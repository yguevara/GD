unit UFormularioDocumento;

{ Formulario de edicion de uno o varios documentos. Se crea por codigo (sin
  .dfm) y no accede a datos: quien lo usa lo abre con las claves y los valores
  actuales, y al guardar lee Cambios (solo lo que el usuario cambio) y se lo
  entrega a UEdicionDocumento. Con un documento muestra sus valores y Cambios
  trae solo lo que difiere; con varios, los campos empiezan vacios ("sin
  cambios"), solo se cambia lo que se rellene y cada campo tiene un boton
  Vaciar para dejarlo vacio a proposito. Codigo, fecha y version no se editan
  (son la clave del documento). La ubicacion se deshabilita sin permiso de
  topografia. Los errores salen bajo su campo. Colores de UTema. Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Forms, UTema, UDocumentoVista,
  UEdicionDocumento, URecepcionArchivos;

type
  { Una opcion de una lista (por ejemplo un gestor): su id y su texto. }
  TOpcionLista = record
    Id: Integer;
    Texto: string;
  end;

  TTipoCampoForm = (tcTexto, tcMemo, tcNumero, tcVisible, tcGestor);

  TCampoForm = record
    Nombre: string;
    Etiqueta: string;
    Tipo: TTipoCampoForm;
    Ubicacion: Boolean;
    Control: TWinControl;
    Error: TLabel;
    Vaciar: TButton;
    Vaciado: Boolean;
    Rotulo: TLabel;
    { Texto del control justo despues de abrir: lo que se compara para saber si
      el usuario cambio el campo (un valor guardado que el control no reconoce
      no cuenta como cambio). }
    Inicial: string;
  end;

  TFormularioDocumento = class(TPanel)
  private
    FTema: TTemaColores;
    FOscuro: Boolean;
    FConstruido: Boolean;
    FTitulo: TLabel;
    FAviso: TLabel;
    FScroll: TScrollBox;
    FBarra: TPanel;
    FBtnGuardar, FBtnCancelar: TButton;
    FCampos: TArray<TCampoForm>;
    FClaves: TArray<TClaveDocumento>;
    FOriginal: TCambiosDoc;
    FGestores: TArray<TOpcionLista>;
    FOnGuardar: TNotifyEvent;
    FOnCancelar: TNotifyEvent;
    FOnVistaAvanzada: TNotifyEvent;
    FOnEliminar: TNotifyEvent;
    FOnSoltarArchivos: TSoltarEvent;
    FBtnAvanzada, FBtnEliminar: TButton;
    FZona: TPanel;
    FReceptor: TRecepcionArchivos;
    FMensaje: string;
    procedure EliminarClick(Sender: TObject);
    procedure ZonaSoltar(const Rutas: TArray<string>);
    procedure VistaAvanzadaClick(Sender: TObject);
    procedure OcultaCampo(const Nombre: string);
    procedure Construir;
    procedure AgregaCampo(const Nombre, Etiqueta: string; Tipo: TTipoCampoForm;
      Ubicacion: Boolean);
    procedure Distribuir;
    function Indice(const Nombre: string): Integer;
    function TextoDe(I: Integer): string;
    function OriginalDe(I: Integer): string;
    procedure PonTexto(I: Integer; const Texto: string);
    procedure LlenarGestores;
    procedure GuardarClick(Sender: TObject);
    procedure CancelarClick(Sender: TObject);
    procedure VaciarClick(Sender: TObject);
    function ErrorDeNumero(I: Integer): string;
    function CambiosDeCampo(I: Integer): TCambiosDoc;
    procedure LimpiarErrores;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    { Claves de los documentos a editar y, para un solo documento, sus valores
      actuales (con la bandera Tiene... de cada campo en True). }
    procedure Abrir(const Claves: TArray<TClaveDocumento>; const Actuales: TCambiosDoc;
      PuedeTopografia: Boolean);
    function EsLote: Boolean;
    { Solo lo que el usuario cambio. }
    function Cambios: TCambiosDoc;
    { Los valores con que se abrio (para detectar cambios ajenos al guardar). }
    function Anteriores: TCambiosDoc;
    function Claves: TArray<TClaveDocumento>;
    { Valida y, si todo esta bien, avisa con OnGuardar. }
    procedure Guardar;
    procedure Cancelar;
    procedure MostrarError(const Campo, Texto: string);
    procedure VaciarCampo(const Campo: string);
    { Gestores para el campo Gestor (si no se dan, se escribe el numero). }
    procedure FijarGestores(const Lista: TArray<TOpcionLista>);
    property OnGuardar: TNotifyEvent read FOnGuardar write FOnGuardar;
    property OnCancelar: TNotifyEvent read FOnCancelar write FOnCancelar;
    { Abre la rejilla antigua de documentos (para lo que este formulario no cubre). }
    property OnVistaAvanzada: TNotifyEvent read FOnVistaAvanzada write FOnVistaAvanzada;
    { Eliminar el documento (solo con uno abierto); quien usa el formulario confirma. }
    property OnEliminar: TNotifyEvent read FOnEliminar write FOnEliminar;
    procedure Eliminar;
    function EliminarVisible: Boolean;
    { Archivos o carpetas soltados sobre la zona del formulario: se agregan a
      todos los documentos que se editan. }
    property OnSoltarArchivos: TSoltarEvent read FOnSoltarArchivos write FOnSoltarArchivos;
    property Receptor: TRecepcionArchivos read FReceptor;
    { Mensaje general (por ejemplo el resultado de un guardado fallido). }
    procedure MostrarMensaje(const Texto: string);
    function MensajeActual: string;
    { Acceso para pruebas y diagnostico }
    function TextoCampo(const Campo: string): string;
    procedure EscribirCampo(const Campo, Texto: string);
    function PistaCampo(const Campo: string): string;
    function ErrorDe(const Campo: string): string;
    function CampoHabilitado(const Campo: string): Boolean;
    function NombresCampos: string;
    function TituloFormulario: string;
    function TextoBotonGuardar: string;
  end;

implementation

uses
  System.Math, System.StrUtils, UShellPrincipal;

const
  FUENTE = 'Segoe UI';
  ALTO_CAMPO = 62;
  SIN_CAMBIOS = '(sin cambios)';
  SIN_DEFINIR = '(sin definir)';

constructor TFormularioDocumento.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOscuro := TemaWindowsOscuro;
  if FOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
end;

procedure TFormularioDocumento.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not FConstruido then
  begin
    FConstruido := True;
    Construir;
  end;
end;

procedure TFormularioDocumento.AgregaCampo(const Nombre, Etiqueta: string;
  Tipo: TTipoCampoForm; Ubicacion: Boolean);
var
  C: TCampoForm;
  Rotulo: TLabel;
begin
  C := Default(TCampoForm);
  C.Nombre := Nombre;
  C.Etiqueta := Etiqueta;
  C.Tipo := Tipo;
  C.Ubicacion := Ubicacion;
  Rotulo := TLabel.Create(Self);
  Rotulo.Parent := FScroll;
  Rotulo.Transparent := True;
  Rotulo.StyleElements := [];
  Rotulo.Font.Name := FUENTE;
  Rotulo.Font.Size := 9;
  Rotulo.Font.Color := FTema.TextoSuave;
  Rotulo.Caption := Etiqueta;
  Rotulo.Tag := Length(FCampos);
  C.Rotulo := Rotulo;
  case Tipo of
    tcMemo:
      begin
        C.Control := TMemo.Create(Self);
        TMemo(C.Control).ScrollBars := ssVertical;
        TMemo(C.Control).WantReturns := True;
      end;
    tcVisible, tcGestor:
      begin
        C.Control := TComboBox.Create(Self);
        TComboBox(C.Control).Style := csDropDownList;
      end;
  else
    C.Control := TEdit.Create(Self);
  end;
  C.Control.Parent := FScroll;
  C.Control.Tag := Length(FCampos);
  C.Control.StyleElements := [];
  C.Error := TLabel.Create(Self);
  C.Error.Parent := FScroll;
  C.Error.Transparent := True;
  C.Error.StyleElements := [];
  C.Error.Font.Name := FUENTE;
  C.Error.Font.Size := 8;
  if FOscuro then
    C.Error.Font.Color := RGB($F0, $8A, $80)
  else
    C.Error.Font.Color := RGB($B4, $23, $18);
  C.Error.Caption := '';
  C.Vaciar := TButton.Create(Self);
  C.Vaciar.Parent := FScroll;
  C.Vaciar.Caption := 'Vaciar';
  C.Vaciar.Tag := Length(FCampos);
  C.Vaciar.OnClick := VaciarClick;
  C.Vaciar.Visible := False;
  C.Control.Hint := Etiqueta;
  Rotulo.FocusControl := C.Control;
  SetLength(FCampos, Length(FCampos) + 1);
  FCampos[High(FCampos)] := C;
end;

procedure TFormularioDocumento.Construir;
begin
  BevelOuter := bvNone;
  ParentBackground := False;
  StyleElements := [];
  ShowCaption := False;
  Color := FTema.Superficie;

  FTitulo := TLabel.Create(Self);
  FTitulo.Parent := Self;
  FTitulo.Align := alTop;
  FTitulo.AlignWithMargins := True;
  FTitulo.Margins.SetBounds(16, 14, 16, 4);
  FTitulo.StyleElements := [];
  FTitulo.Font.Name := FUENTE;
  FTitulo.Font.Size := 12;
  FTitulo.Font.Style := [fsBold];
  FTitulo.Font.Color := FTema.Texto;

  FAviso := TLabel.Create(Self);
  FAviso.Parent := Self;
  FAviso.Align := alTop;
  FAviso.AlignWithMargins := True;
  FAviso.Margins.SetBounds(16, 0, 16, 6);
  FAviso.WordWrap := True;
  FAviso.StyleElements := [];
  FAviso.Font.Name := FUENTE;
  FAviso.Font.Size := 9;
  FAviso.Font.Color := FTema.TextoSuave;

  FBarra := TPanel.Create(Self);
  FBarra.Parent := Self;
  FBarra.Align := alBottom;
  FBarra.Height := 46;
  FBarra.BevelOuter := bvNone;
  FBarra.ParentBackground := False;
  FBarra.StyleElements := [];
  FBarra.ShowCaption := False;
  FBarra.Color := FTema.Superficie2;

  FBtnGuardar := TButton.Create(Self);
  FBtnGuardar.Parent := FBarra;
  FBtnGuardar.Align := alRight;
  FBtnGuardar.Width := 130;
  FBtnGuardar.AlignWithMargins := True;
  FBtnGuardar.Margins.SetBounds(6, 8, 14, 8);
  FBtnGuardar.Default := True;
  FBtnGuardar.OnClick := GuardarClick;

  FBtnAvanzada := TButton.Create(Self);
  FBtnAvanzada.Parent := FBarra;
  FBtnAvanzada.Align := alLeft;
  FBtnAvanzada.Width := 110;
  FBtnAvanzada.AlignWithMargins := True;
  FBtnAvanzada.Margins.SetBounds(14, 8, 6, 8);
  FBtnAvanzada.Caption := 'Vista avanzada';
  FBtnAvanzada.OnClick := VistaAvanzadaClick;

  FBtnEliminar := TButton.Create(Self);
  FBtnEliminar.Parent := FBarra;
  FBtnEliminar.Align := alLeft;
  FBtnEliminar.Width := 90;
  FBtnEliminar.AlignWithMargins := True;
  FBtnEliminar.Margins.SetBounds(0, 8, 6, 8);
  FBtnEliminar.Caption := 'Eliminar...';
  FBtnEliminar.OnClick := EliminarClick;

  FBtnCancelar := TButton.Create(Self);
  FBtnCancelar.Parent := FBarra;
  FBtnCancelar.Align := alRight;
  FBtnCancelar.Width := 90;
  FBtnCancelar.AlignWithMargins := True;
  FBtnCancelar.Margins.SetBounds(6, 8, 0, 8);
  FBtnCancelar.Caption := 'Cancelar';
  FBtnCancelar.Cancel := True;
  FBtnCancelar.OnClick := CancelarClick;

  FZona := TPanel.Create(Self);
  FZona.Parent := Self;
  FZona.Align := alBottom;
  FZona.Height := 44;
  FZona.AlignWithMargins := True;
  FZona.Margins.SetBounds(16, 4, 16, 8);
  FZona.BevelOuter := bvNone;
  FZona.ParentBackground := False;
  FZona.StyleElements := [];
  FZona.Color := FTema.Superficie2;
  FZona.Font.Name := FUENTE;
  FZona.Font.Size := 9;
  FZona.Font.Color := FTema.TextoSuave;
  FZona.Caption := 'Arrastre aquí archivos para agregarlos como anexos digitales';
  FZona.Hint := 'Los archivos se agregan a todos los documentos que se editan';
  FZona.ShowHint := True;

  FScroll := TScrollBox.Create(Self);
  FScroll.Parent := Self;
  FScroll.Align := alClient;
  FScroll.BorderStyle := bsNone;
  FScroll.HorzScrollBar.Visible := False;
  FScroll.StyleElements := [];
  FScroll.Color := FTema.Superficie;
  FScroll.OnResize := nil;

  // Codigo, fecha y version (la clave) no figuran: no se editan
  AgregaCampo('titulo', 'Título', tcTexto, False);
  AgregaCampo('observaciones', 'Observaciones', tcMemo, False);
  AgregaCampo('gestor', 'Gestor', tcGestor, False);
  AgregaCampo('expediente', 'Expediente', tcTexto, False);
  AgregaCampo('subexp', 'Subexpediente', tcTexto, False);
  AgregaCampo('visible', 'Visible', tcVisible, False);
  AgregaCampo('archivo', 'Archivo (número)', tcNumero, True);
  AgregaCampo('deposito', 'Depósito', tcTexto, True);
  AgregaCampo('gaveta', 'Gaveta', tcTexto, True);
  AgregaCampo('servidor', 'Servidor (número)', tcNumero, True);
  AgregaCampo('posicion', 'Posición', tcTexto, True);
  OcultaCampo('gestor'); // hereda de la subserie; no hay lista de gestores que ofrecer
  Distribuir;
  FReceptor := TRecepcionArchivos.Crear(Self, FZona);
  FReceptor.Activo := True;
  FReceptor.OnSoltar := ZonaSoltar;
end;

procedure TFormularioDocumento.ZonaSoltar(const Rutas: TArray<string>);
begin
  if Assigned(FOnSoltarArchivos) then
    FOnSoltarArchivos(Rutas);
end;

procedure TFormularioDocumento.EliminarClick(Sender: TObject);
begin
  Eliminar;
end;

function TFormularioDocumento.EliminarVisible: Boolean;
begin
  Result := (FBtnEliminar <> nil) and FBtnEliminar.Visible;
end;

procedure TFormularioDocumento.Eliminar;
begin
  if (not EsLote) and (Length(FClaves) = 1) and Assigned(FOnEliminar) then
    FOnEliminar(Self);
end;

procedure TFormularioDocumento.OcultaCampo(const Nombre: string);
var
  I: Integer;
begin
  I := Indice(Nombre);
  if I < 0 then
    Exit;
  FCampos[I].Control.Visible := False;
  FCampos[I].Error.Visible := False;
  FCampos[I].Vaciar.Visible := False;
  if FCampos[I].Control.Tag >= 0 then
    FCampos[I].Rotulo.Visible := False;
end;

procedure TFormularioDocumento.VistaAvanzadaClick(Sender: TObject);
begin
  if Assigned(FOnVistaAvanzada) then
    FOnVistaAvanzada(Self);
end;

procedure TFormularioDocumento.MostrarMensaje(const Texto: string);
begin
  FMensaje := Texto;
  if Texto = '' then
    Exit;
  FAviso.Caption := Texto;
  if FOscuro then
    FAviso.Font.Color := RGB($F0, $8A, $80)
  else
    FAviso.Font.Color := RGB($B4, $23, $18);
end;

function TFormularioDocumento.MensajeActual: string;
begin
  Result := FMensaje;
end;

procedure TFormularioDocumento.Distribuir;
var
  I, Y, Ancho, AnchoVaciar: Integer;
  Alto: Integer;
begin
  if FScroll = nil then
    Exit;
  Ancho := Max(160, FScroll.ClientWidth - 32);
  Y := 4;
  for I := 0 to High(FCampos) do
  begin
    if not FCampos[I].Control.Visible then
      Continue;
    Alto := IfThen(FCampos[I].Tipo = tcMemo, 62, 24);
    AnchoVaciar := IfThen(FCampos[I].Vaciar.Visible, 64, 0);
    // el rotulo es el control anterior del mismo indice (se crea antes que el campo)
    FCampos[I].Control.SetBounds(16, Y + 18, Ancho - AnchoVaciar - IfThen(AnchoVaciar > 0, 6, 0), Alto);
    FCampos[I].Vaciar.SetBounds(16 + Ancho - AnchoVaciar, Y + 17, AnchoVaciar, 26);
    FCampos[I].Error.SetBounds(16, Y + 18 + Alto + 2, Ancho, 14);
    Inc(Y, 18 + Alto + 20);
  end;
  // rotulos: van justo sobre su campo
  for I := 0 to FScroll.ControlCount - 1 do
    if (FScroll.Controls[I] is TLabel) and (TLabel(FScroll.Controls[I]).FocusControl <> nil) then
      TLabel(FScroll.Controls[I]).SetBounds(16,
        TLabel(FScroll.Controls[I]).FocusControl.Top - 17, Ancho, 15);
end;

function TFormularioDocumento.Indice(const Nombre: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FCampos) do
    if SameText(FCampos[I].Nombre, Nombre) then
      Exit(I);
end;

function TFormularioDocumento.EsLote: Boolean;
begin
  Result := Length(FClaves) > 1;
end;

function TFormularioDocumento.Claves: TArray<TClaveDocumento>;
begin
  Result := Copy(FClaves);
end;

function TFormularioDocumento.Anteriores: TCambiosDoc;
begin
  if EsLote then
    Result := Default(TCambiosDoc)
  else
    Result := FOriginal;
end;

procedure TFormularioDocumento.FijarGestores(const Lista: TArray<TOpcionLista>);
begin
  FGestores := Copy(Lista);
  LlenarGestores;
end;

procedure TFormularioDocumento.LlenarGestores;
var
  I, G: Integer;
  Cmb: TComboBox;
begin
  G := Indice('gestor');
  if (G < 0) or not (FCampos[G].Control is TComboBox) then
    Exit;
  Cmb := TComboBox(FCampos[G].Control);
  Cmb.Items.Clear;
  Cmb.Items.Add(IfThen(EsLote, SIN_CAMBIOS, SIN_DEFINIR));
  for I := 0 to High(FGestores) do
    Cmb.Items.AddObject(FGestores[I].Texto, TObject(NativeInt(FGestores[I].Id)));
  Cmb.ItemIndex := 0;
end;

function TFormularioDocumento.OriginalDe(I: Integer): string;
begin
  Result := '';
  if EsLote then
    Exit;
  case I of
    0: Result := IfThen(FOriginal.TieneTitulo, FOriginal.Titulo, '');
    1: Result := IfThen(FOriginal.TieneObservaciones, FOriginal.Observaciones, '');
    2: if FOriginal.TieneGestor and (FOriginal.Gestor >= 0) then
         Result := IntToStr(FOriginal.Gestor);
    3: Result := IfThen(FOriginal.TieneIdExpediente, FOriginal.IdExpediente, '');
    4: Result := IfThen(FOriginal.TieneSubExp, FOriginal.SubExp, '');
    5: if FOriginal.TieneVisible then
         Result := FOriginal.Visible;
    6: if FOriginal.TieneArchivo and (FOriginal.Archivo >= 0) then
         Result := IntToStr(FOriginal.Archivo);
    7: Result := IfThen(FOriginal.TieneDeposito, FOriginal.Deposito, '');
    8: Result := IfThen(FOriginal.TieneGaveta, FOriginal.Gaveta, '');
    9: if FOriginal.TieneIdServidor and (FOriginal.IdServidor >= 0) then
         Result := IntToStr(FOriginal.IdServidor);
    10: Result := IfThen(FOriginal.TienePosicion, FOriginal.Posicion, '');
  end;
end;

{ Valor del campo como texto normalizado: el mismo formato que OriginalDe
  (gestor: id; visible: S, N o vacio; numeros: texto). }
function TFormularioDocumento.TextoDe(I: Integer): string;
var
  Cmb: TComboBox;
begin
  Result := '';
  case FCampos[I].Tipo of
    tcMemo: Result := TMemo(FCampos[I].Control).Text;
    tcVisible:
      begin
        Cmb := TComboBox(FCampos[I].Control);
        case Cmb.ItemIndex of
          1: Result := 'S';
          2: Result := 'N';
        end;
      end;
    tcGestor:
      if FCampos[I].Control is TComboBox then
      begin
        Cmb := TComboBox(FCampos[I].Control);
        if Cmb.ItemIndex > 0 then
          Result := IntToStr(NativeInt(Cmb.Items.Objects[Cmb.ItemIndex]));
      end;
  else
    Result := TEdit(FCampos[I].Control).Text;
  end;
  if FCampos[I].Tipo in [tcTexto, tcNumero] then
    Result := Trim(Result);
end;

procedure TFormularioDocumento.PonTexto(I: Integer; const Texto: string);
var
  Cmb: TComboBox;
  K: Integer;
begin
  case FCampos[I].Tipo of
    tcMemo: TMemo(FCampos[I].Control).Text := Texto;
    tcVisible:
      begin
        Cmb := TComboBox(FCampos[I].Control);
        if Texto = 'S' then
          Cmb.ItemIndex := 1
        else if Texto = 'N' then
          Cmb.ItemIndex := 2
        else
          Cmb.ItemIndex := 0;
      end;
    tcGestor:
      begin
        Cmb := TComboBox(FCampos[I].Control);
        Cmb.ItemIndex := 0;
        for K := 1 to Cmb.Items.Count - 1 do
          if IntToStr(NativeInt(Cmb.Items.Objects[K])) = Texto then
            Cmb.ItemIndex := K;
      end;
  else
    TEdit(FCampos[I].Control).Text := Texto;
  end;
end;

procedure TFormularioDocumento.Abrir(const Claves: TArray<TClaveDocumento>;
  const Actuales: TCambiosDoc; PuedeTopografia: Boolean);
var
  I: Integer;
  Cmb: TComboBox;
begin
  FClaves := Copy(Claves);
  FOriginal := Actuales;
  FMensaje := '';
  FBtnEliminar.Visible := Length(FClaves) = 1;
  LimpiarErrores;
  if EsLote then
  begin
    FTitulo.Caption := 'Editar ' + IntToStr(Length(FClaves)) + ' documentos';
    FAviso.Caption := 'Solo se cambian los campos que rellene; el resto queda como esta.';
    FBtnGuardar.Caption := 'Aplicar a ' + IntToStr(Length(FClaves));
  end
  else
  begin
    FTitulo.Caption := 'Editar documento ' + IfThen(Length(FClaves) = 1,
      Trim(FClaves[0].Codigodoc), '');
    FAviso.Caption := 'El código, la fecha y la version no se pueden cambiar.';
    FBtnGuardar.Caption := 'Guardar';
  end;
  if (Indice('gestor') >= 0) then
    LlenarGestores;
  for I := 0 to High(FCampos) do
  begin
    FCampos[I].Vaciado := False;
    FCampos[I].Control.Enabled := PuedeTopografia or not FCampos[I].Ubicacion;
    FCampos[I].Vaciar.Visible := EsLote and FCampos[I].Control.Enabled and
      FCampos[I].Control.Visible;
    case FCampos[I].Tipo of
      tcVisible:
        begin
          Cmb := TComboBox(FCampos[I].Control);
          Cmb.Items.Clear;
          Cmb.Items.Add(IfThen(EsLote, SIN_CAMBIOS, SIN_DEFINIR));
          Cmb.Items.Add('Si');
          Cmb.Items.Add('No');
        end;
      tcTexto, tcNumero:
        TEdit(FCampos[I].Control).TextHint := IfThen(EsLote, SIN_CAMBIOS, '');
    end;
    PonTexto(I, OriginalDe(I));
    FCampos[I].Inicial := TextoDe(I);
  end;
  if not PuedeTopografia then
    FAviso.Caption := FAviso.Caption + ' Sin permiso para cambiar la ubicación.';
  Distribuir;
end;

procedure TFormularioDocumento.LimpiarErrores;
var
  I: Integer;
begin
  for I := 0 to High(FCampos) do
    FCampos[I].Error.Caption := '';
end;

function TFormularioDocumento.ErrorDeNumero(I: Integer): string;
var
  T: string;
  N: Integer;
begin
  Result := '';
  if FCampos[I].Tipo <> tcNumero then
    Exit;
  T := TextoDe(I);
  if (T <> '') and not TryStrToInt(T, N) then
    Result := 'Escriba un número entero.'
  else if (T <> '') and (N < 0) then
    Result := 'El número no puede ser negativo.';
end;

{ Los cambios de un solo campo (para validarlo por separado). }
function TFormularioDocumento.CambiosDeCampo(I: Integer): TCambiosDoc;
var
  Cur, Orig: string;
  N: Integer;
begin
  Result := Default(TCambiosDoc);
  if not FCampos[I].Control.Visible then
    Exit;
  Cur := TextoDe(I);
  Orig := OriginalDe(I);
  if EsLote then
  begin
    if (Cur = '') and not FCampos[I].Vaciado then
      Exit;
  end
  else if Cur = FCampos[I].Inicial then
    Exit;
  case I of
    0: begin Result.TieneTitulo := True; Result.Titulo := Cur; end;
    1: begin Result.TieneObservaciones := True; Result.Observaciones := Cur; end;
    2: begin
         Result.TieneGestor := True;
         if Cur = '' then
           Result.Gestor := -1
         else
           Result.Gestor := StrToIntDef(Cur, -1);
       end;
    3: begin Result.TieneIdExpediente := True; Result.IdExpediente := Cur; end;
    4: begin Result.TieneSubExp := True; Result.SubExp := Cur; end;
    5: begin Result.TieneVisible := True; Result.Visible := Cur; end;
    6: begin
         Result.TieneArchivo := True;
         if TryStrToInt(Cur, N) then
           Result.Archivo := N
         else
           Result.Archivo := -1;
       end;
    7: begin Result.TieneDeposito := True; Result.Deposito := Cur; end;
    8: begin Result.TieneGaveta := True; Result.Gaveta := Cur; end;
    9: begin
         Result.TieneIdServidor := True;
         if TryStrToInt(Cur, N) then
           Result.IdServidor := N
         else
           Result.IdServidor := -1;
       end;
    10: begin Result.TienePosicion := True; Result.Posicion := Cur; end;
  end;
end;

function TFormularioDocumento.Cambios: TCambiosDoc;
var
  I: Integer;
  C: TCambiosDoc;
begin
  Result := Default(TCambiosDoc);
  for I := 0 to High(FCampos) do
  begin
    C := CambiosDeCampo(I);
    if C.TieneTitulo then begin Result.TieneTitulo := True; Result.Titulo := C.Titulo; end;
    if C.TieneObservaciones then begin Result.TieneObservaciones := True; Result.Observaciones := C.Observaciones; end;
    if C.TieneGestor then begin Result.TieneGestor := True; Result.Gestor := C.Gestor; end;
    if C.TieneIdExpediente then begin Result.TieneIdExpediente := True; Result.IdExpediente := C.IdExpediente; end;
    if C.TieneSubExp then begin Result.TieneSubExp := True; Result.SubExp := C.SubExp; end;
    if C.TieneVisible then begin Result.TieneVisible := True; Result.Visible := C.Visible; end;
    if C.TieneArchivo then begin Result.TieneArchivo := True; Result.Archivo := C.Archivo; end;
    if C.TieneDeposito then begin Result.TieneDeposito := True; Result.Deposito := C.Deposito; end;
    if C.TieneGaveta then begin Result.TieneGaveta := True; Result.Gaveta := C.Gaveta; end;
    if C.TieneIdServidor then begin Result.TieneIdServidor := True; Result.IdServidor := C.IdServidor; end;
    if C.TienePosicion then begin Result.TienePosicion := True; Result.Posicion := C.Posicion; end;
  end;
end;

procedure TFormularioDocumento.Guardar;
var
  I: Integer;
  Hay: Boolean;
  Err: string;
begin
  LimpiarErrores;
  Hay := False;
  for I := 0 to High(FCampos) do
  begin
    Err := ErrorDeNumero(I);
    if Err = '' then
      Err := ValidarCambios(CambiosDeCampo(I));
    if Err <> '' then
    begin
      FCampos[I].Error.Caption := Err;
      Hay := True;
    end;
  end;
  if Hay then
    Exit;
  if Assigned(FOnGuardar) then
    FOnGuardar(Self);
end;

procedure TFormularioDocumento.Cancelar;
begin
  if Assigned(FOnCancelar) then
    FOnCancelar(Self);
end;

procedure TFormularioDocumento.GuardarClick(Sender: TObject);
begin
  Guardar;
end;

procedure TFormularioDocumento.CancelarClick(Sender: TObject);
begin
  Cancelar;
end;

procedure TFormularioDocumento.MostrarError(const Campo, Texto: string);
var
  I: Integer;
begin
  I := Indice(Campo);
  if I >= 0 then
    FCampos[I].Error.Caption := Texto;
end;

procedure TFormularioDocumento.VaciarCampo(const Campo: string);
var
  I: Integer;
begin
  I := Indice(Campo);
  if (I < 0) or not EsLote then
    Exit;
  FCampos[I].Vaciado := not FCampos[I].Vaciado;
  PonTexto(I, '');
  FCampos[I].Control.Enabled := not FCampos[I].Vaciado;
  if FCampos[I].Vaciado then
    FCampos[I].Vaciar.Caption := 'Deshacer'
  else
    FCampos[I].Vaciar.Caption := 'Vaciar';
  if FCampos[I].Tipo in [tcTexto, tcNumero] then
    TEdit(FCampos[I].Control).TextHint := IfThen(FCampos[I].Vaciado, '(se vaciara)', SIN_CAMBIOS);
end;

procedure TFormularioDocumento.VaciarClick(Sender: TObject);
begin
  VaciarCampo(FCampos[TButton(Sender).Tag].Nombre);
end;

{ Acceso para pruebas y diagnostico }

function TFormularioDocumento.TextoCampo(const Campo: string): string;
var
  I: Integer;
begin
  I := Indice(Campo);
  if I < 0 then
    Exit('');
  if FCampos[I].Tipo = tcVisible then
    Result := TComboBox(FCampos[I].Control).Text
  else if FCampos[I].Tipo = tcGestor then
    Result := TextoDe(I)
  else
    Result := TextoDe(I);
end;

procedure TFormularioDocumento.EscribirCampo(const Campo, Texto: string);
var
  I: Integer;
begin
  I := Indice(Campo);
  if I >= 0 then
    PonTexto(I, Texto);
end;

function TFormularioDocumento.PistaCampo(const Campo: string): string;
var
  I: Integer;
begin
  I := Indice(Campo);
  Result := '';
  if I < 0 then
    Exit;
  if FCampos[I].Control is TEdit then
    Result := TEdit(FCampos[I].Control).TextHint
  else if EsLote then
    Result := SIN_CAMBIOS;
end;

function TFormularioDocumento.ErrorDe(const Campo: string): string;
var
  I: Integer;
begin
  I := Indice(Campo);
  if I < 0 then
    Result := ''
  else
    Result := FCampos[I].Error.Caption;
end;

function TFormularioDocumento.CampoHabilitado(const Campo: string): Boolean;
var
  I: Integer;
begin
  I := Indice(Campo);
  Result := (I >= 0) and FCampos[I].Control.Enabled;
end;

function TFormularioDocumento.NombresCampos: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(FCampos) do
    Result := Result + FCampos[I].Nombre + ' ' + FCampos[I].Etiqueta + ' ';
end;

function TFormularioDocumento.TituloFormulario: string;
begin
  Result := Trim(FTitulo.Caption);
end;

function TFormularioDocumento.TextoBotonGuardar: string;
begin
  Result := FBtnGuardar.Caption;
end;

end.
