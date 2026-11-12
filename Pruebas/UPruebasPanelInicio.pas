unit UPruebasPanelInicio;

{ Panel de inicio del nodo (UInicioNodo): cifras, acciones, etapas del ciclo y
  "Primeros pasos" plegable. Sin base de datos. Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework, Vcl.Forms, UInicioNodo, UInicioDatos, UTema;

type
  [TestFixture]
  TPruebasPanelInicio = class
  private
    FForma: TForm;
    FPanel: TPanelInicio;
    FUltima: string;
    FCuenta: Integer;
    FRuta: string;
    procedure AlAccion(const AClave: string);
    function Resumen(ADocs, ASub, ASer, ASinUbic, APrest: Integer): TResumenInicio;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Mostrar_PoneLasCifras;
    [Test]
    procedure Mostrar_ConMilesUsaSeparador;
    [Test]
    procedure Boton_Agregar_Dispara_OnAccion;
    [Test]
    procedure Boton_Agregar_SinPermiso_NoDispara;
    [Test]
    procedure Etapa_Prestamo_Dispara_Prestamos;
    [Test]
    procedure Etapa_NoDisponible_NoDispara;
    [Test]
    procedure Etapa_Ubicacion_EsSoloInformativa;
    [Test]
    procedure Paso3_SinPermisoAgregar_HablaDeBuscar;
    [Test]
    procedure Paso3_ConPermisoAgregar_HablaDeAgregar;
    [Test]
    procedure Ciclo_SinPermiso_Oculto;
    [Test]
    procedure Ciclo_ConPermiso_Visible;
    [Test]
    procedure PrimerosPasos_AlternarOculta_YSePersiste;
    [Test]
    procedure PrimerosPasos_ArchivoCorrupto_QuedaVisible;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, Vcl.Controls;

procedure TPruebasPanelInicio.Preparar;
begin
  FUltima := '';
  FCuenta := 0;
  FRuta := TPath.Combine(TPath.GetTempPath, 'pr_inicio_nodo.ini');
  if FileExists(FRuta) then
    DeleteFile(FRuta);
  FForma := TForm.CreateNew(nil);
  FForma.SetBounds(0, 0, 1000, 800);
  FPanel := TPanelInicio.Create(FForma, TemaClaro);
  FPanel.Parent := FForma;
  FPanel.Align := alClient;
  FPanel.OnAccion := AlAccion;
  FPanel.ArchivoConfig := FRuta;
end;

procedure TPruebasPanelInicio.Limpiar;
begin
  FForma.Free;
  if FileExists(FRuta) then
    DeleteFile(FRuta);
end;

procedure TPruebasPanelInicio.AlAccion(const AClave: string);
begin
  FUltima := AClave;
  Inc(FCuenta);
end;

function TPruebasPanelInicio.Resumen(ADocs, ASub, ASer, ASinUbic, APrest: Integer): TResumenInicio;
begin
  Result.Documentos := ADocs;
  Result.Subseries := ASub;
  Result.Series := ASer;
  Result.SinUbicacion := ASinUbic;
  Result.Prestados := APrest;
end;

procedure TPruebasPanelInicio.Mostrar_PoneLasCifras;
begin
  FPanel.Mostrar(Resumen(120, 5, 2, 900, 3), 'Estructura');
  Assert.AreEqual('120', FPanel.TextoCifra('documentos'));
  Assert.AreEqual('5', FPanel.TextoCifra('subseries'));
  Assert.AreEqual('2', FPanel.TextoCifra('series'));
  Assert.AreEqual('900', FPanel.TextoCifra('sinubicacion'));
  Assert.AreEqual('3', FPanel.TextoCifra('prestados'));
end;

procedure TPruebasPanelInicio.Mostrar_ConMilesUsaSeparador;
begin
  FPanel.Mostrar(Resumen(1284, 0, 0, 0, 0), 'Estructura');
  Assert.AreEqual('1 284', FPanel.TextoCifra('documentos'));
end;

procedure TPruebasPanelInicio.Boton_Agregar_Dispara_OnAccion;
begin
  FPanel.FijarPermiso('agregar', True);
  FPanel.Pulsar('agregar');
  Assert.AreEqual('agregar', FUltima);
  Assert.AreEqual(1, FCuenta);
end;

procedure TPruebasPanelInicio.Boton_Agregar_SinPermiso_NoDispara;
begin
  FPanel.FijarPermiso('agregar', False);
  FPanel.Pulsar('agregar');
  Assert.AreEqual(0, FCuenta);
  Assert.IsFalse(FPanel.AccionVisible('agregar'));
end;

procedure TPruebasPanelInicio.Etapa_Prestamo_Dispara_Prestamos;
begin
  FPanel.FijarPermiso('prestamos', True);
  FPanel.Pulsar('etapa:prestamo');
  Assert.AreEqual('prestamos', FUltima);
end;

procedure TPruebasPanelInicio.Etapa_NoDisponible_NoDispara;
begin
  FPanel.FijarPermiso('traslados', False);
  FPanel.Pulsar('etapa:transferencia');
  Assert.AreEqual(0, FCuenta);
end;

procedure TPruebasPanelInicio.Etapa_Ubicacion_EsSoloInformativa;
begin
  FPanel.Pulsar('etapa:ubicacion');
  Assert.AreEqual(0, FCuenta);
end;

procedure TPruebasPanelInicio.Paso3_SinPermisoAgregar_HablaDeBuscar;
begin
  FPanel.FijarPermiso('agregar', False);
  Assert.IsTrue(Pos('Busque', FPanel.TituloPaso(3)) > 0);
  Assert.IsTrue(Pos('Agregue', FPanel.TituloPaso(3)) = 0);
  Assert.IsTrue(Pos('Arrastre', FPanel.TextoPaso(3)) = 0);
end;

procedure TPruebasPanelInicio.Paso3_ConPermisoAgregar_HablaDeAgregar;
begin
  FPanel.FijarPermiso('agregar', True);
  Assert.IsTrue(Pos('Agregue', FPanel.TituloPaso(3)) > 0);
  Assert.IsTrue(Pos('Arrastre', FPanel.TextoPaso(3)) > 0);
end;

procedure TPruebasPanelInicio.Ciclo_SinPermiso_Oculto;
begin
  // el visor y el invitado no ven el ciclo de vida (lleva a secciones de trabajo)
  FPanel.FijarPermiso('ciclo', False);
  Assert.IsFalse(FPanel.CicloVisible);
end;

procedure TPruebasPanelInicio.Ciclo_ConPermiso_Visible;
begin
  FPanel.FijarPermiso('ciclo', True);
  Assert.IsTrue(FPanel.CicloVisible);
end;

procedure TPruebasPanelInicio.PrimerosPasos_AlternarOculta_YSePersiste;
var
  Otro: TPanelInicio;
begin
  Assert.IsTrue(FPanel.PasosVisibles, 'la primera vez estan visibles');
  FPanel.AlternarPasos;
  Assert.IsFalse(FPanel.PasosVisibles);
  // otro panel que lee el mismo archivo arranca plegado
  Otro := TPanelInicio.Create(FForma, TemaClaro);
  try
    Otro.Parent := FForma;
    Otro.ArchivoConfig := FRuta;
    Assert.IsFalse(Otro.PasosVisibles);
  finally
    Otro.Free;
  end;
  FPanel.AlternarPasos;
  Assert.IsTrue(FPanel.PasosVisibles);
end;

procedure TPruebasPanelInicio.PrimerosPasos_ArchivoCorrupto_QuedaVisible;
var
  Otro: TPanelInicio;
begin
  TFile.WriteAllText(FRuta, #1#2#3 + 'basura sin formato');
  Otro := TPanelInicio.Create(FForma, TemaClaro);
  try
    Otro.Parent := FForma;
    Otro.ArchivoConfig := FRuta;
    Assert.IsTrue(Otro.PasosVisibles);
  finally
    Otro.Free;
  end;
end;

end.
