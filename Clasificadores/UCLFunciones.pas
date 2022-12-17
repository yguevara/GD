unit UCLFunciones;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ComCtrls, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ToolWin,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  dxSkinsCore, dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, cxDBData, cxRichEdit,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxGridCustomView, cxGrid, cxDBNavigator;

type
  TfrmCLFunciones = class(TForm)
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1id: TcxGridDBColumn;
    cxGrid1DBTableView1cargo: TcxGridDBColumn;
    cxGrid1DBTableView1funciones: TcxGridDBColumn;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    procedure ToolButton1Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure edtfindChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    campot, campoi: string;
    filtrado: boolean;
    dst: Tdataset;
  end;

var
  frmCLFunciones: TfrmCLFunciones;
  s: string;
  nombrecampo, nombrecampoSel, opt: string;
  papa: Boolean;
  SQLOrig: WideString;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmCLFunciones.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLFunciones.edtfindChange(Sender: TObject);
var
  i: integer;
  cad: string;
begin
  {if Trim(edtfind.Text) = '' then
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
  end;}
end;

procedure TfrmCLFunciones.ToolButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLFunciones.ToolButton4Click(Sender: TObject);
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
    sql.Add('select ' + campoi + ' , ' + campot + ' from cl_funcionesgen order by ' + nombrecampoSel + ' ' + opt);
    try
      Active := True;
    except
    end;
  end;
end;

end.
