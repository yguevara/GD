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
    function Valor(const P: TArray<TPropiedad>; const Grupo, Etiqueta: string;
      out Hallado: Boolean): string;
  public
    [Test]
    procedure MetadatosParaMostrar_ValorVacio_PoneGuion;
    [Test]
    procedure MetadatosParaMostrar_SinVariables_Vacio;
    [Test]
    procedure AgruparFicheros_SeparaAnexosYFuentesYOrdena;
    [Test]
    procedure AgruparFicheros_SinFicheros_Vacio;
    [Test]
    procedure PropiedadesDeArchivos_ConFicheros_UnaFilaPorFichero;
    [Test]
    procedure PropiedadesDeArchivos_SinFicheros_DiceSinFicheros;
    [Test]
    procedure MarcarDiferencias_GavetaDistinta_MarcaSoloEsaYAvisa;
    [Test]
    procedure MarcarDiferencias_IgualesOSinDato_NoMarca;
    [Test]
    procedure MarcarDiferencias_IgnoraLaPosicion;
    [Test]
    procedure UbicacionDeDocumento_Completa;
    [Test]
    procedure UbicacionDeDocumento_ConCeroOVacio_DiceSinAsignar;
    [Test]
    procedure UbicacionDeSubserie_SinPosicion;
    [Test]
    procedure PropiedadesDePestana_Datos_SoloGeneralYExpediente;
    [Test]
    procedure PropiedadesDePestana_Archivos_SoloFicheros;
    [Test]
    procedure PropiedadesDePestana_Metadatos_Vacio;
    [Test]
    procedure TextoEstadoDoc_TresValores;
    [Test]
    procedure CoincideFiltro_TextoPorCodigoTituloYExpediente;
    [Test]
    procedure CoincideFiltro_VacioCoincideConTodo;
    [Test]
    procedure CoincideFiltro_EstadoSoloSiSeFiltra;
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
    [Test]
    procedure TextoPosicion_Completa;
    [Test]
    procedure TextoPosicion_Parcial_OmiteVacios;
    [Test]
    procedure TextoPosicion_Vacia;
    [Test]
    procedure FormatoTamano_Unidades;
    [Test]
    procedure Propiedades_General;
    [Test]
    procedure Propiedades_ExpedienteYSubexp;
    [Test]
    procedure Propiedades_Posicion;
    [Test]
    procedure Propiedades_Ficheros;
    [Test]
    procedure FiltrarPorExpediente_HijosYElPropio;
    [Test]
    procedure FiltrarPorExpediente_SinFiltroYCodigoInexistente;
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

function TPruebasDocumentoVista.Valor(const P: TArray<TPropiedad>;
  const Grupo, Etiqueta: string; out Hallado: Boolean): string;
var
  I: Integer;
begin
  Hallado := False;
  Result := '';
  for I := 0 to High(P) do
    if (P[I].Grupo = Grupo) and (P[I].Etiqueta = Etiqueta) then
    begin
      Hallado := True;
      Exit(P[I].Valor);
    end;
end;

procedure TPruebasDocumentoVista.TextoPosicion_Completa;
var
  D: TDatosDocumento;
begin
  D := Nuevo('P1');
  D.Servidor := 'SRV1';
  D.Archivo := 'A2';
  D.Deposito := 'D2';
  D.Gaveta := '14';
  D.Posicion := '3';
  Assert.AreEqual('Servidor SRV1 > Archivo A2 > Depósito D2 > Gaveta 14 > Posición 3',
    TextoPosicion(D));
end;

procedure TPruebasDocumentoVista.TextoPosicion_Parcial_OmiteVacios;
var
  D: TDatosDocumento;
begin
  D := Nuevo('P2');
  D.Deposito := 'D2';
  D.Gaveta := '14';
  Assert.AreEqual('Depósito D2 > Gaveta 14', TextoPosicion(D));
end;

procedure TPruebasDocumentoVista.TextoPosicion_Vacia;
var
  D: TDatosDocumento;
begin
  D := Nuevo('P3');
  Assert.AreEqual('Sin ubicación asignada', TextoPosicion(D));
  D.Deposito := '   ';
  Assert.AreEqual('Sin ubicación asignada', TextoPosicion(D));
end;

procedure TPruebasDocumentoVista.FormatoTamano_Unidades;
begin
  Assert.AreEqual('512 B', FormatoTamano(512));
  Assert.AreEqual('1.5 KB', FormatoTamano(1536));
  Assert.AreEqual('1.2 MB', FormatoTamano(1258291));
  Assert.AreEqual('3.0 GB', FormatoTamano(3221225472.0));
  Assert.AreEqual('-', FormatoTamano(-1));
