unit UBusquedaDocumentos;

{ Pantalla provisional de busqueda integrada de documentos (Fase 4).
  Caja de texto libre, subserie opcional y, al elegir una subserie, un filtro
  por cada campo de cl_VarSubserie segun su tipo. Siempre busca dentro del
  alcance del usuario (UDM.Alcance). La logica vive en UBusqueda y
  UBusquedaDatos; aqui solo se captura y se muestra. Construida por codigo
  (sin .dfm). Se reubica cuando exista el shell nuevo de la Fase 1. }

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Vcl.Controls,
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, UAlcance, UBusqueda;

type
  { Pide al shell seleccionar el nodo en el arbol del usuario. Devuelve False
    si el arbol no lo muestra (p. ej. documento publico de un nodo ajeno). }
  TSeleccionarNodoEvent = function(const Nodo: TClaveNodo): Boolean of object;

  TEditorFiltro = record
    Campo: TCampoBusqueda;
    E1: TWinControl;
    E2: TWinControl;
  end;

  TfrmBusquedaDocumentos = class(TForm)
  private
    FTexto: TEdit;
    FSubserie: TComboBox;
    FAmbito: TComboBox;
    FNodo: TClaveNodo;
    FTieneNodo: Boolean;
    FRutaNodo: string;
    FRutas: TDictionary<string, string>;
    FPadres: TDictionary<string, string>;
    FClaves: TList<TClaveNodo>;
    FOnSeleccionar: TSeleccionarNodoEvent;
    FFiltros: TScrollBox;
    FLista: TListView;
    FBarra: TStatusBar;
    FEditores: TList<TEditorFiltro>;
    FCodigos: TStringList;
    FBuscarAlMostrar: Boolean;
    FTemporizador: TTimer;
    procedure CargarSubseries;
    procedure CargarRutas;
    function RutaDe(const IdEstructura: string; Id: Integer): string;
    procedure AmbitoChange(Sender: TObject);
    procedure ConstruirFiltros(const CodSubs: string);
    procedure LimpiarFiltros;
    function PedidoActual: TPedidoBusqueda;
    function ValorDe(C: TWinControl; Tipo: TTipoCampo): string;
    procedure SubserieChange(Sender: TObject);
    procedure TextoChange(Sender: TObject);
    procedure TemporizadorTimer(Sender: TObject);
    procedure BuscarClick(Sender: TObject);
    procedure CerrarClick(Sender: TObject);
    procedure ListaDblClick(Sender: TObject);
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ TextoInicial (el del buscador del shell) se copia en la caja de texto y, si
  no esta vacio, la busqueda se ejecuta al abrir la pantalla. Sin nodo, el
  ambito es general. }
procedure AbrirBusquedaDocumentos(const TextoInicial: string = ''); overload;

{ Ambito elegido en el shell. Con abNodoActual y TieneNodo la busqueda se limita
  al nodo y sus descendientes; con abNodoActual y sin nodo elegido se avisa y
  no se busca (nunca cae en silencio a general). }
procedure AbrirBusquedaDocumentos(const TextoInicial: string;
  Ambito: TAmbitoBusqueda; const Nodo: TClaveNodo; TieneNodo: Boolean;
  OnSeleccionar: TSeleccionarNodoEvent = nil); overload;

implementation

uses
  Winapi.Windows, Winapi.Messages,
  Data.DB, FireDAC.Comp.Client, UCapaDatos, UAlcanceDatos, UBusquedaDatos;

const
  ALTO_FILA = 28;

procedure AbrirBusquedaDocumentos(const TextoInicial: string = '');
var
  Nodo: TClaveNodo;
begin
  Nodo.IdEstructura := '';
  Nodo.Id := 0;
  AbrirBusquedaDocumentos(TextoInicial, abGeneral, Nodo, False);
end;

procedure AbrirBusquedaDocumentos(const TextoInicial: string;
  Ambito: TAmbitoBusqueda; const Nodo: TClaveNodo; TieneNodo: Boolean;
  OnSeleccionar: TSeleccionarNodoEvent = nil);
var
  F: TfrmBusquedaDocumentos;
