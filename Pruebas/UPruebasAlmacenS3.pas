unit UPruebasAlmacenS3;

{ Pruebas contra un servidor S3/MinIO real. Se activan con la variable de
  entorno ARCHIGENIO_TEST_S3 = host:puerto|usuario|secreto y se omiten si falta. }

interface

uses
  DUnitX.TestFramework, UAlmacenS3, UAlmacenFicheros;

type
  [TestFixture]
  TPruebasAlmacenS3 = class
  private
    FAlmacen: TAlmacenS3;
    FRef: IAlmacenFicheros; // mantiene viva la instancia (cuenta de referencias)
    FPrefijo: string;
    FTemporales: array of string;
    FEndpoint, FUsuario, FSecreto: string;
    function Disponible: Boolean;
    function Temporal(Tamano: Integer): string;
    function Clave(const Nombre: string): string;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SubirDescargar_UnMega_MismoSha;
    [Test]
    procedure Clave_ConEspaciosYSimbolos_IdaYVuelta;
    [Test]
    procedure CeroBytes_SubeYExiste;
    [Test]
    procedure Existe_Inexistente_False;
    [Test]
    procedure Borrar_LuegoNoExiste;
    [Test]
    procedure UrlTemporal_DescargaSinCabeceras;
    [Test]
    procedure Progreso_Crece_HastaElTotal;
    [Test]
    procedure Cancelar_Aborta_YNoDejaObjeto;
    [Test]
    procedure CredencialesMalas_NoRevelanElSecreto;
    [Test]
    procedure Subir_DevuelveMd5YTamano;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Hash, System.Net.HttpClient;

const
  BUCKET_PRUEBA = 'archigenio-prueba';

function TPruebasAlmacenS3.Disponible: Boolean;
var
  V: string;
  P: TArray<string>;
begin
  V := GetEnvironmentVariable('ARCHIGENIO_TEST_S3');
  P := V.Split(['|']);
  Result := Length(P) = 3;
  if Result then
  begin
    FEndpoint := P[0];
    FUsuario := P[1];
    FSecreto := P[2];
  end;
end;

procedure TPruebasAlmacenS3.Preparar;
begin
  FAlmacen := nil;
  FRef := nil;
  FPrefijo := 'pruebas/' + TGUID.NewGuid.ToString + '/';
  if Disponible then
  begin
    FAlmacen := TAlmacenS3.Create(FEndpoint, BUCKET_PRUEBA, FUsuario, FSecreto, '', False);
    FRef := FAlmacen;
    FAlmacen.AsegurarBucket;
  end;
end;

procedure TPruebasAlmacenS3.Limpiar;
var
  I: Integer;
begin
  for I := 0 to High(FTemporales) do
    if TFile.Exists(FTemporales[I]) then
      TFile.Delete(FTemporales[I]);
  FTemporales := nil;
  FRef := nil;
  FAlmacen := nil;
end;

function TPruebasAlmacenS3.Temporal(Tamano: Integer): string;
var
  F: TFileStream;
  B: TBytes;
  I: Integer;
begin
  Result := TPath.GetTempFileName;
  SetLength(FTemporales, Length(FTemporales) + 1);
  FTemporales[High(FTemporales)] := Result;
  F := TFileStream.Create(Result, fmCreate);
  try
    SetLength(B, Tamano);
    for I := 0 to Tamano - 1 do
      B[I] := Byte((I * 31 + 7) mod 251);
    if Tamano > 0 then
      F.WriteBuffer(B[0], Tamano);
  finally
    F.Free;
  end;
end;

function TPruebasAlmacenS3.Clave(const Nombre: string): string;
begin
  Result := FPrefijo + Nombre;
end;

procedure TPruebasAlmacenS3.SubirDescargar_UnMega_MismoSha;
var
  Origen, Destino: string;
  I: IAlmacenFicheros;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  I := FAlmacen;
  Origen := Temporal(1024 * 1024);
  Destino := Temporal(0);
  I.Subir(Origen, Clave('a.bin'), nil);
  I.Descargar(Clave('a.bin'), Destino, nil);
  Assert.AreEqual(THashSHA2.GetHashStringFromFile(Origen), THashSHA2.GetHashStringFromFile(Destino));
  I.Borrar(Clave('a.bin'));
end;

procedure TPruebasAlmacenS3.Clave_ConEspaciosYSimbolos_IdaYVuelta;
var
  Origen, Destino, K: string;
  I: IAlmacenFicheros;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  I := FAlmacen;
  K := Clave('A.4.3/doc 1 ' + Char($F1) + Char($E1) + ' +#%.txt');
  Origen := Temporal(2000);
  Destino := Temporal(0);
  I.Subir(Origen, K, nil);
  I.Descargar(K, Destino, nil);
  Assert.AreEqual(THashSHA2.GetHashStringFromFile(Origen), THashSHA2.GetHashStringFromFile(Destino));
  I.Borrar(K);
