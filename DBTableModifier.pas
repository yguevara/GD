unit DBTableModifier;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Phys, FireDAC.Stan.Option, Variants;

type
  TDBTableModifier = class
  private
    FConnection: TFDConnection;
    FDatabaseType: string;
    FProgressCallback: TProc<string>;

    procedure DetectDatabaseType;
    procedure CopyTableStructure(const TableName, TempTableName: string; const NewType: string);
    procedure CopyTableData(const TableName, TempTableName: string);
    procedure RecreateConstraints(const TableName, TempTableName: string);
    procedure RenameTable(const OldName, NewName: string);
    procedure ShowProgress(const Msg: string);
  public
    constructor Create(AConnection: TFDConnection; AProgressCallback: TProc<string>);
    procedure ChangePrimaryKeyFieldType(const TableName, FieldName, NewType: string);
    procedure UpdateFieldValue(const TableName, FieldName: string; const NewValue: Variant);
    procedure ExecuteScript(const SQLScript: string);
    procedure CreateOrUpdateTable(const TableName: string; const CreateTableSQL: string; const AlterTableSQL: string);

    property DatabaseType: string read FDatabaseType;
  end;

implementation

constructor TDBTableModifier.Create(AConnection: TFDConnection; AProgressCallback: TProc<string>);
begin
  FConnection := AConnection;
  FProgressCallback := AProgressCallback;
  DetectDatabaseType;
end;

procedure TDBTableModifier.DetectDatabaseType;
begin
  if FConnection.DriverName = 'MSSQL' then
    FDatabaseType := 'SQLServer'
  else if FConnection.DriverName = 'MSAcc' then
    FDatabaseType := 'MSAccess'
  else
    raise Exception.Create('Tipo de base de datos no compatible');

  ShowProgress('Tipo de base de datos detectado: ' + FDatabaseType);
end;

procedure TDBTableModifier.CopyTableStructure(const TableName, TempTableName: string; const NewType: string);
var
  SQL: string;
begin
  // Example of creating the temp table with modified structure
  SQL := Format('SELECT TOP 0 * INTO %s FROM %s', [TempTableName, TableName]);
  FConnection.ExecSQL(SQL);
  ShowProgress('Estructura de tabla temporal creada: ' + TempTableName);

  // Modify the specific field type
  SQL := Format('ALTER TABLE %s ALTER COLUMN FieldName %s', [TempTableName, NewType]);
  FConnection.ExecSQL(SQL);
  ShowProgress(Format('Tipo de campo cambiado en la tabla temporal %s', [TempTableName]));
end;

procedure TDBTableModifier.CopyTableData(const TableName, TempTableName: string);
var
  SQL: string;
begin
  // Copy data from original to temporary table
  SQL := Format('INSERT INTO %s SELECT * FROM %s', [TempTableName, TableName]);
  FConnection.ExecSQL(SQL);
  ShowProgress(Format('Datos copiados de %s a %s', [TableName, TempTableName]));
end;

procedure TDBTableModifier.RecreateConstraints(const TableName, TempTableName: string);
begin
  // Implementation for recreating constraints from original table to temp table
  ShowProgress('Recreando restricciones en la tabla temporal: ' + TempTableName);
  // Detailed implementation needed here
end;

procedure TDBTableModifier.RenameTable(const OldName, NewName: string);
var
  SQL: string;
begin
  SQL := Format('EXEC sp_rename %s, %s', [OldName, NewName]);
  if FDatabaseType = 'MSAccess' then
    SQL := Format('RENAME TABLE %s TO %s', [OldName, NewName]);

  FConnection.ExecSQL(SQL);
  ShowProgress(Format('Cambiado el nombre de la tabla %s a %s', [OldName, NewName]));
end;

procedure TDBTableModifier.ChangePrimaryKeyFieldType(const TableName, FieldName, NewType: string);
var
  TempTableName: string;
begin
  TempTableName := TableName + '_Temp';

  // Start transaction
  FConnection.StartTransaction;
  try
    CopyTableStructure(TableName, TempTableName, NewType);
    CopyTableData(TableName, TempTableName);
    RecreateConstraints(TableName, TempTableName);

    // Drop original table and rename temp table to original name
    FConnection.ExecSQL('DROP TABLE ' + TableName);
    RenameTable(TempTableName, TableName);

    FConnection.Commit;
    ShowProgress('Tipo de campo de clave primaria cambiado con éxito para la tabla: ' + TableName);
  except
    FConnection.Rollback;
    ShowProgress('Error occurred. Changes rolled back.');
    raise;
  end;
end;

procedure TDBTableModifier.UpdateFieldValue(const TableName, FieldName: string; const NewValue: Variant);
var
  SQL: string;
begin
  SQL := Format('UPDATE %s SET %s = :NewValue', [TableName, FieldName]);
  FConnection.ExecSQL(SQL, [NewValue]);
  ShowProgress(Format('Field %s in table %s updated with new value.', [FieldName, TableName]));
end;

procedure TDBTableModifier.ShowProgress(const Msg: string);
begin
  if Assigned(FProgressCallback) then
    FProgressCallback(Msg);
end;

procedure TDBTableModifier.ExecuteScript(const SQLScript: string);
begin
  FConnection.ExecSQL(SQLScript);
  ShowProgress('Script executed successfully.');
end;

procedure TDBTableModifier.CreateOrUpdateTable(const TableName: string; const CreateTableSQL: string; const AlterTableSQL: string);
begin
  try
    // Try creating the table
    try
      FConnection.ExecSQL(CreateTableSQL);
      ShowProgress('Table created successfully: ' + TableName);
    except
      on E: Exception do
      begin
        // If table already exists, apply the alter statement
        if E.Message.Contains('already exists') then
        begin
          FConnection.ExecSQL(AlterTableSQL);
          ShowProgress('Table updated successfully: ' + TableName);
        end
        else
          raise;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowProgress('Error creating or updating table: ' + E.Message);
      raise;
    end;
  end;
end;

end.

