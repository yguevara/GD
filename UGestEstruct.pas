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
  JvTransparentButton, Vcl.Menus, AdvMenus, cxMemo, cxRichEdit, cxDBRichEdit;

type
  TfrmEstructura = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    pcTree: TcxPageControl;
    tsAddNodo: TcxTabSheet;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    Panel1: TPanel;
    Label2: TLabel;
    edtCodigo: TcxDBTextEdit;
    Label1: TLabel;
    edtEtiqueta: TcxDBTextEdit;
    SpeedButton1: TSpeedButton;
    tseditNode: TcxTabSheet;
    Panel2: TPanel;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    Label3: TLabel;
    edtCodigoMod: TcxDBTextEdit;
    Label4: TLabel;
    edtEtiquetaMod: TcxDBTextEdit;
    lcbPadre: TcxDBLookupComboBox;
    Label5: TLabel;
    cmdPadres: TFDQuery;
    dscmdPadres: TDataSource;
    btnFacultades: TJvTransparentButton;
    btnFunciones: TJvTransparentButton;
    PMFunciones: TAdvPopupMenu;
    agregarfun: TMenuItem;
    eliminarfun: TMenuItem;
    PMFacultades: TAdvPopupMenu;
    agregarfac: TMenuItem;
    eliminarfac: TMenuItem;
    tsFuncionesEspecificas: TcxTabSheet;
    Panel3: TPanel;
    cxDBNavigator2: TcxDBNavigator;
    DBNavigator2: TDBNavigator;
    dbFunEsp: TcxDBRichEdit;
    tsFacultades: TcxTabSheet;
    Panel4: TPanel;
    cxDBNavigator4: TcxDBNavigator;
    DBNavigator4: TDBNavigator;
    tsFunGen: TcxTabSheet;
    Panel5: TPanel;
    cxDBNavigator5: TcxDBNavigator;
    dbreFacultades: TcxDBRichEdit;
    cmdFunGen: TFDQuery;
    dscmdFunGen: TDataSource;
    dstb_tree: TDataSource;
    JvTransparentButton1: TJvTransparentButton;
    cxDBRichEdit1: TcxDBRichEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lcbTipoNodoPropertiesCloseUp(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure edtEtiquetaKeyPress(Sender: TObject; var Key: Char);
    procedure agregarfunClick(Sender: TObject);
    procedure eliminarfunClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure dstb_treeDataChange(Sender: TObject; Field: TField);
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

function TfrmEstructura.checkTreeState: Boolean;
begin
  Result := TRUE;
  if (UDM.tb_tree.State = dsInsert) or (UDM.tb_tree.State = dsEdit) then
  begin
    if MessageDlg('�Est� seguro de salir y cancelar las modificaciones que se encontraba realizando?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      UDM.tb_tree.Cancel;
      Result := True;
    end
    else
      Result := False;
  end;

end;

procedure TfrmEstructura.dstb_treeDataChange(Sender: TObject; Field: TField);
begin
  if trim(UDM.tb_tree.FieldByName('IdfunGeneral').AsString) <> '' then
    with cmdFunGen do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select *  from cl_funcionesgen where idfunciones=' + UDM.tb_tree.FieldByName('IdfunGeneral').AsString);
      try
        Active := True;
      except
      end;
    end;
end;

procedure TfrmEstructura.edtEtiquetaKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    if (UDM.tb_tree.State = dsEdit) or (UDM.tb_tree.State = dsInsert) then
    begin
      UDM.tb_tree.Post;
      edtEtiqueta.Focused;
      edtEtiqueta.SetFocus;
    end;

  end;
end;

procedure TfrmEstructura.eliminarfunClick(Sender: TObject);
begin
  if MessageDlg('�Est� seguro que quiere eliminar las funciones generales asignadas?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    UDM.tb_tree.Edit;
    UDM.tb_tree.FieldByName('IdfunGeneral').Value := null;
    UDM.tb_tree.Post;
  end;
end;

procedure TfrmEstructura.FormActivate(Sender: TObject);
begin
  if tsAddNodo.Visible then
  begin
    edtEtiqueta.Focused;
    edtEtiqueta.SetFocus;
  end;
  if tseditNode.Visible then
  begin
    edtEtiquetaMod.Focused;
    edtEtiquetaMod.SetFocus;
  end;
  {if (UDM.tb_tree.FieldByName('IdfunGeneral').AsString <> null) and (trim(UDM.tb_tree.FieldByName('IdfunGeneral').AsString) <> '') then
  begin
    with cmdFunGen do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select * from cl_funcionesgen where idfunciones=' + UDM.tb_tree.FieldByName('IdfunGeneral').AsString);
    end;
  end;  }
  if Trim(UDM.tb_tree.FieldByName('IdfunGeneral').AsString) <> '' then
    with cmdFunGen do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select *  from cl_funcionesgen where idfunciones=' + UDM.tb_tree.FieldByName('IdfunGeneral').AsString);
      try
        Active := True;
      except
      end;
    end;
end;

procedure TfrmEstructura.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if checkTreeState then
    CanClose := True
  else
    CanClose := False;
end;

procedure TfrmEstructura.FormCreate(Sender: TObject);
begin
  tsFunGen.TabVisible := False;
  tsFuncionesEspecificas.TabVisible := False;
  tsFacultades.TabVisible := False;
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

