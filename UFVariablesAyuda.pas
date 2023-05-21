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
    procedure SpeedButton2Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
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

procedure TFVariablesAyuda.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFVariablesAyuda.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TFVariablesAyuda.SpeedButton2Click(Sender: TObject);
begin
  Close;
end;

end.

