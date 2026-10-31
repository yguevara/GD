unit UAsignacionNodos;

{ Pantalla de asignacion de EGD y Directores a los nodos del arbol (solo
  administrador, solo SQL Server). Opcion "B" del diseno: arbol con casillas a
  la izquierda; a la derecha se elige usuario y rol y se pulsa "Asignar a los
  marcados". Las reglas (que nodos se afectan, escritura transaccional) viven
  en UAsignacionDatos; aqui solo se pinta y se recoge lo que el usuario marca.

  Mantiene el aspecto de las demas pantallas: barra superior con Cerrar,
  Reporte y Ayuda, y barra de estado. El formulario se construye por codigo
  (sin .dfm) para no depender del disenador. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Generics.Collections, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Winapi.CommCtrl, JvTransparentButton, UAlcance,
  UAsignacionDatos, UAsignacionIconos;

type
  TfrmAsignacionNodos = class(TForm)
  private
    type
      TInfoNodo = record
        Clave: TClaveNodo;
        Etiqueta: string;
        Padre: TClaveNodo;
        TienePadre: Boolean;
      end;
  private
    FArbol: TArbolNodos;
    FInfos: TList<TInfoNodo>;
    FPropias: TArray<TAsignacion>;
    FSinEGD: TDictionary<string, Boolean>;
    FTree: TTreeView;
    FBarraEstado: TStatusBar;
    FChkSoloSinEGD: TCheckBox;
    FCmbUsuario: TComboBox;
    FRgRol: TRadioGroup;
    FChkHijos: TCheckBox;
    FBtnAsignar: TButton;
    FBtnQuitar: TButton;
    function Clave(const N: TClaveNodo): string;
    function NodoMarcado(Nodo: TTreeNode): Boolean;
    procedure MarcarNodo(Nodo: TTreeNode; Valor: Boolean);
    procedure MarcarDescendientes(Nodo: TTreeNode; Valor: Boolean);
    function CrearBoton(Barra: TPanel; Icono: TIconoAsignacion;
      const Pista: string; Lado: TAlign; AlClick: TNotifyEvent): TJvTransparentButton;
    procedure CargarTodo;
    procedure Reconstruir;
    function ResponsablesPropios(const N: TClaveNodo; Rol: TRolNodo): string;
    function TextoNodo(const Info: TInfoNodo): string;
    function MarcadosActuales: TArray<TClaveNodo>;
    procedure Ejecutar(Agregar: Boolean);
    procedure RegistrarLog(Agregar: Boolean; const Usuario: string;
      Rol: TRolNodo; const Cambios: TArray<TCambioAsignacion>);
    procedure AsignarClick(Sender: TObject);
    procedure QuitarClick(Sender: TObject);
    procedure CerrarClick(Sender: TObject);
    procedure ReporteClick(Sender: TObject);
    procedure AyudaClick(Sender: TObject);
    procedure FiltroClick(Sender: TObject);
    procedure HijosClick(Sender: TObject);
    procedure TreeClick(Sender: TObject);
    procedure TreeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ActivarCasillas;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); reintroduce;
    destructor Destroy; override;
  end;

{ Abre la pantalla de forma modal. }
procedure MostrarAsignacionNodos;

implementation

uses
  Vcl.Graphics, Vcl.Dialogs, FireDAC.Comp.Client, Data.DB, frxClass, frxDBSet,
  UCapaDatos;

const
  TVS_CHECKBOXES = $00000100;
  ROL_EGD_INDICE = 0;
  TEMA_AYUDA = 12;           // mismo tema que la administracion de usuarios
  ACCION_LOG_INSERTAR = 5;   // tb_accionlog: 5 = Insertar
  ACCION_LOG_ELIMINAR = 2;   // tb_accionlog: 2 = Eliminar

procedure MostrarAsignacionNodos;
begin
  with TfrmAsignacionNodos.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

