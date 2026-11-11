unit UCapaDatos;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSAcc,
  FireDAC.Phys.MSAccDef, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.Client,
  FireDAC.Comp.DataSet, System.ImageList, Vcl.ImgList, Vcl.Controls;

type
  TDM = class(TDataModule)
    Conn: TFDConnection;
    ImageList1: TImageList;
    tb_SerieDatosVar: TFDQuery;
    tb_SeriesDatos: TFDQuery;
    Dtb_SeriesDatos: TDataSource;
    Dtb_SerieDatosVar: TDataSource;
    cl_Variables: TFDQuery;
    Dcl_Variables: TDataSource;
    tb_SerieDatosVarId: TSmallintField;
    tb_SerieDatosVarcodsubs: TSmallintField;
    tb_SerieDatosVarFecha: TSQLTimeStampField;
    tb_SerieDatosVarVersion: TSmallintField;
    tb_SerieDatosVarOrden: TIntegerField;
    tb_SerieDatosVarIdVar: TSmallintField;
    tb_SeriesDatosId: TSmallintField;
    tb_SeriesDatoscodsubs: TSmallintField;
    tb_SeriesDatosFecha: TSQLTimeStampField;
    tb_SeriesDatosVersion: TSmallintField;
    tb_SeriesDatosCodigodoc: TWideStringField;
    tb_SeriesDatosIdservidor: TSmallintField;
    tb_SeriesDatosdeposito: TWideStringField;
    tb_SeriesDatosgaveta: TWideStringField;
    tb_SeriesDatosfichero: TWideStringField;
    tb_SeriesDatossoporte: TSmallintField;
    tb_SeriesDatosobservaciones: TWideMemoField;
    Dcl_subseries: TDataSource;
    cl_subseries: TFDQuery;
    tb_SerieDatosVarVarInteger: TIntegerField;
    tb_SerieDatosVarVarDouble: TFloatField;
    tb_SerieDatosVarVarDate: TSQLTimeStampField;
    tb_SerieDatosVarVarString255: TWideStringField;
    tb_VirtualVar: TFDMemTable;
    Dtb_VirtualVar: TDataSource;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
