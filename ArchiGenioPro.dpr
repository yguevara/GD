program ArchiGenioPro;

uses
  Vcl.Forms,
  Winapi.Windows,
  System.SysUtils,
  UMain in 'UMain.pas' {MAINFORM},
  UHistory in 'UHistory.pas' {frmHistory},
  USplash in 'USplash.pas' {frmSplash},
  UAbout in 'UAbout.pas' {frmAbout},
  UCapaDatos in 'UCapaDatos.pas' {UDM: TDataModule},
  UAutentica in 'UAutentica.pas' {frmAutentica},
  md5 in 'md5.pas',
  UUserGest in 'UUserGest.pas' {frmGestUser},
  UChangePass in 'UChangePass.pas' {frmChangePass},
  UNewUser in 'UNewUser.pas' {frmNewUser},
  UDocManagement in 'UDocManagement.pas' {frmDoc},
  UCLSeriesDocumentales in 'UCLSeriesDocumentales.pas' {frmCLSeries},
  UCLDestino in 'UCLDestino.pas' {frmCLDestino},
  UCLAcceso in 'UCLAcceso.pas' {frmCLAcceso},
  UCLSoporte in 'UCLSoporte.pas' {frmCLSoporte},
  UCLFrecuencia in 'UCLFrecuencia.pas' {frmCLFrecuencia},
  UCLTipoDoc in 'UCLTipoDoc.pas' {frmCLTipoDoc},
  UNodeAsist in 'UNodeAsist.pas' {frmGestionarNodos},
  UCLFtpServer in 'UCLFtpServer.pas' {frmListFTPServer},
  UCLProcesos in 'UCLProcesos.pas' {frmCLprocesos},
  UManagementPDFFile in 'UManagementPDFFile.pas' {frmManagementProc},
  UCLRepActArchiv in 'UCLRepActArchiv.pas' {frmRepActArch},
  UGestEstruct in 'UGestEstruct.pas' {frmEstructura},
  UCategoria_Ocupa in 'UCategoria_Ocupa.pas' {frmCatOcupa},
  UCL_Cargo in 'UCL_Cargo.pas' {frmCLCargo},
  UCLFacultades in 'Clasificadores\UCLFacultades.pas' {frmCLFacultades},
  UCLFunciones in 'Clasificadores\UCLFunciones.pas' {frmCLFunciones},
  UViewFunciones in 'UViewFunciones.pas' {frmSelectFuncionG},
  UCLVariables in 'UCLVariables.pas' {frmVariables},
  UVarVirtualVar in 'UVarVirtualVar.pas' {frmVarVirtualVar},
  UMangementArch in 'UMangementArch.pas' {frmManagemetArch},
  USeriesDisp in 'USeriesDisp.pas' {frmSeriesDisp},
  UCL_Especialistas in 'UCL_Especialistas.pas' {frmListEspec},
  UEntrada in 'UEntrada.pas' {FEntrada},
  UFVariablesAyuda in 'UFVariablesAyuda.pas' {FVariablesAyuda},
  UManagementFileSeries in 'UManagementFileSeries.pas' {frmManagementFile},
  UICSeriesDocumentales in 'UICSeriesDocumentales.pas' {frmICSeriesDocumentales},
  UCLTipoEstructura in 'UCLTipoEstructura.pas' {frmTipoEstructura},
  UCLVarProject in 'UCLVarProject.pas' {frmVarProject},
  UCL_Depositos in 'UCL_Depositos.pas' {frmDeposito},
  USecurityClasss in 'USecurityClasss.pas',
  UVeditor in 'UVeditor.pas' {FVeditor},
  UVarVirtualSeriesD in 'UVarVirtualSeriesD.pas' {frmVariablesVirtSeries},
  UExcelExport in 'UExcelExport.pas' {frmExcelExport},
  UClTipoObjeto in 'UClTipoObjeto.pas' {frmTipoObjeto},
  Vcl.Themes,
  Vcl.Styles,
  UManagementNode in 'UManagementNode.pas' {frmAddNode},
  USystemMsg in 'USystemMsg.pas' {frmsystemMSG},
  UAddNewNode in 'UAddNewNode.pas' {frmNewNode},
  UNodeProperties in 'UNodeProperties.pas' {frmPropiedadesNodo},
  UMAINFORM in 'UMAINFORM.pas' {MAIN},
  UCL_Expediente in 'UCL_Expediente.pas' {frmExpediente},
  UCL_TiposExp in 'UCL_TiposExp.pas' {frmTiposExp};

{$R *.res}
VAR
  cad:string;

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

function Sto_GetFmtFileVersion(const FileName: String = '';
  const Fmt: String = '%d.%d.%d.%d'): String;
var
  sFileName: String;
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
  Application.BringToFront;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;                                       //%.d.
  cad:='Versión: '+Sto_GetFmtFileVersion(Application.ExeName, '%.d.%.d.%.d.%.4d');
 // TStyleManager.TrySetStyle('Windows10 Blue');
  TStyleManager.TrySetStyle('Metropolis UI Blue');
  Application.Title := 'ArchiGenioPro';
  frmSplash := TfrmSplash.Create(Application);
  frmSplash.lblBuild.Caption:=cad;
  frmSplash.Show;
  frmSplash.Update;
  frmSplash.Label1.Caption := 'Cargando información. Espere...';
  frmSplash.Gauge1.MaxValue := 1;
  frmSplash.Gauge1.MinValue := 0;
  frmSplash.Gauge1.Progress := 0;
  frmSplash.MueveBar(@frmSplash.Gauge1, 1);
  Application.CreateForm(TUDM, UDM);
  // Application.CreateForm(TMAINFORM, MAINFORM);
  // Application.CreateForm(TMAINFORM, MAINFORM);
  Application.CreateForm(TMAIN, MAIN);
  VersionProgram:=cad;
  //Application.CreateForm(TMAINFORM, MAINFORM);
  //Application.CreateForm(TfrmManagementFile, frmManagementFile);
  Sleep(2000);
  frmSplash.Hide;
  frmSplash.Free;
  TrimAppMemorySize;
  Application.Run;
end.

