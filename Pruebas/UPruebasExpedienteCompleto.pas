unit UPruebasExpedienteCompleto;

{ Expediente completo: lista de ficheros (con alcance) y exportacion a carpeta o
  ZIP con un almacen en memoria. SQL Server: ARCHIGENIO_TEST_DB. Access:
  ARCHIGENIO_TEST_MDB (COPIA). Las filas se siembran dentro de una transaccion
  que se deshace. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, DUnitX.TestFramework, UAlmacenFicheros,
  UPruebasAlcanceDatos, UPruebasMigracion;

type
  [TestFixture]
  TPruebasExpedienteCompleto = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    FOrigen: TAlmacenMemoria;
    FOrigenI: IAlmacenFicheros;
    FCarpeta: string;
    procedure Conectar(EsSql: Boolean);
    procedure Fichero(const Cod, CodSubs: string; Idhijo: Integer; const Nombre: string;
      Bytes: Integer);
    procedure SembrarExtra;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SqlServer_Administrador_ListaPropioMasHijos;
    [Test]
    procedure SqlServer_UsuarioConAlcance_NoVeLosOcultos;
    [Test]
    procedure SqlServer_OtroNodo_NoSeListan;
    [Test]
    procedure SqlServer_ExpedienteSinFicheros_ListaVacia;
    [Test]
    procedure SqlServer_ExportaACarpeta_ConSubcarpetaPorDocumento;
    [Test]
    procedure SqlServer_NombresRepetidos_NoSePisan;
    [Test]
    procedure SqlServer_ExportaAZip_ContieneLoMismo;
    [Test]
    procedure SqlServer_UnFicheroFalla_ElRestoSeCopia;
    [Test]
    procedure Access_ListaYExporta;
  end;

implementation

uses
  System.Classes, System.IOUtils, System.Zip, System.Hash, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, Data.DB, UAlcance, UAlcanceDatos, UEsquemaAlcance,
  UPruebasDocumentoVistaDatos, UExpedienteCompleto;

const
  EST = 'A.4.3';
  NODO = 104;

procedure TPruebasExpedienteCompleto.Preparar;
begin
  FConn := nil;
  FEsc := nil;
  FOrigen := TAlmacenMemoria.Create;
  FOrigenI := FOrigen;
  FCarpeta := TPath.Combine(TPath.GetTempPath, 'exp-' + TGUID.NewGuid.ToString);
end;

procedure TPruebasExpedienteCompleto.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
  FOrigenI := nil;
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
  if TFile.Exists(FCarpeta + '.zip') then
    TFile.Delete(FCarpeta + '.zip');
end;

procedure TPruebasExpedienteCompleto.Fichero(const Cod, CodSubs: string; Idhijo: Integer;
  const Nombre: string; Bytes: Integer);
var
  B: TBytes;
  I: Integer;
begin
  FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, ' +
    'Version, Codigodoc, idhijo, nombre, extnombre, fuente, urlraiz, path) ' +
    'VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l)',
    [EST, NODO, CodSubs, EncodeDate(2026, 1, 31), '1', Cod, Idhijo, Nombre, 'pdf', 'N',
    '/docs/', '\A.4.3\104\']);
  SetLength(B, Bytes);
  for I := 0 to Bytes - 1 do
    B[I] := Byte((Length(Nombre) * 11 + I * 5) mod 251);
  FOrigen.Objetos.AddOrSetValue('/docs/A.4.3/104/' + Nombre, B);
end;

procedure TPruebasExpedienteCompleto.SembrarExtra;
begin
  // F2T-EXP (014001) ya trae f2t1.pdf, f2t2.pdf y la fuente f2t3.docx
  FConn.ExecSQL('UPDATE tb_ssArchdigital SET urlraiz = ''/docs/'', path = ''\A.4.3\104\'' ' +
    'WHERE IdEstructura = ''A.4.3'' AND Codigodoc = ''F2T-EXP''');
  FOrigen.Objetos.AddOrSetValue('/docs/A.4.3/104/f2t1.pdf', TBytes.Create(1, 2, 3));
  FOrigen.Objetos.AddOrSetValue('/docs/A.4.3/104/f2t2.pdf', TBytes.Create(4, 5, 6, 7));
  FOrigen.Objetos.AddOrSetValue('/docs/A.4.3/104/f2t3.docx', TBytes.Create(8));
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc, IDExpediente) VALUES (:a, :b, :c, :d, :e, :f, :g, :h)',
    [EST, NODO, '074', EncodeDate(2026, 1, 31), '1', 'F2T-H4', 'prueba vista', ' F2T-EXP ']);
  Fichero('F2T-H1', '074', 1, 'h1.pdf', 50);
  Fichero('F2T-H2', '003', 1, 'h2.pdf', 60);   // 003: fuera del alcance de usr1
  Fichero('F2T-H3', '014001', 1, 'h3.pdf', 70);
  Fichero('F2T-H4', '074', 1, 'h4.pdf', 80);   // referencia con espacios
  Fichero('F2T-X', '014001', 1, 'x.pdf', 90);  // apunta a otro expediente
