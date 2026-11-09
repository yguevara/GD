unit UCargaModelo;

{ Modelo de la carga de documentos: candidatos (un archivo = un documento
  candidato), sus estados, titulo sugerido, codigos consecutivos, "aplicar a
  todos" y validacion de datos obligatorios. Solo RTL, sin VCL ni UDM. Codigo
  en ASCII. }

interface

uses
  System.SysUtils;

type
  TEstadoCandidato = (ecEspera, ecFalta, ecListo, ecSubiendo, ecGuardado, ecError);

  TValorMeta = record
    Nombre: string;
    Valor: string;
  end;

  TCandidato = record
    Archivo: string;
    Titulo: string;
    Codigo: string;
    Acceso: string;
    Fecha: TDateTime;
    EsExpediente: Boolean;
    Fuentes: TArray<string>;
    Meta: TArray<TValorMeta>;
    Estado: TEstadoCandidato;
    Error: string;
  end;

  TCampoComun = (ccTitulo, ccFecha, ccAcceso, ccEsExpediente);
  TCamposComunes = set of TCampoComun;

{ Titulo legible a partir del nombre de archivo: sin carpeta ni extension, '_' y
  '-' como espacios, sin espacios repetidos y con la primera letra en mayuscula. }
function TituloDesdeNombre(const Archivo: string): string;

{ Misma regla que TUDM.ProponerValores: sin ultimo codigo, IdEstructura + CodSubs
  + Version; con ultimo, se incrementa su sufijo numerico (minimo 3 digitos). La
  unicidad contra la base la comprueba quien guarda. }
function SiguienteCodigo(const Ultimo, IdEstructura, CodSubs, Version: string): string;
function CodigosParaLote(const Ultimo, IdEstructura, CodSubs, Version: string;
  Cantidad: Integer): TArray<string>;

{ Copia a todos los candidatos solo los campos pedidos; nunca toca Archivo,
  Codigo ni Estado. }
procedure AplicarATodos(var Lote: TArray<TCandidato>; const Plantilla: TCandidato;
  Campos: TCamposComunes);

{ Nombres de lo que falta: 'Titulo', 'Codigo', 'Fecha' y los metadatos
  obligatorios vacios (solo espacios cuenta como vacio). }
function Faltantes(const C: TCandidato; const Obligatorios: TArray<string>): TArray<string>;
function EstadoTrasEditar(const C: TCandidato; const Obligatorios: TArray<string>): TEstadoCandidato;

