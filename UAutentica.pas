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
    CDSUser: TADOTable;
    CDSRol: TADOTable;
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
    {CDSUser.Connection := conn;
    CDSRol.Connection := conn;
    CDSUser.Active := True;
    cdsrol.Active := True;}
    showmodal;
  finally
    {result := DM.Rol;
    CDSUser.Active := false;
    cdsrol.Active := False;  }
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
  TopicID :=0 {#?};
  HelpFile := ExtractFilePath(Application.ExeName) + 'GeoDatoIC.chm';
  Application.HelpSystem.ShowContextHelp(TopicID, HelpFile);
end;

procedure TfrmAutentica.btnaceptClick(Sender: TObject);
 {
  function nombreuser(NU: string): Boolean;
  begin
    Result := False;
    CDSUser.First;
    while not CDSUser.Eof do
    begin
      if AnsiLowerCase(CDSUser.FieldByName('NombreUser').AsString) = AnsiLowerCase(NU) then
      begin
        if (cdsrol.Locate('idrol', CDSUser.FieldByName('rol').AsString, [])) then
        begin
          DM.ROL := CDSrol.FieldByName('rol').AsString;
          Result := True;
          Exit;
        end;
      end;
      CDSUser.Next;
    end;
  end;

  function buscaUser(IdUser, IdPass: string): boolean;
  begin
    nombreuser(IdUser);
    CDSUser.First;
    result := False;
    if CDSUser.Locate('NombreUser;Pass', VarArrayOf([ansilowercase(IdUser), IdPass]), []) then
      Result := IdPass = CDSUser.FieldByName('pass').AsString;
  end; }

begin
  {if trim(edtuser.Text) = '' then
  begin
    MessageDlg('Debe especificar un nombre de usuario v�lido.', mtWarning, [mbOK], 0);
    edtuser.Focused;
    edtuser.SetFocus;
    Exit;
  end;
  if (Trim(edtpass.Text) = '') or (length(edtpass.Text) < 4) then
  begin
    MessageDlg('Debe especificar una contrase�a v�lida la cual no puede ser un caracter en blanco ni tener menos de cuatro caracteres de longitud.', mtWarning, [mbOK], 0);
    edtpass.Focused;
    edtpass.SetFocus;
    Exit;
  end;
  DM.Rol := Security.GetRol(DM.FDConn, AnsiLowerCase(trim(edtuser.Text)), trim(edtpass.Text), '');
  if trim(DM.Rol) = '' then
  begin
    MessageDlg('El usuario y/o la contrase�a son incorrectos. Por favor contacte con un administrador del sistema.', mtWarning, [mbOK], 0);
    edtuser.Text := '';
    edtpass.Text := '';
    edtuser.SetFocus;
    edtuser.Focused;
    Exit
  end
  else
  begin
    DM.UserName := trim(edtuser.Text);
    Close;
  end;}
end;

procedure TfrmAutentica.btncancelClick(Sender: TObject);
begin
  {UserROL := 'Visor';
  DM.Username := 'Invitado'; }
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

