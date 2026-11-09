unit UPantallaCarga;

{ Pantalla "Agregar documentos": se sueltan archivos o carpetas, cada archivo es
  un documento candidato, se completan los datos comunes y se guardan todos.
  Construida por codigo (sin .dfm). La lista es un TListView virtual (OwnerData):
  un solo control sin importar cuantos archivos se suelten. La logica vive en
  UCargaModelo y UCargaLote; aqui solo se pinta y se recoge lo que el usuario
  escribe. Pendiente (Tarea 6): tarjeta de datos propios de la subserie y modo
  Guiado. Codigo en ASCII. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance, UAlmacenFicheros,
  UCargaDocumento;

{ Modal. True si se guardo al menos un documento. Subserie = texto para mostrar. }
function MostrarCargaDocumentos(const Origen: TOrigenDocumento;
  const Subserie: string; Conn: TFDConnection; Alcance: TAlcanceUsuario;
  Almacen: IAlmacenFicheros): Boolean;

implementation

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.Classes, System.UITypes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs,
  Vcl.Graphics, FireDAC.Stan.Param, UCargaModelo, UCargaLote, UMetadatosSubserie, UTema;

type
  TfrmPantallaCarga = class(TForm)
  private
    FConn: TFDConnection;
    FAlcance: TAlcanceUsuario;
    FOrigen: TOrigenDocumento;
    FAlmacen: IAlmacenFicheros;
    FSubserie: string;
    FLote: TArray<TCandidato>;
    FCampos: TArray<TCampoMeta>;
    FTablaMeta: string;
    FObligatorios: TArray<string>;
    FGuardo: Boolean;
    FOcupado: Boolean;
    FCancelar: Boolean;
    FActualizando: Boolean;
    FTema: TTemaColores;
    FLista: TListView;
    FZona: TPanel;
    FChkSub: TCheckBox;
    FEdTitulo, FEdCodigo, FEdArchivo: TEdit;
    FFecha: TDateTimePicker;
    FEstado: TLabel;
    FBtnAplicar, FBtnGuardar, FBtnCancelar: TButton;
    FProgreso: TProgressBar;
    FTexto: TLabel;
    procedure Construir;
    function Etiqueta(Padre: TWinControl; const Texto: string; Arriba: Integer): TLabel;
    function Boton(Padre: TWinControl; const Texto: string; Izq, Ancho: Integer;
      AlClick: TNotifyEvent): TButton;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure AgregarRutas(const Rutas: TArray<string>);
    function UltimoCodigo: string;
    function TextoEstado(E: TEstadoCandidato): string;
    procedure Refrescar;
    procedure ListaDatos(Sender: TObject; Item: TListItem);
    procedure ListaCambio(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure MostrarSeleccionado;
    procedure EditoCampo(Sender: TObject);
    procedure ElegirClick(Sender: TObject);
    procedure CarpetaClick(Sender: TObject);
    procedure QuitarClick(Sender: TObject);
    procedure AplicarClick(Sender: TObject);
    procedure GuardarClick(Sender: TObject);
    procedure CancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Avance(Hecho, Total: Integer; const Archivo: string);
  public
    constructor Crear(const Origen: TOrigenDocumento; const Subserie: string;
      Conn: TFDConnection; Alcance: TAlcanceUsuario; Almacen: IAlmacenFicheros);
  end;

function MostrarCargaDocumentos(const Origen: TOrigenDocumento;
  const Subserie: string; Conn: TFDConnection; Alcance: TAlcanceUsuario;
  Almacen: IAlmacenFicheros): Boolean;
var
  F: TfrmPantallaCarga;
begin
  F := TfrmPantallaCarga.Crear(Origen, Subserie, Conn, Alcance, Almacen);
  try
    F.ShowModal;
    Result := F.FGuardo;
  finally
    F.Free;
  end;
end;

{ TfrmPantallaCarga }

constructor TfrmPantallaCarga.Crear(const Origen: TOrigenDocumento;
  const Subserie: string; Conn: TFDConnection; Alcance: TAlcanceUsuario;
  Almacen: IAlmacenFicheros);
begin
  inherited CreateNew(Application);
  FConn := Conn;
  FAlcance := Alcance;
  FOrigen := Origen;
  FAlmacen := Almacen;
  FSubserie := Subserie;
  FTema := TemaClaro;
  FCampos := CargarCamposSubserie(Conn, Origen.CodSubs);
  FTablaMeta := NombreTablaMeta(Conn, Origen.CodSubs);
  Construir;
end;

function TfrmPantallaCarga.Etiqueta(Padre: TWinControl; const Texto: string;
  Arriba: Integer): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := Padre;
  Result.Caption := Texto;
  Result.Left := 12;
  Result.Top := Arriba;
  Result.Font.Color := FTema.TextoSuave;
end;

function TfrmPantallaCarga.Boton(Padre: TWinControl; const Texto: string;
  Izq, Ancho: Integer; AlClick: TNotifyEvent): TButton;
begin
  Result := TButton.Create(Self);
  Result.Parent := Padre;
  Result.Caption := Texto;
  Result.Left := Izq;
  Result.Width := Ancho;
  Result.Height := 28;
  Result.OnClick := AlClick;
end;

procedure TfrmPantallaCarga.Construir;
var
  Izq, Der, Pie, Barra: TPanel;
  Col: TListColumn;
begin
  Caption := 'Agregar documentos - ' + FSubserie;
  Position := poOwnerFormCenter;
  BorderStyle := bsSizeable;
  ClientWidth := 980;
  ClientHeight := 560;
  Constraints.MinWidth := 820;
  Constraints.MinHeight := 480;
  Color := FTema.Fondo;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  OnCloseQuery := FormCloseQuery;
  DragAcceptFiles(Handle, True);

  Pie := TPanel.Create(Self);
  Pie.Parent := Self;
  Pie.Align := alBottom;
  Pie.Height := 48;
  Pie.BevelOuter := bvNone;
  Pie.ParentBackground := False;
  Pie.Color := FTema.Superficie2;

  Der := TPanel.Create(Self);
  Der.Parent := Self;
  Der.Align := alRight;
  Der.Width := 330;
  Der.BevelOuter := bvNone;
  Der.ParentBackground := False;
  Der.Color := FTema.Superficie;

  Izq := TPanel.Create(Self);
  Izq.Parent := Self;
  Izq.Align := alClient;
  Izq.BevelOuter := bvNone;
  Izq.ParentBackground := False;
  Izq.Color := FTema.Fondo;

  { Izquierda: zona de soltar, botones y lista }
  FZona := TPanel.Create(Self);
  FZona.Parent := Izq;
  FZona.Align := alTop;
  FZona.Height := 70;
  FZona.AlignWithMargins := True;
  FZona.Margins.SetBounds(12, 12, 12, 6);
  FZona.BevelOuter := bvNone;
  FZona.ParentBackground := False;
  FZona.Color := FTema.AcentoSuave;
  FZona.Caption := 'Suelte aqui archivos o carpetas';
  FZona.Font.Color := FTema.Texto;

  Barra := TPanel.Create(Self);
  Barra.Parent := Izq;
  Barra.Align := alTop;
  Barra.Height := 34;
  Barra.AlignWithMargins := True;
  Barra.Margins.SetBounds(12, 0, 12, 0);
  Barra.BevelOuter := bvNone;
  Barra.ParentBackground := False;
  Barra.Color := FTema.Fondo;
  Boton(Barra, 'Elegir archivos...', 0, 130, ElegirClick);
  Boton(Barra, 'Agregar carpeta...', 138, 130, CarpetaClick);
  Boton(Barra, 'Quitar', 276, 70, QuitarClick);
  FChkSub := TCheckBox.Create(Self);
  FChkSub.Parent := Barra;
  FChkSub.Left := 360;
  FChkSub.Top := 6;
  FChkSub.Width := 180;
  FChkSub.Caption := 'Incluir subcarpetas';
  FChkSub.Checked := True;

  FLista := TListView.Create(Self);
  FLista.Parent := Izq;
  FLista.Align := alClient;
  FLista.AlignWithMargins := True;
  FLista.Margins.SetBounds(12, 6, 12, 12);
  FLista.ViewStyle := vsReport;
  FLista.ReadOnly := True;
  FLista.RowSelect := True;
  FLista.MultiSelect := True;
  FLista.OwnerData := True;
  FLista.OnData := ListaDatos;
  FLista.OnChange := ListaCambio;
  Col := FLista.Columns.Add;
  Col.Caption := 'Archivo';
  Col.Width := 220;
  Col := FLista.Columns.Add;
  Col.Caption := 'Titulo';
  Col.Width := 200;
  Col := FLista.Columns.Add;
  Col.Caption := 'Estado';
  Col.Width := 110;

  { Derecha: datos del documento seleccionado }
  Etiqueta(Der, 'Archivo', 14);
  FEdArchivo := TEdit.Create(Self);
  FEdArchivo.Parent := Der;
  FEdArchivo.SetBounds(12, 32, 300, 23);
  FEdArchivo.ReadOnly := True;
  FEdArchivo.Anchors := [akLeft, akTop, akRight];

  Etiqueta(Der, 'Titulo', 66);
  FEdTitulo := TEdit.Create(Self);
  FEdTitulo.Parent := Der;
  FEdTitulo.SetBounds(12, 84, 300, 23);
  FEdTitulo.Anchors := [akLeft, akTop, akRight];
  FEdTitulo.OnChange := EditoCampo;

  Etiqueta(Der, 'Codigo', 118);
  FEdCodigo := TEdit.Create(Self);
  FEdCodigo.Parent := Der;
  FEdCodigo.SetBounds(12, 136, 300, 23);
  FEdCodigo.Anchors := [akLeft, akTop, akRight];
  FEdCodigo.OnChange := EditoCampo;

  Etiqueta(Der, 'Fecha', 170);
  FFecha := TDateTimePicker.Create(Self);
  FFecha.Parent := Der;
  FFecha.SetBounds(12, 188, 140, 23);
  FFecha.Kind := dtkDate;
  FFecha.Date := Date;
  FFecha.OnChange := EditoCampo;

  FEstado := Etiqueta(Der, '', 226);
  FEstado.Font.Style := [fsBold];

  FBtnAplicar := Boton(Der, 'Aplicar fecha a todos', 12, 160, AplicarClick);
  FBtnAplicar.Top := 256;

  { Pie }
  FProgreso := TProgressBar.Create(Self);
  FProgreso.Parent := Pie;
  FProgreso.SetBounds(12, 18, 260, 14);
  FTexto := TLabel.Create(Self);
  FTexto.Parent := Pie;
  FTexto.SetBounds(284, 17, 300, 15);
  FTexto.Caption := 'Sin archivos';
  FBtnCancelar := Boton(Pie, 'Cancelar', 0, 90, CancelarClick);
  FBtnGuardar := Boton(Pie, 'Guardar todos', 0, 120, GuardarClick);
  FBtnCancelar.Anchors := [akRight, akTop];
  FBtnGuardar.Anchors := [akRight, akTop];
  FBtnCancelar.Top := 10;
  FBtnGuardar.Top := 10;
  FBtnCancelar.Left := Pie.Width - 90 - 12;
  FBtnGuardar.Left := FBtnCancelar.Left - 120 - 8;
  Refrescar;
end;

procedure TfrmPantallaCarga.WMDropFiles(var Msg: TWMDropFiles);
var
  N, I: Integer;
  Rutas: TArray<string>;
  Buf: array[0..MAX_PATH] of Char;
begin
  try
    if FOcupado then
      Exit;
    N := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
    SetLength(Rutas, N);
    for I := 0 to N - 1 do
    begin
      DragQueryFile(Msg.Drop, I, Buf, Length(Buf));
      Rutas[I] := Buf;
    end;
    AgregarRutas(Rutas);
  finally
    DragFinish(Msg.Drop);
  end;
end;

function TfrmPantallaCarga.UltimoCodigo: string;
var
  I: Integer;
  Q: TFDQuery;
begin
  for I := High(FLote) downto 0 do
    if FLote[I].Codigo <> '' then
      Exit(FLote[I].Codigo);
  Result := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'SELECT MAX(Codigodoc) FROM tb_SeriesDatos ' +
      'WHERE IdEstructura = :e AND codsubs = :c';
    Q.ParamByName('e').AsString := FOrigen.IdEstructura;
    Q.ParamByName('c').AsString := FOrigen.CodSubs;
    Q.Open;
    Result := Q.Fields[0].AsString;
  finally
    Q.Free;
  end;
end;

procedure TfrmPantallaCarga.AgregarRutas(const Rutas: TArray<string>);
var
  Archivos, Codigos: TArray<string>;
  Existentes: TStringList;
  I, N, Base: Integer;
  C: TCandidato;
begin
  Archivos := ExpandirRutas(Rutas, FChkSub.Checked);
  Existentes := TStringList.Create;
  try
    Existentes.CaseSensitive := False;
    Existentes.Sorted := True;
    Existentes.Duplicates := dupIgnore;
    for I := 0 to High(FLote) do
      Existentes.Add(FLote[I].Archivo);
    N := 0;
    for I := 0 to High(Archivos) do
      if Existentes.IndexOf(Archivos[I]) < 0 then
      begin
        Archivos[N] := Archivos[I];
        Inc(N);
      end;
    SetLength(Archivos, N);
  finally
    Existentes.Free;
  end;
  if N = 0 then
    Exit;
  Codigos := CodigosParaLote(UltimoCodigo, FOrigen.IdEstructura, FOrigen.CodSubs,
    '1.0', N);
  Base := Length(FLote);
  SetLength(FLote, Base + N);
  for I := 0 to N - 1 do
  begin
    C := Default(TCandidato);
    C.Archivo := Archivos[I];
    C.Titulo := TituloDesdeNombre(Archivos[I]);
    C.Codigo := Codigos[I];
    C.Fecha := Date;
    C.Estado := EstadoTrasEditar(C, FObligatorios);
    FLote[Base + I] := C;
  end;
  Refrescar;
end;

function TfrmPantallaCarga.TextoEstado(E: TEstadoCandidato): string;
begin
  case E of
    ecEspera: Result := 'En espera';
    ecFalta: Result := 'Falta un dato';
    ecListo: Result := 'Listo';
    ecSubiendo: Result := 'Subiendo';
    ecGuardado: Result := 'Guardado';
  else
    Result := 'Error';
  end;
end;

procedure TfrmPantallaCarga.Refrescar;
var
  Listos, I: Integer;
begin
  FLista.Items.Count := Length(FLote);
  FLista.Invalidate;
  Listos := 0;
  for I := 0 to High(FLote) do
    if FLote[I].Estado in [ecListo, ecError] then
      Inc(Listos);
  if Length(FLote) = 0 then
    FTexto.Caption := 'Sin archivos'
  else
    FTexto.Caption := Format('%d archivos, %d para guardar', [Length(FLote), Listos]);
  FBtnGuardar.Enabled := (Listos > 0) and not FOcupado;
  MostrarSeleccionado;
end;

procedure TfrmPantallaCarga.ListaDatos(Sender: TObject; Item: TListItem);
var
  C: TCandidato;
begin
  if (Item.Index < 0) or (Item.Index > High(FLote)) then
    Exit;
  C := FLote[Item.Index];
  Item.Caption := ExtractFileName(C.Archivo);
  Item.SubItems.Add(C.Titulo);
  Item.SubItems.Add(TextoEstado(C.Estado));
end;

procedure TfrmPantallaCarga.ListaCambio(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if not FActualizando then
    MostrarSeleccionado;
end;

procedure TfrmPantallaCarga.MostrarSeleccionado;
var
  I: Integer;
  Hay: Boolean;
begin
  I := FLista.ItemIndex;
  Hay := (I >= 0) and (I <= High(FLote));
  FActualizando := True;
  try
    FEdTitulo.Enabled := Hay and not FOcupado;
    FEdCodigo.Enabled := Hay and not FOcupado;
    FFecha.Enabled := Hay and not FOcupado;
    FBtnAplicar.Enabled := Hay and (Length(FLote) > 1) and not FOcupado;
    if Hay then
    begin
      FEdArchivo.Text := FLote[I].Archivo;
      FEdTitulo.Text := FLote[I].Titulo;
      FEdCodigo.Text := FLote[I].Codigo;
      FFecha.Date := FLote[I].Fecha;
      FEstado.Caption := TextoEstado(FLote[I].Estado);
      if FLote[I].Error <> '' then
        FEstado.Caption := FEstado.Caption + ': ' + FLote[I].Error;
    end
    else
    begin
      FEdArchivo.Text := '';
      FEdTitulo.Text := '';
      FEdCodigo.Text := '';
      FEstado.Caption := '';
    end;
  finally
    FActualizando := False;
  end;
end;

procedure TfrmPantallaCarga.EditoCampo(Sender: TObject);
var
  I: Integer;
begin
  if FActualizando or (FLista.ItemIndex < 0) or (FLista.ItemIndex > High(FLote)) then
    Exit;
  I := FLista.ItemIndex;
  if FLote[I].Estado in [ecGuardado, ecSubiendo] then
    Exit;
  FLote[I].Titulo := FEdTitulo.Text;
  FLote[I].Codigo := FEdCodigo.Text;
  FLote[I].Fecha := Trunc(FFecha.Date);
  FLote[I].Estado := EstadoTrasEditar(FLote[I], FObligatorios);
  FLote[I].Error := '';
  FEstado.Caption := TextoEstado(FLote[I].Estado);
  FLista.Invalidate;
  FBtnGuardar.Enabled := not FOcupado;
end;

procedure TfrmPantallaCarga.ElegirClick(Sender: TObject);
var
  D: TOpenDialog;
  R: TArray<string>;
  I: Integer;
begin
  D := TOpenDialog.Create(Self);
  try
    D.Options := [ofAllowMultiSelect, ofFileMustExist, ofPathMustExist];
    D.Filter := 'Todos los archivos|*.*';
    if D.Execute then
    begin
      SetLength(R, D.Files.Count);
      for I := 0 to D.Files.Count - 1 do
        R[I] := D.Files[I];
      AgregarRutas(R);
    end;
  finally
    D.Free;
  end;
end;

procedure TfrmPantallaCarga.CarpetaClick(Sender: TObject);
var
  D: TFileOpenDialog;
begin
  D := TFileOpenDialog.Create(Self);
  try
    D.Options := [fdoPickFolders, fdoPathMustExist];
    if D.Execute then
      AgregarRutas([D.FileName]);
  finally
    D.Free;
  end;
end;

procedure TfrmPantallaCarga.QuitarClick(Sender: TObject);
var
  I, J: Integer;
  Nuevo: TArray<TCandidato>;
  Quitar: TArray<Boolean>;
begin
  if FOcupado then
    Exit;
  SetLength(Quitar, Length(FLote));
  for I := 0 to High(FLote) do
    Quitar[I] := (I < FLista.Items.Count) and FLista.Items[I].Selected and
      (FLote[I].Estado <> ecSubiendo);
  SetLength(Nuevo, 0);
  for I := 0 to High(FLote) do
    if not Quitar[I] then
    begin
      J := Length(Nuevo);
      SetLength(Nuevo, J + 1);
      Nuevo[J] := FLote[I];
    end;
  FLote := Nuevo;
  FLista.ClearSelection;
  Refrescar;
end;

procedure TfrmPantallaCarga.AplicarClick(Sender: TObject);
var
  I: Integer;
  Plantilla: TCandidato;
begin
  I := FLista.ItemIndex;
  if (I < 0) or (I > High(FLote)) then
    Exit;
  Plantilla := FLote[I];
  AplicarATodos(FLote, Plantilla, [ccFecha]);
  for I := 0 to High(FLote) do
    if not (FLote[I].Estado in [ecGuardado, ecSubiendo]) then
      FLote[I].Estado := EstadoTrasEditar(FLote[I], FObligatorios);
  Refrescar;
end;

procedure TfrmPantallaCarga.Avance(Hecho, Total: Integer; const Archivo: string);
begin
  FProgreso.Max := Total;
  FProgreso.Position := Hecho;
  FTexto.Caption := Format('%d de %d: %s', [Hecho, Total, ExtractFileName(Archivo)]);
  Application.ProcessMessages;
end;

procedure TfrmPantallaCarga.GuardarClick(Sender: TObject);
var
  Cargador: TCargaLote;
  R: TResumenLote;
begin
  if FOcupado or (Length(FLote) = 0) then
    Exit;
  FOcupado := True;
  FCancelar := False;
  FBtnGuardar.Enabled := False;
  try
    Cargador := TCargaLote.Create(FConn, FAlcance, FOrigen, FAlmacen, FCampos, FTablaMeta);
    try
      R := Cargador.Guardar(FLote,
        procedure(Hecho, Total: Integer; Archivo: string)
        begin
          Avance(Hecho, Total, Archivo);
        end,
        function: Boolean
        begin
          Result := FCancelar;
        end);
    finally
      Cargador.Free;
    end;
  finally
    FOcupado := False;
  end;
  if R.Guardados > 0 then
    FGuardo := True;
  FProgreso.Position := 0;
  Refrescar;
  MessageDlg(Format('Guardados: %d. Con error: %d. Omitidos: %d.',
    [R.Guardados, R.Fallidos, R.Omitidos]), mtInformation, [mbOK], 0);
end;

procedure TfrmPantallaCarga.CancelarClick(Sender: TObject);
begin
  if FOcupado then
    FCancelar := True
  else
    Close;
end;

procedure TfrmPantallaCarga.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  I: Integer;
  Pendientes: Boolean;
begin
  if FOcupado then
  begin
    FCancelar := True;
    CanClose := False;
    Exit;
  end;
  Pendientes := False;
  for I := 0 to High(FLote) do
    if FLote[I].Estado <> ecGuardado then
      Pendientes := True;
  if Pendientes then
    CanClose := MessageDlg('Hay archivos sin guardar. Cerrar de todos modos?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

end.
