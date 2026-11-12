unit UCLArchivosForm;

{ ---------------------------------------------------------------------------
  Clasificador de Archivos, pantalla nueva.

  Hereda de TFormClasificadorBase: tabla a todo el ancho y panel lateral para
  editar. Las reglas (validar, guardar, eliminar protegido, imagenes) estan en
  UArchivosDatos y UImagenes; aqui solo se presentan.

  Guardar solo escribe lo que el usuario cambio: el croquis, la foto y la
  descripcion no se tocan si no se editaron (la descripcion normalmente es RTF y
  se conserva con su formato). Todo el guardado va en una transaccion.

  Los campos del panel se reparten en Distribuir segun el ancho real.

  Entrada: CrearClasificadorArchivos(Conn); TMAIN la acopla a la ventana
  principal. La pantalla clasica sigue en UMangementArch.
  --------------------------------------------------------------------------- }

interface

uses
  FireDAC.Comp.Client, UClasificadorBase;

{ Crea la pantalla de Archivos sin mostrarla: se embebe con Embeber. }
function CrearClasificadorArchivos(Conn: TFDConnection): TFormClasificadorBase;

implementation

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  System.IOUtils, System.StrUtils, Winapi.Windows, Winapi.ShellAPI, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.ComCtrls, Vcl.Dialogs,
  UTema, UShellPrincipal, UClasificadorEstado, UServidoresDatos, UArchivosDatos,
  UImagenes, UIconos, UMensajes;

type
  { Da acceso a la fuente (protegida) de TBotonShell. }
  TBotonAbierto = class(TBotonShell);

  { Bloque de una imagen (croquis o foto) dentro del panel. }
  TBloqueImg = record
    Panel: TPanel;
    Img: TImage;
    Vacio: TLabel;       // texto cuando no hay imagen
    Titulo: TLabel;
    BtnCambiar, BtnVer, BtnQuitar: TBotonShell;
    Bytes: TBytes;        // lo que se muestra (guardado o recien elegido)
    Pendiente: Boolean;   // hay un cambio sin guardar
    Quitar: Boolean;      // el cambio pendiente es quitar la imagen
  end;

  TfrmArchivos = class(TFormClasificadorBase)
  private
    FConn: TFDConnection;
    FArchivos: TArray<TArchivo>;
    FTipos, FResponsables: TArray<TOpcion>;
    FActual: TArchivo;
    FCargando: Boolean;
    FLblNombre, FLblTipo, FLblResp, FLblDesc: TLabel;
    FErrNombre, FErrTipo: TLabel;
    FEdNombre: TEdit;
    FCmbTipo, FCmbResp: TComboBox;
    FBloque: array[TCampoImagen] of TBloqueImg;
    FDescripcion: TRichEdit;
    FDescCambiada: Boolean;
    FResultado: TLabel;
    function NuevaEtiqueta(const ATexto: string; ASuave: Boolean): TLabel;
    function NuevoBotonImg(AParent: TWinControl; const ATexto, AIcono: string;
      ACampo: TCampoImagen; AClick: TNotifyEvent; ATextoColor: TColor): TBotonShell;
    procedure ConstruirBloque(ACampo: TCampoImagen; const ATitulo: string);
    procedure ConstruirCampos;
    procedure Distribuir;
    procedure CuerpoResize(Sender: TObject);
    procedure Recargar(ASeleccionarId: Integer);
    procedure CargarListas;
    function BuscarArchivo(ACod: Integer; out A: TArchivo): Boolean;
    function NombreDe(const AOpciones: TArray<TOpcion>; AId: Integer): string;
    procedure MostrarFicha(const A: TArchivo; AEsNuevo: Boolean);
    function LeerFicha: TArchivo;
    procedure PonerImagen(ACampo: TCampoImagen; const ABytes: TBytes);
    procedure CargarDescripcion(const ATexto: string);
    function TextoDescripcion: string;
    procedure ActualizarBotones;
    procedure LimpiarErrores;
    procedure MostrarErrores(const AErrores: TArray<TErrorCampo>);
    procedure Resultado(const ATexto: string; AOk: Boolean);
    procedure CampoCambio(Sender: TObject);
    procedure DescripcionCambio(Sender: TObject);
    procedure CambiarClick(Sender: TObject);
    procedure VerClick(Sender: TObject);
    procedure QuitarClick(Sender: TObject);
  protected
    procedure AlNuevo; override;
    procedure AlElegirFila(ATag: Integer); override;
    procedure AlGuardar; override;
    procedure AlEliminar; override;
  public
    constructor CrearArchivos(AOwner: TComponent; AConn: TFDConnection);
  end;

