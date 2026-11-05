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

  TPropiedad = record
    Grupo: string;
    Etiqueta: string;
    Valor: string;
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

{ Partes no vacias de la ubicacion fisica, con su rotulo, separadas por ' > ';
  'Sin ubicacion asignada' si no hay ninguna. }
function TextoPosicion(const D: TDatosDocumento): string;
{ '512 B', '1.5 KB', '1.2 MB', '3.0 GB' (base 1024, punto decimal siempre);
  negativo o no numerico: '-'. }
function FormatoTamano(Bytes: Double): string;
{ Propiedades agrupadas (General, Expediente, Posicion fisica, Ficheros) para
  el panel de un documento. }
function ConstruirPropiedades(const D: TDatosDocumento;
  const Ficheros: TArray<TFicheroDoc>): TArray<TPropiedad>;
{ El expediente de codigo Codigo y los documentos que lo referencian; sin
  codigo, todos. Sin distinguir mayusculas ni espacios. }
function FiltrarPorExpediente(const Docs: TArray<TDatosDocumento>;
  const Codigo: string): TArray<TDatosDocumento>;

implementation

uses
  System.SysUtils, System.Math;

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

procedure AgregaPartePosicion(var Resultado: string; const Rotulo, Valor: string);
var
  V: string;
begin
  V := Trim(Valor);
  if V = '' then
    Exit;
  if Resultado <> '' then
    Resultado := Resultado + ' > ';
  Resultado := Resultado + Rotulo + ' ' + V;
end;

function TextoPosicion(const D: TDatosDocumento): string;
begin
  Result := '';
  AgregaPartePosicion(Result, 'Servidor', D.Servidor);
  AgregaPartePosicion(Result, 'Archivo', D.Archivo);
  AgregaPartePosicion(Result, 'Deposito', D.Deposito);
  AgregaPartePosicion(Result, 'Gaveta', D.Gaveta);
  AgregaPartePosicion(Result, 'Posicion', D.Posicion);
  if Result = '' then
    Result := 'Sin ubicacion asignada';
end;

function FormatoTamano(Bytes: Double): string;
const
  UNIDADES: array[0..2] of string = ('KB', 'MB', 'GB');
var
  V: Double;
  I: Integer;
begin
  if IsNan(Bytes) or (Bytes < 0) then
    Exit('-');
  if Bytes < 1024 then
    Exit(Format('%d B', [Round(Bytes)]));
  V := Bytes / 1024;
  I := 0;
  while (V >= 1024) and (I < High(UNIDADES)) do
  begin
    V := V / 1024;
    Inc(I);
  end;
  Result := Format('%.1f %s', [V, UNIDADES[I]], TFormatSettings.Invariant);
end;

procedure AgregaProp(var L: TArray<TPropiedad>; const Grupo, Etiqueta, Valor: string);
begin
  SetLength(L, Length(L) + 1);
  L[High(L)].Grupo := Grupo;
  L[High(L)].Etiqueta := Etiqueta;
  L[High(L)].Valor := Valor;
end;

function ConstruirPropiedades(const D: TDatosDocumento;
  const Ficheros: TArray<TFicheroDoc>): TArray<TPropiedad>;
var
  C: TClaseDocumento;
  I: Integer;
  Tipo, Rotulo: string;
begin
  Result := nil;
  C := ClasificarDocumento(D);
  if C.Tipo = tdExpediente then
    Tipo := 'Expediente'
  else if C.EsMapa then
    Tipo := 'Mapa'
  else
    Tipo := 'Documento';
  AgregaProp(Result, 'General', 'Codigo', D.Clave.Codigodoc);
  AgregaProp(Result, 'General', 'Titulo', D.Titulo);
  AgregaProp(Result, 'General', 'Fecha', FormatDateTime('dd"/"mm"/"yyyy', D.Clave.Fecha));
  AgregaProp(Result, 'General', 'Version', D.Clave.Version);
  AgregaProp(Result, 'General', 'Tipo', Tipo);
  if C.EsGeo then
    AgregaProp(Result, 'General', 'Georreferenciado', 'Si');
  if Trim(D.IdExpediente) <> '' then
    AgregaProp(Result, 'General', 'Pertenece al expediente', Trim(D.IdExpediente));
  if Trim(D.SubExp) <> '' then
    AgregaProp(Result, 'General', 'Subexpediente', Trim(D.SubExp));
  if C.Tipo = tdExpediente then
  begin
    if D.NumHijos = 1 then
      AgregaProp(Result, 'Expediente', 'Contiene', '1 documento')
    else
      AgregaProp(Result, 'Expediente', 'Contiene', IntToStr(D.NumHijos) + ' documentos');
  end;
  AgregaProp(Result, 'Posicion fisica', 'Ubicacion', TextoPosicion(D));
  if Length(Ficheros) = 0 then
    AgregaProp(Result, 'Ficheros', 'Ficheros', 'Sin ficheros')
  else
    for I := 0 to High(Ficheros) do
    begin
      if Ficheros[I].EsFuente then
        Rotulo := 'Fuente'
      else
        Rotulo := 'Fichero';
      AgregaProp(Result, 'Ficheros', Rotulo,
        Ficheros[I].Nombre + ' (' + FormatoTamano(Ficheros[I].Tamano) + ')');
    end;
end;

function FiltrarPorExpediente(const Docs: TArray<TDatosDocumento>;
  const Codigo: string): TArray<TDatosDocumento>;
var
  I, N: Integer;
  Cod: string;
begin
  Cod := Trim(Codigo);
  if Cod = '' then
    Exit(Copy(Docs));
  SetLength(Result, Length(Docs));
  N := 0;
  for I := 0 to High(Docs) do
    if SameText(Trim(Docs[I].Clave.Codigodoc), Cod) or
      SameText(Trim(Docs[I].IdExpediente), Cod) then
    begin
      Result[N] := Docs[I];
      Inc(N);
    end;
  SetLength(Result, N);
end;

end.
