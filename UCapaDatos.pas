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
  cxGrid, Winapi.TlHelp32, Winapi.ShlObj, Masks, Vcl.Forms, FireDAC.VCLUI.Script,
  System.HelpIntfs, Vcl.HtmlHelpViewer, Vcl.AppEvnts, Winapi.Messages, ADOInt,
  ActiveX, Winapi.OleDB, ComObj, WinInet, winsock, frxClass, frxADOComponents,
  JvCaptionPanel, Vcl.Themes, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef,
  strutils, FireDAC.Stan.StorageXML, IdGlobal, IdFTPList, IdException,
  Vcl.Samples.Gauges, IdFTPCommon, System.Zip, System.IOUtils, USysConfig,
  IdHash, IdHashMessageDigest, Vcl.ExtCtrls, frxDBSet, cxDBVGrid, DateUtils,
  System.RegularExpressions, System.IniFiles, frxRich, UMainForm, frxOLE,
  frxCross, frxDMPExport, frxExportImage, frxExportRTF, frxExportXML,
  frxExportHTML, frxGZip, frxExportPDF, frxChBox, frxExportText, frxExportCSV,
  frxExportMail, frxCrypt, frxExportODF, frxPrinter, frxExportHTMLDiv,
  frxExportXLSX, frxExportPPTX, frxExportDOCX, frxExportBIFF, frxChart,
  frxExportSVG, frxTableObject, frxMap, frxExportHelpers, frxExportBaseDialog,
  frxCellularTextObject, frxExportPPML, frxExportPS, frxExportZPL,
  frxSaveFilterFRX, frxHTML, frxPDFViewer, UAlcance;

const
  // Lista completa de palabras reservadas para SQL Server
  SQLServerReservadas: array[0..225] of string = ('ADD', 'ALL', 'ALTER', 'AND', 'ANY', 'AS', 'ASC', 'AUTHORIZATION', 'BACKUP', 'BEGIN', 'BETWEEN', 'BREAK', 'BROWSE', 'BULK', 'BY', 'CASCADE', 'CASE', 'CHECK', 'CLOSE', 'CLUSTERED', 'COALESCE', 'COLLATE', 'COLUMN', 'COMMIT', 'COMPUTE', 'CONSTRAINT', 'CONTAINS', 'CONTAINSTABLE', 'CONTINUE', 'CONVERT', 'CREATE', 'CROSS', 'CURRENT', 'CURRENT_DATE', 'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_USER', 'CURSOR', 'DATABASE', 'DBCC', 'DEALLOCATE', 'DECLARE',
    'DEFAULT', 'DELETE', 'DENY', 'DESC', 'DISK', 'DISTINCT', 'DISTRIBUTED', 'DOUBLE', 'DROP', 'DUMP', 'ELSE', 'END', 'ERRLVL', 'ESCAPE', 'EXCEPT', 'EXEC', 'EXECUTE', 'EXISTS', 'EXIT', 'EXTERNAL', 'FETCH', 'FILE', 'FILLFACTOR', 'FOR', 'FOREIGN', 'FREETEXT', 'FREETEXTTABLE', 'FROM', 'FULL', 'FUNCTION', 'GOTO', 'GRANT', 'GROUP', 'HAVING', 'HOLDLOCK', 'IDENTITY', 'IDENTITY_INSERT', 'IDENTITYCOL', 'IF', 'IN', 'INDEX', 'INNER', 'INSERT', 'INTERSECT', 'INTO', 'IS', 'JOIN', 'KEY', 'KILL', 'LEFT', 'LIKE', 'LINENO',
    'LOAD', 'MERGE', 'NATIONAL', 'NOCHECK', 'NONCLUSTERED', 'NOT', 'NULL', 'NULLIF', 'OF', 'OFF', 'OFFSETS', 'ON', 'OPEN', 'OPENDATASOURCE', 'OPENQUERY', 'OPENROWSET', 'OPENXML', 'OPTION', 'OR', 'ORDER', 'OUTER', 'OVER', 'PERCENT', 'PIVOT', 'PLAN', 'PRIMARY', 'PRINT', 'PROC', 'PROCEDURE', 'PUBLIC', 'RAISERROR', 'READ', 'READTEXT', 'RECONFIGURE', 'REFERENCES', 'REPLICATION', 'RESTORE', 'RESTRICT', 'RETURN', 'REVERT', 'REVOKE', 'RIGHT', 'ROLLBACK', 'ROWCOUNT', 'ROWGUIDCOL', 'RULE', 'SAVE', 'SCHEMA',
    'SECURITYAUDIT', 'SELECT', 'SEMANTICKEYPHRASETABLE', 'SEMANTICSIMILARITYDETAILSTABLE', 'SEMANTICSIMILARITYTABLE', 'SESSION_USER', 'SET', 'SETUSER', 'SHUTDOWN', 'SOME', 'STATISTICS', 'SYSTEM_USER', 'TABLE', 'TABLESAMPLE', 'TEXTSIZE', 'THEN', 'TO', 'TOP', 'TRAN', 'TRANSACTION', 'TRIGGER', 'TRUNCATE', 'TRY_CONVERT', 'TSEQUAL', 'UNION', 'UNIQUE', 'UNPIVOT', 'UPDATE', 'UPDATETEXT', 'USE', 'USER', 'VALUES', 'VARYING', 'VIEW', 'WAITFOR', 'WHEN', 'WHERE', 'WHILE', 'WITH', 'WITHIN GROUP', 'WRITETEXT', 'BIGINT',
    'BINARY', 'BIT', 'CHAR', 'DATE', 'DATETIME', 'DATETIME2', 'DATETIMEOFFSET', 'DECIMAL', 'FLOAT', 'GEOGRAPHY', 'GEOMETRY', 'HIERARCHYID', 'IMAGE', 'INT', 'MONEY', 'NCHAR', 'NTEXT', 'NUMERIC', 'NVARCHAR', 'REAL', 'ROWVERSION', 'SMALLDATETIME', 'SMALLINT', 'SMALLMONEY', 'SQL_VARIANT', 'TEXT', 'TIME', 'TIMESTAMP', 'TINYINT', 'UNIQUEIDENTIFIER', 'VARBINARY', 'VARCHAR', 'XML', 'IDESTRUCTURA', 'ID', 'CODSUBS', 'FECHA', 'VERSION', 'CODIGODOC', 'YEAR', 'MONTH', 'DAY');

  // Lista completa de palabras reservadas para MS Access
  AccessReservadas: array[0..90] of string = ('ADD', 'ALL', 'ALTER', 'AND', 'ANY', 'AS', 'ASC', 'AUTOINCREMENT', 'BETWEEN', 'BY', 'CHAR', 'COLUMN', 'CONSTRAINT', 'COUNT', 'COUNTER', 'CREATE', 'CURRENCY', 'DATABASE', 'DATE', 'DATETIME', 'DELETE', 'DESC', 'DISTINCT', 'DISTINCTROW', 'DROP', 'ELSE', 'END', 'EXISTS', 'FLOAT', 'FOR', 'FOREIGN', 'FROM', 'GENERAL', 'GROUP', 'HAVING', 'INNER', 'INSERT', 'INT', 'INTEGER', 'INTO', 'IS', 'JOIN', 'KEY', 'LEFT', 'LEVEL', 'LIKE', 'LONG', 'MEMO', 'MOD', 'MONEY', 'NOT',
    'NULL', 'NUMBER', 'OLEOBJECT', 'ON', 'OR', 'ORDER', 'OUTER', 'OWNERACCESS', 'PARAMETER', 'PERCENT', 'PIVOT', 'PRIMARY', 'PROCEDURE', 'REAL', 'REFERENCES', 'RIGHT', 'SELECT', 'SET', 'SHORT', 'SINGLE', 'SMALLINT', 'STDEV', 'SUM', 'TABLE', 'TEXT', 'TOP', 'TRANSFORM', 'UPDATE', 'VALUE', 'WHERE', 'YESNO', 'IDESTRUCTURA', 'ID', 'CODSUBS', 'FECHA', 'VERSION', 'CODIGODOC', 'YEAR', 'MONTH', 'DAY');

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

  TDatosPC = record
    Nombre, IP, Usuario: string;
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
    estruct: string;
    Id: Integer;
    Etiqueta: string;
    Padre: Integer;
    Icono: Integer;
    Owner: string;
    Tipo: string;
    Descrip: string;
  end;

  PArbol = ^TTreeview;

  PArbolDB = ^tdxdbtreeview;

  PBarra = ^TGauge;

  Tpdatasource = ^Tdatasource;

  TDatabaseType = (dbAccess, dbSQLServer);

  TUDM = class(TDataModule)
    Conn: TFDConnection;
    FDM: TFDManager;
    WaitCursor: TFDGUIxWaitCursor;
    dstb_Serietree: TDataSource;
    ILEdith: TImageList;
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
    cl_ArchivosGestion: TFDQuery;
    dscl_ArchivosGestion: TDataSource;
    dsTb_SeriesDispo: TDataSource;
    Tb_SeriesDispo: TFDQuery;
    dscl_especialista: TDataSource;
    cl_especialista: TFDQuery;
    IdFTP1: TIdFTP;
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
    cl_vigencia: TFDQuery;
    dscl_vigencia: TDataSource;
    dsSudSDetail: TDataSource;
    SudSDetail: TFDQuery;
    dsCL_ArchivoDpto: TDataSource;
    CL_ArchivoDpto: TFDQuery;
    CMD: TFDQuery;
    MSAccessDriver: TFDPhysMSAccessDriverLink;
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
    ILClasif: TImageList;
    dstb_sysconfig: TDataSource;
    tb_sysconfig: TFDQuery;
    ListadoServidores: TFDMemTable;
    ListadoServidoresIdServer: TStringField;
    ListadoServidoresNombreServer: TStringField;
    dsListadoServidores: TDataSource;
    dstb_log: TDataSource;
    tb_log: TFDQuery;
    frxMain: TfrxReport;
    frxADOComponents1: TfrxADOComponents;
    dstb_accionlog: TDataSource;
    tb_accionlog: TFDQuery;
    dstb_transferencia: TDataSource;
    tb_transferencia: TFDQuery;
    dsCodExpediente: TDataSource;
    CodExpediente: TFDQuery;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    tb_indice: TFDQuery;
    dstb_indice: TDataSource;
    tb_expxseries: TFDQuery;
    dstb_expxseries: TDataSource;
    FDStanStorageXMLLink1: TFDStanStorageXMLLink;
    cmdorig: TFDQuery;
    cmddest: TFDQuery;
    cmdServer: TFDQuery;
    dscmdServer: TDataSource;
    ServidoresDisponibles: TFDQuery;
    dsServidoresDisponibles: TDataSource;
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
    Timer1: TTimer;
    ImageList3: TImageList;
    dstb_arbol: TDataSource;
    tb_arbol: TFDQuery;
    dscl_VarSubserie: TDataSource;
    cl_VarSubserie: TFDQuery;
    dsCL_SubseriesTipoVar: TDataSource;
    CL_SubseriesTipoVar: TFDQuery;
    dsAllSubSerie: TDataSource;
    AllSubSerie: TFDQuery;
    frxtb_sysconfig: TfrxDBDataset;
    frxADOComponents2: TfrxADOComponents;
    tb_expxtiposerie: TFDQuery;
    dstb_expxtiposerie: TDataSource;
    LookupSeriesDataSet: TFDMemTable;
    dsLookupSeriesDataSet: TDataSource;
    frxCaratula: TfrxReport;
    DFDTPrestamos: TDataSource;
    dFDTTB_PrestamosDocumentos: TDataSource;
    TB_Prestamos: TFDQuery;
    TB_PrestamosDocumentos: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure tb_treeAfterPost(DataSet: TDataSet);
    procedure cl_expedientePostError(DataSet: TDataSet; E: EDatabaseError; var Action: TDataAction);
    procedure tb_SeriesDatosNewRecord(DataSet: TDataSet);
    procedure tb_SeriesDatosAfterDelete(DataSet: TDataSet);
    procedure tb_SeriesDatosAfterEdit(DataSet: TDataSet);
    procedure tb_SeriesDatosBeforeDelete(DataSet: TDataSet);
    procedure cl_ftp_ServerBeforePost(DataSet: TDataSet);
    procedure IdFTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure Timer1Timer(Sender: TObject);
    procedure cl_VarSubserieBeforePost(DataSet: TDataSet);
    procedure tb_treeBeforePost(DataSet: TDataSet);
    procedure tb_SeriesDatosBeforePost(DataSet: TDataSet);
    procedure cl_subseriesBeforePost(DataSet: TDataSet);
    procedure cl_subseriesNewRecord(DataSet: TDataSet);
    procedure tb_SeriesDatosAfterPost(DataSet: TDataSet);
    procedure cl_VarSubserieNewRecord(DataSet: TDataSet);
    procedure cl_VarSubserieBeforeInsert(DataSet: TDataSet);
  private
    procedure Inserta(aidObjeto, acodigoHijo, acodigoPadre, aicon: Integer; aetiq, NombreEntidad, aKeyDef, aKeyVal: string);
    procedure UpDateDB;
    function IsValidFieldName(const FieldName: string): Boolean;
    function IsReservedField(const FieldName: string): Boolean;
    function IsLabelNoUnique(const LabelValue: string): Boolean;
    { Private declarations }
  public
    { Public declarations }
    Rol,                  // Rol del usuario logeado.
    UserName: string;     // Usuario logeado
    // Alcance del usuario autenticado (nil en Access y sin cobertura previa a autenticar).
    Alcance: TAlcanceUsuario;
//    Responsable:
//    FileList: TIdFTPListItems;
    function CarpetaGeodato: string;
    procedure ActivaDataLayer(aValue: boolean);
    procedure OverLoadADL;
    destructor Destroy; override;
    procedure EstablecerAlcance(const Usuario: string; EsAdministrador: Boolean);
    procedure AplicarFiltrosAlcance;
//------------------------------------------------------------------------------
// Crear árbol de tablas...
//------------------------------------------------------------------------------
    procedure CreaTreeDB(conn: TFdconnection; t: PArbol; ShowAll: Boolean);
    procedure CargarArbol(TreeView: TTreeView; DataSet: TDataSet; opts: boolean);
    //procedure CrearArbol(TreeView: TTreeView; DataSet: TDataSet; ParentNode: TTreeNode; ParentID: Integer);
    procedure CrearArbol(TreeView: TTreeView; DataSet: TDataSet; ParentNode: TTreeNode; ParentID: Integer; MostrarNodosInvisibles: Boolean);
    procedure AgregaData(Nodo: TTreeNode; aId, aPadre, aIcono, Tipo: Integer; aEtiqueta, aOwner, Estructura, descrip: string);
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
    function sms(aText: string; aTipo: Integer; aTitle: string = ''): Integer;
    function VarToInt(const AVariant: Variant): integer;
    function WinExecAndWait32(FileName: string; Visibility: integer): integer;
    function ViewPDF(FilePath: string): Integer;
    function ViewIMG(FilePath: string): Integer;
    procedure SalvaConfigGrid(nombregrid: TcxGridDBTableView; NombreSalva: string);
    procedure RestauraGrid(nombregrid: TcxGridDBTableView; NombreSalva: string);
    procedure GuardarConfiguracion(cxGrid: TcxGrid; const FileName: string);
    procedure CargarConfiguracion(cxGrid: TcxGrid; const FileName: string);
    function KillProcess(ExeFileName: string): integer;
    function EsLocal(idServer: integer): Boolean;
    function GetFolder(idServer: integer): string;
    function BorrarCarpeta(const vOrigen: string): boolean;
    procedure RunAndWaitShell(Ejecutable, Argumentos: string; Visibilidad: integer);
    function Sto_GetFmtFileVersion(const FileName: string = ''; const Fmt: string = '%d.%d.%d.%d'): string;
    procedure CompletaNombreFile;
    procedure Verayuda(TopicID: integer);
    procedure ListAvailableSQLServers(Names: TStrings);
    function PtCreateADOObject(const ClassID: TGUID): IUnknown;
    procedure ObtenerDatosPC(var Datos: TDatosPC);
    procedure log(Mensaje: string; acc: Integer; aSerie, aSSerie, aStructura: string);
    procedure Boundarys(Sender: TObject);
    procedure ViewHLP(ID: integer);
    procedure DeleteDir(aPath: string);
    function ConfigFTP(H, U, P: string): Boolean;
    procedure TrimAppMemorySize;
    procedure CopyFileToFtpServer(const AServer, AUsername, APassword, ALocalFile, ARemotePath, Opts: string; Puerto: integer);
    function FileExistsOnFTP(const Host, Username, Password, puerto, FilePath: string): Boolean;
    function CheckFTPConnection(const Host, Username, Password: string; Puerto: integer): Boolean;
    procedure Inici(aBAR: PBarra; Min, Max: integer);
    procedure MueveBar(aBAR: PBarra; increment: integer);
    function DownloadFileFromFTP(const Host, Username, Password, RemoteFile, LocalFile: string; Puerto: Integer): boolean;
    procedure DeleteFTPFile(const Host, UserName, Password, FileName: string; Puerto: Integer);
    // Ficheros en S3/MinIO (F4): las rutas 's3://<servidor>/clave' van al almacen S3
    function UrlRaizNuevos: string;
    procedure SubirAS3(const Local: string; Idservidor: Integer; const Clave: string);
    function DescargarDeS3(Idservidor: Integer; const Clave, Local: string): Boolean;
    procedure BorrarDeS3(Idservidor: Integer; const Clave: string);
    procedure DeleteFTPDirectoryRecursive(const Host, UserName, Password, Directory: string; Puerto: Integer);
    procedure DeleteFTPDirectory(const Host, UserName, Password, Directory: string; Puerto: Integer);
    //ZIP
    procedure ZipDirectory(const Directory, ZipFileName: string);
    procedure ActualizaConfig(aVER: string);
    procedure EjecutaFichero(aPath: string);
    function getFileMd5HashString(const vFileName: string): string;
    function getMd5HashString(const vValue: string): string;
    procedure InitializeConnection;
    procedure LoadAndRunReport(const ReportFileName: string);
    procedure CreateTableFromDefinitions(ATableName, ASubserieId: string);
    function QuitaCaracter(Temp: string): string;
    procedure ProponerValores(IdEstructura, codsubs: string; var Fecha: TDateTime; var Version: string; var Codigodoc: string);
    function SubserieTieneVariables(codsubs: string): Boolean;
    function GenerarConsultaSQL(ADataset: TDataSet; const TableName: string; const Subserie: string = ''): string;
    procedure EjecutarCambiosBaseDatos(const SQLCommands: TArray<string>);
    function TablaExiste(Connection: TFDConnection; const NombreTabla: string): Boolean;
    function GetSeriesNameFile(aFecha: TDate): string;
    procedure ApplyCustomBestFit(cxtvg: TcxGridDBTableView);
    procedure CargaValoresCampo(Lista: TStringList; aFieldName, asql: string);
    function FindNode(tv: TTreeView; aId: integer; Etiqueta: string): TTreeNode;
    procedure SaveGridLayout(GridView: TcxGridTableView; const LayoutName: string);
    procedure LoadGridLayout(GridView: TcxGridTableView; const LayoutName: string);
    procedure SaveTreeViewState(TreeView: TTreeView; const FileName: string);
    procedure LoadTreeViewState(TreeView: TTreeView; const FileName: string);
    procedure SaveTreeViewState2(TreeView: TTreeView; const FileName: string; tb_tree, tb_seriestree, tb_seriesdatos: TDataSet);
    procedure LoadTreeViewState2(TreeView: TTreeView; const FileName: string; tb_tree, tb_seriestree, tb_seriesdatos: TDataSet);
    procedure ValidateParentNode(Node: TTreeNode);
    function ValidateTablesForData: Boolean;
    function EsNombreValido(const Nombre: string; const SGBD: char): Boolean;
    procedure DataBasesOnServer(DataBases: TStrings; const ServerName: string);
    function ConstructConnStr(const ServerName: string): WideString;
    function ConstruirConsultaSQL(IdEstructura, CodSubs: string; FDConnection: TFDConnection): string;
    procedure ConfigureMasterDetailRelation(Enable: Boolean; MasterQuery, DetailQuery: TFDQuery; MasterDataSource: TDataSource; MasterKeyFields, DetailKeyFields: string);
    procedure MostrarReporte(const NombreReporte: string);
    procedure StartTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
    function ObtenerNombreTabla(const TableName: string): string;
    procedure ExportarReporteAPDFyoyo(DatabaseType: TDatabaseType; const Params: array of string; const Fichero: string);
    function ConstruirCadenaConexion(DatabaseType: TDatabaseType; const Params: array of string): string;
  end;

