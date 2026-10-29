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
  JvExtComponent, JvCaptionPanel, AdvGroupBox, AdvPanel, Vcl.Menus, AdvMenus,
  frxADOComponents, frxClass, frxGradient, frxRich, frxDBSet;

type
  TfrmCLSeries = class(TForm)
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
    tsVTSS: TcxTabSheet;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    tsFormulario: TcxTabSheet;
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
    cxGridDBTableView1acceso: TcxGridDBColumn;
    cxGridDBTableView1frecuencia: TcxGridDBColumn;
    cxGridDBTableView1tiempo: TcxGridDBColumn;
    cxGridDBTableView1observacion: TcxGridDBColumn;
    SD: TJvSelectDirectory;
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
    Label6: TLabel;
    Label1: TLabel;
    lcbAcceso: TcxDBLookupComboBox;
    lcbDestino: TcxDBLookupComboBox;
    Label10: TLabel;
    cpInfoPathSubSeries: TJvCaptionPanel;
    lbl1: TLabel;
    btnSelectDir: TSpeedButton;
    edt1: TEdit;
    cmdArch: TFDQuery;
    dscmdArch: TDataSource;
    cmdServer: TFDQuery;
    dscmdServer: TDataSource;
    AdvPanel3: TAdvPanel;
    GroupBox1: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    lcbDetalle: TcxDBLookupComboBox;
    lcbVigencia: TcxDBLookupComboBox;
    GroupBox5: TGroupBox;
    Label16: TLabel;
    cxDBLookupComboBox1: TcxDBLookupComboBox;
    cmdGestor: TFDQuery;
    dscmdGestor: TDataSource;
    cxGridDBTableView1fechaaprov: TcxGridDBColumn;
    cxDBDateEdit1: TcxDBDateEdit;
    Label5: TLabel;
    lblTipoSerie: TLabel;
    lcbTipoSerie: TcxDBLookupComboBox;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnExcelExport: TJvTransparentButton;
    btnExpand: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    advManagementDirectoryPath: TAdvPopupMenu;
    S1: TMenuItem;
    S2: TMenuItem;
    AdvPopupMenu1: TAdvPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    JvTransparentButton2: TJvTransparentButton;
    JvTransparentButton3: TJvTransparentButton;
    btnBestFitSS: TJvTransparentButton;
    btnExportSSExcel: TJvTransparentButton;
    Edit1: TEdit;
    Panel9: TPanel;
    JvTransparentButton7: TJvTransparentButton;
    Edit5: TEdit;
    frxMain: TfrxReport;
    btnPrint: TJvTransparentButton;
    frxtb_sysconfig: TfrxDBDataset;
    Label3: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    cxGridDBTableView1idtiposerie: TcxGridDBColumn;
    JvTransparentButton4: TJvTransparentButton;
    allSubSerie: TFDQuery;
    JvTransparentButton5: TJvTransparentButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnFuncionesClick(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
    procedure cxDBVerticalGrid6observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxGridDBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormActivate(Sender: TObject);
    procedure dsSeriesDataChange(Sender: TObject; Field: TField);
    procedure edtObservacionesPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxGridDBTableView1carpetaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnSelectDirClick(Sender: TObject);
    procedure cxDBBlobEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure jvcpGestorButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
    procedure SpeedButton6Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure edtAnioKeyPress(Sender: TObject; var Key: Char);
    procedure edtArchCentralKeyPress(Sender: TObject; var Key: Char);
    procedure edtArchGestionKeyPress(Sender: TObject; var Key: Char);
    procedure S1Click(Sender: TObject);
    procedure btnExpandClick(Sender: TObject);
    procedure S2Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure JvTransparentButton3Click(Sender: TObject);
    procedure btnExportSSExcelClick(Sender: TObject);
    procedure btnBestFitSSClick(Sender: TObject);
    procedure JvTransparentButton2Click(Sender: TObject);
    procedure tsVTSSEnter(Sender: TObject);
    procedure tsVTSSExit(Sender: TObject);
    procedure cxGrid2Enter(Sender: TObject);
    procedure cxGrid2Exit(Sender: TObject);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxDBVerticalGrid2DescripcionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormShow(Sender: TObject);
    procedure jvcpServerDetailEndAutoDrag(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure JvTransparentButton4Click(Sender: TObject);
  private
    { Private declarations }
    procedure ApplyChanges;  // Nuevo método para aplicar cambios
    procedure CancelChanges; // Nuevo método para cancelar cambios
  public
    { Public declarations }
    procedure CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
    procedure InsertConnection(report: TfrxReport; connection: string);
  end;

var
  frmCLSeries: TfrmCLSeries;

implementation

uses
  UCapaDatos, UVarVirtualVar, UVeditor, UExcelExport, USystemMsg, UREditor;

{$R *.dfm}

procedure TfrmCLSeries.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrCancel;  // Cancelar cambios al cerrar
  Close;
end;

procedure TfrmCLSeries.btnExpandClick(Sender: TObject);
begin
  try
    cxGrid1DBTableView1.ApplyBestFit();
    UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'cl_series');
  except
  end;
end;

procedure TfrmCLSeries.btnFuncionesClick(Sender: TObject);
var
  i: Integer;
  nombretmptable: string;
begin
  if UDM.cl_subseries.RecordCount > 0 then
  begin
    with TfrmVarVirtualVar.Create(nil) do
    try
      if TipoObj = 'S' then
        Caption := 'Variables asignadas a la Serie documental ' + AnsiQuotedStr(UDM.cl_subseries.FieldByName('subserie').AsString, '"');
      nombretmptable := UDM.QuitaCaracter('md_' + UDM.cl_series.FieldByName('codserie').AsString + UDM.cl_subseries.FieldByName('codsubs').AsString);
      if not UDM.TablaExiste(UDM.Conn, nombretmptable) then
      begin
        udm.cl_subseries.edit;
        UDM.cl_subseries.FieldByName('NombreTablaMetadatos').AsString := '';
        try
          udm.cl_subseries.Post
        except
          udm.cl_subseries.Cancel;
        end;
        DBNavigator3.VisibleButtons := [nbPrior, nbNext, nbInsert, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh];
        cxGridDBTableView1.OptionsData.Editing := True;
        cxGridDBTableView1.OptionsData.Inserting := True;
        cxGridDBTableView1.OptionsData.Deleting := True;
        Visualizando := False;
      end
      else
      begin
        UDM.sms('La tabla de las variables asociadas a esta serie documental ya fue creada. No podrá realizar modificaciones en las definiciones.', 3);
        DBNavigator3.VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast, nbRefresh];
        cxGridDBTableView1.OptionsData.Editing := False;
        cxGridDBTableView1.OptionsData.Inserting := False;
        cxGridDBTableView1.OptionsData.Deleting := False;
        Visualizando := True;
      end;
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

