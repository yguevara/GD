program ArchiGenioPro;

uses
  Vcl.Forms,
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  dialogs,
  UHistory in 'UHistory.pas' {frmHistory},
  USplash in 'USplash.pas' {frmSplash},
  UAbout in 'UAbout.pas' {frmAbout},
  UCapaDatos in 'UCapaDatos.pas' {UDM: TDataModule},
  UAlcance in 'UAlcance.pas',
  UEsquemaAlcance in 'UEsquemaAlcance.pas',
  UAlcanceDatos in 'UAlcanceDatos.pas',
  UTopografia in 'UTopografia.pas',
  UAsignacionDatos in 'UAsignacionDatos.pas',
  UAsignacionIconos in 'UAsignacionIconos.pas',
  UAsignacionNodos in 'UAsignacionNodos.pas',
  UBusqueda in 'UBusqueda.pas',
  UBusquedaDatos in 'UBusquedaDatos.pas',
  UBusquedaDocumentos in 'UBusquedaDocumentos.pas',
  UTema in 'UTema.pas',
  UIconos in 'UIconos.pas',
  UAutentica in 'UAutentica.pas' {frmAutentica},
  md5 in 'md5.pas',
  UUserGest in 'UUserGest.pas' {frmGestUser},
  UChangePass in 'UChangePass.pas' {frmChangePass},
  UNewUser in 'UNewUser.pas' {frmNewUser},
  UDocManagement in 'UDocManagement.pas' {frmDoc},
  UCLSeriesDocumentales in 'UCLSeriesDocumentales.pas' {frmCLSeries},
  UCLFtpServer in 'UCLFtpServer.pas' {frmListFTPServer},
  UManagementPDFFile in 'UManagementPDFFile.pas' {frmManagementProc},
  UGestEstruct in 'UGestEstruct.pas' {frmEstructura},
  UMangementArch in 'UMangementArch.pas' {frmManagemetArch},
  UManagementFileSeries in 'UManagementFileSeries.pas' {frmManagementFile},
  UVeditor in 'UVeditor.pas' {FVeditor},
  UExcelExport in 'UExcelExport.pas' {frmExcelExport},
  Vcl.Themes,
  Vcl.Styles,
  USystemMsg in 'USystemMsg.pas' {frmsystemMSG},
  UNodeProperties in 'UNodeProperties.pas' {frmPropiedadesNodo},
  UMAINFORM in 'UMAINFORM.pas' {MAIN},
  uiapp in 'uiapp.pas',
  USysConfig in 'USysConfig.pas' {frmSysConfig},
  UTransferencias in 'UTransferencias.pas' {frmTransferencias},
  UExportImportDocumentSubSeries in 'UExportImportDocumentSubSeries.pas' {frmImportExport},
  UManagementIndex in 'UManagementIndex.pas' {frmIEIndex},
  UNewNodefrm in 'UNewNodefrm.pas' {frmNewNodeform},
  UAdminLog in 'UAdminLog.pas' {frmAdminSysLogs},
  UManagementTrans in 'UManagementTrans.pas' {frmTrans},
  UDepuracion in 'UDepuracion.pas' {frmDepuracion},
  DBTableModifier in 'DBTableModifier.pas',
  UVarVirtualVar in 'UVarVirtualVar.pas' {frmVarVirtualVar},
  UTopoDocActual in 'UTopoDocActual.pas' {frmUbicaDocActual},
  UREditor in 'UREditor.pas' {frmREditor},
  UNodeInfo in 'UNodeInfo.pas' {frmNodeInfo},
  frmTransferencia in 'frmTransferencia.pas' {Form1},
  UPrestamos in 'UPrestamos.pas' {fpRESTAMOS};

{$R *.res}
var
  cad, build: string;
  AppPath: string;
  VERSION, VERSIONLoad: string;
  List: TStringList;

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

function Sto_GetFmtFileVersion(const FileName: string = ''; const Fmt: string = '%d.%d.%d.%d'): string;
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

begin
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ThousandSeparator := ',';
  SetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SDECIMAL, '.');
  SetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_STHOUSAND, ',');
  FormatSettings.ShortDateFormat := 'dd/mm/yyyy';
  FormatSettings.LongDateFormat := 'dddd, dd mmmm yyyy';
//  Application.BringToFront;
  Application.Initialize;
  VERSION := 'PROFESIONAL';
//  VERSION := 'BÁSICA';
  Application.MainFormOnTaskbar := True;
  cad := 'Versión: ' + Sto_GetFmtFileVersion(Application.ExeName, '%.d.%.d.%.d.%.4d');
  build := Sto_GetFmtFileVersion(Application.ExeName, '%.d.%.d.%.d.%.4d');
 // TStyleManager.TrySetStyle('Windows10 Blue');
  TStyleManager.TrySetStyle('Metropolis UI Blue');
//  Application.Title := 'ArchiGenioPro';
  Application.Title := 'ArchiGenio';
  vers := VERSION;
  frmSplash := TfrmSplash.Create(Application);
  versionAprobada := true;
  if VersionAprobada then
  begin
    frmSplash.lblBuild.Caption := cad;
    frmSplash.Show;
    frmSplash.Update; {
    frmSplash.Label1.Caption := 'Cargando información. Espere...';
    frmSplash.Gauge1.MaxValue := 1;
    frmSplash.Gauge1.MinValue := 0;
    frmSplash.Gauge1.Progress := 0;
    frmSplash.MueveBar(@frmSplash.Gauge1, 1);   }
    AppPath := ExtractFilePath(Application.ExeName);
    programver := VERSION;
    if FileExists(AppPath + 'config.ini') then
    begin
      List := tstringlist.Create;
      List.LoadFromFile(AppPath + 'config.ini');
      if List[0] = 'A' then
        VERSIONLoad := 'BÁSICA'
      else
        VERSIONLoad := 'PROFESIONAL';
      if not SameText(VERSIONLoad, VERSION) then
      begin
        DeleteFile(AppPath + 'config.ini');
        Configurasys(True);
      end;
      Application.CreateForm(TUDM, UDM);
  VersionProgram := cad;
      buildprogram := build;
      if not CAPP then
        Application.CreateForm(TMAIN, MAIN);
    end
    else
    begin
      Configurasys(True);
      if FileExists(AppPath + 'config.ini') then
      begin
        Application.CreateForm(TUDM, UDM);
        VersionProgram := cad;
        buildprogram := build;
        if not CAPP then
          Application.CreateForm(TMAIN, MAIN);
      end;
    end;
    if not CAPP then
    begin
      Sleep(2000);
      frmSplash.Hide;
      frmSplash.Free;
      TrimAppMemorySize;
      Application.Run;
    end
    else
      Application.Terminate;
  end
  else
  begin
    MessageDlg('No está autorizado a utilizar esta aplicación por favor contacte con el representante de EMSERGO S.R.L (Telef. 50927003).', mtWarning, [mbOK], 0);
    MessageDlg('La aplicación se cerrará.', mtInformation, [mbOK], 0);
    Application.Terminate;
  end;

end.

