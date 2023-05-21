unit UCLSoporte;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, Vcl.ComCtrls, cxGridLevel, cxClasses,
  cxGridCustomView, cxGrid, Vcl.ToolWin, Vcl.DBCtrls, cxDBNavigator,
  Vcl.ExtCtrls, Vcl.Buttons;

type
  TfrmCLSoporte = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1Idsoporte: TcxGridDBColumn;
    cxGrid1DBTableView1Nombresoporte: TcxGridDBColumn;
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
    procedure ToolButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCLSoporte: TfrmCLSoporte;

implementation

uses
  UCapaDatos, UExcelExport;

{$R *.dfm}

procedure TfrmCLSoporte.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLSoporte.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmCLSoporte.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_soporte.FieldByName('Idsoporte').AsInteger := UDM.GetLastId('cl_soporte', 'Idsoporte');
  end;
end;

procedure TfrmCLSoporte.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmCLSoporte.ToolButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.

