unit UAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  dxGDIPlusClasses, Vcl.ExtCtrls, Vcl.StdCtrls, acPNG, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, cxTextEdit, cxMemo, cxRichEdit, Vcl.ComCtrls, Vcl.Imaging.pngimage, UTema;

type
  TfrmAbout = class(TForm)
    BAS: TImage;
    lblBuild: TLabel;
    pro: TImage;
    Panel1: TPanel;
    procedure BASClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FAplicada: Boolean;
    procedure AplicarApariencia;
  public
    { Public declarations }
    function Sto_GetFmtFileVersion(const FileName: string = ''; const Fmt: string = '%d.%d.%d.%d'): string;
  end;

var
  frmAbout: TfrmAbout;

implementation

uses
  UCapaDatos, UShellPrincipal;

{$R *.dfm}

// Apariencia de ArchiGenio con los colores de UTema (claro u oscuro segun
// Windows). Los datos salen de programver, VersionProgram y buildprogram.
procedure TfrmAbout.AplicarApariencia;
const
  ANCHO = 420;
  ALTO = 400;
var
  T: TTemaColores;
  Cabecera: TPanel;
  L: TLabel;
  Logo: TImage;
  Png: TPngImage;
  Flujo: TResourceStream;

  function Etiqueta(const Texto: string; Y, Tam: Integer; Color: TColor;
    Negrita: Boolean): TLabel;
  begin
    Result := TLabel.Create(Self);
    Result.Parent := Self;
    Result.AutoSize := True;
    Result.Transparent := True;
    Result.Font.Name := 'Segoe UI';
    Result.Font.Size := Tam;
    Result.Font.Color := Color;
    if Negrita then
      Result.Font.Style := [fsBold];
    Result.Caption := Texto;
    Result.Left := 28;
    Result.Top := Y;
  end;

begin
  if FAplicada then
    Exit;
  FAplicada := True;
  if TemaWindowsOscuro then
    T := TemaOscuro
  else
    T := TemaClaro;
  BAS.Visible := False;
  pro.Visible := False;
  Panel1.Visible := False;
  Color := T.Superficie;
  ClientWidth := ANCHO;
  ClientHeight := ALTO;

  Cabecera := TPanel.Create(Self);
  Cabecera.Parent := Self;
  Cabecera.Align := alTop;
  Cabecera.Height := 110;
  Cabecera.BevelOuter := bvNone;
  Cabecera.ParentBackground := False;
  Cabecera.StyleElements := [];
  Cabecera.Color := T.Acento;
  Cabecera.OnClick := BASClick;

  L := TLabel.Create(Self);
  L.Parent := Cabecera;
  L.AutoSize := True;
  L.Transparent := True;
  L.Font.Name := 'Segoe UI Semibold';
  L.Font.Size := 26;
  L.Font.Color := T.TextoSobreAcento;
  L.Caption := 'ArchiGenio';
  L.Left := 28;
  L.Top := 26;
  L.OnClick := BASClick;

  L := TLabel.Create(Self);
  L.Parent := Cabecera;
  L.AutoSize := True;
  L.Transparent := True;
  L.Font.Name := 'Segoe UI';
  L.Font.Size := 11;
  L.Font.Color := T.TextoSobreAcento;
  L.Caption := 'Gestion de archivo documental';
  L.Left := 30;
  L.Top := 72;
  L.OnClick := BASClick;

  // lblBuild conserva el texto "ArchiGenio vX.X.X.XXXX" que arma FormActivate
  lblBuild.Parent := Self;
  lblBuild.Transparent := True;
  lblBuild.ParentColor := True;
  lblBuild.Font.Name := 'Segoe UI';
  lblBuild.Font.Size := 11;
  lblBuild.Font.Color := T.Texto;
  lblBuild.Left := 28;
  lblBuild.Top := 134;
  lblBuild.BringToFront;

  if programver = 'PROFESIONAL' then
    Etiqueta('Edicion: Profesional', 168, 10, T.Texto, False)
  else
    Etiqueta('Edicion: Basica', 168, 10, T.Texto, False);
  Etiqueta('Compilacion: ' + buildprogram, 218, 10, T.TextoSuave, False);
  Etiqueta('Desarrollado por', 258, 9, T.TextoSuave, False);
  // Logo de EMSERGO S.R.L. (recurso LOGO_EMSERGO de Iconos.rc)
  Logo := TImage.Create(Self);
  Logo.Parent := Self;
  Logo.Transparent := True;
  Logo.Proportional := True;
  Logo.Stretch := True;
  Logo.SetBounds(28, 276, 240, 58);
  Png := TPngImage.Create;
  try
    Flujo := TResourceStream.Create(HInstance, 'LOGO_EMSERGO', RT_RCDATA);
    try
      Png.LoadFromStream(Flujo);
    finally
      Flujo.Free;
    end;
    Logo.Picture.Assign(Png);
  finally
    Png.Free;
  end;
  Logo.OnClick := BASClick;
  Etiqueta('EMSERGO S.R.L. - Empresa de Servicios Geomaticos del Oriente.', 342, 8, T.TextoSuave, False);
  Etiqueta('Todos los derechos reservados.', 358, 8, T.TextoSuave, False);
  Etiqueta('Clic en cualquier parte para cerrar', ALTO - 22, 8, T.TextoSuave, False);
  OnClick := BASClick;
end;

procedure TfrmAbout.FormActivate(Sender: TObject);
begin
  if programver='PROFESIONAL' then begin
    pro.Visible:=TRUE;
    pro.Align:=alClient;
    pro.SendToBack;
    BAS.Visible:=False;
    lblBuild.Caption:='ArchiGenioPro v' + Sto_GetFmtFileVersion(Application.ExeName, '%.d.%.d.%.d.%.4d');
  end else begin
    BAS.Visible:=TRUE;
    BAS.Align:=alClient;
    BAS.SendToBack;
    Pro.Visible:=False;
    lblBuild.Caption:='ArchiGenio v' + Sto_GetFmtFileVersion(Application.ExeName, '%.d.%.d.%.d.%.4d');
  end;
  AplicarApariencia;
 { if UDM.tb_sysconfig.RecordCount > 0 then
  begin
    lblBuild.Visible:=False;
    mdatos.Lines.Clear;
    mdatos.Lines.Add('EMSERGO S.R.L');
//    mdatos.Lines.Add('Producto Licenciado a: ' + GetPT(UDM.tb_sysconfig.FieldByName('empresa').AsString));
    mdatos.Lines.Add('ID del Producto: ' + UDM.tb_sysconfig.FieldByName('idproducto').AsString);
    mdatos.Lines.Add('Versión: ' + UDM.tb_sysconfig.FieldByName('version').AsString);
    mdatos.Lines.Add('ArchiGenioPro v' + Sto_GetFmtFileVersion(Application.ExeName, '%.d.%.d.%.d.%.4d'));
  end
  else begin
    lblBuild.Visible:=True;
  end;       }
 // lblVersion.Caption:='Versión: '+UDM.tb_sysconfig.FieldByName('version').AsString;
 // lblProductID.Caption:='ID: '+UDM.tb_sysconfig.FieldByName('idproducto').AsString;
 // lblEmpresa.Caption:='Empresa: '+UDM.tb_sysconfig.FieldByName('empresa').AsString;
end;

procedure TfrmAbout.BASClick(Sender: TObject);
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

