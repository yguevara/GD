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
  UMetadatosSubserie in '..\UMetadatosSubserie.pas',
  UPruebasEsquemaCarga in 'UPruebasEsquemaCarga.pas',
  UPruebasMetadatosSubserie in 'UPruebasMetadatosSubserie.pas';

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