function CrearClasificadorArchivos(Conn: TFDConnection): TFormClasificadorBase;
begin
  Result := TfrmArchivos.CrearArchivos(nil, Conn);
end;

{ Icono legible sobre el fondo dado. }
function IconoDe(const ANombre: string; AFondo: TColor): Integer;
begin
  try
    if RazonContraste(AFondo, clWhite) > RazonContraste(AFondo, clBlack) then
      Result := IndiceIconoBlanco(ANombre)
    else
      Result := IndiceIcono(ANombre);
  except
    Result := -1;
  end;
end;

{ Extension adecuada para abrir los bytes en el visor de Windows. }
function ExtensionDe(const ABytes: TBytes): string;
begin
  Result := '.jpg';
  if Length(ABytes) >= 4 then
  begin
    if (ABytes[0] = $89) and (ABytes[1] = $50) then
      Result := '.png'
    else if (ABytes[0] = $42) and (ABytes[1] = $4D) then
      Result := '.bmp';
  end;
end;

{ TfrmArchivos }

constructor TfrmArchivos.CrearArchivos(AOwner: TComponent; AConn: TFDConnection);
begin
  inherited Create(AOwner);
  Caption := 'Archivos';
  FConn := AConn;
  ConstruirBase('Archivos', '', 'Nuevo archivo');
  AgregarColumna('C'#243'digo', 80);
  AgregarColumna('Nombre', 260);
  AgregarColumna('Tipo', 140);
  AgregarColumna('Responsable', 220);
  AgregarColumna('Croquis', 90);
  AgregarColumna('Foto', 90);
  ConstruirCampos;
  CargarListas;
  Recargar(-1);
  FijarBotones(False, False, False);
end;

function TfrmArchivos.NuevaEtiqueta(const ATexto: string; ASuave: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := FCuerpo;
  Result.AutoSize := False;
  Result.Transparent := True;
  Result.StyleElements := [];
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := 8;
  if ASuave then
    Result.Font.Color := FTema.TextoSuave
  else
    Result.Font.Color := FTema.Texto;
  Result.SetBounds(0, 0, Esc(200), Esc(16));
  Result.Caption := ATexto;
end;

function TfrmArchivos.NuevoBotonImg(AParent: TWinControl; const ATexto, AIcono: string;
  ACampo: TCampoImagen; AClick: TNotifyEvent; ATextoColor: TColor): TBotonShell;
begin
  Result := TBotonShell.Create(Self);
  Result.Parent := AParent;
  Result.Estilo := ebPrimario;
  Result.Texto := ATexto;
  Result.Tag := Ord(ACampo);
  TBotonAbierto(Result).Font.Name := 'Segoe UI';
  TBotonAbierto(Result).Font.Size := 8;
  TBotonAbierto(Result).Font.Style := [fsBold];
  Result.Icono := IconoDe(AIcono, FTema.Superficie);
  Result.Colores(TPanel(AParent).Color, FTema.Superficie, FTema.AcentoSuave, ATextoColor,
    FTema.Linea);
  Result.OnClick := AClick;
end;

procedure TfrmArchivos.ConstruirBloque(ACampo: TCampoImagen; const ATitulo: string);
var
  B: ^TBloqueImg;
begin
  B := @FBloque[ACampo];
  B.Panel := TPanel.Create(Self);
  B.Panel.Parent := FCuerpo;
  B.Panel.BevelOuter := bvNone;
  B.Panel.ParentBackground := False;
  B.Panel.StyleElements := [];
  B.Panel.ShowCaption := False;
  B.Panel.Color := FTema.Superficie2;
  B.Img := TImage.Create(Self);
  B.Img.Parent := B.Panel;
  B.Img.Center := True;
  B.Img.Proportional := True;
  B.Img.Stretch := True;
  B.Vacio := TLabel.Create(Self);
  B.Vacio.Parent := B.Panel;
  B.Vacio.AutoSize := False;
  B.Vacio.Alignment := taCenter;
  B.Vacio.Layout := tlCenter;
  B.Vacio.Transparent := True;
  B.Vacio.StyleElements := [];
  B.Vacio.Font.Name := 'Segoe UI';
  B.Vacio.Font.Size := 8;
  B.Vacio.Font.Color := FTema.TextoSuave;
  B.Vacio.Caption := 'Sin ' + LowerCase(ATitulo);
  B.Titulo := TLabel.Create(Self);
  B.Titulo.Parent := B.Panel;
  B.Titulo.AutoSize := True;
  B.Titulo.Transparent := True;
  B.Titulo.StyleElements := [];
  B.Titulo.Font.Name := 'Segoe UI Semibold';
  B.Titulo.Font.Size := 9;
  B.Titulo.Font.Color := FTema.Texto;
  B.Titulo.Caption := ATitulo;
  B.BtnCambiar := NuevoBotonImg(B.Panel, 'Cambiar', 'cargar', ACampo, CambiarClick, FTema.Texto);
  B.BtnVer := NuevoBotonImg(B.Panel, 'Ver', 'ver', ACampo, VerClick, FTema.Texto);
  B.BtnQuitar := NuevoBotonImg(B.Panel, 'Quitar', 'eliminar', ACampo, QuitarClick,
    RGB($B3, $26, $1E));
end;

procedure TfrmArchivos.ConstruirCampos;
begin
  FLblNombre := NuevaEtiqueta('Nombre', True);
  FEdNombre := TEdit.Create(Self);
  FEdNombre.Parent := FCuerpo;
  FEdNombre.StyleElements := [];
  FEdNombre.AutoSize := False;
  FEdNombre.Font.Name := 'Segoe UI';
  FEdNombre.Font.Size := 10;
  FEdNombre.Color := clWhite;
  FEdNombre.Font.Color := FTema.Texto;
  FEdNombre.Height := Esc(28);
  FEdNombre.MaxLength := 100;
  FEdNombre.OnChange := CampoCambio;
  FErrNombre := NuevaEtiqueta('', False);

  FLblTipo := NuevaEtiqueta('Tipo de archivo', True);
  FCmbTipo := TComboBox.Create(Self);
  FCmbTipo.Parent := FCuerpo;
  FCmbTipo.Style := csDropDownList;
  FCmbTipo.Font.Name := 'Segoe UI';
  FCmbTipo.Font.Size := 10;
  FCmbTipo.OnChange := CampoCambio;
  FErrTipo := NuevaEtiqueta('', False);

  FLblResp := NuevaEtiqueta('Responsable', True);
  FCmbResp := TComboBox.Create(Self);
  FCmbResp.Parent := FCuerpo;
  FCmbResp.Style := csDropDownList;
  FCmbResp.Font.Name := 'Segoe UI';
  FCmbResp.Font.Size := 10;
  FCmbResp.OnChange := CampoCambio;

  if FTema.Fondo = TemaOscuro.Fondo then
  begin
    FErrNombre.Font.Color := RGB($FF, $8A, $80);
    FErrTipo.Font.Color := RGB($FF, $8A, $80);
  end
  else
  begin
    FErrNombre.Font.Color := RGB($B3, $26, $1E);
    FErrTipo.Font.Color := RGB($B3, $26, $1E);
  end;

  ConstruirBloque(ciCroquis, 'Croquis');
  ConstruirBloque(ciFoto, 'Foto');

  FLblDesc := NuevaEtiqueta('Descripci'#243'n', True);
  FDescripcion := TRichEdit.Create(Self);
  FDescripcion.Parent := FCuerpo;
  FDescripcion.StyleElements := [];
  FDescripcion.PlainText := False;
  FDescripcion.ScrollBars := ssVertical;
  FDescripcion.Font.Name := 'Segoe UI';
  FDescripcion.Font.Size := 10;
  FDescripcion.Color := clWhite;
  FDescripcion.OnChange := DescripcionCambio;

  FResultado := NuevaEtiqueta('', False);
  FResultado.WordWrap := True;

  FCuerpo.OnResize := CuerpoResize;
  Distribuir;
end;

procedure TfrmArchivos.CuerpoResize(Sender: TObject);
begin
  Distribuir;
end;

{ Reparte los campos segun el ancho real del panel. }
procedure TfrmArchivos.Distribuir;
var
  Ancho, Y, Medio, AltoBloque: Integer;
  C: TCampoImagen;
  X: Integer;
begin
  if (FCuerpo = nil) or (FResultado = nil) then
    Exit;
  Ancho := FCuerpo.ClientWidth - Esc(6);
  if Ancho < Esc(240) then
    Ancho := Esc(240);
  Y := Esc(8);
  FLblNombre.SetBounds(0, Y, Ancho, Esc(16));
  FEdNombre.SetBounds(0, Y + Esc(18), Ancho, Esc(28));
  FErrNombre.SetBounds(0, Y + Esc(48), Ancho, Esc(16));
  Inc(Y, Esc(68));
  Medio := (Ancho - Esc(12)) div 2;
  FLblTipo.SetBounds(0, Y, Medio, Esc(16));
  FCmbTipo.SetBounds(0, Y + Esc(18), Medio, Esc(28));
  FErrTipo.SetBounds(0, Y + Esc(48), Medio, Esc(16));
  FLblResp.SetBounds(Medio + Esc(12), Y, Medio, Esc(16));
  FCmbResp.SetBounds(Medio + Esc(12), Y + Esc(18), Medio, Esc(28));
  Inc(Y, Esc(68));
  AltoBloque := Esc(100);
  for C := Low(TCampoImagen) to High(TCampoImagen) do
  begin
    FBloque[C].Panel.SetBounds(0, Y, Ancho, AltoBloque);
    FBloque[C].Img.SetBounds(Esc(10), Esc(10), Esc(90), Esc(80));
    FBloque[C].Vacio.SetBounds(Esc(10), Esc(10), Esc(90), Esc(80));
    FBloque[C].Titulo.SetBounds(Esc(112), Esc(12), Esc(120), Esc(18));
    X := Esc(112);
    FBloque[C].BtnCambiar.SetBounds(X, Esc(44), Esc(92), Esc(30));
    Inc(X, Esc(96));
    FBloque[C].BtnVer.SetBounds(X, Esc(44), Esc(54), Esc(30));
    Inc(X, Esc(58));
    FBloque[C].BtnQuitar.SetBounds(X, Esc(44), Esc(76), Esc(30));
    Inc(Y, AltoBloque + Esc(10));
  end;
  FLblDesc.SetBounds(0, Y, Ancho, Esc(16));
  FDescripcion.SetBounds(0, Y + Esc(18), Ancho, Esc(130));
  Inc(Y, Esc(156));
  FResultado.SetBounds(0, Y, Ancho, Esc(34));
end;

procedure TfrmArchivos.CargarListas;
var
  O: TOpcion;
  I: Integer;
begin
  FTipos := ListarTiposArchivo(FConn);
  FResponsables := ListarResponsables(FConn);
  FCargando := True;
  try
    FCmbTipo.Items.Clear;
    for I := 0 to High(FTipos) do
      FCmbTipo.Items.AddObject(FTipos[I].Texto, TObject(NativeInt(FTipos[I].Id)));
    FCmbResp.Items.Clear;
    FCmbResp.Items.AddObject('(sin responsable)', TObject(NativeInt(0)));
    for O in FResponsables do
      FCmbResp.Items.AddObject(O.Texto, TObject(NativeInt(O.Id)));
  finally
    FCargando := False;
  end;
end;

function TfrmArchivos.NombreDe(const AOpciones: TArray<TOpcion>; AId: Integer): string;
var
  O: TOpcion;
begin
  Result := '';
  for O in AOpciones do
    if O.Id = AId then
      Exit(O.Texto);
end;

procedure TfrmArchivos.Recargar(ASeleccionarId: Integer);
var
  I: Integer;
  A: TArchivo;
begin
  FArchivos := ListarArchivos(FConn);
  LimpiarFilas;
  for I := 0 to High(FArchivos) do
  begin
    A := FArchivos[I];
    AgregarFila([IntToStr(A.Cod), A.Nombre, NombreDe(FTipos, A.Tipo),
      NombreDe(FResponsables, A.Idresp), IfThen(A.TieneCroquis, 'S'#237, #8212),
      IfThen(A.TieneFoto, 'S'#237, #8212)], A.Cod);
  end;
  RefrescarVista;
  if Length(FArchivos) = 1 then
    FijarSubtitulo('1 archivo')
  else
    FijarSubtitulo(Format('%d archivos', [Length(FArchivos)]));
  if ASeleccionarId >= 0 then
    SeleccionarPorTag(ASeleccionarId);
end;

function TfrmArchivos.BuscarArchivo(ACod: Integer; out A: TArchivo): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(FArchivos) do
    if FArchivos[I].Cod = ACod then
    begin
      A := FArchivos[I];
      Exit(True);
    end;
end;

procedure TfrmArchivos.PonerImagen(ACampo: TCampoImagen; const ABytes: TBytes);
begin
  FBloque[ACampo].Bytes := ABytes;
  FBloque[ACampo].Img.Picture.Assign(nil);
  if (Length(ABytes) = 0) or not CargarMiniatura(ABytes, FBloque[ACampo].Img) then
  begin
    FBloque[ACampo].Bytes := nil;
    FBloque[ACampo].Img.Picture.Assign(nil);
  end;
  FBloque[ACampo].Vacio.Visible := Length(FBloque[ACampo].Bytes) = 0;
  FBloque[ACampo].BtnVer.Enabled := Length(FBloque[ACampo].Bytes) > 0;
  FBloque[ACampo].BtnQuitar.Enabled := Length(FBloque[ACampo].Bytes) > 0;
  FBloque[ACampo].BtnVer.Invalidate;
  FBloque[ACampo].BtnQuitar.Invalidate;
end;

procedure TfrmArchivos.CargarDescripcion(const ATexto: string);
var
  S: TBytesStream;
begin
  FDescripcion.Lines.Clear;
  if ATexto = '' then
    Exit;
  if Copy(ATexto, 1, 5) = '{\rtf' then
  begin
    S := TBytesStream.Create(TEncoding.ANSI.GetBytes(ATexto));
    try
      FDescripcion.Lines.LoadFromStream(S);
    finally
      S.Free;
    end;
  end
  else
    FDescripcion.Text := ATexto;
end;

function TfrmArchivos.TextoDescripcion: string;
var
  S: TBytesStream;
begin
  if Trim(FDescripcion.Text) = '' then
    Exit('');
  S := TBytesStream.Create;
  try
    FDescripcion.Lines.SaveToStream(S);
    Result := TEncoding.ANSI.GetString(S.Bytes, 0, S.Size);
  finally
    S.Free;
  end;
end;

procedure TfrmArchivos.MostrarFicha(const A: TArchivo; AEsNuevo: Boolean);
var
  I: Integer;
  C: TCampoImagen;
begin
  FCargando := True;
  try
    FActual := A;
    FEdNombre.Text := A.Nombre;
    FCmbTipo.ItemIndex := -1;
    for I := 0 to FCmbTipo.Items.Count - 1 do
      if Integer(NativeInt(FCmbTipo.Items.Objects[I])) = A.Tipo then
        FCmbTipo.ItemIndex := I;
    FCmbResp.ItemIndex := 0;
    for I := 0 to FCmbResp.Items.Count - 1 do
      if Integer(NativeInt(FCmbResp.Items.Objects[I])) = A.Idresp then
        FCmbResp.ItemIndex := I;
    for C := Low(TCampoImagen) to High(TCampoImagen) do
    begin
      FBloque[C].Pendiente := False;
      FBloque[C].Quitar := False;
      PonerImagen(C, nil);
    end;
    if not AEsNuevo then
    begin
      if A.TieneCroquis then
        PonerImagen(ciCroquis, LeerImagen(FConn, A.Cod, ciCroquis));
      if A.TieneFoto then
        PonerImagen(ciFoto, LeerImagen(FConn, A.Cod, ciFoto));
      CargarDescripcion(LeerDescripcion(FConn, A.Cod));
    end
    else
      CargarDescripcion('');
    FDescCambiada := False;
    Distribuir;
    LimpiarErrores;
    Resultado('', True);
  finally
    FCargando := False;
  end;
end;

function TfrmArchivos.LeerFicha: TArchivo;
begin
  Result := FActual;
  Result.Nombre := Trim(FEdNombre.Text);
  if FCmbTipo.ItemIndex >= 0 then
    Result.Tipo := Integer(NativeInt(FCmbTipo.Items.Objects[FCmbTipo.ItemIndex]))
  else
    Result.Tipo := 0;
  if FCmbResp.ItemIndex >= 0 then
    Result.Idresp := Integer(NativeInt(FCmbResp.Items.Objects[FCmbResp.ItemIndex]))
  else
    Result.Idresp := 0;
end;

procedure TfrmArchivos.ActualizarBotones;
begin
  FijarBotones(FEstado.PuedeGuardar, True, FActual.Cod <> 0);
end;

procedure TfrmArchivos.LimpiarErrores;
begin
  FErrNombre.Caption := '';
  FErrTipo.Caption := '';
end;

procedure TfrmArchivos.MostrarErrores(const AErrores: TArray<TErrorCampo>);
var
  I: Integer;
begin
  LimpiarErrores;
  for I := 0 to High(AErrores) do
    if AErrores[I].Campo = 'nombre' then
      FErrNombre.Caption := AErrores[I].Mensaje
    else if AErrores[I].Campo = 'tipo' then
      FErrTipo.Caption := AErrores[I].Mensaje;
end;

procedure TfrmArchivos.Resultado(const ATexto: string; AOk: Boolean);
begin
  FResultado.Caption := ATexto;
  if AOk then
    FResultado.Font.Color := RGB($2F, $7D, $4F)
  else if FTema.Fondo = TemaOscuro.Fondo then
    FResultado.Font.Color := RGB($FF, $8A, $80)
  else
    FResultado.Font.Color := RGB($B3, $26, $1E);
end;

procedure TfrmArchivos.CampoCambio(Sender: TObject);
begin
  if FCargando then
    Exit;
  FEstado.MarcarCambio;
  ActualizarBotones;
end;

procedure TfrmArchivos.DescripcionCambio(Sender: TObject);
begin
  if FCargando then
    Exit;
  FDescCambiada := True;
  FEstado.MarcarCambio;
  ActualizarBotones;
end;

procedure TfrmArchivos.CambiarClick(Sender: TObject);
var
  Campo: TCampoImagen;
  Dlg: TOpenDialog;
  Bytes: TBytes;
begin
  Campo := TCampoImagen(TControl(Sender).Tag);
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Filter := 'Im'#225'genes (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp';
    Dlg.Title := 'Elija la imagen';
    if not Dlg.Execute then
      Exit;
    try
      Bytes := PrepararImagen(Dlg.FileName);
    except
      on E: EImagenInvalida do
      begin
        TMensajes.Advertencia(E.Message, 'Imagen no v'#225'lida');
        Exit;
      end;
    end;
  finally
    Dlg.Free;
  end;
  PonerImagen(Campo, Bytes);
  FBloque[Campo].Pendiente := True;
  FBloque[Campo].Quitar := False;
  FEstado.MarcarCambio;
  ActualizarBotones;
end;

procedure TfrmArchivos.VerClick(Sender: TObject);
var
  Campo: TCampoImagen;
  Ruta: string;
begin
  Campo := TCampoImagen(TControl(Sender).Tag);
  if Length(FBloque[Campo].Bytes) = 0 then
    Exit;
  try
    Ruta := TPath.Combine(TPath.GetTempPath, 'archigenio_archivo_' +
      IntToStr(FActual.Cod) + '_' + IfThen(Campo = ciCroquis, 'croquis', 'foto') +
      ExtensionDe(FBloque[Campo].Bytes));
    TFile.WriteAllBytes(Ruta, FBloque[Campo].Bytes);
    ShellExecute(Handle, 'open', PChar(Ruta), nil, nil, SW_SHOWNORMAL);
  except
    on E: Exception do
      TMensajes.Error('No se pudo abrir la imagen: ' + E.Message, 'Archivos');
  end;
end;

procedure TfrmArchivos.QuitarClick(Sender: TObject);
var
  Campo: TCampoImagen;
begin
  Campo := TCampoImagen(TControl(Sender).Tag);
  if Length(FBloque[Campo].Bytes) = 0 then
    Exit;
  PonerImagen(Campo, nil);
  FBloque[Campo].Pendiente := True;
  FBloque[Campo].Quitar := True;
  FEstado.MarcarCambio;
  ActualizarBotones;
end;

procedure TfrmArchivos.AlNuevo;
var
  A: TArchivo;
begin
  A := Default(TArchivo);
  if Length(FTipos) > 0 then
    A.Tipo := FTipos[0].Id;      // sugerencia; no cuenta como cambio
  MostrarFicha(A, True);
  AbrirPanel('Nuevo archivo', False);
  ActualizarBotones;
  FEdNombre.SetFocus;
end;

procedure TfrmArchivos.AlElegirFila(ATag: Integer);
var
  A: TArchivo;
begin
  if not BuscarArchivo(ATag, A) then
    Exit;
  MostrarFicha(A, False);
  AbrirPanel(A.Nombre, True);
  ActualizarBotones;
end;

procedure TfrmArchivos.AlGuardar;
var
  A: TArchivo;
  Errores: TArray<TErrorCampo>;
  Cod: Integer;
  C: TCampoImagen;
begin
  A := LeerFicha;
  Errores := ValidarArchivo(A);
  if Length(Errores) > 0 then
  begin
    MostrarErrores(Errores);
    Resultado('Revise los campos marcados.', False);
    Exit;
  end;
  FConn.StartTransaction;
  try
    Cod := GuardarArchivo(FConn, A);
    for C := Low(TCampoImagen) to High(TCampoImagen) do
      if FBloque[C].Pendiente then
      begin
        if FBloque[C].Quitar then
          QuitarImagen(FConn, Cod, C)
        else
          GuardarImagen(FConn, Cod, C, FBloque[C].Bytes);
      end;
    if FDescCambiada then
      GuardarDescripcion(FConn, Cod, TextoDescripcion);
    FConn.Commit;
  except
    on E: Exception do
    begin
      if FConn.InTransaction then
        FConn.Rollback;
      TMensajes.Error('No se pudo guardar el archivo: ' + E.Message, 'Archivos');
      Exit;
    end;
  end;
  FEstado.Guardado;
  Recargar(Cod);
  AlElegirFila(Cod);
  Resultado('Guardado correctamente.', True);
end;

procedure TfrmArchivos.AlEliminar;
begin
  if FActual.Cod = 0 then
    Exit;
  if not TMensajes.Confirmar('Se eliminar'#225' el archivo "' + FActual.Nombre +
    '". '#191'Desea continuar?', 'Eliminar archivo') then
    Exit;
  try
    EliminarArchivo(FConn, FActual.Cod);
  except
    on E: EArchivoEnUso do
    begin
      TMensajes.Advertencia(E.Message, 'Archivo en uso');
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo eliminar el archivo: ' + E.Message, 'Archivos');
      Exit;
    end;
  end;
  CerrarPanel;
  Recargar(-1);
end;

end.