{ TfrmAsignacionNodos }

{ Boton de la barra superior con el mismo aspecto que los de las demas
  pantallas (55 x 39, hundido, icono blanco). }
function TfrmAsignacionNodos.CrearBoton(Barra: TPanel; Icono: TIconoAsignacion;
  const Pista: string; Lado: TAlign; AlClick: TNotifyEvent): TJvTransparentButton;
begin
  Result := TJvTransparentButton.Create(Self);
  Result.Parent := Barra;
  Result.Caption := '';
  Result.Align := Lado;
  Result.Width := 55;
  Result.Height := 39;
  Result.AutoGray := False;
  Result.Color := 13135884;
  Result.FrameStyle := fsIndent;
  Result.Hint := Pista;
  Result.ShowHint := True;
  CargarIcono(Icono, Result.Glyph);
  Result.OnClick := AlClick;
end;

constructor TfrmAsignacionNodos.Create(AOwner: TComponent);
var
  Barra, PnlDer: TPanel;
  Nota: TLabel;
  Etiqueta: TLabel;
begin
  inherited CreateNew(AOwner);
  Caption := 'Asignaci' + #243 + 'n de responsables por nodo';
  Color := clBtnFace;
  Font.Name := 'Tahoma';
  Font.Height := -11;
  Position := poScreenCenter;
  ClientWidth := 900;
  ClientHeight := 560;
  Icon.Assign(Application.Icon);
  KeyPreview := True;
  OnKeyDown := FormKeyDown;

  FInfos := TList<TInfoNodo>.Create;
  FSinEGD := TDictionary<string, Boolean>.Create;

  FBarraEstado := TStatusBar.Create(Self);
  FBarraEstado.Parent := Self;
  FBarraEstado.SimplePanel := True;

  Barra := TPanel.Create(Self);
  Barra.Parent := Self;
  Barra.Align := alTop;
  Barra.Height := 41;
  Barra.Color := 15780526;
  Barra.ParentBackground := False;
  Barra.Caption := '';
  CrearBoton(Barra, iaCerrar, 'Regresar a la ventana anterior', alLeft, CerrarClick);
  CrearBoton(Barra, iaReporte, 'Reporte de responsables por nodo', alLeft, ReporteClick);
  CrearBoton(Barra, iaAyuda, 'Ayuda para la asignaci' + #243 + 'n de responsables',
    alRight, AyudaClick);

  PnlDer := TPanel.Create(Self);
  PnlDer.Parent := Self;
  PnlDer.Align := alRight;
  PnlDer.Width := 280;
  PnlDer.BevelOuter := bvNone;
  PnlDer.Caption := '';
  PnlDer.ParentBackground := False;

  Etiqueta := TLabel.Create(Self);
  Etiqueta.Parent := PnlDer;
  Etiqueta.SetBounds(12, 14, 40, 13);
  Etiqueta.Caption := 'Usuario';

  FCmbUsuario := TComboBox.Create(Self);
  FCmbUsuario.Parent := PnlDer;
  FCmbUsuario.SetBounds(12, 32, 252, 21);
  FCmbUsuario.Style := csDropDownList;

  FRgRol := TRadioGroup.Create(Self);
  FRgRol.Parent := PnlDer;
  FRgRol.SetBounds(12, 68, 252, 62);
  FRgRol.Caption := 'Rol';
  FRgRol.Items.Add('EGD (especialista de gesti' + #243 + 'n documental)');
  FRgRol.Items.Add('Director');
  FRgRol.ItemIndex := ROL_EGD_INDICE;

  FChkHijos := TCheckBox.Create(Self);
  FChkHijos.Parent := PnlDer;
  FChkHijos.SetBounds(12, 142, 252, 17);
  FChkHijos.Caption := 'Incluir todos los nodos hijos';
  FChkHijos.Checked := True;
  FChkHijos.OnClick := HijosClick;

  FChkSoloSinEGD := TCheckBox.Create(Self);
  FChkSoloSinEGD.Parent := PnlDer;
  FChkSoloSinEGD.SetBounds(12, 166, 252, 17);
  FChkSoloSinEGD.Caption := 'Mostrar solo los nodos sin EGD propio';
  FChkSoloSinEGD.OnClick := FiltroClick;

  FBtnAsignar := TButton.Create(Self);
  FBtnAsignar.Parent := PnlDer;
  FBtnAsignar.SetBounds(12, 198, 252, 30);
  FBtnAsignar.Caption := 'Asignar a los marcados';
  FBtnAsignar.OnClick := AsignarClick;

  FBtnQuitar := TButton.Create(Self);
  FBtnQuitar.Parent := PnlDer;
  FBtnQuitar.SetBounds(12, 234, 252, 30);
  FBtnQuitar.Caption := 'Quitar de los marcados';
  FBtnQuitar.OnClick := QuitarClick;

  Nota := TLabel.Create(Self);
  Nota.Parent := PnlDer;
  Nota.SetBounds(12, 284, 252, 120);
  Nota.AutoSize := False;
  Nota.WordWrap := True;
  Nota.Caption := 'Marque los nodos en el '#225'rbol. Lo asignado a un nodo vale para ' +
    'sus descendientes. Un nodo debe tener al menos un EGD propio; los nodos ' +
    'sin EGD propio se muestran en rojo.';

  FTree := TTreeView.Create(Self);
  FTree.Parent := Self;
  FTree.Align := alClient;
  FTree.ReadOnly := True;
  FTree.HideSelection := False;
  FTree.OnCustomDrawItem := TreeCustomDrawItem;
  FTree.OnClick := TreeClick;
  FTree.OnKeyUp := TreeKeyUp;
end;

destructor TfrmAsignacionNodos.Destroy;
begin
  FSinEGD.Free;
  FInfos.Free;
  FArbol.Free;
  inherited;
end;

procedure TfrmAsignacionNodos.DoShow;
begin
  inherited;
  ActivarCasillas;
  CargarTodo;
end;

{ El TTreeView de la VCL no expone casillas: se activa el estilo de Windows. }
procedure TfrmAsignacionNodos.ActivarCasillas;
begin
  SetWindowLong(FTree.Handle, GWL_STYLE,
    GetWindowLong(FTree.Handle, GWL_STYLE) or TVS_CHECKBOXES);
end;

{ La casilla de un TTreeView con TVS_CHECKBOXES es la imagen de estado 1 (vacia)
  o 2 (marcada); la VCL de esta version no trae TTreeNode.Checked. }
function TfrmAsignacionNodos.NodoMarcado(Nodo: TTreeNode): Boolean;
var
  Item: TTVItem;
begin
  FillChar(Item, SizeOf(Item), 0);
  Item.mask := TVIF_STATE;
  Item.hItem := Nodo.ItemId;
  Item.stateMask := TVIS_STATEIMAGEMASK;
  SendMessage(FTree.Handle, TVM_GETITEM, 0, LPARAM(@Item));
  Result := ((Item.state shr 12) = 2);
end;

procedure TfrmAsignacionNodos.MarcarNodo(Nodo: TTreeNode; Valor: Boolean);
var
  Item: TTVItem;
begin
  FillChar(Item, SizeOf(Item), 0);
  Item.mask := TVIF_STATE;
  Item.hItem := Nodo.ItemId;
  Item.stateMask := TVIS_STATEIMAGEMASK;
  if Valor then
    Item.state := 2 shl 12
  else
    Item.state := 1 shl 12;
  SendMessage(FTree.Handle, TVM_SETITEM, 0, LPARAM(@Item));
end;

procedure TfrmAsignacionNodos.MarcarDescendientes(Nodo: TTreeNode; Valor: Boolean);
var
  Hijo: TTreeNode;
begin
  Hijo := Nodo.GetFirstChild;
  while Hijo <> nil do
  begin
    MarcarNodo(Hijo, Valor);
    MarcarDescendientes(Hijo, Valor);
    Hijo := Nodo.GetNextChild(Hijo);
  end;
end;

{ Con "Incluir hijos" activo, marcar o desmarcar un nodo hace lo mismo con todos
  sus descendientes, para que se vea a que nodos se aplicara el cambio. }
procedure TfrmAsignacionNodos.TreeClick(Sender: TObject);
var
  Pos: TPoint;
  Nodo: TTreeNode;
begin
  if not FChkHijos.Checked then
    Exit;
  GetCursorPos(Pos);
  Pos := FTree.ScreenToClient(Pos);
  if htOnStateIcon in FTree.GetHitTestInfoAt(Pos.X, Pos.Y) then
  begin
    Nodo := FTree.GetNodeAt(Pos.X, Pos.Y);
    if Nodo <> nil then
      MarcarDescendientes(Nodo, NodoMarcado(Nodo));
  end;
end;

procedure TfrmAsignacionNodos.TreeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_SPACE) and FChkHijos.Checked and (FTree.Selected <> nil) then
    MarcarDescendientes(FTree.Selected, NodoMarcado(FTree.Selected));
