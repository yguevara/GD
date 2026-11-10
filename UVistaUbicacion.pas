unit UVistaUbicacion;

{ Muestra la ubicacion fisica de la subserie y del documento: un bloque por
  ubicacion, con un recuadro por tramo (servidor, archivo, deposito, gaveta,
  posicion) unidos por flechas. Un tramo sin dato dice "Sin asignar" y se
  marca como aviso. Un solo control que dibuja y mide su texto (sin controles
  hijos). Colores de UTema. Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics, UTema, UDocumentoVista;

type
  TVistaUbicacion = class(TCustomControl)
  private
    FTema: TTemaColores;
    FBloques: TArray<TUbicacion>;
    FMensaje: string;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Dibujar(Pintar: Boolean; out Alto: Integer);
  protected
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure AplicarTema(const T: TTemaColores);
    { Un bloque por ubicacion (por ejemplo Subserie y Documento). }
    procedure Mostrar(const Bloques: TArray<TUbicacion>);
    { Solo un texto guia (sin documento elegido). }
    procedure MostrarMensaje(const Texto: string);
    { Todo el texto mostrado, una fila por linea (pruebas y diagnostico). }
    function Contenido: string;
    function AlturaContenido: Integer;
  end;

implementation

uses
  System.Math, UShellPrincipal;

const
  FUENTE = 'Segoe UI';
  MARGEN = 14;
  ALTO_TRAMO = 46;
  SEPARACION = 22;

constructor TVistaUbicacion.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  if TemaWindowsOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
  Color := FTema.Superficie;
end;

procedure TVistaUbicacion.AplicarTema(const T: TTemaColores);
begin
  FTema := T;
  Color := T.Superficie;
  Invalidate;
end;

procedure TVistaUbicacion.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := 1;
end;

procedure TVistaUbicacion.Mostrar(const Bloques: TArray<TUbicacion>);
begin
  FBloques := Copy(Bloques);
  FMensaje := '';
  Invalidate;
end;

procedure TVistaUbicacion.MostrarMensaje(const Texto: string);
begin
  FBloques := nil;
  FMensaje := Texto;
  Invalidate;
end;

procedure TVistaUbicacion.Resize;
begin
  inherited Resize;
  Invalidate;
end;

function TVistaUbicacion.Contenido: string;
var
  I, J: Integer;
begin
  Result := FMensaje;
  for I := 0 to High(FBloques) do
  begin
    Result := Result + UpperCase(FBloques[I].Titulo) + #10;
    for J := 0 to High(FBloques[I].Tramos) do
      Result := Result + FBloques[I].Tramos[J].Rotulo + ': ' +
        FBloques[I].Tramos[J].Valor + #10;
    if FBloques[I].Completa then
      Result := Result + 'Ubicacion completa' + #10
    else
      Result := Result + 'Faltan datos de ubicacion' + #10;
  end;
end;

function TVistaUbicacion.AlturaContenido: Integer;
begin
  Dibujar(False, Result);
end;

procedure TVistaUbicacion.Paint;
var
  Alto: Integer;
begin
  Dibujar(True, Alto);
end;

{ Recorre los bloques: con Pintar = False solo mide. Alto es el alto total. }
procedure TVistaUbicacion.Dibujar(Pintar: Boolean; out Alto: Integer);
var
  Y, X, I, J, Ancho, AnchoMax, FaltanN: Integer;
  R: TRect;
  Rot, Val: string;
  Sin: Boolean;
begin
  if Pintar then
  begin
    Canvas.Brush.Color := FTema.Superficie;
    Canvas.FillRect(ClientRect);
    SetBkMode(Canvas.Handle, TRANSPARENT);
  end;
  Y := 14;
  AnchoMax := Max(80, ClientWidth - MARGEN);
  if FMensaje <> '' then
  begin
    if Pintar then
    begin
      Canvas.Font.Name := FUENTE;
      Canvas.Font.Size := 9;
      Canvas.Font.Style := [];
      Canvas.Font.Color := FTema.TextoSuave;
      R := Rect(MARGEN, 16, ClientWidth - MARGEN, 60);
      DrawText(Canvas.Handle, PChar(FMensaje), Length(FMensaje), R,
        DT_WORDBREAK or DT_NOPREFIX);
    end;
    Alto := 60;
    Exit;
  end;
  for I := 0 to High(FBloques) do
  begin
    // titulo del bloque
    Canvas.Font.Name := FUENTE;
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Color := FTema.Acento;
    Rot := UpperCase(FBloques[I].Titulo);
    if Pintar then
      TextOut(Canvas.Handle, MARGEN, Y, PChar(Rot), Length(Rot));
    Inc(Y, 22);
    X := MARGEN;
    FaltanN := 0;
    for J := 0 to High(FBloques[I].Tramos) do
    begin
      Rot := FBloques[I].Tramos[J].Rotulo;
      Val := FBloques[I].Tramos[J].Valor;
      Sin := Val = 'Sin asignar';
      if Sin then
        Inc(FaltanN);
      Canvas.Font.Size := 10;
      Canvas.Font.Style := [fsBold];
      Ancho := Max(Canvas.TextWidth(Val), Canvas.TextWidth(Rot)) + 24;
      if (X > MARGEN) and (X + Ancho > AnchoMax) then
      begin
        X := MARGEN;
        Inc(Y, ALTO_TRAMO + 8);
      end;
      if Pintar then
      begin
        R := Rect(X, Y, X + Ancho, Y + ALTO_TRAMO);
        if Sin then
        begin
          Canvas.Brush.Style := bsSolid;
          Canvas.Brush.Color := FTema.Superficie;
          Canvas.Pen.Color := FTema.Acento;
          Canvas.Pen.Style := psDash;
        end
        else
        begin
          Canvas.Brush.Style := bsSolid;
          Canvas.Brush.Color := FTema.AcentoSuave;
          Canvas.Pen.Color := FTema.AcentoSuave;
          Canvas.Pen.Style := psSolid;
        end;
        Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);
        Canvas.Pen.Style := psSolid;
        Canvas.Brush.Style := bsClear;
        SetBkMode(Canvas.Handle, TRANSPARENT);
        Canvas.Font.Size := 8;
        Canvas.Font.Style := [];
        Canvas.Font.Color := FTema.TextoSuave;
        TextOut(Canvas.Handle, R.Left + 12, R.Top + 5, PChar(Rot), Length(Rot));
        Canvas.Font.Size := 10;
        Canvas.Font.Style := [fsBold];
        if Sin then
          Canvas.Font.Color := FTema.Acento
        else
          Canvas.Font.Color := FTema.Texto;
        TextOut(Canvas.Handle, R.Left + 12, R.Top + 21, PChar(Val), Length(Val));
        // flecha hacia el tramo siguiente
        if J < High(FBloques[I].Tramos) then
        begin
          Canvas.Font.Size := 11;
          Canvas.Font.Style := [];
          Canvas.Font.Color := FTema.TextoSuave;
          TextOut(Canvas.Handle, R.Right + 5, R.Top + 14, '>', 1);
        end;
      end;
      Inc(X, Ancho + SEPARACION);
    end;
    Inc(Y, ALTO_TRAMO + 10);
    // estado de la ubicacion
    if Pintar then
    begin
      Canvas.Font.Size := 9;
      Canvas.Font.Style := [];
      if FBloques[I].Completa then
      begin
        Canvas.Font.Color := FTema.TextoSuave;
        Rot := 'Ubicacion completa';
      end
      else
      begin
        Canvas.Font.Color := FTema.Acento;
        if FaltanN = 1 then
          Rot := 'Falta 1 dato de ubicacion'
        else
          Rot := 'Faltan ' + IntToStr(FaltanN) + ' datos de ubicacion';
      end;
      TextOut(Canvas.Handle, MARGEN, Y, PChar(Rot), Length(Rot));
    end;
    Inc(Y, 36);
  end;
  Alto := Y;
end;

end.
