unit UCL_Especialistas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, Vcl.ComCtrls, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls,
  Vcl.ToolWin, cxDBLookupComboBox;

type
  TfrmListEspec = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1Idespecialista: TcxGridDBColumn;
    cxGrid1DBTableView1Nombespecialista: TcxGridDBColumn;
    cxGrid1DBTableView1usuario: TcxGridDBColumn;
    cxGrid1DBTableView1CorreoElect: TcxGridDBColumn;
    cxGrid1DBTableView1NumControl: TcxGridDBColumn;
    cxGrid1DBTableView1Idcargo: TcxGridDBColumn;
    cxGrid1DBTableView1idcategoria: TcxGridDBColumn;
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmListEspec: TfrmListEspec;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmListEspec.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
