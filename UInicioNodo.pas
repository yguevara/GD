unit UInicioNodo;

{ ---------------------------------------------------------------------------
  Pantalla de inicio del nodo: lo que se ve en el area de trabajo cuando no hay
  una subserie elegida (antes era un espacio vacio). Sin base de datos: recibe el
  resumen ya calculado (UInicioDatos) y avisa de lo que el usuario pide con
  OnAccion.

  Tres bloques, de arriba abajo:
    1. Resumen del nodo: cifras (series, subseries, documentos, sin ubicacion,
       prestados) y las acciones "Agregar", "Buscar" y "Ver cuadro".
    2. Ciclo de vida del documento: etapas con su cifra; cada una lleva a su
       seccion si el usuario tiene permiso.
    3. "Primeros pasos": tres pasos, plegable. Si se pliega, queda guardado en
       ArchivoConfig y no vuelve a aparecer abierto.

  Claves de OnAccion: 'agregar', 'buscar', 'cuadro', 'prestamos', 'traslados',
  'depuracion'. Los permisos (FijarPermiso) usan esas mismas claves; 'buscar'
  siempre esta permitido.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Graphics, UTema, UShellPrincipal, UInicioDatos;

type
  TInicioAccionEvent = procedure(const AClave: string) of object;

  TPanelInicio = class(TScrollBox)
  private
    type
      TTarjeta = record
        Marco: TPanel;      // borde de 1 px
        Cuerpo: TPanel;     // fondo
      end;
      TEtapa = record
        Clave: string;      // 'etapa:captura', ...
        Accion: string;     // clave de OnAccion; '' = solo informativa
        Tarjeta: TTarjeta;
        Icono: TImage;
        Nombre, Cifra, Pie: TLabel;
      end;
  private
    FTema: TTemaColores;
    FContexto: TLabel;
    FKpis: array[0..4] of TTarjeta;
    FKpiValor, FKpiTexto: array[0..4] of TLabel;
    FAcciones: TTarjeta;
    FAccionesTitulo: TLabel;
    FBtnAgregar, FBtnBuscar, FBtnCuadro: TBotonShell;
    FCiclo: TTarjeta;
    FCicloTitulo, FCicloAyuda: TLabel;
    FEtapas: array[0..5] of TEtapa;
    FPasos: TTarjeta;
    FPasosTitulo, FPasosAlternar: TLabel;
    FPasosCuerpo: TPanel;
    FPasosNum, FPasosTit, FPasosTxt: array[0..2] of TLabel;
    FPermisos: TStringList;
    FResumen: TResumenInicio;
    FPasosOcultos: Boolean;
    FArchivoConfig: string;
    FOnAccion: TInicioAccionEvent;
    function Esc(Valor: Integer): Integer;
    function NuevaTarjeta: TTarjeta;
    function NuevaEtiqueta(AParent: TWinControl; const ATexto: string; ATam: Integer;
      ANegrita: Boolean; AColor: TColor): TLabel;
    function NuevoBoton(AParent: TWinControl; const ATexto, AIcono: string;
      APrimario: Boolean; AClick: TNotifyEvent): TBotonShell;
    function Permitido(const AClave: string): Boolean;
    function IndiceDeClave(const AClave: string): Integer;
    procedure Construir;
    procedure Distribuir;
    procedure ActualizarEtapas;
    procedure PonerIcono(AEtapa: Integer; const ANombre: string);
    procedure SetArchivoConfig(const Valor: string);
    procedure GuardarPasos;
    procedure Redimensionado(Sender: TObject);
    procedure BotonAgregarClick(Sender: TObject);
    procedure BotonBuscarClick(Sender: TObject);
    procedure BotonCuadroClick(Sender: TObject);
    procedure EtapaClick(Sender: TObject);
    procedure AlternarClick(Sender: TObject);
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent; const ATema: TTemaColores); reintroduce;
    destructor Destroy; override;
    { Pone las cifras. ATitulo: nombre del nodo ('' = toda el area). }
    procedure Mostrar(const AResumen: TResumenInicio; const ATitulo: string);
    { Permite o no una accion (claves de la cabecera del archivo). }
    procedure FijarPermiso(const AClave: string; APermitido: Boolean);
    { Pulsa una accion o una etapa ('etapa:<nombre>') como lo haria el usuario. }
    procedure Pulsar(const AClave: string);
    function AccionVisible(const AClave: string): Boolean;
    function TextoCifra(const AClave: string): string;
    function PasosVisibles: Boolean;
    procedure AlternarPasos;
    { Archivo .ini donde se recuerda si "Primeros pasos" esta plegado. }
    property ArchivoConfig: string read FArchivoConfig write SetArchivoConfig;
    property OnAccion: TInicioAccionEvent read FOnAccion write FOnAccion;
  end;

