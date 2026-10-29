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
    [Test]
    procedure Arbol_PadreIdDuplicado_ElijePorPrefijo;
    [Test]
    procedure Arbol_PadreIdDuplicado_SinPrefijo_SinPadre;
  end;

  [TestFixture]
  TPruebasAlcance = class
  private
    FArbol: TArbolNodos;
    function Crear(EsAdmin: Boolean; const Nodos: TArray<TAsignacionNodo>;
      const Subs: TArray<TSubserieAsignada>): TAlcanceUsuario;
    function EnConjunto(const Lista: TArray<TClaveNodo>;
      const Nodo: TClaveNodo): Boolean;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Director_VeHijos;
    [Test]
    procedure EGD_NoDesciende;
    [Test]
    procedure EGD_PuedeEliminarEnSuNodo;
    [Test]
    procedure Usuario_NoPuedeEliminar;
    [Test]
    procedure Usuario_SoloSubserieAsignada;
    [Test]
    procedure Publico_LoVeCualquiera;
    [Test]
    procedure Publico_NoDaPermisoDeEditar;
    [Test]
    procedure SinAsignaciones_SoloPublico;
    [Test]
    procedure AccesoInvalido_NoEsPublico;
    [Test]
    procedure Administrador_VeTodo;
    [Test]
    procedure VariosRoles_SeUnen;
    [Test]
    procedure NodosVisibles_IncluyeAncestros;
    [Test]
    procedure AsignacionANodoInexistente_NoDaAcceso;
    [Test]
    procedure NodosCompletos_DirectorYEGD;
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

procedure TPruebasArbol.Arbol_PadreIdDuplicado_ElijePorPrefijo;
var
  Anc: TArray<TClaveNodo>;
begin
  // el hijo se inserta antes que los padres (orden inverso)
  FArbol.Agregar(Clave('A.4.2', 300), 160);
  FArbol.Agregar(Clave('A.3', 160), 1);
  FArbol.Agregar(Clave('A.1', 160), 1);
  FArbol.Agregar(Clave('A.4', 160), 1);
  Assert.IsTrue(FArbol.EsDescendiente(Clave('A.4', 160), Clave('A.4.2', 300)));
  Assert.IsFalse(FArbol.EsDescendiente(Clave('A.1', 160), Clave('A.4.2', 300)));
  Assert.IsFalse(FArbol.EsDescendiente(Clave('A.3', 160), Clave('A.4.2', 300)));
  Anc := FArbol.Ancestros(Clave('A.4.2', 300));
  Assert.AreEqual(1, Integer(Length(Anc)));
  Assert.AreEqual('A.4', Anc[0].IdEstructura);
end;

procedure TPruebasArbol.Arbol_PadreIdDuplicado_SinPrefijo_SinPadre;
var
  Anc: TArray<TClaveNodo>;
begin
  FArbol.Agregar(Clave('A.1', 160), 1);
  FArbol.Agregar(Clave('A.3', 160), 1);
  FArbol.Agregar(Clave('A.4', 160), 1);
  FArbol.Agregar(Clave('B.9.1', 300), 160);
  Assert.IsFalse(FArbol.EsDescendiente(Clave('A.1', 160), Clave('B.9.1', 300)));
  Assert.IsFalse(FArbol.EsDescendiente(Clave('A.3', 160), Clave('B.9.1', 300)));
  Assert.IsFalse(FArbol.EsDescendiente(Clave('A.4', 160), Clave('B.9.1', 300)));
  Anc := FArbol.Ancestros(Clave('B.9.1', 300));
  Assert.AreEqual(0, Integer(Length(Anc)));
end;

function Asig(const N: TClaveNodo; R: TRolNodo): TAsignacionNodo;
begin
  Result.Nodo := N;
  Result.Rol := R;
end;

function Sub(const N: TClaveNodo; const Cod: string): TSubserieAsignada;
begin
  Result.Nodo := N;
  Result.CodSubs := Cod;
end;

{ TPruebasAlcance }

procedure TPruebasAlcance.Preparar;
begin
  FArbol := TArbolNodos.Create;
  FArbol.Agregar(Clave('A', 1), 0);
  FArbol.Agregar(Clave('A.1', 82), 1);
  FArbol.Agregar(Clave('A.4', 101), 1);
  FArbol.Agregar(Clave('A.4.3', 104), 101);
end;

procedure TPruebasAlcance.Limpiar;
begin
  FArbol.Free;
end;

function TPruebasAlcance.Crear(EsAdmin: Boolean;
  const Nodos: TArray<TAsignacionNodo>;
  const Subs: TArray<TSubserieAsignada>): TAlcanceUsuario;
begin
  Result := TAlcanceUsuario.Create(EsAdmin, FArbol, Nodos, Subs, nil);
end;

function TPruebasAlcance.EnConjunto(const Lista: TArray<TClaveNodo>;
  const Nodo: TClaveNodo): Boolean;
var
  N: TClaveNodo;
begin
  Result := False;
  for N in Lista do
    if (NormalizaClave(N.IdEstructura) = NormalizaClave(Nodo.IdEstructura)) and
      (N.Id = Nodo.Id) then
      Exit(True);
end;

