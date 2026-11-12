unit UPruebasClasificadorEstado;

{ Maquina de estados de la ficha de edicion de los clasificadores. }

interface

uses
  DUnitX.TestFramework, UClasificadorEstado;

type
  [TestFixture]
  TPruebasEstadoFicha = class
  private
    FE: TEstadoFicha;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Inicial_NavegandoSinCambios;
    [Test]
    procedure Nuevo_SinCambios_NoPuedeGuardar;
    [Test]
    procedure Nuevo_ConCambio_PuedeGuardar;
    [Test]
    procedure MarcarCambio_DesdeNavegando_PasaAEditando;
    [Test]
    procedure Elegir_DespuesDeCambio_LimpiaCambios;
    [Test]
    procedure RequiereConfirmar_SoloConCambios;
    [Test]
    procedure Guardado_VuelveANavegando;
    [Test]
    procedure Descartado_VuelveANavegando;
    [Test]
    procedure Navegando_NoPuedeGuardar;
  end;

implementation

procedure TPruebasEstadoFicha.Preparar;
begin
  FE := TEstadoFicha.Create;
end;

procedure TPruebasEstadoFicha.Limpiar;
begin
  FE.Free;
end;

procedure TPruebasEstadoFicha.Inicial_NavegandoSinCambios;
begin
  Assert.AreEqual(Ord(mfNavegando), Ord(FE.Modo));
  Assert.IsFalse(FE.HayCambios);
end;

procedure TPruebasEstadoFicha.Nuevo_SinCambios_NoPuedeGuardar;
begin
  FE.Nuevo;
  Assert.AreEqual(Ord(mfNuevo), Ord(FE.Modo));
  Assert.IsFalse(FE.PuedeGuardar);
end;

procedure TPruebasEstadoFicha.Nuevo_ConCambio_PuedeGuardar;
begin
  FE.Nuevo;
  FE.MarcarCambio;
  Assert.AreEqual(Ord(mfNuevo), Ord(FE.Modo));
  Assert.IsTrue(FE.PuedeGuardar);
end;

procedure TPruebasEstadoFicha.MarcarCambio_DesdeNavegando_PasaAEditando;
begin
  FE.Elegir;
  FE.MarcarCambio;
  Assert.AreEqual(Ord(mfEditando), Ord(FE.Modo));
  Assert.IsTrue(FE.HayCambios);
end;

procedure TPruebasEstadoFicha.Elegir_DespuesDeCambio_LimpiaCambios;
begin
  FE.Elegir;
  FE.MarcarCambio;
  FE.Elegir;
  Assert.IsFalse(FE.HayCambios);
  Assert.AreEqual(Ord(mfNavegando), Ord(FE.Modo));
end;

procedure TPruebasEstadoFicha.RequiereConfirmar_SoloConCambios;
begin
  FE.Elegir;
  Assert.IsFalse(FE.RequiereConfirmarAbandono);
  FE.MarcarCambio;
  Assert.IsTrue(FE.RequiereConfirmarAbandono);
end;

procedure TPruebasEstadoFicha.Guardado_VuelveANavegando;
begin
  FE.Nuevo;
  FE.MarcarCambio;
  FE.Guardado;
  Assert.AreEqual(Ord(mfNavegando), Ord(FE.Modo));
  Assert.IsFalse(FE.HayCambios);
end;

procedure TPruebasEstadoFicha.Descartado_VuelveANavegando;
begin
  FE.Elegir;
  FE.MarcarCambio;
  FE.Descartado;
  Assert.AreEqual(Ord(mfNavegando), Ord(FE.Modo));
  Assert.IsFalse(FE.HayCambios);
end;

procedure TPruebasEstadoFicha.Navegando_NoPuedeGuardar;
begin
  FE.Elegir;
  Assert.IsFalse(FE.PuedeGuardar);
end;

end.
