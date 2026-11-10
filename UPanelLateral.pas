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
    FPaginas: TArray<TPanel>;
    FActiva: Integer;
    FOnCambioPagina: TNotifyEvent;
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
    { Recoloca y repinta todo el panel y sus controles. Al mostrarse por primera
      vez las paginas podian quedar en blanco hasta el primer evento. }
    procedure Repintar;
    property OnCambioPagina: TNotifyEvent read FOnCambioPagina write FOnCambioPagina;
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

  FijarCabecera('', '');
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
    FPaginas[I].Visible := I = FActiva;
end;

procedure TPanelLateral.Activar(Indice: Integer);
begin
  if (Indice < 0) or (Indice > High(FPaginas)) or (Indice = FActiva) then
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
