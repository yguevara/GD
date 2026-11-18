unit UPruebasDepuracionDatos;

{ Datos de la depuracion contra SQL Server (ARCHIGENIO_TEST_DB; se omiten sin ella).
  Cada prueba siembra su subserie depurable (UPruebasApoyoDepuracion) y limpia lo
  suyo (CreadoPor = '__prueba__'). Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UAlcance, UProcesosDatos,
  UDepuracionDatos;

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
    FNodo: TClaveNodo;
    function Conectar: Boolean;
    function Escalar(const Sql: string): Variant;
    function NuevaDepuracion(Docs: Integer): TProcesoRef;
    function DepuracionListaParaEjecutar(Docs: Integer): TProcesoRef;
    function Filas: Integer;
    function ActaValida: TActaDepuracion;
    procedure AgregarDosTestigosValidos(IdProceso: Integer);
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
    [Test]
    procedure GuardarActaInvalidaLanzaYNoGuarda;
    [Test]
    procedure GuardarActaCorrectaSeLeeIgual;
    [Test]
    procedure GuardarActaFueraDeLosPasosUnoATresLanza;
    [Test]
    procedure TestigosSeAgreganSeQuitanYSeFirman;
    [Test]
    procedure AgregarTestigoInvalidoLanza;
    [Test]
    procedure DosTestigosDeLaComisionNoBastan;
    [Test]
    procedure SinDocumentosNoSePasaDelPasoUno;
    [Test]
    procedure RecorridoDeLosPasosUnoATres;
    [Test]
    procedure UnPasoLeidoDesfasadoNoAvanzaNiCambiaNada;
    [Test]
    procedure EjecutarConConfirmacionIncorrectaLanzaYNoCambiaNada;
    [Test]
    procedure EjecutarMarcaEliminadosSinTocarLasFilas;
    [Test]
    procedure EjecutarRevalidaQueSigaRetenido;
    [Test]
    procedure EjecutarRevalidaLosPrestamosViejos;
    [Test]
    procedure EjecutarRevalidaQueSigaEnUnArchivoCentral;
    [Test]
    procedure EjecutarFueraDelPasoCuatroDevuelveFalse;
    [Test]
    procedure CerrarSoloDesdeElPasoCincoYLiberaLosCandados;
    [Test]
    procedure CancelarHastaElPasoTresLiberaLosCandados;
    [Test]
    procedure LaTransferenciaNoProponeNiAgregaLosEliminados;
    [Test]
    procedure EjecutarRevalidaTestigosYAutorizacionAunqueSeHayanQuitadoEnElPasoCuatro;
    [Test]
    procedure AgregarGrupoUsaElPlazoYElDestinoDeLaBaseNoLosDelGrupo;
    [Test]
    procedure AgregarGrupoRechazaOtroNodoQueElDeLaDepuracion;
    [Test]
    procedure ListarDepuracionesTraeElTextoDeLaAutorizacion;
  end;

implementation

uses
  System.SysUtils, System.Variants, System.DateUtils, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param,
  Data.DB, UCandados, UProceso, UEsquemaProcesos,
  UAutorizacion, UDepuracionReglas, UEliminados, UTransferenciasDatos, UPruebasApoyoTransferido,
  UPruebasApoyoDepuracion;

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
    FConn.ExecSQL('DELETE FROM prc_proceso WHERE CreadoPor = ''' + USUARIO + ''' AND Tipo = ''T''');
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

{ Depuracion en el paso 1 con una serie depurable de Docs documentos ya agregada. }
function TPruebasDepuracionDatosBD.NuevaDepuracion(Docs: Integer): TProcesoRef;
var
  Nodo: TClaveNodo;
  G: TGrupoDepuracion;
  N: Integer;
  Motivo: string;
begin
  Nodo := SembrarSerieDepurable(FConn, COD, 5, Docs, ArchivoCentralApoyo(FConn));
  FNodo := Nodo;
  Result := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G);
  AgregarGrupoDepuracion(FConn, Result.IdProceso, G, Date, N, Motivo);
end;

{ Depuracion con todo cargado y en el paso 4 (ejecucion). }
function TPruebasDepuracionDatosBD.DepuracionListaParaEjecutar(Docs: Integer): TProcesoRef;
var
  A: TAutorizacion;
  Faltan: TArray<string>;
