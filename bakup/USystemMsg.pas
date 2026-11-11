unit USystemMsg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, acPNG, AdvOfficeStatusBar, Vcl.StdCtrls, dxGDIPlusClasses,
  Winapi.ShellAPI;

type
  TfrmsystemMSG = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Memo1: TMemo;
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

uses UCapaDatos;

procedure TfrmsystemMSG.Image1Click(Sender: TObject);
begin
  Close;
end;

end.

