unit UPruebasProcesoPintura;

{ Pintado de la franja de pestanas de los procesos: la disposicion y la punteria
  se prueban sobre un TBitmap (no hace falta pantalla). }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasProcesoPintura = class
  public
    [Test]
    procedure PestanaEnEncuentraLaPestanaBajoElPunto;
    [Test]
    procedure PestanaEnFueraDevuelveMenosUno;
    [Test]
    procedure PestanaEnSinPestanasDevuelveMenosUno;
    [Test]
    procedure DisenarPestanasNoSolapaYAvanzaALaDerecha;
    [Test]
    procedure DisenarPestanasConInsigniaEsMasAnchaQueSin;
    [Test]
    procedure DisenarPestanasCreceConElTexto;
    [Test]
    procedure DisenarPestanasEscalaConElDpi;
    [Test]
    procedure PintarNoLanzaConListasVacias;
  end;

implementation

uses
  System.SysUtils, System.Types, Vcl.Graphics, UTema, UProceso,
  UProcesoPintura;

procedure TPruebasProcesoPintura.PestanaEnEncuentraLaPestanaBajoElPunto;
var
  R: TArray<TRect>;
begin
  R := [Rect(0, 0, 100, 40), Rect(104, 0, 220, 40)];
  Assert.AreEqual(0, PestanaEn(R, 50, 20));
  Assert.AreEqual(1, PestanaEn(R, 150, 20));
end;

procedure TPruebasProcesoPintura.PestanaEnFueraDevuelveMenosUno;
var
  R: TArray<TRect>;
begin
  R := [Rect(0, 0, 100, 40)];
  Assert.AreEqual(-1, PestanaEn(R, 500, 20));
  Assert.AreEqual(-1, PestanaEn(R, 50, 80));
end;

procedure TPruebasProcesoPintura.PestanaEnSinPestanasDevuelveMenosUno;
begin
  Assert.AreEqual(-1, PestanaEn(nil, 10, 10));
end;

procedure TPruebasProcesoPintura.DisenarPestanasNoSolapaYAvanzaALaDerecha;
var
  Bmp: TBitmap;
  R: TArray<TRect>;
  I: Integer;
begin
  Bmp := TBitmap.Create;
  try
    R := DisenarPestanas(Bmp.Canvas, [Pestana('Todos', 12, False),
      Pestana('En pr', 7, False), Pestana('Vencidos', 2, True)], 46, 96);
    Assert.AreEqual(3, Length(R));
    for I := 1 to High(R) do
      Assert.IsTrue(R[I].Left >= R[I - 1].Right, 'la pestana ' + IntToStr(I) + ' no solapa');
    Assert.AreEqual(46, R[0].Bottom - R[0].Top);
  finally
    Bmp.Free;
  end;
end;

procedure TPruebasProcesoPintura.DisenarPestanasConInsigniaEsMasAnchaQueSin;
var
  Bmp: TBitmap;
  Con, Sin: TArray<TRect>;
begin
  Bmp := TBitmap.Create;
  try
    Con := DisenarPestanas(Bmp.Canvas, [Pestana('Vencidos', 2, True)], 46, 96);
    Sin := DisenarPestanas(Bmp.Canvas, [Pestana('Vencidos', 0, True)], 46, 96);
    Assert.IsTrue((Con[0].Right - Con[0].Left) > (Sin[0].Right - Sin[0].Left));
  finally
    Bmp.Free;
  end;
end;

procedure TPruebasProcesoPintura.DisenarPestanasCreceConElTexto;
var
  Bmp: TBitmap;
  Corta, Larga: TArray<TRect>;
begin
  Bmp := TBitmap.Create;
  try
    Corta := DisenarPestanas(Bmp.Canvas, [Pestana('Si', 0, False)], 46, 96);
    Larga := DisenarPestanas(Bmp.Canvas, [Pestana('Devueltos este ano', 0, False)], 46, 96);
    Assert.IsTrue((Larga[0].Right - Larga[0].Left) > (Corta[0].Right - Corta[0].Left));
  finally
    Bmp.Free;
  end;
end;

procedure TPruebasProcesoPintura.DisenarPestanasEscalaConElDpi;
var
  Bmp: TBitmap;
  A, B: TArray<TRect>;
begin
  Bmp := TBitmap.Create;
  try
    A := DisenarPestanas(Bmp.Canvas, [Pestana('Todos', 0, False)], 46, 96);
    B := DisenarPestanas(Bmp.Canvas, [Pestana('Todos', 0, False)], 46, 192);
    Assert.IsTrue(B[0].Left > A[0].Left, 'el margen izquierdo crece con el DPI');
  finally
    Bmp.Free;
  end;
end;

procedure TPruebasProcesoPintura.PintarNoLanzaConListasVacias;
var
  Bmp: TBitmap;
  T: TTemaColores;
begin
  T := TemaClaro;
  Bmp := TBitmap.Create;
  try
    Bmp.SetSize(400, 100);
    PintarTarjetas(Bmp.Canvas, Rect(0, 0, 400, 100), [], T, 96);
    PintarPestanas(Bmp.Canvas, Rect(0, 0, 400, 46), [], nil, 0, T, 96);
    PintarPasos(Bmp.Canvas, Rect(0, 0, 400, 84), tpPrestamo, [], 1, epEnCurso, T, 96);
    Assert.Pass;
  finally
    Bmp.Free;
  end;
end;

end.
