unit UAutentica;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, DB, Data.Win.ADODB, dxGDIPlusClasses;

type
  TfrmAutentica = class(TForm)
    lbluser: TLabel;
    lblpass: TLabel;
    edtuser: TEdit;
    edtpass: TEdit;
    btnAcept: TButton;
    btnCancel: TButton;
    Image1: TImage;
    procedure FormActivate(Sender: TObject);
    procedure btnaceptClick(Sender: TObject);
    procedure btncancelClick(Sender: TObject);
    procedure edtpassKeyPress(Sender: TObject; var Key: Char);
    procedure edtuserKeyPress(Sender: TObject; var Key: Char);
    procedure btnAceptKeyPress(Sender: TObject; var Key: Char);
    procedure btnCancelKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure edtuserKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function FormHelp(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
  private
    { Private declarations }
    Arol: string;
    LogeUser, userrol: string;
  public
    { Public declarations }
  end;

function autenticar(conn: TadoConnection): string;

implementation

uses
  md5, DBClient, USecurityClasss, UCapaDatos;


{$R *.dfm}

function autenticar(conn: TAdoConnection): string;
begin
  with TfrmAutentica.create(nil) do
  try
    result := 'Visor';
    showmodal;
  finally
    result := UDM.Rol;
    free;
  end;
end;

procedure TfrmAutentica.FormActivate(Sender: TObject);
begin
  edtuser.SetFocus;
  edtuser.Focused;
  Arol := 'Visor';
end;

function TfrmAutentica.FormHelp(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
var
  TopicID: integer;
begin
  TopicID := 0 {#?};
  HelpFile := ExtractFilePath(Application.ExeName) + 'GeoDatoIC.chm';
  Application.HelpSystem.ShowContextHelp(TopicID, HelpFile);
end;

procedure TfrmAutentica.btnaceptClick(Sender: TObject);

  function nombreuser(NU: string): Boolean;
  begin
    Result := False;
    UDM.cl_Resp_Gest_Arch.First;
    while not UDM.cl_Resp_Gest_Arch.Eof do
    begin
      if AnsiLowerCase(UDM.cl_Resp_Gest_Arch.FieldByName('usuario').AsString) = AnsiLowerCase(NU) then
      begin
        if (UDM.Tb_Rol.Locate('idrol', UDM.cl_Resp_Gest_Arch.FieldByName('rol').AsString, [])) then
        begin
          UDM.ROL := UDM.Tb_Rol.FieldByName('rol').AsString;
          Result := True;
          Exit;
        end;
      end;
      udm.cl_Resp_Gest_Arch.Next;
    end;
  end;

  function buscaUser(IdUser, IdPass: string): boolean;
  begin
    nombreuser(IdUser);
    UDM.cl_Resp_Gest_Arch.First;
    result := False;
    if UDM.cl_Resp_Gest_Arch.Locate('usuario;password', VarArrayOf([ansilowercase(IdUser), IdPass]), []) then
      Result := IdPass = UDM.cl_Resp_Gest_Arch.FieldByName('password').AsString;
  end;

begin
  if trim(edtuser.Text) = '' then
  begin
    UDM.sms('Debe especificar un nombre de usuario válido.', 2);
    edtuser.Focused;
    edtuser.SetFocus;
    Exit;
  end;
  if (Trim(edtpass.Text) = '') or (length(edtpass.Text) < 4) then
  begin
    UDM.sms('Debe especificar una contraseña válida la cual no puede ser un caracter en blanco ni tener menos de cuatro caracteres de longitud.', 2);
    edtpass.Focused;
    edtpass.SetFocus;
    Exit;
  end;
  if UDM.cl_Resp_Gest_Arch.Locate('usuario', trim(edtuser.Text), []) then
  begin

    UDM.Rol := Security.GetRol(UDM.Conn, AnsiLowerCase(trim(edtuser.Text)), trim(edtpass.Text), '');
    if trim(UDM.Rol) = '' then
    begin
      UDM.sms('El usuario y/o la contraseña son incorrectos. Por favor contacte con un administrador del sistema.', 2);
      edtuser.Text := '';
      edtpass.Text := '';
      edtuser.SetFocus;
      edtuser.Focused;
      Exit
    end
    else
    begin
      UDM.UserName := trim(edtuser.Text);
      Close;
    end;
  end
  else
  begin
    UDM.sms('El usuario "' + edtuser.Text + '" no se encuentra en la base de datos.', 1);
    edtuser.SetFocus;
    edtuser.Focused;
    Exit;
  end;
end;

procedure TfrmAutentica.btncancelClick(Sender: TObject);
begin
  UserROL := 'Visor';
  UDM.Username := 'Invitado';
  Close;
end;

procedure TfrmAutentica.edtpassKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then { BackSpace Key }
    btnaceptClick(Sender);
  if Key = #27 then
    btncancelClick(Sender);
end;

procedure TfrmAutentica.edtuserKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    edtpass.SetFocus;
    edtpass.Focused;
  end;
  if Key = #27 then
    btncancelClick(Sender);
end;

procedure TfrmAutentica.btnAceptKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    btncancelClick(Sender);
end;

procedure TfrmAutentica.btnCancelKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    btncancelClick(Sender);
end;

procedure TfrmAutentica.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    btncancelClick(Sender);
end;

procedure TfrmAutentica.edtuserKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 112 then
    Application.HelpContext(40);
end;

end.

