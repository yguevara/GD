unit UProcesoPintura;

{ ---------------------------------------------------------------------------
  Pintado de las tres franjas de las pantallas de procesos archivisticos
  (prestamos, transferencias, depuracion), segun las maquetas aprobadas:

    - tarjetas con una cifra ("2 Vencidos", la cifra en rojo si hay alerta);
    - pestanas de estado con insignia de conteo;
    - tira de pasos del proceso (hecho en verde, actual resaltado, pendiente en
      gris; el estado de cada paso lo decide UProceso.EstadoDelPaso).

  Solo dibuja sobre un TCanvas dentro de un area dada: no crea controles, asi la
  pantalla (que tiene su .dfm) pone un TPaintBox por franja y en su OnPaint llama
  a estas rutinas. Los colores salen de la paleta de UTema; el DPI se pasa como
  parametro para escalar. Sin dependencias de formularios.
  --------------------------------------------------------------------------- }

interface

uses
  System.Types, Vcl.Graphics, UTema, UProceso;

type
  TIndicadorTarjeta = record
    Texto: string;      // descripcion corta ("Vencidos")
    Valor: Integer;
    Alerta: Boolean;    // la cifra se muestra en rojo si Valor > 0
  end;

  TPestanaVista = record
    Texto: string;
    Conteo: Integer;    // 0 = sin insignia
    Alerta: Boolean;    // insignia en rojo
  end;

{ Atajos para armar los registros sin declarar variables. }
function Indicador(const ATexto: string; AValor: Integer;
  AAlerta: Boolean): TIndicadorTarjeta;
function Pestana(const ATexto: string; AConteo: Integer;
  AAlerta: Boolean): TPestanaVista;

{ Verde y rojo de estado, mas claros en el tema oscuro. }
function ColorOk(const T: TTemaColores): TColor;
function ColorError(const T: TTemaColores): TColor;

procedure PintarTarjetas(C: TCanvas; const Area: TRect;
  const Items: array of TIndicadorTarjeta; const T: TTemaColores; Ppi: Integer);

{ Calcula el rectangulo de cada pestana (para pintarlas y para saber donde se
  hizo clic). Alto es la altura en pixeles de la franja. }
function DisenarPestanas(C: TCanvas; const Items: array of TPestanaVista;
  Alto, Ppi: Integer): TArray<TRect>;

procedure PintarPestanas(C: TCanvas; const Area: TRect;
  const Items: array of TPestanaVista; const Rects: TArray<TRect>; Activa: Integer;
  const T: TTemaColores; Ppi: Integer);

{ Indice de la pestana bajo el punto, o -1. }
function PestanaEn(const Rects: TArray<TRect>; X, Y: Integer): Integer;

procedure PintarPasos(C: TCanvas; const Area: TRect; Tipo: TTipoProceso;
  const Nombres: array of string; PasoActual: Integer; Estado: TEstadoProceso;
  const T: TTemaColores; Ppi: Integer);

implementation

uses
  System.SysUtils, Winapi.Windows;

function Indicador(const ATexto: string; AValor: Integer;
  AAlerta: Boolean): TIndicadorTarjeta;
begin
  Result.Texto := ATexto;
  Result.Valor := AValor;
  Result.Alerta := AAlerta;
end;

function Pestana(const ATexto: string; AConteo: Integer;
  AAlerta: Boolean): TPestanaVista;
begin
  Result.Texto := ATexto;
  Result.Conteo := AConteo;
  Result.Alerta := AAlerta;
end;

function EsOscuro(const T: TTemaColores): Boolean;
begin
  Result := RazonContraste(T.Fondo, clWhite) > RazonContraste(T.Fondo, clBlack);
end;

function ColorOk(const T: TTemaColores): TColor;
begin
  if EsOscuro(T) then
    Result := ColorDeHex('#5fbf86')
  else
    Result := ColorDeHex('#2f7d4f');
end;

function ColorError(const T: TTemaColores): TColor;
begin
  if EsOscuro(T) then
    Result := ColorDeHex('#f2766c')
  else
    Result := ColorDeHex('#b3261e');
end;

function Esc(Valor, Ppi: Integer): Integer;
begin
  Result := MulDiv(Valor, Ppi, 96);
end;

procedure Fuente(C: TCanvas; AAltoPx: Integer; ANegrita: Boolean; AColor: TColor;
  Ppi: Integer);
begin
  C.Font.Name := 'Segoe UI';
  C.Font.Height := -Esc(AAltoPx, Ppi);
  if ANegrita then
    C.Font.Style := [fsBold]
  else
    C.Font.Style := [];
  C.Font.Color := AColor;
  C.Brush.Style := bsClear;
