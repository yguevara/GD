unit UBusqueda;

{ Reglas puras de la busqueda integrada de documentos: tipos de campo,
  validacion del pedido, escape de LIKE y generacion del SQL de UNA subserie
  (tb_SeriesDatos + su tabla md_* opcional). Sin VCL ni acceso a datos: solo
  usa los tipos TFiltroSql/TParametroSql de UAlcanceDatos.
  El texto del usuario siempre va como parametro; los nombres de campo y de
  tabla se validan antes de entrar al SQL. Valido en SQL Server y en Access. }

interface

uses
  System.SysUtils, System.Variants, System.Generics.Collections, UAlcanceDatos;

type
  TTipoCampo = (tcCaracteres, tcFecha, tcEntero, tcMemo, tcReal, tcBooleano);

  TCampoBusqueda = record
    Nombre: string;
    Etiqueta: string;
    Tipo: TTipoCampo;
  end;

  { Caracteres/Memo: Desde = "contiene". Fecha/Entero/Real: rango, Hasta vacio
    = sin cota superior. Booleano: Desde = '1' o '0'. Fechas como yyyy-mm-dd,
    numeros con punto decimal. }
  TCondicionCampo = record
    Campo: string;
    Desde: string;
    Hasta: string;
  end;

  { abGeneral: todos los nodos (sin permiso solo salen los documentos publicos,
    lo garantiza el filtro de alcance). abNodoActual: un nodo y sus descendientes. }
  TAmbitoBusqueda = (abGeneral, abNodoActual);

  { CodSubs = '' busca en todas las subseries del alcance. Limite <= 0 usa
    LIMITE_BUSQUEDA_DEFECTO. IdsNodo: los IdEstructura LITERALES (tal como estan
    guardados) del nodo y sus descendientes; vacio con abGeneral. El ambito solo
    agrega una restriccion mas: el filtro de alcance siempre se aplica. }
  TPedidoBusqueda = record
    Texto: string;
    CodSubs: string;
    Condiciones: TArray<TCondicionCampo>;
    Limite: Integer;
    Ambito: TAmbitoBusqueda;
    IdsNodo: TArray<string>;
  end;

const
  LIMITE_BUSQUEDA_DEFECTO = 500;

