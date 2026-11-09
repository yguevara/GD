unit UPruebasTrazabilidadDatos;

{ SQL Server: ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB (COPIA). Se omiten
  sin su variable.
  - TPruebasTrazabilidadDatos: escritura de eventos; filas propias con
    codigodoc F5T-*, borradas al final.
  - TPruebasLineaTiempoSql: lectura de la linea de tiempo con los datos de
    TEscenario y TSembradoVista dentro de una transaccion que se deshace. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UDocumentoVista, UPruebasAlcanceDatos,
  UTrazabilidad;

type
  [TestFixture]
  TPruebasTrazabilidadDatos = class
  private
    FConn: TFDConnection;
    procedure Conectar(EsSql: Boolean);
    function Cuenta(const Sql: string): Integer;
    function ClavePrueba(const Cod: string): TClaveDocumento;
    procedure SembrarDocumento(const C: TClaveDocumento);
    procedure QuitarColumnasF5;
    procedure ProbarRegistro;
  public
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SqlServer_RegistrarEvento_GuardaClaveYFecha;
    [Test]
    procedure Access_RegistrarEvento_GuardaClaveYFecha;
    [Test]
    procedure Access_RegistrarEvento_GuardaUsuarioPcEIpDados;
    [Test]
    procedure Access_SinColumnasF5_GuardaLaFilaDeSiempre;
    [Test]
    procedure Access_LineaTiempo_MaximoLimitaYAvisa;
    [Test]
    procedure Access_LineaTiempo_SinColumnasF5_DiceElMotivo;
  end;

  [TestFixture]
  TPruebasLineaTiempoSql = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    FSeq: Integer;
    procedure Log(const Cod, Est: string; Id: Integer; Accion: Integer;
      const Fecha: TDateTime);
    function Linea(const Clave: TClaveDocumento; const Usuario: string;
      EsAdmin: Boolean; Maximo: Integer; out Mas: Boolean): TArray<TEventoDoc>;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Log_TresEventos_DescendenteConTipos;
    [Test]
    procedure Log_OtroNodoOIdDistintoOSinFecha_NoCuenta;
    [Test]
    procedure Prestamo_ConYSinDevolucion;
    [Test]
    procedure Alcance_FueraDeAlcance_Vacio;
    [Test]
    procedure Alcance_DentroDeAlcance_VeEventos;
    [Test]
    procedure Maximo_LimitaYAvisa;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB,
  UAlcance, UAlcanceDatos, UEsquemaAlcance, UEsquemaTrazabilidad,
  UPruebasDocumentoVistaDatos, UTrazabilidadDatos;

const
  EST_T = 'A.4.3';
  NODO_T = 104;

procedure TPruebasTrazabilidadDatos.Conectar(EsSql: Boolean);
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
  CrearEsquemaTrazabilidad(FConn, EsSql);
end;

procedure TPruebasTrazabilidadDatos.Limpiar;
begin
  if FConn <> nil then
  try
    // devolver las columnas que una prueba haya quitado y borrar lo sembrado
    CrearEsquemaTrazabilidad(FConn, FConn.DriverName = 'MSSQL');
    FConn.ExecSQL('DELETE FROM tb_log WHERE codigodoc LIKE ''F5T-%'' OR msg LIKE ''%F5T-%''');
    FConn.ExecSQL('DELETE FROM tb_SeriesDatos WHERE Codigodoc LIKE ''F5T-%''');
  except
  end;
  FreeAndNil(FConn);
end;

function TPruebasTrazabilidadDatos.Cuenta(const Sql: string): Integer;
begin
  Result := FConn.ExecSQLScalar(Sql);
end;

function TPruebasTrazabilidadDatos.ClavePrueba(const Cod: string): TClaveDocumento;
begin
  Result.IdEstructura := 'A.4.3';
  Result.Id := 104;
  Result.CodSubs := '074';
  Result.Fecha := EncodeDate(2026, 1, 31);
  Result.Version := '1';
  Result.Codigodoc := Cod;
end;

procedure TPruebasTrazabilidadDatos.SembrarDocumento(const C: TClaveDocumento);
begin
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, ' +
    'Codigodoc, fecha, version, titulodoc) VALUES (:e, :i, :c, :d, :f, :v, ''t'')',
    [C.IdEstructura, C.Id, C.CodSubs, C.Codigodoc, C.Fecha, C.Version]);
end;