end;

procedure TfrmAsignacionNodos.HijosClick(Sender: TObject);
var
  I: Integer;
begin
  // al activarlo, los hijos de lo ya marcado se marcan tambien
  if not FChkHijos.Checked then
    Exit;
  for I := 0 to FTree.Items.Count - 1 do
    if NodoMarcado(FTree.Items[I]) then
      MarcarDescendientes(FTree.Items[I], True);
end;

function TfrmAsignacionNodos.Clave(const N: TClaveNodo): string;
begin
  Result := NormalizaClave(N.IdEstructura) + '|' + IntToStr(N.Id);
end;

procedure TfrmAsignacionNodos.CargarTodo;
var
  Q: TFDQuery;
  Info: TInfoNodo;
  Usuarios: TArray<string>;
  U: string;
  I: Integer;
begin
  FreeAndNil(FArbol);
  FArbol := TArbolNodos.Create;
  FInfos.Clear;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := UDM.Conn;
    Q.SQL.Text := 'SELECT IdEstructura, id, etiqueta, padre FROM tb_tree ' +
      'ORDER BY IdEstructura, id';
    Q.Open;
    while not Q.Eof do
    begin
      Info.Clave.IdEstructura := Q.Fields[0].AsString;
      Info.Clave.Id := Q.Fields[1].AsInteger;
      Info.Etiqueta := Q.Fields[2].AsString;
      FArbol.Agregar(Info.Clave, Q.Fields[3].AsInteger);
      FInfos.Add(Info);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  // el padre se deduce del arbol: es el primer ancestro
  for I := 0 to FInfos.Count - 1 do
  begin
    Info := FInfos[I];
    Info.TienePadre := Length(FArbol.Ancestros(Info.Clave)) > 0;
    if Info.TienePadre then
      Info.Padre := FArbol.Ancestros(Info.Clave)[0];
    FInfos[I] := Info;
  end;

  FCmbUsuario.Items.Clear;
  Usuarios := UsuariosHabilitados(UDM.Conn);
  for U in Usuarios do
    FCmbUsuario.Items.Add(U);
  if FCmbUsuario.Items.Count > 0 then
    FCmbUsuario.ItemIndex := 0;
  Reconstruir;
