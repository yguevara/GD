unit UCLTipoEstructura;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ToolWin, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  Vcl.DBCtrls, cxDBNavigator, JvExControls, JvButton, JvTransparentButton,
  Vcl.ExtCtrls, cxDBLookupComboBox, cxBlobEdit, Vcl.Buttons;

type
  TfrmTipoEstructura = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    Panel1: TPanel;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    StatusBar1: TStatusBar;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1DBTableView1Idestructura: TcxGridDBColumn;
    cxGrid1DBTableView1Nombreestructura: TcxGridDBColumn;
    cxGrid1DBTableView1Descripcion: TcxGridDBColumn;
    cxGrid1DBTableView1idtipoobj: TcxGridDBColumn;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    SpeedButton3: TSpeedButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    cxGrid1DBTableView1Administrador: TcxGridDBColumn;
    cxGrid1DBTableView1Padre: TcxGridDBColumn;
    procedure btnhlpClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnFuncionesClick(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure cxGrid1DBTableView1DescripcionPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTipoEstructura: TfrmTipoEstructura;

implementation

uses
  UCapaDatos, UCLVarProject, UExcelExport, UVeditor;

{$R *.dfm}

procedure TfrmTipoEstructura.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTipoEstructura.btnFuncionesClick(Sender: TObject);
begin
  if UDM.cl_tipoestructura.RecordCount > 0 then
  begin
    with TfrmVarProject.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
  end
  else
  begin
    UDM.sms('Debe existir al menos una estructura válida.', 2);
    Exit;
  end;
end;

procedure TfrmTipoEstructura.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmTipoEstructura.cxGrid1DBTableView1DescripcionPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.cl_tipoestructura.FieldByName('Descripcion').Value = null) or (trim(UDM.cl_tipoestructura.FieldByName('Descripcion').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  CampoTexto(@UDM.dscl_tipoestructura, 'Descripcion', 'Observaciones de la serie documental');
end;

procedure TfrmTipoEstructura.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmTipoEstructura.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  UDM.cl_tipoestructura.Active:=False;
  UDM.cl_tipoestructura.Active:=True;
end;

procedure TfrmTipoEstructura.ToolButton1Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.

