unit UPruebasEsquemaAlmacen;

{ SQL Server: ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB (COPIA de la base,
  se modifica). Se omiten sin su variable. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasEsquemaAlmacen = class
  private
    FConn: TFDConnection;
    FEsSql: Boolean;
    function ColumnaExiste(const Columna: string): Boolean;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SqlServer_AgregaColumnasYEsIdempotente;
    [Test]
    procedure Access_AgregaColumnasYEsIdempotente;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param,
  Data.DB, UEsquemaAlmacen;

const
  COLUMNAS: array[0..5] of string = ('tipo', 'bucket', 'region', 'usohttps',
    'clave_acceso', 'secreto_cifrado');

procedure TPruebasEsquemaAlmacen.Preparar;
begin
  FConn := nil;
end;

procedure TPruebasEsquemaAlmacen.Limpiar;
begin
  FreeAndNil(FConn);
end;

function TPruebasEsquemaAlmacen.ColumnaExiste(const Columna: string): Boolean;
begin
  try
    FConn.ExecSQLScalar('SELECT COUNT(' + Columna + ') FROM cl_ftp_Server');
    Result := True;
  except
    Result := False;
  end;
end;

procedure TPruebasEsquemaAlmacen.SqlServer_AgregaColumnasYEsIdempotente;
var
  Nombre: string;
  I: Integer;
begin
  Nombre := GetEnvironmentVariable('ARCHIGENIO_TEST_DB');
  if Nombre = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := Nombre;
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
  CrearEsquemaAlmacen(FConn, True);
  CrearEsquemaAlmacen(FConn, True); // segunda vez: idempotente
  for I := Low(COLUMNAS) to High(COLUMNAS) do
    Assert.IsTrue(ColumnaExiste(COLUMNAS[I]), 'SQL Server: falta ' + COLUMNAS[I]);
  Assert.AreEqual(0, Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(*) FROM cl_ftp_Server WHERE tipo IS NULL')),
    'filas existentes deben quedar como FTP');
  Assert.IsTrue(EsquemaAlmacenCompleto(FConn), 'el esquema debe quedar completo');
end;

procedure TPruebasEsquemaAlmacen.Access_AgregaColumnasYEsIdempotente;
var
  Ruta: string;
  I: Integer;
begin
  Ruta := GetEnvironmentVariable('ARCHIGENIO_TEST_MDB');
  if Ruta = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSAcc';
  FConn.Params.Values['Database'] := Ruta;
  FConn.Connected := True;
  CrearEsquemaAlmacen(FConn, False);
  CrearEsquemaAlmacen(FConn, False);
  for I := Low(COLUMNAS) to High(COLUMNAS) do
    Assert.IsTrue(ColumnaExiste(COLUMNAS[I]), 'Access: falta ' + COLUMNAS[I]);
  Assert.AreEqual(0, Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(*) FROM cl_ftp_Server WHERE tipo IS NULL')),
    'filas existentes deben quedar como FTP');
  Assert.IsTrue(EsquemaAlmacenCompleto(FConn), 'el esquema debe quedar completo');
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasEsquemaAlmacen);

end.
