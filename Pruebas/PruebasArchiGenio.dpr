program PruebasArchiGenio;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  UPruebaHumo in 'UPruebaHumo.pas';

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
