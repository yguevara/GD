unit UPruebasDepuracionFicheros;

{ Pruebas del retiro de ficheros digitales de una depuracion (UDepuracionFicheros),
  contra SQL Server (se omiten sin ARCHIGENIO_TEST_DB) y con un almacen simulado. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UAlcance, UAlmacenFicheros,
  UDepuracionFicheros;

type
  [TestFixture]
  TPruebasDepuracionFicheros = class
  private
    FConn: TFDConnection;
    FNodo: TClaveNodo;
    FFalla: Boolean;
    function Conectar: Boolean;
    function Fabrica: TFabricaAlmacenRetiro;
    function ProcesoEnCierre(Paso: Integer): Integer;
    procedure Fichero(N, IdHijo: Integer; const Nombre: string;
      const UrlRaiz: string = 's3://1/');
    function EstadoDe(IdProceso: Integer; const Nombre: string): string;
  public
    [SetupFixture]
    procedure Preparar;
    [TearDownFixture]
    procedure Limpiar;
    [Setup]
    procedure LimpiarFilas;
    [Test]
    procedure CopiarTraeSoloLosFicherosDeLasUnidadesActivasYEsIdempotente;
    [Test]
    procedure RetirarDejaUnEstadoPorFicheroYUnFalloNoDetieneAlResto;
    [Test]
    procedure ReintentarSoloTocaLosQueFallaron;
    [Test]
    procedure ConfirmarRetiroManualSoloPasaLDeSoloLecturaAM;
    [Test]
    procedure NoSeRetiraFueraDelPasoDeCierre;
    [Test]
    procedure RetiroRealContraUnServidorS3;
    [Test]
    procedure UnFicheroDeFtpNuncaSeDaPorInexistenteVaASoloLectura;
    [Test]
    procedure UnFicheroConErrorSinSolucionSePuedeConfirmarARetiradoAMano;
    [Test]
    procedure CerrarExigeLosFicherosResueltosYSinFicherosCierra;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt,
  FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, System.Classes, System.IOUtils, UCandados, UEsquemaProcesos,
  UDepuracionDatos, UPruebasApoyoDepuracion, UAlmacenS3, UAlmacenServidor;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  USUARIO = '__prueba__';
  COD = 'ZZPD2';

type
  { Almacen simulado: 'falta.pdf' no existe, 'ftp.pdf' es de solo lectura y
    'falla.pdf' falla mientras Falla sea True. }
  TAlmacenFalso = class(TInterfacedObject, IAlmacenFicheros)
  private
    FNombre: string;
    FFalla: Boolean;
  public
    constructor Create(const Nombre: string; Falla: Boolean);
    function Subir(const Local, Clave: string; Progreso: TProgresoEvento): TResultadoSubida;
    procedure Descargar(const Clave, Local: string; Progreso: TProgresoEvento);
    function Existe(const Clave: string; out Tamano: Int64): Boolean;
    procedure Borrar(const Clave: string);
    function UrlTemporal(const Clave: string; Segundos: Integer): string;
  end;

constructor TAlmacenFalso.Create(const Nombre: string; Falla: Boolean);
begin
  inherited Create;
  FNombre := Nombre;
  FFalla := Falla;
end;

function TAlmacenFalso.Subir(const Local, Clave: string;
  Progreso: TProgresoEvento): TResultadoSubida;
begin
  Result := Default(TResultadoSubida);
end;

procedure TAlmacenFalso.Descargar(const Clave, Local: string; Progreso: TProgresoEvento);
begin
end;

function TAlmacenFalso.Existe(const Clave: string; out Tamano: Int64): Boolean;
begin
  Tamano := 10;
  Result := FNombre <> 'falta.pdf';
end;

procedure TAlmacenFalso.Borrar(const Clave: string);
begin
  if FNombre = 'ftp.pdf' then
    raise EAlmacenSoloLectura.Create('El servidor FTP es de solo lectura.');
  if (FNombre = 'falla.pdf') and FFalla then
    raise EAlmacen.Create('No se pudo conectar con el almacen.');
end;

function TAlmacenFalso.UrlTemporal(const Clave: string; Segundos: Integer): string;
begin
  Result := '';
end;

procedure TPruebasDepuracionFicheros.Preparar;
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
  FNodo := SembrarSerieDepurable(FConn, COD, 5, 3, ArchivoCentralApoyo(FConn));
end;

procedure TPruebasDepuracionFicheros.LimpiarFilas;
begin
  if FConn = nil then
    Exit;
  FConn.ExecSQL('DELETE FROM tb_ssArchdigital WHERE Codigodoc LIKE ''PD-' + COD + '-%''');
  LimpiarDepuraciones(FConn, USUARIO);
  FFalla := True;
end;

procedure TPruebasDepuracionFicheros.Limpiar;
begin
  if FConn <> nil then
  try
    FConn.ExecSQL('DELETE FROM tb_ssArchdigital WHERE Codigodoc LIKE ''PD-' + COD + '-%''');
    LimpiarDepuraciones(FConn, USUARIO);
    LimpiarSerieDepurable(FConn);
  finally
    FreeAndNil(FConn);
  end;
end;

function TPruebasDepuracionFicheros.Conectar: Boolean;
begin
  Result := FConn <> nil;
  if not Result then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
end;

function TPruebasDepuracionFicheros.Fabrica: TFabricaAlmacenRetiro;
begin
  Result := function(const UrlRaiz, Path, Nombre: string;
    out Clave: string): IAlmacenFicheros
    begin
      Clave := Path + Nombre;
      Result := TAlmacenFalso.Create(Nombre, FFalla);
    end;
end;

{ Depuracion en el paso dado, estado en curso, con el documento 1 como unidad activa. }
function TPruebasDepuracionFicheros.ProcesoEnCierre(Paso: Integer): Integer;
begin
  Result := SembrarDepuracion(FConn, DocumentoDeSerie(FNodo, COD, 1), Paso, 'C', True,
    USUARIO);
end;

{ Fichero IdHijo del documento N de la serie sembrada. }
procedure TPruebasDepuracionFicheros.Fichero(N, IdHijo: Integer; const Nombre: string;
  const UrlRaiz: string);
var
  U: TUnidadDoc;
begin
  U := DocumentoDeSerie(FNodo, COD, N);
  FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, idhijo, nombre, urlraiz, path) VALUES (:e, :i, :s, :f, :v, :c, :h, :n, ' +
    ':u, ''docs/'')',
    [U.IdEstructura, U.Id, U.CodSubs, U.Fecha, U.Version, U.CodigoDoc, IdHijo, Nombre,
     UrlRaiz],
    [ftString, ftInteger, ftString, ftDateTime, ftString, ftString, ftInteger, ftString,
     ftString]);