end;

procedure TPruebasDocumentoVista.Propiedades_General;
var
  D: TDatosDocumento;
  P: TArray<TPropiedad>;
  Ok: Boolean;
begin
  D := Nuevo('EXP-0103');
  D.Titulo := 'Acta 103';
  D.Clave.Fecha := EncodeDate(2026, 11, 5);
  D.Clave.Version := '2';
  P := ConstruirPropiedades(D, nil);
  Assert.AreEqual('EXP-0103', Valor(P, 'General', 'Código', Ok));
  Assert.IsTrue(Ok);
  Assert.AreEqual('Acta 103', Valor(P, 'General', 'Título', Ok));
  Assert.AreEqual('05/11/2026', Valor(P, 'General', 'Fecha', Ok));
  Assert.AreEqual('2', Valor(P, 'General', 'Version', Ok));
  Assert.AreEqual('Documento', Valor(P, 'General', 'Tipo', Ok));

  D.NumHijos := 2;
  P := ConstruirPropiedades(D, nil);
  Assert.AreEqual('Expediente', Valor(P, 'General', 'Tipo', Ok));
  Assert.AreEqual('2 documentos', Valor(P, 'Expediente', 'Contiene', Ok));
  D.NumHijos := 1;
  P := ConstruirPropiedades(D, nil);
  Assert.AreEqual('1 documento', Valor(P, 'Expediente', 'Contiene', Ok));

  D := Nuevo('M1');
  D.ExtPrincipal := 'shp';
  P := ConstruirPropiedades(D, nil);
  Assert.AreEqual('Mapa', Valor(P, 'General', 'Tipo', Ok));

  D := Nuevo('G1');
  D.ExtPrincipal := 'pdf';
  D.NumVerticesGeo := 3;
  P := ConstruirPropiedades(D, nil);
  Assert.AreEqual('Si', Valor(P, 'General', 'Georreferenciado', Ok));
  Assert.IsTrue(Ok);
end;

procedure TPruebasDocumentoVista.Propiedades_ExpedienteYSubexp;
var
  D: TDatosDocumento;
  P: TArray<TPropiedad>;
  Ok: Boolean;
begin
  D := Nuevo('D1');
  D.IdExpediente := 'EXP-0001';
  D.SubExp := 'S1';
  P := ConstruirPropiedades(D, nil);
  Assert.AreEqual('EXP-0001', Valor(P, 'General', 'Pertenece al expediente', Ok));
  Assert.IsTrue(Ok);
  Assert.AreEqual('S1', Valor(P, 'General', 'Subexpediente', Ok));
  Assert.IsTrue(Ok);
  D.IdExpediente := '';
  D.SubExp := '  ';
  P := ConstruirPropiedades(D, nil);
  Valor(P, 'General', 'Pertenece al expediente', Ok);
  Assert.IsFalse(Ok, 'vacío no aparece');
  Valor(P, 'General', 'Subexpediente', Ok);
  Assert.IsFalse(Ok, 'vacío no aparece');
end;

procedure TPruebasDocumentoVista.Propiedades_Posicion;
var
  D: TDatosDocumento;
  P: TArray<TPropiedad>;
  Ok: Boolean;
begin
  D := Nuevo('D1');
  D.Deposito := 'D2';
  P := ConstruirPropiedades(D, nil);
  Assert.AreEqual(TextoPosicion(D), Valor(P, 'Posición física', 'Ubicación', Ok));
  Assert.IsTrue(Ok);
end;

procedure TPruebasDocumentoVista.Propiedades_Ficheros;
var
  D: TDatosDocumento;
  P: TArray<TPropiedad>;
  F: TArray<TFicheroDoc>;
  Ok: Boolean;
begin
  D := Nuevo('D1');
  P := ConstruirPropiedades(D, nil);
  Assert.AreEqual('Sin ficheros', Valor(P, 'Ficheros', 'Ficheros', Ok));
  Assert.IsTrue(Ok);

  SetLength(F, 2);
  F[0].Nombre := 'acta.pdf';
  F[0].Extension := 'pdf';
  F[0].Tamano := 1258291;
  F[0].EsFuente := False;
  F[1].Nombre := 'acta.docx';
  F[1].Extension := 'docx';
  F[1].Tamano := 512;
  F[1].EsFuente := True;
  P := ConstruirPropiedades(D, F);
  Assert.AreEqual('acta.pdf (1.2 MB)', Valor(P, 'Ficheros', 'Fichero', Ok));
  Assert.IsTrue(Ok);
  Assert.AreEqual('acta.docx (512 B)', Valor(P, 'Ficheros', 'Fuente', Ok));
  Assert.IsTrue(Ok);
