unit UAutorizacion;

{ ---------------------------------------------------------------------------
  Autorizacion de la Comision de Valoracion Documental: validacion del acta y
  del acuerdo que respaldan una transferencia o una depuracion. Sin VCL ni
  FireDAC.

  El sistema no modela el voto de la Comision: registra su acta y acuerdo.
    Transferencia : Comision Central de Valoracion de la entidad.
    Depuracion    : Comision Nacional, Provincial o Municipal.
    Prestamo      : no usa autorizacion.
  Campos de error: 'acta', 'acuerdo', 'fecha', 'organo'.
  --------------------------------------------------------------------------- }

interface

uses
  UProceso, UErroresCampo;

type
  TOrganoComision = (ocCentral, ocMunicipal, ocProvincial, ocNacional);

  TAutorizacion = record
    Organo: TOrganoComision;
    NumActa, NumAcuerdo: string;
    Fecha: TDateTime;
  end;

{ Lista de errores; vacia si la autorizacion es valida. Hoy es la fecha de
  referencia (se inyecta para poder probar). }
function ValidarAutorizacion(Tipo: TTipoProceso; const A: TAutorizacion;
  Hoy: TDateTime): TArray<TErrorCampo>;

implementation

uses
  System.SysUtils;

const
  // Antes de 1959 no hay comisiones de valoracion: se descarta un ano mal tecleado.
  FECHA_MINIMA = 21551.0; // 01/01/1959

procedure Agregar(var Lista: TArray<TErrorCampo>; const Campo, Mensaje: string);
var
  E: TErrorCampo;
begin
  E.Campo := Campo;
  E.Mensaje := Mensaje;
  SetLength(Lista, Length(Lista) + 1);
  Lista[High(Lista)] := E;
end;

function ValidarAutorizacion(Tipo: TTipoProceso; const A: TAutorizacion;
  Hoy: TDateTime): TArray<TErrorCampo>;
begin
  Result := nil;
  if Trim(A.NumActa) = '' then
    Agregar(Result, 'acta', 'Falta el numero de acta.');
  if Trim(A.NumAcuerdo) = '' then
    Agregar(Result, 'acuerdo', 'Falta el numero de acuerdo.');
  if (A.Fecha < FECHA_MINIMA) or (Trunc(A.Fecha) > Trunc(Hoy)) then
    Agregar(Result, 'fecha', 'La fecha de la autorizacion no es valida.');
  case Tipo of
    tpTransferencia:
      if A.Organo <> ocCentral then
        Agregar(Result, 'organo',
          'La transferencia la autoriza la Comision Central de la entidad.');
    tpDepuracion:
      if A.Organo = ocCentral then
        Agregar(Result, 'organo',
          'La depuracion la autoriza la Comision Nacional, Provincial o Municipal.');
    tpPrestamo:
      Agregar(Result, 'organo', 'El prestamo no usa autorizacion.');
  end;
end;

end.
