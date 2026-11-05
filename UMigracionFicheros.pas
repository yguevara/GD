unit UMigracionFicheros;

{ Utilidad de migracion de ficheros de un almacen de origen (FTP) a S3/MinIO.
  Recorre tb_ssArchdigital; por cada fila cuyo urlraiz no es 's3://' descarga el
  fichero, lo sube al destino, VERIFICA (tamano y MD5) y solo entonces cambia el
  urlraiz de la fila a 's3://<servidor>/' (el path no cambia, de modo que la
  clave en S3 es el path historico + nombre). Es reanudable: las filas ya en S3
  no se tocan. No escribe ni borra nada en el origen. Solo RTL + FireDAC, sin
  VCL ni UDM. }

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, UAlmacenFicheros;

type
  TFilaFichero = record
    IdEstructura: string;
    Id: Integer;
    CodSubs: string;
    Fecha: TDateTime;
    Version: string;
    Codigodoc: string;
    IdHijo: Integer;
    Nombre, UrlRaiz, Path: string;
  end;

  TResumenMigracion = record
    Total, Migrados, YaMigrados, Fallidos: Integer;
  end;

  TMigracionFicheros = class
  private
    FConn: TFDConnection;
    FOrigen, FDestino: IAlmacenFicheros;
    FIdservidorDestino: Integer;
    FFiltro: string;
    FFallos: TStringList;
    function ActualizarUrlRaiz(const Fila: TFilaFichero): Integer;
  public
    constructor Create(Conn: TFDConnection; Origen, Destino: IAlmacenFicheros;
      IdservidorDestino: Integer);
    destructor Destroy; override;
    { Migra lo pendiente. AlAvanzar(nombre, hecho, total) y AlFallar(clave, motivo)
      son opcionales; Cancelar se consulta antes de cada fichero a migrar. }
    function Migrar(AlAvanzar: TProc<string, Integer, Integer>;
      AlFallar: TProc<string, string>; Cancelar: TFunc<Boolean>): TResumenMigracion;
    { Una linea por fichero fallido: "clave: motivo" }
    function InformeFallos: string;
    procedure GuardarInforme(const Ruta: string);
    { Condicion SQL opcional para limitar las filas (uso interno y pruebas) }
    property Filtro: string read FFiltro write FFiltro;
  end;

implementation

uses
  System.IOUtils, System.Hash, System.Variants, Data.DB, FireDAC.Stan.Param;

const
  TOLERANCIA_FECHA = 10 / 86400000; // 10 ms en dias

function TamanoDe(const Ruta: string): Int64;
var
  F: TFileStream;
begin
  F := TFileStream.Create(Ruta, fmOpenRead or fmShareDenyNone);
  try
    Result := F.Size;
  finally
    F.Free;
  end;
end;

constructor TMigracionFicheros.Create(Conn: TFDConnection; Origen, Destino: IAlmacenFicheros;
  IdservidorDestino: Integer);
begin
  inherited Create;
  FConn := Conn;
  FOrigen := Origen;
  FDestino := Destino;
  FIdservidorDestino := IdservidorDestino;
  FFallos := TStringList.Create;
end;

function TMigracionFicheros.ActualizarUrlRaiz(const Fila: TFilaFichero): Integer;
var
  Q: TFDQuery;
begin
  // La fecha se compara con una tolerancia de 10 ms: datetime de SQL Server
  // redondea a 1/300 s y la igualdad exacta fallaria con milisegundos.
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'UPDATE tb_ssArchdigital SET urlraiz = :u WHERE ' +
      'IdEstructura = :a AND id = :b AND codsubs = :c AND Version = :e AND ' +
      'Codigodoc = :f AND idhijo = :g AND Fecha >= :d AND Fecha <= :h';
    Q.ParamByName('u').AsString := UrlRaizS3(FIdservidorDestino);
    Q.ParamByName('a').AsString := Fila.IdEstructura;
    Q.ParamByName('b').AsInteger := Fila.Id;
    Q.ParamByName('c').AsString := Fila.CodSubs;
    Q.ParamByName('e').AsString := Fila.Version;
    Q.ParamByName('f').AsString := Fila.Codigodoc;
    Q.ParamByName('g').AsInteger := Fila.IdHijo;
    Q.ParamByName('d').AsDateTime := Fila.Fecha - TOLERANCIA_FECHA;
    Q.ParamByName('h').AsDateTime := Fila.Fecha + TOLERANCIA_FECHA;
    Q.ExecSQL;
    Result := Q.RowsAffected;
  finally
    Q.Free;
  end;
end;

destructor TMigracionFicheros.Destroy;
begin
  FFallos.Free;
  inherited;
end;

function TMigracionFicheros.InformeFallos: string;
begin
  Result := FFallos.Text;
end;

procedure TMigracionFicheros.GuardarInforme(const Ruta: string);
begin
  FFallos.SaveToFile(Ruta);
end;

