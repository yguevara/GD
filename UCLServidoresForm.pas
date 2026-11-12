unit UCLServidoresForm;

{ ---------------------------------------------------------------------------
  Clasificador de Servidores de ficheros (FTP y S3 / MinIO), pantalla nueva.

  Hereda de TFormClasificadorBase: tabla a todo el ancho y panel lateral para
  editar. Las reglas (validar, guardar, eliminar protegido, probar conexion)
  estan en UServidoresDatos; aqui solo se presentan.

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

  TfrmServidores = class(TFormClasificadorBase)
  private
    FConn: TFDConnection;
    FServidores: TArray<TServidor>;
    FActual: TServidor;
    FEstadoPorId: TDictionary<Integer, string>;
    FErrores: TDictionary<string, TLabel>;
    FCargando: Boolean;
    FGuardia: IGuardia;
    FBtnFtp, FBtnS3: TBotonShell;
    FEdEtiqueta, FEdDireccion, FEdPuerto, FEdRuta, FEdUsuario, FEdClave: TEdit;
    FEdBucket, FEdRegion, FEdClaveAcceso, FEdSecreto: TEdit;
    FChkHttps: TCheckBox;
    FGrupoFtp, FGrupoS3, FBloqueProbar: TPanel;
    FAyudaClave, FAyudaSecreto, FResultado: TLabel;
    FBtnProbar: TBotonShell;
    function NuevaEtiqueta(AParent: TWinControl; const ATexto: string; X, Y: Integer;
      ASuave: Boolean): TLabel;
    function NuevoCampo(AParent: TWinControl; const AClave, AEtiqueta: string;
      X, Y, AAncho: Integer; ASecreto: Boolean): TEdit;
    function NuevoGrupo(AAlto: Integer): TPanel;
    procedure ConstruirCampos;
    procedure Recargar(ASeleccionarId: Integer);
    function BuscarServidor(AId: Integer; out S: TServidor): Boolean;
    function Destino(const S: TServidor): string;
    procedure MostrarFicha(const S: TServidor; AEsNuevo: Boolean);
    function LeerFicha: TServidor;
    procedure PonerTipo(ATipo: TTipoServidor);
    procedure Reacomodar;
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
  FErrores := TDictionary<string, TLabel>.Create;
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
  FreeAndNil(FErrores);
  inherited Destroy;
end;

function TfrmServidores.NuevaEtiqueta(AParent: TWinControl; const ATexto: string; X, Y: Integer;
  ASuave: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.AutoSize := True;
  Result.Transparent := True;
  Result.StyleElements := [];
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := 8;
  if ASuave then
    Result.Font.Color := FTema.TextoSuave
  else
    Result.Font.Color := FTema.Texto;
  Result.Caption := ATexto;
  Result.SetBounds(X, Y, 10, 16);
end;

function TfrmServidores.NuevoCampo(AParent: TWinControl; const AClave, AEtiqueta: string;
  X, Y, AAncho: Integer; ASecreto: Boolean): TEdit;
var
  Err: TLabel;
begin
  NuevaEtiqueta(AParent, AEtiqueta, X, Y, True);
  Result := TEdit.Create(Self);
  Result.Parent := AParent;
  Result.StyleElements := [];
  Result.Font.Name := 'Segoe UI';
  Result.Font.Size := 10;
  Result.Color := clWhite;
  Result.Font.Color := FTema.Texto;
  Result.SetBounds(X, Y + Esc(18), AAncho, Esc(28));
  if ASecreto then
    Result.PasswordChar := '*';
  Result.OnChange := CampoCambio;
  Err := NuevaEtiqueta(AParent, '', X, Y + Esc(18) + Esc(30), False);
  Err.Font.Size := 8;
  if FTema.Fondo = TemaOscuro.Fondo then
    Err.Font.Color := RGB($FF, $8A, $80)
  else
    Err.Font.Color := RGB($B3, $26, $1E);
  FErrores.AddOrSetValue(AClave, Err);
end;

function TfrmServidores.NuevoGrupo(AAlto: Integer): TPanel;
begin
  Result := TPanel.Create(Self);
  Result.Parent := FCuerpo;
  Result.BevelOuter := bvNone;
  Result.ParentBackground := False;
  Result.StyleElements := [];
  Result.ShowCaption := False;
  Result.Color := FTema.Superficie;
  Result.SetBounds(0, 0, FCuerpo.ClientWidth, AAlto);
  Result.Anchors := [akLeft, akTop, akRight];
end;

procedure TfrmServidores.ConstruirCampos;
var
  Ancho, Fila, Y: Integer;
begin
  Ancho := Esc(390) - Esc(32) - Esc(8);   // ancho util del cuerpo
  Fila := Esc(66);                        // alto de un campo con su error

  // Selector de tipo (dos botones tipo segmento)
  FBtnFtp := TBotonShell.Create(Self);
  FBtnFtp.Parent := FCuerpo;
  FBtnFtp.Estilo := ebPrimario;
  FBtnFtp.Texto := 'FTP';
  TBotonAbierto(FBtnFtp).Font.Name := 'Segoe UI';
  TBotonAbierto(FBtnFtp).Font.Size := 9;
  TBotonAbierto(FBtnFtp).Font.Style := [fsBold];
  FBtnFtp.SetBounds(0, Esc(8), Ancho div 2 - Esc(3), Esc(34));
  FBtnFtp.OnClick := TipoFtpClick;
  FBtnS3 := TBotonShell.Create(Self);
  FBtnS3.Parent := FCuerpo;
  FBtnS3.Estilo := ebPrimario;
  FBtnS3.Texto := 'S3 / MinIO';
  TBotonAbierto(FBtnS3).Font.Name := 'Segoe UI';
  TBotonAbierto(FBtnS3).Font.Size := 9;
  TBotonAbierto(FBtnS3).Font.Style := [fsBold];
  FBtnS3.SetBounds(Ancho div 2 + Esc(3), Esc(8), Ancho div 2 - Esc(3), Esc(34));
  FBtnS3.OnClick := TipoS3Click;

  Y := Esc(54);
  FEdEtiqueta := NuevoCampo(FCuerpo, 'etiqueta', 'Nombre para mostrar', 0, Y, Ancho, False);
  Y := Y + Fila;
  FEdDireccion := NuevoCampo(FCuerpo, 'direccion', 'Direcci'#243'n del servidor', 0, Y,
    Ancho - Esc(96), False);
  FEdPuerto := NuevoCampo(FCuerpo, 'puerto', 'Puerto', Ancho - Esc(84), Y, Esc(84), False);
  Y := Y + Fila;

  // Campos de FTP
  FGrupoFtp := NuevoGrupo(Fila * 3 + Esc(24));
  FGrupoFtp.Top := Y;
  FEdRuta := NuevoCampo(FGrupoFtp, 'ruta', 'Ruta ra'#237'z (opcional)', 0, 0, Ancho, False);
  FEdUsuario := NuevoCampo(FGrupoFtp, 'usuario', 'Usuario', 0, Fila, Ancho, False);
  FEdClave := NuevoCampo(FGrupoFtp, 'clave', 'Contrase'#241'a', 0, Fila * 2, Ancho, True);
  FAyudaClave := NuevaEtiqueta(FGrupoFtp, 'D'#233'jela vac'#237'a al editar para conservar la actual.',
    0, Fila * 3 - Esc(2), True);

  // Campos de S3 / MinIO
  FGrupoS3 := NuevoGrupo(Fila * 3 + Esc(64));
  FGrupoS3.Top := Y;
  FChkHttps := TCheckBox.Create(Self);
  FChkHttps.Parent := FGrupoS3;
  FChkHttps.StyleElements := [];
  FChkHttps.Font.Name := 'Segoe UI';
  FChkHttps.Font.Size := 9;
  FChkHttps.Font.Color := FTema.Texto;
  FChkHttps.Caption := 'Usar conexi'#243'n segura (HTTPS)';
  FChkHttps.SetBounds(0, 0, Ancho, Esc(22));
  FChkHttps.OnClick := CampoCambio;
  FEdBucket := NuevoCampo(FGrupoS3, 'bucket', 'Bucket', 0, Esc(28), Ancho div 2 - Esc(6), False);
  FEdRegion := NuevoCampo(FGrupoS3, 'region', 'Regi'#243'n', Ancho div 2 + Esc(6), Esc(28),
    Ancho div 2 - Esc(6), False);
  FEdClaveAcceso := NuevoCampo(FGrupoS3, 'claveacceso', 'Clave de acceso (Access Key)', 0,
    Esc(28) + Fila, Ancho, False);
  FEdSecreto := NuevoCampo(FGrupoS3, 'secreto', 'Clave secreta (Secret Key)', 0,
    Esc(28) + Fila * 2, Ancho, True);
  FAyudaSecreto := NuevaEtiqueta(FGrupoS3,
    'Se guarda cifrada. D'#233'jela vac'#237'a al editar para conservar la actual.', 0,
    Esc(28) + Fila * 3 - Esc(2), True);

  // Resultado de la prueba y boton
  FBloqueProbar := NuevoGrupo(Esc(96));
  FResultado := NuevaEtiqueta(FBloqueProbar, '', 0, 0, False);
  FResultado.AutoSize := False;
  FResultado.WordWrap := True;
  FResultado.SetBounds(0, 0, Ancho, Esc(40));
  FBtnProbar := TBotonShell.Create(Self);
  FBtnProbar.Parent := FBloqueProbar;
  FBtnProbar.Estilo := ebPrimario;
  FBtnProbar.Texto := 'Probar conexi'#243'n';
  TBotonAbierto(FBtnProbar).Font.Name := 'Segoe UI';
  TBotonAbierto(FBtnProbar).Font.Size := 9;
  TBotonAbierto(FBtnProbar).Font.Style := [fsBold];
  FBtnProbar.Colores(FBloqueProbar.Color, FTema.Superficie, FTema.AcentoSuave, FTema.Texto,
    FTema.Linea);
  FBtnProbar.SetBounds(0, Esc(48), Esc(170), Esc(36));
  FBtnProbar.OnClick := ProbarClick;
  Reacomodar;
end;

procedure TfrmServidores.Reacomodar;
var
  Fondo: TPanel;
begin
  FGrupoFtp.Visible := FActual.Tipo = tsFtp;
  FGrupoS3.Visible := FActual.Tipo = tsS3;
  if FActual.Tipo = tsFtp then
    Fondo := FGrupoFtp
  else
    Fondo := FGrupoS3;
  FBloqueProbar.Top := Fondo.Top + Fondo.Height + Esc(4);
  FBtnFtp.Seleccionado := FActual.Tipo = tsFtp;
  FBtnS3.Seleccionado := FActual.Tipo = tsS3;
  // colores de los segmentos: el elegido con el acento suave
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
    FEdEtiqueta.Text := S.Etiqueta;
    FEdDireccion.Text := S.Direccion;
    if S.Puerto > 0 then
      FEdPuerto.Text := IntToStr(S.Puerto)
    else
      FEdPuerto.Text := '';
    FEdRuta.Text := S.RutaRaiz;
    FEdUsuario.Text := S.Usuario;
    FEdClave.Text := '';
    FEdBucket.Text := S.Bucket;
    FEdRegion.Text := S.Region;
    FChkHttps.Checked := S.UsoHttps;
    FEdClaveAcceso.Text := S.ClaveAcceso;
    FEdSecreto.Text := '';
    // al editar, la clave se puede dejar vacia (se conserva); al crear es obligatoria
    FAyudaClave.Visible := not AEsNuevo;
    FAyudaSecreto.Visible := not AEsNuevo;
    FBtnFtp.Enabled := AEsNuevo;
    FBtnS3.Enabled := AEsNuevo;
    Reacomodar;
    LimpiarErrores;
    Resultado('', True);
  finally
    FCargando := False;
  end;
end;

function TfrmServidores.LeerFicha: TServidor;
begin
  Result := FActual;
  Result.Etiqueta := Trim(FEdEtiqueta.Text);
  Result.Direccion := Trim(FEdDireccion.Text);
  Result.Puerto := StrToIntDef(Trim(FEdPuerto.Text), 0);
  Result.RutaRaiz := Trim(FEdRuta.Text);
  Result.Usuario := Trim(FEdUsuario.Text);
  Result.Clave := FEdClave.Text;
  Result.Bucket := Trim(FEdBucket.Text);
  Result.Region := Trim(FEdRegion.Text);
  Result.UsoHttps := FChkHttps.Checked;
  Result.ClaveAcceso := Trim(FEdClaveAcceso.Text);
  Result.Secreto := FEdSecreto.Text;
end;

procedure TfrmServidores.PonerTipo(ATipo: TTipoServidor);
begin
  if FActual.Id <> 0 then
    Exit;          // el tipo de un servidor existente no cambia
  FActual.Tipo := ATipo;
  Reacomodar;
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
  L: TLabel;
begin
  for L in FErrores.Values do
    L.Caption := '';
end;

procedure TfrmServidores.MostrarErrores(const AErrores: TArray<TErrorCampo>);
var
  I: Integer;
  L: TLabel;
begin
  LimpiarErrores;
  for I := 0 to High(AErrores) do
    if FErrores.TryGetValue(AErrores[I].Campo, L) then
      L.Caption := AErrores[I].Mensaje;
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
  S.UsoHttps := False;
  MostrarFicha(S, True);
  AbrirPanel('Nuevo servidor', False);
  ActualizarBotones;
  FEdEtiqueta.SetFocus;
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
