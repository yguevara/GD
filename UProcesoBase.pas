unit UProcesoBase;

{ ---------------------------------------------------------------------------
  Pantalla base de los procesos archivisticos (prestamos, transferencias,
  depuracion). Sin .dfm: todo por codigo, igual que los clasificadores nuevos.

  Hereda de TFormClasificadorBase (cabecera con titulo y buscador, tabla sin
  aspecto de Excel, panel lateral con barra de acciones, embebida en el area de
  trabajo de la ventana principal) y le agrega tres franjas opcionales entre la
  cabecera y la tabla, tal como en las maquetas aprobadas
  (docs/superpowers/maquetas/2026-11-12-procesos-maqueta.html):

    - indicadores: tarjetas con una cifra (p. ej. "2 Vencidos", en rojo);
    - pestanas de estado con insignia de conteo (p. ej. "Vencidos 2");
    - tira de pasos del proceso: pasos hechos en verde, el actual resaltado y
      los pendientes en gris (la regla la define UProceso.EstadoDelPaso).

  Las franjas se dibujan sobre un TPaintBox cada una (sin controles por tarjeta)
  y quedan ocultas hasta que la pantalla hija llama a FijarIndicadores,
  FijarPestanas o FijarPasos. Colores: paleta de UTema (claro u oscuro).

  La pantalla hija implementa, como en cualquier clasificador, AlNuevo,
  AlElegirFila, AlGuardar y AlEliminar, y AlCambiarPestana para filtrar la lista.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, System.Classes, System.Types, Winapi.Windows, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.Graphics, UTema, UProceso, UClasificadorBase;

type
  { Tarjeta de la franja de indicadores. }
  TIndicador = record
    Texto: string;     // descripcion corta ("Vencidos")
    Valor: Integer;
    Alerta: Boolean;   // la cifra se muestra en rojo
  end;

  { Pestana de estado. Alerta pinta la insignia de conteo en rojo. }
  TPestana = record
    Texto: string;
    Conteo: Integer;
    Alerta: Boolean;
  end;

{ Atajos para armar los registros sin declarar variables. }
function Indicador(const ATexto: string; AValor: Integer; AAlerta: Boolean): TIndicador;
function Pestana(const ATexto: string; AConteo: Integer; AAlerta: Boolean): TPestana;

type
  TFormProcesoBase = class(TFormClasificadorBase)
  private
    FTipo: TTipoProceso;
    FZonaIndicadores, FZonaPestanas, FZonaPasos: TPanel;
    FPinturaIndicadores, FPinturaPestanas, FPinturaPasos: TPaintBox;
    FIndicadores: TArray<TIndicador>;
    FPestanas: TArray<TPestana>;
    FRectPestanas: TArray<TRect>;
    FPestanaActiva: Integer;
    FNombresPasos: TArray<string>;
    FPasoActual: Integer;
    FEstadoProceso: TEstadoProceso;
    function CrearZona(AAlto, AOrden: Integer; out APintura: TPaintBox): TPanel;
    function EsOscuro: Boolean;
    function ColorOk: TColor;
    function ColorError: TColor;
    procedure PintarIndicadores(Sender: TObject);
    procedure PintarPestanas(Sender: TObject);
    procedure PintarPasos(Sender: TObject);
    procedure PestanasMover(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PestanasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function PestanaEn(X, Y: Integer): Integer;
    procedure Fuente(ACanvas: TCanvas; AAltoPx: Integer; ANegrita: Boolean;
      AColor: TColor);
  protected
    { Crea la cabecera, la tabla y el panel lateral (ConstruirBase) y las
      franjas. Llamar una vez desde el constructor de la pantalla hija. }
    procedure ConstruirProceso(ATipo: TTipoProceso; const ATitulo, ASubtitulo,
      ATextoNuevo: string);
    { Muestra las tarjetas; una lista vacia oculta la franja. }
    procedure FijarIndicadores(const Items: array of TIndicador);
    { Muestra las pestanas con la Activa resaltada; lista vacia oculta la franja. }
    procedure FijarPestanas(const Items: array of TPestana; Activa: Integer);
    { Muestra la tira de pasos de un proceso que esta en PasoActual (1..N).
      Nombres tiene un texto por paso. }
    procedure FijarPasos(const Nombres: array of string; PasoActual: Integer;
      Estado: TEstadoProceso = epEnCurso);
    procedure OcultarPasos;
    { El usuario eligio otra pestana; la pantalla hija filtra la lista. }
    procedure AlCambiarPestana(Indice: Integer); virtual;
    property PestanaActiva: Integer read FPestanaActiva;
    property Tipo: TTipoProceso read FTipo;
  end;

implementation

function Indicador(const ATexto: string; AValor: Integer; AAlerta: Boolean): TIndicador;
begin
  Result.Texto := ATexto;
  Result.Valor := AValor;
  Result.Alerta := AAlerta;
end;

function Pestana(const ATexto: string; AConteo: Integer; AAlerta: Boolean): TPestana;
begin
  Result.Texto := ATexto;
  Result.Conteo := AConteo;
  Result.Alerta := AAlerta;
end;

{ TFormProcesoBase }

procedure TFormProcesoBase.ConstruirProceso(ATipo: TTipoProceso; const ATitulo,
  ASubtitulo, ATextoNuevo: string);
begin
  FTipo := ATipo;
  FPestanaActiva := 0;
  ConstruirBase(ATitulo, ASubtitulo, ATextoNuevo);
  // Las franjas van bajo la cabecera, en este orden
  FZonaIndicadores := CrearZona(Esc(84), 1, FPinturaIndicadores);
  FPinturaIndicadores.OnPaint := PintarIndicadores;
  FZonaPasos := CrearZona(Esc(84), 2, FPinturaPasos);
  FPinturaPasos.OnPaint := PintarPasos;
  FZonaPestanas := CrearZona(Esc(46), 3, FPinturaPestanas);
  FPinturaPestanas.OnPaint := PintarPestanas;
  FPinturaPestanas.OnMouseDown := PestanasMouseDown;
  FPinturaPestanas.OnMouseMove := PestanasMover;
end;

function TFormProcesoBase.CrearZona(AAlto, AOrden: Integer;
  out APintura: TPaintBox): TPanel;
begin
  Result := TPanel.Create(Self);
  Result.Visible := False;
  Result.Parent := Self;
  Result.Align := alTop;
  // Bajo la cabecera y por orden entre las franjas
  Result.Top := Cabecera.Top + Cabecera.Height + AOrden * 1000;
  Result.Height := AAlto;
  Result.BevelOuter := bvNone;
  Result.ParentBackground := False;
  Result.StyleElements := [];
  Result.ShowCaption := False;
  Result.Color := FTema.Fondo;
  APintura := TPaintBox.Create(Self);
  APintura.Parent := Result;
  APintura.Align := alClient;
end;

function TFormProcesoBase.EsOscuro: Boolean;
begin
  Result := RazonContraste(FTema.Fondo, clWhite) > RazonContraste(FTema.Fondo, clBlack);
end;

function TFormProcesoBase.ColorOk: TColor;
begin
  if EsOscuro then
    Result := ColorDeHex('#5fbf86')
  else
    Result := ColorDeHex('#2f7d4f');
end;

function TFormProcesoBase.ColorError: TColor;
begin
  if EsOscuro then
    Result := ColorDeHex('#f2766c')
  else
    Result := ColorDeHex('#b3261e');
end;

procedure TFormProcesoBase.Fuente(ACanvas: TCanvas; AAltoPx: Integer;
  ANegrita: Boolean; AColor: TColor);
begin
  ACanvas.Font.Name := 'Segoe UI';
  ACanvas.Font.Height := -AAltoPx;
  if ANegrita then
    ACanvas.Font.Style := [fsBold]
  else
    ACanvas.Font.Style := [];
  ACanvas.Font.Color := AColor;
  ACanvas.Brush.Style := bsClear;
end;

{ ------------------------------ indicadores ------------------------------ }

procedure TFormProcesoBase.FijarIndicadores(const Items: array of TIndicador);
var
  I: Integer;
begin
  SetLength(FIndicadores, Length(Items));
  for I := 0 to High(Items) do
    FIndicadores[I] := Items[I];
  FZonaIndicadores.Visible := Length(FIndicadores) > 0;
  FPinturaIndicadores.Invalidate;
end;

procedure TFormProcesoBase.PintarIndicadores(Sender: TObject);
var
  C: TCanvas;
  I, N, X, Ancho, Hueco, Alto, Y: Integer;
  R: TRect;
  Cifra: string;
begin
  C := FPinturaIndicadores.Canvas;
  C.Brush.Color := FTema.Fondo;
  C.Brush.Style := bsSolid;
  C.FillRect(FPinturaIndicadores.ClientRect);
  N := Length(FIndicadores);
  if N = 0 then
    Exit;
  Hueco := Esc(10);
  Y := Esc(12);
  Alto := FPinturaIndicadores.Height - Y;
  X := Esc(16);
  Ancho := (FPinturaIndicadores.Width - Esc(32) - Hueco * (N - 1)) div N;
  for I := 0 to N - 1 do
  begin
    R := Rect(X, Y, X + Ancho, Y + Alto);
    C.Brush.Style := bsSolid;
    C.Brush.Color := FTema.Superficie;
    C.Pen.Color := FTema.Linea;
    C.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Esc(8), Esc(8));
    Cifra := IntToStr(FIndicadores[I].Valor);
    if FIndicadores[I].Alerta and (FIndicadores[I].Valor > 0) then
      Fuente(C, 24, True, ColorError)
    else
      Fuente(C, 24, True, FTema.Texto);
    C.TextOut(R.Left + Esc(14), R.Top + Esc(6), Cifra);
    Fuente(C, 12, False, FTema.TextoSuave);
    C.TextOut(R.Left + Esc(14), R.Bottom - Esc(26), FIndicadores[I].Texto);
    X := X + Ancho + Hueco;
  end;
end;

{ ------------------------------- pestanas -------------------------------- }

procedure TFormProcesoBase.FijarPestanas(const Items: array of TPestana;
  Activa: Integer);
var
  I: Integer;
begin
  SetLength(FPestanas, Length(Items));
  for I := 0 to High(Items) do
    FPestanas[I] := Items[I];
  if (Activa < 0) or (Activa > High(FPestanas)) then
    Activa := 0;
  FPestanaActiva := Activa;
  FZonaPestanas.Visible := Length(FPestanas) > 0;
  FPinturaPestanas.Invalidate;
end;

procedure TFormProcesoBase.PintarPestanas(Sender: TObject);
var
  C: TCanvas;
  I, X, Ancho, AnchoInsignia, Base: Integer;
  Activa: Boolean;
  Texto: string;
  R, RI: TRect;
begin
  C := FPinturaPestanas.Canvas;
  C.Brush.Color := FTema.Superficie;
  C.Brush.Style := bsSolid;
  C.FillRect(FPinturaPestanas.ClientRect);
  // linea inferior de toda la franja
  C.Pen.Color := FTema.Linea;
  Base := FPinturaPestanas.Height - 1;
  C.MoveTo(0, Base);
  C.LineTo(FPinturaPestanas.Width, Base);
  SetLength(FRectPestanas, Length(FPestanas));
  X := Esc(16);
  for I := 0 to High(FPestanas) do
  begin
    Activa := I = FPestanaActiva;
    Texto := FPestanas[I].Texto;
    if Activa then
      Fuente(C, 13, True, FTema.Acento)
    else
      Fuente(C, 13, False, FTema.TextoSuave);
    Ancho := C.TextWidth(Texto);
    AnchoInsignia := 0;
    if FPestanas[I].Conteo > 0 then
      AnchoInsignia := Esc(30);
    R := Rect(X, 0, X + Esc(14) + Ancho + AnchoInsignia + Esc(14), FPinturaPestanas.Height);
    FRectPestanas[I] := R;
    C.Brush.Style := bsClear;
    C.TextOut(R.Left + Esc(14), (R.Bottom - C.TextHeight(Texto)) div 2, Texto);
    if FPestanas[I].Conteo > 0 then
    begin
      RI := Rect(R.Left + Esc(14) + Ancho + Esc(6), (R.Bottom - Esc(18)) div 2,
        R.Left + Esc(14) + Ancho + Esc(6) + Esc(24), (R.Bottom + Esc(18)) div 2);
      C.Brush.Style := bsSolid;
      if FPestanas[I].Alerta then
      begin
        C.Brush.Color := ColorError;
        C.Pen.Color := ColorError;
      end
      else
      begin
        C.Brush.Color := FTema.Superficie2;
        C.Pen.Color := FTema.Linea;
      end;
      C.RoundRect(RI.Left, RI.Top, RI.Right, RI.Bottom, Esc(18), Esc(18));
      if FPestanas[I].Alerta then
        Fuente(C, 11, True, clWhite)
      else
        Fuente(C, 11, True, FTema.TextoSuave);
      Texto := IntToStr(FPestanas[I].Conteo);
      C.TextOut(RI.Left + (RI.Right - RI.Left - C.TextWidth(Texto)) div 2,
        RI.Top + (RI.Bottom - RI.Top - C.TextHeight(Texto)) div 2, Texto);
    end;
    if Activa then
    begin
      C.Brush.Style := bsSolid;
      C.Brush.Color := FTema.Acento;
      C.FillRect(Rect(R.Left + Esc(6), R.Bottom - Esc(3), R.Right - Esc(6), R.Bottom));
    end;
    X := R.Right + Esc(4);
  end;
end;

function TFormProcesoBase.PestanaEn(X, Y: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FRectPestanas) do
    if PtInRect(FRectPestanas[I], Point(X, Y)) then
      Exit(I);
end;

procedure TFormProcesoBase.PestanasMover(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if PestanaEn(X, Y) >= 0 then
    FPinturaPestanas.Cursor := crHandPoint
  else
    FPinturaPestanas.Cursor := crDefault;
end;

procedure TFormProcesoBase.PestanasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  if Button <> mbLeft then
    Exit;
  I := PestanaEn(X, Y);
  if (I < 0) or (I = FPestanaActiva) then
    Exit;
  FPestanaActiva := I;
  FPinturaPestanas.Invalidate;
  AlCambiarPestana(I);
end;

procedure TFormProcesoBase.AlCambiarPestana(Indice: Integer);
begin
  // Por defecto no filtra nada: la pantalla hija decide.
end;

{ --------------------------------- pasos --------------------------------- }

procedure TFormProcesoBase.FijarPasos(const Nombres: array of string;
  PasoActual: Integer; Estado: TEstadoProceso);
var
  I: Integer;
begin
  SetLength(FNombresPasos, Length(Nombres));
  for I := 0 to High(Nombres) do
    FNombresPasos[I] := Nombres[I];
  FPasoActual := PasoActual;
  FEstadoProceso := Estado;
  FZonaPasos.Visible := Length(FNombresPasos) > 0;
  FPinturaPasos.Invalidate;
end;

procedure TFormProcesoBase.OcultarPasos;
begin
  SetLength(FNombresPasos, 0);
  FZonaPasos.Visible := False;
end;

procedure TFormProcesoBase.PintarPasos(Sender: TObject);
var
  C: TCanvas;
  I, N, CentroX, CentroY, Radio, Ancho, XAnt: Integer;
  Est: TEstadoPaso;
  Etiqueta: string;
begin
  C := FPinturaPasos.Canvas;
  C.Brush.Color := FTema.Superficie;
  C.Brush.Style := bsSolid;
  C.FillRect(FPinturaPasos.ClientRect);
  C.Pen.Color := FTema.Linea;
  C.MoveTo(0, FPinturaPasos.Height - 1);
  C.LineTo(FPinturaPasos.Width, FPinturaPasos.Height - 1);
  N := Length(FNombresPasos);
  if N = 0 then
    Exit;
  Radio := Esc(14);
  CentroY := Esc(26);
  Ancho := FPinturaPasos.Width div N;
  XAnt := 0;
  for I := 0 to N - 1 do
  begin
    CentroX := Ancho * I + Ancho div 2;
    Est := EstadoDelPaso(FTipo, FPasoActual, FEstadoProceso, I + 1);
    // conector con el paso anterior: verde si ese paso ya esta hecho
    if I > 0 then
    begin
      if EstadoDelPaso(FTipo, FPasoActual, FEstadoProceso, I) = psHecho then
        C.Pen.Color := ColorOk
      else
        C.Pen.Color := FTema.Linea;
      C.Pen.Width := Esc(2);
      C.MoveTo(XAnt + Radio, CentroY);
      C.LineTo(CentroX - Radio, CentroY);
      C.Pen.Width := 1;
    end;
    XAnt := CentroX;
    // circulo
    C.Brush.Style := bsSolid;
    case Est of
      psHecho:
        begin
          C.Brush.Color := ColorOk;
          C.Pen.Color := ColorOk;
        end;
      psActual:
        begin
          C.Brush.Color := FTema.Acento;
          C.Pen.Color := FTema.Acento;
        end;
    else
      C.Brush.Color := FTema.Superficie2;
      C.Pen.Color := FTema.Linea;
    end;
    C.Ellipse(CentroX - Radio, CentroY - Radio, CentroX + Radio, CentroY + Radio);
    // contenido del circulo: marca de verificado o numero
    if Est = psHecho then
    begin
      C.Font.Name := 'Segoe UI Symbol';
      C.Font.Height := -Esc(14);
      C.Font.Style := [fsBold];
      C.Font.Color := clWhite;
      Etiqueta := #$2713;
    end
    else
    begin
      if Est = psActual then
        Fuente(C, 13, True, clWhite)
      else
        Fuente(C, 13, True, FTema.TextoSuave);
      Etiqueta := IntToStr(I + 1);
    end;
    C.Brush.Style := bsClear;
    C.TextOut(CentroX - C.TextWidth(Etiqueta) div 2,
      CentroY - C.TextHeight(Etiqueta) div 2, Etiqueta);
    // nombre del paso
    case Est of
      psHecho: Fuente(C, 12, False, ColorOk);
      psActual: Fuente(C, 12, True, FTema.Acento);
    else
      Fuente(C, 12, False, FTema.TextoSuave);
    end;
    Etiqueta := FNombresPasos[I];
    C.TextOut(CentroX - C.TextWidth(Etiqueta) div 2, CentroY + Radio + Esc(6), Etiqueta);
  end;
end;

end.
