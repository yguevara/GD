unit UPruebasVisorContenido;

{ Visor del contenido (VCL + ExpressPDFViewer). Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasVisorContenido = class
  public
    [Test]
    procedure Visor_SinArchivo_MuestraElMensaje;
    [Test]
    procedure Visor_Limpiar_BorraElDocumento;
    [Test]
    procedure Visor_SepararYReincorporar_ConservaElVisorYElEstado;
    [Test]
    procedure Visor_DestruidoEstandoSeparado_NoFalla;
    [Test]
    procedure Visor_CerrarLaVentanaAparte_ReincorporaElVisor;
    [Test]
    procedure Visor_SinDocumento_NoSeSepara;
    [Test]
    procedure Visor_MostrarMensajeConVentanaAparte_VuelveALaAplicacion;
  end;

implementation

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls,
  UVisorContenido;

{ PDF minimo valido de una pagina en blanco, con su tabla de referencias. }
function CrearPdfPrueba: string;
var
  S: TStringBuilder;
  Offs: array[1..3] of Integer;
  XrefPos, I: Integer;
  Cuerpo: TStringList;
begin
  S := TStringBuilder.Create;
  try
    S.Append('%PDF-1.4'#10);
    Offs[1] := S.Length;
    S.Append('1 0 obj'#10'<< /Type /Catalog /Pages 2 0 R >>'#10'endobj'#10);
    Offs[2] := S.Length;
    S.Append('2 0 obj'#10'<< /Type /Pages /Kids [3 0 R] /Count 1 >>'#10'endobj'#10);
    Offs[3] := S.Length;
    S.Append('3 0 obj'#10'<< /Type /Page /Parent 2 0 R /MediaBox [0 0 200 200] >>'#10'endobj'#10);
    XrefPos := S.Length;
    S.Append('xref'#10'0 4'#10'0000000000 65535 f '#10);
    for I := 1 to 3 do
      S.Append(Format('%.10d 00000 n '#10, [Offs[I]]));
    S.Append('trailer'#10'<< /Size 4 /Root 1 0 R >>'#10'startxref'#10);
    S.Append(IntToStr(XrefPos));
    S.Append(#10'%%EOF'#10);
    Result := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) +
      'archigenio_prueba_visor.pdf';
    Cuerpo := TStringList.Create;
    try
      Cuerpo.Text := S.ToString;
      Cuerpo.WriteBOM := False;
      Cuerpo.SaveToFile(Result, TEncoding.ASCII);
    finally
      Cuerpo.Free;
    end;
  finally
    S.Free;
  end;
end;

function NuevoVisor(F: TForm): TVisorContenido;
begin
  F.SetBounds(50, 50, 700, 600);
  Result := TVisorContenido.Create(F);
  Result.Parent := F;
  Result.Align := alClient;
  F.Show;
  Application.ProcessMessages;
end;

procedure TPruebasVisorContenido.Visor_SinArchivo_MuestraElMensaje;
var
  F: TForm;
  V: TVisorContenido;
begin
  F := TForm.CreateNew(nil);
  try
    V := NuevoVisor(F);
    V.Mostrar('C:\no\existe\nada.pdf', 'X');
    Assert.IsTrue(Pos('No se encontro', V.TextoMensaje) > 0);
    Assert.AreEqual('', V.Archivo);
  finally
    F.Free;
  end;
end;

procedure TPruebasVisorContenido.Visor_Limpiar_BorraElDocumento;
var
  F: TForm;
  V: TVisorContenido;
  Pdf: string;
begin
  F := TForm.CreateNew(nil);
  Pdf := CrearPdfPrueba;
  try
    V := NuevoVisor(F);
    V.Mostrar(Pdf, 'A 03.01.02.0003');
    Assert.AreEqual(Pdf, V.Archivo);
    V.Limpiar;
    Assert.AreEqual('', V.Archivo);
    V.MostrarMensaje('Sin contenido');
    Assert.AreEqual('Sin contenido', V.TextoMensaje);
  finally
    F.Free;
    DeleteFile(Pdf);
  end;
end;

procedure TPruebasVisorContenido.Visor_SepararYReincorporar_ConservaElVisorYElEstado;
var
  F: TForm;
  V: TVisorContenido;
  Pdf: string;
  Original: TWinControl;
begin
  F := TForm.CreateNew(nil);
  Pdf := CrearPdfPrueba;
  try
    V := NuevoVisor(F);
    V.Mostrar(Pdf, 'A 03.01.02.0003');
    Original := V.ContenedorDelVisor;
    V.Separar;
    Assert.IsTrue(V.Separado);
    Assert.IsTrue(V.ContenedorDelVisor <> Original, 'el visor esta en otra ventana');
    Assert.AreEqual(Pdf, V.Archivo, 'sigue mostrando el mismo documento');
    V.Reincorporar;
    Application.ProcessMessages;
    Assert.IsFalse(V.Separado);
    Assert.IsTrue(V.ContenedorDelVisor = Original, 'el visor volvio al panel');
  finally
    F.Free;
    DeleteFile(Pdf);
  end;
end;

procedure TPruebasVisorContenido.Visor_DestruidoEstandoSeparado_NoFalla;
var
  F: TForm;
  V: TVisorContenido;
  Pdf: string;
begin
  F := TForm.CreateNew(nil);
  Pdf := CrearPdfPrueba;
  try
    V := NuevoVisor(F);
    V.Mostrar(Pdf, 'X');
    V.Separar;
    Assert.IsTrue(V.Separado);
    // al cerrar la aplicacion el visor se destruye aun separado: sin errores
    F.Free;
    F := nil;
    Application.ProcessMessages;
    Assert.Pass;
  finally
    F.Free;
    DeleteFile(Pdf);
  end;
end;

procedure TPruebasVisorContenido.Visor_CerrarLaVentanaAparte_ReincorporaElVisor;
var
  F: TForm;
  V: TVisorContenido;
  Pdf: string;
  Ventana: TForm;
begin
  F := TForm.CreateNew(nil);
  Pdf := CrearPdfPrueba;
  try
    V := NuevoVisor(F);
    V.Mostrar(Pdf, 'X');
    V.Separar;
    Ventana := V.ContenedorDelVisor as TForm;
    Ventana.Close; // la X de la ventana
    Application.ProcessMessages;
    Assert.IsFalse(V.Separado, 'cerrar la ventana vuelve el visor a la aplicacion');
  finally
    F.Free;
    DeleteFile(Pdf);
  end;
end;

procedure TPruebasVisorContenido.Visor_SinDocumento_NoSeSepara;
var
  F: TForm;
  V: TVisorContenido;
begin
  F := TForm.CreateNew(nil);
  try
    V := NuevoVisor(F);
    V.Separar;
    Assert.IsFalse(V.Separado, 'sin documento no hay nada que separar');
  finally
    F.Free;
  end;
end;

procedure TPruebasVisorContenido.Visor_MostrarMensajeConVentanaAparte_VuelveALaAplicacion;
var
  F: TForm;
  V: TVisorContenido;
  Pdf: string;
begin
  F := TForm.CreateNew(nil);
  Pdf := CrearPdfPrueba;
  try
    V := NuevoVisor(F);
    V.Mostrar(Pdf, 'X');
    V.Separar;
    // cambia a un documento sin PDF: la ventana aparte no queda mostrando el anterior
    V.MostrarMensaje('Este documento no tiene PDF');
    Application.ProcessMessages;
    Assert.IsFalse(V.Separado);
    Assert.AreEqual('Este documento no tiene PDF', V.TextoMensaje);
  finally
    F.Free;
    DeleteFile(Pdf);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasVisorContenido);

end.
