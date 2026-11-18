unit UDepuracionReglas;

{ ---------------------------------------------------------------------------
  Reglas puras de la depuracion (eliminacion de documentos, F4): plazo en el
  archivo central, numero de unidades en letras, validacion del acta, la
  muestra y los testigos, palabra de confirmacion y textos de estado.
  Sin VCL ni FireDAC: se prueban desde la consola.
  Diseno: docs/superpowers/specs/2026-11-18-depuracion-f4-design.md.
  --------------------------------------------------------------------------- }

interface

uses
  UProceso, UAutorizacion;

type
  { Como se eliminan fisicamente los documentos. Codigos 'I' y 'T'. }
  TViaEliminacion = (veIncineracion, veTrituracion);

  { De donde viene un testigo del acta. Codigos 'C', 'G' y 'O'. }
  TOrigenTestigo = (otComision, otArchivoGestion, otOtro);

  TTestigoDatos = record
    Nombre, Cargo: string;
    Origen: TOrigenTestigo;
  end;

const
  MINIMO_TESTIGOS = 2;
  PALABRA_CONFIRMACION = 'ELIMINAR';

function CodigoVia(V: TViaEliminacion): string;
{ Lanza EArgumentException con un codigo desconocido. }
function ViaDesdeCodigo(const Codigo: string): TViaEliminacion;
function TextoVia(V: TViaEliminacion): string;
function CodigoOrigenTestigo(O: TOrigenTestigo): string;
{ Lanza EArgumentException con un codigo desconocido. }
function OrigenTestigoDesdeCodigo(const Codigo: string): TOrigenTestigo;

{ True si el documento ya cumplio su plazo en el archivo central.
  Con HayCierre (el documento llego por una transferencia finalizada, cuyo cierre
  es Cierre) cuenta Cierre + AniosCentral. Sin cierre (ya estaba en el central
  antes del sistema) cuenta FechaBase + AniosGestion + AniosCentral, con
  FechaBase = FechaFin si existe y no es anterior a Fecha, y Fecha si no.
  AniosCentral <= 0 nunca vence; sin Fecha tampoco (sin cierre). }
function PlazoCentralVencido(Hoy: TDateTime; HayCierre: Boolean; Cierre, Fecha,
  FechaFin: TDateTime; HayFechaFin: Boolean; AniosGestion,
  AniosCentral: Integer): Boolean;

{ Numero de unidades en letras, en femenino ("mil doscientas cuarenta"). De 0 a
  999 999 999; fuera de rango lanza EArgumentException. Sin acentos. }
function UnidadesEnLetras(N: Int64): string;

{ "1 240 (mil doscientas cuarenta)": el numero con espacio como separador de miles y
  sus letras en femenino. Lanza EArgumentException fuera de rango. }
function UnidadesNumerosYLetras(N: Int64): string;

{ "01/2008 - 12/2012"; un solo mes y ano si coinciden ("03/2010"); Desde = 0 => ''; sin
  Hasta solo el mes de Desde. }
function RangoMesAnio(Desde, Hasta: TDateTime): string;

{ "Comision Prov. - Acta 14 - Acuerdo 9" para la columna de autorizacion de la lista. }
function TextoAutorizacionCorto(const A: TAutorizacion): string;

{ Hay al menos MINIMO_TESTIGOS, uno de la Comision y uno de un archivo de
  gestion. }
function TestigosSuficientes(const T: array of TTestigoDatos): Boolean;

{ Errores (vacia si es valido): nombre obligatorio (hasta 100) y cargo opcional
  (hasta 100). }
function ValidarTestigo(const T: TTestigoDatos): TArray<string>;

{ Errores (vacia si es valida): lugar obligatorio (hasta 255) y fecha prevista. }
function ValidarActaDepuracion(const Lugar: string; FPrevista: TDateTime): TArray<string>;

{ Errores (vacia si es valida): la muestra que se conserva exige descripcion y
  donde queda (hasta 255 cada una). }
function ValidarMuestra(const Descripcion, Donde: string): TArray<string>;

