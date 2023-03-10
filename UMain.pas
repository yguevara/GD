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
  Winapi.ShellAPI, System.AnsiStrings;

type
  TNODOSD = record
    Id: integer;
    Etiqueta: string;
    Padre: integer;
    ICONO: integer;
    Tipo: integer; // Etiqueta, Estructura, Cargo
  end;

  TMAINFORM = class(TForm)
    StatusBar1: TStatusBar;
    pHeaderApp: TPanel;
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
    JvTransparentButton17: TJvTransparentButton;
    JvTransparentButton21: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    JvTransparentButton20: TJvTransparentButton;
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
    PMNodeTree: TAdvPopupMenu;
    agregar: TMenuItem;
    eliminar: TMenuItem;
    modificar: TMenuItem;
    N4: TMenuItem;
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
    Etiqueta: TMenuItem;
    Estructura: TMenuItem;
    Cargo: TMenuItem;
    N1: TMenuItem;
    PContainer: TPanel;
    V1: TMenuItem;
    PTituloSeries: TPanel;
    A1: TMenuItem;
    E1: TMenuItem;
    pcSeriesDocumentales: TcxPageControl;
    tsSeriesDef: TcxTabSheet;
    tsInputSeriesData: TcxTabSheet;
    pContainerDefSeries: TPanel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1Id: TcxGridDBColumn;
    cxGrid1DBTableView1codsubs: TcxGridDBColumn;
    cxGrid1DBTableView1Ubicacion: TcxGridDBColumn;
    cxGrid1DBTableView1deposito: TcxGridDBColumn;
    cxGrid1DBTableView1gaveta: TcxGridDBColumn;
    cxGrid1DBTableView1especialista: TcxGridDBColumn;
    cxGrid1DBTableView1correo: TcxGridDBColumn;
    cxGrid1DBTableView1usuario: TcxGridDBColumn;
    cxGrid1DBTableView1frecuencia: TcxGridDBColumn;
    cxGrid1DBTableView1tiempo: TcxGridDBColumn;
    cxGrid1DBTableView1observacion: TcxGridDBColumn;
    cxGrid1DBTableView1servidor: TcxGridDBColumn;
    cxGrid1DBTableView1carpeta: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    Panel1: TPanel;
    pGeneralData: TPanel;
    cxPageControl2: TcxPageControl;
    cxTabSheet1: TcxTabSheet;
    cxGrid2: TcxGrid;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2DBTableView1Idservidor: TcxGridDBColumn;
    cxGrid2DBTableView1deposito: TcxGridDBColumn;
    cxGrid2DBTableView1gaveta: TcxGridDBColumn;
    cxGrid2DBTableView1fichero: TcxGridDBColumn;
    cxGrid2DBTableView1observaciones: TcxGridDBColumn;
    cxGrid2Level1: TcxGridLevel;
    cxGroupBox1: TcxGroupBox;
    lblFechaOper: TLabel;
    Label1: TLabel;
    edtFechOper: TcxDBDateEdit;
    edtVersion: TcxDBTextEdit;
    Panel2: TPanel;
    cxDBNavigator1: TcxDBNavigator;
    dbnSeriesDatos: TDBNavigator;
    ToolBar3: TToolBar;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    PMManagementFile: TAdvPopupMenu;
    V2: TMenuItem;
    N2: TMenuItem;
    G1: TMenuItem;
    E2: TMenuItem;
    Proyecto1: TMenuItem;
    ToolBar2: TToolBar;
    ToolButton7: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton18: TToolButton;
    ToolButton17: TToolButton;
    PCaptionSeries: TPanel;
    pCaptionSubSeries: TPanel;
    Label2: TLabel;
    edtCodigo: TcxDBTextEdit;
    Label3: TLabel;
    edtSuport: TcxDBTextEdit;
    TvTree: TdxDBTreeView;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btn2Click(Sender: TObject);
    procedure Acercade1Click(Sender: TObject);
    procedure ControldeVersiones1Click(Sender: TObject);
    procedure btnautenticaClick(Sender: TObject);
    procedure btnusercontrolClick(Sender: TObject);
    procedure P1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TvTreeDblClick(Sender: TObject);
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
    procedure btnCloseTABDatosClick(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure dbnSeriesDatosClick(Sender: TObject; Button: TNavigateBtn);
    procedure ToolButton5Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure G1Click(Sender: TObject);
    procedure V2Click(Sender: TObject);
    procedure E2Click(Sender: TObject);
    procedure Ayuda1Click(Sender: TObject);
    procedure ToolButton13Click(Sender: TObject);
    procedure ToolButton18Click(Sender: TObject);
  private
    procedure CargoState(aState: Boolean);
    procedure MDSeriesSubSeriesDMDR;
    procedure RemoveMDSeriesSubSeriesDMDR;
    procedure PMConfigMainNode(aIdNodo: integer);
    { Private declarations }
  public
    { Public declarations }
    procedure EquipTree;
    procedure DesArmTree;
    procedure CreateMapProcess;
  end;

var
  MAINFORM: TMAINFORM;
  AnItem: TTreeNode; // TcxTreeListNode;
  NewId, ParentID: integer;

const
  CEstructura: array[1..4] of string = ('Etiquetas', 'Estructuras', 'Cargos', 'Proyectos');

implementation

{$R *.dfm}

uses
  UHistory, UAbout, UAutentica, UCapaDatos, UUserGest, UDocManagement,
  UCLSeriesDocumentales, UCLDestino, UCLAcceso, UCLSoporte, UCLFrecuencia,
  UCLTipoDoc, UNodeAsist, UCLFtpServer, UCLProcesos, UCLRepActArchiv,
  UGestEstruct, UCategoria_Ocupa, UCL_Cargo, UCLVariables, UMangementArch,
  USeriesDisp, UCL_Especialistas, UEntrada, UManagementFileSeries;

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

procedure TMAINFORM.btnautenticaClick(Sender: TObject);
var
  Rolactivo: string;
begin
  Rolactivo := autenticar(UDM.Connuser);
end;

procedure TMAINFORM.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TMAINFORM.btnCloseTABDatosClick(Sender: TObject);
begin
  tsInputSeriesData.TabVisible := False;
  tsSeriesDef.TabVisible := True;
  tsSeriesDef.Visible := True;
  pContainerDefSeries.Visible := True;
  pcSeriesDocumentales.ActivePage := tsSeriesDef;
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

procedure TMAINFORM.C1Click(Sender: TObject);
begin
  with TfrmCLCargo.Create(nil) do
  try
      { CargoState(False);
        UDM.cl_funcionesgen.MasterSource := UDM.dscl_cargo;
        UDM.cl_funcionesgen.MasterFields := 'Idcargo';
        UDM.cl_funcionesgen.IndexFieldNames := 'IdCargo;idfunciones';
        UDM.cl_facultadesgen.MasterSource := UDM.dscl_cargo;
        UDM.cl_facultadesgen.MasterFields := 'Idcargo';
        UDM.cl_facultadesgen.IndexFieldNames := 'IdCargo;idfacultades';
        CargoState(True); }
    ShowModal;
  finally
    Free;
      { CargoState(False);
        UDM.cl_funcionesgen.MasterSource := nil;
        UDM.cl_funcionesgen.MasterFields := '';
        UDM.cl_funcionesgen.IndexFieldNames := '';
        UDM.cl_facultadesgen.MasterSource := nil;
        UDM.cl_facultadesgen.MasterFields := '';
        UDM.cl_facultadesgen.IndexFieldNames := '';
        CargoState(True); }
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

procedure TMAINFORM.cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  PMManagementFile.PopupAtCursor;
end;

procedure TMAINFORM.PMConfigMainNode(aIdNodo: integer);
begin
  agregar.Visible := True;
  eliminar.Visible := True;
  modificar.Visible := True;
  if aIdNodo = 0 then
  begin
    agregar.Visible := True;
    eliminar.Visible := False;
    modificar.Visible := False;
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

procedure TMAINFORM.TvTree1Change(Sender: TObject; Node: TTreeNode);
begin
  PMConfigMainNode(UDM.tb_tree.FieldByName('id').AsInteger);
  Etiqueta.Enabled := True;
  Estructura.Enabled := True;
  Cargo.Enabled := True;
  PTituloSeries.Caption := 'Series Documentales (' + Node.Text + ')';
  { case UDM.tb_tree.FieldByName('tipo').AsInteger of
    1:
    begin
    etiqueta.Enabled := True;
    Estructura.Enabled := True;
    Cargo.Enabled := True;
    end;
    2:
    begin
    etiqueta.Enabled := True;
    Estructura.Enabled := True;
    Cargo.Enabled := True;
    end;
    3:
    begin
    agregar.Visible := False;
    end;
    end; }
  if UDM.tb_tree.State = dsInsert then
    TvTree.SelectedIndex := imagenactual
  else
    TvTree.SelectedIndex := UDM.tb_tree.FieldByName('icono').AsInteger;
end;

procedure TMAINFORM.TvTreeDblClick(Sender: TObject);

  procedure ConfigFuncionEspecial(aDS: TDataSource; NombreCampo: string);
  begin

  end;

  procedure ConfigComponentFuncionesGenerales(aDS: TDataSource; NombreCampo: string);
  begin

  end;

  procedure ConfigFuncionesGenerales(aDS: TDataSource; aNombreCampo: string);
  // (UDM.dstb_empresa, 'fungenerales')
  begin
    ConfigComponentFuncionesGenerales(aDS, aNombreCampo);
    if Trim(aDS.DataSet.FieldByName(aNombreCampo).AsString) <> '' then
      with FDQuery1 do
      begin
        Active := False;
        Connection := UDM.Conn;
        SQL.Clear;
        SQL.Add('select funciones from cl_funcionesgen where cl_funcionesgen.id=' + aDS.DataSet.FieldByName(aNombreCampo).AsString);
        try
          Active := True;
          // reDescripCion.Text := VarToStr(Fields[0].Value);
        except
        end;
      end;
  end;

  function busca(NombreTabla, KeyDEF, KeyVAL: string): Variant;
  var
    ListDEF, ListVAL: TStringList;
    i: integer;
    tmp: Variant;
    k: string;
    Qt: TFDQuery;
    cadwhere: string;
    cadKeyDEFUEB, cadKeyDEFDEP: string;
  begin
    { ListDEF := TStringList.Create;
      ListDEF.Delimiter := ';';
      ListDEF.DelimitedText := KeyDEF;
      ListVAL := TStringList.Create;
      ListVAL.Delimiter := ',';
      ListVAL.DelimitedText := KeyVAL;
      tmp := VarArrayCreate([0, ListVAL.Count], varVariant);
      if NombreTabla = 'tb_empresa' then
      begin
      if UDM.tb_empresa.Locate(ListDEF[0], ListVAL[0], []) then
      begin
      ConfigFuncionesGenerales(UDM.dstb_empresa, 'fungenerales');
      ConfigFuncionEspecial(UDM.dstb_empresa, 'funespemp');
      end;
      end
      else if NombreTabla = 'tb_ueb' then
      begin
      if UDM.tb_empresa.Locate(ListDEF[0], ListVAL[0], []) then
      begin
      tmp := VarArrayCreate([0, ListVAL.Count], varVariant);
      for i := 0 to ListVAL.Count - 1 do
      tmp[i] := ListVAL[i];
      if UDM.tb_ueb.Locate(KeyDEF, tmp, []) then
      begin
      //funciones generales ueb...
      ConfigFuncionesGenerales(UDM.dstb_ueb, 'fungenerales');
      //funciones especificas ueb
      ConfigFuncionEspecial(UDM.dstb_ueb, 'funespueb');
      end;
      end;
      end
      else if NombreTabla = 'tb_departamento' then
      begin
      if UDM.tb_empresa.Locate(ListDEF[0], ListVAL[0], []) then
      begin
      tmp := VarArrayCreate([0, ListVAL.Count - 2], varVariant);
      for i := 0 to ListVAL.Count - 2 do
      begin
      tmp[i] := trim(ListVAL[i]);
      if i = 0 then
      cadKeyDEFUEB := ListDEF[i]
      else
      cadKeyDEFUEB := cadKeyDEFUEB + ';' + ListDEF[i];
      end;
      UDM.tb_ueb.First;
      if UDM.tb_ueb.Locate(cadKeyDEFUEB, tmp, []) then
      begin
      tmp := VarArrayCreate([0, ListVAL.Count - 1], varVariant);
      for i := 0 to ListVAL.Count - 1 do
      begin
      tmp[i] := ListVAL[i];
      end;
      if UDM.tb_departamento.Locate(KeyDEF, tmp, []) then
      begin
      //Funciones generales departamento...
      ConfigFuncionesGenerales(UDM.dstb_departamento, 'fungenerales');
      //funciones especificas ueb
      ConfigFuncionEspecial(UDM.dstb_departamento, 'funespdepto');
      end;
      end;
      end;
      end
      else if NombreTabla = 'tb_cargo' then
      begin
      if UDM.tb_empresa.Locate(ListDEF[0], ListVAL[0], []) then
      begin
      tmp := VarArrayCreate([0, ListVAL.Count - 3], varVariant);
      for i := 0 to ListVAL.Count - 3 do
      begin
      tmp[i] := ListVAL[i];
      if i = 0 then
      cadKeyDEFUEB := ListDEF[i]
      else
      cadKeyDEFUEB := cadKeyDEFUEB + ';' + ListDEF[i];
      end;
      if UDM.tb_ueb.Locate(cadKeyDEFUEB, tmp, []) then
      begin
      tmp := VarArrayCreate([0, ListVAL.Count - 2], varVariant);
      for i := 0 to ListVAL.Count - 2 do
      begin
      tmp[i] := ListVAL[i];
      if i = 0 then
      cadKeyDEFDEP := ListDEF[i]
      else
      cadKeyDEFDEP := cadKeyDEFDEP + ';' + ListDEF[i];
      end;
      if UDM.tb_departamento.Locate(cadKeyDEFDEP, tmp, []) then
      begin
      tmp := VarArrayCreate([0, ListVAL.Count], varVariant);
      for i := 0 to ListVAL.Count - 1 do
      tmp[i] := ListVAL[i];
      if UDM.tb_cargo.Locate(KeyDEF, tmp, []) then
      begin
      //funciones generales del cargo...
      ConfigFuncionesGenerales(UDM.dstb_cargo, 'fungenerales');
      //funciones especificas ueb
      ConfigFuncionEspecial(UDM.dstb_cargo, 'funciones');
      end;
      end;
      end;
      end;
      end
      else if NombreTabla = 'tb_orgnoaux' then
      begin
      if UDM.tb_empresa.Locate(ListDEF[0], ListVAL[0], []) then
      begin
      tmp := VarArrayCreate([0, ListVAL.Count], varVariant);
      for i := 0 to ListVAL.Count - 1 do
      tmp[i] := ListVAL[i];
      if UDM.tb_orgnoaux.Locate(KeyDEF, tmp, []) then
      begin
      ConfigFuncionesGenerales(UDM.dstb_orgnoaux, 'fungenerales');
      end;
      end;
      end
      else if NombreTabla = 'tb_organoauxasisten' then
      begin
      if UDM.tb_empresa.Locate(ListDEF[0], ListVAL[0], []) then
      begin
      tmp := VarArrayCreate([0, ListVAL.Count - 1], varVariant);
      for i := 0 to ListVAL.Count - 2 do
      tmp[i] := ListVAL[i];
      if UDM.tb_orgnoaux.Locate(KeyDEF, tmp, []) then
      begin
      tmp := VarArrayCreate([0, ListVAL.Count], varVariant);
      for i := 0 to ListVAL.Count - 1 do
      tmp[i] := ListVAL[i];
      UDM.tb_organoauxasisten.Locate(KeyDEF, tmp, []);
      Panel2.Visible := False;
      end;
      end;
      Qt := UDM.tb_organoauxasisten;
      end;
      ListDEF.Free;
      ListVAL.Free; }
  end;

begin
  { Panel2.Visible := True;
    busca(UDM.tb_tree.FieldByName('nombreentidad').AsString, UDM.tb_tree.FieldByName('keydef').AsString, UDM.tb_tree.FieldByName('keyvalue').AsString); }
end;

procedure TMAINFORM.TvTree1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
begin
  AnItem := TvTree.GetNodeAt(X, Y);
  ParentID := UDM.GetIDParentTreeNode;
  // PContainer.Visible:=False;
  if AnItem <> nil then
  begin
    if Button = mbRight then
    begin
      ParentID := AnItem.Index;
    end
    else
    begin
      if NodoActivo <> AnItem.Text then
      begin
        NodoActivo := AnItem.Text;
        pcSeriesDocumentales.ActivePage := tsSeriesDef;
      end;

      if UDM.tb_tree.FieldByName('tipo').AsInteger <> 1 then
      begin
        PContainer.Visible := True;
      end
      else
        PContainer.Visible := False;

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
        MessageDlg('No se pudo abrir el Informe especificado. Motivo:' + E.Message, mtError, [mbOK], 0);
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

procedure TMAINFORM.D1Click(Sender: TObject);
begin
  with TfrmCLDestino.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.dbnSeriesDatosClick(Sender: TObject; Button: TNavigateBtn);
begin
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
end;

procedure TMAINFORM.DesArmTree;
begin
  UDM.tb_tree.Filtered := False;
  UDM.tb_tree.Filter := 'ID<>0';
  UDM.tb_tree.Filtered := True;
  TvTree.DataSource := nil;
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
  if MessageDlg('?Realmente desea eliminar el contenido del campo actual?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    UDM.tb_SeriesDatos.Edit;
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).Clear;
    UDM.tb_SeriesDatos.Post;
  end;

end;

procedure TMAINFORM.eliminarClick(Sender: TObject);
begin
  if (UDM.tb_tree.FieldByName('Id').AsInteger < 1) then
  begin
    MessageDlg('Etiqueta del sistema. No se puede eliminar. Debe especificar una estructura v?lida que pueda modificar.', mtInformation, [mbOK], 0);
    Exit;
  end;
  if MessageDlg('?Est? seguro que desea eliminar el objeto ' + UDM.tb_tree.FieldByName('etiqueta').AsString + ' de la estructura de su empresa?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    UDM.tb_tree.Delete;
  end;

end;

procedure TMAINFORM.etiquetaClick(Sender: TObject);

  function QuitaCaracter(Temp: string): string;
  begin
    Temp := AnsiReplaceStr(Temp, ' ', '_');
    Temp := AnsiReplaceStr(Temp, Chr(38), '');
  {Temp := AnsiReplaceStr(Temp, '?', 'a');
  Temp := AnsiReplaceStr(Temp, '?', 'e');
  Temp := AnsiReplaceStr(Temp, '?', 'i');
  Temp := AnsiReplaceStr(Temp, '?', 'o');
  Temp := AnsiReplaceStr(Temp, '?', 'u');
  Temp := AnsiReplaceStr(Temp, '?', 'A');
  Temp := AnsiReplaceStr(Temp, '?', 'E');
  Temp := AnsiReplaceStr(Temp, '?', 'I');
  Temp := AnsiReplaceStr(Temp, '?', 'O');
  Temp := AnsiReplaceStr(Temp, '?', 'U'); }
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
    Temp := AnsiReplaceStr(Temp, '?', '_');
    Temp := AnsiReplaceStr(Temp, '?', '_');
    Temp := AnsiReplaceStr(Temp, '?', '_');
    Temp := AnsiReplaceStr(Temp, '!', '_');
    Temp := AnsiReplaceStr(Temp, '.', '_dot_');
    result := Temp;
  end;

begin
  EstructuraActual := TMenuItem(Sender).Tag;
  imagenactual := UDM.Conn.ExecSQLScalar('select icon from cl_tipoestructura where Idestructura=' + IntToStr(EstructuraActual));
  UDM.GetNodoPadreActual;
  UDM.AddBlankNode;
  with TfrmEstructura.Create(nil) do
  try
    Caption := 'Interfaz de gesti?n de ' + CEstructura[TMenuItem(Sender).Tag];
    tsAddNodo.Caption := QuitaCaracter(TMenuItem(Sender).Caption);
    tsAddNodo.TabVisible := True;
    tseditNode.TabVisible := False;
    pcTree.ActivePage := tsAddNodo;
    ShowModal;
  finally
    Free;
  end;
  EquipTree;
end;

procedure TMAINFORM.EquipTree;
begin
  UDM.tb_tree.Filtered := False;
  { TvTree.DataController.DataSource:=UDM.dstb_tree;
    TvTree.DataController.ImageIndexField:='icono';
    TvTree.DataController.KeyField:='id';
    TvTree.DataController.ParentField:='padre';
    TvTree.DataControll  er.StateIndexField:='icono'; }
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
          // Memo1.Lines.Add( Dir +'\'+FileSearch.Name );
        end;
      until FindNext(FileSearch) <> 0;
    FindClose(FileSearch);
  end;

begin
  // ELIMINA TODOS LOS DOCUMENTOS PDF DE LOS TEMPORALES DEL  PC...
  CleanTMP(PathTemp);
  pcSeriesDocumentales.ActivePage := tsSeriesDef;
  for i := pcSeriesDocumentales.PageCount - 1 downto 1 do
    pcSeriesDocumentales.Pages[i].TabVisible := False;
  for i := 0 to TvTree.Items.Count - 1 do
    TvTree.Items[i].Expanded := True;
  PContainer.Visible := False;
  AnItem := TvTree.Items[0];
  if AnItem <> nil then
    NodoActivo := AnItem.Text;
end;

procedure TMAINFORM.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if MessageDlg('?Realmente desea salir del sistema?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    CanClose := True
  end
  else
    CanClose := False;
end;

procedure TMAINFORM.FormCreate(Sender: TObject);
begin
  if FileExists(ExtractFilePath(Application.ExeName) + '\SDTrad.ini') then
  begin
    cxLocalizer1.LoadFromFile(ExtractFilePath(Application.ExeName) + '\SDTrad.ini');
    cxLocalizer1.LanguageIndex := 1; // MUDA DE LINGUAGEM
    cxLocalizer1.Active := True; // ATIVA O COMPONENTE
  end;
  UDM.tb_mp.Active := False;
  UDM.CleanTableTree('tb_mp');
  UDM.tb_mp.Active := True;
  CreateMapProcess;
  // PContainer.Visible := False;
  { UDM.CreaTree;
    UDM.tb_ueb.Filtered := False;
    cxDBTreeList2.DataController.DataSource := UDM.dstb_tree; }
end;

procedure TMAINFORM.G1Click(Sender: TObject);
begin
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gesti?n de serie documental');
end;

procedure TMAINFORM.JvTransparentButton1Click(Sender: TObject);
begin
  //TvTree.SaveToFile('C:\tree.txt');
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

procedure TMAINFORM.modificarClick(Sender: TObject);
var
  cad: string;
begin
  cad := '(tipo is null) or (tipo=1) or (tipo=2)';
  if UDM.tb_tree.FieldByName('tipo').AsInteger = 2 then
  begin
    cad := '(tipo is null) or (tipo=1)';
  end;
  with TfrmEstructura.Create(nil) do
  try
    tsAddNodo.TabVisible := False;
    tseditNode.TabVisible := True;
    pcTree.ActivePage := tseditNode;
    if trim(UDM.tb_tree.FieldByName('IdfunGeneral').AsString) <> '' then
    begin

      if (UDM.tb_tree.FieldByName('tipo').AsInteger = 2) or (UDM.tb_tree.FieldByName('tipo').AsInteger = 3) then
      begin
        with cmdFunGen do
        begin
          Active := False;
          SQL.Clear;
          SQL.Add('select *  from cl_funcionesgen where idfunciones=' + UDM.tb_tree.FieldByName('IdfunGeneral').AsString);
          try
            Active := True;
          except
          end;
        end;
        tsFunGen.TabVisible := True;
        tsFuncionesEspecificas.TabVisible := True;
        tsFacultades.TabVisible := True;
      end;
    end;
    with cmdPadres do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select * from tb_tree where ' + cad + ' order by ID');
      try
        Active := True;
      except
      end;
    end;
    ShowModal;
  finally
    Free;
  end;
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

procedure TMAINFORM.RemoveMDSeriesSubSeriesDMDR;
begin
  UDM.cl_series.Active := False;
  UDM.cl_subseries.Active := False;
  UDM.cl_subseries.MasterSource := nil;
  UDM.cl_subseries.MasterFields := '';
  UDM.cl_subseries.IndexFieldNames := '';
  UDM.cl_series.Active := True;
  UDM.cl_subseries.Active := True;
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

procedure TMAINFORM.ToolButton13Click(Sender: TObject);
begin
  UDM.ManagementHLP(pCaptionSubSeries.Caption, pCaptionSubSeries.Handle);
end;

procedure TMAINFORM.ToolButton18Click(Sender: TObject);
begin
  UDM.ManagementHLP(PCaptionSeries.Caption, PCaptionSeries.Handle);
end;

procedure TMAINFORM.ToolButton1Click(Sender: TObject);
begin
  UDM.Tb_SeriesDispo.Active := False;
  UDM.Tb_SeriesDispo.Active := True;
  UDM.Tb_SeriesDispo.FetchAll;
  with TfrmSeriesDisp.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TMAINFORM.ToolButton5Click(Sender: TObject);
begin
  if UDM.tb_SeriesDatos.RecordCount > 0 then
    VarVirtual
  else
  begin
    MessageDlg('No ha introducido ninguna serie documental el dia de hoy.', mtInformation, [mbOK], 0);
    Exit;
  end;
end;

procedure TMAINFORM.ToolButton6Click(Sender: TObject);
begin
  if UDM.tb_Serietree.RecordCount = 0 then
  begin
    MessageDlg('Debe identificar al menos una serie documental v?lida.', mtInformation, [mbOK], 0);
    if MessageDlg('?Desea consultar el listado de Series documentales identificadas?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      ToolButton1Click(Sender);
    Exit;
  end;
  tsInputSeriesData.TabVisible := True;
  tsSeriesDef.TabVisible := False;
  pcSeriesDocumentales.ActivePage := tsInputSeriesData;
end;

end.