procedure TfrmCLSeries.btnPrintClick(Sender: TObject);   //'rSeiresSubseries.fr3'

  function TamFichero(n: string): longint;
  var
    f: file of Byte;
  begin
    result := 0;
    AssignFile(f, n);
    Reset(f);
    result := FileSize(f);
    CloseFile(f);
  end;

begin
  UDM.MostrarReporte('SERIESV');
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

procedure TfrmCLSeries.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 19;
  Application.HelpContext(TopicID);
end;

procedure TfrmCLSeries.CancelChanges;
begin
  if UDM.cl_series.State in [dsEdit, dsInsert] then
    UDM.cl_series.Cancel;
  if UDM.cl_subseries.State in [dsEdit, dsInsert] then
    UDM.cl_subseries.Cancel;
  if UDM.AllSubSerie.State in [dsEdit, dsInsert] then
    UDM.AllSubSerie.Cancel;
end;

procedure TfrmCLSeries.CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
var
  Component: TfrxComponent;
begin
  with report do
  begin
    LoadFromFile(pathreport);
    InsertConnection(report, PathBD);
    Component := FindObject(nameempresa);
    if Component <> nil then
    begin
      if Component is TfrxRichView then
        TfrxRichView(Component).DataSet := frxtb_sysconfig;
      TfrxRichView(Component).DataField := 'empresa';

    end;
    Component := FindObject(nameimagen);
    if Component <> nil then
    begin
      if Component is TfrxPictureView then
        TfrxPictureView(Component).Picture.LoadFromFile(pathimagen);
    end;
    PrepareReport(False);
    ShowReport();
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

procedure TfrmCLSeries.cxDBVerticalGrid2DescripcionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  CampoTexto(@dscmdArch, 'Descripcion', 'Descripción del  archivo asignado a la subserie ' + UDM.cl_subseries.FieldByName('subserie').AsString);
end;

