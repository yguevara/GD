unit UPruebasDepuracionActa;

{ Lineas, firmas y cabecera del Acta de eliminacion fisica (Anexo 19): la parte pura,
  sin FastReport. Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasDepuracionActa = class
  public
    [Test]
    procedure UnGrupoDaUnaLineaConUnidadesEnLetrasYLaMuestra;
    [Test]
    procedure DosGruposRepitenLaMismaMuestraEnCadaLinea;
    [Test]
    procedure SinGruposNoHayLineas;
    [Test]
    procedure LaDescripcionLargaNoSeRecorta;
    [Test]
    procedure LaSubserieSeAgregaALaDescripcion;
    [Test]
    procedure FirmasEnElOrdenDeAlta;
    [Test]
    procedure NombreDelOrganoDeLaComision;
    [Test]
    procedure CabeceraDeUnaDepuracionEjecutada;
    [Test]
    procedure CabeceraSinEjecutarUsaLaFechaPrevista;
  end;

implementation

uses
  System.SysUtils, UAutorizacion, UDepuracionReglas, UDepuracionDatos, UDepuracionActa;

function Grupo(const Serie, Subserie: string; Unidades: Integer): TGrupoDepuracion;
begin
  Result := Default(TGrupoDepuracion);
  Result.Serie := Serie;
  Result.Subserie := Subserie;
  Result.Unidades := Unidades;
  Result.Desde := EncodeDate(2008, 1, 1);
  Result.Hasta := EncodeDate(2012, 12, 31);
end;

function Acta: TActaDepuracion;
begin
  Result.Lugar := 'Planta de reciclaje municipal';
  Result.Via := veTrituracion;
  Result.FPrevista := EncodeDate(2026, 11, 20);
  Result.MuestraDesc := 'Facturas de enero de cada ano';
  Result.MuestraDonde := 'Dep. 1 - Est. B - Caja M-2';
end;

procedure TPruebasDepuracionActa.UnGrupoDaUnaLineaConUnidadesEnLetrasYLaMuestra;
var
  L: TArray<TLineaActa>;
begin
  L := LineasActaDepuracion([Grupo('Facturas de proveedores', '', 1240)], Acta);
  Assert.AreEqual(1, Length(L));
  Assert.AreEqual('Facturas de proveedores', L[0].Descripcion);
  Assert.AreEqual('1 240 (mil doscientas cuarenta)', L[0].Unidades);
  Assert.AreEqual('01/2008 - 12/2012', L[0].Fechas);
  Assert.AreEqual('Facturas de enero de cada ano', L[0].MuestraDesc);
  Assert.AreEqual('Dep. 1 - Est. B - Caja M-2', L[0].MuestraDonde);
end;

procedure TPruebasDepuracionActa.DosGruposRepitenLaMismaMuestraEnCadaLinea;
var
  L: TArray<TLineaActa>;
begin
  L := LineasActaDepuracion([Grupo('Circulares', '', 320), Grupo('Facturas', '', 85)], Acta);
  Assert.AreEqual(2, Length(L));
  Assert.AreEqual('Circulares', L[0].Descripcion, 'en el orden dado');
  Assert.AreEqual('Facturas', L[1].Descripcion);
  Assert.AreEqual(L[0].MuestraDesc, L[1].MuestraDesc);
  Assert.AreEqual(L[0].MuestraDonde, L[1].MuestraDonde);
  Assert.AreEqual('85 (ochenta y cinco)', L[1].Unidades);
end;

procedure TPruebasDepuracionActa.SinGruposNoHayLineas;
begin
  Assert.AreEqual(0, Length(LineasActaDepuracion([], Acta)));
end;

procedure TPruebasDepuracionActa.LaDescripcionLargaNoSeRecorta;
var
  L: TArray<TLineaActa>;
begin
  L := LineasActaDepuracion([Grupo(StringOfChar('s', 300), '', 1)], Acta);
  Assert.AreEqual(300, Length(L[0].Descripcion));
end;

procedure TPruebasDepuracionActa.LaSubserieSeAgregaALaDescripcion;
var
  L: TArray<TLineaActa>;
begin
  L := LineasActaDepuracion([Grupo('Facturas de proveedores', 'Facturas recibidas', 5)], Acta);
  Assert.AreEqual('Facturas de proveedores / Facturas recibidas', L[0].Descripcion);
  L := LineasActaDepuracion([Grupo('Igual', 'Igual', 5)], Acta);
  Assert.AreEqual('Igual', L[0].Descripcion, 'si coinciden no se repite');
end;

procedure TPruebasDepuracionActa.FirmasEnElOrdenDeAlta;
var
  T: TArray<TTestigoFila>;
  F: TArray<TFirmaActa>;
begin
  SetLength(T, 3);
  T[0].Nombre := 'Elena Ruiz';
  T[0].Cargo := 'Presidenta de la Comision';
  T[1].Nombre := 'Pedro Sosa';
  T[1].Cargo := '';
  T[2].Nombre := 'R. Perez';
  T[2].Cargo := 'Responsable del archivo de gestion';
  F := FirmasActaDepuracion(T);
  Assert.AreEqual(3, Length(F));
  Assert.AreEqual('Elena Ruiz', F[0].Nombre);
  Assert.AreEqual('Presidenta de la Comision', F[0].Cargo);
  Assert.AreEqual('', F[1].Cargo);
  Assert.AreEqual('R. Perez', F[2].Nombre);
  Assert.AreEqual(0, Length(FirmasActaDepuracion([])));
end;

procedure TPruebasDepuracionActa.NombreDelOrganoDeLaComision;
begin
  Assert.AreEqual('Nacional', NombreOrganoComision(ocNacional));
  Assert.AreEqual('Provincial', NombreOrganoComision(ocProvincial));
  Assert.AreEqual('Municipal', NombreOrganoComision(ocMunicipal));
  Assert.AreEqual('Central', NombreOrganoComision(ocCentral));
end;

procedure TPruebasDepuracionActa.CabeceraDeUnaDepuracionEjecutada;
var
  S: string;
begin
  S := TextoCabeceraActa('Provincial', '14', '9', EncodeDate(2026, 9, 3),
    EncodeDate(2026, 11, 20), True, 'Planta de reciclaje municipal', veTrituracion);
  Assert.IsTrue(Pos('Provincial', S) > 0, S);
  Assert.IsTrue(Pos('Acta 14', S) > 0, S);
  Assert.IsTrue(Pos('Acuerdo 9', S) > 0, S);
  Assert.IsTrue(Pos('03/09/2026', S) > 0, S);
  Assert.IsTrue(Pos('Eliminaci'#243'n 20/11/2026', S) > 0, S);
  Assert.IsTrue(Pos('Planta de reciclaje municipal', S) > 0, S);
  Assert.IsTrue(Pos('Trituraci'#243'n', S) > 0, S);
  Assert.AreEqual(0, Pos('Fecha prevista', S));
end;

procedure TPruebasDepuracionActa.CabeceraSinEjecutarUsaLaFechaPrevista;
var
  S: string;
begin
  S := TextoCabeceraActa('Municipal', '3', '7', EncodeDate(2026, 9, 3),
    EncodeDate(2026, 11, 20), False, 'Patio', veIncineracion);
  Assert.IsTrue(Pos('Fecha prevista de eliminaci'#243'n 20/11/2026', S) > 0, S);
  Assert.IsTrue(Pos('Incineraci'#243'n', S) > 0, S);
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasDepuracionActa);

end.
