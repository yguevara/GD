unit USplash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Samples.Gauges, dxGDIPlusClasses, Vcl.ExtCtrls, Vcl.StdCtrls, acPNG,
  mxProtector, CBIOSInfo, CProcessorInfo, CWMIBase, CDiskDriveInfo,
  IdHashMessageDigest, IdGlobal, IdHash, UTema;

type
  TNCB = record
    ncb_command: Byte;
    ncb_retcode: Byte;
    ncb_lsn: Byte;
    ncb_num: Byte;
    ncb_buffer: PAnsiChar;
    ncb_length: Word;
    ncb_callname: array[0..15] of AnsiChar;
    ncb_name: array[0..15] of AnsiChar;
    ncb_rto: Byte;
    ncb_sto: Byte;
    ncb_post: DWORD;
    ncb_lana_num: Byte;
    ncb_cmd_cplt: Byte;
    ncb_reserve: array[0..9] of Byte;
    ncb_event: DWORD;
  end;

  TLanaEnum = record
    length: Byte;
    lana: array[0..254] of Byte;
  end;

  TAdapterStatus = record
    adapter_address: array[0..5] of Byte;
    rev_major: Byte;
    reserved0: Byte;
    adapter_type: Byte;
    rev_minor: Byte;
    duration: Word;
    frmr_recv: Word;
    frmr_xmit: Word;
    iframe_recv_err: Word;
    xmit_aborts: Word;
    xmit_success: DWORD;
    recv_success: DWORD;
    iframe_xmit_err: Word;
    recv_buff_unavail: Word;
    t1_timeouts: Word;
    ti_timeouts: Word;
    reserved1: DWORD;
    free_ncbs: Word;
    max_cfg_ncbs: Word;
    max_ncbs: Word;
    xmit_buf_unavail: Word;
    max_dgram_size: Word;
    pending_sess: Word;
    max_cfg_sess: Word;
    max_sess: Word;
    max_sess_pkt_size: Word;
    name_count: Word;
  end;

  PNCB = ^TNCB;
  PGauge = ^TGauge;

  TfrmSplash = class(TForm)
    Gauge1: TGauge;
    Label1: TLabel;
    PRO: TImage;
    lblBuild: TLabel;
    BAS: TImage;
    DiskDriveInfo1: TDiskDriveInfo;
    ProcessorInfo1: TProcessorInfo;
    BiosInfo1: TBIOSInfo;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    procedure AplicarApariencia;
  public
    { Public declarations }
    procedure Inici(aBAR: PGauge; Min, Max: integer);
    procedure MueveBar(aBAR: PGauge; increment: integer);
    function getMd5HashString(const vValue: string): string;
  end;

const
  NCBNAMSZ = 16;             // Nombre del equipo
  MAX_LANA = 254;            // Número máximo de LANAs
  NCBENUM = $37;             // Enumerar LANAs
  NCBRESET = $32;            // Resetear LANA
  NCBASTAT = $33;            // Obtener estado del adaptador

var
  frmSplash: TfrmSplash;
  VERS: string;
  HID: string;
  PathApp: string;
  VersionAprobada: boolean;

implementation

{$R *.dfm}

uses
  UShellPrincipal;

{ TfrmSplash }

function Netbios(pNCB: pNCB): Byte; stdcall; external 'netapi32.dll';

function GetMACAddress: string;
var
  NCB: TNCB;
  Lenum: TLanaEnum;
  Adapter: TAdapterStatus;
  i, j: integer;
  TmpStr: string;
begin
  Result := '';
  FillChar(NCB, SizeOf(TNCB), 0);
  NCB.ncb_command := NCBENUM;
  NCB.ncb_buffer := @Lenum;
  NCB.ncb_length := SizeOf(Lenum);
  if Netbios(@NCB) <> 0 then
    Exit;
  for i := 0 to Lenum.length - 1 do
  begin
    FillChar(NCB, SizeOf(TNCB), 0);
    NCB.ncb_command := NCBRESET;
    NCB.ncb_lana_num := Lenum.lana[i];
    if Netbios(@NCB) <> 0 then
      Exit;

    FillChar(NCB, SizeOf(TNCB), 0);
    NCB.ncb_command := NCBASTAT;
    NCB.ncb_lana_num := Lenum.lana[i];
    StrPCopy(NCB.ncb_callname, '*               ');
    NCB.ncb_buffer := @Adapter;
    NCB.ncb_length := SizeOf(Adapter);

    if Netbios(@NCB) = 0 then
    begin
      TmpStr := '';
      for j := 0 to 5 do
        TmpStr := TmpStr + IntToHex(Adapter.adapter_address[j], 2);
      Result := TmpStr;
      Break;
    end;
  end;
end;

function GetDiskSerial: string;
var
  VolumeSerialNumber: DWORD;
  MaximumComponentLength, FileSystemFlags: DWORD;
  FileSystemNameBuffer: array[0..MAX_PATH] of Char;
