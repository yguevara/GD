unit UPruebasBarraTrabajo;

{ Barra de trabajo (VCL): fichas de series, busqueda con retardo, modo edicion
  y la regla de cambio de serie. Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasBarraTrabajo = class
  public
    [Test]
    procedure FijarSeries_CreaUnaFichaPorSerie;
    [Test]
    procedure ClicEnFicha_DisparaOnElegirSerieConSuCodigo;
    [Test]
    procedure ClicRealEnFicha_ReconstruirLasMismasSeriesDentroDelClic_NoFalla;
    [Test]
    procedure SinSeries_MuestraTextoGuia;
    [Test]
    procedure Busqueda_DisparaOnFiltroCambioYDaElTexto;
    [Test]
    procedure ModoEdicion_CambiaTextoDelBotonYBloqueaElFiltro;
    [Test]
    procedure PuedeCambiarSerie_TodosLosEstados;
  end;

implementation

uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.Forms,
  Data.DB, UBarraTrabajo, UDocumentoVista;

function DosSeries: TArray<TSerieFiltro>;
begin
  SetLength(Result, 2);
  Result[0].CodSubs := '074';
  Result[0].Nombre := 'Expedientes de planeamientos';
  Result[0].Cantidad := 9;
  Result[1].CodSubs := '075';
  Result[1].Nombre := 'Proyectos';
  Result[1].Cantidad := -1;
end;

type
  TReceptor = class(TComponent)
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    Liberada: Boolean;
    Serie: string;
    Filtros: Integer;
    Barra: TBarraTrabajo;
    procedure Elegir(const CodSubs: string);
    procedure ElegirYRecargar(const CodSubs: string);
    procedure Filtro(Sender: TObject);
  end;

procedure TReceptor.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
    Liberada := True;
end;

procedure TReceptor.Elegir(const CodSubs: string);
begin
  Serie := CodSubs;
end;

{ Como BarraElegirSerie de TMAIN: dentro del clic se vuelven a entregar las
  series (iguales). La ficha pulsada no debe liberarse. }
procedure TReceptor.ElegirYRecargar(const CodSubs: string);
begin
  Serie := CodSubs;
  Barra.FijarSeries(DosSeries, CodSubs);
end;

procedure TReceptor.Filtro(Sender: TObject);
begin
  Inc(Filtros);
end;

function NuevaBarra(F: TForm): TBarraTrabajo;
begin
  F.SetBounds(50, 50, 900, 300);
  Result := TBarraTrabajo.Create(F);
  Result.Parent := F;
  Result.Align := alTop;
  F.Show;
  Application.ProcessMessages;
end;

procedure TPruebasBarraTrabajo.FijarSeries_CreaUnaFichaPorSerie;
var
  F: TForm;
  B: TBarraTrabajo;
begin
  F := TForm.CreateNew(nil);
  try
    B := NuevaBarra(F);
    B.FijarSeries(DosSeries, '075');
    Assert.AreEqual(2, B.CantidadFichas);
    B.FijarSeries(DosSeries, '074'); // no acumula
    Assert.AreEqual(2, B.CantidadFichas);
    Assert.AreEqual('', B.TextoGuiaSeries);
  finally
    F.Free;
  end;
end;

procedure TPruebasBarraTrabajo.ClicEnFicha_DisparaOnElegirSerieConSuCodigo;
var
  F: TForm;
  B: TBarraTrabajo;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create(nil);
  try
    B := NuevaBarra(F);
    B.OnElegirSerie := R.Elegir;
    B.FijarSeries(DosSeries, '074');
    B.ClicFicha(1);
    Assert.AreEqual('075', R.Serie);
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasBarraTrabajo.ClicRealEnFicha_ReconstruirLasMismasSeriesDentroDelClic_NoFalla;
var
  F: TForm;
  B: TBarraTrabajo;
  R: TReceptor;
  Ficha: TControl;
  I: Integer;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create(nil);
  try
    B := NuevaBarra(F);
    R.Barra := B;
    B.OnElegirSerie := R.ElegirYRecargar;
    B.FijarSeries(DosSeries, '074');
    Ficha := nil;
    for I := 0 to B.ControlCount - 1 do
      if B.Controls[I] is TFichaSerie then
        Ficha := B.Controls[I]; // la ultima: Proyectos
    Assert.IsNotNull(Ficha);
    Ficha.FreeNotification(R);
    // clic de verdad, por el bucle de mensajes
    SendMessage(TWinControl(Ficha).Handle, WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(5, 5));
    SendMessage(TWinControl(Ficha).Handle, WM_LBUTTONUP, 0, MakeLong(5, 5));
    Application.ProcessMessages;
    Assert.AreEqual('075', R.Serie);
    Assert.AreEqual(2, B.CantidadFichas, 'las fichas se conservan');
    Assert.IsFalse(R.Liberada, 'la ficha pulsada no se debe liberar dentro de su clic');
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasBarraTrabajo.SinSeries_MuestraTextoGuia;
var
  F: TForm;
  B: TBarraTrabajo;
begin
  F := TForm.CreateNew(nil);
  try
    B := NuevaBarra(F);
    B.FijarSeries(nil, '');
    Assert.AreEqual(0, B.CantidadFichas);
    Assert.AreEqual('Este nodo no tiene series asignadas', B.TextoGuiaSeries);
  finally
    F.Free;
  end;
end;

procedure TPruebasBarraTrabajo.Busqueda_DisparaOnFiltroCambioYDaElTexto;
var
  F: TForm;
  B: TBarraTrabajo;
  R: TReceptor;
  I: Integer;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create(nil);
  try
    B := NuevaBarra(F);
    B.OnFiltroCambio := R.Filtro;
    B.EscribirTexto('pal');
    B.EscribirTexto('palma');
    Assert.AreEqual(0, R.Filtros, 'con retardo: aun no avisa');
    for I := 1 to 30 do
    begin
      Sleep(20);
      Application.ProcessMessages;
    end;
    Assert.AreEqual(1, R.Filtros, 'tecleos seguidos = un solo aviso');
    Assert.AreEqual('palma', B.Texto);
    Assert.IsFalse(B.FiltrarEstado);
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasBarraTrabajo.ModoEdicion_CambiaTextoDelBotonYBloqueaElFiltro;
var
  F: TForm;
  B: TBarraTrabajo;
begin
  F := TForm.CreateNew(nil);
  try
    B := NuevaBarra(F);
    Assert.AreEqual('Editar', B.TextoBotonEditar);
    B.ModoEdicion(True);
    Assert.AreEqual('Ver lista', B.TextoBotonEditar);
    B.ModoEdicion(False);
    Assert.AreEqual('Editar', B.TextoBotonEditar);
  finally
    F.Free;
  end;
end;

procedure TPruebasBarraTrabajo.PuedeCambiarSerie_TodosLosEstados;
begin
  Assert.IsTrue(PuedeCambiarSerie(dsInactive));
  Assert.IsTrue(PuedeCambiarSerie(dsBrowse));
  Assert.IsFalse(PuedeCambiarSerie(dsEdit));
  Assert.IsFalse(PuedeCambiarSerie(dsInsert));
  Assert.IsFalse(PuedeCambiarSerie(dsSetKey));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasBarraTrabajo);

end.
