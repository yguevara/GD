unit UVariablesSesion;

{ ---------------------------------------------------------------------------
  Sesion de edicion de las variables de una subserie: la lista que el usuario
  toca en pantalla (agregar, quitar, ordenar, cambiar propiedades) con las
  reglas de UVariablesDatos aplicadas. No toca la base de datos ni la pantalla.

    - mvLibre: todo se puede cambiar.
    - mvSoloAnadir (la subserie ya tiene documentos): las variables que ya
      estaban se pueden reordenar y cambiar de etiqueta, descripcion y
      obligatoria, pero no quitar ni cambiar de nombre, tipo o longitud; las
      nuevas (agregadas en esta sesion) son libres hasta guardar.

  Modificar sobre una variable bloqueada conserva el nombre, tipo y longitud
  originales (la pantalla ya los muestra de solo lectura). Codigo en ASCII.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, System.Generics.Collections, UMetadatosSubserie, UVariablesDatos,
  UErroresCampo;

type
  TSesionVariables = class
  private
    FEsSqlServer: Boolean;
    FModo: TModoVariables;
    FOriginal: TList<TCampoMeta>;
    FActual: TList<TCampoMeta>;
    FEsNueva: TList<Boolean>;
    function Firma(const ALista: TList<TCampoMeta>): string;
    function NombresOriginales: TArray<string>;
  public
    constructor Create(AEsSqlServer: Boolean);
    destructor Destroy; override;
    procedure Cargar(const ALista: TArray<TCampoMeta>; AModo: TModoVariables);
    function Count: Integer;
    function Campo(AIndice: Integer): TCampoMeta;
    { Agrega al final una variable de texto con nombre y etiqueta provisionales;
      devuelve su indice. }
    function Agregar: Integer;
    { False (sin cambios) si la variable esta bloqueada. }
    function Quitar(AIndice: Integer): Boolean;
    procedure Mover(ADe, AA: Integer);
    procedure Modificar(AIndice: Integer; const ANuevo: TCampoMeta);
    function PuedeQuitar(AIndice: Integer): Boolean;
    function PuedeEditarNombre(AIndice: Integer): Boolean;
    function PuedeEditarTipo(AIndice: Integer): Boolean;
    function HayCambios: Boolean;
    function Errores: TArray<TErrorCampo>;
    { Lista para guardar, con Orden 1..n. }
    function Resultado: TArray<TCampoMeta>;
    procedure Descartar;
    property Modo: TModoVariables read FModo;
  end;

implementation

constructor TSesionVariables.Create(AEsSqlServer: Boolean);
begin
  inherited Create;
  FEsSqlServer := AEsSqlServer;
  FOriginal := TList<TCampoMeta>.Create;
  FActual := TList<TCampoMeta>.Create;
  FEsNueva := TList<Boolean>.Create;
end;

destructor TSesionVariables.Destroy;
begin
  FEsNueva.Free;
  FActual.Free;
  FOriginal.Free;
  inherited;
end;

procedure TSesionVariables.Cargar(const ALista: TArray<TCampoMeta>; AModo: TModoVariables);
var
  C: TCampoMeta;
begin
  FModo := AModo;
  FOriginal.Clear;
  for C in ALista do
    FOriginal.Add(C);
  Descartar;
end;

procedure TSesionVariables.Descartar;
var
  C: TCampoMeta;
begin
  FActual.Clear;
  FEsNueva.Clear;
  for C in FOriginal do
  begin
    FActual.Add(C);
    FEsNueva.Add(False);
  end;
end;

function TSesionVariables.Count: Integer;
begin
  Result := FActual.Count;
end;

function TSesionVariables.Campo(AIndice: Integer): TCampoMeta;
begin
  Result := FActual[AIndice];
end;

function TSesionVariables.Agregar: Integer;
var
  N: Integer;
  Nombre: string;
  C: TCampoMeta;

  function Existe(const ANombre: string): Boolean;
  var
    X: TCampoMeta;
  begin
    for X in FActual do
      if SameText(X.Nombre, ANombre) then
        Exit(True);
    Result := False;
  end;

begin
  N := FActual.Count + 1;
  Nombre := 'Variable' + IntToStr(N);
  while Existe(Nombre) do
  begin
    Inc(N);
    Nombre := 'Variable' + IntToStr(N);
  end;
  C := Default(TCampoMeta);
  C.Nombre := Nombre;
  C.Etiqueta := Nombre;
  C.Tipo := tmTexto;
  C.Longitud := 50;
  FActual.Add(C);
  FEsNueva.Add(True);
  Result := FActual.Count - 1;
end;

function TSesionVariables.PuedeQuitar(AIndice: Integer): Boolean;
begin
  Result := (FModo = mvLibre) or FEsNueva[AIndice];
end;

function TSesionVariables.PuedeEditarNombre(AIndice: Integer): Boolean;
begin
  Result := (FModo = mvLibre) or FEsNueva[AIndice];
end;

function TSesionVariables.PuedeEditarTipo(AIndice: Integer): Boolean;
begin
  Result := PuedeEditarNombre(AIndice);
end;

function TSesionVariables.Quitar(AIndice: Integer): Boolean;
begin
  Result := PuedeQuitar(AIndice);
  if Result then
  begin
    FActual.Delete(AIndice);
    FEsNueva.Delete(AIndice);
  end;
end;

procedure TSesionVariables.Mover(ADe, AA: Integer);
var
  C: TCampoMeta;
  N: Boolean;
begin
  if (ADe = AA) or (ADe < 0) or (AA < 0) or (ADe >= FActual.Count) or (AA >= FActual.Count) then
    Exit;
  C := FActual[ADe];
  N := FEsNueva[ADe];
  FActual.Delete(ADe);
  FEsNueva.Delete(ADe);
  FActual.Insert(AA, C);
  FEsNueva.Insert(AA, N);
end;

procedure TSesionVariables.Modificar(AIndice: Integer; const ANuevo: TCampoMeta);
var
  C: TCampoMeta;
begin
  C := ANuevo;
  if not PuedeEditarNombre(AIndice) then
  begin
    C.Nombre := FActual[AIndice].Nombre;
    C.Tipo := FActual[AIndice].Tipo;
    C.Longitud := FActual[AIndice].Longitud;
  end;
  FActual[AIndice] := C;
end;

function TSesionVariables.Firma(const ALista: TList<TCampoMeta>): string;
var
  C: TCampoMeta;
begin
  Result := '';
  for C in ALista do
    Result := Result + C.Nombre + #1 + C.Etiqueta + #1 + IntToStr(Ord(C.Tipo)) + #1 +
      IntToStr(C.Longitud) + #1 + BoolToStr(C.Obligatorio, True) + #1 + C.Descripcion + #2;
end;

function TSesionVariables.HayCambios: Boolean;
begin
  Result := Firma(FOriginal) <> Firma(FActual);
end;

function TSesionVariables.NombresOriginales: TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, FOriginal.Count);
  for I := 0 to FOriginal.Count - 1 do
    Result[I] := FOriginal[I].Nombre;
end;

function TSesionVariables.Resultado: TArray<TCampoMeta>;
var
  I: Integer;
begin
  SetLength(Result, FActual.Count);
  for I := 0 to FActual.Count - 1 do
  begin
    Result[I] := FActual[I];
    Result[I].Orden := I + 1;
  end;
end;

function TSesionVariables.Errores: TArray<TErrorCampo>;
begin
  Result := ValidarVariables(Resultado, FEsSqlServer, NombresOriginales);
end;

end.
