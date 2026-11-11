unit UPanelDocumento;

{ Panel del documento seleccionado: cabecera (codigo, titulo y estado) y una
  pestana por tipo de informacion: Datos, Ubicacion, Archivos, Metadatos,
  Historia y Contenido. Se crea por codigo (sin .dfm) y no accede a datos:
  quien lo usa llena cada pagina (Pagina) y le indica el estado y el numero de
  archivos. Reutiliza la tira de pestanas de UPanelLateral. Colores de UTema.
  Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Graphics, UTema, UDocumentoVista, UPanelLateral;

type
  { Cabecera del documento dibujada en un solo control: codigo (negrita), titulo
    debajo y el estado a la derecha. Todo se mide con la fuente real, asi que no se
    superponen con ninguna escala de pantalla; lo que no cabe termina en "...". }
  TCabeceraDoc = class(TCustomControl)
  private
    FTema: TTemaColores;
    FCodigo, FTitulo, FEstado: string;
    FOnAltoCambio: TNotifyEvent;
    FAltoUltimo: Integer;
    procedure PrepararLienzo;
    procedure AvisarAlto;
  protected
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Configurar(const T: TTemaColores);
    procedure Fijar(const Codigo, Titulo, Estado: string);
    function AltoNecesario: Integer;
    { Lineas que ocupa el titulo con el ancho actual (1 o 2; si no cabe en dos se
      termina en "..." y el titulo completo esta en el globo de ayuda). }
    function LineasTitulo: Integer;
    property OnAltoCambio: TNotifyEvent read FOnAltoCambio write FOnAltoCambio;
    property Codigo: string read FCodigo;
    property Estado: string read FEstado;
  end;

  TPanelDocumento = class(TPanel)
  private
    FTema: TTemaColores;
    FConstruido: Boolean;
    FCabecera: TPanel;
    FCab: TCabeceraDoc;
    FTira: TTiraPestanas;
    FPaginas: array[TPestanaDoc] of TPanel;
    FActiva: TPestanaDoc;
    FOnCambioPestana: TNotifyEvent;
    procedure Construir;
    procedure CabeceraAlto(Sender: TObject);
    procedure TiraElegir(Sender: TObject);
    procedure MostrarActiva;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    { Contenedor de una pestana: quien usa el panel pone ahi sus controles. }
    function Pagina(P: TPestanaDoc): TPanel;
    procedure Activar(P: TPestanaDoc);
    property Activa: TPestanaDoc read FActiva;
    { Codigo vacio: "Sin documento". El estado solo se muestra si se conoce. }
    procedure FijarCabecera(const Codigo, Titulo: string; Estado: TEstadoDoc);
    { Numero de archivos del documento junto al nombre de la pestana Archivos. }
    procedure FijarConteoArchivos(N: Integer);
    function TextoCodigo: string;
    function LineasTitulo: Integer;
    function AltoCabecera: Integer;
    function HintCabecera: string;
    function TextoEstado: string;
    function TituloPestana(P: TPestanaDoc): string;
    property OnCambioPestana: TNotifyEvent read FOnCambioPestana write FOnCambioPestana;
  end;

implementation

uses
  System.Math, UShellPrincipal;

const
  FUENTE = 'Segoe UI';

{ TCabeceraDoc }

constructor TCabeceraDoc.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  FCodigo := 'Sin documento';
end;

procedure TCabeceraDoc.Configurar(const T: TTemaColores);
begin
  FTema := T;
  Invalidate;
end;

procedure TCabeceraDoc.Fijar(const Codigo, Titulo, Estado: string);
begin
  if (Codigo = FCodigo) and (Titulo = FTitulo) and (Estado = FEstado) then
    Exit;
  FCodigo := Codigo;
  FTitulo := Titulo;
  FEstado := Estado;
  Hint := Trim(Codigo + ' - ' + Titulo);
  ShowHint := Titulo <> '';
  Invalidate;
  AvisarAlto;
end;

procedure TCabeceraDoc.Resize;
begin
  inherited Resize;
  AvisarAlto;
end;

procedure TCabeceraDoc.AvisarAlto;
var
  A: Integer;
begin
  A := AltoNecesario;
  if (A <> FAltoUltimo) then
  begin
    FAltoUltimo := A;
    if Assigned(FOnAltoCambio) then
      FOnAltoCambio(Self);
  end;
end;

function TCabeceraDoc.LineasTitulo: Integer;
var
  R: TRect;
  H1: Integer;
begin
  Result := 1;
  if (FTitulo = '') or (Width < 60) then
    Exit;
  PrepararLienzo;
  Canvas.Font.Size := 9;
  Canvas.Font.Style := [];
  H1 := Canvas.TextHeight('Ag');
  R := Rect(0, 0, Width - 28, 0);
  DrawText(Canvas.Handle, PChar(FTitulo), -1, R,
    DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX or DT_LEFT);
  if (R.Bottom - R.Top) > H1 + 2 then
    Result := 2;
end;

procedure TCabeceraDoc.PrepararLienzo;
begin
  Canvas.Font.Name := FUENTE;
end;

function TCabeceraDoc.AltoNecesario: Integer;
begin
  PrepararLienzo;
  Canvas.Font.Size := 11;
  Canvas.Font.Style := [fsBold];
  Result := Canvas.TextHeight('Ag') + 10;
  Canvas.Font.Size := 9;
  Canvas.Font.Style := [];
  Result := Result + LineasTitulo * Canvas.TextHeight('Ag') + 12;
end;

procedure TCabeceraDoc.Paint;
var
  R, RC, RT, RE: TRect;
  AnchoEstado, Y, H1: Integer;
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FTema.Superficie;
  Canvas.FillRect(ClientRect);
  PrepararLienzo;
  R := ClientRect;
  AnchoEstado := 0;
  if FEstado <> '' then
  begin
    Canvas.Font.Size := 9;
    Canvas.Font.Style := [];
    AnchoEstado := Canvas.TextWidth(FEstado) + 16;
    RE := Rect(R.Right - 14 - AnchoEstado, 8,  R.Right - 14, 8 + Canvas.TextHeight('Ag') + 6);
    Canvas.Brush.Color := FTema.AcentoSuave;
    Canvas.FillRect(RE);
    Canvas.Font.Color := FTema.Acento;
    Canvas.Brush.Style := bsClear;
    DrawText(Canvas.Handle, PChar(FEstado), -1, RE,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_NOPREFIX);
  end;
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Size := 11;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := FTema.Texto;
  H1 := Canvas.TextHeight('Ag');
  Y := 6;
  RC := Rect(14, Y, R.Right - 14 - IfThen(AnchoEstado > 0, AnchoEstado + 8, 0), Y + H1);
  DrawText(Canvas.Handle, PChar(FCodigo), -1, RC,
    DT_LEFT or DT_SINGLELINE or DT_NOPREFIX or DT_END_ELLIPSIS);
  Canvas.Font.Size := 9;
  Canvas.Font.Style := [];
  Canvas.Font.Color := FTema.TextoSuave;
  // hasta dos lineas: lo que no cabe termina en "..." (el titulo completo esta en el hint)
  RT := Rect(14, Y + H1 + 4, R.Right - 14,
    Y + H1 + 4 + 2 * Canvas.TextHeight('Ag') + 2);
  DrawText(Canvas.Handle, PChar(FTitulo), -1, RT,
    DT_LEFT or DT_WORDBREAK or DT_NOPREFIX or DT_END_ELLIPSIS);
end;

{ TPanelDocumento }

constructor TPanelDocumento.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if TemaWindowsOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
end;

procedure TPanelDocumento.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not FConstruido then
  begin
    FConstruido := True;
    Construir;
  end;
end;

procedure TPanelDocumento.Construir;
var
  P: TPestanaDoc;
begin
  BevelOuter := bvNone;
  ParentBackground := False;
  StyleElements := [];
  ShowCaption := False;
  Color := FTema.Superficie;

  FCabecera := TPanel.Create(Self);
  FCabecera.Parent := Self;
  FCabecera.Align := alTop;
  FCabecera.Height := 58;
  FCabecera.BevelOuter := bvNone;
  FCabecera.ParentBackground := False;
  FCabecera.StyleElements := [];
  FCabecera.ShowCaption := False;
  FCabecera.Color := FTema.Superficie;

  FCab := TCabeceraDoc.Create(Self);
  FCab.Parent := FCabecera;
  FCab.Align := alClient;
  FCab.Configurar(FTema);
  FCabecera.Height := FCab.AltoNecesario;
  FCab.OnAltoCambio := CabeceraAlto;

  FTira := TTiraPestanas.Create(Self);
  FTira.Parent := Self;
  FTira.Align := alTop;
  FTira.Configurar(FTema);
  FTira.Agregar('Datos');
  FTira.Agregar('Ubicacion');
  FTira.Agregar('Archivos');
  FTira.Agregar('Metadatos');
  FTira.Agregar('Historia');
  FTira.Agregar('Contenido');
  FTira.OnElegir := TiraElegir;

  for P := Low(TPestanaDoc) to High(TPestanaDoc) do
  begin
    FPaginas[P] := TPanel.Create(Self);
    FPaginas[P].Parent := Self;
    FPaginas[P].Align := alClient;
    FPaginas[P].BevelOuter := bvNone;
    FPaginas[P].ParentBackground := False;
    FPaginas[P].StyleElements := [];
    FPaginas[P].ShowCaption := False;
    FPaginas[P].Color := FTema.Superficie;
  end;
  MostrarActiva;
  FijarCabecera('', '', edDesconocido);
end;

function TPanelDocumento.Pagina(P: TPestanaDoc): TPanel;
begin
  Result := FPaginas[P];
end;

procedure TPanelDocumento.MostrarActiva;
var
  P: TPestanaDoc;
begin
  for P := Low(TPestanaDoc) to High(TPestanaDoc) do
    if FPaginas[P] <> nil then
      FPaginas[P].Visible := P = FActiva;
end;

procedure TPanelDocumento.Activar(P: TPestanaDoc);
begin
  if P = FActiva then
    Exit;
  FActiva := P;
  FTira.Activa := Ord(P);
  MostrarActiva;
  if Assigned(FOnCambioPestana) then
    FOnCambioPestana(Self);
end;

procedure TPanelDocumento.TiraElegir(Sender: TObject);
begin
  if Ord(FActiva) <> FTira.Activa then
  begin
    FActiva := TPestanaDoc(FTira.Activa);
    MostrarActiva;
    if Assigned(FOnCambioPestana) then
      FOnCambioPestana(Self);
  end;
end;

procedure TPanelDocumento.FijarCabecera(const Codigo, Titulo: string;
  Estado: TEstadoDoc);
begin
  if Trim(Codigo) = '' then
    FCab.Fijar('Sin documento', '', '')
  else if Estado = edDesconocido then
    FCab.Fijar(Trim(Codigo), Trim(Titulo), '')
  else
    FCab.Fijar(Trim(Codigo), Trim(Titulo), TextoEstadoDoc(Estado));
end;

procedure TPanelDocumento.FijarConteoArchivos(N: Integer);
begin
  if N > 0 then
    FTira.Retitular(Ord(pdArchivos), 'Archivos ' + IntToStr(N))
  else
    FTira.Retitular(Ord(pdArchivos), 'Archivos');
end;

function TPanelDocumento.LineasTitulo: Integer;
begin
  Result := FCab.LineasTitulo;
end;

function TPanelDocumento.AltoCabecera: Integer;
begin
  Result := FCabecera.Height;
end;

function TPanelDocumento.HintCabecera: string;
begin
  Result := FCab.Hint;
end;

procedure TPanelDocumento.CabeceraAlto(Sender: TObject);
begin
  FCabecera.Height := FCab.AltoNecesario;
end;

function TPanelDocumento.TextoCodigo: string;
begin
  Result := FCab.Codigo;
end;

function TPanelDocumento.TextoEstado: string;
begin
  Result := FCab.Estado;
end;

function TPanelDocumento.TituloPestana(P: TPestanaDoc): string;
begin
  Result := FTira.Titulo(Ord(P));
end;

end.
