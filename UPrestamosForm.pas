unit UPrestamosForm;

{ ---------------------------------------------------------------------------
  Pantalla de Prestamos (maquetas A1 y A2 de docs/superpowers/maquetas/
  2026-11-12-procesos-maqueta.html).

  Todo el DISENO esta en UPrestamosForm.dfm (abrir en el IDE para ajustar
  posiciones, tamanos, columnas, fuentes y colores base). Este archivo solo
  llena datos y reacciona a los eventos: no crea controles de diseno.

  Estructura (de arriba a abajo y de izquierda a derecha):
    pnlCabecera   titulo, buscador, Exportar y "Nuevo prestamo"
    pnlIndicadores / pbIndicadores   tarjetas con cifras
    pnlPasos / pbPasos               tira de pasos del prestamo elegido
    pnlPestanas / pbPestanas         pestanas de estado (filtran la lista)
    pnlLista / grdPrestamos          lista de prestamos
    pnlLateral                       a la derecha, a toda la altura:
        pnlFicha   detalle del prestamo elegido y sus acciones
        pnlNuevo   alta de un prestamo (datos del solicitante y documentos)

  Los datos y las reglas salen de UPrestamosDatos y UPrestamosReglas (sin VCL).
  Los tres paneles con TPaintBox se pintan con UProcesoPintura.

  Colores: el .dfm lleva la paleta clara; AplicarTema los adapta al tema en uso
  (claro u oscuro). Se abre embebida en la ventana principal (IPantallaProceso).
  --------------------------------------------------------------------------- }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types,
  System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, dxSkinsCore, dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, dxDateRanges, cxContainer, cxTextEdit,
  cxMaskEdit, cxDropDownEdit, cxCalendar, cxButtons, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGrid,
  FireDAC.Comp.Client, UAlcance, UProceso, UTema, UCandados, UProcesoPintura,
  UPantallaProceso, UPrestamosReglas, UPrestamosDatos;

