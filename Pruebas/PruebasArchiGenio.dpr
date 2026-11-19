program PruebasArchiGenio;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  UPruebaHumo in 'UPruebaHumo.pas',
  UAlcance in '..\UAlcance.pas',
  UEsquemaAlcance in '..\UEsquemaAlcance.pas',
  UPruebasAlcance in 'UPruebasAlcance.pas',
  UPruebasEsquema in 'UPruebasEsquema.pas',
  UAlcanceDatos in '..\UAlcanceDatos.pas',
  UPruebasAlcanceDatos in 'UPruebasAlcanceDatos.pas',
  UTopografia in '..\UTopografia.pas',
  UPruebasTopografia in 'UPruebasTopografia.pas',
  UAsignacionDatos in '..\UAsignacionDatos.pas',
  UPruebasAsignacion in 'UPruebasAsignacion.pas',
  UAutenticacion in '..\UAutenticacion.pas',
  UPruebasAutenticacion in 'UPruebasAutenticacion.pas',
  UClasificadoresInterruptor in '..\UClasificadoresInterruptor.pas',
  UPruebasClasificadoresInterruptor in 'UPruebasClasificadoresInterruptor.pas',
  UClasificadorEstado in '..\UClasificadorEstado.pas',
  UPruebasClasificadorEstado in 'UPruebasClasificadorEstado.pas',
  UErroresCampo in '..\UErroresCampo.pas',
  UPalabrasReservadas in '..\UPalabrasReservadas.pas',
  UPruebasPalabrasReservadas in 'UPruebasPalabrasReservadas.pas',
  UVariablesDatos in '..\UVariablesDatos.pas',
  USeriesDatos in '..\USeriesDatos.pas',
  UVariablesSesion in '..\UVariablesSesion.pas',
  UVariablesEditor in '..\UVariablesEditor.pas',
  UPruebasVariablesEditor in 'UPruebasVariablesEditor.pas',
  UPruebasVariablesSesion in 'UPruebasVariablesSesion.pas',
  UPruebasSeriesDatos in 'UPruebasSeriesDatos.pas',
  UPruebasVariablesDatos in 'UPruebasVariablesDatos.pas',
  UServidoresDatos in '..\UServidoresDatos.pas',
  UPruebasServidoresDatos in 'UPruebasServidoresDatos.pas',
  UArchivosDatos in '..\UArchivosDatos.pas',
  UPruebasArchivosDatos in 'UPruebasArchivosDatos.pas',
  UImagenes in '..\UImagenes.pas',
  UPruebasImagenes in 'UPruebasImagenes.pas',
  UInicioDatos in '..\UInicioDatos.pas',
  UPruebasInicioDatos in 'UPruebasInicioDatos.pas',
  UInicioNodo in '..\UInicioNodo.pas',
  UPruebasPanelInicio in 'UPruebasPanelInicio.pas',
  UBusqueda in '..\UBusqueda.pas',
  UBusquedaDatos in '..\UBusquedaDatos.pas',
  UPruebasBusqueda in 'UPruebasBusqueda.pas',
  UPruebasBusquedaDatos in 'UPruebasBusquedaDatos.pas',
  UTema in '..\UTema.pas',
  UPruebasTema in 'UPruebasTema.pas',
  UDocumentoVista in '..\UDocumentoVista.pas',
  UPruebasDocumentoVista in 'UPruebasDocumentoVista.pas',
  UDocumentoVistaDatos in '..\UDocumentoVistaDatos.pas',
  UPruebasDocumentoVistaDatos in 'UPruebasDocumentoVistaDatos.pas',
  USigV4 in '..\USigV4.pas',
  UAlmacenFicheros in '..\UAlmacenFicheros.pas',
  UPruebasSigV4 in 'UPruebasSigV4.pas',
  UAlmacenS3 in '..\UAlmacenS3.pas',
  UPruebasAlmacenS3 in 'UPruebasAlmacenS3.pas',
  USecretoServidor in '..\USecretoServidor.pas',
  UPruebasSecreto in 'UPruebasSecreto.pas',
  UEsquemaAlmacen in '..\UEsquemaAlmacen.pas',
  UPruebasEsquemaAlmacen in 'UPruebasEsquemaAlmacen.pas',
  UAlmacenFtp in '..\UAlmacenFtp.pas',
  UAlmacenServidor in '..\UAlmacenServidor.pas',
  UPruebasAlmacenServidor in 'UPruebasAlmacenServidor.pas',
  UMigracionFicheros in '..\UMigracionFicheros.pas',
  UPruebasMigracion in 'UPruebasMigracion.pas',
  UExpedienteCompleto in '..\UExpedienteCompleto.pas',
  UPruebasExpedienteCompleto in 'UPruebasExpedienteCompleto.pas',
  UCargaModelo in '..\UCargaModelo.pas',
  UPruebasCargaModelo in 'UPruebasCargaModelo.pas',
  UEsquemaCarga in '..\UEsquemaCarga.pas',
  UEsquemaTrazabilidad in '..\UEsquemaTrazabilidad.pas',
  UTrazabilidad in '..\UTrazabilidad.pas',
  UTrazabilidadDatos in '..\UTrazabilidadDatos.pas',
  UMetadatosSubserie in '..\UMetadatosSubserie.pas',
  UPruebasEsquemaCarga in 'UPruebasEsquemaCarga.pas',
  UPruebasEsquemaTrazabilidad in 'UPruebasEsquemaTrazabilidad.pas',
  UPruebasTrazabilidad in 'UPruebasTrazabilidad.pas',
  UPruebasTrazabilidadDatos in 'UPruebasTrazabilidadDatos.pas',
  UPruebasPanelDocumentos in 'UPruebasPanelDocumentos.pas',
  UPruebasBarraTrabajo in 'UPruebasBarraTrabajo.pas',
  UPruebasBloqueAccion in 'UPruebasBloqueAccion.pas',
  UPruebasPanelLateral in 'UPruebasPanelLateral.pas',
  UPruebasPanelDocumento in 'UPruebasPanelDocumento.pas',
  UPruebasVisorContenido in 'UPruebasVisorContenido.pas',
  UPruebasRecepcionArchivos in 'UPruebasRecepcionArchivos.pas',
  UPruebasAgregarFicheros in 'UPruebasAgregarFicheros.pas',
  UPruebasEdicionDocumento in 'UPruebasEdicionDocumento.pas',
  UPruebasFormularioDocumento in 'UPruebasFormularioDocumento.pas',
  UPruebasMetadatosSubserie in 'UPruebasMetadatosSubserie.pas',
  UCargaDocumento in '..\UCargaDocumento.pas',
  UCargaLote in '..\UCargaLote.pas',
  UPruebasCargaDocumento in 'UPruebasCargaDocumento.pas',
  UProceso in '..\UProceso.pas',
  UPruebasProceso in 'UPruebasProceso.pas',
  UNumeracion in '..\UNumeracion.pas',
  UPruebasNumeracion in 'UPruebasNumeracion.pas',
  UCandados in '..\UCandados.pas',
  UPruebasCandados in 'UPruebasCandados.pas',
  UAutorizacion in '..\UAutorizacion.pas',
  UPruebasAutorizacion in 'UPruebasAutorizacion.pas',
  UEsquemaProcesos in '..\UEsquemaProcesos.pas',
  UPruebasEsquemaProcesos in 'UPruebasEsquemaProcesos.pas',
  UProcesosDatos in '..\UProcesosDatos.pas',
  UPruebasProcesosDatos in 'UPruebasProcesosDatos.pas',
  UProcesosInterruptor in '..\UProcesosInterruptor.pas',
  UPruebasProcesosInterruptor in 'UPruebasProcesosInterruptor.pas',
  UPrestamosReglas in '..\UPrestamosReglas.pas',
  UPruebasPrestamosReglas in 'UPruebasPrestamosReglas.pas',
  UPrestamosDatos in '..\UPrestamosDatos.pas',
  UPruebasPrestamosDatos in 'UPruebasPrestamosDatos.pas',
  UPrestamosMigracion in '..\UPrestamosMigracion.pas',
  UPruebasPrestamosMigracion in 'UPruebasPrestamosMigracion.pas',
  UTransferidos in '..\UTransferidos.pas',
  UPruebasApoyoTransferido in 'UPruebasApoyoTransferido.pas',
  UPruebasTransferidos in 'UPruebasTransferidos.pas',
  UPrestadosSql in '..\UPrestadosSql.pas',
  UPruebasPrestadosSql in 'UPruebasPrestadosSql.pas',
  UProcesoPintura in '..\UProcesoPintura.pas',
  UPruebasProcesoPintura in 'UPruebasProcesoPintura.pas',
  UTransferenciasReglas in '..\UTransferenciasReglas.pas',
  UPruebasTransferenciasReglas in 'UPruebasTransferenciasReglas.pas',
  UDepuracionReglas in '..\UDepuracionReglas.pas',
  UPruebasDepuracionReglas in 'UPruebasDepuracionReglas.pas',
  UEliminados in '..\UEliminados.pas',
  UPruebasApoyoDepuracion in 'UPruebasApoyoDepuracion.pas',
  UPruebasEliminados in 'UPruebasEliminados.pas',
  UDepuracionDatos in '..\UDepuracionDatos.pas',
  UPruebasDepuracionDatos in 'UPruebasDepuracionDatos.pas',
  UDepuracionActa in '..\UDepuracionActa.pas',
  UDepuracionFicheros in '..\UDepuracionFicheros.pas',
  UDepuracionMigracion in '..\UDepuracionMigracion.pas',
  UPruebasDepuracionActa in 'UPruebasDepuracionActa.pas',
  UPruebasDepuracionFicheros in 'UPruebasDepuracionFicheros.pas',
  UPruebasDepuracionMigracion in 'UPruebasDepuracionMigracion.pas',
  UTransferenciasDatos in '..\UTransferenciasDatos.pas',
  UPruebasTransferenciasDatos in 'UPruebasTransferenciasDatos.pas',
  UOpcionNodo in '..\UOpcionNodo.pas',
  UPruebasOpcionNodo in 'UPruebasOpcionNodo.pas';

var
  Corredor: ITestRunner;
  Resultados: IRunResults;
  LogConsola: ITestLogger;
  LogNUnit: ITestLogger;

begin
  try
    Corredor := TDUnitX.CreateRunner;
    Corredor.UseRTTI := True;
    Corredor.FailsOnNoAsserts := False;

    LogConsola := TDUnitXConsoleLogger.Create(True);
    Corredor.AddLogger(LogConsola);
    LogNUnit := TDUnitXXMLNUnitFileLogger.Create('.\resultados_pruebas.xml');
    Corredor.AddLogger(LogNUnit);

    Resultados := Corredor.Execute;

    if not Resultados.AllPassed then
      System.ExitCode := EXIT_ERRORS;
  except
    on E: Exception do
    begin
      System.Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := EXIT_ERRORS;
    end;
  end;
end.