const
  // Lista de campos reservados que no se pueden usar como nombres de variables
  ReservedFields: array[0..5] of string = ('IdEstructura', 'id', 'codsubs', 'Fecha', 'Version', 'Codigodoc');

  // Conjunto de caracteres no permitidos en nombres de variables
  InvalidChars: set of Char = [' ', 'á', 'é', 'í', 'ó', 'ú', 'Á', 'É', 'Í', 'Ó', 'Ú', 'ñ', 'Ñ', 'ä', 'ë', 'ï', 'ö', 'ü', '[', ']', '(', ')', '.', ',', ';', ':', '-', '+', '/', '\', '=', '!', '@', '#', '$', '%', '^', '&', '*', '<', '>', '|', '?'];

  { Cadena de conexión para MS Access }
  CONN_STR_ACCESS = 'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=%s;' + 'Mode=Share Deny None;Jet OLEDB:System database="";Jet OLEDB:Registry Path="";' + 'Jet OLEDB:Database Password="";Jet OLEDB:Engine Type=5;Jet OLEDB:Database Locking Mode=1;' + 'Jet OLEDB:Global Partial Bulk Ops=2;Jet OLEDB:Global Bulk Transactions=1;' + 'Jet OLEDB:New Database Password="";Jet OLEDB:Create System Database=False;' + 'Jet OLEDB:Encrypt Database=False;Jet OLEDB:Don''t Copy Locale on Compact=False;' + 'Jet OLEDB:Compact Without Replica Repair=False;Jet OLEDB:SFP=False;';
  { Cadena de conexión para SQL Server con autenticación SQL }
  CONN_STR_SQL_SERVER = 'Provider=SQLOLEDB;Data Source=%s;Initial Catalog=%s;' + 'User ID=%s;Password=%s;Persist Security Info=True;';
  { Cadena de conexión para SQL Server con autenticación de Windows }
  CONN_STR_SQL_SERVER_WIN_AUTH = 'Provider=SQLOLEDB;Data Source=%s;Initial Catalog=%s;' + 'Integrated Security=SSPI;Persist Security Info=True;';
  ID_EXTENSION_POR_DEFECTO = 102;
  SEPARADOR_RUTA = '\';
  SEPARADOR_FTP = '/';
  EXTENSION_PDF = '.pdf';
  ACCION_ERROR = 1; // Código de acción para errores en el log
  ACCION_EXITO = 3; // Código de acción para operaciones exitosas

var
  UDM: TUDM;
  treeBM, subBM, datosBM: TBookmark;
  EntraRecupera: Boolean;
  LlaveTree, LlaveEstruct, LlaveDatos: Variant;
  estadoC: boolean;
  Conectado: Boolean;
  programver: string;
  TBD: string;
  CAPP: boolean;
  FicheroTama: Int64;
  EsPropiedadesTopo: Boolean;
  ItsWork: Boolean;
  DatosPC: TDatosPc;
  NombreEstructura: string;
  VersionProgram, helpfile, buildprogram: string;
  Carpeta: string;
  acceso: string;
  syshelpLeft: integer;
  NombreFileSS: string;
  EstoyActualizando: Boolean;
  PathTemp, PathBD, PathSys, PathSaveBinaryFile, Pathtransplt, PathCarat: WideString;
  pathreport, pathdb: string;
  Rolactivo: string;
//  Security: TSecurityClass;
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
  Security: TSecurityClass;
  //Tipo de objeto para la asignacion de variables virturales...
  TipoObj: string;
  fdefaultStyleName: string;
  //Tipo de objeto para la asignacion de variables virturales...
  NombrePadreEditar: string;
  IdPadreEditar: integer;
  administradornodoeditar: string;
  tvActivo: PArbol;
  ReportConnection: TADOConnection;
  dbname, servername: string;
  CargandoEstado: Boolean;
  NodoSel: string;
  primeravez, flaginsert: boolean;
  tiinsert, codinsert: string;
  ListVarTmp: TStringList;
  GestionFile: Boolean;

implementation

uses
  UEsquemaAlcance, UEsquemaAlmacen, UEsquemaCarga, UEsquemaTrazabilidad, UAlcanceDatos, UTopografia,
  UAlmacenFicheros, UAlmacenServidor, UProgresoTransferencia;


{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function TUDM.ConfigFTP(H, U, P: string): Boolean;
var
  FileList: TIdFTPListItems;
begin
  result := False;
  UDM.IdFTP1.Disconnect;
  if UDM.IdFTP1.Connected then
    UDM.IdFTP1.Disconnect;
  UDM.IdFTP1.Host := H;
  UDM.IdFTP1.Username := U;
  UDM.IdFTP1.Password := P;
  try
    UDM.IdFTP1.Connect;
    Result := True;
  except
    on E: EIdFTPException do
      messagedlg(e.Message, mtError, [mbOK], 0);
  end;

end;

procedure TUDM.ConfigureMasterDetailRelation(Enable: Boolean; MasterQuery, DetailQuery: TFDQuery; MasterDataSource: TDataSource; MasterKeyFields, DetailKeyFields: string);
begin
  if primeravez then
    Exit;

  DetailQuery.Close;
  if Enable then
  begin
    // Asegurarse de que la consulta maestra esté abierta
    MasterQuery.Close;
    try
      MasterQuery.Open;
    except
      on E: EFDException do
      begin
        UDM.sms(E.Message, 1);
      end;
    end;

    // Configurar la consulta de la tabla detalle con la relación Master/Detail
    DetailQuery.DisableControls;
    try
      DetailQuery.MasterSource := MasterDataSource;
      DetailQuery.MasterFields := ansireplacestr(MasterKeyFields, ',', ';');
      DetailQuery.IndexFieldNames := ansireplacestr(DetailKeyFields, ',', ';');
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
      end;
    end;
    DetailQuery.EnableControls;
  end
  else
  begin
    // Destruir la relación Master/Detail
    DetailQuery.MasterSource := nil;
    DetailQuery.MasterFields := '';
  end;
  try
    DetailQuery.Open();
    DetailQuery.Refresh;
  except
    on E: EFDException do
    begin
      sms('No se pudieron realizar los cambios en la relación especificada. Motivo: ' + e.Message, 1);
      Exit
    end;
  end;
end;

function TUDM.ConstructConnStr(const ServerName: string): WideString;
begin
  Result := 'Provider=SQLOLEDB.1;Password=geoconn;Persist Security Info=True;User ID=geoconn;Data Source=' + ServerName;
end;

function TUDM.ConstruirCadenaConexion(DatabaseType: TDatabaseType; const Params: array of string): string;
begin
  case DatabaseType of
    dbAccess:
      begin
        if Length(Params) < 1 then
          raise Exception.Create('Se requiere la ruta del archivo de base de datos para MS Access.');
        if not TFile.Exists(Params[0]) then
          raise Exception.Create('El archivo de base de datos no existe: ' + Params[0]);
        Result := Format(CONN_STR_ACCESS, [Params[0]]);
      end;
    dbSQLServer:
      begin
        if Length(Params) < 2 then
          raise Exception.Create('Se requiere el nombre del servidor y la base de datos para SQL Server.');
        if Params[0].IsEmpty or Params[1].IsEmpty then
          raise Exception.Create('El nombre del servidor y la base de datos son obligatorios.');
        if (Length(Params) >= 4) and (not Params[2].IsEmpty) and (not Params[3].IsEmpty) then
          Result := Format(CONN_STR_SQL_SERVER, [Params[0], Params[1], Params[2], Params[3]])
        else
          Result := Format(CONN_STR_SQL_SERVER_WIN_AUTH, [Params[0], Params[1]]);
      end;
  else
    raise Exception.Create('Tipo de base de datos no soportado.');
  end;
end;

function TUDM.ConstruirConsultaSQL(IdEstructura, CodSubs: string; FDConnection: TFDConnection): string;
var
  SQLQuery: string;
  NombreTablaMetadatos, cadfields: string;
  Query: TFDQuery;

  function ObtenerCamposNoClaveOrdenados(const NombreTabla: string): string;
  var
    FDMetaInfoQuery: TFDMetaInfoQuery;
    ListaCampos: TStringList;
    i: integer;
    cadena, cad: string;
  begin
    Result := '';
    FDMetaInfoQuery := TFDMetaInfoQuery.Create(nil);
    FDMetaInfoQuery.Active := False;
    FDMetaInfoQuery.Connection := Conn;
    FDMetaInfoQuery.MetaInfoKind := mkPrimaryKeyFields;
    FDMetaInfoQuery.BaseObjectName := NombreTabla;

    ListaCampos := TStringList.Create;
    try
      FDMetaInfoQuery.Open;
    // Recorrer los campos de la tabla y verificar si son clave o no
      FDMetaInfoQuery.Last;
      while not FDMetaInfoQuery.Bof do
      begin
      // Solo agregamos los campos que no sean claves primarias y ordenamos por el campo 'Orden'
        ListaCampos.Add(ansilowercase(FDMetaInfoQuery.FieldByName('COLUMN_NAME').AsString));
        FDMetaInfoQuery.Prior;
      end;

      with TFDQuery.Create(nil) do
      try
        Active := False;
        Connection := UDM.Conn;
        SQL.Clear;
        SQL.Add('select top 1 * from ' + NombreTabla);
        try
          Open();
          cadena := '';
          for i := 0 to fieldcount - 1 do
          begin
            cad := ansilowercase(Fields[i].FieldName);
            if ListaCampos.IndexOf(cad) = -1 then
            begin
              if trim(cadena) = '' then
                cadena := 'M.' + Fields[i].FieldName
              else
                cadena := cadena + ', M.' + Fields[i].FieldName;
            end;
          end;
        except
          on E: Exception do


        end;
      finally
        Free;
      end;
    // Convertir la lista de campos a una cadena separada por comas
      Result := cadena;
    finally
      FDMetaInfoQuery.Free;
      ListaCampos.Free;
    end;
  end;

begin
  // Crear un query temporal para obtener el nombre de la tabla de metadatos
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := UDM.Conn;
    Query.SQL.Text := 'SELECT NombreTablaMetadatos FROM cl_subseries WHERE CodSubs = ' + QuotedStr(CodSubs);
    Query.Open;

    // Obtener el nombre de la tabla de metadatos (si existe)
    if not Query.IsEmpty then
      NombreTablaMetadatos := Query.FieldByName('NombreTablaMetadatos').AsString;

  finally
    Query.Free;
  end;

  // Construir la consulta SQL en función de si hay o no metadatos asociados
  if NombreTablaMetadatos <> '' then
  begin
    // Si hay una tabla de metadatos, realizar LEFT JOIN
    cadfields := ObtenerCamposNoClaveOrdenados(NombreTablaMetadatos);
    if trim(cadfields) <> '' then
    begin
      SQLQuery := 'SELECT S.*, ' + cadfields + ' FROM tb_SeriesDatos S ' + 'LEFT JOIN ' + NombreTablaMetadatos;
      SQLQuery := SQLQuery + ' M ON S.IdEstructura = M.IdEstructura AND S.codsubs = M.codsubs ';
      SQLQuery := SQLQuery + 'WHERE S.IdEstructura = ' + QuotedStr(IdEstructura) + ' AND S.codsubs = ' + QuotedStr(CodSubs);
    end
    else
    begin
      SQLQuery := 'SELECT * FROM tb_SeriesDatos WHERE IdEstructura = ' + QuotedStr(IdEstructura) + ' AND codsubs = ' + QuotedStr(CodSubs);
    end;
  end
  else
  begin
    // Si no hay tabla de metadatos, seleccionar solo desde tb_SeriesDatos
    SQLQuery := 'SELECT S.* ' + 'FROM tb_SeriesDatos S ' + 'WHERE S.IdEstructura = ' + QuotedStr(IdEstructura) + ' AND S.codsubs = ' + QuotedStr(CodSubs);
  end;
  // Crear y configurar el TFDQuery para ejecutar la consulta final

  Result := SQLQuery;
end;

procedure TUDM.CopyFileToFtpServer(const AServer, AUsername, APassword, ALocalFile, ARemotePath, Opts: string; Puerto: integer);
var
  FTP: TIdFTP;
  Path, NombreFichero: string;
  IdS3: Integer;
  ClaveS3: string;
begin
  if ParsearRutaS3(ARemotePath, IdS3, ClaveS3) then
  begin
    SubirAS3(ALocalFile, IdS3, ClaveS3);
    Exit;
  end;
  FTP := TIdFTP.Create(nil);
  try
    FTP.Host := AServer;
    FTP.Username := AUsername;
    FTP.Password := APassword;
    FTP.Port := Puerto;
    FTP.Passive := True; // Modo pasivo para conexiones detrás de un firewall
    FTP.Connect;
    Path := Copy(ARemotePath, 1, LastDelimiter('/', ARemotePath));
    NombreFichero := Copy(ARemotePath, LastDelimiter('/', ARemotePath) + 1, LastDelimiter('.', ARemotePath) - LastDelimiter('/', ARemotePath) - 1);
    //CREAR ESTRUCTURA DE DIRECTORIOS...
    try
      FTP.MakeDir(Path);
    except
    end;
    if Opts = 'O' then
    begin
      try
        FTP.MakeDir(Path + NombreFichero + '/');
      except
      end;
      try
        FTP.MakeDir(Path + NombreFichero + '/Fuentes/');
      except
      end;
      try
        FTP.MakeDir(Path + NombreFichero + '/Anexos Digitales/');
      except
      end;
    end;
    try
      FTP.Put(ALocalFile, ARemotePath, False);  //+ '/' + ExtractFileName(ALocalFile)
      // El cuarto parámetro indica que se sobrescribirá el archivo si ya existe
      FTP.Disconnect;
    except
      FTP.Disconnect;
    end;
  finally
    FTP.Free;
  end;
end;

// F4: los ficheros nuevos van al primer servidor de tipo S3; sin uno, la ruta
// del servidor FTP de siempre
function TUDM.UrlRaizNuevos: string;
var
  Id: Integer;
begin
  Id := 0;
  try
    Id := ServidorDestinoNuevos(Conn);
  except
    Id := 0;
  end;
  if Id > 0 then
    Result := UrlRaizS3(Id)
  else
    Result := cmdServer.FieldByName('Path').AsString;
end;

procedure TUDM.SubirAS3(const Local: string; Idservidor: Integer; const Clave: string);
var
  Alm: IAlmacenFicheros;
  Prog: TProgresoTransferencia;
begin
  Prog := TProgresoTransferencia.Create(nil, 'Subiendo fichero', ExtractFileName(Local));
  try
    try
      Alm := CrearAlmacen(Conn, Idservidor);
      Alm.Subir(Local, Clave,
        procedure(Hecho, Total: Int64; var Cancelar: Boolean)
        begin
          Prog.Actualizar(Hecho, Total, Cancelar);
        end);
    except
      on E: EAlmacen do
      begin
        sms('No se pudo subir el fichero. ' + E.Message, 1);
        // sin fichero no debe quedar el registro a medio crear
        if tb_ssArchdigital.State in dsEditModes then
          tb_ssArchdigital.Cancel;
        Abort;
      end;
    end;
  finally
    Prog.Free;
  end;
end;

function TUDM.DescargarDeS3(Idservidor: Integer; const Clave, Local: string): Boolean;
var
  Alm: IAlmacenFicheros;
  Prog: TProgresoTransferencia;
begin
  Result := False;
  Prog := TProgresoTransferencia.Create(nil, 'Descargando fichero', ExtractFileName(Local));
  try
    try
      Alm := CrearAlmacen(Conn, Idservidor);
      Alm.Descargar(Clave, Local,
        procedure(Hecho, Total: Int64; var Cancelar: Boolean)
        begin
          Prog.Actualizar(Hecho, Total, Cancelar);
        end);
      Result := True;
    except
      on E: EAlmacen do
        sms('No se puede descargar el fichero especificado. Motivo: ' + E.Message, 1);
    end;
  finally
    Prog.Free;
  end;
end;

procedure TUDM.BorrarDeS3(Idservidor: Integer; const Clave: string);
begin
  CrearAlmacen(Conn, Idservidor).Borrar(Clave);
end;

procedure TUDM.ActualizaConfig(aVER: string);
var
  List: TStringList;
begin
  if trim(ansilowercase(aVER)) = 'profesional' then
  begin
    List := TStringList.Create;
    List.LoadFromFile(PathSys + 'config.ini');
    UDM.tb_sysconfig.Edit;
    UDM.tb_sysconfig.FieldByName('ipservidorbd').AsString := List[1];
    try
      UDM.tb_sysconfig.Post;
    except
      on E: Exception do
        UDM.tb_sysconfig.Cancel;
    end;
    List.Free;
  end
  else
  begin
    UDM.tb_sysconfig.Edit;
    UDM.tb_sysconfig.FieldByName('ipservidorbd').AsString := '';
    try
      UDM.tb_sysconfig.Post;
    except
      on E: Exception do
        UDM.tb_sysconfig.Cancel;
    end;
  end;
end;

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

procedure TUDM.AgregaData(Nodo: TTreeNode; aId, aPadre, aIcono, Tipo: Integer; aEtiqueta, aOwner, Estructura, descrip: string);
var
  pData: PDataRec;

  function RTFToPlainText(const RTFText: string): string;
  var
    InControlWord: Boolean;
    InGroup: Boolean;
    InText: Boolean;
    i: Integer;
    CurrentChar: Char;
    ResultText: TStringBuilder;
  begin
    ResultText := TStringBuilder.Create;
    try
      InControlWord := False;
      InGroup := False;
      InText := False;

      for i := 1 to Length(RTFText) do
      begin
        CurrentChar := RTFText[i];

      // Detectar el inicio de un comando de control
        if CurrentChar = '\' then
        begin
          InControlWord := True;
          InText := False;
        end
      // Detectar el fin de un comando de control
        else if ((CurrentChar = ' ') or (CurrentChar = '{') or (CurrentChar = '}')) and InControlWord then
        begin
          InControlWord := False;
          InText := False;
          if CurrentChar = '{' then
            InGroup := True
          else if CurrentChar = '}' then
            InGroup := False;
        end
      // Guardar texto si no está en un comando de control o grupo
        else if not InControlWord and not InGroup then
        begin
          if (CurrentChar <> '{') and (CurrentChar <> '}') then
          begin
            InText := True;
            ResultText.Append(CurrentChar);
          end;
        end;
      end;

    // Eliminar caracteres especiales como CR (#13) y LF (#10)
      Result := ResultText.ToString;
      Result := Result.Replace(#13, '').Replace(#10, '').Trim;  // Eliminar saltos de línea, retorno de carro y espacios en blanco
    finally
      ResultText.Free;
    end;
  end;

begin
  New(pData);
  pData.estruct := Estructura;
  pData.Id := aId;
  pData.Padre := aPadre;
  pData.Icono := aIcono;
  pData.Etiqueta := aEtiqueta;
  pData.Owner := aOwner;
  pData.Tipo := UDM.Conn.ExecSQLScalar('select nombretipoobj from cl_tipoobj where idtipoobj=' + IntToStr(Tipo));
  if trim(descrip) <> '' then
    pData.Descrip := RTFToPlainText(descrip);
  Nodo.Data := pData;
end;

procedure TUDM.ApplyCustomBestFit(cxtvg: TcxGridDBTableView);
var
  i: Integer;
  Field: TField;
begin
  // Itera sobre las columnas del cxGrid (TcxGridTableView)
  for i := 0 to cxtvg.ColumnCount - 1 do
  begin
    // Obtiene el campo correspondiente a la columna
    Field := cxtvg.Columns[i].DataBinding.Field;

    if Assigned(Field) then
    begin
      // Si es de tipo cadena (ftString) ajusta el ancho a 100
      if (Field.DataType in [ftString, ftWideString]) then
      begin
        if cxtvg.Columns[i].Width < 200 then
          cxtvg.Columns[i].Width := 200
      end      // Si es de tipo numérico ajusta el ancho a 85
      else if (Field.DataType in [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD]) then
        if cxtvg.Columns[i].Width < 85 then
          cxtvg.Columns[i].Width := 85;
    end;
  end;
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

procedure TUDM.Boundarys(Sender: TObject);
begin
  TJvCaptionPanel(Sender).Focused;
  TJvCaptionPanel(Sender).SetFocus;
  if TJvCaptionPanel(Sender).Left < 0 then
    TJvCaptionPanel(Sender).Left := 5;
  if TJvCaptionPanel(Sender).Top < 0 then
    TJvCaptionPanel(Sender).Top := 5;
end;

procedure TUDM.GetNodoPadreActual;
begin
  NodoPadreActual.id := UDM.tb_tree.FieldByName('id').AsInteger;
  NodoPadreActual.Padre := UDM.tb_tree.FieldByName('Padre').AsInteger;
  NodoPadreActual.icono := UDM.tb_tree.FieldByName('icono').AsInteger;
  NodoPadreActual.tipo := UDM.tb_tree.FieldByName('tipo').AsInteger;
end;

function TUDM.GetSeriesNameFile(aFecha: TDate): string;
var
  fe: string;
begin
  fe := datetostr(aFecha) + '' + TimeToStr(Now);
  fe := AnsiReplaceStr(fe, '/', '');
  fe := AnsiReplaceStr(fe, ' ', '');
  fe := AnsiReplaceStr(fe, ':', '');
  result := fe;
end;

procedure TUDM.GuardarConfiguracion(cxGrid: TcxGrid; const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    (cxGrid.Levels[0].GridView as TcxCustomGridTableView).StoreToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TUDM.CargarArbol(TreeView: TTreeView; DataSet: TDataSet; opts: boolean);
begin
  TreeView.Items.BeginUpdate; // Mejora el rendimiento al construir el árbol
  try
    TreeView.Items.Clear; // Limpiar el TreeView antes de añadir los nodos
    DataSet.Active := False;
    DataSet.Active := True;
    DataSet.First; // Asegurarse de que el DataSet esté en el primer registro
    // Comenzar a crear el árbol desde los nodos raíz (padre = 0 o NULL)
    CrearArbol(TreeView, DataSet, nil, 0, opts);
  finally
    TreeView.Items.EndUpdate;
  end;
end;

procedure TUDM.CargarConfiguracion(cxGrid: TcxGrid; const FileName: string);
var
  Stream: TFileStream;
begin
  if FileExists(FileName) then
  begin
    Stream := TFileStream.Create(FileName, fmOpenRead);
    try
      (cxGrid.Levels[0].GridView as TcxCustomGridTableView).RestoreFromStream(Stream);
    finally
      Stream.Free;
    end;
  end;
end;

procedure TUDM.CargaValoresCampo(Lista: TStringList; aFieldName, asql: string);
var
  ComboQuery: TFDQuery;
begin
  ComboQuery := TFDQuery.Create(nil);
  try
    ComboQuery.Connection := UDM.Conn;
    ComboQuery.SQL.Text := 'SELECT DISTINCT ' + aFieldName + ' FROM (' + asql + ') WHERE ' + aFieldName + ' IS NOT NULL ' + ' ORDER BY ' + aFieldName;
    try
      ComboQuery.Open;
    except
    end;
              // Agregar los valores únicos al ComboBox
    while not ComboQuery.Eof do
    begin
      Lista.Add(ComboQuery.Fields[0].AsString);
      ComboQuery.Next;
    end;

  finally
    ComboQuery.Free;
  end;
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

function TUDM.CheckFTPConnection(const Host, Username, Password: string; Puerto: integer): Boolean;
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
      on E: EIdException do
      begin
        // Handle the exception if the connection attempt fails
        Result := False;
      end;
    end;
  finally
    FTPClient.Disconnect;
    FTPClient.Free;
  end;
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

procedure TUDM.cl_ftp_ServerBeforePost(DataSet: TDataSet);
var
  nombreoip: string;
begin
  nombreoip := UDM.cl_ftp_Server.FieldByName('ipserver').AsString;
  if trim(nombreoip) = '' then
    nombreoip := UDM.cl_ftp_Server.FieldByName('etiquetaServ').AsString;
  if UDM.cl_ftp_Server.FieldByName('puerto').value = null then
    UDM.cl_ftp_Server.FieldByName('puerto').AsInteger := 0;
  DataSet.FieldByName('test').AsBoolean := CheckFTPConnection(nombreoip, UDM.cl_ftp_Server.FieldByName('usuarioftp').AsString, UDM.cl_ftp_Server.FieldByName('pass').AsString, UDM.cl_ftp_Server.FieldByName('puerto').AsInteger);
end;

procedure TUDM.cl_subseriesBeforePost(DataSet: TDataSet);
var
  codsubs, subserie: string;

  function ExisteIdEstructura(const acodsubs: string): Boolean;
  var
    Query: TFDQuery;
  begin
    Result := False;
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := UDM.Conn; // Asegúrate de tener tu conexión configurada
      Query.SQL.Text := 'SELECT COUNT(*) FROM cl_subseries WHERE codsubs = :acodsubs';
      Query.ParamByName('acodsubs').AsString := acodsubs;
      Query.Open;

    // Si el resultado es mayor que 0, significa que ya existe
      if Query.Fields[0].AsInteger > 0 then
        Result := True;
    finally
      Query.Free;
    end;
  end;

begin
  if (DataSet.State = dsInsert) then
  begin
    codsubs := DataSet.FieldByName('codsubs').AsString;
    subserie := DataSet.FieldByName('subserie').AsString;
    if Trim(subserie) = '' then
    begin
      sms('El título de la subserie no puede estar vacío.', 2);
//    DataSet.Cancel; // Cancela la operación de inserción o modificación
      Abort;          // Evita que continúe la inserción
      Exit;
    end;
  // Verifica si el campo está vacío
    if Trim(codsubs) = '' then
    begin
      sms('El código de la subserie no puede estar vacío.', 2);
      DataSet.Cancel; // Cancela la operación de inserción o modificación
      Abort;          // Evita que continúe la inserción
      Exit;
    end;
    if ExisteIdEstructura(codsubs) then
    begin
      sms('El código de la subserie ya existe. No se puede insertar un valor duplicado.', 2);
      DataSet.Cancel; // Cancela la operación de inserción o modificación
      Abort;          // Evita que continúe la inserción
      Exit;
    end;
  end;
end;

procedure TUDM.cl_subseriesNewRecord(DataSet: TDataSet);

  function GenerateUniqueCodSubs(codserie: string): string;
  var
    LastCodSubs: string;
    NewCodSubs: string;
    MaxCodSubsNumber: Integer;
    Query: TFDQuery; // Asumimos que estás usando FireDAC
  begin
  // Inicializamos la consulta
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := udm.Conn; // Tu conexión a la base de datos

    // Buscar el último código de subserie para el codserie dado
      Query.SQL.Text := 'SELECT MAX(codsubs) AS LastCodSubs ' + 'FROM cl_subseries ' + 'WHERE codserie = :codserie';
      Query.ParamByName('codserie').AsString := codserie;
      Query.Open;

      LastCodSubs := Query.FieldByName('LastCodSubs').AsString;

      if LastCodSubs = '' then
      begin
      // Si no existe ningún codsubs para el codserie, empezamos desde '001'
        NewCodSubs := '001';
      end
      else
      begin
      // Extraemos la parte numérica del último codsubs
        MaxCodSubsNumber := StrToIntDef(Copy(LastCodSubs, Length(codserie) + 1, MaxInt), 0);

      // Incrementamos el número
        Inc(MaxCodSubsNumber);

      // Generamos el nuevo código, con un formato fijo de longitud (e.g. 'codserie001')
        NewCodSubs := codserie + FormatFloat('000', MaxCodSubsNumber);
      end;

      Result := NewCodSubs;
    finally
      Query.Free;
    end;
  end;

begin
  // Valores por defecto para el nuevo registro
  DataSet.FieldByName('codsubs').AsString := GenerateUniqueCodSubs(DataSet.FieldByName('codserie').AsString);
  DataSet.FieldByName('soporte').AsInteger := 3;
  DataSet.FieldByName('tipodoc').AsInteger := 2;
  DataSet.FieldByName('acceso').AsInteger := 1;
  DataSet.FieldByName('idtiposerie').AsInteger := 1;
  DataSet.FieldByName('Activa').AsBoolean := True;
end;

{procedure TUDM.cl_VarSubserieBeforePost(DataSet: TDataSet);
const
  ReservedFields: array[0..5] of string = ('IdEstructura', 'id', 'codsubs', 'Fecha', 'Version', 'Codigodoc');
  CaracteresInvalidos: set of Char = [' ', 'á', 'é', 'í', 'ó', 'ú', 'Á', 'É', 'Í', 'Ó', 'Ú', 'ñ', 'Ñ', 'ä', 'ë', 'ï', 'ö', 'ü', '[', ']', '(', ')', '.', ',', ';', ':', '-', '+', '/', '\', '=', '!', '@', '#', '$', '%', '^', '&', '*', '<', '>', '|', '?'];

  function ValidarNombreCampo(const NombreCampo: string): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 1 to Length(NombreCampo) do
    begin
      if NombreCampo[I] in CaracteresInvalidos then
      begin
        Result := False;
        Break;
      end;
    end;
  end;

var
  VariableName: string;
  I: Integer;
begin
  // Obtener el valor del campo 'NomVariable' de la variable que se está intentando guardar
  VariableName := DataSet.FieldByName('NomVariable').AsString;
  if not ValidarNombreCampo(VariableName) then
  begin
      // Mostrar un mensaje de error
    raise Exception.CreateFmt('El nombre de la variable "%s" contiene caractes no aceptados por el Gestor de Bases de Datos. Por favor especifique otro nombre de variable.', [VariableName]);

      // Cancelar la operación
    DataSet.Cancel;
    Exit;
  end;
  if not EsNombreValido(VariableName, TBD[1]) then
  begin
      // Mostrar un mensaje de error
    raise Exception.CreateFmt('El nombre de la variable "%s" coincide con una palabra reservada del Sistema de Gestión de Base de Datos. Por favor especifique otro nombre de variable.', [VariableName]);

      // Cancelar la operación
    DataSet.Cancel;
    Exit;
  end;

end; }

/// <summary>
/// Valida el nombre de una variable antes de guardar el registro en el DataSet.
/// Este método se ejecuta en el evento BeforePost del DataSet cl_VarSubserie.
/// </summary>
/// <param name="DataSet">El DataSet que contiene el registro a validar.</param>
/// <remarks>
/// - Verifica que el nombre de la variable (campo 'NomVariable') no contenga caracteres inválidos.
/// - Asegura que el nombre no sea una palabra reservada del sistema de gestión de bases de datos.
/// - Garantiza que el campo 'etiqueta' sea único en el DataSet.
/// Si alguna validación falla, se lanza una excepción y se detiene el proceso de guardado.
/// </remarks>
/// <exception cref="Exception">
/// - Si el nombre de la variable contiene caracteres inválidos.
/// - Si el nombre de la variable es una palabra reservada.
/// - Si el valor del campo 'etiqueta' no es único.
/// </exception>
procedure TUDM.cl_VarSubserieBeforeInsert(DataSet: TDataSet);
var
  VariableName: string;
  LabelValue: string;
begin
  {// Obtener el valor del campo 'NomVariable'
  VariableName := DataSet.FieldByName('NomVariable').AsString;

  // Validar que el nombre no contenga caracteres inválidos
  if not IsValidFieldName(VariableName) then
    raise Exception.CreateFmt('El nombre de la variable "%s" contiene caracteres no aceptados por el Gestor de Bases de Datos. ' + 'Por favor, especifique otro nombre de variable.', [VariableName]);

  // Validar que el nombre no sea una palabra reservada
  if IsReservedField(VariableName) then
    raise Exception.CreateFmt('El nombre de la variable "%s" coincide con una palabra reservada del Sistema de Gestión de Base de Datos. ' + 'Por favor, especifique otro nombre de variable.', [VariableName]);
    }
end;

procedure TUDM.cl_VarSubserieBeforePost(DataSet: TDataSet);
var
  VariableName, TipoDat: string;
  LabelValue: string;
begin
  // Obtener el valor del campo 'NomVariable'
  VariableName := DataSet.FieldByName('NomVariable').AsString;
  // Validar que el nombre no contenga caracteres inválidos
  if Trim(VariableName) = '' then
    raise Exception.CreateFmt('Debe especificar un nombre de variable "%s"  valido. ' + 'Por favor, especifique un nombre de variable.', [VariableName]);
  if trim(DataSet.FieldByName('Etiqueta').AsString) = '' then
  begin
    if (DataSet.State <> dsedit) and (DataSet.State <> dsinsert) then
      DataSet.Edit;
    UDM.sms('No ha especificado una etiqueta valida. Esto no es aconsejable por lo que el sistema utilizará temporalmente el nombre de la variable especificada.', 3);
    DataSet.FieldByName('Etiqueta').AsString := DataSet.FieldByName('NomVariable').AsString;
  end;
  if Trim(DataSet.FieldByName('tipo').AsString) = '' then
    raise Exception.CreateFmt('Debe especificar un tipo datos valido para la variable "%s"  valido. ' + 'Por favor, especifique un tipo de datos valido.', [VariableName])
  else
  begin
    TipoDat := UDM.Conn.ExecSQLScalar('SELECT CL_SubseriesTipoVar.tipo FROM CL_SubseriesTipoVar WHERE CL_SubseriesTipoVar.Idtipo=' + DataSet.FieldByName('tipo').AsString);
    if SameText(TipoDat, 'Caracteres') then
      if (DataSet.FieldByName('longitud').Value = null) or (trim(DataSet.FieldByName('longitud').AsString) = '') then
        raise Exception.CreateFmt('Debe especificar la longitud para la variable "%s". ' + 'Las variables de tipo "Caracteres" exigen que se especifique su tamaño.', [VariableName]);
  end;
  // Validar que el nombre no contenga caracteres inválidos
  if not IsValidFieldName(VariableName) then
    raise Exception.CreateFmt('El nombre de la variable "%s" contiene caracteres no aceptados por el Gestor de Bases de Datos. ' + 'Por favor, especifique otro nombre de variable.', [VariableName]);


  // Validar que el nombre no sea una palabra reservada
  if IsReservedField(VariableName) then
    raise Exception.CreateFmt('El nombre de la variable "%s" coincide con una palabra reservada del Sistema de Gestión de Base de Datos. ' + 'Por favor, especifique otro nombre de variable.', [VariableName]);
  // Obtener el valor del campo 'etiqueta' y validar su unicidad
  LabelValue := DataSet.FieldByName('etiqueta').AsString;
  if IsLabelNoUnique(LabelValue) then
    raise Exception.CreateFmt('El valor del campo "etiqueta" (%s) ya existe. Debe ser único. ' + 'Por favor, especifique un valor diferente.', [LabelValue]);
end;

procedure TUDM.cl_VarSubserieNewRecord(DataSet: TDataSet);
begin
  {}
end;

procedure TUDM.DataBasesOnServer(DataBases: TStrings; const ServerName: string);
var
  RecordS: _RecordSet;
  flag: string;
begin
  //Devuelve las Bases de Datos existentes en un Servidor MS SQL Server...
  //Expesificando un Prefijo el cual se utiliza para identificar las Bases de Datos...
  //del Centro de Datos...
  with TADOConnection.Create(nil) do
  try
    ConnectionString := ConstructConnStr(ServerName);
    LoginPrompt := False;
    try
      Open;
      RecordS := ConnectionObject.OpenSchema(adSchemaCatalogs, EmptyParam, EmptyParam); //more general approach in terms of ADO
      with RecordS do
      begin
        while not Eof do
        begin
          flag := VarToStr(Fields['CATALOG_NAME'].Value);
          DataBases.Add(flag);
          MoveNext;
        end;
      end;
      Close;
    except
      MessageDlg('No se pudo establecer la conexión con el servidor especificado. Motivos: ' + chr(13) + '1- Por favor verifique que el nombre del servidor sea correcto.' + chr(13) + '2- Verifique que se halla ejecutado el procedimiento de configuración de conexión para GeodatoIC v3.0.' + chr(13) + '3- Póngase en contacto con el administrador del GeoDato en su Empresa o con el Grupo de Desarrollo del Programa GeoDato. ', mtError, [mbOK], 0);
      Exit;
    end;
  finally
    Free;
  end;
end;

procedure TUDM.DataModuleCreate(Sender: TObject);
var
  ListT: TStringList;
begin
  GestionFile := False;
  ListVarTmp := TStringList.Create;
  EntraRecupera := False;
  flaginsert := False;
  LlaveTree := VarArrayCreate([0, 1], varVariant);
  LlaveEstruct := VarArrayCreate([0, 2], varVariant);
  LlaveDatos := VarArrayCreate([0, 4], varVariant);
  primeravez := True;
  estadoC := True;
  CargandoEstado := False;
  CAPP := False;
  Conectado := False;
  EstoyActualizando := False;
  EsPropiedadesTopo := False;
  TipoObj := 'S';
  ObtenerDatosPC(DatosPC);
  ItsWork := False;
  EsReadOnly := False;
  PathTemp := CarpetaGeodato;
  cadcmd := '';
  PathSys := ExtractFilePath(Application.ExeName);
  PathSaveBinaryFile := PathSys + 'bin\';
  PathCarat := PathSys + 'CARATULAS\';
  pathreport := ExtractFilePath(Application.ExeName) + 'Report\';
  //Pathtransplt:=PathSys
  if FileExists(PathSys + 'config.ini') then
  begin
    ListT := TStringList.Create;
    ListT.LoadFromFile(PathSys + 'config.ini');
    TBD := ListT[0];
    if TBD = 'S' then
    begin
      ServerName := ListT[1];
      dbname := ListT[2];
    end
    else
    begin
      PathBD := ListT[1];
    end;
    ListT.Free;
  end;
  with Conn do
  begin
    Connected := False;
    with Params do
    begin
      Clear;
      if TBD = 'S' then
      begin
        Add('Database=' + dbname);
        Add('User_Name=geoconn');
        Add('Password=geoconn');
        Add('Server=' + ServerName);
        Add('DriverID=MSSQL');
      end
      else
      begin
        Add('Database=' + PathBD);
        Add('DriverID=MSAcc');
      end;
    end;
//    ResourceOptions.SilentMode := True; // Desactiva cambios automáticos de cursor
//    ResourceOptions.WaitCursor := crDefault; // Fuerza crDefault si se muestra un cursor
    try

      Connected := True;

  // Ejecutar los cambios
      UpDateDB;
    except
      on E: EFDexception do
      begin
        sms('No se ha podido establecer comunicación con la base de datos. Motivo: ' + E.Message, 1);
        if TBD = 'S' then
          sms('No se pudo establecer la conexión con el servidor especificado.' + chr(13) + 'LA APLICACIÓN SE CERRARÁ!!!!. Por favor verifique los posibles motivos listados a continuación: ' + chr(13) + '1- Por favor verifique que el nombre o IP del servidor sean correctos.' + chr(13) + '2- Verifique que se haya ejecutado el procedimiento de configuración de conexión.' + chr(13) + '3- Verifique que su estación de trabajo este correctamente conectada a la red de la empresa.' + chr(13) + '4- Póngase en contacto con el administrador de la red en su Empresa o solicite ayuda a soporte técnico.', 3)
        else
          sms('No se pudo establecer la conexión con la base de datos especificada.' + chr(13) + 'Por favor verifique los posibles motivos listados a continuación: ' + chr(13) + '1- Verifique que la base de datos se encuentre en la ruta especificada.' + AnsiQuotedStr(PathBD, '"') + chr(13) + '2- Si el fichero de bases de datos esta disponible verifique que no este dañado, abrá el fichero access y reparelo.' + chr(13) + '3- Póngase en contacto con el administrador de la red en su Empresa o solicite ayuda a soporte técnico.', 3);
        CAPP := True;
        Exit;
      end;
    end;
  end;

  ActivaDataLayer(true);
end;

procedure TUDM.DeleteDir(aPath: string);
var
  sr: TSearchRec;
begin
  aPath := IncludeTrailingBackslash(aPath);
  if FindFirst(aPath + '*.*', faAnyFile, sr) = 0 then
    repeat
      if (sr.Name <> '..') and (sr.Name <> '.') then
      begin
        if (sr.Attr = faDirectory) then
          DeleteDir(aPath + sr.Name)
        else
          Win32Check(System.SysUtils.DeleteFile(pwidechar(aPath + sr.Name)));
      end;
    until FindNext(sr) <> 0;
  System.SysUtils.FindClose(sr);
  aPath := ExcludeTrailingBackslash(aPath);
  Win32Check(RemoveDir(aPath));
end;

procedure TUDM.DeleteFTPDirectory(const Host, UserName, Password, Directory: string; Puerto: Integer);
var
  FTP: TIdFTP;
begin
  FTP := TIdFTP.Create(nil);
  try
    FTP.Host := Host;
    FTP.Username := UserName;
    FTP.Password := Password;
    FTP.Port := Puerto;
    FTP.Connect;
    try
      try
        FTP.ChangeDir(Directory);
        FTP.RemoveDir(FTP.RetrieveCurrentDir);
      except
      end;
    finally
      FTP.Disconnect;
    end;
  finally
    FTP.Free;
  end;
end;

procedure TUDM.DeleteFTPDirectoryRecursive(const Host, UserName, Password, Directory: string; Puerto: Integer);
var
  FTP: TIdFTP;
  Files: TStringList;
  I: Integer;
begin
  FTP := TIdFTP.Create(nil);
  Files := TStringList.Create;
  try
    FTP.Host := Host;
    FTP.Username := UserName;
    FTP.Password := Password;
    FTP.Port := Puerto;
    FTP.Connect;
    try
      // Obtener la lista de archivos y subdirectorios del directorio
      FTP.List(Files, '', False);
      // Eliminar los archivos del directorio
      for I := 0 to Files.Count - 1 do
      begin
        FTP.Delete(Files[I]);
      end;
      // Eliminar los subdirectorios de forma recursiva
      for I := 0 to Files.Count - 1 do
      begin
        FTP.ChangeDir(Files[I]);
        DeleteFTPDirectoryRecursive(Host, UserName, Password, Files[I], Puerto);
        FTP.ChangeDirUp;
        FTP.RemoveDir(Files[I]);
      end;
    finally
      FTP.Disconnect;
    end;
  finally
    Files.Free;
    FTP.Free;
  end;
end;

procedure TUDM.DeleteFTPFile(const Host, UserName, Password, FileName: string; Puerto: Integer);
var
  FTP: TIdFTP;
  IdS3: Integer;
  ClaveS3: string;
begin
  if ParsearRutaS3(FileName, IdS3, ClaveS3) then
  begin
    BorrarDeS3(IdS3, ClaveS3);
    Exit;
  end;
  FTP := TIdFTP.Create(nil);
  try
    FTP.Host := Host;
    FTP.Username := UserName;
    FTP.Password := Password;
    FTP.Port := Puerto;
    FTP.Connect;
    try
      FTP.Delete(FileName);
    finally
      FTP.Disconnect;
    end;
  finally
    FTP.Free;
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

procedure TUDM.EjecutarCambiosBaseDatos(const SQLCommands: TArray<string>);
var
  Query: TFDQuery;
  i: Integer;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := UDM.Conn;  // Conexión a la base de datos

    // Iterar sobre cada comando SQL
    for i := 0 to High(SQLCommands) do
    begin
      try
        Query.SQL.Text := SQLCommands[i];
        Query.ExecSQL;

        // Opcional: Puedes mostrar un mensaje si el comando se ejecuta correctamente
        // ShowMessage('Comando ejecutado: ' + SQLCommands[i]);
      except
        on E: Exception do
        begin
          // Si ocurre un error, se captura y se muestra o registra
//          ShowMessage('Error al ejecutar comando: ' + SQLCommands[i] + #13#10 + 'Error: ' + E.Message);
          // Puedes agregar registro en un archivo o log si es necesario
          Continue;  // Continúa con el siguiente comando a pesar del error
        end;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TUDM.EsLocal(idServer: integer): Boolean;
begin
  {Result := False;
  if UDM.cl_ftp_Server.Locate('Idservidor', idServer, []) then
    if (trim(UDM.cl_ftp_Server.FieldByName('user').AsString) = '') and (trim(UDM.cl_ftp_Server.FieldByName('pass').AsString) = '') and (trim(UDM.cl_ftp_Server.FieldByName('puerto').AsString) = '') then
      Result := True;}
end;

function TUDM.EsNombreValido(const Nombre: string; const SGBD: char): Boolean;
var
  i: Integer;
  NombreUsuario: string;
begin
  Result := True;  // Asumimos que el nombre es válido hasta probar lo contrario
  NombreUsuario := UpperCase(Nombre);  // Convertimos el nombre a mayúsculas para comparación insensible a mayúsculas/minúsculas

  case SGBD of
    'S':  // Para SQL Server
      begin
        for i := Low(SQLServerReservadas) to High(SQLServerReservadas) do
        begin
          if AnsiCompareText(NombreUsuario, SQLServerReservadas[i]) = 0 then
          begin
            Result := False;
            Exit;
          end;
        end;
      end;

    'A':  // Para MS Access
      begin
        for i := Low(AccessReservadas) to High(AccessReservadas) do
        begin
          if AnsiCompareText(NombreUsuario, AccessReservadas[i]) = 0 then
          begin
            Result := False;
            Exit;
          end;
        end;
      end;

  else
    raise Exception.Create('SGBD no válido. Use "S" para SQL Server o "A" para MS Access.');
  end;
end;

{ Exporta un reporte de FastReport a un archivo PDF, conectando a la base de datos especificada.
  @param DatabaseType: Tipo de base de datos (dbAccess o dbSQLServer).
  @param Params: Arreglo de parámetros para la conexión:
                 - Para dbAccess: [0] = Ruta del archivo .mdb.
                 - Para dbSQLServer: [0] = Servidor, [1] = Nombre de la base de datos,
                                     [2] = Usuario (opcional), [3] = Contraseña (opcional).
  @param Fichero: Ruta completa del archivo PDF de salida (incluye nombre y extensión).
}
procedure TUDM.ExportarReporteAPDFyoyo(DatabaseType: TDatabaseType; const Params: array of string; const Fichero: string);
var
  ExportadorPDF: TfrxPDFExport;
  DatabaseObj: TfrxADODatabase;
  consulta: TfrxADOQuery;
  SerieValue: string;
  Serie, SS, SD, tt: TfrxADOTable;
{ Formatea una fecha para usarla en un filtro SQL según el tipo de base de datos.
  @param Fecha: Valor de la fecha a formatear.
  @param DatabaseType: Tipo de base de datos (dbAccess o dbSQLServer).
  @return: Cadena con la fecha formateada (ej. '#06/04/2025#' para Access, '2025-04-06' para SQL Server).
}

  function FormatearFechaFiltro(const aFecha: TDateTime; DatabaseType: TDatabaseType): string;
  begin
    case DatabaseType of
      dbAccess:
        Result := '#' + FormatDateTime('mm/dd/yyyy', aFecha) + '#'; // Formato para MS Access
      dbSQLServer:
        Result := '''' + FormatDateTime('yyyy-mm-dd', aFecha) + ''''; // Formato para SQL Server
    else
      raise Exception.Create('Tipo de base de datos no soportado.');
    end;
  end;

begin
  // Validar parámetros de entrada
  if Fichero.IsEmpty or not TPath.HasValidFileNameChars(TPath.GetFileName(Fichero), False) then
    raise Exception.Create('Ruta o nombre de archivo PDF inválido.');

  try
    // 1. Configurar la conexión a la base de datos
    DatabaseObj := TfrxADODatabase(frxCaratula.FindObject('ADObASICO'));
    consulta := TfrxADOQuery(frxCaratula.FindObject('Qhijos'));
    Serie := TfrxADOTable(frxCaratula.FindObject('CL_SERIE'));
    SS := TfrxADOTable(frxCaratula.FindObject('cL_subserie'));
    SD := TfrxADOTable(frxCaratula.FindObject('tb_SeriesDatos'));
    tt := TfrxADOTable(frxCaratula.FindObject('Tb_tree'));
    //expediente='P-001'
    if not Assigned(DatabaseObj) then
      raise Exception.Create('No se encontró el objeto de base de datos en la carátula.');

    DatabaseObj.Connected := False;
    DatabaseObj.DatabaseName := ConstruirCadenaConexion(DatabaseType, Params);
    try
      DatabaseObj.Connected := True;
    except
      raise Exception.Create('No se pudo generar la carátula especificada. Problema de conexión con la base de datos.');
    end;
    SerieValue := UDM.Conn.ExecSQLScalar('SELECT cl_subseries.codserie FROM cl_subseries WHERE cl_subseries.codsubs=' + QuotedStr(tb_SeriesDatos.FieldByName('codsubs').asstring));
    if not Assigned(consulta) then
      raise Exception.Create('No se encontró el listado de documentos que incluye este expediente');
    try
      consulta.Active := True;
      consulta.Filter := 'expediente=' + QuotedStr(tb_SeriesDatos.FieldByName('Codigodoc').asstring);
      consulta.Filtered := True;
    except
    end;
    //Tb_tree
    if not Assigned(tt) then
      raise Exception.Create('No se encontró la estructura a la que pertenece el expediente seleccionado.');
    try
      tt.Active := True;
      tt.Filtered := False;
      tt.Filter := 'IdEstructura =' + QuotedStr(tb_SeriesDatos.FieldByName('IdEstructura').asstring);
      tt.Filtered := True;
    except
    end;
    //Series
    if not Assigned(Serie) then
      raise Exception.Create('No se encontró la serie a la que pertenece el documento especificado');
    try
      Serie.Active := True;
      Serie.Filtered := False;
      Serie.Filter := 'CODSERIE =' + QuotedStr(SerieValue);
      Serie.Filtered := True;
    except
    end;
    //Tb_SUBSERIES
    if not Assigned(SS) then
      raise Exception.Create('No se encontró la subserie a la que pertenece el documento especificado.');
    try
      SS.Active := True;
      SS.Filtered := False;
      SS.Filter := 'CODSERIE =' + QuotedStr(SerieValue) + 'and codsubs=' + QuotedStr(tb_SeriesDatos.FieldByName('codsubs').asstring);
      SS.Filtered := True;
    except
    end;
    //Tb_SeriesDatos...
    if not Assigned(SD) then
      raise Exception.Create('No se encontró el listado de documentos que incluye este expediente');
    try
      SD.Active := True;
      SD.Filtered := False;
//      sd.Filter := 'CODSERIE ='+QuotedStr(SerieValue)+'and codsubs='+QuotedStr(tb_SeriesDatos.FieldByName('codsubs').asstring);
      SD.Filter := 'CodigoDoc = ' + QuotedStr(tb_SeriesDatos.FieldByName('CodigoDoc').asstring);
      SD.Filtered := True;
    except
    end;
    // 2. Preparar el reporte
    frxCaratula.PrepareReport(True);

    // 3. Configurar el exportador PDF
    ExportadorPDF := TfrxPDFExport.Create(nil);
    try
      ExportadorPDF.FileName := Fichero;
      ExportadorPDF.ShowDialog := False; // No mostrar diálogo de guardado
      ExportadorPDF.ShowProgress := True; // Mostrar barra de progreso
      ExportadorPDF.OverwritePrompt := True; // Preguntar si sobrescribir
      ExportadorPDF.EmbeddedFonts := True; // Incrustar fuentes para compatibilidad
      ExportadorPDF.Compressed := True; // Comprimir el archivo PDF
      ExportadorPDF.PrintOptimized := True; // Optimizar para impresión

      // 4. Exportar el reporte a PDF
      frxCaratula.Export(ExportadorPDF);

      // 5. Abrir el archivo PDF generado (opcional)
//      ShellExecute(0, 'open', PChar(Fichero), nil, nil, SW_SHOWNORMAL);
    finally
      ExportadorPDF.Free;
    end;

    // 6. Desconectar la base de datos
//    DatabaseObj.Connected := False;
  except
    on E: Exception do
      ShowMessage('Error al generar el PDF: ' + E.Message);
  end;
end;

function TUDM.DownloadFileFromFTP(const Host, Username, Password, RemoteFile, LocalFile: string; Puerto: Integer): boolean;
var
  FTP: TIdFTP;
  IdS3: Integer;
  ClaveS3: string;
begin
  result := False;
  if ParsearRutaS3(RemoteFile, IdS3, ClaveS3) then
  begin
    Result := DescargarDeS3(IdS3, ClaveS3, LocalFile);
    Exit;
  end;
  FTP := TIdFTP.Create(nil);
  try
    FTP.Host := Host;
    FTP.Username := Username;
    FTP.Password := Password;
    FTP.Port := Puerto;
    FTP.Connect;
    try
      FTP.Get(RemoteFile, LocalFile, True);
      Result := True;
    except
      on E: EIdException do
      begin
        UDM.sms('No se puede descargar el fichero especificado. Motivo: ' + E.Message, 1);
      end;

    end;
    FTP.Disconnect;
  finally
    FTP.Free;
  end;
end;

procedure TUDM.EjecutaFichero(aPath: string);
var
  Msg: string;
  Err: LongWord;

  procedure OpenWith(const Filename: string);
{ llama al cuadro de diálogo "Abrir con..." para el fichero pasado por parámetro }
  begin
    ShellExecute(0, 'open', 'rundll32.exe', PChar('shell32.dll,OpenAs_RunDLL ' + Filename), PChar(ExtractFilePath(Filename)), SW_SHOWNORMAL);
  end;

begin
  Err := ShellExecute(Application.Handle, 'open', pchar(aPath), nil, nil, SW_SHOW);
  if Err <= 32 then
  begin
    case Err of
      2:
        begin
          Msg := 'Archivo no encontrado';
          UDM.sms(Msg, 1);
        end;
      3:
        begin
          Msg := 'Ruta no encontrada';
          UDM.sms(Msg, 1);
        end;
      5:
        begin
          Msg := 'Acceso denegado';
          UDM.sms(Msg, 1);
        end;
      8:
        begin
          Msg := 'Memoria insuficiente';
          UDM.sms(Msg, 1);
        end;
      26:
        begin
          Msg := 'No se puede compartir un archivo abierto';
          UDM.sms(Msg, 1);
        end;
      27:
        begin
          Msg := 'Información de asociación de archivo no completa';
          UDM.sms(Msg, 1);
        end;
      28:
        begin
          Msg := 'Se agotó el tiempo de espera de la operación DDE';
          UDM.sms(Msg, 1);
        end;
      29:
        begin
          Msg := 'Operación DDE fallida';
          UDM.sms(Msg, 1);
        end;
      30:
        begin
          Msg := 'La operación DDE está ocupada';
          UDM.sms(Msg, 1);
        end;
      31:
        begin
          Msg := 'Asociación de archivo no disponible';
          UDM.sms(Msg, 1);
          OpenWith(aPath);
          {JvOpenWithDialog1.FileName:=afn;
          JvOpenWithDialog1.Execute;    }
        end;
    else
      Msg := 'Error no especificado';

    end;

  end;
end;

function TUDM.FileExistsOnFTP(const Host, Username, Password, puerto, FilePath: string): Boolean;
var
  FTP: TIdFTP;
  i: integer;
  DIR: string;
begin
  Result := False;
  FTP := TIdFTP.Create(nil);
  try
    FTP.Host := Host;
    FTP.Username := Username;
    FTP.Password := Password;
    FTP.Port := StrToInt(puerto);
    FTP.Connect;
    FTP.Passive := true;
    try
      FTP.List;
      for i := 0 to FTP.DirectoryListing.Count - 1 do
        if FTP.DirectoryListing[i].DisplayName = FilePath then
          Result := True;
    except

    end;
    FTP.Disconnect;
  finally
    FTP.Free;
  end;
end;

function TUDM.FindNode(tv: TTreeView; aId: integer; Etiqueta: string): TTreeNode;
var
  j: integer;
begin
  result := nil;
  for j := 0 to tv.Items.Count - 1 do
    if (PDataRec(tv.Items[j]).Id = aId) or (tv.Items[j].Text = Etiqueta) then
    begin
      tv.Items[j].Selected := True;
      Result := tv.Items[j];
      Break;
    end;
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

function TUDM.GenerarConsultaSQL(ADataset: TDataSet; const TableName: string; const Subserie: string = ''): string;
var
  SQLBuilder: TStringBuilder;
  NomVariable, Etiqueta, Tipo, Longitud: string;
  QueryResult: string;
  IsAccess: Boolean;
begin
  SQLBuilder := TStringBuilder.Create;
  try
    // Determinar si la base de datos es MS Access o SQL Server usando TBD
    IsAccess := (TBD = 'A');

    // Iniciar la consulta con las columnas fijas
    SQLBuilder.Append('SELECT IdEstructura, id, codsubs, Fecha, Version, Codigodoc, ');

    // Filtrar ADataset por la subserie seleccionada si se proporciona Subserie
    if (Subserie <> '') and (ADataset.FieldDefs.IndexOf('codsubs') >= 0) then
    begin
      ADataset.Filter := 'codsubs = ' + QuotedStr(Subserie);
      ADataset.Filtered := True;
    end;

    // Verificar si hay registros después del filtrado
    if ADataset.IsEmpty then
    begin
      Result := ''; // No hay variables para la subserie
      Exit;
    end;

    // Recorrer el DataSet filtrado para construir las columnas dinámicas
    ADataset.First;
    while not ADataset.Eof do
    begin
      NomVariable := ADataset.FieldByName('NomVariable').AsString;
      Etiqueta := ADataset.FieldByName('Etiqueta').AsString;
      Tipo := LowerCase(ADataset.FieldByName('tipo').AsString);
      Longitud := ADataset.FieldByName('longitud').AsString;

      // Ajustar la sintaxis según la base de datos
      if Tipo = 'int' then
        SQLBuilder.Append(NomVariable + ', ')
      else if Tipo = 'varchar' then
      begin
        if IsAccess then
          SQLBuilder.Append('CStr(' + NomVariable + ') AS ' + NomVariable + ', ') // MS Access
        else
          SQLBuilder.Append('CAST(' + NomVariable + ' AS VARCHAR(' + Longitud + ')) AS ' + NomVariable + ', '); // SQL Server
      end
      else
        SQLBuilder.Append(NomVariable + ', ');

      ADataset.Next;
    end;

    // Eliminar la última coma y espacio si hay columnas
    if SQLBuilder.Length > 7 then
      SQLBuilder.Length := SQLBuilder.Length - 2
    else
    begin
      Result := ''; // No se generó ninguna columna válida
      Exit;
    end;

    // Añadir la cláusula FROM
    QueryResult := ObtenerNombreTabla(TableName);
    if QueryResult = '' then
    begin
      Result := '';
      Exit;
    end;

    // Ajustar la sintaxis de FROM según la base de datos
    if IsAccess then
      SQLBuilder.Append(' FROM ' + QueryResult) // MS Access
    else
      SQLBuilder.Append(' FROM [' + QueryResult + ']'); // SQL Server

    // Asignar el resultado final
    Result := SQLBuilder.ToString;
  finally
    // Restaurar el estado del filtro si se modificó
    if (Subserie <> '') and (ADataset.FieldDefs.IndexOf('codsubs') >= 0) then
      ADataset.Filtered := False;
    SQLBuilder.Free;
  end;
end;

{function TUDM.GenerarConsultaSQL(ADataset: TDataSet; const TableName: string): string;
var
  SQLQuery: string;
  NomVariable, Etiqueta, Tipo: string;
begin
  SQLQuery := 'SELECT ';

 // Añadir las llaves primarias de la tabla tb_seriesdatos

  SQLQuery := SQLQuery + 'IdEstructura, id, codsubs, Fecha, Version, Codigodoc, '; // Ajusta según tus llaves primarias

  // Recorremos el DataSet que contiene los datos de cl_VarSubserie
  ADataset.First;
  while not ADataset.Eof do
  begin
    NomVariable := ADataset.FieldByName('NomVariable').AsString;
    Etiqueta := ADataset.FieldByName('Etiqueta').AsString;
    Tipo := LowerCase(ADataset.FieldByName('tipo').AsString);

    // Construir la parte de la consulta dependiendo del tipo de dato
    if Tipo = 'int' then
      SQLQuery := SQLQuery + NomVariable + ', '
    else if Tipo = 'varchar' then
      SQLQuery := SQLQuery + 'CAST(' + NomVariable + ' AS VARCHAR(' + ADataset.FieldByName('longitud').AsString + ')) , '
    else
      SQLQuery := SQLQuery + NomVariable + ', ';

    ADataset.Next;
  end;

  // Eliminar la última coma sobrante
  if Length(SQLQuery) > 7 then
  begin
    SQLQuery := Copy(SQLQuery, 1, Length(SQLQuery) - 2); // Elimina la última coma y espacio
  end
  else
  begin
    Result := ''; // No se generó ninguna columna
    Exit;
  end;

  // Añadir la cláusula FROM
  with TFDQuery.Create(nil) do
  try
    Active := False;
    Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add(TableName);
    try
      Open();
      SQLQuery := SQLQuery + ' FROM ' + Fields[0].AsString;
    except
      on E: Exception do


    end;
  finally
    Free;
  end;


  // Depurar la consulta generada
//  ShowMessage(SQLQuery); // Muestra la consulta generada

  Result := SQLQuery;
end; }

function TUDM.getFileMd5HashString(const vFileName: string): string;
begin

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

function TUDM.getMd5HashString(const vValue: string): string;
var
  vHashMD5: TIdHashMessageDigest5;
begin
  vHashMD5 := nil;
  try
    vHashMD5 := TIdHashMessageDigest5.Create;
    Result := IdGlobal.IndyLowerCase(vHashMD5.HashStringAsHex(vValue));
  finally
    vHashMD5.Free;
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

procedure TUDM.CommitTransaction;
begin
  if Conn.InTransaction then
    Conn.Commit;
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

procedure TUDM.CrearArbol(TreeView: TTreeView; DataSet: TDataSet; ParentNode: TTreeNode; ParentID: Integer; MostrarNodosInvisibles: Boolean);
var
  NewNode: TTreeNode;
  Bookmark: TBookmark;
  IconIndex: Integer;
  EsVisible: Boolean;
begin
  // Guardar la posición actual del dataset
  Bookmark := DataSet.GetBookmark;
  try
    // Mover al primer registro del dataset
    DataSet.First;
    while not DataSet.Eof do
    begin
      // Comprobar si el registro actual es hijo del nodo padre actual
      if DataSet.FieldByName('padre').AsInteger = ParentID then
      begin
        // Determinar si se debe mostrar el nodo
        EsVisible := DataSet.FieldByName('visible').AsBoolean;
        if EsVisible or MostrarNodosInvisibles then
        begin
          // Determinar el índice del icono basado en las condiciones dadas
          if ParentID = 0 then
          begin
            // Si es un nodo raíz (padre es 0 o NULL), usar el valor del campo icono
            IconIndex := DataSet.FieldByName('icono').AsInteger;
          end
          else
          begin
            // Revisar el icono del nodo padre para asignar iconos específicos
            if Assigned(ParentNode) then
            begin
              case ParentNode.ImageIndex of
                5: // Nodos hijos de padre con icono 5
                  if EsVisible then
                    IconIndex := 5
                  else
                    IconIndex := 12; // Icono para nodos invisibles
                6: // Nodos hijos de padre con icono 6
                  if EsVisible then
                    IconIndex := 6
                  else
                    IconIndex := 13; // Icono para nodos invisibles
              else
                // Si no aplica la regla de padre con icono 5 o 6, usar reglas generales
                case DataSet.FieldByName('tipo').AsInteger of
                  1: // Tipo 1
                    if EsVisible then
                      IconIndex := 15
                    else
                      IconIndex := 14; // Icono para nodos invisibles
                  2: // Tipo 2
                    if EsVisible then
                      IconIndex := 1
                    else
                      IconIndex := 8; // Icono para nodos invisibles
                else
                  IconIndex := -1; // Sin icono si no se especifica
                end;
              end;
            end;
          end;

          // Crear un nuevo nodo hijo
          NewNode := TreeView.Items.AddChild(ParentNode, DataSet.FieldByName('etiqueta').AsString);

          // Asignar datos al nodo usando el procedimiento AgregaData
          AgregaData(NewNode, DataSet.FieldByName('id').AsInteger, DataSet.FieldByName('padre').AsInteger, IconIndex, DataSet.FieldByName('tipo').AsInteger, DataSet.FieldByName('etiqueta').AsString, DataSet.FieldByName('administrador').AsString, DataSet.FieldByName('IdEstructura').AsString, DataSet.FieldByName('Descripcion').AsString);

          // Asignar el icono determinado
          NewNode.ImageIndex := IconIndex;
          NewNode.SelectedIndex := IconIndex; // Selecciona el mismo icono al seleccionar el nodo

          // Llamar recursivamente para agregar los hijos de este nodo
          CrearArbol(TreeView, DataSet, NewNode, DataSet.FieldByName('id').AsInteger, MostrarNodosInvisibles);
        end;
      end;
      DataSet.Next;
    end;
  finally
    // Restaurar la posición del dataset
    if DataSet.BookmarkValid(Bookmark) then
      DataSet.GotoBookmark(Bookmark);
    DataSet.FreeBookmark(Bookmark);
  end;
end;


{
procedure TUDM.CrearArbol(TreeView: TTreeView; DataSet: TDataSet; ParentNode: TTreeNode; ParentID: Integer);
var
  NewNode: TTreeNode;
  Bookmark: TBookmark;
  IconIndex: Integer;
begin
  // Guardar la posición actual del dataset
  Bookmark := DataSet.GetBookmark;
  try
    // Mover al primer registro del dataset
    DataSet.First;
    while not DataSet.Eof do
    begin
      // Comprobar si el registro actual es hijo del nodo padre actual
      if DataSet.FieldByName('padre').AsInteger = ParentID then
      begin
        // Determinar el índice del icono basado en las condiciones dadas
        if ParentID = 0 then
        begin
          // Si es un nodo raíz (padre es 0 o NULL), usar el valor del campo icono
          IconIndex := DataSet.FieldByName('icono').AsInteger;
        end
        else
        begin
          // Revisar el icono del nodo padre para asignar iconos específicos
          if Assigned(ParentNode) then
          begin
            case ParentNode.ImageIndex of
              5: // Nodos hijos de padre con icono 5
                if DataSet.FieldByName('visible').AsBoolean then
                  IconIndex := 5
                else
                  IconIndex := 12;
              6: // Nodos hijos de padre con icono 6
                if DataSet.FieldByName('visible').AsBoolean then
                  IconIndex := 6
                else
                  IconIndex := 13;
            else
              // Si no aplica la regla de padre con icono 5 o 6, usar reglas generales
              case DataSet.FieldByName('tipo').AsInteger of
                1: // Tipo 1
                  if DataSet.FieldByName('visible').AsBoolean then
                    IconIndex := 15
                  else
                    IconIndex := 14;
                2: // Tipo 2
                  if DataSet.FieldByName('visible').AsBoolean then
                    IconIndex := 1
                  else
                    IconIndex := 8;
              else
                IconIndex := -1; // Sin icono si no se especifica
              end;
            end;
          end;
        end;

        // Crear un nuevo nodo hijo
        NewNode := TreeView.Items.AddChild(ParentNode, DataSet.FieldByName('etiqueta').AsString);

        // Asignar datos al nodo usando el procedimiento AgregaData
        AgregaData(NewNode, DataSet.FieldByName('id').AsInteger, DataSet.FieldByName('padre').AsInteger, IconIndex, DataSet.FieldByName('etiqueta').AsString, DataSet.FieldByName('administrador').AsString, DataSet.FieldByName('IdEstructura').AsString);

        // Asignar el icono determinado
        NewNode.ImageIndex := IconIndex;
        NewNode.SelectedIndex := IconIndex; // Selecciona el mismo icono al seleccionar el nodo

        // Llamar recursivamente para agregar los hijos de este nodo
        CrearArbol(TreeView, DataSet, NewNode, DataSet.FieldByName('id').AsInteger);
      end;
      DataSet.Next;
    end;
  finally
    // Restaurar la posición del dataset
    if DataSet.BookmarkValid(Bookmark) then
      DataSet.GotoBookmark(Bookmark);
    DataSet.FreeBookmark(Bookmark);
  end;
end;

}
procedure TUDM.CreateFTPDirStructure(ListProccess: TStringList);
var
  Local_i: Integer;
begin

end;

procedure TUDM.CreateTableFromDefinitions(ATableName, ASubserieId: string);
var
  FDQuery: TFDQuery;
  SQL: TStringList;
  VarName, VarType, SQLVarType: string;
  VarLength: Integer;
  serie, subserie: string;
begin
  FDQuery := TFDQuery.Create(nil);
  SQL := TStringList.Create;
  subserie := ASubserieId;
  serie := UDM.Conn.ExecSQLScalar('select codserie from cl_subseries where codsubs=' + QuotedStr(subserie));
  try
    FDQuery.Connection := UDM.Conn;
    // Consulta para leer las definiciones de las variables desde cl_VarSubserie
    FDQuery.SQL.Text := 'SELECT NomVariable, tipo, Longitud ' + 'FROM cl_VarSubserie ' + 'WHERE codsubs = ' + QuotedStr(ASubserieId) + ' ORDER BY Orden';
    FDQuery.Open;

    // Definición inicial de la tabla con campos base
    SQL.Add('CREATE TABLE ' + ATableName + ' (');
    SQL.Add('  IdEstructura VARCHAR(50),');
    SQL.Add('  id INT,');
    SQL.Add('  codsubs VARCHAR(50),');
    SQL.Add('  Fecha DATETIME,');
    SQL.Add('  Version VARCHAR(12),');
    SQL.Add('  Codigodoc VARCHAR(20),');

    // Iterar sobre los resultados de la consulta para construir las columnas de la tabla
    while not FDQuery.Eof do
    begin
      VarName := FDQuery.FieldByName('NomVariable').AsString;
      VarType := UDM.Conn.ExecSQLScalar('SELECT tipo FROM CL_SubseriesTipoVar WHERE idtipo=' + FDQuery.FieldByName('tipo').AsString);
      VarLength := FDQuery.FieldByName('Longitud').AsInteger;

      // Seleccionar el tipo de dato según el motor de base de datos
      if VarType = 'Fecha' then
      begin
        if TBD = 'S' then
          SQLVarType := 'DATETIME2'  // DATETIME2 es más preciso y moderno en SQL Server
        else
          SQLVarType := 'DATETIME';  // Access sigue utilizando LONGTEXT para grandes textos
      end
      else if VarType = 'Caracteres' then
      begin
        if VarLength > 0 then
          SQLVarType := 'VARCHAR(' + IntToStr(VarLength) + ')'
        else
          SQLVarType := 'VARCHAR(MAX)';  // Utilizamos VARCHAR(MAX) en lugar de TEXT o NTEXT
      end
      else if VarType = 'Entero' then
      begin
        SQLVarType := 'INT';
      end
      else if VarType = 'Memo' then
      begin
        if TBD = 'S' then
          SQLVarType := 'VARCHAR(MAX)'  // SQL Server mejor opción en lugar de NTEXT
        else
          SQLVarType := 'LONGTEXT';  // Access sigue utilizando LONGTEXT para grandes textos
      end
      else if VarType = 'Real' then
      begin
        SQLVarType := 'DECIMAL(18, 6)';  // DECIMAL es más preciso que FLOAT/DOUBLE
      end
      else if VarType = 'Boolean' then
      begin
        if TBD = 'S' then
          SQLVarType := 'BIT'  // SQL Server
        else
          SQLVarType := 'YESNO';  // Access
      end;

      // Agregar la definición de la columna al SQL
      SQL.Add('  ' + VarName + ' ' + SQLVarType + ',');

      FDQuery.Next;  // Avanzar al siguiente registro
    end;

    // Agregar clave primaria y referencias a otras tablas con actualización y eliminación en cascada
    if TBD = 'S' then
    begin
      // Para SQL Server
      SQL.Add('  PRIMARY KEY (IdEstructura, id, codsubs, Fecha, Version, Codigodoc),');
      SQL.Add('  FOREIGN KEY (IdEstructura, id, codsubs, Fecha, Version, Codigodoc) ' + 'REFERENCES tb_SeriesDatos(IdEstructura, id, codsubs, Fecha, Version, Codigodoc) ' + 'ON UPDATE CASCADE ' +  // Actualización en cascada
        'ON DELETE CASCADE');    // Eliminación en cascada
    end
    else
    begin
      // Para MS Access
      SQL.Add('  PRIMARY KEY (IdEstructura, id, codsubs, Fecha, Version, Codigodoc),');
      SQL.Add('  FOREIGN KEY (IdEstructura, id, codsubs, Fecha, Version, Codigodoc) ' + 'REFERENCES tb_SeriesDatos(IdEstructura, id, codsubs, Fecha, Version, Codigodoc) ' + 'ON UPDATE CASCADE ' +  // Access admite ON UPDATE CASCADE
        'ON DELETE CASCADE');   // Access admite ON DELETE CASCADE
    end;
    SQL.Add(');');

    // Ejecutar la consulta para crear la tabla
    FDQuery.SQL.Text := SQL.Text;
    try
      Conn.StartTransaction;
      Conn.ExecSQL(SQL.Text);  // Ejecutar la creación de la tabla
      Conn.Commit;
    // Actualizar el nombre de la tabla en la serie correspondiente
      if UDM.cl_series.Locate('codserie', serie, []) then
        if UDM.cl_subseries.Locate('codserie;codsubs', VarArrayOf([serie, subserie]), []) then
        begin
          UDM.cl_subseries.Edit;
          UDM.cl_subseries.FieldByName('NombreTablaMetadatos').AsString := ATableName;
          try
            UDM.cl_subseries.Post;
          except
            on E: Exception do
              UDM.cl_subseries.Cancel;
          end;
        end;
    except
      Conn.Rollback;  // Revertir la transacción en caso de error
    end;

  finally
    FDQuery.Free;
    SQL.Free;
  end;
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
  tmp: integer;

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

  procedure AgregaData(Nodo: TTreeNode; aId, apadre, aIcono: integer; aetiqueta, admin: string; v: Boolean);
  var
    pData: PDataRec;
    tmpNodo: TTreeNode;
  begin
    new(pData);
    pData.Id := aId;
    pData.Padre := apadre;
    pData.Icono := aIcono;
    pData.Etiqueta := aetiqueta;
    pData.Owner := admin;
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
      if TBD = 'A' then
      begin
        if not ShowAll then
          SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible, tb_tree.administrador FROM tb_tree  where Padre=' + IntToStr(IdPadre) + ' and visible=true order by etiqueta')
        else
          SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible, tb_tree.administrador FROM tb_tree  where Padre=' + IntToStr(IdPadre) + ' order by etiqueta');
      end
      else
      begin
        if not ShowAll then
          SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible, tb_tree.administrador FROM tb_tree  where Padre=' + IntToStr(IdPadre) + ' and visible=1 order by etiqueta')
        else
          SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible, tb_tree.administrador FROM tb_tree  where Padre=' + IntToStr(IdPadre) + ' order by etiqueta');
      end;
      try
        Active := True;
        while not Eof do
        begin
          tmpNode := t.Items.AddChild(ndo, FieldByName('etiqueta').AsString);
          AgregaData(tmpNode, Fields[0].AsInteger, Fields[2].AsInteger, Fields[3].AsInteger, Fields[1].AsString, Fields[5].AsString, Fields[4].AsBoolean);
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
    if TBD = 'A' then
    begin
      if not ShowAll then
        SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible, tb_tree.administrador FROM tb_tree  where padre is null and aowner=' + QuotedStr('system') + ' and visible=true order by etiqueta asc')
      else
        SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible, tb_tree.administrador FROM tb_tree  where padre is null and aowner=' + QuotedStr('system') + ' order by etiqueta asc');
    end
    else
    begin
      if not ShowAll then
        SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible, tb_tree.administrador FROM tb_tree  where (padre IS NULL OR padre=0) and aowner=' + QuotedStr('system') + ' and visible=1 order by etiqueta asc')
      else
        SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre, tb_tree.icono, tb_tree.visible, tb_tree.administrador FROM tb_tree  where (padre IS NULL OR padre=0) and aowner=' + QuotedStr('system') + ' order by etiqueta asc');
    end;
    try
      Active := True;
      First;
      while not Eof do
      begin
        ndopadre := t.Items.Add(nil, FieldByName('etiqueta').AsString);
        tmp := Fields[0].AsInteger;
        AgregaData(ndopadre, Fields[0].AsInteger, Fields[2].AsInteger, Fields[3].AsInteger, Fields[1].AsString, Fields[5].AsString, Fields[4].AsBoolean);
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

procedure TUDM.ValidateParentNode(Node: TTreeNode);
begin
  if Node.Parent = nil then
    raise Exception.Create('No se puede agregar un nodo sin un padre asignado. Debe seleccionar un nodo valido.');
end;

function TUDM.ValidateTablesForData: Boolean;
var
  FDQuery: TFDQuery;
  TableList: array[0..3] of string;
  i, RowCount: Integer;
  ErrorMsg: string;
begin
  Result := True;  // Inicialmente asumimos que todas las tablas tienen datos
  FDQuery := TFDQuery.Create(nil);
  try
    FDQuery.Connection := UDM.Conn;  // Tu conexión debe estar configurada
    TableList[0] := 'cl_ArchivosGestion';
    TableList[1] := 'cl_ftp_Server';
    TableList[2] := 'cl_series';
    TableList[3] := 'cl_subseries';

    // Iteramos sobre las tablas para validar si tienen registros
    for i := 0 to High(TableList) do
    begin
      FDQuery.SQL.Text := 'SELECT COUNT(*) FROM ' + TableList[i];
      FDQuery.Open;
      RowCount := FDQuery.Fields[0].AsInteger;

      // Si alguna tabla no tiene registros, generamos el error y detenemos la operación
      if RowCount = 0 then
      begin
        ErrorMsg := 'La tabla ' + TableList[i] + ' no tiene datos. No se puede continuar.';
        Result := False;
        sms(ErrorMsg, 1); // Muestra un mensaje al usuario
//        ShowMessage(ErrorMsg);
        Break;  // Salimos del bucle al encontrar una tabla vacía
      end;
    end;

  finally
    FDQuery.Free;
  end;
end;

function TUDM.VarToInt(const AVariant: Variant): integer;
begin
  Result := StrToIntDef(Trim(VarToStr(AVariant)), 0);
end;

procedure TUDM.VarVirt;
begin

end;

procedure TUDM.Verayuda(TopicID: integer);
begin
  HelpFile := ExtractFilePath(Application.ExeName) + 'ArchiGenioPro.chm';
  Application.HelpSystem.ShowContextHelp(TopicID, HelpFile);
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
//

var
  s, s1, s2, cad: string;
begin

//  s := ExtractFilePath(Application.ExeName) + 'foxit.exe '; //'SumatraPDF\SumatraPDF.exe ' ;

  s1 := aFileName;
//  s2 := Concat(s, '"' + s1 + '"');
  cad := QuotedStr('P') + ' ' + AnsiQuotedStr(s1, '"');
  UDM.RunAndWaitShell(PathSys + 'Viewer.exe', cad, SW_SHOWMAXIMIZED);
//  WinExecAndWait32(s2, SW_HIDE);
end;

procedure TUDM.ViewHLP(ID: integer);
var
  TopicID: integer;
begin
  TStyleManager.TrySetStyle('Windows');
  TopicID := ID;
  HelpFile := ExtractFilePath(Application.ExeName) + 'ArchiGenioPro.chm';
  Application.HelpSystem.ShowContextHelp(TopicID, HelpFile);
  TStyleManager.TrySetStyle(fdefaultStyleName);
end;

function TUDM.ViewIMG(FilePath: string): Integer;
var
  cmd: string;
  fp: string;
begin
  cmd := ExtractFilePath(Application.ExeName) + 'JPEGViewPortable\JPEGViewPortable.exe ';
  if FileExists(trim(cmd)) then
  begin
    fp := AnsiQuotedStr(FilePath, '"');
    ShellExecute(0, 'open', PChar(cmd), PChar(fp), nil, SW_SHOWNORMAL);
  end
  else
  begin
    sms('No se encontró la aplicación por defecto para visualizar la imagen.', 1);
  end;
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
        while (trim(tb_tree.FieldByName('Padre').AsString) <> '') and (tb_tree.FieldByName('Padre').AsString <> '0') do
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
         // tb_tree.Prior;
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

procedure TUDM.ZipDirectory(const Directory, ZipFileName: string);
begin
  TZipFile.ZipDirectoryContents(ZipFileName, Directory, zcStored);
end;

procedure TUDM.IdFTP1Work(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
var
  porciento: integer;
begin
  {if pp <> nil then
  begin
    porciento := trunc((AWorkCount * 100) / FicheroTama);
    MueveBar(pp, porciento);
  end       }
end;

procedure TUDM.Inici(aBAR: PBarra; Min, Max: integer);
begin
  aBAR.MinValue := Min;
  aBAR.MaxValue := Max;
  aBAR.Progress := 0;
  aBAR.Update;
end;

procedure TUDM.InitializeConnection;
begin
  if not Assigned(ReportConnection) then
  begin
    ReportConnection := TADOConnection.Create(nil);
    ReportConnection.ConnectionString := 'Provider=SQLOLEDB;Data Source=' + ServerName + ';' + 'Initial Catalog=SDbd;' + 'User ID=geoconn;Password=geoconn;';
    ReportConnection.LoginPrompt := False;

    try
      ReportConnection.Connected := True; // Conectar una vez
    except
      on E: Exception do
        ShowMessage('Error al conectar a la base de datos: ' + E.Message);
    end;
  end;
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

/// <summary>
/// Verifica si el valor del campo 'etiqueta' es único en el DataSet.
/// </summary>
/// <param name="DataSet">El DataSet donde se buscará el valor.</param>
/// <param name="LabelValue">El valor del campo 'etiqueta' a verificar.</param>
/// <returns>True si el valor es único; False si ya existe en el DataSet.</returns>
/// <remarks>
/// Este método recorre el DataSet para buscar duplicados, ignorando el registro actual (si está en modo de edición o inserción).
/// La comparación es insensible a mayúsculas/minúsculas.
/// Para evitar ciclos infinitos, se asegura que:
/// - El DataSet no esté en un estado que impida la navegación (por ejemplo, modo de edición).
/// - Se use CompareBookmarks para comparar marcadores de forma segura.
/// Si el DataSet no está activo o está vacío, se retorna True.
/// </remarks>
/// <exception cref="Exception">
/// - Si no se puede acceder al campo 'etiqueta' o si falla la navegación del DataSet.
/// </exception>
function TUDM.IsLabelNoUnique(const LabelValue: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to ListVarTmp.Count - 1 do
  begin
    if SameText(LabelValue, ListVarTmp[I]) then
    begin
      Result := True;
      Break;
    end;
  end;
end;


/// <summary>
/// Verifica si un nombre de campo coincide con una palabra reservada.
/// </summary>
/// <param name="FieldName">El nombre del campo a verificar.</param>
/// <returns>True si el nombre es una palabra reservada; False en caso contrario.</returns>

function TUDM.IsReservedField(const FieldName: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(ReservedFields) to High(ReservedFields) do
  begin
    if SameText(FieldName, ReservedFields[I]) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

/// <summary>
/// Verifica si un nombre de campo contiene caracteres inválidos.
/// </summary>
/// <param name="FieldName">El nombre del campo a validar.</param>
/// <returns>True si el nombre es válido; False si contiene caracteres inválidos.</returns>
function TUDM.IsValidFieldName(const FieldName: string): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 1 to Length(FieldName) do
  begin
    if FieldName[I] in InvalidChars then
    begin
      Result := False;
      Break;
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

procedure TUDM.ListAvailableSQLServers(Names: TStrings);
var
  RSCon: ADORecordsetConstruction;
  Rowset: IRowset;
  SourcesRowset: ISourcesRowset;
  SourcesRecordset: _Recordset;
  SourcesName, SourcesType: TField;
begin
  //Lista los servidores SQL Server disponibles en la RED...
  Screen.Cursor := crSQLWait;
  SourcesRecordset := PtCreateADOObject(CLASS_Recordset) as _Recordset;
  RSCon := SourcesRecordset as ADORecordsetConstruction;
  SourcesRowset := CreateComObject(ProgIDToClassID('SQLOLEDB Enumerator')) as ISourcesRowset;
  OleCheck(SourcesRowset.GetSourcesRowset(nil, IRowset, 0, nil, IUnknown(Rowset)));
  RSCon.Rowset := Rowset;
  with TADODataSet.Create(nil) do
  try
    Recordset := SourcesRecordset;
    SourcesName := FieldByName('SOURCES_NAME'); { do not localize }
    SourcesType := FieldByName('SOURCES_TYPE'); { do not localize }
    Names.BeginUpdate;
    try
      while not EOF do
      begin
        if (SourcesType.AsInteger = DBSOURCETYPE_DATASOURCE) and (SourcesName.AsString <> '') then
          Names.Add(SourcesName.AsString);
        Next;
      end;
    finally
      Names.EndUpdate;
    end;
  finally
    Free;
  end;
  Screen.Cursor := crDefault;
end;

procedure TUDM.LoadAndRunReport(const ReportFileName: string);
var
  Report: TfrxReport;
  i: Integer;
  ADODataSet: TADODataSet;
  DBDataset: TfrxDBDataset;
begin
  if not Assigned(ReportConnection) then
    InitializeConnection;

  Report := TfrxReport.Create(nil);
  try
    Report.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Reportes\' + ReportFileName); // Ruta a tu carpeta de reportes
    for i := 0 to Report.ComponentCount - 1 do
      if Report.Components[i] is TfrxADOQuery then
        TfrxADOQuery(Report.Components[i] as TfrxADOQuery).Open();
      {
    // Buscar el componente TfrxDBDataset en el reporte
    DBDataset := Report.FindObject('Dataset') as TfrxDBDataset;
    if Assigned(DBDataset) then
    begin
      // Asignar la conexión ADO a los datasets del reporte
      ADODataSet := TADODataSet.Create(nil);
      try
        ADODataSet.Connection := ReportConnection;
        DBDataset.DataSet := ADODataSet;
        // Configurar el ADODataSet si es necesario
        ADODataSet.Close; // Cerrar para evitar la apertura innecesaria
        ADODataSet.Open; // Abrir el dataset
      except
        on E: Exception do
          ShowMessage('Error al configurar el dataset: ' + E.Message);
      end;
    end
    else
      ShowMessage('No se encontró el dataset "Dataset" en el reporte.');  }

    Report.PrepareReport(False);
    Report.ShowPreparedReport; // O usa Print, Export, etc.
  except
    on E: Exception do
      ShowMessage('Error al ejecutar el reporte: ' + E.Message);
  end;
  Report.Free;
end;

procedure TUDM.LoadGridLayout(GridView: TcxGridTableView; const LayoutName: string);
begin
  // Si el archivo INI existe, restaurar la configuración
  if FileExists(LayoutName) then
    GridView.RestoreFromIniFile(LayoutName);
end;

procedure TUDM.LoadTreeViewState2(TreeView: TTreeView; const FileName: string; tb_tree, tb_seriestree, tb_seriesdatos: TDataSet);

  function BookmarkToString(Bookmark: TBookmark): string;
  begin
    SetString(Result, PAnsiChar(Bookmark), Length(Bookmark));
  end;

  function StringToBookmark(const S: string): TBookmark;
  begin
    SetLength(Result, Length(S));
    Move(PAnsiChar(S)^, Result[0], Length(S));
  end;

var
  IniFile: TIniFile;
  Node: TTreeNode;
  i, SelectedIndex: Integer;
  Expanded: Boolean;
  MousePos: TPoint;
  Bookmark_tree, Bookmark_seriestree, Bookmark_seriesdatos: TBookmark;
  NodeText: string;
begin
  // Abrimos el archivo .ini
  IniFile := TIniFile.Create(FileName);
  try
    // Restaura el estado de expansión de cada nodo
    for i := 0 to TreeView.Items.Count - 1 do
    begin
      Node := TreeView.Items[i];
      NodeText := 'Node' + IntToStr(Node.AbsoluteIndex);

      // Normalizamos la comparación de cadenas con AnsiCompareText para evitar problemas con caracteres especiales
      Expanded := IniFile.ReadBool('TreeViewState', NodeText, False);
      Node.Expanded := Expanded;
    end;

    // Restaura el nodo seleccionado (si existe)
    SelectedIndex := IniFile.ReadInteger('TreeViewState', 'SelectedNode', -1);
    if SelectedIndex <> -1 then
    begin
      Node := TreeView.Items[SelectedIndex];
      if Node <> nil then
      begin
        TreeView.Selected := Node; // Selecciona el nodo

        // Ahora simulamos el evento OnMouseDown para el nodo seleccionado
        if Assigned(TreeView.OnMouseDown) then
        begin
          // Calcula la posición del nodo seleccionado para simular el clic
          MousePos := TreeView.ClientToScreen(Point(Node.DisplayRect(True).Left, Node.DisplayRect(True).Top));

          // Dispara el evento OnMouseDown
          TreeView.OnMouseDown(TreeView, mbLeft, [], MousePos.X, MousePos.Y);
        end;
      end;
    end;

   { // Restaura los bookmarks de las tablas
    if tb_tree.Active then
    begin
      Bookmark_tree := StringToBookmark(IniFile.ReadString('TableState', 'tb_tree', ''));
      if Bookmark_tree <> nil then
        tb_tree.Bookmark := Bookmark_tree;
    end;

    if tb_seriestree.Active then
    begin
      Bookmark_seriestree := StringToBookmark(IniFile.ReadString('TableState', 'tb_seriestree', ''));
      if Bookmark_seriestree <> nil then
        tb_seriestree.Bookmark := Bookmark_seriestree;
    end;

    if tb_seriesdatos.Active then
    begin
      Bookmark_seriesdatos := StringToBookmark(IniFile.ReadString('TableState', 'tb_seriesdatos', ''));
      if Bookmark_seriesdatos <> nil then
        tb_seriesdatos.Bookmark := Bookmark_seriesdatos;
    end;   }
  finally
    IniFile.Free;
  end;
end;

procedure TUDM.LoadTreeViewState(TreeView: TTreeView; const FileName: string);
var
  IniFile: TIniFile;
  Node: TTreeNode;
  i, SelectedIndex: Integer;
  Expanded: Boolean;
  MousePos: TPoint;
begin
  CargandoEstado := True;
  IniFile := TIniFile.Create(FileName);
  try
    // Restaura el estado de expansión de cada nodo
    for i := 0 to TreeView.Items.Count - 1 do
    begin
      Node := TreeView.Items[i];
      Expanded := IniFile.ReadBool('TreeViewState', 'Node' + IntToStr(Node.AbsoluteIndex), False);
      Node.Expanded := Expanded;
    end;

    // Restaura el nodo seleccionado (si existe)
    SelectedIndex := IniFile.ReadInteger('TreeViewState', 'SelectedNode', -1);
    if SelectedIndex <> -1 then
    begin
      Node := TreeView.Items[SelectedIndex];
      if Node <> nil then
      begin
        TreeView.Selected := Node; // Selecciona el nodo
        NodoSel := Node.Text;
        // Ahora simulamos el evento OnMouseDown para el nodo seleccionado
        if Assigned(TreeView.OnMouseDown) then
        begin
          // Calcula la posición del nodo seleccionado para simular el clic
          MousePos := TreeView.ClientToScreen(Point(Node.DisplayRect(True).Left, Node.DisplayRect(True).Top));

          // Dispara el evento OnMouseDown
          TreeView.OnMouseDown(TreeView, mbLeft, [], MousePos.X, MousePos.Y);
        end;
      end;
    end;
  finally
    CargandoEstado := False;
    IniFile.Free;
  end;
end;

procedure TUDM.log(Mensaje: string; acc: Integer; aSerie, aSSerie, aStructura: string);
var
  F: TextFile;
  Filename: string;
  Mutex: THandle;
  FileSearch: TSearchRec;
  cad: string;
  flag: Boolean;
begin
  with tb_log do
  begin
    Append;
    FieldByName('usuariopc').AsString := DatosPC.Usuario;
    FieldByName('pc').AsString := DatosPC.Nombre;
    FieldByName('fecha').AsString := FormatDateTime('[ddd dd mmm, hh:nn:ss:zzz]', Now);
    FieldByName('ip').AsString := DatosPC.IP;
    FieldByName('usuario_sistema').AsString := UDM.UserName;
    FieldByName('accion').AsInteger := acc;
    FieldByName('rol').AsString := UDM.Rol;
    FieldByName('msg').AsString := Mensaje;
    FieldByName('serie').AsString := aSerie;
    FieldByName('subserie').AsString := aSSerie;
    FieldByName('idestructura').AsString := aStructura;
    try
      Post;
    except
      on E: EFDException do
      begin
        Cancel;
      end;
    end;
  end;

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

procedure TUDM.MostrarReporte(const NombreReporte: string);
var
  Reporte: TfrxReport;
  Componente: TfrxComponent;
  RutaReporte: string;
  RutaLogo: string;
  i: Integer;
begin
  // Registrar acción en el log
  UDM.log('Visualizando el reporte: ' + NombreReporte, 14, '', '', '');

  // Validar configuración de la empresa y logo
  if (Trim(UDM.tb_sysconfig.FieldByName('empresa').AsString) = '') or (TBlobField(UDM.tb_sysconfig.FieldByName('logo')).IsNull) then
  begin
    MessageDlg('Debe configurar los datos de la empresa. Diríjase a la configuración del sistema.', mtError, [mbOK], 0);
    Exit;
  end;

  try
    // Inicializar variables
    Reporte := frxMain;
    RutaLogo := pathreport + 'logo.png';
    RutaReporte := pathreport + 'r' + NombreReporte + '.fr3';

    // Verificar si el archivo del reporte existe
    if not FileExists(RutaReporte) then
    begin
      MessageDlg('El archivo del reporte no existe: ' + RutaReporte, mtError, [mbOK], 0);
      Exit;
    end;

    // Guardar el logo desde la base de datos al sistema de archivos
    TBlobField(UDM.tb_sysconfig.FieldByName('logo')).SaveToFile(RutaLogo);

    // Cargar el archivo del reporte
    if not Reporte.LoadFromFile(RutaReporte) then
    begin
      MessageDlg('No se pudo cargar el reporte desde ' + RutaReporte, mtError, [mbOK], 0);
      Exit;
    end;

    // Configurar la conexión a la base de datos
    with TfrxADODatabase(Reporte.FindComponent('conn')) do
    begin
      Connected := False;
      if TBD = 'A' then
        DatabaseName := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + PathBD + ';Persist Security Info=False'
      else
        DatabaseName := 'Provider=SQLOLEDB.1;Password=geoconn;Persist Security Info=True;User ID=geoconn;' + 'Initial Catalog=SDbd;Data Source=' + UDM.tb_sysconfig.FieldByName('ipservidorbd').AsString;
      Connected := True;
    end;

    // Activar las consultas ADO sin parámetros
    for i := 0 to Reporte.ComponentCount - 1 do
    begin
      if Reporte.Components[i] is TfrxADOQuery then
      begin
        if TfrxADOQuery(Reporte.Components[i]).Params.Count = 0 then
        begin
          TfrxADOQuery(Reporte.Components[i]).Active := True;
        end;
      end;
    end;

    // Configurar el nombre de la empresa
    Componente := Reporte.FindObject('empresa');
    if Componente is TfrxRichView then
    begin
      TfrxRichView(Componente).DataSet := frxtb_sysconfig;
      TfrxRichView(Componente).DataField := 'empresa';
    end;

    // Configurar la imagen del logo
    Componente := Reporte.FindObject('imagen');
    if Componente is TfrxPictureView then
      TfrxPictureView(Componente).Picture.LoadFromFile(RutaLogo);

    // Preparar y mostrar el reporte
    Reporte.PrepareReport;
    Reporte.ShowReport;

  except
    on E: Exception do
    begin
      MessageDlg('Error al generar el reporte "' + NombreReporte + '": ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TUDM.MueveBar(aBAR: PBarra; increment: integer);
begin
  aBAR.Progress := increment;
  aBAR.Update;
end;

procedure TUDM.ObtenerDatosPC(var Datos: TDatosPC);
const
  LARGO_MAXIMO = 50;
var
  buffer: array[0..LARGO_MAXIMO + 1] of char;
  Largo: Cardinal;
  PuntHost: PHostEnt;
  PuntIP: PAnsichar;
  wVersionRequested: WORD;
  wsaData: TWSAData;
begin
  Largo := LARGO_MAXIMO + 1;
  Datos.Nombre := '';
  if GetComputerName(buffer, Largo) then
    Datos.Nombre := buffer;
  Largo := SizeOf(buffer);
  GetUserName(buffer, Largo);
  Datos.Usuario := buffer;
  wVersionRequested := MAKEWORD(1, 1);
  WSAStartup(wVersionRequested, wsaData);
  GetHostName(@buffer, LARGO_MAXIMO);
  PuntHost := GetHostByName(@buffer);
  PuntIP := iNet_ntoa(PInAddr(PuntHost^.h_addr_list^)^);
  Datos.IP := PuntIP;
  WSACleanup;
end;

function TUDM.ObtenerNombreTabla(const TableName: string): string;
var
  SQLText: string;
begin
  Result := '';
  SQLText := UDM.Conn.ExecSQLScalar(TableName);
  try
    // Usar ExecSQLScalar para verificar si la tabla existe
    if not VarIsNull(SQLText) then
      Result := SQLText; // Si la consulta tiene éxito, devolvemos el nombre de la tabla
  except
    on E: Exception do
      Exit; // Si falla, devolvemos cadena vacía
  end;
end;

destructor TUDM.Destroy;
begin
  FreeAndNil(Alcance);
  inherited;
end;

procedure TUDM.EstablecerAlcance(const Usuario: string; EsAdministrador: Boolean);
var
  ErrorAlcance: string;
begin
  if TBD <> 'S' then
    Exit; // Access: sin seguridad por alcance
  FreeAndNil(Alcance);
  Alcance := CargarAlcanceSeguro(Conn, Usuario, EsAdministrador, ErrorAlcance);
  AplicarFiltrosAlcance;
  if ErrorAlcance <> '' then
    sms('No se pudo cargar el alcance del usuario; no tendra acceso a datos hasta corregirlo.' +
      sLineBreak + ErrorAlcance, 1);
end;

// Unico punto donde la seguridad por alcance toca las consultas: el arbol
// (tb_tree y tb_arbol) y la lista de documentos (tb_SeriesDatos).
procedure TUDM.AplicarFiltrosAlcance;
const
  SQL_ARBOL = 'select * from tb_tree  Order by id ASC';
  SQL_DOCS = 'SELECT * FROM tb_SeriesDatos ORDER BY Codigodoc ASC';
var
  Consultas: array[0..5] of TFDQuery;
  Activas: array[0..5] of Boolean;
  I: Integer;
  FArbol, FDocs: TFiltroSql;

  procedure Poner(Q: TFDQuery; const Sql: string; const Filtro: TFiltroSql);
  begin
    Q.SQL.Text := Sql;
    if Alcance <> nil then
      AplicarParametros(Q, Filtro);
  end;

begin
  // detalle -> maestro; se reabren en orden inverso
  Consultas[0] := tb_ssArchdigital;
  Consultas[1] := tb_DocCoord;
  Consultas[2] := tb_SeriesDatos;
  Consultas[3] := tb_Serietree;
  Consultas[4] := tb_tree;
  Consultas[5] := tb_arbol;
  for I := 0 to High(Consultas) do
  begin
    Activas[I] := Consultas[I].Active;
    Consultas[I].Active := False;
  end;
  if Alcance = nil then
  begin
    tb_tree.SQL.Text := SQL_ARBOL;
    tb_arbol.SQL.Text := SQL_ARBOL;
    tb_SeriesDatos.SQL.Text := SQL_DOCS;
  end
  else
  begin
    FArbol := FiltroNodosArbol(Alcance, '');
    FDocs := FiltroDocumentos(Alcance, '');
    Poner(tb_tree, 'select * from tb_tree where ' + FArbol.Condicion + '  Order by id ASC', FArbol);
    Poner(tb_arbol, 'select * from tb_tree where ' + FArbol.Condicion + '  Order by id ASC', FArbol);
    Poner(tb_SeriesDatos, 'SELECT * FROM tb_SeriesDatos WHERE ' + FDocs.Condicion + ' ORDER BY Codigodoc ASC', FDocs);
  end;
  for I := High(Consultas) downto 0 do
    if Activas[I] then
      Consultas[I].Active := True;
end;

procedure TUDM.OverLoadADL;
begin
  try
    tb_ssArchdigital.Active := False;
    tb_DocCoord.Active := False;
    tb_seriesdatos.Active := False;
    tb_Serietree.Active := False;
    tb_tree.Active := False;
    tb_tree.Active := true;
    tb_Serietree.Active := true;
    tb_seriesdatos.Active := true;
    tb_ssArchdigital.Active := true;
    tb_DocCoord.Active := True;
    tb_tree.FetchAll();
    tb_Serietree.FetchAll();
    tb_seriesdatos.FetchAll();
    tb_ssArchdigital.FetchAll();
    tb_DocCoord.FetchAll();
    tb_transferencia.FetchAll();
    qryAnexosDig.FetchAll();
    qryFuentesDig.FetchAll();
  except
    on E: EFDException do
    begin
      UDM.sms(E.Message, 1);
      Exit;
    end;

  end;

end;

procedure TUDM.ProponerValores(IdEstructura, codsubs: string; var Fecha: TDateTime; var Version, Codigodoc: string);
var
  Query: TFDQuery;
  UltimaVersion, UltimoCodigodoc: string;
  SufijoNumerico, ParteAlfabetica: string;
  UltimoNumero, i: Integer;
//  fecha1:TDate

  function ExisteCodigodoc(const Codigo: string): Boolean;
  begin
    Query.SQL.Text := 'SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc = ' + QuotedStr(Codigo);
    Query.Open;
    Result := Query.Fields[0].AsInteger > 0;
  end;

begin
  // Proponer la fecha actual para el campo Fecha
  Fecha := Now;
  Fecha := dateof(Fecha);

  // Consulta para obtener la última versión y el último codigodoc
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := UDM.Conn; // Tu conexión a la BD
    Query.SQL.Text := 'SELECT MAX(Version), MAX(Codigodoc) FROM tb_SeriesDatos WHERE IdEstructura =' + QuotedStr(IdEstructura) + ' AND codsubs =' + QuotedStr(codsubs);
    Query.Open;
    if not Query.IsEmpty then
    begin
      UltimaVersion := Query.Fields[0].AsString;
      UltimoCodigodoc := Query.Fields[1].AsString;
    end;
  finally
    Query.Free;
  end;

  // Proponer una nueva versión
  Version := '1.0';
  // Proponer un nuevo codigodoc y asegurar su unicidad
  if UltimoCodigodoc = '' then
  begin
    // Formar el código usando IdEstructura + codsubs + version
    Codigodoc := IdEstructura + codsubs + Version;
  end
  else
  begin
    // Suponer que el codigodoc sigue el patrón 'DOC###'
    i := Length(UltimoCodigodoc);
    while (i > 0) and (UltimoCodigodoc[i] in ['0'..'9']) do
      Dec(i);

    ParteAlfabetica := Copy(UltimoCodigodoc, 1, i);
    SufijoNumerico := Copy(UltimoCodigodoc, i + 1, Length(UltimoCodigodoc) - i);

    // Incrementar el número
    if TryStrToInt(SufijoNumerico, UltimoNumero) then
      Inc(UltimoNumero)
    else
      UltimoNumero := 1;

    // Proponer el nuevo codigodoc
    Codigodoc := ParteAlfabetica + Format('%.3d', [UltimoNumero]);
  end;

  // Asegurar que el codigodoc sea único en la tabla
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := UDM.Conn; // Tu conexión a la BD
    while ExisteCodigodoc(Codigodoc) do
    begin
      // Incrementar el sufijo numérico para buscar un código único
      Inc(UltimoNumero);
      Codigodoc := ParteAlfabetica + Format('%.3d', [UltimoNumero]);
    end;
  finally
    Query.Free;
  end;
end;

function TUDM.PtCreateADOObject(const ClassID: TGUID): IUnknown;
var
  Status: HRESULT;
  FPUControlWord: Word;
begin
  //función utilizada para devolver los Servidores SQL Server disponibles en la RED...
  asm
        FNSTCW  FPUControlWord
  end;
  Status := CoCreateInstance(CLASS_Recordset, nil, CLSCTX_INPROC_SERVER or CLSCTX_LOCAL_SERVER, IUnknown, Result);
  asm
        FNCLEX
        FLDCW   FPUControlWord
  end;
  OleCheck(Status);
end;

function TUDM.QuitaCaracter(Temp: string): string;
var
  i: Integer;
  Caracter: Char;
begin
  Result := '';
  for i := 1 to Length(Temp) do
  begin
    Caracter := Temp[i];
    // Verifica si el caracter es alfanumérico (letras y números) o un espacio
    if Caracter in ['A'..'Z', 'a'..'z', '0'..'9'] then
      Result := Result + Caracter
    else
      Result := Result + '_'; // Sustituye el caracter especial por "_"
  end;
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
      try
        for j := 0 to nombregrid.ColumnCount - 1 do
        begin
          nombregrid.Columns[j].DataBinding.FieldName := l.strings[i];
          nombregrid.Columns[j].Width := strtoint(l.strings[i + 1]);
          nombregrid.Columns[j].Visible := strtobool(l.strings[i + 2]);
          i := i + 3;
        end;
      except

      end;
    finally
      l.free;
    end;

  end;

end;

procedure TUDM.RollbackTransaction;
begin
  if conn.InTransaction then
    conn.Rollback;
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

procedure TUDM.SaveGridLayout(GridView: TcxGridTableView; const LayoutName: string);
begin
  // Guarda la configuración actual del cxGrid en un archivo INI
  GridView.StoreToIniFile(LayoutName);
end;

procedure TUDM.SaveTreeViewState2(TreeView: TTreeView; const FileName: string; tb_tree, tb_seriestree, tb_seriesdatos: TDataSet);
var
  IniFile: TIniFile;
  Node: TTreeNode;
  i: Integer;
  Bookmark_tree, Bookmark_seriestree, Bookmark_seriesdatos: TBookmark;

  function BookmarkToString(Bookmark: TBookmark): string;
  begin
    SetString(Result, PAnsiChar(Bookmark), Length(Bookmark));
  end;

  function StringToBookmark(const S: string): TBookmark;
  begin
    SetLength(Result, Length(S));
    Move(PAnsiChar(S)^, Result[0], Length(S));
  end;

begin
  IniFile := TIniFile.Create(FileName);
  try
    IniFile.EraseSection('TreeViewState'); // Limpia cualquier dato previo

    // Guarda el estado de expansión de cada nodo
    for i := 0 to TreeView.Items.Count - 1 do
    begin
      Node := TreeView.Items[i];
      IniFile.WriteBool('TreeViewState', 'Node' + IntToStr(Node.AbsoluteIndex), Node.Expanded);
    end;

    // Guarda el nodo seleccionado (si existe uno)
    if TreeView.Selected <> nil then
      IniFile.WriteInteger('TreeViewState', 'SelectedNode', TreeView.Selected.AbsoluteIndex)
    else
      IniFile.DeleteKey('TreeViewState', 'SelectedNode');
    {
    // Guarda los bookmarks de las tablas
    if tb_tree.Active then
    begin
      Bookmark_tree := tb_tree.GetBookmark;
      IniFile.WriteString('TableState', 'tb_tree', BookmarkToString(Bookmark_tree));
    end;

    if tb_seriestree.Active then
    begin
      Bookmark_seriestree := tb_seriestree.GetBookmark;
      IniFile.WriteString('TableState', 'tb_seriestree', BookmarkToString(Bookmark_seriestree));
    end;

    if tb_seriesdatos.Active then
    begin
      Bookmark_seriesdatos := tb_seriesdatos.GetBookmark;
      IniFile.WriteString('TableState', 'tb_seriesdatos', BookmarkToString(Bookmark_seriesdatos));
    end;   }
  finally
    IniFile.Free;
  end;
end;

procedure TUDM.SaveTreeViewState(TreeView: TTreeView; const FileName: string);
var
  IniFile: TIniFile;
  Node: TTreeNode;
  i: Integer;
begin
  IniFile := TIniFile.Create(FileName);
  try
    IniFile.EraseSection('TreeViewState'); // Limpia cualquier dato previo

    // Guarda el estado de expansión de cada nodo
    for i := 0 to TreeView.Items.Count - 1 do
    begin
      Node := TreeView.Items[i];
      IniFile.WriteBool('TreeViewState', 'Node' + IntToStr(Node.AbsoluteIndex), Node.Expanded);
    end;

    // Guarda el nodo seleccionado (si existe uno)
    if TreeView.Selected <> nil then
      IniFile.WriteInteger('TreeViewState', 'SelectedNode', TreeView.Selected.AbsoluteIndex)
    else
      IniFile.DeleteKey('TreeViewState', 'SelectedNode'); // Elimina si no hay selección
  finally
    IniFile.Free;
  end;
end;

// Función: TUDM.sms
// Propósito: Muestra un cuadro de diálogo con un mensaje y estilo según el tipo especificado.
//            Retorna el resultado del diálogo (IDOK, IDYES, IDNO, etc.).
// Autor: [Optimizado por Grok 3, xAI]
// Fecha: 11 de abril de 2025
// Mejoras aplicadas:
//   - Validación de aText para evitar mensajes vacíos.
//   - Manejo de aTipo inválido con un valor por defecto (Información).
//   - Título personalizable con valores predeterminados según aTipo.
//   - Uso de PChar para compatibilidad con Application.MessageBox.
//   - Estructura más clara y segura.

function TUDM.sms(aText: string; aTipo: Integer; aTitle: string = ''): Integer;
const
  DEFAULT_TITLES: array[1..4] of string = ('¡Error!', '¡Alerta!', '¡Información!', '¡Confirmación!');
  DEFAULT_TYPE = 3; // Información como tipo por defecto
var
  Title: string;
  MessageFlags: Cardinal;
begin
  // Validar texto de entrada
  if Trim(aText) = '' then
  begin
    Result := IDOK;
    Exit;
  end;

  // Determinar título
  if aTitle = '' then
  begin
    if (aTipo >= 1) and (aTipo <= 4) then
      Title := DEFAULT_TITLES[aTipo]
    else
      Title := DEFAULT_TITLES[DEFAULT_TYPE];
  end
  else
    Title := aTitle;

  // Configurar mensaje según tipo
  case aTipo of
    1: // Error
      MessageFlags := MB_OK + MB_ICONERROR + MB_DEFBUTTON1 + MB_APPLMODAL;
    2: // Alerta
      MessageFlags := MB_OK + MB_ICONEXCLAMATION + MB_DEFBUTTON1 + MB_APPLMODAL;
    3: // Información
      MessageFlags := MB_OK + MB_ICONINFORMATION + MB_DEFBUTTON1 + MB_APPLMODAL;
    4: // Confirmación
      begin
        aText := aText + '.'; // Mantener el punto final para confirmaciones
        MessageFlags := MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON1 + MB_APPLMODAL;
      end;
  else
    begin
        // Tipo desconocido: usar Información como predeterminado
      MessageFlags := MB_OK + MB_ICONINFORMATION + MB_DEFBUTTON1 + MB_APPLMODAL;
      Title := DEFAULT_TITLES[DEFAULT_TYPE];
    end;
  end;

  // Mostrar diálogo usando PChar
  Result := Application.MessageBox(PChar(aText), PChar(Title), MessageFlags);
end;

procedure TUDM.StartTransaction;
begin
  if not conn.InTransaction then
    conn.StartTransaction;
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

function TUDM.SubserieTieneVariables(codsubs: string): Boolean;
var
  Query: TFDQuery;
begin
  // Inicializamos el resultado en False
  Result := False;

  // Creamos la consulta SQL para verificar si existen variables para la subserie
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := UDM.Conn; // Tu conexión a la base de datos
    Query.SQL.Text := 'SELECT COUNT(*) FROM cl_VarSubserie ' + 'WHERE codsubs = ' + QuotedStr(codsubs);
    Query.Open;

    // Si el conteo es mayor a 0, entonces existen variables definidas
    if Query.Fields[0].AsInteger > 0 then
      Result := True;
  finally
    Query.Free;
  end;
end;

function TUDM.TablaExiste(Connection: TFDConnection; const NombreTabla: string): Boolean;
var
  MetaInfoQuery: TFDMetaInfoQuery;
begin
  Result := False; // Inicializa el resultado como False
  MetaInfoQuery := TFDMetaInfoQuery.Create(nil);
  try
    MetaInfoQuery.Connection := Connection;
    MetaInfoQuery.MetaInfoKind := mkTables; // Especifica que queremos información sobre tablas
    MetaInfoQuery.ObjectName := NombreTabla; // Asigna el nombre de la tabla

    // Abre la consulta
    MetaInfoQuery.Open;
    Result := MetaInfoQuery.Locate('TABLE_NAME', NombreTabla, []);
  finally
    MetaInfoQuery.Free;
  end;
end;

procedure TUDM.ActivaDataLayer(aValue: boolean);
begin
  //Activando tablas de la base de datos....
  AllSubSerie.Active := aValue;
  ServidoresDisponibles.Active := aValue;
  ServidoresDisponibles.FetchAll;
  tb_sysconfig.Active := aValue;
  cl_tipoexp.Active := aValue;
  cmdServer.Active := aValue;
  //cl_expediente.Active := aValue;
  CL_ArchivoDpto.Active := aValue;
  CL_ArchivoDpto.FetchAll;
  cl_tipoobj.Active := aValue;
  cl_tipoobj.FetchAll;
  cl_acceso.Active := aValue;
  cl_acceso.FetchAll;
  cl_ArchivosGestion.Active := aValue;
  cl_tipodoc.Active := aValue;
  cl_especialista.Active := aValue;
  cl_destino.Active := aValue;
  cl_frecuencia.Active := aValue;
  cl_series.Active := aValue;
  cl_soporte.Active := aValue;
  cl_subseries.Active := aValue;
  CL_SubseriesTipoVar.Active := aValue;
  cl_VarSubserie.Active := aValue;
  cl_tipodoc.Active := aValue;
  cl_Resp_Gest_Arch.Active := aValue;
  cl_ftp_Server.Active := aValue;
  cl_tipoestructura.Active := aValue;
  cl_tiposerie.Active := aValue;
  cl_tipoarch.Active := aValue;
  cl_valordoc.Active := aValue;
  cl_vigencia.Active := aValue;
  AllFather.Active := aValue;
  CL_Nodos.Active := aValue;
  cl_nodopadre.Active := aValue;
  tb_arbol.Active := aValue;
  tb_transferencia.Active := aValue;
  tb_ext.Active := aValue;
  tb_EstructDisp.Active := aValue;
  tb_tree.Active := aValue;
  tb_Serietree.Active := aValue;
  tb_Serietree.FetchAll;
  tb_seriesdatos.Active := aValue;
  TB_Prestamos.Active := aValue;
  TB_PrestamosDocumentos.Active := aValue;
  tb_ssArchdigital.Active := aValue;
  tb_DocCoord.Active := aValue;
  tb_DocCoord.FetchAll;
  tb_indice.Active := aValue;
  //usuarios y Rol
  Tb_Rol.Active := aValue;
  tb_accionlog.Active := aValue;
  tb_log.Open();
  tb_log.FetchAll();
  qryAnexosDig.Active := aValue;
  qryAnexosDig.FetchAll;
  qryFuentesDig.Active := aValue;
  qryFuentesDig.FetchAll;
  tb_expxseries.Active := aValue;
  tb_expxseries.FetchAll;
  if not UDM.tb_expxseries.Active then
    UDM.tb_expxseries.Active := True;
  {if not tb_expxtiposerie.Active then
    tb_expxtiposerie.Active := True;}
end;

procedure TUDM.tb_SeriesDatosAfterDelete(DataSet: TDataSet);
begin
  if not EstoyActualizando then
    UDM.log('El documento "' + DataSet.FieldByName('titulodoc').AsString + '" con código "' + DataSet.FieldByName('Codigodoc').AsString + '" fue eliminado.', 2, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('Nombreestructura').AsString);
end;

procedure TUDM.tb_SeriesDatosAfterEdit(DataSet: TDataSet);
begin
  if not EstoyActualizando then
    UDM.log('Modificando el documento. "' + DataSet.FieldByName('titulodoc').AsString + '" con código "' + DataSet.FieldByName('Codigodoc').AsString + '".', 3, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('Nombreestructura').AsString);
end;

procedure TUDM.tb_SeriesDatosAfterPost(DataSet: TDataSet);
var
  existe: Boolean;
  nombretmptable, serie, subserie, NombreCarat: string;
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
  RutaDestino, RutaOrigen: string;

  function GetSeriesNameFile(aFecha: TDate): string;
  var
    fe: string;
  begin
    fe := datetostr(aFecha) + '' + TimeToStr(Now);
    fe := AnsiReplaceStr(fe, '/', '');
    fe := AnsiReplaceStr(fe, ' ', '');
    fe := AnsiReplaceStr(fe, ':', '');
    result := fe;
  end;

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

  function ConstruirRutaArchivo(const ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc: string): string;
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

  function GetFileNameWithoutExtension(const FilePath: string): string;
  begin
    Result := ChangeFileExt(ExtractFileName(FilePath), '');
  end;

begin
  // Verificar si ya existe la tabla para la nueva subserie
  nombretmptable := UDM.QuitaCaracter('md_' + UDM.SudSDetail.FieldByName('codserie').AsString + UDM.tb_SeriesDatos.FieldByName('codsubs').AsString);
  existe := UDM.TablaExiste(UDM.Conn, nombretmptable);
  if not existe then
  begin
    serie := UDM.Conn.ExecSQLScalar('select codserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString));
    if not existe then
      UDM.CreateTableFromDefinitions(nombretmptable, UDM.tb_SeriesDatos.FieldByName('codsubs').AsString);
  end;
  if UDM.tb_expxseries.Active then
    UDM.tb_expxseries.Refresh;
  if udm.tb_expxtiposerie.Active then
    udm.tb_expxtiposerie.Refresh;
  if not GestionFile then
    if UDM.tb_expxseries.Locate('codsubs', UDM.tb_SeriesDatos.FieldByName('codsubs').AsString, []) then
    begin
      if (trim(UDM.tb_SeriesDatos.FieldByName('Fichero').AsString) = '') or (UDM.tb_SeriesDatos.FieldByName('Fichero').Value = null) then
      begin
        if UDM.sms('No se ha encontrado un documento definido. ¿Desea definir una carátula para el expediente actual?', 4) = 6 then
        begin
          ObtenerDatosPrincipales;
          NombreCarat := {CodigoDoc+'_'+ }GetSeriesNameFile(StrToDate(UDM.tb_SeriesDatos.FieldByName('Fecha').AsString)) + EXTENSION_PDF;
          if TBD = 'A' then // MS Access
            ExportarReporteAPDFyoyo(dbAccess, [PathBD], PathCarat + NombreCarat)
          else // SQL Server
            ExportarReporteAPDFyoyo(dbSQLServer, [ServerName, dbname, 'geoconn', 'geoconn'], PathCarat + NombreCarat);

          PathSaveBinaryFile := ConstruirRutaArchivo(ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc) + '_' + NombreCarat;
          RutaDestino := AnsiReplaceStr(PathSaveBinaryFile, SEPARADOR_RUTA, SEPARADOR_FTP);
          RutaDestino := AnsiReplaceStr(RutaDestino, SEPARADOR_FTP + SEPARADOR_FTP, SEPARADOR_FTP);
          RutaOrigen := PathCarat + NombreCarat;
          UDM.CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, RutaOrigen, UDM.cmdServer.FieldByName('path').AsString + RutaDestino, 'O', UDM.cmdServer.FieldByName('puerto').AsInteger);
          DataSet.Edit;
          DataSet.FieldByName('fichero').AsString := RutaDestino;
          DataSet.FieldByName('namefile').AsString := GetFileNameWithoutExtension(NombreCarat);
          try
            DataSet.Post;
            sms('La carátula se ha generado satisfactoriamente.', 3);
          except
            DataSet.Cancel;
          end;
        end;
      end;
    end;

end;

procedure TUDM.tb_SeriesDatosBeforeDelete(DataSet: TDataSet);
var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  NombreFile: string;
  PathF, CaminoFichero, DirAsociado: string;

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
  if (ansilowercase(UDM.Rol) <> 'administrador') and (ansilowercase(UDM.Rol) <> 'gestor') then
  begin
    UDM.sms('No tiene permisos suficientes para realizar la operación solicitada.', 2);
    DataSet.Cancel;
    Exit;
  end;
  if (DataSet.FieldByName('fichero').Value <> NULL) or (trim(DataSet.FieldByName('fichero').AsString) <> '') then
  begin

    if UDM.sms('¿Está seguro de eliminar el fichero actual?', 4) = 6 then
    begin
      UDM.tb_ssArchdigital.Last;
      while not udm.tb_ssArchdigital.Bof do
      begin
        CaminoFichero := UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString + UDM.tb_ssArchdigital.FieldByName('path').AsString + UDM.tb_ssArchdigital.FieldByName('nombre').AsString;
        CaminoFichero := AnsiReplaceStr(CaminoFichero, '\', '/');
        CaminoFichero := AnsiReplaceStr(CaminoFichero, '//', '/');
        try
          UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
        except
        end;
        try
          udm.tb_ssArchdigital.Delete;
        except
        end;
        UDM.tb_ssArchdigital.Next;
      end;
      CaminoFichero := UDM.cmdServer.FieldByName('path').AsString + '/' + DataSet.FieldByName('fichero').AsString;
      CaminoFichero := AnsiReplaceStr(CaminoFichero, '\', '/');
      CaminoFichero := AnsiReplaceStr(CaminoFichero, '///', '/');
      CaminoFichero := AnsiReplaceStr(CaminoFichero, '//', '/');
      Path := Copy(CaminoFichero, 1, LastDelimiter('/', CaminoFichero));
      DirAsociado := Copy(CaminoFichero, LastDelimiter('/', CaminoFichero) + 1, LastDelimiter('.', CaminoFichero) - LastDelimiter('/', CaminoFichero) - 1);
      DirAsociado := Path + DirAsociado + '/';
    //Elimina AD
      try
        UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado + 'Fuentes/', UDM.cmdServer.FieldByName('puerto').AsInteger);
        UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado + 'Anexos Digitales/', UDM.cmdServer.FieldByName('puerto').AsInteger);
        UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado, UDM.cmdServer.FieldByName('puerto').AsInteger);
        UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
      except
      end;
      DataSet.Edit;
      DataSet.FieldByName('fichero').Value := null;
      try
        DataSet.Post;
        UDM.sms('El fichero se elimino del sistema satisfactoriamente.', 3);
      except
        on E: EFDException do
        begin
          DataSet.Cancel;
          UDM.sms('No se pudo eliminar el fichero del sistema. Motivo: ' + E.Message, 1);
        end;
      end;
//    edt1.Text := '(Vacio)';
    end;
  end;

 { if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    NombreFile := removeext(ExtractFileName(List[0]));
    if FileExists(List[0]) then
    begin
      DeleteFile(pwidechar(List[0]));
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
  end; }
end;

procedure TUDM.tb_SeriesDatosBeforePost(DataSet: TDataSet);

  procedure ValidateRequiredFields(DataSet: TDataSet);
  var
    FieldName: string;
  begin
    try
      if DataSet.FieldByName('titulodoc').IsNull then
        raise Exception.Create('Debe especificar un valor para el campo "Título" .');

      if DataSet.FieldByName('Codigodoc').IsNull then
        raise Exception.Create('Debe especificar un valor para el campo "Código" .');

    // Añadir más campos según sea necesario

    except
      on E: Exception do
      begin
        sms(E.Message, 2);  // O usar un componente de mensajes más sofisticado.
//      DataSet.Cancel;
        Abort; // Para detener el proceso de guardado
      end;
    end;
  end;

begin
  ValidateRequiredFields(DataSet);
end;


// Procedimiento: TUDM.tb_SeriesDatosNewRecord
// Propósito: Maneja el evento OnNewRecord de UDM.tb_SeriesDatos para inicializar un nuevo registro,
//            añadiendo un nuevo registro directamente (Append) sin posicionarse al final del dataset.
//            Valida datos topográficos y establece valores predeterminados.
// Autor: [Refactorizado e integrado por Grok 3, xAI]
// Fecha: 11 de abril de 2025
// Optimizaciones aplicadas:
//   - Eliminada la llamada a DataSet.Last para evitar operaciones costosas.
//   - Simplificación de la lógica de inserción, usando Append directamente.
//   - Cacheo de valores de campos para reducir accesos a FieldByName.
//   - Ejecución diferida de UDM.log para evitar retrasos en la UI.
//   - Control manual del cursor para evitar crSQLWait.
//   - Corrección de la verificación de SerieTree para evitar errores con Active e IsEmpty.

// Prepara un documento nuevo en tb_SeriesDatos.
// Cancela el alta (con un mensaje) si no hay subserie en el nodo actual, si el
// sistema se esta actualizando, o si faltan los datos topograficos de la
// subserie en este nodo (ver UTopografia). El mensaje depende del permiso: quien
// puede editar la topografia (administrador o EGD del nodo; todos en modo
// Access) recibe que falta; el resto recibe que avise al EGD de su nodo.
procedure TUDM.tb_SeriesDatosNewRecord(DataSet: TDataSet);
const
  MSG_SUBSERIE_REQUERIDA = 'No se puede agregar un nuevo registro porque no hay una subserie declarada en la estructura actual.';
  MSG_ACTUALIZANDO = 'No se puede agregar un registro mientras se está actualizando el sistema.';
  MSG_SUD_DETAIL_INACTIVO = 'El detalle de la subserie no está activo. Por favor, verifique la configuración.';
  MSG_SERIE_TREE_INACTIVO = 'El sistema no tiene acceso al listado de estructuras declaradas. Por favor, contacte al administrador.';
var
  Fecha: TDateTime;
  Version, Codigodoc: string;
  SerieTree: TDataSet;
  SoporteId: Integer;
  IsValid: Boolean;
  IdEstructura, CodSubs, Deposito, Posicion, Gaveta, Archivo, Gestor, IdServidor: string;
  LogMessage: string;
  Topografia: TDatosTopografia;
  PuedeEditarTopografia: Boolean;
  IdNodo: TClaveNodo;

begin
  // Forzar cursor predeterminado para evitar crSQLWait
  Screen.Cursor := crDefault;
  try
    SerieTree := UDM.tb_Serietree;

    // Verificaciones iniciales combinadas
    if not SerieTree.Active then
    begin
      UDM.sms(MSG_SERIE_TREE_INACTIVO, 3);
      DataSet.Cancel;
      Exit;
    end;
    if SerieTree.IsEmpty then
    begin
      UDM.sms(MSG_SUBSERIE_REQUERIDA, 3);
      DataSet.Cancel;
      Exit;
    end;

    if EstoyActualizando then
    begin
      UDM.sms(MSG_ACTUALIZANDO, 3);
      DataSet.Cancel;
      Exit;
    end;

    if not UDM.SudSDetail.Active then
    begin
      UDM.sms(MSG_SUD_DETAIL_INACTIVO, 3);
      DataSet.Cancel;
      Exit;
    end;

    // Cachear valores de campos para reducir accesos
    IdEstructura := SerieTree.FieldByName('IdEstructura').AsString;
    CodSubs := SerieTree.FieldByName('codsubs').AsString;
    Deposito := SerieTree.FieldByName('deposito').AsString;
//    Posicion := SerieTree.FieldByName('posicion').AsString;//
    Gaveta := SerieTree.FieldByName('gaveta').AsString;
    Archivo := SerieTree.FieldByName('Archivo').AsString;
    Gestor := SerieTree.FieldByName('gestor').AsString;
    IdServidor := SerieTree.FieldByName('idservidor').AsString;

    // Generar valores predeterminados
    ProponerValores(IdEstructura, CodSubs, Fecha, Version, Codigodoc);
    DataSet.FieldByName('Fecha').Value := Fecha;
    DataSet.FieldByName('Version').AsString := Version;
    DataSet.FieldByName('Codigodoc').AsString := Codigodoc;

    // Validar datos topográficos
    SoporteId := UDM.SudSDetail.FieldByName('idsoporte').AsInteger;
    Topografia.Deposito := Deposito;
    Topografia.Gaveta := Gaveta;
    Topografia.Archivo := Archivo;
    Topografia.IdServidor := IdServidor;
    IsValid := TopografiaCompleta(SoporteId, Topografia);

    if not IsValid then
    begin
      // Sin alcance (modo Access) cualquiera puede completarla; con alcance, solo
      // el administrador o el EGD del nodo. El resto recibe a quien pedirsela.
      IdNodo.IdEstructura := IdEstructura;
      IdNodo.Id := SerieTree.FieldByName('id').AsInteger;
      PuedeEditarTopografia := (Alcance = nil) or
        Alcance.PuedeRealizar(acEditarTopografia, IdNodo, CodSubs);
      UDM.sms(MensajeTopografiaFaltante(SoporteId, PuedeEditarTopografia), 3);
      DataSet.Cancel;
      Exit;
    end;

    // Asignar valores al nuevo registro
    DataSet.FieldByName('idservidor').AsString := IdServidor;
    DataSet.FieldByName('deposito').AsString := Deposito;
    DataSet.FieldByName('posicion').AsString := Posicion;
    DataSet.FieldByName('gaveta').AsString := Gaveta;
    DataSet.FieldByName('Archivo').AsString := Archivo;
    DataSet.FieldByName('gestor').AsString := Gestor;

    // Preparar mensaje de log
    LogMessage := Format('El documento "%s" con código "%s" fue agregado al sistema.', [DataSet.FieldByName('titulodoc').AsString, DataSet.FieldByName('Codigodoc').AsString]);
  finally
    // Restaurar cursor
    Screen.Cursor := crDefault;
  end;

  // Registrar log de forma diferida para no bloquear
  TThread.Queue(nil,
    procedure
    begin
      UDM.log(LogMessage, 5, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('Nombreestructura').AsString);
    end);
end;

{
var
  Flag: Boolean;
  Fecha: TDateTime;
  Version, Codigodoc: string;
  IdEstructura, codsubs: string;
begin

  if EstoyActualizando then begin
    DataSet.Cancel;
    Exit;
  end;
  if not UDM.SudSDetail.active then begin
    DataSet.Cancel;
    exit;
  end;

  //genera nuevas llaves
  ProponerValores(UDM.tb_Serietree.FieldByName('IdEstructura').AsString, UDM.tb_Serietree.FieldByName('codsubs').AsString, Fecha, Version, Codigodoc);
  // Asignar los valores propuestos a los campos
  DataSet.FieldByName('Fecha').Value := Fecha;
  DataSet.FieldByName('Version').AsString := Version;
  DataSet.FieldByName('Codigodoc').AsString := Codigodoc;
  //Fin de llaves...
  Flag := False;
  case UDM.SudSDetail.FieldByName('idsoporte').AsInteger of
    1:
      begin //Soporte Papel
        if (trim(UDM.tb_Serietree.FieldByName('deposito').AsString) = '') or (UDM.tb_Serietree.FieldByName('deposito').Value = null) then
          Flag := True;
        if (trim(UDM.tb_Serietree.FieldByName('gaveta').AsString) = '') or (UDM.tb_Serietree.FieldByName('gaveta').Value = null) then
          Flag := True;
        if (trim(UDM.tb_Serietree.FieldByName('Archivo').AsString) = '') or (UDM.tb_Serietree.FieldByName('Archivo').Value = null) then
          Flag := True;
        if Flag then
        begin
          UDM.sms('Por favor especifique los datos topográficos necesarios para almacenar series en el soporte especificado.', 3);
          DataSet.Cancel;
          Exit;
        end;
      end;
    2:
      begin //Soporte Digital
        if (trim(UDM.tb_Serietree.FieldByName('Idservidor').AsString) = '') or (UDM.tb_Serietree.FieldByName('Idservidor').Value = null) or (UDM.tb_Serietree.FieldByName('Idservidor').AsString = '0') then
        begin
          UDM.sms('No ha especificado los datos topográficos de la serie acual', 2);
          UDM.sms('Por favor especifique un servidor o repositorio válido para almacenar la información especificada.', 3);
          DataSet.Cancel;
          Exit;
        end;
      end;
    3:
      begin //Soporte Papel y digital
        if (trim(UDM.tb_Serietree.FieldByName('deposito').AsString) = '') or (UDM.tb_Serietree.FieldByName('deposito').Value = null) then
          Flag := True;
        if (trim(UDM.tb_Serietree.FieldByName('gaveta').AsString) = '') or (UDM.tb_Serietree.FieldByName('gaveta').Value = null) then
          Flag := True;
        if (trim(UDM.tb_Serietree.FieldByName('archivo').AsString) = '') or (UDM.tb_Serietree.FieldByName('archivo').Value = null) then
          Flag := True;
        if (trim(UDM.tb_Serietree.FieldByName('Idservidor').AsString) = '') or (UDM.tb_Serietree.FieldByName('Idservidor').Value = null) then
          Flag := True;
        if Flag then
        begin
          UDM.sms('Por favor especifique los datos topográficos necesarios para almacenar series en el soporte especificado.', 3);
          DataSet.Cancel;
          Exit;
        end;
      end;
  end;

  //DataSet.FieldByName('Codigodoc').AsString := UDM.tb_Serietree.FieldByName('codsubs').AsString;
  DataSet.FieldByName('idservidor').AsInteger := UDM.tb_Serietree.FieldByName('idservidor').AsInteger;
  DataSet.FieldByName('deposito').AsString := UDM.tb_Serietree.FieldByName('deposito').AsString;
  DataSet.FieldByName('posicion').AsString := UDM.tb_Serietree.FieldByName('posicion').AsString;
  DataSet.FieldByName('gaveta').AsString := UDM.tb_Serietree.FieldByName('gaveta').AsString;
  DataSet.FieldByName('Archivo').AsString := UDM.tb_Serietree.FieldByName('Archivo').AsString;
  DataSet.FieldByName('gestor').AsString := UDM.tb_Serietree.FieldByName('gestor').AsString;
  UDM.log('El documento"' + DataSet.FieldByName('titulodoc').AsString + '" con código "' + DataSet.FieldByName('Codigodoc').AsString + '" fue agregado al sistema.', 5, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('serie').AsString, UDM.SudSDetail.FieldByName('Nombreestructura').AsString);
end; }

procedure TUDM.tb_treeAfterPost(DataSet: TDataSet);
begin
//  tb_arbol.Refresh;
{  AllFather.Active := False;
  AllFather.Active := True;
  CL_Nodos.Active := False;
  cl_nodopadre.Active := False;
  cl_nodopadre.Active := True;
  CL_Nodos.Active := True;  }
end;

procedure TUDM.tb_treeBeforePost(DataSet: TDataSet);

  function ExisteIdEstructura(const IdEstructura: string): Boolean;
  var
    Query: TFDQuery;
  begin
    Result := False;
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := UDM.Conn; // Asegúrate de tener tu conexión configurada
      Query.SQL.Text := 'SELECT COUNT(*) FROM tb_tree WHERE IdEstructura = :IdEstructura';
      Query.ParamByName('IdEstructura').AsString := IdEstructura;
      Query.Open;

    // Si el resultado es mayor que 0, significa que ya existe
      if Query.Fields[0].AsInteger > 0 then
        Result := True;
    finally
      Query.Free;
    end;
  end;

var
  IdEstructura: string;
begin
  IdEstructura := DataSet.FieldByName('IdEstructura').AsString;
  if Trim(IdEstructura) = '' then
  begin
    sms('El código de la Estructura no puede estar vacío.', 2);
    DataSet.Cancel; // Cancela la operación de inserción o modificación
    Abort;          // Evita que continúe la inserción
    Exit;
  end;
  if DataSet.State = dsInsert then
    if ExisteIdEstructura(IdEstructura) then
    begin
      sms('El código de la Estructura ya existe. No se puede insertar un valor duplicado.', 2);
      DataSet.Cancel; // Cancela la operación de inserción o modificación
      Abort;          // Evita que continúe la inserción
      Exit;
    end;
  if DataSet.FieldByName('tipo').Value = null then
  begin
    sms('Debe especificar un valor para el tipo de objeto.', 2);
    DataSet.Cancel;
    abort;
    exit;
  end;
  if DataSet.FieldByName('Administrador').Value = null then
  begin
    sms('Debe especificar un valor para el Administrador del Area.', 2);
    DataSet.Cancel;
    abort;
    exit;
  end;
end;

procedure TUDM.Timer1Timer(Sender: TObject);
begin
  if Conectado then
  begin
    ActivaDataLayer(true);
    Conectado := False;
  end;
end;

procedure TUDM.TrimAppMemorySize;
var
  MainHandle: THandle;
begin
  try
    MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID);
    SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF);
    CloseHandle(MainHandle);
  except
  end;
  Application.ProcessMessages;
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

  procedure Ejecutacmd(ascript: string);
  begin
    try
      conn.StartTransaction;
      conn.ExecSQL(ascript);
      conn.Commit;
    except
      on E: EFDException do
      begin
        conn.Rollback;
      end;
    end;
  end;

  procedure config(tborigen, tbdestino: string);
  var
    j: integer;
  begin
    with cmdorig do
    begin
      Active := false;
      SQL.clear;
      SQL.Add('select * from ' + tborigen);
      try
        Active := True;
      except
      end;
    end;
    with cmddest do
    begin
      Active := false;
      SQL.clear;
      SQL.Add('select * from ' + tbdestino);
      try
        Active := True;
      except
      end;
    end;
    cmdorig.First;
    while not cmdorig.Eof do
    begin
      cmddest.Append;
      for j := 0 to cmdorig.FieldCount - 1 do
        cmddest.FieldByName(cmdorig.Fields[j].FieldName).Value := cmdorig.Fields[j].Value;
      try
        cmddest.Post;
      except
        cmddest.Cancel;
      end;
      cmdorig.Next;
    end;
  end;

var
  cad: string;
  List: TStringList;
begin              //
  cad := 'UPDATE cl_ttipoarch SET tipoarch = ' + QuotedStr('Gestión') + ' WHERE ldtipoarch = 2';
  execSQLUPD(cad);
  cad := '';
  cad := cad + 'CREATE TABLE TB_Prestamos (IdEstructura varchar(50) NOT NULL, id int NOT NULL, ';
  cad := cad + 'IdPrestamo varchar(12) NOT NULL, Prestamista varchar(255), Estructura varchar(150), ';
  cad := cad + 'Responsable varchar(100), FPrestamo datetime, FDevolucion datetime, FCancelacion datetime, ';
  cad := cad + 'OBS varchar(255), CONSTRAINT PK_TB_Prest PRIMARY KEY (IdEstructura, id, IdPrestamo), ';
  cad := cad + 'CONSTRAINT FK_TREE_PRESTAMOS FOREIGN KEY (IdEstructura, id) REFERENCES tb_tree ';
  cad := cad + '(IdEstructura, id) ON DELETE CASCADE ON UPDATE CASCADE); ';
  execSQLUPD(cad);
  cad := '';
  cad := cad + 'CREATE TABLE TB_PrestamosDocumentos (IdEstructura varchar(50), id int NOT NULL, ';
  cad := cad + 'IdPrestamo varchar(12), Codigodoc varchar(20), fecha datetime NOT NULL, version varchar(12), ';
  cad := cad + 'codsubs varchar(50), titulodoc varchar(255), Archivo smallint, deposito varchar(255), ';
  cad := cad + 'gaveta varchar(20), posicion varchar(10), CONSTRAINT PK_TB_Prest_Document PRIMARY KEY ';
  cad := cad + '(IdEstructura, id, IdPrestamo, Codigodoc, fecha, version), CONSTRAINT FK_PRESTAMOS_DOCUMENTOS ';
  cad := cad + 'FOREIGN KEY (IdEstructura, id, IdPrestamo) REFERENCES TB_Prestamos (IdEstructura, id, ';
  cad := cad + 'IdPrestamo) ON DELETE CASCADE ON UPDATE CASCADE);';
  execSQLUPD(cad);

  cad := '';
  cad := cad + 'CREATE TABLE tb_tree_directors (';
  cad := cad + 'IdEstructura VARCHAR(50) NOT NULL, ';
  cad := cad + 'id INT NOT NULL, ';
  cad := cad + 'user_id VARCHAR(100) NOT NULL, ';
  cad := cad + 'CONSTRAINT PK_tb_tree_directors PRIMARY KEY (IdEstructura, id, user_id), ';
  cad := cad + 'CONSTRAINT FK_tb_tree_directors_tree FOREIGN KEY (IdEstructura, id) ';
  cad := cad + 'REFERENCES tb_tree(IdEstructura, id), ';
  cad := cad + 'CONSTRAINT FK_tb_tree_directors_user FOREIGN KEY (user_id) ';
  cad := cad + 'REFERENCES tb_user(nombreuser)';
  cad := cad + ');';
  execSQLUPD(cad);
  cad := '';

  // Seguridad por alcance y captura masiva (ver UEsquemaAlcance.pas)
  CrearEsquemaAlcance(Conn, TBD = 'S');
  // Tipo de servidor S3/MinIO en cl_ftp_Server (ver UEsquemaAlmacen.pas)
  CrearEsquemaAlmacen(Conn, TBD = 'S');
  // Carga de documentos: columna obligatorio y ultimos valores (ver UEsquemaCarga.pas)
  CrearEsquemaCarga(Conn, TBD = 'S');
  // Trazabilidad: columnas de documento en tb_log (ver UEsquemaTrazabilidad.pas)
  CrearEsquemaTrazabilidad(Conn, TBD = 'S');
  if not EsquemaAlmacenCompleto(Conn) then
  begin
    // Sin permiso para alterar cl_ftp_Server: la aplicacion arranca igual con la
    // consulta de siempre; los servidores S3 no estaran disponibles
    cmdServer.SQL.Text := 'SELECT Idservidor, etiquetaServ, ipserver, path, ' +
      'usuarioftp, pass, puerto FROM cl_ftp_Server';
    sms('No se pudieron agregar las columnas de los servidores S3 en la base de ' +
      'datos (se necesita permiso para modificar tablas). Los servidores S3 no ' +
      'estaran disponibles hasta que el administrador ejecute SCRIPTS/almacen_columnas.sql.', 2);
  end;
//  execSQLUPD('DELETE FROM tb_rol WHERE rol = ' + QuotedStr('Visor'));
  execSQLUPD('DELETE FROM tb_rol WHERE rol = ' + QuotedStr('Archivero'));
  if TBD = 'S' then
  begin
    execSQLUPD('ALTER TABLE tb_serietree DROP COLUMN posicion;');
    execSQLUPD('ALTER TABLE tb_seriesdatos ALTER COLUMN posicion VARCHAR(10);');
    execSQLUPD('ALTER TABLE tb_seriesdatos ALTER COLUMN IDExpediente VARCHAR(20);');
    execSQLUPD('ALTER TABLE tb_sysconfig ADD SistemaIdentificador VARCHAR(50) NOT NULL DEFAULT '+QuotedStr('GD_Valid_2025'));
  end
  else
  begin
    execSQLUPD('ALTER TABLE tb_serietree DROP COLUMN posicion;');
    execSQLUPD('ALTER TABLE tb_seriesdatos ALTER COLUMN posicion TEXT(10);');
    execSQLUPD('ALTER TABLE tb_seriesdatos ALTER COLUMN IDExpediente TEXT(20);');
    execSQLUPD('ALTER TABLE tb_sysconfig ADD COLUMN SistemaIdentificador VARCHAR(50) NOT NULL DEFAULT '+QuotedStr('GD_Valid_2025') );
  end;
end;

end.

