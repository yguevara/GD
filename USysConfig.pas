unit USysConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, JvExControls, JvButton, JvTransparentButton, Vcl.ExtCtrls,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles,
  cxEdit, cxBlobEdit, cxImage, dxSkinsCore, dxSkinsDefaultPainters, cxVGrid,
  cxDBVGrid, cxInplaceContainer, cxTextEdit, IdGlobal, IdHash,
  IdHashMessageDigest, ADOInt, ActiveX, Winapi.OleDB, Data.DB, Data.Win.ADODB,
  ComObj, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, cxDBLookupComboBox, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.VCLUI.Wait, FireDAC.DApt, cxContainer, cxDropDownEdit, cxDBEdit,
  cxMaskEdit, cxLookupEdit, cxDBLookupEdit, AdvPanel, JvExExtCtrls,
  JvExtComponent, JvCaptionPanel, cxButtonEdit, cxClasses;

type
  TfrmSysConfig = class(TForm)
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnExcelExport: TJvTransparentButton;
    btnChangeLicencia: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    Edit1: TEdit;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid2build: TcxDBEditorRow;
    cxDBVerticalGrid2fecha: TcxDBEditorRow;
    cxDBVerticalGrid2carpetabd: TcxDBEditorRow;
    cxDBVerticalGrid2ipservidorbd: TcxDBEditorRow;
    cxDBVerticalGrid2usuariobd: TcxDBEditorRow;
    cxDBVerticalGrid2passbd: TcxDBEditorRow;
    cxDBVerticalGrid2empresa: TcxDBEditorRow;
    cxDBVerticalGrid2direccion: TcxDBEditorRow;
    cxDBVerticalGrid2logo: TcxDBEditorRow;
    cxDBVerticalGrid2directorempresacliente: TcxDBEditorRow;
    cxDBVerticalGrid2presidentecvdempresacliente: TcxDBEditorRow;
    cxDBVerticalGrid2HID: TcxDBEditorRow;
    cxDBVerticalGrid2numeroserie: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid2version: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow2: TcxCategoryRow;
    cxDBVerticalGrid2CategoryRow3: TcxCategoryRow;
    cxDBVerticalGrid2idproducto: TcxDBEditorRow;
    SysConn: TFDConnection;
    tb_version: TFDQuery;
    dstb_version: TDataSource;
    jvcpSSDetail: TJvCaptionPanel;
    AdvPanel13: TAdvPanel;
    Label5: TLabel;
    Label4: TLabel;
    cbbVersion: TcxDBLookupComboBox;
    edtCarpeta: TcxDBBlobEdit;
    Panel2: TPanel;
    JvTransparentButton2: TJvTransparentButton;
    Edit3: TEdit;
    cxDBVerticalGrid2licactiva: TcxDBEditorRow;
    dlgOpenOD: TOpenDialog;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    cxStyle4: TcxStyle;
    cxStyle5: TcxStyle;
    cxStyle6: TcxStyle;
    cxStyle7: TcxStyle;
    cxStyle8: TcxStyle;
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure JvTransparentButton2Click(Sender: TObject);
    procedure cxDBVerticalGrid2direccionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnChangeLicenciaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cxDBVerticalGrid2carpetabdEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxDBVerticalGrid2StylesGetContentStyle(Sender: TObject;
      AEditProp: TcxCustomEditorRowProperties; AFocused: Boolean;
      ARecordIndex: Integer; var AStyle: TcxStyle);
  private
    procedure AgregaVersion(id: Integer; NombreVersion: string);
    { Private declarations }
  public
    { Public declarations }
    function MD5String(str: string): string;
    function GenUniqueValue: string;
  end;

var
  frmSysConfig: TfrmSysConfig;
  HardWareID: string;

implementation

uses
  UCapaDatos, UVeditor;

{$R *.dfm}

procedure TfrmSysConfig.btnChangeLicenciaClick(Sender: TObject);
begin
  jvcpSSDetail.Visible := True;
end;

procedure TfrmSysConfig.cxDBVerticalGrid2carpetabdEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if dlgOpenOD.Execute then
  begin
    if dlgOpenOD.FileName <> '' then
    begin
      if (UDM.tb_sysconfig.State <> dsInsert) and (UDM.tb_sysconfig.State <> dsEdit) then
        UDM.tb_sysconfig.Edit;
      UDM.tb_sysconfig.FieldByName('carpetabd').AsString := dlgOpenOD.FileName;
      UDM.tb_sysconfig.Post;
      UDM.tb_sysconfig.Active := False;
      UDM.tb_sysconfig.Active := True;
    end;
  end;
