unit UPrestamos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.MSAcc, FireDAC.Phys.MSAccDef, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, Vcl.ExtCtrls, cxRichEdit, Vcl.Menus, Vcl.StdCtrls, cxInplaceContainer,
  cxVGrid, cxDBVGrid, cxCalendar, Vcl.ToolWin, Vcl.ComCtrls,
  Vcl.Buttons, System.ImageList, Vcl.ImgList, dxScreenTip, dxCustomHint, cxHint,
  frxClass, frxRich, frxBarcode, frxOLE, frxCross, frxDMPExport, frxExportImage,
  frxExportRTF, frxExportXML, frxExportHTML, frxGZip, frxExportPDF, frxChBox,
  frxExportText, frxExportCSV, frxExportMail, frxADOComponents, frxCrypt,
  frxExportODF, frxPrinter, frxExportHTMLDiv, frxExportXLSX, frxExportPPTX,
  frxExportDOCX, frxExportBIFF, frxChart, frxExportSVG, frxTableObject, frxMap,
  frxExportHelpers, frxExportBaseDialog, frxCellularTextObject, frxExportPPML,
  frxExportPS, frxExportZPL, frxSaveFilterFRX, frxHTML, frxPDFViewer,
  JvExControls, JvButton, JvTransparentButton, cxTextEdit, cxMemo, cxButtonEdit,
  cxDBLookupComboBox, cxDropDownEdit;

type
  TposicionDoc = record
    idstructura: string;
    id: integer;
    codsubs: string;
    fecha: tdatetime;
    version: string;
    codigoDoc: string;
  end;

  TfpRESTAMOS = class(TForm)
    Panel1: TPanel;
    Panel5: TPanel;
    PopupMenu1: TPopupMenu;
    P1: TMenuItem;
    T1: TMenuItem;
    D1: TMenuItem;
    Panel11: TPanel;
    Panel8: TPanel;
    Panel10: TPanel;
    Panel12: TPanel;
    Splitter3: TSplitter;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    Splitter1: TSplitter;
    cxStyle2: TcxStyle;
    cxGrid5DBTableView1: TcxGridDBTableView;
    cxGrid5Level1: TcxGridLevel;
    cxGrid5: TcxGrid;
    cxStyle3: TcxStyle;
    Panel4: TPanel;
    Splitter2: TSplitter;
    Panel2: TPanel;
    Panel3: TPanel;
    cxGrid2: TcxGrid;
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
    cxGridLevel1: TcxGridLevel;
    ImageList1: TImageList;
    Panel6: TPanel;
    cxGrid5DBTableView1IdEstructura: TcxGridDBColumn;
    cxGrid5DBTableView1id: TcxGridDBColumn;
    cxGrid5DBTableView1IdPrestamo: TcxGridDBColumn;
    cxGrid5DBTableView1Codigodoc: TcxGridDBColumn;
    cxGrid5DBTableView1fecha: TcxGridDBColumn;
    cxGrid5DBTableView1version: TcxGridDBColumn;
    cxGrid5DBTableView1codsubs: TcxGridDBColumn;
    cxGrid5DBTableView1titulodoc: TcxGridDBColumn;
    cxGrid5DBTableView1Archivo: TcxGridDBColumn;
    cxGrid5DBTableView1deposito: TcxGridDBColumn;
    cxGrid5DBTableView1gaveta: TcxGridDBColumn;
    cxGrid5DBTableView1posicion: TcxGridDBColumn;
    cxStyle4: TcxStyle;
    frxReport1: TfrxReport;
    DFDQDArchivos: TDataSource;
    FDTable2: TFDTable;
    cxHintStyleController1: TcxHintStyleController;
    pMainContainer: TPanel;
    btnSystemHelp: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    JvTransparentButton2: TJvTransparentButton;
    JvTransparentButton3: TJvTransparentButton;
    JvTransparentButton1: TJvTransparentButton;
    Edit2: TEdit;
    cxGrid1: TcxGrid;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2DBTableView1IdEstructura: TcxGridDBColumn;
    cxGrid2DBTableView1id: TcxGridDBColumn;
    cxGrid2DBTableView1codsubs: TcxGridDBColumn;
    cxGrid2DBTableView1Codigodoc: TcxGridDBColumn;
    cxGrid2DBTableView1Fecha: TcxGridDBColumn;
    cxGrid2DBTableView1Version: TcxGridDBColumn;
    cxGrid2DBTableView1titulodoc: TcxGridDBColumn;
    cxGrid2DBTableView1fichero: TcxGridDBColumn;
    cxGrid2DBTableView1Archivo: TcxGridDBColumn;
    cxGrid2DBTableView1deposito: TcxGridDBColumn;
    cxGrid2DBTableView1gaveta: TcxGridDBColumn;
    cxGrid2DBTableView1Idservidor: TcxGridDBColumn;
    cxGrid2DBTableView1gestor: TcxGridDBColumn;
    cxGrid2DBTableView1observaciones: TcxGridDBColumn;
    cxGrid2DBTableView1IDExpediente: TcxGridDBColumn;
    cxGrid2DBTableView1visible: TcxGridDBColumn;
    cxGrid2DBTableView1posicion: TcxGridDBColumn;
    cxGrid2Level1: TcxGridLevel;
    ToolBar3: TToolBar;
    ToolButton4: TToolButton;
    ToolButton3: TToolButton;
    ToolButton1: TToolButton;
    ToolButton5: TToolButton;
    ToolButton8: TToolButton;
    ToolButton2: TToolButton;
    ToolButton7: TToolButton;
    ToolButton6: TToolButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure ToolButton3Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToolButton5Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
  private
    { Private declarations }
    altoDocumentos: Integer;
    TIPO: Char;
    CabenB: WideString;
  public
    { Public declarations }
  end;

