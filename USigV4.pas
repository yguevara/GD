unit USigV4;

{ Firma AWS Signature V4 para S3/MinIO con direccionamiento por ruta.
  Solo RTL (sin VCL ni UDM) para poder probarla desde una consola. }

interface

uses
  System.SysUtils;

function UriEncode(const S: string; DejarBarra: Boolean): string;
function HexSha256(const B: TBytes): string;
{ Valor de la cabecera Authorization. Ahora debe venir en UTC. Fecha devuelve
  el valor de x-amz-date (yyyymmddThhnnssZ). Firma host, x-amz-content-sha256
  y x-amz-date. Consulta ya debe venir canonica (ordenada y codificada). }
function FirmarPeticion(const Metodo, Ruta, Consulta, Host, Region, AccessKey,
  SecretKey, HashCuerpo: string; Ahora: TDateTime; out Fecha: string): string;
function UrlPrefirmada(const Metodo, Ruta, Host, Region, AccessKey, SecretKey: string;
  Ahora: TDateTime; Segundos: Integer; Https: Boolean): string;

implementation

uses
  System.Hash;

function Hex(const B: TBytes): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(B) do
    Result := Result + LowerCase(IntToHex(B[I], 2));
end;

function Hmac(const Clave: TBytes; const Datos: string): TBytes;
begin
  Result := THashSHA2.GetHMACAsBytes(TEncoding.UTF8.GetBytes(Datos), Clave, SHA256);
end;

function HexSha256(const B: TBytes): string;
var
  H: THashSHA2;
begin
  H := THashSHA2.Create(SHA256);
  if Length(B) > 0 then
    H.Update(B);
  Result := Hex(H.HashAsBytes);
end;

function UriEncode(const S: string; DejarBarra: Boolean): string;
var
  B: TBytes;
  I: Integer;
  C: Byte;
begin
  Result := '';
  B := TEncoding.UTF8.GetBytes(S);
  for I := 0 to High(B) do
  begin
    C := B[I];
    if ((C >= 48) and (C <= 57)) or ((C >= 65) and (C <= 90)) or
      ((C >= 97) and (C <= 122)) or (C = 45) or (C = 46) or (C = 95) or (C = 126) or
      ((C = 47) and DejarBarra) then
      Result := Result + Char(C)
    else
      Result := Result + '%' + IntToHex(C, 2);
  end;
end;

function ClaveFirma(const SecretKey, Dia, Region: string): TBytes;
begin
  Result := Hmac(Hmac(Hmac(Hmac(TEncoding.UTF8.GetBytes('AWS4' + SecretKey), Dia),
    Region), 's3'), 'aws4_request');
end;

function FirmarPeticion(const Metodo, Ruta, Consulta, Host, Region, AccessKey,
  SecretKey, HashCuerpo: string; Ahora: TDateTime; out Fecha: string): string;
var
  Dia, Canon, Alcance, AFirmar: string;
begin
  Fecha := FormatDateTime('yyyymmdd"T"hhnnss"Z"', Ahora);
  Dia := Copy(Fecha, 1, 8);
  Canon := Metodo + #10 + UriEncode(Ruta, True) + #10 + Consulta + #10 +
    'host:' + Host + #10 + 'x-amz-content-sha256:' + HashCuerpo + #10 +
    'x-amz-date:' + Fecha + #10 + #10 +
    'host;x-amz-content-sha256;x-amz-date' + #10 + HashCuerpo;
  Alcance := Dia + '/' + Region + '/s3/aws4_request';
  AFirmar := 'AWS4-HMAC-SHA256' + #10 + Fecha + #10 + Alcance + #10 +
    HexSha256(TEncoding.UTF8.GetBytes(Canon));
  Result := 'AWS4-HMAC-SHA256 Credential=' + AccessKey + '/' + Alcance +
    ', SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=' +
    Hex(Hmac(ClaveFirma(SecretKey, Dia, Region), AFirmar));
end;

function UrlPrefirmada(const Metodo, Ruta, Host, Region, AccessKey, SecretKey: string;
  Ahora: TDateTime; Segundos: Integer; Https: Boolean): string;
var
  Fecha, Dia, Alcance, Consulta, Canon, AFirmar, Esquema: string;
begin
  Fecha := FormatDateTime('yyyymmdd"T"hhnnss"Z"', Ahora);
  Dia := Copy(Fecha, 1, 8);
  Alcance := Dia + '/' + Region + '/s3/aws4_request';
  Consulta := 'X-Amz-Algorithm=AWS4-HMAC-SHA256' +
    '&X-Amz-Credential=' + UriEncode(AccessKey + '/' + Alcance, False) +
    '&X-Amz-Date=' + Fecha +
    '&X-Amz-Expires=' + IntToStr(Segundos) +
    '&X-Amz-SignedHeaders=host';
  Canon := Metodo + #10 + UriEncode(Ruta, True) + #10 + Consulta + #10 +
    'host:' + Host + #10 + #10 + 'host' + #10 + 'UNSIGNED-PAYLOAD';
  AFirmar := 'AWS4-HMAC-SHA256' + #10 + Fecha + #10 + Alcance + #10 +
    HexSha256(TEncoding.UTF8.GetBytes(Canon));
  if Https then
    Esquema := 'https'
  else
    Esquema := 'http';
  Result := Esquema + '://' + Host + UriEncode(Ruta, True) + '?' + Consulta +
    '&X-Amz-Signature=' + Hex(Hmac(ClaveFirma(SecretKey, Dia, Region), AFirmar));
end;

end.
