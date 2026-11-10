unit UPruebasRecepcionArchivos;

{ Receptor de arrastre de archivos: filtro de rutas (puro) y avisos del
  componente. Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasRecepcionArchivos = class
  private
    FCarpeta: string;
    FPdf, FDocx, FSinExt: string;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure FiltrarRutas_SoloPdf_AceptaPdfYRechazaElResto;
    [Test]
    procedure FiltrarRutas_SinExtensiones_AceptaLasQueExisten;
    [Test]
    procedure FiltrarRutas_NoExiste_VaARechazadas;
    [Test]
    procedure FiltrarRutas_ConExtensiones_RechazaLasCarpetas;
    [Test]
    procedure RecrearLaVentana_VuelveAEstarRegistrado;
    [Test]
    procedure SimularSoltar_Activo_AvisaConLasRutas;
    [Test]
    procedure SimularSoltar_ConActivoFalso_NoAvisa;
    [Test]
    procedure SimularSoltar_SinRutas_NoAvisa;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, Vcl.Forms, Vcl.Controls,
  Vcl.ExtCtrls, Winapi.Messages, Winapi.Windows, URecepcionArchivos;

type
  TReceptor = class
    Avisos: Integer;
    Ultimas: TArray<string>;
    procedure Soltar(const Rutas: TArray<string>);
  end;

procedure TReceptor.Soltar(const Rutas: TArray<string>);
begin
  Inc(Avisos);
  Ultimas := Rutas;
end;

procedure Escribe(const Ruta: string);
begin
  TFile.WriteAllText(Ruta, 'x');
end;

procedure TPruebasRecepcionArchivos.Preparar;
begin
  FCarpeta := TPath.Combine(TPath.GetTempPath, 'archigenio_prueba_soltar');
  TDirectory.CreateDirectory(FCarpeta);
  FPdf := TPath.Combine(FCarpeta, 'plano.PDF');
  FDocx := TPath.Combine(FCarpeta, 'memoria.docx');
  FSinExt := TPath.Combine(FCarpeta, 'LEEME');
  Escribe(FPdf);
  Escribe(FDocx);
  Escribe(FSinExt);
end;

procedure TPruebasRecepcionArchivos.Limpiar;
begin
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
end;

procedure TPruebasRecepcionArchivos.FiltrarRutas_SoloPdf_AceptaPdfYRechazaElResto;
var
  Rech, Ok: TArray<string>;
begin
  Ok := FiltrarRutas([FPdf, FDocx, FSinExt], ['pdf'], Rech);
  Assert.AreEqual(1, Integer(Length(Ok)));
  Assert.AreEqual(FPdf, Ok[0], 'la extension se compara sin distinguir mayusculas');
  Assert.AreEqual(2, Integer(Length(Rech)));
end;

procedure TPruebasRecepcionArchivos.FiltrarRutas_SinExtensiones_AceptaLasQueExisten;
var
  Rech, Ok: TArray<string>;
begin
  Ok := FiltrarRutas([FPdf, FDocx, FSinExt], nil, Rech);
  Assert.AreEqual(3, Integer(Length(Ok)));
  Assert.AreEqual(0, Integer(Length(Rech)));
end;

procedure TPruebasRecepcionArchivos.FiltrarRutas_NoExiste_VaARechazadas;
var
  Rech, Ok: TArray<string>;
begin
  Ok := FiltrarRutas([TPath.Combine(FCarpeta, 'no_existe.pdf'), FPdf], nil, Rech);
  Assert.AreEqual(1, Integer(Length(Ok)));
  Assert.AreEqual(1, Integer(Length(Rech)));
end;

procedure TPruebasRecepcionArchivos.FiltrarRutas_ConExtensiones_RechazaLasCarpetas;
var
  Rech, Ok: TArray<string>;
begin
  Ok := FiltrarRutas([FCarpeta], ['pdf'], Rech);
  Assert.AreEqual(0, Integer(Length(Ok)));
  Assert.AreEqual(1, Integer(Length(Rech)));
  // sin extensiones pedidas una carpeta es valida (se expande despues)
  Ok := FiltrarRutas([FCarpeta], nil, Rech);
  Assert.AreEqual(1, Integer(Length(Ok)));
end;

function NuevoReceptor(F: TForm; out R: TReceptor): TRecepcionArchivos;
var
  P: TPanel;
begin
  F.SetBounds(50, 50, 400, 300);
  P := TPanel.Create(F);
  P.Parent := F;
  P.Align := alClient;
  F.Show;
  Application.ProcessMessages;
  R := TReceptor.Create;
  Result := TRecepcionArchivos.Crear(F, P);
  Result.OnSoltar := R.Soltar;
end;

procedure TPruebasRecepcionArchivos.RecrearLaVentana_VuelveAEstarRegistrado;
var
  F: TForm;
  Rc: TRecepcionArchivos;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  try
    Rc := NuevoReceptor(F, R);
    Assert.IsTrue(Rc.Registrado);
    F.Perform(CM_RECREATEWND, 0, 0);
    Application.ProcessMessages;
    TWinControl(F.Controls[0]).Perform(CM_RECREATEWND, 0, 0);
    Application.ProcessMessages;
    Assert.IsTrue(Rc.Registrado, 'tras recrear la ventana se registra de nuevo');
    // OLE guarda el destino en una propiedad de la ventana: debe estar en la nueva
    Assert.IsTrue(GetProp(TWinControl(F.Controls[0]).Handle, 'OleDropTargetInterface') <> 0,
      'el control nuevo debe estar registrado en OLE de verdad');
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasRecepcionArchivos.SimularSoltar_Activo_AvisaConLasRutas;
var
  F: TForm;
  Rc: TRecepcionArchivos;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  try
    Rc := NuevoReceptor(F, R);
    Rc.SimularSoltar([FPdf, FDocx]);
    Assert.AreEqual(1, R.Avisos);
    Assert.AreEqual(2, Integer(Length(R.Ultimas)));
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasRecepcionArchivos.SimularSoltar_ConActivoFalso_NoAvisa;
var
  F: TForm;
  Rc: TRecepcionArchivos;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  try
    Rc := NuevoReceptor(F, R);
    Rc.Activo := False;
    Rc.SimularSoltar([FPdf]);
    Assert.AreEqual(0, R.Avisos);
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasRecepcionArchivos.SimularSoltar_SinRutas_NoAvisa;
var
  F: TForm;
  Rc: TRecepcionArchivos;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  try
    Rc := NuevoReceptor(F, R);
    Rc.SimularSoltar(nil);
    Assert.AreEqual(0, R.Avisos);
  finally
    F.Free;
    R.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasRecepcionArchivos);

end.
