unit UDocumentoVista;

{ Logica pura de la lista de documentos de una subserie (sin VCL ni datos):
  clasificacion (documento / expediente / mapa / georreferenciado), formatos
  de mapa, texto de posicion fisica, propiedades y filtro por expediente.
  Diseno: docs/superpowers/specs/2026-11-05-documentos-carga-consulta-geo-
  trazabilidad-design.md, secciones 3.2 y 3.4. Codigo en ASCII. }

interface

type
  TTipoDocumento = (tdDocumento, tdExpediente);

  { Pestanas del panel del documento. }
  TPestanaDoc = (pdDatos, pdUbicacion, pdArchivos, pdMetadatos, pdHistoria,
    pdContenido);

  { Estado fisico del documento: sin dato (no se pudo consultar), en archivo o
    con un prestamo abierto (sin devolucion). }
  TEstadoDoc = (edDesconocido, edEnArchivo, edPrestado, edTransferido);

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
    Estado: TEstadoDoc;
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
  'Sin ubicación asignada' si no hay ninguna. }
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

type
  { Ficheros de un documento agrupados para mostrarlos (anexos y fuentes). }
  TGrupoFicheros = record
    Titulo: string;
    Ficheros: TArray<TFicheroDoc>;
  end;

{ Grupos "Anexos digitales" (no fuentes) y "Fuentes", solo los no vacios y con
  los ficheros ordenados por nombre. }
function AgruparFicheros(const F: TArray<TFicheroDoc>): TArray<TGrupoFicheros>;
{ Una propiedad por fichero, en su grupo, para la pestana Archivos: etiqueta =
  extension en mayusculas, valor = nombre y tamano. Sin ficheros: "Sin ficheros". }
function PropiedadesDeArchivos(const F: TArray<TFicheroDoc>): TArray<TPropiedad>;

{ Metadatos del documento listos para mostrar: un valor vacio o en blanco se
  ve como un guion (para distinguirlo de una etiqueta sin dato). Sin
  variables: vacio. }
function MetadatosParaMostrar(const M: TArray<TPropiedad>): TArray<TPropiedad>;

type
  { Un tramo de una ubicacion fisica (por ejemplo Archivo = "Archivo 2"). }
  TTramoUbicacion = record
    Rotulo: string;
    Valor: string;
    { El documento esta en un lugar distinto del que tiene su subserie en este tramo. }
    Difiere: Boolean;
  end;

  { Ubicacion fisica de una subserie o de un documento: tramos de mayor a menor.
    Completa solo si todos los tramos tienen valor. }
  TUbicacion = record
    Titulo: string;
    Tramos: TArray<TTramoUbicacion>;
    Completa: Boolean;
    { Cuantos tramos no coinciden con los de la subserie (ver MarcarDiferencias). }
    Diferencias: Integer;
  end;

{ Servidor, Archivo, Deposito, Gaveta y Posicion del documento; un tramo vacio
  o "0" dice "Sin asignar". }
function UbicacionDeDocumento(const D: TDatosDocumento): TUbicacion;
{ Marca en Doc los tramos (servidor, archivo, deposito, gaveta) que tienen valor y son
  distintos de los de la subserie: un documento debe estar donde esta su subserie.
  No compara la posicion (la subserie no la define) ni tramos sin dato. }
procedure MarcarDiferencias(var Doc: TUbicacion; const Sub: TUbicacion);
{ Como la del documento pero de la subserie: sin posicion. }
function UbicacionDeSubserie(const Servidor, Archivo, Deposito,
  Gaveta: string): TUbicacion;

{ Propiedades de ConstruirPropiedades que van en una pestana: Datos = grupos
  General y Expediente; Ubicacion = Posicion fisica; Archivos = Ficheros. Las
  demas pestanas (Metadatos, Historia, Contenido) se arman aparte: vacio. }
function PropiedadesDePestana(const Props: TArray<TPropiedad>;
  P: TPestanaDoc): TArray<TPropiedad>;

