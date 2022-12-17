unit UCLCargo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ToolWin, Data.DB, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmCLCargo = class(TForm)
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    Panel1: TPanel;
    GDATA: TDBGrid;
    dbnCargos: TDBNavigator;
    edtfind: TEdit;
    StatusBar2: TStatusBar;
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure GDATACellClick(Column: TColumn);
    procedure edtfindChange(Sender: TObject);
    procedure edtfindExit(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    campot, campoi: string;
    filtrado: boolean;
    dst: Tdataset;
  end;

var
  frmCLCargo: TfrmCLCargo;
  s: string;
  nombrecampo, nombrecampoSel, opt: string;
  papa: Boolean;
  SQLOrig: WideString;
 // FListaCod: TFListaCod;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmCLCargo.edtfindChange(Sender: TObject);
var
  i: integer;
  cad: string;
begin
  if Trim(edtfind.Text) = '' then
  begin
    with TFDQuery(GDATA.DataSource.DataSet) do
    begin
      Prepare;
      Filtered := False;
      papa := True;
      filtrado := False;
    end;
    Exit;
  end;
  for i := 0 to GDATA.Columns.Count - 1 do
    if (GDATA.Columns[i].Field.DataType = ftString) or (GDATA.Columns[i].Field.DataType = ftWideString) or (GDATA.Columns[i].Field.DataType = ftMemo) or (GDATA.Columns[i].Field.DataType = ftWideMemo) or (GDATA.Columns[i].Field.DataType = ftInteger) or (GDATA.Columns[i].Field.DataType = ftSmallint) then
    begin
      if GDATA.Columns[i].Field.FieldKind <> fkLookup then
      begin
        if cad = '' then
        begin
          cad := 'lower(' + GDATA.Columns[i].Field.FieldName + ') LIKE ' + QuotedStr('%' + AnsiLowerCase(edtfind.Text) + '%')
        end
        else
        begin
          cad := cad + ' or lower(' + GDATA.Columns[i].Field.FieldName + ') LIKE ' + QuotedStr('%' + AnsiLowerCase(edtfind.Text) + '%');
        end;
      end;
    end;
  with TFDQuery(GDATA.DataSource.DataSet) do
  begin
    Prepare;
    Filtered := False;
    Filter := cad;
    Filtered := True;
    papa := True;
    filtrado := True;
  end;
end;

procedure TfrmCLCargo.edtfindExit(Sender: TObject);
begin
  if (GDATA.DataSource.DataSet.Filtered) and (papa) then
  begin
    GDATA.DataSource.DataSet.Refresh;
    papa := False;
  end;
end;

procedure TfrmCLCargo.GDATACellClick(Column: TColumn);
begin
  nombrecampoSel := Column.FieldName;
end;

procedure TfrmCLCargo.ToolButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLCargo.ToolButton4Click(Sender: TObject);
begin
  if opt = 'ASC' then
    opt := 'DESC'
  else
    opt := 'ASC';
  if opt = '' then
    opt := 'ASC';
  with UDM.cl_cargo do
  begin
    Active := False;
    sql.Clear;
    sql.Add('select ' + campoi + ' , ' + campot + ' from cl_cargo order by ' + nombrecampoSel + ' ' + opt);
    try
      Active := True;
    except
    end;
  end;

end;

end.

