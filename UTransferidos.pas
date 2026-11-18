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

{ False si la base no tiene las tablas de procesos (por ejemplo una base antigua):
  alli nada esta transferido. }
function TablasDeProcesosExisten(Conn: TFDConnection): Boolean;

{ '' si el documento no esta transferido; si lo esta, TextoTransferido. Solo la
  falta de las tablas de procesos cuenta como "no transferido": cualquier otro
  error de base se propaga. }
function DondeEstaTransferido(Conn: TFDConnection; const U: TUnidadDoc): string;

function EstaTransferido(Conn: TFDConnection; const U: TUnidadDoc): Boolean;

{ Para cada documento de Docs (en el mismo orden) si esta transferido. Una consulta
  por subserie, no por documento. Mismo tratamiento de errores que
  DondeEstaTransferido. }
function ClavesTransferidas(Conn: TFDConnection;
  const Docs: array of TUnidadDoc): TArray<Boolean>;

implementation

uses
  System.SysUtils, System.Generics.Collections, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Param, FireDAC.Stan.Error;

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

function TablasDeProcesosExisten(Conn: TFDConnection): Boolean;
begin
  try
    Conn.ExecSQLScalar('SELECT COUNT(*) FROM (prc_unidad U INNER JOIN prc_proceso P ON ' +
      'P.IdProceso = U.IdProceso) INNER JOIN prc_transferencia T ON T.IdProceso = ' +
      'P.IdProceso WHERE 1 = 0');
    Result := True;
  except
    on EFDDBEngineException do
      Result := False;
  end;
end;

function BuscarTransferido(Conn: TFDConnection; const U: TUnidadDoc): string;
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

function DondeEstaTransferido(Conn: TFDConnection; const U: TUnidadDoc): string;
begin
  try
    Result := BuscarTransferido(Conn, U);
  except
    on EFDDBEngineException do
      if TablasDeProcesosExisten(Conn) then
        raise
      else
        Result := '';
  end;
end;

function EstaTransferido(Conn: TFDConnection; const U: TUnidadDoc): Boolean;
begin
  Result := DondeEstaTransferido(Conn, U) <> '';
end;

{ Marca de un documento dentro de su subserie: codigo, fecha y version. }
function MarcaDeDocumento(const Codigo: string; Fecha: TDateTime;
  const Version: string): string;
begin
  Result := Trim(Codigo) + '|' + IntToStr(Trunc(Fecha)) + '|' + Trim(Version);
end;

procedure MarcarGrupo(Conn: TFDConnection; const Docs: array of TUnidadDoc;
  Indices: TList<Integer>; var Marcas: TArray<Boolean>);
var
  Q: TFDQuery;
  Hechas: TDictionary<string, Boolean>;
  I: Integer;
  Primera: TUnidadDoc;
begin
  Primera := Docs[Indices[0]];
  Hechas := TDictionary<string, Boolean>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := SqlTransferidos + ' AND U.IdEstructura = :est AND U.id = :id AND ' +
      'U.codsubs = :cs';
    Q.ParamByName('est').AsString := Primera.IdEstructura;
    Q.ParamByName('id').AsInteger := Primera.Id;
    Q.ParamByName('cs').AsString := Primera.CodSubs;
    Q.Open;
    while not Q.Eof do
    begin
      Hechas.AddOrSetValue(MarcaDeDocumento(Q.FieldByName('Codigodoc').AsString,
        Q.FieldByName('fecha').AsDateTime, Q.FieldByName('version').AsString), True);
      Q.Next;
    end;
    for I in Indices do
      Marcas[I] := Hechas.ContainsKey(MarcaDeDocumento(Docs[I].CodigoDoc, Docs[I].Fecha,
        Docs[I].Version));
  finally
    Q.Free;
    Hechas.Free;
  end;
end;

function ClavesTransferidas(Conn: TFDConnection;
  const Docs: array of TUnidadDoc): TArray<Boolean>;
var
  Grupos: TObjectDictionary<string, TList<Integer>>;
  Lista: TList<Integer>;
  I: Integer;
  Clave: string;
  Par: TPair<string, TList<Integer>>;
begin
  SetLength(Result, Length(Docs));
  for I := 0 to High(Result) do
    Result[I] := False;
  if Length(Docs) = 0 then
    Exit;
  Grupos := TObjectDictionary<string, TList<Integer>>.Create([doOwnsValues]);
  try
    for I := 0 to High(Docs) do
    begin
      Clave := Docs[I].IdEstructura + #1 + IntToStr(Docs[I].Id) + #1 + Docs[I].CodSubs;
      if not Grupos.TryGetValue(Clave, Lista) then
      begin
        Lista := TList<Integer>.Create;
        Grupos.Add(Clave, Lista);
      end;
      Lista.Add(I);
    end;
    try
      for Par in Grupos do
        MarcarGrupo(Conn, Docs, Par.Value, Result);
    except
      on EFDDBEngineException do
        if TablasDeProcesosExisten(Conn) then
          raise
        else
          for I := 0 to High(Result) do
            Result[I] := False;
    end;
  finally
    Grupos.Free;
  end;
end;

end.
