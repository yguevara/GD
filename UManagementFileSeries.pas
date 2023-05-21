unit UManagementFileSeries;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.Buttons, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ExtCtrls,
  Winapi.ShellAPI, System.StrUtils, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxCustomData, cxStyles, cxTL, cxMaskEdit,
  cxTLdxBarBuiltInMenu, dxSkinsCore, dxSkinsDefaultPainters, cxInplaceContainer,
  cxDBTL, cxTLData, JvExControls, JvButton, JvTransparentButton,
  AdvOfficeStatusBar;

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
    lbl1: TLabel;
    edt1: TEdit;
    dlgOpenOD: TOpenDialog;
    Timer1: TTimer;
    btnFindInforme: TSpeedButton;
    FDQuery1: TFDQuery;
    sbAD: TAdvOfficeStatusBar;
    procedure btntbtncerrarClick(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btnFindInformeClick(Sender: TObject);
    procedure btnViewInformeClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Contenedor: PQry;
    NombreCampo, capt: string;
    function TamFichero(n: string): longint;
    function GetFTPFilePath: string;
    function GetSeriesNameFile(aFecha: TDate): string;
  end;

var
//  frmManagementFile: TfrmManagementFile;
  PathToSaveFile: WideString;

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
  if (Contenedor^.FieldByName(NombreCampo).Value = null) or (trim(Contenedor^.FieldByName(NombreCampo).asstring) = null) then
  begin
    UDM.sms('Debe especificar un fichero válido para eliminar.', 3);
    Exit;
  end;
  if UDM.sms('¿Está seguro de eliminar el procedimiento almacenado en el campo actual?', 4) = 6 then
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
  URL, cade, NombreF, NombreExt, PathFTPFile: string;
  Stream: TMemoryStream;
  tmp: RActiveFTPServer;
  Origen, Destino: string;
  sr: TSearchRec;
  i, j, inventario, ext: integer;
  nombre, extension, carpetaorg: string;
  padre: integer;
  idpadreA, idhijo: integer;
  VV: Variant;
  LevelAnt: integer;
//VARIABLES NUEVAS PARA METODO NUEVO...
  LongMLevel: Integer;
  MainLevel: Integer;
  CAD: string;
  level, GObjP: integer;
  GPath, GURL: string;
  SQLQ: string;

  function GetLevel(Path: string): Integer;
  var
    i, cont: integer;
    fn: string;
  begin
    fn := ExtractFileName(Path);
    if (fn = '.') or (fn = '..') then
    begin
      result := -1;
      Exit;
    end;
    cont := 0;
    for i := 1 to Length(Path) do
      if Path[i] = '\' then
        inc(cont);
    Result := cont - MainLevel;
  end;

  function getMLevel(Path: string): Integer;
  var
    i, cont: integer;
  begin
    cont := 0;
    LongMLevel := 0;
    for i := 1 to Length(Path) do
    begin
      if Path[i] = '\' then
        inc(cont);
      Inc(LongMLevel);
    end;
    Result := cont;
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\';
  end;

  function MaxIdHijo: Integer;
  var
    tmp: Integer;
  begin
    Result := 1;
    with TFDQuery.Create(nil) do
    try
      Active := False;
      Connection := UDM.Conn;
      SQL.Clear;
      SQL.Add('select Max(idhijo)as maximosonvalue from tb_ssArchdigital');
      try
        Active := True;
        if (Fields[0].Value <> null) and (trim(Fields[0].AsString) <> '') then
          Result := Fields[0].AsInteger + 1;
      except
      end;
    finally
      Free;
    end;
  end;

  function removeext(cad1: string): string;
  var
    i: integer;
    flag: Boolean;
  begin
    flag := False;
    for i := length(cad1) - 1 downto 1 do
    begin
      if flag then
        result := cad1[i] + result;
      if cad1[i] <> '.' then

      else
        flag := True;
    end;
  end;

  function GetFTPFilePath: string;
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
        cad := '/' + Fields[0].AsString + cad;
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
      PathSaveBinaryFile := PathToSaveFile + '_' + GetSeriesNameFile(StrToDate(UDM.tb_SeriesDatos.FieldByName('Fecha').AsString)) + '.pdf';
      ForceDirectories(ExtractFilePath(PathSaveBinaryFile));
      NombreFileSS := removeext(ExtractFileName(PathSaveBinaryFile));
      UDM.tb_SeriesDatos.FieldByName('namefile').AsString := NombreFileSS;
      Destino := PathSaveBinaryFile;
      Origen := dlgOpenOD.FileName;
      CopyFileEx(pchar(Origen), pchar(Destino), nil, nil, nil, COPY_FILE_RESTARTABLE or COPY_FILE_NO_BUFFERING);
      List.Add(Destino);
      List.SaveToStream(Stream);
      Stream.Seek(0, soFromBeginning);
      TBlobField(Contenedor^.FieldByName(NombreCampo)).LoadFromStream(Stream);
      //CreateDir(ExtractFilePath(Destino));
      //Agregando Carpeta fuente al sistema...
     { level := GetLevel(ExtractFilePath(Destino) + '\fuente\');
      GPath := GetPath;
      GURL := GetURLRaiz;
      idhijo := MaxIdHijo;
      ext := 102;
      UDM.tb_ssArchdigital.Append;
      UDM.tb_ssArchdigital.FieldByName('idestructura').AsString := UDM.tb_SeriesDatos.FieldByName('idestructura').AsString;
      UDM.tb_ssArchdigital.FieldByName('id').AsInteger := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
      UDM.tb_ssArchdigital.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
      UDM.tb_ssArchdigital.FieldByName('fecha').AsDateTime := UDM.tb_SeriesDatos.FieldByName('fecha').AsDateTime;
      UDM.tb_ssArchdigital.FieldByName('version').AsString := UDM.tb_SeriesDatos.FieldByName('version').AsString;
      UDM.tb_ssArchdigital.FieldByName('idhijo').AsInteger := 1;
      UDM.tb_ssArchdigital.FieldByName('nombre').AsString := 'FUENTE'; //UDM.tb_SeriesDatos.FieldByName('namefile').AsString;
      UDM.tb_ssArchdigital.FieldByName('ext').AsInteger := 0;
      UDM.tb_ssArchdigital.FieldByName('extnombre').AsString := 'DIR';
      UDM.tb_ssArchdigital.FieldByName('comentario').Value := Null;
      UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString := GURL;
      UDM.tb_ssArchdigital.FieldByName('path').AsString := GPath;
      UDM.tb_ssArchdigital.FieldByName('tamano').AsInteger := 0;
      UDM.tb_ssArchdigital.FieldByName('padre').AsInteger := 0;
      UDM.tb_ssArchdigital.FieldByName('Nivel').AsInteger := 0;
      try
        UDM.tb_ssArchdigital.Post;
      except
      end;   }
      edt1.Text := dlgOpenOD.FileName;
    finally
      Stream.Free;
    end;

  end;
end;

procedure TfrmManagementFile.btntbtncerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmManagementFile.btnViewInformeClick(Sender: TObject);
{var
  List: TStringList;
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
  if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    UDM.ViewPDF(List[0]);
  end;
end; }
var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;
  cad:string;

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
  if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    if FileExists(List[0]) then begin
      ext:=ExtractFileExt(List[0]);
      if AnsiLowerCase(ext)='.pdf' then
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

function TfrmManagementFile.GetSeriesNameFile(aFecha: TDate): string;
var
  fe: string;
begin
  fe := datetostr(aFecha) + '_' + TimeToStr(Now);
  fe := AnsiReplaceStr(fe, '/', '_');
  fe := AnsiReplaceStr(fe, ' ', '_');
  fe := AnsiReplaceStr(fe, ':', '_');
  result := fe;
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
    edt1.Text := '(<<Vacio>>)';
  end
  else
  begin
    edt1.Text := '(<<Fichero PDF Alamacenado>>)';
  end;
end;

end.