{ Solo la palabra exacta ELIMINAR (en mayusculas, con o sin espacios alrededor). }
function ConfirmacionEscritaValida(const Texto: string): Boolean;

{ Texto del estado de una depuracion para la lista. }
function TextoEstadoDepuracion(Paso: Integer; Estado: TEstadoProceso): string;

{ Una frase por cada condicion de depuracion que falta. }
function TextosQueFaltanDepuracion(Faltan: TCondiciones): TArray<string>;

implementation

uses
  System.SysUtils, System.DateUtils;

function CodigoVia(V: TViaEliminacion): string;
begin
  if V = veTrituracion then
    Result := 'T'
  else
    Result := 'I';
end;

function ViaDesdeCodigo(const Codigo: string): TViaEliminacion;
begin
  if Trim(Codigo) = 'I' then
    Result := veIncineracion
  else if Trim(Codigo) = 'T' then
    Result := veTrituracion
  else
    raise EArgumentException.Create('Via de eliminacion desconocida: ' + Codigo);
end;

function TextoVia(V: TViaEliminacion): string;
begin
  if V = veTrituracion then
    Result := 'Trituracion'
  else
    Result := 'Incineracion';
end;

function CodigoOrigenTestigo(O: TOrigenTestigo): string;
begin
  case O of
    otComision: Result := 'C';
    otArchivoGestion: Result := 'G';
  else
    Result := 'O';
  end;
end;

function OrigenTestigoDesdeCodigo(const Codigo: string): TOrigenTestigo;
begin
  if Trim(Codigo) = 'C' then
    Result := otComision
  else if Trim(Codigo) = 'G' then
    Result := otArchivoGestion
  else if Trim(Codigo) = 'O' then
    Result := otOtro
  else
    raise EArgumentException.Create('Origen de testigo desconocido: ' + Codigo);
end;

function PlazoCentralVencido(Hoy: TDateTime; HayCierre: Boolean; Cierre, Fecha,
  FechaFin: TDateTime; HayFechaFin: Boolean; AniosGestion,
  AniosCentral: Integer): Boolean;
var
  Base: TDateTime;
begin
  if AniosCentral <= 0 then
    Exit(False);
  if HayCierre then
    Exit(Trunc(IncYear(Trunc(Cierre), AniosCentral)) <= Trunc(Hoy));
  if Fecha = 0 then
    Exit(False);
  if AniosGestion < 0 then
    AniosGestion := 0;
  Base := Fecha;
  if HayFechaFin and (FechaFin >= Fecha) then
    Base := FechaFin;
  Result := Trunc(IncYear(Trunc(Base), AniosGestion + AniosCentral)) <= Trunc(Hoy);
end;

{ ------------------------------ numero en letras ------------------------------ }

