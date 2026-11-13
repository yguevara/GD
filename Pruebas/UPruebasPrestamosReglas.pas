unit UPruebasPrestamosReglas;

{ Reglas del prestamo: estado visible segun la fecha limite, plazo sugerido y
  validacion de la solicitud. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasPrestamosReglas = class
  public
    [Test]
    procedure EntregadoVencidoAlDiaSiguiente;
    [Test]
    procedure VenceHoyNoEstaVencido;
    [Test]
    procedure PorVencerAlFaltarTresDias;
    [Test]
    procedure FaltandoCuatroDiasSigueEntregado;
    [Test]
    procedure SinFechaLimiteNuncaVence;
    [Test]
    procedure SolicitadoDevueltoYCancelado;
    [Test]
    procedure DiasDeRetrasoCuentaDiasCompletos;
    [Test]
    procedure FechaLimiteSugeridaSumaDias;
    [Test]
    procedure ExternoExigeCarnetDeOnceDigitosYEntidad;
    [Test]
    procedure InternoNoExigeCarnet;
    [Test]
    procedure RechazaLimiteAnteriorAHoy;
    [Test]
    procedure SolicitanteVacioEsError;
    [Test]
    procedure SolicitudCorrectaNoTieneErrores;
    [Test]
    procedure TextoDeLosEstadosSimples;
    [Test]
    procedure TextoVencidoDiceLosDias;
    [Test]
    procedure TextoPorVencerDiceCuantoFalta;
  end;

implementation

uses
  System.SysUtils, UProceso, UErroresCampo, UPrestamosReglas;

var
  HOY: TDateTime;

function Contiene(const Errores: TArray<TErrorCampo>; const Campo: string): Boolean;
var
  E: TErrorCampo;
begin
  Result := False;
  for E in Errores do
    if E.Campo = Campo then
      Exit(True);
end;

function Solicitud(Usuario: TTipoUsuarioPrestamo): TSolicitudPrestamo;
begin
  Result.Solicitante := 'Luis Fernandez';
  Result.Carnet := '82031412345';
  Result.Entidad := 'Finanzas';
  Result.Usuario := Usuario;
  Result.FechaLimite := HOY + 3;
end;

procedure TPruebasPrestamosReglas.EntregadoVencidoAlDiaSiguiente;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsTrue(EstadoDelPrestamo(2, epEnCurso, HOY - 1, HOY) = epsVencido);
  Assert.IsTrue(EstadoDelPrestamo(2, epEnCurso, HOY - 30, HOY) = epsVencido);
end;

procedure TPruebasPrestamosReglas.VenceHoyNoEstaVencido;
begin
  HOY := EncodeDate(2026, 11, 12);
  // la fecha limite es el ultimo dia para devolver; con hora de por medio igual
  Assert.IsTrue(EstadoDelPrestamo(2, epEnCurso, HOY, HOY + 0.75) = epsPorVencer);
  Assert.IsTrue(EstadoDelPrestamo(2, epEnCurso, HOY + 0.5, HOY) = epsPorVencer);
end;

procedure TPruebasPrestamosReglas.PorVencerAlFaltarTresDias;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsTrue(EstadoDelPrestamo(2, epEnCurso, HOY + 1, HOY) = epsPorVencer);
  Assert.IsTrue(EstadoDelPrestamo(2, epEnCurso, HOY + 3, HOY) = epsPorVencer);
end;

procedure TPruebasPrestamosReglas.FaltandoCuatroDiasSigueEntregado;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsTrue(EstadoDelPrestamo(2, epEnCurso, HOY + 4, HOY) = epsEntregado);
end;

procedure TPruebasPrestamosReglas.SinFechaLimiteNuncaVence;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsTrue(EstadoDelPrestamo(2, epEnCurso, 0, HOY) = epsEntregado);
  Assert.AreEqual(0, DiasDeRetraso(0, HOY));
end;

procedure TPruebasPrestamosReglas.SolicitadoDevueltoYCancelado;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.IsTrue(EstadoDelPrestamo(1, epEnCurso, 0, HOY) = epsSolicitado);
  // un solicitado con limite pasado sigue solicitado: aun no se entrego nada
  Assert.IsTrue(EstadoDelPrestamo(1, epEnCurso, HOY - 10, HOY) = epsSolicitado);
  Assert.IsTrue(EstadoDelPrestamo(3, epFinalizado, HOY - 10, HOY) = epsDevuelto);
  Assert.IsTrue(EstadoDelPrestamo(2, epCancelado, HOY - 10, HOY) = epsCancelado);
end;

procedure TPruebasPrestamosReglas.DiasDeRetrasoCuentaDiasCompletos;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.AreEqual(2, DiasDeRetraso(HOY - 2, HOY));
  Assert.AreEqual(0, DiasDeRetraso(HOY, HOY));
  Assert.AreEqual(0, DiasDeRetraso(HOY + 1, HOY));
end;

procedure TPruebasPrestamosReglas.FechaLimiteSugeridaSumaDias;
begin
  Assert.AreEqual(EncodeDate(2026, 11, 15), FechaLimiteSugerida(EncodeDate(2026, 11, 12) + 0.6, 3), 0.0001);
  Assert.AreEqual(3, PLAZO_PRESTAMO_DIAS);
end;

procedure TPruebasPrestamosReglas.ExternoExigeCarnetDeOnceDigitosYEntidad;
var
  S: TSolicitudPrestamo;
begin
  HOY := EncodeDate(2026, 11, 12);
  S := Solicitud(tuExterno);
  S.Carnet := '';
  S.Entidad := '';
  Assert.IsTrue(Contiene(ValidarSolicitud(S, HOY), 'carnet'));
  Assert.IsTrue(Contiene(ValidarSolicitud(S, HOY), 'entidad'));
  S.Carnet := '1234';
  Assert.IsTrue(Contiene(ValidarSolicitud(S, HOY), 'carnet'));
  S.Carnet := '8203141234a';
  Assert.IsTrue(Contiene(ValidarSolicitud(S, HOY), 'carnet'));
  S.Carnet := '82031412345';
  S.Entidad := 'Oficina Nacional';
  Assert.AreEqual(0, Length(ValidarSolicitud(S, HOY)));
end;

procedure TPruebasPrestamosReglas.InternoNoExigeCarnet;
var
  S: TSolicitudPrestamo;
begin
  HOY := EncodeDate(2026, 11, 12);
  S := Solicitud(tuInterno);
  S.Carnet := '';
  S.Entidad := '';
  Assert.AreEqual(0, Length(ValidarSolicitud(S, HOY)));
end;

procedure TPruebasPrestamosReglas.RechazaLimiteAnteriorAHoy;
var
  S: TSolicitudPrestamo;
begin
  HOY := EncodeDate(2026, 11, 12);
  S := Solicitud(tuInterno);
  S.FechaLimite := HOY - 1;
  Assert.IsTrue(Contiene(ValidarSolicitud(S, HOY), 'limite'));
  S.FechaLimite := HOY;
  Assert.AreEqual(0, Length(ValidarSolicitud(S, HOY)), 'hoy es un limite valido');
  S.FechaLimite := 0;
  Assert.AreEqual(0, Length(ValidarSolicitud(S, HOY)), 'sin limite es valido');
end;

procedure TPruebasPrestamosReglas.SolicitanteVacioEsError;
var
  S: TSolicitudPrestamo;
begin
  HOY := EncodeDate(2026, 11, 12);
  S := Solicitud(tuInterno);
  S.Solicitante := '   ';
  Assert.IsTrue(Contiene(ValidarSolicitud(S, HOY), 'solicitante'));
end;

procedure TPruebasPrestamosReglas.SolicitudCorrectaNoTieneErrores;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.AreEqual(0, Length(ValidarSolicitud(Solicitud(tuInterno), HOY)));
  Assert.AreEqual(0, Length(ValidarSolicitud(Solicitud(tuExterno), HOY)));
end;

procedure TPruebasPrestamosReglas.TextoDeLosEstadosSimples;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.AreEqual('Solicitado', TextoEstadoPrestamo(epsSolicitado, 0, HOY));
  Assert.AreEqual('Entregado', TextoEstadoPrestamo(epsEntregado, HOY + 20, HOY));
  Assert.AreEqual('Devuelto', TextoEstadoPrestamo(epsDevuelto, HOY - 5, HOY));
  Assert.AreEqual('Cancelado', TextoEstadoPrestamo(epsCancelado, 0, HOY));
end;

procedure TPruebasPrestamosReglas.TextoVencidoDiceLosDias;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.AreEqual('Vencido ' + #183 + ' 2 d' + #237 + 'as',
    TextoEstadoPrestamo(epsVencido, HOY - 2, HOY));
  Assert.AreEqual('Vencido ' + #183 + ' 1 d' + #237 + 'a',
    TextoEstadoPrestamo(epsVencido, HOY - 1, HOY));
end;

procedure TPruebasPrestamosReglas.TextoPorVencerDiceCuantoFalta;
begin
  HOY := EncodeDate(2026, 11, 12);
  Assert.AreEqual('Vence hoy', TextoEstadoPrestamo(epsPorVencer, HOY, HOY));
  Assert.AreEqual('Vence en 1 d' + #237 + 'a', TextoEstadoPrestamo(epsPorVencer, HOY + 1, HOY));
  Assert.AreEqual('Vence en 3 d' + #237 + 'as', TextoEstadoPrestamo(epsPorVencer, HOY + 3, HOY));
end;

end.