{ '', 'En archivo' o 'Prestado'. }
function TextoEstadoDoc(E: TEstadoDoc): string;
{ Texto: sin distinguir mayusculas ni espacios extremos, busca en codigo,
  titulo y expediente; vacio coincide con todo. Estado solo cuenta si
  FiltrarEstado. }
function CoincideFiltro(const D: TDatosDocumento; const Texto: string;
  FiltrarEstado: Boolean; Estado: TEstadoDoc): Boolean;

implementation

uses
  System.SysUtils, System.Math;

function MetadatosParaMostrar(const M: TArray<TPropiedad>): TArray<TPropiedad>;
var
  I: Integer;
begin
  Result := Copy(M);
  for I := 0 to High(Result) do
    if Trim(Result[I].Valor) = '' then
      Result[I].Valor := '-';
end;

function AgruparFicheros(const F: TArray<TFicheroDoc>): TArray<TGrupoFicheros>;
var
  Anexos, Fuentes: TArray<TFicheroDoc>;
  I, NA, NF: Integer;

  procedure Ordena(var L: TArray<TFicheroDoc>);
  var
    A, B: Integer;
    T: TFicheroDoc;
  begin
    for A := 1 to High(L) do
    begin
      T := L[A];
      B := A - 1;
      while (B >= 0) and (CompareText(L[B].Nombre, T.Nombre) > 0) do
      begin
        L[B + 1] := L[B];
        Dec(B);
      end;
      L[B + 1] := T;
    end;
  end;

begin
  SetLength(Anexos, Length(F));
  SetLength(Fuentes, Length(F));
  NA := 0;
  NF := 0;
  for I := 0 to High(F) do
    if F[I].EsFuente then
    begin
      Fuentes[NF] := F[I];
      Inc(NF);
    end
    else
    begin
      Anexos[NA] := F[I];
      Inc(NA);
    end;
  SetLength(Anexos, NA);
  SetLength(Fuentes, NF);
  Ordena(Anexos);
  Ordena(Fuentes);
  Result := nil;
  if NA > 0 then
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)].Titulo := 'Anexos digitales';
    Result[High(Result)].Ficheros := Anexos;
  end;
  if NF > 0 then
  begin
    SetLength(Result, Length(Result) + 1);
    Result[High(Result)].Titulo := 'Fuentes';
    Result[High(Result)].Ficheros := Fuentes;
  end;
end;

function PropiedadesDeArchivos(const F: TArray<TFicheroDoc>): TArray<TPropiedad>;
var
  G: TArray<TGrupoFicheros>;
  I, J, N: Integer;
begin
  G := AgruparFicheros(F);
  if Length(G) = 0 then
  begin
    SetLength(Result, 1);
    Result[0].Grupo := 'Archivos';
    Result[0].Etiqueta := 'Archivos';
    Result[0].Valor := 'Sin ficheros';
    Exit;
  end;
  SetLength(Result, Length(F));
  N := 0;
  for I := 0 to High(G) do
    for J := 0 to High(G[I].Ficheros) do
    begin
      Result[N].Grupo := G[I].Titulo;
      Result[N].Etiqueta := UpperCase(ExtensionNormal(G[I].Ficheros[J].Extension));
      if Result[N].Etiqueta = '' then
        Result[N].Etiqueta := 'FICHERO';
      Result[N].Valor := G[I].Ficheros[J].Nombre + ' (' +
        FormatoTamano(G[I].Ficheros[J].Tamano) + ')';
      Inc(N);
    end;
end;

procedure AgregaTramo(var U: TUbicacion; const Rotulo, Valor: string);
var
  V: string;
begin
  V := Trim(Valor);
  if V = '0' then
    V := '';
  SetLength(U.Tramos, Length(U.Tramos) + 1);
  U.Tramos[High(U.Tramos)].Rotulo := Rotulo;
  if V = '' then
  begin
    U.Tramos[High(U.Tramos)].Valor := 'Sin asignar';
    U.Completa := False;
  end
  else
    U.Tramos[High(U.Tramos)].Valor := V;
end;

