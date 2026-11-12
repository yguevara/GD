unit UPruebasCandados;

{ Candado "un documento, un proceso abierto" y clave normalizada de unidad. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasCandados = class
  public
    [Test]
    procedure ClaveIgnoraMayusculasYEspacios;
    [Test]
    procedure MismoIdEnOtroNodoEsOtraClave;
    [Test]
    procedure ClaveConDobleCeroSoloNormaliza;
    [Test]
    procedure MismoCodigoEnOtraSubserieEsOtraClave;
    [Test]
    procedure DistingueVersionYFecha;
    [Test]
    procedure EntraSinBloqueo;
    [Test]
    procedure NoEntraConBloqueoYExplicaQuien;
  end;

implementation

uses
  System.SysUtils, UProceso, UCandados;

function Unidad(const IdEstr: string; Id: Integer): TUnidadDoc;
begin
  Result.IdEstructura := IdEstr;
  Result.Id := Id;
  Result.CodSubs := 'S1';
  Result.CodigoDoc := 'D-1';
  Result.Fecha := EncodeDate(2020, 5, 17);
  Result.Version := '1';
end;

procedure TPruebasCandados.ClaveIgnoraMayusculasYEspacios;
begin
  Assert.AreEqual(ClaveUnidad(Unidad('A.1.6', 160)), ClaveUnidad(Unidad('a.1.6 ', 160)));
end;

procedure TPruebasCandados.MismoIdEnOtroNodoEsOtraClave;
begin
  Assert.AreNotEqual(ClaveUnidad(Unidad('A.1.7', 160)), ClaveUnidad(Unidad('A.3.3', 160)));
end;

procedure TPruebasCandados.ClaveConDobleCeroSoloNormaliza;
begin
  Assert.AreEqual(ClaveUnidad(Unidad('A.6..3.3', 5)), ClaveUnidad(Unidad(' a.6..3.3', 5)));
  Assert.AreNotEqual(ClaveUnidad(Unidad('A.6..3.3', 5)), ClaveUnidad(Unidad('A.6.3.3', 5)));
end;

procedure TPruebasCandados.MismoCodigoEnOtraSubserieEsOtraClave;
var
  A, B: TUnidadDoc;
begin
  // tb_SeriesDatos incluye codsubs en su clave: el mismo codigo, fecha y version
  // en dos subseries del mismo nodo son documentos distintos
  A := Unidad('A.1', 1);
  B := A;
  B.CodSubs := 'S2';
  Assert.AreNotEqual(ClaveUnidad(A), ClaveUnidad(B));
  B.CodSubs := ' s1 ';
  Assert.AreEqual(ClaveUnidad(A), ClaveUnidad(B), 'el codsubs se compara sin espacios');
end;

procedure TPruebasCandados.DistingueVersionYFecha;
var
  A, B: TUnidadDoc;
begin
  A := Unidad('A.1', 1);
  B := A;
  B.Version := '2';
  Assert.AreNotEqual(ClaveUnidad(A), ClaveUnidad(B));
  B := A;
  B.Fecha := A.Fecha + 1;
  Assert.AreNotEqual(ClaveUnidad(A), ClaveUnidad(B));
end;

procedure TPruebasCandados.EntraSinBloqueo;
var
  B: TBloqueo;
  Motivo: string;
begin
  B.Tipo := tpPrestamo;
  B.Numero := '';
  Assert.IsTrue(PuedeEntrar(B, False, Motivo));
  Assert.AreEqual('', Motivo);
end;

procedure TPruebasCandados.NoEntraConBloqueoYExplicaQuien;
var
  B: TBloqueo;
  Motivo: string;
begin
  B.Tipo := tpPrestamo;
  B.Numero := '2026-0047';
  Assert.IsFalse(PuedeEntrar(B, True, Motivo));
  Assert.AreEqual('En prestamo 2026-0047', Motivo);
  B.Tipo := tpTransferencia;
  B.Numero := 'T-2026-02';
  Assert.IsFalse(PuedeEntrar(B, True, Motivo));
  Assert.AreEqual('En transferencia T-2026-02', Motivo);
  B.Tipo := tpDepuracion;
  B.Numero := 'D-2026-01';
  Assert.IsFalse(PuedeEntrar(B, True, Motivo));
  Assert.AreEqual('En depuracion D-2026-01', Motivo);
end;

end.
