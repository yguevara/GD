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

  [TestFixture]
  TPruebasGuardarServidores = class
  private
    FConn: TFDConnection;
    function FtpNuevo(const Etiqueta: string): TServidor;
    function S3Nuevo(const Etiqueta: string): TServidor;
    function ContarServidores: Integer;
    function Secreto(Id: Integer): string;
    procedure Restaurar;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Guardar_FtpNuevo_DevuelveIdYSePuedeLeer;
    [Test]
    procedure Guardar_S3Nuevo_CifraElSecreto;
    [Test]
    procedure Guardar_S3Editar_SinSecreto_ConservaElCifrado;
    [Test]
    procedure Guardar_Invalido_LanzaYNoEscribe;
    [Test]
    procedure Leer_SecretoYClaveGuardados;
    [Test]
    procedure Eliminar_SinUso_Borra;
    [Test]
    procedure Eliminar_EnUsoPorSerieTree_Bloquea;
    [Test]
    procedure Eliminar_EnUsoPorUrlRaizS3_Bloquea;
  end;

  [TestFixture]
  TPruebasProbarServidor = class
  public
    [Test]
    procedure Probar_FtpSinServidor_DevuelveFalseConMensaje;
    [Test]
    procedure Probar_S3EndpointInexistente_DevuelveFalse;
    [Test]
    procedure Probar_S3Incompleto_PideLosDatos;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';

{ Conexion a la base de pruebas; nil si falta la variable de entorno. }
function ConectarPruebas: TFDConnection;
var
  NombreBD: string;
begin
  Result := nil;
  NombreBD := GetEnvironmentVariable(VAR_BD);
  if NombreBD = '' then
    Exit;
  if SameText(NombreBD, 'SGDDRHMAIN') then
    raise Exception.Create('Las pruebas no deben correr contra SGDDRHMAIN');
  Result := TFDConnection.Create(nil);
  Result.LoginPrompt := False;
  Result.DriverName := 'MSSQL';
  Result.Params.Values['Server'] := 'localhost';
  Result.Params.Values['Database'] := NombreBD;
  Result.Params.Values['User_Name'] := 'geoconn';
  Result.Params.Values['Password'] := 'geoconn';
  Result.Params.Values['OSAuthent'] := 'No';
  Result.Connected := True;
end;

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
begin
  FConn := ConectarPruebas;
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

{ TPruebasGuardarServidores }

procedure TPruebasGuardarServidores.Preparar;
begin
  FConn := ConectarPruebas;
  if FConn <> nil then
    Restaurar;
end;

procedure TPruebasGuardarServidores.Restaurar;
begin
  FConn.ExecSQL('DELETE FROM cl_ftp_Server WHERE etiquetaServ LIKE ''zz_srv%''');
end;

procedure TPruebasGuardarServidores.Limpiar;
begin
  if FConn <> nil then
  begin
    if FConn.InTransaction then
      FConn.Rollback;
    Restaurar;
    FreeAndNil(FConn);
  end;
end;

function TPruebasGuardarServidores.FtpNuevo(const Etiqueta: string): TServidor;
begin
  Result := Default(TServidor);
  Result.Etiqueta := Etiqueta;
  Result.Tipo := tsFtp;
  Result.Direccion := '192.168.1.20';
  Result.Puerto := 21;
  Result.RutaRaiz := '/documentos';
  Result.Usuario := 'archivo';
  Result.Clave := 'secreta';
end;

function TPruebasGuardarServidores.S3Nuevo(const Etiqueta: string): TServidor;
begin
  Result := Default(TServidor);
  Result.Etiqueta := Etiqueta;
  Result.Tipo := tsS3;
  Result.Direccion := 'minio.empresa.local';
  Result.Puerto := 9000;
  Result.Bucket := 'archivo-digital';
  Result.Region := 'us-east-1';
  Result.ClaveAcceso := 'archigenio';
  Result.Secreto := 'clave-secreta';
end;

