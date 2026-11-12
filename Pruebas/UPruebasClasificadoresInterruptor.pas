unit UPruebasClasificadoresInterruptor;

{ Interruptor de pantallas clasicas y registro de errores de clasificadores. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasInterruptor = class
  private
    FCarpeta: string;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Clasicos_SinFlag_False;
    [Test]
    procedure Clasicos_ConFlag_True;
    [Test]
    procedure Registrar_CreaArchivoConLaLinea;
    [Test]
    procedure Registrar_AgregaSinBorrar;
    [Test]
    procedure Registrar_CarpetaInexistente_NoLanza;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, UClasificadoresInterruptor;

procedure TPruebasInterruptor.Preparar;
begin
  FCarpeta := IncludeTrailingPathDelimiter(TPath.Combine(TPath.GetTempPath, 'pr_clasif'));
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
  TDirectory.CreateDirectory(FCarpeta);
end;

procedure TPruebasInterruptor.Limpiar;
begin
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
end;

procedure TPruebasInterruptor.Clasicos_SinFlag_False;
begin
  Assert.IsFalse(ClasificadoresClasicos(FCarpeta));
end;

procedure TPruebasInterruptor.Clasicos_ConFlag_True;
begin
  TFile.WriteAllText(FCarpeta + ARCHIVO_CLASIFICADORES_CLASICO, '');
  Assert.IsTrue(ClasificadoresClasicos(FCarpeta));
end;

procedure TPruebasInterruptor.Registrar_CreaArchivoConLaLinea;
var
  Texto: string;
begin
  RegistrarErrorClasificador(FCarpeta, 'fallo de prueba');
  Assert.IsTrue(FileExists(FCarpeta + ARCHIVO_ERRORES_CLASIFICADORES));
  Texto := TFile.ReadAllText(FCarpeta + ARCHIVO_ERRORES_CLASIFICADORES);
  Assert.IsTrue(Pos('fallo de prueba', Texto) > 0);
end;

procedure TPruebasInterruptor.Registrar_AgregaSinBorrar;
var
  Lineas: TArray<string>;
begin
  RegistrarErrorClasificador(FCarpeta, 'uno');
  RegistrarErrorClasificador(FCarpeta, 'dos');
  Lineas := TFile.ReadAllLines(FCarpeta + ARCHIVO_ERRORES_CLASIFICADORES);
  Assert.AreEqual(2, Length(Lineas));
end;

procedure TPruebasInterruptor.Registrar_CarpetaInexistente_NoLanza;
begin
  RegistrarErrorClasificador('Z:\no_existe\x\', 'texto');
  Assert.Pass;
end;

end.
