unit UPruebasTransferenciasReglas;

{ Reglas de la transferencia: vencimiento por anos en archivo de gestion,
  cronograma, verificaciones y reparto de los documentos en cajas. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasTransferenciasReglas = class
  public
    [Test]
    procedure VencidoCuandoPasanLosAnios;
    [Test]
    procedure VenceElMismoDiaDelAniversario;
    [Test]
    procedure NoVenceUnDiaAntes;
    [Test]
    procedure SinPlazoNuncaVence;
    [Test]
    procedure SinFechaNoVence;
    [Test]
    procedure FechaFinAnteriorAFechaSeIgnora;
    [Test]
    procedure FechaFinPosteriorManda;
    [Test]
    procedure FechaCorteRestaAniosYCeroSinPlazo;
    [Test]
    procedure CorteAnticipadoIncluyeTodoYNuncaEsCero;
    [Test]
    procedure RecepcionExigeQuienRecibeYFechaCoherente;
    [Test]
    procedure EntradaCentralExigeDestinoYRegistro;
    [Test]
    procedure CajasDecididasNecesitaCajasYNingunaPendiente;
    [Test]
    procedure HayCajaRecibidaSoloConAlgunaRecibida;
    [Test]
    procedure UbicacionDeCajaExigeLosTresCamposYSusLimites;
    [Test]
    procedure EstadoDeCajaIdaYVueltaConElCodigo;
    [Test]
    procedure ReclamacionVenceTreintaDiasDespues;
    [Test]
    procedure TextoDelEstadoDeCajaEsParaPersonas;
    [Test]
    procedure RegistroTopograficoSoloLlevaCajasRecibidasEnOrden;
    [Test]
    procedure RegistroTopograficoSinCajasRecibidasEstaVacio;
    [Test]
    procedure TextoDeUbicacionVaciaSinDatosYCompletaConTodos;
    [Test]
    procedure CronogramaAtrasadaYProgramada;
    [Test]
    procedure CronogramaEnTramiteYRealizada;
    [Test]
    procedure TodasLasVerificacionesMarcadas;
    [Test]
    procedure FaltanVerificacionesDicenCuales;
    [Test]
    procedure CajasNoPartenUnExpediente;
    [Test]
    procedure ExpedienteMayorQueLaCapacidadVaSolo;
    [Test]
    procedure NumeracionConsecutivaSinHuecos;
    [Test]
    procedure GrupoDistintoAbreCajaCuandoNoCabe;
    [Test]
    procedure RespetaElOrdenYLaPrimeraCaja;
    [Test]
    procedure CapacidadCeroUsaLaPorDefecto;
    [Test]
    procedure TextoDeEstados;
  end;

implementation

uses
  System.SysUtils, UProceso, UTransferenciasReglas;

var
  HOY: TDateTime;

function Item(const Grupo: string; Orden: Integer): TItemCaja;
begin
  Result.Grupo := Grupo;
  Result.Orden := Orden;
end;

procedure TPruebasTransferenciasReglas.VencidoCuandoPasanLosAnios;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsTrue(PlazoVencido(EncodeDate(2018, 3, 1), 0, False, 5, HOY));
end;

procedure TPruebasTransferenciasReglas.VenceElMismoDiaDelAniversario;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsTrue(PlazoVencido(EncodeDate(2021, 11, 12), 0, False, 5, HOY));
end;

procedure TPruebasTransferenciasReglas.NoVenceUnDiaAntes;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsFalse(PlazoVencido(EncodeDate(2021, 11, 13), 0, False, 5, HOY));
  Assert.IsFalse(PlazoVencido(EncodeDate(2022, 1, 1), 0, False, 5, HOY));
end;

procedure TPruebasTransferenciasReglas.SinPlazoNuncaVence;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsFalse(PlazoVencido(EncodeDate(1990, 1, 1), 0, False, 0, HOY));
  Assert.IsFalse(PlazoVencido(EncodeDate(1990, 1, 1), 0, False, -3, HOY));
end;

procedure TPruebasTransferenciasReglas.SinFechaNoVence;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsFalse(PlazoVencido(0, 0, False, 5, HOY));
end;

procedure TPruebasTransferenciasReglas.FechaFinAnteriorAFechaSeIgnora;
begin
  HOY := EncodeDate(2026, 11, 12);
  // FechaFin 2010 es anterior a Fecha 2020: se usa Fecha (2020 + 5 = 2025: vencido)
  Assert.IsTrue(PlazoVencido(EncodeDate(2020, 1, 1), EncodeDate(2010, 1, 1), True, 5, HOY));
  // y con Fecha reciente no vence aunque FechaFin sea vieja
  Assert.IsFalse(PlazoVencido(EncodeDate(2024, 1, 1), EncodeDate(2010, 1, 1), True, 5, HOY));
end;

procedure TPruebasTransferenciasReglas.FechaFinPosteriorManda;
begin
  HOY := EncodeDate(2026, 11, 12);
  // por Fecha (2015 + 5) estaria vencido; por FechaFin (2024 + 5 = 2029) no
  Assert.IsFalse(PlazoVencido(EncodeDate(2015, 1, 1), EncodeDate(2024, 1, 1), True, 5, HOY));
end;

procedure TPruebasTransferenciasReglas.CorteAnticipadoIncluyeTodoYNuncaEsCero;
begin
  // normal: igual que FechaCorte (0 = sin plazo, no se propone)
  Assert.AreEqual(EncodeDate(2021, 11, 12), FechaCorteGrupo(HOY, 5, False), 0.0001);
  Assert.AreEqual(0.0, FechaCorteGrupo(HOY, 0, False), 0.0001);
  // anticipado: un corte muy futuro, con o sin plazo, para incluir los que aun no vencen
  Assert.IsTrue(FechaCorteGrupo(HOY, 5, True) > HOY + 365 * 50);
  Assert.IsTrue(FechaCorteGrupo(HOY, 0, True) > HOY + 365 * 50);
end;

procedure TPruebasTransferenciasReglas.RecepcionExigeQuienRecibeYFechaCoherente;
var
  Entrega, Hoy: TDateTime;
begin
  Hoy := EncodeDate(2026, 11, 13);
  Entrega := EncodeDate(2026, 11, 10);
  // correcta: el mismo dia de la entrega, un dia despues y hoy
  Assert.AreEqual(0, Length(ValidarRecepcion('Ana', Entrega, Entrega, Hoy)));
  Assert.AreEqual(0, Length(ValidarRecepcion(' Ana ', Hoy, Entrega, Hoy)));
  // sin nombre
  Assert.AreEqual(1, Length(ValidarRecepcion('   ', Hoy, Entrega, Hoy)));
  // futura
  Assert.AreEqual(1, Length(ValidarRecepcion('Ana', Hoy + 1, Entrega, Hoy)));
  // anterior a la entrega
  Assert.AreEqual(1, Length(ValidarRecepcion('Ana', Entrega - 1, Entrega, Hoy)));
  // sin fecha de entrega conocida: solo cuenta que no sea futura
  Assert.AreEqual(0, Length(ValidarRecepcion('Ana', Hoy, 0, Hoy)));
  // varios errores a la vez
  Assert.AreEqual(2, Length(ValidarRecepcion('', Hoy + 1, Entrega, Hoy)));
end;

procedure TPruebasTransferenciasReglas.EntradaCentralExigeDestinoYRegistro;
begin
  Assert.AreEqual(2, Length(ValidarEntradaCentral(0, '')));
  Assert.AreEqual(1, Length(ValidarEntradaCentral(3, '')));
  Assert.AreEqual(1, Length(ValidarEntradaCentral(3, '   ')));
  Assert.AreEqual(0, Length(ValidarEntradaCentral(3, '2026-0012')));
  Assert.AreEqual(0, Length(ValidarEntradaCentral(3, StringOfChar('x', 30))));
  Assert.AreEqual(1, Length(ValidarEntradaCentral(3, StringOfChar('x', 31))));
end;

procedure TPruebasTransferenciasReglas.CajasDecididasNecesitaCajasYNingunaPendiente;
begin
  Assert.IsFalse(CajasDecididas([]));
  Assert.IsFalse(CajasDecididas([ecRecibida, ecPendiente]));
  Assert.IsTrue(CajasDecididas([ecRecibida, ecCuarentena, ecFaltante]));
end;

procedure TPruebasTransferenciasReglas.HayCajaRecibidaSoloConAlgunaRecibida;
begin
  Assert.IsFalse(HayCajaRecibida([]));
  Assert.IsFalse(HayCajaRecibida([ecFaltante]));
  Assert.IsTrue(HayCajaRecibida([ecRecibida, ecFaltante]));
end;

procedure TPruebasTransferenciasReglas.UbicacionDeCajaExigeLosTresCamposYSusLimites;
begin
  Assert.AreEqual(3, Length(ValidarUbicacionCaja('', '', '')));
  Assert.AreEqual(1, Length(ValidarUbicacionCaja('0', '02', '3')));
  Assert.AreEqual(0, Length(ValidarUbicacionCaja(' 01 ', '02', '3')));
  Assert.AreEqual(1, Length(ValidarUbicacionCaja('01', StringOfChar('g', 21), '3')));
  Assert.AreEqual(0, Length(ValidarUbicacionCaja('01', StringOfChar('g', 20), '3')));
  Assert.AreEqual(1, Length(ValidarUbicacionCaja('01', '02', StringOfChar('7', 11))));
  Assert.AreEqual(1, Length(ValidarUbicacionCaja(StringOfChar('d', 256), '02', '3')));
  Assert.AreEqual(0, Length(ValidarUbicacionCaja(StringOfChar('d', 255), '02', '3')));
end;

procedure TPruebasTransferenciasReglas.EstadoDeCajaIdaYVueltaConElCodigo;
var
  E: TEstadoCaja;
begin
  for E := Low(TEstadoCaja) to High(TEstadoCaja) do
    Assert.AreEqual(Ord(E), Ord(EstadoCajaDesdeCodigo(CodigoDeEstadoCaja(E))));
  Assert.AreEqual(Ord(ecCuarentena), Ord(EstadoCajaDesdeCodigo('Q')));
  Assert.AreEqual(Ord(ecPendiente), Ord(EstadoCajaDesdeCodigo('x')));
  Assert.AreEqual(Ord(ecPendiente), Ord(EstadoCajaDesdeCodigo('')));
end;

function CajaTopo(N: Integer; E: TEstadoCaja; const Dep: string): TCajaFila;
begin
  Result := Default(TCajaFila);
  Result.Caja := N;
  Result.Estado := E;
  Result.Deposito := Dep;
  Result.Gaveta := 'G' + IntToStr(N);
  Result.Posicion := IntToStr(N);
  Result.Unidades := 10 + N;
  Result.Descripcion := 'Caja ' + IntToStr(N);
end;

procedure TPruebasTransferenciasReglas.RegistroTopograficoSoloLlevaCajasRecibidasEnOrden;
var
  L: TArray<TLineaTopografia>;
begin
  L := LineasRegistroTopografico([CajaTopo(3, ecRecibida, 'D3'), CajaTopo(1, ecRecibida, 'D1'),
    CajaTopo(2, ecCuarentena, ''), CajaTopo(4, ecFaltante, ''), CajaTopo(5, ecPendiente, '')]);
  Assert.AreEqual(2, Length(L), 'solo las recibidas');
  Assert.AreEqual(1, L[0].Caja);
  Assert.AreEqual('D1', L[0].Deposito);
  Assert.AreEqual('G1', L[0].Gaveta);
  Assert.AreEqual('1', L[0].Posicion);
  Assert.AreEqual(11, L[0].Unidades);
  Assert.AreEqual(3, L[1].Caja, 'orden ascendente por numero de caja');
end;

procedure TPruebasTransferenciasReglas.RegistroTopograficoSinCajasRecibidasEstaVacio;
begin
  Assert.AreEqual(0, Length(LineasRegistroTopografico([])));
  Assert.AreEqual(0, Length(LineasRegistroTopografico([CajaTopo(1, ecFaltante, '')])));
end;

procedure TPruebasTransferenciasReglas.TextoDelEstadoDeCajaEsParaPersonas;
begin
  Assert.AreEqual('Pendiente', TextoEstadoCaja(ecPendiente));
  Assert.AreEqual('Recibida', TextoEstadoCaja(ecRecibida));
  Assert.AreEqual('En cuarentena', TextoEstadoCaja(ecCuarentena));
  Assert.AreEqual('Faltante', TextoEstadoCaja(ecFaltante));
end;

procedure TPruebasTransferenciasReglas.TextoDeUbicacionVaciaSinDatosYCompletaConTodos;
begin
  Assert.AreEqual('', TextoUbicacionCaja('', '', ''));
  Assert.AreEqual('', TextoUbicacionCaja(' ', '0', ''));
  Assert.AreEqual('Dep. 01 / Gav. 02 / Pos. 3', TextoUbicacionCaja('01', '02', '3'));
  Assert.AreEqual('Dep. 01', TextoUbicacionCaja('01', '', ''), 'solo lo que hay');
  Assert.AreEqual('Dep. 01 / Pos. 3', TextoUbicacionCaja(' 01 ', '0', '3'));
end;

procedure TPruebasTransferenciasReglas.ReclamacionVenceTreintaDiasDespues;
begin
  Assert.AreEqual(30, PLAZO_RECLAMACION_DIAS);
  Assert.AreEqual(EncodeDate(2026, 12, 1), FechaLimiteReclamacion(EncodeDate(2026, 11, 1)), 0.0001);
end;

procedure TPruebasTransferenciasReglas.FechaCorteRestaAniosYCeroSinPlazo;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.AreEqual(EncodeDate(2021, 11, 12), FechaCorte(HOY, 5), 0.0001);
  Assert.AreEqual(0.0, FechaCorte(HOY, 0), 0.0001);
  Assert.AreEqual(0.0, FechaCorte(HOY, -2), 0.0001);
end;

procedure TPruebasTransferenciasReglas.CronogramaAtrasadaYProgramada;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsTrue(EstadoCronograma(HOY - 1, False, False, HOY) = ecAtrasada);
  Assert.IsTrue(EstadoCronograma(HOY, False, False, HOY) = ecProgramada);
  Assert.IsTrue(EstadoCronograma(HOY + 30, False, False, HOY) = ecProgramada);
end;

procedure TPruebasTransferenciasReglas.CronogramaEnTramiteYRealizada;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsTrue(EstadoCronograma(HOY - 40, True, False, HOY) = ecEnTramite,
    'con proceso abierto no se considera atrasada');
  Assert.IsTrue(EstadoCronograma(HOY - 40, True, True, HOY) = ecRealizada);
end;

procedure TPruebasTransferenciasReglas.TodasLasVerificacionesMarcadas;
begin
  Assert.IsTrue(VerificacionesCompletas(['unicos', 'completos', 'sindividir',
    'etiquetas', 'prestamos']));
  Assert.IsFalse(VerificacionesCompletas(['unicos']));
  Assert.IsFalse(VerificacionesCompletas([]));
end;

procedure TPruebasTransferenciasReglas.FaltanVerificacionesDicenCuales;
var
  F: TArray<string>;
begin
  F := VerificacionesFaltan(['unicos', 'etiquetas']);
  Assert.AreEqual(3, Length(F));
  Assert.AreEqual('completos', F[0]);
  Assert.AreEqual('sindividir', F[1]);
  Assert.AreEqual('prestamos', F[2]);
  Assert.AreEqual(0, Length(VerificacionesFaltan(['unicos', 'completos', 'sindividir',
    'etiquetas', 'prestamos'])));
end;

procedure TPruebasTransferenciasReglas.CajasNoPartenUnExpediente;
var
  C: TArray<Integer>;
begin
  // capacidad 3: el expediente B (2 documentos) no cabe tras A (2) y pasa entero a la caja 2
  C := RepartirEnCajas([Item('A', 1), Item('A', 2), Item('B', 3), Item('B', 4)], 3, 1);
  Assert.AreEqual(1, C[0]);
  Assert.AreEqual(1, C[1]);
  Assert.AreEqual(2, C[2]);
  Assert.AreEqual(2, C[3]);
end;

procedure TPruebasTransferenciasReglas.ExpedienteMayorQueLaCapacidadVaSolo;
var
  C: TArray<Integer>;
  I: Integer;
begin
  C := RepartirEnCajas([Item('X', 1), Item('X', 2), Item('X', 3), Item('X', 4),
    Item('X', 5), Item('Y', 6)], 3, 1);
  for I := 0 to 4 do
    Assert.AreEqual(1, C[I], 'el expediente X completo en la caja 1');
  Assert.AreEqual(2, C[5], 'Y en otra caja');
end;

procedure TPruebasTransferenciasReglas.NumeracionConsecutivaSinHuecos;
var
  C: TArray<Integer>;
begin
  C := RepartirEnCajas([Item('A', 1), Item('B', 2), Item('C', 3), Item('D', 4)], 1, 1);
  Assert.AreEqual(1, C[0]);
  Assert.AreEqual(2, C[1]);
  Assert.AreEqual(3, C[2]);
  Assert.AreEqual(4, C[3]);
  // un expediente enorme seguido de uno chico: 1 y 2, sin saltar numeros
  C := RepartirEnCajas([Item('G', 1), Item('G', 2), Item('G', 3), Item('P', 4)], 2, 1);
  Assert.AreEqual(1, C[0]);
  Assert.AreEqual(1, C[2]);
  Assert.AreEqual(2, C[3]);
end;

procedure TPruebasTransferenciasReglas.GrupoDistintoAbreCajaCuandoNoCabe;
var
  C: TArray<Integer>;
begin
  C := RepartirEnCajas([Item('A', 1), Item('B', 2), Item('C', 3)], 2, 1);
  // A y B caben juntos (1 + 1 = 2); C abre la caja 2
  Assert.AreEqual(1, C[0]);
  Assert.AreEqual(1, C[1]);
  Assert.AreEqual(2, C[2]);
end;

procedure TPruebasTransferenciasReglas.RespetaElOrdenYLaPrimeraCaja;
var
  C: TArray<Integer>;
begin
  // entran desordenados: por Orden van A(1), B(2), C(3); capacidad 1, desde la caja 10
  C := RepartirEnCajas([Item('C', 3), Item('A', 1), Item('B', 2)], 1, 10);
  Assert.AreEqual(12, C[0], 'C es el tercero');
  Assert.AreEqual(10, C[1], 'A es el primero');
  Assert.AreEqual(11, C[2], 'B es el segundo');
end;

procedure TPruebasTransferenciasReglas.CapacidadCeroUsaLaPorDefecto;
var
  Items: TArray<TItemCaja>;
  C: TArray<Integer>;
  I: Integer;
begin
  SetLength(Items, 21);
  for I := 0 to 20 do
    Items[I] := Item('G' + IntToStr(I), I + 1);
  C := RepartirEnCajas(Items, 0, 1);
  Assert.AreEqual(1, C[19], 'los primeros 20 caben en la caja 1');
  Assert.AreEqual(2, C[20], 'el 21 abre la caja 2');
end;

procedure TPruebasTransferenciasReglas.TextoDeEstados;
begin
  Assert.AreEqual('Propuesta', TextoEstadoTransferencia(1, epEnCurso));
  Assert.AreEqual('Esperando comisi' + #243 + 'n', TextoEstadoTransferencia(2, epEnCurso));
  Assert.AreEqual('En preparaci' + #243 + 'n', TextoEstadoTransferencia(3, epEnCurso));
  Assert.AreEqual('Listo para entregar', TextoEstadoTransferencia(4, epEnCurso));
  Assert.AreEqual('En recepci' + #243 + 'n', TextoEstadoTransferencia(5, epEnCurso));
  Assert.AreEqual('En ubicaci' + #243 + 'n', TextoEstadoTransferencia(6, epEnCurso));
  Assert.AreEqual('Completada', TextoEstadoTransferencia(6, epFinalizado));
  Assert.AreEqual('Cancelada', TextoEstadoTransferencia(2, epCancelado));
end;

end.