begin
  if GetVolumeInformation(PChar('C:\'), nil, 0, @VolumeSerialNumber, MaximumComponentLength, FileSystemFlags, FileSystemNameBuffer, SizeOf(FileSystemNameBuffer)) then
    Result := IntToHex(VolumeSerialNumber, 8)
  else
    Result := '00000000';
end;

function GenerateUniqueHash: string;
var
  HashStr: string;
  Hash: TIdHashMessageDigest5;
begin
  // Combinar los identificadores en un solo string
  HashStr := GetDiskSerial + GetMACAddress+ GetEnvironmentVariable('COMPUTERNAME') + GetEnvironmentVariable('USERNAME');
  // Generar el hash MD5
  Hash := TIdHashMessageDigest5.Create;
  try
    Result := Hash.HashStringAsHex(HashStr);
  finally
    Hash.Free;
  end;
end;

// Apariencia de ArchiGenio: colores de UTema (claro u oscuro segun Windows).
// Solo toca controles visuales; la imagen de fondo anterior queda oculta.
procedure TfrmSplash.AplicarApariencia;
var
  T: TTemaColores;
  Banda: TPanel;
  Nombre, Edicion: TLabel;
begin
  if TemaWindowsOscuro then
    T := TemaOscuro
  else
    T := TemaClaro;
  PRO.Visible := False;
  BAS.Visible := False;
  Color := T.Superficie;

  Banda := TPanel.Create(Self);
  Banda.Parent := Self;
  Banda.Align := alLeft;
  Banda.Width := 12;
  Banda.BevelOuter := bvNone;
  Banda.ParentBackground := False;
  Banda.StyleElements := [];
  Banda.Color := T.Acento;

  Nombre := TLabel.Create(Self);
  Nombre.Parent := Self;
  Nombre.AutoSize := True;
  Nombre.Transparent := True;
  Nombre.Font.Name := 'Segoe UI Semibold';
  Nombre.Font.Size := 34;
  Nombre.Font.Color := T.Texto;
  Nombre.Caption := 'ArchiGenio';
  Nombre.Left := 58;
  Nombre.Top := 110;

  Edicion := TLabel.Create(Self);
  Edicion.Parent := Self;
  Edicion.AutoSize := True;
  Edicion.Transparent := True;
  Edicion.Font.Name := 'Segoe UI';
  Edicion.Font.Size := 13;
  Edicion.Font.Color := T.Acento;
  if VERS = 'PROFESIONAL' then
    Edicion.Caption := 'Edicion Profesional - gestion de archivo documental'
  else
    Edicion.Caption := 'Edicion Basica - gestion de archivo documental';
  Edicion.Left := 60;
  Edicion.Top := 168;

  lblBuild.Transparent := True;
  lblBuild.ParentColor := True;
  lblBuild.Font.Name := 'Segoe UI';
  lblBuild.Font.Size := 10;
  lblBuild.Font.Style := [];
  lblBuild.Font.Color := T.TextoSuave;
  lblBuild.Left := 60;
  lblBuild.Top := 202;
  lblBuild.BringToFront;

  Gauge1.BorderStyle := bsNone;
  Gauge1.ForeColor := T.Acento;
  Gauge1.BackColor := T.Linea;
  Gauge1.SetBounds(60, ClientHeight - 70, ClientWidth - 60 - 48, 6);
  Gauge1.BringToFront;
  Label1.Transparent := True;
  Label1.Font.Name := 'Segoe UI';
  Label1.Font.Size := 9;
  Label1.Font.Color := T.TextoSuave;
  Label1.Caption := 'Iniciando...';
  Label1.SetBounds(60, ClientHeight - 56, 300, 16);
  Label1.BringToFront;
end;

procedure TfrmSplash.FormCreate(Sender: TObject);
var
  List: TStringList;
  pcad, dcad: string;
  ddP: TProcessorInfo;
  ddPropsP: TProcessorProperties;
  dd: TDiskDriveInfo;
  ddProps: TDiskDriveProperties;
  PasswordApp: string;
begin
  PathApp := ExtractFilePath(Application.ExeName);
  List := TStringList.Create;
  VersionAprobada := False;
  PasswordApp:=GenerateUniqueHash;
  if FileExists(PathApp + 'vcode.conf') then
  begin
    List.LoadFromFile(PathApp + 'vcode.conf');
    if List.IndexOf(PasswordApp) <> -1 then
      VersionAprobada := True;
  end;
  List.Free;
  AplicarApariencia;
  Gauge1.MaxValue := 4;
  Gauge1.MinValue := 0;
  Gauge1.Progress := 0;
end;

procedure TfrmSplash.FormShow(Sender: TObject);
begin
{  Application.BringToFront;
  BringToFront;}
end;

function TfrmSplash.getMd5HashString(const vValue: string): string;
var
  vHashMD5: TIdHashMessageDigest5;
begin
  vHashMD5 := nil;
  try
    vHashMD5 := TIdHashMessageDigest5.Create;
    Result := IdGlobal.IndyLowerCase(vHashMD5.HashStringAsHex(vValue));
  finally
    vHashMD5.Free;
  end;
end;

procedure TfrmSplash.Inici(aBAR: PGauge; Min, Max: integer);
begin
  aBAR.MinValue := Min;
  aBAR.MaxValue := Max;
  aBAR.Progress := 0;
  aBAR.Update;
end;

procedure TfrmSplash.MueveBar(aBAR: PGauge; increment: integer);
begin
  aBAR.Progress := aBAR.Progress + increment;
  aBAR.Update;
  Application.ProcessMessages;
end;

end.

