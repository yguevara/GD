unit UCLProcesos;

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
  cxClasses, cxGridCustomView, cxGrid, cxDBLookupComboBox, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, cxImage, cxMRUEdit, cxButtonEdit,
  dxOfficeSearchBox, cxHyperLinkEdit, cxMemo, JvExControls, JvButton,
  JvTransparentButton;

type
  TfrmCLprocesos = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    pProceso: TPanel;
    AdvSplitter1: TAdvSplitter;
    pSubProcesos: TPanel;
    Panel1: TPanel;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    Panel2: TPanel;
    cxDBNavigator2: TcxDBNavigator;
    DBNavigator2: TDBNavigator;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    pGrupo: TPanel;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    Panel7: TPanel;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    tcl_procesosGrupos: TFDQuery;
    tcl_Procesos: TFDQuery;
    tcl_ProcesoSubproceso: TFDQuery;
    Dtcl_procesosGrupos: TDataSource;
    Dtcl_Procesos: TDataSource;
    Dtcl_ProcesoSubproceso: TDataSource;
    cxGrid3DBTableView1: TcxGridDBTableView;
    cxGrid3Level1: TcxGridLevel;
    cxGrid3: TcxGrid;
    cxGridDBTableView1IdGrupo: TcxGridDBColumn;
    cxGridDBTableView1Nombregrupo: TcxGridDBColumn;
    cxGrid1DBTableView1IdGrupo: TcxGridDBColumn;
    cxGrid1DBTableView1IdProceso: TcxGridDBColumn;
    cxGrid1DBTableView1NombreProceso: TcxGridDBColumn;
    tcl_procesosGruposIdGrupo: TSmallintField;
    tcl_procesosGruposNombreGrupo: TWideStringField;
    tcl_ProcesosIdGrupo: TSmallintField;
    tcl_ProcesosIdProceso: TSmallintField;
    tcl_ProcesosNombreProceso: TWideStringField;
    cxGrid3DBTableView1IdGrupo: TcxGridDBColumn;
    cxGrid3DBTableView1IdProceso: TcxGridDBColumn;
    cxGrid3DBTableView1IdSubproceso: TcxGridDBColumn;
    cxGrid3DBTableView1Nombresubproceso: TcxGridDBColumn;
    cxGrid3DBTableView1PDFSubproceso: TcxGridDBColumn;
    cxGrid3DBTableView1IDSistemaCalidad: TcxGridDBColumn;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    JvTransparentButton2: TJvTransparentButton;
    JvTransparentButton1: TJvTransparentButton;
    JvTransparentButton3: TJvTransparentButton;
    procedure btnCloseClick(Sender: TObject);
    procedure cxGrid3DBTableView1PDFSubprocesoPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormActivate(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure DBNavigator2Click(Sender: TObject; Button: TNavigateBtn);
    procedure DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
    procedure JvTransparentButton2Click(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure JvTransparentButton3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCLprocesos: TfrmCLprocesos;
  s: string;

implementation

uses
  UCapaDatos, UManagementPDFFile, UExcelExport;

{$R *.dfm}

procedure TfrmCLprocesos.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLprocesos.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmCLprocesos.cxGrid3DBTableView1PDFSubprocesoPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreProc: string;
begin
  NombreProc := tcl_ProcesoSubproceso.FieldByName('Nombresubproceso').AsString + ' ID SGIC Calidad (' + tcl_ProcesoSubproceso.FieldByName('IDSistemaCalidad').AsString + ')';
  ManagementPDF(@tcl_ProcesoSubproceso, 'PDFSubproceso', NombreProc, 'pdf');
end;

procedure TfrmCLprocesos.DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.tcl_ProcesoSubproceso.FieldByName('IdSubproceso').AsInteger := UDM.GetLastId('tcl_ProcesoSubproceso', 'IdSubproceso');
  end;
end;

procedure TfrmCLprocesos.DBNavigator2Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.tcl_Procesos.FieldByName('IdProceso').AsInteger := UDM.GetLastId('tcl_Procesos', 'IdProceso');
  end;
end;

procedure TfrmCLprocesos.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.tcl_procesosGrupos.FieldByName('IdGrupo').AsInteger := UDM.GetLastId('tcl_procesosGrupos', 'IdGrupo');
  end;
end;

procedure TfrmCLprocesos.FormActivate(Sender: TObject);
begin
  tcl_procesosGrupos.Active := True;
  tcl_Procesos.Active := True;
  tcl_ProcesoSubproceso.Active := True;
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmCLprocesos.JvTransparentButton1Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TfrmCLprocesos.JvTransparentButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid2);
end;

procedure TfrmCLprocesos.JvTransparentButton3Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid3);
end;

end.

