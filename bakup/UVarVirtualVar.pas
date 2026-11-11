unit UVarVirtualVar;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  Vcl.ComCtrls, cxGridLevel, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxClasses, cxGridCustomView, cxGrid, Vcl.DBCtrls,
  cxDBNavigator, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ToolWin, cxDBLookupComboBox,
  cxBlobEdit, JvExExtCtrls, JvExtComponent, JvCaptionPanel, cxCheckBox,
  cxDropDownEdit, cxVGrid, cxDBVGrid, cxInplaceContainer, dxBarBuiltInMenu,
  cxContainer, cxDBEdit, cxMaskEdit, cxTextEdit, Vcl.StdCtrls, cxPC, AdvSplitter,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  JvExControls, JvButton, JvTransparentButton;

type
  TfrmVarVirtualVar = class(TForm)
    StatusBar1: TStatusBar;
    PVariables: TPanel;
    cxPageControl1: TcxPageControl;
    tsform: TcxTabSheet;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxDBEditorRow1: TcxDBEditorRow;
    cxDBEditorRow2: TcxDBEditorRow;
    cxDBEditorRow3: TcxDBEditorRow;
    cxDBEditorRow4: TcxDBEditorRow;
    cxLong: TcxDBEditorRow;
    cxDBEditorRow5: TcxDBEditorRow;
    cxDBEditorRow6: TcxDBEditorRow;
    cxTabSheet2: TcxTabSheet;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    AdvSplitter1: TAdvSplitter;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnExcelExport: TJvTransparentButton;
    btnExpand: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    Edit1: TEdit;
    cxGridDBTableView1codserie: TcxGridDBColumn;
    cxGridDBTableView1codsubs: TcxGridDBColumn;
    cxGridDBTableView1Orden: TcxGridDBColumn;
    cxGridDBTableView1NomVariable: TcxGridDBColumn;
    cxGridDBTableView1Etiqueta: TcxGridDBColumn;
    cxGridDBTableView1tipo: TcxGridDBColumn;
    cxGridDBTableView1longitud: TcxGridDBColumn;
    cxGridDBTableView1descripcion: TcxGridDBColumn;
    Panel6: TPanel;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    procedure btnCloseClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function GetNextConsecutiveValue(TableName: string; FieldName: string): Integer;
  end;

var
  frmVarVirtualVar: TfrmVarVirtualVar;
  Visualizando: boolean;

implementation

uses
  UCapaDatos, UCLVariables, UExcelExport;

{$R *.dfm}

procedure TfrmVarVirtualVar.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVarVirtualVar.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
var
  ordenfld: integer;
begin
  if Button = nbInsert then
  begin
    ordenfld := GetNextConsecutiveValue('cl_VarSubserie', 'orden');
    if (UDM.cl_VarSubserie.State = dsInsert) or (UDM.cl_VarSubserie.State = dsEdit) then
      UDM.cl_VarSubserie.FieldByName('orden').AsInteger := ordenfld;
  end;
end;

procedure TfrmVarVirtualVar.FormActivate(Sender: TObject);
begin
  ListVarTmp.Clear;
  UDM.cl_VarSubserie.First;
  while not UDM.cl_VarSubserie.Eof do
  begin
    ListVarTmp.Add(UDM.cl_VarSubserie.FieldByName('Etiqueta').AsString);
    UDM.cl_VarSubserie.Next;
  end;
  UDM.cl_VarSubserie.First;
end;

procedure TfrmVarVirtualVar.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  nombretmptable: string;
  existe: boolean;
begin
  if visualizando then
  begin
    CanClose := True;
  end
  else
  begin
    {if UDM.cl_VarSubserie.RecordCount>0 then begin
      UDM.sms('Tenga presente que cuando abandone esta interfaz no podrá modificar las definiciones de variable realizadas.', 3);
      if UDM.sms('¿Realmente desea salir de la interfaz de definiciones de variables?', 4) = 6 then
      begin
        nombretmptable := UDM.QuitaCaracter('md_' + UDM.cl_series.FieldByName('codserie').AsString + UDM.cl_subseries.FieldByName('codsubs').AsString);
        existe := UDM.TablaExiste(UDM.Conn, nombretmptable);
        if not existe then
          UDM.CreateTableFromDefinitions(nombretmptable, UDM.cl_subseries.FieldByName('codsubs').AsString);
      end;
    end;           }
    CanClose := True;
  end;
end;

function TfrmVarVirtualVar.GetNextConsecutiveValue(TableName, FieldName: string): Integer;
var
  ADOQuery: TFDQuery;
  MaxValue: Integer;
begin
  Result := 1; // Valor predeterminado en caso de error
  ADOQuery := TFDQuery.Create(nil);
  try
    ADOQuery.Connection := UDM.Conn;
//    if TBD='S' then
    ADOQuery.SQL.Text := Format('SELECT MAX(%s) AS MaxValue FROM %s', [FieldName, TableName]);
//    else
//      ADOQuery.SQL.Text :=Format('SELECT NZ(MAX(%s), 0) AS MaxValue FROM %s', [FieldName, TableName]);
//      'SELECT NZ(MAX(orden), 0) AS MaxValue FROM cl_VarSubserie';
    ADOQuery.Open;

    if not ADOQuery.IsEmpty then
    begin
      MaxValue := ADOQuery.FieldByName('MaxValue').AsInteger;
      Result := MaxValue + 1;
    end;
  finally
    ADOQuery.Free;
  end;
end;

end.

