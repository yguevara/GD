unit UProcesosInterruptor;

{ ---------------------------------------------------------------------------
  Interruptor entre las pantallas nuevas de procesos (prestamos,
  transferencias, depuracion) y las clasicas. Sin VCL ni TUDM.

  Un archivo "procesos_clasico.flag" junto al ejecutable hace que se abran las
  pantallas clasicas (igual que "clasificadores_clasico.flag" con los
  clasificadores). Si una pantalla nueva falla al abrirse, quien la llama
  registra el motivo con RegistrarErrorProceso y abre la clasica.
  --------------------------------------------------------------------------- }

interface

const
  ARCHIVO_PROCESOS_CLASICO = 'procesos_clasico.flag';
  ARCHIVO_ERRORES_PROCESOS = 'procesos_error.log';

{ True si existe el .flag en ACarpeta (con barra final): se usan las pantallas
  clasicas. }
function ProcesosClasicos(const ACarpeta: string): Boolean;

{ Agrega "fecha hora texto" a procesos_error.log en ACarpeta (con barra final).
  Nunca lanza: registrar un error no puede causar otro. }
procedure RegistrarErrorProceso(const ACarpeta, ATexto: string);

implementation

uses
  System.SysUtils, System.IOUtils;

function ProcesosClasicos(const ACarpeta: string): Boolean;
begin
  Result := FileExists(ACarpeta + ARCHIVO_PROCESOS_CLASICO);
end;

procedure RegistrarErrorProceso(const ACarpeta, ATexto: string);
begin
  try
    TFile.AppendAllText(ACarpeta + ARCHIVO_ERRORES_PROCESOS,
      FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' ' + ATexto + sLineBreak);
  except
    // el registro es opcional
  end;
end;

end.
