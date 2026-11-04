unit UPruebasTema;

interface

uses
  DUnitX.TestFramework, UTema;

type
  [TestFixture]
  TPruebasTema = class
  private
    procedure VerificarContrastes(const T: TTemaColores);
  public
    [Test]
    procedure ColorDeHex_ValoresDeLaMaqueta;
    [Test]
    procedure ColorDeHex_Invalido_Lanza;
    [Test]
    procedure RazonContraste_BlancoSobreNegro_Es21;
    [Test]
    procedure RazonContraste_MismoColor_Es1;
    [Test]
    procedure TemaClaro_Contrastes;
    [Test]
    procedure TemaOscuro_Contrastes;
    [Test]
    procedure TemaClaro_ValoresDeLaMaqueta;
    [Test]
    procedure TemaOscuro_ValoresDeLaMaqueta;
  end;

implementation

uses
  System.SysUtils, System.UITypes;

procedure TPruebasTema.ColorDeHex_ValoresDeLaMaqueta;
var
  C: TColor;
begin
  C := ColorDeHex('#1d5fa6');
  Assert.AreEqual(29, Integer(C and $FF), 'R');
  Assert.AreEqual(95, Integer((C shr 8) and $FF), 'G');
  Assert.AreEqual(166, Integer((C shr 16) and $FF), 'B');
  Assert.AreEqual(Integer($A65F1D), Integer(C), 'BGR');
  Assert.AreEqual(Integer(C), Integer(ColorDeHex('#1D5FA6')), 'mayusculas');
end;

procedure TPruebasTema.ColorDeHex_Invalido_Lanza;
begin
  Assert.WillRaise(procedure begin ColorDeHex('1d5fa6'); end, EArgumentException, 'sin #');
  Assert.WillRaise(procedure begin ColorDeHex('#12'); end, EArgumentException, 'corto');
  Assert.WillRaise(procedure begin ColorDeHex(''); end, EArgumentException, 'vacio');
  Assert.WillRaise(procedure begin ColorDeHex('#zz5fa6'); end, EArgumentException, 'no hex');
end;

procedure TPruebasTema.RazonContraste_BlancoSobreNegro_Es21;
begin
  Assert.AreEqual(21.0, RazonContraste(TColor($FFFFFF), TColor($000000)), 0.001);
  Assert.AreEqual(21.0, RazonContraste(TColor($000000), TColor($FFFFFF)), 0.001);
end;

procedure TPruebasTema.RazonContraste_MismoColor_Es1;
begin
  Assert.AreEqual(1.0, RazonContraste(ColorDeHex('#1d5fa6'), ColorDeHex('#1d5fa6')), 0.0001);
end;

procedure TPruebasTema.VerificarContrastes(const T: TTemaColores);
begin
  Assert.IsTrue(RazonContraste(T.Texto, T.Fondo) >= 4.5, 'Texto/Fondo');
  Assert.IsTrue(RazonContraste(T.Texto, T.Superficie) >= 4.5, 'Texto/Superficie');
  Assert.IsTrue(RazonContraste(T.TextoSobreAcento, T.Acento) >= 4.5, 'TextoSobreAcento/Acento');
  Assert.IsTrue(RazonContraste(T.Acento, T.Superficie) >= 3.0, 'Acento/Superficie');
end;

procedure TPruebasTema.TemaClaro_Contrastes;
begin
  VerificarContrastes(TemaClaro);
end;

procedure TPruebasTema.TemaOscuro_Contrastes;
begin
  VerificarContrastes(TemaOscuro);
end;

procedure TPruebasTema.TemaClaro_ValoresDeLaMaqueta;
var
  T: TTemaColores;
begin
  T := TemaClaro;
  Assert.AreEqual(Integer(ColorDeHex('#e9edf1')), Integer(T.Fondo));
  Assert.AreEqual(Integer(ColorDeHex('#ffffff')), Integer(T.Superficie));
  Assert.AreEqual(Integer(ColorDeHex('#1b2733')), Integer(T.Texto));
  Assert.AreEqual(Integer(ColorDeHex('#1d5fa6')), Integer(T.Acento));
end;

procedure TPruebasTema.TemaOscuro_ValoresDeLaMaqueta;
var
  T: TTemaColores;
begin
  T := TemaOscuro;
  Assert.AreEqual(Integer(ColorDeHex('#12181e')), Integer(T.Fondo));
  Assert.AreEqual(Integer(ColorDeHex('#1a232c')), Integer(T.Superficie));
  Assert.AreEqual(Integer(ColorDeHex('#e5ebf1')), Integer(T.Texto));
  Assert.AreEqual(Integer(ColorDeHex('#6aa8ea')), Integer(T.Acento));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasTema);

end.
