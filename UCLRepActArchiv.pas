unit UCLRepActArchiv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls,
  Vcl.ComCtrls, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, Vcl.ToolWin, cxHyperLinkEdit,
  cxDBLookupComboBox, cxTextEdit;

type
  TfrmRepActArch = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    cxGrid1DBTableView1Idresp: TcxGridDBColumn;
    cxGrid1DBTableView1NombreResponsable: TcxGridDBColumn;
    cxGrid1DBTableView1usuario: TcxGridDBColumn;
    cxGrid1DBTableView1CorreoElect: TcxGridDBColumn;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    cxGrid1DBTableView1Rol: TcxGridDBColumn;
    cxGrid1DBTableView1Telefono: TcxGridDBColumn;
    cxGrid1DBTableView1password: TcxGridDBColumn;
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
  frmRepActArch: TfrmRepActArch;

implementation

uses
  UCapaDatos, UExcelExport;

{$R *.dfm}

procedure TfrmRepActArch.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRepActArch.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmRepActArch.DBNavigator3Click(Sender: TObject;
  Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_Resp_Gest_Arch.FieldByName('Idresp').AsInteger:=UDM.GetLastId('cl_Resp_Gest_Arch', 'Idresp');
  end;
end;

procedure TfrmRepActArch.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmRepActArch.ToolButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.
