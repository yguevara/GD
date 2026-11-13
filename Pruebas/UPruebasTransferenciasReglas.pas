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
