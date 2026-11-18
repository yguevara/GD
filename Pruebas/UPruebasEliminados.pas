unit UPruebasEliminados;

{ Documentos eliminados: la parte pura (SQL y texto) corre siempre; las pruebas de
  base usan ARCHIGENIO_TEST_DB (se omiten sin ella). Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasEliminadosPuro = class
  public
    [Test]
    procedure SqlSoloDeDepuracionesEjecutadasNoCanceladas;
    [Test]
    procedure SqlNoTieneParametrosYUsaLaClaveCompletaDelDocumento;
    [Test]
    procedure SqlNoEliminadoEsUnNotExistsSobreElAliasH;
    [Test]
    procedure TextoDiceElNumeroDeLaDepuracion;
  end;

  [TestFixture]
  TPruebasEliminadosBD = class
  private
    FConn: TFDConnection;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure EstaEliminadoSoloDesdeElPasoCincoYSiSigueVigente;
    [Test]
    procedure ClavesEliminadasMarcaCadaDocumentoDeUnaVez;
    [Test]
    procedure SinLasTablasDeProcesosNadaEstaEliminado;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt,
  FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UCandados, UEsquemaProcesos,
  UEliminados, UPruebasApoyoTransferido, UPruebasApoyoDepuracion;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  USUARIO = '__prueba__';

{ TPruebasEliminadosPuro }

procedure TPruebasEliminadosPuro.SqlSoloDeDepuracionesEjecutadasNoCanceladas;
var
  S: string;
begin
  S := SqlEliminados;
  Assert.IsTrue(Pos('P.Tipo = ''D''', S) > 0);
  Assert.IsTrue(Pos('P.Estado <> ''X''', S) > 0);
  Assert.IsTrue(Pos('P.Paso >= 5', S) > 0);
  Assert.IsTrue(Pos('U.Activa <> 0', S) > 0);
end;

procedure TPruebasEliminadosPuro.SqlNoTieneParametrosYUsaLaClaveCompletaDelDocumento;
var
  S: string;
begin
  S := SqlEliminados;
  Assert.AreEqual(0, Pos(':', S), 'sin parametros: el llamador agrega los suyos');
  Assert.IsTrue(Pos('U.codsubs', S) > 0);
  Assert.IsTrue(Pos('U.Codigodoc', S) > 0);
  Assert.IsTrue(Pos('U.fecha', S) > 0);
  Assert.IsTrue(Pos('U.version', S) > 0);
  Assert.IsTrue(Pos('P.Numero', S) > 0);
end;

procedure TPruebasEliminadosPuro.SqlNoEliminadoEsUnNotExistsSobreElAliasH;
var
  S: string;
begin
  S := SqlNoEliminado;
  Assert.IsTrue(Pos('NOT EXISTS', S) = 1);
  Assert.AreEqual(0, Pos(':', S));
  Assert.IsTrue(Pos('X.codsubs = H.codsubs', S) > 0);
  Assert.IsTrue(Pos('X.version = H.version', S) > 0);
  Assert.IsTrue(Pos('P.Paso >= 5', S) > 0);
  Assert.IsTrue(Pos('X.Activa <> 0', S) > 0);
end;

procedure TPruebasEliminadosPuro.TextoDiceElNumeroDeLaDepuracion;
begin
  Assert.AreEqual('Eliminado (D-2026-02)', TextoEliminado('D-2026-02'));
end;

{ TPruebasEliminadosBD }

procedure TPruebasEliminadosBD.Preparar;
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
end;

procedure TPruebasEliminadosBD.Limpiar;
begin
  if FConn <> nil then
  try
    LimpiarDepuraciones(FConn, USUARIO);
  finally
    FreeAndNil(FConn);
  end;
end;

procedure TPruebasEliminadosBD.EstaEliminadoSoloDesdeElPasoCincoYSiSigueVigente;
var
  U: TUnidadDoc;
  Id: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  U := UnidadApoyo('ZZ.T', 951, 'S1', 'DE1');
  Id := SembrarDepuracion(FConn, U, 4, 'C', True, USUARIO);
  Assert.AreEqual('', DondeEstaEliminado(FConn, U), 'en el paso 4 todavia no');
  Assert.IsFalse(EstaEliminado(FConn, U));
  FConn.ExecSQL('UPDATE prc_proceso SET Paso = 5 WHERE IdProceso = ' + IntToStr(Id));
  Assert.IsTrue(Pos('D-1992-', DondeEstaEliminado(FConn, U)) > 0, DondeEstaEliminado(FConn, U));
  Assert.IsTrue(Pos('Eliminado', DondeEstaEliminado(FConn, U)) = 1);
  Assert.IsTrue(EstaEliminado(FConn, U));
  FConn.ExecSQL('UPDATE prc_proceso SET Estado = ''F'' WHERE IdProceso = ' + IntToStr(Id));
  Assert.IsTrue(EstaEliminado(FConn, U), 'cerrada sigue eliminado');
  FConn.ExecSQL('UPDATE prc_proceso SET Estado = ''X'' WHERE IdProceso = ' + IntToStr(Id));
  Assert.IsFalse(EstaEliminado(FConn, U), 'cancelada no cuenta');
  FConn.ExecSQL('UPDATE prc_proceso SET Estado = ''C'' WHERE IdProceso = ' + IntToStr(Id));
  FConn.ExecSQL('UPDATE prc_unidad SET Activa = 0 WHERE IdProceso = ' + IntToStr(Id));
  Assert.IsFalse(EstaEliminado(FConn, U), 'unidad inactiva no cuenta');
end;

procedure TPruebasEliminadosBD.ClavesEliminadasMarcaCadaDocumentoDeUnaVez;
var
  U1, U2, U3: TUnidadDoc;
  F: TArray<Boolean>;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  U1 := UnidadApoyo('ZZ.T', 952, 'S1', 'DE2');
  U2 := UnidadApoyo('ZZ.T', 952, 'S1', 'DE3');  // no eliminado
  U3 := UnidadApoyo('ZZ.T', 953, 'S9', 'DE4');  // eliminado, en otra subserie
  SembrarDepuracion(FConn, U1, 5, 'C', True, USUARIO);
  SembrarDepuracion(FConn, U3, 5, 'F', True, USUARIO);
  F := ClavesEliminadas(FConn, [U1, U2, U3]);
  Assert.AreEqual(3, Length(F));
  Assert.IsTrue(F[0]);
  Assert.IsFalse(F[1]);
  Assert.IsTrue(F[2]);
  Assert.AreEqual(0, Length(ClavesEliminadas(FConn, [])));
end;

procedure TPruebasEliminadosBD.SinLasTablasDeProcesosNadaEstaEliminado;
var
  C: TFDConnection;
  U: TUnidadDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  C := TFDConnection.Create(nil);
  try
    C.LoginPrompt := False;
    C.DriverName := 'MSSQL';
    C.Params.Values['Server'] := 'localhost';
    C.Params.Values['Database'] := 'tempdb';  // sin tablas prc_*
    C.Params.Values['User_Name'] := 'geoconn';
    C.Params.Values['Password'] := 'geoconn';
    C.Params.Values['OSAuthent'] := 'No';
    C.Connected := True;
    U := UnidadApoyo('ZZ.T', 1, 'S1', 'X');
    Assert.AreEqual('', DondeEstaEliminado(C, U));
    Assert.IsFalse(EstaEliminado(C, U));
    Assert.IsFalse(ClavesEliminadas(C, [U])[0]);
  finally
    C.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasEliminadosPuro);
  TDUnitX.RegisterTestFixture(TPruebasEliminadosBD);

end.
