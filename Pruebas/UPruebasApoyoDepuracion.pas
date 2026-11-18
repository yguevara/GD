unit UPruebasApoyoDepuracion;

{ Apoyo de las pruebas de base de la depuracion: siembra procesos 'D' a mano (sin
  recorrer los pasos) y los limpia. Codigo en ASCII. }

interface

uses
  FireDAC.Comp.Client, UAlcance, UCandados;

const
  ANIO_DEPURACION_APOYO = 1992;
  COD_ARCHIVO_CENTRAL_APOYO = 9993;
  COD_ARCHIVO_GESTION_APOYO = 9994;
  PREFIJO_SUBSERIE_APOYO = 'ZZPD';

{ Crea un proceso D-1992-n en el paso y estado dados ('C' en curso, 'F' finalizado,
  'X' cancelado) con una unidad (activa o no) del documento. Devuelve su IdProceso.
  Usa el primer nodo de tb_tree. }
function SembrarDepuracion(Conn: TFDConnection; const U: TUnidadDoc; Paso: Integer;
  const Estado: string; Activa: Boolean; const Usuario: string): Integer;

{ Todas las depuraciones del usuario (cualquier ano) y los prestamos viejos de prueba. }
procedure LimpiarDepuraciones(Conn: TFDConnection; const Usuario: string);

{ Crea (si faltan) los archivos de prueba de tipo Central (Tipo = 1) y Gestion
  (Tipo = 2) en cl_ArchivosGestion y devuelven su codigo. }
function ArchivoCentralApoyo(Conn: TFDConnection): Integer;
function ArchivoGestionApoyo(Conn: TFDConnection): Integer;

{ Subserie de prueba Cod (debe empezar por PREFIJO_SUBSERIE_APOYO) con destino 3
  (eliminarlo), tgestion 0 y tcentral = AniosCentral, asignada al primer nodo de
  tb_tree, con Documentos documentos del 10/03/2010 (Codigodoc 'PD-<Cod>-<n>') en el
  archivo Archivo. Devuelve el nodo. Repetir la llamada reemplaza lo anterior. }
function SembrarSerieDepurable(Conn: TFDConnection; const Cod: string; AniosCentral,
  Documentos, Archivo: Integer): TClaveNodo;

{ Unidad de uno de los documentos sembrados (N desde 1). }
function DocumentoDeSerie(const Nodo: TClaveNodo; const Cod: string; N: Integer): TUnidadDoc;

{ Borra todo lo sembrado por SembrarSerieDepurable y los archivos de prueba. }
procedure LimpiarSerieDepurable(Conn: TFDConnection);

implementation

uses
  System.SysUtils, System.Variants, Data.DB, FireDAC.Stan.Param;

function SembrarDepuracion(Conn: TFDConnection; const U: TUnidadDoc; Paso: Integer;
  const Estado: string; Activa: Boolean; const Usuario: string): Integer;
var
  Cons, A: Integer;
begin
  Cons := Integer(Conn.ExecSQLScalar('SELECT COALESCE(MAX(Consecutivo), 0) + 1 FROM ' +
    'prc_proceso WHERE Tipo = ''D'' AND Anio = :a', [ANIO_DEPURACION_APOYO]));
  Conn.ExecSQL('INSERT INTO prc_proceso (Tipo, Anio, Consecutivo, Numero, Estado, Paso, ' +
    'IdEstructura, IdNodo, CreadoPor) SELECT TOP 1 ''D'', :a, :c, :n, :e, :p, ' +
    'IdEstructura, id, :u FROM tb_tree ORDER BY IdEstructura, id',
    [ANIO_DEPURACION_APOYO, Cons, 'D-' + IntToStr(ANIO_DEPURACION_APOYO) + '-' + IntToStr(Cons),
    Estado, Paso, Usuario],
    [ftInteger, ftInteger, ftString, ftString, ftInteger, ftString]);
  Result := Integer(Conn.ExecSQLScalar('SELECT IdProceso FROM prc_proceso WHERE ' +
    'Tipo = ''D'' AND Anio = :a AND Consecutivo = :c', [ANIO_DEPURACION_APOYO, Cons]));
  if Activa then
    A := 1
  else
    A := 0;
  Conn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, Codigodoc, ' +
    'fecha, version, Activa) VALUES (:p, :e, :i, :s, :c, :f, :v, :a)',
    [Result, U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version, A],
    [ftInteger, ftString, ftInteger, ftString, ftString, ftDateTime, ftString, ftInteger]);
end;

