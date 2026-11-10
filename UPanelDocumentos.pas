unit UPanelDocumentos;

{ Lista de documentos de una subserie con panel de propiedades (F2). Se crea
  por codigo (sin .dfm) y no accede a datos: quien la usa le entrega los
  documentos con Cargar y atiende sus eventos.
    - Un clic en un documento: OnSeleccion y sus propiedades a la derecha.
    - Doble clic o Intro: OnAbrirContenido.
    - Icono distinto para documento, expediente y mapa; insignia para lo
      georreferenciado.
    - Lista virtual (OwnerData): el costo no depende del numero de documentos.
  Colores de UTema (claro u oscuro segun Windows). Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Forms, UTema, UDocumentoVista, UTrazabilidad,
  UListaPropiedades, UPanelDocumento, UVistaUbicacion, UVisorContenido;

type
  { Ruta local de un archivo PDF con el contenido del documento, o '' y el
    motivo (sin PDF, formato no admitido, fichero ausente del almacen). }
  TSolicitudContenido = function(const Clave: TClaveDocumento;
    out Motivo: string): string of object;
  { Valores de las variables (metadatos) del documento: Grupo = subserie,
    Etiqueta = variable, Valor = su valor. Sin variables, un arreglo vacio. }
  TSolicitudMetadatos = function(const Clave: TClaveDocumento): TArray<TPropiedad> of object;
  { Ubicacion fisica de la subserie actual (la entrega quien usa el panel). }
  TSolicitudUbicacion = function: TUbicacion of object;
  TSolicitudFicheros = function(const Clave: TClaveDocumento): TArray<TFicheroDoc> of object;
  TClaveEvent = procedure(const Clave: TClaveDocumento) of object;
  TSolicitudHistoria = function(const Clave: TClaveDocumento;
    out HayMas: Boolean; out Motivo: string): TArray<TEventoDoc> of object;

  TPanelDocumentos = class(TPanel)
  private
    FTema: TTemaColores;
    FOscuro: Boolean;
    FTodos: TArray<TDatosDocumento>;
    FVisibles: TArray<TDatosDocumento>;
    FClases: TArray<TClaseDocumento>;
    FTitulo: string;
    FExpFiltrado: string;
    FSilencio: Boolean;
    FIndiceActual: Integer;
    FTextoFiltro: string;
    FFiltrarEstado: Boolean;
    FEstadoFiltro: TEstadoDoc;
    FFicherosActuales: TArray<TFicheroDoc>;
    FBarra: TPanel;
    FLblTitulo: TLabel;
    FLblFiltro: TLabel;
    FEnlaceTodos: TLabel;
    FLista: TListView;
    FVacio: TLabel;
    FSplitter: TSplitter;
    FDer: TPanel;
    FDoc: TPanelDocumento;
    FPropDatos, FPropArchivos, FPropMetadatos, FPropHistoria: TListaPropiedades;
    FVisor: TVisorContenido;
    FOnPedirContenido: TSolicitudContenido;
    FTimerContenido: TTimer;
    FContenidoPendiente: TDatosDocumento;
    FVistaUbicacion: TVistaUbicacion;
    FOnPedirUbicacionSubserie: TSolicitudUbicacion;
    FOnPedirMetadatos: TSolicitudMetadatos;
    FPie: TPanel;
    FBtnAbrir: TButton;
    FBtnExpediente: TButton;
    FEnlaceExp: TLabel;
    FOnSeleccion: TClaveEvent;
    FOnAbrirContenido: TClaveEvent;
    FOnExpedienteCompleto: TClaveEvent;
    FOnPedirFicheros: TSolicitudFicheros;
    FConstruido: Boolean;
    FErrorFicheros: Boolean;
    FOnPedirHistoria: TSolicitudHistoria;
    FHistoriaActual: TArray<TEventoDoc>;
    FHayMasHistoria: Boolean;
    FTituloHistoria: string;
    FMotivoHistoria: string;
    { La historia se pide una vez por documento seleccionado: redimensionar el
      panel redibuja las propiedades pero no vuelve a consultar. }
    FHistoriaValida: Boolean;
    FHistoriaClave: TClaveDocumento;
    function IconoIdx(const Nombre: string): Integer;
    function NuevaEtiqueta(const Texto: string; Tam: Integer; Color: TColor;
      Negrita: Boolean): TLabel;
    procedure Construir;
    procedure PestanaCambio(Sender: TObject);
    procedure CargarContenido(const D: TDatosDocumento);
    procedure ProgramarContenido(const D: TDatosDocumento);
    procedure TimerContenidoTimer(Sender: TObject);
    function NuevaLista(P: TPestanaDoc): TListaPropiedades;
    procedure AplicarFiltro;
    procedure ActualizarBarra;
    procedure MostrarPropiedades(Indice: Integer);
    procedure LimpiarPropiedades;
    procedure ListaData(Sender: TObject; Item: TListItem);
    procedure ListaSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure ListaDblClick(Sender: TObject);
    procedure ListaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AbrirClick(Sender: TObject);
    procedure ExpedienteClick(Sender: TObject);
    procedure EnlaceExpClick(Sender: TObject);
    procedure HistoriaClick(Sender: TObject);
    procedure EnlaceTodosClick(Sender: TObject);
    function IndiceSeleccionado: Integer;
    procedure AbrirSeleccionado;
  protected
    { Los controles hijos se crean al recibir el padre: un control con
      ventana necesita que toda la cadena de padres exista. }
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Reemplaza los documentos mostrados. Conserva la seleccion si el
      documento sigue en la lista; quita el filtro de expediente. }
    procedure Cargar(const Docs: TArray<TDatosDocumento>; const Titulo: string);
    { Selecciona el documento de esa clave si esta en la lista (sin disparar
      OnSeleccion). }
    procedure SeleccionarClave(const Clave: TClaveDocumento);
    { Sin subserie elegida: lista vacia con su propio texto guia. }
    procedure MostrarSinSubserie;
    { Texto (codigo, titulo, expediente) y, si FiltrarEstado, estado. Conserva
      la seleccion si el documento sigue visible. }
    procedure FijarFiltro(const Texto: string; FiltrarEstado: Boolean;
      Estado: TEstadoDoc);
    function CantidadVisibles: Integer;
    { Panel con las pestanas del documento seleccionado (Datos, Ubicacion...). }
    property Documento: TPanelDocumento read FDoc;
    { Visor del contenido (PDF) de la pestana Contenido. }
    property Visor: TVisorContenido read FVisor;
    { Contenido del documento; se pide solo al abrir la pestana Contenido. }
    property OnPedirContenido: TSolicitudContenido read FOnPedirContenido
      write FOnPedirContenido;
    { Metadatos del documento; sin esto la pestana dice que no hay metadatos. }
    property OnPedirMetadatos: TSolicitudMetadatos read FOnPedirMetadatos
      write FOnPedirMetadatos;
    { Ubicacion de la subserie; sin esto la pestana Ubicacion solo muestra la del documento. }
    property OnPedirUbicacionSubserie: TSolicitudUbicacion
      read FOnPedirUbicacionSubserie write FOnPedirUbicacionSubserie;
    property ExpedienteFiltrado: string read FExpFiltrado;
    property OnSeleccion: TClaveEvent read FOnSeleccion write FOnSeleccion;
    property OnAbrirContenido: TClaveEvent read FOnAbrirContenido write FOnAbrirContenido;
    { Obtener el expediente completo (ficheros del expediente y de sus documentos) }
    property OnExpedienteCompleto: TClaveEvent read FOnExpedienteCompleto write FOnExpedienteCompleto;
    property OnPedirFicheros: TSolicitudFicheros read FOnPedirFicheros write FOnPedirFicheros;
    { Eventos del documento (F5); sin esto el panel no muestra la historia }
    property OnPedirHistoria: TSolicitudHistoria read FOnPedirHistoria write FOnPedirHistoria;
  end;