begin
  Result := NuevaDepuracion(Docs);
  AvanzarDepuracion(FConn, Result.IdProceso, 1, USUARIO, Faltan);
  A.Organo := ocProvincial;
  A.NumActa := '14';
  A.NumAcuerdo := '9';
  A.Fecha := Date - 1;
  GuardarAutorizacion(FConn, Result.IdProceso, A, USUARIO);
  AvanzarDepuracion(FConn, Result.IdProceso, 2, USUARIO, Faltan);
  GuardarActaDepuracion(FConn, Result.IdProceso, ActaValida);
  AgregarDosTestigosValidos(Result.IdProceso);
  AvanzarDepuracion(FConn, Result.IdProceso, 3, USUARIO, Faltan);
end;

{ Filas de documentos de prueba en tb_SeriesDatos. }
function TPruebasDepuracionDatosBD.Filas: Integer;
begin
  Result := Integer(Escalar('SELECT COUNT(*) FROM tb_SeriesDatos WHERE titulodoc = ''__prueba__'''));
end;

function TPruebasDepuracionDatosBD.ActaValida: TActaDepuracion;
begin
  Result.Lugar := 'Planta de reciclaje municipal';
  Result.Via := veTrituracion;
  Result.FPrevista := EncodeDate(2026, 11, 20);
  Result.MuestraDesc := 'Facturas de enero de cada ano';
  Result.MuestraDonde := 'Dep. 1 - Est. B - Caja M-2';
end;

procedure TPruebasDepuracionDatosBD.AgregarDosTestigosValidos(IdProceso: Integer);
var
  T: TTestigoDatos;
begin
  T.Nombre := 'Elena Ruiz';
  T.Cargo := 'Presidenta de la Comision';
  T.Origen := otComision;
  AgregarTestigo(FConn, IdProceso, T);
  T.Nombre := 'R. Perez';
  T.Cargo := 'Responsable del archivo de gestion';
  T.Origen := otArchivoGestion;
  AgregarTestigo(FConn, IdProceso, T);
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

procedure TPruebasDepuracionDatosBD.GuardarActaInvalidaLanzaYNoGuarda;
var
  R: TProcesoRef;
  A: TActaDepuracion;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(2);
  A := ActaValida;
  A.Lugar := '';
  Assert.WillRaise(
    procedure
    begin
      GuardarActaDepuracion(FConn, R.IdProceso, A);
    end, EArgumentException);
  A := ActaValida;
  A.MuestraDonde := '   ';
  Assert.WillRaise(
    procedure
    begin
      GuardarActaDepuracion(FConn, R.IdProceso, A);
    end, EArgumentException);
  Assert.AreEqual('', VarToStr(Escalar('SELECT Lugar FROM prc_depuracion WHERE IdProceso = ' +
    IntToStr(R.IdProceso))), 'no se guardo nada');
end;

procedure TPruebasDepuracionDatosBD.GuardarActaCorrectaSeLeeIgual;
var
  R: TProcesoRef;
  A, B: TActaDepuracion;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(2);
  A := ActaValida;
  GuardarActaDepuracion(FConn, R.IdProceso, A);
  Assert.IsTrue(LeerActaDepuracion(FConn, R.IdProceso, B));
  Assert.AreEqual(A.Lugar, B.Lugar);
  Assert.AreEqual(Ord(veTrituracion), Ord(B.Via));
  Assert.AreEqual(A.FPrevista, B.FPrevista, 0.0001);
  Assert.AreEqual(A.MuestraDesc, B.MuestraDesc);
  Assert.AreEqual(A.MuestraDonde, B.MuestraDonde);
  // se puede cambiar mientras no se ejecute
  A.Via := veIncineracion;
  GuardarActaDepuracion(FConn, R.IdProceso, A);
  LeerActaDepuracion(FConn, R.IdProceso, B);
  Assert.AreEqual(Ord(veIncineracion), Ord(B.Via));
end;

