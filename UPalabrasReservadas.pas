unit UPalabrasReservadas;

{ Palabras reservadas de SQL Server y de Access: no valen como nombre de columna.
  Solo RTL. Codigo en ASCII. }

interface

const
  // Lista completa de palabras reservadas para SQL Server
  SQLServerReservadas: array[0..225] of string = ('ADD', 'ALL', 'ALTER', 'AND', 'ANY', 'AS', 'ASC', 'AUTHORIZATION', 'BACKUP', 'BEGIN', 'BETWEEN', 'BREAK', 'BROWSE', 'BULK', 'BY', 'CASCADE', 'CASE', 'CHECK', 'CLOSE', 'CLUSTERED', 'COALESCE', 'COLLATE', 'COLUMN', 'COMMIT', 'COMPUTE', 'CONSTRAINT', 'CONTAINS', 'CONTAINSTABLE', 'CONTINUE', 'CONVERT', 'CREATE', 'CROSS', 'CURRENT', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_USER', 'CURSOR', 'DATABASE', 'DBCC', 'DEALLOCATE', 'DECLARE',
    'DEFAULT', 'DELETE', 'DENY', 'DESC', 'DISK', 'DISTINCT', 'DISTRIBUTED', 'DOUBLE', 'DROP', 'DUMP', 'ELSE', 'END', 'ERRLVL', 'ESCAPE', 'EXCEPT', 'EXEC', 'EXECUTE', 'EXISTS', 'EXIT', 'EXTERNAL', 'FETCH', 'FILE', 'FILLFACTOR', 'FOR', 'FOREIGN', 'FREETEXT', 'FREETEXTTABLE', 'FROM', 'FULL', 'FUNCTION', 'GOTO', 'GRANT', 'GROUP', 'HAVING', 'HOLDLOCK', 'IDENTITY', 'IDENTITY_INSERT', 'IDENTITYCOL', 'IF', 'IN', 'INDEX', 'INNER', 'INSERT', 'INTERSECT', 'INTO', 'IS', 'JOIN', 'KEY', 'KILL', 'LEFT', 'LIKE', 'LINENO',
    'LOAD', 'MERGE', 'NATIONAL', 'NOCHECK', 'NONCLUSTERED', 'NOT', 'NULL', 'NULLIF', 'OF', 'OFF', 'OFFSETS', 'ON', 'OPEN', 'OPENDATASOURCE', 'OPENQUERY', 'OPENROWSET', 'OPENXML', 'OPTION', 'OR', 'ORDER', 'OUTER', 'OVER', 'PERCENT', 'PIVOT', 'PLAN', 'PRIMARY', 'PRINT', 'PROC', 'PROCEDURE', 'PUBLIC', 'RAISERROR', 'READ', 'READTEXT', 'RECONFIGURE', 'REFERENCES', 'REPLICATION', 'RESTORE', 'RESTRICT', 'RETURN', 'REVERT', 'REVOKE', 'RIGHT', 'ROLLBACK', 'ROWCOUNT', 'ROWGUIDCOL', 'RULE', 'SAVE', 'SCHEMA',
    'SECURITYAUDIT', 'SELECT', 'SEMANTICKEYPHRASETABLE', 'SEMANTICSIMILARITYDETAILSTABLE', 'SEMANTICSIMILARITYTABLE', 'SESSION_USER', 'SET', 'SETUSER', 'SHUTDOWN', 'SOME', 'STATISTICS', 'SYSTEM_USER', 'TABLE', 'TABLESAMPLE', 'TEXTSIZE', 'THEN', 'TO', 'TOP', 'TRAN', 'TRANSACTION', 'TRIGGER', 'TRUNCATE', 'TRY_CONVERT', 'TSEQUAL', 'UNION', 'UNIQUE', 'UNPIVOT', 'UPDATE', 'UPDATETEXT', 'USE', 'USER', 'VALUES', 'VARYING', 'VIEW', 'WAITFOR', 'WHEN', 'WHERE', 'WHILE', 'WITH', 'WITHIN GROUP', 'WRITETEXT', 'BIGINT',
    'BINARY', 'BIT', 'CHAR', 'DATE', 'DATETIME', 'DATETIME2', 'DATETIMEOFFSET', 'DECIMAL', 'FLOAT', 'GEOGRAPHY', 'GEOMETRY', 'HIERARCHYID', 'IMAGE', 'INT', 'MONEY', 'NCHAR', 'NTEXT', 'NUMERIC', 'NVARCHAR', 'REAL', 'ROWVERSION', 'SMALLDATETIME', 'SMALLINT', 'SMALLMONEY', 'SQL_VARIANT', 'TEXT', 'TIME', 'TIMESTAMP', 'TINYINT', 'UNIQUEIDENTIFIER', 'VARBINARY', 'VARCHAR', 'XML', 'IDESTRUCTURA', 'ID', 'CODSUBS', 'FECHA', 'VERSION', 'CODIGODOC', 'YEAR', 'MONTH', 'DAY');

  // Lista completa de palabras reservadas para MS Access
  AccessReservadas: array[0..90] of string = ('ADD', 'ALL', 'ALTER', 'AND', 'ANY', 'AS', 'ASC', 'AUTOINCREMENT', 'BETWEEN', 'BY', 'CHAR', 'COLUMN', 'CONSTRAINT', 'COUNT', 'COUNTER', 'CREATE', 'CURRENCY', 'DATABASE', 'DATE', 'DATETIME', 'DELETE', 'DESC', 'DISTINCT', 'DISTINCTROW', 'DROP', 'ELSE', 'END', 'EXISTS', 'FLOAT', 'FOR', 'FOREIGN', 'FROM', 'GENERAL', 'GROUP', 'HAVING', 'INNER', 'INSERT', 'INT', 'INTEGER', 'INTO', 'IS', 'JOIN', 'KEY', 'LEFT', 'LEVEL', 'LIKE', 'LONG', 'MEMO', 'MOD', 'MONEY', 'NOT',
    'NULL', 'NUMBER', 'OLEOBJECT', 'ON', 'OR', 'ORDER', 'OUTER', 'OWNERACCESS', 'PARAMETER', 'PERCENT', 'PIVOT', 'PRIMARY', 'PROCEDURE', 'REAL', 'REFERENCES', 'RIGHT', 'SELECT', 'SET', 'SHORT', 'SINGLE', 'SMALLINT', 'STDEV', 'SUM', 'TABLE', 'TEXT', 'TOP', 'TRANSFORM', 'UPDATE', 'VALUE', 'WHERE', 'YESNO', 'IDESTRUCTURA', 'ID', 'CODSUBS', 'FECHA', 'VERSION', 'CODIGODOC', 'YEAR', 'MONTH', 'DAY');


{ Sin distinguir mayusculas; vacio = False. }
function EsPalabraReservada(const Nombre: string; EsSqlServer: Boolean): Boolean;

implementation

uses
  System.SysUtils;

function EsPalabraReservada(const Nombre: string; EsSqlServer: Boolean): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Trim(Nombre) = '' then
    Exit;
  if EsSqlServer then
  begin
    for I := Low(SQLServerReservadas) to High(SQLServerReservadas) do
      if SameText(Trim(Nombre), SQLServerReservadas[I]) then
        Exit(True);
  end
  else
    for I := Low(AccessReservadas) to High(AccessReservadas) do
      if SameText(Trim(Nombre), AccessReservadas[I]) then
        Exit(True);
end;

end.
