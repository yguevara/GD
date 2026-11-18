unit UPruebasTransferenciasDatos;

{ Datos de la transferencia. La parte pura (SQL de vencidos, agrupacion en cajas,
  textos de lo que falta) se ejecuta siempre; las pruebas de base usan
  ARCHIGENIO_TEST_DB (se omiten sin ella) y limpian sus filas
  (CreadoPor = '__prueba__', anios 1990-1999). }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UProcesosDatos;

type
  [TestFixture]
  TPruebasTransferenciasPuro = class
  public
    [Test]
    procedure CondicionVencidoUsaFechaFinSoloSiNoEsAnterior;
    [Test]
    procedure NoTransferidoExcluyeLosDeTransferenciasFinalizadas;
    [Test]
    procedure ArchivosDeGestionComoLista;
    [Test]
    procedure SinArchivosDeGestionNoSeleccionaNada;
    [Test]
    procedure GrupoPorExpedienteSiLoHay;
    [Test]
    procedure GrupoPorDocumentoSinExpediente;
    [Test]
    procedure ExpedientesDeSubseriesDistintasSonGruposDistintos;
    [Test]
    procedure TextoFaltaAutorizacion;
    [Test]
    procedure TextoFaltaCajasDiceCuantos;
    [Test]
    procedure TextoFaltaVerificacionesNombraLasQueFaltan;
  end;

  [TestFixture]
  TPruebasTransferenciasDatosBD = class
  private
    FConn: TFDConnection;
    function Conectar: Boolean;
    function Escalar(const Sql: string): Variant;
    procedure Unidad(IdProceso: Integer; const Subs, Cod: string);
    function TransferenciaEnPaso5(Cajas: Integer; Reales: Boolean = False): TProcesoRef;
    function TransferenciaEnPaso6(Cajas, Faltantes: Integer): TProcesoRef;
    procedure ArchivoDePrueba(Cod, Tipo: Integer);
    procedure UnidadReal(IdProceso, N: Integer);
    function DocCampo(N: Integer; const Campo: string): string;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure CrearTransferenciaGuardaPrevistaYEnlazaCronograma;
    [Test]
    procedure NumerarCajasSinHuerfanasYEsIdempotente;
    [Test]
    procedure VerificacionesSeMarcanYSeDesmarcan;
    [Test]
    procedure CondicionesFaltanSinAutorizacionNiCajas;
    [Test]
    procedure AvanzaHastaLaEntrega;
    [Test]
    procedure NoAvanzaSinVerificacionesCompletas;
    [Test]
    procedure EntregaGuardaFechaYPasaAlPasoCinco;
    [Test]
    procedure ListarPorAnio;
    [Test]
    procedure CronogramaAtrasado;
    [Test]
    procedure RelacionTieneUnaLineaPorCaja;
    [Test]
    procedure GruposAgregadosSumanLasUnidades;
    [Test]
    procedure ArchivosCentralesSoloDevuelveLosDeTipoCentral;
    [Test]
    procedure CajasDeTransferenciaLeeUnidadesYEstadoPendiente;
    [Test]
    procedure MarcarCajaRecibidaYCuarentenaYResolver;
    [Test]
    procedure MarcarCajaFaltanteCreaIncidenciaYSacaLasUnidades;
    [Test]
    procedure MarcarCajaFueraDelPasoCincoLanza;
    [Test]
    procedure RecepcionRechazaDestinoInexistenteCajasPendientesYCuarentena;
    [Test]
    procedure RecepcionConTodoDecididoAvanzaYGuardaDestino;
    [Test]
    procedure UbicacionDeCajaInvalidaLanzaYNoCambiaLaCaja;
    [Test]
    procedure UbicacionDeCajaFaltanteOFueraDelPasoSeisLanza;
    [Test]
    procedure CerrarSinUbicarTodasLasCajasLanzaYNoCambiaNada;
    [Test]
    procedure CerrarTraspasaLosDocumentosYFinaliza;
    [Test]
    procedure CerrarDosVecesLaSegundaDevuelveFalse;
    [Test]
    procedure CerrarSinArchivoDestinoLanzaYNoCambiaNada;
    [Test]
    procedure CerrarConElPasoCambiadoDevuelveFalse;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UAlcance,
  UProceso, UAutorizacion, UEsquemaProcesos,
  UTransferenciasReglas, UTransferenciasDatos;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  USUARIO = '__prueba__';

function Contiene(const Texto, Fragmento: string): Boolean;
begin
  Result := Pos(Fragmento, Texto) > 0;
end;

{ TPruebasTransferenciasPuro }

procedure TPruebasTransferenciasPuro.CondicionVencidoUsaFechaFinSoloSiNoEsAnterior;
var
  S: string;
