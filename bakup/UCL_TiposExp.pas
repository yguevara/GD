unit UCL_TiposExp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, cxDBLookupComboBox, cxBlobEdit, Vcl.ComCtrls,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, Vcl.ToolWin, cxDBNavigator, Vcl.DBCtrls,
  Vcl.ExtCtrls, AdvPanel;

type
  TfrmTiposExp = class(TForm)
    AdvPanel1: TAdvPanel;
    DBNavigator3: TDBNavigator;
    cxDBNavigator3: TcxDBNavigator;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    btnClose: TToolButton;
    ToolButton4: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1IdTipoExp: TcxGridDBColumn;
    cxGrid1DBTableView1NombreTipoExp: TcxGridDBColumn;
    procedure btnCloseClick(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTiposExp: TfrmTiposExp;

implementation

uses
  UCapaDatos, UExcelExport;

{$R *.dfm}

procedure TfrmTiposExp.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTiposExp.FormActivate(Sender: TObject);
begin
 // UDM.RestauraGrid(cxGrid1DBTableView1);
end;

procedure TfrmTiposExp.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
//  UDM.SalvaConfigGrid(cxGrid1DBTableView1);
end;

procedure TfrmTiposExp.ToolButton4Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.