var
  fpRESTAMOS: TfpRESTAMOS;
  s: string;
  i: integer;

const
  ac1: WideString = 'Provider=Microsoft.Jet.OLEDB.4.0;User ID=Admin;Data Source=';
  ac2: WideString = ';Mode=Share Deny None;Jet OLEDB:System database="";Jet OLEDB:Registry Path="";Jet OLEDB:Database Password="";Jet OLEDB:Engine Type=5;Jet OLEDB:Database Locking Mode=1;Jet OLEDB:Global Partial Bu';
  ac3: WideString = 'lk Ops=2;Jet OLEDB:Global Bulk Transactions=1;Jet OLEDB:New Database Password="";Jet OLEDB:Create System Database=False;Jet OLEDB:Encrypt Database=False;Jet OLEDB:Don' + chr(39) + 't Co';
  ac4: WideString = 'py Locale on Compact=False;Jet OLEDB:Compact Without Replica Repair=False;Jet OLEDB:SFP=False;';

procedure Prestamos;
   {
    tipos de BD:
    'A' =Access
    'S' = SQLServer
   }

implementation

{$R *.dfm}

uses UCapaDatos;

procedure Prestamos;
begin
  with TfpRESTAMOS.Create(nil) do
  try
    showmodal;
  finally
    Free;
  end;

end;

procedure TfpRESTAMOS.FormCreate(Sender: TObject);
begin
  altoDocumentos := Panel5.Height;
end;

procedure TfpRESTAMOS.JvTransparentButton1Click(Sender: TObject);
begin
  Close
end;

procedure TfpRESTAMOS.SpeedButton1Click(Sender: TObject);
begin
  CLOSE;
end;

procedure TfpRESTAMOS.ToolButton3Click(Sender: TObject);
begin
  if ToolButton3.ImageIndex = 0 then
  begin
    ToolButton3.ImageIndex := 1;
    altoDocumentos := Panel5.Height;
    //cxGrid1.Visible := False;
    Panel5.Height := 0;
    Splitter1.Visible := False;
    ToolButton3.hint := 'Visualizar Documentos disponibles';

  end
  else
  begin
    ToolButton3.ImageIndex := 0;
    Panel5.Height := altoDocumentos;
    cxGrid1.Visible := True;
    Splitter1.Visible := true;
    Splitter1.Top := cxGrid1.Height;
    //Minimizar Documentos disponibles
    ToolButton3.hint := 'Ocultar Documentos disponibles';
  end;

end;

procedure TfpRESTAMOS.ToolButton4Click(Sender: TObject);
begin
  close;
end;

