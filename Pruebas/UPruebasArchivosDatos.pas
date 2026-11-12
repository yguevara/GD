unit UPruebasArchivosDatos;

{ Datos de archivos (UArchivosDatos). La validacion no usa base de datos; el
  resto usa SGDTEST_ALCANCE (ARCHIGENIO_TEST_DB) y deja la base como estaba:
  borra toda fila cuyo nombre empiece por zz_arch. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UServidoresDatos, UArchivosDatos;

type
  [TestFixture]
  TPruebasValidarArchivo = class
  private
    function Valido: TArchivo;
    function TieneError(const E: TArray<TErrorCampo>; const Campo: string): Boolean;
  public
    [Test]
    procedure Valido_Completo_SinErrores;
    [Test]
    procedure Nombre_Vacio_Error;
    [Test]
    procedure Nombre_De101_Error;
    [Test]
    procedure SinTipo_Error;
    [Test]
    procedure SinResponsable_Valido;
    [Test]
    procedure Dos_Errores_Dos_Campos;
  end;

  [TestFixture]
  TPruebasListarArchivos = class
  private
    FConn: TFDConnection;
    procedure Restaurar;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Listar_IncluyeLosExistentes;
    [Test]
    procedure Listar_MarcaCroquisYFoto;
    [Test]
    procedure Tipos_IncluyeCentralYGestion;
    [Test]
    procedure Responsables_NoVacio;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';

{ TPruebasValidarArchivo }

function TPruebasValidarArchivo.Valido: TArchivo;
begin
  Result := Default(TArchivo);
  Result.Nombre := 'zz_arch valido';
  Result.Tipo := 2;
  Result.Idresp := 1;
end;

function TPruebasValidarArchivo.TieneError(const E: TArray<TErrorCampo>;
  const Campo: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(E) do
    if E[I].Campo = Campo then
      Exit(True);
end;

procedure TPruebasValidarArchivo.Valido_Completo_SinErrores;
begin
  Assert.AreEqual(0, Length(ValidarArchivo(Valido)));
end;

procedure TPruebasValidarArchivo.Nombre_Vacio_Error;
var
  A: TArchivo;
begin
  A := Valido;
  A.Nombre := '   ';
  Assert.IsTrue(TieneError(ValidarArchivo(A), 'nombre'));
end;

procedure TPruebasValidarArchivo.Nombre_De101_Error;
var
  A: TArchivo;
begin
  A := Valido;
  A.Nombre := StringOfChar('a', 101);
  Assert.IsTrue(TieneError(ValidarArchivo(A), 'nombre'));
end;

procedure TPruebasValidarArchivo.SinTipo_Error;
var
  A: TArchivo;
begin
  A := Valido;
  A.Tipo := 0;
  Assert.IsTrue(TieneError(ValidarArchivo(A), 'tipo'));
end;

procedure TPruebasValidarArchivo.SinResponsable_Valido;
var
  A: TArchivo;
begin
  A := Valido;
  A.Idresp := 0;
  Assert.AreEqual(0, Length(ValidarArchivo(A)));
end;

procedure TPruebasValidarArchivo.Dos_Errores_Dos_Campos;
var
  A: TArchivo;
  E: TArray<TErrorCampo>;
begin
  A := Valido;
  A.Nombre := '';
  A.Tipo := 0;
  E := ValidarArchivo(A);
  Assert.AreEqual(2, Length(E));
  Assert.IsTrue(E[0].Campo <> E[1].Campo);
end;

{ TPruebasListarArchivos }

procedure TPruebasListarArchivos.Preparar;
var
  NombreBD: string;
begin
  FConn := nil;
  NombreBD := GetEnvironmentVariable(VAR_BD);
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
  Restaurar;
end;

procedure TPruebasListarArchivos.Restaurar;
begin
  FConn.ExecSQL('DELETE FROM cl_ArchivosGestion WHERE nombreArchivo LIKE ''zz_arch%''');
end;

procedure TPruebasListarArchivos.Limpiar;
begin
  if FConn <> nil then
  begin
    Restaurar;
    FreeAndNil(FConn);
  end;
end;

procedure TPruebasListarArchivos.Listar_IncluyeLosExistentes;
var
  L: TArray<TArchivo>;
  I: Integer;
  Hallado: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  L := ListarArchivos(FConn);
  Hallado := False;
  for I := 0 to High(L) do
    if L[I].Cod = 1 then
    begin
      Hallado := True;
      Assert.IsTrue(L[I].Nombre <> '');
      Assert.IsTrue(L[I].Tipo > 0);
    end;
  Assert.IsTrue(Hallado, 'debe existir el archivo Cod 1');
end;

procedure TPruebasListarArchivos.Listar_MarcaCroquisYFoto;
var
  Q: TFDQuery;
  B: TBytes;
  L: TArray<TArchivo>;
  I: Integer;
  Hallado: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'INSERT INTO cl_ArchivosGestion (Cod, nombreArchivo, Tipo, croquis) ' +
      'VALUES (9001, ''zz_arch img'', 1, :b)';
    Q.Params[0].DataType := ftBlob;
    B := TBytes.Create(1, 2, 3);
    Q.Params[0].SetBlobRawData(Length(B), @B[0]);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
  L := ListarArchivos(FConn);
  Hallado := False;
  for I := 0 to High(L) do
    if L[I].Cod = 9001 then
    begin
      Hallado := True;
      Assert.IsTrue(L[I].TieneCroquis);
      Assert.IsFalse(L[I].TieneFoto);
    end;
  Assert.IsTrue(Hallado);
end;

procedure TPruebasListarArchivos.Tipos_IncluyeCentralYGestion;
var
  L: TArray<TOpcion>;
  I: Integer;
  Central, Gestion: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  L := ListarTiposArchivo(FConn);
  Central := False;
  Gestion := False;
  for I := 0 to High(L) do
  begin
    if L[I].Id = 1 then
      Central := True;
    if L[I].Id = 2 then
      Gestion := True;
  end;
  Assert.IsTrue(Central and Gestion);
end;

procedure TPruebasListarArchivos.Responsables_NoVacio;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.IsTrue(Length(ListarResponsables(FConn)) > 0);
end;

end.
