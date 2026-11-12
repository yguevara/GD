unit UAutentica;

{ ---------------------------------------------------------------------------
  Ventana de inicio de sesion.

  Esta unidad SOLO captura usuario y clave y muestra el resultado; la logica de
  verificacion vive en UAutenticacion (sin VCL, con pruebas). La ventana nunca
  modifica la sesion (UDM.Rol / UDM.UserName): devuelve un TResultadoAutenticacion
  y quien la llama (TMAIN.btnautenticaClick) decide que hacer con el.

  Uso:
    if Autenticar(Resultado) then
      // Resultado.Usuario y Resultado.Rol son validos
    else
      // el usuario cancelo (o cerro la ventana): la sesion no cambia
  --------------------------------------------------------------------------- }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, DB, Data.Win.ADODB, dxGDIPlusClasses,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, dxSkinsCore, dxSkinsDefaultPainters, cxTextEdit, UAutenticacion;

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
    lblMensaje: TLabel;
    chkMostrarClave: TCheckBox;
    procedure btnaceptClick(Sender: TObject);
    procedure edtuserKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function FormHelp(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
    procedure btnHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chkMostrarClaveClick(Sender: TObject);
    procedure CampoCambio(Sender: TObject);
  private
    FResultado: TResultadoAutenticacion;
    procedure MostrarMensaje(const ATexto: string);
    procedure RegistrarFallo(const AMotivo: string);
  public
    { Resultado del intento aceptado; solo es valido si ShowModal devolvio mrOk. }
    property Resultado: TResultadoAutenticacion read FResultado;
  end;

{ Muestra la ventana de inicio de sesion. Devuelve True solo si el usuario se
  autentico correctamente; en ese caso AResultado trae usuario y rol. Si
  devuelve False (cancelo o cerro la ventana) AResultado.Rol queda vacio y no
  se toca ningun dato de la sesion. }
function Autenticar(out AResultado: TResultadoAutenticacion): Boolean;

implementation

uses
  UCapaDatos;

{$R *.dfm}

const
  ARCHIVO_ULTIMO_USUARIO = 'lastuseraut.ini';
  TEMA_AYUDA_LOGIN = 11;

function Autenticar(out AResultado: TResultadoAutenticacion): Boolean;
var
  Ventana: TfrmAutentica;
begin
  AResultado.Estado := eaCredencialesInvalidas;
  AResultado.Usuario := '';
  AResultado.Rol := '';
  AResultado.Mensaje := '';
  AResultado.Detalle := '';
  Ventana := TfrmAutentica.Create(nil);
  try
    Result := (Ventana.ShowModal = mrOk) and (Ventana.Resultado.Estado = eaAceptado);
    if Result then
      AResultado := Ventana.Resultado;
  finally
    Ventana.Free;
  end;
end;

{ Muestra un mensaje de error bajo los campos. }
procedure TfrmAutentica.MostrarMensaje(const ATexto: string);
begin
  lblMensaje.Caption := ATexto;
  lblMensaje.Visible := ATexto <> '';
end;

{ Deja constancia en el registro del sistema de un intento fallido. Nunca
  incluye la clave escrita. }
procedure TfrmAutentica.RegistrarFallo(const AMotivo: string);
begin
  UDM.log('Intento de autenticacion fallido en la PC "' + DatosPC.Nombre +
    '" (usuario del sistema operativo "' + DatosPC.Usuario + '") con el nombre de usuario "' +
    NormalizarUsuario(edtuser.Text) + '". ' + AMotivo, 11, '', '', '');
end;

procedure TfrmAutentica.btnaceptClick(Sender: TObject);
var
  Intento: TResultadoAutenticacion;
  Mensaje: string;
begin
  if not ValidarCampos(edtuser.Text, edtpass.Text, Mensaje) then
  begin
    MostrarMensaje(Mensaje);
    if Trim(edtuser.Text) = '' then
      edtuser.SetFocus
    else
      edtpass.SetFocus;
    Exit;
  end;

  Intento := VerificarCredenciales(UDM.Conn, edtuser.Text, edtpass.Text);
  case Intento.Estado of
    eaAceptado:
      begin
        FResultado := Intento;
        GuardarUltimoUsuario(PathTemp + ARCHIVO_ULTIMO_USUARIO, Intento.Usuario);
        ModalResult := mrOk;
      end;
    eaErrorBD:
      begin
        MostrarMensaje(Intento.Mensaje);
        RegistrarFallo('Error de base de datos: ' + Intento.Detalle);
      end;
  else
    // Credenciales invalidas o usuario deshabilitado: se limpia solo la clave.
    edtpass.Text := '';
    MostrarMensaje(Intento.Mensaje);
    edtpass.SetFocus;
    if Intento.Estado = eaDeshabilitado then
      RegistrarFallo('Usuario deshabilitado.')
    else
      RegistrarFallo('Usuario o clave incorrectos.');
  end;
end;

{ Al escribir en cualquier campo desaparece el mensaje de error anterior. }
procedure TfrmAutentica.CampoCambio(Sender: TObject);
begin
  MostrarMensaje('');
end;

{ Alterna entre mostrar y ocultar la clave mientras se escribe. }
procedure TfrmAutentica.chkMostrarClaveClick(Sender: TObject);
begin
  if chkMostrarClave.Checked then
    edtpass.PasswordChar := #0
  else
    edtpass.PasswordChar := '*';
end;

procedure TfrmAutentica.FormShow(Sender: TObject);
begin
  MostrarMensaje('');
  edtuser.Text := LeerUltimoUsuario(PathTemp + ARCHIVO_ULTIMO_USUARIO);
  if edtuser.Text = '' then
    ActiveControl := edtuser
  else
    ActiveControl := edtpass;
end;

function TfrmAutentica.FormHelp(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
begin
  HelpFile := ExtractFilePath(Application.ExeName) + 'ArchiGenio.chm';
  Result := False;
end;

procedure TfrmAutentica.btnHelpClick(Sender: TObject);
begin
  Application.HelpContext(TEMA_AYUDA_LOGIN);
end;

procedure TfrmAutentica.edtuserKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_F1 then
    Application.HelpContext(TEMA_AYUDA_LOGIN);
end;

end.
