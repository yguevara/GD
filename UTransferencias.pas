unit UTransferencias;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, JvExControls, JvButton,
  JvTransparentButton, Vcl.ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxTextEdit, cxDBEdit, cxLabel, dxBarBuiltInMenu,
  cxStyles, cxDropDownEdit, cxCustomData, cxFilter, cxData, cxDataStorage,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, cxDBLookupComboBox, cxCheckBox,
  cxBlobEdit, cxCalendar, AdvPanel, AdvGroupBox, cxMaskEdit, cxLookupEdit,
  cxDBLookupEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, cxVGrid, cxDBVGrid,
  cxInplaceContainer, cxPC, cxButtonEdit;

type
  TfrmTransferencias = class(TForm)
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnExcelExport: TJvTransparentButton;
    btnExpand: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    Edit1: TEdit;
    cxPageControl1: TcxPageControl;
    tsform: TcxTabSheet;
    cxDBVerticalGrid6: TcxDBVerticalGrid;
    cxDBVerticalGrid6IdVar: TcxDBEditorRow;
    cxDBVerticalGrid6NomVariable: TcxDBEditorRow;
    cxDBVerticalGrid6Etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid6tipo: TcxDBEditorRow;
    cxLong: TcxDBEditorRow;
    cxDBVerticalGrid6descripcion: TcxDBEditorRow;
    cxDBVerticalGrid6ListaDesplegable: TcxDBEditorRow;
    tsVTSS: TcxTabSheet;
    tsFormulario: TcxTabSheet;
    GroupBox3: TGroupBox;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBTableView1idtransfer: TcxGridDBColumn;
    cxGridDBTableView1fechainput: TcxGridDBColumn;
    cxGridDBTableView1fechaeject: TcxGridDBColumn;
    cxGridDBTableView1operacion: TcxGridDBColumn;
    cxGridDBTableView1entidad: TcxGridDBColumn;
    cxGridDBTableView1codserie: TcxGridDBColumn;
    cxGridDBTableView1serie: TcxGridDBColumn;
    cxGridDBTableView1codsubs: TcxGridDBColumn;
    cxGridDBTableView1subserie: TcxGridDBColumn;
    cxGridDBTableView1soporte: TcxGridDBColumn;
    cxGridDBTableView1tipodoc: TcxGridDBColumn;
    cxGridDBTableView1activa: TcxGridDBColumn;
    cxGridDBTableView1vigencia: TcxGridDBColumn;
    cxGridDBTableView1detalle: TcxGridDBColumn;
    cxGridDBTableView1Periodo: TcxGridDBColumn;
    cxGridDBTableView1Destino: TcxGridDBColumn;
    cxGridDBTableView1Ejecutada: TcxGridDBColumn;
    cxGridDBTableView1rutazipfile: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid2idtransfer: TcxDBEditorRow;
    cxDBVerticalGrid2fechainput: TcxDBEditorRow;
    cxDBVerticalGrid2fechaeject: TcxDBEditorRow;
    cxDBVerticalGrid2operacion: TcxDBEditorRow;
    cxDBVerticalGrid2entidad: TcxDBEditorRow;
    cxDBVerticalGrid2codserie: TcxDBEditorRow;
    cxDBVerticalGrid2serie: TcxDBEditorRow;
    cxDBVerticalGrid2codsubs: TcxDBEditorRow;
    cxDBVerticalGrid2subserie: TcxDBEditorRow;
    cxDBVerticalGrid2soporte: TcxDBEditorRow;
    cxDBVerticalGrid2tipodoc: TcxDBEditorRow;
    cxDBVerticalGrid2activa: TcxDBEditorRow;
    cxDBVerticalGrid2vigencia: TcxDBEditorRow;
    cxDBVerticalGrid2detalle: TcxDBEditorRow;
    cxDBVerticalGrid2Periodo: TcxDBEditorRow;
    cxDBVerticalGrid2Destino: TcxDBEditorRow;
    cxDBVerticalGrid2Ejecutada: TcxDBEditorRow;
    cxDBVerticalGrid2rutazipfile: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow1: TcxCategoryRow;
    btnPrint: TJvTransparentButton;
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure btnExpandClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTransferencias: TfrmTransferencias;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmTransferencias.btnExpandClick(Sender: TObject);
begin
  if cxGridDBTableView1.DataController.DataSet.RecordCount > 0 then
  begin
    try
      cxGridDBTableView1.ApplyBestFit();
      UDM.SalvaConfigGrid(cxGridDBTableView1, 'tb_transferencia');
    except
    end;
  end
  else
  begin
    UDM.sms('Esta función es recomendable utilizarla cuando existe al menos un registro inscrito.', 3);
    Exit;
  end;
end;

procedure TfrmTransferencias.btnPrintClick(Sender: TObject);
begin
  //Print...
end;

procedure TfrmTransferencias.btnSystemHelpClick(Sender: TObject);
begin
  Application.HelpContext(33);
end;

procedure TfrmTransferencias.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=112 then
    Application.HelpContext(33);
end;

procedure TfrmTransferencias.FormShow(Sender: TObject);
begin
  UDM.RestauraGrid(cxGridDBTableView1, 'tb_transferencia');
end;

procedure TfrmTransferencias.JvTransparentButton1Click(Sender: TObject);
begin
  Close;
end;

end.