procedure TfpRESTAMOS.ToolButton5Click(Sender: TObject);
begin
  if Panel5.height = 0 then
  begin
    ShowMessage('ADVERTEBCIA: Tiene que desplegar los datos de documentos didponibles');
    exit;
  end;

  if UDM.TB_Prestamos.RecordCount = 0 then
  begin
    showmessage('No hay prestamo activo. Cree un prestamo');
    Exit;

  end
  else
  begin
    s := 'Adicionara el documento[' + UDM.tb_SeriesDatos.fieldbyname('titulodoc').asstring + '] al prestamo actual?';
    if MessageDlg(s, mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
    begin
      if UDM.TB_PrestamosDocumentos.locate('Codigodoc;fecha;version', VarArrayOf([UDM.tb_SeriesDatos.fieldbyname('Codigodoc').value, UDM.tb_SeriesDatos.fieldbyname('Fecha').value, UDM.tb_SeriesDatos.fieldbyname('version').value]), []) then
      begin
        ShowMessage('ADVERTEBCIA:ya este documento esta incorporado al prestamo actual');
      end
      else
      begin
        UDM.TB_PrestamosDocumentos.appendrecord([UDM.TB_Prestamos.FieldByName('IdEstructura').value, UDM.TB_Prestamos.FieldByName('id').value, UDM.TB_Prestamos.FieldByName('IdPrestamo').value, UDM.tb_SeriesDatos.FieldByName('Codigodoc').value, UDM.tb_SeriesDatos.FieldByName('fecha').value, UDM.tb_seriesdatos.FieldByName('version').value, UDM.tb_seriesdatos.FieldByName('codsubs').value, UDM.tb_seriesdatos.FieldByName('titulodoc').value, UDM.tb_seriesdatos.FieldByName('Archivo').value, UDM.tb_seriesdatos.FieldByName('deposito').value, UDM.tb_seriesdatos.FieldByName('gaveta').value, UDM.tb_seriesdatos.FieldByName('posicion').value]);
        ShowMessage('Documento adicionado al prestamo actual');
      end;
    end;

  end;
end;

procedure TfpRESTAMOS.ToolButton6Click(Sender: TObject);
begin
  showmessage('Funcionalidad en construcción');
end;

procedure TfpRESTAMOS.ToolButton8Click(Sender: TObject);
var
  CabenB, FDDatabaseName, cad, cad1, Basedatos, servidor: string;
begin
  if TBD = 'A' then
  begin
    FDDatabaseName := UDM.Conn.Params.Values['Database'];
    TfrxADODatabase(frxReport1.FindObject('ADODatabase1ACCES')).Connected := False;
    CabenB := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + FDDatabaseName + ';Persist Security Info=False';
    TfrxADODatabase(frxReport1.FindObject('ADODatabase1ACCES')).DatabaseName := CabenB;
    TfrxADODatabase(frxReport1.FindObject('ADODatabase1ACCES')).Connected := true;
  end
  else
  begin
    Basedatos := UDM.Conn.Params.Values['Database'];
    servidor := UDM.Conn.Params.Values['Server'];
    cad1 := 'Provider=SQLOLEDB.1;Password=geoconn;Persist Security Info=True;User ';
    cad1 := cad1 + 'ID=geoconn;Initial Catalog=' + Basedatos + ';Data Source=' + servidor;
    TfrxADODatabase(frxReport1.FindObject('ADODatabase1ACCES')).Connected := False;
    TfrxADODatabase(frxReport1.FindObject('ADODatabase1ACCES')).DatabaseName := cad1;
    TfrxADODatabase(frxReport1.FindObject('ADODatabase1ACCES')).Connected := true;
  end;
  frxReport1.PrepareReport;
  frxReport1.ShowReport(False);
end;

{
begin
  if tipo = 'A' then
  begin   //--------------------- Access
  //.................. Aqui se abre la conexion a la Bd en ACCESS.................
    TfrxADODatabase(frxReport1.FindObject('ADODatabase1ACCES')).Connected := False;
    CabenB := ac1 + edit1.text + ac2 + ac3 + ac4;
    TfrxADODatabase(frxReport1.FindObject('ADODatabase1ACCES')).DatabaseName := CabenB;
    TfrxADODatabase(frxReport1.FindObject('ADODatabase1ACCES')).Connected := true;

  end
  else
  begin  //--------------------- SQLServer

  end;
  frxReport1.PrepareReport;
  frxReport1.ShowReport(False);
  Exit;
end;
}
end.

