unit UFVariablesAyuda;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxEdit, dxSkinsCore, dxSkinsDefaultPainters,
  cxInplaceContainer, cxVGrid, cxDBVGrid, cxMemo, Vcl.Buttons, cxClasses,
  Vcl.ComCtrls, Vcl.ToolWin;

type
  TFVariablesAyuda = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxDBVerticalGrid1IdVar: TcxDBEditorRow;
    cxDBVerticalGrid1NomVariable: TcxDBEditorRow;
    cxDBVerticalGrid1Etiqueta: TcxDBEditorRow;
    cxDBVerticalGrid1tipo: TcxDBEditorRow;
    cxDBVerticalGrid1longitud: TcxDBEditorRow;
    cxDBVerticalGrid1descripcion: TcxDBEditorRow;
    cxDBVerticalGrid1ListaDesplegable: TcxDBEditorRow;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    procedure eesize(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

//var
 // FVariablesAyuda: TFVariablesAyuda;

procedure AyudaVariable(nombreVariable: string);

implementation

{$R *.dfm}

uses
  UCapaDatos;

procedure AyudaVariable(nombreVariable: string);
begin
  with TFVariablesAyuda.Create(nil) do
  try
    Caption := 'Variable:' + nombreVariable;
    showmodal;
  finally

  end;
end;

procedure TFVariablesAyuda.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFVariablesAyuda.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TFVariablesAyuda.eesize(Sender: TObject);
begin
  button1.Left := panel1.Width div 2 - button1.Width div 2;
end;

procedure TFVariablesAyuda.SpeedButton2Click(Sender: TObject);
begin
  Close;
end;

end.

