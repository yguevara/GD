unit UAlcance;

{ Reglas puras de alcance: roles, acciones y arbol de nodos.
  Sin dependencias de VCL ni de FireDAC. }

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  TRolNodo = (rnVisor, rnUsuario, rnDirector, rnEGD, rnAdministrador);

  TAccion = (acVer, acAgregar, acEditar, acEliminar, acPrestar, acTransferir,
    acDepurar, acAsignarUsuarios, acEditarTopografia);

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
    function Todos: TArray<TClaveNodo>;
  end;

  TAsignacionNodo = record
    Nodo: TClaveNodo;
    Rol: TRolNodo;   // rnDirector o rnEGD
  end;

  TSubserieAsignada = record
    Nodo: TClaveNodo;
    CodSubs: string;
  end;

  { Cobertura de un usuario. No es duena del arbol recibido (lo libera el
    llamador); copia los arreglos. }
  TAlcanceUsuario = class
  private
    FEsAdministrador: Boolean;
    FArbol: TArbolNodos;
    FNodos: TArray<TAsignacionNodo>;
    FSubseries: TArray<TSubserieAsignada>;
    FSubseriesPublicas: TArray<string>;
    FNodosConPublica: TArray<TClaveNodo>;
    FPoseeArbol: Boolean;
    function MismoNodo(const A, B: TClaveNodo): Boolean;
    function Permite(Accion: TAccion; const Nodo: TClaveNodo;
      const CodSubs: string): Boolean;
    procedure Acumular(Dic: TDictionary<string, TClaveNodo>;
      const Nodo: TClaveNodo);
    procedure AcumularConAncestros(Dic: TDictionary<string, TClaveNodo>;
      const Nodo: TClaveNodo);
  public
    constructor Create(EsAdministrador: Boolean; Arbol: TArbolNodos;
      const Nodos: TArray<TAsignacionNodo>;
      const Subseries: TArray<TSubserieAsignada>;
      const SubseriesPublicas: TArray<string>);
    destructor Destroy; override;
    function PuedeVerDocumento(const Nodo: TClaveNodo; const CodSubs: string;
      NivelAcceso: Integer): Boolean;
    function PuedeRealizar(Accion: TAccion; const Nodo: TClaveNodo;
      const CodSubs: string): Boolean;
    { Indica si el usuario puede eliminar un documento del par (Nodo, CodSubs).
      Reglas: el administrador nunca; el EGD de ese nodo siempre, sin ventana de
      dias; el Director del nodo o de un ancestro solo el primer dia
      (DiasDesdeFecha <= 1); el Usuario y el Visor nunca. Los dias negativos
      cuentan como 0 y un nodo que no existe en el arbol no concede nada. }
    function PuedeEliminarDocumento(const Nodo: TClaveNodo; const CodSubs: string;
      DiasDesdeFecha: Integer): Boolean;
    { True si el usuario es EGD de algun nodo que existe en el arbol. Lo usa la
      interfaz para que un Gestor del sistema viejo, mientras no sea EGD de
      ningun nodo, conserve su regla heredada. El administrador no es EGD. }
    function EsEGDDeAlgunNodo: Boolean;
    function NodosVisibles: TArray<TClaveNodo>;
    function NodosCompletos: TArray<TClaveNodo>;
    { Asignaciones de subserie que conceden cobertura: nodo existente en el
      arbol y codigo no vacio. Clave de nodo y codigo normalizados. }
    function SubseriesEfectivas: TArray<TSubserieAsignada>;
    { Si es True, el alcance libera el arbol al destruirse (lo usa CargarAlcance). }
    property PoseeArbol: Boolean read FPoseeArbol write FPoseeArbol;
    property EsAdministrador: Boolean read FEsAdministrador;
    property SubseriesPublicas: TArray<string> read FSubseriesPublicas;
    { Nodos que tienen alguna subserie publica. Solo ensanchan el arbol visible
      (con sus ancestros); no dan cobertura ni permisos. }
    property NodosConPublica: TArray<TClaveNodo> read FNodosConPublica
      write FNodosConPublica;
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
    rnUsuario, rnDirector:
      Result := Accion in [acVer, acAgregar, acEditar];
    rnAdministrador:
      Result := Accion in [acVer, acAgregar, acEditar, acEditarTopografia];
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