end;

function TPruebasDepuracionFicheros.EstadoDe(IdProceso: Integer; const Nombre: string): string;
begin
  Result := Trim(VarToStr(FConn.ExecSQLScalar('SELECT Estado FROM prc_fichero_retiro WHERE ' +
    'IdProceso = :p AND Nombre = :n', [IdProceso, Nombre])));
end;

procedure TPruebasDepuracionFicheros.CopiarTraeSoloLosFicherosDeLasUnidadesActivasYEsIdempotente;
var
  Id: Integer;
begin
  if not Conectar then Exit;
  Id := ProcesoEnCierre(5);
  Fichero(1, 900001, 'a.pdf');
  Fichero(1, 900002, 'b.pdf');
  Fichero(2, 900003, 'otro-documento.pdf');
  Assert.AreEqual(2, CopiarFicherosAlRetiro(FConn, Id));
  Assert.AreEqual(0, CopiarFicherosAlRetiro(FConn, Id), 'no duplica');
  Assert.AreEqual(2, Length(FicherosDelRetiro(FConn, Id)));
  Assert.AreEqual('P', EstadoDe(Id, 'a.pdf'));
  Assert.AreEqual(2, FicherosSinResolver(FConn, Id));
end;

procedure TPruebasDepuracionFicheros.RetirarDejaUnEstadoPorFicheroYUnFalloNoDetieneAlResto;
var
  Id: Integer;
  R: TResumenRetiro;
