unit UUserProperties;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, Vcl.ExtCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
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
  cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, Vcl.ComCtrls, Vcl.ToolWin,
  JvExControls, JvButton, JvTransparentButton;

type
  TfrmProperties = class(TForm)
    Panel4: TPanel;
    lblGrupo: TLabel;
    Panel2: TPanel;
    cbEnable: TComboBox;
    Label2: TLabel;
    Label6: TLabel;
    edtMinisterio: TDBEdit;
    Label5: TLabel;
    Label1: TLabel;
    lblNameUser: TLabel;
    edtUser: TDBEdit;
    edtUserL: TDBEdit;
    edtEmpresa: TDBEdit;
    lcbrol: TDBLookupComboBox;
    StatusBar1: TStatusBar;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnusercontrol: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    JvTransparentButton2: TJvTransparentButton;
    procedure btnCreateUserClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmProperties: TfrmProperties;
  Rol: string;

implementation

uses
  UCapaDatos, UChangePass;

{$R *.dfm}

procedure TfrmProperties.btnCloseClick(Sender: TObject);
begin
  if (UDM.cl_Resp_Gest_Arch.State=dsInsert)or(UDM.cl_Resp_Gest_Arch.State=dsEdit) then
  try
    UDM.cl_Resp_Gest_Arch.Cancel;
  except
    on E: EFDException do
    begin
      MessageDlg('No se pudieron realizar los cambios solicitados.' + E.Message, mtError, [mbOK], 0);
    end;
  end;
  Close;
end;

procedure TfrmProperties.btnCreateUserClick(Sender: TObject);
var
  bm: TBookmark;
begin
  bm := UDM.cl_Resp_Gest_Arch.GetBookmark;
  if (UDM.cl_Resp_Gest_Arch.State <> dsedit) and (UDM.cl_Resp_Gest_Arch.State <> dsinsert) then
    UDM.cl_Resp_Gest_Arch.Edit;
  if trim(cbEnable.Text) <> '' then
    UDM.cl_Resp_Gest_Arch.FieldByName('habilitado').AsString := cbEnable.Text;
  try
    UDM.cl_Resp_Gest_Arch.Post;
    UDM.cl_Resp_Gest_Arch.GotoBookmark(bm);
  except
    on E: EDatabaseError do
    begin
      MessageDlg('No se pudieron realizar los cambios solicitados.' + E.Message, mtError, [mbOK], 0);
      Exit;
    end;
  end;

end;

procedure TfrmProperties.Button1Click(Sender: TObject);
begin
  with TfrmChangePass.Create(nil) do
  try
    Caption := 'Establecer contraseña para el ususario ' + UDM.cl_Resp_Gest_Arch.FieldByName('usuario').AsString;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmProperties.FormActivate(Sender: TObject);
begin
  edtUser.SetFocus;
  edtUser.Focused;
  cbEnable.Text := UDM.cl_Resp_Gest_Arch.FieldByName('habilitado').AsString;
end;

procedure TfrmProperties.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (UDM.cl_Resp_Gest_Arch.State = dsEdit) or (UDM.cl_Resp_Gest_Arch.State = dsInsert) then
    UDM.cl_Resp_Gest_Arch.Cancel;
end;

procedure TfrmProperties.FormCreate(Sender: TObject);
begin
  Rol := UDM.Tb_Rol.FieldByName('idrol').AsString;
  cbEnable.Text := UDM.cl_Resp_Gest_Arch.FieldByName('habilitado').AsString;
  edtUser.DataSource := UDM.dscl_Resp_Gest_Arch;
  edtUserL.DataSource := UDM.dscl_Resp_Gest_Arch;
  edtEmpresa.DataSource := UDM.dscl_Resp_Gest_Arch;
  edtMinisterio.DataSource := UDM.dscl_Resp_Gest_Arch;
  lcbrol.DataSource := UDM.dscl_Resp_Gest_Arch;
  lcbrol.ListSource := UDM.DSTb_Rol;
end;

end.

