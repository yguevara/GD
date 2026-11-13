unit UImpresosComun;

{ ---------------------------------------------------------------------------
  Piezas comunes de los impresos FastReport de los procesos archivisticos
  (prestamos, transferencias, depuracion). Los informes (.fr3 en la carpeta
  Report) NO llevan conexion ni credenciales: la aplicacion les pasa los datos con
  variables de FastReport y con un TfrxDBDataset sobre una tabla en memoria que
  asigna a la banda de datos MasterData1.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, frxClass;

{ dd/mm/aaaa; vacio si no hay fecha (0). }
function FechaTexto(D: TDateTime): string;

{ Fechas extremas: "dd/mm/aaaa - dd/mm/aaaa", una sola fecha si coinciden, vacio
  si no hay ninguna. }
function RangoTexto(Desde, Hasta: TDateTime): string;

{ Valor de una variable de FastReport: el texto entre comillas simples. }
function CadenaFr(const S: string): string;

{ Tabla en memoria con campos de texto (nombre y largo), vacia y abierta. }
function NuevaTablaMemoria(Dueno: TComponent; const Campos: array of string;
  const Largos: array of Integer): TFDMemTable;

{ Conecta la tabla al informe con el nombre (UserName) que el .fr3 espera y la
  asigna a la banda de datos Banda. }
procedure ConectarDataset(Rep: TfrxReport; Tabla: TFDMemTable; const Nombre, Banda: string);

{ Nombre de la empresa (tb_sysconfig); vacio si no se puede leer. }
function EmpresaDe(Conn: TFDConnection): string;

implementation

uses
  System.Variants, Data.DB, frxDBSet;

function FechaTexto(D: TDateTime): string;
begin
  if D = 0 then
    Result := ''
  else
    Result := FormatDateTime('dd/mm/yyyy', D);
end;

function RangoTexto(Desde, Hasta: TDateTime): string;
begin
  if (Desde = 0) and (Hasta = 0) then
    Result := ''
  else if Trunc(Desde) = Trunc(Hasta) then
    Result := FechaTexto(Desde)
  else
    Result := FechaTexto(Desde) + ' - ' + FechaTexto(Hasta);
end;

function CadenaFr(const S: string): string;
begin
  Result := QuotedStr(S);
end;

function NuevaTablaMemoria(Dueno: TComponent; const Campos: array of string;
  const Largos: array of Integer): TFDMemTable;
var
  I: Integer;
begin
  Result := TFDMemTable.Create(Dueno);
  for I := 0 to High(Campos) do
    Result.FieldDefs.Add(Campos[I], ftString, Largos[I]);
  Result.CreateDataSet;
end;

procedure ConectarDataset(Rep: TfrxReport; Tabla: TFDMemTable; const Nombre, Banda: string);
var
  Ds: TfrxDBDataset;
  Obj: TfrxComponent;
begin
  Ds := TfrxDBDataset.Create(Rep);
  Ds.Name := 'frx' + Nombre;     // el .fr3 lo busca con este nombre
  Ds.UserName := Nombre;
  Ds.DataSet := Tabla;
  Ds.OpenDataSource := True;
  Rep.DataSets.Add(Ds);
  Rep.EnabledDataSets.Add(Ds);
  Obj := Rep.FindObject(Banda);
  if Obj is TfrxDataBand then
    TfrxDataBand(Obj).DataSet := Ds
  else
    raise EArgumentException.Create('El informe no tiene la banda de datos ' + Banda);
end;

function EmpresaDe(Conn: TFDConnection): string;
begin
  try
    Result := VarToStr(Conn.ExecSQLScalar('SELECT TOP 1 empresa FROM tb_sysconfig'));
  except
    Result := '';
  end;
end;

end.
