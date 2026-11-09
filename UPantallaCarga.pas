unit UPantallaCarga;

{ Pantalla "Agregar documentos": se sueltan archivos o carpetas, cada archivo es
  un documento candidato, se completan los datos comunes y se guardan todos.
  Construida por codigo (sin .dfm). La lista es un TListView virtual (OwnerData):
  un solo control sin importar cuantos archivos se suelten. La logica vive en
  UCargaModelo y UCargaLote; aqui solo se pinta y se recoge lo que el usuario
  escribe. La tarjeta "Datos de la subserie" se genera en tiempo de ejecucion
  desde cl_VarSubserie (ningun nombre de campo esta escrito aqui). Modo Guiado:
  la misma pantalla por pasos (1 Archivos, 2 Datos, 3 Revisar). Codigo en ASCII. }

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
  Vcl.Graphics, FireDAC.Stan.Param, System.IniFiles, System.IOUtils, UCargaModelo, UCargaLote, UMetadatosSubserie, UTema;

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
    FBarra, FDerTotal, FDerArriba: TPanel;
    FScroll: TScrollBox;
    FCtlMeta: TArray<TControl>;
    FMsgMeta: TArray<TLabel>;
    FBtnRepetir, FBtnAnt, FBtnSig, FBtnFuente: TButton;
    FChkGuiado: TCheckBox;
    FPaso: Integer;
    procedure Construir;
    procedure CrearTarjetaPropia;
    function ValoresDeControles: TArray<TValorMeta>;
    procedure PonerValores(const Valores: TArray<TValorMeta>);
    function ValorDe(const Valores: TArray<TValorMeta>; const Nombre: string): string;
    procedure EditoMeta(Sender: TObject);
    procedure RepetirClick(Sender: TObject);
    function EstadoDe(const C: TCandidato): TEstadoCandidato;
    function Detalle(const C: TCandidato): string;
    procedure ActualizarMensajes(const C: TCandidato);
    function ArchivoModo: string;
    function LeerModoGuiado: Boolean;
    procedure GuardarModoGuiado(Valor: Boolean);
    procedure GuiadoClick(Sender: TObject);
    procedure AnteriorClick(Sender: TObject);
    procedure SiguienteClick(Sender: TObject);
    procedure AplicarPaso;
    procedure AgregarFuentes(Indice: Integer; const Rutas: TArray<string>);
    procedure FuenteClick(Sender: TObject);
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
var
  I: Integer;
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
  if FTablaMeta = '' then
    FCampos := nil;
  for I := 0 to High(FCampos) do
    if FCampos[I].Obligatorio then
    begin
      SetLength(FObligatorios, Length(FObligatorios) + 1);
      FObligatorios[High(FObligatorios)] := FCampos[I].Nombre;
    end;
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

  FDerTotal := TPanel.Create(Self);
  FDerTotal.Parent := Self;
  FDerTotal.Align := alRight;
  FDerTotal.Width := 330;
  FDerTotal.BevelOuter := bvNone;
  FDerTotal.ParentBackground := False;
  FDerTotal.Color := FTema.Superficie;

  Der := TPanel.Create(Self);
  Der.Parent := FDerTotal;
  Der.Align := alTop;
  Der.Height := 290;
  Der.BevelOuter := bvNone;
  Der.ParentBackground := False;
  Der.Color := FTema.Superficie;
  FDerArriba := Der;

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
  FBarra := Barra;
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
  FChkGuiado := TCheckBox.Create(Self);
  FChkGuiado.Parent := Barra;
  FChkGuiado.SetBounds(550, 6, 130, 17);
  FChkGuiado.Caption := 'Modo guiado';
  FChkGuiado.Checked := LeerModoGuiado;
  FChkGuiado.OnClick := GuiadoClick;

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
  Col := FLista.Columns.Add;
  Col.Caption := 'Detalle';
  Col.Width := 200;

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

  FBtnAplicar := Boton(Der, 'Aplicar a todos', 12, 160, AplicarClick);
  FBtnAplicar.Top := 256;
  FBtnFuente := Boton(Der, 'Agregar fuente...', 180, 130, FuenteClick);
  FBtnFuente.Top := 256;
  CrearTarjetaPropia;

  { Pie }
  FProgreso := TProgressBar.Create(Self);
  FProgreso.Parent := Pie;
  FProgreso.SetBounds(12, 18, 160, 14);
  FTexto := TLabel.Create(Self);
  FTexto.Parent := Pie;
  FTexto.SetBounds(180, 17, 180, 15);
  FTexto.Caption := 'Sin archivos';
  FBtnCancelar := Boton(Pie, 'Cancelar', 0, 90, CancelarClick);
  FBtnGuardar := Boton(Pie, 'Guardar todos', 0, 120, GuardarClick);
  FBtnCancelar.Anchors := [akRight, akTop];
  FBtnGuardar.Anchors := [akRight, akTop];
  FBtnCancelar.Top := 10;
  FBtnGuardar.Top := 10;
  FBtnCancelar.Left := Pie.Width - 90 - 12;
  FBtnGuardar.Left := FBtnCancelar.Left - 120 - 8;
  FBtnSig := Boton(Pie, 'Siguiente >', 0, 100, SiguienteClick);
  FBtnAnt := Boton(Pie, '< Anterior', 0, 100, AnteriorClick);
  FBtnSig.Anchors := [akRight, akTop];
  FBtnAnt.Anchors := [akRight, akTop];
  FBtnSig.Top := 10;
  FBtnAnt.Top := 10;
  FBtnSig.Left := FBtnGuardar.Left - 100 - 8;
  FBtnAnt.Left := FBtnSig.Left - 100 - 8;
  FPaso := 1;
  AplicarPaso;
  Refrescar;