{ Nombre valido en Windows para usar en rutas: \ / : * ? " < > | pasan a '_'. }
function LimpiarNombreArchivo(const S: string): string;

{ Archivos de las carpetas y de las rutas sueltas (lo que se suelta en la
  pantalla): sin duplicados, sin ocultos ni temporales (~$*, Thumbs.db,
  desktop.ini), ordenados. Recursivo = entra en subcarpetas. Las rutas que no
  existen se ignoran. }
function ExpandirRutas(const Rutas: TArray<string>; Recursivo: Boolean): TArray<string>;

implementation

uses
  System.IOUtils, System.Generics.Collections, System.Generics.Defaults;

function TituloDesdeNombre(const Archivo: string): string;
var
  I: Integer;
  Anterior: Char;
  Salida: string;
begin
  Result := Trim(ChangeFileExt(ExtractFileName(Trim(Archivo)), ''));
  if Result = '' then
    Exit;
  Result := StringReplace(StringReplace(Result, '_', ' ', [rfReplaceAll]), '-', ' ', [rfReplaceAll]);
  Salida := '';
  Anterior := #0;
  for I := 1 to Length(Result) do
  begin
    if (Result[I] = ' ') and (Anterior = ' ') then
      Continue;
    Salida := Salida + Result[I];
    Anterior := Result[I];
  end;
  Result := Trim(Salida);
  if Result <> '' then
    Result := UpperCase(Copy(Result, 1, 1)) + Copy(Result, 2, MaxInt);
end;

function SiguienteCodigo(const Ultimo, IdEstructura, CodSubs, Version: string): string;
var
  I, Numero: Integer;
  Parte, Sufijo: string;
begin
  if Ultimo = '' then
    Exit(IdEstructura + CodSubs + Version);
  I := Length(Ultimo);
  while (I > 0) and CharInSet(Ultimo[I], ['0'..'9']) do
    Dec(I);
  Parte := Copy(Ultimo, 1, I);
  Sufijo := Copy(Ultimo, I + 1, MaxInt);
  if TryStrToInt(Sufijo, Numero) then
    Inc(Numero)
  else
    Numero := 1;
  Result := Parte + Format('%.3d', [Numero]);
end;

function CodigosParaLote(const Ultimo, IdEstructura, CodSubs, Version: string;
  Cantidad: Integer): TArray<string>;
var
  I: Integer;
  Actual: string;
begin
  Result := nil;
  if Cantidad <= 0 then
    Exit;
  SetLength(Result, Cantidad);
  Actual := Ultimo;
  for I := 0 to Cantidad - 1 do
  begin
    Actual := SiguienteCodigo(Actual, IdEstructura, CodSubs, Version);
    Result[I] := Actual;
  end;
end;

procedure AplicarATodos(var Lote: TArray<TCandidato>; const Plantilla: TCandidato;
  Campos: TCamposComunes);
var
  I: Integer;
begin
  for I := 0 to High(Lote) do
  begin
    if ccTitulo in Campos then
      Lote[I].Titulo := Plantilla.Titulo;
    if ccFecha in Campos then
      Lote[I].Fecha := Plantilla.Fecha;
    if ccAcceso in Campos then
      Lote[I].Acceso := Plantilla.Acceso;
    if ccEsExpediente in Campos then
      Lote[I].EsExpediente := Plantilla.EsExpediente;
  end;
end;

function ValorMeta(const C: TCandidato; const Nombre: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(C.Meta) do
    if SameText(C.Meta[I].Nombre, Nombre) then
      Exit(C.Meta[I].Valor);
end;

function Faltantes(const C: TCandidato; const Obligatorios: TArray<string>): TArray<string>;
var
  I, N: Integer;

  procedure Agregar(const Nombre: string);
  begin
    SetLength(Result, N + 1);
    Result[N] := Nombre;
    Inc(N);
  end;

begin
  Result := nil;
  N := 0;
  if Trim(C.Titulo) = '' then
    Agregar('Titulo');
  if Trim(C.Codigo) = '' then
    Agregar('Codigo');
  if C.Fecha = 0 then
    Agregar('Fecha');
  for I := 0 to High(Obligatorios) do
    if Trim(ValorMeta(C, Obligatorios[I])) = '' then
      Agregar(Obligatorios[I]);
end;

function EstadoTrasEditar(const C: TCandidato; const Obligatorios: TArray<string>): TEstadoCandidato;
begin
  if Length(Faltantes(C, Obligatorios)) = 0 then
    Result := ecListo
  else
    Result := ecFalta;
end;

function LimpiarNombreArchivo(const S: string): string;
var
  I: Integer;
begin
  Result := Trim(S);
  for I := 1 to Length(Result) do
    if CharInSet(Result[I], ['\', '/', ':', '*', '?', '"', '<', '>', '|']) then
      Result[I] := '_';
  if Result = '' then
    Result := '_';
end;

function EsIgnorable(const Ruta: string): Boolean;
var
  Nombre: string;
begin
  Nombre := ExtractFileName(Ruta);
  Result := Nombre.StartsWith('~$') or SameText(Nombre, 'Thumbs.db') or
    SameText(Nombre, 'desktop.ini');
  if not Result then
    try
      Result := TFileAttribute.faHidden in TFile.GetAttributes(Ruta);
    except
      Result := False;
    end;
end;

function ExpandirRutas(const Rutas: TArray<string>; Recursivo: Boolean): TArray<string>;
var
  Vistos: TDictionary<string, Boolean>;
  Lista: TList<string>;
  I: Integer;
  Opcion: TSearchOption;
  A: string;

  procedure Agregar(const Ruta: string);
  begin
    if EsIgnorable(Ruta) then
      Exit;
    if Vistos.ContainsKey(LowerCase(Ruta)) then
      Exit;
    Vistos.Add(LowerCase(Ruta), True);
    Lista.Add(Ruta);
  end;

begin
  Vistos := TDictionary<string, Boolean>.Create;
  Lista := TList<string>.Create;
  try
    if Recursivo then
      Opcion := TSearchOption.soAllDirectories
    else
      Opcion := TSearchOption.soTopDirectoryOnly;
    for I := 0 to High(Rutas) do
    begin
      if TDirectory.Exists(Rutas[I]) then
      begin
        for A in TDirectory.GetFiles(Rutas[I], '*', Opcion) do
          Agregar(A);
      end
      else if TFile.Exists(Rutas[I]) then
        Agregar(Rutas[I]);
    end;
    Lista.Sort(TComparer<string>.Construct(
      function(const X, Y: string): Integer
      begin
        Result := CompareText(X, Y);
      end));
    Result := Lista.ToArray;
  finally
    Lista.Free;
    Vistos.Free;
  end;
end;

end.
