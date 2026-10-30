unit UManagementFileSeries;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.Buttons, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.ExtCtrls,
  Winapi.ShellAPI, System.StrUtils, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxCustomData, cxStyles, cxTL, cxMaskEdit,
  cxTLdxBarBuiltInMenu, dxSkinsCore, dxSkinsDefaultPainters, cxInplaceContainer,
  cxDBTL, cxTLData, JvExControls, JvButton, JvTransparentButton,
  AdvOfficeStatusBar, Vcl.Samples.Gauges, System.DateUtils;

type
  PQry = ^TFDQuery;

  RActiveFTPServer = record
    Ip: string;
    Nombre: string;
    puerto: Integer;
    usuario: string;
    password: string;
    PathServer: string;
  end;

  TfrmManagementFile = class(TForm)
    lbl1: TLabel;
    edt1: TEdit;
    dlgOpenOD: TOpenDialog;
    Timer1: TTimer;
    btnFindInforme: TSpeedButton;
    FDQuery1: TFDQuery;
    sbAD: TAdvOfficeStatusBar;
    pMainContainer: TPanel;
    btnClose: TJvTransparentButton;
    btnautentica: TJvTransparentButton;
    btnFileClean: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    Edit1: TEdit;
    Gauge1: TGauge;
    btnCaratula: TJvTransparentButton;
    procedure btntbtncerrarClick(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btnFindInformeClick(Sender: TObject);
    procedure btnViewInformeClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnautenticaClick(Sender: TObject);
    procedure btnFileCleanClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnCaratulaClick(Sender: TObject);
    procedure GenCara;
  private
    { Private declarations }
  public
    { Public declarations }
    Contenedor: PQry;
    NombreCampo, capt: string;
    function TamFichero(n: string): longint;
    function GetFTPFilePath: string;
    function GetSeriesNameFile(aFecha: TDate): string;
    function GetCantOfDay(aFech: TDateTime): integer;
  end;

var
  frmManagementFile: TfrmManagementFile;
  PathToSaveFile: WideString;

const
  COPY_FILE_NO_BUFFERING = $1000;
  MsgApp = 'Presione Copy para iniciar copia Simple o Múltiple de Archivos';

procedure ManagementFileSeries(aDS: PQry; aFieldName, Etiq: string);

implementation

uses
  UCapaDatos, USystemMsg, UAlcance;

{$R *.dfm}

var
  Cancel: LongBool;

function ProgressRoutine(TotalFileSize, TotalBytesTransferred, StreamSize, StreamBytesTransferred: Int64; dwStreamNumber, dwCallbackReason, hSourceFile, hDestinationFile: Cardinal; lpData: Pointer): Cardinal; stdcall;
var
  Value: Cardinal;
begin
  Application.ProcessMessages;
  if dwCallbackReason = CALLBACK_CHUNK_FINISHED then
  begin
    frmManagementFile.Gauge1.Progress := Round(TotalBytesTransferred / TotalFileSize * 100);
    Application.ProcessMessages;
  end;
  Result := PROGRESS_CONTINUE;
end;

procedure ManagementFileSeries(aDS: PQry; aFieldName, Etiq: string);
begin
  frmManagementFile := TfrmManagementFile.Create(nil);
  with frmManagementFile do
  try
    btnCaratula.Visible := False;
    Contenedor := aDS;
    if UDM.tb_expxseries.Active then
      UDM.tb_expxseries.Refresh;
    if udm.tb_expxtiposerie.Active then
      udm.tb_expxtiposerie.Refresh;
    if UDM.tb_expxseries.Locate('codsubs', UDM.tb_SeriesDatos.FieldByName('codsubs').AsString, []) then
      btnCaratula.Visible := True;
    NombreCampo := aFieldName;
    Caption := Etiq;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmManagementFile.btn3Click(Sender: TObject);
begin
  if (Contenedor^.FieldByName(NombreCampo).Value = null) or (trim(Contenedor^.FieldByName(NombreCampo).asstring) = null) then
  begin
    UDM.sms('Debe especificar un fichero válido para eliminar.', 3);
    Exit;
  end;
  if UDM.sms('¿Está seguro de eliminar el procedimiento almacenado en el campo actual?', 4) = 6 then
  begin
    Contenedor^.Edit;
    Contenedor^.FieldByName(NombreCampo).Clear;
    Contenedor^.Post;
    edt1.Text := '(Vacio)';
  end;
end;

procedure TfrmManagementFile.btnFileCleanClick(Sender: TObject);
var
  DirAsociado: string;
  CaminoFichero, Path: string;
begin
  if (udm.tb_SeriesDatos.FieldByName('fichero').Value = null) or (trim(udm.tb_SeriesDatos.FieldByName('fichero').asstring) = null) then
  begin
    UDM.sms('Debe especificar un fichero válido para eliminar.', 3);
    Exit;
  end;
  if UDM.sms('¿Está seguro de eliminar el fichero actual?', 4) = 6 then
  begin
    UDM.tb_ssArchdigital.Last;
    while not udm.tb_ssArchdigital.Bof do
    begin
      CaminoFichero := UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString + UDM.tb_ssArchdigital.FieldByName('path').AsString + UDM.tb_ssArchdigital.FieldByName('nombre').AsString;
      try
        UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
      except
      end;
      try
        UDM.tb_ssArchdigital.Delete;
      except
      end;
    end;
    CaminoFichero := UDM.cmdServer.FieldByName('path').AsString + udm.tb_SeriesDatos.FieldByName('fichero').AsString;
    Path := Copy(CaminoFichero, 1, LastDelimiter('/', CaminoFichero));
    DirAsociado := Copy(CaminoFichero, LastDelimiter('/', CaminoFichero) + 1, LastDelimiter('.', CaminoFichero) - LastDelimiter('/', CaminoFichero) - 1);
    DirAsociado := Path + DirAsociado + '/';
    //Elimina AD
    try
      UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado + 'Fuentes/', UDM.cmdServer.FieldByName('puerto').AsInteger);
    except
    end;
    try
      UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado + 'Anexos Digitales/', UDM.cmdServer.FieldByName('puerto').AsInteger);
    except
    end;
    try
      UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado, UDM.cmdServer.FieldByName('puerto').AsInteger);
    except
    end;
    try
      UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
    except
    end;
    UDM.tb_SeriesDatos.Edit;
    UDM.tb_SeriesDatos.FieldByName('fichero').Value := Null;
    try
      UDM.tb_SeriesDatos.Post;
      UDM.sms('El fichero se eliminó del sistema satisfactoriamente.', 3);
    except
      on E: EFDException do
      begin
        UDM.tb_SeriesDatos.Cancel;
        UDM.sms('No se pudo eliminar el fichero del sistema. Motivo: ' + e.Message, 1);
      end;
    end;
