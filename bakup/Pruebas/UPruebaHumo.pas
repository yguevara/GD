unit UPruebaHumo;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebaHumo = class
  public
    [Test]
    procedure CompilaYCorre;
  end;

implementation

procedure TPruebaHumo.CompilaYCorre;
begin
  Assert.IsTrue(True);
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebaHumo);

end.