begin
  if not Conectar then Exit;
  Id := ProcesoEnCierre(5);
  Fichero(1, 900001, 'ok.pdf');
  Fichero(1, 900002, 'falta.pdf');
  Fichero(1, 900003, 'ftp.pdf');
  Fichero(1, 900004, 'falla.pdf');
  Fichero(1, 900005, 'zzfinal.pdf');   // va despues del que falla
  CopiarFicherosAlRetiro(FConn, Id);
  R := RetirarFicheros(FConn, Id, Fabrica(), USUARIO);
  Assert.AreEqual(2, R.Retirados);
  Assert.AreEqual(1, R.YaNoExistian);
  Assert.AreEqual(1, R.SoloLectura);
  Assert.AreEqual(1, R.Errores);
  Assert.AreEqual('R', EstadoDe(Id, 'ok.pdf'));
  Assert.AreEqual('N', EstadoDe(Id, 'falta.pdf'));
  Assert.AreEqual('L', EstadoDe(Id, 'ftp.pdf'));
  Assert.AreEqual('E', EstadoDe(Id, 'falla.pdf'));
  Assert.AreEqual('R', EstadoDe(Id, 'zzfinal.pdf'), 'siguio despues del fallo');
  Assert.IsTrue(Pos('conectar', VarToStr(FConn.ExecSQLScalar('SELECT Mensaje FROM ' +
    'prc_fichero_retiro WHERE IdProceso = :p AND Nombre = ''falla.pdf''', [Id]))) > 0,
    'el error queda escrito');
end;

procedure TPruebasDepuracionFicheros.ReintentarSoloTocaLosQueFallaron;
var
  Id: Integer;
  R: TResumenRetiro;
begin
  if not Conectar then Exit;
  Id := ProcesoEnCierre(5);
  Fichero(1, 900001, 'ok.pdf');
  Fichero(1, 900002, 'ftp.pdf');
  Fichero(1, 900003, 'falla.pdf');
  CopiarFicherosAlRetiro(FConn, Id);
  RetirarFicheros(FConn, Id, Fabrica(), USUARIO);
  FFalla := False;   // el almacen vuelve
  R := RetirarFicheros(FConn, Id, Fabrica(), USUARIO);
  Assert.AreEqual(1, R.Retirados, 'solo el que fallo');
  Assert.AreEqual(0, R.SoloLectura, 'los de solo lectura no se reprocesan');
  Assert.AreEqual('R', EstadoDe(Id, 'falla.pdf'));
  Assert.AreEqual('L', EstadoDe(Id, 'ftp.pdf'));
  R := RetirarFicheros(FConn, Id, Fabrica(), USUARIO);
  Assert.AreEqual(0, R.Retirados + R.YaNoExistian + R.SoloLectura + R.Errores, 'inocuo');
end;

procedure TPruebasDepuracionFicheros.ConfirmarRetiroManualSoloPasaLDeSoloLecturaAM;
var
  Id: Integer;
  Lista: TArray<TFicheroRetiro>;
  F: TFicheroRetiro;
begin
  if not Conectar then Exit;
  Id := ProcesoEnCierre(5);
  Fichero(1, 900001, 'ok.pdf');
  Fichero(1, 900002, 'ftp.pdf');
  CopiarFicherosAlRetiro(FConn, Id);
  RetirarFicheros(FConn, Id, Fabrica(), USUARIO);
  for F in FicherosDelRetiro(FConn, Id) do
    if F.Nombre = 'ok.pdf' then
      Assert.IsFalse(ConfirmarRetiroManual(FConn, Id, F, USUARIO), 'ya estaba R')
    else
      Assert.IsTrue(ConfirmarRetiroManual(FConn, Id, F, USUARIO));
  Assert.AreEqual('M', EstadoDe(Id, 'ftp.pdf'));
  Assert.AreEqual('R', EstadoDe(Id, 'ok.pdf'));
  Lista := FicherosDelRetiro(FConn, Id);
  Assert.AreEqual(2, Length(Lista));
  Assert.AreEqual(0, FicherosSinResolver(FConn, Id));
end;

