unit UAlmacenS3;

{ Cliente S3/MinIO propio: firma SigV4 y direccionamiento por ruta
  (http(s)://endpoint/bucket/clave), sin DNS especial. Sube por flujo (nunca
  carga el fichero entero), reintenta ante fallos de red o 5xx y no incluye
  credenciales en los mensajes de error. Solo RTL, sin VCL ni UDM. }

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, UAlmacenFicheros;

{ El Host que envia WinHTTP omite el puerto por defecto (443 con HTTPS, 80 sin
  HTTPS): la firma debe usar ese mismo valor. }
function HostFirmado(const Endpoint: string; Https: Boolean): string;

type
  TAlmacenS3 = class(TInterfacedObject, IAlmacenFicheros)
  private
    FEndpoint, FHostFirmado, FBucket, FAccessKey, FSecretKey, FRegion: string;
    FHttps: Boolean;
    function RutaDe(const Clave: string): string;
    function Esquema: string;
    function Peticion(const Metodo, Ruta, Consulta: string; Cuerpo: TStream;
      const HashCuerpo: string; Destino: TStream; AlRecibir: TReceiveDataEvent): IHTTPResponse;
    function PeticionConReintento(const Metodo, Ruta, Consulta: string; const Local: string;
      const HashCuerpo: string; Progreso: TProgresoEvento; Total: Int64): IHTTPResponse;
    procedure ExigirOk(const R: IHTTPResponse; const Accion: string; LeerCuerpo: Boolean = True);
    procedure ProgresoDescarga(const Sender: TObject; AContentLength, AReadCount: Int64;
      var Abort: Boolean);
  private
    FProgresoActual: TProgresoEvento;
    FCanceladoDescarga: Boolean;
  public
    constructor Create(const Endpoint, Bucket, AccessKey, SecretKey, Region: string;
      Https: Boolean);
    { Crea el bucket si no existe }
    procedure AsegurarBucket;
    { Ida y vuelta completa; el mensaje nunca incluye el secreto }
    function Probar(out Mensaje: string): Boolean;
    function Subir(const Local, Clave: string; Progreso: TProgresoEvento): TResultadoSubida;
    procedure Descargar(const Clave, Local: string; Progreso: TProgresoEvento);
    function Existe(const Clave: string; out Tamano: Int64): Boolean;
    procedure Borrar(const Clave: string);
    function UrlTemporal(const Clave: string; Segundos: Integer): string;
  end;

implementation

uses
  System.IOUtils, System.Hash, System.DateUtils, USigV4;

const
  BLOQUE = 1024 * 1024;
  INTENTOS = 3;

type
  ECancelado = class(Exception);

  { Lee de un fichero y avisa del avance; permite cancelar a mitad de envio }
  TFlujoConProgreso = class(TStream)
  private
    FInterno: TFileStream;
    FProgreso: TProgresoEvento;
    FTotal: Int64;
  protected
    function GetSize: Int64; override;
  public
    constructor Create(const Ruta: string; Progreso: TProgresoEvento);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
  end;

constructor TFlujoConProgreso.Create(const Ruta: string; Progreso: TProgresoEvento);
begin
  inherited Create;
  FInterno := TFileStream.Create(Ruta, fmOpenRead or fmShareDenyWrite);
  FProgreso := Progreso;
  FTotal := FInterno.Size;
end;

destructor TFlujoConProgreso.Destroy;
begin
  FInterno.Free;
  inherited;
end;

function TFlujoConProgreso.GetSize: Int64;
begin
  Result := FTotal;
end;

function TFlujoConProgreso.Read(var Buffer; Count: Longint): Longint;
var
  Cancelar: Boolean;
begin
  Result := FInterno.Read(Buffer, Count);
  if Assigned(FProgreso) then
  begin
    Cancelar := False;
    FProgreso(FInterno.Position, FTotal, Cancelar);
    if Cancelar then
      raise ECancelado.Create('cancelado');
  end;
end;

function TFlujoConProgreso.Write(const Buffer; Count: Longint): Longint;
begin
  raise EAlmacen.Create('Flujo de solo lectura');
end;