procedure TPruebasTrazabilidadDatos.QuitarColumnasF5;
const
  COLS: array[0..4] of string = ('codigodoc', 'iddoc', 'codsubsdoc',
    'versiondoc', 'fecha_evento');
var
  I: Integer;
begin
  try
    FConn.ExecSQL('DROP INDEX IX_tb_log_codigodoc ON tb_log');
  except
  end;
  for I := 0 to High(COLS) do
    FConn.ExecSQL('ALTER TABLE tb_log DROP COLUMN ' + COLS[I]);
end;

procedure TPruebasTrazabilidadDatos.ProbarRegistro;
var
  C: TClaveDocumento;
begin
  C.IdEstructura := 'A.4.3';
  C.Id := 104;
  C.CodSubs := '074';
  C.Fecha := EncodeDate(2026, 1, 31);
  C.Version := '1';
  C.Codigodoc := 'F5T-001';
  RegistrarEventoDoc(FConn, C, 5, 'alta de prueba F5T-001', 'usr1', 'Rol', 'S1');
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_log WHERE codigodoc = ''F5T-001'' ' +
    'AND iddoc = 104 AND codsubsdoc = ''074'' AND versiondoc = ''1'' ' +
    'AND accion = 5 AND IdEstructura = ''A.4.3'' AND fecha_evento IS NOT NULL'));
end;

procedure TPruebasTrazabilidadDatos.SqlServer_RegistrarEvento_GuardaClaveYFecha;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  ProbarRegistro;
end;

procedure TPruebasTrazabilidadDatos.Access_RegistrarEvento_GuardaClaveYFecha;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  ProbarRegistro;
end;

{ TPruebasLineaTiempoSql }

procedure TPruebasLineaTiempoSql.Preparar;
var
  NombreBD: string;
begin
  FConn := nil;
  FEsc := nil;
  FSeq := 0;
  NombreBD := GetEnvironmentVariable('ARCHIGENIO_TEST_DB');
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
  CrearEsquemaTrazabilidad(FConn, True);
  FEsc := TEscenario.Create(FConn);
  FConn.StartTransaction;
  FEsc.Sembrar;
  TSembradoVista.Sembrar(FConn);
end;

procedure TPruebasLineaTiempoSql.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
end;

procedure TPruebasLineaTiempoSql.Log(const Cod, Est: string; Id: Integer;
  Accion: Integer; const Fecha: TDateTime);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'INSERT INTO tb_log (usuariopc, pc, fecha, ip, usuario_sistema, ' +
      'rol, msg, serie, subserie, IdEstructura, accion, codigodoc, iddoc, ' +
      'codsubsdoc, versiondoc, fecha_evento) VALUES (''u'', ''pc'', :ft, '''', ' +
      '''usr1'', ''r'', ''msg'', ''s'', ''014001'', :est, :acc, :cod, :id, ' +
      ':cs, ''1'', :fe)';
    Inc(FSeq);
    Q.ParamByName('ft').AsString := 'f5t-' + IntToStr(FSeq);
    Q.ParamByName('est').AsString := Est;
    Q.ParamByName('acc').AsInteger := Accion;
    Q.ParamByName('cod').AsString := Cod;
    Q.ParamByName('id').AsInteger := Id;
    Q.ParamByName('cs').AsString := '014001';
    if Fecha = 0 then
    begin
      // sin fecha_evento (evento anterior a la F5)
      Q.ParamByName('fe').DataType := ftDateTime;
      Q.ParamByName('fe').Clear;
    end
    else
      Q.ParamByName('fe').AsDateTime := Fecha;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function TPruebasLineaTiempoSql.Linea(const Clave: TClaveDocumento;
  const Usuario: string; EsAdmin: Boolean; Maximo: Integer;
  out Mas: Boolean): TArray<TEventoDoc>;
var
  Al: TAlcanceUsuario;
  Motivo: string;
begin
  Al := CargarAlcance(FConn, Usuario, EsAdmin);
  try
    Result := CargarLineaTiempo(FConn, Al, Clave, Maximo, Mas, Motivo);
    Assert.AreEqual('', Motivo);
  finally
    Al.Free;
  end;
end;

