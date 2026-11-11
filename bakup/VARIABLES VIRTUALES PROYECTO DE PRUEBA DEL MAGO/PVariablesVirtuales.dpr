program PVariablesVirtuales;

uses
  Vcl.Forms,
  UVarVirtual in 'UVarVirtual.pas' {FVarVirtual},
  UCapaDatos in 'UCapaDatos.pas' {DM: TDataModule},
  UEntrada in 'UEntrada.pas' {FEntrada},
  UFVariablesAyuda in 'UFVariablesAyuda.pas' {FVariablesAyuda};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFVarVirtual, FVarVirtual);
  Application.CreateForm(TDM, DM);
 // Application.CreateForm(TFVariablesAyuda, FVariablesAyuda);
  // Application.CreateForm(TFEntrada, FEntrada);
  Application.Run;
end.
