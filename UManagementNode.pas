unit UManagementNode;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ToolWin, dxSkinsCore, dxSkinsDefaultPainters,
  dxBarBuiltInMenu, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxPC, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  cxDBLookupComboBox, Vcl.DBCtrls, cxDBNavigator, JvExControls, JvButton,
  JvTransparentButton, Vcl.Buttons, Vcl.ExtCtrls, AdvSplitter, cxGridLevel,
  dxLayoutContainer, cxGridInplaceEditForm, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid,
  cxBlobEdit, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  cxContainer, cxMaskEdit, cxDropDownEdit, cxLookupEdit, cxDBLookupEdit,
  cxTextEdit, cxDBEdit, Vcl.StdCtrls;

type
  TfrmAddNode = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    cxPageControl2: TcxPageControl;
    tsNewStruct: TcxTabSheet;
    tsNewStructDisp: TcxTabSheet;
    GViewSeries: TcxGrid;
    GViewSeriesDBTableView1: TcxGridDBTableView;
    GViewSeriesDBTableView1RootGroup: TcxGridInplaceEditFormGroup;
    GViewSeriesLevel1: TcxGridLevel;
    Panel1: TPanel;
    AdvSplitter1: TAdvSplitter;
    Panel5: TPanel;
    btnAsignVarVir: TSpeedButton;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridInplaceEditFormGroup1: TcxGridInplaceEditFormGroup;
    cxGridLevel1: TcxGridLevel;
    dstb_tree: TDataSource;
    cxGridDBTableView1Idestructura: TcxGridDBColumn;
    cxGridDBTableView1Nombreestructura: TcxGridDBColumn;
    cxGridDBTableView1Descripcion: TcxGridDBColumn;
    cxGridDBTableView1idtipoobj: TcxGridDBColumn;
    GViewSeriesDBTableView1IdEstructura: TcxGridDBColumn;
    GViewSeriesDBTableView1id: TcxGridDBColumn;
    GViewSeriesDBTableView1etiqueta: TcxGridDBColumn;
    GViewSeriesDBTableView1padre: TcxGridDBColumn;
    GViewSeriesDBTableView1icono: TcxGridDBColumn;
    GViewSeriesDBTableView1tipo: TcxGridDBColumn;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    Panel2: TPanel;
    cxDBNavigator2: TcxDBNavigator;
    DBNavigator2: TDBNavigator;
    cxGrid2: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1DBTableView1Idestructura: TcxGridDBColumn;
    cxGrid1DBTableView1Nombreestructura: TcxGridDBColumn;
    cxGrid1DBTableView1Descripcion: TcxGridDBColumn;
    cxGrid1DBTableView1idtipoobj: TcxGridDBColumn;
    cxGrid1Level1: TcxGridLevel;
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
    procedure btnCloseClick(Sender: TObject);
    procedure cxGridDBTableView1DescripcionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure btnAsignVarVirClick(Sender: TObject);
    procedure DBNavigator2Click(Sender: TObject; Button: TNavigateBtn);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    papa, imgpapa: Integer;
  end;

var
  frmAddNode: TfrmAddNode;

implementation

uses
  UCapaDatos, UVeditor, UExcelExport;

{$R *.dfm}

procedure TfrmAddNode.btnAsignVarVirClick(Sender: TObject);

  function GetIDIMG(id: integer): Integer;
  begin
    Result := -1;
    if UDM.cl_tipoobj.locate('idtipoobj', id, []) then
      Result := UDM.cl_tipoobj.FieldByName('icon').AsInteger;
  end;

var
  idimg: integer;
