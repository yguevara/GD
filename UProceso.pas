unit UProceso;

{ ---------------------------------------------------------------------------
  Reglas de pasos de los procesos archivisticos: prestamo, transferencia y
  depuracion. Sin VCL ni FireDAC: solo RTL y UAlcance.

  Un proceso avanza de un paso al siguiente solo si se cumplen las condiciones
  que exige ese paso (CondicionesParaAvanzar). La pantalla y UProcesosDatos
  consultan estas reglas; nunca las duplican.

  Pasos:
    Prestamo (3)      : 1 Solicitado, 2 Entregado, 3 Devuelto.
    Transferencia (6) : 1 Propuesta, 2 Comision, 3 Preparacion, 4 Entrega,
                        5 Recepcion, 6 Ubicacion.
    Depuracion (5)    : 1 Propuesta, 2 Autorizacion, 3 Acta, 4 Ejecucion,
                        5 Cierre.
  El ultimo paso no "avanza": al cumplir sus condiciones el proceso finaliza.
  Diseno: docs/superpowers/specs/2026-11-12-prestamos-transferencias-
  depuracion-design.md
  --------------------------------------------------------------------------- }

interface

uses
  UAlcance;

type
  TTipoProceso = (tpPrestamo, tpTransferencia, tpDepuracion);

  { En curso, finalizado o cancelado. }
  TEstadoProceso = (epEnCurso, epFinalizado, epCancelado);

  { Hechos que la pantalla o los datos verifican antes de dejar avanzar. }
  TCondicion = (cdAutorizado, cdSinBloqueos, cdVerificacionesCompletas,
    cdRecepcionConfirmada, cdUbicacionCompleta, cdMuestraDefinida,
    cdTestigosMinimos, cdActaCompleta, cdConfirmacionEscrita, cdFicherosResueltos);
  TCondiciones = set of TCondicion;

  TTipoArchivo = (taGestion, taCentral, taHistorico, taOtro);

  { Como se dibuja un paso en la tira de pasos de la pantalla. }
  TEstadoPaso = (psHecho, psActual, psPendiente);

{ Cantidad de pasos del proceso. }
function NumeroPasos(Tipo: TTipoProceso): Integer;

{ Condiciones para completar PasoActual (pasar al siguiente o, en el ultimo
  paso, finalizar). Un paso fuera de rango no tiene condiciones definidas: no
  avanza (ver PuedeAvanzar). }
function CondicionesParaAvanzar(Tipo: TTipoProceso; PasoActual: Integer): TCondiciones;

{ True si Cumplidas incluye todas las condiciones del paso. Faltan devuelve las
  que no se cumplen. Un paso fuera de rango devuelve False. }
function PuedeAvanzar(Tipo: TTipoProceso; PasoActual: Integer;
  Cumplidas: TCondiciones; out Faltan: TCondiciones): Boolean;

{ Cancelar es posible mientras no haya efectos irreversibles: prestamo hasta la
  entrega (pasos 1 y 2), transferencia hasta la entrega (paso 4) y depuracion
  hasta el acta (paso 3). }
function PuedeCancelar(Tipo: TTipoProceso; PasoActual: Integer): Boolean;

{ Si el proceso se puede borrar de la base: uno cancelado, o uno en curso que
  todavia se puede cancelar (no ha salido nada del archivo). Uno finalizado nunca:
  es parte del historial archivistico. }
function PuedeEliminar(Tipo: TTipoProceso; PasoActual: Integer;
  Estado: TEstadoProceso): Boolean;

{ Quien puede iniciar el proceso segun su rol y el tipo del archivo remitente:
  la transferencia sale de un archivo de gestion; la depuracion solo la inicia
  el archivo central o el historico (nunca uno de gestion). }
function PuedeIniciar(Tipo: TTipoProceso; Rol: TRolNodo; Archivo: TTipoArchivo): Boolean;

{ Estado visual del paso Paso (1..N) de un proceso que esta en PasoActual con el
  estado Estado: los anteriores estan hechos y el actual esta en curso. Un
  proceso finalizado tiene todos los pasos hechos; en uno cancelado el paso en
  que se detuvo queda pendiente. }
function EstadoDelPaso(Tipo: TTipoProceso; PasoActual: Integer;
  Estado: TEstadoProceso; Paso: Integer): TEstadoPaso;

