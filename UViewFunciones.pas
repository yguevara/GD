unit UViewFunciones;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, cxRichEdit, Vcl.ComCtrls, Vcl.ToolWin,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  JvExExtCtrls, JvExtComponent, JvCaptionPanel, Vcl.Menus, AdvMenus,
  JvExControls, JvButton, JvTransparentButton, cxBlobEdit, cxDBLookupComboBox;

type
  TfrmSelectFuncionG = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    PMFunciones: TAdvPopupMenu;
    agregarfun: TMenuItem;
    eliminarfun: TMenuItem;
    N1: TMenuItem;
    jcpSelectCargo: TJvCaptionPanel;
    cmdfun: TFDQuery;
    dscmdfun: TDataSource;
    lcbSelectCargo: TDBLookupComboBox;
    zDBTableView1: TcxGridDBTableView;
    zLevel1: TcxGridLevel;
    z: TcxGrid;
    zDBTableView1idfunciones: TcxGridDBColumn;
    zDBTableView1funciones: TcxGridDBColumn;
    zDBTableView1Idcargo: TcxGridDBColumn;
    procedure jcpSelectCargoButtonClick(Sender: TObject;
      Button: TJvCapBtnStyle);
    procedure eliminarfunClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{var
  frmSelectFuncionG: TfrmSelectFuncionG;}

  function GetIDFunctionValue:Integer;

implementation

uses
  UCapaDatos;

{$R *.dfm}
function GetIDFunctionValue:Integer;
begin
  with TfrmSelectFuncionG.Create(nil)do
  try
    Result:=-1;
    showmodal;
  finally
    Result:=cmdfun.FieldByName('idfunciones').AsInteger;
    Free;
  end;
end;



procedure TfrmSelectFuncionG.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSelectFuncionG.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmSelectFuncionG.eliminarfunClick(Sender: TObject);
begin
  jcpSelectCargo.Visible:=True;
end;

procedure TfrmSelectFuncionG.jcpSelectCargoButtonClick(Sender: TObject;
  Button: TJvCapBtnStyle);
begin
  if Button=capClose then begin
    jcpSelectCargo.Visible:=False;
  end;
end;

end.
