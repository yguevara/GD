unit UPruebasEsquemaTrazabilidad;

{ SQL Server: ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB (COPIA). Se omiten
  sin su variable. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasEsquemaTrazabilidad = class
  private
    FConn: TFDConnection;
    procedure Conectar(EsSql: Boolean);
    function Existe(const Sql: string): Boolean;
    function Contar: Integer;
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
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UEsquemaTrazabilidad;

procedure TPruebasEsquemaTrazabilidad.Conectar(EsSql: Boolean);
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

procedure TPruebasEsquemaTrazabilidad.Limpiar;
begin
  FreeAndNil(FConn);
end;

function TPruebasEsquemaTrazabilidad.Contar: Integer;
begin
  Result := FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_log');
end;

function TPruebasEsquemaTrazabilidad.Existe(const Sql: string): Boolean;
begin
  try
    FConn.ExecSQLScalar(Sql);
    Result := True;
  except
    Result := False;
  end;
end;

procedure TPruebasEsquemaTrazabilidad.SqlServer_CreaYEsIdempotente;
var
  Antes: Integer;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  Antes := Contar;
  CrearEsquemaTrazabilidad(FConn, True);
  CrearEsquemaTrazabilidad(FConn, True);
  Assert.AreEqual(Antes, Contar);
  Assert.IsTrue(Existe('SELECT COUNT(codigodoc), COUNT(iddoc), COUNT(codsubsdoc), COUNT(versiondoc), COUNT(fecha_evento) FROM tb_log'), 'faltan columnas');
  Assert.IsTrue(EsquemaTrazabilidadCompleto(FConn));
end;

procedure TPruebasEsquemaTrazabilidad.Access_CreaYEsIdempotente;
var
  Antes: Integer;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  Antes := Contar;
  CrearEsquemaTrazabilidad(FConn, False);
  CrearEsquemaTrazabilidad(FConn, False);
  Assert.AreEqual(Antes, Contar);
  Assert.IsTrue(Existe('SELECT COUNT(codigodoc), COUNT(iddoc), COUNT(codsubsdoc), COUNT(versiondoc), COUNT(fecha_evento) FROM tb_log'), 'Access: faltan columnas');
  Assert.IsTrue(EsquemaTrazabilidadCompleto(FConn));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasEsquemaTrazabilidad);

end.
