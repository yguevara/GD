unit UAsignacionDatos;

{ Asignacion de EGD y Directores a los nodos del arbol (solo SQL Server).
  Sin VCL: la pantalla UAsignacionNodos solo pinta; las reglas de que nodos se
  afectan y la escritura transaccional viven aqui para poder probarlas.

  Modelo: un EGD se guarda en tb_nodo_egd por nombre de usuario; un Director
  en tb_tree_directors por Idresp con idrol = 3. En esta unidad ambos se
  identifican por el login (cl_Resp_Gest_Arch.usuario). Las asignaciones
  "propias" son las filas escritas en el nodo; lo heredado del ancestro lo
  calcula la pantalla con el arbol y no se copia fila por fila. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance;

type
  TAsignacion = record
    Nodo: TClaveNodo;
    Rol: TRolNodo;      // rnEGD o rnDirector
    Usuario: string;    // login (cl_Resp_Gest_Arch.usuario / tb_user.nombreuser)
  end;

  TCambioAsignacion = record
    Asignacion: TAsignacion;
    Agregar: Boolean;   // False = quitar
  end;

{ Nodos marcados (y sus descendientes si IncluirHijos), sin duplicados y solo los
  que existen en el arbol. }
function NodosAfectados(Arbol: TArbolNodos; const Marcados: TArray<TClaveNodo>;
  IncluirHijos: Boolean): TArray<TClaveNodo>;

{ Un cambio por cada nodo afectado para el usuario y rol dados. }
function CalcularCambios(Arbol: TArbolNodos; const Marcados: TArray<TClaveNodo>;
  IncluirHijos: Boolean; Rol: TRolNodo; const Usuario: string;
  Agregar: Boolean): TArray<TCambioAsignacion>;

{ Asignaciones propias de todos los nodos (ambas tablas). }
function CargarAsignaciones(Conn: TFDConnection): TArray<TAsignacion>;

{ Aplica todos los cambios o ninguno. Agregar es idempotente (no duplica);
  el EGD crea su fila de tb_user si falta. Si ya hay una transaccion abierta en
  la conexion, la usa y no la cierra. }
procedure AplicarCambios(Conn: TFDConnection;
  const Cambios: TArray<TCambioAsignacion>);

{ Nodos del arbol sin ningun EGD propio (el heredado no cuenta). }
function NodosSinEGDPropio(Arbol: TArbolNodos;
  const Propias: TArray<TAsignacion>): TArray<TClaveNodo>;

{ Logins habilitados de cl_Resp_Gest_Arch, ordenados, sin los administradores
  (tienen acceso total y no se les asignan nodos). }
function UsuariosHabilitados(Conn: TFDConnection): TArray<string>;

implementation

uses
  System.Generics.Collections, System.Variants, Data.DB, FireDAC.Stan.Param;

const
  ROL_DIRECTOR = 3; // tb_rol.idrol de 'Director'
  ROL_ADMINISTRADOR = 1; // tb_rol.idrol de 'Administrador'

function ClaveTexto(const N: TClaveNodo): string;
begin
  Result := NormalizaClave(N.IdEstructura) + '|' + IntToStr(N.Id);
end;

function NodosAfectados(Arbol: TArbolNodos; const Marcados: TArray<TClaveNodo>;
  IncluirHijos: Boolean): TArray<TClaveNodo>;
var
  Vistos: TDictionary<string, Boolean>;
  Lista: TList<TClaveNodo>;
  M, T: TClaveNodo;
begin
  Vistos := TDictionary<string, Boolean>.Create;
  Lista := TList<TClaveNodo>.Create;
  try
    for M in Marcados do
    begin
      if not Arbol.Contiene(M) then
        Continue;
      if not Vistos.ContainsKey(ClaveTexto(M)) then
      begin
        Vistos.Add(ClaveTexto(M), True);
        Lista.Add(M);
      end;
      if IncluirHijos then
        for T in Arbol.Todos do
          if Arbol.EsDescendiente(M, T) and not Vistos.ContainsKey(ClaveTexto(T)) then
          begin
            Vistos.Add(ClaveTexto(T), True);
            Lista.Add(T);
          end;
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
    Vistos.Free;
  end;
end;

function CalcularCambios(Arbol: TArbolNodos; const Marcados: TArray<TClaveNodo>;
  IncluirHijos: Boolean; Rol: TRolNodo; const Usuario: string;
  Agregar: Boolean): TArray<TCambioAsignacion>;
var
  Nodos: TArray<TClaveNodo>;
  I: Integer;
begin
  if not (Rol in [rnEGD, rnDirector]) then
    raise Exception.Create('Solo se asignan los roles EGD y Director.');
  Nodos := NodosAfectados(Arbol, Marcados, IncluirHijos);
  SetLength(Result, Length(Nodos));
  for I := 0 to High(Nodos) do
  begin
    Result[I].Asignacion.Nodo := Nodos[I];
    Result[I].Asignacion.Rol := Rol;
    Result[I].Asignacion.Usuario := Usuario;
    Result[I].Agregar := Agregar;
  end;
end;

function CargarAsignaciones(Conn: TFDConnection): TArray<TAsignacion>;
var
  Q: TFDQuery;
  Lista: TList<TAsignacion>;
  A: TAsignacion;
begin
  Lista := TList<TAsignacion>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT IdEstructura, id, user_id FROM tb_nodo_egd';
    Q.Open;
    while not Q.Eof do
    begin
      A.Rol := rnEGD;
      A.Nodo.IdEstructura := Q.Fields[0].AsString;
      A.Nodo.Id := Q.Fields[1].AsInteger;
      A.Usuario := Q.Fields[2].AsString;
      Lista.Add(A);
      Q.Next;
    end;
    Q.Close;
    Q.SQL.Text := 'SELECT d.IdEstructura, d.id, r.usuario FROM tb_tree_directors d ' +
      'INNER JOIN cl_Resp_Gest_Arch r ON r.Idresp = d.user_id ' +
      'WHERE d.idrol = ' + IntToStr(ROL_DIRECTOR);
    Q.Open;
    while not Q.Eof do
    begin
      A.Rol := rnDirector;
      A.Nodo.IdEstructura := Q.Fields[0].AsString;
      A.Nodo.Id := Q.Fields[1].AsInteger;
      A.Usuario := Q.Fields[2].AsString;
      Lista.Add(A);
      Q.Next;
    end;
    Result := Lista.ToArray;
  finally
    Q.Free;
    Lista.Free;
  end;
end;

procedure AplicarCambios(Conn: TFDConnection;
  const Cambios: TArray<TCambioAsignacion>);
var
  Propia: Boolean;
  C: TCambioAsignacion;

  function Existe(const Sql: string; const Params: array of Variant): Boolean;
  begin
    Result := Integer(Conn.ExecSQLScalar(Sql, Params)) > 0;
  end;

  { Nombre tal como esta en tb_user (la clave foranea lo exige exacto); si no
    existe se crea. }
  function AsegurarUsuario(const Login: string): string;
  var
    V: Variant;
  begin
    V := Conn.ExecSQLScalar('SELECT TOP 1 nombreuser FROM tb_user ' +
      'WHERE {fn UCASE(nombreuser)} = {fn UCASE(:u)}', [Login]);
    if VarIsNull(V) or VarIsEmpty(V) then
    begin
      Conn.ExecSQL('INSERT INTO tb_user (nombreuser) VALUES (:u)', [Login]);
      Result := Login;
    end
    else
      Result := VarToStr(V);
  end;

  function IdResp(const Login: string): Integer;
  var
    V: Variant;
  begin
    V := Conn.ExecSQLScalar('SELECT TOP 1 Idresp FROM cl_Resp_Gest_Arch ' +
      'WHERE {fn UCASE(usuario)} = {fn UCASE(:u)}', [Login]);
    if VarIsNull(V) or VarIsEmpty(V) then
      raise Exception.Create('El usuario ' + Login + ' no esta en los responsables.');
    Result := Integer(V);
  end;

  procedure Aplicar(const Cambio: TCambioAsignacion);
  var
    A: TAsignacion;
    Nombre: string;
    Resp: Integer;
  begin
    A := Cambio.Asignacion;
    // el administrador ve y puede todo; sus permisos no se modifican desde aqui
    if Existe('SELECT COUNT(*) FROM cl_Resp_Gest_Arch WHERE Rol = ' +
      IntToStr(ROL_ADMINISTRADOR) + ' AND {fn UCASE(usuario)} = {fn UCASE(:u)}',
      [A.Usuario]) then
      raise Exception.CreateFmt('%s es administrador: tiene acceso a todos los ' +
        'nodos y sus permisos no se modifican.', [A.Usuario]);
    if not Existe('SELECT COUNT(*) FROM tb_tree WHERE IdEstructura = :a AND id = :b',
      [A.Nodo.IdEstructura, A.Nodo.Id]) then
      raise Exception.CreateFmt('El nodo %s (%d) no existe.',
        [A.Nodo.IdEstructura, A.Nodo.Id]);
    case A.Rol of
      rnEGD:
        if Cambio.Agregar then
        begin
          Nombre := AsegurarUsuario(A.Usuario);
          if not Existe('SELECT COUNT(*) FROM tb_nodo_egd WHERE IdEstructura = :a ' +
            'AND id = :b AND user_id = :c', [A.Nodo.IdEstructura, A.Nodo.Id, Nombre]) then
            Conn.ExecSQL('INSERT INTO tb_nodo_egd (IdEstructura, id, user_id) ' +
              'VALUES (:a, :b, :c)', [A.Nodo.IdEstructura, A.Nodo.Id, Nombre]);
        end
        else
          Conn.ExecSQL('DELETE FROM tb_nodo_egd WHERE IdEstructura = :a AND id = :b ' +
            'AND {fn UCASE(user_id)} = {fn UCASE(:c)}',
            [A.Nodo.IdEstructura, A.Nodo.Id, A.Usuario]);
      rnDirector:
        begin
          Resp := IdResp(A.Usuario);
          if Cambio.Agregar then
          begin
            // la clave de tb_tree_directors no incluye idrol: otra fila de la
            // misma persona en el nodo impediria el INSERT
            if Existe('SELECT COUNT(*) FROM tb_tree_directors WHERE IdEstructura = :a ' +
              'AND id = :b AND user_id = :c AND idrol <> ' + IntToStr(ROL_DIRECTOR),
              [A.Nodo.IdEstructura, A.Nodo.Id, Resp]) then
              raise Exception.CreateFmt('%s ya tiene otro rol en el nodo %s; ' +
                'qu'#237'telo antes de asignarlo como Director.',
                [A.Usuario, A.Nodo.IdEstructura]);
            if not Existe('SELECT COUNT(*) FROM tb_tree_directors WHERE IdEstructura = :a ' +
              'AND id = :b AND user_id = :c AND idrol = ' + IntToStr(ROL_DIRECTOR),
              [A.Nodo.IdEstructura, A.Nodo.Id, Resp]) then
              Conn.ExecSQL('INSERT INTO tb_tree_directors (IdEstructura, id, user_id, idrol) ' +
                'VALUES (:a, :b, :c, ' + IntToStr(ROL_DIRECTOR) + ')',
                [A.Nodo.IdEstructura, A.Nodo.Id, Resp]);
          end
          else
            Conn.ExecSQL('DELETE FROM tb_tree_directors WHERE IdEstructura = :a ' +
              'AND id = :b AND user_id = :c AND idrol = ' + IntToStr(ROL_DIRECTOR),
              [A.Nodo.IdEstructura, A.Nodo.Id, Resp]);
        end;
    else
      raise Exception.Create('Solo se asignan los roles EGD y Director.');
    end;
  end;

begin
  Propia := not Conn.InTransaction;
  if Propia then
    Conn.StartTransaction;
  try
    for C in Cambios do
      Aplicar(C);
    if Propia then
      Conn.Commit;
  except
    if Propia then
      Conn.Rollback;
    raise;
  end;
end;

function NodosSinEGDPropio(Arbol: TArbolNodos;
  const Propias: TArray<TAsignacion>): TArray<TClaveNodo>;
var
  ConEGD: TDictionary<string, Boolean>;
  Lista: TList<TClaveNodo>;
  P: TAsignacion;
  T: TClaveNodo;
begin
  ConEGD := TDictionary<string, Boolean>.Create;
  Lista := TList<TClaveNodo>.Create;
  try
    for P in Propias do
      if P.Rol = rnEGD then
        ConEGD.AddOrSetValue(ClaveTexto(P.Nodo), True);
    for T in Arbol.Todos do
      if not ConEGD.ContainsKey(ClaveTexto(T)) then
        Lista.Add(T);
    Result := Lista.ToArray;
  finally
    Lista.Free;
    ConEGD.Free;
  end;
end;

function UsuariosHabilitados(Conn: TFDConnection): TArray<string>;
var
  Q: TFDQuery;
  Lista: TList<string>;
begin
  Lista := TList<string>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT usuario FROM cl_Resp_Gest_Arch WHERE habilitado = ''S'' ' +
      'AND usuario IS NOT NULL AND Rol <> ' + IntToStr(ROL_ADMINISTRADOR) +
      ' ORDER BY usuario';
    Q.Open;
    while not Q.Eof do
    begin
      Lista.Add(Q.Fields[0].AsString);
      Q.Next;
    end;
    Result := Lista.ToArray;
  finally
    Q.Free;
    Lista.Free;
  end;
end;

end.