end;

procedure TfrmSysConfig.cxDBVerticalGrid2direccionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  CampoTexto(@UDM.dstb_sysconfig, 'direccion', 'Dirección de la Empresa ' + UDM.dstb_sysconfig.DataSet.FieldByName('empresa').AsString);
end;

procedure TfrmSysConfig.cxDBVerticalGrid2StylesGetContentStyle(Sender: TObject;
  AEditProp: TcxCustomEditorRowProperties; AFocused: Boolean;
  ARecordIndex: Integer; var AStyle: TcxStyle);
begin
//  AStyle:=UDM.cxStyle416
end;

procedure TfrmSysConfig.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (UDM.tb_sysconfig.State = dsInsert) or (UDM.tb_sysconfig.State = dsEdit) then
  begin
    UDM.tb_sysconfig.Post;
    {if UDM.tb_sysconfig.ChangeCount > 0 then
      if UDM.sms('¿Desea salvar los cambios realizados?', 4) = 6 then
      begin
        UDM.tb_sysconfig.Post;
      end
      else
        UDM.tb_sysconfig.Cancel;}
  end;
end;

procedure TfrmSysConfig.FormCreate(Sender: TObject);
var
  ListServer: TStringList;
  i: Integer;
  PathBD: string;
begin
 { PathBD := PathSys + 'sysinfo.db';
  with SysConn do
  begin
    Connected := False;
    with Params do
    begin
      Clear;
      Add('Database=' + PathBD);
      Add('DriverID=SQLite');
    end;
    try
      Connected := True;
      tb_version.Open();
      tb_version.FetchAll;
      AgregaVersion(1, 'BÁSICA');
      AgregaVersion(2, 'PROFESIONAL');
      AgregaVersion(3, 'LLAVE EN MANO');
    except
      Exit;
    end;
  end;
  {if AnsiLowerCase(UDM.UserName) = 'administrador' then
  begin  }
  //tb_version.First;  cxDBVerticalGrid2empresa
  {cxDBVerticalGrid2direccion.Styles.Content.Color := clMaroon;
  cxDBVerticalGrid2logo.Styles.Content.Color := clMaroon;
  cxDBVerticalGrid2carpetabd.Styles.Content.Color := clMaroon;
  cxDBVerticalGrid2ipservidorbd.Styles.Content.Color := clMaroon;
  cxDBVerticalGrid2usuariobd.Styles.Content.Color := clMaroon;
  cxDBVerticalGrid2passbd.Styles.Content.Color := clMaroon;   }
  if UDM.tb_sysconfig.RecordCount = 0 then
  begin
    UDM.tb_sysconfig.Append;
    UDM.tb_sysconfig.FieldByName('idproducto').AsString := '20360'; //tb_version.Fields[2].AsString;
    UDM.tb_sysconfig.FieldByName('build').AsString := buildprogram;
    UDM.tb_sysconfig.FieldByName('fecha').AsString := DateTimeToStr(Now);
    UDM.tb_sysconfig.FieldByName('version').AsString := 'BÁSICA'; // tb_version.Fields[1].AsString;
    UDM.tb_sysconfig.FieldByName('numeroserie').AsString := '3540'; //tb_version.Fields[3].AsString;
    UDM.tb_sysconfig.Post;
  end
  else
  begin
    UDM.tb_sysconfig.edit;
    UDM.tb_sysconfig.FieldByName('idproducto').AsString := '20360'; //tb_version.Fields[2].AsString;
    UDM.tb_sysconfig.FieldByName('build').AsString := buildprogram;
    UDM.tb_sysconfig.FieldByName('fecha').AsString := DateTimeToStr(Now);
    UDM.tb_sysconfig.FieldByName('version').AsString := 'BÁSICA'; // tb_version.Fields[1].AsString;
    UDM.tb_sysconfig.FieldByName('numeroserie').AsString := '3540'; //tb_version.Fields[3].AsString;
    UDM.tb_sysconfig.Post;
  end;
  if trim(ansilowercase(UDM.tb_sysconfig.FieldByName('version').AsString)) = 'profesional' then
  begin
    cxDBVerticalGrid2ipservidorbd.Properties.Options.Editing := True;
    cxDBVerticalGrid2usuariobd.Properties.Options.Editing := True;
    cxDBVerticalGrid2passbd.Properties.Options.Editing := True;
    cxDBVerticalGrid2ipservidorbd.Styles.Content.Color:=clInfoBk;
    cxDBVerticalGrid2usuariobd.Styles.Content.Color:=clInfoBk;
    cxDBVerticalGrid2passbd.Styles.Content.Color:=clInfoBk;
    cxDBVerticalGrid2carpetabd.Styles.Content.Color := $00F7EAD9;
    cxDBVerticalGrid2carpetabd.Properties.Options.Editing := False;
    UDM.tb_sysconfig.Edit;
    UDM.tb_sysconfig.FieldByName('ipservidorbdcarpetabd').AsString:='';
    try
      UDM.tb_sysconfig.Post;
    except on E: Exception do
      UDM.tb_sysconfig.Cancel;
    end;
  end
  else if trim(ansilowercase(UDM.tb_sysconfig.FieldByName('version').AsString)) = 'básica' then
  begin
    cxDBVerticalGrid2ipservidorbd.Properties.Options.Editing := False;
    cxDBVerticalGrid2usuariobd.Properties.Options.Editing := False;
    cxDBVerticalGrid2passbd.Properties.Options.Editing := False;
    cxDBVerticalGrid2ipservidorbd.Styles.Content.Color:=$00F7EAD9;
    cxDBVerticalGrid2usuariobd.Styles.Content.Color:=$00F7EAD9;
    cxDBVerticalGrid2passbd.Styles.Content.Color:=$00F7EAD9;
    cxDBVerticalGrid2carpetabd.Styles.Content.Color := clInfoBk;
    cxDBVerticalGrid2carpetabd.Properties.Options.Editing := True;
    UDM.tb_sysconfig.Edit;
    UDM.tb_sysconfig.FieldByName('ipservidorbd').AsString:='';
    UDM.tb_sysconfig.FieldByName('usuariobd').AsString:='';
    UDM.tb_sysconfig.FieldByName('passbd').AsString:='';
    try
      UDM.tb_sysconfig.Post;
    except on E: Exception do
      UDM.tb_sysconfig.Cancel;
    end;
  end;
end;

function TfrmSysConfig.GenUniqueValue: string;
var
  s: string;
  g: TGuid;
begin
  CreateGuid(g);
  s := GuidToString(g);
  Delete(s, 1, 1);
  Delete(s, Length(s), 1);
  result := s;
end;

procedure TfrmSysConfig.JvTransparentButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmSysConfig.JvTransparentButton2Click(Sender: TObject);
var
  Lic: string;
begin
  if (UDM.tb_sysconfig.State = dsInsert) or (UDM.tb_sysconfig.State = dsEdit) then
  begin
    UDM.tb_sysconfig.Post;
    if tb_version.Locate('idversion', UDM.tb_sysconfig.FieldByName('licactiva').AsString, []) then
    begin
      UDM.tb_sysconfig.edit;
      UDM.tb_sysconfig.FieldByName('idproducto').AsString := tb_version.Fields[2].AsString;
      UDM.tb_sysconfig.FieldByName('build').AsString := buildprogram;
      UDM.tb_sysconfig.FieldByName('fecha').AsString := DateTimeToStr(Now);
      UDM.tb_sysconfig.FieldByName('version').AsString := tb_version.Fields[1].AsString;
      UDM.tb_sysconfig.FieldByName('numeroserie').AsString := tb_version.Fields[3].AsString;
      try
        UDM.tb_sysconfig.Post;
        UDM.sms('La licencia ha sido cambiada satisfactoriamente.', 3);
      except
        UDM.tb_sysconfig.Cancel;
      end;
    end;

  end;
  jvcpSSDetail.Visible := False;
end;

function TfrmSysConfig.MD5String(str: string): string;
begin
  with TIdHashMessageDigest5.Create do
  try
    Result := HashStringAsHex(str);
  finally
    Free;
  end;
end;

procedure TfrmSysConfig.AgregaVersion(id: Integer; NombreVersion: string);
begin
  tb_version.Append;
  tb_version.Fields[0].AsInteger := id;
  tb_version.Fields[1].AsString := NombreVersion;
  tb_version.Fields[2].AsString := GenUniqueValue;
  tb_version.Fields[3].AsString := GenUniqueValue;
  try
    tb_version.Post;
  except
    tb_version.Cancel;
  end;
end;

end.