implementation

uses
  System.IniFiles, System.IOUtils, System.Math, Winapi.Windows, UIconos;

type
  { Da acceso a la fuente (protegida) de TBotonShell. }
  TBotonAbierto = class(TBotonShell);

const
  CLAVES_KPI: array[0..4] of string = ('series', 'subseries', 'documentos',
    'sinubicacion', 'prestados');
  ETAPAS_CLAVE: array[0..5] of string = ('etapa:captura', 'etapa:clasificacion',
    'etapa:ubicacion', 'etapa:prestamo', 'etapa:transferencia', 'etapa:depuracion');
  ETAPAS_ACCION: array[0..5] of string = ('agregar', 'cuadro', '', 'prestamos',
    'traslados', 'depuracion');
  ETAPAS_ICONO: array[0..5] of string = ('documento', 'cuadro', 'topografia',
    'prestamos', 'traslados', 'depuracion');

{ Color intermedio entre A y B (F de 0 a 1). }
function Mezclar(A, B: TColor; F: Double): TColor;
var
  CA, CB: Integer;
begin
  CA := ColorToRGB(A);
  CB := ColorToRGB(B);
  Result := RGB(Round(GetRValue(CA) * (1 - F) + GetRValue(CB) * F),
    Round(GetGValue(CA) * (1 - F) + GetGValue(CB) * F),
    Round(GetBValue(CA) * (1 - F) + GetBValue(CB) * F));
end;

{ 1284 -> '1 284' (separador de miles con espacio). }
function Miles(N: Integer): string;
var
  S: string;
  I, Cuenta: Integer;
begin
  S := IntToStr(Abs(N));
  Result := '';
  Cuenta := 0;
  for I := Length(S) downto 1 do
  begin
    if (Cuenta > 0) and (Cuenta mod 3 = 0) then
      Result := ' ' + Result;
    Result := S[I] + Result;
    Inc(Cuenta);
  end;
  if N < 0 then
    Result := '-' + Result;
end;

{ TPanelInicio }

constructor TPanelInicio.Create(AOwner: TComponent; const ATema: TTemaColores);
begin
  inherited Create(AOwner);
  FTema := ATema;
  FPermisos := TStringList.Create;
  FPermisos.CaseSensitive := False;
  BorderStyle := bsNone;
  HorzScrollBar.Visible := False;
  StyleElements := [];
  Color := FTema.Fondo;
  OnResize := Redimensionado;
  Construir;
end;

destructor TPanelInicio.Destroy;
begin
  FPermisos.Free;
  inherited Destroy;
end;

function TPanelInicio.Esc(Valor: Integer): Integer;
begin
  Result := MulDiv(Valor, CurrentPPI, 96);
end;

function TPanelInicio.NuevaTarjeta: TTarjeta;
begin
  Result.Marco := TPanel.Create(Self);
  Result.Marco.Parent := Self;
  Result.Marco.BevelOuter := bvNone;
  Result.Marco.ParentBackground := False;
  Result.Marco.StyleElements := [];
  Result.Marco.ShowCaption := False;
  Result.Marco.Color := FTema.Linea;
  Result.Marco.Padding.SetBounds(1, 1, 1, 1);
  Result.Cuerpo := TPanel.Create(Self);
  Result.Cuerpo.Parent := Result.Marco;
  Result.Cuerpo.Align := alClient;
  Result.Cuerpo.BevelOuter := bvNone;
  Result.Cuerpo.ParentBackground := False;
  Result.Cuerpo.StyleElements := [];
  Result.Cuerpo.ShowCaption := False;
  Result.Cuerpo.Color := FTema.Superficie;
