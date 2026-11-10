unit UPruebasPanelDocumentos;

{ Panel de documentos (VCL): crea la ventana de verdad (consola con mensajes
  procesados a mano) y cuenta los controles vivos. Detecta etiquetas que no se
  liberan o se duplican al reconstruir las propiedades. Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasPanelDocumentos = class
  public
    [Test]
    procedure SeleccionarDocumento_NoDejaElAvisoNiDuplicados;
    [Test]
    procedure RedimensionarVariasVeces_NoDuplicaEtiquetas;
    [Test]
    procedure SeleccionarDocumento_LaPantallaEsIgualQueUnRepintadoLimpio;
    [Test]
    procedure Propiedades_TituloLargo_AlturaCubreElTexto;
    [Test]
    procedure Propiedades_SinEventos_QuedaCompletoDentroDelContenido;
    [Test]
    procedure Propiedades_MensajeReemplazaTodo;
    [Test]
    procedure Propiedades_ClicEnVerHistoria_DisparaEvento;
    [Test]
    procedure Contenido_SeCargaAlAbrirLaPestanaYNoAlSeleccionar;
    [Test]
    procedure Contenido_NoPdf_MuestraElMotivo;
    [Test]
    procedure Contenido_SinEvento_DiceNoDisponible;
    [Test]
    procedure Metadatos_SinEvento_DiceQueNoDefine;
    [Test]
    procedure Metadatos_ConEvento_MuestraEtiquetasYValores;
    [Test]
    procedure Seleccion_PonePestanasCabeceraYContadorDeArchivos;
    [Test]
    procedure Filtro_PorTexto_DejaSoloLosQueCoinciden;
    [Test]
    procedure Filtro_SinResultados_MuestraTextoYNoSeleccion;
    [Test]
    procedure Filtro_PorEstado_Prestado;
    [Test]
    procedure Cargar_ConEstados_MuestraColumna;
  end;

implementation

uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages, Vcl.Graphics, Vcl.Controls,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, UPanelDocumentos,
  UDocumentoVista, UListaPropiedades, UTrazabilidad;

const
  AVISO = 'Elija un documento para ver sus propiedades';

function BuscarProp(Padre: TWinControl): TListaPropiedades;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Padre.ControlCount - 1 do
  begin
    if Padre.Controls[I] is TListaPropiedades then
      Exit(TListaPropiedades(Padre.Controls[I]));
    if Padre.Controls[I] is TWinControl then
    begin
      Result := BuscarProp(TWinControl(Padre.Controls[I]));
      if Result <> nil then
        Exit;
    end;
  end;
end;

{ Cuantas veces aparece Texto en lo que muestra el panel de propiedades. }
function Cuenta(Padre: TWinControl; const Texto: string): Integer;
var
  C: string;
  P: Integer;
begin
  Result := 0;
  C := BuscarProp(Padre).Contenido;
  P := Pos(Texto, C);
  while P > 0 do
  begin
    Inc(Result);
    P := Pos(Texto, C, P + Length(Texto));
  end;
end;

function BuscarLista(Padre: TWinControl): TListView;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Padre.ControlCount - 1 do
  begin
    // la lista de documentos es virtual; el visor de PDF tiene listas propias
    if (Padre.Controls[I] is TListView) and TListView(Padre.Controls[I]).OwnerData then
      Exit(TListView(Padre.Controls[I]));
    if Padre.Controls[I] is TWinControl then
    begin
      Result := BuscarLista(TWinControl(Padre.Controls[I]));
      if Result <> nil then
        Exit;
    end;
  end;
end;

{ Cuantos pixeles de la pantalla difieren de un repintado limpio del control. }
function PixelesDistintos(W: TWinControl; out Total: Integer): Integer;
var
  Pant, Limpio: TBitmap;
  DC: HDC;
  Pt: TPoint;
  X, Y: Integer;
begin
  Pant := TBitmap.Create;
  Limpio := TBitmap.Create;
  try
    Pant.PixelFormat := pf24bit;
    Limpio.PixelFormat := pf24bit;
    Pant.SetSize(W.ClientWidth, W.ClientHeight);
    Limpio.SetSize(W.ClientWidth, W.ClientHeight);
    Pt := W.ClientToScreen(Point(0, 0));
    DC := GetDC(0);
    try
      BitBlt(Pant.Canvas.Handle, 0, 0, Pant.Width, Pant.Height, DC, Pt.X, Pt.Y, SRCCOPY);
    finally
      ReleaseDC(0, DC);
    end;
    W.PaintTo(Limpio.Canvas.Handle, 0, 0);
    Result := 0;
    Total := Pant.Width * Pant.Height;
    for Y := 0 to Pant.Height - 1 do
      for X := 0 to Pant.Width - 1 do
        if Pant.Canvas.Pixels[X, Y] <> Limpio.Canvas.Pixels[X, Y] then
          Inc(Result);
  finally
    Pant.Free;
    Limpio.Free;
  end;
end;

function Documentos: TArray<TDatosDocumento>;
var
  I: Integer;
begin
  SetLength(Result, 3);
  for I := 0 to 2 do
  begin
    Result[I] := Default(TDatosDocumento);
    Result[I].Clave.IdEstructura := 'A.4.3';
    Result[I].Clave.Id := 104;
    Result[I].Clave.CodSubs := '074';
    Result[I].Clave.Version := '1';
    Result[I].Clave.Codigodoc := 'A 03.01.02.000' + IntToStr(I + 1);
    Result[I].Clave.Fecha := EncodeDate(2014, 1, 1);
    Result[I].Titulo := 'Alcantarillado Palma Soriano. Colector 30 de noviembre. ' +
      'Estudio Ingeniero Geologico. Documento ' + IntToStr(I + 1);
    Result[I].IdExpediente := 'P-006';
    Result[I].Archivo := 'Archivo 2';
    Result[I].Deposito := 'Deposito 01';
    Result[I].Gaveta := 'Gaveta 02';
    Result[I].Posicion := 'Posicion 3';
  end;
end;

procedure PonerAlDia;
var
  I: Integer;
begin
  for I := 1 to 5 do
    Application.ProcessMessages;
end;

procedure TPruebasPanelDocumentos.SeleccionarDocumento_NoDejaElAvisoNiDuplicados;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
begin
  F := TForm.CreateNew(nil);
  try
    F.SetBounds(0, 0, 1100, 700);
    P := TPanelDocumentos.Create(F);
    P.Parent := F;
    P.Align := alClient;
    F.Show;
    PonerAlDia;
    P.Cargar(Documentos, 'Prueba');
    PonerAlDia;
    LV := BuscarLista(P);
    Assert.IsNotNull(LV);
    Assert.AreEqual(1, Cuenta(P, AVISO), 'antes de seleccionar el aviso se ve una vez');
    LV.Items[1].Selected := True;
    PonerAlDia;
    Assert.AreEqual(0, Cuenta(P, AVISO), 'seleccionado un documento no debe quedar el aviso');
    Assert.AreEqual(1, Cuenta(P, 'GENERAL'), 'un solo grupo GENERAL');
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.RedimensionarVariasVeces_NoDuplicaEtiquetas;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
  I: Integer;
begin
  F := TForm.CreateNew(nil);
  try
    F.SetBounds(0, 0, 1100, 700);
    P := TPanelDocumentos.Create(F);
    P.Parent := F;
    P.Align := alClient;
    F.Show;
    PonerAlDia;
    P.Cargar(Documentos, 'Prueba');
    LV := BuscarLista(P);
    LV.Items[0].Selected := True;
    PonerAlDia;
    for I := 1 to 6 do
    begin
      F.Width := 900 + I * 40;
      F.Height := 480 + I * 25;
      PonerAlDia;
    end;
    Assert.AreEqual(0, Cuenta(P, AVISO));
    Assert.AreEqual(1, Cuenta(P, 'GENERAL'));
    LV.Items[2].Selected := True;
    PonerAlDia;
    Assert.AreEqual(0, Cuenta(P, AVISO));
    Assert.AreEqual(1, Cuenta(P, 'GENERAL'));
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.SeleccionarDocumento_LaPantallaEsIgualQueUnRepintadoLimpio;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
  Dist, Total: Integer;
begin
  F := TForm.CreateNew(nil);
  try
    F.SetBounds(50, 50, 1100, 420);
    P := TPanelDocumentos.Create(F);
    P.Parent := F;
    P.Align := alClient;
    F.Show;
    PonerAlDia;
    P.Cargar(Documentos, 'Prueba');
    PonerAlDia;
    LV := BuscarLista(P);
    LV.Items[1].Selected := True;
    PonerAlDia;
    Dist := PixelesDistintos(BuscarProp(P), Total);
    RedrawWindow(BuscarProp(P).Handle, nil, 0,
      RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN or RDW_UPDATENOW);
    PonerAlDia;
    Assert.AreEqual(PixelesDistintos(BuscarProp(P), Total), Dist,
      Format('tras forzar repintado: distintos %d de %d (antes %d)',
      [PixelesDistintos(BuscarProp(P), Total), Total, Dist]));
  finally
    F.Free;
  end;
end;

{ Control suelto sobre un formulario, ya con ventana. }
function NuevaProp(F: TForm; Ancho, Alto: Integer): TListaPropiedades;
begin
  F.SetBounds(50, 50, Ancho + 40, Alto + 60);
  Result := TListaPropiedades.Create(F);
  Result.Parent := F;
  Result.SetBounds(0, 0, Ancho, Alto);
  F.Show;
  PonerAlDia;
end;

function UnaPropiedad(const Valor: string): TArray<TPropiedad>;
begin
  SetLength(Result, 1);
  Result[0].Grupo := 'General';
  Result[0].Etiqueta := 'Titulo';
  Result[0].Valor := Valor;
end;

procedure TPruebasPanelDocumentos.Propiedades_TituloLargo_AlturaCubreElTexto;
var
  F: TForm;
  PL: TListaPropiedades;
  B: TBitmap;
  R: TRect;
  Largo: string;
  I: Integer;
begin
  Largo := '';
  for I := 1 to 20 do
    Largo := Largo + 'Alcantarillado ';
  F := TForm.CreateNew(nil);
  B := TBitmap.Create;
  try
    PL := NuevaProp(F, 300, 300);
    PL.Mostrar(UnaPropiedad(Largo), nil, False, '', True);
    // medida independiente del mismo texto a la letra y el ancho del valor
    B.Canvas.Font.Name := 'Segoe UI';
    B.Canvas.Font.Size := 10;
    R := Rect(0, 0, PL.ClientWidth - 28, 0);
    DrawText(B.Canvas.Handle, PChar(Largo), Length(Largo), R,
      DT_WORDBREAK or DT_NOPREFIX or DT_CALCRECT);
    Assert.IsTrue(PL.AlturaContenido >= R.Bottom + 60,
      Format('alto %d no cubre las lineas del titulo (%d)', [PL.AlturaContenido, R.Bottom]));
  finally
    B.Free;
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Propiedades_SinEventos_QuedaCompletoDentroDelContenido;
var
  F: TForm;
  PL: TListaPropiedades;
  B: TBitmap;
  X, Y, TintaUltimas, TintaDebajo: Integer;
  Fondo: TColor;
begin
  F := TForm.CreateNew(nil);
  B := TBitmap.Create;
  try
    PL := NuevaProp(F, 300, 200);
    PL.Mostrar(UnaPropiedad('Corto'), nil, False, '', True);
    PL.Height := PL.AlturaContenido + 40; // cabe todo: sin desplazamiento
    PonerAlDia;
    PL.Mostrar(UnaPropiedad('Corto'), nil, False, '', True);
    PonerAlDia;
    Assert.IsTrue(Pos('Sin eventos registrados', PL.Contenido) > 0);
    B.PixelFormat := pf24bit;
    B.SetSize(PL.ClientWidth, PL.ClientHeight);
    PL.PaintTo(B.Canvas.Handle, 0, 0);
    Fondo := B.Canvas.Pixels[1, 1];
    TintaUltimas := 0;
    TintaDebajo := 0;
    for Y := 0 to B.Height - 1 do
      for X := 0 to B.Width - 1 do
        if B.Canvas.Pixels[X, Y] <> Fondo then
        begin
          if Y >= PL.AlturaContenido - 40 then
            Inc(TintaUltimas);
          if Y >= PL.AlturaContenido then
            Inc(TintaDebajo);
        end;
    Assert.IsTrue(TintaUltimas > 0, 'la ultima fila (Sin eventos registrados) debe verse');
    Assert.AreEqual(0, TintaDebajo, 'no se dibuja nada fuera del contenido medido');
  finally
    B.Free;
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Propiedades_MensajeReemplazaTodo;
var
  F: TForm;
  PL: TListaPropiedades;
  Dist, Total: Integer;
begin
  F := TForm.CreateNew(nil);
  try
    PL := NuevaProp(F, 320, 300);
    PL.Mostrar(UnaPropiedad('Documento de prueba'), nil, False, '', True);
    PonerAlDia;
    PL.MostrarMensaje('Elija un documento para ver sus propiedades');
    PonerAlDia;
    Assert.AreEqual(0, Pos('GENERAL', PL.Contenido));
    Assert.IsTrue(Pos('Elija un documento', PL.Contenido) > 0);
    // lo que se ve ahora debe ser lo mismo que tras forzar un repintado completo
    Dist := PixelesDistintos(PL, Total);
    RedrawWindow(PL.Handle, nil, 0,
      RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN or RDW_UPDATENOW);
    PonerAlDia;
    Assert.AreEqual(PixelesDistintos(PL, Total), Dist,
      'la pantalla debe ser igual tras forzar el repintado');
  finally
    F.Free;
  end;
end;

var
  GVerHistoria: Integer;

type
  TReceptor = class
    procedure Ver(Sender: TObject);
  end;

procedure TReceptor.Ver(Sender: TObject);
begin
  Inc(GVerHistoria);
end;

procedure TPruebasPanelDocumentos.Propiedades_ClicEnVerHistoria_DisparaEvento;
var
  F: TForm;
  PL: TListaPropiedades;
  Rec: TReceptor;
  Ev: TArray<TEventoDoc>;
  R: TRect;
begin
  GVerHistoria := 0;
  Rec := TReceptor.Create;
  F := TForm.CreateNew(nil);
  try
    PL := NuevaProp(F, 320, 400);
    PL.OnVerHistoria := Rec.Ver;
    SetLength(Ev, 1);
    Ev[0].Fecha := EncodeDate(2026, 11, 9);
    Ev[0].Tipo := teConsultado;
    Ev[0].Usuario := 'MAGO';
    PL.Mostrar(UnaPropiedad('X'), Ev, False, '', True);
    PonerAlDia;
    R := PL.RectEnlaceHistoria;
    Assert.IsTrue(R.Right > R.Left, 'con eventos hay enlace');
    PL.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(R.Left + 4, R.Top + 4));
    PL.Perform(WM_LBUTTONUP, 0, MakeLong(R.Left + 4, R.Top + 4));
    Assert.AreEqual(1, GVerHistoria);
    PL.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(2, 2));
    Assert.AreEqual(1, GVerHistoria, 'un clic fuera del enlace no dispara');
  finally
    F.Free;
    Rec.Free;
  end;
