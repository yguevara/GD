unit UPruebasAsignacion;

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UAlcance;

type
  { Reglas puras de propagacion (sin base de datos). }
  [TestFixture]
  TPruebasAsignacionPura = class
  private
    FArbol: TArbolNodos;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure NodosAfectados_SinHijos;
    [Test]
    procedure NodosAfectados_ConHijos_SinDuplicados;
    [Test]
    procedure NodosAfectados_IgnoraNodoInexistente;
    [Test]
    procedure CalcularCambios_UnoPorNodoAfectado;
    [Test]
    procedure CalcularCambios_RolInvalido_Falla;
    [Test]
    procedure NodosSinEGDPropio_ListaLosQueNoTienen;
    [Test]
    procedure NodosSinEGDPropio_HeredadoNoCuenta;
  end;

  { Escritura contra SGDTEST_ALCANCE (ARCHIGENIO_TEST_DB). Deja la base como la
    encontro: egd_a43 en A.4.3/104 y sin directores. }
  [TestFixture]
  TPruebasAsignacionDatos = class
  private
    FConn: TFDConnection;
    function Contar(const Sql: string): Integer;
    procedure Restaurar;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Agregar_EGD_CreaUsuarioSiFalta;
    [Test]
    procedure Agregar_Director_UsaIdrespEIdrol3;
    [Test]
    procedure Agregar_Repetido_EsIdempotente;
    [Test]
    procedure ErrorAMedias_NoDejaNada;
    [Test]
    procedure Quitar_UnEGD_NoQuitaAlOtro;
    [Test]
    procedure CargarAsignaciones_DevuelveLogin;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt,
  FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UEsquemaAlcance,
  UAsignacionDatos;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';

function Clave(const AIdEstructura: string; AId: Integer): TClaveNodo;
begin
  Result.IdEstructura := AIdEstructura;
  Result.Id := AId;
end;

function Asig(const N: TClaveNodo; R: TRolNodo; const U: string): TAsignacion;
begin
  Result.Nodo := N;
  Result.Rol := R;
  Result.Usuario := U;
end;

{ TPruebasAsignacionPura }

procedure TPruebasAsignacionPura.Preparar;
begin
  FArbol := TArbolNodos.Create;
  FArbol.Agregar(Clave('A', 1), 0);
  FArbol.Agregar(Clave('A.1', 82), 1);
  FArbol.Agregar(Clave('A.4', 101), 1);
  FArbol.Agregar(Clave('A.4.3', 104), 101);
  FArbol.Agregar(Clave('A.4.6', 160), 101);
end;

procedure TPruebasAsignacionPura.Limpiar;
begin
  FArbol.Free;
end;

procedure TPruebasAsignacionPura.NodosAfectados_SinHijos;
begin
  Assert.AreEqual(1, Integer(Length(NodosAfectados(FArbol, [Clave('A.4', 101)], False))));
end;

procedure TPruebasAsignacionPura.NodosAfectados_ConHijos_SinDuplicados;
var
  R: TArray<TClaveNodo>;
begin
  // A.4 con hijos son 3 nodos; marcar tambien A.4.3 no lo repite
  R := NodosAfectados(FArbol, [Clave('A.4', 101), Clave('A.4.3', 104)], True);
  Assert.AreEqual(3, Integer(Length(R)));
end;

procedure TPruebasAsignacionPura.NodosAfectados_IgnoraNodoInexistente;
begin
  Assert.AreEqual(0, Integer(Length(NodosAfectados(FArbol, [Clave('Z.9', 999)], True))));
end;

procedure TPruebasAsignacionPura.CalcularCambios_UnoPorNodoAfectado;
var
  C: TArray<TCambioAsignacion>;
begin
  C := CalcularCambios(FArbol, [Clave('A.4', 101)], True, rnEGD, 'egd_x', False);
  Assert.AreEqual(3, Integer(Length(C)));
  Assert.IsFalse(C[0].Agregar);
  Assert.AreEqual('egd_x', C[0].Asignacion.Usuario);
  Assert.IsTrue(C[0].Asignacion.Rol = rnEGD);
end;

procedure TPruebasAsignacionPura.CalcularCambios_RolInvalido_Falla;
begin
  Assert.WillRaise(
    procedure
    begin
      CalcularCambios(FArbol, [Clave('A.4', 101)], False, rnVisor, 'x', True);
    end, Exception);
