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
  cxVGrid, cxDBVGrid, cxInplaceContainer;

type
  TfrmVariables = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    StatusBar1: TStatusBar;
    cxDBVerticalGrid6: TcxDBVerticalGrid;
    cxDBVerticalGrid6IdVar: TcxDBEditorRow;
    cxDBVerticalGrid6NomVariable: TcxDBEditorRow;
    cxDBVerticalGrid6Etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid6tipo: TcxDBEditorRow;
    cxLong: TcxDBEditorRow;
    cxDBVerticalGrid6descripcion: TcxDBEditorRow;
    cxDBVerticalGrid6ListaDesplegable: TcxDBEditorRow;
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVariables: TfrmVariables;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmVariables.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
