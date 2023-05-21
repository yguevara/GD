unit UCapaDatos;

interface

uses
  System.SysUtils, System.Classes, System.Variants, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Phys, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.VCLUI.Wait, FireDAC.Phys.MSAccDef, FireDAC.Phys.ODBCBase,
  FireDAC.Phys.MSAcc, FireDAC.Comp.UI, Data.DB, FireDAC.Comp.Client,
  Winapi.Windows, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.Comp.DataSet, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  Vcl.Controls, Data.Win.ADODB, cxVGrid, cxStyles, cxGridTableView, cxClasses,
  VCL.StdCtrls, Vcl.ComCtrls, FireDAC.Stan.StorageJSON, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdFTP, Winapi.ShellAPI, USecurityClasss, dxtree, dxdbtree,
  FireDAC.Comp.ScriptCommands, FireDAC.Stan.Util, FireDAC.Comp.Script, cxDBData,
  cxGridLevel, cxGridCustomTableView, cxGridDBTableView, cxGridCustomView,
  cxGrid, Winapi.TlHelp32, Winapi.ShlObj, Masks, Vcl.Forms, FireDAC.VCLUI.Script;

type
//==============================================================================
// Tipos de Datos
//==============================================================================
  RActiveFTPServer = record
    Ip: string;
    Nombre: string;
    puerto: Integer;
    usuario: string;
    password: string;
    PathServer: string;
  end;

  TNODOSD = record
    estructura: string;
    Id: integer;
    Padre: Integer;
    ICONO: Integer;
    Tipo: integer;
  end;

  PDataRec = ^TDataRec; { RecordPointer }

  TDataRec = record
    Id: Integer;
    Etiqueta: string;
    Padre: Integer;
    Icono: Integer;
  end;

  PArbol = ^TTreeview;

  PArbolDB = ^tdxdbtreeview;

  Tpdatasource = ^Tdatasource;

  TUDM = class(TDataModule)
    cl_facultadesgen: TFDQuery;
    dscl_facultadesgen: TDataSource;
    cl_funcionesgen: TFDQuery;
    dscl_funcionesgen: TDataSource;
    Conn: TFDConnection;
    FDM: TFDManager;
    WaitCursor: TFDGUIxWaitCursor;
    dstb_Serietree: TDataSource;
    ILEdith: TImageList;
    cl_cargo: TFDQuery;
    dscl_cargo: TDataSource;
    Tb_Rol: TFDTable;
    DSTb_Rol: TDataSource;
    cmdUser: TFDQuery;
    dstb_tree: TDataSource;
    tb_tree: TFDQuery;
    ImageList1: TImageList;
    dscl_series: TDataSource;
    dscl_subseries: TDataSource;
    cl_subseries: TFDQuery;
    cl_series: TFDQuery;
    ConnUser: TADOConnection;
    ILv4: TImageList;
    ILv1: TImageList;
    cl_destino: TFDQuery;
    dscl_destino: TDataSource;
    cl_acceso: TFDQuery;
    dscl_acceso: TDataSource;
    cl_soporte: TFDQuery;
    dscl_soporte: TDataSource;
    cl_frecuencia: TFDQuery;
    dscl_frecuencia: TDataSource;
    cl_tipodoc: TFDQuery;
    dscl_tipodoc: TDataSource;
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
    GridTableViewStyleSheetDevExpress: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetUserFormat1: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetUserFormat2: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetUserFormat3: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetUserFormat4: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetBrick: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetDesert: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetEggplant: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetLilac: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetMaple: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetMarinehighcolor: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetPlumhighcolor: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetPumpkinlarge: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetRainyDay: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetRedWhiteandBlueVGA: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetRose: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetRoselarge: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetSlate: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetSpruce: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetStormVGA: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetTealVGA: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetWheat: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetWindowsClassic: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetWindowsClassiclarge: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetWindowsStandard: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetWindowsStandardlarge: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetHighContrast1: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetHighContrast1large: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetHighContrast2: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetHighContrast2large: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetHighContrastBlack: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetHighContrastBlacklarge: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetHighContrastWhite: TcxGridTableViewStyleSheet;
    GridTableViewStyleSheetHighContrastWhitelarge: TcxGridTableViewStyleSheet;
    cxStyleRepository2: TcxStyleRepository;
    cxStyle378: TcxStyle;
    cxStyle379: TcxStyle;
    cxStyle380: TcxStyle;
    cxStyle381: TcxStyle;
    cxStyle382: TcxStyle;
    cxStyle383: TcxStyle;
    cxVerticalGridStyleSheetEggplant: TcxVerticalGridStyleSheet;
    cl_Resp_Gest_Arch: TFDQuery;
    dscl_Resp_Gest_Arch: TDataSource;
    cl_ftp_Server: TFDQuery;
    dscl_ftp_Server: TDataSource;
    cl_tipologia: TFDQuery;
    dscl_tipologia: TDataSource;
    cl_tipoestructura: TFDQuery;
    dscl_tipoestructura: TDataSource;
    AllFather: TFDQuery;
    dsAllFather: TDataSource;
    tcl_procesosGrupos: TFDQuery;
    tcl_procesosGruposIdGrupo: TSmallintField;
    tcl_procesosGruposNombreGrupo: TWideStringField;
    Dtcl_procesosGrupos: TDataSource;
    tcl_Procesos: TFDQuery;
    tcl_ProcesosIdGrupo: TSmallintField;
    tcl_ProcesosIdProceso: TSmallintField;
    tcl_ProcesosNombreProceso: TWideStringField;
    Dtcl_Procesos: TDataSource;
    tcl_ProcesoSubproceso: TFDQuery;
    Dtcl_ProcesoSubproceso: TDataSource;
    tb_mp: TFDQuery;
    dstb_mp: TDataSource;
    cl_categoria_ocupacional: TFDQuery;
    dscl_categoria_ocupacional: TDataSource;
    cxVerticalGridStyleSheetDevExpress: TcxVerticalGridStyleSheet;
    cxStyle384: TcxStyle;
    cxStyle385: TcxStyle;
    cxStyle386: TcxStyle;
    cxStyle387: TcxStyle;
    cxStyle388: TcxStyle;
    cxStyle389: TcxStyle;
    cxStyle390: TcxStyle;
    cxVerticalGridStyleSheetUserFormat1: TcxVerticalGridStyleSheet;
    cxStyle391: TcxStyle;
    cxStyle392: TcxStyle;
    cxStyle393: TcxStyle;
    cxStyle394: TcxStyle;
    cxStyle395: TcxStyle;
    cxStyle396: TcxStyle;
    cxVerticalGridStyleSheetUserFormat2: TcxVerticalGridStyleSheet;
    cxStyle397: TcxStyle;
    cxStyle398: TcxStyle;
    cxStyle399: TcxStyle;
    cxStyle400: TcxStyle;
    cxStyle401: TcxStyle;
    cxStyle402: TcxStyle;
    cxVerticalGridStyleSheetUserFormat3: TcxVerticalGridStyleSheet;
    cxStyle403: TcxStyle;
    cxStyle404: TcxStyle;
    cxStyle405: TcxStyle;
    cxStyle406: TcxStyle;
    cxStyle407: TcxStyle;
    cxStyle408: TcxStyle;
    cxVerticalGridStyleSheetUserFormat4: TcxVerticalGridStyleSheet;
    cxStyle409: TcxStyle;
    cxStyle410: TcxStyle;
    cxStyle411: TcxStyle;
    cxStyle412: TcxStyle;
    cxStyle413: TcxStyle;
    cxStyle414: TcxStyle;
    cxStyle415: TcxStyle;
    cxVerticalGridStyleSheetBrick: TcxVerticalGridStyleSheet;
    cxStyle416: TcxStyle;
    cxStyle417: TcxStyle;
    cxStyle418: TcxStyle;
    cxStyle419: TcxStyle;
    cxStyle420: TcxStyle;
    cxStyle421: TcxStyle;
    cxVerticalGridStyleDesert: TcxVerticalGridStyleSheet;
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
    cxVerticalGridStyleSheetLilac: TcxVerticalGridStyleSheet;
    cxStyle434: TcxStyle;
    cxStyle435: TcxStyle;
    cxStyle436: TcxStyle;
    cxStyle437: TcxStyle;
    cxStyle438: TcxStyle;
    cxStyle439: TcxStyle;
    cxVerticalGridStyleSheetMaple: TcxVerticalGridStyleSheet;
    cxStyle440: TcxStyle;
    cxStyle441: TcxStyle;
    cxStyle442: TcxStyle;
    cxStyle443: TcxStyle;
    cxStyle444: TcxStyle;
    cxStyle445: TcxStyle;
    cxVerticalGridStyleSheetMarineHighColor: TcxVerticalGridStyleSheet;
    cxStyle446: TcxStyle;
    cxStyle447: TcxStyle;
    cxStyle448: TcxStyle;
    cxStyle449: TcxStyle;
    cxStyle450: TcxStyle;
    cxStyle451: TcxStyle;
    cxVerticalGridStyleSheetPlumHighColor: TcxVerticalGridStyleSheet;
    cxStyle452: TcxStyle;
    cxStyle453: TcxStyle;
    cxStyle454: TcxStyle;
    cxStyle455: TcxStyle;
    cxStyle456: TcxStyle;
    cxStyle457: TcxStyle;
    cxVerticalGridStyleSheetPumpkinLarge: TcxVerticalGridStyleSheet;
    cxStyle458: TcxStyle;
    cxStyle459: TcxStyle;
    cxStyle460: TcxStyle;
    cxStyle461: TcxStyle;
    cxStyle462: TcxStyle;
    cxStyle463: TcxStyle;
    cxVerticalGridStyleSheetRainyDay: TcxVerticalGridStyleSheet;
    cxStyle464: TcxStyle;
    cxStyle465: TcxStyle;
    cxStyle466: TcxStyle;
    cxStyle467: TcxStyle;
    cxStyle468: TcxStyle;
    cxStyle469: TcxStyle;
    cxVerticalGridStyleSheetRedWhiteAndBlueVGA: TcxVerticalGridStyleSheet;
    cxStyle470: TcxStyle;
    cxStyle471: TcxStyle;
    cxStyle472: TcxStyle;
    cxStyle473: TcxStyle;
    cxStyle474: TcxStyle;
    cxStyle475: TcxStyle;
    cxVerticalGridStyleSheetRose: TcxVerticalGridStyleSheet;
    cxStyle476: TcxStyle;
    cxStyle477: TcxStyle;
    cxStyle478: TcxStyle;
    cxStyle479: TcxStyle;
    cxStyle480: TcxStyle;
    cxStyle481: TcxStyle;
    cxVerticalGridStyleSheetRoseLarge: TcxVerticalGridStyleSheet;
    cxStyle482: TcxStyle;
    cxStyle483: TcxStyle;
    cxStyle484: TcxStyle;
    cxStyle485: TcxStyle;
    cxStyle486: TcxStyle;
    cxStyle487: TcxStyle;
    cxVerticalGridStyleSheetSlate: TcxVerticalGridStyleSheet;
    cxStyle488: TcxStyle;
    cxStyle489: TcxStyle;
    cxStyle490: TcxStyle;
    cxStyle491: TcxStyle;
    cxStyle492: TcxStyle;
    cxStyle493: TcxStyle;
    cxVerticalGridStyleSheetSpruce: TcxVerticalGridStyleSheet;
    cxStyle494: TcxStyle;
    cxStyle495: TcxStyle;
    cxStyle496: TcxStyle;
    cxStyle497: TcxStyle;
    cxStyle498: TcxStyle;
    cxStyle499: TcxStyle;
    cxVerticalGridStyleSheetStormVGA: TcxVerticalGridStyleSheet;
    cxStyle500: TcxStyle;
    cxStyle501: TcxStyle;
    cxStyle502: TcxStyle;
    cxStyle503: TcxStyle;
    cxStyle504: TcxStyle;
    cxStyle505: TcxStyle;
    cxVerticalGridStyleSheetTealVGA: TcxVerticalGridStyleSheet;
    cxStyle506: TcxStyle;
    cxStyle507: TcxStyle;
    cxStyle508: TcxStyle;
    cxStyle509: TcxStyle;
    cxStyle510: TcxStyle;
    cxStyle511: TcxStyle;
    cxVerticalGridStyleSheetWheat: TcxVerticalGridStyleSheet;
    cxStyle512: TcxStyle;
    cxStyle513: TcxStyle;
    cxStyle514: TcxStyle;
    cxStyle515: TcxStyle;
    cxStyle516: TcxStyle;
    cxStyle517: TcxStyle;
    cxVerticalGridStyleSheetWindowsClassic: TcxVerticalGridStyleSheet;
    cxStyle518: TcxStyle;
    cxStyle519: TcxStyle;
    cxStyle520: TcxStyle;
    cxStyle521: TcxStyle;
    cxStyle522: TcxStyle;
    cxStyle523: TcxStyle;
    cxVerticalGridStyleSheetWindowsClassicLarge: TcxVerticalGridStyleSheet;
    cxStyle524: TcxStyle;
    cxStyle525: TcxStyle;
    cxStyle526: TcxStyle;
    cxStyle527: TcxStyle;
    cxStyle528: TcxStyle;
    cxStyle529: TcxStyle;
    cxVerticalGridStyleSheetWindowsStandard: TcxVerticalGridStyleSheet;
    cxStyle530: TcxStyle;
    cxStyle531: TcxStyle;
    cxStyle532: TcxStyle;
    cxStyle533: TcxStyle;
    cxStyle534: TcxStyle;
    cxStyle535: TcxStyle;
    cxVerticalGridStyleSheetWindowsStandardLarge: TcxVerticalGridStyleSheet;
    cxStyle536: TcxStyle;
    cxStyle537: TcxStyle;
    cxStyle538: TcxStyle;
    cxStyle539: TcxStyle;
    cxStyle540: TcxStyle;
    cxStyle541: TcxStyle;
    cxVerticalGridStyleSheetHighContrast1: TcxVerticalGridStyleSheet;
    cxStyle542: TcxStyle;
    cxStyle543: TcxStyle;
    cxStyle544: TcxStyle;
    cxStyle545: TcxStyle;
    cxStyle546: TcxStyle;
    cxStyle547: TcxStyle;
    cxVerticalGridStyleSheetHighContrast1Large: TcxVerticalGridStyleSheet;
    cxStyle548: TcxStyle;
    cxStyle549: TcxStyle;
    cxStyle550: TcxStyle;
    cxStyle551: TcxStyle;
    cxStyle552: TcxStyle;
    cxStyle553: TcxStyle;
    cxVerticalGridStyleSheetHighContrast2: TcxVerticalGridStyleSheet;
    cxStyle554: TcxStyle;
    cxStyle555: TcxStyle;
    cxStyle556: TcxStyle;
    cxStyle557: TcxStyle;
    cxStyle558: TcxStyle;
    cxStyle559: TcxStyle;
    cxVerticalGridStyleSheetHighContrast2Large: TcxVerticalGridStyleSheet;
    cxStyle560: TcxStyle;
    cxStyle561: TcxStyle;
    cxStyle562: TcxStyle;
    cxStyle563: TcxStyle;
    cxStyle564: TcxStyle;
    cxStyle565: TcxStyle;
    cxVerticalGridStyleSheetHighContrastBlack: TcxVerticalGridStyleSheet;
    cxStyle566: TcxStyle;
    cxStyle567: TcxStyle;
    cxStyle568: TcxStyle;
    cxStyle569: TcxStyle;
    cxStyle570: TcxStyle;
    cxStyle571: TcxStyle;
    cxVerticalGridStyleSheetHighContrastBlackLarge: TcxVerticalGridStyleSheet;
    cxStyle572: TcxStyle;
    cxStyle573: TcxStyle;
    cxStyle574: TcxStyle;
    cxStyle575: TcxStyle;
    cxStyle576: TcxStyle;
    cxStyle577: TcxStyle;
    cxVerticalGridStyleSheetHighContrastWhite: TcxVerticalGridStyleSheet;
    cxStyle578: TcxStyle;
    cxStyle579: TcxStyle;
    cxStyle580: TcxStyle;
    cxStyle581: TcxStyle;
    cxStyle582: TcxStyle;
    cxStyle583: TcxStyle;
    cxVerticalGridStyleSheetHighContrastWhiteLarge: TcxVerticalGridStyleSheet;
    cxStyle584: TcxStyle;
    cxStyle585: TcxStyle;
    cxStyle586: TcxStyle;
    cxStyle587: TcxStyle;
    cxStyle588: TcxStyle;
    cxStyle589: TcxStyle;
    cxVerticalGridStyleSheet1: TcxVerticalGridStyleSheet;
    tb_SeriesDatos: TFDQuery;
    dstb_SeriesDatos: TDataSource;
    cl_variables: TFDQuery;
    dscl_variables: TDataSource;
    tb_SerieDatosVar: TFDQuery;
    dstb_SerieDatosVar: TDataSource;
    cl_VarSubserie: TFDQuery;
    dscl_VarSubserie: TDataSource;
    cl_ArchivosGestion: TFDQuery;
    dscl_ArchivosGestion: TDataSource;
    dsTb_SeriesDispo: TDataSource;
    Tb_SeriesDispo: TFDQuery;
    dscl_especialista: TDataSource;
    cl_especialista: TFDQuery;
    tb_VirtualVar: TFDMemTable;
    Dtb_VirtualVar: TDataSource;
    IdFTP1: TIdFTP;
    dscl_deposito: TDataSource;
    cl_deposito: TFDQuery;
    cl_VarProject: TFDQuery;
    dscl_VarProject: TDataSource;
    ILv2: TImageList;
    tb_Serietree: TFDQuery;
    cl_tipoobj: TFDQuery;
    dscl_tipoobj: TDataSource;
    ImageList2: TImageList;
    tb_EstructDisp: TFDQuery;
    dstb_EstructDisp: TDataSource;
    ILv3: TImageList;
    tb_AllSon: TFDQuery;
    dstb_AllSon: TDataSource;
    dsCL_Nodos: TDataSource;
    CL_Nodos: TFDQuery;
    dscl_nodopadre: TDataSource;
    cl_nodopadre: TFDQuery;
    cl_valordoc: TFDQuery;
    dscl_valordoc: TDataSource;
    cl_tipoarch: TFDQuery;
    dscl_tipoarch: TDataSource;
    IDYONI: TcxStyle;
    dsVarDispSubS: TDataSource;
    VarDispSubS: TFDQuery;
    cl_vigencia: TFDQuery;
    dscl_vigencia: TDataSource;
    dsSudSDetail: TDataSource;
    SudSDetail: TFDQuery;
    dsCL_ArchivoDpto: TDataSource;
    CL_ArchivoDpto: TFDQuery;
    dsVarSSDetail: TDataSource;
    VarSSDetail: TFDQuery;
    dsVarDispPrj: TDataSource;
    VarDispPrj: TFDQuery;
    CMD: TFDQuery;
    dsVarEPCDetail: TDataSource;
    VarEPCDetail: TFDQuery;
    dstb_VirtVarDataEstruct: TDataSource;
    tb_VirtVarDataEstruct: TFDQuery;
    tb_VirtualVarPrj: TFDMemTable;
    dstb_VirtualVarPrj: TDataSource;
    cl_vig: TFDQuery;
    MSAccessDriver: TFDPhysMSAccessDriverLink;
    cl_expediente: TFDQuery;
    dscl_expediente: TDataSource;
    cl_tipoexp: TFDQuery;
    dscl_tipoexp: TDataSource;
    tb_ssArchdigital: TFDQuery;
    dstb_ssArchdigital: TDataSource;
    CMDScript: TFDScript;
    tb_ext: TFDQuery;
    dstb_ext: TDataSource;
    ILDigital: TImageList;
    dsqryAnexosDig: TDataSource;
    qryAnexosDig: TFDQuery;
    dsqryFuentesDig: TDataSource;
    qryFuentesDig: TFDQuery;
    tb_DocCoord: TFDQuery;
    dstb_DocCoord: TDataSource;
    FDGUIxScriptDialog1: TFDGUIxScriptDialog;
    cl_tiposerie: TFDQuery;
    dscl_tiposerie: TDataSource;
    SudSDetailcodsubs: TWideStringField;
    SudSDetailcodserie: TWideStringField;
    SudSDetailserie: TWideStringField;
    SudSDetailsubserie: TWideStringField;
    SudSDetailValordoc: TWideStringField;
    SudSDetailTipodoc: TWideStringField;
    SudSDetailvigencia: TWideStringField;
    SudSDetailayear: TSmallintField;
    SudSDetailtgestion: TSmallintField;
    SudSDetailtcentral: TSmallintField;
    SudSDetailNombreDestino: TWideStringField;
    SudSDetailNombreAcceso: TWideStringField;
    SudSDetailNombreFrecuencia: TWideStringField;
    SudSDetailNombresoporte: TWideStringField;
    SudSDetailtiempo: TIntegerField;
    SudSDetailnombreArchivo: TWideStringField;
    SudSDetaildeposito: TWideStringField;
    SudSDetailgaveta: TByteField;
    SudSDetailGESTOR: TWideStringField;
    SudSDetailCorreoElect: TWideStringField;
    SudSDetailobservacion: TWideMemoField;
    SudSDetailetiquetaServ: TWideStringField;
    SudSDetailipserver: TWideStringField;
    SudSDetailcroquis: TBlobField;
    SudSDetailFoto: TBlobField;
    SudSDetailTipo: TIntegerField;
    SudSDetailespacial: TWideStringField;
    procedure DataModuleCreate(Sender: TObject);
    procedure tb_treeAfterPost(DataSet: TDataSet);
    procedure dstb_treeDataChange(Sender: TObject; Field: TField);
    procedure tb_SerietreePostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure cl_expedientePostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure tb_SeriesDatosNewRecord(DataSet: TDataSet);
    procedure tb_SeriesDatosBeforeDelete(DataSet: TDataSet);
  private
    procedure Inserta(aidObjeto, acodigoHijo, acodigoPadre, aicon: Integer; aetiq, NombreEntidad, aKeyDef, aKeyVal: string);
    procedure ActivaDataLayer(aValue: boolean);
    procedure UpDateDB;

    { Private declarations }
  public
    { Public declarations }
    Rol,                  // Rol del usuario logeado.
    UserName: string;     // Usuario logeado
    function CarpetaGeodato: string;