procedure TPruebasDepuracionDatosBD.GuardarActaFueraDeLosPasosUnoATresLanza;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(2);
  FConn.ExecSQL('UPDATE prc_proceso SET Paso = 4 WHERE IdProceso = ' + IntToStr(R.IdProceso));
  Assert.WillRaise(
    procedure
    begin
      GuardarActaDepuracion(FConn, R.IdProceso, ActaValida);
    end, EArgumentException);
end;

procedure TPruebasDepuracionDatosBD.TestigosSeAgreganSeQuitanYSeFirman;
var
  R: TProcesoRef;
  T: TTestigoDatos;
  I1, I2: Integer;
  L: TArray<TTestigoFila>;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(2);
  T.Nombre := 'Elena Ruiz';
  T.Cargo := 'Presidenta';
  T.Origen := otComision;
  I1 := AgregarTestigo(FConn, R.IdProceso, T);
  T.Nombre := 'R. Perez';
  T.Cargo := '';
  T.Origen := otArchivoGestion;
  I2 := AgregarTestigo(FConn, R.IdProceso, T);
  Assert.AreNotEqual(I1, I2);
  L := TestigosDeLaDepuracion(FConn, R.IdProceso);
  Assert.AreEqual(2, Length(L));
  Assert.AreEqual('Elena Ruiz', L[0].Nombre, 'en orden de alta');
  Assert.AreEqual(Ord(otComision), Ord(L[0].Origen));
  Assert.AreEqual(Ord(otArchivoGestion), Ord(L[1].Origen));
  Assert.IsFalse(L[0].Firmo);
  MarcarFirma(FConn, R.IdProceso, I1, True);
  L := TestigosDeLaDepuracion(FConn, R.IdProceso);
  Assert.IsTrue(L[0].Firmo);
  Assert.IsFalse(L[1].Firmo);
  QuitarTestigo(FConn, R.IdProceso, I1);
  L := TestigosDeLaDepuracion(FConn, R.IdProceso);
  Assert.AreEqual(1, Length(L));
  Assert.AreEqual('R. Perez', L[0].Nombre);
end;

procedure TPruebasDepuracionDatosBD.AgregarTestigoInvalidoLanza;
var
  R: TProcesoRef;
  T: TTestigoDatos;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(2);
  T.Nombre := '';
  T.Cargo := '';
  T.Origen := otComision;
  Assert.WillRaise(
    procedure
    begin
      AgregarTestigo(FConn, R.IdProceso, T);
    end, EArgumentException);
  Assert.AreEqual(0, Length(TestigosDeLaDepuracion(FConn, R.IdProceso)));
end;

procedure TPruebasDepuracionDatosBD.DosTestigosDeLaComisionNoBastan;
var
  R: TProcesoRef;
  T: TTestigoDatos;
  Faltan: TArray<string>;
  C: TCondiciones;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(2);
  FConn.ExecSQL('UPDATE prc_proceso SET Paso = 3 WHERE IdProceso = ' + IntToStr(R.IdProceso));
  T.Cargo := '';
  T.Origen := otComision;
  T.Nombre := 'A';
  AgregarTestigo(FConn, R.IdProceso, T);
  T.Nombre := 'B';
  AgregarTestigo(FConn, R.IdProceso, T);
  C := CondicionesCumplidasDepuracion(FConn, R.IdProceso, Faltan);
  Assert.IsFalse(cdTestigosMinimos in C);
  Assert.IsTrue(Length(Faltan) >= 1, 'dice que falta');
  FConn.ExecSQL('DELETE FROM prc_testigo WHERE IdProceso = ' + IntToStr(R.IdProceso) + ' AND Nombre = ''B''');
  T.Nombre := 'B';
  T.Origen := otArchivoGestion;
  AgregarTestigo(FConn, R.IdProceso, T);
  C := CondicionesCumplidasDepuracion(FConn, R.IdProceso, Faltan);
  Assert.IsTrue(cdTestigosMinimos in C, 'Comision + archivo de gestion si bastan');
end;

procedure TPruebasDepuracionDatosBD.SinDocumentosNoSePasaDelPasoUno;
var
  R: TProcesoRef;
  Nodo: TClaveNodo;
  Faltan: TArray<string>;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 0, ArchivoCentralApoyo(FConn));
  R := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  Assert.IsFalse(AvanzarDepuracion(FConn, R.IdProceso, 1, USUARIO, Faltan));
  Assert.IsTrue(Length(Faltan) >= 1, 'dice que no hay documentos');
  Assert.AreEqual(1, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + IntToStr(R.IdProceso))));