end;

procedure TPruebasExpedienteCompleto.Conectar(EsSql: Boolean);
begin
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  if EsSql then
  begin
    FConn.DriverName := 'MSSQL';
    FConn.Params.Values['Server'] := 'localhost';
    FConn.Params.Values['Database'] := GetEnvironmentVariable('ARCHIGENIO_TEST_DB');
    FConn.Params.Values['User_Name'] := 'geoconn';
    FConn.Params.Values['Password'] := 'geoconn';
    FConn.Params.Values['OSAuthent'] := 'No';
  end
  else
  begin
    FConn.DriverName := 'MSAcc';
    FConn.Params.Values['Database'] := GetEnvironmentVariable('ARCHIGENIO_TEST_MDB');
  end;
  FConn.Connected := True;
  CrearEsquemaAlcance(FConn, EsSql);
  FEsc := TEscenario.Create(FConn);
  FConn.StartTransaction;
  FEsc.Sembrar;
  if not EsSql then
  begin
    if Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_Serietree WHERE ' +
      'IdEstructura = ''A.4.3'' AND id = 104 AND codsubs = ''014001''')) = 0 then
      FConn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) ' +
        'VALUES (''A.4.3'', 104, ''014001'')');
    if Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_Serietree WHERE ' +
      'IdEstructura = ''A.4.3'' AND id = 104 AND codsubs = ''074''')) = 0 then
      FConn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) ' +
        'VALUES (''A.4.3'', 104, ''074'')');
  end;
  TSembradoVista.Sembrar(FConn);
  SembrarExtra;
end;

function Nombres(const L: TArray<TFicheroExpediente>): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(L) do
    Result := Result + '|' + L[I].Nombre;
  Result := Result + '|';
end;

function Resolver(Origen: IAlmacenFicheros): TResolverAlmacen;
begin
  Result := function(const F: TFicheroExpediente; out Clave: string): IAlmacenFicheros
    begin
      Clave := NormalizarRutaFtp(F.UrlRaiz + F.Path + F.Nombre);
      Result := Origen;
    end;
end;

procedure TPruebasExpedienteCompleto.SqlServer_Administrador_ListaPropioMasHijos;
var
  Al: TAlcanceUsuario;
  L: TArray<TFicheroExpediente>;
  N: string;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  Al := CargarAlcance(FConn, 'administrador', True);
  try
    L := ListarFicherosExpediente(FConn, Al, EST, NODO, 'F2T-EXP');
  finally
    Al.Free;
  end;
  N := Nombres(L);
  Assert.AreEqual(7, Length(L), N);
  Assert.IsTrue(N.Contains('|f2t1.pdf|') and N.Contains('|f2t3.docx|'), 'ficheros propios y fuente: ' + N);
  Assert.IsTrue(N.Contains('|h1.pdf|') and N.Contains('|h2.pdf|') and N.Contains('|h3.pdf|') and
    N.Contains('|h4.pdf|'), 'ficheros de los hijos: ' + N);
  Assert.IsFalse(N.Contains('|x.pdf|'), 'el de otro expediente no entra');
end;

procedure TPruebasExpedienteCompleto.SqlServer_UsuarioConAlcance_NoVeLosOcultos;
var
  Al: TAlcanceUsuario;
  L: TArray<TFicheroExpediente>;
  N: string;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  Al := CargarAlcance(FConn, 'prueba_alc_usr1', False);
  try
    L := ListarFicherosExpediente(FConn, Al, EST, NODO, 'F2T-EXP');
  finally
    Al.Free;
  end;
  N := Nombres(L);
  Assert.IsFalse(N.Contains('|h2.pdf|'), 'h2 esta en 003, fuera del alcance: ' + N);
  Assert.IsTrue(N.Contains('|h1.pdf|') and N.Contains('|h3.pdf|') and N.Contains('|h4.pdf|'), N);
  Assert.AreEqual(6, Length(L), N);
