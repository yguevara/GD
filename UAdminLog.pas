unit UAdminLog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  cxTextEdit, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, Vcl.DBCtrls,
  cxDBNavigator, Vcl.StdCtrls, JvExControls, JvButton, JvTransparentButton,
  Vcl.ExtCtrls, cxCalendar, cxDBLookupComboBox, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Comp.BatchMove.Text,
  FireDAC.Comp.BatchMove, FireDAC.Comp.BatchMove.DataSet,
  FireDAC.Comp.BatchMove.SQL;

type
  TfrmAdminSysLogs = class(TForm)
    pMainContainer: TPanel;
    btnClose: TJvTransparentButton;
    btnExcelExport: TJvTransparentButton;
    btnExpand: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    Edit1: TEdit;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1DBTableView1usuariopc: TcxGridDBColumn;
    cxGrid1DBTableView1pc: TcxGridDBColumn;
    cxGrid1DBTableView1fecha: TcxGridDBColumn;
    cxGrid1DBTableView1ip: TcxGridDBColumn;
    cxGrid1DBTableView1usuario_sistema: TcxGridDBColumn;
    cxGrid1DBTableView1rol: TcxGridDBColumn;
    cxGrid1DBTableView1msg: TcxGridDBColumn;
    cxGrid1DBTableView1serie: TcxGridDBColumn;
    cxGrid1DBTableView1subserie: TcxGridDBColumn;
    cxGrid1DBTableView1IdEstructura: TcxGridDBColumn;
    cxGrid1DBTableView1accion: TcxGridDBColumn;
    btnSavelog: TJvTransparentButton;
    btnLoadLog: TJvTransparentButton;
    sd: TSaveDialog;
    od: TOpenDialog;
    btnClean: TJvTransparentButton;
    FDQuery1: TFDQuery;
    BM: TFDBatchMove;
    FDBatchMoveSQLReader1: TFDBatchMoveSQLReader;
    TextWriter: TFDBatchMoveTextWriter;
    TextReader: TFDBatchMoveTextReader;
    FDBatchMoveDataSetWriter1: TFDBatchMoveDataSetWriter;
    BM1: TFDBatchMove;
    procedure btnExpandClick(Sender: TObject);
    procedure btnExcelExportClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure btnSavelogClick(Sender: TObject);
    procedure btnLoadLogClick(Sender: TObject);
    procedure btnCleanClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAdminSysLogs: TfrmAdminSysLogs;

implementation

uses
  UCapaDatos, UExcelExport;

{$R *.dfm}

procedure TfrmAdminSysLogs.btnExcelExportClick(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

procedure TfrmAdminSysLogs.btnExpandClick(Sender: TObject);
begin
  try
    cxGrid1DBTableView1.ApplyBestFit();
    UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'adminLOGs');
  except
  end;
end;

procedure TfrmAdminSysLogs.btnSystemHelpClick(Sender: TObject);
begin
  Application.HelpContext(27);
end;

procedure TfrmAdminSysLogs.FormShow(Sender: TObject);
begin
  // El log ya no se carga completo al arrancar la aplicacion: se carga aqui.
  try
    UDM.tb_log.FetchAll;
  except
  end;
  if not FileExists(PathTemp + 'adminLOGs.tbl') then
  begin
    try
      cxGrid1DBTableView1.ApplyBestFit();
      UDM.SalvaConfigGrid(cxGrid1DBTableView1, 'adminLOGs');
    except
    end;
  end
  else
  begin
    UDM.RestauraGrid(cxGrid1DBTableView1, 'adminLOGs');
  end;
end;

procedure TfrmAdminSysLogs.btnCleanClick(Sender: TObject);
begin
  if UDM.sms('¿Realmente desea limpiar los logs del sistema?', 4) = 6 then
  begin
    try
      UDM.tb_log.DisableControls;
      UDM.tb_log.Last;
      UDM.Conn.ExecSQL('delete from tb_log');
      UDM.tb_log.Active := False;
      UDM.tb_log.Active := true;
      UDM.tb_log.EnableControls;
      UDM.sms('Los log fueron eliminados satisfactoriamente.', 3);
    except
      on E: EFDException do
      begin
        UDM.sms('Ha ocurrido un error: ' + e.Message, 1);
        exit;
      end;
    end;

  end;
end;

procedure TfrmAdminSysLogs.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAdminSysLogs.btnSavelogClick(Sender: TObject);
begin
  if sd.Execute then
    if trim(sd.FileName) <> '' then
    begin
      with bm do
      begin
        TextWriter.FileName := SD.FileName + '.LOG';
        try
          Execute;
          MessageDlg('El backup de logs se ha realizado satisfactoriamente.', mtInformation, [mbOK], 0);
        except
          on E: EFDException do
          begin
            MessageDlg('No se pudierón mover los datos especificados. Motivo: ' + e.Message, mtError, [mbOK], 0);
            Exit;
          end;
        end;
      end;

    end;

end;

procedure TfrmAdminSysLogs.btnLoadLogClick(Sender: TObject);
begin
  if od.Execute then
    if trim(od.FileName) <> '' then
    begin
      with bm1 do
      begin
        TextReader.FileName := OD.FileName;
        try
          Execute;
          UDM.tb_log.Active := False;
          UDM.tb_log.Active := TRue;
          UDM.tb_log.FetchAll;
          MessageDlg('El backup de logs se ha cargado satisfactoriamente.', mtInformation, [mbOK], 0);
        except
          on E: EFDException do
          begin
            MessageDlg('No se pudierón mover los datos especificados. Motivo: ' + e.Message, mtError, [mbOK], 0);
            Exit;
          end;
        end;
      end;
    end;
end;

end.

