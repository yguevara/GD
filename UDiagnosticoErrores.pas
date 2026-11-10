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
  MAX_MARCOS = 80;

type
  TPila = record
    N: Integer;
    Dir: array[0..MAX_MARCOS - 1] of Pointer;
  end;
  PPila = ^TPila;

function CapturaPila(P: System.PExceptionRecord): Pointer;
var
  Pila: PPila;
  Sp: PNativeUInt;
  Fin: NativeUInt;
  V: NativeUInt;
  Inicio, Largo: NativeUInt;
  B: PByte;
begin
  New(Pila);
  Pila^.N := 0;
  // Recorrido crudo de la pila: se toman los valores que parecen direcciones de
  // retorno dentro del codigo del ejecutable (precedidas de una instruccion CALL).
  Inicio := NativeUInt(HInstance) + $1000;
  Largo := $A00000;
  Sp := @Pila;
  Fin := NativeUInt(Sp) + 65536;
  try
    while (NativeUInt(Sp) < Fin) and (Pila^.N < MAX_MARCOS) do
    begin
      V := Sp^;
      if (V > Inicio + 8) and (V < Inicio + Largo) then
      begin
        B := PByte(V - 5);
        if (B^ = $E8) or (PByte(V - 2)^ = $FF) or (PByte(V - 3)^ = $FF) or (PByte(V - 6)^ = $FF) then
        begin
          Pila^.Dir[Pila^.N] := Pointer(V);
          Inc(Pila^.N);
        end;
      end;
      Inc(Sp);
    end;
  except
    // fin de la pila legible
  end;
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