function TMigracionFicheros.Migrar(AlAvanzar: TProc<string, Integer, Integer>;
  AlFallar: TProc<string, string>; Cancelar: TFunc<Boolean>): TResumenMigracion;
var
  Q: TFDQuery;
  Filas: array of TFilaFichero;
  N, I, Pendientes, Hechos, IdS3: Integer;
  F: TFilaFichero;
  Sql: string;

  procedure Fallo(const Clave, Motivo: string);
  begin
    Inc(Result.Fallidos);
    FFallos.Add(Clave + ': ' + Motivo);
    if Assigned(AlFallar) then
      AlFallar(Clave, Motivo);
  end;

  procedure MigrarFila(const Fila: TFilaFichero);
  var
    ClaveOrigen, ClaveDestino, Tmp, Md5Local: string;
    Tam, TamDestino: Int64;
    Sub: TResultadoSubida;
    Filas: Integer;
  begin
    ClaveOrigen := NormalizarRutaFtp(Fila.UrlRaiz + Fila.Path + Fila.Nombre);
    ClaveDestino := NormalizarRutaFtp(Fila.Path + Fila.Nombre);
    if (ClaveDestino <> '') and (ClaveDestino[1] = '/') then
      Delete(ClaveDestino, 1, 1);
    Tmp := TPath.GetTempFileName;
    try
      try
        FOrigen.Descargar(ClaveOrigen, Tmp, nil);
        Tam := TamanoDe(Tmp);
        Md5Local := LowerCase(THashMD5.GetHashStringFromFile(Tmp));
        Sub := FDestino.Subir(Tmp, ClaveDestino, nil);
        if Sub.Tamano <> Tam then
          raise EAlmacen.Create('El tamano subido no coincide con el del origen.');
        if LowerCase(Sub.Md5) <> Md5Local then
          raise EAlmacen.Create('La suma de control subida no coincide con la del origen.');
        if not FDestino.Existe(ClaveDestino, TamDestino) then
          raise EAlmacen.Create('El fichero no aparece en el destino tras subirlo.');
        if TamDestino <> Tam then
          raise EAlmacen.Create('El tamano en el destino no coincide con el del origen.');
        // Verificado: recien ahora se cambia la fila (una sola sentencia, atomica)
        // La fecha se compara con una tolerancia de 10 ms: datetime de SQL Server
        // redondea a 1/300 s y la igualdad exacta fallaria con milisegundos.
        Filas := ActualizarUrlRaiz(Fila);
        if Filas <> 1 then
          raise EAlmacen.Create('No se pudo actualizar el registro del fichero.');
        Inc(Result.Migrados);
      except
        on E: Exception do
          Fallo(ClaveOrigen, E.Message);
      end;
    finally
      if TFile.Exists(Tmp) then
        TFile.Delete(Tmp);
    end;
  end;

begin
  Result := Default(TResumenMigracion);
  FFallos.Clear;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Sql := 'SELECT IdEstructura, id, codsubs, Fecha, Version, Codigodoc, idhijo, ' +
      'nombre, urlraiz, path FROM tb_ssArchdigital';
    if FFiltro <> '' then
      Sql := Sql + ' WHERE ' + FFiltro;
    Sql := Sql + ' ORDER BY IdEstructura, id, codsubs, Fecha, Version, Codigodoc, idhijo';
    Q.Open(Sql);
    N := 0;
    SetLength(Filas, Q.RecordCount);
    while not Q.Eof do
    begin
      F.IdEstructura := Q.FieldByName('IdEstructura').AsString;
      F.Id := Q.FieldByName('id').AsInteger;
      F.CodSubs := Q.FieldByName('codsubs').AsString;
      F.Fecha := Q.FieldByName('Fecha').AsDateTime;
      F.Version := Q.FieldByName('Version').AsString;
      F.Codigodoc := Q.FieldByName('Codigodoc').AsString;
      F.IdHijo := Q.FieldByName('idhijo').AsInteger;
      F.Nombre := Q.FieldByName('nombre').AsString;
      F.UrlRaiz := Q.FieldByName('urlraiz').AsString;
      F.Path := Q.FieldByName('path').AsString;
      if N >= Length(Filas) then
        SetLength(Filas, N + 1);
      Filas[N] := F;
      Inc(N);
      Q.Next;
    end;
    SetLength(Filas, N);
  finally
    Q.Free;
  end;

  Result.Total := N;
  Pendientes := 0;
  for I := 0 to N - 1 do
    if EsUrlRaizS3(Filas[I].UrlRaiz, IdS3) then
      Inc(Result.YaMigrados)
    else
      Inc(Pendientes);

  Hechos := 0;
  for I := 0 to N - 1 do
  begin
    if EsUrlRaizS3(Filas[I].UrlRaiz, IdS3) then
      Continue;
    if Assigned(Cancelar) and Cancelar() then
      Break;
    MigrarFila(Filas[I]);
    Inc(Hechos);
    if Assigned(AlAvanzar) then
      AlAvanzar(Filas[I].Nombre, Hechos, Pendientes);
  end;
end;

end.