end;

function Lista4: TArray<TDatosDocumento>;

  function D(const Cod, Exp: string): TDatosDocumento;
  begin
    Result := Default(TDatosDocumento);
    Result.Clave.Codigodoc := Cod;
    Result.IdExpediente := Exp;
  end;

begin
  SetLength(Result, 4);
  Result[0] := D('EXP-1', '');
  Result[1] := D('A', 'EXP-1');
  Result[2] := D('B', ' exp-1 ');
  Result[3] := D('C', 'EXP-2');
end;

procedure TPruebasDocumentoVista.FiltrarPorExpediente_HijosYElPropio;
var
  R: TArray<TDatosDocumento>;
begin
  R := FiltrarPorExpediente(Lista4, 'exp-1');
  Assert.AreEqual(3, Integer(Length(R)));
  Assert.AreEqual('EXP-1', R[0].Clave.Codigodoc);
  Assert.AreEqual('A', R[1].Clave.Codigodoc);
  Assert.AreEqual('B', R[2].Clave.Codigodoc);
end;

procedure TPruebasDocumentoVista.FiltrarPorExpediente_SinFiltroYCodigoInexistente;
begin
  Assert.AreEqual(4, Integer(Length(FiltrarPorExpediente(Lista4, ''))));
  Assert.AreEqual(0, Integer(Length(FiltrarPorExpediente(Lista4, 'NO-EXISTE'))));
end;

procedure TPruebasDocumentoVista.MetadatosParaMostrar_ValorVacio_PoneGuion;
var
  M, R: TArray<TPropiedad>;
begin
  SetLength(M, 2);
  M[0].Grupo := 'Proyectos'; M[0].Etiqueta := 'Municipio'; M[0].Valor := 'Palma Soriano';
  M[1].Grupo := 'Proyectos'; M[1].Etiqueta := 'Ejecutor'; M[1].Valor := '   ';
  R := MetadatosParaMostrar(M);
  Assert.AreEqual(2, Integer(Length(R)));
  Assert.AreEqual('Palma Soriano', R[0].Valor);
  Assert.AreEqual('-', R[1].Valor, 'un valor en blanco se muestra con guion');
end;

procedure TPruebasDocumentoVista.MetadatosParaMostrar_SinVariables_Vacio;
begin
  Assert.AreEqual(0, Integer(Length(MetadatosParaMostrar(nil))));
end;

function Fichero(const Nombre, Ext: string; Tam: Double; Fuente: Boolean): TFicheroDoc;
begin
  Result.Nombre := Nombre;
  Result.Extension := Ext;
  Result.Tamano := Tam;
  Result.EsFuente := Fuente;
end;

procedure TPruebasDocumentoVista.AgruparFicheros_SeparaAnexosYFuentesYOrdena;
var
  G: TArray<TGrupoFicheros>;
begin
  G := AgruparFicheros([Fichero('b.pdf', 'pdf', 100, False),
    Fichero('memoria.docx', 'docx', 200, True), Fichero('a.pdf', 'pdf', 50, False)]);
  Assert.AreEqual(2, Integer(Length(G)));
  Assert.AreEqual('Anexos digitales', G[0].Titulo);
  Assert.AreEqual('a.pdf', G[0].Ficheros[0].Nombre, 'ordenados por nombre');
  Assert.AreEqual(2, Integer(Length(G[0].Ficheros)));
  Assert.AreEqual('Fuentes', G[1].Titulo);
  Assert.AreEqual(1, Integer(Length(G[1].Ficheros)));
end;

procedure TPruebasDocumentoVista.AgruparFicheros_SinFicheros_Vacio;
begin
  Assert.AreEqual(0, Integer(Length(AgruparFicheros(nil))));
  // solo fuentes: no aparece el grupo de anexos
  Assert.AreEqual(1, Integer(Length(AgruparFicheros([Fichero('x.docx', 'docx', 1, True)]))));
end;

procedure TPruebasDocumentoVista.PropiedadesDeArchivos_ConFicheros_UnaFilaPorFichero;
var
  P: TArray<TPropiedad>;
begin
  P := PropiedadesDeArchivos([Fichero('plano.pdf', 'pdf', 1536, False),
    Fichero('memoria.docx', 'docx', 2048, True)]);
  Assert.AreEqual(2, Integer(Length(P)));
  Assert.AreEqual('Anexos digitales', P[0].Grupo);
  Assert.AreEqual('PDF', P[0].Etiqueta);
  Assert.AreEqual('plano.pdf (1.5 KB)', P[0].Valor);
  Assert.AreEqual('Fuentes', P[1].Grupo);
