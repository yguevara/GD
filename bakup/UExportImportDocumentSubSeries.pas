unit UExportImportDocumentSubSeries;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  AdvOfficeStatusBar, Vcl.StdCtrls, JvExControls, JvButton, JvTransparentButton,
  Vcl.ExtCtrls, JvDialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, Data.DB, FireDAC.Comp.Client, JvExExtCtrls, JvExtComponent,
  JvCaptionPanel;

type
  TfrmImportExport = class(TForm)
    pMainContainer: TPanel;
    btnClose: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    Edit1: TEdit;
    Panel1: TPanel;
    Edit2: TEdit;
    sbAD: TAdvOfficeStatusBar;
    edtPath: TEdit;
    JvTransparentButton2: TJvTransparentButton;
    SFTransDOC: TJvSaveDialog;
    btnInfo: TJvTransparentButton;
    ConnPlt: TFDConnection;
    SQLiteD: TFDPhysSQLiteDriverLink;
    Wait: TFDGUIxWaitCursor;
    procedure btnCloseClick(Sender: TObject);
    procedure JvTransparentButton2Click(Sender: TObject);
    procedure btnSystemHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmImportExport: TfrmImportExport;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmImportExport.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmImportExport.btnSystemHelpClick(Sender: TObject);
begin
  Application.HelpContext(1);
end;

procedure TfrmImportExport.JvTransparentButton2Click(Sender: TObject);
var
  Fname: string;

  function copiar: Boolean;
  begin
    Pathtransplt := PathSys + 'BD\plt.db';
    try
      CopyFile(Pchar(Pathtransplt), PChar(Fname), FALSE);
      Result := True;
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo crear el fichero de transacción. Motivo: ' + E.Message, 1);
        Result := False;
      end;
    end;
  end;

begin
  if SFTransDOC.Execute then
    if (Trim(SFTransDOC.FileName) <> '') then
    begin
      Fname := ExtractFileName(SFTransDOC.FileName);
      copiar;
      with ConnPlt do
      begin
        Connected := False;
        Params.Clear;
        Params.Add('Database=' + Fname);
        Params.Add('DriverID=SQLite');
        try
          Connected := True;
        except
          on E: EFDException do
          begin
            UDM.sms('No se pudo crear el fichero de transacción con los datos requeridos. Motivo: '+e.Message, 1);
          end;
        end;
      end;
    end;
end;

end.