begin
  S := SqlCondicionVencido;
  Assert.IsTrue(Contiene(S, 'H.FechaFin >= H.Fecha'));
  Assert.IsTrue(Contiene(S, 'H.FechaFin <= :corte'));
  Assert.IsTrue(Contiene(S, 'H.Fecha <= :corte'));
  Assert.IsTrue(Contiene(S, 'H.FechaFin IS NULL OR H.FechaFin < H.Fecha'));
end;

procedure TPruebasTransferenciasPuro.NoTransferidoExcluyeLosDeTransferenciasFinalizadas;
var
  S: string;
begin
  S := SqlNoTransferido;
  Assert.IsTrue(Contiene(S, 'NOT EXISTS'));
  Assert.IsTrue(Contiene(S, 'prc_unidad'));
  Assert.IsTrue(Contiene(S, 'Tipo = ''T'''));
  Assert.IsTrue(Contiene(S, 'Estado = ''F'''));
  Assert.IsTrue(Contiene(S, 'X.codsubs = H.codsubs'));
  Assert.IsTrue(Contiene(S, 'X.version = H.version'));
  Assert.IsFalse(Contiene(S, ':'), 'sin parametros');
end;

procedure TPruebasTransferenciasPuro.ArchivosDeGestionComoLista;
begin
  Assert.AreEqual('H.Archivo IN (1, 3, 7)', SqlArchivosGestion([1, 3, 7]));
  Assert.AreEqual('H.Archivo IN (2)', SqlArchivosGestion([2]));
end;

procedure TPruebasTransferenciasPuro.SinArchivosDeGestionNoSeleccionaNada;
begin
  Assert.AreEqual('1 = 0', SqlArchivosGestion([]));
end;

procedure TPruebasTransferenciasPuro.GrupoPorExpedienteSiLoHay;
begin
  Assert.AreEqual('S1|EXP-9', GrupoDeCaja('S1', ' EXP-9 ', 'D1', EncodeDate(2020, 1, 1), '1'));
  Assert.AreEqual(GrupoDeCaja('S1', 'EXP-9', 'D1', EncodeDate(2020, 1, 1), '1'),
    GrupoDeCaja('S1', 'EXP-9', 'D2', EncodeDate(2021, 5, 5), '3'),
    'documentos del mismo expediente: mismo grupo');
end;

procedure TPruebasTransferenciasPuro.GrupoPorDocumentoSinExpediente;
begin
  Assert.AreNotEqual(GrupoDeCaja('S1', '', 'D1', EncodeDate(2020, 1, 1), '1'),
    GrupoDeCaja('S1', '', 'D2', EncodeDate(2020, 1, 1), '1'));
  Assert.AreNotEqual(GrupoDeCaja('S1', '', 'D1', EncodeDate(2020, 1, 1), '1'),
    GrupoDeCaja('S1', '', 'D1', EncodeDate(2020, 1, 1), '2'), 'otra version: otro documento');
end;

procedure TPruebasTransferenciasPuro.ExpedientesDeSubseriesDistintasSonGruposDistintos;
begin
  Assert.AreNotEqual(GrupoDeCaja('S1', 'EXP-9', 'D1', EncodeDate(2020, 1, 1), '1'),
    GrupoDeCaja('S2', 'EXP-9', 'D1', EncodeDate(2020, 1, 1), '1'));
end;

procedure TPruebasTransferenciasPuro.TextoFaltaAutorizacion;
var
  T: TArray<string>;
begin
  T := TextosQueFaltan([cdAutorizado], 0, 0, []);
  Assert.AreEqual(1, Length(T));
  Assert.IsTrue(Pos('autorizaci', T[0]) > 0);
end;

procedure TPruebasTransferenciasPuro.TextoFaltaCajasDiceCuantos;
var
  T: TArray<string>;
begin
  T := TextosQueFaltan([cdVerificacionesCompletas], 12, 5, ['unicos', 'completos',
    'sindividir', 'etiquetas', 'prestamos']);
  Assert.AreEqual(1, Length(T));
  Assert.IsTrue(Pos('5', T[0]) > 0);
  Assert.IsTrue(Pos('caja', T[0]) > 0);
end;

procedure TPruebasTransferenciasPuro.TextoFaltaVerificacionesNombraLasQueFaltan;
var
  T: TArray<string>;
begin
  T := TextosQueFaltan([cdVerificacionesCompletas], 3, 0, ['unicos']);
  Assert.AreEqual(1, Length(T));
  Assert.IsTrue(Pos('copias', T[0]) = 0);
  Assert.IsTrue(Pos('presillas', T[0]) > 0, 'nombra la de expedientes completos');
end;

{ TPruebasTransferenciasDatosBD }

procedure TPruebasTransferenciasDatosBD.Preparar;
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

