unit UDepuracionForm;

{ ---------------------------------------------------------------------------
  Pantalla de Depuracion (eliminacion de documentos): maquetas C1 a C3 de
  docs/superpowers/maquetas/2026-11-12-procesos-maqueta.html.

  Todo el DISENO esta en UDepuracionForm.dfm (abrir en el IDE para ajustarlo).
  Este archivo solo llena datos y reacciona a los eventos.

  Dos vistas dentro del formulario:
    pnlLista    lista de depuraciones del ano (grdDepuraciones); "Nueva
                depuracion" y "Abrir".
    pnlDetalle  una depuracion: tira de pasos y, debajo, el panel del paso en que
                esta (propuesta, autorizacion, acta, ejecucion, cierre).

  Los datos y las reglas salen de UDepuracionDatos y UDepuracionReglas (sin VCL).
  Los metodos publicos Mostrar* presentan datos ya leidos: los usa el propio codigo
  despues de leer y las pruebas visuales sin base de datos.

  Colores: el .dfm lleva la paleta clara; AplicarTema los adapta al tema en uso.
  Se abre embebida en la ventana principal (IPantallaProceso). Solo el EGD del nodo
  actua (PuedeActuar); los demas ven y el boton explica por que.
  --------------------------------------------------------------------------- }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, dxSkinsCore, dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, cxContainer, cxCheckBox, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, cxSpinEdit, cxButtons, cxGridLevel,
  cxClasses, cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGrid,
  FireDAC.Comp.Client, UAlcance, UProceso, UTema, UProcesoPintura, UPantallaProceso,
  UOpcionNodo, UDepuracionDatos;

