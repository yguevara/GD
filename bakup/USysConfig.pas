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
  JvExtComponent, JvCaptionPanel, cxButtonEdit, cxClasses, Vcl.AppEvnts,
  shellapi, dxBarBuiltInMenu, cxPC, Vcl.Buttons, StrUtils, cxLabel;

type
  TfrmSysConfig = class(TForm)
    pMainContainer: TPanel;
    btnClose: TJvTransparentButton;
    btnChangeLicencia: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    Edit1: TEdit;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid2build: TcxDBEditorRow;
    cxDBVerticalGrid2fecha: TcxDBEditorRow;
    cxDBVerticalGrid2carpetabd: TcxDBEditorRow;
    cxDBVerticalGrid2ipservidorbd: TcxDBEditorRow;
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
    OpenDialog1: TOpenDialog;
    jvcpViewLogo: TJvCaptionPanel;
    Panel1: TPanel;
    JvTransparentButton4: TJvTransparentButton;
    Edit2: TEdit;
    Image1: TImage;
    btnFileClean: TJvTransparentButton;
    btnLoadlogo: TJvTransparentButton;
    cxDBVerticalGrid2empresa: TcxDBEditorRow;
    pContainer: TPanel;
    btnAceptConfig: TJvTransparentButton;
    btnCancelConfig: TJvTransparentButton;
    ApplicationEvents1: TApplicationEvents;
    cxPageControl1: TcxPageControl;
    tsBasica: TcxTabSheet;
    tsProfesional: TcxTabSheet;
    cbServer: TComboBox;
    edt1: TEdit;
    OpenDialog2: TOpenDialog;
    btnFindInforme: TSpeedButton;
    lbl1: TLabel;
    cbDB: TComboBox;
    cxLabel1: TcxLabel;
    cxLabel2: TcxLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure JvTransparentButton2Click(Sender: TObject);
    procedure cxDBVerticalGrid2direccionEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnChangeLicenciaClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cxDBVerticalGrid2carpetabdEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxDBVerticalGrid2StylesGetContentStyle(Sender: TObject; AEditProp: TcxCustomEditorRowProperties; AFocused: Boolean; ARecordIndex: Integer; var AStyle: TcxStyle);
    procedure cxDBVerticalGrid2logoEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure JvTransparentButton4Click(Sender: TObject);
    procedure btnFileCleanClick(Sender: TObject);
    procedure btnLoadlogoClick(Sender: TObject);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cxDBVerticalGrid2empresaEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormActivate(Sender: TObject);
    procedure btnAceptConfigClick(Sender: TObject);
    procedure btnCancelConfigClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function ApplicationEvents1Help(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbServerKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnFindInformeClick(Sender: TObject);
    procedure cbServerExit(Sender: TObject);
  private
    procedure AgregaVersion(id: Integer; NombreVersion: string);
    { Private declarations }
  public
    { Public declarations }

    Configurado: Boolean;
    function MD5String(str: string): string;
    function GenUniqueValue: string;
    procedure CloseHelpWnd;
  end;

var
 // frmSysConfig: TfrmSysConfig;
  VERSION: string;
  HardWareID: string;
  BDActiva: Boolean;
  Config: Boolean;

function Configurasys(Conf: boolean): boolean;

implementation

uses
  UCapaDatos, UVeditor, UREditor;

{$R *.dfm}

function Configurasys(Conf: boolean): boolean;
var
  ListServer: TStringList;
  i: Integer;
  PathBD: string;
begin
//
//  VERSION := 'BÁSICA';
  VERSION := 'PROFESIONAL';
  Config := Conf;
  if not Conf then
  begin
    with TfrmSysConfig.Create(nil) do
    try
      cxDBVerticalGrid2.Align := alClient;
      cxDBVerticalGrid2.Visible := True;
      pContainer.Visible := False;
      BDActiva := True;
      Constraints.MinHeight := 450;
      Constraints.MaxHeight := 450;
      Constraints.MinWidth := 520;
      Constraints.MaxWidth := 520;
      ShowModal;
    finally
      Free;
    end;
  end
  else
  begin
    with TfrmSysConfig.Create(nil) do
    try
      Configurado := FAlse;
      cxDBVerticalGrid2.Visible := False;
      btnClose.Visible := False;
      pContainer.Visible := True;
      pContainer.Align := alTop;
      btnAceptConfig.Visible := True;
      btnCancelConfig.Visible := True;
      if VERSION = 'BÁSICA' then
      begin
        Constraints.MinHeight := 180;
        Constraints.MaxHeight := 180;
      end
      else
      begin
        Constraints.MinHeight := 250;
        Constraints.MaxHeight := 250;
      end;
      Constraints.MinWidth := 540;
      Constraints.MaxWidth := 540;
      tsBasica.TabVisible := True;
      tsProfesional.TabVisible := True;
      if VERSION = 'BÁSICA' then
      begin
        cxPageControl1.ActivePageIndex := 0;
        tsProfesional.TabVisible := False;
      end
      else
      begin
        cxPageControl1.ActivePageIndex := 1;
        tsBasica.TabVisible := False;
      end;

//      UDM.ListAvailableSQLServers(cbServer.Items);
      ShowModal;
      Result := config
    finally

      Free;
    end;
  end;

end;

function TfrmSysConfig.ApplicationEvents1Help(Command: Word; Data: NativeInt; var CallHelp: Boolean): Boolean;
begin
  CloseHelpWnd;
  Result := ShellExecute(0, 'open', 'hh.exe', PWideChar('-mapid ' + IntToStr(Data) + ' ms-its:' + ExtractFilePath(Application.ExeName) + 'ArchiGenioPro.chm'), nil, SW_SHOW) = 32;
  CallHelp := false;
end;

procedure TfrmSysConfig.btnAceptConfigClick(Sender: TObject);
var
  List: TStringList;
  TestConn: TFDConnection;
  ErrorMsg: string;

  function IsDatabaseValid(DatabaseType: string): Boolean;
  var
    FDQuery: TFDQuery;
    TableCheckSQL, FieldCheckSQL: string;
  begin
    Result := False;
    try
      FDQuery := TFDQuery.Create(nil);
      try
        FDQuery.Connection := TestConn;
        TestConn.Open;

      // Determinar la consulta según el tipo de base de datos
        if UpperCase(DatabaseType) = 'S' then
        begin
          TableCheckSQL := 'SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '+QuotedStr('tb_sysconfig');
          FieldCheckSQL := 'SELECT COUNT(*) FROM tb_sysconfig WHERE SistemaIdentificador = '+QuotedStr('GD_Valid_2025');
        end
        else if UpperCase(DatabaseType) = 'A' then
        begin
          TableCheckSQL := 'SELECT COUNT(*) FROM MSysObjects WHERE Name = '+QuotedStr('tb_sysconfig')+' AND Type = 1';
          FieldCheckSQL := 'SELECT COUNT(*) FROM tb_sysconfig WHERE SistemaIdentificador = '+QuotedStr('GD_Valid_2025');
        end
        else
          raise Exception.Create('Tipo de base de datos no soportado');

      // Paso 1: Verificar si la tabla tb_sysconfig existe
        FDQuery.SQL.Text := TableCheckSQL;
        FDQuery.Open;
        if FDQuery.Fields[0].AsInteger = 0 then
          Exit;

      // Paso 2: Verificar si el campo SistemaIdentificador tiene el valor único
        FDQuery.SQL.Text := FieldCheckSQL;
        FDQuery.Open;
        Result := FDQuery.Fields[0].AsInteger > 0;
      finally
        FDQuery.Free;
      end;
    except
      on E: Exception do
      begin
        ShowMessage('Error al validar la base de datos: ' + E.Message);
        Result := False;
      end;
    end;
  end;

  function EsPathAccessValido(const APath: string): Boolean;
  var
    Ext: string;
  begin
    Result := False;

  // Verificar si la cadena no está vacía
    if Trim(APath) = '' then
      Exit;

  // Verificar si el archivo existe
    if not FileExists(APath) then
      Exit;

  // Extraer la extensión y comparar
    Ext := LowerCase(ExtractFileExt(APath));
    if (Ext = '.mdb') or (Ext = '.accdb') then
      Result := True;
  end;

begin
  PathSys := ExtractFilePath(Application.ExeName);
  if VERSION = 'BÁSICA' then
  begin
    if not EsPathAccessValido(edt1.Text) then
    begin
      MessageDlg('Debe seleccionar una base de datos de Access válida (.mdb o .accdb). Asegúrese de que el archivo exista y tenga permisos de acceso', mterror, [mbOK], 0);
      Exit;
    end;
    TestConn := TFDConnection.Create(nil);
    with TestConn do
    begin
      Connected := False;
      with Params do
      begin
        Clear;
        Add('Database=' + OpenDialog2.FileName);
        Add('DriverID=MSAcc');
      end;
      try
        Connected := True;
      except
        on E: EFDException do
        begin
          UDM.sms('No se pudo establecer la conexión con la base de datos especificada. Motivo: ' + E.Message, 1);
        end;
      end;
    end;
    if IsDatabaseValid('A') then
    begin
      Configurado := True;
      with TStringList.Create do
      try
        Add('A');
        Add(OpenDialog2.FileName);
        SaveToFile(ExtractFilePath(application.ExeName) + 'config.ini');
        UDM.sms('✔ Los ajustes de conexión fueron guardados. Ahora puede iniciar sesión o comenzar a usar la aplicación.', 3);
        Close;
      finally
        Free;
      end;
      Close;
      Exit;
    end
    else
    begin
      UDM.sms('❌ Error: No se puede usar la configuración.' + #13#10 +
      'Motivo: ' + ErrorMsg + #13#10 +
      'Es probable que haya seleccionado una base de datos incorrecta.' + #13#10 +
      'Por favor, revise la selección de la base de datos e inténtelo de nuevo.', 1);
      UDM.sms('No se pudo validar la base de datos. Asegúrese de usar un archivo .mdb o .accdb válido.', 3);
      edt1.Focused;
      edt1.SetFocus;
    end;
  end
  else
  begin
    if trim(cbServer.Text) = '' then
    begin
      Application.MessageBox(PChar('❌ Error: No se ha especificado un servidor de bases de datos.' + #13#10 +
            'Motivo: El campo de servidor está vacío o contiene un valor no válido.' + #13#10 +
            'Sugerencia: Ingrese un nombre de servidor válido (por ejemplo: SERVIDOR\SQLEXPRESS).'), PChar('¡Error!'), MB_OK + MB_ICONERROR + MB_DEFBUTTON1 + MB_APPLMODAL + MB_SYSTEMMODAL);
      exit;
    end;
    if trim(cbDB.Text) = '' then
    begin
      Application.MessageBox(PChar('❌ Error: No se ha seleccionado una base de datos.' + #13#10 +
            'Motivo: No se especificó una base de datos de SQL Server.' + #13#10 +
            'Sugerencia: Seleccione una base de datos válida e inténtelo nuevamente.'), PChar('¡Error!'), MB_OK + MB_ICONERROR + MB_DEFBUTTON1 + MB_APPLMODAL + MB_SYSTEMMODAL);
      exit;
    end;
    TestConn := TFDConnection.Create(nil);
    with TestConn do
    begin
      Connected := False;
      with Params do
      begin
        Clear;
        Add('Database=' + cbDB.Text);
        Add('User_Name=geoconn');
        Add('Password=geoconn');
        Add('Server=' + cbServer.Text);
        Add('DriverID=MSSQL');
      end;
      try
        Connected := True;
      except
        on E: EFDException do
        begin
          UDM.sms('No se pudo establecer la conexión con la base de datos especificada. Motivo: ' + E.Message, 1);
        end;
      end;
    end;
    if IsDatabaseValid('S') then
    begin
      Configurado := True;
      with TStringList.Create do
      try
        Add('S');
        Add(cbServer.Text);
        Add(cbDB.Text);
      finally
        SaveToFile(ExtractFilePath(Application.ExeName) + 'config.ini');
        Free;
      end;
      Close;
      UDM.sms('✔ Los ajustes de conexión fueron guardados. Ahora puede iniciar sesión o comenzar a usar la aplicación.', 3);
      Close;
    end
    else
    begin
      UDM.sms('❌ Error: No se puede usar la configuración.' + #13#10 +
            'Motivo: ' + ErrorMsg + #13#10 +
            'Es probable que haya seleccionado una base de datos incorrecta.' + #13#10 +
            'Por favor, revise la selección de la base de datos e inténtelo de nuevo.', 1);
      cbDB.Focused;
      cbDB.SetFocus;
    end;
  end;
  List.Free;
  TestConn.Free;
end;

procedure TfrmSysConfig.btnCancelConfigClick(Sender: TObject);
begin
  Configurado := True;
  Close;
end;

procedure TfrmSysConfig.btnChangeLicenciaClick(Sender: TObject);
begin
  jvcpSSDetail.Visible := True;
end;

procedure TfrmSysConfig.btnFileCleanClick(Sender: TObject);
begin
  UDM.tb_sysconfig.edit;
  UDM.tb_sysconfig.FieldByName('logo').Value := Null;
  try
    UDM.tb_sysconfig.Post;
    Image1.Picture.Assign(nil);
    UDM.sms('El logo fue eliminado satisfactoriamente.', 3);
  except
    on E: EFDException do
    begin
      UDM.tb_sysconfig.Cancel;
      UDM.sms('No se pudo eliminar el contenido del logo. Motivo: ' + E.Message, 1);
      Exit;
    end;
  end;
end;

procedure TfrmSysConfig.btnFindInformeClick(Sender: TObject);
begin
  if OpenDialog2.Execute then
    if trim(OpenDialog2.FileName) <> '' then
    begin
      edt1.Text := OpenDialog2.FileName;
    end;

end;

procedure TfrmSysConfig.btnLoadlogoClick(Sender: TObject);
var
  stream: TMemoryStream;
begin
  if OpenDialog1.Execute then
    if Trim(OpenDialog1.FileName) <> '' then
    begin
      if (UDM.dstb_sysconfig.DataSet.State <> dsInsert) and (UDM.dstb_sysconfig.DataSet.State <> dsEdit) then
        UDM.dstb_sysconfig.DataSet.Edit;
      TBlobField(UDM.dstb_sysconfig.DataSet.FieldByName('logo')).LoadFromFile(OpenDialog1.FileName);
      try
        UDM.dstb_sysconfig.DataSet.Post;
        Image1.Picture.LoadFromFile(OpenDialog1.FileName);
      except
        on E: EFDException do
        begin
          UDM.dstb_sysconfig.DataSet.Cancel;
        end;
      end;
    end;

end;

procedure TfrmSysConfig.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  if not Config then
    TopicID := 25
  else
    TopicID := 44;
  Application.HelpContext(TopicID);
end;

procedure TfrmSysConfig.cbServerExit(Sender: TObject);
begin
  if cbServer.Text <> '' then
  begin
    cbDB.Items.Clear;
    UDM.DataBasesOnServer(cbDB.Items, cbServer.Text);
  end;
end;

procedure TfrmSysConfig.cbServerKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 13 then
  begin
    btnAceptConfigClick(Sender);
  end;
end;

procedure TfrmSysConfig.CloseHelpWnd;
var
  HlpWind: HWND;
const
  HelpTitle = 'EMSERGO SGD';
begin
  HlpWind := FindWindow('HH Parent', HelpTitle);
  if HlpWind <> 0 then
    PostMessage(HlpWind, WM_Close, 0, 0);
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

procedure TfrmSysConfig.cxDBVerticalGrid2empresaEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  CampoTexto(@UDM.dstb_sysconfig, 'empresa', 'Nombre de la Empresa.')
end;

procedure TfrmSysConfig.cxDBVerticalGrid2logoEditPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  Stream: TMemoryStream;
begin
  if (Trim(UDM.dstb_sysconfig.DataSet.FieldByName('logo').AsString) = '') or (UDM.dstb_sysconfig.DataSet.FieldByName('logo').Value = null) then
  begin
    if OpenDialog1.Execute then
      if Trim(OpenDialog1.FileName) <> '' then
      begin
        if (UDM.dstb_sysconfig.DataSet.State <> dsInsert) and (UDM.dstb_sysconfig.DataSet.State <> dsEdit) then
          UDM.dstb_sysconfig.DataSet.Edit;
        TBlobField(UDM.dstb_sysconfig.DataSet.FieldByName('logo')).LoadFromFile(OpenDialog1.FileName);
        UDM.dstb_sysconfig.DataSet.Post;
      end;

  end
  else
  begin
    jvcpViewLogo.Visible := True;
    Stream := TMemoryStream.Create;
    TBlobField(UDM.dstb_sysconfig.DataSet.FieldByName('logo')).SaveToStream(Stream);
    Stream.Seek(0, soFromBeginning);
    Image1.Picture.LoadFromStream(Stream);
  end;
end;

procedure TfrmSysConfig.cxDBVerticalGrid2StylesGetContentStyle(Sender: TObject; AEditProp: TcxCustomEditorRowProperties; AFocused: Boolean; ARecordIndex: Integer; var AStyle: TcxStyle);
begin
//  AStyle:=UDM.cxStyle416
end;

procedure TfrmSysConfig.FormActivate(Sender: TObject);
begin
  BringToFront;
  if not Configurado then
    Close;
end;

procedure TfrmSysConfig.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if UDM <> NIL then
    if not Configurado then
      if (UDM.tb_sysconfig.State = dsInsert) or (UDM.tb_sysconfig.State = dsEdit) then
        UDM.tb_sysconfig.Post;
end;

procedure TfrmSysConfig.FormCreate(Sender: TObject);

  procedure configuraDS;
  begin
    if UDM.tb_sysconfig.RecordCount = 0 then
    begin
      UDM.tb_sysconfig.Append;
      UDM.tb_sysconfig.FieldByName('idproducto').AsString := '07923';
      UDM.tb_sysconfig.FieldByName('build').AsString := buildprogram;
      UDM.tb_sysconfig.FieldByName('fecha').AsString := DateTimeToStr(Now);
      UDM.tb_sysconfig.FieldByName('version').AsString := VERSION;
      UDM.tb_sysconfig.FieldByName('numeroserie').AsString := '3541';
      UDM.tb_sysconfig.Post;
    end
    else
    begin
      UDM.tb_sysconfig.edit;
      UDM.tb_sysconfig.FieldByName('idproducto').AsString := '07923';
      UDM.tb_sysconfig.FieldByName('build').AsString := buildprogram;
      UDM.tb_sysconfig.FieldByName('fecha').AsString := DateTimeToStr(Now);
      UDM.tb_sysconfig.FieldByName('version').AsString := VERSION;
      UDM.tb_sysconfig.FieldByName('numeroserie').AsString := '3541';
      UDM.tb_sysconfig.Post;
    end;
  end;

  procedure ActualizaConfig(aVER: string);
  var
    List: TStringList;
  begin
    if trim(ansilowercase(aVER)) = 'profesional' then
    begin
      List := TStringList.Create;
      List.LoadFromFile(PathSys + 'config.ini');
      UDM.tb_sysconfig.Edit;
      UDM.tb_sysconfig.FieldByName('ipservidorbd').AsString := List[1];
      try
        UDM.tb_sysconfig.Post;
      except
        on E: Exception do
          UDM.tb_sysconfig.Cancel;
      end;
      List.Free;
    end
    else
    begin
      UDM.tb_sysconfig.Edit;
      UDM.tb_sysconfig.FieldByName('ipservidorbd').AsString := '';
      try
        UDM.tb_sysconfig.Post;
      except
        on E: Exception do
          UDM.tb_sysconfig.Cancel;
      end;
    end;
  end;

  procedure ConfiguraIntergfase;
  begin
    cxDBVerticalGrid2.DataController.DataSource := UDM.dstb_sysconfig;
    if trim(ansilowercase(UDM.tb_sysconfig.FieldByName('version').AsString)) = 'profesional' then
    begin
      cxDBVerticalGrid2ipservidorbd.Visible := True;
      cxDBVerticalGrid2carpetabd.Visible := False;
      cxDBVerticalGrid2CategoryRow3.Visible := True;
      cxDBVerticalGrid2ipservidorbd.Properties.Options.Editing := True;
      cxDBVerticalGrid2ipservidorbd.Styles.Content.Color := clInfoBk;
      cxDBVerticalGrid2carpetabd.Styles.Content.Color := $00F7EAD9;
      cxDBVerticalGrid2carpetabd.Properties.Options.Editing := False;
    end
    else if trim(ansilowercase(UDM.tb_sysconfig.FieldByName('version').AsString)) = 'básica' then
    begin
      cxDBVerticalGrid2ipservidorbd.Visible := True;
      cxDBVerticalGrid2ipservidorbd.Visible := False;
      cxDBVerticalGrid2carpetabd.Visible := False;
      cxDBVerticalGrid2CategoryRow3.Visible := False;
    end;
  end;

begin
  if not Config then
  begin
    configuraDS;
    ConfiguraIntergfase;
    ActualizaConfig(VERSION);
  end;
end;

procedure TfrmSysConfig.FormDestroy(Sender: TObject);
begin
  CloseHelpWnd;
end;

procedure TfrmSysConfig.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
  if Key = 112 then
  begin
    TopicID := 25;
    HelpFile := ExtractFilePath(Application.ExeName) + 'ArchiGenioPro.chm';
    Application.HelpSystem.ShowContextHelp(TopicID, HelpFile);
  end;

end;

procedure TfrmSysConfig.FormShow(Sender: TObject);
begin
  BringToFront;
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

procedure TfrmSysConfig.btnCloseClick(Sender: TObject);
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

procedure TfrmSysConfig.JvTransparentButton4Click(Sender: TObject);
begin
  jvcpViewLogo.Visible := False;
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

