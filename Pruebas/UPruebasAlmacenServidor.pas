unit UPruebasAlmacenServidor;

{ CrearAlmacen / AlmacenParaFichero sobre cl_ftp_Server. SQL Server:
  ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB (COPIA). El servidor S3 real
  (ARCHIGENIO_TEST_S3) es opcional para la prueba de ida y vuelta. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasAlmacenServidor = class
  private
    FConn: TFDConnection;
    FEsSql: Boolean;
    procedure Conectar(EsSql: Boolean);
    procedure Sembrar(Id: Integer; const Tipo, Host, Bucket, SecretoCifrado: string;
      Puerto: Integer);
    procedure Borrar;
    procedure VerificarTodo;
    procedure VerificarGuardado;
  public
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SqlServer_Todo;
    [Test]
    procedure Access_Todo;
  end;

implementation

uses
  System.SysUtils, System.Variants, System.Classes, System.IOUtils, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, Data.DB, UEsquemaAlmacen, USecretoServidor, UAlmacenFicheros,
  UAlmacenS3, UAlmacenFtp, UAlmacenServidor;

const
  ID_FTP = 9001;
  ID_S3 = 9002;
  ID_S3_INCOMPLETO = 9003;
  HOST_LARGO = 'minio.empresa.local.dominio.largo.example'; // 41 caracteres

procedure TPruebasAlmacenServidor.Conectar(EsSql: Boolean);
var
  V: string;
begin
  FEsSql := EsSql;
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  if EsSql then
  begin
    V := GetEnvironmentVariable('ARCHIGENIO_TEST_DB');
    FConn.DriverName := 'MSSQL';
    FConn.Params.Values['Server'] := 'localhost';
    FConn.Params.Values['Database'] := V;
    FConn.Params.Values['User_Name'] := 'geoconn';
    FConn.Params.Values['Password'] := 'geoconn';
    FConn.Params.Values['OSAuthent'] := 'No';
  end
  else
  begin
    V := GetEnvironmentVariable('ARCHIGENIO_TEST_MDB');
    FConn.DriverName := 'MSAcc';
    FConn.Params.Values['Database'] := V;
  end;
  FConn.Connected := True;
  CrearEsquemaAlmacen(FConn, EsSql);
  Borrar;
end;

procedure TPruebasAlmacenServidor.Borrar;
begin
  FConn.ExecSQL('DELETE FROM cl_ftp_Server WHERE Idservidor IN (9001, 9002, 9003)');
  FConn.ExecSQL('DELETE FROM cl_ftp_Server WHERE etiquetaServ = ''prueba guardado''');
end;

procedure TPruebasAlmacenServidor.Limpiar;
begin
  if FConn <> nil then
  begin
    try
      Borrar;
    except
      // limpieza de mejor esfuerzo
    end;
    FreeAndNil(FConn);
  end;
end;

procedure TPruebasAlmacenServidor.Sembrar(Id: Integer; const Tipo, Host, Bucket,
  SecretoCifrado: string; Puerto: Integer);
begin
  FConn.ExecSQL('INSERT INTO cl_ftp_Server (Idservidor, etiquetaServ, ipserver, path, ' +
    'pass, puerto, usuarioftp, tipo, bucket, region, usohttps, clave_acceso, ' +
    'secreto_cifrado) VALUES (:id, :e, :h, :p, :pw, :pu, :u, :t, :b, :r, :s, :ca, :sc)',
    [Id, 'prueba ' + IntToStr(Id), Host, 'Geodato\', 'clave', Puerto, 'geodato', Tipo,
    Bucket, '', False, 'archigenio', SecretoCifrado]);
end;

procedure TPruebasAlmacenServidor.VerificarTodo;
var
  Alm: IAlmacenFicheros;
  Clave: string;
  Lanzo: Boolean;
  Id: Integer;
  S3Real, Origen, Destino: string;
  P: TArray<string>;
  Tam: Int64;
begin
  // Servidor FTP y S3 con host largo (ipserver debe admitir mas de 20 caracteres)
  Sembrar(ID_FTP, 'FTP', '127.0.0.1', '', '', 21);
  Sembrar(ID_S3, 'S3', HOST_LARGO, 'archigenio-prueba', CifrarSecreto('archigenio-test-1'), 9000);
  Sembrar(ID_S3_INCOMPLETO, 'S3', HOST_LARGO, '', CifrarSecreto('x'), 9000);

  Alm := CrearAlmacen(FConn, ID_S3);
  Assert.IsTrue((Alm as TObject) is TAlmacenS3, 'el servidor S3 debe dar TAlmacenS3');
  Alm := CrearAlmacen(FConn, ID_FTP);
  Assert.IsTrue((Alm as TObject) is TAlmacenFtp, 'el servidor FTP debe dar TAlmacenFtp');

  Lanzo := False;
  try
    CrearAlmacen(FConn, 8888);
  except
    on EAlmacen do Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'servidor inexistente debe lanzar EAlmacen');

  Lanzo := False;
  try
    CrearAlmacen(FConn, ID_S3_INCOMPLETO);
  except
    on EAlmacen do Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'servidor S3 sin bucket debe lanzar EAlmacen');

  // FTP de solo lectura
  Alm := CrearAlmacen(FConn, ID_FTP);
  Lanzo := False;
  try
    Alm.Subir('x', 'y', nil);
  except
    on EAlmacenSoloLectura do Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'Subir en FTP debe lanzar EAlmacenSoloLectura');
  Lanzo := False;
  try
    Alm.Borrar('y');
  except
    on EAlmacenSoloLectura do Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'Borrar en FTP debe lanzar EAlmacenSoloLectura');
  Lanzo := False;
  try
    Alm.UrlTemporal('y', 60);
  except
    on EAlmacenNoSoportado do Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'UrlTemporal en FTP debe lanzar EAlmacenNoSoportado');

  // Eleccion segun urlraiz
  Alm := AlmacenParaFichero(FConn, 's3://' + IntToStr(ID_S3) + '/', ID_FTP, Clave, 'A\B\', 'x.pdf');
  Assert.IsTrue((Alm as TObject) is TAlmacenS3);
  Assert.AreEqual('A/B/x.pdf', Clave);
  Alm := AlmacenParaFichero(FConn, '\docs\', ID_FTP, Clave, 'A\', 'x.pdf');
  Assert.IsTrue((Alm as TObject) is TAlmacenFtp);
  Assert.AreEqual('/docs/A/x.pdf', Clave);
  Alm := AlmacenParaFichero(FConn, '', ID_FTP, Clave, 'A/', 'x.pdf');
  Assert.IsTrue((Alm as TObject) is TAlmacenFtp);
  Assert.AreEqual('/A/x.pdf', '/' + Clave);

  // Servidor para ficheros nuevos
  Id := ServidorDestinoNuevos(FConn);
  Assert.AreEqual(ID_S3, Id);
  Borrar;
  Sembrar(ID_FTP, 'FTP', '127.0.0.1', '', '', 21);
  Assert.AreEqual(0, ServidorDestinoNuevos(FConn), 'sin servidor S3 debe dar 0');

  // Ida y vuelta real (secreto cifrado en la base, descifrado al crear el almacen)
  S3Real := GetEnvironmentVariable('ARCHIGENIO_TEST_S3');
  P := S3Real.Split(['|']);
  if Length(P) = 3 then
  begin
    FConn.ExecSQL('DELETE FROM cl_ftp_Server WHERE Idservidor = 9002');
    Sembrar(ID_S3, 'S3', Copy(P[0], 1, Pos(':', P[0]) - 1), 'archigenio-prueba',
      CifrarSecreto(P[2]), StrToInt(Copy(P[0], Pos(':', P[0]) + 1, 10)));
    FConn.ExecSQL('UPDATE cl_ftp_Server SET clave_acceso = :c WHERE Idservidor = 9002', [P[1]]);
    Alm := CrearAlmacen(FConn, ID_S3);
    Origen := TPath.GetTempFileName;
    Destino := TPath.GetTempFileName;
    try
      TFile.WriteAllText(Origen, 'ida y vuelta');
      Alm.Subir(Origen, 'pruebas/servidor/' + TGUID.NewGuid.ToString + '.txt', nil);
      Assert.IsTrue(True);
    finally
      TFile.Delete(Origen);
      TFile.Delete(Destino);
    end;
    Assert.IsTrue(Alm.Existe('no-existe-' + TGUID.NewGuid.ToString, Tam) = False);
  end;
end;

procedure TPruebasAlmacenServidor.VerificarGuardado;
var
  D: TDatosServidorS3;
  Id, Filas: Integer;
  Lanzo: Boolean;
begin
  D := Default(TDatosServidorS3);
  D.Etiqueta := 'prueba guardado';
  D.Endpoint := 'minio.local';
  D.Puerto := 9000;
  D.Bucket := 'archigenio';
  D.ClaveAcceso := 'usuario-servicio';
  D.Secreto := 'secreto-original-1';
  D.UsoHttps := True;
  Id := GuardarServidorS3(FConn, D);
  Assert.IsTrue(Id > 0, 'debe devolver el id nuevo');
  Assert.AreEqual('S3', VarToStr(FConn.ExecSQLScalar('SELECT tipo FROM cl_ftp_Server WHERE Idservidor = ' + IntToStr(Id))));
  Assert.AreEqual('minio.local', VarToStr(FConn.ExecSQLScalar('SELECT ipserver FROM cl_ftp_Server WHERE Idservidor = ' + IntToStr(Id))));
  Assert.AreEqual('archigenio', VarToStr(FConn.ExecSQLScalar('SELECT bucket FROM cl_ftp_Server WHERE Idservidor = ' + IntToStr(Id))));
  Assert.AreNotEqual('secreto-original-1', VarToStr(FConn.ExecSQLScalar('SELECT secreto_cifrado FROM cl_ftp_Server WHERE Idservidor = ' + IntToStr(Id))), 'el secreto no debe guardarse en claro');
  Assert.AreEqual('secreto-original-1', DescifrarSecreto(VarToStr(FConn.ExecSQLScalar('SELECT secreto_cifrado FROM cl_ftp_Server WHERE Idservidor = ' + IntToStr(Id)))));

  // Editar con secreto vacio conserva el anterior
  D.Id := Id;
  D.Bucket := 'otro-bucket';
  D.Secreto := '';
  Assert.AreEqual(Id, GuardarServidorS3(FConn, D));
  Assert.AreEqual('otro-bucket', VarToStr(FConn.ExecSQLScalar('SELECT bucket FROM cl_ftp_Server WHERE Idservidor = ' + IntToStr(Id))));
  Assert.AreEqual('secreto-original-1', DescifrarSecreto(VarToStr(FConn.ExecSQLScalar('SELECT secreto_cifrado FROM cl_ftp_Server WHERE Idservidor = ' + IntToStr(Id)))));
  // Editar con secreto nuevo lo reemplaza
  D.Secreto := 'secreto-nuevo-2';
  GuardarServidorS3(FConn, D);
  Assert.AreEqual('secreto-nuevo-2', DescifrarSecreto(VarToStr(FConn.ExecSQLScalar('SELECT secreto_cifrado FROM cl_ftp_Server WHERE Idservidor = ' + IntToStr(Id)))));

  // Datos incompletos: no escribe
  Filas := Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM cl_ftp_Server'));
  D := Default(TDatosServidorS3);
  D.Etiqueta := 'prueba guardado';
  D.Endpoint := '';
  D.Puerto := 9000;
  D.Bucket := 'b';
  D.ClaveAcceso := 'u';
  D.Secreto := 's';
  Lanzo := False;
  try
    GuardarServidorS3(FConn, D);
  except
    on EAlmacen do Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'endpoint vacio debe lanzar EAlmacen');
  // Alta sin secreto
  D.Endpoint := 'h';
  D.Secreto := '';
  Lanzo := False;
  try
    GuardarServidorS3(FConn, D);
  except
    on EAlmacen do Lanzo := True;
  end;
  Assert.IsTrue(Lanzo, 'alta sin secreto debe lanzar EAlmacen');
  Assert.AreEqual(Filas, Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM cl_ftp_Server')), 'no debe escribir filas');
end;

procedure TPruebasAlmacenServidor.SqlServer_Todo;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  VerificarTodo;
  VerificarGuardado;
end;

procedure TPruebasAlmacenServidor.Access_Todo;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  VerificarTodo;
  VerificarGuardado;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasAlmacenServidor);

end.