end;

{ ---- Tarjeta de datos propios (en tiempo de ejecucion) ---- }

procedure TfrmPantallaCarga.CrearTarjetaPropia;
var
  I, Y: Integer;
  Campo: TCampoMeta;
  Lbl: TLabel;
  Ctl: TControl;
  Memo: TMemo;
  Ed: TEdit;
  Fch: TDateTimePicker;
  Cmb: TComboBox;
begin
  if (FTablaMeta = '') or (Length(FCampos) = 0) then
    Exit;
  FScroll := TScrollBox.Create(Self);
  FScroll.Parent := FDerTotal;
  FScroll.Align := alClient;
  FScroll.BorderStyle := bsNone;
  FScroll.VertScrollBar.Tracking := True;
  FScroll.Color := FTema.Superficie;
  Lbl := TLabel.Create(Self);
  Lbl.Parent := FScroll;
  Lbl.Caption := 'Datos de la subserie';
  Lbl.Font.Style := [fsBold];
  Lbl.Left := 12;
  Lbl.Top := 6;
  FBtnRepetir := Boton(FScroll, 'Repetir los ultimos valores', 12, 190, RepetirClick);
  FBtnRepetir.Top := 26;
  SetLength(FCtlMeta, Length(FCampos));
  SetLength(FMsgMeta, Length(FCampos));
  Y := 62;
  for I := 0 to High(FCampos) do
  begin
    Campo := FCampos[I];
    Lbl := TLabel.Create(Self);
    Lbl.Parent := FScroll;
    Lbl.Left := 12;
    Lbl.Top := Y;
    Lbl.Font.Color := FTema.TextoSuave;
    if Campo.Obligatorio then
      Lbl.Caption := Campo.Etiqueta + ' *'
    else
      Lbl.Caption := Campo.Etiqueta;
    Inc(Y, 18);
    case ControlParaCampo(Campo.Tipo, Campo.Longitud) of
      cmMemo:
        begin
          Memo := TMemo.Create(Self);
          Memo.Parent := FScroll;
          Memo.SetBounds(12, Y, 280, 60);
          Memo.ScrollBars := ssVertical;
          Memo.OnChange := EditoMeta;
          Ctl := Memo;
        end;
      cmFecha:
        begin
          Fch := TDateTimePicker.Create(Self);
          Fch.Parent := FScroll;
          Fch.SetBounds(12, Y, 140, 23);
          Fch.Kind := dtkDate;
          Fch.ShowCheckbox := True;
          Fch.Checked := False;
          Fch.OnChange := EditoMeta;
          Ctl := Fch;
        end;
      cmSiNo:
        begin
          Cmb := TComboBox.Create(Self);
          Cmb.Parent := FScroll;
          Cmb.SetBounds(12, Y, 140, 23);
          Cmb.Style := csDropDownList;
          Cmb.Items.Add('');
          Cmb.Items.Add('Si');
          Cmb.Items.Add('No');
          Cmb.ItemIndex := 0;
          Cmb.OnChange := EditoMeta;
          Ctl := Cmb;
        end;
    else
      begin
        Ed := TEdit.Create(Self);
        Ed.Parent := FScroll;
        Ed.SetBounds(12, Y, 280, 23);
        if (Campo.Tipo = tmTexto) and (Campo.Longitud > 0) then
          Ed.MaxLength := Campo.Longitud;
        Ed.OnChange := EditoMeta;
        Ctl := Ed;
      end;
    end;
    Ctl.Tag := I;
    FCtlMeta[I] := Ctl;
    Inc(Y, Ctl.Height + 2);
    Lbl := TLabel.Create(Self);
    Lbl.Parent := FScroll;
    Lbl.Left := 12;
    Lbl.Top := Y;
    Lbl.Font.Color := FTema.Aviso;
    Lbl.Caption := '';
    FMsgMeta[I] := Lbl;
    Inc(Y, 20);
  end;
