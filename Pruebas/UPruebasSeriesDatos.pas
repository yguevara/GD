unit UPruebasSeriesDatos;

{ Series y subseries (USeriesDatos). Validacion: sin base de datos. Resto: SQL
  Server (ARCHIGENIO_TEST_DB = SGDTEST_ALCANCE); cada prueba siembra la serie ZZ9
  (subseries ZZ9A y ZZ9B) y lo borra al terminar. La subserie real 074, con
  documentos, solo se usa para comprobar que NO se puede eliminar. Codigo en
  ASCII. }

interface

uses
  FireDAC.Comp.Client, DUnitX.TestFramework, USeriesDatos;

type
  [TestFixture]
  TPruebasSeriesValidar = class
  public
    [Test]
    procedure Serie_CodigoYNombreObligatorios;
    [Test]
    procedure Subserie_CodigoVacio;
    [Test]
    procedure Subserie_NombreLargo;
    [Test]
    procedure Subserie_AnosNegativos;
    [Test]
    procedure Subserie_Correcta_SinErrores;
  end;

  [TestFixture]
  TPruebasSeriesBD = class
  private
    FConn: TFDConnection;
    function Sub(const ACod, ANombre: string): TSubserie;
    function Cuenta(const ASql: string): Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure ListarSeries_CuentaSubseries;
    [Test]
    procedure ListarSubseries_MarcaLasQueTienenTabla;
    [Test]
    procedure Guardar_Nueva_YLeer;
    [Test]
    procedure Guardar_Nueva_CodigoDuplicado_Lanza;
    [Test]
    procedure Guardar_Edicion_NoTocaOtrasColumnas;
    [Test]
    procedure Guardar_Serie_NuevaYEdicion;
    [Test]
    procedure Observacion_ConservaElTextoTalCual;
    [Test]
    procedure Eliminar_ConDocumentos_Bloquea;
    [Test]
    procedure Eliminar_Serie_ConSubseries_Bloquea;
    [Test]
    procedure Eliminar_Libre_BorraVariablesYTablaVacia;
    [Test]
    procedure ListarOpciones_TodosLosCatalogosResponden;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt,
  FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UErroresCampo,
  UMetadatosSubserie, UVariablesDatos;

const
  SERIE = 'ZZ9';
  TABLA = 'md_ZZ9ZZ9A';

function SubOk: TSubserie;
begin
  Result := Default(TSubserie);
  Result.CodSerie := 'ZZ9';
  Result.CodSubs := 'ZZ9A';
  Result.Nombre := 'Prueba';
end;

{ TPruebasSeriesValidar }

procedure TPruebasSeriesValidar.Serie_CodigoYNombreObligatorios;
var
  S: TSerie;
  E: TArray<TErrorCampo>;
begin
  S := Default(TSerie);
  E := ValidarSerie(S);
  Assert.AreEqual(2, Length(E));
  S.CodSerie := '01';
  S.Serie := 'Algo';
  Assert.AreEqual(0, Length(ValidarSerie(S)));
end;

procedure TPruebasSeriesValidar.Subserie_CodigoVacio;
var
  S: TSubserie;
  E: TArray<TErrorCampo>;
begin
  S := SubOk;
  S.CodSubs := '  ';
  E := ValidarSubserie(S);
  Assert.AreEqual(1, Length(E));
  Assert.AreEqual('codsubs', E[0].Campo);
end;

procedure TPruebasSeriesValidar.Subserie_NombreLargo;
var
  S: TSubserie;
begin
  S := SubOk;
  S.Nombre := StringOfChar('x', 256);
  Assert.AreEqual('subserie', ValidarSubserie(S)[0].Campo);
end;

procedure TPruebasSeriesValidar.Subserie_AnosNegativos;
var
  S: TSubserie;
begin
  S := SubOk;
  S.Gestion := -1;
  Assert.AreEqual('tgestion', ValidarSubserie(S)[0].Campo);
end;

procedure TPruebasSeriesValidar.Subserie_Correcta_SinErrores;
begin
  Assert.AreEqual(0, Length(ValidarSubserie(SubOk)));
end;

{ TPruebasSeriesBD }

function TPruebasSeriesBD.Sub(const ACod, ANombre: string): TSubserie;
begin
  Result := SubOk;
  Result.CodSubs := ACod;
  Result.Nombre := ANombre;
end;

function TPruebasSeriesBD.Cuenta(const ASql: string): Integer;
begin
  Result := Integer(FConn.ExecSQLScalar(ASql));
