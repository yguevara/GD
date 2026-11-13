unit UPruebasPrestamosMigracion;

{ Migracion de los prestamos antiguos (TB_Prestamos, TB_PrestamosDocumentos) a
  prc_*. La regla de estado es pura y se ejecuta siempre; las pruebas de base se
  omiten sin ARCHIGENIO_TEST_DB. Usan prestamos viejos con IdPrestamo 'ZZ...' y
  los borran al terminar. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasMigracionPura = class
  public
    [Test]
    procedure DevueltoSeMigraComoFinalizado;
    [Test]
    procedure CanceladoSeMigraComoCancelado;
    [Test]
    procedure AbiertoSeMigraComoEntregado;
    [Test]
    procedure DevueltoYCanceladoGanaLaDevolucion;
  end;

  [TestFixture]
  TPruebasMigracionBD = class
  private
    FConn: TFDConnection;
    function Conectar: Boolean;
    function Escalar(const Sql: string): Variant;
    procedure PrestamoViejo(const IdPrestamo, Nombre: string; Devuelto: Boolean);
    procedure DocumentoViejo(const IdPrestamo, Codigo: string);
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure MigraUnPrestamoConSusDocumentos;
    [Test]
    procedure EsIdempotente;
    [Test]
    procedure DocumentoRepetidoEnPrestamoAbiertoSeOmiteConAviso;
    [Test]
    procedure PrestamoSinDocumentosSeCuenta;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UProceso,
  UEsquemaProcesos, UPrestamosMigracion;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';

{ TPruebasMigracionPura }

procedure TPruebasMigracionPura.DevueltoSeMigraComoFinalizado;
var
  R: TEstadoMigrado;
begin
  R := EstadoMigrado(True, False);
  Assert.AreEqual(3, R.Paso);
  Assert.IsTrue(R.Estado = epFinalizado);
end;

procedure TPruebasMigracionPura.CanceladoSeMigraComoCancelado;
var
  R: TEstadoMigrado;
begin
  R := EstadoMigrado(False, True);
  Assert.IsTrue(R.Estado = epCancelado);
  Assert.AreEqual(1, R.Paso);
end;

procedure TPruebasMigracionPura.AbiertoSeMigraComoEntregado;
var
  R: TEstadoMigrado;
begin
  R := EstadoMigrado(False, False);
  Assert.AreEqual(2, R.Paso);
  Assert.IsTrue(R.Estado = epEnCurso);
end;

procedure TPruebasMigracionPura.DevueltoYCanceladoGanaLaDevolucion;
var
  R: TEstadoMigrado;
begin
  // Review Focus 4: datos viejos con FDevolucion y FCancelacion a la vez
  R := EstadoMigrado(True, True);
  Assert.IsTrue(R.Estado = epFinalizado);
  Assert.AreEqual(3, R.Paso);
end;

{ TPruebasMigracionBD }

procedure TPruebasMigracionBD.Preparar;
begin
  FConn := nil;
  if GetEnvironmentVariable(VAR_BD) = '' then
    Exit;
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := GetEnvironmentVariable(VAR_BD);
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
  CrearEsquemaProcesos(FConn, True);
end;

procedure TPruebasMigracionBD.Limpiar;
begin
  if FConn <> nil then
  try
    FConn.ExecSQL('DELETE FROM prc_proceso WHERE IdProceso IN (SELECT IdProceso ' +
      'FROM prc_prestamo WHERE IdPrestamoViejo LIKE ''ZZ%'')');
    FConn.ExecSQL('DELETE FROM TB_PrestamosDocumentos WHERE IdPrestamo LIKE ''ZZ%''');
    FConn.ExecSQL('DELETE FROM TB_Prestamos WHERE IdPrestamo LIKE ''ZZ%''');
  finally
    FreeAndNil(FConn);
  end;
end;

function TPruebasMigracionBD.Conectar: Boolean;
begin
  Result := FConn <> nil;
  if not Result then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
end;

function TPruebasMigracionBD.Escalar(const Sql: string): Variant;
begin
  Result := FConn.ExecSQLScalar(Sql);
end;

procedure TPruebasMigracionBD.PrestamoViejo(const IdPrestamo, Nombre: string;
  Devuelto: Boolean);
var
  IdEstr: string;
  IdNodo: Integer;
begin
  IdEstr := VarToStr(Escalar('SELECT TOP 1 IdEstructura FROM tb_tree ORDER BY IdEstructura, id'));
  IdNodo := Integer(Escalar('SELECT TOP 1 id FROM tb_tree ORDER BY IdEstructura, id'));
  if Devuelto then
    FConn.ExecSQL('INSERT INTO TB_Prestamos (IdEstructura, id, IdPrestamo, Prestamista, ' +
      'Estructura, Responsable, FPrestamo, FDevolucion, OBS) VALUES (:e, :i, :p, :n, ' +
      '''Finanzas'', ''Ana'', ''2019-03-01'', ''2019-03-05'', ''ok'')', [IdEstr, IdNodo, IdPrestamo, Nombre])
  else
    FConn.ExecSQL('INSERT INTO TB_Prestamos (IdEstructura, id, IdPrestamo, Prestamista, ' +
      'Estructura, Responsable, FPrestamo, OBS) VALUES (:e, :i, :p, :n, ' +
      '''Finanzas'', ''Ana'', ''2019-03-01'', ''ok'')', [IdEstr, IdNodo, IdPrestamo, Nombre]);
end;

procedure TPruebasMigracionBD.DocumentoViejo(const IdPrestamo, Codigo: string);
var
  IdEstr: string;
  IdNodo: Integer;
begin
  IdEstr := VarToStr(Escalar('SELECT TOP 1 IdEstructura FROM tb_tree ORDER BY IdEstructura, id'));
  IdNodo := Integer(Escalar('SELECT TOP 1 id FROM tb_tree ORDER BY IdEstructura, id'));
  FConn.ExecSQL('INSERT INTO TB_PrestamosDocumentos (IdEstructura, id, IdPrestamo, ' +
    'Codigodoc, fecha, version, codsubs, titulodoc) VALUES (:e, :i, :p, :c, ' +
    '''2018-01-01'', ''1'', ''ZZSUB'', ''Documento de prueba'')',
    [IdEstr, IdNodo, IdPrestamo, Codigo]);
end;

procedure TPruebasMigracionBD.MigraUnPrestamoConSusDocumentos;
var
  R: TInformeMigracion;
begin
  if not Conectar then Exit;
  PrestamoViejo('ZZ0000000001', 'Luis Fernandez', True);
  DocumentoViejo('ZZ0000000001', 'ZZD1');
  DocumentoViejo('ZZ0000000001', 'ZZD2');
  R := MigrarPrestamosViejos(FConn, True);
  Assert.IsTrue(R.Migrados >= 1);
  Assert.AreEqual('Luis Fernandez', VarToStr(Escalar('SELECT Solicitante FROM prc_prestamo ' +
    'WHERE IdPrestamoViejo = ''ZZ0000000001''')));
  Assert.AreEqual('F', VarToStr(Escalar('SELECT p.Estado FROM prc_proceso p INNER JOIN ' +
    'prc_prestamo r ON r.IdProceso = p.IdProceso WHERE r.IdPrestamoViejo = ''ZZ0000000001''')));
  Assert.AreEqual(2, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad u INNER JOIN ' +
    'prc_prestamo r ON r.IdProceso = u.IdProceso WHERE r.IdPrestamoViejo = ''ZZ0000000001''')));
  Assert.AreEqual(2019, Integer(Escalar('SELECT p.Anio FROM prc_proceso p INNER JOIN ' +
    'prc_prestamo r ON r.IdProceso = p.IdProceso WHERE r.IdPrestamoViejo = ''ZZ0000000001''')));
