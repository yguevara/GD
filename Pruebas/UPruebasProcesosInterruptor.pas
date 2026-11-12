unit UPruebasProcesosInterruptor;

{ Interruptor de pantallas clasicas de procesos y registro de errores. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasProcesosInterruptor = class
  private
    FCarpeta: string;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SinFlagNoEsClasico;
    [Test]
    procedure ConFlagEsClasico;
    [Test]
    procedure RegistraErrorEnArchivo;
    [Test]
    procedure RegistrarAgregaSinBorrar;
    [Test]
    procedure RegistrarEnCarpetaInexistenteNoLanza;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, UProcesosInterruptor;

procedure TPruebasProcesosInterruptor.Preparar;
begin
  FCarpeta := IncludeTrailingPathDelimiter(TPath.Combine(TPath.GetTempPath, 'pr_procesos'));
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
  TDirectory.CreateDirectory(FCarpeta);
end;

procedure TPruebasProcesosInterruptor.Limpiar;
begin
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
end;

procedure TPruebasProcesosInterruptor.SinFlagNoEsClasico;
begin
  Assert.IsFalse(ProcesosClasicos(FCarpeta));
end;

procedure TPruebasProcesosInterruptor.ConFlagEsClasico;
begin
  TFile.WriteAllText(FCarpeta + ARCHIVO_PROCESOS_CLASICO, '');
  Assert.IsTrue(ProcesosClasicos(FCarpeta));
end;

procedure TPruebasProcesosInterruptor.RegistraErrorEnArchivo;
var
  Texto: string;
begin
  RegistrarErrorProceso(FCarpeta, 'fallo de prueba');
  Assert.IsTrue(FileExists(FCarpeta + ARCHIVO_ERRORES_PROCESOS));
  Texto := TFile.ReadAllText(FCarpeta + ARCHIVO_ERRORES_PROCESOS);
  Assert.IsTrue(Pos('fallo de prueba', Texto) > 0);
end;

procedure TPruebasProcesosInterruptor.RegistrarAgregaSinBorrar;
var
  Lineas: TArray<string>;
begin
  RegistrarErrorProceso(FCarpeta, 'uno');
  RegistrarErrorProceso(FCarpeta, 'dos');
  Lineas := TFile.ReadAllLines(FCarpeta + ARCHIVO_ERRORES_PROCESOS);
  Assert.AreEqual(2, Length(Lineas));
end;

procedure TPruebasProcesosInterruptor.RegistrarEnCarpetaInexistenteNoLanza;
begin
  RegistrarErrorProceso('Z:\no_existe\x\', 'texto');
  Assert.Pass;
end;

end.
