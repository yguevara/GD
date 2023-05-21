unit UAddNewNode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, Vcl.ComCtrls, Vcl.DBCtrls, cxNavigator, cxDBNavigator,
  Vcl.ExtCtrls, Vcl.ToolWin, cxContainer, cxEdit, JvExControls, JvButton,
  JvTransparentButton, cxDBEdit, Vcl.StdCtrls, cxMaskEdit, cxDropDownEdit,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, cxTextEdit, cxMemo,
  cxRichEdit, cxDBRichEdit, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, cxCheckBox, Vcl.Buttons;

type
  TfrmNewNode = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    btnClose: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton6: TToolButton;
    btnhlp: TToolButton;
    ToolButton5: TToolButton;
    StatusBar1: TStatusBar;
    GroupBox3: TGroupBox;
    edtDescripcion: TcxDBRichEdit;
    lcbTipodeObjeto: TcxDBLookupComboBox;
    Label5: TLabel;
    lcbRepresentante: TcxDBLookupComboBox;
    Label3: TLabel;
    edtEtiqueta: TcxDBTextEdit;
    Label1: TLabel;
    edtdeposito: TcxDBTextEdit;
    Label4: TLabel;
    Label6: TLabel;
    cxDBCheckBox1: TcxDBCheckBox;
    procedure btnCloseClick(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure lcbTipodeObjetoPropertiesCloseUp(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    IdPadre: Integer;
  end;

var
  frmNewNode: TfrmNewNode;

implementation

uses
  UCapaDatos, UVarVirtualVar;

{$R *.dfm}

procedure TfrmNewNode.btnCloseClick(Sender: TObject);
begin
  if (UDM.tb_tree.State = dsinsert) or (UDM.tb_tree.State = dsedit) then
    UDM.tb_tree.Cancel;
  Close;
end;

procedure TfrmNewNode.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (UDM.tb_tree.State = dsinsert) or (UDM.tb_tree.State = dsedit) then
    UDM.tb_tree.Cancel;
end;

procedure TfrmNewNode.FormCreate(Sender: TObject);
begin
  edtdeposito.TabOrder := 0;
  edtetiqueta.TabOrder := 1;
  //lcbRepresenta.properties.TabOrder := 0;
  cxDBCheckBox1.TabOrder := 2;
  edtDescripcion.TabOrder := 3;
end;

procedure TfrmNewNode.JvTransparentButton1Click(Sender: TObject);
begin
  try
    UDM.tb_tree.Post;
  except
    on E: EFDException do
    begin
      UDM.sms('No se pudo agregar un nuevo nodo. Motivo: ' + e.Message, 1);
      UDM.tb_tree.Cancel;
    end;
  end;
  Close;
end;

procedure TfrmNewNode.lcbTipodeObjetoPropertiesCloseUp(Sender: TObject);
var
  Ic: variant;
begin
  if (UDM.tb_tree.State = dsInsert) or (UDM.tb_tree.State = dsedit) then
    with UDM.CMD do
    begin
      active := False;
      SQL.Clear;
      SQL.Add('select icon from cl_tipoobj where idtipoobj=' + IntToStr(UDM.VarToInt(lcbTipodeObjeto.EditValue)));
      try
        Active := True;
        UDM.tb_tree.FieldByName('Icono').AsString := Fields[0].AsString;
      except
      end;
    end;

end;

procedure TfrmNewNode.SpeedButton1Click(Sender: TObject);
begin
  if UDM.tb_tree.RecordCount > 0 then
  begin
    UDM.UpdateVarPrj(UDM.tb_tree.FieldByName('IdEstructura').AsString, UDM.tb_tree.FieldByName('Id').AsString);
    TipoObj := 'E';
    with TfrmVarVirtualVar.Create(nil) do
    try
      cxGridDBTableView1.DataController.DataSource := UDM.dsVarDispPrj;
      Caption := 'Variables asignadas a la estructura ' + AnsiQuotedStr(UDM.tb_tree.FieldByName('etiqueta').AsString, '"');
      ShowModal;
    finally
      Free;
    end;
  end
  else
  begin
    UDM.sms('Por favor seleccione una estructura válida para la asignación de variables.', 2);
    Exit;
  end;
end;

end.

