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
    procedure NodosConPublica_SonVisiblesConAncestros;
    [Test]
    procedure NodosConPublica_NoDanCoberturaDeDocumentos;
    [Test]
    procedure EGD_EditaTopografiaDeSuNodo;
    [Test]
    procedure Director_Usuario_Visor_NoEditanTopografia;
    [Test]
    procedure Administrador_EditaTopografia;
    [Test]
    procedure EGD_EliminaSinVentanaDeDias;
    [Test]
    procedure Director_EliminaSoloElPrimerDia;
    [Test]
    procedure Usuario_Visor_Administrador_NoEliminan;
    [Test]
    procedure Eliminar_NodoRepetido160_NoMezcla;
    [Test]
    procedure Eliminar_ClaveConEspacios;
    [Test]
    procedure AsignacionANodoInexistente_NoDaAcceso;
    [Test]
    procedure NodosCompletos_DirectorYEGD;
    [Test]
    procedure Usuario_CodSubsVacio_NoDaAcceso;
    [Test]
    procedure Propiedades_AdministradorYPublicas;
    [Test]
    procedure SubseriesEfectivas_DescartaVaciasEInexistentes;
  end;

implementation

uses
  System.SysUtils;

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
  for R in [rnUsuario, rnDirector] do
    for A := Low(TAccion) to High(TAccion) do
      Assert.AreEqual(A in [acVer, acAgregar, acEditar], RolPermite(R, A));
  // el administrador ademas edita la topografia
  for A := Low(TAccion) to High(TAccion) do
    Assert.AreEqual(A in [acVer, acAgregar, acEditar, acEditarTopografia],
      RolPermite(rnAdministrador, A));
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

procedure TPruebasAlcance.NodosConPublica_SonVisiblesConAncestros;
var
  Al: TAlcanceUsuario;
  V: TArray<TClaveNodo>;
begin
  // un Visor sin asignaciones ve el arbol hasta los nodos con subserie publica
  Al := Crear(False, nil, nil);
  try
    Al.NodosConPublica := [Clave('A.4.3', 104), Clave('Z.9', 999)];
    V := Al.NodosVisibles;
    Assert.AreEqual(3, Integer(Length(V)), 'A, A.4 y A.4.3; el nodo inexistente no cuenta');
    Assert.IsTrue(EnConjunto(V, Clave('A', 1)));
    Assert.IsTrue(EnConjunto(V, Clave('A.4', 101)));
    Assert.IsTrue(EnConjunto(V, Clave('A.4.3', 104)));
    Assert.IsFalse(EnConjunto(V, Clave('A.1', 82)));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.NodosConPublica_NoDanCoberturaDeDocumentos;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, nil, nil);
  try
    Al.NodosConPublica := [Clave('A.4.3', 104)];
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4.3', 104), '014001', 2));
    Assert.IsFalse(Al.PuedeRealizar(acEditar, Clave('A.4.3', 104), '014001'));
    Assert.AreEqual(0, Integer(Length(Al.NodosCompletos)));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.EGD_EditaTopografiaDeSuNodo;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, [Asig(Clave('A.4', 101), rnEGD)], nil);
  try
    Assert.IsTrue(Al.PuedeRealizar(acEditarTopografia, Clave('A.4', 101), '074'));
    Assert.IsFalse(Al.PuedeRealizar(acEditarTopografia, Clave('A.4.3', 104), '074'),
      'El EGD no desciende a los hijos');
    Assert.IsFalse(Al.PuedeRealizar(acEditarTopografia, Clave('A.1', 82), '074'));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Director_Usuario_Visor_NoEditanTopografia;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, [Asig(Clave('A.4', 101), rnDirector)],
    [Sub(Clave('A.4.3', 104), '074')]);
  try
    Assert.IsFalse(Al.PuedeRealizar(acEditarTopografia, Clave('A.4', 101), '074'));
    Assert.IsFalse(Al.PuedeRealizar(acEditarTopografia, Clave('A.4.3', 104), '074'));
  finally
    Al.Free;
  end;
  Assert.IsFalse(RolPermite(rnVisor, acEditarTopografia));
  Assert.IsFalse(RolPermite(rnUsuario, acEditarTopografia));
  Assert.IsFalse(RolPermite(rnDirector, acEditarTopografia));
end;

procedure TPruebasAlcance.Administrador_EditaTopografia;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(True, nil, nil);
  try
    Assert.IsTrue(Al.PuedeRealizar(acEditarTopografia, Clave('A.4.3', 104), '074'));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.EGD_EliminaSinVentanaDeDias;
var
  Al: TAlcanceUsuario;
  Dias: Integer;
const
  DIAS_PRUEBA: array[0..4] of Integer = (0, 1, 2, 6, 4000);
