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
  end;

implementation

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls,
  UPanelDocumento, UDocumentoVista;

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

initialization
  TDUnitX.RegisterTestFixture(TPruebasPanelDocumento);

end.