function TArbolNodos.Todos: TArray<TClaveNodo>;
var
  Lista: TList<TClaveNodo>;
  Par: TPair<string, TInfoNodo>;
begin
  Lista := TList<TClaveNodo>.Create;
  try
    for Par in FNodos do
      Lista.Add(Par.Value.Clave);
    Result := Lista.ToArray;
  finally
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

{ TAlcanceUsuario }

constructor TAlcanceUsuario.Create(EsAdministrador: Boolean; Arbol: TArbolNodos;
  const Nodos: TArray<TAsignacionNodo>;
  const Subseries: TArray<TSubserieAsignada>;
  const SubseriesPublicas: TArray<string>);
begin
  inherited Create;
  FEsAdministrador := EsAdministrador;
  FArbol := Arbol;
  FNodos := Copy(Nodos);
  FSubseries := Copy(Subseries);
  FSubseriesPublicas := Copy(SubseriesPublicas);
end;

destructor TAlcanceUsuario.Destroy;
begin
  if FPoseeArbol then
    FArbol.Free;
  inherited;
end;

function TAlcanceUsuario.MismoNodo(const A, B: TClaveNodo): Boolean;
begin
  Result := (A.Id = B.Id) and
    (NormalizaClave(A.IdEstructura) = NormalizaClave(B.IdEstructura));
end;

function TAlcanceUsuario.Permite(Accion: TAccion; const Nodo: TClaveNodo;
  const CodSubs: string): Boolean;
var
  A: TAsignacionNodo;
  S: TSubserieAsignada;
begin
  if FEsAdministrador then
    Exit(RolPermite(rnAdministrador, Accion));
  Result := False;
  for A in FNodos do
  begin
    // un nodo asignado que no existe en el arbol no concede nada
    if not FArbol.Contiene(A.Nodo) then
      Continue;
    if not RolPermite(A.Rol, Accion) then
      Continue;
    case A.Rol of
      rnDirector:
        if FArbol.EsDescendiente(A.Nodo, Nodo) then
          Exit(True);
      rnEGD:
        if MismoNodo(A.Nodo, Nodo) then
          Exit(True);
    end;
  end;
  if not RolPermite(rnUsuario, Accion) then
    Exit;
  for S in FSubseries do
    // una asignacion sin codigo de subserie no concede nada (fallo cerrado)
    if (NormalizaClave(S.CodSubs) <> '') and
      FArbol.Contiene(S.Nodo) and MismoNodo(S.Nodo, Nodo) and
      (NormalizaClave(S.CodSubs) = NormalizaClave(CodSubs)) then
      Exit(True);
end;

function TAlcanceUsuario.PuedeVerDocumento(const Nodo: TClaveNodo;
  const CodSubs: string; NivelAcceso: Integer): Boolean;
begin
  Result := (NivelAcceso = 1) or Permite(acVer, Nodo, CodSubs);
end;

function TAlcanceUsuario.PuedeRealizar(Accion: TAccion; const Nodo: TClaveNodo;
  const CodSubs: string): Boolean;
begin
  Result := Permite(Accion, Nodo, CodSubs);
end;

function TAlcanceUsuario.EsEGDDeAlgunNodo: Boolean;
var
  A: TAsignacionNodo;
begin
  Result := False;
  if FEsAdministrador then
    Exit;
  for A in FNodos do
    if (A.Rol = rnEGD) and FArbol.Contiene(A.Nodo) then
      Exit(True);
end;

function TAlcanceUsuario.PuedeEliminarDocumento(const Nodo: TClaveNodo;
  const CodSubs: string; DiasDesdeFecha: Integer): Boolean;
const
  DIAS_VENTANA_DIRECTOR = 1;
var
  A: TAsignacionNodo;
