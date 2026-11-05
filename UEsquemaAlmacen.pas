unit UEsquemaAlmacen;

{ Columnas de cl_ftp_Server para servidores de tipo S3/MinIO. Aditivo e
  idempotente: cada sentencia es independiente y un fallo (por ejemplo "ya
  existe") no impide ejecutar las demas ni toca datos existentes.
  Copia documental del DDL de SQL Server: SCRIPTS/almacen_columnas.sql
  Solo RTL + FireDAC (sin TUDM ni VCL). }

interface

uses
  FireDAC.Comp.Client;

procedure CrearEsquemaAlmacen(Conn: TFDConnection; EsSqlServer: Boolean);
{ True si cl_ftp_Server ya tiene todas las columnas de S3 (la DDL se ignora en
  silencio si falla, p. ej. sin permiso). }
function EsquemaAlmacenCompleto(Conn: TFDConnection): Boolean;

implementation

uses
  System.SysUtils;

procedure CrearEsquemaAlmacen(Conn: TFDConnection; EsSqlServer: Boolean);

  procedure Ejecutar(const Sql: string);
  begin
    try
      Conn.ExecSQL(Sql);
    except
      // Ya existe o no aplica: se ignora, igual que CrearEsquemaAlcance.
    end;
  end;

  procedure Columna(const Nombre, Tipo: string);
  begin
    if EsSqlServer then
      Ejecutar('IF COL_LENGTH(''dbo.cl_ftp_Server'', ''' + Nombre + ''') IS NULL ' +
        'ALTER TABLE cl_ftp_Server ADD ' + Nombre + ' ' + Tipo + ' NULL')
    else
      Ejecutar('ALTER TABLE cl_ftp_Server ADD COLUMN ' + Nombre + ' ' +
        StringReplace(Tipo, '(500)', '(255)', [])); // Access: texto de hasta 255
  end;

begin
  Columna('tipo', 'VARCHAR(3)');
  Columna('bucket', 'VARCHAR(100)');
  Columna('region', 'VARCHAR(50)');
  Columna('usohttps', 'BIT');
  Columna('clave_acceso', 'VARCHAR(100)');
  Columna('secreto_cifrado', 'VARCHAR(500)');
  // ipserver admitia 20 caracteres: un nombre DNS de MinIO puede ser mas largo
  if EsSqlServer then
    Ejecutar('IF COL_LENGTH(''dbo.cl_ftp_Server'', ''ipserver'') < 100 ' +
      'ALTER TABLE cl_ftp_Server ALTER COLUMN ipserver VARCHAR(100) NULL')
  else
    Ejecutar('ALTER TABLE cl_ftp_Server ALTER COLUMN ipserver TEXT(100)');
  // Los servidores que ya existian son FTP
  Ejecutar('UPDATE cl_ftp_Server SET tipo = ''FTP'' WHERE tipo IS NULL');
end;

function EsquemaAlmacenCompleto(Conn: TFDConnection): Boolean;
const
  COLUMNAS: array[0..5] of string = ('tipo', 'bucket', 'region', 'usohttps',
    'clave_acceso', 'secreto_cifrado');
var
  I: Integer;
begin
  Result := True;
  for I := Low(COLUMNAS) to High(COLUMNAS) do
    try
      Conn.ExecSQLScalar('SELECT COUNT(' + COLUMNAS[I] + ') FROM cl_ftp_Server');
    except
      Exit(False);
    end;
end;

end.
