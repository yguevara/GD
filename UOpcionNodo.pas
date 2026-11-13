unit UOpcionNodo;

{ ---------------------------------------------------------------------------
  Nodos donde el usuario puede trabajar (crear prestamos, transferencias...) y
  eleccion del nodo de trabajo en las pantallas de procesos archivisticos. Sin VCL.

  La ventana principal arma la lista con los nodos del arbol sobre los que el
  usuario tiene la accion (UAlcance.PuedeRealizar) y cada pantalla la muestra en un
  selector; la pantalla trabaja sobre el nodo elegido.
  --------------------------------------------------------------------------- }

interface

uses
  UAlcance;

type
  TOpcionNodo = record
    Clave: TClaveNodo;
    Texto: string;      // ruta del nodo en el arbol, para mostrar
  end;

{ Posicion del nodo en la lista (la estructura se compara sin mayusculas ni
  espacios; el id solo no basta); -1 si no esta. }
function IndiceDeNodo(const Opciones: TArray<TOpcionNodo>; const Clave: TClaveNodo): Integer;

{ Nodo que queda elegido: el preferido si esta en la lista, si no el primero; -1 si
  la lista esta vacia. }
function ElegirNodo(const Opciones: TArray<TOpcionNodo>; const Preferido: TClaveNodo): Integer;

{ Ruta de un nodo: sus nombres desde la raiz separados por " \ ", sin partes vacias. }
function RutaTexto(const Partes: array of string): string;

implementation

function IndiceDeNodo(const Opciones: TArray<TOpcionNodo>; const Clave: TClaveNodo): Integer;
var
  I: Integer;
begin
  for I := 0 to High(Opciones) do
    if (Opciones[I].Clave.Id = Clave.Id) and
      (NormalizaClave(Opciones[I].Clave.IdEstructura) = NormalizaClave(Clave.IdEstructura)) then
      Exit(I);
  Result := -1;
end;

function ElegirNodo(const Opciones: TArray<TOpcionNodo>; const Preferido: TClaveNodo): Integer;
begin
  if Length(Opciones) = 0 then
    Exit(-1);
  Result := IndiceDeNodo(Opciones, Preferido);
  if Result < 0 then
    Result := 0;
end;

function RutaTexto(const Partes: array of string): string;
var
  P: string;
begin
  Result := '';
  for P in Partes do
  begin
    if P = '' then
      Continue;
    if Result <> '' then
      Result := Result + ' \ ';
    Result := Result + P;
  end;
end;

end.