procedure TPruebasAlcance.Director_VeHijos;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, [Asig(Clave('A.4', 101), rnDirector)], nil);
  try
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.4.3', 104), '014001', 2));
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.4', 101), '074', 3));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.1', 82), '014001', 2));
    Assert.IsTrue(Al.PuedeRealizar(acEditar, Clave('A.4.3', 104), '014001'));
    Assert.IsFalse(Al.PuedeRealizar(acEliminar, Clave('A.4.3', 104), '014001'));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.EGD_NoDesciende;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, [Asig(Clave('A.4', 101), rnEGD)], nil);
  try
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.4', 101), '014001', 2));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4.3', 104), '014001', 2));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.EGD_PuedeEliminarEnSuNodo;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, [Asig(Clave('A.4', 101), rnEGD)], nil);
  try
    Assert.IsTrue(Al.PuedeRealizar(acEliminar, Clave('A.4', 101), '074'));
    Assert.IsTrue(Al.PuedeRealizar(acAsignarUsuarios, Clave('A.4', 101), '074'));
    Assert.IsFalse(Al.PuedeRealizar(acEliminar, Clave('A.4.3', 104), '074'));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Usuario_NoPuedeEliminar;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, nil, [Sub(Clave('A.4.3', 104), '014001')]);
  try
    Assert.IsTrue(Al.PuedeRealizar(acEditar, Clave('A.4.3', 104), '014001'));
    Assert.IsFalse(Al.PuedeRealizar(acEliminar, Clave('A.4.3', 104), '014001'));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Usuario_SoloSubserieAsignada;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, nil, [Sub(Clave('A.4.3', 104), '014001')]);
  try
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.4.3', 104), '014001', 2));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4.3', 104), '074', 2));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.1', 82), '014001', 2));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Publico_LoVeCualquiera;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, nil, nil); // Visor
  try
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.1', 82), '014001', 1));
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.4.3', 104), '074', 1));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Publico_NoDaPermisoDeEditar;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, nil, [Sub(Clave('A.4.3', 104), '014001')]);
  try
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.1', 82), '014001', 1));
    Assert.IsFalse(Al.PuedeRealizar(acEditar, Clave('A.1', 82), '014001'));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.SinAsignaciones_SoloPublico;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, nil, nil);
  try
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.4', 101), '014001', 1));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4', 101), '014001', 2));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4', 101), '014001', 3));
    Assert.AreEqual(0, Integer(Length(Al.NodosVisibles)));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.AccesoInvalido_NoEsPublico;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, nil, nil);
  try
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4', 101), '014001', 0));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4', 101), '014001', 4));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4', 101), '014001', -1));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Administrador_VeTodo;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(True, nil, nil);
  try
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.1', 82), '074', 3));
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.4.3', 104), '014001', 0));
    Assert.IsTrue(Al.PuedeRealizar(acEditar, Clave('A.1', 82), '074'));
    Assert.IsFalse(Al.PuedeRealizar(acEliminar, Clave('A.1', 82), '074'));
    Assert.AreEqual(4, Integer(Length(Al.NodosVisibles)));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.VariosRoles_SeUnen;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, [Asig(Clave('A.1', 82), rnDirector)],
    [Sub(Clave('A.4.3', 104), '014001')]);
  try
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.1', 82), '074', 2));
    Assert.IsTrue(Al.PuedeVerDocumento(Clave('A.4.3', 104), '014001', 2));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4.3', 104), '074', 2));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.NodosVisibles_IncluyeAncestros;
var
  Al: TAlcanceUsuario;
  V: TArray<TClaveNodo>;
begin
  Al := Crear(False, nil, [Sub(Clave('A.4.3', 104), '014001')]);
  try
    V := Al.NodosVisibles;
    Assert.AreEqual(3, Integer(Length(V)));
    Assert.IsTrue(EnConjunto(V, Clave('A', 1)));
    Assert.IsTrue(EnConjunto(V, Clave('A.4', 101)));
    Assert.IsTrue(EnConjunto(V, Clave('A.4.3', 104)));
    Assert.IsFalse(EnConjunto(V, Clave('A.1', 82)));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.AsignacionANodoInexistente_NoDaAcceso;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False,
    [Asig(Clave('Z.9', 999), rnDirector), Asig(Clave('Z.8', 998), rnEGD)],
    [Sub(Clave('Z.7', 997), '014001')]);
  try
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('Z.9', 999), '014001', 2));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('Z.8', 998), '014001', 2));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('Z.7', 997), '014001', 2));
    Assert.IsFalse(Al.PuedeRealizar(acEditar, Clave('Z.9', 999), '014001'));
    Assert.AreEqual(0, Integer(Length(Al.NodosVisibles)));
    Assert.AreEqual(0, Integer(Length(Al.NodosCompletos)));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.NodosCompletos_DirectorYEGD;
var
  Al: TAlcanceUsuario;
  C: TArray<TClaveNodo>;
begin
  Al := Crear(False,
    [Asig(Clave('A.4', 101), rnDirector), Asig(Clave('A.1', 82), rnEGD)],
    [Sub(Clave('A.4.3', 104), '014001')]);
  try
    C := Al.NodosCompletos;
    Assert.AreEqual(3, Integer(Length(C)));
    Assert.IsTrue(EnConjunto(C, Clave('A.4', 101)));
    Assert.IsTrue(EnConjunto(C, Clave('A.4.3', 104)));
    Assert.IsTrue(EnConjunto(C, Clave('A.1', 82)));
  finally
    Al.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasReglas);
  TDUnitX.RegisterTestFixture(TPruebasArbol);
  TDUnitX.RegisterTestFixture(TPruebasAlcance);

end.
