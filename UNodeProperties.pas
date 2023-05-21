unit UNodeProperties;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ToolWin, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore,
  dxSkinsDefaultPainters, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, cxStyles, cxCustomData,
  cxFilter, cxData, cxDataStorage, cxNavigator, dxDateRanges, Data.DB, cxDBData,
  cxCheckBox, cxRichEdit, cxVGrid, cxDBVGrid, cxInplaceContainer, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, Vcl.ExtCtrls, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, cxDBEdit, cxMaskEdit, cxDropDownEdit, cxLookupEdit,
  cxDBLookupEdit, cxDBLookupComboBox, cxTextEdit, cxMemo, cxDBRichEdit,
  Vcl.StdCtrls, Vcl.DBCtrls, cxDBNavigator, Vcl.Buttons, dxtree, dxdbtree,
  AdvSplitter, Vcl.Menus, AdvMenus, dxBarBuiltInMenu, cxBlobEdit, cxPC,
  JvExControls, JvButton, JvTransparentButton, AdvPanel, JvExExtCtrls,
  JvExtComponent, JvCaptionPanel, AdvOfficeStatusBar;

type
  TfrmPropiedadesNodo = class(TForm)
    StatusBar1: TStatusBar;
    Padres: TFDQuery;
    dsPadres: TDataSource;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    Panel3: TPanel;
    Panel4: TPanel;
    AdvSplitter1: TAdvSplitter;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    Label3: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    Label2: TLabel;
    lcbTipodeObjeto: TcxDBLookupComboBox;
    lcbRepresentante: TcxDBLookupComboBox;
    edtEtiqueta: TcxDBTextEdit;
    edtdeposito: TcxDBTextEdit;
    cxDBCheckBox1: TcxDBCheckBox;
    lcbPadre: TcxDBLookupComboBox;
    APMArbol: TAdvPopupMenu;
    N3: TMenuItem;
    A2: TMenuItem;
    N1: TMenuItem;
    MenuItem6: TMenuItem;
    cxPageControl1: TcxPageControl;
    tsVariable: TcxTabSheet;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
    cxCategoryRow1: TcxCategoryRow;
    cxDBEditorRow1: TcxDBEditorRow;
    cxDBEditorRow2: TcxDBEditorRow;
    cxDBEditorRow3: TcxDBEditorRow;
    cxDBEditorRow4: TcxDBEditorRow;
    cxDBEditorRow5: TcxDBEditorRow;
    cxGrid1: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridDBColumn1: TcxGridDBColumn;
    cxGridLevel1: TcxGridLevel;
    Panel5: TPanel;
    cxDBNavigator2: TcxDBNavigator;
    DBNavigator2: TDBNavigator;
    tsValue: TcxTabSheet;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    iv1: TcxDBEditorRow;
    iv2: TcxDBEditorRow;
    iv3: TcxDBEditorRow;
    iv4: TcxDBEditorRow;
    iv5: TcxDBEditorRow;
    iv6: TcxDBEditorRow;
    iv7: TcxDBEditorRow;
    iv8: TcxDBEditorRow;
    iv9: TcxDBEditorRow;
    iv10: TcxDBEditorRow;
    iv11: TcxDBEditorRow;
    DataSource1: TDataSource;
    ToolBar3: TToolBar;
    ToolButton4: TToolButton;
    ToolButton9: TToolButton;
    tvTreeData: TTreeView;
    edtDescripcion: TcxDBRichEdit;
    Label6: TLabel;
    N2: TMenuItem;
    v1: TMenuItem;
    N4: TMenuItem;
    O1: TMenuItem;
    MB: TAdvOfficeStatusBar;
    cpNewNode: TJvCaptionPanel;
    Label7: TLabel;
    Label8: TLabel;
    Label10: TLabel;
    Label9: TLabel;
    Label11: TLabel;
    edtCodEstructura: TcxDBTextEdit;
    cxDBLookupComboBox1: TcxDBLookupComboBox;
    cxDBCheckBox2: TcxDBCheckBox;
    cxDBLookupComboBox2: TcxDBLookupComboBox;
    edtNombreEstructura: TcxDBTextEdit;
    cxDBRichEdit1: TcxDBRichEdit;
    AdvPanel1: TAdvPanel;
    btnCancel: TJvTransparentButton;
    btnOK: TJvTransparentButton;
    Timer1: TTimer;
    pMainContainer: TPanel;
    btncerrar: TJvTransparentButton;
    btnadd: TJvTransparentButton;
    btnView: TJvTransparentButton;
    btnHide: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btndel: TJvTransparentButton;
    procedure btnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
    procedure cxDBCheckBox1PropertiesEditValueChanged(Sender: TObject);
    procedure TvTreeChange(Sender: TObject; Node: TTreeNode);
    procedure TvTreeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure A2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure ToolButton9Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvTreeDataMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure cpNewNodeButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cxDBLookupComboBox2PropertiesCloseUp(Sender: TObject);
    procedure cxDBLookupComboBox2PropertiesChange(Sender: TObject);
    procedure v1Click(Sender: TObject);
    procedure O1Click(Sender: TObject);
    procedure edtCodEstructuraPropertiesValidate(Sender: TObject;
      var DisplayValue: Variant; var ErrorText: TCaption; var Error: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
    varUltimoQuery: string;
    iRow: integer; //Posicion en la fila de la VerticalGrid
    procedure CambiaEstado(Estado: boolean);
    procedure EliminaPadreSon(IdPadre: integer);
    procedure ChangeParentState(State: boolean);
    procedure RellenaPrj;
    procedure OcultaVGVardef;
    procedure SaveTreeStateNode;
    procedure LoadTreeStateNode;
  end;

var
  frmPropiedadesNodo: TfrmPropiedadesNodo;
  AnItem: TTreeNode;
  IdSelectedNode: integer;
  S: string;
  salvo: boolean;
  CantIndex: integer;
  idelemento: Variant;

implementation

uses
  UCapaDatos, UAddNewNode, UVarVirtualVar;

{$R *.dfm}

procedure TfrmPropiedadesNodo.A2Click(Sender: TObject);
var
  Idpp: Integer;
  Padre: string;
begin
  SaveTreeStateNode;
  Idpp := UDM.tb_tree.FieldByName('id').AsInteger;
  Padre := UDM.tb_tree.FieldByName('etiqueta').AsString;
//  with TfrmNewNode.Create(nil) do
  UDM.tb_tree.Append;
  UDM.tb_tree.FieldByName('Id').AsInteger := UDM.GetLastId('tb_tree', 'id');
  UDM.tb_tree.FieldByName('Padre').AsInteger := Idpp; //aowner
  UDM.tb_tree.FieldByName('aowner').AsString := 'administrador';
  UDM.tb_tree.FieldByName('visible').AsBoolean := True;
  cpNewNode.Caption := 'Nuevo nodo hijo de ' + AnsiQuotedStr(Padre, '"');
  cpNewNode.Visible := True;
end;

procedure TfrmPropiedadesNodo.btnCancelClick(Sender: TObject);
begin
  if (UDM.tb_tree.State = dsEdit) or (UDM.tb_tree.State = dsInsert) then
  try
    UDM.tb_tree.Cancel;
    cpNewNode.Visible := False;
    UDM.tb_tree.DisableControls;
    UDM.tb_tree.Active := False;
    UDM.tb_tree.Active := True;
    UDM.tb_tree.EnableControls;
    UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
    LoadTreeStateNode;
  except
    on E: EFDException do
    begin
      UDM.sms('No se pudieron salvar los cambios solicitados. Motivo: ' + E.Message, 1);
      exit;
    end;
  end;
end;

procedure TfrmPropiedadesNodo.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPropiedadesNodo.btnOKClick(Sender: TObject);
begin
  if trim(edtCodEstructura.Text)='' then
  begin
    UDM.sms('Debe especificar un identificador de estructura válido.', 1);
    edtCodEstructura.Focused;
    edtCodEstructura.SetFocus;
    Exit;
  end;

  if (UDM.tb_tree.State = dsEdit) or (UDM.tb_tree.State = dsInsert) then
  try
    UDM.tb_tree.Post;
    cpNewNode.Visible := False;
    UDM.tb_tree.DisableControls;
    UDM.tb_tree.Active := False;
    UDM.tb_tree.Active := True;
    UDM.tb_tree.EnableControls;
    UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
    LoadTreeStateNode;
  except
    on E: EFDException do
    begin
      UDM.sms('No se pudieron salvar los cambios solicitados. Motivo: ' + E.Message, 1);
      exit;
    end;
  end;
end;

procedure TfrmPropiedadesNodo.CambiaEstado(Estado: boolean);
var
  q: TFDQuery;
  flag: Boolean;
  CIcon: Integer;

  procedure ChangeVisibleProp(idPadre: string; vp: boolean);
  var
    i: Integer;
  begin
    with TFDQuery.Create(nil) do
    try
      Active := False;
      connection := UDM.Conn;
      SQL.Clear;
      SQL.Add('select * from tb_tree where padre=' + idPadre);
      try
        Active := True;
        First;
        while not Eof do
        begin
          Edit;
          FieldByName('visible').AsBoolean := vp;
//  poner icono al elemento hijo....
          if vp and (FieldByName('Icono').AsInteger > 7) then
            CIcon := FieldByName('Icono').AsInteger - 7;
          if not vp and (FieldByName('Icono').AsInteger < 7) then
            CIcon := FieldByName('Icono').AsInteger + 7;
          if CIcon <> 0 then
            FieldByName('Icono').AsInteger := CIcon;
          try
            Post;
          except
          end;
          ChangeVisibleProp(FieldByName('id').AsString, vp);
          Next;
        end;
      except
      end;
    finally
      Free;
    end;
  end;

begin
  flag := Estado;
  q := TFDQuery.Create(nil);
  with q do
  begin
    Active := False;
    Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('select * from tb_tree where padre=' + UDM.tb_tree.FieldByName('id').AsString);
    try
      Active := True;
      First;
      while not Eof do
      begin
        CIcon := 0;
        Edit;
        FieldByName('visible').AsBoolean := flag;
        if flag and (FieldByName('Icono').AsInteger > 7) then
          CIcon := FieldByName('Icono').AsInteger - 7;
        if not flag and (FieldByName('Icono').AsInteger < 7) then
          CIcon := FieldByName('Icono').AsInteger + 7;
        if CIcon <> 0 then
          FieldByName('Icono').AsInteger := CIcon;
        try
          Post;
        except
        end;
        ChangeVisibleProp(FieldByName('id').AsString, flag);
        Next;
      end;
    except
    end;
  end;
  UDM.tb_tree.Close();
  UDM.tb_tree.Open();
end;

procedure TfrmPropiedadesNodo.ChangeParentState(State: boolean);
begin
  {while UDM.tb_tree.FieldByName('id').Value<>null do begin
    if UDM.tb_tree.Locate('id', UDM.tb_tree.FieldByName('padre').AsString, [])then
  end;}
end;

procedure TfrmPropiedadesNodo.cpNewNodeButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
begin
  if Button = capClose then
  begin
    cpNewNode.Visible := False;
    if (UDM.tb_tree.State = dsEdit) or (UDM.tb_tree.State = dsInsert) then
      UDM.tb_tree.Cancel;
  end;
end;

procedure TfrmPropiedadesNodo.cxDBCheckBox1PropertiesEditValueChanged(Sender: TObject);
var
  CIcon: integer;
begin
  if (UDM.tb_tree.State <> dsEdit) and (UDM.tb_tree.State <> dsInsert) then
    Exit;
  if UDM.tb_tree.FieldByName('Icono').AsInteger < 7 then
    CIcon := UDM.tb_tree.FieldByName('Icono').AsInteger + 7
  else
    CIcon := UDM.tb_tree.FieldByName('Icono').AsInteger - 7;
  if (UDM.tb_tree.State <> dsInsert) and (UDM.tb_tree.State <> dsEdit) then
    UDM.tb_tree.Edit;
  UDM.tb_tree.FieldByName('Icono').AsInteger := CIcon;
end;

procedure TfrmPropiedadesNodo.cxDBLookupComboBox2PropertiesChange(Sender: TObject);
begin
  idelemento := TcxLookupComboBox(Sender).EditValue;
end;

procedure TfrmPropiedadesNodo.cxDBLookupComboBox2PropertiesCloseUp(Sender: TObject);
var
  Ic: variant;
begin
  if (UDM.tb_tree.State = dsInsert) or (UDM.tb_tree.State = dsedit) then
    UDM.tb_tree.FieldByName('Icono').Value := UDM.Conn.ExecSQLScalar('select icon from cl_tipoobj where idtipoobj=' + VarToStr(idelemento));
    {with UDM.CMD do
    begin
      active := False;
      SQL.Clear;
      SQL.Add('select icon from cl_tipoobj where idtipoobj=' + IntToStr(UDM.VarToInt(lcbTipodeObjeto.EditValue)));
      try
        Active := True;
        UDM.tb_tree.FieldByName('Icono').AsString := Fields[0].AsString;
      except
      end;
    end; }

end;

procedure TfrmPropiedadesNodo.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  if UDM.cl_VarProject.RecordCount > 0 then
  begin
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
    RellenaPrj;
    ToolBar3.Visible := True;
   // Panel4.Visible := True;
  end
  else
  begin
    OcultaVGVardef;
  end;
end;

procedure TfrmPropiedadesNodo.DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
var
  bm:TBookmark;
  idNodoActual:Integer;
  etiqueta:string;
  function FindNode(aId:integer): TTreeNode;
  var
    j: integer;
  begin
    result := nil;
    for j := 0 to tvTreeData.Items.Count - 1 do
      if (PDataRec(tvTreeData.Items[j]).Id = aId)or (tvTreeData.Items[j].Text = etiqueta) then
      begin
        tvTreeData.Items[j].Selected:=True;
        Result := tvTreeData.Items[j];
        Break;
      end;
  end;
begin
  if Button = nbPost then
  begin
    bm:=UDM.tb_tree.GetBookmark;
    SaveTreeStateNode;
    UDM.tb_tree.DisableControls;
    idNodoActual:=PDataRec(AnItem.Data).id;
    etiqueta:=pdatarec(AnItem.Data).Etiqueta;

    UDM.VisualizaOneNodeAndParent(UDM.conn, IntToStr(IdSelectedNode), UDM.tb_tree.FieldByName('visible').AsBoolean);
    UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
    FindNode(idNodoActual);
    UDM.tb_tree.GotoBookmark(bm);
    LoadTreeStateNode;
    UDM.tb_tree.EnableControls;
  end;
end;

procedure TfrmPropiedadesNodo.edtCodEstructuraPropertiesValidate(
  Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption;
  var Error: Boolean);
begin
  if trim(VarToStr(DisplayValue))='' then begin
    ERROR:=False;
    ErrorText:='Este campo no debe ser vacio.'
  end;
end;

procedure TfrmPropiedadesNodo.EliminaPadreSon(IdPadre: integer);
var
  q: TFDQuery;
  flag: Boolean;
  CIcon: Integer;

  procedure ChangeVisibleProp(idPadre: string);
  var
    i: Integer;
  begin
    with TFDQuery.Create(nil) do
    try
      Active := False;
      connection := UDM.Conn;
      SQL.Clear;
      SQL.Add('select * from tb_tree where padre=' + idPadre);
      try
        Active := True;
        First;
        while not Eof do
        begin
          ChangeVisibleProp(FieldByName('id').AsString);
          UDM.Conn.ExecSQL('delete from tb_tree where id=' + FieldByName('id').AsString);
          Next;
        end;
      except
      end;
    finally
      Free;
    end;
  end;

begin
  q := TFDQuery.Create(nil);
  with q do
  begin
    Active := False;
    Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('select * from tb_tree where padre=' + IntToStr(IdPadre));
    try
      Active := True;
      First;
      while not Eof do
      begin
        ChangeVisibleProp(FieldByName('id').AsString);
        UDM.Conn.ExecSQL('delete from tb_tree where id=' + FieldByName('id').AsString);
        Next;
      end;
    except
    end;
  end;
  q.Free;
  UDM.Conn.ExecSQL('delete from tb_tree where id=' + IntToStr(IdPadre));
  UDM.tb_tree.Close();
  UDM.tb_tree.Open();
end;

procedure TfrmPropiedadesNodo.FormActivate(Sender: TObject);
begin
  UDM.tb_tree.Filtered := False;
end;

procedure TfrmPropiedadesNodo.FormCreate(Sender: TObject);
begin
  UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
end;

procedure TfrmPropiedadesNodo.FormResize(Sender: TObject);
begin
  tvTreeData.Align := alNone;
  tvTreeData.Align := alClient;
end;

procedure TfrmPropiedadesNodo.LoadTreeStateNode;
var
  i: Integer;
  List: TStringList;
begin
  if FileExists(PathTemp + 'treestatenode1.src') then
  begin
    List := TStringList.Create;
    try
      List.LoadFromFile(PathTemp + 'treestatenode1.src');
      for i := 0 to List.Count - 1 do
        if List[i] = '1' then
        begin
          tvTreeData.Items[i].Expanded := True;
        end
        else
          tvTreeData.Items[i].Expanded := False;
    except
    end;
    List.Free;
  end;
end;

procedure TfrmPropiedadesNodo.MenuItem6Click(Sender: TObject);
begin
  //eliminará el nodo y todos sus hijos...
  SaveTreeStateNode;
  UDM.sms('La acción actual eliminará al nodo actual y a todos sus hijos.', 2);
  if UDM.sms('¿Está seguro de continuar?. Se elimará le nodo actual y todos sus hijos', 4) = 6 then
  begin
    EliminaPadreSon(UDM.tb_tree.FieldByName('id').AsInteger);
  end;
  UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
  LoadTreeStateNode;
end;

procedure TfrmPropiedadesNodo.O1Click(Sender: TObject);
begin
//  UDM.Visualiza(UDM.Conn, Inttostr(IdSelectedNode), False);
  UDM.VisualizaOneNodeAndParent(UDM.conn, IntToStr(IdSelectedNode), False);
  UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
end;

procedure TfrmPropiedadesNodo.OcultaVGVardef;
var
  i: Integer;
  s: string;
begin
 // UDM.tb_SeriesDatos.DisableControls;
  for i := 1 to 10 do
  begin
    s := 'iv' + inttostr(i);
    TcxDBEditorRow(FindComponent(s)).Visible := false;
    TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := '';
  end;
 // UDM.tb_SeriesDatos.EnableControls;
end;

procedure TfrmPropiedadesNodo.RellenaPrj;
var
  i: integer;
  Qcl_Varsubserie: TFDQuery;
  vs: string;
  vtipo: TFieldType;
  LEN: INTEGER;
  s: string;

  procedure abrirTabla(DS: TDataset);
  begin
    if not DS.active then
      DS.active := true;
  end;

begin
  //tb_SeriesDatos.DisableControls;
  //salvo := false;
 //********************Abrit las tablas*****************************************
  AbrirTabla(UDM.tb_tree);
  AbrirTabla(UDM.cl_VarProject);
  AbrirTabla(UDM.tb_VirtVarDataEstruct);
  //AbrirTabla(tb_VirtualVar);
  Qcl_Varsubserie := TFDQuery.create(self);
  with Qcl_Varsubserie do
  begin
    Active := False;
    Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('SELECT * FROM cl_VarProject WHERE cl_VarProject.IdEstructura=' + QuotedStr(UDM.tb_tree.fieldbyname('idestructura').asstring) + ' AND cl_VarProject.id=' + UDM.tb_tree.FieldByName('id').AsString);
    SQL.Add(' ORDER BY cl_VarProject.idestructura, cl_VarProject.id, cl_VarProject.orden;');
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo acceder al listado de variables asignadas a esta serie. Por favor intentelo de nuevo.', 1);
        Exit;
      end;
    end;

  end;
  if UDM.tb_VirtVarDataEstruct.recordcount = 0 then
  try
    Qcl_Varsubserie.First;
    while not Qcl_Varsubserie.eof do
    begin
      UDM.tb_VirtVarDataEstruct.AppendRecord([UDM.tb_tree.fieldbyname('idestructura').Value, UDM.tb_tree.fieldbyname('id').Value, Qcl_Varsubserie.fieldbyname('orden').Value, Qcl_Varsubserie.fieldbyname('idvar').Value]);
      Qcl_Varsubserie.next;
    end;
    UDM.tb_SerieDatosVar.Active := false;
    UDM.tb_SerieDatosVar.Active := true;
  finally
    Qcl_Varsubserie.Free;
  end;
  varUltimoQuery := '';
  OcultaVGVardef;
  UDM.tb_VirtVarDataEstruct.first;
  i := 1;
  //cxDBVerticalGrid1.DataController.DataSource := UDM.Dtb_VirtualVar;
  while not UDM.tb_VirtVarDataEstruct.Eof do
  begin
    s := 'iv' + inttostr(i);
    if UDM.cl_Variables.Locate('idvar', UDM.tb_VirtVarDataEstruct.FieldByName('idvar').Value, []) then
    begin
      TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := UDM.cl_Variables.fieldbyname('NomVariable').asstring;
      TcxDBEditorRow(FindComponent(s)).Properties.Caption := UDM.cl_Variables.fieldbyname('Etiqueta').AsString;
      TcxDBEditorRow(FindComponent(s)).Index := i + 11;
      TcxDBEditorRow(FindComponent(s)).Visible := true;
    end;
    i := i + 1;
    UDM.tb_VirtVarDataEstruct.Next;
  end;
 //------------------------------------------------------------------------------
  UDM.tb_VirtVarDataEstruct.First;
  while not UDM.tb_VirtVarDataEstruct.eof do
  begin
    if UDM.cl_Variables.Locate('idvar', UDM.tb_VirtVarDataEstruct.FieldByName('idvar').Value, []) then
    begin
      s := uppercase(UDM.cl_Variables.fieldbyname('tipo').AsString);
      LEN := UDM.cl_Variables.fieldbyname('LONGITUD').AsInteger;
      if s = 'ENTERO' then
      begin
        vtipo := ftsmallint;
        LEN := 0;
      end
      else if s = 'REAL' then
      begin
        vtipo := ftfloat;
        LEN := 0;
      end
      else if s = 'FECHA' then
      begin
        vtipo := ftdate;
        LEN := 0;
      end
      else
      begin
        vtipo := ftSTRING;
        if (UDM.cl_Variables.fieldbyname('longitud').Value = NULL) or (UDM.cl_Variables.fieldbyname('longitud').Value = 0) then
          LEN := 255;
      end;
      UDM.tb_VirtualVar.FieldDefs.Add(UDM.cl_Variables.fieldbyname('NomVariable').asstring, vtipo, LEN);
    end;
    UDM.tb_VirtVarDataEstruct.next;
  end;
  UDM.tb_VirtualVar.CreateDataSet;
  if not UDM.tb_VirtualVar.active then
    UDM.tb_VirtualVar.Active := true;
 //**************** Adicionar los valores ***************************************
  UDM.tb_VirtVarDataEstruct.First;
  while not UDM.tb_VirtVarDataEstruct.eof do
  begin
    UDM.tb_VirtualVar.edit;
    if UDM.cl_Variables.Locate('idvar', UDM.tb_VirtVarDataEstruct.FieldByName('idvar').Value, []) then
    begin
      s := uppercase(UDM.cl_Variables.fieldbyname('tipo').asstring);
      if s = 'ENTERO' then
        vs := 'VarInteger'
      else if s = 'REAL' then
        vs := 'VarDouble'
      else if s = 'FECHA' then
        vs := 'VarDate'
      else
        vs := 'VarString255';
      UDM.tb_VirtualVar.FieldByName(UDM.cl_Variables.fieldbyname('NomVariable').asstring).Value := UDM.tb_VirtVarDataEstruct.fieldbyname(vs).Value;
      UDM.tb_VirtualVar.post;
    end;
    UDM.tb_VirtVarDataEstruct.next;
  end;
 // tb_SeriesDatos.EnableControls;
//****************************************************************************
end;

procedure TfrmPropiedadesNodo.SaveTreeStateNode;
var
  i: integer;
  List: TStringList;
begin
  List := TStringList.Create;
  for i := 0 to tvTreeData.Items.Count - 1 do
    if tvTreeData.Items[i].Expanded then
    begin
      List.Add('1');
    end
    else
      List.Add('0');
  List.SaveToFile(PathTemp + 'treestatenode1.src');
  List.Free;
end;

procedure TfrmPropiedadesNodo.SpeedButton1Click(Sender: TObject);
begin
  if (UDM.tb_tree.State = dsInsert) or (UDM.tb_tree.State = dsEdit) then
  begin
    UDM.sms('Debe aceptar los cambios realizados en la estructura para entrar a gestionar sus variables.', 2);
    Exit;
  end;

  with UDM.tb_tree do
  begin
    Filtered := False;
    Filter := 'aowner<>' + QuotedStr('system');
    Filtered := True;
  end;
  if UDM.tb_tree.RecordCount > 0 then
  begin
    //UDM.UpdateVarSubS(UDM.cl_subseries.FieldByName('codsubs').AsString);
    UDM.UpdateVarPrj(UDM.tb_tree.FieldByName('IdEstructura').AsString, UDM.tb_tree.FieldByName('id').AsString);
    TipoObj := 'EE';
    with TfrmVarVirtualVar.Create(nil) do
    try
      cxGridDBTableView1.DataController.DataSource := UDM.dsVarDispPrj;
      if TipoObj = 'EE' then
        Caption := 'Variables asignadas a la Estructura ' + AnsiQuotedStr(UDM.tb_tree.FieldByName('etiqueta').AsString, '"');
      ShowModal;
    finally
      Free;
    end;
  end
  else
  begin
    UDM.sms('Debe existir al menos una serie documental valida.', 2);
  end;
  with UDM.tb_tree do
  begin
    Filtered := False;
    Filter := '';
  end;
end;

procedure TfrmPropiedadesNodo.ToolButton9Click(Sender: TObject);
var
  i: integer;
  si: boolean;
  SCampo: string;
begin
  salvo := true;
  if (UDM.tb_VirtualVar.State <> dsedit) and (UDM.tb_VirtualVar.State <> dsinsert) then
    UDM.tb_VirtualVar.edit;
  for i := CantIndex to UDM.tb_VirtualVar.fieldcount - 1 do
  begin
    s := UDM.tb_VirtualVar.Fields[i].FieldName;
    if (UDM.tb_VirtualVar.Fields[i].Value = Null) then
      salvo := false;
  end;
  if not salvo then
  begin
    if UDM.sms('Existen variables que no han tomado valor. ¿Las salvará de todas formas?', 4) = 6 then
      salvo := true;
  end;
  if salvo then
  begin
    UDM.tb_VirtVarDataEstruct.First;
    for i := 0 to UDM.tb_Virtualvar.fieldcount - 1 do
    begin
      UDM.tb_VirtVarDataEstruct.Edit;
      if UDM.cl_variables.locate('NomVariable', UDM.tb_Virtualvar.fields[i].FieldName, []) then
        s := uppercase(UDM.cl_variables.fieldbyname('tipo').asstring);
      if s = 'ENTERO' then
        SCampo := 'VarInteger'
      else if s = 'REAL' then
        SCampo := 'VarDouble'
      else if s = 'FECHA' then
        SCampo := 'VarDate'
      else
        SCampo := 'VarString255';
      UDM.tb_VirtVarDataEstruct.fieldbyname(SCampo).Value := UDM.tb_VirtualVar.fields[i].Value;
      UDM.tb_VirtVarDataEstruct.Post;
      UDM.tb_VirtVarDataEstruct.next;
    end;
   // close;
    UDM.sms('Los cambios se realizaron satisfactoriamente.', 3);
  end;
end;

procedure TfrmPropiedadesNodo.TvTreeChange(Sender: TObject; Node: TTreeNode);
begin
  //TvTree.SelectedIndex := UDM.tb_tree.FieldByName('icono').AsInteger;
end;

procedure TfrmPropiedadesNodo.tvTreeDataMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HT: THitTests;
  id: Integer;
begin
  HT := tvTreeData.GetHitTestInfoAt(X, Y);
  AnItem := tvTreeData.GetNodeAt(X, Y);
  if (HT - [htOnItem, htOnLabel] <> HT) then
  begin
    if Button = mbRight then
    begin
      if (AnItem <> nil) and (trim(AnItem.Text) <> '') then
      begin
        IdSelectedNode := PDataRec(AnItem.Data).id;
        APMArbol.PopupAtCursor;
      end;
    end
    else
    begin
      if AnItem.Text <> '' then
      begin
        etiquetaNA := PDataRec(AnItem.data).Etiqueta;
        MB.Panels[1].Text:=etiquetaNA;
        id := PDataRec(AnItem.Data).id;
        IdSelectedNode := PDataRec(AnItem.Data).id;
        if UDM.tb_tree.Locate('id', id, []) then
        begin
          s := s;
        end;
      end;
    end;
  end;
end;

procedure TfrmPropiedadesNodo.TvTreeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 { AnItem := TvTree.GetNodeAt(X, Y);
  if AnItem <> nil then
  begin
    if Button = mbRight then
    begin
    end
    else
    begin
      TvTree.SelectedIndex:=UDM.tb_tree.FieldByName('Icono').AsInteger;
    end;
  end;  }
end;

procedure TfrmPropiedadesNodo.v1Click(Sender: TObject);
begin
  UDM.Visualiza(UDM.Conn, Inttostr(IdSelectedNode), True);
  UDM.VisualizaOneNodeAndParent(UDM.conn, IntToStr(IdSelectedNode), True);
  UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
end;

end.

