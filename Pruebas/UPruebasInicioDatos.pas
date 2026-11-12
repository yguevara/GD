unit UPruebasInicioDatos;

{ Resumen de la pantalla de inicio del nodo (UInicioDatos). Usa SGDTEST_ALCANCE
  (ARCHIGENIO_TEST_DB); solo lee, no deja filas. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UInicioDatos;

type
  [TestFixture]
  TPruebasInicioDatos = class
  private
    FConn: TFDConnection;
    function Contar(const ASql: string): Integer;
    function NodoDe(const AEstructura: string; AId: Integer): Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Todos_Documentos_IgualAlTotal;
    [Test]
    procedure UnNodo_Documentos;
    [Test]
    procedure DosNodos_SumanDocumentos;
    [Test]
    procedure NodoSinDocumentos_Cero_PeroConSubserie;
    [Test]
    procedure UnNodo_SubseriesYSeries;
    [Test]
    procedure Todos_SinUbicacionYPrestados_IgualQueRequiereAccion;
    [Test]
    procedure SinNodosYSinTodos_TodoCero;
    [Test]
    procedure NodoInexistente_TodoCero;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt,
  FireDAC.ConsoleUI.Wait, UAlcance, UDocumentoVistaDatos;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';

procedure TPruebasInicioDatos.Preparar;
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

procedure TPruebasInicioDatos.Limpiar;
begin
  FreeAndNil(FConn);
end;

function TPruebasInicioDatos.Contar(const ASql: string): Integer;
begin
  Result := Integer(FConn.ExecSQLScalar(ASql));
end;

{ Cuenta los documentos de un nodo directamente en la base. }
function TPruebasInicioDatos.NodoDe(const AEstructura: string; AId: Integer): Integer;
begin
  Result := Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(*) FROM tb_SeriesDatos WHERE IdEstructura = :e AND id = :i',
    [AEstructura, AId]));
end;

procedure TPruebasInicioDatos.Todos_Documentos_IgualAlTotal;
var
  R: TResumenInicio;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := CargarResumenInicio(FConn, nil, nil, True);
  Assert.AreEqual(Contar('SELECT COUNT(*) FROM tb_SeriesDatos'), R.Documentos);
end;

procedure TPruebasInicioDatos.UnNodo_Documentos;
var
  R: TResumenInicio;
  N: TClaveNodo;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  N.IdEstructura := 'A.4.3';
  N.Id := 104;
  R := CargarResumenInicio(FConn, nil, TArray<TClaveNodo>.Create(N), False);
  Assert.AreEqual(NodoDe('A.4.3', 104), R.Documentos);
  Assert.IsTrue(R.Documentos > 0);
end;

procedure TPruebasInicioDatos.DosNodos_SumanDocumentos;
var
  R: TResumenInicio;
  A, B: TClaveNodo;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  A.IdEstructura := 'A.3.4';
  A.Id := 96;
  B.IdEstructura := 'A.4.3';
  B.Id := 104;
  R := CargarResumenInicio(FConn, nil, TArray<TClaveNodo>.Create(A, B), False);
  Assert.AreEqual(NodoDe('A.3.4', 96) + NodoDe('A.4.3', 104), R.Documentos);
end;

procedure TPruebasInicioDatos.NodoSinDocumentos_Cero_PeroConSubserie;
var
  R: TResumenInicio;
  N: TClaveNodo;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  N.IdEstructura := 'A.1.1';
  N.Id := 83;
  R := CargarResumenInicio(FConn, nil, TArray<TClaveNodo>.Create(N), False);
  Assert.AreEqual(0, R.Documentos);
  Assert.AreEqual(1, R.Subseries);
  Assert.AreEqual(1, R.Series);
end;

procedure TPruebasInicioDatos.UnNodo_SubseriesYSeries;
var
  R: TResumenInicio;
  N: TClaveNodo;
  EsperadasSub, EsperadasSer: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  N.IdEstructura := 'A.4.3';
  N.Id := 104;
  EsperadasSub := Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(DISTINCT codsubs) FROM tb_Serietree WHERE IdEstructura = :e AND id = :i',
    ['A.4.3', 104]));
  EsperadasSer := Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(DISTINCT C.codserie) FROM tb_Serietree S INNER JOIN cl_subseries C ' +
    'ON S.codsubs = C.codsubs WHERE S.IdEstructura = :e AND S.id = :i', ['A.4.3', 104]));
  R := CargarResumenInicio(FConn, nil, TArray<TClaveNodo>.Create(N), False);
  Assert.AreEqual(EsperadasSub, R.Subseries);
  Assert.AreEqual(EsperadasSer, R.Series);
  Assert.IsTrue(R.Subseries >= 2);
end;

procedure TPruebasInicioDatos.Todos_SinUbicacionYPrestados_IgualQueRequiereAccion;
var
  R: TResumenInicio;
  L: TArray<TContadorAccion>;
  I, SinUbic, Prest: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  L := CargarRequiereAccion(FConn, nil);
  SinUbic := 0;
  Prest := 0;
  for I := 0 to High(L) do
  begin
    if L[I].Clave = 'sinubicacion' then
      SinUbic := L[I].Cantidad;
    if L[I].Clave = 'prestados' then
      Prest := L[I].Cantidad;
  end;
  R := CargarResumenInicio(FConn, nil, nil, True);
  Assert.AreEqual(SinUbic, R.SinUbicacion);
  Assert.AreEqual(Prest, R.Prestados);
end;

procedure TPruebasInicioDatos.SinNodosYSinTodos_TodoCero;
var
  R: TResumenInicio;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := CargarResumenInicio(FConn, nil, nil, False);
  Assert.AreEqual(0, R.Documentos);
  Assert.AreEqual(0, R.Subseries);
  Assert.AreEqual(0, R.Series);
  Assert.AreEqual(0, R.SinUbicacion);
  Assert.AreEqual(0, R.Prestados);
end;

procedure TPruebasInicioDatos.NodoInexistente_TodoCero;
var
  R: TResumenInicio;
  N: TClaveNodo;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  N.IdEstructura := 'ZZ.9.9';
  N.Id := 99999;
  R := CargarResumenInicio(FConn, nil, TArray<TClaveNodo>.Create(N), False);
  Assert.AreEqual(0, R.Documentos);
  Assert.AreEqual(0, R.Subseries);
end;

end.