//    ReactiveAnexos;
//    edt1.Text := '(Vacio)';
  end;
end;
{var
  DirAsociado: string;
  CaminoFichero, Path: string;
begin
  if (Contenedor^.FieldByName(NombreCampo).Value = null) or (trim(Contenedor^.FieldByName(NombreCampo).asstring) = null) then
  begin
    UDM.sms('Debe especificar un fichero válido para eliminar.', 3);
    Exit;
  end;
  if UDM.sms('¿Está seguro de eliminar el fichero actual?', 4) = 6 then
  begin
    UDM.tb_ssArchdigital.Active := False;
    UDM.tb_ssArchdigital.Active := True;
    UDM.tb_ssArchdigital.Last;
    while not udm.tb_ssArchdigital.Bof do
    begin
      CaminoFichero := UDM.tb_ssArchdigital.FieldByName('urlraiz').AsString + UDM.tb_ssArchdigital.FieldByName('path').AsString + UDM.tb_ssArchdigital.FieldByName('nombre').AsString;
      UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
      UDM.tb_ssArchdigital.Next;
    end;
    CaminoFichero := UDM.cmdServer.FieldByName('path').AsString + Contenedor^.FieldByName(NombreCampo).AsString;
    CaminoFichero := AnsiReplaceStr(CaminoFichero, '\', '/');
    CaminoFichero := AnsiReplaceStr(CaminoFichero, '//', '/');
    Path := Copy(CaminoFichero, 1, LastDelimiter('/', CaminoFichero));
    DirAsociado := Copy(CaminoFichero, LastDelimiter('/', CaminoFichero) + 1, LastDelimiter('.', CaminoFichero) - LastDelimiter('/', CaminoFichero) - 1);
    DirAsociado := Path + DirAsociado + '/';
    //Elimina AD
    UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado + 'Fuentes/', UDM.cmdServer.FieldByName('puerto').AsInteger);
    UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado + 'Anexos Digitales/', UDM.cmdServer.FieldByName('puerto').AsInteger);
    UDM.DeleteFTPDirectory(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, DirAsociado, UDM.cmdServer.FieldByName('puerto').AsInteger);
    UDM.DeleteFTPFile(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, CaminoFichero, UDM.cmdServer.FieldByName('puerto').AsInteger);
    Contenedor^.Edit;
    Contenedor^.FieldByName(NombreCampo).Clear;
    try
      Contenedor^.Post;
      UDM.sms('El fichero se elimino del sistema satisfactoriamente.', 3);
    except
      on E: EFDException do
      begin
        Contenedor^.Cancel;
        UDM.sms('No se pudo eliminar el fichero del sistema. Motivo: ' + e.Message, 1);
      end;
    end;
    edt1.Text := '(Vacio)';
  end;
end; }

{**
  Procedimiento TfrmManagementFile.btnFindInformeClick
  Maneja el evento de clic del botón "Buscar Informe", permitiendo al usuario seleccionar y cargar un archivo PDF
  al servidor FTP y almacenar sus metadatos en la base de datos. Valida datos existentes, asegura que el archivo sea
  un PDF y proporciona retroalimentación mediante mensajes en la interfaz de usuario.

  @param Sender Objeto que desencadenó el evento (típicamente un botón).
*}
{**
  Procedimiento TfrmManagementFile.btnFindInformeClick
  Maneja el evento de clic del botón "Buscar Informe", permitiendo al usuario seleccionar y cargar un archivo PDF
  al servidor FTP y almacenar sus metadatos en la base de datos. Valida datos existentes, asegura que el archivo sea
  un PDF y proporciona retroalimentación mediante mensajes en la interfaz de usuario. Los errores se registran usando
  TUDM.log con información contextual.

  @param Sender Objeto que desencadenó el evento (típicamente un botón).
*}

procedure TfrmManagementFile.btnFindInformeClick(Sender: TObject);
const
  ID_EXTENSION_POR_DEFECTO = 102;
  SEPARADOR_RUTA = '\';
  SEPARADOR_FTP = '/';
  EXTENSION_PDF = '.pdf';
  ACCION_ERROR = 1; // Código de acción para errores en el log
  ACCION_EXITO = 3; // Código de acción para operaciones exitosas
