unit UPruebasDepuracionReglas;

{ Reglas puras de la depuracion: plazo en el archivo central, numero en letras,
  acta, muestra, testigos y confirmacion. Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasDepuracionReglas = class
  public
    [Test]
    procedure PlazoConCierreDeTransferenciaCuentaDesdeElCierre;
    [Test]
    procedure PlazoSinCierreCuentaDesdeLaFechaBaseMasGestionYCentral;
    [Test]
    procedure PlazoSinAniosEnElCentralNuncaVence;
    [Test]
    procedure NumeroEnLetrasCasosNormales;
    [Test]
    procedure NumeroEnLetrasBordes;
    [Test]
    procedure NumeroEnLetrasFueraDeRangoLanza;
    [Test]
    procedure TestigosSuficientesExigeComisionYArchivoDeGestion;
    [Test]
    procedure TestigoExigeNombreYLimites;
    [Test]
    procedure ActaExigeLugarYFechaPrevista;
    [Test]
    procedure MuestraExigeDescripcionYDonde;
    [Test]
    procedure ConfirmacionSoloAceptaEliminarEnMayusculas;
    [Test]
    procedure TextoDelEstadoDeLaDepuracion;
    [Test]
    procedure TextosQueFaltanUnoPorCondicion;
    [Test]
    procedure CodigosDeViaYOrigenIdaYVuelta;
  end;

implementation

uses
  System.SysUtils, UProceso, UDepuracionReglas;

function Testigo(const Nombre: string; O: TOrigenTestigo): TTestigoDatos;
begin
  Result.Nombre := Nombre;
  Result.Cargo := 'Cargo';
  Result.Origen := O;
end;

procedure TPruebasDepuracionReglas.PlazoConCierreDeTransferenciaCuentaDesdeElCierre;
var
  Cierre: TDateTime;
begin
  Cierre := EncodeDate(2020, 2, 1);
  // la fecha del documento no importa cuando hay cierre
  Assert.IsTrue(PlazoCentralVencido(EncodeDate(2025, 2, 1), True, Cierre, EncodeDate(1990, 1, 1), 0, False, 3, 5));
  Assert.IsFalse(PlazoCentralVencido(EncodeDate(2025, 1, 31), True, Cierre, EncodeDate(1990, 1, 1), 0, False, 3, 5));
  Assert.IsFalse(PlazoCentralVencido(EncodeDate(2030, 1, 1), True, Cierre, EncodeDate(1990, 1, 1), 0, False, 3, 0));
end;

procedure TPruebasDepuracionReglas.PlazoSinCierreCuentaDesdeLaFechaBaseMasGestionYCentral;
var
  Fecha: TDateTime;
begin
  Fecha := EncodeDate(2000, 5, 10);
  Assert.IsTrue(PlazoCentralVencido(EncodeDate(2008, 5, 10), False, 0, Fecha, 0, False, 3, 5));
  Assert.IsFalse(PlazoCentralVencido(EncodeDate(2008, 5, 9), False, 0, Fecha, 0, False, 3, 5));
  // FechaFin anterior a Fecha se ignora
  Assert.IsTrue(PlazoCentralVencido(EncodeDate(2008, 5, 10), False, 0, Fecha, EncodeDate(1999, 1, 1), True, 3, 5));
  // FechaFin posterior manda: vence el 10/05/2009
  Assert.IsFalse(PlazoCentralVencido(EncodeDate(2008, 5, 10), False, 0, Fecha, EncodeDate(2001, 5, 10), True, 3, 5));
  Assert.IsTrue(PlazoCentralVencido(EncodeDate(2009, 5, 10), False, 0, Fecha, EncodeDate(2001, 5, 10), True, 3, 5));
end;

procedure TPruebasDepuracionReglas.PlazoSinAniosEnElCentralNuncaVence;
begin
  Assert.IsFalse(PlazoCentralVencido(EncodeDate(2050, 1, 1), False, 0, EncodeDate(2000, 5, 10), 0, False, 3, 0));
  Assert.IsFalse(PlazoCentralVencido(EncodeDate(2050, 1, 1), False, 0, EncodeDate(2000, 5, 10), 0, False, 3, -1));
  Assert.IsFalse(PlazoCentralVencido(EncodeDate(2050, 1, 1), False, 0, 0, 0, False, 3, 5), 'sin fecha no vence');
end;

procedure TPruebasDepuracionReglas.NumeroEnLetrasCasosNormales;
begin
  Assert.AreEqual('cero', UnidadesEnLetras(0));
  Assert.AreEqual('una', UnidadesEnLetras(1));
  Assert.AreEqual('veintiuna', UnidadesEnLetras(21));
  Assert.AreEqual('treinta y una', UnidadesEnLetras(31));
  Assert.AreEqual('cien', UnidadesEnLetras(100));
  Assert.AreEqual('ciento una', UnidadesEnLetras(101));
  Assert.AreEqual('doscientas cuarenta', UnidadesEnLetras(240));
  Assert.AreEqual('mil', UnidadesEnLetras(1000));
  Assert.AreEqual('mil una', UnidadesEnLetras(1001));
  Assert.AreEqual('mil doscientas cuarenta', UnidadesEnLetras(1240));
end;

procedure TPruebasDepuracionReglas.NumeroEnLetrasBordes;
begin
  Assert.AreEqual('veintiun mil', UnidadesEnLetras(21000));
  Assert.AreEqual('cien mil', UnidadesEnLetras(100000));
  Assert.AreEqual('doscientas mil', UnidadesEnLetras(200000));
  Assert.AreEqual('un millon', UnidadesEnLetras(1000000));
  Assert.AreEqual('dos millones', UnidadesEnLetras(2000000));
  Assert.AreEqual('un millon doscientas cuarenta', UnidadesEnLetras(1000240));
  Assert.AreEqual('veintiun millones', UnidadesEnLetras(21000000));
  Assert.AreEqual('doscientos millones', UnidadesEnLetras(200000000));
  Assert.AreEqual('novecientos noventa y nueve millones novecientas noventa y nueve mil novecientas noventa y nueve',
    UnidadesEnLetras(999999999));
end;

procedure TPruebasDepuracionReglas.NumeroEnLetrasFueraDeRangoLanza;
begin
  Assert.WillRaise(
    procedure
    begin
      UnidadesEnLetras(-1);
    end, EArgumentException);
  Assert.WillRaise(
    procedure
    begin
      UnidadesEnLetras(1000000000);
    end, EArgumentException);
end;

procedure TPruebasDepuracionReglas.TestigosSuficientesExigeComisionYArchivoDeGestion;
begin
  Assert.IsFalse(TestigosSuficientes([]));
  Assert.IsFalse(TestigosSuficientes([Testigo('A', otComision), Testigo('B', otComision)]),
    'dos de la Comision no bastan');
  Assert.IsTrue(TestigosSuficientes([Testigo('A', otComision), Testigo('B', otArchivoGestion)]));
  Assert.IsFalse(TestigosSuficientes([Testigo('A', otComision), Testigo('B', otOtro)]));
  Assert.IsFalse(TestigosSuficientes([Testigo('A', otComision)]), 'minimo dos');
  Assert.IsTrue(TestigosSuficientes([Testigo('A', otComision), Testigo('B', otArchivoGestion),
    Testigo('C', otOtro)]));
end;

procedure TPruebasDepuracionReglas.TestigoExigeNombreYLimites;
var
  T: TTestigoDatos;
begin
  T := Testigo('', otComision);
  Assert.AreEqual(1, Length(ValidarTestigo(T)));
  T := Testigo('   ', otComision);
  Assert.AreEqual(1, Length(ValidarTestigo(T)));
  T := Testigo(StringOfChar('n', 101), otComision);
  Assert.AreEqual(1, Length(ValidarTestigo(T)));
  T := Testigo('Ana', otComision);
  T.Cargo := StringOfChar('c', 101);
  Assert.AreEqual(1, Length(ValidarTestigo(T)));
  T.Cargo := StringOfChar('c', 100);
  Assert.AreEqual(0, Length(ValidarTestigo(T)));
  T.Cargo := '';
  Assert.AreEqual(0, Length(ValidarTestigo(T)), 'el cargo es opcional');
end;

procedure TPruebasDepuracionReglas.ActaExigeLugarYFechaPrevista;
begin
  Assert.AreEqual(1, Length(ValidarActaDepuracion('', EncodeDate(2026, 11, 20))));
  Assert.AreEqual(1, Length(ValidarActaDepuracion('Planta', 0)));
  Assert.AreEqual(2, Length(ValidarActaDepuracion('  ', 0)));
  Assert.AreEqual(1, Length(ValidarActaDepuracion(StringOfChar('l', 256), EncodeDate(2026, 11, 20))));
  Assert.AreEqual(0, Length(ValidarActaDepuracion(StringOfChar('l', 255), EncodeDate(2026, 11, 20))));
  Assert.AreEqual(0, Length(ValidarActaDepuracion('Planta de reciclaje', EncodeDate(2026, 11, 20))));
end;

procedure TPruebasDepuracionReglas.MuestraExigeDescripcionYDonde;
begin
  Assert.AreEqual(1, Length(ValidarMuestra('', 'Dep. 1')));
  Assert.AreEqual(1, Length(ValidarMuestra('Enero de cada ano', '')));
  Assert.AreEqual(2, Length(ValidarMuestra('  ', '  ')));
  Assert.AreEqual(1, Length(ValidarMuestra(StringOfChar('d', 256), 'Dep. 1')));
  Assert.AreEqual(1, Length(ValidarMuestra('Enero', StringOfChar('d', 256))));
  Assert.AreEqual(0, Length(ValidarMuestra('Enero de cada ano', 'Dep. 1 - Est. B - Caja M-2')));
end;

procedure TPruebasDepuracionReglas.ConfirmacionSoloAceptaEliminarEnMayusculas;
begin
  Assert.IsTrue(ConfirmacionEscritaValida('ELIMINAR'));
  Assert.IsTrue(ConfirmacionEscritaValida('  ELIMINAR '));
  Assert.IsFalse(ConfirmacionEscritaValida('eliminar'));
  Assert.IsFalse(ConfirmacionEscritaValida('Eliminar'));
  Assert.IsFalse(ConfirmacionEscritaValida(''));
  Assert.IsFalse(ConfirmacionEscritaValida('ELIMINAR TODO'));
  Assert.AreEqual('ELIMINAR', PALABRA_CONFIRMACION);
  Assert.AreEqual(2, MINIMO_TESTIGOS);
end;

procedure TPruebasDepuracionReglas.TextoDelEstadoDeLaDepuracion;
begin
  Assert.AreEqual('Propuesta', TextoEstadoDepuracion(1, epEnCurso));
  Assert.AreEqual('En autorizacion', TextoEstadoDepuracion(2, epEnCurso));
  Assert.AreEqual('Acta por firmar', TextoEstadoDepuracion(3, epEnCurso));
  Assert.AreEqual('Lista para ejecutar', TextoEstadoDepuracion(4, epEnCurso));
  Assert.AreEqual('Ejecutada', TextoEstadoDepuracion(5, epEnCurso));
  Assert.AreEqual('Cerrada', TextoEstadoDepuracion(5, epFinalizado));
  Assert.AreEqual('Cerrada', TextoEstadoDepuracion(3, epFinalizado));
  Assert.AreEqual('Cancelada', TextoEstadoDepuracion(2, epCancelado));
end;

procedure TPruebasDepuracionReglas.TextosQueFaltanUnoPorCondicion;
var
  T: TArray<string>;
  I, J: Integer;
begin
  T := TextosQueFaltanDepuracion([cdAutorizado, cdMuestraDefinida, cdTestigosMinimos]);
  Assert.AreEqual(3, Length(T));
  for I := 0 to High(T) do
  begin
    Assert.IsTrue(T[I] <> '');
    for J := I + 1 to High(T) do
      Assert.AreNotEqual(T[I], T[J], 'frases distintas');
  end;
  Assert.AreEqual(0, Length(TextosQueFaltanDepuracion([])));
end;

procedure TPruebasDepuracionReglas.CodigosDeViaYOrigenIdaYVuelta;
var
  V: TViaEliminacion;
  O: TOrigenTestigo;
begin
  for V := Low(TViaEliminacion) to High(TViaEliminacion) do
    Assert.AreEqual(Ord(V), Ord(ViaDesdeCodigo(CodigoVia(V))));
  for O := Low(TOrigenTestigo) to High(TOrigenTestigo) do
    Assert.AreEqual(Ord(O), Ord(OrigenTestigoDesdeCodigo(CodigoOrigenTestigo(O))));
  Assert.AreEqual('I', CodigoVia(veIncineracion));
  Assert.AreEqual('T', CodigoVia(veTrituracion));
  Assert.AreEqual('C', CodigoOrigenTestigo(otComision));
  Assert.AreEqual('G', CodigoOrigenTestigo(otArchivoGestion));
  Assert.AreEqual('O', CodigoOrigenTestigo(otOtro));
  Assert.AreEqual('Incineracion', TextoVia(veIncineracion));
  Assert.AreEqual('Trituracion', TextoVia(veTrituracion));
  Assert.WillRaise(
    procedure
    begin
      ViaDesdeCodigo('X');
    end, EArgumentException);
  Assert.WillRaise(
    procedure
    begin
      OrigenTestigoDesdeCodigo('');
    end, EArgumentException);
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasDepuracionReglas);

end.
