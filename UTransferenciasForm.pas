unit UTransferenciasForm;

{ ---------------------------------------------------------------------------
  Pantalla de Transferencias, parte del archivo remitente (pasos 1 a 4; maquetas
  B1 a B3 de docs/superpowers/maquetas/2026-11-12-procesos-maqueta.html).

  Todo el DISENO esta en UTransferenciasForm.dfm (abrir en el IDE para ajustarlo).
  Este archivo solo llena datos y reacciona a los eventos.

  Dos vistas dentro del formulario:
    pnlLista    cronograma anual (grdCronograma) y lista de transferencias
                (grdTransferencias); "Nueva transferencia" y "Abrir".
    pnlDetalle  una transferencia: tira de pasos y, debajo, el panel del paso en que
                esta (propuesta, comision, preparacion, entrega) con sus acciones; la
                barra inferior tiene "Pasar al siguiente paso" y "Cancelar".

  Los datos y las reglas salen de UTransferenciasDatos y UTransferenciasReglas (sin
  VCL). Los metodos publicos Mostrar* presentan datos ya leidos: los usa el propio
  codigo despues de leer y las pruebas visuales sin base de datos.

  Colores: el .dfm lleva la paleta clara; AplicarTema los adapta al tema en uso.
  Se abre embebida en la ventana principal (IPantallaProceso).
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
  FireDAC.Comp.Client, UAlcance, UProceso, UTema, UAutorizacion, UProcesoPintura,
  UPantallaProceso, UOpcionNodo, UTransferenciasReglas, UTransferenciasDatos;

type
  { Pide imprimir un impreso de una transferencia. }
  TImprimirTransferencia = reference to procedure(IdProceso: Integer);

  { Lo que se hace con la caja marcada en los pasos 5 y 6. }
  TAccionCaja = (accRecibida, accCuarentena, accFaltante, accResolver, accUbicar);

  TfrmTransferenciasNuevo = class(TForm, IPantallaProceso)
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
    pnlCronograma: TPanel;
    lblCronTitulo: TLabel;
    grdCronograma: TcxGrid;
    tvCronograma: TcxGridTableView;
    colCronUnidad: TcxGridColumn;
    colCronFecha: TcxGridColumn;
    colCronEstado: TcxGridColumn;
    colCronNumero: TcxGridColumn;
    lvCronograma: TcxGridLevel;
    lblProgramar: TLabel;
    dteProgramar: TcxDateEdit;
    btnProgramar: TcxButton;
    pnlTabla: TPanel;
    grdTransferencias: TcxGrid;
    tvTransferencias: TcxGridTableView;
    colIdProceso: TcxGridColumn;
    colNumero: TcxGridColumn;
    colRemitente: TcxGridColumn;
    colDocumentos: TcxGridColumn;
    colCajas: TcxGridColumn;
    colPrevista: TcxGridColumn;
    colPaso: TcxGridColumn;
    colEstado: TcxGridColumn;
    lvTransferencias: TcxGridLevel;
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
    btnCancelarTransf: TcxButton;
    btnEliminarTransf: TcxButton;
    chkAnticipada: TcxCheckBox;
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
    lblP2OrganoVal: TLabel;
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
    pnlP3Der: TPanel;
    lblVerTit: TLabel;
    chkVer1: TCheckBox;
    chkVer2: TCheckBox;
    chkVer3: TCheckBox;
    chkVer4: TCheckBox;
    chkVer5: TCheckBox;
    lblP3Falta: TLabel;
    pnlP3Izq: TPanel;
    pnlP3Barra: TPanel;
    lblCap: TLabel;
    spnCapacidad: TcxSpinEdit;
    btnNumerar: TcxButton;
    pnlP3Rej: TPanel;
    grdCajas: TcxGrid;
    tvCajas: TcxGridTableView;
    colCajaNum: TcxGridColumn;
    colCajaTipo: TcxGridColumn;
    colCajaDesc: TcxGridColumn;
    colCajaFechas: TcxGridColumn;
    colCajaUnid: TcxGridColumn;
    lvCajas: TcxGridLevel;
    pnlPaso4: TPanel;
    lblP4Ayuda: TLabel;
    lblEntFecha: TLabel;
    dteEntrega: TcxDateEdit;
    lblEntPor: TLabel;
    edtEntregadoPor: TcxTextEdit;
    btnRegistrarEntrega: TcxButton;
    btnRelacion: TcxButton;
    btnEtiquetas: TcxButton;
    lblRecFecha: TLabel;
    dteRecepcion: TcxDateEdit;
    lblRecPor: TLabel;
    edtRecibidoPor: TcxTextEdit;
    btnRegistrarRecepcion: TcxButton;
    grdRecep: TcxGrid;
    tvRecep: TcxGridTableView;
    colRecCaja: TcxGridColumn;
    colRecDesc: TcxGridColumn;
    colRecUnid: TcxGridColumn;
    colRecEstado: TcxGridColumn;
    colRecConserv: TcxGridColumn;
    colRecUbic: TcxGridColumn;
    lvRecep: TcxGridLevel;
    pnlRecepcion: TPanel;
    lblRecDestino: TLabel;
    cmbDestino: TcxComboBox;
    lblRecNum: TLabel;
    edtNumRegistro: TcxTextEdit;
    lblConserv: TLabel;
    edtConservacion: TcxTextEdit;
    btnCajaRecibida: TcxButton;
    btnCajaCuarentena: TcxButton;
    btnCajaFaltante: TcxButton;
    btnResolverCuarentena: TcxButton;
    pnlUbicacion: TPanel;
    lblDeposito: TLabel;
    edtDeposito: TcxTextEdit;
    lblGaveta: TLabel;
    edtGaveta: TcxTextEdit;
    lblPosicion: TLabel;
    edtPosicion: TcxTextEdit;
    btnGuardarUbicacion: TcxButton;
    btnCerrarTransf: TcxButton;
    btnRelacion5: TcxButton;
    btnEtiquetas5: TcxButton;
    btnTopografico5: TcxButton;
    lblEntInfo: TLabel;
    pnlPaso5: TPanel;
    lblP5: TLabel;
    strEstilos: TcxStyleRepository;
    stContenido: TcxStyle;
    stContenidoPeq: TcxStyle;
    stCabeceraGrid: TcxStyle;
    stSeleccion: TcxStyle;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure tvCustomDrawColumnHeader(Sender: TcxGridTableView; ACanvas: TcxCanvas;
      AViewInfo: TcxGridColumnHeaderViewInfo; var ADone: Boolean);
    procedure btnNuevaClick(Sender: TObject);
    procedure cboNodoTrabajoPropertiesChange(Sender: TObject);
    procedure btnAbrirClick(Sender: TObject);
    procedure btnProgramarClick(Sender: TObject);
    procedure tvTransferenciasCellDblClick(Sender: TcxCustomGridTableView;
      ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton;
      AShift: TShiftState; var AHandled: Boolean);
    procedure tvTransferenciasFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure btnVolverClick(Sender: TObject);
    procedure pbPasosPaint(Sender: TObject);
    procedure btnAgregarClick(Sender: TObject);
    procedure btnQuitarClick(Sender: TObject);
    procedure btnRegistrarAutClick(Sender: TObject);
    procedure btnNumerarClick(Sender: TObject);
    procedure chkVerClick(Sender: TObject);
    procedure btnRegistrarEntregaClick(Sender: TObject);
    procedure btnRelacionClick(Sender: TObject);
    procedure btnEtiquetasClick(Sender: TObject);
    procedure btnTopograficoClick(Sender: TObject);
    procedure btnAvanzarClick(Sender: TObject);
    procedure btnCancelarTransfClick(Sender: TObject);
    procedure btnEliminarTransfClick(Sender: TObject);
    procedure btnRegistrarRecepcionClick(Sender: TObject);
    procedure tvRecepFocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure btnCajaRecibidaClick(Sender: TObject);
    procedure btnCajaCuarentenaClick(Sender: TObject);
    procedure btnCajaFaltanteClick(Sender: TObject);
    procedure btnResolverCuarentenaClick(Sender: TObject);
    procedure btnGuardarUbicacionClick(Sender: TObject);
    procedure btnCerrarTransfClick(Sender: TObject);
    procedure chkAnticipadaPropertiesChange(Sender: TObject);
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
    FAlImprimirRelacion, FAlImprimirEtiquetas, FAlImprimirTopografico: TImprimirTransferencia;
    FFilas: TArray<TTransferenciaFila>;
    FCrono: TArray<TCronogramaFila>;
    FPropuesta: TArray<TGrupoPropuesto>;
    FAgregados: TArray<TGrupoAgregado>;
    FActual: TTransferenciaFila;
    FIdSeleccionado: Integer;
    FNombresPasos: TArray<string>;
    FActualizando: Boolean;
    FCajasRec: TArray<TCajaFila>;
    FCentrales: TArray<TArchivoCentral>;
    FCajaElegida: Integer;     // numero de la caja marcada (para volver a ella)
    FEnRecepcion, FEnUbicacion: Boolean;
    procedure SetPuedeActuar(Valor: Boolean);
    procedure SetAlImprimirRelacion(const Valor: TImprimirTransferencia);
    procedure SetAlImprimirEtiquetas(const Valor: TImprimirTransferencia);
    procedure SetAlImprimirTopografico(const Valor: TImprimirTransferencia);
    procedure AplicarTema;
    procedure ConfigurarBoton(B: TcxButton; Primario: Boolean);
    procedure Recargar;
    procedure AbrirDetalle(const Fila: TTransferenciaFila);
    procedure RefrescarDetalle;
    procedure CargarPaso;
    procedure VolverALista;
    function FilaDeLista(IdProceso: Integer; out Fila: TTransferenciaFila): Boolean;
    function IdDeLaFilaElegida: Integer;
    procedure ActualizarFaltantes;
    procedure MostrarPostEntrega(const Fila: TTransferenciaFila; Edita: Boolean);
    function CajaElegida(out C: TCajaFila): Boolean;
    procedure MostrarCajaElegida;
    procedure ActuarEnCaja(Accion: TAccionCaja);
    procedure PedirSalir;
    procedure AvisarSinPermiso;
    function Casilla(I: Integer): TCheckBox;
  public
    constructor Create(AOwner: TComponent); override;
    { Conexion, nodos cuyas transferencias se ven (el elegido y sus descendientes),
      nodo donde se crean las nuevas, alcance del usuario y usuario. Carga la lista. }
    procedure Iniciar(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
      const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario; const Usuario: string);
    { Nodos donde el usuario puede crear transferencias (los arma la ventana
      principal) y el nodo que se prefiere elegir. Sin ninguno, la pantalla es de
      solo consulta. }
    procedure FijarNodosDeTrabajo(const Opciones: TArray<TOpcionNodo>;
      const Preferido: TClaveNodo);
    { Presentacion sin leer la base (la usan los metodos que leen y las pruebas
      visuales). }
    procedure MostrarLista(const Filas: TArray<TTransferenciaFila>;
      const Cronograma: TArray<TCronogramaFila>);
    procedure MostrarDetalle(const Fila: TTransferenciaFila);
    procedure MostrarPropuesta(const Grupos: TArray<TGrupoPropuesto>);
    procedure MostrarAgregados(const Grupos: TArray<TGrupoAgregado>);
    procedure MostrarAutorizacion(Hay: Boolean; const A: TAutorizacion);
    procedure MostrarCajas(const Lineas: TArray<TLineaRelacion>);
    procedure MostrarVerificaciones(const Marcadas: array of string;
      const Faltan: TArray<string>);
    procedure MostrarEntrega(const Fila: TTransferenciaFila);
    { Pasos 5 y 6: archivos centrales que pueden recibir y cajas con su estado y
      ubicacion (presentacion sin leer la base). }
    procedure MostrarArchivosCentrales(const Lista: TArray<TArchivoCentral>);
    procedure MostrarCajasRecepcion(const Cajas: TArray<TCajaFila>);
    { IPantallaProceso }
    procedure Embeber(Host: TWinControl);
    function PuedeSalir: Boolean;
    procedure FijarAlSalir(const Valor: TNotifyEvent);
    { Solo quien puede transferir en el nodo (el especialista de gestion documental)
      crea transferencias y cambia su estado; los demas ven. Por defecto, si. }
    property PuedeActuar: Boolean read FPuedeActuar write SetPuedeActuar;
    property AlImprimirRelacion: TImprimirTransferencia read FAlImprimirRelacion
      write SetAlImprimirRelacion;
    property AlImprimirEtiquetas: TImprimirTransferencia read FAlImprimirEtiquetas
      write SetAlImprimirEtiquetas;
    { Registro topografico (Anexo 18): se ofrece desde la ubicacion (paso 6). }
    property AlImprimirTopografico: TImprimirTransferencia read FAlImprimirTopografico
      write SetAlImprimirTopografico;
  end;

function CrearPantallaTransferencias(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario;
  const Usuario: string): TfrmTransferenciasNuevo;

implementation

{$R *.dfm}

uses
  System.DateUtils, System.Variants, Data.DB, UAparienciaLegacy, UMensajes,
  UProcesosDatos;

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

function CrearPantallaTransferencias(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario;
  const Usuario: string): TfrmTransferenciasNuevo;
begin
  Result := TfrmTransferenciasNuevo.Create(nil);
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

function RangoTexto(Desde, Hasta: TDateTime): string;
begin
  if (Desde = 0) and (Hasta = 0) then
    Result := ''
  else if Trunc(Desde) = Trunc(Hasta) then
    Result := FechaTexto(Desde)
  else
    Result := FechaTexto(Desde) + ' - ' + FechaTexto(Hasta);
end;

function TextoEstadoCrono(E: TEstadoCronograma): string;
begin
  case E of
    ecProgramada: Result := 'Programada';
    ecAtrasada: Result := 'Atrasada';
    ecEnTramite: Result := 'En tr' + #225 + 'mite';
    ecRealizada: Result := 'Realizada';
  else
    Result := '';
  end;
end;

{ ------------------------------ construccion ----------------------------- }

constructor TfrmTransferenciasNuevo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPuedeActuar := True;
  FAnio := YearOf(Date);
  FNombresPasos := ['Propuesta', 'Comisi' + #243 + 'n', 'Preparaci' + #243 + 'n', 'Entrega',
    'Recepci' + #243 + 'n', 'Ubicaci' + #243 + 'n'];
  dteProgramar.Date := Date + 30;
  dteAutorizacion.Date := Date;
  dteEntrega.Date := Date;
  dteRecepcion.Date := Date;
  btnRelacion.Visible := False;
  btnEtiquetas.Visible := False;
  btnRelacion5.Visible := False;
  btnEtiquetas5.Visible := False;
  btnTopografico5.Visible := False;
  lblNodoTrab.Visible := False;
  cboNodoTrabajo.Visible := False;
  AplicarTema;
end;

procedure TfrmTransferenciasNuevo.Iniciar(Conn: TFDConnection;
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

procedure TfrmTransferenciasNuevo.SetPuedeActuar(Valor: Boolean);
begin
  FPuedeActuar := Valor;
  if pnlDetalle.Visible then
    MostrarDetalle(FActual);
end;

procedure TfrmTransferenciasNuevo.FijarNodosDeTrabajo(const Opciones: TArray<TOpcionNodo>;
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

procedure TfrmTransferenciasNuevo.cboNodoTrabajoPropertiesChange(Sender: TObject);
var
  I: Integer;
begin
  I := cboNodoTrabajo.ItemIndex;
  if (I >= 0) and (I <= High(FOpciones)) then
    FNodoActual := FOpciones[I].Clave;
end;

procedure TfrmTransferenciasNuevo.SetAlImprimirRelacion(const Valor: TImprimirTransferencia);
begin
  FAlImprimirRelacion := Valor;
  btnRelacion.Visible := Assigned(Valor);
  btnRelacion5.Visible := Assigned(Valor);
end;

procedure TfrmTransferenciasNuevo.SetAlImprimirEtiquetas(const Valor: TImprimirTransferencia);
begin
  FAlImprimirEtiquetas := Valor;
  btnEtiquetas.Visible := Assigned(Valor);
  btnEtiquetas5.Visible := Assigned(Valor);
end;

procedure TfrmTransferenciasNuevo.SetAlImprimirTopografico(const Valor: TImprimirTransferencia);
begin
  FAlImprimirTopografico := Valor;
  btnTopografico5.Visible := Assigned(Valor) and (FActual.Paso >= 6);
end;

procedure TfrmTransferenciasNuevo.btnTopograficoClick(Sender: TObject);
begin
  if Assigned(FAlImprimirTopografico) then
    FAlImprimirTopografico(FActual.IdProceso);
end;

{ ---------------------------------- tema --------------------------------- }

procedure TfrmTransferenciasNuevo.ConfigurarBoton(B: TcxButton; Primario: Boolean);
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

procedure TfrmTransferenciasNuevo.AplicarTema;
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
      ConfigurarBoton(TcxButton(C), (C = btnNueva) or (C = btnAgregar) or
        (C = btnRegistrarAut) or (C = btnNumerar) or (C = btnRegistrarEntrega) or
        (C = btnAvanzar));
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
procedure TfrmTransferenciasNuevo.tvCustomDrawColumnHeader(Sender: TcxGridTableView;
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

procedure TfrmTransferenciasNuevo.Embeber(Host: TWinControl);
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

function TfrmTransferenciasNuevo.PuedeSalir: Boolean;
begin
  Result := True;   // todo se guarda al momento: nunca hay cambios pendientes
end;

procedure TfrmTransferenciasNuevo.FijarAlSalir(const Valor: TNotifyEvent);
begin
  FAlSalir := Valor;
end;

procedure TfrmTransferenciasNuevo.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := PuedeSalir;
end;

{ El boton responde siempre: si el rol no puede transferir, se explica por que. }
procedure TfrmTransferenciasNuevo.AvisarSinPermiso;
begin
  TMensajes.Informacion('Su usuario no es especialista de gesti' + #243 + 'n documental ' +
    '(EGD) de ning' + #250 + 'n ' + #225 + 'rea, as' + #237 + ' que solo puede consultar las ' +
    'transferencias. Un administrador asigna los EGD en Administraci' + #243 + 'n de usuarios.',
    'Transferencias');
end;

procedure TfrmTransferenciasNuevo.PedirSalir;
begin
  if FEmbebido and Assigned(FAlSalir) then
    FAlSalir(Self);
end;

procedure TfrmTransferenciasNuevo.FormKeyDown(Sender: TObject; var Key: Word;
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

procedure TfrmTransferenciasNuevo.Recargar;
var
  Filas: TArray<TTransferenciaFila>;
  Crono: TArray<TCronogramaFila>;
begin
  if FConn = nil then
    Exit;
  try
    Filas := ListarTransferencias(FConn, FNodos, FAnio, LIMITE_LISTA);
    Crono := ListarCronograma(FConn, FNodos, FAnio, Now);
  except
    on E: Exception do
    begin
      Filas := nil;
      Crono := nil;
      TMensajes.Error('No se pudieron leer las transferencias: ' + E.Message,
        'Transferencias');
    end;
  end;
  MostrarLista(Filas, Crono);
  if pnlDetalle.Visible and (FIdSeleccionado <> 0) then
    RefrescarDetalle;
end;

procedure TfrmTransferenciasNuevo.MostrarLista(const Filas: TArray<TTransferenciaFila>;
  const Cronograma: TArray<TCronogramaFila>);
var
  I: Integer;
  F: TTransferenciaFila;
  K: TCronogramaFila;
  DC: TcxGridDataController;
  Num: string;
begin
  FFilas := Filas;
  FCrono := Cronograma;
  FActualizando := True;
  try
    DC := tvTransferencias.DataController;
    tvTransferencias.BeginUpdate;
    try
      DC.RecordCount := Length(Filas);
      for I := 0 to High(Filas) do
      begin
        F := Filas[I];
        DC.Values[I, colIdProceso.Index] := F.IdProceso;
        DC.Values[I, colNumero.Index] := F.Numero;
        DC.Values[I, colRemitente.Index] := F.Remitente;
        DC.Values[I, colDocumentos.Index] := IntToStr(F.Unidades);
        DC.Values[I, colCajas.Index] := IntToStr(F.Cajas);
        DC.Values[I, colPrevista.Index] := FechaTexto(F.FPrevista);
        DC.Values[I, colPaso.Index] := IntToStr(F.Paso) + ' de 6';
        DC.Values[I, colEstado.Index] := F.Estado;
      end;
    finally
      tvTransferencias.EndUpdate;
    end;
    DC := tvCronograma.DataController;
    tvCronograma.BeginUpdate;
    try
      DC.RecordCount := Length(Cronograma);
      for I := 0 to High(Cronograma) do
      begin
        K := Cronograma[I];
        DC.Values[I, colCronUnidad.Index] := K.Etiqueta;
        DC.Values[I, colCronFecha.Index] := FechaTexto(K.FPrevista);
        DC.Values[I, colCronEstado.Index] := TextoEstadoCrono(K.Estado);
        Num := '';
        for F in Filas do
          if F.IdProceso = K.IdProceso then
            Num := F.Numero;
        DC.Values[I, colCronNumero.Index] := Num;
      end;
    finally
      tvCronograma.EndUpdate;
    end;
  finally
    FActualizando := False;
  end;
  lblSubtitulo.Caption := IntToStr(Length(Filas)) + ' transferencias ' + #183 + ' ' +
    IntToStr(FAnio);
  lblCronTitulo.Caption := 'CRONOGRAMA ' + IntToStr(FAnio) +
    ' (UNA TRANSFERENCIA POR UNIDAD)';
end;

function TfrmTransferenciasNuevo.FilaDeLista(IdProceso: Integer;
  out Fila: TTransferenciaFila): Boolean;
var
  F: TTransferenciaFila;
begin
  Result := False;
  for F in FFilas do
    if F.IdProceso = IdProceso then
    begin
      Fila := F;
      Exit(True);
    end;
end;

function TfrmTransferenciasNuevo.IdDeLaFilaElegida: Integer;
var
  I: Integer;
begin
  Result := 0;
  I := tvTransferencias.DataController.FocusedRecordIndex;
  if I < 0 then
    Exit;
  Result := StrToIntDef(VarToStr(tvTransferencias.DataController.Values[I,
    colIdProceso.Index]), 0);
end;

procedure TfrmTransferenciasNuevo.tvTransferenciasFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  // la fila elegida solo se usa al pulsar "Abrir" o con doble clic
end;

procedure TfrmTransferenciasNuevo.tvTransferenciasCellDblClick(
  Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo;
  AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
begin
  btnAbrirClick(nil);
  AHandled := True;
end;

procedure TfrmTransferenciasNuevo.btnAbrirClick(Sender: TObject);
var
  F: TTransferenciaFila;
begin
  if FilaDeLista(IdDeLaFilaElegida, F) then
    AbrirDetalle(F)
  else
    TMensajes.Informacion('Elija una transferencia de la lista.', 'Transferencias');
end;

procedure TfrmTransferenciasNuevo.btnNuevaClick(Sender: TObject);
var
  R: TProcesoRef;
begin
  if not FPuedeActuar then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  if not TMensajes.Confirmar('Se crea una transferencia nueva del ' + #225 + 'rea elegida. ' +
    #191 + 'Continuar?', 'Nueva transferencia') then
    Exit;
  try
    R := CrearTransferencia(FConn, FNodoActual, FUsuario, FAnio, 0);
  except
    on E: Exception do
    begin
      TMensajes.Error('No se pudo crear la transferencia: ' + E.Message, 'Transferencias');
      Exit;
    end;
  end;
  FIdSeleccionado := R.IdProceso;
  Recargar;
  RefrescarDetalle;
end;

procedure TfrmTransferenciasNuevo.btnProgramarClick(Sender: TObject);
begin
  if not FPuedeActuar then
  begin
    AvisarSinPermiso;
    Exit;
  end;
  if VarIsNull(dteProgramar.EditValue) then
  begin
    TMensajes.Advertencia('Indique la fecha prevista.', 'Cronograma');
    Exit;
  end;
  try
    ProgramarTransferencia(FConn, FNodoActual, FAnio, dteProgramar.Date);
  except
    on E: Exception do
      TMensajes.Error('No se pudo programar: ' + E.Message, 'Cronograma');
  end;
  Recargar;
end;

{ -------------------------------- detalle -------------------------------- }

procedure TfrmTransferenciasNuevo.AbrirDetalle(const Fila: TTransferenciaFila);
begin
  FActual := Fila;
  FIdSeleccionado := Fila.IdProceso;
  MostrarDetalle(Fila);
  CargarPaso;
end;

procedure TfrmTransferenciasNuevo.RefrescarDetalle;
var
  F: TTransferenciaFila;
begin
  if FilaDeLista(FIdSeleccionado, F) then
    AbrirDetalle(F)
  else
    VolverALista;
end;

procedure TfrmTransferenciasNuevo.VolverALista;
begin
  pnlDetalle.Visible := False;
  pnlLista.Visible := True;
  FIdSeleccionado := 0;
end;

procedure TfrmTransferenciasNuevo.btnVolverClick(Sender: TObject);
begin
  VolverALista;
end;

{ " el dd/mm/aaaa" si la transferencia ya tiene fecha de entrega. }
function FechaEntrega(const Fila: TTransferenciaFila): string;
begin
  if Fila.FEntrega = 0 then
    Result := ''
  else
    Result := ' el ' + FechaTexto(Fila.FEntrega);
end;

procedure TfrmTransferenciasNuevo.MostrarDetalle(const Fila: TTransferenciaFila);
var
  EnCurso, Edita: Boolean;
begin
  FActual := Fila;
  pnlLista.Visible := False;
  pnlDetalle.Visible := True;
  lblDetTitulo.Caption := 'Transferencia ' + Fila.Numero;
  lblDetSub.Caption := Fila.Remitente + '  ' + #183 + '  ' + Fila.Estado;
  pbPasos.Invalidate;
  pnlPaso1.Visible := (Fila.Paso = 1);
  pnlPaso2.Visible := (Fila.Paso = 2);
  pnlPaso3.Visible := (Fila.Paso = 3);
  pnlPaso4.Visible := (Fila.Paso = 4);
  pnlPaso5.Visible := (Fila.Paso >= 5);
  EnCurso := Fila.Proceso = epEnCurso;
  Edita := EnCurso and FPuedeActuar;
  btnAvanzar.Visible := Edita and (Fila.Paso <= 3);
  btnCancelarTransf.Visible := Edita and PuedeCancelar(tpTransferencia, Fila.Paso);
  btnEliminarTransf.Visible := FPuedeActuar and PuedeEliminar(tpTransferencia, Fila.Paso, Fila.Proceso);
  btnAgregar.Enabled := Edita;
  btnQuitar.Enabled := Edita;
  btnRegistrarAut.Enabled := Edita;
  edtActa.Enabled := Edita;
  edtAcuerdo.Enabled := Edita;
  dteAutorizacion.Enabled := Edita;
  btnNumerar.Enabled := Edita;
  spnCapacidad.Enabled := Edita;
  chkVer1.Enabled := Edita;
  chkVer2.Enabled := Edita;
  chkVer3.Enabled := Edita;
  chkVer4.Enabled := Edita;
  chkVer5.Enabled := Edita;
  btnRegistrarEntrega.Enabled := Edita;
  edtEntregadoPor.Enabled := Edita;
  dteEntrega.Enabled := Edita;
  lblAviso.Caption := '';
  MostrarEntrega(Fila);
  if Fila.Paso >= 5 then
    MostrarPostEntrega(Fila, Edita);
end;

{ Pasos 5 y 6: recepcion en el archivo central y ubicacion de las cajas. Cada
  seccion solo se edita en su paso; despues se muestra lo registrado. }
procedure TfrmTransferenciasNuevo.MostrarPostEntrega(const Fila: TTransferenciaFila;
  Edita: Boolean);
var
  Estados: TArray<TEstadoCaja>;
  I: Integer;
begin
  FEnRecepcion := Edita and (Fila.Paso = 5);
  FEnUbicacion := Edita and (Fila.Paso = 6);
  pnlRecepcion.Visible := (Fila.Paso = 5);
  pnlUbicacion.Visible := (Fila.Paso >= 6);
  lblRecDestino.Enabled := FEnRecepcion;
  cmbDestino.Enabled := FEnRecepcion;
  lblRecNum.Enabled := FEnRecepcion;
  edtNumRegistro.Enabled := FEnRecepcion;
  lblRecFecha.Enabled := FEnRecepcion;
  dteRecepcion.Enabled := FEnRecepcion;
  lblRecPor.Enabled := FEnRecepcion;
  edtRecibidoPor.Enabled := FEnRecepcion;
  btnRegistrarRecepcion.Visible := FEnRecepcion;
  btnCerrarTransf.Visible := FEnUbicacion;
  btnTopografico5.Visible := Assigned(FAlImprimirTopografico) and (Fila.Paso >= 6);
  if Fila.FRecepcion <> 0 then
    dteRecepcion.Date := Fila.FRecepcion;
  if Fila.RecibidoPor <> '' then
    edtRecibidoPor.Text := Fila.RecibidoPor;
  if Fila.Proceso = epFinalizado then
    lblP5.Caption := 'Transferencia completada. Entregada' + FechaEntrega(Fila) +
      ', recibida el ' + FechaTexto(Fila.FRecepcion) + ' por ' + Fila.RecibidoPor +
      '. Los documentos de las cajas recibidas pasaron al archivo central.'
  else if Fila.Paso = 5 then
    lblP5.Caption := 'La transferencia fue entregada' + FechaEntrega(Fila) + '. Marque cada ' +
      'caja como recibida, en cuarentena o que no lleg' + #243 + ', elija el archivo central ' +
      'y registre la recepci' + #243 + 'n.'
  else
    lblP5.Caption := 'Recibida el ' + FechaTexto(Fila.FRecepcion) + ' por ' + Fila.RecibidoPor +
      '. Indique d' + #243 + 'nde queda cada caja recibida y finalice la transferencia: sus ' +
      'documentos pasar' + #225 + 'n al archivo central.';
  MostrarCajaElegida;
end;
procedure TfrmTransferenciasNuevo.pbPasosPaint(Sender: TObject);
begin
  PintarPasos(pbPasos.Canvas, pbPasos.ClientRect, tpTransferencia, FNombresPasos,
    FActual.Paso, FActual.Proceso, FTema, CurrentPPI);
end;

function TfrmTransferenciasNuevo.Casilla(I: Integer): TCheckBox;
begin
  case I of
    0: Result := chkVer1;
    1: Result := chkVer2;
    2: Result := chkVer3;
    3: Result := chkVer4;
  else
    Result := chkVer5;
  end;
end;

{ Lee de la base lo que muestra el panel del paso actual. }
procedure TfrmTransferenciasNuevo.CargarPaso;
var
  Aut: TAutorizacion;
  Hay: Boolean;
  Faltan: TArray<string>;
  Cajas: TArray<TLineaRelacion>;
begin
  if FConn = nil then
    Exit;
  try
    case FActual.Paso of
      5, 6:
        begin
          MostrarArchivosCentrales(ListarArchivosCentrales(FConn));
          MostrarCajasRecepcion(CajasDeTransferencia(FConn, FActual.IdProceso));
        end;
      1:
        begin
          MostrarAgregados(GruposDeLaTransferencia(FConn, FActual.IdProceso));
          // solo las series del area (nodo) de esta transferencia
          MostrarPropuesta(ProponerTransferencia(FConn, [FActual.Nodo], Now,
            chkAnticipada.Checked));
        end;
      2:
        begin
          Hay := LeerAutorizacion(FConn, FActual.IdProceso, Aut);
          MostrarAutorizacion(Hay, Aut);
        end;
      3, 4:
        begin
          Cajas := RelacionDeEntrega(FConn, FActual.IdProceso);
          MostrarCajas(Cajas);
          CondicionesCumplidas(FConn, FActual.IdProceso, Faltan);
          MostrarVerificaciones(VerificacionesMarcadas(FConn, FActual.IdProceso), Faltan);
        end;
    end;
  except
    on E: Exception do
      TMensajes.Error('No se pudieron leer los datos de la transferencia: ' + E.Message,
        'Transferencias');
  end;
end;

procedure TfrmTransferenciasNuevo.MostrarPropuesta(const Grupos: TArray<TGrupoPropuesto>);
var
  I: Integer;
  G: TGrupoPropuesto;
  DC: TcxGridDataController;
  Obs: string;
begin
  FPropuesta := Grupos;
  DC := tvPropuesta.DataController;
  tvPropuesta.BeginUpdate;
  try
    DC.RecordCount := Length(Grupos);
    for I := 0 to High(Grupos) do
    begin
      G := Grupos[I];
      DC.Values[I, colPropSerie.Index] := G.Serie + ' ' + #183 + ' ' + G.Subserie;
      if G.Anios > 0 then
        DC.Values[I, colPropAnios.Index] := IntToStr(G.Anios) + ' a' + #241 + 'os'
      else
        DC.Values[I, colPropAnios.Index] := 'sin plazo';
      DC.Values[I, colPropUnidades.Index] := IntToStr(G.Unidades);
      DC.Values[I, colPropFechas.Index] := RangoTexto(G.Desde, G.Hasta);
      Obs := '';
      if G.Anticipada then
        Obs := 'Antes de vencer el plazo';
      if G.Retenidos > 0 then
        Obs := Trim(Obs + '  ' + IntToStr(G.Retenidos) + ' en pr' + #233 + 'stamo u otro proceso');
      DC.Values[I, colPropObs.Index] := Obs;
    end;
  finally
    tvPropuesta.EndUpdate;
  end;
end;

procedure TfrmTransferenciasNuevo.MostrarAgregados(const Grupos: TArray<TGrupoAgregado>);
var
  I: Integer;
  G: TGrupoAgregado;
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
      DC.Values[I, colAgrFechas.Index] := RangoTexto(G.Desde, G.Hasta);
    end;
  finally
    tvAgregados.EndUpdate;
  end;
end;

procedure TfrmTransferenciasNuevo.MostrarAutorizacion(Hay: Boolean; const A: TAutorizacion);
begin
  lblAutError.Caption := '';
  if Hay then
  begin
    edtActa.Text := A.NumActa;
    edtAcuerdo.Text := A.NumAcuerdo;
    if A.Fecha <> 0 then
      dteAutorizacion.Date := A.Fecha;
    lblAutRegistrada.Caption := 'Autorizaci' + #243 + 'n registrada: acta ' + A.NumActa +
      ', acuerdo ' + A.NumAcuerdo + ' (' + FechaTexto(A.Fecha) + ').';
  end
  else
    lblAutRegistrada.Caption := '';
end;

procedure TfrmTransferenciasNuevo.MostrarCajas(const Lineas: TArray<TLineaRelacion>);
var
  I: Integer;
  L: TLineaRelacion;
  DC: TcxGridDataController;
begin
  DC := tvCajas.DataController;
  tvCajas.BeginUpdate;
  try
    DC.RecordCount := Length(Lineas);
    for I := 0 to High(Lineas) do
    begin
      L := Lineas[I];
      DC.Values[I, colCajaNum.Index] := IntToStr(L.Caja);
      DC.Values[I, colCajaTipo.Index] := L.Tipo;
      DC.Values[I, colCajaDesc.Index] := L.Descripcion;
      DC.Values[I, colCajaFechas.Index] := RangoTexto(L.Desde, L.Hasta);
      DC.Values[I, colCajaUnid.Index] := IntToStr(L.Unidades);
    end;
  finally
    tvCajas.EndUpdate;
  end;
end;

procedure TfrmTransferenciasNuevo.MostrarVerificaciones(const Marcadas: array of string;
  const Faltan: TArray<string>);
var
  I: Integer;
  M, Texto: string;
  Marcada: Boolean;
begin
  FActualizando := True;
  try
    for I := 0 to High(VERIFICACIONES) do
    begin
      Marcada := False;
      for M in Marcadas do
        if SameText(M, VERIFICACIONES[I].Codigo) then
          Marcada := True;
      Casilla(I).Checked := Marcada;
    end;
  finally
    FActualizando := False;
  end;
  Texto := '';
  for M in Faltan do
  begin
    if Texto <> '' then
      Texto := Texto + sLineBreak;
    Texto := Texto + #8226 + ' ' + M;
  end;
  lblP3Falta.Caption := Texto;
end;

procedure TfrmTransferenciasNuevo.MostrarEntrega(const Fila: TTransferenciaFila);
begin
  lblEntInfo.Caption := IntToStr(Fila.Unidades) + ' documento(s) en ' + IntToStr(Fila.Cajas) +
    ' caja(s).';
  if Fila.FEntrega <> 0 then
    lblEntInfo.Caption := lblEntInfo.Caption + '  Entregada el ' + FechaTexto(Fila.FEntrega) + '.';
end;

{ -------------------------------- acciones -------------------------------- }

procedure TfrmTransferenciasNuevo.ActualizarFaltantes;
var
  Faltan: TArray<string>;
begin
  CondicionesCumplidas(FConn, FActual.IdProceso, Faltan);
  MostrarVerificaciones(VerificacionesMarcadas(FConn, FActual.IdProceso), Faltan);
end;

procedure TfrmTransferenciasNuevo.btnAgregarClick(Sender: TObject);
var
  I, Idx, Total, Agregados: Integer;
  Motivo, Problemas: string;
begin
  if tvPropuesta.Controller.SelectedRecordCount = 0 then
  begin
    TMensajes.Informacion('Marque las series que quiere agregar.', 'Transferencias');
    Exit;
  end;
  if chkAnticipada.Checked and not TMensajes.Confirmar('Est' + #225 + ' transfiriendo antes de que ' +
    'venza el plazo en el archivo de gesti' + #243 + 'n, lo que el Manual no prev' + #233 +
    ' en el curso normal. ' + #191 + 'Desea continuar?', 'Transferencia anticipada') then
    Exit;
  Total := 0;
  Problemas := '';
  for I := 0 to tvPropuesta.Controller.SelectedRecordCount - 1 do
  begin
    Idx := tvPropuesta.Controller.SelectedRecords[I].RecordIndex;
    if (Idx < 0) or (Idx > High(FPropuesta)) then
      Continue;
    try
      if AgregarGrupo(FConn, FActual.IdProceso, FPropuesta[Idx], Now, Agregados, Motivo) then
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
      Problemas, 'Transferencias');
  Recargar;
end;

procedure TfrmTransferenciasNuevo.btnQuitarClick(Sender: TObject);
var
  I: Integer;
  G: TGrupoAgregado;
begin
  I := tvAgregados.DataController.FocusedRecordIndex;
  if (I < 0) or (I > High(FAgregados)) then
  begin
    TMensajes.Informacion('Elija la serie que quiere quitar.', 'Transferencias');
    Exit;
  end;
  G := FAgregados[I];
  if not TMensajes.Confirmar(#191 + 'Quitar ' + IntToStr(G.Unidades) + ' documento(s) de ' +
    G.Subserie + '? Quedar' + #225 + 'n libres.', 'Quitar de la transferencia') then
    Exit;
  try
    QuitarGrupo(FConn, FActual.IdProceso, G.IdEstructura, G.IdNodo, G.CodSubs);
  except
    on E: Exception do
      TMensajes.Error('No se pudo quitar: ' + E.Message, 'Transferencias');
  end;
  Recargar;
end;

procedure TfrmTransferenciasNuevo.btnRegistrarAutClick(Sender: TObject);
var
  A: TAutorizacion;
begin
  lblAutError.Caption := '';
  A.Organo := ocCentral;
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
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo registrar la autorizaci' + #243 + 'n: ' + E.Message,
        'Transferencias');
      Exit;
    end;
  end;
  MostrarAutorizacion(True, A);
end;

procedure TfrmTransferenciasNuevo.btnNumerarClick(Sender: TObject);
begin
  try
    NumerarCajas(FConn, FActual.IdProceso, spnCapacidad.Value);
  except
    on E: Exception do
    begin
      TMensajes.Error('No se pudieron numerar las cajas: ' + E.Message, 'Transferencias');
      Exit;
    end;
  end;
  MostrarCajas(RelacionDeEntrega(FConn, FActual.IdProceso));
  ActualizarFaltantes;
  Recargar;
end;

procedure TfrmTransferenciasNuevo.chkVerClick(Sender: TObject);
var
  I: Integer;
begin
  if FActualizando then
    Exit;
  I := TCheckBox(Sender).Tag;
  if (I < 0) or (I > High(VERIFICACIONES)) then
    Exit;
  try
    MarcarVerificacion(FConn, FActual.IdProceso, VERIFICACIONES[I].Codigo,
      TCheckBox(Sender).Checked);
    ActualizarFaltantes;
  except
    on E: Exception do
      TMensajes.Error('No se pudo guardar la verificaci' + #243 + 'n: ' + E.Message,
        'Transferencias');
  end;
end;

procedure TfrmTransferenciasNuevo.btnAvanzarClick(Sender: TObject);
var
  Faltan: TArray<string>;
  Texto, S: string;
begin
  lblAviso.Caption := '';
  if AvanzarTransferencia(FConn, FActual.IdProceso, FActual.Paso, FUsuario, Faltan) then
  begin
    Recargar;
    Exit;
  end;
  Texto := '';
  for S in Faltan do
  begin
    if Texto <> '' then
      Texto := Texto + '  ';
    Texto := Texto + S;
  end;
  lblAviso.Caption := Texto;
end;

procedure TfrmTransferenciasNuevo.btnRegistrarEntregaClick(Sender: TObject);
var
  Fecha: TDateTime;
begin
  if Trim(edtEntregadoPor.Text) = '' then
  begin
    lblAviso.Caption := 'Escriba el nombre de quien entrega.';
    Exit;
  end;
  if VarIsNull(dteEntrega.EditValue) then
    Fecha := Date
  else
    Fecha := dteEntrega.Date;
  if not TMensajes.Confirmar('Se registra la entrega de las cajas al archivo central. ' +
    'Ya no se podr' + #225 + ' cambiar la transferencia. ' + #191 + 'Continuar?',
    'Registrar la entrega') then
    Exit;
  if not RegistrarEntregaTransferencia(FConn, FActual.IdProceso, FUsuario,
    edtEntregadoPor.Text, Fecha) then
    TMensajes.Advertencia('La transferencia ya no est' + #225 + ' lista para entregar.',
      'Transferencias');
  Recargar;
end;

procedure TfrmTransferenciasNuevo.btnCancelarTransfClick(Sender: TObject);
begin
  if not TMensajes.Confirmar(#191 + 'Cancelar la transferencia ' + FActual.Numero +
    '? Los documentos quedar' + #225 + 'n libres.', 'Cancelar transferencia') then
    Exit;
  if not CancelarProceso(FConn, FActual.IdProceso, FUsuario, 'Cancelada por el usuario') then
    TMensajes.Advertencia('La transferencia ya no se puede cancelar.', 'Transferencias');
  Recargar;
end;

procedure TfrmTransferenciasNuevo.chkAnticipadaPropertiesChange(Sender: TObject);
begin
  if (FActual.Paso = 1) and pnlDetalle.Visible then
    CargarPaso;
end;

procedure TfrmTransferenciasNuevo.btnRegistrarRecepcionClick(Sender: TObject);
var
  Fecha: TDateTime;
  Errores: TArray<string>;
  Destino: Integer;
begin
  if VarIsNull(dteRecepcion.EditValue) then
    Fecha := Date
  else
    Fecha := dteRecepcion.Date;
  Destino := 0;
  if (cmbDestino.ItemIndex >= 0) and (cmbDestino.ItemIndex <= High(FCentrales)) then
    Destino := FCentrales[cmbDestino.ItemIndex].Cod;
  Errores := ValidarRecepcion(edtRecibidoPor.Text, Fecha, FActual.FEntrega, Now);
  if Length(Errores) = 0 then
    Errores := ValidarEntradaCentral(Destino, edtNumRegistro.Text);
  if Length(Errores) > 0 then
  begin
    lblAviso.Caption := Errores[0];
    Exit;
  end;
  if not TMensajes.Confirmar('Se registra que el archivo central recibi' + #243 + ' las cajas. ' +
    #191 + 'Continuar?', 'Registrar la recepci' + #243 + 'n') then
    Exit;
  try
    if not RegistrarRecepcionTransferencia(FConn, FActual.IdProceso, FUsuario,
      edtRecibidoPor.Text, edtNumRegistro.Text, Fecha, Destino) then
      TMensajes.Advertencia('La transferencia ya no est' + #225 + ' en el paso de recepci' + #243 +
        'n.', 'Transferencias');
  except
    on E: EArgumentException do
    begin
      lblAviso.Caption := E.Message;
      Exit;
    end;
    on E: Exception do
      TMensajes.Error('No se pudo registrar la recepci' + #243 + 'n: ' + E.Message, 'Transferencias');
  end;
  lblAviso.Caption := '';
  Recargar;
end;
procedure TfrmTransferenciasNuevo.btnCajaRecibidaClick(Sender: TObject);
begin
  ActuarEnCaja(accRecibida);
end;

procedure TfrmTransferenciasNuevo.btnCajaCuarentenaClick(Sender: TObject);
begin
  ActuarEnCaja(accCuarentena);
end;

procedure TfrmTransferenciasNuevo.btnCajaFaltanteClick(Sender: TObject);
begin
  ActuarEnCaja(accFaltante);
end;

procedure TfrmTransferenciasNuevo.btnResolverCuarentenaClick(Sender: TObject);
begin
  ActuarEnCaja(accResolver);
end;

procedure TfrmTransferenciasNuevo.btnGuardarUbicacionClick(Sender: TObject);
begin
  ActuarEnCaja(accUbicar);
end;

procedure TfrmTransferenciasNuevo.btnCerrarTransfClick(Sender: TObject);
begin
  if not TMensajes.Confirmar('Se finaliza la transferencia: los documentos de las cajas ' +
    'recibidas pasan al archivo central y quedan solo de lectura en el archivo de origen. ' +
    'No se puede deshacer. ' + #191 + 'Continuar?', 'Finalizar la transferencia') then
    Exit;
  try
    if not CerrarTransferencia(FConn, FActual.IdProceso, FUsuario) then
      TMensajes.Advertencia('La transferencia ya no est' + #225 + ' en el paso de ubicaci' + #243 +
        'n.', 'Transferencias');
  except
    on E: EArgumentException do
    begin
      lblAviso.Caption := E.Message;
      Exit;
    end;
    on E: Exception do
      TMensajes.Error('No se pudo finalizar la transferencia: ' + E.Message, 'Transferencias');
  end;
  lblAviso.Caption := '';
  Recargar;
end;

procedure TfrmTransferenciasNuevo.tvRecepFocusedRecordChanged(
  Sender: TcxCustomGridTableView; APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);
begin
  MostrarCajaElegida;
end;

procedure TfrmTransferenciasNuevo.MostrarArchivosCentrales(
  const Lista: TArray<TArchivoCentral>);
var
  I, Sel: Integer;
  Previo: Integer;
begin
  Previo := 0;
  if (cmbDestino.ItemIndex >= 0) and (cmbDestino.ItemIndex <= High(FCentrales)) then
    Previo := FCentrales[cmbDestino.ItemIndex].Cod;
  FCentrales := Lista;
  Sel := -1;
  cmbDestino.Properties.Items.Clear;
  for I := 0 to High(Lista) do
  begin
    cmbDestino.Properties.Items.Add(Lista[I].Nombre);
    if Lista[I].Cod = Previo then
      Sel := I;
  end;
  if (Sel < 0) and (Length(Lista) = 1) then
    Sel := 0;
  cmbDestino.ItemIndex := Sel;
  if Length(Lista) = 0 then
    cmbDestino.Properties.Items.Add('(no hay archivos de tipo Central)');
end;

procedure TfrmTransferenciasNuevo.MostrarCajasRecepcion(const Cajas: TArray<TCajaFila>);
var
  I, Sel: Integer;
  C: TCajaFila;
  DC: TcxGridDataController;
begin
  FCajasRec := Cajas;
  DC := tvRecep.DataController;
  tvRecep.BeginUpdate;
  try
    DC.RecordCount := Length(Cajas);
    for I := 0 to High(Cajas) do
    begin
      C := Cajas[I];
      DC.Values[I, colRecCaja.Index] := IntToStr(C.Caja);
      DC.Values[I, colRecDesc.Index] := C.Descripcion;
      DC.Values[I, colRecUnid.Index] := IntToStr(C.Unidades);
      DC.Values[I, colRecEstado.Index] := TextoEstadoCaja(C.Estado);
      DC.Values[I, colRecConserv.Index] := C.Conservacion;
      DC.Values[I, colRecUbic.Index] := TextoUbicacionCaja(C.Deposito, C.Gaveta, C.Posicion);
    end;
  finally
    tvRecep.EndUpdate;
  end;
  // vuelve a la caja que estaba marcada
  Sel := 0;
  for I := 0 to High(Cajas) do
    if Cajas[I].Caja = FCajaElegida then
      Sel := I;
  if Length(Cajas) > 0 then
    DC.FocusedRecordIndex := Sel;
  MostrarCajaElegida;
end;

function TfrmTransferenciasNuevo.CajaElegida(out C: TCajaFila): Boolean;
var
  I: Integer;
begin
  I := tvRecep.DataController.FocusedRecordIndex;
  Result := (I >= 0) and (I <= High(FCajasRec));
  if Result then
    C := FCajasRec[I];
end;

{ Pasa a los campos los datos de la caja marcada y deja activo solo lo que se puede
  hacer con ella en el paso en que esta la transferencia. }
procedure TfrmTransferenciasNuevo.MostrarCajaElegida;
var
  C: TCajaFila;
  Hay: Boolean;
begin
  Hay := CajaElegida(C);
  if Hay then
  begin
    FCajaElegida := C.Caja;
    edtConservacion.Text := C.Conservacion;
    edtDeposito.Text := C.Deposito;
    edtGaveta.Text := C.Gaveta;
    edtPosicion.Text := C.Posicion;
  end
  else
  begin
    edtConservacion.Text := '';
    edtDeposito.Text := '';
    edtGaveta.Text := '';
    edtPosicion.Text := '';
  end;
  lblConserv.Enabled := FEnRecepcion and Hay;
  edtConservacion.Enabled := FEnRecepcion and Hay;
  btnCajaRecibida.Enabled := FEnRecepcion and Hay and (C.Estado <> ecFaltante);
  btnCajaCuarentena.Enabled := FEnRecepcion and Hay and (C.Estado <> ecFaltante);
  btnCajaFaltante.Enabled := FEnRecepcion and Hay and (C.Estado <> ecFaltante);
  btnResolverCuarentena.Enabled := FEnRecepcion and Hay and (C.Estado = ecCuarentena);
  edtDeposito.Enabled := FEnUbicacion and Hay and (C.Estado = ecRecibida);
  edtGaveta.Enabled := edtDeposito.Enabled;
  edtPosicion.Enabled := edtDeposito.Enabled;
  btnGuardarUbicacion.Enabled := edtDeposito.Enabled;
  btnGuardarUbicacion.Visible := FEnUbicacion;
end;

procedure TfrmTransferenciasNuevo.ActuarEnCaja(Accion: TAccionCaja);
var
  C: TCajaFila;
begin
  if not CajaElegida(C) then
  begin
    lblAviso.Caption := 'Marque primero una caja de la lista.';
    Exit;
  end;
  try
    case Accion of
      accRecibida:
        MarcarCajaRecibida(FConn, FActual.IdProceso, C.Caja, edtConservacion.Text);
      accCuarentena:
        MarcarCajaCuarentena(FConn, FActual.IdProceso, C.Caja, edtConservacion.Text);
      accResolver:
        ResolverCuarentena(FConn, FActual.IdProceso, C.Caja);
      accUbicar:
        RegistrarUbicacionCaja(FConn, FActual.IdProceso, C.Caja, edtDeposito.Text,
          edtGaveta.Text, edtPosicion.Text);
      accFaltante:
        begin
          if not TMensajes.Confirmar('La caja ' + IntToStr(C.Caja) + ' sale de la ' +
            'transferencia: sus documentos se quedan en el archivo de origen y se abre una ' +
            'incidencia con plazo de reclamaci' + #243 + 'n. No se puede deshacer. ' + #191 +
            'Continuar?', 'Caja que no lleg' + #243) then
            Exit;
          MarcarCajaFaltante(FConn, FActual.IdProceso, C.Caja, FUsuario,
            edtConservacion.Text, Date);
        end;
    end;
  except
    on E: EArgumentException do
    begin
      lblAviso.Caption := E.Message;
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo registrar: ' + E.Message, 'Transferencias');
      Exit;
    end;
  end;
  lblAviso.Caption := '';
  Recargar;
end;
procedure TfrmTransferenciasNuevo.btnEliminarTransfClick(Sender: TObject);
begin
  if not TMensajes.Confirmar(#191 + 'Eliminar la transferencia ' + FActual.Numero +
    '? Se borra por completo y no se puede deshacer; los documentos quedar' + #225 +
    'n libres.', 'Eliminar transferencia') then
    Exit;
  if not EliminarProceso(FConn, FActual.IdProceso) then
    TMensajes.Advertencia('La transferencia ya no se puede eliminar.', 'Transferencias');
  FIdSeleccionado := 0;
  pnlDetalle.Visible := False;
  Recargar;
end;

procedure TfrmTransferenciasNuevo.btnRelacionClick(Sender: TObject);
begin
  if Assigned(FAlImprimirRelacion) then
    FAlImprimirRelacion(FActual.IdProceso);
end;

procedure TfrmTransferenciasNuevo.btnEtiquetasClick(Sender: TObject);
begin
  if Assigned(FAlImprimirEtiquetas) then
    FAlImprimirEtiquetas(FActual.IdProceso);
end;

end.
