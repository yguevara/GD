unit UServidoresDatos;

{ ---------------------------------------------------------------------------
  Datos de los servidores de ficheros (FTP y S3/MinIO) de cl_ftp_Server.
  Sin VCL ni TUDM (RTL + FireDAC + Indy). La pantalla UCLServidoresForm solo
  presenta; las reglas viven aqui para poder probarlas.

  Tipo de servidor: cl_ftp_Server.tipo es 'FTP' o 'S3' (vacio o NULL = FTP).
  El secreto de un servidor S3 se guarda cifrado (USecretoServidor) y nunca se
  devuelve al leer: TServidor.Secreto es solo de entrada.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client;

type
  TTipoServidor = (tsFtp, tsS3);

  TServidor = record
    Id: Integer;             // 0 = servidor nuevo
    Etiqueta: string;        // nombre para mostrar (etiquetaServ, max 50)
    Tipo: TTipoServidor;
    Direccion: string;       // ipserver (max 100)
    Puerto: Integer;
    RutaRaiz: string;        // path (solo FTP)
    Usuario, Clave: string;  // usuarioftp, pass (solo FTP; Clave max 20)
    Bucket, Region: string;  // solo S3
    UsoHttps: Boolean;       // solo S3
    ClaveAcceso: string;     // solo S3
    Secreto: string;         // solo entrada; vacio al editar = conservar el guardado
  end;

  TErrorCampo = record
    Campo: string;           // etiqueta, direccion, puerto, usuario, clave, bucket, claveacceso, secreto
    Mensaje: string;
  end;

  EServidorInvalido = class(Exception);

  EServidorEnUso = class(Exception)
  public
    Usos: Integer;
  end;

{ Filas de cl_ftp_Server ordenadas por Idservidor (Secreto siempre vacio). }
function ListarServidores(Conn: TFDConnection): TArray<TServidor>;

{ Valida un servidor antes de guardarlo. Lista vacia = valido; como maximo un
  error por campo. }
function ValidarServidor(const S: TServidor): TArray<TErrorCampo>;

{ Alta (Id = 0) o edicion. Valida primero (EServidorInvalido con el primer
  mensaje; no escribe nada). S3 usa GuardarServidorS3 (secreto cifrado; vacio al
  editar = conserva el guardado). FTP escribe etiquetaServ, ipserver, path, pass,
  puerto, usuarioftp y tipo = 'FTP' (clave vacia al editar = conserva la guardada).
  Devuelve el Idservidor. }
function GuardarServidor(Conn: TFDConnection; const S: TServidor): Integer;

{ Documentos y ficheros que usan el servidor: tb_SeriesDatos.Idservidor +
  tb_Serietree.Idservidor + tb_ssArchdigital con urlraiz que empieza por
  's3://<id>/'. }
function ContarUsoServidor(Conn: TFDConnection; Id: Integer): Integer;

{ Secreto S3 guardado, ya descifrado ('' si no hay). Sirve para "Probar conexion"
  al editar sin volver a escribirlo; se lee en el hilo principal. }
function LeerSecretoGuardado(Conn: TFDConnection; Id: Integer): string;

{ Contrasena FTP guardada ('' si no hay). }
function LeerClaveFtpGuardada(Conn: TFDConnection; Id: Integer): string;

{ Elimina el servidor. Si esta en uso lanza EServidorEnUso (con Usos) y no borra. }
procedure EliminarServidor(Conn: TFDConnection; Id: Integer);

{ Prueba la conexion. S3: TAlmacenS3.Probar con el secreto escrito o, si esta
  vacio, el guardado. FTP: conectar y desconectar. Conn puede ser nil si no hay
  que leer nada guardado. Nunca lanza: devuelve False y un Mensaje legible. }
function ProbarServidor(Conn: TFDConnection; const S: TServidor; out Mensaje: string): Boolean;

implementation

uses
  System.Generics.Collections, System.Variants, Data.DB, FireDAC.Stan.Param,
  IdFTP, UAlmacenFicheros, UAlmacenS3, UAlmacenServidor, USecretoServidor;

function ListarServidores(Conn: TFDConnection): TArray<TServidor>;
var
  Q: TFDQuery;
  L: TList<TServidor>;
  S: TServidor;
begin
  L := TList<TServidor>.Create;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.Open('SELECT Idservidor, etiquetaServ, ipserver, path, pass, puerto, usuarioftp, ' +
        'tipo, bucket, region, usohttps, clave_acceso FROM cl_ftp_Server ORDER BY Idservidor');
      while not Q.Eof do
      begin
        S := Default(TServidor);
        S.Id := Q.FieldByName('Idservidor').AsInteger;
        S.Etiqueta := Trim(Q.FieldByName('etiquetaServ').AsString);
        if SameText(Trim(Q.FieldByName('tipo').AsString), 'S3') then
          S.Tipo := tsS3
        else
          S.Tipo := tsFtp;
        S.Direccion := Trim(Q.FieldByName('ipserver').AsString);
        S.Puerto := Q.FieldByName('puerto').AsInteger;
        S.RutaRaiz := Q.FieldByName('path').AsString;
        S.Usuario := Q.FieldByName('usuarioftp').AsString;
        S.Clave := Q.FieldByName('pass').AsString;
        S.Bucket := Trim(Q.FieldByName('bucket').AsString);
        S.Region := Trim(Q.FieldByName('region').AsString);
        S.UsoHttps := Q.FieldByName('usohttps').AsBoolean;
        S.ClaveAcceso := Trim(Q.FieldByName('clave_acceso').AsString);
        L.Add(S);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function ValidarServidor(const S: TServidor): TArray<TErrorCampo>;
var
  L: TList<TErrorCampo>;

  procedure Error(const Campo, Mensaje: string);
  var
    E: TErrorCampo;
  begin
    E.Campo := Campo;
    E.Mensaje := Mensaje;
    L.Add(E);
  end;

begin
  L := TList<TErrorCampo>.Create;
  try
    if Trim(S.Etiqueta) = '' then
      Error('etiqueta', 'Escriba un nombre para el servidor.')
    else if Length(Trim(S.Etiqueta)) > 50 then
      Error('etiqueta', 'El nombre admite como maximo 50 caracteres.');
    if Trim(S.Direccion) = '' then
      Error('direccion', 'Escriba la direcci'#243'n del servidor.')
    else if Length(Trim(S.Direccion)) > 100 then
      Error('direccion', 'La direcci'#243'n admite como maximo 100 caracteres.');
    if (S.Puerto < 1) or (S.Puerto > 65535) then
      Error('puerto', 'El puerto debe estar entre 1 y 65535.');
    if S.Tipo = tsFtp then
    begin
      if Trim(S.Usuario) = '' then
        Error('usuario', 'Escriba el usuario del servidor FTP.');
      if (S.Id = 0) and (S.Clave = '') then
        Error('clave', 'Escriba la contrase'#241'a del servidor FTP.')
      else if Length(S.Clave) > 20 then
        Error('clave', 'La contrase'#241'a FTP admite como maximo 20 caracteres.');
    end
    else
    begin
      if Trim(S.Bucket) = '' then
        Error('bucket', 'Escriba el nombre del bucket.');
      if Trim(S.ClaveAcceso) = '' then
        Error('claveacceso', 'Escriba la clave de acceso (Access Key).');
      if (S.Id = 0) and (S.Secreto = '') then
        Error('secreto', 'Escriba la clave secreta (Secret Key).');
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function SiguienteId(Conn: TFDConnection): Integer;
var
  V: Variant;
begin
  V := Conn.ExecSQLScalar('SELECT MAX(Idservidor) FROM cl_ftp_Server');
  if VarIsNull(V) or VarIsEmpty(V) then
    Result := 1
  else
    Result := Integer(V) + 1;
end;

function GuardarServidor(Conn: TFDConnection; const S: TServidor): Integer;
var
  Errores: TArray<TErrorCampo>;
  D: TDatosServidorS3;
begin
  Errores := ValidarServidor(S);
  if Length(Errores) > 0 then
    raise EServidorInvalido.Create(Errores[0].Mensaje);
  if S.Tipo = tsS3 then
  begin
    D := Default(TDatosServidorS3);
    D.Id := S.Id;
    D.Etiqueta := Trim(S.Etiqueta);
    D.Endpoint := Trim(S.Direccion);
    D.Puerto := S.Puerto;
    D.Bucket := Trim(S.Bucket);
    D.Region := Trim(S.Region);
    D.ClaveAcceso := Trim(S.ClaveAcceso);
    D.Secreto := S.Secreto;
    D.UsoHttps := S.UsoHttps;
    Exit(GuardarServidorS3(Conn, D));
  end;
  Conn.StartTransaction;
  try
    if S.Id = 0 then
    begin
      Result := SiguienteId(Conn);
      Conn.ExecSQL('INSERT INTO cl_ftp_Server (Idservidor, etiquetaServ, ipserver, path, ' +
        'pass, puerto, usuarioftp, tipo) VALUES (:id, :e, :h, :p, :pw, :pu, :u, :t)',
        [Result, Trim(S.Etiqueta), Trim(S.Direccion), S.RutaRaiz, S.Clave, S.Puerto,
        Trim(S.Usuario), 'FTP']);
    end
    else
    begin
      Result := S.Id;
      Conn.ExecSQL('UPDATE cl_ftp_Server SET etiquetaServ = :e, ipserver = :h, path = :p, ' +
        'puerto = :pu, usuarioftp = :u, tipo = :t WHERE Idservidor = :id',
        [Trim(S.Etiqueta), Trim(S.Direccion), S.RutaRaiz, S.Puerto, Trim(S.Usuario),
        'FTP', Result]);
      if S.Clave <> '' then
        Conn.ExecSQL('UPDATE cl_ftp_Server SET pass = :pw WHERE Idservidor = :id',
          [S.Clave, Result]);
    end;
    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;

function LeerSecretoGuardado(Conn: TFDConnection; Id: Integer): string;
begin
  Result := DescifrarSecreto(VarToStr(Conn.ExecSQLScalar(
    'SELECT secreto_cifrado FROM cl_ftp_Server WHERE Idservidor = :i', [Id])));
end;

function LeerClaveFtpGuardada(Conn: TFDConnection; Id: Integer): string;
begin
  Result := VarToStr(Conn.ExecSQLScalar(
    'SELECT pass FROM cl_ftp_Server WHERE Idservidor = :i', [Id]));
end;

function ContarUsoServidor(Conn: TFDConnection; Id: Integer): Integer;
var
  Prefijo: string;
begin
  Prefijo := UrlRaizS3(Id);
  Result := Integer(Conn.ExecSQLScalar(
    'SELECT COUNT(*) FROM tb_SeriesDatos WHERE Idservidor = :id', [Id]));
  Result := Result + Integer(Conn.ExecSQLScalar(
    'SELECT COUNT(*) FROM tb_Serietree WHERE Idservidor = :id', [Id]));
  Result := Result + Integer(Conn.ExecSQLScalar(
    'SELECT COUNT(*) FROM tb_ssArchdigital WHERE LEFT(urlraiz, :n) = :p',
    [Length(Prefijo), Prefijo]));
end;

procedure EliminarServidor(Conn: TFDConnection; Id: Integer);
var
  Usos: Integer;
  E: EServidorEnUso;
begin
  Usos := ContarUsoServidor(Conn, Id);
  if Usos > 0 then
  begin
    E := EServidorEnUso.CreateFmt('El servidor no se puede eliminar: lo usan %d ' +
      'documento(s) o fichero(s).', [Usos]);
    E.Usos := Usos;
    raise E;
  end;
  Conn.ExecSQL('DELETE FROM cl_ftp_Server WHERE Idservidor = :id', [Id]);
end;

function ProbarServidor(Conn: TFDConnection; const S: TServidor; out Mensaje: string): Boolean;
var
  Secreto, Clave, Host: string;
  Alm: TAlmacenS3;
  Ref: IAlmacenFicheros;
  Ftp: TIdFTP;
begin
  Result := False;
  Mensaje := '';
  try
    if S.Tipo = tsS3 then
    begin
      Secreto := S.Secreto;
      if (Secreto = '') and (S.Id > 0) and (Conn <> nil) then
        Secreto := LeerSecretoGuardado(Conn, S.Id);
      if (Trim(S.Direccion) = '') or (Trim(S.Bucket) = '') or
        (Trim(S.ClaveAcceso) = '') or (S.Puerto <= 0) or (Secreto = '') then
      begin
        Mensaje := 'Complete servidor, puerto, bucket, clave de acceso y clave secreta.';
        Exit;
      end;
      Host := Trim(S.Direccion) + ':' + IntToStr(S.Puerto);
      Alm := TAlmacenS3.Create(Host, Trim(S.Bucket), Trim(S.ClaveAcceso), Secreto,
        Trim(S.Region), S.UsoHttps);
      Ref := Alm;
      Result := Alm.Probar(Mensaje);
      if Mensaje = '' then
        if Result then
          Mensaje := 'Conexi'#243'n correcta.'
        else
          Mensaje := 'No se pudo conectar con el servidor.';
    end
    else
    begin
      Clave := S.Clave;
      if (Clave = '') and (S.Id > 0) and (Conn <> nil) then
        Clave := LeerClaveFtpGuardada(Conn, S.Id);
      if (Trim(S.Direccion) = '') or (S.Puerto <= 0) or (Trim(S.Usuario) = '') then
      begin
        Mensaje := 'Complete servidor, puerto y usuario.';
        Exit;
      end;
      Ftp := TIdFTP.Create(nil);
      try
        Ftp.Host := Trim(S.Direccion);
        Ftp.Port := S.Puerto;
        Ftp.Username := Trim(S.Usuario);
        Ftp.Password := Clave;
        Ftp.ConnectTimeout := 5000;
        Ftp.ReadTimeout := 5000;
        Ftp.Connect;
        Result := True;
        Mensaje := 'Conexi'#243'n correcta.';
        Ftp.Disconnect;
      finally
        Ftp.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      Result := False;
      Mensaje := 'No se pudo conectar: ' + E.Message;
    end;
  end;
end;

end.
