unit UListaPropiedades;

{ Propiedades e historia de un documento en UN solo control que dibuja y mide
  su propio texto. No tiene controles hijos: no pueden quedar etiquetas viejas
  debajo de las nuevas, y el alto de cada fila sale de medir el texto (no se
  recorta con letra grande ni con DPI alto). Desplazamiento vertical propio.
  Colores de UTema. Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics, UTema, UDocumentoVista, UTrazabilidad;

type
  TTipoFila = (tfGrupo, tfEtiqueta, tfValor, tfSuave, tfEvento, tfEnlace);

  TFilaProp = record
    Tipo: TTipoFila;
    Texto: string;
    Y, Alto: Integer;
  end;

  TListaPropiedades = class(TCustomControl)
  private
    FTema: TTemaColores;
    FOscuro: Boolean;
    FFilas: TArray<TFilaProp>;
    FMensaje: Boolean;
    FAlto: Integer;
    FDesplazamiento: Integer;
    FMidiendo: Boolean;
    FOnVerHistoria: TNotifyEvent;
    procedure Medir;
    function AnchoTexto: Integer;
    procedure ConfigurarFuente(Tipo: TTipoFila);
    function FlagsTexto(Tipo: TTipoFila): Cardinal;
    procedure ActualizarBarra;
    procedure Desplazar(Nuevo: Integer);
    function EnlaceEn(X, Y: Integer): Boolean;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AplicarTema(const T: TTemaColores; Oscuro: Boolean);
    { Propiedades agrupadas y, si MostrarHistoria, la historia (los 5 eventos
      mas recientes y el enlace "Ver historia completa"). }
    procedure Mostrar(const Props: TArray<TPropiedad>;
      const Historia: TArray<TEventoDoc>; HayMas: Boolean;
      const MotivoHistoria: string; MostrarHistoria: Boolean);
    { Solo un texto guia (sin documento elegido). }
    procedure MostrarMensaje(const Texto: string);
    { Alto total del contenido, en pixeles. }
    function AlturaContenido: Integer;
    { Todo el texto mostrado, una fila por linea (para pruebas y diagnostico). }
    function Contenido: string;
    { Rectangulo (en el contenido, sin desplazar) del enlace de historia; vacio
      si no hay. }
    function RectEnlaceHistoria: TRect;
    property OnVerHistoria: TNotifyEvent read FOnVerHistoria write FOnVerHistoria;
  end;

implementation

uses
  System.Math, Winapi.UxTheme, UHistoriaDocumento, UShellPrincipal;

const
  FUENTE = 'Segoe UI';
  MARGEN = 14;
  MAX_EVENTOS = 5;

constructor TListaPropiedades.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  TabStop := False;
  FOscuro := TemaWindowsOscuro;
  if FOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
  Color := FTema.Superficie;
  Font.Name := FUENTE;
end;

procedure TListaPropiedades.CreateWnd;
begin
  inherited CreateWnd;
  if FOscuro then
    SetWindowTheme(Handle, 'DarkMode_Explorer', nil)
  else
    SetWindowTheme(Handle, 'Explorer', nil);
  ActualizarBarra;
end;

procedure TListaPropiedades.AplicarTema(const T: TTemaColores; Oscuro: Boolean);
begin
  FTema := T;
  FOscuro := Oscuro;
  Color := T.Superficie;
  if HandleAllocated then
    if Oscuro then
      SetWindowTheme(Handle, 'DarkMode_Explorer', nil)
    else
      SetWindowTheme(Handle, 'Explorer', nil);
  Invalidate;
end;

procedure TListaPropiedades.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1; // Paint rellena todo
end;

procedure TListaPropiedades.ConfigurarFuente(Tipo: TTipoFila);
begin
  Canvas.Font.Name := FUENTE;
  Canvas.Font.Style := [];
  case Tipo of
    tfGrupo:
      begin
        Canvas.Font.Size := 8;
        Canvas.Font.Style := [fsBold];
        Canvas.Font.Color := FTema.Acento;
      end;
    tfEtiqueta:
      begin
        Canvas.Font.Size := 8;
        Canvas.Font.Color := FTema.TextoSuave;
      end;
    tfValor:
      begin
        Canvas.Font.Size := 10;
        Canvas.Font.Color := FTema.Texto;
      end;
    tfSuave:
      begin
        Canvas.Font.Size := 9;
        Canvas.Font.Color := FTema.TextoSuave;
      end;
    tfEvento:
      begin
        Canvas.Font.Size := 9;
        Canvas.Font.Color := FTema.Texto;
      end;
    tfEnlace:
      begin
        Canvas.Font.Size := 9;
        Canvas.Font.Style := [fsUnderline];
        Canvas.Font.Color := FTema.Acento;
      end;
  end;
end;

{ Valores y textos suaves se parten en lineas; el resto va en una sola. }
function TListaPropiedades.FlagsTexto(Tipo: TTipoFila): Cardinal;
begin
  Result := DT_NOPREFIX or DT_LEFT;
  if Tipo in [tfValor, tfSuave] then
    Result := Result or DT_WORDBREAK
  else
    Result := Result or DT_SINGLELINE or DT_END_ELLIPSIS;
end;

function TListaPropiedades.AnchoTexto: Integer;
begin
  Result := Max(60, ClientWidth - 2 * MARGEN);
end;

procedure TListaPropiedades.Medir;
var
  I, Y, Antes, Despues: Integer;
  R: TRect;
begin
  Canvas.Lock;
  try
    Y := IfThen(FMensaje, 16, 10);
    for I := 0 to High(FFilas) do
    begin
      Antes := 0;
      Despues := 0;
      case FFilas[I].Tipo of
        tfGrupo: begin Antes := 6; Despues := 4; end;
        tfValor, tfSuave: Despues := 4;
        tfEvento: Despues := 3;
        tfEnlace: begin Antes := 4; Despues := 8; end;
      end;
      ConfigurarFuente(FFilas[I].Tipo);
      R := Rect(0, 0, AnchoTexto, 0);
      DrawText(Canvas.Handle, PChar(FFilas[I].Texto), Length(FFilas[I].Texto), R,
        FlagsTexto(FFilas[I].Tipo) or DT_CALCRECT);
      Inc(Y, Antes);
      FFilas[I].Y := Y;
      // un valor vacio ocupa una linea, como uno con texto
      FFilas[I].Alto := Max(R.Bottom - R.Top, Canvas.TextHeight('Ag'));
      Inc(Y, FFilas[I].Alto + Despues);
    end;
    FAlto := Y + 16;
  finally
    Canvas.Unlock;
  end;
end;

procedure TListaPropiedades.ActualizarBarra;
var
  Info: TScrollInfo;
begin
  if not HandleAllocated then
    Exit;
  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  Info.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
  Info.nMin := 0;
  Info.nMax := Max(0, FAlto - 1);
  Info.nPage := Max(1, ClientHeight);
  Info.nPos := FDesplazamiento;
  SetScrollInfo(Handle, SB_VERT, Info, True);
end;

procedure TListaPropiedades.Resize;
var
  Ancho: Integer;
begin
  inherited Resize;
  if FMidiendo or (csDestroying in ComponentState) then
    Exit;
  FMidiendo := True;
  try
    Ancho := ClientWidth;
    Medir;
    FDesplazamiento := Max(0, Min(FDesplazamiento, FAlto - ClientHeight));
    ActualizarBarra;
    // al aparecer o desaparecer la barra cambia el ancho: se mide una vez mas
    if ClientWidth <> Ancho then
    begin
      Medir;
      FDesplazamiento := Max(0, Min(FDesplazamiento, FAlto - ClientHeight));
      ActualizarBarra;
    end;
  finally
    FMidiendo := False;
  end;
  Invalidate;
end;

procedure TListaPropiedades.Mostrar(const Props: TArray<TPropiedad>;
  const Historia: TArray<TEventoDoc>; HayMas: Boolean;
  const MotivoHistoria: string; MostrarHistoria: Boolean);
var
  Lista: TArray<TFilaProp>;
  N, I, Tope: Integer;
  Grupo: string;

  procedure Anade(Tipo: TTipoFila; const Texto: string);
  begin
    if N > High(Lista) then
      SetLength(Lista, N * 2 + 8);
    Lista[N] := Default(TFilaProp);
    Lista[N].Tipo := Tipo;
    Lista[N].Texto := Texto;
    Inc(N);
  end;

begin
  N := 0;
  Grupo := '';
  for I := 0 to High(Props) do
  begin
    if Props[I].Grupo <> Grupo then
    begin
      Grupo := Props[I].Grupo;
      Anade(tfGrupo, UpperCase(Grupo));
    end;
    Anade(tfEtiqueta, Props[I].Etiqueta);
    Anade(tfValor, Props[I].Valor);
  end;
  if MostrarHistoria then
  begin
    Anade(tfGrupo, 'HISTORIA');
    if Length(Historia) = 0 then
    begin
      // no decir "sin eventos" cuando en realidad no se pudo leer la historia
      if MotivoHistoria <> '' then
        Anade(tfSuave, 'Historia no disponible')
      else
        Anade(tfSuave, 'Sin eventos registrados');
    end
    else
    begin
      Tope := Min(MAX_EVENTOS - 1, High(Historia));
      for I := 0 to Tope do
        Anade(tfEvento, TextoFechaEvento(Historia[I].Fecha) + '  ' +
          EtiquetaEvento(Historia[I].Tipo) + '  ' + Historia[I].Usuario);
      Anade(tfEnlace, 'Ver historia completa');
    end;
  end;
  SetLength(Lista, N);
  FFilas := Lista;
  FMensaje := False;
  FDesplazamiento := 0;
  FMidiendo := True;
  try
    Medir;
    ActualizarBarra;
  finally
    FMidiendo := False;
  end;
  Resize; // por si la barra cambio el ancho
end;

procedure TListaPropiedades.MostrarMensaje(const Texto: string);
begin
  SetLength(FFilas, 1);
  FFilas[0] := Default(TFilaProp);
  FFilas[0].Tipo := tfSuave;
  FFilas[0].Texto := Texto;
  FMensaje := True;
  FDesplazamiento := 0;
  FMidiendo := True;
  try
    Medir;
    ActualizarBarra;
  finally
    FMidiendo := False;
  end;
  Invalidate;
end;

function TListaPropiedades.AlturaContenido: Integer;
begin
  Result := FAlto;
end;

function TListaPropiedades.Contenido: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(FFilas) do
    Result := Result + FFilas[I].Texto + #10;
end;

function TListaPropiedades.RectEnlaceHistoria: TRect;
var
  I: Integer;
begin
  Result := Rect(0, 0, 0, 0);
  for I := 0 to High(FFilas) do
    if FFilas[I].Tipo = tfEnlace then
    begin
      Canvas.Lock;
      try
        ConfigurarFuente(tfEnlace);
        Result := Rect(MARGEN, FFilas[I].Y,
          MARGEN + Canvas.TextWidth(FFilas[I].Texto), FFilas[I].Y + FFilas[I].Alto);
      finally
        Canvas.Unlock;
      end;
      Exit;
    end;
end;

procedure TListaPropiedades.Paint;
var
  I: Integer;
  R: TRect;
begin
  Canvas.Brush.Color := FTema.Superficie;
  Canvas.FillRect(ClientRect);
  SetBkMode(Canvas.Handle, TRANSPARENT);
  for I := 0 to High(FFilas) do
  begin
    R := Rect(MARGEN, FFilas[I].Y - FDesplazamiento, ClientWidth - MARGEN,
      FFilas[I].Y - FDesplazamiento + FFilas[I].Alto);
    if (R.Bottom < 0) or (R.Top > ClientHeight) then
      Continue;
    ConfigurarFuente(FFilas[I].Tipo);
    DrawText(Canvas.Handle, PChar(FFilas[I].Texto), Length(FFilas[I].Texto), R,
      FlagsTexto(FFilas[I].Tipo));
  end;
end;

procedure TListaPropiedades.Desplazar(Nuevo: Integer);
begin
  Nuevo := Max(0, Min(Nuevo, Max(0, FAlto - ClientHeight)));
  if Nuevo = FDesplazamiento then
    Exit;
  FDesplazamiento := Nuevo;
  ActualizarBarra;
  Invalidate;
end;

procedure TListaPropiedades.WMVScroll(var Msg: TWMVScroll);
var
  Info: TScrollInfo;
  Nuevo: Integer;
begin
  Nuevo := FDesplazamiento;
  case Msg.ScrollCode of
    SB_LINEUP: Dec(Nuevo, 24);
    SB_LINEDOWN: Inc(Nuevo, 24);
    SB_PAGEUP: Dec(Nuevo, ClientHeight);
    SB_PAGEDOWN: Inc(Nuevo, ClientHeight);
    SB_TOP: Nuevo := 0;
    SB_BOTTOM: Nuevo := FAlto;
    SB_THUMBPOSITION, SB_THUMBTRACK:
      begin
        FillChar(Info, SizeOf(Info), 0);
        Info.cbSize := SizeOf(Info);
        Info.fMask := SIF_TRACKPOS;
        GetScrollInfo(Handle, SB_VERT, Info);
        Nuevo := Info.nTrackPos;
      end;
  end;
  Desplazar(Nuevo);
end;

function TListaPropiedades.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  Desplazar(FDesplazamiento - (WheelDelta div 120) * 48);
  Result := True;
end;

function TListaPropiedades.EnlaceEn(X, Y: Integer): Boolean;
var
  R: TRect;
begin
  R := RectEnlaceHistoria;
  Result := (R.Right > R.Left) and PtInRect(R, Point(X, Y + FDesplazamiento));
end;

procedure TListaPropiedades.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and EnlaceEn(X, Y) and Assigned(FOnVerHistoria) then
    FOnVerHistoria(Self);
end;

procedure TListaPropiedades.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if EnlaceEn(X, Y) then
    Cursor := crHandPoint
  else
    Cursor := crDefault;
end;

end.
