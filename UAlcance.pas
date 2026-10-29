unit UAlcance;

{ Reglas puras de alcance: roles, acciones y arbol de nodos.
  Sin dependencias de VCL ni de FireDAC. }

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  TRolNodo = (rnVisor, rnUsuario, rnDirector, rnEGD, rnAdministrador);

  TAccion = (acVer, acAgregar, acEditar, acEliminar, acPrestar, acTransferir,
    acDepurar, acAsignarUsuarios);

  TClaveNodo = record
    IdEstructura: string;
    Id: Integer;
  end;

function NormalizaClave(const S: string): string;
function RolPermite(Rol: TRolNodo; Accion: TAccion): Boolean;

type
  TArbolNodos = class
  private
    type
      TInfoNodo = record
        Clave: TClaveNodo;   // IdEstructura ya normalizado
        PadreId: Integer;
      end;
  private
    FNodos: TDictionary<string, TInfoNodo>;
    FPorId: TDictionary<Integer, TList<string>>;
    FPadres: TDictionary<string, string>; // cache; vacio = sin padre
    FPadresValidos: Boolean;
    function ClaveInterna(const Nodo: TClaveNodo): string;
    function BuscarPadre(const Info: TInfoNodo): string;
    procedure Resolver;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Agregar(const Nodo: TClaveNodo; PadreId: Integer);
    function Contiene(const Nodo: TClaveNodo): Boolean;
    function EsDescendiente(const Raiz, Nodo: TClaveNodo): Boolean;
    function Ancestros(const Nodo: TClaveNodo): TArray<TClaveNodo>;
  end;

implementation

function NormalizaClave(const S: string): string;
begin
  Result := UpperCase(Trim(S));
end;

function RolPermite(Rol: TRolNodo; Accion: TAccion): Boolean;
begin
  case Rol of
    rnVisor:
      Result := Accion = acVer;
    rnUsuario, rnDirector, rnAdministrador:
      Result := Accion in [acVer, acAgregar, acEditar];
    rnEGD:
      Result := True;
  else
    Result := False;
  end;
end;

{ TArbolNodos }

constructor TArbolNodos.Create;
begin
  inherited Create;
  FNodos := TDictionary<string, TInfoNodo>.Create;
  FPorId := TObjectDictionary<Integer, TList<string>>.Create([doOwnsValues]);
  FPadres := TDictionary<string, string>.Create;
  FPadresValidos := True;
end;

destructor TArbolNodos.Destroy;
begin
  FPadres.Free;
  FPorId.Free;
  FNodos.Free;
  inherited;
end;

function TArbolNodos.ClaveInterna(const Nodo: TClaveNodo): string;
begin
  Result := NormalizaClave(Nodo.IdEstructura) + '|' + IntToStr(Nodo.Id);
end;

procedure TArbolNodos.Agregar(const Nodo: TClaveNodo; PadreId: Integer);
var
  Info: TInfoNodo;
  K: string;
  Lista: TList<string>;
begin
  Info.Clave.IdEstructura := NormalizaClave(Nodo.IdEstructura);
  Info.Clave.Id := Nodo.Id;
  Info.PadreId := PadreId;
  K := ClaveInterna(Nodo);
  if not FNodos.ContainsKey(K) then
  begin
    if not FPorId.TryGetValue(Nodo.Id, Lista) then
    begin
      Lista := TList<string>.Create;
      FPorId.Add(Nodo.Id, Lista);
    end;
    Lista.Add(K);
  end;
  FNodos.AddOrSetValue(K, Info);
  FPadresValidos := False;
end;

function TArbolNodos.BuscarPadre(const Info: TInfoNodo): string;
var
  Lista: TList<string>;
  Cand: string;
  Pref: string;
  Otro: TInfoNodo;
begin
  Result := '';
  if not FPorId.TryGetValue(Info.PadreId, Lista) then
    Exit;
  for Cand in Lista do
  begin
    Otro := FNodos[Cand];
    Pref := Otro.Clave.IdEstructura + '.';
    if (Length(Info.Clave.IdEstructura) > Length(Pref)) and
      (Copy(Info.Clave.IdEstructura, 1, Length(Pref)) = Pref) then
    begin
      Result := Cand;
      Exit;
    end;
  end;
end;

procedure TArbolNodos.Resolver;
var
  Par: TPair<string, TInfoNodo>;
  P: string;
begin
  if FPadresValidos then
    Exit;
  FPadres.Clear;
  for Par in FNodos do
  begin
    P := BuscarPadre(Par.Value);
    if (P <> '') and (P <> Par.Key) then
      FPadres.Add(Par.Key, P);
  end;
  FPadresValidos := True;
end;

function TArbolNodos.Contiene(const Nodo: TClaveNodo): Boolean;
begin
  Result := FNodos.ContainsKey(ClaveInterna(Nodo));
end;

function TArbolNodos.Ancestros(const Nodo: TClaveNodo): TArray<TClaveNodo>;
var
  Lista: TList<TClaveNodo>;
  K, P: string;
  Visitados: TList<string>;
begin
  Resolver;
  Lista := TList<TClaveNodo>.Create;
  Visitados := TList<string>.Create;
  try
    K := ClaveInterna(Nodo);
    Visitados.Add(K);
    while FPadres.TryGetValue(K, P) do
    begin
      if Visitados.Contains(P) then
        Break; // proteccion ante ciclos
      Visitados.Add(P);
      Lista.Add(FNodos[P].Clave);
      K := P;
    end;
    Result := Lista.ToArray;
  finally
    Visitados.Free;
    Lista.Free;
  end;
end;

function TArbolNodos.EsDescendiente(const Raiz, Nodo: TClaveNodo): Boolean;
var
  KR, K, P: string;
  Pasos: Integer;
begin
  Resolver;
  KR := ClaveInterna(Raiz);
  K := ClaveInterna(Nodo);
  if K = KR then
    Exit(True);
  Result := False;
  Pasos := 0;
  while FPadres.TryGetValue(K, P) and (Pasos <= FNodos.Count) do
  begin
    if P = KR then
      Exit(True);
    K := P;
    Inc(Pasos);
  end;
end;

end.