end;

function TPanelInicio.NuevaEtiqueta(AParent: TWinControl; const ATexto: string;
  ATam: Integer; ANegrita: Boolean; AColor: TColor): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.AutoSize := False;
  Result.Transparent := True;
  Result.StyleElements := [];
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := ATam;
  if ANegrita then
    Result.Font.Style := [fsBold];
  Result.Font.Color := AColor;
  Result.SetBounds(0, 0, 100, 16);
  Result.Caption := ATexto;
end;

function TPanelInicio.NuevoBoton(AParent: TWinControl; const ATexto, AIcono: string;
  APrimario: Boolean; AClick: TNotifyEvent): TBotonShell;
var
  Idx: Integer;
begin
  Result := TBotonShell.Create(Self);
  Result.Parent := AParent;
  Result.Estilo := ebPrimario;
  Result.Texto := ATexto;
  TBotonAbierto(Result).Font.Name := 'Segoe UI';
  TBotonAbierto(Result).Font.Size := 10;
  TBotonAbierto(Result).Font.Style := [fsBold];
  try
    if APrimario then
      Idx := IndiceIconoBlanco(AIcono)
    else
      Idx := IndiceIcono(AIcono);
  except
    Idx := -1;
  end;
  Result.Icono := Idx;
  if APrimario then
    Result.Colores(FTema.Superficie, FTema.Acento, Mezclar(FTema.Acento, FTema.TextoSobreAcento, 0.15),
      FTema.TextoSobreAcento, clNone)
  else
    Result.Colores(FTema.Superficie, FTema.Superficie, FTema.AcentoSuave, FTema.Texto, FTema.Linea);
  Result.OnClick := AClick;
end;

procedure TPanelInicio.Construir;
var
  I: Integer;
