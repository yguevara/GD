unit UCLVarProject;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  cxDBLookupComboBox, Vcl.ComCtrls, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  Vcl.DBCtrls, cxDBNavigator, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ToolWin, cxVGrid,
  cxDBVGrid, cxInplaceContainer, cxDropDownEdit, AdvSplitter, dxBarBuiltInMenu,
  cxImageComboBox, cxPC, cxBlobEdit, System.ImageList, Vcl.ImgList, cxCheckBox;

type
  TfrmVarProject = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    ToolButton1: TToolButton;
    cxPageControl2: TcxPageControl;
    tsNewStruct: TcxTabSheet;
    PVariables: TPanel;
    AdvSplitter1: TAdvSplitter;
    Panel1: TPanel;
    btnAsignVarVir: TSpeedButton;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    cxDBVerticalGrid6: TcxDBVerticalGrid;
    cxDBVerticalGrid6IdVar: TcxDBEditorRow;
    cxDBVerticalGrid6NomVariable: TcxDBEditorRow;
    cxDBVerticalGrid6Etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid6tipo: TcxDBEditorRow;
    cxDBVerticalGrid6longitud: TcxDBEditorRow;
    cxDBVerticalGrid6descripcion: TcxDBEditorRow;
    cxDBVerticalGrid6ListaDesplegable: TcxDBEditorRow;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1IdEstructura: TcxGridDBColumn;
    cxGrid1DBTableView1Orden: TcxGridDBColumn;
    cxGrid1DBTableView1IdVar: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    ILv2: TImageList;
    SpeedButton1: TSpeedButton;
    procedure btnhlpClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnAsignVarVirClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btnExportVarExcelClick(Sender: TObject);
    procedure cxDBVerticalGrid6descripcionEditPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ActCmp(Action: boolean);
  end;

var
  frmVarProject: TfrmVarProject;

implementation

uses
  UCapaDatos, UExcelExport, UVeditor;

{$R *.dfm}

procedure TfrmVarProject.ActCmp(Action: boolean);
begin
end;

procedure TfrmVarProject.btnAsignVarVirClick(Sender: TObject);
var
  tmp: Variant;
begin
  UDM.cl_VarProject.Append;
  tmp := UDM.Conn.ExecSQLScalar('select max(orden)+1 as orden from cl_varproject');
  if tmp = null then
    tmp := 0;
  UDM.cl_VarProject.FieldByName('orden').Value := tmp;
  UDM.cl_VarProject.FieldByName('IdVar').AsInteger := UDM.cl_variables.FieldByName('IdVar').AsInteger;
end;

procedure TfrmVarProject.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVarProject.btnExportVarExcelClick(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TfrmVarProject.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmVarProject.cxDBVerticalGrid6descripcionEditPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.cl_variables.FieldByName('Descripcion').Value = null) or (trim(UDM.cl_variables.FieldByName('Descripcion').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  CampoTexto(@UDM.dscl_variables,  'Descripcion', 'Descripción de la variable.');
end;

procedure TfrmVarProject.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmVarProject.SpeedButton2Click(Sender: TObject);
begin
  //ExcelExport(nil, cxGrid2);
end;

procedure TfrmVarProject.ToolButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.

