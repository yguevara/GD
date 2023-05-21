unit UCLVariables;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, Vcl.DBCtrls, cxNavigator, cxDBNavigator, Vcl.ExtCtrls,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, dxDateRanges,
  Data.DB, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, cxDropDownEdit,
  cxVGrid, cxDBVGrid, cxInplaceContainer, dxBarBuiltInMenu, cxContainer,
  cxDBEdit, cxCheckBox, cxTextEdit, cxMaskEdit, cxBlobEdit, Vcl.StdCtrls,
  cxGroupBox, cxPC, Vcl.Buttons;

type
  TfrmVariables = class(TForm)
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    StatusBar1: TStatusBar;
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    cxPageControl1: TcxPageControl;
    tsform: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    cxDBVerticalGrid6: TcxDBVerticalGrid;
    cxDBVerticalGrid6IdVar: TcxDBEditorRow;
    cxDBVerticalGrid6NomVariable: TcxDBEditorRow;
    cxDBVerticalGrid6Etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid6tipo: TcxDBEditorRow;
    cxLong: TcxDBEditorRow;
    cxDBVerticalGrid6descripcion: TcxDBEditorRow;
    cxDBVerticalGrid6ListaDesplegable: TcxDBEditorRow;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1IdVar: TcxGridDBColumn;
    cxGrid1DBTableView1NomVariable: TcxGridDBColumn;
    cxGrid1DBTableView1Etiqueta: TcxGridDBColumn;
    cxGrid1DBTableView1tipo: TcxGridDBColumn;
    cxGrid1DBTableView1longitud: TcxGridDBColumn;
    cxGrid1DBTableView1descripcion: TcxGridDBColumn;
    cxGrid1DBTableView1ListaDesplegable: TcxGridDBColumn;
    tsFormulario: TcxTabSheet;
    Panel1: TPanel;
    Label6: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    Label1: TLabel;
    cxDBComboBox1: TcxDBComboBox;
    cxDBBlobEdit2: TcxDBBlobEdit;
    Label3: TLabel;
    cxDBCheckBox1: TcxDBCheckBox;
    cxDBTextEdit2: TcxDBTextEdit;
    Label2: TLabel;
    Label10: TLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure cxDBBlobEdit2PropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure ToolButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure cxGrid1DBTableView1descripcionPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVariables: TfrmVariables;

implementation

uses
  UCapaDatos, UVeditor, UExcelExport;

{$R *.dfm}

procedure TfrmVariables.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVariables.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmVariables.cxDBBlobEdit2PropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  { if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.cl_facultadesgen.FieldByName('facultades').Value = null) or (trim(UDM.cl_facultadesgen.FieldByName('facultades').Value) = '') then
    begin
      udm.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;  }
  CampoTexto(@UDM.dscl_variables, 'descripcion', 'Descripciones generales de la variable ' + UDM.cl_variables.FieldByName('etiqueta').AsString);
end;

procedure TfrmVariables.cxGrid1DBTableView1descripcionPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  CampoTexto(@UDM.dscl_variables, 'descripcion', 'Descripciones generales de la variable ' + UDM.cl_variables.FieldByName('etiqueta').AsString);
end;

procedure TfrmVariables.DBNavigator3Click(Sender: TObject;
  Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_variables.FieldByName('IdVar').AsInteger:=UDM.GetLastId('cl_variables', 'IdVar');
  end;
end;

procedure TfrmVariables.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmVariables.ToolButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.
