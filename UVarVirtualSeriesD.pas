unit UVarVirtualSeriesD;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ToolWin, Vcl.StdCtrls, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  cxStyles, cxEdit, cxDBLookupComboBox, cxBlobEdit, cxVGrid, cxDBVGrid,
  cxInplaceContainer, Vcl.DBCtrls, cxNavigator, cxDBNavigator, JvExControls,
  JvButton, JvTransparentButton, Vcl.ExtCtrls;

type
  TfrmVariablesVirtSeries = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    Button1: TButton;
    Button2: TButton;
    pSubSeries: TPanel;
    Panel1: TPanel;
    btnFunciones: TJvTransparentButton;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    Panel3: TPanel;
    Panel6: TPanel;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxDBVerticalGrid6codserie: TcxDBEditorRow;
    cxDBVerticalGrid6CategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid6codsubs: TcxDBEditorRow;
    cxDBEditorRow1: TcxDBEditorRow;
    cxDBVerticalGrid6subserie: TcxDBEditorRow;
    cxDBVerticalGrid6tipodoc: TcxDBEditorRow;
    cxDBVerticalGrid6ayear: TcxDBEditorRow;
    cxDBVerticalGrid6CategoryRow2: TcxCategoryRow;
    cxDBVerticalGrid6tgestion: TcxDBEditorRow;
    cxDBVerticalGrid6tcentral: TcxDBEditorRow;
    cxDBVerticalGrid6destino: TcxDBEditorRow;
    cxDBVerticalGrid6acceso: TcxDBEditorRow;
    cxDBVerticalGrid6soporte: TcxDBEditorRow;
    cxDBVerticalGrid6observacion: TcxDBEditorRow;
    procedure btnhlpClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVariablesVirtSeries: TfrmVariablesVirtSeries;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmVariablesVirtSeries.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVariablesVirtSeries.btnhlpClick(Sender: TObject);
begin
  ShowMessage(IntToStr(Width));
end;

procedure TfrmVariablesVirtSeries.Button1Click(Sender: TObject);
begin
  Width:=1000;
end;

procedure TfrmVariablesVirtSeries.Button2Click(Sender: TObject);
begin
  width:=500;
end;

procedure TfrmVariablesVirtSeries.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

end.

