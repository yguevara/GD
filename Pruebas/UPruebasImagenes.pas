unit UPruebasImagenes;

{ Preparar una imagen para guardarla y mostrar miniaturas (UImagenes). }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasImagenes = class
  private
    FCarpeta: string;
    function RutaPng(AAncho, AAlto: Integer): string;
    function RutaJpeg(AAncho, AAlto: Integer): string;
    procedure DimensionesJpeg(const ABytes: TArray<Byte>; out AAncho, AAlto: Integer);
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Preparar_PngGrande_SeReduceA1600;
    [Test]
    procedure Preparar_Pequena_NoSeAgranda;
    [Test]
    procedure Preparar_NoEsImagen_Lanza;
    [Test]
    procedure Preparar_NoExiste_Lanza;
    [Test]
    procedure Miniatura_Jpeg_True;
    [Test]
    procedure Miniatura_Png_True;
    [Test]
    procedure Miniatura_Basura_FalseSinLanzar;
    [Test]
    procedure Miniatura_Vacia_False;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, Vcl.Graphics, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage, UImagenes;

procedure TPruebasImagenes.Preparar;
begin
  FCarpeta := IncludeTrailingPathDelimiter(TPath.Combine(TPath.GetTempPath, 'pr_imagenes'));
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
  TDirectory.CreateDirectory(FCarpeta);
end;

procedure TPruebasImagenes.Limpiar;
begin
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
end;

function TPruebasImagenes.RutaPng(AAncho, AAlto: Integer): string;
var
  Bmp: TBitmap;
  Png: TPngImage;
begin
  Result := FCarpeta + 'grande.png';
  Bmp := TBitmap.Create;
  Png := TPngImage.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Bmp.SetSize(AAncho, AAlto);
    Bmp.Canvas.Brush.Color := clTeal;
    Bmp.Canvas.FillRect(Rect(0, 0, AAncho, AAlto));
    Png.Assign(Bmp);
    Png.SaveToFile(Result);
  finally
    Png.Free;
    Bmp.Free;
  end;
end;

function TPruebasImagenes.RutaJpeg(AAncho, AAlto: Integer): string;
var
  Bmp: TBitmap;
  Jpg: TJPEGImage;
begin
  Result := FCarpeta + 'pequena.jpg';
  Bmp := TBitmap.Create;
  Jpg := TJPEGImage.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Bmp.SetSize(AAncho, AAlto);
    Bmp.Canvas.Brush.Color := clMaroon;
    Bmp.Canvas.FillRect(Rect(0, 0, AAncho, AAlto));
    Jpg.Assign(Bmp);
    Jpg.SaveToFile(Result);
  finally
    Jpg.Free;
    Bmp.Free;
  end;
end;

procedure TPruebasImagenes.DimensionesJpeg(const ABytes: TArray<Byte>; out AAncho, AAlto: Integer);
var
  S: TBytesStream;
  Jpg: TJPEGImage;
begin
  S := TBytesStream.Create(ABytes);
  Jpg := TJPEGImage.Create;
  try
    Jpg.LoadFromStream(S);
    AAncho := Jpg.Width;
    AAlto := Jpg.Height;
  finally
    Jpg.Free;
    S.Free;
  end;
end;

procedure TPruebasImagenes.Preparar_PngGrande_SeReduceA1600;
var
  B: TBytes;
  W, H: Integer;
begin
  B := PrepararImagen(RutaPng(2000, 1000));
  DimensionesJpeg(B, W, H);
  Assert.AreEqual(1600, W);
  Assert.AreEqual(800, H);
end;

procedure TPruebasImagenes.Preparar_Pequena_NoSeAgranda;
var
  B: TBytes;
  W, H: Integer;
begin
  B := PrepararImagen(RutaJpeg(100, 50));
  DimensionesJpeg(B, W, H);
  Assert.AreEqual(100, W);
  Assert.AreEqual(50, H);
end;

procedure TPruebasImagenes.Preparar_NoEsImagen_Lanza;
var
  Ruta: string;
begin
  Ruta := FCarpeta + 'falsa.jpg';
  TFile.WriteAllText(Ruta, 'esto no es una imagen');
  Assert.WillRaise(
    procedure
    begin
      PrepararImagen(Ruta);
    end, EImagenInvalida);
end;

procedure TPruebasImagenes.Preparar_NoExiste_Lanza;
begin
  Assert.WillRaise(
    procedure
    begin
      PrepararImagen(FCarpeta + 'no_existe.jpg');
    end, EImagenInvalida);
end;

procedure TPruebasImagenes.Miniatura_Jpeg_True;
var
  Img: TImage;
begin
  Img := TImage.Create(nil);
  try
    Assert.IsTrue(CargarMiniatura(TFile.ReadAllBytes(RutaJpeg(40, 30)), Img));
    Assert.IsTrue(Img.Picture.Graphic <> nil);
  finally
    Img.Free;
  end;
end;

procedure TPruebasImagenes.Miniatura_Png_True;
var
  Img: TImage;
begin
  Img := TImage.Create(nil);
  try
    Assert.IsTrue(CargarMiniatura(TFile.ReadAllBytes(RutaPng(40, 30)), Img));
    Assert.IsTrue(Img.Picture.Graphic <> nil);
  finally
    Img.Free;
  end;
end;

procedure TPruebasImagenes.Miniatura_Basura_FalseSinLanzar;
var
  Img: TImage;
begin
  Img := TImage.Create(nil);
  try
    Assert.IsFalse(CargarMiniatura(TBytes.Create(1, 2, 3, 4, 5, 6, 7, 8), Img));
  finally
    Img.Free;
  end;
end;

procedure TPruebasImagenes.Miniatura_Vacia_False;
var
  Img: TImage;
begin
  Img := TImage.Create(nil);
  try
    Assert.IsFalse(CargarMiniatura(nil, Img));
  finally
    Img.Free;
  end;
end;

end.
