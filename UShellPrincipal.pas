unit UShellPrincipal;

{ Shell de la variante A sobre la pantalla principal (TMAIN), construido por
  codigo y sin tocar UMAINFORM.dfm:
  - columna de secciones de 58 px a la izquierda, en el color de acento:
    Inicio, Archivo, Traslados, Prestamos y, abajo, Gestion;
  - el arbol (nbMain) a unos 270 px y rotulado "Mi area";
  - cabecera del area de trabajo: ruta y titulo del nodo elegido a la
    izquierda; a la derecha el buscador, la ranura del selector de ambito
    (Tarea 4), "Agregar documento" y el usuario.
  La barra antigua (pMainContainer) se oculta entera, con sus botones dentro:
  no se cambia el Name, Caption, Tag, OnClick ni Visible de ninguno, asi que
  el codigo por rol de TMAIN (adminOptions, GestorOptions, VisorOptions,
  ArchiveroOpts) los sigue gobernando. El menu "Gestion" se arma al abrirse
  con los botones que en ese momento estan visibles e invoca su mismo OnClick
  (o copia su menu desplegable).
  Un archivo shell_clasico.flag junto al ejecutable desactiva el shell: la
  pantalla clasica queda igual que antes. Si algo falla al construirlo se
  deshace lo hecho y queda la pantalla clasica, sin mensajes. }

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  System.Types, System.Generics.Collections, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, Vcl.ComCtrls, UTema, UBusqueda;

const
  ARCHIVO_SHELL_CLASICO = 'shell_clasico.flag';
  SECCION_INICIO = 'inicio';
  SECCION_ARCHIVO = 'archivo';
  SECCION_TRASLADOS = 'traslados';
  SECCION_PRESTAMOS = 'prestamos';
  SECCION_CLASIFICADORES = 'clasificadores';
  SECCION_CUADRO = 'cuadro';
  SECCION_DEPURACION = 'depuracion';
  SECCION_INDICES = 'indices';
  SECCION_USUARIOS = 'usuarios';
  SECCION_CONFIGURACION = 'configuracion';
  SECCION_ACERCA = 'acerca';

type
  TBuscarEvent = procedure(const Texto: string; Ambito: TAmbitoBusqueda) of object;
  TSeccionEvent = procedure(const Nombre: string) of object;
  TSeccionDisponibleEvent = function(const Nombre: string): Boolean of object;
  TTextoUsuarioEvent = function: string of object;

  TEstiloBoton = (ebColumna, ebPrimario, ebChip);

  { Boton dibujado por codigo (icono de UIconos y texto) con los colores del
    tema. ebColumna: icono arriba y texto debajo; ebPrimario y ebChip: icono
    a la izquierda y texto al lado. }
  TBotonShell = class(TCustomControl)
  private
    FEstilo: TEstiloBoton;
    FTexto: string;
    FIcono: Integer;
    FSeleccionado: Boolean;
    FEncima: Boolean;
    FSoloIcono: Boolean;
    FColorPadre: TColor;
    FColorFondo: TColor;
    FColorActivo: TColor;
    FColorTexto: TColor;
    FColorBorde: TColor;
    procedure SetTexto(const Valor: string);
    procedure SetSeleccionado(Valor: Boolean);
    procedure SetSoloIcono(Valor: Boolean);
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    function Esc(Valor: Integer): Integer;
  protected
    procedure Paint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoEnter; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    { Padre: color del control contenedor; Borde = clNone sin borde. }
    procedure Colores(Padre, Fondo, Activo, Texto, Borde: TColor);
    function AnchoIdeal: Integer;
    property Estilo: TEstiloBoton read FEstilo write FEstilo;
    property Texto: string read FTexto write SetTexto;
    property Icono: Integer read FIcono write FIcono;
    property Seleccionado: Boolean read FSeleccionado write SetSeleccionado;
    property SoloIcono: Boolean read FSoloIcono write SetSoloIcono;
    property OnClick;
  end;

  { Caja de busqueda: icono de lupa y un TEdit sin borde. Intro o clic en la
    lupa disparan OnBuscar; Escape borra el texto. }
  TCajaBusqueda = class(TCustomControl)
  private
    FEdit: TEdit;
    FIcono: Integer;
    FColorPadre: TColor;
    FColorFondo: TColor;
    FColorBorde: TColor;
    FOnBuscar: TNotifyEvent;
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    function GetTexto: string;
    function Esc(Valor: Integer): Integer;
    function AnchoLupa: Integer;
    procedure DoBuscar;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Colores(Padre, Fondo, Borde, Texto: TColor; Icono: Integer);
    property Edit: TEdit read FEdit;
    property Texto: string read GetTexto;
    property OnBuscar: TNotifyEvent read FOnBuscar write FOnBuscar;
  end;

  TShellPrincipal = class(TComponent)
  private
    FMain: TForm;
    FTema: TTemaColores;
    // Controles existentes de TMAIN (por nombre)
    FBarraClasica: TControl;   // pMainContainer
    FNavBar: TControl;         // nbMain
    FContenedor: TControl;     // PContainer
    FArbol: TTreeView;         // tvTree
    FGrupoArbol: TComponent;   // bgBD (opcional)
    // Controles propios
    FColumna: TPanel;
    FBtnInicio: TBotonShell;
    FBtnArchivo: TBotonShell;
    FSecciones: array of TBotonShell;  // botones por permiso (SECCIONES_PERMISO)
    FBtnGestion: TBotonShell;
    FCabecera: TPanel;
    FRuta: TLabel;
    FTitulo: TLabel;
    FBusqueda: TCajaBusqueda;
    FRanuraAmbito: TPanel;
    FSelAmbito: TComboBox;
    FBtnAgregar: TBotonShell;
    FChipUsuario: TBotonShell;
    // Pantalla de inicio: se muestra sobre el area de trabajo sin nodo elegido
    FInicio: TPanel;
    FInicioGrupo: TPanel;
    FInicioAgregar: TBotonShell;
    FInicioBuscar: TBotonShell;
    FMenuGestion: TPopupMenu;
    FOrigenes: TDictionary<TMenuItem, TMenuItem>;
    FTimer: TTimer;
    FAmbito: TAmbitoBusqueda;
    FSincronizando: Boolean;
    // Estado previo para deshacer
    FWndProcAnterior: TWndMethod;
    FEnganchado: Boolean;
    FCambioBarra: Boolean;
    FBarraVisibleAntes: Boolean;
    FCambioArbol: Boolean;
    FAnchoArbolAntes: Integer;
    FCambioGrupo: Boolean;
    FCaptionGrupoAntes: string;
    FCambioContenedor: Boolean;
    FConMargenesAntes: Boolean;
    FMargenesAntes: TRect;
    // Eventos
    FOnAgregarDocumento: TNotifyEvent;
    FOnBuscar: TBuscarEvent;
    FOnSeccion: TSeccionEvent;
    FOnSeccionDisponible: TSeccionDisponibleEvent;
    FOnTextoUsuario: TTextoUsuarioEvent;
    function Esc(Valor: Integer): Integer;
    function ControlRequerido(const Nombre: string): TControl;
    procedure CrearColumna;
    function CrearBotonColumna(const Texto, Icono: string; Alineacion: TAlign): TBotonShell;
    procedure OrdenarColumna;
    procedure CrearCabecera;
    procedure CrearInicio;
    procedure ActualizarInicio;
    procedure InicioResize(Sender: TObject);
    procedure InicioBuscarClick(Sender: TObject);
    procedure Desenganchar;
    procedure ContenedorWndProc(var Msg: TMessage);
    procedure SincronizarCabecera;
    procedure CabeceraResize(Sender: TObject);
    procedure ActualizarUbicacion;
    procedure ActualizarUsuario;
    procedure ActualizarSecciones;
    function SeccionDisponible(const Nombre: string): Boolean;
    procedure TimerRefresco(Sender: TObject);
    procedure SeccionClick(Sender: TObject);
    procedure GestionClick(Sender: TObject);
    procedure AgregarClick(Sender: TObject);
    procedure ChipClick(Sender: TObject);
    procedure BusquedaBuscar(Sender: TObject);
    procedure SelAmbitoChange(Sender: TObject);
    procedure ConstruirMenuGestion;
    procedure CopiarItems(Origen, Destino: TMenuItem);
    procedure ItemBotonClick(Sender: TObject);
    procedure ItemCopiaClick(Sender: TObject);
    procedure InvocarBoton(const Nombre: string);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AMain: TForm); reintroduce;
    destructor Destroy; override;
    procedure Construir;
    procedure Deshacer;
    { Recoloca la cabecera (p. ej. tras cambiar el ancho de la ranura de ambito). }
    procedure Reacomodar;
    { Relee nodo elegido, usuario y secciones disponibles (tambien cada 300 ms). }
    procedure Refrescar;
    { Ranura para el selector de ambito de la Tarea 4: oculta y de ancho 0
      hasta que se use. Para mostrarla: Visible := True, Width y Reacomodar. }
    property RanuraAmbito: TPanel read FRanuraAmbito;
    { Ambito que se envia en OnBuscar. Por defecto general (Tarea 4 lo elige). }
    property Ambito: TAmbitoBusqueda read FAmbito write FAmbito;
    property Tema: TTemaColores read FTema;
    property OnAgregarDocumento: TNotifyEvent read FOnAgregarDocumento write FOnAgregarDocumento;
    property OnBuscar: TBuscarEvent read FOnBuscar write FOnBuscar;
    property OnSeccion: TSeccionEvent read FOnSeccion write FOnSeccion;
    property OnSeccionDisponible: TSeccionDisponibleEvent read FOnSeccionDisponible write FOnSeccionDisponible;
    property OnTextoUsuario: TTextoUsuarioEvent read FOnTextoUsuario write FOnTextoUsuario;
  end;

