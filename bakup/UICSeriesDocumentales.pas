unit UICSeriesDocumentales;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, Vcl.ToolWin, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, Data.DB, cxDBData, cxCalendar, cxDBLookupComboBox, cxBlobEdit,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error,
  FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.StdCtrls,
  cxGridLevel, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxClasses, cxGridCustomView, cxGrid, Vcl.DBCtrls, cxDBNavigator, Vcl.ExtCtrls,
  AdvSplitter, Vcl.Menus, AdvMenus, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, cxVGrid,
  cxDBVGrid, cxInplaceContainer, cxMemo, Winapi.ShellAPI;

type
  TfrmICSeriesDocumentales = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    Panel2: TPanel;
    cxDBNavigator1: TcxDBNavigator;
    dbnSeriesDatos: TDBNavigator;
    cmd: TFDQuery;
    dstb_SeriesDatos: TDataSource;
    ToolButton1: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    Panel4: TPanel;
    Splitter1: TSplitter;
    cxDBVerticalGrid1: TcxDBVerticalGrid;
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
    Panel5: TPanel;
    DBGrid1: TDBGrid;
    Panel6: TPanel;
    SpeedButton3: TSpeedButton;
    PanelCaption: TPanel;
    Panel7: TPanel;
    QListaCodigo: TFDQuery;
    DQListaCodigo: TDataSource;
    AdvPopupMenu1: TAdvPopupMenu;
    G1: TMenuItem;
    V1: TMenuItem;
    Panel3: TPanel;
    cxGrid2: TcxGrid;
    cxGrid2DBTableView1: TcxGridDBTableView;
    cxGrid2Level1: TcxGridLevel;
    AdvSplitter1: TAdvSplitter;
    ToolBar2: TToolBar;
    ToolButton6: TToolButton;
    ToolButton8: TToolButton;
    ToolButton7: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    V2: TMenuItem;
    N2: TMenuItem;
    mGestionarContentFile: TMenuItem;
    E2: TMenuItem;
    ToolButton2: TToolButton;
    ToolButton5: TToolButton;
    cxGrid2DBTableView1IdEstructura: TcxGridDBColumn;
    cxGrid2DBTableView1codsubs: TcxGridDBColumn;
    cxGrid2DBTableView1Fecha: TcxGridDBColumn;
    cxGrid2DBTableView1Version: TcxGridDBColumn;
    cxGrid2DBTableView1Codigodoc: TcxGridDBColumn;
    cxGrid2DBTableView1Idservidor: TcxGridDBColumn;
    cxGrid2DBTableView1deposito: TcxGridDBColumn;
    cxGrid2DBTableView1gaveta: TcxGridDBColumn;
    cxGrid2DBTableView1fichero: TcxGridDBColumn;
    cxGrid2DBTableView1soporte: TcxGridDBColumn;
    cxGrid2DBTableView1observaciones: TcxGridDBColumn;
    cxGrid2DBTableView1uploadserver: TcxGridDBColumn;
    PMManagementFile: TAdvPopupMenu;
    Panel1: TPanel;
    lblinf: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure dstb_SeriesDatosDataChange(Sender: TObject; Field: TField);
    procedure ToolButton9Click(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
    procedure G1Click(Sender: TObject);
    procedure cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure V2Click(Sender: TObject);
    procedure mGestionarContentFileClick(Sender: TObject);
    procedure E2Click(Sender: TObject);
    procedure cxDBVerticalGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnAddVarClick(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure dbnSeriesDatosClick(Sender: TObject; Button: TNavigateBtn);
    procedure cxGrid2DBTableView1observacionesPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ToolButton5Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    varUltimoQuery: string;
    iRow: integer; //Posicion en la fila de la VerticalGrid
    procedure Rellena;
  end;

var
  frmICSeriesDocumentales: TfrmICSeriesDocumentales;
  S: string;
  salvo: boolean;
  CantIndex: integer;

implementation

uses
  UCapaDatos, UFVariablesAyuda, UManagementFileSeries, UVeditor, UExcelExport;

{$R *.dfm}

procedure TfrmICSeriesDocumentales.btnAddVarClick(Sender: TObject);
begin
  Splitter1.Visible := False;
  Panel5.Visible := False;
end;

procedure TfrmICSeriesDocumentales.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmICSeriesDocumentales.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmICSeriesDocumentales.cxDBVerticalGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
  Campo: string;
begin
  Irow := -1;
  i := Y div cxDBVerticalGrid1.OptionsView.RowHeight;
  if i <= UDM.tb_SerieDatosVar.recordcount - 1 then
  begin
    iRow := i;
    UDM.tb_SerieDatosVar.First;
    UDM.tb_SerieDatosVar.MoveBy(i);
    s := UDM.tb_SerieDatosVar.fieldbyname('IdVar').asstring;
    if UDM.cl_variables.locate('idvar', UDM.tb_SerieDatosVar.fieldbyname('IdVar').asinteger, []) then
    begin
      s := UDM.cl_variables.fields[1].value;
      g1.Enabled := False;
      Panel5.Visible := False;
      if UDM.cl_variables.fieldbyname('ListaDesplegable').value then
      begin
        PanelCaption.Caption := ' Variable: ' + UDM.cl_Variables.fieldbyname('NomVariable').asstring;
//********************************************************************************************
        QListaCodigo.Active := false;
        QListaCodigo.SQL.Clear;
        if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Entero' then
          Campo := 'VarInteger'
        else if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Real' then
          Campo := 'VarDouble'
        else if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Fecha' then
          Campo := 'VarDate'
        else
          Campo := 'VarString255';
        DBGrid1.Columns[0].FieldName := Campo;
        QListaCodigo.SQL.Add('select ' + Campo + ' from tb_SerieDatosVar where IdVar=' + UDM.tb_SerieDatosVar.fieldbyname('IdVar').asstring + ' and ' + Campo + ' <> NULL  group by ' + Campo + ' order by ' + Campo);
        QListaCodigo.Active := true;
        panel7.Visible := false;
        if QListaCodigo.RecordCount = 0 then
          panel7.Visible := true;
        Panel2.Visible := true;
        Splitter1.Visible := true;
        Panel5.Visible := True;
      end;
    end;
  end;
end;

procedure TfrmICSeriesDocumentales.cxGrid2DBTableView1ficheroPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
  PMManagementFile.PopupAtCursor;
end;

procedure TfrmICSeriesDocumentales.cxGrid2DBTableView1observacionesPropertiesButtonClick(Sender: TObject; AButtonIndex: Integer);
var
  NombreSerieDocAsig: string;
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.tb_SeriesDatos.FieldByName('observaciones').Value = null) or (trim(UDM.tb_SeriesDatos.FieldByName('observaciones').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  NombreSerieDocAsig := VarToStr(UDM.Conn.ExecSQLScalar('select subserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_Serietree.FieldByName('codsubs').AsString)));
  CampoTexto(@UDM.dstb_SeriesDatos, 'observaciones', 'Observaciones de la serie documental ' + NombreSerieDocAsig);
end;

procedure TfrmICSeriesDocumentales.dbnSeriesDatosClick(Sender: TObject; Button: TNavigateBtn);
var
  CodSerie, CodSubSerie: string;
  cmdVar: TFDQuery;
begin
  if Button = nbPost then
  begin
    CodSerie := VarToStr(UDM.Conn.ExecSQLScalar('select codserie from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString)));
    if UDM.cl_series.Locate('codserie', CodSerie, []) then
      if UDM.cl_subseries.Locate('codserie;codsubs', vararrayOf([CodSerie, UDM.tb_SeriesDatos.FieldByName('codsubs').AsString]), []) then
      begin
        UDM.cl_VarSubserie.First;
        while not UDM.cl_VarSubserie.Eof do
        begin
          if not UDM.tb_SerieDatosVar.Locate('Id;codsubs;Fecha;Version;Orden;IdVar', VarArrayOf([UDM.tb_SeriesDatos.FieldByName('Id').AsString, UDM.tb_SeriesDatos.FieldByName('codsubs').AsString, UDM.tb_SeriesDatos.FieldByName('Fecha').AsString, UDM.tb_SeriesDatos.FieldByName('version').AsString, UDM.cl_VarSubserie.FieldByName('Orden').AsString, UDM.cl_VarSubserie.FieldByName('idvar').AsString]), []) then
          begin
            UDM.tb_SerieDatosVar.Append;
            UDM.tb_SerieDatosVar.FieldByName('Id').AsString := UDM.tb_SeriesDatos.FieldByName('Id').AsString;
            UDM.tb_SerieDatosVar.FieldByName('codsubs').AsString := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
            UDM.tb_SerieDatosVar.FieldByName('Fecha').Value := UDM.tb_SeriesDatos.FieldByName('Fecha').Value;
            UDM.tb_SerieDatosVar.FieldByName('version').AsInteger := UDM.tb_SeriesDatos.FieldByName('version').AsInteger;
            UDM.tb_SerieDatosVar.FieldByName('Orden').AsInteger := UDM.cl_VarSubserie.FieldByName('Orden').AsInteger;
            UDM.tb_SerieDatosVar.FieldByName('idvar').AsInteger := UDM.cl_VarSubserie.FieldByName('idvar').AsInteger;
            try
              UDM.tb_SerieDatosVar.Post;
            except
              UDM.tb_SerieDatosVar.Cancel;
            end;
          end;

          UDM.cl_VarSubserie.Next;
        end;
      end;
  end;
end;

procedure TfrmICSeriesDocumentales.dstb_SeriesDatosDataChange(Sender: TObject; Field: TField);
begin
  lblinf.Caption := ' Gestionando información referente a la serie documental: ';
  lblinf.Caption := lblinf.Caption + VarToStr(UDM.Conn.ExecSQLScalar('select etiqueta from cl_subseries where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString)));
  CantIndex := 0;
  Panel4.Visible := True;
  Splitter1.Visible := True;
  if UDM.tb_SerieDatosVar.RecordCount > 0 then
  begin
    UDM.tb_VirtualVar.Active := False;
    UDM.tb_VirtualVar.FieldDefs.Clear;
    Rellena;
  end
  else
  begin
    Panel4.Visible := False;
    Splitter1.Visible := False;
    Panel3.Align := alClient;
    cxGrid2.Update;
    Panel3.Update;
  end;

end;

procedure TfrmICSeriesDocumentales.E2Click(Sender: TObject);
begin
  if UDM.sms('¿Realmente desea eliminar el contenido del campo actual?', 4)=6 then
  begin
    UDM.tb_SeriesDatos.Edit;
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).Clear;
    UDM.tb_SeriesDatos.Post;
  end;

end;

procedure TfrmICSeriesDocumentales.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmICSeriesDocumentales.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.tb_VirtualVar.Active := False;
  UDM.tb_VirtualVar.FieldDefs.Clear;
end;

procedure TfrmICSeriesDocumentales.G1Click(Sender: TObject);
var
  Campo: string;
begin
  PanelCaption.Caption := ' Variable: ' + UDM.cl_Variables.fieldbyname('NomVariable').asstring;
//********************************************************************************************
  QListaCodigo.Active := false;
  QListaCodigo.SQL.Clear;
  if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Entero' then
    Campo := 'VarInteger'
  else if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Real' then
    Campo := 'VarDouble'
  else if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Fecha' then
    Campo := 'VarDate'
  else
    Campo := 'VarString255';
  DBGrid1.Columns[0].FieldName := Campo;
  QListaCodigo.SQL.Add('select ' + Campo + ' from tb_SerieDatosVar where ' + Campo + ' <> NULL  group by ' + Campo + ' order by ' + Campo);
  QListaCodigo.Active := true;
  panel4.Visible := false;
  if QListaCodigo.RecordCount = 0 then
    panel4.Visible := true;
//********************************************************************************************
  Panel2.Visible := true;
  Splitter1.Visible := true;
end;

procedure TfrmICSeriesDocumentales.mGestionarContentFileClick(Sender: TObject);
begin
  ManagementFileSeries(@UDM.tb_SeriesDatos, 'fichero', 'Gestión de serie documental');
end;

procedure TfrmICSeriesDocumentales.Rellena;
var
  i: integer;
  Qcl_Varsubserie: TFDQuery;
  vs: string;
  vtipo: TFieldType;
  LEN: INTEGER;

  procedure abrirTabla(DS: TDataset);
  begin
    if not DS.active then
      DS.active := true;
  end;

begin
  salvo := false;
 //********************Abrit las tablas*****************************************
  AbrirTabla(UDM.tb_SeriesDatos);
  AbrirTabla(UDM.cl_Variables);
  AbrirTabla(UDM.tb_SerieDatosVar);
  AbrirTabla(UDM.cl_subseries);
  Qcl_Varsubserie := TFDQuery.create(self);
  with Qcl_Varsubserie do
  begin
    Active := False;
    Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('select * from cl_varsubserie where codsubs=' + QuotedStr(UDM.tb_SeriesDatos.fieldbyname('codsubs').asstring));
    SQL.Add(' order by codsubs, orden');
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
  if UDM.tb_SerieDatosVar.recordcount = 0 then
  try
    Qcl_Varsubserie.First;
    while not Qcl_Varsubserie.eof do
    begin
      UDM.tb_SerieDatosVar.AppendRecord([UDM.tb_SeriesDatos.fieldbyname('id').value, UDM.tb_SeriesDatos.fieldbyname('codsubs').value, UDM.tb_SeriesDatos.fieldbyname('Fecha').value, UDM.tb_SeriesDatos.fieldbyname('Version').value, Qcl_Varsubserie.fieldbyname('orden').value, Qcl_Varsubserie.fieldbyname('idvar').value]);
      Qcl_Varsubserie.next;
    end;
    UDM.tb_SerieDatosVar.Active := false;
    UDM.tb_SerieDatosVar.Active := true;
  finally
    Qcl_Varsubserie.Free;
  end;
  varUltimoQuery := '';
  for i := 1 to 10 do
  begin
    s := 'iv' + inttostr(1);
    TcxDBEditorRow(FindComponent(s)).Visible := false;
    TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := '';
  end;
  UDM.tb_SerieDatosVar.first;
  i := 1;
  cxDBVerticalGrid1.DataController.DataSource := UDM.dtb_VirtualVar;
  while not UDM.tb_SerieDatosVar.Eof do
  begin
    s := 'iv' + inttostr(i);
    if UDM.cl_Variables.Locate('idvar', UDM.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
    begin
      TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := UDM.cl_Variables.fieldbyname('NomVariable').asstring;
      TcxDBEditorRow(FindComponent(s)).Properties.Caption := UDM.cl_Variables.fieldbyname('Etiqueta').AsString;
      TcxDBEditorRow(FindComponent(s)).Index := i + 11;
      TcxDBEditorRow(FindComponent(s)).Visible := true;
    end;
    i := i + 1;
    UDM.tb_SerieDatosVar.Next;
  end;
 //------------------------------------------------------------------------------
  UDM.tb_SerieDatosVar.First;
  while not UDM.tb_SerieDatosVar.eof do
  begin
    if UDM.cl_Variables.Locate('idvar', UDM.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
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
        if (UDM.cl_Variables.fieldbyname('longitud').VALUE = NULL) or (UDM.cl_Variables.fieldbyname('longitud').value = 0) then
          LEN := 255;
      end;
      UDM.tb_VirtualVar.FieldDefs.Add(UDM.cl_Variables.fieldbyname('NomVariable').asstring, vtipo, LEN);
    end;
    UDM.tb_SerieDatosVar.next;
  end;
  UDM.tb_VirtualVar.CreateDataSet;
  if not UDM.tb_VirtualVar.active then
    UDM.tb_VirtualVar.Active := true;
 //**************** Adicionar los valores ***************************************
  UDM.tb_SerieDatosVar.First;
  while not UDM.tb_SerieDatosVar.eof do
  begin
    UDM.tb_VirtualVar.edit;
    if UDM.cl_Variables.Locate('idvar', UDM.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
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
      UDM.tb_VirtualVar.FieldByName(UDM.cl_Variables.fieldbyname('NomVariable').asstring).value := UDM.tb_SerieDatosVar.fieldbyname(vs).value;
      UDM.tb_VirtualVar.post;
    end;
    UDM.tb_SerieDatosVar.next;
  end;
//****************************************************************************
end;

procedure TfrmICSeriesDocumentales.SpeedButton3Click(Sender: TObject);
begin
  UDM.tb_VirtualVar.Edit;
  UDM.tb_VirtualVar.fieldbyname(cxDBVerticalGrid1.DataController.DataSet.Fields[IROW].FieldName).value := dbgrid1.DataSource.DataSet.Fields[0].Value;
  UDM.tb_VirtualVar.Post;
end;

procedure TfrmICSeriesDocumentales.ToolButton11Click(Sender: TObject);
begin
  AyudaVariable(UDM.cl_Variables.fieldbyname('NomVariable').asstring);
end;

procedure TfrmICSeriesDocumentales.ToolButton5Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid2);
end;

procedure TfrmICSeriesDocumentales.ToolButton8Click(Sender: TObject);
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
    if (UDM.tb_VirtualVar.Fields[i].value = Null) then
      salvo := false;
  end;
  if not salvo then
  begin
    if UDM.sms('Existen variables que no han tomado valor. ¿Salvará de cualquier forma?', 4) = 6 then
      salvo := true;
  end;
  if salvo then
  begin
    UDM.tb_SerieDatosVar.First;
    for i := 0 to UDM.tb_Virtualvar.fieldcount - 1 do
    begin
      UDM.tb_SerieDatosVar.Edit;
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
      UDM.tb_SerieDatosVar.fieldbyname(SCampo).Value := UDM.tb_VirtualVar.fields[i].Value;
      UDM.tb_SerieDatosVar.Post;
      UDM.tb_SerieDatosVar.next;
    end;
   // close;
  end;
end;

procedure TfrmICSeriesDocumentales.ToolButton9Click(Sender: TObject);
var
  Campo: string;
begin
  PanelCaption.Caption := ' Variable: ' + UDM.cl_Variables.fieldbyname('NomVariable').asstring;
//********************************************************************************************
  QListaCodigo.Active := false;
  QListaCodigo.SQL.Clear;
  if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Entero' then
    Campo := 'VarInteger'
  else if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Real' then
    Campo := 'VarDouble'
  else if UDM.cl_Variables.fieldbyname('tipo').asstring = 'Fecha' then
    Campo := 'VarDate'
  else
    Campo := 'VarString255';
  DBGrid1.Columns[0].FieldName := Campo;
  QListaCodigo.SQL.Add('select ' + Campo + ' from tb_SerieDatosVar where ' + Campo + ' <> NULL  group by ' + Campo + ' order by ' + Campo);
  //QListaCodigo.SQL.SaveToFile('c:\!a.txt');
  QListaCodigo.Active := true;
  panel4.Visible := false;
  if QListaCodigo.RecordCount = 0 then
    panel4.Visible := true;
//********************************************************************************************
  Panel2.Visible := true;
  Splitter1.Visible := true;
end;

procedure TfrmICSeriesDocumentales.V2Click(Sender: TObject);
var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    ejecutaPDF(List[0]);
    //ShowMessage(List[0]);
  end;
end;

end.