procedure TPruebasTransferenciasDatosBD.Limpiar;
begin
  if FConn <> nil then
  try
    FConn.ExecSQL('DELETE FROM tb_SeriesDatos WHERE titulodoc = ''' + USUARIO + '''');
    FConn.ExecSQL('DELETE FROM cl_ArchivosGestion WHERE nombreArchivo = ''' + USUARIO + '''');
    FConn.ExecSQL('DELETE FROM prc_cronograma WHERE Anio BETWEEN 1990 AND 1999');
    FConn.ExecSQL('DELETE FROM prc_proceso WHERE CreadoPor = ''' + USUARIO + '''');
  finally
    FreeAndNil(FConn);
  end;
end;

function TPruebasTransferenciasDatosBD.Conectar: Boolean;
begin
  Result := FConn <> nil;
  if not Result then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
end;

function TPruebasTransferenciasDatosBD.Escalar(const Sql: string): Variant;
begin
  Result := FConn.ExecSQLScalar(Sql);
end;

{ Unidad suelta (sin documento real en tb_SeriesDatos) retenida por el proceso. }
procedure TPruebasTransferenciasDatosBD.Unidad(IdProceso: Integer; const Subs, Cod: string);
begin
  FConn.ExecSQL('INSERT INTO prc_bloqueo (IdEstructura, id, codsubs, Codigodoc, fecha, ' +
    'version, IdProceso) VALUES (''ZZ.T'', 900, :s, :c, ''2018-01-01'', ''1'', :p)',
    [Subs, Cod, IdProceso]);
  FConn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, Codigodoc, ' +
    'fecha, version, Activa) VALUES (:p, ''ZZ.T'', 900, :s, :c, ''2018-01-01'', ''1'', 1)',
    [IdProceso, Subs, Cod]);
end;

function NodoDePrueba(Conn: TFDConnection): TClaveNodo;
begin
  Result.IdEstructura := VarToStr(Conn.ExecSQLScalar(
    'SELECT TOP 1 IdEstructura FROM tb_tree ORDER BY IdEstructura, id'));
  Result.Id := Integer(Conn.ExecSQLScalar(
    'SELECT TOP 1 id FROM tb_tree ORDER BY IdEstructura, id'));
end;

procedure TPruebasTransferenciasDatosBD.ArchivoDePrueba(Cod, Tipo: Integer);
begin
  FConn.ExecSQL('DELETE FROM cl_ArchivosGestion WHERE Cod = :c', [Cod]);
  FConn.ExecSQL('INSERT INTO cl_ArchivosGestion (Cod, nombreArchivo, Tipo, Idresp) ' +
    'VALUES (:c, :n, :t, 1)', [Cod, USUARIO, Tipo]);
end;

{ Transferencia con una unidad por caja, entregada: lista para la recepcion (paso 5). }
function TPruebasTransferenciasDatosBD.TransferenciaEnPaso5(Cajas: Integer;
  Reales: Boolean): TProcesoRef;
var
  Faltan: TArray<string>;
  A: TAutorizacion;
  V: TVerificacion;
  I: Integer;
begin
  Result := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);
  for I := 1 to Cajas do
    if Reales then
      UnidadReal(Result.IdProceso, I)
    else
      Unidad(Result.IdProceso, 'S1', 'D' + IntToStr(I));
  AvanzarTransferencia(FConn, Result.IdProceso, 1, USUARIO, Faltan);
  A.Organo := ocCentral;
  A.NumActa := '7';
  A.NumAcuerdo := '3';
  A.Fecha := Date - 1;
  GuardarAutorizacion(FConn, Result.IdProceso, A, USUARIO);
  AvanzarTransferencia(FConn, Result.IdProceso, 2, USUARIO, Faltan);
  NumerarCajas(FConn, Result.IdProceso, 1);
  for V in VERIFICACIONES do
    MarcarVerificacion(FConn, Result.IdProceso, V.Codigo, True);
  AvanzarTransferencia(FConn, Result.IdProceso, 3, USUARIO, Faltan);
  RegistrarEntregaTransferencia(FConn, Result.IdProceso, USUARIO, 'R. Perez', Date - 1);
end;

{ Documento de verdad en tb_SeriesDatos (en la primera subserie del arbol, archivo de
  gestion 2) retenido por el proceso: PF3-<N>. }
procedure TPruebasTransferenciasDatosBD.UnidadReal(IdProceso, N: Integer);
var
  Cod: string;
begin
  Cod := 'PF3-' + IntToStr(N);
  FConn.ExecSQL('DELETE FROM tb_SeriesDatos WHERE Codigodoc = :c AND titulodoc = :t',
    [Cod, USUARIO]);
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc, Archivo) SELECT TOP 1 IdEstructura, id, codsubs, ''2018-01-01'', ' +
    '''1'', :c, :t, 2 FROM tb_Serietree ORDER BY IdEstructura, id', [Cod, USUARIO],
    [ftString, ftString]);
  FConn.ExecSQL('INSERT INTO prc_bloqueo (IdEstructura, id, codsubs, Codigodoc, fecha, ' +
    'version, IdProceso) SELECT TOP 1 IdEstructura, id, codsubs, :c, ''2018-01-01'', ''1'', :p ' +
    'FROM tb_Serietree ORDER BY IdEstructura, id', [Cod, IdProceso], [ftString, ftInteger]);
  FConn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, Codigodoc, ' +
    'fecha, version, Activa) SELECT TOP 1 :p, IdEstructura, id, codsubs, :c, ''2018-01-01'', ' +
    '''1'', 1 FROM tb_Serietree ORDER BY IdEstructura, id', [IdProceso, Cod],
    [ftInteger, ftString]);
end;

function TPruebasTransferenciasDatosBD.DocCampo(N: Integer; const Campo: string): string;
begin
  Result := Trim(VarToStr(Escalar('SELECT ' + Campo + ' FROM tb_SeriesDatos WHERE Codigodoc = ' +
    QuotedStr('PF3-' + IntToStr(N)) + ' AND titulodoc = ' + QuotedStr(USUARIO))));
end;

{ Transferencia con documentos reales ya recibida (paso 6) en el archivo central 9990:
  las ultimas Faltantes cajas son faltantes y las demas, recibidas. }
function TPruebasTransferenciasDatosBD.TransferenciaEnPaso6(Cajas,
  Faltantes: Integer): TProcesoRef;
var
  I: Integer;
begin
  ArchivoDePrueba(9990, 1);
  Result := TransferenciaEnPaso5(Cajas, True);
  for I := 1 to Cajas do
    if I > Cajas - Faltantes then
      MarcarCajaFaltante(FConn, Result.IdProceso, I, USUARIO, 'Falta', Date)
    else
      MarcarCajaRecibida(FConn, Result.IdProceso, I, '');
  RegistrarRecepcionTransferencia(FConn, Result.IdProceso, USUARIO, 'Ana', '2026-0001', Date, 9990);
end;

procedure TPruebasTransferenciasDatosBD.CrearTransferenciaGuardaPrevistaYEnlazaCronograma;
var
  N: TClaveNodo;
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  ProgramarTransferencia(FConn, N, 1990, EncodeDate(1990, 11, 20));
  R := CrearTransferencia(FConn, N, USUARIO, 1990, EncodeDate(1990, 11, 20));
  Assert.AreEqual('T-1990-01', R.Numero);
  Assert.AreEqual(R.IdProceso, Integer(Escalar('SELECT IdProceso FROM prc_cronograma WHERE ' +
    'Anio = 1990 AND IdNodo = ' + IntToStr(N.Id))), 'enlaza con su cronograma');
  Assert.IsFalse(VarIsNull(Escalar('SELECT FPrevista FROM prc_transferencia WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasTransferenciasDatosBD.NumerarCajasSinHuerfanasYEsIdempotente;
var
  R: TProcesoRef;
  I: Integer;
begin
  if not Conectar then Exit;
  R := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);
  for I := 1 to 5 do
    Unidad(R.IdProceso, 'S1', 'D' + IntToStr(I));
  NumerarCajas(FConn, R.IdProceso, 2);
  Assert.AreEqual(3, Integer(Escalar('SELECT COUNT(*) FROM prc_caja WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad WHERE Caja IS NULL ' +
    'AND IdProceso = ' + IntToStr(R.IdProceso))), 'toda unidad tiene caja');
  NumerarCajas(FConn, R.IdProceso, 2);
  Assert.AreEqual(3, Integer(Escalar('SELECT COUNT(*) FROM prc_caja WHERE IdProceso = ' +
    IntToStr(R.IdProceso))), 'idempotente');
  // con capacidad mayor se reconstruye: ya no quedan cajas de mas
  NumerarCajas(FConn, R.IdProceso, 10);
  Assert.AreEqual(1, Integer(Escalar('SELECT COUNT(*) FROM prc_caja WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasTransferenciasDatosBD.VerificacionesSeMarcanYSeDesmarcan;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);
  MarcarVerificacion(FConn, R.IdProceso, 'unicos', True);
  MarcarVerificacion(FConn, R.IdProceso, 'completos', True);
  Assert.AreEqual(2, Length(VerificacionesMarcadas(FConn, R.IdProceso)));
  MarcarVerificacion(FConn, R.IdProceso, 'unicos', False);
  Assert.AreEqual(1, Length(VerificacionesMarcadas(FConn, R.IdProceso)));
end;

procedure TPruebasTransferenciasDatosBD.CondicionesFaltanSinAutorizacionNiCajas;
var
  R: TProcesoRef;
  Faltan: TArray<string>;
  C: TCondiciones;
begin
  if not Conectar then Exit;
  R := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);
  Unidad(R.IdProceso, 'S1', 'D1');
  C := CondicionesCumplidas(FConn, R.IdProceso, Faltan);
  Assert.IsFalse(cdAutorizado in C);
  Assert.IsFalse(cdVerificacionesCompletas in C);
  Assert.IsTrue(cdSinBloqueos in C);
  Assert.IsTrue(Length(Faltan) >= 2);
end;

procedure TPruebasTransferenciasDatosBD.AvanzaHastaLaEntrega;
var
  R: TProcesoRef;
  Faltan: TArray<string>;
  A: TAutorizacion;
  V: TVerificacion;
begin
  if not Conectar then Exit;
  R := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);
  Unidad(R.IdProceso, 'S1', 'D1');
  Assert.IsTrue(AvanzarTransferencia(FConn, R.IdProceso, 1, USUARIO, Faltan));
  A.Organo := ocCentral;
  A.NumActa := '7';
  A.NumAcuerdo := '3';
  A.Fecha := Date - 1;
  GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
  Assert.IsTrue(AvanzarTransferencia(FConn, R.IdProceso, 2, USUARIO, Faltan));
  NumerarCajas(FConn, R.IdProceso, 20);
  for V in VERIFICACIONES do
    MarcarVerificacion(FConn, R.IdProceso, V.Codigo, True);
  Assert.IsTrue(AvanzarTransferencia(FConn, R.IdProceso, 3, USUARIO, Faltan));
  Assert.AreEqual(4, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasTransferenciasDatosBD.NoAvanzaSinVerificacionesCompletas;
var
  R: TProcesoRef;
  Faltan: TArray<string>;
  A: TAutorizacion;
begin
  if not Conectar then Exit;
  R := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);
  Unidad(R.IdProceso, 'S1', 'D1');
  Assert.IsTrue(AvanzarTransferencia(FConn, R.IdProceso, 1, USUARIO, Faltan));
  A.Organo := ocCentral;
  A.NumActa := '7';
  A.NumAcuerdo := '3';
  A.Fecha := Date - 1;
  GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
  Assert.IsTrue(AvanzarTransferencia(FConn, R.IdProceso, 2, USUARIO, Faltan));
  Assert.IsFalse(AvanzarTransferencia(FConn, R.IdProceso, 3, USUARIO, Faltan));
  Assert.IsTrue(Length(Faltan) >= 1, 'dice que falta');
  Assert.AreEqual(3, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasTransferenciasDatosBD.EntregaGuardaFechaYPasaAlPasoCinco;
var
  R: TProcesoRef;
  Faltan: TArray<string>;
  A: TAutorizacion;
  V: TVerificacion;
begin
  if not Conectar then Exit;
  R := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);
  Unidad(R.IdProceso, 'S1', 'D1');
  AvanzarTransferencia(FConn, R.IdProceso, 1, USUARIO, Faltan);
  A.Organo := ocCentral;
  A.NumActa := '7';
  A.NumAcuerdo := '3';
  A.Fecha := Date - 1;
  GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
  AvanzarTransferencia(FConn, R.IdProceso, 2, USUARIO, Faltan);
  NumerarCajas(FConn, R.IdProceso, 20);
  for V in VERIFICACIONES do
    MarcarVerificacion(FConn, R.IdProceso, V.Codigo, True);
  AvanzarTransferencia(FConn, R.IdProceso, 3, USUARIO, Faltan);
  Assert.IsTrue(RegistrarEntregaTransferencia(FConn, R.IdProceso, USUARIO, 'R. Perez', Date));
  Assert.AreEqual(5, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.AreEqual('R. Perez', VarToStr(Escalar('SELECT EntregadoPor FROM prc_transferencia ' +
    'WHERE IdProceso = ' + IntToStr(R.IdProceso))));
  Assert.IsFalse(RegistrarEntregaTransferencia(FConn, R.IdProceso, USUARIO, 'R. Perez', Date),
    'entregar dos veces se rechaza');
end;

procedure TPruebasTransferenciasDatosBD.ListarPorAnio;
var
  N: TClaveNodo;
  R: TProcesoRef;
  Filas: TArray<TTransferenciaFila>;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  R := CrearTransferencia(FConn, N, USUARIO, 1991, 0);
  CrearTransferencia(FConn, N, USUARIO, 1992, 0);
  Filas := ListarTransferencias(FConn, [N], 1991, 50);
  Assert.IsTrue(Length(Filas) >= 1);
  Assert.AreEqual(R.IdProceso, Filas[0].IdProceso);
  Assert.AreEqual('Propuesta', Filas[0].Estado);
end;

procedure TPruebasTransferenciasDatosBD.CronogramaAtrasado;
var
  N: TClaveNodo;
  F: TArray<TCronogramaFila>;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  ProgramarTransferencia(FConn, N, 1993, EncodeDate(1993, 6, 1));
  F := ListarCronograma(FConn, [N], 1993, Date);
  Assert.AreEqual(1, Length(F));
  Assert.IsTrue(F[0].Estado = ecAtrasada);
  // reprogramar actualiza, no duplica
  ProgramarTransferencia(FConn, N, 1993, Date + 30);
  F := ListarCronograma(FConn, [N], 1993, Date);
  Assert.AreEqual(1, Length(F));
  Assert.IsTrue(F[0].Estado = ecProgramada);
end;

procedure TPruebasTransferenciasDatosBD.RelacionTieneUnaLineaPorCaja;
var
  R: TProcesoRef;
  L: TArray<TLineaRelacion>;
  I: Integer;
begin
  if not Conectar then Exit;
  R := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);
  for I := 1 to 4 do
    Unidad(R.IdProceso, 'S1', 'D' + IntToStr(I));
  NumerarCajas(FConn, R.IdProceso, 2);
  L := RelacionDeEntrega(FConn, R.IdProceso);
  Assert.AreEqual(2, Length(L));
  Assert.AreEqual(1, L[0].Caja);
  Assert.AreEqual(2, L[0].Unidades);
end;

procedure TPruebasTransferenciasDatosBD.GruposAgregadosSumanLasUnidades;
var
  R: TProcesoRef;
  G: TArray<TGrupoAgregado>;
  I, Suma: Integer;
begin
  if not Conectar then Exit;
  R := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);
  Unidad(R.IdProceso, 'S1', 'D1');
  Unidad(R.IdProceso, 'S1', 'D2');
  Unidad(R.IdProceso, 'S2', 'D3');
  G := GruposDeLaTransferencia(FConn, R.IdProceso);
  Assert.AreEqual(2, Length(G), 'un grupo por subserie');
  Suma := 0;
  for I := 0 to High(G) do
    Inc(Suma, G[I].Unidades);
  Assert.AreEqual(3, Suma);
end;

procedure TPruebasTransferenciasDatosBD.ArchivosCentralesSoloDevuelveLosDeTipoCentral;
var
  L: TArray<TArchivoCentral>;
  C: TArchivoCentral;
  HayCentral, HayGestion: Boolean;
begin
  if not Conectar then Exit;
  ArchivoDePrueba(9990, 1);  // Central
  ArchivoDePrueba(9991, 2);  // Gestion
  L := ListarArchivosCentrales(FConn);
  HayCentral := False;
  HayGestion := False;
  for C in L do
  begin
    if C.Cod = 9990 then HayCentral := True;
    if C.Cod = 9991 then HayGestion := True;
  end;
  Assert.IsTrue(HayCentral, 'falta el archivo central');
  Assert.IsFalse(HayGestion, 'no debe listar archivos de gestion');
end;

procedure TPruebasTransferenciasDatosBD.CajasDeTransferenciaLeeUnidadesYEstadoPendiente;
var
  R: TProcesoRef;
  Cajas: TArray<TCajaFila>;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso5(2);
  Cajas := CajasDeTransferencia(FConn, R.IdProceso);
  Assert.AreEqual(2, Length(Cajas));
  Assert.AreEqual(1, Cajas[0].Caja);
  Assert.AreEqual(2, Cajas[1].Caja);
  Assert.AreEqual(1, Cajas[0].Unidades);
  Assert.AreEqual(Ord(ecPendiente), Ord(Cajas[0].Estado), 'Estado NULL = pendiente');
end;

procedure TPruebasTransferenciasDatosBD.MarcarCajaRecibidaYCuarentenaYResolver;
var
  R: TProcesoRef;
  Cajas: TArray<TCajaFila>;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso5(2);
  MarcarCajaRecibida(FConn, R.IdProceso, 1, 'Buen estado');
  MarcarCajaCuarentena(FConn, R.IdProceso, 2, 'Humedad');
  Cajas := CajasDeTransferencia(FConn, R.IdProceso);
  Assert.AreEqual(Ord(ecRecibida), Ord(Cajas[0].Estado));
  Assert.AreEqual('Buen estado', Cajas[0].Conservacion);
  Assert.AreEqual(Ord(ecCuarentena), Ord(Cajas[1].Estado));
  ResolverCuarentena(FConn, R.IdProceso, 2);
  Cajas := CajasDeTransferencia(FConn, R.IdProceso);
  Assert.AreEqual(Ord(ecRecibida), Ord(Cajas[1].Estado));
  // resolver una caja que no esta en cuarentena no la cambia
  ResolverCuarentena(FConn, R.IdProceso, 1);
  Cajas := CajasDeTransferencia(FConn, R.IdProceso);
  Assert.AreEqual(Ord(ecRecibida), Ord(Cajas[0].Estado));
end;

procedure TPruebasTransferenciasDatosBD.MarcarCajaFaltanteCreaIncidenciaYSacaLasUnidades;
var
  R: TProcesoRef;
  Cajas: TArray<TCajaFila>;
  Id: string;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso5(2);
  Id := IntToStr(R.IdProceso);
  MarcarCajaFaltante(FConn, R.IdProceso, 2, USUARIO, 'No llego la caja', EncodeDate(2026, 11, 1));
  Cajas := CajasDeTransferencia(FConn, R.IdProceso);
  Assert.AreEqual(Ord(ecFaltante), Ord(Cajas[1].Estado));
  Assert.AreEqual(1, Integer(Escalar('SELECT COUNT(*) FROM prc_incidencia WHERE IdProceso = ' + Id +
    ' AND Caja = 2 AND Tipo = ''FALTA'' AND Estado = ''A''')));
  Assert.AreEqual(EncodeDate(2026, 12, 1), TDateTime(Escalar(
    'SELECT FechaLimite FROM prc_incidencia WHERE IdProceso = ' + Id)), 0.0001);
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad WHERE IdProceso = ' + Id +
    ' AND Caja = 2 AND Activa = 1')), 'la unidad faltante sale de la transferencia');
  Assert.AreEqual(1, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' + Id)),
    'solo queda retenida la unidad de la caja 1');
