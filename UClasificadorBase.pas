unit UClasificadorBase;

{ ---------------------------------------------------------------------------
  Formulario base de los clasificadores nuevos (sin .dfm, todo por codigo).

  Estructura: cabecera (titulo, subtitulo, buscador, Exportar, "+ Nuevo"),
  tabla DevExpress sin aspecto de Excel y, a la derecha, un panel lateral de
  edicion con barra "Guardar / Cancelar / Eliminar". La pantalla hija arma sus
  campos dentro de FCuerpo e implementa AlNuevo, AlElegirFila, AlGuardar y
  AlEliminar.

  La tabla NO esta enlazada a datos: se llena con LimpiarFilas / AgregarFila /
  RefrescarVista. Asi la pantalla no depende de datasets de TUDM.

  Cambios sin guardar: FEstado (TEstadoFicha) los lleva; la pantalla hija llama
  a FEstado.MarcarCambio cuando el usuario modifica un campo. Cambiar de fila,
  cerrar el panel o la ventana pregunta antes de perderlos (ConfirmarAbandonar).

  Colores: paleta de UTema (TemaLegacyActual, claro u oscuro). Botones y
  buscador son los mismos controles del shell (TBotonShell, TCajaBusqueda).
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  dxCore, cxClasses, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxGridLevel, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGrid,
  UTema, UShellPrincipal, UClasificadorEstado;

type
  TFormClasificadorBase = class(TForm)
  private
    FFilas: TList<TArray<Variant>>;
    FTags: TList<Integer>;
    FFiltro: string;
    FSilencio: Boolean;
    FCabecera, FZonaTabla, FPanel, FBarraAcciones: TPanel;
    FTitulo, FSubtitulo, FTituloPanel, FCerrarPanel: TLabel;
    FBuscar: TCajaBusqueda;
    FBtnNuevo, FBtnExportar, FBtnGuardar, FBtnCancelar, FBtnEliminar: TBotonShell;
    FGrid: TcxGrid;
    FVista: TcxGridTableView;
    FColTag: TcxGridColumn;
    FEstilos: TcxStyleRepository;
    FTextoNuevo: string;
    FEmbebido: Boolean;
    FIndice: TPanel;
    FVistaAlterna: TWinControl;
    FPanelEstabaAbierto: Boolean;
    FOnSalir: TNotifyEvent;
    function NuevoEstilo(AColor, ATexto: TColor; ATam: Integer; ANegrita: Boolean): TcxStyle;
    function NuevoBoton(AParent: TWinControl; const ATexto, AIcono: string;
      APrimario: Boolean; ATextoColor: TColor): TBotonShell;
    procedure ConstruirCabecera(const ATitulo, ASubtitulo: string);
    procedure ConstruirTabla;
    procedure ConstruirIndice;
    procedure ConstruirPanel;
    procedure ReubicarCabecera;
    procedure CabeceraResize(Sender: TObject);
    procedure BuscarCambio(Sender: TObject);
    procedure NuevoClick(Sender: TObject);
    procedure ExportarClick(Sender: TObject);
    procedure GuardarClick(Sender: TObject);
    procedure CancelarClick(Sender: TObject);
    procedure EliminarClick(Sender: TObject);
    procedure CerrarPanelClick(Sender: TObject);
    procedure VistaFocoCambiado(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure VistaDibujarCabecera(Sender: TcxGridTableView; ACanvas: TcxCanvas;
      AViewInfo: TcxGridColumnHeaderViewInfo; var ADone: Boolean);
    procedure FormCerrando(Sender: TObject; var CanClose: Boolean);
    procedure FormTecla(Sender: TObject; var Key: Word; Shift: TShiftState);
    function TagDeRegistro(ARegistro: TcxCustomGridRecord): Integer;
  protected
    FTema: TTemaColores;
    FEstado: TEstadoFicha;
    { Contenedor (con desplazamiento) donde la pantalla hija arma sus campos. }
    FCuerpo: TScrollBox;
    { Escala un tamano en pixeles segun el DPI actual. }
    function Esc(Valor: Integer): Integer;
    function Vista: TcxGridTableView;
    { Crea cabecera, tabla y panel. Llamar una vez desde el constructor hijo. }
    procedure ConstruirBase(const ATitulo, ASubtitulo, ATextoNuevo: string);
    procedure FijarSubtitulo(const ATexto: string);
    function AgregarColumna(const ATitulo: string; AAncho: Integer): TcxGridColumn;
    { Anade una fila a la lista; ATag identifica el elemento (p. ej. su Id).
      Llamar a RefrescarVista al terminar de cargar. }
    procedure AgregarFila(const AValores: array of Variant; ATag: Integer);
    procedure LimpiarFilas;
    { Vuelca a la tabla las filas que cumplen el buscador. Conserva la fila
      elegida si sigue visible. }
    procedure RefrescarVista;
    { Tag de la fila elegida en la tabla; -1 si no hay. }
    function FilaActualTag: Integer;
    procedure SeleccionarPorTag(ATag: Integer);
    procedure AbrirPanel(const ATitulo: string; AMostrarEliminar: Boolean);
    procedure CerrarPanel;
    function PanelAbierto: Boolean;
    procedure FijarBotones(AGuardar, ACancelar, AEliminar: Boolean);
    { True si no hay cambios o el usuario acepta perderlos. }
    function ConfirmarAbandonar: Boolean; virtual;
    { Zona de indice a la izquierda de la tabla (p. ej. las series); oculta por
      defecto: la pantalla hija la llena y la muestra con MostrarIndice. }
    function Indice: TPanel;
    procedure MostrarIndice(AVisible: Boolean);
    { Sustituye la tabla (y el indice y el panel lateral) por una vista a pantalla
      completa, p. ej. un editor; VolverALista la restaura. }
    procedure MostrarVista(AVista: TWinControl);
    procedure VolverALista;
    function VistaAlternaActiva: Boolean;
    { Eventos que implementa la pantalla hija. }
    procedure AlNuevo; virtual; abstract;
    procedure AlElegirFila(ATag: Integer); virtual; abstract;
    procedure AlGuardar; virtual; abstract;
    procedure AlEliminar; virtual; abstract;
    { Por defecto descarta los cambios y cierra el panel. }
    procedure AlCancelar; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Acopla la pantalla DENTRO de un contenedor de la ventana principal (en vez
      de abrirla como ventana modal): sin borde, ocupando todo el contenedor. El
      titulo lo muestra la cabecera de la ventana principal. }
    procedure Embeber(AHost: TWinControl);
    { Pregunta si hay cambios sin guardar; True si se puede abandonar la pantalla. }
    function PuedeSalir: Boolean;
    { Se dispara cuando el usuario pide salir (Esc sin panel abierto). Quien
      embebio la pantalla decide: normalmente PuedeSalir y liberarla. }
    property OnSalir: TNotifyEvent read FOnSalir write FOnSalir;
  end;

implementation

uses
  UAparienciaLegacy, UIconos, UMensajes, UExcelExport;

type
  { Da acceso a la fuente (protegida) de TBotonShell. }
  TBotonAbierto = class(TBotonShell);

{ Color intermedio entre A y B (F de 0 a 1). }
function Mezclar(A, B: TColor; F: Double): TColor;
var
  CA, CB: Integer;
begin
  CA := ColorToRGB(A);
  CB := ColorToRGB(B);
  Result := RGB(Round(GetRValue(CA) * (1 - F) + GetRValue(CB) * F),
    Round(GetGValue(CA) * (1 - F) + GetGValue(CB) * F),
    Round(GetBValue(CA) * (1 - F) + GetBValue(CB) * F));
end;

{ Icono legible sobre el fondo dado (blanco sobre fondos oscuros). }
function IconoDe(const ANombre: string; AFondo: TColor): Integer;
begin
  try
    if RazonContraste(AFondo, clWhite) > RazonContraste(AFondo, clBlack) then
      Result := IndiceIconoBlanco(ANombre)
    else
      Result := IndiceIcono(ANombre);
  except
    Result := -1;
  end;
end;

{ TFormClasificadorBase }

constructor TFormClasificadorBase.Create(AOwner: TComponent);
begin
  // Sin .dfm: se crea con CreateNew (Create intentaria leer el recurso)
  inherited CreateNew(AOwner);
  FFilas := TList<TArray<Variant>>.Create;
  FTags := TList<Integer>.Create;
  FEstado := TEstadoFicha.Create;
  FTema := TemaLegacyActual;
  Position := poScreenCenter;
  BorderIcons := [biSystemMenu, biMaximize];
  KeyPreview := True;
  Color := FTema.Fondo;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  Width := Round(Screen.WorkAreaWidth * 0.92);
  Height := Round(Screen.WorkAreaHeight * 0.92);
  OnCloseQuery := FormCerrando;
  OnKeyDown := FormTecla;
end;

destructor TFormClasificadorBase.Destroy;
begin
  FreeAndNil(FEstado);
  FreeAndNil(FFilas);
  FreeAndNil(FTags);
  inherited Destroy;
end;

function TFormClasificadorBase.Esc(Valor: Integer): Integer;
begin
  Result := MulDiv(Valor, CurrentPPI, 96);
end;

function TFormClasificadorBase.Vista: TcxGridTableView;
begin
  Result := FVista;
end;

function TFormClasificadorBase.NuevoEstilo(AColor, ATexto: TColor; ATam: Integer;
  ANegrita: Boolean): TcxStyle;
begin
  Result := FEstilos.CreateItem(TcxStyle) as TcxStyle;
  Result.Color := AColor;
  Result.TextColor := ATexto;
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := ATam;
  if ANegrita then
    Result.Font.Style := [fsBold]
  else
    Result.Font.Style := [];
end;

function TFormClasificadorBase.NuevoBoton(AParent: TWinControl; const ATexto, AIcono: string;
  APrimario: Boolean; ATextoColor: TColor): TBotonShell;
var
  Padre: TColor;
begin
  Result := TBotonShell.Create(Self);
  Result.Estilo := ebPrimario;
  Result.Texto := ATexto;
  TBotonAbierto(Result).Font.Name := 'Segoe UI';
  TBotonAbierto(Result).Font.Size := 9;
  TBotonAbierto(Result).Font.Style := [fsBold];
  if AParent is TPanel then
    Padre := TPanel(AParent).Color
  else
    Padre := FTema.Superficie;
  if APrimario then
  begin
    Result.Icono := IconoDe(AIcono, FTema.Acento);
    Result.Colores(Padre, FTema.Acento, Mezclar(FTema.Acento, FTema.TextoSobreAcento, 0.15),
      FTema.TextoSobreAcento, clNone);
  end
  else
  begin
    Result.Icono := IconoDe(AIcono, FTema.Superficie);
    Result.Colores(Padre, FTema.Superficie, FTema.AcentoSuave, ATextoColor, FTema.Linea);
  end;
  Result.Parent := AParent;
end;

procedure TFormClasificadorBase.ConstruirBase(const ATitulo, ASubtitulo, ATextoNuevo: string);
begin
  FTextoNuevo := ATextoNuevo;
  FEstilos := TcxStyleRepository.Create(Self);
  ConstruirPanel;       // primero: alRight debe crearse antes que el cliente
  ConstruirCabecera(ATitulo, ASubtitulo);
  ConstruirIndice;      // alLeft, antes que el cliente
  ConstruirTabla;
  ReubicarCabecera;
end;

procedure TFormClasificadorBase.ConstruirCabecera(const ATitulo, ASubtitulo: string);
var
  Linea: TPanel;
begin
  FCabecera := TPanel.Create(Self);
  FCabecera.Parent := Self;
  FCabecera.Align := alTop;
  FCabecera.Height := Esc(66);
  FCabecera.BevelOuter := bvNone;
  FCabecera.ParentBackground := False;
  FCabecera.StyleElements := [];
  FCabecera.ShowCaption := False;
  FCabecera.Color := FTema.Superficie;
  FCabecera.OnResize := CabeceraResize;

  Linea := TPanel.Create(Self);
  Linea.Parent := FCabecera;
  Linea.Align := alBottom;
  Linea.Height := 1;
  Linea.BevelOuter := bvNone;
  Linea.ParentBackground := False;
  Linea.StyleElements := [];
  Linea.Color := FTema.Linea;

  FTitulo := TLabel.Create(Self);
  FTitulo.Parent := FCabecera;
  FTitulo.AutoSize := True;
  FTitulo.Transparent := True;
  FTitulo.StyleElements := [];
  FTitulo.Font.Name := 'Segoe UI Semibold';
  FTitulo.Font.Size := 13;
  FTitulo.Font.Color := FTema.Texto;
  FTitulo.Caption := ATitulo;
  FTitulo.SetBounds(Esc(20), Esc(10), Esc(300), Esc(24));

  FSubtitulo := TLabel.Create(Self);
  FSubtitulo.Parent := FCabecera;
  FSubtitulo.AutoSize := True;
  FSubtitulo.Transparent := True;
  FSubtitulo.StyleElements := [];
  FSubtitulo.Font.Name := 'Segoe UI';
  FSubtitulo.Font.Size := 9;
  FSubtitulo.Font.Color := FTema.TextoSuave;
  FSubtitulo.Caption := ASubtitulo;
  FSubtitulo.SetBounds(Esc(20), Esc(38), Esc(300), Esc(16));

  FBtnNuevo := NuevoBoton(FCabecera, FTextoNuevo, 'agregar', True, FTema.Texto);
  FBtnNuevo.OnClick := NuevoClick;
  FBtnExportar := NuevoBoton(FCabecera, 'Exportar', 'excel', False, FTema.Texto);
  FBtnExportar.OnClick := ExportarClick;

  FBuscar := TCajaBusqueda.Create(Self);
  FBuscar.Parent := FCabecera;
  FBuscar.Colores(FCabecera.Color, FTema.Superficie2, FTema.Linea, FTema.Texto,
    IconoDe('buscar', FTema.Superficie2));
  FBuscar.Edit.TextHint := 'Buscar...';
  FBuscar.Edit.OnChange := BuscarCambio;
end;

procedure TFormClasificadorBase.ReubicarCabecera;
var
  X, Alto, Y: Integer;
begin
  if (FCabecera = nil) or (FBtnNuevo = nil) then
    Exit;
  Alto := Esc(36);
  Y := (FCabecera.Height - Alto) div 2;
  X := FCabecera.ClientWidth - Esc(20);
  FBtnNuevo.Width := FBtnNuevo.AnchoIdeal + Esc(8);
  FBtnNuevo.SetBounds(X - FBtnNuevo.Width, Y, FBtnNuevo.Width, Alto);
  X := FBtnNuevo.Left - Esc(10);
  FBtnExportar.Width := FBtnExportar.AnchoIdeal + Esc(8);
  FBtnExportar.SetBounds(X - FBtnExportar.Width, Y, FBtnExportar.Width, Alto);
  X := FBtnExportar.Left - Esc(14);
  FBuscar.SetBounds(X - Esc(240), Y, Esc(240), Alto);
end;

procedure TFormClasificadorBase.CabeceraResize(Sender: TObject);
begin
  ReubicarCabecera;
end;

procedure TFormClasificadorBase.ConstruirTabla;
var
  Nivel: TcxGridLevel;
  Fondo, Cabecera, Seleccion: TcxStyle;
begin
  FZonaTabla := TPanel.Create(Self);
  FZonaTabla.Parent := Self;
  FZonaTabla.Align := alClient;
  FZonaTabla.BevelOuter := bvNone;
  FZonaTabla.ParentBackground := False;
  FZonaTabla.StyleElements := [];
  FZonaTabla.ShowCaption := False;
  FZonaTabla.Color := FTema.Superficie;
  // margen alrededor de la tabla (el texto no debe tocar los bordes)
  FZonaTabla.Padding.SetBounds(Esc(16), 0, Esc(16), Esc(16));

  FGrid := TcxGrid.Create(Self);
  FGrid.Parent := FZonaTabla;
  FGrid.Align := alClient;
  FGrid.BorderStyle := cxcbsNone;
  FGrid.LookAndFeel.NativeStyle := False;
  FGrid.LookAndFeel.SkinName := '';   // sin piel de DevExpress: aspecto plano propio
  FGrid.LookAndFeel.Kind := lfUltraFlat;

  FVista := FGrid.CreateView(TcxGridTableView) as TcxGridTableView;
  Nivel := FGrid.Levels.Add;
  Nivel.GridView := FVista;

  FVista.OptionsView.GridLines := glHorizontal;
  FVista.OptionsView.GridLineColor := FTema.Linea;
  FVista.OptionsView.GroupByBox := False;
  FVista.OptionsView.ColumnAutoWidth := True;
  FVista.OptionsView.Indicator := False;
  FVista.OptionsView.DataRowHeight := Esc(42);
  FVista.OptionsView.HeaderHeight := Esc(36);
  FVista.OptionsData.Editing := False;
  FVista.OptionsData.Inserting := False;
  FVista.OptionsData.Deleting := False;
  FVista.OptionsData.Appending := False;
  FVista.OptionsSelection.CellSelect := False;
  FVista.OptionsSelection.InvertSelect := False;
  FVista.OptionsSelection.HideFocusRectOnExit := True;
  FVista.OptionsCustomize.ColumnMoving := False;

  Fondo := NuevoEstilo(FTema.Superficie, FTema.Texto, 10, False);
  Cabecera := NuevoEstilo(FTema.Superficie2, FTema.TextoSuave, 8, True);
  Seleccion := NuevoEstilo(FTema.AcentoSuave, FTema.Texto, 10, False);
  FVista.Styles.Background := Fondo;
  FVista.Styles.Content := Fondo;
  FVista.Styles.ContentEven := Fondo;
  FVista.Styles.ContentOdd := Fondo;
  FVista.Styles.Header := Cabecera;
  FVista.Styles.Selection := Seleccion;
  FVista.Styles.Inactive := Seleccion;

  // Columna oculta con el identificador de cada fila
  FColTag := FVista.CreateColumn;
  FColTag.DataBinding.ValueTypeClass := TcxIntegerValueType;
  FColTag.Visible := False;

  FVista.OnFocusedRecordChanged := VistaFocoCambiado;
  FVista.OnCustomDrawColumnHeader := VistaDibujarCabecera;
end;

procedure TFormClasificadorBase.ConstruirIndice;
var
  Linea: TPanel;
begin
  FIndice := TPanel.Create(Self);
  FIndice.Parent := Self;
  FIndice.Align := alLeft;
  FIndice.Width := Esc(250);
  FIndice.BevelOuter := bvNone;
  FIndice.ParentBackground := False;
  FIndice.StyleElements := [];
  FIndice.ShowCaption := False;
  FIndice.Color := FTema.Superficie2;
  FIndice.Visible := False;
  Linea := TPanel.Create(Self);
  Linea.Parent := FIndice;
  Linea.Align := alRight;
  Linea.Width := 1;
  Linea.BevelOuter := bvNone;
  Linea.ParentBackground := False;
  Linea.StyleElements := [];
  Linea.Color := FTema.Linea;
end;

function TFormClasificadorBase.Indice: TPanel;
begin
  Result := FIndice;
end;

procedure TFormClasificadorBase.MostrarIndice(AVisible: Boolean);
begin
  FIndice.Visible := AVisible;
  if AVisible then
    FIndice.Tag := 1
  else
    FIndice.Tag := 0;
end;

function TFormClasificadorBase.VistaAlternaActiva: Boolean;
begin
  Result := FVistaAlterna <> nil;
end;

procedure TFormClasificadorBase.MostrarVista(AVista: TWinControl);
begin
  if FVistaAlterna <> nil then
    Exit;
  FVistaAlterna := AVista;
  FPanelEstabaAbierto := FPanel.Visible;
  FPanel.Visible := False;
  FIndice.Visible := False;
  FZonaTabla.Visible := False;
  FBuscar.Visible := False;
  FBtnNuevo.Visible := False;
  FBtnExportar.Visible := False;
  AVista.Parent := Self;
  AVista.Align := alClient;
  AVista.Visible := True;
  AVista.BringToFront;
end;

procedure TFormClasificadorBase.VolverALista;
begin
  if FVistaAlterna = nil then
    Exit;
  FVistaAlterna.Visible := False;
  FVistaAlterna := nil;
  FZonaTabla.Visible := True;
  FIndice.Visible := FIndice.Tag = 1;
  FPanel.Visible := FPanelEstabaAbierto;
  FBuscar.Visible := True;
  FBtnNuevo.Visible := True;
  FBtnExportar.Visible := True;
end;

procedure TFormClasificadorBase.ConstruirPanel;
var
  Barra: TPanel;
  Linea: TPanel;
begin
  FPanel := TPanel.Create(Self);
  FPanel.Parent := Self;
  FPanel.Align := alRight;
  FPanel.Width := Esc(430);
  FPanel.BevelOuter := bvNone;
  FPanel.ParentBackground := False;
  FPanel.StyleElements := [];
  FPanel.ShowCaption := False;
  FPanel.Color := FTema.Superficie;
  FPanel.Visible := False;

  Linea := TPanel.Create(Self);
  Linea.Parent := FPanel;
  Linea.Align := alLeft;
  Linea.Width := 1;
  Linea.BevelOuter := bvNone;
  Linea.ParentBackground := False;
  Linea.StyleElements := [];
  Linea.Color := FTema.Linea;

  Barra := TPanel.Create(Self);
  Barra.Parent := FPanel;
  Barra.Align := alTop;
  Barra.Height := Esc(52);
  Barra.BevelOuter := bvNone;
  Barra.ParentBackground := False;
  Barra.StyleElements := [];
  Barra.ShowCaption := False;
  Barra.Color := FTema.Superficie;

  FTituloPanel := TLabel.Create(Self);
  FTituloPanel.Parent := Barra;
  FTituloPanel.AutoSize := False;
  FTituloPanel.Transparent := True;
  FTituloPanel.StyleElements := [];
  FTituloPanel.Font.Name := 'Segoe UI Semibold';
  FTituloPanel.Font.Size := 11;
  FTituloPanel.Font.Color := FTema.Texto;
  FTituloPanel.Layout := tlCenter;
  FTituloPanel.Align := alClient;
  FTituloPanel.AlignWithMargins := True;
  FTituloPanel.Margins.SetBounds(Esc(18), 0, 0, 0);

  FCerrarPanel := TLabel.Create(Self);
  FCerrarPanel.Parent := Barra;
  FCerrarPanel.AutoSize := False;
  FCerrarPanel.Alignment := taCenter;
  FCerrarPanel.Transparent := True;
  FCerrarPanel.StyleElements := [];
  FCerrarPanel.Font.Name := 'Segoe UI Symbol';
  FCerrarPanel.Font.Size := 11;
  FCerrarPanel.Font.Color := FTema.TextoSuave;
  FCerrarPanel.Layout := tlCenter;
  FCerrarPanel.Caption := #$2715;
  FCerrarPanel.Cursor := crHandPoint;
  FCerrarPanel.Hint := 'Cerrar';
  FCerrarPanel.ShowHint := True;
  FCerrarPanel.Align := alRight;
  FCerrarPanel.Width := Esc(44);
  FCerrarPanel.OnClick := CerrarPanelClick;

  FBarraAcciones := TPanel.Create(Self);
  FBarraAcciones.Parent := FPanel;
  FBarraAcciones.Align := alBottom;
  FBarraAcciones.Height := Esc(62);
  FBarraAcciones.BevelOuter := bvNone;
  FBarraAcciones.ParentBackground := False;
  FBarraAcciones.StyleElements := [];
  FBarraAcciones.ShowCaption := False;
  FBarraAcciones.Color := FTema.Superficie2;

  // Los botones se alinean (no se posicionan a mano) para que sigan al ancho real
  FBtnGuardar := NuevoBoton(FBarraAcciones, 'Guardar', 'guardar', True, FTema.Texto);
  FBtnGuardar.Align := alLeft;
  FBtnGuardar.Width := Esc(116);
  FBtnGuardar.AlignWithMargins := True;
  FBtnGuardar.Margins.SetBounds(Esc(16), Esc(13), 0, Esc(13));
  FBtnGuardar.OnClick := GuardarClick;
  FBtnCancelar := NuevoBoton(FBarraAcciones, 'Cancelar', 'cancelar', False, FTema.Texto);
  FBtnCancelar.Align := alLeft;
  FBtnCancelar.Width := Esc(124);
  FBtnCancelar.AlignWithMargins := True;
  FBtnCancelar.Margins.SetBounds(Esc(8), Esc(13), 0, Esc(13));
  FBtnCancelar.OnClick := CancelarClick;
  FBtnEliminar := NuevoBoton(FBarraAcciones, 'Eliminar', 'eliminar', False,
    Mezclar(clRed, FTema.Texto, 0.35));
  FBtnEliminar.Align := alRight;
  FBtnEliminar.Width := Esc(116);
  FBtnEliminar.AlignWithMargins := True;
  FBtnEliminar.Margins.SetBounds(0, Esc(13), Esc(16), Esc(13));
  FBtnEliminar.OnClick := EliminarClick;

  FCuerpo := TScrollBox.Create(Self);
  FCuerpo.Parent := FPanel;
  FCuerpo.Align := alClient;
  FCuerpo.BorderStyle := bsNone;
  FCuerpo.HorzScrollBar.Visible := False;
  FCuerpo.StyleElements := [];
  FCuerpo.Color := FTema.Superficie;
  FCuerpo.AlignWithMargins := True;
  FCuerpo.Margins.SetBounds(Esc(16), Esc(4), Esc(16), Esc(4));
end;

procedure TFormClasificadorBase.Embeber(AHost: TWinControl);
begin
  FEmbebido := True;
  BorderStyle := bsNone;
  BorderIcons := [];
  Color := FTema.Fondo;
  Parent := AHost;
  Align := alClient;
  // El titulo ya lo muestra la cabecera de la ventana principal: aqui queda el
  // subtitulo (p. ej. el numero de elementos) como texto principal.
  FTitulo.Visible := False;
  FSubtitulo.Font.Size := 10;
  FSubtitulo.SetBounds(Esc(20), (FCabecera.Height - FSubtitulo.Height) div 2,
    FSubtitulo.Width, FSubtitulo.Height);
  Visible := True;
end;

function TFormClasificadorBase.PuedeSalir: Boolean;
begin
  Result := ConfirmarAbandonar;
end;

procedure TFormClasificadorBase.FijarSubtitulo(const ATexto: string);
begin
  FSubtitulo.Caption := ATexto;
end;

function TFormClasificadorBase.AgregarColumna(const ATitulo: string; AAncho: Integer): TcxGridColumn;
begin
  Result := FVista.CreateColumn;
  Result.DataBinding.ValueTypeClass := TcxStringValueType;
  Result.Caption := UpperCase(ATitulo);
  Result.Width := Esc(AAncho);
  Result.Options.Editing := False;
  Result.Options.Focusing := False;
end;

procedure TFormClasificadorBase.AgregarFila(const AValores: array of Variant; ATag: Integer);
var
  V: TArray<Variant>;
  I: Integer;
begin
  SetLength(V, Length(AValores));
  for I := 0 to High(AValores) do
    V[I] := AValores[I];
  FFilas.Add(V);
  FTags.Add(ATag);
end;

procedure TFormClasificadorBase.LimpiarFilas;
begin
  FFilas.Clear;
  FTags.Clear;
end;

procedure TFormClasificadorBase.RefrescarVista;
var
  I, J, N, Previo, Col: Integer;
  Texto: string;
  Coincide: Boolean;
begin
  Previo := FilaActualTag;
  FSilencio := True;
  FVista.BeginUpdate;
  try
    FVista.DataController.RecordCount := 0;
    N := 0;
    for I := 0 to FFilas.Count - 1 do
    begin
      if FFiltro <> '' then
      begin
        Texto := '';
        for J := 0 to High(FFilas[I]) do
          Texto := Texto + ' ' + VarToStr(FFilas[I][J]);
        Coincide := Pos(AnsiLowerCase(FFiltro), AnsiLowerCase(Texto)) > 0;
      end
      else
        Coincide := True;
      if not Coincide then
        Continue;
      FVista.DataController.RecordCount := N + 1;
      FVista.DataController.Values[N, FColTag.Index] := FTags[I];
      Col := 0;
      for J := 0 to FVista.ItemCount - 1 do
        if FVista.Items[J] <> FColTag then
        begin
          if Col <= High(FFilas[I]) then
            FVista.DataController.Values[N, J] := FFilas[I][Col];
          Inc(Col);
        end;
      Inc(N);
    end;
  finally
    FVista.EndUpdate;
    FSilencio := False;
  end;
  if Previo >= 0 then
    SeleccionarPorTag(Previo);
end;

function TFormClasificadorBase.TagDeRegistro(ARegistro: TcxCustomGridRecord): Integer;
var
  V: Variant;
begin
  Result := -1;
  if ARegistro = nil then
    Exit;
  V := FVista.DataController.Values[ARegistro.RecordIndex, FColTag.Index];
  if not VarIsNull(V) then
    Result := V;
end;

function TFormClasificadorBase.FilaActualTag: Integer;
begin
  Result := TagDeRegistro(FVista.Controller.FocusedRecord);
end;

procedure TFormClasificadorBase.SeleccionarPorTag(ATag: Integer);
var
  I: Integer;
  V: Variant;
begin
  for I := 0 to FVista.DataController.RecordCount - 1 do
  begin
    V := FVista.DataController.Values[I, FColTag.Index];
    if (not VarIsNull(V)) and (Integer(V) = ATag) then
    begin
      FSilencio := True;
      try
        FVista.DataController.ChangeFocusedRecordIndex(I);
      finally
        FSilencio := False;
      end;
      Exit;
    end;
  end;
end;

procedure TFormClasificadorBase.AbrirPanel(const ATitulo: string; AMostrarEliminar: Boolean);
begin
  FTituloPanel.Caption := ATitulo;
  FBtnEliminar.Visible := AMostrarEliminar;
  FPanel.Visible := True;
  FPanel.BringToFront;
end;

procedure TFormClasificadorBase.CerrarPanel;
begin
  FPanel.Visible := False;
  FEstado.Elegir;
end;

function TFormClasificadorBase.PanelAbierto: Boolean;
begin
  Result := FPanel.Visible;
end;

procedure TFormClasificadorBase.FijarBotones(AGuardar, ACancelar, AEliminar: Boolean);
begin
  FBtnGuardar.Enabled := AGuardar;
  FBtnCancelar.Enabled := ACancelar;
  FBtnEliminar.Enabled := AEliminar;
  FBtnGuardar.Invalidate;
  FBtnCancelar.Invalidate;
  FBtnEliminar.Invalidate;
end;

function TFormClasificadorBase.ConfirmarAbandonar: Boolean;
begin
  if not FEstado.RequiereConfirmarAbandono then
    Exit(True);
  Result := TMensajes.Confirmar('Hay cambios sin guardar. '#191'Desea descartarlos?',
    'Cambios sin guardar');
  if Result then
    FEstado.Descartado;
end;

procedure TFormClasificadorBase.AlCancelar;
begin
  FEstado.Descartado;
  CerrarPanel;
end;

procedure TFormClasificadorBase.BuscarCambio(Sender: TObject);
begin
  FFiltro := Trim(FBuscar.Edit.Text);
  RefrescarVista;
end;

procedure TFormClasificadorBase.NuevoClick(Sender: TObject);
begin
  if not ConfirmarAbandonar then
    Exit;
  FEstado.Nuevo;
  AlNuevo;
end;

procedure TFormClasificadorBase.ExportarClick(Sender: TObject);
begin
  try
    ExcelExport(nil, FGrid);
  except
    on E: Exception do
      TMensajes.Error('No se pudo exportar: ' + E.Message, 'Exportar');
  end;
end;

procedure TFormClasificadorBase.GuardarClick(Sender: TObject);
begin
  if FBtnGuardar.Enabled then
    AlGuardar;
end;

procedure TFormClasificadorBase.CancelarClick(Sender: TObject);
begin
  if not ConfirmarAbandonar then
    Exit;
  AlCancelar;
end;

procedure TFormClasificadorBase.EliminarClick(Sender: TObject);
begin
  if FBtnEliminar.Enabled then
    AlEliminar;
end;

procedure TFormClasificadorBase.CerrarPanelClick(Sender: TObject);
begin
  if ConfirmarAbandonar then
    CerrarPanel;
end;

procedure TFormClasificadorBase.VistaFocoCambiado(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
var
  Tag: Integer;
begin
  if FSilencio then
    Exit;
  Tag := TagDeRegistro(AFocusedRecord);
  if Tag < 0 then
    Exit;
  if not ConfirmarAbandonar then
  begin
    // vuelve a la fila anterior sin disparar otra confirmacion
    if APrevFocusedRecord <> nil then
    begin
      FSilencio := True;
      try
        FVista.DataController.ChangeFocusedRecordIndex(APrevFocusedRecord.RecordIndex);
      finally
        FSilencio := False;
      end;
    end;
    Exit;
  end;
  FEstado.Elegir;
  AlElegirFila(Tag);
end;

{ Cabecera de columna sin bordes de rejilla: fondo suave, texto pequeno y una
  linea inferior; la flecha del orden se dibuja como texto. }
procedure TFormClasificadorBase.VistaDibujarCabecera(Sender: TcxGridTableView; ACanvas: TcxCanvas;
  AViewInfo: TcxGridColumnHeaderViewInfo; var ADone: Boolean);
var
  R: TRect;
  Texto: string;
begin
  R := AViewInfo.Bounds;
  ACanvas.Brush.Color := FTema.Superficie2;
  ACanvas.FillRect(R);
  ACanvas.Brush.Color := FTema.Linea;
  ACanvas.FillRect(Rect(R.Left, R.Bottom - 1, R.Right, R.Bottom));
  Texto := AViewInfo.Text;
  if AViewInfo.Column.SortOrder = soAscending then
    Texto := Texto + '  '#9650
  else if AViewInfo.Column.SortOrder = soDescending then
    Texto := Texto + '  '#9660;
  ACanvas.Font.Name := 'Segoe UI';
  ACanvas.Font.Size := 8;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := FTema.TextoSuave;
  ACanvas.Brush.Style := bsClear;
  ACanvas.DrawText(Texto, Rect(R.Left + Esc(12), R.Top, R.Right - Esc(6), R.Bottom),
    cxAlignVCenter or cxAlignLeft or cxSingleLine);
  ADone := True;
end;

procedure TFormClasificadorBase.FormCerrando(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := ConfirmarAbandonar;
end;

procedure TFormClasificadorBase.FormTecla(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    if PanelAbierto then
    begin
      if ConfirmarAbandonar then
        CerrarPanel;
    end
    else if FEmbebido then
    begin
      if Assigned(FOnSalir) then
        FOnSalir(Self);
    end
    else
      Close;
    Key := 0;
  end;
end;

end.
