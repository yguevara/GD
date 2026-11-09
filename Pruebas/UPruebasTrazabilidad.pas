unit UPruebasTrazabilidad;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasTrazabilidad = class
  public
    [Test]
    procedure TipoDesdeAccion_Conocidas;
    [Test]
    procedure TipoDesdeAccion_Desconocida_EsOtro;
    [Test]
    procedure Orden_Desordenados_DescendenteSinMas;
    [Test]
    procedure Orden_Limite_ConservaRecientesYAvisa;
    [Test]
    procedure Orden_VaciaOMaximoCero_NoFalla;
    [Test]
    procedure Etiqueta_TodosTienenTexto;
  end;

implementation

uses
  UTrazabilidad;

function Ev(F: Double): TEventoDoc;
begin
  Result := Default(TEventoDoc);
  Result.Fecha := F;
end;

procedure TPruebasTrazabilidad.TipoDesdeAccion_Conocidas;
begin
  Assert.AreEqual(Ord(teCreado), Ord(TipoDesdeAccion(5)));
  Assert.AreEqual(Ord(teModificado), Ord(TipoDesdeAccion(3)));
  Assert.AreEqual(Ord(teDepurado), Ord(TipoDesdeAccion(2)));
  Assert.AreEqual(Ord(teConsultado), Ord(TipoDesdeAccion(14)));
  Assert.AreEqual(Ord(teDescargado), Ord(TipoDesdeAccion(ACCION_DESCARGAR)));
end;

procedure TPruebasTrazabilidad.TipoDesdeAccion_Desconocida_EsOtro;
begin
  Assert.AreEqual(Ord(teOtro), Ord(TipoDesdeAccion(999)));
end;

procedure TPruebasTrazabilidad.Orden_Desordenados_DescendenteSinMas;
var
  L: TArray<TEventoDoc>;
  Mas: Boolean;
begin
  L := [Ev(2), Ev(3), Ev(1)];
  OrdenarYLimitar(L, 10, Mas);
  Assert.IsFalse(Mas);
  Assert.AreEqual(3, Length(L));
  Assert.IsTrue(Double(L[0].Fecha) = 3.0);
  Assert.IsTrue(Double(L[1].Fecha) = 2.0);
  Assert.IsTrue(Double(L[2].Fecha) = 1.0);
end;

procedure TPruebasTrazabilidad.Orden_Limite_ConservaRecientesYAvisa;
var
  L: TArray<TEventoDoc>;
  Mas: Boolean;
begin
  L := [Ev(1), Ev(5), Ev(3), Ev(4), Ev(2)];
  OrdenarYLimitar(L, 3, Mas);
  Assert.IsTrue(Mas);
  Assert.AreEqual(3, Length(L));
  Assert.IsTrue(Double(L[0].Fecha) = 5.0);
  Assert.IsTrue(Double(L[2].Fecha) = 3.0);
end;

procedure TPruebasTrazabilidad.Orden_VaciaOMaximoCero_NoFalla;
var
  L: TArray<TEventoDoc>;
  Mas: Boolean;
begin
  L := nil;
  OrdenarYLimitar(L, 3, Mas);
  Assert.IsFalse(Mas);
  L := [Ev(1), Ev(2)];
  OrdenarYLimitar(L, 0, Mas);
  Assert.IsFalse(Mas);
  Assert.AreEqual(2, Length(L));
end;

procedure TPruebasTrazabilidad.Etiqueta_TodosTienenTexto;
var
  T: TTipoEvento;
begin
  for T := Low(TTipoEvento) to High(TTipoEvento) do
    Assert.AreNotEqual('', EtiquetaEvento(T));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasTrazabilidad);

end.
