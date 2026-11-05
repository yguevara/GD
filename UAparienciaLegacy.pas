unit UAparienciaLegacy;

{ Fase 1 de la identidad visual: adapta los formularios viejos (rejillas
  DevExpress, botones con iconos blancos, paneles azules) a la paleta de
  UTema sin tocar sus .dfm. Se instala una vez (InstalarAparienciaLegacy) y
  cada formulario se adapta al activarse por primera vez. Es solo apariencia:
  no cambia nombres, eventos ni datos. Un error al adaptar un control nunca
  interrumpe el programa. Codigo en ASCII. }

interface

uses
  Vcl.Forms, UTema;

{ Engancha Screen.OnActiveFormChange y adapta los formularios ya abiertos. }
procedure InstalarAparienciaLegacy;

{ Adapta un formulario (una sola vez por formulario). }
procedure AplicarAparienciaLegacy(Form: TForm; const Tema: TTemaColores);

implementation

uses
  System.SysUtils, System.Classes, System.TypInfo, System.Generics.Collections,
  Winapi.Windows, Vcl.Controls, Vcl.Graphics, Vcl.ExtCtrls, Vcl.StdCtrls,
  cxGraphics, cxStyles, cxGridTableView, cxGridCustomTableView, cxVGrid, JvTransparentButton,
  UShellPrincipal;

const
  NOMBRE_MARCA = 'ArchiGenioApariencia';

type
  { Juego de estilos cx compartido por todas las rejillas. }
  TEstilosLegacy = class(TComponent)
  public
    Fondo, Contenido, ContenidoPar, ContenidoImpar, Cabecera, Seleccion,
      Inactivo, Indicador, Grupo, CajaGrupo, Pie, Vista, Filtro, Busqueda,
      Categoria, Etiqueta: TcxStyle;
    constructor CrearCon(const T: TTemaColores);
  private
    function Nuevo(Color, Texto: TColor): TcxStyle;
  end;

  TManejadorApariencia = class
    procedure CambioFormulario(Sender: TObject);
  end;

var
  GEstilos: TEstilosLegacy;
  GTema: TTemaColores;
  GTemaListo: Boolean;
  GManejador: TManejadorApariencia;
  GAnteriorCambio: TNotifyEvent;

function Rojo(C: TColor): Integer;
begin
  Result := Integer(ColorToRGB(C)) and $FF;
end;

function Verde(C: TColor): Integer;
begin
  Result := (Integer(ColorToRGB(C)) shr 8) and $FF;
end;

function Azul(C: TColor): Integer;
begin
  Result := (Integer(ColorToRGB(C)) shr 16) and $FF;
end;

function Mezcla(A, B: TColor; Parte: Double): TColor;
begin
  Result := TColor(RGB(
    Round(Rojo(A) + (Rojo(B) - Rojo(A)) * Parte),
    Round(Verde(A) + (Verde(B) - Verde(A)) * Parte),
    Round(Azul(A) + (Azul(B) - Azul(A)) * Parte)));
end;

function Luminosidad(C: TColor): Double;
begin
  Result := (0.299 * Rojo(C) + 0.587 * Verde(C) + 0.114 * Azul(C)) / 255;
end;

{ Fondo "azulado": el azul domina claramente sobre rojo y verde. }
function EsAzulado(C: TColor): Boolean;
begin
  if C < 0 then
    Exit(False); // colores del sistema (clBtnFace...): se dejan al estilo
  Result := (Azul(C) > Rojo(C) + 25) and (Azul(C) >= Verde(C));
end;

{ TEstilosLegacy }

function TEstilosLegacy.Nuevo(Color, Texto: TColor): TcxStyle;
begin
  Result := TcxStyle.Create(Self);
  Result.Color := Color;
  Result.TextColor := Texto;
end;

constructor TEstilosLegacy.CrearCon(const T: TTemaColores);
begin
  inherited Create(nil);
  Fondo := Nuevo(T.Fondo, T.Texto);
  Contenido := Nuevo(T.Superficie, T.Texto);
  ContenidoPar := Nuevo(T.Superficie, T.Texto);
  ContenidoImpar := Nuevo(Mezcla(T.Superficie, T.Superficie2, 0.55), T.Texto);
  Cabecera := Nuevo(T.Superficie2, T.TextoSuave);
  Seleccion := Nuevo(T.AcentoSuave, T.Texto);
  Inactivo := Nuevo(Mezcla(T.Superficie, T.AcentoSuave, 0.5), T.Texto);
  Indicador := Nuevo(T.Superficie2, T.TextoSuave);
  Grupo := Nuevo(T.AcentoSuave, T.Texto);
  CajaGrupo := Nuevo(T.Superficie2, T.TextoSuave);
  Pie := Nuevo(T.Superficie2, T.Texto);
  Vista := Nuevo(T.Superficie, T.TextoSuave);
  Filtro := Nuevo(T.Superficie2, T.Texto);
  Busqueda := Nuevo(T.AcentoSuave, T.Texto);
  Categoria := Nuevo(T.AcentoSuave, T.Acento);
  Etiqueta := Nuevo(T.Superficie2, T.TextoSuave);
