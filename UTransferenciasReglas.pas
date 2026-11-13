unit UTransferenciasReglas;

{ ---------------------------------------------------------------------------
  Reglas de la transferencia documental del archivo de gestion al archivo
  central. Sin VCL ni FireDAC.

  Vencimiento: un documento se propone para transferir cuando termino su plazo
  en el archivo de gestion (cl_subseries.tgestion, en anos). El plazo se cuenta
  desde la fecha de cierre del documento (FechaFin) si existe y no es anterior a
  su fecha (Fecha); en otro caso, desde Fecha. Sin plazo definido (0) no se
  propone nunca. Vence el dia del aniversario.

  Cajas: los documentos se reparten en cajas numeradas de forma consecutiva; un
  expediente (o los documentos de un mismo asunto) NO se divide entre cajas
  (Manual de procedimientos GD, requisitos de la transferencia, punto e).

  Verificaciones: casillas que el archivo de gestion marca antes de entregar
  (mismo Manual, "Requerimientos para la transferencia").
  Diseno: docs/superpowers/specs/2026-11-12-prestamos-transferencias-
  depuracion-design.md (seccion 6).
  --------------------------------------------------------------------------- }

interface

uses
  UProceso;

const
  { Documentos por caja si no se indica otra capacidad. }
  CAPACIDAD_CAJA_DEFECTO = 20;

type
  TEstadoCronograma = (ecProgramada, ecAtrasada, ecEnTramite, ecRealizada);

  { Un documento a repartir: Grupo identifica el conjunto que no se parte
    (codsubs + expediente) y Orden su posicion en la relacion. }
  TItemCaja = record
    Grupo: string;
    Orden: Integer;
  end;

  TVerificacion = record
    Codigo: string;
    Texto: string;
  end;

