unit UPruebasApoyoDepuracion;

{ Apoyo de las pruebas de base de la depuracion: siembra procesos 'D' a mano (sin
  recorrer los pasos) y los limpia. Codigo en ASCII. }

interface

uses
  FireDAC.Comp.Client, UCandados;

const
  ANIO_DEPURACION_APOYO = 1992;

{ Crea un proceso D-1992-n en el paso y estado dados ('C' en curso, 'F' finalizado,
  'X' cancelado) con una unidad (activa o no) del documento. Devuelve su IdProceso.
  Usa el primer nodo de tb_tree. }
function SembrarDepuracion(Conn: TFDConnection; const U: TUnidadDoc; Paso: Integer;
  const Estado: string; Activa: Boolean; const Usuario: string): Integer;

procedure LimpiarDepuraciones(Conn: TFDConnection; const Usuario: string);

implementation

uses
  System.SysUtils, Data.DB, FireDAC.Stan.Param;

function SembrarDepuracion(Conn: TFDConnection; const U: TUnidadDoc; Paso: Integer;
  const Estado: string; Activa: Boolean; const Usuario: string): Integer;
var
  Cons, A: Integer;
begin
  Cons := Integer(Conn.ExecSQLScalar('SELECT COALESCE(MAX(Consecutivo), 0) + 1 FROM ' +
    'prc_proceso WHERE Tipo = ''D'' AND Anio = :a', [ANIO_DEPURACION_APOYO]));
  Conn.ExecSQL('INSERT INTO prc_proceso (Tipo, Anio, Consecutivo, Numero, Estado, Paso, ' +
    'IdEstructura, IdNodo, CreadoPor) SELECT TOP 1 ''D'', :a, :c, :n, :e, :p, ' +
    'IdEstructura, id, :u FROM tb_tree ORDER BY IdEstructura, id',
    [ANIO_DEPURACION_APOYO, Cons, 'D-' + IntToStr(ANIO_DEPURACION_APOYO) + '-' + IntToStr(Cons),
    Estado, Paso, Usuario],
    [ftInteger, ftInteger, ftString, ftString, ftInteger, ftString]);
  Result := Integer(Conn.ExecSQLScalar('SELECT IdProceso FROM prc_proceso WHERE ' +
    'Tipo = ''D'' AND Anio = :a AND Consecutivo = :c', [ANIO_DEPURACION_APOYO, Cons]));
  if Activa then
    A := 1
  else
    A := 0;
  Conn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, Codigodoc, ' +
    'fecha, version, Activa) VALUES (:p, :e, :i, :s, :c, :f, :v, :a)',
    [Result, U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version, A],
    [ftInteger, ftString, ftInteger, ftString, ftString, ftDateTime, ftString, ftInteger]);
end;

procedure LimpiarDepuraciones(Conn: TFDConnection; const Usuario: string);
begin
  Conn.ExecSQL('DELETE FROM prc_proceso WHERE CreadoPor = :u AND Tipo = ''D'' AND Anio = :a',
    [Usuario, ANIO_DEPURACION_APOYO]);
end;

end.