end;

procedure TPruebasTransferenciasDatosBD.MarcarCajaFueraDelPasoCincoLanza;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := CrearTransferencia(FConn, NodoDePrueba(FConn), USUARIO, 1990, 0);  // paso 1
  Assert.WillRaise(
    procedure begin MarcarCajaRecibida(FConn, R.IdProceso, 1, ''); end,
    EArgumentException);
end;

procedure TPruebasTransferenciasDatosBD.RecepcionRechazaDestinoInexistenteCajasPendientesYCuarentena;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  ArchivoDePrueba(9990, 1);
  R := TransferenciaEnPaso5(2);
  // sin decidir ninguna caja
  Assert.WillRaise(
    procedure begin RegistrarRecepcionTransferencia(FConn, R.IdProceso, USUARIO, 'Ana', '2026-0001', Date, 9990); end,
    EArgumentException);
  MarcarCajaRecibida(FConn, R.IdProceso, 1, '');
  MarcarCajaCuarentena(FConn, R.IdProceso, 2, 'Hongo');
  // una caja en cuarentena
  Assert.WillRaise(
    procedure begin RegistrarRecepcionTransferencia(FConn, R.IdProceso, USUARIO, 'Ana', '2026-0001', Date, 9990); end,
    EArgumentException);
  ResolverCuarentena(FConn, R.IdProceso, 2);
  // destino que no es un archivo central
  Assert.WillRaise(
    procedure begin RegistrarRecepcionTransferencia(FConn, R.IdProceso, USUARIO, 'Ana', '2026-0001', Date, 9999); end,
    EArgumentException);
  Assert.AreEqual(5, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))), 'sigue en el paso 5');
