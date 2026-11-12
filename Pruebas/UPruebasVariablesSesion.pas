unit UPruebasVariablesSesion;

{ Sesion de edicion de variables (UVariablesSesion). Sin base de datos. }

interface

uses
  DUnitX.TestFramework, UMetadatosSubserie, UVariablesDatos, UVariablesSesion;

type
  [TestFixture]
  TPruebasVariablesSesion = class
  private
    FS: TSesionVariables;
    function V(const ANombre, AEtiqueta: string; ATipo: TTipoMeta; ALong: Integer): TCampoMeta;
    function Dos: TArray<TCampoMeta>;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Libre_TodoEditable;
    [Test]
    procedure SoloAnadir_ExistentesBloqueadas_NuevasLibres;
    [Test]
    procedure SoloAnadir_NoPermiteQuitarExistente_YSiLaNueva;
    [Test]
    procedure SoloAnadir_Modificar_ConservaNombreTipoLongitud;
    [Test]
    procedure Mover_ReordenaYMarcaCambio;
    [Test]
    procedure Agregar_ProponeNombreNoRepetido;
    [Test]
    procedure Descartar_VuelveAlOriginal;
    [Test]
    procedure Errores_SePropagan;
    [Test]
    procedure SinCambios_HayCambiosFalse;
    [Test]
    procedure Resultado_RenumeraOrden;
  end;

implementation

uses
  System.SysUtils, UErroresCampo;

function TPruebasVariablesSesion.V(const ANombre, AEtiqueta: string; ATipo: TTipoMeta;
  ALong: Integer): TCampoMeta;
begin
  Result := Default(TCampoMeta);
  Result.Nombre := ANombre;
  Result.Etiqueta := AEtiqueta;
  Result.Tipo := ATipo;
  Result.Longitud := ALong;
end;

function TPruebasVariablesSesion.Dos: TArray<TCampoMeta>;
begin
  Result := [V('Org', 'Organismo', tmTexto, 20), V('Ent', 'Entidad', tmTexto, 20)];
end;

procedure TPruebasVariablesSesion.Preparar;
begin
  FS := TSesionVariables.Create(True);
end;

procedure TPruebasVariablesSesion.Limpiar;
begin
  FS.Free;
end;

procedure TPruebasVariablesSesion.Libre_TodoEditable;
begin
  FS.Cargar(Dos, mvLibre);
  Assert.IsTrue(FS.PuedeEditarNombre(0));
  Assert.IsTrue(FS.PuedeEditarTipo(1));
  Assert.IsTrue(FS.PuedeQuitar(0));
end;

procedure TPruebasVariablesSesion.SoloAnadir_ExistentesBloqueadas_NuevasLibres;
var
  N: Integer;
begin
  FS.Cargar(Dos, mvSoloAnadir);
  Assert.IsFalse(FS.PuedeEditarNombre(0));
  Assert.IsFalse(FS.PuedeEditarTipo(1));
  N := FS.Agregar;
  Assert.IsTrue(FS.PuedeEditarNombre(N));
  Assert.IsTrue(FS.PuedeEditarTipo(N));
end;

procedure TPruebasVariablesSesion.SoloAnadir_NoPermiteQuitarExistente_YSiLaNueva;
var
  N: Integer;
begin
  FS.Cargar(Dos, mvSoloAnadir);
  Assert.IsFalse(FS.Quitar(0));
  Assert.AreEqual(2, FS.Count);
  N := FS.Agregar;
  Assert.IsTrue(FS.Quitar(N));
  Assert.AreEqual(2, FS.Count);
end;

procedure TPruebasVariablesSesion.SoloAnadir_Modificar_ConservaNombreTipoLongitud;
var
  C: TCampoMeta;
begin
  FS.Cargar(Dos, mvSoloAnadir);
  C := V('Otro', 'Organismo emisor', tmEntero, 5);
  C.Obligatorio := True;
  FS.Modificar(0, C);
  Assert.AreEqual('Org', FS.Campo(0).Nombre);
  Assert.IsTrue(FS.Campo(0).Tipo = tmTexto);
  Assert.AreEqual(20, FS.Campo(0).Longitud);
  Assert.AreEqual('Organismo emisor', FS.Campo(0).Etiqueta);
  Assert.IsTrue(FS.Campo(0).Obligatorio);
end;

procedure TPruebasVariablesSesion.Mover_ReordenaYMarcaCambio;
begin
  FS.Cargar(Dos, mvLibre);
  FS.Mover(0, 1);
  Assert.AreEqual('Ent', FS.Campo(0).Nombre);
  Assert.AreEqual('Org', FS.Campo(1).Nombre);
  Assert.IsTrue(FS.HayCambios);
  FS.Mover(1, 0);
  Assert.IsFalse(FS.HayCambios);
end;

procedure TPruebasVariablesSesion.Agregar_ProponeNombreNoRepetido;
var
  A, B: Integer;
begin
  FS.Cargar([V('Variable2', 'Dos', tmTexto, 10)], mvLibre);
  A := FS.Agregar;
  B := FS.Agregar;
  Assert.AreNotEqual(FS.Campo(A).Nombre, FS.Campo(B).Nombre);
  Assert.AreNotEqual('Variable2', FS.Campo(A).Nombre);
  Assert.AreEqual(0, Length(FS.Errores));
end;

procedure TPruebasVariablesSesion.Descartar_VuelveAlOriginal;
begin
  FS.Cargar(Dos, mvLibre);
  FS.Agregar;
  FS.Quitar(0);
  Assert.IsTrue(FS.HayCambios);
  FS.Descartar;
  Assert.AreEqual(2, FS.Count);
  Assert.IsFalse(FS.HayCambios);
end;

procedure TPruebasVariablesSesion.Errores_SePropagan;
begin
  FS.Cargar(Dos, mvLibre);
  FS.Modificar(1, V('select', 'Entidad', tmTexto, 20));
  Assert.AreEqual(1, Length(FS.Errores));
  Assert.AreEqual('select.nombre', FS.Errores[0].Campo);
end;

procedure TPruebasVariablesSesion.SinCambios_HayCambiosFalse;
begin
  FS.Cargar(Dos, mvLibre);
  Assert.IsFalse(FS.HayCambios);
  Assert.AreEqual(0, Length(FS.Errores));
end;

procedure TPruebasVariablesSesion.Resultado_RenumeraOrden;
var
  R: TArray<TCampoMeta>;
begin
  FS.Cargar(Dos, mvLibre);
  FS.Mover(1, 0);
  R := FS.Resultado;
  Assert.AreEqual(1, R[0].Orden);
  Assert.AreEqual('Ent', R[0].Nombre);
  Assert.AreEqual(2, R[1].Orden);
end;

end.
