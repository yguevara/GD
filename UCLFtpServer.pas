unit UCLFtpServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, cxTextEdit,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, Vcl.ComCtrls,
  cxGridLevel, cxClasses, cxGridCustomView, cxGrid, Vcl.ToolWin, Vcl.DBCtrls,
  cxDBNavigator, Vcl.ExtCtrls, cxDropDownEdit, JvExControls, JvButton,
  JvTransparentButton, Vcl.StdCtrls;

type
  TfrmListFTPServer = class(TForm)
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
    dscl_ftp_Server: TDataSource;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnExcelExport: TJvTransparentButton;
    btnExpand: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnBestFitSS: TJvTransparentButton;
    btnExportSSExcel: TJvTransparentButton;
    Edit1: TEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure ToolButton2Click(Sender: TObject);
    procedure btnExpandClick(Sender: TObject);
    procedure btnExcelExportClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSystemHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmListFTPServer: TfrmListFTPServer;

implementation

uses
  UCapaDatos, UExcelExport, USystemMsg;

{$R *.dfm}

procedure TfrmListFTPServer.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmListFTPServer.btnExcelExportClick(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TfrmListFTPServer.btnExpandClick(Sender: TObject);
begin
  try
    cxGrid1DBTableView1.ApplyBestFit();
    UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'cl_servidoresFTP');
  except
  end;
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

procedure TfrmListFTPServer.btnSystemHelpClick(Sender: TObject);
begin
  with TfrmsystemMSG.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;

end;

procedure TfrmListFTPServer.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_ftp_Server.FieldByName('Idservidor').AsInteger := UDM.GetLastId('cl_ftp_Server', 'Idservidor');
  end;
end;

procedure TfrmListFTPServer.FormActivate(Sender: TObject);
begin
  Edit1.Focused;
  Edit1.SetFocus;
  UDM.RestauraGrid(cxGrid1DBTableView1, 'cl_servidoresFTP');
end;

procedure TfrmListFTPServer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'cl_servidoresFTP');
end;

procedure TfrmListFTPServer.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 112 then
  begin
    with TfrmsystemMSG.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
  end;
end;

procedure TfrmListFTPServer.ToolButton2Click(Sender: TObject);
begin
  if cxGrid1DBTableView1.DataController.DataSet.RecordCount > 0 then
    cxGrid1DBTableView1.ApplyBestFit();
end;

end.

