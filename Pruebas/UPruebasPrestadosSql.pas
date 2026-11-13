unit UPruebasPrestadosSql;

{ SQL de "documentos prestados": lee los prestamos nuevos (prc_bloqueo) y los
  viejos abiertos (TB_Prestamos) y los une sin duplicar. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasPrestadosSql = class
  private
    function Contar(const Texto, Fragmento: string): Integer;
  public
    [Test]
    procedure CombinadoLeeNuevosYViejos;
    [Test]
    procedure CombinadoUneSinDuplicar;
    [Test]
    procedure CombinadoAplicaElFiltroEnAmbasMitades;
    [Test]
    procedure NuevosSoloCuentaPrestamosNoOtrosProcesos;
    [Test]
    procedure ViejosExcluyeDevueltosYCancelados;
    [Test]
    procedure SubserieDevuelveFechaVersionYCodigo;
    [Test]
    procedure SubserieUsaLosMismosParametrosEnAmbasMitades;
  end;

implementation

uses
  System.SysUtils, UPrestadosSql;

function TPruebasPrestadosSql.Contar(const Texto, Fragmento: string): Integer;
var
  P: Integer;
begin
  Result := 0;
  P := Pos(Fragmento, Texto);
  while P > 0 do
  begin
    Inc(Result);
    P := Pos(Fragmento, Texto, P + Length(Fragmento));
  end;
end;

procedure TPruebasPrestadosSql.CombinadoLeeNuevosYViejos;
begin
  Assert.IsTrue(Pos('prc_bloqueo', SqlPrestadosCombinados) > 0);
  Assert.IsTrue(Pos('TB_PrestamosDocumentos', SqlPrestadosCombinados) > 0);
end;

procedure TPruebasPrestadosSql.CombinadoUneSinDuplicar;
begin
  Assert.AreEqual(1, Contar(SqlPrestadosCombinados, ' UNION '));
  Assert.AreEqual(0, Contar(SqlPrestadosCombinados, 'UNION ALL'));
end;

procedure TPruebasPrestadosSql.CombinadoAplicaElFiltroEnAmbasMitades;
begin
  Assert.AreEqual(2, Contar(SqlPrestadosCombinados, '({filtro})'));
end;

procedure TPruebasPrestadosSql.NuevosSoloCuentaPrestamosNoOtrosProcesos;
begin
  Assert.IsTrue(Pos('P.Tipo = ''P''', SqlPrestadosNuevos) > 0);
end;

procedure TPruebasPrestadosSql.ViejosExcluyeDevueltosYCancelados;
begin
  Assert.IsTrue(Pos('P.FDevolucion IS NULL AND P.FCancelacion IS NULL', SqlPrestadosViejos) > 0);
end;

procedure TPruebasPrestadosSql.SubserieDevuelveFechaVersionYCodigo;
begin
  Assert.IsTrue(Pos('AS Fecha', SqlClavesPrestadasDeSubserie) > 0);
  Assert.IsTrue(Pos('AS Version', SqlClavesPrestadasDeSubserie) > 0);
  Assert.IsTrue(Pos('AS Codigodoc', SqlClavesPrestadasDeSubserie) > 0);
  Assert.IsTrue(Pos('prc_bloqueo', SqlClavesPrestadasDeSubserie) > 0);
  Assert.IsTrue(Pos('TB_PrestamosDocumentos', SqlClavesPrestadasDeSubserie) > 0);
end;

procedure TPruebasPrestadosSql.SubserieUsaLosMismosParametrosEnAmbasMitades;
begin
  Assert.AreEqual(2, Contar(SqlClavesPrestadasDeSubserie, ':est'));
  Assert.AreEqual(2, Contar(SqlClavesPrestadasDeSubserie, ':cs'));
end;

end.
