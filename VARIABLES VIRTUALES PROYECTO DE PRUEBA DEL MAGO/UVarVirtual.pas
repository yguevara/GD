unit UVarVirtual;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB,
  Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, cxDBData, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView, cxGrid,
  Vcl.DBCtrls, cxDropDownEdit, cxBlobEdit, cxDBLookupComboBox, Vcl.StdCtrls,
  cxVGrid, cxDBVGrid;

type
  TFVarVirtual = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    DBNavigator1: TDBNavigator;
    Splitter1: TSplitter;
    Panel4: TPanel;
    DBGrid2: TDBGrid;
    DBNavigator2: TDBNavigator;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1Id: TcxGridDBColumn;
    cxGrid1DBTableView1codsubs: TcxGridDBColumn;
    cxGrid1DBTableView1Fecha: TcxGridDBColumn;
    cxGrid1DBTableView1Version: TcxGridDBColumn;
    cxGrid1DBTableView1IdVar: TcxGridDBColumn;
    Panel5: TPanel;
    Splitter2: TSplitter;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel10: TPanel;
    DBNavigator4: TDBNavigator;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2Level1: TcxGridLevel;
    cxGrid2: TcxGrid;
    cxGrid2DBTableView1IdVar: TcxGridDBColumn;
    cxGrid2DBTableView1NomVariable: TcxGridDBColumn;
    cxGrid2DBTableView1Etiqueta: TcxGridDBColumn;
    cxGrid2DBTableView1tipo: TcxGridDBColumn;
    cxGrid2DBTableView1longitud: TcxGridDBColumn;
    cxGrid2DBTableView1descripcion: TcxGridDBColumn;
    Panel8: TPanel;
    Button1: TButton;
    cxGrid1DBTableView1Orden: TcxGridDBColumn;
    cxGrid2DBTableView1ListaDesplegable: TcxGridDBColumn;
    cxGrid1DBTableView1VarInteger: TcxGridDBColumn;
    cxGrid1DBTableView1VarDouble: TcxGridDBColumn;
    cxGrid1DBTableView1VarDate: TcxGridDBColumn;
    cxGrid1DBTableView1VarString255: TcxGridDBColumn;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FVarVirtual: TFVarVirtual;
  S: string;

implementation

{$R *.dfm}
uses
  UCapaDatos, UEntrada;

procedure TFVarVirtual.Button1Click(Sender: TObject);
begin
  FEntrada.VarVirtual;
end;

end.

