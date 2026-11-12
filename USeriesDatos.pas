unit USeriesDatos;

{ ---------------------------------------------------------------------------
  Series y subseries documentales (cl_series, cl_subseries): listar, validar,
  guardar y eliminar. Solo RTL + FireDAC (sin VCL ni UDM); valido en SQL Server y
  Access. Codigo en ASCII.

  Guardar una subserie escribe solo los campos de TSubserie (identificacion,
  contenido, conservacion y ubicacion); el resto de las columnas de la fila
  (vigencia, detalle, nombre de la tabla de metadatos...) no se tocan. La
  observacion es texto enriquecido (RTF) y se lee y guarda aparte, como la
  descripcion de Archivos.

  Eliminar nunca borra datos ajenos: una serie con subseries, o una subserie
  que se usa en el arbol, en documentos, transferencias, prestamos u otras
  tablas, no se puede eliminar (EEnUso con el detalle). Una subserie sin uso se
  elimina con sus variables y con su tabla de datos si esta vacia.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UErroresCampo;

type
  TOpcionSerie = record
    Id: Integer;
    Texto: string;
  end;

  TCatalogoSerie = (csSoporte, csTipoDoc, csTipoSerie, csDestino, csFrecuencia, csAcceso, csArchivo);

  TSerie = record
    CodSerie: string;
    Serie: string;
  end;

  TSerieResumen = record
    CodSerie: string;
    Serie: string;
    NSubseries: Integer;
  end;

  TSubserie = record
    CodSerie: string;
    CodSubs: string;
    Nombre: string;
    IdTipoSerie: Integer;
    TipoDoc: Integer;
    Soporte: Integer;
    Acceso: Integer;
    Activa: Boolean;
    Gestion: Integer;       // anos en archivo de gestion
    Central: Integer;       // anos en archivo central
    Destino: Integer;
    Frecuencia: Integer;
    FechaAprobacion: TDateTime;   // 0 = sin fecha
    Archivo: Integer;       // cl_ArchivosGestion.Cod; 0 = ninguno
    Deposito: string;
    Gaveta: string;
    Carpeta: string;
  end;

  TSubserieResumen = record
    CodSerie: string;
    CodSubs: string;
    Nombre: string;
    TipoDoc: string;
    Soporte: string;
    NVariables: Integer;
    TieneTabla: Boolean;    // ya tiene documentos: sus variables solo admiten nuevas
    Activa: Boolean;
  end;

  ESerieInvalida = class(Exception);

  EEnUso = class(Exception)
  public
    Usos: Integer;
  end;

function ListarSeries(Conn: TFDConnection): TArray<TSerieResumen>;
{ CodSerie vacio = todas las subseries. }
function ListarSubseries(Conn: TFDConnection; const ACodSerie: string): TArray<TSubserieResumen>;
function LeerSubserie(Conn: TFDConnection; const ACodSubs: string): TSubserie;
function ExisteSubserie(Conn: TFDConnection; const ACodSubs: string): Boolean;
function ListarOpciones(Conn: TFDConnection; ACatalogo: TCatalogoSerie): TArray<TOpcionSerie>;

function ValidarSerie(const S: TSerie): TArray<TErrorCampo>;
function ValidarSubserie(const S: TSubserie): TArray<TErrorCampo>;

{ Alta (EsNueva) o edicion; valida y, si el codigo ya existe en un alta,
  ESerieInvalida. Una edicion cambia solo Serie / los campos de TSubserie. }
procedure GuardarSerie(Conn: TFDConnection; const S: TSerie; EsNueva: Boolean);
procedure GuardarSubserie(Conn: TFDConnection; const S: TSubserie; EsNueva: Boolean);

function LeerObservacion(Conn: TFDConnection; const ACodSubs: string): string;
procedure GuardarObservacion(Conn: TFDConnection; const ACodSubs, ATexto: string);

{ Cuantas subseries tiene la serie / cuantas filas usan la subserie. }
function ContarUsoSerie(Conn: TFDConnection; const ACodSerie: string): Integer;
function ContarUsoSubserie(Conn: TFDConnection; const ACodSubs: string): Integer;

procedure EliminarSerie(Conn: TFDConnection; const ACodSerie: string);
procedure EliminarSubserie(Conn: TFDConnection; const ACodSubs: string);

implementation

uses
  System.Classes, System.Generics.Collections, Data.DB, FireDAC.Stan.Param, FireDAC.Phys.Intf,
  UVariablesDatos;

const
  // tablas que referencian la subserie por codsubs y bloquean su baja
  TABLAS_USO: array[0..8] of string = ('tb_Serietree', 'tb_SeriesDatos', 'tb_transferencia',
    'TB_PrestamosDocumentos', 'tb_ssArchdigital', 'tb_DocCoord', 'cl_Subserirnodo',
    'tb_usuario_subserie', 'tb_regla_carpeta');

function Q(Conn: TFDConnection): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Conn;
end;

function ListarSeries(Conn: TFDConnection): TArray<TSerieResumen>;
var
  L: TList<TSerieResumen>;
  C: TFDQuery;
  R: TSerieResumen;
begin
  L := TList<TSerieResumen>.Create;
  try
    C := Q(Conn);
    try
      C.Open('SELECT S.codserie, S.serie, (SELECT COUNT(*) FROM cl_subseries X ' +
        'WHERE X.codserie = S.codserie) FROM cl_series S ORDER BY S.codserie');
      while not C.Eof do
      begin
        R.CodSerie := Trim(C.Fields[0].AsString);
        R.Serie := Trim(C.Fields[1].AsString);
        R.NSubseries := C.Fields[2].AsInteger;
        L.Add(R);
        C.Next;
      end;
    finally
      C.Free;
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function ListarSubseries(Conn: TFDConnection; const ACodSerie: string): TArray<TSubserieResumen>;
var
  L: TList<TSubserieResumen>;
  C: TFDQuery;
  R: TSubserieResumen;
  Tablas: TStringList;
  Guardada: string;
begin
  Tablas := TStringList.Create;
  L := TList<TSubserieResumen>.Create;
  try
    Tablas.CaseSensitive := False;
    Tablas.Sorted := True;
    Tablas.Duplicates := dupIgnore;
    try
      Conn.GetTableNames('', '', '', Tablas, [osMy], [tkTable], False);
    except
      Tablas.Clear;
    end;
    C := Q(Conn);
    try
      C.SQL.Text := 'SELECT C.codserie, C.codsubs, C.subserie, C.Activa, T.Tipodoc, ' +
        'P.Nombresoporte, C.NombreTablaMetadatos, (SELECT COUNT(*) FROM cl_VarSubserie V ' +
        'WHERE V.codsubs = C.codsubs) FROM (cl_subseries C LEFT JOIN cl_tipodoc T ' +
        'ON C.tipodoc = T.Idtipodoc) LEFT JOIN cl_soporte P ON C.soporte = P.Idsoporte ' +
        'WHERE (:s = '''' OR C.codserie = :s2) ORDER BY C.codserie, C.codsubs';
      C.ParamByName('s').AsString := ACodSerie;
      C.ParamByName('s2').AsString := ACodSerie;
      C.Open;
      while not C.Eof do
      begin
        R.CodSerie := Trim(C.Fields[0].AsString);
        R.CodSubs := Trim(C.Fields[1].AsString);
        R.Nombre := Trim(C.Fields[2].AsString);
        R.Activa := (not C.Fields[3].IsNull) and C.Fields[3].AsBoolean;
        R.TipoDoc := Trim(C.Fields[4].AsString);
        R.Soporte := Trim(C.Fields[5].AsString);
        Guardada := Trim(C.Fields[6].AsString);
        R.NVariables := C.Fields[7].AsInteger;
        R.TieneTabla := ((Guardada <> '') and (Tablas.IndexOf(Guardada) >= 0)) or
          (Tablas.IndexOf(NombreTablaDatos(R.CodSerie, R.CodSubs)) >= 0);
        L.Add(R);
        C.Next;
      end;
    finally
      C.Free;
    end;
    Result := L.ToArray;
  finally
    L.Free;
    Tablas.Free;
  end;
end;

function LeerSubserie(Conn: TFDConnection; const ACodSubs: string): TSubserie;
var
  C: TFDQuery;
begin
  Result := Default(TSubserie);
  C := Q(Conn);
  try
    C.SQL.Text := 'SELECT codserie, codsubs, subserie, idtiposerie, tipodoc, soporte, acceso, ' +
      'Activa, tgestion, tcentral, destino, frecuencia, fechaaprov, archivo, deposito, gaveta, ' +
      'carpeta FROM cl_subseries WHERE codsubs = :c';
    C.ParamByName('c').AsString := ACodSubs;
    C.Open;
    if C.IsEmpty then
      raise ESerieInvalida.Create('La subserie "' + ACodSubs + '" no existe.');
    Result.CodSerie := Trim(C.FieldByName('codserie').AsString);
    Result.CodSubs := Trim(C.FieldByName('codsubs').AsString);
    Result.Nombre := Trim(C.FieldByName('subserie').AsString);
    Result.IdTipoSerie := C.FieldByName('idtiposerie').AsInteger;
    Result.TipoDoc := C.FieldByName('tipodoc').AsInteger;
    Result.Soporte := C.FieldByName('soporte').AsInteger;
    Result.Acceso := C.FieldByName('acceso').AsInteger;
    Result.Activa := (not C.FieldByName('Activa').IsNull) and C.FieldByName('Activa').AsBoolean;
    Result.Gestion := C.FieldByName('tgestion').AsInteger;
    Result.Central := C.FieldByName('tcentral').AsInteger;
    Result.Destino := C.FieldByName('destino').AsInteger;
    Result.Frecuencia := C.FieldByName('frecuencia').AsInteger;
    if not C.FieldByName('fechaaprov').IsNull then
      Result.FechaAprobacion := C.FieldByName('fechaaprov').AsDateTime;
    Result.Archivo := C.FieldByName('archivo').AsInteger;
    Result.Deposito := Trim(C.FieldByName('deposito').AsString);
    Result.Gaveta := Trim(C.FieldByName('gaveta').AsString);
    Result.Carpeta := Trim(C.FieldByName('carpeta').AsString);
  finally
    C.Free;
  end;
end;

function ExisteSubserie(Conn: TFDConnection; const ACodSubs: string): Boolean;
var
  C: TFDQuery;
begin
  C := Q(Conn);
  try
    C.SQL.Text := 'SELECT COUNT(*) FROM cl_subseries WHERE codsubs = :c';
    C.ParamByName('c').AsString := ACodSubs;
    C.Open;
    Result := C.Fields[0].AsInteger > 0;
  finally
    C.Free;
  end;
end;

function ListarOpciones(Conn: TFDConnection; ACatalogo: TCatalogoSerie): TArray<TOpcionSerie>;
var
  L: TList<TOpcionSerie>;
  C: TFDQuery;
  O: TOpcionSerie;
  Sql: string;
begin
  case ACatalogo of
    csSoporte: Sql := 'SELECT Idsoporte, Nombresoporte FROM cl_soporte ORDER BY Idsoporte';
    csTipoDoc: Sql := 'SELECT Idtipodoc, Tipodoc FROM cl_tipodoc ORDER BY Idtipodoc';
    csTipoSerie: Sql := 'SELECT idtiposerie, tiposerie FROM cl_tiposerie ORDER BY idtiposerie';
    csDestino: Sql := 'SELECT IdDestino, NombreDestino FROM cl_destino ORDER BY IdDestino';
    csFrecuencia: Sql := 'SELECT Idfrecuencia, NombreFrecuencia FROM cl_frecuencia ORDER BY Idfrecuencia';
    csAcceso: Sql := 'SELECT Idacceso, NombreAcceso FROM cl_acceso ORDER BY Idacceso';
  else
    Sql := 'SELECT Cod, nombreArchivo FROM cl_ArchivosGestion ORDER BY Cod';
  end;
  L := TList<TOpcionSerie>.Create;
  try
    C := Q(Conn);
    try
      C.Open(Sql);
      while not C.Eof do
      begin
        O.Id := C.Fields[0].AsInteger;
        O.Texto := Trim(C.Fields[1].AsString);
        L.Add(O);
        C.Next;
      end;
    finally
      C.Free;
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

procedure AgregarError(L: TList<TErrorCampo>; const ACampo, AMensaje: string);
var
  E: TErrorCampo;
begin
  E.Campo := ACampo;
  E.Mensaje := AMensaje;
  L.Add(E);
end;

function ValidarSerie(const S: TSerie): TArray<TErrorCampo>;
var
  L: TList<TErrorCampo>;
begin
  L := TList<TErrorCampo>.Create;
  try
    if Trim(S.CodSerie) = '' then
      AgregarError(L, 'codserie', 'Indique el codigo de la serie.')
    else if Length(Trim(S.CodSerie)) > 50 then
      AgregarError(L, 'codserie', 'El codigo de la serie admite como maximo 50 caracteres.');
    if Trim(S.Serie) = '' then
      AgregarError(L, 'serie', 'Indique el nombre de la serie.')
    else if Length(Trim(S.Serie)) > 225 then
      AgregarError(L, 'serie', 'El nombre de la serie admite como maximo 225 caracteres.');
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function ValidarSubserie(const S: TSubserie): TArray<TErrorCampo>;
var
  L: TList<TErrorCampo>;
begin
  L := TList<TErrorCampo>.Create;
  try
    if Trim(S.CodSerie) = '' then
      AgregarError(L, 'codserie', 'Elija la serie a la que pertenece.');
    if Trim(S.CodSubs) = '' then
      AgregarError(L, 'codsubs', 'Indique el codigo de la subserie.')
    else if Length(Trim(S.CodSubs)) > 50 then
      AgregarError(L, 'codsubs', 'El codigo de la subserie admite como maximo 50 caracteres.');
    if Trim(S.Nombre) = '' then
      AgregarError(L, 'subserie', 'Indique el nombre de la subserie.')
    else if Length(Trim(S.Nombre)) > 255 then
      AgregarError(L, 'subserie', 'El nombre de la subserie admite como maximo 255 caracteres.');
    if (S.Gestion < 0) or (S.Gestion > 32767) then
      AgregarError(L, 'tgestion', 'Los anos en archivo de gestion deben estar entre 0 y 32767.');
    if (S.Central < 0) or (S.Central > 32767) then
      AgregarError(L, 'tcentral', 'Los anos en archivo central deben estar entre 0 y 32767.');
    if Length(S.Deposito) > 255 then
      AgregarError(L, 'deposito', 'El deposito admite como maximo 255 caracteres.');
    if Length(S.Gaveta) > 20 then
      AgregarError(L, 'gaveta', 'La gaveta admite como maximo 20 caracteres.');
    if Length(S.Carpeta) > 255 then
      AgregarError(L, 'carpeta', 'La carpeta admite como maximo 255 caracteres.');
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

procedure GuardarSerie(Conn: TFDConnection; const S: TSerie; EsNueva: Boolean);
var
  E: TArray<TErrorCampo>;
  C: TFDQuery;
begin
  E := ValidarSerie(S);
  if Length(E) > 0 then
    raise ESerieInvalida.Create(E[0].Mensaje);
  C := Q(Conn);
  try
    if EsNueva then
    begin
      C.SQL.Text := 'SELECT COUNT(*) FROM cl_series WHERE codserie = :c';
      C.ParamByName('c').AsString := Trim(S.CodSerie);
      C.Open;
      if C.Fields[0].AsInteger > 0 then
        raise ESerieInvalida.Create('Ya existe una serie con el codigo "' + Trim(S.CodSerie) + '".');
      C.Close;
      C.SQL.Text := 'INSERT INTO cl_series (codserie, serie) VALUES (:c, :s)';
    end
    else
      C.SQL.Text := 'UPDATE cl_series SET serie = :s WHERE codserie = :c';
    C.ParamByName('c').AsString := Trim(S.CodSerie);
    C.ParamByName('s').AsString := Trim(S.Serie);
    C.ExecSQL;
  finally
    C.Free;
  end;
end;

procedure PonerParametros(C: TFDQuery; const S: TSubserie);
begin
  C.ParamByName('cs').AsString := Trim(S.CodSerie);
  C.ParamByName('c').AsString := Trim(S.CodSubs);
  C.ParamByName('n').AsString := Trim(S.Nombre);
  C.ParamByName('its').AsInteger := S.IdTipoSerie;
  C.ParamByName('td').AsInteger := S.TipoDoc;
  C.ParamByName('so').AsInteger := S.Soporte;
  C.ParamByName('ac').AsInteger := S.Acceso;
  C.ParamByName('av').AsBoolean := S.Activa;
  C.ParamByName('tg').AsInteger := S.Gestion;
  C.ParamByName('tc').AsInteger := S.Central;
  C.ParamByName('de').AsInteger := S.Destino;
  C.ParamByName('fr').AsInteger := S.Frecuencia;
  C.ParamByName('fa').DataType := ftDateTime;
  if S.FechaAprobacion = 0 then
    C.ParamByName('fa').Clear
  else
    C.ParamByName('fa').AsDateTime := S.FechaAprobacion;
  C.ParamByName('ar').AsInteger := S.Archivo;
  C.ParamByName('dp').AsString := Trim(S.Deposito);
  C.ParamByName('ga').AsString := Trim(S.Gaveta);
  C.ParamByName('ca').AsString := Trim(S.Carpeta);
end;

procedure GuardarSubserie(Conn: TFDConnection; const S: TSubserie; EsNueva: Boolean);
var
  E: TArray<TErrorCampo>;
  C: TFDQuery;
begin
  E := ValidarSubserie(S);
  if Length(E) > 0 then
    raise ESerieInvalida.Create(E[0].Mensaje);
  if EsNueva and ExisteSubserie(Conn, Trim(S.CodSubs)) then
    raise ESerieInvalida.Create('Ya existe una subserie con el codigo "' + Trim(S.CodSubs) + '".');
  C := Q(Conn);
  try
    if EsNueva then
      C.SQL.Text := 'INSERT INTO cl_subseries (codserie, codsubs, subserie, idtiposerie, tipodoc, ' +
        'soporte, acceso, Activa, tgestion, tcentral, destino, frecuencia, fechaaprov, archivo, ' +
        'deposito, gaveta, carpeta, Detalle, Vigencia, ayear, pc, tiempo, cargo) VALUES ' +
        '(:cs, :c, :n, :its, :td, :so, :ac, :av, :tg, :tc, :de, :fr, :fa, :ar, :dp, :ga, :ca, ' +
        '0, 0, 0, 0, 0, 0)'
    else
      C.SQL.Text := 'UPDATE cl_subseries SET codserie = :cs, subserie = :n, idtiposerie = :its, ' +
        'tipodoc = :td, soporte = :so, acceso = :ac, Activa = :av, tgestion = :tg, tcentral = :tc, ' +
        'destino = :de, frecuencia = :fr, fechaaprov = :fa, archivo = :ar, deposito = :dp, ' +
        'gaveta = :ga, carpeta = :ca WHERE codsubs = :c';
    PonerParametros(C, S);
    C.ExecSQL;
  finally
    C.Free;
  end;
end;

function LeerObservacion(Conn: TFDConnection; const ACodSubs: string): string;
var
  C: TFDQuery;
begin
  Result := '';
  C := Q(Conn);
  try
    C.SQL.Text := 'SELECT observacion FROM cl_subseries WHERE codsubs = :c';
    C.ParamByName('c').AsString := ACodSubs;
    C.Open;
    if (not C.IsEmpty) and (not C.Fields[0].IsNull) then
      Result := C.Fields[0].AsString;
  finally
    C.Free;
  end;
end;

procedure GuardarObservacion(Conn: TFDConnection; const ACodSubs, ATexto: string);
var
  C: TFDQuery;
begin
  C := Q(Conn);
  try
    C.SQL.Text := 'UPDATE cl_subseries SET observacion = :o WHERE codsubs = :c';
    C.ParamByName('o').DataType := ftMemo;
    if ATexto = '' then
      C.ParamByName('o').Clear
    else
      C.ParamByName('o').AsString := ATexto;
    C.ParamByName('c').AsString := ACodSubs;
    C.ExecSQL;
  finally
    C.Free;
  end;
end;

function ContarUsoSerie(Conn: TFDConnection; const ACodSerie: string): Integer;
var
  C: TFDQuery;
begin
  C := Q(Conn);
  try
    C.SQL.Text := 'SELECT COUNT(*) FROM cl_subseries WHERE codserie = :c';
    C.ParamByName('c').AsString := ACodSerie;
    C.Open;
    Result := C.Fields[0].AsInteger;
  finally
    C.Free;
  end;
end;

function ContarUsoSubserie(Conn: TFDConnection; const ACodSubs: string): Integer;
var
  C: TFDQuery;
  T: string;
begin
  Result := 0;
  C := Q(Conn);
  try
    for T in TABLAS_USO do
    try
      C.Close;
      C.SQL.Text := 'SELECT COUNT(*) FROM ' + T + ' WHERE codsubs = :c';
      C.ParamByName('c').AsString := ACodSubs;
      C.Open;
      Inc(Result, C.Fields[0].AsInteger);
    except
      on EDatabaseError do
        ;   // la tabla no existe en esta base: no hay uso
    end;
  finally
    C.Free;
  end;
end;

procedure EliminarSerie(Conn: TFDConnection; const ACodSerie: string);
var
  N: Integer;
  E: EEnUso;
  C: TFDQuery;
begin
  N := ContarUsoSerie(Conn, ACodSerie);
  if N > 0 then
  begin
    E := EEnUso.Create('La serie "' + ACodSerie + '" tiene ' + IntToStr(N) +
      ' subserie(s). Elimine o mueva primero sus subseries.');
    E.Usos := N;
    raise E;
  end;
  C := Q(Conn);
  try
    C.SQL.Text := 'DELETE FROM cl_series WHERE codserie = :c';
    C.ParamByName('c').AsString := ACodSerie;
    C.ExecSQL;
  finally
    C.Free;
  end;
end;

procedure EliminarSubserie(Conn: TFDConnection; const ACodSubs: string);
var
  N: Integer;
  E: EEnUso;
  C: TFDQuery;
  S: TSubserie;
  Tabla: string;
begin
  N := ContarUsoSubserie(Conn, ACodSubs);
  if N > 0 then
  begin
    E := EEnUso.Create('La subserie "' + ACodSubs + '" se esta usando (' + IntToStr(N) +
      ' registro(s) en el arbol, los documentos u otras tablas) y no se puede eliminar.');
    E.Usos := N;
    raise E;
  end;
  S := LeerSubserie(Conn, ACodSubs);
  Tabla := TablaDatosActual(Conn, S.CodSerie, ACodSubs);
  C := Q(Conn);
  try
    Conn.StartTransaction;
    try
      C.SQL.Text := 'DELETE FROM cl_VarSubserie WHERE codsubs = :c';
      C.ParamByName('c').AsString := ACodSubs;
      C.ExecSQL;
      try
        C.SQL.Text := 'DELETE FROM cl_SubserieVariables WHERE codsubs = :c';
        C.ParamByName('c').AsString := ACodSubs;
        C.ExecSQL;
      except
        on EDatabaseError do
          ;   // esa tabla antigua no existe en esta base
      end;
      C.SQL.Text := 'DELETE FROM cl_subseries WHERE codsubs = :c';
      C.ParamByName('c').AsString := ACodSubs;
      C.ExecSQL;
      Conn.Commit;
    except
      Conn.Rollback;
      raise;
    end;
    if Tabla <> '' then
    try
      // sin documentos (se comprobo arriba): la tabla de datos esta vacia
      Conn.ExecSQL('DROP TABLE ' + Tabla);
    except
      on EDatabaseError do
        ;   // queda la tabla vacia; no afecta a nada
    end;
  finally
    C.Free;
  end;
end;

end.