function UbicacionDeDocumento(const D: TDatosDocumento): TUbicacion;
begin
  Result := Default(TUbicacion);
  Result.Titulo := 'Documento';
  Result.Completa := True;
  AgregaTramo(Result, 'Servidor', D.Servidor);
  AgregaTramo(Result, 'Archivo', D.Archivo);
  AgregaTramo(Result, 'Depósito', D.Deposito);
  AgregaTramo(Result, 'Gaveta', D.Gaveta);
  AgregaTramo(Result, 'Posición', D.Posicion);
end;

procedure MarcarDiferencias(var Doc: TUbicacion; const Sub: TUbicacion);
var
  I, J: Integer;
  A, B: string;
begin
  Doc.Diferencias := 0;
  for I := 0 to High(Doc.Tramos) do
  begin
    Doc.Tramos[I].Difiere := False;
    for J := 0 to High(Sub.Tramos) do
      if SameText(Doc.Tramos[I].Rotulo, Sub.Tramos[J].Rotulo) then
      begin
        A := Trim(Doc.Tramos[I].Valor);
        B := Trim(Sub.Tramos[J].Valor);
        if (A <> '') and (B <> '') and (A <> 'Sin asignar') and (B <> 'Sin asignar') and
          not SameText(A, B) then
        begin
          Doc.Tramos[I].Difiere := True;
          Inc(Doc.Diferencias);
        end;
        Break;
      end;
  end;
end;

function UbicacionDeSubserie(const Servidor, Archivo, Deposito,
  Gaveta: string): TUbicacion;
begin
  Result := Default(TUbicacion);
  Result.Titulo := 'Subserie';
  Result.Completa := True;
  AgregaTramo(Result, 'Servidor', Servidor);
  AgregaTramo(Result, 'Archivo', Archivo);
  AgregaTramo(Result, 'Depósito', Deposito);
  AgregaTramo(Result, 'Gaveta', Gaveta);
end;

function PropiedadesDePestana(const Props: TArray<TPropiedad>;
  P: TPestanaDoc): TArray<TPropiedad>;
var
  I, N: Integer;
  Quiere: Boolean;
begin
  SetLength(Result, Length(Props));
  N := 0;
  for I := 0 to High(Props) do
  begin
    case P of
      pdDatos: Quiere := (Props[I].Grupo = 'General') or (Props[I].Grupo = 'Expediente');
      pdUbicacion: Quiere := Props[I].Grupo = 'Posición física';
      pdArchivos: Quiere := Props[I].Grupo = 'Ficheros';
    else
      Quiere := False;
    end;
    if Quiere then
    begin
      Result[N] := Props[I];
      Inc(N);
    end;
  end;
  SetLength(Result, N);
end;

function TextoEstadoDoc(E: TEstadoDoc): string;
begin
  case E of
    edEnArchivo: Result := 'En archivo';
    edPrestado: Result := 'Prestado';
    edTransferido: Result := 'Transferido';
  else
    Result := '';
  end;
end;

function CoincideFiltro(const D: TDatosDocumento; const Texto: string;
  FiltrarEstado: Boolean; Estado: TEstadoDoc): Boolean;
var
  T: string;
begin
  Result := False;
  if FiltrarEstado and (D.Estado <> Estado) then
    Exit;
  T := LowerCase(Trim(Texto));
  Result := (T = '') or (Pos(T, LowerCase(D.Clave.Codigodoc)) > 0) or
    (Pos(T, LowerCase(D.Titulo)) > 0) or (Pos(T, LowerCase(D.IdExpediente)) > 0);
end;

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
  AgregaPartePosicion(Result, 'Depósito', D.Deposito);
  AgregaPartePosicion(Result, 'Gaveta', D.Gaveta);
  AgregaPartePosicion(Result, 'Posición', D.Posicion);
  if Result = '' then
    Result := 'Sin ubicación asignada';
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
  AgregaProp(Result, 'General', 'Código', D.Clave.Codigodoc);
  AgregaProp(Result, 'General', 'Título', D.Titulo);
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
  AgregaProp(Result, 'Posición física', 'Ubicación', TextoPosicion(D));
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
