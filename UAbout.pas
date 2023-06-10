unit UAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  dxGDIPlusClasses, Vcl.ExtCtrls, Vcl.StdCtrls, acPNG, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxTextEdit, cxMemo;

type
  TfrmAbout = class(TForm)
    Image1: TImage;
    lblBuild: TLabel;
    mDatos: TcxMemo;
    procedure Image1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Sto_GetFmtFileVersion(const FileName: string = ''; const Fmt: string = '%d.%d.%d.%d'): string;
  end;

var
  frmAbout: TfrmAbout;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmAbout.FormActivate(Sender: TObject);
begin
  if UDM.tb_sysconfig.RecordCount > 0 then
  begin
    lblBuild.Visible:=False;
    mdatos.Lines.Clear;
    mdatos.Lines.Add('EMSERGO S.R.L');
    mdatos.Lines.Add('Producto Licenciado a: ' + UDM.tb_sysconfig.FieldByName('empresa').AsString);
    mdatos.Lines.Add('ID del Producto: ' + UDM.tb_sysconfig.FieldByName('idproducto').AsString);
    mdatos.Lines.Add('Versión: ' + UDM.tb_sysconfig.FieldByName('version').AsString);
    mdatos.Lines.Add('ArchiGenioPro v' + Sto_GetFmtFileVersion(Application.ExeName, '%.d.%.d.%.d.%.4d'));
  end
  else begin
    lblBuild.Visible:=True;
  end;
 // lblVersion.Caption:='Versión: '+UDM.tb_sysconfig.FieldByName('version').AsString;
 // lblProductID.Caption:='ID: '+UDM.tb_sysconfig.FieldByName('idproducto').AsString;
 // lblEmpresa.Caption:='Empresa: '+UDM.tb_sysconfig.FieldByName('empresa').AsString;
end;

procedure TfrmAbout.Image1Click(Sender: TObject);
begin
  Close;
end;

function TfrmAbout.Sto_GetFmtFileVersion(const FileName, Fmt: string): string;
  var
    sFileName: string;
    iBufferSize: DWORD;
    iDummy: DWORD;
    pBuffer: Pointer;
    pFileInfo: Pointer;
    iVer: array[1..4] of Word;
  begin
  // set default value
    Result := '';
  // get filename of exe/dll if no filename is specified
    sFileName := Trim(FileName);
    if (sFileName = '') then
      sFileName := GetModuleName(HInstance);
  // get size of version info (0 if no version info exists)
    iBufferSize := GetFileVersionInfoSize(PChar(sFileName), iDummy);
    if (iBufferSize > 0) then
    begin
      GetMem(pBuffer, iBufferSize);
      try
    // get fixed file info (language independent)
        GetFileVersionInfo(PChar(sFileName), 0, iBufferSize, pBuffer);
        VerQueryValue(pBuffer, '\', pFileInfo, iDummy);
    // read version blocks
        iVer[1] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
        iVer[2] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionMS);
        iVer[3] := HiWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
        iVer[4] := LoWord(PVSFixedFileInfo(pFileInfo)^.dwFileVersionLS);
      finally
        FreeMem(pBuffer);
      end;
    // format result string
      Result := Format(Fmt, [iVer[1], iVer[2], iVer[3], iVer[4]]);
    end;
  end;

end.

