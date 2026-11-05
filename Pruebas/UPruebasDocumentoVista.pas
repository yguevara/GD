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
  Assert.AreEqual('Servidor SRV1 > Archivo A2 > Deposito D2 > Gaveta 14 > Posicion 3',
    TextoPosicion(D));
end;

procedure TPruebasDocumentoVista.TextoPosicion_Parcial_OmiteVacios;
var
  D: TDatosDocumento;
begin
  D := Nuevo('P2');
  D.Deposito := 'D2';
  D.Gaveta := '14';
  Assert.AreEqual('Deposito D2 > Gaveta 14', TextoPosicion(D));
end;

procedure TPruebasDocumentoVista.TextoPosicion_Vacia;
var
  D: TDatosDocumento;
begin
  D := Nuevo('P3');
  Assert.AreEqual('Sin ubicacion asignada', TextoPosicion(D));
  D.Deposito := '   ';
  Assert.AreEqual('Sin ubicacion asignada', TextoPosicion(D));
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
  Assert.AreEqual('EXP-0103', Valor(P, 'General', 'Codigo', Ok));
  Assert.IsTrue(Ok);
  Assert.AreEqual('Acta 103', Valor(P, 'General', 'Titulo', Ok));
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
  Assert.IsFalse(Ok, 'vacio no aparece');
  Valor(P, 'General', 'Subexpediente', Ok);
  Assert.IsFalse(Ok, 'vacio no aparece');
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
  Assert.AreEqual(TextoPosicion(D), Valor(P, 'Posicion fisica', 'Ubicacion', Ok));
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

initialization
  TDUnitX.RegisterTestFixture(TPruebasDocumentoVista);

end.
