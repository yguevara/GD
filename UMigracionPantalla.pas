unit UMigracionPantalla;

{ Pantalla de la utilidad de migracion de ficheros FTP -> S3/MinIO, construida
  por codigo (sin .dfm). Elige el servidor FTP de origen y el S3 de destino,
  migra con barra de progreso, permite cancelar y reanudar, y guarda los
  fallos en migracion_fallos.log junto al ejecutable. No borra nada del FTP. }

interface

uses
  FireDAC.Comp.Client;

procedure MostrarMigracionFicheros(Conn: TFDConnection);

implementation

uses
  System.SysUtils, System.Classes, System.UITypes, Winapi.Windows, Winapi.ShellAPI,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Dialogs, Vcl.Graphics, Data.DB,
  System.IOUtils, UTema, UAlmacenFicheros, UAlmacenS3, UAlmacenServidor,
  UMigracionFicheros;

type
  TFormMigracion = class(TForm)
  private
    FConn: TFDConnection;
    FOrigen, FDestino: TComboBox;
    FBarra: TProgressBar;
    FEstado, FResumen: TLabel;
    FIniciar, FCancelar, FInforme, FCerrar: TButton;
    FCancelado, FEnCurso: Boolean;
    FRutaInforme: string;
    procedure CargarServidores(Combo: TComboBox; const Tipo: string);
    procedure AlIniciar(Sender: TObject);
    procedure AlCancelar(Sender: TObject);
    procedure AlAbrirInforme(Sender: TObject);
    procedure AlCerrar(Sender: TObject);
    procedure AlCerrarForm(Sender: TObject; var CanClose: Boolean);
    function Etiqueta(const Texto: string; Y: Integer): TLabel;
  public
    constructor Crear(AOwner: TComponent; Conn: TFDConnection);
  end;

function TFormMigracion.Etiqueta(const Texto: string; Y: Integer): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := Self;
  Result.SetBounds(20, Y, 460, 18);
  Result.Caption := Texto;
end;

constructor TFormMigracion.Crear(AOwner: TComponent; Conn: TFDConnection);
var
  T: TTemaColores;
  L: TLabel;
begin
  inherited CreateNew(AOwner);
  FConn := Conn;
  T := TemaClaro;
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  Caption := 'Migrar ficheros a MinIO';
  ClientWidth := 520;
  ClientHeight := 340;
  Color := T.Fondo;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  OnCloseQuery := AlCerrarForm;

  L := Etiqueta('Copia los ficheros del servidor FTP al servidor S3 y verifica cada copia.', 16);
  L.Font.Style := [fsBold];
  Etiqueta('No se borra nada del FTP. Puede cancelar y reanudar cuando quiera.', 38);

  Etiqueta('Servidor FTP de origen', 72);
  FOrigen := TComboBox.Create(Self);
  FOrigen.Parent := Self;
  FOrigen.Style := csDropDownList;
  FOrigen.SetBounds(20, 92, 480, 24);
  CargarServidores(FOrigen, 'FTP');

  Etiqueta('Servidor S3 (MinIO) de destino', 128);
  FDestino := TComboBox.Create(Self);
  FDestino.Parent := Self;
  FDestino.Style := csDropDownList;
  FDestino.SetBounds(20, 148, 480, 24);
  CargarServidores(FDestino, 'S3');

  FBarra := TProgressBar.Create(Self);
  FBarra.Parent := Self;
  FBarra.SetBounds(20, 190, 480, 20);
  FEstado := Etiqueta('', 218);
  FResumen := Etiqueta('', 240);

  FIniciar := TButton.Create(Self);
  FIniciar.Parent := Self;
  FIniciar.SetBounds(20, 286, 110, 30);
  FIniciar.Caption := 'Iniciar';
  FIniciar.OnClick := AlIniciar;
  FCancelar := TButton.Create(Self);
  FCancelar.Parent := Self;
  FCancelar.SetBounds(140, 286, 110, 30);
  FCancelar.Caption := 'Cancelar';
  FCancelar.Enabled := False;
  FCancelar.OnClick := AlCancelar;
  FInforme := TButton.Create(Self);
  FInforme.Parent := Self;
  FInforme.SetBounds(260, 286, 130, 30);
  FInforme.Caption := 'Ver fallos';
  FInforme.Enabled := False;
  FInforme.OnClick := AlAbrirInforme;
  FCerrar := TButton.Create(Self);
  FCerrar.Parent := Self;
  FCerrar.SetBounds(410, 286, 90, 30);
  FCerrar.Caption := 'Cerrar';
  FCerrar.OnClick := AlCerrar;

  // Carpeta del usuario: junto al ejecutable (Program Files) no se puede escribir
  FRutaInforme := TPath.Combine(TPath.Combine(TPath.GetHomePath, 'ArchiGenio'),
    'migracion_fallos.log');
  if (FOrigen.Items.Count = 0) or (FDestino.Items.Count = 0) then
  begin
    FIniciar.Enabled := False;
    FEstado.Caption := 'Hace falta un servidor FTP y un servidor S3 registrados en Clasificadores > Servidores.';
  end;
