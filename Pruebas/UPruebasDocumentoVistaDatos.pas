unit UPruebasDocumentoVistaDatos;

{ Pruebas de UDocumentoVistaDatos (indicadores por documento: hijos de un
  expediente con alcance, vertices geo y ficheros).
  - TPruebasDocumentoVistaTexto: sin base de datos.
  - TPruebasDocumentoVistaSql: contra SQL Server (ARCHIGENIO_TEST_DB), con los
    datos de TEscenario y filas propias dentro de una transaccion que se
    deshace al final.
  - TPruebasDocumentoVistaAccess: contra la COPIA de un .mdb
    (ARCHIGENIO_TEST_MDB), sin alcance. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UAlcance, UAlcanceDatos,
  UDocumentoVista, UDocumentoVistaDatos, UPruebasAlcanceDatos;

type
  [TestFixture]
  TPruebasDocumentoVistaTexto = class
  public
    [Test]
    procedure ClaveTexto_NoDependeDeMayusculasNiEspacios;
    [Test]
    procedure ClaveTexto_DistingueFechaDiaMayorQueDoce;
  end;

  { Siembra comun a ambos motores. En el nodo A.4.3/104 (existente en las
    bases de prueba con las subseries 014001 y 074; 003 la crea TEscenario):
      F2T-EXP  expediente en 014001, 3 vertices geo, 2 ficheros digitales
               (pdf, pdf) y 1 fuente (docx)
      F2T-H1   en 074 (publica) con IDExpediente = F2T-EXP
      F2T-H2   en 003 (no publica, fuera de la cobertura de usr1) idem
      F2T-H3   en 014001 (cubierta por usr1) idem
      F2T-X    en 014001 con IDExpediente = NO-EXISTE
    Fecha 2026-01-31 (dia mayor que 12), Version '1'. }
  TSembradoVista = class
  public
    class procedure Sembrar(Conn: TFDConnection);
    class function Clave(const Cod, CodSubs: string): TClaveDocumento;
  end;

  [TestFixture]
  TPruebasDocumentoVistaSql = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    function Cargar(const Usuario: string; EsAdmin: Boolean): TIndicadoresDocs;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Hijos_CuentaLosQueApuntanAlExpediente;
    [Test]
    procedure Hijos_SoloLosVisiblesParaElUsuario;
    [Test]
    procedure Hijos_ExpedienteInexistente_NoFalla;
    [Test]
    procedure Hijos_OtroNodoConElMismoCodigo_NoCuenta;
    [Test]
    procedure Hijos_ReferenciasConEspacios_SeSuman;
    [Test]
    procedure Geo_CuentaVertices;
    [Test]
    procedure Ficheros_DigitalesYFuentes;
    [Test]
    procedure Fecha_ConDiaMayorQueDoce;
  end;

  [TestFixture]
  TPruebasDocumentoVistaAccess = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    function Cargar: TIndicadoresDocs;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Access_HijosGeoYFicheros;
    [Test]
    procedure Access_ExpedienteInexistente_NoFalla;
  end;

implementation

uses
  System.SysUtils, System.Generics.Collections, UEsquemaAlcance;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  VAR_MDB = 'ARCHIGENIO_TEST_MDB';
  EST = 'A.4.3';
  NODO = 104;

{ TPruebasDocumentoVistaTexto }

procedure TPruebasDocumentoVistaTexto.ClaveTexto_NoDependeDeMayusculasNiEspacios;
var
  A, B: TClaveDocumento;
begin
  A := TSembradoVista.Clave('F2T-EXP', '014001');
  B := A;
  B.IdEstructura := ' a.4.3 ';
  B.Codigodoc := 'f2t-exp  ';
  Assert.AreEqual(ClaveTexto(A), ClaveTexto(B));
end;

procedure TPruebasDocumentoVistaTexto.ClaveTexto_DistingueFechaDiaMayorQueDoce;
var
  A, B: TClaveDocumento;
begin
  A := TSembradoVista.Clave('X', '014001');
  B := A;
  B.Fecha := EncodeDate(2026, 1, 12);
  Assert.AreNotEqual(ClaveTexto(A), ClaveTexto(B));
  B.Fecha := EncodeDate(2026, 1, 31);
  Assert.AreEqual(ClaveTexto(A), ClaveTexto(B));
end;

{ TSembradoVista }

class function TSembradoVista.Clave(const Cod, CodSubs: string): TClaveDocumento;
begin
  Result := Default(TClaveDocumento);
  Result.IdEstructura := EST;
  Result.Id := NODO;
  Result.CodSubs := CodSubs;
  Result.Fecha := EncodeDate(2026, 1, 31);
  Result.Version := '1';
  Result.Codigodoc := Cod;
end;

class procedure TSembradoVista.Sembrar(Conn: TFDConnection);

  procedure Doc(const Cod, CodSubs, IdExp: string);
  begin
    Conn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, ' +
      'Version, Codigodoc, titulodoc, IDExpediente) VALUES (:a, :b, :c, :d, :e, :f, :g, :h)',
      [EST, NODO, CodSubs, EncodeDate(2026, 1, 31), '1', Cod, 'prueba vista', IdExp]);
  end;

  procedure Vertice(N: Integer);
  begin
    Conn.ExecSQL('INSERT INTO tb_DocCoord (IdEstructura, id, codsubs, Fecha, Version, ' +
      'Codigodoc, idVertice, x, y) VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i)',
      [EST, NODO, '014001', EncodeDate(2026, 1, 31), '1', 'F2T-EXP', N, 10.5 * N, 20.25 * N]);
  end;

  procedure Fichero(N: Integer; const Ext, Fuente: string);
  begin
    Conn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, ' +
      'Version, Codigodoc, idhijo, nombre, extnombre, fuente) ' +
      'VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, :j)',
      [EST, NODO, '014001', EncodeDate(2026, 1, 31), '1', 'F2T-EXP', N,
      'f2t' + IntToStr(N) + '.' + Ext, Ext, Fuente]);
  end;

