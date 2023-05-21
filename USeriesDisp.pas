unit USeriesDisp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, cxDBLookupComboBox, Vcl.Buttons, FireDAC.Stan.Error;

type
  TfrmSeriesDisp = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    btnAsignVarVir: TSpeedButton;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    cxGrid1DBTableView1codserie: TcxGridDBColumn;
    cxGrid1DBTableView1codsubs: TcxGridDBColumn;
    cxGrid1DBTableView1Series: TcxGridDBColumn;
    cxGrid1DBTableView1Subseries: TcxGridDBColumn;
    cxGrid1DBTableView1Etiqueta: TcxGridDBColumn;
    procedure btnCloseClick(Sender: TObject);
    procedure btnAsignVarVirClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSeriesDisp: TfrmSeriesDisp;

implementation

uses
  UCapaDatos, UExcelExport;

{$R *.dfm}

procedure TfrmSeriesDisp.btnAsignVarVirClick(Sender: TObject);
begin
  if UDM.sms('¿Desea agregar la serie a la estructura actual?', 4) = 6 then
  begin
    if not UDM.tb_Serietree.Locate('IdEstructura;codsubs', VarArrayOf([UDM.tb_tree.FieldByName('IdEstructura').AsString, UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString]), []) then
    begin
      UDM.tb_Serietree.Append;
      UDM.tb_Serietree.FieldByName('IdEstructura').AsString := UDM.tb_tree.FieldByName('IdEstructura').AsString;
      UDM.tb_Serietree.FieldByName('id').AsInteger := UDM.tb_tree.FieldByName('id').AsInteger;
      UDM.tb_Serietree.FieldByName('codsubs').AsString := UDM.Tb_SeriesDispo.FieldByName('codsubs').AsString;
      try
        UDM.tb_Serietree.Post;
      except
        on E: EFDException do
        begin
          UDM.sms('La serie ' + UDM.Tb_SeriesDispo.FieldByName('Etiqueta').AsString + ' no se pudo agregar. Motivo: ' + E.Message,1);
          Exit;
        end;
      end;
    end;

  end;
end;

procedure TfrmSeriesDisp.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmSeriesDisp.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmSeriesDisp.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmSeriesDisp.ToolButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.

