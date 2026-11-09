unit UTrazabilidad;

{ Eventos de la vida de un documento (F5): tipos, clasificacion por codigo de
  accion de tb_log, etiquetas y orden. Solo RTL (sin VCL ni FireDAC).
  Codigos de accion (tb_accionlog, orden del diseno 2026-10-29: Copiar,
  Eliminar, Modificar, Descargar, Insertar, Visualizar): 2 Eliminar,
  3 Modificar, 5 Insertar y 14 Visualizar estan confirmados por el codigo
  existente; 4 Descargar y 6 Visualizar se deducen del orden y deben
  confirmarse con SELECT * FROM tb_accionlog (ver la lista manual). }

interface

type
  TTipoEvento = (teCreado, teNuevaVersion, teModificado, teConsultado,
    teDescargado, tePrestado, teDevuelto, teTransferido, teDepurado, teOtro);

  TEventoDoc = record
    Fecha: TDateTime;
    Tipo: TTipoEvento;
    Usuario, Rol, Detalle: string;
  end;

const
  ACCION_ELIMINAR = 2;
  ACCION_MODIFICAR = 3;
  ACCION_DESCARGAR = 4;
  ACCION_INSERTAR = 5;
  ACCION_VISUALIZAR_ALT = 6;
  ACCION_VISUALIZAR = 14;

function TipoDesdeAccion(Accion: Integer): TTipoEvento;
function EtiquetaEvento(Tipo: TTipoEvento): string;
{ Deja los Maximo eventos mas recientes, el mas reciente primero. HayMas indica
  que se descartaron eventos. Maximo <= 0 no limita. }
procedure OrdenarYLimitar(var Eventos: TArray<TEventoDoc>; Maximo: Integer;
  out HayMas: Boolean);

implementation

uses
  System.Generics.Collections, System.Generics.Defaults;

function TipoDesdeAccion(Accion: Integer): TTipoEvento;
begin
  case Accion of
    ACCION_ELIMINAR: Result := teDepurado;
    ACCION_MODIFICAR: Result := teModificado;
    ACCION_DESCARGAR: Result := teDescargado;
    ACCION_INSERTAR: Result := teCreado;
    ACCION_VISUALIZAR_ALT, ACCION_VISUALIZAR: Result := teConsultado;
  else
    Result := teOtro;
  end;
end;

function EtiquetaEvento(Tipo: TTipoEvento): string;
begin
  case Tipo of
    teCreado: Result := 'Creado';
    teNuevaVersion: Result := 'Nueva version';
    teModificado: Result := 'Modificado';
    teConsultado: Result := 'Consultado';
    teDescargado: Result := 'Descargado';
    tePrestado: Result := 'Prestado';
    teDevuelto: Result := 'Devuelto';
    teTransferido: Result := 'Transferido';
    teDepurado: Result := 'Depurado';
  else
    Result := 'Otro';
  end;
end;

procedure OrdenarYLimitar(var Eventos: TArray<TEventoDoc>; Maximo: Integer;
  out HayMas: Boolean);
begin
  HayMas := False;
  if Length(Eventos) = 0 then
    Exit;
  TArray.Sort<TEventoDoc>(Eventos, TComparer<TEventoDoc>.Construct(
    function(const A, B: TEventoDoc): Integer
    begin
      if A.Fecha > B.Fecha then
        Result := -1
      else if A.Fecha < B.Fecha then
        Result := 1
      else
        Result := 0;
    end));
  if (Maximo > 0) and (Length(Eventos) > Maximo) then
  begin
    SetLength(Eventos, Maximo);
    HayMas := True;
  end;
end;

end.
