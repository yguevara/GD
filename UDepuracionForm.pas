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
  FireDAC.Comp.Client, UAlcance, UProceso, UAutorizacion, UTema, UProcesoPintura, UPantallaProceso,
  UOpcionNodo, UDepuracionDatos, UDepuracionFicheros;

type
  { Pide imprimir el acta de una depuracion. }
  TImprimirDepuracion = reference to procedure(IdProceso: Integer);

  { Una comprobacion del paso de ejecucion y si se cumple. }
  TCheckEjecucion = record
    Texto: string;
    Cumplido: Boolean;
  end;

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
    pnlP1Prop: TPanel;
    pnlP1Top: TPanel;
    lblP1Ayuda: TLabel;
    pnlP1TopDer: TPanel;
    btnAgregar: TcxButton;
    pnlP1Rej: TPanel;
    grdPropuesta: TcxGrid;
    tvPropuesta: TcxGridTableView;
    colPropSerie: TcxGridColumn;
    colPropAnios: TcxGridColumn;
    colPropUnidades: TcxGridColumn;
    colPropFechas: TcxGridColumn;
    colPropObs: TcxGridColumn;
    lvPropuesta: TcxGridLevel;
    pnlP1Agreg: TPanel;
    pnlP1AgregTop: TPanel;
    lblP1Agregados: TLabel;
    pnlP1AgregDer: TPanel;
    btnQuitar: TcxButton;
    pnlP1AgregRej: TPanel;
    grdAgregados: TcxGrid;
    tvAgregados: TcxGridTableView;
    colAgrSerie: TcxGridColumn;
    colAgrUnidades: TcxGridColumn;
    colAgrFechas: TcxGridColumn;
    lvAgregados: TcxGridLevel;
    pnlPaso2: TPanel;
    lblP2Ayuda: TLabel;
    lblP2Organo: TLabel;
    cboOrgano: TcxComboBox;
    lblP2Acta: TLabel;
    edtActa: TcxTextEdit;
    lblP2Acuerdo: TLabel;
    edtAcuerdo: TcxTextEdit;
    lblP2Fecha: TLabel;
    dteAutorizacion: TcxDateEdit;
    btnRegistrarAut: TcxButton;
    lblAutError: TLabel;
    lblAutRegistrada: TLabel;
    pnlPaso3: TPanel;
    sbActa: TScrollBox;
    lblA3AutT: TLabel;
    lblA3Aut: TLabel;
    lblA3QueT: TLabel;
    grdLineas: TcxGrid;
    tvLineas: TcxGridTableView;
    colLinSerie: TcxGridColumn;
    colLinUnidades: TcxGridColumn;
    colLinFechas: TcxGridColumn;
    lvLineas: TcxGridLevel;
    grdDesglose: TcxGrid;
    tvDesglose: TcxGridTableView;
    colDesAnio: TcxGridColumn;
    colDesUnidades: TcxGridColumn;
    lvDesglose: TcxGridLevel;
    lblA3MuestraT: TLabel;
    lblMDescT: TLabel;
    edtMuestraDesc: TcxTextEdit;
    lblMDondeT: TLabel;
    edtMuestraDonde: TcxTextEdit;
    lblA3EjecT: TLabel;
    lblLugarT: TLabel;
    edtLugar: TcxTextEdit;
    lblViaT: TLabel;
    cboVia: TcxComboBox;
    lblFPrevT: TLabel;
    dteFPrevista: TcxDateEdit;
    btnGuardarActa: TcxButton;
    btnImprimirActa: TcxButton;
    lblA3TestT: TLabel;
    grdTestigos: TcxGrid;
    tvTestigos: TcxGridTableView;
    colTesNombre: TcxGridColumn;
    colTesCargo: TcxGridColumn;
    colTesOrigen: TcxGridColumn;
    colTesFirmo: TcxGridColumn;
    lvTestigos: TcxGridLevel;
    btnQuitarTestigo: TcxButton;
    btnMarcarFirma: TcxButton;
    lblTNombreT: TLabel;
    edtTNombre: TcxTextEdit;
    lblTCargoT: TLabel;
    edtTCargo: TcxTextEdit;
    lblTOrigenT: TLabel;
    cboTOrigen: TcxComboBox;
    btnAgregarTestigo: TcxButton;
    lblA3Req: TLabel;
    lblA3Falta: TLabel;
    pnlPaso4: TPanel;
    lblE4Titulo: TLabel;
    lblE4Resumen: TLabel;
    lblE4ChkT: TLabel;
    lblChk1: TLabel;
    lblChk2: TLabel;
    lblChk3: TLabel;
    lblChk4: TLabel;
    lblE4Advert: TLabel;
    edtConfirmacion: TcxTextEdit;
    btnEjecutar: TcxButton;
    pnlPaso5: TPanel;
    lblE5Texto: TLabel;
    lblE5Ayuda: TLabel;
    btnImprimirActa5: TcxButton;
    btnCerrarDep: TcxButton;
    lblE5FicherosT: TLabel;
    grdFicheros: TcxGrid;
    tvFicheros: TcxGridTableView;
    colFicNombre: TcxGridColumn;
    colFicEstado: TcxGridColumn;
    colFicMensaje: TcxGridColumn;
    lvFicheros: TcxGridLevel;
    lblE5Resumen: TLabel;
    btnRetirar: TcxButton;
    btnReintentar: TcxButton;
    btnConfirmarManual: TcxButton;
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
    procedure btnAgregarClick(Sender: TObject);
    procedure btnQuitarClick(Sender: TObject);
    procedure btnRegistrarAutClick(Sender: TObject);
    procedure btnAvanzarClick(Sender: TObject);
    procedure btnGuardarActaClick(Sender: TObject);
    procedure btnImprimirActaClick(Sender: TObject);
    procedure btnAgregarTestigoClick(Sender: TObject);
    procedure btnQuitarTestigoClick(Sender: TObject);
    procedure btnMarcarFirmaClick(Sender: TObject);
    procedure edtConfirmacionPropertiesChange(Sender: TObject);
    procedure btnEjecutarClick(Sender: TObject);
    procedure btnCerrarDepClick(Sender: TObject);
    procedure btnCancelarDepClick(Sender: TObject);
    procedure btnEliminarDepClick(Sender: TObject);
    procedure btnRetirarClick(Sender: TObject);
    procedure btnReintentarClick(Sender: TObject);
    procedure btnConfirmarManualClick(Sender: TObject);
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
    FPropuesta: TArray<TGrupoDepuracion>;
    FAgregados: TArray<TGrupoDepuracion>;
    FTestigos: TArray<TTestigoFila>;
    FChecksOk: Boolean;
    FFicheros: TArray<TFicheroRetiro>;
    FFabricaRetiro: TFabricaAlmacenRetiro;
    procedure RetirarLosFicheros(Confirmar: Boolean);
    procedure RefrescarFaltantes;
    function PuedeActuarAqui: Boolean;
    procedure ActualizarBotonEjecutar;
    procedure SetPuedeActuar(Valor: Boolean);
    procedure SetAlImprimirActa(const Valor: TImprimirDepuracion);
    procedure AplicarTema;
    procedure ConfigurarBoton(B: TcxButton; Primario: Boolean);
    procedure Recargar;
    procedure AbrirDetalle(const Fila: TDepuracionFila);
    procedure RefrescarDetalle;
    procedure VolverALista;
    procedure CargarPaso;
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
    { Paso 1: lo que se puede proponer (con el motivo si no hay nada) y lo ya agregado. }
    procedure MostrarPropuesta(const Grupos: TArray<TGrupoDepuracion>;
      const MotivoVacia: string = '');
    procedure MostrarAgregados(const Grupos: TArray<TGrupoDepuracion>);
    { Paso 2: la autorizacion registrada (o los campos vacios). }
    procedure MostrarAutorizacion(Hay: Boolean; const A: TAutorizacion);
    { Lo que falta para avanzar, en el aviso del pie. }
    procedure MostrarFaltan(const Textos: TArray<string>);
    { Paso 3: el acta guardada, lo que se elimina (en numeros y letras) y su desglose
      por ano; y los testigos. }
    procedure MostrarActa(const A: TActaDepuracion; const Grupos: TArray<TGrupoDepuracion>;
      const Desglose: TArray<TAnioCantidad>);
    procedure MostrarTestigos(const T: TArray<TTestigoFila>);
    { Paso 4: el resumen de lo que se elimina y las comprobaciones previas; el boton de
      ejecutar solo se activa con todo cumplido y la palabra ELIMINAR escrita. }
    procedure MostrarEjecucion(const Fila: TDepuracionFila;
      const Checks: TArray<TCheckEjecucion>);
    { Paso 5: los ficheros digitales de lo eliminado y su estado. El cierre solo se
      permite con todos resueltos. }
    procedure MostrarFicheros(const F: TArray<TFicheroRetiro>);
    { IPantallaProceso }
    procedure Embeber(Host: TWinControl);
    function PuedeSalir: Boolean;
    procedure FijarAlSalir(const Valor: TNotifyEvent);
    { Solo quien puede depurar en el nodo (el especialista de gestion documental)
      crea depuraciones y cambia su estado; los demas ven. Por defecto, si. }
    property PuedeActuar: Boolean read FPuedeActuar write SetPuedeActuar;
    property AlImprimirActa: TImprimirDepuracion read FAlImprimirActa
      write SetAlImprimirActa;
    { Almacen de cada fichero (lo arma la ventana principal); sin el, no se retira. }
    property FabricaRetiro: TFabricaAlmacenRetiro read FFabricaRetiro write FFabricaRetiro;
  end;

