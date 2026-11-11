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
    Edit1: TEdit;
    procedure btncloseClick(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSystemHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmHistory: TfrmHistory;

implementation

uses
  UCapaDatos, USystemMsg;

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

procedure TfrmHistory.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 34;
  Application.HelpContext(TopicID);
end;

procedure TfrmHistory.FormActivate(Sender: TObject);
begin
  Edit1.Focused;
  Edit1.SetFocus;
  mhistory.Lines.Clear;
  mhistory.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Leeme.rtf');
end;

procedure TfrmHistory.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
  if Key = 112 then
  begin
    TopicID := 34;
    Application.HelpContext(TopicID);
  end;
end;

end.

