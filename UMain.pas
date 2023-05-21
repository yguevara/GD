unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ToolWin, System.ImageList, Vcl.ImgList, Vcl.StdCtrls,
  Vcl.Menus, AdvMenus, JvExControls, JvButton, JvTransparentButton, Vcl.ExtCtrls,
  Vcl.Buttons, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, dxSkinsDefaultPainters, cxClasses, dxNavBarBase, dxNavBarCollns,
  dxNavBar, cxCustomData, cxStyles, cxTL, cxMaskEdit, cxMemo,
  cxTLdxBarBuiltInMenu, cxInplaceContainer, cxDBTL, cxTLData, ToolPanels,
  AdvSplitter, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.DBCtrls, AdvPageControl,
  AdvOfficePager, cxContainer, cxEdit, cxFilter, cxData, cxDataStorage,
  cxNavigator, dxDateRanges, cxDBData, cxGridTableView, cxGridLevel,
  cxGridCustomView, cxGridCustomTableView, cxGridDBTableView, cxGrid, cxTextEdit,
  cxDBEdit, AdvToolBar, AdvToolBarExt, AdvRichEditorToolBar, AdvScrollControl,
  AdvRichEditorBase, AdvRichEditor, DBAdvRichEditor,
  AdvRichEditorFormatButtonBar, AdvPanel, dxBarDBNav, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, AdvRichEditorPopupToolBar, cxLabel,
  AdvDBLookupComboBox, cxDBLookupComboBox, cxBlobEdit, cxRichEdit, cxDBNavigator,
  dxBarBuiltInMenu, cxPC, cxGroupBox, cxLocalization, dxtree, dxdbtree,
  cxDropDownEdit, cxCalendar, cxLookupEdit, cxDBLookupEdit, cxVGrid, cxDBVGrid,
  Winapi.ShellAPI, System.AnsiStrings, cxCheckBox, dxLayoutContainer,
  cxGridInplaceEditForm, cxScrollBox, cxButtonEdit, JvBaseDlg, JvSelectDirectory,
  JvExExtCtrls, JvExtComponent, JvCaptionPanel, JvExStdCtrls, JvCtrls, JvFooter,
  AdvOfficeStatusBar, cxImage;