var
  NombreArchivo, ExtensionArchivo, RutaBase, UrlRaiz, RutaOrigen, RutaDestino: string;
  ConsultaProcesamiento: TFDQuery;
  Serie, Subserie, Estructura: string;

  {**
    Calcula el nivel de anidamiento de una ruta de archivo contando los separadores de directorio.
    @param RutaArchivo Ruta completa a analizar.
    @param NivelBase Nivel base a restar.
    @return Integer Nivel relativo de la ruta, o -1 para rutas inválidas ('.' o '..').
  *}

  function CalcularNivelRuta(const RutaArchivo: string; NivelBase: Integer): Integer;
  var
    i, ConteoNiveles: Integer;
    NombreExtraido: string;
  begin
    NombreExtraido := ExtractFileName(RutaArchivo);
    if (NombreExtraido = '.') or (NombreExtraido = '..') then
      Exit(-1);

    ConteoNiveles := 0;
    for i := 1 to Length(RutaArchivo) do
      if RutaArchivo[i] = SEPARADOR_RUTA then
        Inc(ConteoNiveles);
    Result := ConteoNiveles - NivelBase;
  end;

  {**
    Obtiene la URL raíz para el almacenamiento de archivos desde la base de datos.
    @return String URL raíz.
  *}
  function ObtenerUrlRaiz: string;
  begin
    Result := UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

  {**
    Construye la ruta de almacenamiento del archivo basada en campos de la base de datos.
    @return String Ruta construida.
  *}
  function ConstruirRutaAlmacenamiento: string;
  begin
    Result := SEPARADOR_RUTA + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + SEPARADOR_RUTA + UDM.SudSDetail.FieldByName('codserie').AsString + SEPARADOR_RUTA + UDM.SudSDetail.FieldByName('codsubs').AsString + SEPARADOR_RUTA + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + SEPARADOR_RUTA;
  end;

 {**
  Obtiene el siguiente ID de hijo disponible desde la tabla tb_ssArchdigital.
  Ejecuta una consulta SQL para obtener el máximo idhijo + 1, o devuelve un valor por defecto si ocurre un error.
  Los errores se registran usando TUDM.log con información contextual.

  @param Serie Código de la serie para el registro en el log.
  @param Subserie Código de la subserie para el registro en el log.
  @param Estructura ID de la estructura para el registro en el log.
  @return Integer Siguiente ID de hijo, o 1 si ocurre un error.
*}
  function ObtenerSiguienteIdHijo(const Serie, Subserie, Estructura: string): Integer;
  const
    ID_HIJO_POR_DEFECTO = 1;
    ACCION_ERROR = 1; // Código de acción para errores en el log
  var
    ConsultaProcesamiento: TFDQuery;
  begin
    Result := ID_HIJO_POR_DEFECTO;
    ConsultaProcesamiento := nil;

    try
      if not Assigned(UDM.Conn) or not UDM.Conn.Connected then
        raise Exception.Create('La conexión a la base de datos no está activa.');

      ConsultaProcesamiento := TFDQuery.Create(nil);
      try
        ConsultaProcesamiento.Connection := UDM.Conn;
        ConsultaProcesamiento.SQL.Text := 'SELECT COALESCE(MAX(idhijo), 0) + 1 AS maximosonvalue FROM tb_ssArchdigital';
        ConsultaProcesamiento.Open;
        if not ConsultaProcesamiento.IsEmpty then
          Result := ConsultaProcesamiento.Fields[0].AsInteger;
      finally
        if Assigned(ConsultaProcesamiento) then
        begin
          ConsultaProcesamiento.Close; // Cerrar explícitamente el query
          ConsultaProcesamiento.Free;
        end;
      end;
    except
      on E: Exception do
      begin
        UDM.log('Error en consulta ObtenerSiguienteIdHijo: ' + E.Message, ACCION_ERROR, Serie, Subserie, Estructura);
        Result := ID_HIJO_POR_DEFECTO; // Asegurar valor por defecto en caso de error
      end;
    end;
  end;

  {**
    Construye la ruta FTP para el almacenamiento basado en la estructura de árbol.
    @return String Ruta FTP construida.
  *}
  function ObtenerRutaFTP: string;
  var
    IdActual: Integer;
    ConstructorRuta: TStringBuilder;
    Consulta: TFDQuery;
  begin
    ConstructorRuta := TStringBuilder.Create;
    Consulta := TFDQuery.Create(nil);
    try
      Consulta.Connection := UDM.Conn;
      ConstructorRuta.Append(SEPARADOR_FTP + UDM.tb_tree.FieldByName('etiqueta').AsString + SEPARADOR_FTP);
      IdActual := UDM.tb_tree.FieldByName('padre').AsInteger;

      while IdActual <> 0 do
      begin
        Consulta.SQL.Text := 'SELECT etiqueta, padre FROM tb_tree WHERE id = :id';
        Consulta.ParamByName('id').AsInteger := IdActual;
        try
          Consulta.Open;
          if not Consulta.IsEmpty then
          begin
            ConstructorRuta.Insert(0, SEPARADOR_FTP + Consulta.Fields[0].AsString);
            IdActual := Consulta.Fields[1].AsInteger;
          end
          else
            Break;
        except
          on E: Exception do
            UDM.log('Error en consulta ObtenerRutaFTP para id ' + IntToStr(IdActual) + ': ' + E.Message, ACCION_ERROR, Serie, Subserie, Estructura);
        end;
      end;

      Consulta.SQL.Text := 'SELECT etiqueta FROM tb_tree WHERE id = 0';
      try
        Consulta.Open;
        if not Consulta.IsEmpty then
          ConstructorRuta.Insert(0, SEPARADOR_FTP + Consulta.Fields[0].AsString);
      except
        on E: Exception do
          UDM.log('Error en consulta raíz ObtenerRutaFTP: ' + E.Message, ACCION_ERROR, Serie, Subserie, Estructura);
      end;

      Result := ConstructorRuta.ToString;
    finally
      Consulta.Free;
      ConstructorRuta.Free;
    end;
  end;

