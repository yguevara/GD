unit UNumeracion;

{ ---------------------------------------------------------------------------
  Formato y lectura de los numeros de proceso. Sin VCL ni FireDAC.

    Prestamo      : AAAA-NNNN   (2026-0047, consecutivo a 4 digitos)
    Transferencia : T-AAAA-NN   (T-2026-02, consecutivo a 2 digitos)
    Depuracion    : D-AAAA-NN   (D-2026-01, consecutivo a 2 digitos)

  Si el consecutivo supera el ancho, el numero crece sin truncarse. El
  consecutivo lo asigna UProcesosDatos; esta unidad solo le da forma.
  --------------------------------------------------------------------------- }

interface

uses
  UProceso;

{ Da forma al numero de un proceso. }
function FormatearNumero(Tipo: TTipoProceso; Anio, Consecutivo: Integer): string;

{ Interpreta un numero ya formado. Devuelve False (sin lanzar) si el texto no
  tiene el formato de ningun tipo. }
function LeerNumero(const Numero: string; out Tipo: TTipoProceso;
  out Anio, Consecutivo: Integer): Boolean;

implementation

uses
  System.SysUtils;

function FormatearNumero(Tipo: TTipoProceso; Anio, Consecutivo: Integer): string;
begin
  case Tipo of
    tpPrestamo:
      Result := Format('%d-%.4d', [Anio, Consecutivo]);
    tpTransferencia:
      Result := Format('T-%d-%.2d', [Anio, Consecutivo]);
    tpDepuracion:
      Result := Format('D-%d-%.2d', [Anio, Consecutivo]);
  else
    Result := '';
  end;
end;

{ True si S son solo digitos (y no esta vacio); Valor es su numero. }
function SoloDigitos(const S: string; out Valor: Integer): Boolean;
var
  C: Char;
begin
  Result := S <> '';
  for C in S do
    if (C < '0') or (C > '9') then
      Exit(False);
  if Result then
    Result := TryStrToInt(S, Valor);
end;

function LeerNumero(const Numero: string; out Tipo: TTipoProceso;
  out Anio, Consecutivo: Integer): Boolean;
var
  Texto, TextoAnio, TextoCons: string;
  P: Integer;
begin
  Result := False;
  Tipo := tpPrestamo;
  Anio := 0;
  Consecutivo := 0;
  Texto := Trim(Numero);
  if (Length(Texto) > 2) and (Texto[2] = '-') and CharInSet(Texto[1], ['T', 'D']) then
  begin
    if Texto[1] = 'T' then
      Tipo := tpTransferencia
    else
      Tipo := tpDepuracion;
    Texto := Copy(Texto, 3, MaxInt);
  end
  else
    Tipo := tpPrestamo;
  P := Pos('-', Texto);
  if P = 0 then
    Exit;
  TextoAnio := Copy(Texto, 1, P - 1);
  TextoCons := Copy(Texto, P + 1, MaxInt);
  if Length(TextoAnio) <> 4 then
    Exit;
  Result := SoloDigitos(TextoAnio, Anio) and SoloDigitos(TextoCons, Consecutivo);
end;

end.
