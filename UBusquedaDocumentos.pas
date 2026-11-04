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
  Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, UBusqueda;

type
  TEditorFiltro = record
    Campo: TCampoBusqueda;
    E1: TWinControl;
    E2: TWinControl;
  end;

  TfrmBusquedaDocumentos = class(TForm)
  private
    FTexto: TEdit;
    FSubserie: TComboBox;
    FFiltros: TScrollBox;
    FLista: TListView;
    FBarra: TStatusBar;
    FEditores: TList<TEditorFiltro>;
    FCodigos: TStringList;
    procedure CargarSubseries;
    procedure ConstruirFiltros(const CodSubs: string);
    procedure LimpiarFiltros;
    function PedidoActual: TPedidoBusqueda;
    function ValorDe(C: TWinControl; Tipo: TTipoCampo): string;
    procedure SubserieChange(Sender: TObject);
    procedure BuscarClick(Sender: TObject);
    procedure CerrarClick(Sender: TObject);
    procedure ListaDblClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure AbrirBusquedaDocumentos;

implementation

uses
  Data.DB, FireDAC.Comp.Client, UCapaDatos, UAlcanceDatos, UBusquedaDatos;

const
  ALTO_FILA = 28;

procedure AbrirBusquedaDocumentos;
var
  F: TfrmBusquedaDocumentos;
begin
  F := TfrmBusquedaDocumentos.Create(Application);
  try
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
  ClientWidth := 900;
  ClientHeight := 560;

  FBarra := TStatusBar.Create(Self);
  FBarra.Parent := Self;
  FBarra.SimplePanel := True;

  Barra := TPanel.Create(Self);
  Barra.Parent := Self;
  Barra.Align := alTop;
  Barra.Height := 44;
  Barra.BevelOuter := bvNone;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Barra;
  Lbl.SetBounds(12, 14, 40, 16);
  Lbl.Caption := 'Texto:';
  FTexto := TEdit.Create(Self);
  FTexto.Parent := Barra;
  FTexto.SetBounds(56, 10, 280, 24);
  FTexto.TextHint := 'Titulo, codigo o cualquier dato del documento';

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Barra;
  Lbl.SetBounds(350, 14, 56, 16);
  Lbl.Caption := 'Subserie:';
  FSubserie := TComboBox.Create(Self);
  FSubserie.Parent := Barra;
  FSubserie.Style := csDropDownList;
  FSubserie.SetBounds(410, 10, 280, 24);
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
  with FLista.Columns.Add do begin Caption := 'Codigo'; Width := 110; end;
  with FLista.Columns.Add do begin Caption := 'Titulo'; Width := 330; end;
  with FLista.Columns.Add do begin Caption := 'Subserie'; Width := 230; end;
  with FLista.Columns.Add do begin Caption := 'Nodo'; Width := 100; end;
  with FLista.Columns.Add do begin Caption := 'Fecha'; Width := 90; end;

  CargarSubseries;
  ConstruirFiltros('');
end;

destructor TfrmBusquedaDocumentos.Destroy;
begin
  FEditores.Free;
  FCodigos.Free;
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
  Result.Ambito := abGeneral;
  Result.IdsNodo := nil;
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

procedure TfrmBusquedaDocumentos.SubserieChange(Sender: TObject);
begin
  ConstruirFiltros(FCodigos[FSubserie.ItemIndex]);
end;

procedure TfrmBusquedaDocumentos.BuscarClick(Sender: TObject);
var
  T: TFDMemTable;
  Truncado: Boolean;
  It: TListItem;
begin
  FLista.Items.BeginUpdate;
  try
    FLista.Items.Clear;
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
        It.SubItems.Add(T.FieldByName('IdEstructura').AsString);
        It.SubItems.Add(FormatDateTime('dd/mm/yyyy', T.FieldByName('Fecha').AsDateTime));
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
  // La navegacion al nodo se hara con el shell de la Fase 1; por ahora se
  // muestra donde esta el documento.
  if FLista.Selected <> nil then
    Application.MessageBox(PChar('Documento ' + FLista.Selected.Caption +
      ' en el nodo ' + FLista.Selected.SubItems[2]), 'Buscar documentos', 64);
end;

procedure TfrmBusquedaDocumentos.CerrarClick(Sender: TObject);
begin
  Close;
end;

end.