function TPruebasGuardarServidores.ContarServidores: Integer;
begin
  Result := Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(*) FROM cl_ftp_Server WHERE etiquetaServ LIKE ''zz_srv%'''));
end;

function TPruebasGuardarServidores.Secreto(Id: Integer): string;
begin
  Result := VarToStr(FConn.ExecSQLScalar(
    'SELECT secreto_cifrado FROM cl_ftp_Server WHERE Idservidor = :i', [Id]));
end;

procedure TPruebasGuardarServidores.Guardar_FtpNuevo_DevuelveIdYSePuedeLeer;
var
  Id, I: Integer;
  L: TArray<TServidor>;
  Hallado: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Id := GuardarServidor(FConn, FtpNuevo('zz_srv ftp'));
  Assert.IsTrue(Id > 0);
  L := ListarServidores(FConn);
  Hallado := False;
  for I := 0 to High(L) do
    if L[I].Id = Id then
    begin
      Hallado := True;
      Assert.AreEqual('zz_srv ftp', L[I].Etiqueta);
      Assert.AreEqual(Ord(tsFtp), Ord(L[I].Tipo));
      Assert.AreEqual('192.168.1.20', L[I].Direccion);
      Assert.AreEqual('archivo', L[I].Usuario);
      Assert.AreEqual(21, L[I].Puerto);
    end;
  Assert.IsTrue(Hallado);
end;

procedure TPruebasGuardarServidores.Guardar_S3Nuevo_CifraElSecreto;
var
  Id: Integer;
  Cif: string;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Id := GuardarServidor(FConn, S3Nuevo('zz_srv minio'));
  Cif := Secreto(Id);
  Assert.IsTrue(Cif <> '');
  Assert.IsTrue(Cif <> 'clave-secreta');
  Assert.IsTrue(Pos('v1:', Cif) = 1);
end;

procedure TPruebasGuardarServidores.Guardar_S3Editar_SinSecreto_ConservaElCifrado;
var
  S: TServidor;
  Id: Integer;
  Antes: string;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Id := GuardarServidor(FConn, S3Nuevo('zz_srv minio'));
  Antes := Secreto(Id);
  S := S3Nuevo('zz_srv minio');
  S.Id := Id;
  S.Region := 'eu-west-1';
  S.Secreto := '';
  GuardarServidor(FConn, S);
  Assert.AreEqual(Antes, Secreto(Id));
  Assert.AreEqual('eu-west-1', VarToStr(FConn.ExecSQLScalar(
    'SELECT region FROM cl_ftp_Server WHERE Idservidor = :i', [Id])));
end;

procedure TPruebasGuardarServidores.Guardar_Invalido_LanzaYNoEscribe;
var
  S: TServidor;
  Antes: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Antes := ContarServidores;
  S := FtpNuevo('zz_srv malo');
  S.Puerto := 0;
  Assert.WillRaise(
    procedure
    begin
      GuardarServidor(FConn, S);
    end, EServidorInvalido);
  Assert.AreEqual(Antes, ContarServidores);
end;

procedure TPruebasGuardarServidores.Leer_SecretoYClaveGuardados;
var
  IdS3, IdFtp: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  IdS3 := GuardarServidor(FConn, S3Nuevo('zz_srv minio'));
  IdFtp := GuardarServidor(FConn, FtpNuevo('zz_srv ftp'));
  Assert.AreEqual('clave-secreta', LeerSecretoGuardado(FConn, IdS3));
  Assert.AreEqual('secreta', LeerClaveFtpGuardada(FConn, IdFtp));
  Assert.AreEqual('', LeerSecretoGuardado(FConn, 99999));
end;

procedure TPruebasGuardarServidores.Eliminar_SinUso_Borra;
var
  Id: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Id := GuardarServidor(FConn, FtpNuevo('zz_srv borrar'));
  EliminarServidor(FConn, Id);
  Assert.AreEqual(0, ContarServidores);
end;

procedure TPruebasGuardarServidores.Eliminar_EnUsoPorSerieTree_Bloquea;
var
  Id, Usos: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Id := GuardarServidor(FConn, FtpNuevo('zz_srv usado'));
  Usos := 0;
  FConn.StartTransaction;
  try
    FConn.ExecSQL('UPDATE tb_Serietree SET Idservidor = :i', [Id]);
    try
      EliminarServidor(FConn, Id);
      Assert.Fail('debio lanzar EServidorEnUso');
    except
      on E: EServidorEnUso do
        Usos := E.Usos;
    end;
    Assert.IsTrue(Usos >= 1);
    Assert.AreEqual(1, ContarServidores);
  finally
    FConn.Rollback;
  end;
end;

procedure TPruebasGuardarServidores.Eliminar_EnUsoPorUrlRaizS3_Bloquea;
var
  Id, Usos: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Id := GuardarServidor(FConn, S3Nuevo('zz_srv minio usado'));
  Usos := 0;
  FConn.StartTransaction;
  try
    FConn.ExecSQL('UPDATE tb_ssArchdigital SET urlraiz = :u', ['s3://' + IntToStr(Id) + '/']);
    try
      EliminarServidor(FConn, Id);
      Assert.Fail('debio lanzar EServidorEnUso');
    except
      on E: EServidorEnUso do
        Usos := E.Usos;
    end;
    Assert.IsTrue(Usos >= 1);
    Assert.AreEqual(1, ContarServidores);
  finally
    FConn.Rollback;
  end;
end;

{ TPruebasProbarServidor }

procedure TPruebasProbarServidor.Probar_FtpSinServidor_DevuelveFalseConMensaje;
var
  S: TServidor;
  Msg: string;
begin
  S := Default(TServidor);
  S.Tipo := tsFtp;
  S.Direccion := '127.0.0.1';
  S.Puerto := 1;
  S.Usuario := 'x';
  S.Clave := 'x';
  Assert.IsFalse(ProbarServidor(nil, S, Msg));
  Assert.IsTrue(Msg <> '');
end;

procedure TPruebasProbarServidor.Probar_S3EndpointInexistente_DevuelveFalse;
var
  S: TServidor;
  Msg: string;
begin
  S := Default(TServidor);
  S.Tipo := tsS3;
  S.Direccion := 'no-existe.invalid';
  S.Puerto := 9000;
  S.Bucket := 'b';
  S.ClaveAcceso := 'a';
  S.Secreto := 's';
  Assert.IsFalse(ProbarServidor(nil, S, Msg));
  Assert.IsTrue(Msg <> '');
end;

procedure TPruebasProbarServidor.Probar_S3Incompleto_PideLosDatos;
var
  S: TServidor;
  Msg: string;
begin
  S := Default(TServidor);
  S.Tipo := tsS3;
  S.Direccion := 'minio.local';
  S.Puerto := 9000;
  Assert.IsFalse(ProbarServidor(nil, S, Msg));
  Assert.IsTrue(Msg <> '');
end;

end.
