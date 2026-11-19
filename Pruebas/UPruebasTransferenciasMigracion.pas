unit UPruebasTransferenciasMigracion;

{ Pruebas del informe de tb_transferencia (UTransferenciasMigracion) contra SQL Server;
  se omiten sin ARCHIGENIO_TEST_DB. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasTransferenciasMigracion = class
  private
    FConn: TFDConnection;
    function Conectar: Boolean;
    procedure Vieja(Ejecutada: Integer; const Serie: string);
  public
    [SetupFixture]
    procedure Preparar;
    [TearDownFixture]
    procedure Limpiar;
    [Setup]
    procedure AntesDeCada;
    [Test]
    procedure SinLineasDeLaPruebaSoloCuentaLoQueHay;
    [Test]
    procedure CuentaEjecutadasYSinEjecutarYNoEscribeNada;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param,
  Data.DB, UPrestamosMigracion, UTransferenciasMigracion;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';

procedure TPruebasTransferenciasMigracion.Preparar;
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
end;

procedure TPruebasTransferenciasMigracion.AntesDeCada;
begin
  if FConn <> nil then
    FConn.ExecSQL('DELETE FROM tb_transferencia WHERE entidad = ''__prueba__''');
end;

procedure TPruebasTransferenciasMigracion.Limpiar;
begin
  if FConn <> nil then
  try
    FConn.ExecSQL('DELETE FROM tb_transferencia WHERE entidad = ''__prueba__''');
  finally
    FreeAndNil(FConn);
  end;
end;

function TPruebasTransferenciasMigracion.Conectar: Boolean;
begin
  Result := FConn <> nil;
  if not Result then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
end;

procedure TPruebasTransferenciasMigracion.Vieja(Ejecutada: Integer; const Serie: string);
begin
  FConn.ExecSQL('INSERT INTO tb_transferencia (idtransfer, fechainput, entidad, serie, ' +
    'subserie, Ejecutada) SELECT COALESCE(MAX(idtransfer), 0) + 1, :f, ''__prueba__'', :s, ' +
    '''sub'', :e FROM tb_transferencia',
    [EncodeDate(2025, 5, 4), Serie, Ejecutada], [ftDateTime, ftString, ftInteger]);
end;

procedure TPruebasTransferenciasMigracion.SinLineasDeLaPruebaSoloCuentaLoQueHay;
var
  R: TInformeMigracion;
  Total: Integer;
begin
  if not Conectar then Exit;
  Total := Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_transferencia'));
  R := InformarTransferenciasViejas(FConn);
  Assert.AreEqual(Total, R.Leidos);
  Assert.AreEqual(0, R.Migrados, 'nunca migra');
end;

procedure TPruebasTransferenciasMigracion.CuentaEjecutadasYSinEjecutarYNoEscribeNada;
var
  R: TInformeMigracion;
  Antes, Base: Integer;
begin
  if not Conectar then Exit;
  Base := InformarTransferenciasViejas(FConn).Leidos;
  Vieja(1, 'Serie A');
  Vieja(1, 'Serie B');
  Vieja(0, 'Serie C');
  Antes := Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_transferencia'));
  R := InformarTransferenciasViejas(FConn);
  Assert.AreEqual(Base + 3, R.Leidos);
  Assert.IsTrue(Length(R.Avisos) >= 2, 'resumen y la linea sin ejecutar');
  Assert.IsTrue(Pos('2 ejecutadas', R.Avisos[0]) > 0);
  Assert.IsTrue(Pos('sin ejecutar', R.Avisos[0]) > 0);
  Assert.IsTrue(Pos('Serie C', R.Avisos[High(R.Avisos)]) > 0);
  Assert.AreEqual(Antes, Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_transferencia')),
    'no escribe');
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasTransferenciasMigracion);

end.
