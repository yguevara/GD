unit UPruebasTransferidos;

{ Documentos transferidos: la parte pura (SQL y texto) corre siempre; las pruebas de
  base usan ARCHIGENIO_TEST_DB (se omiten sin ella). Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasTransferidosPuro = class
  public
    [Test]
    procedure SqlSoloDeTransferenciasFinalizadasConUnidadActiva;
    [Test]
    procedure SqlNoTieneParametrosYUsaLaClaveCompletaDelDocumento;
    [Test]
    procedure TextoDiceArchivoYNumero;
    [Test]
    procedure TextoSinNombreDeArchivoSigueDiciendoElNumero;
  end;

  [TestFixture]
  TPruebasTransferidosBD = class
  private
    FConn: TFDConnection;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure DocumentoTransferidoDiceDondeEstaYOtroNo;
    [Test]
    procedure UnaUnidadInactivaNoCuentaComoTransferida;
    [Test]
    procedure ClavesTransferidasMarcaCadaDocumentoDeUnaVez;
    [Test]
    procedure SinLasTablasDeProcesosNadaEstaTransferido;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt,
  FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UCandados, UEsquemaProcesos,
  UTransferidos, UPruebasApoyoTransferido;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  USUARIO = '__prueba__';

{ TPruebasTransferidosPuro }

procedure TPruebasTransferidosPuro.SqlSoloDeTransferenciasFinalizadasConUnidadActiva;
var
  S: string;
begin
  S := SqlTransferidos;
  Assert.IsTrue(Pos('P.Tipo = ''T''', S) > 0);
  Assert.IsTrue(Pos('P.Estado = ''F''', S) > 0);
  Assert.IsTrue(Pos('U.Activa <> 0', S) > 0);
  Assert.IsTrue(Pos('prc_transferencia', S) > 0);
end;

procedure TPruebasTransferidosPuro.SqlNoTieneParametrosYUsaLaClaveCompletaDelDocumento;
var
  S: string;
begin
  S := SqlTransferidos;
  Assert.AreEqual(0, Pos(':', S), 'sin parametros: el llamador agrega los suyos');
  Assert.IsTrue(Pos('U.codsubs', S) > 0);
  Assert.IsTrue(Pos('U.Codigodoc', S) > 0);
  Assert.IsTrue(Pos('U.fecha', S) > 0);
  Assert.IsTrue(Pos('U.version', S) > 0);
end;

procedure TPruebasTransferidosPuro.TextoDiceArchivoYNumero;
begin
  Assert.AreEqual('Transferido al archivo Central Norte (T-2026-02)',
    TextoTransferido('T-2026-02', 'Central Norte'));
end;

procedure TPruebasTransferidosPuro.TextoSinNombreDeArchivoSigueDiciendoElNumero;
begin
  Assert.AreEqual('Transferido (T-2026-02)', TextoTransferido('T-2026-02', ''));
  Assert.AreEqual('Transferido (T-2026-02)', TextoTransferido('T-2026-02', '   '));
end;

{ TPruebasTransferidosBD }

procedure TPruebasTransferidosBD.Preparar;
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

procedure TPruebasTransferidosBD.Limpiar;
begin
  if FConn <> nil then
  try
    LimpiarTransferidos(FConn, USUARIO);
  finally
    FreeAndNil(FConn);
  end;
end;

procedure TPruebasTransferidosBD.DocumentoTransferidoDiceDondeEstaYOtroNo;
var
  U, Otro: TUnidadDoc;
  Texto: string;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  U := UnidadApoyo('ZZ.T', 905, 'S1', 'DT1');
  SembrarTransferido(FConn, U, USUARIO);
  Texto := DondeEstaTransferido(FConn, U);
  Assert.IsTrue(Pos(USUARIO, Texto) > 0, 'dice el archivo: ' + Texto);
  Assert.IsTrue(Pos('T-1991-', Texto) > 0, 'dice la transferencia: ' + Texto);
  Assert.IsTrue(EstaTransferido(FConn, U));
  Otro := UnidadApoyo('ZZ.T', 905, 'S1', 'DT2');
  Assert.AreEqual('', DondeEstaTransferido(FConn, Otro));
  Assert.IsFalse(EstaTransferido(FConn, Otro));
  Otro := U;
  Otro.CodSubs := 'S2';  // misma clave salvo la subserie: es otro documento
  Assert.IsFalse(EstaTransferido(FConn, Otro));
end;

procedure TPruebasTransferidosBD.UnaUnidadInactivaNoCuentaComoTransferida;
var
  U: TUnidadDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  U := UnidadApoyo('ZZ.T', 906, 'S1', 'DT3');
  SembrarTransferido(FConn, U, USUARIO);
  FConn.ExecSQL('UPDATE prc_unidad SET Activa = 0 WHERE Codigodoc = ''DT3'' AND id = 906');
  Assert.IsFalse(EstaTransferido(FConn, U), 'una caja faltante se queda en el origen');
end;

procedure TPruebasTransferidosBD.ClavesTransferidasMarcaCadaDocumentoDeUnaVez;
var
  U1, U2, U3: TUnidadDoc;
  F: TArray<Boolean>;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  U1 := UnidadApoyo('ZZ.T', 907, 'S1', 'DT4');
  U2 := UnidadApoyo('ZZ.T', 907, 'S1', 'DT5');  // no transferido
  U3 := UnidadApoyo('ZZ.T', 908, 'S9', 'DT6');  // transferido, en otra subserie
  SembrarTransferido(FConn, U1, USUARIO);
  SembrarTransferido(FConn, U3, USUARIO);
  F := ClavesTransferidas(FConn, [U1, U2, U3]);
  Assert.AreEqual(3, Length(F));
  Assert.IsTrue(F[0]);
  Assert.IsFalse(F[1]);
  Assert.IsTrue(F[2]);
  Assert.AreEqual(0, Length(ClavesTransferidas(FConn, [])));
end;

procedure TPruebasTransferidosBD.SinLasTablasDeProcesosNadaEstaTransferido;
var
  C: TFDConnection;
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
    Assert.IsFalse(TablasDeProcesosExisten(C));
    Assert.IsTrue(TablasDeProcesosExisten(FConn));
    Assert.AreEqual('', DondeEstaTransferido(C, UnidadApoyo('ZZ.T', 1, 'S1', 'X')));
    Assert.AreEqual(1, Length(ClavesTransferidas(C, [UnidadApoyo('ZZ.T', 1, 'S1', 'X')])));
    Assert.IsFalse(ClavesTransferidas(C, [UnidadApoyo('ZZ.T', 1, 'S1', 'X')])[0]);
  finally
    C.Free;
  end;
end;

end.
