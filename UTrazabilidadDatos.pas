unit UTrazabilidadDatos;

{ Trazabilidad del documento (F5), acceso a datos: escritura de eventos en
  tb_log con la clave del documento y lectura de la linea de tiempo (log y
  prestamos) respetando el alcance. Solo RTL + FireDAC (sin VCL ni TUDM).
  Codigo en ASCII. }

interface

uses
  FireDAC.Comp.Client, UAlcance, UDocumentoVista, UTrazabilidad;

{ Inserta un evento del documento en tb_log. Si tb_log aun no tiene las
  columnas de la F5 inserta la fila de siempre (sin clave de documento) para no
  perder la bitacora. Serie va a la columna serie. }
procedure RegistrarEventoDoc(Conn: TFDConnection; const Clave: TClaveDocumento;
  Accion: Integer; const Msg, Usuario, Rol, Serie: string);

{ Linea de tiempo del documento (todas sus versiones: mismo IdEstructura, id,
  CodSubs y Codigodoc): eventos de tb_log con fecha_evento y prestamos
  (Prestado / Devuelto). Mas reciente primero, como mucho Maximo eventos
  (HayMas = hubo mas). Alcance = nil (Access) o administrador: sin filtro; si el
  documento no esta en el alcance del usuario devuelve vacio. Nunca lanza por
  falta de tablas o columnas: devuelve lo que pudo leer. }
function CargarLineaTiempo(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Clave: TClaveDocumento; Maximo: Integer;
  out HayMas: Boolean): TArray<TEventoDoc>;

implementation

uses
  System.SysUtils, System.Generics.Collections, Data.DB, FireDAC.Stan.Param,
  FireDAC.Stan.Error, UAlcanceDatos;

procedure RegistrarEventoDoc(Conn: TFDConnection; const Clave: TClaveDocumento;
  Accion: Integer; const Msg, Usuario, Rol, Serie: string);
const
  BASE_COLS = 'usuariopc, pc, fecha, ip, usuario_sistema, rol, msg, serie, ' +
    'subserie, IdEstructura, accion';
  BASE_VALS = ':a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k';

  procedure Poner(Q: TFDQuery);
  begin
    Q.ParamByName('a').AsString := GetEnvironmentVariable('USERNAME');
    Q.ParamByName('b').AsString := GetEnvironmentVariable('COMPUTERNAME');
    Q.ParamByName('c').AsString := FormatDateTime('[ddd dd mmm, hh:nn:ss:zzz]', Now);
    Q.ParamByName('d').AsString := '';
    Q.ParamByName('e').AsString := Usuario;
    Q.ParamByName('f').AsString := Rol;
    Q.ParamByName('g').AsString := Copy(Msg, 1, 255);
    Q.ParamByName('h').AsString := Serie;
    Q.ParamByName('i').AsString := Clave.CodSubs;
    Q.ParamByName('j').AsString := Clave.IdEstructura;
    Q.ParamByName('k').AsInteger := Accion;
  end;

var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    try
      Q.SQL.Text := 'INSERT INTO tb_log (' + BASE_COLS + ', codigodoc, iddoc, ' +
        'codsubsdoc, versiondoc, fecha_evento) VALUES (' + BASE_VALS +
        ', :m, :n, :o, :p, :q)';
      Poner(Q);
      Q.ParamByName('m').AsString := Copy(Clave.Codigodoc, 1, 20);
      Q.ParamByName('n').AsInteger := Clave.Id;
      Q.ParamByName('o').AsString := Clave.CodSubs;
      Q.ParamByName('p').AsString := Copy(Clave.Version, 1, 12);
      Q.ParamByName('q').AsDateTime := Now;
      Q.ExecSQL;
    except
      on EFDDBEngineException do
      begin
        // Sin las columnas de la F5: la bitacora de siempre
        Q.SQL.Text := 'INSERT INTO tb_log (' + BASE_COLS + ') VALUES (' + BASE_VALS + ')';
        Poner(Q);
        Q.ExecSQL;
      end;
    end;
  finally
    Q.Free;
  end;
end;

function EnAlcance(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Clave: TClaveDocumento): Boolean;
var
  Q: TFDQuery;
  Filtro: TFiltroSql;
