unit UClTipoObjeto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxGridCustomView, cxGrid, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls;

type
  TfrmTipoObjeto = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    Panel1: TPanel;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1idtipoobj: TcxGridDBColumn;
    cxGrid1DBTableView1nombretipoobj: TcxGridDBColumn;
    cxGrid1DBTableView1icon: TcxGridDBColumn;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton7: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTipoObjeto: TfrmTipoObjeto;

implementation

uses
  UCapaDatos, UExcelExport;

{$R *.dfm}

procedure TfrmTipoObjeto.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTipoObjeto.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmTipoObjeto.ToolButton1Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.
