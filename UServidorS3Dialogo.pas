unit UServidorS3Dialogo;

{ Dialogo (construido por codigo, sin .dfm) para dar de alta o editar un
  servidor S3/MinIO en el clasificador de servidores, con "Probar conexion".
  El secreto se guarda cifrado y nunca se muestra ni se escribe en mensajes. }

interface

uses
  FireDAC.Comp.Client;

{ Idservidor = 0 crea uno nuevo. Devuelve True si se guardo. }
function EditarServidorS3(Conn: TFDConnection; Idservidor: Integer): Boolean;

implementation

uses
  System.SysUtils, System.Classes, System.UITypes, Vcl.Forms, Vcl.Controls,
  Vcl.StdCtrls, Vcl.Graphics, Vcl.Dialogs, Data.DB, UTema, UAlmacenFicheros,
  UAlmacenS3, UAlmacenServidor, USecretoServidor;

type
  TDialogoS3 = class(TForm)
  private
    FConn: TFDConnection;
    FId: Integer;
    FEtiqueta, FServidor, FPuerto, FBucket, FRegion, FClave, FSecreto: TEdit;
    FHttps: TCheckBox;
    FResultado: TLabel;
    FProbar, FGuardar, FCancelar: TButton;
    FCerrando: Boolean;
    FSecretoGuardado: string;
    function Fila(const Texto: string; Y: Integer; Ancho: Integer = 300): TEdit;
    procedure Cargar;
    function Leer: TDatosServidorS3;
    procedure AlProbar(Sender: TObject);
    procedure AlGuardar(Sender: TObject);
    procedure AlCerrarForm(Sender: TObject; var Action: TCloseAction);
  public
    constructor Crear(AOwner: TComponent; Conn: TFDConnection; Id: Integer);
  end;

constructor TDialogoS3.Crear(AOwner: TComponent; Conn: TFDConnection; Id: Integer);
var
  T: TTemaColores;
begin
  inherited CreateNew(AOwner);
  FConn := Conn;
  FId := Id;
  T := TemaClaro;
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  Caption := 'Servidor S3 (MinIO)';
  ClientWidth := 480;
  ClientHeight := 400;
  Color := T.Fondo;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  OnClose := AlCerrarForm;

  FEtiqueta := Fila('Nombre del servidor', 16);
  FServidor := Fila('Servidor (nombre o IP, sin puerto)', 62);
  FPuerto := Fila('Puerto', 108, 100);
  FBucket := Fila('Bucket', 154);
  FRegion := Fila('Region (vacio = us-east-1)', 200);
  FHttps := TCheckBox.Create(Self);
  FHttps.Parent := Self;
  FHttps.SetBounds(20, 248, 300, 20);
  FHttps.Caption := 'Usar HTTPS (recomendado)';
  FClave := Fila('Clave de acceso (usuario de servicio)', 276, 300);
  FSecreto := Fila('Secreto', 322, 300);
  FSecreto.PasswordChar := '*';

  FResultado := TLabel.Create(Self);
  FResultado.Parent := Self;
  FResultado.SetBounds(20, 372, 440, 18);
  FResultado.AutoSize := False;

  FProbar := TButton.Create(Self);
  FProbar.Parent := Self;
  FProbar.SetBounds(340, 30, 120, 30);
  FProbar.Caption := 'Probar conexion';
  FProbar.OnClick := AlProbar;
  FGuardar := TButton.Create(Self);
  FGuardar.Parent := Self;
  FGuardar.SetBounds(340, 76, 120, 30);
  FGuardar.Caption := 'Guardar';
  FGuardar.OnClick := AlGuardar;
  FCancelar := TButton.Create(Self);
  FCancelar.Parent := Self;
  FCancelar.SetBounds(340, 122, 120, 30);
  FCancelar.Caption := 'Cancelar';
  FCancelar.ModalResult := mrCancel;

  FPuerto.Text := '9000';
  FHttps.Checked := False;
  if FId <> 0 then
    Cargar;
end;

function TDialogoS3.Fila(const Texto: string; Y: Integer; Ancho: Integer): TEdit;
var
  L: TLabel;
begin
  L := TLabel.Create(Self);
  L.Parent := Self;
  L.SetBounds(20, Y, 300, 16);
  L.Caption := Texto;
  Result := TEdit.Create(Self);
  Result.Parent := Self;
  Result.SetBounds(20, Y + 18, Ancho, 24);
