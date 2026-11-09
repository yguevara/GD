unit UMetadatosSubserie;

{ Campos propios de una subserie, definidos por el usuario en cl_VarSubserie, y
  su alta en la tabla de metadatos (md_*). Nada de esos campos esta escrito en
  el codigo: salen de la base. Solo RTL + FireDAC, sin VCL ni UDM. Valido en SQL
  Server y en Access. Codigo en ASCII. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UCargaModelo;

type
  EMetadatos = class(Exception);

  TTipoMeta = (tmTexto, tmMemo, tmFecha, tmEntero, tmReal, tmBooleano);

  TCampoMeta = record
    Nombre: string;
    Etiqueta: string;
    Tipo: TTipoMeta;
    Longitud: Integer;
    Orden: Integer;
    Obligatorio: Boolean;
  end;

  TControlMeta = (cmEdit, cmMemo, cmFecha, cmNumero, cmSiNo);

  TClaveMeta = record
    IdEstructura: string;
    Id: Integer;
    CodSubs: string;
    Fecha: TDateTime;
    Version: string;
    Codigodoc: string;
  end;

{ Control que corresponde a un campo: texto de hasta 255 = cmEdit; Memo, o
  longitud 0 o mayor de 255 = cmMemo. (Esta aqui y no en UCargaModelo porque
  TTipoMeta usa TValorMeta de UCargaModelo.) }
function ControlParaCampo(Tipo: TTipoMeta; Longitud: Integer): TControlMeta;

{ Campos de la subserie ordenados por Orden; vacio si no tiene variables. }
function CargarCamposSubserie(Conn: TFDConnection; const CodSubs: string): TArray<TCampoMeta>;
{ NombreTablaMetadatos de la subserie, o '' si no tiene. }
function NombreTablaMeta(Conn: TFDConnection; const CodSubs: string): string;
{ '' = valido; si no, el mensaje en espanol para mostrar al usuario. Fecha como
  dd/mm/aaaa y decimales con punto, como fija el .dpr. }
function ValidarValorMeta(const Campo: TCampoMeta; const Texto: string): string;
{ Inserta una fila en la tabla de metadatos. Valores vacios = NULL. El nombre de
  la tabla y de las columnas se comprueban contra los reales: EMetadatos y nada
  escrito si alguno no existe. }
procedure GuardarMetadatos(Conn: TFDConnection; const Tabla: string;
  const Clave: TClaveMeta; const Campos: TArray<TCampoMeta>;
  const Valores: TArray<TValorMeta>);

implementation

uses
  System.Classes, System.Variants, Data.DB, FireDAC.Stan.Param;

function Formato: TFormatSettings;
begin
  Result := TFormatSettings.Create;
  Result.DateSeparator := '/';
  Result.ShortDateFormat := 'dd/mm/yyyy';
  Result.DecimalSeparator := '.';
  Result.ThousandSeparator := ',';
end;

function TipoDesdeId(IdTipo: Integer): TTipoMeta;
begin
  case IdTipo of
    2: Result := tmFecha;
    3: Result := tmEntero;
    4: Result := tmMemo;
    5: Result := tmReal;
    6: Result := tmBooleano;
  else
    Result := tmTexto;
  end;
end;

function ControlParaCampo(Tipo: TTipoMeta; Longitud: Integer): TControlMeta;
begin
  case Tipo of
    tmTexto:
      if (Longitud > 0) and (Longitud <= 255) then
        Result := cmEdit
      else
        Result := cmMemo;
    tmMemo: Result := cmMemo;
    tmFecha: Result := cmFecha;
    tmEntero, tmReal: Result := cmNumero;
  else
    Result := cmSiNo;
  end;
end;

function CargarCamposSubserie(Conn: TFDConnection; const CodSubs: string): TArray<TCampoMeta>;
var
  Q: TFDQuery;
  N: Integer;
  C: TCampoMeta;
  Obl: TField;
begin
  Result := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT * FROM cl_VarSubserie WHERE codsubs = :c ORDER BY Orden';
    Q.ParamByName('c').AsString := CodSubs;
    Q.Open;
    Obl := Q.FindField('obligatorio');
    N := 0;
    while not Q.Eof do
    begin
      C := Default(TCampoMeta);
      C.Nombre := Trim(Q.FieldByName('NomVariable').AsString);
      C.Etiqueta := Trim(Q.FieldByName('Etiqueta').AsString);
      if C.Etiqueta = '' then
        C.Etiqueta := C.Nombre;
      C.Tipo := TipoDesdeId(Q.FieldByName('tipo').AsInteger);
      C.Longitud := Q.FieldByName('longitud').AsInteger;
      C.Orden := Q.FieldByName('Orden').AsInteger;
      C.Obligatorio := (Obl <> nil) and (not Obl.IsNull) and Obl.AsBoolean;
      if C.Nombre <> '' then
      begin
        SetLength(Result, N + 1);
        Result[N] := C;
        Inc(N);
      end;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function NombreTablaMeta(Conn: TFDConnection; const CodSubs: string): string;
var
  Q: TFDQuery;
begin
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT NombreTablaMetadatos FROM cl_subseries WHERE codsubs = :c';
    Q.ParamByName('c').AsString := CodSubs;
    Q.Open;
    if not Q.IsEmpty then
      Result := Trim(Q.FieldByName('NombreTablaMetadatos').AsString);
  finally
    Q.Free;
  end;
end;

function TextoABooleano(const Texto: string; out Valor: Boolean): Boolean;
var
  T: string;
begin
  T := LowerCase(Trim(Texto));
  Result := True;
  if (T = '1') or (T = '-1') or (T = 'si') or (T = 'true') or (T = 's') then
    Valor := True
  else if (T = '0') or (T = 'no') or (T = 'false') or (T = 'n') then
    Valor := False
  else
    Result := False;
end;

function ValidarValorMeta(const Campo: TCampoMeta; const Texto: string): string;
var
  T: string;
  I: Integer;
  R: Double;
  D: TDateTime;
  B: Boolean;
  FS: TFormatSettings;
begin
  Result := '';
  T := Trim(Texto);
  if T = '' then
  begin
    if Campo.Obligatorio then
      Result := 'El dato "' + Campo.Etiqueta + '" es obligatorio.';
    Exit;
  end;
  FS := Formato;
  case Campo.Tipo of
    tmTexto:
      if (Campo.Longitud > 0) and (Length(Texto) > Campo.Longitud) then
        Result := Format('El dato "%s" admite hasta %d caracteres.', [Campo.Etiqueta, Campo.Longitud]);
    tmEntero:
      if not TryStrToInt(T, I) then
        Result := 'El dato "' + Campo.Etiqueta + '" debe ser un numero entero.';
    tmReal:
      if not TryStrToFloat(T, R, FS) then
        Result := 'El dato "' + Campo.Etiqueta + '" debe ser un numero (decimales con punto).';
    tmFecha:
      if not TryStrToDate(T, D, FS) then
        Result := 'El dato "' + Campo.Etiqueta + '" debe ser una fecha valida (dd/mm/aaaa).';
    tmBooleano:
      if not TextoABooleano(T, B) then
        Result := 'El dato "' + Campo.Etiqueta + '" debe ser Si o No.';
  end;
end;

{ Solo letras, digitos y guion bajo }
function NombreSeguro(const S: string): Boolean;
var
  I: Integer;
begin
  Result := S <> '';
  for I := 1 to Length(S) do
    if not CharInSet(S[I], ['A'..'Z', 'a'..'z', '0'..'9', '_']) then
      Exit(False);
end;

procedure GuardarMetadatos(Conn: TFDConnection; const Tabla: string;
  const Clave: TClaveMeta; const Campos: TArray<TCampoMeta>;
  const Valores: TArray<TValorMeta>);
const
  BASE: array[0..5] of string = ('IdEstructura', 'id', 'codsubs', 'Fecha', 'Version', 'Codigodoc');
var
  Reales: TStringList;
  Q: TFDQuery;
  Cols, Pars, Nombre: string;
  I, J: Integer;
  Texto: string;
  Valor: string;
  FS: TFormatSettings;
  Entero: Integer;
  Real: Double;
  Fecha: TDateTime;
  Bool: Boolean;
  P: TFDParam;
begin
  if not NombreSeguro(Tabla) then
    raise EMetadatos.Create('Nombre de tabla de metadatos no valido.');
  Reales := TStringList.Create;
  Q := TFDQuery.Create(nil);
  try
    Reales.CaseSensitive := False;
    Q.Connection := Conn;
    try
      Q.Open('SELECT * FROM ' + Tabla + ' WHERE 1 = 0');
    except
      raise EMetadatos.Create('No existe la tabla de metadatos de la subserie.');
    end;
    for I := 0 to Q.FieldCount - 1 do
      Reales.Add(Q.Fields[I].FieldName);
    Q.Close;
    for I := 0 to High(Campos) do
      if Reales.IndexOf(Campos[I].Nombre) < 0 then
        raise EMetadatos.CreateFmt('La tabla de metadatos no tiene la columna "%s".', [Campos[I].Nombre]);

    Cols := 'IdEstructura, id, codsubs, Fecha, Version, Codigodoc';
    Pars := ':k0, :k1, :k2, :k3, :k4, :k5';
    for I := 0 to High(Campos) do
    begin
      Nombre := Reales[Reales.IndexOf(Campos[I].Nombre)];
      Cols := Cols + ', ' + Nombre;
      Pars := Pars + ', :m' + IntToStr(I);
    end;
    Q.SQL.Text := 'INSERT INTO ' + Tabla + ' (' + Cols + ') VALUES (' + Pars + ')';
    Q.ParamByName('k0').AsString := Clave.IdEstructura;
    Q.ParamByName('k1').AsInteger := Clave.Id;
    Q.ParamByName('k2').AsString := Clave.CodSubs;
    Q.ParamByName('k3').AsDateTime := Clave.Fecha;
    Q.ParamByName('k4').AsString := Clave.Version;
    Q.ParamByName('k5').AsString := Clave.Codigodoc;
    FS := Formato;
    for I := 0 to High(Campos) do
    begin
      Valor := '';
      for J := 0 to High(Valores) do
        if SameText(Valores[J].Nombre, Campos[I].Nombre) then
        begin
          Valor := Trim(Valores[J].Valor);
          Break;
        end;
      Texto := Valor;
      P := Q.ParamByName('m' + IntToStr(I));
      case Campos[I].Tipo of
        tmTexto, tmMemo:
          begin
            P.DataType := ftWideString;
            if Campos[I].Tipo = tmMemo then
              P.DataType := ftWideMemo;
            if Texto = '' then
              P.Clear
            else
              P.AsWideString := Texto;
          end;
        tmEntero:
          begin
            P.DataType := ftInteger;
            if (Texto = '') or not TryStrToInt(Texto, Entero) then
              P.Clear
            else
              P.AsInteger := Entero;
          end;
        tmReal:
          begin
            P.DataType := ftFloat;
            if (Texto = '') or not TryStrToFloat(Texto, Real, FS) then
              P.Clear
            else
              P.AsFloat := Real;
          end;
        tmFecha:
          begin
            P.DataType := ftDateTime;
            if (Texto = '') or not TryStrToDate(Texto, Fecha, FS) then
              P.Clear
            else
              P.AsDateTime := Fecha;
          end;
        tmBooleano:
          begin
            P.DataType := ftBoolean;
            if (Texto = '') or not TextoABooleano(Texto, Bool) then
              P.Clear
            else
              P.AsBoolean := Bool;
          end;
      end;
    end;
    Q.ExecSQL;
  finally
    Q.Free;
    Reales.Free;
  end;
end;

end.
