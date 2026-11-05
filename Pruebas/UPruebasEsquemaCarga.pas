unit UPruebasEsquemaCarga;

{ SQL Server: ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB (COPIA). Se omiten
  sin su variable. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasEsquemaCarga = class
  private
    FConn: TFDConnection;
    procedure Conectar(EsSql: Boolean);
    function Existe(const Sql: string): Boolean;
  public
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SqlServer_CreaYEsIdempotente;
    [Test]
    procedure Access_CreaYEsIdempotente;
  end;

implementation

uses
  System.SysUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UEsquemaCarga;

procedure TPruebasEsquemaCarga.Conectar(EsSql: Boolean);
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
end;

procedure TPruebasEsquemaCarga.Limpiar;
begin
  FreeAndNil(FConn);
end;

function TPruebasEsquemaCarga.Existe(const Sql: string): Boolean;
begin
  try
    FConn.ExecSQLScalar(Sql);
    Result := True;
  except
    Result := False;
  end;
end;

procedure TPruebasEsquemaCarga.SqlServer_CreaYEsIdempotente;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  CrearEsquemaCarga(FConn, True);
  CrearEsquemaCarga(FConn, True);
  Assert.IsTrue(Existe('SELECT COUNT(obligatorio) FROM cl_VarSubserie'), 'falta obligatorio');
  Assert.IsTrue(Existe('SELECT COUNT(*) FROM tb_carga_valores'), 'falta tb_carga_valores');
  Assert.IsTrue(EsquemaCargaCompleto(FConn));
end;

procedure TPruebasEsquemaCarga.Access_CreaYEsIdempotente;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  CrearEsquemaCarga(FConn, False);
  CrearEsquemaCarga(FConn, False);
  Assert.IsTrue(Existe('SELECT COUNT(obligatorio) FROM cl_VarSubserie'), 'Access: falta obligatorio');
  Assert.IsTrue(Existe('SELECT COUNT(*) FROM tb_carga_valores'), 'Access: falta tb_carga_valores');
  Assert.IsTrue(EsquemaCargaCompleto(FConn));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasEsquemaCarga);

end.
