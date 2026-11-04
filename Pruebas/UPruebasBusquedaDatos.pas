unit UPruebasBusquedaDatos;

{ Pruebas de UBusquedaDatos.
  - TPruebasBusquedaDatos: validaciones de Buscar que no tocan la base.
  - TPruebasBusquedaAccess: contra la copia de un .mdb (ARCHIGENIO_TEST_MDB).
  - TPruebasBusquedaSql: contra SQL Server (ARCHIGENIO_TEST_DB), con los datos
    de TEscenario sembrados dentro de una transaccion que se deshace. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UPruebasAlcanceDatos;

type
  [TestFixture]
  TPruebasBusquedaDatos = class
  public
    [Test]
    procedure Buscar_PedidoVacio_Lanza;
    [Test]
    procedure Buscar_FiltrosSinSubserie_Lanza;
  end;

  [TestFixture]
  TPruebasBusquedaSql = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    function Contar(const Usuario: string; EsAdmin: Boolean): Integer;
    function Buscar(const Texto, CodSubs, Usuario: string; EsAdmin: Boolean;
      Limite: Integer; out Truncado: Boolean): Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Buscar_RespetaAlcance;
    [Test]
    procedure Buscar_Truncado;
    [Test]
    procedure Buscar_TablaMdInexistente;
    [Test]
    procedure Buscar_PorcientoYApostrofeSonLiterales;
  end;

  [TestFixture]
  TPruebasBusquedaAccess = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    function Buscar(const Texto, CodSubs: string; Limite: Integer;
      out Truncado: Boolean): Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Access_BuscaTextoEnTitulo;
    [Test]
    procedure Access_Truncado;
    [Test]
    procedure Access_TablaMdInexistente;
    [Test]
    procedure Access_PorcientoYApostrofeSonLiterales;
  end;

implementation

uses
  System.SysUtils, Data.DB, UAlcance, UAlcanceDatos, UBusqueda, UBusquedaDatos,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, UEsquemaAlcance;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  VAR_MDB = 'ARCHIGENIO_TEST_MDB';
  TITULO_PRUEBA = 'prueba alcance';

{ TPruebasBusquedaDatos }

procedure TPruebasBusquedaDatos.Buscar_PedidoVacio_Lanza;
var
  P: TPedidoBusqueda;
  Trunc: Boolean;
begin
  P.Texto := '';
  P.CodSubs := '';
  P.Condiciones := nil;
  P.Limite := 0;
  Assert.WillRaise(
    procedure begin UBusquedaDatos.Buscar(nil, nil, P, True, Trunc).Free; end,
    Exception);
end;

procedure TPruebasBusquedaDatos.Buscar_FiltrosSinSubserie_Lanza;
var
  P: TPedidoBusqueda;
  Trunc: Boolean;
begin
  P.Texto := 'acta';
  P.CodSubs := '';
  SetLength(P.Condiciones, 1);
  P.Condiciones[0].Campo := 'Depto';
  P.Condiciones[0].Desde := 'x';
  P.Condiciones[0].Hasta := '';
  P.Limite := 0;
  Assert.WillRaise(
    procedure begin UBusquedaDatos.Buscar(nil, nil, P, True, Trunc).Free; end,
    Exception);
end;

{ TPruebasBusquedaSql }

procedure TPruebasBusquedaSql.Preparar;
var
  NombreBD: string;
begin
  FConn := nil;
  FEsc := nil;
  NombreBD := GetEnvironmentVariable(VAR_BD);
  if NombreBD = '' then
    Exit;
  if SameText(NombreBD, 'SGDDRHMAIN') then
    raise Exception.Create('Las pruebas no deben correr contra SGDDRHMAIN');
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := NombreBD;
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
  CrearEsquemaAlcance(FConn, True);
  FEsc := TEscenario.Create(FConn);
  FConn.StartTransaction;
  FEsc.Sembrar;
end;

procedure TPruebasBusquedaSql.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
end;

{ Documentos sembrados que el alcance deja ver, contados con el filtro de
  alcance directamente (sin pasar por Buscar). }
function TPruebasBusquedaSql.Contar(const Usuario: string; EsAdmin: Boolean): Integer;
var
  Al: TAlcanceUsuario;
  F: TFiltroSql;
begin
  Al := CargarAlcance(FConn, Usuario, EsAdmin);
  try
    F := FiltroDocumentos(Al, 'd');
    F.Condicion := '(' + F.Condicion + ') AND d.titulodoc = ''' + TITULO_PRUEBA + '''';
    Result := FEsc.Contar(F);
  finally
    Al.Free;
  end;
end;

function TPruebasBusquedaSql.Buscar(const Texto, CodSubs, Usuario: string;
  EsAdmin: Boolean; Limite: Integer; out Truncado: Boolean): Integer;
var
  Al: TAlcanceUsuario;
  P: TPedidoBusqueda;
  T: TFDMemTable;
begin
  P.Texto := Texto;
  P.CodSubs := CodSubs;
  P.Condiciones := nil;
  P.Limite := Limite;
  Al := CargarAlcance(FConn, Usuario, EsAdmin);
  try
    T := UBusquedaDatos.Buscar(FConn, Al, P, True, Truncado);
    try
      Result := T.RecordCount;
    finally
      T.Free;
    end;
  finally
    Al.Free;
  end;
end;

procedure TPruebasBusquedaSql.Buscar_RespetaAlcance;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(Contar('administrador', True),
    Buscar(TITULO_PRUEBA, '', 'administrador', True, 100000, Trunc), 'administrador');
  Assert.AreEqual(Contar('prueba_alc_usr1', False),
    Buscar(TITULO_PRUEBA, '', 'prueba_alc_usr1', False, 100000, Trunc), 'usr1');
  Assert.AreEqual(Contar('prueba_alc_vacio', False),
    Buscar(TITULO_PRUEBA, '', 'prueba_alc_vacio', False, 100000, Trunc), 'sin asignaciones');
  Assert.AreEqual(Contar('prueba_alc_egd', False),
    Buscar(TITULO_PRUEBA, '', 'prueba_alc_egd', False, 100000, Trunc), 'egd');
end;

procedure TPruebasBusquedaSql.Buscar_Truncado;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(2, Buscar(TITULO_PRUEBA, '', 'administrador', True, 2, Trunc));
  Assert.IsTrue(Trunc, 'debe marcar que hay mas resultados');
end;

procedure TPruebasBusquedaSql.Buscar_TablaMdInexistente;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  FConn.ExecSQL('UPDATE cl_subseries SET NombreTablaMetadatos = ''md_no_existe_xyz'' ' +
    'WHERE codsubs = ''014001''');
  // Sembrar() crea 3 + 4 + 5 documentos de prueba en 014001
  Assert.AreEqual(12, Buscar(TITULO_PRUEBA, '014001', 'administrador', True, 100000, Trunc));
