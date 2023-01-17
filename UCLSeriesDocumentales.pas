unit UCLSeriesDocumentales;

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
  cxClasses, cxGridCustomView, cxGrid, cxDBLookupComboBox, JvExControls,
  JvButton, JvTransparentButton, cxCalendar;

type
  TfrmCLSeries = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    pSeries: TPanel;
    AdvSplitter1: TAdvSplitter;
    pSubSeries: TPanel;
    cxDBVerticalGrid6: TcxDBVerticalGrid;
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
    cxGrid1DBTableView1codserie: TcxGridDBColumn;
    cxGrid1DBTableView1serie: TcxGridDBColumn;
    btnFunciones: TJvTransparentButton;
    Timer1: TTimer;
    cxDBVerticalGrid6codserie: TcxDBEditorRow;
    cxDBVerticalGrid6codsubs: TcxDBEditorRow;
    cxDBVerticalGrid6subserie: TcxDBEditorRow;
    cxDBVerticalGrid6etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid6tipodoc: TcxDBEditorRow;
    cxDBVerticalGrid6ayear: TcxDBEditorRow;
    cxDBVerticalGrid6tgestion: TcxDBEditorRow;
    cxDBVerticalGrid6tcentral: TcxDBEditorRow;
    cxDBVerticalGrid6destino: TcxDBEditorRow;
    cxDBVerticalGrid6acceso: TcxDBEditorRow;
    cxDBVerticalGrid6soporte: TcxDBEditorRow;
    cxDBVerticalGrid6observacion: TcxDBEditorRow;
    cxDBVerticalGrid6CategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid6CategoryRow2: TcxCategoryRow;
    procedure btnCloseClick(Sender: TObject);
    procedure btnFuncionesClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCLSeries: TfrmCLSeries;

implementation

uses
  UCapaDatos, UVarVirtualVar;

{$R *.dfm}

procedure TfrmCLSeries.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLSeries.btnFuncionesClick(Sender: TObject);
begin
  if UDM.cl_subseries.RecordCount > 0 then
  begin
    with TfrmVarVirtualVar.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
  end
  else
  begin
    MessageDlg('Debe existir al menos una serie documental valida.', mtWarning, [mbOK], 0);
    Exit;
  end;
end;

procedure TfrmCLSeries.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmCLSeries.Timer1Timer(Sender: TObject);
begin
  if UDM.cl_subseries.RecordCount = 0 then
    btnFunciones.Enabled := False
  else
    btnFunciones.Enabled := True;
end;

end.

