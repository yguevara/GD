unit UPruebasAutenticacion;

{ Pruebas de UAutenticacion. La parte pura no necesita base de datos; la de
  credenciales usa SGDTEST_ALCANCE (variable ARCHIGENIO_TEST_DB) y deja la base
  como la encontro: borra todo usuario cuyo nombre empiece por zz_auth. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UAutenticacion;

type
  [TestFixture]
  TPruebasAutenticacionPura = class
  public
    [Test]
    procedure Md5_Conocido;
    [Test]
    procedure Normalizar_QuitaEspaciosYMayusculas;
    [Test]
    procedure Campos_UsuarioVacio_Falla;
    [Test]
    procedure Campos_ClaveVacia_Falla;
    [Test]
    procedure Campos_ClaveDeTresCaracteres_Acepta;
    [Test]
    procedure ClaveNueva_CortaFalla;
    [Test]
    procedure ClaveNueva_NoCoincideFalla;
    [Test]
    procedure ClaveNueva_SeisCoincideAcepta;
  end;

  [TestFixture]
  TPruebasUltimoUsuario = class
  private
    FRuta: string;
    procedure Escribir(const ATexto: string);
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure UltimoUsuario_NoExiste;
    [Test]
    procedure UltimoUsuario_ArchivoVacio;
    [Test]
    procedure UltimoUsuario_SoloEspacios;
    [Test]
    procedure UltimoUsuario_VariasLineas;
    [Test]
    procedure Guardar_Y_Leer;
    [Test]
    procedure Guardar_RutaInvalida_NoLanza;
  end;

  [TestFixture]
  TPruebasVerificarCredenciales = class
  private
    FConn: TFDConnection;
    procedure Restaurar;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Verificar_CorrectoDevuelveRol;
    [Test]
    procedure Verificar_UsuarioConMayusculasAcepta;
    [Test]
    procedure Verificar_ClaveIncorrecta;
    [Test]
    procedure Verificar_UsuarioInexistente;
    [Test]
    procedure Verificar_Deshabilitado;
    [Test]
    procedure Verificar_ComillaEnUsuario_NoRompe;
    [Test]
    procedure Verificar_ConexionInvalida;
    [Test]
    procedure Verificar_UsuarioNuevoSinRefrescar;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';

{ TPruebasAutenticacionPura }

procedure TPruebasAutenticacionPura.Md5_Conocido;
begin
  Assert.AreEqual('900150983cd24fb0d6963f7d28e17f72', CalcularMd5('abc'));
end;

procedure TPruebasAutenticacionPura.Normalizar_QuitaEspaciosYMayusculas;
begin
  Assert.AreEqual('admin', NormalizarUsuario('  Admin '));
end;

procedure TPruebasAutenticacionPura.Campos_UsuarioVacio_Falla;
var
  Msg: string;
begin
  Assert.IsFalse(ValidarCampos('   ', 'abcd', Msg));
  Assert.IsTrue(Msg <> '');
end;

procedure TPruebasAutenticacionPura.Campos_ClaveVacia_Falla;
var
  Msg: string;
begin
  Assert.IsFalse(ValidarCampos('admin', '', Msg));
  Assert.IsTrue(Msg <> '');
end;

procedure TPruebasAutenticacionPura.Campos_ClaveDeTresCaracteres_Acepta;
var
  Msg: string;
begin
  Assert.IsTrue(ValidarCampos('admin', 'abc', Msg));
  Assert.AreEqual('', Msg);
end;

procedure TPruebasAutenticacionPura.ClaveNueva_CortaFalla;
var
  Msg: string;
begin
  Assert.IsFalse(ValidarClaveNueva('12345', '12345', Msg));
  Assert.IsTrue(Msg <> '');
end;

procedure TPruebasAutenticacionPura.ClaveNueva_NoCoincideFalla;
var
  Msg: string;
begin
  Assert.IsFalse(ValidarClaveNueva('123456', '123457', Msg));
  Assert.IsTrue(Msg <> '');
end;

procedure TPruebasAutenticacionPura.ClaveNueva_SeisCoincideAcepta;
var
  Msg: string;
begin
  Assert.IsTrue(ValidarClaveNueva('123456', '123456', Msg));
  Assert.AreEqual('', Msg);
end;

{ TPruebasUltimoUsuario }

procedure TPruebasUltimoUsuario.Preparar;
begin
  FRuta := TPath.Combine(TPath.GetTempPath, 'pr_ultimo_usuario.ini');
  if FileExists(FRuta) then
    DeleteFile(FRuta);
end;

procedure TPruebasUltimoUsuario.Limpiar;
begin
  if FileExists(FRuta) then
    DeleteFile(FRuta);
end;

procedure TPruebasUltimoUsuario.Escribir(const ATexto: string);
var
  L: TStringList;
begin
  L := TStringList.Create;
  try
    L.Text := ATexto;
    L.SaveToFile(FRuta);
  finally
    L.Free;
  end;
end;

procedure TPruebasUltimoUsuario.UltimoUsuario_NoExiste;
begin
  Assert.AreEqual('', LeerUltimoUsuario(FRuta));
end;

procedure TPruebasUltimoUsuario.UltimoUsuario_ArchivoVacio;
begin
  Escribir('');
  Assert.AreEqual('', LeerUltimoUsuario(FRuta));
end;

procedure TPruebasUltimoUsuario.UltimoUsuario_SoloEspacios;
begin
  Escribir('    ');
  Assert.AreEqual('', LeerUltimoUsuario(FRuta));
end;

procedure TPruebasUltimoUsuario.UltimoUsuario_VariasLineas;
begin
  Escribir('  ana  ' + sLineBreak + 'bob');
  Assert.AreEqual('ana', LeerUltimoUsuario(FRuta));
end;

procedure TPruebasUltimoUsuario.Guardar_Y_Leer;
begin
  GuardarUltimoUsuario(FRuta, 'carla');
  Assert.AreEqual('carla', LeerUltimoUsuario(FRuta));
end;

procedure TPruebasUltimoUsuario.Guardar_RutaInvalida_NoLanza;
begin
  GuardarUltimoUsuario('Z:\no_existe_nunca\sub\x.ini', 'carla');
  Assert.Pass;
end;

{ TPruebasVerificarCredenciales }

procedure TPruebasVerificarCredenciales.Preparar;
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
  Restaurar;
  FConn.ExecSQL('INSERT INTO cl_Resp_Gest_Arch (Idresp, NombreResponsable, usuario, Rol, password, habilitado) ' +
    'VALUES (9101, ''Prueba'', ''zz_auth_ok'', 2, ''' + CalcularMd5('clave123') + ''', ''S'')');
  FConn.ExecSQL('INSERT INTO cl_Resp_Gest_Arch (Idresp, NombreResponsable, usuario, Rol, password, habilitado) ' +
    'VALUES (9102, ''Prueba'', ''zz_auth_off'', 2, ''' + CalcularMd5('clave123') + ''', ''N'')');
end;

procedure TPruebasVerificarCredenciales.Restaurar;
begin
  FConn.ExecSQL('DELETE FROM cl_Resp_Gest_Arch WHERE usuario LIKE ''zz_auth%''');
end;

procedure TPruebasVerificarCredenciales.Limpiar;
begin
  if FConn <> nil then
  begin
    Restaurar;
    FreeAndNil(FConn);
  end;
end;

procedure TPruebasVerificarCredenciales.Verificar_CorrectoDevuelveRol;
var
  R: TResultadoAutenticacion;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := VerificarCredenciales(FConn, 'zz_auth_ok', 'clave123');
  Assert.AreEqual(Ord(eaAceptado), Ord(R.Estado), R.Detalle);
  Assert.AreEqual('Gestor', R.Rol);
  Assert.AreEqual('zz_auth_ok', R.Usuario);
end;

procedure TPruebasVerificarCredenciales.Verificar_UsuarioConMayusculasAcepta;
var
  R: TResultadoAutenticacion;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := VerificarCredenciales(FConn, '  ZZ_Auth_OK ', 'clave123');
  Assert.AreEqual(Ord(eaAceptado), Ord(R.Estado), R.Detalle);
  Assert.AreEqual('zz_auth_ok', R.Usuario);
end;

procedure TPruebasVerificarCredenciales.Verificar_ClaveIncorrecta;
var
  R: TResultadoAutenticacion;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := VerificarCredenciales(FConn, 'zz_auth_ok', 'otra');
  Assert.AreEqual(Ord(eaCredencialesInvalidas), Ord(R.Estado));
  Assert.AreEqual('', R.Rol);
end;

procedure TPruebasVerificarCredenciales.Verificar_UsuarioInexistente;
var
  R: TResultadoAutenticacion;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := VerificarCredenciales(FConn, 'zz_auth_nadie', 'clave123');
  Assert.AreEqual(Ord(eaCredencialesInvalidas), Ord(R.Estado));
end;

procedure TPruebasVerificarCredenciales.Verificar_Deshabilitado;
var
  R: TResultadoAutenticacion;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := VerificarCredenciales(FConn, 'zz_auth_off', 'clave123');
  Assert.AreEqual(Ord(eaDeshabilitado), Ord(R.Estado));
  Assert.AreEqual('', R.Rol);
end;

procedure TPruebasVerificarCredenciales.Verificar_ComillaEnUsuario_NoRompe;
var
  R: TResultadoAutenticacion;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := VerificarCredenciales(FConn, 'o''brien', 'clave123');
  Assert.AreEqual(Ord(eaCredencialesInvalidas), Ord(R.Estado), R.Detalle);
end;

procedure TPruebasVerificarCredenciales.Verificar_ConexionInvalida;
var
  C: TFDConnection;
  R: TResultadoAutenticacion;
begin
  C := TFDConnection.Create(nil);
  try
    C.LoginPrompt := False;
    C.DriverName := 'MSSQL';
    C.Params.Values['Server'] := 'localhost';
    C.Params.Values['Database'] := 'bd_que_no_existe_auth';
    C.Params.Values['User_Name'] := 'geoconn';
    C.Params.Values['Password'] := 'geoconn';
    C.Params.Values['OSAuthent'] := 'No';
    R := VerificarCredenciales(C, 'admin', 'clave123');
    Assert.AreEqual(Ord(eaErrorBD), Ord(R.Estado));
    Assert.IsTrue(R.Detalle <> '');
    Assert.AreEqual('', R.Rol);
  finally
    C.Free;
  end;
end;

procedure TPruebasVerificarCredenciales.Verificar_UsuarioNuevoSinRefrescar;
var
  R: TResultadoAutenticacion;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  FConn.ExecSQL('INSERT INTO cl_Resp_Gest_Arch (Idresp, NombreResponsable, usuario, Rol, password, habilitado) ' +
    'VALUES (9103, ''Prueba'', ''zz_auth_nuevo'', 4, ''' + CalcularMd5('secreta1') + ''', ''S'')');
  R := VerificarCredenciales(FConn, 'zz_auth_nuevo', 'secreta1');
  Assert.AreEqual(Ord(eaAceptado), Ord(R.Estado), R.Detalle);
  Assert.AreEqual('Visor', R.Rol);
end;

end.