end;

{ Rejillas }

procedure AdaptarVistaTabla(V: TcxGridTableView);
begin
  V.Styles.StyleSheet := nil;
  V.Styles.Background := GEstilos.Fondo;
  V.Styles.Content := GEstilos.Contenido;
  V.Styles.ContentEven := GEstilos.ContenidoPar;
  V.Styles.ContentOdd := GEstilos.ContenidoImpar;
  V.Styles.Header := GEstilos.Cabecera;
  V.Styles.Selection := GEstilos.Seleccion;
  V.Styles.Inactive := GEstilos.Inactivo;
  V.Styles.Indicator := GEstilos.Indicador;
  V.Styles.Group := GEstilos.Grupo;
  V.Styles.GroupByBox := GEstilos.CajaGrupo;
  V.Styles.Footer := GEstilos.Pie;
  V.Styles.Preview := GEstilos.Vista;
  V.Styles.FilterBox := GEstilos.Filtro;
  V.Styles.IncSearch := GEstilos.Busqueda;
  V.OptionsView.GridLines := glHorizontal;
end;

procedure AdaptarRejillaVertical(G: TcxCustomVerticalGrid);
begin
  G.Styles.StyleSheet := nil;
  G.Styles.Background := GEstilos.Fondo;
  G.Styles.Content := GEstilos.Contenido;
  G.Styles.ContentEven := GEstilos.ContenidoPar;
  G.Styles.ContentOdd := GEstilos.ContenidoImpar;
  G.Styles.Header := GEstilos.Etiqueta;
  G.Styles.Category := GEstilos.Categoria;
  G.Styles.Inactive := GEstilos.Inactivo;
  G.Styles.Selection := GEstilos.Seleccion;
  G.Styles.IncSearch := GEstilos.Busqueda;
end;

{ Los iconos de estos botones son blancos (pensados para el fondo azul) y por
  defecto el boton es transparente: no pinta su Color. Se le da una cara opaca
  de marron calido (TextoSuave) donde el icono blanco se lee bien. Un boton de
  color oscuro o intencionado (rojo, verde...) se respeta. }
procedure AdaptarBoton(B: TJvTransparentButton; const T: TTemaColores);
begin
  if EsAzulado(B.Color) or (Luminosidad(B.Color) > 0.6) then
  begin
    B.Transparent := False;
    B.Color := T.TextoSuave;
  end;
end;

{ Propiedades de color por nombre (paneles de terceros): solo si existen. }
procedure FijarColorProp(Obj: TObject; const Nombre: string; Valor: TColor);
begin
  if (Obj <> nil) and (GetPropInfo(Obj, Nombre) <> nil) and
    (GetPropInfo(Obj, Nombre)^.PropType^.Kind = tkInteger) then
    SetOrdProp(Obj, Nombre, Valor);
end;

procedure AdaptarPanelTercero(C: TComponent; const T: TTemaColores);
var
  Cap: TObject;
begin
  FijarColorProp(C, 'Color', T.Superficie2);
  FijarColorProp(C, 'ColorTo', T.Superficie2);
  FijarColorProp(C, 'ColorMirror', T.Superficie2);
  FijarColorProp(C, 'ColorMirrorTo', T.Superficie2);
  FijarColorProp(C, 'CaptionColor', T.Superficie2);
  // Paneles y pestanas laterales de TMS (AdvToolPanel / AdvToolPanelTab)
  FijarColorProp(C, 'FocusCaptionColor', T.AcentoSuave);
  FijarColorProp(C, 'FocusCaptionColorTo', T.AcentoSuave);
  FijarColorProp(C, 'NoFocusCaptionColor', T.Superficie2);
  FijarColorProp(C, 'NoFocusCaptionColorTo', T.Superficie2);
  FijarColorProp(C, 'HoverButtonColor', T.AcentoSuave);
  FijarColorProp(C, 'HoverButtonColorTo', T.AcentoSuave);
  FijarColorProp(C, 'DownButtonColor', T.AcentoSuave);
  FijarColorProp(C, 'DownButtonColorTo', T.AcentoSuave);
  FijarColorProp(C, 'TabColor', T.Superficie2);
  FijarColorProp(C, 'TabColorTo', T.Superficie2);
  FijarColorProp(C, 'TabHoverColor', T.AcentoSuave);
  FijarColorProp(C, 'TabHoverColorTo', T.AcentoSuave);
  FijarColorProp(C, 'TabBorderColor', T.Linea);
  if GetPropInfo(C, 'Caption') <> nil then
  begin
    if GetPropInfo(C, 'Caption')^.PropType^.Kind = tkClass then
    begin
      Cap := GetObjectProp(C, 'Caption');
      FijarColorProp(Cap, 'Color', T.Superficie2);
      FijarColorProp(Cap, 'ColorTo', T.Superficie2);
      FijarColorProp(Cap, 'TextColor', T.TextoSuave);
    end;
  end;