begin
  if (Ambito = abNodoActual) and not TieneNodo then
  begin
    Application.MessageBox('Elija un nodo en el arbol para buscar en el nodo actual.',
      'Buscar documentos', 48);
    Exit;
  end;
  F := TfrmBusquedaDocumentos.Create(Application);
  try
    F.FOnSeleccionar := OnSeleccionar;
    F.FNodo := Nodo;
    F.FTieneNodo := TieneNodo;
    if TieneNodo then
      F.FRutaNodo := F.RutaDe(Nodo.IdEstructura, Nodo.Id);
    F.FAmbito.Items[1] := 'Solo en ' + F.FRutaNodo;
    F.FAmbito.ItemIndex := Ord(Ambito);
    F.FTexto.Text := TextoInicial;
    // Siempre se busca al abrir: sin texto, todo lo que el usuario puede ver
    F.FBuscarAlMostrar := True;
    F.ShowModal;
  finally
    F.Free;
  end;
end;

constructor TfrmBusquedaDocumentos.Create(AOwner: TComponent);
var
  Barra: TPanel;
  Lbl: TLabel;
  Btn: TButton;
begin
  inherited CreateNew(AOwner);
  FEditores := TList<TEditorFiltro>.Create;
  FCodigos := TStringList.Create;
  Caption := 'Buscar documentos';
  Position := poScreenCenter;
  ClientWidth := 1000;
  ClientHeight := 580;
  FRutas := TDictionary<string, string>.Create;
  FPadres := TDictionary<string, string>.Create;
  FClaves := TList<TClaveNodo>.Create;
  FRutaNodo := '(sin nodo elegido)';

  FBarra := TStatusBar.Create(Self);
  FBarra.Parent := Self;
  FBarra.SimplePanel := True;

  Barra := TPanel.Create(Self);
  Barra.Parent := Self;
  Barra.Align := alTop;
  Barra.Height := 78;
  Barra.BevelOuter := bvNone;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Barra;
  Lbl.SetBounds(12, 14, 40, 16);
  Lbl.Caption := 'Texto:';
  FTexto := TEdit.Create(Self);
  FTexto.Parent := Barra;
  FTexto.SetBounds(56, 10, 280, 24);
  FTexto.TextHint := 'Titulo, codigo o cualquier dato del documento';
  FTexto.OnChange := TextoChange;
  // Filtra mientras se escribe: busca 350 ms despues de la ultima tecla
  FTemporizador := TTimer.Create(Self);
  FTemporizador.Enabled := False;
  FTemporizador.Interval := 350;
  FTemporizador.OnTimer := TemporizadorTimer;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Barra;
  Lbl.SetBounds(350, 14, 46, 16);
  Lbl.Caption := 'Ambito:';
  FAmbito := TComboBox.Create(Self);
  FAmbito.Parent := Barra;
  FAmbito.Style := csDropDownList;
  FAmbito.SetBounds(400, 10, 290, 24);
  FAmbito.Items.Add('Todo el archivo');
  FAmbito.Items.Add('Solo en ' + FRutaNodo);
  FAmbito.ItemIndex := 0;
  SendMessage(FAmbito.Handle, CB_SETDROPPEDWIDTH, 420, 0);
  FAmbito.OnChange := AmbitoChange;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Barra;
  Lbl.SetBounds(12, 48, 56, 16);
  Lbl.Caption := 'Subserie:';
  FSubserie := TComboBox.Create(Self);
  FSubserie.Parent := Barra;
  FSubserie.Style := csDropDownList;
  FSubserie.SetBounds(72, 44, 618, 24);
  FSubserie.OnChange := SubserieChange;

  Btn := TButton.Create(Self);
  Btn.Parent := Barra;
  Btn.SetBounds(704, 9, 80, 26);
  Btn.Caption := 'Buscar';
  Btn.Default := True;
  Btn.OnClick := BuscarClick;
  Btn := TButton.Create(Self);
  Btn.Parent := Barra;
  Btn.SetBounds(792, 9, 80, 26);
  Btn.Caption := 'Cerrar';
  Btn.Cancel := True;
  Btn.OnClick := CerrarClick;

  FFiltros := TScrollBox.Create(Self);
  FFiltros.Parent := Self;
  FFiltros.Align := alTop;
  FFiltros.Height := 110;
  FFiltros.BorderStyle := bsNone;

  FLista := TListView.Create(Self);
  FLista.Parent := Self;
  FLista.Align := alClient;
  FLista.ViewStyle := vsReport;
  FLista.ReadOnly := True;
  FLista.RowSelect := True;
  FLista.OnDblClick := ListaDblClick;
  with FLista.Columns.Add do begin Caption := 'Codigo'; Width := 100; end;
  with FLista.Columns.Add do begin Caption := 'Titulo'; Width := 230; end;
  with FLista.Columns.Add do begin Caption := 'Subserie'; Width := 140; end;
  with FLista.Columns.Add do begin Caption := 'Nodo'; Width := 340; end;
  with FLista.Columns.Add do begin Caption := 'Acceso'; Width := 80; end;
  with FLista.Columns.Add do begin Caption := 'Fecha'; Width := 80; end;

  CargarSubseries;
  ConstruirFiltros('');
  CargarRutas;
