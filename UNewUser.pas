unit UNewUser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.DBCtrls, Vcl.ExtCtrls, System.UITypes, Vcl.ComCtrls,
  JvExComCtrls, JvDateTimePicker, Data.DB, Data.Win.ADODB, FireDAC.Stan.Error,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxContainer,
  cxEdit, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinTheBezier,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, cxTextEdit, cxMaskEdit, cxDropDownEdit,
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox;

type
  TfrmNewUser = class(TForm)
    lblNameUser: TLabel;
    edtUser: TEdit;
    edtCompleteName: TEdit;
    Label1: TLabel;
    cbEnable: TComboBox;
    Label2: TLabel;
    lblPass: TLabel;
    edtpass: TEdit;
    Panel2: TPanel;
    edtconfirmpass: TEdit;
    Label3: TLabel;
    Panel3: TPanel;
    lblGrupo: TLabel;
    Panel4: TPanel;
    btnClose: TButton;
    btnCreateUser: TButton;
    btnHelp: TButton;
    Label5: TLabel;
    Label6: TLabel;
    edtEmpresa: TEdit;
    edtMinisterio: TEdit;
    lcbrol: TDBLookupComboBox;
    procedure btnCloseClick(Sender: TObject);
    procedure btnCreateUserClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmNewUser: TfrmNewUser;

implementation

{$R *.dfm}

uses
  md5, UCapaDatos;

procedure TfrmNewUser.btnCloseClick(Sender: TObject);
begin
  if (UDM.Tb_User.State <> dsInsert) or (UDM.Tb_User.State <> dsEdit) then
    UDM.Tb_User.Cancel;
  Close;
end;

procedure TfrmNewUser.btnCreateUserClick(Sender: TObject);

  function GetLastId: Integer;
  var
    V: Variant;
  begin
      V := UDM.Conn.ExecSQLScalar('SELECT Max(des_registrador.codregistrador) FROM des_registrador');
    result := StrToInt(VarToStr(V)) + 1;
  end;

begin
  if (LowerCase(edtUser.Text) = 'administrador') or (LowerCase(edtUser.Text) = 'administrator') then
  begin
    MessageDlg('El nombre de usuario especificado está restringido por el sistema.', mtError, [mbOK], 0);
    Exit;
  end;
  if (edtUser.Text = '') or (Length(edtUser.Text) <= 3) or (edtUser.Text = ' ') or (Length(edtpass.Text) <= 6) then
  begin
    MessageDlg('Por favor debe verificar lo siguiente:' + #13 + '1- No se especificó el "Usuario".' + #13 + '2- La longitud del nombre especificado debe ser de al menos tres caracteres.' + #13 + '3- El nombre de usuario está formado por caracteres no admitidos.' + #13 + '4- La longitud de la contraseña debe ser mayor de seis caracteres.' + #13, mtError, [mbOK], 0);
    edtUser.SetFocus;
    edtUser.Focused;
    Exit;
  end;
  if edtpass.Text = edtconfirmpass.Text then
  begin
    if (UDM.Tb_User.State <> dsInsert) or (UDM.Tb_User.State <> dsEdit) then
      UDM.Tb_User.Append;
    with UDM.Tb_User do
    begin
      FieldByName('NombreUser').AsString := AnsiLowerCase(trim(edtUser.Text));
      FieldByName('NombreLUser').AsString := edtCompleteName.Text;
      FieldByName('Pass').AsString := MD5Print(MD5String(edtpass.Text));
      FieldByName('Empresa').AsString := edtEmpresa.Text;
      FieldByName('Ministerio').AsString := edtMinisterio.Text;
      FieldByName('Habilitado').AsString := cbEnable.Text;
      FieldByName('Rol').AsInteger := lcbrol.KeyValue;
      try
        Post;
        edtUser.Text := '';
        edtCompleteName.Text := '';
        edtpass.Text := '';
        edtconfirmpass.Text := '';
        cbEnable.Text := '';
        lcbrol.KeyValue := Null;
        edtEmpresa.Text := '';
        edtMinisterio.Text := '';
        MessageDlg('¡El usuario se ha creado satisfactoriamente!', mtInformation, [mbOK], 0);
        Append;
      except
        on E: EDatabaseError do
        begin
          MessageDlg('No se pudo agregar el usuario especificado.' + #13 + '1- Verifique que el usuario no exista.' + #13 + '2- Verifique que el nombre de usuario no contenga caráteres especiales.' + #13 + 'Motivo: ' + e.Message, mtError, [mbOK], 0);
          Exit;
        end;
      end;
    end;
  end;
end;

procedure TfrmNewUser.btnHelpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmNewUser.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (UDM.Tb_User.State <> dsInsert) or (UDM.Tb_User.State <> dsEdit) then
    UDM.Tb_User.Cancel;
  CanClose := True;
end;

procedure TfrmNewUser.FormCreate(Sender: TObject);
begin
  lcbrol.ListSource := UDM.DSTb_Rol;
  lcbrol.ListField := 'Rol';
  lcbrol.KeyField := 'IdRol';

end;

end.

