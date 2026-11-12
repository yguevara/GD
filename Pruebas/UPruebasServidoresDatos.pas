unit UPruebasServidoresDatos;

{ Datos de servidores FTP/S3 (UServidoresDatos). La parte de validacion no usa
  base de datos; la de lectura/escritura usa SGDTEST_ALCANCE (ARCHIGENIO_TEST_DB)
  y deja la base como estaba: borra toda fila cuya etiqueta empiece por zz_srv. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UServidoresDatos;

type
  [TestFixture]
  TPruebasValidarServidor = class
  private
    function FtpValido: TServidor;
    function S3Valido: TServidor;
    function TieneError(const E: TArray<TErrorCampo>; const Campo: string): Boolean;
  public
    [Test]
    procedure Valido_FtpCompleto_SinErrores;
    [Test]
    procedure Valido_S3Completo_SinErrores;
    [Test]
    procedure Etiqueta_Vacia_Error;
    [Test]
    procedure Puerto_Cero_Error;
    [Test]
    procedure Puerto_70000_Error;
    [Test]
    procedure Ftp_SinUsuario_Error;
    [Test]
    procedure Ftp_ClaveDe21Caracteres_Error;
    [Test]
    procedure S3_SinBucket_Error;
    [Test]
    procedure S3_Nuevo_SinSecreto_Error;
    [Test]
    procedure S3_Existente_SinSecreto_Valido;
    [Test]
    procedure Un_Error_Por_Campo;
  end;

  [TestFixture]
  TPruebasListarServidores = class
  private
    FConn: TFDConnection;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Listar_IncluyeElFtpExistente;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt,
  FireDAC.ConsoleUI.Wait;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';

{ TPruebasValidarServidor }

function TPruebasValidarServidor.FtpValido: TServidor;
begin
  Result := Default(TServidor);
  Result.Id := 0;
  Result.Etiqueta := 'zz_srv ftp';
  Result.Tipo := tsFtp;
  Result.Direccion := '192.168.1.20';
  Result.Puerto := 21;
  Result.RutaRaiz := '/documentos';
  Result.Usuario := 'archivo';
  Result.Clave := 'secreta';
end;

function TPruebasValidarServidor.S3Valido: TServidor;
begin
  Result := Default(TServidor);
  Result.Id := 0;
  Result.Etiqueta := 'zz_srv minio';
  Result.Tipo := tsS3;
  Result.Direccion := 'minio.empresa.local';
  Result.Puerto := 9000;
  Result.Bucket := 'archivo-digital';
  Result.Region := 'us-east-1';
  Result.ClaveAcceso := 'archigenio';
  Result.Secreto := 'clave-secreta';
end;

function TPruebasValidarServidor.TieneError(const E: TArray<TErrorCampo>;
  const Campo: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(E) do
    if E[I].Campo = Campo then
      Exit(True);
end;

procedure TPruebasValidarServidor.Valido_FtpCompleto_SinErrores;
begin
  Assert.AreEqual(0, Length(ValidarServidor(FtpValido)));
end;

procedure TPruebasValidarServidor.Valido_S3Completo_SinErrores;
begin
  Assert.AreEqual(0, Length(ValidarServidor(S3Valido)));
end;

procedure TPruebasValidarServidor.Etiqueta_Vacia_Error;
var
  S: TServidor;
begin
  S := FtpValido;
  S.Etiqueta := '   ';
  Assert.IsTrue(TieneError(ValidarServidor(S), 'etiqueta'));
end;

procedure TPruebasValidarServidor.Puerto_Cero_Error;
var
  S: TServidor;
begin
  S := FtpValido;
  S.Puerto := 0;
  Assert.IsTrue(TieneError(ValidarServidor(S), 'puerto'));
end;

procedure TPruebasValidarServidor.Puerto_70000_Error;
var
  S: TServidor;
begin
  S := S3Valido;
  S.Puerto := 70000;
  Assert.IsTrue(TieneError(ValidarServidor(S), 'puerto'));
end;

procedure TPruebasValidarServidor.Ftp_SinUsuario_Error;
var
  S: TServidor;
begin
  S := FtpValido;
  S.Usuario := '';
  Assert.IsTrue(TieneError(ValidarServidor(S), 'usuario'));
end;

procedure TPruebasValidarServidor.Ftp_ClaveDe21Caracteres_Error;
var
  S: TServidor;
begin
  S := FtpValido;
  S.Clave := StringOfChar('a', 21);
  Assert.IsTrue(TieneError(ValidarServidor(S), 'clave'));
end;

procedure TPruebasValidarServidor.S3_SinBucket_Error;
var
  S: TServidor;
begin
  S := S3Valido;
  S.Bucket := '';
  Assert.IsTrue(TieneError(ValidarServidor(S), 'bucket'));
end;

procedure TPruebasValidarServidor.S3_Nuevo_SinSecreto_Error;
var
  S: TServidor;
begin
  S := S3Valido;
  S.Secreto := '';
  Assert.IsTrue(TieneError(ValidarServidor(S), 'secreto'));
end;

procedure TPruebasValidarServidor.S3_Existente_SinSecreto_Valido;
var
  S: TServidor;
begin
  S := S3Valido;
  S.Id := 5;
  S.Secreto := '';
  Assert.AreEqual(0, Length(ValidarServidor(S)));
end;

procedure TPruebasValidarServidor.Un_Error_Por_Campo;
var
  S: TServidor;
  E: TArray<TErrorCampo>;
begin
  S := FtpValido;
  S.Etiqueta := '';
  S.Puerto := 0;
  E := ValidarServidor(S);
  Assert.AreEqual(2, Length(E));
  Assert.IsTrue(E[0].Campo <> E[1].Campo);
end;

{ TPruebasListarServidores }

procedure TPruebasListarServidores.Preparar;
var
  NombreBD: string;
begin
  FConn := nil;
  NombreBD := GetEnvironmentVariable(VAR_BD);
  if NombreBD = '' then
    Exit;
  if SameText(NombreBD, 'SGDDRHMAIN') then
    raise Exception.Create('Las pruebas no deben correr contra SGDDRHMAIN');
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := NombreBD;
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
end;

procedure TPruebasListarServidores.Limpiar;
begin
  FreeAndNil(FConn);
end;

procedure TPruebasListarServidores.Listar_IncluyeElFtpExistente;
var
  L: TArray<TServidor>;
  I: Integer;
  Hallado: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  L := ListarServidores(FConn);
  Hallado := False;
  for I := 0 to High(L) do
    if L[I].Id = 1 then
    begin
      Hallado := True;
      Assert.AreEqual(Ord(tsFtp), Ord(L[I].Tipo));
      Assert.AreEqual('', L[I].Secreto);
    end;
  Assert.IsTrue(Hallado, 'debe existir el servidor Id 1');
end;

end.