//------------------------------------------------------------------------------
// Crear árbol de tablas...
//------------------------------------------------------------------------------
    procedure CreaTreeDB(conn: TFdconnection; t: PArbol; ShowAll: Boolean);
    procedure Visualiza(conn: TFDConnection; IdNodo: string; V: boolean);
    procedure VisualizaOneNodeAndParent(conn: TFDConnection; IdNodo: string; V: boolean);
    procedure VerPDFF(aFileName: string);
    function GetNewNodeID: Integer;
    function CleanTableTree(aTableName: string): boolean;
    function GetNewNodeMP: Integer;
    function GetIDParentTreeNode: integer;
    procedure AddBlankNode;
    procedure GetNodoPadreActual;
    function GetLastFunct: Integer;
    function GetLastFacult: Integer;
    function GetLastId(NombreTabla, NombdeKey: string): Integer;
    procedure VarVirt;
    procedure FTPconnect(aHost, auser, apass, aport: string);
    procedure FTPDisconnect;
    function GetFTPHost(IdServer: integer): RActiveFTPServer;
    procedure CreateFTPDirStructure(ListProccess: TStringList);
    procedure ejecutaPDF(WindowsID: HWND; Path: string);
    procedure ManagementHLP(HLPName: string; WindowsHandle: HWND);
    function sms(aText: string; aTipo: Integer): integer;
    procedure UpdateVarSubS(acod: string);
    procedure UpdateVarPrj(acodEE, acodNN: string);
    function VarToInt(const AVariant: Variant): integer;
    function WinExecAndWait32(FileName: string; Visibility: integer): integer;
    function ViewPDF(FilePath: string): Integer;
    function ViewIMG(FilePath: string): Integer;
    procedure SalvaConfigGrid(nombregrid: TcxGridDBTableView; NombreSalva: string);
    procedure RestauraGrid(nombregrid: TcxGridDBTableView; NombreSalva: string);
    function KillProcess(ExeFileName: string): integer;
    function EsLocal(idServer: integer): Boolean;
    function GetFolder(idServer: integer): string;
    function BorrarCarpeta(const vOrigen: string): boolean;
    procedure RunAndWaitShell(Ejecutable, Argumentos: string; Visibilidad: integer);
    function Sto_GetFmtFileVersion(const FileName: string = ''; const Fmt: string = '%d.%d.%d.%d'): string;
    procedure CompletaNombreFile;
  end;

