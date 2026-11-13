unit UPruebasTransferenciasDatos;

{ Datos de la transferencia. La parte pura (SQL de vencidos, agrupacion en cajas,
  textos de lo que falta) se ejecuta siempre; las pruebas de base usan
  ARCHIGENIO_TEST_DB (se omiten sin ella) y limpian sus filas
  (CreadoPor = '__prueba__', anios 1990-1999). }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasTransferenciasPuro = class
  public
    [Test]
    procedure CondicionVencidoUsaFechaFinSoloSiNoEsAnterior;
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
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UAlcance,
  UProceso, UAutorizacion, UEsquemaProcesos, UProcesosDatos,
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

end.
