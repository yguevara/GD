unit UEsquemaCarga;

{ Esquema de la carga de documentos: columna cl_VarSubserie.obligatorio (nulo =
  no obligatorio) y tabla tb_carga_valores (ultimos valores por usuario y
  subserie). Aditivo e idempotente: cada sentencia es independiente y un fallo
  (por ejemplo "ya existe") no impide ejecutar las demas ni toca datos.
  Copia documental del DDL de SQL Server: SCRIPTS/carga_esquema.sql
  Solo RTL + FireDAC (sin TUDM ni VCL). }

interface

uses
  FireDAC.Comp.Client;

procedure CrearEsquemaCarga(Conn: TFDConnection; EsSqlServer: Boolean);
{ True si el esquema de la carga esta completo (la DDL se ignora en silencio si
  falla, p. ej. sin permiso). }
function EsquemaCargaCompleto(Conn: TFDConnection): Boolean;

implementation

uses
  System.SysUtils;

procedure CrearEsquemaCarga(Conn: TFDConnection; EsSqlServer: Boolean);

  procedure Ejecutar(const Sql: string);
  begin
    try
      Conn.ExecSQL(Sql);
    except
      // Ya existe o no aplica: se ignora, igual que CrearEsquemaAlmacen.
    end;
  end;

const
  SQL_VALORES =
    'CREATE TABLE tb_carga_valores (' +
    'user_id VARCHAR(100) NOT NULL, ' +
    'codsubs VARCHAR(50) NOT NULL, ' +
    'campo VARCHAR(100) NOT NULL, ' +
    'valor VARCHAR(255) NULL, ' +
    'CONSTRAINT PK_tb_carga_valores PRIMARY KEY (user_id, codsubs, campo))';

begin
  if EsSqlServer then
  begin
    Ejecutar('IF COL_LENGTH(''dbo.cl_VarSubserie'', ''obligatorio'') IS NULL ' +
      'ALTER TABLE cl_VarSubserie ADD obligatorio BIT NULL');
    Ejecutar('IF OBJECT_ID(''dbo.tb_carga_valores'', ''U'') IS NULL ' + SQL_VALORES);
  end
  else
  begin
    Ejecutar('ALTER TABLE cl_VarSubserie ADD COLUMN obligatorio BIT');
    Ejecutar(SQL_VALORES);
  end;
end;

function EsquemaCargaCompleto(Conn: TFDConnection): Boolean;
begin
  try
    Conn.ExecSQLScalar('SELECT COUNT(obligatorio) FROM cl_VarSubserie');
    Conn.ExecSQLScalar('SELECT COUNT(*) FROM tb_carga_valores');
    Result := True;
  except
    Result := False;
  end;
end;

end.
