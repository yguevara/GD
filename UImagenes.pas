unit UImagenes;

{ ---------------------------------------------------------------------------
  Imagenes de los clasificadores (croquis, fotos): preparar un archivo para
  guardarlo en la base de datos y mostrar una miniatura. VCL pero sin TUDM, para
  poder probarlo desde Pruebas/.

  El formato se reconoce por la cabecera del contenido (JPEG, PNG o BMP), no por
  la extension del archivo.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, Vcl.ExtCtrls;

const
  { Ningun lado de una imagen guardada pasa de este tamano (pixeles). }
  LADO_MAXIMO_IMAGEN = 1600;

type
  EImagenInvalida = class(Exception);

{ Lee un JPG, PNG o BMP de ARuta, lo reduce para que ningun lado pase de
  AMaxLado (conservando la proporcion; nunca agranda) y devuelve el contenido
  como JPEG calidad 85. Un JPEG que ya cabe se devuelve sin tocar. Lanza
  EImagenInvalida si el archivo no existe o no es una imagen. }
function PrepararImagen(const ARuta: string; AMaxLado: Integer = LADO_MAXIMO_IMAGEN): TBytes;

{ Muestra ABytes (JPEG, PNG o BMP) en AImagen, ajustada y centrada. Devuelve
  False si esta vacio o no es una imagen; nunca lanza. }
function CargarMiniatura(const ABytes: TBytes; AImagen: TImage): Boolean;

implementation

uses
  System.Classes, System.IOUtils, Winapi.Windows, Vcl.Graphics,
  Vcl.Imaging.jpeg, Vcl.Imaging.pngimage;

{ Interpreta ABytes segun su cabecera. nil si no es una imagen valida. El que
  llama libera el resultado. }
function CargarGrafico(const ABytes: TBytes): TGraphic;
var
  S: TBytesStream;
begin
  Result := nil;
  if Length(ABytes) < 8 then
    Exit;
  if (ABytes[0] = $FF) and (ABytes[1] = $D8) then
    Result := TJPEGImage.Create
  else if (ABytes[0] = $89) and (ABytes[1] = $50) and (ABytes[2] = $4E) and (ABytes[3] = $47) then
    Result := TPngImage.Create
  else if (ABytes[0] = $42) and (ABytes[1] = $4D) then
    Result := TBitmap.Create
  else
    Exit;
  S := TBytesStream.Create(ABytes);
  try
    try
      Result.LoadFromStream(S);
    except
      FreeAndNil(Result);
    end;
  finally
    S.Free;
  end;
end;

function PrepararImagen(const ARuta: string; AMaxLado: Integer): TBytes;
var
  Origen: TBytes;
  G: TGraphic;
  Bmp: TBitmap;
  Jpg: TJPEGImage;
  Flujo: TBytesStream;
  Ancho, Alto, Mayor: Integer;
begin
  if not FileExists(ARuta) then
    raise EImagenInvalida.Create('No se encontr'#243' el archivo de imagen.');
  try
    Origen := TFile.ReadAllBytes(ARuta);
  except
    on E: Exception do
      raise EImagenInvalida.Create('No se pudo leer el archivo: ' + E.Message);
  end;
  G := CargarGrafico(Origen);
  if G = nil then
    raise EImagenInvalida.Create('El archivo no es una imagen v'#225'lida (JPG, PNG o BMP).');
  try
    Ancho := G.Width;
    Alto := G.Height;
    Mayor := Ancho;
    if Alto > Mayor then
      Mayor := Alto;
    // Un JPEG que ya cabe se conserva tal cual (sin volver a comprimirlo)
    if (G is TJPEGImage) and (Mayor <= AMaxLado) then
      Exit(Origen);
    if Mayor > AMaxLado then
    begin
      Ancho := Round(Ancho * AMaxLado / Mayor);
      Alto := Round(Alto * AMaxLado / Mayor);
      if Ancho < 1 then
        Ancho := 1;
      if Alto < 1 then
        Alto := 1;
    end;
    Bmp := TBitmap.Create;
    Jpg := TJPEGImage.Create;
    Flujo := TBytesStream.Create;
    try
      Bmp.PixelFormat := pf24bit;
      Bmp.SetSize(Ancho, Alto);
      Bmp.Canvas.Brush.Color := clWhite;
      Bmp.Canvas.FillRect(Rect(0, 0, Ancho, Alto));
      SetStretchBltMode(Bmp.Canvas.Handle, HALFTONE);
      Bmp.Canvas.StretchDraw(Rect(0, 0, Ancho, Alto), G);
      Jpg.Assign(Bmp);
      Jpg.CompressionQuality := 85;
      Jpg.SaveToStream(Flujo);
      Result := Copy(Flujo.Bytes, 0, Flujo.Size);
    finally
      Flujo.Free;
      Jpg.Free;
      Bmp.Free;
    end;
  finally
    G.Free;
  end;
end;

function CargarMiniatura(const ABytes: TBytes; AImagen: TImage): Boolean;
var
  G: TGraphic;
begin
  Result := False;
  if (AImagen = nil) or (Length(ABytes) = 0) then
    Exit;
  try
    G := CargarGrafico(ABytes);
    if G = nil then
      Exit;
    try
      AImagen.Picture.Assign(G);
      AImagen.Stretch := True;
      AImagen.Proportional := True;
      AImagen.Center := True;
      Result := True;
    finally
      G.Free;
    end;
  except
    Result := False;
  end;
end;

end.