function CrearPantallaDepuracion(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario;
  const Usuario: string): TfrmDepuracionNueva;

implementation

{$R *.dfm}

uses
  System.DateUtils, System.Variants, Data.DB, UAparienciaLegacy, UMensajes,
  UProcesosDatos, UTransferenciasDatos, UDepuracionReglas;

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
  cboTOrigen.ItemIndex := 0;
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

{ El EGD actua solo en SU nodo: la ficha abierta debe ser de uno de los nodos de trabajo
  (ve los de sus descendientes, pero no los cambia). Sin nodos fijados (arnes de capturas),
  vale el permiso general. }
function TfrmDepuracionNueva.PuedeActuarAqui: Boolean;
begin
  Result := FPuedeActuar and ((Length(FOpciones) = 0) or
    (IndiceDeNodo(FOpciones, FActual.Nodo) >= 0));
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
  btnImprimirActa.Visible := Assigned(Valor);
  btnImprimirActa5.Visible := Assigned(Valor);
end;

{ ---------------------------------- tema --------------------------------- }

procedure TfrmDepuracionNueva.ConfigurarBoton(B: TcxButton; Primario: Boolean);
begin
  B.LookAndFeel.NativeStyle := False;
  B.LookAndFeel.Kind := lfFlat;
  B.Font.Name := 'Segoe UI';
  B.Font.Height := -12;
  B.Font.Style := [fsBold];
  B.Colors.Disabled := FTema.Superficie2;
  B.Colors.DisabledText := FTema.TextoSuave;
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
    else if C is TScrollBox then
    begin
      if TScrollBox(C).Color = CLARO_SUP then
        TScrollBox(C).Color := T.Superficie;
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
      ConfigurarBoton(TcxButton(C), (C = btnNueva) or (C = btnAvanzar) or
        (C = btnAgregar) or (C = btnRegistrarAut) or (C = btnGuardarActa) or (C = btnEjecutar) or (C = btnCerrarDep) or (C = btnRetirar));
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
  CargarPaso;
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

