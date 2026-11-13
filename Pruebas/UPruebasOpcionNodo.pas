unit UPruebasOpcionNodo;

{ Opciones de nodo de trabajo de las pantallas de procesos: busqueda por clave
  (tolerante a mayusculas y espacios), eleccion por defecto y texto de ruta. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasOpcionNodo = class
  public
    [Test]
    procedure IndiceEncuentraElNodoSinImportarMayusculasNiEspacios;
    [Test]
    procedure IndiceDistingueNodosConElMismoId;
    [Test]
    procedure IndiceDeNodoAusenteEsMenosUno;
    [Test]
    procedure ElegirPrefiereElNodoPedido;
    [Test]
    procedure ElegirUsaLaPrimeraSiElPreferidoNoEsta;
    [Test]
    procedure ElegirSinOpcionesDevuelveMenosUno;
    [Test]
    procedure RutaUneConBarraInvertidaYOmiteVacios;
  end;

implementation

uses
  System.SysUtils, UAlcance, UOpcionNodo;

function Opcion(const IdEstr: string; Id: Integer; const Texto: string): TOpcionNodo;
begin
  Result.Clave.IdEstructura := IdEstr;
  Result.Clave.Id := Id;
  Result.Texto := Texto;
end;

function Clave(const IdEstr: string; Id: Integer): TClaveNodo;
begin
  Result.IdEstructura := IdEstr;
  Result.Id := Id;
end;

procedure TPruebasOpcionNodo.IndiceEncuentraElNodoSinImportarMayusculasNiEspacios;
var
  O: TArray<TOpcionNodo>;
begin
  O := [Opcion('A.1', 10, 'Uno'), Opcion('a.4.3 ', 104, 'Planeamiento')];
  Assert.AreEqual(1, IndiceDeNodo(O, Clave('A.4.3', 104)));
end;

procedure TPruebasOpcionNodo.IndiceDistingueNodosConElMismoId;
var
  O: TArray<TOpcionNodo>;
begin
  // el id no es unico por si solo: se compara tambien la estructura
  O := [Opcion('A.1.7', 160, 'Uno'), Opcion('A.3.3', 160, 'Dos')];
  Assert.AreEqual(1, IndiceDeNodo(O, Clave('A.3.3', 160)));
end;

procedure TPruebasOpcionNodo.IndiceDeNodoAusenteEsMenosUno;
begin
  Assert.AreEqual(-1, IndiceDeNodo([Opcion('A.1', 1, 'x')], Clave('B.9', 9)));
  Assert.AreEqual(-1, IndiceDeNodo(nil, Clave('A.1', 1)));
end;

procedure TPruebasOpcionNodo.ElegirPrefiereElNodoPedido;
begin
  Assert.AreEqual(1, ElegirNodo([Opcion('A.1', 1, 'x'), Opcion('A.2', 2, 'y')], Clave('A.2', 2)));
end;

procedure TPruebasOpcionNodo.ElegirUsaLaPrimeraSiElPreferidoNoEsta;
begin
  Assert.AreEqual(0, ElegirNodo([Opcion('A.1', 1, 'x'), Opcion('A.2', 2, 'y')], Clave('Z', 99)));
end;

procedure TPruebasOpcionNodo.ElegirSinOpcionesDevuelveMenosUno;
begin
  Assert.AreEqual(-1, ElegirNodo(nil, Clave('A.1', 1)));
end;

procedure TPruebasOpcionNodo.RutaUneConBarraInvertidaYOmiteVacios;
begin
  Assert.AreEqual('Inversiones \ Planeamiento', RutaTexto(['Inversiones', '', 'Planeamiento']));
  Assert.AreEqual('Solo', RutaTexto(['Solo']));
  Assert.AreEqual('', RutaTexto([]));
end;

end.
