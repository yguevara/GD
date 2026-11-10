unit UPruebasPanelDocumento;

{ Panel del documento con pestanas (VCL). Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasPanelDocumento = class
  public
    [Test]
    procedure Panel_SeisPaginas_SoloLaActivaEsVisible;
    [Test]
    procedure Panel_Activar_AvisaUnaVezPorCambio;
    [Test]
    procedure Panel_FijarCabecera_MuestraCodigoYEstado;
    [Test]
    procedure Panel_FijarConteoArchivos_ActualizaLaPestana;
    [Test]
    procedure Ubicacion_DosBloques_MuestraTitulosYSinAsignar;
    [Test]
    procedure Ubicacion_Mensaje_ReemplazaLosBloques;
    [Test]
    procedure Ubicacion_TramosAnchos_PasanALaSiguienteLinea;
  end;

implementation

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls,
  UPanelDocumento, UDocumentoVista, UVistaUbicacion;

type
  TReceptor = class
    Cuenta: Integer;
    procedure Aviso(Sender: TObject);
  end;

procedure TReceptor.Aviso(Sender: TObject);
begin
  Inc(Cuenta);
end;

function NuevoPanel(F: TForm): TPanelDocumento;
begin
  F.SetBounds(50, 50, 600, 600);
  Result := TPanelDocumento.Create(F);
  Result.Parent := F;
  Result.Align := alRight;
  Result.Width := 380;
  F.Show;
  Application.ProcessMessages;
end;

procedure TPruebasPanelDocumento.Panel_SeisPaginas_SoloLaActivaEsVisible;
var
  F: TForm;
  P: TPanelDocumento;
  T: TPestanaDoc;
begin
  F := TForm.CreateNew(nil);
  try
    P := NuevoPanel(F);
    Assert.AreEqual(Ord(pdDatos), Ord(P.Activa));
    P.Activar(pdMetadatos);
    for T := Low(TPestanaDoc) to High(TPestanaDoc) do
      Assert.AreEqual(T = pdMetadatos, P.Pagina(T).Visible);
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumento.Panel_Activar_AvisaUnaVezPorCambio;
var
  F: TForm;
  P: TPanelDocumento;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create;
  try
    P := NuevoPanel(F);
    P.OnCambioPestana := R.Aviso;
    P.Activar(pdContenido);
    P.Activar(pdContenido);
    P.Activar(pdHistoria);
    Assert.AreEqual(2, R.Cuenta);
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasPanelDocumento.Panel_FijarCabecera_MuestraCodigoYEstado;
var
  F: TForm;
  P: TPanelDocumento;
begin
  F := TForm.CreateNew(nil);
  try
    P := NuevoPanel(F);
    Assert.AreEqual('Sin documento', P.TextoCodigo);
    P.FijarCabecera('A 03.01.02.0003', 'Alcantarillado', edPrestado);
    Assert.AreEqual('A 03.01.02.0003', P.TextoCodigo);
    Assert.AreEqual('Prestado', P.TextoEstado);
    P.FijarCabecera('A 03.01.02.0003', 'Alcantarillado', edDesconocido);
    Assert.AreEqual('', P.TextoEstado, 'sin estado conocido no se muestra');
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumento.Panel_FijarConteoArchivos_ActualizaLaPestana;
var
  F: TForm;
  P: TPanelDocumento;
begin
  F := TForm.CreateNew(nil);
  try
    P := NuevoPanel(F);
    Assert.AreEqual('Archivos', P.TituloPestana(pdArchivos));
    P.FijarConteoArchivos(3);
    Assert.AreEqual('Archivos 3', P.TituloPestana(pdArchivos));
    P.FijarConteoArchivos(0);
    Assert.AreEqual('Archivos', P.TituloPestana(pdArchivos));
  finally
    F.Free;
  end;
end;

function VistaNueva(F: TForm; Ancho: Integer): TVistaUbicacion;
begin
  F.SetBounds(50, 50, Ancho + 40, 500);
  Result := TVistaUbicacion.Create(F);
  Result.Parent := F;
  Result.SetBounds(0, 0, Ancho, 400);
  F.Show;
  Application.ProcessMessages;
end;

procedure TPruebasPanelDocumento.Ubicacion_DosBloques_MuestraTitulosYSinAsignar;
var
  F: TForm;
  V: TVistaUbicacion;
  D: TDatosDocumento;
begin
  F := TForm.CreateNew(nil);
  try
    V := VistaNueva(F, 380);
    D := Default(TDatosDocumento);
    D.Archivo := 'Archivo 2';
    D.Deposito := '0';
    V.Mostrar([UbicacionDeSubserie('3', 'Archivo 2', 'Deposito 01', 'Gaveta 02'),
      UbicacionDeDocumento(D)]);
    Assert.IsTrue(Pos('SUBSERIE', V.Contenido) > 0);
    Assert.IsTrue(Pos('DOCUMENTO', V.Contenido) > 0);
    Assert.IsTrue(Pos('Deposito: Sin asignar', V.Contenido) > 0);
    Assert.IsTrue(Pos('Ubicacion completa', V.Contenido) > 0, 'la subserie esta completa');
    Assert.IsTrue(Pos('Faltan datos de ubicacion', V.Contenido) > 0, 'el documento no');
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumento.Ubicacion_Mensaje_ReemplazaLosBloques;
var
  F: TForm;
  V: TVistaUbicacion;
begin
  F := TForm.CreateNew(nil);
  try
    V := VistaNueva(F, 380);
    V.Mostrar([UbicacionDeSubserie('3', 'A', 'D', 'G')]);
    V.MostrarMensaje('Elija un documento para ver su ubicacion');
    Assert.AreEqual(0, Pos('SUBSERIE', V.Contenido));
    Assert.IsTrue(Pos('Elija un documento', V.Contenido) > 0);
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumento.Ubicacion_TramosAnchos_PasanALaSiguienteLinea;
var
  F: TForm;
  V: TVistaUbicacion;
  Ancha, Estrecha: Integer;
  D: TDatosDocumento;
begin
  F := TForm.CreateNew(nil);
  try
    V := VistaNueva(F, 700);
    D := Default(TDatosDocumento);
    D.Servidor := 'Servidor central de produccion';
    D.Archivo := 'Archivo historico general';
    D.Deposito := 'Deposito de documentos antiguos';
    D.Gaveta := 'Gaveta 02';
    D.Posicion := 'Posicion 3';
    V.Mostrar([UbicacionDeDocumento(D)]);
    Ancha := V.AlturaContenido;
    V.Width := 280;
    Application.ProcessMessages;
    Estrecha := V.AlturaContenido;
    Assert.IsTrue(Estrecha > Ancha, 'en un panel estrecho los tramos ocupan mas lineas');
  finally
    F.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasPanelDocumento);

end.
