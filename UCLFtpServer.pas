unit UCLFtpServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, Data.DB, cxDBData, cxTextEdit,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, Vcl.ComCtrls,
  cxGridLevel, cxClasses, cxGridCustomView, cxGrid, Vcl.ToolWin, Vcl.DBCtrls,
  cxDBNavigator, Vcl.ExtCtrls, cxDropDownEdit, JvExControls, JvButton,
  JvTransparentButton, Vcl.StdCtrls, frxADOComponents, frxClass, frxGradient,
  frxRich, cxButtonEdit, JvBaseDlg, JvSelectDirectory, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, frxDBSet, cxCheckBox, IdFTP,
  IdTCPClient, IdException, UServidorS3Dialogo;

type
  TfrmListFTPServer = class(TForm)
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1Idservidor: TcxGridDBColumn;
    cxGrid1DBTableView1path: TcxGridDBColumn;
    cxGrid1DBTableView1user: TcxGridDBColumn;
    cxGrid1DBTableView1pass: TcxGridDBColumn;
    cxGrid1DBTableView1puerto: TcxGridDBColumn;
    cxGrid1DBTableView1ipserver: TcxGridDBColumn;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    cxGrid1DBTableView1etiquetaServ: TcxGridDBColumn;
    dscl_ftp_Server: TDataSource;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnExcelExport: TJvTransparentButton;
    btnExpand: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnBestFitSS: TJvTransparentButton;
    btnExportSSExcel: TJvTransparentButton;
    Edit1: TEdit;
    btnPrint: TJvTransparentButton;
    frxMain: TfrxReport;
    SD: TJvSelectDirectory;
    frxtb_sysconfig: TfrxDBDataset;
    btnTestConn: TJvTransparentButton;
    cxGrid1DBTableView1test: TcxGridDBColumn;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure ToolButton2Click(Sender: TObject);
    procedure btnExpandClick(Sender: TObject);
    procedure btnExcelExportClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure cxGrid1DBTableView1pathPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnTestConnClick(Sender: TObject);
    procedure BotonS3Click(Sender: TObject);
  private
    FBotonS3: TButton;
    { Private declarations }
  public
    { Public declarations }
    procedure CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
    procedure InsertConnection(report: TfrxReport; connection: string);
    function CheckFTPConnection(const Host, Username, Password: string; Puerto: integer): Boolean;
    function ValidaDatos: boolean;
  end;

var
  frmListFTPServer: TfrmListFTPServer;

implementation

uses
  UCapaDatos, UExcelExport, USystemMsg;

{$R *.dfm}

procedure TfrmListFTPServer.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmListFTPServer.btnExcelExportClick(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TfrmListFTPServer.btnExpandClick(Sender: TObject);
begin
  try
    cxGrid1DBTableView1.ApplyBestFit();
    UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'cl_servidoresFTP');
  except
  end;
end;

procedure TfrmListFTPServer.btnhlpClick(Sender: TObject);
{var
  i:integer;
  cad:string;
  list:TStringList;
begin
  list:=TStringList.Create;
  cxGrid1DBTableView1.ApplyBestFit();
  for i := 0 to cxGrid1DBTableView1.ColumnCount-1 do begin
    cad:=IntToStr(cxGrid1DBTableView1.Columns[i].Width);
    list.Add(cad);
  end;
  list.SaveToFile('C:\Temp\largocol.txt');
  ShowMessage('YAAAAA!!!!');
end;}
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmListFTPServer.btnPrintClick(Sender: TObject);

  function TamFichero(n: string): longint;
  var
    f: file of Byte;
  begin
    result := 0;
    AssignFile(f, n);
    Reset(f);
    result := FileSize(f);
    CloseFile(f);
  end;

