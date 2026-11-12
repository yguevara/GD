unit UPruebasPalabrasReservadas;

{ Palabras reservadas de SQL Server y Access (UPalabrasReservadas). Sin base de datos. }

interface

uses
  DUnitX.TestFramework, UPalabrasReservadas;

type
  [TestFixture]
  TPruebasPalabrasReservadas = class
  public
    [Test]
    procedure SqlServer_Select_EsReservada;
    [Test]
    procedure Access_Counter_EsReservada_PeroNoEnSqlServer;
    [Test]
    procedure NombreLibre_NoEsReservada;
    [Test]
    procedure Vacio_NoEsReservada;
  end;

implementation

procedure TPruebasPalabrasReservadas.SqlServer_Select_EsReservada;
begin
  Assert.IsTrue(EsPalabraReservada('select', True));
end;

procedure TPruebasPalabrasReservadas.Access_Counter_EsReservada_PeroNoEnSqlServer;
begin
  Assert.IsTrue(EsPalabraReservada('COUNTER', False));
  Assert.IsFalse(EsPalabraReservada('COUNTER', True));
end;

procedure TPruebasPalabrasReservadas.NombreLibre_NoEsReservada;
begin
  Assert.IsFalse(EsPalabraReservada('Municipio', True));
  Assert.IsFalse(EsPalabraReservada('Municipio', False));
end;

procedure TPruebasPalabrasReservadas.Vacio_NoEsReservada;
begin
  Assert.IsFalse(EsPalabraReservada('', True));
end;

end.
