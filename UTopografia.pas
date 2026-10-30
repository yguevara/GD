unit UTopografia;

{ Validacion de los datos topograficos (ubicacion fisica) de una subserie en un
  nodo y mensajes para quien intenta agregar un documento sin ellos.
  Solo RTL: sin VCL, FireDAC ni TUDM, para poder probarla desde una consola.

  Los datos topograficos viven en tb_Serietree (un registro por nodo y subserie):
    - Deposito, Gaveta, Archivo: donde se guarda el soporte fisico.
    - IdServidor: servidor FTP o repositorio del soporte digital.
  Que datos hacen falta depende del soporte de la subserie
  (cl_subseries.idsoporte): 1 = papel, 2 = digital, 3 = ambos. }

interface

type
  { Valores de tb_Serietree tal como llegan de la base (texto). }
  TDatosTopografia = record
    Deposito: string;
    Gaveta: string;
    Archivo: string;
    IdServidor: string;
  end;

{ Indica si los datos bastan para almacenar documentos en el soporte dado.
  Un campo cuenta como vacio si esta en blanco o vale '0'.
  Soporte 1 exige Deposito, Gaveta y Archivo; el 2 exige IdServidor; el 3 exige
  los cuatro. Cualquier otro soporte (incluido 0 o nulo) no bloquea, igual que
  el comportamiento anterior. }
function TopografiaCompleta(IdSoporte: Integer; const Datos: TDatosTopografia): Boolean;

{ Texto para quien intenta agregar un documento y la topografia esta incompleta.
  PuedeEditar = True: quien puede completarla (administrador o EGD del nodo)
  recibe que falta; PuedeEditar = False: el usuario recibe a quien pedirselo. }
function MensajeTopografiaFaltante(IdSoporte: Integer; PuedeEditar: Boolean): string;

implementation

uses
  System.SysUtils;

function CampoVacio(const Valor: string): Boolean;
begin
  Result := (Trim(Valor) = '') or (Valor = '0');
end;

function TopografiaCompleta(IdSoporte: Integer; const Datos: TDatosTopografia): Boolean;
begin
  case IdSoporte of
    1:
      Result := not (CampoVacio(Datos.Deposito) or CampoVacio(Datos.Gaveta) or
        CampoVacio(Datos.Archivo));
    2:
      Result := not CampoVacio(Datos.IdServidor);
    3:
      Result := not (CampoVacio(Datos.Deposito) or CampoVacio(Datos.Gaveta) or
        CampoVacio(Datos.Archivo) or CampoVacio(Datos.IdServidor));
  else
    Result := True;
  end;
end;

function MensajeTopografiaFaltante(IdSoporte: Integer; PuedeEditar: Boolean): string;
begin
  if not PuedeEditar then
    Result := 'Falta la ubicación de esta subserie en tu área. ' +
      'Avisa al especialista de gestión documental de tu nodo.'
  else if IdSoporte = 2 then
    Result := 'No ha especificado los datos topográficos de la serie actual. ' +
      'Por favor especifique un servidor o repositorio válido.'
  else
    Result := 'Por favor especifique los datos topográficos necesarios para ' +
      'almacenar series en el soporte especificado.';
end;

end.