type
  { Pide imprimir el acta de una depuracion. }
  TImprimirDepuracion = reference to procedure(IdProceso: Integer);

  TfrmDepuracionNueva = class(TForm, IPantallaProceso)
    pnlLista: TPanel;
    pnlCabecera: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlCabeceraAcciones: TPanel;
    lblNodoTrab: TLabel;
    cboNodoTrabajo: TcxComboBox;
    btnAbrir: TcxButton;
    btnNueva: TcxButton;
    pnlCabeceraLinea: TPanel;
    pnlTabla: TPanel;
    grdDepuraciones: TcxGrid;
    tvDepuraciones: TcxGridTableView;
    colIdProceso: TcxGridColumn;
    colNumero: TcxGridColumn;
    colSeries: TcxGridColumn;
    colUnidades: TcxGridColumn;
    colFechas: TcxGridColumn;
    colAutorizacion: TcxGridColumn;
    colPaso: TcxGridColumn;
    colEstado: TcxGridColumn;
    lvDepuraciones: TcxGridLevel;
    pnlDetalle: TPanel;
    pnlDetCabecera: TPanel;
    btnVolver: TcxButton;
    lblDetTitulo: TLabel;
    lblDetSub: TLabel;
    pnlDetLinea: TPanel;
    pnlPasos: TPanel;
    pbPasos: TPaintBox;
    pnlAcciones: TPanel;
    pnlAccionesDer: TPanel;
    btnAvanzar: TcxButton;
    btnCancelarDep: TcxButton;
    btnEliminarDep: TcxButton;
    pnlAviso: TPanel;
    lblAviso: TLabel;
    pnlContenido: TPanel;
    pnlPaso1: TPanel;
    lblP1: TLabel;
    pnlPaso2: TPanel;
    lblP2: TLabel;
    pnlPaso3: TPanel;
    lblP3: TLabel;
    pnlPaso4: TPanel;
    lblP4: TLabel;
    pnlPaso5: TPanel;
    lblP5: TLabel;
    strEstilos: TcxStyleRepository;
    stContenido: TcxStyle;
    stContenidoPeq: TcxStyle;
    stCabeceraGrid: TcxStyle;
    stSeleccion: TcxStyle;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cboNodoTrabajoPropertiesChange(Sender: TObject);
    procedure tvCustomDrawColumnHeader(Sender: TcxGridTableView; ACanvas: TcxCanvas;
      AViewInfo: TcxGridColumnHeaderViewInfo; var ADone: Boolean);
    procedure tvDepuracionesFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure tvDepuracionesCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure btnAbrirClick(Sender: TObject);
    procedure btnNuevaClick(Sender: TObject);
    procedure btnVolverClick(Sender: TObject);
    procedure pbPasosPaint(Sender: TObject);
  private
    FConn: TFDConnection;
    FNodos: TArray<TClaveNodo>;
    FNodoActual: TClaveNodo;
    FOpciones: TArray<TOpcionNodo>;
    FAlcance: TAlcanceUsuario;
    FUsuario: string;
    FTema: TTemaColores;
    FAnio: Integer;
    FPuedeActuar: Boolean;
    FEmbebido: Boolean;
    FAlSalir: TNotifyEvent;
    FAlImprimirActa: TImprimirDepuracion;
    FFilas: TArray<TDepuracionFila>;
    FActual: TDepuracionFila;
    FIdSeleccionado: Integer;
    FNombresPasos: TArray<string>;
    FActualizando: Boolean;
    procedure SetPuedeActuar(Valor: Boolean);
    procedure SetAlImprimirActa(const Valor: TImprimirDepuracion);
    procedure AplicarTema;
    procedure ConfigurarBoton(B: TcxButton; Primario: Boolean);
    procedure Recargar;
    procedure AbrirDetalle(const Fila: TDepuracionFila);
    procedure RefrescarDetalle;
    procedure VolverALista;
    function FilaDeLista(IdProceso: Integer; out Fila: TDepuracionFila): Boolean;
    function IdDeLaFilaElegida: Integer;
    procedure PedirSalir;
    procedure AvisarSinPermiso;
  public
    constructor Create(AOwner: TComponent); override;
    { Conexion, nodos cuyas depuraciones se ven (el elegido y sus descendientes),
      nodo donde se crean las nuevas, alcance del usuario y usuario. Carga la lista. }
    procedure Iniciar(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
      const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario; const Usuario: string);
    { Nodos donde el usuario puede depurar (los arma la ventana principal) y el nodo
      que se prefiere elegir. Sin ninguno, la pantalla es de solo consulta. }
    procedure FijarNodosDeTrabajo(const Opciones: TArray<TOpcionNodo>;
      const Preferido: TClaveNodo);
    { Presentacion sin leer la base (la usan los metodos que leen y las pruebas
      visuales). }
    procedure MostrarLista(const Filas: TArray<TDepuracionFila>);
    procedure MostrarDetalle(const Fila: TDepuracionFila);
    { IPantallaProceso }
    procedure Embeber(Host: TWinControl);
    function PuedeSalir: Boolean;
    procedure FijarAlSalir(const Valor: TNotifyEvent);
    { Solo quien puede depurar en el nodo (el especialista de gestion documental)
      crea depuraciones y cambia su estado; los demas ven. Por defecto, si. }
    property PuedeActuar: Boolean read FPuedeActuar write SetPuedeActuar;
    property AlImprimirActa: TImprimirDepuracion read FAlImprimirActa
      write SetAlImprimirActa;
  end;

function CrearPantallaDepuracion(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario;
  const Usuario: string): TfrmDepuracionNueva;

implementation

{$R *.dfm}

uses
  System.DateUtils, System.Variants, Data.DB, UAparienciaLegacy, UMensajes,
  UProcesosDatos, UDepuracionReglas;

const
  // Colores base del .dfm (paleta clara); AplicarTema los cambia si el tema es otro.
  CLARO_FONDO = TColor(15528951);
  CLARO_SUP = TColor(16383487);
  CLARO_SUP2 = TColor(14806258);
  CLARO_LINEA = TColor(13031136);
  CLARO_TEXTO = TColor(1581355);
  CLARO_SUAVE = TColor(5924725);
  CLARO_ACENTO = TColor(803266);
  CLARO_ERROR = TColor(1975987);
  CLARO_OK = TColor(5209391);
  LIMITE_LISTA = 500;

