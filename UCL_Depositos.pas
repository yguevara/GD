unit UCL_Depositos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, Vcl.ComCtrls, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls,
  Vcl.ToolWin, cxBlobEdit;

type
  TfrmDeposito = class(TForm)
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
    cxGrid1DBTableView1inventario: TcxGridDBColumn;
    cxGrid1DBTableView1coddep: TcxGridDBColumn;
    cxGrid1DBTableView1cant_gav: TcxGridDBColumn;
    cxGrid1DBTableView1descripcion: TcxGridDBColumn;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure cxGrid1DBTableView1descripcionPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure ToolButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDeposito: TfrmDeposito;

implementation

uses
  UCapaDatos, UVeditor, UExcelExport;

{$R *.dfm}

procedure TfrmDeposito.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDeposito.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmDeposito.cxGrid1DBTableView1descripcionPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.cl_deposito.FieldByName('descripcion').Value = null) or (trim(UDM.cl_deposito.FieldByName('descripcion').Value) = '') then
    begin
      udm.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  CampoTexto(@UDM.dscl_deposito, 'descripcion', 'Descripción del depósito' + UDM.cl_deposito.FieldByName('coddep').AsString);
end;

procedure TfrmDeposito.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmDeposito.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.cl_deposito.Active:=False;
  UDM.cl_deposito.Active:=True;
end;

procedure TfrmDeposito.ToolButton1Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.
