unit UPruebasBusqueda;

{ Pruebas de la busqueda integrada.
  - TPruebasBusqueda: reglas puras y texto SQL de UBusqueda, sin base de datos. }

interface

uses
  DUnitX.TestFramework, UAlcanceDatos, UBusqueda;

type
  [TestFixture]
  TPruebasBusqueda = class
  private
    function Campos: TArray<TCampoBusqueda>;
    function Pedido(const Texto: string): TPedidoBusqueda;
    function Cond(const Campo, Desde, Hasta: string): TCondicionCampo;
    function SinAlcance: TFiltroSql;
    function TieneValor(const F: TFiltroSql; const Valor: string): Boolean;
  public
    [Test]
    procedure EscaparLike_PorcientoGuionYCorchete;
    [Test]
    procedure NombreSeguro_RechazaEspaciosYComillas;
    [Test]
    procedure TipoDeNombre_ConocidosYDesconocido;
    [Test]
    procedure ValidarPedido_SinNadaSeRechaza;
    [Test]
    procedure ValidarPedido_SoloTextoOSoloSubserieEsValido;
    [Test]
    procedure ValidarPedido_RangoInvertido;
    [Test]
    procedure SqlSubserie_ConTabla;
    [Test]
    procedure SqlSubserie_SinTabla;
    [Test]
    procedure SqlSubserie_CampoAjeno;
    [Test]
    procedure SqlSubserie_SqlServerUsaCollate;
    [Test]
    procedure SqlSubserie_IncluyeAlcance;
    [Test]
    procedure SqlSubserie_FechaHastaIncluyeElDia;
    [Test]
    procedure ValidarPedido_NodoActualSinNodo;
    [Test]
    procedure SqlSubserie_NodoActualRestringeIdEstructura;
    [Test]
    procedure SqlSubserie_NodoActualConservaElAlcance;
    [Test]
    procedure SqlSubserie_NodoActualMuchosNodos;
  end;

implementation

uses
  System.SysUtils, System.Variants;

function TPruebasBusqueda.Campos: TArray<TCampoBusqueda>;
begin
  SetLength(Result, 4);
  Result[0].Nombre := 'Depto';     Result[0].Etiqueta := 'Departamento'; Result[0].Tipo := tcCaracteres;
  Result[1].Nombre := 'Fecha_ing'; Result[1].Etiqueta := 'Ingreso';      Result[1].Tipo := tcFecha;
  Result[2].Nombre := 'Folios';    Result[2].Etiqueta := 'Folios';       Result[2].Tipo := tcEntero;
  Result[3].Nombre := 'Activo';    Result[3].Etiqueta := 'Activo';       Result[3].Tipo := tcBooleano;
end;

function TPruebasBusqueda.Pedido(const Texto: string): TPedidoBusqueda;
begin
  Result.Texto := Texto;
  Result.CodSubs := '014001';
  Result.Condiciones := nil;
  Result.Limite := 0;
  Result.Ambito := abGeneral;
  Result.IdsNodo := nil;
end;

function TPruebasBusqueda.Cond(const Campo, Desde, Hasta: string): TCondicionCampo;
begin
  Result.Campo := Campo;
  Result.Desde := Desde;
  Result.Hasta := Hasta;
end;

function TPruebasBusqueda.SinAlcance: TFiltroSql;
begin
  Result.Condicion := '1=1';
  Result.Parametros := nil;
end;

function TPruebasBusqueda.TieneValor(const F: TFiltroSql; const Valor: string): Boolean;
var
  P: TParametroSql;
begin
  for P in F.Parametros do
    if VarToStr(P.Valor) = Valor then
      Exit(True);
  Result := False;
end;

procedure TPruebasBusqueda.EscaparLike_PorcientoGuionYCorchete;
begin
  Assert.AreEqual('50[%][_][[]a]', EscaparLike('50%_[a]'));
  Assert.AreEqual('normal', EscaparLike('normal'));
end;

procedure TPruebasBusqueda.NombreSeguro_RechazaEspaciosYComillas;
begin
  Assert.IsTrue(NombreSeguro('Depto'));
  Assert.IsTrue(NombreSeguro('_x1'));
  Assert.IsFalse(NombreSeguro('a b'));
  Assert.IsFalse(NombreSeguro('x;drop'));
  Assert.IsFalse(NombreSeguro('1abc'));
  Assert.IsFalse(NombreSeguro(''));
  Assert.IsFalse(NombreSeguro('a''b'));
end;

procedure TPruebasBusqueda.TipoDeNombre_ConocidosYDesconocido;
begin
  Assert.AreEqual(Ord(tcCaracteres), Ord(TipoDeNombre('Caracteres')));
  Assert.AreEqual(Ord(tcBooleano), Ord(TipoDeNombre('Boolean')));
  Assert.WillRaise(
    procedure begin TipoDeNombre('Otro'); end, EArgumentException);
end;