end;

procedure TPruebasMigracionBD.EsIdempotente;
var
  R: TInformeMigracion;
  Antes: Integer;
begin
  if not Conectar then Exit;
  PrestamoViejo('ZZ0000000002', 'Ana', True);
  MigrarPrestamosViejos(FConn, True);
  Antes := Integer(Escalar('SELECT COUNT(*) FROM prc_prestamo'));
  R := MigrarPrestamosViejos(FConn, True);
  Assert.AreEqual(0, R.Migrados);
  Assert.AreEqual(Antes, Integer(Escalar('SELECT COUNT(*) FROM prc_prestamo')));
end;

procedure TPruebasMigracionBD.DocumentoRepetidoEnPrestamoAbiertoSeOmiteConAviso;
var
  R: TInformeMigracion;
begin
  if not Conectar then Exit;
  // dos prestamos abiertos con el mismo documento: solo el primero lo retiene
  PrestamoViejo('ZZ0000000003', 'Uno', False);
  PrestamoViejo('ZZ0000000004', 'Dos', False);
  DocumentoViejo('ZZ0000000003', 'ZZD9');
  DocumentoViejo('ZZ0000000004', 'ZZD9');
  R := MigrarPrestamosViejos(FConn, True);
  Assert.IsTrue(R.DocumentosOmitidos >= 1);
  Assert.IsTrue(Length(R.Avisos) >= 1);
  Assert.AreEqual(1, Integer(Escalar('SELECT COUNT(*) FROM prc_bloqueo WHERE Codigodoc = ''ZZD9''')));
end;

procedure TPruebasMigracionBD.PrestamoSinDocumentosSeCuenta;
var
  R: TInformeMigracion;
begin
  if not Conectar then Exit;
  PrestamoViejo('ZZ0000000005', 'Sin docs', True);
  R := MigrarPrestamosViejos(FConn, True);
  Assert.IsTrue(R.SinDocumentos >= 1);
  Assert.AreEqual(1, Integer(Escalar('SELECT COUNT(*) FROM prc_prestamo WHERE ' +
    'IdPrestamoViejo = ''ZZ0000000005''')), 'se migra aunque no tenga documentos');
end;

end.
