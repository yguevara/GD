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
    cxGrid1DBTableView1codsubs: TcxGridDBColumn;
    cxGrid1DBTableView1subserie: TcxGridDBColumn;
    cxGrid1DBTableView1etiqueta: TcxGridDBColumn;
    cxGrid1DBTableView1serie: TcxGridDBColumn;
    procedure btnCloseClick(Sender: TObject);
    procedure btnAsignVarVirClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSeriesDisp: TfrmSeriesDisp;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmSeriesDisp.btnAsignVarVirClick(Sender: TObject);
begin
  if MessageDlg('¿Desea agregar la serie a la estructura actual?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if not UDM.tb_Serietree.Locate('id;codsubs', VarArrayOf([UDM.tb_tree.FieldByName('Id').AsInteger, UDM.Tb_SeriesDispo.FieldByName('codsubs').AsInteger]), []) then
    begin
      UDM.tb_Serietree.Append;
      UDM.tb_Serietree.FieldByName('Id').AsInteger := UDM.tb_tree.FieldByName('Id').AsInteger;
      UDM.tb_Serietree.FieldByName('codsubs').AsInteger := UDM.Tb_SeriesDispo.FieldByName('codsubs').AsInteger;
      try
        UDM.tb_Serietree.Post;
      except
        on E: EFDException do
        begin
          MessageDlg('La serie ' + UDM.Tb_SeriesDispo.FieldByName('Etiqueta').AsString + ' no se pudo agregar. Motivo: ' + E.Message, mtError, [mbOK], 0);
          Exit;
        end;
      end;
    end;
    {
    Id
codsubs
Ubicacion
deposito
gaveta
especialista
correo
usuario
frecuencia
tiempo
observacion
servidor
carpeta

    }

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

end.

