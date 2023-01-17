unit UManagementFileSeries;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.Buttons, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ExtCtrls,
  Winapi.ShellAPI, System.StrUtils;

type
  PQry = ^TFDQuery;

  RActiveFTPServer = record
    Ip: string;
    Nombre: string;
    puerto: Integer;
    usuario: string;
    password: string;
    PathServer: string;
  end;

  TfrmManagementFile = class(TForm)
    tlbObject: TToolBar;
    btntbtncerrar: TToolButton;
    btn3: TToolButton;
    btn1: TToolButton;
    btnViewInforme: TToolButton;
    btn2: TToolButton;
    btnhelp: TToolButton;
    statInformesGeo: TStatusBar;
    lbl1: TLabel;
    edt1: TEdit;
    dlgOpenOD: TOpenDialog;
    Timer1: TTimer;
    btnFindInforme: TSpeedButton;
    procedure btntbtncerrarClick(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btnFindInformeClick(Sender: TObject);
    procedure btnViewInformeClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnhelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Contenedor: PQry;
    NombreCampo, capt: string;
    function TamFichero(n: string): longint;
    function GetFTPFilePath: string;
  end;

{var
  frmManagementFile: TfrmManagementFile;    }

const
  COPY_FILE_NO_BUFFERING = $1000;
  MsgApp = 'Presione Copy para iniciar copia Simple o Múltiple de Archivos';

procedure ManagementFileSeries(aDS: PQry; aFieldName, Etiq: string);

implementation

uses
  UCapaDatos;

{$R *.dfm}

var
  Cancel: LongBool;

procedure ManagementFileSeries(aDS: PQry; aFieldName, Etiq: string);
begin
  with TfrmManagementFile.Create(nil) do
  try
    Contenedor := aDS;
    NombreCampo := aFieldName;
    capt := Etiq;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmManagementFile.btn3Click(Sender: TObject);
begin
  if MessageDlg('¿Está seguro de eliminar el procedimiento almacenado en el campo actual?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Contenedor^.Edit;
    Contenedor^.FieldByName(NombreCampo).Clear;
    Contenedor^.Post;
    edt1.Text := '(Vacio)';
  end;
end;

procedure TfrmManagementFile.btnFindInformeClick(Sender: TObject);
var
  List: TStringList;
  URL, cade, ext, NombreF, NombreExt, PathFTPFile: string;
  Stream: TMemoryStream;
  tmp: RActiveFTPServer;
  Origen, Destino:string;

  function GetFTPFilePath: string;
  var
    cad: string;
    id: Integer;
    q: TFDQuery;
  begin
    cad := '/' +UDM.tb_tree.FieldByName('etiqueta').AsString+ '/';
    id := UDM.tb_tree.FieldByName('padre').AsInteger;
    q := TFDQuery.Create(nil);
    with q do
    begin
      active := False;
      Connection := UDM.Conn;
      SQL.Clear;
    end;
    while id <> 0 do
    begin
      with q do
      begin
        Active := False;
        SQL.Clear;
        SQL.Add('select etiqueta, padre from tb_tree where id=' + IntToStr(id));
        try
          Active := True;
          id := Fields[1].AsInteger;
          cad := '/' + Fields[0].AsString + cad;
        except
        end;
      end;
    end;
    with q do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select etiqueta, padre from tb_tree where id=0');
      try
        Active := True;
        cad := '/' + Fields[0].AsString+ cad;
      except
      end;
    end;
    q.Free;
    Result := cad;
  end;

begin
  //Load PDF File into DB Field...
  List := TStringList.Create;
  if (Contenedor^.State <> dsedit) or (Contenedor^.State <> dsinsert) then
    Contenedor^.Edit;
  Stream := TMemoryStream.Create;
  if dlgOpenOD.Execute then
  begin
    if dlgOpenOD.FileName <> '' then
    try
      tmp := RActiveFTPServer(UDM.GetFTPHost(UDM.tb_Serietree.FieldByName('servidor').AsInteger));
      if trim(tmp.usuario) <> '' then
        UDM.FTPconnect(tmp.Ip, tmp.usuario, tmp.password, inttostr(tmp.puerto))
      else
      begin
        PathFTPFile:=GetFTPFilePath;
        PathFTPFile:= AnsiReplaceStr(PathFTPFile, '/', '\');
        PathFTPFile := IncludeTrailingBackslash(tmp.PathServer) + PathFTPFile;
        PathFTPFile := AnsiReplaceStr(PathFTPFile, '\\', '\');
        PathFTPFile := AnsiReplaceStr(PathFTPFile, '"', '');
        ForceDirectories(PathFTPFile);
      end;
      Destino:=PathFTPFile+ExtractFileName(dlgOpenOD.FileName);
      Origen:=dlgOpenOD.FileName;
      CopyFileEx(pchar(origen), pchar(destino),nil, nil, nil, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);
      List.Add(destino);
      List.SaveToStream(Stream);
      //Stream.LoadFromFile(dlgOpenOD.FileName);
      Stream.Seek(0, soFromBeginning);
      TBlobField(Contenedor^.FieldByName(NombreCampo)).LoadFromStream(Stream);
      edt1.Text := dlgOpenOD.FileName;
    finally
      Stream.Free;
    end;
  end;
end;

procedure TfrmManagementFile.btnhelpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmManagementFile.btntbtncerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmManagementFile.btnViewInformeClick(Sender: TObject);
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
        MessageDlg('No se pudo abrir el Informe especificado. Motivo:' + E.Message, mtError, [mbOK], 0);
        Exit;
      end;
    end;
  end;

begin
  ext := 'pdf';
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
    ejecutaPDF(Path);
    BringToFront;
    Refresh;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TfrmManagementFile.GetFTPFilePath: string;
var
  cad: string;
  id: Integer;
  q: TFDQuery;
begin
  cad := '/' + UDM.tb_tree.FieldByName('etiqueta').AsString + '/';
  id := UDM.tb_tree.FieldByName('padre').AsInteger;
  q := TFDQuery.Create(nil);
  with q do
  begin
    active := False;
    SQL.Clear;
  end;
  while id <> 0 do
  begin
    with q do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select etiqueta, padre from tb_tree where id=' + IntToStr(id));
      try
        Active := True;
        id := Fields[1].AsInteger;
        cad := '/' + Fields[0].AsString + cad;
      except
      end;
    end;
  end;
  with q do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select etiqueta, padre from tb_tree where id=0');
    try
      Active := True;
      cad := '/' + Fields[0].AsString + cad;
    except
    end;
  end;
  q.Free;
  Result := cad;
end;

function TfrmManagementFile.TamFichero(n: string): longint;
var
  f: file of Byte;
begin
  AssignFile(f, n);
  Reset(f);
  TamFichero := FileSize(f);
  CloseFile(f);
end;

procedure TfrmManagementFile.Timer1Timer(Sender: TObject);
begin
  if (TBlobField(Contenedor^.FieldByName(NombreCampo)).Value = null) or (TBlobField(Contenedor^.FieldByName(NombreCampo)).AsString = '') then
  begin
    btn3.Enabled := False;
    btnViewInforme.Enabled := False;
    edt1.Text := '(<<Vacio>>)';
  end
  else
  begin
    btn3.Enabled := True;
    btnViewInforme.Enabled := True;
    edt1.Text := '(<<Fichero PDF Alamacenado>>)';
  end;
end;

end.

