unit UGestEstruct;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin, dxSkinsCore,
  dxSkinsDefaultPainters, dxBarBuiltInMenu, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxPC, Vcl.DBCtrls, cxNavigator,
  cxDBNavigator, Vcl.ExtCtrls, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, dxDateRanges, Data.DB, cxDBData, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxImageComboBox, cxContainer, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxDBEdit, Vcl.StdCtrls, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, cxVGrid, cxDBVGrid, cxInplaceContainer,
  cxBlobEdit;

type
  TfrmEstructura = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    cxPageControl1: TcxPageControl;
    tsFunciones: TcxTabSheet;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    Panel1: TPanel;
    Label2: TLabel;
    edtCodigo: TcxDBTextEdit;
    Label3: TLabel;
    lcbTipoNodo: TcxDBLookupComboBox;
    Label1: TLabel;
    edtEtiqueta: TcxDBTextEdit;
    Label5: TLabel;
    lcbPadre: TcxDBLookupComboBox;
    lcbIMG: TcxDBImageComboBox;
    Label4: TLabel;
    Panel2: TPanel;
    cxPageControl2: TcxPageControl;
    tsProperties: TcxTabSheet;
    cxTabSheet3: TcxTabSheet;
    Label6: TLabel;
    cxDBLookupComboBox1: TcxDBLookupComboBox;
    cxPageControl3: TcxPageControl;
    tsfuncion: TcxTabSheet;
    tsCargo: TcxTabSheet;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lcbTipoNodoPropertiesCloseUp(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function checkTreeState:Boolean;
  end;

var
  frmEstructura: TfrmEstructura;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmEstructura.btnCloseClick(Sender: TObject);
begin
  Close;
end;

function TfrmEstructura.checkTreeState: Boolean;
begin
  Result:=TRUE;
  if (UDM.tb_tree.State=dsInsert)or (UDM.tb_tree.State=dsEdit) then
  begin
    if MessageDlg('¿Está seguro de salir y cancelar las modificaciones que se encontraba realizando?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      UDM.tb_tree.Cancel;
      Result:=True;
    end else
      Result:=False;
  end;

end;

procedure TfrmEstructura.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if checkTreeState then
    CanClose:=True
  else
    CanClose:=False;
end;

procedure TfrmEstructura.lcbTipoNodoPropertiesCloseUp(Sender: TObject);
begin
  {if TcxLookupComboBoxProperties(Sender).Properties.KeyFieldNames:='id'; then

  if TcxDBLookupComboBox(Sender). then }

end;

end.