function TFlujoConProgreso.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  Result := FInterno.Seek(Offset, Origin);
end;

function HostFirmado(const Endpoint: string; Https: Boolean): string;
begin
  Result := Endpoint;
  if Https and Result.EndsWith(':443') then
    Result := Copy(Result, 1, Length(Result) - 4)
  else if (not Https) and Result.EndsWith(':80') then
    Result := Copy(Result, 1, Length(Result) - 3);
end;

function UtcAhora: TDateTime;
begin
  Result := TTimeZone.Local.ToUniversalTime(Now);
end;

function CodigoS3(const Cuerpo: string): string;
var
  A, B: Integer;
begin
  Result := '';
  A := Pos('<Code>', Cuerpo);
  B := Pos('</Code>', Cuerpo);
  if (A > 0) and (B > A) then
    Result := Copy(Cuerpo, A + 6, B - A - 6);
end;

constructor TAlmacenS3.Create(const Endpoint, Bucket, AccessKey, SecretKey,
  Region: string; Https: Boolean);
begin
  inherited Create;
  FEndpoint := Trim(Endpoint);
  FBucket := Trim(Bucket);
  FAccessKey := AccessKey;
  FSecretKey := SecretKey;
  FRegion := Trim(Region);
  if FRegion = '' then
    FRegion := 'us-east-1';
  FHttps := Https;
  FHostFirmado := HostFirmado(FEndpoint, FHttps);
end;

function TAlmacenS3.Esquema: string;
begin
  if FHttps then
    Result := 'https'
  else
    Result := 'http';
end;

