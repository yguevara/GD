unit UPanelLateral;

{ Panel lateral unico de la pantalla de documentos: cabecera con el nombre y el
  codigo de la subserie, tira de pestanas y una pagina por pestana. Se crea por
  codigo (sin .dfm). Quien lo usa le pasa los controles de cada pagina con
  MoverContenido, que solo cambia su contenedor (conservan datos y eventos).
  Colores de UTema. Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Graphics, UTema;

const
  PAG_SERIES = 0;
  PAG_DETALLE = 1;
  PAG_COMPLEMENTARIA = 2;
  MODO_SUBSERIE = 0;
  MODO_DOCUMENTO = 1;

type
  { Tira de pestanas: texto y subrayado de la activa. }
  TTiraPestanas = class(TCustomControl)
  private
    FTitulos: TArray<string>;
    FActiva: Integer;
    FTema: TTemaColores;
    FOnElegir: TNotifyEvent;
    function IndiceEn(X: Integer): Integer;
    procedure SetActiva(Valor: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configurar(const T: TTemaColores);
    procedure Agregar(const Titulo: string);
    { Cambia el texto de una pestana (por ejemplo para anadir un contador). }
    procedure Retitular(Indice: Integer; const Titulo: string);
    function Titulo(Indice: Integer): string;
    property Activa: Integer read FActiva write SetActiva;
    property OnElegir: TNotifyEvent read FOnElegir write FOnElegir;
  end;

  TPanelLateral = class(TPanel)
  private
    FTema: TTemaColores;
    FConstruido: Boolean;
    FCabecera: TPanel;
    FLblTitulo: TLabel;
    FLblCodigo: TLabel;
    FTira: TTiraPestanas;
    FVacio: TPanel;
    FPaginas: TArray<TPanel>;
    FActiva: Integer;
    FOnCambioPagina: TNotifyEvent;
    FTiraModos: TTiraPestanas;
    FContDocumento: TPanel;
    FModo: Integer;
    FOnCambioModo: TNotifyEvent;
    procedure ModoElegido(Sender: TObject);
    procedure AplicarModo;
    procedure Construir;
    procedure TiraElegir(Sender: TObject);
    procedure MostrarActiva;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    function AgregarPagina(const Titulo: string): TPanel;
    procedure Activar(Indice: Integer);
    function PaginaActiva: Integer;
    function CantidadPaginas: Integer;
    { Titulo vacio: "Sin subserie". }
    procedure FijarCabecera(const Titulo, Codigo: string);
    function TextoCabecera: string;
    { Texto guia que tapa las paginas mientras no hay subserie elegida. }
    function VacioVisible: Boolean;
    { Recoloca y repinta todo el panel y sus controles. Al mostrarse por primera
      vez las paginas podian quedar en blanco hasta el primer evento. }
    procedure Repintar;
    property OnCambioPagina: TNotifyEvent read FOnCambioPagina write FOnCambioPagina;
    { Primer nivel de pestanas: Subserie (Series, Detalle, Complementaria) y
      Documento. Sin llamar a AgregarModoDocumento el panel se comporta como siempre.
      Devuelve el contenedor del modo Documento (ocupa todo el espacio bajo la tira). }
    function AgregarModoDocumento: TPanel;
    { Quita la tira de modos y el contenedor del documento y deja el panel como
      antes (camino de respaldo si el documento no pudo colocarse). }
    procedure QuitarModoDocumento;
    procedure ActivarModo(Modo: Integer);
    function ModoActivo: Integer;
    function TieneModoDocumento: Boolean;
    property OnCambioModo: TNotifyEvent read FOnCambioModo write FOnCambioModo;
    { Estado visible de cada parte (pruebas). }
    function TiraModosVisible: Boolean;
    function TiraPaginasVisible: Boolean;
    function CabeceraSubserieVisible: Boolean;
  end;

{ Pasa cada hijo de Origen a Destino, en su orden. Conservan Align, Anchors,
  datos y manejadores. Con Duenio <> nil solo se mueven los controles de ese
  duenio (los del formulario), no los que el propio Origen crea por dentro. }
procedure MoverContenido(Origen, Destino: TWinControl; Duenio: TComponent = nil);

implementation

uses
  System.Math, UShellPrincipal;

const
  FUENTE = 'Segoe UI';

procedure MoverContenido(Origen, Destino: TWinControl; Duenio: TComponent);
var
  Lista: TArray<TControl>;
  I, N: Integer;
begin
  SetLength(Lista, Origen.ControlCount);
  N := 0;
  for I := 0 to Origen.ControlCount - 1 do
    if (Duenio = nil) or (Origen.Controls[I].Owner = Duenio) then
    begin
      Lista[N] := Origen.Controls[I];
      Inc(N);
    end;
  for I := 0 to N - 1 do
    Lista[I].Parent := Destino;
end;

{ TTiraPestanas }

constructor TTiraPestanas.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  TabStop := True;
  Height := 36;
  Cursor := crHandPoint;
end;

procedure TTiraPestanas.Configurar(const T: TTemaColores);
begin
  FTema := T;
  Invalidate;
end;

procedure TTiraPestanas.Agregar(const Titulo: string);
begin
  SetLength(FTitulos, Length(FTitulos) + 1);
  FTitulos[High(FTitulos)] := Titulo;
  Invalidate;
end;

procedure TTiraPestanas.Retitular(Indice: Integer; const Titulo: string);
begin
  if (Indice >= 0) and (Indice <= High(FTitulos)) and (FTitulos[Indice] <> Titulo) then
  begin
    FTitulos[Indice] := Titulo;
    Invalidate;
  end;
end;

function TTiraPestanas.Titulo(Indice: Integer): string;
begin
  if (Indice >= 0) and (Indice <= High(FTitulos)) then
    Result := FTitulos[Indice]
  else
    Result := '';
end;

function TTiraPestanas.IndiceEn(X: Integer): Integer;
begin
  Result := -1;
  if Length(FTitulos) = 0 then
    Exit;
  Result := X * Length(FTitulos) div Max(1, ClientWidth);
  if Result > High(FTitulos) then
    Result := High(FTitulos);
  if Result < 0 then
    Result := 0;
end;

procedure TTiraPestanas.SetActiva(Valor: Integer);
begin
  if (Valor < 0) or (Valor > High(FTitulos)) or (Valor = FActiva) then
    Exit;
  FActiva := Valor;
  Invalidate;
end;

procedure TTiraPestanas.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  I: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  I := IndiceEn(X);
  if (Button = mbLeft) and (I >= 0) then
  begin
    if CanFocus then
      SetFocus;
    Activa := I;
    if Assigned(FOnElegir) then
      FOnElegir(Self);
  end;
end;

procedure TTiraPestanas.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_RIGHT) and (FActiva < High(FTitulos)) then
    Activa := FActiva + 1
  else if (Key = VK_LEFT) and (FActiva > 0) then
    Activa := FActiva - 1
  else
    Exit;
  Key := 0;
  if Assigned(FOnElegir) then
    FOnElegir(Self);
end;

procedure TTiraPestanas.Paint;
var
  I, Ancho: Integer;
  R: TRect;
begin
  Canvas.Brush.Color := FTema.Superficie;
  Canvas.FillRect(ClientRect);
  Canvas.Pen.Color := FTema.Linea;
  Canvas.MoveTo(0, Height - 1);
  Canvas.LineTo(Width, Height - 1);
  if Length(FTitulos) = 0 then
    Exit;
  Ancho := Width div Length(FTitulos);
  SetBkMode(Canvas.Handle, TRANSPARENT);
  for I := 0 to High(FTitulos) do
  begin
    R := Rect(I * Ancho, 0, (I + 1) * Ancho, Height - 1);
    Canvas.Font.Name := FUENTE;
    Canvas.Font.Size := 9;
    Canvas.Font.Style := [fsBold];
    if I = FActiva then
    begin
      Canvas.Font.Color := FTema.Acento;
      // subrayado de la pestana activa
      Canvas.Brush.Style := bsSolid;
      Canvas.Brush.Color := FTema.Acento;
      Canvas.FillRect(Rect(R.Left, Height - 3, R.Right, Height));
    end
    else
      Canvas.Font.Color := FTema.TextoSuave;
    // el texto va sin fondo: el pincel anterior (naranja) taparia las letras
    Canvas.Brush.Style := bsClear;
    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawText(Canvas.Handle, PChar(FTitulos[I]), Length(FTitulos[I]), R,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
  end;
  if Focused then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := FTema.Acento;
    Canvas.Rectangle(Rect(0, 0, Width, Height - 1));
  end;
end;

{ TPanelLateral }

constructor TPanelLateral.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if TemaWindowsOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
end;

procedure TPanelLateral.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not FConstruido then
  begin
    FConstruido := True;
    Construir;
  end;
end;

procedure TPanelLateral.Construir;
begin
  BevelOuter := bvNone;
  ParentBackground := False;
  StyleElements := [];
  ShowCaption := False;
  Color := FTema.Superficie;

  FCabecera := TPanel.Create(Self);
  FCabecera.Parent := Self;
  FCabecera.Align := alTop;
  FCabecera.Height := 48;
  FCabecera.BevelOuter := bvNone;
  FCabecera.ParentBackground := False;
  FCabecera.StyleElements := [];
  FCabecera.ShowCaption := False;
  FCabecera.Color := FTema.Superficie;

  FLblCodigo := TLabel.Create(Self);
  FLblCodigo.Parent := FCabecera;
  FLblCodigo.Align := alRight;
  FLblCodigo.AlignWithMargins := True;
  FLblCodigo.Margins.SetBounds(6, 14, 14, 14);
  FLblCodigo.Transparent := False;
  FLblCodigo.StyleElements := [];
  FLblCodigo.Font.Name := FUENTE;
  FLblCodigo.Font.Size := 9;
  FLblCodigo.Font.Color := FTema.Acento;
  FLblCodigo.Color := FTema.AcentoSuave;
  FLblCodigo.Layout := tlCenter;
  FLblCodigo.Alignment := taCenter;

  FLblTitulo := TLabel.Create(Self);
  FLblTitulo.Parent := FCabecera;
  FLblTitulo.Align := alClient;
  FLblTitulo.AlignWithMargins := True;
  FLblTitulo.Margins.SetBounds(14, 6, 6, 6);
  FLblTitulo.Transparent := True;
  FLblTitulo.StyleElements := [];
  FLblTitulo.Layout := tlCenter;
  FLblTitulo.EllipsisPosition := epEndEllipsis;
  FLblTitulo.Font.Name := FUENTE;
  FLblTitulo.Font.Size := 11;
  FLblTitulo.Font.Style := [fsBold];
  FLblTitulo.Font.Color := FTema.Texto;

  FTira := TTiraPestanas.Create(Self);
  FTira.Parent := Self;
  FTira.Align := alTop;
  FTira.Configurar(FTema);
  FTira.OnElegir := TiraElegir;

  // Sin subserie las paginas solo mostrarian rejillas vacias: se tapan con un texto guia
  FVacio := TPanel.Create(Self);
  FVacio.Parent := Self;
  FVacio.Align := alClient;
  FVacio.BevelOuter := bvNone;
  FVacio.ParentBackground := False;
  FVacio.StyleElements := [];
  FVacio.Color := FTema.Superficie;
  FVacio.Caption := 'Elija una subserie para ver su informacion';
  FVacio.Font.Name := FUENTE;
  FVacio.Font.Size := 10;
  FVacio.Font.Color := FTema.TextoSuave;

  FijarCabecera('', '');
end;

function TPanelLateral.AgregarModoDocumento: TPanel;
begin
  if FContDocumento <> nil then
    Exit(FContDocumento);
  FContDocumento := TPanel.Create(Self);
  FContDocumento.Parent := Self;
  FContDocumento.Align := alClient;
  FContDocumento.BevelOuter := bvNone;
  FContDocumento.ParentBackground := False;
  FContDocumento.StyleElements := [];
  FContDocumento.ShowCaption := False;
  FContDocumento.Color := FTema.Superficie;
  FTiraModos := TTiraPestanas.Create(Self);
  FTiraModos.Parent := Self;
  FTiraModos.Align := alTop;
  FTiraModos.Top := -1; // encima de la cabecera de la subserie
  FTiraModos.Configurar(FTema);
  FTiraModos.Agregar('Subserie');
  FTiraModos.Agregar('Documento');
  FTiraModos.OnElegir := ModoElegido;
  AplicarModo;
  Result := FContDocumento;
end;

procedure TPanelLateral.QuitarModoDocumento;
begin
  FModo := MODO_SUBSERIE;
  if FTiraModos <> nil then
    FreeAndNil(FTiraModos);
  if FContDocumento <> nil then
    FreeAndNil(FContDocumento);
  AplicarModo;
end;

procedure TPanelLateral.AplicarModo;
var
  EnSubserie: Boolean;
  I: Integer;
begin
  EnSubserie := (FContDocumento = nil) or (FModo = MODO_SUBSERIE);
  FCabecera.Visible := EnSubserie;
  FTira.Visible := EnSubserie;
  for I := 0 to High(FPaginas) do
    FPaginas[I].Visible := EnSubserie and (I = FActiva);
  FVacio.Visible := EnSubserie and (Trim(FLblTitulo.Caption) = 'Sin subserie');
  if FContDocumento <> nil then
  begin
    FContDocumento.Visible := not EnSubserie;
    if not EnSubserie then
      FContDocumento.BringToFront;
  end;
  if FVacio.Visible then
    FVacio.BringToFront;
end;

procedure TPanelLateral.ActivarModo(Modo: Integer);
begin
  if (FContDocumento = nil) or (Modo < MODO_SUBSERIE) or (Modo > MODO_DOCUMENTO) or
    (Modo = FModo) then
    Exit;
  FModo := Modo;
  FTiraModos.Activa := Modo;
  AplicarModo;
  if Assigned(FOnCambioModo) then
    FOnCambioModo(Self);
end;

procedure TPanelLateral.ModoElegido(Sender: TObject);
begin
  if FTiraModos.Activa <> FModo then
  begin
    FModo := FTiraModos.Activa;
    AplicarModo;
    if Assigned(FOnCambioModo) then
      FOnCambioModo(Self);
  end;
end;

function TPanelLateral.ModoActivo: Integer;
begin
  Result := FModo;
end;

function TPanelLateral.TieneModoDocumento: Boolean;
begin
  Result := FContDocumento <> nil;
end;

function TPanelLateral.TiraModosVisible: Boolean;
begin
  Result := (FTiraModos <> nil) and FTiraModos.Visible;
end;

function TPanelLateral.TiraPaginasVisible: Boolean;
begin
  Result := FTira.Visible;
end;

function TPanelLateral.CabeceraSubserieVisible: Boolean;
begin
  Result := FCabecera.Visible;
end;

function TPanelLateral.VacioVisible: Boolean;
begin
  Result := FVacio.Visible;
end;

function TPanelLateral.AgregarPagina(const Titulo: string): TPanel;
begin
  Result := TPanel.Create(Self);
  Result.Parent := Self;
  Result.Align := alClient;
  Result.BevelOuter := bvNone;
  Result.ParentBackground := False;
  Result.StyleElements := [];
  Result.ShowCaption := False;
  Result.Color := FTema.Superficie;
  SetLength(FPaginas, Length(FPaginas) + 1);
  FPaginas[High(FPaginas)] := Result;
  FTira.Agregar(Titulo);
  MostrarActiva;
end;

procedure TPanelLateral.MostrarActiva;
var
  I: Integer;
begin
  for I := 0 to High(FPaginas) do
    FPaginas[I].Visible := (I = FActiva) and ((FContDocumento = nil) or (FModo = MODO_SUBSERIE));
end;

procedure TPanelLateral.Activar(Indice: Integer);
begin
  if (Indice < 0) or (Indice > High(FPaginas)) then
    Exit;
  // pedir una pagina de la subserie (Series, Detalle, Complementaria) la muestra
  ActivarModo(MODO_SUBSERIE);
  if Indice = FActiva then
    Exit;
  FActiva := Indice;
  FTira.Activa := Indice;
  MostrarActiva;
  if Assigned(FOnCambioPagina) then
    FOnCambioPagina(Self);
end;

procedure TPanelLateral.TiraElegir(Sender: TObject);
begin
  if FTira.Activa <> FActiva then
  begin
    FActiva := FTira.Activa;
    MostrarActiva;
    if Assigned(FOnCambioPagina) then
      FOnCambioPagina(Self);
  end;
end;

function TPanelLateral.PaginaActiva: Integer;
begin
  Result := FActiva;
end;

function TPanelLateral.CantidadPaginas: Integer;
begin
  Result := Length(FPaginas);
end;

procedure TPanelLateral.FijarCabecera(const Titulo, Codigo: string);
begin
  if Trim(Titulo) = '' then
    FLblTitulo.Caption := 'Sin subserie'
  else
    FLblTitulo.Caption := Trim(Titulo);
  FLblCodigo.Caption := ' ' + Trim(Codigo) + ' ';
  FLblCodigo.Visible := Trim(Codigo) <> '';
  FVacio.Visible := (Trim(Titulo) = '') and ((FContDocumento = nil) or (FModo = MODO_SUBSERIE));
  if FVacio.Visible then
    FVacio.BringToFront;
end;

function TPanelLateral.TextoCabecera: string;
begin
  Result := FLblTitulo.Caption;
end;

procedure TPanelLateral.Repintar;
begin
  Realign;
  if HandleAllocated then
    RedrawWindow(Handle, nil, 0,
      RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN or RDW_UPDATENOW);
end;

end.