end;

{ -------------------------------- tarjetas ------------------------------- }

procedure PintarTarjetas(C: TCanvas; const Area: TRect;
  const Items: array of TIndicadorTarjeta; const T: TTemaColores; Ppi: Integer);
var
  I, N, X, Ancho, Hueco, Alto, Y: Integer;
  R: TRect;
begin
  C.Brush.Color := T.Fondo;
  C.Brush.Style := bsSolid;
  C.FillRect(Area);
  N := Length(Items);
  if N = 0 then
    Exit;
  Hueco := Esc(10, Ppi);
  Y := Area.Top + Esc(12, Ppi);
  Alto := Area.Bottom - Y;
  X := Area.Left + Esc(16, Ppi);
  Ancho := (Area.Right - Area.Left - Esc(32, Ppi) - Hueco * (N - 1)) div N;
  for I := 0 to N - 1 do
  begin
    R := Rect(X, Y, X + Ancho, Y + Alto);
    C.Brush.Style := bsSolid;
    C.Brush.Color := T.Superficie;
    C.Pen.Color := T.Linea;
    C.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Esc(8, Ppi), Esc(8, Ppi));
    if Items[I].Alerta and (Items[I].Valor > 0) then
      Fuente(C, 24, True, ColorError(T), Ppi)
    else
      Fuente(C, 24, True, T.Texto, Ppi);
    C.TextOut(R.Left + Esc(14, Ppi), R.Top + Esc(6, Ppi), IntToStr(Items[I].Valor));
    Fuente(C, 12, False, T.TextoSuave, Ppi);
    C.TextOut(R.Left + Esc(14, Ppi), R.Bottom - Esc(26, Ppi), Items[I].Texto);
    X := X + Ancho + Hueco;
  end;
end;

{ -------------------------------- pestanas ------------------------------- }

function DisenarPestanas(C: TCanvas; const Items: array of TPestanaVista;
  Alto, Ppi: Integer): TArray<TRect>;
var
  I, X, Ancho, Insignia: Integer;
begin
  SetLength(Result, Length(Items));
  // se mide en negrita: la pestana activa es la mas ancha y no debe saltar
  Fuente(C, 13, True, clBlack, Ppi);
  X := Esc(16, Ppi);
  for I := 0 to High(Items) do
  begin
    Ancho := C.TextWidth(Items[I].Texto);
    if Items[I].Conteo > 0 then
      Insignia := Esc(30, Ppi)
    else
      Insignia := 0;
    Result[I] := Rect(X, 0, X + Esc(14, Ppi) + Ancho + Insignia + Esc(14, Ppi), Alto);
    X := Result[I].Right + Esc(4, Ppi);
  end;
end;

