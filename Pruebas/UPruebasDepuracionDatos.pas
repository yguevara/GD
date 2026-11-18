unit UPruebasDepuracionDatos;

{ Datos de la depuracion contra SQL Server (ARCHIGENIO_TEST_DB; se omiten sin ella).
  Cada prueba siembra su subserie depurable (UPruebasApoyoDepuracion) y limpia lo
  suyo (CreadoPor = '__prueba__'). Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasDepuracionPuro = class
  public
    [Test]
    procedure CondicionVencidoCentralUsaCierreOFechaBase;
  end;

  [TestFixture]
  TPruebasDepuracionDatosBD = class
  private
    FConn: TFDConnection;
    function Conectar: Boolean;
    function Escalar(const Sql: string): Variant;
    function Grupo(const Grupos: TArray<TObject>; const Cod: string): Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure ProponeLosDocumentosEnArchivoCentralConPlazoVencido;
    [Test]
    procedure NoProponeLosDeUnArchivoDeGestion;
    [Test]
    procedure NoProponeSinAniosEnElCentralNiConOtroDestino;
    [Test]
    procedure NoProponeSiElPlazoNoVencio;
    [Test]
    procedure CuentaDesdeElCierreDeLaTransferencia;
    [Test]
    procedure UnDocumentoRetenidoNoEntraYSumaARetenidos;
    [Test]
    procedure UnDocumentoEnPrestamoViejoAbiertoNoSePropone;
    [Test]
    procedure NoProponeLosYaEliminados;
    [Test]
    procedure CrearDepuracionNumeraYCreaLaFilaDelActa;
    [Test]
    procedure AgregarGrupoRetieneYUnaSegundaVezNoAgregaNada;
    [Test]
    procedure QuitarGrupoLiberaLosDocumentos;
    [Test]
    procedure GruposYDesglosePorAnio;
    [Test]
    procedure ListarDepuracionesRespetaAnioYLimite;
  end;

implementation

uses
  System.SysUtils, System.Variants, System.DateUtils, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param,
  Data.DB, UAlcance, UCandados, UProceso, UEsquemaProcesos, UProcesosDatos,
  UDepuracionDatos, UPruebasApoyoTransferido, UPruebasApoyoDepuracion;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  USUARIO = '__prueba__';
  COD = 'ZZPD1';

function BuscarGrupo(const Grupos: TArray<TGrupoDepuracion>; const Cod: string;
  out G: TGrupoDepuracion): Boolean;
var
  X: TGrupoDepuracion;
begin
  Result := False;
  for X in Grupos do
    if X.CodSubs = Cod then
    begin
      G := X;
      Exit(True);
    end;
end;

{ TPruebasDepuracionPuro }

procedure TPruebasDepuracionPuro.CondicionVencidoCentralUsaCierreOFechaBase;
var
  S: string;
begin
  S := SqlCondicionVencidoCentral;
  Assert.IsTrue(Pos(':corteT', S) > 0);
  Assert.IsTrue(Pos(':corteF', S) > 0);
  Assert.IsTrue(Pos('prc_unidad', S) > 0);
  Assert.IsTrue(Pos('P.Tipo = ''T''', S) > 0);
  Assert.IsTrue(Pos('P.Estado = ''F''', S) > 0);
  Assert.IsTrue(Pos('P.Cerrado', S) > 0);
  Assert.IsTrue(Pos('H.FechaFin >= H.Fecha', S) > 0);
end;

{ TPruebasDepuracionDatosBD }

procedure TPruebasDepuracionDatosBD.Preparar;
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

procedure TPruebasDepuracionDatosBD.Limpiar;
begin
  if FConn <> nil then
  try
    LimpiarDepuraciones(FConn, USUARIO);
    LimpiarTransferidos(FConn, USUARIO);
    LimpiarSerieDepurable(FConn);
  finally
    FreeAndNil(FConn);
  end;
end;

function TPruebasDepuracionDatosBD.Conectar: Boolean;
begin
  Result := FConn <> nil;
  if not Result then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
end;

function TPruebasDepuracionDatosBD.Escalar(const Sql: string): Variant;
begin
  Result := FConn.ExecSQLScalar(Sql);
end;

function TPruebasDepuracionDatosBD.Grupo(const Grupos: TArray<TObject>; const Cod: string): Integer;
begin
  Result := 0;
end;

procedure TPruebasDepuracionDatosBD.ProponeLosDocumentosEnArchivoCentralConPlazoVencido;
var
  Nodo: TClaveNodo;
  G: TGrupoDepuracion;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
  Assert.IsTrue(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G), 'debe haber un grupo');
  Assert.AreEqual(3, G.Unidades);
  Assert.AreEqual(0, G.Retenidos);
  Assert.AreEqual(5, G.AniosCentral);
  Assert.AreEqual('Serie de prueba', G.Subserie);
  Assert.AreEqual(EncodeDate(2010, 3, 10), G.Desde, 0.0001);
  Assert.AreEqual(EncodeDate(2010, 3, 10), G.Hasta, 0.0001);
  Assert.AreEqual(Nodo.IdEstructura, G.IdEstructura);
  Assert.AreEqual(Nodo.Id, G.IdNodo);