type
  TNODOSD = record
    Id: integer;
    Etiqueta: string;
    Padre: integer;
    ICONO: integer;
    Tipo: integer; // Etiqueta, Estructura, Cargo
  end;

  TMAINFORM = class(TForm)
    pMainContainer: TPanel;
    PMAyuda: TAdvPopupMenu;
    Ayuda1: TMenuItem;
    P1: TMenuItem;
    N6: TMenuItem;
    Acercade1: TMenuItem;
    N5: TMenuItem;
    ControldeVersiones1: TMenuItem;
    btnClose: TJvTransparentButton;
    btnautentica: TJvTransparentButton;
    btnusercontrol: TJvTransparentButton;
    btnLC: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnHlp: TJvTransparentButton;
    PMListascod: TAdvPopupMenu;
    C1: TMenuItem;
    cxStyleRepository1: TcxStyleRepository;
    GridTableViewStyleSheetDevExpress: TcxGridTableViewStyleSheet;
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
    GridTableViewStyleSheetUserFormat1: TcxGridTableViewStyleSheet;
    cxStyle15: TcxStyle;
    cxStyle16: TcxStyle;
    cxStyle17: TcxStyle;
    cxStyle18: TcxStyle;
    cxStyle19: TcxStyle;
    cxStyle20: TcxStyle;
    cxStyle21: TcxStyle;
    cxStyle22: TcxStyle;
    cxStyle23: TcxStyle;
    cxStyle24: TcxStyle;
    cxStyle25: TcxStyle;
    GridTableViewStyleSheetUserFormat2: TcxGridTableViewStyleSheet;
    cxStyle26: TcxStyle;
    cxStyle27: TcxStyle;
    cxStyle28: TcxStyle;
    cxStyle29: TcxStyle;
    cxStyle30: TcxStyle;
    cxStyle31: TcxStyle;
    cxStyle32: TcxStyle;
    cxStyle33: TcxStyle;
    cxStyle34: TcxStyle;
    cxStyle35: TcxStyle;
    cxStyle36: TcxStyle;
    GridTableViewStyleSheetUserFormat3: TcxGridTableViewStyleSheet;
    cxStyle37: TcxStyle;
    cxStyle38: TcxStyle;
    cxStyle39: TcxStyle;
    cxStyle40: TcxStyle;
    cxStyle41: TcxStyle;
    cxStyle42: TcxStyle;
    cxStyle43: TcxStyle;
    cxStyle44: TcxStyle;
    cxStyle45: TcxStyle;
    cxStyle46: TcxStyle;
    cxStyle47: TcxStyle;
    GridTableViewStyleSheetUserFormat4: TcxGridTableViewStyleSheet;
    cxStyle48: TcxStyle;
    cxStyle49: TcxStyle;
    cxStyle50: TcxStyle;
    cxStyle51: TcxStyle;
    cxStyle52: TcxStyle;
    cxStyle53: TcxStyle;
    cxStyle54: TcxStyle;
    cxStyle55: TcxStyle;
    cxStyle56: TcxStyle;
    cxStyle57: TcxStyle;
    cxStyle58: TcxStyle;
    GridTableViewStyleSheetBrick: TcxGridTableViewStyleSheet;
    cxStyle59: TcxStyle;
    cxStyle60: TcxStyle;
    cxStyle61: TcxStyle;
    cxStyle62: TcxStyle;
    cxStyle63: TcxStyle;
    cxStyle64: TcxStyle;
    cxStyle65: TcxStyle;
    cxStyle66: TcxStyle;
    cxStyle67: TcxStyle;
    cxStyle68: TcxStyle;
    cxStyle69: TcxStyle;
    GridTableViewStyleSheetDesert: TcxGridTableViewStyleSheet;
    cxStyle70: TcxStyle;
    cxStyle71: TcxStyle;
    cxStyle72: TcxStyle;
    cxStyle73: TcxStyle;
    cxStyle74: TcxStyle;
    cxStyle75: TcxStyle;
    cxStyle76: TcxStyle;
    cxStyle77: TcxStyle;
    cxStyle78: TcxStyle;
    cxStyle79: TcxStyle;
    cxStyle80: TcxStyle;
    GridTableViewStyleSheetEggplant: TcxGridTableViewStyleSheet;
    cxStyle81: TcxStyle;
    cxStyle82: TcxStyle;
    cxStyle83: TcxStyle;
    cxStyle84: TcxStyle;
    cxStyle85: TcxStyle;
    cxStyle86: TcxStyle;
    cxStyle87: TcxStyle;
    cxStyle88: TcxStyle;
    cxStyle89: TcxStyle;
    cxStyle90: TcxStyle;
    cxStyle91: TcxStyle;
    GridTableViewStyleSheetLilac: TcxGridTableViewStyleSheet;
    cxStyle92: TcxStyle;
    cxStyle93: TcxStyle;
    cxStyle94: TcxStyle;
    cxStyle95: TcxStyle;
    cxStyle96: TcxStyle;
    cxStyle97: TcxStyle;
    cxStyle98: TcxStyle;
    cxStyle99: TcxStyle;
    cxStyle100: TcxStyle;
    cxStyle101: TcxStyle;
    cxStyle102: TcxStyle;
    GridTableViewStyleSheetMaple: TcxGridTableViewStyleSheet;
    cxStyle103: TcxStyle;
    cxStyle104: TcxStyle;
    cxStyle105: TcxStyle;
    cxStyle106: TcxStyle;
    cxStyle107: TcxStyle;
    cxStyle108: TcxStyle;
    cxStyle109: TcxStyle;
    cxStyle110: TcxStyle;
    cxStyle111: TcxStyle;
    cxStyle112: TcxStyle;
    cxStyle113: TcxStyle;
    GridTableViewStyleSheetMarinehighcolor: TcxGridTableViewStyleSheet;
    cxStyle114: TcxStyle;
    cxStyle115: TcxStyle;
    cxStyle116: TcxStyle;
    cxStyle117: TcxStyle;
    cxStyle118: TcxStyle;
    cxStyle119: TcxStyle;
    cxStyle120: TcxStyle;
    cxStyle121: TcxStyle;
    cxStyle122: TcxStyle;
    cxStyle123: TcxStyle;
    cxStyle124: TcxStyle;
    GridTableViewStyleSheetPlumhighcolor: TcxGridTableViewStyleSheet;
    cxStyle125: TcxStyle;
    cxStyle126: TcxStyle;
    cxStyle127: TcxStyle;
    cxStyle128: TcxStyle;
    cxStyle129: TcxStyle;
    cxStyle130: TcxStyle;
    cxStyle131: TcxStyle;
    cxStyle132: TcxStyle;
    cxStyle133: TcxStyle;
    cxStyle134: TcxStyle;
    cxStyle135: TcxStyle;
    GridTableViewStyleSheetPumpkinlarge: TcxGridTableViewStyleSheet;
    cxStyle136: TcxStyle;
    cxStyle137: TcxStyle;
    cxStyle138: TcxStyle;
    cxStyle139: TcxStyle;
    cxStyle140: TcxStyle;
    cxStyle141: TcxStyle;
    cxStyle142: TcxStyle;
    cxStyle143: TcxStyle;
    cxStyle144: TcxStyle;
    cxStyle145: TcxStyle;
    cxStyle146: TcxStyle;
    GridTableViewStyleSheetRainyDay: TcxGridTableViewStyleSheet;
    cxStyle147: TcxStyle;
    cxStyle148: TcxStyle;
    cxStyle149: TcxStyle;
    cxStyle150: TcxStyle;
    cxStyle151: TcxStyle;
    cxStyle152: TcxStyle;
    cxStyle153: TcxStyle;
    cxStyle154: TcxStyle;
    cxStyle155: TcxStyle;
    cxStyle156: TcxStyle;
    cxStyle157: TcxStyle;
    GridTableViewStyleSheetRedWhiteandBlueVGA: TcxGridTableViewStyleSheet;
    cxStyle158: TcxStyle;
    cxStyle159: TcxStyle;
    cxStyle160: TcxStyle;
    cxStyle161: TcxStyle;
    cxStyle162: TcxStyle;
    cxStyle163: TcxStyle;
    cxStyle164: TcxStyle;
    cxStyle165: TcxStyle;
    cxStyle166: TcxStyle;
    cxStyle167: TcxStyle;
    cxStyle168: TcxStyle;
    GridTableViewStyleSheetRose: TcxGridTableViewStyleSheet;
    cxStyle169: TcxStyle;
    cxStyle170: TcxStyle;
    cxStyle171: TcxStyle;
    cxStyle172: TcxStyle;
    cxStyle173: TcxStyle;
    cxStyle174: TcxStyle;
    cxStyle175: TcxStyle;
    cxStyle176: TcxStyle;
    cxStyle177: TcxStyle;
    cxStyle178: TcxStyle;
    cxStyle179: TcxStyle;
    GridTableViewStyleSheetRoselarge: TcxGridTableViewStyleSheet;
    cxStyle180: TcxStyle;
    cxStyle181: TcxStyle;
    cxStyle182: TcxStyle;
    cxStyle183: TcxStyle;
    cxStyle184: TcxStyle;
    cxStyle185: TcxStyle;
    cxStyle186: TcxStyle;
    cxStyle187: TcxStyle;
    cxStyle188: TcxStyle;
    cxStyle189: TcxStyle;
    cxStyle190: TcxStyle;
    GridTableViewStyleSheetSlate: TcxGridTableViewStyleSheet;
    cxStyle191: TcxStyle;
    cxStyle192: TcxStyle;
    cxStyle193: TcxStyle;
    cxStyle194: TcxStyle;
    cxStyle195: TcxStyle;
    cxStyle196: TcxStyle;
    cxStyle197: TcxStyle;
    cxStyle198: TcxStyle;
    cxStyle199: TcxStyle;
    cxStyle200: TcxStyle;
    cxStyle201: TcxStyle;
    GridTableViewStyleSheetSpruce: TcxGridTableViewStyleSheet;
    cxStyle202: TcxStyle;
    cxStyle203: TcxStyle;
    cxStyle204: TcxStyle;
    cxStyle205: TcxStyle;
    cxStyle206: TcxStyle;
    cxStyle207: TcxStyle;
    cxStyle208: TcxStyle;
    cxStyle209: TcxStyle;
    cxStyle210: TcxStyle;
    cxStyle211: TcxStyle;
    cxStyle212: TcxStyle;
    GridTableViewStyleSheetStormVGA: TcxGridTableViewStyleSheet;
    cxStyle213: TcxStyle;
    cxStyle214: TcxStyle;
    cxStyle215: TcxStyle;
    cxStyle216: TcxStyle;
    cxStyle217: TcxStyle;
    cxStyle218: TcxStyle;
    cxStyle219: TcxStyle;
    cxStyle220: TcxStyle;
    cxStyle221: TcxStyle;
    cxStyle222: TcxStyle;
    cxStyle223: TcxStyle;
    GridTableViewStyleSheetTealVGA: TcxGridTableViewStyleSheet;
    cxStyle224: TcxStyle;
    cxStyle225: TcxStyle;
    cxStyle226: TcxStyle;
    cxStyle227: TcxStyle;
    cxStyle228: TcxStyle;
    cxStyle229: TcxStyle;
    cxStyle230: TcxStyle;
    cxStyle231: TcxStyle;
    cxStyle232: TcxStyle;
    cxStyle233: TcxStyle;
    cxStyle234: TcxStyle;
    GridTableViewStyleSheetWheat: TcxGridTableViewStyleSheet;
    cxStyle235: TcxStyle;
    cxStyle236: TcxStyle;
    cxStyle237: TcxStyle;
    cxStyle238: TcxStyle;
    cxStyle239: TcxStyle;
    cxStyle240: TcxStyle;
    cxStyle241: TcxStyle;
    cxStyle242: TcxStyle;
    cxStyle243: TcxStyle;
    cxStyle244: TcxStyle;
    cxStyle245: TcxStyle;
    GridTableViewStyleSheetWindowsClassic: TcxGridTableViewStyleSheet;
    cxStyle246: TcxStyle;
    cxStyle247: TcxStyle;
    cxStyle248: TcxStyle;
    cxStyle249: TcxStyle;
    cxStyle250: TcxStyle;
    cxStyle251: TcxStyle;
    cxStyle252: TcxStyle;
    cxStyle253: TcxStyle;
    cxStyle254: TcxStyle;
    cxStyle255: TcxStyle;
    cxStyle256: TcxStyle;
    GridTableViewStyleSheetWindowsClassiclarge: TcxGridTableViewStyleSheet;
    cxStyle257: TcxStyle;
    cxStyle258: TcxStyle;
    cxStyle259: TcxStyle;
    cxStyle260: TcxStyle;
    cxStyle261: TcxStyle;
    cxStyle262: TcxStyle;
    cxStyle263: TcxStyle;
    cxStyle264: TcxStyle;
    cxStyle265: TcxStyle;
    cxStyle266: TcxStyle;
    cxStyle267: TcxStyle;
    GridTableViewStyleSheetWindowsStandard: TcxGridTableViewStyleSheet;
    cxStyle268: TcxStyle;
    cxStyle269: TcxStyle;
    cxStyle270: TcxStyle;
    cxStyle271: TcxStyle;
    cxStyle272: TcxStyle;
    cxStyle273: TcxStyle;
    cxStyle274: TcxStyle;
    cxStyle275: TcxStyle;
    cxStyle276: TcxStyle;
    cxStyle277: TcxStyle;
    cxStyle278: TcxStyle;
    GridTableViewStyleSheetWindowsStandardlarge: TcxGridTableViewStyleSheet;
    cxStyle279: TcxStyle;
    cxStyle280: TcxStyle;
    cxStyle281: TcxStyle;
    cxStyle282: TcxStyle;
    cxStyle283: TcxStyle;
    cxStyle284: TcxStyle;
    cxStyle285: TcxStyle;
    cxStyle286: TcxStyle;
    cxStyle287: TcxStyle;
    cxStyle288: TcxStyle;
    cxStyle289: TcxStyle;
    GridTableViewStyleSheetHighContrast1: TcxGridTableViewStyleSheet;
    cxStyle290: TcxStyle;
    cxStyle291: TcxStyle;
    cxStyle292: TcxStyle;
    cxStyle293: TcxStyle;
    cxStyle294: TcxStyle;
    cxStyle295: TcxStyle;
    cxStyle296: TcxStyle;
    cxStyle297: TcxStyle;
    cxStyle298: TcxStyle;
    cxStyle299: TcxStyle;
    cxStyle300: TcxStyle;
    GridTableViewStyleSheetHighContrast1large: TcxGridTableViewStyleSheet;
    cxStyle301: TcxStyle;
    cxStyle302: TcxStyle;
    cxStyle303: TcxStyle;
    cxStyle304: TcxStyle;
    cxStyle305: TcxStyle;
    cxStyle306: TcxStyle;
    cxStyle307: TcxStyle;
    cxStyle308: TcxStyle;
    cxStyle309: TcxStyle;
    cxStyle310: TcxStyle;
    cxStyle311: TcxStyle;
    GridTableViewStyleSheetHighContrast2: TcxGridTableViewStyleSheet;
    cxStyle312: TcxStyle;
    cxStyle313: TcxStyle;
    cxStyle314: TcxStyle;
    cxStyle315: TcxStyle;
    cxStyle316: TcxStyle;
    cxStyle317: TcxStyle;
    cxStyle318: TcxStyle;
    cxStyle319: TcxStyle;
    cxStyle320: TcxStyle;
    cxStyle321: TcxStyle;
    cxStyle322: TcxStyle;
    GridTableViewStyleSheetHighContrast2large: TcxGridTableViewStyleSheet;
    cxStyle323: TcxStyle;
    cxStyle324: TcxStyle;
    cxStyle325: TcxStyle;
    cxStyle326: TcxStyle;
    cxStyle327: TcxStyle;
    cxStyle328: TcxStyle;
    cxStyle329: TcxStyle;
    cxStyle330: TcxStyle;
    cxStyle331: TcxStyle;
    cxStyle332: TcxStyle;
    cxStyle333: TcxStyle;
    GridTableViewStyleSheetHighContrastBlack: TcxGridTableViewStyleSheet;
    cxStyle334: TcxStyle;
    cxStyle335: TcxStyle;
    cxStyle336: TcxStyle;
    cxStyle337: TcxStyle;
    cxStyle338: TcxStyle;
    cxStyle339: TcxStyle;
    cxStyle340: TcxStyle;
    cxStyle341: TcxStyle;
    cxStyle342: TcxStyle;
    cxStyle343: TcxStyle;
    cxStyle344: TcxStyle;
    GridTableViewStyleSheetHighContrastBlacklarge: TcxGridTableViewStyleSheet;
    cxStyle345: TcxStyle;
    cxStyle346: TcxStyle;
    cxStyle347: TcxStyle;
    cxStyle348: TcxStyle;
    cxStyle349: TcxStyle;
    cxStyle350: TcxStyle;
    cxStyle351: TcxStyle;
    cxStyle352: TcxStyle;
    cxStyle353: TcxStyle;
    cxStyle354: TcxStyle;
    cxStyle355: TcxStyle;
    GridTableViewStyleSheetHighContrastWhite: TcxGridTableViewStyleSheet;
    cxStyle356: TcxStyle;
    cxStyle357: TcxStyle;
    cxStyle358: TcxStyle;
    cxStyle359: TcxStyle;
    cxStyle360: TcxStyle;
    cxStyle361: TcxStyle;
    cxStyle362: TcxStyle;
    cxStyle363: TcxStyle;
    cxStyle364: TcxStyle;
    cxStyle365: TcxStyle;
    cxStyle366: TcxStyle;
    GridTableViewStyleSheetHighContrastWhitelarge: TcxGridTableViewStyleSheet;
    cxStyle367: TcxStyle;
    cxStyle368: TcxStyle;
    cxStyle369: TcxStyle;
    cxStyle370: TcxStyle;
    cxStyle371: TcxStyle;
    cxStyle372: TcxStyle;
    cxStyle373: TcxStyle;
    cxStyle374: TcxStyle;
    cxStyle375: TcxStyle;
    cxStyle376: TcxStyle;
    cxStyle377: TcxStyle;
    cxStyle378: TcxStyle;
    AdvSplitter1: TAdvSplitter;
    FDQuery1: TFDQuery;
    dstb_empresa: TDataSource;
    dstb_ueb: TDataSource;
    dstb_departamento: TDataSource;
    dstb_cargo: TDataSource;
    S1: TMenuItem;
    D1: TMenuItem;
    T1: TMenuItem;
    S2: TMenuItem;
    F1: TMenuItem;
    T2: TMenuItem;
    L1: TMenuItem;
    R1: TMenuItem;
    P2: TMenuItem;
    cxLocalizer1: TcxLocalizer;
    nbMain: TdxNavBar;
    bgBD: TdxNavBarGroup;
    SGIC: TdxNavBarGroup;
    bgBDControl: TdxNavBarGroupControl;
    SGICControl: TdxNavBarGroupControl;
    TvTreeCalidad: TdxDBTreeView;
    C2: TMenuItem;
    PContainer: TPanel;
    V1: TMenuItem;
    PTituloSeries: TPanel;
    A1: TMenuItem;
    E1: TMenuItem;
    TvTree: TdxDBTreeView;
    PMManagementFile: TAdvPopupMenu;
    V2: TMenuItem;
    N2: TMenuItem;
    G1: TMenuItem;
    E2: TMenuItem;
    T3: TMenuItem;
    D2: TMenuItem;
    Panel3: TPanel;
    edtFill: TEdit;
    PageControl1: TcxPageControl;
    tsBasicView: TcxTabSheet;
    cxScrollBox1: TcxScrollBox;
    tsAdvancedView: TcxTabSheet;
    cxScrollBox2: TcxScrollBox;
    GViewSeries: TcxGrid;
    GViewSeriesDBTableView1: TcxGridDBTableView;
    GViewSeriesDBTableView1RootGroup: TcxGridInplaceEditFormGroup;
    GViewSeriesLevel1: TcxGridLevel;
    advManagementDirectoryPath: TAdvPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    N121: TMenuItem;
    I1: TMenuItem;
    SD: TJvSelectDirectory;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    cpInfoPathSubSeries: TJvCaptionPanel;
    lbl1: TLabel;
    edt1: TEdit;
    pLateralSSDisp: TPanel;
    AdvSplitter2: TAdvSplitter;
    dstb_Serietree: TDataSource;
    T4: TMenuItem;
    pVerticalSSDisp: TPanel;
    AdvSplitter3: TAdvSplitter;
    pNavBSeriesDatos: TPanel;
    cxDBNavigator2: TcxDBNavigator;
    dbnSeriesDatos: TDBNavigator;
    pVerticalTitle: TPanel;
    dstb_SeriesDatos: TDataSource;
    cxPCSeriesDatos: TcxPageControl;
    tsSubseriesDatos: TcxTabSheet;
    cxGrid2: TcxGrid;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2DBTableView1IdEstructura: TcxGridDBColumn;
    cxGrid2DBTableView1codsubs: TcxGridDBColumn;
    cxGrid2DBTableView1Fecha: TcxGridDBColumn;
    cxGrid2DBTableView1Version: TcxGridDBColumn;
    cxGrid2DBTableView1Codigodoc: TcxGridDBColumn;
    cxGrid2DBTableView1Idservidor: TcxGridDBColumn;
    cxGrid2DBTableView1deposito: TcxGridDBColumn;
    cxGrid2DBTableView1gaveta: TcxGridDBColumn;
    cxGrid2DBTableView1fichero: TcxGridDBColumn;
    cxGrid2DBTableView1soporte: TcxGridDBColumn;
    cxGrid2DBTableView1observaciones: TcxGridDBColumn;
    cxGrid2DBTableView1uploadserver: TcxGridDBColumn;
    cxGrid2Level1: TcxGridLevel;
    tsVariablesVirtSubseriesDatos: TcxTabSheet;
    Panel12: TPanel;
    DBGrid2: TDBGrid;
    Panel13: TPanel;
    SpeedButton1: TSpeedButton;
    pInfoVar: TPanel;
    PanelCaption: TPanel;
    AdvSplitter4: TAdvSplitter;
    QListaCodigo: TFDQuery;
    DQListaCodigo: TDataSource;
    cmd: TFDQuery;
    AdvPopupMenu2: TAdvPopupMenu;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    PMManagementFileSubSerie: TAdvPopupMenu;
    MenuItem5: TMenuItem;
    MenuItem10: TMenuItem;
    mGestionarContentFile: TMenuItem;
    MenuItem11: TMenuItem;
    DataSource1: TDataSource;
    splitervar: TAdvSplitter;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    GroupBox5: TGroupBox;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    lcbSubSeries: TcxDBLookupComboBox;
    GroupBox3: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    edtUser: TcxDBTextEdit;
    edtPass: TcxDBTextEdit;
    Label14: TLabel;
    edtObservaciones: TcxDBBlobEdit;
    MB: TAdvOfficeStatusBar;
    ImageList1: TImageList;
    cxPageControl1: TcxPageControl;
    tssubseriesdisp: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    Panel2: TPanel;
    cxPageControl3: TcxPageControl;
    tsSSDispoVF: TcxTabSheet;
    lblxDP: TLabel;
    lblyDP: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    edtDPX: TcxDBTextEdit;
    edtDPy: TcxDBTextEdit;
    cxDBMemo1: TcxDBMemo;
    cxDBMemo2: TcxDBMemo;
    tsSSDispoVT: TcxTabSheet;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1codserie: TcxGridDBColumn;
    cxGrid1DBTableView1codsubs: TcxGridDBColumn;
    cxGrid1DBTableView1Series: TcxGridDBColumn;
    cxGrid1DBTableView1Subseries: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    Panel5: TPanel;
    btnAsignVarVir: TSpeedButton;
    SpeedButton2: TSpeedButton;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    Panel1: TPanel;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid2codsubs: TcxDBEditorRow;
    cxDBVerticalGrid2serie: TcxDBEditorRow;
    cxDBVerticalGrid2subserie: TcxDBEditorRow;
    cxDBVerticalGrid2Vdocumental: TcxDBEditorRow;
    cxDBVerticalGrid2Vigencia: TcxDBEditorRow;
    cxDBVerticalGrid2tipodoc: TcxDBEditorRow;
    cxDBVerticalGrid2ayear: TcxDBEditorRow;
    cxDBVerticalGrid2tgestion: TcxDBEditorRow;
    cxDBVerticalGrid2tcentral: TcxDBEditorRow;
    cxDBVerticalGrid2destino: TcxDBEditorRow;
    cxDBVerticalGrid2acceso: TcxDBEditorRow;
    cxDBVerticalGrid2soporte: TcxDBEditorRow;
    cxDBVerticalGrid2frecuencia: TcxDBEditorRow;
    cxDBVerticalGrid2tiempo: TcxDBEditorRow;
    cxDBVerticalGrid2tipoArchivo: TcxDBEditorRow;
    cxDBVerticalGrid2Archivo: TcxDBEditorRow;
    cxDBVerticalGrid2deposito: TcxDBEditorRow;
    cxDBVerticalGrid2gaveta: TcxDBEditorRow;
    cxDBVerticalGrid2usuario: TcxDBEditorRow;
    cxDBVerticalGrid2correo: TcxDBEditorRow;
    cxDBVerticalGrid2observacion: TcxDBEditorRow;
    cxDBVerticalGrid2Idservidor: TcxDBEditorRow;
    cxDBVerticalGrid2carpeta: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid2CategoryRow2: TcxCategoryRow;
    cxDBVerticalGrid2CategoryRow3: TcxCategoryRow;
    cxDBVerticalGrid2CategoryRow4: TcxCategoryRow;
    cxDBVerticalGrid2CategoryRow5: TcxCategoryRow;
    cxDBVerticalGrid2CategoryRow6: TcxCategoryRow;
    cxDBVerticalGrid2croquis: TcxDBEditorRow;
    cxDBVerticalGrid2Foto: TcxDBEditorRow;
    Label1: TLabel;
    jcpTopografiaArchivo: TJvCaptionPanel;
    Label3: TLabel;
    lcbTipodeArchivo: TcxDBLookupComboBox;
    Label4: TLabel;
    edtdeposito: TcxDBTextEdit;
    Label5: TLabel;
    edtGaveta: TcxDBTextEdit;
    lcbServidores: TcxDBLookupComboBox;
    Label11: TLabel;
    Label6: TLabel;
    cxDBBlobEdit1: TcxDBBlobEdit;
    cxPageControl4: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxTabSheet3: TcxTabSheet;
    cxDBImage1: TcxDBImage;
    cxDBImage2: TcxDBImage;
    btnViewTopoData: TJvTransparentButton;
    cxTabSheet4: TcxTabSheet;
    ViewServerDetail: TFDQuery;
    dsViewServerDetail: TDataSource;
    cxDBVerticalGrid3: TcxDBVerticalGrid;
    cxDBVerticalGrid3ipserver: TcxDBEditorRow;
    cxDBVerticalGrid3path: TcxDBEditorRow;
    cxDBVerticalGrid3user: TcxDBEditorRow;
    cxDBVerticalGrid3pass: TcxDBEditorRow;
    cxDBVerticalGrid3puerto: TcxDBEditorRow;
    Panel4: TPanel;
    cxDBNavigator4: TcxDBNavigator;
    DBNavigator2: TDBNavigator;
    JvTransparentButton1: TJvTransparentButton;
    Label7: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    AdvPopupMenu1: TAdvPopupMenu;
    MenuItem7: TMenuItem;
    JvTransparentButton2: TJvTransparentButton;
    GViewSeriesDBTableView1IdEstructura: TcxGridDBColumn;
    GViewSeriesDBTableView1id: TcxGridDBColumn;
    GViewSeriesDBTableView1codsubs: TcxGridDBColumn;
    GViewSeriesDBTableView1tipoArchivo: TcxGridDBColumn;
    GViewSeriesDBTableView1Archivo: TcxGridDBColumn;
    GViewSeriesDBTableView1deposito: TcxGridDBColumn;
    GViewSeriesDBTableView1gaveta: TcxGridDBColumn;
    GViewSeriesDBTableView1usuario: TcxGridDBColumn;
    GViewSeriesDBTableView1correo: TcxGridDBColumn;
    GViewSeriesDBTableView1observacion: TcxGridDBColumn;
    GViewSeriesDBTableView1Idservidor: TcxGridDBColumn;
    GViewSeriesDBTableView1carpeta: TcxGridDBColumn;
    cxDBLookupComboBox2: TcxDBLookupComboBox;
    NombreSS: TcxGridDBColumn;
    edtNombreSerie: TcxDBTextEdit;
    pVariablesSD: TPanel;
    cxPageControl2: TcxPageControl;
    tsvar: TcxTabSheet;
    ToolBar3: TToolBar;
    ToolButton4: TToolButton;
    ToolButton9: TToolButton;
    cxTabSheet5: TcxTabSheet;
    cxDBVerticalGrid4: TcxDBVerticalGrid;
    cxDBVerticalGrid4Etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid4tipo: TcxDBEditorRow;
    cxDBVerticalGrid4longitud: TcxDBEditorRow;
    cxDBVerticalGrid4descripcion: TcxDBEditorRow;
    cxDBVerticalGrid4ListaDesplegable: TcxDBEditorRow;
    cxGrid3DBTableView1: TcxGridDBTableView;
    cxGrid3Level1: TcxGridLevel;
    cxGrid3: TcxGrid;
    cxGrid3DBTableView1NomVariable: TcxGridDBColumn;
    Panel7: TPanel;
    cxDBNavigator5: TcxDBNavigator;
    DBNavigator4: TDBNavigator;
    cxDBVerticalGrid4CategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid3CategoryRow1: TcxCategoryRow;
    cxGrid2DBTableView1id: TcxGridDBColumn;
    cxGrid2DBTableView1titulodoc: TcxGridDBColumn;
    APMArbol: TAdvPopupMenu;
    N3: TMenuItem;
    A2: TMenuItem;
    E3: TMenuItem;
    N1: TMenuItem;
    MenuItem6: TMenuItem;
    N4: TMenuItem;
    P3: TMenuItem;
    JvTransparentButton3: TJvTransparentButton;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
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
    PVarVirtDataEstruct: TPanel;
    cxDBVerticalGrid5: TcxDBVerticalGrid;
    ivj1: TcxDBEditorRow;
    ivj2: TcxDBEditorRow;
    ivj3: TcxDBEditorRow;
    ivj4: TcxDBEditorRow;
    ivj5: TcxDBEditorRow;
    ivj6: TcxDBEditorRow;
    ivj7: TcxDBEditorRow;
    ivj8: TcxDBEditorRow;
    ivj9: TcxDBEditorRow;
    ivj10: TcxDBEditorRow;
    ivj11: TcxDBEditorRow;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    AdvSplitter5: TAdvSplitter;
    dstb_tree: TDataSource;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btn2Click(Sender: TObject);
    procedure Acercade1Click(Sender: TObject);
    procedure ControldeVersiones1Click(Sender: TObject);
    procedure btnautenticaClick(Sender: TObject);
    procedure btnusercontrolClick(Sender: TObject);
    procedure P1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure D1Click(Sender: TObject);
    procedure T1Click(Sender: TObject);
    procedure S2Click(Sender: TObject);
    procedure F1Click(Sender: TObject);
    procedure T2Click(Sender: TObject);
    procedure L1Click(Sender: TObject);
    procedure P2Click(Sender: TObject);
    procedure R1Click(Sender: TObject);
    procedure eliminarClick(Sender: TObject);
    procedure TvTreeCalidadChange(Sender: TObject; Node: TTreeNode);
    procedure C2Click(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure TvTree1Change(Sender: TObject; Node: TTreeNode);
    procedure etiquetaClick(Sender: TObject);
    procedure modificarClick(Sender: TObject);
    procedure V1Click(Sender: TObject);
    procedure A1Click(Sender: TObject);
    procedure TvTree1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure ToolButton1Click(Sender: TObject);
    procedure E1Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure dbnSeriesDatosClick(Sender: TObject; Button: TNavigateBtn);
    procedure ToolButton5Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure G1Click(Sender: TObject);
    procedure V2Click(Sender: TObject);
    procedure E2Click(Sender: TObject);
    procedure Ayuda1Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure ToolButton18Click(Sender: TObject);
    procedure F2Click(Sender: TObject);
    procedure F3Click(Sender: TObject);
    procedure btnviewClick(Sender: TObject);
    procedure T3Click(Sender: TObject);
    procedure D2Click(Sender: TObject);
    procedure cxGrid1DBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure V3Click(Sender: TObject);
    procedure GViewSeriesDBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure GViewSeriesDBTableView1carpetaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure MenuItem1Click(Sender: TObject);
    procedure cpInfoPathSubSeriesButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
    procedure I1Click(Sender: TObject);
    procedure cxDBBlobEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxDBBlobEdit3PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure ToolButton8Click(Sender: TObject);
    procedure edtestructuraClick(Sender: TObject);
    procedure GViewSeriesDBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure ToolButton3Click(Sender: TObject);
    procedure dstb_SerietreeDataChange(Sender: TObject; Field: TField);
    procedure btnAsignVarVirClick(Sender: TObject);
    procedure btnLateralCloseClick(Sender: TObject);
    procedure btnLateralOpenClick(Sender: TObject);
    procedure dstb_SeriesDatosDataChange(Sender: TObject; Field: TField);
    procedure JvTransparentButton2Click(Sender: TObject);
    procedure btnFuncionesClick(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure mGestionarContentFileClick(Sender: TObject);
    procedure btnCloseVerticalClick(Sender: TObject);
    procedure btnOpenVerticalClick(Sender: TObject);
    procedure T4Click(Sender: TObject);
    procedure iv11EditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxDBVerticalGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ToolButton9Click(Sender: TObject);
    procedure cxGrid2DBTableView1observacionesPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure Button1Click(Sender: TObject);
    procedure D3Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure btnHlpClick(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure MBPanelClick(Sender: TObject; PanelIndex: Integer);
    procedure cxDBVerticalGrid2observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure jcpTopografiaArchivoButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
    procedure btnViewTopoDataClick(Sender: TObject);
    procedure lcbServidoresPropertiesCloseUp(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure dstb_SeriesDatosUpdateData(Sender: TObject);
    procedure E3Click(Sender: TObject);
    procedure TvTreeMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure JvTransparentButton3Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure dstb_treeDataChange(Sender: TObject; Field: TField);
  private
    procedure CargoState(aState: Boolean);
    procedure MDSeriesSubSeriesDMDR;
    procedure RemoveMDSeriesSubSeriesDMDR;
    procedure PMConfigMainNode(aIdNodo: integer);
    { Private declarations }
    procedure CreaMenu;
    procedure DestroyMenu;
    procedure ViewPanelLateral;
    procedure ViewPanelVertical;
  public
    { Public declarations }
    varUltimoQuery: string;
    iRow: integer; //Posicion en la fila de la VerticalGrid
    procedure Rellena;
    procedure RellenaPrj;
    procedure EquipTree;
    procedure DesArmTree;
    procedure CreateMapProcess;
    procedure OcultaVGVardef;
    procedure OcultaVGVardefPrj;
    procedure SaveTreeStateNode;
    procedure LoadTreeStateNode;
  end;

var
  MAINFORM: TMAINFORM;
  AnItem: TTreeNode; // TcxTreeListNode;
  NewId, ParentID: integer;
  //MENU
  PMNodeTree: TAdvPopupMenu;
  agregar: TMenuItem;
  etiqueta: TMenuItem;
  eliminar: TMenuItem;
  N1: TMenuItem;
  modificar: TMenuItem;
  N4: TMenuItem;
  pepe: Boolean;
  Salvo2:Boolean;

const
  CEstructura: array[1..4] of string = ('Etiquetas', 'Estructuras', 'Cargos', 'Proyectos');

implementation

{$R *.dfm}

uses
  UHistory, UAbout, UAutentica, UCapaDatos, UUserGest, UDocManagement,
  UCLSeriesDocumentales, UCLDestino, UCLAcceso, UCLSoporte, UCLFrecuencia,
  UCLTipoDoc, UNodeAsist, UCLFtpServer, UCLProcesos, UCLRepActArchiv,
  UGestEstruct, UCategoria_Ocupa, UCL_Cargo, UCLVariables, UMangementArch,
  USeriesDisp, UCL_Especialistas, UEntrada, UManagementFileSeries, UCLFacultades,
  UCLFunciones, UViewFunciones, UICSeriesDocumentales, UCLTipoEstructura,
  UCL_Depositos, UVeditor, UVarVirtualSeriesD, UExcelExport, UClTipoObjeto,
  UManagementNode, USystemMsg, UAddNewNode, UNodeProperties;

procedure TMAINFORM.A1Click(Sender: TObject);
begin
  with TfrmManagemetArch.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.Acercade1Click(Sender: TObject);
begin
  with TfrmAbout.Create(nil) do
  try
    Image1.Visible := True;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.Ayuda1Click(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TMAINFORM.btn2Click(Sender: TObject);
begin
  close;
end;

procedure TMAINFORM.btnAsignVarVirClick(Sender: TObject);
begin
  if UDM.sms('¿Desea agregar la serie a la estructura actual?', 4) = 6 then
  begin
    if not UDM.tb_Serietree.Locate('IdEstructura;codsubs', VarArrayOf([UDM.tb_tree.FieldByName('IdEstructura').AsString, UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString]), []) then
    begin
      UDM.tb_Serietree.Append;
      UDM.tb_Serietree.FieldByName('IdEstructura').AsString := UDM.tb_tree.FieldByName('IdEstructura').AsString;
      UDM.tb_Serietree.FieldByName('id').AsInteger := UDM.tb_tree.FieldByName('id').AsInteger;
      UDM.tb_Serietree.FieldByName('codsubs').AsString := UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString;
      try
        UDM.tb_Serietree.Post;
      except
        on E: EFDException do
        begin
          UDM.sms('La serie ' + UDM.Tb_SeriesDispo.FieldByName('Etiqueta').AsString + ' no se pudo agregar. Motivo: ' + E.Message, 1);
          Exit;
        end;
      end;
    end;

  end;
end;

procedure TMAINFORM.btnautenticaClick(Sender: TObject);
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

procedure TMAINFORM.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TMAINFORM.btnCloseVerticalClick(Sender: TObject);
begin
  ViewPanelVertical;
end;

procedure TMAINFORM.btnFuncionesClick(Sender: TObject);
begin
  ExcelExport(nil, GViewSeries);
end;

procedure TMAINFORM.btnHlpClick(Sender: TObject);
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
  ejecutaPDF(PathSys+'ReportApp.exe');
end;

procedure TMAINFORM.btnLateralCloseClick(Sender: TObject);
begin
  ViewPanelLateral;
end;

procedure TMAINFORM.btnLateralOpenClick(Sender: TObject);
begin
  ViewPanelLateral;
end;

procedure TMAINFORM.btnOpenVerticalClick(Sender: TObject);
begin
  ViewPanelVertical;
end;

procedure TMAINFORM.btnusercontrolClick(Sender: TObject);
begin
  with TfrmGestUser.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.btnviewClick(Sender: TObject);
begin
  if UDM.tb_Serietree.RecordCount = 0 then
  begin
    udm.sms('Debe identificar al menos una serie documental válida.', 3);
    if UDM.sms('¿Desea consultar el listado de Series documentales identificadas?', 4) = 6 then
      ToolButton1Click(Sender);
    Exit;
  end;
  {tsInputSeriesData.TabVisible := True;
  tsSeriesDef.TabVisible := False;
  pcSeriesDocumentales.ActivePage := tsInputSeriesData;        }
end;

procedure TMAINFORM.btnViewTopoDataClick(Sender: TObject);
begin
  jcpTopografiaArchivo.Visible := True;
  jcpTopografiaArchivo.Left := GroupBox5.Left + Trunc(GroupBox5.Width / 2) - Trunc(jcpTopografiaArchivo.Width / 2);
  jcpTopografiaArchivo.BringToFront;
  jcpTopografiaArchivo.Caption := 'Datos topográficos de ' + AnsiQuotedStr(UDM.SudSDetail.FieldByName('subserie').AsString, '"');
end;

procedure TMAINFORM.Button1Click(Sender: TObject);
begin
  cpInfoPathSubSeries.Visible := False;
end;

procedure TMAINFORM.C1Click(Sender: TObject);
begin
  with TfrmCLCargo.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.C2Click(Sender: TObject);
begin
  with TfrmCatOcupa.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.ControldeVersiones1Click(Sender: TObject);
begin
  with TfrmHistory.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.cpInfoPathSubSeriesButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
begin
  if Button = capClose then
    cpInfoPathSubSeries.Visible := False;
end;

procedure TMAINFORM.CreaMenu;
var
  i: integer;
  qNodos: TFDQuery;
begin
  //PMNodeTree
  if FindComponent('PMNodeTree1') <> nil then
    Exit;

  PMNodeTree := TAdvPopupMenu.Create(Self);
  PMNodeTree.Name := 'PMNodeTree1';
  //agregar
  agregar := TMenuItem.Create(Self);
  //eliminar
  eliminar := TMenuItem.Create(Self);
  //N1
  N1 := TMenuItem.Create(Self);
  //modificar
  modificar := TMenuItem.Create(Self);
  //N4
  N4 := TMenuItem.Create(Self);
  //PMNodeTree

  PMNodeTree.Version := '2.6.4.0';
  //agregar
  agregar.Name := 'agregar';
  PMNodeTree.Items.Add(agregar);
  agregar.Caption := 'Agregar';
  agregar.Visible := true;
  //etiqueta
  qNodos := TFDQuery.Create(nil);
  with qNodos do
  begin
    Active := False;
    Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('select idestructura, Nombreestructura from cl_tipoestructura where Idestructura not in (select Idestructura from tb_tree)');
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        Exit;
      end;
    end;
  end;
  qNodos.First;
  for i := 0 to qNodos.RecordCount - 1 do
  begin
    etiqueta := TMenuItem.Create(Self);
    etiqueta.Name := 'etiqueta' + IntToStr(i);
    agregar.Add(etiqueta);
    etiqueta.Hint := qNodos.FieldByName('Idestructura').AsString;
    etiqueta.Caption := qNodos.FieldByName('Nombreestructura').AsString;
    etiqueta.OnClick := etiquetaClick;
    etiqueta.Visible := True;
    qNodos.Next;
  end;
    //eliminar
  eliminar.Name := 'eliminar';
  PMNodeTree.Items.Add(eliminar);
  eliminar.Caption := 'Eliminar';
  eliminar.OnClick := eliminarClick;
  //N1
  N1.Name := 'N1';
  PMNodeTree.Items.Add(N1);
  N1.Caption := '-';
  //modificar
  modificar.Name := 'modificar';
  PMNodeTree.Items.Add(modificar);
  modificar.Caption := 'Propiedades';
  modificar.OnClick := modificarClick;
  //N4
  N4.Name := 'N4';
  PMNodeTree.Items.Add(N4);
  N4.Caption := '-';
end;

procedure TMAINFORM.CreateMapProcess;
var
  ContG, ContP, ContServ: integer;

  function AddTreeProcess(aCode, aPadre, aImg: integer; Etiq: string): Boolean;
  begin
    UDM.tb_mp.Append;
    UDM.tb_mp.FieldByName('Id').AsInteger := aCode;
    UDM.tb_mp.FieldByName('Padre').AsInteger := aPadre;
    UDM.tb_mp.FieldByName('Icono').AsInteger := aImg;
    UDM.tb_mp.FieldByName('etiqueta').AsString := Etiq;
    try
      UDM.tb_mp.Post;
      UDM.tb_mp.Active := False;
      UDM.tb_mp.Active := True;
    except
      UDM.tb_mp.Cancel;
    end;
  end;

begin
  UDM.tcl_procesosGrupos.Active := True;
  UDM.tcl_procesosGrupos.First;
  ContG := 1;
  while not UDM.tcl_procesosGrupos.Eof do
  begin
    AddTreeProcess(ContG, 0, 14, UDM.tcl_procesosGrupos.FieldByName('NombreGrupo').AsString);
    UDM.tcl_Procesos.Active := True;
    UDM.tcl_Procesos.First;
    ContP := UDM.GetNewNodeMP;
    while not UDM.tcl_Procesos.Eof do
    begin
      AddTreeProcess(ContP, ContG, 15, UDM.tcl_Procesos.FieldByName('NombreProceso').AsString);
      UDM.tcl_Procesos.Active := True;
      UDM.tcl_Procesos.First;
      ContServ := UDM.GetNewNodeMP;
      while not UDM.tcl_ProcesoSubproceso.Eof do
      begin
        AddTreeProcess(ContServ, ContP, 16, UDM.tcl_ProcesoSubproceso.FieldByName('Nombresubproceso').AsString);
        ContServ := UDM.GetNewNodeMP;
        Application.ProcessMessages;
        UDM.tcl_ProcesoSubproceso.Next;
      end;
      ContP := UDM.GetNewNodeMP;
      Application.ProcessMessages;
      UDM.tcl_Procesos.Next;
    end;
    // Fin
    ContG := UDM.GetNewNodeMP;
    Application.ProcessMessages;
    UDM.tcl_procesosGrupos.Next;
  end;
end;

procedure TMAINFORM.ViewPanelLateral;
begin
  if pLateralSSDisp.Visible then
  begin
    pLateralSSDisp.Visible := False;
  end
  else
  begin
    //Panel
    pLateralSSDisp.Visible := True;
    AdvSplitter2.Align := alNone;
    pLateralSSDisp.Align := alNone;
    pLateralSSDisp.Align := alRight;
    AdvSplitter2.Align := alRight;
  end;
end;

procedure TMAINFORM.ViewPanelVertical;
begin
  if pVerticalSSDisp.Visible then
  begin
    pVerticalSSDisp.Visible := False;
    AdvSplitter3.Visible := False;
  end
  else
  begin
    //Panel
    pVerticalSSDisp.Visible := True;
    AdvSplitter3.Align := alNone;
    pVerticalSSDisp.Align := alNone;
    pVerticalSSDisp.Align := alBottom;
    AdvSplitter3.Align := alBottom;
    AdvSplitter3.Visible := True;

  end;
end;

procedure TMAINFORM.cxDBBlobEdit1PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  advManagementDirectoryPath.PopupAtCursor;
end;

procedure TMAINFORM.cxDBBlobEdit3PropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.tb_Serietree.FieldByName('observacion').Value = null) or (trim(UDM.tb_Serietree.FieldByName('observacion').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
    end;
  NombreSerieDocAsig := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  CampoTexto(@UDM.dstb_Serietree, 'observacion', 'Observaciones sobre la serie ' + NombreSerieDocAsig);
end;

procedure TMAINFORM.cxDBVerticalGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  Campo: string;
begin
  //Este codigo lo veo innecesario... que despues me expliquen....
{  Irow := -1;
  i := Y div cxDBVerticalGrid1.OptionsView.RowHeight;
  if i <= UDM.tb_SerieDatosVar.recordcount - 1 then
  begin
    iRow := i;
    UDM.tb_SerieDatosVar.First;
    UDM.tb_SerieDatosVar.MoveBy(i);
    s := UDM.tb_SerieDatosVar.fieldbyname('IdVar').asstring;
    if UDM.cl_variables.locate('idvar', UDM.tb_SerieDatosVar.fieldbyname('IdVar').asinteger, []) then
    begin
      s := UDM.cl_variables.fields[1].value;
      g1.Enabled := False;
      Panel5.Visible := False;
      if UDM.cl_variables.fieldbyname('ListaDesplegable').value then
      begin
        PanelCaption.Caption := ' Variable: ' + UDM.cl_Variables.fieldbyname('NomVariable').asstring;
//********************************************************************************************
        QListaCodigo.Active := false;
        QListaCodigo.SQL.Clear;
        if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Entero' then
          Campo := 'VarInteger'
        else if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Real' then
          Campo := 'VarDouble'
        else if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Fecha' then
          Campo := 'VarDate'
        else
          Campo := 'VarString255';
        DBGrid2.Columns[0].FieldName := Campo;
        QListaCodigo.SQL.Add('select ' + Campo + ' from tb_SerieDatosVar where IdVar=' + UDM.tb_SerieDatosVar.fieldbyname('IdVar').asstring + ' and ' + Campo + ' <> NULL  group by ' + Campo + ' order by ' + Campo);
        QListaCodigo.Active := true;
        pInfoVar.Visible := false;
        if QListaCodigo.RecordCount = 0 then
          pInfoVar.Visible := true;
        pNavBSeriesDatos.Visible := true;
        AdvSplitter4.Visible := true;
        Panel5.Visible := True;
      end;
    end;
  end;  }
end;

procedure TMAINFORM.cxDBVerticalGrid2observacionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  EsReadOnly := True;
  CampoTexto(@UDM.dsSudSDetail, 'observacion', 'Observaciones sobre la serie ' + UDM.SudSDetail.FieldByName('subserie').AsString);
  EsReadOnly := False;
end;

procedure TMAINFORM.cxGrid1DBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TMAINFORM.cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  PMManagementFileSubSerie.PopupAtCursor;
end;

procedure TMAINFORM.cxGrid2DBTableView1observacionesPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TMAINFORM.PMConfigMainNode(aIdNodo: integer);
begin
  {agregar.Visible := True;
  eliminar.Visible := True;
  modificar.Visible := True;
  if aIdNodo = 0 then
  begin
    agregar.Visible := True;
    eliminar.Visible := False;
    modificar.Visible := False;
  end;  }
end;

procedure TMAINFORM.MBPanelClick(Sender: TObject; PanelIndex: Integer);
begin
  if PanelIndex = 10 then
  begin
    if MB.Panels[PanelIndex].ImageIndex = 0 then
    begin
      ViewPanelVertical;
      MB.Panels[PanelIndex].ImageIndex := 1;
    end
    else if MB.Panels[PanelIndex].ImageIndex = 1 then
    begin
      ViewPanelVertical;
      MB.Panels[PanelIndex].ImageIndex := 0;
    end;
  end;
  if PanelIndex = 11 then
  begin
    if MB.Panels[PanelIndex].ImageIndex = 2 then
    begin
      ViewPanelLateral;
      MB.Panels[PanelIndex].ImageIndex := 3;
    end
    else if MB.Panels[PanelIndex].ImageIndex = 3 then
    begin
      ViewPanelLateral;
      MB.Panels[PanelIndex].ImageIndex := 2;
    end;

  end;
end;

procedure TMAINFORM.MDSeriesSubSeriesDMDR;
begin
  UDM.cl_series.Active := False;
  UDM.cl_subseries.Active := False;
  UDM.cl_subseries.MasterSource := UDM.dscl_series;
  UDM.cl_subseries.MasterFields := 'codserie';
  UDM.cl_subseries.IndexFieldNames := 'codserie;codsubs';
  UDM.cl_series.Active := True;
  UDM.cl_subseries.Active := True;
end;

procedure TMAINFORM.MenuItem1Click(Sender: TObject);
begin
  if SD.Execute then
    if trim(SD.Directory) <> '' then
    begin
      if (UDM.tb_Serietree.State <> dsInsert) and (UDM.tb_Serietree.State <> dsEdit) then
        UDM.tb_Serietree.Edit;
      UDM.tb_Serietree.FieldByName('carpeta').AsString := SD.Directory;
    end;
end;

procedure TMAINFORM.MenuItem5Click(Sender: TObject);
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
  end
  else
  begin
    UDM.sms('Especifique una subserie válida para visualizar.', 3);
  end;
end;

procedure TMAINFORM.MenuItem7Click(Sender: TObject);
begin
  jcpTopografiaArchivo.Visible := True;
  jcpTopografiaArchivo.Left := GroupBox5.Left + Trunc(GroupBox5.Width / 2) - Trunc(jcpTopografiaArchivo.Width / 2);
  jcpTopografiaArchivo.BringToFront;
  jcpTopografiaArchivo.Caption := 'Datos topográficos de ' + AnsiQuotedStr(UDM.SudSDetail.FieldByName('subserie').AsString, '"');
end;

procedure TMAINFORM.CargoState(aState: Boolean);
begin
  UDM.cl_cargo.Active := aState;
  UDM.cl_funcionesgen.Active := aState;
  UDM.cl_facultadesgen.Active := aState;
end;

procedure TMAINFORM.TvTreeCalidadChange(Sender: TObject; Node: TTreeNode);
begin
  TvTreeCalidad.SelectedIndex := UDM.tb_mp.FieldByName('icono').AsInteger;
end;

procedure TMAINFORM.TvTreeMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  s: string;
begin
 { AnItem := TvTree.GetNodeAt(X, Y);
  if AnItem <> nil then
  begin
    if Button = mbRight then
    begin
    end
    else
    begin
      TvTree.SelectedIndex:=UDM.tb_tree.FieldByName('Icono').AsInteger;
    end;
  end;}
end;

procedure TMAINFORM.TvTree1Change(Sender: TObject; Node: TTreeNode);
begin
  //PMConfigMainNode(UDM.tb_tree.FieldByName('IdEstructura').AsString);
  PTituloSeries.Caption := 'CUADRO DE CLASIFICACIÓN (' + Node.Text + ')';
  MB.Panels[7].Text := PTituloSeries.Caption;
 // pStructInfo.Caption := '   Estructura actual: ' + PTituloSeries.Caption;
  with NodoPadreActual do
  begin
    Id := UDM.tb_tree.FieldByName('id').AsInteger;
    estructura := UDM.tb_tree.FieldByName('Idestructura').AsString;
    Padre := UDM.tb_tree.FieldByName('Padre').AsInteger;
    icono := UDM.tb_tree.FieldByName('icono').AsInteger;
    Tipo := UDM.tb_tree.FieldByName('Tipo').AsInteger;
  end;
  if TRIM(NodoActivo) = '' then
    NodoActivo := Node.Text;
  if UDM.tb_tree.State = dsInsert then
    TvTree.SelectedIndex := imagenactual
  else
    TvTree.SelectedIndex := UDM.tb_tree.FieldByName('icono').AsInteger;
end;

procedure TMAINFORM.TvTree1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  s: string;
begin
  AnItem := TvTree.GetNodeAt(X, Y);
  ParentID := UDM.GetIDParentTreeNode;
  if AnItem <> nil then
  begin
    if Button = mbRight then
    begin
    end
    else
    begin
      //Esto hay que preguntarlo no vaya a ser que tu sabes...
      {if ansilowercase(trim(UDM.tb_tree.FieldByName('aowner').AsString))='system' then
      begin
        PContainer.Visible := False;
        exit;
      end;    }
      s := UDM.tb_tree.FieldByName('etiqueta').AsString;
      if NodoActivo <> AnItem.Text then
      begin
        NodoActivo := AnItem.Text;
        //pcSeriesDocumentales.ActivePage := tsSeriesDef;
      end;
      if UDM.tb_tree.FieldByName('tipo').AsInteger <> 1 then
      begin
        PContainer.Visible := True;
      end
      else
      begin
        PContainer.Visible := False;
      end;
    end;
  end;
end;

procedure TMAINFORM.V1Click(Sender: TObject);
begin
  with TfrmVariables.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.V2Click(Sender: TObject);
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

procedure TMAINFORM.V3Click(Sender: TObject);
begin
  with TfrmVariablesVirtSeries.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.D1Click(Sender: TObject);
begin
  with TfrmCLDestino.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.D2Click(Sender: TObject);
begin
  with TfrmDeposito.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.D3Click(Sender: TObject);
begin
  with UDM.tb_AllSon do
  begin
    Active := False;
    Params[0].Value := UDM.tb_tree.FieldByName('Id').AsInteger;
    Active := True;
  end;
  with TfrmAddNode.Create(nil) do
  try
    papa := NodoPadreActual.Id;
    imgpapa := NodoPadreActual.ICONO;
    DBNavigator3.VisibleButtons := [nbFirst, nbPrior, nbNext, nbLast];
    tsNewStructDisp.TabVisible := True;
    cxPageControl2.ActivePage := tsNewStructDisp;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbPost then
  begin
    if UDM.tb_Serietree.ChangeCount > 0 then
      UDM.tb_Serietree.ApplyUpdates(0);
  end;
end;

procedure TMAINFORM.dbnSeriesDatosClick(Sender: TObject; Button: TNavigateBtn);
var
  CodSerie, CodSubSerie: string;
  cmdVar: TFDQuery;
begin
  if Button = nbPost then
  begin
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
    //Rellena;
    CodSerie := VarToStr(UDM.Conn.ExecSQLScalar('select codserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString)));
    if UDM.cl_series.Locate('codserie', CodSerie, []) then
      if UDM.cl_subseries.Locate('codserie;codsubs', vararrayOf([CodSerie, UDM.tb_SeriesDatos.FieldByName('codsubs').AsString]), []) then
      begin
        UDM.cl_VarSubserie.First;
        while not UDM.cl_VarSubserie.Eof do
        begin
          if not UDM.tb_SerieDatosVar.Locate('Id;codsubs;Fecha;Version;Orden;IdVar', VarArrayOf([UDM.tb_SeriesDatos.FieldByName('Id').AsString, UDM.tb_SeriesDatos.FieldByName('codsubs').AsString, UDM.tb_SeriesDatos.FieldByName('Fecha').AsString, UDM.tb_SeriesDatos.FieldByName('version').AsString, UDM.cl_VarSubserie.FieldByName('Orden').AsString, UDM.cl_VarSubserie.FieldByName('idvar').AsString]), []) then
          begin
            UDM.tb_SerieDatosVar.Append;
            UDM.tb_SerieDatosVar.FieldByName('Id').AsString := UDM.tb_SeriesDatos.FieldByName('Id').AsString;
            UDM.tb_SerieDatosVar.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
            UDM.tb_SerieDatosVar.FieldByName('Fecha').Value := UDM.tb_SeriesDatos.FieldByName('Fecha').Value;
            UDM.tb_SerieDatosVar.FieldByName('version').AsInteger := UDM.tb_SeriesDatos.FieldByName('version').AsInteger;
            UDM.tb_SerieDatosVar.FieldByName('Orden').AsInteger := UDM.cl_VarSubserie.FieldByName('Orden').AsInteger;
            UDM.tb_SerieDatosVar.FieldByName('idvar').AsInteger := UDM.cl_VarSubserie.FieldByName('idvar').AsInteger;
            try
              UDM.tb_SerieDatosVar.Post;
            except
              UDM.tb_SerieDatosVar.Cancel;
            end;
          end;

          UDM.cl_VarSubserie.Next;
        end;
      end;
  end;
  if Button = nbInsert then
  begin
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
    if UDM.tb_SeriesDatos.State = dsInsert then
    begin
      UDM.tb_SeriesDatos.FieldByName('idservidor').AsInteger := UDM.tb_Serietree.FieldByName('idservidor').AsInteger;
      UDM.tb_SeriesDatos.FieldByName('deposito').AsString := UDM.tb_Serietree.FieldByName('deposito').AsString;
      UDM.tb_SeriesDatos.FieldByName('gaveta').AsString := UDM.tb_Serietree.FieldByName('gaveta').AsString;
    end;
  end;
end;
{begin
  if Button = nbInsert then
  begin
    if UDM.tb_SeriesDatos.State = dsInsert then
    begin
      UDM.tb_SeriesDatos.FieldByName('idservidor').AsInteger := UDM.tb_Serietree.FieldByName('servidor').AsInteger;
      UDM.tb_SeriesDatos.FieldByName('deposito').AsString := UDM.tb_Serietree.FieldByName('deposito').AsString;
      UDM.tb_SeriesDatos.FieldByName('gaveta').AsString := UDM.tb_Serietree.FieldByName('gaveta').AsString;
    end;

  end;

  if Button = nbPost then
  begin
    if UDM.tb_SeriesDatos.State = dsInsert then
    begin
      UDM.tb_SeriesDatos.FieldByName('idservidor').AsInteger := UDM.tb_Serietree.FieldByName('servidor').AsInteger;
      UDM.tb_SeriesDatos.FieldByName('deposito').AsString := UDM.tb_Serietree.FieldByName('deposito').AsString;
      UDM.tb_SeriesDatos.FieldByName('gaveta').AsString := UDM.tb_Serietree.FieldByName('gaveta').AsString;
    end;
  end;
end;  }

procedure TMAINFORM.DesArmTree;
begin
  UDM.tb_tree.Filtered := False;
  UDM.tb_tree.Filter := 'ID<>0';
  UDM.tb_tree.Filtered := True;
  TvTree.DataSource := nil;
end;

procedure TMAINFORM.DestroyMenu;
var
  i: Integer;
begin
  if N4 <> nil then
    N4.Free;
  if modificar <> nil then
    modificar.Free;
  if N1 <> nil then
    N1.Free;
  if eliminar <> nil then
    eliminar.Free;
  for i := agregar.Count - 1 downto 0 do
    if agregar.Items[i] <> nil then
      agregar.Items[i].Free;
  if agregar <> nil then
    agregar.Free;
  if PMNodeTree <> nil then
    PMNodeTree.Free;
end;

procedure TMAINFORM.dstb_SeriesDatosDataChange(Sender: TObject; Field: TField);
begin
  pVerticalTitle.Caption := ' Documentos de la subserie: ';
  pVerticalTitle.Caption := pVerticalTitle.Caption + VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString)));
  if UDM.tb_SerieDatosVar.RecordCount > 0 then
  begin
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
    Rellena;
    //UDM.tb_SeriesDatos.EnableControls;
    cxGrid2.Align := alNone;
    splitervar.Align := alNone;
    cxPageControl2.Align := alNone;
    cxPageControl2.Align := alRight;
    splitervar.Align := alRight;
    splitervar.Visible := True;
    cxGrid2.Align := alClient;
    cxPageControl2.Visible := True;
    ToolBar3.Visible := True;
    pVariablesSD.Visible:=True;
  end
  else
  begin
    OcultaVGVardef;
    ToolBar3.Visible := False;
    Panel3.Align := alClient;
    cxGrid2.Update;
    Panel3.Update;
    splitervar.Align := alNone;
    cxPageControl2.Align := alNone;
    splitervar.Visible := False;
    cxPageControl2.Visible := False;
    pVariablesSD.Visible:=False;
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
  end;
end;

procedure TMAINFORM.dstb_SeriesDatosUpdateData(Sender: TObject);
begin
  pVerticalTitle.Caption := ' Documentos de la subserie: ';
  pVerticalTitle.Caption := pVerticalTitle.Caption + VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString)));
  if UDM.tb_SerieDatosVar.RecordCount > 0 then
  begin
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
    Rellena;
    //UDM.tb_SeriesDatos.EnableControls;
    cxGrid2.Align := alNone;
    splitervar.Align := alNone;
    cxPageControl2.Align := alNone;
    cxPageControl2.Align := alRight;
    splitervar.Align := alRight;
    splitervar.Visible := True;
    cxGrid2.Align := alClient;
    cxPageControl2.Visible := True;
    ToolBar3.Visible := True;
   // Panel4.Visible := True;
  end
  else
  begin
    OcultaVGVardef;
  //  Panel4.Visible := False;
    ToolBar3.Visible := False;
    Panel3.Align := alClient;
    cxGrid2.Update;
    Panel3.Update;
    splitervar.Align := alNone;
    cxPageControl2.Align := alNone;
    splitervar.Visible := False;
    cxPageControl2.Visible := False;
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
  end;
end;

procedure TMAINFORM.dstb_SerietreeDataChange(Sender: TObject; Field: TField);
var
  aNombre: string;
begin
  if (UDM.tb_Serietree.State <> dsInsert) and (UDM.tb_Serietree.State <> dsEdit) then
  begin
    try
      UDM.Tb_SeriesDispo.Active := False;
      UDM.Tb_SeriesDispo.Params[0].Value := UDM.tb_tree.FieldByName('id').Value;
      UDM.Tb_SeriesDispo.Active := True;
      UDM.Tb_SeriesDispo.FetchAll;
    except
      on E: EFDException do
      begin
        udm.sms('No se pudo acceder al listado de subseries disponibles. Motivo: ' + e.Message, 1);
        exit;
      end;
    end;
    try
      UDM.SudSDetail.Active := False;
      UDM.SudSDetail.Params[0].Value := UDM.tb_Serietree.FieldByName('codsubs').Value;
      UDM.SudSDetail.Active := True;
      UDM.SudSDetail.FetchAll;
    except
      on E: EFDException do
      begin
        udm.sms('No se pueden cosultar los detalles de la subserie documental actual. Motivo: ' + e.Message, 1);
        exit;
      end;
    end;
    try
      UDM.VarSSDetail.Active := False;
      UDM.VarSSDetail.Params[0].Value := UDM.tb_Serietree.FieldByName('codsubs').Value;
      UDM.VarSSDetail.Active := True;
      UDM.VarSSDetail.FetchAll;
    except
      on E: EFDException do
      begin
        udm.sms('No se pueden cosultar los detalles de la subserie documental actual. Motivo: ' + e.Message, 1);
        exit;
      end;
    end;
    try
      ViewServerDetail.Connection := UDM.Conn;
      ViewServerDetail.Active := False;
      ViewServerDetail.Params[0].Value := UDM.tb_Serietree.FieldByName('idservidor').Value;
      ViewServerDetail.Active := True;
      ViewServerDetail.FetchAll;
    except
      on E: EFDException do
      begin
        udm.sms('No se pueden cosultar los detalles del repositorio de datos. Motivo: ' + e.Message, 1);
        exit;
      end;
    end;
  end;
  pVerticalTitle.Caption := ' Documentos de la subserie: ';
  aNombre := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  MB.Panels[9].Text := aNombre;
  if trim(aNombre) <> '' then
    pVerticalTitle.Caption := pVerticalTitle.Caption + AnsiQuotedStr(aNombre, '"')
  else
    pVerticalTitle.Caption := ' Debe definir al menos una serie documental';
end;

procedure TMAINFORM.dstb_treeDataChange(Sender: TObject; Field: TField);
begin
 { if UDM.tb_VirtVarDataEstruct.RecordCount > 0 then
  begin
    UDM.tb_VirtualVarPrj.Active := False;
    UDM.tb_VirtualVarPrj.FieldDefs.Clear;
    RellenaPrj;
    PVarVirtDataEstruct.Visible:=True;
  end
  else
  begin
    OcultaVGVardef;
    PVarVirtDataEstruct.Visible:=False;
    UDM.tb_VirtualVarPrj.Active := False;
    UDM.tb_VirtualVarPrj.FieldDefs.Clear;
  end;}
end;

procedure TMAINFORM.E1Click(Sender: TObject);
begin
  with TfrmListEspec.Create(NIL) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.E2Click(Sender: TObject);
begin
  if UDM.sms('¿Realmente desea eliminar el contenido del campo actual?', 4) = 6 then
  begin
    UDM.tb_SeriesDatos.Edit;
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).Clear;
    UDM.tb_SeriesDatos.Post;
  end;

end;

procedure TMAINFORM.E3Click(Sender: TObject);
begin
  UDM.sms('Se está tabajando en esta funcionalidad!!!', 2);
end;

procedure TMAINFORM.edtestructuraClick(Sender: TObject);
begin
  nombrecamp := TcxDBTextEdit(Sender).DataBinding.Field.FieldName;
  valueSelectedFill := TcxDBTextEdit(Sender).EditValue;
  valueSelectedFillD := TcxDBTextEdit(Sender).EditingText;
end;

procedure TMAINFORM.eliminarClick(Sender: TObject);
begin
  if (Trim(AnsiLowerCase(UDM.tb_tree.FieldByName('aowner').AsString)) = 'system') then
  begin
    UDM.sms('El elemento actual no se puede eliminar, es parte de la configuración del sistema.', 2);
    Exit;
  end;

  if (UDM.tb_tree.FieldByName('Id').AsInteger < 1) then
  begin
    UDM.sms('Etiqueta del sistema. No se puede eliminar. Debe especificar una estructura válida que pueda modificar.', 3);
    Exit;
  end;
  if UDM.sms('¿Está seguro que desea eliminar el objeto ' + UDM.tb_tree.FieldByName('etiqueta').AsString + ' de la estructura de su empresa?', 4) = 6 then
  begin
    try
      UDM.tb_tree.Delete;
      UDM.tb_EstructDisp.Active := False;
      UDM.tb_EstructDisp.Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo eliminar la estructura actual. Motivo: ' + e.Message, 1);
        Exit;
      end;

    end;
  end;

end;

procedure TMAINFORM.etiquetaClick(Sender: TObject);

  function QuitaCaracter(Temp: string): string;
  begin
    Temp := AnsiReplaceStr(Temp, ' ', '_');
    Temp := AnsiReplaceStr(Temp, Chr(38), '');
    Temp := AnsiReplaceStr(Temp, '-', '_');
    Temp := AnsiReplaceStr(Temp, '*', '_');
    Temp := AnsiReplaceStr(Temp, '+', '_');
    Temp := AnsiReplaceStr(Temp, '(', '_');
    Temp := AnsiReplaceStr(Temp, ')', '_');
    Temp := AnsiReplaceStr(Temp, '/', '_');
    Temp := AnsiReplaceStr(Temp, '\', '_');
    Temp := AnsiReplaceStr(Temp, '|', '_');
    Temp := AnsiReplaceStr(Temp, chr(39), '_');
    Temp := AnsiReplaceStr(Temp, ':', '_');
    Temp := AnsiReplaceStr(Temp, '<', '_');
    Temp := AnsiReplaceStr(Temp, '>', '_');
    Temp := AnsiReplaceStr(Temp, '¿', '_');
    Temp := AnsiReplaceStr(Temp, '?', '_');
    Temp := AnsiReplaceStr(Temp, '¡', '_');
    Temp := AnsiReplaceStr(Temp, '!', '_');
    Temp := AnsiReplaceStr(Temp, '.', '_dot_');
    result := Temp;
  end;

begin
  EstructuraActual := TMenuItem(Sender).Hint;
  //UDM.GetNodoPadreActual;
  UDM.AddBlankNode;
  with TfrmEstructura.Create(nil) do
  try
    Caption := 'Interfaz de gestión de ';
   { tsAddNodo.Caption := QuitaCaracter(TMenuItem(Sender).Caption);
    tsAddNodo.TabVisible := True;
    tseditNode.TabVisible := False;
    pcTree.ActivePage := tsAddNodo;}
    ShowModal;
  finally
    Free;
  end;
  EquipTree;
end;

procedure TMAINFORM.EquipTree;
begin
  UDM.tb_tree.Filtered := False;
end;

procedure TMAINFORM.F1Click(Sender: TObject);
begin
  with TfrmCLFrecuencia.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.F2Click(Sender: TObject);
begin
  with TfrmCLFacultades.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.F3Click(Sender: TObject);
begin
  with TfrmCLFunciones.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.FormActivate(Sender: TObject);
var
  i: integer;

  procedure CleanTMP(Dir: string);
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

begin
  // ELIMINA TODOS LOS DOCUMENTOS PDF DE LOS TEMPORALES DEL  PC...
  UDM.tb_tree.DisableControls;
  udm.tb_tree.Filtered:=False;
  UDM.tb_tree.Filter:='visible=true';
  UDM.tb_tree.Filtered:=True;
  CleanTMP(PathTemp);
  LoadTreeStateNode;
  //pcSeriesDocumentales.ActivePage := tsSeriesDef;
 { for i := pcSeriesDocumentales.PageCount - 1 downto 1 do
    pcSeriesDocumentales.Pages[i].TabVisible := False; }
 { for i := 0 to TvTree.Items.Count - 1 do
    TvTree.Items[i].Expanded := True; }

  PContainer.Visible := False;
  AnItem := TvTree.Items[0];
  if AnItem <> nil then
    NodoActivo := AnItem.Text;
  //DestroyMenu;
  //CreaMenu;
  //PMNodeTree.Items.Count;
  //TvTree.PopupMenu := PMNodeTree;
  MB.Panels[1].Text := UDM.UserName;
  MB.Panels[3].Text := UDM.Rol;
  MB.Panels[5].Text := PathBD;
  UDM.tb_tree.EnableControls;
  {pUserInfo.Caption := '   Usuario: ' + UDM.UserName;
  pRolInfo.Caption := '   Rol: ' + UDM.Rol;
  pPathBD.Caption := '  Base de Datos: ' + PathBD;  }
  if not PContainer.Visible then

  else
  begin
    ViewPanelLateral;
    ViewPanelVertical;
  end;
  cxPCSeriesDatos.ActivePage := tsSubseriesDatos;
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
  pVerticalSSDisp.Height := 366;
  ViewPanelLateral;
  ViewPanelVertical;
end;

procedure TMAINFORM.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if UDM.sms('¿Realmente desea salir del sistema?', 4) = 6 then
  begin
    CanClose := True;
    SaveTreeStateNode;
  end
  else
    CanClose := False;
end;

procedure TMAINFORM.FormCreate(Sender: TObject);
var
  s: string;
begin
  syshelpLeft := btnSystemHelp.Left;
  if FileExists(ExtractFilePath(Application.ExeName) + '\SDTrad.ini') then
  begin
    cxLocalizer1.LoadFromFile(ExtractFilePath(Application.ExeName) + '\SDTrad.ini');
    cxLocalizer1.LanguageIndex := 1; // MUDA DE LINGUAGEM
    cxLocalizer1.Active := True; // ATIVA O COMPONENTE
  end;
  Caption := 'EMSERGO SGD ' + VersionProgram;
  jcpTopografiaArchivo.Left := 253;
  jcpTopografiaArchivo.Top := 42;
  cpInfoPathSubSeries.Left := 230;
  cpInfoPathSubSeries.Top := 174;
  UDM.tb_mp.Active := False;
  UDM.CleanTableTree('tb_mp');
  UDM.tb_mp.Active := True;
  CreateMapProcess;
  //ESTE MODULO DE ACA NO SE PUEDE BORRAR ES, LO QUE ASEGURA LA SEGURIDAD DEL SISTEMA
  //UDM.Rol := 'Visor';
  UDM.Rol := 'administradores';
  UDM.UserName := 'Invitado';
  if (AnsiLowerCase(UDM.Rol) = 'administradores') or (AnsiLowerCase(UDM.Rol) = 'documentador') then
    acceso := 'acceso total'
  else
    acceso := 'solo lectura';
  if Trim(acceso) = '' then
    acceso := 'solo lectura';
  Security.SetModSecurity(Self, acceso);
end;

procedure TMAINFORM.FormResize(Sender: TObject);
begin
 // Position:=poScreenCenter;
end;

procedure TMAINFORM.G1Click(Sender: TObject);
begin
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gestión de serie documental');
end;

procedure TMAINFORM.GViewSeriesDBTableView1carpetaPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  //Agregar el path de un fichero...
  advManagementDirectoryPath.PopupAtCursor;
end;

procedure TMAINFORM.GViewSeriesDBTableView1CellClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);

  function GetSelectedValuesFrmGrid: string;
  var
    intSelectLoop, intRowLoop: Integer;
    oTableView: TcxGridDbTableView;
    strValue: Variant;
    oList: TStringList;
  begin
    Result := '';
  // Kind Of TableView
    if GViewSeries.ActiveView is TcxGridDbTableView then
    begin
      oTableView := GViewSeries.ActiveView as TcxGridDbTableView;
      oList := TStringList.Create();
      try
        for intSelectLoop := 0 to oTableView.Controller.SelectedRowCount - 1 do
        begin
          for intRowLoop := 0 to oTableView.Controller.SelectedRows[intSelectLoop].ValueCount - 1 do
          begin
            strValue := oTableView.Controller.SelectedRows[intSelectLoop].Values[intRowLoop];
          // Value can be Null
            if VarIsNull(strValue) then
            begin
              strValue := '';
            end;
            oList.Add(strValue);
          end;
        end;
        Result := oList.CommaText;
      finally
        oList.Free;
      end;
    end;
  end;

  function GetSelectedValuesFrmGridDisplay: string;
  var
    intSelectLoop, intRowLoop: Integer;
    oTableView: TcxGridDbTableView;
    strValue: Variant;
    oList: TStringList;
  begin
    Result := '';
  // Kind Of TableView
    if GViewSeries.ActiveView is TcxGridDbTableView then
    begin
      oTableView := GViewSeries.ActiveView as TcxGridDbTableView;
      oList := TStringList.Create();
      try
        for intSelectLoop := 0 to oTableView.Controller.SelectedRowCount - 1 do
        begin
          for intRowLoop := 0 to oTableView.Controller.SelectedRows[intSelectLoop].ValueCount - 1 do
          begin
            strValue := oTableView.Controller.SelectedRows[intSelectLoop].DisplayTexts[intRowLoop];
          // Value can be Null
            if VarIsNull(strValue) then
            begin
              strValue := '';
            end;
            oList.Add(strValue);
          end;
        end;
        Result := oList.CommaText;
      finally
        oList.Free;
      end;
    end;
  end;

  function GetV(Value: string; ID: integer): Variant;
  var
    List: TStringList;
  begin
    List := TStringList.Create;
    List.Delimiter := ',';
    List.DelimitedText := Value;
    result := List[ID];
    List.Free;
  end;

var
  TipoDato: string;
  i: integer;
begin
{  valueSelectedFill := getv(GetSelectedValuesFrmGrid, ACellViewInfo.Item.ID);
  valueSelectedFillD := GetV(GetSelectedValuesFrmGridDisplay, ACellViewInfo.Item.ID);
  if valueSelectedFillD = '' then
    valueSelectedFill := Null;
  nombrecamp := TcxGridDBColumn(ACellViewInfo.Item).DataBinding.FieldName; }
end;

procedure TMAINFORM.GViewSeriesDBTableView1observacionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TMAINFORM.I1Click(Sender: TObject);
begin
  if Trim(UDM.tb_Serietree.FieldByName('carpeta').AsString) <> '' then
  begin
    edt1.Text := UDM.tb_Serietree.FieldByName('carpeta').AsString;
    edt1.ReadOnly := True;
    cpInfoPathSubSeries.Visible := True;
    cpInfoPathSubSeries.BringToFront;
    cpInfoPathSubSeries.Left := GroupBox5.Left + Trunc(GroupBox5.Width / 2) - Trunc(cpInfoPathSubSeries.Width / 2);
  end
  else
  begin
    UDM.sms('No se encontró ningún contenido que mostrar. Por favor especifique una ruta válida donde se guardaran las series documentales.', 3);
    Exit;
  end;
end;

procedure TMAINFORM.iv11EditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
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

procedure TMAINFORM.jcpTopografiaArchivoButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
begin
  if Button = capClose then
  begin
    jcpTopografiaArchivo.Visible := False;
    cpInfoPathSubSeries.Visible := False;
  end;
end;

procedure TMAINFORM.JvTransparentButton1Click(Sender: TObject);
begin
  jcpTopografiaArchivo.Visible := False;
  cpInfoPathSubSeries.Visible := False;
end;

procedure TMAINFORM.JvTransparentButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TMAINFORM.JvTransparentButton3Click(Sender: TObject);
begin
  nbMain.Hide;
  with TfrmPropiedadesNodo.Create(nil)do
  try
    with Padres do begin
      Active:=False;
      Params[0].Value:=UDM.tb_tree.FieldByName('id').Value;
      Active:=True;
    end;
    Caption:='Administrando el cuadro de clasificación';
    ShowModal;
  finally
    Free;
    UDM.tb_tree.Filtered:=True;
    nbMain.Show;
  end;
end;

procedure TMAINFORM.L1Click(Sender: TObject);
begin
  with TfrmListFTPServer.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.lcbServidoresPropertiesCloseUp(Sender: TObject);
begin
  {if (UDM.tb_Serietree.State=dsInsert)or (UDM.tb_Serietree.State=dsEdit) then
  try
    UDM.tb_Serietree.Post;
  except
    on E:EFDException do begin
      UDM.sms('No se pudieron aceptar los cambios solicitados. Motivo: '+E.Message, 1);
      UDM.tb_Serietree.Cancel;
      Exit;
    end;
  end; }

end;

procedure TMAINFORM.LoadTreeStateNode;
var
  i:Integer;
  List:TStringList;
begin
  if FileExists(PathTemp+'treestatenode.src') then
  begin
    List:=TStringList.Create;
    List.LoadFromFile(PathTemp+'treestatenode.src');
    for i := 0 to List.Count-1 do
      if List[i]='1' then begin
        ShowMessage(TvTree.Items[i].Text);
        TvTree.Items[i].Expanded:=True;
      end
      else
        TvTree.Items[i].Expanded:=False;
    List.Free;
  end;
end;

procedure TMAINFORM.mGestionarContentFileClick(Sender: TObject);
begin
  if (UDM.tb_Serietree.FieldByName('idservidor').Value = null) or (trim(UDM.tb_Serietree.FieldByName('idservidor').AsString) = '') then
  begin
    UDM.sms('No se encontró una ruta válida para almacenar las subseries.', 2);
    udm.sms('Por favor defina un servidor y una ruta válida para guardar las subseries documentales.', 3);
    Exit;
  end;

  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gestión de serie documental');
end;

procedure TMAINFORM.modificarClick(Sender: TObject);
var
  cad: string;
begin
 { cad := '(tipo is null) or (tipo=1) or (tipo=2)';
  if UDM.tb_tree.FieldByName('tipo').AsInteger = 2 then
  begin
    cad := '(tipo is null) or (tipo=1)';
  end;      }
  with TfrmEstructura.Create(nil) do
  try
    {tsAddNodo.TabVisible := False;
    tseditNode.TabVisible := True;
    pcTree.ActivePage := tseditNode;

    with cmdPadres do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select * from tb_tree where ' + cad + ' order by ID');
      try
        Active := True;
      except
      end;
    end;      }
    Caption := 'Porpiedades del elemento ' + NodoActivo;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.N3Click(Sender: TObject);
begin
  {SystemTree := @TvTree;
  with TfrmAddNode.Create(nil) do
  try
    papa := NodoPadreActual.Id;
    imgpapa := NodoPadreActual.ICONO;
    DBNavigator2.VisibleButtons := [nbInsert, nbPost, nbCancel];
    tsNewStruct.TabVisible := True;
    cxPageControl2.ActivePage := tsNewStruct;
    ShowModal;
  finally
    Free;
  end;}
end;

procedure TMAINFORM.OcultaVGVardef;
var
  i: Integer;
begin
 // UDM.tb_SeriesDatos.DisableControls;
  for i := 1 to 10 do
  begin
    s := 'ivj' + inttostr(i);
    TcxDBEditorRow(FindComponent(s)).Visible := false;
    TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := '';
  end;
 // UDM.tb_SeriesDatos.EnableControls;
end;

procedure TMAINFORM.OcultaVGVardefPrj;
var
  i: Integer;
begin
 // UDM.tb_SeriesDatos.DisableControls;
  for i := 1 to 10 do
  begin
    s := 'iv1' + inttostr(i);
    TcxDBEditorRow(FindComponent(s)).Visible := false;
    TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := '';
  end;
 // UDM.tb_SeriesDatos.EnableControls;
end;

procedure TMAINFORM.P1Click(Sender: TObject);
begin
  with TfrmDoc.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.P2Click(Sender: TObject);
begin
  with TfrmCLprocesos.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.R1Click(Sender: TObject);
begin
  with TfrmRepActArch.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.Rellena;
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
  while not UDM.tb_SerieDatosVar.Eof do
  begin
    s := 'iv' + inttostr(i);
    if UDM.cl_Variables.Locate('idvar', UDM.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
    begin
      TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := UDM.cl_Variables.fieldbyname('NomVariable').asstring;
      TcxDBEditorRow(FindComponent(s)).Properties.Caption := UDM.cl_Variables.fieldbyname('Etiqueta').AsString;
      TcxDBEditorRow(FindComponent(s)).Index := i + 11;
      TcxDBEditorRow(FindComponent(s)).Visible := true;
    end;
    i := i + 1;
    UDM.tb_SerieDatosVar.Next;
  end;
 //------------------------------------------------------------------------------
  UDM.tb_SerieDatosVar.First;
  while not UDM.tb_SerieDatosVar.eof do
  begin
    if UDM.cl_Variables.Locate('idvar', UDM.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
    begin
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
    UDM.tb_SerieDatosVar.next;
  end;
  UDM.tb_VirtualVar.CreateDataSet;
  if not UDM.tb_VirtualVar.active then
    UDM.tb_VirtualVar.Active := true;
 //**************** Adicionar los valores ***************************************
  UDM.tb_SerieDatosVar.First;
  while not UDM.tb_SerieDatosVar.eof do
  begin
    UDM.tb_VirtualVar.edit;
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
      UDM.tb_VirtualVar.FieldByName(UDM.cl_Variables.fieldbyname('NomVariable').asstring).Value := UDM.tb_SerieDatosVar.fieldbyname(vs).Value;
      UDM.tb_VirtualVar.post;
    end;
    UDM.tb_SerieDatosVar.next;
  end;
 // UDM.tb_SeriesDatos.EnableControls;
//****************************************************************************
end;

procedure TMAINFORM.RellenaPrj;
var
  i: integer;
  Qcl_Varsubserie: TFDQuery;
  vs: string;
  vtipo: TFieldType;
  LEN: INTEGER;
  s: string;

  procedure abrirTabla(DS: TDataset);
  begin
    if not DS.active then
      DS.active := true;
  end;

begin
  //tb_SeriesDatos.DisableControls;
  //salvo := false;
 //********************Abrit las tablas*****************************************
  AbrirTabla(UDM.tb_tree);
  AbrirTabla(UDM.cl_VarProject);
  AbrirTabla(UDM.tb_VirtVarDataEstruct);
  //AbrirTabla(UDM.tb_VirtualVarPrj);
  Qcl_Varsubserie := TFDQuery.create(self);
  with Qcl_Varsubserie do
  begin
    Active := False;
    Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('SELECT * FROM cl_VarProject WHERE cl_VarProject.IdEstructura=' + QuotedStr(UDM.tb_tree.fieldbyname('idestructura').asstring) + ' AND cl_VarProject.id=' + UDM.tb_tree.FieldByName('id').AsString);
    SQL.Add(' ORDER BY cl_VarProject.idestructura, cl_VarProject.id, cl_VarProject.orden;');
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
  if UDM.tb_VirtVarDataEstruct.recordcount = 0 then
  try
    Qcl_Varsubserie.First;
    while not Qcl_Varsubserie.eof do
    begin
      UDM.tb_VirtVarDataEstruct.AppendRecord([UDM.tb_tree.fieldbyname('idestructura').Value, UDM.tb_tree.fieldbyname('id').Value, Qcl_Varsubserie.fieldbyname('orden').Value, Qcl_Varsubserie.fieldbyname('idvar').Value]);
      Qcl_Varsubserie.next;
    end;
    UDM.tb_SerieDatosVar.Active := false;
    UDM.tb_SerieDatosVar.Active := true;
  finally
    Qcl_Varsubserie.Free;
  end;
  varUltimoQuery := '';
  OcultaVGVardef;
  UDM.tb_VirtVarDataEstruct.first;
  i := 1;
  //cxDBVerticalGrid1.DataController.DataSource := UDM.Dtb_VirtualVar;
  while not UDM.tb_VirtVarDataEstruct.Eof do
  begin
    s := 'iv' + inttostr(i);
    if UDM.cl_Variables.Locate('idvar', UDM.tb_VirtVarDataEstruct.FieldByName('idvar').Value, []) then
    begin
      TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := UDM.cl_Variables.fieldbyname('NomVariable').asstring;
      TcxDBEditorRow(FindComponent(s)).Properties.Caption := UDM.cl_Variables.fieldbyname('Etiqueta').AsString;
      TcxDBEditorRow(FindComponent(s)).Index := i + 11;
      TcxDBEditorRow(FindComponent(s)).Visible := true;
    end;
    i := i + 1;
    UDM.tb_VirtVarDataEstruct.Next;
  end;
 //------------------------------------------------------------------------------
  UDM.tb_VirtVarDataEstruct.First;
  while not UDM.tb_VirtVarDataEstruct.eof do
  begin
    if UDM.cl_Variables.Locate('idvar', UDM.tb_VirtVarDataEstruct.FieldByName('idvar').Value, []) then
    begin
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
      UDM.tb_VirtualVarPrj.FieldDefs.Add(UDM.cl_Variables.fieldbyname('NomVariable').asstring, vtipo, LEN);
    end;
    UDM.tb_VirtVarDataEstruct.next;
  end;
  UDM.tb_VirtualVarPrj.CreateDataSet;
  if not UDM.tb_VirtualVarPrj.active then
    UDM.tb_VirtualVarPrj.Active := true;
 //**************** Adicionar los valores ***************************************
  UDM.tb_VirtVarDataEstruct.First;
  while not UDM.tb_VirtVarDataEstruct.eof do
  begin
    UDM.tb_VirtualVarPrj.edit;
    if UDM.cl_Variables.Locate('idvar', UDM.tb_VirtVarDataEstruct.FieldByName('idvar').Value, []) then
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
      UDM.tb_VirtualVarPrj.FieldByName(UDM.cl_Variables.fieldbyname('NomVariable').asstring).Value := UDM.tb_VirtVarDataEstruct.fieldbyname(vs).Value;
      UDM.tb_VirtualVarPrj.post;
    end;
    UDM.tb_VirtVarDataEstruct.next;
  end;
 // tb_SeriesDatos.EnableControls;
//****************************************************************************
end;

procedure TMAINFORM.RemoveMDSeriesSubSeriesDMDR;
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

procedure TMAINFORM.S1Click(Sender: TObject);
begin
  with TfrmCLSeries.Create(nil) do
  try
    MDSeriesSubSeriesDMDR;
    ShowModal;
  finally
    Free;
    RemoveMDSeriesSubSeriesDMDR
  end;
end;

procedure TMAINFORM.S2Click(Sender: TObject);
begin
  with TfrmCLSoporte.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.SaveTreeStateNode;
var
  i:integer;
  List:TStringList;
begin
  List:=TStringList.Create;
  for I := 0 to TvTree.Items.Count-1 do
    if TvTree.Items[i].Expanded then begin
      TvTree.Items[i].Index;
      //List.Add( '1')
    end
    else
      List.Add('0');
  List.SaveToFile(PathTemp+'treestatenode.src');
  List.Free;
end;

procedure TMAINFORM.SpeedButton5Click(Sender: TObject);
begin
  ExcelExport(nil, cxgrid2);
end;

procedure TMAINFORM.T1Click(Sender: TObject);
begin
  with TfrmCLAcceso.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.T2Click(Sender: TObject);
begin
  with TfrmCLTipoDoc.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.T3Click(Sender: TObject);
begin
  with TfrmTipoEstructura.Create(nil) do
  try
    ShowModal;
  finally
    Free;
    //DestroyMenu;
    //CreaMenu;
  end;
end;

procedure TMAINFORM.T4Click(Sender: TObject);
begin
  with TfrmTipoObjeto.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.ToolButton13Click(Sender: TObject);
begin
 // UDM.ManagementHLP(pCaptionSubSeries.Caption, pCaptionSubSeries.Handle);
end;

procedure TMAINFORM.ToolButton18Click(Sender: TObject);
begin
//  UDM.ManagementHLP(PCaptionSeries.Caption, PCaptionSeries.Handle);
end;

procedure TMAINFORM.ToolButton1Click(Sender: TObject);
begin
  UDM.Tb_SeriesDispo.Active := False;
  UDM.Tb_SeriesDispo.Params[0].Value := UDM.tb_tree.FieldByName('id').Value;
  UDM.Tb_SeriesDispo.Active := True;
  UDM.Tb_SeriesDispo.FetchAll;
  with TfrmSeriesDisp.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.ToolButton2Click(Sender: TObject);
var
  i: integer;
  si: boolean;
  SCampo: string;
begin
  salvo2 := true;
  if (UDM.tb_VirtualVar.State <> dsedit) and (UDM.tb_VirtualVar.State <> dsinsert) then
    UDM.tb_VirtualVar.edit;
  for i := CantIndex to UDM.tb_VirtualVar.fieldcount - 1 do
  begin
    s := UDM.tb_VirtualVar.Fields[i].FieldName;
    if (UDM.tb_VirtualVar.Fields[i].Value = Null) then
      salvo2 := false;
  end;
  if not salvo2 then
  begin
    if UDM.sms('Existen variables que no han tomado valor. ¿Las salvará de todas formas?', 4) = 6 then
      salvo2 := true;
  end;
  if salvo2 then
  begin
    UDM.tb_VirtVarDataEstruct.First;
    for i := 0 to UDM.tb_Virtualvar.fieldcount - 1 do
    begin
      UDM.tb_VirtVarDataEstruct.Edit;
      if UDM.cl_variables.locate('NomVariable', UDM.tb_Virtualvar.fields[i].FieldName, []) then
        s := uppercase(UDM.cl_variables.fieldbyname('tipo').asstring);
      if s = 'ENTERO' then
        SCampo := 'VarInteger'
      else if s = 'REAL' then
        SCampo := 'VarDouble'
      else if s = 'FECHA' then
        SCampo := 'VarDate'
      else
        SCampo := 'VarString255';
      UDM.tb_VirtVarDataEstruct.fieldbyname(SCampo).Value := UDM.tb_VirtualVar.fields[i].Value;
      UDM.tb_VirtVarDataEstruct.Post;
      UDM.tb_VirtVarDataEstruct.next;
    end;
   // close;
   UDM.sms('Los cambios se realizaron satisfactoriamente.', 3);
  end;
end;

procedure TMAINFORM.ToolButton3Click(Sender: TObject);
var
  ss, subquery: string;
begin
  if trim(nombrecamp) = '' then
  begin
    UDM.sms('Debe seleccionar una columna válida haciendo click en su contenido.', 3);
    Exit;
  end;
  if pos('ORDER BY', UDM.tb_Serietree.SQL.Text) > 0 then
  begin
    UDM.tb_Serietree.Active := False;
    ss := UDM.tb_Serietree.SQL.Text;
    subquery := copy(ss, pos('ORDER BY', UDM.tb_Serietree.SQL.Text), 9999);
    ss := AnsiReplaceStr(ss, subquery, ' ORDER BY ' + nombrecamp + ' DESC ');
    UDM.tb_Serietree.SQL.Text := ss;
    UDM.tb_Serietree.Active := True;
  end
  else
  begin
    UDM.tb_Serietree.Active := False;
    UDM.tb_Serietree.SQL.Text := UDM.tb_Serietree.SQL.Text + ' ORDER BY ' + nombrecamp + ' DESC';
    UDM.tb_Serietree.Active := True;
  end;
end;

procedure TMAINFORM.ToolButton5Click(Sender: TObject);
begin
  if UDM.tb_SeriesDatos.RecordCount > 0 then
    VarVirtual
  else
  begin
    UDM.sms('No ha introducido ninguna serie documental el día de hoy.', 3);
    Exit;
  end;
end;

procedure TMAINFORM.ToolButton6Click(Sender: TObject);
begin
  if UDM.tb_Serietree.RecordCount = 0 then
  begin
    UDM.sms('Debe identificar al menos una serie documental válida.', 3);
    if UDM.sms('¿Desea consultar el listado de Series documentales identificadas?', 4) = 6 then
      ToolButton1Click(Sender);
    Exit;
  end;
  with TfrmICSeriesDocumentales.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.ToolButton8Click(Sender: TObject);
begin
  UDM.Tb_SeriesDispo.Active := False;
  UDM.Tb_SeriesDispo.Params[0].Value := UDM.tb_tree.FieldByName('id').Value;
  UDM.Tb_SeriesDispo.Active := True;
  UDM.Tb_SeriesDispo.FetchAll;
  with TfrmSeriesDisp.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.ToolButton9Click(Sender: TObject);
var
  i: integer;
  si: boolean;
  SCampo: string;
begin
  salvo := true;
  if (UDM.tb_VirtualVar.State <> dsedit) and (UDM.tb_VirtualVar.State <> dsinsert) then
    UDM.tb_VirtualVar.edit;
  for i := CantIndex to UDM.tb_VirtualVar.fieldcount - 1 do
  begin
    s := UDM.tb_VirtualVar.Fields[i].FieldName;
    if (UDM.tb_VirtualVar.Fields[i].Value = Null) then
      salvo := false;
  end;
  if not salvo then
  begin
    if UDM.sms('Existen variables que no han tomado valor. ¿Las salvará de todas formas?', 4) = 6 then
      salvo := true;
  end;
  if salvo then
  begin
    UDM.tb_SerieDatosVar.First;
    for i := 0 to UDM.tb_Virtualvar.fieldcount - 1 do
    begin
      UDM.tb_SerieDatosVar.Edit;
      if UDM.cl_variables.locate('NomVariable', UDM.tb_Virtualvar.fields[i].FieldName, []) then
        s := uppercase(UDM.cl_variables.fieldbyname('tipo').asstring);
      if s = 'ENTERO' then
        SCampo := 'VarInteger'
      else if s = 'REAL' then
        SCampo := 'VarDouble'
      else if s = 'FECHA' then
        SCampo := 'VarDate'
      else
        SCampo := 'VarString255';
      UDM.tb_SerieDatosVar.fieldbyname(SCampo).Value := UDM.tb_VirtualVar.fields[i].Value;
      UDM.tb_SerieDatosVar.Post;
      UDM.tb_SerieDatosVar.next;
    end;
   // close;
  end;
end;

end.

