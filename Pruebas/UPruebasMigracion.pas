unit UPruebasMigracion;

{ Migracion de ficheros FTP -> S3 con dos almacenes en memoria (sin red) sobre
  tb_ssArchdigital. SQL Server: ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB
  (COPIA). Las filas se siembran dentro de una transaccion que se deshace. }

interface

uses
  System.Generics.Collections, System.SysUtils, FireDAC.Comp.Client, DUnitX.TestFramework,
  UAlmacenFicheros, UPruebasAlcanceDatos;

type
  { Almacen falso: objetos en un diccionario, con fallos configurables }
  TAlmacenMemoria = class(TInterfacedObject, IAlmacenFicheros)
  public
    Objetos: TDictionary<string, TBytes>;
    Subidas, Borrados, Descargas: Integer;
    FallarSubidaEn: string;
    TamanoMentiroso: Boolean;
    constructor Create;
    destructor Destroy; override;
    function Subir(const Local, Clave: string; Progreso: TProgresoEvento): TResultadoSubida;
    procedure Descargar(const Clave, Local: string; Progreso: TProgresoEvento);
    function Existe(const Clave: string; out Tamano: Int64): Boolean;
    procedure Borrar(const Clave: string);
    function UrlTemporal(const Clave: string; Segundos: Integer): string;
  end;

  [TestFixture]
  TPruebasMigracion = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    FOrigen, FDestino: TAlmacenMemoria;
    FOrigenI, FDestinoI: IAlmacenFicheros;
    procedure Conectar(EsSql: Boolean);
    procedure SembrarFicheros;
    function UrlRaizDe(Idhijo: Integer): string;
    function Migrador: TObject;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SqlServer_MigraTodasYDejaS3;
    [Test]
    procedure SqlServer_SegundaEjecucion_NoHaceNada;
    [Test]
    procedure SqlServer_CancelarYReanudar_NoDuplica;
    [Test]
    procedure SqlServer_FallaLaSubida_LaFilaQuedaIntacta;
    [Test]
    procedure SqlServer_TamanoDistinto_NoActualizaLaFila;
    [Test]
    procedure SqlServer_OrigenSinElFichero_SeInforma;
    [Test]
    procedure SqlServer_OrigenNuncaRecibeSubirNiBorrar;
    [Test]
    procedure SqlServer_FechaConHoraYMilisegundos_Migra;
    [Test]
    procedure Access_MigraTodasYEsIdempotente;
  end;

implementation

uses
  System.Classes, System.IOUtils, System.Hash, System.Variants, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, Data.DB, UEsquemaAlcance, UPruebasDocumentoVistaDatos,
  UMigracionFicheros;

const
  EST = 'A.4.3';
  NODO = 104;
  ID_S3 = 77;
  FILTRO = 'IdEstructura = ''A.4.3'' AND Codigodoc = ''F2T-EXP''';

{ TAlmacenMemoria }

constructor TAlmacenMemoria.Create;
begin
  inherited Create;
  Objetos := TDictionary<string, TBytes>.Create;
end;

destructor TAlmacenMemoria.Destroy;
begin
  Objetos.Free;
  inherited;
end;

function TAlmacenMemoria.Subir(const Local, Clave: string; Progreso: TProgresoEvento): TResultadoSubida;
var
  B: TBytes;
begin
  Inc(Subidas);
  if (FallarSubidaEn <> '') and (Clave = FallarSubidaEn) then
    raise EAlmacen.Create('fallo simulado de subida');
  B := TFile.ReadAllBytes(Local);
  Objetos.AddOrSetValue(Clave, B);
  Result.Tamano := Length(B);
  Result.Md5 := LowerCase(THashMD5.GetHashStringFromFile(Local));
end;

procedure TAlmacenMemoria.Descargar(const Clave, Local: string; Progreso: TProgresoEvento);
var
  B: TBytes;
begin
  Inc(Descargas);
  if not Objetos.TryGetValue(Clave, B) then
    raise EAlmacen.CreateFmt('no existe %s', [Clave]);
  TFile.WriteAllBytes(Local, B);
