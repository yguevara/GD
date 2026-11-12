unit UCLSeriesForm;

{ ---------------------------------------------------------------------------
  Clasificador "Series y subseries" (pantalla nueva, embebida en la ventana
  principal; sin .dfm). Descendiente de TFormClasificadorBase:

    - indice a la izquierda con las series (y alta/edicion de la serie elegida);
    - tabla con las subseries de la serie elegida (o de todas);
    - panel lateral con la ficha de la subserie (pestanas Datos y Ubicacion);
    - el boton "Editar variables..." sustituye la tabla por el editor de las
      variables del formulario (TEditorVariables), con "Volver a subseries".

  Datos y reglas: USeriesDatos, UVariablesDatos (sin VCL, con pruebas). Esta
  pantalla solo los muestra. Codigo en ASCII.
  --------------------------------------------------------------------------- }

interface

uses
  FireDAC.Comp.Client, UClasificadorBase;

{ Crea la pantalla sin mostrarla: quien la llama la embebe con Embeber. }
function CrearClasificadorSeries(Conn: TFDConnection): TFormClasificadorBase;

implementation

uses
  System.SysUtils, System.Classes, System.Variants, System.StrUtils,
  System.Generics.Collections, System.Types, System.Math, Winapi.Windows, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, Vcl.ComCtrls, UTema, UShellPrincipal, UClasificadorEstado,
  UErroresCampo, UMensajes, USeriesDatos, UVariablesDatos, UVariablesEditor,
  UMetadatosSubserie;

