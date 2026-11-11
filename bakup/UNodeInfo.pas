unit UNodeInfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxEdit, cxDropDownEdit,
  cxBlobEdit, dxSkinsCore, dxSkinsDefaultPainters, cxVGrid, cxDBVGrid,
  cxInplaceContainer, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.StdCtrls, JvExControls, JvButton, JvTransparentButton, Vcl.ExtCtrls, JvEditor,
  cxRichEdit;

type
  TfrmNodeInfo = class(TForm)
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    Edit1: TEdit;
    cmdNodeInfo: TFDQuery;
    cxDBVerticalGrid5: TcxDBVerticalGrid;
    dscmdNodeInfo: TDataSource;
    cxDBVerticalGrid5IdEstructura: TcxDBEditorRow;
    cxDBVerticalGrid5etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid5nombretipoobj: TcxDBEditorRow;
    cxDBVerticalGrid5NombreResponsable: TcxDBEditorRow;
    cxDBVerticalGrid5CorreoElect: TcxDBEditorRow;
    cxDBVerticalGrid5Telefono: TcxDBEditorRow;
    cxDBVerticalGrid5descripcion: TcxDBEditorRow;
    cxDBVerticalGrid5CategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid5CategoryRow2: TcxCategoryRow;
    procedure JvTransparentButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNodeInfo: TfrmNodeInfo;

implementation

uses
  UCapaDatos, UVeditor;

{$R *.dfm}

procedure TfrmNodeInfo.JvTransparentButton1Click(Sender: TObject);
begin
  Close;
end;

end.