end;

procedure TPruebasBusquedaSql.Buscar_PorcientoYApostrofeSonLiterales;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc) VALUES (''A.4.3'', 104, ''003'', :f, ''1'', ''PBUS-1'', :t)',
    [EncodeDate(2026, 10, 29), 'Acta 100% O''Brien']);
  Assert.AreEqual(1, Buscar('100%', '', 'administrador', True, 100000, Trunc), 'porciento');
  Assert.AreEqual(1, Buscar('O''Brien', '', 'administrador', True, 100000, Trunc), 'apostrofe');
  Assert.AreEqual(1, Buscar('%', '', 'administrador', True, 100000, Trunc),
    'un % solo debe buscar el caracter, no todo');
end;

{ TPruebasBusquedaAccess }
{ Contra la COPIA de una base .mdb (ARCHIGENIO_TEST_MDB). En Access no hay
  alcance (Alcance = nil, como en la aplicacion real). }

procedure TPruebasBusquedaAccess.Preparar;
var
  Ruta: string;
begin
  FConn := nil;
  FEsc := nil;
  Ruta := GetEnvironmentVariable(VAR_MDB);
  if Ruta = '' then
    Exit;
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSAcc';
  FConn.Params.Values['Database'] := Ruta;
  FConn.Connected := True;
  CrearEsquemaAlcance(FConn, False);
  FEsc := TEscenario.Create(FConn);
  FConn.StartTransaction;
  FEsc.Sembrar;
end;

procedure TPruebasBusquedaAccess.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
end;

function TPruebasBusquedaAccess.Buscar(const Texto, CodSubs: string;
  Limite: Integer; out Truncado: Boolean): Integer;
var
  P: TPedidoBusqueda;
  T: TFDMemTable;
begin
  P.Texto := Texto;
  P.CodSubs := CodSubs;
  P.Condiciones := nil;
  P.Limite := Limite;
  T := UBusquedaDatos.Buscar(FConn, nil, P, False, Truncado);
  try
    Result := T.RecordCount;
  finally
    T.Free;
  end;
end;

procedure TPruebasBusquedaAccess.Access_BuscaTextoEnTitulo;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  // Sembrar() crea 2 + 3 + 4 + 5 documentos de prueba
  Assert.AreEqual(14, Buscar(TITULO_PRUEBA, '', 100000, Trunc));
  Assert.IsFalse(Trunc);
end;

procedure TPruebasBusquedaAccess.Access_Truncado;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  Assert.AreEqual(2, Buscar(TITULO_PRUEBA, '', 2, Trunc));
  Assert.IsTrue(Trunc);
end;

procedure TPruebasBusquedaAccess.Access_TablaMdInexistente;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  FConn.ExecSQL('UPDATE cl_subseries SET NombreTablaMetadatos = ''md_no_existe_xyz'' ' +
    'WHERE codsubs = ''014001''');
  Assert.AreEqual(12, Buscar(TITULO_PRUEBA, '014001', 100000, Trunc));
end;

procedure TPruebasBusquedaAccess.Access_PorcientoYApostrofeSonLiterales;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc) VALUES (''A.4.3'', 104, ''003'', :f, ''1'', ''PBUS-1'', :t)',
    [EncodeDate(2026, 10, 29), 'Acta 100% O''Brien']);
  Assert.AreEqual(1, Buscar('100%', '', 100000, Trunc), 'porciento');
  Assert.AreEqual(1, Buscar('O''Brien', '', 100000, Trunc), 'apostrofe');
  Assert.AreEqual(1, Buscar('%', '', 100000, Trunc),
    'un % solo debe buscar el caracter, no todo');
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasBusquedaDatos);
  TDUnitX.RegisterTestFixture(TPruebasBusquedaSql);
  TDUnitX.RegisterTestFixture(TPruebasBusquedaAccess);

end.
