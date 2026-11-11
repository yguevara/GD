unit UNewNodefrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit,
  dxSkinsCore, dxSkinsDefaultPainters, cxMemo, cxRichEdit, cxDBRichEdit,
  cxCheckBox, cxDBEdit, cxMaskEdit, cxDropDownEdit, cxLookupEdit, cxDBLookupEdit,
  cxDBLookupComboBox, cxTextEdit, Vcl.StdCtrls, JvExControls, JvButton,
  JvTransparentButton, Vcl.ExtCtrls, AdvPanel, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmNewNodeform = class(TForm)
    AdvPanel1: TAdvPanel;
    btnCancel: TJvTransparentButton;
    btnOK: TJvTransparentButton;
    JvTransparentButton4: TJvTransparentButton;
    JvTransparentButton11: TJvTransparentButton;
    Label7: TLabel;
    edtCodEstructura: TcxDBTextEdit;
    Label9: TLabel;
    edtNombreEstructura: TcxDBTextEdit;
    cxDBLookupComboBox2: TcxDBLookupComboBox;
    Label10: TLabel;
    Label11: TLabel;
    cxDBRichEdit1: TcxDBRichEdit;
    Edit1: TEdit;
    Label3: TLabel;
    lcbRepresentante: TcxDBLookupComboBox;
    cxDBCheckBox1: TcxDBCheckBox;
    procedure JvTransparentButton4Click(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure JvTransparentButton11Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNewNodeform: TfrmNewNodeform;
  idEntrada: integer;
  Padreentrada: integer;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmNewNodeform.btnCancelClick(Sender: TObject);
begin
  if (UDM.tb_tree.State = dsEdit) or (UDM.tb_tree.State = dsInsert) then
  try
    UDM.tb_tree.Cancel;
    udm.tb_tree.Locate('id;etiqueta', vararrayof([IdPadreEditar, NombrePadreEditar]));
    Close;
  except
    on E: EFDException do
    begin
      UDM.sms('No se pudieron salvar los cambios solicitados. Motivo: ' + E.Message, 1);
      exit;
    end;
  end;
end;

procedure TfrmNewNodeform.btnOKClick(Sender: TObject);
begin
  if trim(edtCodEstructura.Text) = '' then
  begin
    UDM.sms('Debe especificar un identificador de estructura válido.', 1);
    edtCodEstructura.Focused;
    edtCodEstructura.SetFocus;
    Exit;
  end;
  if trim(edtNombreEstructura.Text) = '' then
  begin
    UDM.sms('Debe especificar una etiqueta valida de estructura.', 1);
    edtNombreEstructura.Focused;
    edtNombreEstructura.SetFocus;
    Exit;
  end;
  if (UDM.tb_tree.State = dsEdit) or (UDM.tb_tree.State = dsInsert) then
  try
    UDM.tb_tree.Post;
    UDM.tb_arbol.Active:=False;
    UDM.tb_arbol.Active:=True;
    UDM.CargarArbol(tvActivo^, UDM.tb_arbol, false);
//    UDM.CreaTreeDB(UDM.Conn, tvActivo, True);
    if udm.tb_tree.Locate('id;etiqueta', vararrayof([IdPadreEditar, NombrePadreEditar])) then
    begin
      if UDM.sms('¿Desea agregar un hijo al nodo actual (' + NombrePadreEditar + ')?', 4) = 6 then
      begin
        UDM.tb_tree.Append;
        UDM.tb_tree.FieldByName('Id').AsInteger := UDM.GetLastId('tb_tree', 'id');
        UDM.tb_tree.FieldByName('Padre').AsInteger := IdPadreEditar; //aowner
        UDM.tb_tree.FieldByName('aowner').AsString := administradornodoeditar;
        UDM.tb_tree.FieldByName('visible').AsBoolean := True;
        edtCodEstructura.SetFocus;
        edtCodEstructura.Focused;
        Exit;
      end;
    end;
    UDM.tb_tree.DisableControls;
    UDM.tb_tree.Active := False;
    UDM.tb_tree.Active := True;
    UDM.tb_tree.EnableControls;
    udm.tb_tree.Locate('id;etiqueta', vararrayof([IdPadreEditar, NombrePadreEditar]));
  except
    on E: EFDException do
    begin
      UDM.sms('No se pudieron salvar los cambios solicitados. Motivo: ' + E.Message, 1);
      exit;
    end;
  end;
end;

procedure TfrmNewNodeform.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=True;
  if (UDM.tb_tree.State = dsEdit) or (UDM.tb_tree.State = dsInsert) then
  try
    UDM.tb_tree.Cancel;
    udm.tb_tree.Locate('id;etiqueta', vararrayof([IdPadreEditar, NombrePadreEditar]));
  except
  end;
end;

procedure TfrmNewNodeform.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 112 then
    Application.HelpContext(21);
end;

procedure TfrmNewNodeform.FormShow(Sender: TObject);
begin
  Edit1.Focused;
  Edit1.SetFocus;
end;

procedure TfrmNewNodeform.JvTransparentButton11Click(Sender: TObject);
begin
  Application.HelpContext(21);
end;

procedure TfrmNewNodeform.JvTransparentButton4Click(Sender: TObject);
begin
  Close;
end;

end.