end;

procedure TFormMigracion.CargarServidores(Combo: TComboBox; const Tipo: string);
var
  Q: TFDQuery;
  Cond: string;
begin
  if Tipo = 'S3' then
    Cond := 'tipo = ''S3'''
  else
    Cond := '(tipo IS NULL OR tipo <> ''S3'')';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.Open('SELECT Idservidor, etiquetaServ, ipserver FROM cl_ftp_Server WHERE ' + Cond +
      ' ORDER BY Idservidor');
    while not Q.Eof do
    begin
      Combo.Items.AddObject(Q.FieldByName('etiquetaServ').AsString + ' (' +
        Q.FieldByName('ipserver').AsString + ')', TObject(Q.FieldByName('Idservidor').AsInteger));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  if Combo.Items.Count > 0 then
    Combo.ItemIndex := 0;
end;

procedure TFormMigracion.AlIniciar(Sender: TObject);
var
  M: TMigracionFicheros;
  R: TResumenMigracion;
  IdOrigen, IdDestino: Integer;
  Destino: IAlmacenFicheros;
  Msg: string;
begin
  IdOrigen := Integer(FOrigen.Items.Objects[FOrigen.ItemIndex]);
  IdDestino := Integer(FDestino.Items.Objects[FDestino.ItemIndex]);
  FCancelado := False;
  FEnCurso := True;
  FIniciar.Enabled := False;
  FCancelar.Enabled := True;
  FInforme.Enabled := False;
  FResumen.Caption := '';
  FEstado.Caption := 'Preparando...';
  Application.ProcessMessages;
  try
    try
      Destino := CrearAlmacen(FConn, IdDestino);
      // Comprobar el destino antes de empezar: con MinIO caido o credenciales
      // malas cada fichero fallaria despues de bajarlo del FTP
      if (Destino as TObject) is TAlmacenS3 then
        if not TAlmacenS3(Destino as TObject).Probar(Msg) then
        begin
          FEstado.Caption := 'No se puede migrar: ' + Msg;
          Exit;
        end;
      M := TMigracionFicheros.Create(FConn, CrearAlmacen(FConn, IdOrigen),
        Destino, IdDestino);
      try
        R := M.Migrar(
          procedure(Nombre: string; Hecho, Total: Integer)
          begin
            FBarra.Max := Total;
            FBarra.Position := Hecho;
            FEstado.Caption := Format('%d de %d: %s', [Hecho, Total, Nombre]);
            Application.ProcessMessages;
          end,
          nil,
          function: Boolean
          begin
            Application.ProcessMessages;
            Result := FCancelado;
          end);
        if R.Fallidos > 0 then
          try
            TDirectory.CreateDirectory(ExtractFilePath(FRutaInforme));
            M.GuardarInforme(FRutaInforme);
            FInforme.Enabled := True;
          except
            // no poder guardar el informe no debe perder el resumen
            FResumen.Caption := 'No se pudo guardar el informe de fallos. ';
          end;
        FResumen.Caption := FResumen.Caption + Format('Migrados: %d. Ya estaban en S3: %d. Fallidos: %d. Total: %d.',
          [R.Migrados, R.YaMigrados, R.Fallidos, R.Total]);
        if FCancelado then
          FEstado.Caption := 'Cancelado. Puede reanudar cuando quiera.'
        else if R.Fallidos = 0 then
          FEstado.Caption := 'Terminado sin errores.'
        else
          FEstado.Caption := 'Terminado con fallos: revise el informe.';
      finally
        M.Free;
      end;
    except
      on E: Exception do
        FEstado.Caption := 'No se pudo migrar: ' + E.Message;
    end;
  finally
    FEnCurso := False;
    FIniciar.Enabled := True;
    FCancelar.Enabled := False;
  end;
end;

procedure TFormMigracion.AlCancelar(Sender: TObject);
begin
  FCancelado := True;
  FCancelar.Enabled := False;
  FEstado.Caption := 'Cancelando al terminar el fichero actual...';
end;

procedure TFormMigracion.AlAbrirInforme(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(FRutaInforme), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormMigracion.AlCerrar(Sender: TObject);
begin
  Close;
end;

procedure TFormMigracion.AlCerrarForm(Sender: TObject; var CanClose: Boolean);
begin
  // No se cierra con una migracion en curso: primero Cancelar
  CanClose := not FEnCurso;
end;

procedure MostrarMigracionFicheros(Conn: TFDConnection);
var
  F: TFormMigracion;
begin
  F := TFormMigracion.Crear(Application, Conn);
  try
    F.ShowModal;
  finally
    F.Free;
  end;
end;

end.