end;

function TfrmPantallaCarga.ValoresDeControles: TArray<TValorMeta>;
var
  I: Integer;
  Txt: string;
begin
  SetLength(Result, Length(FCtlMeta));
  for I := 0 to High(FCtlMeta) do
  begin
    Txt := '';
    if FCtlMeta[I] is TDateTimePicker then
    begin
      if TDateTimePicker(FCtlMeta[I]).Checked then
        Txt := FormatDateTime('dd/mm/yyyy', TDateTimePicker(FCtlMeta[I]).Date);
    end
    else if FCtlMeta[I] is TComboBox then
      Txt := TComboBox(FCtlMeta[I]).Text
    else if FCtlMeta[I] is TMemo then
      Txt := TMemo(FCtlMeta[I]).Text
    else if FCtlMeta[I] is TEdit then
      Txt := TEdit(FCtlMeta[I]).Text;
    Result[I].Nombre := FCampos[I].Nombre;
    Result[I].Valor := Txt;
  end;
end;

function TfrmPantallaCarga.ValorDe(const Valores: TArray<TValorMeta>;
  const Nombre: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(Valores) do
    if SameText(Valores[I].Nombre, Nombre) then
      Exit(Valores[I].Valor);
end;

procedure TfrmPantallaCarga.PonerValores(const Valores: TArray<TValorMeta>);
var
  I: Integer;
  Txt: string;
  D: TDateTime;
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Create;
  FS.DateSeparator := '/';
  FS.ShortDateFormat := 'dd/mm/yyyy';
  for I := 0 to High(FCtlMeta) do
  begin
    Txt := ValorDe(Valores, FCampos[I].Nombre);
    if FCtlMeta[I] is TDateTimePicker then
    begin
      if (Txt <> '') and TryStrToDate(Txt, D, FS) then
      begin
        TDateTimePicker(FCtlMeta[I]).Date := D;
        TDateTimePicker(FCtlMeta[I]).Checked := True;
      end
      else
        TDateTimePicker(FCtlMeta[I]).Checked := False;
    end
    else if FCtlMeta[I] is TComboBox then
      TComboBox(FCtlMeta[I]).ItemIndex := TComboBox(FCtlMeta[I]).Items.IndexOf(Txt)
    else if FCtlMeta[I] is TMemo then
      TMemo(FCtlMeta[I]).Text := Txt
    else if FCtlMeta[I] is TEdit then
      TEdit(FCtlMeta[I]).Text := Txt;
  end;
end;

function TfrmPantallaCarga.EstadoDe(const C: TCandidato): TEstadoCandidato;
var
  I: Integer;
begin
  Result := EstadoTrasEditar(C, FObligatorios);
  if Result <> ecListo then
    Exit;
  for I := 0 to High(FCampos) do
    if ValidarValorMeta(FCampos[I], ValorDe(C.Meta, FCampos[I].Nombre)) <> '' then
      Exit(ecFalta);
end;

function TfrmPantallaCarga.Detalle(const C: TCandidato): string;
var
  F: TArray<string>;
  I: Integer;
begin
  if C.Error <> '' then
    Exit(C.Error);
  Result := '';
  if C.Estado <> ecFalta then
    Exit;
  F := Faltantes(C, FObligatorios);
  for I := 0 to High(F) do
    if Result = '' then
      Result := F[I]
    else
      Result := Result + ', ' + F[I];
  if Result = '' then
    Result := 'Hay datos invalidos'
  else
    Result := 'Falta: ' + Result;
end;

procedure TfrmPantallaCarga.ActualizarMensajes(const C: TCandidato);
var
  I: Integer;
begin
  for I := 0 to High(FMsgMeta) do
    FMsgMeta[I].Caption := ValidarValorMeta(FCampos[I], ValorDe(C.Meta, FCampos[I].Nombre));
end;

procedure TfrmPantallaCarga.EditoMeta(Sender: TObject);
var
  I: Integer;
begin
  if FActualizando or (FLista.ItemIndex < 0) or (FLista.ItemIndex > High(FLote)) then
    Exit;
  I := FLista.ItemIndex;
  if FLote[I].Estado in [ecGuardado, ecSubiendo] then
    Exit;
  FLote[I].Meta := ValoresDeControles;
  FLote[I].Estado := EstadoDe(FLote[I]);
  FLote[I].Error := '';
  ActualizarMensajes(FLote[I]);
  FEstado.Caption := TextoEstado(FLote[I].Estado);
  FLista.Invalidate;
  FBtnGuardar.Enabled := not FOcupado;
end;

procedure TfrmPantallaCarga.RepetirClick(Sender: TObject);
var
  U: TArray<TValorMeta>;
begin
  if (FLista.ItemIndex < 0) or FOcupado then
    Exit;
  U := LeerUltimosValores(FConn, FOrigen.Usuario, FOrigen.CodSubs);
  if Length(U) = 0 then
  begin
    MessageDlg('Todavia no hay valores anteriores para esta subserie.',
      mtInformation, [mbOK], 0);
    Exit;
  end;
  FActualizando := True;
  try
    PonerValores(U);
  finally
    FActualizando := False;
  end;
  EditoMeta(nil);
end;

{ ---- Modo Guiado ---- }

function TfrmPantallaCarga.ArchivoModo: string;
begin
  Result := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ArchiGenio'), 'carga.ini');
end;

function TfrmPantallaCarga.LeerModoGuiado: Boolean;
var
  Ini: TIniFile;
begin
  Result := False;
  try
    if not TFile.Exists(ArchivoModo) then
      Exit;
    Ini := TIniFile.Create(ArchivoModo);
    try
      Result := Ini.ReadBool('Usuario_' + FOrigen.Usuario, 'Guiado', False);
    finally
      Ini.Free;
    end;
  except
    Result := False;
  end;
end;

procedure TfrmPantallaCarga.GuardarModoGuiado(Valor: Boolean);
var
  Ini: TIniFile;
begin
  try
    TDirectory.CreateDirectory(ExtractFilePath(ArchivoModo));
    Ini := TIniFile.Create(ArchivoModo);
    try
      Ini.WriteBool('Usuario_' + FOrigen.Usuario, 'Guiado', Valor);
    finally
      Ini.Free;
    end;
  except
    { preferencia opcional: si no se puede guardar, no pasa nada }
  end;
end;

procedure TfrmPantallaCarga.GuiadoClick(Sender: TObject);
begin
  GuardarModoGuiado(FChkGuiado.Checked);
  FPaso := 1;
  AplicarPaso;
end;

procedure TfrmPantallaCarga.AplicarPaso;
var
  Guiado: Boolean;
begin
  Guiado := FChkGuiado.Checked;
  FBtnAnt.Visible := Guiado;
  FBtnSig.Visible := Guiado;
  if not Guiado then
  begin
    Caption := 'Agregar documentos - ' + FSubserie;
    FZona.Visible := True;
    FBarra.Visible := True;
    FDerTotal.Visible := True;
    Exit;
  end;
  Caption := Format('Agregar documentos - %s (paso %d de 3)', [FSubserie, FPaso]);
  FZona.Visible := FPaso = 1;
  FBarra.Visible := FPaso = 1;
  FDerTotal.Visible := FPaso = 2;
  FBtnAnt.Enabled := FPaso > 1;
  FBtnSig.Enabled := (FPaso < 3) and (Length(FLote) > 0);
  case FPaso of
    1: FBtnSig.Caption := 'Datos >';
    2: FBtnSig.Caption := 'Revisar >';
  else
    FBtnSig.Caption := 'Siguiente >';
  end;
end;

procedure TfrmPantallaCarga.AgregarFuentes(Indice: Integer; const Rutas: TArray<string>);
var
  Archivos: TArray<string>;
  I, N: Integer;
begin
  if (Indice < 0) or (Indice > High(FLote)) or
    (FLote[Indice].Estado in [ecGuardado, ecSubiendo]) then
    Exit;
  Archivos := ExpandirRutas(Rutas, False);
  for I := 0 to High(Archivos) do
  begin
    N := Length(FLote[Indice].Fuentes);
    SetLength(FLote[Indice].Fuentes, N + 1);
    FLote[Indice].Fuentes[N] := Archivos[I];
  end;
  FLista.ItemIndex := Indice;
  MostrarSeleccionado;
end;

procedure TfrmPantallaCarga.FuenteClick(Sender: TObject);
var
  D: TOpenDialog;
  R: TArray<string>;
  I: Integer;
begin
  if FLista.ItemIndex < 0 then
    Exit;
  D := TOpenDialog.Create(Self);
  try
    D.Options := [ofAllowMultiSelect, ofFileMustExist, ofPathMustExist];
    D.Filter := 'Todos los archivos|*.*';
    if D.Execute then
    begin
      SetLength(R, D.Files.Count);
      for I := 0 to D.Files.Count - 1 do
        R[I] := D.Files[I];
      AgregarFuentes(FLista.ItemIndex, R);
    end;
  finally
    D.Free;
  end;
end;

procedure TfrmPantallaCarga.AnteriorClick(Sender: TObject);
begin
  if FPaso > 1 then
    Dec(FPaso);
  AplicarPaso;
end;

procedure TfrmPantallaCarga.SiguienteClick(Sender: TObject);
begin
  if FPaso < 3 then
    Inc(FPaso);
  AplicarPaso;
end;

procedure TfrmPantallaCarga.WMDropFiles(var Msg: TWMDropFiles);
var
  N, I: Integer;
  Rutas: TArray<string>;
  Buf: array[0..MAX_PATH] of Char;
  Pt: TPoint;
  Item: TListItem;
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
    { Soltado sobre la fila de un candidato = ficheros fuente de ese documento }
    Item := nil;
    if DragQueryPoint(Msg.Drop, Pt) then
    begin
      Pt := FLista.ScreenToClient(ClientToScreen(Pt));
      if PtInRect(FLista.ClientRect, Pt) then
        Item := FLista.GetItemAt(Pt.X, Pt.Y);
    end;
    if Item <> nil then
      AgregarFuentes(Item.Index, Rutas)
    else
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
    C.Estado := EstadoDe(C);
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
  if FBtnSig <> nil then
    FBtnSig.Enabled := (FPaso < 3) and (Length(FLote) > 0);
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
  Item.SubItems.Add(Detalle(C));
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
    FBtnFuente.Enabled := Hay and not FOcupado;
    if FScroll <> nil then
      FScroll.Enabled := Hay and not FOcupado;
    if Hay then
    begin
      if FScroll <> nil then
      begin
        PonerValores(FLote[I].Meta);
        ActualizarMensajes(FLote[I]);
      end;
      FEdArchivo.Text := FLote[I].Archivo;
      FEdTitulo.Text := FLote[I].Titulo;
      FEdCodigo.Text := FLote[I].Codigo;
      FFecha.Date := FLote[I].Fecha;
      FEstado.Caption := TextoEstado(FLote[I].Estado);
      if Length(FLote[I].Fuentes) > 0 then
        FEstado.Caption := FEstado.Caption + Format(' (%d fuente(s))', [Length(FLote[I].Fuentes)]);
      if FLote[I].Error <> '' then
        FEstado.Caption := FEstado.Caption + ': ' + FLote[I].Error;
    end
    else
    begin
      FEdArchivo.Text := '';
      FEdTitulo.Text := '';
      FEdCodigo.Text := '';
      FEstado.Caption := '';
      if FScroll <> nil then
      begin
        PonerValores(nil);
        ActualizarMensajes(Default(TCandidato));
      end;
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
  FLote[I].Estado := EstadoDe(FLote[I]);
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
  if (FScroll <> nil) and
    (MessageDlg('Aplicar tambien los datos de la subserie de este documento a todos los demas?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
    for I := 0 to High(FLote) do
      if not (FLote[I].Estado in [ecGuardado, ecSubiendo]) then
        FLote[I].Meta := Copy(Plantilla.Meta);
  for I := 0 to High(FLote) do
    if not (FLote[I].Estado in [ecGuardado, ecSubiendo]) then
      FLote[I].Estado := EstadoDe(FLote[I]);
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
  Texto: string;
  I: Integer;
  Reintentar: Boolean;
begin
  Reintentar := False;
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
  Texto := ResumenLote(R.Guardados, R.Fallidos, R.Omitidos);
  if R.Fallidos > 0 then
  begin
    for I := 0 to High(FLote) do
      if (FLote[I].Estado = ecError) and (FLote[I].Error <> '') then
        Texto := Texto + #13#10 + '- ' + ExtractFileName(FLote[I].Archivo) + ': ' + FLote[I].Error;
    Texto := Texto + #13#10#13#10 + 'Reintentar los que fallaron?';
    Reintentar := MessageDlg(Texto, mtWarning, [mbYes, mbNo], 0) = mrYes;
  end
  else
    MessageDlg(Texto, mtInformation, [mbOK], 0);
  if Reintentar then
    GuardarClick(nil);
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