{ Aplica el shell sobre la pantalla principal. Sin efecto si existe
  shell_clasico.flag junto al ejecutable, si ya esta aplicado o si falla
  (en ese caso deshace lo hecho y deja la pantalla clasica). }
procedure AplicarShell(Main: TForm);
function ShellActivo: Boolean;
{ El shell aplicado, o nil. }
function ShellPrincipal: TShellPrincipal;
{ True si Windows usa el tema oscuro para las aplicaciones. }
function TemaWindowsOscuro: Boolean;

implementation

uses
  System.Math, System.TypInfo, System.Win.Registry, Vcl.VirtualImageList,
  UIconos;

type
  TControlAcceso = class(TControl);

  TBotonClasico = record
    Nombre: string;
    Texto: string;
    Grupo: Integer;
  end;

type
  { Seccion de la columna que solo se ofrece a quien tiene permiso para ella
    (lo decide OnSeccionDisponible). Abajo: junto a Gestion. }
  TSeccionDef = record
    Nombre: string;
    Texto: string;
    Icono: string;
    Ayuda: string;
    Abajo: Boolean;
  end;

const
  SECCIONES_PERMISO: array[0..8] of TSeccionDef = (
    (Nombre: SECCION_CLASIFICADORES; Texto: 'Clasificad.'; Icono: 'clasificadores';
      Ayuda: 'Clasificadores: archivos, servidores FTP, series y subseries'; Abajo: False),
    (Nombre: SECCION_CUADRO; Texto: 'Cuadro'; Icono: 'cuadro';
      Ayuda: 'Administrar el cuadro de clasificacion'; Abajo: False),
    (Nombre: SECCION_TRASLADOS; Texto: 'Traslados'; Icono: 'traslados';
      Ayuda: 'Transferencias de documentos entre archivos'; Abajo: False),
    (Nombre: SECCION_PRESTAMOS; Texto: 'Prestamos'; Icono: 'prestamos';
      Ayuda: 'Prestamos de documentos'; Abajo: False),
    (Nombre: SECCION_DEPURACION; Texto: 'Depuracion'; Icono: 'depuracion';
      Ayuda: 'Depuracion de documentos'; Abajo: False),
    (Nombre: SECCION_INDICES; Texto: 'Indices'; Icono: 'indices';
      Ayuda: 'Gestion e indices de archivos'; Abajo: False),
    (Nombre: SECCION_USUARIOS; Texto: 'Usuarios'; Icono: 'usuarios';
      Ayuda: 'Administracion de usuarios'; Abajo: True),
    (Nombre: SECCION_CONFIGURACION; Texto: 'Config.'; Icono: 'configuracion';
      Ayuda: 'Configuracion del sistema, base de datos y registros'; Abajo: True),
    (Nombre: SECCION_ACERCA; Texto: 'Acerca de'; Icono: 'acerca';
      Ayuda: 'Acerca de ArchiGenio: version, edicion y creditos'; Abajo: True));

  { Botones de la barra antigua (pMainContainer), en el orden del menu
    Gestion. Grupo distinto = separador. }
  BOTONES_CLASICOS: array[0..9] of TBotonClasico = (
    (Nombre: 'btnautentica'; Texto: 'Iniciar o cerrar sesion'; Grupo: 0),
    (Nombre: 'btnRecuperacion'; Texto: 'Localizar documentos y subseries'; Grupo: 0),
    (Nombre: 'btnusercontrol'; Texto: 'Administracion de usuarios'; Grupo: 1),
    (Nombre: 'btnLC'; Texto: 'Listas de codigos'; Grupo: 1),
    (Nombre: 'btnPrint'; Texto: 'Impresiones y reportes'; Grupo: 1),
    (Nombre: 'btnManagementTree'; Texto: 'Administrar cuadro de clasificacion'; Grupo: 1),
    (Nombre: 'btnTool'; Texto: 'Herramientas administrativas'; Grupo: 1),
    (Nombre: 'btnViewPanel'; Texto: 'Mostrar paneles ocultos'; Grupo: 1),
    (Nombre: 'btnSystemHelp'; Texto: 'Ayuda del sistema'; Grupo: 2),
    (Nombre: 'btnClose'; Texto: 'Salir del sistema'; Grupo: 3));

  { Icono de cada entrada de BOTONES_CLASICOS en el menu Gestion. }
  ICONOS_CLASICOS: array[0..9] of string = (
    'usuario', 'buscar', 'usuarios', 'clasificadores', 'reportes', 'cuadro',
    'configuracion', 'gestion', 'ayuda', 'salir');

  FUENTE = 'Segoe UI';
  ANCHO_COLUMNA = 74;
  ANCHO_ARBOL = 270;
  ALTO_CABECERA = 64;
  ANCHO_BUSQUEDA = 260;
  ANCHO_BUSQUEDA_MIN = 160;
  ANCHO_CHIP_MAX = 220;
  ANCHO_TITULOS_MIN = 180;
  INTERVALO_REFRESCO = 300;

var
  GShell: TShellPrincipal;

{ Utilidades }

function Mezcla(A, B: TColor; F: Double): TColor;
var
  CA, CB: Integer;
begin
  CA := ColorToRGB(A);
  CB := ColorToRGB(B);
  Result := TColor(RGB(
    Round(GetRValue(CA) * (1 - F) + GetRValue(CB) * F),
    Round(GetGValue(CA) * (1 - F) + GetGValue(CB) * F),
    Round(GetBValue(CA) * (1 - F) + GetBValue(CB) * F)));
end;

function EsOscuro(C: TColor): Boolean;
begin
  Result := RazonContraste(C, clWhite) > RazonContraste(C, clBlack);
end;

