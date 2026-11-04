unit UTema;

{ Sistema de diseno de ArchiGenio: paleta de colores de los temas claro y
  oscuro (valores de la maqueta aprobada) y utilidades de color.
  No depende de formularios ni de controles VCL: solo System.UITypes. }

interface

uses
  System.UITypes;

type
  TTemaColores = record
    Fondo: TColor;
    Superficie: TColor;
    Superficie2: TColor;
    Texto: TColor;
    TextoSuave: TColor;
    Linea: TColor;
    Acento: TColor;
    TextoSobreAcento: TColor;
    AcentoSuave: TColor;
    Aviso: TColor;
  end;

function TemaClaro: TTemaColores;
function TemaOscuro: TTemaColores;

{ Convierte '#rrggbb' en TColor (BGR). Lanza EArgumentException si no es valido. }
function ColorDeHex(const Hex: string): TColor;

{ Razon de contraste WCAG entre dos colores (1 a 21). }
function RazonContraste(A, B: TColor): Double;

implementation

uses
  System.SysUtils, System.Math;

function ColorDeHex(const Hex: string): TColor;
var
  I, V, Dig: Integer;
  C: Char;
begin
  if (Length(Hex) <> 7) or (Hex[1] <> '#') then
    raise EArgumentException.CreateFmt('Color hexadecimal no valido: "%s"', [Hex]);
  V := 0;
  for I := 2 to 7 do
  begin
    C := Hex[I];
    case C of
      '0'..'9': Dig := Ord(C) - Ord('0');
      'a'..'f': Dig := Ord(C) - Ord('a') + 10;
      'A'..'F': Dig := Ord(C) - Ord('A') + 10;
    else
      raise EArgumentException.CreateFmt('Color hexadecimal no valido: "%s"', [Hex]);
    end;
    V := (V shl 4) or Dig;
  end;
  // V = $RRGGBB; TColor es $00BBGGRR
  Result := TColor(((V and $FF) shl 16) or (V and $FF00) or ((V shr 16) and $FF));
end;

function LuminanciaCanal(Valor: Integer): Double;
var
  S: Double;
begin
  S := Valor / 255;
  if S <= 0.03928 then
    Result := S / 12.92
  else
    Result := Power((S + 0.055) / 1.055, 2.4);
end;

function Luminancia(C: TColor): Double;
var
  N: Integer;
begin
  N := Integer(C);
  Result := 0.2126 * LuminanciaCanal(N and $FF)
          + 0.7152 * LuminanciaCanal((N shr 8) and $FF)
          + 0.0722 * LuminanciaCanal((N shr 16) and $FF);
end;

function RazonContraste(A, B: TColor): Double;
var
  LA, LB, T: Double;
begin
  LA := Luminancia(A);
  LB := Luminancia(B);
  if LA < LB then
  begin
    T := LA;
    LA := LB;
    LB := T;
  end;
  Result := (LA + 0.05) / (LB + 0.05);
end;

function TemaClaro: TTemaColores;
begin
  // Fondo, Superficie, Texto y Acento vienen de la maqueta; los demas tokens
  // son derivados de la misma familia (no fijados por la maqueta).
  Result.Fondo := ColorDeHex('#e9edf1');
  Result.Superficie := ColorDeHex('#ffffff');
  Result.Superficie2 := ColorDeHex('#f4f6f8');
  Result.Texto := ColorDeHex('#1b2733');
  Result.TextoSuave := ColorDeHex('#566574');
  Result.Linea := ColorDeHex('#d3dae1');
  Result.Acento := ColorDeHex('#1d5fa6');
  Result.TextoSobreAcento := ColorDeHex('#ffffff');
  Result.AcentoSuave := ColorDeHex('#dce9f7');
  Result.Aviso := ColorDeHex('#b3501a');
end;

function TemaOscuro: TTemaColores;
begin
  Result.Fondo := ColorDeHex('#12181e');
  Result.Superficie := ColorDeHex('#1a232c');
  Result.Superficie2 := ColorDeHex('#222d38');
  Result.Texto := ColorDeHex('#e5ebf1');
  Result.TextoSuave := ColorDeHex('#9aa9b8');
  Result.Linea := ColorDeHex('#2e3b48');
  Result.Acento := ColorDeHex('#6aa8ea');
  Result.TextoSobreAcento := ColorDeHex('#0d1620');
  Result.AcentoSuave := ColorDeHex('#1f3550');
  Result.Aviso := ColorDeHex('#e0904f');
end;

end.