end;

procedure AdaptarControl(C: TComponent; const T: TTemaColores);
var
  Padre: TWinControl;
  FondoPadre: TColor;
  L: TLabel;
begin
  if C is TcxGridTableView then
    AdaptarVistaTabla(TcxGridTableView(C))
  else if C is TcxCustomVerticalGrid then
    AdaptarRejillaVertical(TcxCustomVerticalGrid(C))
  else if C is TJvTransparentButton then
    AdaptarBoton(TJvTransparentButton(C), T)
  else if (C.ClassName = 'TAdvPanel') or (C.ClassName = 'TAdvToolPanel') or
    (C.ClassName = 'TAdvToolPanelTab') or (C.ClassName = 'TJvCaptionPanel') then
    AdaptarPanelTercero(C, T)
  else if (C is TPanel) and EsAzulado(TPanel(C).Color) then
  begin
    TPanel(C).ParentBackground := False;
    TPanel(C).Color := T.Superficie2;
    if Luminosidad(TPanel(C).Font.Color) > 0.8 then
      TPanel(C).Font.Color := T.Texto;
  end
  else if C is TLabel then
  begin
    // Etiqueta clara (blanca) sobre un fondo que ya es claro: pasa a texto
    L := TLabel(C);
    if (L.Font.Color >= 0) and (Luminosidad(L.Font.Color) > 0.85) and
      (L.Parent <> nil) then
    begin
      Padre := L.Parent;
      if Padre is TPanel then
        FondoPadre := TPanel(Padre).Color
      else
        FondoPadre := T.Fondo;
      if (FondoPadre >= 0) and (Luminosidad(FondoPadre) > 0.6) then
        L.Font.Color := T.Texto;
    end;
  end;
end;

procedure AplicarAparienciaLegacy(Form: TForm; const Tema: TTemaColores);
var
  I: Integer;
  Marca: TComponent;
begin
  if (Form = nil) or (csDestroying in Form.ComponentState) then
    Exit;
  if Form.FindComponent(NOMBRE_MARCA) <> nil then
    Exit;
  Marca := TComponent.Create(Form);
  Marca.Name := NOMBRE_MARCA;
  if GEstilos = nil then
    GEstilos := TEstilosLegacy.CrearCon(Tema);
  Form.DisableAlign;
  try
    for I := 0 to Form.ComponentCount - 1 do
    try
      AdaptarControl(Form.Components[I], Tema);
    except
      // Un control que no admite el cambio no debe detener el resto
    end;
  finally
    Form.EnableAlign;
  end;
end;

{ TManejadorApariencia }

procedure TManejadorApariencia.CambioFormulario(Sender: TObject);
begin
  try
    if Screen.ActiveForm <> nil then
      AplicarAparienciaLegacy(Screen.ActiveForm, GTema);
  except
    // Solo apariencia
  end;
  if Assigned(GAnteriorCambio) then
    GAnteriorCambio(Sender);
end;

procedure InstalarAparienciaLegacy;
var
  I: Integer;
begin
  if GManejador <> nil then
    Exit;
  if TemaWindowsOscuro then
    GTema := TemaOscuro
  else
    GTema := TemaClaro;
  GTemaListo := True;
  GManejador := TManejadorApariencia.Create;
  GAnteriorCambio := Screen.OnActiveFormChange;
  Screen.OnActiveFormChange := GManejador.CambioFormulario;
  for I := 0 to Screen.FormCount - 1 do
    AplicarAparienciaLegacy(Screen.Forms[I], GTema);
end;

initialization

finalization
  FreeAndNil(GEstilos);
  FreeAndNil(GManejador);

end.
