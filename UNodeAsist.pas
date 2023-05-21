unit UNodeAsist;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  dxSkinsCore, dxSkinsDefaultPainters, dxBarBuiltInMenu, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, Vcl.ExtCtrls, AdvSplitter, cxPC,
  Vcl.ComCtrls, Vcl.StdCtrls, CnButtons, CnPanel, cxContainer, cxEdit,
  cxTextEdit, cxMemo;

type
  TfrmGestionarNodos = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
    Panel4: TPanel;
    Panel3: TPanel;
    pcNodeAssist: TcxPageControl;
    TS1: TcxTabSheet;
    AdvSplitter1: TAdvSplitter;
    Image1: TImage;
    TS2: TcxTabSheet;
    TS3: TcxTabSheet;
    btnBack: TCnButton;
    btnNext: TCnButton;
    btnFin: TCnButton;
    btnCancell: TCnButton;
    cxMemo1: TcxMemo;
    Panel5: TPanel;
    procedure btnPriorClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure btnCancellClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnBackClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmGestionarNodos: TfrmGestionarNodos;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmGestionarNodos.btnBackClick(Sender: TObject);
begin
  pcNodeAssist.ActivePageIndex := pcNodeAssist.ActivePageIndex - 1;
  case pcNodeAssist.ActivePageIndex of
    0:
      begin
      //Tratamiento de botones del asistente
        btnBack.Enabled := False;
        btnNext.Enabled := True;
        btnFin.Enabled := False;
      end;
    1:
      begin
      //Tratamiento de botones del asistente
        btnNext.Enabled := True;
        btnBack.Enabled := True;
        btnFin.Enabled := False;
      end;
    2:
      begin
      //Tratamiento de botones del asistente
        btnNext.Enabled := False;
        btnBack.Enabled := True;
        btnFin.Enabled := True;
      end;
  end;
end;

procedure TfrmGestionarNodos.btnCancellClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGestionarNodos.btnNextClick(Sender: TObject);
begin
  pcNodeAssist.ActivePageIndex := pcNodeAssist.ActivePageIndex + 1;
  case pcNodeAssist.ActivePageIndex of
    0:
      begin
      //Tratamiento de botones del asistente
        btnBack.Enabled := False;
        btnNext.Enabled := True;
        btnFin.Enabled := False;
      end;
    1:
      begin
      //Tratamiento de botones del asistente
        btnNext.Enabled := True;
        btnBack.Enabled := True;
        btnFin.Enabled := False;
      end;
    2:
      begin
      //Tratamiento de botones del asistente
        btnNext.Enabled := False;
        btnBack.Enabled := True;
        btnFin.Enabled := True;
      end;
  end;
end;

procedure TfrmGestionarNodos.btnPriorClick(Sender: TObject);
begin
  btnNext.Enabled := true;
  btnBack.Enabled := False;
end;

procedure TfrmGestionarNodos.FormActivate(Sender: TObject);
begin
  pcNodeAssist.ActivePageIndex := 0;
  btnBack.Enabled := False;
  btnNext.Enabled := True;
  btnFin.Enabled := False;
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmGestionarNodos.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if UDM.sms('�Realmente desea salir del asistente de creaci�n de nodos?', 4)=6 then
  begin
    CanClose := True
  end
  else
    CanClose := False;
end;

end.

