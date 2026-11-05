unit UPruebasMetadatosSubserie;

{ Metadatos dinamicos de la subserie. Validacion por tipo: sin base de datos.
  Lectura de campos y alta en la tabla md_*: SQL Server (ARCHIGENIO_TEST_DB) y
  Access (ARCHIGENIO_TEST_MDB, COPIA). Las filas se siembran en una transaccion
  que se deshace. }

interface

uses
  FireDAC.Comp.Client, DUnitX.TestFramework, UMetadatosSubserie;

type
  [TestFixture]
  TPruebasValidarMeta = class
  private
    function Campo(Tipo: TTipoMeta; Longitud: Integer; Obligatorio: Boolean): TCampoMeta;
  public
    [Test]
    procedure ObligatorioVacio_DaMensaje;
    [Test]
    procedure OpcionalVacio_EsValido;
    [Test]
    procedure TextoMasLargoQueLongitud_DaMensaje;
    [Test]
    procedure Entero_Casos;
    [Test]
    procedure Real_ConPunto;
    [Test]
    procedure Fecha_Casos;
    [Test]
    procedure Booleano_Casos;
  end;

  [TestFixture]
  TPruebasMetadatosDatos = class
  private
    FConn: TFDConnection;
    FSubserie, FSerie: string;
    procedure Conectar(EsSql: Boolean);
    procedure Sembrar(EsSql: Boolean);
    procedure Verificar;
  public
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SqlServer_Todo;
    [Test]
    procedure Access_Todo;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param,
  Data.DB, UEsquemaCarga, UCargaModelo;

const
  TABLA = 'md_f3_prueba';

{ TPruebasValidarMeta }

function TPruebasValidarMeta.Campo(Tipo: TTipoMeta; Longitud: Integer;
  Obligatorio: Boolean): TCampoMeta;
begin
  Result := Default(TCampoMeta);
  Result.Nombre := 'X';
  Result.Etiqueta := 'Cantidad total';
  Result.Tipo := Tipo;
  Result.Longitud := Longitud;
  Result.Obligatorio := Obligatorio;
end;

procedure TPruebasValidarMeta.ObligatorioVacio_DaMensaje;
begin
  Assert.IsTrue(ValidarValorMeta(Campo(tmTexto, 10, True), '   ').Contains('Cantidad total'));
  Assert.IsTrue(ValidarValorMeta(Campo(tmEntero, 0, True), '') <> '');
end;

procedure TPruebasValidarMeta.OpcionalVacio_EsValido;
begin
  Assert.AreEqual('', ValidarValorMeta(Campo(tmEntero, 0, False), ''));
  Assert.AreEqual('', ValidarValorMeta(Campo(tmFecha, 0, False), '  '));
end;

procedure TPruebasValidarMeta.TextoMasLargoQueLongitud_DaMensaje;
begin
  Assert.IsTrue(ValidarValorMeta(Campo(tmTexto, 10, False), '12345678901') <> '');
  Assert.AreEqual('', ValidarValorMeta(Campo(tmTexto, 10, False), '1234567890'));
  Assert.AreEqual('', ValidarValorMeta(Campo(tmTexto, 0, False), StringOfChar('a', 5000)), 'longitud 0 = sin limite');
  Assert.AreEqual('', ValidarValorMeta(Campo(tmMemo, 10, False), StringOfChar('a', 5000)), 'memo sin limite');
end;

procedure TPruebasValidarMeta.Entero_Casos;
begin
  Assert.AreEqual('', ValidarValorMeta(Campo(tmEntero, 0, False), '12'));
  Assert.AreEqual('', ValidarValorMeta(Campo(tmEntero, 0, False), '-7'));
  Assert.IsTrue(ValidarValorMeta(Campo(tmEntero, 0, False), 'abc') <> '');
  Assert.IsTrue(ValidarValorMeta(Campo(tmEntero, 0, False), '1.5') <> '');
end;

procedure TPruebasValidarMeta.Real_ConPunto;
begin
  Assert.AreEqual('', ValidarValorMeta(Campo(tmReal, 0, False), '1.5'));
  Assert.AreEqual('', ValidarValorMeta(Campo(tmReal, 0, False), '3'));
  Assert.IsTrue(ValidarValorMeta(Campo(tmReal, 0, False), '1,5') <> '');
  Assert.IsTrue(ValidarValorMeta(Campo(tmReal, 0, False), 'x') <> '');
end;

procedure TPruebasValidarMeta.Fecha_Casos;
begin
  Assert.AreEqual('', ValidarValorMeta(Campo(tmFecha, 0, False), '28/02/2026'));
  Assert.IsTrue(ValidarValorMeta(Campo(tmFecha, 0, False), '31/02/2026') <> '');
  Assert.IsTrue(ValidarValorMeta(Campo(tmFecha, 0, False), 'ayer') <> '');