begin
  Doc('F2T-EXP', '014001', '');
  Doc('F2T-H1', '074', 'F2T-EXP');
  Doc('F2T-H2', '003', 'F2T-EXP');
  Doc('F2T-H3', '014001', 'F2T-EXP');
  Doc('F2T-X', '014001', 'NO-EXISTE');
  Vertice(1);
  Vertice(2);
  Vertice(3);
  Fichero(1, 'pdf', 'N');
  Fichero(2, 'pdf', 'N');
  Fichero(3, 'docx', 'S');
end;

{ TPruebasDocumentoVistaSql }

procedure TPruebasDocumentoVistaSql.Preparar;
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
  TSembradoVista.Sembrar(FConn);
end;

procedure TPruebasDocumentoVistaSql.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
end;

function TPruebasDocumentoVistaSql.Cargar(const Usuario: string;
  EsAdmin: Boolean): TIndicadoresDocs;
var
  Al: TAlcanceUsuario;
begin
  Al := CargarAlcance(FConn, Usuario, EsAdmin);
  try
    Result := CargarIndicadores(FConn, Al, EST, NODO, '014001');
  finally
    Al.Free;
  end;
end;

procedure TPruebasDocumentoVistaSql.Hijos_CuentaLosQueApuntanAlExpediente;
var
  R: TIndicadoresDocs;
  I: TIndicadoresDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := Cargar('administrador', True);
  try
    Assert.IsTrue(R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-EXP', '014001')), I));
    Assert.AreEqual(3, I.NumHijos);
  finally
    R.Free;
  end;
end;

procedure TPruebasDocumentoVistaSql.Hijos_SoloLosVisiblesParaElUsuario;
var
  R: TIndicadoresDocs;
  I: TIndicadoresDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // usr1 cubre 014001 en A.4.3/104 y ve lo publico (074); no ve F2T-H2 (003)
  R := Cargar('prueba_alc_usr1', False);
  try
    Assert.IsTrue(R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-EXP', '014001')), I));
    Assert.AreEqual(2, I.NumHijos);
  finally
    R.Free;
  end;
end;

procedure TPruebasDocumentoVistaSql.Hijos_ExpedienteInexistente_NoFalla;
var
  R: TIndicadoresDocs;
  I: TIndicadoresDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := Cargar('administrador', True);
  try
    if R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-X', '014001')), I) then
      Assert.AreEqual(0, I.NumHijos);
    Assert.IsTrue(True, 'no lanzo');
  finally
    R.Free;
  end;
end;

procedure TPruebasDocumentoVistaSql.Hijos_OtroNodoConElMismoCodigo_NoCuenta;
var
  R: TIndicadoresDocs;
  I: TIndicadoresDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // Un documento de OTRO nodo (mismo IdEstructura, otro id) que apunta al mismo
  // codigo de expediente no es hijo del expediente de este nodo
  FConn.ExecSQL('INSERT INTO tb_tree (IdEstructura, id, etiqueta, padre, visible) ' +
    'VALUES (:a, :b, ''prueba vista'', 1, 1)', [EST, 99104]);
  FConn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) VALUES (:a, :b, :c)',
    [EST, 99104, '074']);
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc, IDExpediente) VALUES (:a, :b, :c, :d, :e, :f, :g, :h)',
    [EST, 99104, '074', EncodeDate(2026, 1, 31), '1', 'F2T-AJENO', 'prueba vista', 'F2T-EXP']);
  R := Cargar('administrador', True);
  try
    Assert.IsTrue(R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-EXP', '014001')), I));
    Assert.AreEqual(3, I.NumHijos, 'el documento del otro nodo no cuenta');
  finally
    R.Free;
  end;
end;

procedure TPruebasDocumentoVistaSql.Hijos_ReferenciasConEspacios_SeSuman;
var
  R: TIndicadoresDocs;
  I: TIndicadoresDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // ' F2T-EXP' y 'F2T-EXP' son el mismo expediente: los hijos se suman
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc, IDExpediente) VALUES (:a, :b, :c, :d, :e, :f, :g, :h)',
    [EST, NODO, '074', EncodeDate(2026, 1, 31), '1', 'F2T-H4', 'prueba vista', ' F2T-EXP']);
  R := Cargar('administrador', True);
  try
    Assert.IsTrue(R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-EXP', '014001')), I));
    Assert.AreEqual(4, I.NumHijos, '3 con el codigo exacto + 1 con espacio');
  finally
    R.Free;
  end;
end;

procedure TPruebasDocumentoVistaSql.Geo_CuentaVertices;
var
  R: TIndicadoresDocs;
  I: TIndicadoresDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := Cargar('administrador', True);
  try
    Assert.IsTrue(R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-EXP', '014001')), I));
    Assert.AreEqual(3, I.NumVerticesGeo);
    if R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-H3', '014001')), I) then
      Assert.AreEqual(0, I.NumVerticesGeo, 'sin vertices');
  finally
    R.Free;
  end;
end;

procedure TPruebasDocumentoVistaSql.Ficheros_DigitalesYFuentes;
var
  R: TIndicadoresDocs;
  I: TIndicadoresDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  R := Cargar('administrador', True);
  try
    Assert.IsTrue(R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-EXP', '014001')), I));
    Assert.AreEqual(2, I.NumFicheros);
    Assert.AreEqual(1, I.NumFuentes);
    Assert.AreEqual('pdf', I.ExtPrincipal);
  finally
    R.Free;
  end;
end;

procedure TPruebasDocumentoVistaSql.Fecha_ConDiaMayorQueDoce;
var
  R: TIndicadoresDocs;
  I: TIndicadoresDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // los documentos sembrados tienen Fecha 31/01: si la fecha se enlazara como
  // texto dd/mm/yyyy en un servidor en ingles, la clave no coincidiria
  R := Cargar('administrador', True);
  try
    Assert.IsTrue(R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-EXP', '014001')), I));
    Assert.AreEqual(3, I.NumVerticesGeo);
  finally
    R.Free;
  end;
end;

{ TPruebasDocumentoVistaAccess }

procedure TPruebasDocumentoVistaAccess.Preparar;
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
  // la copia de Access puede no traer las subseries 014001 y 074 en el nodo
  if Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_Serietree WHERE ' +
    'IdEstructura = ''A.4.3'' AND id = 104 AND codsubs = ''014001''')) = 0 then
    FConn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) ' +
      'VALUES (''A.4.3'', 104, ''014001'')');
  if Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_Serietree WHERE ' +
    'IdEstructura = ''A.4.3'' AND id = 104 AND codsubs = ''074''')) = 0 then
    FConn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) ' +
      'VALUES (''A.4.3'', 104, ''074'')');
  TSembradoVista.Sembrar(FConn);
