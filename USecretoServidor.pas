unit USecretoServidor;

{ Cifrado del secreto de acceso a MinIO/S3 antes de guardarlo en la base.
  AES-256 de CryptoAPI de Windows con clave derivada (SHA-256) de una constante
  de la aplicacion mas una sal aleatoria por valor. Evita el secreto en claro
  en la base; no protege frente a quien tenga el ejecutable y la base.
  Solo RTL + WinAPI, sin VCL ni UDM. }

interface

{ Devuelve 'v1:' + Base64(sal + cifrado) }
function CifrarSecreto(const Claro: string): string;
{ Devuelve '' ante un dato vacio, invalido o alterado; nunca lanza }
function DescifrarSecreto(const Cifrado: string): string;

implementation

uses
  Winapi.Windows, System.SysUtils, System.NetEncoding;

const
  PREFIJO = 'v1:';
  CONSTANTE = 'ArchiGenio.Servidor.S3.v1|EMSERGO';
  PROV_RSA_AES = 24;
  CRYPT_VERIFYCONTEXT = $F0000000;
  CALG_SHA_256 = $800C;
  CALG_AES_256 = $6610;
  LONG_SAL = 16;

function CryptAcquireContextW(out phProv: NativeUInt; pszContainer, pszProvider: PWideChar;
  dwProvType, dwFlags: DWORD): BOOL; stdcall; external 'advapi32.dll';
function CryptReleaseContext(hProv: NativeUInt; dwFlags: DWORD): BOOL; stdcall;
  external 'advapi32.dll';
function CryptCreateHash(hProv: NativeUInt; Algid: DWORD; hKey: NativeUInt; dwFlags: DWORD;
  out phHash: NativeUInt): BOOL; stdcall; external 'advapi32.dll';
function CryptHashData(hHash: NativeUInt; pbData: PByte; dwDataLen, dwFlags: DWORD): BOOL;
  stdcall; external 'advapi32.dll';
function CryptDestroyHash(hHash: NativeUInt): BOOL; stdcall; external 'advapi32.dll';
function CryptDeriveKey(hProv: NativeUInt; Algid: DWORD; hBaseData: NativeUInt;
  dwFlags: DWORD; out phKey: NativeUInt): BOOL; stdcall; external 'advapi32.dll';
function CryptDestroyKey(hKey: NativeUInt): BOOL; stdcall; external 'advapi32.dll';
function CryptEncrypt(hKey, hHash: NativeUInt; Final: BOOL; dwFlags: DWORD; pbData: PByte;
  var pdwDataLen: DWORD; dwBufLen: DWORD): BOOL; stdcall; external 'advapi32.dll';
function CryptDecrypt(hKey, hHash: NativeUInt; Final: BOOL; dwFlags: DWORD; pbData: PByte;
  var pdwDataLen: DWORD): BOOL; stdcall; external 'advapi32.dll';

{ Ejecuta Encriptar o Desencriptar con la clave derivada de la sal }
function Transformar(const Sal, Datos: TBytes; Cifrar: Boolean; out Res: TBytes): Boolean;
var
  Prov, Hash, Clave: NativeUInt;
  Semilla, Buf: TBytes;
  Largo: DWORD;
begin
  Result := False;
  Prov := 0;
  Hash := 0;
  Clave := 0;
  if not CryptAcquireContextW(Prov, nil, nil, PROV_RSA_AES, CRYPT_VERIFYCONTEXT) then
    Exit;
  try
    if not CryptCreateHash(Prov, CALG_SHA_256, 0, 0, Hash) then
      Exit;
    try
      Semilla := TEncoding.UTF8.GetBytes(CONSTANTE);
      SetLength(Semilla, Length(Semilla) + Length(Sal));
      Move(Sal[0], Semilla[Length(Semilla) - Length(Sal)], Length(Sal));
      if not CryptHashData(Hash, @Semilla[0], Length(Semilla), 0) then
        Exit;
      if not CryptDeriveKey(Prov, CALG_AES_256, Hash, 0, Clave) then
        Exit;
      try
        SetLength(Buf, Length(Datos) + 64);
        if Length(Datos) > 0 then
          Move(Datos[0], Buf[0], Length(Datos));
        Largo := Length(Datos);
        if Cifrar then
          Result := CryptEncrypt(Clave, 0, True, 0, @Buf[0], Largo, Length(Buf))
        else
          Result := CryptDecrypt(Clave, 0, True, 0, @Buf[0], Largo);
        if Result then
        begin
          SetLength(Buf, Largo);
          Res := Buf;
        end;
      finally
        CryptDestroyKey(Clave);
      end;
    finally
      CryptDestroyHash(Hash);
    end;
  finally
    CryptReleaseContext(Prov, 0);
  end;
end;

function CifrarSecreto(const Claro: string): string;
var
  Sal, Cifrado, Todo: TBytes;
  G: TGUID;
begin
  if Claro = '' then
    Exit('');
  G := TGUID.NewGuid;
  SetLength(Sal, LONG_SAL);
  Move(G, Sal[0], LONG_SAL);
  if not Transformar(Sal, TEncoding.UTF8.GetBytes(Claro), True, Cifrado) then
    raise Exception.Create('No se pudo cifrar el secreto.');
  SetLength(Todo, LONG_SAL + Length(Cifrado));
  Move(Sal[0], Todo[0], LONG_SAL);
  Move(Cifrado[0], Todo[LONG_SAL], Length(Cifrado));
  Result := PREFIJO + TNetEncoding.Base64.EncodeBytesToString(Todo);
end;

function DescifrarSecreto(const Cifrado: string): string;
var
  Todo, Sal, Datos, Claro: TBytes;
begin
  Result := '';
  try
    if not Cifrado.StartsWith(PREFIJO) then
      Exit;
    Todo := TNetEncoding.Base64.DecodeStringToBytes(Copy(Cifrado, Length(PREFIJO) + 1, MaxInt));
    if Length(Todo) <= LONG_SAL then
      Exit;
    SetLength(Sal, LONG_SAL);
    Move(Todo[0], Sal[0], LONG_SAL);
    SetLength(Datos, Length(Todo) - LONG_SAL);
    Move(Todo[LONG_SAL], Datos[0], Length(Datos));
    if Transformar(Sal, Datos, False, Claro) then
      Result := TEncoding.UTF8.GetString(Claro);
  except
    Result := '';
  end;
end;

end.
