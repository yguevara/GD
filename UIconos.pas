unit UIconos;

{ Iconos de ArchiGenio (Tabler Icons, licencia MIT).
  Los PNG de 24 px van incrustados como recursos (Iconos.rc / Iconos.res);
  no se leen archivos externos en tiempo de ejecucion.
  Dos juegos: oscuro (#1b2733) y blanco (columna lateral). La lista se
  construye bajo demanda y no necesita ningun formulario. }

interface

uses
  Vcl.VirtualImageList;

type
  TIconos = class
  public
    { Lista de 24 px con ambos juegos (oscuro y blanco). }
    class function Lista: TVirtualImageList;
  end;

{ Indice en TIconos.Lista del icono oscuro. Nombre desconocido: EArgumentException. }
function IndiceIcono(const Nombre: string): Integer;
{ Indice en TIconos.Lista del icono blanco. Nombre desconocido: EArgumentException. }
function IndiceIconoBlanco(const Nombre: string): Integer;

implementation

{$R Iconos.res}

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Imaging.pngimage,
  Vcl.ImageCollection;

const
  NombresIconos: array[0..14] of string = (
    'inicio', 'archivo', 'traslados', 'prestamos', 'gestion', 'buscar',
    'agregar', 'editar', 'archivos', 'topografia', 'eliminar', 'usuario',
    'mas', 'abajo', 'derecha');
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