end;

procedure TPruebasSeriesBD.Preparar;
begin
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := GetEnvironmentVariable('ARCHIGENIO_TEST_DB');
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
  Limpiar;
  FConn.Connected := True;
  FConn.ExecSQL('INSERT INTO cl_series (codserie, serie) VALUES (''ZZ9'', ''Serie de prueba'')');
end;

procedure TPruebasSeriesBD.Limpiar;
begin
  if FConn = nil then
    Exit;
  try
    if FConn.InTransaction then
      FConn.Rollback;
    try
      FConn.ExecSQL('DROP TABLE ' + TABLA);
    except
      // puede no existir
    end;
    FConn.ExecSQL('DELETE FROM cl_VarSubserie WHERE codserie = ''' + SERIE + '''');
    FConn.ExecSQL('DELETE FROM cl_subseries WHERE codserie = ''' + SERIE + '''');
    FConn.ExecSQL('DELETE FROM cl_series WHERE codserie = ''' + SERIE + '''');
  except
    // limpieza de mejor esfuerzo
  end;
end;

procedure TPruebasSeriesBD.ListarSeries_CuentaSubseries;
var
  L: TArray<TSerieResumen>;
  R: TSerieResumen;
  Visto: Boolean;
begin
  GuardarSubserie(FConn, Sub('ZZ9A', 'Uno'), True);
  GuardarSubserie(FConn, Sub('ZZ9B', 'Dos'), True);
  L := ListarSeries(FConn);
  Visto := False;
  for R in L do
    if R.CodSerie = SERIE then
    begin
      Visto := True;
      Assert.AreEqual(2, R.NSubseries);
    end;
  Assert.IsTrue(Visto);
end;

procedure TPruebasSeriesBD.ListarSubseries_MarcaLasQueTienenTabla;
var
  L: TArray<TSubserieResumen>;
begin
  GuardarSubserie(FConn, Sub('ZZ9A', 'Uno'), True);
  GuardarSubserie(FConn, Sub('ZZ9B', 'Dos'), True);
  FConn.ExecSQL('CREATE TABLE ' + TABLA + ' (id INT)');
  L := ListarSubseries(FConn, SERIE);
  Assert.AreEqual(2, Length(L));
  Assert.AreEqual('ZZ9A', L[0].CodSubs);
  Assert.IsTrue(L[0].TieneTabla);
  Assert.IsFalse(L[1].TieneTabla);
end;

procedure TPruebasSeriesBD.Guardar_Nueva_YLeer;
var
  S, R: TSubserie;
begin
  S := Sub('ZZ9A', 'Expedientes de prueba');
  S.TipoDoc := 2;
  S.Soporte := 1;
  S.Activa := True;
  S.Gestion := 5;
  S.Central := 10;
  S.FechaAprobacion := EncodeDate(2024, 3, 12);
  S.Deposito := 'D1';
  S.Gaveta := 'G2';
  GuardarSubserie(FConn, S, True);
  R := LeerSubserie(FConn, 'ZZ9A');
  Assert.AreEqual('Expedientes de prueba', R.Nombre);
  Assert.AreEqual(2, R.TipoDoc);
  Assert.IsTrue(R.Activa);
  Assert.AreEqual(5, R.Gestion);
  Assert.AreEqual(10, R.Central);
  Assert.AreEqual('D1', R.Deposito);
  Assert.AreEqual('G2', R.Gaveta);
  Assert.AreEqual(Double(EncodeDate(2024, 3, 12)), Double(Trunc(R.FechaAprobacion)));
end;

procedure TPruebasSeriesBD.Guardar_Nueva_CodigoDuplicado_Lanza;
begin
  Assert.WillRaise(
    procedure
    begin
      // 074 ya existe en la base de pruebas
      GuardarSubserie(FConn, Sub('074', 'Repetida'), True);
    end, ESerieInvalida);
end;

procedure TPruebasSeriesBD.Guardar_Edicion_NoTocaOtrasColumnas;
var
  S: TSubserie;
begin
  GuardarSubserie(FConn, Sub('ZZ9A', 'Uno'), True);
  FConn.ExecSQL('UPDATE cl_subseries SET Vigencia = 7, NombreTablaMetadatos = ''md_otra'' WHERE codsubs = ''ZZ9A''');
  S := LeerSubserie(FConn, 'ZZ9A');
  S.Nombre := 'Uno editada';
  GuardarSubserie(FConn, S, False);
  Assert.AreEqual('Uno editada', LeerSubserie(FConn, 'ZZ9A').Nombre);
  Assert.AreEqual(7, Cuenta('SELECT Vigencia FROM cl_subseries WHERE codsubs = ''ZZ9A'''));
  Assert.AreEqual('md_otra', string(FConn.ExecSQLScalar('SELECT NombreTablaMetadatos FROM cl_subseries WHERE codsubs = ''ZZ9A''')));
