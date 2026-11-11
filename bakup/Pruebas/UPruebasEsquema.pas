unit UPruebasEsquema;

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasEsquema = class
  private
    FConn: TFDConnection;
    FNombreBD: string;
    function Escalar(const Sql: string): Variant;
    function TablaExiste(const Nombre: string): Boolean;
    function ContarFilasTablas: Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure TablasExisten;
    [Test]
    procedure NodoNoAdmiteDosEGD;
    [Test]
    procedure EsIdempotente;
  end;

  { Rama Access de CrearEsquemaAlcance. Usa la COPIA de una base .mdb cuya ruta
    viene en ARCHIGENIO_TEST_MDB (se omite sin ella). Modifica esa copia. }
  [TestFixture]
  TPruebasEsquemaAccess = class
  private
    FConn: TFDConnection;
    function TablaExiste(const Nombre: string): Boolean;
    function ColumnaExiste(const Tabla, Columna: string): Boolean;
    function ContarFilasTablas: Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Access_CreaTablasYEsIdempotente;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param,
  Data.DB, UEsquemaAlcance;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  VAR_MDB = 'ARCHIGENIO_TEST_MDB';
  TABLAS_NUEVAS: array[0..4] of string = ('tb_nodo_egd', 'tb_usuario_subserie',
    'tb_lote_captura', 'tb_lote_captura_item', 'tb_regla_carpeta');

procedure TPruebasEsquema.Preparar;
begin
  FConn := nil;
  FNombreBD := GetEnvironmentVariable(VAR_BD);
  if FNombreBD = '' then
    Exit;
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := FNombreBD;
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
end;

procedure TPruebasEsquema.Limpiar;
begin
  FreeAndNil(FConn);
end;

function TPruebasEsquema.Escalar(const Sql: string): Variant;
begin
  Result := FConn.ExecSQLScalar(Sql);
end;

function TPruebasEsquema.TablaExiste(const Nombre: string): Boolean;
begin
  Result := Integer(Escalar('SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES ' +
    'WHERE TABLE_NAME = ' + QuotedStr(Nombre))) > 0;
end;

function TPruebasEsquema.ContarFilasTablas: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(TABLAS_NUEVAS) to High(TABLAS_NUEVAS) do
    Result := Result + Integer(Escalar('SELECT COUNT(*) FROM ' + TABLAS_NUEVAS[I]));
end;

procedure TPruebasEsquema.TablasExisten;
var
  I: Integer;
begin
  if FConn = nil then
  begin
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
    Exit;
  end;
  CrearEsquemaAlcance(FConn, True);
  for I := Low(TABLAS_NUEVAS) to High(TABLAS_NUEVAS) do
    Assert.IsTrue(TablaExiste(TABLAS_NUEVAS[I]), 'Falta la tabla ' + TABLAS_NUEVAS[I]);
  Assert.AreEqual(1, Integer(Escalar('SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS ' +
    'WHERE TABLE_NAME = ''cl_Resp_Gest_Arch'' AND COLUMN_NAME = ''usuario_ad''')),
    'Falta la columna usuario_ad');
end;

procedure TPruebasEsquema.NodoNoAdmiteDosEGD;
var
  IdEstr, Usuario1, Usuario2: string;
  IdNodo: Integer;
  Lanzo: Boolean;
