unit UChangePass;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB,
  Data.Win.ADODB, System.UITypes;

type
  TfrmChangePass = class(TForm)
    lblPass: TLabel;
    Label3: TLabel;
    edtconfirmpass: TEdit;
    edtpass: TEdit;
    btnCreateUser: TButton;
    btnClose: TButton;
    procedure btnCreateUserClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmChangePass: TfrmChangePass;

implementation

{$R *.dfm}

uses
  md5, UCapaDatos;

procedure TfrmChangePass.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmChangePass.btnCreateUserClick(Sender: TObject);
begin
  if Length(edtpass.Text) <= 4 then
  begin
    UDM.sms('No se pudo cambiar la contraseña.', 1);
    UDM.sms('La longitud de la contraseña debe ser mayor de cuatro carácteres.', 3);
    Exit;
  end;
  if (edtpass.Text = edtconfirmpass.Text) and (edtpass.text <> '') then
  begin

      UDM.cl_Resp_Gest_Arch.Edit;
      UDM.cl_Resp_Gest_Arch.FieldByName('password').AsString := MD5Print(MD5String(edtpass.Text));
      try
        UDM.cl_Resp_Gest_Arch.Post;
        UDM.sms('¡La contraseña se ha cambiado satisfactoriamente!', 3);
        Close;
      except
        on E: EDataBaseError do
        begin
          UDM.sms(E.Message, 1);
          Exit;
        end;
      end;

  end
  else
  begin
    UDM.sms('Por favor verifique la contraseña. Deben coincidir la contraseña y su confirmación para continuar.', 3);
    Exit;
  end;
end;

end.

