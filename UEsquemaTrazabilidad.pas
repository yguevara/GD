unit UEsquemaTrazabilidad;

{ Esquema de la trazabilidad de documentos (F5): columnas aditivas de tb_log que
  identifican el documento (codigodoc, iddoc, codsubsdoc, versiondoc) y una
  fecha real ordenable (fecha_evento), mas un indice por documento.
  Idempotente: cada sentencia es independiente y un fallo (ya existe, sin
  permiso) no impide ejecutar las demas ni toca datos.
  En SQL Server el DDL espera como mucho TIEMPO_ESPERA_BLOQUEO_MS por un lock
  (otro cliente con tb_log ocupada): si vence, la sentencia falla, se ignora y
  la aplicacion arranca; se reintenta en el siguiente arranque. El indice se
  intenta primero ONLINE (no bloquea las escrituras del log; solo Enterprise).
  Copia documental del DDL de SQL Server: SCRIPTS/trazabilidad_esquema.sql
  Solo RTL + FireDAC (sin TUDM ni VCL). }

interface

uses
  FireDAC.Comp.Client;

const
  TIEMPO_ESPERA_BLOQUEO_MS = 5000;

procedure CrearEsquemaTrazabilidad(Conn: TFDConnection; EsSqlServer: Boolean);
{ True si tb_log tiene todas las columnas de la trazabilidad. }
function EsquemaTrazabilidadCompleto(Conn: TFDConnection): Boolean;

implementation

uses
  System.SysUtils;

procedure CrearEsquemaTrazabilidad(Conn: TFDConnection; EsSqlServer: Boolean);

  procedure Ejecutar(const Sql: string);
  begin
    try
      Conn.ExecSQL(Sql);
    except
      // Ya existe o no aplica: se ignora, igual que CrearEsquemaCarga.
    end;
  end;

  procedure Columna(const Nombre, TipoSql, TipoAccess: string);
  begin
    if EsSqlServer then
      Ejecutar('IF COL_LENGTH(''dbo.tb_log'', ''' + Nombre + ''') IS NULL ' +
        'ALTER TABLE tb_log ADD ' + Nombre + ' ' + TipoSql + ' NULL')
    else
      Ejecutar('ALTER TABLE tb_log ADD COLUMN ' + Nombre + ' ' + TipoAccess);
  end;

begin
  if EsSqlServer then
    Ejecutar('SET LOCK_TIMEOUT ' + IntToStr(TIEMPO_ESPERA_BLOQUEO_MS));
  try
    Columna('codigodoc', 'VARCHAR(20)', 'VARCHAR(20)');
    Columna('iddoc', 'INT', 'LONG');
    Columna('codsubsdoc', 'VARCHAR(50)', 'VARCHAR(50)');
    Columna('versiondoc', 'VARCHAR(12)', 'VARCHAR(12)');
    Columna('fecha_evento', 'DATETIME', 'DATETIME');
    if EsSqlServer then
    begin
      // ONLINE solo existe en Enterprise: si falla, el indice normal
      Ejecutar('IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = ''IX_tb_log_codigodoc'') ' +
        'CREATE INDEX IX_tb_log_codigodoc ON tb_log (codigodoc, IdEstructura) ' +
        'WITH (ONLINE = ON)');
      Ejecutar('IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = ''IX_tb_log_codigodoc'') ' +
        'CREATE INDEX IX_tb_log_codigodoc ON tb_log (codigodoc, IdEstructura)');
    end
    else
      Ejecutar('CREATE INDEX IX_tb_log_codigodoc ON tb_log (codigodoc, IdEstructura)');
  finally
    // la sesion es la de la aplicacion: volver a esperar sin limite
    if EsSqlServer then
      Ejecutar('SET LOCK_TIMEOUT -1');
  end;
end;

function EsquemaTrazabilidadCompleto(Conn: TFDConnection): Boolean;
begin
  try
    Conn.ExecSQLScalar('SELECT COUNT(codigodoc) + COUNT(iddoc) + COUNT(codsubsdoc) + ' +
      'COUNT(versiondoc) + COUNT(fecha_evento) FROM tb_log');
    Result := True;
  except
    Result := False;
  end;
end;

end.
