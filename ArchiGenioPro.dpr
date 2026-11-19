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
  UEsquemaAlmacen in 'UEsquemaAlmacen.pas',
  UEsquemaCarga in 'UEsquemaCarga.pas',
  UEsquemaTrazabilidad in 'UEsquemaTrazabilidad.pas',
  UEsquemaProcesos in 'UEsquemaProcesos.pas',
  UProceso in 'UProceso.pas',
  UNumeracion in 'UNumeracion.pas',
  UCandados in 'UCandados.pas',
  UAutorizacion in 'UAutorizacion.pas',
  UProcesosDatos in 'UProcesosDatos.pas',
  UProcesosInterruptor in 'UProcesosInterruptor.pas',
  UTransferidos in 'UTransferidos.pas',
  UDepuracionReglas in 'UDepuracionReglas.pas',
  UEliminados in 'UEliminados.pas',
  UDepuracionDatos in 'UDepuracionDatos.pas',
  UDepuracionActa in 'UDepuracionActa.pas',
  UDepuracionImpresos in 'UDepuracionImpresos.pas',
  UDepuracionFicheros in 'UDepuracionFicheros.pas',
  UDepuracionMigracion in 'UDepuracionMigracion.pas',
  UTransferenciasMigracion in 'UTransferenciasMigracion.pas',
  UDepuracionForm in 'UDepuracionForm.pas' {frmDepuracionNueva},
  UPrestadosSql in 'UPrestadosSql.pas',
  UPrestamosReglas in 'UPrestamosReglas.pas',
  UPrestamosDatos in 'UPrestamosDatos.pas',
  UPrestamosMigracion in 'UPrestamosMigracion.pas',
  UOpcionNodo in 'UOpcionNodo.pas',
  UProcesoPintura in 'UProcesoPintura.pas',
  UPantallaProceso in 'UPantallaProceso.pas',
  UPrestamosForm in 'UPrestamosForm.pas' {frmPrestamos},
  UImpresosComun in 'UImpresosComun.pas',
  UPrestamosImpresos in 'UPrestamosImpresos.pas',
  UTransferenciasReglas in 'UTransferenciasReglas.pas',
  UTransferenciasDatos in 'UTransferenciasDatos.pas',
  UTransferenciasForm in 'UTransferenciasForm.pas' {frmTransferenciasNuevo},
  UTransferenciasImpresos in 'UTransferenciasImpresos.pas',
  UTrazabilidad in 'UTrazabilidad.pas',
  UTrazabilidadDatos in 'UTrazabilidadDatos.pas',
  UHistoriaDocumento in 'UHistoriaDocumento.pas',
  UCargaModelo in 'UCargaModelo.pas',
  UMetadatosSubserie in 'UMetadatosSubserie.pas',
  UCargaDocumento in 'UCargaDocumento.pas',
  UCargaLote in 'UCargaLote.pas',
  UPantallaCarga in 'UPantallaCarga.pas',
  USecretoServidor in 'USecretoServidor.pas',
  UAlmacenFicheros in 'UAlmacenFicheros.pas',
  USigV4 in 'USigV4.pas',
  UAlmacenS3 in 'UAlmacenS3.pas',
  UAlmacenFtp in 'UAlmacenFtp.pas',
  UAlmacenServidor in 'UAlmacenServidor.pas',
  UProgresoTransferencia in 'UProgresoTransferencia.pas',
  UMigracionFicheros in 'UMigracionFicheros.pas',
  UMigracionPantalla in 'UMigracionPantalla.pas',
  UServidorS3Dialogo in 'UServidorS3Dialogo.pas',
  UExpedienteCompleto in 'UExpedienteCompleto.pas',
  UAlcanceDatos in 'UAlcanceDatos.pas',
  UTopografia in 'UTopografia.pas',
  UAsignacionDatos in 'UAsignacionDatos.pas',
  UAsignacionIconos in 'UAsignacionIconos.pas',
  UAsignacionNodos in 'UAsignacionNodos.pas',
  UBusqueda in 'UBusqueda.pas',
  UBusquedaDatos in 'UBusquedaDatos.pas',
  UBusquedaDocumentos in 'UBusquedaDocumentos.pas',
  UTema in 'UTema.pas',
  UDocumentoVista in 'UDocumentoVista.pas',
  UDocumentoVistaDatos in 'UDocumentoVistaDatos.pas',
  UPanelDocumentos in 'UPanelDocumentos.pas',
  UListaPropiedades in 'UListaPropiedades.pas',
  UBarraTrabajo in 'UBarraTrabajo.pas',
  UBloqueAccion in 'UBloqueAccion.pas',
  UPanelLateral in 'UPanelLateral.pas',
  UPanelDocumento in 'UPanelDocumento.pas',
  UVistaUbicacion in 'UVistaUbicacion.pas',
  UVisorContenido in 'UVisorContenido.pas',
  URecepcionArchivos in 'URecepcionArchivos.pas',
  UAgregarFicheros in 'UAgregarFicheros.pas',
  UDiagnosticoErrores in 'UDiagnosticoErrores.pas',
  UEdicionDocumento in 'UEdicionDocumento.pas',
  UFormularioDocumento in 'UFormularioDocumento.pas',
  UIconos in 'UIconos.pas',
  UShellPrincipal in 'UShellPrincipal.pas',
  UAparienciaLegacy in 'UAparienciaLegacy.pas',
  UAutenticacion in 'UAutenticacion.pas',
  UMensajes in 'UMensajes.pas',
  UClasificadoresInterruptor in 'UClasificadoresInterruptor.pas',
  UClasificadorEstado in 'UClasificadorEstado.pas',
  UErroresCampo in 'UErroresCampo.pas',
  UPalabrasReservadas in 'UPalabrasReservadas.pas',
  UVariablesDatos in 'UVariablesDatos.pas',
  USeriesDatos in 'USeriesDatos.pas',
  UVariablesSesion in 'UVariablesSesion.pas',
  UVariablesEditor in 'UVariablesEditor.pas',
  UCLSeriesForm in 'UCLSeriesForm.pas',
  UServidoresDatos in 'UServidoresDatos.pas',
  UArchivosDatos in 'UArchivosDatos.pas',
  UImagenes in 'UImagenes.pas',
  UInicioDatos in 'UInicioDatos.pas',
  UInicioNodo in 'UInicioNodo.pas',
  UClasificadorBase in 'UClasificadorBase.pas',
  UCLServidoresForm in 'UCLServidoresForm.pas',
  UCLArchivosForm in 'UCLArchivosForm.pas',
  UTiempos in 'UTiempos.pas',
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
  TiemposIniciar;
  Application.Initialize;
  TiemposMarca('Application.Initialize');
  InstalarDiagnosticoErrores;
  VERSION := 'PROFESIONAL';