end;

procedure TPruebasDepuracionDatosBD.NoProponeLosDeUnArchivoDeGestion;
var
  Nodo: TClaveNodo;
  G: TGrupoDepuracion;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoGestionApoyo(FConn));
  Assert.IsFalse(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G),
    'lo que sigue en un archivo de gestion no se depura');
end;

procedure TPruebasDepuracionDatosBD.NoProponeSinAniosEnElCentralNiConOtroDestino;
var
  Nodo: TClaveNodo;
  G: TGrupoDepuracion;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 0, 3, ArchivoCentralApoyo(FConn));
  Assert.IsFalse(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G), 'tcentral = 0 nunca se propone');
  FConn.ExecSQL('UPDATE cl_subseries SET tcentral = 5, destino = 1 WHERE codsubs = ''' + COD + '''');
  Assert.IsFalse(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G), 'solo destino Eliminarlo');
  FConn.ExecSQL('UPDATE cl_subseries SET destino = 3 WHERE codsubs = ''' + COD + '''');
  Assert.IsTrue(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G), 'con destino 3 y plazo si');
end;

procedure TPruebasDepuracionDatosBD.NoProponeSiElPlazoNoVencio;
var
  Nodo: TClaveNodo;
  G: TGrupoDepuracion;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 50, 3, ArchivoCentralApoyo(FConn));
  Assert.IsFalse(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G));
end;

procedure TPruebasDepuracionDatosBD.CuentaDesdeElCierreDeLaTransferencia;
var
  Nodo: TClaveNodo;
  G: TGrupoDepuracion;
  Id: Integer;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
  Id := SembrarTransferido(FConn, DocumentoDeSerie(Nodo, COD, 1), USUARIO);
  FConn.ExecSQL('UPDATE prc_proceso SET Cerrado = :d WHERE IdProceso = :p', [Date, Id],
    [ftDateTime, ftInteger]);
  Assert.IsTrue(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G));
  Assert.AreEqual(2, G.Unidades, 'el que llego hoy al central aun no cumple sus 5 anos');
  FConn.ExecSQL('UPDATE prc_proceso SET Cerrado = :d WHERE IdProceso = :p', [IncYear(Date, -6), Id],
    [ftDateTime, ftInteger]);
  Assert.IsTrue(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G));
  Assert.AreEqual(3, G.Unidades, 'con el cierre de hace 6 anos ya vencio');
end;

procedure TPruebasDepuracionDatosBD.UnDocumentoRetenidoNoEntraYSumaARetenidos;
var
  Nodo: TClaveNodo;
  G: TGrupoDepuracion;
  U: TUnidadDoc;
  Id: Integer;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
  U := DocumentoDeSerie(Nodo, COD, 1);
  Id := SembrarDepuracion(FConn, U, 1, 'C', True, USUARIO);  // otra depuracion en curso
  FConn.ExecSQL('INSERT INTO prc_bloqueo (IdEstructura, id, codsubs, Codigodoc, fecha, ' +
    'version, IdProceso) VALUES (:e, :i, :s, :c, :f, :v, :p)',
    [U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version, Id],
    [ftString, ftInteger, ftString, ftString, ftDateTime, ftString, ftInteger]);
  Assert.IsTrue(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G));
  Assert.AreEqual(2, G.Unidades);
  Assert.AreEqual(1, G.Retenidos);
end;

procedure TPruebasDepuracionDatosBD.UnDocumentoEnPrestamoViejoAbiertoNoSePropone;
var
  Nodo: TClaveNodo;
  G: TGrupoDepuracion;
  U: TUnidadDoc;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
  U := DocumentoDeSerie(Nodo, COD, 2);
  FConn.ExecSQL('INSERT INTO TB_Prestamos (IdEstructura, id, IdPrestamo, Prestamista, ' +
    'Responsable, FPrestamo) VALUES (:e, :i, ''F4A-1'', ''Juan'', ''usr1'', :f)',
    [U.IdEstructura, U.Id, EncodeDate(2026, 4, 1)]);
  FConn.ExecSQL('INSERT INTO TB_PrestamosDocumentos (IdEstructura, id, IdPrestamo, Codigodoc, ' +
    'fecha, version, codsubs, titulodoc) VALUES (:e, :i, ''F4A-1'', :c, :f, ''1'', :s, ''t'')',
    [U.IdEstructura, U.Id, U.CodigoDoc, U.Fecha, U.CodSubs]);
  Assert.IsTrue(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G));
  Assert.AreEqual(2, G.Unidades);
  Assert.AreEqual(1, G.Retenidos, 'el prestamo viejo abierto cuenta como retenido');
end;

procedure TPruebasDepuracionDatosBD.NoProponeLosYaEliminados;
var
  Nodo: TClaveNodo;
  G: TGrupoDepuracion;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
  SembrarDepuracion(FConn, DocumentoDeSerie(Nodo, COD, 3), 5, 'C', True, USUARIO);
  Assert.IsTrue(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G));
  Assert.AreEqual(2, G.Unidades, 'el eliminado por otra depuracion no se vuelve a proponer');
  Assert.AreEqual(0, G.Retenidos);
end;

procedure TPruebasDepuracionDatosBD.CrearDepuracionNumeraYCreaLaFilaDelActa;
var
  Nodo: TClaveNodo;
  R: TProcesoRef;
  Id: string;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 1, ArchivoCentralApoyo(FConn));
  R := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  Id := IntToStr(R.IdProceso);
  Assert.IsTrue(Pos('D-1992-', R.Numero) = 1, R.Numero);
  Assert.AreEqual('D', Trim(VarToStr(Escalar('SELECT Tipo FROM prc_proceso WHERE IdProceso = ' + Id))));
  Assert.AreEqual(1, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
  Assert.AreEqual(1, Integer(Escalar('SELECT COUNT(*) FROM prc_depuracion WHERE IdProceso = ' + Id)));
  Assert.AreEqual(R.Numero, Trim(VarToStr(Escalar('SELECT Numero FROM prc_proceso WHERE IdProceso = ' + Id))));
end;

procedure TPruebasDepuracionDatosBD.AgregarGrupoRetieneYUnaSegundaVezNoAgregaNada;
var
  Nodo: TClaveNodo;
  R: TProcesoRef;
  G: TGrupoDepuracion;
  N: Integer;
  Motivo, Id: string;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
  R := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  Id := IntToStr(R.IdProceso);
  Assert.IsTrue(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G));
  Assert.IsTrue(AgregarGrupoDepuracion(FConn, R.IdProceso, G, Date, N, Motivo), Motivo);
  Assert.AreEqual(3, N);
  Assert.AreEqual(3, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' + Id)));
  Assert.AreEqual(3, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad WHERE IdProceso = ' + Id + ' AND Activa <> 0')));
  Assert.IsFalse(AgregarGrupoDepuracion(FConn, R.IdProceso, G, Date, N, Motivo));
  Assert.AreEqual(0, N);
  Assert.IsTrue(Motivo <> '', 'dice por que');
  Assert.AreEqual(3, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad WHERE IdProceso = ' + Id)));
end;

procedure TPruebasDepuracionDatosBD.QuitarGrupoLiberaLosDocumentos;
var
  Nodo: TClaveNodo;
  R: TProcesoRef;
  G: TGrupoDepuracion;
  N: Integer;
  Motivo, Id: string;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
  R := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  Id := IntToStr(R.IdProceso);
  BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G);
  Assert.IsTrue(AgregarGrupoDepuracion(FConn, R.IdProceso, G, Date, N, Motivo));
  QuitarGrupoDepuracion(FConn, R.IdProceso, Nodo.IdEstructura, Nodo.Id, COD);
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' + Id)));
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad WHERE IdProceso = ' + Id)));
  Assert.IsTrue(BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G), 'vuelve a proponerse');
  Assert.AreEqual(3, G.Unidades);
end;

procedure TPruebasDepuracionDatosBD.GruposYDesglosePorAnio;
var
  Nodo: TClaveNodo;
  R: TProcesoRef;
  G: TGrupoDepuracion;
  Gr: TArray<TGrupoDepuracion>;
  D: TArray<TAnioCantidad>;
  N: Integer;
  Motivo: string;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
  FConn.ExecSQL('UPDATE tb_SeriesDatos SET fecha = ''2011-06-01'' WHERE codsubs = ''' + COD +
    ''' AND Codigodoc = ''PD-' + COD + '-3'' AND titulodoc = ''__prueba__''');
  R := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G);
  Assert.IsTrue(AgregarGrupoDepuracion(FConn, R.IdProceso, G, Date, N, Motivo), Motivo);
  Gr := GruposDeLaDepuracion(FConn, R.IdProceso);
  Assert.AreEqual(1, Length(Gr));
  Assert.AreEqual(COD, Gr[0].CodSubs);
  Assert.AreEqual(3, Gr[0].Unidades);
  Assert.AreEqual(EncodeDate(2010, 3, 10), Gr[0].Desde, 0.0001);
  Assert.AreEqual(EncodeDate(2011, 6, 1), Gr[0].Hasta, 0.0001);
  D := DesglosePorAnio(FConn, R.IdProceso);
  Assert.AreEqual(2, Length(D));
  Assert.AreEqual(2010, D[0].Anio);
  Assert.AreEqual(2, D[0].Unidades);
  Assert.AreEqual(2011, D[1].Anio);
  Assert.AreEqual(1, D[1].Unidades);