{ ------------------------------ pasos 1 y 2 ------------------------------ }

function UnirTextos(const Textos: TArray<string>): string;
var
  S: string;
begin
  Result := '';
  for S in Textos do
  begin
    if Result <> '' then
      Result := Result + '  ';
    Result := Result + S;
  end;
end;

procedure TfrmDepuracionNueva.CargarPaso;
var
  Aut: TAutorizacion;
  Hay: Boolean;
  Grupos: TArray<TGrupoDepuracion>;
  Motivo: string;
  Acta: TActaDepuracion;
  Cond: TCondiciones;
  FaltanAux: TArray<string>;
  Testigos: TArray<TTestigoFila>;
  Checks: TArray<TCheckEjecucion>;
  Firmaron, I: Integer;
begin
  if FConn = nil then
    Exit;
  try
    case FActual.Paso of
      1:
        begin
          MostrarAgregados(GruposDeLaDepuracion(FConn, FActual.IdProceso));
          Grupos := ProponerDepuracion(FConn, FActual.Nodo, Now);
          Motivo := '';
          if Length(Grupos) = 0 then
          begin
            if Length(ListarArchivosCentrales(FConn)) = 0 then
              Motivo := 'No hay ning' + #250 + 'n archivo de tipo Central. Los documentos ' +
                'deben estar en un archivo Central o Hist' + #243 + 'rico para depurarse; ' +
                'cree uno en Clasificadores > Archivos.'
            else
              Motivo := 'No hay series con destino final ' + #171 + 'Eliminarlo' + #187 +
                ' y plazo en el archivo central, o todav' + #237 + 'a no ha vencido ning' +
                #250 + 'n plazo.';
          end;
          MostrarPropuesta(Grupos, Motivo);
        end;
      2:
        begin
          Hay := LeerAutorizacion(FConn, FActual.IdProceso, Aut);
          MostrarAutorizacion(Hay, Aut);
        end;
      3:
        begin
          LeerActaDepuracion(FConn, FActual.IdProceso, Acta);
          MostrarActa(Acta, GruposDeLaDepuracion(FConn, FActual.IdProceso),
            DesglosePorAnio(FConn, FActual.IdProceso));
          MostrarTestigos(TestigosDeLaDepuracion(FConn, FActual.IdProceso));
          RefrescarFaltantes;
        end;
      4:
        begin
          Cond := CondicionesCumplidasDepuracion(FConn, FActual.IdProceso, FaltanAux);
          LeerActaDepuracion(FConn, FActual.IdProceso, Acta);
          Testigos := TestigosDeLaDepuracion(FConn, FActual.IdProceso);
          Firmaron := 0;
          for I := 0 to High(Testigos) do
            if Testigos[I].Firmo then
              Inc(Firmaron);
          SetLength(Checks, 4);
          if FActual.Autorizacion <> '' then
            Checks[0].Texto := 'Acuerdo de la Comisi' + #243 + 'n: ' + FActual.Autorizacion
          else
            Checks[0].Texto := 'Falta el acuerdo de la Comisi' + #243 + 'n';
          Checks[0].Cumplido := cdAutorizado in Cond;
          if cdMuestraDefinida in Cond then
            Checks[1].Texto := 'Muestra definida: ' + Acta.MuestraDesc + ' (' +
              Acta.MuestraDonde + ')'
          else
            Checks[1].Texto := 'Falta definir la muestra que se conserva';
          Checks[1].Cumplido := cdMuestraDefinida in Cond;
          Checks[2].Texto := IntToStr(Length(Testigos)) + ' testigos, ' + IntToStr(Firmaron) +
            ' ya firmaron';
          Checks[2].Cumplido := cdTestigosMinimos in Cond;
          if cdSinBloqueos in Cond then
            Checks[3].Texto := 'Ning' + #250 + 'n documento est' + #225 +
              ' en pr' + #233 + 'stamo ni en otra transferencia'
          else
            Checks[3].Texto := 'Hay documentos retenidos por otro proceso o ya fuera del ' +
              'archivo';
          Checks[3].Cumplido := cdSinBloqueos in Cond;
          MostrarEjecucion(FActual, Checks);
        end;
      5:
        MostrarFicheros(FicherosDelRetiro(FConn, FActual.IdProceso));
    end;
  except
    on E: Exception do
      TMensajes.Error('No se pudieron leer los datos de la depuraci' + #243 + 'n: ' +
        E.Message, 'Depuraci' + #243 + 'n');
  end;
end;

procedure TfrmDepuracionNueva.MostrarPropuesta(const Grupos: TArray<TGrupoDepuracion>;
  const MotivoVacia: string);
var
  I: Integer;
  G: TGrupoDepuracion;
  DC: TcxGridDataController;
  Obs: string;
begin
  FPropuesta := Grupos;
  if MotivoVacia <> '' then
    tvPropuesta.OptionsView.NoDataToDisplayInfoText := MotivoVacia
  else
    tvPropuesta.OptionsView.NoDataToDisplayInfoText := 'No hay series para proponer';
  DC := tvPropuesta.DataController;
  tvPropuesta.BeginUpdate;
  try
    DC.RecordCount := Length(Grupos);
    for I := 0 to High(Grupos) do
    begin
      G := Grupos[I];
      Obs := '';
      if G.Retenidos > 0 then
        Obs := IntToStr(G.Retenidos) + ' retenidos por otro proceso';
      DC.Values[I, colPropSerie.Index] := G.Serie + ' ' + #183 + ' ' + G.Subserie;
      DC.Values[I, colPropAnios.Index] := IntToStr(G.AniosCentral) + ' a' + #241 + 'os';
      DC.Values[I, colPropUnidades.Index] := IntToStr(G.Unidades);
      DC.Values[I, colPropFechas.Index] := RangoMesAnio(G.Desde, G.Hasta);
      DC.Values[I, colPropObs.Index] := Obs;
    end;
  finally
    tvPropuesta.EndUpdate;
  end;
end;

procedure TfrmDepuracionNueva.MostrarAgregados(const Grupos: TArray<TGrupoDepuracion>);
var
  I: Integer;
  G: TGrupoDepuracion;
  DC: TcxGridDataController;
begin
  FAgregados := Grupos;
  DC := tvAgregados.DataController;
  tvAgregados.BeginUpdate;
  try
    DC.RecordCount := Length(Grupos);
    for I := 0 to High(Grupos) do
    begin
      G := Grupos[I];
      DC.Values[I, colAgrSerie.Index] := G.Serie + ' ' + #183 + ' ' + G.Subserie;
      DC.Values[I, colAgrUnidades.Index] := IntToStr(G.Unidades);
      DC.Values[I, colAgrFechas.Index] := RangoMesAnio(G.Desde, G.Hasta);
    end;
  finally
    tvAgregados.EndUpdate;
  end;
end;

procedure TfrmDepuracionNueva.MostrarAutorizacion(Hay: Boolean; const A: TAutorizacion);
begin
  lblAutError.Caption := '';
  if Hay then
  begin
    case A.Organo of
      ocNacional: cboOrgano.ItemIndex := 0;
      ocProvincial: cboOrgano.ItemIndex := 1;
    else
      cboOrgano.ItemIndex := 2;
    end;
    edtActa.Text := A.NumActa;
    edtAcuerdo.Text := A.NumAcuerdo;
    if A.Fecha <> 0 then
      dteAutorizacion.Date := A.Fecha
    else
      dteAutorizacion.Clear;
    lblAutRegistrada.Caption := 'Autorizaci' + #243 + 'n registrada: ' +
      TextoAutorizacionCorto(A) + ' (' + FormatDateTime('dd/mm/yyyy', A.Fecha) + ').';
  end
  else
  begin
    // sin autorizacion: nada de lo que quedo de otra depuracion
    lblAutRegistrada.Caption := '';
    cboOrgano.ItemIndex := -1;
    edtActa.Clear;
    edtAcuerdo.Clear;
    dteAutorizacion.Clear;
  end;
end;

procedure TfrmDepuracionNueva.MostrarFaltan(const Textos: TArray<string>);
begin
  lblAviso.Caption := UnirTextos(Textos);
  if Length(Textos) = 0 then
  begin
    lblA3Falta.Font.Color := ColorOk(FTema);
    lblA3Falta.Caption := 'Todo listo para pasar a Ejecuci' + #243 + 'n.';
  end
  else
  begin
    lblA3Falta.Font.Color := ColorError(FTema);
    lblA3Falta.Caption := UnirTextos(Textos);
  end;
end;

procedure TfrmDepuracionNueva.RefrescarFaltantes;
var
  Faltan: TArray<string>;
begin
  CondicionesCumplidasDepuracion(FConn, FActual.IdProceso, Faltan);
  MostrarFaltan(Faltan);
end;

function TextoOrigen(O: TOrigenTestigo): string;
begin
  case O of
    otComision: Result := 'Comisi' + #243 + 'n de Valoraci' + #243 + 'n';
    otArchivoGestion: Result := 'Archivo de gesti' + #243 + 'n';
  else
    Result := 'Otro';
  end;
end;

procedure TfrmDepuracionNueva.MostrarActa(const A: TActaDepuracion;
  const Grupos: TArray<TGrupoDepuracion>; const Desglose: TArray<TAnioCantidad>);
var
  I: Integer;
  DC: TcxGridDataController;
begin
  if FActual.Autorizacion <> '' then
    lblA3Aut.Caption := FActual.Autorizacion
  else
    lblA3Aut.Caption := 'Sin autorizaci' + #243 + 'n registrada';
  DC := tvLineas.DataController;
  tvLineas.BeginUpdate;
  try
    DC.RecordCount := Length(Grupos);
    for I := 0 to High(Grupos) do
    begin
      if SameText(Grupos[I].Serie, Grupos[I].Subserie) or (Grupos[I].Subserie = '') then
        DC.Values[I, colLinSerie.Index] := Grupos[I].Serie
      else
        DC.Values[I, colLinSerie.Index] := Grupos[I].Serie + ' / ' + Grupos[I].Subserie;
      DC.Values[I, colLinUnidades.Index] := UnidadesNumerosYLetras(Grupos[I].Unidades);
      DC.Values[I, colLinFechas.Index] := RangoMesAnio(Grupos[I].Desde, Grupos[I].Hasta);
    end;
  finally
    tvLineas.EndUpdate;
  end;
  DC := tvDesglose.DataController;
  tvDesglose.BeginUpdate;
  try
    DC.RecordCount := Length(Desglose);
    for I := 0 to High(Desglose) do
    begin
      DC.Values[I, colDesAnio.Index] := IntToStr(Desglose[I].Anio);
      DC.Values[I, colDesUnidades.Index] := IntToStr(Desglose[I].Unidades);
    end;
  finally
    tvDesglose.EndUpdate;
  end;
  edtMuestraDesc.Text := A.MuestraDesc;
  edtMuestraDonde.Text := A.MuestraDonde;
  edtLugar.Text := A.Lugar;
  if (A.Lugar = '') and (A.FPrevista = 0) then
  begin
    cboVia.ItemIndex := -1;
    dteFPrevista.Clear;
  end
  else
  begin
    if A.Via = veTrituracion then
      cboVia.ItemIndex := 1
    else
      cboVia.ItemIndex := 0;
    if A.FPrevista <> 0 then
      dteFPrevista.Date := A.FPrevista
    else
      dteFPrevista.Clear;
  end;
end;

procedure TfrmDepuracionNueva.MostrarTestigos(const T: TArray<TTestigoFila>);
var
  I: Integer;
  DC: TcxGridDataController;
begin
  FTestigos := T;
  DC := tvTestigos.DataController;
  tvTestigos.BeginUpdate;
  try
    DC.RecordCount := Length(T);
    for I := 0 to High(T) do
    begin
      DC.Values[I, colTesNombre.Index] := T[I].Nombre;
      DC.Values[I, colTesCargo.Index] := T[I].Cargo;
      DC.Values[I, colTesOrigen.Index] := TextoOrigen(T[I].Origen);
      if T[I].Firmo then
        DC.Values[I, colTesFirmo.Index] := 'S' + #237
      else
        DC.Values[I, colTesFirmo.Index] := '';
    end;
  finally
    tvTestigos.EndUpdate;
  end;
end;

procedure TfrmDepuracionNueva.btnGuardarActaClick(Sender: TObject);
var
  A: TActaDepuracion;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  lblAviso.Caption := '';
  if cboVia.ItemIndex < 0 then
  begin
    lblAviso.Caption := 'Elija la v' + #237 + 'a de eliminaci' + #243 + 'n.';
    Exit;
  end;
  A := Default(TActaDepuracion);
  A.Lugar := edtLugar.Text;
  if cboVia.ItemIndex = 1 then
    A.Via := veTrituracion
  else
    A.Via := veIncineracion;
  if VarIsNull(dteFPrevista.EditValue) then
    A.FPrevista := 0
  else
    A.FPrevista := dteFPrevista.Date;
  A.MuestraDesc := edtMuestraDesc.Text;
  A.MuestraDonde := edtMuestraDonde.Text;
  try
    GuardarActaDepuracion(FConn, FActual.IdProceso, A);
  except
    on E: EArgumentException do
    begin
      lblAviso.Caption := E.Message;
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo guardar el acta: ' + E.Message, 'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  RefrescarFaltantes;
end;

procedure TfrmDepuracionNueva.btnImprimirActaClick(Sender: TObject);
begin
  if Assigned(FAlImprimirActa) then
    FAlImprimirActa(FActual.IdProceso);
end;

procedure TfrmDepuracionNueva.btnAgregarTestigoClick(Sender: TObject);
var
  T: TTestigoDatos;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  lblAviso.Caption := '';
  T.Nombre := edtTNombre.Text;
  T.Cargo := edtTCargo.Text;
  case cboTOrigen.ItemIndex of
    0: T.Origen := otComision;
    1: T.Origen := otArchivoGestion;
  else
    T.Origen := otOtro;
  end;
  try
    AgregarTestigo(FConn, FActual.IdProceso, T);
  except
    on E: EArgumentException do
    begin
      lblAviso.Caption := E.Message;
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo agregar el testigo: ' + E.Message, 'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  edtTNombre.Clear;
  edtTCargo.Clear;
  MostrarTestigos(TestigosDeLaDepuracion(FConn, FActual.IdProceso));
  RefrescarFaltantes;
end;

procedure TfrmDepuracionNueva.btnQuitarTestigoClick(Sender: TObject);
var
  I: Integer;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  I := tvTestigos.DataController.FocusedRecordIndex;
  if (I < 0) or (I > High(FTestigos)) then
  begin
    TMensajes.Informacion('Elija el testigo que quiere quitar.', 'Depuraci' + #243 + 'n');
    Exit;
  end;
  if not TMensajes.Confirmar(#191 + 'Quitar a ' + FTestigos[I].Nombre + '?',
    'Quitar testigo') then
    Exit;
  try
    QuitarTestigo(FConn, FActual.IdProceso, FTestigos[I].IdTestigo);
  except
    on E: Exception do
    begin
      TMensajes.Error('No se pudo quitar el testigo: ' + E.Message, 'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  MostrarTestigos(TestigosDeLaDepuracion(FConn, FActual.IdProceso));
  RefrescarFaltantes;
end;

procedure TfrmDepuracionNueva.btnMarcarFirmaClick(Sender: TObject);
var
  I: Integer;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  I := tvTestigos.DataController.FocusedRecordIndex;
  if (I < 0) or (I > High(FTestigos)) then
  begin
    TMensajes.Informacion('Elija el testigo que firm' + #243 + '.', 'Depuraci' + #243 + 'n');
    Exit;
  end;
  try
    MarcarFirma(FConn, FActual.IdProceso, FTestigos[I].IdTestigo, not FTestigos[I].Firmo);
  except
    on E: Exception do
    begin
      TMensajes.Error('No se pudo guardar la firma: ' + E.Message, 'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  MostrarTestigos(TestigosDeLaDepuracion(FConn, FActual.IdProceso));
end;

procedure TfrmDepuracionNueva.btnAgregarClick(Sender: TObject);
var
  I, Idx, Total, Agregados: Integer;
  Motivo, Problemas: string;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  if tvPropuesta.Controller.SelectedRecordCount = 0 then
  begin
    TMensajes.Informacion('Marque las series que quiere agregar.', 'Depuraci' + #243 + 'n');
    Exit;
  end;
  if not TMensajes.Confirmar('Las series marcadas se agregan a la depuraci' + #243 +
    'n y sus documentos quedan retenidos hasta que se cierre o se cancele. ' + #191 +
    'Continuar?', 'Agregar a la depuraci' + #243 + 'n') then
    Exit;
  Total := 0;
  Problemas := '';
  for I := 0 to tvPropuesta.Controller.SelectedRecordCount - 1 do
  begin
    Idx := tvPropuesta.Controller.SelectedRecords[I].RecordIndex;
    if (Idx < 0) or (Idx > High(FPropuesta)) then
      Continue;
    try
      if AgregarGrupoDepuracion(FConn, FActual.IdProceso, FPropuesta[Idx], Now, Agregados,
        Motivo) then
        Inc(Total, Agregados)
      else
        Problemas := Problemas + sLineBreak + FPropuesta[Idx].Subserie + ': ' + Motivo;
    except
      on E: Exception do
        Problemas := Problemas + sLineBreak + FPropuesta[Idx].Subserie + ': ' + E.Message;
    end;
  end;
  if Problemas <> '' then
    TMensajes.Advertencia('Se agregaron ' + IntToStr(Total) + ' documento(s), pero:' +
      Problemas, 'Depuraci' + #243 + 'n');
  Recargar;
end;

procedure TfrmDepuracionNueva.btnQuitarClick(Sender: TObject);
var
  I: Integer;
  G: TGrupoDepuracion;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  I := tvAgregados.DataController.FocusedRecordIndex;
  if (I < 0) or (I > High(FAgregados)) then
  begin
    TMensajes.Informacion('Elija la serie que quiere quitar.', 'Depuraci' + #243 + 'n');
    Exit;
  end;
  G := FAgregados[I];
  if not TMensajes.Confirmar(#191 + 'Quitar ' + IntToStr(G.Unidades) + ' documento(s) de ' +
    G.Subserie + '? Quedar' + #225 + 'n libres.', 'Quitar de la depuraci' + #243 + 'n') then
    Exit;
  try
    QuitarGrupoDepuracion(FConn, FActual.IdProceso, G.IdEstructura, G.IdNodo, G.CodSubs);
  except
    on E: Exception do
      TMensajes.Error('No se pudo quitar: ' + E.Message, 'Depuraci' + #243 + 'n');
  end;
  Recargar;
end;

procedure TfrmDepuracionNueva.btnRegistrarAutClick(Sender: TObject);
var
  A: TAutorizacion;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  lblAutError.Caption := '';
  if cboOrgano.ItemIndex < 0 then
  begin
    lblAutError.Caption := 'Elija el ' + #243 + 'rgano de la Comisi' + #243 + 'n.';
    lblAviso.Caption := lblAutError.Caption;
    Exit;
  end;
  case cboOrgano.ItemIndex of
    0: A.Organo := ocNacional;
    1: A.Organo := ocProvincial;
  else
    A.Organo := ocMunicipal;
  end;
  A.NumActa := edtActa.Text;
  A.NumAcuerdo := edtAcuerdo.Text;
  if VarIsNull(dteAutorizacion.EditValue) then
    A.Fecha := 0
  else
    A.Fecha := dteAutorizacion.Date;
  try
    GuardarAutorizacion(FConn, FActual.IdProceso, A, FUsuario);
  except
    on E: EAutorizacionInvalida do
    begin
      lblAutError.Caption := E.Message;
      lblAviso.Caption := E.Message;
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo registrar la autorizaci' + #243 + 'n: ' + E.Message,
        'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  MostrarAutorizacion(True, A);
  lblAviso.Caption := '';
end;

procedure TfrmDepuracionNueva.btnAvanzarClick(Sender: TObject);
var
  Faltan: TArray<string>;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  lblAviso.Caption := '';
  try
    if AvanzarDepuracion(FConn, FActual.IdProceso, FActual.Paso, FUsuario, Faltan) then
    begin
      Recargar;
      Exit;
    end;
  except
    on E: Exception do
    begin
      TMensajes.Error('No se pudo avanzar la depuraci' + #243 + 'n: ' + E.Message,
        'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  if Length(Faltan) > 0 then
    MostrarFaltan(Faltan)
  else
  begin
    TMensajes.Advertencia('Otro usuario ya avanz' + #243 + ' o cambi' + #243 +
      ' esta depuraci' + #243 + 'n. Se muestra su estado actual.', 'Depuraci' + #243 + 'n');
    Recargar;
  end;
end;

procedure TfrmDepuracionNueva.ActualizarBotonEjecutar;
begin
  btnEjecutar.Enabled := FChecksOk and
    ConfirmacionEscritaValida(VarToStr(edtConfirmacion.EditingValue));
end;

procedure TfrmDepuracionNueva.MostrarEjecucion(const Fila: TDepuracionFila;
  const Checks: TArray<TCheckEjecucion>);
var
  Etiquetas: array[0..3] of TLabel;
  I: Integer;
begin
  Etiquetas[0] := lblChk1;
  Etiquetas[1] := lblChk2;
  Etiquetas[2] := lblChk3;
  Etiquetas[3] := lblChk4;
  lblE4Resumen.Caption := 'Se marcar' + #225 + 'n como eliminados ' + IntToStr(Fila.Unidades) +
    ' documentos: ' + Fila.Series + ' (' + RangoMesAnio(Fila.Desde, Fila.Hasta) + ')';
  FChecksOk := Length(Checks) > 0;
  for I := 0 to High(Etiquetas) do
  begin
    if I > High(Checks) then
    begin
      Etiquetas[I].Caption := '';
      Continue;
    end;
    if Checks[I].Cumplido then
    begin
      Etiquetas[I].Caption := #10003 + '  ' + Checks[I].Texto;
      Etiquetas[I].Font.Color := ColorOk(FTema);
    end
    else
    begin
      Etiquetas[I].Caption := #10007 + '  ' + Checks[I].Texto;
      Etiquetas[I].Font.Color := ColorError(FTema);
      FChecksOk := False;
    end;
  end;
  edtConfirmacion.Clear;
  ActualizarBotonEjecutar;
end;

procedure TfrmDepuracionNueva.edtConfirmacionPropertiesChange(Sender: TObject);
begin
  ActualizarBotonEjecutar;
end;

procedure TfrmDepuracionNueva.btnEjecutarClick(Sender: TObject);
var
  Hecho: Boolean;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  lblAviso.Caption := '';
  if not TMensajes.Confirmar('Se eliminan ' + IntToStr(FActual.Unidades) + ' documentos de ' +
    FActual.Series + '. Esta acci' + #243 + 'n no se puede deshacer. ' + #191 + 'Continuar?',
    'Ejecutar la eliminaci' + #243 + 'n') then
    Exit;
  try
    Hecho := EjecutarDepuracion(FConn, FActual.IdProceso, FUsuario, edtConfirmacion.Text,
      Date);
  except
    on E: EArgumentException do
    begin
      lblAviso.Caption := E.Message;
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo ejecutar la eliminaci' + #243 + 'n: ' + E.Message,
        'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  if not Hecho then
    TMensajes.Advertencia('La depuraci' + #243 + 'n ya no est' + #225 + ' en este paso. ' +
      'Se muestra su estado actual.', 'Depuraci' + #243 + 'n');
  Recargar;
end;

procedure TfrmDepuracionNueva.MostrarFicheros(const F: TArray<TFicheroRetiro>);
var
  I, Pend, Err, Ret, Lect: Integer;
  DC: TcxGridDataController;
  Edita: Boolean;
begin
  FFicheros := F;
  Pend := 0;
  Err := 0;
  Ret := 0;
  Lect := 0;
  DC := tvFicheros.DataController;
  tvFicheros.BeginUpdate;
  try
    DC.RecordCount := Length(F);
    for I := 0 to High(F) do
    begin
      DC.Values[I, colFicNombre.Index] := F[I].Nombre;
      DC.Values[I, colFicEstado.Index] := TextoEstadoFichero(F[I].Estado);
      DC.Values[I, colFicMensaje.Index] := F[I].Mensaje;
      if F[I].Estado = 'P' then
        Inc(Pend)
      else if F[I].Estado = 'E' then
        Inc(Err)
      else if F[I].Estado = 'L' then
        Inc(Lect)
      else
        Inc(Ret);
    end;
  finally
    tvFicheros.EndUpdate;
  end;
  if Length(F) = 0 then
    lblE5Resumen.Caption := ''
  else
    lblE5Resumen.Caption := IntToStr(Ret) + ' resueltos, ' + IntToStr(Pend) + ' pendientes, ' +
      IntToStr(Err) + ' con error, ' + IntToStr(Lect) + ' de solo lectura.';
  if Lect > 0 then
    lblE5Resumen.Caption := lblE5Resumen.Caption + ' Ret' + #237 + 'relos a mano en el servidor y ' +
      'conf' + #237 + 'rmelo.';
  Edita := (FActual.Proceso = epEnCurso) and PuedeActuarAqui;
  btnRetirar.Visible := Edita and (Pend > 0);
  btnReintentar.Visible := Edita and (Err > 0);
  btnConfirmarManual.Visible := Edita and (Lect > 0);
  btnCerrarDep.Enabled := (Pend + Err + Lect) = 0;
end;

{ Retira los pendientes y reintenta los que fallaron (es la misma operacion). }
procedure TfrmDepuracionNueva.RetirarLosFicheros(Confirmar: Boolean);
var
  R: TResumenRetiro;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  if not Assigned(FFabricaRetiro) then
  begin
    TMensajes.Error('No hay un almac' + #233 + 'n de ficheros configurado.', 'Depuraci' + #243 + 'n');
    Exit;
  end;
  if Confirmar and not TMensajes.Confirmar('Se retiran del almac' + #233 + 'n los ficheros ' +
    'digitales de los documentos eliminados. Esta acci' + #243 + 'n no se puede deshacer. ' +
    #191 + 'Continuar?', 'Retirar ficheros') then
    Exit;
  lblAviso.Caption := '';
  try
    R := RetirarFicheros(FConn, FActual.IdProceso, FFabricaRetiro, FUsuario);
  except
    on E: EArgumentException do
    begin
      lblAviso.Caption := E.Message;
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudieron retirar los ficheros: ' + E.Message, 'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  CargarPaso;
  lblAviso.Caption := IntToStr(R.Retirados) + ' retirados, ' + IntToStr(R.YaNoExistian) +
    ' ya no exist' + #237 + 'an, ' + IntToStr(R.SoloLectura) + ' de solo lectura, ' +
    IntToStr(R.Errores) + ' con error.';
end;

procedure TfrmDepuracionNueva.btnRetirarClick(Sender: TObject);
begin
  RetirarLosFicheros(True);
end;

procedure TfrmDepuracionNueva.btnReintentarClick(Sender: TObject);
begin
  RetirarLosFicheros(False);
end;

procedure TfrmDepuracionNueva.btnConfirmarManualClick(Sender: TObject);
var
  I: Integer;
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  I := tvFicheros.DataController.FocusedRecordIndex;
  if (I < 0) or (I > High(FFicheros)) or (FFicheros[I].Estado <> 'L') then
  begin
    TMensajes.Informacion('Elija un fichero de solo lectura que ya haya retirado a mano.',
      'Depuraci' + #243 + 'n');
    Exit;
  end;
  if not TMensajes.Confirmar(#191 + 'Confirma que ' + FFicheros[I].Nombre + ' ya se retir' + #243 +
    ' a mano del servidor?', 'Confirmar retiro a mano') then
    Exit;
  try
    ConfirmarRetiroManual(FConn, FActual.IdProceso, FFicheros[I], FUsuario);
  except
    on E: Exception do
    begin
      TMensajes.Error('No se pudo confirmar: ' + E.Message, 'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  CargarPaso;
end;

procedure TfrmDepuracionNueva.btnCerrarDepClick(Sender: TObject);
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  try
    if not CerrarDepuracion(FConn, FActual.IdProceso, FUsuario) then
    begin
      if FicherosSinResolver(FConn, FActual.IdProceso) > 0 then
        TMensajes.Advertencia('Todav' + #237 + 'a quedan ficheros digitales por retirar o ' +
          'confirmar: ret' + #237 + 'relos antes de cerrar.', 'Depuraci' + #243 + 'n')
      else
        TMensajes.Advertencia('La depuraci' + #243 + 'n ya no est' + #225 + ' en este paso. ' +
          'Se muestra su estado actual.', 'Depuraci' + #243 + 'n');
    end;
  except
    on E: Exception do
    begin
      TMensajes.Error('No se pudo cerrar la depuraci' + #243 + 'n: ' + E.Message,
        'Depuraci' + #243 + 'n');
      Exit;
    end;
  end;
  Recargar;
end;

procedure TfrmDepuracionNueva.btnCancelarDepClick(Sender: TObject);
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  if not TMensajes.Confirmar(#191 + 'Cancelar la depuraci' + #243 + 'n ' + FActual.Numero +
    '? Los documentos quedar' + #225 + 'n libres.', 'Cancelar depuraci' + #243 + 'n') then
    Exit;
  if not CancelarProceso(FConn, FActual.IdProceso, FUsuario, 'Cancelada por el usuario') then
    TMensajes.Advertencia('La depuraci' + #243 + 'n ya no se puede cancelar.',
      'Depuraci' + #243 + 'n');
  Recargar;
end;

procedure TfrmDepuracionNueva.btnEliminarDepClick(Sender: TObject);
begin
  if not PuedeActuarAqui then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  if not TMensajes.Confirmar(#191 + 'Eliminar la depuraci' + #243 + 'n ' + FActual.Numero +
    '? Se borra por completo y no se puede deshacer; los documentos quedar' + #225 +
    'n libres.', 'Eliminar depuraci' + #243 + 'n') then
    Exit;
  if not EliminarProceso(FConn, FActual.IdProceso) then
    TMensajes.Advertencia('La depuraci' + #243 + 'n ya no se puede eliminar.',
      'Depuraci' + #243 + 'n');
  FIdSeleccionado := 0;
  pnlDetalle.Visible := False;
  pnlLista.Visible := True;
  Recargar;
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
  Edita := (Fila.Proceso = epEnCurso) and PuedeActuarAqui;
  btnAvanzar.Visible := Edita and (Fila.Paso <= 3);
  if Fila.Paso = 3 then
    btnAvanzar.Caption := 'Pasar a ejecuci' + #243 + 'n'
  else
    btnAvanzar.Caption := 'Pasar al siguiente paso';
  btnCancelarDep.Visible := Edita and PuedeCancelar(tpDepuracion, Fila.Paso);
  btnEliminarDep.Visible := PuedeActuarAqui and PuedeEliminar(tpDepuracion, Fila.Paso,
    Fila.Proceso);
  lblAviso.Caption := '';
  if Fila.Proceso = epCancelado then
    lblAviso.Caption := 'Esta depuraci' + #243 + 'n est' + #225 + ' cancelada: se conserva ' +
      'solo para consulta.';
  if Fila.Paso >= 5 then
  begin
    if Fila.FEjecucion <> 0 then
      lblE5Texto.Caption := 'Eliminaci' + #243 + 'n ejecutada el ' +
        FormatDateTime('dd/mm/yyyy', Fila.FEjecucion) + '.'
    else
      lblE5Texto.Caption := 'Eliminaci' + #243 + 'n ejecutada.';
    if Fila.Proceso = epFinalizado then
      lblE5Ayuda.Caption := 'La depuraci' + #243 + 'n est' + #225 + ' cerrada.'
    else
      lblE5Ayuda.Caption := 'Imprima el acta y cierre la depuraci' + #243 +
        'n. Los documentos ya figuran como eliminados.';
    btnImprimirActa5.Visible := Assigned(FAlImprimirActa);
    btnCerrarDep.Visible := Edita;
  end;
end;

procedure TfrmDepuracionNueva.pbPasosPaint(Sender: TObject);
begin
  PintarPasos(pbPasos.Canvas, pbPasos.ClientRect, tpDepuracion, FNombresPasos,
    FActual.Paso, FActual.Proceso, FTema, CurrentPPI);
end;

end.
