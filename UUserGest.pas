unit UUserGest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, JvExComCtrls, JvListView, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  UCapaDatos;

type
  TfrmGestUser = class(TForm)
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    tsGeneralProperties: TTabSheet;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    lbUser: TJvListView;
    PMUsuarios: TPopupMenu;
    Establecercontrasea1: TMenuItem;
    N5: TMenuItem;
    Agregar1: TMenuItem;
    N1: TMenuItem;
    EliminarUsuario1: TMenuItem;
    N4: TMenuItem;
    Propiedades1: TMenuItem;
    procedure FormActivate(Sender: TObject);
    procedure Establecercontrasea1Click(Sender: TObject);
    procedure Agregar1Click(Sender: TObject);
    procedure EliminarUsuario1Click(Sender: TObject);
    procedure Propiedades1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateUserList;
  end;

var
  frmGestUser: TfrmGestUser;

implementation

{$R *.dfm}

uses
  UChangePass, UNewUser, UUserProperties;

procedure TfrmGestUser.Agregar1Click(Sender: TObject);
var
  ListItem: TListItem;
begin
  with TfrmNewUser.Create(nil) do
  try
    UDM.Tb_User.Append;
    ShowModal;
  finally
    Free;
    //FormActivate(Sender);
  end;
  UpdateUserList;
end;

procedure TfrmGestUser.EliminarUsuario1Click(Sender: TObject);
begin
  if lbUser.ItemIndex <> -1 then
  begin
    if (lbUser.Items[lbUser.ItemIndex].Caption <> UDM.UserName) and (AnsiLowerCase(lbUser.Items[lbUser.ItemIndex].Caption) <> 'administrador') then
    begin

      if UDM.Tb_User.Locate('nombreuser', lbUser.Items[lbUser.ItemIndex].Caption, []) then
      begin
        if MessageDlg('�Est� seguro de querer borrar el usuario especificado?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
          UDM.Tb_User.Delete;
      end;

    end
    else
    begin
      MessageDlg('No puede eliminar el usuario especificado. Verifique: ' + #13 + '1- Que el usuario especificado no sea el administrador del sistema.' + #13 + '2- Que el usuario especificado no sea el mismo con el que se encuentra autenticado en el sistema.', mtWarning, [mbOK], 0);
      Exit;
    end;
  end
  else
    MessageDlg('Debe seleccionar un usuario v�lido.', mtInformation, [mbOK], 0);
  UpdateUserList;
end;

procedure TfrmGestUser.Establecercontrasea1Click(Sender: TObject);
var
  nombreu: string;
begin
  nombreu := '';
  if lbUser.ItemIndex <> -1 then
  begin
    if UDM.Tb_User.Locate('nombreuser', lbUser.Items[lbUser.ItemIndex].Caption, []) then
      nombreu := UDM.Tb_User.FieldByName('nombreuser').AsString;
    with TfrmChangePass.Create(nil) do
    try
      Caption := 'Establecer contrase�a para ' + nombreu;
      ShowModal;
    finally
      Free;
    end;
  end
  else
    MessageDlg('Debe seleccionar un usuario v�lido.', mtInformation, [mbOK], 0);
end;

procedure TfrmGestUser.FormActivate(Sender: TObject);
begin
  UpdateUserList;
end;

procedure TfrmGestUser.Propiedades1Click(Sender: TObject);
begin
  if lbUser.ItemIndex <> -1 then
  begin
    if UDM.Tb_User.Locate('nombreuser', lbUser.Items[lbUser.ItemIndex].Caption, []) then
    begin
      with TfrmProperties.Create(nil) do
      try
        ShowModal;
      finally
        Free;
      end;
      UpdateUserList;
    end;
  end;
end;

procedure TfrmGestUser.UpdateUserList;
var
  ListItem: TListItem;
begin
  lbUser.Items.Clear;
  UDM.cmdUser.Active := False;
  UDM.cmdUser.Active := True;
  UDM.cmdUser.First;
  while not UDM.cmdUser.Eof do
  begin
    lbUser.Items.BeginUpdate;
    ListItem := lbUser.Items.Add;
    ListItem.Caption := UDM.cmdUser.FieldByName('nombreuser').AsString;
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('nombreluser').AsString);
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('rol').AsString);
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('ministerio').AsString);
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('empresa').AsString);
    ListItem.ImageIndex := 133;
    ListItem.StateIndex := 133;
    lbUser.Items.EndUpdate;
    UDM.cmdUser.Next;
  end;
end;

end.

