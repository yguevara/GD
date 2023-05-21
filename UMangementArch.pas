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
  Vcl.Menus, AdvMenus, Winapi.ShellAPI, AdvPanel;

type
  TConsultaFD = ^TFDQuery;

  TfrmManagemetArch = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    ToolButton1: TToolButton;
    ToolButton4: TToolButton;
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
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure ToolButton4Click(Sender: TObject);
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
  private
    { Private declarations }
    function DownloadImageFileToTMP(aName, aCampoName: string): string;
    procedure ViewIMG(NombreCampo: string);
    function CleanFieldIMG(NombreCampo: string): Boolean;
  public
    { Public declarations }
  end;

var
  frmManagemetArch: TfrmManagemetArch;

implementation

uses
  UCapaDatos, UExcelExport, UVeditor, UVisorTif, UManagementPDFFile;

{$R *.dfm}

procedure TfrmManagemetArch.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmManagemetArch.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

function TfrmManagemetArch.CleanFieldIMG(NombreCampo: string): Boolean;
begin
  Result := False;
  if UDM.sms('¿Realmente desea eliminar el contenido del campo ' + AnsiQuotedStr(NombreCampo, '"') + '?', 4) = 6 then
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
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmManagemetArch.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.cl_ArchivosGestion.Active := False;
  UDM.cl_ArchivosGestion.Active := True;
  UDM.KillProcess('JPEGViewPortable.exe');
end;

procedure TfrmManagemetArch.G1Click(Sender: TObject);
begin
  ManagementPDF(@UDM.cl_ArchivosGestion, 'croquis', 'Gestionando el croquis del archivo.', 'jpg');
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

procedure TfrmManagemetArch.ToolButton4Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
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
//    ejecutaPDF(Path);
    BringToFront;
    Refresh;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.