begin
  FContexto := NuevaEtiqueta(Self, '', 10, False, FTema.TextoSuave);

  for I := 0 to High(FKpis) do
  begin
    FKpis[I] := NuevaTarjeta;
    FKpiValor[I] := NuevaEtiqueta(FKpis[I].Cuerpo, '0', 22, True, FTema.Texto);
    FKpiTexto[I] := NuevaEtiqueta(FKpis[I].Cuerpo, '', 9, False, FTema.TextoSuave);
  end;
  FKpiTexto[0].Caption := 'Series';
  FKpiTexto[1].Caption := 'Subseries';
  FKpiTexto[2].Caption := 'Documentos';
  FKpiTexto[3].Caption := 'Sin ubicaci'#243'n f'#237'sica';
  FKpiTexto[4].Caption := 'Prestados ahora';

  FAcciones := NuevaTarjeta;
  FAccionesTitulo := NuevaEtiqueta(FAcciones.Cuerpo, #191'Qu'#233' desea hacer?', 11, True, FTema.Texto);
  FBtnAgregar := NuevoBoton(FAcciones.Cuerpo, 'Agregar documento', 'agregar', True, BotonAgregarClick);
  FBtnBuscar := NuevoBoton(FAcciones.Cuerpo, 'Buscar un documento', 'buscar', False, BotonBuscarClick);
  FBtnCuadro := NuevoBoton(FAcciones.Cuerpo, 'Ver cuadro de clasificaci'#243'n', 'cuadro', False,
    BotonCuadroClick);
  FBtnAgregar.Visible := False;
  FBtnCuadro.Visible := False;

  FCiclo := NuevaTarjeta;
  FCicloTitulo := NuevaEtiqueta(FCiclo.Cuerpo, 'Ciclo de vida del documento', 11, True, FTema.Texto);
  FCicloAyuda := NuevaEtiqueta(FCiclo.Cuerpo, 'Haga clic en una etapa para ir a ella.', 9, False,
    FTema.TextoSuave);
  for I := 0 to High(FEtapas) do
  begin
    FEtapas[I].Clave := ETAPAS_CLAVE[I];
    FEtapas[I].Accion := ETAPAS_ACCION[I];
    FEtapas[I].Tarjeta := NuevaTarjeta;
    FEtapas[I].Tarjeta.Marco.Parent := FCiclo.Cuerpo;
    FEtapas[I].Icono := TImage.Create(Self);
    FEtapas[I].Icono.Parent := FEtapas[I].Tarjeta.Cuerpo;
    FEtapas[I].Icono.Transparent := True;
    FEtapas[I].Nombre := NuevaEtiqueta(FEtapas[I].Tarjeta.Cuerpo, '', 9, True, FTema.Texto);
    FEtapas[I].Cifra := NuevaEtiqueta(FEtapas[I].Tarjeta.Cuerpo, '', 16, True, FTema.Acento);
    FEtapas[I].Pie := NuevaEtiqueta(FEtapas[I].Tarjeta.Cuerpo, '', 8, False, FTema.TextoSuave);
    FEtapas[I].Tarjeta.Marco.Tag := I;
    FEtapas[I].Tarjeta.Cuerpo.Tag := I;
    FEtapas[I].Icono.Tag := I;
    FEtapas[I].Nombre.Tag := I;
    FEtapas[I].Cifra.Tag := I;
    FEtapas[I].Pie.Tag := I;
    FEtapas[I].Tarjeta.Marco.OnClick := EtapaClick;
    FEtapas[I].Tarjeta.Cuerpo.OnClick := EtapaClick;
    FEtapas[I].Icono.OnClick := EtapaClick;
    FEtapas[I].Nombre.OnClick := EtapaClick;
    FEtapas[I].Cifra.OnClick := EtapaClick;
    FEtapas[I].Pie.OnClick := EtapaClick;
    PonerIcono(I, ETAPAS_ICONO[I]);
  end;
  FEtapas[0].Nombre.Caption := 'Captura';
  FEtapas[1].Nombre.Caption := 'Clasificaci'#243'n';
  FEtapas[2].Nombre.Caption := 'Ubicaci'#243'n';
  FEtapas[3].Nombre.Caption := 'Pr'#233'stamos';
  FEtapas[4].Nombre.Caption := 'Transferencia';
  FEtapas[5].Nombre.Caption := 'Depuraci'#243'n';
  FEtapas[0].Pie.Caption := 'documentos';
  FEtapas[1].Pie.Caption := 'subseries';
  FEtapas[2].Pie.Caption := 'sin ubicar';
  FEtapas[3].Pie.Caption := 'prestados';
  FEtapas[4].Pie.Caption := 'ir a traslados';
  FEtapas[5].Pie.Caption := 'ir a depuraci'#243'n';

  FPasos := NuevaTarjeta;
  FPasosTitulo := NuevaEtiqueta(FPasos.Cuerpo, 'Primeros pasos', 11, True, FTema.Texto);
  FPasosAlternar := NuevaEtiqueta(FPasos.Cuerpo, 'Ocultar', 9, False, FTema.Acento);
  FPasosAlternar.Alignment := taRightJustify;
  FPasosAlternar.Cursor := crHandPoint;
  FPasosAlternar.OnClick := AlternarClick;
  FPasosCuerpo := TPanel.Create(Self);
  FPasosCuerpo.Parent := FPasos.Cuerpo;
  FPasosCuerpo.BevelOuter := bvNone;
  FPasosCuerpo.ParentBackground := False;
  FPasosCuerpo.StyleElements := [];
  FPasosCuerpo.ShowCaption := False;
  FPasosCuerpo.Color := FTema.Superficie;
  for I := 0 to 2 do
  begin
    FPasosNum[I] := NuevaEtiqueta(FPasosCuerpo, IntToStr(I + 1), 10, True, FTema.Acento);
    FPasosNum[I].Alignment := taCenter;
    FPasosNum[I].Layout := tlCenter;
    FPasosNum[I].Transparent := False;
    FPasosNum[I].Color := FTema.AcentoSuave;
    FPasosTit[I] := NuevaEtiqueta(FPasosCuerpo, '', 9, True, FTema.Texto);
    FPasosTxt[I] := NuevaEtiqueta(FPasosCuerpo, '', 9, False, FTema.TextoSuave);
    FPasosTxt[I].WordWrap := True;
  end;
  FPasosTit[0].Caption := 'Elija su '#225'rea';
  FPasosTxt[0].Caption := 'En el '#225'rbol de la izquierda: una oficina o una serie.';
  FPasosTit[1].Caption := 'Elija la subserie';
  FPasosTxt[1].Caption := 'Aparece la lista de sus documentos.';
  FPasosTit[2].Caption := 'Agregue o busque';
  FPasosTxt[2].Caption := 'Arrastre archivos sobre la lista para adjuntarlos.';

  Distribuir;
end;

procedure TPanelInicio.PonerIcono(AEtapa: Integer; const ANombre: string);
var
  Bmp: Vcl.Graphics.TBitmap;
begin
  Bmp := Vcl.Graphics.TBitmap.Create;
  try
    Bmp.PixelFormat := pf24bit;
    Bmp.SetSize(24, 24);
    Bmp.Canvas.Brush.Color := FTema.Superficie;
    Bmp.Canvas.FillRect(Rect(0, 0, 24, 24));
    try
      TIconos.Lista.Draw(Bmp.Canvas, 0, 0, IndiceIcono(ANombre));
    except
      // sin iconos (p. ej. en las pruebas) la etapa queda sin dibujo
    end;
    FEtapas[AEtapa].Icono.Picture.Assign(Bmp);
  finally
    Bmp.Free;
  end;
end;

procedure TPanelInicio.Redimensionado(Sender: TObject);
begin
  Distribuir;
end;

{ Al ponerle contenedor ya hay ancho real: se reparten las tarjetas. }
procedure TPanelInicio.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if AParent <> nil then
    Distribuir;
end;

{ Reparte las tarjetas segun el ancho real; el contenido no pasa de ~1000 px. }
procedure TPanelInicio.Distribuir;
var
  Ancho, X0, Y, I, W, Alto, Gap, Tam: Integer;
begin
  if (FContexto = nil) or (FPasosCuerpo = nil) or (Parent = nil) then
    Exit;
  X0 := Esc(24);
  Ancho := ClientWidth - 2 * X0;
  if Ancho > Esc(1000) then
    Ancho := Esc(1000);
  if Ancho < Esc(420) then
    Ancho := Esc(420);
  Gap := Esc(12);
  Y := Esc(18);
  FContexto.SetBounds(X0, Y, Ancho, Esc(20));
  Inc(Y, Esc(30));

  // cifras
  W := (Ancho - Gap * 4) div 5;
  Alto := Esc(96);
  for I := 0 to High(FKpis) do
  begin
    FKpis[I].Marco.SetBounds(X0 + I * (W + Gap), Y, W, Alto);
    FKpiValor[I].SetBounds(Esc(14), Esc(8), W - Esc(24), Esc(48));
    FKpiTexto[I].SetBounds(Esc(14), Esc(60), W - Esc(24), Esc(20));
  end;
  Inc(Y, Alto + Gap);

  // acciones
  Alto := Esc(96);
  FAcciones.Marco.SetBounds(X0, Y, Ancho, Alto);
  FAccionesTitulo.SetBounds(Esc(16), Esc(12), Ancho - Esc(32), Esc(22));
  Tam := Esc(16);
  FBtnAgregar.SetBounds(Tam, Esc(42), Esc(220), Esc(40));
  Tam := Tam + Esc(220) + Esc(10);
  FBtnBuscar.SetBounds(Tam, Esc(42), Esc(240), Esc(40));
  Tam := Tam + Esc(240) + Esc(10);
  FBtnCuadro.SetBounds(Tam, Esc(42), Esc(280), Esc(40));
  if not FBtnAgregar.Visible then
  begin
    FBtnBuscar.Left := Esc(16);
    FBtnCuadro.Left := Esc(16) + Esc(240) + Esc(10);
  end;
  Inc(Y, Alto + Gap);

  // ciclo de vida
  Alto := Esc(172);
  FCiclo.Marco.SetBounds(X0, Y, Ancho, Alto);
  FCicloTitulo.SetBounds(Esc(16), Esc(12), Ancho - Esc(32), Esc(22));
  FCicloAyuda.SetBounds(Esc(16), Esc(34), Ancho - Esc(32), Esc(18));
  W := (Ancho - Esc(32) - Gap * 5) div 6;
  for I := 0 to High(FEtapas) do
  begin
    FEtapas[I].Tarjeta.Marco.SetBounds(Esc(16) + I * (W + Gap), Esc(62), W, Esc(98));
    FEtapas[I].Icono.SetBounds(Esc(10), Esc(8), 24, 24);
    FEtapas[I].Nombre.SetBounds(Esc(40), Esc(11), W - Esc(46), Esc(18));
    FEtapas[I].Cifra.SetBounds(Esc(10), Esc(38), W - Esc(20), Esc(36));
    FEtapas[I].Pie.SetBounds(Esc(10), Esc(76), W - Esc(20), Esc(16));
  end;
  Inc(Y, Alto + Gap);

  // primeros pasos
  FPasosTitulo.SetBounds(Esc(16), Esc(12), Esc(300), Esc(22));
  FPasosAlternar.SetBounds(Ancho - Esc(116), Esc(14), Esc(100), Esc(18));
  if FPasosOcultos then
  begin
    FPasosCuerpo.Visible := False;
    Alto := Esc(46);
  end
  else
  begin
    FPasosCuerpo.Visible := True;
    Alto := Esc(150);
    FPasosCuerpo.SetBounds(0, Esc(42), Ancho - 2, Esc(104));
    W := (Ancho - Esc(32) - Gap * 2) div 3;
    for I := 0 to 2 do
    begin
      FPasosNum[I].SetBounds(Esc(16) + I * (W + Gap), Esc(6), Esc(26), Esc(26));
      FPasosTit[I].SetBounds(Esc(16) + I * (W + Gap), Esc(38), W, Esc(18));
      FPasosTxt[I].SetBounds(Esc(16) + I * (W + Gap), Esc(58), W - Esc(8), Esc(40));
    end;
  end;
  FPasos.Marco.SetBounds(X0, Y, Ancho, Alto);
  if FPasosOcultos then
    FPasosAlternar.Caption := 'Mostrar'
  else
    FPasosAlternar.Caption := 'Ocultar';
  Inc(Y, Alto + Esc(24));
  VertScrollBar.Range := Y;
end;

function TPanelInicio.Permitido(const AClave: string): Boolean;
begin
  if AClave = 'buscar' then
    Exit(True);
  Result := FPermisos.Values[AClave] = '1';
end;

function TPanelInicio.IndiceDeClave(const AClave: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(ETAPAS_CLAVE) do
    if ETAPAS_CLAVE[I] = AClave then
      Exit(I);
end;

procedure TPanelInicio.ActualizarEtapas;
var
  I: Integer;
  Activa: Boolean;
begin
  for I := 0 to High(FEtapas) do
  begin
    Activa := (FEtapas[I].Accion <> '') and Permitido(FEtapas[I].Accion);
    if Activa then
      FEtapas[I].Tarjeta.Cuerpo.Cursor := crHandPoint
    else
      FEtapas[I].Tarjeta.Cuerpo.Cursor := crDefault;
    FEtapas[I].Icono.Cursor := FEtapas[I].Tarjeta.Cuerpo.Cursor;
    FEtapas[I].Nombre.Cursor := FEtapas[I].Tarjeta.Cuerpo.Cursor;
    FEtapas[I].Cifra.Cursor := FEtapas[I].Tarjeta.Cuerpo.Cursor;
    FEtapas[I].Pie.Cursor := FEtapas[I].Tarjeta.Cuerpo.Cursor;
    // sin permiso (o sin destino) la etapa se ve atenuada
    if Activa or (FEtapas[I].Accion = '') then
      FEtapas[I].Nombre.Font.Color := FTema.Texto
    else
      FEtapas[I].Nombre.Font.Color := FTema.TextoSuave;
  end;
  FBtnAgregar.Visible := Permitido('agregar');
  FBtnCuadro.Visible := Permitido('cuadro');
  Distribuir;
end;

procedure TPanelInicio.Mostrar(const AResumen: TResumenInicio; const ATitulo: string);
begin
  FResumen := AResumen;
  if ATitulo = '' then
    FContexto.Caption := 'Resumen de toda su '#225'rea'
  else
    FContexto.Caption := 'Resumen de ' + ATitulo + ' y todo lo que contiene';
  FKpiValor[0].Caption := Miles(AResumen.Series);
  FKpiValor[1].Caption := Miles(AResumen.Subseries);
  FKpiValor[2].Caption := Miles(AResumen.Documentos);
  FKpiValor[3].Caption := Miles(AResumen.SinUbicacion);
  FKpiValor[4].Caption := Miles(AResumen.Prestados);
  if AResumen.SinUbicacion > 0 then
    FKpiValor[3].Font.Color := FTema.Acento
  else
    FKpiValor[3].Font.Color := FTema.Texto;
  FEtapas[0].Cifra.Caption := Miles(AResumen.Documentos);
  FEtapas[1].Cifra.Caption := Miles(AResumen.Subseries);
  FEtapas[2].Cifra.Caption := Miles(AResumen.SinUbicacion);
  FEtapas[3].Cifra.Caption := Miles(AResumen.Prestados);
  FEtapas[4].Cifra.Caption := '';
  FEtapas[5].Cifra.Caption := '';
end;

procedure TPanelInicio.FijarPermiso(const AClave: string; APermitido: Boolean);
begin
  if APermitido then
    FPermisos.Values[AClave] := '1'
  else
    FPermisos.Values[AClave] := '0';
  ActualizarEtapas;
end;

function TPanelInicio.AccionVisible(const AClave: string): Boolean;
begin
  if AClave = 'agregar' then
    Result := FBtnAgregar.Visible
  else if AClave = 'cuadro' then
    Result := FBtnCuadro.Visible
  else
    Result := Permitido(AClave);
end;

procedure TPanelInicio.Pulsar(const AClave: string);
var
  I: Integer;
begin
  if Copy(AClave, 1, 6) = 'etapa:' then
  begin
    I := IndiceDeClave(AClave);
    if (I >= 0) and (FEtapas[I].Accion <> '') and Permitido(FEtapas[I].Accion) and
      Assigned(FOnAccion) then
      FOnAccion(FEtapas[I].Accion);
    Exit;
  end;
  if Permitido(AClave) and Assigned(FOnAccion) then
    FOnAccion(AClave);
end;

function TPanelInicio.TextoCifra(const AClave: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(CLAVES_KPI) do
    if CLAVES_KPI[I] = AClave then
      Exit(FKpiValor[I].Caption);
end;

procedure TPanelInicio.BotonAgregarClick(Sender: TObject);
begin
  Pulsar('agregar');
end;

procedure TPanelInicio.BotonBuscarClick(Sender: TObject);
begin
  Pulsar('buscar');
end;

procedure TPanelInicio.BotonCuadroClick(Sender: TObject);
begin
  Pulsar('cuadro');
end;

procedure TPanelInicio.EtapaClick(Sender: TObject);
begin
  Pulsar(ETAPAS_CLAVE[TControl(Sender).Tag]);
end;

function TPanelInicio.PasosVisibles: Boolean;
begin
  Result := not FPasosOcultos;
end;

procedure TPanelInicio.AlternarPasos;
begin
  FPasosOcultos := not FPasosOcultos;
  GuardarPasos;
  Distribuir;
end;

procedure TPanelInicio.AlternarClick(Sender: TObject);
begin
  AlternarPasos;
end;

procedure TPanelInicio.SetArchivoConfig(const Valor: string);
var
  Ini: TIniFile;
begin
  FArchivoConfig := Valor;
  FPasosOcultos := False;
  if (Valor <> '') and FileExists(Valor) then
  try
    Ini := TIniFile.Create(Valor);
    try
      FPasosOcultos := Ini.ReadBool('Inicio', 'PasosOcultos', False);
    finally
      Ini.Free;
    end;
  except
    FPasosOcultos := False;
  end;
  Distribuir;
end;

procedure TPanelInicio.GuardarPasos;
var
  Ini: TIniFile;
begin
  if FArchivoConfig = '' then
    Exit;
  try
    ForceDirectories(ExtractFilePath(FArchivoConfig));
    Ini := TIniFile.Create(FArchivoConfig);
    try
      Ini.WriteBool('Inicio', 'PasosOcultos', FPasosOcultos);
    finally
      Ini.Free;
    end;
  except
    // recordar el pliegue es una comodidad, no un requisito
  end;
end;

end.
