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
  UPruebasBusquedaDatos in 'UPruebasBusquedaDatos.pas';

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