function CrearPantallaDepuracion(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario;
  const Usuario: string): TfrmDepuracionNueva;
begin
  Result := TfrmDepuracionNueva.Create(nil);
  try
    Result.Iniciar(Conn, Nodos, NodoActual, Alcance, Usuario);
  except
    Result.Free;
    raise;
  end;
end;

constructor TfrmDepuracionNueva.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPuedeActuar := True;
  FAnio := YearOf(Date);
  FNombresPasos := ['Propuesta', 'Autorizaci' + #243 + 'n', 'Acta', 'Ejecuci' + #243 + 'n',
    'Cierre'];
  lblNodoTrab.Visible := False;
  cboNodoTrabajo.Visible := False;
  AplicarTema;
end;

procedure TfrmDepuracionNueva.Iniciar(Conn: TFDConnection;
  const Nodos: TArray<TClaveNodo>; const NodoActual: TClaveNodo;
  Alcance: TAlcanceUsuario; const Usuario: string);
begin
  FConn := Conn;
  FNodos := Nodos;
  FNodoActual := NodoActual;
  FAlcance := Alcance;
  FUsuario := Usuario;
  Recargar;
end;

procedure TfrmDepuracionNueva.SetPuedeActuar(Valor: Boolean);
begin
  FPuedeActuar := Valor;
  if pnlDetalle.Visible then
    MostrarDetalle(FActual);
end;

procedure TfrmDepuracionNueva.FijarNodosDeTrabajo(const Opciones: TArray<TOpcionNodo>;
  const Preferido: TClaveNodo);
var
  I, Sel: Integer;
begin
  FOpciones := Opciones;
  cboNodoTrabajo.Properties.Items.Clear;
  for I := 0 to High(Opciones) do
    cboNodoTrabajo.Properties.Items.Add(Opciones[I].Texto);
  Sel := ElegirNodo(Opciones, Preferido);
  cboNodoTrabajo.ItemIndex := Sel;
  if Sel >= 0 then
    FNodoActual := Opciones[Sel].Clave;
  lblNodoTrab.Visible := Sel >= 0;
  cboNodoTrabajo.Visible := Sel >= 0;
  PuedeActuar := Sel >= 0;
end;

procedure TfrmDepuracionNueva.cboNodoTrabajoPropertiesChange(Sender: TObject);
var
  I: Integer;
begin
  I := cboNodoTrabajo.ItemIndex;
  if (I >= 0) and (I <= High(FOpciones)) then
    FNodoActual := FOpciones[I].Clave;
end;

procedure TfrmDepuracionNueva.SetAlImprimirActa(const Valor: TImprimirDepuracion);
begin
  FAlImprimirActa := Valor;
end;

{ ---------------------------------- tema --------------------------------- }

procedure TfrmDepuracionNueva.ConfigurarBoton(B: TcxButton; Primario: Boolean);
begin
  B.LookAndFeel.NativeStyle := False;
  B.LookAndFeel.Kind := lfFlat;
  B.Font.Name := 'Segoe UI';
  B.Font.Height := -12;
  B.Font.Style := [fsBold];
  if Primario then
  begin
    B.Colors.Default := FTema.Acento;
    B.Colors.Normal := FTema.Acento;
    B.Colors.Hot := FTema.Acento;
    B.Colors.Pressed := FTema.Acento;
    B.Colors.DefaultText := FTema.TextoSobreAcento;
    B.Colors.NormalText := FTema.TextoSobreAcento;
    B.Colors.HotText := FTema.TextoSobreAcento;
    B.Colors.PressedText := FTema.TextoSobreAcento;
  end
  else
  begin
    B.Colors.Default := FTema.Superficie;
    B.Colors.Normal := FTema.Superficie;
    B.Colors.Hot := FTema.AcentoSuave;
    B.Colors.Pressed := FTema.AcentoSuave;
    B.Colors.DefaultText := FTema.Texto;
    B.Colors.NormalText := FTema.Texto;
    B.Colors.HotText := FTema.Texto;
    B.Colors.PressedText := FTema.Texto;
  end;
end;