end;

{ Panel ya cargado con los tres documentos de prueba (el 2.o prestado). }
function PanelCargado(F: TForm): TPanelDocumentos;
var
  D: TArray<TDatosDocumento>;
begin
  F.SetBounds(50, 50, 1100, 500);
  Result := TPanelDocumentos.Create(F);
  Result.Parent := F;
  Result.Align := alClient;
  F.Show;
  PonerAlDia;
  D := Documentos;
  D[0].Estado := edEnArchivo;
  D[1].Estado := edPrestado;
  D[2].Estado := edEnArchivo;
  Result.Cargar(D, 'Prueba');
  PonerAlDia;
end;

function HayEtiquetaVisible(Padre: TWinControl; const Texto: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Padre.ControlCount - 1 do
  begin
    if (Padre.Controls[I] is TLabel) and Padre.Controls[I].Visible and
      (TLabel(Padre.Controls[I]).Caption = Texto) then
      Exit(True);
    if (Padre.Controls[I] is TWinControl) and
      HayEtiquetaVisible(TWinControl(Padre.Controls[I]), Texto) then
      Exit(True);
  end;
end;

type
  TProveedorMeta = class
    Vacio: Boolean;
    function Pedir(const Clave: TClaveDocumento): TArray<TPropiedad>;
  end;

function TProveedorMeta.Pedir(const Clave: TClaveDocumento): TArray<TPropiedad>;
begin
  Result := nil;
  if Vacio then
    Exit;
  SetLength(Result, 2);
  Result[0].Grupo := 'Proyectos';
  Result[0].Etiqueta := 'Municipio';
  Result[0].Valor := 'Palma Soriano';
  Result[1].Grupo := 'Proyectos';
  Result[1].Etiqueta := 'Ejecutor';
  Result[1].Valor := '';
end;

function BuscarListaMeta(P: TPanelDocumentos): TListaPropiedades;
var
  Pag: TWinControl;
  I: Integer;
begin
  Result := nil;
  Pag := P.Documento.Pagina(pdMetadatos);
  for I := 0 to Pag.ControlCount - 1 do
    if Pag.Controls[I] is TListaPropiedades then
      Result := TListaPropiedades(Pag.Controls[I]);
end;

type
  TProveedorContenido = class
    Llamadas: Integer;
    function Pedir(const Clave: TClaveDocumento; out Motivo: string): string;
  end;

function TProveedorContenido.Pedir(const Clave: TClaveDocumento; out Motivo: string): string;
begin
  Inc(Llamadas);
  Motivo := 'El contenido incrustado solo admite PDF; abra el archivo desde Archivos.';
  Result := '';
end;

procedure TPruebasPanelDocumentos.Contenido_SeCargaAlAbrirLaPestanaYNoAlSeleccionar;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
  Prov: TProveedorContenido;
begin
  F := TForm.CreateNew(nil);
  Prov := TProveedorContenido.Create;
  try
    P := PanelCargado(F);
    P.OnPedirContenido := Prov.Pedir;
    LV := BuscarLista(P);
    LV.Items[0].Selected := True;
    PonerAlDia;
    Assert.AreEqual(0, Prov.Llamadas, 'seleccionar no descarga el contenido');
    P.Documento.Activar(pdContenido);
    PonerAlDia;
    Assert.AreEqual(1, Prov.Llamadas, 'al abrir la pestana se pide una vez');
    LV.Items[1].Selected := True;
    PonerAlDia;
    Assert.AreEqual(2, Prov.Llamadas, 'con la pestana abierta, cambiar de documento lo vuelve a pedir');
  finally
    F.Free;
    Prov.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Contenido_NoPdf_MuestraElMotivo;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
  Prov: TProveedorContenido;
begin
  F := TForm.CreateNew(nil);
  Prov := TProveedorContenido.Create;
  try
    P := PanelCargado(F);
    P.OnPedirContenido := Prov.Pedir;
    LV := BuscarLista(P);
    LV.Items[0].Selected := True;
    P.Documento.Activar(pdContenido);
    PonerAlDia;
    Assert.IsTrue(Pos('solo admite PDF', P.Visor.TextoMensaje) > 0);
  finally
    F.Free;
    Prov.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Contenido_SinEvento_DiceNoDisponible;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
begin
  F := TForm.CreateNew(nil);
  try
    P := PanelCargado(F);
    LV := BuscarLista(P);
    LV.Items[0].Selected := True;
    P.Documento.Activar(pdContenido);
    PonerAlDia;
    Assert.IsTrue(Pos('no esta disponible', P.Visor.TextoMensaje) > 0);
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Metadatos_SinEvento_DiceQueNoDefine;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
begin
  F := TForm.CreateNew(nil);
  try
    P := PanelCargado(F);
    LV := BuscarLista(P);
    LV.Items[0].Selected := True;
    PonerAlDia;
    Assert.IsTrue(Pos('no define metadatos', BuscarListaMeta(P).Contenido) > 0);
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Metadatos_ConEvento_MuestraEtiquetasYValores;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
  Prov: TProveedorMeta;
begin
  F := TForm.CreateNew(nil);
  Prov := TProveedorMeta.Create;
  try
    P := PanelCargado(F);
    P.OnPedirMetadatos := Prov.Pedir;
    LV := BuscarLista(P);
    LV.Items[0].Selected := True;
    PonerAlDia;
    Assert.IsTrue(Pos('Municipio', BuscarListaMeta(P).Contenido) > 0);
    Assert.IsTrue(Pos('Palma Soriano', BuscarListaMeta(P).Contenido) > 0);
    Assert.IsTrue(Pos('-', BuscarListaMeta(P).Contenido) > 0, 'el valor vacio va con guion');
  finally
    F.Free;
    Prov.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Seleccion_PonePestanasCabeceraYContadorDeArchivos;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
begin
  F := TForm.CreateNew(nil);
  try
    P := PanelCargado(F);
    Assert.AreEqual('Sin documento', P.Documento.TextoCodigo);
    LV := BuscarLista(P);
    LV.Items[1].Selected := True;
    PonerAlDia;
    Assert.AreEqual('A 03.01.02.0002', P.Documento.TextoCodigo);
    Assert.AreEqual('Prestado', P.Documento.TextoEstado);
    Assert.IsTrue(Pos('GENERAL', BuscarProp(P).Contenido) > 0,
      'la pestana Datos muestra el grupo General');
    Assert.IsFalse(Pos('POSICION FISICA', BuscarProp(P).Contenido) > 0,
      'la ubicacion ya no va en la pestana Datos');
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Filtro_PorTexto_DejaSoloLosQueCoinciden;
var
  F: TForm;
  P: TPanelDocumentos;
begin
  F := TForm.CreateNew(nil);
  try
    P := PanelCargado(F);
    Assert.AreEqual(3, P.CantidadVisibles);
    P.FijarFiltro('documento 2', False, edDesconocido);
    Assert.AreEqual(1, P.CantidadVisibles);
    P.FijarFiltro('', False, edDesconocido);
    Assert.AreEqual(3, P.CantidadVisibles);
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Filtro_SinResultados_MuestraTextoYNoSeleccion;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
begin
  F := TForm.CreateNew(nil);
  try
    P := PanelCargado(F);
    LV := BuscarLista(P);
    LV.Items[0].Selected := True;
    PonerAlDia;
    P.FijarFiltro('zzz-no-existe', False, edDesconocido);
    PonerAlDia;
    Assert.AreEqual(0, P.CantidadVisibles);
    Assert.IsTrue(HayEtiquetaVisible(P, 'Ningun documento coincide'));
    Assert.IsTrue(Pos(AVISO, BuscarProp(P).Contenido) > 0,
      'sin seleccion, las propiedades vuelven al texto guia');
    P.FijarFiltro('', False, edDesconocido);
    PonerAlDia;
    Assert.IsFalse(HayEtiquetaVisible(P, 'Ningun documento coincide'));
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Filtro_PorEstado_Prestado;
var
  F: TForm;
  P: TPanelDocumentos;
begin
  F := TForm.CreateNew(nil);
  try
    P := PanelCargado(F);
    P.FijarFiltro('', True, edPrestado);
    Assert.AreEqual(1, P.CantidadVisibles);
    P.FijarFiltro('', True, edEnArchivo);
    Assert.AreEqual(2, P.CantidadVisibles);
  finally
    F.Free;
  end;
end;

procedure TPruebasPanelDocumentos.Cargar_ConEstados_MuestraColumna;
var
  F: TForm;
  P: TPanelDocumentos;
  LV: TListView;
  I, Col: Integer;
  Esta: Boolean;
begin
  F := TForm.CreateNew(nil);
  try
    P := PanelCargado(F);
    LV := BuscarLista(P);
    Col := -1;
    for I := 0 to LV.Columns.Count - 1 do
      if LV.Columns[I].Caption = 'Estado' then
        Col := I;
    Assert.IsTrue(Col > 0, 'falta la columna Estado');
    Esta := False;
    for I := 0 to LV.Items.Count - 1 do
      if LV.Items[I].SubItems[Col - 1] = 'Prestado' then
        Esta := True;
    Assert.IsTrue(Esta, 'el documento prestado debe decir Prestado');
  finally
    F.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasPanelDocumentos);

end.
