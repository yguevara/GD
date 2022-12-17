unit UCLFacultades;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ComCtrls, Vcl.DBCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ToolWin,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxNavigator, cxDBNavigator, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxEdit, dxDateRanges, cxDBData, cxRichEdit,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid;

type
  TfrmCLFacultades = class(TForm)
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1DBTableView1idfacultades: TcxGridDBColumn;
    cxGrid1DBTableView1facultades: TcxGridDBColumn;
    cxGrid1DBTableView1IdCargo: TcxGridDBColumn;
    procedure btnCloseClick(Sender: TObject);
    procedure btnSortClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    campot, campoi: string;
    filtrado: boolean;
    dst: Tdataset;
  end;

var
  frmCLFacultades: TfrmCLFacultades;
  s: string;
  nombrecampo, nombrecampoSel, opt: string;
  papa: Boolean;
  SQLOrig: WideString;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmCLFacultades.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLFacultades.btnSortClick(Sender: TObject);
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
    sql.Add('select ' + campoi + ' , ' + campot + ' from cl_facultadesgen order by ' + nombrecampoSel + ' ' + opt);
    try
      Active := True;
    except
    end;
  end;
end;

end.