end;

destructor TfrmBusquedaDocumentos.Destroy;
begin
  FEditores.Free;
  FCodigos.Free;
  FRutas.Free;
  FPadres.Free;
  FClaves.Free;
  inherited;
end;

procedure TfrmBusquedaDocumentos.CargarSubseries;
var
  Q: TFDQuery;
  Filtro: TFiltroSql;
begin
  FSubserie.Items.Clear;
  FCodigos.Clear;
  FSubserie.Items.Add('(Todas las de mi alcance)');
  FCodigos.Add('');
  Filtro := FiltroDocumentos(UDM.Alcance, 'S');
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := UDM.Conn;
    Q.SQL.Text := 'SELECT DISTINCT S.codsubs, C.subserie FROM tb_SeriesDatos S ' +
      'INNER JOIN cl_subseries C ON C.codsubs = S.codsubs WHERE (' +
      Filtro.Condicion + ') ORDER BY C.subserie';
    AplicarParametros(Q, Filtro);
    Q.Open;
    while not Q.Eof do
    begin
      FCodigos.Add(Q.Fields[0].AsString);
      FSubserie.Items.Add(Q.Fields[1].AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  FSubserie.ItemIndex := 0;
end;

{ Etiqueta y padre de cada nodo (clave id) para mostrar la ruta
  como texto; sirve tambien para nodos que el arbol del usuario no muestra. }
procedure TfrmBusquedaDocumentos.CargarRutas;
var
  Q: TFDQuery;
  Clave: string;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := UDM.Conn;
    Q.SQL.Text := 'SELECT IdEstructura, id, etiqueta, padre FROM tb_tree';
    Q.Open;
    while not Q.Eof do
    begin
      // padre apunta solo al id del nodo (IdEstructura es el codigo del nodo)
      Clave := Q.Fields[1].AsString;
      FRutas.AddOrSetValue(Clave, Q.Fields[2].AsString);
      FPadres.AddOrSetValue(Clave, Q.Fields[3].AsString);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TfrmBusquedaDocumentos.RutaDe(const IdEstructura: string; Id: Integer): string;
var
  Clave, Et, Sig: string;
  Guarda: Integer;
begin
  Result := '';
  Clave := IntToStr(Id);
  Guarda := 0;
  while FRutas.TryGetValue(Clave, Et) and (Guarda < 64) do
  begin
    if Result = '' then
      Result := Et
    else
      Result := Et + ' > ' + Result;
    if not FPadres.TryGetValue(Clave, Sig) then
      Break;
    Clave := Sig;
    Inc(Guarda);
  end;
  if Result = '' then
    Result := IdEstructura;
end;

procedure TfrmBusquedaDocumentos.AmbitoChange(Sender: TObject);
begin
  if (FAmbito.ItemIndex = 1) and not FTieneNodo then
  begin
    FAmbito.ItemIndex := 0;
    FBarra.SimpleText := 'Elija un nodo en el arbol para buscar en el nodo actual.';
    Application.MessageBox('Elija un nodo en el arbol para buscar en el nodo actual.',
      'Buscar documentos', 48);
  end;
end;

procedure TfrmBusquedaDocumentos.LimpiarFiltros;
begin
  FEditores.Clear;
  while FFiltros.ControlCount > 0 do
    FFiltros.Controls[0].Free;
end;

procedure TfrmBusquedaDocumentos.ConstruirFiltros(const CodSubs: string);
var
  Campos: TArray<TCampoBusqueda>;
  C: TCampoBusqueda;
  Ed: TEditorFiltro;
  Lbl: TLabel;
  X, Y, N: Integer;

  function NuevoEdit(Ancho: Integer): TEdit;
  begin
    Result := TEdit.Create(Self);
    Result.Parent := FFiltros;
    Result.SetBounds(X, Y, Ancho, 24);
    X := X + Ancho + 6;
  end;

  function NuevaFecha: TDateTimePicker;
  begin
    Result := TDateTimePicker.Create(Self);
    Result.Parent := FFiltros;
    Result.SetBounds(X, Y, 110, 24);
    Result.ShowCheckBox := True;
    Result.Checked := False;
    X := X + 116;
  end;

begin
  LimpiarFiltros;
  if CodSubs = '' then
  begin
    Lbl := TLabel.Create(Self);
    Lbl.Parent := FFiltros;
    Lbl.SetBounds(12, 10, 500, 16);
    Lbl.Caption := 'Elija una subserie para filtrar por sus campos.';
    Exit;
  end;
  Campos := CargarCamposSubserie(UDM.Conn, CodSubs);
  N := 0;
  for C in Campos do
  begin
    Ed.Campo := C;
    Ed.E1 := nil;
    Ed.E2 := nil;
    X := 12 + (N mod 2) * 440;
    Y := 6 + (N div 2) * ALTO_FILA;
    Lbl := TLabel.Create(Self);
    Lbl.Parent := FFiltros;
    Lbl.SetBounds(X, Y + 4, 120, 16);
    Lbl.Caption := C.Etiqueta + ':';
    X := X + 124;
    case C.Tipo of
      tcCaracteres, tcMemo:
        Ed.E1 := NuevoEdit(200);
      tcFecha:
        begin
          Ed.E1 := NuevaFecha;
          Ed.E2 := NuevaFecha;
        end;
      tcEntero, tcReal:
        begin
          Ed.E1 := NuevoEdit(90);
          Ed.E2 := NuevoEdit(90);
        end;
      tcBooleano:
        begin
          Ed.E1 := TComboBox.Create(Self);
          Ed.E1.Parent := FFiltros;
          Ed.E1.SetBounds(X, Y, 120, 24);
          TComboBox(Ed.E1).Style := csDropDownList;
          TComboBox(Ed.E1).Items.CommaText := '(cualquiera),Si,No';
          TComboBox(Ed.E1).ItemIndex := 0;
        end;
    end;
    FEditores.Add(Ed);
    Inc(N);
  end;
  if N = 0 then
  begin
    Lbl := TLabel.Create(Self);
    Lbl.Parent := FFiltros;
    Lbl.SetBounds(12, 10, 500, 16);
    Lbl.Caption := 'Esta subserie no tiene campos propios para filtrar.';
  end;
end;

function TfrmBusquedaDocumentos.ValorDe(C: TWinControl; Tipo: TTipoCampo): string;
begin
  Result := '';
  if C = nil then
    Exit;
  case Tipo of
    tcCaracteres, tcMemo, tcEntero, tcReal:
      Result := Trim(TEdit(C).Text);
    tcFecha:
      if TDateTimePicker(C).Checked then
        Result := FormatDateTime('yyyy-mm-dd', TDateTimePicker(C).Date);
    tcBooleano:
      case TComboBox(C).ItemIndex of
        1: Result := '1';
        2: Result := '0';
      end;
  end;
end;

function TfrmBusquedaDocumentos.PedidoActual: TPedidoBusqueda;
var
  Ed: TEditorFiltro;
  Cd: TCondicionCampo;
  L: TList<TCondicionCampo>;
begin
  Result.Texto := Trim(FTexto.Text);
  Result.CodSubs := FCodigos[FSubserie.ItemIndex];
  Result.Limite := 0;
  if (FAmbito.ItemIndex = 1) and FTieneNodo then
  begin
    Result.Ambito := abNodoActual;
    Result.IdsNodo := NodosDelAmbito(UDM.Conn, FNodo);
  end
  else
  begin
    Result.Ambito := abGeneral;
    Result.IdsNodo := nil;
  end;
  L :=TList<TCondicionCampo>.Create;
  try
    for Ed in FEditores do
    begin
      Cd.Campo := Ed.Campo.Nombre;
      Cd.Desde := ValorDe(Ed.E1, Ed.Campo.Tipo);
      Cd.Hasta := ValorDe(Ed.E2, Ed.Campo.Tipo);
      if (Cd.Desde <> '') or (Cd.Hasta <> '') then
        L.Add(Cd);
    end;
    Result.Condiciones := L.ToArray;
  finally
    L.Free;
  end;
end;

procedure TfrmBusquedaDocumentos.TextoChange(Sender: TObject);
begin
  FTemporizador.Enabled := False;
  FTemporizador.Enabled := True;
end;

procedure TfrmBusquedaDocumentos.TemporizadorTimer(Sender: TObject);
begin
  FTemporizador.Enabled := False;
  BuscarClick(nil);
end;

procedure TfrmBusquedaDocumentos.SubserieChange(Sender: TObject);
begin
  ConstruirFiltros(FCodigos[FSubserie.ItemIndex]);
end;

procedure TfrmBusquedaDocumentos.BuscarClick(Sender: TObject);
var
  T: TFDMemTable;
  Truncado: Boolean;
  It: TListItem;
  Clave: TClaveNodo;
begin
  FLista.Items.BeginUpdate;
  try
    FLista.Items.Clear;
    FClaves.Clear;
    try
      T := UBusquedaDatos.Buscar(UDM.Conn, UDM.Alcance, PedidoActual,
        TBD = 'S', Truncado);
    except
      on E: Exception do
      begin
        FBarra.SimpleText := E.Message;
        Application.MessageBox(PChar(E.Message), 'Buscar documentos', 48);
        Exit;
      end;
    end;
    try
      while not T.Eof do
      begin
        It := FLista.Items.Add;
        It.Caption := T.FieldByName('Codigodoc').AsString;
        It.SubItems.Add(T.FieldByName('titulodoc').AsString);
        It.SubItems.Add(T.FieldByName('NombreSubserie').AsString);
        It.SubItems.Add(RutaDe(T.FieldByName('IdEstructura').AsString,
          T.FieldByName('id').AsInteger));
        It.SubItems.Add(T.FieldByName('Acceso').AsString);
        It.SubItems.Add(FormatDateTime('dd/mm/yyyy', T.FieldByName('Fecha').AsDateTime));
        Clave.IdEstructura := T.FieldByName('IdEstructura').AsString;
        Clave.Id := T.FieldByName('id').AsInteger;
        FClaves.Add(Clave);
        T.Next;
      end;
      FBarra.SimpleText := IntToStr(FLista.Items.Count) + ' documento(s)';
      if Truncado then
        FBarra.SimpleText := FBarra.SimpleText +
          '. Hay mas resultados: afine la busqueda.';
    finally
      T.Free;
    end;
  finally
    FLista.Items.EndUpdate;
  end;
end;

procedure TfrmBusquedaDocumentos.ListaDblClick(Sender: TObject);
begin
  // Si el arbol del usuario muestra el nodo se selecciona y se cierra la
  // busqueda; si no (documento publico de un nodo ajeno) se muestran los
  // datos y la ruta sin tocar el arbol.
  if (FLista.Selected <> nil) and (FLista.Selected.Index < FClaves.Count) then
  begin
    if Assigned(FOnSeleccionar) and
      FOnSeleccionar(FClaves[FLista.Selected.Index]) then
    begin
      Close;
      Exit;
    end;
    Application.MessageBox(PChar('Documento ' + FLista.Selected.Caption + sLineBreak +
      FLista.Selected.SubItems[0] + sLineBreak + 'Subserie: ' +
      FLista.Selected.SubItems[1] + sLineBreak + 'Nodo: ' +
      FLista.Selected.SubItems[2] + ' (' + FClaves[FLista.Selected.Index].IdEstructura +
      ')' + sLineBreak + 'Acceso: ' + FLista.Selected.SubItems[3]),
      'Buscar documentos', 64);
  end;
end;

procedure TfrmBusquedaDocumentos.DoShow;
begin
  inherited;
  if FBuscarAlMostrar then
  begin
    FBuscarAlMostrar := False;
    FTemporizador.Enabled := False;
    BuscarClick(nil);
  end;
end;

procedure TfrmBusquedaDocumentos.CerrarClick(Sender: TObject);
begin
  Close;
end;

end.