const
  VERIFICACIONES: array[0..4] of TVerificacion = (
    (Codigo: 'unicos';
     Texto: 'Son ejemplares '#250'nicos, no copias'),
    (Codigo: 'completos';
     Texto: 'Los expedientes est'#225'n completos y en buen estado, sin presillas ni clips'),
    (Codigo: 'sindividir';
     Texto: 'Ning'#250'n expediente queda dividido en cajas distintas'),
    (Codigo: 'etiquetas';
     Texto: 'El listado de documentos est'#225' pegado en el exterior de cada caja'),
    (Codigo: 'prestamos';
     Texto: 'No hay documentos de la transferencia en pr'#233'stamo'));

{ Fecha tal que un documento anterior o igual a ella ya cumplio AniosGestion
  anos. 0 si no hay plazo (AniosGestion <= 0). }
function FechaCorte(Hoy: TDateTime; AniosGestion: Integer): TDateTime;

{ Como FechaCorte, pero con Anticipada (transferir antes de que venza el plazo, o
  sin plazo definido) devuelve un corte tan lejano que incluye todos los documentos. }
function FechaCorteGrupo(Hoy: TDateTime; AniosGestion: Integer;
  Anticipada: Boolean): TDateTime;

{ True si el plazo en el archivo de gestion ya vencio. }
function PlazoVencido(Fecha, FechaFin: TDateTime; HayFechaFin: Boolean;
  AniosGestion: Integer; Hoy: TDateTime): Boolean;

{ Estado de una unidad del cronograma anual. }
function EstadoCronograma(FPrevista: TDateTime; HayProceso, Finalizado: Boolean;
  Hoy: TDateTime): TEstadoCronograma;

{ Marcadas son los codigos marcados; se ignoran los desconocidos. }
function VerificacionesCompletas(const Marcadas: array of string): Boolean;
function VerificacionesFaltan(const Marcadas: array of string): TArray<string>;

{ Caja de cada item (en el orden de entrada): se recorren por Orden, un grupo
  entero va siempre a una caja, se abre caja nueva cuando el grupo siguiente no
  cabe (salvo que la caja este vacia) y un grupo mayor que la capacidad ocupa su
  propia caja. Cajas consecutivas desde PrimeraCaja. Capacidad <= 0 usa
  CAPACIDAD_CAJA_DEFECTO. }
function RepartirEnCajas(const Items: TArray<TItemCaja>; Capacidad,
  PrimeraCaja: Integer): TArray<Integer>;

{ Texto del estado de una transferencia para la lista. }
function TextoEstadoTransferencia(Paso: Integer; Estado: TEstadoProceso): string;

{ Errores (vacia si es valida) al registrar la recepcion en el archivo central: hay
  que decir quien recibe y la fecha no puede ser futura ni anterior a la entrega
  (FEntrega = 0 si no se conoce). }
function ValidarRecepcion(const RecibidoPor: string; Fecha, FEntrega,
  Hoy: TDateTime): TArray<string>;

{ Errores (vacia si es valida) al registrar donde quedan las cajas: un texto no
  vacio de hasta 255 caracteres (limite de Access). }
function ValidarUbicacion(const Ubicacion: string): TArray<string>;

implementation

uses
  System.SysUtils, System.DateUtils, System.Generics.Collections,
  System.Generics.Defaults;

function FechaCorte(Hoy: TDateTime; AniosGestion: Integer): TDateTime;
begin
  if AniosGestion <= 0 then
    Result := 0
  else
    Result := IncYear(Hoy, -AniosGestion);
end;

function FechaCorteGrupo(Hoy: TDateTime; AniosGestion: Integer;
  Anticipada: Boolean): TDateTime;
begin
  if Anticipada then
    Result := IncYear(Hoy, 100)
  else
    Result := FechaCorte(Hoy, AniosGestion);
end;

function PlazoVencido(Fecha, FechaFin: TDateTime; HayFechaFin: Boolean;
  AniosGestion: Integer; Hoy: TDateTime): Boolean;
var
  Base: TDateTime;
begin
  if (AniosGestion <= 0) or (Fecha = 0) then
    Exit(False);
  Base := Fecha;
  if HayFechaFin and (FechaFin >= Fecha) then
    Base := FechaFin;
  Result := Trunc(IncYear(Trunc(Base), AniosGestion)) <= Trunc(Hoy);
end;

function EstadoCronograma(FPrevista: TDateTime; HayProceso, Finalizado: Boolean;
  Hoy: TDateTime): TEstadoCronograma;
begin
  if Finalizado then
    Result := ecRealizada
  else if HayProceso then
    Result := ecEnTramite
  else if Trunc(FPrevista) < Trunc(Hoy) then
    Result := ecAtrasada
  else
    Result := ecProgramada;
end;

function EstaMarcada(const Marcadas: array of string; const Codigo: string): Boolean;
var
  M: string;
begin
  for M in Marcadas do
    if SameText(M, Codigo) then
      Exit(True);
  Result := False;
end;

function VerificacionesFaltan(const Marcadas: array of string): TArray<string>;
var
  V: TVerificacion;
begin
  Result := nil;
  for V in VERIFICACIONES do
    if not EstaMarcada(Marcadas, V.Codigo) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := V.Codigo;
    end;
end;

function VerificacionesCompletas(const Marcadas: array of string): Boolean;
begin
  Result := Length(VerificacionesFaltan(Marcadas)) = 0;
end;

function RepartirEnCajas(const Items: TArray<TItemCaja>; Capacidad,
  PrimeraCaja: Integer): TArray<Integer>;
var
  Indices: TList<Integer>;
  Grupos: TList<string>;
  Tamano: TDictionary<string, Integer>;
  CajaDe: TDictionary<string, Integer>;
  I, Caja, Cuenta, N: Integer;
  G: string;
begin
  if Capacidad <= 0 then
    Capacidad := CAPACIDAD_CAJA_DEFECTO;
  SetLength(Result, Length(Items));
  if Length(Items) = 0 then
    Exit;
  Indices := TList<Integer>.Create;
  Grupos := TList<string>.Create;
  Tamano := TDictionary<string, Integer>.Create;
  CajaDe := TDictionary<string, Integer>.Create;
  try
    for I := 0 to High(Items) do
      Indices.Add(I);
    // por Orden; a igual Orden, por posicion de entrada (orden estable)
    Indices.Sort(TComparer<Integer>.Construct(
      function(const A, B: Integer): Integer
      begin
        Result := Items[A].Orden - Items[B].Orden;
        if Result = 0 then
          Result := A - B;
      end));
    // grupos en orden de primera aparicion y su tamano
    for I in Indices do
    begin
      G := Items[I].Grupo;
      if Tamano.TryGetValue(G, N) then
        Tamano[G] := N + 1
      else
      begin
        Tamano.Add(G, 1);
        Grupos.Add(G);
      end;
    end;
    Caja := PrimeraCaja;
    Cuenta := 0;
    for G in Grupos do
    begin
      N := Tamano[G];
      if (Cuenta > 0) and (Cuenta + N > Capacidad) then
      begin
        Inc(Caja);
        Cuenta := 0;
      end;
      CajaDe.Add(G, Caja);
      Inc(Cuenta, N);
    end;
    for I := 0 to High(Items) do
      Result[I] := CajaDe[Items[I].Grupo];
  finally
    CajaDe.Free;
    Tamano.Free;
    Grupos.Free;
    Indices.Free;
  end;
end;

function ValidarRecepcion(const RecibidoPor: string; Fecha, FEntrega,
  Hoy: TDateTime): TArray<string>;
var
  Lista: TList<string>;
begin
  Lista := TList<string>.Create;
  try
    if Trim(RecibidoPor) = '' then
      Lista.Add('Escriba el nombre de quien recibe.');
    if Trunc(Fecha) > Trunc(Hoy) then
      Lista.Add('La fecha de recepci' + #243 + 'n no puede ser futura.');
    if (FEntrega <> 0) and (Trunc(Fecha) < Trunc(FEntrega)) then
      Lista.Add('La recepci' + #243 + 'n no puede ser anterior a la entrega.');
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

function ValidarUbicacion(const Ubicacion: string): TArray<string>;
begin
  Result := nil;
  if Trim(Ubicacion) = '' then
    Result := ['Indique d' + #243 + 'nde quedan las cajas (dep' + #243 + 'sito, estante...).']
  else if Length(Trim(Ubicacion)) > 255 then
    Result := ['La ubicaci' + #243 + 'n es demasiado larga (m' + #225 + 'ximo 255 caracteres).'];
end;

function TextoEstadoTransferencia(Paso: Integer; Estado: TEstadoProceso): string;
begin
  case Estado of
    epCancelado:
      Exit('Cancelada');
    epFinalizado:
      Exit('Completada');
  end;
  case Paso of
    1: Result := 'Propuesta';
    2: Result := 'Esperando comisi' + #243 + 'n';
    3: Result := 'En preparaci' + #243 + 'n';
    4: Result := 'Listo para entregar';
    5: Result := 'En recepci' + #243 + 'n';
    6: Result := 'En ubicaci' + #243 + 'n';
  else
    Result := '';
  end;
end;

end.
