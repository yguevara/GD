unit UDiagnosticoErrores;

{ Registra los errores no controlados de la aplicacion en errores_inesperados.log
  (junto al ejecutable) con la pila de llamadas en direcciones: con el archivo
  .map del mismo ejecutable cada direccion se traduce a su unidad y linea. No
  cambia lo que ve el usuario: el mensaje de siempre se muestra igual. Sin VCL
  propia mas alla de Application. Codigo en ASCII. }

interface

procedure InstalarDiagnosticoErrores;

implementation

uses
  System.SysUtils, System.Classes, Winapi.Windows, Vcl.Forms;

const
  MAX_MARCOS = 24;

type
  TPila = record
    N: Integer;
    Dir: array[0..MAX_MARCOS - 1] of Pointer;
  end;
  PPila = ^TPila;

function RtlCaptureStackBackTrace(FramesToSkip, FramesToCapture: DWORD;
  BackTrace: Pointer; BackTraceHash: PDWORD): WORD; stdcall;
  external 'kernel32.dll' name 'RtlCaptureStackBackTrace';

function CapturaPila(P: System.PExceptionRecord): Pointer;
var
  Pila: PPila;
begin
  New(Pila);
  Pila^.N := RtlCaptureStackBackTrace(0, MAX_MARCOS, @Pila^.Dir[0], nil);
  Result := Pila;
end;

function PilaATexto(Info: Pointer): string;
var
  Pila: PPila;
  I: Integer;
begin
  Result := '';
  if Info = nil then
    Exit;
  Pila := PPila(Info);
  for I := 0 to Pila^.N - 1 do
    Result := Result + Format('%.8x ', [NativeUInt(Pila^.Dir[I])]);
end;

procedure LiberaPila(Info: Pointer);
begin
  if Info <> nil then
    Dispose(PPila(Info));
end;

type
  TRegistrador = class
    procedure AlErrorNoControlado(Sender: TObject; E: Exception);
  end;

var
  GRegistrador: TRegistrador;

procedure TRegistrador.AlErrorNoControlado(Sender: TObject; E: Exception);
var
  L: TStringList;
  Ruta: string;
begin
  try
    Ruta := ExtractFilePath(ParamStr(0)) + 'errores_inesperados.log';
    L := TStringList.Create;
    try
      if FileExists(Ruta) then
        L.LoadFromFile(Ruta);
      L.Add(DateTimeToStr(Now) + ' ' + E.ClassName + ': ' + E.Message);
      L.Add('  pila: ' + E.StackTrace);
      if Sender <> nil then
        L.Add('  origen: ' + Sender.ClassName);
      L.SaveToFile(Ruta);
    finally
      L.Free;
    end;
  except
    // registrar nunca debe causar otro error
  end;
  Application.ShowException(E);
end;

procedure InstalarDiagnosticoErrores;
begin
  Exception.GetExceptionStackInfoProc := CapturaPila;
  Exception.GetStackInfoStringProc := PilaATexto;
  Exception.CleanUpStackInfoProc := LiberaPila;
  GRegistrador := TRegistrador.Create;
  Application.OnException := GRegistrador.AlErrorNoControlado;
end;

end.
