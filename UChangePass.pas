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
  md5, UCapaDatos, UAutenticacion, UMensajes;

procedure TfrmChangePass.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmChangePass.btnCreateUserClick(Sender: TObject);
var
  MensajeClave: string;
begin
  // Regla unica de clave nueva (longitud minima y confirmacion): ver UAutenticacion.
  if not ValidarClaveNueva(Trim(edtpass.Text), Trim(edtconfirmpass.Text), MensajeClave) then
  begin
    TMensajes.Advertencia('No se pudo cambiar la contraseña.' + sLineBreak + MensajeClave, 'Cambio de contraseña');
    Exit;
  end;
  if (edtpass.Text = edtconfirmpass.Text) and (edtpass.text <> '') then
  begin

      UDM.cl_Resp_Gest_Arch.Edit;
      UDM.cl_Resp_Gest_Arch.FieldByName('password').AsString := CalcularMd5(Trim(edtpass.Text));
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

