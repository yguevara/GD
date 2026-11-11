unit UCL_Expediente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, cxDBLookupComboBox, cxBlobEdit, Vcl.ComCtrls,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, cxDBNavigator, Vcl.DBCtrls, Vcl.ExtCtrls,
  AdvPanel, Vcl.ToolWin;

type
  TfrmExpediente = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    btnClose: TToolButton;
    ToolButton4: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    AdvPanel1: TAdvPanel;
    DBNavigator3: TDBNavigator;
    cxDBNavigator3: TcxDBNavigator;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1IDExpediente: TcxGridDBColumn;
    cxGrid1DBTableView1Nombre: TcxGridDBColumn;
    cxGrid1DBTableView1IdTipoExp: TcxGridDBColumn;
    cxGrid1DBTableView1FechaInicio: TcxGridDBColumn;
    cxGrid1DBTableView1FechaCierre: TcxGridDBColumn;
    cxGrid1DBTableView1cerrado: TcxGridDBColumn;
    cxGrid1DBTableView1comentario: TcxGridDBColumn;
    ToolButton2: TToolButton;
    procedure cxGrid1DBTableView1comentarioPropertiesButtonClick(
      Sender: TObject; AButtonIndex: Integer);
    procedure btnCloseClick(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmExpediente: TfrmExpediente;

implementation

uses
  UCapaDatos, UVeditor, UExcelExport;

{$R *.dfm}

procedure TfrmExpediente.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmExpediente.cxGrid1DBTableView1comentarioPropertiesButtonClick(
  Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.cl_expediente.FieldByName('comentario').Value = null) or (trim(UDM.cl_expediente.FieldByName('comentario').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  //NombreSerieDocAsig := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  CampoTexto(@UDM.dscl_expediente, 'comentario', 'Comentarios sobre el expediene actual. ');
end;

procedure TfrmExpediente.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;


procedure TfrmExpediente.ToolButton2Click(Sender: TObject);
begin
  if cxGrid1DBTableView1.DataController.DataSet.RecordCount>0 then
    cxGrid1DBTableView1.ApplyBestFit();
end;

procedure TfrmExpediente.ToolButton4Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.