{ Icono legible sobre el fondo dado: blanco sobre fondos oscuros. }
function IconoSobre(const Nombre: string; Fondo: TColor): Integer;
begin
  if EsOscuro(Fondo) then
    Result := IndiceIconoBlanco(Nombre)
  else
    Result := IndiceIcono(Nombre);
end;

{ Dibuja el icono escalado al rectangulo (nitido a cualquier DPI: se dibuja
  desde la coleccion, no desde la lista de 24 px). }
procedure DibujarIcono(C: TCanvas; Indice: Integer; const R: TRect);
var
  L: TVirtualImageList;
begin
  if Indice < 0 then
    Exit;
  L := TIconos.Lista;
  if (Indice < L.Images.Count) and (L.ImageCollection <> nil) then
    L.ImageCollection.Draw(C, R, L.Images[Indice].CollectionIndex, True);
end;

function TemaWindowsOscuro: Boolean;
var
  Reg: TRegistry;
begin
  Result := False;
  try
    Reg := TRegistry.Create(KEY_READ);
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKeyReadOnly('Software\Microsoft\Windows\CurrentVersion\Themes\Personalize') and
        Reg.ValueExists('AppsUseLightTheme') then
        Result := Reg.ReadInteger('AppsUseLightTheme') = 0;
    finally
      Reg.Free;
    end;
  except
    Result := False; // sin dato: tema claro
  end;
end;

{ TBotonShell }

constructor TBotonShell.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csClickEvents, csCaptureMouse] - [csSetCaption];
  FIcono := -1;
  FColorPadre := clWhite;
  FColorFondo := clWhite;
  FColorActivo := clWhite;
  FColorTexto := clBlack;
  FColorBorde := clNone;
  Cursor := crHandPoint;
  TabStop := True;
  DoubleBuffered := True;
end;

function TBotonShell.Esc(Valor: Integer): Integer;
begin
  Result := MulDiv(Valor, CurrentPPI, 96);
end;

procedure TBotonShell.Colores(Padre, Fondo, Activo, Texto, Borde: TColor);
begin
  FColorPadre := Padre;
  FColorFondo := Fondo;
  FColorActivo := Activo;
  FColorTexto := Texto;
  FColorBorde := Borde;
  Invalidate;
end;

procedure TBotonShell.SetTexto(const Valor: string);
begin
  if FTexto <> Valor then
  begin
    FTexto := Valor;
    Invalidate;
  end;
end;

procedure TBotonShell.SetSeleccionado(Valor: Boolean);
begin
  if FSeleccionado <> Valor then
  begin
    FSeleccionado := Valor;
    Invalidate;
  end;
end;

procedure TBotonShell.SetSoloIcono(Valor: Boolean);
begin
  if FSoloIcono <> Valor then
  begin
    FSoloIcono := Valor;
    Invalidate;
  end;
end;

function TBotonShell.AnchoIdeal: Integer;
begin
  if FSoloIcono then
    Exit(Esc(38));
  Canvas.Font := Font;
  Result := Esc(10) + Esc(18) + Esc(6) + Canvas.TextWidth(FTexto) + Esc(12);
end;

procedure TBotonShell.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  FEncima := True;
  Invalidate;
end;

procedure TBotonShell.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  FEncima := False;
  Invalidate;
end;

procedure TBotonShell.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TBotonShell.DoEnter;
begin
  inherited;
  Invalidate;
end;

procedure TBotonShell.DoExit;
begin
  inherited;
  Invalidate;
end;

procedure TBotonShell.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_RETURN) or (Key = VK_SPACE) then
  begin
    Key := 0;
    Click;
  end;
end;

procedure TBotonShell.Paint;
var
  R, RI, RT: TRect;
  Fondo, ColTexto: TColor;
  Tam, Radio, X, Y: Integer;
  Flags: Cardinal;
begin
  R := ClientRect;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FColorPadre;
  Canvas.FillRect(R);

  if Enabled and (FSeleccionado or FEncima) then
    Fondo := FColorActivo
  else
    Fondo := FColorFondo;
  Radio := Esc(8);
  if (Fondo <> FColorPadre) or (FColorBorde <> clNone) then
  begin
    Canvas.Brush.Color := Fondo;
    if FColorBorde <> clNone then
      Canvas.Pen.Color := FColorBorde
    else
      Canvas.Pen.Color := Fondo;
    Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Radio, Radio);
  end;

  ColTexto := FColorTexto;
  if not Enabled then
    ColTexto := Mezcla(FColorTexto, Fondo, 0.5);
  Canvas.Font := Font;
  Canvas.Font.Color := ColTexto;
  Canvas.Brush.Style := bsClear;

  if FEstilo = ebColumna then
  begin
    Tam := Esc(22);
    X := (R.Width - Tam) div 2;
    Y := Esc(7);
    RI := Rect(X, Y, X + Tam, Y + Tam);
    DibujarIcono(Canvas, FIcono, RI);
    RT := Rect(R.Left + Esc(2), RI.Bottom + Esc(3), R.Right - Esc(2), R.Bottom - Esc(2));
    Flags := DT_CENTER or DT_TOP or DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOPREFIX;
  end
  else
  begin
    Tam := Esc(18);
    if FSoloIcono then
      X := (R.Width - Tam) div 2
    else
      X := Esc(10);
    Y := (R.Height - Tam) div 2;
    RI := Rect(X, Y, X + Tam, Y + Tam);
    DibujarIcono(Canvas, FIcono, RI);
    RT := Rect(RI.Right + Esc(6), R.Top, R.Right - Esc(8), R.Bottom);
    Flags := DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOPREFIX;
  end;
  if not FSoloIcono and (FTexto <> '') then
    DrawText(Canvas.Handle, PChar(FTexto), Length(FTexto), RT, Flags);

  if Focused then
  begin
    Canvas.Brush.Style := bsSolid;
    RT := R;
    InflateRect(RT, -Esc(2), -Esc(2));
    Canvas.DrawFocusRect(RT);
  end;
end;

{ TCajaBusqueda }

constructor TCajaBusqueda.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csSetCaption];
  FIcono := -1;
  FColorPadre := clWhite;
  FColorFondo := clWhite;
  FColorBorde := clGray;
  DoubleBuffered := True;
  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.BorderStyle := bsNone;
  FEdit.ParentFont := True;
  FEdit.StyleElements := [];
  FEdit.OnKeyPress := EditKeyPress;
end;

function TCajaBusqueda.Esc(Valor: Integer): Integer;
begin
  Result := MulDiv(Valor, CurrentPPI, 96);
end;

function TCajaBusqueda.AnchoLupa: Integer;
begin
  Result := Esc(34);
end;

procedure TCajaBusqueda.Colores(Padre, Fondo, Borde, Texto: TColor; Icono: Integer);
begin
  FColorPadre := Padre;
  FColorFondo := Fondo;
  FColorBorde := Borde;
  FIcono := Icono;
  FEdit.Color := Fondo;
  FEdit.Font.Color := Texto;
  Invalidate;
end;

function TCajaBusqueda.GetTexto: string;
begin
  Result := FEdit.Text;
end;

procedure TCajaBusqueda.DoBuscar;
begin
  if Assigned(FOnBuscar) then
    FOnBuscar(Self);
end;

procedure TCajaBusqueda.EditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    DoBuscar;
  end
  else if Key = #27 then
  begin
    Key := #0;
    FEdit.Clear;
  end;
end;

procedure TCajaBusqueda.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Button <> mbLeft then
    Exit;
  if X < AnchoLupa then
    DoBuscar
  else if FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TCajaBusqueda.Resize;
var
  Izq, Alto: Integer;
begin
  inherited;
  if FEdit = nil then
    Exit;
  Izq := AnchoLupa;
  Alto := FEdit.Height;
  FEdit.SetBounds(Izq, Max(0, (ClientHeight - Alto) div 2),
    Max(0, ClientWidth - Izq - Esc(10)), Alto);
