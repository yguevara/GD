unit UPruebasPanelLateral;

{ Panel lateral unico (VCL): paginas con pestanas, cabecera y el movimiento de
  controles entre contenedores. Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasPanelLateral = class
  public
    [Test]
    procedure AgregarPagina_SoloLaActivaEsVisible;
    [Test]
    procedure Activar_CambiaDePaginaYAvisa;
    [Test]
    procedure Activar_PorConstante_SeleccionaLaPaginaEsperada;
    [Test]
    procedure FijarCabecera_SinTitulo_DiceSinSubserie;
    [Test]
    procedure MoverContenido_ConservaOrdenAlignYEventos;
    [Test]
    procedure MoverContenido_TresPaneles_QuedanEnSuPagina;
  end;

implementation

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls,
  Vcl.StdCtrls, UPanelLateral;

type
  TReceptor = class
    Cuenta: Integer;
    Clics: Integer;
    procedure Aviso(Sender: TObject);
    procedure Clic(Sender: TObject);
  end;

procedure TReceptor.Aviso(Sender: TObject);
begin
  Inc(Cuenta);
end;

procedure TReceptor.Clic(Sender: TObject);
begin
  Inc(Clics);
end;

function NuevoPanel(F: TForm): TPanelLateral;
begin
  F.SetBounds(50, 50, 600, 600);
  Result := TPanelLateral.Create(F);
  Result.Parent := F;
  Result.Align := alRight;
  Result.Width := 380;
  F.Show;
  Application.ProcessMessages;
end;

procedure TPruebasPanelLateral.AgregarPagina_SoloLaActivaEsVisible;
var
  F: TForm;
  P: TPanelLateral;
  A, B, C: TPanel;
begin
  F := TForm.CreateNew(nil);
  try
    P := NuevoPanel(F);
    A := P.AgregarPagina('Series');
    B := P.AgregarPagina('Detalle');
    C := P.AgregarPagina('Complementaria');
    Assert.AreEqual(3, P.CantidadPaginas);
    P.Activar(1);
    Assert.IsFalse(A.Visible);
    Assert.IsTrue(B.Visible);
    Assert.IsFalse(C.Visible);
    Assert.AreEqual(1, P.PaginaActiva);
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelLateral.Activar_CambiaDePaginaYAvisa;
var
  F: TForm;
  P: TPanelLateral;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create;
  try
    P := NuevoPanel(F);
    P.AgregarPagina('Series');
    P.AgregarPagina('Detalle');
    P.OnCambioPagina := R.Aviso;
    P.Activar(1);
    P.Activar(1); // la misma: no avisa de nuevo
    P.Activar(0);
    Assert.AreEqual(2, R.Cuenta);
    P.Activar(7); // fuera de rango: se ignora
    Assert.AreEqual(0, P.PaginaActiva);
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasPanelLateral.Activar_PorConstante_SeleccionaLaPaginaEsperada;
var
  F: TForm;
  P: TPanelLateral;
begin
  F := TForm.CreateNew(nil);
  try
    P := NuevoPanel(F);
    P.AgregarPagina('Series');
    P.AgregarPagina('Detalle');
    P.AgregarPagina('Complementaria');
    P.Activar(PAG_COMPLEMENTARIA);
    Assert.AreEqual(2, P.PaginaActiva);
    P.Activar(PAG_SERIES);
    Assert.AreEqual(0, P.PaginaActiva);
    P.Activar(PAG_DETALLE);
    Assert.AreEqual(1, P.PaginaActiva);
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelLateral.FijarCabecera_SinTitulo_DiceSinSubserie;
var
  F: TForm;
  P: TPanelLateral;
begin
  F := TForm.CreateNew(nil);
  try
    P := NuevoPanel(F);
    P.FijarCabecera('', '');
    Assert.AreEqual('Sin subserie', P.TextoCabecera);
    P.FijarCabecera('Expedientes de planeamientos', '014001');
    Assert.AreEqual('Expedientes de planeamientos', P.TextoCabecera);
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelLateral.MoverContenido_ConservaOrdenAlignYEventos;
var
  F: TForm;
  Origen, Destino, Arriba, Centro: TPanel;
  Boton: TButton;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create;
  try
    Origen := TPanel.Create(F);
    Origen.Parent := F;
    Destino := TPanel.Create(F);
    Destino.Parent := F;
    Arriba := TPanel.Create(F);
    Arriba.Parent := Origen;
    Arriba.Align := alTop;
    Boton := TButton.Create(F);
    Boton.Parent := Origen;
    Boton.OnClick := R.Clic;
    Centro := TPanel.Create(F);
    Centro.Parent := Origen;
    Centro.Align := alClient;
    MoverContenido(Origen, Destino);
    Assert.AreEqual(0, Origen.ControlCount);
    Assert.AreEqual(3, Destino.ControlCount);
    Assert.AreEqual(Ord(alTop), Ord(Arriba.Align));
    Assert.AreEqual(Ord(alClient), Ord(Centro.Align));
    Assert.IsTrue(Boton.Parent = Destino);
    Boton.Click;
    Assert.AreEqual(1, R.Clics, 'el boton movido conserva su manejador');
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasPanelLateral.MoverContenido_TresPaneles_QuedanEnSuPagina;
var
  F: TForm;
  P: TPanelLateral;
  Orig: array[0..2] of TPanel;
  Hijo: array[0..2] of TLabel;
  Pag: array[0..2] of TPanel;
  I: Integer;
begin
  F := TForm.CreateNew(nil);
  try
    P := NuevoPanel(F);
    for I := 0 to 2 do
    begin
      Pag[I] := P.AgregarPagina('P' + IntToStr(I));
      Orig[I] := TPanel.Create(F);
      Orig[I].Parent := F;
      Hijo[I] := TLabel.Create(F);
      Hijo[I].Parent := Orig[I];
      Hijo[I].Caption := 'contenido ' + IntToStr(I);
      MoverContenido(Orig[I], Pag[I]);
    end;
    P.Activar(PAG_DETALLE);
    for I := 0 to 2 do
    begin
      Assert.IsTrue(Hijo[I].Parent = Pag[I]);
      Assert.AreEqual(I = PAG_DETALLE, Hijo[I].Parent.Visible,
        'solo es visible el contenido de la pestana activa');
    end;
  finally
    F.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasPanelLateral);

end.
