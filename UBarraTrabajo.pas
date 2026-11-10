unit UBarraTrabajo;

{ Barra de la pantalla de documentos: ruta y nombre del nodo, fichas de las
  series asignadas, busqueda, filtro de estado y el boton Editar (el alta es "Agregar documento" del shell).
  Se crea por codigo (sin .dfm) y no accede a datos: quien la usa le entrega
  las series con FijarSeries y atiende sus eventos. Colores de UTema.
  Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Winapi.Messages, Data.DB,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Graphics, Vcl.Forms,
  UTema, UDocumentoVista;

type
  TSerieFiltro = record
    CodSubs: string;
    Nombre: string;
    Cantidad: Integer; // -1: desconocida
  end;

  TSerieEvent = procedure(const CodSubs: string) of object;

  { Ficha de serie: pastilla pulsable, activa o no. }
  TFichaSerie = class(TCustomControl)
  private
    FActiva: Boolean;
    FTexto: string;
    FTema: TTemaColores;
    FEnRaton: Boolean;
    procedure SetActiva(Valor: Boolean);
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configurar(const Texto: string; const T: TTemaColores);
    property Activa: Boolean read FActiva write SetActiva;
    property OnClick;
  end;

  TBarraTrabajo = class(TPanel)
  private
    FTema: TTemaColores;
    FOscuro: Boolean;
    FConstruido: Boolean;
    FFichas: TArray<TFichaSerie>;
    FReajustando: Boolean;
    FLblSinSeries: TLabel;
    FFila: TPanel;
    FBusqueda: TEdit;
    FCmbEstado: TComboBox;
    FBtnEditar: TButton;
    FTemporizador: TTimer;
    FSeries: TArray<TSerieFiltro>;
    FActual: string;
    FOnElegirSerie: TSerieEvent;
    FOnFiltroCambio: TNotifyEvent;
    FOnEditar: TNotifyEvent;
    procedure Construir;
    procedure Reajustar;
    procedure FichaClick(Sender: TObject);
    procedure BusquedaChange(Sender: TObject);
    procedure EstadoChange(Sender: TObject);
    procedure TemporizadorTimer(Sender: TObject);
    procedure EditarClick(Sender: TObject);
    procedure AvisarFiltro;
    function GetTexto: string;
    function GetFiltrarEstado: Boolean;
    function GetEstado: TEstadoDoc;
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure FijarSeries(const Series: TArray<TSerieFiltro>; const Actual: string);
    { En modo edicion (rejilla) el filtro de la lista no se aplica. }
    procedure ModoEdicion(Valor: Boolean);
    function CantidadFichas: Integer;
    { Simula el clic en la ficha de ese indice (pruebas y atajos). }
    procedure ClicFicha(Indice: Integer);
    { Escribe en la caja de busqueda como si se tecleara (pruebas). }
    procedure EscribirTexto(const Texto: string);
    { Pone el filtro de estado (como si se eligiera en la lista) y avisa. }
    procedure FijarEstado(Valor: TEstadoDoc);
    function TextoBotonEditar: string;
    function TextoGuiaSeries: string;
    property Texto: string read GetTexto;
    property FiltrarEstado: Boolean read GetFiltrarEstado;
    property Estado: TEstadoDoc read GetEstado;
    property OnElegirSerie: TSerieEvent read FOnElegirSerie write FOnElegirSerie;
    property OnFiltroCambio: TNotifyEvent read FOnFiltroCambio write FOnFiltroCambio;
    property OnEditar: TNotifyEvent read FOnEditar write FOnEditar;
  end;

{ Solo se puede cambiar de serie con el dataset de documentos sin editar. }
function PuedeCambiarSerie(Estado: TDataSetState): Boolean;

implementation

uses
  System.Math, UShellPrincipal;

const
  FUENTE = 'Segoe UI';

function PuedeCambiarSerie(Estado: TDataSetState): Boolean;
begin
  Result := Estado in [dsInactive, dsBrowse];
end;

{ TFichaSerie }

constructor TFichaSerie.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Cursor := crHandPoint;
  Height := 28;
end;

procedure TFichaSerie.Configurar(const Texto: string; const T: TTemaColores);
begin
  FTexto := Texto;
  FTema := T;
  Canvas.Font.Name := FUENTE;
  Canvas.Font.Size := 9;
  Width := Canvas.TextWidth(Texto) + 28;
  Invalidate;
end;

procedure TFichaSerie.SetActiva(Valor: Boolean);
begin
  if FActiva <> Valor then
  begin
    FActiva := Valor;
    Invalidate;
  end;
end;

procedure TFichaSerie.CMMouseEnter(var Msg: TMessage);
begin
  FEnRaton := True;
  Invalidate;
end;

procedure TFichaSerie.CMMouseLeave(var Msg: TMessage);
begin
  FEnRaton := False;
  Invalidate;
end;

procedure TFichaSerie.Paint;
var
  R: TRect;
begin
  Canvas.Brush.Color := FTema.Superficie;
  Canvas.FillRect(ClientRect);
  R := Rect(0, 1, Width, Height - 1);
  if FActiva then
  begin
    Canvas.Brush.Color := FTema.Acento;
    Canvas.Pen.Color := FTema.Acento;
    Canvas.Font.Color := FTema.TextoSobreAcento;
  end
  else
  begin
    if FEnRaton then
      Canvas.Brush.Color := FTema.AcentoSuave
    else
      Canvas.Brush.Color := FTema.Superficie;
    Canvas.Pen.Color := FTema.Linea;
    Canvas.Font.Color := FTema.Texto;
  end;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, R.Height, R.Height);
  Canvas.Font.Name := FUENTE;
  Canvas.Font.Size := 9;
  Canvas.Font.Style := [];
  if FActiva then
    Canvas.Font.Style := [fsBold];
  SetBkMode(Canvas.Handle, TRANSPARENT);
  DrawText(Canvas.Handle, PChar(FTexto), Length(FTexto), R,
    DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
end;

{ TBarraTrabajo }

constructor TBarraTrabajo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOscuro := TemaWindowsOscuro;
  if FOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
end;

procedure TBarraTrabajo.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not FConstruido then
  begin
    FConstruido := True;
    Construir;
  end;
end;

procedure TBarraTrabajo.Construir;
begin
  BevelOuter := bvNone;
  ParentBackground := False;
  StyleElements := [];
  ShowCaption := False;
  Color := FTema.Fondo;

  FLblSinSeries := TLabel.Create(Self);
  FLblSinSeries.Parent := Self;
  FLblSinSeries.Transparent := True;
  FLblSinSeries.StyleElements := [];
  FLblSinSeries.Font.Name := FUENTE;
  FLblSinSeries.Font.Size := 9;
  FLblSinSeries.Font.Color := FTema.TextoSuave;
  FLblSinSeries.Caption := 'Este nodo no tiene series asignadas';
  FLblSinSeries.SetBounds(16, 12, 300, 16);

  FFila := TPanel.Create(Self);
  FFila.Parent := Self;
  FFila.Align := alBottom;
  FFila.Height := 42;
  FFila.BevelOuter := bvNone;
  FFila.ParentBackground := False;
  FFila.StyleElements := [];
  FFila.ShowCaption := False;
  FFila.Color := FTema.Fondo;

  FBtnEditar := TButton.Create(Self);
  FBtnEditar.Parent := FFila;
  FBtnEditar.Caption := 'Editar';
  FBtnEditar.Align := alRight;
  FBtnEditar.Width := 90;
  FBtnEditar.AlignWithMargins := True;
  FBtnEditar.Margins.SetBounds(6, 6, 16, 8);
  FBtnEditar.OnClick := EditarClick;

  FCmbEstado := TComboBox.Create(Self);
  FCmbEstado.Parent := FFila;
  FCmbEstado.Style := csDropDownList;
  FCmbEstado.Align := alRight;
  FCmbEstado.Width := 150;
  FCmbEstado.AlignWithMargins := True;
  FCmbEstado.Margins.SetBounds(6, 7, 6, 8);
  FCmbEstado.Items.Add('Todos los estados');
  FCmbEstado.Items.Add('En archivo');
  FCmbEstado.Items.Add('Prestado');
  FCmbEstado.ItemIndex := 0;
  FCmbEstado.OnChange := EstadoChange;

  FBusqueda := TEdit.Create(Self);
  FBusqueda.Parent := FFila;
  FBusqueda.Align := alClient;
  FBusqueda.AlignWithMargins := True;
  FBusqueda.Margins.SetBounds(16, 7, 0, 8);
  FBusqueda.TextHint := 'Filtrar esta lista por codigo, titulo o expediente';
  FBusqueda.OnChange := BusquedaChange;

  FTemporizador := TTimer.Create(Self);
  FTemporizador.Enabled := False;
  FTemporizador.Interval := 250;
  FTemporizador.OnTimer := TemporizadorTimer;

  FijarSeries(nil, '');
end;

procedure TBarraTrabajo.Reajustar;
const
  ALTO_FICHA = 28;
  SEP = 6;
var
  I, X, Y: Integer;
begin
  if (not FConstruido) or FReajustando then
    Exit;
  FReajustando := True;
  try
    X := 16;
    Y := 8;
    for I := 0 to High(FFichas) do
    begin
      if (X > 16) and (X + FFichas[I].Width > ClientWidth - 16) then
      begin
        X := 16;
        Inc(Y, ALTO_FICHA + SEP);
      end;
      FFichas[I].SetBounds(X, Y, FFichas[I].Width, ALTO_FICHA);
      Inc(X, FFichas[I].Width + 8);
    end;
    if Length(FFichas) > 0 then
      Height := Y + ALTO_FICHA + 6 + FFila.Height
    else
      Height := 8 + 24 + FFila.Height;
  finally
    FReajustando := False;
  end;
end;

procedure TBarraTrabajo.Resize;
begin
  inherited Resize;
  Reajustar;
end;

procedure TBarraTrabajo.FijarSeries(const Series: TArray<TSerieFiltro>;
  const Actual: string);
var
  I: Integer;
  F: TFichaSerie;
  Txt: string;
  Misma: Boolean;
begin
  // Mismas series: solo cambia la ficha activa. Asi no se libera la ficha que
  // se acaba de pulsar mientras se atiende su propio clic.
  if (Length(Series) = Length(FSeries)) and (Length(Series) = Length(FFichas)) then
  begin
    Misma := True;
    for I := 0 to High(Series) do
      if not SameText(Series[I].CodSubs, FSeries[I].CodSubs) or
        (Series[I].Nombre <> FSeries[I].Nombre) or
        (Series[I].Cantidad <> FSeries[I].Cantidad) then
        Misma := False;
    if Misma then
    begin
      FActual := Actual;
      for I := 0 to High(FFichas) do
        FFichas[I].Activa := SameText(Trim(FSeries[I].CodSubs), Trim(Actual));
      Exit;
    end;
  end;
  FSeries := Copy(Series);
  FActual := Actual;
  for I := 0 to High(FFichas) do
    FFichas[I].Free;
  FFichas := nil;
  SetLength(FFichas, Length(FSeries));
  for I := 0 to High(FSeries) do
  begin
    F := TFichaSerie.Create(Self);
    F.Parent := Self; // el lienzo necesita ventana para medir el texto
    Txt := FSeries[I].Nombre;
    if FSeries[I].Cantidad >= 0 then
      Txt := Txt + '  ' + IntToStr(FSeries[I].Cantidad);
    F.Configurar(Txt, FTema);
    F.Tag := I;
    F.Activa := SameText(Trim(FSeries[I].CodSubs), Trim(Actual));
    F.OnClick := FichaClick;
    FFichas[I] := F;
  end;
  FLblSinSeries.Visible := Length(FSeries) = 0;
  Reajustar;
end;

procedure TBarraTrabajo.FichaClick(Sender: TObject);
var
  I: Integer;
begin
  I := TComponent(Sender).Tag;
  if (I >= 0) and (I <= High(FSeries)) and Assigned(FOnElegirSerie) then
    FOnElegirSerie(FSeries[I].CodSubs);
end;

procedure TBarraTrabajo.ClicFicha(Indice: Integer);
begin
  if (Indice >= 0) and (Indice <= High(FFichas)) then
    FichaClick(FFichas[Indice]);
end;

function TBarraTrabajo.CantidadFichas: Integer;
begin
  Result := Length(FFichas);
end;

function TBarraTrabajo.TextoGuiaSeries: string;
begin
  if FLblSinSeries.Visible then
    Result := FLblSinSeries.Caption
  else
    Result := '';
end;

procedure TBarraTrabajo.ModoEdicion(Valor: Boolean);
begin
  if Valor then
    FBtnEditar.Caption := 'Ver lista'
  else
    FBtnEditar.Caption := 'Editar';
  FBusqueda.Enabled := not Valor;
  FCmbEstado.Enabled := not Valor;
end;

procedure TBarraTrabajo.FijarEstado(Valor: TEstadoDoc);
begin
  case Valor of
    edEnArchivo: FCmbEstado.ItemIndex := 1;
    edPrestado: FCmbEstado.ItemIndex := 2;
  else
    FCmbEstado.ItemIndex := 0;
  end;
  AvisarFiltro;
end;

function TBarraTrabajo.TextoBotonEditar: string;
begin
  Result := FBtnEditar.Caption;
end;

procedure TBarraTrabajo.EscribirTexto(const Texto: string);
begin
  FBusqueda.Text := Texto;
end;

function TBarraTrabajo.GetTexto: string;
begin
  Result := Trim(FBusqueda.Text);
end;

function TBarraTrabajo.GetFiltrarEstado: Boolean;
begin
  Result := FCmbEstado.ItemIndex > 0;
end;

function TBarraTrabajo.GetEstado: TEstadoDoc;
begin
  case FCmbEstado.ItemIndex of
    1: Result := edEnArchivo;
    2: Result := edPrestado;
  else
    Result := edDesconocido;
  end;
end;

procedure TBarraTrabajo.AvisarFiltro;
begin
  if Assigned(FOnFiltroCambio) then
    FOnFiltroCambio(Self);
end;

procedure TBarraTrabajo.BusquedaChange(Sender: TObject);
begin
  // se espera a que termine de teclear para no recargar en cada letra
  FTemporizador.Enabled := False;
  FTemporizador.Enabled := True;
end;

procedure TBarraTrabajo.TemporizadorTimer(Sender: TObject);
begin
  FTemporizador.Enabled := False;
  AvisarFiltro;
end;

procedure TBarraTrabajo.EstadoChange(Sender: TObject);
begin
  AvisarFiltro;
end;

procedure TBarraTrabajo.EditarClick(Sender: TObject);
begin
  if Assigned(FOnEditar) then
    FOnEditar(Self);
end;

end.