begin
  Filtro := FiltroDocumentos(Alcance, 'H');
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT COUNT(*) AS N FROM tb_SeriesDatos H WHERE ' +
      'H.IdEstructura = :est AND H.id = :id AND H.codsubs = :cs AND ' +
      'H.Codigodoc = :cod AND (' + Filtro.Condicion + ')';
    Q.ParamByName('est').AsString := Clave.IdEstructura;
    Q.ParamByName('id').AsInteger := Clave.Id;
    Q.ParamByName('cs').AsString := Clave.CodSubs;
    Q.ParamByName('cod').AsString := Clave.Codigodoc;
    AplicarParametros(Q, Filtro);
    Q.Open;
    Result := Q.FieldByName('N').AsInteger > 0;
  finally
    Q.Free;
  end;
end;

procedure LeerLog(Conn: TFDConnection; const Clave: TClaveDocumento;
  Lista: TList<TEventoDoc>);
var
  Q: TFDQuery;
  E: TEventoDoc;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT fecha_evento, accion, usuario_sistema, rol, msg ' +
      'FROM tb_log WHERE codigodoc = :cod AND IdEstructura = :est AND ' +
      'iddoc = :id AND codsubsdoc = :cs AND fecha_evento IS NOT NULL';
    Q.ParamByName('cod').AsString := Clave.Codigodoc;
    Q.ParamByName('est').AsString := Clave.IdEstructura;
    Q.ParamByName('id').AsInteger := Clave.Id;
    Q.ParamByName('cs').AsString := Clave.CodSubs;
    Q.Open;
    while not Q.Eof do
    begin
      E := Default(TEventoDoc);
      E.Fecha := Q.FieldByName('fecha_evento').AsDateTime;
      E.Tipo := TipoDesdeAccion(Q.FieldByName('accion').AsInteger);
      E.Usuario := Q.FieldByName('usuario_sistema').AsString;
      E.Rol := Q.FieldByName('rol').AsString;
      E.Detalle := Q.FieldByName('msg').AsString;
      Lista.Add(E);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure LeerPrestamos(Conn: TFDConnection; const Clave: TClaveDocumento;
  Lista: TList<TEventoDoc>);
var
  Q: TFDQuery;
  E: TEventoDoc;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT P.FPrestamo, P.FDevolucion, P.Prestamista, P.Responsable ' +
      'FROM TB_PrestamosDocumentos D INNER JOIN TB_Prestamos P ON ' +
      'P.IdEstructura = D.IdEstructura AND P.id = D.id AND P.IdPrestamo = D.IdPrestamo ' +
      'WHERE D.IdEstructura = :est AND D.id = :id AND D.codsubs = :cs AND ' +
      'D.Codigodoc = :cod';
    Q.ParamByName('est').AsString := Clave.IdEstructura;
    Q.ParamByName('id').AsInteger := Clave.Id;
    Q.ParamByName('cs').AsString := Clave.CodSubs;
    Q.ParamByName('cod').AsString := Clave.Codigodoc;
    Q.Open;
    while not Q.Eof do
    begin
      E := Default(TEventoDoc);
      E.Usuario := Q.FieldByName('Responsable').AsString;
      E.Detalle := Q.FieldByName('Prestamista').AsString;
      if not Q.FieldByName('FPrestamo').IsNull then
      begin
        E.Fecha := Q.FieldByName('FPrestamo').AsDateTime;
        E.Tipo := tePrestado;
        Lista.Add(E);
      end;
      if not Q.FieldByName('FDevolucion').IsNull then
      begin
        E.Fecha := Q.FieldByName('FDevolucion').AsDateTime;
        E.Tipo := teDevuelto;
        Lista.Add(E);
      end;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function CargarLineaTiempo(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Clave: TClaveDocumento; Maximo: Integer;
  out HayMas: Boolean): TArray<TEventoDoc>;
var
  Lista: TList<TEventoDoc>;
begin
  HayMas := False;
  Result := nil;
  Lista := TList<TEventoDoc>.Create;
  try
    try
      if not EnAlcance(Conn, Alcance, Clave) then
        Exit;
    except
      on EFDDBEngineException do
        Exit;
    end;
    try
      LeerLog(Conn, Clave, Lista);
    except
      on EFDDBEngineException do ; // tb_log sin las columnas de la F5
    end;
    try
      LeerPrestamos(Conn, Clave, Lista);
    except
      on EFDDBEngineException do ;
    end;
    Result := Lista.ToArray;
    OrdenarYLimitar(Result, Maximo, HayMas);
  finally
    Lista.Free;
  end;
end;

end.
