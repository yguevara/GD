unit UCL_Cargo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, Vcl.ExtCtrls, AdvSplitter, Vcl.DBCtrls, cxNavigator,
  cxDBNavigator, Vcl.ComCtrls, Vcl.ToolWin, cxContainer, cxEdit, cxMaskEdit,
  cxDropDownEdit, cxLookupEdit, cxDBLookupEdit, cxDBLookupComboBox, cxTextEdit,
  cxDBEdit, Vcl.StdCtrls, AdvGroupBox, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, dxDateRanges, Data.DB, cxDBData, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxBlobEdit, Vcl.Buttons, Vcl.Menus, AdvMenus,
  JvExControls, JvButton, JvTransparentButton;

type
  TfrmCLCargo = class(TForm)
    ToolBar1: TToolBar;
    btnClose: TToolButton;
    ToolButton3: TToolButton;
    btnhlp: TToolButton;
    StatusBar1: TStatusBar;
    Panel6: TPanel;
    btnFacultades: TJvTransparentButton;
    btnFunciones: TJvTransparentButton;
    cxDBNavigator3: TcxDBNavigator;
    DBNavigator3: TDBNavigator;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    cxGrid1DBTableView1Idcargo: TcxGridDBColumn;
    cxGrid1DBTableView1nombre: TcxGridDBColumn;
    cxGrid1DBTableView1idcategoria: TcxGridDBColumn;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure agregarfunClick(Sender: TObject);
    procedure btnFuncionesClick(Sender: TObject);
    procedure dscl_cargoDataChange(Sender: TObject; Field: TField);
    procedure eliminarfunClick(Sender: TObject);
    procedure eliminarfacClick(Sender: TObject);
    procedure modificarfunClick(Sender: TObject);
    procedure agregarfacClick(Sender: TObject);
    procedure editarfacClick(Sender: TObject);
    procedure DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
    procedure btnhlpClick(Sender: TObject);
    procedure btnFacultadesClick(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCLCargo: TfrmCLCargo;

implementation

uses
  UCapaDatos, UVeditor, UCLFacultades, UCLFunciones, UExcelExport;

{$R *.dfm}

procedure TfrmCLCargo.agregarfacClick(Sender: TObject);
begin
  with TfrmCLFacultades.Create(nil) do
  try
    UDM.cl_facultadesgen.Append;
    UDM.cl_facultadesgen.FieldByName('idfacultades').AsString := inttostr(UDM.GetLastFacult);
    DBNavigator3.VisibleButtons := [nbPost, nbCancel];
    ShowModal;
  finally
    DBNavigator3.VisibleButtons := [nbPrior, nbNext, nbInsert, nbDelete, nbEdit, nbPost, nbCancel];
    Free;
  end;
end;

procedure TfrmCLCargo.agregarfunClick(Sender: TObject);
begin
  with TfrmCLFunciones.Create(nil) do
  try
    UDM.cl_funcionesgen.Append;
    UDM.cl_funcionesgen.FieldByName('idfunciones').AsString := inttostr(UDM.GetLastFunct);
    DBNavigator3.VisibleButtons := [nbPost, nbCancel];
    ShowModal;
  finally
    DBNavigator3.VisibleButtons := [nbPrior, nbNext, nbInsert, nbDelete, nbEdit, nbPost, nbCancel];
    Free;
  end;

  {
  if udm.cl_funcionesgen.RecordCount = 0 then
  begin

  end
  else
  begin
    udm.sms('Ya ha agregado funciones generales al cargo actual.', 3);
    exit;
  end;
  }
end;

procedure TfrmCLCargo.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCLCargo.btnFacultadesClick(Sender: TObject);
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.cl_facultadesgen.FieldByName('facultades').Value = null) or (trim(UDM.cl_facultadesgen.FieldByName('facultades').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.',22222222222223);
      Exit;
    end;
  CampoTexto(@UDM.dscl_facultadesgen, 'facultades', 'Funciones generales del cargo ' + UDM.cl_cargo.FieldByName('nombre').AsString);
end;

procedure TfrmCLCargo.btnFuncionesClick(Sender: TObject);
begin
  if ansilowercase(UDM.ROL) <> 'administradores' then
    if (UDM.cl_funcionesgen.FieldByName('funciones').Value = null) or (trim(UDM.cl_funcionesgen.FieldByName('funciones').Value) = '') then
    begin
      UDM.sms('No se encontró contenido para mostrar.', 3);
      Exit;
    end;
  CampoTexto(@UDM.dscl_funcionesgen, 'funciones', 'Funciones generales del cargo ' + UDM.cl_cargo.FieldByName('nombre').AsString);
end;

procedure TfrmCLCargo.btnhlpClick(Sender: TObject);
begin
  UDM.ManagementHLP(Caption, Self.Handle);
end;

procedure TfrmCLCargo.DBNavigator3Click(Sender: TObject; Button: TNavigateBtn);
begin
  if Button = nbInsert then
  begin
    if (TDBNavigator(Sender).DataSource.DataSet.State = dsInsert) or (TDBNavigator(Sender).DataSource.DataSet.State = dsEdit) then
      UDM.cl_cargo.FieldByName('idcargo').AsInteger := UDM.GetLastId('cl_cargo', 'idcargo');
  end;
end;

procedure TfrmCLCargo.dscl_cargoDataChange(Sender: TObject; Field: TField);
var
  Tienefunciones, TieneFacultades: integer;
begin
 { if (UDM.cl_cargo.State=dsInsert)or (UDM.cl_cargo.State=dsEdit) then
    Exit;
  Tienefunciones := 0;
  TieneFacultades := 0;
  Tienefunciones := UDM.Conn.ExecSQLScalar('select count(idfunciones)as funciones_cant from cl_funcionesgen where idcargo=' + UDM.cl_cargo.FieldByName('idcargo').AsString);
  TieneFacultades := UDM.Conn.ExecSQLScalar('select count(idfacultades)as facultad from cl_facultadesgen where idcargo=' + UDM.cl_cargo.FieldByName('idcargo').AsString);
  agregarfun.Enabled := true;
  agregarfac.Enabled := True;
  if Tienefunciones > 0 then
    agregarfun.Enabled := False;
  if TieneFacultades > 0 then
    agregarfac.Enabled := False; }

end;

procedure TfrmCLCargo.editarfacClick(Sender: TObject);
begin
  with UDM.cl_facultadesgen do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select * from cl_facultadesgen where Idcargo=' + UDM.cl_cargo.FieldByName('idCargo').AsString);
    try
      Active := True;
    except

    end;
  end;
  with TfrmCLFacultades.Create(nil) do
  try
    DBNavigator3.VisibleButtons := [nbPost, nbCancel];
    ShowModal;
  finally
    DBNavigator3.VisibleButtons := [nbPrior, nbNext, nbInsert, nbDelete, nbEdit, nbPost, nbCancel];
    Free;
  end;
end;

procedure TfrmCLCargo.eliminarfacClick(Sender: TObject);
begin
  if UDM.sms('¿Está seguro que quiere eliminar las facultades del cargo actual?', 4) = 6 then
    UDM.Conn.ExecSQL('delete from cl_facultadesgen where Idcargo=' + UDM.cl_cargo.FieldByName('idCargo').AsString);
end;

procedure TfrmCLCargo.eliminarfunClick(Sender: TObject);
begin
  if UDM.sms('¿Está seguro que quiere eliminar las funciones del cargo actual?', 4) = 6 then
    UDM.Conn.ExecSQL('delete from cl_funcionesgen where Idcargo=' + UDM.cl_cargo.FieldByName('idCargo').AsString);
end;

procedure TfrmCLCargo.FormActivate(Sender: TObject);
begin
  Security.SetModSecurity(Self, acceso);
end;

procedure TfrmCLCargo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  UDM.cl_cargo.Active:=False;
  UDM.cl_cargo.Active:=True;
end;

procedure TfrmCLCargo.modificarfunClick(Sender: TObject);
var
  cad: string;
begin
  with UDM.cl_funcionesgen do
  begin
    Active := False;
    SQL.Clear;
    cad := 'select * from cl_funcionesgen where Idcargo=' + UDM.cl_cargo.FieldByName('idCargo').AsString;
    SQL.Add(cad);
    try
      Active := True;
    except

    end;
  end;
  with TfrmCLFunciones.Create(nil) do
  try
    DBNavigator3.VisibleButtons := [nbPost, nbCancel];
    ShowModal;
  finally
    DBNavigator3.VisibleButtons := [nbPrior, nbNext, nbInsert, nbDelete, nbEdit, nbPost, nbCancel];
    Free;
  end;
end;

procedure TfrmCLCargo.ToolButton2Click(Sender: TObject);
begin
  ExcelExport(nil, cxGrid1);
end;

end.

