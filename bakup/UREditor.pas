unit UREditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AdvScrollControl, AdvRichEditorBase, AdvRichEditor, DBAdvRichEditor,
  StdCtrls, Grids, DBGrids, ExtCtrls, DBCtrls, DB, ADODB, AdvToolBar,
  AdvToolBarExt, AdvRichEditorToolBar, AdvToolBarStylers, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, UCapaDatos, JvExControls, JvButton,
  JvTransparentButton;

type
  TfrmREditor = class(TForm)
    DBAdvRichEditor1: TDBAdvRichEditor;
    dsqeditor: TDataSource;
    Panel1: TPanel;
    AdvRichEditorFormatToolBar1: TAdvRichEditorFormatToolBar;
    Panel2: TPanel;
    DBNavigator1: TDBNavigator;
    AdvToolBarOfficeStyler1: TAdvToolBarOfficeStyler;
    qeditor: TFDQuery;
    btnclose: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

{var
  frmREditor: TfrmREditor;}
function CampoTexto12(ds: Tpdatasource; campo, Titulo: string): Boolean; overload;

implementation

{$R *.dfm}

function CampoTexto12(ds: Tpdatasource; campo, Titulo: string): Boolean; overload;
var
  s:string;
begin
  with TfrmREditor.Create(Application) do
  try
    s := ds^.DataSet.Name;
    s := s;
    TFDQuery(ds^.DataSet).FieldByName(campo).OnGetText := nil;
    EditorActivo := True;
    DBAdvRichEditor1.DataSource := ds^;
    DBAdvRichEditor1.DataField := campo;
    DBAdvRichEditor1.ReadOnly := False;
    DBNavigator1.DataSource := ds^;
    try
      ds^.DataSet.Edit;
    except
    end;
    Caption := Titulo;
    ShowModal;
  finally
    Free;
  end;
end;

end.
