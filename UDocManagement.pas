unit UDocManagement;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ToolWin, JvExComCtrls, JvListView;

type
  TfrmDoc = class(TForm)
    StatusBar2: TStatusBar;
    ToolBar1: TToolBar;
    ToolButton2: TToolButton;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    lbDoc: TJvListView;
    procedure ToolButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lbDocDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmDoc: TfrmDoc;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmDoc.FormActivate(Sender: TObject);

  procedure CreaItem(NombreDoc: string);
  var
    ListItem: TListItem;
  begin
    lbDoc.Items.BeginUpdate;
    ListItem := lbDoc.Items.Add;
    ListItem.Caption := NombreDoc;
    ListItem.ImageIndex := 44;
    ListItem.StateIndex := 44;
    lbDoc.Items.EndUpdate;
  end;

  procedure RastreaDir(Dir: string);
  var
    FileSearch: TSearchRec;
    li: TListItem;
  begin
    ChDir(Dir);
    if FindFirst('*.pdf', faDirectory, FileSearch) = 0 then
      repeat
        if ((FileSearch.Attr and fadirectory) = fadirectory) then
        begin
          if (FileSearch.Name <> '.') and (FileSearch.Name <> '..') then
            RastreaDir(Dir + '\' + FileSearch.Name);
        end
        else
        begin
         {Pon aqui lo que quieras hacer con los ficheros encontrados}
         {Put here anything to make with the find files}
          CreaItem(FileSearch.Name);

        // ListView1.Items
        // Memo1.Lines.Add( Dir +'\'+FileSearch.Name );
        end;
      until FindNext(FileSearch) <> 0;
    FindClose(FileSearch);
  end;

begin
  RastreaDir(PathSys + 'DOC\');
end;

procedure TfrmDoc.lbDocDblClick(Sender: TObject);
begin
  if lbDoc.ItemIndex<>-1 then
    UDM.VerPDFF(PathSys+'DOC\'+lbDoc.Items[lbDoc.ItemIndex].Caption);
end;

procedure TfrmDoc.ToolButton1Click(Sender: TObject);
begin
  Close;
end;

end.

