unit UPruebasEsquemaProcesos;

{ Esquema prc_* de los procesos archivisticos. Las pruebas de sentencias son
  puras (no necesitan base). Las de base se omiten sin ARCHIGENIO_TEST_DB. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasEsquemaProcesosSql = class
  private
    function Todo(EsSqlServer: Boolean): string;
    function Contar(const Texto, Fragmento: string): Integer;
  public
    [Test]
    procedure SqlServer_TablasConGuardaDeExistencia;
    [Test]
    procedure Access_SinIdentityNiObjectId;
    [Test]
    procedure Access_UsaCounterEnLasClavesAutonumericas;
    [Test]
    procedure Proceso_TieneClaveUnicaTipoAnioConsecutivo;
    [Test]
    procedure Unidad_BorraseConSuProceso;
    [Test]
    procedure Transferencia_TieneColumnasDeRecepcionYUbicacion;
    [Test]
    procedure TieneLosCincoIndices;
    [Test]
    procedure SqlServer_IndicesConGuarda;
    [Test]
    procedure Bloqueo_ClavePrimariaEsElDocumento;
    [Test]
    procedure Prestamo_TablaConClaveYCascada;
    [Test]
    procedure Prestamo_IndiceDeLimite;
    [Test]
    procedure Transferencia_TablaConCascadaYDatosDeEntrega;
    [Test]
    procedure Cronograma_UnoPorNodoYAnio;
    [Test]
    procedure Caja_ClaveEsProcesoYNumero;
    [Test]
    procedure Verificacion_ClaveEsProcesoYCodigo;
    [Test]
    procedure Unidad_IndiceDeCaja;
    [Test]
    procedure TransferenciaF3_ColumnasDeDestinoYRegistroDeEntrada;
    [Test]
    procedure CajaF3_ColumnasDeUbicacionYEstado;
    [Test]
    procedure Incidencia_TablaConCascadaEIndice;
    [Test]
    procedure Depuracion_TablaConClaveYCascada;
    [Test]
    procedure Testigo_TablaConClaveCascadaEIndice;
  end;

  [TestFixture]
  TPruebasEsquemaProcesosBD = class
  private
    FConn: TFDConnection;
    function Escalar(const Sql: string): Variant;
    function TablaExiste(const Nombre: string): Boolean;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure TablasExisten;
    [Test]
    procedure EsIdempotente;
    [Test]
    procedure NumeroUnicoPorTipoAnio;
    [Test]
    procedure BorrarProcesoBorraUnidades;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB,
  UEsquemaProcesos;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  TABLAS: array[0..12] of string = ('prc_proceso', 'prc_unidad', 'prc_evento',
    'prc_autorizacion', 'prc_bloqueo', 'prc_prestamo', 'prc_transferencia',
    'prc_cronograma', 'prc_caja', 'prc_verificacion', 'prc_incidencia', 'prc_depuracion', 'prc_testigo');

{ TPruebasEsquemaProcesosSql }

function TPruebasEsquemaProcesosSql.Todo(EsSqlServer: Boolean): string;
var
  S: string;
begin
  Result := '';
  for S in SentenciasEsquemaProcesos(EsSqlServer) do
    Result := Result + S + #10;
end;

function TPruebasEsquemaProcesosSql.Contar(const Texto, Fragmento: string): Integer;
var
  P: Integer;
begin
  Result := 0;
  P := Pos(Fragmento, Texto);
  while P > 0 do
  begin
    Inc(Result);
    P := Pos(Fragmento, Texto, P + Length(Fragmento));
  end;
end;

procedure TPruebasEsquemaProcesosSql.SqlServer_TablasConGuardaDeExistencia;
var
  T: string;
begin
  for T in TABLAS do
    Assert.IsTrue(Pos('IF OBJECT_ID(''dbo.' + T + ''', ''U'') IS NULL CREATE TABLE ' +
      T + ' (', Todo(True)) > 0, 'Falta la tabla o su guarda: ' + T);
end;

procedure TPruebasEsquemaProcesosSql.Access_SinIdentityNiObjectId;
begin
  Assert.AreEqual(0, Contar(Todo(False), 'IDENTITY'));
  Assert.AreEqual(0, Contar(Todo(False), 'OBJECT_ID'));
  Assert.AreEqual(0, Contar(Todo(False), 'sys.indexes'));
end;

procedure TPruebasEsquemaProcesosSql.Access_UsaCounterEnLasClavesAutonumericas;
begin
  Assert.AreEqual(5, Contar(Todo(False), 'COUNTER'), 'IdProceso, IdEvento, IdCronograma, IdIncidencia e IdTestigo');
  Assert.AreEqual(5, Contar(Todo(True), 'IDENTITY(1,1)'));
end;

procedure TPruebasEsquemaProcesosSql.Proceso_TieneClaveUnicaTipoAnioConsecutivo;
begin
  Assert.IsTrue(Pos('UNIQUE (Tipo, Anio, Consecutivo)', Todo(True)) > 0);
  Assert.IsTrue(Pos('UNIQUE (Tipo, Anio, Consecutivo)', Todo(False)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Transferencia_TieneColumnasDeRecepcionYUbicacion;
var
  C: string;
begin
  for C in TArray<string>.Create('FRecepcion', 'RecibidoPor', 'Ubicacion') do
  begin
    Assert.IsTrue(Pos('ALTER TABLE prc_transferencia ADD ' + C, Todo(True)) > 0, 'SQL Server ' + C);
    Assert.IsTrue(Pos('ALTER TABLE prc_transferencia ADD COLUMN ' + C, Todo(False)) > 0, 'Access ' + C);
  end;
  // en SQL Server solo se agrega si falta
  Assert.IsTrue(Pos('COL_LENGTH(''prc_transferencia'', ''FRecepcion'') IS NULL', Todo(True)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Unidad_BorraseConSuProceso;
begin
  Assert.IsTrue(Pos('REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE', Todo(True)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.TieneLosCincoIndices;
begin
  Assert.AreEqual(7, Contar(Todo(True), 'CREATE INDEX'));
  Assert.AreEqual(7, Contar(Todo(False), 'CREATE INDEX'));
end;

procedure TPruebasEsquemaProcesosSql.SqlServer_IndicesConGuarda;
begin
  Assert.AreEqual(7, Contar(Todo(True), 'IF NOT EXISTS (SELECT 1 FROM sys.indexes'));
end;

procedure TPruebasEsquemaProcesosSql.Bloqueo_ClavePrimariaEsElDocumento;
begin
  // Un documento solo puede tener una fila de bloqueo: lo hace cumplir la base.
  Assert.IsTrue(Pos('CONSTRAINT PK_prc_bloqueo PRIMARY KEY (IdEstructura, id, codsubs, Codigodoc, fecha, version)',
    Todo(True)) > 0);
  Assert.IsTrue(Pos('CONSTRAINT PK_prc_bloqueo PRIMARY KEY (IdEstructura, id, codsubs, Codigodoc, fecha, version)',
    Todo(False)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Prestamo_TablaConClaveYCascada;
var
  Sql: string;
begin
  Sql := Todo(True);
  Assert.IsTrue(Pos('IF OBJECT_ID(''dbo.prc_prestamo'', ''U'') IS NULL CREATE TABLE prc_prestamo (', Sql) > 0);
  Assert.IsTrue(Pos('CONSTRAINT PK_prc_prestamo PRIMARY KEY (IdProceso)', Sql) > 0);
  Assert.IsTrue(Pos('FOREIGN KEY (IdProceso) REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE', Sql) > 0);
  Assert.IsTrue(Pos('Solicitante VARCHAR(150) NOT NULL', Sql) > 0);
  Assert.IsTrue(Pos('TipoUsuario VARCHAR(1) NOT NULL', Sql) > 0);
  Assert.IsTrue(Pos('IdPrestamoViejo VARCHAR(12) NULL', Sql) > 0);
  Assert.IsTrue(Pos('CREATE TABLE prc_prestamo (', Todo(False)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Prestamo_IndiceDeLimite;
begin
  Assert.IsTrue(Pos('CREATE INDEX IX_prc_prestamo_limite ON prc_prestamo (FLimite)', Todo(True)) > 0);
  Assert.IsTrue(Pos('CREATE INDEX IX_prc_prestamo_limite ON prc_prestamo (FLimite)', Todo(False)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Transferencia_TablaConCascadaYDatosDeEntrega;
var
  Sql: string;
begin
  Sql := Todo(True);
  Assert.IsTrue(Pos('IF OBJECT_ID(''dbo.prc_transferencia'', ''U'') IS NULL CREATE TABLE prc_transferencia (', Sql) > 0);
  Assert.IsTrue(Pos('CONSTRAINT PK_prc_transferencia PRIMARY KEY (IdProceso)', Sql) > 0);
  Assert.IsTrue(Pos('EntregadoPor VARCHAR(100) NULL', Sql) > 0);
  Assert.IsTrue(Pos('FOREIGN KEY (IdProceso) REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE', Sql) > 0);
  Assert.IsTrue(Pos('CREATE TABLE prc_transferencia (', Todo(False)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Cronograma_UnoPorNodoYAnio;
begin
  Assert.IsTrue(Pos('UNIQUE (Anio, IdEstructura, IdNodo)', Todo(True)) > 0);
  Assert.IsTrue(Pos('UNIQUE (Anio, IdEstructura, IdNodo)', Todo(False)) > 0);
  Assert.IsTrue(Pos('FOREIGN KEY (IdEstructura, IdNodo) REFERENCES tb_tree(IdEstructura, id)',
    Todo(True)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Caja_ClaveEsProcesoYNumero;
begin
  Assert.IsTrue(Pos('CONSTRAINT PK_prc_caja PRIMARY KEY (IdProceso, Caja)', Todo(True)) > 0);
  Assert.IsTrue(Pos('CONSTRAINT PK_prc_caja PRIMARY KEY (IdProceso, Caja)', Todo(False)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Verificacion_ClaveEsProcesoYCodigo;
begin
  Assert.IsTrue(Pos('CONSTRAINT PK_prc_verificacion PRIMARY KEY (IdProceso, Codigo)', Todo(True)) > 0);
  Assert.IsTrue(Pos('CONSTRAINT PK_prc_verificacion PRIMARY KEY (IdProceso, Codigo)', Todo(False)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Unidad_IndiceDeCaja;
begin
  Assert.IsTrue(Pos('CREATE INDEX IX_prc_unidad_caja ON prc_unidad (IdProceso, Caja)', Todo(True)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.TransferenciaF3_ColumnasDeDestinoYRegistroDeEntrada;
begin
  Assert.IsTrue(Pos('ALTER TABLE prc_transferencia ADD IdArchivoDestino SMALLINT NULL', Todo(True)) > 0);
  Assert.IsTrue(Pos('ALTER TABLE prc_transferencia ADD NumRegistroEntrada VARCHAR(30) NULL', Todo(True)) > 0);
  Assert.IsTrue(Pos('ALTER TABLE prc_transferencia ADD COLUMN IdArchivoDestino SMALLINT NULL', Todo(False)) > 0);
  Assert.IsTrue(Pos('COL_LENGTH(''prc_transferencia'', ''NumRegistroEntrada'') IS NULL', Todo(True)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.CajaF3_ColumnasDeUbicacionYEstado;
var
  C: string;
begin
  for C in TArray<string>.Create('Deposito VARCHAR(255) NULL', 'Gaveta VARCHAR(20) NULL',
    'Posicion VARCHAR(10) NULL', 'Estado VARCHAR(1) NULL', 'Conservacion VARCHAR(255) NULL') do
  begin
    Assert.IsTrue(Pos('ALTER TABLE prc_caja ADD ' + C, Todo(True)) > 0, 'SQL Server ' + C);
    Assert.IsTrue(Pos('ALTER TABLE prc_caja ADD COLUMN ' + C, Todo(False)) > 0, 'Access ' + C);
  end;
end;

procedure TPruebasEsquemaProcesosSql.Depuracion_TablaConClaveYCascada;
var
  C: string;
begin
  for C in TArray<string>.Create('CREATE TABLE prc_depuracion (',
    'CONSTRAINT PK_prc_depuracion PRIMARY KEY (IdProceso)',
    'Lugar VARCHAR(255) NULL', 'Via VARCHAR(1) NULL', 'FPrevista DATETIME NULL',
    'FEjecucion DATETIME NULL', 'MuestraDesc VARCHAR(255) NULL',
    'MuestraDonde VARCHAR(255) NULL') do
  begin
    Assert.IsTrue(Pos(C, Todo(True)) > 0, 'SQL Server ' + C);
    Assert.IsTrue(Pos(C, Todo(False)) > 0, 'Access ' + C);
  end;
  Assert.IsTrue(Pos('CONSTRAINT FK_prc_depuracion_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE', Todo(False)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Testigo_TablaConClaveCascadaEIndice;
var
  C: string;
begin
  for C in TArray<string>.Create('CREATE TABLE prc_testigo (',
    'CONSTRAINT PK_prc_testigo PRIMARY KEY (IdTestigo)', 'Nombre VARCHAR(100) NOT NULL',
    'Cargo VARCHAR(100) NULL', 'Origen VARCHAR(1) NOT NULL') do
  begin
    Assert.IsTrue(Pos(C, Todo(True)) > 0, 'SQL Server ' + C);
    Assert.IsTrue(Pos(C, Todo(False)) > 0, 'Access ' + C);
  end;
  Assert.IsTrue(Pos('CONSTRAINT FK_prc_testigo_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE', Todo(True)) > 0);
  Assert.IsTrue(Pos('CREATE INDEX IX_prc_testigo_proceso ON prc_testigo (IdProceso)', Todo(True)) > 0);
end;

procedure TPruebasEsquemaProcesosSql.Incidencia_TablaConCascadaEIndice;
begin
  Assert.IsTrue(Pos('CREATE TABLE prc_incidencia (', Todo(True)) > 0);
  Assert.IsTrue(Pos('CONSTRAINT PK_prc_incidencia PRIMARY KEY (IdIncidencia)', Todo(True)) > 0);
  Assert.IsTrue(Pos('CONSTRAINT FK_prc_incidencia_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE', Todo(False)) > 0);
  Assert.IsTrue(Pos('CREATE INDEX IX_prc_incidencia_proceso ON prc_incidencia (IdProceso)', Todo(True)) > 0);
end;

{ TPruebasEsquemaProcesosBD }

procedure TPruebasEsquemaProcesosBD.Preparar;
var
  Nombre: string;
begin
  FConn := nil;
  Nombre := GetEnvironmentVariable(VAR_BD);
  if Nombre = '' then
    Exit;
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := Nombre;
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
end;

procedure TPruebasEsquemaProcesosBD.Limpiar;
begin
  FreeAndNil(FConn);
end;

function TPruebasEsquemaProcesosBD.Escalar(const Sql: string): Variant;
begin
  Result := FConn.ExecSQLScalar(Sql);
end;

function TPruebasEsquemaProcesosBD.TablaExiste(const Nombre: string): Boolean;
begin
  Result := Integer(Escalar('SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES ' +
    'WHERE TABLE_NAME = ' + QuotedStr(Nombre))) > 0;
end;

procedure TPruebasEsquemaProcesosBD.TablasExisten;
var
  T: string;
begin
  if FConn = nil then
  begin
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
    Exit;
  end;
  CrearEsquemaProcesos(FConn, True);
  for T in TABLAS do
    Assert.IsTrue(TablaExiste(T), 'Falta la tabla ' + T);
end;

procedure TPruebasEsquemaProcesosBD.EsIdempotente;
var
  T: string;
  Antes, Despues: Integer;
begin
  if FConn = nil then
  begin
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
    Exit;
  end;
  CrearEsquemaProcesos(FConn, True);
  Antes := 0;
  for T in TABLAS do
    Antes := Antes + Integer(Escalar('SELECT COUNT(*) FROM ' + T));
  CrearEsquemaProcesos(FConn, True);
  Despues := 0;
  for T in TABLAS do
    Despues := Despues + Integer(Escalar('SELECT COUNT(*) FROM ' + T));
  Assert.AreEqual(Antes, Despues);
end;

procedure TPruebasEsquemaProcesosBD.NumeroUnicoPorTipoAnio;
var
  IdEstr: string;
  IdNodo: Integer;
  Lanzo: Boolean;
  Sql: string;
begin
  if FConn = nil then
  begin
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
    Exit;
  end;
  CrearEsquemaProcesos(FConn, True);
  IdEstr := VarToStr(Escalar('SELECT TOP 1 IdEstructura FROM tb_tree ORDER BY IdEstructura, id'));
  IdNodo := Integer(Escalar('SELECT TOP 1 id FROM tb_tree ORDER BY IdEstructura, id'));
  Sql := 'INSERT INTO prc_proceso (Tipo, Anio, Consecutivo, Numero, Estado, Paso, ' +
    'IdEstructura, IdNodo) VALUES (''P'', 1999, 1, ''1999-0001'', ''C'', 1, ' +
    QuotedStr(IdEstr) + ', ' + IntToStr(IdNodo) + ')';
  try
    FConn.ExecSQL(Sql);
    Lanzo := False;
    try
      FConn.ExecSQL(Sql);
    except
      on EFDDBEngineException do
        Lanzo := True;
    end;
    Assert.IsTrue(Lanzo, 'La clave (Tipo, Anio, Consecutivo) debe ser unica');
  finally
    FConn.ExecSQL('DELETE FROM prc_proceso WHERE Anio = 1999');
  end;
end;

procedure TPruebasEsquemaProcesosBD.BorrarProcesoBorraUnidades;
var
  IdEstr: string;
  IdNodo, IdProc: Integer;
begin
  if FConn = nil then
  begin
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
    Exit;
  end;
  CrearEsquemaProcesos(FConn, True);
  IdEstr := VarToStr(Escalar('SELECT TOP 1 IdEstructura FROM tb_tree ORDER BY IdEstructura, id'));
  IdNodo := Integer(Escalar('SELECT TOP 1 id FROM tb_tree ORDER BY IdEstructura, id'));
  FConn.ExecSQL('INSERT INTO prc_proceso (Tipo, Anio, Consecutivo, Numero, Estado, Paso, ' +
    'IdEstructura, IdNodo) VALUES (''P'', 1998, 1, ''1998-0001'', ''C'', 1, ' +
    QuotedStr(IdEstr) + ', ' + IntToStr(IdNodo) + ')');
  try
    IdProc := Integer(Escalar('SELECT IdProceso FROM prc_proceso WHERE Anio = 1998'));
    FConn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, Codigodoc, ' +
      'fecha, version, Activa) VALUES (' + IntToStr(IdProc) + ', ' + QuotedStr(IdEstr) +
      ', ' + IntToStr(IdNodo) + ', ''S'', ''X'', ''2020-01-01'', ''1'', 1)');
    FConn.ExecSQL('DELETE FROM prc_proceso WHERE IdProceso = ' + IntToStr(IdProc));
    Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad WHERE IdProceso = ' +
      IntToStr(IdProc))));
  finally
    FConn.ExecSQL('DELETE FROM prc_proceso WHERE Anio = 1998');
  end;
end;

end.
