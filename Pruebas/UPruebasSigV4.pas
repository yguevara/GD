unit UPruebasSigV4;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasSigV4 = class
  public
    [Test]
    procedure UriEncode_CaracteresEspeciales;
    [Test]
    procedure UriEncode_SinBarra_CodificaLaBarra;
    [Test]
    procedure HexSha256_Vacio;
    [Test]
    procedure UrlPrefirmada_VectorDeAws;
    [Test]
    procedure FirmarPeticion_FormaDeLaCabecera;
    [Test]
    procedure ClaveObjeto_Contrato;
    [Test]
    procedure EsUrlRaizS3_Casos;
    [Test]
    procedure UrlRaizS3_Forma;
    [Test]
    procedure NormalizarRutaFtp_Casos;
    [Test]
    procedure ParsearRutaS3_Casos;
  end;

implementation

uses
  System.SysUtils, System.DateUtils, USigV4, UAlmacenFicheros;

procedure TPruebasSigV4.UriEncode_CaracteresEspeciales;
begin
  Assert.AreEqual('A.4.3/doc%201%20%C3%B1%2B%23%25.txt',
    UriEncode('A.4.3/doc 1 ' + Char($F1) + '+#%.txt', True));
end;

procedure TPruebasSigV4.UriEncode_SinBarra_CodificaLaBarra;
begin
  Assert.AreEqual('A.4.3%2F', UriEncode('A.4.3/', False));
end;

procedure TPruebasSigV4.HexSha256_Vacio;
begin
  Assert.AreEqual('e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    HexSha256(nil));
end;

procedure TPruebasSigV4.UrlPrefirmada_VectorDeAws;
var
  U: string;
begin
  // Vector de la documentacion de AWS (Authenticating Requests: Using Query Parameters)
  U := UrlPrefirmada('GET', '/test.txt', 'examplebucket.s3.amazonaws.com',
    'us-east-1', 'AKIAIOSFODNN7EXAMPLE', 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
    EncodeDateTime(2013, 5, 24, 0, 0, 0, 0), 86400, True);
  Assert.IsTrue(U.StartsWith('https://examplebucket.s3.amazonaws.com/test.txt?'), U);
  Assert.IsTrue(U.Contains('X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request'), U);
  Assert.IsTrue(U.Contains('X-Amz-Expires=86400'), U);
  Assert.IsTrue(U.EndsWith('X-Amz-Signature=aeeed9bbccd4d02ee5c0109b86d86835f995330da4c265957d157751f604d404'), U);
end;

procedure TPruebasSigV4.FirmarPeticion_FormaDeLaCabecera;
var
  A, Fecha: string;
begin
  A := FirmarPeticion('GET', '/b/k', 'list-type=2', '127.0.0.1:9100', 'us-east-1',
    'AK', 'SK', HexSha256(nil), EncodeDateTime(2013, 5, 24, 0, 0, 0, 0), Fecha);
  Assert.AreEqual('20130524T000000Z', Fecha);
  Assert.IsTrue(A.StartsWith('AWS4-HMAC-SHA256 Credential=AK/20130524/us-east-1/s3/aws4_request, ' +
    'SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature='), A);
  Assert.AreEqual(Length('AWS4-HMAC-SHA256 Credential=AK/20130524/us-east-1/s3/aws4_request, ' +
    'SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=') + 64, Length(A));
  Assert.IsFalse(A.Contains('SK'), 'el secreto no debe aparecer');
end;

procedure TPruebasSigV4.ClaveObjeto_Contrato;
begin
  Assert.AreEqual('SGD/104/074/P-001/1/3-plano ' + Char($F1) + '.pdf',
    ClaveObjeto('SGD', 104, '074', 'P-001', '1', 3, 'plano ' + Char($F1) + '.pdf'));
end;

procedure TPruebasSigV4.EsUrlRaizS3_Casos;
var
  N: Integer;
begin
  Assert.IsTrue(EsUrlRaizS3('s3://7/', N));
  Assert.AreEqual(7, N);
  Assert.IsFalse(EsUrlRaizS3('/docs/', N));
  Assert.IsFalse(EsUrlRaizS3('', N));
  Assert.IsFalse(EsUrlRaizS3('s3://x/', N));
end;

procedure TPruebasSigV4.UrlRaizS3_Forma;
begin
  Assert.AreEqual('s3://7/', UrlRaizS3(7));
end;

procedure TPruebasSigV4.NormalizarRutaFtp_Casos;
begin
  Assert.AreEqual('a/b/c', NormalizarRutaFtp('a\\b//c'));
  Assert.AreEqual('/x/y.pdf', NormalizarRutaFtp('\x\\y.pdf'));
end;

procedure TPruebasSigV4.ParsearRutaS3_Casos;
var
  N: Integer;
  K: string;
begin
  Assert.IsTrue(ParsearRutaS3('s3://7/\Est\Serie\a b.pdf', N, K));
  Assert.AreEqual(7, N);
  Assert.AreEqual('Est/Serie/a b.pdf', K);
  // ya colapsada por los llamadores (// -> /)
  Assert.IsTrue(ParsearRutaS3('s3:/12/Est/x.pdf', N, K));
  Assert.AreEqual(12, N);
  Assert.AreEqual('Est/x.pdf', K);
  Assert.IsTrue(ParsearRutaS3('s3://7/', N, K));
  Assert.AreEqual('', K);
  // el prefijo no distingue mayusculas (igual que EsUrlRaizS3)
  Assert.IsTrue(ParsearRutaS3('S3://7/A/x.pdf', N, K));
  Assert.AreEqual(7, N);
  Assert.AreEqual('A/x.pdf', K);
  Assert.IsFalse(ParsearRutaS3('/docs/x.pdf', N, K));
  Assert.IsFalse(ParsearRutaS3('s3://x/y', N, K));
  Assert.IsFalse(ParsearRutaS3('', N, K));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasSigV4);

end.