end;

procedure TPruebasExpedienteCompleto.SqlServer_OtroNodo_NoSeListan;
var
  Al: TAlcanceUsuario;
  L: TArray<TFicheroExpediente>;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  FConn.ExecSQL('INSERT INTO tb_tree (IdEstructura, id, etiqueta, padre, visible) ' +
    'VALUES (:a, :b, ''prueba vista'', 1, 1)', [EST, 99104]);
  FConn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) VALUES (:a, :b, :c)',
    [EST, 99104, '074']);
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc, IDExpediente) VALUES (:a, :b, :c, :d, :e, :f, :g, :h)',
    [EST, 99104, '074', EncodeDate(2026, 1, 31), '1', 'F2T-AJENO', 'prueba vista', 'F2T-EXP']);
  FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, idhijo, nombre, extnombre, fuente) VALUES (:a, :b, :c, :d, :e, :f, 1, ' +
    '''ajeno.pdf'', ''pdf'', ''N'')', [EST, 99104, '074', EncodeDate(2026, 1, 31), '1', 'F2T-AJENO']);
  Al := CargarAlcance(FConn, 'administrador', True);
  try
    L := ListarFicherosExpediente(FConn, Al, EST, NODO, 'F2T-EXP');
  finally
    Al.Free;
  end;
  Assert.IsFalse(Nombres(L).Contains('|ajeno.pdf|'), Nombres(L));
  Assert.AreEqual(7, Length(L));
end;

procedure TPruebasExpedienteCompleto.SqlServer_ExpedienteSinFicheros_ListaVacia;
var
  Al: TAlcanceUsuario;
  L: TArray<TFicheroExpediente>;
  R: TResumenExportacion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  Al := CargarAlcance(FConn, 'administrador', True);
  try
    L := ListarFicherosExpediente(FConn, Al, EST, NODO, 'F2T-NADA');
  finally
    Al.Free;
  end;
  Assert.AreEqual(0, Length(L));
  R := ExportarExpediente(L, Resolver(FOrigenI), FCarpeta, False, nil);
  Assert.AreEqual(0, R.Copiados);
  Assert.AreEqual(0, R.Fallidos);
end;

procedure TPruebasExpedienteCompleto.SqlServer_ExportaACarpeta_ConSubcarpetaPorDocumento;
var
  Al: TAlcanceUsuario;
  L: TArray<TFicheroExpediente>;
  R: TResumenExportacion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  Al := CargarAlcance(FConn, 'administrador', True);
  try
    L := ListarFicherosExpediente(FConn, Al, EST, NODO, 'F2T-EXP');
  finally
    Al.Free;
  end;
  R := ExportarExpediente(L, Resolver(FOrigenI), FCarpeta, False, nil);
  Assert.AreEqual(7, R.Copiados, R.Fallos);
  Assert.AreEqual(0, R.Fallidos);
  Assert.IsTrue(TFile.Exists(TPath.Combine(TPath.Combine(FCarpeta, 'F2T-EXP'), 'f2t1.pdf')));
  Assert.AreEqual(3, Length(TFile.ReadAllBytes(TPath.Combine(TPath.Combine(FCarpeta, 'F2T-EXP'), 'f2t1.pdf'))));
  Assert.IsTrue(TFile.Exists(TPath.Combine(TPath.Combine(FCarpeta, 'F2T-H1'), 'h1.pdf')));
  Assert.AreEqual(50, Length(TFile.ReadAllBytes(TPath.Combine(TPath.Combine(FCarpeta, 'F2T-H1'), 'h1.pdf'))));
end;

procedure TPruebasExpedienteCompleto.SqlServer_NombresRepetidos_NoSePisan;
var
  Al: TAlcanceUsuario;
  L: TArray<TFicheroExpediente>;
  R: TResumenExportacion;
  Dir: string;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  // dos ficheros con el mismo nombre en el mismo documento (rutas distintas en origen)
  FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, idhijo, nombre, extnombre, fuente, urlraiz, path) VALUES (:a, :b, :c, :d, ' +
    ':e, :f, 20, ''dup.pdf'', ''pdf'', ''N'', ''/docs/'', ''\A.4.3\104\uno\'')',
    [EST, NODO, '014001', EncodeDate(2026, 1, 31), '1', 'F2T-EXP']);
  FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, idhijo, nombre, extnombre, fuente, urlraiz, path) VALUES (:a, :b, :c, :d, ' +
    ':e, :f, 21, ''dup.pdf'', ''pdf'', ''N'', ''/docs/'', ''\A.4.3\104\dos\'')',
    [EST, NODO, '014001', EncodeDate(2026, 1, 31), '1', 'F2T-EXP']);
  FOrigen.Objetos.AddOrSetValue('/docs/A.4.3/104/uno/dup.pdf', TBytes.Create(1, 1));
  FOrigen.Objetos.AddOrSetValue('/docs/A.4.3/104/dos/dup.pdf', TBytes.Create(2, 2, 2));
  Al := CargarAlcance(FConn, 'administrador', True);
  try
    L := ListarFicherosExpediente(FConn, Al, EST, NODO, 'F2T-EXP');
  finally
    Al.Free;
  end;
  R := ExportarExpediente(L, Resolver(FOrigenI), FCarpeta, False, nil);
  Assert.AreEqual(0, R.Fallidos, R.Fallos);
  Dir := TPath.Combine(FCarpeta, 'F2T-EXP');
  Assert.IsTrue(TFile.Exists(TPath.Combine(Dir, 'dup.pdf')));
  Assert.IsTrue(TFile.Exists(TPath.Combine(Dir, 'dup (2).pdf')), 'el repetido lleva sufijo (2)');
end;

procedure TPruebasExpedienteCompleto.SqlServer_ExportaAZip_ContieneLoMismo;
var
  Al: TAlcanceUsuario;
  L: TArray<TFicheroExpediente>;
  R: TResumenExportacion;
  Z: TZipFile;
  Datos: TBytes;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  Al := CargarAlcance(FConn, 'administrador', True);
  try
    L := ListarFicherosExpediente(FConn, Al, EST, NODO, 'F2T-EXP');
  finally
    Al.Free;
  end;
  R := ExportarExpediente(L, Resolver(FOrigenI), FCarpeta + '.zip', True, nil);
  Assert.AreEqual(7, R.Copiados, R.Fallos);
  Z := TZipFile.Create;
  try
    Z.Open(FCarpeta + '.zip', zmRead);
    Assert.AreEqual(7, Z.FileCount);
    Z.Read('F2T-EXP/f2t2.pdf', Datos);
    Assert.AreEqual(4, Length(Datos));
    Z.Read('F2T-H3/h3.pdf', Datos);
    Assert.AreEqual(70, Length(Datos));
    Z.Close;
  finally
    Z.Free;
  end;
end;

procedure TPruebasExpedienteCompleto.SqlServer_UnFicheroFalla_ElRestoSeCopia;
var
  Al: TAlcanceUsuario;
  L: TArray<TFicheroExpediente>;
  R: TResumenExportacion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  FOrigen.Objetos.Remove('/docs/A.4.3/104/h3.pdf');
  Al := CargarAlcance(FConn, 'administrador', True);
  try
    L := ListarFicherosExpediente(FConn, Al, EST, NODO, 'F2T-EXP');
  finally
    Al.Free;
  end;
  R := ExportarExpediente(L, Resolver(FOrigenI), FCarpeta, False, nil);
  Assert.AreEqual(6, R.Copiados);
  Assert.AreEqual(1, R.Fallidos);
  Assert.IsTrue(R.Fallos.Contains('h3.pdf'), R.Fallos);
end;

procedure TPruebasExpedienteCompleto.Access_ListaYExporta;
var
  L: TArray<TFicheroExpediente>;
  R: TResumenExportacion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  L := ListarFicherosExpediente(FConn, nil, EST, NODO, 'F2T-EXP');
  Assert.AreEqual(7, Length(L), 'Access: ' + Nombres(L));
  R := ExportarExpediente(L, Resolver(FOrigenI), FCarpeta, False, nil);
  Assert.AreEqual(7, R.Copiados, R.Fallos);
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasExpedienteCompleto);

end.