end;

procedure TPruebasAsignacionPura.NodosSinEGDPropio_ListaLosQueNoTienen;
var
  R: TArray<TClaveNodo>;
begin
  R := NodosSinEGDPropio(FArbol, [Asig(Clave('A.4.3', 104), rnEGD, 'a'),
    Asig(Clave('A.1', 82), rnDirector, 'b')]);
  // 5 nodos; solo A.4.3 tiene EGD propio (un Director no cuenta)
  Assert.AreEqual(4, Integer(Length(R)));
end;

procedure TPruebasAsignacionPura.NodosSinEGDPropio_HeredadoNoCuenta;
var
  R: TArray<TClaveNodo>;
  N: TClaveNodo;
  Hallado: Boolean;
begin
  R := NodosSinEGDPropio(FArbol, [Asig(Clave('A.4', 101), rnEGD, 'a')]);
  Hallado := False;
  for N in R do
    if N.Id = 104 then
      Hallado := True;
  Assert.IsTrue(Hallado, 'A.4.3 hereda el EGD de A.4 pero sigue sin EGD propio');
end;

{ TPruebasAsignacionDatos }

procedure TPruebasAsignacionDatos.Preparar;
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
  CrearEsquemaAlcance(FConn, True);
  Restaurar;
end;

procedure TPruebasAsignacionDatos.Restaurar;
begin
  FConn.ExecSQL('DELETE FROM tb_tree_directors');
  FConn.ExecSQL('DELETE FROM tb_nodo_egd WHERE user_id <> ''egd_a43'' ' +
    'OR NOT (IdEstructura = ''A.4.3'' AND id = 104)');
  if Contar('SELECT COUNT(*) FROM tb_nodo_egd WHERE user_id = ''egd_a43'' ' +
    'AND IdEstructura = ''A.4.3'' AND id = 104') = 0 then
    FConn.ExecSQL('INSERT INTO tb_nodo_egd (IdEstructura, id, user_id) ' +
      'VALUES (''A.4.3'', 104, ''egd_a43'')');
  FConn.ExecSQL('DELETE FROM tb_user WHERE nombreuser NOT IN (''administrador'', ''egd_a43'')');
end;

procedure TPruebasAsignacionDatos.Limpiar;
begin
  if FConn <> nil then
  begin
    if FConn.InTransaction then
      FConn.Rollback;
    Restaurar;
  end;
  FreeAndNil(FConn);
end;

function TPruebasAsignacionDatos.Contar(const Sql: string): Integer;
begin
  Result := Integer(FConn.ExecSQLScalar(Sql));
end;

procedure TPruebasAsignacionDatos.Agregar_EGD_CreaUsuarioSiFalta;
var
  Arbol: TArbolNodos;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Arbol := TArbolNodos.Create;
  try
    Arbol.Agregar(Clave('A.4', 101), 1);
    Assert.AreEqual(0, Contar('SELECT COUNT(*) FROM tb_user WHERE nombreuser = ''usr_sub'''));
    AplicarCambios(FConn, CalcularCambios(Arbol, [Clave('A.4', 101)], False, rnEGD,
      'USR_SUB', True));
    Assert.AreEqual(1, Contar('SELECT COUNT(*) FROM tb_user WHERE UPPER(nombreuser) = ''USR_SUB'''));
    Assert.AreEqual(1, Contar('SELECT COUNT(*) FROM tb_nodo_egd WHERE IdEstructura = ''A.4'' ' +
      'AND id = 101'));
    // otra capitalizacion no duplica al usuario
    AplicarCambios(FConn, CalcularCambios(Arbol, [Clave('A.4', 101)], False, rnEGD,
      'usr_sub', True));
    Assert.AreEqual(1, Contar('SELECT COUNT(*) FROM tb_user WHERE UPPER(nombreuser) = ''USR_SUB'''));
    Assert.AreEqual(1, Contar('SELECT COUNT(*) FROM tb_nodo_egd WHERE IdEstructura = ''A.4'' ' +
      'AND id = 101'));
  finally
    Arbol.Free;
  end;
end;

