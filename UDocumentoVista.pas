unit UDocumentoVista;

{ Logica pura de la lista de documentos de una subserie (sin VCL ni datos):
  clasificacion (documento / expediente / mapa / georreferenciado), formatos
  de mapa, texto de posicion fisica, propiedades y filtro por expediente.
  Diseno: docs/superpowers/specs/2026-11-05-documentos-carga-consulta-geo-
  trazabilidad-design.md, secciones 3.2 y 3.4. Codigo en ASCII. }

interface

type
  TTipoDocumento = (tdDocumento, tdExpediente);

  TClaveDocumento = record
    IdEstructura: string;
    Id: Integer;
    CodSubs: string;
    Fecha: TDateTime;
    Version: string;
    Codigodoc: string;
  end;

  TFicheroDoc = record
    Nombre: string;
    Extension: string;
    Tamano: Double;
    EsFuente: Boolean;
  end;

  TDatosDocumento = record
    Clave: TClaveDocumento;
    Titulo, IdExpediente, SubExp, Servidor, Archivo, Deposito, Gaveta,
      Posicion, Observaciones, ExtPrincipal: string;
    NumHijos, NumVerticesGeo, NumFicheros, NumFuentes: Integer;
    MarcadoExpediente: Boolean;
  end;

  TClaseDocumento = record
    Tipo: TTipoDocumento;
    EsGeo: Boolean;
    EsMapa: Boolean;
  end;

{ Extension sin punto, en minusculas y sin espacios. }
function ExtensionNormal(const Ext: string): string;
{ shp, kml, geojson, dwg, dxf, gpkg, tif, tiff. }
function EsFormatoMapa(const Ext: string): Boolean;
{ Solo tif y tiff: pueden ser un escaneo normal; cuentan como mapa solo con
  coordenadas. }
function EsFormatoAmbiguo(const Ext: string): Boolean;
function ClasificarDocumento(const D: TDatosDocumento): TClaseDocumento;
{ 'expediente', 'mapa' o 'documento'. }
function NombreIconoDocumento(const C: TClaseDocumento): string;
{ 'georreferenciado' si EsGeo o EsMapa; si no, ''. }
function NombreInsigniaGeo(const C: TClaseDocumento): string;

implementation

uses
  System.SysUtils;

function ExtensionNormal(const Ext: string): string;
begin
  Result := LowerCase(Trim(Ext));
  while (Result <> '') and (Result[1] = '.') do
    Delete(Result, 1, 1);
  Result := Trim(Result);
end;

function EsFormatoMapa(const Ext: string): Boolean;
var
  E: string;
begin
  E := ExtensionNormal(Ext);
  Result := (E = 'shp') or (E = 'kml') or (E = 'geojson') or (E = 'dwg') or
    (E = 'dxf') or (E = 'gpkg') or (E = 'tif') or (E = 'tiff');
end;

function EsFormatoAmbiguo(const Ext: string): Boolean;
var
  E: string;
begin
  E := ExtensionNormal(Ext);
  Result := (E = 'tif') or (E = 'tiff');
end;

function ClasificarDocumento(const D: TDatosDocumento): TClaseDocumento;
begin
  if (D.NumHijos > 0) or D.MarcadoExpediente then
    Result.Tipo := tdExpediente
  else
    Result.Tipo := tdDocumento;
  Result.EsGeo := D.NumVerticesGeo > 0;
  Result.EsMapa := EsFormatoMapa(D.ExtPrincipal) and
    (not EsFormatoAmbiguo(D.ExtPrincipal) or Result.EsGeo);
end;

function NombreIconoDocumento(const C: TClaseDocumento): string;
begin
  if C.Tipo = tdExpediente then
    Result := 'expediente'
  else if C.EsMapa then
    Result := 'mapa'
  else
    Result := 'documento';
end;

function NombreInsigniaGeo(const C: TClaseDocumento): string;
begin
  if C.EsGeo or C.EsMapa then
    Result := 'georreferenciado'
  else
    Result := '';
end;

end.
