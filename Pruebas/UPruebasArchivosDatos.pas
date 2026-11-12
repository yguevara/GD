unit UPruebasArchivosDatos;

{ Datos de archivos (UArchivosDatos). La validacion no usa base de datos; el
  resto usa SGDTEST_ALCANCE (ARCHIGENIO_TEST_DB) y deja la base como estaba:
  borra toda fila cuyo nombre empiece por zz_arch. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UServidoresDatos, UErroresCampo, UArchivosDatos;

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

  [TestFixture]
  TPruebasGuardarArchivos = class
  private
    FConn: TFDConnection;
    function ArchivoNuevo(const ANombre: string): TArchivo;
    function Contar: Integer;
    procedure Restaurar;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Guardar_Nuevo_AsignaCodYSePuedeLeer;
    [Test]
    procedure Guardar_Editar_CambiaNombreTipoYResp;
    [Test]
    procedure Guardar_Editar_NoTocaImagenesNiDescripcion;
    [Test]
    procedure Guardar_SinResponsable_GuardaNull;
    [Test]
    procedure Guardar_Invalido_LanzaYNoEscribe;
    [Test]
    procedure Descripcion_RoundTrip;
    [Test]
    procedure Descripcion_Vacia_GuardaNull;
    [Test]
    procedure Imagen_RoundTrip;
    [Test]
    procedure Imagen_Quitar_DejaVacio;
    [Test]
    procedure Eliminar_SinUso_Borra;
    [Test]
    procedure Eliminar_EnUsoPorSubserie_Bloquea;
    [Test]
    procedure Eliminar_EnUsoPorSerieTree_Bloquea;
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

{ TPruebasGuardarArchivos }

procedure TPruebasGuardarArchivos.Preparar;
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

procedure TPruebasGuardarArchivos.Restaurar;
begin
  FConn.ExecSQL('DELETE FROM cl_ArchivosGestion WHERE nombreArchivo LIKE ''zz_arch%''');
end;

procedure TPruebasGuardarArchivos.Limpiar;
begin
  if FConn <> nil then
  begin
    if FConn.InTransaction then
      FConn.Rollback;
    Restaurar;
    FreeAndNil(FConn);
  end;
end;

function TPruebasGuardarArchivos.ArchivoNuevo(const ANombre: string): TArchivo;
begin
  Result := Default(TArchivo);
  Result.Nombre := ANombre;
  Result.Tipo := 1;
  Result.Idresp := 0;
end;

function TPruebasGuardarArchivos.Contar: Integer;
begin
  Result := Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(*) FROM cl_ArchivosGestion WHERE nombreArchivo LIKE ''zz_arch%'''));
end;

procedure TPruebasGuardarArchivos.Guardar_Nuevo_AsignaCodYSePuedeLeer;
var
  Cod, I: Integer;
  L: TArray<TArchivo>;
  Hallado: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch nuevo'));
  Assert.IsTrue(Cod > 0);
  L := ListarArchivos(FConn);
  Hallado := False;
  for I := 0 to High(L) do
    if L[I].Cod = Cod then
    begin
      Hallado := True;
      Assert.AreEqual('zz_arch nuevo', L[I].Nombre);
      Assert.AreEqual(1, L[I].Tipo);
    end;
  Assert.IsTrue(Hallado);
end;

procedure TPruebasGuardarArchivos.Guardar_Editar_CambiaNombreTipoYResp;
var
  A: TArchivo;
  Cod, I: Integer;
  L: TArray<TArchivo>;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch uno'));
  A := ArchivoNuevo('zz_arch editado');
  A.Cod := Cod;
  A.Tipo := 2;
  A.Idresp := 1;
  Assert.AreEqual(Cod, GuardarArchivo(FConn, A));
  L := ListarArchivos(FConn);
  for I := 0 to High(L) do
    if L[I].Cod = Cod then
    begin
      Assert.AreEqual('zz_arch editado', L[I].Nombre);
      Assert.AreEqual(2, L[I].Tipo);
      Assert.AreEqual(1, L[I].Idresp);
    end;
end;

procedure TPruebasGuardarArchivos.Guardar_Editar_NoTocaImagenesNiDescripcion;
var
  A: TArchivo;
  Cod: Integer;
  Croq, Foto: TBytes;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch con datos'));
  GuardarImagen(FConn, Cod, ciCroquis, TBytes.Create(1, 2, 3));
  GuardarImagen(FConn, Cod, ciFoto, TBytes.Create(4, 5));
  GuardarDescripcion(FConn, Cod, '{\rtf1 hola}');
  A := ArchivoNuevo('zz_arch renombrado');
  A.Cod := Cod;
  GuardarArchivo(FConn, A);
  Croq := LeerImagen(FConn, Cod, ciCroquis);
  Foto := LeerImagen(FConn, Cod, ciFoto);
  Assert.AreEqual(3, Length(Croq));
  Assert.AreEqual(2, Length(Foto));
  Assert.AreEqual('{\rtf1 hola}', LeerDescripcion(FConn, Cod));
end;

procedure TPruebasGuardarArchivos.Guardar_SinResponsable_GuardaNull;
var
  Cod: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch sin resp'));
  Assert.AreEqual(1, Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(*) FROM cl_ArchivosGestion WHERE Cod = :c AND Idresp IS NULL', [Cod])));
end;

procedure TPruebasGuardarArchivos.Guardar_Invalido_LanzaYNoEscribe;
var
  A: TArchivo;
  Antes: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Antes := Contar;
  A := ArchivoNuevo('zz_arch malo');
  A.Tipo := 0;
  Assert.WillRaise(
    procedure
    begin
      GuardarArchivo(FConn, A);
    end, EArchivoInvalido);
  Assert.AreEqual(Antes, Contar);
end;

procedure TPruebasGuardarArchivos.Descripcion_RoundTrip;
var
  Cod: Integer;
  Rtf: string;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch rtf'));
  Rtf := '{\rtf1\ansi\deff0 {\fonttbl{\f0 Arial;}}caf\''e9 \b negrita\b0 }';
  GuardarDescripcion(FConn, Cod, Rtf);
  Assert.AreEqual(Rtf, LeerDescripcion(FConn, Cod));
end;

procedure TPruebasGuardarArchivos.Descripcion_Vacia_GuardaNull;
var
  Cod: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch sin desc'));
  GuardarDescripcion(FConn, Cod, 'algo');
  GuardarDescripcion(FConn, Cod, '');
  Assert.AreEqual(1, Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(*) FROM cl_ArchivosGestion WHERE Cod = :c AND Descripcion IS NULL', [Cod])));
  Assert.AreEqual('', LeerDescripcion(FConn, Cod));
end;

procedure TPruebasGuardarArchivos.Imagen_RoundTrip;
var
  Cod, I: Integer;
  B, R: TBytes;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch img'));
  SetLength(B, 100000);
  for I := 0 to High(B) do
    B[I] := Byte(I mod 256);
  GuardarImagen(FConn, Cod, ciFoto, B);
  R := LeerImagen(FConn, Cod, ciFoto);
  Assert.AreEqual(Length(B), Length(R));
  Assert.IsTrue(CompareMem(@B[0], @R[0], Length(B)), 'los bytes deben ser identicos');
end;

procedure TPruebasGuardarArchivos.Imagen_Quitar_DejaVacio;
var
  Cod: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch quitar'));
  GuardarImagen(FConn, Cod, ciCroquis, TBytes.Create(9, 9));
  QuitarImagen(FConn, Cod, ciCroquis);
  Assert.AreEqual(0, Length(LeerImagen(FConn, Cod, ciCroquis)));
end;

procedure TPruebasGuardarArchivos.Eliminar_SinUso_Borra;
var
  Cod: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch borrar'));
  EliminarArchivo(FConn, Cod);
  Assert.AreEqual(0, Contar);
end;

procedure TPruebasGuardarArchivos.Eliminar_EnUsoPorSubserie_Bloquea;
var
  Cod, Usos: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch usado'));
  Usos := 0;
  FConn.StartTransaction;
  try
    FConn.ExecSQL('UPDATE cl_subseries SET archivo = :c', [Cod]);
    try
      EliminarArchivo(FConn, Cod);
      Assert.Fail('debio lanzar EArchivoEnUso');
    except
      on E: EArchivoEnUso do
        Usos := E.Usos;
    end;
    Assert.IsTrue(Usos >= 1);
    Assert.AreEqual(1, Contar);
  finally
    FConn.Rollback;
  end;
end;

procedure TPruebasGuardarArchivos.Eliminar_EnUsoPorSerieTree_Bloquea;
var
  Cod, Usos: Integer;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Cod := GuardarArchivo(FConn, ArchivoNuevo('zz_arch usado2'));
  Usos := 0;
  FConn.StartTransaction;
  try
    FConn.ExecSQL('UPDATE tb_Serietree SET Archivo = :c', [Cod]);
    try
      EliminarArchivo(FConn, Cod);
      Assert.Fail('debio lanzar EArchivoEnUso');
    except
      on E: EArchivoEnUso do
        Usos := E.Usos;
    end;
    Assert.IsTrue(Usos >= 1);
    Assert.AreEqual(1, Contar);
  finally
    FConn.Rollback;
  end;
end;

end.
