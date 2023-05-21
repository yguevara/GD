unit USystemMsg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, acPNG;

type
  TfrmsystemMSG = class(TForm)
    Image1: TImage;
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmsystemMSG: TfrmsystemMSG;

implementation

{$R *.dfm}

procedure TfrmsystemMSG.Image1Click(Sender: TObject);
begin
  Close;
end;

end.