end;

procedure TPruebasDocumentoVista.PropiedadesDeArchivos_SinFicheros_DiceSinFicheros;
var
  P: TArray<TPropiedad>;
begin
  P := PropiedadesDeArchivos(nil);
  Assert.AreEqual(1, Integer(Length(P)));
  Assert.AreEqual('Sin ficheros', P[0].Valor);
end;

procedure TPruebasDocumentoVista.MarcarDiferencias_GavetaDistinta_MarcaSoloEsaYAvisa;
var
  S, D: TUbicacion;
begin
  S := UbicacionDeSubserie('Servidor A', 'Contabilidad', '01', '14');
  D := UbicacionDeDocumento(Nuevo('D1'));
  D.Tramos[0].Valor := 'Servidor A';
  D.Tramos[1].Valor := 'Contabilidad';
  D.Tramos[2].Valor := '01';
  D.Tramos[3].Valor := '02';
  D.Tramos[4].Valor := '3';
  MarcarDiferencias(D, S);
  Assert.AreEqual(1, D.Diferencias);
  Assert.IsTrue(D.Tramos[3].Difiere, 'la gaveta 02 no es la 14 de la subserie');
  Assert.IsFalse(D.Tramos[2].Difiere);
  Assert.IsFalse(D.Tramos[0].Difiere);
end;

procedure TPruebasDocumentoVista.MarcarDiferencias_IgualesOSinDato_NoMarca;
var
  S, D: TUbicacion;
begin
  // iguales sin importar mayusculas ni espacios; un tramo sin dato en cualquiera
  // de los dos lados no se compara (eso ya dice "Sin asignar")
  S := UbicacionDeSubserie('Servidor A', 'Contabilidad', '01', '');
  D := UbicacionDeDocumento(Nuevo('D1'));
  D.Tramos[0].Valor := ' servidor a ';
  D.Tramos[1].Valor := 'CONTABILIDAD';
  D.Tramos[2].Valor := '01';
  D.Tramos[3].Valor := '99';
  MarcarDiferencias(D, S);
  Assert.AreEqual(0, D.Diferencias);
end;

procedure TPruebasDocumentoVista.MarcarDiferencias_IgnoraLaPosicion;
var
  S, D: TUbicacion;
begin
  S := UbicacionDeSubserie('A', 'B', 'C', 'D');
  D := UbicacionDeDocumento(Nuevo('D1'));
  D.Tramos[4].Valor := '7'; // la posicion es del documento: la subserie no la define
  MarcarDiferencias(D, S);
  Assert.IsFalse(D.Tramos[4].Difiere);
end;

procedure TPruebasDocumentoVista.UbicacionDeDocumento_Completa;
var
  D: TDatosDocumento;
  U: TUbicacion;
begin
  D := Nuevo('A1');
  D.Servidor := '3';
  D.Archivo := 'Archivo 2';
  D.Deposito := 'Depósito 01';
  D.Gaveta := 'Gaveta 02';
  D.Posicion := 'Posición 3';
  U := UbicacionDeDocumento(D);
  Assert.AreEqual('Documento', U.Titulo);
  Assert.AreEqual(5, Integer(Length(U.Tramos)));
  Assert.AreEqual('Archivo', U.Tramos[1].Rotulo);
  Assert.AreEqual('Archivo 2', U.Tramos[1].Valor);
  Assert.IsTrue(U.Completa);
end;

procedure TPruebasDocumentoVista.UbicacionDeDocumento_ConCeroOVacio_DiceSinAsignar;
var
  D: TDatosDocumento;
  U: TUbicacion;
begin
  D := Nuevo('A1');
  D.Archivo := '0';
  D.Deposito := 'Depósito 01';
  D.Gaveta := '';
  U := UbicacionDeDocumento(D);
  Assert.AreEqual('Sin asignar', U.Tramos[1].Valor, 'el 0 cuenta como sin dato');
  Assert.AreEqual('Depósito 01', U.Tramos[2].Valor);
  Assert.AreEqual('Sin asignar', U.Tramos[3].Valor);
  Assert.IsFalse(U.Completa);
end;

procedure TPruebasDocumentoVista.UbicacionDeSubserie_SinPosicion;
var
  U: TUbicacion;
