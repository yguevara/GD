unit UPruebasProcesosDatos;

{ Acceso a datos de los procesos archivisticos. Las pruebas de codigos son puras;
  las de base usan ARCHIGENIO_TEST_DB (se omiten sin ella) y limpian sus filas
  (CreadoPor = '__prueba__', anios 1990 a 1999). }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasProcesosCodigos = class
  public
    [Test]
    procedure CodigoDeTipoYVuelta;
    [Test]
    procedure TipoDesdeCodigoInvalidoLanza;
    [Test]
    procedure CodigoDeOrgano;
  end;

  [TestFixture]
  TPruebasProcesosDatosBD = class
  private
    FConn: TFDConnection;
    function Conectar: Boolean;
    function Escalar(const Sql: string): Variant;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure CreaProcesoConNumero;
    [Test]
    procedure ConsecutivoAvanzaPorTipoYReiniciaCadaAnio;
    [Test]
    procedure AvanzaPasoYRegistraEvento;
    [Test]
    procedure NoAvanzaSiFaltanCondiciones;
    [Test]
    procedure DosAvancesSimultaneosSoloUnoGana;
    [Test]
    procedure FinalizaEnElUltimoPaso;
    [Test]
    procedure CancelarDepuracionEjecutadaSeRechaza;
    [Test]
    procedure CancelarTransferenciaRecibidaSeRechaza;
    [Test]
    procedure AutorizacionInvalidaLanza;
    [Test]
    procedure AutorizacionSeReemplaza;
    [Test]
    procedure UnidadBloqueadaNoSeAgrega;
    [Test]
    procedure UnidadSeLiberaAlCancelarYAlFinalizar;
    [Test]
    procedure MismoIdEnOtroNodoNoSeBloquea;
    [Test]
    procedure MismoCodigoEnOtraSubserieNoSeBloquea;
    [Test]
    procedure BloqueosDelNodoSeBuscaPorClaveNormalizada;
    [Test]
    procedure ContarPorEstadoSumaBien;
  end;

implementation

uses
  System.SysUtils, System.Variants, System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, Data.DB, UAlcance, UProceso, UAutorizacion, UCandados,
  UEsquemaProcesos, UProcesosDatos;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  USUARIO = '__prueba__';

{ TPruebasProcesosCodigos }

procedure TPruebasProcesosCodigos.CodigoDeTipoYVuelta;
var
  T: TTipoProceso;
begin
  Assert.AreEqual('P', CodigoTipo(tpPrestamo));
  Assert.AreEqual('T', CodigoTipo(tpTransferencia));
  Assert.AreEqual('D', CodigoTipo(tpDepuracion));
  for T := Low(TTipoProceso) to High(TTipoProceso) do
    Assert.IsTrue(TipoDesdeCodigo(CodigoTipo(T)) = T);
end;

procedure TPruebasProcesosCodigos.TipoDesdeCodigoInvalidoLanza;
begin
  Assert.WillRaise(
    procedure
    begin
      TipoDesdeCodigo('Z');
    end, EArgumentException);
end;

procedure TPruebasProcesosCodigos.CodigoDeOrgano;
begin
  Assert.AreEqual('C', CodigoOrgano(ocCentral));
  Assert.AreEqual('M', CodigoOrgano(ocMunicipal));
  Assert.AreEqual('P', CodigoOrgano(ocProvincial));
  Assert.AreEqual('N', CodigoOrgano(ocNacional));
end;

{ TPruebasProcesosDatosBD }

procedure TPruebasProcesosDatosBD.Preparar;
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

