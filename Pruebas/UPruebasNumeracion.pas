unit UPruebasNumeracion;

{ Formato y lectura de los numeros de proceso (2026-0047, T-2026-02, D-2026-01). }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasNumeracion = class
  public
    [Test]
    procedure FormateaPrestamo;
    [Test]
    procedure FormateaTransferencia;
    [Test]
    procedure FormateaDepuracion;
    [Test]
    procedure NoTruncaConsecutivosGrandes;
    [Test]
    procedure LeeLoQueFormatea;
    [Test]
    procedure RechazaTextoInvalido;
  end;

implementation

uses
  System.SysUtils, UProceso, UNumeracion;

procedure TPruebasNumeracion.FormateaPrestamo;
begin
  Assert.AreEqual('2026-0047', FormatearNumero(tpPrestamo, 2026, 47));
end;

procedure TPruebasNumeracion.FormateaTransferencia;
begin
  Assert.AreEqual('T-2026-02', FormatearNumero(tpTransferencia, 2026, 2));
end;

procedure TPruebasNumeracion.FormateaDepuracion;
begin
  Assert.AreEqual('D-2026-01', FormatearNumero(tpDepuracion, 2026, 1));
end;

procedure TPruebasNumeracion.NoTruncaConsecutivosGrandes;
begin
  Assert.AreEqual('T-2026-123', FormatearNumero(tpTransferencia, 2026, 123));
  Assert.AreEqual('2026-12345', FormatearNumero(tpPrestamo, 2026, 12345));
end;

procedure TPruebasNumeracion.LeeLoQueFormatea;
var
  T: TTipoProceso;
  Tipo: TTipoProceso;
  Anio, Cons: Integer;
begin
  for T := Low(TTipoProceso) to High(TTipoProceso) do
  begin
    Assert.IsTrue(LeerNumero(FormatearNumero(T, 2027, 9), Tipo, Anio, Cons));
    Assert.IsTrue(Tipo = T);
    Assert.AreEqual(2027, Anio);
    Assert.AreEqual(9, Cons);
  end;
end;

procedure TPruebasNumeracion.RechazaTextoInvalido;
var
  Tipo: TTipoProceso;
  Anio, Cons: Integer;
begin
  Assert.IsFalse(LeerNumero('', Tipo, Anio, Cons));
  Assert.IsFalse(LeerNumero('X-2026-01', Tipo, Anio, Cons));
  Assert.IsFalse(LeerNumero('T-26-01', Tipo, Anio, Cons));
  Assert.IsFalse(LeerNumero('T-2026-', Tipo, Anio, Cons));
  Assert.IsFalse(LeerNumero('2026-ab', Tipo, Anio, Cons));
end;

end.