end;

procedure TPruebasDepuracionDatosBD.RecorridoDeLosPasosUnoATres;
var
  R: TProcesoRef;
  A: TAutorizacion;
  Faltan: TArray<string>;
  Id: string;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(3);
  Id := IntToStr(R.IdProceso);
  // paso 1 -> 2
  Assert.IsTrue(AvanzarDepuracion(FConn, R.IdProceso, 1, USUARIO, Faltan));
  Assert.AreEqual(2, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
  // paso 2 exige autorizacion de la Comision (no la Central)
  Assert.IsFalse(AvanzarDepuracion(FConn, R.IdProceso, 2, USUARIO, Faltan));
  Assert.AreEqual(1, Length(Faltan));
  A.Organo := ocCentral;
  A.NumActa := '14';
  A.NumAcuerdo := '9';
  A.Fecha := Date - 1;
  Assert.WillRaise(
    procedure
    begin
      GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
    end, EAutorizacionInvalida);
  A.Organo := ocProvincial;
  GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
  Assert.IsTrue(AvanzarDepuracion(FConn, R.IdProceso, 2, USUARIO, Faltan));
  Assert.AreEqual(3, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
  // paso 3 exige muestra, testigos y acta completa
  Assert.IsFalse(AvanzarDepuracion(FConn, R.IdProceso, 3, USUARIO, Faltan));
  Assert.AreEqual(3, Length(Faltan), 'acta, muestra y testigos');
  GuardarActaDepuracion(FConn, R.IdProceso, ActaValida);
  Assert.IsFalse(AvanzarDepuracion(FConn, R.IdProceso, 3, USUARIO, Faltan));
  Assert.AreEqual(1, Length(Faltan), 'solo faltan los testigos');
  AgregarDosTestigosValidos(R.IdProceso);
  Assert.IsTrue(AvanzarDepuracion(FConn, R.IdProceso, 3, USUARIO, Faltan));
  Assert.AreEqual(4, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
  // los pasos 4 y 5 no se avanzan con esta funcion
  Assert.IsFalse(AvanzarDepuracion(FConn, R.IdProceso, 4, USUARIO, Faltan));
end;

procedure TPruebasDepuracionDatosBD.UnPasoLeidoDesfasadoNoAvanzaNiCambiaNada;
var
  R: TProcesoRef;
  Faltan: TArray<string>;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(2);
  FConn.ExecSQL('UPDATE prc_proceso SET Paso = 2 WHERE IdProceso = ' + IntToStr(R.IdProceso));
  Assert.IsFalse(AvanzarDepuracion(FConn, R.IdProceso, 1, USUARIO, Faltan), 'el usuario vio el paso 1 pero ya esta en el 2');
  Assert.AreEqual(2, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + IntToStr(R.IdProceso))));
end;

procedure TPruebasDepuracionDatosBD.EjecutarConConfirmacionIncorrectaLanzaYNoCambiaNada;
var
  R: TProcesoRef;
  Id: string;
begin
  if not Conectar then Exit;
  R := DepuracionListaParaEjecutar(3);
  Id := IntToStr(R.IdProceso);
  Assert.AreEqual(4, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)), 'parte del paso 4');
  Assert.WillRaise(
    procedure
    begin
      EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'eliminar', Date);
    end, EArgumentException);
  Assert.WillRaise(
    procedure
    begin
      EjecutarDepuracion(FConn, R.IdProceso, USUARIO, '', Date);
    end, EArgumentException);
  Assert.AreEqual(4, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
  Assert.IsTrue(VarIsNull(Escalar('SELECT FEjecucion FROM prc_depuracion WHERE IdProceso = ' + Id)));
  Assert.IsFalse(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 1)));
end;

procedure TPruebasDepuracionDatosBD.EjecutarMarcaEliminadosSinTocarLasFilas;
var
  R: TProcesoRef;
  Id: string;
  Antes: Integer;