procedure LimpiarDepuraciones(Conn: TFDConnection; const Usuario: string);
begin
  Conn.ExecSQL('DELETE FROM prc_proceso WHERE CreadoPor = :u AND Tipo = ''D''', [Usuario]);
  Conn.ExecSQL('DELETE FROM TB_PrestamosDocumentos WHERE IdPrestamo LIKE ''F4A-%''');
  Conn.ExecSQL('DELETE FROM TB_Prestamos WHERE IdPrestamo LIKE ''F4A-%''');
end;

function AsegurarArchivo(Conn: TFDConnection; Cod, Tipo: Integer): Integer;
begin
  if Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM cl_ArchivosGestion WHERE Cod = :c',
    [Cod])) = 0 then
    Conn.ExecSQL('INSERT INTO cl_ArchivosGestion (Cod, nombreArchivo, Tipo, Idresp) ' +
      'VALUES (:c, ''__prueba__'', :t, 1)', [Cod, Tipo]);
  Result := Cod;
end;

function ArchivoCentralApoyo(Conn: TFDConnection): Integer;
begin
  Result := AsegurarArchivo(Conn, COD_ARCHIVO_CENTRAL_APOYO, 1);
end;

function ArchivoGestionApoyo(Conn: TFDConnection): Integer;
begin
  Result := AsegurarArchivo(Conn, COD_ARCHIVO_GESTION_APOYO, 2);
end;

procedure BorrarSerieDeApoyo(Conn: TFDConnection; const Cod: string);
begin
  Conn.ExecSQL('DELETE FROM tb_SeriesDatos WHERE codsubs = :s AND titulodoc = ''__prueba__''', [Cod]);
  Conn.ExecSQL('DELETE FROM tb_Serietree WHERE codsubs = :s', [Cod]);
  Conn.ExecSQL('DELETE FROM cl_subseries WHERE codsubs = :s', [Cod]);
end;

function SembrarSerieDepurable(Conn: TFDConnection; const Cod: string; AniosCentral,
  Documentos, Archivo: Integer): TClaveNodo;
var
  I: Integer;
begin
  BorrarSerieDeApoyo(Conn, Cod);
  Result.IdEstructura := VarToStr(Conn.ExecSQLScalar(
    'SELECT TOP 1 IdEstructura FROM tb_tree ORDER BY IdEstructura, id'));
  Result.Id := Integer(Conn.ExecSQLScalar('SELECT TOP 1 id FROM tb_tree ORDER BY IdEstructura, id'));
  Conn.ExecSQL('INSERT INTO cl_subseries (codserie, codsubs, subserie, Activa, tgestion, ' +
    'tcentral, destino) VALUES (''01'', :s, ''Serie de prueba'', 1, 0, :c, 3)',
    [Cod, AniosCentral]);
  Conn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) VALUES (:e, :i, :s)',
    [Result.IdEstructura, Result.Id, Cod]);
  for I := 1 to Documentos do
    Conn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
      'Codigodoc, titulodoc, Archivo) VALUES (:e, :i, :s, ''2010-03-10'', ''1'', :c, ' +
      '''__prueba__'', :a)', [Result.IdEstructura, Result.Id, Cod,
      'PD-' + Cod + '-' + IntToStr(I), Archivo],
      [ftString, ftInteger, ftString, ftString, ftInteger]);
end;

function DocumentoDeSerie(const Nodo: TClaveNodo; const Cod: string; N: Integer): TUnidadDoc;
begin
  Result.IdEstructura := Nodo.IdEstructura;
  Result.Id := Nodo.Id;
  Result.CodSubs := Cod;
  Result.CodigoDoc := 'PD-' + Cod + '-' + IntToStr(N);
  Result.Fecha := EncodeDate(2010, 3, 10);
  Result.Version := '1';
end;

procedure LimpiarSerieDepurable(Conn: TFDConnection);
var
  Q: TFDQuery;
  Codigos: TArray<string>;
  C: string;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.Open('SELECT codsubs FROM cl_subseries WHERE codsubs LIKE ''' + PREFIJO_SUBSERIE_APOYO + '%''');
    while not Q.Eof do
    begin
      SetLength(Codigos, Length(Codigos) + 1);
      Codigos[High(Codigos)] := Q.FieldByName('codsubs').AsString;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  for C in Codigos do
    BorrarSerieDeApoyo(Conn, C);
  Conn.ExecSQL('DELETE FROM cl_ArchivosGestion WHERE Cod IN (:a, :b) AND nombreArchivo = ''__prueba__''',
    [COD_ARCHIVO_CENTRAL_APOYO, COD_ARCHIVO_GESTION_APOYO]);
end;

end.
