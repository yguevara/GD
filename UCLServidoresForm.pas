unit UCLServidoresForm;

{ ---------------------------------------------------------------------------
  Clasificador de Servidores de ficheros (FTP y S3 / MinIO), pantalla nueva.

  Hereda de TFormClasificadorBase: tabla a todo el ancho y panel lateral para
  editar. Las reglas (validar, guardar, eliminar protegido, probar conexion)
  estan en UServidoresDatos; aqui solo se presentan.

  Los campos de la ficha se reparten en Distribuir segun el ancho REAL del
  panel (no hay posiciones fijas), y se vuelve a repartir al cambiar el tipo o
  el tamano.

  Entrada: MostrarClasificadorServidores(Conn). La pantalla clasica sigue en
  UCLFtpServer (se abre con clasificadores_clasico.flag o si esta falla).
  --------------------------------------------------------------------------- }

interface

uses
  FireDAC.Comp.Client;

{ Abre la pantalla de Servidores FTP/S3 de forma modal sobre Conn. }
procedure MostrarClasificadorServidores(Conn: TFDConnection);

implementation

uses
  System.SysUtils, System.Classes, System.Variants, System.Generics.Collections,
  Winapi.Windows, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
  UTema, UShellPrincipal, UClasificadorBase, UClasificadorEstado, UServidoresDatos,
  UMensajes;

type
  { Guardia compartida con el hilo de la prueba: avisa si la ventana ya se cerro. }
  IGuardia = interface
    ['{3D5C4E0B-8A9E-4B3C-9B7B-6E2D1F0A7C55}']
    function GetCerrado: Boolean;
    procedure SetCerrado(Valor: Boolean);
  end;

  TGuardia = class(TInterfacedObject, IGuardia)
  private
    FCerrado: Boolean;
  public
    function GetCerrado: Boolean;
    procedure SetCerrado(Valor: Boolean);
  end;

  { Da acceso a la fuente (protegida) de TBotonShell. }
  TBotonAbierto = class(TBotonShell);

  { Un campo de la ficha: rotulo, caja de texto y mensaje de error. }
  TCampoUI = record
    Lbl: TLabel;
    Ed: TEdit;
    Err: TLabel;
  end;

  TfrmServidores = class(TFormClasificadorBase)
  private
    FConn: TFDConnection;
    FServidores: TArray<TServidor>;
    FActual: TServidor;
    FEstadoPorId: TDictionary<Integer, string>;
    FCampos: TDictionary<string, TCampoUI>;
    FCargando: Boolean;
    FGuardia: IGuardia;
    FBtnFtp, FBtnS3: TBotonShell;
    FChkHttps: TCheckBox;
    FAyudaClave, FAyudaSecreto, FResultado: TLabel;
    FBtnProbar: TBotonShell;
    function NuevaEtiqueta(const ATexto: string; ASuave: Boolean): TLabel;
    procedure NuevoCampo(const AClave, AEtiqueta: string; ASecreto: Boolean);
    function Campo(const AClave: string): TEdit;
    function NuevoSegmento(const ATexto: string; AClick: TNotifyEvent): TBotonShell;
    procedure ConstruirCampos;
    procedure Distribuir;
    procedure CuerpoResize(Sender: TObject);
    procedure Recargar(ASeleccionarId: Integer);
    function BuscarServidor(AId: Integer; out S: TServidor): Boolean;
    function Destino(const S: TServidor): string;
    procedure MostrarFicha(const S: TServidor; AEsNuevo: Boolean);
    function LeerFicha: TServidor;
    procedure PonerTipo(ATipo: TTipoServidor);
    procedure ActualizarBotones;
    procedure LimpiarErrores;
    procedure MostrarErrores(const AErrores: TArray<TErrorCampo>);
    procedure Resultado(const ATexto: string; AOk: Boolean);
    procedure CampoCambio(Sender: TObject);
    procedure TipoFtpClick(Sender: TObject);
    procedure TipoS3Click(Sender: TObject);
    procedure ProbarClick(Sender: TObject);
  protected
    procedure AlNuevo; override;
    procedure AlElegirFila(ATag: Integer); override;
    procedure AlGuardar; override;
    procedure AlEliminar; override;
  public
    constructor CrearServidores(AOwner: TComponent; AConn: TFDConnection);
    destructor Destroy; override;
  end;