begin
  UDM.MostrarReporte('ListFTP');
{   //esta validacion la puse aqui pero puede ser en otro lugar si deseas
  if ((UDM.tb_sysconfig.FieldByName('empresa').AsString <> '') and (not TBlobField(UDM.tb_sysconfig.FieldByName('logo')).IsNull)) then
  begin
     //salvar el logo que esta en la tabla de configuracion a la carpeta de reportes ,que ahora esta a nivel del mosulo
     //principal
    try
      TBlobField(UDM.tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
      if TamFichero(pathreport + 'logo.png') > 0 then
     //todos los parametros para cargar el reporte
        CargaReporte(frxMain, pathreport + 'rListFTP.fr3', 'empresa', UDM.tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png')
      else
        UDM.sms('No se pudo cargar el logo de la empresa especificado. Por favor revise la configuración del sistema.', 1);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo cargar el logo de la empresa por favor revise la configuración del sistema. Motivo: ' + e.Message, 1);
      end;
    end;
  end
  else
  begin
    udm.sms('Debe configurar los Datos de la Empresa. Diríjase a la configuración del Sistema', 1);
  end; }
end;

procedure TfrmListFTPServer.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 18;
  Application.HelpContext(TopicID);
end;

procedure TfrmListFTPServer.btnTestConnClick(Sender: TObject);
var
  nombreoip: string;
begin
  if not ValidaDatos then
  begin
    UDM.sms('La prueba de conexión no se pudo completar. Se encontraron errores en la configuración suministrada.', 1);
    UDM.sms('Debe completar los datos referente al servidor.', 2);
    exit;
  end;
  nombreoip := UDM.cl_ftp_Server.FieldByName('ipserver').AsString;
  if trim(nombreoip) = '' then
    nombreoip := UDM.cl_ftp_Server.FieldByName('etiquetaServ').AsString;
  if trim(nombreoip) = '' then
  begin
    UDM.sms('La prueba de conexión no se pudo completar. Se encontraron errores en la configuración suministrada.', 1);
    UDM.sms('Especifique un nombre o ip válido para el servidor actual.', 2);
    Exit;
  end;
  if CheckFTPConnection(nombreoip, UDM.cl_ftp_Server.FieldByName('usuarioftp').AsString, UDM.cl_ftp_Server.FieldByName('pass').AsString, UDM.cl_ftp_Server.FieldByName('puerto').AsInteger) then
    UDM.sms('La prueba de conexión fue satisfactoria', 3)
  else
    UDM.sms('La prueba de conexión no se pudo completar.', 1);
end;

procedure TfrmListFTPServer.CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
var
  Component: TfrxComponent;
begin
  with report do
  begin
    LoadFromFile(pathreport);
    InsertConnection(report, PathBD);
    Component := FindObject(nameempresa);
    if Component is TfrxRichView then
      TfrxRichView(Component).DataSet := frxtb_sysconfig;
    TfrxRichView(Component).DataField := 'empresa';
    Component := FindObject(nameimagen);
    if Component is TfrxPictureView then
      TfrxPictureView(Component).Picture.LoadFromFile(pathimagen);
    PrepareReport();
    ShowReport();
  end;
end;

function TfrmListFTPServer.CheckFTPConnection(const Host, Username, Password: string; Puerto: integer): Boolean;
var
  FTPClient: TIdFTP;
begin
  FTPClient := TIdFTP.Create(nil);
  try
    FTPClient.Host := Host;
    FTPClient.Username := Username;
    FTPClient.Password := Password;
    FTPClient.Port := Puerto;
    try
      FTPClient.Connect;
      Result := True;
    except
      on E: EIdException do
      begin
        // Handle the exception if the connection attempt fails
        Result := False;
      end;
    end;
  finally
    FTPClient.Disconnect;
    FTPClient.Free;
  end;
end;

procedure TfrmListFTPServer.cxGrid1DBTableView1pathPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  if SD.Execute then
    if trim(SD.Directory) <> '' then
    begin
      if (UDM.cl_ftp_Server.State = dsinsert) or (UDM.cl_ftp_Server.State = dsedit) then
      begin
        UDM.cl_ftp_Server.FieldByName('path').AsString := SD.Directory;
        try
          UDM.cl_ftp_Server.Post;
        except
          on E: EFDException do
          begin
            UDM.cl_ftp_Server.Cancel;
            UDM.sms('No se pudo agregar la ruta especificada. Motivo: ' + e.Message, 1);
            exit;
          end;
        end;
      end
      else
      begin
        UDM.cl_ftp_Server.Edit;
        UDM.cl_ftp_Server.FieldByName('path').AsString := SD.Directory;
        try
          UDM.cl_ftp_Server.Post;
        except
          on E: EFDException do
          begin
            UDM.cl_ftp_Server.Cancel;
            UDM.sms('No se pudo agregar la ruta especificada. Motivo: ' + e.Message, 1);
            exit;
          end;
        end;
      end;

    end;

end;

procedure TfrmListFTPServer.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_ftp_Server.FieldByName('Idservidor').AsInteger := UDM.GetLastId('cl_ftp_Server', 'Idservidor');
  end;
end;

procedure TfrmListFTPServer.FormActivate(Sender: TObject);
begin
  UDM.RestauraGrid(cxGrid1DBTableView1, 'cl_servidoresFTP');
end;

procedure TfrmListFTPServer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'cl_servidoresFTP');
  try
    UDM.cl_ftp_Server.active := False;
    UDM.cl_ftp_Server.Active := True;
  except

  end
end;

procedure TfrmListFTPServer.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
  if Key = 112 then
  begin
    TopicID := 18;
    Application.HelpContext(TopicID);
  end;
end;

// Edita el servidor S3 seleccionado; si el seleccionado es FTP, crea uno nuevo
procedure TfrmListFTPServer.BotonS3Click(Sender: TObject);
var
  Id: Integer;
begin
  Id := 0;
  if UDM.cl_ftp_Server.Active and not UDM.cl_ftp_Server.IsEmpty and
    (UpperCase(Trim(UDM.cl_ftp_Server.FieldByName('tipo').AsString)) = 'S3') then
    Id := UDM.cl_ftp_Server.FieldByName('Idservidor').AsInteger;
  if EditarServidorS3(UDM.Conn, Id) then
  begin
    UDM.cl_ftp_Server.Refresh;
    if UDM.cmdServer.Active then
      UDM.cmdServer.Refresh;
  end;
end;

procedure TfrmListFTPServer.FormShow(Sender: TObject);
begin
  // Servidor S3 (MinIO): boton propio, sin tocar el .dfm de la rejilla
  if FBotonS3 = nil then
  begin
    FBotonS3 := TButton.Create(Self);
    FBotonS3.Parent := Panel6;
    FBotonS3.Align := alLeft;
    FBotonS3.Width := 190;
    FBotonS3.Caption := 'Servidor S3 (MinIO)...';
    FBotonS3.OnClick := BotonS3Click;
  end;
  Edit1.Focused;
  Edit1.SetFocus;
end;

procedure TfrmListFTPServer.InsertConnection(report: TfrxReport; connection: string);
var
  i: integer;
begin
  TfrxADODatabase(report.FindComponent('conn')).Connected := false;
  if TBD = 'A' then
    TfrxADODatabase(report.FindComponent('conn')).DatabaseName := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + connection + ';Persist Security Info=False'
  else
    TfrxADODatabase(report.FindComponent('conn')).DatabaseName := 'Provider=SQLOLEDB.1;Password=geoconn;Persist Security Info=True;User ID=geoconn;Initial Catalog=SDbd;Data Source=' + UDM.tb_sysconfig.FieldByName('ipservidorbd').AsString;
  TfrxADODatabase(report.FindComponent('conn')).Connected := True;
  for i := 0 to report.ComponentCount - 1 do
  begin
    if report.Components[i] is TfrxADOQuery then
    begin
      if TfrxADOQuery(report.Components[i]).Params.Count = 0 then
      begin
        TfrxADOQuery(report.Components[i]).Active := True;
      end;

    end;
  end
end;

procedure TfrmListFTPServer.ToolButton2Click(Sender: TObject);
begin
  if cxGrid1DBTableView1.DataController.DataSet.RecordCount > 0 then
    cxGrid1DBTableView1.ApplyBestFit();
end;

function TfrmListFTPServer.ValidaDatos: boolean;
begin
  result := True;
  if trim(UDM.cl_ftp_Server.FieldByName('usuarioftp').AsString) = '' then
    Result := False;
  if trim(UDM.cl_ftp_Server.FieldByName('pass').AsString) = '' then
    Result := False;
  if trim(UDM.cl_ftp_Server.FieldByName('puerto').AsString) = '' then
    Result := False;
  if (trim(UDM.cl_ftp_Server.FieldByName('etiquetaServ').AsString) = '') and (trim(UDM.cl_ftp_Server.FieldByName('ipserver').AsString) = '') then
    Result := False;
end;

end.

