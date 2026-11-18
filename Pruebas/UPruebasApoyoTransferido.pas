unit UPruebasApoyoTransferido;

{ Apoyo de las pruebas de base: deja un documento como "transferido" (retenido por
  una transferencia FINALIZADA hacia un archivo central de prueba) sin recorrer los
  seis pasos, y lo limpia. Codigo en ASCII. }

interface

uses
  FireDAC.Comp.Client, UCandados;

const
  ANIO_APOYO = 1991;
  COD_ARCHIVO_APOYO = 9992;

{ Crea el archivo central de prueba (llamado como Usuario), una transferencia
  finalizada T-1991-n con destino ese archivo y la unidad activa del documento. }
procedure SembrarTransferido(Conn: TFDConnection; const U: TUnidadDoc;
  const Usuario: string);

procedure LimpiarTransferidos(Conn: TFDConnection; const Usuario: string);

function UnidadApoyo(const IdEstructura: string; Id: Integer; const CodSubs,
  Codigo: string): TUnidadDoc;

implementation

uses
  System.SysUtils, Data.DB, FireDAC.Stan.Param;

function UnidadApoyo(const IdEstructura: string; Id: Integer; const CodSubs,
  Codigo: string): TUnidadDoc;
begin
  Result.IdEstructura := IdEstructura;
  Result.Id := Id;
  Result.CodSubs := CodSubs;
  Result.CodigoDoc := Codigo;
  Result.Fecha := EncodeDate(2018, 1, 1);
  Result.Version := '1';
end;

procedure SembrarTransferido(Conn: TFDConnection; const U: TUnidadDoc;
  const Usuario: string);
var
  Cons, IdProceso: Integer;
begin
  if Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM cl_ArchivosGestion WHERE Cod = :c',
    [COD_ARCHIVO_APOYO])) = 0 then
    Conn.ExecSQL('INSERT INTO cl_ArchivosGestion (Cod, nombreArchivo, Tipo, Idresp) ' +
      'VALUES (:c, :n, 1, 1)', [COD_ARCHIVO_APOYO, Usuario]);
  Cons := Integer(Conn.ExecSQLScalar('SELECT COALESCE(MAX(Consecutivo), 0) + 1 FROM ' +
    'prc_proceso WHERE Tipo = ''T'' AND Anio = :a', [ANIO_APOYO]));
  Conn.ExecSQL('INSERT INTO prc_proceso (Tipo, Anio, Consecutivo, Numero, Estado, Paso, ' +
    'IdEstructura, IdNodo, CreadoPor) SELECT TOP 1 ''T'', :a, :c, :n, ''F'', 6, ' +
    'IdEstructura, id, :u FROM tb_tree ORDER BY IdEstructura, id',
    [ANIO_APOYO, Cons, 'T-' + IntToStr(ANIO_APOYO) + '-' + IntToStr(Cons), Usuario],
    [ftInteger, ftInteger, ftString, ftString]);
  IdProceso := Integer(Conn.ExecSQLScalar('SELECT IdProceso FROM prc_proceso WHERE ' +
    'Tipo = ''T'' AND Anio = :a AND Consecutivo = :c', [ANIO_APOYO, Cons]));
  Conn.ExecSQL('INSERT INTO prc_transferencia (IdProceso, IdArchivoDestino) VALUES (:p, :a)',
    [IdProceso, COD_ARCHIVO_APOYO]);
  Conn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, Codigodoc, ' +
    'fecha, version, Activa) VALUES (:p, :e, :i, :s, :c, :f, :v, 1)',
    [IdProceso, U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version],
    [ftInteger, ftString, ftInteger, ftString, ftString, ftDateTime, ftString]);
end;

procedure LimpiarTransferidos(Conn: TFDConnection; const Usuario: string);
begin
  Conn.ExecSQL('DELETE FROM prc_proceso WHERE CreadoPor = :u AND Anio = :a',
    [Usuario, ANIO_APOYO]);
  Conn.ExecSQL('DELETE FROM cl_ArchivosGestion WHERE Cod = :c', [COD_ARCHIVO_APOYO]);
end;

end.
