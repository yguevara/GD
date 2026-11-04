unit UAlcanceDatos;

{ Carga el alcance de un usuario desde la base y lo convierte en un filtro SQL
  parametrizado (valido en SQL Server y en Access). Punto unico de la seguridad
  por alcance para el arbol y la busqueda de documentos. }

interface

uses
  System.SysUtils, System.Variants, FireDAC.Comp.Client, UAlcance;

type
  TParametroSql = record
    Nombre: string;
    Valor: Variant;
  end;

  TFiltroSql = record
    Condicion: string;
    Parametros: TArray<TParametroSql>;
  end;

const
  LIMITE_PARAMETROS = 1000;

{ Alcance = nil (modo Access) o administrador: el filtro es 1=1. El resultado
  de CargarAlcance es del llamador (libera tambien el arbol que carga). }
function CargarAlcance(Conn: TFDConnection; const Usuario: string;
  EsAdministrador: Boolean): TAlcanceUsuario;
function FiltroDocumentos(Alcance: TAlcanceUsuario;
  const AliasDocumentos: string): TFiltroSql;
function FiltroNodosArbol(Alcance: TAlcanceUsuario;
  const AliasArbol: string): TFiltroSql;
{ Como CargarAlcance, pero nunca lanza ni devuelve nil: si la carga falla,
  Error trae el mensaje y el alcance es el de "sin acceso" (el administrador
  conserva el acceso total para poder reparar). }
function CargarAlcanceSeguro(Conn: TFDConnection; const Usuario: string;
  EsAdministrador: Boolean; out Error: string): TAlcanceUsuario;
{ Asigna los parametros del filtro a una consulta cuyo SQL ya contiene la condicion. }
procedure AplicarParametros(Query: TFDQuery; const Filtro: TFiltroSql);

implementation

uses
  System.Generics.Collections, System.Generics.Defaults, Data.DB,
  FireDAC.Stan.Param;

const
  ROL_DIRECTOR = 3; // tb_rol.idrol de 'Director'

type
  { Reparte parametros con nombre; pasado el limite, los textos van como
    literales con el apostrofe doblado. }
  TConstructorParametros = class
  private
    FPrefijo: string;
    FParams: TList<TParametroSql>;
  public
    constructor Create(const APrefijo: string);
    destructor Destroy; override;
    function Texto(const Valor: string): string;
    function Parametros: TArray<TParametroSql>;
  end;

constructor TConstructorParametros.Create(const APrefijo: string);
begin
  inherited Create;
  FPrefijo := APrefijo;
  FParams := TList<TParametroSql>.Create;
end;

destructor TConstructorParametros.Destroy;
begin
  FParams.Free;
  inherited;
end;

function TConstructorParametros.Texto(const Valor: string): string;
var
  P: TParametroSql;
