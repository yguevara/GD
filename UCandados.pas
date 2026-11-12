unit UCandados;

{ ---------------------------------------------------------------------------
  Candado "un documento, un proceso abierto". Sin VCL ni FireDAC.

  Un documento solo puede estar en un proceso abierto a la vez (prestamo,
  transferencia o depuracion). Esta unidad define la clave que identifica al
  documento y la regla de entrada; la consulta de los bloqueos esta en
  UProcesosDatos (una sola consulta por nodo, nunca una por fila).

  La clave usa NormalizaClave para IdEstructura: en las bases reales aparecen
  'a.1.4', 'A.1.6 ' y 'A.6..3.3', y el id del nodo NO es unico por si solo.
  --------------------------------------------------------------------------- }

interface

uses
  UProceso;

type
  { Misma clave que TB_PrestamosDocumentos y prc_unidad. }
  TUnidadDoc = record
    IdEstructura: string;
    Id: Integer;
    CodigoDoc: string;
    Fecha: TDateTime;
    Version: string;
  end;

  { Proceso abierto que retiene un documento. }
  TBloqueo = record
    Tipo: TTipoProceso;
    Numero: string;
  end;

{ Clave textual unica del documento, tolerante a mayusculas y espacios en
  IdEstructura, CodigoDoc y Version. }
function ClaveUnidad(const U: TUnidadDoc): string;

{ True si el documento puede entrar a otro proceso (no hay bloqueo). Si no puede,
  Motivo explica quien lo tiene ("En prestamo 2026-0047"). }
function PuedeEntrar(const Bloqueo: TBloqueo; HayBloqueo: Boolean;
  out Motivo: string): Boolean;

implementation

uses
  System.SysUtils, UAlcance;

function ClaveUnidad(const U: TUnidadDoc): string;
begin
  Result := NormalizaClave(U.IdEstructura) + '|' + IntToStr(U.Id) + '|' +
    Trim(U.CodigoDoc) + '|' + FormatDateTime('yyyymmddhhnnss', U.Fecha) + '|' +
    Trim(U.Version);
end;

function PuedeEntrar(const Bloqueo: TBloqueo; HayBloqueo: Boolean;
  out Motivo: string): Boolean;
begin
  Motivo := '';
  if not HayBloqueo then
    Exit(True);
  case Bloqueo.Tipo of
    tpPrestamo: Motivo := 'En prestamo ';
    tpTransferencia: Motivo := 'En transferencia ';
    tpDepuracion: Motivo := 'En depuracion ';
  end;
  Motivo := Motivo + Bloqueo.Numero;
  Result := False;
end;

end.
