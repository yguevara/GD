unit UCLVariables;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, Vcl.DBCtrls, cxNavigator, cxDBNavigator, Vcl.ExtCtrls,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, dxDateRanges,
  Data.DB, cxDBData, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, cxDropDownEdit,
  cxVGrid, cxDBVGrid, cxInplaceContainer, dxBarBuiltInMenu, cxContainer,
  cxDBEdit, cxCheckBox, cxTextEdit, cxMaskEdit, cxBlobEdit, Vcl.StdCtrls,
  cxGroupBox, cxPC, Vcl.Buttons, JvExControls, JvButton, JvTransparentButton;

type
  TfrmVariables = class(TForm)
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    StatusBar1: TStatusBar;
    cxPageControl1: TcxPageControl;
    tsform: TcxTabSheet;
    cxTabSheet2: TcxTabSheet;
    cxDBVerticalGrid6: TcxDBVerticalGrid;
    cxDBVerticalGrid6IdVar: TcxDBEditorRow;
    cxDBVerticalGrid6NomVariable: TcxDBEditorRow;
    cxDBVerticalGrid6Etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid6tipo: TcxDBEditorRow;
    cxLong: TcxDBEditorRow;
    cxDBVerticalGrid6descripcion: TcxDBEditorRow;
    cxDBVerticalGrid6ListaDesplegable: TcxDBEditorRow;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1IdVar: TcxGridDBColumn;
    cxGrid1DBTableView1NomVariable: TcxGridDBColumn;
    cxGrid1DBTableView1Etiqueta: TcxGridDBColumn;
    cxGrid1DBTableView1tipo: TcxGridDBColumn;
    cxGrid1DBTableView1longitud: TcxGridDBColumn;
    cxGrid1DBTableView1descripcion: TcxGridDBColumn;
    cxGrid1DBTableView1ListaDesplegable: TcxGridDBColumn;
    tsFormulario: TcxTabSheet;
    Panel1: TPanel;
    Label6: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    Label1: TLabel;
    cxDBComboBox1: TcxDBComboBox;
    cxDBBlobEdit2: TcxDBBlobEdit;
    Label3: TLabel;
    cxDBTextEdit2: TcxDBTextEdit;
    Label2: TLabel;
    Label10: TLabel;
    cxDBTextEdit3: TcxDBTextEdit;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnExcelExport: TJvTransparentButton;
    btnExpand: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    Edit1: TEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVariables: TfrmVariables;

implementation

uses
  UCapaDatos, UVeditor, UExcelExport;

{$R *.dfm}

procedure TfrmVariables.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVariables.FormActivate(Sender: TObject);
begin
//  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmVariables.ToolButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.