procedure TfrmDepuracionNueva.AplicarTema;
var
  T: TTemaColores;
  I: Integer;
  C: TComponent;
  P: TPanel;
  L: TLabel;
begin
  FTema := TemaLegacyActual;
  T := FTema;
  Color := T.Fondo;
  for I := 0 to ComponentCount - 1 do
  begin
    C := Components[I];
    if C is TPanel then
    begin
      P := TPanel(C);
      if P.Color = CLARO_FONDO then
        P.Color := T.Fondo
      else if P.Color = CLARO_SUP then
        P.Color := T.Superficie
      else if P.Color = CLARO_SUP2 then
        P.Color := T.Superficie2
      else if P.Color = CLARO_LINEA then
        P.Color := T.Linea;
    end
    else if C is TLabel then
    begin
      L := TLabel(C);
      if L.Font.Color = CLARO_TEXTO then
        L.Font.Color := T.Texto
      else if L.Font.Color = CLARO_SUAVE then
        L.Font.Color := T.TextoSuave
      else if L.Font.Color = CLARO_ACENTO then
        L.Font.Color := T.Acento
      else if L.Font.Color = CLARO_ERROR then
        L.Font.Color := ColorError(T)
      else if L.Font.Color = CLARO_OK then
        L.Font.Color := ColorOk(T);
    end
    else if C is TCheckBox then
      TCheckBox(C).Font.Color := T.Texto
    else if C is TcxCustomEdit then
    begin
      TcxCustomEdit(C).Style.Color := T.Superficie;
      TcxCustomEdit(C).Style.TextColor := T.Texto;
    end
    else if C is TcxGridTableView then
      TcxGridTableView(C).OptionsView.GridLineColor := T.Linea
    else if C is TcxButton then
      ConfigurarBoton(TcxButton(C), (C = btnNueva) or (C = btnAvanzar));
  end;
  stContenido.Color := T.Superficie;
  stContenido.TextColor := T.Texto;
  stContenidoPeq.Color := T.Superficie;
  stContenidoPeq.TextColor := T.Texto;
  stCabeceraGrid.Color := T.Superficie2;
  stCabeceraGrid.TextColor := T.TextoSuave;
  stSeleccion.Color := T.AcentoSuave;
  stSeleccion.TextColor := T.Texto;
  Invalidate;
end;

{ Cabecera plana, sin los bordes negros del estilo UltraFlat. }
procedure TfrmDepuracionNueva.tvCustomDrawColumnHeader(Sender: TcxGridTableView;
  ACanvas: TcxCanvas; AViewInfo: TcxGridColumnHeaderViewInfo; var ADone: Boolean);
var
  R: TRect;
begin
  R := AViewInfo.Bounds;
  ACanvas.Brush.Color := FTema.Superficie2;
  ACanvas.FillRect(R);
  ACanvas.Brush.Color := FTema.Linea;
  ACanvas.FillRect(Rect(R.Left, R.Bottom - 1, R.Right, R.Bottom));
  ACanvas.Font.Name := 'Segoe UI';
  ACanvas.Font.Size := 8;
  ACanvas.Font.Style := [fsBold];
  ACanvas.Font.Color := FTema.TextoSuave;
  ACanvas.Brush.Style := bsClear;
  ACanvas.DrawText(AViewInfo.Text, Rect(R.Left + MulDiv(12, CurrentPPI, 96), R.Top,
    R.Right - MulDiv(6, CurrentPPI, 96), R.Bottom), cxAlignVCenter or cxAlignLeft or
    cxSingleLine);
  ADone := True;
end;

{ --------------------------- IPantallaProceso ---------------------------- }

procedure TfrmDepuracionNueva.Embeber(Host: TWinControl);
begin
  FEmbebido := True;
  BorderStyle := bsNone;
  BorderIcons := [];
  Parent := Host;
  Align := alClient;
  // el titulo ya lo muestra la cabecera de la ventana principal: queda el subtitulo
  lblTitulo.Visible := False;
  lblSubtitulo.Font.Height := -14;
  lblSubtitulo.Top := (pnlCabecera.Height - lblSubtitulo.Height) div 2;
  Visible := True;
