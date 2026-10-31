unit UUserGest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ComCtrls, JvExComCtrls, JvListView, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  UCapaDatos, Vcl.ToolWin, JvExControls, JvButton, JvTransparentButton,
  frxADOComponents, frxClass, frxGradient, frxRich, Data.Win.ADODB, db,
  frxDBSet;

type
  TfrmGestUser = class(TForm)
    StatusBar1: TStatusBar;
    PageControl1: TPageControl;
    tsGeneralProperties: TTabSheet;
    PMUsuarios: TPopupMenu;
    Establecercontrasea1: TMenuItem;
    N5: TMenuItem;
    Agregar1: TMenuItem;
    N1: TMenuItem;
    EliminarUsuario1: TMenuItem;
    N4: TMenuItem;
    Propiedades1: TMenuItem;
    lbUser: TJvListView;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnautentica: TJvTransparentButton;
    btnusercontrol: TJvTransparentButton;
    btnLC: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    JvTransparentButton2: TJvTransparentButton;
    Edit1: TEdit;
    btnPrint: TJvTransparentButton;
    frxMain: TfrxReport;
    frxtb_sysconfig: TfrxDBDataset;
    procedure FormActivate(Sender: TObject);
    procedure Establecercontrasea1Click(Sender: TObject);
    procedure Agregar1Click(Sender: TObject);
    procedure EliminarUsuario1Click(Sender: TObject);
    procedure Propiedades1Click(Sender: TObject);
    procedure lbUserDblClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure AsignacionNodosClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateUserList;
    procedure CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
    procedure InsertConnection(report: TfrxReport; connection: string);
  end;

var
  frmGestUser: TfrmGestUser;

implementation

{$R *.dfm}

uses
  UChangePass, UNewUser, UUserProperties, USystemMsg, UAsignacionNodos, UAsignacionIconos;

procedure TfrmGestUser.Agregar1Click(Sender: TObject);
var
  ListItem: TListItem;
begin
  with TfrmNewUser.Create(nil) do
  try
    UDM.cl_Resp_Gest_Arch.Append;
    ShowModal;
  finally
    Free;
    //FormActivate(Sender);
  end;
  UpdateUserList;
end;

procedure TfrmGestUser.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmGestUser.btnPrintClick(Sender: TObject);
begin
 //esta validacion la puse aqui pero puede ser en otro lugar si deseas
  if ((UDM.tb_sysconfig.FieldByName('empresa').AsString <> '') and (not TBlobField(UDM.tb_sysconfig.FieldByName('logo')).IsNull)) then
  begin
     //salvar el logo que esta en la tabla de configuracion a la carpeta de reportes ,que ahora esta a nivel del mosulo
     //principal
    TBlobField(UDM.tb_sysconfig.FieldByName('logo')).SaveToFile(pathreport + 'logo.png');
    //todos los parametros para cargar el reporte
    CargaReporte(frxMain, pathreport + 'rListUser.fr3', 'empresa', UDM.tb_sysconfig.FieldByName('empresa').AsString, 'imagen', pathreport + 'logo.png');
  end
  else
  begin
    udm.sms('Debe configurar los Datos de la Empresa. Diríjase a la configuración del Sistema', 1);
  end;
end;

procedure TfrmGestUser.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 12;
  Application.HelpContext(TopicID);
end;

procedure TfrmGestUser.CargaReporte(report: TfrxReport; pathreport, nameempresa, empresa, nameimagen, pathimagen: string);
var
  Component: TfrxComponent;
begin
  with report do
  begin
    LoadFromFile(pathreport);
    InsertConnection(report, PathBD);
    Component := FindObject(nameempresa);
    if Component is TfrxRichView then

      TfrxRichView(Component).DataSet:= frxtb_sysconfig;
      TfrxRichView(Component).DataField:='empresa';
    Component := FindObject(nameimagen);
    if Component is TfrxPictureView then
      TfrxPictureView(Component).Picture.LoadFromFile(pathimagen);
    PrepareReport();
    ShowReport();
  end;
end;