begin
  Al := Crear(False, [Asig(Clave('A.4', 101), rnEGD)], nil);
  try
    for Dias in DIAS_PRUEBA do
      Assert.IsTrue(Al.PuedeEliminarDocumento(Clave('A.4', 101), '074', Dias),
        'dias=' + IntToStr(Dias));
    Assert.IsFalse(Al.PuedeEliminarDocumento(Clave('A.4.3', 104), '074', 0),
      'El EGD no elimina en los hijos');
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Director_EliminaSoloElPrimerDia;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, [Asig(Clave('A.4', 101), rnDirector)], nil);
  try
    Assert.IsTrue(Al.PuedeEliminarDocumento(Clave('A.4.3', 104), '074', 0));
    Assert.IsTrue(Al.PuedeEliminarDocumento(Clave('A.4.3', 104), '074', 1));
    Assert.IsFalse(Al.PuedeEliminarDocumento(Clave('A.4.3', 104), '074', 2));
    Assert.IsTrue(Al.PuedeEliminarDocumento(Clave('A.4', 101), '074', 1));
    Assert.IsFalse(Al.PuedeEliminarDocumento(Clave('A.4', 101), '074', 3));
    Assert.IsTrue(Al.PuedeEliminarDocumento(Clave('A.4.3', 104), '074', -5),
      'Dias negativos cuentan como 0');
    Assert.IsFalse(Al.PuedeEliminarDocumento(Clave('A.1', 82), '074', 0));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Usuario_Visor_Administrador_NoEliminan;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, nil, [Sub(Clave('A.4.3', 104), '074')]);
  try
    Assert.IsFalse(Al.PuedeEliminarDocumento(Clave('A.4.3', 104), '074', 0));
  finally
    Al.Free;
  end;
  Al := Crear(False, nil, nil);
  try
    Assert.IsFalse(Al.PuedeEliminarDocumento(Clave('A.4.3', 104), '074', 0));
  finally
    Al.Free;
  end;
  Al := Crear(True, nil, nil);
  try
    Assert.IsFalse(Al.PuedeEliminarDocumento(Clave('A.4.3', 104), '074', 0));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Eliminar_NodoRepetido160_NoMezcla;
var
  Al: TAlcanceUsuario;
begin
  FArbol.Agregar(Clave('A.4.6', 160), 101);
  FArbol.Agregar(Clave('A.1.7', 160), 82);
  Al := Crear(False, [Asig(Clave('A.4.6', 160), rnEGD)], nil);
  try
    Assert.IsTrue(Al.PuedeEliminarDocumento(Clave('A.4.6', 160), '074', 900));
    Assert.IsFalse(Al.PuedeEliminarDocumento(Clave('A.1.7', 160), '074', 900));
    Assert.IsTrue(Al.PuedeRealizar(acEditarTopografia, Clave('A.4.6', 160), '074'));
    Assert.IsFalse(Al.PuedeRealizar(acEditarTopografia, Clave('A.1.7', 160), '074'));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Eliminar_ClaveConEspacios;
var
  Al: TAlcanceUsuario;
begin
  FArbol.Agregar(Clave('A.4.6', 160), 101);
  Al := Crear(False, [Asig(Clave('A.4.6', 160), rnEGD)], nil);
  try
    Assert.IsTrue(Al.PuedeEliminarDocumento(Clave('a.4.6 ', 160), '074', 900));
    Assert.IsTrue(Al.PuedeRealizar(acEditarTopografia, Clave(' a.4.6', 160), '074'));
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

procedure TPruebasAlcance.Usuario_CodSubsVacio_NoDaAcceso;
var
  Al: TAlcanceUsuario;
begin
  Al := Crear(False, nil, [Sub(Clave('A.4.3', 104), ''), Sub(Clave('A.4', 101), '   ')]);
  try
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4.3', 104), '', 2));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4.3', 104), '014001', 2));
    Assert.IsFalse(Al.PuedeVerDocumento(Clave('A.4', 101), ' ', 3));
    Assert.IsFalse(Al.PuedeRealizar(acEditar, Clave('A.4.3', 104), ''));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.Propiedades_AdministradorYPublicas;
var
  Al: TAlcanceUsuario;
begin
  Al := TAlcanceUsuario.Create(True, FArbol, nil, nil, ['074', '014001']);
  try
    Assert.IsTrue(Al.EsAdministrador);
    Assert.AreEqual(2, Integer(Length(Al.SubseriesPublicas)));
    Assert.AreEqual('074', Al.SubseriesPublicas[0]);
  finally
    Al.Free;
  end;
  Al := Crear(False, nil, nil);
  try
    Assert.IsFalse(Al.EsAdministrador);
    Assert.AreEqual(0, Integer(Length(Al.SubseriesPublicas)));
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcance.SubseriesEfectivas_DescartaVaciasEInexistentes;
var
  Al: TAlcanceUsuario;
  E: TArray<TSubserieAsignada>;
begin
  Al := Crear(False, nil, [Sub(Clave('a.4.3 ', 104), ' 014001 '),
    Sub(Clave('A.4.3', 104), ''), Sub(Clave('Z.9', 999), '074')]);
  try
    E := Al.SubseriesEfectivas;
    Assert.AreEqual(1, Integer(Length(E)));
    Assert.AreEqual('A.4.3', E[0].Nodo.IdEstructura);
    Assert.AreEqual(104, E[0].Nodo.Id);
    Assert.AreEqual('014001', E[0].CodSubs);
  finally
    Al.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasReglas);
  TDUnitX.RegisterTestFixture(TPruebasArbol);
  TDUnitX.RegisterTestFixture(TPruebasAlcance);

end.
