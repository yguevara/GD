unit UAlmacenServidor;

{ Elige el almacen de ficheros (S3 o FTP de solo lectura) a partir de la fila
  del servidor en cl_ftp_Server y del urlraiz de cada fichero. Solo RTL +
  FireDAC, sin VCL ni UDM. }

interface

uses
  FireDAC.Comp.Client, UAlmacenFicheros;

type
  TDatosServidorS3 = record
    Id: Integer;          // 0 = servidor nuevo
    Etiqueta: string;
    Endpoint: string;     // host o DNS, sin puerto
    Puerto: Integer;
    Bucket: string;
    Region: string;
    ClaveAcceso: string;
    Secreto: string;      // vacio al editar = conservar el anterior
    UsoHttps: Boolean;
  end;

{ Alta o edicion de un servidor S3 en cl_ftp_Server; el secreto se guarda
  cifrado. Devuelve el Idservidor. EAlmacen si faltan datos (no escribe). }
function GuardarServidorS3(Conn: TFDConnection; const D: TDatosServidorS3): Integer;
{ Servidor S3 o FTP segun su columna tipo. EAlmacen si no existe o esta incompleto. }
function CrearAlmacen(Conn: TFDConnection; Idservidor: Integer): IAlmacenFicheros;
{ Almacen de un fichero segun su urlraiz: 's3://<n>/' usa el servidor n y la
  clave Path + Nombre; cualquier otro valor es FTP del servidor por defecto,
  con la ruta urlraiz + Path + Nombre normalizada. }
function AlmacenParaFichero(Conn: TFDConnection; const UrlRaiz: string;
  IdservidorPorDefecto: Integer; out Clave: string; const Path, Nombre: string): IAlmacenFicheros;
{ Primer servidor de tipo S3 (donde van los ficheros nuevos); 0 si no hay }
function ServidorDestinoNuevos(Conn: TFDConnection): Integer;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Param, Data.DB, UAlmacenS3,
  UAlmacenFtp, USecretoServidor;

function CrearAlmacen(Conn: TFDConnection; Idservidor: Integer): IAlmacenFicheros;
var
  Q: TFDQuery;
  Tipo, Host, Bucket, Secreto: string;
  Puerto: Integer;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT * FROM cl_ftp_Server WHERE Idservidor = :id';
    Q.ParamByName('id').AsInteger := Idservidor;
    Q.Open;
    if Q.IsEmpty then
      raise EAlmacen.CreateFmt('No existe el servidor de ficheros %d.', [Idservidor]);
    Tipo := UpperCase(Trim(Q.FieldByName('tipo').AsString));
    Host := Trim(Q.FieldByName('ipserver').AsString);
    Puerto := Q.FieldByName('puerto').AsInteger;
    if Tipo = 'S3' then
    begin
      Bucket := Trim(Q.FieldByName('bucket').AsString);
      Secreto := DescifrarSecreto(Q.FieldByName('secreto_cifrado').AsString);
      if (Host = '') or (Bucket = '') or (Trim(Q.FieldByName('clave_acceso').AsString) = '') or
        (Secreto = '') then
        raise EAlmacen.CreateFmt('El servidor S3 %d esta incompleto: revise endpoint, ' +
          'bucket, clave de acceso y secreto.', [Idservidor]);
      if Puerto > 0 then
        Host := Host + ':' + IntToStr(Puerto);
      Result := TAlmacenS3.Create(Host, Bucket, Trim(Q.FieldByName('clave_acceso').AsString),
        Secreto, Trim(Q.FieldByName('region').AsString), Q.FieldByName('usohttps').AsBoolean);
    end
    else
      Result := TAlmacenFtp.Create(Host, Q.FieldByName('usuarioftp').AsString,
        Q.FieldByName('pass').AsString, Puerto, '');
  finally
    Q.Free;
  end;
end;

function AlmacenParaFichero(Conn: TFDConnection; const UrlRaiz: string;
  IdservidorPorDefecto: Integer; out Clave: string; const Path, Nombre: string): IAlmacenFicheros;
var
  Id: Integer;
begin
  if EsUrlRaizS3(UrlRaiz, Id) then
  begin
    Clave := NormalizarRutaFtp(Path + Nombre);
    if (Clave <> '') and (Clave[1] = '/') then
      Delete(Clave, 1, 1);
    Result := CrearAlmacen(Conn, Id);
  end
  else
  begin
    Clave := NormalizarRutaFtp(UrlRaiz + Path + Nombre);
    Result := CrearAlmacen(Conn, IdservidorPorDefecto);
  end;
end;

function GuardarServidorS3(Conn: TFDConnection; const D: TDatosServidorS3): Integer;
var
  Cifrado: string;
  V: Variant;
begin
  if (Trim(D.Endpoint) = '') or (Trim(D.Bucket) = '') or (Trim(D.ClaveAcceso) = '') or
    (D.Puerto <= 0) then
    raise EAlmacen.Create('Complete el servidor, el puerto, el bucket y la clave de acceso.');
  if (D.Id = 0) and (D.Secreto = '') then
    raise EAlmacen.Create('Indique el secreto de acceso.');
  if D.Secreto <> '' then
    Cifrado := CifrarSecreto(D.Secreto);
  if D.Id = 0 then
  begin
    V := Conn.ExecSQLScalar('SELECT MAX(Idservidor) FROM cl_ftp_Server');
    if VarIsNull(V) or VarIsEmpty(V) then
      Result := 1
    else
      Result := Integer(V) + 1;
    Conn.ExecSQL('INSERT INTO cl_ftp_Server (Idservidor, etiquetaServ, ipserver, path, ' +
      'pass, puerto, usuarioftp, tipo, bucket, region, usohttps, clave_acceso, ' +
      'secreto_cifrado) VALUES (:id, :e, :h, :p, :pw, :pu, :u, :t, :b, :r, :s, :ca, :sc)',
      [Result, Trim(D.Etiqueta), Trim(D.Endpoint), '', '', D.Puerto, '', 'S3',
      Trim(D.Bucket), Trim(D.Region), D.UsoHttps, Trim(D.ClaveAcceso), Cifrado]);
  end
  else
  begin
    Result := D.Id;
    Conn.ExecSQL('UPDATE cl_ftp_Server SET etiquetaServ = :e, ipserver = :h, puerto = :pu, ' +
      'bucket = :b, region = :r, usohttps = :s, clave_acceso = :ca WHERE Idservidor = :id',
      [Trim(D.Etiqueta), Trim(D.Endpoint), D.Puerto, Trim(D.Bucket), Trim(D.Region),
      D.UsoHttps, Trim(D.ClaveAcceso), Result]);
    if D.Secreto <> '' then
      Conn.ExecSQL('UPDATE cl_ftp_Server SET secreto_cifrado = :sc WHERE Idservidor = :id',
        [Cifrado, Result]);
  end;
end;

function ServidorDestinoNuevos(Conn: TFDConnection): Integer;
var
  V: Variant;
begin
  V := Conn.ExecSQLScalar('SELECT MIN(Idservidor) FROM cl_ftp_Server WHERE tipo = ''S3''');
  if VarIsNull(V) or VarIsEmpty(V) then
    Result := 0
  else
    Result := V;
end;

end.