{ Interpreta el nombre del tipo de archivo (cl_ttipoarch.tipoarch) sin depender
  del codigo numerico ni de las tildes. }
function TipoArchivoDesdeTexto(const Texto: string): TTipoArchivo;

implementation

uses
  System.SysUtils;

function NumeroPasos(Tipo: TTipoProceso): Integer;
begin
  case Tipo of
    tpPrestamo: Result := 3;
    tpTransferencia: Result := 6;
    tpDepuracion: Result := 5;
  else
    Result := 0;
  end;
end;

function CondicionesParaAvanzar(Tipo: TTipoProceso; PasoActual: Integer): TCondiciones;
begin
  Result := [];
  case Tipo of
    tpPrestamo:
      if PasoActual = 1 then
        Result := [cdSinBloqueos];
    tpTransferencia:
      case PasoActual of
        1: Result := [cdSinBloqueos];
        2: Result := [cdAutorizado];
        3: Result := [cdAutorizado, cdSinBloqueos, cdVerificacionesCompletas];
        5: Result := [cdRecepcionConfirmada];
        6: Result := [cdUbicacionCompleta];
      end;
    tpDepuracion:
      case PasoActual of
        1: Result := [cdSinBloqueos];
        2: Result := [cdAutorizado];
        3: Result := [cdMuestraDefinida, cdTestigosMinimos, cdActaCompleta];
        4: Result := [cdConfirmacionEscrita, cdSinBloqueos];
        5: Result := [cdFicherosResueltos];
      end;
  end;
end;

function PuedeAvanzar(Tipo: TTipoProceso; PasoActual: Integer;
  Cumplidas: TCondiciones; out Faltan: TCondiciones): Boolean;
begin
  Faltan := [];
  if (PasoActual < 1) or (PasoActual > NumeroPasos(Tipo)) then
    Exit(False);
  Faltan := CondicionesParaAvanzar(Tipo, PasoActual) - Cumplidas;
  Result := Faltan = [];
end;

function PuedeEliminar(Tipo: TTipoProceso; PasoActual: Integer;
  Estado: TEstadoProceso): Boolean;
begin
  case Estado of
    epCancelado: Result := True;
    epEnCurso: Result := PuedeCancelar(Tipo, PasoActual);
  else
    Result := False;
  end;
end;

function PuedeCancelar(Tipo: TTipoProceso; PasoActual: Integer): Boolean;
begin
  if (PasoActual < 1) or (PasoActual > NumeroPasos(Tipo)) then
    Exit(False);
  case Tipo of
    tpPrestamo: Result := PasoActual <= 2;
    tpTransferencia: Result := PasoActual <= 4;
    tpDepuracion: Result := PasoActual <= 3;
  else
    Result := False;
  end;
end;

function PuedeIniciar(Tipo: TTipoProceso; Rol: TRolNodo; Archivo: TTipoArchivo): Boolean;
begin
  case Tipo of
    tpPrestamo:
      Result := RolPermite(Rol, acPrestar);
    tpTransferencia:
      Result := RolPermite(Rol, acTransferir) and (Archivo = taGestion);
    tpDepuracion:
      Result := RolPermite(Rol, acDepurar) and (Archivo in [taCentral, taHistorico]);
  else
    Result := False;
  end;
end;

function EstadoDelPaso(Tipo: TTipoProceso; PasoActual: Integer;
  Estado: TEstadoProceso; Paso: Integer): TEstadoPaso;
begin
  if Estado = epFinalizado then
    Exit(psHecho);
  if Paso < PasoActual then
    Result := psHecho
  else if (Paso = PasoActual) and (Estado = epEnCurso) then
    Result := psActual
  else
    Result := psPendiente;
end;

function TipoArchivoDesdeTexto(const Texto: string): TTipoArchivo;
var
  T: string;
begin
  T := UpperCase(Trim(Texto));
  // La tilde de "Historico"/"Gestion" no importa: se busca la raiz sin ella.
  if Pos('CENTRAL', T) > 0 then
    Result := taCentral
  else if Pos('HIST', T) > 0 then
    Result := taHistorico
  else if Pos('GESTI', T) > 0 then
    Result := taGestion
  else
    Result := taOtro;
end;

end.
