unit UCLSeriesDocumentales;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ToolWin, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxEdit, dxSkinsCore, dxSkinsDefaultPainters,
  cxVGrid, cxDBVGrid, cxInplaceContainer, Vcl.ExtCtrls, AdvSplitter,
  cxDropDownEdit, Vcl.DBCtrls, cxBlobEdit, cxNavigator, cxDBNavigator,
  cxCustomData, cxFilter, cxData, cxDataStorage, dxDateRanges, Data.DB, cxDBData,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGridLevel,
  cxClasses, cxGridCustomView, cxGrid, cxDBLookupComboBox, JvExControls,
  JvButton, JvTransparentButton, cxCalendar, dxBarBuiltInMenu, cxContainer,
  cxCheckBox, cxDBEdit, cxMaskEdit, cxTextEdit, Vcl.StdCtrls, cxPC, cxLookupEdit,
  cxDBLookupEdit, cxMemo, Vcl.Buttons, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, cxButtonEdit, JvBaseDlg, JvSelectDirectory, JvExExtCtrls,
  JvExtComponent, JvCaptionPanel, AdvGroupBox, AdvPanel;

type
  TfrmCLSeries = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    pSeries: TPanel;
    AdvSplitter1: TAdvSplitter;
    Panel2: TPanel;
    cxDBNavigator2: TcxDBNavigator;
    DBNavigator2: TDBNavigator;
    Panel4: TPanel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1DBTableView1codserie: TcxGridDBColumn;
    cxGrid1DBTableView1serie: TcxGridDBColumn;
    Timer1: TTimer;
    pSubSeries: TPanel;
    Panel1: TPanel;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    Panel3: TPanel;
    Panel6: TPanel;
    cxPageControl1: TcxPageControl;
    tsform: TcxTabSheet;
    cxDBVerticalGrid6: TcxDBVerticalGrid;
    cxDBVerticalGrid6IdVar: TcxDBEditorRow;
    cxDBVerticalGrid6NomVariable: TcxDBEditorRow;
    cxDBVerticalGrid6Etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid6tipo: TcxDBEditorRow;
    cxLong: TcxDBEditorRow;
    cxDBVerticalGrid6descripcion: TcxDBEditorRow;
    cxDBVerticalGrid6ListaDesplegable: TcxDBEditorRow;
    cxTabSheet2: TcxTabSheet;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    tsFormulario: TcxTabSheet;
    ToolButton4: TToolButton;
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton3: TSpeedButton;
    dsSeries: TDataSource;
    GroupBox3: TGroupBox;
    GroupBox2: TGroupBox;
    Label15: TLabel;
    edtcodss: TcxDBTextEdit;
    cxGridDBTableView1codserie: TcxGridDBColumn;
    cxGridDBTableView1codsubs: TcxGridDBColumn;
    cxGridDBTableView1subserie: TcxGridDBColumn;
    cxGridDBTableView1soporte: TcxGridDBColumn;
    cxGridDBTableView1tipodoc: TcxGridDBColumn;
    cxGridDBTableView1Activa: TcxGridDBColumn;
    cxGridDBTableView1Detalle: TcxGridDBColumn;
    cxGridDBTableView1Vigencia: TcxGridDBColumn;
    cxGridDBTableView1ayear: TcxGridDBColumn;
    cxGridDBTableView1tgestion: TcxGridDBColumn;
    cxGridDBTableView1tcentral: TcxGridDBColumn;
    cxGridDBTableView1destino: TcxGridDBColumn;
    cxGridDBTableView1tipoarchivo: TcxGridDBColumn;
    cxGridDBTableView1pc: TcxGridDBColumn;
    cxGridDBTableView1carpeta: TcxGridDBColumn;
    cxGridDBTableView1acceso: TcxGridDBColumn;
    cxGridDBTableView1frecuencia: TcxGridDBColumn;
    cxGridDBTableView1tiempo: TcxGridDBColumn;
    cxGridDBTableView1observacion: TcxGridDBColumn;
    cxGridDBTableView1correo: TcxGridDBColumn;
    cxGridDBTableView1archivo: TcxGridDBColumn;
    cxGridDBTableView1deposito: TcxGridDBColumn;
    cxGridDBTableView1gaveta: TcxGridDBColumn;
    SD: TJvSelectDirectory;
    cxGridDBTableView1cargo: TcxGridDBColumn;
    Label9: TLabel;
    lcbSoporte: TcxDBLookupComboBox;
    edtNombreSS: TcxDBTextEdit;
    Label2: TLabel;
    lcbTipoDoc: TcxDBLookupComboBox;
    Label7: TLabel;
    cxDBCheckBox1: TcxDBCheckBox;
    edtObservaciones: TcxDBBlobEdit;
    GroupBox4: TGroupBox;
    Label8: TLabel;
    edtAnio: TcxDBTextEdit;
    Label11: TLabel;
    Label12: TLabel;
    edtArchCentral: TcxDBTextEdit;
    edtArchGestion: TcxDBTextEdit;
    AdvGroupBox1: TAdvGroupBox;
    Label4: TLabel;
    Label6: TLabel;
    Label1: TLabel;
    lcbAcceso: TcxDBLookupComboBox;
    lcbDestino: TcxDBLookupComboBox;
    Label10: TLabel;
    GroupBox6: TGroupBox;
    Label21: TLabel;
    lcbServer: TcxDBLookupComboBox;
    cxDBTextEdit6: TcxDBTextEdit;
    Label22: TLabel;
    cxDBTextEdit7: TcxDBTextEdit;
    Label25: TLabel;
    cxDBBlobEdit1: TcxDBBlobEdit;
    Label18: TLabel;
    cpInfoPathSubSeries: TJvCaptionPanel;
    lbl1: TLabel;
    btnSelectDir: TSpeedButton;
    edt1: TEdit;
    cbbarchivo: TcxDBLookupComboBox;
    Label3: TLabel;
    jvcpArchivo: TJvCaptionPanel;
    cmdArch: TFDQuery;
    btnViewDetailFile: TJvTransparentButton;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid2CategoryRow6: TcxCategoryRow;
    dscmdArch: TDataSource;
    cxDBVerticalGrid2Cod: TcxDBEditorRow;
    cxDBVerticalGrid2nombreArchivo: TcxDBEditorRow;
    cxDBVerticalGrid2Tipo: TcxDBEditorRow;
    cxDBVerticalGrid2Idresp: TcxDBEditorRow;
    cxDBVerticalGrid2croquis: TcxDBEditorRow;
    cxDBVerticalGrid2Foto: TcxDBEditorRow;
    cxDBVerticalGrid2Descripcion: TcxDBEditorRow;
    btnServerDetailView: TJvTransparentButton;
    cmdServer: TFDQuery;
    dscmdServer: TDataSource;
    jvcpServerDetail: TJvCaptionPanel;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxCategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid1Idservidor: TcxDBEditorRow;
    cxDBVerticalGrid1etiquetaServ: TcxDBEditorRow;
    cxDBVerticalGrid1ipserver: TcxDBEditorRow;
    cxDBVerticalGrid1path: TcxDBEditorRow;
    cxDBVerticalGrid1user: TcxDBEditorRow;
    cxDBVerticalGrid1pass: TcxDBEditorRow;
    cxDBVerticalGrid1puerto: TcxDBEditorRow;
    AdvPanel3: TAdvPanel;
    GroupBox1: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    lcbDetalle: TcxDBLookupComboBox;
    lcbVigencia: TcxDBLookupComboBox;
    GroupBox5: TGroupBox;
    Label16: TLabel;
    Label17: TLabel;
    cxDBLookupComboBox1: TcxDBLookupComboBox;
    cxDBTextEdit3: TcxDBTextEdit;
    btnGestDetail: TJvTransparentButton;
    lcbGestor: TcxDBLookupComboBox;
    jvcpGestor: TJvCaptionPanel;
    cxDBVerticalGrid3: TcxDBVerticalGrid;
    cxCategoryRow2: TcxCategoryRow;
    cmdGestor: TFDQuery;
    dscmdGestor: TDataSource;
    cxDBVerticalGrid3Idresp: TcxDBEditorRow;
    cxDBVerticalGrid3NombreResponsable: TcxDBEditorRow;
    cxDBVerticalGrid3usuario: TcxDBEditorRow;
    cxDBVerticalGrid3password: TcxDBEditorRow;
    cxDBVerticalGrid3CorreoElect: TcxDBEditorRow;
    cxDBVerticalGrid3rol: TcxDBEditorRow;
    cxDBVerticalGrid3Telefono: TcxDBEditorRow;
    AdvPanel5: TAdvPanel;
    SpeedButton5: TSpeedButton;
    AdvPanel2: TAdvPanel;
    SpeedButton4: TSpeedButton;
    AdvPanel1: TAdvPanel;
    SpeedButton6: TSpeedButton;
    AdvPanel6: TAdvPanel;
    SpeedButton7: TSpeedButton;
    ToolButton1: TToolButton;
    cxGridDBTableView1fechaaprov: TcxGridDBColumn;
    cxDBDateEdit1: TcxDBDateEdit;
    Label5: TLabel;
    lblTipoSerie: TLabel;
    lcbTipoSerie: TcxDBLookupComboBox;
    procedure btnCloseClick(Sender: TObject);
    procedure btnFuncionesClick(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
    procedure cxDBVerticalGrid6observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxGridDBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure JvTransparentButton2Click(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure dsSeriesDataChange(Sender: TObject; Field: TField);
    procedure edtObservacionesPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxGridDBTableView1carpetaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnSelectDirClick(Sender: TObject);
    procedure cxDBBlobEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnViewDetailFileClick(Sender: TObject);
    procedure btnServerDetailViewClick(Sender: TObject);
    procedure btnGestDetailClick(Sender: TObject);
    procedure jvcpGestorButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edtAnioKeyPress(Sender: TObject; var Key: Char);
    procedure edtArchCentralKeyPress(Sender: TObject; var Key: Char);
    procedure edtArchGestionKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCLSeries: TfrmCLSeries;

implementation

uses
  UCapaDatos, UVarVirtualVar, UVeditor, UExcelExport;

{$R *.dfm}

procedure TfrmCLSeries.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLSeries.btnFuncionesClick(Sender: TObject);
begin
  if UDM.cl_subseries.RecordCount > 0 then
  begin
    UDM.UpdateVarSubS(UDM.cl_subseries.FieldByName('codsubs').AsString);
    TipoObj := 'S';
    with TfrmVarVirtualVar.Create(nil) do
    try
      cxGridDBTableView1.DataController.DataSource := UDM.dsVarDispSubS;
      if TipoObj = 'S' then
        Caption := 'Variables asignadas a la Serie documental ' + AnsiQuotedStr(UDM.cl_subseries.FieldByName('subserie').AsString, '"');
      ShowModal;
    finally
      Free;
    end;
  end
  else
  begin
    UDM.sms('Debe existir al menos una serie documental valida.', 2);
    Exit;
  end;
end;

procedure TfrmCLSeries.btnGestDetailClick(Sender: TObject);
begin
  if (trim(UDM.cl_subseries.FieldByName('cargo').AsString) = '') or (UDM.cl_subseries.FieldByName('cargo').Value = null) then
  begin
    UDM.sms('Debe especificar un gestor de serie documental válido.', 2);
    Exit;
  end;
  jvcpGestor.Visible := True;
  with cmdGestor do
  begin
    Active := False;
    Params[0].Value := UDM.cl_subseries.FieldByName('cargo').AsInteger;
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo consultar los detalles del gestor seleccionado. Motivo: ' + E.Message, 3);
        Exit;
      end;
    end;
  end;
end;

procedure TfrmCLSeries.btnSelectDirClick(Sender: TObject);
begin
  if SD.Execute then
    if trim(sd.Directory) <> '' then
    begin
      if (UDM.cl_subseries.State <> dsInsert) and (UDM.cl_subseries.State <> dsEdit) then
        UDM.cl_subseries.Edit;
      UDM.cl_subseries.FieldByName('carpeta').AsString := SD.Directory;
      edt1.Text := SD.Directory;
    end;
end;

procedure TfrmCLSeries.btnServerDetailViewClick(Sender: TObject);
begin
  cmdServer.Active := False;
  cmdServer.Params[0].Value := UDM.cl_subseries.FieldByName('pc').Value;
  try
    cmdServer.Active := True;
    if cmdServer.RecordCount > 0 then
      jvcpServerDetail.Visible := true
    else
      UDM.sms('No ha escogido un servidor válido para visualizar sus detalles.', 2);
  except
    on E: EFDException do
    begin
      UDM.sms('No se pueden consultar los detalles del servidor.', 1);
    end;
  end;

end;

procedure TfrmCLSeries.btnViewDetailFileClick(Sender: TObject);
begin
  cmdArch.Active := False;
  cmdArch.Params[0].Value := UDM.cl_subseries.FieldByName('archivo').Value;
  try
    cmdArch.Active := True;
    if cmdArch.RecordCount > 0 then
      jvcpArchivo.Visible := True
    else
      UDM.sms('No ha escogido un archivo válido para visualizar sus detalles.', 2);
  except
    on E: EFDException do
    begin
      UDM.sms('No se pueden consultar los detalles del archivo.', 1);
    end;
  end;
end;

procedure TfrmCLSeries.cxDBBlobEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
// llamar lo mismo que en el formulario principal...
  if trim(UDM.cl_subseries.FieldByName('carpeta').AsString) <> '' then
    edt1.Text := UDM.cl_subseries.FieldByName('carpeta').AsString
  else
    edt1.Text := '';
  cpInfoPathSubSeries.Visible := True;
end;

procedure TfrmCLSeries.cxDBVerticalGrid6observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  CampoTexto(@UDM.dscl_subseries, 'observacion', 'Observaciones realizadas a la subserie ' + UDM.cl_subseries.FieldByName('subserie').AsString);
end;

procedure TfrmCLSeries.cxGridDBTableView1carpetaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
// llamar lo mismo que en el formulario principal...
  if trim(UDM.cl_subseries.FieldByName('carpeta').AsString) <> '' then
    edt1.Text := UDM.cl_subseries.FieldByName('carpeta').AsString;
  cpInfoPathSubSeries.Visible := True;

end;

procedure TfrmCLSeries.cxGridDBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  CampoTexto(@UDM.dscl_subseries, 'observacion', 'Observaciones realizadas a la subserie ' + UDM.cl_subseries.FieldByName('subserie').AsString);
end;

procedure TfrmCLSeries.DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_subseries.FieldByName('codsubs').AsInteger := UDM.GetLastId('cl_subseries', 'codsubs');
  end;
end;

procedure TfrmCLSeries.dsSeriesDataChange(Sender: TObject; Field: TField);
begin
  if UDM.cl_series.RecordCount > 0 then
  begin
    Panel4.Caption := 'Serie: ' + AnsiQuotedStr(UDM.cl_series.FieldByName('serie').AsString, '"');
    Panel3.Caption := 'Subseries de la Serie: ' + AnsiQuotedStr(UDM.cl_series.FieldByName('serie').AsString, '"');
    GroupBox3.Caption := '--';
  end
  else
  begin
    Panel4.Caption := 'No hay series definidas.';
    Panel3.Caption := 'Debe definir al menos una serie válida.';
    GroupBox3.Caption := '--';
  end;
  if cxGrid1DBTableView1.DataController.DataSet.RecordCount>0 then
  try
    cxGrid1DBTableView1.ApplyBestFit();
  except
  end;

  if cxGridDBTableView1.DataController.DataSet.RecordCount > 0 then
  try
    cxGridDBTableView1.ApplyBestFit();
  except
  end;
end;

procedure TfrmCLSeries.edtAnioKeyPress(Sender: TObject; var Key: Char);
begin
  if length(TcxDBTextEdit(Sender).Text)>3 then begin
    UDM.sms('La longitud del año no puede ser mayor cuatro caracteres.', 1);
    TcxDBTextEdit(Sender).Focused;
    TcxDBTextEdit(Sender).SetFocus;
    Key := #0;
    exit;
  end;

  if (StrScan('0123456789', Key) <> nil) or (Key = Char(VK_BACK)) then { BackSpace Key }
  else
  begin
    UDM.sms('El año solo puede contener caracteres numéricos.', 3);
    Key := #0;
  end;
end;

procedure TfrmCLSeries.edtArchCentralKeyPress(Sender: TObject; var Key: Char);
begin
  if (StrScan('0123456789', Key) <> nil) or (Key = Char(VK_BACK)) then { BackSpace Key }
  else
  begin
    UDM.sms('El año solo puede contener caracteres numéricos.', 3);
    Key := #0;
  end;
end;

procedure TfrmCLSeries.edtArchGestionKeyPress(Sender: TObject; var Key: Char);
begin
  if (StrScan('0123456789', Key) <> nil) or (Key = Char(VK_BACK)) then { BackSpace Key }
  else
  begin
    UDM.sms('El año solo puede contener caracteres numéricos.', 3);
    Key := #0;
  end;
end;

procedure TfrmCLSeries.edtObservacionesPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  CampoTexto(@UDM.dscl_subseries, 'observacion', 'Observaciones realizadas a la subserie ' + UDM.cl_subseries.FieldByName('subserie').AsString);
end;

procedure TfrmCLSeries.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
 { UDM.RestauraGrid(cxGrid1DBTableView1);
  UDM.RestauraGrid(cxGridDBTableView1); }
end;

procedure TfrmCLSeries.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
{  UDM.SalvaConfigGrid(cxGrid1DBTableView1);
  UDM.SalvaConfigGrid(cxGridDBTableView1);}
end;

procedure TfrmCLSeries.jvcpGestorButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
begin
  if Button = capClose then
    TJvCaptionPanel(Sender).Visible := False;
end;

procedure TfrmCLSeries.JvTransparentButton1Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid2);
end;

procedure TfrmCLSeries.JvTransparentButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TfrmCLSeries.SpeedButton4Click(Sender: TObject);
begin
  jvcpArchivo.Visible := False;
end;

procedure TfrmCLSeries.SpeedButton5Click(Sender: TObject);
begin
  jvcpServerDetail.Visible := False;
end;

procedure TfrmCLSeries.SpeedButton6Click(Sender: TObject);
begin
  cpInfoPathSubSeries.Visible := False;
end;

procedure TfrmCLSeries.SpeedButton7Click(Sender: TObject);
begin
  jvcpGestor.Visible := False;
end;

procedure TfrmCLSeries.ToolButton1Click(Sender: TObject);
begin
  if cxGrid1DBTableView1.DataController.DataSet.RecordCount > 0 then
    cxGrid1DBTableView1.ApplyBestFit();
end;

end.

