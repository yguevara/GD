unit UManagementPDFFile;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.Buttons, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ExtCtrls,
  Winapi.ShellAPI, AdvOfficeStatusBar;

type
  PQry = ^TFDQuery;

  TfrmManagementProc = class(TForm)
    btnFindInforme: TSpeedButton;
    lbl1: TLabel;
    tlbObject: TToolBar;
    btn1: TToolButton;
    btntbtncerrar: TToolButton;
    btn3: TToolButton;
    btnViewInforme: TToolButton;
    btn2: TToolButton;
    btnhelp: TToolButton;
    edt1: TEdit;
    dlgOpenODPDF: TOpenDialog;
    dlgOpenODJPG: TOpenDialog;
    Timer1: TTimer;
    sbAD: TAdvOfficeStatusBar;
    procedure btn3Click(Sender: TObject);
    procedure btnFindInformeClick(Sender: TObject);
    procedure btnViewInformeClick(Sender: TObject);
    procedure btntbtncerrarClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnhelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    exten: string;
    Contenedor: PQry;
    NombreCampo, capt: string;
    function TamFichero(n: string): longint;
  end;

{var
  frmManagementProc: TfrmManagementProc;    }
procedure ManagementPDF(aDS: PQry; aFieldName, Etiq, extension: string);

implementation

uses
  UCapaDatos;

{$R *.dfm}
procedure ManagementPDF(aDS: PQry; aFieldName, Etiq, extension: string);
begin
  with TfrmManagementProc.Create(nil) do
  try
    Contenedor := aDS;
    exten := extension;
    NombreCampo := aFieldName;
    capt := Etiq;
    ShowModal;
  finally
    Free;
  end;
end;

{ TfrmManagementProc }

procedure TfrmManagementProc.btn3Click(Sender: TObject);
begin
  if (Contenedor^.FieldByName(NombreCampo).Value=null)or(trim(Contenedor^.FieldByName(NombreCampo).asstring)=null) then begin
    UDM.sms('Debe especificar un fichero válido para eliminar.', 3);
    Exit;
  end;
  if udm.sms('¿Está seguro de eliminar el procedimiento almacenado en el campo actual?', 4) = 6 then
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
  if exten = 'jpg' then
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

procedure TfrmManagementProc.btntbtncerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmManagementProc.btnViewInformeClick(Sender: TObject);
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
  if (Contenedor^.FieldByName(NombreCampo).Value=null)or(trim(Contenedor^.FieldByName(NombreCampo).asstring)=null) then begin
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

end.