type
  { Pide imprimir la solicitud (Anexo 8.2) de un prestamo. }
  TImprimirSolicitud = reference to procedure(IdProceso: Integer);
  { Pide imprimir el registro de prestamos (Anexo 8.3) de un ano. }
  TImprimirRegistro = reference to procedure(Anio: Integer);

  TfrmPrestamos = class(TForm, IPantallaProceso)
    pnlLateral: TPanel;
    pnlLateralLinea: TPanel;
    pnlLateralTitulo: TPanel;
    lblLateralTitulo: TLabel;
    lblCerrarLateral: TLabel;
    pnlFicha: TPanel;
    lblFichaEstado: TLabel;
    lblSecSolicitante: TLabel;
    lblFichaSolicitante: TLabel;
    lblFichaDetalle: TLabel;
    lblSecFechas: TLabel;
    lblFichaEntregaTit: TLabel;
    lblFichaEntrega: TLabel;
    lblFichaLimiteTit: TLabel;
    lblFichaLimite: TLabel;
    lblFichaAtendido: TLabel;
    lblSecDocs: TLabel;
    grdFichaDocs: TcxGrid;
    tvFichaDocs: TcxGridTableView;
    colFichaCodigo: TcxGridColumn;
    colFichaTitulo: TcxGridColumn;
    colFichaUbicacion: TcxGridColumn;
    lvFichaDocs: TcxGridLevel;
    lblFichaAccionTit: TLabel;
    dteFichaLimite: TcxDateEdit;
    chkCompleto: TCheckBox;
    edtObservacion: TcxTextEdit;
    pnlFichaAcciones: TPanel;
    btnEntrega: TcxButton;
    btnDevolucion: TcxButton;
    btnRenovar: TcxButton;
    btnImprimir: TcxButton;
    btnCancelarPrestamo: TcxButton;
    pnlNuevo: TScrollBox;
    lblNuevoTipo: TLabel;
    cboTipoUsuario: TcxComboBox;
    lblNuevoLimite: TLabel;
    dteNuevoLimite: TcxDateEdit;
    lblNuevoSolicitante: TLabel;
    edtSolicitante: TcxTextEdit;
    lblNuevoCarnet: TLabel;
    edtCarnet: TcxTextEdit;
    lblNuevoEntidad: TLabel;
    edtEntidad: TcxTextEdit;
    lblNuevoBuscar: TLabel;
    edtBuscarDoc: TcxTextEdit;
    grdBuscarDoc: TcxGrid;
    tvBuscarDoc: TcxGridTableView;
    colBuscarCodigo: TcxGridColumn;
    colBuscarTitulo: TcxGridColumn;
    colBuscarUbicacion: TcxGridColumn;
    colBuscarEstado: TcxGridColumn;
    lvBuscarDoc: TcxGridLevel;
    btnAgregarDoc: TcxButton;
    lblNuevoElegidos: TLabel;
    grdElegidos: TcxGrid;
    tvElegidos: TcxGridTableView;
    colElegidoCodigo: TcxGridColumn;
    colElegidoTitulo: TcxGridColumn;
    lvElegidos: TcxGridLevel;
    lblNuevoAyuda: TLabel;
    lblNuevoError: TLabel;
    pnlNuevoAcciones: TPanel;
    btnGuardarSolicitud: TcxButton;
    btnRegistrarEntrega: TcxButton;
    btnCerrarNuevo: TcxButton;
    pnlPrincipal: TPanel;
    pnlCabecera: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    edtBuscar: TcxTextEdit;
    btnRegistro: TcxButton;
    btnExportar: TcxButton;
    btnNuevo: TcxButton;
    pnlCabeceraAcciones: TPanel;
    pnlCabeceraLinea: TPanel;
    pnlIndicadores: TPanel;
    pbIndicadores: TPaintBox;
    pnlPasos: TPanel;
    pbPasos: TPaintBox;
    pnlPestanas: TPanel;
    pbPestanas: TPaintBox;
    pnlLista: TPanel;
    grdPrestamos: TcxGrid;
    tvPrestamos: TcxGridTableView;
    colIdProceso: TcxGridColumn;
    colNumero: TcxGridColumn;
    colSolicitante: TcxGridColumn;
    colEntidad: TcxGridColumn;
    colUnidades: TcxGridColumn;
    colFecha: TcxGridColumn;
    colLimite: TcxGridColumn;
    colEstado: TcxGridColumn;
    lvPrestamos: TcxGridLevel;
    tmrBuscarLista: TTimer;
    tmrBuscarDoc: TTimer;
    strEstilos: TcxStyleRepository;
    stContenido: TcxStyle;
    stContenidoPeq: TcxStyle;
    stCabeceraGrid: TcxStyle;
    stSeleccion: TcxStyle;
    procedure tvCustomDrawColumnHeader(Sender: TcxGridTableView; ACanvas: TcxCanvas;
      AViewInfo: TcxGridColumnHeaderViewInfo; var ADone: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtBuscarPropertiesChange(Sender: TObject);
    procedure tmrBuscarListaTimer(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure btnRegistroClick(Sender: TObject);
    procedure btnNuevoClick(Sender: TObject);
    procedure pbIndicadoresPaint(Sender: TObject);
    procedure pbPasosPaint(Sender: TObject);
    procedure pbPestanasPaint(Sender: TObject);
    procedure pbPestanasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pbPestanasMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure lblCerrarLateralClick(Sender: TObject);
    procedure tvPrestamosFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure btnEntregaClick(Sender: TObject);
    procedure btnDevolucionClick(Sender: TObject);
    procedure btnRenovarClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure btnCancelarPrestamoClick(Sender: TObject);
    procedure cboTipoUsuarioPropertiesChange(Sender: TObject);
    procedure edtBuscarDocPropertiesChange(Sender: TObject);
    procedure tmrBuscarDocTimer(Sender: TObject);
    procedure tvBuscarDocCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure btnAgregarDocClick(Sender: TObject);
    procedure tvElegidosCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure btnGuardarSolicitudClick(Sender: TObject);
    procedure btnRegistrarEntregaNuevoClick(Sender: TObject);
    procedure btnCerrarNuevoClick(Sender: TObject);
  private
    FConn: TFDConnection;
    FNodos: TArray<TClaveNodo>;
    FNodoActual: TClaveNodo;
    FAlcance: TAlcanceUsuario;
    FUsuario: string;
    FTema: TTemaColores;
    FFiltro: TFiltroPrestamo;
    FFilas: TArray<TPrestamoFila>;
    FIndicadores: TIndicadoresPrestamo;
    FIdSeleccionado: Integer;     // prestamo mostrado en la ficha; 0 = ninguno
    FCargando: Boolean;
    FBuscados: TArray<TDocumentoBuscado>;
    FElegidos: TList<TDocumentoBuscado>;
    FTarjetas: TArray<TIndicadorTarjeta>;
    FPestanas: TArray<TPestanaVista>;
    FRectPestanas: TArray<TRect>;
    FPestanaActiva: Integer;
    FNombresPasos: TArray<string>;
    FPasoActual: Integer;
    FEstadoProceso: TEstadoProceso;
    FEmbebido: Boolean;
    FAlSalir: TNotifyEvent;
    FAlImprimir: TImprimirSolicitud;
    FAlImprimirRegistro: TImprimirRegistro;
    FPuedeActuar: Boolean;
    procedure SetPuedeActuar(Valor: Boolean);
    procedure SetAlImprimirRegistro(const Valor: TImprimirRegistro);
    procedure AplicarTema;
    procedure ConfigurarBoton(B: TcxButton; Primario: Boolean);
    procedure Recargar;
    procedure LlenarLista;
    procedure ActualizarFranjas;
    function PosicionDe(IdProceso: Integer): Integer;
    function FilaActual(out Fila: TPrestamoFila): Boolean;
    procedure MostrarFicha(const Fila: TPrestamoFila);
    procedure CerrarLateral;
    procedure CerrarNuevo;
    procedure AjustarColumnas;
    procedure BuscarDocs;
    procedure LlenarElegidos;
    procedure AgregarSeleccion;
    procedure QuitarSeleccion;
    function LeerSolicitud: TSolicitudPrestamo;
    procedure ProcesarNuevo(Entregar: Boolean);
    function HayNuevoSinGuardar: Boolean;
    procedure ActualizarCamposExterno;
    function TextoUbicacionVacia: string;
    procedure PedirSalir;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Datos con los que trabaja: la conexion, los nodos cuyos prestamos se ven
      (el elegido y sus descendientes), el nodo donde se crean los prestamos
      nuevos, el alcance del usuario (filtra la busqueda de documentos; nil = sin
      filtro) y el usuario que atiende. Carga la lista. }
    procedure Iniciar(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
      const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario; const Usuario: string);
    { Presentacion sin leer la base (la usan Recargar, MostrarFicha y BuscarDocs
      despues de leer, y las pruebas visuales): pone en pantalla la lista y los
      indicadores, la ficha de un prestamo con sus documentos y los resultados de la
      busqueda de documentos. }
    procedure MostrarDatos(const Filas: TArray<TPrestamoFila>;
      const Indicadores: TIndicadoresPrestamo);
    procedure MostrarFichaConDocumentos(const Fila: TPrestamoFila;
      const Docs: TArray<TDocumentoBuscado>);
    procedure MostrarBuscados(const Docs: TArray<TDocumentoBuscado>);
    { Abre el panel de prestamo nuevo (con los campos vacios). }
    procedure MostrarNuevo;
    { IPantallaProceso }
    procedure Embeber(Host: TWinControl);
    function PuedeSalir: Boolean;
    procedure FijarAlSalir(const Valor: TNotifyEvent);
    { Si se asigna, el boton "Imprimir solicitud" llama a este procedimiento. }
    property AlImprimirSolicitud: TImprimirSolicitud read FAlImprimir write FAlImprimir;
    { Si se asigna, el boton "Registro anual" llama a este procedimiento con el ano en curso. }
    property AlImprimirRegistro: TImprimirRegistro read FAlImprimirRegistro write SetAlImprimirRegistro;
    { Solo quien puede prestar en el nodo (el especialista de gestion documental)
      crea prestamos y registra entregas, devoluciones y cancelaciones; los demas
      ven la lista y las fichas. Por defecto, si. }
    property PuedeActuar: Boolean read FPuedeActuar write SetPuedeActuar;
  end;

{ Crea la pantalla ya cargada. Falla si no se puede leer la base. }
function CrearPantallaPrestamos(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario;
  const Usuario: string): TfrmPrestamos;

implementation

{$R *.dfm}

uses
  System.DateUtils, System.Variants, Data.DB, UAparienciaLegacy, UMensajes,
  UExcelExport, UErroresCampo, UProcesosDatos;

const
  // Colores base del .dfm (paleta clara); AplicarTema los cambia en tema oscuro.
  CLARO_TEXTO = TColor(1581355);
  CLARO_SUAVE = TColor(5924725);
  CLARO_ACENTO = TColor(803266);
  CLARO_ERROR = TColor(1975987);
  LIMITE_LISTA = 500;
  LIMITE_BUSQUEDA = 200;

function CrearPantallaPrestamos(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario;
  const Usuario: string): TfrmPrestamos;
begin
  Result := TfrmPrestamos.Create(nil);
  try
    Result.Iniciar(Conn, Nodos, NodoActual, Alcance, Usuario);
  except
    Result.Free;
    raise;
  end;
end;

function FechaTexto(D: TDateTime): string;
begin
  if D = 0 then
    Result := ''
  else
    Result := FormatDateTime('dd/mm/yyyy', D);
end;

{ ------------------------------ construccion ----------------------------- }

constructor TfrmPrestamos.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FElegidos := TList<TDocumentoBuscado>.Create;
  FFiltro := fpTodos;
  FPuedeActuar := True;
  FPestanaActiva := 0;
  FPasoActual := 1;
  FEstadoProceso := epEnCurso;
  FNombresPasos := ['Solicitado', 'Entregado', 'Devuelto'];
  cboTipoUsuario.ItemIndex := 0;
  btnRegistro.Visible := False;
  AplicarTema;
  ActualizarCamposExterno;
end;

destructor TfrmPrestamos.Destroy;
begin
  FElegidos.Free;
  inherited Destroy;
end;

procedure TfrmPrestamos.SetAlImprimirRegistro(const Valor: TImprimirRegistro);
begin
  FAlImprimirRegistro := Valor;
  btnRegistro.Visible := Assigned(Valor);
end;

procedure TfrmPrestamos.btnRegistroClick(Sender: TObject);
begin
  if Assigned(FAlImprimirRegistro) then
    FAlImprimirRegistro(YearOf(Date));
end;

procedure TfrmPrestamos.SetPuedeActuar(Valor: Boolean);
begin
  FPuedeActuar := Valor;
  btnNuevo.Enabled := Valor;
  if FIdSeleccionado <> 0 then
    Recargar;
end;

procedure TfrmPrestamos.Iniciar(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario; const Usuario: string);
begin
  FConn := Conn;
  FNodos := Nodos;
  FNodoActual := NodoActual;
  FAlcance := Alcance;
  FUsuario := Usuario;
  btnImprimir.Visible := Assigned(FAlImprimir);
  Recargar;
end;

{ ---------------------------------- tema --------------------------------- }

procedure TfrmPrestamos.ConfigurarBoton(B: TcxButton; Primario: Boolean);
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

procedure TfrmPrestamos.AplicarTema;
var
  T: TTemaColores;
  P: TPanel;
  I: Integer;
  C: TComponent;
  Claros, Medios, Lineas: TArray<TPanel>;
begin
  FTema := TemaLegacyActual;
  T := FTema;
  Color := T.Fondo;
  pnlIndicadores.Color := T.Fondo;
  pnlPrincipal.Color := T.Fondo;
  Claros := [pnlCabecera, pnlCabeceraAcciones, pnlPasos, pnlPestanas, pnlLateral, pnlLateralTitulo,
    pnlFicha, pnlLista];
  pnlNuevo.Color := T.Superficie;
  Medios := [pnlFichaAcciones, pnlNuevoAcciones];
  Lineas := [pnlCabeceraLinea, pnlLateralLinea];
  for P in Claros do
    P.Color := T.Superficie;
  for P in Medios do
    P.Color := T.Superficie2;
  for P in Lineas do
    P.Color := T.Linea;
  for I := 0 to ComponentCount - 1 do
  begin
    C := Components[I];
    if C is TLabel then
    begin
      if TLabel(C).Font.Color = CLARO_TEXTO then
        TLabel(C).Font.Color := T.Texto
      else if TLabel(C).Font.Color = CLARO_SUAVE then
        TLabel(C).Font.Color := T.TextoSuave
      else if TLabel(C).Font.Color = CLARO_ACENTO then
        TLabel(C).Font.Color := T.Acento
      else if TLabel(C).Font.Color = CLARO_ERROR then
        TLabel(C).Font.Color := ColorError(T);
    end
    else if C is TCheckBox then
      TCheckBox(C).Font.Color := T.Texto
    else if C is TcxCustomEdit then
    begin
      TcxCustomEdit(C).Style.Color := T.Superficie;
      TcxCustomEdit(C).Style.TextColor := T.Texto;
    end;
  end;
  stContenido.Color := T.Superficie;
  stContenido.TextColor := T.Texto;
  stContenidoPeq.Color := T.Superficie;
  stContenidoPeq.TextColor := T.Texto;
  stCabeceraGrid.Color := T.Superficie2;
  stCabeceraGrid.TextColor := T.TextoSuave;
  stSeleccion.Color := T.AcentoSuave;
  stSeleccion.TextColor := T.Texto;
  tvPrestamos.OptionsView.GridLineColor := T.Linea;
  tvFichaDocs.OptionsView.GridLineColor := T.Linea;
  tvBuscarDoc.OptionsView.GridLineColor := T.Linea;
  tvElegidos.OptionsView.GridLineColor := T.Linea;
  ConfigurarBoton(btnNuevo, True);
  ConfigurarBoton(btnExportar, False);
  ConfigurarBoton(btnRegistro, False);
  ConfigurarBoton(btnEntrega, True);
  ConfigurarBoton(btnDevolucion, True);
  ConfigurarBoton(btnRenovar, False);
  ConfigurarBoton(btnImprimir, False);
  ConfigurarBoton(btnCancelarPrestamo, False);
  ConfigurarBoton(btnGuardarSolicitud, False);
  ConfigurarBoton(btnRegistrarEntrega, True);
  ConfigurarBoton(btnCerrarNuevo, False);
  ConfigurarBoton(btnAgregarDoc, False);
  Invalidate;
end;

{ --------------------------- IPantallaProceso ---------------------------- }

procedure TfrmPrestamos.Embeber(Host: TWinControl);
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

function TfrmPrestamos.PuedeSalir: Boolean;
begin
  Result := True;
  if HayNuevoSinGuardar then
    Result := TMensajes.Confirmar('Hay un pr' + #233 + 'stamo sin guardar. ' + #191 +
      'Descartarlo?', 'Pr' + #233 + 'stamos');
end;

procedure TfrmPrestamos.FijarAlSalir(const Valor: TNotifyEvent);
begin
  FAlSalir := Valor;
end;

procedure TfrmPrestamos.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := PuedeSalir;
end;

procedure TfrmPrestamos.PedirSalir;
begin
  if FEmbebido and Assigned(FAlSalir) then
    FAlSalir(Self);
end;

procedure TfrmPrestamos.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key <> VK_ESCAPE then
    Exit;
  Key := 0;
  if pnlNuevo.Visible then
    btnCerrarNuevoClick(nil)
  else if pnlLateral.Visible then
    CerrarLateral
  else
    PedirSalir;
end;

{ --------------------------------- lista --------------------------------- }

function TfrmPrestamos.PosicionDe(IdProceso: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to tvPrestamos.DataController.RecordCount - 1 do
    if VarToStr(tvPrestamos.DataController.Values[I, colIdProceso.Index]) =
      IntToStr(IdProceso) then
      Exit(I);
end;

function TfrmPrestamos.FilaActual(out Fila: TPrestamoFila): Boolean;
var
  F: TPrestamoFila;
begin
  Result := False;
  for F in FFilas do
    if F.IdProceso = FIdSeleccionado then
    begin
      Fila := F;
      Exit(True);
    end;
end;

procedure TfrmPrestamos.MostrarDatos(const Filas: TArray<TPrestamoFila>;
  const Indicadores: TIndicadoresPrestamo);
begin
  FCargando := True;
  try
    FFilas := Filas;
    FIndicadores := Indicadores;
    LlenarLista;
    ActualizarFranjas;
  finally
    FCargando := False;
  end;
end;

procedure TfrmPrestamos.Recargar;
var
  Fila: TPrestamoFila;
  Filas: TArray<TPrestamoFila>;
  Ind: TIndicadoresPrestamo;
begin
  if FConn = nil then
    Exit;
  try
    Filas := ListarPrestamos(FConn, FNodos, FFiltro, Now, Trim(edtBuscar.Text),
      LIMITE_LISTA);
    Ind := IndicadoresPrestamo(FConn, FNodos, Now);
  except
    on E: Exception do
    begin
      Filas := nil;
      FillChar(Ind, SizeOf(Ind), 0);
      TMensajes.Error('No se pudieron leer los pr' + #233 + 'stamos: ' + E.Message,
        'Pr' + #233 + 'stamos');
    end;
  end;
  MostrarDatos(Filas, Ind);
  // la ficha sigue al prestamo elegido (si ya no esta en la lista, se cierra)
  if pnlFicha.Visible and (FIdSeleccionado <> 0) then
  begin
    if FilaActual(Fila) then
      MostrarFicha(Fila)
    else
      CerrarLateral;
  end;
end;

procedure TfrmPrestamos.LlenarLista;
var
  I, Idx: Integer;
  F: TPrestamoFila;
  DC: TcxGridDataController;
begin
  DC := tvPrestamos.DataController;
  tvPrestamos.BeginUpdate;
  try
    DC.RecordCount := Length(FFilas);
    for I := 0 to High(FFilas) do
    begin
      F := FFilas[I];
      DC.Values[I, colIdProceso.Index] := F.IdProceso;
      DC.Values[I, colNumero.Index] := F.Numero;
      DC.Values[I, colSolicitante.Index] := F.Solicitante;
      DC.Values[I, colEntidad.Index] := F.Entidad;
      DC.Values[I, colUnidades.Index] := IntToStr(F.Unidades);
      DC.Values[I, colFecha.Index] := FechaTexto(F.FEntrega);
      DC.Values[I, colLimite.Index] := FechaTexto(F.FLimite);
      DC.Values[I, colEstado.Index] := TextoEstadoPrestamo(F.Visible, F.FLimite, Now);
    end;
  finally
    tvPrestamos.EndUpdate;
  end;
  if FIdSeleccionado <> 0 then
  begin
    Idx := PosicionDe(FIdSeleccionado);
    if Idx >= 0 then
      DC.FocusedRecordIndex := Idx;
  end;
  lblSubtitulo.Caption := IntToStr(FIndicadores.Total) + ' pr' + #233 + 'stamos';
end;

procedure TfrmPrestamos.ActualizarFranjas;
begin
  FTarjetas := [
    Indicador('En pr' + #233 + 'stamo ahora', FIndicadores.EnPrestamo, False),
    Indicador('Vencidos', FIndicadores.Vencidos, True),
    Indicador('Vencen en 3 d' + #237 + 'as', FIndicadores.PorVencer, False),
    Indicador('Devueltos este a' + #241 + 'o', FIndicadores.DevueltosAnio, False)];
  FPestanas := [
    Pestana('Todos', FIndicadores.Total, False),
    Pestana('En pr' + #233 + 'stamo', FIndicadores.EnPrestamo, False),
    Pestana('Vencidos', FIndicadores.Vencidos, True),
    Pestana('Devueltos', FIndicadores.DevueltosAnio, False),
    Pestana('Solicitudes', FIndicadores.Solicitudes, False)];
  pbIndicadores.Invalidate;
  pbPestanas.Invalidate;
end;

procedure TfrmPrestamos.edtBuscarPropertiesChange(Sender: TObject);
begin
  tmrBuscarLista.Enabled := False;
  tmrBuscarLista.Enabled := True;
end;

procedure TfrmPrestamos.tmrBuscarListaTimer(Sender: TObject);
begin
  tmrBuscarLista.Enabled := False;
  Recargar;
end;

procedure TfrmPrestamos.btnExportarClick(Sender: TObject);
begin
  try
    ExcelExport(nil, grdPrestamos);
  except
    on E: Exception do
      TMensajes.Error('No se pudo exportar: ' + E.Message, 'Exportar');
  end;
end;

procedure TfrmPrestamos.tvPrestamosFocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
var
  Id: Integer;
  Fila: TPrestamoFila;
begin
  if FCargando or (AFocusedRecord = nil) then
    Exit;
  if not (AFocusedRecord is TcxGridDataRow) then
    Exit;
  Id := StrToIntDef(VarToStr(AFocusedRecord.Values[colIdProceso.Index]), 0);
  if Id = 0 then
    Exit;
  FIdSeleccionado := Id;
  if FilaActual(Fila) then
  begin
    if HayNuevoSinGuardar and not PuedeSalir then
      Exit;
    MostrarFicha(Fila);
  end;
end;

{ ------------------------------ franjas pintadas ------------------------- }

procedure TfrmPrestamos.pbIndicadoresPaint(Sender: TObject);
begin
  PintarTarjetas(pbIndicadores.Canvas, pbIndicadores.ClientRect, FTarjetas, FTema,
    CurrentPPI);
end;

procedure TfrmPrestamos.pbPestanasPaint(Sender: TObject);
begin
  FRectPestanas := DisenarPestanas(pbPestanas.Canvas, FPestanas, pbPestanas.Height,
    CurrentPPI);
  PintarPestanas(pbPestanas.Canvas, pbPestanas.ClientRect, FPestanas, FRectPestanas,
    FPestanaActiva, FTema, CurrentPPI);
end;

procedure TfrmPrestamos.pbPestanasMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if PestanaEn(FRectPestanas, X, Y) >= 0 then
    pbPestanas.Cursor := crHandPoint
  else
    pbPestanas.Cursor := crDefault;
end;

procedure TfrmPrestamos.pbPestanasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  if Button <> mbLeft then
    Exit;
  I := PestanaEn(FRectPestanas, X, Y);
  if (I < 0) or (I = FPestanaActiva) then
    Exit;
  FPestanaActiva := I;
  case I of
    1: FFiltro := fpEnPrestamo;
    2: FFiltro := fpVencidos;
    3: FFiltro := fpDevueltos;
    4: FFiltro := fpSolicitudes;
  else
    FFiltro := fpTodos;
  end;
  Recargar;
end;

procedure TfrmPrestamos.pbPasosPaint(Sender: TObject);
begin
  PintarPasos(pbPasos.Canvas, pbPasos.ClientRect, tpPrestamo, FNombresPasos,
    FPasoActual, FEstadoProceso, FTema, CurrentPPI);
end;

{ --------------------------------- ficha --------------------------------- }

procedure TfrmPrestamos.MostrarFicha(const Fila: TPrestamoFila);
var
  Docs: TArray<TDocumentoBuscado>;
begin
  try
    Docs := DocumentosDelPrestamo(FConn, Fila.IdProceso);
  except
    on E: Exception do
    begin
      Docs := nil;
      TMensajes.Error('No se pudieron leer los documentos: ' + E.Message,
        'Pr' + #233 + 'stamos');
    end;
  end;
  MostrarFichaConDocumentos(Fila, Docs);
end;

procedure TfrmPrestamos.MostrarFichaConDocumentos(const Fila: TPrestamoFila;
  const Docs: TArray<TDocumentoBuscado>);
var
  D: TDocumentoBuscado;
  I: Integer;
  Detalle, TipoTxt: string;
  Solicitado, Entregado, Cerrado: Boolean;
begin
  FIdSeleccionado := Fila.IdProceso;
  pnlNuevo.Visible := False;
  pnlNuevoAcciones.Visible := False;
  pnlFicha.Visible := True;
  pnlLateral.Visible := True;
  AjustarColumnas;
  lblLateralTitulo.Caption := 'Pr' + #233 + 'stamo ' + Fila.Numero;
  lblFichaEstado.Caption := TextoEstadoPrestamo(Fila.Visible, Fila.FLimite, Now);
  case Fila.Visible of
    epsVencido: lblFichaEstado.Font.Color := ColorError(FTema);
    epsDevuelto: lblFichaEstado.Font.Color := ColorOk(FTema);
    epsCancelado: lblFichaEstado.Font.Color := FTema.TextoSuave;
  else
    lblFichaEstado.Font.Color := FTema.Acento;
  end;
  lblFichaSolicitante.Caption := Fila.Solicitante;
  if Fila.Usuario = tuExterno then
    TipoTxt := 'Externo'
  else
    TipoTxt := 'Interno';
  Detalle := TipoTxt;
  if Trim(Fila.Carnet) <> '' then
    Detalle := Detalle + '  ' + #183 + '  CI ' + Fila.Carnet;
  if Trim(Fila.Entidad) <> '' then
    Detalle := Detalle + '  ' + #183 + '  ' + Fila.Entidad;
  lblFichaDetalle.Caption := Detalle;
  if Fila.FEntrega = 0 then
    lblFichaEntrega.Caption := #8212
  else
    lblFichaEntrega.Caption := FechaTexto(Fila.FEntrega);
  if Fila.Estado = epFinalizado then
  begin
    lblFichaLimiteTit.Caption := 'Devuelto el';
    lblFichaLimite.Caption := FechaTexto(Fila.FDevolucion);
  end
  else
  begin
    lblFichaLimiteTit.Caption := 'Devolver antes del';
    if Fila.FLimite = 0 then
      lblFichaLimite.Caption := 'Sin l' + #237 + 'mite'
    else
      lblFichaLimite.Caption := FechaTexto(Fila.FLimite);
  end;
  if Trim(Fila.AtendidoPor) <> '' then
    lblFichaAtendido.Caption := 'Atendido por ' + Fila.AtendidoPor
  else
    lblFichaAtendido.Caption := '';
  // documentos del prestamo
  tvFichaDocs.BeginUpdate;
  try
    tvFichaDocs.DataController.RecordCount := Length(Docs);
    I := 0;
    for D in Docs do
    begin
      tvFichaDocs.DataController.Values[I, colFichaCodigo.Index] := D.Unidad.CodigoDoc;
      tvFichaDocs.DataController.Values[I, colFichaTitulo.Index] := D.Titulo;
      tvFichaDocs.DataController.Values[I, colFichaUbicacion.Index] := D.Ubicacion;
      Inc(I);
    end;
  finally
    tvFichaDocs.EndUpdate;
  end;
  // tira de pasos
  FPasoActual := Fila.Paso;
  FEstadoProceso := Fila.Estado;
  pnlPasos.Visible := True;
  pbPasos.Invalidate;
  // acciones segun el estado
  Solicitado := (Fila.Estado = epEnCurso) and (Fila.Paso = 1);
  Entregado := (Fila.Estado = epEnCurso) and (Fila.Paso = 2);
  Cerrado := Fila.Estado <> epEnCurso;
  btnEntrega.Visible := Solicitado and FPuedeActuar;
  btnDevolucion.Visible := Entregado and FPuedeActuar;
  btnRenovar.Visible := Entregado and FPuedeActuar;
  btnCancelarPrestamo.Visible := (not Cerrado) and FPuedeActuar;
  btnImprimir.Visible := Assigned(FAlImprimir);
  dteFichaLimite.Visible := (Solicitado or Entregado) and FPuedeActuar;
  lblFichaAccionTit.Visible := (Solicitado or Entregado) and FPuedeActuar;
  chkCompleto.Visible := Entregado and FPuedeActuar;
  edtObservacion.Visible := Entregado and FPuedeActuar;
  if Solicitado then
  begin
    lblFichaAccionTit.Caption := 'Devolver antes del (al entregar)';
    dteFichaLimite.Date := FechaLimiteSugerida(Now, PLAZO_PRESTAMO_DIAS);
  end
  else if Entregado then
  begin
    lblFichaAccionTit.Caption := 'Nueva fecha l' + #237 + 'mite (para renovar)';
    if Fila.FLimite <> 0 then
      dteFichaLimite.Date := Fila.FLimite + PLAZO_PRESTAMO_DIAS
    else
      dteFichaLimite.Date := FechaLimiteSugerida(Now, PLAZO_PRESTAMO_DIAS);
    chkCompleto.Checked := True;
    edtObservacion.Text := '';
  end;
end;

procedure TfrmPrestamos.CerrarLateral;
begin
  pnlLateral.Visible := False;
  pnlPasos.Visible := False;
  FIdSeleccionado := 0;
  AjustarColumnas;
end;

{ Con el panel lateral abierto la lista es mas estrecha: se ocultan las columnas
  menos importantes para que los textos no se partan. }
procedure TfrmPrestamos.AjustarColumnas;
var
  Ancha: Boolean;
begin
  Ancha := not pnlLateral.Visible;
  colEntidad.Visible := Ancha;
  colFecha.Visible := Ancha;
  colUnidades.Visible := Ancha;
end;

{ Cabecera plana, sin los bordes negros del estilo UltraFlat. }
procedure TfrmPrestamos.tvCustomDrawColumnHeader(Sender: TcxGridTableView;
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

procedure TfrmPrestamos.lblCerrarLateralClick(Sender: TObject);
begin
  if pnlNuevo.Visible then
    btnCerrarNuevoClick(nil)
  else
    CerrarLateral;
end;

procedure TfrmPrestamos.btnEntregaClick(Sender: TObject);
var
  Fila: TPrestamoFila;
  Motivo: string;
  Limite: TDateTime;
begin
  if not FilaActual(Fila) then
    Exit;
  if VarIsNull(dteFichaLimite.EditValue) then
    Limite := 0
  else
    Limite := dteFichaLimite.Date;
  if not RegistrarEntrega(FConn, Fila.IdProceso, FUsuario, Now, Limite, Motivo) then
    TMensajes.Advertencia(Motivo, 'Pr' + #233 + 'stamos');
  Recargar;
end;

procedure TfrmPrestamos.btnDevolucionClick(Sender: TObject);
var
  Fila: TPrestamoFila;
begin
  if not FilaActual(Fila) then
    Exit;
  if not TMensajes.Confirmar('Se registra la devoluci' + #243 + 'n de los ' +
    IntToStr(Fila.Unidades) + ' documento(s) del pr' + #233 + 'stamo ' + Fila.Numero +
    '. Los documentos quedar' + #225 + 'n libres.', 'Registrar devoluci' + #243 + 'n') then
    Exit;
  if not RegistrarDevolucion(FConn, Fila.IdProceso, chkCompleto.Checked,
    edtObservacion.Text, FUsuario, Now) then
    TMensajes.Advertencia('El pr' + #233 + 'stamo ya no est' + #225 + ' entregado.',
      'Pr' + #233 + 'stamos');
  Recargar;
end;

procedure TfrmPrestamos.btnRenovarClick(Sender: TObject);
var
  Fila: TPrestamoFila;
begin
  if not FilaActual(Fila) then
    Exit;
  if VarIsNull(dteFichaLimite.EditValue) or
    not RenovarPlazo(FConn, Fila.IdProceso, dteFichaLimite.Date, FUsuario) then
    TMensajes.Advertencia('La nueva fecha debe ser posterior a la fecha l' + #237 +
      'mite actual.', 'Renovar plazo');
  Recargar;
end;

procedure TfrmPrestamos.btnImprimirClick(Sender: TObject);
var
  Fila: TPrestamoFila;
begin
  if Assigned(FAlImprimir) and FilaActual(Fila) then
    FAlImprimir(Fila.IdProceso);
end;

procedure TfrmPrestamos.btnCancelarPrestamoClick(Sender: TObject);
var
  Fila: TPrestamoFila;
begin
  if not FilaActual(Fila) then
    Exit;
  if not TMensajes.Confirmar(#191 + 'Cancelar el pr' + #233 + 'stamo ' + Fila.Numero +
    '? Los documentos quedar' + #225 + 'n libres.', 'Cancelar pr' + #233 + 'stamo') then
    Exit;
  if not CancelarPrestamo(FConn, Fila.IdProceso, 'Cancelado por el usuario', FUsuario) then
    TMensajes.Advertencia('El pr' + #233 + 'stamo ya no se puede cancelar.',
      'Pr' + #233 + 'stamos');
  Recargar;
end;

{ ------------------------------- prestamo nuevo -------------------------- }

function TfrmPrestamos.HayNuevoSinGuardar: Boolean;
begin
  Result := pnlNuevo.Visible and ((Trim(edtSolicitante.Text) <> '') or
    (FElegidos.Count > 0));
end;

function TfrmPrestamos.TextoUbicacionVacia: string;
begin
  Result := 'Sin ubicaci' + #243 + 'n';
end;

procedure TfrmPrestamos.ActualizarCamposExterno;
var
  Externo: Boolean;
begin
  Externo := cboTipoUsuario.ItemIndex = 1;
  edtCarnet.Enabled := Externo;
  edtEntidad.Enabled := Externo;
  if not Externo then
  begin
    edtCarnet.Text := '';
    edtEntidad.Text := '';
  end;
end;

procedure TfrmPrestamos.cboTipoUsuarioPropertiesChange(Sender: TObject);
begin
  ActualizarCamposExterno;
end;

procedure TfrmPrestamos.btnNuevoClick(Sender: TObject);
begin
  MostrarNuevo;
end;

procedure TfrmPrestamos.MostrarNuevo;
begin
  if HayNuevoSinGuardar and not PuedeSalir then
    Exit;
  FIdSeleccionado := 0;
  pnlFicha.Visible := False;
  pnlPasos.Visible := False;
  pnlNuevo.Visible := True;
  pnlNuevoAcciones.Visible := True;
  pnlLateral.Visible := True;
  AjustarColumnas;
  lblLateralTitulo.Caption := 'Nuevo pr' + #233 + 'stamo';
  cboTipoUsuario.ItemIndex := 0;
  edtSolicitante.Text := '';
  edtCarnet.Text := '';
  edtEntidad.Text := '';
  edtBuscarDoc.Text := '';
  dteNuevoLimite.Date := FechaLimiteSugerida(Now, PLAZO_PRESTAMO_DIAS);
  lblNuevoError.Caption := '';
  lblNuevoAyuda.Caption := 'Doble clic en un documento para agregarlo; en la lista ' +
    'de elegidos, para quitarlo.';
  FElegidos.Clear;
  ActualizarCamposExterno;
  LlenarElegidos;
  BuscarDocs;
  edtSolicitante.SetFocus;
end;

procedure TfrmPrestamos.CerrarNuevo;
begin
  pnlNuevo.Visible := False;
  pnlNuevoAcciones.Visible := False;
  FElegidos.Clear;
  pnlLateral.Visible := False;
  AjustarColumnas;
end;

procedure TfrmPrestamos.btnCerrarNuevoClick(Sender: TObject);
begin
  if HayNuevoSinGuardar and not TMensajes.Confirmar('Hay un pr' + #233 +
    'stamo sin guardar. ' + #191 + 'Descartarlo?', 'Pr' + #233 + 'stamos') then
    Exit;
  CerrarNuevo;
end;

procedure TfrmPrestamos.edtBuscarDocPropertiesChange(Sender: TObject);
begin
  tmrBuscarDoc.Enabled := False;
  tmrBuscarDoc.Enabled := True;
end;

procedure TfrmPrestamos.tmrBuscarDocTimer(Sender: TObject);
begin
  tmrBuscarDoc.Enabled := False;
  BuscarDocs;
end;

procedure TfrmPrestamos.BuscarDocs;
var
  Docs: TArray<TDocumentoBuscado>;
begin
  if FConn = nil then
    Exit;
  try
    Docs := BuscarDocumentos(FConn, FNodos, FAlcance, Trim(edtBuscarDoc.Text),
      LIMITE_BUSQUEDA);
  except
    on E: Exception do
    begin
      Docs := nil;
      TMensajes.Error('No se pudo buscar: ' + E.Message, 'Pr' + #233 + 'stamos');
    end;
  end;
  MostrarBuscados(Docs);
end;

procedure TfrmPrestamos.MostrarBuscados(const Docs: TArray<TDocumentoBuscado>);
var
  I: Integer;
  D: TDocumentoBuscado;
  Motivo: string;
  DC: TcxGridDataController;
begin
  FBuscados := Docs;
  DC := tvBuscarDoc.DataController;
  tvBuscarDoc.BeginUpdate;
  try
    DC.RecordCount := Length(FBuscados);
    for I := 0 to High(FBuscados) do
    begin
      D := FBuscados[I];
      DC.Values[I, colBuscarCodigo.Index] := D.Unidad.CodigoDoc;
      DC.Values[I, colBuscarTitulo.Index] := D.Titulo;
      if D.Ubicacion = '' then
        DC.Values[I, colBuscarUbicacion.Index] := TextoUbicacionVacia
      else
        DC.Values[I, colBuscarUbicacion.Index] := D.Ubicacion;
      if D.Bloqueado then
      begin
        PuedeEntrar(D.Bloqueo, True, Motivo);
        DC.Values[I, colBuscarEstado.Index] := Motivo;
      end
      else
        DC.Values[I, colBuscarEstado.Index] := 'Disponible';
    end;
  finally
    tvBuscarDoc.EndUpdate;
  end;
end;

procedure TfrmPrestamos.LlenarElegidos;
var
  I: Integer;
  DC: TcxGridDataController;
begin
  DC := tvElegidos.DataController;
  tvElegidos.BeginUpdate;
  try
    DC.RecordCount := FElegidos.Count;
    for I := 0 to FElegidos.Count - 1 do
    begin
      DC.Values[I, colElegidoCodigo.Index] := FElegidos[I].Unidad.CodigoDoc;
      DC.Values[I, colElegidoTitulo.Index] := FElegidos[I].Titulo;
    end;
  finally
    tvElegidos.EndUpdate;
  end;
  lblNuevoElegidos.Caption := 'Documentos elegidos (' + IntToStr(FElegidos.Count) + ')';
end;

procedure TfrmPrestamos.AgregarSeleccion;
var
  I, J: Integer;
  D: TDocumentoBuscado;
  Motivo: string;
begin
  I := tvBuscarDoc.DataController.FocusedRecordIndex;
  if (I < 0) or (I > High(FBuscados)) then
    Exit;
  D := FBuscados[I];
  if D.Bloqueado then
  begin
    PuedeEntrar(D.Bloqueo, True, Motivo);
    TMensajes.Advertencia('Ese documento no est' + #225 + ' disponible: ' + Motivo + '.',
      'Pr' + #233 + 'stamos');
    Exit;
  end;
  for J := 0 to FElegidos.Count - 1 do
    if ClaveUnidad(FElegidos[J].Unidad) = ClaveUnidad(D.Unidad) then
      Exit;
  FElegidos.Add(D);
  LlenarElegidos;
end;

procedure TfrmPrestamos.QuitarSeleccion;
var
  I: Integer;
begin
  I := tvElegidos.DataController.FocusedRecordIndex;
  if (I < 0) or (I >= FElegidos.Count) then
    Exit;
  FElegidos.Delete(I);
  LlenarElegidos;
end;

procedure TfrmPrestamos.btnAgregarDocClick(Sender: TObject);
begin
  AgregarSeleccion;
end;

procedure TfrmPrestamos.tvBuscarDocCellDblClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  AgregarSeleccion;
  AHandled := True;
end;

procedure TfrmPrestamos.tvElegidosCellDblClick(Sender: TcxCustomGridTableView;
  ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
  AShift: TShiftState; var AHandled: Boolean);
begin
  QuitarSeleccion;
  AHandled := True;
end;

function TfrmPrestamos.LeerSolicitud: TSolicitudPrestamo;
begin
  Result.Solicitante := Trim(edtSolicitante.Text);
  Result.Carnet := Trim(edtCarnet.Text);
  Result.Entidad := Trim(edtEntidad.Text);
  if cboTipoUsuario.ItemIndex = 1 then
    Result.Usuario := tuExterno
  else
    Result.Usuario := tuInterno;
  if VarIsNull(dteNuevoLimite.EditValue) then
    Result.FechaLimite := 0
  else
    Result.FechaLimite := dteNuevoLimite.Date;
end;

procedure TfrmPrestamos.ProcesarNuevo(Entregar: Boolean);
var
  S: TSolicitudPrestamo;
  Errores: TArray<TErrorCampo>;
  R: TProcesoRef;
  D: TDocumentoBuscado;
  Motivo, Fallos: string;
begin
  lblNuevoError.Caption := '';
  S := LeerSolicitud;
  Errores := ValidarSolicitud(S, Date);
  if Length(Errores) > 0 then
  begin
    lblNuevoError.Caption := Errores[0].Mensaje;
    Exit;
  end;
  if Entregar and (FElegidos.Count = 0) then
  begin
    lblNuevoError.Caption := 'Agregue al menos un documento antes de entregar.';
    Exit;
  end;
  Fallos := '';
  try
    R := CrearSolicitud(FConn, FNodoActual, S, FUsuario, YearOf(Date));
    for D in FElegidos do
      if not AgregarDocumento(FConn, R.IdProceso, D.Unidad, Motivo) then
        Fallos := Fallos + sLineBreak + D.Unidad.CodigoDoc + ': ' + Motivo;
    if Entregar and not RegistrarEntrega(FConn, R.IdProceso, FUsuario, Now,
      S.FechaLimite, Motivo) then
      Fallos := Fallos + sLineBreak + 'Entrega: ' + Motivo;
  except
    on E: EPrestamoInvalido do
    begin
      lblNuevoError.Caption := E.Message;
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo guardar el pr' + #233 + 'stamo: ' + E.Message,
        'Pr' + #233 + 'stamos');
      Exit;
    end;
  end;
  if Fallos <> '' then
    TMensajes.Advertencia('El pr' + #233 + 'stamo ' + R.Numero + ' se cre' + #243 +
      ', pero:' + Fallos, 'Pr' + #233 + 'stamos');
  CerrarNuevo;
  FIdSeleccionado := R.IdProceso;
  Recargar;
  // se deja el prestamo recien creado en la ficha
  if PosicionDe(R.IdProceso) >= 0 then
    tvPrestamos.DataController.FocusedRecordIndex := PosicionDe(R.IdProceso);
end;

procedure TfrmPrestamos.btnGuardarSolicitudClick(Sender: TObject);
begin
  ProcesarNuevo(False);
end;

procedure TfrmPrestamos.btnRegistrarEntregaNuevoClick(Sender: TObject);
begin
  ProcesarNuevo(True);
end;

end.
