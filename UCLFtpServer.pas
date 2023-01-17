unit UCLFtpServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, cxTextEdit, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, Vcl.ComCtrls, cxGridLevel, cxClasses,
  cxGridCustomView, cxGrid, Vcl.ToolWin, Vcl.DBCtrls, cxDBNavigator,
  Vcl.ExtCtrls, cxDropDownEdit;

type
  TfrmListFTPServer = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1Idservidor: TcxGridDBColumn;
    cxGrid1DBTableView1path: TcxGridDBColumn;
    cxGrid1DBTableView1user: TcxGridDBColumn;
    cxGrid1DBTableView1pass: TcxGridDBColumn;
    cxGrid1DBTableView1puerto: TcxGridDBColumn;
    cxGrid1DBTableView1ipserver: TcxGridDBColumn;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    cxGrid1DBTableView1etiquetaServ: TcxGridDBColumn;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmListFTPServer: TfrmListFTPServer;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmListFTPServer.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmListFTPServer.btnhlpClick(Sender: TObject);
{var
  i:integer;
  cad:string;
  list:TStringList;
begin
  list:=TStringList.Create;
  cxGrid1DBTableView1.ApplyBestFit();
  for i := 0 to cxGrid1DBTableView1.ColumnCount-1 do begin
    cad:=IntToStr(cxGrid1DBTableView1.Columns[i].Width);
    list.Add(cad);
  end;
  list.SaveToFile('C:\Temp\largocol.txt');
  ShowMessage('YAAAAA!!!!');
end;}
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

end.
