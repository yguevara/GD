unit UDepuracion;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, AdvOfficeStatusBar, Vcl.StdCtrls, JvExControls, JvButton,
  JvTransparentButton, Vcl.ExtCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, dxBarBuiltInMenu, cxPC,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, cxDBLookupComboBox, cxDropDownEdit,
  cxButtonEdit, frxClass, frxDBSet, frxADOComponents, frxRich, cxBlobEdit,
  cxVGrid, cxDBVGrid, cxInplaceContainer, ToolPanels, cxGridExportLink,
  cxCheckBox, cxRichEdit, cxContainer, cxMemo, cxLabel, cxTextEdit, cxMaskEdit,
  cxLookupEdit, cxDBLookupEdit, JvExExtCtrls, JvExtComponent, JvCaptionPanel,
  Vcl.DBCtrls, cxCalendar, frxExportBaseDialog, frxExportPDF;

type
  TfrmDepuracion = class(TForm)
    pMainContainer: TPanel;
    btnClose: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    StatusBar: TAdvOfficeStatusBar;
    btnExportExcelCC: TJvTransparentButton;
    QDocDepurarAll: TFDQuery;
    pcMain: TcxPageControl;
    dsQDocDepurarAll: TDataSource;
    tsDocDepurar: TcxTabSheet;
    cl_destino: TFDQuery;
    dscl_destino: TDataSource;
    tb_depuracion: TFDQuery;
    dstb_depuracion: TDataSource;
    rSeriesDepurar: TfrxReport;
    tb_sysconfig: TFDQuery;
    dstb_sysconfig: TDataSource;
    frxtb_sysconfig: TfrxDBDataset;
    frxADOComponents1: TfrxADOComponents;
    frxRichObject1: TfrxRichObject;
    cl_valorDOc: TFDQuery;
    dscl_valorDOc: TDataSource;
    tsDocDepurados: TcxTabSheet;
    QDocumentosDepurados: TFDQuery;
    dsQDocumentosDepurados: TDataSource;
    cxDocDepurar: TcxGrid;
    cxDocDepurarTb: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridDBColumn2: TcxGridDBColumn;
    cxGridDBColumn3: TcxGridDBColumn;
    cxGridDBColumn4: TcxGridDBColumn;
    cxGridDBColumn5: TcxGridDBColumn;
    cxGridDBColumn6: TcxGridDBColumn;
    cxGridDBColumn7: TcxGridDBColumn;
    cxGridDBColumn8: TcxGridDBColumn;
    cxGridDBColumn9: TcxGridDBColumn;
    cxGridDBColumn10: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    cxDocDocDepurado: TcxGrid;
    cxDocDocDepuradoTv: TcxGridDBTableView;
    cxDocDocDepuradoTvIdEstructura: TcxGridDBColumn;
    cxDocDocDepuradoTvcodsubs: TcxGridDBColumn;
    cxDocDocDepuradoTvVersion: TcxGridDBColumn;
    cxDocDocDepuradoTvCodigodoc: TcxGridDBColumn;
    cxDocDocDepuradoTvtitulodoc: TcxGridDBColumn;
    cxDocDocDepuradoTvArchivo: TcxGridDBColumn;
    cxDocDocDepuradoTvdeposito: TcxGridDBColumn;
    cxDocDocDepuradoTvgaveta: TcxGridDBColumn;
    cxDocDocDepuradoTvdestino: TcxGridDBColumn;
    cxDocDocDepuradoTvColumn2: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    cxDocDepurarTbColumn1: TcxGridDBColumn;
    QDatosSubserie: TFDQuery;
    dsUDatosSubserie: TDataSource;
    cxDocDocDepuradoTvColumn1: TcxGridDBColumn;
    sdExcel: TSaveDialog;
    frxtb_depuracion: TfrxDBDataset;
    btnAdjustColumnCC: TJvTransparentButton;
    MetaInfo: TFDMetaInfoQuery;
    cpDepurarDocumentos: TJvCaptionPanel;
    Panel2: TPanel;
    Button1: TButton;
    cxDocDocDepuradoTvfechadepuracion: TcxGridDBColumn;
    tb_SeriesDatos: TFDQuery;
    dstb_SeriesDatos: TDataSource;
    cl_detalle: TFDQuery;
    dscl_detalle: TDataSource;
    tb_Tree: TFDQuery;
    dstb_Serietree: TDataSource;
    cl_subseries: TFDQuery;
    dscl_subseries: TDataSource;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    cxStyle9: TcxStyle;
    cxStyle10: TcxStyle;
    cxStyle11: TcxStyle;
    cxStyle12: TcxStyle;
    cxStyle13: TcxStyle;
    cxStyle14: TcxStyle;
    cxStyle15: TcxStyle;
    GridTableViewStyleSheetDevExpress: TcxGridTableViewStyleSheet;
    Panel1: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    JvTransparentButton5: TJvTransparentButton;
    AdvToolPanelTab1: TAdvToolPanelTab;
    AdvToolPanel1: TAdvToolPanel;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid2CategoryRow6: TcxCategoryRow;
    cxDBVerticalGrid2subserie: TcxDBEditorRow;
    cxDBVerticalGrid2codsubs: TcxDBEditorRow;
    cxDBVerticalGrid2serie: TcxDBEditorRow;
    cxDBVerticalGrid2Tipodoc: TcxDBEditorRow;
    cxDBVerticalGrid2Nombresoporte: TcxDBEditorRow;
    cxDBVerticalGrid2NombreAcceso: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid2Valordoc: TcxDBEditorRow;
    cxDBVerticalGrid2vigencia: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow2: TcxCategoryRow;
    cxDBVerticalGrid2ayear: TcxDBEditorRow;
    cxDBVerticalGrid2tgestion: TcxDBEditorRow;
    cxDBVerticalGrid2tcentral: TcxDBEditorRow;
    cxDBVerticalGrid2NombreDestino: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow3: TcxCategoryRow;
    cxDBVerticalGrid2nombreArchivo: TcxDBEditorRow;
    cxDBVerticalGrid2Tipo: TcxDBEditorRow;
    cxDBVerticalGrid2deposito: TcxDBEditorRow;
    cxDBVerticalGrid2gaveta: TcxDBEditorRow;
    cxDBVerticalGrid2etiquetaServ: TcxDBEditorRow;
    cxDBVerticalGrid2ipserver: TcxDBEditorRow;
    cxDBVerticalGrid2croquis: TcxDBEditorRow;
    cxDBVerticalGrid2Foto: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow4: TcxCategoryRow;
    cxDBVerticalGrid2GESTOR: TcxDBEditorRow;
    cxDBVerticalGrid2CorreoElect: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow5: TcxCategoryRow;
    cxDBVerticalGrid2NombreFrecuencia: TcxDBEditorRow;
    cxDBVerticalGrid2tiempo: TcxDBEditorRow;
    GroupBox1: TGroupBox;
    DBLookupComboBox1: TDBLookupComboBox;
    GroupBox2: TGroupBox;
    DBMemo1: TDBMemo;
    frxQDocumentosDepurados: TfrxDBDataset;
    cxStyleRepository2: TcxStyleRepository;
    cxStyle378: TcxStyle;
    cxStyle379: TcxStyle;
    cxStyle380: TcxStyle;
    cxStyle381: TcxStyle;
    cxStyle382: TcxStyle;
    cxStyle383: TcxStyle;
    cxStyle384: TcxStyle;
    cxStyle385: TcxStyle;
    cxStyle386: TcxStyle;
    cxStyle387: TcxStyle;
    cxStyle388: TcxStyle;
    cxStyle389: TcxStyle;
    cxStyle390: TcxStyle;
    cxStyle391: TcxStyle;
    cxStyle392: TcxStyle;
    cxStyle393: TcxStyle;
    cxStyle394: TcxStyle;
    cxStyle395: TcxStyle;
    cxStyle396: TcxStyle;
    cxStyle397: TcxStyle;
    cxStyle398: TcxStyle;
    cxStyle399: TcxStyle;
    cxStyle400: TcxStyle;
    cxStyle401: TcxStyle;
    cxStyle402: TcxStyle;
    cxStyle403: TcxStyle;
    cxStyle404: TcxStyle;
    cxStyle405: TcxStyle;
    cxStyle406: TcxStyle;
    cxStyle407: TcxStyle;
    cxStyle408: TcxStyle;
    cxStyle409: TcxStyle;
    cxStyle410: TcxStyle;
    cxStyle411: TcxStyle;
    cxStyle412: TcxStyle;
    cxStyle413: TcxStyle;
    cxStyle414: TcxStyle;
    cxStyle415: TcxStyle;
    cxStyle416: TcxStyle;
    cxStyle417: TcxStyle;
    cxStyle418: TcxStyle;
    cxStyle419: TcxStyle;
    cxStyle420: TcxStyle;
    cxStyle421: TcxStyle;
    cxStyle422: TcxStyle;
    cxStyle423: TcxStyle;
    cxStyle424: TcxStyle;
    cxStyle425: TcxStyle;
    cxStyle426: TcxStyle;
    cxStyle427: TcxStyle;
    cxStyle428: TcxStyle;
    cxStyle429: TcxStyle;
    cxStyle430: TcxStyle;
    cxStyle431: TcxStyle;
    cxStyle432: TcxStyle;
    cxStyle433: TcxStyle;
    cxStyle434: TcxStyle;
    cxStyle435: TcxStyle;
    cxStyle436: TcxStyle;
    cxStyle437: TcxStyle;
    cxStyle438: TcxStyle;
    cxStyle439: TcxStyle;
    cxStyle440: TcxStyle;
    cxStyle441: TcxStyle;
    cxStyle442: TcxStyle;
    cxStyle443: TcxStyle;
    cxStyle444: TcxStyle;
    cxStyle445: TcxStyle;
    cxStyle446: TcxStyle;
    cxStyle447: TcxStyle;
    cxStyle448: TcxStyle;
    cxStyle449: TcxStyle;
    cxStyle450: TcxStyle;
    cxStyle451: TcxStyle;
    cxStyle452: TcxStyle;
    cxStyle453: TcxStyle;
    cxStyle454: TcxStyle;
    cxStyle455: TcxStyle;
    cxStyle456: TcxStyle;
    cxStyle457: TcxStyle;
    cxStyle458: TcxStyle;
    cxStyle459: TcxStyle;
    cxStyle460: TcxStyle;
    cxStyle461: TcxStyle;
    cxStyle462: TcxStyle;
    cxStyle463: TcxStyle;
    cxStyle464: TcxStyle;
    cxStyle465: TcxStyle;
    cxStyle466: TcxStyle;
    cxStyle467: TcxStyle;
    cxStyle468: TcxStyle;
    cxStyle469: TcxStyle;
    cxStyle470: TcxStyle;
    cxStyle471: TcxStyle;
    cxStyle472: TcxStyle;
    cxStyle473: TcxStyle;
    cxStyle474: TcxStyle;
    cxStyle475: TcxStyle;
    cxStyle476: TcxStyle;
    cxStyle477: TcxStyle;
    cxStyle478: TcxStyle;
    cxStyle479: TcxStyle;
    cxStyle480: TcxStyle;
    cxStyle481: TcxStyle;
    cxStyle482: TcxStyle;
    cxStyle483: TcxStyle;
    cxStyle484: TcxStyle;
    cxStyle485: TcxStyle;
    cxStyle486: TcxStyle;
    cxStyle487: TcxStyle;
    cxStyle488: TcxStyle;
    cxStyle489: TcxStyle;
    cxStyle490: TcxStyle;
    cxStyle491: TcxStyle;
    cxStyle492: TcxStyle;
    cxStyle493: TcxStyle;
    cxStyle494: TcxStyle;
    cxStyle495: TcxStyle;
    cxStyle496: TcxStyle;
    cxStyle497: TcxStyle;
    cxStyle498: TcxStyle;
    cxStyle499: TcxStyle;
    cxStyle500: TcxStyle;
    cxStyle501: TcxStyle;
    cxStyle502: TcxStyle;
    cxStyle503: TcxStyle;
    cxStyle504: TcxStyle;
    cxStyle505: TcxStyle;
    cxStyle506: TcxStyle;
    cxStyle507: TcxStyle;
    cxStyle508: TcxStyle;
    cxStyle509: TcxStyle;
    cxStyle510: TcxStyle;
    cxStyle511: TcxStyle;
    cxStyle512: TcxStyle;
    cxStyle513: TcxStyle;
    cxStyle514: TcxStyle;
    cxStyle515: TcxStyle;
    cxStyle516: TcxStyle;
    cxStyle517: TcxStyle;
    cxStyle518: TcxStyle;
    cxStyle519: TcxStyle;
    cxStyle520: TcxStyle;
    cxStyle521: TcxStyle;
    cxStyle522: TcxStyle;
    cxStyle523: TcxStyle;
    cxStyle524: TcxStyle;
    cxStyle525: TcxStyle;
    cxStyle526: TcxStyle;
    cxStyle527: TcxStyle;
    cxStyle528: TcxStyle;
    cxStyle529: TcxStyle;
    cxStyle530: TcxStyle;
    cxStyle531: TcxStyle;
    cxStyle532: TcxStyle;
    cxStyle533: TcxStyle;
    cxStyle534: TcxStyle;
    cxStyle535: TcxStyle;
    cxStyle536: TcxStyle;
    cxStyle537: TcxStyle;
    cxStyle538: TcxStyle;
    cxStyle539: TcxStyle;
    cxStyle540: TcxStyle;
    cxStyle541: TcxStyle;
    cxStyle542: TcxStyle;
    cxStyle543: TcxStyle;
    cxStyle544: TcxStyle;
    cxStyle545: TcxStyle;
    cxStyle546: TcxStyle;
    cxStyle547: TcxStyle;
    cxStyle548: TcxStyle;
    cxStyle549: TcxStyle;
    cxStyle550: TcxStyle;
    cxStyle551: TcxStyle;
    cxStyle552: TcxStyle;
    cxStyle553: TcxStyle;
    cxStyle554: TcxStyle;
    cxStyle555: TcxStyle;
    cxStyle556: TcxStyle;
    cxStyle557: TcxStyle;
    cxStyle558: TcxStyle;
    cxStyle559: TcxStyle;
    cxStyle560: TcxStyle;
    cxStyle561: TcxStyle;
    cxStyle562: TcxStyle;
    cxStyle563: TcxStyle;
    cxStyle564: TcxStyle;
    cxStyle565: TcxStyle;
    cxStyle566: TcxStyle;
    cxStyle567: TcxStyle;
    cxStyle568: TcxStyle;
    cxStyle569: TcxStyle;
    cxStyle570: TcxStyle;
    cxStyle571: TcxStyle;
    cxStyle572: TcxStyle;
    cxStyle573: TcxStyle;
    cxStyle574: TcxStyle;
    cxStyle575: TcxStyle;
    cxStyle576: TcxStyle;
    cxStyle577: TcxStyle;
    cxStyle578: TcxStyle;
    cxStyle579: TcxStyle;
    cxStyle580: TcxStyle;
    cxStyle581: TcxStyle;
    cxStyle582: TcxStyle;
    cxStyle583: TcxStyle;
    cxStyle584: TcxStyle;
    cxStyle585: TcxStyle;
    cxStyle586: TcxStyle;
    cxStyle587: TcxStyle;
    cxStyle588: TcxStyle;
    cxStyle589: TcxStyle;
    cxVerticalGridStyleSheetEggplant: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetDevExpress: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetUserFormat1: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetUserFormat2: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetUserFormat3: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetUserFormat4: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetBrick: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleDesert: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheet1: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetLilac: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetMaple: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetMarineHighColor: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetPlumHighColor: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetPumpkinLarge: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetRainyDay: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetRedWhiteAndBlueVGA: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetRose: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetRoseLarge: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetSlate: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetSpruce: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetStormVGA: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetTealVGA: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetWheat: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetWindowsClassic: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetWindowsClassicLarge: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetWindowsStandard: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetWindowsStandardLarge: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetHighContrast1: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetHighContrast1Large: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetHighContrast2: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetHighContrast2Large: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetHighContrastBlack: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetHighContrastBlackLarge: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetHighContrastWhite: TcxVerticalGridStyleSheet;
    cxVerticalGridStyleSheetHighContrastWhiteLarge: TcxVerticalGridStyleSheet;
    frxPDFExport1: TfrxPDFExport;
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure cxGridDBTableView1Column1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnPrintClick(Sender: TObject);
    procedure tsDocDepuradosShow(Sender: TObject);
    procedure btnExportExcelCCClick(Sender: TObject);
    procedure btnAdjustColumnCCClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cxDocDepurarTbCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure tb_depuracionPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure JvTransparentButton5Click(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure cxDocDocDepuradoTvCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure cxDocDepurarTbKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxDocDepurarTbKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxDocDocDepuradoTvKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxDocDocDepuradoTvKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnPrintMouseEnter(Sender: TObject);
    procedure btnExportExcelCCMouseEnter(Sender: TObject);
    procedure tb_depuracionAfterRefresh(DataSet: TDataSet);
    procedure QDocumentosDepuradosAfterRefresh(DataSet: TDataSet);
    procedure tsDocDepurarShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ReloadDocumentDepurar;
    procedure CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
    function LocalizaConsulta(consulta_nombre: string): Boolean;
  end;

var
  frmDepuracion: TfrmDepuracion;

implementation

uses
  UCapaDatos;

{$R *.dfm}

function TfrmDepuracion.LocalizaConsulta(consulta_nombre: string): Boolean;
begin
  MetaInfo.Active := false;
  MetaInfo.Active := True;

  if MetaInfo.Locate('TABLE_NAME', consulta_nombre, []) then
  begin
    Result := True;
  end
  else
    result := False;

end;

procedure TfrmDepuracion.QDocumentosDepuradosAfterRefresh(DataSet: TDataSet);
begin
  StatusBar.Panels[1].Text := '';
  StatusBar.Panels[1].Text := IntToStr(tb_depuracion.RecordCount);
  StatusBar.Panels[3].Text := '';
  StatusBar.Panels[3].Text := IntToStr(QDocumentosDepurados.RecordCount);
end;

procedure TfrmDepuracion.btnAdjustColumnCCClick(Sender: TObject);
begin
  cxDocDepurarTb.ApplyBestFit;
  cxDocDocDepuradoTv.ApplyBestFit;
end;

procedure TfrmDepuracion.btnCloseClick(Sender: TObject);
begin
  close;

end;

procedure TfrmDepuracion.JvTransparentButton1Click(Sender: TObject);
begin

  cpDepurarDocumentos.Visible := false;

end;

procedure TfrmDepuracion.JvTransparentButton5Click(Sender: TObject);
begin
  ShowMessage('AYUDA EN CONSTRUCCION');
end;

procedure TfrmDepuracion.CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
var
  Component: TfrxComponent;
begin
  with report do
  begin
    LoadFromFile(pathreport);
   // InsertConnection(report, pathdb);
    Component := FindObject(nameempresa);
    {********************************************************}
    {esto que te encierro aqui es lo que tiens que cambiar en esta funcion donde la tengas en tu proyecto}
    {fijate aqui que hay un query con un frxtb_sysconfig, este es el qu emuestra el valor}
    if Component is TfrxRichView then
      TfrxRichView(Component).DataSet := frxtb_sysconfig;
    TfrxRichView(Component).DataField := 'empresa';

    Component := FindObject(nameimagen);
    if Component is TfrxPictureView then
      TfrxPictureView(Component).Picture.LoadFromFile(pathimagen);

    PrepareReport();
    ShowReport();
  end;
end;

procedure TfrmDepuracion.btnExportExcelCCClick(Sender: TObject);
begin

  with sdExcel do
  begin
    if pcMain.ActivePage = tsDocDepurar then
    begin
      if Execute then
      begin

        ExportGridToExcel(sdExcel.FileName, cxDocDepurar, False);
        MessageDlg('Información salvada correctamente en ' + sdExcel.FileName, mtInformation, [mbok], 0);
      end;

    end
    else if pcMain.ActivePage = tsDocDepurados then
    begin
      if Execute then
      begin
        ExportGridToExcel(sdExcel.FileName, cxDocDocDepurado, False);
        MessageDlg('Información salvada correctamente en ' + sdExcel.FileName, mtInformation, [mbok], 0);
      end;

    end

  end;
end;

procedure TfrmDepuracion.btnExportExcelCCMouseEnter(Sender: TObject);
begin
  btnExportExcelCC.Hint := 'Exportar a Exel los  ' + pcMain.ActivePage.Caption;
end;

procedure TfrmDepuracion.btnPrintClick(Sender: TObject);
var
  marca: TBookmark;
begin


  if pcMain.ActivePage = tsDocDepurar then
  begin

    marca := tb_depuracion.GetBookmark;
    tb_depuracion.DisableControls;

    if tb_sysconfig.Active = false then
      tb_sysconfig.Active := True;

      //esta validacion la puse aqui pero puede ser en otro lugar si deseas
    if ((tb_sysconfig.FieldByName('empresa').AsString <> '') and (not TBlobField(tb_sysconfig.FieldByName('logo')).IsNull)) then
    begin
     //salvar el logo que esta en la tabla de configuracion a la carpeta de reportes ,que ahora esta a nivel del mosulo
     //principal
      TBlobField(tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
    //todos los parametros para cargar el reporte

      if tb_depuracion.RecordCount <> 0 then
      begin
        CargaReporte(rSeriesDepurar, pathreport + 'rSeriesDepurar.fr3', 'empresa', tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png');
      end
      else
      begin
        MessageDlg('No hay documentos que cumplan con la condición de Depurar.', mtWarning, [mbok], 0);
      end;

    end
    else
    begin
      MessageDlg('Debe configurar los Datos de la Empresa. Dirijase a la configuración del Sistema.', mtError, [mbOK], 0);
    end;
    tb_depuracion.EnableControls;
    tb_depuracion.GotoBookmark(marca);
  end;

  if pcMain.ActivePage = tsDocDepurados then
  begin
    marca := QDocumentosDepurados.GetBookmark;
    QDocumentosDepurados.DisableControls;

    if tb_sysconfig.Active = false then
      tb_sysconfig.Active := True;

      //esta validacion la puse aqui pero puede ser en otro lugar si deseas
    if ((tb_sysconfig.FieldByName('empresa').AsString <> '') and (not TBlobField(tb_sysconfig.FieldByName('logo')).IsNull)) then
    begin
     //salvar el logo que esta en la tabla de configuracion a la carpeta de reportes ,que ahora esta a nivel del mosulo
     //principal
      TBlobField(tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
    //todos los parametros para cargar el reporte

      if QDocumentosDepurados.RecordCount <> 0 then
      begin
        CargaReporte(rSeriesDepurar, pathreport + 'rDocDepurados.fr3', 'empresa', tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png');
      end
      else
      begin
        MessageDlg('No hay documentos depurados para mostrar.', mtWarning, [mbok], 0);
      end;

    end
    else
    begin
      MessageDlg('Debe configurar los Datos de la Empresa. Dirijase a la configuración del Sistema.', mtError, [mbOK], 0);
    end;
    QDocumentosDepurados.EnableControls;
    QDocumentosDepurados.GotoBookmark(marca);
  end;

end;

procedure TfrmDepuracion.btnPrintMouseEnter(Sender: TObject);
begin
  btnPrint.Hint := 'Imprimir el Reporte de ' + pcMain.ActivePage.Caption;
end;

procedure TfrmDepuracion.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 26;
  Application.HelpContext(TopicID);                                                   //26

end;

procedure TfrmDepuracion.Button1Click(Sender: TObject);
begin
///marcarlo como depurado
  if tb_depuracion.FieldByName('fundamentacion').AsString <> '' then
  begin
       // caso eliminar
    if tb_depuracion.FieldByName('destino').AsInteger = 3 then
    begin
       //elimino el registro desde aqui
      tb_SeriesDatos.Active := False;
      tb_SeriesDatos.Active := true;
      if tb_SeriesDatos.Locate('IdEstructura;id;codsubs;Fecha;Version', VarArrayOf([tb_depuracion.FieldByName('IdEstructura').AsString, tb_depuracion.FieldByName('id').AsString, tb_depuracion.FieldByName('codsubs').AsString, tb_depuracion.FieldByName('Fecha').AsString, tb_depuracion.FieldByName('Version').AsString]), []) then
      begin
        if (MessageDlg('¿ Está seguro que desea eliminar el  documento:' + sLineBreak + ' [' + tb_depuracion.FieldByName('titulodoc').AsString + ' ] ?', mtInformation, [mbYes, mbNo], 0)) = mrYes then
        begin
          tb_SeriesDatos.Delete;
          tb_depuracion.edit;
          tb_depuracion.FieldByName('fundamentacion').AsString := tb_depuracion.FieldByName('fundamentacion').AsString;
          tb_depuracion.FieldByName('fechadepuracion').AsDateTime := Now();
          tb_depuracion.FieldByName('depurado').AsBoolean := StrToBool('True');
          tb_depuracion.post;
          cpDepurarDocumentos.Visible := false;
        end;

      end;

    end;
       //caso Conservación total
    if tb_depuracion.FieldByName('destino').AsInteger = 1 then
    begin
     // le actualizo la fecha y le pongo la fecha en que se depuro el documento
     //verificar tipo de acrchivo
     //verifico tipo de archivo central y le sumo los años
     //actualizo la fecha del documento original , garantizo que no me salga a depurar nuevavente
     //localozar ese documento primero
      tb_SeriesDatos.Active := False;
      tb_SeriesDatos.Active := true;
      if tb_SeriesDatos.Locate('IdEstructura;id;codsubs;Fecha;Version', VarArrayOf([tb_depuracion.FieldByName('IdEstructura').AsString, tb_depuracion.FieldByName('id').AsString, tb_depuracion.FieldByName('codsubs').AsString, tb_depuracion.FieldByName('Fecha').AsString, tb_depuracion.FieldByName('Version').AsString]), []) then
      begin
        tb_seriesdatos.edit;
        tb_SeriesDatos.FieldByName('fecha').AsDateTime := Now();
        tb_SeriesDatos.FieldByName('observaciones').AsString := tb_SeriesDatos.FieldByName('observaciones').AsString + sLineBreak + tb_depuracion.FieldByName('fundamentacion').AsString + ' <<Documento Depurado>> <<Fecha dupuracion>> ' + FormatDateTime('dd/mm/yyyy', Now()) + '<< Destino: ' + tb_depuracion.FieldByName('lkdestino').AsString + '>>';
       // tb_SeriesDatos.FieldByName('destino').AsInteger := tb_depuracion.FieldByName('destino').AsInteger ;
        tb_seriesdatos.post;
        tb_depuracion.Edit;
        tb_depuracion.FieldByName('fechadepuracion').AsDateTime := Now();
        tb_depuracion.FieldByName('depurado').AsBoolean := StrToBool('True');
        tb_depuracion.post;
        cpDepurarDocumentos.Visible := false;
      end;

    end;

    if tb_depuracion.FieldByName('destino').AsInteger = 2 then
    begin
      tb_SeriesDatos.Active := False;
      tb_SeriesDatos.Active := true;
      if tb_SeriesDatos.Locate('IdEstructura;id;codsubs;Fecha;Version', VarArrayOf([tb_depuracion.FieldByName('IdEstructura').AsString, tb_depuracion.FieldByName('id').AsString, tb_depuracion.FieldByName('codsubs').AsString, tb_depuracion.FieldByName('Fecha').AsString, tb_depuracion.FieldByName('Version').AsString]), []) then
      begin
        tb_seriesdatos.edit;
        tb_SeriesDatos.FieldByName('fecha').AsDateTime := Now();
        tb_SeriesDatos.FieldByName('observaciones').AsString := tb_SeriesDatos.FieldByName('observaciones').AsString + tb_depuracion.FieldByName('fundamentacion').AsString + sLineBreak + ' <<Documento Depurado>> <<Fecha dupuracion>> ' + FormatDateTime('dd/mm/yyyy', Now()) + '<< Destino: ' + tb_depuracion.FieldByName('lkdestino').AsString + '>>';
        tb_seriesdatos.post;
        tb_depuracion.Edit;
        tb_depuracion.FieldByName('fechadepuracion').AsDateTime := Now();
        tb_depuracion.FieldByName('depurado').AsBoolean := StrToBool('True');
        tb_depuracion.post;
        cpDepurarDocumentos.Visible := false;
      end;
    end;
    if tb_depuracion.FieldByName('destino').AsInteger = 4 then
    begin
      tb_SeriesDatos.Active := False;
      tb_SeriesDatos.Active := true;
      if tb_SeriesDatos.Locate('IdEstructura;id;codsubs;Fecha;Version', VarArrayOf([tb_depuracion.FieldByName('IdEstructura').AsString, tb_depuracion.FieldByName('id').AsString, tb_depuracion.FieldByName('codsubs').AsString, tb_depuracion.FieldByName('Fecha').AsString, tb_depuracion.FieldByName('Version').AsString]), []) then
      begin
        tb_seriesdatos.edit;
        tb_SeriesDatos.FieldByName('fecha').AsDateTime := Now();
        tb_SeriesDatos.FieldByName('observaciones').AsString := tb_SeriesDatos.FieldByName('observaciones').AsString + sLineBreak + tb_depuracion.FieldByName('fundamentacion').AsString + ' <<Documento Depurado>> <<Fecha dupuracion>> ' + FormatDateTime('dd/mm/yyyy', Now()) + '<< Destino: ' + tb_depuracion.FieldByName('lkdestino').AsString + '>>';
        tb_seriesdatos.post;
        tb_depuracion.Edit;
        tb_depuracion.FieldByName('fechadepuracion').AsDateTime := Now();
        tb_depuracion.FieldByName('depurado').AsBoolean := StrToBool('True');
        tb_depuracion.post;
        cpDepurarDocumentos.Visible := false;
      end;
    end;

  end
  else
  begin
    MessageDlg('Debe describir las acciones realizadas con el documento a Depurar.', mtError, [mbok], 0);
  end;

  QDocumentosDepurados.Refresh;
  tb_depuracion.Refresh;

end;

procedure TfrmDepuracion.cxDocDepurarTbCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  with QDatosSubserie do
  begin
    Active := false;
    with params do
    begin
      Params[0].Value := tb_depuracion.FieldByName('codsubs').AsString;
    end;
    Active := True;
  end;
end;

procedure TfrmDepuracion.cxDocDepurarTbKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  with QDatosSubserie do
  begin
    Active := false;
    with params do
    begin
      Params[0].Value := tb_depuracion.FieldByName('codsubs').AsString;
    end;
    Active := True;
  end;
end;

procedure TfrmDepuracion.cxDocDepurarTbKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  with QDatosSubserie do
  begin
    Active := false;
    with params do
    begin
      Params[0].Value := tb_depuracion.FieldByName('codsubs').AsString;
    end;
    Active := True;
  end;
end;

procedure TfrmDepuracion.cxDocDocDepuradoTvCellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  with QDatosSubserie do
  begin
    Active := false;
    with params do
    begin
      Params[0].Value := QDocumentosDepurados.FieldByName('codsubs').AsString;
    end;
    Active := True;
  end;
end;

procedure TfrmDepuracion.cxDocDocDepuradoTvKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  with QDatosSubserie do
  begin
    Active := false;
    with params do
    begin
      Params[0].Value := QDocumentosDepurados.FieldByName('codsubs').AsString;
    end;
    Active := True;
  end;
end;

procedure TfrmDepuracion.cxDocDocDepuradoTvKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  with QDatosSubserie do
  begin
    Active := false;
    with params do
    begin
      Params[0].Value := QDocumentosDepurados.FieldByName('codsubs').AsString;
    end;
    Active := True;
  end;
end;

procedure TfrmDepuracion.cxGridDBTableView1Column1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if tb_depuracion.FieldByName('destino').AsInteger <> 0 then
  begin
    if not cpDepurarDocumentos.Visible then
      cpDepurarDocumentos.Caption := '';
    cpDepurarDocumentos.Caption := tb_depuracion.FieldByName('titulodoc').AsString;
    cpDepurarDocumentos.Visible := True;

  end
  else
  begin
    MessageDlg('El documento: [' + tb_depuracion.FieldByName('titulodoc').AsString + ' ], a Depurar debe contener un Destino.', mtError, [mbok], 0);

  end;

end;

procedure TfrmDepuracion.tb_depuracionAfterRefresh(DataSet: TDataSet);
begin
  StatusBar.Panels[1].Text := '';
  StatusBar.Panels[1].Text := IntToStr(tb_depuracion.RecordCount);
  StatusBar.Panels[3].Text := '';
  StatusBar.Panels[3].Text := IntToStr(QDocumentosDepurados.RecordCount);
end;

procedure TfrmDepuracion.tb_depuracionPostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin

  if MessageDlg('El documento: [' + DataSet.FieldByName('titulodoc').AsString + ' ],' + sLineBreak + ' está depurado como [Eliminado], y no se ha realizado la acción.Eliminine el Documento. ', mtError, [mbOK, mbCancel], 0) = mrOk then
  begin
    Action := daRetry;
  end
  else
  begin
    Action := daAbort;
  end;

end;

procedure TfrmDepuracion.tsDocDepuradosShow(Sender: TObject);
begin
  if QDocumentosDepurados.SQL.Text <> '' then
  begin
    QDocumentosDepurados.Active := False;
    QDocumentosDepurados.Active := True;
  end;

end;

procedure TfrmDepuracion.tsDocDepurarShow(Sender: TObject);
begin
  if tb_depuracion.SQL.Text <> '' then
  begin
    tb_depuracion.Active := False;
    tb_depuracion.Active := True;
  end;
end;

procedure TfrmDepuracion.FormCreate(Sender: TObject);

  function QDOcDepuarar(version: string): string;
  var
    query: WideString;
  begin
    if lowercase(version) = 'profesional' then
    begin
      query := 'SELECT tb_SeriesDatos.IdEstructura, tb_SeriesDatos.Id, tb_SeriesDatos.codsubs, tb_SeriesDatos.Fecha,' + 'tb_SeriesDatos.Version, tb_SeriesDatos.Codigodoc, tb_SeriesDatos.titulodoc,  tb_SeriesDatos.Archivo, ' + 'tb_SeriesDatos.deposito, tb_SeriesDatos.gaveta, tb_SeriesDatos.Idservidor, tb_SeriesDatos.fichero,' + ' tb_SeriesDatos.namefile, cl_subseries.fechaaprov, cl_subseries.destino, cl_subseries.Detalle AS ValorDoc,' + ' cl_subseries.tgestion, cl_subseries.tcentral FROM tb_SeriesDatos LEFT JOIN cl_subseries ON tb_SeriesDatos.codsubs = cl_subseries.codsubs  ' + ' where ( DateDiff(year,tb_SeriesDatos.Fecha,:param) >cl_subseries.tgestion) or  ( DateDiff(year,tb_SeriesDatos.Fecha,:param1) >cl_subseries.tgestion)  ';
    end;
    if lowercase(version) = 'básica' then
    begin
      query := 'SELECT tb_SeriesDatos.IdEstructura, tb_SeriesDatos.Id, tb_SeriesDatos.codsubs, tb_SeriesDatos.Fecha,' + 'tb_SeriesDatos.Version, tb_SeriesDatos.Codigodoc, tb_SeriesDatos.titulodoc,  tb_SeriesDatos.Archivo, ' + 'tb_SeriesDatos.deposito, tb_SeriesDatos.gaveta, tb_SeriesDatos.Idservidor, tb_SeriesDatos.fichero,' + ' tb_SeriesDatos.namefile, cl_subseries.fechaaprov, cl_subseries.destino, cl_subseries.Detalle AS ValorDoc,' +
        ' cl_subseries.tgestion, cl_subseries.tcentral FROM tb_SeriesDatos LEFT JOIN cl_subseries ON tb_SeriesDatos.codsubs = cl_subseries.codsubs  ' + ' where ( DateDiff(' + QuotedStr('yyyy') + ',tb_SeriesDatos.Fecha,:param) >cl_subseries.tgestion) or  ( DateDiff(' + QuotedStr('yyyy') + ',tb_SeriesDatos.Fecha,:param1) >cl_subseries.tgestion)  ';
    end;
    result := query;

  end;

begin
  if not LocalizaConsulta('tb_depuracion') then
  begin

    if lowercase(programver) = 'básica' then
    begin
      UDM.Conn.ExecSQL('CREATE TABLE "tb_depuracion" ( "IdEstructura" TEXT(50) NOT NULL,"Id" Integer NOT NULL,"codsubs" TEXT(50) NOT NULL,"fecha" date NOT NULL,' + ' "Version" TEXT(12) NOT NULL,"Codigodoc" TEXT(20),"titulodoc" TEXT(255),"Archivo" Integer,"depósito" TEXT(255),"gaveta" TEXT(20),"IdServidor" integer,"fichero" image,' + ' "fechaFin" date,"gestor" integer, "observaciones"  TEXT(255),"IdExpediente" TEXT (12),"namefile" TEXT(12),"destino" integer' + ',"detalle" integer ,"depurado" bit,"fechadepuracion" date,"fundamentacion" TEXT(255),  PRIMARY KEY ("IdEstructura","id","codsubs","Fecha","Version","Codigodoc") ); ');

    end;
    if lowercase(programver) = 'profesional' then
    begin
      UDM.Conn.ExecSQL('CREATE TABLE "tb_depuracion" ( "IdEstructura" VARCHAR(50) NOT NULL,"Id" Integer NOT NULL,"codsubs" VARCHAR(50) NOT NULL,"fecha" date NOT NULL,' + ' "Version" VARCHAR(12) NOT NULL,"Codigodoc" VARCHAR(20),"titulodoc" VARCHAR(255),"Archivo" Integer,"deposito" VARCHAR(255),"gaveta" VARCHAR(20),"IdServidor" integer,"fichero" image,' + ' "fechaFin" date,"gestor" integer, "observaciones"  VARCHAR(255),"IdExpediente" VARCHAR (12),"namefile" VARCHAR(12),"destino" integer' + ',"detalle" integer ,"depurado" bit,"fechadepuracion" date,"fundamentacion" VARCHAR(255),  PRIMARY KEY ("IdEstructura","id","codsubs","Fecha","Version","Codigodoc") ); ');
    end;

  end;

  with QDocDepurarAll do
  begin
   // Active := False;
    sql.Clear;
    SQL.Add(QDOcDepuarar(programver));
    try
  //    Active := True;
    except
    end;
  end;

end;

procedure TfrmDepuracion.FormShow(Sender: TObject);
begin

  pcMain.ActivePage := tsDocDepurar;
  tb_Tree.Active := false;
  tb_Tree.Active := true;

  cl_subseries.Active := false;
  cl_subseries.Active := true;

  cl_destino.Active := false;
  cl_destino.Active := true;
  cl_valorDOc.Active := false;
  cl_valorDOc.Active := True;

  cl_detalle.Active := false;
  cl_detalle.Active := True;

  with QDocumentosDepurados do
  begin
    Active := false;

    if TBD = 'A' then
    begin
      SQL.Clear;
      sql.Add('SELECT tb_depuracion.IdEstructura, tb_depuracion.id, tb_depuracion.titulodoc, tb_depuracion.codsubs, tb_depuracion.archivo, tb_depuracion.Fecha, tb_depuracion.version,' + ' tb_depuracion.Codigodoc, tb_depuracion.gaveta, tb_depuracion.fechaFin, tb_depuracion.gestor, tb_depuracion.fichero, tb_depuracion.Idservidor, tb_depuracion.IdExpediente, tb_depuracion.depurado,' +
        ' tb_depuracion.fechadepuracion, tb_depuracion.deposito, tb_depuracion.fundamentacion, tb_depuracion.detalle, tb_depuracion.destino AS lkDestino, tb_depuracion.namefile,  ' + ' tb_tree.etiqueta, cl_subseries.subserie, cl_valordoc.Valordoc AS lkdetalle, cl_destino.NombreDestino FROM (((tb_depuracion INNER JOIN tb_tree ON (tb_depuracion.Id = tb_tree.id) ' + ' AND (tb_depuracion.IdEstructura = tb_tree.IdEstructura)) INNER JOIN cl_subseries ON tb_depuracion.codsubs = cl_subseries.codsubs) INNER JOIN cl_valordoc ON tb_depuracion.detalle = ' + ' cl_valordoc.Idtipodoc) INNER JOIN cl_destino ON tb_depuracion.destino = cl_destino.IdDestino WHERE (((tb_depuracion.depurado)=true)); ');


    end
    else
    begin
      SQL.Clear;
      sql.Add(' SELECT   tb_depuracion.IdEstructura,	tb_depuracion.id,	tb_depuracion.titulodoc,	tb_depuracion.codsubs,	tb_depuracion.archivo,	tb_depuracion.Fecha,' + ' 	tb_depuracion.version,	tb_depuracion.Codigodoc,	tb_depuracion.gaveta,	tb_depuracion.fechaFin,	tb_depuracion.gestor,	tb_depuracion.fichero,	tb_depuracion.Idservidor,	tb_depuracion.IdExpediente,' +
        '	tb_depuracion.depurado,	tb_depuracion.fechadepuracion,	tb_depuracion.deposito,	tb_depuracion.fundamentacion,	tb_depuracion.detalle,	tb_depuracion.destino,	tb_depuracion.namefile,	tb_tree.etiqueta,' + '	cl_subseries.subserie,	cl_destino.NombreDestino AS lkDestino,	cl_valordoc.Valordoc AS lkdetalle FROM	dbo.tb_depuracion	LEFT JOIN	dbo.tb_tree	ON' + '		tb_depuracion.IdEstructura = tb_tree.IdEstructura AND		tb_depuracion.Id = tb_tree.id	LEFT JOIN	dbo.cl_subseries	ON		tb_depuracion.codsubs = cl_subseries.codsubs' + '	INNER JOIN	dbo.cl_destino	ON		tb_depuracion.destino = cl_destino.IdDestino	INNER JOIN	dbo.cl_valordoc	ON		tb_depuracion.detalle = cl_valordoc.Idtipodoc WHERE 	tb_depuracion.depurado = 1');

    end;



    Active := True;
  end;

  with tb_depuracion do
  begin
    active := False;
    if TBD = 'A' then
    begin
      SQL.Clear;
      sql.Add('SELECT tb_depuracion.IdEstructura, tb_depuracion.id, tb_depuracion.titulodoc, tb_depuracion.codsubs, tb_depuracion.archivo, tb_depuracion.Fecha, tb_depuracion.version,' + ' tb_depuracion.Codigodoc, tb_depuracion.gaveta, tb_depuracion.fechaFin, tb_depuracion.gestor, tb_depuracion.fichero, tb_depuracion.Idservidor, tb_depuracion.IdExpediente, tb_depuracion.depurado,' +
        ' tb_depuracion.fechadepuracion, tb_depuracion.deposito, tb_depuracion.fundamentacion, tb_depuracion.detalle, tb_depuracion.destino AS lkDestino, tb_depuracion.namefile,  ' + ' tb_tree.etiqueta, cl_subseries.subserie, cl_valordoc.Valordoc AS lkdetalle, cl_destino.NombreDestino FROM (((tb_depuracion INNER JOIN tb_tree ON (tb_depuracion.Id = tb_tree.id) ' + ' AND (tb_depuracion.IdEstructura = tb_tree.IdEstructura)) INNER JOIN cl_subseries ON tb_depuracion.codsubs = cl_subseries.codsubs) INNER JOIN cl_valordoc ON tb_depuracion.detalle = ' + ' cl_valordoc.Idtipodoc) INNER JOIN cl_destino ON tb_depuracion.destino = cl_destino.IdDestino WHERE (((tb_depuracion.depurado)=False)); ');

    end
    else
    begin
      SQL.Clear;
      sql.Add(' SELECT   tb_depuracion.IdEstructura,	tb_depuracion.id,	tb_depuracion.titulodoc,	tb_depuracion.codsubs,	tb_depuracion.archivo,	tb_depuracion.Fecha,' + ' 	tb_depuracion.version,	tb_depuracion.Codigodoc,	tb_depuracion.gaveta,	tb_depuracion.fechaFin,	tb_depuracion.gestor,	tb_depuracion.fichero,	tb_depuracion.Idservidor,	tb_depuracion.IdExpediente,' +
        '	tb_depuracion.depurado,	tb_depuracion.fechadepuracion,	tb_depuracion.deposito,	tb_depuracion.fundamentacion,	tb_depuracion.detalle,	tb_depuracion.destino,	tb_depuracion.namefile,	tb_tree.etiqueta,' + '	cl_subseries.subserie,	cl_destino.NombreDestino AS lkDestino,	cl_valordoc.Valordoc AS lkdetalle FROM	dbo.tb_depuracion	LEFT JOIN	dbo.tb_tree	ON' + '		tb_depuracion.IdEstructura = tb_tree.IdEstructura AND		tb_depuracion.Id = tb_tree.id	LEFT JOIN	dbo.cl_subseries	ON		tb_depuracion.codsubs = cl_subseries.codsubs' + '	INNER JOIN	dbo.cl_destino	ON		tb_depuracion.destino = cl_destino.IdDestino	INNER JOIN	dbo.cl_valordoc	ON		tb_depuracion.detalle = cl_valordoc.Idtipodoc WHERE 	tb_depuracion.depurado = 0');

    end;

    Active := True;
  end;

  ReloadDocumentDepurar;
  with QDatosSubserie do
  begin
    Active := false;
    with params do
    begin
      Params[0].Value := tb_depuracion.FieldByName('codsubs').AsString;
    end;
    Active := True;
  end;
  pathreport := ExtractFilePath(Application.ExeName) + 'Report\';
end;

procedure TfrmDepuracion.ReloadDocumentDepurar;
begin

  with QDocDepurarAll do
  begin
    close;
    with params do
    begin
      {Params[0].Value := FormatDateTime('dd-mm-yyyy', Now());
      Params[1].Value := FormatDateTime('dd-mm-yyyy', Now()); }
      Params[0].Value := now();
      Params[1].Value := Now  ();
    end;
    Open;
  end;

  with tb_depuracion do
  begin
    Close;
    Open;
  end;
  QDocDepurarAll.DisableControls;
  QDocDepurarAll.First;
  while not QDocDepurarAll.Eof do
  begin

    if not tb_depuracion.Locate('IdEstructura;id;codsubs;fecha;version;Codigodoc', VarArrayOf([QDocDepurarAll.FieldByName('IdEstructura').AsString, QDocDepurarAll.FieldByName('Id').AsString, QDocDepurarAll.FieldByName('codsubs').AsString, QDocDepurarAll.FieldByName('Fecha').AsString, QDocDepurarAll.FieldByName('Version').AsString, QDocDepurarAll.FieldByName('Codigodoc').AsString]), []) then
    begin
      tb_depuracion.Append;
      tb_depuracion.FieldByName('IdEstructura').AsString := QDocDepurarAll.FieldByName('IdEstructura').AsString;
      tb_depuracion.FieldByName('id').AsString := QDocDepurarAll.FieldByName('Id').AsString;
      tb_depuracion.FieldByName('codsubs').AsString := QDocDepurarAll.FieldByName('codsubs').AsString;
      tb_depuracion.FieldByName('Fecha').AsString := QDocDepurarAll.FieldByName('Fecha').AsString;
      tb_depuracion.FieldByName('Version').AsString := QDocDepurarAll.FieldByName('Version').AsString;
      tb_depuracion.FieldByName('Codigodoc').AsString := QDocDepurarAll.FieldByName('Codigodoc').AsString;
      tb_depuracion.FieldByName('titulodoc').AsString := QDocDepurarAll.FieldByName('titulodoc').AsString;
      tb_depuracion.FieldByName('Archivo').AsString := QDocDepurarAll.FieldByName('Archivo').AsString;
      tb_depuracion.FieldByName('deposito').AsString := QDocDepurarAll.FieldByName('deposito').AsString;
      tb_depuracion.FieldByName('gaveta').AsString := QDocDepurarAll.FieldByName('gaveta').AsString;
      tb_depuracion.FieldByName('Idservidor').AsString := QDocDepurarAll.FieldByName('Idservidor').AsString;
      tb_depuracion.FieldByName('fichero').AsString := QDocDepurarAll.FieldByName('fichero').AsString;
      tb_depuracion.FieldByName('namefile').AsString := QDocDepurarAll.FieldByName('namefile').AsString;
      tb_depuracion.FieldByName('destino').AsString := QDocDepurarAll.FieldByName('destino').AsString;
      tb_depuracion.FieldByName('detalle').AsString := QDocDepurarAll.FieldByName('ValorDoc').AsString;
      if TBD = 'A' then
      begin
        tb_depuracion.FieldByName('depurado').AsBoolean := StrToBool('False');
      end
      else
      begin
        tb_depuracion.FieldByName('depurado').AsBoolean := false;
      end;

      tb_depuracion.Post;

    end;

    QDocDepurarAll.Next;
  end;
  QDocDepurarAll.EnableControls;
  tb_depuracion.Refresh;
  tb_depuracion.First;
end;

end.