end;

{ Logins asignados como propios en el nodo con ese rol, separados por coma. }
function TfrmAsignacionNodos.ResponsablesPropios(const N: TClaveNodo;
  Rol: TRolNodo): string;
var
  P: TAsignacion;
begin
  Result := '';
  for P in FPropias do
    if (P.Rol = Rol) and (Clave(P.Nodo) = Clave(N)) then
    begin
      if Result <> '' then
        Result := Result + ', ';
      Result := Result + P.Usuario;
    end;
end;

function TfrmAsignacionNodos.TextoNodo(const Info: TInfoNodo): string;
var
  Anc: TClaveNodo;
  Egd, Dir, HerEgd, HerDir, S: string;

  procedure Sumar(var Lista: string; const Usuarios: string);
  begin
    if Usuarios = '' then
      Exit;
    if Lista <> '' then
      Lista := Lista + ', ';
    Lista := Lista + Usuarios;
  end;

begin
  Egd := ResponsablesPropios(Info.Clave, rnEGD);
  Dir := ResponsablesPropios(Info.Clave, rnDirector);
  for Anc in FArbol.Ancestros(Info.Clave) do
  begin
    Sumar(HerEgd, ResponsablesPropios(Anc, rnEGD));
    Sumar(HerDir, ResponsablesPropios(Anc, rnDirector));
  end;
  S := Info.Etiqueta + '  [' + Info.Clave.IdEstructura + ']';
  if Egd <> '' then
    S := S + '   EGD: ' + Egd;
  if Dir <> '' then
    S := S + '   Director: ' + Dir;
  if HerEgd <> '' then
    S := S + '   (hereda EGD: ' + HerEgd + ')';
  if HerDir <> '' then
    S := S + '   (hereda Director: ' + HerDir + ')';
  Result := S;
