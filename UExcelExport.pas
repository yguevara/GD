unit UExcelExport;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, sGauge,
  JvComponentBase, JvgExportComponents, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, sDialogs, TlHelp32, shellapi,
  Vcl.ExtCtrls, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, cxDBData, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, Vcl.Grids, Vcl.DBGrids, Excel2000, ComCtrls, cxDBLookupComboBox,
  cxGridExportLink, System.StrUtils;

type
  TfrmExcelExport = class(TForm)
    ex: TJvgExportExcel;
    SD: TsSaveDialog;
    Panel1: TPanel;
    g1: TsGauge;
    Timer1: TTimer;
    procedure exExportRecord(Sender: TObject; const DataSet: TDataSet; var AllowExport: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    cualExport: integer;
    DevExportingGrid: TcxGrid;
    dsutils: TFDDataSet;
    cierra: Boolean;
    procedure ExportDataSet;
    procedure ExportDev;
    procedure EjecutaFile(aPath: string);
    function KillProcess(ExeFileName: string): integer;
  end;

{var
  frmExcelExport: TfrmExcelExport;}

procedure ExcelExport(DS: TFDDataSet; DevGrid: TcxGrid);

implementation

{$R *.dfm}
procedure ExcelExport(DS: TFDDataSet; DevGrid: TcxGrid);
begin
  with TfrmExcelExport.Create(nil) do
  try
    if DS <> nil then
    begin
      dsutils := DS;
      cualExport := 0;
    end;
    if DevGrid <> nil then
    begin
      DevExportingGrid := DevGrid;
      cualExport := 1;
    end;
    cierra := False;
    ShowModal;
  finally
    Free;
  end;
end;


{ TfrmExcelExport }

procedure TfrmExcelExport.EjecutaFile(aPath: string);
begin
  ShellExecute(Handle, nil, PChar(aPath), '', '', SW_SHOWNORMAL);
end;

procedure TfrmExcelExport.exExportRecord(Sender: TObject; const DataSet: TDataSet; var AllowExport: Boolean);

  procedure TrimAppMemorySize;
  var
    MainHandle: THandle;
  begin
    try
      MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID);
      SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF);
      CloseHandle(MainHandle);
    except
    end;
    Application.ProcessMessages;
  end;

begin
  g1.Progress := g1.Progress + 1;
  g1.Update;
  TrimAppMemorySize;
end;

procedure TfrmExcelExport.ExportDataSet;
var
  bm: TBookmark;
begin
  if SD.Execute then
    if Trim(SD.FileName) <> '' then
    begin
      Screen.Cursor := crSQLWait;
      ex.SaveToFileName := SD.FileName;
      ex.ExcelVisible := False;
      g1.MinValue := 0;
      g1.MaxValue := dsutils.RecordCount;
      g1.Progress := 0;
      bm := dsutils.GetBookmark;
      dsutils.DisableControls;
      g1.Visible := True;
      ex.DataSet := dsutils;
      ex.Execute;
      dsutils.GotoBookmark(bm);
      dsutils.EnableControls;
      Screen.Cursor := crDefault;
      try
        KillProcess('EXCEL.EXE');
      except
      end;
      EjecutaFile(SD.FileName);
    end;
  cierra := True;
end;

procedure TfrmExcelExport.ExportDev;
begin
  if SD.Execute then
    if Trim(SD.FileName) <> '' then
    begin
      Panel1.Caption := 'Exportando GRID a MS Excel...';
      Panel1.Update;
      ExportGridToExcel(SD.FileName, DevExportingGrid);
      if FileExists(SD.FileName) then
        EjecutaFile(SD.FileName)
      else
      begin
        EjecutaFile(AnsiReplaceStr(SD.FileName, ExtractFileExt(SD.FileName), '.xls'));
      end;
    end;
  cierra := True;
end;

procedure TfrmExcelExport.FormActivate(Sender: TObject);
begin
  if cualExport = 0 then
    ExportDataSet
  else
    ExportDev;
end;

function TfrmExcelExport.KillProcess(ExeFileName: string): integer;
const
  PROCESS_TERMINATE = $0001;
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  Result := 0;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ExeFileName)) or (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ExeFileName))) then
      Result := Integer(TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure TfrmExcelExport.Timer1Timer(Sender: TObject);
begin
  if cierra then
    Close;
end;

end.