procedure TfrmGestUser.EliminarUsuario1Click(Sender: TObject);
begin
  if lbUser.ItemIndex <> -1 then
  begin
    if (lbUser.Items[lbUser.ItemIndex].Caption <> UDM.UserName) and (AnsiLowerCase(lbUser.Items[lbUser.ItemIndex].Caption) <> 'administrador') then
    begin

      if UDM.cl_Resp_Gest_Arch.Locate('usuario', lbUser.Items[lbUser.ItemIndex].Caption, []) then
      begin
        if UDM.sms('¿Está seguro de querer borrar el usuario "' + lbUser.Items[lbUser.ItemIndex].Caption + '"?', 4) = 6 then
          UDM.cl_Resp_Gest_Arch.Delete;
      end;

    end
    else
    begin
      UDM.sms('No puede eliminar el usuario "' + lbUser.Items[lbUser.ItemIndex].Caption + '". Verifique: ' + #13 + '1- Que el usuario especificado no sea el administrador del sistema.' + #13 + '2- Que el usuario especificado no sea el mismo con el que se encuentra autenticado en el sistema.', 2);
      Exit;
    end;
  end
  else
    UDM.sms('Debe seleccionar un usuario válido.', 3);
  UpdateUserList;
end;

procedure TfrmGestUser.Establecercontrasea1Click(Sender: TObject);
var
  nombreu: string;
begin
  nombreu := '';
  if lbUser.ItemIndex <> -1 then
  begin     // UDM.cl_Resp_Gest_Arch
    if UDM.cl_Resp_Gest_Arch.Locate('usuario', lbUser.Items[lbUser.ItemIndex].Caption, []) then
      nombreu := UDM.cl_Resp_Gest_Arch.FieldByName('usuario').AsString;
    with TfrmChangePass.Create(nil) do
    try
      Caption := 'Establecer contraseña para ' + nombreu;
      ShowModal;
    finally
      Free;
    end;
  end
  else
    UDM.sms('Debe seleccionar un usuario válido.', 3);
end;

procedure TfrmGestUser.FormActivate(Sender: TObject);
begin
  UpdateUserList;
  if lbUser.ItemIndex = -1 then
    lbUser.Items[0].Selected := True;
end;

procedure TfrmGestUser.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  TopicID: integer;
begin
  if Key = 112 then
  begin
    TopicID := 12;
    Application.HelpContext(TopicID);
  end;

end;

procedure TfrmGestUser.AsignacionNodosClick(Sender: TObject);
begin
  MostrarAsignacionNodos;
end;

procedure TfrmGestUser.FormShow(Sender: TObject);
var
  Boton: TJvTransparentButton;
begin
  // Asignacion de EGD y Directores a los nodos: solo con SQL Server. Esta
  // pantalla de usuarios solo la abre el administrador. El boton se suma a la
  // barra superior con el aspecto de los demas.
  if (TBD = 'S') and (FindComponent('btnAsignacionNodos') = nil) then
  begin
    Boton := TJvTransparentButton.Create(Self);
    Boton.Name := 'btnAsignacionNodos';
    Boton.Caption := '';
    Boton.Parent := pMainContainer;
    Boton.Left := btnPrint.Left + btnPrint.Width;
    Boton.Align := alLeft;
    Boton.Width := 55;
    Boton.Height := 39;
    Boton.AutoGray := False;
    Boton.Color := 13135884;
    Boton.FrameStyle := fsIndent;
    Boton.Hint := 'Asignaci' + #243 + 'n de responsables por nodo (EGD y Directores)';
    Boton.ShowHint := True;
    CargarIcono(iaAsignacion, Boton.Glyph);
    Boton.OnClick := AsignacionNodosClick;
  end;
  Edit1.Focused;
  Edit1.SetFocus;
end;

procedure TfrmGestUser.InsertConnection(report: TfrxReport; connection: string);
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
  end
end;

procedure TfrmGestUser.lbUserDblClick(Sender: TObject);
begin
  if lbUser.ItemIndex <> -1 then
  begin
    if UDM.cl_Resp_Gest_Arch.Locate('usuario', lbUser.Items[lbUser.ItemIndex].Caption, []) then
    begin
      with TfrmProperties.Create(nil) do
      try
        ShowModal;
      finally
        Free;
      end;
      UpdateUserList;
    end;
  end;
end;

procedure TfrmGestUser.Propiedades1Click(Sender: TObject);
begin
  if lbUser.ItemIndex <> -1 then
  begin
    if UDM.cl_Resp_Gest_Arch.Locate('usuario', lbUser.Items[lbUser.ItemIndex].Caption, []) then
    begin
      with TfrmProperties.Create(nil) do
      try
        ShowModal;
      finally
        Free;
      end;
      UpdateUserList;
    end;
  end
  else
    UDM.sms('Debe seleccionar un usuario válido.', 3);
end;

procedure TfrmGestUser.UpdateUserList;
var
  ListItem: TListItem;
begin
  lbUser.Items.Clear;
  UDM.cmdUser.Active := False;
  UDM.cmdUser.Active := True;
  UDM.cmdUser.First;
  while not UDM.cmdUser.Eof do
  begin
    lbUser.Items.BeginUpdate;
    ListItem := lbUser.Items.Add;
    ListItem.Caption := UDM.cmdUser.FieldByName('usuario').AsString;
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('Nombre').AsString);
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('rol').AsString);
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('email').AsString);
    ListItem.SubItems.Add(UDM.cmdUser.FieldByName('telefono').AsString);
    ListItem.ImageIndex := 133;
    ListItem.StateIndex := 133;
    lbUser.Items.EndUpdate;
    UDM.cmdUser.Next;
  end;
end;

end.

