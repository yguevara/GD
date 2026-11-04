unit UBusquedaDatos;

{ Ejecuta la busqueda integrada: lee los campos de cada subserie
  (cl_VarSubserie), arma una consulta por subserie con UBusqueda.SqlSubserie y
  la condicion de alcance de UAlcanceDatos.FiltroDocumentos, y junta las filas
  en un unico TFDMemTable. Sin VCL ni TUDM. Valido en SQL Server y Access. }

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client, UAlcance, UBusqueda;

{ Campos de la subserie segun cl_VarSubserie, en su orden. Omite los de nombre
  no seguro o tipo desconocido. }
function CargarCamposSubserie(Conn: TFDConnection;
  const CodSubs: string): TArray<TCampoBusqueda>;

{ Nombre de la tabla md_* de la subserie; '' si no tiene, si el nombre no es
  seguro o si la tabla no existe. }
function TablaMetadatos(Conn: TFDConnection; const CodSubs: string): string;

{ El resultado es del llamador. Columnas: IdEstructura, id, codsubs, Fecha,
  Version, Codigodoc, titulodoc, NombreSubserie. Lanza Exception con el
  mensaje para el usuario si el pedido no es valido. Alcance = nil: todo. }
function Buscar(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Pedido: TPedidoBusqueda; ConSqlServer: Boolean;
  out Truncado: Boolean): TFDMemTable;

implementation

uses
  Data.DB, UAlcanceDatos;

function ColumnasDeTabla(Conn: TFDConnection; const Tabla: string): TArray<string>;
var
  Q: TFDQuery;
  I: Integer;
begin
  Result := nil;
  if not NombreSeguro(Tabla) then
    Exit;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT * FROM ' + Tabla + ' WHERE 1=0';
    try
      Q.Open;
    except
      Exit; // la tabla no existe
    end;
    SetLength(Result, Q.FieldCount);
    for I := 0 to Q.FieldCount - 1 do
      Result[I] := Q.Fields[I].FieldName;
  finally
    Q.Free;
  end;
end;

function Contiene(const Lista: TArray<string>; const Nombre: string): Boolean;
var
  S: string;
begin
  for S in Lista do
    if SameText(S, Nombre) then
      Exit(True);
  Result := False;
end;

function CargarCamposSubserie(Conn: TFDConnection;
  const CodSubs: string): TArray<TCampoBusqueda>;
var
  Q: TFDQuery;
  L: TList<TCampoBusqueda>;
  C: TCampoBusqueda;
begin
  L := TList<TCampoBusqueda>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT V.NomVariable, V.Etiqueta, T.tipo AS NombreTipo ' +
      'FROM cl_VarSubserie V INNER JOIN CL_SubseriesTipoVar T ON V.tipo = T.idtipo ' +
      'WHERE V.codsubs = :cod ORDER BY V.Orden';
    Q.ParamByName('cod').AsString := CodSubs;
    Q.Open;
    while not Q.Eof do
    begin
      C.Nombre := Trim(Q.FieldByName('NomVariable').AsString);
      C.Etiqueta := Q.FieldByName('Etiqueta').AsString;
      if C.Etiqueta = '' then
        C.Etiqueta := C.Nombre;
      if NombreSeguro(C.Nombre) then
        try
          C.Tipo := TipoDeNombre(Trim(Q.FieldByName('NombreTipo').AsString));
          L.Add(C);
        except
          on EArgumentException do ; // tipo desconocido: el campo no se ofrece
        end;
      Q.Next;
    end;
    Result := L.ToArray;
  finally
    Q.Free;
    L.Free;
  end;
end;

function TablaMetadatos(Conn: TFDConnection; const CodSubs: string): string;
var
  Q: TFDQuery;
begin
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT NombreTablaMetadatos FROM cl_subseries WHERE codsubs = :cod';
    Q.ParamByName('cod').AsString := CodSubs;
    Q.Open;
    if not Q.IsEmpty then
      Result := Trim(Q.Fields[0].AsString);
  finally
    Q.Free;
  end;
  if (Result <> '') and (Length(ColumnasDeTabla(Conn, Result)) = 0) then
    Result := '';
end;

function SubseriesConDocumentos(Conn: TFDConnection; const Alc: TFiltroSql;
  const CodSubs: string): TArray<string>;
var
  Q: TFDQuery;
  L: TList<string>;
