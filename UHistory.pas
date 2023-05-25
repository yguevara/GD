unit UHistory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ToolWin, JvBaseDlg, JvSelectDirectory,
  System.ImageList, Vcl.ImgList, JvExControls, JvButton, JvTransparentButton,
  Vcl.ExtCtrls;

type
  TfrmHistory = class(TForm)
    StatusBar1: TStatusBar;
    JvSelectDirectory1: TJvSelectDirectory;
    SaveDialog1: TSaveDialog;
    mhistory: TRichEdit;
    ILEdith: TImageList;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    procedure btncloseClick(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHistory: TfrmHistory;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmHistory.btncloseClick(Sender: TObject);
begin
  close;
end;

procedure TfrmHistory.ToolButton4Click(Sender: TObject);
begin
  if JvSelectDirectory1.Execute then
    if trim(JvSelectDirectory1.Directory) <> '' then
    begin
      mhistory.Lines.SaveToFile(JvSelectDirectory1.Directory + '\Leeme.txt');
      UDM.sms('El historial ha sido guardado satisfactoriamente.', 3);
    end;
end;

procedure TfrmHistory.FormActivate(Sender: TObject);
begin
  mhistory.Lines.Clear;
  mhistory.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Leeme.rtf');
end;

end.

