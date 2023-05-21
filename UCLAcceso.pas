unit UCLAcceso;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, Vcl.ComCtrls, cxGridLevel, cxClasses,
  cxGridCustomView, cxGrid, Vcl.ToolWin, Vcl.DBCtrls, cxDBNavigator,
  Vcl.ExtCtrls;

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
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure ToolButton4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCLAcceso: TfrmCLAcceso;

implementation

uses
  UCapaDatos, UExcelExport;

{$R *.dfm}

procedure TfrmCLAcceso.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLAcceso.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmCLAcceso.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_acceso.FieldByName('Idacceso').AsInteger := UDM.GetLastId('cl_acceso', 'Idacceso');
  end;
end;

procedure TfrmCLAcceso.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmCLAcceso.ToolButton4Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.