procedure TPruebasLineaTiempoSql.Log_TresEventos_DescendenteConTipos;
var
  L: TArray<TEventoDoc>;
  Mas: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Log('F2T-EXP', EST_T, NODO_T, 5, EncodeDate(2026, 3, 1));
  Log('F2T-EXP', EST_T, NODO_T, 3, EncodeDate(2026, 3, 2));
  Log('F2T-EXP', EST_T, NODO_T, 14, EncodeDate(2026, 3, 3));
  L := Linea(TSembradoVista.Clave('F2T-EXP', '014001'), 'administrador', True, 50, Mas);
  Assert.AreEqual(3, Length(L));
  Assert.IsFalse(Mas);
  Assert.AreEqual(Ord(teConsultado), Ord(L[0].Tipo));
  Assert.AreEqual(Ord(teModificado), Ord(L[1].Tipo));
  Assert.AreEqual(Ord(teCreado), Ord(L[2].Tipo));
end;

procedure TPruebasLineaTiempoSql.Log_OtroNodoOIdDistintoOSinFecha_NoCuenta;
var
  L: TArray<TEventoDoc>;
  Mas: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Log('F2T-EXP', 'OTRO.NODO', NODO_T, 5, EncodeDate(2026, 3, 1));
  Log('F2T-EXP', EST_T, NODO_T + 1, 5, EncodeDate(2026, 3, 1));
  Log('F2T-EXP', EST_T, NODO_T, 5, 0);
  Log('F2T-EXP', EST_T, NODO_T, 3, EncodeDate(2026, 3, 2));
  L := Linea(TSembradoVista.Clave('F2T-EXP', '014001'), 'administrador', True, 50, Mas);
  Assert.AreEqual(1, Length(L));
  Assert.AreEqual(Ord(teModificado), Ord(L[0].Tipo));
end;

procedure TPruebasLineaTiempoSql.Prestamo_ConYSinDevolucion;
var
  L: TArray<TEventoDoc>;
  Mas: Boolean;
  Q: TFDQuery;

  procedure Prestamo(const IdP: string; Devuelto: Boolean);
  begin
    Q.SQL.Text := 'INSERT INTO TB_Prestamos (IdEstructura, id, IdPrestamo, ' +
      'Prestamista, Responsable, FPrestamo, FDevolucion) VALUES (:est, :id, :p, ' +
      '''Juan'', ''usr1'', :fp, :fd)';
    Q.ParamByName('est').AsString := EST_T;
    Q.ParamByName('id').AsInteger := NODO_T;
    Q.ParamByName('p').AsString := IdP;
    Q.ParamByName('fp').AsDateTime := EncodeDate(2026, 4, 1);
    Q.ParamByName('fd').DataType := ftDateTime;
    if Devuelto then
      Q.ParamByName('fd').AsDateTime := EncodeDate(2026, 4, 5)
    else
      Q.ParamByName('fd').Clear;
    Q.ExecSQL;
    Q.SQL.Text := 'INSERT INTO TB_PrestamosDocumentos (IdEstructura, id, ' +
      'IdPrestamo, Codigodoc, fecha, version, codsubs, titulodoc) VALUES (:est, :id, :p, ' +
      '''F2T-EXP'', :f, ''1'', ''014001'', ''t'')';
    Q.ParamByName('est').AsString := EST_T;
    Q.ParamByName('id').AsInteger := NODO_T;
    Q.ParamByName('p').AsString := IdP;
    Q.ParamByName('f').AsDateTime := EncodeDate(2026, 1, 31);
    Q.ExecSQL;
  end;

begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Prestamo('F5T-P1', True);
    Prestamo('F5T-P2', False);
  finally
    Q.Free;
  end;
  L := Linea(TSembradoVista.Clave('F2T-EXP', '014001'), 'administrador', True, 50, Mas);
  Assert.AreEqual(3, Length(L));
  Assert.AreEqual(Ord(teDevuelto), Ord(L[0].Tipo));
  Assert.AreEqual('Juan', L[0].Detalle);
end;

procedure TPruebasLineaTiempoSql.Alcance_FueraDeAlcance_Vacio;
var
  L: TArray<TEventoDoc>;
  Mas: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Log('F2T-H2', EST_T, NODO_T, 5, EncodeDate(2026, 3, 1));
  FConn.ExecSQL('UPDATE tb_log SET codsubsdoc = ''003'' WHERE codigodoc = ''F2T-H2''');
  L := Linea(TSembradoVista.Clave('F2T-H2', '003'), 'prueba_alc_usr1', False, 50, Mas);
  Assert.AreEqual(0, Length(L));
end;