end;

procedure TPruebasTransferenciasDatosBD.RecepcionConTodoDecididoAvanzaYGuardaDestino;
var
  R: TProcesoRef;
  Id: string;
begin
  if not Conectar then Exit;
  ArchivoDePrueba(9990, 1);
  R := TransferenciaEnPaso5(2);
  Id := IntToStr(R.IdProceso);
  MarcarCajaRecibida(FConn, R.IdProceso, 1, '');
  MarcarCajaFaltante(FConn, R.IdProceso, 2, USUARIO, 'Falta', Date);
  Assert.IsTrue(RegistrarRecepcionTransferencia(FConn, R.IdProceso, USUARIO, 'Ana', '2026-0001', Date, 9990));
  Assert.AreEqual(6, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' + Id)));
  Assert.AreEqual(9990, Integer(Escalar('SELECT IdArchivoDestino FROM prc_transferencia WHERE IdProceso = ' + Id)));
  Assert.AreEqual('2026-0001', VarToStr(Escalar('SELECT NumRegistroEntrada FROM prc_transferencia WHERE IdProceso = ' + Id)));
  Assert.AreEqual('Ana', VarToStr(Escalar('SELECT RecibidoPor FROM prc_transferencia WHERE IdProceso = ' + Id)));
  Assert.IsFalse(RegistrarRecepcionTransferencia(FConn, R.IdProceso, USUARIO, 'Ana', '2026-0001', Date, 9990),
    'recibir dos veces se rechaza');
end;

procedure TPruebasTransferenciasDatosBD.UbicacionDeCajaInvalidaLanzaYNoCambiaLaCaja;
var
  R: TProcesoRef;
  Cajas: TArray<TCajaFila>;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso6(1, 0);
  Assert.WillRaise(
    procedure
    begin
      RegistrarUbicacionCaja(FConn, R.IdProceso, 1, '01', StringOfChar('g', 21), '3');
    end, EArgumentException);
  Cajas := CajasDeTransferencia(FConn, R.IdProceso);
  Assert.AreEqual('', Cajas[0].Gaveta, 'no se guardo nada');
end;

procedure TPruebasTransferenciasDatosBD.UbicacionDeCajaFaltanteOFueraDelPasoSeisLanza;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso6(2, 1);  // la caja 2 es faltante
  Assert.WillRaise(
    procedure
    begin
      RegistrarUbicacionCaja(FConn, R.IdProceso, 2, '01', '02', '3');
    end, EArgumentException);
  FConn.ExecSQL('UPDATE prc_proceso SET Paso = 5 WHERE IdProceso = ' + IntToStr(R.IdProceso));
  Assert.WillRaise(
    procedure
    begin
      RegistrarUbicacionCaja(FConn, R.IdProceso, 1, '01', '02', '3');
    end, EArgumentException);
end;

procedure TPruebasTransferenciasDatosBD.CerrarSinUbicarTodasLasCajasLanzaYNoCambiaNada;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso6(2, 0);
  RegistrarUbicacionCaja(FConn, R.IdProceso, 1, '01', '02', '3');
  Assert.WillRaise(
    procedure
    begin
      CerrarTransferencia(FConn, R.IdProceso, USUARIO);
    end, EArgumentException);
  Assert.AreEqual('2', DocCampo(1, 'Archivo'), 'el documento sigue en el origen');
  Assert.AreEqual(6, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasTransferenciasDatosBD.CerrarTraspasaLosDocumentosYFinaliza;
var
  R: TProcesoRef;
  Id: string;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso6(3, 1);  // caja 3 faltante
  Id := IntToStr(R.IdProceso);
  RegistrarUbicacionCaja(FConn, R.IdProceso, 1, '01', '02', '3');
  RegistrarUbicacionCaja(FConn, R.IdProceso, 2, '04', '05', '6');
  Assert.IsTrue(CerrarTransferencia(FConn, R.IdProceso, USUARIO));
  Assert.AreEqual('9990', DocCampo(1, 'Archivo'));
  Assert.AreEqual('01', DocCampo(1, 'deposito'));
  Assert.AreEqual('02', DocCampo(1, 'gaveta'));
  Assert.AreEqual('3', DocCampo(1, 'posicion'));
  Assert.AreEqual('9990', DocCampo(2, 'Archivo'));
  Assert.AreEqual('04', DocCampo(2, 'deposito'));
  Assert.AreEqual('6', DocCampo(2, 'posicion'));
  Assert.AreEqual('2', DocCampo(3, 'Archivo'), 'el de la caja faltante sigue en el origen');
  Assert.AreEqual('', DocCampo(3, 'deposito'));
  Assert.AreEqual('F', Trim(VarToStr(Escalar('SELECT Estado FROM prc_proceso WHERE IdProceso = ' + Id))));
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' + Id)));
  Assert.IsTrue(VarToStr(Escalar('SELECT Ubicacion FROM prc_transferencia WHERE IdProceso = ' + Id)) <> '',
    'queda un resumen de la ubicacion');
end;

procedure TPruebasTransferenciasDatosBD.CerrarDosVecesLaSegundaDevuelveFalse;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso6(1, 0);
  RegistrarUbicacionCaja(FConn, R.IdProceso, 1, '01', '02', '3');
  Assert.IsTrue(CerrarTransferencia(FConn, R.IdProceso, USUARIO));
  FConn.ExecSQL('UPDATE tb_SeriesDatos SET deposito = ''ZZ'' WHERE Codigodoc = ''PF3-1'' AND titulodoc = ''' + USUARIO + '''');
  Assert.IsFalse(CerrarTransferencia(FConn, R.IdProceso, USUARIO));
  Assert.AreEqual('ZZ', DocCampo(1, 'deposito'), 'la segunda llamada no repite el traspaso');
end;

procedure TPruebasTransferenciasDatosBD.CerrarSinArchivoDestinoLanzaYNoCambiaNada;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso6(1, 0);
  RegistrarUbicacionCaja(FConn, R.IdProceso, 1, '01', '02', '3');
  FConn.ExecSQL('UPDATE prc_transferencia SET IdArchivoDestino = NULL WHERE IdProceso = ' +
    IntToStr(R.IdProceso));
  Assert.WillRaise(
    procedure
    begin
      CerrarTransferencia(FConn, R.IdProceso, USUARIO);
    end, EArgumentException);
  Assert.AreEqual('2', DocCampo(1, 'Archivo'));
  Assert.AreEqual(6, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasTransferenciasDatosBD.CerrarConElPasoCambiadoDevuelveFalse;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := TransferenciaEnPaso6(1, 0);
  RegistrarUbicacionCaja(FConn, R.IdProceso, 1, '01', '02', '3');
  FConn.ExecSQL('UPDATE prc_proceso SET Paso = 5 WHERE IdProceso = ' + IntToStr(R.IdProceso));
  Assert.IsFalse(CerrarTransferencia(FConn, R.IdProceso, USUARIO));
  Assert.AreEqual('2', DocCampo(1, 'Archivo'));
end;

end.