function PestanaEn(const Rects: TArray<TRect>; X, Y: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(Rects) do
    if PtInRect(Rects[I], Point(X, Y)) then
      Exit(I);
end;

procedure PintarPestanas(C: TCanvas; const Area: TRect;
  const Items: array of TPestanaVista; const Rects: TArray<TRect>; Activa: Integer;
  const T: TTemaColores; Ppi: Integer);
var
  I, Ancho: Integer;
  R, RI: TRect;
  Texto: string;
begin
  C.Brush.Color := T.Superficie;
  C.Brush.Style := bsSolid;
  C.FillRect(Area);
  // linea inferior de toda la franja
  C.Pen.Color := T.Linea;
  C.MoveTo(Area.Left, Area.Bottom - 1);
  C.LineTo(Area.Right, Area.Bottom - 1);
  for I := 0 to High(Items) do
  begin
    if I > High(Rects) then
      Break;
    R := Rects[I];
    OffsetRect(R, Area.Left, Area.Top);
    if I = Activa then
      Fuente(C, 13, True, T.Acento, Ppi)
    else
      Fuente(C, 13, False, T.TextoSuave, Ppi);
    Texto := Items[I].Texto;
    Ancho := C.TextWidth(Texto);
    C.TextOut(R.Left + Esc(14, Ppi), R.Top + (R.Bottom - R.Top - C.TextHeight(Texto)) div 2,
      Texto);
    if Items[I].Conteo > 0 then
    begin
      RI := Rect(R.Left + Esc(14, Ppi) + Ancho + Esc(6, Ppi),
        R.Top + (R.Bottom - R.Top - Esc(18, Ppi)) div 2,
        R.Left + Esc(14, Ppi) + Ancho + Esc(6, Ppi) + Esc(24, Ppi),
        R.Top + (R.Bottom - R.Top + Esc(18, Ppi)) div 2);
      C.Brush.Style := bsSolid;
      if Items[I].Alerta then
      begin
        C.Brush.Color := ColorError(T);
        C.Pen.Color := ColorError(T);
      end
      else
      begin
        C.Brush.Color := T.Superficie2;
        C.Pen.Color := T.Linea;
      end;
      C.RoundRect(RI.Left, RI.Top, RI.Right, RI.Bottom, Esc(18, Ppi), Esc(18, Ppi));
      if Items[I].Alerta then
        Fuente(C, 11, True, clWhite, Ppi)
      else
        Fuente(C, 11, True, T.TextoSuave, Ppi);
      Texto := IntToStr(Items[I].Conteo);
      C.TextOut(RI.Left + (RI.Right - RI.Left - C.TextWidth(Texto)) div 2,
        RI.Top + (RI.Bottom - RI.Top - C.TextHeight(Texto)) div 2, Texto);
    end;
    if I = Activa then
    begin
      C.Brush.Style := bsSolid;
      C.Brush.Color := T.Acento;
      C.FillRect(Rect(R.Left + Esc(6, Ppi), R.Bottom - Esc(3, Ppi),
        R.Right - Esc(6, Ppi), R.Bottom));
    end;
  end;
end;

{ --------------------------------- pasos --------------------------------- }

procedure PintarPasos(C: TCanvas; const Area: TRect; Tipo: TTipoProceso;
  const Nombres: array of string; PasoActual: Integer; Estado: TEstadoProceso;
  const T: TTemaColores; Ppi: Integer);
var
  I, N, CentroX, CentroY, Radio, Ancho, XAnt: Integer;
  Est: TEstadoPaso;
  Etiqueta: string;
begin
  C.Brush.Color := T.Superficie;
  C.Brush.Style := bsSolid;
  C.FillRect(Area);
  C.Pen.Color := T.Linea;
  C.MoveTo(Area.Left, Area.Bottom - 1);
  C.LineTo(Area.Right, Area.Bottom - 1);
  N := Length(Nombres);
  if N = 0 then
    Exit;
  Radio := Esc(14, Ppi);
  CentroY := Area.Top + Esc(26, Ppi);
  Ancho := (Area.Right - Area.Left) div N;
  XAnt := 0;
  for I := 0 to N - 1 do
  begin
    CentroX := Area.Left + Ancho * I + Ancho div 2;
    Est := EstadoDelPaso(Tipo, PasoActual, Estado, I + 1);
    // conector con el paso anterior: verde si ese paso ya esta hecho
    if I > 0 then
    begin
      if EstadoDelPaso(Tipo, PasoActual, Estado, I) = psHecho then
        C.Pen.Color := ColorOk(T)
      else
        C.Pen.Color := T.Linea;
      C.Pen.Width := Esc(2, Ppi);
      C.MoveTo(XAnt + Radio, CentroY);
      C.LineTo(CentroX - Radio, CentroY);
      C.Pen.Width := 1;
    end;
    XAnt := CentroX;
    C.Brush.Style := bsSolid;
    case Est of
      psHecho:
        begin
          C.Brush.Color := ColorOk(T);
          C.Pen.Color := ColorOk(T);
        end;
      psActual:
        begin
          C.Brush.Color := T.Acento;
          C.Pen.Color := T.Acento;
        end;
    else
      C.Brush.Color := T.Superficie2;
      C.Pen.Color := T.Linea;
    end;
    C.Ellipse(CentroX - Radio, CentroY - Radio, CentroX + Radio, CentroY + Radio);
    if Est = psHecho then
    begin
      C.Font.Name := 'Segoe UI Symbol';
      C.Font.Height := -Esc(14, Ppi);
      C.Font.Style := [fsBold];
      C.Font.Color := clWhite;
      Etiqueta := #$2713;
    end
    else
    begin
      if Est = psActual then
        Fuente(C, 13, True, clWhite, Ppi)
      else
        Fuente(C, 13, True, T.TextoSuave, Ppi);
      Etiqueta := IntToStr(I + 1);
    end;
    C.Brush.Style := bsClear;
    C.TextOut(CentroX - C.TextWidth(Etiqueta) div 2,
      CentroY - C.TextHeight(Etiqueta) div 2, Etiqueta);
    case Est of
      psHecho: Fuente(C, 12, False, ColorOk(T), Ppi);
      psActual: Fuente(C, 12, True, T.Acento, Ppi);
    else
      Fuente(C, 12, False, T.TextoSuave, Ppi);
    end;
    Etiqueta := Nombres[I];
    C.TextOut(CentroX - C.TextWidth(Etiqueta) div 2, CentroY + Radio + Esc(6, Ppi), Etiqueta);
  end;
end;

end.