begin
  Result := False;
  if FEsAdministrador or not FArbol.Contiene(Nodo) then
    Exit;
  if DiasDesdeFecha < 0 then
    DiasDesdeFecha := 0;
  for A in FNodos do
  begin
    if not FArbol.Contiene(A.Nodo) then
      Continue;
    case A.Rol of
      rnEGD:
        if MismoNodo(A.Nodo, Nodo) then
          Exit(True);
      rnDirector:
        if (DiasDesdeFecha <= DIAS_VENTANA_DIRECTOR) and
          FArbol.EsDescendiente(A.Nodo, Nodo) then
          Exit(True);
    end;
  end;
end;

procedure TAlcanceUsuario.Acumular(Dic: TDictionary<string, TClaveNodo>;
  const Nodo: TClaveNodo);
begin
  Dic.AddOrSetValue(NormalizaClave(Nodo.IdEstructura) + '|' + IntToStr(Nodo.Id),
    Nodo);
end;

procedure TAlcanceUsuario.AcumularConAncestros(
  Dic: TDictionary<string, TClaveNodo>; const Nodo: TClaveNodo);
var
  Anc: TClaveNodo;
begin
  Acumular(Dic, Nodo);
  for Anc in FArbol.Ancestros(Nodo) do
    Acumular(Dic, Anc);
end;

function TAlcanceUsuario.NodosVisibles: TArray<TClaveNodo>;
var
  Dic: TDictionary<string, TClaveNodo>;
  A: TAsignacionNodo;
  S: TSubserieAsignada;
  T: TClaveNodo;
begin
  if FEsAdministrador then
    Exit(FArbol.Todos);
  Dic := TDictionary<string, TClaveNodo>.Create;
  try
    for A in FNodos do
    begin
      if not FArbol.Contiene(A.Nodo) then
        Continue;
      case A.Rol of
        rnDirector:
          begin
            for T in FArbol.Todos do
              if FArbol.EsDescendiente(A.Nodo, T) then
                AcumularConAncestros(Dic, T);
            AcumularConAncestros(Dic, A.Nodo);
          end;
        rnEGD:
          AcumularConAncestros(Dic, A.Nodo);
      end;
    end;
    for S in SubseriesEfectivas do
      AcumularConAncestros(Dic, S.Nodo);
    for T in FNodosConPublica do
      if FArbol.Contiene(T) then
        AcumularConAncestros(Dic, T);
    Result := Dic.Values.ToArray;
  finally
    Dic.Free;
  end;
end;

function TAlcanceUsuario.NodosCompletos: TArray<TClaveNodo>;
var
  Dic: TDictionary<string, TClaveNodo>;
  A: TAsignacionNodo;
  T: TClaveNodo;
begin
  if FEsAdministrador then
    Exit(nil);
  Dic := TDictionary<string, TClaveNodo>.Create;
  try
    for A in FNodos do
    begin
      if not FArbol.Contiene(A.Nodo) then
        Continue;
      case A.Rol of
        rnDirector:
          for T in FArbol.Todos do
            if FArbol.EsDescendiente(A.Nodo, T) then
              Acumular(Dic, T);
        rnEGD:
          Acumular(Dic, A.Nodo);
      end;
    end;
    Result := Dic.Values.ToArray;
  finally
    Dic.Free;
  end;
end;

function TAlcanceUsuario.SubseriesEfectivas: TArray<TSubserieAsignada>;
var
  Lista: TList<TSubserieAsignada>;
  S, R: TSubserieAsignada;
begin
  Lista := TList<TSubserieAsignada>.Create;
  try
    for S in FSubseries do
    begin
      if (NormalizaClave(S.CodSubs) = '') or not FArbol.Contiene(S.Nodo) then
        Continue;
      R.Nodo.IdEstructura := NormalizaClave(S.Nodo.IdEstructura);
      R.Nodo.Id := S.Nodo.Id;
      R.CodSubs := NormalizaClave(S.CodSubs);
      Lista.Add(R);
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

end.
