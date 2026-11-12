unit UVariablesEditor;

{ ---------------------------------------------------------------------------
  Editor visual de las variables del formulario de una subserie (sin .dfm).

    izquierda : lista ordenable (se arrastra una variable para cambiar su orden)
                con el boton "Nueva variable";
    derecha   : propiedades de la variable elegida (nombre interno, etiqueta,
                tipo, longitud, obligatoria, descripcion) y, debajo, "Asi se vera
                el formulario": una vista previa que se actualiza en cada cambio
                y resalta el campo elegido.

  Las reglas (que se puede cambiar o quitar segun la subserie tenga o no
  documentos) viven en TSesionVariables; aqui solo se pintan. Cuando algo esta
  bloqueado el campo queda de solo lectura y arriba se explica por que. Codigo
  en ASCII.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, UTema, UMetadatosSubserie, UVariablesDatos,
  UVariablesSesion, UErroresCampo;

type
  TEditorVariables = class(TPanel)
  private
    FTema: TTemaColores;
    FSesion: TSesionVariables;
    FSel: Integer;
    FCargando: Boolean;
    FDestino: Integer;
    FDesde: Integer;
    FIni: TPoint;
    FArrastrando: Boolean;
    FOnCambio: TNotifyEvent;
    FCabLista: TLabel;
    FBtnNueva: TButton;
    FLista: TListBox;
    FAviso: TPanel;
    FAvisoTexto: TLabel;
    FTituloProps: TLabel;
    FProps: TPanel;
    FLblNombre, FLblEtiqueta, FLblTipo, FLblLong, FLblDesc, FTituloPrevia: TLabel;
    FEdNombre, FEdEtiqueta, FEdLong: TEdit;
    FCbTipo: TComboBox;
    FChkObl: TCheckBox;
    FMemoDesc: TMemo;
    FBtnQuitar: TButton;
    FPrevia: TScrollBox;
    FCamposPrevia: TList<TPanel>;
    function Esc(AValor: Integer): Integer;
    function NuevaEtiqueta(AParent: TWinControl; const ATexto: string; ANegrita: Boolean): TLabel;
    procedure Construir;
    procedure Distribuir;
    procedure RefrescarLista;
    procedure RefrescarPropiedades;
    procedure RefrescarPrevia;
    procedure RefrescarAviso;
    procedure AplicarPropiedades;
    procedure Cambio;
    procedure ListaDibujar(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListaClick(Sender: TObject);
    procedure ListaMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListaMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PropiedadCambio(Sender: TObject);
    procedure NuevaClick(Sender: TObject);
    procedure QuitarClick(Sender: TObject);
    procedure LongitudKeyPress(Sender: TObject; var Key: Char);
    function TextoTipo(const C: TCampoMeta): string;
  protected
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent; const ATema: TTemaColores; AEsSqlServer: Boolean); reintroduce;
    destructor Destroy; override;
    procedure Cargar(const ALista: TArray<TCampoMeta>; AModo: TModoVariables);
    procedure Descartar;
    function Resultado: TArray<TCampoMeta>;
    function HayCambios: Boolean;
    function Errores: TArray<TErrorCampo>;
    procedure SeleccionarIndice(AIndice: Integer);
    { Cambia el orden (lo mismo que arrastrar con el raton). }
    procedure Arrastrar(ADe, AA: Integer);
    property OnCambio: TNotifyEvent read FOnCambio write FOnCambio;
    { Ayudas para las pruebas. }
    function CantidadItems: Integer;
    function CantidadPrevia: Integer;
    function EtiquetaPrevia(AIndice: Integer): string;
    function PreviaResaltada: Integer;
    function NombreSoloLectura: Boolean;
    function TipoDeshabilitado: Boolean;
    function AvisoVisible: Boolean;
    procedure EscribirEtiqueta(const ATexto: string);
    procedure EscribirNombre(const ATexto: string);
  end;

implementation

const
  TIPOS: array[0..5] of string = ('Caracteres', 'Memo (texto largo)', 'Fecha', 'Entero',
    'Real (decimal)', 'S' + #237 + ' / No');

constructor TEditorVariables.Create(AOwner: TComponent; const ATema: TTemaColores;
  AEsSqlServer: Boolean);
begin
  inherited Create(AOwner);
  FTema := ATema;
  FSesion := TSesionVariables.Create(AEsSqlServer);
  FCamposPrevia := TList<TPanel>.Create;
  FSel := -1;
  FDestino := -1;
  FDesde := -1;
  BevelOuter := bvNone;
  ParentBackground := False;
  Color := FTema.Fondo;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  Construir;
end;

destructor TEditorVariables.Destroy;
begin
  FCamposPrevia.Free;
  FSesion.Free;
  inherited;
end;

function TEditorVariables.Esc(AValor: Integer): Integer;
begin
  Result := MulDiv(AValor, Screen.PixelsPerInch, 96);
end;

function TEditorVariables.NuevaEtiqueta(AParent: TWinControl; const ATexto: string;
  ANegrita: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.Caption := ATexto;
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := 9;
  Result.Font.Color := FTema.TextoSuave;
  if ANegrita then
  begin
    Result.Font.Style := [fsBold];
    Result.Font.Color := FTema.Texto;
  end;
  Result.Transparent := True;
end;

procedure TEditorVariables.Construir;
begin
  FCabLista := NuevaEtiqueta(Self, '0 variables', True);
  FBtnNueva := TButton.Create(Self);
  FBtnNueva.Parent := Self;
  FBtnNueva.Caption := '+ Nueva variable';
  FBtnNueva.OnClick := NuevaClick;

  FLista := TListBox.Create(Self);
  FLista.Parent := Self;
  FLista.Style := lbOwnerDrawFixed;
  FLista.ItemHeight := Esc(48);
  FLista.BorderStyle := bsNone;
  FLista.Color := FTema.Superficie;
  FLista.OnDrawItem := ListaDibujar;
  FLista.OnClick := ListaClick;
  FLista.OnMouseDown := ListaMouseDown;
  FLista.OnMouseMove := ListaMouseMove;
  FLista.OnMouseUp := ListaMouseUp;

  FAviso := TPanel.Create(Self);
  FAviso.Parent := Self;
  FAviso.BevelOuter := bvNone;
  FAviso.ParentBackground := False;
  FAviso.Color := ColorDeHex('#fff7e8');
  FAviso.Visible := False;
  FAvisoTexto := TLabel.Create(Self);
  FAvisoTexto.Parent := FAviso;
  FAvisoTexto.WordWrap := True;
  FAvisoTexto.Font.Name := 'Segoe UI';
  FAvisoTexto.Font.Size := 9;
  FAvisoTexto.Font.Color := ColorDeHex('#6b5320');
  FAvisoTexto.Transparent := True;

  FTituloProps := NuevaEtiqueta(Self, 'Propiedades de la variable', True);
  FProps := TPanel.Create(Self);
  FProps.Parent := Self;
  FProps.BevelOuter := bvNone;
  FProps.ParentBackground := False;
  FProps.Color := FTema.Fondo;

  FLblNombre := NuevaEtiqueta(FProps, 'Nombre interno', False);
  FEdNombre := TEdit.Create(Self);
  FEdNombre.Parent := FProps;
  FEdNombre.MaxLength := LONGITUD_MAX_NOMBRE;
  FEdNombre.OnChange := PropiedadCambio;
  FLblEtiqueta := NuevaEtiqueta(FProps, 'Etiqueta (lo que se ve)', False);
  FEdEtiqueta := TEdit.Create(Self);
  FEdEtiqueta.Parent := FProps;
  FEdEtiqueta.MaxLength := 100;
  FEdEtiqueta.OnChange := PropiedadCambio;
  FLblTipo := NuevaEtiqueta(FProps, 'Tipo', False);
  FCbTipo := TComboBox.Create(Self);
  FCbTipo.Parent := FProps;
  FCbTipo.Style := csDropDownList;
  FCbTipo.OnChange := PropiedadCambio;
  FLblLong := NuevaEtiqueta(FProps, 'Longitud', False);
  FEdLong := TEdit.Create(Self);
  FEdLong.Parent := FProps;
  FEdLong.MaxLength := 4;
  FEdLong.OnChange := PropiedadCambio;
  FEdLong.OnKeyPress := LongitudKeyPress;
  FChkObl := TCheckBox.Create(Self);
  FChkObl.Parent := FProps;
  FChkObl.Caption := 'Obligatoria';
  FChkObl.OnClick := PropiedadCambio;
  FLblDesc := NuevaEtiqueta(FProps, 'Descripci' + #243 + 'n / ayuda (opcional)', False);
  FMemoDesc := TMemo.Create(Self);
  FMemoDesc.Parent := FProps;
  FMemoDesc.ScrollBars := ssVertical;
  FMemoDesc.OnChange := PropiedadCambio;
  FBtnQuitar := TButton.Create(Self);
  FBtnQuitar.Parent := FProps;
  FBtnQuitar.Caption := 'Quitar variable';
  FBtnQuitar.OnClick := QuitarClick;

  FTituloPrevia := NuevaEtiqueta(Self, 'As' + #237 + ' se ver' + #225 + ' el formulario', True);
  FPrevia := TScrollBox.Create(Self);
  FPrevia.Parent := Self;
  FPrevia.BorderStyle := bsNone;
  FPrevia.Color := FTema.Superficie2;
  FPrevia.VertScrollBar.Tracking := True;
end;

procedure TEditorVariables.Distribuir;
var
  W, H, X0, Y, AnchoLista, AnchoDer, Col, Alto: Integer;
begin
  if (Parent = nil) or (ClientWidth < 50) then
    Exit;
  W := ClientWidth;
  H := ClientHeight;
  AnchoLista := Esc(300);
  if AnchoLista > W div 2 then
    AnchoLista := W div 2;
  FCabLista.SetBounds(Esc(12), Esc(10), AnchoLista - Esc(150), Esc(20));
  FBtnNueva.SetBounds(AnchoLista - Esc(138), Esc(6), Esc(128), Esc(28));
  FLista.SetBounds(0, Esc(40), AnchoLista, H - Esc(40));

  X0 := AnchoLista + Esc(16);
  AnchoDer := W - X0 - Esc(12);
  Y := Esc(8);
  if FAviso.Visible then
  begin
    FAviso.SetBounds(X0, Y, AnchoDer, Esc(52));
    FAvisoTexto.SetBounds(Esc(10), Esc(6), AnchoDer - Esc(20), Esc(40));
    Inc(Y, Esc(60));
  end;
  FTituloProps.SetBounds(X0, Y, AnchoDer, Esc(20));
  Inc(Y, Esc(24));
  Alto := Esc(190);
  FProps.SetBounds(X0, Y, AnchoDer, Alto);
  Col := (AnchoDer - Esc(12)) div 2;
  FLblNombre.SetBounds(0, 0, Col, Esc(16));
  FEdNombre.SetBounds(0, Esc(17), Col, Esc(24));
  FLblEtiqueta.SetBounds(Col + Esc(12), 0, Col, Esc(16));
  FEdEtiqueta.SetBounds(Col + Esc(12), Esc(17), Col, Esc(24));
  FLblTipo.SetBounds(0, Esc(46), Col, Esc(16));
  FCbTipo.SetBounds(0, Esc(63), Col, Esc(24));
  FLblLong.SetBounds(Col + Esc(12), Esc(46), Esc(90), Esc(16));
  FEdLong.SetBounds(Col + Esc(12), Esc(63), Esc(90), Esc(24));
  FChkObl.SetBounds(Col + Esc(12) + Esc(106), Esc(65), Esc(110), Esc(20));
  FLblDesc.SetBounds(0, Esc(92), AnchoDer, Esc(16));
  FMemoDesc.SetBounds(0, Esc(109), AnchoDer - Esc(150), Esc(60));
  FBtnQuitar.SetBounds(AnchoDer - Esc(140), Esc(109), Esc(140), Esc(28));
  Inc(Y, Alto + Esc(6));
  FTituloPrevia.SetBounds(X0, Y, AnchoDer, Esc(20));
  Inc(Y, Esc(24));
  FPrevia.SetBounds(X0, Y, AnchoDer, H - Y - Esc(8));
  RefrescarPrevia;
end;

procedure TEditorVariables.Resize;
begin
  inherited;
  Distribuir;
end;

function TEditorVariables.TextoTipo(const C: TCampoMeta): string;
begin
  Result := TIPOS[Ord(C.Tipo)];
  if C.Tipo = tmTexto then
    Result := 'Caracteres ' + #183 + ' ' + IntToStr(C.Longitud)
  else
    Result := Result;
end;

procedure TEditorVariables.RefrescarAviso;
begin
  FAviso.Visible := FSesion.Modo = mvSoloAnadir;
  if FAviso.Visible then
    FAvisoTexto.Caption := 'Esta subserie ya tiene documentos guardados. Puede agregar variables ' +
      'nuevas, reordenar y cambiar etiquetas, descripciones y si son obligatorias; el nombre, ' +
      'el tipo y la longitud de las existentes no se pueden modificar ni quitar.';
end;

procedure TEditorVariables.RefrescarLista;
var
  N: Integer;
begin
  N := FSesion.Count;
  FLista.Items.BeginUpdate;
  try
    while FLista.Items.Count < N do
      FLista.Items.Add('');
    while FLista.Items.Count > N do
      FLista.Items.Delete(FLista.Items.Count - 1);
  finally
    FLista.Items.EndUpdate;
  end;
  if N = 1 then
    FCabLista.Caption := '1 variable'
  else
    FCabLista.Caption := IntToStr(N) + ' variables';
  if (FSel >= 0) and (FSel < N) then
    FLista.ItemIndex := FSel;
  FLista.Invalidate;
end;

procedure TEditorVariables.RefrescarPropiedades;
var
  C: TCampoMeta;
  Hay: Boolean;
begin
  FCargando := True;
  try
    Hay := (FSel >= 0) and (FSel < FSesion.Count);
    FEdNombre.Enabled := Hay;
    FEdEtiqueta.Enabled := Hay;
    FCbTipo.Enabled := Hay;
    FEdLong.Enabled := Hay;
    FChkObl.Enabled := Hay;
    FMemoDesc.Enabled := Hay;
    FBtnQuitar.Enabled := Hay and FSesion.PuedeQuitar(FSel);
    if not Hay then
    begin
      FEdNombre.Text := '';
      FEdEtiqueta.Text := '';
      FCbTipo.ItemIndex := -1;
      FEdLong.Text := '';
      FChkObl.Checked := False;
      FMemoDesc.Text := '';
      Exit;
    end;
    C := FSesion.Campo(FSel);
    FEdNombre.Text := C.Nombre;
    FEdEtiqueta.Text := C.Etiqueta;
    FCbTipo.ItemIndex := Ord(C.Tipo);
    FEdLong.Text := IntToStr(C.Longitud);
    FChkObl.Checked := C.Obligatorio;
    FMemoDesc.Text := C.Descripcion;
    FEdNombre.ReadOnly := not FSesion.PuedeEditarNombre(FSel);
    FCbTipo.Enabled := FSesion.PuedeEditarTipo(FSel);
    FEdLong.ReadOnly := (not FSesion.PuedeEditarTipo(FSel)) or (C.Tipo <> tmTexto);
    FEdLong.Enabled := C.Tipo = tmTexto;
  finally
    FCargando := False;
  end;
end;

procedure TEditorVariables.RefrescarPrevia;
var
  I, X, Y, AnchoCampo, AnchoFila, AltoFila, Col: Integer;
  C: TCampoMeta;
  Panel: TPanel;
  Rot: TLabel;
  Ctl: TControl;
  Eti: string;
begin
  if FPrevia = nil then
    Exit;
  FPrevia.DisableAlign;
  try
    for I := FCamposPrevia.Count - 1 downto 0 do
      FCamposPrevia[I].Free;
    FCamposPrevia.Clear;
    AnchoFila := FPrevia.ClientWidth - Esc(24);
    if AnchoFila < Esc(200) then
      AnchoFila := Esc(200);
    AnchoCampo := Esc(200);
    X := Esc(12);
    Y := Esc(12);
    AltoFila := 0;
    Col := 0;
    for I := 0 to FSesion.Count - 1 do
    begin
      C := FSesion.Campo(I);
      Eti := C.Etiqueta;
      if Eti = '' then
        Eti := C.Nombre;
      if C.Obligatorio then
        Eti := Eti + ' *';
      Panel := TPanel.Create(FPrevia);
      Panel.Parent := FPrevia;
      Panel.BevelOuter := bvNone;
      Panel.ParentBackground := False;
      if I = FSel then
        Panel.Color := FTema.AcentoSuave
      else
        Panel.Color := FTema.Superficie2;
      Panel.Tag := I;
      if ControlParaCampo(C.Tipo, C.Longitud) = cmMemo then
      begin
        if Col > 0 then
        begin
          X := Esc(12);
          Inc(Y, AltoFila + Esc(8));
          Col := 0;
        end;
        Panel.SetBounds(X, Y, AnchoFila, Esc(84));
      end
      else
      begin
        if (Col > 0) and (X + AnchoCampo > AnchoFila + Esc(12)) then
        begin
          X := Esc(12);
          Inc(Y, AltoFila + Esc(8));
          Col := 0;
          AltoFila := 0;
        end;
        Panel.SetBounds(X, Y, AnchoCampo, Esc(52));
      end;
      Rot := TLabel.Create(Panel);
      Rot.Parent := Panel;
      Rot.Caption := Eti;
      Rot.Font.Name := 'Segoe UI';
      Rot.Font.Size := 8;
      Rot.Font.Color := FTema.TextoSuave;
      Rot.SetBounds(Esc(6), Esc(3), Panel.Width - Esc(12), Esc(14));
      case ControlParaCampo(C.Tipo, C.Longitud) of
        cmMemo:
          begin
            Ctl := TMemo.Create(Panel);
            TMemo(Ctl).Parent := Panel;
            TMemo(Ctl).ReadOnly := True;
          end;
        cmSiNo:
          begin
            Ctl := TCheckBox.Create(Panel);
            TCheckBox(Ctl).Parent := Panel;
            TCheckBox(Ctl).Caption := 'S' + #237;
            TCheckBox(Ctl).Enabled := False;
          end;
      else
        begin
          Ctl := TEdit.Create(Panel);
          TEdit(Ctl).Parent := Panel;
          TEdit(Ctl).ReadOnly := True;
          if ControlParaCampo(C.Tipo, C.Longitud) = cmFecha then
            TEdit(Ctl).TextHint := 'dd/mm/aaaa';
        end;
      end;
      Ctl.SetBounds(Esc(6), Esc(20), Panel.Width - Esc(12), Panel.Height - Esc(26));
      if Ctl is TEdit then
        Ctl.Height := Esc(24);
      FCamposPrevia.Add(Panel);
      if ControlParaCampo(C.Tipo, C.Longitud) = cmMemo then
      begin
        Inc(Y, Panel.Height + Esc(8));
        X := Esc(12);
        Col := 0;
        AltoFila := 0;
      end
      else
      begin
        if Panel.Height > AltoFila then
          AltoFila := Panel.Height;
        Inc(X, AnchoCampo + Esc(8));
        Inc(Col);
      end;
    end;
  finally
    FPrevia.EnableAlign;
  end;
end;

procedure TEditorVariables.Cambio;
begin
  if Assigned(FOnCambio) then
    FOnCambio(Self);
end;

procedure TEditorVariables.Cargar(const ALista: TArray<TCampoMeta>; AModo: TModoVariables);
var
  I: Integer;
begin
  if FCbTipo.Items.Count = 0 then   // necesita la ventana: por eso aqui y no en Create
    for I := Low(TIPOS) to High(TIPOS) do
      FCbTipo.Items.Add(TIPOS[I]);
  FSesion.Cargar(ALista, AModo);
  if FSesion.Count > 0 then
    FSel := 0
  else
    FSel := -1;
  RefrescarAviso;
  Distribuir;
  RefrescarLista;
  RefrescarPropiedades;
  RefrescarPrevia;
end;

procedure TEditorVariables.Descartar;
begin
  FSesion.Descartar;
  if FSel >= FSesion.Count then
    FSel := FSesion.Count - 1;
  RefrescarLista;
  RefrescarPropiedades;
  RefrescarPrevia;
  Cambio;
end;

function TEditorVariables.Resultado: TArray<TCampoMeta>;
begin
  Result := FSesion.Resultado;
end;

function TEditorVariables.HayCambios: Boolean;
begin
  Result := FSesion.HayCambios;
end;

function TEditorVariables.Errores: TArray<TErrorCampo>;
begin
  Result := FSesion.Errores;
end;

procedure TEditorVariables.SeleccionarIndice(AIndice: Integer);
begin
  if (AIndice < 0) or (AIndice >= FSesion.Count) then
    Exit;
  FSel := AIndice;
  FLista.ItemIndex := AIndice;
  RefrescarPropiedades;
  RefrescarPrevia;
end;

procedure TEditorVariables.Arrastrar(ADe, AA: Integer);
begin
  FSesion.Mover(ADe, AA);
  FSel := AA;
  RefrescarLista;
  RefrescarPropiedades;
  RefrescarPrevia;
  Cambio;
end;

procedure TEditorVariables.AplicarPropiedades;
var
  C: TCampoMeta;
  L: Integer;
begin
  if FCargando or (FSel < 0) or (FSel >= FSesion.Count) then
    Exit;
  C := FSesion.Campo(FSel);
  C.Nombre := Trim(FEdNombre.Text);
  C.Etiqueta := Trim(FEdEtiqueta.Text);
  if FCbTipo.ItemIndex >= 0 then
    C.Tipo := TTipoMeta(FCbTipo.ItemIndex);
  if TryStrToInt(Trim(FEdLong.Text), L) then
    C.Longitud := L
  else
    C.Longitud := 0;
  if C.Tipo <> tmTexto then
    C.Longitud := 0;
  C.Obligatorio := FChkObl.Checked;
  C.Descripcion := Trim(FMemoDesc.Text);
  FSesion.Modificar(FSel, C);
end;

procedure TEditorVariables.PropiedadCambio(Sender: TObject);
var
  TipoAnterior: TTipoMeta;
begin
  if FCargando then
    Exit;
  TipoAnterior := FSesion.Campo(FSel).Tipo;
  AplicarPropiedades;
  if FSesion.Campo(FSel).Tipo <> TipoAnterior then
    RefrescarPropiedades;   // habilita o no la longitud
  FLista.Invalidate;
  RefrescarPrevia;
  Cambio;
end;

procedure TEditorVariables.NuevaClick(Sender: TObject);
begin
  FSel := FSesion.Agregar;
  RefrescarLista;
  RefrescarPropiedades;
  RefrescarPrevia;
  Cambio;
  if FEdNombre.CanFocus then
    FEdNombre.SetFocus;
end;

procedure TEditorVariables.QuitarClick(Sender: TObject);
begin
  if (FSel < 0) or (not FSesion.Quitar(FSel)) then
    Exit;
  if FSel >= FSesion.Count then
    FSel := FSesion.Count - 1;
  RefrescarLista;
  RefrescarPropiedades;
  RefrescarPrevia;
  Cambio;
end;

procedure TEditorVariables.LongitudKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8]) then
    Key := #0;
end;

procedure TEditorVariables.ListaClick(Sender: TObject);
begin
  if not FArrastrando then
    SeleccionarIndice(FLista.ItemIndex);
end;

procedure TEditorVariables.ListaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FDesde := FLista.ItemAtPos(Point(X, Y), True);
  FIni := Point(X, Y);
  FArrastrando := False;
  FDestino := -1;
end;

procedure TEditorVariables.ListaMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  D: Integer;
begin
  if (not (ssLeft in Shift)) or (FDesde < 0) then
    Exit;
  if (not FArrastrando) and (Abs(Y - FIni.Y) > Esc(6)) then
  begin
    FArrastrando := True;
    FLista.Cursor := crSizeNS;
  end;
  if FArrastrando then
  begin
    D := FLista.ItemAtPos(Point(X, Y), False);
    if D >= FSesion.Count then
      D := FSesion.Count - 1;
    if D <> FDestino then
    begin
      FDestino := D;
      FLista.Invalidate;
    end;
  end;
end;

procedure TEditorVariables.ListaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  De, A: Integer;
begin
  De := FDesde;
  A := FDestino;
  FLista.Cursor := crDefault;
  if FArrastrando and (De >= 0) and (A >= 0) and (A <> De) then
  begin
    FArrastrando := False;
    FDesde := -1;
    FDestino := -1;
    Arrastrar(De, A);
    Exit;
  end;
  FArrastrando := False;
  FDesde := -1;
  FDestino := -1;
  FLista.Invalidate;
end;

procedure TEditorVariables.ListaDibujar(Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  C: TCampoMeta;
  Cv: TCanvas;
  Sel: Boolean;
  Circulo: TRect;
  Sub, Chip: string;
  Ancho: Integer;
begin
  if (Index < 0) or (Index >= FSesion.Count) then
    Exit;
  C := FSesion.Campo(Index);
  Cv := FLista.Canvas;
  Sel := Index = FSel;
  if Sel then
    Cv.Brush.Color := FTema.AcentoSuave
  else
    Cv.Brush.Color := FTema.Superficie;
  Cv.FillRect(Rect);
  if Sel then
  begin
    Cv.Brush.Color := FTema.Acento;
    Cv.FillRect(System.Types.Rect(Rect.Left, Rect.Top, Rect.Left + Esc(3), Rect.Bottom));
  end;
  Cv.Pen.Color := FTema.Linea;
  Cv.MoveTo(Rect.Left, Rect.Bottom - 1);
  Cv.LineTo(Rect.Right, Rect.Bottom - 1);
  // indicador de destino al arrastrar
  if FArrastrando and (Index = FDestino) then
  begin
    Cv.Pen.Color := FTema.Acento;
    Cv.Pen.Width := 2;
    if FDestino > FDesde then
    begin
      Cv.MoveTo(Rect.Left, Rect.Bottom - 2);
      Cv.LineTo(Rect.Right, Rect.Bottom - 2);
    end
    else
    begin
      Cv.MoveTo(Rect.Left, Rect.Top + 1);
      Cv.LineTo(Rect.Right, Rect.Top + 1);
    end;
    Cv.Pen.Width := 1;
  end;
  // asa para arrastrar
  Cv.Font.Name := 'Segoe UI';
  Cv.Font.Size := 11;
  Cv.Font.Style := [];
  Cv.Font.Color := FTema.TextoSuave;
  Cv.Brush.Style := bsClear;
  Cv.TextOut(Rect.Left + Esc(8), Rect.Top + Esc(12), #8942);
  // numero
  Circulo := System.Types.Rect(Rect.Left + Esc(30), Rect.Top + Esc(13), Rect.Left + Esc(52), Rect.Top + Esc(35));
  Cv.Brush.Style := bsSolid;
  Cv.Brush.Color := FTema.Superficie2;
  Cv.Pen.Color := FTema.Linea;
  Cv.Ellipse(Circulo);
  Cv.Brush.Style := bsClear;
  Cv.Font.Size := 8;
  Cv.TextOut(Circulo.Left + (Circulo.Width - Cv.TextWidth(IntToStr(Index + 1))) div 2,
    Circulo.Top + (Circulo.Height - Cv.TextHeight('0')) div 2, IntToStr(Index + 1));
  // nombre y tipo
  Cv.Font.Size := 9;
  Cv.Font.Style := [fsBold];
  Cv.Font.Color := FTema.Texto;
  Cv.TextOut(Rect.Left + Esc(62), Rect.Top + Esc(6), C.Nombre);
  Cv.Font.Style := [];
  Cv.Font.Size := 8;
  Cv.Font.Color := FTema.TextoSuave;
  Sub := TextoTipo(C);
  if not FSesion.PuedeEditarNombre(Index) then
    Sub := Sub + ' ' + #183 + ' fija';
  Cv.TextOut(Rect.Left + Esc(62), Rect.Top + Esc(26), Sub);
  if C.Obligatorio then
  begin
    Chip := 'Obligatoria';
    Cv.Font.Style := [fsBold];
    Cv.Font.Color := FTema.Acento;
    Ancho := Cv.TextWidth(Chip);
    Cv.TextOut(Rect.Right - Ancho - Esc(10), Rect.Top + Esc(15), Chip);
  end;
  Cv.Brush.Style := bsSolid;
end;

function TEditorVariables.CantidadItems: Integer;
begin
  Result := FLista.Items.Count;
end;

function TEditorVariables.CantidadPrevia: Integer;
begin
  Result := FCamposPrevia.Count;
end;

function TEditorVariables.EtiquetaPrevia(AIndice: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FCamposPrevia[AIndice].ControlCount - 1 do
    if FCamposPrevia[AIndice].Controls[I] is TLabel then
      Exit(TLabel(FCamposPrevia[AIndice].Controls[I]).Caption);
end;

function TEditorVariables.PreviaResaltada: Integer;
var
  I: Integer;
begin
  for I := 0 to FCamposPrevia.Count - 1 do
    if FCamposPrevia[I].Color = FTema.AcentoSuave then
      Exit(I);
  Result := -1;
end;

function TEditorVariables.NombreSoloLectura: Boolean;
begin
  Result := FEdNombre.ReadOnly;
end;

function TEditorVariables.TipoDeshabilitado: Boolean;
begin
  Result := not FCbTipo.Enabled;
end;

function TEditorVariables.AvisoVisible: Boolean;
begin
  Result := FAviso.Visible;
end;

procedure TEditorVariables.EscribirEtiqueta(const ATexto: string);
begin
  FEdEtiqueta.Text := ATexto;
end;

procedure TEditorVariables.EscribirNombre(const ATexto: string);
begin
  FEdNombre.Text := ATexto;
end;

end.