end;

function TAlmacenMemoria.Existe(const Clave: string; out Tamano: Int64): Boolean;
var
  B: TBytes;
begin
  Result := Objetos.TryGetValue(Clave, B);
  Tamano := Length(B);
  if Result and TamanoMentiroso then
    Inc(Tamano);
end;

procedure TAlmacenMemoria.Borrar(const Clave: string);
begin
  Inc(Borrados);
  Objetos.Remove(Clave);
end;

function TAlmacenMemoria.UrlTemporal(const Clave: string; Segundos: Integer): string;
begin
  raise EAlmacenNoSoportado.Create('no aplica');
end;

{ TPruebasMigracion }

procedure TPruebasMigracion.Preparar;
begin
  FConn := nil;
  FEsc := nil;
  FOrigen := TAlmacenMemoria.Create;
  FOrigenI := FOrigen;
  FDestino := TAlmacenMemoria.Create;
  FDestinoI := FDestino;
end;

procedure TPruebasMigracion.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
  FOrigenI := nil;
  FDestinoI := nil;
end;

procedure TPruebasMigracion.Conectar(EsSql: Boolean);
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
  SembrarFicheros;
end;

{ Deja el documento F2T-EXP con 5 ficheros en FTP (rutas con '\') y uno ya migrado:
    1 f2t1.pdf, 2 f2t2.pdf, 3 f2t3.docx (de la siembra comun), 4 'plano <n> 1.pdf'
    de 0 bytes, 5 'acta.pdf' ya en S3. }
procedure TPruebasMigracion.SembrarFicheros;

  procedure Contenido(const Clave: string; Tam: Integer);
  var
    B: TBytes;
    I: Integer;
  begin
    SetLength(B, Tam);
    for I := 0 to Tam - 1 do
      B[I] := Byte((Length(Clave) * 7 + I * 13) mod 251);
    FOrigen.Objetos.AddOrSetValue(Clave, B);
  end;

var
  I: Integer;
  Nombre, N4: string;
begin
  FConn.ExecSQL('UPDATE tb_ssArchdigital SET urlraiz = ''/docs/'', path = ''\A.4.3\104\'' ' +
    'WHERE IdEstructura = ''A.4.3'' AND Codigodoc = ''F2T-EXP''');
  N4 := 'plano ' + Char($F1) + ' 1.pdf';
  FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, ' +
    'Version, Codigodoc, idhijo, nombre, extnombre, fuente, urlraiz, path) ' +
    'VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l)',
    [EST, NODO, '014001', EncodeDate(2026, 1, 31), '1', 'F2T-EXP', 4, N4, 'pdf', 'N',
    '/docs/', '\A.4.3\104\']);
  FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, ' +
    'Version, Codigodoc, idhijo, nombre, extnombre, fuente, urlraiz, path) ' +
    'VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l)',
    [EST, NODO, '014001', EncodeDate(2026, 1, 31), '1', 'F2T-EXP', 5, 'acta.pdf', 'pdf', 'N',
    'S3://' + IntToStr(ID_S3) + '/', '\A.4.3\104\']);
  // El contenido de origen usa la ruta tal como la arma el sistema
  for I := 1 to 3 do
  begin
    Nombre := VarToStr(FConn.ExecSQLScalar('SELECT nombre FROM tb_ssArchdigital WHERE ' +
      'IdEstructura = ''A.4.3'' AND Codigodoc = ''F2T-EXP'' AND idhijo = ' + IntToStr(I)));
    Contenido('/docs/A.4.3/104/' + Nombre, 100 * I);
  end;
  Contenido('/docs/A.4.3/104/' + N4, 0);
end;

function TPruebasMigracion.UrlRaizDe(Idhijo: Integer): string;
begin
  Result := VarToStr(FConn.ExecSQLScalar('SELECT urlraiz FROM tb_ssArchdigital WHERE ' +
    'IdEstructura = ''A.4.3'' AND Codigodoc = ''F2T-EXP'' AND idhijo = ' + IntToStr(Idhijo)));
end;

function TPruebasMigracion.Migrador: TObject;
var
  M: TMigracionFicheros;
begin
  M := TMigracionFicheros.Create(FConn, FOrigenI, FDestinoI, ID_S3);
  M.Filtro := FILTRO;
  Result := M;
end;

procedure TPruebasMigracion.SqlServer_MigraTodasYDejaS3;
var
  M: TMigracionFicheros;
  R: TResumenMigracion;
  I: Integer;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  M := TMigracionFicheros(Migrador);
  try
    R := M.Migrar(nil, nil, nil);
  finally
    M.Free;
  end;
  Assert.AreEqual(4, R.Migrados, 'migrados');
  Assert.AreEqual(1, R.YaMigrados, 'ya migrados');
  Assert.AreEqual(0, R.Fallidos, 'fallidos');
  Assert.AreEqual(5, R.Total, 'total');
  for I := 1 to 4 do
    Assert.AreEqual('s3://77/', UrlRaizDe(I), 'urlraiz del fichero ' + IntToStr(I));
  Assert.IsTrue(FDestino.Objetos.ContainsKey('A.4.3/104/f2t1.pdf'), 'clave destino 1');
  Assert.IsTrue(FDestino.Objetos.ContainsKey('A.4.3/104/plano ' + Char($F1) + ' 1.pdf'), 'clave con ene y espacios');
  Assert.AreEqual(0, Length(FDestino.Objetos['A.4.3/104/plano ' + Char($F1) + ' 1.pdf']), 'fichero de 0 bytes');
  Assert.AreEqual(200, Length(FDestino.Objetos['A.4.3/104/f2t2.pdf']));
end;

procedure TPruebasMigracion.SqlServer_SegundaEjecucion_NoHaceNada;
var
  M: TMigracionFicheros;
  R: TResumenMigracion;
  Antes: Integer;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  M := TMigracionFicheros(Migrador);
  try
    M.Migrar(nil, nil, nil);
    Antes := FDestino.Subidas;
    R := M.Migrar(nil, nil, nil);
  finally
    M.Free;
  end;
  Assert.AreEqual(0, R.Migrados);
  Assert.AreEqual(5, R.YaMigrados);
  Assert.AreEqual(Antes, FDestino.Subidas, 'no debe subir nada otra vez');
end;

procedure TPruebasMigracion.SqlServer_CancelarYReanudar_NoDuplica;
var
  M: TMigracionFicheros;
  R1, R2: TResumenMigracion;
  Llamadas: Integer;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  M := TMigracionFicheros(Migrador);
  try
    Llamadas := 0;
    R1 := M.Migrar(nil, nil,
      function: Boolean
      begin
        Inc(Llamadas);
        Result := Llamadas > 2; // cancela tras dos ficheros
      end);
    Assert.AreEqual(2, R1.Migrados, 'migrados antes de cancelar');
    R2 := M.Migrar(nil, nil, nil);
  finally
    M.Free;
  end;
  Assert.AreEqual(2, R2.Migrados, 'migrados al reanudar');
  Assert.AreEqual(4, FDestino.Subidas, 'cada fichero sube una sola vez');
end;

procedure TPruebasMigracion.SqlServer_FallaLaSubida_LaFilaQuedaIntacta;
var
  M: TMigracionFicheros;
  R: TResumenMigracion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  FDestino.FallarSubidaEn := 'A.4.3/104/f2t2.pdf';
  M := TMigracionFicheros(Migrador);
  try
    R := M.Migrar(nil, nil, nil);
    Assert.AreEqual(3, R.Migrados);
    Assert.AreEqual(1, R.Fallidos);
    Assert.IsTrue(M.InformeFallos.Contains('f2t2.pdf'), M.InformeFallos);
  finally
    M.Free;
  end;
  Assert.AreEqual('/docs/', UrlRaizDe(2), 'la fila fallida conserva su urlraiz');
  Assert.AreEqual('s3://77/', UrlRaizDe(1));
end;

procedure TPruebasMigracion.SqlServer_TamanoDistinto_NoActualizaLaFila;
var
  M: TMigracionFicheros;
  R: TResumenMigracion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  FDestino.TamanoMentiroso := True;
  M := TMigracionFicheros(Migrador);
  try
    R := M.Migrar(nil, nil, nil);
  finally
    M.Free;
  end;
  Assert.AreEqual(0, R.Migrados);
  Assert.AreEqual(4, R.Fallidos);
  Assert.AreEqual('/docs/', UrlRaizDe(1));
end;

procedure TPruebasMigracion.SqlServer_OrigenSinElFichero_SeInforma;
var
  M: TMigracionFicheros;
  R: TResumenMigracion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  FOrigen.Objetos.Remove('/docs/A.4.3/104/f2t3.docx');
  M := TMigracionFicheros(Migrador);
  try
    R := M.Migrar(nil, nil, nil);
    Assert.AreEqual(3, R.Migrados);
    Assert.AreEqual(1, R.Fallidos);
    Assert.IsTrue(M.InformeFallos.Contains('f2t3.docx'), M.InformeFallos);
  finally
    M.Free;
  end;
  Assert.AreEqual('/docs/', UrlRaizDe(3));
end;

procedure TPruebasMigracion.SqlServer_OrigenNuncaRecibeSubirNiBorrar;
var
  M: TMigracionFicheros;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  M := TMigracionFicheros(Migrador);
  try
    M.Migrar(nil, nil, nil);
  finally
    M.Free;
  end;
  Assert.AreEqual(0, FOrigen.Subidas);
  Assert.AreEqual(0, FOrigen.Borrados);
  Assert.AreEqual(0, FDestino.Borrados);
end;

procedure TPruebasMigracion.SqlServer_FechaConHoraYMilisegundos_Migra;
var
  M: TMigracionFicheros;
  R: TResumenMigracion;
  F: TDateTime;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  // Documento con fecha-hora real (no medianoche) y milisegundos
  F := EncodeDate(2026, 2, 3) + EncodeTime(13, 45, 27, 123);
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc) VALUES (:a, :b, :c, :d, :e, :f, :g)',
    [EST, NODO, '014001', F, '1', 'F2T-EXP', 'prueba hora']);
  FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, ' +
    'Version, Codigodoc, idhijo, nombre, extnombre, fuente, urlraiz, path) ' +
    'VALUES (:a, :b, :c, :d, :e, :f, 30, ''hora.pdf'', ''pdf'', ''N'', ''/docs/'', ''\A.4.3\104\'')',
    [EST, NODO, '014001', F, '1', 'F2T-EXP']);
  FOrigen.Objetos.AddOrSetValue('/docs/A.4.3/104/hora.pdf', TBytes.Create(1, 2, 3));
  M := TMigracionFicheros(Migrador);
  try
    R := M.Migrar(nil, nil, nil);
    Assert.AreEqual(0, R.Fallidos, M.InformeFallos);
  finally
    M.Free;
  end;
  Assert.AreEqual('s3://77/', VarToStr(FConn.ExecSQLScalar(
    'SELECT urlraiz FROM tb_ssArchdigital WHERE idhijo = 30 AND Codigodoc = ''F2T-EXP''')));
end;

procedure TPruebasMigracion.Access_MigraTodasYEsIdempotente;
var
  M: TMigracionFicheros;
  R: TResumenMigracion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  M := TMigracionFicheros(Migrador);
  try
    R := M.Migrar(nil, nil, nil);
    Assert.AreEqual(4, R.Migrados, 'Access: migrados');
    Assert.AreEqual('s3://77/', UrlRaizDe(1));
    R := M.Migrar(nil, nil, nil);
    Assert.AreEqual(0, R.Migrados, 'Access: segunda pasada');
    Assert.AreEqual(5, R.YaMigrados);
  finally
    M.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasMigracion);

end.