begin
  L := TList<string>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT DISTINCT S.codsubs FROM tb_SeriesDatos S WHERE (' +
      Alc.Condicion + ')';
    if CodSubs <> '' then
      Q.SQL.Text := Q.SQL.Text + ' AND S.codsubs = :bqsub';
    Q.SQL.Text := Q.SQL.Text + ' ORDER BY S.codsubs';
    AplicarParametros(Q, Alc);
    if CodSubs <> '' then
      Q.ParamByName('bqsub').AsString := CodSubs;
    Q.Open;
    while not Q.Eof do
    begin
      L.Add(Q.Fields[0].AsString);
      Q.Next;
    end;
    Result := L.ToArray;
  finally
    Q.Free;
    L.Free;
  end;
end;

function NombreDeSubserie(Conn: TFDConnection; const CodSubs: string): string;
var
  Q: TFDQuery;
begin
  Result := CodSubs;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT subserie FROM cl_subseries WHERE codsubs = :cod';
    Q.ParamByName('cod').AsString := CodSubs;
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.Fields[0].AsString;
  finally
    Q.Free;
  end;
end;

function CrearResultado: TFDMemTable;
begin
  Result := TFDMemTable.Create(nil);
  try
    with Result.FieldDefs do
    begin
      Add('IdEstructura', ftString, 50);
      Add('id', ftInteger);
      Add('codsubs', ftString, 50);
      Add('Fecha', ftDateTime);
      Add('Version', ftString, 12);
      Add('Codigodoc', ftString, 20);
      Add('titulodoc', ftString, 255);
      Add('NombreSubserie', ftString, 255);
    end;
    Result.CreateDataSet;
  except
    Result.Free;
    raise;
  end;
end;

function Buscar(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Pedido: TPedidoBusqueda; ConSqlServer: Boolean;
  out Truncado: Boolean): TFDMemTable;
var
  Msg, Cod, Tabla, Nombre: string;
  Limite, I: Integer;
  Alc, F: TFiltroSql;
  Subs: TArray<string>;
  Campos: TArray<TCampoBusqueda>;
  Cols: TArray<string>;
  Aptos: TList<TCampoBusqueda>;
  C: TCampoBusqueda;
  P: TPedidoBusqueda;
  Q: TFDQuery;
begin
  Truncado := False;
  Msg := ValidarPedido(Pedido);
  if Msg <> '' then
    raise Exception.Create(Msg);
  if (Pedido.CodSubs = '') and (Length(Pedido.Condiciones) > 0) then
    raise Exception.Create('Los filtros por campo requieren elegir una subserie.');
  Limite := Pedido.Limite;
  if Limite <= 0 then
    Limite := LIMITE_BUSQUEDA_DEFECTO;

  Alc := FiltroDocumentos(Alcance, 'S');
  Subs := SubseriesConDocumentos(Conn, Alc, Pedido.CodSubs);

  Result := CrearResultado;
  try
    Q := TFDQuery.Create(nil);
    Aptos := TList<TCampoBusqueda>.Create;
    try
      Q.Connection := Conn;
      for Cod in Subs do
      begin
        Tabla := TablaMetadatos(Conn, Cod);
        Aptos.Clear;
        if Tabla <> '' then
        begin
          Cols := ColumnasDeTabla(Conn, Tabla);
          Campos := CargarCamposSubserie(Conn, Cod);
          for C in Campos do
            if Contiene(Cols, C.Nombre) then
              Aptos.Add(C);
        end;
        P := Pedido;
        P.CodSubs := Cod;
        F := SqlSubserie(P, Aptos.ToArray, Tabla, Alc, ConSqlServer);
        Q.Close;
        Q.SQL.Text := F.Condicion;
        AplicarParametros(Q, F);
        Q.Open;
        Nombre := NombreDeSubserie(Conn, Cod);
        while (not Q.Eof) and (not Truncado) do
        begin
          if Result.RecordCount >= Limite then
            Truncado := True
          else
          begin
            Result.Append;
            for I := 0 to 6 do
              Result.Fields[I].Value := Q.Fields[I].Value;
            Result.FieldByName('NombreSubserie').AsString := Nombre;
            Result.Post;
            Q.Next;
          end;
        end;
        if Truncado then
          Break;
      end;
    finally
      Aptos.Free;
      Q.Free;
    end;
    Result.First;
  except
    Result.Free;
    raise;
  end;
end;

end.