end;

procedure TPruebasDepuracionDatosBD.ListarDepuracionesRespetaAnioYLimite;
var
  Nodo: TClaveNodo;
  A, B, C: TProcesoRef;
  L: TArray<TDepuracionFila>;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 1, ArchivoCentralApoyo(FConn));
  A := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  B := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  C := CrearDepuracion(FConn, Nodo, USUARIO, 1993);
  L := ListarDepuraciones(FConn, [Nodo], 1992, 0);
  Assert.IsTrue(Length(L) >= 2);
  Assert.AreEqual(B.IdProceso, L[0].IdProceso, 'la mas reciente primero');
  Assert.AreEqual(1, L[0].Paso);
  Assert.AreEqual('Propuesta', L[0].Estado);
  Assert.AreEqual(Ord(epEnCurso), Ord(L[0].Proceso));
  Assert.AreEqual(Nodo.Id, L[0].Nodo.Id);
  L := ListarDepuraciones(FConn, [Nodo], 1992, 1);
  Assert.AreEqual(1, Length(L), 'respeta el limite');
  L := ListarDepuraciones(FConn, [Nodo], 1993, 0);
  Assert.AreEqual(1, Length(L));
  Assert.AreEqual(C.IdProceso, L[0].IdProceso);
  Assert.AreNotEqual(A.IdProceso, B.IdProceso);
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasDepuracionPuro);
  TDUnitX.RegisterTestFixture(TPruebasDepuracionDatosBD);

end.
