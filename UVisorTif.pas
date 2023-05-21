unit UVisorTif;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.OleCtrls, MapWinGIS_TLB, Data.DB, Bde.DBTables, AdvToolBar,
  Vcl.ExtCtrls, Vcl.ImgList, System.ImageList, Vcl.AppEvnts, Vcl.ComCtrls,
  Vcl.ToolWin, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TConsultaFD = ^TFDQuery;

  TfrmVisorFile = class(TForm)
    Map1: TMap;
    ILEdith: TImageList;
    OpenDialog1: TOpenDialog;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    btnClose: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton3: TToolButton;
    ToolButton6: TToolButton;
    btnhlp: TToolButton;
    ToolButton5: TToolButton;
    ImageList1: TImageList;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    FDConnection1: TFDConnection;
    FDQuery1: TFDQuery;
    procedure AdvToolBarButton5Click(Sender: TObject);
    procedure AdvToolBarButton6Click(Sender: TObject);
    procedure AdvToolBarButton9Click(Sender: TObject);
    procedure AdvToolBarButton8Click(Sender: TObject);
    procedure AdvToolBarButton1Click(Sender: TObject);
    procedure AdvToolBarButton3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    function sms(aText: string; aTipo: Integer): integer;
    procedure ToolButton7Click(Sender: TObject);
  private
    function OpenIMG(ImgPath: string): boolean;
    { Private declarations }
  public
    {Public declarations}
    pathfile: string;
    Simagen: Image;
    Contenedor: TConsultaFD;
    CampoIMG: string;
  end;

{var
  frmVisorFile: TfrmVisorFile; }

procedure VerTiff(ds: TConsultaFD; AFieldName, aFileName: string);

implementation

{$R *.dfm}

procedure VerTiff(ds: TConsultaFD; AFieldName, aFileName: string);
begin
  with TfrmVisorFile.Create(nil) do
  try
    pathfile := aFileName;
    Contenedor := ds;
    CampoIMG := AFieldName;
    if Trim(aFileName) <> '' then
      OpenIMG(aFileName);
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmVisorFile.AdvToolBarButton1Click(Sender: TObject);
begin
  close;
end;

procedure TfrmVisorFile.AdvToolBarButton3Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    if trim(OpenDialog1.FileName) <> '' then
    begin
      pathfile := '';
      if OpenIMG(OpenDialog1.FileName) then
        pathfile := OpenDialog1.FileName
    end;
end;

procedure TfrmVisorFile.AdvToolBarButton5Click(Sender: TObject);
begin
  Map1.CursorMode := cmZoomIn;
  Map1.Cursor := crDefault;
end;

procedure TfrmVisorFile.AdvToolBarButton6Click(Sender: TObject);
begin
  Map1.CursorMode := cmZoomOut;
  Map1.Cursor := crDefault;
end;

procedure TfrmVisorFile.AdvToolBarButton8Click(Sender: TObject);
begin
  Map1.ZoomToMaxExtents;
end;

procedure TfrmVisorFile.AdvToolBarButton9Click(Sender: TObject);
begin
  Map1.CursorMode := cmPan;
  Map1.Cursor := crDefault;
end;

procedure TfrmVisorFile.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVisorFile.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Simagen <> nil then
    Simagen.Close;
end;

procedure TfrmVisorFile.FormShow(Sender: TObject);
var
  hdle: integer;
begin
  {if trim(pathfile) = '' then
    Exit;
  if Simagen <> nil then
    Simagen.Close;
  Screen.Cursor := crSQLWait;
  try
    Simagen := CoImage.Create;
      //Simagen.BufferSize := 100;
    Simagen.Open(pathfile, USE_FILE_EXTENSION, False, nil);
    hdle := Map1.AddLayer(Simagen, true);
    if hdle = -1 then
    begin
      sms('No se pudo abrir el archivo especificado. Por favor inténtelo de nuevo si el problema persiste contacte con el soporte técnico de este software.', 1);
      Exit;
    end;
    Map1.LockWindow(lmUnlock);
  finally

    Screen.Cursor := crDefault;
  end;}
end;

function TfrmVisorFile.sms(aText: string; aTipo: Integer): integer;
begin
  case aTipo of
    1:
      begin
        result := Application.MessageBox(PChar(aText), PChar('¡Error!'), MB_OK + MB_ICONERROR + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
    2:
      begin
        result := MessageBox(Application.Handle, PChar(aText), PChar('¡Alerta!'), MB_OK + MB_ICONEXCLAMATION + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
    3:
      begin
        result := MessageBox(Application.Handle, PChar(aText), PChar('¡Información!'), MB_OK + MB_ICONINFORMATION + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
    4:
      begin
        result := Application.MessageBox(PChar(aText), PChar('¡Confirmación!'), MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON1 + MB_APPLMODAL);
      end;
  end;
end;

procedure TfrmVisorFile.ToolButton7Click(Sender: TObject);
var
  List: TStringList;
  URL, cade, ext, NombreF, NombreExt: string;
  Stream: TMemoryStream;
begin
  //Load PDF File into DB Field...
  if (Contenedor^.State <> dsedit) or (Contenedor^.State <> dsinsert) then
    Contenedor^.Edit;
  Stream := TMemoryStream.Create;
  if trim(pathfile) <> '' then
  try
    Stream.LoadFromFile(pathfile);
    Stream.Seek(0, soFromBeginning);
    TBlobField(Contenedor^.FieldByName(CampoIMG)).LoadFromStream(Stream);
    if (Contenedor^.State = dsedit) or (Contenedor^.State = dsinsert) then
    try
      Contenedor^.Post;
      sms('El fichero se guardó satisfactoriamente.', 3);
    except
      on E: EFDException do
      begin
        sms('No se pudo guardar el archivo imagen especificado. Motivo: ' + E.Message, 1);
        Contenedor^.Cancel;
      end;
    end;
  finally
    Stream.Free;
  end;

end;

function TfrmVisorFile.OpenIMG(ImgPath: string): boolean;
var
  handle: Integer;
begin
  Result := False;
  if Simagen <> nil then
    Simagen.Close;
  Screen.Cursor := crSQLWait;
  try
    Simagen := CoImage.Create;
    Simagen.Open(ImgPath, JPEG_FILE, False, nil);
    try
      handle := Map1.AddLayer(Simagen, true);
    except
    end;
    if handle = -1 then
    begin
      sms('No se pudo abrir el archivo especificado. Por favor inténtelo de nuevo si el problema persiste contacte con el soporte técnico de este software.', 1);
      Exit;
    end;
    Map1.LockWindow(lmUnlock);
    Result := True;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.

