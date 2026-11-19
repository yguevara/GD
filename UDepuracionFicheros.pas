unit UDepuracionFicheros;

{ ---------------------------------------------------------------------------
  Retiro de los ficheros digitales de los documentos eliminados por una
  depuracion (F4c). La ejecucion (paso 4 -> 5) solo marca los documentos; aqui se
  copian sus ficheros de tb_ssArchdigital a prc_fichero_retiro y, en el paso 5, se
  retiran del almacen uno por uno, con resultado por fichero y reintento.
  Solo RTL + FireDAC: sin VCL ni TUDM.

  Estado de cada fichero:
    P pendiente   R retirado   N ya no existia   E error (se puede reintentar)
    L solo lectura (FTP): se retira a mano y se confirma -> M
    M retirado a mano

  Un fallo en un fichero no detiene a los demas. Las filas de tb_ssArchdigital y
  de tb_SeriesDatos no se tocan: solo se retira el objeto del almacen.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlmacenFicheros;

type
  { Un fichero digital de un documento eliminado. }
  TFicheroRetiro = record
    IdEstructura: string;
    Id: Integer;
    CodSubs, CodigoDoc: string;
    Fecha: TDateTime;
    Version: string;
    IdHijo: Integer;
    UrlRaiz, Path, Nombre: string;
    Estado: string;        // P R N L M E
    Mensaje: string;
  end;

  { Almacen donde esta un fichero segun su raiz, carpeta y nombre; devuelve tambien
    la clave del objeto en ese almacen (igual que TFabricaAlmacen). }
  TFabricaAlmacenRetiro = reference to function(const UrlRaiz, Path, Nombre: string;
    out Clave: string): IAlmacenFicheros;

  TResumenRetiro = record
    Retirados, YaNoExistian, SoloLectura, Errores: Integer;
  end;

{ Copia a prc_fichero_retiro (en P) los ficheros de las unidades activas del proceso.
  Idempotente. Devuelve cuantos se copiaron. }
function CopiarFicherosAlRetiro(Conn: TFDConnection; IdProceso: Integer): Integer;

function FicherosDelRetiro(Conn: TFDConnection; IdProceso: Integer): TArray<TFicheroRetiro>;

{ Retira del almacen los ficheros en P o E de una depuracion en el paso 5. Lanza
  EArgumentException si la depuracion no esta en ese paso; nunca lanza por un fichero. }
function RetirarFicheros(Conn: TFDConnection; IdProceso: Integer;
  const Fabrica: TFabricaAlmacenRetiro; const Usuario: string): TResumenRetiro;

{ Pasa un fichero de L a M (retirado a mano). False si no esta en L. }
function ConfirmarRetiroManual(Conn: TFDConnection; IdProceso: Integer;
  const F: TFicheroRetiro; const Usuario: string): Boolean;

{ Ficheros que impiden cerrar: los que no estan en R, N ni M. }
function FicherosSinResolver(Conn: TFDConnection; IdProceso: Integer): Integer;

function TextoEstadoFichero(const Estado: string): string;

implementation

uses
  System.Variants, Data.DB, FireDAC.Stan.Param, UProceso, UProcesosDatos;

const
  CLAVE_SQL = 'IdProceso = :p AND IdEstructura = :e AND id = :i AND codsubs = :s AND ' +
    'Codigodoc = :c AND fecha = :f AND version = :v AND idhijo = :h';

function CopiarFicherosAlRetiro(Conn: TFDConnection; IdProceso: Integer): Integer;
begin
  Result := Conn.ExecSQL('INSERT INTO prc_fichero_retiro (IdProceso, IdEstructura, id, ' +
    'codsubs, Codigodoc, fecha, version, idhijo, UrlRaiz, Path, Nombre, Estado) ' +
    'SELECT u.IdProceso, f.IdEstructura, f.id, f.codsubs, f.Codigodoc, f.Fecha, f.Version, ' +
    'f.idhijo, f.urlraiz, f.path, f.nombre, ''P'' ' +
    'FROM prc_unidad u INNER JOIN tb_ssArchdigital f ON f.IdEstructura = u.IdEstructura ' +
    'AND f.id = u.id AND f.codsubs = u.codsubs AND f.Codigodoc = u.Codigodoc AND ' +
    'f.Fecha = u.fecha AND f.Version = u.version ' +
    'WHERE u.IdProceso = :p AND u.Activa <> 0 AND NOT EXISTS (SELECT 1 FROM ' +
    'prc_fichero_retiro r WHERE r.IdProceso = u.IdProceso AND r.IdEstructura = f.IdEstructura ' +
    'AND r.id = f.id AND r.codsubs = f.codsubs AND r.Codigodoc = f.Codigodoc AND ' +
    'r.fecha = f.Fecha AND r.version = f.Version AND r.idhijo = f.idhijo)',
    [IdProceso], [ftInteger]);
end;

function FicherosDelRetiro(Conn: TFDConnection; IdProceso: Integer): TArray<TFicheroRetiro>;
var
  Q: TFDQuery;
  N: Integer;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT IdEstructura, id, codsubs, Codigodoc, fecha, version, idhijo, ' +
      'UrlRaiz, Path, Nombre, Estado, Mensaje FROM prc_fichero_retiro WHERE IdProceso = :p ' +
      'ORDER BY Nombre, idhijo';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    SetLength(Result, 0);
    N := 0;
    while not Q.Eof do
    begin
      SetLength(Result, N + 1);
      Result[N].IdEstructura := Q.FieldByName('IdEstructura').AsString;
      Result[N].Id := Q.FieldByName('id').AsInteger;
      Result[N].CodSubs := Q.FieldByName('codsubs').AsString;
      Result[N].CodigoDoc := Q.FieldByName('Codigodoc').AsString;
      Result[N].Fecha := Q.FieldByName('fecha').AsDateTime;
      Result[N].Version := Q.FieldByName('version').AsString;
      Result[N].IdHijo := Q.FieldByName('idhijo').AsInteger;
      Result[N].UrlRaiz := Q.FieldByName('UrlRaiz').AsString;
      Result[N].Path := Q.FieldByName('Path').AsString;
      Result[N].Nombre := Q.FieldByName('Nombre').AsString;
      Result[N].Estado := Trim(Q.FieldByName('Estado').AsString);
      Result[N].Mensaje := Q.FieldByName('Mensaje').AsString;
      Inc(N);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure GuardarResultado(Conn: TFDConnection; IdProceso: Integer; const F: TFicheroRetiro;
  const Estado, Mensaje: string; Hoy: TDateTime);
begin
  Conn.ExecSQL('UPDATE prc_fichero_retiro SET Estado = :est, Mensaje = :m, ' +
    'FechaRetiro = :fr WHERE ' + CLAVE_SQL,
    [Estado, Mensaje, Hoy, IdProceso, F.IdEstructura, F.Id, F.CodSubs, F.CodigoDoc,
     F.Fecha, F.Version, F.IdHijo],
    [ftString, ftString, ftDateTime, ftInteger, ftString, ftInteger, ftString, ftString,
     ftDateTime, ftString, ftInteger]);
end;

function EnPasoDeCierre(Conn: TFDConnection; IdProceso: Integer): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
begin
  Result := LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) and (Tipo = tpDepuracion) and
    (Estado = 'C') and (Paso = 5);
