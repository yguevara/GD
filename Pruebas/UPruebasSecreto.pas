unit UPruebasSecreto;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasSecreto = class
  public
    [Test]
    procedure IdaYVuelta_Simple;
    [Test]
    procedure IdaYVuelta_ConAcentos;
    [Test]
    procedure DosCifrados_SonDistintos;
    [Test]
    procedure Cifrado_NoContieneElClaro;
    [Test]
    procedure Descifrar_Invalido_DaVacio;
    [Test]
    procedure Descifrar_Alterado_DaVacio;
  end;

implementation

uses
  System.SysUtils, USecretoServidor;

procedure TPruebasSecreto.IdaYVuelta_Simple;
begin
  Assert.AreEqual('archigenio-test-1', DescifrarSecreto(CifrarSecreto('archigenio-test-1')));
end;

procedure TPruebasSecreto.IdaYVuelta_ConAcentos;
var
  S: string;
begin
  S := 'cl' + Char($E1) + 've ' + Char($F1) + Char($FA) + '!';
  Assert.AreEqual(S, DescifrarSecreto(CifrarSecreto(S)));
end;

procedure TPruebasSecreto.DosCifrados_SonDistintos;
begin
  Assert.AreNotEqual(CifrarSecreto('igual'), CifrarSecreto('igual'));
end;

procedure TPruebasSecreto.Cifrado_NoContieneElClaro;
begin
  Assert.IsFalse(CifrarSecreto('archigenio-test-1').Contains('archigenio'));
  Assert.IsTrue(CifrarSecreto('x').StartsWith('v1:'));
end;

procedure TPruebasSecreto.Descifrar_Invalido_DaVacio;
begin
  Assert.AreEqual('', DescifrarSecreto('basura'));
  Assert.AreEqual('', DescifrarSecreto(''));
  Assert.AreEqual('', DescifrarSecreto('v1:%%%no-es-base64'));
  Assert.AreEqual('', DescifrarSecreto('v1:AAAA'));
end;

procedure TPruebasSecreto.Descifrar_Alterado_DaVacio;
var
  C: string;
begin
  C := CifrarSecreto('secreto largo para alterar el bloque final');
  // Cambiar el ultimo caracter Base64 rompe el relleno o el contenido
  C := Copy(C, 1, Length(C) - 3) + 'AAA';
  Assert.AreNotEqual('secreto largo para alterar el bloque final', DescifrarSecreto(C));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasSecreto);

end.