type
  { Una fila de la ficha: etiqueta, control y espacio para el mensaje de error. }
  TFila = record
    Hoja: TTabSheet;
    Lbl: TLabel;
    Ctl: TControl;
    Err: TLabel;
    Mitad: Integer;     // 0 = ancho completo, 1 = mitad izquierda, 2 = mitad derecha
    Alto: Integer;
    Clave: string;      // campo para los errores de validacion
  end;

  TfrmSeries = class(TFormClasificadorBase)
  private
    FConn: TFDConnection;
    FEsSql: Boolean;
    FSeries: TArray<TSerieResumen>;
    FSubs: TArray<TSubserieResumen>;
    FSerieSel: string;           // '' = todas
    FActual: TSubserie;
    FEsNueva: Boolean;
    FCargando: Boolean;
    FObsCambiada: Boolean;
    FFilas: TList<TFila>;
    // indice de series
    FCabIndice: TLabel;
    FBtnSerieNueva, FBtnSerieEditar: TButton;
    FListaSeries: TListBox;
    FPanelSerie: TPanel;
    FEdSerieCod, FEdSerieNom: TEdit;
    FErrSerie: TLabel;
    FBtnSerieGuardar, FBtnSerieEliminar, FBtnSerieCancelar: TButton;
    FSerieEsNueva: Boolean;
    // ficha
    FPaginas: TPageControl;
    FHojaDatos, FHojaUbic: TTabSheet;
    FEdCodSubs, FEdNombre, FEdGestion, FEdCentral, FEdDeposito, FEdGaveta, FEdCarpeta: TEdit;
    FCmbSerie, FCmbTipoSerie, FCmbTipoDoc, FCmbSoporte, FCmbAcceso, FCmbDestino,
      FCmbFrecuencia, FCmbArchivo: TComboBox;
    FChkActiva: TCheckBox;
    FFecha: TDateTimePicker;
    FObs: TRichEdit;
    FResultado: TLabel;
    FFilaVars: TPanel;
    FLblVars: TLabel;
    FBtnVars: TButton;
    // editor de variables
    FVarVista: TPanel;
    FVarTitulo: TLabel;
    FVarEditor: TEditorVariables;
    FBtnVarVolver, FBtnVarGuardar, FBtnVarDescartar: TButton;
    FVarCodSubs, FVarCodSerie: string;
    function NuevaEtiqueta(AParent: TWinControl; const ATexto: string; ASuave: Boolean): TLabel;
    function NuevoEdit(AMax: Integer): TEdit;
    function NuevoCombo: TComboBox;
    function NuevoBotonSimple(AParent: TWinControl; const ATexto: string; AClick: TNotifyEvent): TButton;
    function AgregarFilaFicha(AHoja: TTabSheet; const ATitulo, AClave: string; ACtl: TControl;
      AMitad, AAlto: Integer): Integer;
    procedure ConstruirIndiceSeries;
    procedure CargarCombosSerie;
    procedure ConstruirFicha;
    procedure ConstruirVariables;
    procedure LlenarCombo(ACmb: TComboBox; const AOps: TArray<TOpcionSerie>);
    procedure CargarListas;
    procedure Distribuir;
    procedure PaginasResize(Sender: TObject);
    procedure RecargarSeries;
    procedure RecargarSubseries(ASeleccionar: string);
    function IdDe(ACmb: TComboBox): Integer;
    procedure PonerId(ACmb: TComboBox; AId: Integer);
    procedure MostrarFicha(const S: TSubserie; AEsNueva: Boolean);
    function LeerFicha: TSubserie;
    procedure CargarObservacion(const ATexto: string);
    function TextoObservacion: string;
    procedure LimpiarErrores;
    procedure MostrarErrores(const AErrores: TArray<TErrorCampo>);
    procedure Resultado(const ATexto: string; AOk: Boolean);
    procedure ActualizarBotones;
    procedure ActualizarFilaVars;
    procedure CampoCambio(Sender: TObject);
    procedure ObsCambio(Sender: TObject);
    procedure NumeroKeyPress(Sender: TObject; var Key: Char);
    procedure ListaSeriesDibujar(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListaSeriesClick(Sender: TObject);
    procedure SerieNuevaClick(Sender: TObject);
    procedure SerieEditarClick(Sender: TObject);
    procedure SerieGuardarClick(Sender: TObject);
    procedure SerieEliminarClick(Sender: TObject);
    procedure SerieCancelarClick(Sender: TObject);
    procedure AbrirPanelSerie(AEsNueva: Boolean);
    procedure CerrarPanelSerie;
    procedure VariablesClick(Sender: TObject);
    procedure VariablesVolverClick(Sender: TObject);
    procedure VariablesGuardarClick(Sender: TObject);
    procedure VariablesDescartarClick(Sender: TObject);
    procedure VariablesCambio(Sender: TObject);
    procedure CargarEditorVariables;
    function CodSerieElegida: string;
  protected
    procedure AlNuevo; override;
    procedure AlElegirFila(ATag: Integer); override;
    procedure AlGuardar; override;
    procedure AlEliminar; override;
    function ConfirmarAbandonar: Boolean; override;
  public
    constructor CrearSeries(AOwner: TComponent; AConn: TFDConnection);
    destructor Destroy; override;
  end;

function CrearClasificadorSeries(Conn: TFDConnection): TFormClasificadorBase;
begin
  Result := TfrmSeries.CrearSeries(nil, Conn);
end;

const
  TXT_SIN_DEFINIR = '(sin definir)';

{ TfrmSeries }

constructor TfrmSeries.CrearSeries(AOwner: TComponent; AConn: TFDConnection);
begin
  inherited Create(AOwner);
  Caption := 'Series y subseries';
  FConn := AConn;
  FEsSql := SameText(AConn.DriverName, 'MSSQL');
  FFilas := TList<TFila>.Create;
  ConstruirBase('Series y subseries', '', 'Nueva subserie');
  AgregarColumna('C'#243'digo', 90);
  AgregarColumna('Subserie', 280);
  AgregarColumna('Tipo de documento', 140);
  AgregarColumna('Soporte', 120);
  AgregarColumna('Formulario', 170);
  AgregarColumna('Estado', 80);
  ConstruirIndiceSeries;
  ConstruirFicha;
  ConstruirVariables;
  CargarListas;
  RecargarSeries;
  RecargarSubseries('');
  MostrarIndice(True);
  FijarBotones(False, False, False);
end;

destructor TfrmSeries.Destroy;
begin
  FreeAndNil(FFilas);
  inherited Destroy;
end;

function TfrmSeries.NuevaEtiqueta(AParent: TWinControl; const ATexto: string;
  ASuave: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.AutoSize := False;
  Result.Transparent := True;
  Result.StyleElements := [];
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := 8;
  if ASuave then
    Result.Font.Color := FTema.TextoSuave
  else
    Result.Font.Color := FTema.Texto;
  Result.SetBounds(0, 0, Esc(200), Esc(16));
  Result.Caption := ATexto;
end;

function TfrmSeries.NuevoEdit(AMax: Integer): TEdit;
begin
  Result := TEdit.Create(Self);
  Result.StyleElements := [];
  Result.AutoSize := False;
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := 10;
  Result.Color := clWhite;
  Result.Font.Color := FTema.Texto;
  Result.Height := Esc(28);
  Result.MaxLength := AMax;
  Result.OnChange := CampoCambio;
end;

function TfrmSeries.NuevoCombo: TComboBox;
begin
  Result := TComboBox.Create(Self);
  Result.Style := csDropDownList;
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := 10;
  Result.OnChange := CampoCambio;
end;

function TfrmSeries.NuevoBotonSimple(AParent: TWinControl; const ATexto: string;
  AClick: TNotifyEvent): TButton;
begin
  Result := TButton.Create(Self);
  Result.Parent := AParent;
  Result.Caption := ATexto;
  Result.OnClick := AClick;
end;

function TfrmSeries.AgregarFilaFicha(AHoja: TTabSheet; const ATitulo, AClave: string;
  ACtl: TControl; AMitad, AAlto: Integer): Integer;
var
  F: TFila;
begin
  F.Hoja := AHoja;
  F.Lbl := NuevaEtiqueta(AHoja, ATitulo, True);
  ACtl.Parent := AHoja;
  F.Ctl := ACtl;
  F.Err := NuevaEtiqueta(AHoja, '', False);
  if FTema.Fondo = TemaOscuro.Fondo then
    F.Err.Font.Color := RGB($FF, $8A, $80)
  else
    F.Err.Font.Color := RGB($B3, $26, $1E);
  F.Mitad := AMitad;
  F.Alto := AAlto;
  F.Clave := AClave;
  FFilas.Add(F);
  Result := FFilas.Count - 1;
end;

procedure TfrmSeries.LlenarCombo(ACmb: TComboBox; const AOps: TArray<TOpcionSerie>);
var
  O: TOpcionSerie;
begin
  ACmb.Items.Clear;
  ACmb.Items.AddObject(TXT_SIN_DEFINIR, TObject(NativeInt(0)));
  for O in AOps do
    ACmb.Items.AddObject(O.Texto, TObject(NativeInt(O.Id)));
  ACmb.ItemIndex := 0;
end;

function TfrmSeries.IdDe(ACmb: TComboBox): Integer;
begin
  if ACmb.ItemIndex < 0 then
    Result := 0
  else
    Result := Integer(NativeInt(ACmb.Items.Objects[ACmb.ItemIndex]));
end;

procedure TfrmSeries.PonerId(ACmb: TComboBox; AId: Integer);
var
  I: Integer;
begin
  ACmb.ItemIndex := 0;
  for I := 0 to ACmb.Items.Count - 1 do
    if Integer(NativeInt(ACmb.Items.Objects[I])) = AId then
      ACmb.ItemIndex := I;
end;

procedure TfrmSeries.CargarListas;
begin
  LlenarCombo(FCmbTipoSerie, ListarOpciones(FConn, csTipoSerie));
  LlenarCombo(FCmbTipoDoc, ListarOpciones(FConn, csTipoDoc));
  LlenarCombo(FCmbSoporte, ListarOpciones(FConn, csSoporte));
  LlenarCombo(FCmbAcceso, ListarOpciones(FConn, csAcceso));
  LlenarCombo(FCmbDestino, ListarOpciones(FConn, csDestino));
  LlenarCombo(FCmbFrecuencia, ListarOpciones(FConn, csFrecuencia));
  LlenarCombo(FCmbArchivo, ListarOpciones(FConn, csArchivo));
end;

{ ---- indice de series ---- }

procedure TfrmSeries.ConstruirIndiceSeries;
begin
  FCabIndice := NuevaEtiqueta(Indice, 'SERIES', True);
  FCabIndice.Font.Style := [fsBold];
  FBtnSerieNueva := NuevoBotonSimple(Indice, '+ Nueva', SerieNuevaClick);
  FBtnSerieEditar := NuevoBotonSimple(Indice, 'Editar', SerieEditarClick);

  FListaSeries := TListBox.Create(Self);
  FListaSeries.Parent := Indice;
  FListaSeries.Style := lbOwnerDrawFixed;
  FListaSeries.ItemHeight := Esc(48);
  FListaSeries.BorderStyle := bsNone;
  FListaSeries.StyleElements := [];
  FListaSeries.Color := FTema.Superficie2;
  FListaSeries.OnDrawItem := ListaSeriesDibujar;
  FListaSeries.OnClick := ListaSeriesClick;

  FPanelSerie := TPanel.Create(Self);
  FPanelSerie.Parent := Indice;
  FPanelSerie.Align := alBottom;
  FPanelSerie.Height := Esc(190);
  FPanelSerie.BevelOuter := bvNone;
  FPanelSerie.ParentBackground := False;
  FPanelSerie.StyleElements := [];
  FPanelSerie.Color := FTema.Superficie;
  FPanelSerie.Visible := False;
  NuevaEtiqueta(FPanelSerie, 'C'#243'digo de la serie', True).SetBounds(Esc(12), Esc(8), Esc(200), Esc(16));
  FEdSerieCod := NuevoEdit(50);
  FEdSerieCod.Parent := FPanelSerie;
  FEdSerieCod.OnChange := nil;
  FEdSerieCod.SetBounds(Esc(12), Esc(26), Esc(222), Esc(28));
  NuevaEtiqueta(FPanelSerie, 'Nombre de la serie', True).SetBounds(Esc(12), Esc(58), Esc(200), Esc(16));
  FEdSerieNom := NuevoEdit(225);
  FEdSerieNom.Parent := FPanelSerie;
  FEdSerieNom.OnChange := nil;
  FEdSerieNom.SetBounds(Esc(12), Esc(76), Esc(222), Esc(28));
  FErrSerie := NuevaEtiqueta(FPanelSerie, '', False);
  FErrSerie.WordWrap := True;
  if FTema.Fondo = TemaOscuro.Fondo then
    FErrSerie.Font.Color := RGB($FF, $8A, $80)
  else
    FErrSerie.Font.Color := RGB($B3, $26, $1E);
  FErrSerie.SetBounds(Esc(12), Esc(106), Esc(222), Esc(30));
  FBtnSerieGuardar := NuevoBotonSimple(FPanelSerie, 'Guardar', SerieGuardarClick);
  FBtnSerieGuardar.SetBounds(Esc(12), Esc(144), Esc(70), Esc(30));
  FBtnSerieCancelar := NuevoBotonSimple(FPanelSerie, 'Cancelar', SerieCancelarClick);
  FBtnSerieCancelar.SetBounds(Esc(88), Esc(144), Esc(70), Esc(30));
  FBtnSerieEliminar := NuevoBotonSimple(FPanelSerie, 'Eliminar', SerieEliminarClick);
  FBtnSerieEliminar.SetBounds(Esc(164), Esc(144), Esc(70), Esc(30));
  Indice.OnResize := PaginasResize;
end;

procedure TfrmSeries.ListaSeriesDibujar(Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
var
  Cv: TCanvas;
  Sel: Boolean;
  Nombre, Sub: string;
  Total, I: Integer;
begin
  Cv := FListaSeries.Canvas;
  Sel := Index = FListaSeries.ItemIndex;
  if Sel then
    Cv.Brush.Color := FTema.AcentoSuave
  else
    Cv.Brush.Color := FTema.Superficie2;
  Cv.FillRect(Rect);
  if Sel then
  begin
    Cv.Brush.Color := FTema.Acento;
    Cv.FillRect(System.Types.Rect(Rect.Left, Rect.Top, Rect.Left + Esc(3), Rect.Bottom));
  end;
  if Index = 0 then
  begin
    Total := 0;
    for I := 0 to High(FSeries) do
      Inc(Total, FSeries[I].NSubseries);
    Nombre := 'Todas las series';
    Sub := IntToStr(Total) + ' subseries';
  end
  else
  begin
    Nombre := FSeries[Index - 1].Serie;
    Sub := FSeries[Index - 1].CodSerie + '  ' + #183 + '  ' + IntToStr(FSeries[Index - 1].NSubseries) +
      IfThen(FSeries[Index - 1].NSubseries = 1, ' subserie', ' subseries');
  end;
  Cv.Brush.Style := bsClear;
  Cv.Font.Name := 'Segoe UI';
  Cv.Font.Size := 9;
  Cv.Font.Style := [fsBold];
  Cv.Font.Color := FTema.Texto;
  Cv.TextRect(System.Types.Rect(Rect.Left + Esc(14), Rect.Top + Esc(6), Rect.Right - Esc(6), Rect.Top + Esc(24)),
    Rect.Left + Esc(14), Rect.Top + Esc(6), Nombre);
  Cv.Font.Style := [];
  Cv.Font.Size := 8;
  Cv.Font.Color := FTema.TextoSuave;
  Cv.TextOut(Rect.Left + Esc(14), Rect.Top + Esc(26), Sub);
  Cv.Brush.Style := bsSolid;
end;

procedure TfrmSeries.ListaSeriesClick(Sender: TObject);
var
  Nueva: string;
begin
  if FListaSeries.ItemIndex < 0 then
    Exit;
  if FListaSeries.ItemIndex = 0 then
    Nueva := ''
  else
    Nueva := FSeries[FListaSeries.ItemIndex - 1].CodSerie;
  if Nueva = FSerieSel then
    Exit;
  if PanelAbierto then
  begin
    if not ConfirmarAbandonar then
    begin
      // vuelve a marcar la serie anterior
      RecargarSeries;
      Exit;
    end;
    CerrarPanel;
  end;
  CerrarPanelSerie;
  FSerieSel := Nueva;
  RecargarSubseries('');
end;

procedure TfrmSeries.AbrirPanelSerie(AEsNueva: Boolean);
var
  I: Integer;
begin
  FSerieEsNueva := AEsNueva;
  FErrSerie.Caption := '';
  if AEsNueva then
  begin
    FEdSerieCod.Text := '';
    FEdSerieNom.Text := '';
    FEdSerieCod.ReadOnly := False;
    FBtnSerieEliminar.Visible := False;
  end
  else
  begin
    for I := 0 to High(FSeries) do
      if FSeries[I].CodSerie = FSerieSel then
      begin
        FEdSerieCod.Text := FSeries[I].CodSerie;
        FEdSerieNom.Text := FSeries[I].Serie;
      end;
    FEdSerieCod.ReadOnly := True;
    FBtnSerieEliminar.Visible := True;
  end;
  FPanelSerie.Visible := True;
  FEdSerieNom.SetFocus;
end;

procedure TfrmSeries.CerrarPanelSerie;
begin
  FPanelSerie.Visible := False;
end;

procedure TfrmSeries.SerieNuevaClick(Sender: TObject);
begin
  AbrirPanelSerie(True);
end;

procedure TfrmSeries.SerieEditarClick(Sender: TObject);
begin
  if FSerieSel = '' then
  begin
    TMensajes.Informacion('Elija primero una serie en la lista.', 'Series y subseries');
    Exit;
  end;
  AbrirPanelSerie(False);
end;

procedure TfrmSeries.SerieCancelarClick(Sender: TObject);
begin
  CerrarPanelSerie;
end;

procedure TfrmSeries.SerieGuardarClick(Sender: TObject);
var
  S: TSerie;
  E: TArray<TErrorCampo>;
begin
  S.CodSerie := Trim(FEdSerieCod.Text);
  S.Serie := Trim(FEdSerieNom.Text);
  E := ValidarSerie(S);
  if Length(E) > 0 then
  begin
    FErrSerie.Caption := E[0].Mensaje;
    Exit;
  end;
  try
    GuardarSerie(FConn, S, FSerieEsNueva);
  except
    on E2: ESerieInvalida do
    begin
      FErrSerie.Caption := E2.Message;
      Exit;
    end;
    on E2: Exception do
    begin
      TMensajes.Error('No se pudo guardar la serie: ' + E2.Message, 'Series y subseries');
      Exit;
    end;
  end;
  CerrarPanelSerie;
  FSerieSel := S.CodSerie;
  RecargarSeries;
  RecargarSubseries('');
end;

procedure TfrmSeries.SerieEliminarClick(Sender: TObject);
begin
  if not TMensajes.Confirmar('Se eliminar'#225' la serie "' + FEdSerieNom.Text + '". '#191'Desea continuar?',
    'Eliminar serie') then
    Exit;
  try
    EliminarSerie(FConn, FEdSerieCod.Text);
  except
    on E: EEnUso do
    begin
      TMensajes.Advertencia(E.Message, 'Serie en uso');
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo eliminar la serie: ' + E.Message, 'Series y subseries');
      Exit;
    end;
  end;
  CerrarPanelSerie;
  FSerieSel := '';
  RecargarSeries;
  RecargarSubseries('');
end;

procedure TfrmSeries.CargarCombosSerie;
var
  I: Integer;
begin
  FCmbSerie.Items.Clear;
  for I := 0 to High(FSeries) do
    FCmbSerie.Items.Add(FSeries[I].CodSerie + ' - ' + FSeries[I].Serie);
end;

procedure TfrmSeries.RecargarSeries;
var
  I, Sel: Integer;
begin
  FSeries := ListarSeries(FConn);
  FListaSeries.Items.BeginUpdate;
  try
    FListaSeries.Items.Clear;
    FListaSeries.Items.Add('');
    for I := 0 to High(FSeries) do
      FListaSeries.Items.Add(FSeries[I].Serie);
  finally
    FListaSeries.Items.EndUpdate;
  end;
  Sel := 0;
  for I := 0 to High(FSeries) do
    if FSeries[I].CodSerie = FSerieSel then
      Sel := I + 1;
  FListaSeries.ItemIndex := Sel;
  FListaSeries.Invalidate;
  CargarCombosSerie;
end;

{ ---- ficha ---- }

procedure TfrmSeries.ConstruirFicha;
begin
  FPaginas := TPageControl.Create(Self);
  FPaginas.Parent := FCuerpo;
  FPaginas.Align := alClient;
  FPaginas.OnResize := PaginasResize;
  FHojaDatos := TTabSheet.Create(Self);
  FHojaDatos.PageControl := FPaginas;
  FHojaDatos.Caption := 'Datos';
  FHojaUbic := TTabSheet.Create(Self);
  FHojaUbic.PageControl := FPaginas;
  FHojaUbic.Caption := 'Ubicaci'#243'n y almacenamiento';

  FEdCodSubs := NuevoEdit(50);
  AgregarFilaFicha(FHojaDatos, 'C'#243'digo de la subserie', 'codsubs', FEdCodSubs, 1, Esc(28));
  FCmbSerie := NuevoCombo;
  AgregarFilaFicha(FHojaDatos, 'Serie', 'codserie', FCmbSerie, 2, Esc(28));
  FEdNombre := NuevoEdit(255);
  AgregarFilaFicha(FHojaDatos, 'Nombre de la subserie', 'subserie', FEdNombre, 0, Esc(28));
  FCmbTipoSerie := NuevoCombo;
  AgregarFilaFicha(FHojaDatos, 'Tipo de serie', 'tiposerie', FCmbTipoSerie, 1, Esc(28));
  FCmbTipoDoc := NuevoCombo;
  AgregarFilaFicha(FHojaDatos, 'Tipo de documento', 'tipodoc', FCmbTipoDoc, 2, Esc(28));
  FCmbSoporte := NuevoCombo;
  AgregarFilaFicha(FHojaDatos, 'Soporte', 'soporte', FCmbSoporte, 1, Esc(28));
  FCmbAcceso := NuevoCombo;
  AgregarFilaFicha(FHojaDatos, 'Acceso', 'acceso', FCmbAcceso, 2, Esc(28));
  FEdGestion := NuevoEdit(5);
  FEdGestion.OnKeyPress := NumeroKeyPress;
  AgregarFilaFicha(FHojaDatos, 'A'#241'os en archivo de gesti'#243'n', 'tgestion', FEdGestion, 1, Esc(28));
  FEdCentral := NuevoEdit(5);
  FEdCentral.OnKeyPress := NumeroKeyPress;
  AgregarFilaFicha(FHojaDatos, 'A'#241'os en archivo central', 'tcentral', FEdCentral, 2, Esc(28));
  FCmbDestino := NuevoCombo;
  AgregarFilaFicha(FHojaDatos, 'Destino final', 'destino', FCmbDestino, 1, Esc(28));
  FCmbFrecuencia := NuevoCombo;
  AgregarFilaFicha(FHojaDatos, 'Frecuencia de consulta', 'frecuencia', FCmbFrecuencia, 2, Esc(28));
  FFecha := TDateTimePicker.Create(Self);
  FFecha.Kind := dtkDate;
  FFecha.ShowCheckbox := True;
  FFecha.Checked := False;
  FFecha.Font.Name := 'Segoe UI';
  FFecha.Font.Size := 10;
  FFecha.OnChange := CampoCambio;
  AgregarFilaFicha(FHojaDatos, 'Fecha de aprobaci'#243'n', 'fecha', FFecha, 1, Esc(28));
  FChkActiva := TCheckBox.Create(Self);
  FChkActiva.Caption := 'Subserie activa';
  FChkActiva.OnClick := CampoCambio;
  AgregarFilaFicha(FHojaDatos, ' ', 'activa', FChkActiva, 2, Esc(28));
  FObs := TRichEdit.Create(Self);
  FObs.StyleElements := [];
  FObs.PlainText := False;
  FObs.ScrollBars := ssVertical;
  FObs.Font.Name := 'Segoe UI';
  FObs.Font.Size := 10;
  FObs.Color := clWhite;
  FObs.OnChange := ObsCambio;
  AgregarFilaFicha(FHojaDatos, 'Observaci'#243'n', 'observacion', FObs, 0, Esc(90));

  FCmbArchivo := NuevoCombo;
  AgregarFilaFicha(FHojaUbic, 'Archivo', 'archivo', FCmbArchivo, 0, Esc(28));
  FEdDeposito := NuevoEdit(255);
  AgregarFilaFicha(FHojaUbic, 'Dep'#243'sito', 'deposito', FEdDeposito, 1, Esc(28));
  FEdGaveta := NuevoEdit(20);
  AgregarFilaFicha(FHojaUbic, 'Gaveta', 'gaveta', FEdGaveta, 2, Esc(28));
  FEdCarpeta := NuevoEdit(255);
  AgregarFilaFicha(FHojaUbic, 'Carpeta', 'carpeta', FEdCarpeta, 0, Esc(28));

  FResultado := NuevaEtiqueta(FCuerpo, '', False);
  FResultado.Align := alBottom;
  FResultado.AutoSize := False;
  FResultado.WordWrap := True;
  FResultado.Height := Esc(32);

  // fila "Formulario": cuantas variables tiene y el boton para editarlas
  FFilaVars := TPanel.Create(Self);
  FFilaVars.Parent := FCuerpo.Parent;   // el panel lateral
  FFilaVars.Align := alTop;
  FFilaVars.Top := 10000;
  FFilaVars.Height := Esc(46);
  FFilaVars.BevelOuter := bvNone;
  FFilaVars.ParentBackground := False;
  FFilaVars.StyleElements := [];
  FFilaVars.Color := FTema.Superficie2;
  FLblVars := NuevaEtiqueta(FFilaVars, '', False);
  FLblVars.Font.Size := 9;
  FLblVars.SetBounds(Esc(18), Esc(14), Esc(240), Esc(18));
  FBtnVars := NuevoBotonSimple(FFilaVars, 'Editar variables...', VariablesClick);
  FBtnVars.SetBounds(Esc(268), Esc(8), Esc(140), Esc(30));
  FFilaVars.Visible := False;
end;

procedure TfrmSeries.PaginasResize(Sender: TObject);
begin
  Distribuir;
end;

procedure TfrmSeries.Distribuir;
var
  I, Y, W, Medio, Fin: Integer;
  F: TFila;
  Hoja: TTabSheet;
  H: Integer;
begin
  // indice: cabecera, botones y lista
  if (Indice <> nil) and (FListaSeries <> nil) then
  begin
    FCabIndice.SetBounds(Esc(14), Esc(14), Esc(70), Esc(18));
    FBtnSerieNueva.SetBounds(Indice.ClientWidth - Esc(150), Esc(8), Esc(68), Esc(28));
    FBtnSerieEditar.SetBounds(Indice.ClientWidth - Esc(76), Esc(8), Esc(66), Esc(28));
    FListaSeries.SetBounds(0, Esc(44), Indice.ClientWidth - 1,
      Indice.ClientHeight - Esc(44) - IfThen(FPanelSerie.Visible, FPanelSerie.Height, 0));
  end;
  if (FPaginas = nil) or (FFilas = nil) then
    Exit;
  for H := 0 to 1 do
  begin
    if H = 0 then
      Hoja := FHojaDatos
    else
      Hoja := FHojaUbic;
    W := Hoja.ClientWidth - Esc(12);
    if W < Esc(240) then
      W := Esc(240);
    Medio := (W - Esc(12)) div 2;
    Y := Esc(8);
    Fin := Y;
    for I := 0 to FFilas.Count - 1 do
    begin
      F := FFilas[I];
      if F.Hoja <> Hoja then
        Continue;
      case F.Mitad of
        0:
          begin
            F.Lbl.SetBounds(0, Y, W, Esc(16));
            F.Ctl.SetBounds(0, Y + Esc(18), W, F.Alto);
            F.Err.SetBounds(0, Y + Esc(18) + F.Alto + 1, W, Esc(14));
            Fin := Y + Esc(18) + F.Alto + Esc(20);
            Y := Fin;
          end;
        1:
          begin
            F.Lbl.SetBounds(0, Y, Medio, Esc(16));
            F.Ctl.SetBounds(0, Y + Esc(18), Medio, F.Alto);
            F.Err.SetBounds(0, Y + Esc(18) + F.Alto + 1, Medio, Esc(14));
            Fin := Y + Esc(18) + F.Alto + Esc(20);
          end;
      else
        begin
          F.Lbl.SetBounds(Medio + Esc(12), Y, Medio, Esc(16));
          F.Ctl.SetBounds(Medio + Esc(12), Y + Esc(18), Medio, F.Alto);
          F.Err.SetBounds(Medio + Esc(12), Y + Esc(18) + F.Alto + 1, Medio, Esc(14));
          Y := Fin;
        end;
      end;
    end;
  end;
end;

procedure TfrmSeries.NumeroKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8]) then
    Key := #0;
end;

procedure TfrmSeries.CargarObservacion(const ATexto: string);
var
  S: TBytesStream;
begin
  FObs.Lines.Clear;
  if ATexto = '' then
    Exit;
  if Copy(ATexto, 1, 5) = '{\rtf' then
  begin
    S := TBytesStream.Create(TEncoding.ANSI.GetBytes(ATexto));
    try
      FObs.Lines.LoadFromStream(S);
    finally
      S.Free;
    end;
  end
  else
    FObs.Text := ATexto;
end;

function TfrmSeries.TextoObservacion: string;
var
  S: TBytesStream;
begin
  if Trim(FObs.Text) = '' then
    Exit('');
  S := TBytesStream.Create;
  try
    FObs.Lines.SaveToStream(S);
    Result := TEncoding.ANSI.GetString(S.Bytes, 0, S.Size);
  finally
    S.Free;
  end;
end;

procedure TfrmSeries.MostrarFicha(const S: TSubserie; AEsNueva: Boolean);
var
  I: Integer;
begin
  FCargando := True;
  try
    FActual := S;
    FEsNueva := AEsNueva;
    FEdCodSubs.Text := S.CodSubs;
    FEdCodSubs.ReadOnly := not AEsNueva;
    FCmbSerie.ItemIndex := -1;
    for I := 0 to High(FSeries) do
      if FSeries[I].CodSerie = S.CodSerie then
        FCmbSerie.ItemIndex := I;
    FEdNombre.Text := S.Nombre;
    PonerId(FCmbTipoSerie, S.IdTipoSerie);
    PonerId(FCmbTipoDoc, S.TipoDoc);
    PonerId(FCmbSoporte, S.Soporte);
    PonerId(FCmbAcceso, S.Acceso);
    PonerId(FCmbDestino, S.Destino);
    PonerId(FCmbFrecuencia, S.Frecuencia);
    PonerId(FCmbArchivo, S.Archivo);
    FEdGestion.Text := IntToStr(S.Gestion);
    FEdCentral.Text := IntToStr(S.Central);
    FChkActiva.Checked := S.Activa;
    if S.FechaAprobacion = 0 then
      FFecha.Checked := False
    else
    begin
      FFecha.Date := S.FechaAprobacion;
      FFecha.Checked := True;
    end;
    FEdDeposito.Text := S.Deposito;
    FEdGaveta.Text := S.Gaveta;
    FEdCarpeta.Text := S.Carpeta;
    if AEsNueva then
      CargarObservacion('')
    else
      CargarObservacion(LeerObservacion(FConn, S.CodSubs));
    FObsCambiada := False;
    LimpiarErrores;
    Resultado('', True);
    FPaginas.ActivePage := FHojaDatos;
    Distribuir;
  finally
    FCargando := False;
  end;
  ActualizarFilaVars;
end;

function TfrmSeries.LeerFicha: TSubserie;
begin
  Result := FActual;
  Result.CodSubs := Trim(FEdCodSubs.Text);
  if FCmbSerie.ItemIndex >= 0 then
    Result.CodSerie := FSeries[FCmbSerie.ItemIndex].CodSerie;
  Result.Nombre := Trim(FEdNombre.Text);
  Result.IdTipoSerie := IdDe(FCmbTipoSerie);
  Result.TipoDoc := IdDe(FCmbTipoDoc);
  Result.Soporte := IdDe(FCmbSoporte);
  Result.Acceso := IdDe(FCmbAcceso);
  Result.Destino := IdDe(FCmbDestino);
  Result.Frecuencia := IdDe(FCmbFrecuencia);
  Result.Archivo := IdDe(FCmbArchivo);
  Result.Gestion := StrToIntDef(Trim(FEdGestion.Text), 0);
  Result.Central := StrToIntDef(Trim(FEdCentral.Text), 0);
  Result.Activa := FChkActiva.Checked;
  if FFecha.Checked then
    Result.FechaAprobacion := Trunc(FFecha.Date)
  else
    Result.FechaAprobacion := 0;
  Result.Deposito := Trim(FEdDeposito.Text);
  Result.Gaveta := Trim(FEdGaveta.Text);
  Result.Carpeta := Trim(FEdCarpeta.Text);
end;

procedure TfrmSeries.LimpiarErrores;
var
  I: Integer;
begin
  for I := 0 to FFilas.Count - 1 do
    FFilas[I].Err.Caption := '';
end;

procedure TfrmSeries.MostrarErrores(const AErrores: TArray<TErrorCampo>);
var
  I, J: Integer;
begin
  LimpiarErrores;
  for I := 0 to High(AErrores) do
    for J := 0 to FFilas.Count - 1 do
      if FFilas[J].Clave = AErrores[I].Campo then
        FFilas[J].Err.Caption := AErrores[I].Mensaje;
end;

procedure TfrmSeries.Resultado(const ATexto: string; AOk: Boolean);
begin
  FResultado.Caption := ATexto;
  if AOk then
    FResultado.Font.Color := RGB($2F, $7D, $4F)
  else if FTema.Fondo = TemaOscuro.Fondo then
    FResultado.Font.Color := RGB($FF, $8A, $80)
  else
    FResultado.Font.Color := RGB($B3, $26, $1E);
end;

procedure TfrmSeries.ActualizarBotones;
begin
  FijarBotones(FEstado.PuedeGuardar, True, not FEsNueva);
end;

procedure TfrmSeries.ActualizarFilaVars;
var
  I, N: Integer;
  Tiene: Boolean;
begin
  FFilaVars.Visible := PanelAbierto and not FEsNueva;
  if not FFilaVars.Visible then
    Exit;
  N := 0;
  Tiene := False;
  for I := 0 to High(FSubs) do
    if FSubs[I].CodSubs = FActual.CodSubs then
    begin
      N := FSubs[I].NVariables;
      Tiene := FSubs[I].TieneTabla;
    end;
  if N = 1 then
    FLblVars.Caption := 'Formulario: 1 variable'
  else
    FLblVars.Caption := 'Formulario: ' + IntToStr(N) + ' variables';
  if Tiene then
    FLblVars.Caption := FLblVars.Caption + ' (con documentos)';
end;

procedure TfrmSeries.CampoCambio(Sender: TObject);
begin
  if FCargando then
    Exit;
  FEstado.MarcarCambio;
  ActualizarBotones;
end;

procedure TfrmSeries.ObsCambio(Sender: TObject);
begin
  if FCargando then
    Exit;
  FObsCambiada := True;
  FEstado.MarcarCambio;
  ActualizarBotones;
end;

{ ---- lista de subseries ---- }

procedure TfrmSeries.RecargarSubseries(ASeleccionar: string);
var
  I, Total: Integer;
  S: TSubserieResumen;
  Form: string;
begin
  FSubs := ListarSubseries(FConn, FSerieSel);
  LimpiarFilas;
  for I := 0 to High(FSubs) do
  begin
    S := FSubs[I];
    if S.NVariables = 0 then
      Form := #8212
    else if S.NVariables = 1 then
      Form := '1 variable'
    else
      Form := IntToStr(S.NVariables) + ' variables';
    if S.TieneTabla and (S.NVariables > 0) then
      Form := Form + '  ' + #183 + '  con documentos';
    AgregarFila([S.CodSubs, S.Nombre, S.TipoDoc, S.Soporte, Form,
      IfThen(S.Activa, 'Activa', 'Inactiva')], I);
  end;
  RefrescarVista;
  Total := 0;
  for I := 0 to High(FSeries) do
    Inc(Total, FSeries[I].NSubseries);
  FijarSubtitulo(Format('%d series  %s  %d subseries', [Length(FSeries), #183, Total]));
  if ASeleccionar <> '' then
    for I := 0 to High(FSubs) do
      if FSubs[I].CodSubs = ASeleccionar then
        SeleccionarPorTag(I);
end;

function TfrmSeries.CodSerieElegida: string;
begin
  if FSerieSel <> '' then
    Result := FSerieSel
  else if Length(FSeries) > 0 then
    Result := FSeries[0].CodSerie
  else
    Result := '';
end;

procedure TfrmSeries.AlNuevo;
var
  S: TSubserie;
begin
  if Length(FSeries) = 0 then
  begin
    TMensajes.Informacion('Cree primero una serie con el bot'#243'n "+ Nueva" de la lista de series.',
      'Series y subseries');
    Exit;
  end;
  S := Default(TSubserie);
  S.CodSerie := CodSerieElegida;
  S.Activa := True;
  MostrarFicha(S, True);
  AbrirPanel('Nueva subserie', False);
  ActualizarFilaVars;
  ActualizarBotones;
  FEdCodSubs.SetFocus;
end;

procedure TfrmSeries.AlElegirFila(ATag: Integer);
var
  S: TSubserie;
begin
  if (ATag < 0) or (ATag > High(FSubs)) then
    Exit;
  S := LeerSubserie(FConn, FSubs[ATag].CodSubs);
  MostrarFicha(S, False);
  AbrirPanel(S.Nombre, True);
  ActualizarFilaVars;
  ActualizarBotones;
end;

procedure TfrmSeries.AlGuardar;
var
  S: TSubserie;
  Errores: TArray<TErrorCampo>;
  I: Integer;
begin
  S := LeerFicha;
  Errores := ValidarSubserie(S);
  if Length(Errores) > 0 then
  begin
    MostrarErrores(Errores);
    Resultado('Revise los campos marcados.', False);
    Exit;
  end;
  try
    FConn.StartTransaction;
    try
      GuardarSubserie(FConn, S, FEsNueva);
      if FObsCambiada then
        GuardarObservacion(FConn, S.CodSubs, TextoObservacion);
      FConn.Commit;
    except
      if FConn.InTransaction then
        FConn.Rollback;
      raise;
    end;
  except
    on E: ESerieInvalida do
    begin
      FEdCodSubs.SetFocus;
      Resultado(E.Message, False);
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo guardar la subserie: ' + E.Message, 'Series y subseries');
      Exit;
    end;
  end;
  FEstado.Guardado;
  RecargarSeries;
  RecargarSubseries(S.CodSubs);
  for I := 0 to High(FSubs) do
    if FSubs[I].CodSubs = S.CodSubs then
      AlElegirFila(I);
  Resultado('Guardado correctamente.', True);
end;

procedure TfrmSeries.AlEliminar;
begin
  if FEsNueva or (FActual.CodSubs = '') then
    Exit;
  if not TMensajes.Confirmar('Se eliminar'#225' la subserie "' + FActual.Nombre +
    '". '#191'Desea continuar?', 'Eliminar subserie') then
    Exit;
  try
    EliminarSubserie(FConn, FActual.CodSubs);
  except
    on E: EEnUso do
    begin
      TMensajes.Advertencia(E.Message, 'Subserie en uso');
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo eliminar la subserie: ' + E.Message, 'Series y subseries');
      Exit;
    end;
  end;
  FEstado.Descartado;
  CerrarPanel;
  RecargarSeries;
  RecargarSubseries('');
end;

{ ---- editor de variables ---- }

procedure TfrmSeries.ConstruirVariables;
var
  Barra: TPanel;
begin
  FVarVista := TPanel.Create(Self);
  FVarVista.Parent := Self;
  FVarVista.BevelOuter := bvNone;
  FVarVista.ParentBackground := False;
  FVarVista.StyleElements := [];
  FVarVista.Color := FTema.Fondo;
  FVarVista.Visible := False;

  Barra := TPanel.Create(Self);
  Barra.Parent := FVarVista;
  Barra.Align := alTop;
  Barra.Height := Esc(54);
  Barra.BevelOuter := bvNone;
  Barra.ParentBackground := False;
  Barra.StyleElements := [];
  Barra.Color := FTema.Superficie;
  FBtnVarVolver := NuevoBotonSimple(Barra, #8592 + ' Volver a subseries', VariablesVolverClick);
  FBtnVarVolver.SetBounds(Esc(16), Esc(12), Esc(170), Esc(30));
  FVarTitulo := NuevaEtiqueta(Barra, '', False);
  FVarTitulo.Font.Name := 'Segoe UI Semibold';
  FVarTitulo.Font.Size := 11;
  FVarTitulo.SetBounds(Esc(204), Esc(16), Esc(520), Esc(24));
  FBtnVarDescartar := NuevoBotonSimple(Barra, 'Descartar', VariablesDescartarClick);
  FBtnVarDescartar.Align := alRight;
  FBtnVarDescartar.Width := Esc(120);
  FBtnVarDescartar.AlignWithMargins := True;
  FBtnVarDescartar.Margins.SetBounds(Esc(8), Esc(12), Esc(16), Esc(12));
  FBtnVarGuardar := NuevoBotonSimple(Barra, 'Guardar cambios', VariablesGuardarClick);
  FBtnVarGuardar.Align := alRight;
  FBtnVarGuardar.Width := Esc(150);
  FBtnVarGuardar.AlignWithMargins := True;
  FBtnVarGuardar.Margins.SetBounds(Esc(8), Esc(12), 0, Esc(12));

  FVarEditor := TEditorVariables.Create(Self, FTema, FEsSql);
  FVarEditor.Parent := FVarVista;
  FVarEditor.Align := alClient;
  FVarEditor.OnCambio := VariablesCambio;
end;

procedure TfrmSeries.CargarEditorVariables;
begin
  FVarEditor.Cargar(CargarCamposSubserie(FConn, FVarCodSubs),
    ModoVariables(FConn, FVarCodSerie, FVarCodSubs));
  VariablesCambio(nil);
end;

procedure TfrmSeries.VariablesCambio(Sender: TObject);
begin
  FBtnVarGuardar.Enabled := FVarEditor.HayCambios;
  FBtnVarDescartar.Enabled := FVarEditor.HayCambios;
end;

procedure TfrmSeries.VariablesClick(Sender: TObject);
begin
  if FEsNueva or (FActual.CodSubs = '') then
    Exit;
  if FEstado.RequiereConfirmarAbandono then
  begin
    TMensajes.Informacion('Guarde o cancele primero los cambios de la ficha de la subserie.',
      'Series y subseries');
    Exit;
  end;
  FVarCodSubs := FActual.CodSubs;
  FVarCodSerie := FActual.CodSerie;
  FVarTitulo.Caption := FActual.Nombre + '  ' + #183 + '  variables del formulario';
  MostrarVista(FVarVista);
  FVarVista.Update;
  CargarEditorVariables;
end;

procedure TfrmSeries.VariablesVolverClick(Sender: TObject);
begin
  if not ConfirmarAbandonar then
    Exit;
  VolverALista;
  RecargarSubseries(FVarCodSubs);
  ActualizarFilaVars;
end;

procedure TfrmSeries.VariablesDescartarClick(Sender: TObject);
begin
  if TMensajes.Confirmar('Se descartar'#225'n los cambios de las variables. '#191'Desea continuar?',
    'Descartar cambios') then
    FVarEditor.Descartar;
end;

procedure TfrmSeries.VariablesGuardarClick(Sender: TObject);
var
  Errores: TArray<TErrorCampo>;
  Nuevas, I, J: Integer;
  Lista, Antes: TArray<TCampoMeta>;
  Existe: Boolean;
begin
  Errores := FVarEditor.Errores;
  if Length(Errores) > 0 then
  begin
    TMensajes.Advertencia(Errores[0].Mensaje, 'Variables del formulario');
    Exit;
  end;
  Lista := FVarEditor.Resultado;
  if ModoVariables(FConn, FVarCodSerie, FVarCodSubs) = mvSoloAnadir then
  begin
    Antes := CargarCamposSubserie(FConn, FVarCodSubs);
    Nuevas := 0;
    for I := 0 to High(Lista) do
    begin
      Existe := False;
      for J := 0 to High(Antes) do
        if SameText(Antes[J].Nombre, Lista[I].Nombre) then
          Existe := True;
      if not Existe then
        Inc(Nuevas);
    end;
    if (Nuevas > 0) and not TMensajes.Confirmar('La subserie ya tiene documentos. Se agregar'#225' ' +
      IntToStr(Nuevas) + ' columna(s) nueva(s) a su tabla de datos; los documentos existentes ' +
      'quedar'#225'n vac'#237'os en esos campos. '#191'Desea continuar?', 'Agregar variables') then
      Exit;
  end;
  try
    GuardarVariables(FConn, FEsSql, FVarCodSerie, FVarCodSubs, Lista);
  except
    on E: Exception do
    begin
      TMensajes.Error(E.Message, 'Variables del formulario');
      Exit;
    end;
  end;
  CargarEditorVariables;
  TMensajes.Exito('Las variables se guardaron correctamente.', 'Variables del formulario');
end;

function TfrmSeries.ConfirmarAbandonar: Boolean;
begin
  if VistaAlternaActiva and FVarEditor.HayCambios then
    Result := TMensajes.Confirmar('Hay cambios sin guardar en las variables del formulario. ' +
      #191'Desea descartarlos?', 'Cambios sin guardar')
  else
    Result := inherited ConfirmarAbandonar;
end;

end.