{**
  Valida si el campo especificado en Contenedor ya contiene datos y solicita confirmación para sobrescribirlo.
  Si se confirma, limpia el campo y prepara el Contenedor para edición. Registra acciones y errores usando TUDM.log.

  @param NombreCampo Nombre del campo a validar en Contenedor.
  @param Serie Código de la serie para el registro en el log.
  @param Subserie Código de la subserie para el registro en el log.
  @param Estructura ID de la estructura para el registro en el log.
  @raises Exception Si el usuario cancela la operación o si hay errores en la base de datos.
*}
  procedure ValidarSobrescrituraCampo(const NombreCampo, Serie, Subserie, Estructura: string);
  const
    ACCION_ERROR = 1; // Código de acción para errores en el log
    ACCION_SOBRESCRITURA = 2; // Código de acción para sobrescritura confirmada
  begin
    if not Contenedor^.Active then
      raise Exception.Create('El contenedor de datos no está activo.');

    if not Contenedor^.FieldByName(NombreCampo).IsNull then
    begin
      if UDM.sms('El campo ya contiene un archivo. ¿Desea sobrescribirlo?', 4) <> 6 then // Asumiendo 4 es tipo de diálogo de confirmación
      begin
        UDM.log('Operación de sobrescritura cancelada por el usuario para el campo: ' + NombreCampo, ACCION_ERROR, Serie, Subserie, Estructura);
        raise Exception.Create('Operación cancelada por el usuario.');
      end;

    // Preparar el Contenedor para edición
      if not (Contenedor^.State in [dsEdit, dsInsert]) then
        Contenedor^.Edit
      else
      begin
        Contenedor^.Cancel; // Cancelar cambios previos
        Contenedor^.Edit;   // Iniciar nueva edición
      end;

    // Limpiar el campo
      Contenedor^.FieldByName(NombreCampo).Value := Null;
      try
        Contenedor^.Post;
        UDM.log('Campo sobrescrito exitosamente: ' + NombreCampo, ACCION_SOBRESCRITURA, Serie, Subserie, Estructura);
      except
        on E: EFDException do
        begin
          Contenedor^.Cancel;
          UDM.log('Error al sobrescribir el campo ' + NombreCampo + ': ' + E.Message, ACCION_ERROR, Serie, Subserie, Estructura);
          raise Exception.Create('Error al guardar los cambios: ' + E.Message);
        end;
      end;
    end;
  end;

  {**
    Valida que el archivo seleccionado sea un PDF y que el contenedor esté en un estado válido.
    @raises Exception Si las validaciones fallan.
  *}
  procedure ValidarEntrada;
  begin
    if not Contenedor^.Active then
      raise Exception.Create('El contenedor de datos no está activo.');

    if Contenedor^.State in [dsEdit, dsInsert] then
      raise Exception.Create('El contenedor ya está en modo edición o inserción.');

    if Trim(dlgOpenOD.FileName) = '' then
      raise Exception.Create('No se seleccionó ningún archivo.');

    if AnsiLowerCase(ExtractFileExt(dlgOpenOD.FileName)) <> EXTENSION_PDF then
      raise Exception.Create('El archivo seleccionado debe ser un PDF.');

    ValidarSobrescrituraCampo(NombreCampo, Serie, Subserie, Estructura);
  end;

  function EliminarExtensionArchivo(const Entrada: string): string;
  begin
    Result := ChangeFileExt(Entrada, '');
  end;

  {**
    Transfiere el archivo seleccionado al servidor FTP y actualiza la base de datos.
  *}
  procedure CargarArchivo;
  var
    NombreArchivoSinExt: string;
  begin
    NombreArchivo := ExtractFileName(dlgOpenOD.FileName);
    NombreArchivoSinExt := EliminarExtensionArchivo(NombreArchivo);
    RutaDestino := AnsiReplaceStr(PathSaveBinaryFile, SEPARADOR_RUTA, SEPARADOR_FTP);
    RutaDestino := AnsiReplaceStr(RutaDestino, SEPARADOR_FTP + SEPARADOR_FTP, SEPARADOR_FTP);
    RutaOrigen := PathTemp + NombreArchivo;

    Contenedor^.Edit;
    try
      Contenedor^.FieldByName('idservidor').AsInteger := UDM.tb_Serietree.FieldByName('idservidor').AsInteger;
      Contenedor^.FieldByName('deposito').AsString := UDM.tb_Serietree.FieldByName('deposito').AsString;
//      Contenedor^.FieldByName('posicion').AsString := UDM.tb_Serietree.FieldByName('posicion').AsString;
      Contenedor^.FieldByName('gaveta').AsString := UDM.tb_Serietree.FieldByName('gaveta').AsString;
      Contenedor^.FieldByName('Archivo').AsString := UDM.tb_Serietree.FieldByName('Archivo').AsString;
      Contenedor^.FieldByName('gestor').AsString := UDM.tb_Serietree.FieldByName('gestor').AsString;
      UDM.tb_SeriesDatos.FieldByName('namefile').AsString := NombreArchivoSinExt;
      Contenedor^.FieldByName(NombreCampo).AsString := RutaDestino;

      CopyFile(PWideChar(dlgOpenOD.FileName), PWideChar(RutaOrigen), True);
      try
        Gauge1.Visible := True;
        Gauge1.MinValue := 0;
        Gauge1.Progress := 0;
        UDM.CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, RutaOrigen, UDM.cmdServer.FieldByName('path').AsString + RutaDestino, 'O', UDM.cmdServer.FieldByName('puerto').AsInteger);
        Contenedor^.Post;
        UDM.log('Archivo PDF cargado exitosamente: ' + NombreArchivo, ACCION_EXITO, Serie, Subserie, Estructura);
      finally
        DeleteFile(RutaOrigen);
        Gauge1.Visible := False;
      end;
    except
      Contenedor^.Cancel;
      UDM.log('Error al cargar archivo al FTP: ' + NombreArchivo + ' - ' + Exception(ExceptObject).Message, ACCION_ERROR, Serie, Subserie, Estructura);
      raise;
    end;
  end;