end;

procedure TCajaBusqueda.Paint;
var
  R, RI: TRect;
  Tam, Radio, X, Y: Integer;
begin
  R := ClientRect;
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := FColorPadre;
  Canvas.FillRect(R);
  Radio := Esc(8);
  Canvas.Brush.Color := FColorFondo;
  if FEdit.Focused then
    Canvas.Pen.Color := Mezcla(FColorBorde, FEdit.Font.Color, 0.45)
  else
    Canvas.Pen.Color := FColorBorde;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Radio, Radio);
  Tam := Esc(18);
  X := (AnchoLupa - Tam) div 2 + Esc(2);
  Y := (R.Height - Tam) div 2;
  RI := Rect(X, Y, X + Tam, Y + Tam);
  DibujarIcono(Canvas, FIcono, RI);
end;

{ TShellPrincipal }

constructor TShellPrincipal.Create(AMain: TForm);
begin
  inherited Create(AMain);
  FMain := AMain;
  FAmbito := abGeneral;
  FOrigenes := TDictionary<TMenuItem, TMenuItem>.Create;
end;

destructor TShellPrincipal.Destroy;
begin
  if GShell = Self then
    GShell := nil;
  if FTimer <> nil then
    FTimer.Enabled := False;
  Desenganchar;
  FOrigenes.Free;
  FOrigenes := nil;
  inherited Destroy;
end;

procedure TShellPrincipal.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation <> opRemove then
    Exit;
  if AComponent = FContenedor then
  begin
    FEnganchado := False; // se destruye: no restaurar su WindowProc
    FContenedor := nil;
  end
  else if AComponent = FBarraClasica then
    FBarraClasica := nil
  else if AComponent = FNavBar then
    FNavBar := nil
  else if AComponent = FArbol then
    FArbol := nil
  else if AComponent = FGrupoArbol then
    FGrupoArbol := nil;
end;

function TShellPrincipal.Esc(Valor: Integer): Integer;
begin
  Result := MulDiv(Valor, FMain.CurrentPPI, 96);
end;

function TShellPrincipal.ControlRequerido(const Nombre: string): TControl;
var
  C: TComponent;
begin
  C := FMain.FindComponent(Nombre);
  if not (C is TControl) then
    raise Exception.CreateFmt('Shell: falta el control "%s"', [Nombre]);
  Result := TControl(C);
  Result.FreeNotification(Self);
end;

procedure TShellPrincipal.Construir;
var
  C: TComponent;
begin
  // 1. Controles existentes (sin cambiar nada todavia)
  FBarraClasica := ControlRequerido('pMainContainer');
  FNavBar := ControlRequerido('nbMain');
  FContenedor := ControlRequerido('PContainer');
  C := ControlRequerido('tvTree');
  if not (C is TTreeView) then
    raise Exception.Create('Shell: tvTree no es un TTreeView');
  FArbol := TTreeView(C);
  C := FMain.FindComponent('bgBD');
  if (C <> nil) and IsPublishedProp(C, 'Caption') then
  begin
    FGrupoArbol := C;
    FGrupoArbol.FreeNotification(Self);
  end;
  if TemaWindowsOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;

  FMain.DisableAlign;
  try
    // 2. Controles propios
    CrearColumna;
    CrearCabecera;
    CrearInicio;
    FMenuGestion := TPopupMenu.Create(Self);
    FMenuGestion.AutoHotkeys := maManual;
    FMenuGestion.Images := TIconos.Lista;

    // 3. Cambios sobre los controles existentes (Deshacer los revierte)
    FBarraVisibleAntes := FBarraClasica.Visible;
    FCambioBarra := True;
    FBarraClasica.Visible := False;

    FAnchoArbolAntes := FNavBar.Width;
    FCambioArbol := True;
    FNavBar.Width := Esc(ANCHO_ARBOL);
    // La columna va a la izquierda de todo: alLeft se ordena por Left
    FNavBar.Left := FColumna.Left + FColumna.Width;

    if FGrupoArbol <> nil then
    begin
      FCaptionGrupoAntes := GetStrProp(FGrupoArbol, 'Caption');
      FCambioGrupo := True;
      SetStrProp(FGrupoArbol, 'Caption', 'Mi area');
    end;

    FConMargenesAntes := FContenedor.AlignWithMargins;
    FMargenesAntes := Rect(FContenedor.Margins.Left, FContenedor.Margins.Top,
      FContenedor.Margins.Right, FContenedor.Margins.Bottom);
    FCambioContenedor := True;
    FContenedor.Margins.SetBounds(0, FCabecera.Height, 0, 0);
    FContenedor.AlignWithMargins := True;

    FWndProcAnterior := FContenedor.WindowProc;
    FContenedor.WindowProc := ContenedorWndProc;
    FEnganchado := True;
  finally
    FMain.EnableAlign;
  end;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := INTERVALO_REFRESCO;
  FTimer.OnTimer := TimerRefresco;
  Refrescar;
  FTimer.Enabled := True;
end;

procedure TShellPrincipal.Deshacer;
begin
  if FTimer <> nil then
    FTimer.Enabled := False;
  Desenganchar;
  if FCambioContenedor and (FContenedor <> nil) then
  begin
    FContenedor.AlignWithMargins := FConMargenesAntes;
    FContenedor.Margins.SetBounds(FMargenesAntes.Left, FMargenesAntes.Top,
      FMargenesAntes.Right, FMargenesAntes.Bottom);
  end;
  FCambioContenedor := False;
  if FCambioGrupo and (FGrupoArbol <> nil) then
    SetStrProp(FGrupoArbol, 'Caption', FCaptionGrupoAntes);
  FCambioGrupo := False;
  if FCambioArbol and (FNavBar <> nil) then
    FNavBar.Width := FAnchoArbolAntes;
  FCambioArbol := False;
  if FCambioBarra and (FBarraClasica <> nil) then
    FBarraClasica.Visible := FBarraVisibleAntes;
  FCambioBarra := False;
  // Los controles propios se liberan con sus hijos
  FBtnInicio := nil;
  FBtnArchivo := nil;
  SetLength(FSecciones, 0);
  FBtnGestion := nil;
  FRuta := nil;
  FTitulo := nil;
  FBusqueda := nil;
  FRanuraAmbito := nil;
  FSelAmbito := nil;
  FBtnAgregar := nil;
  FChipUsuario := nil;
  FInicioGrupo := nil;
  FInicioAgregar := nil;
  FInicioBuscar := nil;
  FreeAndNil(FInicio);
  FreeAndNil(FColumna);
  FreeAndNil(FCabecera);
end;

procedure TShellPrincipal.Desenganchar;
begin
  if FEnganchado and (FContenedor <> nil) and
    (TMethod(FContenedor.WindowProc).Data = Pointer(Self)) then
    FContenedor.WindowProc := FWndProcAnterior;
  FEnganchado := False;
end;

procedure TShellPrincipal.ContenedorWndProc(var Msg: TMessage);
begin
  FWndProcAnterior(Msg);
  // PContainer cambia de tamano al mover el separador, ocultar el arbol (F8)
  // o redimensionar la ventana: la cabecera lo acompana.
  if (Msg.Msg = WM_WINDOWPOSCHANGED) and not (csDestroying in ComponentState) then
  try
    SincronizarCabecera;
  except
    // Solo es la posicion de la cabecera: el temporizador lo reintenta
  end;
end;

procedure TShellPrincipal.CrearColumna;
var
  I: Integer;
  A: TAlign;
