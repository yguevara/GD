unit UManagementPDFFile;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.Buttons, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ExtCtrls,
  Winapi.ShellAPI, AdvOfficeStatusBar, JvExControls, JvButton,
  JvTransparentButton;

type
  PQry = ^TFDQuery;

  TfrmManagementProc = class(TForm)
    btnFindInforme: TSpeedButton;
    lbl1: TLabel;
    edt1: TEdit;
    dlgOpenODPDF: TOpenDialog;
    dlgOpenODJPG: TOpenDialog;
    Timer1: TTimer;
    sbAD: TAdvOfficeStatusBar;
    pMainContainer: TPanel;
    btnClose: TJvTransparentButton;
    btnautentica: TJvTransparentButton;
    btnFileClean: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    Edit1: TEdit;
    procedure btn3Click(Sender: TObject);
    procedure btnFindInformeClick(Sender: TObject);
    procedure btnViewInformeClick(Sender: TObject);
    procedure btntbtncerrarClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnhelpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    exten: string;
    Contenedor: PQry;
    NombreCampo, capt: string;
    function TamFichero(n: string): longint;
    procedure ViewIMG(NombreCampo: string);
  end;

{var
  frmManagementProc: TfrmManagementProc;    }


procedure ManagementPDF(aDS: PQry; aFieldName, Etiq, extension: string);

implementation

uses
  UCapaDatos, USystemMsg;

{$R *.dfm}
procedure ManagementPDF(aDS: PQry; aFieldName, Etiq, extension: string);
begin
  with TfrmManagementProc.Create(nil) do
  try
    Contenedor := aDS;
    exten := extension;
    NombreCampo := aFieldName;
    Caption := Etiq;
    ShowModal;
  finally
    Free;
  end;
end;

{ TfrmManagementProc }

procedure TfrmManagementProc.btn3Click(Sender: TObject);
begin
  if (Contenedor^.FieldByName(NombreCampo).Value = null) or (trim(Contenedor^.FieldByName(NombreCampo).asstring) = null) then
  begin
    UDM.sms('Debe especificar un fichero válido para eliminar.', 3);
    Exit;
  end;
  if udm.sms('Atención:' + sLineBreak + 'Está a punto de eliminar el fichero actual.' + sLineBreak + '¿Desea continuar?', 4) = 6 then
  begin
    Contenedor^.Edit;
    Contenedor^.FieldByName(NombreCampo).Clear;
    Contenedor^.Post;
    edt1.Text := '(Vacio)';
  end;

end;

procedure TfrmManagementProc.btnFindInformeClick(Sender: TObject);
var
  List: TStringList;
  URL, cade, ext, NombreF, NombreExt: string;
  Stream: TMemoryStream;
begin
  //Load PDF File into DB Field...
  if (exten = 'jpg') or (exten = 'jpeg') or (exten = 'png') or (exten = 'bmp') then
  begin
    if (Contenedor^.State <> dsedit) or (Contenedor^.State <> dsinsert) then
      Contenedor^.Edit;
    Stream := TMemoryStream.Create;
    if dlgOpenODJPG.Execute then
    begin
      if dlgOpenODJPG.FileName <> '' then
      try
        Stream.LoadFromFile(dlgOpenODJPG.FileName);
        Stream.Seek(0, soFromBeginning);
        TBlobField(Contenedor^.FieldByName(NombreCampo)).LoadFromStream(Stream);
        edt1.Text := dlgOpenODJPG.FileName;
      finally
        Stream.Free;
      end;
    end;
  end
  else
  begin
    if (Contenedor^.State <> dsedit) or (Contenedor^.State <> dsinsert) then
      Contenedor^.Edit;
    Stream := TMemoryStream.Create;
    if dlgOpenODPDF.Execute then
    begin
      if dlgOpenODPDF.FileName <> '' then
      try
        Stream.LoadFromFile(dlgOpenODPDF.FileName);
        Stream.Seek(0, soFromBeginning);
        TBlobField(Contenedor^.FieldByName(NombreCampo)).LoadFromStream(Stream);
        edt1.Text := dlgOpenODPDF.FileName;
      finally
        Stream.Free;
      end;
    end;
  end;

end;

procedure TfrmManagementProc.btnhelpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmManagementProc.btnSystemHelpClick(Sender: TObject);
begin
  Application.HelpContext(42);
end;

procedure TfrmManagementProc.btntbtncerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmManagementProc.btnViewInformeClick(Sender: TObject);
var
  param, param1, listParam: string;
begin
  if exten <> 'jpg' then
  begin
    screen.Cursor := crSQLWait;
    param := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
    param1 := UDM.tb_SeriesDatos.FieldByName('codigodoc').AsString;
    listParam := AnsiQuotedStr(param, '"') + ' ' + AnsiQuotedStr(param1, '"');
    UDM.RunAndWaitShell(ExtractFilePath(Application.ExeName) + '\PDFExpressViewer.exe', listParam, SW_SHOWMAXIMIZED);
    screen.Cursor := crDefault;
  end
  else
  begin
    ViewIMG(NombreCampo);
  end;
end;
{var
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
  if (Contenedor^.FieldByName(NombreCampo).Value = null) or (trim(Contenedor^.FieldByName(NombreCampo).asstring) = null) then
  begin
    UDM.sms('No existe ningún fichero almacenado que pueda ser visualizado.', 3);
    Exit;
  end;
  ext := exten;
  Screen.Cursor := crSQLWait;
  try
    Path := PathTemp + capt + '.' + ext;
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
          Path := PathTemp + capt + inttostr(cont) + '.' + ext;
          if not FileExists(Path) then
            flag := True;
          cont := cont + 1;
        end;
      end;
    end;
    TBlobField(Contenedor^.FieldByName(NombreCampo)).SaveToFile(Path);
    UDM.ViewIMG(Path);
    //ejecutaPDF(Path);
    BringToFront;
    Refresh;
  finally
    Screen.Cursor := crDefault;
  end;     }

  {
  if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    if FileExists(List[0]) then
    begin
      ext := ExtractFileExt(List[0]);
      if AnsiLowerCase(ext) = '.pdf' then
      begin
        cad := QuotedStr('P') + ' ' + AnsiQuotedStr(List[0], '"');
        UDM.RunAndWaitShell(PathSys + 'Viewer.exe', cad, SW_SHOWMAXIMIZED);
      end;
      //UDM.ViewPDF(List[0]);
    end
    else
      UDM.sms('No existe el fichero especificado.', 1);
  end
  else
  begin
    UDM.sms('Error se encontró un documento para visualizar. Especifique un documento válido para visualizar.', 3);
  end;
end;        }

procedure TfrmManagementProc.FormActivate(Sender: TObject);
begin
  Edit1.Focused;
  Edit1.SetFocus;
end;

procedure TfrmManagementProc.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 112 then
  begin
    Application.HelpContext(42);
  end;
end;

function TfrmManagementProc.TamFichero(n: string): longint;
var
  f: file of Byte;
begin
  AssignFile(f, n);
  Reset(f);
  TamFichero := FileSize(f);
  CloseFile(f);
end;

procedure TfrmManagementProc.Timer1Timer(Sender: TObject);
begin
  if (TBlobField(Contenedor^.FieldByName(NombreCampo)).Value = null) or (TBlobField(Contenedor^.FieldByName(NombreCampo)).AsString = '') then
  begin
    edt1.Text := '(<<Vacio>>)';
  end
  else
  begin
    edt1.Text := '(<<Fichero Alamacenado>>)';
  end;
end;

procedure TfrmManagementProc.ViewIMG(NombreCampo: string);
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
  ext := exten;
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

