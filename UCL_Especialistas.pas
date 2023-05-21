unit UCL_Especialistas;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  Vcl.ComCtrls, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, Vcl.DBCtrls,
  cxDBNavigator, Vcl.ExtCtrls, Vcl.ToolWin, cxDBLookupComboBox;

type
  TfrmListEspec = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1Idespecialista: TcxGridDBColumn;
    cxGrid1DBTableView1Nombespecialista: TcxGridDBColumn;
    cxGrid1DBTableView1usuario: TcxGridDBColumn;
    cxGrid1DBTableView1CorreoElect: TcxGridDBColumn;
    cxGrid1DBTableView1NumControl: TcxGridDBColumn;
    cxGrid1DBTableView1Idcargo: TcxGridDBColumn;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmListEspec: TfrmListEspec;

implementation

uses
  UCapaDatos, UExcelExport;

{$R *.dfm}

procedure TfrmListEspec.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmListEspec.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmListEspec.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmListEspec.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.cl_especialista.Active:=False;
  UDM.cl_especialista.Active:=True;
end;

procedure TfrmListEspec.ToolButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.