begin
  FColumna := TPanel.Create(Self);
  FColumna.BevelOuter := bvNone;
  FColumna.ParentBackground := False;
  FColumna.StyleElements := [];
  FColumna.ShowCaption := False;
  FColumna.Color := FTema.Columna;
  FColumna.SetBounds(0, 0, Esc(ANCHO_COLUMNA), FMain.ClientHeight);
  FColumna.Align := alLeft;
  FColumna.Parent := FMain;

  FBtnInicio := CrearBotonColumna('Inicio', 'inicio', alTop);
  FBtnArchivo := CrearBotonColumna('Archivo', 'archivo', alTop);
  SetLength(FSecciones, Length(SECCIONES_PERMISO));
  for I := Low(SECCIONES_PERMISO) to High(SECCIONES_PERMISO) do
  begin
    if SECCIONES_PERMISO[I].Abajo then
      A := alBottom
    else
      A := alTop;
    FSecciones[I] := CrearBotonColumna(SECCIONES_PERMISO[I].Texto,
      SECCIONES_PERMISO[I].Icono, A);
    FSecciones[I].Hint := SECCIONES_PERMISO[I].Ayuda;
  end;
  FBtnGestion := CrearBotonColumna('Gestion', 'gestion', alBottom);
  FBtnGestion.OnClick := GestionClick;
  FBtnArchivo.Seleccionado := True;
  OrdenarColumna;
end;

function TShellPrincipal.CrearBotonColumna(const Texto, Icono: string;
  Alineacion: TAlign): TBotonShell;
begin
  Result := TBotonShell.Create(Self);
  Result.Estilo := ebColumna;
  Result.Texto := Texto;
  Result.Icono := IconoSobre(Icono, FTema.Columna);
  Result.Hint := Texto;
  Result.ShowHint := True;
  Result.TabStop := False;
  Result.Colores(FTema.Columna, FTema.Columna,
    Mezcla(FTema.Columna, FTema.Acento, 0.18), FTema.TextoColumna, clNone);
  Result.Font.Name := FUENTE;
  Result.Font.Height := -Esc(10);
  Result.AlignWithMargins := True;
  Result.Margins.SetBounds(Esc(4), Esc(2), Esc(4), Esc(2));
  Result.SetBounds(0, FColumna.ControlCount * Esc(52), Esc(66), Esc(46));
  Result.Align := Alineacion;
  Result.OnClick := SeccionClick;
  Result.Parent := FColumna;
end;

{ Fija el orden de los botones de arriba (alTop se ordena por Top), tambien
  despues de ocultar o mostrar Traslados o Prestamos. }
procedure TShellPrincipal.OrdenarColumna;
var
  I, Arriba, Abajo: Integer;
begin
  FColumna.DisableAlign;
  try
    // alTop y alBottom se ordenan por Top: se renumera tambien tras mostrar
    // u ocultar secciones
    FBtnInicio.Top := 0;
    FBtnArchivo.Top := Esc(52);
    Arriba := 2;
    Abajo := 0;
    for I := Low(FSecciones) to High(FSecciones) do
      if FSecciones[I] <> nil then
        if SECCIONES_PERMISO[I].Nombre = SECCION_ACERCA then
          Continue
        else if SECCIONES_PERMISO[I].Abajo then
        begin
          FSecciones[I].Top := Esc(2000) + Abajo * Esc(52);
          Inc(Abajo);
        end
        else
        begin
          FSecciones[I].Top := Arriba * Esc(52);
          Inc(Arriba);
        end;
    FBtnGestion.Top := Esc(2000) + Abajo * Esc(52);
    // Acerca de queda siempre en el extremo inferior, bajo Gestion
    for I := Low(FSecciones) to High(FSecciones) do
      if (FSecciones[I] <> nil) and (SECCIONES_PERMISO[I].Nombre = SECCION_ACERCA) then
        FSecciones[I].Top := Esc(2000) + (Abajo + 1) * Esc(52);
  finally
    FColumna.EnableAlign;
  end;
end;

procedure TShellPrincipal.CrearCabecera;
var
  Linea: TPanel;
begin
  FCabecera := TPanel.Create(Self);
  FCabecera.BevelOuter := bvNone;
  FCabecera.ParentBackground := False;
  FCabecera.StyleElements := [];
  FCabecera.ShowCaption := False;
  FCabecera.DoubleBuffered := True;
  FCabecera.Color := FTema.Superficie;
  FCabecera.SetBounds(0, 0, FMain.ClientWidth, Esc(ALTO_CABECERA));
  FCabecera.Parent := FMain;

  Linea := TPanel.Create(Self);
  Linea.BevelOuter := bvNone;
  Linea.ParentBackground := False;
  Linea.StyleElements := [];
  Linea.ShowCaption := False;
  Linea.Color := FTema.Linea;
  Linea.Height := 1;
  Linea.Align := alBottom;
  Linea.Parent := FCabecera;

  FRuta := TLabel.Create(Self);
  FRuta.AutoSize := False;
  FRuta.Transparent := True;
  FRuta.ShowAccelChar := False;
  FRuta.StyleElements := [];
  FRuta.EllipsisPosition := epEndEllipsis;
  FRuta.Font.Name := FUENTE;
  FRuta.Font.Height := -Esc(12);
  FRuta.Font.Color := FTema.TextoSuave;
  FRuta.Parent := FCabecera;

  FTitulo := TLabel.Create(Self);
  FTitulo.AutoSize := False;
  FTitulo.Transparent := True;
  FTitulo.ShowAccelChar := False;
  FTitulo.StyleElements := [];
  FTitulo.EllipsisPosition := epEndEllipsis;
  FTitulo.Font.Name := FUENTE;
  FTitulo.Font.Height := -Esc(18);
  FTitulo.Font.Style := [fsBold];
  FTitulo.Font.Color := FTema.Texto;
  FTitulo.Parent := FCabecera;

  FBusqueda := TCajaBusqueda.Create(Self);
  FBusqueda.Font.Name := FUENTE;
  FBusqueda.Font.Height := -Esc(13);
  FBusqueda.Parent := FCabecera;
  FBusqueda.Colores(FTema.Superficie, FTema.Superficie2, FTema.Linea, FTema.Texto,
    IconoSobre('buscar', FTema.Superficie2));
  FBusqueda.Edit.TextHint := 'Buscar por titulo, codigo o dato...';
  FBusqueda.OnBuscar := BusquedaBuscar;

  // Ranura del selector de ambito (general / nodo actual): Tarea 4
  FRanuraAmbito := TPanel.Create(Self);
  FRanuraAmbito.BevelOuter := bvNone;
  FRanuraAmbito.ParentBackground := False;
  FRanuraAmbito.StyleElements := [];
  FRanuraAmbito.ShowCaption := False;
  FRanuraAmbito.Color := FTema.Superficie;
  FRanuraAmbito.Parent := FCabecera;
  FRanuraAmbito.Width := Esc(190);
  FRanuraAmbito.Visible := True;
  FSelAmbito := TComboBox.Create(Self);
  FSelAmbito.Parent := FRanuraAmbito;
  FSelAmbito.Style := csDropDownList;
  FSelAmbito.Font.Name := FUENTE;
  FSelAmbito.Font.Height := -Esc(13);
  FSelAmbito.Align := alClient;
  FSelAmbito.AlignWithMargins := True;
  FSelAmbito.Margins.SetBounds(0, Esc(4), 0, 0);
  FSelAmbito.Items.Add('Todo el archivo');
  FSelAmbito.Items.Add('Solo en el nodo actual');
  FSelAmbito.ItemIndex := Ord(FAmbito);
  FSelAmbito.Hint := 'Donde buscar: todo el archivo o solo el nodo elegido en el arbol';
  FSelAmbito.ShowHint := True;
  SendMessage(FSelAmbito.Handle, CB_SETDROPPEDWIDTH, Esc(320), 0);
  FSelAmbito.OnChange := SelAmbitoChange;

  FBtnAgregar := TBotonShell.Create(Self);
  FBtnAgregar.Estilo := ebPrimario;
  FBtnAgregar.Texto := 'Agregar documento';
  FBtnAgregar.Hint := 'Agregar documento en la subserie elegida';
  FBtnAgregar.ShowHint := True;
  FBtnAgregar.Icono := IconoSobre('agregar', FTema.Acento);
  FBtnAgregar.Colores(FTema.Superficie, FTema.Acento,
    Mezcla(FTema.Acento, FTema.TextoSobreAcento, 0.15), FTema.TextoSobreAcento, clNone);
  FBtnAgregar.Font.Name := FUENTE;
  FBtnAgregar.Font.Height := -Esc(13);
  FBtnAgregar.Font.Style := [fsBold];
  FBtnAgregar.OnClick := AgregarClick;
  FBtnAgregar.Parent := FCabecera;

  FChipUsuario := TBotonShell.Create(Self);
  FChipUsuario.Estilo := ebChip;
  FChipUsuario.Icono := IconoSobre('usuario', FTema.Superficie2);
  FChipUsuario.ShowHint := True;
  FChipUsuario.Colores(FTema.Superficie, FTema.Superficie2, FTema.AcentoSuave,
    FTema.Texto, FTema.Linea);
  FChipUsuario.Font.Name := FUENTE;
  FChipUsuario.Font.Height := -Esc(12);
  FChipUsuario.OnClick := ChipClick;
  FChipUsuario.Parent := FCabecera;

  FCabecera.OnResize := CabeceraResize;
  Reacomodar;