var
  UDM: TUDM;
  ItsWork: Boolean;
  VersionProgram: string;
  Carpeta: string;
  acceso: string;
  syshelpLeft: integer;
  NombreFileSS: string;
  PathTemp, PathBD, PathSys, PathSaveBinaryFile: WideString;
  Rolactivo: string;
  Security: TSecurityClass;
  nombrecamp, valueSelectedFillD: string;
  valueSelectedFill: OleVariant;
  //Nodos
  AnItem: TTreeNode;
  etiquetaNA: string;
  //NodePadre:TTreeNode;
  IDN: Integer;
  NodoPadreActual: TNODOSD;
  Descripcion: AnsiString;
  EditorActivo: Boolean;
  imagenactual: Integer;
  EstructuraActual: string;
  cadcmd: WideString;
  varMod: string; // A: Append; E: Edit
  NodoActivo: string;
  SystemTree: PArbolDB;
  EsReadOnly: Boolean;
  //Tipo de objeto para la asignacion de variables virturales...
  TipoObj: string;

implementation


{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TUDM.AddBlankNode;
var
  tipoestruc: Integer;
begin
  tipoestruc := UDM.Conn.ExecSQLScalar('select idtipoobj from cl_tipoestructura where Idestructura=' + QuotedStr(EstructuraActual));
  imagenactual := UDM.Conn.ExecSQLScalar('select icon from cl_tipoobj where idtipoobj=' + inttostr(tipoestruc));
  UDM.tb_tree.Append;
  UDM.tb_tree.FieldByName('Idestructura').AsString := EstructuraActual;
  UDM.tb_tree.FieldByName('id').AsInteger := UDM.GetNewNodeID;
  UDM.tb_tree.FieldByName('etiqueta').AsString := '(Agregar ' + EstructuraActual + ')';
  UDM.tb_tree.FieldByName('Padre').AsInteger := NodoPadreActual.Id;
  UDM.tb_tree.FieldByName('icono').AsInteger := imagenactual;
  UDM.tb_tree.FieldByName('tipo').AsInteger := tipoestruc;
  UDM.tb_tree.Post;
end;

function TUDM.BorrarCarpeta(const vOrigen: string): boolean;
var
  vCarpetas: TSHFileOpStruct;
begin
  // Inicializamos la variable vCarpetas
  FillChar(vCarpetas, SizeOf(vCarpetas), #0);

  // Preparamos las propiedades de vCarpetas para borrar
  vCarpetas.wFunc := FO_DELETE;
  vCarpetas.Wnd := GetDesktopWindow;
  vCarpetas.pFrom := PChar(vOrigen + #0#0);

  // Cargamos las banderas de
  // FOF_NOCONFIRMATION -> no pide confirmación para copiar
  // FOF_SILENT -> no muestra el dialogo de progreso
  // FOF_ALLOWUNDO -> preserva la información para deshacer, si es posible
  vCarpetas.fFlags := FOF_NOCONFIRMATION or FOF_SILENT or FOF_ALLOWUNDO;

  // Ejecutamos el proceso con ShFileOperation y si devuelve 0, la operación es un éxito
  Result := (ShFileOperation(vCarpetas) = 0);
end;

procedure TUDM.GetNodoPadreActual;
begin
  NodoPadreActual.id := UDM.tb_tree.FieldByName('id').AsInteger;
  NodoPadreActual.Padre := UDM.tb_tree.FieldByName('Padre').AsInteger;
  NodoPadreActual.icono := UDM.tb_tree.FieldByName('icono').AsInteger;
  NodoPadreActual.tipo := UDM.tb_tree.FieldByName('tipo').AsInteger;
end;

function TUDM.CarpetaGeodato: string;

  function TempDir: widestring;
  var
    Temp: array[0..MAX_PATH] of char;
  begin
    GetTempPath(MAX_PATH, Temp);
    result := wideString(Temp);
  end;

begin
  if not DirectoryExists(TempDir + 'GD_SERIES\') then
    MkDir(TempDir + '\GD_SERIES');
  Result := TempDir + 'GD_SERIES\';
end;

function TUDM.CleanTableTree(aTableName: string): boolean;
begin
  Result := false;
  try
    conn.ExecSQL('delete from ' + aTableName + ' where id<>0');
    Result := True;
  except
  end;
end;

procedure TUDM.cl_expedientePostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  UDM.sms('Los cambios no se pudieron realizar. Motivo: ' + E.Message, 1);
end;

procedure TUDM.DataModuleCreate(Sender: TObject);
begin
  TipoObj := 'S';
  ItsWork := False;
  EsReadOnly := False;
  PathTemp := CarpetaGeodato;
  cadcmd := '';
  PathSys := ExtractFilePath(Application.ExeName);
  PathBD := PathSys + 'BD\SDbd.mdb';
  PathSaveBinaryFile := PathSys + 'bin\';
  with conn do
  begin
    Connected := False;
    with Params do
    begin
      Clear;
      Add('Database=' + PathBD);
      Add('DriverID=MSAcc');
    end;
    try
      Connected := True;
      //Agregue un fichero llamado Update.src que le permita modificar la base de datos...
      UpDateDB;
    except
      on E: EFDexception do
      begin
        sms('No se ha podido establecer comunicación con la base de datos. Motivo: ' + E.Message, 1);
        Exit;
      end;
    end;
  end;
  ActivaDataLayer(true);
end;

procedure TUDM.dstb_treeDataChange(Sender: TObject; Field: TField);
begin
  with UDM.VarEPCDetail do
  begin
    Active := False;
    Params[0].Value := tb_tree.FieldByName('idestructura').AsString;
    try
      Active := True;
    except
    end;
  end;
end;

procedure TUDM.ejecutaPDF(WindowsID: HWND; Path: string);
begin
  try
    ShellExecute(WindowsID, nil, PChar(Path), '', '', SW_SHOWNORMAL);
  except
    on E: EFilerError do
    begin
      sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
      Exit;
    end;
  end;
end;

function TUDM.EsLocal(idServer: integer): Boolean;
begin
  {Result := False;
  if UDM.cl_ftp_Server.Locate('Idservidor', idServer, []) then
    if (trim(UDM.cl_ftp_Server.FieldByName('user').AsString) = '') and (trim(UDM.cl_ftp_Server.FieldByName('pass').AsString) = '') and (trim(UDM.cl_ftp_Server.FieldByName('puerto').AsString) = '') then
      Result := True;}
end;

procedure TUDM.FTPconnect(aHost, auser, apass, aport: string);
begin
  if UDM.IdFTP1.Connected then
    UDM.IdFTP1.Disconnect;
  UDM.IdFTP1.Host := aHost; //'127.0.0.1';
  UDM.IdFTP1.Username := auser; //'geodato';
  UDM.IdFTP1.Password := apass; //'geodato';
  UDM.IdFTP1.Port := StrToInt(aport);
  UDM.IdFTP1.Passive := True;
  UDM.IdFTP1.Connect;
end;

procedure TUDM.FTPDisconnect;
begin
  UDM.IdFTP1.Disconnect;
end;

function TUDM.GetFolder(idServer: integer): string;
begin
  Result := '';
  if UDM.cl_ftp_Server.Locate('Idservidor', idServer, []) then
    Result := UDM.cl_ftp_Server.FieldByName('path').AsString;

end;

function TUDM.GetFTPHost(IdServer: integer): RActiveFTPServer;
var
  tmp: RActiveFTPServer;
begin
  with TFDQuery.Create(nil) do
  try
    Active := False;
    Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('select * from cl_ftp_Server where idservidor=' + IntToStr(IdServer));
    try
      Active := True;
      tmp.Ip := FieldByName('ipserver').AsString;
      tmp.Nombre := FieldByName('etiquetaServ').AsString;
      tmp.PathServer := FieldByName('path').AsString;
      tmp.usuario := FieldByName('user').AsString;
      tmp.password := FieldByName('pass').AsString;
      tmp.puerto := FieldByName('puerto').AsInteger;
    except
    end;
  finally
    Free;
  end;
  Result := tmp;
end;

function TUDM.GetIDParentTreeNode: integer;
begin
  Result := conn.ExecSQLScalar('SELECT Min(id) AS ParentID FROM tb_tree');
end;

function TUDM.GetLastFacult: Integer;
begin
  Result := 0;
  try
    Result := conn.ExecSQLScalar('SELECT Max(idfacultades)+1 AS NewID FROM cl_facultadesgen');
  except
  end;
end;

function TUDM.GetLastFunct: Integer;
begin
  Result := 0;
  try
    Result := conn.ExecSQLScalar('SELECT Max(idfunciones)+1 AS NewID FROM cl_funcionesgen');
  except
  end;
end;

function TUDM.GetLastId(NombreTabla, NombdeKey: string): Integer;
var
  cad: string;
  pp: integer;
begin
  Result := 0;
  cad := 'SELECT Max(' + NombdeKey + ')+1 AS NewID FROM ' + NombreTabla;
  try
    if conn.ExecSQLScalar(cad) <> null then
      Result := conn.ExecSQLScalar(cad);
  except
  end;
end;

function TUDM.GetNewNodeID: Integer;
begin
  Result := 0;
  try
    Result := conn.ExecSQLScalar('SELECT Max(id)+1 AS NewID FROM tb_tree');
  except
  end;
end;

function TUDM.GetNewNodeMP: Integer;
begin
  Result := 0;
  try
    Result := UDM.conn.ExecSQLScalar('SELECT Max(id)+1 AS NewID FROM tb_mp');
  except
  end;
end;

procedure TUDM.CompletaNombreFile;
var
  List: TStringList;
  NombreFile: string;

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
  if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    NombreFile := removeext(ExtractFileName(List[0]));
    UDM.tb_SeriesDatos.Edit;
    UDM.tb_SeriesDatos.FieldByName('namefile').AsString := NombreFile;
    try
      UDM.tb_SeriesDatos.Post;
    except
      UDM.tb_SeriesDatos.Cancel;
    end;
  end;
end;

procedure TUDM.CreateFTPDirStructure(ListProccess: TStringList);
var
  Local_i: Integer;
begin

end;

procedure TUDM.CreaTreeDB(conn: TFdconnection; t: PArbol; ShowAll: Boolean);
{-------------------------------------------------------------------------------
  Procedure: TDM.CreaTreeDB
  Author:    YONI
  DateTime:  2021.05.01
  Arguments: conn: TFdconnection; t: PArbol; tipo: char
  Result:    None
-------------------------------------------------------------------------------}

var
  qry, qr: TFDQuery;
  cad: string;
  ndopadre, ndoparent: TTreeNode;
  EsView: Boolean;

  function c(objeto: string; tipo: char): string;
  begin
    Result := objeto;
    if tipo = 'P' then
      Result := '"' + lowercase(objeto) + '"';
  end;

  procedure PonImgen(ndo: TTreeNode; id: Integer);
  begin
    ndo.ImageIndex := id;
    ndo.SelectedIndex := id;
  end;

  procedure AgregaData(Nodo: TTreeNode; aId, apadre, aIcono: integer; aetiqueta: string; v: Boolean);
  var
    pData: PDataRec;
    tmpNodo: TTreeNode;
  begin
    new(pData);
    pData.Id := aId;
    pData.Padre := apadre;
    pData.Icono := aIcono;
    pData.Etiqueta := aetiqueta;
    PonImgen(Nodo, aIcono);
    Nodo.Data := pData;
  end;

  procedure NodoQuery(ndo: TTreeNode; IdPadre: integer);
  var
    tmpNode: TTreeNode;
  begin
    with TFDQuery.Create(nil) do
    try
      Connection := conn;
      SQL.Clear;
      if not ShowAll then
        SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible FROM tb_tree  where Padre=' + IntToStr(IdPadre) + ' and visible=true order by etiqueta')
      else
        SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible FROM tb_tree  where Padre=' + IntToStr(IdPadre) + ' order by etiqueta');
      try
        Active := True;
        while not Eof do
        begin
          tmpNode := t.Items.AddChild(ndo, FieldByName('etiqueta').AsString);
          AgregaData(tmpNode, Fields[0].AsInteger, Fields[2].AsInteger, Fields[3].AsInteger, Fields[1].AsString, Fields[4].AsBoolean);
          NodoQuery(tmpNode, Fields[0].AsInteger);
          Next;
        end;
      except
      end;

    finally
      Free;
    end;
  end;

  function FindNode(atext: string): TTreeNode;
  var
    j: integer;
  begin
    result := nil;
    for j := 0 to t^.Items.Count - 1 do
      if t^.Items[j].Text = atext then
      begin
        Result := t^.Items[j];
        Break;
      end;
  end;

begin
  t^.Items.Clear;
  Screen.Cursor := crSQLWait;
  qry := TFDQuery.create(nil);
  with qry do
  begin
    Active := False;
    Connection := conn;
    SQL.Clear;
    if not ShowAll then
      SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible FROM tb_tree  where aowner=' + QuotedStr('system') + ' and visible=true order by etiqueta asc')
    else
      SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible FROM tb_tree  where aowner=' + QuotedStr('system') + ' order by etiqueta asc');
    try
      Active := True;
      First;
      while not Eof do
      begin
        ndopadre := t.Items.Add(nil, FieldByName('etiqueta').AsString);
        AgregaData(ndopadre, Fields[0].AsInteger, Fields[2].AsInteger, Fields[3].AsInteger, Fields[1].AsString, Fields[4].AsBoolean);
        NodoQuery(ndopadre, Fields[0].AsInteger);
        Next;
      end;
    except
      on E: EDatabaseError do
      begin
        ShowMessage(E.Message);
      end;
    end;
  end;
  Screen.Cursor := crDefault;
end;

function TUDM.VarToInt(const AVariant: Variant): integer;
begin
  Result := StrToIntDef(Trim(VarToStr(AVariant)), 0);
end;

procedure TUDM.VarVirt;
begin
  if UDM.tb_SerieDatosVar.recordcount = 0 then
    UDM.tb_VirtualVar.Append;
end;

procedure TUDM.VerPDFF(aFileName: string);

  function WinExecAndWait32(FileName: string; Visibility: integer): integer;
  var
    zAppName: array[0..512] of char;
    zCurDir: array[0..255] of char;
    WorkDir: string;
    StartupInfo: TStartupInfo;
    ProcessInfo: TProcessInformation;
    Resultado, exitCode: DWord;
    kk: DWord;
  begin
    StrPCopy(zAppName, FileName);
    GetDir(0, WorkDir);
    StrPCopy(zCurDir, WorkDir);
    FillChar(StartupInfo, Sizeof(StartupInfo), #0);
    StartupInfo.cb := Sizeof(StartupInfo);
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := Visibility;
    CreateProcess(nil, zAppName, nil, nil, false, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo);
    GetExitCodeProcess(ProcessInfo.hProcess, Resultado);
    MessageBeep(0);
    CloseHandle(ProcessInfo.hProcess);
    Result := Resultado;
  end;

var
  s, s1, s2: string;
begin
  s := ExtractFilePath(Application.ExeName) + 'foxit.exe '; //'SumatraPDF\SumatraPDF.exe ' ;
  s1 := aFileName;
  s2 := Concat(s, '"' + s1 + '"');
  WinExecAndWait32(s2, SW_HIDE);
end;

function TUDM.ViewIMG(FilePath: string): Integer;
var
  cmd: string;
  fp: string;
begin
  cmd := ExtractFilePath(Application.ExeName) + '\JPEGViewPortable\JPEGViewPortable.exe ';
  fp := AnsiQuotedStr(FilePath, '"');
  cmd := cmd + fp;
  Result := WinExecAndWait32(cmd, SW_SHOWNORMAL);
end;

function TUDM.ViewPDF(FilePath: string): Integer;
var
  cmd: string;
  fp: string;
begin
  cmd := ExtractFilePath(Application.ExeName) + 'Foxit.exe ';
  fp := AnsiQuotedStr(FilePath, '"');
  cmd := cmd + fp;
  Result := WinExecAndWait32(cmd, SW_SHOWNORMAL);
end;

procedure TUDM.Visualiza(conn: TFDConnection; IdNodo: string; V: boolean);
var
  qry: TFDQuery;

  procedure NodoQuery(IdPadre: integer);
  begin
    with TFDQuery.Create(nil) do
    try
      Connection := conn;
      SQL.Clear;
      SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible FROM tb_tree  where Padre=' + IntToStr(IdPadre) + ' order by etiqueta');
      try
        Active := True;
        while not Eof do
        begin
          if tb_tree.Locate('id', Fields[0].AsString, []) then
          begin
            tb_tree.Edit;
            tb_tree.FieldByName('visible').AsBoolean := V;
            if V then
            begin
              if tb_tree.FieldByName('icono').AsInteger < 7 then

              else
                tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger - 7;
            end
            else
            begin
              if tb_tree.FieldByName('icono').AsInteger < 7 then
                tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger + 7;
            end;
            try
              tb_tree.Post;
              NodoQuery(Fields[0].AsInteger);
            except
            end;
          end;
          Next;
        end;
      except
      end;

    finally
      Free;
    end;
  end;

begin
  Screen.Cursor := crSQLWait;
  if tb_tree.Locate('id', IdNodo, []) then
  begin
    tb_tree.Edit;
    tb_tree.FieldByName('visible').AsBoolean := V;
    if V then
    begin
      if tb_tree.FieldByName('icono').AsInteger < 7 then

      else
        tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger - 7;
    end
    else
    begin
      if tb_tree.FieldByName('icono').AsInteger < 7 then
        tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger + 7;
    end;
    try
      tb_tree.Post;
      //recursivo...
      qry := TFDQuery.create(nil);
      with qry do
      begin
        Active := False;
        Connection := conn;
        SQL.Clear;
        SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible FROM tb_tree  where padre=' + IdNodo + ' order by etiqueta asc');
        try
          Active := True;
          First;
          while not Eof do
          begin
            if tb_tree.Locate('id', Fields[0].AsString, []) then
            begin
              tb_tree.Edit;
              tb_tree.FieldByName('visible').AsBoolean := V;
              if V then
              begin
                if tb_tree.FieldByName('icono').AsInteger < 7 then

                else
                  tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger - 7;
              end
              else
              begin
                if tb_tree.FieldByName('icono').AsInteger < 7 then
                  tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger + 7;
              end;
              try
                tb_tree.Post;
                NodoQuery(Fields[0].AsInteger);
              except
              end;
            end;
            Next;
          end;
        except
          on E: EDatabaseError do
          begin
            ShowMessage(E.Message);
          end;
        end;
      end;
    except
      on E: EFDException do
      begin
        MessageDlg('' + E.Message, mtError, [mbOK], 0);
        Exit;
      end;
    end;

  end;
  Screen.Cursor := crDefault;
end;

procedure TUDM.VisualizaOneNodeAndParent(conn: TFDConnection; IdNodo: string; V: boolean);
begin
//
  if tb_tree.Locate('id', IdNodo, []) then
  begin
    tb_tree.Edit;
    tb_tree.FieldByName('visible').AsBoolean := V;
    if V then
    begin
      if tb_tree.FieldByName('icono').AsInteger < 7 then

      else
        tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger - 7;
    end
    else
    begin
      if tb_tree.FieldByName('icono').AsInteger < 7 then
        tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger + 7;
    end;
    try
      tb_tree.Post;
      if V then
      begin
        while trim(tb_tree.FieldByName('Padre').AsString) <> '' do
        begin
          tb_tree.Edit;
          tb_tree.FieldByName('visible').AsBoolean := V;
          if V then
          begin
            if tb_tree.FieldByName('icono').AsInteger < 7 then

            else
              tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger - 7;
          end
          else
          begin
            if tb_tree.FieldByName('icono').AsInteger < 7 then
              tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger + 7;
          end;
          try
            tb_tree.Post;
            tb_tree.Locate('id', tb_tree.FieldByName('Padre').AsString, [])
          except

          end;
        end;
        tb_tree.Edit;
        tb_tree.FieldByName('visible').AsBoolean := V;
        if V then
        begin
          if tb_tree.FieldByName('icono').AsInteger < 7 then

          else
            tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger - 7;
        end
        else
        begin
          if tb_tree.FieldByName('icono').AsInteger < 7 then
            tb_tree.FieldByName('icono').AsInteger := tb_tree.FieldByName('icono').AsInteger + 7;
        end;
        try
          tb_tree.Post;
        except
        end;
      end
      else
      begin
        Visualiza(conn, IdNodo, False);
      end;
    except

    end;
  end;
end;

function TUDM.WinExecAndWait32(FileName: string; Visibility: integer): integer;
var
  zAppName: array[0..512] of char;
  zCurDir: array[0..255] of char;
  WorkDir: string;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Resultado, exitCode: DWord;
begin
  StrPCopy(zAppName, FileName);
  GetDir(0, WorkDir);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  CreateProcess(nil, zAppName,                      { pointer to command line string }
    nil,                           { pointer to process security attributes}
    nil,                           { pointer to thread security attributes}
    false,                         { handle inheritance flag }
    CREATE_NEW_CONSOLE or          { creation flags }
    NORMAL_PRIORITY_CLASS, nil,                           { pointer to new environment block }
    nil,                           { pointer to current directory name }
    StartupInfo,                   { pointer to STARTUPINFO }
    ProcessInfo);

  {Espera a que termine la ejecucion}
  {Wait until execution finish}
  repeat
    exitCode := WaitForSingleObject(ProcessInfo.hProcess, 1000);
    Application.ProcessMessages;
  until (exitCode <> WAIT_TIMEOUT);
  GetExitCodeProcess(ProcessInfo.hProcess, Resultado);
  MessageBeep(0);
  CloseHandle(ProcessInfo.hProcess);
  Result := Resultado;
end;

procedure TUDM.Inserta(aidObjeto, acodigoHijo, acodigoPadre, aicon: Integer; aetiq, NombreEntidad, aKeyDef, aKeyVal: string);
begin
  tb_tree.Append;
  tb_tree.FieldByName('id').AsInteger := aidObjeto;
  tb_tree.FieldByName('codigo').AsInteger := acodigoHijo;
  tb_tree.FieldByName('padre').AsInteger := acodigoPadre;
  tb_tree.FieldByName('etiqueta').AsString := aetiq;
  tb_tree.FieldByName('icono').AsInteger := aicon;
  tb_tree.FieldByName('nombreentidad').AsString := NombreEntidad;
  tb_tree.FieldByName('keydef').AsString := aKeyDef;
  tb_tree.FieldByName('keyvalue').AsString := aKeyVal;
  try
    tb_tree.Post;
  except
    on E: Exception do
    begin
      sms('No se pudo crear correctamente el organigrama empresarial. Motivo: ' + E.Message, 1);
      tb_tree.Cancel;
    end;
  end;
end;

function TUDM.KillProcess(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure TUDM.ManagementHLP(HLPName: string; WindowsHandle: HWND);
var
  PathHLP: string;
begin
  PathHLP := ExtractFilePath(Application.ExeName) + 'HLP\';
  if not FileExists(PathHLP + HLPName + '.docx') then
    CopyFile(PWideChar(PathHLP + 'plt.docx'), PWideChar(PathHLP + HLPName + '.docx'), False);
  ejecutaPDF(WindowsHandle, PathHLP + HLPName + '.docx');
end;

procedure TUDM.RestauraGrid(nombregrid: TcxGridDBTableView; NombreSalva: string);
var
  i, j: integer;
  l: Tstringlist;
begin
  if FileExists(PathTemp + NombreSalva + '.tbl') then
  begin
    l := Tstringlist.create;
    with l do
    try
      loadfromfile(PathTemp + NombreSalva + '.tbl');
      i := 0;
      j := 0;
      for j := 0 to nombregrid.ColumnCount - 1 do
      begin
        nombregrid.Columns[j].DataBinding.FieldName := l.strings[i];
        nombregrid.Columns[j].Width := strtoint(l.strings[i + 1]);
        nombregrid.Columns[j].Visible := strtobool(l.strings[i + 2]);
        //nombregrid.Columns[j].Caption:=l.Strings[i+3];
        i := i + 3;
      end;
    finally
      l.free;
    end;

  end;

end;

procedure TUDM.RunAndWaitShell(Ejecutable, Argumentos: string; Visibilidad: integer);
var
  Info: TShellExecuteInfo;
  pInfo: PShellExecuteInfo;
  exitCode: DWord;
begin
      {Puntero a Info}
      {Pointer to Info}
  pInfo := @Info;
      {Rellenamos Info}
      {Fill info}
  with Info do
  begin
    cbSize := SizeOf(Info);
    fMask := SEE_MASK_NOCLOSEPROCESS;
    wnd := Application.Handle;
    lpVerb := nil;
    lpFile := PChar(Ejecutable);
       {Parametros al ejecutable}
       {Executable parameters}
    lpParameters := Pchar(Argumentos + #0);
    lpDirectory := nil;
    nShow := Visibilidad;
    hInstApp := 0;
  end;
      {Ejecutamos}
      {Execute}
  ShellExecuteEx(pInfo);
      {Esperamos que termine}
      {Wait to finish}
  repeat
    exitCode := WaitForSingleObject(Info.hProcess, 500);
    Application.ProcessMessages;
  until (exitCode <> WAIT_TIMEOUT);
end;

procedure TUDM.SalvaConfigGrid(nombregrid: TcxGridDBTableView; NombreSalva: string);
var
  i: integer;
begin
  with Tstringlist.create do
  try
    for i := 0 to nombregrid.ColumnCount - 1 do
    begin
      add(nombregrid.Columns[i].DataBinding.FieldName);
      add(inttostr(nombregrid.Columns[i].Width));
      add(booltostr(nombregrid.Columns[i].visible));
      //add(nombregrid.Columns[i].Caption);
    end;
    savetofile(PathTemp + NombreSalva + '.tbl');
  finally
    free;
  end;
end;

function TUDM.sms(aText: string; aTipo: Integer): integer;
begin
  case aTipo of
    1:
      begin
        result := Application.MessageBox(PChar(aText), PChar('¡Error!'), MB_ICONINFORMATION);
       // result := Application.MessageBox(PChar(aText), PChar('¡Error!'), MB_OK + MB_ICONERROR + MB_DEFBUTTON1 + MB_APPLMODAL+MB_SYSTEMMODAL);
      end;
    2:
      begin
        result := MessageBox(Application.Handle, PChar(aText), PChar('¡Alerta!'), MB_OK + MB_ICONEXCLAMATION + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
    3:
      begin
        result := MessageBox(Application.Handle, PChar(aText), PChar('¡Información!'), MB_OK + MB_ICONINFORMATION + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
    4:
      begin
        result := Application.MessageBox(PChar(aText), PChar('¡Confirmación!'), MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
  end;
end;

function TUDM.Sto_GetFmtFileVersion(const FileName, Fmt: string): string;
var
  sFileName: string;
  iBufferSize: DWORD;
  iDummy: DWORD;
  pBuffer: Pointer;
  pFileInfo: Pointer;
  iVer: array[1..4] of Word;
begin
  // set default value
  Result := '';
  // get filename of exe/dll if no filename is specified
  sFileName := Trim(FileName);
  if (sFileName = '') then
    sFileName := GetModuleName(HInstance);
  // get size of version info (0 if no version info exists)
  iBufferSize := GetFileVersionInfoSize(PChar(sFileName), iDummy);
  if (iBufferSize > 0) then
  begin
    GetMem(pBuffer, iBufferSize);
    try
    // get fixed file info (language independent)
      GetFileVersionInfo(PChar(sFileName), 0, iBufferSize, pBuffer);
      VerQueryValue(pBuffer, '\', pFileInfo, iDummy);
    // read version blocks
      iVer[1] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
      iVer[2] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
      iVer[3] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
      iVer[4] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
    finally
      FreeMem(pBuffer);
    end;
    // format result string
    Result := Format(Fmt, [iVer[1], iVer[2], iVer[3], iVer[4]]);
  end;
end;

procedure TUDM.ActivaDataLayer(aValue: boolean);
begin
  //Activando tablas de la base de datos....
  cl_tipoexp.Active := aValue;
  cl_expediente.Active := aValue;
  CL_ArchivoDpto.Active := aValue;
  CL_ArchivoDpto.FetchAll;
  cl_tipoobj.Active := aValue;
  cl_tipoobj.FetchAll;
  cl_acceso.Active := aValue;
  cl_acceso.FetchAll;
  cl_ArchivosGestion.Active := aValue;
  cl_deposito.Active := aValue;
  cl_tipodoc.Active := aValue;
  cl_especialista.Active := aValue;
  cl_destino.Active := aValue;
  cl_frecuencia.Active := aValue;
  cl_facultadesgen.Active := aValue;
  cl_funcionesgen.Active := aValue;
  cl_cargo.Active := aValue;
  cl_series.Active := aValue;
  cl_soporte.Active := aValue;
  cl_subseries.Active := aValue;
  cl_tipodoc.Active := aValue;
  cl_Resp_Gest_Arch.Active := aValue;
  cl_ftp_Server.Active := aValue;
  cl_tipoestructura.Active := aValue;
  cl_tiposerie.Active := aValue;
  cl_tipoarch.Active := aValue;
  cl_VarProject.Active := aValue;
  cl_categoria_ocupacional.Active := aValue;
  cl_variables.Active := aValue;
  cl_VarSubserie.Active := aValue;
  cl_valordoc.Active := aValue;
  cl_vigencia.Active := aValue;
  AllFather.Active := aValue;
  CL_Nodos.Active := aValue;
  cl_nodopadre.Active := aValue;
  tb_ext.Active := aValue;
  tb_EstructDisp.Active := aValue;
  tb_tree.Active := aValue;
  tb_VirtVarDataEstruct.Active := aValue;
  tb_Serietree.Active := aValue;
  tb_Serietree.FetchAll;
  tb_SeriesDatos.Active := aValue;
  tb_ssArchdigital.Active := aValue;
  tb_DocCoord.Active := aValue;
  tb_DocCoord.FetchAll;
  tb_SerieDatosVar.Active := aValue;
  //usuarios y Rol
  Tb_Rol.Active := aValue;
  //Tb_User.Active := aValue;
  tcl_procesosGrupos.Active := aValue;
  tcl_Procesos.Active := aValue;
  tcl_ProcesoSubproceso.Active := aValue;
  tb_mp.Active := aValue;
  qryAnexosDig.Active := aValue;
  qryAnexosDig.FetchAll;
  qryFuentesDig.Active := aValue;
  qryFuentesDig.FetchAll;
end;

procedure TUDM.tb_SeriesDatosBeforeDelete(DataSet: TDataSet);
begin
{  if UDM.sms('¿Realmente desea eliminar el registro seleccionado?', 4) <> 6 then
    DataSet.Cancel;      }
end;

procedure TUDM.tb_SeriesDatosNewRecord(DataSet: TDataSet);
begin
 { if (trim(UDM.tb_Serietree.FieldByName('carpeta').AsString)='')or (UDM.tb_Serietree.FieldByName('carpeta').Value=null) then
  begin
    UDM.sms('No ha especificado una ruta válida para almacenar los ficheros de subseries documentales para la estructura actual.', 2);
    DataSet.Cancel;
    Exit;
  end;}
  if (trim(UDM.tb_Serietree.FieldByName('Idservidor').AsString) = '') or (UDM.tb_Serietree.FieldByName('Idservidor').Value = null) or (UDM.tb_Serietree.FieldByName('Idservidor').AsString = '0') then
  begin
    UDM.sms('No ha especificado una ruta válida para almacenar los ficheros de subseries documentales para la estructura actual.', 2);
    UDM.sms('Por favor especifique un servidor o repositorio válido para almacenar la información especificada.', 3);
    DataSet.Cancel;
    Exit;
  end;
  DataSet.FieldByName('idservidor').AsInteger := UDM.tb_Serietree.FieldByName('idservidor').AsInteger;
  DataSet.FieldByName('deposito').AsString := UDM.tb_Serietree.FieldByName('deposito').AsString;
  DataSet.FieldByName('gaveta').AsString := UDM.tb_Serietree.FieldByName('gaveta').AsString;
  DataSet.FieldByName('Archivo').AsString := UDM.tb_Serietree.FieldByName('Archivo').AsString;
  DataSet.FieldByName('gestor').AsString := UDM.tb_Serietree.FieldByName('gestor').AsString;
end;

procedure TUDM.tb_SerietreePostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
begin
  UDM.sms('No se pudieron guardar los cambios realizados. Motivo: ' + E.Message, 1);
end;

procedure TUDM.tb_treeAfterPost(DataSet: TDataSet);
begin
  AllFather.Active := False;
  AllFather.Active := True;
  CL_Nodos.Active := False;
  cl_nodopadre.Active := False;
  cl_nodopadre.Active := True;
  CL_Nodos.Active := True;
end;

procedure TUDM.UpDateDB;

  function execSQLUPD(ascript: string): Boolean;
  begin
    Result := False;
    try
      conn.ExecSQL(ascript);
      Result := True;
    except
      result := False;
    end;
  end;

var
  cad: string;
begin    //fuente varchar(1)
  execSQLUPD('ALTER TABLE cl_Resp_Gest_Arch ADD COLUMN habilitado varchar(1)');
  execSQLUPD('ALTER TABLE cl_subseries ADD COLUMN fechaaprov date');
  execSQLUPD('ALTER TABLE cl_subseries ADD COLUMN idtiposerie int');
  execSQLUPD('ALTER TABLE cl_expediente ALTER COLUMN IDExpediente varchar(12)');
  execSQLUPD('ALTER TABLE tb_SeriesDatos ALTER COLUMN IDExpediente varchar(12)');
  execSQLUPD('UPDATE cl_series SET cl_series.serie = LTrim(RTrim(cl_Series.serie))');
  execSQLUPD('UPDATE cl_subseries SET cl_subseries.subserie = LTrim(RTrim(cl_subseries.subserie))');
  execSQLUPD('UPDATE tb_tree SET tb_tree.etiqueta = LTrim(RTrim(tb_tree.etiqueta))');
  execSQLUPD('UPDATE cl_subseries SET cl_subseries.activa = true');
  execSQLUPD('CREATE VIEW V_EtiquetaID AS SELECT id, etiqueta FROM tb_tree');
  cad := 'CREATE TABLE tb_VirtVarDataEstruct (IdEstructura VARCHAR (50) NOT NULL, ';
  cad := cad + 'id INTEGER, Orden INTEGER, IdVar SMALLINT, VarInteger INTEGER, VarDouble ';
  cad := cad + 'REAL, VarDate TIMESTAMP,	VarString255 VARCHAR (255),	VarMemo TEXT,	CONSTRAINT ';
  cad := cad + 'tb_VirtVarDataEstructPK PRIMARY KEY (IdEstructura, id, Orden, IdVar), ';
  cad := cad + 'CONSTRAINT FK_tb_treevardata FOREIGN KEY (IdEstructura,id) REFERENCES tb_tree (IdEstructura,id))';
  execSQLUPD(cad);
  cad := 'INSERT INTO cl_Resp_Gest_Arch(Idresp, NombreResponsable, usuario, CorreoElect, Rol, Telefono, password, habilitado) ';
  cad := cad + 'VALUES(0, ' + QuotedStr('Administrador del Sistema EMSERGO SGD') + ', ' + QuotedStr('administrador') + ', ';
  cad := cad + QuotedStr('crosales@nauta.cu') + ', 1, ' + QuotedStr('50926970') + ', ' + QuotedStr('dd46685659a8cbe9779bc361e6d9ae47') + ', ' + QuotedStr('S') + ')';
  execSQLUPD(cad);
  cad := 'create table cl_tipoexp(IdTipoExp int primary key, NombreTipoExp varchar(255))';
  execSQLUPD(cad);
  cad := 'create table cl_expediente(IDExpediente int primary key, Nombre varchar(255), IdTipoExp int, FechaInicio datetime, FechaCierre datetime, cerrado varchar(1), comentario memo)';
  execSQLUPD(cad);
  execSQLUPD('ALTER TABLE cl_Resp_Gest_Arch ADD COLUMN habilitado varchar(1)');
  execSQLUPD('ALTER TABLE tb_SeriesDatos ADD COLUMN IDExpediente int');
  execSQLUPD('ALTER TABLE tb_SeriesDatos ADD COLUMN namefile varchar(255)');
  cad := 'CREATE TABLE tb_ssArchdigital(IdEstructura varchar(50) NOT NULL, id int NOT NULL, codsubs varchar(50) ';
  cad := cad + 'NOT NULL, Fecha datetime NOT NULL, Version smallint NOT NULL, idhijo int NOT NULL, nombre varchar(255),Etiqueta varchar(50)';
  cad := cad + ' ext int, extnombre varchar(255), comentario varchar(255), urlraiz varchar(50), path varchar(255), ';
  cad := cad + 'tamano int, padre int, nivel smallint, CONSTRAINT PK_tb_SSArchDigital PRIMARY KEY(IdEstructura, id,  ';
  cad := cad + 'codsubs,  Fecha,  Version,  idhijo), CONSTRAINT  FK_SSDatos_SSArchDigital FOREIGN KEY (IdEstructura,  ';
  cad := cad + 'id,  codsubs,  Fecha,  Version) REFERENCES  tb_SeriesDatos(IdEstructura, id, codsubs, Fecha, Version))';    // ON DELETE CASCADE ON UPDATE CASCADE
  execSQLUPD(cad);
  execSQLUPD('ALTER TABLE tb_ssArchdigital ADD COLUMN fuente varchar(1)');
  execSQLUPD('ALTER TABLE tb_ssArchdigital ADD COLUMN etiqueta varchar(50)');
  execSQLUPD('CREATE TABLE tb_ext(id int NOT NULL, ext varchar(5) NOT NULL, CONSTRAINT tb_ext_pkey PRIMARY KEY (id, ext));');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.doc') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.docm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.docx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.dotm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.dotx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.mht') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.odt') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.rtf') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.txt') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.xml') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (1, ' + QuotedStr('.xps') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (2, ' + QuotedStr('.accd') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (2, ' + QuotedStr('.mdb') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr(' .mht') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.csv') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.dif') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.ods') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.prn') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.slk') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xla') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xlam') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xls') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xlsb') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xlsm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xlsx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xlt') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xltm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xltx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xml') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (3, ' + QuotedStr('.xps') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.emf') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.odp') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.png') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.pot') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.potm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.potx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.ppa') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.ppam') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.pps') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.ppsm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.ppsx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.ppt') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.pptm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.pptx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.thmx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.wmf') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.wmv') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (4, ' + QuotedStr('.xps') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (5, ' + QuotedStr('.dwg') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (6, ' + QuotedStr('.pdf') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (7, ' + QuotedStr('.srf') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (9, ' + QuotedStr('.dat') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (10, ' + QuotedStr('.log') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (11, ' + QuotedStr('.bat') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (12, ' + QuotedStr('.exe') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (13, ' + QuotedStr('.htm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (14, ' + QuotedStr('.bmp') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (15, ' + QuotedStr('.gif') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (16, ' + QuotedStr('.jpg') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (17, ' + QuotedStr('.jpeg') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (18, ' + QuotedStr('.html') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (19, ' + QuotedStr('.mp4') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (20, ' + QuotedStr('.psd') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (21, ' + QuotedStr('.rar') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (22, ' + QuotedStr('.shp') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (23, ' + QuotedStr('.swf') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (24, ' + QuotedStr('.tif') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (26, ' + QuotedStr('.wma') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (27, ' + QuotedStr('.zip') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (28, ' + QuotedStr('.3gp') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (29, ' + QuotedStr('.7z') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (30, ' + QuotedStr('.ace') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (31, ' + QuotedStr('.ai') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (32, ' + QuotedStr('.aif') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (33, ' + QuotedStr('.aiff') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (34, ' + QuotedStr('.amr') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (35, ' + QuotedStr('.asf') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (36, ' + QuotedStr('.asx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (37, ' + QuotedStr('.bin') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (38, ' + QuotedStr('.bup') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (39, ' + QuotedStr('.cab') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (40, ' + QuotedStr('.cbr') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (41, ' + QuotedStr('.cda') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (42, ' + QuotedStr('.cdl') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (43, ' + QuotedStr('.cdr') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (44, ' + QuotedStr('.chm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (45, ' + QuotedStr('.divx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (46, ' + QuotedStr('.dll') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (47, ' + QuotedStr('.dmg') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (48, ' + QuotedStr('.dss') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (49, ' + QuotedStr('.dvf') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (50, ' + QuotedStr('.eml') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (51, ' + QuotedStr('.eps') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (52, ' + QuotedStr('.fla') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (53, ' + QuotedStr('.flv') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (54, ' + QuotedStr('.gz') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (55, ' + QuotedStr('.hqx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (56, ' + QuotedStr('.ifo') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (57, ' + QuotedStr('.indd') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (58, ' + QuotedStr('.iso') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (59, ' + QuotedStr('.jar') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (60, ' + QuotedStr('.lnk') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (61, ' + QuotedStr('.m4a') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (62, ' + QuotedStr('.m4b') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (63, ' + QuotedStr('.m4p') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (64, ' + QuotedStr('.m4v') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (65, ' + QuotedStr('.mcd') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (66, ' + QuotedStr('.mid') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (67, ' + QuotedStr('.mov') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (68, ' + QuotedStr('.mp2') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (69, ' + QuotedStr('.mpeg') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (70, ' + QuotedStr('mpg') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (71, ' + QuotedStr('.msi') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (72, ' + QuotedStr('.mswm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (73, ' + QuotedStr('.ogg') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (74, ' + QuotedStr('.png') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (75, ' + QuotedStr('.ps') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (76, ' + QuotedStr('.pst') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (77, ' + QuotedStr('.pub') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (78, ' + QuotedStr('.ptb') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (79, ' + QuotedStr('.qbb') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (80, ' + QuotedStr('.qbw') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (81, ' + QuotedStr('.qxd') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (82, ' + QuotedStr('.ram') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (83, ' + QuotedStr('.rm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (84, ' + QuotedStr('.rmvb') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (86, ' + QuotedStr('.sea') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (87, ' + QuotedStr('.ses') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (88, ' + QuotedStr('.sit') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (89, ' + QuotedStr('.sitx') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (90, ' + QuotedStr('.ss') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (91, ' + QuotedStr('.tgz') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (92, ' + QuotedStr('.thm') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (93, ' + QuotedStr('.tmp') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (94, ' + QuotedStr('.torr') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (95, ' + QuotedStr('.ttf') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (96, ' + QuotedStr('.vcd') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (97, ' + QuotedStr('.vob') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (98, ' + QuotedStr('.wav') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (99, ' + QuotedStr('.wmv') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (100, ' + QuotedStr('.wps') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (101, ' + QuotedStr('.xpi') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (102, ' + QuotedStr('.db') + ');');
  execSQLUPD('INSERT INTO tb_ext(id, ext)VALUES (104, ' + QuotedStr('.mp3') + ');');
  execSQLUPD('DELETE FROM cl_frecuencia WHERE idfrecuencia=8;');
  execSQLUPD('DELETE FROM cl_frecuencia WHERE idfrecuencia=9;');
  execSQLUPD('INSERT INTO cl_frecuencia(Idfrecuencia, NombreFrecuencia)VALUES (8, ' + QuotedStr('Semestral') + ');');
  execSQLUPD('INSERT INTO cl_frecuencia(Idfrecuencia, NombreFrecuencia)VALUES (9, ' + QuotedStr('') + ');');
  execSQLUPD('DROP TABLE cl_tiposerie');
  execSQLUPD('CREATE TABLE cl_tiposerie(idtiposerie int NOT NULL PRIMARY KEY, tiposerie varchar(50), espacial varchar(1));');
  execSQLUPD('INSERT INTO cl_tiposerie(idtiposerie, tiposerie, espacial) VALUES(1, ' + QuotedStr('Documento') + ', '+ QuotedStr('N')+');');
  execSQLUPD('INSERT INTO cl_tiposerie(idtiposerie, tiposerie, espacial) VALUES(2, ' + QuotedStr('Documento Espacial') + ', '+ QuotedStr('S')+');');
  execSQLUPD('INSERT INTO cl_tiposerie(idtiposerie, tiposerie, espacial) VALUES(3, ' + QuotedStr('Expediente') + ', '+ QuotedStr('N')+');');
  execSQLUPD('INSERT INTO cl_tiposerie(idtiposerie, tiposerie, espacial) VALUES(4, ' + QuotedStr('Expediente Espacial') + ', '+ QuotedStr('S')+');');
end;

procedure TUDM.UpdateVarPrj(acodEE, acodNN: string);
var
  cad: string;
begin
  {cad:='SELECT cl_variables.IdVar,	cl_variables.NomVariable,	cl_variables.Etiqueta, cl_variables.tipo,	';
  cad:=cad+'cl_variables.longitud, cl_variables.descripcion, cl_variables.ListaDesplegable FROM cl_variables';
  cad:=cad+' WHERE (((cl_variables.IdVar) NOT IN ( SELECT IdVar FROM cl_VarProject  WHERE IdEstructura ='+QuotedStr(acodEE)+' and id='+acodNN+')));';  }
  with UDM.VarDispPrj do
  begin
    Active := False;
    Params[0].Value := acodEE;
    Params[1].Value := acodNN;
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo cargar el listado de variables disponibles. Motivo: ' + E.Message, 1);
        Exit;
      end;
    end;
  end;
end;

procedure TUDM.UpdateVarSubS(acod: string);
begin
  with UDM.VarDispSubS do
  begin
    Active := False;
    Params[0].Value := acod;
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo cargar el listado de variables disponibles. Motivo: ' + E.Message, 1);
        Exit;
      end;
    end;
  end;
end;

end.

