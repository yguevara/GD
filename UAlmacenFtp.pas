unit UAlmacenFtp;

{ Almacen FTP de solo lectura: solo sirve para abrir los ficheros que todavia
  no se han migrado a S3 y para que la utilidad de migracion los lea. Subir y
  Borrar no existen a proposito. Una conexion por operacion, como el codigo
  historico de TUDM. Solo RTL + Indy, sin VCL ni UDM. }

interface

uses
  System.SysUtils, UAlmacenFicheros;

type
  TAlmacenFtp = class(TInterfacedObject, IAlmacenFicheros)
  private
    FHost, FUsuario, FClave, FRaiz: string;
    FPuerto: Integer;
    function RutaDe(const Clave: string): string;
  public
    constructor Create(const Host, Usuario, Clave: string; Puerto: Integer;
      const Raiz: string);
    function Subir(const Local, Clave: string; Progreso: TProgresoEvento): TResultadoSubida;
    procedure Descargar(const Clave, Local: string; Progreso: TProgresoEvento);
    function Existe(const Clave: string; out Tamano: Int64): Boolean;
    procedure Borrar(const Clave: string);
    function UrlTemporal(const Clave: string; Segundos: Integer): string;
  end;

implementation

uses
  System.Classes, System.IOUtils, IdFTP, IdGlobal, IdException, IdComponent;

type
  { Recibe el avance de Indy y lo reenvia al evento de progreso }
  TEscuchaFtp = class
  public
    Ftp: TIdFTP;
    Progreso: TProgresoEvento;
    Total: Int64;
    procedure AlTrabajar(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
  end;

procedure TEscuchaFtp.AlTrabajar(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
var
  Cancelar: Boolean;
begin
  if Assigned(Progreso) and (AWorkMode = wmRead) then
  begin
    Cancelar := False;
    Progreso(AWorkCount, Total, Cancelar);
    if Cancelar then
      Ftp.Abort;
  end;
end;

constructor TAlmacenFtp.Create(const Host, Usuario, Clave: string; Puerto: Integer;
  const Raiz: string);
begin
  inherited Create;
  FHost := Host;
  FUsuario := Usuario;
  FClave := Clave;
  FPuerto := Puerto;
  FRaiz := Raiz;
end;

function TAlmacenFtp.RutaDe(const Clave: string): string;
begin
  Result := NormalizarRutaFtp(FRaiz + Clave);
end;

function TAlmacenFtp.Subir(const Local, Clave: string; Progreso: TProgresoEvento): TResultadoSubida;
begin
  raise EAlmacenSoloLectura.Create('El servidor FTP es de solo lectura: los ficheros nuevos van al almacen S3.');
end;

procedure TAlmacenFtp.Borrar(const Clave: string);
begin
  raise EAlmacenSoloLectura.Create('El servidor FTP es de solo lectura: no se pueden borrar ficheros.');
end;

function TAlmacenFtp.UrlTemporal(const Clave: string; Segundos: Integer): string;
begin
  raise EAlmacenNoSoportado.Create('El servidor FTP no genera enlaces temporales.');
end;

procedure TAlmacenFtp.Descargar(const Clave, Local: string; Progreso: TProgresoEvento);
var
  Ftp: TIdFTP;
  Escucha: TEscuchaFtp;
  Parte: string;
  Ok: Boolean;
begin
  Parte := Local + '.parte';
  Ok := False;
  Ftp := TIdFTP.Create(nil);
  Escucha := TEscuchaFtp.Create;
  try
    Ftp.Host := FHost;
    Ftp.Username := FUsuario;
    Ftp.Password := FClave;
    Ftp.Port := FPuerto;
    Escucha.Ftp := Ftp;
    Escucha.Progreso := Progreso;
    Ftp.OnWork := Escucha.AlTrabajar;
    try
      Ftp.Connect;
      try
        try
          Escucha.Total := Ftp.Size(RutaDe(Clave));
        except
          Escucha.Total := 0;
        end;
        Ftp.Get(RutaDe(Clave), Parte, True);
        Ok := True;
      finally
        if Ftp.Connected then
          Ftp.Disconnect;
      end;
    except
      on E: EIdException do
        raise EAlmacen.CreateFmt('No se pudo descargar el fichero del servidor FTP (%s): %s',
          [FHost, E.Message]);
    end;
  finally
    Escucha.Free;
    Ftp.Free;
    if not Ok and TFile.Exists(Parte) then
      TFile.Delete(Parte);
  end;
  if TFile.Exists(Local) then
    TFile.Delete(Local);
  TFile.Move(Parte, Local);
end;

function TAlmacenFtp.Existe(const Clave: string; out Tamano: Int64): Boolean;
var
  Ftp: TIdFTP;
begin
  Tamano := 0;
  Result := False;
  Ftp := TIdFTP.Create(nil);
  try
    Ftp.Host := FHost;
    Ftp.Username := FUsuario;
    Ftp.Password := FClave;
    Ftp.Port := FPuerto;
    try
      Ftp.Connect;
    except
      on E: EIdException do
        raise EAlmacen.CreateFmt('No se pudo conectar con el servidor FTP (%s).', [FHost]);
    end;
    try
      try
        Tamano := Ftp.Size(RutaDe(Clave));
        Result := Tamano >= 0;
        if not Result then
          Tamano := 0;
      except
        on E: EIdException do
          Result := False;
      end;
    finally
      if Ftp.Connected then
        Ftp.Disconnect;
    end;
  finally
    Ftp.Free;
  end;
end;

end.
