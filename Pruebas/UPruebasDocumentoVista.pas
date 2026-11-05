unit UPruebasDocumentoVista;

{ Pruebas de la logica pura de la lista de documentos (UDocumentoVista):
  clasificacion (documento / expediente / mapa / georreferenciado), formatos
  de mapa, texto de posicion, propiedades y filtro por expediente. }

interface

uses
  DUnitX.TestFramework, UDocumentoVista;

type
  [TestFixture]
  TPruebasDocumentoVista = class
  private
    function Nuevo(const Codigo: string): TDatosDocumento;
  public
    [Test]
    procedure ExtensionNormal_QuitaPuntoYMayusculas;
    [Test]
    procedure EsFormatoMapa_ListaConfirmada;
    [Test]
    procedure EsFormatoAmbiguo_SoloTif;
    [Test]
    procedure Clasificar_ConHijos_EsExpediente;
    [Test]
    procedure Clasificar_Geo_PorVertices;
    [Test]
    procedure Clasificar_Mapa;
    [Test]
    procedure NombreIcono_Prioridad;
  end;

implementation

uses
  System.SysUtils;

function TPruebasDocumentoVista.Nuevo(const Codigo: string): TDatosDocumento;
begin
  Result := Default(TDatosDocumento);
  Result.Clave.Codigodoc := Codigo;
end;

procedure TPruebasDocumentoVista.ExtensionNormal_QuitaPuntoYMayusculas;
begin
  Assert.AreEqual('geojson', ExtensionNormal(' .GeoJSON '));
  Assert.AreEqual('', ExtensionNormal(''));
end;

procedure TPruebasDocumentoVista.EsFormatoMapa_ListaConfirmada;
const
  SI: array[0..9] of string = ('shp', 'kml', 'geojson', 'dwg', 'dxf', 'gpkg',
    'tif', 'tiff', '.SHP', 'GeoJSON');
  NO_: array[0..4] of string = ('pdf', 'docx', 'jpg', 'png', '');
var
  E: string;
begin
  for E in SI do
    Assert.IsTrue(EsFormatoMapa(E), E);
  for E in NO_ do
    Assert.IsFalse(EsFormatoMapa(E), E);
end;

procedure TPruebasDocumentoVista.EsFormatoAmbiguo_SoloTif;
begin
  Assert.IsTrue(EsFormatoAmbiguo('tif'));
  Assert.IsTrue(EsFormatoAmbiguo('.TIFF'));
  Assert.IsFalse(EsFormatoAmbiguo('shp'));
  Assert.IsFalse(EsFormatoAmbiguo('dxf'));
end;

procedure TPruebasDocumentoVista.Clasificar_ConHijos_EsExpediente;
var
  D: TDatosDocumento;
begin
  D := Nuevo('E1');
  D.NumHijos := 2;
  Assert.AreEqual(Ord(tdExpediente), Ord(ClasificarDocumento(D).Tipo));
  D.NumHijos := 0;
  Assert.AreEqual(Ord(tdDocumento), Ord(ClasificarDocumento(D).Tipo));
  D.MarcadoExpediente := True; // expediente vacio cuenta
  Assert.AreEqual(Ord(tdExpediente), Ord(ClasificarDocumento(D).Tipo));
end;

procedure TPruebasDocumentoVista.Clasificar_Geo_PorVertices;
var
  D: TDatosDocumento;
begin
  D := Nuevo('G1');
  D.NumVerticesGeo := 3;
  Assert.IsTrue(ClasificarDocumento(D).EsGeo);
  D.NumVerticesGeo := 0;
  Assert.IsFalse(ClasificarDocumento(D).EsGeo);
end;

procedure TPruebasDocumentoVista.Clasificar_Mapa;
var
  D: TDatosDocumento;
  C: TClaseDocumento;
begin
  D := Nuevo('M1');
  D.ExtPrincipal := 'shp';
  C := ClasificarDocumento(D);
  Assert.IsTrue(C.EsMapa, 'shp sin vertices es mapa');
  Assert.IsFalse(C.EsGeo, 'shp sin vertices no es geo');

  D.ExtPrincipal := 'tif';
  Assert.IsFalse(ClasificarDocumento(D).EsMapa, 'tif sin vertices: escaneo normal');
  D.NumVerticesGeo := 3;
  C := ClasificarDocumento(D);
  Assert.IsTrue(C.EsMapa, 'tif con vertices es mapa');
  Assert.IsTrue(C.EsGeo);

  D.ExtPrincipal := 'pdf';
  C := ClasificarDocumento(D);
  Assert.IsTrue(C.EsGeo, 'pdf con vertices es geo');
  Assert.IsFalse(C.EsMapa, 'pdf no es mapa');
end;

procedure TPruebasDocumentoVista.NombreIcono_Prioridad;
var
  D: TDatosDocumento;
  C: TClaseDocumento;
begin
  D := Nuevo('X1');
  D.NumHijos := 1;
  D.NumVerticesGeo := 2;
  C := ClasificarDocumento(D);
  Assert.AreEqual('expediente', NombreIconoDocumento(C));
  Assert.AreEqual('georreferenciado', NombreInsigniaGeo(C));

  D := Nuevo('X2');
  D.ExtPrincipal := 'dxf';
  Assert.AreEqual('mapa', NombreIconoDocumento(ClasificarDocumento(D)));

  D := Nuevo('X3');
  D.ExtPrincipal := 'pdf';
  C := ClasificarDocumento(D);
  Assert.AreEqual('documento', NombreIconoDocumento(C));
  Assert.AreEqual('', NombreInsigniaGeo(C));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasDocumentoVista);

end.