begin
  if not Conectar then Exit;
  R := DepuracionListaParaEjecutar(3);
  Id := IntToStr(R.IdProceso);
  Antes := Filas;
  Assert.AreEqual(3, Antes);
  Assert.IsTrue(EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'ELIMINAR', Date));
  Assert.AreEqual(5, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
  Assert.AreEqual(Date, TDateTime(Escalar('SELECT FEjecucion FROM prc_depuracion WHERE IdProceso = ' + Id)), 1.0);
  Assert.AreEqual(Antes, Filas, 'las filas de los documentos NO se borran');
  Assert.AreEqual(3, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' + Id)), 'siguen retenidos');
  Assert.IsTrue(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 1)));
  Assert.IsTrue(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 3)));
  Assert.IsFalse(EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'ELIMINAR', Date), 'la segunda vez no hace nada');
  Assert.AreEqual(5, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
end;

procedure TPruebasDepuracionDatosBD.EjecutarRevalidaQueSigaRetenido;
var
  R: TProcesoRef;
  Id: string;
begin
  if not Conectar then Exit;
  R := DepuracionListaParaEjecutar(3);
  Id := IntToStr(R.IdProceso);
  FConn.ExecSQL('DELETE FROM prc_bloqueo WHERE IdProceso = ' + Id + ' AND Codigodoc = ''PD-' + COD + '-2''');
  Assert.WillRaise(
    procedure
    begin
      EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'ELIMINAR', Date);
    end, EArgumentException);
  Assert.AreEqual(4, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)), 'sigue en el paso 4');
  Assert.IsTrue(VarIsNull(Escalar('SELECT FEjecucion FROM prc_depuracion WHERE IdProceso = ' + Id)));
  Assert.IsFalse(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 1)));
end;

procedure TPruebasDepuracionDatosBD.EjecutarRevalidaLosPrestamosViejos;
var
  R: TProcesoRef;
  U: TUnidadDoc;
begin
  if not Conectar then Exit;
  R := DepuracionListaParaEjecutar(3);
  U := DocumentoDeSerie(FNodo, COD, 2);
  FConn.ExecSQL('INSERT INTO TB_Prestamos (IdEstructura, id, IdPrestamo, Prestamista, ' +
    'Responsable, FPrestamo) VALUES (:e, :i, ''F4A-2'', ''Juan'', ''usr1'', :f)',
    [U.IdEstructura, U.Id, EncodeDate(2026, 4, 1)]);
  FConn.ExecSQL('INSERT INTO TB_PrestamosDocumentos (IdEstructura, id, IdPrestamo, Codigodoc, ' +
    'fecha, version, codsubs, titulodoc) VALUES (:e, :i, ''F4A-2'', :c, :f, ''1'', :s, ''t'')',
    [U.IdEstructura, U.Id, U.CodigoDoc, U.Fecha, U.CodSubs]);
  Assert.WillRaise(
    procedure
    begin
      EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'ELIMINAR', Date);
    end, EArgumentException);
  Assert.AreEqual(4, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + IntToStr(R.IdProceso))));
end;

procedure TPruebasDepuracionDatosBD.EjecutarRevalidaQueSigaEnUnArchivoCentral;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := DepuracionListaParaEjecutar(3);
  FConn.ExecSQL('UPDATE tb_SeriesDatos SET Archivo = ' + IntToStr(ArchivoGestionApoyo(FConn)) +
    ' WHERE codsubs = ''' + COD + ''' AND Codigodoc = ''PD-' + COD + '-1'' AND titulodoc = ''__prueba__''');
  Assert.WillRaise(
    procedure
    begin
      EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'ELIMINAR', Date);
    end, EArgumentException);
  Assert.AreEqual(4, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + IntToStr(R.IdProceso))));
  Assert.IsFalse(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 2)), 'ninguno quedo a medias');
end;

procedure TPruebasDepuracionDatosBD.EjecutarFueraDelPasoCuatroDevuelveFalse;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(2);  // paso 1
  Assert.IsFalse(EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'ELIMINAR', Date));
  Assert.AreEqual(1, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + IntToStr(R.IdProceso))));
end;

procedure TPruebasDepuracionDatosBD.CerrarSoloDesdeElPasoCincoYLiberaLosCandados;
var
  R: TProcesoRef;
  Id: string;