implementation

uses
  System.Generics.Defaults, System.Math, System.StrUtils, System.DateUtils,
  UIconos, UShellPrincipal, UHistoriaDocumento;

const
  FUENTE = 'Segoe UI';
  ANCHO_DERECHA = 340;

function MismaClave(const A, B: TClaveDocumento): Boolean;
begin
  Result := SameText(Trim(A.IdEstructura), Trim(B.IdEstructura)) and
    (A.Id = B.Id) and SameText(Trim(A.CodSubs), Trim(B.CodSubs)) and
    (A.Fecha = B.Fecha) and SameText(Trim(A.Version), Trim(B.Version)) and
    SameText(Trim(A.Codigodoc), Trim(B.Codigodoc));
end;

{ TPanelDocumentos }

constructor TPanelDocumentos.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOscuro := TemaWindowsOscuro;
  if FOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
  FIndiceActual := -1;
end;

procedure TPanelDocumentos.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not FConstruido then
  begin
    FConstruido := True;
    Construir;
  end;
end;

destructor TPanelDocumentos.Destroy;
begin
  inherited Destroy;
end;

function TPanelDocumentos.IconoIdx(const Nombre: string): Integer;
begin
  try
    if FOscuro then
      Result := IndiceIconoBlanco(Nombre)
    else
      Result := IndiceIcono(Nombre);
  except
    Result := -1;
  end;
