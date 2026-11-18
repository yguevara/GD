unit UDepuracionActa;

{ ---------------------------------------------------------------------------
  Contenido del Acta de eliminacion fisica de los documentos (Anexo 19 del Manual
  de procedimientos GD): lineas por serie, firmas de los testigos y cabecera. Es
  la parte PURA del impreso (sin FastReport): UDepuracionImpresos la lleva al
  informe. Codigo en ASCII.
  --------------------------------------------------------------------------- }

interface

uses
  UAutorizacion, UDepuracionReglas, UDepuracionDatos;

type
  { Una fila de la tabla del acta: lo que se elimina y la muestra que se conserva. }
  TLineaActa = record
    Descripcion, Unidades, Fechas, MuestraDesc, MuestraDonde: string;
  end;

  TFirmaActa = record
    Nombre, Cargo: string;
  end;

{ Una linea por grupo (serie), en el orden dado. La muestra es la misma en todas. }
function LineasActaDepuracion(const Grupos: array of TGrupoDepuracion;
  const A: TActaDepuracion): TArray<TLineaActa>;

{ Una firma por testigo, en el orden de alta. }
function FirmasActaDepuracion(const T: array of TTestigoFila): TArray<TFirmaActa>;

{ Nacional, Provincial, Municipal o Central. }
function NombreOrganoComision(O: TOrganoComision): string;

{ Cabecera del acta en una frase. FEliminacion es la fecha en que se elimino
  (Ejecutada = True) o la fecha prevista (Ejecutada = False). }
function TextoCabeceraActa(const Organo, NumActa, NumAcuerdo: string; FAutorizacion,
  FEliminacion: TDateTime; Ejecutada: Boolean; const Lugar: string;
  Via: TViaEliminacion): string;

implementation

uses
  System.SysUtils;

function Fecha(D: TDateTime): string;
begin
  if D = 0 then
    Result := ''
  else
    Result := FormatDateTime('dd/mm/yyyy', D);
end;

function LineasActaDepuracion(const Grupos: array of TGrupoDepuracion;
  const A: TActaDepuracion): TArray<TLineaActa>;
var
  I: Integer;
begin
  SetLength(Result, Length(Grupos));
  for I := 0 to High(Grupos) do
  begin
    Result[I].Descripcion := Grupos[I].Serie;
    if (Grupos[I].Subserie <> '') and (Grupos[I].Subserie <> Grupos[I].Serie) then
      Result[I].Descripcion := Grupos[I].Serie + ' / ' + Grupos[I].Subserie;
    Result[I].Unidades := UnidadesNumerosYLetras(Grupos[I].Unidades);
    Result[I].Fechas := RangoMesAnio(Grupos[I].Desde, Grupos[I].Hasta);
    Result[I].MuestraDesc := A.MuestraDesc;
    Result[I].MuestraDonde := A.MuestraDonde;
  end;
end;

function FirmasActaDepuracion(const T: array of TTestigoFila): TArray<TFirmaActa>;
var
  I: Integer;
begin
  SetLength(Result, Length(T));
  for I := 0 to High(T) do
  begin
    Result[I].Nombre := T[I].Nombre;
    Result[I].Cargo := T[I].Cargo;
  end;
end;

function NombreOrganoComision(O: TOrganoComision): string;
begin
  case O of
    ocNacional: Result := 'Nacional';
    ocProvincial: Result := 'Provincial';
    ocMunicipal: Result := 'Municipal';
  else
    Result := 'Central';
  end;
end;

function TextoCabeceraActa(const Organo, NumActa, NumAcuerdo: string; FAutorizacion,
  FEliminacion: TDateTime; Ejecutada: Boolean; const Lugar: string;
  Via: TViaEliminacion): string;
begin
  Result := 'Comisi' + #243 + 'n ' + Organo + ' de Valoraci' + #243 + 'n Documental - Acta ' +
    NumActa + ' - Acuerdo ' + NumAcuerdo + ' - Autorizaci' + #243 + 'n ' +
    Fecha(FAutorizacion) + ' - ';
  if Ejecutada then
    Result := Result + 'Eliminaci' + #243 + 'n ' + Fecha(FEliminacion)
  else
    Result := Result + 'Fecha prevista de eliminaci' + #243 + 'n ' + Fecha(FEliminacion);
  Result := Result + ' - Lugar: ' + Lugar + ' - V' + #237 + 'a: ' + TextoVia(Via);
end;

end.