//  VERSION := 'BÁSICA';
  Application.MainFormOnTaskbar := True;
  cad := 'Versión: ' + Sto_GetFmtFileVersion(Application.ExeName, '%.d.%.d.%.d.%.4d');
  build := Sto_GetFmtFileVersion(Application.ExeName, '%.d.%.d.%.d.%.4d');
 // TStyleManager.TrySetStyle('Windows10 Blue');
  // Estilo VCL claro, plano y neutro (Light). El color de la aplicacion lo da UTema
  // (paleta E). Si Light no se pudiera cargar se usa Windows10, tambien neutro.
  if not TStyleManager.TrySetStyle('Light') then
    TStyleManager.TrySetStyle('Windows10');
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
    frmSplash.Paso('Leyendo la configuración...', 1);
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
      frmSplash.Paso('Conectando con la base de datos...', 0);
      Application.CreateForm(TUDM, UDM);
      frmSplash.Paso('Cargando la interfaz...', 1);
  VersionProgram := cad;
      buildprogram := build;
      if not CAPP then
        Application.CreateForm(TMAIN, MAIN);
      TiemposMarca('dpr: MAIN creado');
        frmSplash.Paso('Listo', 2);
    end
    else
    begin
      Configurasys(True);
      if FileExists(AppPath + 'config.ini') then
      begin
        frmSplash.Paso('Conectando con la base de datos...', 0);
        Application.CreateForm(TUDM, UDM);
        frmSplash.Paso('Cargando la interfaz...', 1);
        VersionProgram := cad;
        buildprogram := build;
        if not CAPP then
          Application.CreateForm(TMAIN, MAIN);
          frmSplash.Paso('Listo', 2);
      end;
    end;
    if not CAPP then
    begin
      // El splash NO se cierra aqui: sigue visible mientras TMAIN termina de cargar
      // en FormShow (que llama a SplashCerrar), sin hueco entre splash y ventana.
      SplashEstado('Preparando la pantalla principal...');
      TrimAppMemorySize;
      TiemposMarca('dpr: antes de Application.Run');
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

