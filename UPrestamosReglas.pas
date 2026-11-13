unit UPrestamosReglas;

{ ---------------------------------------------------------------------------
  Reglas del prestamo de documentos. Sin VCL ni FireDAC.

  El prestamo es un proceso de 3 pasos (UProceso): 1 Solicitado, 2 Entregado,
  3 Devuelto. Lo que el usuario ve (EstadoDelPrestamo) combina el paso y el
  estado del proceso con la fecha limite:

    - Entregado y con la fecha limite ya pasada   -> Vencido
    - Entregado y que vence en 0 a 3 dias         -> Por vencer
    - Entregado en otro caso                      -> Entregado

  La fecha limite es el ULTIMO dia para devolver: un prestamo que vence hoy no
  esta vencido. Sin fecha limite (0) nunca vence. Las comparaciones usan solo la
  parte de fecha (la hora no cuenta).

  La solicitud sigue el Anexo 8.2 del Manual Marco: nombre y carnet del
  solicitante; los usuarios externos deben identificarse y decir su entidad.
  Diseno: docs/superpowers/specs/2026-11-12-prestamos-transferencias-
  depuracion-design.md (seccion 5).
  --------------------------------------------------------------------------- }

interface

uses
  UProceso, UErroresCampo;

const
  { Plazo de devolucion que se sugiere al registrar la entrega. }
  PLAZO_PRESTAMO_DIAS = 3;
  { Dias de aviso antes del vencimiento. }
  DIAS_POR_VENCER = 3;

type
  TTipoUsuarioPrestamo = (tuInterno, tuExterno);

  TEstadoPrestamo = (epsSolicitado, epsEntregado, epsPorVencer, epsVencido,
    epsDevuelto, epsCancelado);

  { Datos que se piden al solicitar el prestamo. FechaLimite = 0: sin limite. }
  TSolicitudPrestamo = record
    Solicitante: string;
    Carnet: string;
    Entidad: string;
    Usuario: TTipoUsuarioPrestamo;
    FechaLimite: TDateTime;
  end;

{ Estado que se muestra al usuario. Paso y Estado son los del proceso. }
function EstadoDelPrestamo(Paso: Integer; Estado: TEstadoProceso;
  FechaLimite, Hoy: TDateTime): TEstadoPrestamo;

{ Dias completos de retraso (0 si no esta vencido o no hay fecha limite). }
function DiasDeRetraso(FechaLimite, Hoy: TDateTime): Integer;

{ Fecha limite sugerida: la fecha de entrega (sin hora) mas Dias. }
function FechaLimiteSugerida(Entrega: TDateTime; Dias: Integer): TDateTime;

{ Errores de la solicitud (campos 'solicitante', 'carnet', 'entidad', 'limite');
  vacia si es valida. }
function ValidarSolicitud(const S: TSolicitudPrestamo;
  Hoy: TDateTime): TArray<TErrorCampo>;

implementation

uses
  System.SysUtils;

function EstadoDelPrestamo(Paso: Integer; Estado: TEstadoProceso;
  FechaLimite, Hoy: TDateTime): TEstadoPrestamo;
var
  Faltan: Integer;
begin
  case Estado of
    epFinalizado:
      Exit(epsDevuelto);
    epCancelado:
      Exit(epsCancelado);
  end;
  if Paso <= 1 then
    Exit(epsSolicitado);
  Result := epsEntregado;
  if FechaLimite = 0 then
    Exit;
  Faltan := Trunc(FechaLimite) - Trunc(Hoy);
  if Faltan < 0 then
    Result := epsVencido
  else if Faltan <= DIAS_POR_VENCER then
    Result := epsPorVencer;
end;

function DiasDeRetraso(FechaLimite, Hoy: TDateTime): Integer;
begin
  Result := 0;
  if FechaLimite = 0 then
    Exit;
  if Trunc(FechaLimite) < Trunc(Hoy) then
    Result := Trunc(Hoy) - Trunc(FechaLimite);
end;

function FechaLimiteSugerida(Entrega: TDateTime; Dias: Integer): TDateTime;
begin
  Result := Trunc(Entrega) + Dias;
end;

procedure Agregar(var Lista: TArray<TErrorCampo>; const Campo, Mensaje: string);
var
  E: TErrorCampo;
begin
  E.Campo := Campo;
  E.Mensaje := Mensaje;
  SetLength(Lista, Length(Lista) + 1);
  Lista[High(Lista)] := E;
end;

{ True si S tiene exactamente N digitos. }
function SoloDigitos(const S: string; N: Integer): Boolean;
var
  C: Char;
begin
  Result := Length(S) = N;
  if Result then
    for C in S do
      if (C < '0') or (C > '9') then
        Exit(False);
end;

function ValidarSolicitud(const S: TSolicitudPrestamo;
  Hoy: TDateTime): TArray<TErrorCampo>;
begin
  Result := nil;
  if Trim(S.Solicitante) = '' then
    Agregar(Result, 'solicitante', 'Falta el nombre del solicitante.');
  if S.Usuario = tuExterno then
  begin
    if not SoloDigitos(Trim(S.Carnet), 11) then
      Agregar(Result, 'carnet',
        'El usuario externo debe identificarse con su carnet de 11 digitos.');
    if Trim(S.Entidad) = '' then
      Agregar(Result, 'entidad', 'Falta la entidad a la que pertenece.');
  end;
  if (S.FechaLimite <> 0) and (Trunc(S.FechaLimite) < Trunc(Hoy)) then
    Agregar(Result, 'limite', 'La fecha limite no puede ser anterior a hoy.');
end;

end.
