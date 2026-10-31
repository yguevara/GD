unit UAsignacionNodos;

{ Pantalla de asignacion de EGD y Directores a los nodos del arbol (solo
  administrador, solo SQL Server). Opcion "B" del diseno: arbol con casillas a
  la izquierda; a la derecha se elige usuario y rol y se pulsa "Asignar a los
  marcados". Las reglas (que nodos se afectan, escritura transaccional) viven
  en UAsignacionDatos; aqui solo se pinta y se recoge lo que el usuario marca.

  El formulario se construye por codigo (sin .dfm) para no depender del
  disenador. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Generics.Collections, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Winapi.CommCtrl, UAlcance, UAsignacionDatos;

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
    FLblResumen: TLabel;
    FChkSoloSinEGD: TCheckBox;
    FCmbUsuario: TComboBox;
    FRgRol: TRadioGroup;
    FChkHijos: TCheckBox;
    FBtnAsignar: TButton;
    FBtnQuitar: TButton;
    FBtnCerrar: TButton;
    function Clave(const N: TClaveNodo): string;
    function NodoMarcado(Nodo: TTreeNode): Boolean;
    procedure MarcarNodo(Nodo: TTreeNode; Valor: Boolean);
    procedure CargarTodo;
    procedure Reconstruir;
    function TextoNodo(const Info: TInfoNodo): string;
    function MarcadosActuales: TArray<TClaveNodo>;
    procedure Ejecutar(Agregar: Boolean);
    procedure RegistrarLog(Agregar: Boolean; const Usuario: string;
      Rol: TRolNodo; const Cambios: TArray<TCambioAsignacion>);
    procedure AsignarClick(Sender: TObject);
    procedure QuitarClick(Sender: TObject);
    procedure CerrarClick(Sender: TObject);
    procedure FiltroClick(Sender: TObject);
    procedure TreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure TreeCreateWnd;
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
  Vcl.Graphics, Vcl.Dialogs, FireDAC.Comp.Client, Data.DB, UCapaDatos;

const
  TVS_CHECKBOXES = $00000100;
  ROL_EGD_INDICE = 0;
  ROL_DIRECTOR_INDICE = 1;
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

constructor TfrmAsignacionNodos.Create(AOwner: TComponent);
var
  PnlSup, PnlDer: TPanel;
begin
  inherited CreateNew(AOwner);
  Caption := 'Asignaci' + #243 + 'n de responsables por nodo';
  Position := poScreenCenter;
  ClientWidth := 900;
  ClientHeight := 560;
  BorderIcons := [biSystemMenu, biMaximize];

  FInfos := TList<TInfoNodo>.Create;
  FSinEGD := TDictionary<string, Boolean>.Create;

  PnlSup := TPanel.Create(Self);
  PnlSup.Parent := Self;
  PnlSup.Align := alTop;
  PnlSup.Height := 34;
  PnlSup.BevelOuter := bvNone;

  FLblResumen := TLabel.Create(Self);
  FLblResumen.Parent := PnlSup;
  FLblResumen.Left := 8;
  FLblResumen.Top := 9;

  FChkSoloSinEGD := TCheckBox.Create(Self);
  FChkSoloSinEGD.Parent := PnlSup;
  FChkSoloSinEGD.Left := 420;
  FChkSoloSinEGD.Top := 7;
  FChkSoloSinEGD.Width := 300;
  FChkSoloSinEGD.Caption := 'Mostrar solo los nodos sin EGD propio';
  FChkSoloSinEGD.OnClick := FiltroClick;

  PnlDer := TPanel.Create(Self);
  PnlDer.Parent := Self;
  PnlDer.Align := alRight;
  PnlDer.Width := 280;
  PnlDer.BevelOuter := bvNone;

  with TLabel.Create(Self) do
  begin
    Parent := PnlDer;
    Left := 12;
    Top := 14;
    Caption := 'Usuario';
  end;
  FCmbUsuario := TComboBox.Create(Self);
  FCmbUsuario.Parent := PnlDer;
  FCmbUsuario.Left := 12;
  FCmbUsuario.Top := 32;
  FCmbUsuario.Width := 252;
  FCmbUsuario.Style := csDropDownList;

  FRgRol := TRadioGroup.Create(Self);
  FRgRol.Parent := PnlDer;
  FRgRol.Left := 12;
  FRgRol.Top := 68;
  FRgRol.Width := 252;
  FRgRol.Height := 62;
  FRgRol.Caption := 'Rol';
  FRgRol.Items.Add('EGD (especialista de gesti' + #243 + 'n documental)');
  FRgRol.Items.Add('Director');
  FRgRol.ItemIndex := ROL_EGD_INDICE;

  FChkHijos := TCheckBox.Create(Self);
  FChkHijos.Parent := PnlDer;
  FChkHijos.Left := 12;
  FChkHijos.Top := 142;
  FChkHijos.Width := 252;
  FChkHijos.Caption := 'Incluir todos los nodos hijos';
  FChkHijos.Checked := True;

  FBtnAsignar := TButton.Create(Self);
  FBtnAsignar.Parent := PnlDer;
  FBtnAsignar.SetBounds(12, 176, 252, 30);
  FBtnAsignar.Caption := 'Asignar a los marcados';
  FBtnAsignar.OnClick := AsignarClick;

  FBtnQuitar := TButton.Create(Self);
  FBtnQuitar.Parent := PnlDer;
  FBtnQuitar.SetBounds(12, 212, 252, 30);
  FBtnQuitar.Caption := 'Quitar de los marcados';
  FBtnQuitar.OnClick := QuitarClick;

  with TLabel.Create(Self) do
  begin
    Parent := PnlDer;
    SetBounds(12, 262, 252, 120);
    AutoSize := False;
    WordWrap := True;
    Caption := 'Marque los nodos en el '#225'rbol. Lo asignado a un nodo vale para ' +
      'sus descendientes. Un nodo debe tener al menos un EGD propio; los nodos ' +
      'sin EGD propio se muestran en rojo.';
  end;

  FBtnCerrar := TButton.Create(Self);
  FBtnCerrar.Parent := PnlDer;
  FBtnCerrar.SetBounds(12, 510, 252, 30);
  FBtnCerrar.Anchors := [akLeft, akBottom];
  FBtnCerrar.Caption := 'Cerrar';
  FBtnCerrar.OnClick := CerrarClick;

  FTree := TTreeView.Create(Self);
  FTree.Parent := Self;
  FTree.Align := alClient;
  FTree.ReadOnly := True;
  FTree.HideSelection := False;
  FTree.OnCustomDrawItem := TreeCustomDrawItem;
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
  TreeCreateWnd;
  CargarTodo;
end;

{ El TTreeView de la VCL no expone casillas: se activa el estilo de Windows. }
procedure TfrmAsignacionNodos.TreeCreateWnd;
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

function TfrmAsignacionNodos.TextoNodo(const Info: TInfoNodo): string;
var
  P: TAsignacion;
  Anc: TClaveNodo;
  Egd, Dir, HerEgd, HerDir: string;

  procedure Sumar(var Lista: string; const Usuario: string);
  begin
    if Lista <> '' then
      Lista := Lista + ', ';
    Lista := Lista + Usuario;
  end;

begin
  for P in FPropias do
    if Clave(P.Nodo) = Clave(Info.Clave) then
    begin
      if P.Rol = rnEGD then
        Sumar(Egd, P.Usuario)
      else
        Sumar(Dir, P.Usuario);
    end;
  for Anc in FArbol.Ancestros(Info.Clave) do
    for P in FPropias do
      if Clave(P.Nodo) = Clave(Anc) then
      begin
        if P.Rol = rnEGD then
          Sumar(HerEgd, P.Usuario)
        else
          Sumar(HerDir, P.Usuario);
      end;
  Result := Info.Etiqueta + '  [' + Info.Clave.IdEstructura + ']';
  if Egd <> '' then
    Result := Result + '   EGD: ' + Egd;
  if Dir <> '' then
    Result := Result + '   Director: ' + Dir;
  if HerEgd <> '' then
    Result := Result + '   (hereda EGD: ' + HerEgd + ')';
  if HerDir <> '' then
    Result := Result + '   (hereda Director: ' + HerDir + ')';
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
    FLblResumen.Caption := Format('%d nodos, %d sin EGD propio',
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

procedure TfrmAsignacionNodos.FiltroClick(Sender: TObject);
begin
  // en la lista plana filtrada no se ven los hijos: no se permite asignar a ciegas
  if FChkSoloSinEGD.Checked then
    FChkHijos.Checked := False;
  FChkHijos.Enabled := not FChkSoloSinEGD.Checked;
  Reconstruir;
end;

end.
