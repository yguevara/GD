unit USplash;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Samples.Gauges, dxGDIPlusClasses,
  Vcl.ExtCtrls, Vcl.StdCtrls, acPNG;

type
  PGauge=^TGauge;
  TfrmSplash = class(TForm)
    Gauge1: TGauge;
    Label1: TLabel;
    Image1: TImage;
    lblBuild: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Inici(aBAR:PGauge; Min, Max:integer);
    procedure MueveBar(aBAR:PGauge; increment:integer);
  end;

var
  frmSplash: TfrmSplash;

implementation

{$R *.dfm}

{ TfrmSplash }

procedure TfrmSplash.FormCreate(Sender: TObject);
begin
  Gauge1.MaxValue:=4;
  Gauge1.MinValue:=0;
  Gauge1.Progress:=0;
end;

procedure TfrmSplash.FormShow(Sender: TObject);
begin
  Application.BringToFront;
  BringToFront;
end;

procedure TfrmSplash.Inici(aBAR: PGauge; Min, Max: integer);
begin
  aBAR.MinValue:=Min;
  aBAR.MaxValue:=Max;
  aBAR.Progress:=0;
  aBAR.Update;
end;

procedure TfrmSplash.MueveBar(aBAR: PGauge; increment: integer);
begin
  aBAR.Progress:=aBAR.Progress+increment;
  aBAR.Update;
  Application.ProcessMessages;
end;

end.