function TipoDeNombre(const Nombre: string): TTipoCampo;
function NombreSeguro(const Nombre: string): Boolean;
{ Cada %, _ y [ queda entre corchetes ([%]): literal en SQL Server y Access. }
function EscaparLike(const Texto: string): string;
{ '' si el pedido es valido; si no, el mensaje para el usuario. }
function ValidarPedido(const P: TPedidoBusqueda): string;
{ Devuelve en Condicion el SELECT completo y en Parametros los del alcance
  mas los propios. TablaMd = '' busca solo en los datos fijos. Lanza
  EArgumentException ante un campo o tabla no validos. }
function SqlSubserie(const Pedido: TPedidoBusqueda;
  const Campos: TArray<TCampoBusqueda>; const TablaMd: string;
  const FiltroAlcance: TFiltroSql; ConSqlServer: Boolean): TFiltroSql;

implementation

const
  COLLATE_SQLSERVER = ' COLLATE Modern_Spanish_CI_AI';

function TipoDeNombre(const Nombre: string): TTipoCampo;
begin
  if SameText(Nombre, 'Caracteres') then Exit(tcCaracteres);
  if SameText(Nombre, 'Fecha') then Exit(tcFecha);
  if SameText(Nombre, 'Entero') then Exit(tcEntero);
  if SameText(Nombre, 'Memo') then Exit(tcMemo);
  if SameText(Nombre, 'Real') then Exit(tcReal);
  if SameText(Nombre, 'Boolean') then Exit(tcBooleano);
  raise EArgumentException.Create('Tipo de campo desconocido: ' + Nombre);
end;

function NombreSeguro(const Nombre: string): Boolean;
var
  I: Integer;
  C: Char;
begin
  Result := Nombre <> '';
  for I := 1 to Length(Nombre) do
  begin
    C := Nombre[I];
    if not (((C >= 'a') and (C <= 'z')) or ((C >= 'A') and (C <= 'Z')) or
      (C = '_') or ((I > 1) and (C >= '0') and (C <= '9'))) then
      Exit(False);
  end;
end;

function EscaparLike(const Texto: string): string;
var
  C: Char;
begin
  Result := '';
  for C in Texto do
    if (C = '%') or (C = '_') or (C = '[') then
      Result := Result + '[' + C + ']'
    else
      Result := Result + C;
end;

function FormatoInvariante: TFormatSettings;
begin
  Result := TFormatSettings.Create('en-US');
  Result.DecimalSeparator := '.';
end;

{ yyyy-mm-dd estricto. }
function TryFecha(const S: string; out F: TDateTime): Boolean;
var
  A, M, D: Integer;
begin
  Result := False;
  if (Length(S) <> 10) or (S[5] <> '-') or (S[8] <> '-') then
    Exit;
  if not (TryStrToInt(Copy(S, 1, 4), A) and TryStrToInt(Copy(S, 6, 2), M) and
    TryStrToInt(Copy(S, 9, 2), D)) then
    Exit;
  Result := TryEncodeDate(A, M, D, F);
end;

function ValidarPedido(const P: TPedidoBusqueda): string;
var
  C: TCondicionCampo;
  D1, D2: TDateTime;
  N1, N2: Double;
  FS: TFormatSettings;
begin
  Result := '';
  if (P.Ambito = abNodoActual) and (Length(P.IdsNodo) = 0) then
    Exit('Elija un nodo del arbol para buscar en el nodo actual.');
  if (Trim(P.Texto) = '') and (P.CodSubs = '') and (Length(P.Condiciones) = 0) then
    Exit('Escriba un texto, o elija una subserie o un filtro, para buscar.');
  FS := FormatoInvariante;
  for C in P.Condiciones do
  begin
    if not NombreSeguro(C.Campo) then
      Exit('Filtro no valido: ' + C.Campo);
    if (C.Desde = '') and (C.Hasta = '') then
      Exit('Falta el valor del filtro ' + C.Campo + '.');
    if (C.Hasta <> '') and (C.Desde <> '') then
    begin
      if TryFecha(C.Desde, D1) and TryFecha(C.Hasta, D2) then
      begin
        if D1 > D2 then
          Exit('El rango de fechas de ' + C.Campo + ' esta invertido.');
      end
      else if TryStrToFloat(C.Desde, N1, FS) and TryStrToFloat(C.Hasta, N2, FS) then
        if N1 > N2 then
          Exit('El rango de ' + C.Campo + ' esta invertido.');
    end;
  end;
end;

function SqlSubserie(const Pedido: TPedidoBusqueda;
  const Campos: TArray<TCampoBusqueda>; const TablaMd: string;
  const FiltroAlcance: TFiltroSql; ConSqlServer: Boolean): TFiltroSql;
var
  Params: TList<TParametroSql>;
  Texto, Sql, Coll, Partes, Nombre: string;
  Cond: TCondicionCampo;
  Campo: TCampoBusqueda;
  Hallado: Boolean;
  C: TCampoBusqueda;

  function NuevoParam(const Valor: Variant): string;
  var
    P: TParametroSql;
  begin
    P.Nombre := 'bq' + IntToStr(Params.Count + 1);
    P.Valor := Valor;
    Params.Add(P);
    Result := ':' + P.Nombre;
  end;

  procedure Y(const Parte: string);
  begin
    Sql := Sql + ' AND ' + Parte;
  end;

  procedure Condicion(const Cd: TCondicionCampo; const Cp: TCampoBusqueda);
  var
    F: TDateTime;
    N: Double;
    I: Int64;
    FS: TFormatSettings;
    Col: string;
  begin
    FS := FormatoInvariante;
    Col := 'M.' + Cp.Nombre;
    case Cp.Tipo of
      tcCaracteres, tcMemo:
        if Cd.Desde <> '' then
          Y(Col + Coll + ' LIKE ' + NuevoParam('%' + EscaparLike(Cd.Desde) + '%'));
      tcFecha:
        begin
          if Cd.Desde <> '' then
          begin
            if not TryFecha(Cd.Desde, F) then
              raise EArgumentException.Create('Fecha no valida: ' + Cd.Desde);
            Y(Col + ' >= ' + NuevoParam(VarFromDateTime(F)));
          end;
          if Cd.Hasta <> '' then
          begin
            if not TryFecha(Cd.Hasta, F) then
              raise EArgumentException.Create('Fecha no valida: ' + Cd.Hasta);
            Y(Col + ' < ' + NuevoParam(VarFromDateTime(F + 1)));
          end;
        end;
      tcEntero:
        begin
          if Cd.Desde <> '' then
          begin
            if not TryStrToInt64(Cd.Desde, I) then
              raise EArgumentException.Create('Numero no valido: ' + Cd.Desde);
            Y(Col + ' >= ' + NuevoParam(I));
          end;
          if Cd.Hasta <> '' then
          begin
            if not TryStrToInt64(Cd.Hasta, I) then
              raise EArgumentException.Create('Numero no valido: ' + Cd.Hasta);
            Y(Col + ' <= ' + NuevoParam(I));
          end;
        end;
      tcReal:
        begin
          if Cd.Desde <> '' then
          begin
            if not TryStrToFloat(Cd.Desde, N, FS) then
              raise EArgumentException.Create('Numero no valido: ' + Cd.Desde);
            Y(Col + ' >= ' + NuevoParam(N));
          end;
          if Cd.Hasta <> '' then
          begin
            if not TryStrToFloat(Cd.Hasta, N, FS) then
              raise EArgumentException.Create('Numero no valido: ' + Cd.Hasta);
            Y(Col + ' <= ' + NuevoParam(N));
          end;
        end;
      tcBooleano:
        if Cd.Desde <> '' then
          Y(Col + ' = ' + NuevoParam(Cd.Desde = '1'));
    end;
  end;

begin
  if (TablaMd <> '') and not NombreSeguro(TablaMd) then
    raise EArgumentException.Create('Tabla de metadatos no valida: ' + TablaMd);
  if ConSqlServer then
    Coll := COLLATE_SQLSERVER
  else
    Coll := '';

  Params := TList<TParametroSql>.Create;
  try
    Params.AddRange(FiltroAlcance.Parametros);

    Sql := 'SELECT S.IdEstructura, S.id, S.codsubs, S.Fecha, S.Version, ' +
      'S.Codigodoc, S.titulodoc FROM tb_SeriesDatos S';
    if TablaMd <> '' then
      Sql := Sql + ' LEFT JOIN ' + TablaMd + ' M ON ' +
        'S.IdEstructura = M.IdEstructura AND S.id = M.id AND ' +
        'S.codsubs = M.codsubs AND S.Fecha = M.Fecha AND ' +
        'S.Version = M.Version AND S.Codigodoc = M.Codigodoc';
    Sql := Sql + ' WHERE (' + FiltroAlcance.Condicion + ')';

    if Pedido.CodSubs <> '' then
      Y('S.codsubs = ' + NuevoParam(Pedido.CodSubs));

    if Pedido.Ambito = abNodoActual then
    begin
      if Length(Pedido.IdsNodo) = 0 then
        raise EArgumentException.Create('El ambito nodo actual requiere nodos');
      Partes := '';
      for Nombre in Pedido.IdsNodo do
      begin
        if Partes <> '' then
          Partes := Partes + ', ';
        Partes := Partes + NuevoParam(Nombre);
      end;
      Y('S.IdEstructura IN (' + Partes + ')');
    end;

    Texto := Trim(Pedido.Texto);
    if Texto <> '' then
    begin
      Nombre := NuevoParam('%' + EscaparLike(Texto) + '%');
      Partes := 'S.Codigodoc' + Coll + ' LIKE ' + Nombre +
        ' OR S.titulodoc' + Coll + ' LIKE ' + Nombre;
      if TablaMd <> '' then
        for C in Campos do
          if C.Tipo in [tcCaracteres, tcMemo] then
            Partes := Partes + ' OR M.' + C.Nombre + Coll + ' LIKE ' + Nombre;
      Y('(' + Partes + ')');
    end;

    for Cond in Pedido.Condiciones do
    begin
      Hallado := False;
      if TablaMd <> '' then
        for Campo in Campos do
          if SameText(Campo.Nombre, Cond.Campo) then
          begin
            Hallado := True;
            Condicion(Cond, Campo);
            Break;
          end;
      if not Hallado then
        raise EArgumentException.Create('El campo ' + Cond.Campo +
          ' no pertenece a la subserie');
    end;

    Sql := Sql + ' ORDER BY S.Fecha DESC, S.Codigodoc';
    Result.Condicion := Sql;
    Result.Parametros := Params.ToArray;
  finally
    Params.Free;
  end;
end;

end.