begin
  if not contenedor^.FieldByName(NombreCampo).IsNull then
  begin
    if UDM.sms('Se detectó que esta tratando de sustituir un documento existente, ' + #13 + 'esta operación es irreversible. ¿Desea continuar?', 4) = 6 then
    begin
      Contenedor^.Edit;
      Contenedor^.FieldByName(NombreCampo).Value := null;
      try
        Contenedor^.Post;
        UDM.sms('El documento ha sido eliminado satisfactoriamente.', 3);
      except
        Contenedor^.Cancel;
      end;

    end
    else
      Exit;
  end;

  // Inicializar parámetros para el log
  Serie := UDM.SudSDetail.FieldByName('codserie').AsString;
  Subserie := UDM.SudSDetail.FieldByName('codsubs').AsString;
  Estructura := UDM.tb_Serietree.FieldByName('IdEstructura').AsString;

  try
    if not dlgOpenOD.Execute then
      Exit;
    ValidarEntrada;
    PathSaveBinaryFile := PathToSaveFile + '_' + GetSeriesNameFile(StrToDate(UDM.tb_SeriesDatos.FieldByName('Fecha').AsString)) + EXTENSION_PDF;
    CargarArchivo;

    edt1.Text := dlgOpenOD.FileName;
    UDM.sms('El fichero fue cargado satisfactoriamente.', 3);
  except
    on E: Exception do
    begin
      UDM.sms('Error al cargar el fichero: ' + E.Message, 1);
      UDM.log('Error en btnFindInformeClick: ' + E.Message, ACCION_ERROR, Serie, Subserie, Estructura);
      if Contenedor^.State in [dsEdit, dsInsert] then
        Contenedor^.Cancel;
    end;
  end;
end;



{procedure TfrmManagementFile.btnFindInformeClick(Sender: TObject);
var
  List: TStringList;
  URL, cade, NombreF, NombreExt, PathFTPFile: string;
  Stream: TMemoryStream;
  tmp: RActiveFTPServer;
  Origen, Destino: string;
  sr: TSearchRec;
  i, j, inventario, ext: integer;
  nombre, extension, carpetaorg: string;
  padre: integer;
  idpadreA, idhijo: integer;
  VV: Variant;
  LevelAnt: integer;
//VARIABLES NUEVAS PARA METODO NUEVO...
  LongMLevel: Integer;
  MainLevel: Integer;
  CAD: string;
  level, GObjP: integer;
  GPath, GURL: string;
  SQLQ: string;
  NombreFichero: string;
  Destemp: string;

  function GetLevel(Path: string): Integer;
  var
    i, cont: integer;
    fn: string;
  begin
    fn := ExtractFileName(Path);
    if (fn = '.') or (fn = '..') then
    begin
      result := -1;
      Exit;
    end;
    cont := 0;
    for i := 1 to Length(Path) do
      if Path[i] = '\' then
        inc(cont);
    Result := cont - MainLevel;
  end;

  function getMLevel(Path: string): Integer;
  var
    i, cont: integer;
  begin
    cont := 0;
    LongMLevel := 0;
    for i := 1 to Length(Path) do
    begin
      if Path[i] = '\' then
        inc(cont);
      Inc(LongMLevel);
    end;
    Result := cont;
  end;

  function GetURLRaiz: string;
  begin
    Result := UDM.SudSDetail.FieldByName('carpeta').AsString;
  end;

  function GetPath: string;
  begin
    Result := '\' + UDM.tb_Serietree.FieldByName('IdEstructura').AsString + '\' + UDM.SudSDetail.FieldByName('codserie').AsString + '\' + UDM.SudSDetail.FieldByName('codsubs').AsString + '\' + UDM.tb_SeriesDatos.FieldByName('namefile').AsString + '\';
  end;

  function MaxIdHijo: Integer;
  var
    tmp: Integer;
  begin
    Result := 1;
    with TFDQuery.Create(nil) do
    try
      Active := False;
      Connection := UDM.Conn;
      SQL.Clear;
      SQL.Add('select Max(idhijo)as maximosonvalue from tb_ssArchdigital');
      try
        Active := True;
        if (Fields[0].Value <> null) and (trim(Fields[0].AsString) <> '') then
          Result := Fields[0].AsInteger + 1;
      except
      end;
    finally
      Free;
    end;
  end;

  function removeext(cad1: string): string;
  var
    i: integer;
    flag: Boolean;
  begin
    flag := False;
    for i := length(cad1) - 1 downto 1 do
    begin
      if flag then
        result := cad1[i] + result;
      if cad1[i] <> '.' then

      else
        flag := True;
    end;
  end;

  function GetFTPFilePath: string;
  var
    cad: string;
    id: Integer;
    q: TFDQuery;
  begin
    cad := '/' + UDM.tb_tree.FieldByName('etiqueta').AsString + '/';
    id := UDM.tb_tree.FieldByName('padre').AsInteger;
    q := TFDQuery.Create(nil);
    with q do
    begin
      active := False;
      Connection := UDM.Conn;
      SQL.Clear;
    end;
    while id <> 0 do
    begin
      with q do
      begin
        Active := False;
        SQL.Clear;
        SQL.Add('select etiqueta, padre from tb_tree where id=' + IntToStr(id));
        try
          Active := True;
          id := Fields[1].AsInteger;
          cad := '/' + Fields[0].AsString + cad;
        except
        end;
      end;
    end;
    with q do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select etiqueta, padre from tb_tree where id=0');
      try
        Active := True;
        cad := '/' + Fields[0].AsString + cad;
      except
      end;
    end;
    q.Free;
    Result := cad;
  end;

begin
                                      //Load PDF File into DB Field...
//  List := TStringList.Create;
  if (Contenedor^.State <> dsedit) or (Contenedor^.State <> dsinsert) then
    Contenedor^.Edit;
//  Contenedor^.FieldByName('Fecha').AsDateTime:=datetimetodate(Now);
//  Stream := TMemoryStream.Create;
  if dlgOpenOD.Execute then
  begin
    if trim(dlgOpenOD.FileName) <> '' then
    try
      Contenedor^.FieldByName('idservidor').AsInteger := UDM.tb_Serietree.FieldByName('idservidor').AsInteger;
      Contenedor^.FieldByName('deposito').AsString := UDM.tb_Serietree.FieldByName('deposito').AsString;
      Contenedor^.FieldByName('posicion').AsString := UDM.tb_Serietree.FieldByName('posicion').AsString;
      Contenedor^.FieldByName('gaveta').AsString := UDM.tb_Serietree.FieldByName('gaveta').AsString;
      Contenedor^.FieldByName('Archivo').AsString := UDM.tb_Serietree.FieldByName('Archivo').AsString;
      Contenedor^.FieldByName('gestor').AsString := UDM.tb_Serietree.FieldByName('gestor').AsString;
      PathSaveBinaryFile := PathToSaveFile + '_' + GetSeriesNameFile(StrToDate(UDM.tb_SeriesDatos.FieldByName('Fecha').AsString)) + '.pdf';
//      ForceDirectories(ExtractFilePath(PathSaveBinaryFile));
      try
        NombreFileSS := removeext(ExtractFileName(PathSaveBinaryFile));
        Destino := AnsiReplaceStr(PathSaveBinaryFile, '\', '/');
        Destino := AnsiReplaceStr(Destino, '//', '/');
        Destemp := Destino;
        Destemp := UDM.cmdServer.FieldByName('path').AsString + Destino;
        Destemp := AnsiReplaceStr(Destemp, '\', '/');
        Destemp := AnsiReplaceStr(Destemp, '//', '/');
        NombreFichero := Copy(Destino, LastDelimiter('/', Destino) + 1, LastDelimiter('.', Destino) - LastDelimiter('/', Destino) - 1);
        UDM.tb_SeriesDatos.FieldByName('namefile').AsString := NombreFichero;
        Origen := PathTemp + ExtractFileName(dlgOpenOD.FileName);
        CopyFile(pwidechar(dlgOpenOD.FileName), pwidechar(Origen), True);
        Gauge1.Progress := 0;
        Gauge1.MinValue := 0;
        Gauge1.Visible := True;
        try
          udm.CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, Origen, Destemp, 'O', UDM.cmdServer.FieldByName('puerto').AsInteger);
        except
        end;
        DeleteFile(Origen);
        Gauge1.Visible := False;
        Contenedor^.FieldByName(NombreCampo).AsString := Destino;
        Contenedor^.Post;
        edt1.Text := dlgOpenOD.FileName;
      except
        on E: Exception do
          UDM.sms(e.Message, 1);
      end;

    finally
      UDM.sms('El fichero fue cargado satisfactoriamente.', 3);
    end;

  end;
end;  }

procedure TfrmManagementFile.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 42;
  Application.HelpContext(TopicID);
end;
{begin
  with TfrmsystemMSG.Create(nil) do
  try
    ShowModal;
  finally
    Free;
  end;
end;  }

procedure TfrmManagementFile.btntbtncerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmManagementFile.btnViewInformeClick(Sender: TObject);
begin

end;
{
var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;
  cad: string;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    TBlobField(UDM.tb_SeriesDatos.FieldByName('fichero')).SaveToFile(PathTemp + 'tmpfile.txt');
    List := TStringList.Create;
    List.LoadFromFile(PathTemp + 'tmpfile.txt');
    if FileExists(List[0]) then
    begin
      ext := ExtractFileExt(List[0]);
      if AnsiLowerCase(ext) = '.pdf' then
      begin
        cad := QuotedStr('P') + ' ' + AnsiQuotedStr(List[0], '"');
        UDM.RunAndWaitShell(PathSys + 'Viewer.exe', cad, SW_SHOWMAXIMIZED);
      end;
      //UDM.ViewPDF(List[0]);
    end
    else
      UDM.sms('No existe el fichero especificado.', 1);
  end
  else
  begin
    UDM.sms('Error se encontró un documento para visualizar. Especifique un documento válido para visualizar.', 3);
  end;
end;  }

// Al abrir la gestion de ficheros decide si se ofrece "limpiar" (btnFileClean).
// Con alcance (SQL Server) lo decide UAlcance, igual que en la ventana principal:
// el EGD siempre, el Director el primer dia. Sin alcance (Access), o un gestor
// que aun no es EGD de ningun nodo, conserva la regla heredada: solo el gestor
// de la subserie y solo el primer dia.
procedure TfrmManagementFile.FormActivate(Sender: TObject);
var
  Rol: string;
  Nodo: TClaveNodo;
  Dias: Integer;

  function GetIdResp(aUser: string): Integer;
  var
    cad: string;
  begin
    Result := -1;
    try
      cad := UDM.Conn.ExecSQLScalar('SELECT cl_Resp_Gest_Arch.Idresp FROM cl_Resp_Gest_Arch WHERE lower(cl_Resp_Gest_Arch.usuario) = ' + QuotedStr(AnsiLowerCase(aUser)));
      Result := StrToInt(cad);
    except
    end;
  end;

begin
  GestionFile := True;
  Edit1.Focused;
  Edit1.SetFocus;
  Rol := AnsiLowerCase(UDM.Rol);
  if (UDM.Alcance <> nil) and ((Rol = 'director') or
    ((Rol = 'gestor') and UDM.Alcance.EsEGDDeAlgunNodo)) then
  begin
    Nodo.IdEstructura := UDM.tb_Serietree.FieldByName('IdEstructura').AsString;
    Nodo.Id := UDM.tb_Serietree.FieldByName('id').AsInteger;
    if UDM.tb_SeriesDatos.FieldByName('Fecha').IsNull then
      Dias := 0
    else
      Dias := GetCantOfDay(UDM.tb_SeriesDatos.FieldByName('Fecha').AsDateTime);
    btnFileClean.Visible := UDM.Alcance.PuedeEliminarDocumento(Nodo,
      UDM.tb_Serietree.FieldByName('codsubs').AsString, Dias);
  end
  else if Rol = 'gestor' then
  begin
    if (UDM.tb_Serietree.FieldByName('gestor').asinteger = GetIdResp(UDM.UserName)) then
    begin
      if GetCantOfDay(UDM.tb_SeriesDatos.FieldByName('Fecha').AsDateTime) > 1 then
      begin
        btnFileClean.Visible := false;
      end
      else
      begin
        btnFileClean.Visible := True;
      end;
    end
    else
    begin
      btnFileClean.Visible := false;
    end;
  end;
end;

procedure TfrmManagementFile.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (UDM.tb_SeriesDatos.state = dsEdit) or (UDM.tb_SeriesDatos.state = dsInsert) then
  begin
    try
      UDM.tb_SeriesDatos.Post;
    except
      on E: Exception do
      begin
        UDM.tb_SeriesDatos.Cancel;
      end;
    end;

  end;
  if UDM.tb_expxseries.Locate('codsubs', UDM.tb_SeriesDatos.FieldByName('codsubs').AsString, []) then
  begin
    if (trim(UDM.tb_SeriesDatos.FieldByName('Fichero').AsString) = '') or (UDM.tb_SeriesDatos.FieldByName('Fichero').Value = null) then
    begin
      if UDM.sms('No se ha encontrado un documento definido. ¿Desea definir una carátula para el expediente actual?', 4) = 6 then
      begin
        GenCara;
        CanClose := False;
        Exit;
      end;
    end;
  end;
  CanClose := True;
  GestionFile := False;
end;

procedure TfrmManagementFile.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = 112 then
  begin
    Application.HelpContext(42);
  end;
end;

procedure TfrmManagementFile.GenCara;
var
  existe: Boolean;
  nombretmptable, serie, subserie, NombreCarat: string;
  ServerPath: string;        // Ruta base del servidor FTP obtenida de cmdServer
  FilePath: string;          // Ruta completa del archivo construida
  IdEstructura: string;      // Identificador de la estructura documental
  CodSerie: string;          // Código de la serie documental
  CodSubs: string;           // Código de la subserie
  CodigoDoc: string;         // Código del documento específico
  IdServidorLocal: string;   // ID del servidor definido en el documento
  IdServidorGlobal: string;  // ID del servidor definido en la estructura
  IdServidor: string;        // ID del servidor seleccionado para usar
  IdSerieTree: Integer;      // Identificador numérico de la serie en la estructura
  RutaDestino, RutaOrigen: string;

  function GetSeriesNameFile(aFecha: TDate): string;
  var
    fe: string;
  begin
    fe := datetostr(aFecha) + '' + TimeToStr(Now);
    fe := AnsiReplaceStr(fe, '/', '');
    fe := AnsiReplaceStr(fe, ' ', '');
    fe := AnsiReplaceStr(fe, ':', '');
    result := fe;
  end;

  function ObtenerDatosPrincipales: Boolean;
  begin
    IdEstructura := Trim(UDM.tb_SeriesDatos.FieldByName('IdEstructura').AsString);
    IdSerieTree := UDM.tb_SeriesDatos.FieldByName('id').AsInteger;
    CodSubs := Trim(UDM.tb_SeriesDatos.FieldByName('codsubs').AsString);
    CodigoDoc := Trim(UDM.tb_SeriesDatos.FieldByName('Codigodoc').AsString);
    IdServidorLocal := Trim(UDM.tb_SeriesDatos.FieldByName('Idservidor').AsString);
    ServerPath := Trim(UDM.cmdServer.FieldByName('path').AsString);
    CodSerie := Trim(UDM.SudSDetail.FieldByName('codserie').AsString);
    Result := True;
  end;

  function ConstruirRutaArchivo(const ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc: string): string;
  var
    Builder: TStringBuilder;
  begin
    Result := '';
    Builder := TStringBuilder.Create;
    try
      Builder.Append(ServerPath);
      if not ServerPath.EndsWith(PathDelim) then
        Builder.Append(PathDelim);
      Builder.Append(IdEstructura).Append(PathDelim).Append(CodSerie).Append(PathDelim).Append(CodSubs).Append(PathDelim).Append(CodigoDoc);
      Result := Builder.ToString;
    finally
      Builder.Free;
    end;
  end;

  function GetFileNameWithoutExtension(const FilePath: string): string;
  begin
    Result := ChangeFileExt(ExtractFileName(FilePath), '');
  end;

begin
  ObtenerDatosPrincipales;
  NombreCarat := {CodigoDoc+'_'+ }GetSeriesNameFile(StrToDate(UDM.tb_SeriesDatos.FieldByName('Fecha').AsString)) + EXTENSION_PDF;
  if TBD = 'A' then // MS Access
    UDM.ExportarReporteAPDFyoyo(dbAccess, [PathBD], PathCarat + NombreCarat)
  else // SQL Server
    UDM.ExportarReporteAPDFyoyo(dbSQLServer, [ServerName, dbname, 'geoconn', 'geoconn'], PathCarat + NombreCarat);
  PathSaveBinaryFile := ConstruirRutaArchivo(ServerPath, IdEstructura, CodSerie, CodSubs, CodigoDoc) + '_' + NombreCarat;
  RutaDestino := AnsiReplaceStr(PathSaveBinaryFile, SEPARADOR_RUTA, SEPARADOR_FTP);
  RutaDestino := AnsiReplaceStr(RutaDestino, SEPARADOR_FTP + SEPARADOR_FTP, SEPARADOR_FTP);
  RutaOrigen := PathCarat + NombreCarat;
  UDM.CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, RutaOrigen, UDM.cmdServer.FieldByName('path').AsString + RutaDestino, 'O', UDM.cmdServer.FieldByName('puerto').AsInteger);
  UDM.tb_SeriesDatos.Edit;
  UDM.tb_SeriesDatos.FieldByName('fichero').AsString := RutaDestino;
  UDM.tb_SeriesDatos.FieldByName('namefile').AsString := GetFileNameWithoutExtension(NombreCarat);
  try
    UDM.tb_SeriesDatos.Post;
    UDM.sms('La carátula se ha generado satisfactoriamente.', 3);
  except
    UDM.tb_SeriesDatos.Cancel;
  end;
end;

function TfrmManagementFile.GetCantOfDay(aFech: TDateTime): integer;
begin
  Result := DaysBetween(Now(), aFech);
end;

function TfrmManagementFile.GetFTPFilePath: string;
var
  cad: string;
  id: Integer;
  q: TFDQuery;
begin
  cad := '/' + UDM.tb_tree.FieldByName('etiqueta').AsString + '/';
  id := UDM.tb_tree.FieldByName('padre').AsInteger;
  q := TFDQuery.Create(nil);
  with q do
  begin
    active := False;
    SQL.Clear;
  end;
  while id <> 0 do
  begin
    with q do
    begin
      Active := False;
      SQL.Clear;
      SQL.Add('select etiqueta, padre from tb_tree where id=' + IntToStr(id));
      try
        Active := True;
        id := Fields[1].AsInteger;
        cad := '/' + Fields[0].AsString + cad;
      except
      end;
    end;
  end;
  with q do
  begin
    Active := False;
    SQL.Clear;
    SQL.Add('select etiqueta, padre from tb_tree where id=0');
    try
      Active := True;
      cad := '/' + Fields[0].AsString + cad;
    except
    end;
  end;
  q.Free;
  Result := cad;
end;

function TfrmManagementFile.GetSeriesNameFile(aFecha: TDate): string;
var
  fe: string;
begin
  fe := datetostr(aFecha) + '' + TimeToStr(Now);
  fe := AnsiReplaceStr(fe, '/', '');
  fe := AnsiReplaceStr(fe, ' ', '');
  fe := AnsiReplaceStr(fe, ':', '');
  result := fe;
end;

procedure TfrmManagementFile.btnautenticaClick(Sender: TObject);
var
  param, param1, listParam: string;
begin
  screen.Cursor := crSQLWait;
  param := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
  param1 := UDM.tb_SeriesDatos.FieldByName('codigodoc').AsString;
  listParam := AnsiQuotedStr(param, '"') + ' ' + AnsiQuotedStr(param1, '"');
  UDM.RunAndWaitShell(ExtractFilePath(Application.ExeName) + '\PDFExpressViewer.exe', listParam, SW_SHOWMAXIMIZED);
  screen.Cursor := crDefault;
end;
{var
  param, param1, listParam: string;
begin
  if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
  begin
    screen.Cursor := crSQLWait;
    param := UDM.tb_SeriesDatos.FieldByName('codsubs').AsString;
    param1 := UDM.tb_SeriesDatos.FieldByName('codigodoc').AsString;
    listParam := AnsiQuotedStr(param, '"') + ' ' + AnsiQuotedStr(param1, '"');
    UDM.RunAndWaitShell(ExtractFilePath(Application.ExeName) + '\PDFExpressViewer.exe', listParam, SW_SHOWMAXIMIZED);
    screen.Cursor := crDefault;
  end else begin
    UDM.sms('No existe un fichero válido para ejecutar.', 2);
  end;
end;}
{var
  List: TStringList;
  Path, ext: string;
  flag: Boolean;
  cont: Integer;
  TFBD, TFTMP: Int64;
  cad, Origen, Destino: string;

  procedure ejecutaPDF(Path: string);
  begin
    try
      ShellExecute(Handle, nil, PChar(Path), '', '', SW_SHOWNORMAL);
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo abrir el Informe especificado. Motivo:' + E.Message, 1);
        Exit;
      end;
    end;
  end;

begin
  screen.Cursor := crSQLWait;
  try
    if (UDM.tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(UDM.tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
    begin
      Origen := UDM.cmdServer.FieldByName('path').AsString + UDM.tb_SeriesDatos.FieldByName('fichero').AsString;
      Origen := AnsiReplaceStr(Origen, '\', '/');
      Origen := AnsiReplaceStr(Origen, '//', '/');
      Destino := PathTemp + UDM.tb_SeriesDatos.FieldByName('namefile').AsString;
      UDM.DownloadFileFromFTP(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, Origen, Destino, UDM.cmdServer.FieldByName('puerto').AsInteger);
      if FileExists(Destino) then
      begin
        cad := QuotedStr('P') + ' ' + AnsiQuotedStr(Destino, '"');
        UDM.RunAndWaitShell(PathSys + 'Viewer.exe', cad, SW_SHOWMAXIMIZED);
      end
      else
      begin
        UDM.sms('El fichero no se pudo encontrar en la ruta especificada.', 2);
        Exit;
      end;
    end
    else
    begin
      UDM.sms('Error se encontró un documento para visualizar. Especifique un documento válido para visualizar.', 3);
    end;
  finally
    screen.Cursor := crDefault;
  end;
end; }

procedure TfrmManagementFile.btnCaratulaClick(Sender: TObject);
begin

//  if not GestionFile then
  if UDM.tb_expxseries.Locate('codsubs', UDM.tb_SeriesDatos.FieldByName('codsubs').AsString, []) then
  begin
    if (trim(UDM.tb_SeriesDatos.FieldByName('Fichero').AsString) = '') or (UDM.tb_SeriesDatos.FieldByName('Fichero').Value = null) then
    begin
      if UDM.sms('No se ha encontrado un documento definido. ¿Desea definir una carátula para el expediente actual?', 4) = 6 then
      begin
        GenCara;
      end;
    end;
  end;
end;

procedure TfrmManagementFile.btnCloseClick(Sender: TObject);
begin
  Close;
end;

function TfrmManagementFile.TamFichero(n: string): longint;
var
  f: file of Byte;
begin
  AssignFile(f, n);
  Reset(f);
  TamFichero := FileSize(f);
  CloseFile(f);
end;

procedure TfrmManagementFile.Timer1Timer(Sender: TObject);
begin
  if (Contenedor^.FieldByName(NombreCampo).Value = null) or (Contenedor^.FieldByName(NombreCampo).AsString = '') then
  begin
    edt1.Text := '(<<Vacio>>)';
  end
  else
  begin
    edt1.Text := '(<<Fichero PDF Alamacenado>>)';
  end;
end;

end.

