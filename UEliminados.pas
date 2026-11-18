unit UEliminados;

{ ---------------------------------------------------------------------------
  Documentos ELIMINADOS: los que incluye una depuracion EJECUTADA (prc_unidad
  activa de un proceso tipo 'D' que no esta cancelado y ya paso el paso 4,
  Paso >= 5). No se toca tb_SeriesDatos ni se agrega ninguna columna: la marca
  se deduce de la depuracion, igual que "transferido" (UTransferidos).
  Un documento eliminado queda en solo lectura: no se presta, no se edita, no
  se propone en una transferencia ni en otra depuracion. Excluirlo de la
  busqueda y del arbol es F5; aqui queda la consulta compartida.
  Sin VCL ni TUDM (RTL + FireDAC).
  Diseno: docs/superpowers/specs/2026-11-18-depuracion-f4-design.md.
  --------------------------------------------------------------------------- }

interface

uses
  FireDAC.Comp.Client, UCandados;

{ Unidades de depuraciones ejecutadas: U.IdEstructura, U.id, U.codsubs, U.Codigodoc,
  U.fecha, U.version, P.IdProceso, P.Numero. Sin parametros: el llamador agrega su
  WHERE con AND. Valido en Access. }
function SqlEliminados: string;

{ Condicion (alias H = tb_SeriesDatos, sin parametros) que deja fuera los documentos
  ya eliminados. }
function SqlNoEliminado: string;

{ "Eliminado (D-2026-02)". }
function TextoEliminado(const Numero: string): string;

{ '' si el documento no esta eliminado; si lo esta, TextoEliminado. Solo la falta de
  las tablas de procesos cuenta como "no eliminado": otro error de base se propaga. }
function DondeEstaEliminado(Conn: TFDConnection; const U: TUnidadDoc): string;

function EstaEliminado(Conn: TFDConnection; const U: TUnidadDoc): Boolean;

{ Para cada documento de Docs (en el mismo orden) si esta eliminado. Una consulta por
  subserie. Mismo tratamiento de errores que DondeEstaEliminado. }
function ClavesEliminadas(Conn: TFDConnection;
  const Docs: array of TUnidadDoc): TArray<Boolean>;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Param, FireDAC.Stan.Error,
  UTransferidos;

const
  // Depuracion ejecutada y vigente: no cancelada, pasada la ejecucion (paso 4 -> 5).
  CONDICION_EJECUTADA = 'P.Tipo = ''D'' AND P.Estado <> ''X'' AND P.Paso >= 5';

function SqlEliminados: string;
begin
  Result := 'SELECT U.IdEstructura, U.id, U.codsubs, U.Codigodoc, U.fecha, U.version, ' +
    'P.IdProceso, P.Numero FROM prc_unidad U INNER JOIN prc_proceso P ON ' +
    'P.IdProceso = U.IdProceso WHERE ' + CONDICION_EJECUTADA + ' AND U.Activa <> 0';
end;

function SqlNoEliminado: string;
begin
  Result := 'NOT EXISTS (SELECT 1 FROM prc_unidad X INNER JOIN prc_proceso P ON ' +
    'P.IdProceso = X.IdProceso WHERE ' + CONDICION_EJECUTADA + ' AND X.Activa <> 0 AND ' +
    'X.IdEstructura = H.IdEstructura AND X.id = H.id AND X.codsubs = H.codsubs AND ' +
    'X.Codigodoc = H.Codigodoc AND X.fecha = H.fecha AND X.version = H.version)';
end;

function TextoEliminado(const Numero: string): string;
begin
  Result := 'Eliminado (' + Numero + ')';
end;

function BuscarEliminado(Conn: TFDConnection; const U: TUnidadDoc): string;
var
  Q: TFDQuery;
begin
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := SqlEliminados + ' AND U.IdEstructura = :est AND U.id = :id AND ' +
      'U.codsubs = :cs AND U.Codigodoc = :cd AND U.fecha = :f AND U.version = :v';
    Q.ParamByName('est').AsString := U.IdEstructura;
    Q.ParamByName('id').AsInteger := U.Id;
    Q.ParamByName('cs').AsString := U.CodSubs;
    Q.ParamByName('cd').AsString := U.CodigoDoc;
    Q.ParamByName('f').AsDateTime := U.Fecha;
    Q.ParamByName('v').AsString := U.Version;
    Q.Open;
    if not Q.Eof then
      Result := TextoEliminado(Trim(Q.FieldByName('Numero').AsString));
  finally
    Q.Free;
  end;
end;

function DondeEstaEliminado(Conn: TFDConnection; const U: TUnidadDoc): string;
begin
  try
    Result := BuscarEliminado(Conn, U);
  except
    on EFDDBEngineException do
      if TablasDeProcesosExisten(Conn) then
        raise
      else
        Result := '';
  end;
end;

function EstaEliminado(Conn: TFDConnection; const U: TUnidadDoc): Boolean;
begin
  Result := DondeEstaEliminado(Conn, U) <> '';
end;

function ClavesEliminadas(Conn: TFDConnection;
  const Docs: array of TUnidadDoc): TArray<Boolean>;
begin
  Result := ClavesSegunConsulta(Conn, SqlEliminados, Docs);
end;

end.