end;

procedure TPruebasSeriesBD.Guardar_Serie_NuevaYEdicion;
var
  S: TSerie;
begin
  S.CodSerie := 'ZZ9';
  S.Serie := 'Serie de prueba';
  // ZZ9 ya existe (la siembra la prueba): un alta con ese codigo se rechaza
  Assert.WillRaise(
    procedure
    begin
      GuardarSerie(FConn, S, True);
    end, ESerieInvalida);
  S.CodSerie := 'ZZ9X';
  GuardarSerie(FConn, S, True);
  FConn.ExecSQL('DELETE FROM cl_series WHERE codserie = ''ZZ9X''');
  S.CodSerie := 'ZZ9';
  S.Serie := 'Cambiada';
  GuardarSerie(FConn, S, False);
  Assert.AreEqual('Cambiada', string(FConn.ExecSQLScalar('SELECT serie FROM cl_series WHERE codserie = ''ZZ9''')));
end;

procedure TPruebasSeriesBD.Observacion_ConservaElTextoTalCual;
const
  RTF = '{\rtf1\ansi Hola\par}';
begin
  GuardarSubserie(FConn, Sub('ZZ9A', 'Uno'), True);
  Assert.AreEqual('', LeerObservacion(FConn, 'ZZ9A'));
  GuardarObservacion(FConn, 'ZZ9A', RTF);
  Assert.AreEqual(RTF, LeerObservacion(FConn, 'ZZ9A'));
  GuardarObservacion(FConn, 'ZZ9A', '');
  Assert.AreEqual('', LeerObservacion(FConn, 'ZZ9A'));
end;

procedure TPruebasSeriesBD.Eliminar_ConDocumentos_Bloquea;
var
  Antes: Integer;
begin
  Antes := Cuenta('SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs = ''074''');
  try
    EliminarSubserie(FConn, '074');
    Assert.Fail('debio bloquear la baja de una subserie con documentos');
  except
    on E: EEnUso do
      Assert.IsTrue(E.Usos > 0);
  end;
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM cl_subseries WHERE codsubs = ''074'''));
  Assert.AreEqual(Antes, Cuenta('SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs = ''074'''));
end;

procedure TPruebasSeriesBD.Eliminar_Serie_ConSubseries_Bloquea;
begin
  GuardarSubserie(FConn, Sub('ZZ9A', 'Uno'), True);
  Assert.WillRaise(
    procedure
    begin
      EliminarSerie(FConn, SERIE);
    end, EEnUso);
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM cl_series WHERE codserie = ''ZZ9'''));
end;

procedure TPruebasSeriesBD.Eliminar_Libre_BorraVariablesYTablaVacia;
var
  V: TCampoMeta;
begin
  GuardarSubserie(FConn, Sub('ZZ9A', 'Uno'), True);
  V := Default(TCampoMeta);
  V.Nombre := 'Org';
  V.Etiqueta := 'Organismo';
  V.Tipo := tmTexto;
  V.Longitud := 10;
  GuardarVariables(FConn, True, SERIE, 'ZZ9A', [V]);
  FConn.ExecSQL('CREATE TABLE ' + TABLA + ' (id INT, Org VARCHAR(10))');
  EliminarSubserie(FConn, 'ZZ9A');
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM cl_subseries WHERE codsubs = ''ZZ9A'''));
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs = ''ZZ9A'''));
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM sys.tables WHERE name = ''' + TABLA + ''''));
  // ahora la serie, sin subseries, si se puede eliminar
  EliminarSerie(FConn, SERIE);
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM cl_series WHERE codserie = ''ZZ9'''));
end;

procedure TPruebasSeriesBD.ListarOpciones_TodosLosCatalogosResponden;
var
  C: TCatalogoSerie;
begin
  for C := Low(TCatalogoSerie) to High(TCatalogoSerie) do
    ListarOpciones(FConn, C);
  Assert.IsTrue(Length(ListarOpciones(FConn, csSoporte)) > 0);
  Assert.IsTrue(Length(ListarOpciones(FConn, csTipoDoc)) > 0);
end;

end.
