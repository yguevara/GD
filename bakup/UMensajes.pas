unit UMensajes;

interface

uses
  SysUtils, Classes, Vcl.Dialogs, UITypes, Vcl.Forms, Winapi.Windows;

type
  { Modo de registro (solo para las pruebas automaticas): en lugar de mostrar el mensaje lo anota en Registro como
    «TIPO|Titulo|Mensaje» y responde a Confirmar con RespuestaConfirmar. Con Registro = nil (lo normal) se muestra el mensaje. }
  TMensajes = class
  public
    class var Registro: TStringList;
    class var RespuestaConfirmar: Boolean;
    class procedure ActivarRegistro;
    class procedure DesactivarRegistro;
    class procedure Informacion(const Mensaje: string; const Titulo: string = 'Información');
    class procedure Advertencia(const Mensaje: string; const Titulo: string = 'Advertencia');
    class procedure Error(const Mensaje: string; const Titulo: string = 'Error');
    class procedure Exito(const Mensaje: string; const Titulo: string = 'Operación Exitosa');
    class function  Confirmar(const Mensaje: string; const Titulo: string = 'Confirmación'): Boolean;
  end;

implementation

class procedure TMensajes.ActivarRegistro;
begin
  if Registro = nil then
    Registro := TStringList.Create
  else
    Registro.Clear;
  RespuestaConfirmar := True;
end;

class procedure TMensajes.DesactivarRegistro;
begin
  FreeAndNil(Registro);
end;

class procedure TMensajes.Informacion(const Mensaje, Titulo: string);
begin
  if Registro <> nil then
  begin
    Registro.Add('INFORMACION|' + Titulo + '|' + Mensaje);
    Exit;
  end;
  Application.MessageBox(PChar(Mensaje), PChar(Titulo), MB_OK or MB_ICONINFORMATION);
end;

class procedure TMensajes.Advertencia(const Mensaje, Titulo: string);
begin
  if Registro <> nil then
  begin
    Registro.Add('ADVERTENCIA|' + Titulo + '|' + Mensaje);
    Exit;
  end;
  Application.MessageBox(PChar(Mensaje), PChar(Titulo), MB_OK or MB_ICONWARNING);
end;

class procedure TMensajes.Error(const Mensaje, Titulo: string);
begin
  if Registro <> nil then
  begin
    Registro.Add('ERROR|' + Titulo + '|' + Mensaje);
    Exit;
  end;
  Application.MessageBox(PChar(Mensaje), PChar(Titulo), MB_OK or MB_ICONERROR);
end;

class procedure TMensajes.Exito(const Mensaje, Titulo: string);
begin
  if Registro <> nil then
  begin
    Registro.Add('EXITO|' + Titulo + '|' + Mensaje);
    Exit;
  end;
  Application.MessageBox(PChar(Mensaje), PChar(Titulo), MB_OK or MB_ICONINFORMATION);
end;

class function TMensajes.Confirmar(const Mensaje, Titulo: string): Boolean;
begin
  if Registro <> nil then
  begin
    Registro.Add('CONFIRMAR|' + Titulo + '|' + Mensaje);
    Result := RespuestaConfirmar;
    Exit;
  end;
  Result := Application.MessageBox(
    PChar(Mensaje),
    PChar(Titulo),
    MB_YESNO or MB_ICONQUESTION
  ) = IDYES;
end;

end.