end;

procedure TPruebasValidarMeta.Booleano_Casos;
begin
  Assert.AreEqual('', ValidarValorMeta(Campo(tmBooleano, 0, False), '1'));
  Assert.AreEqual('', ValidarValorMeta(Campo(tmBooleano, 0, False), 'No'));
  Assert.AreEqual('', ValidarValorMeta(Campo(tmBooleano, 0, False), 'true'));
  Assert.IsTrue(ValidarValorMeta(Campo(tmBooleano, 0, False), 'quizas') <> '');
end;

{ TPruebasMetadatosDatos }

procedure TPruebasMetadatosDatos.Conectar(EsSql: Boolean);
begin
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  if EsSql then
  begin
    FConn.DriverName := 'MSSQL';
    FConn.Params.Values['Server'] := 'localhost';
    FConn.Params.Values['Database'] := GetEnvironmentVariable('ARCHIGENIO_TEST_DB');
    FConn.Params.Values['User_Name'] := 'geoconn';
    FConn.Params.Values['Password'] := 'geoconn';
    FConn.Params.Values['OSAuthent'] := 'No';
  end
  else
  begin
    FConn.DriverName := 'MSAcc';
    FConn.Params.Values['Database'] := GetEnvironmentVariable('ARCHIGENIO_TEST_MDB');
  end;
  FConn.Connected := True;
  CrearEsquemaCarga(FConn, EsSql);
  Sembrar(EsSql);
end;

procedure TPruebasMetadatosDatos.Limpiar;
begin
  if FConn <> nil then
  begin
    try
      if FConn.InTransaction then
        FConn.Rollback;
      FConn.ExecSQL('DROP TABLE ' + TABLA);
    except
      // la tabla de prueba puede no existir
    end;
    FreeAndNil(FConn);
  end;
end;

{ Subserie de prueba con 4 variables y su tabla md_*. DDL fuera de transaccion
  (Access); las filas de cl_VarSubserie y el UPDATE de cl_subseries se deshacen. }
procedure TPruebasMetadatosDatos.Sembrar(EsSql: Boolean);
var
  Tipos: string;