end;

procedure TPruebasDocumentoVistaAccess.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
end;

function TPruebasDocumentoVistaAccess.Cargar: TIndicadoresDocs;
begin
  Result := CargarIndicadores(FConn, nil, EST, NODO, '014001');
end;

procedure TPruebasDocumentoVistaAccess.Access_HijosGeoYFicheros;
var
  R: TIndicadoresDocs;
  I: TIndicadoresDoc;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  R := Cargar;
  try
    Assert.IsTrue(R.TryGetValue(ClaveTexto(TSembradoVista.Clave('F2T-EXP', '014001')), I));
    Assert.AreEqual(3, I.NumHijos, 'sin alcance: los 3 hijos');
    Assert.AreEqual(3, I.NumVerticesGeo);
    Assert.AreEqual(2, I.NumFicheros);
    Assert.AreEqual(1, I.NumFuentes);
    Assert.AreEqual('pdf', I.ExtPrincipal);
  finally
    R.Free;
  end;
end;

procedure TPruebasDocumentoVistaAccess.Access_ExpedienteInexistente_NoFalla;
var
  R: TIndicadoresDocs;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  R := Cargar;
  try
    Assert.IsTrue(R <> nil);
  finally
    R.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasDocumentoVistaTexto);
  TDUnitX.RegisterTestFixture(TPruebasDocumentoVistaSql);
  TDUnitX.RegisterTestFixture(TPruebasDocumentoVistaAccess);

end.
