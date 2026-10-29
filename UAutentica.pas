unit UAutentica;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, DB, Data.Win.ADODB, dxGDIPlusClasses,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, dxSkinsCore, dxSkinsDefaultPainters, cxTextEdit, IdGlobal, IdHash,
  IdHashMessageDigest;

type
  TfrmAutentica = class(TForm)
    lbluser: TLabel;
    lblpass: TLabel;
    edtuser: TEdit;
    btnAcept: TButton;
    btnCancel: TButton;
    Image1: TImage;
    btnHelp: TButton;
    edtpass: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure btnaceptClick(Sender: TObject);
    procedure btncancelClick(Sender: TObject);
    procedure edtpassKeyPress(Sender: TObject; var Key: Char);
    procedure btnAceptKeyPress(Sender: TObject; var Key: Char);
    procedure btnCancelKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure edtuserKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function FormHelp(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    Arol: string;
    LogeUser, userrol: string;
  public
    { Public declarations }
    EsCargado: boolean;
    function getFileMd5HashString(const vFileName: string): string;
    function getMd5HashString(const vValue: string): string;
  end;

function autenticar: string;

implementation

uses
  md5, DBClient, USecurityClasss, UCapaDatos, USystemMsg;


{$R *.dfm}

function autenticar: string;
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
  if trim(edtuser.Text) = '' then
  begin
    edtuser.SetFocus;
    edtuser.Focused;
  end
  else
  begin
    edtpass.SetFocus;
    edtpass.Focused;
  end;
  Arol := 'Visor';
end;

function TfrmAutentica.FormHelp(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
begin
  HelpFile := ExtractFilePath(Application.ExeName) + 'ArchiGenio.chm';
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

var
  List: TStringList;
  cadpass:string;
begin
  if trim(edtuser.Text) = '' then
  begin
    UDM.sms('Debe especificar un nombre de usuario válido.', 2);
    edtuser.Focused;
    edtuser.SetFocus;
    UDM.log('Se ha producido un intento de autenticación en la PC "' + DatosPC.Nombre + '" con el nombre de usuario "' + DatosPC.Usuario + '". Debe especificar un nombre de usuario válido.', 11, '', '', '');
    Exit;
  end;
  if (Trim(edtpass.Text) = '') or (length(edtpass.Text) < 4) then
  begin
    UDM.sms('Debe especificar una contraseña válida la cual no puede ser un caracter en blanco ni tener menos de cuatro caracteres de longitud.', 2);
    edtpass.Focused;
    edtpass.SetFocus;
    UDM.log('Se ha producido un intento de autenticación en la PC "' + DatosPC.Nombre + '" con el nombre de usuario ". ' + DatosPC.Usuario + '".Debe especificar un nombre de usuario válido.', 11, '', '', '');
    Exit;
  end;
  if UDM.cl_Resp_Gest_Arch.Locate('usuario', trim(edtuser.Text), []) then
  begin
    cadpass:=UDM.getMd5HashString(trim(edtpass.Text));
    UDM.Rol := Security.GetRol(UDM.Conn, AnsiLowerCase(trim(edtuser.Text)), trim(edtpass.Text), cadpass);
    if trim(UDM.Rol) = '' then
    begin
      UDM.sms('El usuario y/o la contraseña son incorrectos. Por favor contacte con un administrador del sistema.', 2);
      if not EsCargado then
      begin
        edtuser.Text := '';
        edtpass.Text := '';
        edtuser.SetFocus;
        edtuser.Focused;
      end
      else
      begin
        edtpass.Text := '';
        edtpass.SetFocus;
        edtpass.Focused;
      end;
      Exit
    end
    else
    begin
      UDM.UserName := trim(edtuser.Text);
      List := TStringList.Create;
      List.Add(trim(edtuser.Text));
      List.SaveToFile(PathTemp + 'lastuseraut.ini');
      List.Free;
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

procedure TfrmAutentica.btnHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 11;
  Application.HelpContext(11);
end;

procedure TfrmAutentica.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    btncancelClick(Sender);
end;

procedure TfrmAutentica.FormShow(Sender: TObject);
var
  List: TStringList;
begin
  EsCargado := False;
  if FileExists(PathTemp + 'lastuseraut.ini') then
  begin
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'lastuseraut.ini');
    if trim(List[0]) <> '' then
    begin
      edtuser.Text := List[0];
      edtpass.Focused;
      edtpass.SetFocus;
      EsCargado := True;
    end;
    List.Free;
  end;
end;

function TfrmAutentica.getFileMd5HashString(const vFileName: string): string;
var
  vHashMD5: TIdHashMessageDigest5;
  vFile: TFileStream;
begin
  vFile := TFileStream.Create(vFileName, fmOpenRead OR fmShareDenyWrite);
  vHashMD5 := nil;
  try
    vHashMD5 := TIdHashMessageDigest5.Create;
    Result := IdGlobal.IndyLowerCase(vHashMD5.HashStreamAsHex(vFile));
  finally
    vHashMD5.Free;
  end;
end;

function TfrmAutentica.getMd5HashString(const vValue: string): string;
var
  vHashMD5: TIdHashMessageDigest5;
begin
  vHashMD5 := nil;
  try
    vHashMD5 := TIdHashMessageDigest5.Create;
    Result := IdGlobal.IndyLowerCase(vHashMD5.HashStringAsHex(vValue));
  finally
    vHashMD5.Free;
  end;
end;

procedure TfrmAutentica.edtuserKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
  if Key = 112 then
  begin
    TopicID := 11;
    Application.HelpContext(TopicID);
  end;
end;

end.

