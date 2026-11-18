unit UDepuracionImpresos;

{ ---------------------------------------------------------------------------
  Impreso oficial de la depuracion (FastReport): Acta de eliminacion fisica de los
  documentos (Anexo 19 del Manual de procedimientos GD), con la serie o series que
  se eliminan (unidades en numeros y letras, fechas extremas), la muestra que se
  conserva, el desglose por ano y las firmas de los testigos.

  El informe (MAISEL REPORT/Report/rActaEliminacion.fr3, en la carpeta Report junto
  al ejecutable) se puede retocar con el disenador de FastReport. Sin conexion ni
  credenciales (ver UImpresosComun). Variables: Empresa, Numero, Cabecera, Total;
  datasets: "Lineas" (Descripcion, Unidades, Fechas, MuestraDesc, MuestraDonde),
  "Desglose" (Anio, Unidades) y "Firmas" (Nombre, Cargo).
  El contenido lo arma UDepuracionActa (puro y con pruebas).
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, frxClass, UDepuracionDatos, UDepuracionActa;

type
  TDatosActa = record
    Empresa, Numero, Cabecera, Total: string;
    Lineas: TArray<TLineaActa>;
    Desglose: TArray<TAnioCantidad>;
    Firmas: TArray<TFirmaActa>;
  end;

{ Devuelve el informe listo para mostrar o exportar; el llamador lo libera (los
  datos viajan dentro del informe). }
function PrepararActaDepuracion(const Fr3: string; const D: TDatosActa): TfrxReport;

{ Lee la depuracion de la base y muestra la vista previa. CarpetaReportes termina
  en barra o no (se completa). }
procedure ImprimirActaDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);

implementation

uses
  System.Classes, Data.DB, UImpresosComun, UDepuracionReglas, UAutorizacion,
  UTransferenciasDatos;

const
  ARCHIVO_ACTA = 'rActaEliminacion.fr3';

function PrepararActaDepuracion(const Fr3: string; const D: TDatosActa): TfrxReport;
var
  Tabla: TFDMemTable;
  L: TLineaActa;
  A: TAnioCantidad;
  F: TFirmaActa;
begin
  Result := TfrxReport.Create(nil);
  try
    Result.LoadFromFile(Fr3);
    Result.Variables['Empresa'] := CadenaFr(D.Empresa);
    Result.Variables['Numero'] := CadenaFr(D.Numero);
    Result.Variables['Cabecera'] := CadenaFr(D.Cabecera);
    Result.Variables['Total'] := CadenaFr(D.Total);
    Tabla := NuevaTablaMemoria(Result, ['Descripcion', 'Unidades', 'Fechas', 'MuestraDesc',
      'MuestraDonde'], [1000, 100, 40, 255, 255]);
    for L in D.Lineas do
    begin
      Tabla.Append;
      Tabla.FieldByName('Descripcion').AsString := L.Descripcion;
      Tabla.FieldByName('Unidades').AsString := L.Unidades;
      Tabla.FieldByName('Fechas').AsString := L.Fechas;
      Tabla.FieldByName('MuestraDesc').AsString := L.MuestraDesc;
      Tabla.FieldByName('MuestraDonde').AsString := L.MuestraDonde;
      Tabla.Post;
    end;
    ConectarDataset(Result, Tabla, 'Lineas', 'MasterData1');
    Tabla := NuevaTablaMemoria(Result, ['Anio', 'Unidades'], [10, 20]);
    for A in D.Desglose do
    begin
      Tabla.Append;
      Tabla.FieldByName('Anio').AsString := IntToStr(A.Anio);
      Tabla.FieldByName('Unidades').AsString := IntToStr(A.Unidades);
      Tabla.Post;
    end;
    ConectarDataset(Result, Tabla, 'Desglose', 'MasterData2');
    Tabla := NuevaTablaMemoria(Result, ['Nombre', 'Cargo'], [100, 100]);
    for F in D.Firmas do
    begin
      Tabla.Append;
      Tabla.FieldByName('Nombre').AsString := F.Nombre;
      Tabla.FieldByName('Cargo').AsString := F.Cargo;
      Tabla.Post;
    end;
    ConectarDataset(Result, Tabla, 'Firmas', 'MasterData3');
  except
    Result.Free;
    raise;
  end;
end;

{ Todo lo que el acta necesita, leido de la base. }
procedure LeerDatosActa(Conn: TFDConnection; IdProceso: Integer; out D: TDatosActa);
var
  Q: TFDQuery;
  Paso: Integer;
  FEjecucion: TDateTime;
  Ejecutada, HayAut: Boolean;
  A: TAutorizacion;
  Acta: TActaDepuracion;
  Grupos: TArray<TGrupoDepuracion>;
  Total, I: Integer;
  Organo, NumActa, NumAcuerdo: string;
  FAut, FEliminacion: TDateTime;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT p.Numero, p.Paso, d.FEjecucion FROM prc_proceso p INNER JOIN ' +
      'prc_depuracion d ON d.IdProceso = p.IdProceso WHERE p.IdProceso = :i';
    Q.ParamByName('i').AsInteger := IdProceso;
    Q.Open;
    if Q.IsEmpty then
      raise EArgumentException.Create('La depuracion no existe: ' + IntToStr(IdProceso));
    D.Numero := Trim(Q.FieldByName('Numero').AsString);
    Paso := Q.FieldByName('Paso').AsInteger;
    if Q.FieldByName('FEjecucion').IsNull then
      FEjecucion := 0
    else
      FEjecucion := Q.FieldByName('FEjecucion').AsDateTime;
  finally
    Q.Free;
  end;
  D.Empresa := EmpresaDe(Conn);
  HayAut := LeerAutorizacion(Conn, IdProceso, A);
  if HayAut then
  begin
    Organo := NombreOrganoComision(A.Organo);
    NumActa := A.NumActa;
    NumAcuerdo := A.NumAcuerdo;
    FAut := A.Fecha;
  end
  else
  begin
    Organo := '________';
    NumActa := '____';
    NumAcuerdo := '____';
    FAut := 0;
  end;
  LeerActaDepuracion(Conn, IdProceso, Acta);
  Ejecutada := (Paso >= 5) and (FEjecucion <> 0);
  if Ejecutada then
    FEliminacion := FEjecucion
  else
    FEliminacion := Acta.FPrevista;
  D.Cabecera := TextoCabeceraActa(Organo, NumActa, NumAcuerdo, FAut, FEliminacion,
    Ejecutada, Acta.Lugar, Acta.Via);
  Grupos := GruposDeLaDepuracion(Conn, IdProceso);
  D.Lineas := LineasActaDepuracion(Grupos, Acta);
  Total := 0;
  for I := 0 to High(Grupos) do
    Inc(Total, Grupos[I].Unidades);
  D.Total := UnidadesNumerosYLetras(Total);
  D.Desglose := DesglosePorAnio(Conn, IdProceso);
  D.Firmas := FirmasActaDepuracion(TestigosDeLaDepuracion(Conn, IdProceso));
end;

procedure ImprimirActaDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);
var
  D: TDatosActa;
  Rep: TfrxReport;
begin
  LeerDatosActa(Conn, IdProceso, D);
  Rep := PrepararActaDepuracion(IncludeTrailingPathDelimiter(CarpetaReportes) +
    ARCHIVO_ACTA, D);
  try
    Rep.ShowReport;
  finally
    Rep.Free;
  end;
end;

end.