procedure TPruebasAsignacionDatos.Agregar_Director_UsaIdrespEIdrol3;
var
  Arbol: TArbolNodos;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Arbol := TArbolNodos.Create;
  try
    Arbol.Agregar(Clave('A.4', 101), 1);
    AplicarCambios(FConn, CalcularCambios(Arbol, [Clave('A.4', 101)], False, rnDirector,
      'usr_sub', True));
    Assert.AreEqual(1, Contar('SELECT COUNT(*) FROM tb_tree_directors WHERE ' +
      'IdEstructura = ''A.4'' AND id = 101 AND user_id = 2 AND idrol = 3'));
    AplicarCambios(FConn, CalcularCambios(Arbol, [Clave('A.4', 101)], False, rnDirector,
      'usr_sub', False));
    Assert.AreEqual(0, Contar('SELECT COUNT(*) FROM tb_tree_directors'));
  finally
    Arbol.Free;
  end;
end;

procedure TPruebasAsignacionDatos.Agregar_Repetido_EsIdempotente;
var
  Arbol: TArbolNodos;
  C: TArray<TCambioAsignacion>;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Arbol := TArbolNodos.Create;
  try
    Arbol.Agregar(Clave('A.4', 101), 1);
    C := CalcularCambios(Arbol, [Clave('A.4', 101)], False, rnDirector, 'usr_sub', True);
    AplicarCambios(FConn, C);
    AplicarCambios(FConn, C);
    Assert.AreEqual(1, Contar('SELECT COUNT(*) FROM tb_tree_directors'));
  finally
    Arbol.Free;
  end;
end;

procedure TPruebasAsignacionDatos.ErrorAMedias_NoDejaNada;
var
  Cambios: TArray<TCambioAsignacion>;
  Lanzo: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  SetLength(Cambios, 2);
  Cambios[0].Agregar := True;
  Cambios[0].Asignacion := Asig(Clave('A.4', 101), rnDirector, 'usr_sub');
  Cambios[1].Agregar := True;
  Cambios[1].Asignacion := Asig(Clave('Z.9', 999), rnDirector, 'usr_sub'); // no existe
  Lanzo := False;
  try
    AplicarCambios(FConn, Cambios);
  except
    on E: Exception do
      Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'Debia fallar por el nodo inexistente');
  Assert.AreEqual(0, Contar('SELECT COUNT(*) FROM tb_tree_directors'),
    'La primera fila no debio quedar guardada');
  Assert.IsFalse(FConn.InTransaction);
end;

procedure TPruebasAsignacionDatos.Quitar_UnEGD_NoQuitaAlOtro;
var
  Arbol: TArbolNodos;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Arbol := TArbolNodos.Create;
  try
    Arbol.Agregar(Clave('A.4.3', 104), 101);
    AplicarCambios(FConn, CalcularCambios(Arbol, [Clave('A.4.3', 104)], False, rnEGD,
      'usr_sub', True));
    Assert.AreEqual(2, Contar('SELECT COUNT(*) FROM tb_nodo_egd WHERE id = 104'));
    AplicarCambios(FConn, CalcularCambios(Arbol, [Clave('A.4.3', 104)], False, rnEGD,
      'usr_sub', False));
    Assert.AreEqual(1, Contar('SELECT COUNT(*) FROM tb_nodo_egd WHERE id = 104 ' +
      'AND user_id = ''egd_a43'''));
  finally
    Arbol.Free;
  end;
end;

procedure TPruebasAsignacionDatos.CargarAsignaciones_DevuelveLogin;
var
  Arbol: TArbolNodos;
  R: TArray<TAsignacion>;
  A: TAsignacion;
  HallaEGD, HallaDir: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Arbol := TArbolNodos.Create;
  try
    Arbol.Agregar(Clave('A.4', 101), 1);
    AplicarCambios(FConn, CalcularCambios(Arbol, [Clave('A.4', 101)], False, rnDirector,
      'usr_sub', True));
    R := CargarAsignaciones(FConn);
    HallaEGD := False;
    HallaDir := False;
    for A in R do
    begin
      if (A.Rol = rnEGD) and (A.Usuario = 'egd_a43') and (A.Nodo.Id = 104) then
        HallaEGD := True;
      if (A.Rol = rnDirector) and (A.Usuario = 'usr_sub') and (A.Nodo.Id = 101) then
        HallaDir := True;
    end;
    Assert.IsTrue(HallaEGD and HallaDir);
  finally
    Arbol.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasAsignacionPura);
  TDUnitX.RegisterTestFixture(TPruebasAsignacionDatos);

end.
