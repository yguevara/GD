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

implementation

uses
  System.Generics.Collections, Data.DB;

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

end.
