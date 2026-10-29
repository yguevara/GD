unit UPruebasAlcance;

interface

uses
  DUnitX.TestFramework, UAlcance;

type
  [TestFixture]
  TPruebasReglas = class
  public
    [Test]
    procedure RolPermite_Visor_SoloVer;
    [Test]
    procedure RolPermite_Usuario_VerAgregarEditar;
    [Test]
    procedure RolPermite_EGD_Todo;
    [Test]
    procedure NormalizaClave_MinusculasYEspacios;
  end;

  [TestFixture]
  TPruebasArbol = class
  private
    FArbol: TArbolNodos;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Arbol_Descendiente_HijosYNietos;
    [Test]
    procedure Arbol_IdDuplicado_NoMezcla;
    [Test]
    procedure Arbol_ClaveConEspacio_EsMismoNodo;
    [Test]
    procedure Arbol_PadreInexistente_SinHerencia;
  end;

implementation

function Clave(const AIdEstructura: string; AId: Integer): TClaveNodo;
begin
  Result.IdEstructura := AIdEstructura;
  Result.Id := AId;
end;

{ TPruebasReglas }

procedure TPruebasReglas.RolPermite_Visor_SoloVer;
var
  A: TAccion;
begin
  for A := Low(TAccion) to High(TAccion) do
    Assert.AreEqual(A = acVer, RolPermite(rnVisor, A));
end;

procedure TPruebasReglas.RolPermite_Usuario_VerAgregarEditar;
var
  R: TRolNodo;
  A: TAccion;
begin
  for R in [rnUsuario, rnDirector, rnAdministrador] do
    for A := Low(TAccion) to High(TAccion) do
      Assert.AreEqual(A in [acVer, acAgregar, acEditar], RolPermite(R, A));
end;

procedure TPruebasReglas.RolPermite_EGD_Todo;
var
  A: TAccion;
begin
  for A := Low(TAccion) to High(TAccion) do
    Assert.IsTrue(RolPermite(rnEGD, A));
end;

procedure TPruebasReglas.NormalizaClave_MinusculasYEspacios;
begin
  Assert.AreEqual('A.1.6', NormalizaClave('a.1.6 '));
end;

{ TPruebasArbol }

procedure TPruebasArbol.Preparar;
begin
  FArbol := TArbolNodos.Create;
end;

procedure TPruebasArbol.Limpiar;
begin
  FArbol.Free;
end;

procedure TPruebasArbol.Arbol_Descendiente_HijosYNietos;
begin
  FArbol.Agregar(Clave('A', 1), 0);
  FArbol.Agregar(Clave('A.4', 101), 1);
  FArbol.Agregar(Clave('A.4.3', 104), 101);
  Assert.IsTrue(FArbol.EsDescendiente(Clave('A.4', 101), Clave('A.4.3', 104)));
  Assert.IsFalse(FArbol.EsDescendiente(Clave('A.4.3', 104), Clave('A.4', 101)));
end;

procedure TPruebasArbol.Arbol_IdDuplicado_NoMezcla;
begin
  FArbol.Agregar(Clave('A', 1), 0);
  FArbol.Agregar(Clave('A.1', 82), 1);
  FArbol.Agregar(Clave('A.3', 92), 1);
  FArbol.Agregar(Clave('A.4', 101), 1);
  FArbol.Agregar(Clave('A.1.7', 160), 82);
  FArbol.Agregar(Clave('A.3.3', 160), 92);
  FArbol.Agregar(Clave('A.4.6', 160), 101);
  Assert.IsFalse(FArbol.EsDescendiente(Clave('A.4', 101), Clave('A.1.7', 160)));
  Assert.IsTrue(FArbol.EsDescendiente(Clave('A.1', 82), Clave('A.1.7', 160)));
end;

procedure TPruebasArbol.Arbol_ClaveConEspacio_EsMismoNodo;
begin
  FArbol.Agregar(Clave('A.1.6', 50), 0);
  Assert.IsTrue(FArbol.Contiene(Clave('A.1.6 ', 50)));
  Assert.IsTrue(FArbol.Contiene(Clave('a.1.6', 50)));
end;

procedure TPruebasArbol.Arbol_PadreInexistente_SinHerencia;
var
  Anc: TArray<TClaveNodo>;
begin
  FArbol.Agregar(Clave('A', 1), 0);
  FArbol.Agregar(Clave('A.6', 200), 1);
  FArbol.Agregar(Clave('A.6..3.3', 300), 999);
  Assert.IsFalse(FArbol.EsDescendiente(Clave('A', 1), Clave('A.6..3.3', 300)));
  Assert.IsFalse(FArbol.EsDescendiente(Clave('A.6', 200), Clave('A.6..3.3', 300)));
  Anc := FArbol.Ancestros(Clave('A.6..3.3', 300));
  Assert.AreEqual(0, Integer(Length(Anc)));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasReglas);
  TDUnitX.RegisterTestFixture(TPruebasArbol);

end.
