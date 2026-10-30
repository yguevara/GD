unit UPruebasTopografia;

{ Pruebas de la validacion topografica (UTopografia): que datos exige cada
  tipo de soporte y que mensaje recibe quien intenta agregar un documento. }

interface

uses
  DUnitX.TestFramework, UTopografia;

type
  [TestFixture]
  TPruebasTopografia = class
  private
    function Datos(const Deposito, Gaveta, Archivo, IdServidor: string): TDatosTopografia;
  public
    [Test]
    procedure Soporte0_SiempreCompleta;
    [Test]
    procedure Soporte1_ExigeDepositoGavetaYArchivo;
    [Test]
    procedure Soporte2_ExigeServidor;
    [Test]
    procedure Soporte3_ExigeLosCuatro;
    [Test]
    procedure CeroYEspacios_CuentanComoVacio;
    [Test]
    procedure SoporteDesconocido_NoBloquea;
    [Test]
    procedure Mensaje_Soporte2_ConPermiso_PideServidor;
    [Test]
    procedure Mensaje_OtroSoporte_ConPermiso_PideDatos;
    [Test]
    procedure Mensaje_SinPermiso_Manda_AlEGD;
  end;

implementation

uses
  System.SysUtils;

function TPruebasTopografia.Datos(const Deposito, Gaveta, Archivo,
  IdServidor: string): TDatosTopografia;
begin
  Result.Deposito := Deposito;
  Result.Gaveta := Gaveta;
  Result.Archivo := Archivo;
  Result.IdServidor := IdServidor;
end;

procedure TPruebasTopografia.Soporte0_SiempreCompleta;
begin
  Assert.IsTrue(TopografiaCompleta(0, Datos('', '', '', '')));
end;

procedure TPruebasTopografia.Soporte1_ExigeDepositoGavetaYArchivo;
begin
  Assert.IsTrue(TopografiaCompleta(1, Datos('01', '14', '2', '')));
  Assert.IsFalse(TopografiaCompleta(1, Datos('', '14', '2', '1')));
  Assert.IsFalse(TopografiaCompleta(1, Datos('01', '', '2', '1')));
  Assert.IsFalse(TopografiaCompleta(1, Datos('01', '14', '', '1')));
end;

procedure TPruebasTopografia.Soporte2_ExigeServidor;
begin
  Assert.IsTrue(TopografiaCompleta(2, Datos('', '', '', '1')));
  Assert.IsFalse(TopografiaCompleta(2, Datos('01', '14', '2', '')));
end;

procedure TPruebasTopografia.Soporte3_ExigeLosCuatro;
begin
  Assert.IsTrue(TopografiaCompleta(3, Datos('01', '14', '2', '1')));
  Assert.IsFalse(TopografiaCompleta(3, Datos('01', '14', '2', '')));
  Assert.IsFalse(TopografiaCompleta(3, Datos('', '14', '2', '1')));
end;

procedure TPruebasTopografia.CeroYEspacios_CuentanComoVacio;
begin
  Assert.IsFalse(TopografiaCompleta(2, Datos('', '', '', '0')));
  Assert.IsFalse(TopografiaCompleta(2, Datos('', '', '', '   ')));
  Assert.IsFalse(TopografiaCompleta(1, Datos('0', '14', '2', '')));
  Assert.IsTrue(TopografiaCompleta(1, Datos(' 01 ', '14', '2', '')));
end;

procedure TPruebasTopografia.SoporteDesconocido_NoBloquea;
begin
  Assert.IsTrue(TopografiaCompleta(9, Datos('', '', '', '')));
  Assert.IsTrue(TopografiaCompleta(-1, Datos('', '', '', '')));
end;

procedure TPruebasTopografia.Mensaje_Soporte2_ConPermiso_PideServidor;
begin
  Assert.IsTrue(Pos('servidor o repositorio', MensajeTopografiaFaltante(2, True)) > 0);
end;

procedure TPruebasTopografia.Mensaje_OtroSoporte_ConPermiso_PideDatos;
begin
  Assert.IsTrue(Pos('soporte especificado', MensajeTopografiaFaltante(1, True)) > 0);
  Assert.IsTrue(Pos('soporte especificado', MensajeTopografiaFaltante(3, True)) > 0);
end;

procedure TPruebasTopografia.Mensaje_SinPermiso_Manda_AlEGD;
var
  S: Integer;
begin
  for S := 0 to 3 do
    Assert.IsTrue(Pos('Avisa al especialista', MensajeTopografiaFaltante(S, False)) > 0,
      'soporte ' + IntToStr(S));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasTopografia);

end.
