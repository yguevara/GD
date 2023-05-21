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
  cxDBLookupComboBox, cxImage, cxDropDownEdit, cxMaskEdit, cxLookupEdit,
  cxDBLookupEdit, JvExExtCtrls, JvExtComponent, JvCaptionPanel,
  dxLayoutContainer, cxGridInplaceEditForm, Winapi.ShellAPI, AdvSplitter,
  cxCalendar, AdvLabel, AdvScrollBox, cxButtonEdit, cxLabel, System.ImageList,
  Vcl.ImgList, Vcl.DBActns, System.Actions, Vcl.ActnList, dxDateTimeWheelPicker,
  JvBaseDlg, JvSelectDirectory, cxTL, cxTLdxBarBuiltInMenu, Vcl.Samples.Gauges,
  cxDBTL, cxTLData, System.StrUtils, JvDialogs, cxButtons, cxGridBandedTableView,
  cxGridDBBandedTableView;

type
  TMAIN = class(TForm)
    pMainContainer: TPanel;
    btnClose: TJvTransparentButton;
    btnautentica: TJvTransparentButton;
    btnusercontrol: TJvTransparentButton;
    btnLC: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnHlp: TJvTransparentButton;
    btnManagementTree: TJvTransparentButton;
    PMListascod: TAdvPopupMenu;
    A1: TMenuItem;
    C2: TMenuItem;
    D2: TMenuItem;
    D1: TMenuItem;
    E1: TMenuItem;
    T3: TMenuItem;
    C1: TMenuItem;
    F1: TMenuItem;
    L1: TMenuItem;
    R1: TMenuItem;
    S1: TMenuItem;
    S2: TMenuItem;
    T1: TMenuItem;
    T2: TMenuItem;
    T4: TMenuItem;
    P2: TMenuItem;
    V1: TMenuItem;
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
    GViewSeries: TcxGrid;
    GViewSeriesDBTableView1: TcxGridDBTableView;
    GViewSeriesDBTableView1IdEstructura: TcxGridDBColumn;
    GViewSeriesDBTableView1id: TcxGridDBColumn;
    GViewSeriesDBTableView1codsubs: TcxGridDBColumn;
    d: TcxGridDBColumn;
    GViewSeriesDBTableView1tipoArchivo: TcxGridDBColumn;
    GViewSeriesDBTableView1Archivo: TcxGridDBColumn;
    GViewSeriesDBTableView1deposito: TcxGridDBColumn;
    GViewSeriesDBTableView1gaveta: TcxGridDBColumn;
    GViewSeriesDBTableView1usuario: TcxGridDBColumn;
    GViewSeriesDBTableView1correo: TcxGridDBColumn;
    GViewSeriesDBTableView1observacion: TcxGridDBColumn;
    GViewSeriesDBTableView1Idservidor: TcxGridDBColumn;
    GViewSeriesDBTableView1carpeta: TcxGridDBColumn;
    GViewSeriesDBTableView1RootGroup: TcxGridInplaceEditFormGroup;
    GViewSeriesLevel1: TcxGridLevel;
    AdvPanel2: TAdvPanel;
    DBNavigator3: TDBNavigator;
    cxDBNavigator3: TcxDBNavigator;
    SpeedButton3: TSpeedButton;
    PSeriesDatos: TAdvPanel;
    pVerticalTitle: TPanel;
    AdvPanel6: TAdvPanel;
    cxDBNavigator2: TcxDBNavigator;
    cxGrid2: TcxGrid;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2Level1: TcxGridLevel;
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
    SpeedButton4: TSpeedButton;
    jvcpSSDetail: TJvCaptionPanel;
    AdvPanel5: TAdvPanel;
    pcDetalle: TcxPageControl;
    tsTopo: TcxTabSheet;
    cmdArch: TFDQuery;
    dscmdArch: TDataSource;
    dscmdGestor: TDataSource;
    cmdGestor: TFDQuery;
    cmdServer: TFDQuery;
    dscmdServer: TDataSource;
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
    btnDetalles: TSpeedButton;
    SpeedButton6: TSpeedButton;
    ActionList1: TActionList;
    DatasetPost1: TDataSetPost;
    DatasetCancel1: TDataSetCancel;
    ImageList1: TImageList;
    Button1: TButton;
    Button2: TButton;
    AdvPanel13: TAdvPanel;
    Label9: TLabel;
    Label8: TLabel;
    Label5: TLabel;
    edtGaveta: TcxDBTextEdit;
    edtDeposito: TcxDBTextEdit;
    lcbArchivo: TcxDBLookupComboBox;
    Label10: TLabel;
    lcbServer: TcxDBLookupComboBox;
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
    SpeedButton7: TSpeedButton;
    lblTitulo: TPanel;
    Timer1: TTimer;
    Label4: TLabel;
    edtCarpeta: TcxDBBlobEdit;
    SD: TJvSelectDirectory;
    E3: TMenuItem;
    T5: TMenuItem;
    ODArchDig: TJvOpenDialog;
    dsTb_SeriesDispo: TDataSource;
    FDQuery1: TFDQuery;
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
    cxGrid2DBTableView1fichero: TcxGridDBColumn;
    cxGrid2DBTableView1FechaFin: TcxGridDBColumn;
    cxGrid2DBTableView1gestor: TcxGridDBColumn;
    cxGrid2DBTableView1observaciones: TcxGridDBColumn;
    cxGrid2DBTableView1IDExpediente: TcxGridDBColumn;
    cxGrid2DBTableView1namefile: TcxGridDBColumn;
    SpeedButton9: TSpeedButton;
    SpeedButton10: TSpeedButton;
    dbnSeriesDatos: TDBNavigator;
    gProcess: TGauge;
    btnTool: TJvTransparentButton;
    PMTool: TAdvPopupMenu;
    D3: TMenuItem;
    P3: TMenuItem;
    L2: TMenuItem;
    btnViewPanel: TJvTransparentButton;
    btnValue: TMenuItem;
    btnTransfer: TMenuItem;
    btnImport: TMenuItem;
    btnExport: TMenuItem;
    advtpDetalle: TAdvToolPanelTab;
    advtpVariables: TAdvToolPanel;
    AdvSplitter2: TAdvSplitter;
    AdvSplitter3: TAdvSplitter;
    AdvPanel3: TAdvPanel;
    DBNavigator4: TDBNavigator;
    cxDBNavigator5: TcxDBNavigator;
    cxDBVerticalGrid4: TcxDBVerticalGrid;
    cxDBVerticalGrid4CategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid4Etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid4tipo: TcxDBEditorRow;
    cxDBVerticalGrid4longitud: TcxDBEditorRow;
    cxDBVerticalGrid4ListaDesplegable: TcxDBEditorRow;
    cxDBVerticalGrid4descripcion: TcxDBEditorRow;
    cxGrid3: TcxGrid;
    cxGrid3DBTableView1: TcxGridDBTableView;
    cxGrid3DBTableView1NomVariable: TcxGridDBColumn;
    cxGrid3Level1: TcxGridLevel;
    AdvPanel7: TAdvPanel;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxDBVerticalGrid1CategoryRow1: TcxCategoryRow;
    iv1: TcxDBEditorRow;
    iv2: TcxDBEditorRow;
    iv3: TcxDBEditorRow;
    iv4: TcxDBEditorRow;
    iv5: TcxDBEditorRow;
    iv6: TcxDBEditorRow;
    iv7: TcxDBEditorRow;
    iv8: TcxDBEditorRow;
    iv9: TcxDBEditorRow;
    iv10: TcxDBEditorRow;
    iv11: TcxDBEditorRow;
    AdvPanel8: TAdvPanel;
    SpeedButton1: TSpeedButton;
    advtpSSDispo: TAdvToolPanel;
    AdvPanel1: TAdvPanel;
    btnAsignVarVir: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton8: TSpeedButton;
    btnAdjust: TSpeedButton;
    DBNavigator1: TDBNavigator;
    cxDBNavigator1: TcxDBNavigator;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1codserie: TcxGridDBColumn;
    cxGrid1DBTableView1codsubs: TcxGridDBColumn;
    cxGrid1DBTableView1Series: TcxGridDBColumn;
    cxGrid1DBTableView1Subseries: TcxGridDBColumn;
    cxGrid1DBTableView1archivo: TcxGridDBColumn;
    cxGrid1DBTableView1deposito: TcxGridDBColumn;
    cxGrid1DBTableView1gaveta: TcxGridDBColumn;
    cxGrid1DBTableView1cargo: TcxGridDBColumn;
    cxGrid1DBTableView1pc: TcxGridDBColumn;
    cxGrid1DBTableView1carpeta: TcxGridDBColumn;
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
    AdvToolPanel1: TAdvToolPanel;
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
    AdvPanel12: TAdvPanel;
    tlFuente: TcxDBTreeList;
    cxDBTreeListColumn1: TcxDBTreeListColumn;
    cxDBTreeListColumn2: TcxDBTreeListColumn;
    cxDBTreeListColumn3: TcxDBTreeListColumn;
    cxDBTreeListColumn4: TcxDBTreeListColumn;
    cxDBTreeListColumn5: TcxDBTreeListColumn;
    cxDBTreeListColumn6: TcxDBTreeListColumn;
    cxDBTreeListColumn10: TcxDBTreeListColumn;
    cxDBTreeListColumn7: TcxDBTreeListColumn;
    cxDBTreeListColumn8: TcxDBTreeListColumn;
    cxDBTreeListColumn9: TcxDBTreeListColumn;
    cxDBTreeListColumn11: TcxDBTreeListColumn;
    cxDBTreeListColumn12: TcxDBTreeListColumn;
    cxDBTreeListColumn13: TcxDBTreeListColumn;
    cxDBTreeListColumn14: TcxDBTreeListColumn;
    cxDBTreeListColumn15: TcxDBTreeListColumn;
    cxDBTreeListColumn16: TcxDBTreeListColumn;
    cxDBTreeListColumn17: TcxDBTreeListColumn;
    cxGrid4: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
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
    cxGridDBColumn17: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    tsAnexosDig: TcxTabSheet;
    AdvSplitter1: TAdvSplitter;
    AdvPanel9: TAdvPanel;
    btnaddfile: TJvTransparentButton;
    btnaddfilelist: TJvTransparentButton;
    btnremovefile: TJvTransparentButton;
    btnRemoveFileList: TJvTransparentButton;
    JvTransparentButton6: TJvTransparentButton;
    cxGrid5: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBTableView2IdEstructura: TcxGridDBColumn;
    cxGridDBTableView2id: TcxGridDBColumn;
    cxGridDBTableView2codsubs: TcxGridDBColumn;
    cxGridDBTableView2Fecha: TcxGridDBColumn;
    cxGridDBTableView2Version: TcxGridDBColumn;
    cxGridDBTableView2idhijo: TcxGridDBColumn;
    cxGridDBTableView2nombre: TcxGridDBColumn;
    cxGridDBTableView2ext: TcxGridDBColumn;
    cxGridDBTableView2extnombre: TcxGridDBColumn;
    cxGridDBTableView2Etiqueta: TcxGridDBColumn;
    cxGridDBTableView2comentario: TcxGridDBColumn;
    cxGridDBTableView2urlraiz: TcxGridDBColumn;
    cxGridDBTableView2path: TcxGridDBColumn;
    cxGridDBTableView2tamano: TcxGridDBColumn;
    cxGridDBTableView2padre: TcxGridDBColumn;
    cxGridDBTableView2nivel: TcxGridDBColumn;
    cxGridDBTableView2fuente: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    AdvPanel11: TAdvPanel;
    cxDBTreeList2: TcxDBTreeList;
    cxDBTreeList2IdEstructura: TcxDBTreeListColumn;
    cxDBTreeList2id: TcxDBTreeListColumn;
    cxDBTreeList2codsubs: TcxDBTreeListColumn;
    cxDBTreeList2Fecha: TcxDBTreeListColumn;
    cxDBTreeList2Version: TcxDBTreeListColumn;
    cxDBTreeList2idhijo: TcxDBTreeListColumn;
    cxDBTreeList2nombre: TcxDBTreeListColumn;
    cxDBTreeList2ext: TcxDBTreeListColumn;
    cxDBTreeList2extnombre: TcxDBTreeListColumn;
    cxDBTreeList2Etiqueta: TcxDBTreeListColumn;
    cxDBTreeList2comentario: TcxDBTreeListColumn;
    cxDBTreeList2urlraiz: TcxDBTreeListColumn;
    cxDBTreeList2path: TcxDBTreeListColumn;
    cxDBTreeList2tamano: TcxDBTreeListColumn;
    cxDBTreeList2padre: TcxDBTreeListColumn;
    cxDBTreeList2nivel: TcxDBTreeListColumn;
    cxDBTreeList2fuente: TcxDBTreeListColumn;
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
    PLCC: TMenuItem;
    PLDS: TMenuItem;
    PLSD: TMenuItem;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnautenticaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure tvTreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnPrintClick(Sender: TObject);
    procedure btnusercontrolClick(Sender: TObject);
    procedure A1Click(Sender: TObject);
    procedure C2Click(Sender: TObject);
    procedure D2Click(Sender: TObject);
    procedure D1Click(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure T3Click(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure F1Click(Sender: TObject);
    procedure L1Click(Sender: TObject);
    procedure R1Click(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure S2Click(Sender: TObject);
    procedure T1Click(Sender: TObject);
    procedure T2Click(Sender: TObject);
    procedure T4Click(Sender: TObject);
    procedure P2Click(Sender: TObject);
    procedure V1Click(Sender: TObject);
    procedure btnManagementTreeClick(Sender: TObject);
    procedure cxDBBlobEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure I1Click(Sender: TObject);
    procedure cpProgressButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
    procedure cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure MenuItem5Click(Sender: TObject);
    procedure mGestionarContentFileClick(Sender: TObject);
    procedure cxGrid2DBTableView1observacionesPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure MenuItem11Click(Sender: TObject);
    procedure dstb_SeriesDatosDataChange(Sender: TObject; Field: TField);
    procedure GViewSeriesDBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxDBVerticalGrid2observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure SpeedButton3Click(Sender: TObject);
    procedure dstb_SerietreeDataChange(Sender: TObject; Field: TField);
    procedure btnAsignVarVirClick(Sender: TObject);
    procedure Ayuda1Click(Sender: TObject);
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
    procedure lcbServidorPropertiesCloseUp(Sender: TObject);
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
    procedure E3Click(Sender: TObject);
    procedure T5Click(Sender: TObject);
    procedure cxDBTreeList2DblClick(Sender: TObject);
    procedure btnAdjustClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure dstb_SerietreeUpdateData(Sender: TObject);
    procedure btnHlpClick(Sender: TObject);
    procedure btnremovefileClick(Sender: TObject);
    procedure btnRemoveFileListClick(Sender: TObject);
    procedure btnaddfileClick(Sender: TObject);
    procedure btnaddfilelistClick(Sender: TObject);
    procedure cxGridDBTableView2comentarioPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxGridDBTableView2CellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure JvTransparentButton6Click(Sender: TObject);
    procedure btnAddListSourceClick(Sender: TObject);
    procedure btnSourceFileClick(Sender: TObject);
    procedure btnExecuteSourceFileClick(Sender: TObject);
    procedure btnDropSourceFileClick(Sender: TObject);
    procedure btnRemoveSourceFileListClick(Sender: TObject);
    procedure tlFuenteDblClick(Sender: TObject);
    procedure cxGridDBColumn11PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SpeedButton10Click(Sender: TObject);
    procedure dbnSeriesDatosClick(Sender: TObject; Button: TNavigateBtn);
    procedure cxDBNavigator4ButtonsButtonClick(Sender: TObject; AButtonIndex: Integer; var ADone: Boolean);
    procedure SpeedButton12Click(Sender: TObject);
    procedure advtpCuadroClasifResize(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure D3Click(Sender: TObject);
    procedure btnValueClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure PLADClick(Sender: TObject);
    procedure PLCCClick(Sender: TObject);
    procedure PLDSClick(Sender: TObject);
    procedure PLSDClick(Sender: TObject);
  private
    procedure PrepareSSDisp;
    procedure PrepareSSDetailView;
    procedure PrepareVirtVarSS;
    procedure PrepareServerDetailView;
    procedure ArchivoActual;
    { Private declarations }
  public
    { Public declarations }
    varUltimoQuery: string;
    iRow: integer; //Posicion en la fila de la VerticalGrid
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
  end;

var
  MAIN: TMAIN;
  EsLocalServer: Boolean;

implementation

uses
  UHistory, UAbout, UAutentica, UCapaDatos, UUserGest, UDocManagement,
  UCLSeriesDocumentales, UCLDestino, UCLAcceso, UCLSoporte, UCLFrecuencia,
  UCLTipoDoc, UNodeAsist, UCLFtpServer, UCLProcesos, UCLRepActArchiv,
  UGestEstruct, UCategoria_Ocupa, UCL_Cargo, UCLVariables, UMangementArch,
  USeriesDisp, UCL_Especialistas, UEntrada, UManagementFileSeries, UCLFacultades,
  UCLFunciones, UViewFunciones, UICSeriesDocumentales, UCLTipoEstructura,
  UCL_Depositos, UVeditor, UVarVirtualSeriesD, UExcelExport, UClTipoObjeto,
  UManagementNode, USystemMsg, UAddNewNode, UNodeProperties, UCL_Expediente,
  UCL_TiposExp;

{$R *.dfm}

var
  Cancel: LongBool;

function ProgressRoutine(TotalFileSize, TotalBytesTransferred, StreamSize, StreamBytesTransferred: Int64; dwStreamNumber, dwCallbackReason, hSourceFile, hDestinationFile: Cardinal; lpData: Pointer): Cardinal; stdcall;
var
  Value: Cardinal;
begin
  Application.ProcessMessages;
  if dwCallbackReason = CALLBACK_CHUNK_FINISHED then
  begin
    MAIN.gProcess.Progress := Round(TotalBytesTransferred / TotalFileSize * 100);
    Application.ProcessMessages;
  end;
  Result := PROGRESS_CONTINUE;
end;

procedure TMAIN.A1Click(Sender: TObject);
begin
  PContainer.Visible := False;
  with TfrmManagemetArch.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
  PContainer.Visible := True;
end;

procedure TMAIN.Acercade1Click(Sender: TObject);
begin
  with TfrmAbout.Create(nil) do
  try
    Image1.Visible := True;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.advtpCuadroClasifResize(Sender: TObject);
begin
  PageControl1.Align := alNone;
  PageControl1.Align := alClient;
end;

procedure TMAIN.Ayuda1Click(Sender: TObject);
begin
  with TfrmDoc.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.btnaddfileClick(Sender: TObject);
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
    Result := cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Anexos Digitales\';
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

begin
  if UDM.tb_SeriesDatos.RecordCount = 0 then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 1);
    Exit;
  end;
  UDM.CompletaNombreFile;
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
        UDM.tb_ssArchdigital.Post;
        PathSaveBinaryFile := GURL + GPath + ExtractFileName(ODArchDig.FileName);
        ForceDirectories(ExtractFilePath(PathSaveBinaryFile));
        Destino := PathSaveBinaryFile;
        Origen := ODArchDig.FileName;
        CopyFileEx(pchar(Origen), pchar(Destino), nil, nil, nil, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);
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
    Result := cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
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
          if ((FileSearch.Attr and faDirectory) = FileSearch.Attr) or (FileSearch.Attr = 48) then
          begin
            if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
            begin
              level := GetLevel(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'));
              GPath := GetPath;
              GURL := GetURLRaiz;
              Inc(idhijo);
              SQLQ := 'INSERT INTO tb_ssArchdigital(idestructura, id, codsubs, fecha, version, idhijo, nombre, ext, extnombre, comentario, urlraiz, path, tamano, padre, nivel, fuente, etiqueta) VALUES(';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('IdEstructura').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('id').AsString + ', ';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('codsubs').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('Fecha').AsString + ', ';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Version').AsString) + ', ' + IntToStr(idhijo) + ', ' + QuotedStr(FileSearch.NAME) + ', 104, ';
              SQLQ := SQLQ + QuotedStr('DIR') + ', null, ' + QuotedStr(GURL) + ', ' + QuotedStr(GPath) + ', ' + IntToStr(FileSearch.SIZE) + ', ' + IntToStr(papa) + ', ' + IntToStr(level) + ')';
              UDM.CMDScript.SQLScripts[0].SQL.Add(SQLQ + ';');
              RastreaDir(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'), idhijo);
            end;
          end
          else
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
            SQLQ := 'INSERT INTO tb_ssArchdigital(idestructura, id, codsubs, fecha, version, idhijo, nombre, ext, extnombre, comentario, urlraiz, path, tamano, padre, nivel, fuente, etiqueta) VALUES(';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('IdEstructura').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('id').AsString + ', ';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('codsubs').AsString) + ', :ff, ';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Version').AsString) + ', ' + IntToStr(idhijo) + ', ' + QuotedStr(FileSearch.NAME) + ', ' + inttostr(ext) + ', ';
            SQLQ := SQLQ + QuotedStr(extension) + ', null, ' + QuotedStr(GURL) + ', ' + QuotedStr(GPath) + ', ' + IntToStr(FileSearch.SIZE) + ', ';
            SQLQ := SQLQ + IntToStr(papa) + ', ' + IntToStr(level) + ', ' + QuotedStr('N') + ', ' + QuotedStr(removeext(FileSearch.NAME)) + ')';
            PathSaveBinaryFile := AnsiReplaceStr(GURL + GPath + FileSearch.Name, '\\', '\');
            ForceDirectories(ExtractFilePath(PathSaveBinaryFile));
            Destino := PathSaveBinaryFile;
            Origen := Dir + '\' + FileSearch.Name;
            CopyFileEx(pchar(Origen), pchar(Destino), nil, nil, nil, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);
            UDM.CMDScript.SQLScripts[0].SQL.Add(SQLQ + ';');
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
  UDM.CompletaNombreFile;
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
      if not UDM.tb_ext.Active then
        UDM.tb_ext.Active := True;
      LevelAnt := 0;
      sbAD.Panels[0].Text := 'Archivo Digital';
      sbAD.Refresh;
      UDM.tb_SeriesDatos.DisableControls;
      UDM.CMDScript.SQLScripts.CLEAR;
      UDM.CMDScript.SQLScripts.add;
      idhijo := MaxIdHijo;
      RastreaDir(SD.Directory, 0);
      UDM.CMDScript.Params[0].Value := UDM.tb_SeriesDatos.FieldByname('Fecha').Value;
      //UDM.CMDScript.SQLScripts[0].SQL.SaveToFile('C:\qry.txt');
      try
        UDM.CMDScript.ValidateAll;
        UDM.CMDScript.ExecuteAll;
        UDM.sms('El directorio se agregó satisfactoriamente.', 3);
      except
      end;
      UDM.tb_ssArchdigital.Active := False;
      UDM.tb_ssArchdigital.Active := True;
      UDM.tb_ssArchdigital.FetchAll;
      UDM.tb_SeriesDatos.EnableControls;
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
    Result := cmdServer.FieldByName('Path').AsString;
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
          if ((FileSearch.Attr and faDirectory) = FileSearch.Attr) or (FileSearch.Attr = 48) then
          begin
            if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
            begin
              level := GetLevel(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'));
              GPath := GetPath;
              GURL := GetURLRaiz;
              Inc(idhijo);
              SQLQ := 'INSERT INTO tb_ssArchdigital(idestructura, id, codsubs, fecha, version, idhijo, nombre, ext, extnombre, comentario, urlraiz, path, tamano, padre, nivel, fuente, etiqueta) VALUES(';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('IdEstructura').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('id').AsString + ', ';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('codsubs').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('Fecha').AsString + ', ';
              SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Version').AsString) + ', ' + IntToStr(idhijo) + ', ' + QuotedStr(FileSearch.NAME) + ', 104, ';
              SQLQ := SQLQ + QuotedStr('DIR') + ', null, ' + QuotedStr(GURL) + ', ' + QuotedStr(GPath) + ', ' + IntToStr(FileSearch.SIZE) + ', ' + IntToStr(papa) + ', ' + IntToStr(level) + ')';
              UDM.CMDScript.SQLScripts[0].SQL.Add(SQLQ + ';');
              RastreaDir(AnsiReplaceStr(Dir + '\' + FileSearch.Name, '\\', '\'), idhijo);
            end;
          end
          else
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
            SQLQ := 'INSERT INTO tb_ssArchdigital(idestructura, id, codsubs, fecha, version, idhijo, nombre, ext, extnombre, comentario, urlraiz, path, tamano, padre, nivel, fuente, etiqueta) VALUES(';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('IdEstructura').AsString) + ', ' + UDM.tb_SeriesDatos.FieldByname('id').AsString + ', ';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('codsubs').AsString) + ', :ff, ';
            SQLQ := SQLQ + QuotedStr(UDM.tb_SeriesDatos.FieldByname('Version').AsString) + ', ' + IntToStr(idhijo) + ', ' + QuotedStr(FileSearch.NAME) + ', ' + inttostr(ext) + ', ';
            SQLQ := SQLQ + QuotedStr(extension) + ', null, ' + QuotedStr(GURL) + ', ' + QuotedStr(GPath) + ', ' + IntToStr(FileSearch.SIZE) + ', ';
            SQLQ := SQLQ + IntToStr(papa) + ', ' + IntToStr(level) + ', ' + QuotedStr('S') + ', ' + QuotedStr(removeext(FileSearch.NAME)) + ')';
            PathSaveBinaryFile := GURL + GPath + FileSearch.Name;
            ForceDirectories(ExtractFilePath(PathSaveBinaryFile));
            Destino := PathSaveBinaryFile;
            Origen := Dir + '\' + FileSearch.Name;
            cpProgress.Visible := True;
            //CopyFileEx(pchar(Origen), pchar(Destino), @ProgressRoutine, nil, @Cancel, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);
            CopyFileEx(pchar(Origen), pchar(Destino), @ProgressRoutine, nil, @Cancel, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);

            UDM.CMDScript.SQLScripts[0].SQL.Add(SQLQ + ';');
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
  UDM.CompletaNombreFile;
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
    SD.InitialDir := UDM.tb_Serietree.FieldByName('carpeta').AsString;  }
  if SD.Execute then
    if trim(SD.Directory) <> '' then
    begin
      if not UDM.tb_ext.Active then
        UDM.tb_ext.Active := True;
      LevelAnt := 0;
      sbAD.Panels[0].Text := 'Archivo Digital';
      sbAD.Refresh;
      UDM.tb_SeriesDatos.DisableControls;
      UDM.CMDScript.SQLScripts.CLEAR;
      UDM.CMDScript.SQLScripts.add;
      idhijo := MaxIdHijo;
      RastreaDir(SD.Directory, 0);
      cpProgress.Visible := False;
      UDM.CMDScript.Params[0].Value := UDM.tb_SeriesDatos.FieldByname('Fecha').Value;
     // UDM.CMDScript.SQLScripts[0].SQL.SaveToFile('C:\pepe.sql');
      try
        UDM.CMDScript.ValidateAll;
        UDM.CMDScript.ExecuteAll;
      except
      end;
      cpProgress.Visible := False;
      UDM.tb_ssArchdigital.Active := False;
      UDM.tb_ssArchdigital.Active := True;
      UDM.tb_ssArchdigital.FetchAll;
      UDM.tb_SeriesDatos.EnableControls;
    end;
  ReactiveAnexos;
end;

procedure TMAIN.btnAdjustClick(Sender: TObject);
begin
  cxGrid1DBTableView1.ApplyBestFit();
end;

procedure TMAIN.btnAsignVarVirClick(Sender: TObject);
var
  i: Integer;
begin
  {ShowMessage(cxGrid1DBTableView1.DataController.DataSet.Filter);
  exit;
  if trim(cxGrid1DBTableView1.DataController.DataSet.Filter)<>'' then begin
    UDM.Tb_SeriesDispo.Filtered:=False;
    UDM.Tb_SeriesDispo.Filter:=cxGrid1DBTableView1.DataController.DataSet.Filter;
    UDM.Tb_SeriesDispo.Filtered:=True;
  end;    }

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
end;

procedure TMAIN.btnautenticaClick(Sender: TObject);
begin
  with UDM.ConnUser do
  begin
    Connected := False;
    LoginPrompt := False;
    ConnectionString := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + PathBD + ';Persist Security Info=False';
    try
      Connected := True;
    except
    end;
  end;
  Rolactivo := autenticar(UDM.Connuser);
  MB.Panels[1].Text := UDM.UserName;
  MB.Panels[3].Text := UDM.Rol;
//  pUserInfo.Caption := '   Usuario: ' + UDM.UserName;
//  pRolInfo.Caption := '   Rol: ' + UDM.Rol;
  if ansilowercase(UDM.Rol) = 'administradores' then
  begin
    acceso := 'acceso total';
    btnSystemHelp.Left := syshelpLeft;
    btnSystemHelp.Visible := True;
    btnHlp.Visible := True;
    btnusercontrol.Visible := True;
    btnLC.Visible := True;
    btnPrint.Visible := True;
  end
  else
  begin
    btnSystemHelp.Left := btnHlp.Left;
    btnSystemHelp.Visible := True;
    btnHlp.Visible := False;
    btnusercontrol.Visible := False;
    btnLC.Visible := False;
    btnPrint.Visible := False;
  end;
  Security.SetModSecurity(Self, acceso);
end;

procedure TMAIN.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TMAIN.btnDetallesClick(Sender: TObject);
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
  jvcpSSDetail.Visible := True;
end;

procedure TMAIN.btnDropSourceFileClick(Sender: TObject);
var
  Pathf: string;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Fuentes\';
  end;

  function GetURLRaiz: string;
  begin
    Result := cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

begin
//  UDM.CompletaNombreFile;
  if UDM.qryFuentesDig.RecordCount <= 0 then
  begin
    UDM.sms('No existen Ficheros fuentes disponibles que puedan ser eliminados.', 1);
    exit;
  end;
  if UDM.sms('¿Realmente desea eliminar el fichero seleccionado?', 4) = 6 then
  begin
    UDM.qryFuentesDig.DisableControls;
    try
      Pathf := GetURLRaiz + GetPath + UDM.qryFuentesDig.FieldByName('nombre').AsString;
      if FileExists(Pathf) then
      begin
        DeleteFile(Pathf);
        UDM.qryFuentesDig.Delete;
        UDM.sms('El fichero fue eliminado satisfactoriamente.', 3);
      end;
      ReactiveAnexos;
    except
    end;
    UDM.qryFuentesDig.EnableControls;
  end;
end;

procedure TMAIN.btnExecuteSourceFileClick(Sender: TObject);
var
  pathfile: string;
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
  if UDM.qryFuentesDig.RecordCount <= 0 then
  begin
    UDM.sms('No existen Ficheros fuentes disponibles que puedan ser ejecutados.', 1);
    exit;
  end;
  //UDM.CompletaNombreFile;                                                                                                               //nombre
  pathfile := UDM.qryFuentesDig.FieldByName('urlraiz').AsString + UDM.qryFuentesDig.FieldByName('path').AsString + UDM.qryFuentesDig.FieldByName('nombre').AsString;
  if FileExists(pathfile) then
    ejecutaPDF(pathfile);
end;

procedure TMAIN.btnHlpClick(Sender: TObject);
begin
  with TfrmsystemMSG.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
  exit;
  UDM.KillProcess('PRecovery.exe');
  udm.RunAndWaitShell(ExtractFilePath(Application.ExeName) + 'PRecovery.exe', UDM.UserName + ' ' + UDM.Rol, SW_SHOW);
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
  UDM.KillProcess('ReportApp.exe');
  udm.RunAndWaitShell(ExtractFilePath(Application.ExeName) + 'ReportApp.exe', UDM.UserName + ' ' + UDM.Rol, SW_SHOW);
end;

procedure TMAIN.btnremovefileClick(Sender: TObject);
var
  Pathf, namefile: string;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Anexos Digitales\';
  end;

  function GetURLRaiz: string;
  begin
    Result := cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

begin
  if UDM.sms('¿Realmente desea eliminar el fichero seleccionado?', 4) = 6 then
  begin
    //UDM.CompletaNombreFile;
    UDM.qryAnexosDig.DisableControls;
    try
      namefile := UDM.qryAnexosDig.FieldByName(namefile).AsString;
      Pathf := GetURLRaiz + GetPath + UDM.qryAnexosDig.FieldByName('nombre').AsString;
      if FileExists(Pathf) then
      begin
        DeleteFile(Pathf);
        UDM.qryAnexosDig.Delete;
        UDM.sms('El fichero "' + namefile + '" fue eliminado satisfactoriamente.', 3);
      end;
      ReactiveAnexos;
    except
    end;
    UDM.qryAnexosDig.EnableControls;
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

procedure TMAIN.btnRemoveFileListClick(Sender: TObject);
var
  PathF: string;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Anexos Digitales\';
  end;

  function GetURLRaiz: string;
  begin
    Result := cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

begin
  if UDM.sms('¿Realmente desea eliminar todos los ficheros asociados a la subserie actual?', 4) = 6 then
  begin
    //UDM.CompletaNombreFile;
    PathF := GetURLRaiz + GetPath;
    UDM.qryAnexosDig.DisableControls;
    try
      if UDM.BorrarCarpeta(PChar(PathF)) then
        UDM.qryAnexosDig.Last;
      while not UDM.qryAnexosDig.Bof do
        UDM.qryAnexosDig.Delete;
      UDM.sms('Todos los archivos fueron eliminados satisfactoriamente.', 3);
      ReactiveAnexos;
    except
    end;
    UDM.qryAnexosDig.EnableControls;
  end;
end;

procedure TMAIN.btnRemoveSourceFileListClick(Sender: TObject);
var
  PathF: string;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Fuentes\';
  end;

  function GetURLRaiz: string;
  begin
    Result := cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

begin
//  UDM.CompletaNombreFile;
  if UDM.qryFuentesDig.RecordCount <= 0 then
  begin
    UDM.sms('No existen Ficheros fuentes disponibles que puedan ser eliminados.', 1);
    exit;
  end;
  if UDM.sms('¿Realmente desea eliminar todos los ficheros asociados a la subserie actual?', 4) = 6 then
  begin
    PathF := GetURLRaiz + GetPath;
    UDM.qryFuentesDig.DisableControls;
    try
      if UDM.BorrarCarpeta(PChar(PathF)) then
        UDM.qryFuentesDig.Last;
      while not UDM.qryFuentesDig.Bof do
        UDM.qryFuentesDig.Delete;
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
    Result := cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\Fuentes\';
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

begin
  if UDM.tb_SeriesDatos.RecordCount = 0 then
  begin
    UDM.sms('No se encontró ningún fichero de subserie documental en la fecha señalada.', 1);
    Exit;
  end;
  UDM.CompletaNombreFile;
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
      UDM.tb_ssArchdigital.FieldByName('Etiqueta').AsString := removeext(ExtractFileName(ODArchDig.FileName));
      try
        UDM.tb_ssArchdigital.Post;
        PathSaveBinaryFile := GURL + GPath + ExtractFileName(ODArchDig.FileName);
        ForceDirectories(ExtractFilePath(PathSaveBinaryFile));
        Destino := PathSaveBinaryFile;
        Origen := ODArchDig.FileName;
        //CopyFileEx(pchar(aCarpetaEntrada + sr.name), pchar(aCarpetaSalida + sr.name), @ProgressRoutine, nil, @Cancel, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);
        cpProgress.Visible := True;
        CopyFileEx(pchar(Origen), pchar(Destino), @ProgressRoutine, nil, @Cancel, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);
        cpProgress.Visible := False;
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

procedure TMAIN.btnusercontrolClick(Sender: TObject);
begin
  with TfrmGestUser.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.btnValueClick(Sender: TObject);
begin
  with TfrmsystemMSG.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.C1Click(Sender: TObject);
begin
  with TfrmCLCargo.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.C2Click(Sender: TObject);
begin
  with TfrmCatOcupa.Create(nil) do
  try
    ShowModal;
  finally
    Free;
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

procedure TMAIN.ControldeVersiones1Click(Sender: TObject);
begin
  with TfrmHistory.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.cpProgressButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
begin
  {if Button = capClose then
    cpInfoPathSubSeries.Visible := False;}
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
  CampoTexto(@dscmdArch, 'descripcion', 'Observaciones de la serie documental ' + NombreSerieDocAsig);
end;

procedure TMAIN.cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  PMManagementFileSubSerie.PopupAtCursor;
end;

procedure TMAIN.cxGrid2DBTableView1observacionesPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.tb_SeriesDatos.FieldByName('observaciones').Value = null) or (trim(UDM.tb_SeriesDatos.FieldByName('observaciones').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  NombreSerieDocAsig := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  CampoTexto(@UDM.dstb_SeriesDatos, 'observaciones', 'Observaciones de la serie documental ' + NombreSerieDocAsig);
end;

procedure TMAIN.cxGridDBColumn11PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.qryFuentesDig.FieldByName('Comentario').Value = null) or (trim(UDM.qryFuentesDig.FieldByName('Comentario').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  NombreSerieDocAsig := UDM.qryFuentesDig.FieldByName('etiqueta').AsString;
  if NombreSerieDocAsig = '' then
    NombreSerieDocAsig := UDM.qryFuentesDig.FieldByName('nombre').AsString;
  CampoTexto(@UDM.dsqryFuentesDig, 'comentario', 'Comentario sobre el fichero  ' + NombreSerieDocAsig);
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
  pathfile := UDM.qryAnexosDig.FieldByName('urlraiz').AsString + UDM.qryAnexosDig.FieldByName('path').AsString + UDM.qryAnexosDig.FieldByName('nombre').AsString;
  if FileExists(pathfile) then
    ejecutaPDF(pathfile);
end;

procedure TMAIN.cxGridDBTableView2comentarioPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.qryAnexosDig.FieldByName('Comentario').Value = null) or (trim(UDM.qryAnexosDig.FieldByName('Comentario').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  NombreSerieDocAsig := UDM.qryAnexosDig.FieldByName('etiqueta').AsString;
  if NombreSerieDocAsig = '' then
    NombreSerieDocAsig := UDM.qryAnexosDig.FieldByName('nombre').AsString;
  CampoTexto(@UDM.dsqryAnexosDig, 'comentario', 'Comentario sobre el fichero  ' + NombreSerieDocAsig);
end;

procedure TMAIN.D1Click(Sender: TObject);
begin
  with TfrmCLDestino.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.D2Click(Sender: TObject);
begin
  with TfrmDeposito.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.D3Click(Sender: TObject);
begin
  with TfrmsystemMSG.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.dbnSeriesDatosClick(Sender: TObject; Button: TNavigateBtn);
var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  NombreFile: string;
  PathF: string;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\';
  end;

  function GetURLRaiz: string;
  begin
    Result := cmdServer.FieldByName('Path').AsString; //UDM.SudSDetail.FieldByName('carpeta').AsString;
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
  if Button = nbInsert then
  begin
    if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
    begin
    end;
  end;
  if Button = nbDelete then
  begin
    if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
    begin
      TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
      List := TStringList.Create;
      List.LoadFromFile(PathTemp + 'tmpfile.txt');
      NombreFile := removeext(ExtractFileName(List[0]));
      if FileExists(List[0]) then
      begin
        DeleteFile(List[0]);
        PathF := GetURLRaiz + GetPath;
        if DirectoryExists(PathF) then
        begin
          if UDM.BorrarCarpeta(pchar(PathF)) then
          begin
            UDM.sms('El documento y el conido asociado al mismo fueron eliminados satisfactoriamente.', 3);
            Exit;
          end;

        end;
      end
      else
        UDM.sms('No existe el fichero especificado.', 1);
    end;
  end;
end;

procedure TMAIN.dstb_SeriesDatosDataChange(Sender: TObject; Field: TField);
var
  CantDoc: integer;
begin
  pVerticalTitle.Caption := ' Documentos de la subserie: ';
  CantDoc := 0;
  CantDoc := UDM.Conn.ExecSQLScalar('select count(subserie) as cantidad from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString));
  if CantDoc <= 0 then
  begin
    pVerticalTitle.Caption := ' << SIN DOCUMENTOS >>';
//    pVerticalTitle.Color:=clWindow;
    pVerticalTitle.Font.Color := clRed;
    pVerticalTitle.Font.Style := [fsbold];
    Exit;
  end
  else
  begin
    pVerticalTitle.Font.Color := clWindow;
    pVerticalTitle.Font.Style := [fsbold];
  end;

  pVerticalTitle.Caption := pVerticalTitle.Caption + VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString)));
  if UDM.tb_SerieDatosVar.RecordCount > 0 then
  begin
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
    Rellena;
  end
  else
  begin
    OcultaVGVardef;
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
  end;
  PrepareSSDetailView;
  if (trim(UDM.SudSDetail.FieldByName('espacial').AsString) <> '') and (trim(UDM.SudSDetail.FieldByName('espacial').AsString) = 'S') then
  begin
    tsCoord.TabVisible := True
  end
  else
    tsCoord.TabVisible := False;
 // ReactiveAnexos;
end;

procedure TMAIN.dstb_SerietreeDataChange(Sender: TObject; Field: TField);
var
  aNombre: string;
  CantDoc: integer;
begin
  if (UDM.tb_Serietree.State <> dsInsert) and (UDM.tb_Serietree.State <> dsEdit) then
  begin
    PrepareSSDisp;
    PrepareSSDetailView;
    PrepareVirtVarSS;
    PrepareServerDetailView;
    ArchivoActual;
  end;
  if (trim(UDM.SudSDetail.FieldByName('espacial').AsString) <> '') and (trim(UDM.SudSDetail.FieldByName('espacial').AsString) = 'S') then
  begin
    tsCoord.TabVisible := True
  end
  else
    tsCoord.TabVisible := False;
  {if UDM.tb_SeriesDatos.RecordCount = 0 then begin
    lblTitulo.Caption := 'NO EXISTEN SUBSERIES DOCUMENTALES DISPONIBLES';
    PSeriesDatos.Visible:=False;
  end
  else begin
    lblTitulo.Caption := 'CDC ACTIVO ' + AnsiQuotedStr(etiquetaNA, '"');
    PSeriesDatos.Visible:=True;
  end; }
  pVerticalTitle.Caption := ' Documentos de la subserie: ';
  CantDoc := 0;
  CantDoc := UDM.Conn.ExecSQLScalar('select count(subserie) as cantidad from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString));
  if CantDoc <= 0 then
  begin
    pVerticalTitle.Caption := ' << SIN DOCUMENTOS >>';
    //pVerticalTitle.Color:=clWindow;
    pVerticalTitle.Font.Color := clRed;
    pVerticalTitle.Font.Style := [fsbold];
    Exit;
  end
  else
  begin
    pVerticalTitle.Font.Color := clWindow;
    pVerticalTitle.Font.Style := [fsbold];
  end;

  aNombre := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  if trim(aNombre) <> '' then
    pVerticalTitle.Caption := pVerticalTitle.Caption + AnsiQuotedStr(aNombre, '"'); {
  else
    pVerticalTitle.Caption := ' Bienvenido al Sistema de Gestión Documental EMSERGO SGD v1.0';}

  if UDM.tb_Serietree.RecordCount = 0 then
  begin
    lblTitulo.Caption := 'NO EXISTEN SUBSERIES DOCUMENTALES DISPONIBLES';
    cxGrid2.Visible := False;
    AdvPanel6.Visible := False;
  end
  else
  begin
    lblTitulo.Caption := 'CDC ACTIVO ' + AnsiQuotedStr(etiquetaNA, '"');
    cxGrid2.Visible := True;
    AdvPanel6.Visible := True;
  end;
 // EsLocalServer := UDM.EsLocal(UDM.tb_Serietree.FieldByName('Idservidor').AsInteger);
end;

procedure TMAIN.dstb_SerietreeUpdateData(Sender: TObject);
begin
  EsLocalServer := UDM.EsLocal(UDM.tb_Serietree.FieldByName('Idservidor').AsInteger);
end;

procedure TMAIN.E1Click(Sender: TObject);
begin
  with TfrmListEspec.Create(NIL) do
  try
    ShowModal;
  finally
    Free;
  end;
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

procedure TMAIN.E3Click(Sender: TObject);
begin
  with tfrmexpediente.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
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

procedure TMAIN.edtObsPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TMAIN.P2Click(Sender: TObject);
begin
  with TfrmCLprocesos.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.PLADClick(Sender: TObject);
begin
  if advtpDetalle.Visible then
  begin

    advtpDetalle.Panels[advtpDetalle.PanelIndex(AdvToolPanel1)].Visible:=True;
    advtpDetalle.Panels[advtpDetalle.PanelIndex(AdvToolPanel1)].Panel.Show;
    advtpDetalle.Panels[advtpDetalle.PanelIndex(AdvToolPanel1)].Panel.Locked:=True;
    advtpDetalle.Panels[advtpDetalle.PanelIndex(AdvToolPanel1)].Panel.Parent:=advtpDetalle;
    {AdvToolPanel1.Visible := True;
    AdvToolPanel1.Locked := True;
    AdvToolPanel1.Show;}
  end;
end;

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
  if advtpDetalle.Visible then
  begin
    advtpSSDispo.Visible := True;
    advtpSSDispo.Locked := True;
    advtpSSDispo.Show;
  end;
end;

procedure TMAIN.PrepareServerDetailView;
begin
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
end;

procedure TMAIN.PrepareVirtVarSS;
begin
  UDM.VarSSDetail.DisableControls;
  try
    UDM.VarSSDetail.Active := False;
    UDM.VarSSDetail.Params[0].Value := UDM.tb_Serietree.FieldByName('codsubs').Value;
    UDM.VarSSDetail.Active := True;
    UDM.VarSSDetail.FetchAll;
    UDM.VarSSDetail.EnableControls;
  except
    on E: EFDException do
    begin
      udm.sms('No se pueden cosultar los detalles de la subserie documental actual. Motivo: ' + e.Message, 1);
    end;
  end;
end;

procedure TMAIN.R1Click(Sender: TObject);
begin
  PContainer.Visible := False;
  with TfrmRepActArch.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
  PContainer.Visible := True;
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
  //UDM.tb_SeriesDatos.DisableControls;
  salvo := false;
 //********************Abrit las tablas*****************************************
  AbrirTabla(UDM.tb_SeriesDatos);
  AbrirTabla(UDM.cl_Variables);
  AbrirTabla(UDM.tb_SerieDatosVar);
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
  if UDM.tb_SerieDatosVar.recordcount = 0 then
  try
    Qcl_Varsubserie.First;
    while not Qcl_Varsubserie.eof do
    begin
      UDM.tb_SerieDatosVar.AppendRecord([UDM.tb_SeriesDatos.fieldbyname('id').Value, UDM.tb_SeriesDatos.fieldbyname('codsubs').Value, UDM.tb_SeriesDatos.fieldbyname('Fecha').Value, UDM.tb_SeriesDatos.fieldbyname('Version').Value, Qcl_Varsubserie.fieldbyname('orden').Value, Qcl_Varsubserie.fieldbyname('idvar').Value]);
      Qcl_Varsubserie.next;
    end;
    UDM.tb_SerieDatosVar.Active := false;
    UDM.tb_SerieDatosVar.Active := true;
  finally
    Qcl_Varsubserie.Free;
  end;
  varUltimoQuery := '';
  OcultaVGVardef;
  UDM.tb_SerieDatosVar.first;
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
      else if s = 'REAL' then
      begin
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
//****************************************************************************
end;

procedure TMAIN.RellenaPrj;
begin

end;

procedure TMAIN.RemoveMDSeriesSubSeriesDMDR;
begin
  UDM.cl_series.Active := False;
  UDM.cl_subseries.Active := False;
  UDM.cl_VarSubserie.Active := False;
  UDM.Tb_SeriesDispo.Active := False;
  UDM.cl_subseries.MasterSource := nil;
  UDM.cl_subseries.MasterFields := '';
  UDM.cl_subseries.IndexFieldNames := '';
  UDM.cl_series.Active := True;
  UDM.cl_subseries.Active := True;
  UDM.cl_VarSubserie.Active := True;
  UDM.Tb_SeriesDispo.Active := True;
end;

procedure TMAIN.ArchivoActual;
begin
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
  with cmdServer do
  begin
    Active := False;
    Connection := UDM.Conn;
    Params[0].Value := UDM.tb_Serietree.FieldByName('IdServidor').Value;
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pueden consultar los detalles del Servidor actual. Motivo: ' + e.Message, 1);
      end;
    end;
  end;
end;

procedure TMAIN.PrepareSSDetailView;
begin
  if UDM.tb_Serietree.RecordCount = 0 then
    Exit;
  if UDM.tb_Serietree.FieldByName('codsubs').Value = null then
    Exit;
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
end;

procedure TMAIN.PrepareSSDisp;
begin
  UDM.Tb_SeriesDispo.DisableControls;
  try
    UDM.Tb_SeriesDispo.Active := False;
    UDM.Tb_SeriesDispo.Params[0].Value := UDM.tb_tree.FieldByName('id').Value;
    UDM.Tb_SeriesDispo.Active := True;
    UDM.Tb_SeriesDispo.FetchAll;
    UDM.Tb_SeriesDispo.EnableControls;
  except
    on E: EFDException do
    begin
      udm.sms('No se pudo acceder al listado de subseries disponibles. Motivo: ' + e.Message, 1);
    end;
  end;
end;

procedure TMAIN.F1Click(Sender: TObject);
begin
  with TfrmCLFrecuencia.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.FormActivate(Sender: TObject);
begin
  MB.Panels[1].Text := UDM.UserName;
  MB.Panels[3].Text := UDM.Rol;
  MB.Panels[5].Text := PathBD;
  UDM.RestauraGrid(GViewSeriesDBTableView1, 'GSeriesAsignadas');
  UDM.RestauraGrid(cxGrid2DBTableView1, 'GDocumentos');
  UDM.RestauraGrid(cxGrid1DBTableView1, 'GSeriesDisp');
  Caption := 'ArchiGenio Pro ' + VersionProgram;
  btnViewPanel.Visible := False;
  btnSystemHelp.Left := btnTool.Left + btnTool.Width + 7;
end;

procedure TMAIN.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if UDM.sms('¿Realmente desea salir del sistema?', 4) = 6 then
  begin
    CanClose := True;
    UDM.SalvaConfigGrid(GViewSeriesDBTableView1, 'GSeriesAsignadas');
    UDM.SalvaConfigGrid(cxGrid2DBTableView1, 'GDocumentos');
    UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'GSeriesDisp');
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
begin

  syshelpLeft := btnSystemHelp.Left;
  if FileExists(ExtractFilePath(Application.ExeName) + '\SDTrad.ini') then
  begin
    cxLocalizer1.LoadFromFile(ExtractFilePath(Application.ExeName) + '\SDTrad.ini');
    cxLocalizer1.LanguageIndex := 1; // MUDA DE LINGUAGEM
    cxLocalizer1.Active := True; // ATIVA O COMPONENTE
  end;
  //Ocultar las variables...
  advtpVariables.Hide;
  advtpVariables.Visible := False;
  advtpDetalle.Panels[0].Free;
//  AdvToolPanelTab2.Panels[0].Visible:=False;
  Caption := 'ArchiGenio Pro v' + VersionProgram;
  UDM.CreaTreeDB(UDM.Conn, @tvTree, False);
  LoadTreeStateNode;
  CleanTMP(PathTemp);
  UDM.Rol := 'administradores';
  UDM.UserName := 'Invitado';
  PrepareSSDisp;
  PrepareSSDetailView;
  PrepareVirtVarSS;
  PrepareServerDetailView;
  ArchivoActual;
 { if (AnsiLowerCase(UDM.Rol) = 'administradores') or (AnsiLowerCase(UDM.Rol) = 'documentador') then
    acceso := 'acceso total'
  else
    acceso := 'solo lectura';
  if Trim(acceso) = '' then
    acceso := 'solo lectura';
  Security.SetModSecurity(Self, acceso);}
end;

procedure TMAIN.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
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
  if Key = 112 then
    UDM.sms('¡No se encontró ningún fichero de ayuda disponible!', 2);
  cxGrid2DBTableView1.Columns[0].Focused;
end;

procedure TMAIN.G1Click(Sender: TObject);
begin
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gestión de serie documental');
end;

procedure TMAIN.GViewSeriesDBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TMAIN.btnManagementTreeClick(Sender: TObject);
begin
  nbMain.Hide;
  PContainer.Visible := False;
  PSeriesDatos.Visible := False;
  with TfrmPropiedadesNodo.Create(nil) do
  try
    with Padres do
    begin
      Active := False;
      Params[0].Value := UDM.tb_tree.FieldByName('id').Value;
      Active := True;
    end;
    Caption := 'Administrando el cuadro de clasificación';
    ShowModal;
  finally
    Free;
    UDM.tb_tree.Active := False;
    UDM.tb_tree.Active := True;
    UDM.CreaTreeDB(UDM.Conn, @tvTree, False);
    UDM.tb_tree.Filtered := True;
    PContainer.Visible := True;
    nbMain.Show;
  end;
end;

procedure TMAIN.JvTransparentButton6Click(Sender: TObject);
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
//  UDM.CompletaNombreFile;                                                                                                    //nombre
  pathfile := UDM.qryAnexosDig.FieldByName('urlraiz').AsString + UDM.qryAnexosDig.FieldByName('path').AsString + UDM.qryAnexosDig.FieldByName('nombre').AsString;
  if FileExists(pathfile) then
    ejecutaPDF(pathfile);
end;

procedure TMAIN.L1Click(Sender: TObject);
begin
  PContainer.Visible := False;
  with TfrmListFTPServer.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
  PContainer.Visible := True;
end;

procedure TMAIN.lcbArchivoEnter(Sender: TObject);
begin
  pcDetalle.ActivePage := tsTopo;
end;

procedure TMAIN.lcbArchivoPropertiesCloseUp(Sender: TObject);
begin
  cmdArch.Active := False;
  cmdArch.Params[0].Value := lcbArchivo.EditValue;
  cmdArch.Active := True;
  PrepareSSDetailView;
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
    Connection := UDM.Conn;
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

procedure TMAIN.lcbServerEnter(Sender: TObject);
begin
  pcDetalle.ActivePage := tsServidor;
end;

procedure TMAIN.lcbServidorPropertiesCloseUp(Sender: TObject);
begin
  with cmdServer do
  begin
    Active := False;
    Connection := UDM.Conn;
    Params[0].Value := lcbServer.EditValue;
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
          ShowMessage(TvTree.Items[i].Text);
          TvTree.Items[i].Expanded := True;
        end
        else
          TvTree.Items[i].Expanded := False;
    except
    end;
    List.Free;
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

procedure TMAIN.MenuItem11Click(Sender: TObject);
var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;
begin
  if UDM.sms('¿Realmente desea eliminar el contenido del campo actual?', 4) = 6 then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    if FileExists(List[0]) then
      DeleteFile(List[0])
    else
    begin
      UDM.sms('El fichero especificado "' + List[0] + '" no existe en la ruta especificada.', 1);
    end;
    try
      UDM.tb_SeriesDatos.Edit;
      TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).Clear;
      UDM.tb_SeriesDatos.FieldByName('namefile').Value := null;
      UDM.tb_SeriesDatos.Post;
    except
    end;

  end;
end;

procedure TMAIN.MenuItem1Click(Sender: TObject);
begin
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gestión de serie documental');
end;

procedure TMAIN.MenuItem5Click(Sender: TObject);
var
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
      //UDM.ViewPDF(List[0]);
    end
    else
      UDM.sms('No existe el fichero especificado.', 1);
  end
  else
  begin
    UDM.sms('Error se encontró un documento para visualizar. Especifique un documento válido para visualizar.', 3);
  end;
end;

procedure TMAIN.mGestionarContentFileClick(Sender: TObject);
var
  cad: string;
begin     //UDM.SudSDetail
  if (UDM.tb_SeriesDatos.State = dsInsert) or (UDM.tb_SeriesDatos.State = dsedit) then
    UDM.tb_SeriesDatos.Post;
  {if trim(UDM.SudSDetail.FieldByName('carpeta').AsString) = '' then
  begin
    UDM.sms('No ha especificado una carpeta raíz válida para almacenar el fichero especificado.', 1);
    Exit;
  end;} //ForceDirectories(pathftp + ExtractFilePath(ListProccess[1]));                                                                                                        //puerto
//  cad := UDM.SudSDetail.FieldByName('carpeta').AsString + '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\';
  Carpeta := cmdServer.FieldByName('path').AsString;
  cad := cmdServer.FieldByName('path').AsString + '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\';
  PathToSaveFile := cad + UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString;
  if (UDM.tb_Serietree.FieldByName('idservidor').Value = null) or (trim(UDM.tb_Serietree.FieldByName('idservidor').AsString) = '') then
  begin
    UDM.sms('No se encontró una ruta válida para almacenar las subseries.', 2);
    udm.sms('Por favor defina un servidor y una ruta válida para guardar las subseries documentales.', 3);
    Exit;
  end;
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gestión de serie documental');
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

procedure TMAIN.S1Click(Sender: TObject);
begin
  PContainer.Visible := False;
  with TfrmCLSeries.Create(nil) do
  try
    MDSeriesSubSeriesDMDR;
    ShowModal;
  finally
    Free;
    RemoveMDSeriesSubSeriesDMDR
  end;
  Screen.Cursor := crSQLWait;
  PrepareSSDisp;
  PrepareSSDetailView;
  PrepareVirtVarSS;
  PrepareServerDetailView;
  ArchivoActual;
  Screen.Cursor := crDefault;
  PContainer.Visible := True;
end;

procedure TMAIN.S2Click(Sender: TObject);
begin
  with TfrmCLSoporte.Create(nil) do
  try
    ShowModal;
  finally
    Free;
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
    ExcelExport(nil, GViewSeries);
end;

procedure TMAIN.SpeedButton4Click(Sender: TObject);
begin
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
begin
  jvcpSSDetail.Visible := False;
end;

procedure TMAIN.SpeedButton7Click(Sender: TObject);
begin
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
  try
    GViewSeriesDBTableView1.ApplyBestFit();
  except
  end;
end;

procedure TMAIN.T1Click(Sender: TObject);
begin
  with TfrmCLAcceso.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.T2Click(Sender: TObject);
begin
  with TfrmCLTipoDoc.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.T3Click(Sender: TObject);
begin
  with TfrmTipoEstructura.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAIN.T4Click(Sender: TObject);
begin
  with TfrmTipoObjeto.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
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

  procedure MuestraBTNEyes(aValue: boolean);
  begin
    if aValue then
    begin
      btnViewPanel.Visible := True;{
      btnViewPanel.Left := btnTool.Left + btnTool.Width + 7;
      btnSystemHelp.Left := btnViewPanel.Left + btnViewPanel.Width + 7;}
    end
    else
    begin
      btnViewPanel.Visible := False;
      //btnSystemHelp.Left := btnTool.Left + btnTool.Width + 7;
    end;
  end;

begin
  MuestraBTNEyes(false);
  if not advtpDetalle.Visible then
    Exit;
  MuestraBTNEyes(true);
  if not AdvToolPanel1.Visible then
    PLAD.Enabled := True
  else
    PLAD.Enabled := False;
  if not advtpSSDispo.Visible then
    PLSD.Enabled := True
  else
    PLSD.Enabled := False;
  if not advtpDetail.Visible then
    PLDS.Enabled := True
  else
    PLDS.Enabled := False;

  if not advtpCC.Visible then
    Exit;
  MuestraBTNEyes(true);
  if not advtpCuadroClasif.Visible then
    PLCC.Enabled := True
  else
    PLCC.Enabled := False;
end;

procedure TMAIN.tvTreeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HT: THitTests;
  id: Integer;
begin
  HT := tvTree.GetHitTestInfoAt(X, Y);
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
        etiquetaNA := PDataRec(AnItem.data).Etiqueta;
        id := PDataRec(AnItem.Data).id;
        advtpCuadroClasif.Caption := 'CDC ACTIVO ' + AnsiQuotedStr(etiquetaNA, '"');
        lblTitulo.Caption := 'CDC ACTIVO ' + AnsiQuotedStr(etiquetaNA, '"');
        if UDM.tb_tree.Locate('id', id, []) then
        begin
          advtpCC.Visible := True;
          advtpDetalle.Visible := True;
          if not advtpCuadroClasif.Showing then
          begin
            advtpCuadroClasif.Show;
            advtpCuadroClasif.Locked := True;
          end;
          PSeriesDatos.Visible := True;
         { if not advtpDetail.Showing then
          begin
            advtpDetail.Show;
            advtpDetail.Locked := True;
          end;}
        end;
      end;
    end;
  end;
end;

procedure TMAIN.V1Click(Sender: TObject);
begin
  with TfrmVariables.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
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

