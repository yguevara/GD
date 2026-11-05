unit UAlmacenFicheros;

{ Almacenamiento de ficheros de documentos: interfaz comun (S3/MinIO y FTP de
  solo lectura) y reglas de rutas. Solo RTL, sin VCL ni UDM. }

interface

uses
  System.SysUtils;

type
  EAlmacen = class(Exception);
  EAlmacenSoloLectura = class(EAlmacen);
  EAlmacenNoSoportado = class(EAlmacen);

  { Cancelar = True aborta la operacion }
  TProgresoEvento = reference to procedure(Hecho, Total: Int64; var Cancelar: Boolean);

  TResultadoSubida = record
    Tamano: Int64;
    Md5: string;
  end;

  IAlmacenFicheros = interface
    ['{6B1F5E0A-3C0D-4C55-9E5B-2F2B7D4A9C11}']
    function Subir(const Local, Clave: string; Progreso: TProgresoEvento): TResultadoSubida;
    procedure Descargar(const Clave, Local: string; Progreso: TProgresoEvento);
    function Existe(const Clave: string; out Tamano: Int64): Boolean;
    procedure Borrar(const Clave: string);
    function UrlTemporal(const Clave: string; Segundos: Integer): string;
  end;

function ClaveObjeto(const IdEstructura: string; Id: Integer; const CodSubs,
  CodigoDoc, Version: string; IdHijo: Integer; const Nombre: string): string;
function UrlRaizS3(Idservidor: Integer): string;
function EsUrlRaizS3(const UrlRaiz: string; out Idservidor: Integer): Boolean;
function NormalizarRutaFtp(const S: string): string;

implementation

const
  PREFIJO_S3 = 's3://';

function ClaveObjeto(const IdEstructura: string; Id: Integer; const CodSubs,
  CodigoDoc, Version: string; IdHijo: Integer; const Nombre: string): string;
begin
  Result := IdEstructura + '/' + IntToStr(Id) + '/' + CodSubs + '/' + CodigoDoc +
    '/' + Version + '/' + IntToStr(IdHijo) + '-' + Nombre;
end;

function UrlRaizS3(Idservidor: Integer): string;
begin
  Result := PREFIJO_S3 + IntToStr(Idservidor) + '/';
end;

function EsUrlRaizS3(const UrlRaiz: string; out Idservidor: Integer): Boolean;
var
  Resto: string;
  P: Integer;
begin
  Idservidor := 0;
  Result := False;
  if not UrlRaiz.StartsWith(PREFIJO_S3, True) then
    Exit;
  Resto := Copy(UrlRaiz, Length(PREFIJO_S3) + 1, MaxInt);
  P := Pos('/', Resto);
  if P > 0 then
    Resto := Copy(Resto, 1, P - 1);
  Result := TryStrToInt(Resto, Idservidor) and (Idservidor > 0);
  if not Result then
    Idservidor := 0;
end;

function NormalizarRutaFtp(const S: string): string;
begin
  Result := StringReplace(S, '\', '/', [rfReplaceAll]);
  while Pos('//', Result) > 0 do
    Result := StringReplace(Result, '//', '/', [rfReplaceAll]);
end;

end.