type
  { Femenino: "una", "doscientas". Apocope: "un" con centenas femeninas ("doscientas
    mil", "veintiun mil"). Masculino: "un", "doscientos" ("doscientos millones"). }
  TModoLetras = (mlFemenino, mlApocope, mlMasculino);

const
  UNIDADES: array[1..29] of string = ('un', 'dos', 'tres', 'cuatro', 'cinco', 'seis',
    'siete', 'ocho', 'nueve', 'diez', 'once', 'doce', 'trece', 'catorce', 'quince',
    'dieciseis', 'diecisiete', 'dieciocho', 'diecinueve', 'veinte', 'veintiun',
    'veintidos', 'veintitres', 'veinticuatro', 'veinticinco', 'veintiseis',
    'veintisiete', 'veintiocho', 'veintinueve');
  DECENAS: array[3..9] of string = ('treinta', 'cuarenta', 'cincuenta', 'sesenta',
    'setenta', 'ochenta', 'noventa');
  CENTENAS: array[1..9] of string = ('ciento', 'doscientos', 'trescientos',
    'cuatrocientos', 'quinientos', 'seiscientos', 'setecientos', 'ochocientos',
    'novecientos');

function Unidad(R: Integer; Modo: TModoLetras): string;
begin
  Result := UNIDADES[R];
  if Modo = mlFemenino then
    if R = 1 then
      Result := 'una'
    else if R = 21 then
      Result := 'veintiuna';
end;

function Menos100(R: Integer; Modo: TModoLetras): string;
begin
  if R < 30 then
    Result := Unidad(R, Modo)
  else
  begin
    Result := DECENAS[R div 10];
    if R mod 10 > 0 then
      Result := Result + ' y ' + Unidad(R mod 10, Modo);
  end;
end;

function Menos1000(N: Integer; Modo: TModoLetras): string;
var
  H, R: Integer;
  Centena: string;
begin
  if N = 100 then
    Exit('cien');
  Result := '';
  H := N div 100;
  R := N mod 100;
  if H > 0 then
  begin
    Centena := CENTENAS[H];
    if (H >= 2) and (Modo <> mlMasculino) then
      Centena := Copy(Centena, 1, Length(Centena) - 2) + 'as';
    Result := Centena;
  end;
  if R > 0 then
  begin
    if Result <> '' then
      Result := Result + ' ';
    Result := Result + Menos100(R, Modo);
  end;
end;

function UnidadesEnLetras(N: Int64): string;
var
  Millones, Miles, Resto: Integer;

  procedure Agregar(const Texto: string);
  begin
    if Result <> '' then
      Result := Result + ' ';
    Result := Result + Texto;
  end;

begin
  if (N < 0) or (N > 999999999) then
    raise EArgumentException.Create('El numero de unidades esta fuera de rango: ' + IntToStr(N));
  if N = 0 then
    Exit('cero');
  Result := '';
  Millones := N div 1000000;
  Miles := (N mod 1000000) div 1000;
  Resto := N mod 1000;
  if Millones > 0 then
    if Millones = 1 then
      Agregar('un millon')
    else
      Agregar(Menos1000(Millones, mlMasculino) + ' millones');
  if Miles > 0 then
    if Miles = 1 then
      Agregar('mil')
    else
      Agregar(Menos1000(Miles, mlApocope) + ' mil');
  if Resto > 0 then
    Agregar(Menos1000(Resto, mlFemenino));
end;

function UnidadesNumerosYLetras(N: Int64): string;
var
  Letras, Digitos: string;
  I, Cont: Integer;
begin
  Letras := UnidadesEnLetras(N);   // lanza si esta fuera de rango
  Digitos := IntToStr(N);
  Result := '';
  Cont := 0;
  for I := Length(Digitos) downto 1 do
  begin
    if (Cont > 0) and (Cont mod 3 = 0) then
      Result := ' ' + Result;
    Result := Digitos[I] + Result;
    Inc(Cont);
  end;
  Result := Result + ' (' + Letras + ')';
end;

function RangoMesAnio(Desde, Hasta: TDateTime): string;
var
  A1, M1, D1, A2, M2, D2: Word;
begin
  if Desde = 0 then
    Exit('');
  DecodeDate(Desde, A1, M1, D1);
  Result := Format('%.2d/%d', [M1, A1]);
  if Hasta = 0 then
    Exit;
  DecodeDate(Hasta, A2, M2, D2);
  if (A1 <> A2) or (M1 <> M2) then
    Result := Result + ' - ' + Format('%.2d/%d', [M2, A2]);
end;

function TextoAutorizacionCorto(const A: TAutorizacion): string;
var
  Organo: string;
begin
  case A.Organo of
    ocNacional: Organo := 'Comision Nac.';
    ocProvincial: Organo := 'Comision Prov.';
    ocMunicipal: Organo := 'Comision Mun.';
  else
    Organo := 'Comision Central';
  end;
  Result := Organo + ' - Acta ' + A.NumActa + ' - Acuerdo ' + A.NumAcuerdo;
end;

{ -------------------------------- validaciones -------------------------------- }

procedure Sumar(var Lista: TArray<string>; const Mensaje: string);
begin
  SetLength(Lista, Length(Lista) + 1);
  Lista[High(Lista)] := Mensaje;
end;

function TestigosSuficientes(const T: array of TTestigoDatos): Boolean;
var
  X: TTestigoDatos;
  HayComision, HayGestion: Boolean;
begin
  HayComision := False;
  HayGestion := False;
  for X in T do
  begin
    if X.Origen = otComision then
      HayComision := True;
    if X.Origen = otArchivoGestion then
      HayGestion := True;
  end;
  Result := (Length(T) >= MINIMO_TESTIGOS) and HayComision and HayGestion;
end;

function ValidarTestigo(const T: TTestigoDatos): TArray<string>;
begin
  Result := nil;
  if Trim(T.Nombre) = '' then
    Sumar(Result, 'Escriba el nombre del testigo.')
  else if Length(Trim(T.Nombre)) > 100 then
    Sumar(Result, 'El nombre del testigo es demasiado largo (m' + #225 + 'ximo 100 caracteres).');
  if Length(Trim(T.Cargo)) > 100 then
    Sumar(Result, 'El cargo del testigo es demasiado largo (m' + #225 + 'ximo 100 caracteres).');
end;

function ValidarActaDepuracion(const Lugar: string; FPrevista: TDateTime): TArray<string>;
begin
  Result := nil;
  if Trim(Lugar) = '' then
    Sumar(Result, 'Indique el lugar de la eliminaci' + #243 + 'n.')
  else if Length(Trim(Lugar)) > 255 then
    Sumar(Result, 'El lugar es demasiado largo (m' + #225 + 'ximo 255 caracteres).');
  if FPrevista = 0 then
    Sumar(Result, 'Indique la fecha prevista de la eliminaci' + #243 + 'n.');
end;

function ValidarMuestra(const Descripcion, Donde: string): TArray<string>;
begin
  Result := nil;
  if Trim(Descripcion) = '' then
    Sumar(Result, 'Describa la muestra que se conserva.')
  else if Length(Trim(Descripcion)) > 255 then
    Sumar(Result, 'La descripci' + #243 + 'n de la muestra es demasiado larga (m' + #225 +
      'ximo 255 caracteres).');
  if Trim(Donde) = '' then
    Sumar(Result, 'Indique d' + #243 + 'nde queda la muestra.')
  else if Length(Trim(Donde)) > 255 then
    Sumar(Result, 'La localizaci' + #243 + 'n de la muestra es demasiado larga (m' + #225 +
      'ximo 255 caracteres).');
end;

function ConfirmacionEscritaValida(const Texto: string): Boolean;
begin
  Result := Trim(Texto) = PALABRA_CONFIRMACION;
end;

function TextoEstadoDepuracion(Paso: Integer; Estado: TEstadoProceso): string;
begin
  case Estado of
    epFinalizado: Result := 'Cerrada';
    epCancelado: Result := 'Cancelada';
  else
    case Paso of
      1: Result := 'Propuesta';
      2: Result := 'En autorizacion';
      3: Result := 'Acta por firmar';
      4: Result := 'Lista para ejecutar';
    else
      Result := 'Ejecutada';
    end;
  end;
end;

function TextosQueFaltanDepuracion(Faltan: TCondiciones): TArray<string>;
begin
  Result := nil;
  if cdSinBloqueos in Faltan then
    Sumar(Result, 'No hay documentos en la depuraci' + #243 + 'n o alguno ya no est' + #225 +
      ' retenido por ella.');
  if cdAutorizado in Faltan then
    Sumar(Result, 'Falta registrar el acta y el acuerdo de la Comisi' + #243 + 'n.');
  if cdMuestraDefinida in Faltan then
    Sumar(Result, 'Falta definir la muestra que se conserva (descripci' + #243 +
      'n y d' + #243 + 'nde queda).');
  if cdTestigosMinimos in Faltan then
    Sumar(Result, 'Hacen falta al menos ' + IntToStr(MINIMO_TESTIGOS) + ' testigos: uno de la ' +
      'Comisi' + #243 + 'n y uno de un archivo de gesti' + #243 + 'n.');
  if cdActaCompleta in Faltan then
    Sumar(Result, 'Falta completar el acta: lugar, v' + #237 + 'a y fecha prevista de la ' +
      'eliminaci' + #243 + 'n.');
  if cdConfirmacionEscrita in Faltan then
    Sumar(Result, 'Escriba ' + PALABRA_CONFIRMACION + ' para confirmar.');
end;

end.