begin
  if not Conectar then Exit;
  R := DepuracionListaParaEjecutar(3);
  Id := IntToStr(R.IdProceso);
  Assert.IsFalse(CerrarDepuracion(FConn, R.IdProceso, USUARIO), 'todavia no se ejecuto');
  Assert.IsTrue(EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'ELIMINAR', Date));
  Assert.IsTrue(CerrarDepuracion(FConn, R.IdProceso, USUARIO));
  Assert.AreEqual('F', Trim(VarToStr(Escalar('SELECT Estado FROM prc_proceso WHERE IdProceso = ' + Id))));
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' + Id)));
  Assert.AreEqual(3, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad WHERE IdProceso = ' + Id + ' AND Activa <> 0')));
  Assert.IsTrue(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 1)), 'cerrada sigue eliminado');
  Assert.IsFalse(CerrarDepuracion(FConn, R.IdProceso, USUARIO), 'cerrar dos veces no hace nada');
end;

procedure TPruebasDepuracionDatosBD.CancelarHastaElPasoTresLiberaLosCandados;
var
  R, R4: TProcesoRef;
  Id: string;
begin
  if not Conectar then Exit;
  R := NuevaDepuracion(3);
  Id := IntToStr(R.IdProceso);
  Assert.IsTrue(CancelarProceso(FConn, R.IdProceso, USUARIO, 'ya no se depura'));
  Assert.AreEqual('X', Trim(VarToStr(Escalar('SELECT Estado FROM prc_proceso WHERE IdProceso = ' + Id))));
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' + Id)));
  R4 := DepuracionListaParaEjecutar(3);
  Assert.IsFalse(CancelarProceso(FConn, R4.IdProceso, USUARIO, 'tarde'), 'en el paso 4 ya no se cancela');
end;

procedure TPruebasDepuracionDatosBD.LaTransferenciaNoProponeNiAgregaLosEliminados;
var
  Nodo: TClaveNodo;
  Grupos: TArray<TGrupoPropuesto>;
  G, Elegido: TGrupoPropuesto;
  T: TProcesoRef;
  Hay: Boolean;
  N: Integer;
  Motivo: string;
