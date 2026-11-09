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
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Forms, UTema, UDocumentoVista, UTrazabilidad;

type
  TSolicitudFicheros = function(const Clave: TClaveDocumento): TArray<TFicheroDoc> of object;
  TClaveEvent = procedure(const Clave: TClaveDocumento) of object;
  TSolicitudHistoria = function(const Clave: TClaveDocumento;
    out HayMas: Boolean): TArray<TEventoDoc> of object;

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
    FFicherosActuales: TArray<TFicheroDoc>;
    FEtiquetas: TObjectList<TControl>;
    FBarra: TPanel;
    FLblTitulo: TLabel;
    FLblFiltro: TLabel;
    FEnlaceTodos: TLabel;
    FBtnVista: TButton;
    FLista: TListView;
    FVacio: TLabel;
    FSplitter: TSplitter;
    FDer: TPanel;
    FScroll: TScrollBox;
    FPie: TPanel;
    FBtnAbrir: TButton;
    FBtnExpediente: TButton;
    FEnlaceExp: TLabel;
    FOnSeleccion: TClaveEvent;
    FOnAbrirContenido: TClaveEvent;
    FOnExpedienteCompleto: TClaveEvent;
    FOnPedirFicheros: TSolicitudFicheros;
    FOnAlternarVista: TNotifyEvent;
    FConstruido: Boolean;
    FErrorFicheros: Boolean;
    FOnPedirHistoria: TSolicitudHistoria;
    FHistoriaActual: TArray<TEventoDoc>;
    FHayMasHistoria: Boolean;
    FTituloHistoria: string;
    function IconoIdx(const Nombre: string): Integer;
    function NuevaEtiqueta(const Texto: string; Tam: Integer; Color: TColor;
      Negrita: Boolean): TLabel;
    procedure Construir;
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
    procedure VistaClick(Sender: TObject);
    procedure EnlaceExpClick(Sender: TObject);
    procedure HistoriaClick(Sender: TObject);
    procedure EnlaceTodosClick(Sender: TObject);
    procedure ScrollResize(Sender: TObject);
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
    property ExpedienteFiltrado: string read FExpFiltrado;
    property OnSeleccion: TClaveEvent read FOnSeleccion write FOnSeleccion;
    property OnAbrirContenido: TClaveEvent read FOnAbrirContenido write FOnAbrirContenido;
    { Obtener el expediente completo (ficheros del expediente y de sus documentos) }
    property OnExpedienteCompleto: TClaveEvent read FOnExpedienteCompleto write FOnExpedienteCompleto;
    property OnPedirFicheros: TSolicitudFicheros read FOnPedirFicheros write FOnPedirFicheros;
    property OnAlternarVista: TNotifyEvent read FOnAlternarVista write FOnAlternarVista;
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
  FEtiquetas := TObjectList<TControl>.Create(True);
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
  // los controles de propiedades pertenecen a FScroll: se sueltan sin liberar
  FEtiquetas.OwnsObjects := False;
  FEtiquetas.Free;
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

  FBtnVista := TButton.Create(Self);
  FBtnVista.Parent := FBarra;
  FBtnVista.Caption := 'Ver rejilla';
  FBtnVista.Align := alRight;
  FBtnVista.Width := 110;
  FBtnVista.AlignWithMargins := True;
  FBtnVista.Margins.SetBounds(6, 8, 10, 8);
  FBtnVista.OnClick := VistaClick;

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

  FPie := TPanel.Create(Self);
  FPie.Parent := FDer;
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

  FScroll := TScrollBox.Create(Self);
  FScroll.Parent := FDer;
  FScroll.Align := alClient;
  FScroll.BorderStyle := bsNone;
  FScroll.HorzScrollBar.Visible := False;
  FScroll.StyleElements := [];
  FScroll.Color := FTema.Superficie;
  FScroll.OnResize := ScrollResize;

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
  I: Integer;
begin
  FVisibles := FiltrarPorExpediente(FTodos, FExpFiltrado);
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
  FVacio.Caption := 'Esta subserie aun no tiene documentos';
  FVacio.Visible := Length(FVisibles) = 0;
  LimpiarPropiedades;
  ActualizarBarra;
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
  Item.SubItems.Add(Ficheros);
  Item.SubItems.Add('');
  Geo := NombreInsigniaGeo(C);
  if Geo <> '' then
    Item.SubItemImages[4] := IconoIdx(Geo);
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

procedure TPanelDocumentos.VistaClick(Sender: TObject);
begin
  if Assigned(FOnAlternarVista) then
    FOnAlternarVista(Self);
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

procedure TPanelDocumentos.ScrollResize(Sender: TObject);
begin
  if (FIndiceActual >= 0) and (FIndiceActual < Length(FVisibles)) then
    MostrarPropiedades(FIndiceActual)
  else
    LimpiarPropiedades;
end;

