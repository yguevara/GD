program SerPerf;

uses
  Vcl.Forms,
  Winapi.Windows,
  UMain in 'UMain.pas' {MAINFORM},
  UHistory in 'UHistory.pas' {frmHistory},
  USplash in 'USplash.pas' {frmSplash},
  UAbout in 'UAbout.pas' {frmAbout},
  UCapaDatos in 'UCapaDatos.pas' {UDM: TDataModule},
  UAutentica in 'UAutentica.pas' {frmAutentica},
  md5 in 'md5.pas',
  USecurityClasss in 'USecurityClasss.pas',
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
  UCL_Especialistas in 'UCL_Especialistas.pas' {frmListEspec};

{$R *.res}

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
  Application.BringToFront;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  frmSplash := TfrmSplash.Create(Application);
  frmSplash.Show;
  frmSplash.Update;
  frmSplash.Label1.Caption := 'Cargando información. Espere...';
  frmSplash.Gauge1.MaxValue := 1;
  frmSplash.Gauge1.MinValue := 0;
  frmSplash.Gauge1.Progress := 0;
  frmSplash.MueveBar(@frmSplash.Gauge1, 1);
  Application.CreateForm(TUDM, UDM);
  Application.CreateForm(TMAINFORM, MAINFORM);
  Sleep(2000);
  frmSplash.Hide;
  frmSplash.Free;
  TrimAppMemorySize;
  Application.Run;
end.