begin
  if FConn = nil then
  begin
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
    Exit;
  end;
  CrearEsquemaAlcance(FConn, True);
  IdEstr := VarToStr(Escalar('SELECT TOP 1 IdEstructura FROM tb_tree ORDER BY IdEstructura, id'));
  IdNodo := Integer(Escalar('SELECT TOP 1 id FROM tb_tree ORDER BY IdEstructura, id'));
  Usuario1 := VarToStr(Escalar('SELECT TOP 1 nombreuser FROM tb_user ORDER BY nombreuser'));
  Usuario2 := VarToStr(Escalar('SELECT TOP 1 nombreuser FROM tb_user ORDER BY nombreuser DESC'));
  Assert.IsTrue((IdEstr <> '') and (Usuario1 <> ''), 'La base de pruebas no tiene nodos o usuarios');
  FConn.ExecSQL('DELETE FROM tb_nodo_egd WHERE IdEstructura = :a AND id = :b', [IdEstr, IdNodo]);
  try
    FConn.ExecSQL('INSERT INTO tb_nodo_egd (IdEstructura, id, user_id) VALUES (:a, :b, :c)',
      [IdEstr, IdNodo, Usuario1]);
    Lanzo := False;
    try
      FConn.ExecSQL('INSERT INTO tb_nodo_egd (IdEstructura, id, user_id) VALUES (:a, :b, :c)',
        [IdEstr, IdNodo, Usuario2]);
    except
      on E: EFDDBEngineException do
        Lanzo := True;
    end;
    Assert.IsTrue(Lanzo, 'Se permitio un segundo EGD en el mismo nodo');
  finally
    FConn.ExecSQL('DELETE FROM tb_nodo_egd WHERE IdEstructura = :a AND id = :b', [IdEstr, IdNodo]);
  end;
end;

procedure TPruebasEsquema.EsIdempotente;
var
  Antes, Despues: Integer;
begin
  if FConn = nil then
  begin
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
    Exit;
  end;
  CrearEsquemaAlcance(FConn, True);
  Antes := ContarFilasTablas;
  CrearEsquemaAlcance(FConn, True);
  CrearEsquemaAlcance(FConn, True);
  Despues := ContarFilasTablas;
  Assert.AreEqual(Antes, Despues, 'Cambio el numero de filas');
  Assert.IsTrue(TablaExiste('tb_nodo_egd'));
end;

{ TPruebasEsquemaAccess }

procedure TPruebasEsquemaAccess.Preparar;
var
  Ruta: string;
begin
  FConn := nil;
  Ruta := GetEnvironmentVariable(VAR_MDB);
  if Ruta = '' then
    Exit;
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSAcc';
  FConn.Params.Values['Database'] := Ruta;
  FConn.Connected := True;
end;

procedure TPruebasEsquemaAccess.Limpiar;
begin
  FreeAndNil(FConn);
end;

function TPruebasEsquemaAccess.TablaExiste(const Nombre: string): Boolean;
begin
  try
    FConn.ExecSQLScalar('SELECT COUNT(*) FROM ' + Nombre);
    Result := True;
  except
    Result := False;
  end;
end;

function TPruebasEsquemaAccess.ColumnaExiste(const Tabla, Columna: string): Boolean;
begin
  try
    FConn.ExecSQLScalar('SELECT COUNT(' + Columna + ') FROM ' + Tabla);
    Result := True;
  except
    Result := False;
  end;
end;

function TPruebasEsquemaAccess.ContarFilasTablas: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(TABLAS_NUEVAS) to High(TABLAS_NUEVAS) do
    Result := Result + Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM ' + TABLAS_NUEVAS[I]));
end;

procedure TPruebasEsquemaAccess.Access_CreaTablasYEsIdempotente;
var
  I, Antes: Integer;
begin
  if FConn = nil then
  begin
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
    Exit;
  end;
  CrearEsquemaAlcance(FConn, False);
  for I := Low(TABLAS_NUEVAS) to High(TABLAS_NUEVAS) do
    Assert.IsTrue(TablaExiste(TABLAS_NUEVAS[I]), 'Access: falta la tabla ' + TABLAS_NUEVAS[I]);
  Assert.IsTrue(ColumnaExiste('cl_Resp_Gest_Arch', 'usuario_ad'), 'Access: falta usuario_ad');
  Antes := ContarFilasTablas;
  CrearEsquemaAlcance(FConn, False);
  Assert.AreEqual(Antes, ContarFilasTablas, 'Access: cambio el numero de filas');
  for I := Low(TABLAS_NUEVAS) to High(TABLAS_NUEVAS) do
    Assert.IsTrue(TablaExiste(TABLAS_NUEVAS[I]), 'Access: falta la tabla ' + TABLAS_NUEVAS[I]);
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasEsquema);
  TDUnitX.RegisterTestFixture(TPruebasEsquemaAccess);

end.