procedure TfrmCLSeries.cxDBVerticalGrid6observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  CampoTexto(@UDM.dscl_subseries, 'observacion', 'Observaciones realizadas a la subserie ' + UDM.cl_subseries.FieldByName('subserie').AsString);
end;

procedure TfrmCLSeries.cxGrid2Enter(Sender: TObject);
begin
  btnBestFitSS.Visible := True;
end;

procedure TfrmCLSeries.cxGrid2Exit(Sender: TObject);
begin
  btnBestFitSS.Visible := False;
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
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) then
      UDM.cl_subseries.FieldByName('codsubs').AsInteger := UDM.GetLastId('cl_subseries', 'codsubs');
  end; {
  else if Button = nbPost then
    ApplyChanges
  else if Button = nbCancel then
    CancelChanges;   }
end;

procedure TfrmCLSeries.dsSeriesDataChange(Sender: TObject; Field: TField);
begin
  UDM.dscl_subseries.DataSet := UDM.cl_subseries;
  cxGridDBTableView1.FilterRow.Visible := False;  // Muestra una fila especial para filtrar
  cxGridDBTableView1.OptionsBehavior.IncSearch := False;  // Búsqueda incremental mientras el usuario escribe
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
end;

procedure TfrmCLSeries.edtAnioKeyPress(Sender: TObject; var Key: Char);
begin
  if length(TcxDBTextEdit(Sender).Text) > 3 then
  begin
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
//  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmCLSeries.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.SaveGridLayout(cxGrid1DBTableView1, PathTemp + 'cl_series.ini');
  UDM.SaveGridLayout(cxGridDBTableView1, PathTemp + 'cl_subseries.ini');

  // Verificar si hay cambios pendientes
  if (UDM.cl_series.State in [dsEdit, dsInsert]) or (UDM.cl_subseries.State in [dsEdit, dsInsert]) or (UDM.AllSubSerie.State in [dsEdit, dsInsert]) then
  begin
    case MessageDlg('¿Desea guardar los cambios antes de cerrar?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:
        begin
          ApplyChanges;
          ModalResult := mrOk;
        end;
      mrNo:
        begin
          CancelChanges;
          ModalResult := mrCancel;
        end;
      mrCancel:
        CanClose := False;  // No cerrar el formulario
    end;
  end
  else
    ModalResult := mrCancel;  // No hay cambios, cerrar sin guardar
end;

procedure TfrmCLSeries.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
  if Key = 112 then
  begin
    TopicID := 19;
    Application.HelpContext(TopicID);
  end;
end;

procedure TfrmCLSeries.FormShow(Sender: TObject);
begin
  Edit1.Focused;
  Edit1.SetFocus;
  UDM.LoadGridLayout(cxGrid1DBTableView1, PathTemp + 'cl_series.ini');
  UDM.LoadGridLayout(cxGridDBTableView1, PathTemp + 'cl_subseries.ini');
end;

procedure TfrmCLSeries.InsertConnection(report: TfrxReport; connection: string);
var
  i: integer;
begin
  TfrxADODatabase(report.FindComponent('conn')).Connected := false;
  if TBD = 'A' then
    TfrxADODatabase(report.FindComponent('conn')).DatabaseName := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + connection + ';Persist Security Info=False'
  else
    TfrxADODatabase(report.FindComponent('conn')).DatabaseName := 'Provider=SQLOLEDB.1;Password=geoconn;Persist Security Info=True;User ID=geoconn;Initial Catalog=SDbd;Data Source=' + UDM.tb_sysconfig.FieldByName('ipservidorbd').AsString;
  TfrxADODatabase(report.FindComponent('conn')).Connected := True;
  for i := 0 to report.ComponentCount - 1 do
  begin
    if report.Components[i] is TfrxADOQuery then
    begin
      if TfrxADOQuery(report.Components[i]).Params.Count = 0 then
      begin
        TfrxADOQuery(report.Components[i]).Active := True;
      end;

    end;
    if report.Components[i] is TfrxADOTable then
    begin
      TfrxADOTable(report.Components[i]).Active := True;
    end;
  end
end;

procedure TfrmCLSeries.jvcpGestorButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
begin
  if Button = capClose then
    TJvCaptionPanel(Sender).Visible := False;
end;

procedure TfrmCLSeries.jvcpServerDetailEndAutoDrag(Sender: TObject);
begin
  UDM.Boundarys(Sender);
end;

procedure TfrmCLSeries.JvTransparentButton2Click(Sender: TObject);
begin
  if cxGrid1DBTableView1.DataController.DataSet.RecordCount > 0 then
    cxGrid1DBTableView1.ApplyBestFit()
  else
    UDM.sms('Esta funcionalidad solo funciona cuando en la el conjunto de datos existe al menos un elemento.', 3);
end;

procedure TfrmCLSeries.JvTransparentButton3Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TfrmCLSeries.JvTransparentButton4Click(Sender: TObject);
begin
  if UDM.dscl_subseries.DataSet = UDM.cl_subseries then
  begin
  // Limpiar cualquier consulta anterior
    pSeries.Visible := False;
    cxPageControl1.ActivePage := tsVTSS;
    allSubSerie.Close;
  // Preparar la consulta para obtener todas las subseries
    allSubSerie.SQL.Text := 'SELECT * FROM cl_subseries ORDER BY codserie, codsubs'; // Ordenar por codserie y codsubs
    allSubSerie.Open; // Ejecutar la consulta
    UDM.dscl_subseries.DataSet := allSubSerie;
    cxGridDBTableView1.FilterRow.Visible := True;  // Muestra una fila especial para filtrar
    cxGridDBTableView1.OptionsBehavior.IncSearch := True;  // Búsqueda incremental mientras el usuario escribe

  // Verificar si hay registros y mostrar un mensaje
    if allSubSerie.RecordCount = 0 then
      udm.sms('No hay subseries registradas.', 3)
    else
      udm.sms(Format('Se están visualizando %d subseries.', [allSubSerie.RecordCount]), 3);
  end
  else
  begin
    UDM.dscl_subseries.DataSet := UDM.cl_subseries;
    cxGridDBTableView1.FilterRow.Visible := False;  // Muestra una fila especial para filtrar
    cxGridDBTableView1.OptionsBehavior.IncSearch := False;  // Búsqueda incremental mientras el usuario escribe
    pSeries.Visible := True;
    cxPageControl1.ActivePage := tsFormulario;
  end;
end;

procedure TfrmCLSeries.ApplyChanges;
begin
  if UDM.cl_series.State in [dsEdit, dsInsert] then
    UDM.cl_series.Post;
  if UDM.cl_subseries.State in [dsEdit, dsInsert] then
    UDM.cl_subseries.Post;
  if UDM.AllSubSerie.State in [dsEdit, dsInsert] then
    UDM.AllSubSerie.Post;
end;

procedure TfrmCLSeries.btnBestFitSSClick(Sender: TObject);
begin
  try
    cxGridDBTableView1.ApplyBestFit();
  except
  end;
end;

procedure TfrmCLSeries.btnExportSSExcelClick(Sender: TObject);
begin
  ExcelExport(nil, cxGrid2);
end;

procedure TfrmCLSeries.MenuItem1Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TfrmCLSeries.MenuItem2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid2);
end;

procedure TfrmCLSeries.S1Click(Sender: TObject);
begin
  try
    cxGrid1DBTableView1.ApplyBestFit();
  except
  end;
end;

procedure TfrmCLSeries.S2Click(Sender: TObject);
begin
  try
    cxGridDBTableView1.ApplyBestFit();
  except
  end;
end;

procedure TfrmCLSeries.SpeedButton6Click(Sender: TObject);
begin
  cpInfoPathSubSeries.Visible := False;
end;

procedure TfrmCLSeries.ToolButton1Click(Sender: TObject);
begin
  if cxGrid1DBTableView1.DataController.DataSet.RecordCount > 0 then
    cxGrid1DBTableView1.ApplyBestFit();
end;

procedure TfrmCLSeries.tsVTSSEnter(Sender: TObject);
begin
  DBNavigator1.Align := alNone;
  cxDBNavigator1.Align := alNone;
  btnExportSSExcel.Align := alNone;
  btnBestFitSS.Align := alNone;
  btnBestFitSS.Visible := True;
  btnBestFitSS.Align := alRight;
  btnExportSSExcel.Align := alRight;
end;

procedure TfrmCLSeries.tsVTSSExit(Sender: TObject);
begin
  btnBestFitSS.Visible := False;
end;

end.