procedure TPruebasLineaTiempoSql.Alcance_DentroDeAlcance_VeEventos;
var
  L: TArray<TEventoDoc>;
  Mas: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Log('F2T-H3', EST_T, NODO_T, 5, EncodeDate(2026, 3, 1));
  L := Linea(TSembradoVista.Clave('F2T-H3', '014001'), 'prueba_alc_usr1', False, 50, Mas);
  Assert.AreEqual(1, Length(L));
end;

procedure TPruebasLineaTiempoSql.Maximo_LimitaYAvisa;
var
  L: TArray<TEventoDoc>;
  Mas: Boolean;
  I: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  for I := 1 to 5 do
    Log('F2T-EXP', EST_T, NODO_T, 14, EncodeDate(2026, 3, I));
  L := Linea(TSembradoVista.Clave('F2T-EXP', '014001'), 'administrador', True, 3, Mas);
  Assert.AreEqual(3, Length(L));
  Assert.IsTrue(Mas);
end;

procedure TPruebasTrazabilidadDatos.Access_RegistrarEvento_GuardaUsuarioPcEIpDados;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  RegistrarEventoDoc(FConn, ClavePrueba('F5T-005'), 5, 'origen F5T-005', 'usr1',
    'Rol', 'S1', 'winuser', 'PC-PRUEBA', '10.1.2.3');
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_log WHERE codigodoc = ''F5T-005'' ' +
    'AND usuariopc = ''winuser'' AND pc = ''PC-PRUEBA'' AND ip = ''10.1.2.3'''));
  // sin origen explicito sigue valiendo el entorno (unidades sin acceso a DatosPC)
  RegistrarEventoDoc(FConn, ClavePrueba('F5T-006'), 5, 'origen F5T-006', 'usr1',
    'Rol', 'S1');
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_log WHERE codigodoc = ''F5T-006'' ' +
    'AND ip = '''''));
end;

procedure TPruebasTrazabilidadDatos.Access_SinColumnasF5_GuardaLaFilaDeSiempre;
var
  C: TClaveDocumento;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  QuitarColumnasF5;
  C := ClavePrueba('F5T-002');
  RegistrarEventoDoc(FConn, C, 5, 'sin columnas F5T-002', 'usr1', 'Rol', 'S1');
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_log WHERE msg = ''sin columnas F5T-002'''));
end;

procedure TPruebasTrazabilidadDatos.Access_LineaTiempo_MaximoLimitaYAvisa;
var
  C: TClaveDocumento;
  L: TArray<TEventoDoc>;
  Mas: Boolean;
  Motivo: string;
  I: Integer;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  C := ClavePrueba('F5T-003');
  SembrarDocumento(C);
  for I := 1 to 5 do
    FConn.ExecSQL('INSERT INTO tb_log (usuariopc, pc, fecha, ip, usuario_sistema, ' +
      'rol, serie, subserie, msg, accion, IdEstructura, ' +
      'codigodoc, iddoc, codsubsdoc, versiondoc, fecha_evento) VALUES ' +
      '(''u'', ''p'', ''f' + IntToStr(I) + ''', ''i'', ''u'', ''r'', ''s'', ''074'', ''ev' + IntToStr(I) +
      ''', 14, ''A.4.3'', ''F5T-003'', 104, ''074'', ' +
      '''1'', :f)', [EncodeDate(2026, 3, I)]);
  L := CargarLineaTiempo(FConn, nil, C, 3, Mas, Motivo);
  Assert.AreEqual('', Motivo);
  Assert.AreEqual(3, Length(L));
  Assert.IsTrue(Mas);
  Assert.AreEqual('ev5', L[0].Detalle);
  Assert.AreEqual('ev3', L[2].Detalle);
  L := CargarLineaTiempo(FConn, nil, C, 5, Mas, Motivo);
  Assert.AreEqual(5, Length(L));
  Assert.IsFalse(Mas);
end;

procedure TPruebasTrazabilidadDatos.Access_LineaTiempo_SinColumnasF5_DiceElMotivo;
var
  C: TClaveDocumento;
  L: TArray<TEventoDoc>;
  Mas: Boolean;
  Motivo: string;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  C := ClavePrueba('F5T-004');
  SembrarDocumento(C);
  QuitarColumnasF5;
  L := CargarLineaTiempo(FConn, nil, C, 50, Mas, Motivo);
  Assert.AreEqual(0, Length(L));
  Assert.IsTrue(Motivo <> '', 'sin columnas debe explicar que la historia no esta disponible');
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasTrazabilidadDatos);
  TDUnitX.RegisterTestFixture(TPruebasLineaTiempoSql);

end.