end;

function TPanelDocumentos.NuevaEtiqueta(const Texto: string; Tam: Integer;
  Color: TColor; Negrita: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.AutoSize := True;
  Result.Transparent := True;
  Result.StyleElements := [];
  Result.Font.Name := FUENTE;
  Result.Font.Size := Tam;
  Result.Font.Color := Color;
  if Negrita then
    Result.Font.Style := [fsBold];
  Result.Caption := Texto;
end;

// Pide el contenido del documento y lo muestra en el visor; si no hay PDF muestra
// el motivo. Se llama al abrir la pestana Contenido o al cambiar de documento con
// ella abierta.
procedure TPanelDocumentos.CargarContenido(const D: TDatosDocumento);
var
  Ruta, Motivo: string;
begin
  if not Assigned(FOnPedirContenido) then
  begin
    FVisor.MostrarMensaje('El contenido no esta disponible.');
    Exit;
  end;
  Motivo := '';
  try
    Ruta := FOnPedirContenido(D.Clave, Motivo);
  except
    on E: Exception do
    begin
      Ruta := '';
      Motivo := E.Message;
    end;
  end;
  if Ruta = '' then
  begin
    if Motivo = '' then
      Motivo := 'Este documento no tiene contenido.';
    FVisor.MostrarMensaje(Motivo);
  end
  else
    FVisor.Mostrar(Ruta, Trim(D.Clave.Codigodoc));
end;

// Cambiar de documento con el contenido abierto no descarga al instante: se
// espera un momento por si el usuario sigue recorriendo la lista (cada descarga
// es una conexion al almacen y una visualizacion registrada).
procedure TPanelDocumentos.ProgramarContenido(const D: TDatosDocumento);
begin
  FContenidoPendiente := D;
  // con la ventana aparte abierta se conserva lo que muestra hasta tener el nuevo
  if not FVisor.Separado then
    FVisor.MostrarMensaje('Cargando el contenido...');
  FTimerContenido.Enabled := False;
  FTimerContenido.Enabled := True;
end;

procedure TPanelDocumentos.TimerContenidoTimer(Sender: TObject);
begin
  FTimerContenido.Enabled := False;
  CargarContenido(FContenidoPendiente);
end;

procedure TPanelDocumentos.PestanaCambio(Sender: TObject);
begin
  if (FDoc.Activa = pdContenido) and (FIndiceActual >= 0) and
    (FIndiceActual < Length(FVisibles)) then
    CargarContenido(FVisibles[FIndiceActual]);
end;

// Lista de propiedades que ocupa toda la pagina de una pestana del documento
function TPanelDocumentos.NuevaLista(P: TPestanaDoc): TListaPropiedades;
begin
  Result := TListaPropiedades.Create(Self);
  Result.Parent := FDoc.Pagina(P);
  Result.Align := alClient;
  Result.AplicarTema(FTema, FOscuro);
end;

procedure TPanelDocumentos.Construir;

  procedure Col(const Titulo: string; Ancho: Integer);
  begin
    with FLista.Columns.Add do
    begin
      Caption := Titulo;
      Width := Ancho;
    end;
  end;

begin
  BevelOuter := bvNone;
  ParentBackground := False;
  StyleElements := [];
  ShowCaption := False;
  Color := FTema.Fondo;

  // Barra superior: titulo, aviso de filtro y boton de vista
  FBarra := TPanel.Create(Self);
  FBarra.Parent := Self;
  FBarra.Align := alTop;
  FBarra.Height := 46;
  FBarra.BevelOuter := bvNone;
  FBarra.ParentBackground := False;
  FBarra.StyleElements := [];
  FBarra.ShowCaption := False;
  FBarra.Color := FTema.Superficie;

  FLblTitulo := NuevaEtiqueta('', 11, FTema.Texto, True);
  FLblTitulo.Parent := FBarra;
  FLblTitulo.SetBounds(14, 6, 400, 20);

  FLblFiltro := NuevaEtiqueta('', 9, FTema.TextoSuave, False);
  FLblFiltro.Parent := FBarra;
  FLblFiltro.SetBounds(14, 26, 300, 16);
  FLblFiltro.Visible := False;

  FEnlaceTodos := NuevaEtiqueta('Mostrar todos', 9, FTema.Acento, False);
  FEnlaceTodos.Parent := FBarra;
  FEnlaceTodos.Font.Style := [fsUnderline];
  FEnlaceTodos.Cursor := crHandPoint;
  FEnlaceTodos.Visible := False;
  FEnlaceTodos.OnClick := EnlaceTodosClick;

  // Propiedades a la derecha
  FDer := TPanel.Create(Self);
  FDer.Parent := Self;
  FDer.Align := alRight;
  FDer.Width := ANCHO_DERECHA;
  FDer.BevelOuter := bvNone;
  FDer.ParentBackground := False;
  FDer.StyleElements := [];
  FDer.ShowCaption := False;
  FDer.Color := FTema.Superficie;

  FSplitter := TSplitter.Create(Self);
  FSplitter.Parent := Self;
  FSplitter.Align := alRight;
  FSplitter.Width := 5;
  FSplitter.MinSize := 240;
  FSplitter.StyleElements := [];
  FSplitter.Color := FTema.Linea;
  FSplitter.ParentColor := False;
  FDer.Left := Width; // el separador queda a su izquierda
  FSplitter.Left := FDer.Left - 1;

  FDoc := TPanelDocumento.Create(Self);
  FDoc.Parent := FDer;
  FDoc.Align := alClient;

  FPie := TPanel.Create(Self);
  FPie.Parent := FDoc.Pagina(pdArchivos);
  FPie.Align := alBottom;
  FPie.Height := 112;
  FPie.BevelOuter := bvNone;
  FPie.ParentBackground := False;
  FPie.StyleElements := [];
  FPie.ShowCaption := False;
  FPie.Color := FTema.Superficie;

  FBtnAbrir := TButton.Create(Self);
  FBtnAbrir.Parent := FPie;
  FBtnAbrir.Caption := 'Abrir contenido';
  FBtnAbrir.SetBounds(12, 10, 150, 30);
  FBtnAbrir.Enabled := False;
  FBtnAbrir.OnClick := AbrirClick;

  FBtnExpediente := TButton.Create(Self);
  FBtnExpediente.Parent := FPie;
  FBtnExpediente.Caption := 'Obtener expediente completo';
  FBtnExpediente.SetBounds(12, 46, 230, 30);
  FBtnExpediente.Visible := False;
  FBtnExpediente.OnClick := ExpedienteClick;

  FEnlaceExp := NuevaEtiqueta('Mostrar solo este expediente', 9, FTema.Acento, False);
  FEnlaceExp.Parent := FPie;
  FEnlaceExp.Font.Style := [fsUnderline];
  FEnlaceExp.Cursor := crHandPoint;
  FEnlaceExp.SetBounds(14, 86, 200, 16);
  FEnlaceExp.Visible := False;
  FEnlaceExp.OnClick := EnlaceExpClick;

  FPropDatos := NuevaLista(pdDatos);
  FVistaUbicacion := TVistaUbicacion.Create(Self);
  FVistaUbicacion.Parent := FDoc.Pagina(pdUbicacion);
  FVistaUbicacion.Align := alClient;
  FVistaUbicacion.AplicarTema(FTema);
  FPropArchivos := NuevaLista(pdArchivos);
  FPropMetadatos := NuevaLista(pdMetadatos);
  FPropHistoria := NuevaLista(pdHistoria);
  FPropHistoria.SinTituloHistoria := True;
  FPropHistoria.OnVerHistoria := HistoriaClick;
  FVisor := TVisorContenido.Create(Self);
  FVisor.Parent := FDoc.Pagina(pdContenido);
  FVisor.Align := alClient;
  FDoc.OnCambioPestana := PestanaCambio;
  FTimerContenido := TTimer.Create(Self);
  FTimerContenido.Enabled := False;
  FTimerContenido.Interval := 250;
  FTimerContenido.OnTimer := TimerContenidoTimer;

  // Lista virtual
  FLista := TListView.Create(Self);
  FLista.Parent := Self;
  FLista.Align := alClient;
  FLista.ViewStyle := vsReport;
  FLista.OwnerData := True;
  FLista.ReadOnly := True;
  FLista.RowSelect := True;
  FLista.HideSelection := False;
  FLista.MultiSelect := False;
  FLista.StyleElements := [];
  FLista.Color := FTema.Superficie;
  FLista.Font.Name := FUENTE;
  FLista.Font.Size := 10;
  FLista.Font.Color := FTema.Texto;
  FLista.BorderStyle := bsNone;
  FLista.SmallImages := TIconos.Lista;
  Col('Codigo', 175);
  Col('Titulo', 270);
  Col('Fecha', 105);
  Col('Tipo', 115);
  Col('Estado', 100);
  Col('Ficheros', 110);
  Col('Geo', 40);
  FLista.OnData := ListaData;
  FLista.OnSelectItem := ListaSelectItem;
  FLista.OnDblClick := ListaDblClick;
  FLista.OnKeyDown := ListaKeyDown;

  FVacio := NuevaEtiqueta('Esta subserie aun no tiene documentos', 12,
    FTema.TextoSuave, False);
  FVacio.Parent := FLista;
  FVacio.Left := 40;
  FVacio.Top := 60;
  FVacio.Visible := False;

  LimpiarPropiedades;
  ActualizarBarra;
end;

procedure TPanelDocumentos.Cargar(const Docs: TArray<TDatosDocumento>;
  const Titulo: string);
var
  Previa: TClaveDocumento;
  TeniaSeleccion: Boolean;
begin
  TeniaSeleccion := (FIndiceActual >= 0) and (FIndiceActual < Length(FVisibles));
  if TeniaSeleccion then
    Previa := FVisibles[FIndiceActual].Clave;
  FTodos := Copy(Docs);
  FTitulo := Titulo;
  FExpFiltrado := '';
  AplicarFiltro;
  if TeniaSeleccion then
    SeleccionarClave(Previa);
end;

procedure TPanelDocumentos.MostrarSinSubserie;
begin
  FTodos := nil;
  FTitulo := '';
  FExpFiltrado := '';
  AplicarFiltro;
  FVacio.Caption := 'Elija una subserie para ver sus documentos';
end;

procedure TPanelDocumentos.AplicarFiltro;
var
  I, N: Integer;
begin
  FVisibles := FiltrarPorExpediente(FTodos, FExpFiltrado);
  if (Trim(FTextoFiltro) <> '') or FFiltrarEstado then
  begin
    N := 0;
    for I := 0 to High(FVisibles) do
      if CoincideFiltro(FVisibles[I], FTextoFiltro, FFiltrarEstado, FEstadoFiltro) then
      begin
        FVisibles[N] := FVisibles[I];
        Inc(N);
      end;
    SetLength(FVisibles, N);
  end;
  TArray.Sort<TDatosDocumento>(FVisibles, TComparer<TDatosDocumento>.Construct(
    function(const A, B: TDatosDocumento): Integer
    begin
      Result := CompareText(A.Clave.Codigodoc, B.Clave.Codigodoc);
      if Result = 0 then
        Result := CompareText(A.Clave.Version, B.Clave.Version);
      if Result = 0 then
        Result := CompareDateTime(A.Clave.Fecha, B.Clave.Fecha);
    end));
  SetLength(FClases, Length(FVisibles));
  for I := 0 to High(FVisibles) do
    FClases[I] := ClasificarDocumento(FVisibles[I]);
  FIndiceActual := -1;
  FLista.Items.Count := 0;
  FLista.Items.Count := Length(FVisibles);
  FLista.Invalidate;
  if (Length(FVisibles) = 0) and (Length(FTodos) > 0) then
    FVacio.Caption := 'Ningun documento coincide'
  else
    FVacio.Caption := 'Esta subserie aun no tiene documentos';
  FVacio.Visible := Length(FVisibles) = 0;
  LimpiarPropiedades;
  ActualizarBarra;
end;

procedure TPanelDocumentos.FijarFiltro(const Texto: string;
  FiltrarEstado: Boolean; Estado: TEstadoDoc);
var
  Previa: TClaveDocumento;
  Tenia: Boolean;
begin
  FTextoFiltro := Texto;
  FFiltrarEstado := FiltrarEstado;
  FEstadoFiltro := Estado;
  Tenia := (FIndiceActual >= 0) and (FIndiceActual < Length(FVisibles));
  if Tenia then
    Previa := FVisibles[FIndiceActual].Clave;
  AplicarFiltro;
  if Tenia then
    SeleccionarClave(Previa);
end;

function TPanelDocumentos.CantidadVisibles: Integer;
begin
  Result := Length(FVisibles);
end;

procedure TPanelDocumentos.ActualizarBarra;
var
  N: Integer;
begin
  N := Length(FVisibles);
  if FTitulo <> '' then
    FLblTitulo.Caption := FTitulo + ' - ' + IntToStr(N) +
      IfThen(N = 1, ' documento', ' documentos')
  else
    FLblTitulo.Caption := IntToStr(N) + IfThen(N = 1, ' documento', ' documentos');
  FLblFiltro.Visible := FExpFiltrado <> '';
  FEnlaceTodos.Visible := FExpFiltrado <> '';
  if FExpFiltrado <> '' then
  begin
    FLblFiltro.Caption := 'Solo el expediente ' + FExpFiltrado + ' y sus documentos';
    FEnlaceTodos.Left := FLblFiltro.Left + FLblFiltro.Width + 12;
    FEnlaceTodos.Top := FLblFiltro.Top;
  end;
end;

procedure TPanelDocumentos.ListaData(Sender: TObject; Item: TListItem);
var
  D: TDatosDocumento;
  C: TClaseDocumento;
  Tipo, Ficheros, Geo: string;
begin
  if (Item.Index < 0) or (Item.Index > High(FVisibles)) then
    Exit;
  D := FVisibles[Item.Index];
  C := FClases[Item.Index];
  if C.Tipo = tdExpediente then
    Tipo := 'Expediente'
  else if C.EsMapa then
    Tipo := 'Mapa'
  else
    Tipo := 'Documento';
  Ficheros := IntToStr(D.NumFicheros);
  if D.NumFuentes > 0 then
    Ficheros := Ficheros + ' + ' + IntToStr(D.NumFuentes) + ' fuente';
  Item.Caption := D.Clave.Codigodoc;
  Item.ImageIndex := IconoIdx(NombreIconoDocumento(C));
  Item.SubItems.Add(D.Titulo);
  Item.SubItems.Add(FormatDateTime('dd"/"mm"/"yyyy', D.Clave.Fecha));
  Item.SubItems.Add(Tipo);
  Item.SubItems.Add(TextoEstadoDoc(D.Estado));
  Item.SubItems.Add(Ficheros);
  Item.SubItems.Add('');
  Geo := NombreInsigniaGeo(C);
  if Geo <> '' then
    Item.SubItemImages[5] := IconoIdx(Geo);
end;

function TPanelDocumentos.IndiceSeleccionado: Integer;
begin
  if FLista.Selected <> nil then
    Result := FLista.Selected.Index
  else
    Result := -1;
end;

procedure TPanelDocumentos.ListaSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if not Selected or (Item = nil) then
    Exit;
  if (Item.Index < 0) or (Item.Index > High(FVisibles)) then
    Exit;
  FIndiceActual := Item.Index;
  MostrarPropiedades(Item.Index);
  if (not FSilencio) and Assigned(FOnSeleccion) then
    FOnSeleccion(FVisibles[Item.Index].Clave);
end;

procedure TPanelDocumentos.AbrirSeleccionado;
var
  I: Integer;
begin
  // Misma condicion que el boton: sin ficheros digitales no hay contenido que abrir
  if not FBtnAbrir.Enabled then
    Exit;
  I := IndiceSeleccionado;
  if (I >= 0) and (I <= High(FVisibles)) and Assigned(FOnAbrirContenido) then
    FOnAbrirContenido(FVisibles[I].Clave);
end;

procedure TPanelDocumentos.ListaDblClick(Sender: TObject);
begin
  AbrirSeleccionado;
end;

procedure TPanelDocumentos.ListaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    AbrirSeleccionado;
    Key := 0;
  end;
end;

procedure TPanelDocumentos.AbrirClick(Sender: TObject);
begin
  AbrirSeleccionado;
end;

procedure TPanelDocumentos.ExpedienteClick(Sender: TObject);
var
  I: Integer;
begin
  I := IndiceSeleccionado;
  if (I >= 0) and (I <= High(FVisibles)) and Assigned(FOnExpedienteCompleto) then
    FOnExpedienteCompleto(FVisibles[I].Clave);
end;

procedure TPanelDocumentos.EnlaceTodosClick(Sender: TObject);
var
  Previa: TClaveDocumento;
  Tenia: Boolean;
begin
  Tenia := (FIndiceActual >= 0) and (FIndiceActual < Length(FVisibles));
  if Tenia then
    Previa := FVisibles[FIndiceActual].Clave;
  FExpFiltrado := '';
  AplicarFiltro;
  if Tenia then
    SeleccionarClave(Previa);
end;

procedure TPanelDocumentos.EnlaceExpClick(Sender: TObject);
var
  I: Integer;
  Cod: string;
begin
  I := FIndiceActual;
  if (I < 0) or (I > High(FVisibles)) then
    Exit;
  Cod := Trim(FVisibles[I].Clave.Codigodoc);
  FExpFiltrado := Cod;
  AplicarFiltro;
  // el expediente queda seleccionado
  for I := 0 to High(FVisibles) do
    if SameText(Trim(FVisibles[I].Clave.Codigodoc), Cod) then
    begin
      SeleccionarClave(FVisibles[I].Clave);
      Break;
    end;
end;

procedure TPanelDocumentos.SeleccionarClave(const Clave: TClaveDocumento);
var
  I: Integer;
begin
  for I := 0 to High(FVisibles) do
    if MismaClave(FVisibles[I].Clave, Clave) then
    begin
      FSilencio := True;
      try
        FLista.ItemIndex := I;
        FLista.Items[I].MakeVisible(False);
        FIndiceActual := I;
        MostrarPropiedades(I);
      finally
        FSilencio := False;
      end;
      Exit;
    end;
end;

procedure TPanelDocumentos.HistoriaClick(Sender: TObject);
begin
  MostrarHistoria(FTituloHistoria, FHistoriaActual, FHayMasHistoria, FTema);
end;

procedure TPanelDocumentos.LimpiarPropiedades;
begin
  FFicherosActuales := nil;
  FHistoriaActual := nil;
  FHistoriaValida := False;
  FBtnAbrir.Enabled := False;
  FBtnExpediente.Visible := False;
  FEnlaceExp.Visible := False;
  FPropDatos.MostrarMensaje('Elija un documento para ver sus propiedades');
  FVistaUbicacion.MostrarMensaje('Elija un documento para ver su ubicacion');
  FPropArchivos.MostrarMensaje('Elija un documento para ver sus archivos');
  FPropMetadatos.MostrarMensaje('Elija un documento para ver sus metadatos');
  FPropHistoria.MostrarMensaje('Elija un documento para ver su historia');
  FVisor.MostrarMensaje('Elija un documento para ver su contenido');
  FDoc.FijarCabecera('', '', edDesconocido);
  FDoc.FijarConteoArchivos(0);
end;

procedure TPanelDocumentos.MostrarPropiedades(Indice: Integer);
var
  D: TDatosDocumento;
  Props, Meta: TArray<TPropiedad>;
  I, Digitales: Integer;
  ErrorMeta: Boolean;
begin
  if (Indice < 0) or (Indice > High(FVisibles)) then
    Exit;
  D := FVisibles[Indice];
  FFicherosActuales := nil;
  FErrorFicheros := False;
  if Assigned(FOnPedirFicheros) then
  try
    FFicherosActuales := FOnPedirFicheros(D.Clave);
  except
    FFicherosActuales := nil;
    FErrorFicheros := True;
  end;
  Props := ConstruirPropiedades(D, FFicherosActuales);
  if FErrorFicheros then
    // no decir "Sin ficheros" cuando en realidad no se pudieron leer
    for I := 0 to High(Props) do
      if Props[I].Grupo = 'Ficheros' then
        Props[I].Valor := 'No se pudieron leer los ficheros';

  // Historia del documento: se pide una vez por documento seleccionado
  FTituloHistoria := D.Titulo;
  if Assigned(FOnPedirHistoria) and
    not (FHistoriaValida and MismaClave(FHistoriaClave, D.Clave)) then
  begin
    FHistoriaActual := nil;
    FHayMasHistoria := False;
    FMotivoHistoria := '';
    try
      FHistoriaActual := FOnPedirHistoria(D.Clave, FHayMasHistoria,
        FMotivoHistoria);
    except
      FHistoriaActual := nil;
      FMotivoHistoria := 'error al pedir la historia';
    end;
    FHistoriaClave := D.Clave;
    FHistoriaValida := True;
  end;
  // Cada pestana recibe sus propiedades; Metadatos y Contenido se llenan en sus
  // propias tareas y por ahora solo dicen que aun no estan disponibles
  FDoc.FijarCabecera(D.Clave.Codigodoc, D.Titulo, D.Estado);
  FPropDatos.Mostrar(PropiedadesDePestana(Props, pdDatos), nil, False, '', False);
  if Assigned(FOnPedirUbicacionSubserie) then
    FVistaUbicacion.Mostrar([FOnPedirUbicacionSubserie(), UbicacionDeDocumento(D)])
  else
    FVistaUbicacion.Mostrar([UbicacionDeDocumento(D)]);
  if FErrorFicheros then
    // no decir "Sin ficheros" cuando en realidad no se pudieron leer
    FPropArchivos.Mostrar(PropiedadesDePestana(Props, pdArchivos), nil, False, '', False)
  else
    FPropArchivos.Mostrar(PropiedadesDeArchivos(FFicherosActuales), nil, False, '', False);
  FPropHistoria.Mostrar(nil, FHistoriaActual, FHayMasHistoria, FMotivoHistoria,
    Assigned(FOnPedirHistoria));
  Meta := nil;
  ErrorMeta := False;
  if Assigned(FOnPedirMetadatos) then
  try
    Meta := MetadatosParaMostrar(FOnPedirMetadatos(D.Clave));
  except
    Meta := nil;
    ErrorMeta := True;
  end;
  if ErrorMeta then
    // no decir "no define metadatos" cuando en realidad no se pudieron leer
    FPropMetadatos.MostrarMensaje('No se pudieron leer los metadatos del documento.')
  else if Length(Meta) = 0 then
    FPropMetadatos.MostrarMensaje('Esta subserie no define metadatos')
  else
    FPropMetadatos.Mostrar(Meta, nil, False, '', False);
  // El contenido se descarga solo si la pestana esta abierta: no al seleccionar
  // Con el contenido separado en otra ventana tambien se sigue al documento, aunque
  // la pestana activa sea otra: si no, la ventana se cerraria sola
  FTimerContenido.Enabled := False;
  if (FDoc.Activa = pdContenido) or FVisor.Separado then
    ProgramarContenido(D)
  else
    FVisor.MostrarMensaje('Abra esta pestana para ver el contenido del documento.');
  FDoc.FijarConteoArchivos(Length(FFicherosActuales));

  Digitales := 0;
  if Assigned(FOnPedirFicheros) then
  begin
    for I := 0 to High(FFicherosActuales) do
      if not FFicherosActuales[I].EsFuente then
        Inc(Digitales);
  end
  else
    Digitales := D.NumFicheros;
  FBtnAbrir.Enabled := Digitales > 0;
  FBtnExpediente.Visible := (FClases[Indice].Tipo = tdExpediente) and
    Assigned(FOnExpedienteCompleto);
  // Solo si hay documentos del expediente en esta lista (los de otras subseries
  // no estan aqui: el filtro dejaria solo el expediente)
  FEnlaceExp.Visible := (FClases[Indice].Tipo = tdExpediente) and
    (Length(FiltrarPorExpediente(FTodos, Trim(D.Clave.Codigodoc))) > 1);
end;

end.
