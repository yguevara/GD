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
  JvExtComponent, JvCaptionPanel, AdvOfficeStatusBar, frxClass, frxADOComponents,
  frxRich, frxDBSet, frxExportXLS, frxExportBaseDialog, frxExportPDF;

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
    Timer1: TTimer;
    pMainContainer: TPanel;
    btncerrar: TJvTransparentButton;
    btnadd: TJvTransparentButton;
    btnView: TJvTransparentButton;
    btnHide: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btndel: TJvTransparentButton;
    Edit1: TEdit;
    Panel1: TPanel;
    frxMain: TfrxReport;
    frxtb_sysconfig: TfrxDBDataset;
    frxPDFExport1: TfrxPDFExport;
    frxXLSExport1: TfrxXLSExport;
    cxPageControl2: TcxPageControl;
    tsnode: TcxTabSheet;
    tsmainNode: TcxTabSheet;
    Panel6: TPanel;
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
    Panel7: TPanel;
    GroupBox1: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    cxDBTextEdit1: TcxDBTextEdit;
    cxDBTextEdit2: TcxDBTextEdit;
    cxDBCheckBox2: TcxDBCheckBox;
    Label7: TLabel;
    Label8: TLabel;
    font: TJvTransparentButton;
    FontDialog1: TFontDialog;
    ppmtvTree: TAdvPopupMenu;
    MtvFont: TMenuItem;
    MenuItem1: TMenuItem;
    pmtvReset: TMenuItem;
    PPMDescript: TAdvPopupMenu;
    MenuItem3: TMenuItem;
    AdvPopupMenu1: TAdvPopupMenu;
    MenuItem2: TMenuItem;
    F1: TMenuItem;
    C1: TMenuItem;
    R1: TMenuItem;
    procedure btnCloseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
    procedure cxDBCheckBox1PropertiesEditValueChanged(Sender: TObject);
    procedure TvTreeChange(Sender: TObject; Node: TTreeNode);
    procedure TvTreeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure A2Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvTreeDataMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure cxDBLookupComboBox2PropertiesCloseUp(Sender: TObject);
    procedure cxDBLookupComboBox2PropertiesChange(Sender: TObject);
    procedure v1Click(Sender: TObject);
    procedure O1Click(Sender: TObject);
    procedure edtCodEstructuraPropertiesValidate(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure Panel3Resize(Sender: TObject);
    procedure cpNewNodeEndAutoDrag(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure lcbTipodeObjetoPropertiesCloseUp(Sender: TObject);
    procedure tvTreeDataCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure cxPageControl2Change(Sender: TObject);
    procedure MtvFontClick(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure pmtvResetClick(Sender: TObject);
    procedure F1Click(Sender: TObject);
    procedure C1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure R1Click(Sender: TObject);
  private
    procedure ReActiveFather(aId: Integer);
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
    procedure CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
    procedure InsertConnection(report: TfrxReport; connection: string);
    function FindNode(aId: integer; Etiqueta: string): TTreeNode;
    procedure ValidateParentNode(Node: TTreeNode);
    procedure RestrictMoveOrChangeParent(Node: TTreeNode);
    procedure SaveTreeViewFont(TreeView: TTreeView; const FileName: string);
    procedure LoadTreeViewFont(TreeView: TTreeView; const FileName: string);
    procedure SaveRichEditFont(RichEdit: TcxDBRichEdit; const FileName: string);
    procedure LoadRichEditFont(RichEdit: TcxDBRichEdit; const FileName: string);
  end;

var
  frmPropiedadesNodo: TfrmPropiedadesNodo;
  AnItem1: TTreeNode;
  IdSelectedNode: integer;
  S: string;
  salvo: boolean;
  CantIndex: integer;
  idelemento: Variant;

implementation

uses
  UCapaDatos, UVarVirtualVar, USystemMsg, UNewNodefrm;

{$R *.dfm}
procedure TfrmPropiedadesNodo.LoadRichEditFont(RichEdit: TcxDBRichEdit; const FileName: string);
var
  FileStream: TextFile;
  Line, Value: string;
begin
  AssignFile(FileStream, FileName);
  Reset(FileStream);
  try
    while not Eof(FileStream) do
    begin
      Readln(FileStream, Line);

      // Leer y aplicar el nombre de la fuente
      if Pos('FontName=', Line) = 1 then
      begin
        Value := Copy(Line, Length('FontName=') + 1, MaxInt);
        RichEdit.Style.Font.Name := Value;
      end;

      // Leer y aplicar el tamaño de la fuente
      if Pos('FontSize=', Line) = 1 then
      begin
        Value := Copy(Line, Length('FontSize=') + 1, MaxInt);
        RichEdit.Style.Font.Size := StrToInt(Value);
      end;

      // Leer y aplicar el color de la fuente
      if Pos('FontColor=', Line) = 1 then
      begin
        Value := Copy(Line, Length('FontColor=') + 1, MaxInt);
        RichEdit.Style.Font.Color := StringToColor('$' + Value);
      end;

      // Leer y aplicar los estilos de la fuente
      if Pos('FontStyle=', Line) = 1 then
      begin
        RichEdit.Style.Font.Style := [];
        Readln(FileStream, Line);
        if Line = 'Bold' then
          RichEdit.Style.Font.Style := RichEdit.Style.Font.Style + [fsBold];
        if Line = 'Italic' then
          RichEdit.Style.Font.Style := RichEdit.Style.Font.Style + [fsItalic];
        if Line = 'Underline' then
          RichEdit.Style.Font.Style := RichEdit.Style.Font.Style + [fsUnderline];
        if Line = 'StrikeOut' then
          RichEdit.Style.Font.Style := RichEdit.Style.Font.Style + [fsStrikeOut];
      end;
    end;
  finally
    CloseFile(FileStream);
  end;
end;

procedure TfrmPropiedadesNodo.SaveRichEditFont(RichEdit: TcxDBRichEdit; const FileName: string);
var
  FileStream: TextFile;
begin
  AssignFile(FileStream, FileName);
  Rewrite(FileStream);
  try
    // Guardar nombre de la fuente
    Writeln(FileStream, 'FontName=' + RichEdit.Style.Font.Name);

    // Guardar tamaño de la fuente
    Writeln(FileStream, 'FontSize=' + IntToStr(RichEdit.Style.Font.Size));

    // Guardar color de la fuente en formato hexadecimal
    Writeln(FileStream, 'FontColor=' + IntToHex(RichEdit.Style.Font.Color, 6));

    // Guardar estilos de la fuente (Bold, Italic, etc.)
    Writeln(FileStream, 'FontStyle=');
    if fsBold in RichEdit.Style.Font.Style then
      Writeln(FileStream, 'Bold');
    if fsItalic in RichEdit.Style.Font.Style then
      Writeln(FileStream, 'Italic');
    if fsUnderline in RichEdit.Style.Font.Style then
      Writeln(FileStream, 'Underline');
    if fsStrikeOut in RichEdit.Style.Font.Style then
      Writeln(FileStream, 'StrikeOut');
  finally
    CloseFile(FileStream);
  end;
end;

procedure TfrmPropiedadesNodo.A2Click(Sender: TObject);
var
  Idpp: Integer;
  Padre: string;
  bm: TBookmark;
begin
  tvTreeData.Items.BeginUpdate;
  bm := UDM.tb_tree.GetBookmark;
  SaveTreeStateNode;
  Idpp := UDM.tb_tree.FieldByName('id').AsInteger;
  //
  NombrePadreEditar := UDM.tb_tree.FieldByName('etiqueta').AsString; //UDM.Conn.ExecSQLScalar(Padre);
  IdPadreEditar := Idpp;
  administradornodoeditar := UDM.tb_tree.FieldByName('aowner').AsString;
  Padre := UDM.Conn.ExecSQLScalar('SELECT tb_tree.etiqueta FROM tb_tree where id=' + inttostr(Idpp) + '  and visible=1 ORDER BY etiqueta ASC');
  if UDM.sms('¿Desea agregar un hijo al nodo actual (' + NombrePadreEditar + ')?', 4) = 6 then
  begin
    UDM.tb_tree.Append;
    UDM.tb_tree.FieldByName('Id').AsInteger := UDM.GetLastId('tb_tree', 'id');
    UDM.tb_tree.FieldByName('Padre').AsInteger := IdPadreEditar; //aowner
    UDM.tb_tree.FieldByName('aowner').AsString := administradornodoeditar;
    UDM.tb_tree.FieldByName('visible').AsBoolean := True;
    tvActivo := @tvTreeData;
    with TfrmNewNodeform.Create(nil) do
    try
      Caption := 'Nuevo nodo hijo de ' + AnsiQuotedStr(Padre, '"');
      ShowModal;
    finally
      Free;
//      UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
      UDM.CargarArbol(tvTreeData, UDM.tb_arbol, true);
      AnItem1 := FindNode(Udm.tb_tree.FieldByName('ID').AsInteger, Udm.tb_tree.FieldByName('Etiqueta').AsString);
      LoadTreeStateNode;
      UDM.tb_tree.EnableControls;
      LoadTreeStateNode;
      tvTreeData.Items.EndUpdate;
    end;
  end;
//  cpNewNode.Caption := 'Nuevo nodo hijo de ' + AnsiQuotedStr(Padre, '"');
//  cpNewNode.Visible := True;
end;

procedure TfrmPropiedadesNodo.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPropiedadesNodo.btnPrintClick(Sender: TObject);
begin
  UDM.MostrarReporte('Cuadro_ClasificacionAdmin');
  {
    //esta validacion la puse aqui pero puede ser en otro lugar si deseas
  if ((UDM.tb_sysconfig.FieldByName('empresa').AsString <> '') and (not TBlobField(UDM.tb_sysconfig.FieldByName('logo')).IsNull)) then
  begin
     //salvar el logo que esta en la tabla de configuracion a la carpeta de reportes ,que ahora esta a nivel del mosulo
     //principal
    TBlobField(UDM.tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
    //todos los parametros para cargar el reporte
    CargaReporte(frxMain, pathreport + 'rCuadro_ClasificacionAdmin.fr3', 'empresa', UDM.tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png');
  end
  else
  begin
    udm.sms('Debe configurar los Datos de la Empresa. Diríjase a la configuración del Sistema', 1);
  end;   }
end;

procedure TfrmPropiedadesNodo.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 21;
  Application.HelpContext(TopicID);
end;

procedure TfrmPropiedadesNodo.C1Click(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    // Asignar la fuente seleccionada al campo descripción...
    edtDescripcion.Style.Font.Assign(FontDialog1.Font);
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

procedure TfrmPropiedadesNodo.CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
var
  Component: TfrxComponent;
begin
  with report do
  begin
    LoadFromFile(pathreport);
    InsertConnection(report, PathBD);
    Component := FindObject(nameempresa);
    if Component is TfrxRichView then
      TfrxRichView(Component).DataSet := frxtb_sysconfig;
    TfrxRichView(Component).DataField := 'empresa';
    Component := FindObject(nameimagen);
    if Component is TfrxPictureView then
      TfrxPictureView(Component).Picture.LoadFromFile(pathimagen);
    PrepareReport();
    ShowReport();
  end;
end;

procedure TfrmPropiedadesNodo.ChangeParentState(State: boolean);
begin
  {while UDM.tb_tree.FieldByName('id').Value<>null do begin
    if UDM.tb_tree.Locate('id', UDM.tb_tree.FieldByName('padre').AsString, [])then
  end;}
end;

procedure TfrmPropiedadesNodo.cpNewNodeEndAutoDrag(Sender: TObject);
begin
  UDM.Boundarys(Sender);
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
end;

procedure TfrmPropiedadesNodo.cxPageControl2Change(Sender: TObject);
begin
  edtDescripcion.Height := 100;
end;

procedure TfrmPropiedadesNodo.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  Caption := 'Propiedades del nodo actual (' + UDM.tb_tree.FieldByName('etiqueta').AsString + ')';
end;

procedure TfrmPropiedadesNodo.DBNavigator1Click(Sender: TObject; Button: TNavigateBtn);
var
  bm: TBookmark;
  idNodoActual: Integer;
  etiqueta: string;
begin
  if Button = nbPost then
  begin
    tvTreeData.Items.BeginUpdate;
    bm := UDM.tb_tree.GetBookmark;
    SaveTreeStateNode;
    UDM.tb_tree.DisableControls;
    if AnItem1 <> nil then
    begin
      try
        idNodoActual := PDataRec(AnItem1.Data).id;
        etiqueta := PDataRec(AnItem1.Data).etiqueta;
      except
        on E: Exception do


      end;
    end;
    UDM.VisualizaOneNodeAndParent(UDM.conn, IntToStr(IdSelectedNode), UDM.tb_tree.FieldByName('visible').AsBoolean);
//    UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
    UDM.CargarArbol(tvTreeData, UDM.tb_arbol, true);
    FindNode(idNodoActual, etiqueta);
    UDM.tb_tree.GotoBookmark(bm);
    LoadTreeStateNode;
    UDM.tb_tree.EnableControls;
    tvTreeData.Items.EndUpdate;
  end;
end;

procedure TfrmPropiedadesNodo.edtCodEstructuraPropertiesValidate(Sender: TObject; var DisplayValue: Variant; var ErrorText: TCaption; var Error: Boolean);
begin
  if trim(VarToStr(DisplayValue)) = '' then
  begin
    Error := False;
    ErrorText := 'Este campo no debe ser vacio.'
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
          try
            UDM.Conn.StartTransaction;
            UDM.Conn.ExecSQL('delete from tb_tree where id=' + FieldByName('id').AsString);
            UDM.Conn.Commit;
          except
            UDM.Conn.Rollback;
          end;
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
        try
          UDM.Conn.StartTransaction;
          UDM.Conn.ExecSQL('delete from tb_tree where id=' + FieldByName('id').AsString);
          UDM.Conn.Commit;
        except
          UDM.Conn.Rollback;
        end;

        Next;
      end;
    except
    end;
  end;
  q.Free;
  UDM.Conn.ExecSQL('delete from tb_tree where id=' + IntToStr(IdPadre));
  EstoyActualizando := True;
  UDM.tb_tree.Refresh;
  {UDM.tb_tree.Close();
  UDM.tb_tree.Open();}
  EstoyActualizando := False;
end;

procedure TfrmPropiedadesNodo.F1Click(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    // Asignar la fuente seleccionada al TreeView
    tvTreeData.Font.Assign(FontDialog1.Font);
  end;
end;

function TfrmPropiedadesNodo.FindNode(aId: integer; Etiqueta: string): TTreeNode;
var
  j: integer;
begin
  result := nil;
  for j := 0 to tvTreeData.Items.Count - 1 do
    if (PDataRec(tvTreeData.Items[j]).Id = aId) or (tvTreeData.Items[j].Text = Etiqueta) then
    begin
      tvTreeData.Items[j].Selected := True;
      Result := tvTreeData.Items[j];
      Break;
    end;
end;

procedure TfrmPropiedadesNodo.FormActivate(Sender: TObject);
begin
  Edit1.Focused;
  Edit1.SetFocus;
  UDM.tb_tree.Filtered := False;
  ReActiveFather(UDM.tb_tree.FieldByName('id').Value);
end;

procedure TfrmPropiedadesNodo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  SaveTreeViewFont(tvTreeData, PathTemp + '\tvTreeData.ini');
  SaveRichEditFont(edtDescripcion, PathTemp + '\ccDescript.ini');
end;

procedure TfrmPropiedadesNodo.FormCreate(Sender: TObject);
begin
  tvTreeData.Items.BeginUpdate;
  UDM.CargarArbol(tvTreeData, UDM.tb_arbol, true);
  udm.FindNode(tvTreeData, UDM.tb_tree.FieldByName('id').AsInteger, UDM.tb_tree.FieldByName('Etiqueta').AsString);
  tvTreeData.Items.EndUpdate;
end;

procedure TfrmPropiedadesNodo.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
  if Key = 112 then
  begin
    {TopicID := 21;
    HelpFile := ExtractFilePath(Application.ExeName) + 'ArchiGenioPro.chm';          }
    Application.HelpContext(21);
    //Application.HelpSystem.ShowContextHelp(TopicID, HelpFile);
  end;
end;

procedure TfrmPropiedadesNodo.FormResize(Sender: TObject);
begin
  //Panel3.Width := Width - (GroupBox3.width + 76);
  edtDescripcion.height := panel4.height - Label6.top - 30;

  tvTreeData.Align := alNone;
  tvTreeData.Align := alClient;
end;

procedure TfrmPropiedadesNodo.FormShow(Sender: TObject);
begin
  if FileExists(PathTemp + '\tvTreeData.ini') then
    LoadTreeViewFont(tvTreeData, PathTemp + '\tvTreeData.ini');
  if FileExists(PathTemp + '\ccDescript.ini') then
    LoadRichEditFont(edtDescripcion, PathTemp + '\ccDescript.ini');
end;

procedure TfrmPropiedadesNodo.InsertConnection(report: TfrxReport; connection: string);
var
  i: integer;
begin
  TfrxADODatabase(report.FindComponent('conn')).Connected := false;
  if TBD = 'A' then
    TfrxADODatabase(report.FindComponent('conn')).DatabaseName := 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=' + connection + ';Persist Security Info=False'
  else
    TfrxADODatabase(report.FindComponent('conn')).DatabaseName := 'Provider=SQLOLEDB.1;Password=geoconn;Persist Security Info=True;User ID=geoconn;Initial Catalog=SDbd;Data Source=' + UDM.tb_sysconfig.FieldByName('ipservidorbd').AsString;
  TfrxADODatabase(report.FindComponent('conn')).Connected := True;
  for i := 0 to report.ComponentCount - 1 do
  begin
    if report.Components[i] is TfrxADOQuery then
    begin
      if TfrxADOQuery(report.Components[i]).Params.Count = 0 then
      begin
        TfrxADOQuery(report.Components[i]).Active := True;
      end;

    end;
  end;
end;

procedure TfrmPropiedadesNodo.lcbTipodeObjetoPropertiesCloseUp(Sender: TObject);
var
  bm: TBookmark;
  idNodoActual: Integer;
  etiqueta: string;
begin
  bm := UDM.tb_tree.GetBookmark;
  if (UDM.tb_tree.State = dsedit) or (UDM.tb_tree.State = dsInsert) then
    UDM.tb_tree.Post;
  tvTreeData.Items.BeginUpdate;
  SaveTreeStateNode;
  UDM.tb_tree.DisableControls;
  if AnItem1 <> nil then
  begin
    try
      idNodoActual := PDataRec(AnItem1.Data).id;
      etiqueta := PDataRec(AnItem1.Data).etiqueta;
    except
      on E: Exception do


    end;
  end;
  UDM.VisualizaOneNodeAndParent(UDM.conn, IntToStr(IdSelectedNode), UDM.tb_tree.FieldByName('visible').AsBoolean);
//    UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
  UDM.CargarArbol(tvTreeData, UDM.tb_arbol, true);
  FindNode(idNodoActual, etiqueta);
  UDM.tb_tree.GotoBookmark(bm);
  LoadTreeStateNode;
  UDM.tb_tree.EnableControls;
  tvTreeData.Items.EndUpdate;
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

procedure TfrmPropiedadesNodo.LoadTreeViewFont(TreeView: TTreeView; const FileName: string);
var
  FileStream: TextFile;
  Line: string;
begin
  AssignFile(FileStream, FileName);
  Reset(FileStream);
  try
    while not Eof(FileStream) do
    begin
      Readln(FileStream, Line);

      // Cargar nombre de la fuente
      if Pos('FontName=', Line) = 1 then
        TreeView.Font.Name := Copy(Line, Length('FontName=') + 1, MaxInt);

      // Cargar tamaño de la fuente
      if Pos('FontSize=', Line) = 1 then
        TreeView.Font.Size := StrToIntDef(Copy(Line, Length('FontSize=') + 1, MaxInt), TreeView.Font.Size);

      // Cargar color de la fuente
      if Pos('FontColor=', Line) = 1 then
        TreeView.Font.Color := StrToInt('$' + Copy(Line, Length('FontColor=') + 1, MaxInt));

      // Cargar estilos de la fuente
      if Pos('FontStyle=', Line) = 1 then
      begin
        TreeView.Font.Style := [];
        while not Eof(FileStream) do
        begin
          Readln(FileStream, Line);
          if Line = 'Bold' then
            TreeView.Font.Style := TreeView.Font.Style + [fsBold];
          if Line = 'Italic' then
            TreeView.Font.Style := TreeView.Font.Style + [fsItalic];
          if Line = 'Underline' then
            TreeView.Font.Style := TreeView.Font.Style + [fsUnderline];
          if Line = 'StrikeOut' then
            TreeView.Font.Style := TreeView.Font.Style + [fsStrikeOut];
        end;
      end;
    end;
  finally
    CloseFile(FileStream);
  end;
end;

procedure TfrmPropiedadesNodo.R1Click(Sender: TObject);
begin
  if UDM.sms('¿Realmente restablecer la fuente por defecto en el árbol del Cuadro de Clasificación Documental (CCD)?', 4) = 6 then
  begin
    LoadTreeViewFont(tvTreeData, PathSys + '\Resources\tvtree.ini');
  end;
end;

procedure TfrmPropiedadesNodo.ReActiveFather(aId: Integer);
var
  cad: string;
begin
  Padres.Active := False;
  if TBD = 'A' then
  begin
    cad := 'SELECT tb_tree.id, tb_tree.etiqueta';
    cad := cad + ' FROM tb_tree where id<>' + IntToStr(aId) + '  and visible=true ORDER BY etiqueta ASC';
  end
  else
  begin
    cad := 'SELECT tb_tree.id, tb_tree.etiqueta';
    cad := cad + ' FROM tb_tree where id<>' + IntToStr(aId) + '  and visible=1 ORDER BY etiqueta ASC';
  end;
  Padres.SQL.Clear;
  Padres.SQL.Add(cad);
  Padres.Active := True;
end;

procedure TfrmPropiedadesNodo.MenuItem3Click(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    // Asignar la fuente seleccionada al TreeView
    edtDescripcion.Style.Font.Assign(FontDialog1.Font);
  end;
end;

procedure TfrmPropiedadesNodo.MenuItem6Click(Sender: TObject);
begin
 //eliminará el nodo y todos sus hijos...
  if UDM.tb_tree.FieldByName('padre').AsInteger = 0 then
  begin
    UDM.sms('¡EL NODO ACTUAL (' + UDM.tb_tree.FieldByName('etiqueta').AsString + ') NO SE PUEDE ELIMINAR!.', 1);
    EXIT;
  end;
  SaveTreeStateNode;
  UDM.sms('La acción actual eliminará al nodo actual (' + UDM.tb_tree.FieldByName('etiqueta').AsString + ') y a todos sus hijos.', 2);
  if UDM.sms('¿Está seguro de continuar?. Se elimará el nodo actual (' + UDM.tb_tree.FieldByName('etiqueta').AsString + ') y todos sus hijos', 4) = 6 then
  begin
    EliminaPadreSon(UDM.tb_tree.FieldByName('id').AsInteger);
  end;
  tvTreeData.Items.BeginUpdate;
  //UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
  UDM.CargarArbol(tvTreeData, UDM.tb_arbol, True);
  tvTreeData.Items.EndUpdate;
  tvTreeData.Items.BeginUpdate;
  LoadTreeStateNode;
  tvTreeData.Items.EndUpdate;
end;

procedure TfrmPropiedadesNodo.MtvFontClick(Sender: TObject);
begin
  if FontDialog1.Execute then
  begin
    // Asignar la fuente seleccionada al TreeView
    tvTreeData.Font.Assign(FontDialog1.Font);
  end;
end;

procedure TfrmPropiedadesNodo.O1Click(Sender: TObject);
begin
  UDM.VisualizaOneNodeAndParent(UDM.conn, IntToStr(IdSelectedNode), False);
//  UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
  UDM.CargarArbol(tvTreeData, UDM.tb_arbol, True);
end;

procedure TfrmPropiedadesNodo.OcultaVGVardef;
var
  i: Integer;
  s: string;
begin
 // UDM.tb_SeriesDatos.DisableControls;
  {for i := 1 to 10 do
  begin
    s := 'iv' + inttostr(i);
    TcxDBEditorRow(FindComponent(s)).Visible := false;
    TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := '';
  end;  }
 // UDM.tb_SeriesDatos.EnableControls;
end;

procedure TfrmPropiedadesNodo.Panel3Resize(Sender: TObject);
begin
  Width := Panel3.Width + (GroupBox3.width + 76);
end;

procedure TfrmPropiedadesNodo.pmtvResetClick(Sender: TObject);
begin
  if UDM.sms('¿Realmente restablecer la fuente por defecto en el árbol del Cuadro de Clasificación Documental (CCD)?', 4) = 6 then
  begin
    LoadTreeViewFont(tvTreeData, PathSys + '\Resources\tvtree.ini');
  end;
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
{  AbrirTabla(UDM.tb_tree);
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
  end;                         }
 // tb_SeriesDatos.EnableControls;
//****************************************************************************
end;

procedure TfrmPropiedadesNodo.RestrictMoveOrChangeParent(Node: TTreeNode);
const
  ProtectedNodes: array[0..2] of string = ('ESTRUCTURA EMPRESA', 'PROCESOS', 'CONTENIDOS');
var
  i: Integer;
begin
  for i := Low(ProtectedNodes) to High(ProtectedNodes) do
  begin
    if Node.Text = ProtectedNodes[i] then
    begin
      raise Exception.Create('No se puede mover o cambiar el padre del nodo "' + Node.Text + '".');
    end;
  end;
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

procedure TfrmPropiedadesNodo.SaveTreeViewFont(TreeView: TTreeView; const FileName: string);
var
  FileStream: TextFile;
begin
  AssignFile(FileStream, FileName);
  Rewrite(FileStream);
  try
    // Guardar nombre de la fuente
    Writeln(FileStream, 'FontName=' + TreeView.Font.Name);

    // Guardar tamaño de la fuente
    Writeln(FileStream, 'FontSize=' + IntToStr(TreeView.Font.Size));

    // Guardar color de la fuente en formato hexadecimal
    Writeln(FileStream, 'FontColor=' + IntToHex(TreeView.Font.Color, 6));

    // Guardar estilos de la fuente (Bold, Italic, etc.)
    Writeln(FileStream, 'FontStyle=');
    if fsBold in TreeView.Font.Style then
      Writeln(FileStream, 'Bold');
    if fsItalic in TreeView.Font.Style then
      Writeln(FileStream, 'Italic');
    if fsUnderline in TreeView.Font.Style then
      Writeln(FileStream, 'Underline');
    if fsStrikeOut in TreeView.Font.Style then
      Writeln(FileStream, 'StrikeOut');
  finally
    CloseFile(FileStream);
  end;
end;

procedure TfrmPropiedadesNodo.SpeedButton1Click(Sender: TObject);
begin
{  if (UDM.tb_tree.State = dsInsert) or (UDM.tb_tree.State = dsEdit) then
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
  end;     }
end;

procedure TfrmPropiedadesNodo.ToolButton9Click(Sender: TObject);
var
  i: integer;
  si: boolean;
  SCampo: string;
begin
 { salvo := true;
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
  end;     }
end;

procedure TfrmPropiedadesNodo.TvTreeChange(Sender: TObject; Node: TTreeNode);
begin
  //TvTree.SelectedIndex := UDM.tb_tree.FieldByName('icono').AsInteger;
end;

procedure TfrmPropiedadesNodo.tvTreeDataCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if cdsSelected in State then
  begin
    // Mantén el nodo resaltado incluso si el TreeView pierde el foco
    tvTreeData.Canvas.Brush.Color := $00EFCD85; //clHighlight;
    tvTreeData.Canvas.Font.Style := [fsBold, fsUnderline];
    tvTreeData.Canvas.Font.Color := clWindowText; //clHighlightText;
  end
  else
  begin
    // Dibuja los nodos no seleccionados con el color de fondo predeterminado
    tvTreeData.Canvas.Brush.Color := clWindow;
    tvTreeData.Canvas.Font.Style := [];
    tvTreeData.Canvas.Font.Color := clWindowText;
  end;

  DefaultDraw := True; // Permite que Delphi dibuje el nodo con los colores establecidos
end;

procedure TfrmPropiedadesNodo.tvTreeDataMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
const
  ProtectedNodes: array[0..2] of string = ('ESTRUCTURA EMPRESA', 'PROCESOS', 'CONTENIDOS');
var
  HT: THitTests;
  ident, i: Integer;
begin
  HT := tvTreeData.GetHitTestInfoAt(X, Y);
  AnItem1 := tvTreeData.GetNodeAt(X, Y);
  if (HT - [htOnItem, htOnLabel] <> HT) then
  begin
    if Button = mbRight then
    begin
      if (AnItem1 <> nil) and (trim(AnItem1.Text) <> '') then
      begin
        IdSelectedNode := PDataRec(AnItem1.Data).id;
        APMArbol.PopupAtCursor;
      end;
    end
    else
    begin
      if AnItem1.Text <> '' then
      begin
        if AnItem1.Parent = nil then
        begin
          cxPageControl2.ActivePage := tsmainNode;
          edtDescripcion.Height := 190;
        end
        else
        begin
          try
            edtDescripcion.Height := 100;
            cxPageControl2.ActivePage := tsnode;
            etiquetaNA := PDataRec(AnItem1.data).etiqueta;
            MB.Panels[1].Text := etiquetaNA;
            ident := 0;
            ident := PDataRec(AnItem1.Data).id;
            ident := PDataRec(AnItem1.Data).id;
            ReActiveFather(ident);
            IdSelectedNode := PDataRec(AnItem1.Data).id;
          except
            on E: Exception do
              showmessage(e.Message);
          end;
          if UDM.tb_tree.Locate('id', ident, []) then
          begin
            s := s;
          end;
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
//  UDM.CreaTreeDB(UDM.Conn, @tvTreeData, True);
  UDM.CargarArbol(tvTreeData, UDM.tb_arbol, true);
end;

procedure TfrmPropiedadesNodo.ValidateParentNode(Node: TTreeNode);
begin
  if Node.Parent = nil then
    raise Exception.Create('No se puede agregar un nodo sin un padre asignado.');
end;

end.

