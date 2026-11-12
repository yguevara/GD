unit UVariablesDatos;

{ ---------------------------------------------------------------------------
  Variables del formulario de una subserie (cl_VarSubserie) y su columna en la
  tabla de datos md_*. Solo RTL + FireDAC (sin VCL ni UDM); valido en SQL Server
  y Access. Codigo en ASCII.

  Regla (decision del usuario):
    - Subserie SIN tabla de datos: edicion libre.
    - Subserie CON tabla de datos (ya hay documentos): solo se pueden AGREGAR
      variables (ALTER TABLE ADD COLUMN; los documentos viejos quedan en NULL) y
      cambiar de las existentes Etiqueta, descripcion, obligatorio y Orden.
      Nombre, tipo, longitud y quitar quedan bloqueados.

  Un guardado que falla no deja nada a medias: en SQL Server todo va en una
  transaccion (el DDL tambien); en Access, que no deshace el DDL, las columnas
  agregadas se quitan al fallar.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UMetadatosSubserie, UErroresCampo;

type
  EVariables = class(Exception);

  TModoVariables = (mvLibre, mvSoloAnadir);

const
  LONGITUD_MAX_NOMBRE = 30;
  LONGITUD_MAX_TEXTO = 8000;

{ Nombre que la aplicacion da a la tabla de datos de una subserie: 'md_' mas
  serie y subserie, con '_' en lugar de lo que no sea letra o digito. }
function NombreTablaDatos(const CodSerie, CodSubs: string): string;

{ Tabla de datos que existe de verdad para la subserie, o '' si no hay ninguna.
  Se mira primero cl_subseries.NombreTablaMetadatos y luego el nombre calculado;
  un nombre guardado cuya tabla ya no existe cuenta como "sin tabla". }
function TablaDatosActual(Conn: TFDConnection; const CodSerie, CodSubs: string): string;

function ModoVariables(Conn: TFDConnection; const CodSerie, CodSubs: string): TModoVariables;

{ Tipo de columna SQL de una variable, segun el motor. }
function SqlTipoColumna(Tipo: TTipoMeta; Longitud: Integer; EsSqlServer: Boolean): string;

{ Validacion de la lista completa (sin tocar la base). Campo de cada error =
  '<nombre>.<propiedad>' (nombre, etiqueta, longitud). Las variables cuyo nombre
  esta en Existentes ya existian: no se les exige la sintaxis ni que no sea
  reservado (pueden venir de datos antiguos). }
function ValidarVariables(const Lista: TArray<TCampoMeta>; EsSqlServer: Boolean): TArray<TErrorCampo>; overload;
function ValidarVariables(const Lista: TArray<TCampoMeta>; EsSqlServer: Boolean;
  const Existentes: TArray<string>): TArray<TErrorCampo>; overload;

{ Reemplaza las variables de la subserie por Lista (Orden se renumera 1..n en el
  orden recibido) y, si la subserie ya tiene tabla, agrega las columnas de las
  nuevas. EVariables con el mensaje en espanol si algo no vale; en ese caso no
  queda nada escrito. }
procedure GuardarVariables(Conn: TFDConnection; EsSqlServer: Boolean;
  const CodSerie, CodSubs: string; const Lista: TArray<TCampoMeta>);

implementation

uses
  System.Classes, System.Generics.Collections, Data.DB, FireDAC.Stan.Param,
  UPalabrasReservadas;

const
  COLUMNAS_BASE: array[0..5] of string =
    ('IdEstructura', 'id', 'codsubs', 'Fecha', 'Version', 'Codigodoc');

function Clave(const S: string): string;
begin
  Result := LowerCase(Trim(S));
end;

function NombreSeguro(const S: string): Boolean;
var
  I: Integer;
begin
  Result := S <> '';
  for I := 1 to Length(S) do
    if not CharInSet(S[I], ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
      Exit(False);
end;

function NombreTablaDatos(const CodSerie, CodSubs: string): string;
var
  I: Integer;
  T: string;
begin
  T := 'md_' + CodSerie + CodSubs;
  Result := '';
  for I := 1 to Length(T) do
    if CharInSet(T[I], ['A'..'Z', 'a'..'z', '0'..'9']) then
      Result := Result + T[I]
    else
      Result := Result + '_';
end;

function TablaExiste(Conn: TFDConnection; const ATabla: string): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  if not NombreSeguro(ATabla) then
    Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    try
      Q.Open('SELECT * FROM ' + ATabla + ' WHERE 1 = 0');
      Result := True;
    except
      on EDatabaseError do
        Result := False;
    end;
  finally
    Q.Free;
  end;
end;

function TablaDatosActual(Conn: TFDConnection; const CodSerie, CodSubs: string): string;
var
  Guardada: string;
begin
  Guardada := NombreTablaMeta(Conn, CodSubs);
  if (Guardada <> '') and TablaExiste(Conn, Guardada) then
    Exit(Guardada);
  Result := NombreTablaDatos(CodSerie, CodSubs);
  if not TablaExiste(Conn, Result) then
    Result := '';
end;

function ModoVariables(Conn: TFDConnection; const CodSerie, CodSubs: string): TModoVariables;
begin
  if TablaDatosActual(Conn, CodSerie, CodSubs) <> '' then
    Result := mvSoloAnadir
  else
    Result := mvLibre;
end;

function SqlTipoColumna(Tipo: TTipoMeta; Longitud: Integer; EsSqlServer: Boolean): string;
begin
  case Tipo of
    tmFecha:
      if EsSqlServer then Result := 'DATETIME2' else Result := 'DATETIME';
    tmTexto:
      if (Longitud > 0) and (EsSqlServer or (Longitud <= 255)) then
        Result := 'VARCHAR(' + IntToStr(Longitud) + ')'
      else if EsSqlServer then
        Result := 'VARCHAR(MAX)'
      else
        Result := 'LONGTEXT';
    tmEntero: Result := 'INT';
    tmMemo:
      if EsSqlServer then Result := 'VARCHAR(MAX)' else Result := 'LONGTEXT';
    tmReal: Result := 'DECIMAL(18, 6)';
  else
    if EsSqlServer then Result := 'BIT' else Result := 'YESNO';
  end;
end;

function EsColumnaBase(const Nombre: string): Boolean;
var
  B: string;
begin
  for B in COLUMNAS_BASE do
    if Clave(B) = Clave(Nombre) then
      Exit(True);
  Result := False;
end;

function NombreEnLista(const Nombre: string; const Lista: TArray<string>): Boolean;
var
  S: string;
begin
  for S in Lista do
    if Clave(S) = Clave(Nombre) then
      Exit(True);
  Result := False;
end;

function ValidarVariables(const Lista: TArray<TCampoMeta>; EsSqlServer: Boolean): TArray<TErrorCampo>;
begin
  Result := ValidarVariables(Lista, EsSqlServer, nil);
end;

function ValidarVariables(const Lista: TArray<TCampoMeta>; EsSqlServer: Boolean;
  const Existentes: TArray<string>): TArray<TErrorCampo>;
var
  L: TList<TErrorCampo>;
  I, J: Integer;
  V: TCampoMeta;

  procedure Err(const ACampo, AMensaje: string);
  var
    E: TErrorCampo;
  begin
    E.Campo := ACampo;
    E.Mensaje := AMensaje;
    L.Add(E);
  end;

begin
  L := TList<TErrorCampo>.Create;
  try
    for I := 0 to High(Lista) do
    begin
      V := Lista[I];
      if Trim(V.Nombre) = '' then
      begin
        Err('#' + IntToStr(I + 1) + '.nombre', 'La variable ' + IntToStr(I + 1) + ' no tiene nombre.');
        Continue;
      end;
      if not NombreEnLista(V.Nombre, Existentes) then
      begin
        if (not NombreSeguro(Trim(V.Nombre))) or (Length(Trim(V.Nombre)) > LONGITUD_MAX_NOMBRE) or
          (not CharInSet(Trim(V.Nombre)[1], ['A'..'Z', 'a'..'z'])) then
          Err(V.Nombre + '.nombre', 'El nombre "' + V.Nombre + '" no es valido: use letras, ' +
            'digitos y guion bajo, empiece por una letra y tenga como maximo ' +
            IntToStr(LONGITUD_MAX_NOMBRE) + ' caracteres.')
        else if EsColumnaBase(V.Nombre) then
          Err(V.Nombre + '.nombre', 'El nombre "' + V.Nombre + '" lo usa el sistema en la ' +
            'tabla de datos. Elija otro.')
        else if EsPalabraReservada(V.Nombre, EsSqlServer) then
          Err(V.Nombre + '.nombre', 'El nombre "' + V.Nombre + '" es una palabra reservada del ' +
            'gestor de base de datos. Elija otro.');
      end;
      for J := 0 to I - 1 do
      begin
        if Clave(Lista[J].Nombre) = Clave(V.Nombre) then
          Err(V.Nombre + '.nombre', 'El nombre "' + V.Nombre + '" esta repetido.');
        if (Trim(V.Etiqueta) <> '') and (Clave(Lista[J].Etiqueta) = Clave(V.Etiqueta)) then
          Err(V.Nombre + '.etiqueta', 'La etiqueta "' + V.Etiqueta + '" esta repetida.');
      end;
      if Trim(V.Etiqueta) = '' then
        Err(V.Nombre + '.etiqueta', 'La variable "' + V.Nombre + '" necesita una etiqueta.');
      if (V.Tipo = tmTexto) and ((V.Longitud < 1) or (V.Longitud > LONGITUD_MAX_TEXTO)) then
        Err(V.Nombre + '.longitud', 'La variable "' + V.Nombre + '" es de tipo Caracteres: indique ' +
          'una longitud entre 1 y ' + IntToStr(LONGITUD_MAX_TEXTO) + '.');
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function IdTipo(Tipo: TTipoMeta): Integer;
begin
  case Tipo of
    tmFecha: Result := 2;
    tmEntero: Result := 3;
    tmMemo: Result := 4;
    tmReal: Result := 5;
    tmBooleano: Result := 6;
  else
    Result := 1;
  end;
end;

function LongitudEfectiva(const V: TCampoMeta): Integer;
begin
  if V.Tipo = tmTexto then
    Result := V.Longitud
  else
    Result := 0;
end;

function Buscar(const Lista: TArray<TCampoMeta>; const Nombre: string): Integer;
var
  I: Integer;
begin
  for I := 0 to High(Lista) do
    if Clave(Lista[I].Nombre) = Clave(Nombre) then
      Exit(I);
  Result := -1;
end;

procedure EscribirDefiniciones(Conn: TFDConnection; const CodSerie, CodSubs: string;
  const Lista: TArray<TCampoMeta>);
var
  Q: TFDQuery;
  Esquema: TFDQuery;
  ConDescripcion, ConObligatorio: Boolean;
  Sql, Cols, Vals: string;
  I: Integer;
begin
  Esquema := TFDQuery.Create(nil);
  try
    Esquema.Connection := Conn;
    Esquema.Open('SELECT * FROM cl_VarSubserie WHERE 1 = 0');
    ConDescripcion := Esquema.FindField('descripcion') <> nil;
    ConObligatorio := Esquema.FindField('obligatorio') <> nil;
  finally
    Esquema.Free;
  end;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'DELETE FROM cl_VarSubserie WHERE codserie = :s AND codsubs = :c';
    Q.ParamByName('s').AsString := CodSerie;
    Q.ParamByName('c').AsString := CodSubs;
    Q.ExecSQL;
    Cols := 'codserie, codsubs, Orden, NomVariable, Etiqueta, tipo, longitud';
    Vals := ':s, :c, :o, :n, :e, :t, :l';
    if ConDescripcion then
    begin
      Cols := Cols + ', descripcion';
      Vals := Vals + ', :d';
    end;
    if ConObligatorio then
    begin
      Cols := Cols + ', obligatorio';
      Vals := Vals + ', :b';
    end;
    Sql := 'INSERT INTO cl_VarSubserie (' + Cols + ') VALUES (' + Vals + ')';
    for I := 0 to High(Lista) do
    begin
      Q.SQL.Text := Sql;
      Q.ParamByName('s').AsString := CodSerie;
      Q.ParamByName('c').AsString := CodSubs;
      Q.ParamByName('o').AsInteger := I + 1;
      Q.ParamByName('n').AsString := Trim(Lista[I].Nombre);
      Q.ParamByName('e').AsString := Trim(Lista[I].Etiqueta);
      Q.ParamByName('t').AsInteger := IdTipo(Lista[I].Tipo);
      Q.ParamByName('l').AsInteger := LongitudEfectiva(Lista[I]);
      if ConDescripcion then
      begin
        Q.ParamByName('d').DataType := ftMemo;
        if Trim(Lista[I].Descripcion) = '' then
          Q.ParamByName('d').Clear
        else
          Q.ParamByName('d').AsString := Trim(Lista[I].Descripcion);
      end;
      if ConObligatorio then
        Q.ParamByName('b').AsBoolean := Lista[I].Obligatorio;
      Q.ExecSQL;
    end;
  finally
    Q.Free;
  end;
end;

procedure GuardarVariables(Conn: TFDConnection; EsSqlServer: Boolean;
  const CodSerie, CodSubs: string; const Lista: TArray<TCampoMeta>);
var
  Actuales: TArray<TCampoMeta>;
  Existentes: TArray<string>;
  Errores: TArray<TErrorCampo>;
  Modo: TModoVariables;
  Tabla, Palabra: string;
  I, P: Integer;
  Agregadas: TStringList;
begin
  Actuales := CargarCamposSubserie(Conn, CodSubs);
  Tabla := TablaDatosActual(Conn, CodSerie, CodSubs);
  if Tabla <> '' then
    Modo := mvSoloAnadir
  else
    Modo := mvLibre;

  SetLength(Existentes, Length(Actuales));
  for I := 0 to High(Actuales) do
    Existentes[I] := Actuales[I].Nombre;
  if Modo = mvLibre then
    Existentes := nil;

  Errores := ValidarVariables(Lista, EsSqlServer, Existentes);
  if Length(Errores) > 0 then
    raise EVariables.Create(Errores[0].Mensaje);

  if Modo = mvSoloAnadir then
    for I := 0 to High(Actuales) do
    begin
      P := Buscar(Lista, Actuales[I].Nombre);
      if P < 0 then
        raise EVariables.Create('La variable "' + Actuales[I].Nombre + '" ya no se puede quitar: ' +
          'la subserie tiene documentos guardados.');
      if (Lista[P].Tipo <> Actuales[I].Tipo) or
        (LongitudEfectiva(Lista[P]) <> LongitudEfectiva(Actuales[I])) then
        raise EVariables.Create('El tipo y la longitud de la variable "' + Actuales[I].Nombre +
          '" ya no se pueden cambiar: la subserie tiene documentos guardados.');
      if Lista[P].Nombre <> Actuales[I].Nombre then
        raise EVariables.Create('El nombre de la variable "' + Actuales[I].Nombre +
          '" ya no se puede cambiar: la subserie tiene documentos guardados.');
    end;

  Agregadas := TStringList.Create;
  try
    Conn.StartTransaction;
    try
      if Modo = mvSoloAnadir then
        for I := 0 to High(Lista) do
          if Buscar(Actuales, Lista[I].Nombre) < 0 then
          begin
            if EsSqlServer then
              Palabra := 'ALTER TABLE ' + Tabla + ' ADD ' + Trim(Lista[I].Nombre) + ' ' +
                SqlTipoColumna(Lista[I].Tipo, Lista[I].Longitud, True) + ' NULL'
            else
              Palabra := 'ALTER TABLE ' + Tabla + ' ADD COLUMN ' + Trim(Lista[I].Nombre) + ' ' +
                SqlTipoColumna(Lista[I].Tipo, Lista[I].Longitud, False);
            Conn.ExecSQL(Palabra);
            Agregadas.Add(Trim(Lista[I].Nombre));
          end;
      EscribirDefiniciones(Conn, CodSerie, CodSubs, Lista);
      Conn.Commit;
    except
      on E: Exception do
      begin
        try
          Conn.Rollback;
        except
          // la conexion ya deshizo la transaccion
        end;
        if not EsSqlServer then
          for I := 0 to Agregadas.Count - 1 do
            try
              Conn.ExecSQL('ALTER TABLE ' + Tabla + ' DROP COLUMN ' + Agregadas[I]);
            except
              // la columna no llego a crearse
            end;
        raise EVariables.Create('No se pudieron guardar las variables: ' + E.Message);
      end;
    end;
  finally
    Agregadas.Free;
  end;
end;

end.