end;

function RetirarFicheros(Conn: TFDConnection; IdProceso: Integer;
  const Fabrica: TFabricaAlmacenRetiro; const Usuario: string): TResumenRetiro;
var
  Lista: TArray<TFicheroRetiro>;
  F: TFicheroRetiro;
  Almacen: IAlmacenFicheros;
  Clave: string;
  Tamano: Int64;
begin
  Result := Default(TResumenRetiro);
  if not EnPasoDeCierre(Conn, IdProceso) then
    raise EArgumentException.Create('La depuraci' + #243 + 'n no est' + #225 +
      ' en el paso de cierre: no se pueden retirar ficheros.');
  Lista := FicherosDelRetiro(Conn, IdProceso);
  for F in Lista do
  begin
    if (F.Estado <> 'P') and (F.Estado <> 'E') then
      Continue;
    try
      Almacen := Fabrica(F.UrlRaiz, F.Path, F.Nombre, Clave);
      if not Almacen.Existe(Clave, Tamano) then
      begin
        GuardarResultado(Conn, IdProceso, F, 'N', 'El fichero ya no estaba en el almacen.', Now);
        Inc(Result.YaNoExistian);
      end
      else
      begin
        Almacen.Borrar(Clave);
        GuardarResultado(Conn, IdProceso, F, 'R', '', Now);
        Inc(Result.Retirados);
      end;
    except
      on E: EAlmacenSoloLectura do
      begin
        GuardarResultado(Conn, IdProceso, F, 'L', Copy(E.Message, 1, 255), Now);
        Inc(Result.SoloLectura);
      end;
      on E: Exception do
      begin
        GuardarResultado(Conn, IdProceso, F, 'E', Copy(E.Message, 1, 255), Now);
        Inc(Result.Errores);
      end;
    end;
  end;
  RegistrarEvento(Conn, IdProceso, Usuario, 'Retiro de ficheros: ' + IntToStr(Result.Retirados) +
    ' retirados, ' + IntToStr(Result.YaNoExistian) + ' ya no exist' + #237 + 'an, ' +
    IntToStr(Result.SoloLectura) + ' de solo lectura, ' + IntToStr(Result.Errores) +
    ' con error');
end;

function ConfirmarRetiroManual(Conn: TFDConnection; IdProceso: Integer;
  const F: TFicheroRetiro; const Usuario: string): Boolean;
begin
  Result := False;
  if not EnPasoDeCierre(Conn, IdProceso) then
    Exit;
  Result := Conn.ExecSQL('UPDATE prc_fichero_retiro SET Estado = ''M'', ' +
    'Mensaje = ''Retirado a mano'', FechaRetiro = :fr WHERE Estado = ''L'' AND ' + CLAVE_SQL,
    [Now, IdProceso, F.IdEstructura, F.Id, F.CodSubs, F.CodigoDoc, F.Fecha, F.Version, F.IdHijo],
    [ftDateTime, ftInteger, ftString, ftInteger, ftString, ftString, ftDateTime, ftString,
     ftInteger]) > 0;
  if Result then
    RegistrarEvento(Conn, IdProceso, Usuario, 'Retiro a mano confirmado: ' + F.Nombre);
end;

function FicherosSinResolver(Conn: TFDConnection; IdProceso: Integer): Integer;
begin
  Result := Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_fichero_retiro WHERE ' +
    'IdProceso = :p AND Estado NOT IN (''R'', ''N'', ''M'')', [IdProceso]));
end;

function TextoEstadoFichero(const Estado: string): string;
begin
  if Estado = 'P' then
    Result := 'Pendiente'
  else if Estado = 'R' then
    Result := 'Retirado'
  else if Estado = 'N' then
    Result := 'Ya no exist' + #237 + 'a'
  else if Estado = 'L' then
    Result := 'Solo lectura: ret' + #237 + 'relo a mano'
  else if Estado = 'M' then
    Result := 'Retirado a mano'
  else if Estado = 'E' then
    Result := 'Error: reintentar'
  else
    Result := Estado;
end;

end.