end;

{ Pantalla de inicio minima: con ningun nodo elegido, el area de trabajo
  muestra dos acciones grandes y una linea guia. "Mis pendientes" y
  "recientes" quedan para la Fase 5. }
procedure TShellPrincipal.CrearInicio;
var
  Titulo, Guia: TLabel;
begin
  FInicio := TPanel.Create(Self);
  FInicio.BevelOuter := bvNone;
  FInicio.ParentBackground := False;
  FInicio.StyleElements := [];
  FInicio.ShowCaption := False;
  FInicio.Color := FTema.Fondo;
  FInicio.Align := alClient;
  FInicio.AlignWithMargins := True;
  FInicio.Margins.SetBounds(0, FCabecera.Height, 0, 0);
  FInicio.Visible := False;
  FInicio.Parent := FMain;
  FInicio.OnResize := InicioResize;

  FInicioGrupo := TPanel.Create(Self);
  FInicioGrupo.Parent := FInicio;
  FInicioGrupo.BevelOuter := bvNone;
  FInicioGrupo.ParentBackground := False;
  FInicioGrupo.StyleElements := [];
  FInicioGrupo.ShowCaption := False;
  FInicioGrupo.Color := FTema.Fondo;
  FInicioGrupo.SetBounds(0, 0, Esc(560), Esc(190));

  Titulo := TLabel.Create(Self);
  Titulo.Parent := FInicioGrupo;
  Titulo.AutoSize := False;
  Titulo.Alignment := taCenter;
  Titulo.Transparent := True;
  Titulo.Font.Name := FUENTE;
  Titulo.Font.Height := -Esc(26);
  Titulo.Font.Style := [fsBold];
  Titulo.Font.Color := FTema.Texto;
  Titulo.Caption := 'Que quiere hacer?';
  Titulo.SetBounds(0, 0, FInicioGrupo.Width, Esc(40));

  FInicioAgregar := TBotonShell.Create(Self);
  FInicioAgregar.Estilo := ebPrimario;
  FInicioAgregar.Texto := 'Agregar un documento';
  FInicioAgregar.Icono := IconoSobre('agregar', FTema.Acento);
  FInicioAgregar.Colores(FTema.Fondo, FTema.Acento,
    Mezcla(FTema.Acento, FTema.TextoSobreAcento, 0.15), FTema.TextoSobreAcento, clNone);
  FInicioAgregar.Font.Name := FUENTE;
  FInicioAgregar.Font.Height := -Esc(16);
  FInicioAgregar.Font.Style := [fsBold];
  FInicioAgregar.OnClick := AgregarClick;
  FInicioAgregar.Parent := FInicioGrupo;
  FInicioAgregar.SetBounds(0, Esc(64), Esc(270), Esc(64));

  FInicioBuscar := TBotonShell.Create(Self);
  FInicioBuscar.Estilo := ebPrimario;
  FInicioBuscar.Texto := 'Buscar un documento';
  FInicioBuscar.Icono := IconoSobre('buscar', FTema.Superficie);
  FInicioBuscar.Colores(FTema.Fondo, FTema.Superficie, FTema.AcentoSuave,
    FTema.Texto, FTema.Linea);
  FInicioBuscar.Font.Name := FUENTE;
  FInicioBuscar.Font.Height := -Esc(16);
  FInicioBuscar.Font.Style := [fsBold];
  FInicioBuscar.OnClick := InicioBuscarClick;
  FInicioBuscar.Parent := FInicioGrupo;
  FInicioBuscar.SetBounds(Esc(290), Esc(64), Esc(270), Esc(64));

  Guia := TLabel.Create(Self);
  Guia.Parent := FInicioGrupo;
  Guia.AutoSize := False;
  Guia.Alignment := taCenter;
  Guia.Transparent := True;
  Guia.Font.Name := FUENTE;
  Guia.Font.Height := -Esc(14);
  Guia.Font.Color := FTema.TextoSuave;
  Guia.Caption := 'Para trabajar en su area, elijala en el arbol de la izquierda.';
  Guia.SetBounds(0, Esc(150), FInicioGrupo.Width, Esc(24));
  InicioResize(nil);
end;

procedure TShellPrincipal.InicioResize(Sender: TObject);
begin
  if (FInicio = nil) or (FInicioGrupo = nil) then
    Exit;
  FInicioGrupo.SetBounds(Max(0, (FInicio.ClientWidth - FInicioGrupo.Width) div 2),
    Max(0, (FInicio.ClientHeight - FInicioGrupo.Height) div 2 - Esc(30)),
    FInicioGrupo.Width, FInicioGrupo.Height);
end;

{ Visible solo sin nodo elegido y con el arbol a la vista. }
procedure TShellPrincipal.ActualizarInicio;
var
  Mostrar: Boolean;
begin
  if FInicio = nil then
    Exit;
  Mostrar := (FArbol <> nil) and (FArbol.Selected = nil);
  if FInicio.Visible <> Mostrar then
  begin
    FInicio.Visible := Mostrar;
    if Mostrar then
    begin
      FInicio.BringToFront;
      FCabecera.BringToFront;
    end;
  end;
end;

procedure TShellPrincipal.InicioBuscarClick(Sender: TObject);
begin
  // Misma accion que el buscador de la cabecera, con el texto que haya
  BusquedaBuscar(Sender);
end;

procedure TShellPrincipal.CabeceraResize(Sender: TObject);
begin
  Reacomodar;
end;

{ Coloca los controles de la cabecera. A la derecha, de derecha a izquierda:
  usuario, Agregar, ranura de ambito y buscador. Si no queda sitio para la
  ruta y el titulo (1366x768 al 125 %), achica el buscador y deja el usuario
  y luego "Agregar" solo con su icono (el texto queda en la ayuda emergente). }
procedure TShellPrincipal.Reacomodar;
var
  W, H, Pad, Sep, AltoCtl, Y, X: Integer;
  AnchoBus, AnchoAmb, AnchoAgr, AnchoChip, MinTit: Integer;

  function Libre: Integer;
  begin
    Result := W - 2 * Pad - AnchoChip - Sep - AnchoAgr - Sep - AnchoBus - Sep;
    if AnchoAmb > 0 then
      Dec(Result, AnchoAmb + Sep);
  end;