procedure TPanelDocumentos.HistoriaClick(Sender: TObject);
begin
  MostrarHistoria(FTituloHistoria, FHistoriaActual, FHayMasHistoria, FTema);
end;

procedure TPanelDocumentos.LimpiarPropiedades;
var
  L: TLabel;
begin
  FFicherosActuales := nil;
  FHistoriaActual := nil;
  FEtiquetas.OwnsObjects := True;
  FEtiquetas.Clear;
  FBtnAbrir.Enabled := False;
  FBtnExpediente.Visible := False;
  FEnlaceExp.Visible := False;
  L := NuevaEtiqueta('Elija un documento para ver sus propiedades', 9,
    FTema.TextoSuave, False);
  L.Parent := FScroll;
  L.AutoSize := False;
  L.WordWrap := True;
  L.SetBounds(14, 16, Max(120, FScroll.ClientWidth - 28), 40);
  FEtiquetas.Add(L);
end;

procedure TPanelDocumentos.MostrarPropiedades(Indice: Integer);
var
  D: TDatosDocumento;
  Props: TArray<TPropiedad>;
  I, Y, Ancho, Digitales: Integer;
  GrupoActual: string;
  Lbl, Val: TLabel;
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

  FScroll.DisableAlign;
  try
    FEtiquetas.OwnsObjects := True;
    FEtiquetas.Clear;
    Ancho := Max(120, FScroll.ClientWidth - 28);
    Y := 10;
    GrupoActual := '';
    for I := 0 to High(Props) do
    begin
      if Props[I].Grupo <> GrupoActual then
      begin
        GrupoActual := Props[I].Grupo;
        Lbl := NuevaEtiqueta(UpperCase(GrupoActual), 8, FTema.Acento, True);
        Lbl.Parent := FScroll;
        Lbl.Left := 14;
        Lbl.Top := Y + 6;
        FEtiquetas.Add(Lbl);
        Inc(Y, Lbl.Height + 10);
      end;
      Lbl := NuevaEtiqueta(Props[I].Etiqueta, 8, FTema.TextoSuave, False);
      Lbl.Parent := FScroll;
      Lbl.Left := 14;
      Lbl.Top := Y;
      FEtiquetas.Add(Lbl);
      Inc(Y, Lbl.Height);
      Val := NuevaEtiqueta('', 10, FTema.Texto, False);
      Val.AutoSize := False;
      Val.WordWrap := True;
      Val.Parent := FScroll;
      Val.SetBounds(14, Y, Ancho, 20);
      Val.Caption := Props[I].Valor;
      Val.AutoSize := True; // con WordWrap el alto sale del ancho fijado
      FEtiquetas.Add(Val);
      Inc(Y, Val.Height + 4);
    end;

    // Historia del documento: los 5 eventos mas recientes y el enlace a todos
    FHistoriaActual := nil;
    FHayMasHistoria := False;
    FTituloHistoria := D.Titulo;
    if Assigned(FOnPedirHistoria) then
    begin
      try
        FHistoriaActual := FOnPedirHistoria(D.Clave, FHayMasHistoria);
      except
        FHistoriaActual := nil;
      end;
      Lbl := NuevaEtiqueta('HISTORIA', 8, FTema.Acento, True);
      Lbl.Parent := FScroll;
      Lbl.Left := 14;
      Lbl.Top := Y + 6;
      FEtiquetas.Add(Lbl);
      Inc(Y, Lbl.Height + 10);
      if Length(FHistoriaActual) = 0 then
      begin
        Val := NuevaEtiqueta('Sin eventos registrados', 9, FTema.TextoSuave, False);
        Val.Parent := FScroll;
        Val.SetBounds(14, Y, Ancho, 16);
        FEtiquetas.Add(Val);
        Inc(Y, Val.Height + 4);
      end
      else
      begin
        for I := 0 to Min(4, High(FHistoriaActual)) do
        begin
          Val := NuevaEtiqueta(TextoFechaEvento(FHistoriaActual[I].Fecha) + '  ' +
            EtiquetaEvento(FHistoriaActual[I].Tipo) + '  ' + FHistoriaActual[I].Usuario,
            9, FTema.Texto, False);
          Val.Parent := FScroll;
          Val.SetBounds(14, Y, Ancho, 16);
          FEtiquetas.Add(Val);
          Inc(Y, Val.Height + 3);
        end;
        Val := NuevaEtiqueta('Ver historia completa', 9, FTema.Acento, False);
        Val.Parent := FScroll;
        Val.Font.Style := [fsUnderline];
        Val.Cursor := crHandPoint;
        Val.SetBounds(14, Y + 4, 200, 16);
        Val.OnClick := HistoriaClick;
        FEtiquetas.Add(Val);
        Inc(Y, Val.Height + 8);
      end;
    end;
  finally
    FScroll.EnableAlign;
  end;

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