begin                                                           //UDM.tb_EstructDisp
  UDM.tb_tree.Append;
  UDM.tb_tree.FieldByName('IdEstructura').AsString := UDM.tb_EstructDisp.FieldByName('IdEstructura').AsString;
  UDM.tb_tree.FieldByName('etiqueta').AsString := UDM.tb_EstructDisp.FieldByName('Nombreestructura').AsString;
  UDM.tb_tree.FieldByName('Tipo').AsInteger := UDM.tb_EstructDisp.FieldByName('idtipoobj').AsInteger;
  UDM.tb_tree.FieldByName('id').AsInteger := UDM.GetNewNodeID;
  UDM.tb_tree.FieldByName('Padre').AsInteger := papa;
  UDM.tb_tree.FieldByName('visible').AsBoolean := True;
  idimg := GetIDIMG(UDM.tb_EstructDisp.FieldByName('idtipoobj').AsInteger);
  if idimg = -1 then
    idimg := imgpapa;
  UDM.tb_tree.FieldByName('icono').AsInteger := idimg;
  try
    UDM.tb_tree.Post;
    UDM.tb_AllSon.Active := False;
    UDM.tb_AllSon.Params[0].AsInteger := papa;
    UDM.tb_AllSon.Active := True;
    UDM.tb_EstructDisp.Active := False;
    UDM.tb_EstructDisp.Active := True;
  except
    on E: EFDException do
    begin
      UDM.sms('No se pudo agregar la nueva estructura. Motivo: ' + e.Message, 1);
      Exit;
    end;
  end;

end;

procedure TfrmAddNode.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAddNode.cxGridDBTableView1DescripcionPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  //Descripcion
  CampoTexto(@UDM.dstb_EstructDisp, 'descripcion', 'Descripción de la estructura actual.');
end;

procedure TfrmAddNode.DBNavigator2Click(Sender: TObject; Button: TNavigateBtn);

  function GetIDIMG(id: integer): Integer;
  begin
    Result := -1;
    if UDM.cl_tipoobj.locate('idtipoobj', id, []) then
      Result := UDM.cl_tipoobj.FieldByName('icon').AsInteger;
  end;

var
  idimg: integer;
  bm:TBookmark;
begin
  if Button = nbPost then
  begin
    UDM.tb_tree.Append;
    UDM.tb_tree.FieldByName('IdEstructura').AsString := UDM.cl_tipoestructura.FieldByName('IdEstructura').AsString;
    UDM.tb_tree.FieldByName('etiqueta').AsString := UDM.cl_tipoestructura.FieldByName('Nombreestructura').AsString;
    UDM.tb_tree.FieldByName('Tipo').AsInteger := UDM.cl_tipoestructura.FieldByName('idtipoobj').AsInteger;
    UDM.tb_tree.FieldByName('id').AsInteger := UDM.GetNewNodeID;
    UDM.tb_tree.FieldByName('Padre').AsInteger := papa;
    UDM.tb_tree.FieldByName('visible').AsBoolean := True;
    idimg := GetIDIMG(UDM.cl_tipoestructura.FieldByName('idtipoobj').AsInteger);
    if idimg = -1 then
      idimg := imgpapa;
    UDM.tb_tree.FieldByName('icono').AsInteger := idimg;
    try
      UDM.tb_tree.Post;
      UDM.tb_AllSon.Active := False;
      UDM.tb_AllSon.Params[0].AsInteger := papa;
      UDM.tb_AllSon.Active := True;
      UDM.tb_EstructDisp.Active := False;
      UDM.tb_EstructDisp.Active := True;
      //UDM.tb_tree.DisableControls;
      bm:=UDM.tb_tree.GetBookmark;
      SystemTree^.Update;
      SystemTree^.Refresh;
      UDM.tb_tree.First;
      UDM.tb_tree.Last;
      UDM.tb_tree.GotoBookmark(bm);
     // UDM.tb_tree.EnableControls;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo agregar la nueva estructura. Motivo: ' + e.Message, 1);
        Exit;
      end;
    end;

  end;
end;

procedure TfrmAddNode.SpeedButton1Click(Sender: TObject);
begin
  ExcelExport(nil, GViewSeries);
end;

procedure TfrmAddNode.SpeedButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.

