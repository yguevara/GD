unit UPruebasBloqueAccion;

{ Bloque "Requiere accion" (VCL). Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasBloqueAccion = class
  public
    [Test]
    procedure SinContadores_QuedaOculto;
    [Test]
    procedure ConContadores_MuestraFilas_SoloPrestadosResponde;
  end;

implementation

uses
  System.SysUtils, Vcl.Controls, Vcl.Forms, UBloqueAccion, UDocumentoVistaDatos;

type
  TReceptor = class
    Clave: string;
    procedure Elegir(const C: string);
  end;

procedure TReceptor.Elegir(const C: string);
begin
  Clave := C;
end;

function Dos: TArray<TContadorAccion>;
begin
  SetLength(Result, 2);
  Result[0].Clave := 'prestados';
  Result[0].Texto := 'Prestados ahora';
  Result[0].Cantidad := 3;
  Result[1].Clave := 'sinubicacion';
  Result[1].Texto := 'Sin ubicación';
  Result[1].Cantidad := 7;
end;

procedure TPruebasBloqueAccion.SinContadores_QuedaOculto;
var
  F: TForm;
  B: TBloqueAccion;
begin
  F := TForm.CreateNew(nil);
  try
    B := TBloqueAccion.Create(F);
    B.Parent := F;
    B.Mostrar(Dos);
    Assert.IsTrue(B.Visible);
    B.Mostrar(nil);
    Assert.IsFalse(B.Visible);
    Assert.AreEqual(0, B.CantidadFilas);
  finally
    F.Free;
  end;
end;

procedure TPruebasBloqueAccion.ConContadores_MuestraFilas_SoloPrestadosResponde;
var
  F: TForm;
  B: TBloqueAccion;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create;
  try
    B := TBloqueAccion.Create(F);
    B.Parent := F;
    B.OnElegir := R.Elegir;
    B.Mostrar(Dos);
    Assert.AreEqual(2, B.CantidadFilas);
    B.ClicFila(1);
    Assert.AreEqual('', R.Clave, 'sin ubicación es informativo');
    B.ClicFila(0);
    Assert.AreEqual('prestados', R.Clave);
  finally
    F.Free;
    R.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasBloqueAccion);

end.