begin
  if (FCabecera = nil) or (FBusqueda = nil) or (FBtnAgregar = nil) or
    (FChipUsuario = nil) or (FRanuraAmbito = nil) then
    Exit;
  W := FCabecera.ClientWidth;
  H := FCabecera.ClientHeight - 1;
  Pad := Esc(16);
  Sep := Esc(8);
  AltoCtl := Esc(34);
  MinTit := Esc(ANCHO_TITULOS_MIN);
  Y := Max(0, (H - AltoCtl) div 2);

  FChipUsuario.SoloIcono := False;
  FBtnAgregar.SoloIcono := False;
  AnchoBus := Esc(ANCHO_BUSQUEDA);
  if FRanuraAmbito.Visible then
    AnchoAmb := FRanuraAmbito.Width
  else
    AnchoAmb := 0;
  AnchoChip := Min(FChipUsuario.AnchoIdeal, Esc(ANCHO_CHIP_MAX));
  AnchoAgr := FBtnAgregar.AnchoIdeal;
  if Libre < MinTit then
    AnchoBus := Max(Esc(ANCHO_BUSQUEDA_MIN), AnchoBus - (MinTit - Libre));
  if Libre < MinTit then
  begin
    FChipUsuario.SoloIcono := True;
    AnchoChip := FChipUsuario.AnchoIdeal;
  end;
  if Libre < MinTit then
  begin
    FBtnAgregar.SoloIcono := True;
    AnchoAgr := FBtnAgregar.AnchoIdeal;
  end;

  X := W - Pad - AnchoChip;
  FChipUsuario.SetBounds(X, Y, AnchoChip, AltoCtl);
  X := X - Sep - AnchoAgr;
  FBtnAgregar.SetBounds(X, Y, AnchoAgr, AltoCtl);
  if AnchoAmb > 0 then
  begin
    X := X - Sep - AnchoAmb;
    FRanuraAmbito.SetBounds(X, Y, AnchoAmb, AltoCtl);
  end;
  X := X - Sep - AnchoBus;
  FBusqueda.SetBounds(X, Y, AnchoBus, AltoCtl);

  W := Max(0, X - Sep - Pad);
  FRuta.SetBounds(Pad, Esc(9), W, Esc(18));
  FTitulo.SetBounds(Pad, Esc(27), W, Esc(28));
end;

{ La cabecera ocupa el lugar de la barra antigua pero solo sobre el area de
  trabajo: desde el borde derecho de los controles alLeft (columna, arbol y
  separador) hasta el borde derecho de la ventana. PContainer deja arriba un
  margen del alto de la cabecera. }
procedure TShellPrincipal.SincronizarCabecera;
var
  I, X, W, H: Integer;
  C: TControl;
begin
  if FSincronizando or (FCabecera = nil) or (FContenedor = nil) or
    (csDestroying in FMain.ComponentState) then
    Exit;
  FSincronizando := True;
  try
    X := 0;
    for I := 0 to FMain.ControlCount - 1 do
    begin
      C := FMain.Controls[I];
      if C.Visible and (C.Align = alLeft) then
        X := Max(X, C.Left + C.Width);
    end;
    W := Max(0, FMain.ClientWidth - X);
    H := FCabecera.Height;
    if (FCabecera.Left <> X) or (FCabecera.Top <> 0) or (FCabecera.Width <> W) then
      FCabecera.SetBounds(X, 0, W, H);
    if FContenedor.Margins.Top <> H then
      FContenedor.Margins.Top := H;
    if (FInicio <> nil) and (FInicio.Margins.Top <> H) then
      FInicio.Margins.Top := H;
  finally
    FSincronizando := False;
  end;
end;

procedure TShellPrincipal.Refrescar;
begin
  SincronizarCabecera;
  ActualizarUbicacion;
  ActualizarInicio;
  ActualizarUsuario;
  ActualizarSecciones;
end;

procedure TShellPrincipal.TimerRefresco(Sender: TObject);
begin
  try
    Refrescar;
  except
    // No repetir un error cada 300 ms; la pantalla sigue funcionando
    FTimer.Enabled := False;
  end;
end;

procedure TShellPrincipal.ActualizarUbicacion;
var
  N, P: TTreeNode;
  Ruta, Titulo, Et: string;
  Idx: Integer;
begin
  if (FRuta = nil) or (FTitulo = nil) then
    Exit;
  N := nil;
  if FArbol <> nil then
    N := FArbol.Selected;
  if N = nil then
  begin
    Ruta := 'Mi area';
    Titulo := 'Elija un nodo en el arbol';
  end
  else
  begin
    Titulo := N.Text;
    Ruta := '';
    P := N.Parent;
    while P <> nil do
    begin
      if Ruta = '' then
        Ruta := P.Text
      else
        Ruta := P.Text + '  >  ' + Ruta;
      P := P.Parent;
    end;
    if Ruta = '' then
      Ruta := 'Mi area';
  end;
  if FSelAmbito <> nil then
  begin
    if N = nil then
      Et := 'Solo en el nodo actual'
    else
      Et := 'Solo en ' + Titulo;
    if FSelAmbito.Items[1] <> Et then
    begin
      Idx := FSelAmbito.ItemIndex;
      FSelAmbito.Items[1] := Et;
      FSelAmbito.ItemIndex := Idx;
    end;
  end;
  if FRuta.Caption <> Ruta then
    FRuta.Caption := Ruta;
  if FTitulo.Caption <> Titulo then
    FTitulo.Caption := Titulo;
end;

procedure TShellPrincipal.ActualizarUsuario;
var
  T: string;
begin
  if FChipUsuario = nil then
    Exit;
  T := '';
  if Assigned(FOnTextoUsuario) then
    T := FOnTextoUsuario;
  if FChipUsuario.Texto <> T then
  begin
    FChipUsuario.Texto := T;
    FChipUsuario.Hint := T + ' (clic para iniciar o cerrar sesion)';
    Reacomodar;
  end;
end;

function TShellPrincipal.SeccionDisponible(const Nombre: string): Boolean;
begin
  Result := True;
  if Assigned(FOnSeccionDisponible) then
    Result := FOnSeccionDisponible(Nombre);
end;

{ Traslados y Prestamos se ven solo si TMAIN los ofrece al usuario actual
  (OnSeccionDisponible), igual que antes solo se alcanzaban segun el rol. }
procedure TShellPrincipal.ActualizarSecciones;
var
  Cambio: Boolean;
  I: Integer;

  procedure Ajustar(B: TBotonShell; const Nombre: string);
  var
    Ver: Boolean;
  begin
    if B = nil then
      Exit;
    Ver := SeccionDisponible(Nombre);
    if B.Visible <> Ver then
    begin
      B.Visible := Ver;
      Cambio := True;
    end;
  end;

begin
  Cambio := False;
  for I := Low(FSecciones) to High(FSecciones) do
    Ajustar(FSecciones[I], SECCIONES_PERMISO[I].Nombre);
  if Cambio and (FColumna <> nil) then
    OrdenarColumna;
end;

procedure TShellPrincipal.SeccionClick(Sender: TObject);
var
  Nombre: string;
  I: Integer;
begin
  if Sender = FBtnInicio then
    Nombre := SECCION_INICIO
  else if Sender = FBtnArchivo then
    Nombre := SECCION_ARCHIVO
  else
  begin
    Nombre := '';
    for I := Low(FSecciones) to High(FSecciones) do
      if Sender = FSecciones[I] then
        Nombre := SECCIONES_PERMISO[I].Nombre;
    if Nombre = '' then
      Exit;
  end;
  if (Sender = FBtnInicio) or (Sender = FBtnArchivo) then
  begin
    FBtnInicio.Seleccionado := Sender = FBtnInicio;
    FBtnArchivo.Seleccionado := Sender = FBtnArchivo;
  end;
  if Assigned(FOnSeccion) then
    FOnSeccion(Nombre);