begin
  if FParams.Count >= LIMITE_PARAMETROS then
    Exit('''' + StringReplace(Valor, '''', '''''', [rfReplaceAll]) + '''');
  P.Nombre := FPrefijo + IntToStr(FParams.Count + 1);
  P.Valor := Valor;
  FParams.Add(P);
  Result := ':' + P.Nombre;
end;

function TConstructorParametros.Parametros: TArray<TParametroSql>;
begin
  Result := FParams.ToArray;
end;

function PrefijoAlias(const Alias: string): string;
var
  C: Char;
  I: Integer;
begin
  if Alias = '' then
    Exit('');
  for I := 1 to Length(Alias) do
  begin
    C := Alias[I];
    if not (((C >= 'a') and (C <= 'z')) or ((C >= 'A') and (C <= 'Z')) or
      (C = '_') or ((I > 1) and (C >= '0') and (C <= '9'))) then
      raise EArgumentException.Create('Alias de tabla invalido: ' + Alias);
  end;
  Result := Alias + '.';
end;

function CompararNodos(const A, B: TClaveNodo): Integer;
begin
  Result := CompareStr(NormalizaClave(A.IdEstructura), NormalizaClave(B.IdEstructura));
  if Result = 0 then
    Result := A.Id - B.Id;
end;

function CompararSubseries(const A, B: TSubserieAsignada): Integer;
begin
  Result := CompararNodos(A.Nodo, B.Nodo);
  if Result = 0 then
    Result := CompareStr(A.CodSubs, B.CodSubs);
end;

{ Un grupo por IdEstructura: (p.IdEstructura = x AND p.id IN (...)). El id
  nunca va solo, porque no es unico entre estructuras. }
function CondicionNodos(Constr: TConstructorParametros; const Pref: string;
  Nodos: TArray<TClaveNodo>): TArray<string>;
var
  Lista: TList<string>;
  I, J: Integer;
  Ids, IdEstr: string;
begin
  TArray.Sort<TClaveNodo>(Nodos, TComparer<TClaveNodo>.Construct(CompararNodos));
  Lista := TList<string>.Create;
  try
    I := 0;
    while I < Length(Nodos) do
    begin
      IdEstr := NormalizaClave(Nodos[I].IdEstructura);
      Ids := IntToStr(Nodos[I].Id);
      J := I + 1;
      while (J < Length(Nodos)) and
        (NormalizaClave(Nodos[J].IdEstructura) = IdEstr) do
      begin
        if Nodos[J].Id <> Nodos[J - 1].Id then
          Ids := Ids + ', ' + IntToStr(Nodos[J].Id);
        Inc(J);
      end;
      Lista.Add('(' + Pref + 'IdEstructura = ' + Constr.Texto(IdEstr) +
        ' AND ' + Pref + 'id IN (' + Ids + '))');
      I := J;
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

function Unir(const Partes: TArray<string>): string;
var
  I: Integer;
begin
  if Length(Partes) = 0 then
    Exit('1=0');
  Result := Partes[0];
  for I := 1 to High(Partes) do
    Result := Result + ' OR ' + Partes[I];
  if Length(Partes) > 1 then
    Result := '(' + Result + ')';
end;

function ListaIn(Constr: TConstructorParametros; const Codigos: TArray<string>): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(Codigos) do
  begin
    if I > 0 then
      Result := Result + ', ';
    Result := Result + Constr.Texto(Codigos[I]);
  end;
end;

function FiltroDocumentos(Alcance: TAlcanceUsuario;
  const AliasDocumentos: string): TFiltroSql;
var
  Pref, S: string;
  Constr: TConstructorParametros;
  Partes: TList<string>;
  Codigos, Publicas: TList<string>;
  Subs: TArray<TSubserieAsignada>;
  PubArr: TArray<string>;
  I, J: Integer;
begin
  Pref := PrefijoAlias(AliasDocumentos);
  Result.Parametros := nil;
  if (Alcance = nil) or Alcance.EsAdministrador then
  begin
    Result.Condicion := '1=1';
    Exit;
  end;
  Constr := TConstructorParametros.Create('alcd_');
  Partes := TList<string>.Create;
  Codigos := TList<string>.Create;
  Publicas := TList<string>.Create;
  try
    Partes.AddRange(CondicionNodos(Constr, Pref, Alcance.NodosCompletos));

    Subs := Alcance.SubseriesEfectivas;
    TArray.Sort<TSubserieAsignada>(Subs,
      TComparer<TSubserieAsignada>.Construct(CompararSubseries));
    I := 0;
    while I < Length(Subs) do
    begin
      Codigos.Clear;
      Codigos.Add(Subs[I].CodSubs);
      J := I + 1;
      while (J < Length(Subs)) and (CompararNodos(Subs[J].Nodo, Subs[I].Nodo) = 0) do
      begin
        if Subs[J].CodSubs <> Subs[J - 1].CodSubs then
          Codigos.Add(Subs[J].CodSubs);
        Inc(J);
      end;
      Partes.Add('(' + Pref + 'IdEstructura = ' + Constr.Texto(Subs[I].Nodo.IdEstructura) +
        ' AND ' + Pref + 'id = ' + IntToStr(Subs[I].Nodo.Id) +
        ' AND ' + Pref + 'codsubs IN (' + ListaIn(Constr, Codigos.ToArray) + '))');
      I := J;
    end;

    for S in Alcance.SubseriesPublicas do
      if (NormalizaClave(S) <> '') and not Publicas.Contains(NormalizaClave(S)) then
        Publicas.Add(NormalizaClave(S));
    if Publicas.Count > 0 then
    begin
      PubArr := Publicas.ToArray;
      TArray.Sort<string>(PubArr);
      Partes.Add('(' + Pref + 'codsubs IN (' + ListaIn(Constr, PubArr) + '))');
    end;

    Result.Condicion := Unir(Partes.ToArray);
    Result.Parametros := Constr.Parametros;
  finally
    Publicas.Free;
    Codigos.Free;
    Partes.Free;
    Constr.Free;
  end;
end;

function FiltroNodosArbol(Alcance: TAlcanceUsuario;
  const AliasArbol: string): TFiltroSql;
var
  Pref: string;
  Constr: TConstructorParametros;
begin
  Pref := PrefijoAlias(AliasArbol);
  Result.Parametros := nil;
  if (Alcance = nil) or Alcance.EsAdministrador then
  begin
    Result.Condicion := '1=1';
    Exit;
  end;
  Constr := TConstructorParametros.Create('alca_');
  try
    Result.Condicion := Unir(CondicionNodos(Constr, Pref, Alcance.NodosVisibles));
    Result.Parametros := Constr.Parametros;
  finally
    Constr.Free;
  end;
end;

{ Cada valor se enlaza con su tipo: una fecha, un numero o un booleano enviados
  como texto dependen del formato regional del cliente (dd/mm/yyyy) y del idioma
  del servidor, y en Access dan "no coinciden los tipos de datos". }
procedure AplicarParametros(Query: TFDQuery; const Filtro: TFiltroSql);
var
  P: TParametroSql;
  Par: TFDParam;
  Grande: Int64;
begin
  for P in Filtro.Parametros do
  begin
    Par := Query.ParamByName(P.Nombre);
    case VarType(P.Valor) and varTypeMask of
      varDate:
        Par.AsDateTime := VarToDateTime(P.Valor);
      varBoolean:
        Par.AsBoolean := Boolean(P.Valor);
      varShortInt, varSmallint, varInteger, varByte, varWord, varLongWord, varInt64:
        begin
          Grande := P.Valor;
          if (Grande >= Low(Integer)) and (Grande <= High(Integer)) then
            Par.AsInteger := Integer(Grande)
          else
            Par.AsLargeInt := Grande;
        end;
      varSingle, varDouble, varCurrency:
        Par.AsFloat := P.Valor;
    else
      Par.AsString := VarToStr(P.Valor);
    end;
  end;
end;

function CargarAlcance(Conn: TFDConnection; const Usuario: string;
  EsAdministrador: Boolean): TAlcanceUsuario;
var
  Arbol: TArbolNodos;
  Nodos: TList<TAsignacionNodo>;
  Subs: TList<TSubserieAsignada>;
  Publicas: TList<string>;
  ConPublica: TList<TClaveNodo>;
  Q: TFDQuery;
  U: string;
  A: TAsignacionNodo;
  S: TSubserieAsignada;

  procedure Abrir(const Sql: string; ConUsuario: Boolean);
  begin
    Q.Close;
    Q.SQL.Text := Sql;
    if ConUsuario then
      Q.ParamByName('u').AsString := U;
    Q.Open;
  end;

begin
  U := NormalizaClave(Usuario);
  Arbol := TArbolNodos.Create;
  Nodos := TList<TAsignacionNodo>.Create;
  Subs := TList<TSubserieAsignada>.Create;
  Publicas := TList<string>.Create;
  ConPublica := TList<TClaveNodo>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Abrir('SELECT IdEstructura, id, padre FROM tb_tree', False);
    while not Q.Eof do
    begin
      A.Nodo.IdEstructura := Q.Fields[0].AsString;
      A.Nodo.Id := Q.Fields[1].AsInteger;
      Arbol.Agregar(A.Nodo, Q.Fields[2].AsInteger); // padre NULL = 0 = raiz
      Q.Next;
    end;

    if not EsAdministrador then
    begin
      Abrir('SELECT d.IdEstructura, d.id FROM tb_tree_directors d ' +
        'INNER JOIN cl_Resp_Gest_Arch r ON r.Idresp = d.user_id ' +
        'WHERE d.idrol = ' + IntToStr(ROL_DIRECTOR) +
        ' AND {fn UCASE(r.usuario)} = :u', True);
      while not Q.Eof do
      begin
        A.Rol := rnDirector;
        A.Nodo.IdEstructura := Q.Fields[0].AsString;
        A.Nodo.Id := Q.Fields[1].AsInteger;
        Nodos.Add(A);
        Q.Next;
      end;

      Abrir('SELECT IdEstructura, id FROM tb_nodo_egd WHERE {fn UCASE(user_id)} = :u', True);
      while not Q.Eof do
      begin
        A.Rol := rnEGD;
        A.Nodo.IdEstructura := Q.Fields[0].AsString;
        A.Nodo.Id := Q.Fields[1].AsInteger;
        Nodos.Add(A);
        Q.Next;
      end;

      Abrir('SELECT IdEstructura, id, codsubs FROM tb_usuario_subserie ' +
        'WHERE {fn UCASE(user_id)} = :u', True);
      while not Q.Eof do
      begin
        S.Nodo.IdEstructura := Q.Fields[0].AsString;
        S.Nodo.Id := Q.Fields[1].AsInteger;
        S.CodSubs := Q.Fields[2].AsString;
        if NormalizaClave(S.CodSubs) <> '' then
          Subs.Add(S);
        Q.Next;
      end;

      Abrir('SELECT codsubs FROM cl_subseries WHERE acceso = 1', False);
      while not Q.Eof do
      begin
        Publicas.Add(Q.Fields[0].AsString);
        Q.Next;
      end;

      // nodos con alguna subserie publica: se ven en el arbol para llegar a ellas
      Abrir('SELECT DISTINCT st.IdEstructura, st.id FROM tb_Serietree st ' +
        'INNER JOIN cl_subseries s ON s.codsubs = st.codsubs WHERE s.acceso = 1', False);
      while not Q.Eof do
      begin
        A.Nodo.IdEstructura := Q.Fields[0].AsString;
        A.Nodo.Id := Q.Fields[1].AsInteger;
        ConPublica.Add(A.Nodo);
        Q.Next;
      end;
    end;

    Result := TAlcanceUsuario.Create(EsAdministrador, Arbol, Nodos.ToArray,
      Subs.ToArray, Publicas.ToArray);
    Result.PoseeArbol := True;
    Result.NodosConPublica := ConPublica.ToArray;
    Arbol := nil;
  finally
    Q.Free;
    ConPublica.Free;
    Publicas.Free;
    Subs.Free;
    Nodos.Free;
    Arbol.Free;
  end;
end;

function CargarAlcanceSeguro(Conn: TFDConnection; const Usuario: string;
  EsAdministrador: Boolean; out Error: string): TAlcanceUsuario;
begin
  Error := '';
  try
    Result := CargarAlcance(Conn, Usuario, EsAdministrador);
  except
    on E: Exception do
    begin
      Error := E.Message;
      Result := TAlcanceUsuario.Create(EsAdministrador, TArbolNodos.Create,
        nil, nil, nil);
      Result.PoseeArbol := True;
    end;
  end;
end;

end.
