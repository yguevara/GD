unit UMangementArch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  Vcl.ComCtrls, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls, Vcl.ToolWin,
  cxBlobEdit, cxDBLookupComboBox;

type
  TfrmManagemetArch = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    StatusBar1: TStatusBar;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1DBTableView1Idarchivo: TcxGridDBColumn;
    cxGrid1DBTableView1nombreArchivo: TcxGridDBColumn;
    cxGrid1DBTableView1Direccion: TcxGridDBColumn;
    cxGrid1DBTableView1Idresp: TcxGridDBColumn;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmManagemetArch: TfrmManagemetArch;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure TfrmManagemetArch.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmManagemetArch.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

end.