end;

procedure TShellPrincipal.AgregarClick(Sender: TObject);
begin
  if Assigned(FOnAgregarDocumento) then
    FOnAgregarDocumento(Self);
end;

procedure TShellPrincipal.SelAmbitoChange(Sender: TObject);
begin
  // El ambito elegido se recuerda mientras dure la sesion (vive en el shell)
  FAmbito := TAmbitoBusqueda(FSelAmbito.ItemIndex);
end;

procedure TShellPrincipal.BusquedaBuscar(Sender: TObject);
begin
  if Assigned(FOnBuscar) then
    FOnBuscar(Trim(FBusqueda.Texto), FAmbito);
end;

{ El chip del usuario hace lo mismo que el boton antiguo de autenticacion. }
procedure TShellPrincipal.ChipClick(Sender: TObject);
begin
  InvocarBoton('btnautentica');
end;

{ Invoca el OnClick original del boton antiguo, solo si sigue visible para el
  rol actual. Sender es el propio boton, como en la barra clasica. }
procedure TShellPrincipal.InvocarBoton(const Nombre: string);
var
  C: TComponent;
begin
  C := FMain.FindComponent(Nombre);
  if (C is TControl) and TControl(C).Visible and
    Assigned(TControlAcceso(C).OnClick) then
    TControlAcceso(C).OnClick(C);
end;

procedure TShellPrincipal.GestionClick(Sender: TObject);
var
  P: TPoint;
begin
  ConstruirMenuGestion;
  P := FBtnGestion.ClientToScreen(Point(FBtnGestion.Width, FBtnGestion.Height));
  FMenuGestion.Popup(P.X, P.Y);
end;

{ Arma el menu Gestion con los botones antiguos que estan visibles AHORA (su
  Visible lo pone el codigo por rol de TMAIN). Un boton con menu desplegable
  (DropDownMenu) da un submenu con copias de sus items; uno sin el, un item
  que invoca su OnClick. }
procedure TShellPrincipal.ConstruirMenuGestion;
var
  I, GrupoAnterior: Integer;
  C: TComponent;
  Obj: TObject;
  Item, Sep: TMenuItem;
  Desplegable: TPopupMenu;
begin
  FOrigenes.Clear;
  FMenuGestion.Items.Clear;
  GrupoAnterior := -1;
  for I := Low(BOTONES_CLASICOS) to High(BOTONES_CLASICOS) do
  begin
    C := FMain.FindComponent(BOTONES_CLASICOS[I].Nombre);
    if not (C is TControl) or not TControl(C).Visible then
      Continue;
    if (GrupoAnterior >= 0) and (BOTONES_CLASICOS[I].Grupo <> GrupoAnterior) then
    begin
      Sep := TMenuItem.Create(FMenuGestion);
      Sep.Caption := '-';
      FMenuGestion.Items.Add(Sep);
    end;
    GrupoAnterior := BOTONES_CLASICOS[I].Grupo;

    Item := TMenuItem.Create(FMenuGestion);
    Item.Caption := BOTONES_CLASICOS[I].Texto;
    Item.Tag := I;
    Item.ImageIndex := IndiceIcono(ICONOS_CLASICOS[I]);
    Desplegable := nil;
    if IsPublishedProp(C, 'DropDownMenu') then
    begin
      Obj := GetObjectProp(C, 'DropDownMenu');
      if Obj is TPopupMenu then
        Desplegable := TPopupMenu(Obj);
    end;
    if Desplegable <> nil then
    begin
      if Assigned(Desplegable.OnPopup) then
        Desplegable.OnPopup(Desplegable);
      CopiarItems(Desplegable.Items, Item);
    end
    else
      Item.OnClick := ItemBotonClick;
    FMenuGestion.Items.Add(Item);
  end;
end;

{ Icono de los items de los menus heredados, por el nombre del item original. }
function IconoDeItem(const Nombre: string): Integer;
const
  PARES: array[0..15] of array[0..1] of string = (
    ('A1', 'archivos'), ('L1', 'servidor'), ('S1', 'series'),
    ('B1', 'configuracion'), ('C1', 'basedatos'), ('log', 'logs'),
    ('P3', 'prestamos'), ('btnTransfer', 'traslados'), ('D3', 'depuracion'),
    ('I2', 'indices'), ('Ayuda1', 'ayuda'), ('Acercade1', 'acerca'),
    ('ControldeVersiones1', 'versiones'), ('cclasificacion', 'cuadro'),
    ('registrotopografico', 'topografia'), ('plazoretencion', 'reportes'));
var
  I: Integer;
begin
  Result := -1;
  for I := Low(PARES) to High(PARES) do
    if SameText(PARES[I][0], Nombre) then
      Exit(IndiceIcono(PARES[I][1]));
  if SameText(Nombre, 'seriesvalorar') then
    Result := IndiceIcono('series');
end;

procedure TShellPrincipal.CopiarItems(Origen, Destino: TMenuItem);
var
  J: Integer;
  O, N: TMenuItem;
begin
  for J := 0 to Origen.Count - 1 do
  begin
    O := Origen.Items[J];
    N := TMenuItem.Create(FMenuGestion);
    N.Caption := O.Caption;
    N.ImageIndex := IconoDeItem(O.Name);
    N.Hint := O.Hint;
    N.Visible := O.Visible;
    N.Enabled := O.Enabled;
    N.Checked := O.Checked;
    if O.Count > 0 then
      CopiarItems(O, N)
    else if not O.IsLine then
    begin
      N.OnClick := ItemCopiaClick;
      FOrigenes.AddOrSetValue(N, O);
    end;
    Destino.Add(N);
  end;
end;

procedure TShellPrincipal.ItemBotonClick(Sender: TObject);
var
  I: Integer;
begin
  I := TMenuItem(Sender).Tag;
  if (I >= Low(BOTONES_CLASICOS)) and (I <= High(BOTONES_CLASICOS)) then
    InvocarBoton(BOTONES_CLASICOS[I].Nombre);
end;

{ Copia de un item de un menu desplegable: ejecuta el item original (su
  OnClick o su accion, con el original como Sender). }
procedure TShellPrincipal.ItemCopiaClick(Sender: TObject);
var
  O: TMenuItem;
begin
  if FOrigenes.TryGetValue(TMenuItem(Sender), O) then
    O.Click;
end;

{ API }

procedure AplicarShell(Main: TForm);
var
  S: TShellPrincipal;

  procedure RegistrarError(E: Exception);
  begin
    // Sin mensajes: queda la pantalla clasica; el motivo se guarda en
    // shell_error.log junto al ejecutable
    try
      with TStringList.Create do
      try
        Add(DateTimeToStr(Now) + ' ' + E.ClassName + ': ' + E.Message);
        SaveToFile(ExtractFilePath(ParamStr(0)) + 'shell_error.log');
      finally
        Free;
      end;
    except
    end;
  end;

begin
  if (Main = nil) or (GShell <> nil) then
    Exit;
  // Interruptor de seguridad: con el archivo, la pantalla clasica sin cambios
  if FileExists(ExtractFilePath(ParamStr(0)) + ARCHIVO_SHELL_CLASICO) then
    Exit;
  S := nil;
  try
    S := TShellPrincipal.Create(Main);
    S.Construir;
    GShell := S;
  except
    on E: Exception do
    begin
      RegistrarError(E);
      if S <> nil then
      begin
        try
          S.Deshacer;
        except
        end;
        try
          S.Free;
        except
        end;
      end;
      GShell := nil;
    end;
  end;
end;

function ShellActivo: Boolean;
begin
  Result := GShell <> nil;
end;

function ShellPrincipal: TShellPrincipal;
begin
  Result := GShell;
end;

end.
