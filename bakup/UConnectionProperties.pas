unit UConnectionProperties;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.StdCtrls;

type
  TfrmConnProperties = class(TForm)
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    ToolButton4: TToolButton;
    StatusBar1: TStatusBar;
    lblServer: TLabel;
    edtServer: TEdit;
    lblUser: TLabel;
    edtuser: TEdit;
    lblpuerto: TLabel;
    edtpuerto: TEdit;
    edtpass: TEdit;
    Label1: TLabel;
    btnAcept: TButton;
    btnCancel: TButton;
    procedure ToolButton2Click(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnAceptClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    opera: Boolean;
  end;

var
  frmConnProperties: TfrmConnProperties;

implementation

uses
  DMBDRU;

{$R *.dfm}

procedure TfrmConnProperties.btnAceptClick(Sender: TObject);

  function verificaDatos: Boolean;
  begin
    result := True;
    if (trim(edtServer.Text) = '') or (trim(edtuser.Text) = '') or (trim(edtpass.Text) = '') or (trim(edtpuerto.Text) = '') then
      Result := False;
  end;

var
  List: TStringList;
begin
  if (trim(edtServer.Text) = '') and (trim(edtuser.Text) = '') and (trim(edtpass.Text) = '') and (trim(edtpuerto.Text) = '') then
  begin
    MessageDlg('No ha especificado ningun dato en la interface', mtWarning, [mbOK], 0);
    Exit;
  end
  else
  if not verificaDatos then
  begin
    MessageDlg('Debe especificar todos los datos que se solicitan en la interface actual.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if changeConn then
  begin
    List := TStringList.Create;
    List.Add(edtServer.Text);
    List.Add(edtuser.Text);
    List.Add(edtpass.Text);
    List.Add(edtpuerto.Text);
    List.SaveToFile(PathConf);
    List.Free;
    opera := True;
  end;
  Close;
end;

procedure TfrmConnProperties.btnCancelClick(Sender: TObject);
begin
  opera := False;
  Close;
end;

procedure TfrmConnProperties.ToolButton2Click(Sender: TObject);
begin
  Close;
end;

end.