procedure TPruebasBusqueda.ValidarPedido_SinNadaSeRechaza;
var
  P: TPedidoBusqueda;
begin
  P := Pedido('');
  P.CodSubs := '';
  Assert.AreNotEqual('', ValidarPedido(P));
  P.Texto := '   ';
  Assert.AreNotEqual('', ValidarPedido(P));
end;

procedure TPruebasBusqueda.ValidarPedido_SoloTextoOSoloSubserieEsValido;
var
  P: TPedidoBusqueda;
begin
  P := Pedido('acta');
  P.CodSubs := '';
  Assert.AreEqual('', ValidarPedido(P));
  P := Pedido('');
  Assert.AreEqual('', ValidarPedido(P));
end;

procedure TPruebasBusqueda.ValidarPedido_RangoInvertido;
var
  P: TPedidoBusqueda;
begin
  P := Pedido('');
  P.Condiciones := [Cond('Fecha_ing', '2026-02-01', '2026-01-01')];
  Assert.AreNotEqual('', ValidarPedido(P));
end;

procedure TPruebasBusqueda.SqlSubserie_ConTabla;
var
  F: TFiltroSql;
begin
  F := SqlSubserie(Pedido('camaguey'), Campos, 'md_014001', SinAlcance, True);
  Assert.IsTrue(Pos('LEFT JOIN md_014001 M ON', F.Condicion) > 0, 'falta el join');
  Assert.IsTrue(Pos('S.IdEstructura = M.IdEstructura', F.Condicion) > 0);
  Assert.IsTrue(Pos('S.id = M.id', F.Condicion) > 0);
  Assert.IsTrue(Pos('S.codsubs = M.codsubs', F.Condicion) > 0);
  Assert.IsTrue(Pos('S.Fecha = M.Fecha', F.Condicion) > 0);
  Assert.IsTrue(Pos('S.Version = M.Version', F.Condicion) > 0);
  Assert.IsTrue(Pos('S.Codigodoc = M.Codigodoc', F.Condicion) > 0);
  Assert.IsTrue(Pos('S.titulodoc', F.Condicion) > 0);
  Assert.IsTrue(Pos('M.Depto', F.Condicion) > 0);
  Assert.IsTrue(Pos('LIKE', F.Condicion) > 0);
  Assert.AreEqual(0, Pos('camaguey', F.Condicion), 'el texto no va en el SQL');
  Assert.IsTrue(TieneValor(F, '%camaguey%'));
end;

procedure TPruebasBusqueda.SqlSubserie_SinTabla;
var
  F: TFiltroSql;
begin
  F := SqlSubserie(Pedido('acta'), Campos, '', SinAlcance, False);
  Assert.AreEqual(0, Pos('JOIN', F.Condicion));
  Assert.AreEqual(0, Pos('M.', F.Condicion));
  Assert.IsTrue(Pos('S.titulodoc', F.Condicion) > 0);
end;

procedure TPruebasBusqueda.SqlSubserie_CampoAjeno;
var
  P: TPedidoBusqueda;
begin
  P := Pedido('');
  P.Condiciones := [Cond('Secreto', 'x', '')];
  Assert.WillRaise(
    procedure begin SqlSubserie(P, Campos, 'md_014001', SinAlcance, True); end,
    EArgumentException);
end;

procedure TPruebasBusqueda.SqlSubserie_SqlServerUsaCollate;
begin
  Assert.IsTrue(Pos('COLLATE Modern_Spanish_CI_AI',
    SqlSubserie(Pedido('a'), Campos, 'md_014001', SinAlcance, True).Condicion) > 0);
  Assert.AreEqual(0, Pos('COLLATE',
    SqlSubserie(Pedido('a'), Campos, 'md_014001', SinAlcance, False).Condicion));
end;

procedure TPruebasBusqueda.SqlSubserie_IncluyeAlcance;
var
  A, F: TFiltroSql;
begin
  A.Condicion := '(S.IdEstructura = :alcd_1)';
  SetLength(A.Parametros, 1);
  A.Parametros[0].Nombre := 'alcd_1';
  A.Parametros[0].Valor := 'A.4.3';
  F := SqlSubserie(Pedido('acta'), Campos, 'md_014001', A, True);
  Assert.IsTrue(Pos('(S.IdEstructura = :alcd_1)', F.Condicion) > 0);
  Assert.IsTrue(TieneValor(F, 'A.4.3'), 'se pierde el parametro del alcance');
  Assert.IsTrue(Pos(' AND ', F.Condicion) > 0);
end;

procedure TPruebasBusqueda.SqlSubserie_FechaHastaIncluyeElDia;
var
  P: TPedidoBusqueda;
  F: TFiltroSql;
  Par: TParametroSql;
  Fechas: Integer;