procedure TPruebasDepuracionFicheros.UnFicheroDeFtpNuncaSeDaPorInexistenteVaASoloLectura;
var
  Id: Integer;
begin
  if not Conectar then Exit;
  Id := ProcesoEnCierre(5);
  // el FTP no distingue 'no existe' de un error en Existe: se retira siempre a mano
  Fichero(1, 900001, 'falta.pdf', '/ftp/');
  CopiarFicherosAlRetiro(FConn, Id);
  RetirarFicheros(FConn, Id, Fabrica(), USUARIO);
  Assert.AreEqual('L', EstadoDe(Id, 'falta.pdf'));
  Assert.IsFalse(CerrarDepuracion(FConn, Id, USUARIO));
end;

procedure TPruebasDepuracionFicheros.UnFicheroConErrorSinSolucionSePuedeConfirmarARetiradoAMano;
var
  Id: Integer;
  F: TFicheroRetiro;
begin
  if not Conectar then Exit;
  Id := ProcesoEnCierre(5);
  Fichero(1, 900001, 'falla.pdf');
  CopiarFicherosAlRetiro(FConn, Id);
  RetirarFicheros(FConn, Id, Fabrica(), USUARIO);
  Assert.AreEqual('E', EstadoDe(Id, 'falla.pdf'));
  // el servidor ya no existe o no hay forma: se retira a mano y se confirma
  for F in FicherosDelRetiro(FConn, Id) do
    Assert.IsTrue(ConfirmarRetiroManual(FConn, Id, F, USUARIO));
  Assert.AreEqual('M', EstadoDe(Id, 'falla.pdf'));
  Assert.IsTrue(CerrarDepuracion(FConn, Id, USUARIO));
end;

{ Contra un servidor S3 real (ARCHIGENIO_TEST_S3 = host:puerto|usuario|secreto): sube
  ficheros, los retira con RetirarFicheros y comprueba que desaparecen del bucket. }
procedure TPruebasDepuracionFicheros.RetiroRealContraUnServidorS3;
var
  V: TArray<string>;
  H: TArray<string>;
  D: TDatosServidorS3;
  IdSrv, Id, I: Integer;
  S3: TAlmacenS3;
  Ref: IAlmacenFicheros;
  Local, Raiz: string;
  Tam: Int64;
  Fab: TFabricaAlmacenRetiro;