procedure MostrarClasificadorServidores(Conn: TFDConnection);
var
  Frm: TfrmServidores;
begin
  Frm := TfrmServidores.CrearServidores(nil, Conn);
  try
    Frm.ShowModal;
  finally
    Frm.Free;
  end;
end;

{ TGuardia }

function TGuardia.GetCerrado: Boolean;
begin
  Result := FCerrado;
end;

procedure TGuardia.SetCerrado(Valor: Boolean);
begin
  FCerrado := Valor;
end;

{ TfrmServidores }

constructor TfrmServidores.CrearServidores(AOwner: TComponent; AConn: TFDConnection);
begin
  inherited Create(AOwner);
  Caption := 'Servidores de ficheros';
  FConn := AConn;
  FGuardia := TGuardia.Create;
  FEstadoPorId := TDictionary<Integer, string>.Create;
  FCampos := TDictionary<string, TCampoUI>.Create;
  ConstruirBase('Servidores de ficheros', 'D'#243'nde se guardan los documentos digitales',
    'Nuevo servidor');
  AgregarColumna('Estado', 110);
  AgregarColumna('Nombre', 230);
  AgregarColumna('Tipo', 110);
  AgregarColumna('Direcci'#243'n', 240);
  AgregarColumna('Destino', 230);
  ConstruirCampos;
  Recargar(-1);
  FijarBotones(False, False, False);
end;

destructor TfrmServidores.Destroy;
begin
  if FGuardia <> nil then
    FGuardia.SetCerrado(True);
  FreeAndNil(FEstadoPorId);
  FreeAndNil(FCampos);
  inherited Destroy;
end;

function TfrmServidores.NuevaEtiqueta(const ATexto: string; ASuave: Boolean): TLabel;
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

procedure TfrmServidores.NuevoCampo(const AClave, AEtiqueta: string; ASecreto: Boolean);
var
  C: TCampoUI;
begin
  C.Lbl := NuevaEtiqueta(AEtiqueta, True);
  C.Ed := TEdit.Create(Self);
  C.Ed.Parent := FCuerpo;
  C.Ed.StyleElements := [];
  C.Ed.AutoSize := False;
  C.Ed.Font.Name := 'Segoe UI';
  C.Ed.Font.Size := 10;
  C.Ed.Color := clWhite;
  C.Ed.Font.Color := FTema.Texto;
  C.Ed.Height := Esc(28);
  if ASecreto then
    C.Ed.PasswordChar := '*';
  C.Ed.OnChange := CampoCambio;
  C.Err := NuevaEtiqueta('', False);
  if FTema.Fondo = TemaOscuro.Fondo then
    C.Err.Font.Color := RGB($FF, $8A, $80)
  else
    C.Err.Font.Color := RGB($B3, $26, $1E);
  FCampos.AddOrSetValue(AClave, C);
end;

function TfrmServidores.Campo(const AClave: string): TEdit;
begin
  Result := FCampos[AClave].Ed;
end;

function TfrmServidores.NuevoSegmento(const ATexto: string; AClick: TNotifyEvent): TBotonShell;
begin
  Result := TBotonShell.Create(Self);
  Result.Parent := FCuerpo;
  Result.Estilo := ebPrimario;
  Result.Texto := ATexto;
  TBotonAbierto(Result).Font.Name := 'Segoe UI';
  TBotonAbierto(Result).Font.Size := 9;
  TBotonAbierto(Result).Font.Style := [fsBold];
  Result.OnClick := AClick;
end;

procedure TfrmServidores.ConstruirCampos;
begin
  FBtnFtp := NuevoSegmento('FTP', TipoFtpClick);
  FBtnS3 := NuevoSegmento('S3 / MinIO', TipoS3Click);

  NuevoCampo('etiqueta', 'Nombre para mostrar', False);
  NuevoCampo('direccion', 'Direcci'#243'n del servidor', False);
  NuevoCampo('puerto', 'Puerto', False);
  // FTP
  NuevoCampo('ruta', 'Ruta ra'#237'z (opcional)', False);
  NuevoCampo('usuario', 'Usuario', False);
  NuevoCampo('clave', 'Contrase'#241'a', True);
  FAyudaClave := NuevaEtiqueta('D'#233'jela vac'#237'a al editar para conservar la actual.', True);
  // S3 / MinIO
  FChkHttps := TCheckBox.Create(Self);
  FChkHttps.Parent := FCuerpo;
  FChkHttps.StyleElements := [];
  FChkHttps.Font.Name := 'Segoe UI';
  FChkHttps.Font.Size := 9;
  FChkHttps.Font.Color := FTema.Texto;
  FChkHttps.Caption := 'Usar conexi'#243'n segura (HTTPS)';
  FChkHttps.OnClick := CampoCambio;
  NuevoCampo('bucket', 'Bucket', False);
  NuevoCampo('region', 'Regi'#243'n', False);
  NuevoCampo('claveacceso', 'Clave de acceso (Access Key)', False);
  NuevoCampo('secreto', 'Clave secreta (Secret Key)', True);
  FAyudaSecreto := NuevaEtiqueta(
    'Se guarda cifrada. D'#233'jela vac'#237'a al editar para conservar la actual.', True);

  // Resultado de la prueba y boton
  FResultado := NuevaEtiqueta('', False);
  FResultado.WordWrap := True;
  FBtnProbar := TBotonShell.Create(Self);
  FBtnProbar.Parent := FCuerpo;
  FBtnProbar.Estilo := ebPrimario;
  FBtnProbar.Texto := 'Probar conexi'#243'n';
  TBotonAbierto(FBtnProbar).Font.Name := 'Segoe UI';
  TBotonAbierto(FBtnProbar).Font.Size := 9;
  TBotonAbierto(FBtnProbar).Font.Style := [fsBold];
  FBtnProbar.Colores(FCuerpo.Color, FTema.Superficie, FTema.AcentoSuave, FTema.Texto,
    FTema.Linea);
  FBtnProbar.OnClick := ProbarClick;

  FCuerpo.OnResize := CuerpoResize;
  Distribuir;
end;

procedure TfrmServidores.CuerpoResize(Sender: TObject);
begin
  Distribuir;
end;

{ Reparte los campos segun el tipo del servidor y el ancho real del panel. }
procedure TfrmServidores.Distribuir;
var
  Ancho, Y: Integer;
  C: TCampoUI;

  procedure Fila(const Claves: array of string; const Pesos: array of Integer);
  var
    I, X, Total, Libre, W: Integer;
  begin
    Total := 0;
    for I := 0 to High(Pesos) do
      Inc(Total, Pesos[I]);
    Libre := Ancho - Esc(12) * High(Claves);
    X := 0;
    for I := 0 to High(Claves) do
    begin
      C := FCampos[Claves[I]];
      W := Libre * Pesos[I] div Total;
      C.Lbl.SetBounds(X, Y, W, Esc(16));
      C.Ed.SetBounds(X, Y + Esc(18), W, Esc(28));
      C.Err.SetBounds(X, Y + Esc(48), W, Esc(16));
      C.Lbl.Visible := True;
      C.Ed.Visible := True;
      C.Err.Visible := True;
      X := X + W + Esc(12);
    end;
    Inc(Y, Esc(68));
  end;

begin
  if (FCuerpo = nil) or (FBtnProbar = nil) then
    Exit;
  Ancho := FCuerpo.ClientWidth - Esc(6);
  if Ancho < Esc(220) then
    Ancho := Esc(220);
  for C in FCampos.Values do
  begin
    C.Lbl.Visible := False;
    C.Ed.Visible := False;
    C.Err.Visible := False;
  end;
  FAyudaClave.Visible := False;
  FAyudaSecreto.Visible := False;
  FChkHttps.Visible := False;

  Y := Esc(8);
  FBtnFtp.SetBounds(0, Y, Ancho div 2 - Esc(3), Esc(34));
  FBtnS3.SetBounds(Ancho div 2 + Esc(3), Y, Ancho - (Ancho div 2 + Esc(3)), Esc(34));
  Inc(Y, Esc(48));
  Fila(['etiqueta'], [1]);
  Fila(['direccion', 'puerto'], [3, 1]);
  if FActual.Tipo = tsFtp then
  begin
    Fila(['ruta'], [1]);
    Fila(['usuario'], [1]);
    Fila(['clave'], [1]);
    FAyudaClave.SetBounds(0, Y - Esc(10), Ancho, Esc(16));
    FAyudaClave.Visible := FActual.Id <> 0;
    if FActual.Id <> 0 then
      Inc(Y, Esc(14));
  end
  else
  begin
    FChkHttps.SetBounds(0, Y, Ancho, Esc(22));
    FChkHttps.Visible := True;
    Inc(Y, Esc(30));
    Fila(['bucket', 'region'], [1, 1]);
    Fila(['claveacceso'], [1]);
    Fila(['secreto'], [1]);
    FAyudaSecreto.SetBounds(0, Y - Esc(10), Ancho, Esc(16));
    FAyudaSecreto.Visible := FActual.Id <> 0;
    if FActual.Id <> 0 then
      Inc(Y, Esc(14));
  end;
  FResultado.SetBounds(0, Y, Ancho, Esc(40));
  Inc(Y, Esc(46));
  FBtnProbar.SetBounds(0, Y, Esc(170), Esc(36));

  // El tipo elegido va resaltado
  FBtnFtp.Seleccionado := FActual.Tipo = tsFtp;
  FBtnS3.Seleccionado := FActual.Tipo = tsS3;
  if FActual.Tipo = tsFtp then
  begin
    FBtnFtp.Colores(FCuerpo.Color, FTema.AcentoSuave, FTema.AcentoSuave, FTema.Acento, FTema.Acento);
    FBtnS3.Colores(FCuerpo.Color, FTema.Superficie, FTema.Superficie2, FTema.TextoSuave, FTema.Linea);
  end
  else
  begin
    FBtnS3.Colores(FCuerpo.Color, FTema.AcentoSuave, FTema.AcentoSuave, FTema.Acento, FTema.Acento);
    FBtnFtp.Colores(FCuerpo.Color, FTema.Superficie, FTema.Superficie2, FTema.TextoSuave, FTema.Linea);
  end;
  FBtnFtp.Invalidate;
  FBtnS3.Invalidate;
end;

function TfrmServidores.Destino(const S: TServidor): string;
begin
  if S.Tipo = tsS3 then
    Result := S.Bucket
  else
    Result := S.RutaRaiz;
end;

procedure TfrmServidores.Recargar(ASeleccionarId: Integer);
var
  I, NumS3: Integer;
  S: TServidor;
  Estado, TipoTxt: string;
begin
  FServidores := ListarServidores(FConn);
  LimpiarFilas;
  NumS3 := 0;
  for I := 0 to High(FServidores) do
  begin
    S := FServidores[I];
    if not FEstadoPorId.TryGetValue(S.Id, Estado) then
      Estado := 'Sin probar';
    if S.Tipo = tsS3 then
    begin
      TipoTxt := 'S3 / MinIO';
      Inc(NumS3);
    end
    else
      TipoTxt := 'FTP';
    AgregarFila([Estado, S.Etiqueta, TipoTxt, S.Direccion + ':' + IntToStr(S.Puerto),
      Destino(S)], S.Id);
  end;
  RefrescarVista;
  FijarSubtitulo(Format('%d servidores - %d en S3 / MinIO', [Length(FServidores), NumS3]));
  if ASeleccionarId >= 0 then
    SeleccionarPorTag(ASeleccionarId);
end;

function TfrmServidores.BuscarServidor(AId: Integer; out S: TServidor): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to High(FServidores) do
    if FServidores[I].Id = AId then
    begin
      S := FServidores[I];
      Exit(True);
    end;
end;

procedure TfrmServidores.MostrarFicha(const S: TServidor; AEsNuevo: Boolean);
begin
  FCargando := True;
  try
    FActual := S;
    Campo('etiqueta').Text := S.Etiqueta;
    Campo('direccion').Text := S.Direccion;
    if S.Puerto > 0 then
      Campo('puerto').Text := IntToStr(S.Puerto)
    else
      Campo('puerto').Text := '';
    Campo('ruta').Text := S.RutaRaiz;
    Campo('usuario').Text := S.Usuario;
    Campo('clave').Text := '';
    Campo('bucket').Text := S.Bucket;
    Campo('region').Text := S.Region;
    FChkHttps.Checked := S.UsoHttps;
    Campo('claveacceso').Text := S.ClaveAcceso;
    Campo('secreto').Text := '';
    // el tipo de un servidor existente no se cambia
    FBtnFtp.Enabled := AEsNuevo;
    FBtnS3.Enabled := AEsNuevo;
    Distribuir;
    LimpiarErrores;
    Resultado('', True);
  finally
    FCargando := False;
  end;
end;

function TfrmServidores.LeerFicha: TServidor;
begin
  Result := FActual;
  Result.Etiqueta := Trim(Campo('etiqueta').Text);
  Result.Direccion := Trim(Campo('direccion').Text);
  Result.Puerto := StrToIntDef(Trim(Campo('puerto').Text), 0);
  Result.RutaRaiz := Trim(Campo('ruta').Text);
  Result.Usuario := Trim(Campo('usuario').Text);
  Result.Clave := Campo('clave').Text;
  Result.Bucket := Trim(Campo('bucket').Text);
  Result.Region := Trim(Campo('region').Text);
  Result.UsoHttps := FChkHttps.Checked;
  Result.ClaveAcceso := Trim(Campo('claveacceso').Text);
  Result.Secreto := Campo('secreto').Text;
end;

procedure TfrmServidores.PonerTipo(ATipo: TTipoServidor);
begin
  if FActual.Id <> 0 then
    Exit;
  FActual.Tipo := ATipo;
  Distribuir;
  if not FCargando then
  begin
    FEstado.MarcarCambio;
    ActualizarBotones;
  end;
end;

procedure TfrmServidores.TipoFtpClick(Sender: TObject);
begin
  PonerTipo(tsFtp);
end;

procedure TfrmServidores.TipoS3Click(Sender: TObject);
begin
  PonerTipo(tsS3);
end;

procedure TfrmServidores.ActualizarBotones;
begin
  FijarBotones(FEstado.PuedeGuardar, True, FActual.Id <> 0);
end;

procedure TfrmServidores.LimpiarErrores;
var
  C: TCampoUI;
begin
  for C in FCampos.Values do
    C.Err.Caption := '';
end;

procedure TfrmServidores.MostrarErrores(const AErrores: TArray<TErrorCampo>);
var
  I: Integer;
  C: TCampoUI;
begin
  LimpiarErrores;
  for I := 0 to High(AErrores) do
    if FCampos.TryGetValue(AErrores[I].Campo, C) then
      C.Err.Caption := AErrores[I].Mensaje;
end;

procedure TfrmServidores.Resultado(const ATexto: string; AOk: Boolean);
begin
  FResultado.Caption := ATexto;
  if AOk then
    FResultado.Font.Color := RGB($2F, $7D, $4F)
  else if FTema.Fondo = TemaOscuro.Fondo then
    FResultado.Font.Color := RGB($FF, $8A, $80)
  else
    FResultado.Font.Color := RGB($B3, $26, $1E);
end;

procedure TfrmServidores.CampoCambio(Sender: TObject);
begin
  if FCargando then
    Exit;
  FEstado.MarcarCambio;
  ActualizarBotones;
end;

procedure TfrmServidores.AlNuevo;
var
  S: TServidor;
begin
  S := Default(TServidor);
  S.Tipo := tsS3;          // los ficheros nuevos van a S3 / MinIO
  S.Puerto := 9000;
  MostrarFicha(S, True);
  AbrirPanel('Nuevo servidor', False);
  ActualizarBotones;
  Campo('etiqueta').SetFocus;
end;

procedure TfrmServidores.AlElegirFila(ATag: Integer);
var
  S: TServidor;
begin
  if not BuscarServidor(ATag, S) then
    Exit;
  MostrarFicha(S, False);
  AbrirPanel(S.Etiqueta, True);
  ActualizarBotones;
end;

procedure TfrmServidores.AlGuardar;
var
  S: TServidor;
  Errores: TArray<TErrorCampo>;
  Id: Integer;
begin
  S := LeerFicha;
  Errores := ValidarServidor(S);
  if Length(Errores) > 0 then
  begin
    MostrarErrores(Errores);
    Resultado('Revise los campos marcados.', False);
    Exit;
  end;
  try
    Id := GuardarServidor(FConn, S);
  except
    on E: Exception do
    begin
      TMensajes.Error('No se pudo guardar el servidor: ' + E.Message, 'Servidores');
      Exit;
    end;
  end;
  FEstado.Guardado;
  Recargar(Id);
  AlElegirFila(Id);
  Resultado('Guardado correctamente.', True);
end;

procedure TfrmServidores.AlEliminar;
begin
  if FActual.Id = 0 then
    Exit;
  if not TMensajes.Confirmar('Se eliminar'#225' el servidor "' + FActual.Etiqueta +
    '". '#191'Desea continuar?', 'Eliminar servidor') then
    Exit;
  try
    EliminarServidor(FConn, FActual.Id);
  except
    on E: EServidorEnUso do
    begin
      TMensajes.Advertencia(E.Message, 'Servidor en uso');
      Exit;
    end;
    on E: Exception do
    begin
      TMensajes.Error('No se pudo eliminar el servidor: ' + E.Message, 'Servidores');
      Exit;
    end;
  end;
  CerrarPanel;
  Recargar(-1);
end;

procedure TfrmServidores.ProbarClick(Sender: TObject);
var
  S: TServidor;
  Guardia: IGuardia;
  Id: Integer;
begin
  S := LeerFicha;
  Id := S.Id;
  // La clave guardada se resuelve aqui (hilo principal): la conexion de la base
  // de datos no se usa desde el hilo de la prueba.
  try
    if (Id > 0) and (S.Tipo = tsS3) and (S.Secreto = '') then
      S.Secreto := LeerSecretoGuardado(FConn, Id);
    if (Id > 0) and (S.Tipo = tsFtp) and (S.Clave = '') then
      S.Clave := LeerClaveFtpGuardada(FConn, Id);
  except
    on E: Exception do
    begin
      Resultado('No se pudo leer la clave guardada: ' + E.Message, False);
      Exit;
    end;
  end;
  Guardia := FGuardia;
  FBtnProbar.Enabled := False;
  FBtnProbar.Invalidate;
  Resultado('Probando la conexi'#243'n...', True);
  FResultado.Font.Color := FTema.TextoSuave;
  TThread.CreateAnonymousThread(
    procedure
    var
      Msg: string;
      Ok: Boolean;
    begin
      Ok := ProbarServidor(nil, S, Msg);
      TThread.Queue(nil,
        procedure
        begin
          if Guardia.GetCerrado then
            Exit;
          FBtnProbar.Enabled := True;
          FBtnProbar.Invalidate;
          Resultado(Msg, Ok);
          if Id > 0 then
          begin
            if Ok then
              FEstadoPorId.AddOrSetValue(Id, 'Correcto')
            else
              FEstadoPorId.AddOrSetValue(Id, 'Sin respuesta');
            Recargar(Id);
          end;
        end);
    end).Start;
end;

end.