begin
  if not Conectar then Exit;
  // serie con plazo en el archivo de gestion vencido (tgestion 5) y documentos en un archivo de gestion
  Nodo := SembrarSerieDepurable(FConn, COD, 0, 3, ArchivoGestionApoyo(FConn));
  FConn.ExecSQL('UPDATE cl_subseries SET tgestion = 5, tcentral = 0 WHERE codsubs = ''' + COD + '''');
  SembrarDepuracion(FConn, DocumentoDeSerie(Nodo, COD, 3), 5, 'C', True, USUARIO);
  Grupos := ProponerTransferencia(FConn, [Nodo], Date);
  Hay := False;
  for G in Grupos do
    if G.CodSubs = COD then
    begin
      Hay := True;
      Elegido := G;
    end;
  Assert.IsTrue(Hay, 'la serie aparece en la propuesta de transferencia');
  Assert.AreEqual(2, Elegido.Unidades, 'el eliminado no se propone');
  T := CrearTransferencia(FConn, Nodo, USUARIO, 1992, 0);
  Assert.IsTrue(AgregarGrupo(FConn, T.IdProceso, Elegido, Date, N, Motivo), Motivo);
  Assert.AreEqual(2, N, 'tampoco se agrega');
end;

procedure TPruebasDepuracionDatosBD.EjecutarRevalidaTestigosYAutorizacionAunqueSeHayanQuitadoEnElPasoCuatro;
var
  R: TProcesoRef;
  T: TTestigoFila;
  Id: string;
begin
  if not Conectar then Exit;
  R := DepuracionListaParaEjecutar(3);
  Id := IntToStr(R.IdProceso);
  for T in TestigosDeLaDepuracion(FConn, R.IdProceso) do
    QuitarTestigo(FConn, R.IdProceso, T.IdTestigo);  // se permite hasta el paso 4
  Assert.WillRaise(
    procedure
    begin
      EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'ELIMINAR', Date);
    end, EArgumentException);
  Assert.AreEqual(4, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
  Assert.IsFalse(EstaEliminado(FConn, DocumentoDeSerie(FNodo, COD, 1)));
  AgregarDosTestigosValidos(R.IdProceso);
  FConn.ExecSQL('DELETE FROM prc_autorizacion WHERE IdProceso = ' + Id);
  Assert.WillRaise(
    procedure
    begin
      EjecutarDepuracion(FConn, R.IdProceso, USUARIO, 'ELIMINAR', Date);
    end, EArgumentException);
  Assert.AreEqual(4, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
end;

procedure TPruebasDepuracionDatosBD.AgregarGrupoUsaElPlazoYElDestinoDeLaBaseNoLosDelGrupo;
var
  Nodo: TClaveNodo;
  R: TProcesoRef;
  G: TGrupoDepuracion;
  N: Integer;
  Motivo: string;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 50, 3, ArchivoCentralApoyo(FConn));  // plazo no vencido
  R := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  G.IdEstructura := Nodo.IdEstructura;
  G.IdNodo := Nodo.Id;
  G.CodSubs := COD;
  G.AniosGestion := 0;
  G.AniosCentral := 1;  // el grupo dice 1 ano, la base dice 50
  Assert.IsFalse(AgregarGrupoDepuracion(FConn, R.IdProceso, G, Date, N, Motivo));
  Assert.AreEqual(0, N, 'manda el plazo de la base');
  // destino distinto de Eliminarlo
  FConn.ExecSQL('UPDATE cl_subseries SET tcentral = 5, destino = 1 WHERE codsubs = ''' + COD + '''');
  G.AniosCentral := 5;
  Assert.IsFalse(AgregarGrupoDepuracion(FConn, R.IdProceso, G, Date, N, Motivo));
  Assert.AreEqual(0, N);
  Assert.IsTrue(Motivo <> '');
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' + IntToStr(R.IdProceso))));
end;

procedure TPruebasDepuracionDatosBD.AgregarGrupoRechazaOtroNodoQueElDeLaDepuracion;
var
  Nodo: TClaveNodo;
  R: TProcesoRef;
  G: TGrupoDepuracion;
  N: Integer;
  Motivo: string;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
  R := CrearDepuracion(FConn, Nodo, USUARIO, 1992);
  BuscarGrupo(ProponerDepuracion(FConn, Nodo, Date), COD, G);
  G.IdNodo := Nodo.Id + 100000;  // otro nodo
  Assert.IsFalse(AgregarGrupoDepuracion(FConn, R.IdProceso, G, Date, N, Motivo));
  Assert.AreEqual(0, N);
  Assert.IsTrue(Motivo <> '');
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' + IntToStr(R.IdProceso))));
end;

procedure TPruebasDepuracionDatosBD.ListarDepuracionesTraeElTextoDeLaAutorizacion;
var
  Nodo: TClaveNodo;
  R: TProcesoRef;
  A: TAutorizacion;
  L: TArray<TDepuracionFila>;
begin
  if not Conectar then Exit;
  Nodo := SembrarSerieDepurable(FConn, COD, 5, 1, ArchivoCentralApoyo(FConn));
  R := CrearDepuracion(FConn, Nodo, USUARIO, 1994);
  L := ListarDepuraciones(FConn, [Nodo], 1994, 0);
  Assert.AreEqual(1, Length(L));
  Assert.AreEqual('', L[0].Autorizacion, 'sin autorizacion');
  A.Organo := ocProvincial;
  A.NumActa := '14';
  A.NumAcuerdo := '9';
  A.Fecha := Date - 1;
  GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
  L := ListarDepuraciones(FConn, [Nodo], 1994, 0);
  Assert.AreEqual('Comisi'#243'n Prov. - Acta 14 - Acuerdo 9', L[0].Autorizacion);
  A.Organo := ocMunicipal;
  GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
  L := ListarDepuraciones(FConn, [Nodo], 1994, 0);
  Assert.AreEqual('Comisi'#243'n Mun. - Acta 14 - Acuerdo 9', L[0].Autorizacion);
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasDepuracionPuro);
  TDUnitX.RegisterTestFixture(TPruebasDepuracionDatosBD);

end.
