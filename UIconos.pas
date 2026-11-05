unit UIconos;

{ Iconos de ArchiGenio (Tabler Icons, licencia MIT).
  Los PNG de 24 px van incrustados como recursos (Iconos.rc / Iconos.res);
  no se leen archivos externos en tiempo de ejecucion.
  Dos juegos: oscuro (#1b2733) y blanco (columna lateral). La lista se
  construye bajo demanda y no necesita ningun formulario. }

interface

uses
  Vcl.VirtualImageList, Vcl.ImgList;

type
  TIconos = class
  public
    { Lista de 24 px con ambos juegos (oscuro y blanco). }
    class function Lista: TVirtualImageList;
  end;

{ Reemplaza las 16 imagenes de la lista del arbol del cuadro de clasificacion
  (UDM.ImageList3, 32 px) por los iconos Tabler. Se conservan los indices:
  0 estructura, 1 nodo, 2 documentos, 3 entidad, 4 informes, 5 ciclo,
  6 carpeta de ajustes, 15 unidad; 7 a 14 son las variantes grises (nodo
  invisible) de 0 a 6 y 15. Un error al cargar deja la lista como estaba. }
procedure ReemplazarIconosArbol(Lista: TCustomImageList);

{ Indice en TIconos.Lista del icono oscuro. Nombre desconocido: EArgumentException. }
function IndiceIcono(const Nombre: string): Integer;
{ Indice en TIconos.Lista del icono blanco. Nombre desconocido: EArgumentException. }
function IndiceIconoBlanco(const Nombre: string): Integer;

implementation

{$R Iconos.res}

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Imaging.pngimage,
  Vcl.ImageCollection, Vcl.Graphics;

const
  NombresIconos: array[0..29] of string = (
    'inicio', 'archivo', 'traslados', 'prestamos', 'gestion', 'buscar',
    'agregar', 'editar', 'archivos', 'topografia', 'eliminar', 'usuario',
    'mas', 'abajo', 'derecha', 'clasificadores', 'cuadro', 'usuarios',
    'configuracion', 'depuracion', 'indices', 'basedatos', 'salir', 'ayuda',
    'reportes', 'servidor', 'series', 'logs', 'acerca', 'versiones');
  SufijoBlanco = '_blanco';
  TamanoIcono = 24;

var
  GColeccion: TImageCollection;
  GLista: TVirtualImageList;

procedure AgregarIcono(const Nombre, Recurso: string);
var
  Flujo: TResourceStream;
  Item: TImageCollectionItem;
begin
  Flujo := TResourceStream.Create(HInstance, Recurso, RT_RCDATA);
  try
    Item := GColeccion.Images.Add;
    Item.Name := Nombre;
    Item.SourceImages.Add.Image.LoadFromStream(Flujo);
  finally
    Flujo.Free;
  end;
end;

procedure Construir;
var
  N: string;
begin
  GColeccion := TImageCollection.Create(nil);
  GLista := TVirtualImageList.Create(nil);
  GLista.Width := TamanoIcono;
  GLista.Height := TamanoIcono;
  GLista.ImageCollection := GColeccion;
  for N in NombresIconos do
    AgregarIcono(N, 'ICO_' + UpperCase(N));
  for N in NombresIconos do
    AgregarIcono(N + SufijoBlanco, 'ICO_' + UpperCase(N) + '_BLANCO');
  // Un elemento de la lista virtual por cada imagen de la coleccion
  GLista.Add('', 0, GColeccion.Count - 1);
end;

procedure ReemplazarIconosArbol(Lista: TCustomImageList);
var
  I: Integer;
  Png: TPngImage;
  Bmp: TBitmap;
  Flujo: TResourceStream;
  Nuevas: array of TBitmap;
begin
  if (Lista = nil) or (Lista.Count < 16) then
    Exit;
  SetLength(Nuevas, 16);
  try
    for I := 0 to 15 do
    begin
      Png := TPngImage.Create;
      try
        Flujo := TResourceStream.Create(HInstance, Format('ARB_%.2d', [I]), RT_RCDATA);
        try
          Png.LoadFromStream(Flujo);
        finally
          Flujo.Free;
        end;
        Bmp := TBitmap.Create;
        Nuevas[I] := Bmp;
        Bmp.Assign(Png);
        Bmp.AlphaFormat := afDefined;
      finally
        Png.Free;
      end;
    end;
    for I := 0 to 15 do
      Lista.Replace(I, Nuevas[I], nil);
  finally
    for I := 0 to High(Nuevas) do
      Nuevas[I].Free;
  end;
end;

class function TIconos.Lista: TVirtualImageList;
begin
  if GLista = nil then
    Construir;
  Result := GLista;
end;

function BuscarIndice(const Nombre, Sufijo: string; Base: Integer): Integer;
var
  I: Integer;
begin
  for I := Low(NombresIconos) to High(NombresIconos) do
    if SameText(NombresIconos[I], Nombre) then
      Exit(Base + I);
  raise EArgumentException.CreateFmt('Icono desconocido: "%s"', [Nombre + Sufijo]);
end;

function IndiceIcono(const Nombre: string): Integer;
begin
  TIconos.Lista;
  Result := BuscarIndice(Nombre, '', 0);
end;

function IndiceIconoBlanco(const Nombre: string): Integer;
begin
  TIconos.Lista;
  Result := BuscarIndice(Nombre, SufijoBlanco, Length(NombresIconos));
end;

initialization
  // La lista se construye bajo demanda (TIconos.Lista)

finalization
  GLista.Free;
  GColeccion.Free;

end.