begin
  U := UbicacionDeSubserie('3', 'Archivo 2', 'Depósito 01', 'Gaveta 02');
  Assert.AreEqual('Subserie', U.Titulo);
  Assert.AreEqual(4, Integer(Length(U.Tramos)));
  Assert.IsTrue(U.Completa);
  U := UbicacionDeSubserie('', '', '', '');
  Assert.IsFalse(U.Completa);
  Assert.AreEqual('Sin asignar', U.Tramos[0].Valor);
end;

function PropsPrueba: TArray<TPropiedad>;
  procedure Pon(I: Integer; const G, E, V: string);
  begin
    Result[I].Grupo := G;
    Result[I].Etiqueta := E;
    Result[I].Valor := V;
  end;
begin
  SetLength(Result, 5);
  Pon(0, 'General', 'Codigo', 'A1');
  Pon(1, 'Expediente', 'Contiene', '2 documentos');
  Pon(2, 'Posición física', 'Ubicacion', 'Archivo 2');
  Pon(3, 'Ficheros', 'Ficheros', 'Sin ficheros');
  Pon(4, 'General', 'Titulo', 'T');
end;

procedure TPruebasDocumentoVista.PropiedadesDePestana_Datos_SoloGeneralYExpediente;
var
  R: TArray<TPropiedad>;
begin
  R := PropiedadesDePestana(PropsPrueba, pdDatos);
  Assert.AreEqual(3, Integer(Length(R)));
  Assert.AreEqual('Codigo', R[0].Etiqueta);
  Assert.AreEqual('Contiene', R[1].Etiqueta);
  Assert.AreEqual('Titulo', R[2].Etiqueta);
  Assert.AreEqual(1, Integer(Length(PropiedadesDePestana(PropsPrueba, pdUbicacion))));
end;

procedure TPruebasDocumentoVista.PropiedadesDePestana_Archivos_SoloFicheros;
var
  R: TArray<TPropiedad>;
begin
  R := PropiedadesDePestana(PropsPrueba, pdArchivos);
  Assert.AreEqual(1, Integer(Length(R)));
  Assert.AreEqual('Ficheros', R[0].Grupo);
end;

procedure TPruebasDocumentoVista.PropiedadesDePestana_Metadatos_Vacio;
begin
  Assert.AreEqual(0, Integer(Length(PropiedadesDePestana(PropsPrueba, pdMetadatos))));
  Assert.AreEqual(0, Integer(Length(PropiedadesDePestana(PropsPrueba, pdHistoria))));
  Assert.AreEqual(0, Integer(Length(PropiedadesDePestana(PropsPrueba, pdContenido))));
end;

procedure TPruebasDocumentoVista.TextoEstadoDoc_TresValores;
begin
  Assert.AreEqual('', TextoEstadoDoc(edDesconocido));
  Assert.AreEqual('En archivo', TextoEstadoDoc(edEnArchivo));
  Assert.AreEqual('Prestado', TextoEstadoDoc(edPrestado));
end;

procedure TPruebasDocumentoVista.CoincideFiltro_TextoPorCodigoTituloYExpediente;
var
  D: TDatosDocumento;
begin
  D := Nuevo('A 03.01.02.0003');
  D.Titulo := 'Alcantarillado Palma Soriano';
  D.IdExpediente := 'P-006';
  Assert.IsTrue(CoincideFiltro(D, 'palma', False, edDesconocido));
  Assert.IsTrue(CoincideFiltro(D, '  a 03.01 ', False, edDesconocido));
  Assert.IsTrue(CoincideFiltro(D, 'p-006', False, edDesconocido));
  Assert.IsFalse(CoincideFiltro(D, 'contramaestre', False, edDesconocido));
end;

procedure TPruebasDocumentoVista.CoincideFiltro_VacioCoincideConTodo;
begin
  Assert.IsTrue(CoincideFiltro(Nuevo('X'), '', False, edDesconocido));
  Assert.IsTrue(CoincideFiltro(Nuevo('X'), '   ', False, edDesconocido));
end;

procedure TPruebasDocumentoVista.CoincideFiltro_EstadoSoloSiSeFiltra;
var
  D: TDatosDocumento;
begin
  D := Nuevo('X');
  D.Estado := edPrestado;
  Assert.IsTrue(CoincideFiltro(D, '', False, edEnArchivo), 'sin filtrar estado, no cuenta');
  Assert.IsTrue(CoincideFiltro(D, '', True, edPrestado));
  Assert.IsFalse(CoincideFiltro(D, '', True, edEnArchivo));
  D.Estado := edDesconocido;
  Assert.IsFalse(CoincideFiltro(D, '', True, edPrestado));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasDocumentoVista);

end.
