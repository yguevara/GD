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
  cxDropDownEdit;

type
  TfrmVarVirtualVar = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    Panel6: TPanel;
    btnProp: TSpeedButton;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    StatusBar1: TStatusBar;
    cxGrid1DBTableView1codserie: TcxGridDBColumn;
    cxGrid1DBTableView1codsubs: TcxGridDBColumn;
    cxGrid1DBTableView1IdVar: TcxGridDBColumn;
    btnAddVar: TSpeedButton;
    jcpVarList: TJvCaptionPanel;
    Panel1: TPanel;
    btnAsignVarVir: TSpeedButton;
    cxDBNavigator1: TcxDBNavigator;
    DBNavigator1: TDBNavigator;
    StatusBar2: TStatusBar;
    cxGrid2: TcxGrid;
    cxGridDBTableView1: TcxGridDBTableView;
    cxGridLevel1: TcxGridLevel;
    cxGridDBTableView1IdVar: TcxGridDBColumn;
    cxGridDBTableView1NomVariable: TcxGridDBColumn;
    cxGridDBTableView1Etiqueta: TcxGridDBColumn;
    cxGridDBTableView1tipo: TcxGridDBColumn;
    cxGridDBTableView1longitud: TcxGridDBColumn;
    cxGridDBTableView1descripcion: TcxGridDBColumn;
    cxGridDBTableView1ListaDesplegable: TcxGridDBColumn;
    SpeedButton1: TSpeedButton;
    procedure btnCloseClick(Sender: TObject);
    procedure jcpVarListButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
    procedure btnAsignVarVirClick(Sender: TObject);
    procedure btnAddVarClick(Sender: TObject);
    procedure btnPropClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnhlpClick(Sender: TObject);
  private
    procedure ActCmp(Action: boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVarVirtualVar: TfrmVarVirtualVar;

implementation

uses
  UCapaDatos, UCLVariables;

{$R *.dfm}

procedure TfrmVarVirtualVar.btnAddVarClick(Sender: TObject);
begin
  ActCmp(False);
  jcpVarList.Visible := True;
  varMod:='A';
end;

procedure TfrmVarVirtualVar.btnAsignVarVirClick(Sender: TObject);
begin
  if varMod='A' then
    UDM.cl_VarSubserie.Append
  else
    UDM.cl_VarSubserie.Edit;
  UDM.cl_VarSubserie.FieldByName('IdVar').AsInteger := UDM.cl_variables.FieldByName('IdVar').AsInteger;
end;

procedure TfrmVarVirtualVar.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVarVirtualVar.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmVarVirtualVar.btnPropClick(Sender: TObject);
begin
  if jcpVarList.Visible then
    Exit;
  ActCmp(False);
  Panel1.Visible:=False;
  with UDM.cl_variables do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select * from cl_variables where idvar=' + UDM.cl_VarSubserie.FieldByName('idVar').AsString);
    try
      Active := True;
      jcpVarList.Visible := True;
      varMod:='E';
    except
    end;
  end;

end;

procedure TfrmVarVirtualVar.ActCmp(Action: boolean);
begin
  btnAddVar.Enabled := Action;
  btnProp.Enabled := Action;
end;

procedure TfrmVarVirtualVar.jcpVarListButtonClick(Sender: TObject; Button: TJvCapBtnStyle);
begin
  if Button = capClose then
  begin
    TJvCaptionPanel(Sender).Visible := False;
    with UDM.cl_variables do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select * from cl_variables');
      try
        Active := True;
        ActCmp(True);
        Panel1.Visible:=True;
      except
      end;
    end;
  end;
  if Button=capHelp then begin
    UDM.ManagementHLP(jcpVarList.Caption, jcpVarList.Handle);
  end;
end;

procedure TfrmVarVirtualVar.SpeedButton1Click(Sender: TObject);
begin
  jcpVarList.Visible:=False;
end;

end.