begin
  P := Pedido('');
  P.Condiciones := [Cond('Fecha_ing', '2026-01-01', '2026-01-31')];
  F := SqlSubserie(P, Campos, 'md_014001', SinAlcance, True);
  Assert.IsTrue(Pos('M.Fecha_ing >=', F.Condicion) > 0);
  Assert.IsTrue(Pos('M.Fecha_ing <', F.Condicion) > 0);
  Fechas := 0;
  for Par in F.Parametros do
    if VarIsType(Par.Valor, varDate) then
    begin
      Inc(Fechas);
      Assert.IsTrue((VarToDateTime(Par.Valor) = EncodeDate(2026, 1, 1)) or
        (VarToDateTime(Par.Valor) = EncodeDate(2026, 2, 1)),
        'la cota superior es el dia siguiente a Hasta');
    end;
  Assert.AreEqual(2, Fechas);
end;

procedure TPruebasBusqueda.ValidarPedido_NodoActualSinNodo;
var
  P: TPedidoBusqueda;
begin
  P := Pedido('acta');
  P.Ambito := abNodoActual;
  P.IdsNodo := nil;
  Assert.AreEqual('Elija un nodo del arbol para buscar en el nodo actual.',
    ValidarPedido(P));
  P.Ambito := abGeneral;
  Assert.AreEqual('', ValidarPedido(P));
  P.Ambito := abNodoActual;
  P.IdsNodo := ['A.4.3'];
  Assert.AreEqual('', ValidarPedido(P));
end;

procedure TPruebasBusqueda.SqlSubserie_NodoActualRestringeIdEstructura;
var
  P: TPedidoBusqueda;
  F: TFiltroSql;
begin
  P := Pedido('acta');
  P.Ambito := abNodoActual;
  P.IdsNodo := ['A.4.3', 'A.4.3.1'];
  F := SqlSubserie(P, Campos, '', SinAlcance, True);
  Assert.IsTrue(Pos('S.IdEstructura IN (', F.Condicion) > 0, 'falta el IN');
  Assert.AreEqual(0, Pos('A.4.3', F.Condicion), 'los nodos no van en el SQL');
  Assert.IsTrue(TieneValor(F, 'A.4.3'), 'falta el primer nodo como parametro');
  Assert.IsTrue(TieneValor(F, 'A.4.3.1'), 'falta el segundo nodo como parametro');
  P.Ambito := abGeneral;
  P.IdsNodo := nil;
  F := SqlSubserie(P, Campos, '', SinAlcance, True);
  Assert.AreEqual(0, Pos('S.IdEstructura IN (', F.Condicion), 'el general no restringe');
end;

procedure TPruebasBusqueda.SqlSubserie_NodoActualConservaElAlcance;
var
  A, F: TFiltroSql;
  P: TPedidoBusqueda;
begin
  A.Condicion := '(S.IdEstructura = :alcd_1)';
  SetLength(A.Parametros, 1);
  A.Parametros[0].Nombre := 'alcd_1';
  A.Parametros[0].Valor := 'A.4.3';
  P := Pedido('acta');
  P.Ambito := abNodoActual;
  P.IdsNodo := ['A.4.3', 'A.4.3.1'];
  F := SqlSubserie(P, Campos, '', A, True);
  Assert.IsTrue(Pos('WHERE ((S.IdEstructura = :alcd_1)) AND', F.Condicion) > 0,
    'el alcance debe seguir antes de las demas restricciones');
  Assert.IsTrue(Pos(' AND S.IdEstructura IN (', F.Condicion) > 0);
  Assert.IsTrue(TieneValor(F, 'A.4.3'), 'se pierde el parametro del alcance');
end;

procedure TPruebasBusqueda.SqlSubserie_NodoActualMuchosNodos;
var
  P: TPedidoBusqueda;
  F, F1: TFiltroSql;
  I: Integer;
begin
  P := Pedido('acta');
  P.Ambito := abNodoActual;
  SetLength(P.IdsNodo, 1200);
  for I := 0 to 1198 do
    P.IdsNodo[I] := 'A.9.' + IntToStr(I + 1);
  P.IdsNodo[1199] := 'A.9''x'; // despues del tope
  F := SqlSubserie(P, Campos, '', SinAlcance, True);
  P.IdsNodo := ['A.9.1'];
  F1 := SqlSubserie(P, Campos, '', SinAlcance, True);
  Assert.IsTrue(Length(F.Parametros) <= Length(F1.Parametros) + LIMITE_NODOS_PARAMETRO,
    'los parametros de nodo no pasan del tope');
  Assert.IsTrue(Pos('''A.9''''x''', F.Condicion) > 0, 'literal con apostrofe doblado');
  Assert.IsTrue(TieneValor(F, 'A.9.1'), 'los primeros van como parametro');
  Assert.AreEqual(0, Pos('''A.9.1''', F.Condicion), 'los primeros no son literales');
  Assert.IsFalse(TieneValor(F, 'A.9.1100'), 'los ultimos no son parametros');
  Assert.IsTrue(Pos('''A.9.1100''', F.Condicion) > 0, 'los ultimos son literales');end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasBusqueda);

end.