procedure TPruebasProcesosDatosBD.Limpiar;
begin
  if FConn <> nil then
  try
    FConn.ExecSQL('DELETE FROM prc_proceso WHERE CreadoPor = ''' + USUARIO + '''');
  finally
    FreeAndNil(FConn);
  end;
end;

function TPruebasProcesosDatosBD.Conectar: Boolean;
begin
  Result := FConn <> nil;
  if not Result then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
end;

function TPruebasProcesosDatosBD.Escalar(const Sql: string): Variant;
begin
  Result := FConn.ExecSQLScalar(Sql);
end;

{ Nodo real de la base de pruebas (el proceso tiene clave foranea a tb_tree). }
function NodoDePrueba(Conn: TFDConnection): TClaveNodo;
begin
  Result.IdEstructura := VarToStr(Conn.ExecSQLScalar(
    'SELECT TOP 1 IdEstructura FROM tb_tree ORDER BY IdEstructura, id'));
  Result.Id := Integer(Conn.ExecSQLScalar(
    'SELECT TOP 1 id FROM tb_tree ORDER BY IdEstructura, id'));
end;

function UnidadPrueba(const IdEstr: string; Id: Integer; const Cod: string): TUnidadDoc;
begin
  Result.IdEstructura := IdEstr;
  Result.Id := Id;
  Result.CodSubs := 'S1';
  Result.CodigoDoc := Cod;
  Result.Fecha := EncodeDate(2020, 5, 17);
  Result.Version := '1';
end;

procedure TPruebasProcesosDatosBD.CreaProcesoConNumero;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := CrearProceso(FConn, tpPrestamo, NodoDePrueba(FConn), USUARIO, 1990);
  Assert.AreEqual('1990-0001', R.Numero);
  Assert.IsTrue(R.IdProceso > 0);
  Assert.AreEqual('C', VarToStr(Escalar('SELECT Estado FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.AreEqual(1, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.AreEqual(1, Integer(Escalar('SELECT COUNT(*) FROM prc_evento WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasProcesosDatosBD.ConsecutivoAvanzaPorTipoYReiniciaCadaAnio;
var
  N: TClaveNodo;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  Assert.AreEqual('1990-0001', CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990).Numero);
  Assert.AreEqual('1990-0002', CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990).Numero);
  Assert.AreEqual('T-1990-01', CrearProceso(FConn, tpTransferencia, N, USUARIO, 1990).Numero);
  Assert.AreEqual('1991-0001', CrearProceso(FConn, tpPrestamo, N, USUARIO, 1991).Numero);
end;

procedure TPruebasProcesosDatosBD.AvanzaPasoYRegistraEvento;
var
  R: TProcesoRef;
  Faltan: TCondiciones;
begin
  if not Conectar then Exit;
  R := CrearProceso(FConn, tpPrestamo, NodoDePrueba(FConn), USUARIO, 1990);
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 1, [cdSinBloqueos], USUARIO, Faltan));
  Assert.AreEqual(2, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.AreEqual(2, Integer(Escalar('SELECT COUNT(*) FROM prc_evento WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasProcesosDatosBD.NoAvanzaSiFaltanCondiciones;
var
  R: TProcesoRef;
  Faltan: TCondiciones;
begin
  if not Conectar then Exit;
  R := CrearProceso(FConn, tpTransferencia, NodoDePrueba(FConn), USUARIO, 1990);
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 1, [cdSinBloqueos], USUARIO, Faltan));
  Assert.IsFalse(AvanzarPaso(FConn, R.IdProceso, 2, [], USUARIO, Faltan));
  Assert.IsTrue(Faltan = [cdAutorizado]);
  Assert.AreEqual(2, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasProcesosDatosBD.DosAvancesSimultaneosSoloUnoGana;
var
  R: TProcesoRef;
  Faltan: TCondiciones;
begin
  if not Conectar then Exit;
  R := CrearProceso(FConn, tpPrestamo, NodoDePrueba(FConn), USUARIO, 1990);
  // Los dos usuarios leyeron el paso 1; el segundo ya no puede avanzar desde ahi.
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 1, [cdSinBloqueos], USUARIO, Faltan));
  Assert.IsFalse(AvanzarPaso(FConn, R.IdProceso, 1, [cdSinBloqueos], USUARIO, Faltan));
  Assert.AreEqual(2, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasProcesosDatosBD.FinalizaEnElUltimoPaso;
var
  R: TProcesoRef;
  Faltan: TCondiciones;
begin
  if not Conectar then Exit;
  R := CrearProceso(FConn, tpPrestamo, NodoDePrueba(FConn), USUARIO, 1990);
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 1, [cdSinBloqueos], USUARIO, Faltan));
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 2, [], USUARIO, Faltan));
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 3, [], USUARIO, Faltan));
  Assert.AreEqual('F', VarToStr(Escalar('SELECT Estado FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.IsFalse(VarIsNull(Escalar('SELECT Cerrado FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasProcesosDatosBD.CancelarDepuracionEjecutadaSeRechaza;
var
  R: TProcesoRef;
  Faltan: TCondiciones;
begin
  if not Conectar then Exit;
  R := CrearProceso(FConn, tpDepuracion, NodoDePrueba(FConn), USUARIO, 1990);
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 1, [cdSinBloqueos], USUARIO, Faltan));
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 2, [cdAutorizado], USUARIO, Faltan));
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 3,
    [cdMuestraDefinida, cdTestigosMinimos, cdActaCompleta], USUARIO, Faltan));
  Assert.IsFalse(CancelarProceso(FConn, R.IdProceso, USUARIO, 'prueba'));
  Assert.AreEqual('C', VarToStr(Escalar('SELECT Estado FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasProcesosDatosBD.CancelarTransferenciaRecibidaSeRechaza;
var
  R: TProcesoRef;
  Faltan: TCondiciones;
begin
  if not Conectar then Exit;
  R := CrearProceso(FConn, tpTransferencia, NodoDePrueba(FConn), USUARIO, 1990);
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 1, [cdSinBloqueos], USUARIO, Faltan));
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 2, [cdAutorizado], USUARIO, Faltan));
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 3,
    [cdAutorizado, cdSinBloqueos, cdVerificacionesCompletas], USUARIO, Faltan));
  Assert.IsTrue(AvanzarPaso(FConn, R.IdProceso, 4, [], USUARIO, Faltan));
  Assert.IsFalse(CancelarProceso(FConn, R.IdProceso, USUARIO, 'prueba'));
end;

procedure TPruebasProcesosDatosBD.AutorizacionInvalidaLanza;
var
  R: TProcesoRef;
  A: TAutorizacion;
begin
  if not Conectar then Exit;
  R := CrearProceso(FConn, tpDepuracion, NodoDePrueba(FConn), USUARIO, 1990);
  A.Organo := ocProvincial;
  A.NumActa := '';
  A.NumAcuerdo := '9';
  A.Fecha := Date - 1;
  Assert.WillRaise(
    procedure
    begin
      GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
    end, EAutorizacionInvalida);
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_autorizacion WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasProcesosDatosBD.AutorizacionSeReemplaza;
var
  R: TProcesoRef;
  A: TAutorizacion;
begin
  if not Conectar then Exit;
  R := CrearProceso(FConn, tpDepuracion, NodoDePrueba(FConn), USUARIO, 1990);
  A.Organo := ocProvincial;
  A.NumActa := '14';
  A.NumAcuerdo := '9';
  A.Fecha := Date - 1;
  GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
  A.NumActa := '15';
  GuardarAutorizacion(FConn, R.IdProceso, A, USUARIO);
  Assert.AreEqual(1, Integer(Escalar('SELECT COUNT(*) FROM prc_autorizacion WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.AreEqual('15', VarToStr(Escalar('SELECT NumActa FROM prc_autorizacion WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasProcesosDatosBD.UnidadBloqueadaNoSeAgrega;
var
  N: TClaveNodo;
  P1, P2: TProcesoRef;
  Motivo: string;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  P1 := CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990);
  P2 := CrearProceso(FConn, tpTransferencia, N, USUARIO, 1990);
  Assert.IsTrue(AgregarUnidad(FConn, P1.IdProceso, UnidadPrueba('ZZ.1', 160, 'D1'), Motivo));
  Assert.IsFalse(AgregarUnidad(FConn, P2.IdProceso, UnidadPrueba('ZZ.1', 160, 'D1'), Motivo));
  Assert.AreEqual('En prestamo ' + P1.Numero, Motivo);
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad WHERE IdProceso = ' +
    IntToStr(P2.IdProceso))));
end;

procedure TPruebasProcesosDatosBD.UnidadSeLiberaAlCancelarYAlFinalizar;
var
  N: TClaveNodo;
  P1, P2: TProcesoRef;
  Motivo: string;
  Faltan: TCondiciones;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  P1 := CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990);
  P2 := CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990);
  Assert.IsTrue(AgregarUnidad(FConn, P1.IdProceso, UnidadPrueba('ZZ.2', 161, 'D1'), Motivo));
  Assert.IsTrue(CancelarProceso(FConn, P1.IdProceso, USUARIO, 'prueba'));
  Assert.IsTrue(AgregarUnidad(FConn, P2.IdProceso, UnidadPrueba('ZZ.2', 161, 'D1'), Motivo),
    'Al cancelar, el documento queda libre');
  Assert.IsTrue(AvanzarPaso(FConn, P2.IdProceso, 1, [cdSinBloqueos], USUARIO, Faltan));
  Assert.IsTrue(AvanzarPaso(FConn, P2.IdProceso, 2, [], USUARIO, Faltan));
  Assert.IsTrue(AvanzarPaso(FConn, P2.IdProceso, 3, [], USUARIO, Faltan));
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE IdProceso = ' +
    IntToStr(P2.IdProceso))), 'Al finalizar, el documento queda libre');
end;

procedure TPruebasProcesosDatosBD.MismoIdEnOtroNodoNoSeBloquea;
var
  N: TClaveNodo;
  P1, P2: TProcesoRef;
  Motivo: string;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  P1 := CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990);
  P2 := CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990);
  // El id 160 existe en varios nodos reales: solo el par (nodo, id) identifica.
  Assert.IsTrue(AgregarUnidad(FConn, P1.IdProceso, UnidadPrueba('ZZ.3.7', 160, 'D1'), Motivo));
  Assert.IsTrue(AgregarUnidad(FConn, P2.IdProceso, UnidadPrueba('ZZ.3.3', 160, 'D1'), Motivo));
end;

procedure TPruebasProcesosDatosBD.MismoCodigoEnOtraSubserieNoSeBloquea;
var
  N: TClaveNodo;
  P1, P2: TProcesoRef;
  Motivo: string;
  U1, U2: TUnidadDoc;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  P1 := CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990);
  P2 := CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990);
  U1 := UnidadPrueba('ZZ.5', 163, 'D1');
  U2 := U1;
  U2.CodSubs := 'S2';
  Assert.IsTrue(AgregarUnidad(FConn, P1.IdProceso, U1, Motivo));
  Assert.IsTrue(AgregarUnidad(FConn, P2.IdProceso, U2, Motivo),
    'Otra subserie del mismo nodo con igual codigo, fecha y version es otro documento');
end;

procedure TPruebasProcesosDatosBD.BloqueosDelNodoSeBuscaPorClaveNormalizada;
var
  N, Otro: TClaveNodo;
  P1: TProcesoRef;
  Motivo: string;
  Mapa: TDictionary<string, TBloqueo>;
  B: TBloqueo;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  P1 := CrearProceso(FConn, tpPrestamo, N, USUARIO, 1990);
  Assert.IsTrue(AgregarUnidad(FConn, P1.IdProceso, UnidadPrueba('ZZ.4', 162, 'D1'), Motivo));
  Otro.IdEstructura := 'ZZ.4';
  Otro.Id := 162;
  Mapa := BloqueosDelNodo(FConn, Otro);
  try
    // Se busca con una clave escrita distinto (minusculas y espacio final)
    Assert.IsTrue(Mapa.TryGetValue(ClaveUnidad(UnidadPrueba('zz.4 ', 162, 'D1')), B));
    Assert.AreEqual(P1.Numero, B.Numero);
    Assert.IsTrue(B.Tipo = tpPrestamo);
  finally
    Mapa.Free;
  end;
end;

procedure TPruebasProcesosDatosBD.ContarPorEstadoSumaBien;
var
  N: TClaveNodo;
  P1, P2: TProcesoRef;
  Faltan: TCondiciones;
  Cuentas: TArray<Integer>;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  P1 := CrearProceso(FConn, tpDepuracion, N, USUARIO, 1990);
  P2 := CrearProceso(FConn, tpDepuracion, N, USUARIO, 1990);
  CrearProceso(FConn, tpDepuracion, N, USUARIO, 1990);
  Assert.IsTrue(CancelarProceso(FConn, P1.IdProceso, USUARIO, 'prueba'));
  Assert.IsTrue(AvanzarPaso(FConn, P2.IdProceso, 1, [cdSinBloqueos], USUARIO, Faltan));
  Cuentas := ContarPorEstado(FConn, tpDepuracion, [N]);
  // Se cuentan tambien los procesos de otras corridas: solo se exige lo minimo.
  Assert.AreEqual(3, Length(Cuentas));
  Assert.IsTrue(Cuentas[0] >= 2, 'En curso');
  Assert.IsTrue(Cuentas[2] >= 1, 'Cancelados');
end;

end.
