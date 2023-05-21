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
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TfrmVarVirtualVar = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1codserie: TcxGridDBColumn;
    cxGrid1DBTableView1codsubs: TcxGridDBColumn;
    cxGrid1DBTableView1IdVar: TcxGridDBColumn;
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
    cxGridDBColumn1: TcxGridDBColumn;
    cxGrid1DBTableView1NomVariable: TcxGridDBColumn;
    cxGrid1DBTableView1Etiqueta: TcxGridDBColumn;
    cxGrid1DBTableView1tipo: TcxGridDBColumn;
    cxGrid1DBTableView1longitud: TcxGridDBColumn;
    cxGrid1DBTableView1descripcion: TcxGridDBColumn;
    cxGrid1DBTableView1ListaDesplegable: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    AdvSplitter1: TAdvSplitter;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    dsVarVirtSS: TDataSource;
    cxGrid3: TcxGrid;
    cxGridDBTableView2: TcxGridDBTableView;
    cxGridDBTableView2IdEstructura: TcxGridDBColumn;
    cxGridDBTableView2id: TcxGridDBColumn;
    cxGridDBTableView2Orden: TcxGridDBColumn;
    cxGridDBTableView2IdVar: TcxGridDBColumn;
    cxGridLevel2: TcxGridLevel;
    dscl_VarProject: TDataSource;
    Panel2: TPanel;
    btnAsignVarVir: TSpeedButton;
    Panel3: TPanel;
    Panel4: TPanel;
    btnDelAsignVirtVar: TSpeedButton;
    procedure btnCloseClick(Sender: TObject);
    procedure btnAsignVarVirClick(Sender: TObject);
    procedure btnAddVarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure DataSource1UpdateData(Sender: TObject);
    procedure dsVarVirtSSDataChange(Sender: TObject; Field: TField);
    procedure dscl_VarProjectDataChange(Sender: TObject; Field: TField);
    procedure dscl_VarProjectUpdateData(Sender: TObject);
    procedure btnDelAsignVirtVarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

  end;

var
  frmVarVirtualVar: TfrmVarVirtualVar;

implementation

uses
  UCapaDatos, UCLVariables, UExcelExport;

{$R *.dfm}

procedure TfrmVarVirtualVar.btnAddVarClick(Sender: TObject);
begin
  if TipoObj = 'S' then
    ExcelExport(nil, cxGrid1)
  else
    ExcelExport(nil, cxGrid3)
end;

procedure TfrmVarVirtualVar.btnAsignVarVirClick(Sender: TObject);
var
  idvariable: integer;
begin
  if TipoObj = 'S' then
  begin
    if UDM.VarDispSubS.RecordCount = 0 then
    begin
      UDM.sms('No existen variables disponibles para agregar a la subserie actual.', 3);
      Exit;
    end;
    if (UDM.cl_VarSubserie.State = dsInsert) or (UDM.cl_VarSubserie.State = dsEdit) then
    try
      UDM.cl_VarSubserie.Post;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo agregar la variable especificada. Motivo: ' + e.Message, 1);
        UDM.cl_varsubserie.cancel;
      end;
    end;
    idvariable := UDM.VarDispSubS.FieldByName('IdVar').AsInteger;
    if not UDM.cl_VarSubserie.Locate('codserie;codsubs;IdVar', VarArrayOf([UDM.cl_subseries.FieldByName('codserie').AsString, UDM.cl_subseries.FieldByName('codsubs').AsString, idvariable]), []) then
    begin
      UDM.cl_VarSubserie.Append;
      UDM.cl_VarSubserie.FieldByName('Orden').AsInteger := UDM.GetLastId('cl_VarSubserie', 'Orden');
      UDM.cl_VarSubserie.FieldByName('IdVar').AsInteger := idvariable;
      try
        UDM.cl_VarSubserie.Post;
      except
        on E: EFDException do
        begin
          UDM.sms('No se pudo agregar la variable especificada. Motivo: ' + e.Message, 1);
          UDM.cl_varsubserie.cancel;
        end;
      end;
    end
    else
    begin
      UDM.sms('La variable especificada ya existe en el conjunto de datos.', 2);
      Exit;
    end;
  end
  else
  begin
    if  UDM.VarDispPrj.RecordCount=0 then begin
      UDM.sms('No existen variables disponibles para agregar a la estructura actual.', 3);
      Exit;
    end;
    if (UDM.cl_VarProject.State = dsInsert) or (UDM.cl_VarProject.State = dsEdit) then
    try
      UDM.cl_VarProject.Post;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo agregar la variable especificada. Motivo: ' + e.Message, 1);
        UDM.cl_VarProject.cancel;
      end;
    end;
    idvariable := UDM.VarDispPrj.FieldByName('IdVar').AsInteger;
    if not UDM.cl_VarProject.Locate('idestructura;id;IdVar', VarArrayOf([UDM.tb_tree.FieldByName('idestructura').AsString, UDM.tb_tree.FieldByName('id').AsString, idvariable]), []) then
    UDM.cl_VarProject.Append;
    UDM.cl_VarProject.FieldByName('Orden').AsInteger := UDM.GetLastId('cl_VarProject', 'Orden');
    UDM.cl_VarProject.FieldByName('IdVar').AsInteger := idvariable;
    try
      UDM.cl_VarProject.Post;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo agregar la variable especificada. Motivo: ' + e.Message, 1);
        UDM.cl_VarProject.cancel;
      end;
    end;
  end;
end;

procedure TfrmVarVirtualVar.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVarVirtualVar.btnDelAsignVirtVarClick(Sender: TObject);
begin
  if TipoObj = 'S' then
  begin
    if UDM.cl_VarSubserie.RecordCount=0 then begin
      UDM.sms('Debe especificar una variable válida. No existen variables que se puedan eliminar.', 3);
      Exit;
    end;
    UDM.cl_VarSubserie.Delete;
  end
  else begin
    if UDM.cl_VarProject.RecordCount=0 then begin
      UDM.sms('Debe especificar una variable válida. No existen variables que se puedan eliminar.', 3);
      Exit;
    end;
    UDM.cl_VarProject.Delete;
  end;
end;

procedure TfrmVarVirtualVar.dscl_VarProjectDataChange(Sender: TObject; Field: TField);
begin
  UDM.UpdateVarPrj(UDM.tb_tree.FieldByName('IdEstructura').AsString, UDM.tb_tree.FieldByName('Id').AsString);
end;

procedure TfrmVarVirtualVar.dscl_VarProjectUpdateData(Sender: TObject);
begin
  UDM.UpdateVarPrj(UDM.tb_tree.FieldByName('IdEstructura').AsString, UDM.tb_tree.FieldByName('Id').AsString);
end;

procedure TfrmVarVirtualVar.dsVarVirtSSDataChange(Sender: TObject; Field: TField);
begin
  UDM.UpdateVarSubS(UDM.cl_subseries.FieldByName('codsubs').AsString)
end;

procedure TfrmVarVirtualVar.DataSource1UpdateData(Sender: TObject);
begin
  UDM.UpdateVarSubS(UDM.cl_subseries.FieldByName('codsubs').AsString)
end;

procedure TfrmVarVirtualVar.FormActivate(Sender: TObject);
begin
  if TipoObj = 'S' then
  begin
    cxGrid3.Visible := False;
    cxGrid1.Visible := True;
  end
  else
  begin
    cxGrid3.Visible := True;
    cxGrid1.Visible := False
  end;
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmVarVirtualVar.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  with UDM.cl_variables do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select * from cl_variables');
    try
      Active := True;
    except
    end;
  end;
end;

end.

