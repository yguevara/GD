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
  Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup, AdvMenus, cxMemo,
  Vcl.ComCtrls, Vcl.ToolWin;

type
  TFEntrada = class(TForm)
    cxStyleRepository1: TcxStyleRepository;
    cxStyle1: TcxStyle;
    QListaCodigo: TFDQuery;
    DQListaCodigo: TDataSource;
    AdvPopupMenu1: TAdvPopupMenu;
    G1: TMenuItem;
    V1: TMenuItem;
    cxStyleRepository2: TcxStyleRepository;
    cxStyle2: TcxStyle;
    cxStyle3: TcxStyle;
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    StatusBar1: TStatusBar;
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
    btnAddVar: TSpeedButton;
    PanelCaption: TPanel;
    Panel4: TPanel;
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButtonayuda(Sender: TObject);
    procedure Panel3Resize(Sender: TObject);
    procedure cxDBVerticalGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure G1Click(Sender: TObject);
    procedure V1Click(Sender: TObject);
    procedure Panel2Resize(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure ToolButton8Click(Sender: TObject);
    procedure btnAddVarClick(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    varUltimoQuery: string;

    iRow: integer; //Posicion en la fila de la VerticalGrid

  public
    { Public declarations }
    procedure Rellena;
  end;

var
  //FEntrada: TFEntrada;
  S: string;
  salvo: boolean;
  CantIndex: integer;

function VarVirtual: boolean;

implementation

{$R *.dfm}

uses
  UCapaDatos, UFVariablesAyuda;

procedure TFEntrada.V1Click(Sender: TObject);
begin
  AyudaVariable(UDM.cl_Variables.fieldbyname('NomVariable').asstring)
end;

function VarVirtual: boolean;
var
  vtipo: TFieldType;
  LEN: INTEGER;
  vs: string;
begin
  with TFEntrada.Create(nil) do
  try
    CantIndex := 0;
    if UDM.cl_subseries.Locate('codsubs', UDM.tb_SeriesDatos.FieldByName('codsubs').AsInteger) then
      s := s;
    caption := UDM.cl_subseries.fieldbyname('etiqueta').AsString;
    if UDM.tb_SerieDatosVar.recordcount = 0 then
      UDM.tb_VirtualVar.Append;
    if UDM.cl_subseries.Locate('codsubs', UDM.tb_SeriesDatos.FieldByName('codsubs').AsInteger) then
      s := s;
    caption := UDM.cl_subseries.fieldbyname('etiqueta').AsString;
    ShowModal;
  finally
    UDM.tb_VirtualVar.active := false;
    UDM.tb_VirtualVar.FieldDefs.Clear;
    Free;
  end;
end;

procedure TFEntrada.btnAddVarClick(Sender: TObject);
begin
  Splitter1.Visible := False;
  Panel2.Visible := False;
end;

procedure TFEntrada.btnCloseClick(Sender: TObject);
begin
  salvo := False;
  Close;
end;

procedure TFEntrada.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TFEntrada.Button1Click(Sender: TObject);
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
    if UDM.sms('Existen variables que no han tomado valor. ?Salvará de todas formas', 4) = 6 then
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
    close;
  end;
end;

procedure TFEntrada.cxDBVerticalGrid1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i: integer;
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
      if UDM.cl_variables.fieldbyname('ListaDesplegable').value then
        g1.Enabled := true;
      AdvPopupMenu1.PopupAtCursor;
    end;
  end
  else
    s := s;
end;

procedure TFEntrada.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TFEntrada.FormCreate(Sender: TObject);
begin
  Rellena;
end;

procedure TFEntrada.G1Click(Sender: TObject);
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

procedure TFEntrada.Rellena;
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
  with Qcl_Varsubserie do begin
    Active:=False;
    Connection:=UDM.Conn;
    SQL.Clear;
    SQL.Add('select * from cl_varsubserie where codsubs='+QuotedStr(UDM.tb_SeriesDatos.fieldbyname('codsubs').asstring));
    SQL.Add(' order by codsubs, orden');
    try
      Active:=True;
    except on E: EFDException do
      begin
        UDM.sms('No se pudo acceder al listado de variables asignadas a esta serie. Por favor intentelo de nuevo.',  1);
        Exit;
      end;
    end;

  end;
  if UDM.tb_SerieDatosVar.recordcount = 0 then
  try
    Qcl_Varsubserie.First;
    while not Qcl_Varsubserie.eof do
    begin
      UDM.tb_SerieDatosVar.AppendRecord([
                                          UDM.tb_SeriesDatos.fieldbyname('id').value,
                                          UDM.tb_SeriesDatos.fieldbyname('codsubs').value,
                                          UDM.tb_SeriesDatos.fieldbyname('Fecha').value,
                                          UDM.tb_SeriesDatos.fieldbyname('Version').value,
                                          Qcl_Varsubserie.fieldbyname('orden').value,
                                          Qcl_Varsubserie.fieldbyname('idvar').value
                                        ]);
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
        vtipo := ftsmallint
      else if s = 'REAL' then
        vtipo := ftfloat
      else if s = 'FECHA' then
        vtipo := ftdate
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

procedure TFEntrada.SpeedButton1Click(Sender: TObject);
begin
  salvo := false;
  close;
end;

procedure TFEntrada.SpeedButton3Click(Sender: TObject);
begin
  UDM.tb_VirtualVar.Edit;
  S := cxDBVerticalGrid1.DataController.DataSet.Fields[IROW].FieldName;
  UDM.tb_VirtualVar.fieldbyname(s).value := dbgrid1.DataSource.DataSet.Fields[0].Value;
  UDM.tb_VirtualVar.Post;
end;

procedure TFEntrada.SpeedButtonayuda(Sender: TObject);
begin
  showmessage('Funcionalidad en construcción');
end;

procedure TFEntrada.ToolButton8Click(Sender: TObject);
begin
  Button1Click(Sender);
end;

end.