end;

function TfrmAsignacionNodos.MarcadosActuales: TArray<TClaveNodo>;
var
  Lista: TList<TClaveNodo>;
  I: Integer;
begin
  Lista := TList<TClaveNodo>.Create;
  try
    for I := 0 to FTree.Items.Count - 1 do
      if NodoMarcado(FTree.Items[I]) then
        Lista.Add(FInfos[Integer(FTree.Items[I].Data) - 1].Clave);
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

procedure TfrmAsignacionNodos.Reconstruir;
var
  Marcados: TDictionary<string, Boolean>;
  Nodos: TDictionary<string, TTreeNode>;
  Sin: TArray<TClaveNodo>;
  N: TClaveNodo;
  I: Integer;
  Info: TInfoNodo;
  Nuevo, PadreNodo: TTreeNode;
  M: TClaveNodo;
begin
  Marcados := TDictionary<string, Boolean>.Create;
  Nodos := TDictionary<string, TTreeNode>.Create;
  try
    for M in MarcadosActuales do
      Marcados.AddOrSetValue(Clave(M), True);

    FPropias := CargarAsignaciones(UDM.Conn);
    FSinEGD.Clear;
    Sin := NodosSinEGDPropio(FArbol, FPropias);
    for N in Sin do
      FSinEGD.AddOrSetValue(Clave(N), True);
    FBarraEstado.SimpleText := Format('%d nodos, %d sin EGD propio',
      [FInfos.Count, Length(Sin)]);

    FTree.Items.BeginUpdate;
    try
      FTree.Items.Clear;
      // FInfos esta ordenado por IdEstructura: un padre aparece antes que sus hijos
      for I := 0 to FInfos.Count - 1 do
      begin
        Info := FInfos[I];
        if FChkSoloSinEGD.Checked and not FSinEGD.ContainsKey(Clave(Info.Clave)) then
          Continue;
        PadreNodo := nil;
        if (not FChkSoloSinEGD.Checked) and Info.TienePadre then
          Nodos.TryGetValue(Clave(Info.Padre), PadreNodo);
        Nuevo := FTree.Items.AddChild(PadreNodo, TextoNodo(Info));
        Nuevo.Data := Pointer(I + 1); // +1: Data = nil significa "sin dato"
        Nodos.AddOrSetValue(Clave(Info.Clave), Nuevo);
        if Marcados.ContainsKey(Clave(Info.Clave)) then
          MarcarNodo(Nuevo, True);
      end;
      if (FTree.Items.Count > 0) and (not FChkSoloSinEGD.Checked) then
        FTree.Items[0].Expand(False);
    finally
      FTree.Items.EndUpdate;
    end;
  finally
    Nodos.Free;
    Marcados.Free;
  end;