function TAlmacenS3.RutaDe(const Clave: string): string;
begin
  Result := '/' + FBucket + '/' + StringReplace(Clave, '\', '/', [rfReplaceAll]);
end;

function TAlmacenS3.Peticion(const Metodo, Ruta, Consulta: string; Cuerpo: TStream;
  const HashCuerpo: string; Destino: TStream; AlRecibir: TReceiveDataEvent): IHTTPResponse;
var
  Cli: THTTPClient;
  Fecha, Url: string;
  Vacio: TMemoryStream;
begin
  Cli := THTTPClient.Create;
  Vacio := nil;
  try
    Cli.CustomHeaders['x-amz-content-sha256'] := HashCuerpo;
    Cli.CustomHeaders['Authorization'] := FirmarPeticion(Metodo, Ruta, Consulta,
      FHostFirmado, FRegion, FAccessKey, FSecretKey, HashCuerpo, UtcAhora, Fecha);
    Cli.CustomHeaders['x-amz-date'] := Fecha;
    Cli.OnReceiveData := AlRecibir;
    Url := Esquema + '://' + FEndpoint + UriEncode(Ruta, True);
    if Consulta <> '' then
      Url := Url + '?' + Consulta;
    if (Cuerpo = nil) and ((Metodo = 'PUT') or (Metodo = 'POST')) then
    begin
      Vacio := TMemoryStream.Create;
      Cuerpo := Vacio;
    end;
    Result := Cli.Execute(Metodo, Url, Cuerpo, Destino) as IHTTPResponse;
  finally
    Vacio.Free;
    Cli.Free;
  end;
end;

procedure TAlmacenS3.ExigirOk(const R: IHTTPResponse; const Accion: string;
  LeerCuerpo: Boolean);
var
  Codigo, Motivo: string;
begin
  if (R.StatusCode >= 200) and (R.StatusCode < 300) then
    Exit;
  Codigo := '';
  if LeerCuerpo then
    try
      Codigo := CodigoS3(R.ContentAsString(TEncoding.UTF8));
    except
      Codigo := '';
    end;
  case R.StatusCode of
    403: Motivo := 'acceso denegado (revise la clave de acceso, el secreto y los permisos)';
    404: Motivo := 'no encontrado (revise el bucket y la clave)';
  else
    Motivo := 'el servidor respondio con error';
  end;
  if Codigo <> '' then
    Motivo := Motivo + ' [' + Codigo + ']';
  raise EAlmacen.CreateFmt('No se pudo %s en el servidor S3: %s (codigo %d).',
    [Accion, Motivo, R.StatusCode]);
end;

function TAlmacenS3.PeticionConReintento(const Metodo, Ruta, Consulta: string;
  const Local: string; const HashCuerpo: string; Progreso: TProgresoEvento;
  Total: Int64): IHTTPResponse;
var
  Intento: Integer;
  Flujo: TFlujoConProgreso;
  Cancelado: Boolean;
begin
  Result := nil;
  Cancelado := False;
  for Intento := 1 to INTENTOS do
  begin
    Flujo := TFlujoConProgreso.Create(Local,
      procedure(Hecho, Tot: Int64; var Cancelar: Boolean)
      begin
        if Assigned(Progreso) then
          Progreso(Hecho, Tot, Cancelar);
        if Cancelar then
          Cancelado := True;
      end);
    try
      try
        Result := Peticion(Metodo, Ruta, Consulta, Flujo, HashCuerpo, nil, nil);
        if Result.StatusCode < 500 then
          Exit;
      except
        on E: Exception do
        begin
          if Cancelado then
            raise EAlmacen.Create('Subida cancelada.');
          if Intento = INTENTOS then
            raise EAlmacen.CreateFmt('No se pudo conectar con el servidor S3 (%s).', [FEndpoint]);
        end;
      end;
    finally
      Flujo.Free;
    end;
    Sleep(300 * Intento);
  end;
end;

procedure TAlmacenS3.AsegurarBucket;
var
  R: IHTTPResponse;
begin
  try
    R := Peticion('HEAD', '/' + FBucket, '', nil, HexSha256(nil), nil, nil);
    if R.StatusCode = 404 then
      R := Peticion('PUT', '/' + FBucket, '', nil, HexSha256(nil), nil, nil);
  except
    raise EAlmacen.CreateFmt('No se pudo conectar con el servidor S3 (%s).', [FEndpoint]);
  end;
  if R.StatusCode = 409 then
    Exit; // ya existe
  ExigirOk(R, 'preparar el bucket');
end;

function TAlmacenS3.Subir(const Local, Clave: string; Progreso: TProgresoEvento): TResultadoSubida;
var
  F: TFileStream;
  Sha: THashSHA2;
  Md5: THashMD5;
  Buf: TBytes;
  N: Integer;
  Cancelar: Boolean;
  R: IHTTPResponse;
begin
  if not TFile.Exists(Local) then
    raise EAlmacen.CreateFmt('No existe el fichero local "%s".', [Local]);
  Sha := THashSHA2.Create(SHA256);
  Md5 := THashMD5.Create;
  SetLength(Buf, BLOQUE);
  F := TFileStream.Create(Local, fmOpenRead or fmShareDenyWrite);
  try
    Result.Tamano := F.Size;
    repeat
      N := F.Read(Buf[0], BLOQUE);
      if N > 0 then
      begin
        Sha.Update(Buf, N);
        Md5.Update(Buf, N);
      end;
    until N = 0;
  finally
    F.Free;
  end;
  Result.Md5 := LowerCase(Md5.HashAsString);
  if Assigned(Progreso) then
  begin
    Cancelar := False;
    Progreso(0, Result.Tamano, Cancelar);
    if Cancelar then
      raise EAlmacen.Create('Subida cancelada.');
  end;
  R := PeticionConReintento('PUT', RutaDe(Clave), '', Local, LowerCase(Sha.HashAsString),
    Progreso, Result.Tamano);
  if (R.StatusCode < 200) or (R.StatusCode >= 300) then
    ExigirOk(R, 'subir el fichero');
  if Assigned(Progreso) then
  begin
    Cancelar := False;
    Progreso(Result.Tamano, Result.Tamano, Cancelar);
  end;
end;

procedure TAlmacenS3.ProgresoDescarga(const Sender: TObject; AContentLength,
  AReadCount: Int64; var Abort: Boolean);
var
  Cancelar: Boolean;
begin
  if Assigned(FProgresoActual) then
  begin
    Cancelar := False;
    FProgresoActual(AReadCount, AContentLength, Cancelar);
    if Cancelar then
    begin
      FCanceladoDescarga := True;
      Abort := True;
    end;
  end;
end;

procedure TAlmacenS3.Descargar(const Clave, Local: string; Progreso: TProgresoEvento);
var
  Parte: string;
  F: TFileStream;
  R: IHTTPResponse;
  Ok: Boolean;
begin
  Parte := Local + '.parte';
  FProgresoActual := Progreso;
  FCanceladoDescarga := False;
  Ok := False;
  F := TFileStream.Create(Parte, fmCreate);
  try
    try
      R := Peticion('GET', RutaDe(Clave), '', nil, HexSha256(nil), F, ProgresoDescarga);
    except
      on E: Exception do
      begin
        if FCanceladoDescarga then
          raise EAlmacen.Create('Descarga cancelada.');
        raise EAlmacen.CreateFmt('No se pudo conectar con el servidor S3 (%s).', [FEndpoint]);
      end;
    end;
    Ok := (R.StatusCode >= 200) and (R.StatusCode < 300);
  finally
    F.Free;
    FProgresoActual := nil;
    if not Ok then
      TFile.Delete(Parte);
  end;
  if FCanceladoDescarga then
  begin
    TFile.Delete(Parte);
    raise EAlmacen.Create('Descarga cancelada.');
  end;
  if not Ok then
    ExigirOk(R, 'descargar el fichero', False); // el cuerpo fue al flujo ya liberado
  if TFile.Exists(Local) then
    TFile.Delete(Local);
  TFile.Move(Parte, Local);
end;

function TAlmacenS3.Existe(const Clave: string; out Tamano: Int64): Boolean;
var
  R: IHTTPResponse;
begin
  Tamano := 0;
  try
    R := Peticion('HEAD', RutaDe(Clave), '', nil, HexSha256(nil), nil, nil);
  except
    raise EAlmacen.CreateFmt('No se pudo conectar con el servidor S3 (%s).', [FEndpoint]);
  end;
  if R.StatusCode = 404 then
    Exit(False);
  ExigirOk(R, 'consultar el fichero');
  Result := True;
  Tamano := StrToInt64Def(R.HeaderValue['Content-Length'], 0);
end;

procedure TAlmacenS3.Borrar(const Clave: string);
var
  R: IHTTPResponse;
begin
  try
    R := Peticion('DELETE', RutaDe(Clave), '', nil, HexSha256(nil), nil, nil);
  except
    raise EAlmacen.CreateFmt('No se pudo conectar con el servidor S3 (%s).', [FEndpoint]);
  end;
  if R.StatusCode = 404 then
    Exit;
  ExigirOk(R, 'borrar el fichero');
end;

function TAlmacenS3.UrlTemporal(const Clave: string; Segundos: Integer): string;
begin
  Result := UrlPrefirmada('GET', RutaDe(Clave), FHostFirmado, FRegion, FAccessKey,
    FSecretKey, UtcAhora, Segundos, FHttps);
end;

function TAlmacenS3.Probar(out Mensaje: string): Boolean;
var
  Origen, Destino, K: string;
  Tam: Int64;
begin
  Result := False;
  Origen := TPath.GetTempFileName;
  Destino := TPath.GetTempFileName;
  try
    try
      TFile.WriteAllText(Origen, 'prueba de conexion ArchiGenio');
      AsegurarBucket;
      K := '_prueba/' + TGUID.NewGuid.ToString + '.txt';
      Subir(Origen, K, nil);
      if not Existe(K, Tam) then
        raise EAlmacen.Create('El fichero de prueba no aparece tras subirlo.');
      Descargar(K, Destino, nil);
      Borrar(K);
      if TFile.ReadAllText(Destino) <> 'prueba de conexion ArchiGenio' then
        raise EAlmacen.Create('El fichero de prueba volvio distinto.');
      Mensaje := 'Conexion correcta.';
      Result := True;
    except
      on E: EAlmacen do
        Mensaje := E.Message;
      on E: Exception do
        Mensaje := 'No se pudo completar la prueba: ' + E.ClassName;
    end;
  finally
    if TFile.Exists(Origen) then TFile.Delete(Origen);
    if TFile.Exists(Destino) then TFile.Delete(Destino);
  end;
end;

end.
