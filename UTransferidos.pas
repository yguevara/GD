unit UTransferidos;

{ ---------------------------------------------------------------------------
  Documentos TRANSFERIDOS: los que pasaron a un archivo central porque una
  transferencia FINALIZADA los incluyo (prc_unidad activa de un proceso tipo
  'T' en estado 'F'). Una caja faltante saca sus unidades (Activa = 0): esos
  documentos siguen en el origen y no cuentan.
  En el origen quedan solo en lectura: no se prestan, no se editan, no se
  vuelven a proponer. Sin VCL ni TUDM (RTL + FireDAC).
  Diseno: docs/superpowers/specs/2026-11-15-transferencias-f3-recepcion-
  ubicacion.md.
  --------------------------------------------------------------------------- }

interface

uses
  FireDAC.Comp.Client, UCandados;

{ Unidades de transferencias finalizadas: U.IdEstructura, U.id, U.codsubs,
  U.Codigodoc, U.fecha, U.version, P.IdProceso, P.Numero, T.IdArchivoDestino.
  Sin parametros: el llamador agrega su WHERE con AND. Valido en Access. }
function SqlTransferidos: string;

{ "Transferido al archivo X (T-2026-02)"; sin nombre de archivo,
  "Transferido (T-2026-02)". }
function TextoTransferido(const Numero, Archivo: string): string;

{ '' si el documento no esta transferido; si lo esta, TextoTransferido. }
function DondeEstaTransferido(Conn: TFDConnection; const U: TUnidadDoc): string;

function EstaTransferido(Conn: TFDConnection; const U: TUnidadDoc): Boolean;

implementation

uses
  System.SysUtils, FireDAC.Stan.Param;

function SqlTransferidos: string;
begin
  Result := 'SELECT U.IdEstructura, U.id, U.codsubs, U.Codigodoc, U.fecha, U.version, ' +
    'P.IdProceso, P.Numero, T.IdArchivoDestino FROM (prc_unidad U INNER JOIN prc_proceso P ' +
    'ON P.IdProceso = U.IdProceso) INNER JOIN prc_transferencia T ON ' +
    'T.IdProceso = P.IdProceso WHERE P.Tipo = ''T'' AND P.Estado = ''F'' AND U.Activa <> 0';
end;

function TextoTransferido(const Numero, Archivo: string): string;
begin
  if Trim(Archivo) = '' then
    Result := 'Transferido (' + Numero + ')'
  else
    Result := 'Transferido al archivo ' + Trim(Archivo) + ' (' + Numero + ')';
end;

function DondeEstaTransferido(Conn: TFDConnection; const U: TUnidadDoc): string;
var
  Q: TFDQuery;
  Numero, Archivo: string;
  Destino: Integer;
begin
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := SqlTransferidos + ' AND U.IdEstructura = :est AND U.id = :id AND ' +
      'U.codsubs = :cs AND U.Codigodoc = :cd AND U.fecha = :f AND U.version = :v';
    Q.ParamByName('est').AsString := U.IdEstructura;
    Q.ParamByName('id').AsInteger := U.Id;
    Q.ParamByName('cs').AsString := U.CodSubs;
    Q.ParamByName('cd').AsString := U.CodigoDoc;
    Q.ParamByName('f').AsDateTime := U.Fecha;
    Q.ParamByName('v').AsString := U.Version;
    Q.Open;
    if Q.Eof then
      Exit;
    Numero := Q.FieldByName('Numero').AsString;
    Destino := Q.FieldByName('IdArchivoDestino').AsInteger;
    Q.Close;
    Archivo := '';
    Q.SQL.Text := 'SELECT nombreArchivo FROM cl_ArchivosGestion WHERE Cod = :c';
    Q.ParamByName('c').AsInteger := Destino;
    Q.Open;
    if not Q.Eof then
      Archivo := Q.FieldByName('nombreArchivo').AsString;
    Result := TextoTransferido(Numero, Archivo);
  finally
    Q.Free;
  end;
end;

function EstaTransferido(Conn: TFDConnection; const U: TUnidadDoc): Boolean;
begin
  Result := DondeEstaTransferido(Conn, U) <> '';
end;

end.
