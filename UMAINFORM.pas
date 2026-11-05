unit UMAINFORM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus,
  AdvMenus, JvExControls, JvButton, JvTransparentButton, Vcl.ExtCtrls,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, AdvOfficeStatusBar, Vcl.ComCtrls, dxtree, dxdbtree,
  dxNavBarCollns, cxClasses, dxNavBarBase, dxNavBar, cxLocalization,
  AdvMetroScrollBox, ToolPanels, Data.DB, dxBarBuiltInMenu, cxContainer, cxEdit,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator,
  dxDateRanges, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGridCustomView, cxGrid, cxMemo, cxDBEdit, cxTextEdit,
  Vcl.StdCtrls, cxPC, Vcl.DBCtrls, cxDBNavigator, Vcl.Buttons, AdvPanel,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, cxBlobEdit,
  cxCheckBox, cxRichEdit, cxVGrid, cxDBVGrid, cxInplaceContainer,
  cxDBLookupComboBox, cxImage, cxDropDownEdit, cxLookupEdit, cxDBLookupEdit,
  JvExExtCtrls, JvExtComponent, JvCaptionPanel, dxLayoutContainer,
  cxGridInplaceEditForm, Winapi.ShellAPI, AdvSplitter, cxCalendar, AdvLabel,
  AdvScrollBox, cxButtonEdit, cxLabel, System.ImageList, Vcl.ImgList,
  Vcl.DBActns, System.Actions, Vcl.ActnList, dxDateTimeWheelPicker, JvBaseDlg,
  JvSelectDirectory, cxTL, cxTLdxBarBuiltInMenu, Vcl.Samples.Gauges, cxDBTL,
  cxTLData, System.StrUtils, JvDialogs, cxButtons, cxGridBandedTableView,
  cxGridDBBandedTableView, AdvMenuStylers, System.HelpIntfs, Vcl.HtmlHelpViewer,
  Vcl.AppEvnts, Vcl.Themes, frxClass, frxADOComponents, frxRich, frxDBSet,
  System.DateUtils, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdExplicitTLSClientServerBase, IdFTP, IdException, adoint, adodb, Math,
  cxDBRichEdit, System.Generics.Collections, cxSplitter, AdvListV, DBAdvLst,
  IniFiles, cxSpinEdit, Vcl.Grids, Vcl.DBGrids, JvDBControls, cxMaskEdit,
  dxScreenTip, dxCustomHint, cxHint, cxEditRepositoryItems, cxGroupBox,
  UBusqueda, UAlcance, UPanelDocumentos, UDocumentoVista, UMigracionPantalla;

type
  TComboBoxFieldAssociation = record
    ComboBox: TcxComboBoxProperties;
    GridRow: Integer;
    FieldName: string;
  end;
    // Usar una lista para almacenar las asociaciones

  TComboBoxFieldAssociations = TList<TComboBoxFieldAssociation>;

  TMAIN = class(TForm)
    PMListascod: TAdvPopupMenu;
    A1: TMenuItem;
    L1: TMenuItem;
    S1: TMenuItem;
    nbMain: TdxNavBar;
    bgBD: TdxNavBarGroup;
    bgBDControl: TdxNavBarGroupControl;
    tvTree: TTreeView;
    MB: TAdvOfficeStatusBar;
    cxLocalizer1: TcxLocalizer;
    PMAyuda: TAdvPopupMenu;
    Ayuda1: TMenuItem;
    P1: TMenuItem;
    N6: TMenuItem;
    Acercade1: TMenuItem;
    N5: TMenuItem;
    ControldeVersiones1: TMenuItem;
    advManagementDirectoryPath: TAdvPopupMenu;
    I1: TMenuItem;
    N121: TMenuItem;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    PMManagementFile: TAdvPopupMenu;
    V2: TMenuItem;
    N2: TMenuItem;
    G1: TMenuItem;
    E2: TMenuItem;
    AdvMenuStyler1: TAdvMenuStyler;
    PContainer: TAdvMetroScrollBox;
    advtpCC: TAdvToolPanelTab;
    advtpCuadroClasif: TAdvToolPanel;
    ViewServerDetail: TFDQuery;
    dsViewServerDetail: TDataSource;
    PageControl1: TcxPageControl;
    tsBasicView: TcxTabSheet;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label1: TLabel;
    edtSerieDocumental: TcxDBMemo;
    edtSubSerieDocumental: TcxDBMemo;
    cxTabSheet2: TcxTabSheet;
    GViewSeriesI: TcxGrid;
    GViewSeriesIDBTableView1: TcxGridDBTableView;
    GViewSeriesIDBTableView1IdEstructura: TcxGridDBColumn;
    GViewSeriesIDBTableView1id: TcxGridDBColumn;
    GViewSeriesIDBTableView1codsubs: TcxGridDBColumn;
    d: TcxGridDBColumn;
    GViewSeriesIDBTableView1tipoArchivo: TcxGridDBColumn;
    GViewSeriesIDBTableView1Archivo: TcxGridDBColumn;
    GViewSeriesIDBTableView1deposito: TcxGridDBColumn;
    GViewSeriesIDBTableView1gaveta: TcxGridDBColumn;
    GViewSeriesIDBTableView1usuario: TcxGridDBColumn;
    GViewSeriesIDBTableView1correo: TcxGridDBColumn;
    GViewSeriesIDBTableView1observacion: TcxGridDBColumn;
    GViewSeriesIDBTableView1Idservidor: TcxGridDBColumn;
    GViewSeriesIDBTableView1carpeta: TcxGridDBColumn;
    GViewSeriesIDBTableView1RootGroup: TcxGridInplaceEditFormGroup;
    GViewSeriesILevel1: TcxGridLevel;
    AdvPanel2: TAdvPanel;
    DBNavigator3: TDBNavigator;
    cxDBNavigator3: TcxDBNavigator;
    PSeriesDatos: TAdvPanel;
    AdvSplitter4: TAdvSplitter;
    cpProgress: TJvCaptionPanel;
    PMManagementFileSubSerie: TAdvPopupMenu;
    MenuItem5: TMenuItem;
    MenuItem10: TMenuItem;
    mGestionarContentFile: TMenuItem;
    MenuItem11: TMenuItem;
    dstb_SeriesDatos: TDataSource;
    dstb_Serietree: TDataSource;
    cxStyleRepository1: TcxStyleRepository;
    Test: TcxStyle;
    jvcpSSDetail: TJvCaptionPanel;
    pcDetalle: TcxPageControl;
    tsTopo: TcxTabSheet;
    cmdArch: TFDQuery;
    dscmdArch: TDataSource;
    dscmdGestor: TDataSource;
    cmdGestor: TFDQuery;
    tsGestor: TcxTabSheet;
    tsServidor: TcxTabSheet;
    cxDBVerticalGrid6: TcxDBVerticalGrid;
    cxCategoryRow3: TcxCategoryRow;
    cxDBVerticalGrid7: TcxDBVerticalGrid;
    cxCategoryRow4: TcxCategoryRow;
    cxDBVerticalGrid6usuario: TcxDBEditorRow;
    cxDBVerticalGrid6CorreoElect: TcxDBEditorRow;
    cxDBVerticalGrid6rol: TcxDBEditorRow;
    cxDBVerticalGrid6Telefono: TcxDBEditorRow;
    cxDBVerticalGrid7ipserver: TcxDBEditorRow;
    cxDBVerticalGrid7path: TcxDBEditorRow;
    cxDBVerticalGrid7user: TcxDBEditorRow;
    cxDBVerticalGrid7puerto: TcxDBEditorRow;
    ActionList1: TActionList;
    DatasetPost1: TDataSetPost;
    DatasetCancel1: TDataSetCancel;
    ImageList1: TImageList;
    AdvPanel13: TAdvPanel;
    Label9: TLabel;
    Label8: TLabel;
    Label5: TLabel;
    edtGaveta: TcxDBTextEdit;
    edtDeposito: TcxDBTextEdit;
    lcbArchivo: TcxDBLookupComboBox;
    Label10: TLabel;
    lcbGestor: TcxDBLookupComboBox;
    Label11: TLabel;
    cxDBVerticalGrid5: TcxDBVerticalGrid;
    cxCategoryRow2: TcxCategoryRow;
    cxDBVerticalGrid5Tipo: TcxDBEditorRow;
    cxDBVerticalGrid5Idresp: TcxDBEditorRow;
    cxDBVerticalGrid5croquis: TcxDBEditorRow;
    cxDBVerticalGrid5Foto: TcxDBEditorRow;
    cxDBVerticalGrid5Descripcion: TcxDBEditorRow;
    Label3: TLabel;
    edtObs: TcxDBBlobEdit;
    Timer1: TTimer;
    SD: TJvSelectDirectory;
    ODArchDig: TJvOpenDialog;
    dsTb_SeriesDispo: TDataSource;
    gProcess: TGauge;
    PMTool: TAdvPopupMenu;
    D3: TMenuItem;
    P3: TMenuItem;
    log: TMenuItem;
    btnTransfer: TMenuItem;
    advtpDetalle: TAdvToolPanelTab;
    advtpSSDispo: TAdvToolPanel;
    AdvPanel1: TAdvPanel;
    DBNavigator1: TDBNavigator;
    cxDBNavigator1: TcxDBNavigator;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1codserie: TcxGridDBColumn;
    cxGrid1DBTableView1codsubs: TcxGridDBColumn;
    cxGrid1DBTableView1Series: TcxGridDBColumn;
    cxGrid1DBTableView1Subseries: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    advtpDetail: TAdvToolPanel;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid2CategoryRow6: TcxCategoryRow;
    cxDBVerticalGrid2subserie: TcxDBEditorRow;
    cxDBVerticalGrid2codsubs: TcxDBEditorRow;
    cxDBVerticalGrid2serie: TcxDBEditorRow;
    cxDBVerticalGrid2Tipodoc: TcxDBEditorRow;
    cxDBVerticalGrid2Nombresoporte: TcxDBEditorRow;
    cxDBVerticalGrid2NombreAcceso: TcxDBEditorRow;
    cxDBVerticalGrid2observacion: TcxDBEditorRow;
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
    pArchivoDig: TAdvToolPanel;
    sbAD: TAdvOfficeStatusBar;
    cxPageControl1: TcxPageControl;
    tsFuentes: TcxTabSheet;
    AdvSplitter5: TAdvSplitter;
    AdvPanel10: TAdvPanel;
    btnSourceFile: TJvTransparentButton;
    btnAddListSource: TJvTransparentButton;
    btnDropSourceFile: TJvTransparentButton;
    btnRemoveSourceFileList: TJvTransparentButton;
    btnExecuteSourceFile: TJvTransparentButton;
    tsAnexosDig: TcxTabSheet;
    SourceFileADToolBar: TAdvPanel;
    btnaddfile: TJvTransparentButton;
    btnaddfilelist: TJvTransparentButton;
    btnremovefile: TJvTransparentButton;
    btnRemoveFileList: TJvTransparentButton;
    btnExecFileAD: TJvTransparentButton;
    tsCoord: TcxTabSheet;
    cxGrid6: TcxGrid;
    cxGridDBTableView3: TcxGridDBTableView;
    cxGridDBTableView3IdEstructura: TcxGridDBColumn;
    cxGridDBTableView3id: TcxGridDBColumn;
    cxGridDBTableView3codsubs: TcxGridDBColumn;
    cxGridDBTableView3Fecha: TcxGridDBColumn;
    cxGridDBTableView3Version: TcxGridDBColumn;
    cxGridDBTableView3idVertice: TcxGridDBColumn;
    cxGridDBTableView3x: TcxGridDBColumn;
    cxGridDBTableView3y: TcxGridDBColumn;
    cxGridLevel3: TcxGridLevel;
    AdvPanel14: TAdvPanel;
    cxDBNavigator4: TcxDBNavigator;
    DBNavigator2: TDBNavigator;
    tsOtherData: TcxTabSheet;
    PMPL: TAdvPopupMenu;
    PLAD: TMenuItem;
    PLDS: TMenuItem;
    PLSD: TMenuItem;
    PAAD: TMenuItem;
    VAD: TMenuItem;
    PADS: TMenuItem;
    VDSS: TMenuItem;
    PASD: TMenuItem;
    VSSD: TMenuItem;
    PopupMenu1: TPopupMenu;
    Archivos1: TMenuItem;
    ServidoresFTP1: TMenuItem;
    SeriesySubseriesDocumentales1: TMenuItem;
    AdvMenuStyler2: TAdvMenuStyler;
    B1: TMenuItem;
    btnExportExcelCC: TJvTransparentButton;
    btnAdjustColumnCC: TJvTransparentButton;
    btnRemoveSerieAsig: TJvTransparentButton;
    btnRemoveAllSeriesAsig: TJvTransparentButton;
    btnAsignSS: TJvTransparentButton;
    btnAsignarSS: TJvTransparentButton;
    btnExcelExportSSD: TJvTransparentButton;
    btnAdjustColumnSSD: TJvTransparentButton;
    I2: TMenuItem;
    pmReportArchigenio: TAdvPopupMenu;
    cclasificacion: TMenuItem;
    registrotopografico: TMenuItem;
    plazoretencion: TMenuItem;
    seriesvalorar: TMenuItem;
    OpenDialog1: TOpenDialog;
    frxMain: TfrxReport;
    frxADOComponents1: TfrxADOComponents;
    Panel1: TPanel;
    JvTransparentButton4: TJvTransparentButton;
    JvTransparentButton8: TJvTransparentButton;
    JvTransparentButton10: TJvTransparentButton;
    Edit2: TEdit;
    JvTransparentButton11: TJvTransparentButton;
    jvcpExpediente: TJvCaptionPanel;
    ApplicationEvents1: TApplicationEvents;
    btnViewtopoSS: TJvTransparentButton;
    frxtb_sysconfig: TfrxDBDataset;
    Label6: TLabel;
    Panel2: TPanel;
    btnClosejvcpExpediente: TJvTransparentButton;
    JvTransparentButton6: TJvTransparentButton;
    Edit3: TEdit;
    ExpAllDoc: TFDQuery;
    dsExpAllDoc: TDataSource;
    pQuickFill: TPanel;
    lblQuickFill: TLabel;
    edtFill: TEdit;
    btnquickFill: TJvTransparentButton;
    Timer2: TTimer;
    Optimizer: TTimer;
    cxDBVerticalGrid2tiposerie: TcxDBEditorRow;
    ImageList2: TImageList;
    IdFTP1: TIdFTP;
    tsVar: TcxTabSheet;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    dsVar: TDataSource;
    md_var: TFDQuery;
    cxPageControl2: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet3: TcxTabSheet;
    AdvPanel6: TAdvPanel;
    JvTransparentButton5: TJvTransparentButton;
    btnExportExcelDoc: TJvTransparentButton;
    JvTransparentButton9: TJvTransparentButton;
    cxDBNavigator2: TcxDBNavigator;
    pVerticalTitle: TPanel;
    cxGrid2: TcxGrid;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2DBTableView1IdEstructura: TcxGridDBColumn;
    cxGrid2DBTableView1id: TcxGridDBColumn;
    cxGrid2DBTableView1codsubs: TcxGridDBColumn;
    cxGrid2DBTableView1Fecha: TcxGridDBColumn;
    cxGrid2DBTableView1Version: TcxGridDBColumn;
    cxGrid2DBTableView1Codigodoc: TcxGridDBColumn;
    cxGrid2DBTableView1titulodoc: TcxGridDBColumn;
    cxGrid2DBTableView1Archivo: TcxGridDBColumn;
    cxGrid2DBTableView1deposito: TcxGridDBColumn;
    cxGrid2DBTableView1gaveta: TcxGridDBColumn;
    cxGrid2DBTableView1Idservidor: TcxGridDBColumn;
    cxGrid2DBTableView1gestor: TcxGridDBColumn;
    cxGrid2DBTableView1observaciones: TcxGridDBColumn;
    cxGrid2DBTableView1IDExpediente: TcxGridDBColumn;
    cxGrid2DBTableView1visible: TcxGridDBColumn;
    cxGrid2Level1: TcxGridLevel;
    Panel3: TPanel;
    cxGrid3: TcxGrid;
    cxGridDBTableView4: TcxGridDBTableView;
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
    cxGridDBColumn11: TcxGridDBColumn;
    cxGridDBColumn12: TcxGridDBColumn;
    cxGridDBColumn13: TcxGridDBColumn;
    cxGridDBColumn14: TcxGridDBColumn;
    cxGridDBColumn15: TcxGridDBColumn;
    cxGridDBColumn16: TcxGridDBColumn;
    cxGridLevel4: TcxGridLevel;
    cxDBVerticalGrid3: TcxDBVerticalGrid;
    md_def: TFDQuery;
    AdvPanel3: TAdvPanel;
    cxDBNavigator5: TcxDBNavigator;
    DBNavigator4: TDBNavigator;
    cxGrid2DBTableView1posicion: TcxGridDBColumn;
    jvcpDescripcionEtiq: TJvCaptionPanel;
    cxDBRichEdit1: TcxDBRichEdit;
    btnviewTopoDocActual: TJvTransparentButton;
    ppmtvTree: TAdvPopupMenu;
    MtvFont: TMenuItem;
    N1: TMenuItem;
    P2: TMenuItem;
    FontDialog1: TFontDialog;
    N3: TMenuItem;
    pmtvReset: TMenuItem;
    cxSplitter1: TcxSplitter;
    VarCL: TFDQuery;
    dsVarCL: TDataSource;
    gVariablesDetailDBTableView1: TcxGridDBTableView;
    gVariablesDetailLevel1: TcxGridLevel;
    gVariablesDetail: TcxGrid;
    gVariablesDetailDBTableView1NomVariable: TcxGridDBColumn;
    gVariablesDetailDBTableView1Etiqueta: TcxGridDBColumn;
    gVariablesDetailDBTableView1tipo: TcxGridDBColumn;
    gVariablesDetailDBTableView1longitud: TcxGridDBColumn;
    gVariablesDetailDBTableView1descripcion: TcxGridDBColumn;
    C1: TMenuItem;
    Panel4: TPanel;
    cxSpinEdit1: TcxSpinEdit;
    cxLabel1: TcxLabel;
    cxGrid4DBTableView1: TcxGridDBTableView;
    cxGrid4Level1: TcxGridLevel;
    cxGrid4: TcxGrid;
    cxGrid4DBTableView1IdEstructura: TcxGridDBColumn;
    cxGrid4DBTableView1id: TcxGridDBColumn;
    cxGrid4DBTableView1codsubs: TcxGridDBColumn;
    cxGrid4DBTableView1Fecha: TcxGridDBColumn;
    cxGrid4DBTableView1Version: TcxGridDBColumn;
    cxGrid4DBTableView1Codigodoc: TcxGridDBColumn;
    cxGrid4DBTableView1idhijo: TcxGridDBColumn;
    cxGrid4DBTableView1nombre: TcxGridDBColumn;
    cxGrid4DBTableView1Etiqueta: TcxGridDBColumn;
    cxGrid4DBTableView1ext: TcxGridDBColumn;
    cxGrid4DBTableView1extnombre: TcxGridDBColumn;
    cxGrid4DBTableView1comentario: TcxGridDBColumn;
    cxGrid4DBTableView1urlraiz: TcxGridDBColumn;
    cxGrid4DBTableView1path: TcxGridDBColumn;
    cxGrid4DBTableView1tamano: TcxGridDBColumn;
    cxGrid4DBTableView1padre: TcxGridDBColumn;
    cxGrid4DBTableView1nivel: TcxGridDBColumn;
    cxGrid4DBTableView1fuente: TcxGridDBColumn;
    cxGrid5DBTableView1: TcxGridDBTableView;
    cxGrid5Level1: TcxGridLevel;
    cxGrid5: TcxGrid;
    cxGrid5DBTableView1IdEstructura: TcxGridDBColumn;
    cxGrid5DBTableView1id: TcxGridDBColumn;
    cxGrid5DBTableView1codsubs: TcxGridDBColumn;
    cxGrid5DBTableView1Fecha: TcxGridDBColumn;
    cxGrid5DBTableView1Version: TcxGridDBColumn;
    cxGrid5DBTableView1Codigodoc: TcxGridDBColumn;
    cxGrid5DBTableView1idhijo: TcxGridDBColumn;
    cxGrid5DBTableView1nombre: TcxGridDBColumn;
    cxGrid5DBTableView1Etiqueta: TcxGridDBColumn;
    cxGrid5DBTableView1ext: TcxGridDBColumn;
    cxGrid5DBTableView1extnombre: TcxGridDBColumn;
    cxGrid5DBTableView1comentario: TcxGridDBColumn;
    cxGrid5DBTableView1urlraiz: TcxGridDBColumn;
    cxGrid5DBTableView1path: TcxGridDBColumn;
    cxGrid5DBTableView1tamano: TcxGridDBColumn;
    cxGrid5DBTableView1padre: TcxGridDBColumn;
    cxGrid5DBTableView1nivel: TcxGridDBColumn;
    cxGrid5DBTableView1fuente: TcxGridDBColumn;
    qRecupera: TFDQuery;
    dsqRecupera: TDataSource;
    pMainContainer: TPanel;
    btnClose: TJvTransparentButton;
    btnautentica: TJvTransparentButton;
    btnusercontrol: TJvTransparentButton;
    btnLC: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnRecuperacion: TJvTransparentButton;
    btnManagementTree: TJvTransparentButton;
    btnTool: TJvTransparentButton;
    btnViewPanel: TJvTransparentButton;
    Edit1: TEdit;
    tmrUpdate: TTimer;
    cxLookAndFeelController1: TcxLookAndFeelController;
    dbnSeriesDatos: TJvDBNavigator;
    lcbServer: TDBLookupComboBox;
    cxDBNavigator6: TcxDBNavigator;
    cxHintStyleController1: TcxHintStyleController;
    cxEditRepository1: TcxEditRepository;
    cxEditRepository1ButtonItem1: TcxEditRepositoryButtonItem;
    cxGrid2DBTableView1fichero: TcxGridDBColumn;
    cxEditRepository1ButtonItem2: TcxEditRepositoryButtonItem;
    btnExpediente: TcxEditRepositoryButtonItem;
    cxHintStyleController2: TcxHintStyleController;
    Panel5: TPanel;
    tb_expxtiposerie: TFDQuery;
    dstb_expxtiposerie: TDataSource;
    Panel6: TPanel;
    Label4: TLabel;
    JvTransparentButton1: TJvTransparentButton;
    edtFillExp: TEdit;
    lcbIDExp: TDBLookupComboBox;
    cxGrid7: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    codsubs: TcxGridDBColumn;
    codigodoc: TcxGridDBColumn;
    Fecha: TcxGridDBColumn;
    Version: TcxGridDBColumn;
    titulodoc: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    cxGroupBox1: TcxGroupBox;
    edtExpAsignado: TcxDBTextEdit;
    btnClearExp: TcxButton;
    Panel7: TPanel;
    cxRichEdit1: TcxRichEdit;
    cxLookAndFeelController2: TcxLookAndFeelController;
    Vacio: TcxStyle;
    Lleno: TcxStyle;
    LlenoOdd: TcxStyle;
    VacioOdd: TcxStyle;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnautenticaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure tvTreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnPrintClick(Sender: TObject);
    procedure btnusercontrolClick(Sender: TObject);
    procedure A1Click(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure T3Click(Sender: TObject);
    procedure F1Click(Sender: TObject);
    procedure L1Click(Sender: TObject);
    procedure pmtvResetClick(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure S2Click(Sender: TObject);
    procedure T1Click(Sender: TObject);
    procedure T2Click(Sender: TObject);
    procedure T4Click(Sender: TObject);
    procedure btnManagementTreeClick(Sender: TObject);
    procedure cxDBBlobEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure I1Click(Sender: TObject);
    procedure cpProgressButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
    procedure cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure MenuItem5Click(Sender: TObject);
    procedure mGestionarContentFileClick(Sender: TObject);
    function ConstruirRutaArchivo(const ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc: string): string;
    procedure MenuItem11Click(Sender: TObject);
    procedure dstb_SeriesDatosDataChange(Sender: TObject; Field: TField);
    procedure GViewSeriesDBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxDBVerticalGrid2observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure SpeedButton3Click(Sender: TObject);
    procedure dstb_SerietreeDataChange(Sender: TObject; Field: TField);
    procedure btnAsignVarVirClick(Sender: TObject);
    procedure Acercade1Click(Sender: TObject);
    procedure ControldeVersiones1Click(Sender: TObject);
    procedure V2Click(Sender: TObject);
    procedure G1Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure E2Click(Sender: TObject);
    procedure cxDBVerticalGrid3observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure lcbArchivoPropertiesCloseUp(Sender: TObject);
    procedure btnDetallesClick(Sender: TObject);
    procedure cxDBVerticalGrid5DescripcionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure jvcpSSDetailButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
    procedure lcbGestorPropertiesCloseUp(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure lcbArchivoEnter(Sender: TObject);
    procedure lcbGestorEnter(Sender: TObject);
    procedure lcbServerEnter(Sender: TObject);
    procedure edtObsPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure edtCarpetaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure SpeedButton8Click(Sender: TObject);
    procedure T5Click(Sender: TObject);
    procedure cxDBTreeList2DblClick(Sender: TObject);
    procedure btnAdjustClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btnRecuperacionClick(Sender: TObject);
    procedure btnremovefileClick(Sender: TObject);
    procedure btnRemoveFileListClick(Sender: TObject);
    procedure btnaddfileClick(Sender: TObject);
    procedure btnaddfilelistClick(Sender: TObject);
    procedure cxGridDBTableView2comentarioPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxGridDBTableView2CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure btnExecFileADClick(Sender: TObject);
    procedure btnAddListSourceClick(Sender: TObject);
    procedure btnSourceFileClick(Sender: TObject);
    procedure btnExecuteSourceFileClick(Sender: TObject);
    procedure btnDropSourceFileClick(Sender: TObject);
    procedure btnRemoveSourceFileListClick(Sender: TObject);
    procedure tlFuenteDblClick(Sender: TObject);
    procedure cxGridDBColumn11PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure cxDBNavigator4ButtonsButtonClick(Sender: TObject; AButtonIndex: Integer; var ADone: Boolean);
    procedure SpeedButton12Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure btnValueClick(Sender: TObject);
    procedure PLADClick(Sender: TObject);
    procedure PLCCClick(Sender: TObject);
    procedure PLDSClick(Sender: TObject);
    procedure PLSDClick(Sender: TObject);
    procedure P1Click(Sender: TObject);
    procedure btnExportExcelDocClick(Sender: TObject);
    procedure cxGridDBTableView1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure B1Click(Sender: TObject);
    procedure btnViewPanelClick(Sender: TObject);
    procedure Ayuda1Click(Sender: TObject);
    procedure tvTreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cclasificacionClick(Sender: TObject);
    procedure registrotopograficoClick(Sender: TObject);
    procedure plazoretencionClick(Sender: TObject);
    procedure seriesvalorarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure I4Click(Sender: TObject);
    procedure jvcpSSDetailEndAutoDrag(Sender: TObject);
    procedure cpProgressEndAutoDrag(Sender: TObject);
    procedure jvcpExpedienteEndAutoDrag(Sender: TObject);
    procedure btnAsignSSClick(Sender: TObject);
    procedure logClick(Sender: TObject);
    function ApplicationEvents1Help(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
    procedure FormDestroy(Sender: TObject);
    procedure I2Click(Sender: TObject);
    procedure btnClosejvcpExpedienteClick(Sender: TObject);
    procedure cxGrid2DBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure lcbIDExpCloseUp(Sender: TObject);
    procedure edtFillKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnquickFillClick(Sender: TObject);
    procedure edtFillChange(Sender: TObject);
    procedure OptimizerTimer(Sender: TObject);
    procedure btnTransferClick(Sender: TObject);
    procedure D3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure JvTransparentButton11Click(Sender: TObject);
    procedure lcbArchivoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure JvTransparentButton6Click(Sender: TObject);
    procedure tvTreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure md_varBeforePost(DataSet: TDataSet);
    procedure cxPageControl1Change(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure btnviewTopoDocActualClick(Sender: TObject);
    procedure cxDBVerticalGrid3Editing(Sender: TObject; ARowProperties: TcxCustomEditorRowProperties; var Allow: Boolean);
    procedure MtvFontClick(Sender: TObject);
    procedure P2Click(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure GViewSeriesIDBTableView1FocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
    procedure cxSpinEdit1PropertiesChange(Sender: TObject);
    procedure cxGrid2DBTableView1GetCellHeight(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; ACellViewInfo: TcxGridTableDataCellViewInfo; var AHeight: Integer);
    procedure cxGrid4DBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure cxGrid4DBTableView1DblClick(Sender: TObject);
    procedure tsFuentesEnter(Sender: TObject);
    procedure tsFuentesClick(Sender: TObject);
    procedure tsFuentesShow(Sender: TObject);
    procedure tsAnexosDigClick(Sender: TObject);
    procedure tsAnexosDigEnter(Sender: TObject);
    procedure tsAnexosDigShow(Sender: TObject);
    procedure tsAnexosDigDblClick(Sender: TObject);
    procedure cxGrid4DBTableView1comentarioPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxGrid5DBTableView1comentarioPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxTabSheet1Show(Sender: TObject);
    procedure GViewSeriesIDBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure tmrUpdateTimer(Sender: TObject);
    procedure pArchivoDigCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
    procedure pArchivoDigNodeCollapse(Sender: TObject; SectionIndex: Integer);
    procedure pArchivoDigNodeExpand(Sender: TObject; SectionIndex: Integer);
    procedure AdvPanel10Resize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure cxPageControl2Change(Sender: TObject);
    procedure GViewSeriesIDBTableView1MouseEnter(Sender: TObject);
    procedure pVerticalTitleClick(Sender: TObject);
    procedure cxEditRepository1ButtonItem2PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnExpedientePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure edtFillExpChange(Sender: TObject);
    procedure cxGridDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure btnClearExpClick(Sender: TObject);
    procedure cxGrid2DBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
    procedure P3Click(Sender: TObject);
  private
    FShellMenuConfig: TPopupMenu;
    FShellMenuClasif: TPopupMenu;
    // Lista de documentos de la subserie (F2)
    FListaDocs: TPanelDocumentos;
    FBarraRejilla: TPanel;
    FEnlaceDocs: TObject;
    FTimerDocs: TTimer;
    FModoLista: Boolean;
    FCargandoDocs: Boolean;
    FComboBoxAssociations: TComboBoxFieldAssociations;
    FIsAuthenticated: Boolean; // RASTREA SI EL USUARIO ESTÁ AUTENTICADO
    FLoginImage: TBitmap; // Imagen para el estado "no autenticado"
    FLogoutImage: TBitmap; // Imagen para el estado "autenticado"
//    FComboBoxAssociations: TArray<TComboBoxFieldAssociation>;
//    FComboBoxAssociations: TDictionary<TcxComboBoxProperties, string>;
    procedure UpdateButtonImage;
    procedure PrepareSSDisp;
    procedure PrepareSSDetailView;
    procedure PrepareServerDetailView;
    procedure ArchivoActual;
    procedure adminOptions;
    procedure VisorOptions;
    procedure GestorOptions;
    procedure ArchiveroOpts;
    procedure Acomoda;
    procedure Acomoda2;
    procedure cxDBVerticalGridClick(Sender: TObject);
    procedure ConfigureVariablesGrid(const ASubserie: string);
    function GetSubserie: string;
    function HasVariablesForSubserie(const ASubserie: string): Boolean;
    procedure UpdateVariablesDisplay;
    procedure ConfigureGridNavigation;
    function IsUserAuthorized(const UserRole: string): Boolean;
    function HasTopographicData(DataSet: TDataSet): Boolean;
    { Private declarations }

  public
    { Public declarations }
    varUltimoQuery: string;
    iRow: integer; //Posicion en la fila de la VerticalGrid
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Rellena;
    procedure RellenaPrj;
    procedure OcultaVGVardef;
    procedure OcultaVGVardefPrj;
    procedure SaveTreeStateNode;
    procedure LoadTreeStateNode;
    procedure CleanTMP(Dir: string);
    procedure MDSeriesSubSeriesDMDR;
    procedure RemoveMDSeriesSubSeriesDMDR;
    function TamFichero(n: string): longint;
    procedure ReactiveAnexos;
    procedure CloseHelpWnd;
    procedure CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
    procedure InsertConnection(report: TfrxReport; connection: string);
    function GetCantOfDay(aFech: TDateTime): integer;
    procedure ChangeAttributes(const Dir: string);
    function CheckFTPConnection(const Host, Username, Password: string; Puerto: integer): Boolean;
    procedure Permisos(Opts: string);
    procedure CreateVerticalGridRows(DBVerticalGrid: TcxDBVerticalGrid; Query: TFDQuery; LabelQuery: TFDQuery);
    procedure ConfigureNavigatorBar(DBVerticalGrid: TcxDBVerticalGrid);
    procedure ApplyBestFit(DBVerticalGrid: TcxDBVerticalGrid);
    procedure BuscarDocumentosClick(Sender: TObject);
    procedure CargaValue(Sender: TObject);
    procedure SaveGridLayout(GridView: TcxGridTableView; const LayoutName: string);
    procedure LoadGridLayout(GridView: TcxGridTableView; const LayoutName: string);
    procedure LoadComboBoxValues(ComboBoxProperties: TcxComboBoxProperties; tbname, FieldName: string);
    procedure ComboBoxCloseUp(Sender: TObject);
    procedure CbDItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure HandleSubserieChange;
    procedure ShowVariablesForSubserie;
    procedure SaveTreeViewFont(TreeView: TTreeView; const FileName: string);
    procedure LoadTreeViewFont(TreeView: TTreeView; const FileName: string);
    function changeText(RTFText: string): string;
    procedure GuardarEstadoNavBar(NavBar: TdxNavBar; const ArchivoINI: string);
    procedure RestaurarEstadoNavBar(NavBar: TdxNavBar; const ArchivoINI: string);
    procedure GuardarEstadoToolPanel(ToolPanel: TAdvToolPanel; const ArchivoINI: string);
    procedure CargarEstadoToolPanel(ToolPanel: TAdvToolPanel; const ArchivoINI: string);
    procedure FilterSource;
    procedure FilterNoSource;
    procedure FormatearGrid(cxGrid: TcxGrid; Query: TFDQuery);
    function CargarVariablesSubserie(ASubserieID: string): string;
    procedure CopyColumnsAndProperties(SourceView, TargetView: TcxGridDBTableView);
    procedure ViewVarDetail(V: boolean);
    procedure PropagarCambiosTopograficos;
    // Reglas de botones y menus del documento actual (ver cabeceras en la implementacion)
    procedure AplicarReglasDocumento;
    procedure AplicarReglasPorAlcance;
    procedure AplicarReglasPorRolHeredado(Rol: string);
    procedure AplicarReglasGestorHeredado;
    function GetIdResp(aUser: string): Integer;
    procedure SetVisibilityForButtons(Visible: Boolean);
    procedure SetDbNavigatorButtons(Buttons: TNavButtonSet);
    // Respuestas al shell de la variante A (UShellPrincipal)
    procedure ConectarShell;
    procedure ConectarListaDocumentos;
    procedure ListaDocsCambio(Sender: TObject);
    procedure ListaDocsRefrescar(Sender: TObject);
    procedure ListaDocsCargar;
    procedure RegistrarErrorLista(const Texto: string);
    function ListaDocsLocalizar(const Clave: TClaveDocumento): Boolean;
    procedure ListaDocsSeleccion(const Clave: TClaveDocumento);
    procedure ListaDocsAbrir(const Clave: TClaveDocumento);
    function ListaDocsFicheros(const Clave: TClaveDocumento): TArray<TFicheroDoc>;
    procedure ListaDocsAlternar(Sender: TObject);
    procedure ShellAgregarDocumento(Sender: TObject);
    procedure ShellBuscar(const Texto: string; Ambito: TAmbitoBusqueda);
    function SeleccionarNodoEnArbol(const Nodo: TClaveNodo): Boolean;
    procedure ShellMenuConfiguracion;
    procedure ShellMenuClasificadores;
    function ShellMenuDesde(var Menu: TPopupMenu; const Origenes: array of TMenuItem;
      const Iconos: array of string): TPopupMenu;
    procedure ShellMenuConfiguracionClick(Sender: TObject);
    procedure ShellMigrarFicheros(Sender: TObject);
    procedure ShellSeccion(const Nombre: string);
    function ShellSeccionDisponible(const Nombre: string): Boolean;
    function ShellTextoUsuario: string;
  end;

var
  MAIN: TMAIN;
  EsLocalServer: Boolean;
  FilaSel: integer;
  ComboBoxAssociation: TComboBoxFieldAssociation;
  NombrecampoActivo: string;

implementation

uses
  UAparienciaLegacy, UIconos, UDocumentoVistaDatos, UTopografia, UBusquedaDocumentos, UHistory, UAbout, UAutentica, UCapaDatos, UUserGest, UDocManagement,
  UCLSeriesDocumentales, UCLFtpServer, UGestEstruct, UMangementArch,
  UManagementFileSeries, UViewFunciones, UVeditor, UExcelExport, UManagementNode,
  USystemMsg, UNodeProperties, UCL_TiposExp, USysConfig, UTransferencias,
  UExportImportDocumentSubSeries, UManagementIndex, UAdminLog, UManagementTrans,
  UDepuracion, UTopoDocActual, UREditor, UNodeInfo, frmTransferencia, UPrestamos,
  UShellPrincipal;

{$R *.dfm}

var
  Cancel: LongBool;

const
  BaseLineHeight = 24;
// Roles autorizados para consultar o gestionar expedientes
  AuthorizedRoles: array[0..2] of string = ('administrador', 'gestor', 'director');
//  MainFilterNoSource = 'fuente=' + QuotedStr('N');

function ProgressRoutine(TotalFileSize, TotalBytesTransferred, StreamSize, StreamBytesTransferred: Int64; dwStreamNumber, dwCallbackReason, hSourceFile, hDestinationFile: Cardinal; lpData: Pointer): Cardinal; stdcall;
begin
  Application.ProcessMessages;
  if dwCallbackReason = CALLBACK_CHUNK_FINISHED then
  begin
    MAIN.gProcess.Progress := Round(TotalBytesTransferred / TotalFileSize * 100);
    Application.ProcessMessages;
  end;
  Result := PROGRESS_CONTINUE;
end;

const
  LOG_ACCESO_CLASIFICADOR = 14;
  LOG_SALIDA_CLASIFICADOR = 15;
  LOG_ERROR_CLASIFICADOR = 16;

/// <summary>
/// Procedimiento para acceder al clasificador de archivos desde el menú principal.
/// Oculta el contenedor, muestra el formulario de gestión de archivos,
/// y actualiza los datos al cerrar el formulario.
/// </summary>
/// <param name="Sender">Objeto que generó el evento</param>
procedure TMAIN.A1Click(Sender: TObject);
var
  frmManagementArch: TfrmManagemetArch;
  ModalResult: Integer;
begin
  // Validar componentes críticos
  if not Assigned(PContainer) then
  begin
    UDM.sms('Error: PContainer no está asignado.', 1);
    Exit;
  end;

  if not Assigned(UDM) then
  begin
    UDM.sms('Error: UDM no está inicializado.', 1);
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  try
    // Ocultar el contenedor
    PContainer.Visible := False;

    try
      // Registrar el acceso al clasificador
      UDM.log('Accediendo al clasificador de Archivos.', LOG_ACCESO_CLASIFICADOR, '', '', '');

      // Crear y mostrar el formulario de gestión de archivos
      frmManagementArch := TfrmManagemetArch.Create(Self); // Usar Self como propietario para mejor gestión de memoria
      try
        ModalResult := frmManagementArch.ShowModal;
      finally
        frmManagementArch.Free;
      end;

      // Actualizar datos independientemente del resultado modal (a menos que haya una razón específica para no hacerlo)
      if Assigned(UDM.cl_ArchivosGestion) then
      begin
        try
          UDM.cl_ArchivosGestion.DisableControls; // Optimización: deshabilitar controles durante la actualización
          try
            UDM.cl_ArchivosGestion.Refresh;
          finally
            UDM.cl_ArchivosGestion.EnableControls; // Asegurar que los controles se rehabiliten
          end;
        except
          on E: Exception do
          begin
            UDM.log('Error al actualizar datos: ' + E.Message, LOG_ERROR_CLASIFICADOR, '', '', '');
            UDM.sms('Error al actualizar datos: ' + E.Message, 1);
          end;
        end;
      end
      else
        UDM.log('Advertencia: cl_ArchivosGestion no está asignado.', LOG_ERROR_CLASIFICADOR, '', '', '');
    except
      on E: Exception do
      begin
        UDM.log('Error al acceder al clasificador de Archivos: ' + E.Message, LOG_ERROR_CLASIFICADOR, '', '', '');
        UDM.sms('Error: ' + E.Message, 1);
      end;
    end;
  finally
    // Estas operaciones siempre deben ejecutarse, incluso si ocurre una excepción
    PContainer.Visible := True;
    UDM.log('Abandonando el clasificador de Archivos.', LOG_SALIDA_CLASIFICADOR, '', '', '');
    Screen.Cursor := crDefault;
  end;
end;
{procedure TMAIN.A1Click(Sender: TObject);
begin
  PContainer.Visible := False;
  UDM.log('Accediendo al clasificador de Archivos.', 14, '', '', '');
  with TfrmManagemetArch.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
  PContainer.Visible := True;
  UDM.cl_ArchivosGestion.Refresh;
  UDM.log('Abandonando al clasificador de Archivos.', 15, '', '', '');
end; }

procedure TMAIN.Acercade1Click(Sender: TObject);
begin
  with TfrmAbout.Create(nil) do
  try
    //Image1.Visible := True;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.btnaddfileClick(Sender: TObject);
const
  DEFAULT_EXTENSION_ID = 102;
  ROOT_SEPARATOR = '\';
  FTP_SEPARATOR = '/';
var
  FileInfo: TSearchRec;
  FileExtensionId: Integer;
  FileName, FileExtension, BasePath, RootUrl, SourcePath, DestinationPath: string;
  ChildId, FileSize: Integer;
  FileLevel: Integer;
  FileProcessingQuery: TFDQuery;

  function CalculatePathLevel(const FilePath: string; MainLevel: Integer): Integer;
  var
    i, LevelCount: Integer;
    FileName: string;
  begin
    FileName := ExtractFileName(FilePath);
    if (FileName = '.') or (FileName = '..') then
      Exit(-1);

    LevelCount := 0;
    for i := 1 to Length(FilePath) do
      if FilePath[i] = ROOT_SEPARATOR then
        Inc(LevelCount);
    Result := LevelCount - MainLevel;
  end;

  function GetMaximumPathLevel(const FilePath: string): Integer;
  var
    i, LevelCount: Integer;
  begin
    LevelCount := 0;
    for i := 1 to Length(FilePath) do
      if FilePath[i] = ROOT_SEPARATOR then
        Inc(LevelCount);
    Result := LevelCount;
  end;

  function GetRootUrl: string;
  begin
    Result := UDM.UrlRaizNuevos;
  end;

  function BuildStoragePath: string;
  begin
    Result := ROOT_SEPARATOR + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + ROOT_SEPARATOR + UDM.SudSDetail.FieldByName('codserie').AsString + ROOT_SEPARATOR + UDM.SudSDetail.FieldByName('codsubs').AsString + ROOT_SEPARATOR + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + ROOT_SEPARATOR + 'Anexos Digitales' + ROOT_SEPARATOR;
  end;

  function GetNextChildId: Integer;
  const
    DEFAULT_CHILD_ID = 1;
  var
    Query: TFDQuery;
  begin
    Result := DEFAULT_CHILD_ID;
    Query := nil;

    try
      Query := TFDQuery.Create(nil);
      Query.Connection := UDM.Conn;
      if TBD = 'S' then
        Query.SQL.Text := 'SELECT COALESCE(MAX(idhijo), 0) + 1 AS maximosonvalue FROM tb_ssArchdigital'
      else
        Query.SQL.Text := 'SELECT IIf(IsNull(MAX(idhijo)), 0, MAX(idhijo)) + 1 AS maximosonvalue FROM tb_ssArchdigital';
      try
        Query.Open;
        if not Query.IsEmpty then
          Result := Query.Fields[0].AsInteger;
      except
        on E: Exception do
        begin
          //UDM.LogError('GetNextChildId query failed: ' + E.Message);
          Result := DEFAULT_CHILD_ID;
        end;
      end;
    finally
      if Assigned(Query) then
        Query.Free;
    end;
  end;

  function RemoveFileExtension(const Input: string): string;
  var
    i: Integer;
  begin
    Result := '';
    for i := Length(Input) downto 1 do
      if Input[i] = '.' then
        Break
      else
        Result := Input[i] + Result;
    Result := ReverseString(Result);
  end;

  function GetFileNameWithoutExtension(const FileName: string): string;
  var
    BaseName: string;
    ExtPos: Integer;
  begin
  // Extract the base filename (removes path)
    BaseName := ExtractFileName(FileName);
  // Find the last dot to remove the extension
    ExtPos := LastDelimiter('.', BaseName);
    if ExtPos > 0 then
      Result := Copy(BaseName, 1, ExtPos - 1)
    else
      Result := BaseName;
  end;

  procedure ValidateSeriesData;
  begin

    {if Trim(UDM.tb_SeriesDatos.FieldByName('namefile').AsString) = '' then
      raise Exception.Create('No se encontró ningún fichero de subserie documental en la fecha señalada.');}
  end;

  procedure SaveFileToDatabase;
  begin
    UDM.tb_ssArchdigital.Append;
    try
      UDM.tb_ssArchdigital.FieldByName('idestructura').AsString := UDM.tb_SeriesDatos.FieldByName('idestructura').AsString;
      UDM.tb_ssArchdigital.FieldByName('id').AsInteger := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
      UDM.tb_ssArchdigital.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
      UDM.tb_ssArchdigital.FieldByName('fecha').AsDateTime := UDM.tb_SeriesDatos.FieldByName('fecha').AsDateTime;
      UDM.tb_ssArchdigital.FieldByName('version').AsString := UDM.tb_SeriesDatos.FieldByName('version').AsString;
      UDM.tb_ssArchdigital.FieldByName('Codigodoc').AsString := UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
      UDM.tb_ssArchdigital.FieldByName('idhijo').AsInteger := ChildId;
      UDM.tb_ssArchdigital.FieldByName('nombre').AsString := FileName;
      UDM.tb_ssArchdigital.FieldByName('ext').AsInteger := FileExtensionId;
      UDM.tb_ssArchdigital.FieldByName('extnombre').AsString := FileExtension;
      UDM.tb_ssArchdigital.FieldByName('comentario').Value := Null;
      UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString := RootUrl;
      UDM.tb_ssArchdigital.FieldByName('path').AsString := BasePath;
      UDM.tb_ssArchdigital.FieldByName('tamano').AsInteger := FileSize;
      UDM.tb_ssArchdigital.FieldByName('padre').AsInteger := 0;
      UDM.tb_ssArchdigital.FieldByName('Nivel').AsInteger := 0;
      UDM.tb_ssArchdigital.FieldByName('fuente').AsString := 'N';
      UDM.tb_ssArchdigital.FieldByName('Etiqueta').AsString := GetFileNameWithoutExtension(FileName);
      UDM.tb_ssArchdigital.Post;
    except
      UDM.tb_ssArchdigital.Cancel;
      raise;
    end;
  end;

  procedure TransferFileToServer;
  begin
    DestinationPath := AnsiReplaceStr(RootUrl + BasePath + FileName, ROOT_SEPARATOR, FTP_SEPARATOR);
    DestinationPath := AnsiReplaceStr(DestinationPath, FTP_SEPARATOR + FTP_SEPARATOR, FTP_SEPARATOR);
    SourcePath := pathtemp + FileName;

    CopyFile(PWideChar(ODArchDig.FileName), PWideChar(SourcePath), True);
    try
      UDM.CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, SourcePath, DestinationPath, 'A', UDM.cmdServer.FieldByName('puerto').AsInteger);
    finally
      DeleteFile(SourcePath);
    end;
  end;

  procedure RefreshDataViews;
  begin
    UDM.tb_ssArchdigital.DisableControls;
    try
      UDM.qryAnexosDig.Active := False;
      UDM.qryAnexosDig.Active := True;
      UDM.qryFuentesDig.Active := False;
      UDM.qryFuentesDig.Active := True;
      UDM.tb_ssArchdigital.FetchAll;
    finally
      UDM.tb_ssArchdigital.EnableControls;
    end;
  end;

begin
  try
    cxgrid5.Visible := True;
    if UDM.tb_SeriesDatos.RecordCount = 0 then begin
      raise Exception.Create('No se encontró ningún fichero de subserie documental en la fecha señalada.');
      exit;
    end;

    if not ODArchDig.Execute or (Trim(ODArchDig.FileName) = '') then
      Exit;

    FileName := ExtractFileName(ODArchDig.FileName);
    FileExtension := ExtractFileExt(ODArchDig.FileName);
    FileLevel := CalculatePathLevel(ODArchDig.FileName, 0);
    BasePath := BuildStoragePath;
    RootUrl := GetRootUrl;
    ChildId := GetNextChildId;
    FileSize := TamFichero(ODArchDig.FileName);

    if UDM.tb_ext.Locate('ext', AnsiLowerCase(FileExtension), []) then
      FileExtensionId := UDM.tb_ext.FieldByName('id').AsInteger - 1
    else
      FileExtensionId := DEFAULT_EXTENSION_ID;
    SaveFileToDatabase;
    TransferFileToServer;
    RefreshDataViews;
    UDM.sms('El fichero se agregó satisfactoriamente', 3);
  except
    on E: EFDException do
      UDM.sms('No se pudo agregar el fichero seleccionado al archivo digital actual. Motivo: ' + E.Message, 1);
    on E: Exception do
      UDM.sms('Error al procesar el fichero: ' + E.Message, 1);
  end;
  ReactiveAnexos;
end;

{procedure TMAIN.btnaddfileClick(Sender: TObject);
var
  sr: TSearchRec;
  i, j, ext: integer;
  nombre, extension, carpetaorg: string;
  padre: integer;
  idpadreA, idhijo: integer;
  VV: Variant;
  LevelAnt: integer;
//VARIABLES NUEVAS PARA METODO NUEVO...
  LongMLevel: Integer;
  MainLevel: Integer;
  CAD: string;
  level, GObjP: integer;
  GPath, GURL: string;
  SQLQ, Origen, Destino: string;

  function GetLevel(Path: string): Integer;
  var
    i, cont: integer;
    fn: string;
  begin
    fn := ExtractFileName(Path);
    if (fn = '.') or (fn = '..') then
    begin
      result := -1;
      Exit;
    end;
    cont := 0;
    for i := 1 to Length(Path) do
      if Path[i] = '\' then
        inc(cont);
    Result := cont - MainLevel;
  end;

  function getMLevel(Path: string): Integer;
  var
    i, cont: integer;
  begin
    cont := 0;
    LongMLevel := 0;
    for i := 1 to Length(Path) do
    begin
      if Path[i] = '\' then
        inc(cont);
      Inc(LongMLevel);
    end;
    Result := cont;
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.UrlRaizNuevos; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Anexos Digitales\';
  end;

  function MaxIdHijo: Integer;
  begin
    Result := 1;
    with TFDQuery.Create(nil) do
    try
      Active := False;
      Connection := UDM.Conn;
      SQL.Clear;
      SQL.Add('select Max(idhijo)as maximosonvalue from tb_ssArchdigital');
      try
        Active := True;
        if (Fields[0].Value <> null) and (trim(Fields[0].AsString) <> '') then
          Result := Fields[0].AsInteger + 1;
      except
      end;
    finally
      Free;
    end;
  end;

  function removeext(cad1: string): string;
  var
    i: integer;
    flag: Boolean;
  begin
    flag := False;
    Result := '';
    for i := length(cad1) - 1 downto 1 do
    begin
      if flag then
        result := cad1[i] + result;
      if cad1[i] <> '.' then

      else
        flag := True;
    end;
  end;

begin
  if UDM.tb_SeriesDatos.RecordCount = 0 then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 1);
    Exit;
  end;
//  UDM.CompletaNombreFile;
  if trim(UDM.tb_SeriesDatos.FieldByName('namefile').AsString) = '' then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 1);
    Exit;
  end;
  if ODArchDig.Execute then
    if Trim(ODArchDig.FileName) <> '' then
    begin
      level := GetLevel(ODArchDig.FileName);
      GPath := GetPath;
      GURL := GetURLRaiz;
      idhijo := MaxIdHijo;
      extension := ExtractFileExt(ODArchDig.FileName);
      if UDM.tb_ext.Locate('ext', AnsiLowerCase(extension), []) then
        ext := UDM.tb_ext.FieldByName('id').AsInteger - 1
      else
        ext := 102;
      UDM.tb_ssArchdigital.Append;
      UDM.tb_ssArchdigital.FieldByName('idestructura').AsString := UDM.tb_SeriesDatos.FieldByName('idestructura').AsString;
      UDM.tb_ssArchdigital.FieldByName('id').AsInteger := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
      UDM.tb_ssArchdigital.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
      UDM.tb_ssArchdigital.FieldByName('fecha').AsDateTime := UDM.tb_SeriesDatos.FieldByName('fecha').AsDateTime;
      UDM.tb_ssArchdigital.FieldByName('version').AsString := UDM.tb_SeriesDatos.FieldByName('version').AsString;
      UDM.tb_ssArchdigital.FieldByName('Codigodoc').AsString := UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
      UDM.tb_ssArchdigital.FieldByName('idhijo').AsInteger := idhijo;
      UDM.tb_ssArchdigital.FieldByName('nombre').AsString := ExtractFileName(ODArchDig.FileName); //UDM.tb_SeriesDatos.FieldByName('namefile').AsString;
      UDM.tb_ssArchdigital.FieldByName('ext').AsInteger := ext;
      UDM.tb_ssArchdigital.FieldByName('extnombre').AsString := extension;
      UDM.tb_ssArchdigital.FieldByName('comentario').Value := Null;
      UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString := GURL;
      UDM.tb_ssArchdigital.FieldByName('path').AsString := GPath;
      UDM.tb_ssArchdigital.FieldByName('tamano').AsInteger := TamFichero(ODArchDig.FileName);
      UDM.tb_ssArchdigital.FieldByName('padre').AsInteger := 0;
      UDM.tb_ssArchdigital.FieldByName('Nivel').AsInteger := 0;
      UDM.tb_ssArchdigital.FieldByName('fuente').AsString := 'N';
      UDM.tb_ssArchdigital.FieldByName('Etiqueta').AsString := removeext(ExtractFileName(ODArchDig.FileName));
      try
        PathSaveBinaryFile := GURL + GPath + ExtractFileName(ODArchDig.FileName);
        PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '\', '/');
        PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '//', '/');
        Destino := PathSaveBinaryFile;
        CopyFile(pwidechar(ODArchDig.FileName), pwidechar(pathtemp + ExtractFileName(ODArchDig.FileName)), true);
        Origen := pathtemp + ExtractFileName(ODArchDig.FileName);
//        Origen := ODArchDig.FileName;
        udm.CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, Origen, Destino, 'A', UDM.cmdServer.FieldByName('puerto').AsInteger);
        UDM.tb_ssArchdigital.Post;
        DeleteFile(Origen);
        UDM.tb_ssArchdigital.DisableControls;
        UDM.qryAnexosDig.Active := False;
        UDM.qryAnexosDig.Active := True;
        UDM.qryFuentesDig.Active := False;
        UDM.qryFuentesDig.Active := True;
        UDM.tb_ssArchdigital.FetchAll;
        UDM.tb_ssArchdigital.EnableControls;
        UDM.sms('El fichero se agregó satisfactoriamente', 3);
      except
        on E: EFDException do
        begin
          udm.sms('No se pudo agregar el fichero seleccionado al archivo digital actual. Motivo: ' + E.Message, 1);
          UDM.tb_ssArchdigital.Cancel;
        end;
      end;
    end;
  ReactiveAnexos;
end; }

procedure TMAIN.btnaddfilelistClick(Sender: TObject);
var
  sr: TSearchRec;
  i, j, inventario, ext: integer;
  nombre, extension, carpetaorg: string;
  padre: integer;
  idpadreA, idhijo: integer;
  VV: Variant;
  LevelAnt: integer;
//VARIABLES NUEVAS PARA METODO NUEVO...
  LongMLevel: Integer;
  MainLevel: Integer;
  CAD: string;
  cantidaddeficheros: integer;

  procedure contarficheros(Dir: string);
  var
    FileSearch: TSearchRec;
  begin
    ChDir(Dir);
    if FindFirst('*.*', faDirectory, FileSearch) = 0 then
      repeat
        if ((FileSearch.Attr and fadirectory) = fadirectory) then
        begin
          if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
            contarficheros(Dir + '\' + FileSearch.Name);
        end
        else
        begin
         {Pon aqui lo que quieras hacer con los ficheros encontrados}
         {Put here anything to make with the find files}
          cantidaddeficheros := cantidaddeficheros + 1;
         //Memo1.Lines.Add( Dir +'\'+FileSearch.Name );
        end;
      until FindNext(FileSearch) <> 0;
    FindClose(FileSearch);
  end;

  function GetLevel(Path: string): Integer;
  var
    i, cont: integer;
    fn: string;
  begin
    fn := ExtractFileName(Path);
    if (fn = '.') or (fn = '..') then
    begin
      result := -1;
      Exit;
    end;
    cont := 0;
    for i := 1 to Length(Path) do
      if Path[i] = '\' then
        inc(cont);
    Result := cont - MainLevel;
  end;

  function getMLevel(Path: string): Integer;
  var
    i, cont: integer;
  begin
    cont := 0;
    LongMLevel := 0;
    for i := 1 to Length(Path) do
    begin
      if Path[i] = '\' then
        inc(cont);
      Inc(LongMLevel);
    end;
    Result := cont;
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.UrlRaizNuevos; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Anexos Digitales\';
  end;

  function MaxIdHijo: Integer;
  var
    tmp: Integer;
  begin
    Result := 0;
    with TFDQuery.Create(nil) do
    try
      Active := False;
      Connection := UDM.Conn;
      SQL.Clear;
      SQL.Add('select Max(idhijo)as maximosonvalue from tb_ssArchdigital');
      try
        Active := True;
        if (Fields[0].Value <> null) and (trim(Fields[0].AsString) <> '') then
          Result := Fields[0].AsInteger + 1;
      except
      end;
    finally
      Free;
    end;
  end;

  function removeext(cad1: string): string;
  var
    i: integer;
    flag: Boolean;
  begin
    flag := False;
    Result := '';
    for i := length(cad1) - 1 downto 1 do
    begin
      if flag then
        result := cad1[i] + result;
      if cad1[i] <> '.' then

      else
        flag := True;
    end;
  end;

  procedure RastreaDir(Dir: string; papa: integer);
  var
    FileSearch: TSearchRec;
    level, GObjP: integer;
    GPath, GURL: string;
    SQLQ, Origen, Destino: string;
  begin
    try
      ChDir(Dir);
      if FindFirst('*.*', faDirectory, FileSearch) = 0 then
        repeat
          Application.ProcessMessages;
          try
            SetFileAttributes(PChar(Dir + FileSearch.Name), FILE_ATTRIBUTE_NORMAL);
            Update;
          except
          end;

          if ((FileSearch.Attr and faDirectory) = FileSearch.Attr) or (FileSearch.Attr = 48) then
          begin
            if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
            begin
              level := GetLevel(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'));
              GPath := GetPath;
              GURL := GetURLRaiz;
              Inc(idhijo);
              {SQLQ := 'INSERT INTO tb_ssArchdigital(idestructura, id, codsubs, fecha, version, Codigodoc, idhijo, nombre, ext, extnombre, comentario, urlraiz, path, tamano, padre, nivel, fuente, etiqueta) VALUES(';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('IdEstructura').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('id').AsString + ', ';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('codsubs').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('Fecha').AsString + ', ';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Version').AsString) + ', ' + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Codigodoc').AsString) + ', ' + IntToStr(idhijo) + ', ' + QuotedStr(FileSearch.NAME) + ', 104, ';
              SQLQ := SQLQ + QuotedStr('DIR') + ', null, ' + QuotedStr(GURL) + ', ' + QuotedStr(GPath) + ', ' + IntToStr(FileSearch.SIZE) + ', ' + IntToStr(papa) + ', ' + IntToStr(level) + ')';
              UDM.CMDScript.SQLScripts[0].SQL.Add(SQLQ + ';');   }
              {UDM.tb_ssArchdigital.Append;
              UDM.tb_ssArchdigital.FieldByName('idestructura').AsString := UDM.tb_SeriesDatos.FieldByName('idestructura').AsString;
              UDM.tb_ssArchdigital.FieldByName('id').AsInteger := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
              UDM.tb_ssArchdigital.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
              UDM.tb_ssArchdigital.FieldByName('fecha').AsDateTime := UDM.tb_SeriesDatos.FieldByName('fecha').AsDateTime;
              UDM.tb_ssArchdigital.FieldByName('version').AsString := UDM.tb_SeriesDatos.FieldByName('version').AsString;
              UDM.tb_ssArchdigital.FieldByName('Codigodoc').AsString := UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
              UDM.tb_ssArchdigital.FieldByName('idhijo').AsInteger := idhijo;
              UDM.tb_ssArchdigital.FieldByName('nombre').AsString := FileSearch.NAME; //UDM.tb_SeriesDatos.FieldByName('namefile').AsString;
              UDM.tb_ssArchdigital.FieldByName('ext').AsInteger := ext;
              UDM.tb_ssArchdigital.FieldByName('extnombre').AsString := extension;
              UDM.tb_ssArchdigital.FieldByName('comentario').Value := Null;
              UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString := GURL;
              UDM.tb_ssArchdigital.FieldByName('path').AsString := GPath;
              UDM.tb_ssArchdigital.FieldByName('tamano').AsInteger := FileSearch.SIZE;
              UDM.tb_ssArchdigital.FieldByName('padre').AsInteger := 0;
              UDM.tb_ssArchdigital.FieldByName('Nivel').AsInteger := 0;
              UDM.tb_ssArchdigital.FieldByName('fuente').AsString := 'N';
              UDM.tb_ssArchdigital.FieldByName('Etiqueta').AsString := removeext(FileSearch.NAME);
              try
                UDM.tb_ssArchdigital.Post;
              except
                UDM.tb_ssArchdigital.Cancel;
              end;
              if FileSearch.Size > 0 then
              begin
                gProcess.Progress := gProcess.Progress + 1;
                Application.ProcessMessages;
              end; }
              RastreaDir(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'), idhijo);
            end;
          end
          else if FileSearch.Attr = 1048592 then
          begin
            if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
              RastreaDir(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'), idhijo);
          end
          else
          begin
            extension := ExtractFileExt(FileSearch.Name);
            if trim(extension) <> '' then
              if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
              begin
                level := GetLevel(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'));
                GPath := GetPath;
                GURL := GetURLRaiz;
                inc(idhijo);
                extension := ExtractFileExt(FileSearch.Name);
                if UDM.tb_ext.Locate('ext', AnsiLowerCase(extension), []) then
                  ext := UDM.tb_ext.FieldByName('id').AsInteger - 1
                else
                  ext := 102;
            {SQLQ := 'INSERT INTO tb_ssArchdigital(idestructura, id, codsubs, fecha, version, Codigodoc, idhijo, nombre, ext, extnombre, comentario, urlraiz, path, tamano, padre, nivel, fuente, etiqueta) VALUES(';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('IdEstructura').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('id').AsString + ', ';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('codsubs').AsString) + ', CONVERT(varchar, ' + UDM.tb_SeriesDatos.FieldByname('Fecha').AsString + ', 103), ';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Version').AsString) + ', ' + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Codigodoc').AsString) + ', ' + IntToStr(idhijo) + ', ' + QuotedStr(FileSearch.NAME) + ', ' + inttostr(ext) + ', ';
            SQLQ := SQLQ + QuotedStr(extension) + ', null, ' + QuotedStr(GURL) + ', ' + QuotedStr(GPath) + ', ' + IntToStr(FileSearch.SIZE) + ', ';
            SQLQ := SQLQ + IntToStr(papa) + ', ' + IntToStr(level) + ', ' + QuotedStr('N') + ', ' + QuotedStr(removeext(FileSearch.NAME)) + ')';   }
                UDM.tb_ssArchdigital.Append;
                UDM.tb_ssArchdigital.FieldByName('idestructura').AsString := UDM.tb_SeriesDatos.FieldByName('idestructura').AsString;
                UDM.tb_ssArchdigital.FieldByName('id').AsInteger := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
                UDM.tb_ssArchdigital.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
                UDM.tb_ssArchdigital.FieldByName('fecha').AsDateTime := UDM.tb_SeriesDatos.FieldByName('fecha').AsDateTime;
                UDM.tb_ssArchdigital.FieldByName('version').AsString := UDM.tb_SeriesDatos.FieldByName('version').AsString;
                UDM.tb_ssArchdigital.FieldByName('Codigodoc').AsString := UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
                UDM.tb_ssArchdigital.FieldByName('idhijo').AsInteger := idhijo;
                UDM.tb_ssArchdigital.FieldByName('nombre').AsString := FileSearch.NAME; //UDM.tb_SeriesDatos.FieldByName('namefile').AsString;
                UDM.tb_ssArchdigital.FieldByName('ext').AsInteger := ext;
                UDM.tb_ssArchdigital.FieldByName('extnombre').AsString := extension;
                UDM.tb_ssArchdigital.FieldByName('comentario').Value := Null;
                UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString := GURL;
                UDM.tb_ssArchdigital.FieldByName('path').AsString := GPath;
                UDM.tb_ssArchdigital.FieldByName('tamano').AsInteger := FileSearch.SIZE;
                UDM.tb_ssArchdigital.FieldByName('padre').AsInteger := 0;
                UDM.tb_ssArchdigital.FieldByName('Nivel').AsInteger := 0;
                UDM.tb_ssArchdigital.FieldByName('fuente').AsString := 'N';
                UDM.tb_ssArchdigital.FieldByName('Etiqueta').AsString := removeext(FileSearch.NAME);
                try
                  UDM.tb_ssArchdigital.Post;
                except
                  UDM.tb_ssArchdigital.Cancel;
                end;
                PathSaveBinaryFile := GURL + GPath + FileSearch.Name;
                PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '\', '/');
                PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '//', '/');
                Destino := PathSaveBinaryFile;
                CopyFile(pwidechar(Dir + '\' + FileSearch.Name), pwidechar(pathtemp + FileSearch.Name), true);
                Origen := pathtemp + FileSearch.Name;
                udm.CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, Origen, Destino, 'A', UDM.cmdServer.FieldByName('puerto').AsInteger);
                gProcess.Progress := gProcess.Progress + 1;
                DeleteFile(pathtemp + FileSearch.Name);
                Application.ProcessMessages;
            {
            PathSaveBinaryFile := AnsiReplaceStr(GURL + GPath + FileSearch.Name, '\\', '\');
            ForceDirectories(ExtractFilePath(PathSaveBinaryFile));
            Destino := PathSaveBinaryFile;
            Origen := Dir + '\' + FileSearch.Name;
            CopyFileEx(pchar(Origen), pchar(Destino), nil, nil, nil, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);}
//            UDM.CMDScript.SQLScripts[0].SQL.Add(SQLQ + ';');
              end;
          end;
        until FindNext(FileSearch) <> 0;
      FindClose(FileSearch);
    except
    end;

  end;

begin
  if UDM.tb_SeriesDatos.RecordCount = 0 then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 1);
    Exit;
  end;
 // UDM.CompletaNombreFile;
  if trim(UDM.tb_SeriesDatos.FieldByName('namefile').AsString) = '' then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 1);
    Exit;
  end;
  if (UDM.tb_SeriesDatos.State = dsInsert) or (UDM.tb_SeriesDatos.State = dsedit) then
    UDM.tb_SeriesDatos.Post;
  {if trim(UDM.SudSDetail.FieldByName('carpeta').AsString) = '' then
  begin
    UDM.sms('No ha especificado una carpeta raíz válida para almacenar el fichero especificado.', 1);
    Exit;
  end;
  if EsLocalServer then
    SD.InitialDir := UDM.tb_Serietree.FieldByName('carpeta').AsString;}
  if SD.Execute then
    if trim(SD.Directory) <> '' then
    begin
      Screen.Cursor := crSQLWait;
      try
        if not UDM.tb_ext.Active then
          UDM.tb_ext.Active := True;
        LevelAnt := 0;
        sbAD.Panels[0].Text := 'Archivo Digital';
        sbAD.Refresh;
        UDM.tb_SeriesDatos.DisableControls;
        {UDM.CMDScript.SQLScripts.CLEAR;
        UDM.CMDScript.SQLScripts.add; }
        idhijo := MaxIdHijo;
        cantidaddeficheros := 0;
        contarficheros(SD.Directory);
        cpProgress.Visible := True;
        Application.ProcessMessages;
        gProcess.MinValue := 0;
        gProcess.Progress := 0;
        gProcess.MaxValue := cantidaddeficheros;
//        ChangeAttributes(SD.Directory);
        CAD := QuotedStr(AnsiQuotedStr(SD.Directory, '"'));
        UDM.RunAndWaitShell(PathSys + 'cmdChangeAttr.exe', CAD, SW_HIDE);
        RastreaDir(SD.Directory, 0);
        cpProgress.Visible := False;
        UDM.tb_ssArchdigital.Active := False;
        UDM.tb_ssArchdigital.Active := True;
        UDM.tb_ssArchdigital.FetchAll;
        UDM.tb_SeriesDatos.EnableControls;
      finally
        Screen.Cursor := crDefault;
      end;
    end;
  ReactiveAnexos;

end;

procedure TMAIN.btnAddListSourceClick(Sender: TObject);
var
  sr: TSearchRec;
  i, j, inventario, ext: integer;
  nombre, extension, carpetaorg: string;
  padre: integer;
  idpadreA, idhijo: integer;
  VV: Variant;
  LevelAnt: integer;
//VARIABLES NUEVAS PARA METODO NUEVO...
  LongMLevel: Integer;
  MainLevel: Integer;
  CAD: string;
  cantidaddeficheros: integer;

  procedure contarficheros(Dir: string);
  var
    FileSearch: TSearchRec;
  begin
    ChDir(Dir);
    if FindFirst('*.*', faDirectory, FileSearch) = 0 then
      repeat
        if ((FileSearch.Attr and fadirectory) = fadirectory) then
        begin
          if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
            contarficheros(Dir + '\' + FileSearch.Name);
        end
        else
        begin
         {Pon aqui lo que quieras hacer con los ficheros encontrados}
         {Put here anything to make with the find files}
          cantidaddeficheros := cantidaddeficheros + 1;
         //Memo1.Lines.Add( Dir +'\'+FileSearch.Name );
        end;
      until FindNext(FileSearch) <> 0;
    FindClose(FileSearch);
  end;

  function GetLevel(Path: string): Integer;
  var
    i, cont: integer;
    fn: string;
  begin
    fn := ExtractFileName(Path);
    if (fn = '.') or (fn = '..') then
    begin
      result := -1;
      Exit;
    end;
    cont := 0;
    for i := 1 to Length(Path) do
      if Path[i] = '\' then
        inc(cont);
    Result := cont - MainLevel;
  end;

  function getMLevel(Path: string): Integer;
  var
    i, cont: integer;
  begin
    cont := 0;
    LongMLevel := 0;
    for i := 1 to Length(Path) do
    begin
      if Path[i] = '\' then
        inc(cont);
      Inc(LongMLevel);
    end;
    Result := cont;
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.UrlRaizNuevos;
  end;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Fuentes\';
  end;

  function MaxIdHijo: Integer;
  var
    tmp: Integer;
  begin
    Result := 0;
    with TFDQuery.Create(nil) do
    try
      Active := False;
      Connection := UDM.Conn;
      SQL.Clear;
      SQL.Add('select Max(idhijo)as maximosonvalue from tb_ssArchdigital');
      try
        Active := True;
        if (Fields[0].Value <> null) and (trim(Fields[0].AsString) <> '') then
          Result := Fields[0].AsInteger + 1;
      except
      end;
    finally
      Free;
    end;
  end;

  function removeext(cad1: string): string;
  var
    i: integer;
    flag: Boolean;
  begin
    flag := False;
    Result := '';
    for i := length(cad1) - 1 downto 1 do
    begin
      if flag then
        result := cad1[i] + result;
      if cad1[i] <> '.' then

      else
        flag := True;
    end;
  end;

  procedure RastreaDir(Dir: string; papa: integer);
  var
    FileSearch: TSearchRec;
    level, GObjP: integer;
    GPath, GURL: string;
    SQLQ, Origen, Destino: string;
  begin
    try
      ChDir(Dir);
      if FindFirst('*.*', faDirectory, FileSearch) = 0 then
        repeat
          Application.ProcessMessages;
          try
            SetFileAttributes(PChar(Dir + FileSearch.Name), FILE_ATTRIBUTE_NORMAL);
            Update;
          except
          end;
          if ((FileSearch.Attr and faDirectory) = FileSearch.Attr) or (FileSearch.Attr = 48) then
          begin
            if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
            begin
              level := GetLevel(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'));
              GPath := GetPath;
              GURL := GetURLRaiz;
              Inc(idhijo);
              {QLQ := 'INSERT INTO tb_ssArchdigital(idestructura, id, codsubs, fecha, version, Codigodoc, idhijo, nombre, ext, extnombre, comentario, urlraiz, path, tamano, padre, nivel, fuente, etiqueta) VALUES(';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('IdEstructura').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('id').AsString + ', ';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('codsubs').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('Fecha').AsString + ', ';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Version').AsString) + ', ' + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Codigodoc').AsString) + ', ' + IntToStr(idhijo) + ', ' + QuotedStr(FileSearch.NAME) + ', 104, ';
              SQLQ := SQLQ + QuotedStr('DIR') + ', null, ' + QuotedStr(GURL) + ', ' + QuotedStr(GPath) + ', ' + IntToStr(FileSearch.SIZE) + ', ' + IntToStr(papa) + ', ' + IntToStr(level) + ')';
              UDM.CMDScript.SQLScripts[0].SQL.Add(SQLQ + ';');   +}
              {UDM.tb_ssArchdigital.Append;
              UDM.tb_ssArchdigital.FieldByName('idestructura').AsString := UDM.tb_SeriesDatos.FieldByName('idestructura').AsString;
              UDM.tb_ssArchdigital.FieldByName('id').AsInteger := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
              UDM.tb_ssArchdigital.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
              UDM.tb_ssArchdigital.FieldByName('fecha').AsDateTime := UDM.tb_SeriesDatos.FieldByName('fecha').AsDateTime;
              UDM.tb_ssArchdigital.FieldByName('version').AsString := UDM.tb_SeriesDatos.FieldByName('version').AsString;
              UDM.tb_ssArchdigital.FieldByName('Codigodoc').AsString := UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
              UDM.tb_ssArchdigital.FieldByName('idhijo').AsInteger := idhijo;
              UDM.tb_ssArchdigital.FieldByName('nombre').AsString := FileSearch.NAME; //UDM.tb_SeriesDatos.FieldByName('namefile').AsString;
              UDM.tb_ssArchdigital.FieldByName('ext').AsInteger := ext;
              UDM.tb_ssArchdigital.FieldByName('extnombre').AsString := extension;
              UDM.tb_ssArchdigital.FieldByName('comentario').Value := Null;
              UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString := GURL;
              UDM.tb_ssArchdigital.FieldByName('path').AsString := GPath;
              UDM.tb_ssArchdigital.FieldByName('tamano').AsInteger := FileSearch.SIZE;
              UDM.tb_ssArchdigital.FieldByName('padre').AsInteger := 0;
              UDM.tb_ssArchdigital.FieldByName('Nivel').AsInteger := 0;
              UDM.tb_ssArchdigital.FieldByName('fuente').AsString := 'S';
              UDM.tb_ssArchdigital.FieldByName('Etiqueta').AsString := removeext(FileSearch.NAME);
              try
                UDM.tb_ssArchdigital.Post;
              except
                UDM.tb_ssArchdigital.Cancel;
              end;
              if FileSearch.Size > 0 then
              begin
                gProcess.Progress := gProcess.Progress + 1;
                Application.ProcessMessages;
              end;     }
              RastreaDir(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'), idhijo);
            end;
          end
          else if FileSearch.Attr = 1048592 then
          begin
            if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
              RastreaDir(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'), idhijo);
          end
          else
          begin
            if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
            begin
              level := GetLevel(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'));
              GPath := GetPath;
              GURL := GetURLRaiz;
              inc(idhijo);
              extension := ExtractFileExt(FileSearch.Name);
              if UDM.tb_ext.Locate('ext', AnsiLowerCase(extension), []) then
                ext := UDM.tb_ext.FieldByName('id').AsInteger - 1
              else
                ext := 102;
            {SQLQ := 'INSERT INTO tb_ssArchdigital(idestructura, id, codsubs, fecha, version, Codigodoc, idhijo, nombre, ext, extnombre, comentario, urlraiz, path, tamano, padre, nivel, fuente, etiqueta) VALUES(';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('IdEstructura').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('id').AsString + ', ';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('codsubs').AsString) + ', :ff, ';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Version').AsString) + ', ' + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Codigodoc').AsString) + ', ' + IntToStr(idhijo) + ', ' + QuotedStr(FileSearch.NAME) + ', ' + inttostr(ext) + ', ';
            SQLQ := SQLQ + QuotedStr(extension) + ', null, ' + QuotedStr(GURL) + ', ' + QuotedStr(GPath) + ', ' + IntToStr(FileSearch.SIZE) + ', ';
            SQLQ := SQLQ + IntToStr(papa) + ', ' + IntToStr(level) + ', ' + QuotedStr('S') + ', ' + QuotedStr(removeext(FileSearch.NAME)) + ')'; }
              UDM.tb_ssArchdigital.Append;
              UDM.tb_ssArchdigital.FieldByName('idestructura').AsString := UDM.tb_SeriesDatos.FieldByName('idestructura').AsString;
              UDM.tb_ssArchdigital.FieldByName('id').AsInteger := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
              UDM.tb_ssArchdigital.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
              UDM.tb_ssArchdigital.FieldByName('fecha').AsDateTime := UDM.tb_SeriesDatos.FieldByName('fecha').AsDateTime;
              UDM.tb_ssArchdigital.FieldByName('version').AsString := UDM.tb_SeriesDatos.FieldByName('version').AsString;
              UDM.tb_ssArchdigital.FieldByName('Codigodoc').AsString := UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
              UDM.tb_ssArchdigital.FieldByName('idhijo').AsInteger := idhijo;
              UDM.tb_ssArchdigital.FieldByName('nombre').AsString := FileSearch.NAME; //UDM.tb_SeriesDatos.FieldByName('namefile').AsString;
              UDM.tb_ssArchdigital.FieldByName('ext').AsInteger := ext;
              UDM.tb_ssArchdigital.FieldByName('extnombre').AsString := extension;
              UDM.tb_ssArchdigital.FieldByName('comentario').Value := Null;
              UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString := GURL;
              UDM.tb_ssArchdigital.FieldByName('path').AsString := GPath;
              UDM.tb_ssArchdigital.FieldByName('tamano').AsInteger := FileSearch.SIZE;
              UDM.tb_ssArchdigital.FieldByName('padre').AsInteger := 0;
              UDM.tb_ssArchdigital.FieldByName('Nivel').AsInteger := 0;
              UDM.tb_ssArchdigital.FieldByName('fuente').AsString := 'S';
              UDM.tb_ssArchdigital.FieldByName('Etiqueta').AsString := removeext(FileSearch.NAME);
              try
                UDM.tb_ssArchdigital.Post;
              except
                UDM.tb_ssArchdigital.Cancel;
              end;
              PathSaveBinaryFile := GURL + GPath + FileSearch.Name;
              PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '\', '/');
              PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '//', '/');
              Destino := PathSaveBinaryFile;
              CopyFile(pwidechar(Dir + '\' + FileSearch.Name), pwidechar(pathtemp + FileSearch.Name), true);
              Origen := pathtemp + FileSearch.Name;
//              Origen := Dir + '\' + FileSearch.Name;
              udm.CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, Origen, Destino, 'F', UDM.cmdServer.FieldByName('puerto').AsInteger);
              gProcess.Progress := gProcess.Progress + 1;
              Application.ProcessMessages;
              DeleteFile(pathtemp + FileSearch.Name);
           { PathSaveBinaryFile := GURL + GPath + FileSearch.Name;
            ForceDirectories(ExtractFilePath(PathSaveBinaryFile));
            Destino := PathSaveBinaryFile;
            Origen := Dir + '\' + FileSearch.Name;
            cpProgress.Visible := True;
            //CopyFileEx(pchar(Origen), pchar(Destino), @ProgressRoutine, nil, @Cancel, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);
            CopyFileEx(pchar(Origen), pchar(Destino), @ProgressRoutine, nil, @Cancel, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);
                  }
           // UDM.CMDScript.SQLScripts[0].SQL.Add(SQLQ + ';');
            end;
          end;
        until FindNext(FileSearch) <> 0;
      FindClose(FileSearch);
    except
    end;

  end;

begin
  if UDM.tb_SeriesDatos.RecordCount = 0 then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 1);
    Exit;
  end;
  //UDM.CompletaNombreFile;
  if trim(UDM.tb_SeriesDatos.FieldByName('namefile').AsString) = '' then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 1);
    Exit;
  end;
  if (UDM.tb_SeriesDatos.State = dsInsert) or (UDM.tb_SeriesDatos.State = dsedit) then
    UDM.tb_SeriesDatos.Post;
  if SD.Execute then
    if trim(SD.Directory) <> '' then
    begin
      if not UDM.tb_ext.Active then
        UDM.tb_ext.Active := True;
      Screen.Cursor := crSQLWait;
      LevelAnt := 0;
      sbAD.Panels[0].Text := 'Ficheros Fuente';
      sbAD.Refresh;
      UDM.tb_SeriesDatos.DisableControls;
      {UDM.CMDScript.SQLScripts.CLEAR;
      UDM.CMDScript.SQLScripts.add; }
      idhijo := MaxIdHijo;
      cantidaddeficheros := 0;
      contarficheros(SD.Directory);
      cpProgress.Visible := True;
      Application.ProcessMessages;
      gProcess.MinValue := 0;
      gProcess.Progress := 0;
      gProcess.MaxValue := cantidaddeficheros;
      CAD := QuotedStr(AnsiQuotedStr(SD.Directory, '"'));
      UDM.RunAndWaitShell(PathSys + 'cmdChangeAttr.exe', CAD, SW_HIDE);
      RastreaDir(SD.Directory, 0);
      cpProgress.Visible := False;
     { UDM.CMDScript.Params[0].Value := UDM.tb_SeriesDatos.FieldByname('Fecha').Value;
      try
        UDM.CMDScript.ValidateAll;
        UDM.CMDScript.ExecuteAll;
      except
      end;
      cpProgress.Visible := False; }
      UDM.tb_ssArchdigital.Active := False;
      UDM.tb_ssArchdigital.Active := True;
      UDM.tb_ssArchdigital.FetchAll;
      UDM.tb_SeriesDatos.EnableControls;
      Screen.Cursor := crDefault;
    end;
  ReactiveAnexos;
end;

procedure TMAIN.btnAdjustClick(Sender: TObject);
begin
  if cxGrid1DBTableView1.DataController.DataSet.RecordCount > 0 then
    cxGrid1DBTableView1.ApplyBestFit()
  else
  begin
    UDM.sms('Esta función solo es aplicable cuando el conjunto de datos tiene al menos un registro.', 3);
    Exit;
  end;
end;

/// <summary>
/// Asigna múltiples subseries disponibles a la estructura actual del árbol.
/// Permite al usuario confirmar la operación y muestra un resumen de resultados.
/// </summary>
/// <param name="Sender">Objeto que generó el evento</param>
procedure TMAIN.btnAsignVarVirClick(Sender: TObject);
var
  i, ExitosCount, ErroresCount: Integer;
  IdEstructura: string;
  BookmarkActual: TBookmark;
  ErrorLog: TStringList;
begin
  // Verificar que UDM esté asignado
  if not Assigned(UDM) then
  begin
    UDM.sms('Error: Módulo de datos no inicializado.', 1);
    Exit;
  end;

  // Verificar que existan datasets necesarios
  if not Assigned(UDM.Tb_SeriesDispo) or not Assigned(UDM.tb_Serietree) or not Assigned(UDM.tb_tree) then
  begin
    UDM.sms('Error: Uno o más datasets necesarios no están disponibles.', 1);
    Exit;
  end;

  // Verificar que existan subseries disponibles
  if not UDM.Tb_SeriesDispo.Active or (UDM.Tb_SeriesDispo.RecordCount = 0) then
  begin
    UDM.sms('No existen subseries disponibles que se puedan agregar.', 2);
    Exit;
  end;

  // Verificar que haya un nodo seleccionado en el árbol
  if not UDM.tb_tree.Active or (UDM.tb_tree.RecordCount = 0) then
  begin
    UDM.sms('No hay una estructura seleccionada para asignar las subseries.', 1);
    Exit;
  end;

  // Confirmar la operación con el usuario
  if UDM.sms('¿Desea agregar el conjunto de subseries (' + IntToStr(UDM.Tb_SeriesDispo.RecordCount) + ') a la estructura actual?', 4) <> 6 then
    Exit;

  // Inicializar contadores y log de errores
  ExitosCount := 0;
  ErroresCount := 0;
  ErrorLog := TStringList.Create;
  try
    // Guardar el ID de estructura para evitar problemas si cambia el registro activo
    IdEstructura := UDM.tb_tree.FieldByName('IdEstructura').AsString;

    // Guardar la posición actual para restaurarla al final
    BookmarkActual := UDM.Tb_SeriesDispo.GetBookmark;

    Screen.Cursor := crHourGlass;
    try
      // Deshabilitar controles para mejorar rendimiento
      UDM.Tb_SeriesDispo.DisableControls;
      try
        UDM.tb_Serietree.DisableControls;
        try
          // Iniciar transacción para todo el proceso
          UDM.StartTransaction;
          try
            // Procesar todas las subseries disponibles
            UDM.Tb_SeriesDispo.First;
            while not UDM.Tb_SeriesDispo.Eof do
            begin
              try
                // Verificar si la combinación ya existe
                if not UDM.tb_Serietree.Locate('IdEstructura;codsubs', VarArrayOf([IdEstructura, UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString]), []) then
                begin
                  // Agregar nuevo registro
                  UDM.tb_Serietree.Append;
                  try
                    // Asignar valores al nuevo registro con verificación de campos
                    UDM.tb_Serietree.FieldByName('IdEstructura').AsString := IdEstructura;
                    UDM.tb_Serietree.FieldByName('id').AsInteger := UDM.tb_tree.FieldByName('id').AsInteger;
                    UDM.tb_Serietree.FieldByName('codsubs').AsString := UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString;

                    // Verificar que los campos existan antes de asignarlos
                    if UDM.Tb_SeriesDispo.FindField('Archivo') <> nil then
                      UDM.tb_Serietree.FieldByName('Archivo').AsString := UDM.Tb_SeriesDispo.FieldByName('Archivo').AsString;

                    if UDM.Tb_SeriesDispo.FindField('deposito') <> nil then
                      UDM.tb_Serietree.FieldByName('deposito').AsString := UDM.Tb_SeriesDispo.FieldByName('deposito').AsString;

                    if UDM.Tb_SeriesDispo.FindField('gaveta') <> nil then
                      UDM.tb_Serietree.FieldByName('gaveta').AsString := UDM.Tb_SeriesDispo.FieldByName('gaveta').AsString;

                    if UDM.Tb_SeriesDispo.FindField('cargo') <> nil then
                      UDM.tb_Serietree.FieldByName('gestor').AsString := UDM.Tb_SeriesDispo.FieldByName('cargo').AsString;

                    if UDM.Tb_SeriesDispo.FindField('pc') <> nil then
                      UDM.tb_Serietree.FieldByName('idservidor').AsString := UDM.Tb_SeriesDispo.FieldByName('pc').AsString;

                    // Guardar el registro
                    UDM.tb_Serietree.Post;
                    Inc(ExitosCount);
                  except
                    on E: Exception do
                    begin
                      // Cancelar la edición si hay error
                      if UDM.tb_Serietree.State in [dsEdit, dsInsert] then
                        UDM.tb_Serietree.Cancel;

                      Inc(ErroresCount);
                      ErrorLog.Add('Error al agregar ' + UDM.Tb_SeriesDispo.FieldByName('subseries').AsString + ': ' + E.Message);
                    end;
                  end;
                end;
              except
                on E: Exception do
                begin
                  Inc(ErroresCount);
                  ErrorLog.Add('Error inesperado con ' + UDM.Tb_SeriesDispo.FieldByName('subseries').AsString + ': ' + E.Message);
                end;
              end;

              UDM.Tb_SeriesDispo.Next;
            end;

            // Confirmar la transacción si hubo al menos un éxito
            if ExitosCount > 0 then
              UDM.CommitTransaction
            else
              UDM.RollbackTransaction;

          except
            on E: Exception do
            begin
              // Asegurar que se haga rollback si hay error en la transacción
              try
                UDM.RollbackTransaction;
              except
                // Ignorar errores en rollback
              end;

              UDM.sms('Error en la transacción: ' + E.Message, 1);
              Inc(ErroresCount);
              ErrorLog.Add('Error en la transacción: ' + E.Message);
            end;
          end;
        finally
          // Asegurar que los controles se rehabiliten
          UDM.tb_Serietree.EnableControls;
        end;
      finally
        // Asegurar que los controles se rehabiliten y restaurar posición
        try
          if UDM.Tb_SeriesDispo.BookmarkValid(BookmarkActual) then
            UDM.Tb_SeriesDispo.GotoBookmark(BookmarkActual);
        except
          // Ignorar errores al restaurar bookmark
        end;
        UDM.Tb_SeriesDispo.FreeBookmark(BookmarkActual);
        UDM.Tb_SeriesDispo.EnableControls;
      end;
    finally
      Screen.Cursor := crDefault;
    end;

    // Mostrar resumen de resultados
    if ErroresCount = 0 then
    begin
      if ExitosCount > 0 then
        UDM.sms('Se agregaron correctamente ' + IntToStr(ExitosCount) + ' subseries.', 0)
      else
        UDM.sms('No se agregó ninguna subserie. Posiblemente ya estaban todas asignadas.', 2);
    end
    else
    begin
      if ExitosCount > 0 then
        UDM.sms('Proceso completado con advertencias. Se agregaron ' + IntToStr(ExitosCount) + ' subseries, pero hubo ' + IntToStr(ErroresCount) + ' errores.', 2)
      else
        UDM.sms('No se pudo agregar ninguna subserie. Ocurrieron ' + IntToStr(ErroresCount) + ' errores.', 1);

      // Mostrar detalles de errores si hay muchos
      if ErroresCount > 3 then
      begin
        if UDM.sms('¿Desea ver el detalle de los errores?', 4) = 6 then
        begin
          with TForm.Create(nil) do
          try
            Caption := 'Detalle de errores';
            Width := 500;
            Height := 300;
            Position := poScreenCenter;

            with TMemo.Create(nil) do
            begin
              Parent := TWinControl(Self);
              Align := alClient;
              ScrollBars := ssVertical;
              ReadOnly := True;
              Lines.AddStrings(ErrorLog);
            end;

            ShowModal;
          finally
            Free;
          end;
        end;
      end
      else if ErroresCount > 0 then
      begin
        // Mostrar los primeros errores directamente
        UDM.sms(ErrorLog.Text, 1);
      end;
    end;
  finally
    ErrorLog.Free;

    // Refrescar vista si es necesario
    try
      if Assigned(UDM.tb_Serietree) and UDM.tb_Serietree.Active then
        UDM.tb_Serietree.Refresh;
    except
      // Ignorar errores al refrescar
    end;
  end;
end;
{procedure TMAIN.btnAsignVarVirClick(Sender: TObject);
var
  i: Integer;
begin
  if UDM.Tb_SeriesDispo.RecordCount = 0 then
  begin
    UDM.sms('No existen subseries disponibles que se puedan agregar.', 2);
    Exit;
  end;
  if UDM.sms('¿Desea agregar el conjunto de subseries (' + IntToStr(UDM.Tb_SeriesDispo.RecordCount) + ') a la estructura actual?', 4) = 6 then
  begin
    UDM.Tb_SeriesDispo.DisableControls;
    UDM.tb_Serietree.DisableControls;
    UDM.Tb_SeriesDispo.First;
    for i := 0 to UDM.Tb_SeriesDispo.RecordCount - 1 do
    begin
      if not UDM.tb_Serietree.Locate('IdEstructura;codsubs', VarArrayOf([UDM.tb_tree.FieldByName('IdEstructura').AsString, UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString]), []) then
      begin
        UDM.tb_Serietree.Append;
        UDM.tb_Serietree.FieldByName('IdEstructura').AsString := UDM.tb_tree.FieldByName('IdEstructura').AsString;
        UDM.tb_Serietree.FieldByName('id').AsInteger := UDM.tb_tree.FieldByName('id').AsInteger;
        UDM.tb_Serietree.FieldByName('codsubs').AsString := UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString;
        UDM.tb_Serietree.FieldByName('Archivo').AsString := UDM.Tb_SeriesDispo.FieldByName('Archivo').AsString;
        UDM.tb_Serietree.FieldByName('deposito').AsString := UDM.Tb_SeriesDispo.FieldByName('deposito').AsString;
        UDM.tb_Serietree.FieldByName('gaveta').AsString := UDM.Tb_SeriesDispo.FieldByName('gaveta').AsString;
        UDM.tb_Serietree.FieldByName('gestor').AsString := UDM.Tb_SeriesDispo.FieldByName('cargo').AsString;
        UDM.tb_Serietree.FieldByName('idservidor').AsString := UDM.Tb_SeriesDispo.FieldByName('pc').AsString;
       // UDM.tb_Serietree.FieldByName('carpeta').AsString := UDM.Tb_SeriesDispo.FieldByName('carpeta').AsString;
        try
          UDM.tb_Serietree.Post;
        except
          on E: EFDException do
          begin
            UDM.sms('La serie ' + UDM.Tb_SeriesDispo.FieldByName('subseries').AsString + ' no se pudo agregar. Motivo: ' + E.Message, 1);
            Exit;
          end;
        end;
      end;
      UDM.Tb_SeriesDispo.Next;
    end;
    UDM.tb_Serietree.EnableControls;
    UDM.Tb_SeriesDispo.EnableControls;
  end;
end;  }

// Procedimiento: TMAIN.btnautenticaClick
// Propósito: Maneja el evento OnClick del botón btnautentica. Si el usuario no está autenticado,
//            realiza la autenticación. Si ya está autenticado, cierra la sesión y restablece el rol a "visor".
// Autor: [Refactorizado por Grok 3, xAI]
// Fecha: 09 de abril de 2025
// Parámetros:
//   Sender: TObject - El objeto que dispara el evento (btnautentica).
// Resultado: No devuelve valor (procedimiento). Autentica al usuario o cierra la sesión.
// Excepciones: Maneja errores relacionados con la autenticación y el acceso a la base de datos.
// Dependencias externas:
//   - UDM.Conn: Conexión a la base de datos para consultas SQL.
//   - UDM.Rol: Rol actual del usuario.
//   - UDM.UserName: Nombre del usuario actual.
//   - Security: Objeto para manejar la seguridad y roles del usuario.
//   - autenticar: Función que realiza la autenticación y devuelve el rol activo.
// Variables globales:
//   - TBD: Tipo de base de datos ('A' para Access, 'S' para SQL Server, etc.).
//   - Rolactivo: Variable global que almacena el rol activo.
//   - acceso: Variable global que almacena el nivel de acceso.

procedure TMAIN.btnautenticaClick(Sender: TObject);
var
  RolID: Integer;
  QueryFunction: string;  // Para determinar la función SQL a usar
  PreviousUserName, PreviousRol: string; // Para registrar el usuario y rol antes de cerrar sesión

  function GetRolID: Integer;
  var
    QueryFunction: string;
  begin
    // Determinar la función SQL según el tipo de base de datos
    case TBD[1] of
      'A':
        QueryFunction := 'lcase';  // MS Access
      'S':
        QueryFunction := 'lower';  // SQL Server
      'M':
        QueryFunction := 'lower';  // MySQL (también usa LOWER)
      'P':
        QueryFunction := 'lower';  // PostgreSQL (también usa LOWER)
    else
      raise Exception.CreateFmt('Tipo de base de datos no soportado: %s', [TBD]);
    end;

    // Ejecutar la consulta
    Result := UDM.Conn.ExecSQLScalar(Format('SELECT idrol FROM tb_rol WHERE %s(rol) = %s', [QueryFunction, QuotedStr(AnsiLowerCase(UDM.Rol))]));
  end;

begin
  try
    // Si el usuario ya está autenticado, cerrar sesión
    if FIsAuthenticated then
    begin
      if UDM.sms('¿Desea cerrar la sesión actual?', 4) = 6 then
      begin
        // Registrar el cierre de sesión
        PreviousUserName := UDM.UserName;
        PreviousRol := UDM.Rol;
        UDM.log(Format('El usuario "%s" con el rol de "%s" ha cerrado sesión', [PreviousUserName, PreviousRol]), 13, '', '', '');

        // Restablecer el estado a "visor"
        UDM.Rol := 'visor';
        UDM.UserName := 'Invitado';
        FIsAuthenticated := False;

        // Actualizar paneles
        MB.Panels[1].Text := UDM.UserName;
        MB.Panels[3].Text := UDM.Rol;

        // Configurar opciones para el rol "visor"
        RolID := GetRolID;
        case RolID of
          1:
            adminOptions;
          2, 3:
            GestorOptions;
          4:
            VisorOptions;
          5:
            ArchiveroOpts;
        end;

        // Acomodar interfaz
        Acomoda;
        Acomoda2;

        // Sin sesion: vuelve el alcance de Visor (solo publico)
        UDM.EstablecerAlcance('Invitado', False);
        UDM.CargarArbol(tvTree, UDM.tb_arbol, False);

        // Actualizar nivel de acceso
        acceso := 'solo lectura';
        Security.SetModSecurity(Self, acceso);

        // Actualizar la imagen del botón
//        UpdateButtonImage;

        UDM.sms('Sesión cerrada. Ahora está como "Invitado" con rol "visor".', 3);
      end;
      Exit;
    end;

    // Si no está autenticado, proceder con la autenticación
    Rolactivo := autenticar;

    // Si el usuario cancela, salir de la función antes de continuar
    if AnsiLowerCase(Rolactivo) = 'visor' then
    begin
      UDM.sms('Autenticación cancelada.', 3);
      Exit;
    end;

    // Actualizar paneles solo si la autenticación es exitosa
    MB.Panels[1].Text := UDM.UserName;
    MB.Panels[3].Text := UDM.Rol;

    // Obtener RolID actualizado
    RolID := GetRolID;

    // Configurar opciones según rol usando case mejorado
    case RolID of
      1:
        adminOptions;
      2, 3:
        GestorOptions;  // Combinar roles 2 y 3 ya que usan la misma función
      4:
        VisorOptions;
      5:
        ArchiveroOpts;
    end;

    // Acomodar interfaz

    Acomoda;
    Acomoda2;

    // El alcance del usuario ya esta cargado: recargar el arbol filtrado
    UDM.CargarArbol(tvTree, UDM.tb_arbol, False);

    // Notificar autenticación
    UDM.sms(Format('Ud se ha autenticado al sistema con el Rol de %s', [AnsiQuotedStr(UDM.Rol, '"')]), 3);
    UDM.log(Format('El usuario "%s" con el rol de "%s" se ha autenticado en el sistema', [UDM.UserName, UDM.Rol]), 11, '', '', '');

    // Determinar nivel de acceso usando operador ternario
    acceso := IfThen((AnsiLowerCase(UDM.Rol) = 'administrador') or (AnsiLowerCase(UDM.Rol) = 'gestor'), 'acceso total', 'solo lectura');
    Security.SetModSecurity(Self, acceso);

    // Actualizar el estado de autenticación y la imagen del botón
    FIsAuthenticated := True;
    //UpdateButtonImage;
  except
    on E: Exception do
    begin
      UDM.sms('Error durante la autenticación: ' + E.Message, 3);
      FIsAuthenticated := False;
      //UpdateButtonImage;
    end;
  end;
end;



{
procedure TMAIN.btnautenticaClick(Sender: TObject);
var
  RolID: Integer;
  QueryFunction: string;  // Para determinar la función SQL a usar

  function GetRolID: Integer;
  var
    QueryFunction: string;
    p: char;
  begin
  // Determinar la función SQL según el tipo de base de datos
    case TBD[1] of
      'A':
        QueryFunction := 'lcase';  // MS Access
      'S':
        QueryFunction := 'lower';  // SQL Server
      'M':
        QueryFunction := 'lower';  // MySQL (también usa LOWER)
      'P':
        QueryFunction := 'lower';  // PostgreSQL (también usa LOWER)
    else
      raise Exception.CreateFmt('Tipo de base de datos no soportado: %s', [TBD]);
    end;

  // Ejecutar la consulta
    Result := UDM.Conn.ExecSQLScalar(Format('SELECT idrol FROM tb_rol WHERE %s(rol) = %s', [QueryFunction, QuotedStr(AnsiLowerCase(UDM.Rol))]));
  end;

begin
// Autenticar y actualizar paneles
  Rolactivo := autenticar;

// Si el usuario cancela, salir de la función antes de continuar
  if ansilowercase(Rolactivo) = 'visor' then
  begin
    UDM.sms('Autenticación cancelada.', 3);
    Exit;
  end;

// Actualizar paneles solo si la autenticación es exitosa
  MB.Panels[1].Text := UDM.UserName;
  MB.Panels[3].Text := UDM.Rol;

// Obtener RolID actualizado
  RolID := GetRolID;

// Configurar opciones según rol usando case mejorado
  case RolID of
    1:
      adminOptions;
    2, 3:
      GestorOptions;  // Combinar roles 2 y 3 ya que usan la misma función
    4:
      VisorOptions;
    5:
      ArchiveroOpts;
  end;

// Acomodar interfaz
  Acomoda;
  Acomoda2;

// Notificar autenticación
  UDM.sms(Format('Ud se ha autenticado al sistema con el Rol de %s', [AnsiQuotedStr(UDM.Rol, '"')]), 3);
  UDM.log(Format('El usuario "%s" con el rol de "%s" se ha autenticado en el sistema', [UDM.UserName, UDM.Rol]), 11, '', '', '');

// Determinar nivel de acceso usando operador ternario
  acceso := IfThen((AnsiLowerCase(UDM.Rol) = 'administrador') or (AnsiLowerCase(UDM.Rol) = 'gestor'), 'acceso total', 'solo lectura');
  Security.SetModSecurity(Self, acceso);
end; }
{var
  RolID: Integer;
  acceso: string;

  function ObtenerRolID: Integer;
  begin
    if TBD = 'A' then
      Result := UDM.Conn.ExecSQLScalar('SELECT idrol FROM tb_rol WHERE lcase(rol) = ' + QuotedStr(AnsiLowerCase(UDM.Rol)))
    else
      Result := UDM.Conn.ExecSQLScalar('SELECT idrol FROM tb_rol WHERE lower(rol) = ' + QuotedStr(AnsiLowerCase(UDM.Rol)));
  end;

begin
  RolID := ObtenerRolID;

  if RolID <> 4 then
  begin
    if UDM.sms('¿Desea cerrar la sesión actual primero?', 4) = 6 then
    begin
      UDM.log(Format('El usuario "%s" con el rol de "%s" ha cerrado sesión', [UDM.UserName, UDM.Rol]), 13, '', '', '');
      UDM.Rol := 'visor';
      UDM.UserName := 'Invitado';
      ArchiveroOpts;
    end
    else
      Exit;
  end;

  Rolactivo := autenticar;
  MB.Panels[1].Text := UDM.UserName;
  MB.Panels[3].Text := UDM.Rol;

  RolID := ObtenerRolID;

  case RolID of
    1:
      adminOptions;
    2, 3:
      GestorOptions;
    4:
      VisorOptions;
    5:
      ArchiveroOpts;
  end;

  Acomoda;
  Acomoda2;

  UDM.sms(Format('Ud se ha autenticado al sistema con el Rol de "%s"', [UDM.Rol]), 3);
  UDM.log(Format('El usuario "%s" con el rol de "%s" se ha autenticado en el sistema', [UDM.UserName, UDM.Rol]), 11, '', '', '');

  if (AnsiLowerCase(UDM.Rol) = 'administrador') or (AnsiLowerCase(UDM.Rol) = 'gestor') then
    acceso := 'acceso total'
  else
    acceso := 'solo lectura';

  if Trim(acceso) = '' then
    acceso := 'solo lectura';

  // Security.SetModSecurity(Self, acceso);
end;  }

procedure TMAIN.btnClearExpClick(Sender: TObject);
begin
  if (AnsiLowerCase(UDM.Rol).Trim = 'administrador') or (AnsiLowerCase(UDM.Rol).Trim = 'gestor') then
  begin
    if UDM.sms('Está a punto de eliminar la asignación al expediente "' + UDM.tb_SeriesDatos.FieldByName('IDExpediente').AsString + '". Esta acción no se puede deshacer. ¿Confirma que desea continuar?', 4) = 6 then
    begin
      if (UDM.tb_SeriesDatos.State <> dsEdit) and (UDM.tb_SeriesDatos.State <> dsInsert) then
        UDM.tb_SeriesDatos.Edit;
      UDM.tb_SeriesDatos.FieldByName('IDExpediente').Value := Null;
      try
        UDM.tb_SeriesDatos.Post;
        UDM.sms('En estos momentos el expediente (' + UDM.tb_SeriesDatos.FieldByName('codigodoc').AsString + ') no esta asignado a ningún expediente válido.', 3);
      except
        on E: EFDException do
        begin
          UDM.tb_SeriesDatos.Cancel;
          UDM.sms('No se pudo eliminar la asociación con el expediente ' + UDM.tb_SeriesDatos.FieldByName('IDExpediente').AsString + '. Motivo: ' + E.Message, 1);
        end;
      end;
    end;
  end
  else
  begin
    UDM.sms('No tiene permisos suficientes para realizar esta operación.', 3);
    Exit;
  end;
end;

procedure TMAIN.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMAIN.btnClosejvcpExpedienteClick(Sender: TObject);
begin
  jvcpExpediente.Visible := False;
  UDM.log('Saliendo de la interfaz de expediente.', 15, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('Nombreestructura').AsString);
end;

procedure TMAIN.btnDetallesClick(Sender: TObject);

  procedure CenterPanel(Panel: TJvCaptionPanel);
  begin
    Panel.Left := (ClientWidth - Panel.Width) div 2;
    Panel.Top := (ClientHeight - Panel.Height) div 2;
  end;

begin
  if UDM.tb_Serietree.RecordCount = 0 then
  begin
    UDM.sms('No existe ninguna subserie documental asignada.', 2);
    Exit;
  end;
  ArchivoActual;
  lcbArchivo.TabOrder := 0;
  edtDeposito.TabOrder := 1;
  edtGaveta.TabOrder := 2;
  lcbServer.TabOrder := 3;
  lcbGestor.TabOrder := 4;
  pcDetalle.TabOrder := 5;
  edtObs.TabOrder := 6;
  CenterPanel(jvcpSSDetail);
  jvcpSSDetail.Visible := True;
  UDM.log('Consultando la topografía de la subsserie.', 14, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('Nombreestructura').AsString);
end;

procedure TMAIN.btnDropSourceFileClick(Sender: TObject);
var
  Pathf, CaminoFichero: string;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Fuentes\';
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

begin
//  UDM.CompletaNombreFile;
  if UDM.qryFuentesDig.RecordCount <= 0 then
  begin
    UDM.sms('No existen Ficheros fuentes disponibles que puedan ser eliminados.', 3);
    exit;
  end;
  if UDM.sms('¿Realmente desea eliminar el fichero seleccionado?', 4) = 6 then
  begin
    UDM.qryFuentesDig.DisableControls;
    try
      Pathf := GetURLRaiz + GetPath + UDM.qryFuentesDig.FieldByName('nombre').AsString;
      CaminoFichero := UDM.qryFuentesDig.FieldByName('urlraiz').AsString + UDM.qryFuentesDig.FieldByName('path').AsString + UDM.qryFuentesDig.FieldByName('nombre').AsString;
      CaminoFichero := AnsiReplaceStr(CaminoFichero, '\', '/');
      CaminoFichero := AnsiReplaceStr(CaminoFichero, '//', '/');
      UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
      UDM.qryFuentesDig.Delete;
      UDM.qryFuentesDig.ApplyUpdates();
      UDM.sms('El fichero fue eliminado satisfactoriamente.', 3);
      {if FileExists(Pathf) then
      begin
//        DeleteFile(Pathf);
        UDM.qryFuentesDig.Delete;
        UDM.qryFuentesDig.ApplyUpdates();
        UDM.sms('El fichero fue eliminado satisfactoriamente.', 3);
      end;}
      ReactiveAnexos;
    except
    end;
    UDM.qryFuentesDig.EnableControls;
  end;
end;

procedure TMAIN.btnExecuteSourceFileClick(Sender: TObject);
var
  pathfile, Destino: string;
  bm: TBookmark;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  if cxPageControl1.ActivePageIndex = 0 then
  begin
    if UDM.qryFuentesDig.RecordCount <= 0 then
    begin
      UDM.sms('No existen Ficheros fuentes disponibles que puedan ser ejecutados.', 2);
      exit;
    end;

    pathfile := UDM.qryFuentesDig.FieldByName('urlraiz').AsString + UDM.qryFuentesDig.FieldByName('path').AsString + UDM.qryFuentesDig.FieldByName('nombre').AsString;
    pathfile := AnsiReplaceStr(pathfile, '\', '/');
    pathfile := AnsiReplaceStr(pathfile, '//', '/');
    Destino := PathTemp + UDM.qryFuentesDig.FieldByName('nombre').AsString;
    UDM.DownloadFileFromFTP(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, pathfile, Destino, UDM.cmdServer.FieldByName('puerto').AsInteger);
    if FileExists(Destino) then
   // ejecutaPDF(Destino)
      UDM.EjecutaFichero(Destino)
    else
      udm.sms('No se encontró el fichero "' + UDM.qryFuentesDig.FieldByName('nombre').AsString + '" en la ruta especificada.', 1);
  end
  else
  begin
    if UDM.qryAnexosDig.RecordCount <= 0 then
    begin
      UDM.sms('No existen anexos digitales disponibles que puedan ser ejecutados.', 2);
      exit;
    end;
    pathfile := UDM.qryAnexosDig.FieldByName('urlraiz').AsString + UDM.qryAnexosDig.FieldByName('path').AsString + UDM.qryAnexosDig.FieldByName('nombre').AsString;
    pathfile := AnsiReplaceStr(pathfile, '\', '/');
    pathfile := AnsiReplaceStr(pathfile, '//', '/');
    Destino := PathTemp + UDM.qryAnexosDig.FieldByName('nombre').AsString;
    if UDM.DownloadFileFromFTP(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, pathfile, Destino, UDM.cmdServer.FieldByName('puerto').AsInteger) then
    begin
      if FileExists(Destino) then
   // ejecutaPDF(Destino)
        UDM.EjecutaFichero(Destino)
      else
        udm.sms('No se encontró el fichero "' + UDM.qryAnexosDig.FieldByName('nombre').AsString + '" en la ruta especificada.', 1);
    end
    else
    begin
      udm.sms('No se pudo descargar el fichero "' + UDM.qryAnexosDig.FieldByName('nombre').AsString + '".', 1);
      exit
    end;
  end;
end;

procedure TMAIN.btnRecuperacionClick(Sender: TObject);
var
  param, listParam: string;
begin
  if not FileExists(ExtractFilePath(Application.ExeName) + 'ArchiRec.exe') then
  begin
    UDM.sms('No se encontró el módulo especificado. Por favor contacte con el proveedor del sistema.', 1);
    Exit;
  end;
  UDM.log('Accediendo al módulo de recuperación.', 14, '', '', '');
  UDM.KillProcess('ArchiRec.exe');
  param:='R';
  listParam := AnsiQuotedStr(param, '"') ;
  UDM.RunAndWaitShell(ExtractFilePath(Application.ExeName) + '\ArchiRec.exe', listParam, SW_SHOWMAXIMIZED);
  screen.Cursor := crDefault;
end;

procedure TMAIN.btnPrintClick(Sender: TObject);

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo acceder al listado de reportes. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
//  ejecutaPDF(PathSys + 'ReportApp.exe');
 { UDM.KillProcess('ReportApp.exe');
  udm.RunAndWaitShell(ExtractFilePath(Application.ExeName) + 'ReportApp.exe', UDM.UserName + ' ' + UDM.Rol, SW_SHOW);
  }
end;

procedure TMAIN.btnquickFillClick(Sender: TObject);

  procedure ApplyFilter(aTable: TFDQuery; const FilterFields: array of string; const EditText: string; const IsSQLServer: Boolean);
  var
    FilterExpression: string;
    i: Integer;
    LowerCaseFunction: string;
  begin
  // Determinar la función de conversión a minúsculas según el SGBD
    if IsSQLServer then
      LowerCaseFunction := 'LOWER'
    else
      LowerCaseFunction := 'LCASE';

  // Refresco de la tabla
    aTable.Refresh;

  // Inicialización de la cadena de filtro
    FilterExpression := '';

  // Verificación del texto de búsqueda
    if Trim(EditText) = '' then
    begin
    // Si el campo de búsqueda está vacío, se deshabilita el filtro
      aTable.Filter := '';
      aTable.Filtered := False;
    end
    else
    begin
    // Construcción de la expresión de filtro
      for i := Low(FilterFields) to High(FilterFields) do
      begin
        if FilterExpression <> '' then
          FilterExpression := FilterExpression + ' OR ';
        FilterExpression := FilterExpression + LowerCaseFunction + '(' + FilterFields[i] + ') LIKE ' + QuotedStr('%' + AnsiLowerCase(EditText) + '%');
      end;

    // Aplicación del filtro
      with aTable do
      begin
        Prepare;
        Filtered := False;
        Filter := FilterExpression;
        Filtered := True;
      end;
    end;
  end;

var
  FilterFields: array of string;
  IsSQLServer: Boolean;
begin
  SetLength(FilterFields, 3);
  FilterFields[0] := 'titulodoc';
  FilterFields[1] := 'codigodoc';
  FilterFields[2] := 'codsubs';
  IsSQLServer := True;
  if TBD = 'A' then
    IsSQLServer := False;
  ApplyFilter(UDM.tb_expxtiposerie, FilterFields, edtFillExp.Text, IsSQLServer);
end;

procedure TMAIN.btnremovefileClick(Sender: TObject);
var
  Pathf, namefile, CaminoFichero: string;
  rc: integer;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Anexos Digitales\';
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

begin
  if UDM.qryAnexosDig.RecordCount <= 0 then
  begin
    UDM.sms('No existen anexos digitales para eliminar', 2);
    Exit;
  end;
  if UDM.sms('¿Realmente desea eliminar el fichero seleccionado?', 4) = 6 then
  begin
    //UDM.CompletaNombreFile;
    UDM.qryAnexosDig.DisableControls;
    try
      rc := UDM.qryAnexosDig.RecordCount;
      namefile := UDM.qryAnexosDig.FieldByName('nombre').AsString;
      Pathf := GetURLRaiz + GetPath + UDM.qryAnexosDig.FieldByName('nombre').AsString;
      CaminoFichero := UDM.qryAnexosDig.FieldByName('urlraiz').AsString + UDM.qryAnexosDig.FieldByName('path').AsString + UDM.qryAnexosDig.FieldByName('nombre').AsString;
      CaminoFichero := AnsiReplaceStr(CaminoFichero, '\', '/');
      CaminoFichero := AnsiReplaceStr(CaminoFichero, '//', '/');
      UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
      UDM.qryAnexosDig.Delete;
      UDM.sms('El fichero "' + namefile + '" fue eliminado satisfactoriamente.', 3);
      UDM.qryAnexosDig.ApplyUpdates();
      {

      if FileExists(Pathf) then
      begin
        DeleteFile(Pathf);
        UDM.qryAnexosDig.Delete;
        UDM.qryAnexosDig.ApplyUpdates();
        UDM.sms('El fichero "' + namefile + '" fue eliminado satisfactoriamente.', 3);
      end; }
      ReactiveAnexos;
    except
    end;
    UDM.qryAnexosDig.EnableControls;
    rc := rc;
  end;
end;

procedure TMAIN.ReactiveAnexos;
begin
  UDM.qryAnexosDig.DisableControls;
  UDM.qryFuentesDig.DisableControls;
  UDM.qryAnexosDig.Active := False;
  UDM.qryAnexosDig.Active := True;
  UDM.qryFuentesDig.Active := False;
  UDM.qryFuentesDig.Active := True;
  UDM.qryAnexosDig.FetchAll;
  UDM.qryFuentesDig.FetchAll;
  UDM.qryAnexosDig.EnableControls;
  UDM.qryFuentesDig.EnableControls;
end;

procedure TMAIN.registrotopograficoClick(Sender: TObject);
begin
  UDM.MostrarReporte('RegistroTopografico');
  {
  if ((trim(UDM.tb_sysconfig.FieldByName('empresa').AsString) <> '') and (not TBlobField(UDM.tb_sysconfig.FieldByName('logo')).IsNull)) then
  begin
       //lo mismo
    UDM.log('Visualizando el reporte de registro topográfico de la entidad.', 14, '', '', '');
    TBlobField(UDM.tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
    CargaReporte(frxMain, pathreport + 'rRegistroTopografico.fr3', 'empresa', UDM.tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png');
  end
  else
  begin
    MessageDlg('Debe configurar los Datos de la Empresa. Consulte la configuración del Sistema.', mtError, [mbOK], 0);
  end;     }
end;

procedure TMAIN.btnRemoveFileListClick(Sender: TObject);
var
  PathF, CaminoFichero: string;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Anexos Digitales\';
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

begin
  if UDM.qryAnexosDig.RecordCount <= 0 then
  begin
    UDM.sms('No existen anexos digitales para eliminar', 2);
    Exit;
  end;
  if UDM.sms('¿Realmente desea eliminar todos los ficheros asociados a la subserie actual?', 4) = 6 then
  begin
    //UDM.CompletaNombreFile;
    PathF := GetURLRaiz + GetPath;
    UDM.qryAnexosDig.DisableControls;
    try
      if UDM.BorrarCarpeta(PChar(PathF)) then
        UDM.qryAnexosDig.Last;
      UDM.qryAnexosDig.Last;
      cpProgress.Visible := True;
      Application.ProcessMessages;
      gProcess.MinValue := 0;
      gProcess.Progress := 0;
      gProcess.MaxValue := UDM.qryAnexosDig.RecordCount;
      while not UDM.qryAnexosDig.Bof do
      begin
        CaminoFichero := UDM.qryAnexosDig.FieldByName('urlraiz').AsString + UDM.qryAnexosDig.FieldByName('path').AsString + UDM.qryAnexosDig.FieldByName('nombre').AsString;
        CaminoFichero := AnsiReplaceStr(CaminoFichero, '\', '/');
        CaminoFichero := AnsiReplaceStr(CaminoFichero, '//', '/');
        try
          UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
        except
        end;
        UDM.qryAnexosDig.Delete;
        gProcess.Progress := gProcess.Progress + 1;
        Application.ProcessMessages;
      end;
      cpProgress.Visible := False;
      UDM.sms('Todos los archivos fueron eliminados satisfactoriamente.', 3);
      ReactiveAnexos;
    except
    end;
    UDM.qryAnexosDig.EnableControls;
  end;
end;

procedure TMAIN.btnRemoveSourceFileListClick(Sender: TObject);
var
  PathF, CaminoFichero: string;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Fuentes\';
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

begin
//  UDM.CompletaNombreFile;
  if UDM.qryFuentesDig.RecordCount <= 0 then
  begin
    UDM.sms('No existen Ficheros fuentes disponibles que puedan ser eliminados.', 3);
    exit;
  end;
  if UDM.sms('¿Realmente desea eliminar todos los ficheros asociados a la subserie actual?', 4) = 6 then
  begin
    PathF := GetURLRaiz + GetPath;
    UDM.qryFuentesDig.DisableControls;
    try
      if UDM.BorrarCarpeta(PChar(PathF)) then
        UDM.qryFuentesDig.Last;
      UDM.qryFuentesDig.Last;
      cpProgress.Visible := True;
      APPLICATION.ProcessMessages;
      gProcess.Progress := 0;
      gProcess.MinValue := 0;
      gProcess.MaxValue := UDM.qryFuentesDig.RecordCount;
      while not UDM.qryFuentesDig.Bof do
      begin
        CaminoFichero := UDM.qryFuentesDig.FieldByName('urlraiz').AsString + UDM.qryFuentesDig.FieldByName('path').AsString + UDM.qryFuentesDig.FieldByName('nombre').AsString;
        CaminoFichero := AnsiReplaceStr(CaminoFichero, '\', '/');
        CaminoFichero := AnsiReplaceStr(CaminoFichero, '//', '/');
        try
          UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
        except
        end;
        UDM.qryFuentesDig.Delete;
        gProcess.Progress := gProcess.Progress + 1;
        Application.ProcessMessages;
      end;
      cpProgress.Visible := False;
      APPLICATION.ProcessMessages;
      UDM.sms('Todos los archivos fueron eliminados satisfactoriamente.', 3);
      ReactiveAnexos;
    except
    end;
    UDM.qryFuentesDig.EnableControls;
  end;
end;

procedure TMAIN.btnSelectDirClick(Sender: TObject);
var
  carpetaLocal: string;
begin
  EsLocalServer := UDM.EsLocal(UDM.tb_Serietree.FieldByName('Idservidor').AsInteger);
  if EsLocalServer then
  begin
    carpetaLocal := UDM.GetFolder(UDM.tb_Serietree.FieldByName('Idservidor').AsInteger);
    SD.InitialDir := carpetaLocal;
  end;
  if SD.Execute then
    if trim(sd.Directory) <> '' then
    begin
      if (UDM.tb_Serietree.State <> dsInsert) and (UDM.tb_Serietree.State <> dsEdit) then
        UDM.tb_Serietree.Edit;
      if EsLocalServer then
        if Pos(carpetaLocal, sd.Directory) = 0 then
        begin
          UDM.sms('No coincide la información suministrada con la asignada para almacenamiento local.', 1);
          Exit;
        end;
      //UDM.tb_Serietree.FieldByName('carpeta').AsString := SD.Directory;
      //edt1.Text := SD.Directory;
    end;
end;

procedure TMAIN.btnSourceFileClick(Sender: TObject);
var
  sr: TSearchRec;
  i, j, inventario, ext: integer;
  nombre, extension, carpetaorg: string;
  padre: integer;
  idpadreA, idhijo: integer;
  VV: Variant;
  LevelAnt: integer;
//VARIABLES NUEVAS PARA METODO NUEVO...
  LongMLevel: Integer;
  MainLevel: Integer;
  CAD: string;
  level, GObjP: integer;
  GPath, GURL: string;
  SQLQ, Origen, Destino: string;

  function GetLevel(Path: string): Integer;
  var
    i, cont: integer;
    fn: string;
  begin
    fn := ExtractFileName(Path);
    if (fn = '.') or (fn = '..') then
    begin
      result := -1;
      Exit;
    end;
    cont := 0;
    for i := 1 to Length(Path) do
      if Path[i] = '\' then
        inc(cont);
    Result := cont - MainLevel;
  end;

  function getMLevel(Path: string): Integer;
  var
    i, cont: integer;
  begin
    cont := 0;
    LongMLevel := 0;
    for i := 1 to Length(Path) do
    begin
      if Path[i] = '\' then
        inc(cont);
      Inc(LongMLevel);
    end;
    Result := cont;
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.UrlRaizNuevos; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

  function GetPath: string;
  begin
    Result := '/' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '/' + UDM.SudSDetail.FieldByName('codserie').AsString + '/' + UDM.SudSDetail.FieldByName('codsubs').AsString + '/' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '/Fuentes/';
  end;

  function MaxIdHijo: Integer;
  var
    tmp: Integer;
  begin
    Result := 1;
    with TFDQuery.Create(nil) do
    try
      Active := False;
      Connection := UDM.Conn;
      SQL.Clear;
      SQL.Add('select Max(idhijo)as maximosonvalue from tb_ssArchdigital');
      try
        Active := True;
        if (Fields[0].Value <> null) and (trim(Fields[0].AsString) <> '') then
          Result := Fields[0].AsInteger + 1;
      except
      end;
    finally
      Free;
    end;
  end;

  function removeext(cad1: string): string;
  var
    i: integer;
    flag: Boolean;
  begin
    flag := False;
    Result := '';
    for i := length(cad1) - 1 downto 1 do
    begin
      if flag then
        result := cad1[i] + result;
      if cad1[i] <> '.' then

      else
        flag := True;
    end;
  end;

  function GetFileNameWithoutExtension(const FileName: string): string;
  var
    BaseName: string;
    ExtPos: Integer;
  begin
  // Extract the base filename (removes path)
    BaseName := ExtractFileName(FileName);
  // Find the last dot to remove the extension
    ExtPos := LastDelimiter('.', BaseName);
    if ExtPos > 0 then
      Result := Copy(BaseName, 1, ExtPos - 1)
    else
      Result := BaseName;
  end;

begin
  if UDM.tb_SeriesDatos.RecordCount = 0 then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 3);
    Exit;
  end;
  //UDM.CompletaNombreFile;
  {if trim(UDM.tb_SeriesDatos.FieldByName('namefile').AsString) = '' then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 1);
    Exit;
  end; }
  if ODArchDig.Execute then
    if Trim(ODArchDig.FileName) <> '' then
    begin
      level := GetLevel(ODArchDig.FileName);
      GPath := GetPath;
      GURL := GetURLRaiz;
      idhijo := MaxIdHijo;
      extension := ExtractFileExt(ODArchDig.FileName);
      if UDM.tb_ext.Locate('ext', AnsiLowerCase(extension), []) then
        ext := UDM.tb_ext.FieldByName('id').AsInteger - 1
      else
        ext := 102;
      UDM.tb_ssArchdigital.Append;
      UDM.tb_ssArchdigital.FieldByName('idestructura').AsString := UDM.tb_SeriesDatos.FieldByName('idestructura').AsString;
      UDM.tb_ssArchdigital.FieldByName('id').AsInteger := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
      UDM.tb_ssArchdigital.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
      UDM.tb_ssArchdigital.FieldByName('fecha').AsDateTime := UDM.tb_SeriesDatos.FieldByName('fecha').AsDateTime;
      UDM.tb_ssArchdigital.FieldByName('version').AsString := UDM.tb_SeriesDatos.FieldByName('version').AsString;
      UDM.tb_ssArchdigital.FieldByName('Codigodoc').AsString := UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString; //Codigodoc
      UDM.tb_ssArchdigital.FieldByName('idhijo').AsInteger := idhijo;
      UDM.tb_ssArchdigital.FieldByName('nombre').AsString := ExtractFileName(ODArchDig.FileName); //UDM.tb_SeriesDatos.FieldByName('namefile').AsString;
      UDM.tb_ssArchdigital.FieldByName('ext').AsInteger := ext;
      UDM.tb_ssArchdigital.FieldByName('extnombre').AsString := extension;
      UDM.tb_ssArchdigital.FieldByName('comentario').Value := Null;
      UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString := GURL;
      UDM.tb_ssArchdigital.FieldByName('path').AsString := GPath;
      UDM.tb_ssArchdigital.FieldByName('tamano').AsInteger := TamFichero(ODArchDig.FileName);
      UDM.tb_ssArchdigital.FieldByName('padre').AsInteger := 0;
      UDM.tb_ssArchdigital.FieldByName('Nivel').AsInteger := 0;
      UDM.tb_ssArchdigital.FieldByName('fuente').AsString := 'S';
      UDM.tb_ssArchdigital.FieldByName('Etiqueta').AsString := GetFileNameWithoutExtension(ODArchDig.FileName);
      try
        PathSaveBinaryFile := GURL + GPath + ExtractFileName(ODArchDig.FileName);
        PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '\', '/');
        PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '//', '/');
        Destino := PathSaveBinaryFile;
        CopyFile(pwidechar(ODArchDig.FileName), pwidechar(pathtemp + ExtractFileName(ODArchDig.FileName)), true);
        Origen := pathtemp + ExtractFileName(ODArchDig.FileName);
//        Origen := ODArchDig.FileName;
        udm.CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, Origen, Destino, 'F', UDM.cmdServer.FieldByName('puerto').AsInteger);
        DeleteFile(Origen);
        UDM.tb_ssArchdigital.Post;
        UDM.tb_ssArchdigital.DisableControls;
        UDM.tb_ssArchdigital.Active := False;
        UDM.tb_ssArchdigital.Active := True;
        UDM.tb_ssArchdigital.FetchAll;
        UDM.tb_ssArchdigital.EnableControls;
        UDM.sms('El fichero se agregó satisfactoriamente', 3);
      except
        on E: EFDException do
        begin
          udm.sms('No se pudo agregar el fichero seleccionado al archivo digital actual. Motivo: ' + E.Message, 1);
          UDM.tb_ssArchdigital.Cancel;
        end;
      end;
    end;
  ReactiveAnexos;
end;

procedure TMAIN.btnTransferClick(Sender: TObject);
begin
  //ExportTrans;
  with TfrmTransferencias.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.btnusercontrolClick(Sender: TObject);
begin
  UDM.log('Accediendo al módulo de administrción de usuarios.', 14, '', '', '');
  with TfrmGestUser.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
  UDM.log('Abandonando el módulo de administración de usuarios.', 15, '', '', '');
end;

procedure TMAIN.btnValueClick(Sender: TObject);
begin
  with TfrmImportExport.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.btnViewPanelClick(Sender: TObject);
begin
 // btnViewPanel.Visible:=pArchivoDig.
  if not PSeriesDatos.Visible then
  begin
    udm.sms('No hay datos para mostrar.', 2);
    Exit;
  end;
  {if not advtpDetalle.Visible then
    Exit;
  if (UDM.qryAnexosDig.RecordCount = 0) and (UDM.qryFuentesDig.RecordCount = 0) and (UDM.tb_DocCoord.RecordCount = 0) then
  begin
    UDM.sms('No hay datos para mostrar.', 2);
    Exit;
  end;    }

  if not pArchivoDig.Visible then
    pArchivoDig.Show
  else
  begin
    pArchivoDig.Hide;
  end;
end;

procedure TMAIN.btnviewTopoDocActualClick(Sender: TObject);
begin
  if UDM.tb_SeriesDatos.RecordCount = 0 then
  begin
    UDM.sms('Especifique un documento válido.', 3);
    Exit;
  end;
  with TfrmUbicaDocActual.Create(nil) do
  try
    Caption := 'Documento ' + UDM.tb_SeriesDatos.FieldByName('titulodoc').AsString;
    ShowTopografia(UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString);
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.C1Click(Sender: TObject);
begin
  if UDM.sms('¿Está seguro que desea cambiar el fichero de configuración de acceso a la base de datos?', 4) = 6 then
  begin
    CopyFile(pwidechar(PathSys + 'config.ini'), pwidechar(PathTemp + 'config.ini'), true);
    DeleteFile(PathSys + 'config.ini');
    if Configurasys(True) then
    begin
      UDM.sms('La aplicación se cerrará para aplicar los cambios realizados', 3);
      Application.Terminate;
    end;
  end;
end;

procedure TMAIN.CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
var
  Component: TfrxComponent;
begin
  with report do
  begin
    if LoadFromFile(pathreport) then
    begin
      InsertConnection(report, PathBD);
      Component := FindObject(nameempresa);
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
end;

procedure TMAIN.CargarEstadoToolPanel(ToolPanel: TAdvToolPanel; const ArchivoINI: string);
var
  INI: TIniFile;
  wi: integer;
begin
  if not FileExists(ArchivoINI) then
    Exit;
  INI := TIniFile.Create(ArchivoINI);
  try
    ToolPanel.Height := INI.ReadInteger('ToolPanel', 'Height', ToolPanel.Height);
    wi := INI.ReadInteger('ToolPanel', 'Width', ToolPanel.Width);
    if wi = 0 then
    begin
      ToolPanel.Width := 400;
      ToolPanel.OpenWidth := 400;
    end;
    ToolPanel.Locked := INI.ReadBool('ToolPanel', 'Locked', ToolPanel.Locked);
//    ToolPanel.Show;
    ToolPanel.Visible := True;
  finally
    INI.Free;
  end;
end;

function TMAIN.CargarVariablesSubserie(ASubserieID: string): string;
begin
  result := 'SELECT * FROM cl_VarSubserie WHERE codsubs = ' + QuotedStr(ASubserieID);
end;

procedure TMAIN.CargaValue(Sender: TObject);
//var
//  FieldNames:string;
begin
//  TcxComboBoxProperties(Sender.Properties.EditProperties).
//  FieldNames:=TcxComboBoxProperties(NewRow.Properties.EditProperties).Items.Assign(ComboValues);
//  udm.CargaValoresCampo(ComboValues, (FieldName), md_var.SQL.Text);
end;

procedure TMAIN.CbDItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin

end;

procedure TMAIN.cclasificacionClick(Sender: TObject);
begin
  UDM.MostrarReporte('Cuadro_Clasificacion');
  {
//esta validacion la puse aqui pero puede ser en otro lugar si deseas
  UDM.log('Visualizando el reporte de Cuadro de Clasificación.', 14, '', '', '');
  if ((trim(udm.tb_sysconfig.FieldByName('empresa').AsString) <> '') and (not TBlobField(udm.tb_sysconfig.FieldByName('logo')).IsNull)) then
  begin
     //salvar el logo que esta en la tabla de configuracion a la carpeta de reportes ,que ahora esta a nivel del mosulo
     //principal
    TBlobField(udm.tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
    //todos los parametros para cargar el reporte
    CargaReporte(frxMain, pathreport + 'rCuadro_Clasificacion.fr3', 'empresa', UDM.tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png');
  end
  else
  begin
    MessageDlg('Debe configurar lo sDatos de la Empresa. Dirijase a la configuración del Sistema.', mtError, [mbOK], 0);
  end; }
end;

procedure TMAIN.ChangeAttributes(const Dir: string);
var
  FileSearch: TSearchRec;
  extension: string;
  idhijo: integer;
begin
  try
    ChDir(Dir);
    if FindFirst('*.*', faDirectory, FileSearch) = 0 then
      repeat
        Application.ProcessMessages;
        if ((FileSearch.Attr and faDirectory) = FileSearch.Attr) or (FileSearch.Attr = 48) then
        begin
          if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
          begin
            SetFileAttributes(PChar(Dir + FileSearch.Name), FILE_ATTRIBUTE_DIRECTORY);
            Inc(idhijo);
            ChangeAttributes(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'));
          end;
        end
        else if (FileSearch.Attr > 71) and (FileSearch.Attr <> 1048592) then
        begin
          try
            SetFileAttributes(PChar(Dir + FileSearch.Name), FILE_ATTRIBUTE_DIRECTORY);
          except
          end;
        end
        else if (FileSearch.Attr > 71) and (FileSearch.Attr = 1048592) then
        begin
          if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
          begin
            try
              SetFileAttributes(PChar(Dir + FileSearch.Name), FILE_ATTRIBUTE_DIRECTORY);
            except
            end;
          end;
        end
        else
        begin
          extension := ExtractFileExt(FileSearch.Name);
          if trim(extension) <> '' then
            if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
            begin
              extension := ExtractFileExt(FileSearch.Name);
              try
                SetFileAttributes(PChar(Dir + FileSearch.Name), FILE_ATTRIBUTE_ARCHIVE);
              except
              end;

            end;
        end;
      until FindNext(FileSearch) <> 0;
    FindClose(FileSearch);
  except
  end;

end;

function TMAIN.changeText(RTFText: string): string;
var
  i: Integer;
  InControlWord: Boolean;
  InEscape: Boolean;
  InGroup: Integer;
  CurrentChar: Char;
  TempChar: string;
begin
  Result := '';
  InControlWord := False;
  InEscape := False;
  InGroup := 0;
  i := 1;
  while i <= Length(RTFText) do
  begin
    CurrentChar := RTFText[i];
    if InEscape then
    begin
      // Manejar caracteres escapados, como \'xx
      if CurrentChar = '''' then
      begin
        // Convertir el siguiente dos caracteres hexadecimales a un carácter
        if (i + 2 <= Length(RTFText)) then
        begin
          TempChar := Chr(StrToInt('$' + Copy(RTFText, i + 1, 2)));
          Result := Result + TempChar;
          Inc(i, 2); // Saltar los dos caracteres hexadecimales
        end;
        InEscape := False;
      end
      else
      begin
        Result := Result + CurrentChar;
        InEscape := False;
      end;
    end
    else if InControlWord then
    begin
      if CurrentChar in [' ', '\', '{', '}'] then
      begin
        // Fin de la palabra de control
        InControlWord := False;
        Dec(i); // Reprocesar este carácter en la siguiente iteración
      end;
    end
    else
    begin
      case CurrentChar of
        '{':
          Inc(InGroup);
        '}':
          if InGroup > 0 then
            Dec(InGroup);
        '\':
          // Manejar palabras de control o caracteres escapados
          if (i < Length(RTFText)) and (RTFText[i + 1] = '''') then
          begin
            InEscape := True;
            Inc(i);
          end
          else
            InControlWord := True;
      else
        if InGroup = 1 then
          Result := Result + CurrentChar;
      end;
    end;
    Inc(i);
  end;

  Result := Trim(Result);
end;

function TMAIN.CheckFTPConnection(const Host, Username, Password: string; Puerto: integer): Boolean;
var
  FTPClient: TIdFTP;
begin
  FTPClient := TIdFTP.Create(nil);
  try
    FTPClient.Host := Host;
    FTPClient.Username := Username;
    FTPClient.Password := Password;
    FTPClient.Port := Puerto;
    try
      FTPClient.Connect;
      Result := True;
    except
        // Handle the exception if the connection attempt fails
      Result := False;
    end;
  finally
    FTPClient.Disconnect;
    FTPClient.Free;
  end;
end;

procedure TMAIN.CleanTMP(Dir: string);
var
  FileSearch: TSearchRec;
begin
  ChDir(Dir);
  if FindFirst('*.pdf', faDirectory, FileSearch) = 0 then
    repeat
      if ((FileSearch.Attr and faDirectory) = faDirectory) then
      begin
        if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
          CleanTMP(Dir + '\' + FileSearch.Name);
      end
      else
      begin
          { Pon aqui lo que quieras hacer con los ficheros encontrados }
          { Put here anything to make with the find files }
        DeleteFile(Dir + '\' + FileSearch.Name);
      end;
    until FindNext(FileSearch) <> 0;
  FindClose(FileSearch);
end;

procedure TMAIN.CloseHelpWnd;
var
  HlpWind: HWND;
const
  HelpTitle = 'EMSERGO SGD';
begin
  HlpWind := FindWindow('HH Parent', HelpTitle);
  if HlpWind <> 0 then
    PostMessage(HlpWind, WM_Close, 0, 0);
end;

constructor TMAIN.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FComboBoxAssociations := TComboBoxFieldAssociations.Create; // Inicializar la lista
end;

procedure TMain.CreateVerticalGridRows(DBVerticalGrid: TcxDBVerticalGrid; Query: TFDQuery; LabelQuery: TFDQuery);
var
  I: Integer;
  NewRow: TcxDBEditorRow;
  UserLabel, FieldName: string;
  ComboBoxProperties: TcxComboBoxProperties;
//  ComboBoxAssociation: TComboBoxFieldAssociation; // Asociación para ComboBox
begin
  // Limpiar las filas existentes
  DBVerticalGrid.ClearRows;

  // Iterar por todos los campos de la consulta origen
  for I := 6 to Query.FieldCount - 1 do
  begin
    FieldName := Query.Fields[I].FieldName;
    // Crear una nueva fila basada en el tipo de campo
    NewRow := DBVerticalGrid.Add(TcxDBEditorRow) as TcxDBEditorRow;
    // Obtener la etiqueta del campo desde la tabla cl_VarSubserie
    if LabelQuery.Locate('NomVariable', FieldName, []) then
    begin
      UserLabel := LabelQuery.FieldByName('Etiqueta').AsString;
    end
    else
    begin
      // Si no se encuentra una etiqueta personalizada, usar el nombre del campo
      UserLabel := Query.Fields[I].DisplayName;
    end;

    // Asignar el nombre de la etiqueta como título o caption de la fila
    NewRow.Properties.Caption := UserLabel;

    // Asignar la etiqueta como hint
    NewRow.Properties.Hint := LabelQuery.FieldByName('descripcion').AsString;

    // Enlazar la fila con el campo de la consulta
    NewRow.Properties.DataBinding.FieldName := FieldName;

    // Configurar propiedades adicionales según el tipo de campo
    case Query.Fields[I].DataType of
      ftString, ftWideString:
        begin
          if Query.Fields[I].Size <= 30 then
          begin
            // Usar un ComboBox para campos de tipo varchar con menos de 30 caracteres
            NewRow.Properties.EditPropertiesClass := TcxComboBoxProperties;

            // Asignar el evento OnCloseUp para actualizar la lista
            ComboBoxProperties := TcxComboBoxProperties(NewRow.Properties.EditProperties);
            ComboBoxProperties.OnInitPopup := ComboBoxCloseUp;
            ComboBoxProperties.DropDownRows := 8;
//            AddComboBoxAssociation(ComboBoxProperties, FieldName);
            // Crear la asociación y almacenar el nombre del campo
            ComboBoxAssociation.ComboBox := ComboBoxProperties; // Ahora es correcto
            ComboBoxAssociation.FieldName := FieldName;
            ComboBoxAssociation.GridRow := I;

            // Opcional: almacenar en una lista para manejarlo después
            FComboBoxAssociations.Add(ComboBoxAssociation); // Asegúrate de que esta lista sea inicializada antes
            // Cargar valores iniciales en el ComboBox
            try
              LoadComboBoxValues(ComboBoxProperties, udm.Conn.ExecSQLScalar('select NombreTablaMetadatos from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)), FieldName);
            except

            end;
          end
          else
          begin
            // Para otros campos de texto
            NewRow.Properties.EditPropertiesClass := TcxTextEditProperties;
          end;
        end;
      ftDate, ftDateTime, ftTimeStamp:
        begin
          NewRow.Properties.EditPropertiesClass := TcxDateEditProperties;
          TcxDateEditProperties(NewRow.Properties.EditProperties).UseMouseWheel := True;  // Activar el selector de fechas
          TcxDateEditProperties(NewRow.Properties.EditProperties).Kind := ckDate;  // Para mostrar tanto la fecha como la hora
        end;
      ftMemo, ftWideMemo:
        begin
          NewRow.Properties.EditPropertiesClass := TcxMemoProperties;
          TcxMemoProperties(NewRow.Properties.EditProperties).ScrollBars := ssVertical;
          TcxMemoProperties(NewRow.Properties.EditProperties).VisibleLineCount := 5;
        end;
      // Otros tipos de campos...
    end;
  end;
end;

{var
  I: Integer;
  NewRow: TcxDBEditorRow;
  UserLabel, FieldName: string;
  ComboBoxProperties: TcxComboBoxProperties;
begin
  // Limpiar las filas existentes
  DBVerticalGrid.ClearRows;

  // Iterar por todos los campos de la consulta origen
  for I := 6 to Query.FieldCount - 1 do
  begin
    FieldName := Query.Fields[I].FieldName;

    // Crear una nueva fila basada en el tipo de campo
    NewRow := DBVerticalGrid.Add(TcxDBEditorRow) as TcxDBEditorRow;

    // Obtener la etiqueta del campo desde la tabla cl_VarSubserie
    if LabelQuery.Locate('NomVariable', FieldName, []) then
    begin
      UserLabel := LabelQuery.FieldByName('Etiqueta').AsString;
    end
    else
    begin
      // Si no se encuentra una etiqueta personalizada, usar el nombre del campo
      UserLabel := Query.Fields[I].DisplayName;
    end;

    // Asignar el nombre de la etiqueta como título o caption de la fila
    NewRow.Properties.Caption := UserLabel;

    // Asignar la etiqueta como hint
    NewRow.Properties.Hint := LabelQuery.FieldByName('descripcion').AsString;

    // Enlazar la fila con el campo de la consulta
    NewRow.Properties.DataBinding.FieldName := FieldName;

    // Configurar propiedades adicionales según el tipo de campo
    case Query.Fields[I].DataType of
      ftString, ftWideString:
        begin
          if Query.Fields[I].Size < 30 then
          begin
            // Usar un ComboBox para campos de tipo varchar con menos de 30 caracteres
            NewRow.Properties.EditPropertiesClass := TcxComboBoxProperties;
            // Asignar el evento OnCloseUp para actualizar la lista
            ComboBoxProperties := TcxComboBoxProperties(NewRow.Properties.EditProperties);
            ComboBoxProperties.OnCloseUp := ComboBoxCloseUp;
            // Guardar el nombre del campo en el Tag
            NewRow.Properties.Edi := Integer(Pointer(FieldName)); // Asignar el nombre del campo
            // Cargar valores iniciales al ComboBox
            LoadComboBoxValues(ComboBoxProperties, FieldName);
          end
          else
          begin
            // Para otros campos de texto
            NewRow.Properties.EditPropertiesClass := TcxTextEditProperties;
          end;
        end;

      ftInteger, ftSmallint, ftWord, ftAutoInc, ftFloat, ftCurrency:
        begin
          NewRow.Properties.EditPropertiesClass := TcxTextEditProperties;
        end;

      ftDate, ftDateTime, ftTimeStamp:
        begin
          NewRow.Properties.EditPropertiesClass := TcxDateEditProperties;
          TcxDateEditProperties(NewRow.Properties.EditProperties).UseMouseWheel := True;  // Activar el selector de fechas
          TcxDateEditProperties(NewRow.Properties.EditProperties).Kind := ckDate;  // Para mostrar tanto la fecha como la hora
        end;

      ftMemo, ftWideMemo:
        begin
          NewRow.Properties.EditPropertiesClass := TcxMemoProperties;
          TcxMemoProperties(NewRow.Properties.EditProperties).ScrollBars := ssVertical;
          TcxMemoProperties(NewRow.Properties.EditProperties).VisibleLineCount := 5;
        end;
    else
      // Por defecto, usar TcxTextEditProperties si el tipo no está manejado
      NewRow.Properties.EditPropertiesClass := TcxTextEditProperties;
    end;
  end;
end;    }

procedure TMain.ComboBoxCloseUp(Sender: TObject);
var
  ComboBox: TcxComboBox;
  NewValue: string;
  i: integer;
  Row: TcxCustomRow;
  FieldName: string;
  Association: TComboBoxFieldAssociation;
  ItemCount: Integer;
begin
  // Asegúrate de que Sender sea del tipo correcto
  if Sender is TcxComboBox then
  begin
    ComboBox := Sender as TcxComboBox;
    // Obtener la fila a la que pertenece el ComboBox
//    Row := TcxCustomRow(ComboBox);
//    ItemCount:=Row.IndexOf(Row);
    // Buscar la asociación por la fila
    ComboBox.Properties.DropDownRows := 8;
    NewValue := ComboBox.Text;  // Acceder a la propiedad Text del ComboBox
    FieldName := '';
    for Association in FComboBoxAssociations do
    begin
      if Association.GridRow = FilaSel then
      begin
        FieldName := Association.FieldName;
      end;
    end;
    {Association := FComboBoxAssociations.FindAssociation(Row);
    if Assigned(Association) then
    begin
      FieldName := Association.FieldName;
    end; }

    // Comprobar si el nuevo valor no está en la lista
    if (NewValue <> '') and (ComboBox.Properties.Items.IndexOf(NewValue) = -1) then
    begin
      ComboBox.Properties.Items.Add(NewValue); // Agregar el nuevo valor
      // Aquí podrías agregar lógica para guardar el nuevo valor en la base de datos
      // por ejemplo: AddValueToDatabase(NewValue);
    end;
    // Volver a cargar los valores después de agregar uno nuevo
    LoadComboBoxValues(ComboBox.Properties, udm.Conn.ExecSQLScalar('select NombreTablaMetadatos from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)), FieldName);
  end;
end;

procedure TMAIN.ConfigureGridNavigation;
begin
  // Asegurarse de que el grid permita la navegación con teclas
  cxGrid2DBTableView1.OptionsBehavior.FocusCellOnTab := False; // Evitar que el Tab cambie de celda
  cxGrid2DBTableView1.OptionsBehavior.FocusCellOnCycle := True; // Permitir que el foco cicle entre registros
  cxGrid2DBTableView1.OptionsBehavior.GoToNextCellOnEnter := False; // Evitar que Enter mueva el foco a la siguiente celda
  cxGrid2DBTableView1.OptionsBehavior.ImmediateEditor := False; // Evitar que el grid entre en modo edición al presionar una tecla
  cxGrid2DBTableView1.OptionsBehavior.AlwaysShowEditor := False; // No mostrar el editor automáticamente

  // Configurar la selección de filas
  cxGrid2DBTableView1.OptionsSelection.CellSelect := False; // Seleccionar filas completas, no celdas
  cxGrid2DBTableView1.OptionsSelection.MultiSelect := False; // Permitir seleccionar solo una fila a la vez
  cxGrid2DBTableView1.OptionsSelection.InvertSelect := False; // No invertir la selección

  // Asegurarse de que el grid pueda recibir el foco
  cxGrid1.TabStop := True; // Permitir que el grid reciba el foco con Tab
end;

procedure TMAIN.ConfigureNavigatorBar(DBVerticalGrid: TcxDBVerticalGrid);
begin
  // Habilitar la NavigatorBar
  DBVerticalGrid.Navigator.Visible := True;

  // Mostrar solo los botones Edit, Post (Aceptar) y Refresh
  with DBVerticalGrid.Navigator.Buttons do
  begin
    // Mostrar solo los botones deseados
    Edit.Visible := True;
    Post.Visible := True;
    Refresh.Visible := True;

    // Ocultar los botones no deseados
    Append.Visible := False;
    Cancel.Visible := False;
    Delete.Visible := False;
    Edit.Visible := False;
    First.Visible := False;
    Insert.Visible := False;
    Last.Visible := False;
    Next.Visible := False;
    Prior.Visible := False;
  end;
end;

procedure TMAIN.ConfigureVariablesGrid(const ASubserie: string);
var
  serie, cadena, nombretmptable: string;
  existe: Boolean;
begin
  serie := UDM.Conn.ExecSQLScalar('SELECT codserie FROM cl_subseries WHERE codsubs = ' + QuotedStr(ASubserie));
  nombretmptable := UDM.QuitaCaracter('md_' + serie + ASubserie);

  if (nombretmptable = 'md_') or (nombretmptable = '') then
    Exit;

  existe := UDM.TablaExiste(UDM.Conn, nombretmptable);
  if not existe then
    Exit;

  // Configurar título y posicionar datasets
  pVerticalTitle.Caption := ' Subserie: ' + ASubserie;
  UDM.cl_series.Locate('codserie', serie, []);
  UDM.cl_subseries.Locate('codserie;codsubs', VarArrayOf([serie, ASubserie]));

  // Configurar consulta para md_var
  md_var.Active := False;
  md_var.SQL.Clear;
  cadena := UDM.GenerarConsultaSQL(UDM.cl_VarSubSerie, 'SELECT NombreTablaMetadatos FROM cl_subseries WHERE codsubs = ' + QuotedStr(ASubserie));
  md_var.SQL.Add(cadena);

  // Configurar consulta para md_def
  md_def.Active := False;
  md_def.SQL.Clear;
  md_def.SQL.Add('SELECT NomVariable, Etiqueta, descripcion FROM cl_VarSubserie WHERE codsubs = ' + QuotedStr(ASubserie) + ' ORDER BY orden ASC');

  try
    md_var.Open();
    md_def.Open();
    CreateVerticalGridRows(cxDBVerticalGrid3, md_var, md_def);
    ApplyBestFit(cxDBVerticalGrid3);
  except
    on E: Exception do
    begin
      UDM.sms('Error al configurar el grid de variables: ' + E.Message, 1);
      raise;
    end;
  end;
end;

procedure TMAIN.ControldeVersiones1Click(Sender: TObject);
begin
  with TfrmHistory.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.CopyColumnsAndProperties(SourceView, TargetView: TcxGridDBTableView);
var
  i, j, pp: Integer;
  SourceColumn, TargetColumn: TcxGridDBColumn;
begin
  // Copiar propiedades generales del DataView
  TargetView.OptionsData := SourceView.OptionsData;
  TargetView.OptionsSelection := SourceView.OptionsSelection;
  TargetView.OptionsView := SourceView.OptionsView;
  TargetView.OptionsBehavior := SourceView.OptionsBehavior;
  TargetView.OptionsCustomize := SourceView.OptionsCustomize;
  pp := 0;
  // Recorrer columnas de la vista de destino
  for i := 0 to TargetView.ColumnCount - 1 do
  begin
    TargetColumn := TargetView.Columns[i];
    // Buscar columna con el mismo nombre de campo en la vista de origen

    for j := pp to SourceView.ColumnCount - 1 do
    begin
      SourceColumn := SourceView.Columns[j];
      if SameText(TargetColumn.DataBinding.FieldName, SourceColumn.DataBinding.FieldName) then
      begin
        // Copiar propiedades de la columna de origen a la columna de destino
        TargetColumn.Width := SourceColumn.Width;
        TargetColumn.Visible := SourceColumn.Visible;
        TargetColumn.Caption := SourceColumn.Caption;
        TargetColumn.Index := SourceColumn.Index;
        TargetColumn.Styles := SourceColumn.Styles;
        TargetColumn.SortOrder := SourceColumn.SortOrder;
        TargetColumn.Options := SourceColumn.Options;
        TargetColumn.Tag := SourceColumn.Tag;
        // Ajuste de alineación según el tipo de propiedades de la columna
        if SourceColumn.Properties is TcxTextEditProperties then
        begin
          TcxTextEditProperties(TargetColumn.Properties).Alignment.Horz := TcxTextEditProperties(SourceColumn.Properties).Alignment.Horz;
          TcxTextEditProperties(TargetColumn.Properties).Alignment.Vert := TcxTextEditProperties(SourceColumn.Properties).Alignment.Vert;
        end;
        if SourceColumn.Properties is TcxBlobEditProperties then
        begin
          TargetColumn.PropertiesClass := TcxBlobEditProperties;
          with TcxBlobEditProperties(TargetColumn.Properties) do
          begin
            AlwaysSaveData := True;                   // Asegura que los datos se guarden siempre
            BlobEditKind := bekBlob;                  // Define el tipo de edición del blob
            BlobPaintStyle := bpsIcon;                // Define el estilo de la presentación
            ImmediateDropDown := True;                // Opcional: muestra el dropdown de inmediato
            ImmediatePost := True;                    // Opcional: envía cambios de inmediato
            OnButtonClick := cxGrid2DBTableView1ficheroPropertiesButtonClick;
          end;
        end;
        pp := j + 1;
        Break;
      end;
    end;
  end;
end;

procedure TMAIN.cpProgressButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
begin
  {if Button = capClose then
    cpInfoPathSubSeries.Visible := False;}
end;

procedure TMAIN.cpProgressEndAutoDrag(Sender: TObject);
begin
  UDM.Boundarys(Sender);
end;

procedure TMAIN.cxDBBlobEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  advManagementDirectoryPath.PopupAtCursor;
end;

procedure TMAIN.cxDBNavigator4ButtonsButtonClick(Sender: TObject; AButtonIndex: Integer; var ADone: Boolean);
begin
  if AButtonIndex = 11 then
  begin
    S := s;
  end;
end;

procedure TMAIN.tlFuenteDblClick(Sender: TObject);
var
  pathfile: string;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin                                                                                                                 //nombre
  pathfile := UDM.qryFuentesDig.FieldByName('urlraiz').AsString + UDM.qryFuentesDig.FieldByName('path').AsString + UDM.qryFuentesDig.FieldByName('nombre').AsString;
  if FileExists(pathfile) then
    ejecutaPDF(pathfile)
  else
  begin
    UDM.sms('No se encontró el fichero "' + UDM.qryFuentesDig.FieldByName('nombre').AsString + '" en la ruta especificada.', 1);
    Exit;
  end;
end;

procedure TMAIN.tmrUpdateTimer(Sender: TObject);
begin
  btnSystemHelp.Left := pMainContainer.Width - btnSystemHelp.Width - 5;
  btnSystemHelp.Top := (pMainContainer.Height - btnSystemHelp.Height) div 2;
  pMainContainer.Repaint;
  tmrUpdate.Enabled := False;
end;

procedure TMAIN.tsAnexosDigClick(Sender: TObject);
begin
  FilterNoSource;
end;

procedure TMAIN.tsAnexosDigDblClick(Sender: TObject);
begin
  FilterNoSource;
end;

procedure TMAIN.tsAnexosDigEnter(Sender: TObject);
begin
  FilterNoSource;
end;

procedure TMAIN.tsAnexosDigShow(Sender: TObject);
begin
  FilterNoSource;
end;

procedure TMAIN.tsFuentesClick(Sender: TObject);
begin
  FilterSource
end;

procedure TMAIN.tsFuentesEnter(Sender: TObject);
begin
  FilterSource;
end;

procedure TMAIN.tsFuentesShow(Sender: TObject);
begin
  FilterSource
end;

procedure TMAIN.cxDBTreeList2DblClick(Sender: TObject);
var
  pathfile: string;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin                                                                                                                 //nombre
  pathfile := UDM.qryAnexosDig.FieldByName('urlraiz').AsString + UDM.qryAnexosDig.FieldByName('path').AsString + UDM.qryAnexosDig.FieldByName('nombre').AsString;
  if FileExists(pathfile) then
    ejecutaPDF(pathfile);
end;

procedure TMAIN.cxDBVerticalGrid2observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  EsReadOnly := True;
  CampoTexto(@UDM.dsSudSDetail, 'observacion', 'Observaciones sobre la serie ' + UDM.SudSDetail.FieldByName('subserie').AsString);
  EsReadOnly := False;
end;

procedure TMAIN.cxDBVerticalGrid3Editing(Sender: TObject; ARowProperties: TcxCustomEditorRowProperties; var Allow: Boolean);
begin
  FilaSel := ARowProperties.ID + 6;
end;

procedure TMAIN.cxDBVerticalGrid3observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.tb_Serietree.FieldByName('observacion').Value = null) or (trim(UDM.tb_Serietree.FieldByName('observacion').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  NombreSerieDocAsig := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  CampoTexto(@UDM.dstb_Serietree, 'observacion', 'Observaciones sobre la serie ' + NombreSerieDocAsig);
end;

procedure TMAIN.cxDBVerticalGrid5DescripcionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (cmdArch.FieldByName('descripcion').Value = null) or (trim(cmdArch.FieldByName('descripcion').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  NombreSerieDocAsig := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  EsPropiedadesTopo := True;
  CampoTexto(@dscmdArch, 'descripcion', 'Observaciones de la serie documental ' + NombreSerieDocAsig);
  EsPropiedadesTopo := False;
end;

procedure TMAIN.cxDBVerticalGridClick(Sender: TObject);
var
  ComboBox: TcxComboBoxProperties;
  FocusedRow: TcxCustomRow;
  FieldName: string;
begin
  ComboBox := TcxComboBoxProperties(Sender);
  FocusedRow := cxDBVerticalGrid3.FocusedRow;

  FocusedRow := cxDBVerticalGrid3.FocusedRow; // Obtener la fila enfocada
  if FocusedRow is TcxDBEditorRow then
  begin
    FilaSel := TcxDBEditorRow(FocusedRow).Properties.ItemIndex + 6;
  end;
end;

procedure TMAIN.cxEditRepository1ButtonItem2PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  NombreSerieDocAsig := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  CampoTexto(@UDM.dstb_SeriesDatos, 'observaciones', 'Observaciones de la serie documental ' + NombreSerieDocAsig);
end;

procedure TMAIN.cxGrid2DBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  NombreCamp: string;
begin
{  if (ansilowercase(udm.Rol) = 'administrador') or (ansilowercase(udm.Rol) = 'gestor') or (ansilowercase(udm.Rol) = 'director') then
  begin
    NombreCamp := TcxGridDBColumn(ACellViewInfo.Item).DataBinding.FieldName;
    if (NombreCamp = 'IDExpediente') and (trim(UDM.tb_SeriesDatos.FieldByName('subexp').AsString) = '') then
    begin
  // Verificar si el usuario tiene un rol autorizado
      if not IsUserAuthorized(UDM.Rol) then
      begin
        UDM.sms('No tiene permisos para realizar esta acción. Solo los roles administrador, gestor o director pueden consultar expedientes.', 2);
        Exit;
      end;
    // Verificar si el documento tiene datos topográficos
      if not HasTopographicData(UDM.tb_SeriesDatos) then
      begin
        UDM.sms('No se puede agregar expedientes porque el documento no tiene especificados los datos topográficos (Servidor, Archivo, depósito, gaveta o posición).', 2);
        Exit;
      end;
      jvcpExpediente.Visible := True;
      jvcpExpediente.BringToFront;
    end;
  end;  }
end;

procedure TMAIN.cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  PMManagementFileSubSerie.PopupAtCursor;
 { case AButtonIndex of
    0:
      MenuItem5Click(Sender);
    1:
      mGestionarContentFileClick(Sender);
    2:
      MenuItem11Click(Sender);
  end;  }
end;

procedure TMAIN.cxGrid2DBTableView1GetCellHeight(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; ACellViewInfo: TcxGridTableDataCellViewInfo; var AHeight: Integer);
begin
  // Ajusta la altura de la celda según VisibleLineCount
  if AItem = cxGrid2DBTableView1titulodoc then
    AHeight := cxSpinEdit1.Value * BaseLineHeight;
end;

/// <summary>
/// Maneja el evento de clic en el botón del campo IDExpediente en el cxGrid2DBTableView1.
/// Permite consultar o gestionar expedientes en una subserie, mostrando un panel de expedientes si las condiciones se cumplen.
/// </summary>
/// <param name="Sender">El objeto que desencadenó el evento (TcxCustomGridTableItem).</param>
/// <param name="AButtonIndex">El índice del botón clicado (0 para el primer botón, 1 para el segundo, etc.).</param>
/// <remarks>
/// Este método realiza las siguientes acciones:
/// 1. Verifica si el usuario tiene un rol autorizado (administrador, gestor o director).
/// 2. Si el usuario está autorizado, activa los DataSet necesarios para consultar expedientes.
/// 3. Registra un log de la acción.
/// 4. Verifica si la subserie tiene documentos asociados.
/// 5. Valida que el documento tenga datos topográficos (deposito, gaveta, posicion).
/// 6. Si todas las condiciones se cumplen, muestra el panel de expedientes (jvcpExpediente).
/// Si alguna validación falla, se muestra un mensaje al usuario y se detiene el proceso.
/// </remarks>
/// <exception cref="Exception">
/// - Si ocurre un error al activar los DataSet o acceder a los campos.
/// </exception>
procedure TMAIN.cxGrid2DBTableView1StylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; var AStyle: TcxStyle);
begin
{// Determina si la fila es par o impar
  var IsEven: Boolean := (ARecord.Index mod 2 = 0);

  // Verifica si la columna 'fichero' está vacía (NULL o cadena vacía)
  if VarIsNull(ARecord.Values[cxGrid2DBTableView1fichero.Index]) or (ARecord.Values[cxGrid2DBTableView1fichero.Index] = '') then
  begin
    if IsEven then
      AStyle := Vacio // Estilo para fila par con fichero vacío
    else
      AStyle := VacioOdd; // Estilo para fila impar con fichero vacío
  end
  else
  begin
    if IsEven then
      AStyle := Lleno // Estilo para fila par con fichero no vacío
    else
      AStyle := LlenoOdd; // Estilo para fila impar con fichero no vacío
  end;  }
end;


{procedure TMAIN.cxGrid2DBTableView1IDExpedientePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if (ansilowercase(udm.Rol) = 'administrador') or (ansilowercase(udm.Rol) = 'gestor') or (ansilowercase(udm.Rol) = 'director') then
  begin
    UDM.tb_expxseries.Active := False;
    UDM.tb_expxtiposerie.Active := False;
    UDM.log('Consultando el expediente.', 14, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('Nombreestructura').AsString);
    UDM.tb_expxseries.Active := True;
    if UDM.tb_expxtiposerie.IsEmpty then
    begin
      UDM.sms('No ha agregado ningun documento a esta subserie por lo que su acción no ha reflejado ningun resultado.', 2);
      exit;
    end;
    UDM.tb_expxtiposerie.Active := True;
    jvcpExpediente.Visible := True;
  end;

end;}

procedure TMAIN.cxGrid4DBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  pathfile: string;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
//nombre
  btnExecuteSourceFileClick(Sender);
end;

procedure TMAIN.cxGrid4DBTableView1comentarioPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  NombreSerieDocAsig := UDM.tb_ssArchdigital.FieldByName('etiqueta').AsString;
  if NombreSerieDocAsig = '' then
    NombreSerieDocAsig := UDM.tb_ssArchdigital.FieldByName('nombre').AsString;
  CampoTexto(@UDM.dstb_ssArchdigital, 'comentario', 'Comentario sobre el fichero  ' + NombreSerieDocAsig);
end;

procedure TMAIN.cxGrid4DBTableView1DblClick(Sender: TObject);
var
  pathfile, Destino: string;
  bm: TBookmark;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  if cxPageControl1.ActivePageIndex = 0 then
  begin
    if UDM.qryFuentesDig.RecordCount <= 0 then
    begin
      UDM.sms('No existen Ficheros fuentes disponibles que puedan ser ejecutados.', 2);
      exit;
    end;

    pathfile := UDM.qryFuentesDig.FieldByName('urlraiz').AsString + UDM.qryFuentesDig.FieldByName('path').AsString + UDM.qryFuentesDig.FieldByName('nombre').AsString;
    pathfile := AnsiReplaceStr(pathfile, '\', '/');
    pathfile := AnsiReplaceStr(pathfile, '//', '/');
    Destino := PathTemp + UDM.qryFuentesDig.FieldByName('nombre').AsString;
    UDM.DownloadFileFromFTP(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, pathfile, Destino, UDM.cmdServer.FieldByName('puerto').AsInteger);
    if FileExists(Destino) then
   // ejecutaPDF(Destino)
      UDM.EjecutaFichero(Destino)
    else
      udm.sms('No se encontró el fichero "' + UDM.qryFuentesDig.FieldByName('nombre').AsString + '" en la ruta especificada.', 1);
  end
  else
  begin
    if UDM.qryAnexosDig.RecordCount <= 0 then
    begin
      UDM.sms('No existen anexos digitales disponibles que puedan ser ejecutados.', 2);
      exit;
    end;
    pathfile := UDM.qryAnexosDig.FieldByName('urlraiz').AsString + UDM.qryAnexosDig.FieldByName('path').AsString + UDM.qryAnexosDig.FieldByName('nombre').AsString;
    pathfile := AnsiReplaceStr(pathfile, '\', '/');
    pathfile := AnsiReplaceStr(pathfile, '//', '/');
    Destino := PathTemp + UDM.qryAnexosDig.FieldByName('nombre').AsString;
    if UDM.DownloadFileFromFTP(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, pathfile, Destino, UDM.cmdServer.FieldByName('puerto').AsInteger) then
    begin
      if FileExists(Destino) then
   // ejecutaPDF(Destino)
        UDM.EjecutaFichero(Destino)
      else
        udm.sms('No se encontró el fichero "' + UDM.qryAnexosDig.FieldByName('nombre').AsString + '" en la ruta especificada.', 1);
    end
    else
    begin
      udm.sms('No se pudo descargar el fichero "' + UDM.qryAnexosDig.FieldByName('nombre').AsString + '".', 1);
      exit
    end;
  end;
end;

procedure TMAIN.cxGrid5DBTableView1comentarioPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  NombreSerieDocAsig := UDM.tb_ssArchdigital.FieldByName('etiqueta').AsString;
  if NombreSerieDocAsig = '' then
    NombreSerieDocAsig := UDM.tb_ssArchdigital.FieldByName('nombre').AsString;
  CampoTexto(@UDM.dstb_ssArchdigital, 'comentario', 'Comentario sobre el fichero  ' + NombreSerieDocAsig);
end;

procedure TMAIN.cxGridDBColumn11PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  NombreSerieDocAsig := UDM.qryFuentesDig.FieldByName('etiqueta').AsString;
  if NombreSerieDocAsig = '' then
    NombreSerieDocAsig := UDM.qryFuentesDig.FieldByName('nombre').AsString;
  CampoTexto(@UDM.dsqryFuentesDig, 'comentario', 'Comentario sobre el fichero  ' + NombreSerieDocAsig);
end;

procedure TMAIN.cxGridDBTableView1CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  if (AnsiLowerCase(UDM.Rol).Trim = 'administrador') or (AnsiLowerCase(UDM.Rol).Trim = 'gestor') then
  begin
    if (UDM.tb_SeriesDatos.State <> dsEdit) and (UDM.tb_SeriesDatos.State <> dsInsert) then
      UDM.tb_SeriesDatos.Edit;
    UDM.tb_SeriesDatos.FieldByName('IDExpediente').AsString := UDM.tb_expxtiposerie.FieldByName('codigodoc').AsString;
    try
      UDM.tb_SeriesDatos.Post;
      UDM.sms('El expediente fue asignado exitosamente.', 3);
    except
      on E: EFDException do
      begin
        UDM.tb_SeriesDatos.Cancel;
        UDM.sms('No se pudo asignar el expediente seleccionado. Motivo: ' + E.Message, 1);
      end;
    end;
  end
  else
  begin
    UDM.sms('No tiene permisos suficientes para realizar la operación solicitada.', 3);
    Exit;
  end;
end;

procedure TMAIN.cxGridDBTableView1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 113 then
  begin
    btnExecuteSourceFileClick(Sender);
  end;
end;

procedure TMAIN.cxGridDBTableView2CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  pathfile: string;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin                                                                                                                 //nombre
  btnExecuteSourceFileClick(Sender);
end;

procedure TMAIN.cxGridDBTableView2comentarioPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  NombreSerieDocAsig := UDM.qryAnexosDig.FieldByName('etiqueta').AsString;
  if NombreSerieDocAsig = '' then
    NombreSerieDocAsig := UDM.qryAnexosDig.FieldByName('nombre').AsString;
  CampoTexto(@UDM.dsqryAnexosDig, 'comentario', 'Comentario sobre el fichero  ' + NombreSerieDocAsig);
end;

procedure TMAIN.cxPageControl1Change(Sender: TObject);
var
  nombretmptable: string;
  existe: Boolean;
begin
 // Si el TabSheet de variables está activo
//  tsVar.Visible:=False;
//  cxPageControl1.Pages
  if cxPageControl1.ActivePage = tsVar then
  begin
    nombretmptable := UDM.QuitaCaracter('md_' + UDM.SudSDetail.FieldByName('codserie').AsString + UDM.tb_SeriesDatos.FieldByName('codsubs').AsString);
    existe := UDM.TablaExiste(UDM.Conn, nombretmptable);
    if not existe then
      HandleSubserieChange;
  end
  else if cxPageControl1.ActivePage = nil then
  begin
    cxPageControl1.ActivePage := tsFuentes;
    Exit;
  end;
  ShowVariablesForSubserie;
//  UpdateVariablesDisplay;
  ApplyBestFit(cxDBVerticalGrid3);
end;

procedure TMAIN.cxPageControl2Change(Sender: TObject);
begin
  ShowVariablesForSubserie
//  UpdateVariablesDisplay;
end;

procedure TMAIN.cxSpinEdit1PropertiesChange(Sender: TObject);
begin
  // Ajusta el número de líneas visibles
  TcxMemoProperties(cxGrid2DBTableView1titulodoc.Properties).VisibleLineCount := cxSpinEdit1.Value;

  // Calcula la nueva altura de la fila y actualiza RowHeight
  cxGrid2DBTableView1.LayoutChanged;

end;

procedure TMAIN.cxTabSheet1Show(Sender: TObject);
begin
{  if UDM.tb_Serietree.MasterSource = nil then
  begin
    UDM.tb_tree.Active := True;
    udm.tb_Serietree.DisableControls;
    UDM.tb_tree.DisableControls;
    md_var.Active := False;
    UDM.tb_ssArchdigital.Active := False;
    UDM.tb_DocCoord.Active := False;
    UDM.tb_SeriesDatos.Active := False;
    udm.tb_Serietree.Active := False;
    UDM.tb_Serietree.MasterSource := udm.dstb_tree;
    UDM.tb_Serietree.MasterFields := 'IdEstructura;id';
    UDM.tb_Serietree.IndexFieldNames := 'IdEstructura;id;codsubs';
    udm.tb_Serietree.Active := True;
    UDM.tb_SeriesDatos.Active := True;
    UDM.tb_DocCoord.Active := True;
    UDM.tb_ssArchdigital.Active := True;
//    md_var.Active := True;
    UDM.tb_tree.EnableControls;
    udm.tb_Serietree.EnableControls;

  end;  }
end;

procedure TMAIN.D3Click(Sender: TObject);
begin
  with Tfrmdepuracion.create(nil) do
  begin
    try
      showmodal;
    finally
      free;
    end;
  end;
end;

destructor TMAIN.Destroy;
begin
  FreeAndNil(FEnlaceDocs);
  FComboBoxAssociations.Free; // Liberar la lista
  inherited Destroy;
end;

// Devuelve el Idresp (cl_Resp_Gest_Arch) del usuario, o -1 si no existe o la
// consulta falla (por ejemplo durante la carga inicial). Solo lo usa la regla
// heredada del gestor (modo Access).
function TMAIN.GetIdResp(aUser: string): Integer;
var
  cad: string;
begin
  // Obtiene el ID del responsable de gestión de archivos para un usuario dado
  Result := -1;
  try
    cad := UDM.Conn.ExecSQLScalar('SELECT cl_Resp_Gest_Arch.Idresp FROM cl_Resp_Gest_Arch WHERE lower(cl_Resp_Gest_Arch.usuario) = ' + QuotedStr(AnsiLowerCase(aUser)));
    Result := StrToInt(cad);
  except
    // Ignora errores silenciosamente, ya que puede fallar durante la carga inicial
  end;
end;

// Muestra u oculta los botones de agregar y quitar fuentes y archivos digitales.
procedure TMAIN.SetVisibilityForButtons(Visible: Boolean);
begin
  // Configura la visibilidad de los botones relacionados con fuentes y archivos digitales
  btnSourceFile.Visible := Visible;
  btnAddListSource.Visible := Visible;
  btnRemoveSourceFileList.Visible := Visible;
  btnDropSourceFile.Visible := Visible;
  btnaddfile.Visible := Visible;
  btnaddfilelist.Visible := Visible;
  btnRemoveFileList.Visible := Visible;
  btnremovefile.Visible := Visible;
end;

// Define los botones visibles del navegador de tb_SeriesDatos.
procedure TMAIN.SetDbNavigatorButtons(Buttons: TNavButtonSet);
begin
  // Configura los botones visibles del navegador de datos
  dbnSeriesDatos.VisibleButtons := Buttons;
end;

// Regla heredada del Gestor (modo Access, sin alcance): solo es efectiva si el
// usuario es el 'gestor' registrado en tb_Serietree para el nodo y la subserie.
// Puede eliminar hasta 5 dias despues de la fecha del documento.
procedure TMAIN.AplicarReglasGestorHeredado;
var
  DaysElapsed: Integer;
begin
  // Configura la interfaz para el rol 'gestor' según el usuario y los días transcurridos
  if UDM.tb_Serietree.FieldByName('gestor').IsNull then
    Exit;  // Sale silenciosamente si el campo 'gestor' es nulo

  if UDM.tb_Serietree.FieldByName('gestor').AsInteger = GetIdResp(UDM.UserName) then
  begin
    if UDM.tb_SeriesDatos.FieldByName('Fecha').IsNull then
    begin
      SetDbNavigatorButtons([nbFirst, nbPrior, nbNext, nbLast, nbCancel]);
      SetVisibilityForButtons(False);
      Exit;
    end;

    DaysElapsed := GetCantOfDay(UDM.tb_SeriesDatos.FieldByName('Fecha').AsDateTime);
    if DaysElapsed > 5 then
    begin
      SetDbNavigatorButtons([nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbPost, nbCancel]);
      SetVisibilityForButtons(False);
      JvTransparentButton5.Visible := True;
      btnViewtopoSS.Visible := True;
      mGestionarContentFile.Visible := True;
      Label11.Visible := False;
      lcbGestor.Visible := False;
    end
    else
    begin
      SetDbNavigatorButtons([nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbPost, nbCancel]);
      SetVisibilityForButtons(True);
      JvTransparentButton5.Visible := True;
      btnViewtopoSS.Visible := True;
      mGestionarContentFile.Visible := True;
      Label11.Visible := False;
      lcbGestor.Visible := False;
    end;
  end
  else
  begin
    SetDbNavigatorButtons([nbFirst, nbPrior, nbNext, nbLast, nbCancel]);
    SetVisibilityForButtons(False);
    JvTransparentButton5.Visible := False;
    mGestionarContentFile.Visible := False;
    btnViewtopoSS.Visible := False;
    Label11.Visible := False;
    lcbGestor.Visible := False;
  end;
end;

// Reglas heredadas por nombre de rol (archivero, gestor, director,
// administrador). Se usan en modo Access y para los roles que no dependen del
// alcance. En SQL Server, gestor y director pasan por AplicarReglasPorAlcance.
procedure TMAIN.AplicarReglasPorRolHeredado(Rol: string);
var
  DaysElapsed: Integer;
begin
  // Obtener el nivel de acceso para este formulario
  // Configura la interfaz según el rol del usuario
  if Rol = 'archivero' then
  begin
    SetDbNavigatorButtons([nbFirst, nbPrior, nbNext, nbLast, nbCancel]);
    SetVisibilityForButtons(False);
    JvTransparentButton5.Visible := False;
    btnViewtopoSS.Visible := False;
    mGestionarContentFile.Visible := False;
  end
  else if Rol = 'gestor' then
    AplicarReglasGestorHeredado
  else if Rol = 'director' then
  begin
    SetVisibilityForButtons(False);
    if UDM.tb_SeriesDatos.FieldByName('Fecha').IsNull then
    begin
      SetDbNavigatorButtons([nbFirst, nbPrior, nbNext, nbLast, nbCancel]);
      Exit;
    end;

    DaysElapsed := GetCantOfDay(UDM.tb_SeriesDatos.FieldByName('Fecha').AsDateTime);
    if DaysElapsed > 1 then
      SetDbNavigatorButtons([nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbPost, nbCancel])
    else
      SetDbNavigatorButtons([nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbPost, nbCancel]);
    MenuItem11.Visible := not (DaysElapsed > 1);
    JvTransparentButton5.Visible := False;
    btnViewtopoSS.Visible := False;
    mGestionarContentFile.Visible := not (DaysElapsed > 1);
  end
  else if Rol = 'administrador' then
  begin
    SetDbNavigatorButtons([nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbPost, nbCancel]);
    SetVisibilityForButtons(True);
    MenuItem11.Visible := True;
    JvTransparentButton5.Visible := True;
    btnViewtopoSS.Visible := True;
    mGestionarContentFile.Visible := True;
//      acceso := GlobalSecurity.GetAccess(UDM.Rol, Self.Name); // Self.Name es el nombre del formulario
//      GlobalSecurity.SetModuleSecurity(Self, acceso);
    Security.SetModSecurity(Self, 'acceso total');
  end;
end;

// Botones y menus del documento actual segun el alcance del usuario (SQL
// Server). Decide por nodo y subserie del registro actual de tb_Serietree:
//   - navegar y cancelar: siempre;
//   - insertar y guardar: si puede agregar o editar;
//   - borrar, botones de archivos y fuentes y el menu MenuItem11: si puede
//     eliminar (el EGD siempre; el Director solo el primer dia);
//   - topografia (JvTransparentButton5 y btnViewtopoSS): solo si puede
//     editarla (administrador o EGD del nodo);
//   - gestionar contenido (mGestionarContentFile): quien puede eliminar o
//     editar la topografia.
// Ya no consulta tb_Serietree.gestor, que queda como dato informativo.
procedure TMAIN.AplicarReglasPorAlcance;
var
  Nodo: TClaveNodo;
  CodSubs: string;
  Dias: Integer;
  PuedeAgregar, PuedeEditar, PuedeEliminar, PuedeTopografia: Boolean;
  Botones: TNavButtonSet;
begin
  Botones := [nbFirst, nbPrior, nbNext, nbLast, nbCancel];
  PuedeAgregar := False;
  PuedeEditar := False;
  PuedeEliminar := False;
  PuedeTopografia := False;
  if UDM.tb_Serietree.Active and not UDM.tb_Serietree.IsEmpty then
  begin
    Nodo.IdEstructura := UDM.tb_Serietree.FieldByName('IdEstructura').AsString;
    Nodo.Id := UDM.tb_Serietree.FieldByName('id').AsInteger;
    CodSubs := UDM.tb_Serietree.FieldByName('codsubs').AsString;
    if UDM.tb_SeriesDatos.FieldByName('Fecha').IsNull then
      Dias := 0
    else
      Dias := GetCantOfDay(UDM.tb_SeriesDatos.FieldByName('Fecha').AsDateTime);
    PuedeAgregar := UDM.Alcance.PuedeRealizar(acAgregar, Nodo, CodSubs);
    PuedeEditar := UDM.Alcance.PuedeRealizar(acEditar, Nodo, CodSubs);
    PuedeEliminar := UDM.Alcance.PuedeEliminarDocumento(Nodo, CodSubs, Dias);
    PuedeTopografia := UDM.Alcance.PuedeRealizar(acEditarTopografia, Nodo, CodSubs);
  end;
  if PuedeAgregar then
    Include(Botones, nbInsert);
  if PuedeAgregar or PuedeEditar then
    Include(Botones, nbPost);
  if PuedeEliminar then
    Include(Botones, nbDelete);
  SetDbNavigatorButtons(Botones);
  SetVisibilityForButtons(PuedeEliminar);
  MenuItem11.Visible := PuedeEliminar;
  JvTransparentButton5.Visible := PuedeTopografia;
  btnViewtopoSS.Visible := PuedeTopografia;
  mGestionarContentFile.Visible := PuedeEliminar or PuedeTopografia;
end;

// Punto unico que configura los controles del documento actual segun el
// usuario. Administrador, archivero y visor (y todos en modo Access, sin
// alcance) siguen la regla heredada por rol. Con alcance (SQL Server) el
// director sigue las reglas de UAlcance, y el gestor tambien una vez que es EGD
// de algun nodo; mientras no lo sea conserva la regla heredada del gestor.
procedure TMAIN.AplicarReglasDocumento;
var
  Rol: string;
begin
  Rol := AnsiLowerCase(UDM.Rol);
  if (UDM.Alcance <> nil) and ((Rol = 'director') or
    ((Rol = 'gestor') and UDM.Alcance.EsEGDDeAlgunNodo)) then
    AplicarReglasPorAlcance
  else
    AplicarReglasPorRolHeredado(Rol);
end;

procedure TMAIN.dstb_SeriesDatosDataChange(Sender: TObject; Field: TField);
var
  CantDoc: integer;

  procedure UpdateVariablesView;
  begin
    // Actualiza la vista de variables según la subserie
    gVariablesDetail.Visible := False;
    if UDM.tb_Serietree.FieldByName('codsubs').IsNull then
      Exit;  // Sale silenciosamente si 'codsubs' es nulo

    VarCL.Active := False;
    VarCL.SQL.Clear;
    VarCL.SQL.Add(CargarVariablesSubserie(UDM.tb_Serietree.FieldByName('codsubs').AsString));
    try
      VarCL.Open();
      gVariablesDetail.Visible := VarCL.RecordCount > 0;
    except
      on E: EFDException do
      begin
        // Muestra un mensaje de error solo si falla la consulta por un motivo inesperado
        UDM.sms('No se pudo consultar la definición de variables de la subserie actual. Motivo: ' + E.Message, 1);
        Exit;
      end;
    end;
  end;

  procedure UpdateTabVisibility;
  var
    tiene: string;
  begin
    // Actualiza la visibilidad de las pestañas y grids según el estado de los datos
    if (trim(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString) <> '') then
    begin

      tiene := VarToStr(UDM.Conn.ExecSQLScalar('SELECT cl_subseries.NombreTablaMetadatos FROM cl_subseries WHERE codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString)));
      tsVar.TabVisible := False;
      if tiene.Trim <> '' then
      begin
        if UDM.tb_SeriesDatos.RecordCount > 0 then
          tsVar.TabVisible := True
        else
          tsVar.TabVisible := False;
      end;
      if UDM.SudSDetail.Active and not UDM.SudSDetail.FieldByName('espacial').IsNull then
        tsCoord.TabVisible := (Trim(UDM.SudSDetail.FieldByName('espacial').AsString) = 'S')
      else
        tsCoord.TabVisible := False;

      cxPageControl1.Visible := True; // Ahora es seguro hacer visible el control de pestañas
    end;
  end;

  procedure UpdateSubserieDetails;
  begin
    // Actualiza los detalles de la subserie y la interfaz
    pVerticalTitle.Caption := ' Subserie: ';
    if UDM.tb_SeriesDatos.FieldByName('codsubs').IsNull then
    begin
      pVerticalTitle.Caption := ' << SIN DOCUMENTOS >>';
      Timer2.Enabled := True;
      pVerticalTitle.Font.Color := $00362077;
      pVerticalTitle.Font.Style := [fsBold];
      Exit;
    end;

    CantDoc := UDM.Conn.ExecSQLScalar('SELECT count(subserie) AS cantidad FROM cl_subseries WHERE codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString));
    if CantDoc <= 0 then
    begin
      pVerticalTitle.Caption := ' << SIN DOCUMENTOS >>';
      Timer2.Enabled := True;
      pVerticalTitle.Font.Color := $00362077;
      pVerticalTitle.Font.Style := [fsBold];
      Exit;
    end;

    Timer2.Enabled := False;
    pVerticalTitle.Color := $00F0CAAE;
    pVerticalTitle.Font.Color := $0050370A;
    pVerticalTitle.Font.Style := [fsBold];
    pVerticalTitle.Caption := ' Subserie: ' + VarToStr(UDM.Conn.ExecSQLScalar('SELECT subserie FROM cl_subseries WHERE codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString)));
  end;

  procedure ConfigureInitialUI;
  begin
    // Configura la interfaz inicial según el rol del usuario
    if EstoyActualizando then
      Exit;

    // Obtener el nivel de acceso para este formulario
    Security.SetModSecurity(Self, acceso);

{    if (RolLower = 'administrador') or (RolLower = 'gestor') then
      acceso := 'acceso total'
    else
      acceso := 'solo lectura';

    if Trim(acceso) = '' then
      acceso := 'solo lectura';

    Security.SetModSecurity(Self, acceso);  }
    Label11.Visible := True;
    lcbGestor.Visible := True;
    AplicarReglasDocumento;
  end;

  procedure RefreshGrid;
  begin
    cxGrid2DBTableView1.BeginUpdate;
    try
      //cxGrid2DBTableView1.DataController.Refresh;
      if cxGrid2.CanFocus then
        cxGrid2.SetFocus;
    finally
      cxGrid2DBTableView1.EndUpdate;
      cxGrid2DBTableView1.Invalidate;
    end;
  end;

begin
  UDM.Conn.ResourceOptions.SilentMode := True; // Desactiva cambios automáticos de cursor
//  UDM.Conn.ResourceOptions.WaitCursor := crDefault; // Fuerza crDefault si se muestra un cursor
  try
    // Configura el valor inicial del control de edición
    cxSpinEdit1.Value := TcxMemoProperties(cxGrid2DBTableView1titulodoc.Properties).VisibleLineCount;
//
//    cxGrid2DBTableView1.Invalidate;
    ConfigureInitialUI;
    UpdateVariablesView;
    UpdateSubserieDetails;
    UpdateTabVisibility;
//    RefreshGrid;
    ApplyBestFit(cxDBVerticalGrid3);
//    cxGrid2DBTableView1.Invalidate;
  finally
    UDM.Conn.ResourceOptions.SilentMode := False; // Desactiva cambios automáticos de cursor
//    UDM.Conn.ResourceOptions.WaitCursor := crSQLWait; // Fuerza crDefault si se muestra un cursor
  end;
end;


procedure TMAIN.dstb_SerietreeDataChange(Sender: TObject; Field: TField);
var
  aNombre: string;
  CantDoc: Integer;
  HasVariables: Boolean;

  procedure PrepareViews;
  begin
    // Sale si está actualizando o prepara las vistas si no hay edición/inserción
    if EstoyActualizando then
      Exit;
    if (UDM.tb_tree.State in [dsInsert, dsEdit]) or (UDM.tb_Serietree.State in [dsInsert, dsEdit]) then
      Exit;

    PrepareSSDisp;
    PrepareSSDetailView;
    PrepareServerDetailView;
    ArchivoActual;
  end;

  procedure UpdateCoordinateTab;
  begin
    // Controla la visibilidad de la pestaña de coordenadas según el campo 'espacial'
    if UDM.SudSDetail.Active then
      tsCoord.TabVisible := (Trim(UDM.SudSDetail.FieldByName('espacial').AsString) = 'S')
    else
      tsCoord.TabVisible := False;
  end;

  procedure LoadDocumentCount;
  begin
    // Obtiene la cantidad de documentos asociados a la subserie actual
    CantDoc := 0;
    try
      CantDoc := UDM.Conn.ExecSQLScalar('SELECT COUNT(subserie) AS cantidad FROM cl_subseries WHERE codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString));
    except
      on E: Exception do
      begin
        UDM.sms('Error al obtener la cantidad de documentos: ' + E.Message, 1);
        CantDoc := 0;
      end;
    end;
  end;

  function CheckIfSeriesHasVariables: Boolean;
  begin
    // Verifica si la subserie actual tiene variables asociadas
    Result := False;
    try
      if Trim(UDM.tb_Serietree.FieldByName('codsubs').AsString) <> '' then
      begin
        // Asumimos que las variables están en una tabla 'cl_VarSubserie' relacionada con 'codsubs'
        Result := UDM.Conn.ExecSQLScalar('SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)) > 0;
      end;
    except
      on E: Exception do
      begin
        UDM.sms('Error al verificar variables de la subserie: ' + E.Message, 1);
        Result := False;
      end;
    end;
  end;

  procedure UpdateVariablesTab;
  begin
    // Verifica si la subserie tiene variables
    HasVariables := CheckIfSeriesHasVariables;

    // Si el tab de variables está activo y la subserie tiene variables, lo dejamos visible y activo
    if Assigned(cxPageControl1) and Assigned(tsVar) and Assigned(tsFuentes) then
    begin
      if (cxPageControl1.ActivePage = tsVar) and HasVariables then
      begin
        tsVar.TabVisible := True;
        // Aseguramos que el page control y sus padres estén visibles
        if Assigned(cxPageControl1.Parent) then
          cxPageControl1.Parent.Visible := True;
        cxPageControl1.Visible := True;
        cxPageControl1.ActivePage := tsVar;
      end
      else
      begin
        // Si no hay variables o el tab de variables no está activo, lo ocultamos y mostramos el tab de fuentes
        tsVar.TabVisible := False;
        cxPageControl1.ActivePage := tsFuentes;
      end;
    end;

    // Actualiza las variables y ajusta la cuadrícula vertical
    ShowVariablesForSubserie;
    ApplyBestFit(cxDBVerticalGrid3);
  end;

  procedure UpdateTitle;
  begin
    // Actualiza el título vertical según la cantidad de documentos y el nombre de la subserie
    if CantDoc <= 0 then
    begin
      pVerticalTitle.Caption := ' << No existen series definidas >>';
      Exit;
    end;

    try
      aNombre := VarToStr(UDM.Conn.ExecSQLScalar('SELECT subserie FROM cl_subseries WHERE codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
      if Trim(aNombre) <> '' then
        pVerticalTitle.Caption := 'Subserie: ' + AnsiQuotedStr(aNombre, '"');
//        pVerticalTitle.Caption := pVerticalTitle.Caption + AnsiQuotedStr(aNombre, '"');
    except
      on E: Exception do
      begin
        UDM.sms('Error al actualizar el título: ' + E.Message, 1);
        pVerticalTitle.Caption := ' << ERROR AL CARGAR TÍTULO >>';
      end;
    end;
  end;

begin
  // Primer try-finally para garantizar que el cursor se restaure siempre
    // Muestra el cursor de espera mientras se procesan los cambios de datos
  UDM.Conn.ResourceOptions.SilentMode := True; // Desactiva cambios automáticos de cursor
//  UDM.Conn.ResourceOptions.WaitCursor := crDefault; // Fuerza crDefault si se muestra un cursor
  // ... resto de la inicialización ...
  try
    // Segundo try-except para manejar excepciones
    try
      // Ejecuta las actualizaciones necesarias

      PrepareViews;
      UpdateCoordinateTab;
      LoadDocumentCount;
      UpdateVariablesTab;
      UpdateTitle;
    except
      {on E: Exception do
      begin
        ShowMessage('Error en series asignadas: ' + E.Message);
      end;}
    end;

  finally
    // Restaura el cursor predeterminado al finalizar
    UDM.Conn.ResourceOptions.SilentMode := False; // Desactiva cambios automáticos de cursor
//    UDM.Conn.ResourceOptions.WaitCursor := crSQLWait; // Fuerza crDefault si se muestra un cursor
  // ... resto de la inicialización ...
  end;
end;

{procedure TMAIN.dstb_SerietreeDataChange(Sender: TObject; Field: TField);
var
  aNombre: string;
  CantDoc: integer;

  procedure PrepareViews;
  begin
    // Sale si está actualizando o prepara las vistas si no hay edición/insersión
    if EstoyActualizando then
      Exit;
    if (UDM.tb_tree.State <> dsInsert) and (UDM.tb_tree.State <> dsEdit) and (UDM.tb_Serietree.State <> dsInsert) and (UDM.tb_Serietree.State <> dsEdit) then
    begin
      PrepareSSDisp;
      PrepareSSDetailView;
      PrepareServerDetailView;
      ArchivoActual;
    end;
  end;

  procedure UpdateCoordinateTab;
  begin
    // Controla la visibilidad de la pestaña de coordenadas según el campo 'espacial'
    if UDM.SudSDetail.Active then
      tsCoord.TabVisible := (Trim(UDM.SudSDetail.FieldByName('espacial').AsString) <> '') and (Trim(UDM.SudSDetail.FieldByName('espacial').AsString) = 'S')
    else
      tsCoord.TabVisible := False;
  end;

  procedure LoadDocumentCount;
  begin
    // Obtiene la cantidad de documentos asociados a la subserie actual
    CantDoc := 0;
    CantDoc := UDM.Conn.ExecSQLScalar('SELECT COUNT(subserie) AS cantidad FROM cl_subseries WHERE codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString));
  end;

  procedure UpdateUIElements;
  begin
    // Actualiza las variables y ajusta la cuadrícula vertical
    ShowVariablesForSubserie;
    ApplyBestFit(cxDBVerticalGrid3);

    // Oculta la pestaña de variables y cambia a la pestaña de fuentes si no hay código de subserie
    if Trim(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString) = '' then
    begin
      tsVar.TabVisible := False;
      cxPageControl1.ActivePage := tsFuentes;
    end;
  end;

  procedure UpdateTitle;
  begin
    // Actualiza el título vertical según la cantidad de documentos y el nombre de la subserie
    if CantDoc <= 0 then
    begin
      pVerticalTitle.Caption := ' << SIN DOCUMENTOS >>';
      Exit;
    end;

    aNombre := VarToStr(UDM.Conn.ExecSQLScalar('SELECT subserie FROM cl_subseries WHERE codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
    if Trim(aNombre) <> '' then
      pVerticalTitle.Caption := pVerticalTitle.Caption + AnsiQuotedStr(aNombre, '"');
  end;

begin
  try
    // Muestra el cursor de espera mientras se procesan los cambios de datos
    Screen.Cursor := crHourGlass;

    PrepareViews;
    UpdateCoordinateTab;
    LoadDocumentCount;
    UpdateUIElements;
    UpdateTitle;

  finally
    // Restaura el cursor predeterminado al finalizar
    Screen.Cursor := crDefault;
  end;
end;   }
{var
  aNombre: string;
  CantDoc: integer;
  cad, serie, subserie: string;
begin
  if EstoyActualizando then
    Exit;
  if (UDM.tb_tree.State <> dsInsert) and (UDM.tb_tree.State <> dsEdit) and (UDM.tb_Serietree.State <> dsInsert) and (UDM.tb_Serietree.State <> dsEdit) then
  begin
    PrepareSSDisp;
    PrepareSSDetailView;
    PrepareServerDetailView;
    ArchivoActual;
  end;
  if UDM.SudSDetail.Active then
    if (trim(UDM.SudSDetail.FieldByName('espacial').AsString) <> '') and (trim(UDM.SudSDetail.FieldByName('espacial').AsString) = 'S') then
    begin
      tsCoord.TabVisible := True
    end
    else
      tsCoord.TabVisible := False;
  CantDoc := 0;
  CantDoc := UDM.Conn.ExecSQLScalar('select count(subserie) as cantidad from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString));
  ShowVariablesForSubserie;
//  UpdateVariablesDisplay;
  ApplyBestFit(cxDBVerticalGrid3);

  if trim(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString) = '' then
  begin
    tsVar.TabVisible := False;
    cxPageControl1.ActivePage := tsFuentes;
  end;
  if CantDoc <= 0 then
  begin
    pVerticalTitle.Caption := ' << SIN DOCUMENTOS >>';
//    GViewSeries.Views[0].EndUpdate;
    Exit;
  end;

  aNombre := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  if trim(aNombre) <> '' then
    pVerticalTitle.Caption := pVerticalTitle.Caption + AnsiQuotedStr(aNombre, '"');
  Screen.Cursor := crDefault;
end;  }

procedure TMAIN.E1Click(Sender: TObject);
begin
 { with TfrmListEspec.Create(NIL) do
  try
    ShowModal;
  finally
    Free;
  end; }
end;

procedure TMAIN.E2Click(Sender: TObject);
begin
  if UDM.sms('¿Realmente desea eliminar el contenido del campo actual?', 4) = 6 then
  begin
    UDM.tb_SeriesDatos.Edit;
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).Clear;
    UDM.tb_SeriesDatos.Post;
  end;
end;

procedure TMAIN.edtFillExpChange(Sender: TObject);

  procedure ApplyFilter(aTable: TFDQuery; const FilterFields: array of string; const EditText: string; const IsSQLServer: Boolean);
  var
    FilterExpression: string;
    i: Integer;
    LowerCaseFunction: string;
  begin
  // Determinar la función de conversión a minúsculas según el SGBD
    if IsSQLServer then
      LowerCaseFunction := 'LOWER'
    else
      LowerCaseFunction := 'LCASE';

  // Refresco de la tabla
    aTable.Refresh;

  // Inicialización de la cadena de filtro
    FilterExpression := '';

  // Verificación del texto de búsqueda
    if Trim(EditText) = '' then
    begin
    // Si el campo de búsqueda está vacío, se deshabilita el filtro
      aTable.Filter := '';
      aTable.Filtered := False;
    end
    else
    begin
    // Construcción de la expresión de filtro
      for i := Low(FilterFields) to High(FilterFields) do
      begin
        if FilterExpression <> '' then
          FilterExpression := FilterExpression + ' OR ';
        FilterExpression := FilterExpression + LowerCaseFunction + '(' + FilterFields[i] + ') LIKE ' + QuotedStr('%' + AnsiLowerCase(EditText) + '%');
      end;

    // Aplicación del filtro
      with aTable do
      begin
        Prepare;
        Filtered := False;
        Filter := FilterExpression;
        Filtered := True;
      end;
    end;
  end;

var
  FilterFields: array of string;
  IsSQLServer: Boolean;
begin
  SetLength(FilterFields, 3);
  FilterFields[0] := 'titulodoc';
  FilterFields[1] := 'codigodoc';
  FilterFields[2] := 'codsubs';
  IsSQLServer := True;
  if TBD = 'A' then
    IsSQLServer := False;
  ApplyFilter(UDM.tb_expxtiposerie, FilterFields, edtFillExp.Text, IsSQLServer);
end;

procedure TMAIN.edtCarpetaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if (trim(UDM.tb_Serietree.FieldByName('Idservidor').AsString) = '') or (UDM.tb_Serietree.FieldByName('Idservidor').Value = null) then
  begin
    UDM.sms('Debe especificar un servidor valido antes de continuar.', 3);
    Exit;
  end;

  //edt1.Text := UDM.tb_Serietree.FieldByName('carpeta').AsString;
  //cpInfoPathSubSeries.Visible := True;
end;

procedure TMAIN.edtFillChange(Sender: TObject);
begin
  if length(TEdit(Sender).Text) = 0 then
    btnquickFillClick(Sender);
end;

procedure TMAIN.edtFillKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
    btnquickFillClick(Sender);
end;

procedure TMAIN.edtObsPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  NombreSerieDocAsig := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  EsPropiedadesTopo := True;
  CampoTexto(@UDM.dstb_Serietree, 'observacion', 'Observaciones sobre la serie ' + NombreSerieDocAsig);
  EsPropiedadesTopo := False;
end;

procedure TMAIN.P1Click(Sender: TObject);
begin
  with TfrmDoc.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.P2Click(Sender: TObject);
begin
  if AnItem = nil then
  begin
    udm.sms('Debe seleccionar un nodo válido.', 3);
    Exit
  end;
  with TfrmNodeInfo.Create(nil) do
  try
    cmdNodeInfo.Active := True;

    cmdNodeInfo.Locate('IdEstructura;ID', VarArrayOf([PDataRec(AnItem.data).estruct, PDataRec(AnItem.data).id]), []);
    Caption := 'Información de ' + AnItem.Text;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.P3Click(Sender: TObject);
begin
  Prestamos;
end;

procedure TMAIN.pArchivoDigCanResize(Sender: TObject; var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
  ApplyBestFit(cxDBVerticalGrid3);
end;

procedure TMAIN.pArchivoDigNodeCollapse(Sender: TObject; SectionIndex: Integer);
begin
  ApplyBestFit(cxDBVerticalGrid3);
end;

procedure TMAIN.pArchivoDigNodeExpand(Sender: TObject; SectionIndex: Integer);
begin
  ApplyBestFit(cxDBVerticalGrid3);
end;

procedure TMAIN.Permisos(Opts: string);
begin
  //F is full access...
  if Opts = 'F' then
  begin
  end
  else
  begin

  end;
end;

procedure TMAIN.PLADClick(Sender: TObject);
begin
  if advtpDetalle.Visible then
  begin

    advtpDetalle.Panels[advtpDetalle.PanelIndex(pArchivoDig)].Visible := True;
    advtpDetalle.Panels[advtpDetalle.PanelIndex(pArchivoDig)].Panel.Show;
    advtpDetalle.Panels[advtpDetalle.PanelIndex(pArchivoDig)].Panel.Locked := True;
    advtpDetalle.Panels[advtpDetalle.PanelIndex(pArchivoDig)].Panel.Parent := advtpDetalle;
    {AdvToolPanel1.Visible := True;
    AdvToolPanel1.Locked := True;
    AdvToolPanel1.Show;}
  end;
end;

procedure TMAIN.plazoretencionClick(Sender: TObject);
begin
  UDM.MostrarReporte('PlazoRetencion');
end;
{begin
//te puse esto en cada item del popupmenu, la unica diferencia es que se le pasa el nobre de reporte diferente, se puede mejorar el codigo pero bueno
  if ((Trim(UDM.tb_sysconfig.FieldByName('empresa').AsString) <> '') and (not TBlobField(UDM.tb_sysconfig.FieldByName('logo')).IsNull)) then
  begin
     //descargo el logo para la carpeta 'Report\logo.png'
    UDM.log('Visualizando el reporte de tablas de retención documental.', 14, '', '', '');
    TBlobField(UDM.tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
    CargaReporte(frxMain, pathreport + 'rPlazoRetencion.fr3', 'empresa', UDM.tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png');
  end
  else
  begin
    MessageDlg('Debe configurar losDatos de la Empresa. Dirijase a la configuración del Sistema.', mtError, [mbOK], 0);
  end;
end;
}

procedure TMAIN.PLCCClick(Sender: TObject);
begin
  if advtpCC.Visible then
  begin
    advtpCuadroClasif.Visible := True;
    advtpCuadroClasif.Locked := True;
    advtpCuadroClasif.Show;
  end;
end;

procedure TMAIN.PLDSClick(Sender: TObject);
begin
  if advtpDetalle.Visible then
  begin
    advtpDetail.Visible := True;
    advtpDetail.Locked := True;
    advtpDetail.Show;
  end;
end;

procedure TMAIN.PLSDClick(Sender: TObject);
begin
 { if advtpDetalle.Visible then
  begin
    advtpSSDispo.Visible := True;
    advtpSSDispo.Locked := True;
    advtpSSDispo.Show;
  end;   }
end;

procedure TMAIN.PrepareServerDetailView;

  procedure ConfigureServerQuery;
  begin
    // Sale si está actualizando
    if EstoyActualizando then
      Exit;

    // Desactiva los controles y prepara la consulta
    ViewServerDetail.DisableControls;
    ViewServerDetail.Active := False;
    ViewServerDetail.Connection := UDM.Conn;

    // Asigna el parámetro para la consulta
    ViewServerDetail.Params[0].Value := UDM.tb_Serietree.FieldByName('idservidor').Value;
  end;

  procedure ExecuteServerQuery;
  begin
    // Activa la consulta y obtiene todos los datos
    ViewServerDetail.Active := True;
    ViewServerDetail.FetchAll;
  end;

begin
  try
    ConfigureServerQuery;
    ExecuteServerQuery;
  except
    on E: EFDException do
    begin
      // Muestra un mensaje de error si falla la consulta
      udm.sms('No se pueden consultar los detalles del repositorio de datos. Motivo: ' + E.Message, 1);
    end;
  end;

  // Restaura los controles al finalizar
  ViewServerDetail.EnableControls;
end;
{begin
  if EstoyActualizando then
    Exit;
  ViewServerDetail.DisableControls;
  try
    ViewServerDetail.Connection := UDM.Conn;
    ViewServerDetail.Active := False;
    ViewServerDetail.Params[0].Value := UDM.tb_Serietree.FieldByName('idservidor').Value;
    ViewServerDetail.Active := True;
    ViewServerDetail.FetchAll;
    ViewServerDetail.EnableControls;
  except
    on E: EFDException do
    begin
      udm.sms('No se pueden cosultar los detalles del repositorio de datos. Motivo: ' + e.Message, 1);
    end;
  end;
  //              exit;
end; }

procedure TMAIN.pmtvResetClick(Sender: TObject);
begin
  if UDM.sms('¿Realmente restablecer la fuente por defecto en el árbol del Cuadro de Clasificación Documental (CCD)?', 4) = 6 then
  begin
    LoadTreeViewFont(tvtree, PathSys + '\Resources\tvtree.ini');
  end;
{  PContainer.Visible := False;
  with TfrmRepActArch.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
  PContainer.Visible := True;  }

end;

procedure TMAIN.Rellena;
var
  i: integer;
  Qcl_Varsubserie: TFDQuery;
  vs: string;
  vtipo: TFieldType;
  LEN: INTEGER;

  procedure abrirTabla(DS: TDataset);
  begin
    if not DS.active then
      DS.active := true;
  end;

begin
 { //UDM.tb_SeriesDatos.DisableControls;
  salvo := false;
 //********************Abrit las tablas*****************************************
  AbrirTabla(UDM.tb_SeriesDatos);
  AbrirTabla(UDM.cl_subseries);
  Qcl_Varsubserie := TFDQuery.create(self);
  with Qcl_Varsubserie do
  begin
    Active := False;
    Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('select * from cl_varsubserie where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.fieldbyname('codsubs').asstring));
    SQL.Add(' order by codsubs, orden');
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo acceder al listado de variables asignadas a esta serie. Por favor intentelo de nuevo.', 1);
        Exit;
      end;
    end;

  end;
  varUltimoQuery := '';
  OcultaVGVardef;
  i := 1;
  cxDBVerticalGrid1.DataController.DataSource := UDM.dtb_VirtualVar;
  UDM.tb_SerieDatosVar.DisableControls;
  while not UDM.tb_SerieDatosVar.Eof do
  begin
    s := 'iv' + inttostr(i);
    if UDM.cl_Variables.Locate('idvar', UDM.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
    begin
      TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := UDM.cl_Variables.fieldbyname('NomVariable').asstring;
      TcxDBEditorRow(FindComponent(s)).Properties.Caption := UDM.cl_Variables.fieldbyname('Etiqueta').AsString;
      TcxDBEditorRow(FindComponent(s)).Index := i + 11;
      TcxDBEditorRow(FindComponent(s)).Visible := true;
      s := uppercase(UDM.cl_Variables.fieldbyname('tipo').AsString);
      LEN := UDM.cl_Variables.fieldbyname('LONGITUD').AsInteger;
      if s = 'ENTERO' then
      begin
        vtipo := ftsmallint;
        LEN := 0;
      end
        vtipo := ftfloat;
        LEN := 0;
      end
      else if s = 'FECHA' then
      begin
        vtipo := ftdate;
        LEN := 0;
      end
      else
      begin
        vtipo := ftSTRING;
        if (UDM.cl_Variables.fieldbyname('longitud').Value = NULL) or (UDM.cl_Variables.fieldbyname('longitud').Value = 0) then
          LEN := 255;
      end;
      UDM.tb_VirtualVar.FieldDefs.Add(UDM.cl_Variables.fieldbyname('NomVariable').asstring, vtipo, LEN);
    end;
    i := i + 1;
    UDM.tb_SerieDatosVar.Next;
  end;
 //------------------------------------------------------------------------------

  UDM.tb_VirtualVar.CreateDataSet;
  if not UDM.tb_VirtualVar.active then
    UDM.tb_VirtualVar.Active := true;
 //**************** Adicionar los valores ***************************************
  UDM.tb_SerieDatosVar.First;
  while not UDM.tb_SerieDatosVar.eof do
  begin
    if UDM.cl_Variables.Locate('idvar', UDM.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
    begin
      s := uppercase(UDM.cl_Variables.fieldbyname('tipo').asstring);
      if s = 'ENTERO' then
        vs := 'VarInteger'
      else if s = 'REAL' then
        vs := 'VarDouble'
      else if s = 'FECHA' then
        vs := 'VarDate'
      else
        vs := 'VarString255';
      UDM.tb_VirtualVar.edit;
      UDM.tb_VirtualVar.FieldByName(UDM.cl_Variables.fieldbyname('NomVariable').asstring).Value := UDM.tb_SerieDatosVar.fieldbyname(vs).Value;
      UDM.tb_VirtualVar.post;
    end;
    UDM.tb_SerieDatosVar.next;
  end;
  UDM.tb_SerieDatosVar.EnableControls;
 // UDM.tb_SeriesDatos.EnableControls;
//****************************************************************************            }
end;

procedure TMAIN.RellenaPrj;
begin

end;

procedure TMAIN.RemoveMDSeriesSubSeriesDMDR;
begin
  UDM.cl_series.Active := False;
  UDM.cl_subseries.Active := False;
  UDM.Tb_SeriesDispo.Active := False;
  UDM.cl_subseries.MasterSource := nil;
  UDM.cl_subseries.MasterFields := '';
  UDM.cl_subseries.IndexFieldNames := '';
  UDM.cl_series.Active := True;
  UDM.cl_subseries.Active := True;
  UDM.Tb_SeriesDispo.Active := True;
end;

procedure TMAIN.RestaurarEstadoNavBar(NavBar: TdxNavBar; const ArchivoINI: string);
var
  INI: TIniFile;
begin
  if not FileExists(ArchivoINI) then
    Exit;

  INI := TIniFile.Create(ArchivoINI);
  try
    NavBar.Height := INI.ReadInteger('NavBar', 'Height', NavBar.Height);
    NavBar.Width := INI.ReadInteger('NavBar', 'Width', NavBar.Width);
    NavBar.OptionsBehavior.NavigationPane.Collapsed := INI.ReadBool('NavBar', 'Collapsed', False);
  finally
    INI.Free;
  end;
end;

function TMAIN.ApplicationEvents1Help(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
begin
  CloseHelpWnd;

  Result := ShellExecute(0, 'open', 'hh.exe', PWideChar('-mapid ' + IntToStr(Data) + ' ms-its:' + ExtractFilePath(Application.ExeName) + 'ArchiGenioPro.chm'), nil, SW_SHOW) = 32;

  CallHelp := false;
end;

procedure TMAIN.ApplyBestFit(DBVerticalGrid: TcxDBVerticalGrid);
var
  I: Integer;
  MaxLabelWidth, MaxValueWidth: Integer;
  CurrentRow: TcxDBEditorRow;  // Cambiado a TcxDBEditorRow
  LabelWidth, ValueWidth: Integer;
  FieldText: string;
  ComboBoxProperties: TcxComboBoxProperties;
begin
  MaxLabelWidth := 100;
  MaxValueWidth := 100;
  // Iterar a través de todas las filas del cxDBVerticalGrid
  for I := 0 to DBVerticalGrid.Rows.Count - 1 do
  begin
    // Verificar si la fila es del tipo TcxDBEditorRow para poder acceder a sus propiedades
    if DBVerticalGrid.Rows[I] is TcxDBEditorRow then
    begin
      CurrentRow := TcxDBEditorRow(DBVerticalGrid.Rows[I]);
      // Medir el ancho de la etiqueta (Caption)
      LabelWidth := DBVerticalGrid.Canvas.TextWidth(CurrentRow.Properties.Caption);
      MaxLabelWidth := Max(MaxLabelWidth, LabelWidth);

      // Medir el ancho del valor actual en la fila (si está asociado a un campo)
      if CurrentRow.Properties.DataBinding.Field <> nil then
        FieldText := CurrentRow.Properties.DataBinding.Field.DisplayText;
      ValueWidth := DBVerticalGrid.Canvas.TextWidth(FieldText);
      MaxValueWidth := Max(MaxValueWidth, ValueWidth);
    end;
  end;

  // Ajustar el ancho de las filas con el mayor ancho encontrado
  DBVerticalGrid.OptionsView.RowHeaderWidth := MaxLabelWidth + 20;  // Espacio adicional para margen
  DBVerticalGrid.OptionsView.ValueWidth := MaxValueWidth + 20;      // Espacio adicional para margen
end;

procedure TMAIN.ArchivoActual;
begin
  if EstoyActualizando then
    Exit;
  with cmdArch do
  begin
    Active := False;
    cmdArch.Connection := UDM.Conn;
    Params[0].Value := UDM.tb_Serietree.FieldByName('archivo').Value;
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pueden consultar los detalles del archivo actual. Motivo: ' + e.Message, 1);
      end;
    end;
  end;
  with cmdGestor do
  begin
    Active := False;
    Connection := UDM.Conn;
    Params[0].Value := UDM.tb_Serietree.FieldByName('gestor').Value;
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pueden consultar los detalles del Gestor actual. Motivo: ' + e.Message, 1);
      end;
    end;
  end;
  UDM.ServidoresDisponibles.Active := False;
  UDM.ServidoresDisponibles.Active := True;
end;

procedure TMAIN.Ayuda1Click(Sender: TObject);
var
  TopicID: integer;
begin
  Application.HelpContext(4);
{  TStyleManager.TrySetStyle('Windows');
  TopicID := 4;
  HelpFile := ExtractFilePath(Application.ExeName) + 'ArchiGenioPro.chm';
  Application.HelpSystem.ShowContextHelp(TopicID, HelpFile);    }
//  Application.HelpSystem.ShowContextHelp(TopicID, HelpFile);
{TStyleManager.TrySetStyle('Windows');
  TopicID := 4;
  HelpFile := ExtractFilePath(Application.ExeName) + 'ArchiGenioPro.chm';
  Application.HelpSystem.ShowContextHelp(TopicID, HelpFile);
  TStyleManager.TrySetStyle(fdefaultStyleName);}
  //UDM.ViewHLP(4);
end;

procedure TMAIN.B1Click(Sender: TObject);
var
  i: Integer;
  ListServer: TStringList;
begin
{  jvcpInformation.Visible := True;
  Application.ProcessMessages;
  ListServer := TStringList.Create;
  ListServer.Add('localhost');
  UDM.ListAvailableSQLServers(ListServer);
  for i := 0 to ListServer.Count - 1 do
  begin
    UDM.ListadoServidores.Append;
    UDM.ListadoServidores.Fields[0].AsString := ListServer[0];
    UDM.ListadoServidores.Fields[1].AsString := ListServer[0];
    UDM.ListadoServidores.Post;
  end;
  ListServer.Free;
  jvcpInformation.Visible := False;
  Application.ProcessMessages; }
  UDM.log('Accediendo a la configuración del sistema.', 14, '', '', '');
  Configurasys(False);
  {with TfrmSysConfig.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;   }
  UDM.log('Abandonando el módulo de configuración del sistema.', 15, '', '', '');
end;

procedure TMAIN.PrepareSSDetailView;

  procedure CheckInitialConditions;
  begin
    // Sale si está actualizando o no hay registros
    if EstoyActualizando then
      Exit;
    if UDM.tb_Serietree.RecordCount = 0 then
    begin
      UDM.SudSDetail.Active := False;
      Exit;
    end;
  end;

  procedure ConfigureDetailQuery;
  begin
    // Configura y ejecuta la consulta de detalles
    cxDBVerticalGrid2.BeginUpdate;
    UDM.SudSDetail.DisableControls;
    UDM.SudSDetail.Active := False;

    // Verifica si los campos son nulos y sale silenciosamente si es el caso
    if UDM.tb_Serietree.FieldByName('codsubs').IsNull or UDM.tb_Serietree.FieldByName('IdEstructura').IsNull then
    begin
      Exit;  // Sale sin mostrar mensajes, ya que es esperado que los parámetros sean nulos al inicio
    end;

    // Define explícitamente los tipos de datos de los parámetros
    UDM.SudSDetail.Params[0].DataType := ftString;  // Asume que 'codsubs' es una cadena
    UDM.SudSDetail.Params[0].Value := UDM.tb_Serietree.FieldByName('codsubs').AsString;

    UDM.SudSDetail.Params[1].DataType := ftString;  // Asume que 'IdEstructura' es una cadena
    UDM.SudSDetail.Params[1].Value := UDM.tb_Serietree.FieldByName('IdEstructura').AsString;

    try
      // Activa la consulta y obtiene todos los datos
      UDM.SudSDetail.Active := True;
      UDM.SudSDetail.FetchAll;
    except
      on E: EFDException do
      begin
        // Muestra un mensaje de error solo si falla la consulta por otro motivo
        UDM.sms('No se pudo configurar la consulta de detalles. Motivo: ' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  try
    CheckInitialConditions;
    ConfigureDetailQuery;
  except
    on E: EFDException do
    begin
      // Muestra un mensaje de error si falla la consulta
      udm.sms('No se pueden consultar los detalles de la subserie documental actual. Motivo: ' + E.Message, 1);
    end;
  end;

  // Finaliza la actualización de la cuadrícula y restaura los controles
  UDM.SudSDetail.EnableControls;
  cxDBVerticalGrid2.EndUpdate;
end;
 {
begin
  try
    CheckInitialConditions;
    ConfigureDetailQuery;
  except
    on E: EFDException do
    begin
      // Muestra un mensaje de error si falla la consulta
      udm.sms('No se pueden consultar los detalles de la subserie documental actual. Motivo: ' + E.Message, 1);
    end;
  end;

  // Finaliza la actualización de la cuadrícula y restaura los controles
  UDM.SudSDetail.EnableControls;
  cxDBVerticalGrid2.EndUpdate;
end; }
{begin
  if EstoyActualizando then
    Exit;
  if UDM.tb_Serietree.RecordCount = 0 then
  begin
    UDM.SudSDetail.Active := False;
    Exit;
  end;
  if UDM.tb_Serietree.FieldByName('codsubs').Value = null then
  begin
    UDM.SudSDetail.Active := False;
    Exit;
  end;
  cxDBVerticalGrid2.BeginUpdate;
  UDM.SudSDetail.DisableControls;
  try
    UDM.SudSDetail.Active := False;
    UDM.SudSDetail.Params[0].Value := UDM.tb_Serietree.FieldByName('codsubs').Value;
    UDM.SudSDetail.Params[1].Value := UDM.tb_Serietree.FieldByName('IdEstructura').Value;
    UDM.SudSDetail.Active := True;
    UDM.SudSDetail.FetchAll;
    UDM.SudSDetail.EnableControls;
  except
    on E: EFDException do
    begin
      udm.sms('No se pueden cosultar los detalles de la subserie documental actual. Motivo: ' + e.Message, 1);
    end;
  end;
  cxDBVerticalGrid2.EndUpdate;
end; }

procedure TMAIN.PrepareSSDisp;
const
  BASE_SQL = 'SELECT cl_series.codserie, cl_subseries.codsubs, cl_series.serie AS Series, cl_subseries.subserie AS Subseries, ' + 'cl_subseries.archivo, cl_subseries.deposito, cl_subseries.gaveta, cl_subseries.cargo, cl_subseries.pc, cl_subseries.carpeta ' + 'FROM cl_series INNER JOIN cl_subseries ON cl_series.codserie = cl_subseries.codserie WHERE codsubs NOT IN ' + '(SELECT tb_Serietree.codsubs FROM tb_Serietree WHERE tb_Serietree.id=';
  ORDER_BY = ') AND cl_subseries.activa=%s ORDER BY subserie ASC';

  procedure ConfigureSeriesQuery;
  var
    ActivaCondition: string;
  begin
    // Sale si está actualizando
    if EstoyActualizando then
      Exit;

    // Desactiva los controles y prepara la consulta
    UDM.Tb_SeriesDispo.DisableControls;
    UDM.Tb_SeriesDispo.Active := False;
    with UDM.Tb_SeriesDispo do
    begin
      SQL.Clear;
      Params.Clear;

      // Determina la condición de 'activa' según TBD
      if TBD = 'A' then
        ActivaCondition := 'true'
      else
        ActivaCondition := '1';

      // Construye y agrega la consulta SQL
      SQL.Text := BASE_SQL + UDM.tb_tree.FieldByName('id').AsString + Format(ORDER_BY, [ActivaCondition]);
    end;
  end;

  procedure ExecuteQuery;
  begin
    // Activa la consulta y obtiene todos los datos
    UDM.Tb_SeriesDispo.Active := True;
    UDM.Tb_SeriesDispo.FetchAll;
  end;

begin
  try
    ConfigureSeriesQuery;
    ExecuteQuery;
  except
    on E: EFDException do
    begin
      // Muestra un mensaje de error si falla la consulta
      udm.sms('No se pudo acceder al listado de subseries disponibles. Motivo: ' + E.Message, 1);
    end;
  end;

  // Restaura los controles al finalizar
  UDM.Tb_SeriesDispo.EnableControls;
end;
{begin
  if EstoyActualizando then
    exit;
  UDM.Tb_SeriesDispo.DisableControls;
  try
    UDM.Tb_SeriesDispo.Active := False;
    with UDM.Tb_SeriesDispo do
    begin
      Active := False;
      sql.Clear;
      Params.Clear;
      if TBD = 'A' then
      begin
        SQL.Add('SELECT cl_series.codserie, cl_subseries.codsubs, cl_series.serie AS Series, cl_subseries.subserie AS Subseries,');
        SQL.Add(' cl_subseries.archivo, cl_subseries.deposito, cl_subseries.gaveta, cl_subseries.cargo, cl_subseries.pc, cl_subseries.carpeta');
        SQL.Add(' FROM cl_series INNER JOIN cl_subseries ON cl_series.codserie = cl_subseries.codserie where codsubs not in ');
        SQL.Add('(SELECT  tb_Serietree.codsubs FROM tb_Serietree where tb_Serietree.id=' + UDM.tb_tree.FieldByName('id').AsString + ') and cl_subseries.activa=true order by subserie ASC');
      end
      else
      begin
        SQL.Add('SELECT cl_series.codserie, cl_subseries.codsubs, cl_series.serie AS Series, cl_subseries.subserie AS Subseries,');
        SQL.Add(' cl_subseries.archivo, cl_subseries.deposito, cl_subseries.gaveta, cl_subseries.cargo, cl_subseries.pc, cl_subseries.carpeta');
        SQL.Add(' FROM cl_series INNER JOIN cl_subseries ON cl_series.codserie = cl_subseries.codserie where codsubs not in ');
        SQL.Add('(SELECT  tb_Serietree.codsubs FROM tb_Serietree where tb_Serietree.id=' + UDM.tb_tree.FieldByName('id').AsString + ') and cl_subseries.activa=1 order by subserie ASC');
      end;
    end;
    UDM.Tb_SeriesDispo.Active := True;
    UDM.Tb_SeriesDispo.FetchAll;
    UDM.Tb_SeriesDispo.EnableControls;
  except
    on E: EFDException do
    begin
      udm.sms('No se pudo acceder al listado de subseries disponibles. Motivo: ' + e.Message, 1);
    end;
  end;
end; }

procedure TMAIN.F1Click(Sender: TObject);
begin
  {with TfrmCLFrecuencia.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;}
end;

procedure TMAIN.FilterNoSource;
begin
  UDM.tb_ssArchdigital.DisableControls;
  UDM.tb_ssArchdigital.Filtered := False;
  UDM.tb_ssArchdigital.Filter := '';
  UDM.tb_ssArchdigital.Filter := 'fuente=' + QuotedStr('N');
  UDM.tb_ssArchdigital.Filtered := True;
  UDM.tb_ssArchdigital.EnableControls;
end;

procedure TMAIN.FilterSource;
begin
  UDM.tb_ssArchdigital.DisableControls;
  UDM.tb_ssArchdigital.Filtered := False;
  UDM.tb_ssArchdigital.Filter := '';
  UDM.tb_ssArchdigital.Filter := 'fuente=' + QuotedStr('S');
  UDM.tb_ssArchdigital.Filtered := True;
  UDM.tb_ssArchdigital.EnableControls;
end;

// Procedimiento: TMAIN.FormActivate
// Propósito: Configura y actualiza el estado del formulario principal al activarse, incluyendo
//            la barra de estado, conexiones de datos, elementos de UI y estado inicial.
// Autor: [Refactorizado por Grok 3, xAI]
// Fecha: 09 de abril de 2025
// Parámetros:
//   Sender: TObject - Objeto que dispara el evento (generalmente el formulario TMAIN).
// Resultado: No devuelve valor (procedimiento). Actualiza la UI y los datos del sistema.
// Excepciones: Maneja errores de archivo, componentes nulos y operaciones de datos, notificando al usuario.
// Dependencias externas:
//   - UDM: Unidad de datos con propiedades (UserName, Rol) y métodos de refresco (cl_series, etc.).
//   - MB: Barra de estado (TStatusBar o similar) con paneles para mostrar información.
//   - LoadGridLayout: Procedimiento externo para cargar la configuración del grid.
//   - PathSys, PathBD, PathTemp: Variables globales con rutas del sistema y base de datos.
//   - programver: Variable global que indica la versión del programa ('BÁSICA' u otra).
//   - primeravez: Variable global booleana para controlar la carga inicial.
// Posibles problemas:
//   - Excepción de acceso prohibido al salir si MB o ConnectionInfo no se liberan correctamente.
//   - Conflictos si el formulario se destruye durante la ejecución.

procedure TMAIN.FormActivate(Sender: TObject);
const
  CONFIG_FILE = 'config.ini'; // Nombre del archivo de configuración
var
  ConnectionInfo: TStringList; // Lista de cadenas para la información de conexión
  ConfigFilePath: string;

  // Función interna: UpdateStatusBar
  // Propósito: Actualiza la barra de estado con información del usuario, rol y conexión.
  // Parámetros: Ninguno (usa variables globales y ConnectionInfo del ámbito superior).
  // Excepciones: Maneja errores de archivo y componentes nulos.

  procedure UpdateStatusBar;
  begin
    if not Assigned(MB) then
      Exit; // Evita acceso a barra de estado nula

    MB.Panels[1].Text := UDM.UserName; // Nombre del usuario
    MB.Panels[3].Text := UDM.Rol;      // Rol del usuario

    if programver = 'BÁSICA' then
      MB.Panels[5].Text := PathBD // Ruta de la base de datos en versión básica
    else
    begin
      MB.Panels[4].Width := 200;
      MB.Panels[4].Text := 'Datos de Conexión';

      if FileExists(PathSys + CONFIG_FILE) then
      begin
        try
          ConnectionInfo.LoadFromFile(PathSys + CONFIG_FILE);
          if ConnectionInfo.Count >= 3 then
            MB.Panels[5].Text := Format('Se encuentra conectado a la Base de Datos: %s en el Servidor: %s', [AnsiQuotedStr(ConnectionInfo[2], '"'), AnsiQuotedStr(ConnectionInfo[1], '"')])
          else
            MB.Panels[5].Text := 'Error: Datos insuficientes en config.ini';
        except
          on E: Exception do
            MB.Panels[5].Text := 'Error al cargar config.ini: ' + E.Message;
        end;
      end
      else
        MB.Panels[5].Text := 'Archivo config.ini no encontrado';
    end;
  end;

  // Función interna: RefreshDataConnections
  // Propósito: Refresca las conexiones de datos si están activas.
  // Parámetros: Ninguno (usa objetos de UDM).
  // Excepciones: Verifica si los componentes están asignados antes de refrescar.
  procedure RefreshDataConnections;
  begin
    if Assigned(VarCL) and VarCL.Active then
      VarCL.Refresh;
    if Assigned(UDM.cl_series) then
      UDM.cl_series.Refresh;
    if Assigned(UDM.cl_subseries) then
      UDM.cl_subseries.Refresh;
    if Assigned(UDM.cl_ftp_Server) then
      UDM.cl_ftp_Server.Refresh;
    if Assigned(UDM.cl_Resp_Gest_Arch) then
      UDM.cl_Resp_Gest_Arch.Refresh;
    if Assigned(UDM.cl_ArchivosGestion) then
      UDM.cl_ArchivosGestion.Refresh;
  end;

  // Función interna: AdjustUIElements
  // Propósito: Ajusta la posición de elementos de la UI y realinea el contenedor principal.
  // Parámetros: Ninguno (usa componentes del formulario).
  // Excepciones: Verifica que los componentes existan antes de manipularlos.
  procedure AdjustUIElements;
  begin
    if Assigned(btnSystemHelp) and Assigned(btnTool) then
      btnSystemHelp.Left := btnTool.Left + btnTool.Width + 7;
    if Assigned(pMainContainer) then
    begin
      pMainContainer.Realign;
      pMainContainer.Invalidate;
    end;
  end;
   {
  // Función interna: LoadInitialState
  // Propósito: Carga el estado inicial del grid y refresca la UI solo la primera vez.
  // Parámetros: Ninguno (usa variables globales y componentes del formulario).
  // Excepciones: Maneja errores al cargar el archivo de configuración del grid.
  procedure LoadInitialState;
  begin
    if primeravez and Assigned(cxGrid2DBTableView1) then
    begin
      try
        if FileExists(PathTemp + 'GDocumentos.ini') then
          LoadGridLayout(cxGrid2DBTableView1, PathTemp + 'GDocumentos.ini')
        else
          Exit; // Silenciosamente ignora si el archivo no existe
        Refresh;
        Update;
        primeravez := False; // Marca que ya se cargó el estado inicial
      except
        on E: Exception do
          ; // Podría añadirse un log o mensaje aquí si se desea
      end;
    end;
  end; }

// Función interna: LoadInitialState
// Propósito: Carga el estado inicial del grid cxGrid2DBTableView1 desde un archivo de configuración
//            y asegura que el formulario se actualice solo la primera vez que se activa.
// Parámetros: Ninguno (usa variables globales y componentes del formulario).
// Excepciones: Maneja errores al cargar el archivo de configuración del grid y notifica problemas.
// Dependencias externas:
//   - cxGrid2DBTableView1: Componente TcxGridDBTableView de DevExpress para mostrar datos.
//   - LoadGridLayout: Procedimiento externo que carga la configuración del grid desde un archivo.
//   - PathTemp: Variable global con la ruta temporal donde se almacena GDocumentos.ini.
//   - primeravez: Variable global booleana que indica si es la primera activación del formulario.
// Posibles problemas:
//   - Violación de acceso si cxGrid2DBTableView1 o su DataSet se liberan antes de cerrar el formulario.
//   - Errores en LoadGridLayout si GDocumentos.ini está corrupto o no es compatible con el grid.
// Recomendaciones:
//   - Asegurarse de que el DataSet asociado a cxGrid2DBTableView1 se cierre antes de destruir el formulario.
//   - Limpiar las configuraciones del grid en el evento OnDestroy del formulario.

  {procedure LoadInitialState;
  const
    GRID_CONFIG_FILE = 'GDocumentos.ini'; // Nombre del archivo de configuración del grid
  var
    ConfigFilePath: string; // Ruta completa del archivo de configuración
  begin
  // Verifica si es la primera vez y si el grid está disponible
    if not primeravez then
      Exit; // Sale si no es la primera activación

    if not Assigned(cxGrid2DBTableView1) then
    begin
      primeravez := False; // Evita intentos futuros si el grid no está disponible
      Exit;
    end;

  // Verifica que el formulario no esté en proceso de destrucción
    if csDestroying in cxGrid2DBTableView1.ComponentState then
    begin
      primeravez := False; // Evita intentos futuros si el formulario se está destruyendo
      Exit;
    end;

  // Construye la ruta del archivo de configuración
    ConfigFilePath := PathTemp + 'GDocumentos.ini';

    try
    // Verifica si el archivo de configuración existe
      if not FileExists(ConfigFilePath) then
      begin
        primeravez := False; // Marca como completado para evitar intentos futuros
        Exit;
      end;

    // Carga la configuración del grid
      LoadGridLayout(cxGrid2DBTableView1, ConfigFilePath);

    // Marca que la carga inicial se completó
      primeravez := False;

    // Nota: Se eliminaron Refresh y Update para evitar accesos a componentes durante el cierre
    // El propio cxGrid2DBTableView1 debería manejar su repintado automáticamente
    except
      on E: Exception do
      begin
      // Registra el error para depuración (puede reemplazarse con un log a archivo o mensaje al usuario)
        primeravez := False; // Evita intentos futuros si falla
      // Opcional: Mostrar mensaje al usuario
      // ShowMessage('Error al cargar la configuración del grid: ' + E.Message);
      end;
    end;
  end; }



begin
  // Inicializa ConnectionInfo al nivel del procedimiento para un manejo seguro
  ConnectionInfo := TStringList.Create;
  try
    // Muestra el cursor de espera durante la ejecución
    Screen.Cursor := crHourGlass;

    // Ejecuta las operaciones principales
    UpdateStatusBar;
    RefreshDataConnections;
    AdjustUIElements;
    if primeravez then
    begin
      LoadGridLayout(cxGrid2DBTableView1, PathTemp + 'GDocumentos.ini');
      primeravez := False;
    end;
    //LoadInitialState;

  finally
    // Libera recursos y restaura el estado
//    ConnectionInfo.Free;
    Screen.Cursor := crDefault;
//    Application.ProcessMessages; // Procesa mensajes pendientes para evitar bloqueos
  end;
end;


{procedure TMAIN.FormActivate(Sender: TObject);
const
  CONFIG_FILE = 'config.ini';
var
  ConnectionInfo: TStringList;

  procedure UpdateStatusBar;
  begin
    // Actualiza la información del usuario y rol en la barra de estado
    MB.Panels[1].Text := UDM.UserName;
    MB.Panels[3].Text := UDM.Rol;

    // Configura la barra según la versión del programa
    if programver = 'BÁSICA' then
      MB.Panels[5].Text := PathBD
    else
    begin
      MB.Panels[4].Width := 200;
      MB.Panels[4].Text := 'Datos de Conexión';

      // Carga la información de conexión desde el archivo de configuración
      ConnectionInfo := TStringList.Create;
      try
        ConnectionInfo.LoadFromFile(PathSys + CONFIG_FILE);
        MB.Panels[5].Text := Format('Se encuentra conectado a la Base de Datos: %s en el Servidor: %s', [AnsiQuotedStr(ConnectionInfo[2], '"'), AnsiQuotedStr(ConnectionInfo[1], '"')]);
      finally
        ConnectionInfo.Free;
      end;
    end;
  end;

  procedure RefreshDataConnections;
  begin
    // Refresca las conexiones de datos si están activas
    if VarCL.Active then
      VarCL.Refresh;
    UDM.cl_series.Refresh;
    UDM.cl_subseries.Refresh;
    UDM.cl_ftp_Server.Refresh;
    UDM.cl_Resp_Gest_Arch.Refresh;
    UDM.cl_ArchivosGestion.Refresh;
  end;

  procedure AdjustUIElements;
  begin
    // Ajusta la posición del botón de ayuda y realinea el contenedor principal
    btnSystemHelp.Left := btnTool.Left + btnTool.Width + 7;
    pMainContainer.Realign;
    pMainContainer.Invalidate;
  end;

  procedure LoadInitialState;
  begin
    // Carga el estado inicial solo la primera vez
    if primeravez then
    begin
      LoadGridLayout(cxGrid2DBTableView1, PathTemp + 'GDocumentos.ini');
      Refresh;
      Update;
      primeravez := False;
    end;
  end;

begin
  try
    // Muestra el cursor de espera durante la ejecución
    Screen.Cursor := crHourGlass;

    UpdateStatusBar;
    RefreshDataConnections;
    AdjustUIElements;
    LoadInitialState;

  finally
    // Restaura el cursor y procesa mensajes pendientes
    Screen.Cursor := crDefault;
    Application.ProcessMessages;
  end;
end;   }
{var
  List: TStringList;
begin
  //Activate
//  syshelpLeft := cxGrid2DBTableView1.ColumnCount;
  MB.Panels[1].Text := UDM.UserName;
  MB.Panels[3].Text := UDM.Rol;
  if programver = 'BÁSICA' then
    MB.Panels[5].Text := PathBD
  else
  begin
    MB.Panels[4].Width := 200;
    MB.Panels[4].Text := 'Datos de Conexión ';
    List := TStringList.Create;
    List.LoadFromFile(PathSys + 'config.ini');
    MB.Panels[5].Text := ' Se encuentra conectado a la Base de Datos:  ' + AnsiQuotedStr(List[2], '"') + '   en el Servidor:   ' + AnsiQuotedStr(List[1], '"');
    List.Free;
  end;
 // Caption := 'ArchiGenio ' + VersionProgram;
//  btnViewPanel.Visible := False;
  if VarCL.Active then
    VarCL.Refresh;
  UDM.cl_series.Refresh;
  UDM.cl_subseries.Refresh;
  UDM.cl_ftp_Server.Refresh;
  UDM.cl_Resp_Gest_Arch.Refresh;
  UDM.cl_ArchivosGestion.Refresh;
  btnSystemHelp.Left := btnTool.Left + btnTool.Width + 7;
  if primeravez then
  begin     }
    {CargarEstadoToolPanel(advtpCuadroClasif, PathTemp + '\advtpCuadroClasif.ini');
    CargarEstadoToolPanel(advtpSSDispo, PathTemp + '\advtpSSDispo.ini');
    CargarEstadoToolPanel(advtpDetail, PathTemp + '\advtpDetail.ini');
    CargarEstadoToolPanel(pArchivoDig, PathTemp + '\pArchivoDig.ini');  }
   { LoadGridLayout(cxGrid2DBTableView1, PathTemp + 'GDocumentos.ini');
    Refresh;
    Update;
    //PContainer.Visible := True;
    primeravez := False;
  end;
  Screen.Cursor := crDefault;
  pMainContainer.Realign;
  pMainContainer.Invalidate;
  Application.ProcessMessages;
//  syshelpLeft := cxGrid2DBTableView1.ColumnCount;
end; }

procedure TMAIN.FormatearGrid(cxGrid: TcxGrid; Query: TFDQuery);
var
  VarQuery: TFDQuery;
  Field: TField;
  GridView: TcxGridDBTableView;
  Column: TcxGridDBColumn; // Cambiar el tipo de columna a TcxGridDBColumn
  SourceGridView: TcxGridDBTableView;
  SourceColumn: TcxGridDBColumn;
  i: Integer;
begin
  // Asegúrate de que el grid tenga al menos una vista y que sea del tipo correcto

  if cxGrid.ViewCount = 0 then
    raise Exception.Create('El cxGrid no tiene vistas disponibles.');

  // Verifica que la vista sea del tipo TcxGridDBTableView
  if cxGrid.Views[0] is TcxGridDBTableView then
    GridView := TcxGridDBTableView(cxGrid.Views[0])
  else
    raise Exception.Create('La vista del cxGrid no es de tipo TcxGridDBTableView.');
  // Limpiar columnas existentes
  GridView.ClearItems;
  // Copiar el formato de cxGrid2DBTableView1 a la nueva grid
  SourceGridView := cxGrid2DBTableView1; // Referencia al grid existente
  // Agregar columnas de tb_SeriesDatos
  for Field in Query.Fields do
  begin
    Column := GridView.CreateColumn as TcxGridDBColumn; // Cast para TcxGridDBColumn
    Column.DataBinding.FieldName := Field.FieldName; // Nombre del campo en el grid
    Column.Caption := Field.DisplayName;  // Usar el nombre del campo como título

    // Buscar y copiar formato de la columna correspondiente en cxGrid2DBTableView1
    for i := 0 to SourceGridView.ColumnCount - 1 do
    begin
      SourceColumn := SourceGridView.Columns[i] as TcxGridDBColumn;
      // Aquí buscamos si el nombre del campo está contenido en el campo del grid
      if SameText(SourceColumn.DataBinding.FieldName, Field.FieldName) then
      begin
        // Copiar propiedades visuales
        Column.Width := SourceColumn.Width;
        Column.Caption := SourceColumn.Caption;
        Column.HeaderAlignmentHorz := SourceColumn.HeaderAlignmentHorz;
        Column.Visible := SourceColumn.Visible;
        Column.VisibleForCustomization := SourceColumn.VisibleForCustomization;
        Column.Properties := SourceColumn.Properties;
        Column.DataBinding.DataController.DataSource := dsqRecupera;
//        Column.Properties.Assign(SourceColumn.Properties);
        // Puedes añadir más propiedades a copiar según sea necesario
        Break; // Salir del bucle una vez encontrado
      end;
    end;
  end;
  // Obtener el formato para los campos de metadatos de cl_VarSubserie
  VarQuery := TFDQuery.Create(nil);
  try
    VarQuery.Connection := UDM.Conn;
    VarQuery.SQL.Text := 'SELECT * FROM cl_VarSubserie WHERE codserie = ' + QuotedStr(UDM.SudSDetail.FieldByName('codserie').AsString) + ' AND codsubs = ' + QuotedStr(UDM.SudSDetail.FieldByName('codsubs').AsString) + ' ORDER BY Orden';
    VarQuery.Open;

    // Agregar columnas de metadatos
    while not VarQuery.Eof do
    begin
      Column := GridView.CreateColumn as TcxGridDBColumn; // Cast para TcxGridDBColumn
      Column.DataBinding.FieldName := VarQuery.FieldByName('NomVariable').AsString; // Nombre de la variable
      Column.Caption := VarQuery.FieldByName('Etiqueta').AsString; // Usar la etiqueta como título

      // Aplicar formato según tipo
      case VarQuery.FieldByName('tipo').AsInteger of
        1, 3, 5: // Tipos (Caracteres, Entero y Real)
          begin
            // Aquí puedes establecer propiedades específicas para texto
            Column.PropertiesClass := TcxTextEditProperties; // Cambia esto según tu necesidad
          end;
        2: // Tipo Fecha
          begin
            // Aquí puedes establecer propiedades específicas para numérico
            Column.PropertiesClass := TcxDateEditProperties // Cambia esto según tu necesidad
          end;
        4: // Tipo Memo
          begin
            // Aquí puedes establecer propiedades específicas para numérico
            Column.PropertiesClass := TcxMemoProperties // Cambia esto según tu necesidad
          end;
        6: // Tipo boolean
          begin
            // Aquí puedes establecer propiedades específicas para numérico
            Column.PropertiesClass := TcxCheckBoxProperties // Cambia esto según tu necesidad
          end;
        // Agrega más tipos según tu lógica
      end;

      VarQuery.Next; // Ir al siguiente registro de variables
    end;

  finally
    VarQuery.Free; // Liberar la consulta de variables
  end;

  // Ajustar automáticamente el ancho de las columnas
  GridView.ApplyBestFit;
end;

procedure TMAIN.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if UDM.sms('¿Realmente desea salir del sistema?', 4) = 6 then
  begin
    CanClose := True;
    UDM.log('El usuario "' + UDM.UserName + '" con el rol de "' + UDM.Rol + '" ha cerrado sesión abandonando el sistema.', 12, '', '', '');
    if (ansilowercase(UDM.Rol) <> 'visor') then
    begin
      DeleteFile(PathTemp + 'GDocumentos.ini');
      SaveGridLayout(cxGrid2DBTableView1, PathTemp + 'GDocumentos.ini');
    end;
    SaveTreeViewFont(tvtree, PathTemp + '\tvtree.ini');
    UDM.SaveTreeViewState(tvTree, PathTemp + '\tvtreeState.ini');
//    GuardarEstadoNavBar(nbMain, PathTemp + '\NavBarEstado.ini');
    GuardarEstadoToolPanel(advtpCuadroClasif, PathTemp + '\advtpCuadroClasif.ini');
    GuardarEstadoToolPanel(advtpSSDispo, PathTemp + '\advtpSSDispo.ini');
    GuardarEstadoToolPanel(advtpDetail, PathTemp + '\advtpDetail.ini');
    GuardarEstadoToolPanel(pArchivoDig, PathTemp + '\pArchivoDig.ini');
//    nbMain.SaveToIniFile(PathTemp + '\BarraMain.ini');
    //    SaveTreeViewToFile(PathSys + '\Resources\tvtree.ini');
    //UDM.GuardarConfiguracion(cxGrid2, PathTemp + 'GDocumentos.tbl');
//    UDM.SalvaConfigGrid(GViewSeriesDBTableView1, 'GSeriesAsignadas');
//    UDM.SalvaConfigGrid(cxGrid2DBTableView1, 'GDocumentos');
//    UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'GSeriesDisp');
    try
      UDM.KillProcess('PDFExpressViewer.exe');
    except
    end;
    try
      UDM.KillProcess('EXCEL.EXE');
    except
    end;
    try
      UDM.KillProcess('PRecovery.exe');
    except
    end;
    try
      UDM.KillProcess('ReportApp.exe');
    except
    end;
    SaveTreeStateNode;

  end
  else
    CanClose := False;
end;

procedure TMAIN.FormCreate(Sender: TObject);
var
  MonitorIndex: Integer;
  MonitorRect: TRect;
  cad: string;
  i: integer;

  function SetAcento(acad: string): string;
  var
    tmp, tmp1: string;
  begin
    tmp := acad;
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'c1', 'Á');
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'c9', 'É');
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'cd', 'Í');
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'd3', 'Ó');
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'da', 'Ú');
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'e1', 'á');
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'e9', 'é');
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'ed', 'í');
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'f3', 'ó');
    tmp := AnsiReplacestr(tmp, '\' + chr(39) + chr(39) + 'fa', 'ú');
    result := tmp;
  end;

begin
//  if FileExists(PathTemp + '\NavBarEstado.ini') then
//  PContainer.Visible := False;
  RestaurarEstadoNavBar(nbMain, PathTemp + '\NavBarEstado.ini');
  advtpSSDispo.Hide;
  advtpDetail.Hide;
  pArchivoDig.Hide;
//multi monitor
  // Elige el monitor deseado (por ejemplo, el segundo monitor)
  if Screen.MonitorCount > 1 then
  begin
    MonitorIndex := 0; // 0 es el primer monitor, 1 es el segundo, etc.
    if (MonitorIndex >= 0) and (MonitorIndex < Screen.MonitorCount) then
    begin
      MonitorRect := Screen.Monitors[MonitorIndex].BoundsRect;
   // Ajusta la posición y el tamaño del formulario
      Self.Left := MonitorRect.Left;
      Self.Top := MonitorRect.Top;
      Self.Width := (MonitorRect.Right - MonitorRect.Left);
      Self.Height := (MonitorRect.Bottom - MonitorRect.Top) - 40;

    // O puedes centrar la ventana en el monitor seleccionado
      Self.Left := MonitorRect.Left + (MonitorRect.Width - Self.Width) div 2;
      Self.Top := MonitorRect.Top + (MonitorRect.Height - Self.Height) div 2;
    end;
  end;
  syshelpLeft := btnSystemHelp.Left;
  if FileExists(ExtractFilePath(Application.ExeName) + '\SDTrad.ini') then
  begin
    cxLocalizer1.LoadFromFile(ExtractFilePath(Application.ExeName) + '\SDTrad.ini');
    cxLocalizer1.LanguageIndex := 1; // MUDA DE LINGUAGEM
    cxLocalizer1.Active := True; // ATIVA O COMPONENTE
  end;
  WindowState := wsMaximized;
  Caption := 'ArchiGenio ' + VersionProgram; // + UDM.tb_sysconfig.FieldByName().AsString;
  HelpFile := ExtractFilePath(Application.ExeName) + 'ArchiGenioPro.chm';
  cxDBVerticalGrid3.OnClick := cxDBVerticalGridClick;
  UDM.EstablecerAlcance('Invitado', False); // antes de autenticar solo ve lo publico
  UDM.CargarArbol(tvTree, UDM.tb_arbol, false);
  LoadTreeStateNode;
  CleanTMP(PathTemp);
  UDM.Rol := 'Visor';
  UDM.UserName := 'Invitado';
  if (AnsiLowerCase(UDM.Rol) = 'administradores') or (AnsiLowerCase(UDM.Rol) = 'documentador') then
    acceso := 'acceso total'
  else
    acceso := 'solo lectura';
  if Trim(acceso) = '' then
    acceso := 'solo lectura';
  Security.SetModSecurity(Self, acceso);
  {ArchiveroOpts;
  PrepareSSDisp;
  PrepareSSDetailView;
  PrepareServerDetailView;
  ArchivoActual;
  if Assigned(TStyleManager.ActiveStyle) then
    fdefaultStyleName := TStyleManager.ActiveStyle.Name; }
end;

procedure TMAIN.FormDestroy(Sender: TObject);
begin
  CloseHelpWnd;
end;

procedure TMAIN.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
 { TopicID := 4;
  if Key = 112 then
    Application.HelpContext(TopicID);   }

  if Key = 123 then
    if UDM.tb_Serietree.RecordCount > 0 then
      jvcpSSDetail.Visible := not jvcpSSDetail.Visible;
  if Key = 120 then
  begin
    if advtpCuadroClasif.Showing then
      advtpCuadroClasif.Hide
    else
      advtpCuadroClasif.Show;
  end;
  if Key = 121 then
  begin
    if advtpDetail.Showing then
      advtpDetail.Hide
    else
      advtpDetail.Show;
  end;
  if Key = 122 then
  begin
    if advtpSSDispo.Showing then
      advtpSSDispo.Hide
    else
      advtpSSDispo.Show;
  end;
  if Key = 119 then
  begin
    if nbMain.Showing then
      nbMain.Hide
    else
      nbMain.Show;
  end;
end;

procedure TMAIN.FormResize(Sender: TObject);
begin
  {pMainContainer.Realign;
  pMainContainer.Invalidate;
  Application.ProcessMessages;   }
end;

procedure TMAIN.FormShow(Sender: TObject);
const
  TREE_CONFIG = 'tvtree.ini';
  TREE_STATE = 'tvtreeState.ini';
  RESOURCE_PATH = '\Resources\';

  procedure LoadTreeViewSettings;
  begin
    // Habilita el optimizador
    Optimizer.Enabled := True;

    // Verifica si existe el archivo de configuración en el directorio temporal
    if not FileExists(PathTemp + TREE_CONFIG) then
    begin
      // Si no existe en temporal, busca en el directorio de recursos del sistema
      if FileExists(PathSys + RESOURCE_PATH + TREE_CONFIG) then
        LoadTreeViewFont(tvtree, PathSys + RESOURCE_PATH + TREE_CONFIG);
    end
    else
    begin
      // Carga la fuente y el estado del TreeView desde el directorio temporal
      LoadTreeViewFont(tvtree, PathTemp + TREE_CONFIG);
      udm.LoadTreeViewState(tvtree, PathTemp + TREE_STATE);
    end;
  end;

  procedure AgregarMenuBusqueda;
  var
    Item: TMenuItem;
  begin
    // Entrada "Buscar documentos" en el menu de herramientas (por codigo, sin
    // tocar el .dfm). FormShow puede ejecutarse mas de una vez: no se duplica.
    if FindComponent('miBuscarDocumentos') <> nil then
      Exit;
    Item := TMenuItem.Create(Self);
    Item.Name := 'miBuscarDocumentos';
    Item.Caption := 'Buscar documentos';
    Item.OnClick := BuscarDocumentosClick;
    PMTool.Items.Insert(0, Item);
  end;

  procedure FinalizeUI;
  begin
    // Restablece el estado y ajusta la interfaz de usuario
    estadoC := False;
    Screen.Cursor := crDefault;
    syshelpLeft := cxGrid2DBTableView1.ColumnCount;
    pMainContainer.Realign;
    pMainContainer.Invalidate;
    Application.ProcessMessages;
  end;

begin
  // Ejecuta la carga de configuraciones y ajustes finales
  LoadTreeViewSettings;
  // Shell de la variante A (sin efecto con shell_clasico.flag). Con el shell
  // activo, el buscador de la cabecera sustituye a "Buscar documentos".
  AplicarShell(Self);
  // Paleta de UTema en las pantallas viejas (rejillas, iconos, paneles)
  InstalarAparienciaLegacy;
  // Iconos del arbol del cuadro de clasificacion (mismos indices, nuevas imagenes)
  try
    ReemplazarIconosArbol(UDM.ImageList3);
  except
    // Solo apariencia: si falla quedan los iconos anteriores
  end;
  if ShellActivo then
  begin
    ConectarShell;
    ConectarListaDocumentos;
  end
  else
    AgregarMenuBusqueda;
  FinalizeUI;
end;

procedure TMAIN.BuscarDocumentosClick(Sender: TObject);
begin
  AbrirBusquedaDocumentos;
end;

// Conecta los eventos del shell (UShellPrincipal) con los flujos existentes
// y quita "Buscar documentos" de PMTool: lo sustituye el buscador del shell.
type
  { Avisa cuando cambian los datos de tb_SeriesDatos (otra subserie, refresco,
    alta, baja). Los desplazamientos entre registros no lo disparan. }
  TEnlaceDocumentos = class(TDataLink)
  private
    FAlCambiar: TNotifyEvent;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
  public
    property AlCambiar: TNotifyEvent read FAlCambiar write FAlCambiar;
  end;

procedure TEnlaceDocumentos.ActiveChanged;
begin
  inherited ActiveChanged;
  if Assigned(FAlCambiar) then
    FAlCambiar(Self);
end;

procedure TEnlaceDocumentos.DataSetChanged;
begin
  inherited DataSetChanged;
  if Assigned(FAlCambiar) then
    FAlCambiar(Self);
end;

// Guarda el motivo de un fallo de la lista en lista_error.log (junto al
// ejecutable) sin molestar al usuario.
procedure TMAIN.RegistrarErrorLista(const Texto: string);
begin
  try
    with TStringList.Create do
    try
      if FileExists(ExtractFilePath(ParamStr(0)) + 'lista_error.log') then
        LoadFromFile(ExtractFilePath(ParamStr(0)) + 'lista_error.log');
      Add(DateTimeToStr(Now) + ' ' + Texto);
      SaveToFile(ExtractFilePath(ParamStr(0)) + 'lista_error.log');
    finally
      Free;
    end;
  except
  end;
end;

// Lista de documentos de la subserie (F2): vista de la subserie en lugar de la
// rejilla cxGrid, que queda como vista alternativa (alta y edicion) hasta que
// exista la carga nueva. Se alimenta de UDM.tb_SeriesDatos, el mismo dataset
// de la rejilla, de modo que lista lo que el usuario ya veia. Sin efecto con
// shell_clasico.flag (ConectarShell solo corre con el shell activo).
procedure TMAIN.ConectarListaDocumentos;
begin
  if FListaDocs <> nil then
    Exit;
  try
    FBarraRejilla := TPanel.Create(Self);
    FBarraRejilla.Parent := PSeriesDatos;
    FBarraRejilla.Align := alTop;
    FBarraRejilla.Height := 34;
    FBarraRejilla.BevelOuter := bvNone;
    FBarraRejilla.ShowCaption := False;
    FBarraRejilla.Visible := False;
    with TButton.Create(FBarraRejilla) do
    begin
      Parent := FBarraRejilla;
      Caption := 'Ver lista';
      SetBounds(8, 4, 110, 26);
      OnClick := ListaDocsAlternar;
    end;

    FListaDocs := TPanelDocumentos.Create(Self);
    FListaDocs.Parent := PSeriesDatos;
    FListaDocs.Align := alClient;
    FListaDocs.OnSeleccion := ListaDocsSeleccion;
    FListaDocs.OnAbrirContenido := ListaDocsAbrir;
    FListaDocs.OnPedirFicheros := ListaDocsFicheros;
    FListaDocs.OnAlternarVista := ListaDocsAlternar;

    FTimerDocs := TTimer.Create(Self);
    FTimerDocs.Enabled := False;
    FTimerDocs.Interval := 150;
    FTimerDocs.OnTimer := ListaDocsRefrescar;

    FEnlaceDocs := TEnlaceDocumentos.Create;
    TEnlaceDocumentos(FEnlaceDocs).DataSource := UDM.dstb_SeriesDatos;
    TEnlaceDocumentos(FEnlaceDocs).AlCambiar := ListaDocsCambio;

    FModoLista := True;
    cxPageControl2.Visible := False;
    FListaDocs.Visible := True;
    FListaDocs.BringToFront;
    ListaDocsCargar;
  except
    on E: Exception do
    begin
      // Si algo falla queda la rejilla de siempre, sin mensajes; el motivo se
      // guarda en lista_error.log junto al ejecutable
      RegistrarErrorLista(E.ClassName + ': ' + E.Message);
      FModoLista := False;
      cxPageControl2.Visible := True;
      FreeAndNil(FListaDocs);
      FreeAndNil(FBarraRejilla);
    end;
  end;
end;

// Varios cambios seguidos (p. ej. al cambiar de subserie) se agrupan en una carga
procedure TMAIN.ListaDocsCambio(Sender: TObject);
begin
  // La propia carga (DisableControls/EnableControls) emite cambios de datos: se ignoran
  if FCargandoDocs or (FTimerDocs = nil) or not FModoLista then
    Exit;
  FTimerDocs.Enabled := False;
  FTimerDocs.Enabled := True;
end;

procedure TMAIN.ListaDocsRefrescar(Sender: TObject);
begin
  FTimerDocs.Enabled := False;
  ListaDocsCargar;
end;

procedure TMAIN.ListaDocsCargar;
var
  DS: TFDQuery;
  Docs: TArray<TDatosDocumento>;
  N, IdNodo: Integer;
  Ind: TIndicadoresDocs;
  Indic: TIndicadoresDoc;
  Est, CodSubs, Titulo: string;
  Bm: TBookmark;
  D: TDatosDocumento;

  function Texto0(const Campo: string): string;
  begin
    // 0 y vacio cuentan como "sin dato", igual que la validacion topografica
    Result := Trim(DS.FieldByName(Campo).AsString);
    if Result = '0' then
      Result := '';
  end;

begin
  if (FListaDocs = nil) or not FModoLista then
    Exit;
  DS := UDM.tb_SeriesDatos;
  if not DS.Active then
  begin
    FListaDocs.MostrarSinSubserie;
    Exit;
  end;
  Est := '';
  CodSubs := '';
  IdNodo := 0;
  if UDM.tb_Serietree.Active and not UDM.tb_Serietree.IsEmpty then
  begin
    Est := UDM.tb_Serietree.FieldByName('IdEstructura').AsString;
    IdNodo := UDM.tb_Serietree.FieldByName('id').AsInteger;
    CodSubs := UDM.tb_Serietree.FieldByName('codsubs').AsString;
  end;
  if CodSubs = '' then
  begin
    FListaDocs.MostrarSinSubserie;
    Exit;
  end;
  Titulo := CodSubs;
  try
    if CodSubs <> '' then
      Titulo := VarToStr(UDM.Conn.ExecSQLScalar(
        'SELECT subserie FROM cl_subseries WHERE codsubs = :c', [CodSubs]));
  except
    Titulo := CodSubs;
  end;

  FCargandoDocs := True;
  Ind := nil;
  try
    if CodSubs <> '' then
      Ind := CargarIndicadores(UDM.Conn, UDM.Alcance, Est, IdNodo, CodSubs);
  except
    on E: Exception do
    begin
      // sin indicadores: se listan igual, como documentos simples
      Ind := nil;
      RegistrarErrorLista('Indicadores: ' + E.ClassName + ': ' + E.Message);
    end;
  end;
  try
    N := 0;
    SetLength(Docs, DS.RecordCount);
    Bm := DS.GetBookmark;
    DS.DisableControls;
    try
      DS.First;
      while not DS.Eof do
      begin
        D := Default(TDatosDocumento);
        D.Clave.IdEstructura := DS.FieldByName('IdEstructura').AsString;
        D.Clave.Id := DS.FieldByName('id').AsInteger;
        D.Clave.CodSubs := DS.FieldByName('codsubs').AsString;
        D.Clave.Fecha := DS.FieldByName('Fecha').AsDateTime;
        D.Clave.Version := DS.FieldByName('Version').AsString;
        D.Clave.Codigodoc := DS.FieldByName('Codigodoc').AsString;
        D.Titulo := DS.FieldByName('titulodoc').AsString;
        D.IdExpediente := Trim(DS.FieldByName('IDExpediente').AsString);
        D.SubExp := Trim(DS.FieldByName('subexp').AsString);
        D.Servidor := Texto0('Idservidor');
        D.Archivo := Texto0('Archivo');
        D.Deposito := Texto0('deposito');
        D.Gaveta := Texto0('gaveta');
        D.Posicion := Texto0('posicion');
        D.Observaciones := DS.FieldByName('observaciones').AsString;
        D.ExtPrincipal := ExtensionNormal(ExtractFileExt(DS.FieldByName('fichero').AsString));
        if (Ind <> nil) and Ind.TryGetValue(ClaveTexto(D.Clave), Indic) then
        begin
          D.NumHijos := Indic.NumHijos;
          D.NumVerticesGeo := Indic.NumVerticesGeo;
          D.NumFicheros := Indic.NumFicheros;
          D.NumFuentes := Indic.NumFuentes;
          if Indic.ExtPrincipal <> '' then
            D.ExtPrincipal := Indic.ExtPrincipal;
        end;
        if N > High(Docs) then
          SetLength(Docs, N + 1);
        Docs[N] := D;
        Inc(N);
        DS.Next;
      end;
    finally
      if DS.BookmarkValid(Bm) then
        DS.GotoBookmark(Bm);
      DS.FreeBookmark(Bm);
      DS.EnableControls;
    end;
    SetLength(Docs, N);
    FListaDocs.Cargar(Docs, Titulo);
  finally
    Ind.Free;
    FCargandoDocs := False;
  end;
end;

function TMAIN.ListaDocsLocalizar(const Clave: TClaveDocumento): Boolean;
begin
  Result := UDM.tb_SeriesDatos.Active and UDM.tb_SeriesDatos.Locate(
    'IdEstructura;id;codsubs;Fecha;Version;Codigodoc',
    VarArrayOf([Clave.IdEstructura, Clave.Id, Clave.CodSubs,
    VarFromDateTime(Clave.Fecha), Clave.Version, Clave.Codigodoc]), []);
end;

procedure TMAIN.ListaDocsSeleccion(const Clave: TClaveDocumento);
begin
  // el registro actual de tb_SeriesDatos sigue a la lista: los datasets de
  // ficheros (maestro-detalle) y los botones por rol trabajan sobre el
  if not ListaDocsLocalizar(Clave) then
    UDM.sms('No se pudo localizar el documento seleccionado.', 2);
end;

procedure TMAIN.ListaDocsAbrir(const Clave: TClaveDocumento);
begin
  if ListaDocsLocalizar(Clave) then
    MenuItem5Click(Self) // el mismo "Abrir" del menu de ficheros
  else
    UDM.sms('No se pudo localizar el documento seleccionado.', 2);
end;

function TMAIN.ListaDocsFicheros(const Clave: TClaveDocumento): TArray<TFicheroDoc>;
var
  N: Integer;

  procedure Leer(Q: TFDQuery; EsFuente: Boolean);
  var
    F: TFicheroDoc;
  begin
    if not Q.Active then
      Exit;
    Q.DisableControls;
    try
      Q.First;
      while not Q.Eof do
      begin
        F.Nombre := Q.FieldByName('nombre').AsString;
        F.Extension := Q.FieldByName('extnombre').AsString;
        F.Tamano := Q.FieldByName('tamano').AsFloat;
        F.EsFuente := EsFuente;
        SetLength(Result, N + 1);
        Result[N] := F;
        Inc(N);
        Q.Next;
      end;
      Q.First;
    finally
      Q.EnableControls;
    end;
  end;

begin
  Result := nil;
  N := 0;
  if not ListaDocsLocalizar(Clave) then
    Exit;
  try
    Leer(UDM.qryAnexosDig, False);
    Leer(UDM.qryFuentesDig, True);
  except
    on E: Exception do
    begin
      RegistrarErrorLista('Ficheros: ' + E.ClassName + ': ' + E.Message);
      raise;
    end;
  end;
end;

procedure TMAIN.ListaDocsAlternar(Sender: TObject);
begin
  if FListaDocs = nil then
    Exit;
  FModoLista := not FModoLista;
  FListaDocs.Visible := FModoLista;
  cxPageControl2.Visible := not FModoLista;
  FBarraRejilla.Visible := not FModoLista;
  if FModoLista then
  begin
    FListaDocs.BringToFront;
    ListaDocsCargar;
  end
  else
    FBarraRejilla.BringToFront;
end;

procedure TMAIN.ConectarShell;
var
  Item: TComponent;
begin
  Item := FindComponent('miBuscarDocumentos');
  if Item <> nil then
    Item.Free;
  ShellPrincipal.OnAgregarDocumento := ShellAgregarDocumento;
  ShellPrincipal.OnBuscar := ShellBuscar;
  ShellPrincipal.OnSeccion := ShellSeccion;
  ShellPrincipal.OnSeccionDisponible := ShellSeccionDisponible;
  ShellPrincipal.OnTextoUsuario := ShellTextoUsuario;
  ShellPrincipal.Refrescar;
end;

// "Agregar documento" del shell: el mismo alta que el boton Insertar del
// navegador de documentos (dbnSeriesDatos) sobre el nodo y la subserie
// elegidos (tb_Serietree). Ese boton solo es visible si el rol o el alcance
// permiten agregar (SetModSecurity y AplicarReglasDocumento); se respeta igual.
procedure TMAIN.ShellAgregarDocumento(Sender: TObject);
begin
  // El alta se llena en la rejilla: con la lista a la vista se pasa a ella
  if (FListaDocs <> nil) and FModoLista then
    ListaDocsAlternar(nil);
  if (tvTree.Selected = nil) or not PContainer.Visible or not PSeriesDatos.Visible or
    not UDM.tb_Serietree.Active or UDM.tb_Serietree.IsEmpty or
    not UDM.tb_SeriesDatos.Active then
  begin
    UDM.sms('Elija en el arbol el nodo y la subserie donde agregar el documento.', 3);
    Exit;
  end;
  if not (nbInsert in dbnSeriesDatos.VisibleButtons) or not UDM.tb_SeriesDatos.CanModify then
  begin
    UDM.sms('No tiene permiso para agregar documentos en esta subserie.', 3);
    Exit;
  end;
  if cxPageControl2.ActivePage <> cxTabSheet1 then
    cxPageControl2.ActivePage := cxTabSheet1;
  dbnSeriesDatos.BtnClick(nbInsert);
end;

// Buscador del shell. Abre la pantalla de busqueda (que siempre aplica el
// alcance del usuario) con el ambito elegido; "nodo actual" usa el nodo de
// tvTree y sus descendientes.
procedure TMAIN.ShellBuscar(const Texto: string; Ambito: TAmbitoBusqueda);
var
  Nodo: TClaveNodo;
  TieneNodo: Boolean;
begin
  Nodo.IdEstructura := '';
  Nodo.Id := 0;
  TieneNodo := (tvTree.Selected <> nil) and (tvTree.Selected.Data <> nil);
  if TieneNodo then
  begin
    Nodo.IdEstructura := PDataRec(tvTree.Selected.Data).estruct;
    Nodo.Id := PDataRec(tvTree.Selected.Data).Id;
  end;
  // Con "nodo actual" y sin nodo elegido la pantalla avisa; no cae a general
  AbrirBusquedaDocumentos(Texto, Ambito, Nodo, TieneNodo, SeleccionarNodoEnArbol);
end;

// Selecciona en tvTree el nodo indicado y ejecuta el mismo manejo que un clic
// real (tvTreeMouseDown actualiza PContainer, tb_tree, etc.). False si el
// arbol del usuario no muestra ese nodo.
function TMAIN.SeleccionarNodoEnArbol(const Nodo: TClaveNodo): Boolean;
var
  I: Integer;
  N, Hallado: TTreeNode;
  R: TRect;
begin
  Result := False;
  Hallado := nil;
  for I := 0 to tvTree.Items.Count - 1 do
  begin
    N := tvTree.Items[I];
    if (N.Data <> nil) and (PDataRec(N.Data).Id = Nodo.Id) and
      SameText(Trim(PDataRec(N.Data).estruct), Trim(Nodo.IdEstructura)) then
    begin
      Hallado := N;
      Break;
    end;
  end;
  if Hallado = nil then
    Exit;
  if not nbMain.Visible then
    nbMain.Show;
  Hallado.MakeVisible;
  tvTree.Selected := Hallado;
  R := Hallado.DisplayRect(True);
  tvTreeMouseDown(tvTree, mbLeft, [], R.Left + (R.Right - R.Left) div 2,
    R.Top + (R.Bottom - R.Top) div 2);
  if tvTree.CanFocus then
    tvTree.SetFocus;
  Result := True;
end;

// Secciones de la columna del shell. Inicio y Archivo muestran el arbol;
// Traslados y Prestamos abren lo mismo que sus items de PMTool.
procedure TMAIN.ShellSeccion(const Nombre: string);
begin
  if (Nombre = SECCION_INICIO) or (Nombre = SECCION_ARCHIVO) then
  begin
    if not nbMain.Visible then
      nbMain.Show;
    if (Nombre = SECCION_INICIO) and (tvTree.Items.GetFirstNode <> nil) then
      tvTree.Items.GetFirstNode.MakeVisible;
    if tvTree.CanFocus then
      tvTree.SetFocus;
    Exit;
  end;
  // Las demas secciones solo se atienden si el rol actual las ve
  if not ShellSeccionDisponible(Nombre) then
    Exit;
  if Nombre = SECCION_TRASLADOS then
    btnTransfer.Click
  else if Nombre = SECCION_PRESTAMOS then
    P3.Click
  else if Nombre = SECCION_DEPURACION then
    D3.Click
  else if Nombre = SECCION_INDICES then
    I2.Click
  else if Nombre = SECCION_CUADRO then
    btnManagementTree.Click
  else if Nombre = SECCION_USUARIOS then
    btnusercontrol.Click
  else if Nombre = SECCION_CLASIFICADORES then
    ShellMenuClasificadores
  else if Nombre = SECCION_CONFIGURACION then
    ShellMenuConfiguracion
  else if Nombre = SECCION_ACERCA then
    Acercade1Click(Self);
end;

// Menu de configuracion del sistema: los items de PMTool que no son de
// gestion documental (configuracion, cambio de base de datos, registros).
// Cada entrada ejecuta el item original.
// Arma una sola vez un menu con copias (y su icono) de items existentes; cada
// entrada ejecuta el item original y refleja su Enabled actual.
function TMAIN.ShellMenuDesde(var Menu: TPopupMenu; const Origenes: array of TMenuItem;
  const Iconos: array of string): TPopupMenu;
var
  I: Integer;
  Item: TMenuItem;
begin
  if Menu = nil then
  begin
    Menu := TPopupMenu.Create(Self);
    Menu.Images := TIconos.Lista;
    for I := Low(Origenes) to High(Origenes) do
    begin
      Item := TMenuItem.Create(Menu);
      Item.Caption := Origenes[I].Caption;
      Item.ImageIndex := IndiceIcono(Iconos[I]);
      Item.Tag := NativeInt(Origenes[I]);
      Item.OnClick := ShellMenuConfiguracionClick;
      Menu.Items.Add(Item);
    end;
  end;
  for I := 0 to Menu.Items.Count - 1 do
    if Menu.Items[I].Tag <> 0 then
      Menu.Items[I].Enabled := TMenuItem(Menu.Items[I].Tag).Enabled;
  Result := Menu;
end;

// Configuracion del sistema: los items de PMTool que no son de gestion
// documental (configuracion, cambio de base de datos, registros).
procedure TMAIN.ShellMenuConfiguracion;
var
  Item: TMenuItem;
begin
  ShellMenuDesde(FShellMenuConfig, [B1, C1, log], ['configuracion', 'basedatos', 'logs']);
  // Entrada propia (Tag = 0): migrar ficheros del FTP a MinIO
  if FShellMenuConfig.Items.Count = 3 then
  begin
    Item := TMenuItem.Create(FShellMenuConfig);
    Item.Caption := 'Migrar ficheros a MinIO...';
    Item.ImageIndex := IndiceIcono('servidor');
    Item.OnClick := ShellMigrarFicheros;
    FShellMenuConfig.Items.Add(Item);
  end;
  FShellMenuConfig.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

// Clasificadores: los items de PMListascod (listas de codigos).
procedure TMAIN.ShellMenuClasificadores;
begin
  ShellMenuDesde(FShellMenuClasif, [A1, L1, S1],
    ['archivos', 'servidor', 'series']).Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TMAIN.ShellMigrarFicheros(Sender: TObject);
begin
  MostrarMigracionFicheros(UDM.Conn);
end;

procedure TMAIN.ShellMenuConfiguracionClick(Sender: TObject);
begin
  TMenuItem(TMenuItem(Sender).Tag).Click;
end;

// Disponibilidad por permiso. Los botones de la barra antigua (btnLC,
// btnusercontrol, btnManagementTree, btnTool...) los muestra u oculta el
// codigo por rol (adminOptions, GestorOptions...), asi que son la fuente del
// permiso. Transferencias, Depuracion e Indices estan ocultos en el .dfm pero
// cuelgan de Herramientas (btnTool): se ofrecen a quien ve Herramientas.
function TMAIN.ShellSeccionDisponible(const Nombre: string): Boolean;
begin
  if Nombre = SECCION_TRASLADOS then
    Result := btnTool.Visible and btnTransfer.Enabled
  else if Nombre = SECCION_PRESTAMOS then
    Result := btnTool.Visible and P3.Visible and P3.Enabled
  else if Nombre = SECCION_DEPURACION then
    Result := btnTool.Visible and D3.Enabled
  else if Nombre = SECCION_INDICES then
    Result := btnTool.Visible and I2.Enabled
  else if Nombre = SECCION_CUADRO then
    Result := btnManagementTree.Visible and btnManagementTree.Enabled
  else if Nombre = SECCION_USUARIOS then
    Result := btnusercontrol.Visible and btnusercontrol.Enabled
  else if Nombre = SECCION_CLASIFICADORES then
    Result := btnLC.Visible and btnLC.Enabled
  else if Nombre = SECCION_CONFIGURACION then
    Result := btnTool.Visible and (B1.Enabled or C1.Enabled or log.Enabled)
  else
    Result := True;
end;

function TMAIN.ShellTextoUsuario: string;
begin
  Result := UDM.UserName + ' - ' + UDM.Rol;
end;
{begin
  //show
  Optimizer.Enabled := True;
  if not FileExists(PathTemp + '\tvtree.ini') then
  begin
    if FileExists(PathSys + '\Resources\tvtree.ini') then
      LoadTreeViewFont(tvtree, PathSys + '\Resources\tvtree.ini');
  end
  else
  begin
    LoadTreeViewFont(tvtree, PathTemp + '\tvtree.ini');
    udm.LoadTreeViewState(tvtree, PathTemp + '\tvtreeState.ini');
  end;
  estadoC := False;
  Screen.Cursor := crDefault;
  syshelpLeft := cxGrid2DBTableView1.ColumnCount;
  pMainContainer.Realign;
  pMainContainer.Invalidate;
  Application.ProcessMessages;
end;  }

procedure TMAIN.G1Click(Sender: TObject);
begin
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gestión de serie documental');
end;

procedure TMAIN.GViewSeriesIDBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
 // GViewSeriesIDBTableView1.LayoutChanged;
end;

procedure TMAIN.GViewSeriesIDBTableView1FocusedRecordChanged(Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord; ANewItemRecordFocusingChanged: Boolean);
begin
//  GViewSeries.Invalidate(False);
  GViewSeriesIDBTableView1.LayoutChanged;

end;

procedure TMAIN.GViewSeriesIDBTableView1MouseEnter(Sender: TObject);
begin
  GViewSeriesIDBTableView1.Invalidate;
end;

procedure TMAIN.GViewSeriesDBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
{  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.tb_Serietree.FieldByName('observacion').Value = null) or (trim(UDM.tb_Serietree.FieldByName('observacion').Value) = '') then
  begin
    UDM.sms('No se encontró contenido para mostrar.', 3);
    Exit;
  end;}
  NombreSerieDocAsig := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  CampoTexto(@UDM.dstb_Serietree, 'observacion', 'Observaciones sobre la serie ' + NombreSerieDocAsig);
end;

procedure TMAIN.HandleSubserieChange;
var
  existe: Boolean;
  nombretmptable, serie, subserie: string;
begin
  if trim(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString) = '' then
  begin
    tsVar.TabVisible := False;
    cxPageControl1.ActivePage := tsFuentes;
    exit;
  end;
  // Verificar si ya existe la tabla para la nueva subserie
  subserie := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
  serie := UDM.Conn.ExecSQLScalar('select codserie from cl_subseries where codsubs=' + QuotedStr(subserie));
  // Verificar si ya existe la tabla para la nueva subserie
  nombretmptable := UDM.QuitaCaracter('md_' + serie + subserie);
  if (nombretmptable = 'md_') or (nombretmptable = '') then
    exit;
  existe := UDM.TablaExiste(UDM.Conn, nombretmptable);
  if not existe then
  begin
    serie := UDM.Conn.ExecSQLScalar('select codserie from cl_subseries where codsubs=' + QuotedStr(subserie));
    if not existe then
      UDM.CreateTableFromDefinitions(nombretmptable, subserie);
  end;


  {nombretmptable := UDM.QuitaCaracter('md_' + UDM.SudSDetail.FieldByName('codserie').AsString + UDM.tb_SeriesDatos.FieldByName('codsubs').AsString);
  existe := UDM.TablaExiste(UDM.Conn, nombretmptable);
  if not existe then
  begin
    serie := UDM.Conn.ExecSQLScalar('select codserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString));
    if not existe then
      UDM.CreateTableFromDefinitions(nombretmptable, UDM.tb_SeriesDatos.FieldByName('codsubs').AsString);
  end;      }
  // Mostrar las variables correspondientes en el TabSheet
  ShowVariablesForSubserie;
end;

/// <summary>
/// Verifica si el documento tiene datos topográficos especificados.
/// </summary>
/// <param name="DataSet">El DataSet que contiene los datos del documento (tb_expxtiposerie).</param>
/// <returns>True si los datos topográficos están especificados; False en caso contrario.</returns>
/// <remarks>
/// Los datos topográficos incluyen los campos 'deposito', 'gaveta' y 'posicion'.
/// Se considera que los datos están especificados si al menos uno de estos campos no está vacío.
/// Si el DataSet está vacío, se retorna False.
/// Un documento sin servidor propio usa el servidor de la estructura (tb_Serietree)
/// para esta validación (ver UTopografia.ServidorEfectivo).
/// </remarks>
/// <exception cref="Exception">
/// - Si no se encuentran los campos esperados en el DataSet.
/// </exception>
function TMAIN.HasTopographicData(DataSet: TDataSet): Boolean;
var
  Deposito, Gaveta, Posicion, Server, Archivo: string;
  Formato: string;
  cad: string;
begin
  Result := False;

  // Si el DataSet está vacío, no hay datos topográficos
  if DataSet.IsEmpty then
    Exit;

  // Obtener los valores de los campos topográficos
  Deposito := DataSet.FieldByName('deposito').AsString;
  Gaveta := DataSet.FieldByName('gaveta').AsString;
  Posicion := DataSet.FieldByName('posicion').AsString;
  // Un documento sin servidor propio usa el de la estructura (tb_Serietree)
  Server := ServidorEfectivo(DataSet.FieldByName('Idservidor').AsString,
    VarToStr(UDM.Conn.ExecSQLScalar(
    'SELECT Idservidor FROM tb_Serietree WHERE IdEstructura = :a AND id = :b AND codsubs = :c',
    [DataSet.FieldByName('IdEstructura').AsString, DataSet.FieldByName('id').AsInteger,
    DataSet.FieldByName('codsubs').AsString])));
  Archivo := DataSet.FieldByName('Archivo').AsString;
  cad := 'SELECT cl_subseries.soporte FROM cl_subseries WHERE ';
  cad := cad + ' cl_subseries.codsubs=' + QuotedStr(DataSet.FieldByName('codsubs').AsString);
//  Formato:=null;
  Formato := UDM.Conn.ExecSQLScalar(cad);
  if Formato.IsNullOrEmpty(cad) then
    Formato := '3';
//  DataSet.FieldByName('Formato').AsInteger; // Asumiendo que el campo 'Formato' existe

  // Evaluar según el formato
  case strtoint(Formato) of
    1: // Papel
      Result := not Deposito.IsEmpty and not Gaveta.IsEmpty and not Posicion.IsEmpty and not Archivo.IsEmpty;
    2: // Digital
      Result := not Server.IsEmpty;
    3: // Papel y Digital
      Result := not Deposito.IsEmpty and not Gaveta.IsEmpty and not Posicion.IsEmpty and not Archivo.IsEmpty and not Server.IsEmpty;
  end;
end;

function TMAIN.HasVariablesForSubserie(const ASubserie: string): Boolean;
begin
  Result := UDM.Conn.ExecSQLScalar('SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs = ' + QuotedStr(ASubserie)) > 0;
end;

procedure TMAIN.I1Click(Sender: TObject);
begin
  {if Trim(UDM.tb_Serietree.FieldByName('carpeta').AsString) <> '' then
  begin
    //edt1.Text := UDM.tb_Serietree.FieldByName('carpeta').AsString;
    edt1.ReadOnly := True;
    cpInfoPathSubSeries.Visible := True;
    cpInfoPathSubSeries.BringToFront;
    cpInfoPathSubSeries.Left := PContainer.Left + Trunc(PContainer.Width / 2) - Trunc(cpInfoPathSubSeries.Width / 2);
  end
  else
  begin
    UDM.sms('No se encontró ningún contenido que mostrar. Por favor especifique una ruta válida donde se guardaran las series documentales.', 3);
    Exit;
  end;}
end;

procedure TMAIN.I2Click(Sender: TObject);
begin
  UDM.log('Accediendo al módulo de gestión y de índices de Archivos.', 14, '', '', '');
  PContainer.Visible := false;
  EstoyActualizando := True;
  ExportIndex;
  EstoyActualizando := False;
  UDM.CreaTreeDB(UDM.Conn, @tvTree, False);
  PContainer.Visible := True;
  UDM.log('Abandonando el módulo de gestión y de índices de Archivos.', 15, '', '', '');
end;

procedure TMAIN.I4Click(Sender: TObject);
begin
  with TfrmTransferencias.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.InsertConnection(report: TfrxReport; connection: string);
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
        try
          TfrxADOQuery(report.Components[i]).Active := True;
        except
          on E: EDatabaseError do
          begin
            UDM.sms('No se pudo agregar la conexión al reporte especificado. Motivo: ' + e.message, 1);
          end;
        end;
      end;

    end;
  end;
end;

/// <summary>
/// Verifica si el rol del usuario está autorizado para realizar la acción.
/// </summary>
/// <param name="UserRole">El rol del usuario a verificar.</param>
/// <returns>True si el rol está autorizado; False en caso contrario.</returns>
/// <remarks>
/// Los roles autorizados son: administrador, gestor y director.
/// La comparación es insensible a mayúsculas/minúsculas.
/// </remarks>
function TMAIN.IsUserAuthorized(const UserRole: string): Boolean;
var
  I: Integer;
  LowerRole: string;
begin
  Result := False;
  LowerRole := AnsiLowerCase(UserRole);
  for I := Low(AuthorizedRoles) to High(AuthorizedRoles) do
  begin
    if LowerRole = AuthorizedRoles[I] then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TMAIN.ArchiveroOpts;
begin
//  acceso := 'sin acceso';
  acceso := 'solo lectura';
  btnViewPanel.Align := alRight;
//  btnRecuperacion.Visible := True;
  btnusercontrol.Visible := False;
  btnLC.Visible := False;
  btnPrint.Visible := False;
  btnManagementTree.Visible := False;
  btnTool.Visible := False;
  btnViewPanel.Align := alLeft;
  //botones main form
  btnRemoveSerieAsig.Visible := False;
  btnRemoveAllSeriesAsig.Visible := False;
  btnExportExcelCC.Visible := False;
  btnAsignSS.Visible := False;
  btnAsignarSS.Visible := False;
  btnExcelExportSSD.Visible := False;
  btnExportExcelDoc.Visible := False;
//  JvTransparentButton5.Visible := False;
//  btnViewtopoSS.Visible := False;
//Archivos Fuentes
  btnRemoveSourceFileList.Visible := False;
  btnDropSourceFile.Visible := False;
  btnExecuteSourceFile.Visible := True;
  btnSourceFile.Visible := False;
  btnAddListSource.Visible := False;
//Archivos digitales
  btnRemoveFileList.Visible := False;
  btnremovefile.Visible := False;
  btnExecFileAD.Visible := true;
  btnaddfile.Visible := False;
  btnaddfilelist.Visible := False;
end;

procedure TMAIN.GestorOptions;
begin
  btnViewPanel.Align := alRight;
  acceso := 'acceso total';
//  btnRecuperacion.Visible := True;
  btnusercontrol.Visible := False;
  btnLC.Visible := False;
  btnManagementTree.Visible := False;
  btnPrint.Visible := True;
  btnTool.Visible := False;
//  btnViewtopoSS.Visible := False;
  btnViewPanel.Align := alLeft;
  cxGrid2DBTableView1fichero.Visible := True;
  cxGrid2DBTableView1observaciones.Visible := True;
end;

function TMAIN.GetCantOfDay(aFech: TDateTime): integer;
begin
  Result := DaysBetween(aFech, Now());
end;

function TMAIN.GetSubserie: string;
begin
  Result := '';
  if not UDM.SudSDetail.Active then
    Exit;
  if not UDM.tb_SeriesDatos.Active then
    Exit;

  Result := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
  if Result = '' then
    Result := UDM.tb_Serietree.FieldByName('codsubs').AsString;
end;

procedure TMAIN.GuardarEstadoNavBar(NavBar: TdxNavBar; const ArchivoINI: string);
var
  INI: TIniFile;
begin
  INI := TIniFile.Create(ArchivoINI);
  try
    INI.WriteInteger('NavBar', 'Height', NavBar.Height);
    INI.WriteInteger('NavBar', 'Width', NavBar.Width);
    INI.WriteBool('NavBar', 'Collapsed', NavBar.OptionsBehavior.NavigationPane.Collapsed);
  finally
    INI.Free;
  end;
end;

procedure TMAIN.GuardarEstadoToolPanel(ToolPanel: TAdvToolPanel; const ArchivoINI: string);
var
  INI: TIniFile;
begin
  INI := TIniFile.Create(ArchivoINI);
  try
    INI.WriteInteger('ToolPanel', 'Height', ToolPanel.Height);
    INI.WriteInteger('ToolPanel', 'Width', ToolPanel.Width);
    INI.WriteBool('ToolPanel', 'Locked', ToolPanel.Locked);
  finally
    INI.Free;
  end;
end;

procedure TMAIN.Acomoda2;
begin
  btnRecuperacion.Align := alLeft;
  btnusercontrol.Align := alLeft;
  btnLC.Align := alLeft;
  btnPrint.Align := alLeft;
  btnManagementTree.Align := alLeft;
  btnTool.Align := alLeft;
  btnViewPanel.Align := alLeft;
end;

procedure TMAIN.Acomoda;
begin
  btnRecuperacion.Align := alNone;
  btnusercontrol.Align := alNone;
  btnLC.Align := alNone;
  btnPrint.Align := alNone;
  btnManagementTree.Align := alNone;
  btnTool.Align := alNone;
  btnViewPanel.Align := alNone;
end;

procedure TMAIN.ViewVarDetail(V: boolean);

  procedure AjustarPaneles;
  begin
    if (cxDBVerticalGrid2.Visible) and (cxDBVerticalGrid2.RecordCount > 0) then
    begin
    // Ajustar la altura del VerticalGrid según el número de filas
      cxDBVerticalGrid2.Align := alNone;
//      cxDBVerticalGrid2.Height := cxDBVerticalGrid2.RecordCount * 24; // Ajuste basado en la altura de fila
      cxDBVerticalGrid2.Align := alTop;
      cxDBVerticalGrid2.Height := 570;

    // Ajustar la Grid con las variables al espacio restante
      gVariablesDetail.Align := alClient;
    end
    else
    begin
    // Si no hay variables, la grid ocupa todo el espacio
      gVariablesDetail.Align := alClient;
      cxDBVerticalGrid2.Visible := False;
    end;
  end;

begin
  cxDBVerticalGrid2.BeginUpdate;
  gVariablesDetail.BeginUpdate;

  // Suponiendo que aquí se detecta si la subserie tiene variables asignadas
  try
    VarCL.DisableControls;
    VarCL.Active := False;
    VarCL.SQL.Clear; //tb_Serietree
    VarCL.SQL.Add('select * from cl_VarSubserie where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString) + ' order by Orden ASC');
    VarCL.Active := True;
    if gVariablesDetail.Visible <> V then
    begin
      if V then
      begin
        gVariablesDetail.Visible := True;
        gVariablesDetail.Align := alNone;
        gVariablesDetail.Height := 10;
        cxDBVerticalGrid2.Visible := True;
        cxDBVerticalGrid2.Align := alNone;
        AjustarPaneles;
      end
      else
      begin
        cxDBVerticalGrid2.align := alclient;
        gVariablesDetail.Visible := False;
  //    cxGrid1.Align := alClient;
      end;
    end;
  finally
    VarCL.EnableControls;
    gVariablesDetailDBTableView1.ApplyBestFit();
    cxDBVerticalGrid2.EndUpdate;
    gVariablesDetail.EndUpdate;
  end;

end;

procedure TMAIN.VisorOptions;
begin
  acceso := 'sin acceso';
  btnViewPanel.Align := alRight;
//  btnRecuperacion.Visible := True;
  btnusercontrol.Visible := False;
  btnLC.Visible := False;
  btnPrint.Visible := False;
  btnManagementTree.Visible := False;
  btnTool.Visible := False;
//  btnViewtopoSS.Visible := False;
  btnViewPanel.Align := alLeft;
end;

procedure TMAIN.adminOptions;
begin
  btnViewPanel.Align := alRight;
  acceso := 'acceso total';
//  btnRecuperacion.Visible := True;
  btnusercontrol.Visible := True;
  btnLC.Visible := True;
  btnManagementTree.Visible := True;
  btnPrint.Visible := True;
  btnTool.Visible := True;
  btnViewPanel.Align := alLeft;
  btnViewtopoSS.Visible := True;
  //botones del mainform
  btnRemoveSerieAsig.Visible := True;
  btnRemoveAllSeriesAsig.Visible := True;
  btnExportExcelCC.Visible := True;
  btnAsignSS.Visible := True;
  btnAsignarSS.Visible := True;
  btnExcelExportSSD.Visible := True;
  btnExportExcelDoc.Visible := True;
//  JvTransparentButton5.Visible := True;
//Archivos Fuentes
  btnRemoveSourceFileList.Visible := True;
  btnDropSourceFile.Visible := True;
  btnExecuteSourceFile.Visible := True;
  btnSourceFile.Visible := True;
  btnAddListSource.Visible := True;
//Archivos digitales
  btnRemoveFileList.Visible := True;
  btnremovefile.Visible := True;
  btnExecFileAD.Visible := True;
  btnaddfile.Visible := True;
  btnaddfilelist.Visible := True;
  cxGrid2DBTableView1fichero.Visible := True;
  cxGrid2DBTableView1observaciones.Visible := True;
end;

procedure TMAIN.AdvPanel10Resize(Sender: TObject);
var
  BtnWidth: Integer;
begin
  BtnWidth := AdvPanel10.Width div 5; // 5 botones
  btnSourceFile.Width := BtnWidth;
  btnAddListSource.Width := BtnWidth;
  btnDropSourceFile.Width := BtnWidth;
  btnRemoveSourceFileList.Width := BtnWidth;
  btnExecuteSourceFile.Width := BtnWidth;
end;

procedure TMAIN.jvcpExpedienteEndAutoDrag(Sender: TObject);
begin
  UDM.Boundarys(Sender);
end;

procedure TMAIN.jvcpSSDetailButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
begin
  if Button = capClose then
  begin
    TJvCaptionPanel(Sender).Visible := False;
    if (UDM.tb_Serietree.State = dsEdit) or (UDM.tb_Serietree.State = dsInsert) then
    begin
      try
        UDM.tb_Serietree.Post;
      except
        on E: EFDException do
        begin
          UDM.sms('No se pudieron salvar los cambios. Motivo: ' + e.Message, 1);
          UDM.tb_Serietree.Cancel;
          Exit;
        end;
      end;

    end;
  end;
end;

procedure TMAIN.jvcpSSDetailEndAutoDrag(Sender: TObject);
begin
  UDM.Boundarys(Sender);
end;

procedure TMAIN.JvTransparentButton11Click(Sender: TObject);
begin
  Application.HelpContext(40);
end;

procedure TMAIN.JvTransparentButton1Click(Sender: TObject);
begin
  jvcpDescripcionEtiq.Visible := False;
end;

procedure TMAIN.JvTransparentButton6Click(Sender: TObject);
begin
  Application.HelpContext(45);
end;

procedure TMAIN.btnManagementTreeClick(Sender: TObject);
begin
  tvTree.Items.BeginUpdate;
  UDM.log('Accediendo al módulo de gestión de estructuras.', 14, '', '', '');
  PContainer.Visible := False;
  PSeriesDatos.Visible := False;
  with TfrmPropiedadesNodo.Create(nil) do
  try
    with Padres do
    begin
      Active := False;
      SQL.Clear;
      if TBD = 'A' then
      begin
        SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta FROM tb_tree where id<>:EE  and visible=true ORDER BY etiqueta ASC');
      end
      else
      begin
        SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta FROM tb_tree where id<>:EE  and visible=1 ORDER BY etiqueta ASC');
      end;
      Params[0].Value := UDM.tb_tree.FieldByName('id').Value;
      Active := True;
    end;
    Caption := 'Administrando el cuadro de clasificación';
    ShowModal;
  finally
    Free;
    UDM.tb_tree.Refresh;
    UDM.tb_arbol.Refresh;
    UDM.CargarArbol(tvTree, UDM.tb_arbol, false);
    UDM.tb_tree.Filtered := True;
    PContainer.Visible := True;
    AnItem := udm.FindNode(tvTree, UDM.tb_tree.FieldByName('id').AsInteger, UDM.tb_tree.FieldByName('Etiqueta').AsString);
    if AnItem <> nil then
    begin
      AnItem.MakeVisible;
      PostMessage(tvTree.Handle, WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(AnItem.DisplayRect(True).Left, AnItem.DisplayRect(True).Top));
    end;
    tvTree.Items.EndUpdate;
  end;
  UDM.log('Abandonando el módulo de gestión de estructuras.', 15, '', '', '');
end;


/// <summary>
/// Asigna una subserie seleccionada a la estructura actual del árbol.
/// Verifica las condiciones necesarias y maneja posibles errores durante el proceso.
/// </summary>
/// <param name="Sender">Objeto que generó el evento</param>
procedure TMAIN.btnAsignSSClick(Sender: TObject);
var
  IdEstructura, CodSubs: Variant;
begin
  // Verificar que UDM esté asignado
  if not Assigned(UDM) then
  begin
    UDM.sms('Error: Módulo de datos no inicializado.', 1);
    Exit;
  end;

  // Verificación de los clasificadores de información
  if not UDM.ValidateTablesForData then
  begin
    UDM.sms('No se puede asignar series o subseries hasta que complete la información de los clasificadores del sistema.', 1);
    Exit;
  end;

  // Verificar que existan datasets necesarios
  if not Assigned(UDM.Tb_SeriesDispo) or not Assigned(UDM.tb_Serietree) or not Assigned(UDM.tb_tree) then
  begin
    UDM.sms('Error: Uno o más datasets necesarios no están disponibles.', 1);
    Exit;
  end;

  // Verificar que existan subseries disponibles
  if not UDM.Tb_SeriesDispo.Active or (UDM.Tb_SeriesDispo.RecordCount = 0) then
  begin
    UDM.sms('No existen subseries disponibles que se puedan agregar.', 2);
    Exit;
  end;

  // Verificar que haya un nodo seleccionado en el árbol
  if not UDM.tb_tree.Active or (UDM.tb_tree.RecordCount = 0) then
  begin
    UDM.sms('No hay una estructura seleccionada para asignar la subserie.', 1);
    Exit;
  end;

  // Guardar valores clave para evitar problemas si cambia el registro activo
  try
    IdEstructura := UDM.tb_tree.FieldByName('IdEstructura').AsString;
    CodSubs := UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString;
  except
    on E: Exception do
    begin
      UDM.sms('Error al obtener información necesaria: ' + E.Message, 1);
      Exit;
    end;
  end;

  // Deshabilitar controles para mejorar rendimiento
  Screen.Cursor := crHourGlass;
  try
    UDM.Tb_SeriesDispo.DisableControls;
    try
      UDM.tb_Serietree.DisableControls;
      try
        // Verificar si la combinación ya existe
        if not UDM.tb_Serietree.Locate('IdEstructura;codsubs', VarArrayOf([IdEstructura, CodSubs]), []) then
        begin
          // Iniciar transacción para garantizar integridad
          UDM.StartTransaction;
          try
            // Agregar nuevo registro
            UDM.tb_Serietree.Append;
            try
              // Asignar valores al nuevo registro
              UDM.tb_Serietree.FieldByName('IdEstructura').AsString := IdEstructura;
              UDM.tb_Serietree.FieldByName('id').AsInteger := UDM.tb_tree.FieldByName('id').AsInteger;
              UDM.tb_Serietree.FieldByName('codsubs').AsString := CodSubs;

              // Verificar que los campos existan antes de asignarlos
              if UDM.Tb_SeriesDispo.FindField('Archivo') <> nil then
                UDM.tb_Serietree.FieldByName('Archivo').AsString := UDM.Tb_SeriesDispo.FieldByName('Archivo').AsString;

              if UDM.Tb_SeriesDispo.FindField('deposito') <> nil then
                UDM.tb_Serietree.FieldByName('deposito').AsString := UDM.Tb_SeriesDispo.FieldByName('deposito').AsString;

              if UDM.Tb_SeriesDispo.FindField('gaveta') <> nil then
                UDM.tb_Serietree.FieldByName('gaveta').AsString := UDM.Tb_SeriesDispo.FieldByName('gaveta').AsString;

              if UDM.Tb_SeriesDispo.FindField('cargo') <> nil then
                UDM.tb_Serietree.FieldByName('gestor').AsString := UDM.Tb_SeriesDispo.FieldByName('cargo').AsString;

              if UDM.Tb_SeriesDispo.FindField('pc') <> nil then
                UDM.tb_Serietree.FieldByName('idservidor').AsString := UDM.Tb_SeriesDispo.FieldByName('pc').AsString;

              // Guardar el registro
              UDM.tb_Serietree.Post;
              UDM.CommitTransaction;

              // Mostrar mensaje de éxito
              UDM.sms('Subserie asignada correctamente.', 0);
            except
              on E: Exception do
              begin
                // Cancelar la edición si hay error
                if UDM.tb_Serietree.State in [dsEdit, dsInsert] then
                  UDM.tb_Serietree.Cancel;

                UDM.RollbackTransaction;
                UDM.sms('La serie ' + UDM.Tb_SeriesDispo.FieldByName('subseries').AsString + ' no se pudo agregar. Motivo: ' + E.Message, 1);
              end;
            end;
          except
            on E: Exception do
            begin
              // Asegurar que se haga rollback si hay error en la transacción
              try
                UDM.RollbackTransaction;
              except
                // Ignorar errores en rollback
              end;
              UDM.sms('Error en la transacción: ' + E.Message, 1);
            end;
          end;
        end
        else
        begin
          UDM.sms('La subserie ya está asignada a esta estructura.', 2);
        end;
      finally
        // Asegurar que los controles se rehabiliten
        UDM.tb_Serietree.EnableControls;
      end;
    finally
      // Asegurar que los controles se rehabiliten
      UDM.Tb_SeriesDispo.EnableControls;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  // Refrescar vista si es necesario
  try
    if Assigned(UDM.tb_Serietree) and UDM.tb_Serietree.Active then
      UDM.tb_Serietree.Refresh;
  except
    on E: Exception do
      UDM.sms('Error al actualizar la vista: ' + E.Message, 2);
  end;
end;
{procedure TMAIN.btnAsignSSClick(Sender: TObject);
begin
//  verificación de los clasficadores de informacion...
  if not UDM.ValidateTablesForData then
  begin
    UDM.sms('No se puede asignar series o subseries hasta que complete la información de los clasificadores del sistema.', 1);
    Exit;  // Evita la asignación si alguna tabla está vacía
  end;

  if UDM.Tb_SeriesDispo.RecordCount = 0 then
  begin
    UDM.sms('No existen subseries disponibles que se puedan agregar.', 2);
    Exit;
  end;
  UDM.Tb_SeriesDispo.DisableControls;
  UDM.tb_Serietree.DisableControls;
  if not UDM.tb_Serietree.Locate('IdEstructura;codsubs', VarArrayOf([UDM.tb_tree.FieldByName('IdEstructura').AsString, UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString]), []) then
  begin
    UDM.tb_Serietree.Append;
    UDM.tb_Serietree.FieldByName('IdEstructura').AsString := UDM.tb_tree.FieldByName('IdEstructura').AsString;
    UDM.tb_Serietree.FieldByName('id').AsInteger := UDM.tb_tree.FieldByName('id').AsInteger;
    UDM.tb_Serietree.FieldByName('codsubs').AsString := UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString;
    UDM.tb_Serietree.FieldByName('Archivo').AsString := UDM.Tb_SeriesDispo.FieldByName('Archivo').AsString;
    UDM.tb_Serietree.FieldByName('deposito').AsString := UDM.Tb_SeriesDispo.FieldByName('deposito').AsString;
    UDM.tb_Serietree.FieldByName('gaveta').AsString := UDM.Tb_SeriesDispo.FieldByName('gaveta').AsString;
    UDM.tb_Serietree.FieldByName('gestor').AsString := UDM.Tb_SeriesDispo.FieldByName('cargo').AsString;
    UDM.tb_Serietree.FieldByName('idservidor').AsString := UDM.Tb_SeriesDispo.FieldByName('pc').AsString;
    //UDM.tb_Serietree.FieldByName('carpeta').AsString := UDM.Tb_SeriesDispo.FieldByName('carpeta').AsString;
    try
      UDM.tb_Serietree.Post;
    except
      on E: EFDException do
      begin
        UDM.sms('La serie ' + UDM.Tb_SeriesDispo.FieldByName('subseries').AsString + ' no se pudo agregar. Motivo: ' + E.Message, 1);
        Exit;
      end;
    end;
  end;
  UDM.tb_Serietree.EnableControls;
  UDM.Tb_SeriesDispo.EnableControls;
end;   }

procedure TMAIN.btnExecFileADClick(Sender: TObject);
var
  pathfile: string;
  cad, Origen, Destino: string;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin  //UDM.tb_ssArchdigital
  if UDM.tb_ssArchdigital.RecordCount <= 0 then
  begin
    UDM.sms('No existen Ficheros fuentes daisponibles que puedan ser ejecutados.', 1);
    exit;
  end;                                                                                                //nombre
  pathfile := UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString + UDM.tb_ssArchdigital.FieldByName('path').AsString + UDM.tb_ssArchdigital.FieldByName('nombre').AsString;
  pathfile := AnsiReplaceStr(pathfile, '\', '/');
  pathfile := AnsiReplaceStr(pathfile, '//', '/');
  Destino := PathTemp + UDM.tb_ssArchdigital.FieldByName('nombre').AsString;
  UDM.DownloadFileFromFTP(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, pathfile, Destino, UDM.cmdServer.FieldByName('puerto').AsInteger);
  if FileExists(Destino) then
//    ejecutaPDF(Destino)
    UDM.EjecutaFichero(Destino)
  else
    udm.sms('No se encontró el fichero "' + UDM.tb_ssArchdigital.FieldByName('nombre').AsString + '" en la ruta especificada.', 1);
end;

procedure TMAIN.btnExpedientePropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  Serie: string;
  NombreEstructura: string;

  procedure PrepararLookupSeries;
  begin
    UDM.LookupSeriesDataSet.DisableControls;
    try
      UDM.LookupSeriesDataSet.EmptyDataSet;
    // Primero agregas "Todos"
      UDM.LookupSeriesDataSet.Append;
      UDM.LookupSeriesDataSet.FieldByName('codsubs').AsInteger := -1;
      UDM.LookupSeriesDataSet.FieldByName('subserie').AsString := 'Todos';
      UDM.LookupSeriesDataSet.Post;

    // Luego copias todos los reales
      UDM.tb_expxseries.First;
      while not UDM.tb_expxseries.Eof do
      begin
        UDM.LookupSeriesDataSet.Append;
        UDM.LookupSeriesDataSet.FieldByName('codsubs').AsVariant := UDM.tb_expxseries.FieldByName('codsubs').AsVariant;
        UDM.LookupSeriesDataSet.FieldByName('subserie').AsString := UDM.tb_expxseries.FieldByName('subserie').AsString;
        UDM.LookupSeriesDataSet.Post;
        UDM.tb_expxseries.Next;
      end;
    finally
      UDM.LookupSeriesDataSet.EnableControls;
      lcbIDExp.KeyValue := -1;
    end;
  end;

  procedure AgregarTodosMaestro;
  begin
    if not UDM.tb_expxseries.Active then
      UDM.tb_expxseries.Open;
    UDM.tb_expxseries.DisableControls;
    try
      UDM.tb_expxseries.Append;
      UDM.tb_expxseries.FieldByName('codsubs').AsInteger := -1; // Usa un ID especial
      UDM.tb_expxseries.FieldByName('subserie').AsString := 'Todos';
      UDM.tb_expxseries.Post;
    finally
      UDM.tb_expxseries.EnableControls;
    end;
  end;

begin
  if AButtonIndex = 0 then
  begin
  // Verificar si el usuario tiene un rol autorizado
    if not IsUserAuthorized(UDM.Rol) then
    begin
      UDM.sms('No tiene permisos para realizar esta acción. Solo los roles administrador, gestor o director pueden consultar expedientes.', 2);
      Exit;
    end;

    try
    // Obtener valores para el log
      Serie := UDM.SudSDetail.FieldByName('serie').AsString;
      NombreEstructura := UDM.SudSDetail.FieldByName('Nombreestructura').AsString;

    // Desactivar los DataSet para asegurar un estado limpio
      UDM.tb_expxseries.Active := False;
      UDM.tb_expxtiposerie.Active := False;

    // Registrar la acción en el log
      UDM.log('Consultando el expediente.', 14, Serie, Serie, NombreEstructura);

    // Activar el DataSet tb_expxseries
      UDM.tb_expxseries.Active := True;

    // Activar el DataSet tb_expxtiposerie
      //UDM.tb_expxtiposerie.Active := True;
      PrepararLookupSeries;
    // Verificar si el documento tiene datos topográficos
      if not HasTopographicData(UDM.tb_SeriesDatos) then
      begin
        UDM.sms('No se puede agregar expedientes porque el documento no tiene especificados los datos topográficos (depósito, gaveta o posición).', 2);
        Exit;
      end;

    // Mostrar el panel de expedientes
      if not UDM.tb_expxtiposerie.Active then
        UDM.tb_expxtiposerie.Active := True;
      if UDM.tb_SeriesDatos.FieldByName('IDExpediente').Value <> null then
        UDM.tb_expxtiposerie.Locate('codigodoc', UDM.tb_SeriesDatos.FieldByName('IDExpediente').Value, []);
      jvcpExpediente.Visible := True;
    except
      on E: Exception do
      begin
        UDM.sms('Error al consultar el expediente: ' + E.Message, 2);
        Exit;
      end;
    end;
  end;
end;

procedure TMAIN.btnExportExcelDocClick(Sender: TObject);
begin
  if UDM.sms('¿Desea exportar el listado de ficheos de la subserie actual?', 4) = 6 then
    ExcelExport(nil, cxGrid2);
end;

procedure TMAIN.L1Click(Sender: TObject);
var
  frmListFTP: TfrmListFTPServer;
begin
  Screen.Cursor := crHourGlass;
  try
    // Ocultar el contenedor
    PContainer.Visible := False;

    // Registrar acceso (con verificación de nulo)
    if Assigned(UDM) then
      UDM.log('Accediendo al clasificador de Servidores FTP.', 14, '', '', '');

    // Crear y mostrar formulario con manejo de excepciones adecuado
    frmListFTP := TfrmListFTPServer.Create(nil);
    try
      frmListFTP.ShowModal;
    finally
      frmListFTP.Free;
      // Asegurar que el contenedor sea visible nuevamente
      PContainer.Visible := True;

      // Actualizar datos y registrar salida (con verificación de nulo)
      if Assigned(UDM) then
      begin
        try
          UDM.cl_ftp_Server.Refresh;
          UDM.cmdServer.Refresh;
        except
          on E: Exception do
            UDM.sms('Error al actualizar datos de servidores FTP: ' + E.Message, 1);
        end;

        UDM.log('Abandonando al clasificador de Servidores FTP.', 15, '', '', '');
      end;

      Screen.Cursor := crDefault;
    end;
  except
    on E: Exception do
    begin
      Screen.Cursor := crDefault;
      PContainer.Visible := True;
      UDM.sms('Error en el clasificador de servidores FTP: ' + E.Message, 1);

      // Registrar error si es posible
      if Assigned(UDM) then
        UDM.log('Error en el clasificador de Servidores FTP: ' + E.Message, 15, '', '', '');
    end;
  end;
end;
{procedure TMAIN.L1Click(Sender: TObject);
begin
  PContainer.Visible := False;
  UDM.log('Accediendo al clasificador de Servidores FTP.', 14, '', '', '');
  with TfrmListFTPServer.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
  UDM.cl_ftp_Server.Refresh;
  UDM.cmdServer.Refresh;
  PContainer.Visible := True;
  UDM.log('Abandonando al clasificador de Servidores FTP.', 15, '', '', '');
end; }

procedure TMAIN.lcbArchivoEnter(Sender: TObject);
begin
  pcDetalle.ActivePage := tsTopo;
end;

procedure TMAIN.lcbArchivoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 112 then
    Application.HelpContext(40);
end;

procedure TMAIN.lcbArchivoPropertiesCloseUp(Sender: TObject);
begin
  {cmdArch.Active := False;
  cmdArch.Params[0].Value := lcbArchivo.EditValue;
  cmdArch.Active := True;
  PrepareSSDetailView; }
end;

procedure TMAIN.lcbGestorEnter(Sender: TObject);
begin
  pcDetalle.ActivePage := tsGestor;
end;

procedure TMAIN.lcbGestorPropertiesCloseUp(Sender: TObject);
begin
  with cmdGestor do
  begin
    Active := False;
    connection := UDM.Conn;
    Params[0].Value := lcbGestor.EditValue;
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pueden consultar los detalles del Gestor actual. Motivo: ' + e.Message, 1);
      end;
    end;
  end;
end;

procedure TMAIN.lcbIDExpCloseUp(Sender: TObject);
var
  cad: string;
begin
  if lcbIDExp.KeyValue <> null then
  begin
    cad := UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
    if lcbIDExp.KeyValue = '-1' then
    begin
      UDM.tb_expxtiposerie.Filtered := False;
      UDM.tb_expxtiposerie.Filter := '';
      {cad := 'SELECT tb_SeriesDatos.codsubs, cl_subseries.subserie, tb_SeriesDatos.Fecha, ';
      cad := cad + 'tb_SeriesDatos.Version, tb_SeriesDatos.codigodoc, ';
      cad := cad + 'tb_SeriesDatos.titulodoc ';
      cad := cad + 'FROM tb_SeriesDatos LEFT JOIN cl_subseries ';
      cad := cad + 'ON tb_SeriesDatos.codsubs = cl_subseries.codsubs;';}
      {cad:='SELECT tb_SeriesDatos.codsubs, cl_subseries.subserie, tb_SeriesDatos.Fecha, ';
      cad:=cad+' tb_SeriesDatos.Version, tb_SeriesDatos.codigodoc, tb_SeriesDatos.titulodoc';
      cad:=cad+' FROM tb_SeriesDatos LEFT JOIN cl_subseries ON tb_SeriesDatos.codsubs = ';
      cad:=cad+ ' cl_subseries.codsubs;';   }
    end
    else
    begin
      UDM.tb_expxtiposerie.Filtered := False;
      cad := 'codsubs = ' + QuotedStr(lcbIDExp.KeyValue);
      cad := cad + 'AND Codigodoc <> ' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString);
      UDM.tb_expxtiposerie.Filtered := False;
      UDM.tb_expxtiposerie.Filter := cad;
      try
        UDM.tb_expxtiposerie.Filtered := True;
        UDM.sms('Existen (' + UDM.tb_expxtiposerie.RecordCount.ToString + ') expedientes disponibles.', 3);
      except

      end;
      {cad := 'SELECT tb_SeriesDatos.codsubs, cl_subseries.subserie, tb_SeriesDatos.Fecha, ';
      cad := cad + 'tb_SeriesDatos.Version, tb_SeriesDatos.codigodoc, ';
      cad := cad + 'tb_SeriesDatos.titulodoc ';
      cad := cad + 'FROM tb_SeriesDatos LEFT JOIN cl_subseries ';
      cad := cad + 'ON tb_SeriesDatos.codsubs = cl_subseries.codsubs ';
      cad := cad + 'WHERE tb_SeriesDatos.codsubs = ' + QuotedStr(lcbIDExp.KeyValue);
      cad := cad + 'AND tb_SeriesDatos.Codigodoc <> ' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString);}
    end;
//    UDM.tb_expxtiposerie.SQL.Add(cad);
//    UDM.tb_expxtiposerie.Active := True;
  end;
end;

procedure TMAIN.lcbServerEnter(Sender: TObject);
begin
  pcDetalle.ActivePage := tsServidor;
end;

procedure TMAIN.LoadComboBoxValues(ComboBoxProperties: TcxComboBoxProperties; tbname, FieldName: string);
var
  Query: TFDQuery;
  ValuesList: TStringList;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := UDM.Conn; // Asegúrate de asignar tu conexión
    Query.SQL.Text := Format('SELECT %s FROM ' + tbname + ' GROUP BY %s', [FieldName, FieldName]);
    Query.Open;

    ValuesList := TStringList.Create;
    try
      while not Query.Eof do
      begin
        ValuesList.Add(Query.FieldByName(FieldName).AsString);
        Query.Next;
      end;
            // Opcional: almacenar en una lista para manejarlo después
      ComboBoxProperties.Items.Assign(ValuesList);
//      FComboBoxAssociations.Add(ComboBoxAssociation);
    finally
      ValuesList.Free;
    end;
  finally
    Query.Free;
  end;
end;

procedure TMAIN.LoadGridLayout(GridView: TcxGridTableView; const LayoutName: string);
var
  Ini: TIniFile;
  VisibleLines: Integer;
begin
  // Si el archivo INI existe, restaurar la configuración
  if FileExists(LayoutName) then
  begin
    GridView.RestoreFromIniFile(LayoutName);

    // Leer el VisibleLineCount manualmente
    Ini := TIniFile.Create(LayoutName);
    try
      VisibleLines := Ini.ReadInteger('GridState', 'VisibleLineCount_titulodoc', 1); // Valor por defecto de 1
      TcxMemoProperties(cxGrid2DBTableView1titulodoc.Properties).VisibleLineCount := VisibleLines;
      //TcxTextEditProperties(cxGrid2DBTableView1titulodoc.Properties).VisibleLineCount := VisibleLines;
      cxSpinEdit1.Value := VisibleLines;
      //Forzar actualización inmediata del grid
      cxGrid2DBTableView1fichero.Visible := False;
      cxGrid2DBTableView1observaciones.Visible := False;
      GridView.LayoutChanged;
      GridView.DataController.Refresh;

    finally
      Ini.Free;
    end;
  end;
end;

procedure TMAIN.LoadTreeStateNode;
var
  i: Integer;
  List: TStringList;
begin
  if FileExists(PathTemp + 'treestatenode.src') then
  begin
    List := TStringList.Create;
    try
      List.LoadFromFile(PathTemp + 'treestatenode.src');
      for i := 0 to List.Count - 1 do
        if List[i] = '1' then
        begin
          UDM.sms(TvTree.Items[i].Text, 1);
          TvTree.Items[i].Expanded := True;
        end
        else
          TvTree.Items[i].Expanded := False;
    except
    end;
    List.Free;
  end;
end;

procedure TMAIN.LoadTreeViewFont(TreeView: TTreeView; const FileName: string);
var
  FileStream: TextFile;
  Line: string;
begin
  AssignFile(FileStream, FileName);
  Reset(FileStream);
  try
    while not Eof(FileStream) do
    begin
      Readln(FileStream, Line);

      // Cargar nombre de la fuente
      if Pos('FontName=', Line) = 1 then
        TreeView.Font.Name := Copy(Line, Length('FontName=') + 1, MaxInt);

      // Cargar tamaño de la fuente
      if Pos('FontSize=', Line) = 1 then
        TreeView.Font.Size := StrToIntDef(Copy(Line, Length('FontSize=') + 1, MaxInt), TreeView.Font.Size);

      // Cargar color de la fuente
      if Pos('FontColor=', Line) = 1 then
        TreeView.Font.Color := StrToInt('$' + Copy(Line, Length('FontColor=') + 1, MaxInt));

      // Cargar estilos de la fuente
      if Pos('FontStyle=', Line) = 1 then
      begin
        TreeView.Font.Style := [];
        while not Eof(FileStream) do
        begin
          Readln(FileStream, Line);
          if Line = 'Bold' then
            TreeView.Font.Style := TreeView.Font.Style + [fsBold];
          if Line = 'Italic' then
            TreeView.Font.Style := TreeView.Font.Style + [fsItalic];
          if Line = 'Underline' then
            TreeView.Font.Style := TreeView.Font.Style + [fsUnderline];
          if Line = 'StrikeOut' then
            TreeView.Font.Style := TreeView.Font.Style + [fsStrikeOut];
        end;
      end;
    end;
  finally
    CloseFile(FileStream);
  end;
end;


{procedure TMAIN.LoadTreeViewFont(TreeView: TTreeView; const FileName: string);
var
  FileStream: TextFile;
  Line: string;
begin
  AssignFile(FileStream, FileName);
  Reset(FileStream);
  try
    while not Eof(FileStream) do
    begin
      Readln(FileStream, Line);

      // Cargar nombre de la fuente
      if Pos('FontName=', Line) = 1 then
        TreeView.Font.Name := Copy(Line, Length('FontName=') + 1, MaxInt);

      // Cargar tamaño de la fuente
      if Pos('FontSize=', Line) = 1 then
        TreeView.Font.Size := StrToIntDef(Copy(Line, Length('FontSize=') + 1, MaxInt), TreeView.Font.Size);

      // Cargar color de la fuente
      if Pos('FontColor=', Line) = 1 then
        TreeView.Font.Color := StrToInt('$' + Copy(Line, Length('FontColor=') + 1, MaxInt));

      // Cargar estilos de la fuente
      if Pos('FontStyle=', Line) = 1 then
      begin
        TreeView.Font.Style := [];
        while not Eof(FileStream) do
        begin
          Readln(FileStream, Line);
          if Line = 'Bold' then
            TreeView.Font.Style := TreeView.Font.Style + [fsBold];
          if Line = 'Italic' then
            TreeView.Font.Style := TreeView.Font.Style + [fsItalic];
          if Line = 'Underline' then
            TreeView.Font.Style := TreeView.Font.Style + [fsUnderline];
          if Line = 'StrikeOut' then
            TreeView.Font.Style := TreeView.Font.Style + [fsStrikeOut];
        end;
      end;
    end;
  finally
    CloseFile(FileStream);
  end;
end; }

procedure TMAIN.logClick(Sender: TObject);
begin
  with TfrmAdminSysLogs.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.MDSeriesSubSeriesDMDR;
begin
  UDM.cl_series.Active := False;
  UDM.cl_subseries.Active := False;
  UDM.cl_subseries.MasterSource := UDM.dscl_series;
  UDM.cl_subseries.MasterFields := 'codserie';
  UDM.cl_subseries.IndexFieldNames := 'codserie;codsubs';
  UDM.cl_series.Active := True;
  UDM.cl_subseries.Active := True;
end;

procedure TMAIN.md_varBeforePost(DataSet: TDataSet);
begin
  DataSet.FieldByName('IdEstructura').AsString := UDM.tb_SeriesDatos.FieldByName('IdEstructura').AsString;
  DataSet.FieldByName('id').AsString := UDM.tb_SeriesDatos.FieldByName('id').AsString;
  DataSet.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
  DataSet.FieldByName('Fecha').AsString := UDM.tb_SeriesDatos.FieldByName('Fecha').AsString;
  DataSet.FieldByName('Version').AsString := UDM.tb_SeriesDatos.FieldByName('Version').AsString;
  DataSet.FieldByName('Codigodoc').AsString := UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
end;

procedure TMAIN.MenuItem11Click(Sender: TObject);
var
  DirAsociado: string;
  CaminoFichero, Path: string;
begin
  if (udm.tb_SeriesDatos.FieldByName('fichero').Value = null) or (trim(udm.tb_SeriesDatos.FieldByName('fichero').asstring) = null) then
  begin
    UDM.sms('Debe especificar un fichero válido para eliminar.', 3);
    Exit;
  end;
  if UDM.sms('¿Está seguro de eliminar el fichero actual?', 4) = 6 then
  begin
    UDM.tb_ssArchdigital.Last;
    while not udm.tb_ssArchdigital.Bof do
    begin
      CaminoFichero := UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString + UDM.tb_ssArchdigital.FieldByName('path').AsString + UDM.tb_ssArchdigital.FieldByName('nombre').AsString;
      try
        UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
      except
      end;
      try
        UDM.tb_ssArchdigital.Delete;
      except
      end;
    end;
    CaminoFichero := UDM.cmdServer.FieldByName('path').AsString + udm.tb_SeriesDatos.FieldByName('fichero').AsString;
    Path := Copy(CaminoFichero, 1, LastDelimiter('/', CaminoFichero));
    DirAsociado := Copy(CaminoFichero, LastDelimiter('/', CaminoFichero) + 1, LastDelimiter('.', CaminoFichero) - LastDelimiter('/', CaminoFichero) - 1);
    DirAsociado := Path + DirAsociado + '/';
    //Elimina AD
    try
      UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado + 'Fuentes/', UDM.cmdServer.FieldByName('puerto').AsInteger);
    except
    end;
    try
      UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado + 'Anexos Digitales/', UDM.cmdServer.FieldByName('puerto').AsInteger);
    except
    end;
    try
      UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado, UDM.cmdServer.FieldByName('puerto').AsInteger);
    except
    end;
    try
      UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
    except
    end;
    UDM.tb_SeriesDatos.Edit;
    UDM.tb_SeriesDatos.FieldByName('fichero').value := Null;
    try
      UDM.tb_SeriesDatos.Post;
      UDM.sms('El fichero se eliminó del sistema satisfactoriamente.', 3);
    except
      on E: EFDException do
      begin
        UDM.tb_SeriesDatos.Cancel;
        UDM.sms('No se pudo eliminar el fichero del sistema. Motivo: ' + e.Message, 1);
      end;
    end;
    ReactiveAnexos;
//    edt1.Text := '(Vacio)';
  end;
end;

procedure TMAIN.MenuItem1Click(Sender: TObject);
begin
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gestión de serie documental');
end;

procedure TMAIN.MenuItem5Click(Sender: TObject);
var
  param, param1, listParam: string;
begin
  {if UDM.tb_SeriesDatos.FieldByName('Fichero').Value = null then
  begin
    UDM.sms('Debe especificar un fichero válido para abrir. El registro actual no contiene ficheros.', 1);
    exit;
  end;}

  screen.Cursor := crSQLWait;
  param := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
  param1 := UDM.tb_SeriesDatos.FieldByName('codigodoc').AsString;
  listParam := AnsiQuotedStr(param, '"') + ' ' + AnsiQuotedStr(param1, '"');
  UDM.RunAndWaitShell(ExtractFilePath(Application.ExeName) + '\PDFExpressViewer.exe', listParam, SW_SHOWMAXIMIZED);
  screen.Cursor := crDefault;
end;
{var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;
  cad, Origen, Destino: string;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  screen.Cursor := crSQLWait;
  try

    if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
    begin
      Origen := UDM.cmdServer.FieldByName('path').AsString + UDM.tb_SeriesDatos.FieldByName('fichero').AsString;
      Origen := AnsiReplaceStr(Origen, '\', '/');
      Origen := AnsiReplaceStr(Origen, '//', '/');
      if trim(UDM.tb_SeriesDatos.FieldByName('namefile').AsString) <> '' then
        Destino := PathTemp + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '.pdf'
      else
        Destino := PathTemp + copy(UDM.tb_SeriesDatos.FieldByName('fichero').AsString, LastDelimiter(UDM.tb_SeriesDatos.FieldByName('fichero').AsString, '/'), length(UDM.tb_SeriesDatos.FieldByName('fichero').AsString));
      if UDM.DownloadFileFromFTP(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, Origen, Destino, UDM.cmdServer.FieldByName('puerto').AsInteger) then
      begin
        if FileExists(Destino) then
        begin
          cad := QuotedStr('P') + ' ' + AnsiQuotedStr(Destino, '"');
          UDM.RunAndWaitShell(PathSys + 'Viewer.exe', cad, SW_SHOWMAXIMIZED);
        end
        else
        begin
          UDM.sms('El fichero no se pudo encontrar en la ruta especificada.', 2);
          Exit;
        end;
      end
      else
      begin
        UDM.sms('No se pudo ejcutar el fichero especificado.', 2);
        Exit;
      end;
    end
    else
    begin
      UDM.sms('Error!!!!. No se encontró un documento para visualizar. Especifique un documento válido para visualizar.', 1);
    end;
  finally
    screen.Cursor := crDefault;
  end;
end; }
{var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;
  cad: string;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
     List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    if FileExists(List[0]) then
    begin
      ext := ExtractFileExt(List[0]);
      if AnsiLowerCase(ext) = '.pdf' then
      begin
        cad := QuotedStr('P') + ' ' + AnsiQuotedStr(List[0], '"');
        UDM.RunAndWaitShell(PathSys + 'Viewer.exe', cad, SW_SHOWMAXIMIZED);
      end;
    end
    else
       UDM.sms('No existe el fichero especificado.', 1);
  end
  else
  begin
    UDM.sms('Error no se encontró un documento para visualizar. Especifique un documento válido para visualizar.', 3);
  end;
end; }

// Procedimiento: TMAIN.mGestionarContentFileClick
// Propósito: Gestiona la construcción de una ruta de archivo y abre una interfaz para manejar
//            archivos en un sistema documental basado en series y subseries.
// Autor: [Generado y refactorizado por Grok 3, xAI]
// Fecha: 09 de abril de 2025 (basado en la fecha actual del sistema)
// Parámetros:
//   Sender: TObject - Objeto que dispara el evento (generalmente un componente de la UI).
// Resultado: No devuelve valor (procedimiento). Ejecuta acciones y notifica errores mediante UDM.sms.
// Excepciones: Maneja errores de base de datos y validaciones, saliendo prematuramente si falla.
// Dependencias externas:
//   - UDM: Unidad de datos que contiene las tablas y métodos como sms, tb_SeriesDatos, etc.
//   - ConstruirRutaArchivo: Función externa que genera la ruta del archivo.
//   - ManagementFileSeries: Procedimiento externo que abre la interfaz de gestión.
// Variables globales modificadas:
//   - Carpeta: Almacena la ruta del servidor.
//   - PathToSaveFile: Almacena la ruta completa del archivo generado.

procedure TMAIN.mGestionarContentFileClick(Sender: TObject);
const
  MSG_TITLE = 'Gestión de documentos de la serie documental'; // Título usado en la interfaz de gestión
var
  ServerPath: string;        // Ruta base del servidor FTP obtenida de cmdServer
  FilePath: string;          // Ruta completa del archivo construida
  IdEstructura: string;      // Identificador de la estructura documental
  CodSerie: string;          // Código de la serie documental
  CodSubs: string;           // Código de la subserie
  CodigoDoc: string;         // Código del documento específico
  IdServidorLocal: string;   // ID del servidor definido en el documento
  IdServidorGlobal: string;  // ID del servidor definido en la estructura
  IdServidor: string;        // ID del servidor seleccionado para usar
  IdSerieTree: Integer;      // Identificador numérico de la serie en la estructura

  // Función interna: DatasetsActivos
  // Propósito: Verifica si todos los datasets necesarios están activos.
  // Retorno: Boolean - True si todos están activos, False si alguno falla.

  function DatasetsActivos: Boolean;
  begin
    Result := UDM.tb_SeriesDatos.Active and UDM.SudSDetail.Active and UDM.cmdServer.Active and UDM.tb_Serietree.Active;
  end;

  // Función interna: GuardarCambiosPendientes
  // Propósito: Guarda cambios en tb_SeriesDatos si está en modo edición o inserción.
  // Retorno: Boolean - True si se guardó con éxito o no había cambios, False si falló.
  function GuardarCambiosPendientes: Boolean;
  begin
    Result := True;
    if UDM.tb_SeriesDatos.State in [dsInsert, dsEdit] then
    begin
      try
        UDM.tb_SeriesDatos.Post; // Intenta guardar los cambios
      except
        on E: Exception do
        begin
          UDM.sms('Error al guardar los cambios en la tabla de gestión de documentos: ' + E.Message, 3);
          Result := False; // Indica fallo en la operación
        end;
      end;
    end;
  end;

  // Función interna: ObtenerDatosPrincipales
  // Propósito: Extrae los valores clave de las tablas para construir la ruta y configurar el servidor.
  // Retorno: Boolean - Siempre True (podría fallar si los campos no existen, pero se asume integridad).
  function ObtenerDatosPrincipales: Boolean;
  begin
    IdEstructura := Trim(UDM.tb_SeriesDatos.FieldByName('IdEstructura').AsString);
    IdSerieTree := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
    CodSubs := Trim(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString);
    CodigoDoc := Trim(UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString);
    IdServidorLocal := Trim(UDM.tb_SeriesDatos.FieldByName('Idservidor').AsString);
    ServerPath := Trim(UDM.cmdServer.FieldByName('path').AsString);
    CodSerie := Trim(UDM.SudSDetail.FieldByName('codserie').AsString);
    Result := True;
  end;

  // Función interna: ValidarSubserieEnEstructura
  // Propósito: Confirma que la subserie existe en tb_Serietree según los identificadores.
  // Retorno: Boolean - True si se encuentra, False si no (notifica al usuario).
  function ValidarSubserieEnEstructura: Boolean;
  begin
    Result := UDM.tb_Serietree.Locate('IdEstructura;id;codsubs', VarArrayOf([IdEstructura, IdSerieTree, CodSubs]), []);
    if not Result then
      UDM.sms('No se ha podido localizar la subserie en la estructura actual.' + sLineBreak + Format('IdEstructura: %s, id: %d, codsubs: %s', [IdEstructura, IdSerieTree, CodSubs]), 2);
  end;

  // Función interna: DeterminarServidor
  // Propósito: Resuelve qué servidor usar (local o global) y actualiza tb_SeriesDatos si es necesario.
  // Retorno: Boolean - True si se determinó un servidor válido, False si ambos están vacíos o falla la actualización.
  function DeterminarServidor: Boolean;
  begin
    IdServidorGlobal := Trim(UDM.tb_Serietree.FieldByName('Idservidor').AsString);
    Result := False;

    // Caso 1: Servidor global vacío, advertir pero usar local
    if (IdServidorGlobal = '') or (IdServidorGlobal = '0') then
    begin
      UDM.sms('Advertencia: No hay un servidor definido para la subserie en la estructura actual.' + sLineBreak + 'Complete la topografía de la estructura.', 1);
      exit;
    end;

    // Caso 2: Servidor local vacío, usar y actualizar con el global
    if IdServidorLocal = '' then
    begin
      try
        UDM.tb_SeriesDatos.Edit;
        UDM.tb_SeriesDatos.FieldByName('Idservidor').AsString := IdServidorGlobal;
        UDM.tb_SeriesDatos.Post;
        IdServidorLocal := IdServidorGlobal; // Sincroniza la variable local
      except
        on E: Exception do
        begin
          UDM.sms('Error al actualizar Servidor FTP en el documento actual: ' + E.Message, 3);
          UDM.tb_SeriesDatos.Cancel; // Revierte cambios en caso de fallo
          Exit;
        end;
      end;
    end;

    IdServidor := IdServidorLocal; // Selecciona el servidor local (original o actualizado)
    Result := True;
  end;

  // Función interna: ValidarDatosRequeridos
  // Propósito: Verifica que todos los datos necesarios para construir la ruta estén presentes.
  // Retorno: Boolean - True si todos los datos son válidos, False si falta algo (notifica al usuario).
  function ValidarDatosRequeridos: Boolean;
  begin
    Result := False;
    if ServerPath = '' then
    begin
      UDM.sms('El servidor FTP no tiene una ruta definida en el clasificador de Servidores.', 2);
      Exit;
    end;
    if (IdEstructura = '') or (CodSerie = '') or (CodSubs = '') or (CodigoDoc = '') then
    begin
      UDM.sms('Faltan datos necesarios para construir la ruta del archivo:' + sLineBreak + 'Estructura, Serie, subserie o el código del documento están vacíos.', 2);
      Exit;
    end;
    Result := True;
  end;

begin
  // Paso 1: Validar que todos los datasets necesarios estén activos
  if not DatasetsActivos then
  begin
    UDM.sms('Uno o más conjuntos de datos necesarios no están disponibles.', 2);
    Exit;
  end;

  // Paso 2: Guardar cambios pendientes en tb_SeriesDatos
  if not GuardarCambiosPendientes then
    Exit;

  // Paso 3: Obtener los datos principales de las tablas
  if not ObtenerDatosPrincipales then
    Exit;

  // Paso 4: Validar que la subserie existe en la estructura
  if not ValidarSubserieEnEstructura then
    Exit;

  // Paso 5: Determinar qué servidor usar y actualizar si es necesario
  if not DeterminarServidor then
    Exit;

  // Paso 6: Validar que todos los datos requeridos estén presentes
  if not ValidarDatosRequeridos then
    Exit;

  // Paso 7: Construir la ruta del archivo usando la función externa
  FilePath := ConstruirRutaArchivo(ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc);
  if FilePath = '' then
  begin
    UDM.sms('No se pudo construir una ruta válida para el archivo.', 2);
    Exit;
  end;

  // Paso 8: Asignar variables globales y abrir la interfaz de gestión
  Carpeta := ServerPath;
  PathToSaveFile := FilePath;
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', MSG_TITLE);
end;

{procedure TMAIN.mGestionarContentFileClick(Sender: TObject);
const
  MSG_TITLE = 'Gestión de serie documental';
var
  ServerPath: string;
  FilePath: string;
  IdEstructura, CodSerie, CodSubs, CodigoDoc, IdServidorLocal, IdServidorGlobal, IdServidor: string;
  IdSerieTree: Integer;
begin
  // Validar datasets necesarios
  if not (UDM.tb_SeriesDatos.Active and UDM.SudSDetail.Active and UDM.cmdServer.Active and UDM.tb_Serietree.Active) then
  begin
    UDM.sms('Uno o más conjuntos de datos necesarios no están disponibles.', 2);
    Exit;
  end;

  // Guardar cambios pendientes en tb_SeriesDatos
  if UDM.tb_SeriesDatos.State in [dsInsert, dsEdit] then
  try
    UDM.tb_SeriesDatos.Post;
  except
    on E: Exception do
    begin
      UDM.sms('Error al guardar los cambios en la tabla de gestión de documentos: ' + E.Message, 3);
      Exit;
    end;
  end;

  // Obtener valores de tb_SeriesDatos
  IdEstructura := Trim(UDM.tb_SeriesDatos.FieldByName('IdEstructura').AsString);
  IdSerieTree := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
  CodSubs := Trim(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString);
  CodigoDoc := Trim(UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString);
  IdServidorLocal := Trim(UDM.tb_SeriesDatos.FieldByName('Idservidor').AsString);

  // Obtener valores adicionales
  ServerPath := Trim(UDM.cmdServer.FieldByName('path').AsString);
  CodSerie := Trim(UDM.SudSDetail.FieldByName('codserie').AsString);

  // Validar topografía en tb_Serietree
  if not UDM.tb_Serietree.Locate('IdEstructura;id;codsubs', VarArrayOf([IdEstructura, IdSerieTree, CodSubs]), []) then
  begin
    UDM.sms('No se ha podido localizar la subserie en la estructura actual.' + sLineBreak +
            Format('IdEstructura: %s, id: %d, codsubs: %s', [IdEstructura, IdSerieTree, CodSubs]), 2);
    Exit;
  end;

  // Obtener Idservidor global desde tb_Serietree
  IdServidorGlobal := Trim(UDM.tb_Serietree.FieldByName('Idservidor').AsString);

  // Lógica de manejo de Idservidor
  if (IdServidorLocal = '') and (IdServidorGlobal = '') then
  begin
    UDM.sms('No se especificó un servidor FTP ni en el documento ni en la estructura actual.' + sLineBreak +
            'Defina un servidor para gestionar los ficheros.', 3);
    Exit;
  end
  else if IdServidorLocal = '' then
  begin
    // Actualizar tb_SeriesDatos con el servidor global
    UDM.tb_SeriesDatos.Edit;
    try
      UDM.tb_SeriesDatos.FieldByName('Idservidor').AsString := IdServidorGlobal;
      UDM.tb_SeriesDatos.Post;
      IdServidorLocal := IdServidorGlobal; // Actualizar variable local
    except
      on E: Exception do
      begin
        UDM.sms('Error al actualizar Servidor FTP en el documento actual. Revise el valor en la topografía de la estructura actual. Error: ' + E.Message, 3);
        UDM.tb_SeriesDatos.Cancel;
        Exit;
      end;
    end;
  end
  else if (IdServidorGlobal = '') and (IdServidorLocal <> '') then
  begin
    UDM.sms('Advertencia: No hay un servidor definido para la subserie en la estructura actual.' + sLineBreak +
            'Se usará el servidor definido en el documento (' + IdServidorLocal + ').', 1);
  end;

  // Usar el servidor local (ya sea original o actualizado desde global)
  IdServidor := IdServidorLocal;

  // Validaciones específicas
  if ServerPath = '' then
  begin
    UDM.sms('El servidor FTP no tiene una ruta definida en el clasificador de Servidores.', 2);
    Exit;
  end;

  if (IdEstructura = '') or (CodSerie = '') or (CodSubs = '') or (CodigoDoc = '') then
  begin
    UDM.sms('Faltan datos necesarios para construir la ruta del archivo:' + sLineBreak +
            'Estructura, Serie, subserie o el código del documento están vacíos.', 2);
    Exit;
  end;

  // Construir la ruta del archivo
  FilePath := ConstruirRutaArchivo(ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc);
  if FilePath = '' then
  begin
    UDM.sms('No se pudo construir una ruta válida para el archivo.', 2);
    Exit;
  end;

  // Asignar variables globales y abrir la interfaz de gestión
  Carpeta := ServerPath;
  PathToSaveFile := FilePath;
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', MSG_TITLE);
end; }

function TMAIN.ConstruirRutaArchivo(const ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc: string): string;
var
  Builder: TStringBuilder;
begin
  Result := '';
  Builder := TStringBuilder.Create;
  try
    Builder.Append(ServerPath);
    if not ServerPath.EndsWith(PathDelim) then
      Builder.Append(PathDelim);
    Builder.Append(IdEstructura).Append(PathDelim).Append(CodSerie).Append(PathDelim).Append(CodSubs).Append(PathDelim).Append(CodigoDoc);
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;


{procedure TMAIN.mGestionarContentFileClick(Sender: TObject);
const
  MSG_TITLE = 'Gestión de serie documental';
var
  ServerPath: string;
  FilePath: string;
  IdEstructura, CodSerie, CodSubs, CodigoDoc, IdServidor: string;
begin
  // Validar datasets necesarios
  if not (UDM.tb_SeriesDatos.Active and UDM.SudSDetail.Active and UDM.cmdServer.Active) then
  begin
    UDM.sms('Uno o más conjuntos de datos necesarios no están disponibles.', 2);
    Exit;
  end;
  // Guardar cambios pendientes en tb_SeriesDatos
  if UDM.tb_SeriesDatos.State in [dsInsert, dsEdit] then
  try
    UDM.tb_SeriesDatos.Post;
  except
    on E: Exception do
    begin
      UDM.sms('Error al guardar los cambios en tb_SeriesDatos: ' + E.Message, 3);
      Exit;
    end;
  end;

  // Obtener y validar los valores necesarios
  ServerPath := Trim(UDM.cmdServer.FieldByName('path').AsString);
  IdEstructura := Trim(UDM.tb_SeriesDatos.FieldByName('IdEstructura').AsString);
  CodSerie := Trim(UDM.SudSDetail.FieldByName('codserie').AsString);
  CodSubs := Trim(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString);
  CodigoDoc := Trim(UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString);
  IdServidor := Trim(UDM.tb_SeriesDatos.FieldByName('Idservidor').AsString);

  // Validaciones específicas
  if ServerPath = '' then
  begin
    UDM.sms('El servidor FTP no tiene una ruta definida en cmdServer.path.', 2);
    Exit;
  end;

  if IdServidor = '' then
  begin
    UDM.sms('No se especificó un servidor FTP en la topografía de la subserie actual.' + sLineBreak +
            'Por favor, defina un servidor para gestionar los ficheros.', 3);
    Exit;
  end;

  if (IdEstructura = '') or (CodSerie = '') or (CodSubs = '') or (CodigoDoc = '') then
  begin
    UDM.sms('Faltan datos necesarios para construir la ruta del archivo:' + sLineBreak +
            'IdEstructura, codserie, codsubs o Codigodoc están vacíos.', 2);
    Exit;
  end;

  // Construir la ruta del archivo
  FilePath := ConstruirRutaArchivo(ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc);
  if FilePath = '' then
  begin
    UDM.sms('No se pudo construir una ruta válida para el archivo.', 2);
    Exit;
  end;

  // Asignar variables globales y abrir la interfaz de gestión
  Carpeta := ServerPath;
  PathToSaveFile := FilePath;
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', MSG_TITLE);
end;

function TMAIN.ConstruirRutaArchivo(const ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc: string): string;
var
  Builder: TStringBuilder;
begin
  Result := '';
  Builder := TStringBuilder.Create;
  try
    Builder.Append(ServerPath);
    if not ServerPath.EndsWith(PathDelim) then
      Builder.Append(PathDelim);
    Builder.Append(IdEstructura).Append(PathDelim)
           .Append(CodSerie).Append(PathDelim)
           .Append(CodSubs).Append(PathDelim)
           .Append(CodigoDoc);
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;   }

{var
  cad: string;
begin
  if (UDM.tb_SeriesDatos.State = dsInsert) or (UDM.tb_SeriesDatos.State = dsedit) then
    UDM.tb_SeriesDatos.Post;
  Carpeta := UDM.cmdServer.FieldByName('path').AsString;
  cad := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\';
  PathToSaveFile := cad + UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
  if (UDM.tb_Serietree.FieldByName('idservidor').Value = null) or (trim(UDM.tb_Serietree.FieldByName('idservidor').AsString) = '') then
  begin
    UDM.sms('No se encontró una ruta válida para almacenar las subseries.', 2);
    udm.sms('Por favor defina un servidor y una ruta válida para guardar las subseries documentales.', 3);
    Exit;
  end;
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gestión de serie documental');
end; }

procedure TMAIN.MtvFontClick(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    // Asignar la fuente seleccionada al TreeView
    tvTree.Font.Assign(FontDialog1.Font);
  end;
end;

procedure TMAIN.OcultaVGVardef;
var
  i: Integer;
begin
 // UDM.tb_SeriesDatos.DisableControls;
  for i := 1 to 10 do
  begin
    s := 'iv' + inttostr(i);
    TcxDBEditorRow(FindComponent(s)).Visible := false;
    TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := '';
  end;
 // UDM.tb_SeriesDatos.EnableControls;
end;

procedure TMAIN.OcultaVGVardefPrj;
var
  i: Integer;
begin
  for i := 1 to 10 do
  begin
    s := 'iv1' + inttostr(i);
    TcxDBEditorRow(FindComponent(s)).Visible := false;
    TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := '';
  end;
end;

procedure TMAIN.OptimizerTimer(Sender: TObject);
begin
  udm.TrimAppMemorySize;
  Application.ProcessMessages;
end;

/// <summary>
/// Procedimiento para acceder al clasificador de series documentales.
/// Gestiona transacciones, actualiza múltiples datasets y vistas relacionadas.
/// </summary>
/// <param name="Sender">Objeto que generó el evento</param>
procedure TMAIN.S1Click(Sender: TObject);
var
  frmCLSeries: TfrmCLSeries;
  ModalResult: Integer;
  TransactionStarted: Boolean;
begin
  // Validar componentes críticos
  if not Assigned(PContainer) then
  begin
    UDM.sms('Error: El contenedor de la interfaz principal no está asignado.', 1);
    Exit;
  end;

  if not Assigned(UDM) then
  begin
    UDM.sms('Error: El módulo de datos no está inicializado.', 1);
    Exit;
  end;

  TransactionStarted := False;
  Screen.Cursor := crHourGlass;
  try
    // Ocultar el contenedor
    PContainer.Visible := False;

    // Registrar el acceso al clasificador
    UDM.log('Accediendo al clasificador de series documentales.', LOG_ACCESO_CLASIFICADOR, '', '', '');

    // Iniciar transacción
    UDM.StartTransaction;
    TransactionStarted := True;

    try
      // Preparar datos maestros-detalle
      try
        MDSeriesSubSeriesDMDR;
      except
        on E: Exception do
        begin
          UDM.log('Error al preparar datos maestros-detalle: ' + E.Message, LOG_ERROR_CLASIFICADOR, '', '', '');
          UDM.sms('Error al configurar los componentes de acceso a datos: ' + E.Message, 1);
          raise;
        end;
      end;

      // Crear y mostrar el formulario
      frmCLSeries := TfrmCLSeries.Create(Self); // Usar Self como propietario
      try
        ModalResult := frmCLSeries.ShowModal;

        if ModalResult = mrOk then
        begin
          // Refrescar datasets después de cambios
          Screen.Cursor := crSQLWait;
          try
            // Actualizar datasets con verificación de asignación y actividad
            if Assigned(UDM.cl_series) and UDM.cl_series.Active then
            begin
              UDM.cl_series.DisableControls;
              try
                UDM.cl_series.Refresh;
              finally
                UDM.cl_series.EnableControls;
              end;
            end;

            if Assigned(UDM.cl_subseries) and UDM.cl_subseries.Active then
            begin
              UDM.cl_subseries.DisableControls;
              try
                UDM.cl_subseries.Refresh;
              finally
                UDM.cl_subseries.EnableControls;
              end;
            end;

            if Assigned(UDM.AllSubSerie) and UDM.AllSubSerie.Active then
            begin
              UDM.AllSubSerie.DisableControls;
              try
                UDM.AllSubSerie.Refresh;
              finally
                UDM.AllSubSerie.EnableControls;
              end;
            end;

            // Actualizar vistas
            try
              PrepareSSDisp;
              PrepareSSDetailView;
              PrepareServerDetailView;
              ArchivoActual;
            except
              on E: Exception do
              begin
                UDM.log('Error al actualizar vistas: ' + E.Message, LOG_ERROR_CLASIFICADOR, '', '', '');
                UDM.sms('Error al actualizar vistas: ' + E.Message, 1);
                // No relanzamos la excepción para permitir que la transacción se confirme con los cambios realizados
              end;
            end;

            // Confirmar cambios
            UDM.CommitTransaction;
            TransactionStarted := False;
          finally
            Screen.Cursor := crDefault;
          end;
        end
        else
        begin
          // Deshacer si se cancela
          UDM.RollbackTransaction;
          TransactionStarted := False;
        end;
      finally
        frmCLSeries.Free;

        // Limpiar datos maestros-detalle
        try
          RemoveMDSeriesSubSeriesDMDR;
        except
          on E: Exception do
            UDM.log('Error al limpiar datos maestros-detalle: ' + E.Message, LOG_ERROR_CLASIFICADOR, '', '', '');
        end;
      end;
    except
      on E: Exception do
      begin
        // Deshacer en caso de error si la transacción sigue activa
        if TransactionStarted then
        begin
          UDM.RollbackTransaction;
          TransactionStarted := False;
        end;

        UDM.log('Error al tratar de acceder al clasificador de series y subseries: ' + E.Message, LOG_ERROR_CLASIFICADOR, '', '', '');
        UDM.sms('Error en el clasificador de series: ' + E.Message, 1);
      end;
    end;
  finally
    // Estas operaciones siempre deben ejecutarse
    if TransactionStarted then
    begin
      try
        UDM.RollbackTransaction;
      except
        // Ignorar errores al hacer rollback final
      end;
    end;

    PContainer.Visible := True;
    UDM.log('Abandonando al clasificador de series y subseries documentales.', LOG_SALIDA_CLASIFICADOR, '', '', '');
    Screen.Cursor := crDefault;
  end;
end;
{procedure TMAIN.S1Click(Sender: TObject);
begin
  UDM.log('Accediendo al clasificador de series documentales.', 14, '', '', '');
  PContainer.Visible := False;
  with TfrmCLSeries.Create(nil) do
  try
    MDSeriesSubSeriesDMDR;
    ShowModal;
  finally
    Free;
    RemoveMDSeriesSubSeriesDMDR
  end;
  UDM.cl_series.Refresh;
  UDM.cl_subseries.Refresh;
  UDM.AllSubSerie.Refresh;
  Screen.Cursor := crSQLWait;
  PrepareSSDisp;
  PrepareSSDetailView;
  PrepareServerDetailView;
  ArchivoActual;
  Screen.Cursor := crDefault;
  PContainer.Visible := True;
  UDM.log('Abandonando al clasificador de series y subseries documentales.', 15, '', '', '');
end;  }

procedure TMAIN.S2Click(Sender: TObject);
begin
  {with TfrmCLSoporte.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;}
end;

procedure TMAIN.SaveGridLayout(GridView: TcxGridTableView; const LayoutName: string);
var
  Ini: TIniFile;
begin
  // Guarda la configuración actual del cxGrid en un archivo INI
  GridView.StoreToIniFile(LayoutName);
  // Guardar manualmente el VisibleLineCount
  Ini := TIniFile.Create(LayoutName);
  try
    Ini.WriteInteger('GridState', 'VisibleLineCount_titulodoc', TcxMemoProperties(cxGrid2DBTableView1titulodoc.Properties).VisibleLineCount);
  finally
    Ini.Free;
  end;
end;

procedure TMAIN.SaveTreeStateNode;
var
  i: integer;
  List: TStringList;
begin
  List := TStringList.Create;
  for i := 0 to TvTree.Items.Count - 1 do
    if TvTree.Items[i].Expanded then
    begin
      TvTree.Items[i].Index;
    end
    else
      List.Add('0');
  try
    List.SaveToFile(PathTemp + 'treestatenode.src');
  except
  end;

  List.Free;
end;

procedure TMAIN.SaveTreeViewFont(TreeView: TTreeView; const FileName: string);
var
  FileStream: TextFile;
begin
  AssignFile(FileStream, FileName);
  Rewrite(FileStream);
  try
    // Guardar nombre de la fuente
    Writeln(FileStream, 'FontName=' + TreeView.Font.Name);

    // Guardar tamaño de la fuente
    Writeln(FileStream, 'FontSize=' + IntToStr(TreeView.Font.Size));

    // Guardar color de la fuente en formato hexadecimal
    Writeln(FileStream, 'FontColor=' + IntToHex(TreeView.Font.Color, 6));

    // Guardar estilos de la fuente (Bold, Italic, etc.)
    Writeln(FileStream, 'FontStyle=');
    if fsBold in TreeView.Font.Style then
      Writeln(FileStream, 'Bold');
    if fsItalic in TreeView.Font.Style then
      Writeln(FileStream, 'Italic');
    if fsUnderline in TreeView.Font.Style then
      Writeln(FileStream, 'Underline');
    if fsStrikeOut in TreeView.Font.Style then
      Writeln(FileStream, 'StrikeOut');
  finally
    CloseFile(FileStream);
  end;
end;

procedure TMAIN.seriesvalorarClick(Sender: TObject);
begin
  UDM.MostrarReporte('SeriesValorar'); {
  if ((TRIM(UDM.tb_sysconfig.FieldByName('empresa').AsString) <> '') and (not TBlobField(UDM.tb_sysconfig.FieldByName('logo')).IsNull)) then
  begin
       //lo mismo
    UDM.log('Visualizando el reporte de series a valorar.', 14, '', '', '');
    TBlobField(UDM.tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
    CargaReporte(frxMain, pathreport + 'rSeriesValorar.fr3', 'empresa', UDM.tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png');
  end
  else
  begin
    MessageDlg('Debe configurar los Datos de la Empresa. Consulte la interface de configuración del Sistema.', mtError, [mbOK], 0);
  end;    }
end;

// Procedimiento: TMAIN.ShowVariablesForSubserie
// Propósito: Muestra las variables asociadas a una subserie en un grid vertical,
//            validando la existencia de datasets, tablas y consistencia de datos.
// Autor: [Refactorizado por Grok 3, xAI]
// Fecha: 11 de abril de 2025
// Mejoras aplicadas:
//   - Uso de UDM.sms para todos los mensajes.
//   - Validación explícita de la variable 'cadena' antes de usarla.
//   - Verificación de consistencia entre cl_VarSubserie y la tabla física usando TFDMetaInfoQuery.
//   - Consultas parametrizadas para mayor seguridad y rendimiento.
//   - Compatibilidad con MS Access y SQL Server.
//   - Manejo de errores más específico con mensajes detallados.
//   - Validaciones adicionales para datasets y componentes.

procedure TMAIN.ShowVariablesForSubserie;
const
  MSG_DATASET_INACTIVO = 'El dataset requerido no está activo. Por favor, verifique la configuración.';
  MSG_SUBSERIE_VACIA = 'No se especificó una subserie válida.';
  MSG_TABLA_INVALIDA = 'La tabla de metadatos "%s" no es válida o no existe.';
  MSG_CONSULTA_VACIA = 'No se pudo generar una consulta válida para la subserie.';
  MSG_CAMPO_DISCREPANCIA = 'Los campos definidos en cl_VarSubserie no coinciden con la tabla física "%s".';
  MSG_Deadlock = 'Error al cargar los datos de la subserie: %s';
  MSG_SERIE_NO_ENCONTRADA = 'No se encontró la serie asociada a la subserie: %s';
  MSG_LOCATE_SERIE = 'No se pudo posicionar en la serie: %s';
  MSG_LOCATE_SUBSERIE = 'No se pudo posicionar en la subserie: %s';
var
  serie, cadena, subserie, nombretmptable: string;
  existe, Flag: Boolean;
  Query: TFDQuery;
  MetaInfoQuery: TFDMetaInfoQuery;
  CamposTabla, CamposDefinidos: TStringList;

  // Valida si los campos definidos coinciden con la tabla física

  function ValidarConsistenciaTabla(const Tabla: string; const Subserie: string): Boolean;
  var
    i: Integer;
    Campo: string;
  begin
    Result := False;
    CamposTabla := TStringList.Create;
    CamposDefinidos := TStringList.Create;
    try
      // Obtener campos de la tabla física usando TFDMetaInfoQuery
      MetaInfoQuery := TFDMetaInfoQuery.Create(nil);
      try
        MetaInfoQuery.Connection := UDM.Conn;
        MetaInfoQuery.MetaInfoKind := mkTableFields;
        MetaInfoQuery.ObjectName := Tabla;
        MetaInfoQuery.Open;
        while not MetaInfoQuery.Eof do
        begin
          CamposTabla.Add(AnsiLowerCase(MetaInfoQuery.FieldByName('COLUMN_NAME').AsString));
          MetaInfoQuery.Next;
        end;
        MetaInfoQuery.Close;
      finally
        MetaInfoQuery.Free;
      end;

      // Obtener campos definidos en cl_VarSubserie
      Query.SQL.Text := 'SELECT NomVariable FROM cl_VarSubserie WHERE codsubs = :codsubs';
      Query.ParamByName('codsubs').AsString := Subserie;
      Query.Open;
      while not Query.Eof do

      begin
        CamposDefinidos.Add(AnsiLowerCase(Query.FieldByName('NomVariable').AsString));
        Query.Next;
      end;
      Query.Close;

      // Verificar que todos los campos definidos existan en la tabla
      for i := 0 to CamposDefinidos.Count - 1 do
      begin
        Campo := CamposDefinidos[i];
        if CamposTabla.IndexOf(Campo) = -1 then
        begin
          UDM.sms(Format(MSG_CAMPO_DISCREPANCIA, [Tabla]), 1);
          Exit;
        end;
      end;
      Result := True;
    finally
      CamposTabla.Free;
      CamposDefinidos.Free;
    end;
  end;

begin
  // Forzar cursor predeterminado
  Screen.Cursor := crDefault;
  try
    // Validar datasets
    if not (UDM.SudSDetail.Active and UDM.tb_SeriesDatos.Active and UDM.cl_series.Active and UDM.cl_subseries.Active) then
    begin
//      UDM.sms(MSG_DATASET_INACTIVO, 1);
      Exit;
    end;
//    tsVar.TabVisible := False;
    // Obtener subserie
    subserie := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
    if subserie = '' then
      subserie := UDM.tb_Serietree.FieldByName('codsubs').AsString;
    if Trim(subserie) = '' then
    begin
      UDM.sms(MSG_SUBSERIE_VACIA, 1);
      Exit;
    end;
    cadena := 'SELECT cl_subseries.codserie FROM cl_subseries' + ' WHERE (((cl_subseries.codsubs)=' + QuotedStr(subserie) + '))' + ' GROUP BY cl_subseries.codserie;';
    serie := UDM.Conn.ExecSQLScalar(cadena);
    // Crear query reutilizable
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := UDM.Conn;

      // Verificar variables asociadas
      Query.SQL.Text := 'SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs =' + QuotedStr(subserie);
//      Query.ParamByName('codsubs').AsString := subserie;
      Query.Open;
      Flag := Query.Fields[0].AsInteger > 0;
      Query.Close;

      // Actualizar visibilidad de la pestaña
      if Flag <> tsVar.TabVisible then
        tsVar.TabVisible := Flag;
      ViewVarDetail(tsVar.TabVisible);

      // Obtener serie
      Query.SQL.Text := 'SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs =' + QuotedStr(subserie);
      Query.Open;
      if Query.IsEmpty then
      begin
//        UDM.sms(Format(MSG_SERIE_NO_ENCONTRADA, [subserie]), 1);
        Exit;
      end;
//      serie := Query.FieldByName('codserie').AsString;
      Query.Close;

      // Generar nombre de la tabla
      nombretmptable := UDM.QuitaCaracter('md_' + serie + subserie);
      if (nombretmptable = 'md_') or (Trim(nombretmptable) = '') then
      begin
//        UDM.sms(Format(MSG_TABLA_INVALIDA, [nombretmptable]), 1);
        Exit;
      end;

      // Verificar existencia de la tabla
      existe := UDM.TablaExiste(UDM.Conn, nombretmptable);
      if not existe then
      begin
//        UDM.sms(Format(MSG_TABLA_INVALIDA, [nombretmptable]), 1);
        Exit;
      end;

      // Validar consistencia de la tabla con las definiciones
      if not ValidarConsistenciaTabla(nombretmptable, subserie) then
        Exit;

      // Configurar UI
      pVerticalTitle.Caption := ' Subserie: ' + subserie;
      if not UDM.cl_series.Locate('codserie', serie, []) then
        UDM.sms(Format(MSG_LOCATE_SERIE, [serie]), 2);
      if not UDM.cl_subseries.Locate('codserie;codsubs', VarArrayOf([serie, subserie]), []) then
        UDM.sms(Format(MSG_LOCATE_SUBSERIE, [subserie]), 2);

      // Configurar md_var
      md_var.Active := False;
      md_var.SQL.Clear;
//      cadena := UDM.GenerarConsultaSQL(UDM.cl_VarSubserie, 'SELECT NombreTablaMetadatos FROM cl_subseries WHERE codsubs = :codsubs', subserie);
      cadena := UDM.GenerarConsultaSQL(UDM.cl_VarSubSerie, 'SELECT NombreTablaMetadatos FROM cl_subseries WHERE codsubs = ' + QuotedStr(subserie));
      if Trim(cadena) = '' then
      begin
//        UDM.sms(MSG_CONSULTA_VACIA, 1);
        Exit;
      end;
      md_var.SQL.Text := cadena;

      // Configurar md_def
      md_def.Active := False;
      md_def.SQL.Clear;
      md_def.SQL.Text := 'SELECT NomVariable, Etiqueta, descripcion FROM cl_VarSubserie WHERE codsubs = :codsubs ORDER BY orden ASC';
      md_def.ParamByName('codsubs').AsString := subserie;

      // Abrir datasets
      try
        md_var.Open;
        md_def.Open;
        CreateVerticalGridRows(cxDBVerticalGrid3, md_var, md_def);
        ApplyBestFit(cxDBVerticalGrid3);
      except
        on E: Exception do
        begin
//          UDM.sms(Format(MSG_Deadlock, [E.Message]), 1);
          Exit;
        end;
      end;
    finally
      Query.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;


// Función para obtener el valor de subserie

// Método refactorizado
{procedure TMAIN.ShowVariablesForSubserie;
var
  subserie: string;
  hasVariables: Boolean;
begin
  subserie := GetSubserie;
  if subserie = '' then
    Exit;

  hasVariables := HasVariablesForSubserie(subserie);
  ViewVarDetail(hasVariables); // Mover la lógica de visibilidad a otro evento

  if hasVariables then
    ConfigureVariablesGrid(subserie);
end;  }

{procedure TMAIN.ShowVariablesForSubserie;
var
  serie, cadena: string;
  existe, Flag: Boolean;
  nombretmptable, subserie: string;
begin
  if not UDM.SudSDetail.Active then
    Exit;
  if not UDM.tb_SeriesDatos.Active then
    Exit;

  subserie := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
  if subserie = '' then
    subserie := UDM.tb_Serietree.FieldByName('codsubs').AsString;
  if subserie = '' then
    Exit;

  Flag := UDM.Conn.ExecSQLScalar('SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs = ' + QuotedStr(subserie)) > 0;
  if Flag <> tsVar.TabVisible then
    tsVar.TabVisible := Flag;
  ViewVarDetail(tsVar.TabVisible);

  serie := UDM.Conn.ExecSQLScalar('SELECT codserie FROM cl_subseries WHERE codsubs = ' + QuotedStr(subserie));
  nombretmptable := UDM.QuitaCaracter('md_' + serie + subserie);
  if (nombretmptable = 'md_') or (nombretmptable = '') then
    Exit;

  existe := UDM.TablaExiste(UDM.Conn, nombretmptable);
  if not existe then
  begin
    ShowMessage('La tabla asociada a la subserie no existe: ' + nombretmptable);
    Exit;
  end;

  pVerticalTitle.Caption := ' Subserie:      ';
  UDM.cl_series.Locate('codserie', serie, []);
  UDM.cl_subseries.Locate('codserie;codsubs', VarArrayOf([serie, subserie]));

  md_var.Active := False;
  md_var.SQL.Clear;
  cadena := UDM.GenerarConsultaSQL(UDM.cl_VarSubserie, 'SELECT NombreTablaMetadatos FROM cl_subseries WHERE codsubs = ' + QuotedStr(subserie), subserie);
  md_var.SQL.Add(cadena);

  md_def.Active := False;
  md_def.SQL.Clear;
  md_def.SQL.Add('SELECT NomVariable, Etiqueta, descripcion FROM cl_VarSubserie WHERE codsubs = ' + QuotedStr(subserie) + ' ORDER BY orden ASC;');

  try
    md_var.Open();
    md_def.Open();
    CreateVerticalGridRows(cxDBVerticalGrid3, md_var, md_def);
  except
    on E: Exception do
      ShowMessage('Error al cargar los datos: ' + E.Message);
  end;

  ApplyBestFit(cxDBVerticalGrid3);
end; }

{procedure TMAIN.ShowVariablesForSubserie;
var
  serie, cadena: string;
  existe, Flag: Boolean;
  nombretmptable, subserie: string;
begin
  if not UDM.SudSDetail.Active then
    exit;
  if not UDM.tb_SeriesDatos.Active then
    exit;
  subserie := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
  if subserie = '' then
    subserie := UDM.tb_Serietree.FieldByName('codsubs').AsString;
  if subserie = '' then
    Exit;
  Flag := False;
  Flag := UDM.Conn.ExecSQLScalar('SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs = ' + QuotedStr(subserie)) > 0;
  if Flag <> tsVar.TabVisible then
    tsVar.TabVisible := Flag;
  ViewVarDetail(tsVar.TabVisible);
  serie := UDM.Conn.ExecSQLScalar('select codserie from cl_subseries where codsubs=' + QuotedStr(subserie));
  // Verificar si ya existe la tabla para la nueva subserie
  nombretmptable := UDM.QuitaCaracter('md_' + serie + subserie);
  if (nombretmptable = 'md_') or (nombretmptable = '') then
    exit;
  existe := UDM.TablaExiste(UDM.Conn, nombretmptable);
  if not existe then
  begin
    Exit;
  end;
  pVerticalTitle.Caption := ' Subserie:      ';
  Flag := False;
  Flag := UDM.Conn.ExecSQLScalar('SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs = ' + QuotedStr(subserie)) > 0;
  if Flag <> tsVar.TabVisible then
    tsVar.TabVisible := Flag;
  ViewVarDetail(tsVar.TabVisible);
  serie := UDM.Conn.ExecSQLScalar('select codserie from cl_subseries where codsubs=' + QuotedStr(subserie));
  UDM.cl_series.Locate('codserie', serie, []);
  UDM.cl_subseries.Locate('codserie;codsubs', VarArrayOf([serie, subserie]));
  md_var.Active := False;
  md_var.SQL.Clear;
  cadena := UDM.GenerarConsultaSQL(UDM.cl_VarSubserie, 'select NombreTablaMetadatos from cl_subseries where codsubs=' + QuotedStr(subserie));
  md_var.SQL.Add(cadena);
  md_def.Active := False;
  md_def.SQL.Clear;
  md_def.SQL.Add('SELECT NomVariable, Etiqueta, descripcion FROM cl_VarSubserie WHERE codsubs =' + QuotedStr(subserie) + '  order by orden asc;');
  try
    md_var.Open();
    md_def.Open();
    CreateVerticalGridRows(cxDBVerticalGrid3, md_var, md_def);
  except
  end;
  ApplyBestFit(cxDBVerticalGrid3);
end; }

procedure TMAIN.SpeedButton10Click(Sender: TObject);
begin
  try
    cxGrid2DBTableView1.ApplyBestFit();
  except
  end;
end;

procedure TMAIN.SpeedButton12Click(Sender: TObject);
begin
  if cxGridDBTableView3.DataController.DataSet.RecordCount > 0 then
    cxGridDBTableView3.ApplyBestFit();
end;

procedure TMAIN.SpeedButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TMAIN.SpeedButton3Click(Sender: TObject);
begin
  if UDM.sms('¿Desea exportar el listado de subseries asignadas la estructura actual?', 4) = 6 then
    ExcelExport(nil, GViewSeriesI);
end;

procedure TMAIN.SpeedButton4Click(Sender: TObject);
begin
  if UDM.tb_Serietree.RecordCount = 0 then
  begin
    UDM.sms('El conjunto de datos está vacío. Debe seleccionar una serie válida para eliminar.', 2);
    Exit;
  end;
  if UDM.tb_SeriesDatos.RecordCount > 0 then
  begin
    UDM.sms('La subserie actual, tiene documentos asociados por lo que no se puede eliminar.', 2);
    Exit;
  end;
  if UDM.sms('¿Desea eliminar todas las subseries asignadas?', 4) = 6 then
    if UDM.tb_Serietree.RecordCount > 0 then
    begin
      UDM.tb_Serietree.DisableControls;
      UDM.Tb_SeriesDispo.DisableControls;
      UDM.tb_Serietree.Last;
      while not UDM.tb_Serietree.Bof do
        UDM.tb_Serietree.Delete;
      UDM.tb_Serietree.EnableControls;
      UDM.Tb_SeriesDispo.EnableControls;
      UDM.sms('Todos las subseries fueron eliminadas satisfactoriamente.', 3);
    end
    else
    begin
      UDM.sms('No existen subseries que se puedan eliminar.', 3);
      Exit;
    end;
end;

procedure TMAIN.SpeedButton5Click(Sender: TObject);
var
  carpetaLocal: string;
begin
  EsLocalServer := UDM.EsLocal(UDM.tb_Serietree.FieldByName('Idservidor').AsInteger);
  if EsLocalServer then
  begin
    carpetaLocal := UDM.GetFolder(UDM.tb_Serietree.FieldByName('Idservidor').AsInteger);
  end;
  {if EsLocalServer then
    if Pos(carpetaLocal, sd.Directory) = 0 then
    begin
      UDM.sms('No coincide la información suministrada con la asignada para almacenamiento local.', 1);
      UDM.sms('Por favor debe especificar una ruta que contenga la raiz especificada en el clasificador de servidores.', 3);
      edt1.Focused;
      edt1.SetFocus;
      Exit;
    end;
  cpInfoPathSubSeries.Visible := False;}
  PrepareSSDetailView;
end;

procedure TMAIN.SpeedButton6Click(Sender: TObject);
var
  Response: Integer;
begin
  // Verificar si hay cambios pendientes en los datasets
  if (UDM.tb_Serietree.State in [dsEdit, dsInsert]) or (UDM.tb_SeriesDatos.State in [dsEdit, dsInsert]) then
  begin
    // Preguntar al usuario si desea guardar los cambios
    Response := MessageDlg('¿Desea guardar los cambios realizados en los datos topográficos?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    case Response of
      mrYes:
        begin
          // Guardar cambios en tb_Serietree
          if UDM.tb_Serietree.State in [dsEdit, dsInsert] then
          try
            UDM.tb_Serietree.Post;
          except
            on E: Exception do
            begin
              UDM.sms('Error al guardar los cambios en la estructura topográfica: ' + E.Message, 3);
              Exit;
            end;
          end;

          // Guardar cambios en tb_SeriesDatos
          if UDM.tb_SeriesDatos.State in [dsEdit, dsInsert] then
          try
            UDM.tb_SeriesDatos.Post;
          except
            on E: Exception do
            begin
              UDM.sms('Error al guardar los cambios en los datos de la serie: ' + E.Message, 3);
              Exit;
            end;
          end;

          // Propagar cambios sin afectar la UI
          PropagarCambiosTopograficos;
        end;

      mrNo:
        begin
          // Descartar cambios
          if UDM.tb_Serietree.State in [dsEdit, dsInsert] then
            UDM.tb_Serietree.Cancel;
          if UDM.tb_SeriesDatos.State in [dsEdit, dsInsert] then
            UDM.tb_SeriesDatos.Cancel;
        end;

      mrCancel:
        Exit; // El usuario canceló, no hacemos nada y no ocultamos el panel
    end;
  end;

  // Ocultar el panel solo si no se canceló
  jvcpSSDetail.Visible := False;

  // Registrar la salida del módulo
  UDM.log('Abandonando el módulo topográfico.', 15, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('Nombreestructura').AsString);
end;

procedure TMAIN.PropagarCambiosTopograficos;
var
  OldCursor: TCursor;
  BookmarkTree, BookmarkDatos, BookmarkDetail: TBookmark;
begin
  // Guardar el cursor actual y establecer uno fijo
  OldCursor := Screen.Cursor;
  Screen.Cursor := crDefault; // Cursor normal, sin reloj de arena

  try
    // Deshabilitar controles vinculados para evitar parpadeos
    UDM.tb_Serietree.DisableControls;
    UDM.tb_SeriesDatos.DisableControls;
    if UDM.SudSDetail.Active then
      UDM.SudSDetail.DisableControls;

    // Preservar posiciones actuales de los datasets
    BookmarkTree := nil;
    BookmarkDatos := nil;
    BookmarkDetail := nil;

    with UDM.tb_Serietree do
    begin
      if Active and not IsEmpty then
        BookmarkTree := GetBookmark;
    end;
    with UDM.tb_SeriesDatos do
    begin
      if Active and not IsEmpty then
        BookmarkDatos := GetBookmark;
    end;
    with UDM.SudSDetail do
    begin
      if Active and not IsEmpty then
        BookmarkDetail := GetBookmark;
    end;

    // Refrescar los DataSources asociados para propagar cambios
    if Assigned(UDM.dstb_Serietree) and UDM.dstb_Serietree.DataSet.Active then
      UDM.dstb_Serietree.DataSet.Refresh;
    if Assigned(UDM.dstb_SeriesDatos) and UDM.dstb_SeriesDatos.DataSet.Active then
      UDM.dstb_SeriesDatos.DataSet.Refresh;
    if UDM.SudSDetail.Active then
      UDM.SudSDetail.Refresh;

    // Restaurar posiciones
    with UDM.tb_Serietree do
    begin
      if Active and not IsEmpty and BookmarkValid(BookmarkTree) then
      begin
        GotoBookmark(BookmarkTree);
        FreeBookmark(BookmarkTree);
      end;
    end;
    with UDM.tb_SeriesDatos do
    begin
      if Active and not IsEmpty and BookmarkValid(BookmarkDatos) then
      begin
        GotoBookmark(BookmarkDatos);
        FreeBookmark(BookmarkDatos);
      end;
    end;
    with UDM.SudSDetail do
    begin
      if Active and not IsEmpty and BookmarkValid(BookmarkDetail) then
      begin
        GotoBookmark(BookmarkDetail);
        FreeBookmark(BookmarkDetail);
      end;
    end;

  finally
    // Restaurar controles y cursor
    UDM.tb_Serietree.EnableControls;
    UDM.tb_SeriesDatos.EnableControls;
    if UDM.SudSDetail.Active then
      UDM.SudSDetail.EnableControls;
    Screen.Cursor := OldCursor;
  end;
end;

procedure TMAIN.pVerticalTitleClick(Sender: TObject);
begin

end;

{procedure TMAIN.SpeedButton6Click(Sender: TObject);
begin
  jvcpSSDetail.Visible := False;
  UDM.tb_Serietree.Refresh;
  UDM.tb_SeriesDatos.Refresh;
  UDM.log('Abandonando el módulo topográfico.', 15, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('Nombreestructura').AsString);
end; }

procedure TMAIN.SpeedButton7Click(Sender: TObject);
begin
  if UDM.tb_Serietree.RecordCount = 0 then
  begin
    UDM.sms('El conjunto de datos está vacío. Debe seleccionar una serie válida para eliminar.', 2);
    Exit;
  end;
  if UDM.tb_SeriesDatos.RecordCount > 0 then
  begin
    UDM.sms('La subserie actual, tiene documentos asociados por lo que no se puede eliminar.', 2);
    Exit;
  end;
  if UDM.sms('¿Desea eliminar la subserie actual?', 4) = 6 then
    if UDM.tb_Serietree.RecordCount > 0 then
    begin
      UDM.tb_Serietree.DisableControls;
      UDM.Tb_SeriesDispo.DisableControls;
      UDM.tb_Serietree.Delete;
      UDM.tb_Serietree.EnableControls;
      UDM.Tb_SeriesDispo.EnableControls;
      UDM.sms('La subserie fue eliminada satisfactoriamente.', 3);
    end
    else
    begin
      UDM.sms('No existen subseries que se puedan eliminar.', 3);
      Exit;
    end;
end;

procedure TMAIN.SpeedButton8Click(Sender: TObject);
begin
  if UDM.Tb_SeriesDispo.RecordCount = 0 then
  begin
    UDM.sms('No existen subseries disponibles que se puedan agregar.', 2);
    Exit;
  end;
  UDM.Tb_SeriesDispo.DisableControls;
  UDM.tb_Serietree.DisableControls;
  if not UDM.tb_Serietree.Locate('IdEstructura;codsubs', VarArrayOf([UDM.tb_tree.FieldByName('IdEstructura').AsString, UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString]), []) then
  begin
    UDM.tb_Serietree.Append;
    UDM.tb_Serietree.FieldByName('IdEstructura').AsString := UDM.tb_tree.FieldByName('IdEstructura').AsString;
    UDM.tb_Serietree.FieldByName('id').AsInteger := UDM.tb_tree.FieldByName('id').AsInteger;
    UDM.tb_Serietree.FieldByName('codsubs').AsString := UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString;
    UDM.tb_Serietree.FieldByName('Archivo').AsString := UDM.Tb_SeriesDispo.FieldByName('Archivo').AsString;
    UDM.tb_Serietree.FieldByName('deposito').AsString := UDM.Tb_SeriesDispo.FieldByName('deposito').AsString;
    UDM.tb_Serietree.FieldByName('gaveta').AsString := UDM.Tb_SeriesDispo.FieldByName('gaveta').AsString;
    UDM.tb_Serietree.FieldByName('gestor').AsString := UDM.Tb_SeriesDispo.FieldByName('cargo').AsString;
    UDM.tb_Serietree.FieldByName('idservidor').AsString := UDM.Tb_SeriesDispo.FieldByName('pc').AsString;
    //UDM.tb_Serietree.FieldByName('carpeta').AsString := UDM.Tb_SeriesDispo.FieldByName('carpeta').AsString;
    try
      UDM.tb_Serietree.Post;
    except
      on E: EFDException do
      begin
        UDM.sms('La serie ' + UDM.Tb_SeriesDispo.FieldByName('subseries').AsString + ' no se pudo agregar. Motivo: ' + E.Message, 1);
        Exit;
      end;
    end;
  end;
  UDM.tb_Serietree.EnableControls;
  UDM.Tb_SeriesDispo.EnableControls;
end;

procedure TMAIN.SpeedButton9Click(Sender: TObject);
begin
  if GViewSeriesIDBTableView1.DataController.RecordCount > 0 then
  begin
    try
      GViewSeriesIDBTableView1.ApplyBestFit();
    except
    end;
  end
  else
  begin
    UDM.sms('Esta función es recomendable utilizarla cuando existe al menos un registro inscrito.', 3);
    Exit;
  end;
end;

procedure TMAIN.T1Click(Sender: TObject);
begin
  {with TfrmCLAcceso.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end; }
end;

procedure TMAIN.T2Click(Sender: TObject);
begin
 { with TfrmCLTipoDoc.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end; }
end;

procedure TMAIN.T3Click(Sender: TObject);
begin
  {with TfrmTipoEstructura.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;}
end;

procedure TMAIN.T4Click(Sender: TObject);
begin
 { with TfrmTipoObjeto.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;}
end;

procedure TMAIN.T5Click(Sender: TObject);
begin
  with TfrmTiposExp.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

function TMAIN.TamFichero(n: string): longint;
var
  f: file of Byte;
begin
  AssignFile(f, n);
  Reset(f);
  TamFichero := FileSize(f);
  CloseFile(f);
end;

procedure TMAIN.Timer1Timer(Sender: TObject);
begin
//  Application.ProcessMessages;
  {if not CAPP then
    with TFDConnection.Create(nil) do
    try
      Connected := False;
      Params.Clear;
      Params.Assign(UDM.Conn.Params);
      try
        Connected := True;
      except
        on E: EFDexception do
        begin
          udm.sms('No se ha podido establecer comunicación con la base de datos. Motivo: ' + E.Message, 1);
          if TBD = 'S' then
            udm.sms('No se pudo establecer la conexión con el servidor especificado.' + chr(13) + 'LA APLICACIÓN SE CERRARÁ!!!!. Por favor verifique los posibles motivos listados a continuación: ' + chr(13) + '1- Por favor verifique que el nombre o IP del servidor sean correctos.' + chr(13) + '2- Verifique que se haya ejecutado el procedimiento de configuración de conexión.' + chr(13) + '3- Verifique que su estación de trabajo este correctamente conectada a la red de la empresa.' + chr(13) + '4- Póngase en contacto con el administrador de la red en su Empresa o solicite ayuda a soporte técnico.', 3)
          else
            udm.sms('No se pudo establecer la conexión con la base de datos especificada.' + chr(13) + 'Por favor verifique los posibles motivos listados a continuación: ' + chr(13) + '1- Verifique que la base de datos se encuentre en la ruta especificada.' + AnsiQuotedStr(PathBD, '"') + chr(13) + '2- Si el fichero de bases de datos esta disponible verifique que no este dañado, abrá el fichero access y reparelo.' + chr(13) + '3- Póngase en contacto con el administrador de la red en su Empresa o solicite ayuda a soporte técnico.', 3);
          CAPP := True;
          Application.Terminate;
          Exit;
        end;
      end;
    finally
      Free;
    end; }
end;

procedure TMAIN.tvTreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if cdsSelected in State then
  begin
    // Mantén el nodo resaltado incluso si el TreeView pierde el foco
    tvTree.Canvas.Brush.Color := $00EFCD85; //$00F0CAAE;
    tvTree.Canvas.Font.Style := [fsBold, fsUnderline];
    tvTree.Canvas.Font.Color := clWindowText; //clHighlightText;
  end
  else
  begin
    // Dibuja los nodos no seleccionados con el color de fondo predeterminado
    tvTree.Canvas.Brush.Color := clWindow;
    tvTree.Canvas.Font.Style := [];
    tvTree.Canvas.Font.Color := clWindowText;
  end;

  DefaultDraw := True; // Permite que Delphi dibuje el nodo con los colores establecidos
end;

procedure TMAIN.tvTreeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
  TopicID := 6;
  if Key = 112 then
    Application.HelpContext(TopicID);
end;

procedure TMAIN.tvTreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HT: THitTests;
  SelectedNode: TTreeNode;

  function FindAdministrator(Node: TTreeNode; const RoleNameSeek: string): Integer;
  var
    Bookmark: TBookmark;
    Found: Boolean;
  begin
    Result := -1;
    Found := False;
    Bookmark := UDM.tb_tree.GetBookmark;
    UDM.tb_tree.DisableControls;
    try
      if UDM.tb_tree.Locate('id', PDataRec(Node.Data).id, []) and UDM.cl_Resp_Gest_Arch.Locate('idresp', UDM.tb_tree.FieldByName('administrador').AsInteger, []) and udm.Tb_Rol.Locate('idrol', UDM.cl_Resp_Gest_Arch.FieldByName('rol').AsInteger, []) then
      begin
        if AnsiLowerCase(udm.Tb_Rol.FieldByName('rol').AsString) = AnsiLowerCase(RoleNameSeek) then
        begin
          Result := udm.Tb_Rol.FieldByName('idrol').AsInteger;
          Found := True;
        end;
      end;

      if not Found and (Node.Parent <> nil) then
        Result := FindAdministrator(Node.Parent, RoleNameSeek);
    finally
      UDM.tb_tree.GotoBookmark(Bookmark);
      UDM.tb_tree.EnableControls;
    end;
  end;

  function FindNodeByText(TreeView: TTreeView; const NodeText: string): TTreeNode;
  var
    i: Integer;
  begin
    Result := nil;
    for i := 0 to Pred(TreeView.Items.Count) do
    begin
      if SameText(TreeView.Items[i].Text, NodeText) then
        Exit(TreeView.Items[i]);
    end;
  end;

  procedure UpdateUIForNode(Node: TTreeNode);
  var
    NodeData: PDataRec;
    IsLabel: Boolean;
  begin
    if (Node = nil) or (Node.Text = '') then
      Exit;

    NodeData := PDataRec(Node.Data);
    IsLabel := AnsiLowerCase(NodeData.Tipo) = 'etiqueta';

    jvcpDescripcionEtiq.Visible := False;
    PContainer.Visible := not IsLabel;

    if UDM.tb_tree.Locate('IdEstructura;Id', VarArrayOf([NodeData.estruct, NodeData.id]), []) then
    begin
      if IsLabel then
      begin
        if Trim(NodeData.Descrip) <> '' then
        begin
          jvcpDescripcionEtiq.Visible := True;
          jvcpDescripcionEtiq.Caption := 'Breve descripción de la etiqueta: ' + NodeData.Etiqueta;
        end;
      end
      else
      begin
        etiquetaNA := NodeData.Etiqueta;
        advtpCuadroClasif.Caption := 'CDC ACTIVO ' + AnsiQuotedStr(etiquetaNA, '"');
        advtpCC.Visible := True;
        advtpDetalle.Visible := True;

        if not advtpCuadroClasif.Showing then
        begin
          advtpCuadroClasif.Show;
          advtpCuadroClasif.Locked := True;
        end;

        PSeriesDatos.Visible := True;
        NombreEstructura := UDM.tb_tree.FieldByName('Etiqueta').AsString;
      end;
    end;
  end;

begin
  HT := tvTree.GetHitTestInfoAt(X, Y);
//AnItem := tvTree.GetNodeAt(X, Y);
  if CargandoEstado then
  begin
    AnItem := FindNodeByText(tvTree, NodoSel);
  end
  else if htOnItem in HT then
  begin
    AnItem := tvTree.GetNodeAt(X, Y);
    if Button = mbRight then
      Exit; // Handle right-click if needed
  end
  else
    Exit;

  try
    UpdateUIForNode(AnItem);
  except
    on E: EFDException do
    begin
      UDM.sms('No se encontró el nodo especificado en la base de datos. Motivo: ' + E.Message, 1);
      Exit;
    end;
  end;
end;
{var
  HT: THitTests;
  id: Integer;
  Estructura: string;

  function BuscaAdministrador(nodo: TTreeNode; rolnameseek: string): integer;
  var
    auid: integer;
    sal: boolean;
    bm: TBookmark;
  begin
    Result := -1;
    sal := false;
    bm := UDM.tb_tree.GetBookmark;
    UDM.tb_tree.DisableControls;
    if UDM.tb_tree.Locate('id', PDataRec(nodo.Data).id, []) then
    begin
      if UDM.cl_Resp_Gest_Arch.Locate('idresp', UDM.tb_tree.FieldByName('administrador').asinteger, []) then
        if udm.Tb_Rol.Locate('idrol', UDM.cl_Resp_Gest_Arch.FieldByName('rol').AsInteger, []) then
        begin
          if ansilowercase(udm.Tb_Rol.FieldByName('rol').AsString) = rolnameseek then
          begin
            Result := udm.Tb_Rol.FieldByName('idrol').AsInteger;
            sal := true;
          end;
        end;
    end;
    if (nodo.Parent <> nil) and not sal then
      BuscaAdministrador(nodo.Parent, UDM.tb_tree.FieldByName('administrador').AsString);
    UDM.tb_tree.GotoBookmark(bm);
    UDM.tb_tree.EnableControls;
  end;

  function FindTreeNodeByText(TreeView: TTreeView; const NodeText: string): TTreeNode;
  var
    i: Integer;
  begin
    Result := nil; // Por defecto, devuelve nil si no encuentra el nodo
    for i := 0 to TreeView.Items.Count - 1 do
    begin
      if AnsiCompareText(TreeView.Items[i].Text, NodeText) = 0 then
      begin
        Result := TreeView.Items[i];
        Exit;  // Salir al encontrar el nodo
      end;
    end;
  end;

  function LocalizarYPosicionarRegistro(FDQuery: TFDQuery; const CampoBusqueda, ValorBusqueda: string): Boolean;
  begin
    Result := False;  // Inicializamos el resultado en falso

  // Aplicamos un filtro para encontrar el registro
    try
    // Si la consulta no está abierta, la abrimos
      if not FDQuery.Active then
        FDQuery.Open;

    // Establecemos el filtro para el campo y valor de búsqueda
      FDQuery.Filter := Format('%s = %s', [CampoBusqueda, QuotedStr(ValorBusqueda)]);
      FDQuery.Filtered := True;

    // Si se encuentra algún registro, movemos el cursor y retornamos True
      if not FDQuery.IsEmpty then
      begin
        FDQuery.First;  // Movemos el cursor al primer registro encontrado (ya que puede haber más de uno)
        Result := True;
      end;
    finally
    // Quitamos el filtro para restaurar el conjunto de datos original
      FDQuery.Filtered := False;
    end;
  end;

begin
  HT := tvTree.GetHitTestInfoAt(X, Y);
  if not CargandoEstado then
  begin
    AnItem := tvTree.GetNodeAt(X, Y);
    if (HT - [htOnItem, htOnLabel] <> HT) then
    begin
      if Button = mbRight then
      begin
      end
      else
      begin
        if AnItem.Text <> '' then
        begin
//          GViewSeriesDBTableView1.DataController.Refresh;
          jvcpDescripcionEtiq.Visible := False;
          if ansilowercase(PDataRec(AnItem.data).Tipo) = 'etiqueta' then
          begin
            PContainer.Visible := False;
            if UDM.tb_tree.Locate('IdEstructura;Id', VarArrayOf([PDataRec(AnItem.data).estruct, PDataRec(AnItem.data).id]), []) then
            begin
              if trim(PDataRec(AnItem.data).Descrip) <> '' then
              begin
                jvcpDescripcionEtiq.Visible := True;
                jvcpDescripcionEtiq.Caption := 'Breve descripción de la etiqueta: ' + PDataRec(AnItem.data).Etiqueta;
              end;
            end;
          end
          else
          begin
            PContainer.Visible := True;
            etiquetaNA := PDataRec(AnItem.data).Etiqueta;
            id := PDataRec(AnItem.Data).id;
            Estructura := PDataRec(AnItem.Data).estruct;
            advtpCuadroClasif.Caption := 'CDC ACTIVO ' + AnsiQuotedStr(etiquetaNA, '"');
//          lblTitulo.Caption := 'CDC ACTIVO ' + AnsiQuotedStr(etiquetaNA, '"');
            try
              UDM.tb_tree.Locate('idestructura;id', VarArrayOf([Estructura, id]), []);
            except
              on E: EFDException do
              begin
                UDM.sms('No se encontró el nodo especificado en la base de datos. Motivo: ' + e.Message, 1);
                Exit;
              end;
            end;

//           Estamos trabajando en este punto...
//          BuscaAdministrador(AnItem, );
            if UDM.tb_tree.Locate('IdEstructura;Id', VarArrayOf([PDataRec(AnItem.data).estruct, PDataRec(AnItem.data).id]), []) then
            begin
              advtpCC.Visible := True;
              advtpDetalle.Visible := True;
              if not advtpCuadroClasif.Showing then
              begin
                advtpCuadroClasif.Show;
                advtpCuadroClasif.Locked := True;
              end;
              PSeriesDatos.Visible := True;
              NombreEstructura := UDM.tb_tree.FieldByName('Etiqueta').AsString;
            end;
          end;
//          GViewSeriesDBTableView1.DataController.Refresh;
        end;
      end;
    end;
  end
  else
  begin
    AnItem := FindTreeNodeByText(tvTree, NodoSel);
    if AnItem.Text <> '' then
    begin
      jvcpDescripcionEtiq.Visible := False;
      if ansilowercase(PDataRec(AnItem.data).Tipo) = 'etiqueta' then
      begin
        PContainer.Visible := False;
        if UDM.tb_tree.Locate('IdEstructura;Id', VarArrayOf([PDataRec(AnItem.data).estruct, PDataRec(AnItem.data).id]), []) then
        begin
          if trim(PDataRec(AnItem.data).Descrip) <> '' then
          begin
            jvcpDescripcionEtiq.Visible := True;
            jvcpDescripcionEtiq.Caption := 'Breve descripción de la etiqueta: ' + PDataRec(AnItem.data).Etiqueta;
          end;
        end;
      end
      else
      begin
        PContainer.Visible := True;
        etiquetaNA := PDataRec(AnItem.data).Etiqueta;
        id := PDataRec(AnItem.Data).id;
        advtpCuadroClasif.Caption := 'CDC ACTIVO ' + AnsiQuotedStr(etiquetaNA, '"');
//          lblTitulo.Caption := 'CDC ACTIVO ' + AnsiQuotedStr(etiquetaNA, '"');
        if UDM.tb_tree.Locate('IdEstructura;Id', VarArrayOf([PDataRec(AnItem.data).estruct, PDataRec(AnItem.data).id]), []) then
        begin
//           Estamos trabajando en este punto...
//          BuscaAdministrador(AnItem, );
          advtpCC.Visible := True;
          advtpDetalle.Visible := True;
          if not advtpCuadroClasif.Showing then
          begin
            advtpCuadroClasif.Show;
            advtpCuadroClasif.Locked := True;
          end;
          PSeriesDatos.Visible := True;
          NombreEstructura := UDM.tb_tree.FieldByName('Etiqueta').AsString;
//          GViewSeriesDBTableView1.DataController.Refresh;
        end;
      end;
    end;
  end;

end; }

procedure TMAIN.UpdateButtonImage;
begin
  try
    if FIsAuthenticated then
    begin
      //btnautentica.Caption := 'Cerrar Sesión';
      if Assigned(FLogoutImage) then
        btnautentica.Glyph.Assign(FLogoutImage); // Imagen para "Cerrar sesión"
    end
    else
    begin
      //btnautentica.Caption := 'Autenticar';
      if Assigned(FLoginImage) then
        btnautentica.Glyph.Assign(FLoginImage); // Imagen para "Iniciar sesión"
    end;
  except
    on E: Exception do
      UDM.sms('Error al actualizar la imagen del botón: ' + E.Message, 1);
  end;
end;

procedure TMAIN.UpdateVariablesDisplay;
var
  subserie: string;
  hasVariables: Boolean;
begin
  subserie := GetSubserie;
  tsVar.TabVisible := False;
  if subserie = '' then
  begin
    tsVar.TabVisible := False;
    Exit;
  end;

  hasVariables := HasVariablesForSubserie(subserie);
  tsVar.TabVisible := hasVariables; // Mostrar u ocultar el TabSheet según si hay variables

  if hasVariables and (cxPageControl2.ActivePage = tsVar) then
    ConfigureVariablesGrid(subserie);
end;

procedure TMAIN.V2Click(Sender: TObject);
var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    ejecutaPDF(List[0]);
    //ShowMessage(List[0]);
  end;
end;

end.

