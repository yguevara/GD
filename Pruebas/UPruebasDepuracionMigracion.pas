unit UPruebasDepuracionMigracion;

{ Pruebas de la migracion de tb_depuracion (UDepuracionMigracion) contra SQL Server;
  se omiten sin ARCHIGENIO_TEST_DB. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UAlcance;

type
  [TestFixture]
  TPruebasDepuracionMigracion = class
  private
    FConn: TFDConnection;
    FNodo: TClaveNodo;
    function Conectar: Boolean;
    procedure Vieja(N: Integer; const Fecha: string; Destino: Integer);
    procedure LimpiarTodo;
  public
    [SetupFixture]
    procedure Preparar;
    [TearDownFixture]
    procedure Limpiar;
    [Setup]
    procedure AntesDeCada;
    [Test]
    procedure MigraUnProcesoFinalizadoPorFechaYSoloLoEliminado;
    [Test]
    procedure RepetirLaMigracionNoDuplica;
    [Test]
    procedure UnDocumentoYaEliminadoPorOtraDepuracionSeOmiteYSeAvisa;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param,
  Data.DB, UCandados, UEsquemaProcesos, UEliminados, UPrestamosMigracion,
  UDepuracionMigracion, UPruebasApoyoDepuracion;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  USUARIO = '__prueba__';
  COD = 'ZZPD3';

procedure TPruebasDepuracionMigracion.Preparar;
begin
  FConn := nil;
  if GetEnvironmentVariable(VAR_BD) = '' then
    Exit;
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := GetEnvironmentVariable(VAR_BD);
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
  CrearEsquemaProcesos(FConn, True);
  FNodo := SembrarSerieDepurable(FConn, COD, 5, 4, ArchivoCentralApoyo(FConn));
end;

procedure TPruebasDepuracionMigracion.LimpiarTodo;
begin
  FConn.ExecSQL('DELETE FROM tb_depuracion WHERE Codigodoc LIKE ''PD-' + COD + '-%''');
  FConn.ExecSQL('DELETE FROM prc_proceso WHERE IdProceso IN (SELECT IdProceso FROM ' +
    'prc_unidad WHERE codsubs = ''' + COD + ''')');
  LimpiarDepuraciones(FConn, USUARIO);
end;

procedure TPruebasDepuracionMigracion.AntesDeCada;
begin
  if FConn <> nil then
    LimpiarTodo;
end;

procedure TPruebasDepuracionMigracion.Limpiar;
begin
  if FConn <> nil then
  try
    LimpiarTodo;
    LimpiarSerieDepurable(FConn);
  finally
    FreeAndNil(FConn);
  end;
end;

function TPruebasDepuracionMigracion.Conectar: Boolean;
begin
  Result := FConn <> nil;
  if not Result then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
end;

{ Fila de tb_depuracion del documento N de la serie sembrada, depurada en Fecha. }
procedure TPruebasDepuracionMigracion.Vieja(N: Integer; const Fecha: string; Destino: Integer);
var
  U: TUnidadDoc;
begin
  U := DocumentoDeSerie(FNodo, COD, N);
  FConn.ExecSQL('INSERT INTO tb_depuracion (IdEstructura, id, codsubs, fecha, Version, ' +
    'Codigodoc, titulodoc, destino, depurado, fechadepuracion) VALUES (:e, :i, :s, :f, :v, ' +
    ':c, ''__prueba__'', :d, 1, :fd)',
    [U.IdEstructura, U.Id, U.CodSubs, U.Fecha, U.Version, U.CodigoDoc, Destino,
     StrToDate(Fecha)],
    [ftString, ftInteger, ftString, ftDateTime, ftString, ftString, ftInteger, ftDateTime]);
end;

procedure TPruebasDepuracionMigracion.MigraUnProcesoFinalizadoPorFechaYSoloLoEliminado;
var
  R: TInformeMigracion;
  Antes: Integer;
begin
  if not Conectar then Exit;
  Vieja(1, '10/03/2026', 3);
  Vieja(2, '10/03/2026', 3);
  Vieja(3, '02/04/2026', 3);
  Vieja(4, '02/04/2026', 1);   // otro destino: no se migra
  Antes := Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_depuracion'));
  R := MigrarDepuracionesViejas(FConn);
  Assert.AreEqual(3, R.Leidos);
  Assert.AreEqual(2, R.Migrados, 'un proceso por fecha');
  Assert.AreEqual(2, Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM prc_proceso WHERE ' +
    'Tipo = ''D'' AND Estado = ''F'' AND Paso = 5 AND IdProceso IN (SELECT IdProceso FROM ' +
    'prc_unidad WHERE codsubs = ''' + COD + ''')')));
  Assert.IsTrue(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 1)));
  Assert.IsTrue(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 3)));
  Assert.IsFalse(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 4)), 'otro destino');
  Assert.AreEqual(Antes, Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_depuracion')),
    'la tabla vieja queda intacta');
  Assert.AreEqual(0, Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM prc_bloqueo WHERE ' +
    'codsubs = ''' + COD + '''')), 'sin candados');
end;

procedure TPruebasDepuracionMigracion.RepetirLaMigracionNoDuplica;
var
  R: TInformeMigracion;
begin
  if not Conectar then Exit;
  Vieja(1, '10/03/2026', 3);
  MigrarDepuracionesViejas(FConn);
  R := MigrarDepuracionesViejas(FConn);
  Assert.AreEqual(0, R.Migrados);
  Assert.AreEqual(1, Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad u INNER ' +
    'JOIN prc_proceso p ON p.IdProceso = u.IdProceso WHERE p.Tipo = ''D'' AND u.codsubs = ''' +
    COD + '''')));
end;

procedure TPruebasDepuracionMigracion.UnDocumentoYaEliminadoPorOtraDepuracionSeOmiteYSeAvisa;
var
  R: TInformeMigracion;
begin
  if not Conectar then Exit;
  SembrarDepuracion(FConn, DocumentoDeSerie(FNodo, COD, 1), 5, 'F', True, USUARIO);
  Vieja(1, '10/03/2026', 3);
  R := MigrarDepuracionesViejas(FConn);
  // el documento ya es eliminado por otra depuracion: no se vuelve a marcar
  Assert.AreEqual(0, R.Migrados);
  Assert.AreEqual(1, Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad u INNER ' +
    'JOIN prc_proceso p ON p.IdProceso = u.IdProceso WHERE p.Tipo = ''D'' AND u.codsubs = ''' +
    COD + '''')), 'una sola depuracion lo elimina');
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasDepuracionMigracion);

end.
