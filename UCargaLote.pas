unit UCargaLote;

{ Lote de carga: guarda varios candidatos, uno a uno (una operacion completa
  por documento), registra el lote en tb_lote_captura / tb_lote_captura_item
  para poder reintentar o retomar, y recuerda los ultimos valores usados por
  usuario y subserie (tb_carga_valores). Solo RTL + FireDAC, sin VCL ni UDM.
  Valido en SQL Server y en Access. Codigo en ASCII. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance, UAlmacenFicheros, UCargaModelo,
  UMetadatosSubserie, UCargaDocumento;

type
  TResumenLote = record
    Total, Guardados, Fallidos, Omitidos: Integer;
  end;

  TLotePendiente = record
    IdLote: Integer;
    Fecha: TDateTime;
    Origen, IdEstructura, CodSubs: string;
    Pendientes: Integer;
  end;

  TItemLote = record
    Orden: Integer;
    Archivo, Estado, Codigodoc, Error: string;
  end;

  TCargaLote = class
  private
    FConn: TFDConnection;
    FAlcance: TAlcanceUsuario;
    FOrigen: TOrigenDocumento;
    FAlmacen: IAlmacenFicheros;
    FCampos: TArray<TCampoMeta>;
    FTablaMeta: string;
    FIdLote: Integer;
    FItems: Integer;
    procedure CrearLote;
    procedure AsegurarItems(const Lote: TArray<TCandidato>);
    procedure ActualizarItem(Orden: Integer; const Estado, Codigo, Error: string);
    procedure CerrarSiTermino(const Lote: TArray<TCandidato>);
  public
    constructor Create(Conn: TFDConnection; Alcance: TAlcanceUsuario;
      const Origen: TOrigenDocumento; Almacen: IAlmacenFicheros;
      const Campos: TArray<TCampoMeta>; const TablaMeta: string);
    { Procesa los candidatos en ecListo o ecError. AlAvanzar(hecho, total, archivo)
      y Cancelar son opcionales; Cancelar se consulta antes de cada documento. }
    function Guardar(var Lote: TArray<TCandidato>; AlAvanzar: TProc<Integer, Integer, string>;
      Cancelar: TFunc<Boolean>): TResumenLote;
    { Sigue un lote guardado antes: no crea otro; Items = cuantos items tiene ya
      (todos los candidatos del lote retomado, en el mismo orden). }
    procedure Retomar(IdLote, Items: Integer);
    property IdLote: Integer read FIdLote;
  end;

{ Candidatos de un lote guardado, en su orden: guardado = ecGuardado; un archivo
  que ya no existe = ecError con el motivo; el resto = ecListo. Solo se
  recuperan archivo, codigo y error; titulo y datos propios hay que volver a
  completarlos. }
function CandidatosDeLote(const Items: TArray<TItemLote>): TArray<TCandidato>;
{ Marca el lote como descartado: ya no se ofrece retomarlo. }
procedure DescartarLote(Conn: TFDConnection; IdLote: Integer);

function LotesPendientes(Conn: TFDConnection; const Usuario: string): TArray<TLotePendiente>;
function CargarItems(Conn: TFDConnection; IdLote: Integer): TArray<TItemLote>;
procedure GuardarUltimosValores(Conn: TFDConnection; const Usuario, CodSubs: string;
  const Valores: TArray<TValorMeta>);
function LeerUltimosValores(Conn: TFDConnection; const Usuario, CodSubs: string): TArray<TValorMeta>;

implementation

uses
  System.Variants, Data.DB, FireDAC.Stan.Param;

constructor TCargaLote.Create(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; Almacen: IAlmacenFicheros;
  const Campos: TArray<TCampoMeta>; const TablaMeta: string);
begin
  inherited Create;
  FConn := Conn;
  FAlcance := Alcance;
  FOrigen := Origen;
  FAlmacen := Almacen;
  FCampos := Campos;
  FTablaMeta := TablaMeta;
end;

procedure TCargaLote.Retomar(IdLote, Items: Integer);
begin
  FIdLote := IdLote;
  FItems := Items;
end;

function CandidatosDeLote(const Items: TArray<TItemLote>): TArray<TCandidato>;
var
  I: Integer;
  C: TCandidato;
begin
  SetLength(Result, Length(Items));
  for I := 0 to High(Items) do
  begin
    C := Default(TCandidato);
    C.Archivo := Items[I].Archivo;
    C.Titulo := TituloDesdeNombre(Items[I].Archivo);
    C.Codigo := Items[I].Codigodoc;
    C.Fecha := Date;
    if SameText(Items[I].Estado, 'guardado') then
      C.Estado := ecGuardado
    else if not FileExists(Items[I].Archivo) then
    begin
      C.Estado := ecError;
      C.Error := 'No se encuentra el archivo.';
    end
    else
    begin
      C.Estado := ecListo;
      if SameText(Items[I].Estado, 'error') then
        C.Error := Items[I].Error;
    end;
    Result[I] := C;
  end;
end;

procedure DescartarLote(Conn: TFDConnection; IdLote: Integer);
begin
  Conn.ExecSQL('UPDATE tb_lote_captura SET estado = ''descartado'' WHERE idlote = :l', [IdLote]);
end;

procedure TCargaLote.CrearLote;
var
  Q: TFDQuery;
  V: Variant;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'INSERT INTO tb_lote_captura (fecha, user_id, origen, estado, ' +
      'IdEstructura, id, codsubs) VALUES (:f, :u, :o, :e, :a, :b, :c)';
    Q.ParamByName('f').AsDateTime := Now;
    Q.ParamByName('u').AsString := FOrigen.Usuario;
    Q.ParamByName('o').AsString := 'Agregar documentos';
    Q.ParamByName('e').AsString := 'abierto';
    Q.ParamByName('a').AsString := FOrigen.IdEstructura;
    Q.ParamByName('b').AsInteger := FOrigen.Id;
    Q.ParamByName('c').AsString := FOrigen.CodSubs;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
  FIdLote := 0;
  try
    V := FConn.GetLastAutoGenValue('');
    if not (VarIsNull(V) or VarIsEmpty(V)) then
      FIdLote := Integer(V);
  except
    FIdLote := 0;
  end;
  if FIdLote <= 0 then
  begin
    V := FConn.ExecSQLScalar('SELECT MAX(idlote) FROM tb_lote_captura WHERE user_id = :u',
      [FOrigen.Usuario]);
    if not (VarIsNull(V) or VarIsEmpty(V)) then
      FIdLote := Integer(V);
  end;
end;

procedure TCargaLote.AsegurarItems(const Lote: TArray<TCandidato>);
var
  I: Integer;
  Q: TFDQuery;
begin
  if FIdLote = 0 then
    CrearLote;
  if FItems >= Length(Lote) then
    Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'INSERT INTO tb_lote_captura_item (idlote, orden, archivo, estado) ' +
      'VALUES (:l, :o, :a, :e)';
    for I := FItems to High(Lote) do
    begin
      Q.ParamByName('l').AsInteger := FIdLote;
      Q.ParamByName('o').AsInteger := I + 1;
      Q.ParamByName('a').AsString := Copy(Lote[I].Archivo, 1, 500);
      Q.ParamByName('e').AsString := 'espera';
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
  FItems := Length(Lote);
end;

procedure TCargaLote.ActualizarItem(Orden: Integer; const Estado, Codigo, Error: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'UPDATE tb_lote_captura_item SET estado = :e, Codigodoc = :c, error = :r ' +
      'WHERE idlote = :l AND orden = :o';
    Q.ParamByName('e').AsString := Estado;
    Q.ParamByName('c').AsString := Copy(Codigo, 1, 20);
    Q.ParamByName('r').AsString := Copy(Error, 1, 500);
    Q.ParamByName('l').AsInteger := FIdLote;
    Q.ParamByName('o').AsInteger := Orden;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TCargaLote.CerrarSiTermino(const Lote: TArray<TCandidato>);
var
  I: Integer;
  Todos: Boolean;
begin
  Todos := True;
  for I := 0 to High(Lote) do
    if Lote[I].Estado <> ecGuardado then
      Todos := False;
  if Todos then
    FConn.ExecSQL('UPDATE tb_lote_captura SET estado = ''cerrado'' WHERE idlote = :l', [FIdLote])
  else
    FConn.ExecSQL('UPDATE tb_lote_captura SET estado = ''abierto'' WHERE idlote = :l', [FIdLote]);
end;

function TCargaLote.Guardar(var Lote: TArray<TCandidato>; AlAvanzar: TProc<Integer, Integer, string>;
  Cancelar: TFunc<Boolean>): TResumenLote;
var
  I, Hechos, Procesables: Integer;
  R: TResultadoDocumento;
  Cancelado: Boolean;
begin
  Result := Default(TResumenLote);
  Result.Total := Length(Lote);
  if Length(Lote) = 0 then
    Exit;
  AsegurarItems(Lote);
  Procesables := 0;
  for I := 0 to High(Lote) do
    if Lote[I].Estado in [ecListo, ecError] then
      Inc(Procesables)
    else if Lote[I].Estado = ecFalta then
      ActualizarItem(I + 1, 'falta', Lote[I].Codigo, '');
  Hechos := 0;
  Cancelado := False;
  for I := 0 to High(Lote) do
  begin
    if not (Lote[I].Estado in [ecListo, ecError]) then
    begin
      if Lote[I].Estado <> ecGuardado then
        Inc(Result.Omitidos);
      Continue;
    end;
    if Cancelado or (Assigned(Cancelar) and Cancelar()) then
    begin
      Cancelado := True;
      Inc(Result.Omitidos);
      Continue;
    end;
    Lote[I].Estado := ecSubiendo;
    R := GuardarDocumento(FConn, FAlcance, FOrigen, FAlmacen, Lote[I], FCampos, FTablaMeta, nil);
    Inc(Hechos);
    if R.Guardado then
    begin
      Lote[I].Estado := ecGuardado;
      Lote[I].Codigo := R.Codigodoc;
      Lote[I].Error := '';
      Inc(Result.Guardados);
      ActualizarItem(I + 1, 'guardado', R.Codigodoc, '');
    end
    else
    begin
      Lote[I].Estado := ecError;
      Lote[I].Error := R.Mensaje;
      Inc(Result.Fallidos);
      ActualizarItem(I + 1, 'error', Lote[I].Codigo, R.Mensaje);
    end;
    if Assigned(AlAvanzar) then
      AlAvanzar(Hechos, Procesables, ExtractFileName(Lote[I].Archivo));
  end;
  CerrarSiTermino(Lote);
end;

function LotesPendientes(Conn: TFDConnection; const Usuario: string): TArray<TLotePendiente>;
var
  Q: TFDQuery;
  N: Integer;
  L: TLotePendiente;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT idlote, fecha, origen, IdEstructura, codsubs FROM tb_lote_captura ' +
      'WHERE user_id = :u AND estado = ''abierto'' ORDER BY idlote';
    Q.ParamByName('u').AsString := Usuario;
    Q.Open;
    N := 0;
    while not Q.Eof do
    begin
      L.IdLote := Q.FieldByName('idlote').AsInteger;
      L.Fecha := Q.FieldByName('fecha').AsDateTime;
      L.Origen := Q.FieldByName('origen').AsString;
      L.IdEstructura := Q.FieldByName('IdEstructura').AsString;
      L.CodSubs := Q.FieldByName('codsubs').AsString;
      L.Pendientes := Integer(Conn.ExecSQLScalar(
        'SELECT COUNT(*) FROM tb_lote_captura_item WHERE idlote = :l AND estado <> ''guardado''',
        [L.IdLote]));
      SetLength(Result, N + 1);
      Result[N] := L;
      Inc(N);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function CargarItems(Conn: TFDConnection; IdLote: Integer): TArray<TItemLote>;
var
  Q: TFDQuery;
  N: Integer;
  It: TItemLote;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT orden, archivo, estado, Codigodoc, error FROM tb_lote_captura_item ' +
      'WHERE idlote = :l ORDER BY orden';
    Q.ParamByName('l').AsInteger := IdLote;
    Q.Open;
    N := 0;
    while not Q.Eof do
    begin
      It.Orden := Q.FieldByName('orden').AsInteger;
      It.Archivo := Q.FieldByName('archivo').AsString;
      It.Estado := Q.FieldByName('estado').AsString;
      It.Codigodoc := Q.FieldByName('Codigodoc').AsString;
      It.Error := Q.FieldByName('error').AsString;
      SetLength(Result, N + 1);
      Result[N] := It;
      Inc(N);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure GuardarUltimosValores(Conn: TFDConnection; const Usuario, CodSubs: string;
  const Valores: TArray<TValorMeta>);
var
  I: Integer;
  Propia: Boolean;
  Q: TFDQuery;
begin
  Propia := not Conn.InTransaction;
  if Propia then
    Conn.StartTransaction;
  try
    Conn.ExecSQL('DELETE FROM tb_carga_valores WHERE user_id = :u AND codsubs = :c',
      [Usuario, CodSubs]);
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := 'INSERT INTO tb_carga_valores (user_id, codsubs, campo, valor) ' +
        'VALUES (:u, :c, :k, :v)';
      for I := 0 to High(Valores) do
      begin
        Q.ParamByName('u').AsString := Usuario;
        Q.ParamByName('c').AsString := CodSubs;
        Q.ParamByName('k').AsString := Copy(Valores[I].Nombre, 1, 100);
        Q.ParamByName('v').AsString := Copy(Valores[I].Valor, 1, 255);
        Q.ExecSQL;
      end;
    finally
      Q.Free;
    end;
    if Propia then
      Conn.Commit;
  except
    if Propia and Conn.InTransaction then
      Conn.Rollback;
    raise;
  end;
end;

function LeerUltimosValores(Conn: TFDConnection; const Usuario, CodSubs: string): TArray<TValorMeta>;
var
  Q: TFDQuery;
  N: Integer;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT campo, valor FROM tb_carga_valores WHERE user_id = :u AND ' +
      'codsubs = :c ORDER BY campo';
    Q.ParamByName('u').AsString := Usuario;
    Q.ParamByName('c').AsString := CodSubs;
    Q.Open;
    N := 0;
    while not Q.Eof do
    begin
      SetLength(Result, N + 1);
      Result[N].Nombre := Q.FieldByName('campo').AsString;
      Result[N].Valor := Q.FieldByName('valor').AsString;
      Inc(N);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

end.
