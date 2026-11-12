unit UPruebasVariablesEditor;

{ Editor visual de variables (UVariablesEditor): lista, vista previa y reglas de
  bloqueo. Sin base de datos. }

interface

uses
  Vcl.Forms, DUnitX.TestFramework, UMetadatosSubserie, UVariablesDatos, UVariablesEditor;

type
  [TestFixture]
  TPruebasVariablesEditor = class
  private
    FForma: TForm;
    FEd: TEditorVariables;
    FCambios: Integer;
    procedure AlCambio(Sender: TObject);
    function V(const ANombre, AEtiqueta: string; ATipo: TTipoMeta; ALong: Integer): TCampoMeta;
    function Tres: TArray<TCampoMeta>;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Cargar_PintaUnItemPorVariable;
    [Test]
    procedure Preview_UnCampoPorVariable_ConEtiqueta;
    [Test]
    procedure Preview_Obligatoria_MarcaAsterisco;
    [Test]
    procedure Preview_CambiarEtiqueta_ActualizaEnVivo;
    [Test]
    procedure Preview_ResaltaLaElegida;
    [Test]
    procedure Libre_NombreYTipoEditables_SinAviso;
    [Test]
    procedure SoloAnadir_ExistentesSoloLectura_ConAviso;
    [Test]
    procedure SoloAnadir_RenombrarNoSurteEfecto;
    [Test]
    procedure Arrastrar_Reordena_YDisparaOnCambio;
  end;

implementation

uses
  System.SysUtils, Vcl.Controls, UTema;

function TPruebasVariablesEditor.V(const ANombre, AEtiqueta: string; ATipo: TTipoMeta;
  ALong: Integer): TCampoMeta;
begin
  Result := Default(TCampoMeta);
  Result.Nombre := ANombre;
  Result.Etiqueta := AEtiqueta;
  Result.Tipo := ATipo;
  Result.Longitud := ALong;
end;

function TPruebasVariablesEditor.Tres: TArray<TCampoMeta>;
begin
  Result := [V('Org', 'Organismo', tmTexto, 20), V('Ent', 'Entidad', tmTexto, 20),
    V('FechaIni', 'Fecha inicial', tmFecha, 0)];
  Result[0].Obligatorio := True;
end;

procedure TPruebasVariablesEditor.AlCambio(Sender: TObject);
begin
  Inc(FCambios);
end;

procedure TPruebasVariablesEditor.Preparar;
begin
  FCambios := 0;
  FForma := TForm.CreateNew(nil);
  FForma.SetBounds(0, 0, 1200, 700);
  FForma.HandleNeeded;
  FEd := TEditorVariables.Create(FForma, TemaClaro, True);
  FEd.Parent := FForma;
  FEd.Align := alClient;
  FEd.OnCambio := AlCambio;
end;

procedure TPruebasVariablesEditor.Limpiar;
begin
  FForma.Free;
end;

procedure TPruebasVariablesEditor.Cargar_PintaUnItemPorVariable;
begin
  FEd.Cargar(Tres, mvLibre);
  Assert.AreEqual(3, FEd.CantidadItems);
end;

procedure TPruebasVariablesEditor.Preview_UnCampoPorVariable_ConEtiqueta;
begin
  FEd.Cargar(Tres, mvLibre);
  Assert.AreEqual(3, FEd.CantidadPrevia);
  Assert.AreEqual('Entidad', FEd.EtiquetaPrevia(1));
end;

procedure TPruebasVariablesEditor.Preview_Obligatoria_MarcaAsterisco;
begin
  FEd.Cargar(Tres, mvLibre);
  Assert.AreEqual('Organismo *', FEd.EtiquetaPrevia(0));
  Assert.AreEqual('Entidad', FEd.EtiquetaPrevia(1));
end;

procedure TPruebasVariablesEditor.Preview_CambiarEtiqueta_ActualizaEnVivo;
begin
  FEd.Cargar(Tres, mvLibre);
  FEd.SeleccionarIndice(1);
  FEd.EscribirEtiqueta('Ente emisor');
  Assert.AreEqual('Ente emisor', FEd.EtiquetaPrevia(1));
  Assert.IsTrue(FEd.HayCambios);
  Assert.IsTrue(FCambios > 0);
end;

procedure TPruebasVariablesEditor.Preview_ResaltaLaElegida;
begin
  FEd.Cargar(Tres, mvLibre);
  FEd.SeleccionarIndice(2);
  Assert.AreEqual(2, FEd.PreviaResaltada);
end;

procedure TPruebasVariablesEditor.Libre_NombreYTipoEditables_SinAviso;
begin
  FEd.Cargar(Tres, mvLibre);
  Assert.IsFalse(FEd.NombreSoloLectura);
  Assert.IsFalse(FEd.TipoDeshabilitado);
  Assert.IsFalse(FEd.AvisoVisible);
end;

procedure TPruebasVariablesEditor.SoloAnadir_ExistentesSoloLectura_ConAviso;
begin
  FEd.Cargar(Tres, mvSoloAnadir);
  FEd.SeleccionarIndice(0);
  Assert.IsTrue(FEd.NombreSoloLectura);
  Assert.IsTrue(FEd.TipoDeshabilitado);
  Assert.IsTrue(FEd.AvisoVisible);
end;

procedure TPruebasVariablesEditor.SoloAnadir_RenombrarNoSurteEfecto;
begin
  FEd.Cargar(Tres, mvSoloAnadir);
  FEd.SeleccionarIndice(0);
  FEd.EscribirNombre('Otro');
  Assert.AreEqual('Org', FEd.Resultado[0].Nombre);
end;

procedure TPruebasVariablesEditor.Arrastrar_Reordena_YDisparaOnCambio;
begin
  FEd.Cargar(Tres, mvLibre);
  FCambios := 0;
  FEd.Arrastrar(0, 2);
  Assert.AreEqual('Ent', FEd.Resultado[0].Nombre);
  Assert.AreEqual('Org', FEd.Resultado[2].Nombre);
  Assert.IsTrue(FCambios > 0);
  Assert.AreEqual('Organismo *', FEd.EtiquetaPrevia(2));
end;

end.
