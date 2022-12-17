unit UHistory;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ToolWin, JvBaseDlg, JvSelectDirectory,
  System.ImageList, Vcl.ImgList;

type
  TfrmHistory = class(TForm)
    ToolBar2: TToolBar;
    btnclose: TToolButton;
    ToolButton4: TToolButton;
    StatusBar1: TStatusBar;
    JvSelectDirectory1: TJvSelectDirectory;
    SaveDialog1: TSaveDialog;
    mhistory: TRichEdit;
    ILEdith: TImageList;
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
      MessageDlg('El historial ha sido guardado satisfactoriamente.', mtInformation, [mbOK], 0);
    end;
end;

procedure TfrmHistory.FormActivate(Sender: TObject);
begin
  mhistory.Lines.Clear;
  mhistory.Lines.LoadFromFile(ExtractFilePath(Application.ExeName) + 'Leeme.rtf');
end;

end.