begin
  if not Conectar then Exit;
  V := GetEnvironmentVariable('ARCHIGENIO_TEST_S3').Split(['|']);
  if Length(V) <> 3 then
  begin
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_S3');
    Exit;
  end;
  H := V[0].Split([':']);
  D := Default(TDatosServidorS3);
  D.Etiqueta := '__prueba__';
  D.Endpoint := H[0];
  D.Puerto := StrToInt(H[1]);
  D.Bucket := 'archigenio-prueba';
  D.ClaveAcceso := V[1];
  D.Secreto := V[2];
  IdSrv := GuardarServidorS3(FConn, D);
  S3 := TAlmacenS3.Create(V[0], 'archigenio-prueba', V[1], V[2], '', False);
  Ref := S3;
  Local := ChangeFileExt(ParamStr(0), '.tmp');
  try
    S3.AsegurarBucket;
    with TStringList.Create do
    try
      Add('contenido de prueba');
      SaveToFile(Local);
    finally
      Free;
    end;
    Raiz := 's3://' + IntToStr(IdSrv) + '/';
    S3.Subir(Local, 'docs-f4c/real1.pdf', nil);
    S3.Subir(Local, 'docs-f4c/real2.pdf', nil);
    Assert.IsTrue(S3.Existe('docs-f4c/real1.pdf', Tam), 'subido');
    Id := ProcesoEnCierre(5);
    Fichero(1, 900001, 'real1.pdf', Raiz);
    Fichero(1, 900002, 'real2.pdf', Raiz);
    Fichero(1, 900003, 'ausente.pdf', Raiz);                 // nunca se subio
    Fichero(1, 900004, 'servidor-inexistente.pdf', 's3://999999/');
    FConn.ExecSQL('UPDATE tb_ssArchdigital SET path = ''docs-f4c/'' WHERE Codigodoc LIKE ' +
      '''PD-' + COD + '-%''');
    CopiarFicherosAlRetiro(FConn, Id);
    Fab := function(const UrlRaiz, Path, Nombre: string; out Clave: string): IAlmacenFicheros
      begin
        Result := AlmacenParaFichero(FConn, UrlRaiz, 0, Clave, Path, Nombre);
      end;
    RetirarFicheros(FConn, Id, Fab, USUARIO);
    Assert.AreEqual('R', EstadoDe(Id, 'real1.pdf'));
    Assert.AreEqual('R', EstadoDe(Id, 'real2.pdf'));
    Assert.AreEqual('N', EstadoDe(Id, 'ausente.pdf'));
    Assert.AreEqual('E', EstadoDe(Id, 'servidor-inexistente.pdf'));
    Assert.IsFalse(S3.Existe('docs-f4c/real1.pdf', Tam), 'real1 ya no esta en el bucket');
    Assert.IsFalse(S3.Existe('docs-f4c/real2.pdf', Tam), 'real2 ya no esta en el bucket');
    Assert.IsFalse(CerrarDepuracion(FConn, Id, USUARIO), 'el error bloquea el cierre');
    // reintentar no cambia nada (el servidor sigue sin existir) y no toca los resueltos
    RetirarFicheros(FConn, Id, Fab, USUARIO);
    Assert.AreEqual('E', EstadoDe(Id, 'servidor-inexistente.pdf'));
    // salida: confirmar a mano
    for I := 0 to High(FicherosDelRetiro(FConn, Id)) do
      ConfirmarRetiroManual(FConn, Id, FicherosDelRetiro(FConn, Id)[I], USUARIO);
    Assert.AreEqual('M', EstadoDe(Id, 'servidor-inexistente.pdf'));
    Assert.IsTrue(CerrarDepuracion(FConn, Id, USUARIO));
  finally
    if TFile.Exists(Local) then
      TFile.Delete(Local);
    FConn.ExecSQL('DELETE FROM cl_ftp_Server WHERE Idservidor = :i', [IdSrv]);
  end;
end;

procedure TPruebasDepuracionFicheros.NoSeRetiraFueraDelPasoDeCierre;
var
  Id: Integer;
begin
  if not Conectar then Exit;
  Id := ProcesoEnCierre(4);
  Fichero(1, 900001, 'ok.pdf');
  CopiarFicherosAlRetiro(FConn, Id);
  Assert.WillRaise(
    procedure
    begin
      RetirarFicheros(FConn, Id, Fabrica(), USUARIO);
    end, EArgumentException);
  Assert.AreEqual('P', EstadoDe(Id, 'ok.pdf'));
end;

procedure TPruebasDepuracionFicheros.CerrarExigeLosFicherosResueltosYSinFicherosCierra;
var
  Id, Id2: Integer;
begin
  if not Conectar then Exit;
  Id := ProcesoEnCierre(5);
  Fichero(1, 900001, 'ok.pdf');
  Fichero(1, 900002, 'ftp.pdf');
  CopiarFicherosAlRetiro(FConn, Id);
  Assert.IsFalse(CerrarDepuracion(FConn, Id, USUARIO), 'con pendientes no cierra');
  RetirarFicheros(FConn, Id, Fabrica(), USUARIO);
  Assert.IsFalse(CerrarDepuracion(FConn, Id, USUARIO), 'el de solo lectura sin confirmar tampoco');
  FConn.ExecSQL('UPDATE prc_fichero_retiro SET Estado = ''M'' WHERE IdProceso = :p AND ' +
    'Estado = ''L''', [Id]);
  Assert.IsTrue(CerrarDepuracion(FConn, Id, USUARIO));
  // sin ficheros digitales cierra como siempre
  FConn.ExecSQL('DELETE FROM tb_ssArchdigital WHERE Codigodoc LIKE ''PD-' + COD + '-%''');
  Id2 := ProcesoEnCierre(5);
  Assert.IsTrue(CerrarDepuracion(FConn, Id2, USUARIO));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasDepuracionFicheros);

end.