end;

function TfrmDepuracionNueva.PuedeSalir: Boolean;
begin
  Result := True;   // todo se guarda al momento: nunca hay cambios pendientes
end;

procedure TfrmDepuracionNueva.FijarAlSalir(const Valor: TNotifyEvent);
begin
  FAlSalir := Valor;
end;

procedure TfrmDepuracionNueva.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := PuedeSalir;
end;

{ El boton responde siempre: si el rol no puede depurar, se explica por que. }
procedure TfrmDepuracionNueva.AvisarSinPermiso;
begin
  TMensajes.Informacion('Su usuario no es especialista de gesti' + #243 + 'n documental ' +
    '(EGD) de ning' + #250 + 'n ' + #225 + 'rea con permiso para depurar, as' + #237 +
    ' que solo puede consultar las depuraciones. Un administrador asigna los EGD en ' +
    'Administraci' + #243 + 'n de usuarios.', 'Depuraci' + #243 + 'n');
end;

procedure TfrmDepuracionNueva.PedirSalir;
begin
  if FEmbebido and Assigned(FAlSalir) then
    FAlSalir(Self);
end;

procedure TfrmDepuracionNueva.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key <> VK_ESCAPE then
    Exit;
  Key := 0;
  if pnlDetalle.Visible then
    VolverALista
  else
    PedirSalir;
end;

{ --------------------------------- lista --------------------------------- }

procedure TfrmDepuracionNueva.Recargar;
var
  Filas: TArray<TDepuracionFila>;
begin
  if FConn = nil then
    Exit;
  try
    Filas := ListarDepuraciones(FConn, FNodos, FAnio, LIMITE_LISTA);
  except
    on E: Exception do
    begin
      Filas := nil;
      TMensajes.Error('No se pudieron leer las depuraciones: ' + E.Message,
        'Depuraci' + #243 + 'n');
    end;
  end;
  MostrarLista(Filas);
  if pnlDetalle.Visible and (FIdSeleccionado <> 0) then
    RefrescarDetalle;
end;

procedure TfrmDepuracionNueva.MostrarLista(const Filas: TArray<TDepuracionFila>);
var
  I: Integer;
  F: TDepuracionFila;
  DC: TcxGridDataController;
begin
  FFilas := Filas;
  FActualizando := True;
  try
    DC := tvDepuraciones.DataController;
    tvDepuraciones.BeginUpdate;
    try
      DC.RecordCount := Length(Filas);
      for I := 0 to High(Filas) do
      begin
        F := Filas[I];
        DC.Values[I, colIdProceso.Index] := F.IdProceso;
        DC.Values[I, colNumero.Index] := F.Numero;
        DC.Values[I, colSeries.Index] := F.Series;
        DC.Values[I, colUnidades.Index] := IntToStr(F.Unidades);
        DC.Values[I, colFechas.Index] := RangoMesAnio(F.Desde, F.Hasta);
        DC.Values[I, colAutorizacion.Index] := F.Autorizacion;
        DC.Values[I, colPaso.Index] := IntToStr(F.Paso) + ' de 5';
        DC.Values[I, colEstado.Index] := F.Estado;
      end;
    finally
      tvDepuraciones.EndUpdate;
    end;
  finally
    FActualizando := False;
  end;
  lblSubtitulo.Caption := IntToStr(Length(Filas)) + ' depuraciones ' + #183 + ' ' +
    IntToStr(FAnio);
end;

function TfrmDepuracionNueva.FilaDeLista(IdProceso: Integer;
  out Fila: TDepuracionFila): Boolean;
var
  F: TDepuracionFila;
begin
  Result := False;
  for F in FFilas do
    if F.IdProceso = IdProceso then
    begin
      Fila := F;
      Exit(True);
    end;
end;

function TfrmDepuracionNueva.IdDeLaFilaElegida: Integer;
var
  I: Integer;
begin
  Result := 0;
  I := tvDepuraciones.DataController.FocusedRecordIndex;
  if I < 0 then
    Exit;
  Result := StrToIntDef(VarToStr(tvDepuraciones.DataController.Values[I,
    colIdProceso.Index]), 0);
end;

procedure TfrmDepuracionNueva.tvDepuracionesFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  // la fila elegida solo se usa al pulsar "Abrir" o con doble clic
end;

procedure TfrmDepuracionNueva.tvDepuracionesCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  btnAbrirClick(nil);
  AHandled := True;
end;

procedure TfrmDepuracionNueva.btnAbrirClick(Sender: TObject);
var
  F: TDepuracionFila;
begin
  if FilaDeLista(IdDeLaFilaElegida, F) then
    AbrirDetalle(F)
  else
    TMensajes.Informacion('Elija una depuraci' + #243 + 'n de la lista.',
      'Depuraci' + #243 + 'n');
end;

procedure TfrmDepuracionNueva.btnNuevaClick(Sender: TObject);
var
  R: TProcesoRef;
begin
  if not FPuedeActuar then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  if not TMensajes.Confirmar('Se crea una depuraci' + #243 + 'n nueva del ' + #225 +
    'rea elegida. ' + #191 + 'Continuar?', 'Nueva depuraci' + #243 + 'n') then
    Exit;
  try
    R := CrearDepuracion(FConn, FNodoActual, FUsuario, FAnio);
  except
    on E: Exception do
    begin
      TMensajes.Error('No se pudo crear la depuraci' + #243 + 'n: ' + E.Message,
        'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  FIdSeleccionado := R.IdProceso;
  Recargar;
  RefrescarDetalle;
end;

procedure TfrmDepuracionNueva.AbrirDetalle(const Fila: TDepuracionFila);
begin
  FActual := Fila;
  FIdSeleccionado := Fila.IdProceso;
  MostrarDetalle(Fila);
end;

procedure TfrmDepuracionNueva.RefrescarDetalle;
var
  F: TDepuracionFila;
begin
  if FilaDeLista(FIdSeleccionado, F) then
    AbrirDetalle(F)
  else
    VolverALista;
end;

procedure TfrmDepuracionNueva.VolverALista;
begin
  pnlDetalle.Visible := False;
  pnlLista.Visible := True;
  FIdSeleccionado := 0;
end;

procedure TfrmDepuracionNueva.btnVolverClick(Sender: TObject);
begin
  VolverALista;
end;

{ --------------------------------- ficha --------------------------------- }

procedure TfrmDepuracionNueva.MostrarDetalle(const Fila: TDepuracionFila);
var
  Edita: Boolean;
begin
  FActual := Fila;
  pnlLista.Visible := False;
  pnlDetalle.Visible := True;
  lblDetTitulo.Caption := 'Depuraci' + #243 + 'n ' + Fila.Numero;
  lblDetSub.Caption := Fila.Series + '  ' + #183 + '  ' + Fila.Estado;
  pbPasos.Invalidate;
  pnlPaso1.Visible := (Fila.Paso = 1);
  pnlPaso2.Visible := (Fila.Paso = 2);
  pnlPaso3.Visible := (Fila.Paso = 3);
  pnlPaso4.Visible := (Fila.Paso = 4);
  pnlPaso5.Visible := (Fila.Paso >= 5);
  Edita := (Fila.Proceso = epEnCurso) and FPuedeActuar;
  btnAvanzar.Visible := Edita and (Fila.Paso <= 3);
  btnCancelarDep.Visible := Edita and PuedeCancelar(tpDepuracion, Fila.Paso);
  btnEliminarDep.Visible := FPuedeActuar and PuedeEliminar(tpDepuracion, Fila.Paso,
    Fila.Proceso);
  lblAviso.Caption := '';
end;

procedure TfrmDepuracionNueva.pbPasosPaint(Sender: TObject);
begin
  PintarPasos(pbPasos.Canvas, pbPasos.ClientRect, tpDepuracion, FNombresPasos,
    FActual.Paso, FActual.Proceso, FTema, CurrentPPI);
end;

end.
