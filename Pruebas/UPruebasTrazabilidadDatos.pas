unit UPruebasTrazabilidadDatos;

{ SQL Server: ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB (COPIA). Se omiten
  sin su variable. Filas propias con codigodoc F5T-*, borradas al final. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UDocumentoVista;

type
  [TestFixture]
  TPruebasTrazabilidadDatos = class
  private
    FConn: TFDConnection;
    procedure Conectar(EsSql: Boolean);
    function Cuenta(const Sql: string): Integer;
    procedure ProbarRegistro;
  public
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SqlServer_RegistrarEvento_GuardaClaveYFecha;
    [Test]
    procedure Access_RegistrarEvento_GuardaClaveYFecha;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB,
  UEsquemaTrazabilidad, UTrazabilidadDatos;

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
    FConn.ExecSQL('DELETE FROM tb_log WHERE codigodoc LIKE ''F5T-%''');
  except
  end;
  FreeAndNil(FConn);
end;

function TPruebasTrazabilidadDatos.Cuenta(const Sql: string): Integer;
begin
  Result := FConn.ExecSQLScalar(Sql);
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

initialization
  TDUnitX.RegisterTestFixture(TPruebasTrazabilidadDatos);

end.
