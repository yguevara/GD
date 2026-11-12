unit UTiempos;

{ ---------------------------------------------------------------------------
  Medicion de tiempos de arranque (diagnostico). Sin VCL ni TUDM.

  Esta desactivada por defecto y no cuesta nada: solo escribe si existe el
  archivo "perfil_arranque.flag" junto al ejecutable o la variable de entorno
  ARCHIGENIO_PERFIL=1. Cuando esta activa, TiemposMarca anade al archivo
  "tiempos_arranque.log" (junto al ejecutable) una linea con los milisegundos
  desde TiemposIniciar y desde la marca anterior:

      [  1234 ms | +  210 ms] Etiqueta

  Uso: llamar TiemposIniciar al comienzo del programa y TiemposMarca('texto')
  al terminar cada fase que se quiera medir.
  --------------------------------------------------------------------------- }

interface

{ Fija el instante cero, decide si la medicion esta activa y reinicia el log. }
procedure TiemposIniciar;

{ Anota una marca de tiempo con su etiqueta (no hace nada si esta desactivada). }
procedure TiemposMarca(const AEtiqueta: string);

{ True si la medicion de arranque esta activa. }
function TiemposActivo: Boolean;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes;

var
  GActivo: Boolean = False;
  GFrecuencia: Int64 = 0;
  GInicio: Int64 = 0;
  GAnterior: Int64 = 0;
  GRuta: string = '';

function Ahora: Int64;
begin
  QueryPerformanceCounter(Result);
end;

function TiemposActivo: Boolean;
begin
  Result := GActivo;
end;

procedure TiemposIniciar;
var
  Carpeta: string;
begin
  Carpeta := ExtractFilePath(ParamStr(0));
  GActivo := FileExists(Carpeta + 'perfil_arranque.flag') or
    (GetEnvironmentVariable('ARCHIGENIO_PERFIL') = '1');
  if not GActivo then
    Exit;
  QueryPerformanceFrequency(GFrecuencia);
  GInicio := Ahora;
  GAnterior := GInicio;
  GRuta := Carpeta + 'tiempos_arranque.log';
  try
    DeleteFile(GRuta);
  except
  end;
  TiemposMarca('Inicio del programa');
end;

procedure TiemposMarca(const AEtiqueta: string);
var
  T: Int64;
  Linea: string;
  F: TextFile;
begin
  if not GActivo then
    Exit;
  T := Ahora;
  Linea := Format('[%6d ms | +%5d ms] %s',
    [(T - GInicio) * 1000 div GFrecuencia, (T - GAnterior) * 1000 div GFrecuencia, AEtiqueta]);
  GAnterior := T;
  try
    AssignFile(F, GRuta);
    if FileExists(GRuta) then
      Append(F)
    else
      Rewrite(F);
    try
      Writeln(F, Linea);
    finally
      CloseFile(F);
    end;
  except
    // Medir nunca debe romper el arranque.
  end;
end;

end.
