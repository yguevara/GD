unit UCategoria_Ocupa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ToolWin, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmCatOcupa = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1DBTableView1idcategoria: TcxGridDBColumn;
    cxGrid1DBTableView1nombrecategoria: TcxGridDBColumn;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure ToolButton1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCatOcupa: TfrmCatOcupa;

implementation

uses
  UCapaDatos, UExcelExport;

{$R *.dfm}

procedure TfrmCatOcupa.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCatOcupa.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmCatOcupa.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
begin
{  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_categoria_ocupacional.FieldByName('idcategoria').AsInteger:=UDM.GetLastId('cl_categoria_ocupacional', 'idcategoria');
  end;  }
end;

procedure TfrmCatOcupa.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmCatOcupa.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.cl_categoria_ocupacional.Active := False;
  UDM.cl_categoria_ocupacional.Active := True;
end;

procedure TfrmCatOcupa.ToolButton1Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.

