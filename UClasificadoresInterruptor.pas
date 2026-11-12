unit UClasificadoresInterruptor;

{ ---------------------------------------------------------------------------
  Interruptor entre las pantallas nuevas de clasificadores y las clasicas.
  Sin VCL ni TUDM.

  Un archivo "clasificadores_clasico.flag" junto al ejecutable hace que se abran
  las pantallas clasicas (igual que "shell_clasico.flag" con el shell). Si una
  pantalla nueva falla al abrirse, quien la llama registra el motivo con
  RegistrarErrorClasificador y abre la clasica.
  --------------------------------------------------------------------------- }

interface

const
  ARCHIVO_CLASIFICADORES_CLASICO = 'clasificadores_clasico.flag';
  ARCHIVO_ERRORES_CLASIFICADORES = 'clasificadores_error.log';

{ True si existe el .flag en ACarpeta (con barra final): se usan las pantallas
  clasicas. }
function ClasificadoresClasicos(const ACarpeta: string): Boolean;

{ Agrega "fecha hora texto" a clasificadores_error.log en ACarpeta (con barra
  final). Nunca lanza: registrar un error no puede causar otro. }
procedure RegistrarErrorClasificador(const ACarpeta, ATexto: string);

implementation

uses
  System.SysUtils, System.IOUtils;

function ClasificadoresClasicos(const ACarpeta: string): Boolean;
begin
  Result := FileExists(ACarpeta + ARCHIVO_CLASIFICADORES_CLASICO);
end;

procedure RegistrarErrorClasificador(const ACarpeta, ATexto: string);
begin
  try
    TFile.AppendAllText(ACarpeta + ARCHIVO_ERRORES_CLASIFICADORES,
      FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' ' + ATexto + sLineBreak);
  except
    // el registro es opcional
  end;
end;

end.
