unit UEntrada;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxEdit,
  dxSkinsCore, dxSkinsDefaultPainters, cxInplaceContainer, cxVGrid, cxDBVGrid,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Data.db, cxClasses, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, FireDAC.Stan.Async, FireDAC.DApt,
  Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup, AdvMenus, cxMemo;

type
  TFEntrada = class(TForm)
    PanelHeader: TPanel;
    Panelfooter: TPanel;
    SpeedButton1: TSpeedButton;
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    Button1: TButton;
    SpeedButton2: TSpeedButton;
    QListaCodigo: TFDQuery;
    DQListaCodigo: TDataSource;
    AdvPopupMenu1: TAdvPopupMenu;
    G1: TMenuItem;
    V1: TMenuItem;
    cxStyleRepository2: TcxStyleRepository;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    Panel1: TPanel;
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
    Panel2: TPanel;
    DBGrid1: TDBGrid;
    Panel3: TPanel;
    SpeedButton3: TSpeedButton;
    PanelCaption: TPanel;
    Panel4: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButtonayuda(Sender: TObject);
    procedure Panel3Resize(Sender: TObject);
    procedure cxDBVerticalGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure G1Click(Sender: TObject);
    procedure PanelfooterResize(Sender: TObject);
    procedure V1Click(Sender: TObject);
    procedure Panel2Resize(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    { Private declarations }
    varUltimoQuery: string;

    iRow: integer; //Posicion en la fila de la VerticalGrid
  public
    { Public declarations }
    function VarVirtual: boolean;
  end;

var
  FEntrada: TFEntrada;
  S: string;
  salvo: boolean;
  CantIndex: integer;

implementation

{$R *.dfm}

uses
  UCapaDatos, UFVariablesAyuda;

procedure TFEntrada.V1Click(Sender: TObject);
begin
  AyudaVariable(dm.cl_Variables.fieldbyname('NomVariable').asstring)
end;

function TFEntrada.VarVirtual: boolean;
var
  vtipo: TFieldType;
  LEN: INTEGER;
  vs: string;
begin
  with TFEntrada.Create(nil) do
  try
    height := (panelfooter.Height + panelHeADER.Height + 80) + 15 * DM.tb_SerieDatosVar.RECORDCOUNT;
    CantIndex := 0;
    if dm.cl_subseries.Locate('codsubs', dm.tb_SeriesDatos.FieldByName('codsubs').AsInteger) then
      s := s;
    caption := dm.cl_subseries.fieldbyname('etiqueta').AsString;
    if DM.tb_SerieDatosVar.recordcount = 0 then
      dm.tb_VirtualVar.Append;
    if dm.cl_subseries.Locate('codsubs', dm.tb_SeriesDatos.FieldByName('codsubs').AsInteger) then
      s := s;
    caption := dm.cl_subseries.fieldbyname('etiqueta').AsString;
    ShowModal;
  finally
    dm.tb_VirtualVar.active := false;
    dm.tb_VirtualVar.FieldDefs.Clear;
    Free;
  end;
end;

procedure TFEntrada.Button1Click(Sender: TObject);
var
  i: integer;
  si: boolean;
  SCampo: string;
begin
  salvo := true;
  if (dm.tb_VirtualVar.State <> dsedit) and (dm.tb_VirtualVar.State <> dsinsert) then
    dm.tb_VirtualVar.edit;
  for i := CantIndex to dm.tb_VirtualVar.fieldcount - 1 do
  begin
    s := dm.tb_VirtualVar.Fields[i].FieldName;
    if (dm.tb_VirtualVar.Fields[i].value = Null) then
      salvo := false;
  end;
  if not salvo then
  begin
    if MessageDlg('Existen variables que no han tomado valor. ?Salvará de todas formas', mtConfirmation, [mbYes, mbNo], 0, mbYes) = mryes then
      salvo := true;
  end;
  if salvo then
  begin
    DM.tb_SerieDatosVar.First;
    for i := 0 to dm.tb_Virtualvar.fieldcount - 1 do
    begin
      dm.tb_SerieDatosVar.Edit;
      if dm.cl_variables.locate('NomVariable', dm.tb_Virtualvar.fields[i].FieldName, []) then
        s := uppercase(dm.cl_variables.fieldbyname('tipo').asstring);
      if s = 'ENTERO' then
        SCampo := 'VarInteger'
      else if s = 'REAL' then
        SCampo := 'VarDouble'
      else if s = 'FECHA' then
        SCampo := 'VarDate'
      else
        SCampo := 'VarString255';
      DM.tb_SerieDatosVar.fieldbyname(SCampo).Value := DM.tb_VirtualVar.fields[i].Value;
      dm.tb_SerieDatosVar.Post;
      DM.tb_SerieDatosVar.next;
    end;
    close;
  end;
end;

procedure TFEntrada.cxDBVerticalGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
begin
  if Button <> mbRight then
    exit;
  Irow := -1;
  i := Y div cxDBVerticalGrid1.OptionsView.RowHeight;
  if i <= DM.tb_SerieDatosVar.recordcount - 1 then
  begin
    iRow := i;
    DM.tb_SerieDatosVar.First;
    DM.tb_SerieDatosVar.MoveBy(i);
    s := DM.tb_SerieDatosVar.fieldbyname('IdVar').asstring;
    if dm.cl_variables.locate('idvar', DM.tb_SerieDatosVar.fieldbyname('IdVar').asinteger, []) then
    begin
      s := dm.cl_variables.fields[1].value;
      if dm.cl_variables.fieldbyname('ListaDesplegable').value then
      begin
        g1.Enabled := true;
        AdvPopupMenu1.PopupAtCursor;
      end
      else
      begin
        g1.Enabled := false;
        ;
        AdvPopupMenu1.PopupAtCursor;
      end;
    end;
  end
  else
    s := s;
end;

procedure TFEntrada.FormCreate(Sender: TObject);
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
  AbrirTabla(dm.tb_SeriesDatos);
  AbrirTabla(dm.cl_Variables);
  AbrirTabla(dm.tb_SerieDatosVar);
  AbrirTabla(dm.cl_subseries);
  Qcl_Varsubserie := TFDQuery.create(self);
  with Qcl_Varsubserie do begin
    Active:=False;
    Connection:=DM.Conn;
    SQL.Clear;
    SQL.Add('select * from cl_varsubserie where codsubs='+QuotedStr(DM.tb_SeriesDatos.fieldbyname('codsubs').asstring));
    SQL.Add(' order by codsubs, orden');
    try
      Active:=True;
    except on E: EFDException do
      begin
        MessageDlg('No se pudo acceder al listado de variables asignadas a esta serie. Por favor intentelo de nuevo.',  mtError, [mbOK], 0);
        Exit;
      end;
    end;

  end;
  if DM.tb_SerieDatosVar.recordcount = 0 then
  try
    Qcl_Varsubserie.First;
    while not Qcl_Varsubserie.eof do
    begin
      dm.tb_SerieDatosVar.AppendRecord([DM.tb_SeriesDatos.fieldbyname('id').value, DM.tb_SeriesDatos.fieldbyname('codsubs').value, DM.tb_SeriesDatos.fieldbyname('Fecha').value, DM.tb_SeriesDatos.fieldbyname('Version').value, Qcl_Varsubserie.fieldbyname('orden').value, Qcl_Varsubserie.fieldbyname('idvar').value]);
      Qcl_Varsubserie.next;
    end;
    dm.tb_SerieDatosVar.Active := false;
    dm.tb_SerieDatosVar.Active := true;
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
  dm.tb_SerieDatosVar.first;
  i := 1;
  cxDBVerticalGrid1.DataController.DataSource := dm.dtb_VirtualVar;
  while not dm.tb_SerieDatosVar.Eof do
  begin
    s := 'iv' + inttostr(i);
    if dm.cl_Variables.Locate('idvar', dm.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
    begin
      TcxDBEditorRow(FindComponent(s)).Properties.DataBinding.FieldName := dm.cl_Variables.fieldbyname('NomVariable').asstring;
      TcxDBEditorRow(FindComponent(s)).Properties.Caption := dm.cl_Variables.fieldbyname('Etiqueta').AsString;
      TcxDBEditorRow(FindComponent(s)).Index := i + 11;
      TcxDBEditorRow(FindComponent(s)).Visible := true;
    end;
    i := i + 1;
    dm.tb_SerieDatosVar.Next;
  end;
 //------------------------------------------------------------------------------
  DM.tb_SerieDatosVar.First;
  while not dm.tb_SerieDatosVar.eof do
  begin
    if dm.cl_Variables.Locate('idvar', dm.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
    begin
      s := uppercase(dm.cl_Variables.fieldbyname('tipo').AsString);
      LEN := dm.cl_Variables.fieldbyname('LONGITUD').AsInteger;
      if s = 'ENTERO' then
        vtipo := ftsmallint
      else if s = 'REAL' then
        vtipo := ftfloat
      else if s = 'FECHA' then
        vtipo := ftdate
      else
      begin
        vtipo := ftSTRING;
        if (dm.cl_Variables.fieldbyname('longitud').VALUE = NULL) or (dm.cl_Variables.fieldbyname('longitud').value = 0) then
          LEN := 255;
      end;
      dm.tb_VirtualVar.FieldDefs.Add(dm.cl_Variables.fieldbyname('NomVariable').asstring, vtipo, LEN);
    end;
    dm.tb_SerieDatosVar.next;
  end;
  dm.tb_VirtualVar.CreateDataSet;
  if not dm.tb_VirtualVar.active then
    dm.tb_VirtualVar.Active := true;



 //**************** Adicionar los valores ***************************************
  DM.tb_SerieDatosVar.First;
  while not dm.tb_SerieDatosVar.eof do
  begin
    dm.tb_VirtualVar.edit;
    if dm.cl_Variables.Locate('idvar', dm.tb_SerieDatosVar.FieldByName('idvar').Value, []) then
    begin
      s := uppercase(dm.cl_Variables.fieldbyname('tipo').asstring);
      if s = 'ENTERO' then
        vs := 'VarInteger'
      else if s = 'REAL' then
        vs := 'VarDouble'
      else if s = 'FECHA' then
        vs := 'VarDate'
      else
        vs := 'VarString255';
      dm.tb_VirtualVar.FieldByName(dm.cl_Variables.fieldbyname('NomVariable').asstring).value := dm.tb_SerieDatosVar.fieldbyname(vs).value;
      dm.tb_VirtualVar.post;
    end;
    dm.tb_SerieDatosVar.next;
  end;
//****************************************************************************
end;

procedure TFEntrada.G1Click(Sender: TObject);
var
  Campo: string;
begin
  PanelCaption.Caption := ' Variable: ' + dm.cl_Variables.fieldbyname('NomVariable').asstring;
//********************************************************************************************
  QListaCodigo.Active := false;
  QListaCodigo.SQL.Clear;
  if dm.cl_Variables.fieldbyname('tipo').asstring = 'Entero' then
    Campo := 'VarInteger'
  else if dm.cl_Variables.fieldbyname('tipo').asstring = 'Real' then
    Campo := 'VarDouble'
  else if dm.cl_Variables.fieldbyname('tipo').asstring = 'Fecha' then
    Campo := 'VarDate'
  else
    Campo := 'VarString255';
  DBGrid1.Columns[0].FieldName := Campo;
  QListaCodigo.SQL.Add('select ' + Campo + ' from tb_SerieDatosVar where ' + Campo + ' <> NULL  group by ' + Campo + ' order by ' + Campo);
  QListaCodigo.SQL.SaveToFile('c:\!a.txt');
  QListaCodigo.Active := true;
  panel4.Visible := false;
  if QListaCodigo.RecordCount = 0 then
    panel4.Visible := true;
//********************************************************************************************
  Panel2.Visible := true;
  Splitter1.Visible := true;
end;

procedure TFEntrada.Panel2Resize(Sender: TObject);
begin
  panel4.Width := dbgrid1.Width;
  panel4.Top := dbgrid1.height div 2 + panel4.height div 2;
end;

procedure TFEntrada.Panel3Resize(Sender: TObject);
begin
  with panel3 do
  begin
    SpeedButton3.left := panel3.width div 2 - SpeedButton3.width div 2;
    SpeedButton3.top := panel3.height div 2 - SpeedButton3.height div 2;
  end;
end;

procedure TFEntrada.PanelfooterResize(Sender: TObject);
begin
  button1.left := Panelfooter.Width div 2 - button1.width div 2;
end;

procedure TFEntrada.SpeedButton1Click(Sender: TObject);
begin
  salvo := false;
  close;
end;

procedure TFEntrada.SpeedButton3Click(Sender: TObject);
begin
  dm.tb_VirtualVar.Edit;
  S := cxDBVerticalGrid1.DataController.DataSet.Fields[IROW].FieldName;
  DM.tb_VirtualVar.fieldbyname(s).value := dbgrid1.DataSource.DataSet.Fields[0].Value;
  dm.tb_VirtualVar.Post;
end;

procedure TFEntrada.SpeedButtonayuda(Sender: TObject);
begin
  showmessage('Funcionalidad en construcción');
end;

end.