end;

procedure TfrmAsignacionNodos.TreeCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  // los nodos sin EGD propio se destacan en rojo (salvo el seleccionado)
  if (Node.Data <> nil) and not (cdsSelected in State) and
    FSinEGD.ContainsKey(Clave(FInfos[Integer(Node.Data) - 1].Clave)) then
    Sender.Canvas.Font.Color := clMaroon;
end;

procedure TfrmAsignacionNodos.Ejecutar(Agregar: Boolean);
var
  Marcados: TArray<TClaveNodo>;
  Rol: TRolNodo;
  Usuario: string;
  Cambios: TArray<TCambioAsignacion>;
begin
  if FCmbUsuario.ItemIndex < 0 then
  begin
    UDM.sms('Elija el usuario.', 2);
    Exit;
  end;
  Marcados := MarcadosActuales;
  if Length(Marcados) = 0 then
  begin
    UDM.sms('Marque al menos un nodo del '#225'rbol.', 2);
    Exit;
  end;
  Usuario := FCmbUsuario.Text;
  if FRgRol.ItemIndex = ROL_EGD_INDICE then
    Rol := rnEGD
  else
    Rol := rnDirector;
  Cambios := CalcularCambios(FArbol, Marcados, FChkHijos.Checked, Rol, Usuario, Agregar);
  if (not Agregar) and (Length(Cambios) > 1) then
    if UDM.sms(Format('Se quitar'#225' a %s de %d nodos. '#191'Continuar?',
      [Usuario, Length(Cambios)]), 4) <> IDYES then
      Exit;
  try
    AplicarCambios(UDM.Conn, Cambios);
  except
    on E: Exception do
    begin
      UDM.sms('No se guard' + #243 + ' ning' + #250 + 'n cambio: ' + E.Message, 1);
      Exit;
    end;
  end;
  RegistrarLog(Agregar, Usuario, Rol, Cambios);
  Reconstruir;
end;

procedure TfrmAsignacionNodos.RegistrarLog(Agregar: Boolean; const Usuario: string;
  Rol: TRolNodo; const Cambios: TArray<TCambioAsignacion>);
var
  NombreRol, Verbo, Accion: string;
  Codigo: Integer;
begin
  if Length(Cambios) = 0 then
    Exit;
  if Rol = rnEGD then
    NombreRol := 'EGD'
  else
    NombreRol := 'Director';
  if Agregar then
  begin
    Verbo := 'Asign' + #243;
    Codigo := ACCION_LOG_INSERTAR;
  end
  else
  begin
    Verbo := 'Quit' + #243;
    Codigo := ACCION_LOG_ELIMINAR;
  end;
  Accion := Format('%s %s %s en %d nodo(s), desde %s.', [Verbo, NombreRol, Usuario,
    Length(Cambios), Cambios[0].Asignacion.Nodo.IdEstructura]);
  UDM.log(Accion, Codigo, '', '', Cambios[0].Asignacion.Nodo.IdEstructura);
end;

procedure TfrmAsignacionNodos.AsignarClick(Sender: TObject);
begin
  Ejecutar(True);
end;

procedure TfrmAsignacionNodos.QuitarClick(Sender: TObject);
begin
  Ejecutar(False);
end;

procedure TfrmAsignacionNodos.CerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmAsignacionNodos.AyudaClick(Sender: TObject);
begin
  Application.HelpContext(TEMA_AYUDA);
end;

procedure TfrmAsignacionNodos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
end;

procedure TfrmAsignacionNodos.FiltroClick(Sender: TObject);
begin
  // en la lista plana filtrada no se ven los hijos: no se permite asignar a ciegas
  if FChkSoloSinEGD.Checked then
    FChkHijos.Checked := False;
  FChkHijos.Enabled := not FChkSoloSinEGD.Checked;
  Reconstruir;
end;

{ Reporte de responsables propios por nodo, en el visor de FastReport. }
procedure TfrmAsignacionNodos.ReporteClick(Sender: TObject);
const
  ANCHOS: array[0..3] of Integer = (70, 250, 200, 180);
  TITULOS: array[0..3] of string = ('Estructura', 'Nodo', 'EGD', 'Director');
  CAMPOS: array[0..3] of string = ('Estructura', 'Nodo', 'EGD', 'Director');
var
  Mem: TFDMemTable;
  DS: TfrxDBDataset;
  Rep: TfrxReport;
  Pagina: TfrxReportPage;
  Titulo: TfrxReportTitle;
  Cabecera: TfrxPageHeader;
  Datos: TfrxMasterData;
  Memo: TfrxMemoView;
  Info: TInfoNodo;
  I, X: Integer;
begin
  Mem := TFDMemTable.Create(nil);
  DS := TfrxDBDataset.Create(nil);
  Rep := TfrxReport.Create(nil);
  try
    for I := 0 to High(CAMPOS) do
      Mem.FieldDefs.Add(CAMPOS[I], ftString, 250);
    Mem.CreateDataSet;
    for Info in FInfos do
    begin
      Mem.Append;
      Mem.FieldByName('Estructura').AsString := Info.Clave.IdEstructura;
      Mem.FieldByName('Nodo').AsString := Info.Etiqueta;
      Mem.FieldByName('EGD').AsString := ResponsablesPropios(Info.Clave, rnEGD);
      Mem.FieldByName('Director').AsString := ResponsablesPropios(Info.Clave, rnDirector);
      Mem.Post;
    end;
    DS.DataSet := Mem;
    DS.UserName := 'responsables';
    Rep.DataSets.Add(DS);

    Rep.Clear;
    Pagina := TfrxReportPage.Create(Rep);
    Pagina.CreateUniqueName;
    Pagina.SetDefaults;

    Titulo := TfrxReportTitle.Create(Pagina);
    Titulo.CreateUniqueName;
    Titulo.Height := 40;
    Memo := TfrxMemoView.Create(Titulo);
    Memo.CreateUniqueName;
    Memo.SetBounds(0, 8, 700, 24);
    Memo.Font.Size := 14;
    Memo.Font.Style := [fsBold];
    Memo.Memo.Text := 'Responsables por nodo (asignaciones propias)';

    Cabecera := TfrxPageHeader.Create(Pagina);
    Cabecera.CreateUniqueName;
    Cabecera.Height := 20;
    X := 0;
    for I := 0 to High(TITULOS) do
    begin
      Memo := TfrxMemoView.Create(Cabecera);
      Memo.CreateUniqueName;
      Memo.SetBounds(X, 0, ANCHOS[I], 18);
      Memo.Font.Style := [fsBold];
      Memo.Frame.Typ := [ftBottom];
      Memo.Memo.Text := TITULOS[I];
      Inc(X, ANCHOS[I]);
    end;

    Datos := TfrxMasterData.Create(Pagina);
    Datos.CreateUniqueName;
    Datos.DataSet := DS;
    Datos.Height := 18;
    X := 0;
    for I := 0 to High(CAMPOS) do
    begin
      Memo := TfrxMemoView.Create(Datos);
      Memo.CreateUniqueName;
      Memo.SetBounds(X, 0, ANCHOS[I], 18);
      Memo.Memo.Text := '[responsables."' + CAMPOS[I] + '"]';
      Inc(X, ANCHOS[I]);
    end;

    Rep.PrepareReport;
    Rep.ShowReport;
  finally
    Rep.Free;
    DS.Free;
    Mem.Free;
  end;
end;

end.
