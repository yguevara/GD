unit UPruebasAutorizacion;

{ Validacion del acta y acuerdo de la Comision de Valoracion. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasAutorizacion = class
  public
    [Test]
    procedure ValidaAutorizacionCorrecta;
    [Test]
    procedure ExigeActaYAcuerdo;
    [Test]
    procedure RechazaFechaFutura;
    [Test]
    procedure AceptaFechaDeHoy;
    [Test]
    procedure DepuracionRechazaComisionCentral;
    [Test]
    procedure TransferenciaRechazaComisionProvincial;
    [Test]
    procedure PrestamoNoAdmiteAutorizacion;
  end;

implementation

uses
  System.SysUtils, UProceso, UErroresCampo, UAutorizacion;

const
  HOY = 46338.0; // fecha fija para las pruebas

function Valida(Organo: TOrganoComision; Fecha: TDateTime): TAutorizacion;
begin
  Result.Organo := Organo;
  Result.NumActa := '14';
  Result.NumAcuerdo := '9';
  Result.Fecha := Fecha;
end;

function Contiene(const Errores: TArray<TErrorCampo>; const Campo: string): Boolean;
var
  E: TErrorCampo;
begin
  Result := False;
  for E in Errores do
    if E.Campo = Campo then
      Exit(True);
end;

procedure TPruebasAutorizacion.ValidaAutorizacionCorrecta;
begin
  Assert.AreEqual(0, Length(ValidarAutorizacion(tpDepuracion,
    Valida(ocProvincial, HOY - 10), HOY)));
  Assert.AreEqual(0, Length(ValidarAutorizacion(tpTransferencia,
    Valida(ocCentral, HOY - 10), HOY)));
end;

procedure TPruebasAutorizacion.ExigeActaYAcuerdo;
var
  A: TAutorizacion;
  E: TArray<TErrorCampo>;
begin
  A := Valida(ocNacional, HOY);
  A.NumActa := '  ';
  A.NumAcuerdo := '';
  E := ValidarAutorizacion(tpDepuracion, A, HOY);
  Assert.IsTrue(Contiene(E, 'acta'));
  Assert.IsTrue(Contiene(E, 'acuerdo'));
end;

procedure TPruebasAutorizacion.RechazaFechaFutura;
var
  E: TArray<TErrorCampo>;
begin
  E := ValidarAutorizacion(tpDepuracion, Valida(ocNacional, HOY + 1), HOY);
  Assert.IsTrue(Contiene(E, 'fecha'));
end;

procedure TPruebasAutorizacion.AceptaFechaDeHoy;
begin
  Assert.AreEqual(0, Length(ValidarAutorizacion(tpDepuracion,
    Valida(ocMunicipal, HOY), HOY)));
end;

procedure TPruebasAutorizacion.DepuracionRechazaComisionCentral;
begin
  Assert.IsTrue(Contiene(ValidarAutorizacion(tpDepuracion,
    Valida(ocCentral, HOY), HOY), 'organo'));
end;

procedure TPruebasAutorizacion.TransferenciaRechazaComisionProvincial;
begin
  Assert.IsTrue(Contiene(ValidarAutorizacion(tpTransferencia,
    Valida(ocProvincial, HOY), HOY), 'organo'));
end;

procedure TPruebasAutorizacion.PrestamoNoAdmiteAutorizacion;
begin
  Assert.IsTrue(Contiene(ValidarAutorizacion(tpPrestamo,
    Valida(ocCentral, HOY), HOY), 'organo'));
end;

end.
