unit UUserGest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, JvExComCtrls, JvListView, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  UCapaDatos, Vcl.ToolWin, JvExControls, JvButton, JvTransparentButton;

type
  TfrmGestUser = class(TForm)
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    tsGeneralProperties: TTabSheet;
    PMUsuarios: TPopupMenu;
    Establecercontrasea1: TMenuItem;
    N5: TMenuItem;
    Agregar1: TMenuItem;
    N1: TMenuItem;
    EliminarUsuario1: TMenuItem;
    N4: TMenuItem;
    Propiedades1: TMenuItem;
    lbUser: TJvListView;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnautentica: TJvTransparentButton;
    btnusercontrol: TJvTransparentButton;
    btnLC: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    JvTransparentButton2: TJvTransparentButton;
    procedure FormActivate(Sender: TObject);
    procedure Establecercontrasea1Click(Sender: TObject);
    procedure Agregar1Click(Sender: TObject);
    procedure EliminarUsuario1Click(Sender: TObject);
    procedure Propiedades1Click(Sender: TObject);
    procedure lbUserDblClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
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
    UDM.cl_Resp_Gest_Arch.Append;
    ShowModal;
  finally
    Free;
    //FormActivate(Sender);
  end;
  UpdateUserList;
end;

procedure TfrmGestUser.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGestUser.EliminarUsuario1Click(Sender: TObject);
begin
  if lbUser.ItemIndex <> -1 then
  begin
    if (lbUser.Items[lbUser.ItemIndex].Caption <> UDM.UserName) and (AnsiLowerCase(lbUser.Items[lbUser.ItemIndex].Caption) <> 'administrador') then
    begin

      if UDM.cl_Resp_Gest_Arch.Locate('usuario', lbUser.Items[lbUser.ItemIndex].Caption, []) then
      begin
        if UDM.sms('¿Está seguro de querer borrar el usuario "'+lbUser.Items[lbUser.ItemIndex].Caption+'"?', 4)=6 then
          UDM.cl_Resp_Gest_Arch.Delete;
      end;

    end
    else
    begin
      UDM.sms('No puede eliminar el usuario "'+lbUser.Items[lbUser.ItemIndex].Caption+'". Verifique: ' + #13 + '1- Que el usuario especificado no sea el administrador del sistema.' + #13 + '2- Que el usuario especificado no sea el mismo con el que se encuentra autenticado en el sistema.', 2);
      Exit;
    end;
  end
  else
    UDM.sms('Debe seleccionar un usuario válido.', 3);
  UpdateUserList;
end;

procedure TfrmGestUser.Establecercontrasea1Click(Sender: TObject);
var
  nombreu: string;
begin
  nombreu := '';
  if lbUser.ItemIndex <> -1 then
  begin     // UDM.cl_Resp_Gest_Arch
    if UDM.cl_Resp_Gest_Arch.Locate('usuario', lbUser.Items[lbUser.ItemIndex].Caption, []) then
      nombreu := UDM.cl_Resp_Gest_Arch.FieldByName('usuario').AsString;
    with TfrmChangePass.Create(nil) do
    try
      Caption := 'Establecer contraseña para ' + nombreu;
      ShowModal;
    finally
      Free;
    end;
  end
  else
    UDM.sms('Debe seleccionar un usuario válido.', 3);
end;

procedure TfrmGestUser.FormActivate(Sender: TObject);
begin
  UpdateUserList;
end;

procedure TfrmGestUser.lbUserDblClick(Sender: TObject);
begin
  if lbUser.ItemIndex <> -1 then
  begin
    if UDM.cl_Resp_Gest_Arch.Locate('usuario', lbUser.Items[lbUser.ItemIndex].Caption, []) then
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

procedure TfrmGestUser.Propiedades1Click(Sender: TObject);
begin
  if lbUser.ItemIndex <> -1 then
  begin
    if UDM.cl_Resp_Gest_Arch.Locate('usuario', lbUser.Items[lbUser.ItemIndex].Caption, []) then
    begin
      with TfrmProperties.Create(nil) do
      try
        ShowModal;
      finally
        Free;
      end;
      UpdateUserList;
    end;
  end else
    UDM.sms('Debe seleccionar un usuario válido.', 3);
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
    ListItem.Caption := UDM.cmdUser.FieldByName('usuario').AsString;
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('Nombre').AsString);
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('rol').AsString);
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('email').AsString);
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('telefono').AsString);
    ListItem.ImageIndex := 133;
    ListItem.StateIndex := 133;
    lbUser.Items.EndUpdate;
    UDM.cmdUser.Next;
  end;
end;

end.

