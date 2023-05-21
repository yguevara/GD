unit UGestEstruct;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ToolWin, dxSkinsCore, dxSkinsDefaultPainters,
  dxBarBuiltInMenu, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxPC, Vcl.DBCtrls, cxNavigator, cxDBNavigator,
  Vcl.ExtCtrls, cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  dxDateRanges, Data.DB, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  cxImageComboBox, cxContainer, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxDBEdit,
  Vcl.StdCtrls, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, cxVGrid,
  cxDBVGrid, cxInplaceContainer, cxBlobEdit, Vcl.Buttons, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, JvExControls, JvButton,
  JvTransparentButton, Vcl.Menus, AdvMenus, cxMemo, cxRichEdit, cxDBRichEdit,
  dxLayoutContainer, cxGridInplaceEditForm, AdvSplitter;

type
  TfrmEstructura = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    cmdPadres: TFDQuery;
    dscmdPadres: TDataSource;
    dstb_tree: TDataSource;
    cxPageControl2: TcxPageControl;
    tsNewStruct: TcxTabSheet;
    Panel1: TPanel;
    SpeedButton2: TSpeedButton;
    cxDBNavigator6: TcxDBNavigator;
    DBNavigator5: TDBNavigator;
    Panel7: TPanel;
    cxTabSheet1: TcxTabSheet;
    GViewSeries: TcxGrid;
    GViewSeriesDBTableView1: TcxGridDBTableView;
    GViewSeriesDBTableView1RootGroup: TcxGridInplaceEditFormGroup;
    GViewSeriesLevel1: TcxGridLevel;
    GViewSeriesDBTableView1IdEstructura: TcxGridDBColumn;
    GViewSeriesDBTableView1id: TcxGridDBColumn;
    GViewSeriesDBTableView1etiqueta: TcxGridDBColumn;
    GViewSeriesDBTableView1padre: TcxGridDBColumn;
    GViewSeriesDBTableView1icono: TcxGridDBColumn;
    GViewSeriesDBTableView1tipo: TcxGridDBColumn;
    Label1: TLabel;
    edtEtiqueta: TcxDBMemo;
    spPerfilTrabProy: TAdvSplitter;
    pPerfilTrabEstruct: TPanel;
    cxPageControl1: TcxPageControl;
    tsv1: TcxTabSheet;
    cxVG1: TcxDBVerticalGrid;
    iv1: TcxDBEditorRow;
    iv2: TcxDBEditorRow;
    iv3: TcxDBEditorRow;
    iv4: TcxDBEditorRow;
    iv5: TcxDBEditorRow;
    iv6: TcxDBEditorRow;
    iv7: TcxDBEditorRow;
    iv8: TcxDBEditorRow;
    iv9: TcxDBEditorRow;
    iv10: TcxDBEditorRow;
    iv11: TcxDBEditorRow;
    ToolBar3: TToolBar;
    ToolButton4: TToolButton;
    ToolButton9: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lcbTipoNodoPropertiesCloseUp(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure edtEtiquetaKeyPress(Sender: TObject; var Key: Char);
    procedure agregarfunClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function checkTreeState: Boolean;
  end;

var
  frmEstructura: TfrmEstructura;

implementation

uses
  UCapaDatos, UViewFunciones;

{$R *.dfm}

procedure TfrmEstructura.agregarfunClick(Sender: TObject);
begin
  if (UDM.tb_tree.State = dsInsert) or (UDM.tb_tree.State = dsEdit) then
    UDM.tb_tree.FieldByName('IdfunGeneral').AsInteger := GetIDFunctionValue
  else
  begin
    UDM.tb_tree.Edit;
    UDM.tb_tree.FieldByName('IdfunGeneral').AsInteger := GetIDFunctionValue
  end;
  {with TfrmSelectFuncionG.Create(nil) do
  try
    with cmdfun do begin
      Active:=False;
      SQL.Clear;
      SQL.Add('select * from cl_funcionesgen ') ;
      try
        Active:=True;
      except
      end;
    end;
    ShowModal;
  finally
    Free;
  end; }
end;

procedure TfrmEstructura.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmEstructura.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

function TfrmEstructura.checkTreeState: Boolean;
begin
  Result := TRUE;
  if (UDM.tb_tree.State = dsInsert) or (UDM.tb_tree.State = dsEdit) then
  begin
    if UDM.sms('¿Está seguro de salir y cancelar las modificaciones que se encontraba realizando?', 4)=6 then
    begin
      UDM.tb_tree.Cancel;
      Result := True;
    end
    else
      Result := False;
  end;

end;

procedure TfrmEstructura.edtEtiquetaKeyPress(Sender: TObject; var Key: Char);
begin
  {if Key = #13 then
  begin
    if (UDM.tb_tree.State = dsEdit) or (UDM.tb_tree.State = dsInsert) then
    begin
      UDM.tb_tree.Post;
      edtEtiqueta.Focused;
      edtEtiqueta.SetFocus;
    end;

  end;     }
end;

procedure TfrmEstructura.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
  cxPageControl2.ActivePage:=tsNewStruct;
  Width:=515;
  Height:=290;
{  if UDM.cl_tipoestructura.Locate('Idestructura', UDM.tb_tree.FieldByName('Idestructura').AsString, []) then begin
    if UDM.cl_perfilvariablesvirtproy.RecordCount>0 then begin
      Height:=560;
      spPerfilTrabProy.Visible:=True;
      spPerfilTrabProy.Align:=alTop;
      pPerfilTrabEstruct.Visible:=True;
      pPerfilTrabEstruct.Align:=alClient;
    end;
  end;  }

end;

procedure TfrmEstructura.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if checkTreeState then
    CanClose := True
  else
    CanClose := False;
end;

procedure TfrmEstructura.lcbTipoNodoPropertiesCloseUp(Sender: TObject);
begin
  UDM.tb_tree.FieldByName('icono').AsInteger := UDM.cl_tipoestructura.FieldByName('icon').AsInteger;
end;

procedure TfrmEstructura.SpeedButton1Click(Sender: TObject);
begin
  UDM.AddBlankNode;
end;

end.