end;

procedure TPruebasAlmacenS3.CeroBytes_SubeYExiste;
var
  Origen: string;
  I: IAlmacenFicheros;
  Tam: Int64;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  I := FAlmacen;
  Origen := Temporal(0);
  I.Subir(Origen, Clave('vacio.bin'), nil);
  Assert.IsTrue(I.Existe(Clave('vacio.bin'), Tam));
  Assert.AreEqual(Int64(0), Tam);
  I.Borrar(Clave('vacio.bin'));
end;

procedure TPruebasAlmacenS3.Existe_Inexistente_False;
var
  Tam: Int64;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  Assert.IsFalse((FAlmacen as IAlmacenFicheros).Existe(Clave('no-existe.bin'), Tam));
end;

procedure TPruebasAlmacenS3.Borrar_LuegoNoExiste;
var
  I: IAlmacenFicheros;
  Tam: Int64;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  I := FAlmacen;
  I.Subir(Temporal(10), Clave('b.bin'), nil);
  Assert.IsTrue(I.Existe(Clave('b.bin'), Tam));
  I.Borrar(Clave('b.bin'));
  Assert.IsFalse(I.Existe(Clave('b.bin'), Tam));
end;

procedure TPruebasAlmacenS3.UrlTemporal_DescargaSinCabeceras;
var
  I: IAlmacenFicheros;
  Cli: THTTPClient;
  R: IHTTPResponse;
  Origen: string;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  I := FAlmacen;
  Origen := Temporal(500);
  I.Subir(Origen, Clave('t u.bin'), nil);
  Cli := THTTPClient.Create;
  try
    R := Cli.Get(I.UrlTemporal(Clave('t u.bin'), 60));
    Assert.AreEqual(200, R.StatusCode);
    Assert.AreEqual(Int64(500), R.ContentStream.Size);
  finally
    Cli.Free;
  end;
  I.Borrar(Clave('t u.bin'));
end;

procedure TPruebasAlmacenS3.Progreso_Crece_HastaElTotal;
var
  I: IAlmacenFicheros;
  Ultimo, Total: Int64;
  Decrece: Boolean;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  I := FAlmacen;
  Ultimo := -1;
  Total := 0;
  Decrece := False;
  I.Subir(Temporal(3 * 1024 * 1024), Clave('p.bin'),
    procedure(Hecho, Tot: Int64; var Cancelar: Boolean)
    begin
      if Hecho < Ultimo then
        Decrece := True;
      Ultimo := Hecho;
      Total := Tot;
    end);
  Assert.IsFalse(Decrece);
  Assert.AreEqual(Int64(3 * 1024 * 1024), Total);
  Assert.AreEqual(Total, Ultimo);
  I.Borrar(Clave('p.bin'));
end;

procedure TPruebasAlmacenS3.Cancelar_Aborta_YNoDejaObjeto;
var
  I: IAlmacenFicheros;
  Tam: Int64;
  Cancelado: Boolean;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  I := FAlmacen;
  Cancelado := False;
  try
    I.Subir(Temporal(3 * 1024 * 1024), Clave('c.bin'),
      procedure(Hecho, Tot: Int64; var Cancelar: Boolean)
      begin
        Cancelar := True;
      end);
  except
    on EAlmacen do
      Cancelado := True;
  end;
  Assert.IsTrue(Cancelado, 'debia lanzar EAlmacen');
  Assert.IsFalse(I.Existe(Clave('c.bin'), Tam));
end;

procedure TPruebasAlmacenS3.CredencialesMalas_NoRevelanElSecreto;
var
  A: IAlmacenFicheros;
  Mensaje: string;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  A := TAlmacenS3.Create(FEndpoint, BUCKET_PRUEBA, FUsuario, 'secreto-equivocado-123', '', False);
  Mensaje := '';
  try
    A.Subir(Temporal(10), Clave('x.bin'), nil);
  except
    on E: EAlmacen do
      Mensaje := E.Message;
  end;
  Assert.AreNotEqual('', Mensaje, 'debia fallar con EAlmacen');
  Assert.IsFalse(Mensaje.Contains('secreto-equivocado-123'));
  Assert.IsFalse(Mensaje.Contains(FSecreto));
end;

procedure TPruebasAlmacenS3.Subir_DevuelveMd5YTamano;
var
  I: IAlmacenFicheros;
  Origen: string;
  R: TResultadoSubida;
begin
  if not Disponible then Assert.Pass('sin ARCHIGENIO_TEST_S3');
  I := FAlmacen;
  Origen := Temporal(70000);
  R := I.Subir(Origen, Clave('m.bin'), nil);
  Assert.AreEqual(Int64(70000), R.Tamano);
  Assert.AreEqual(LowerCase(THashMD5.GetHashStringFromFile(Origen)), LowerCase(R.Md5));
  I.Borrar(Clave('m.bin'));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasAlmacenS3);

end.
