unit UMangementArch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, Vcl.ComCtrls, Vcl.DBCtrls, cxDBNavigator,
  Vcl.ExtCtrls, Vcl.ToolWin, cxBlobEdit, cxDBLookupComboBox, JvEditor,
  cxDropDownEdit, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Menus, AdvMenus, Winapi.ShellAPI, AdvPanel, JvExControls, JvButton,
  JvTransparentButton, Vcl.StdCtrls, frxADOComponents, frxClass, frxGradient,
  frxRich, frxDBSet;

type
  TConsultaFD = ^TFDQuery;

  TfrmManagemetArch = class(TForm)
    StatusBar1: TStatusBar;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1DBTableView1Cod: TcxGridDBColumn;
    cxGrid1DBTableView1nombreArchivo: TcxGridDBColumn;
    cxGrid1DBTableView1Tipo: TcxGridDBColumn;
    cxGrid1DBTableView1Idresp: TcxGridDBColumn;
    cxGrid1DBTableView1croquis: TcxGridDBColumn;
    cxGrid1DBTableView1Foto: TcxGridDBColumn;
    cxGrid1DBTableView1Descripcion: TcxGridDBColumn;
    FDQuery1: TFDQuery;
    PMCroquis: TAdvPopupMenu;
    V2: TMenuItem;
    N2: TMenuItem;
    G1: TMenuItem;
    E2: TMenuItem;
    PMFoto: TAdvPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    AdvPanel1: TAdvPanel;
    DBNavigator3: TDBNavigator;
    cxDBNavigator3: TcxDBNavigator;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnExcelExport: TJvTransparentButton;
    btnExpand: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnExportSSExcel: TJvTransparentButton;
    btnBestFitSS: TJvTransparentButton;
    Edit1: TEdit;
    frxMain: TfrxReport;
    btnPrint: TJvTransparentButton;
    frxtb_sysconfig: TfrxDBDataset;
    procedure btnCloseClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure FormActivate(Sender: TObject);
    procedure cxGrid1DBTableView1croquisPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxGrid1DBTableView1DescripcionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure cxGrid1DBTableView1FotoPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure G1Click(Sender: TObject);
    procedure V2Click(Sender: TObject);
    procedure E2Click(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure btnExcelExportClick(Sender: TObject);
    procedure btnExpandClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
  private
    { Private declarations }
    function DownloadImageFileToTMP(aName, aCampoName: string): string;
    procedure ViewIMG(NombreCampo: string);
    function CleanFieldIMG(NombreCampo: string): Boolean;
  public
    { Public declarations }
    procedure CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
    procedure InsertConnection(report: TfrxReport; connection: string);
  end;

var
  frmManagemetArch: TfrmManagemetArch;

implementation

uses
  UCapaDatos, UExcelExport, UVeditor, UVisorTif, UManagementPDFFile, USystemMsg, UREditor;

{$R *.dfm}

procedure TfrmManagemetArch.btnExcelExportClick(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TfrmManagemetArch.btnExpandClick(Sender: TObject);
begin
  if cxGrid1DBTableView1.DataController.DataSet.RecordCount > 0 then
  begin
    try
      cxGrid1DBTableView1.ApplyBestFit();
      UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'cl_archivos');
    except
    end;
  end
  else
  begin
    UDM.sms('Esta función es recomendable utilizarla cuando existe al menos un registro inscrito.', 3);
    Exit;
  end;
end;

procedure TfrmManagemetArch.btnPrintClick(Sender: TObject);

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
  UDM.MostrarReporte('Archivo');{
   //esta validacion la puse aqui pero puede ser en otro lugar si deseas
  if ((UDM.tb_sysconfig.FieldByName('empresa').AsString <> '') and (not TBlobField(UDM.tb_sysconfig.FieldByName('logo')).IsNull)) then
  begin
     //salvar el logo que esta en la tabla de configuracion a la carpeta de reportes ,que ahora esta a nivel del mosulo
     //principal
    try
      TBlobField(UDM.tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
      if TamFichero(pathreport + 'logo.png') > 0 then
     //todos los parametros para cargar el reporte
        CargaReporte(frxMain, pathreport + 'rArchivo.fr3', 'empresa', UDM.tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png')
      else
        UDM.sms('No se pudo cargar el logo de la empresa especificado. Por favor revise la configuración del sistema.', 1);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo cargar el logo de la empresa por favor revise la configuración del sistema. Motivo: '+e.Message, 1);
      end;
    end;

  end
  else
  begin
    udm.sms('Debe configurar los Datos de la Empresa. Diríjase a la configuración del Sistema', 1);
  end;   }
end;

procedure TfrmManagemetArch.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmManagemetArch.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 17;
  Application.HelpContext(TopicID);
end;

procedure TfrmManagemetArch.CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
var
  Component: TfrxComponent;
begin
  with report do
  begin
    LoadFromFile(pathreport);
    InsertConnection(report, PathBD);
    Component := FindObject(nameempresa);
    if Component is TfrxRichView then

      TfrxRichView(Component).DataSet:= frxtb_sysconfig;
      TfrxRichView(Component).DataField:='empresa';
    Component := FindObject(nameimagen);
    if Component is TfrxPictureView then
      TfrxPictureView(Component).Picture.LoadFromFile(pathimagen);
    PrepareReport();
    ShowReport();
  end;
end;

function TfrmManagemetArch.CleanFieldIMG(NombreCampo: string): Boolean;
begin
  Result := False;
  if udm.sms('Atención:' + sLineBreak +
                'Está a punto de eliminar el fichero actual.' + sLineBreak +
                '¿Desea continuar?', 4) = 6 then
//  if UDM.sms('¿Realmente desea eliminar el contenido del campo ' + AnsiQuotedStr(NombreCampo, '"') + '?', 4) = 6 then
  begin
    UDM.cl_ArchivosGestion.Edit;
    TBlobField(UDM.cl_ArchivosGestion.FieldByName(NombreCampo)).Clear;
    try
      UDM.cl_ArchivosGestion.Post;
    except
      on E: EFDException do
      begin
        UDM.cl_ArchivosGestion.Cancel;
        UDM.sms('No se pudo realizar la operación solicitada. Motivo: ' + e.Message, 1);
      end;

    end;
  end;
end;

procedure TfrmManagemetArch.cxGrid1DBTableView1croquisPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  //CampoTexto(@UDM.dscl_ArchivosGestion, 'croquis', '');
 // ShowMessage('Tiesnes que programar una interface para cargar imagenes en objetos blob!!!');
  PMCroquis.PopupAtCursor;
end;

procedure TfrmManagemetArch.cxGrid1DBTableView1DescripcionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  //Descripcion
  CampoTexto(@UDM.dscl_ArchivosGestion, 'descripcion', 'Descripción del Archivo actual.');
end;

procedure TfrmManagemetArch.cxGrid1DBTableView1FotoPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  PMFoto.PopupAtCursor;
end;

procedure TfrmManagemetArch.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
begin
 { if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_ArchivosGestion.FieldByName('Idarchivo').AsInteger := UDM.GetLastId('cl_ArchivosGestion', 'Idarchivo');
  end; }
end;

function TfrmManagemetArch.DownloadImageFileToTMP(aName, aCampoName: string): string;
var
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;
begin
  Result := '';
  ext := 'jpg';
  Screen.Cursor := crSQLWait;
  try
    Path := PathTemp + aName + '.' + ext;
    if FileExists(Path) then
    try
      DeleteFile(Path);
    except
      if FileExists(Path) then
      begin
        flag := False;
        cont := 1;
        while not flag do
        begin
          Path := PathTemp + aName + inttostr(cont) + '.' + ext;
          if not FileExists(Path) then
            flag := True;
          cont := cont + 1;
        end;
      end;
    end;
    TBlobField(UDM.cl_ArchivosGestion.FieldByName(aCampoName)).SaveToFile(Path);
    Result := Path;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmManagemetArch.E2Click(Sender: TObject);
begin
  if CleanFieldIMG('croquis') then
    UDM.sms('El ' + AnsiQuotedStr('croquis', '"') + ' fue eliminado satisfactoriamente.', 3);
end;

procedure TfrmManagemetArch.FormActivate(Sender: TObject);
begin
//  Security.SetModSecurity(Self, acceso);
  //UDM.SalvaConfigGrid(cxGrid1DBTableView1.Name, 'cl_archivos');
end;

procedure TfrmManagemetArch.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.cl_ArchivosGestion.Active := False;
  UDM.cl_ArchivosGestion.Active := True;
  UDM.KillProcess('JPEGViewPortable.exe');
  UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'cl_archivos');
end;

procedure TfrmManagemetArch.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
  if Key = 112 then
  begin
    TopicID := 17;
    Application.HelpContext(TopicID);
  end;
end;

procedure TfrmManagemetArch.FormShow(Sender: TObject);
begin
  Edit1.Focused;
  Edit1.SetFocus;
  UDM.RestauraGrid(cxGrid1DBTableView1, 'cl_archivos');
end;

procedure TfrmManagemetArch.G1Click(Sender: TObject);
begin
  ManagementPDF(@UDM.cl_ArchivosGestion, 'croquis', 'Gestionando el croquis del archivo.', 'jpg');
end;

procedure TfrmManagemetArch.InsertConnection(report: TfrxReport; connection: string);
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

procedure TfrmManagemetArch.MenuItem1Click(Sender: TObject);
begin
  ViewIMG('foto');
end;

procedure TfrmManagemetArch.MenuItem3Click(Sender: TObject);
begin
  ManagementPDF(@UDM.cl_ArchivosGestion, 'foto', 'Gestionando la foto del archivo.', 'jpg');
end;

procedure TfrmManagemetArch.MenuItem4Click(Sender: TObject);
begin
  if CleanFieldIMG('foto') then
    UDM.sms('La ' + AnsiQuotedStr('foto', '"') + ' del archivo fue eliminada satisfactoriamente.', 3);
end;

procedure TfrmManagemetArch.V2Click(Sender: TObject);
begin
  ViewIMG('croquis');
end;

procedure TfrmManagemetArch.ViewIMG(NombreCampo: string);
var
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  if (UDM.cl_ArchivosGestion.FieldByName(NombreCampo).Value = null) or (trim(UDM.cl_ArchivosGestion.FieldByName(NombreCampo).asstring) = null) then
  begin
    UDM.sms('No existe ningún fichero almacenado que pueda ser visualizado.', 3);
    Exit;
  end;
  ext := 'jpg';
  Screen.Cursor := crSQLWait;
  try
    Path := PathTemp + NombreCampo + '.' + ext;
    if FileExists(Path) then
    try
      DeleteFile(Path);
    except
      if FileExists(Path) then
      begin
        flag := False;
        cont := 1;
        while not flag do
        begin
          Path := PathTemp + NombreCampo + inttostr(cont) + '.' + ext;
          if not FileExists(Path) then
            flag := True;
          cont := cont + 1;
        end;
      end;
    end;
    TBlobField(UDM.cl_ArchivosGestion.FieldByName(NombreCampo)).SaveToFile(Path);
    UDM.ViewIMG(Path);
    BringToFront;
    Refresh;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.

