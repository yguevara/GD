unit UCLAcceso;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, Vcl.ComCtrls, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, Vcl.ToolWin, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls;

type
  TfrmCLAcceso = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1Idacceso: TcxGridDBColumn;
    cxGrid1DBTableView1NombreAcceso: TcxGridDBColumn;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCLAcceso: TfrmCLAcceso;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmCLAcceso.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.