end;

procedure TDialogoS3.Cargar;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'SELECT * FROM cl_ftp_Server WHERE Idservidor = :id';
    Q.ParamByName('id').AsInteger := FId;
    Q.Open;
    if Q.IsEmpty then
      Exit;
    FEtiqueta.Text := Q.FieldByName('etiquetaServ').AsString;
    FServidor.Text := Q.FieldByName('ipserver').AsString;
    FPuerto.Text := IntToStr(Q.FieldByName('puerto').AsInteger);
    FBucket.Text := Q.FieldByName('bucket').AsString;
    FRegion.Text := Q.FieldByName('region').AsString;
    FHttps.Checked := Q.FieldByName('usohttps').AsBoolean;
    FClave.Text := Q.FieldByName('clave_acceso').AsString;
    FSecretoGuardado := DescifrarSecreto(Q.FieldByName('secreto_cifrado').AsString);
    FSecreto.TextHint := 'Dejar vacio para conservar el actual';
  finally
    Q.Free;
  end;
end;

function TDialogoS3.Leer: TDatosServidorS3;
begin
  Result := Default(TDatosServidorS3);
  Result.Id := FId;
  Result.Etiqueta := FEtiqueta.Text;
  Result.Endpoint := FServidor.Text;
  Result.Puerto := StrToIntDef(Trim(FPuerto.Text), 0);
  Result.Bucket := FBucket.Text;
  Result.Region := FRegion.Text;
  Result.ClaveAcceso := FClave.Text;
  Result.Secreto := FSecreto.Text;
  Result.UsoHttps := FHttps.Checked;
end;

procedure TDialogoS3.AlProbar(Sender: TObject);
var
  D: TDatosServidorS3;
  Secreto, Host: string;
begin
  D := Leer;
  Secreto := D.Secreto;
  if Secreto = '' then
    Secreto := FSecretoGuardado;
  if (Trim(D.Endpoint) = '') or (Trim(D.Bucket) = '') or (Trim(D.ClaveAcceso) = '') or
    (D.Puerto <= 0) or (Secreto = '') then
  begin
    FResultado.Font.Color := clMaroon;
    FResultado.Caption := 'Complete servidor, puerto, bucket, clave de acceso y secreto.';
    Exit;
  end;
  Host := Trim(D.Endpoint) + ':' + IntToStr(D.Puerto);
  FProbar.Enabled := False;
  FGuardar.Enabled := False;
  FResultado.Font.Color := clWindowText;
  FResultado.Caption := 'Probando la conexion...';
  // La prueba (red) corre fuera del hilo principal; el secreto solo vive en el hilo
  TThread.CreateAnonymousThread(
    procedure
    var
      Alm: TAlmacenS3;
      Ref: IAlmacenFicheros;
      Mensaje: string;
      Ok: Boolean;
    begin
      Alm := TAlmacenS3.Create(Host, Trim(D.Bucket), Trim(D.ClaveAcceso), Secreto,
        Trim(D.Region), D.UsoHttps);
      Ref := Alm;
      Ok := Alm.Probar(Mensaje);
      TThread.Queue(nil,
        procedure
        begin
          if FCerrando then
            Exit;
          FProbar.Enabled := True;
          FGuardar.Enabled := True;
          if Ok then
            FResultado.Font.Color := clGreen
          else
            FResultado.Font.Color := clMaroon;
          FResultado.Caption := Mensaje;
        end);
    end).Start;
end;

procedure TDialogoS3.AlGuardar(Sender: TObject);
begin
  try
    FId := GuardarServidorS3(FConn, Leer);
    ModalResult := mrOk;
  except
    on E: EAlmacen do
    begin
      FResultado.Font.Color := clMaroon;
      FResultado.Caption := E.Message;
    end;
  end;
end;

procedure TDialogoS3.AlCerrarForm(Sender: TObject; var Action: TCloseAction);
begin
  FCerrando := True;
end;

function EditarServidorS3(Conn: TFDConnection; Idservidor: Integer): Boolean;
var
  F: TDialogoS3;
begin
  F := TDialogoS3.Crear(Application, Conn, Idservidor);
  try
    Result := F.ShowModal = mrOk;
  finally
    F.Free;
  end;
end;

end.