begin
  FSubserie := VarToStr(FConn.ExecSQLScalar('SELECT MIN(codsubs) FROM cl_subseries'));
  FSerie := VarToStr(FConn.ExecSQLScalar('SELECT codserie FROM cl_subseries WHERE codsubs = ''' + FSubserie + ''''));
  try
    FConn.ExecSQL('DROP TABLE ' + TABLA);
  except
  end;
  if EsSql then
    Tipos := 'Texto VARCHAR(10), Cantidad INT, FechaRef DATETIME2, Nota VARCHAR(MAX)'
  else
    Tipos := 'Texto VARCHAR(10), Cantidad INT, FechaRef DATETIME, Nota LONGTEXT';
  FConn.ExecSQL('CREATE TABLE ' + TABLA + ' (IdEstructura VARCHAR(50), id INT, codsubs VARCHAR(50), ' +
    'Fecha DATETIME, Version VARCHAR(12), Codigodoc VARCHAR(20), ' + Tipos + ')');
  FConn.StartTransaction;
  FConn.ExecSQL('DELETE FROM cl_VarSubserie WHERE codsubs = :c', [FSubserie]);
  FConn.ExecSQL('INSERT INTO cl_VarSubserie (codserie, codsubs, Orden, NomVariable, Etiqueta, tipo, longitud, obligatorio) ' +
    'VALUES (:a, :b, 2, ''Cantidad'', ''Cantidad total'', 3, 0, 1)', [FSerie, FSubserie]);
  FConn.ExecSQL('INSERT INTO cl_VarSubserie (codserie, codsubs, Orden, NomVariable, Etiqueta, tipo, longitud, obligatorio) ' +
    'VALUES (:a, :b, 1, ''Texto'', ''Texto corto'', 1, 10, 0)', [FSerie, FSubserie]);
  FConn.ExecSQL('INSERT INTO cl_VarSubserie (codserie, codsubs, Orden, NomVariable, Etiqueta, tipo, longitud) ' +
    'VALUES (:a, :b, 4, ''Nota'', ''Nota'', 4, 0)', [FSerie, FSubserie]);
  FConn.ExecSQL('INSERT INTO cl_VarSubserie (codserie, codsubs, Orden, NomVariable, Etiqueta, tipo, longitud, obligatorio) ' +
    'VALUES (:a, :b, 3, ''FechaRef'', ''Fecha de referencia'', 2, 0, 0)', [FSerie, FSubserie]);
  FConn.ExecSQL('UPDATE cl_subseries SET NombreTablaMetadatos = :t WHERE codsubs = :c', [TABLA, FSubserie]);
end;

procedure TPruebasMetadatosDatos.Verificar;
var
  Campos: TArray<TCampoMeta>;
  K: TClaveMeta;
  V: TArray<TValorMeta>;
  Lanzo: Boolean;
  Q: TFDQuery;
begin
  Campos := CargarCamposSubserie(FConn, FSubserie);
  Assert.AreEqual(4, Length(Campos));
  Assert.AreEqual('Texto', Campos[0].Nombre);
  Assert.AreEqual('Texto corto', Campos[0].Etiqueta);
  Assert.IsTrue(Campos[0].Tipo = tmTexto);
  Assert.AreEqual(10, Campos[0].Longitud);
  Assert.IsFalse(Campos[0].Obligatorio);
  Assert.AreEqual('Cantidad', Campos[1].Nombre);
  Assert.IsTrue(Campos[1].Tipo = tmEntero);
  Assert.IsTrue(Campos[1].Obligatorio);
  Assert.IsTrue(Campos[2].Tipo = tmFecha);
  Assert.IsTrue(Campos[3].Tipo = tmMemo);
  Assert.IsFalse(Campos[3].Obligatorio, 'obligatorio nulo = no obligatorio');
  Assert.AreEqual(TABLA, NombreTablaMeta(FConn, FSubserie));

  // subserie sin variables ni tabla
  FConn.ExecSQL('DELETE FROM cl_VarSubserie WHERE codsubs = :c', [FSubserie]);
  FConn.ExecSQL('UPDATE cl_subseries SET NombreTablaMetadatos = NULL WHERE codsubs = :c', [FSubserie]);
  Assert.AreEqual(0, Length(CargarCamposSubserie(FConn, FSubserie)));
  Assert.AreEqual('', NombreTablaMeta(FConn, FSubserie));

  // alta con valores tipados y apostrofe
  K.IdEstructura := 'A.4.3';
  K.Id := 104;
  K.CodSubs := FSubserie;
  K.Fecha := EncodeDate(2026, 1, 31);
  K.Version := '1.0';
  K.Codigodoc := 'F3T-001';
  SetLength(V, 4);
  V[0].Nombre := 'Texto';     V[0].Valor := 'O''Brien';
  V[1].Nombre := 'Cantidad';  V[1].Valor := '42';
  V[2].Nombre := 'FechaRef';  V[2].Valor := '28/02/2026';
  V[3].Nombre := 'Nota';      V[3].Valor := '';
  GuardarMetadatos(FConn, TABLA, K, Campos, V);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.Open('SELECT * FROM ' + TABLA + ' WHERE Codigodoc = ''F3T-001''');
    Assert.AreEqual(1, Q.RecordCount);
    Assert.AreEqual('O''Brien', Q.FieldByName('Texto').AsString);
    Assert.AreEqual(42, Q.FieldByName('Cantidad').AsInteger);
    Assert.AreEqual(EncodeDate(2026, 2, 28), Double(Trunc(Q.FieldByName('FechaRef').AsDateTime)) + 0, 0.5);
    Assert.IsTrue(Q.FieldByName('Nota').IsNull, 'valor vacio = NULL');
  finally
    Q.Free;
  end;

  // columna que no existe en la tabla: no escribe
  SetLength(Campos, 1);
  Campos[0].Nombre := 'NoExiste';
  Campos[0].Tipo := tmTexto;
  SetLength(V, 1);
  V[0].Nombre := 'NoExiste';
  V[0].Valor := 'x';
  K.Codigodoc := 'F3T-002';
  Lanzo := False;
  try
    GuardarMetadatos(FConn, TABLA, K, Campos, V);
  except
    on EMetadatos do Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'columna inexistente debe lanzar EMetadatos');
  Assert.AreEqual(0, Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM ' + TABLA + ' WHERE Codigodoc = ''F3T-002''')));

  // nombre de tabla invalido
  Lanzo := False;
  try
    GuardarMetadatos(FConn, 'md_x; DROP TABLE tb_user', K, Campos, V);
  except
    on EMetadatos do Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'tabla invalida debe lanzar EMetadatos');
end;

procedure TPruebasMetadatosDatos.SqlServer_Todo;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  Verificar;
end;

procedure TPruebasMetadatosDatos.Access_Todo;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  Verificar;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasValidarMeta);
  TDUnitX.RegisterTestFixture(TPruebasMetadatosDatos);

end.
