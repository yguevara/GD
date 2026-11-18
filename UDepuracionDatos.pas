unit UDepuracionDatos;

{ ---------------------------------------------------------------------------
  Datos de la depuracion (eliminacion de documentos, F4), sobre la base comun de
  procesos (UProcesosDatos, tablas prc_*). Sin VCL ni TUDM (RTL + FireDAC).

  Pasos: 1 propuesta, 2 autorizacion, 3 acta, 4 ejecucion, 5 cierre. Los
  documentos NO se borran: pasan a estar "eliminados" (UEliminados) cuando la
  depuracion se ejecuta.

  Propuesta: documentos que estan en un archivo Central o Historico, de
  subseries con destino "Eliminarlo" (cl_destino 3) y plazo vencido en el
  central (UDepuracionReglas.PlazoCentralVencido). Se retienen en prc_bloqueo
  al agregarlos (un documento, un proceso).
  Diseno: docs/superpowers/specs/2026-11-18-depuracion-f4-design.md.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance, UProceso, UProcesosDatos,
  UDepuracionReglas;

type
  { Documentos de una subserie en un nodo, listos para proponer o ya agregados. }
  TGrupoDepuracion = record
    IdEstructura: string;
    IdNodo: Integer;
    CodSubs, Serie, Subserie: string;
    AniosGestion, AniosCentral: Integer;
    Unidades: Integer;            // disponibles para depurar
    Retenidos: Integer;           // vencidos pero retenidos por otro proceso o prestamo
    Desde, Hasta: TDateTime;      // fechas extremas
  end;

  TDepuracionFila = record
    IdProceso, Anio, Consecutivo, Paso: Integer;
    Numero, Series, Estado: string;
    Autorizacion: string;                               // 'Comision Prov. - Acta 14 - Acuerdo 9' o ''
    Unidades: Integer;
    Desde, Hasta, FPrevista, FEjecucion: TDateTime;     // 0 = sin fecha
    Proceso: TEstadoProceso;
    Nodo: TClaveNodo;
  end;

  TAnioCantidad = record
    Anio, Unidades: Integer;
  end;

  { Datos del acta de eliminacion (Anexo 19) que se escriben en el paso 3. }
  TActaDepuracion = record
    Lugar: string;
    Via: TViaEliminacion;
    FPrevista: TDateTime;
    MuestraDesc, MuestraDonde: string;
  end;

  TTestigoFila = record
    IdTestigo: Integer;
    Nombre, Cargo: string;
    Origen: TOrigenTestigo;
    Firmo: Boolean;
  end;

{ Condicion de plazo vencido en el central (alias H, parametros :corteT y :corteF):
  con cierre de transferencia finalizada, P.Cerrado <= :corteT; sin cierre, la fecha
  base (FechaFin si existe y no es anterior a Fecha) <= :corteF. }
function SqlCondicionVencidoCentral: string;

{ Grupos de documentos depurables del nodo (una subserie cada uno). }
function ProponerDepuracion(Conn: TFDConnection; const Nodo: TClaveNodo;
  Hoy: TDateTime): TArray<TGrupoDepuracion>;

{ Crea la depuracion (paso 1) y su fila de datos propios (prc_depuracion). }
function CrearDepuracion(Conn: TFDConnection; const Nodo: TClaveNodo;
  const Usuario: string; Anio: Integer): TProcesoRef;

{ Agrega al proceso (en paso 1) los documentos vencidos y libres del grupo y los
  retiene. False con Motivo si no se agrego ninguno o si otro usuario se los llevo
  a la vez. }
function AgregarGrupoDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const G: TGrupoDepuracion; Hoy: TDateTime; out Agregados: Integer;
  out Motivo: string): Boolean;

{ Quita del proceso (hasta el paso 3) los documentos de un nodo y subserie y los
  libera. }
procedure QuitarGrupoDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const IdEstructura: string; IdNodo: Integer; const CodSubs: string);

{ Lo agregado a la depuracion por subserie (una consulta). }
function GruposDeLaDepuracion(Conn: TFDConnection;
  IdProceso: Integer): TArray<TGrupoDepuracion>;

{ Unidades de la depuracion por ano de la fecha del documento, ascendente. }
function DesglosePorAnio(Conn: TFDConnection; IdProceso: Integer): TArray<TAnioCantidad>;

{ Depuraciones de los nodos en el ano, la mas reciente primero (Limite <= 0 usa
  un tope por defecto). }
function ListarDepuraciones(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Anio, Limite: Integer): TArray<TDepuracionFila>;

{ Guarda el acta (lugar, via, fecha prevista y muestra). Lanza EArgumentException si
  los datos no son validos (ValidarActaDepuracion, ValidarMuestra) o si la depuracion
  no esta en curso en los pasos 1 a 3. }
procedure GuardarActaDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const A: TActaDepuracion);

{ False si la depuracion no tiene fila de acta. Un acta sin guardar vuelve con los
  textos vacios y la fecha en 0. }
function LeerActaDepuracion(Conn: TFDConnection; IdProceso: Integer;
  out A: TActaDepuracion): Boolean;

{ Agrega un testigo y devuelve su id. Lanza EArgumentException si no es valido
  (ValidarTestigo) o si la depuracion ya no esta en curso antes de la ejecucion
  (pasos 1 a 4). }
function AgregarTestigo(Conn: TFDConnection; IdProceso: Integer;
  const T: TTestigoDatos): Integer;
{ Estos dos no hacen nada si la depuracion ya no esta en curso (pasos 1 a 4). }
procedure QuitarTestigo(Conn: TFDConnection; IdProceso, IdTestigo: Integer);
procedure MarcarFirma(Conn: TFDConnection; IdProceso, IdTestigo: Integer; Firmo: Boolean);
function TestigosDeLaDepuracion(Conn: TFDConnection;
  IdProceso: Integer): TArray<TTestigoFila>;

{ Condiciones que se cumplen hoy; Faltan trae las frases de lo que impide avanzar
  desde el paso actual (UDepuracionReglas.TextosQueFaltanDepuracion).
  cdSinBloqueos: hay unidades y todas siguen retenidas por esta depuracion;
  cdAutorizado: hay acta y acuerdo de la Comision; cdMuestraDefinida: descripcion y
  donde queda; cdTestigosMinimos: TestigosSuficientes; cdActaCompleta: lugar, via y
  fecha prevista. cdConfirmacionEscrita no se evalua aqui (lo hace la ejecucion). }
function CondicionesCumplidasDepuracion(Conn: TFDConnection; IdProceso: Integer;
  out Faltan: TArray<string>): TCondiciones;

{ Avanza de los pasos 1 a 3 si se cumplen sus condiciones; si no, False y Faltan dice
  que falta. PasoLeido es el paso que el usuario vio; con otro paso (o un proceso
  que ya no esta en ese paso) devuelve False sin cambiar nada. Los pasos 4 y 5 no
  se avanzan con esta funcion. }
function AvanzarDepuracion(Conn: TFDConnection; IdProceso, PasoLeido: Integer;
  const Usuario: string; out Faltan: TArray<string>): Boolean;

{ Paso 4 -> 5. False si ya no esta en el paso 4 (por ejemplo, otro usuario la ejecuto
  antes). Lanza EArgumentException, sin cambiar nada, si Confirmacion no es la
  palabra ELIMINAR, si alguna unidad ya no esta retenida por esta depuracion, esta en
  un prestamo viejo abierto o su documento ya no esta en un archivo Central o
  Historico. En UNA transaccion: avanza el paso, guarda la fecha de ejecucion y deja
  un evento con el acta. NO modifica tb_SeriesDatos: desde el paso 5 los documentos
  cuentan como eliminados (UEliminados). }
function EjecutarDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const Usuario, Confirmacion: string; Hoy: TDateTime): Boolean;

{ Paso 5 -> finalizada (libera los candados). False si no esta en el paso 5. }
function CerrarDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const Usuario: string): Boolean;

implementation

uses
  System.Generics.Collections, System.Generics.Defaults, System.Variants, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Param, FireDAC.Stan.Error, UTransferenciasReglas,
  UTransferenciasDatos, UAutorizacion, UEliminados;

const
  NODOS_POR_CONSULTA = 200;
  LIMITE_POR_DEFECTO = 500;
  DESTINO_ELIMINAR = 3;   // cl_destino.IdDestino de "Eliminarlo (E)"

{ ----------------------------- apoyo de consultas ----------------------------- }

function CondicionNodos(const ColEstructura, ColId: string; Desde, Hasta: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := Desde to Hasta do
  begin
    if Result <> '' then
      Result := Result + ' OR ';
    Result := Result + '(' + ColEstructura + ' = :qe' + IntToStr(I - Desde) + ' AND ' +
      ColId + ' = :qi' + IntToStr(I - Desde) + ')';
  end;
end;

procedure PonerNodos(Q: TFDQuery; const Nodos: TArray<TClaveNodo>; Desde, Hasta: Integer);
var
  I: Integer;
begin
  for I := Desde to Hasta do
  begin
    Q.ParamByName('qe' + IntToStr(I - Desde)).AsString := Nodos[I].IdEstructura;
    Q.ParamByName('qi' + IntToStr(I - Desde)).AsInteger := Nodos[I].Id;
  end;
end;

function FechaODefecto(Campo: TField): TDateTime;
begin
  if Campo.IsNull then
    Result := 0
  else
    Result := Campo.AsDateTime;
end;

{ Codigos de los archivos (cl_ArchivosGestion) de tipo Central o Historico. }
function CodigosArchivoCentral(Conn: TFDConnection): TArray<Integer>;
var
  Q: TFDQuery;
  L: TList<Integer>;
  Tipo: TTipoArchivo;
begin
  L := TList<Integer>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.Open('SELECT A.Cod AS Cod, T.tipoarch AS Tipo FROM cl_ArchivosGestion A ' +
      'INNER JOIN cl_tipoarch T ON T.Idtipoarch = A.Tipo');
    while not Q.Eof do
    begin
      Tipo := TipoArchivoDesdeTexto(Q.FieldByName('Tipo').AsString);
      if Tipo in [taCentral, taHistorico] then
        L.Add(Q.FieldByName('Cod').AsInteger);
      Q.Next;
    end;
    Result := L.ToArray;
  finally
    Q.Free;
    L.Free;
  end;
end;

{ Documento retenido por otro proceso (prc_bloqueo) o por un prestamo viejo abierto
  (alias H). }
function SqlRetenido: string;
begin
  Result := '(EXISTS (SELECT 1 FROM prc_bloqueo B WHERE B.IdEstructura = H.IdEstructura ' +
    'AND B.id = H.id AND B.codsubs = H.codsubs AND B.Codigodoc = H.Codigodoc AND ' +
    'B.fecha = H.fecha AND B.version = H.version) OR EXISTS (SELECT 1 FROM ' +
    'TB_PrestamosDocumentos D INNER JOIN TB_Prestamos Pr ON Pr.IdEstructura = ' +
    'D.IdEstructura AND Pr.id = D.id AND Pr.IdPrestamo = D.IdPrestamo WHERE ' +
    'Pr.FDevolucion IS NULL AND Pr.FCancelacion IS NULL AND D.IdEstructura = ' +
    'H.IdEstructura AND D.id = H.id AND D.codsubs = H.codsubs AND D.Codigodoc = ' +
    'H.Codigodoc AND D.fecha = H.fecha AND D.version = H.version))';
end;

function SqlCondicionVencidoCentral: string;
const
  CLAVE = 'X.IdEstructura = H.IdEstructura AND X.id = H.id AND X.codsubs = H.codsubs ' +
    'AND X.Codigodoc = H.Codigodoc AND X.fecha = H.fecha AND X.version = H.version';
  CIERRES = 'SELECT 1 FROM prc_unidad X INNER JOIN prc_proceso P ON P.IdProceso = ' +
    'X.IdProceso WHERE P.Tipo = ''T'' AND P.Estado = ''F'' AND P.Cerrado IS NOT NULL ' +
    'AND X.Activa <> 0 AND ' + CLAVE;
begin
  Result := '(EXISTS (' + CIERRES + ' AND P.Cerrado <= :corteT) OR (NOT EXISTS (' +
    CIERRES + ') AND ((H.FechaFin IS NOT NULL AND H.FechaFin >= H.Fecha AND ' +
    'H.FechaFin <= :corteF) OR ((H.FechaFin IS NULL OR H.FechaFin < H.Fecha) AND ' +
    'H.Fecha <= :corteF))))';
end;

procedure PonerCortes(Q: TFDQuery; Hoy: TDateTime; AniosGestion, AniosCentral: Integer);
begin
  if AniosGestion < 0 then
    AniosGestion := 0;
  Q.ParamByName('corteT').AsDateTime := FechaCorte(Hoy, AniosCentral);
  Q.ParamByName('corteF').AsDateTime := FechaCorte(Hoy, AniosGestion + AniosCentral);
end;

{ -------------------------------- propuesta -------------------------------- }

function ProponerDepuracion(Conn: TFDConnection; const Nodo: TClaveNodo;
  Hoy: TDateTime): TArray<TGrupoDepuracion>;
var
  Lista, Subs: TList<TGrupoDepuracion>;
  Centrales: TArray<Integer>;
  G: TGrupoDepuracion;
  Q: TFDQuery;
  I, Total, Ret: Integer;

  { Cuenta (y fechas extremas) los documentos vencidos del grupo; SoloRetenidos
    cuenta solo los que ya retiene otro proceso o un prestamo. }
  procedure Contar(var Gr: TGrupoDepuracion; SoloRetenidos: Boolean; out N: Integer);
  var
    Sql: string;
  begin
    Sql := 'SELECT COUNT(*) AS N, MIN(H.Fecha) AS Desde, MAX(H.Fecha) AS Hasta ' +
      'FROM tb_SeriesDatos H WHERE H.IdEstructura = :e AND H.id = :i AND H.codsubs = :s ' +
      'AND ' + SqlArchivosGestion(Centrales) + ' AND ' + SqlCondicionVencidoCentral +
      ' AND ' + SqlNoEliminado;
    if SoloRetenidos then
      Sql := Sql + ' AND ' + SqlRetenido;
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := Sql;
      Q.ParamByName('e').AsString := Gr.IdEstructura;
      Q.ParamByName('i').AsInteger := Gr.IdNodo;
      Q.ParamByName('s').AsString := Gr.CodSubs;
      PonerCortes(Q, Hoy, Gr.AniosGestion, Gr.AniosCentral);
      Q.Open;
      N := Q.FieldByName('N').AsInteger;
      if not SoloRetenidos then
      begin
        Gr.Desde := FechaODefecto(Q.FieldByName('Desde'));
        Gr.Hasta := FechaODefecto(Q.FieldByName('Hasta'));
      end;
    finally
      Q.Free;
    end;
  end;

begin
  Result := nil;
  Centrales := CodigosArchivoCentral(Conn);
  if Length(Centrales) = 0 then
    Exit;
  Lista := TList<TGrupoDepuracion>.Create;
  Subs := TList<TGrupoDepuracion>.Create;
  try
    // 1) subseries del nodo con destino "Eliminarlo" y plazo en el central definido
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := 'SELECT S.IdEstructura, S.id, S.codsubs, C.subserie, C.tgestion, ' +
        'C.tcentral, R.serie FROM (tb_Serietree S INNER JOIN cl_subseries C ON ' +
        'C.codsubs = S.codsubs) INNER JOIN cl_series R ON R.codserie = C.codserie ' +
        'WHERE S.IdEstructura = :e AND S.id = :i AND C.destino = ' +
        IntToStr(DESTINO_ELIMINAR) + ' AND C.tcentral > 0 ORDER BY R.serie, C.subserie';
      Q.ParamByName('e').AsString := Nodo.IdEstructura;
      Q.ParamByName('i').AsInteger := Nodo.Id;
      Q.Open;
      while not Q.Eof do
      begin
        G.IdEstructura := Q.FieldByName('IdEstructura').AsString;
        G.IdNodo := Q.FieldByName('id').AsInteger;
        G.CodSubs := Q.FieldByName('codsubs').AsString;
        G.Subserie := Q.FieldByName('subserie').AsString;
        G.Serie := Q.FieldByName('serie').AsString;
        G.AniosGestion := Q.FieldByName('tgestion').AsInteger;
        G.AniosCentral := Q.FieldByName('tcentral').AsInteger;
        G.Unidades := 0;
        G.Retenidos := 0;
        G.Desde := 0;
        G.Hasta := 0;
        Subs.Add(G);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    // 2) por cada una, cuantos documentos vencieron y cuantos estan retenidos
    for I := 0 to Subs.Count - 1 do
    begin
      G := Subs[I];
      Contar(G, False, Total);
      if Total = 0 then
        Continue;
      Contar(G, True, Ret);
      G.Retenidos := Ret;
      G.Unidades := Total - Ret;
      Lista.Add(G);
    end;
    Result := Lista.ToArray;
  finally
    Subs.Free;
    Lista.Free;
  end;
end;

{ ------------------------------- escritura ------------------------------- }

function CrearDepuracion(Conn: TFDConnection; const Nodo: TClaveNodo;
  const Usuario: string; Anio: Integer): TProcesoRef;
var
  Intento: Integer;
  Propia: Boolean;
begin
  Result.IdProceso := 0;
  Result.Numero := '';
  for Intento := 1 to 3 do
  begin
    Propia := IniciarTx(Conn);
    try
      Result := CrearProceso(Conn, tpDepuracion, Nodo, Usuario, Anio);
      Conn.ExecSQL('INSERT INTO prc_depuracion (IdProceso) VALUES (:i)',
        [Result.IdProceso], [ftInteger]);
      ConfirmarTx(Conn, Propia);
      Exit;
    except
      on E: EFDDBEngineException do
      begin
        DeshacerTx(Conn, Propia);
        if (Intento >= 3) or (not Propia) or (E.Kind <> ekUKViolated) then
          raise;
      end;
      on Exception do
      begin
        DeshacerTx(Conn, Propia);
        raise;
      end;
    end;
  end;
end;

function AgregarGrupoDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const G: TGrupoDepuracion; Hoy: TDateTime; out Agregados: Integer;
  out Motivo: string): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Centrales: TArray<Integer>;
  Propia: Boolean;
  Filtro, Clave, P: string;
  Q: TFDQuery;
  AniosGestion, AniosCentral: Integer;
begin
  Agregados := 0;
  Motivo := '';
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpDepuracion) then
    raise EArgumentException.Create('La depuracion no existe: ' + IntToStr(IdProceso));
  if (Estado <> 'C') or (Paso <> 1) then
  begin
    Motivo := 'Solo se pueden agregar documentos en el paso de propuesta';
    Exit;
  end;
  // el nodo, el destino y el plazo salen de la base, no del registro que trae el llamador
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT IdEstructura, IdNodo FROM prc_proceso WHERE IdProceso = :p';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    if Q.IsEmpty or (Q.FieldByName('IdEstructura').AsString <> G.IdEstructura) or
      (Q.FieldByName('IdNodo').AsInteger <> G.IdNodo) then
    begin
      Motivo := 'El grupo no pertenece al nodo de esta depuraci' + #243 + 'n';
      Exit;
    end;
    Q.Close;
    Q.SQL.Text := 'SELECT tgestion, tcentral, destino FROM cl_subseries WHERE codsubs = :s';
    Q.ParamByName('s').AsString := G.CodSubs;
    Q.Open;
    if Q.IsEmpty or (Q.FieldByName('destino').AsInteger <> DESTINO_ELIMINAR) or
      (Q.FieldByName('tcentral').AsInteger <= 0) then
    begin
      Motivo := 'La subserie ya no tiene destino Eliminarlo o plazo definido en el archivo central';
      Exit;
    end;
    AniosGestion := Q.FieldByName('tgestion').AsInteger;
    AniosCentral := Q.FieldByName('tcentral').AsInteger;
  finally
    Q.Free;
  end;
  Centrales := CodigosArchivoCentral(Conn);
  P := IntToStr(IdProceso);
  Filtro := 'H.IdEstructura = :e AND H.id = :i AND H.codsubs = :s AND ' +
    SqlArchivosGestion(Centrales) + ' AND ' + SqlCondicionVencidoCentral + ' AND ' +
    SqlNoEliminado + ' AND NOT ' + SqlRetenido;
  Clave := 'B.IdProceso = ' + P + ' AND B.IdEstructura = :e AND B.id = :i AND B.codsubs = :s';
  Propia := IniciarTx(Conn);
  try
    try
      Q := TFDQuery.Create(nil);
      try
        Q.Connection := Conn;
        Q.SQL.Text := 'INSERT INTO prc_bloqueo (IdEstructura, id, codsubs, Codigodoc, ' +
          'fecha, version, IdProceso) SELECT H.IdEstructura, H.id, H.codsubs, ' +
          'H.Codigodoc, H.fecha, H.version, ' + P + ' FROM tb_SeriesDatos H WHERE ' + Filtro;
        Q.ParamByName('e').AsString := G.IdEstructura;
        Q.ParamByName('i').AsInteger := G.IdNodo;
        Q.ParamByName('s').AsString := G.CodSubs;
        PonerCortes(Q, Hoy, AniosGestion, AniosCentral);
        Q.ExecSQL;
        Agregados := Q.RowsAffected;
      finally
        Q.Free;
      end;
      if Agregados > 0 then
      begin
        Conn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, ' +
          'Codigodoc, fecha, version) SELECT B.IdProceso, B.IdEstructura, B.id, B.codsubs, ' +
          'B.Codigodoc, B.fecha, B.version FROM prc_bloqueo B WHERE ' + Clave +
          ' AND NOT EXISTS (SELECT 1 FROM prc_unidad U WHERE U.IdProceso = B.IdProceso ' +
          'AND U.IdEstructura = B.IdEstructura AND U.id = B.id AND U.codsubs = B.codsubs ' +
          'AND U.Codigodoc = B.Codigodoc AND U.fecha = B.fecha AND U.version = B.version)',
          [G.IdEstructura, G.IdNodo, G.CodSubs]);
        // Access no tiene valor por defecto en el bit: se marca activa explicitamente
        Conn.ExecSQL('UPDATE prc_unidad SET Activa = :a WHERE IdProceso = ' + P +
          ' AND Activa IS NULL', [True], [ftBoolean]);
      end;
      ConfirmarTx(Conn, Propia);
      Result := Agregados > 0;
      if not Result then
        Motivo := 'No hay documentos disponibles en este grupo (ya est' + #225 +
          'n retenidos, prestados o eliminados)';
    except
      on E: EFDDBEngineException do
      begin
        DeshacerTx(Conn, Propia);
        Agregados := 0;
        if E.Kind <> ekUKViolated then
          raise;
        Motivo := 'Otro usuario tom' + #243 + ' algunos de estos documentos a la vez; ' +
          'vuelva a proponer';
      end;
      on Exception do
      begin
        DeshacerTx(Conn, Propia);
        raise;
      end;
    end;
  except
    raise;
  end;
end;

procedure QuitarGrupoDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const IdEstructura: string; IdNodo: Integer; const CodSubs: string);
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Propia: Boolean;
begin
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpDepuracion) or
    (Estado <> 'C') or (Paso > 3) then
    Exit;
  Propia := IniciarTx(Conn);
  try
    Conn.ExecSQL('DELETE FROM prc_bloqueo WHERE IdProceso = :p AND IdEstructura = :e ' +
      'AND id = :i AND codsubs = :s', [IdProceso, IdEstructura, IdNodo, CodSubs]);
    Conn.ExecSQL('DELETE FROM prc_unidad WHERE IdProceso = :p AND IdEstructura = :e ' +
      'AND id = :i AND codsubs = :s', [IdProceso, IdEstructura, IdNodo, CodSubs]);
    ConfirmarTx(Conn, Propia);
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

{ -------------------------------- listados -------------------------------- }

function OrganoDesdeCodigo(const Codigo: string): TOrganoComision;
begin
  if Trim(Codigo) = 'M' then
    Result := ocMunicipal
  else if Trim(Codigo) = 'P' then
    Result := ocProvincial
  else if Trim(Codigo) = 'N' then
    Result := ocNacional
  else
    Result := ocCentral;
end;

function GruposDeLaDepuracion(Conn: TFDConnection;
  IdProceso: Integer): TArray<TGrupoDepuracion>;
var
  Q: TFDQuery;
  L: TList<TGrupoDepuracion>;
  G: TGrupoDepuracion;
begin
  L := TList<TGrupoDepuracion>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT u.IdEstructura AS Ie, u.id AS Id, u.codsubs AS Cs, ' +
      'C.subserie AS Sub, R.serie AS Ser, C.tgestion AS Tg, C.tcentral AS Tc, ' +
      'COUNT(*) AS N, MIN(u.fecha) AS Desde, MAX(u.fecha) AS Hasta ' +
      'FROM (prc_unidad u LEFT JOIN cl_subseries C ON C.codsubs = u.codsubs) ' +
      'LEFT JOIN cl_series R ON R.codserie = C.codserie ' +
      'WHERE u.IdProceso = :p AND u.Activa <> 0 GROUP BY u.IdEstructura, u.id, ' +
      'u.codsubs, C.subserie, R.serie, C.tgestion, C.tcentral ORDER BY R.serie, C.subserie';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    while not Q.Eof do
    begin
      G.IdEstructura := Q.FieldByName('Ie').AsString;
      G.IdNodo := Q.FieldByName('Id').AsInteger;
      G.CodSubs := Q.FieldByName('Cs').AsString;
      G.Subserie := Q.FieldByName('Sub').AsString;
      G.Serie := Q.FieldByName('Ser').AsString;
      G.AniosGestion := Q.FieldByName('Tg').AsInteger;
      G.AniosCentral := Q.FieldByName('Tc').AsInteger;
      G.Unidades := Q.FieldByName('N').AsInteger;
      G.Retenidos := 0;
      G.Desde := FechaODefecto(Q.FieldByName('Desde'));
      G.Hasta := FechaODefecto(Q.FieldByName('Hasta'));
      L.Add(G);
      Q.Next;
    end;
    Result := L.ToArray;
  finally
    Q.Free;
    L.Free;
  end;
end;

function DesglosePorAnio(Conn: TFDConnection; IdProceso: Integer): TArray<TAnioCantidad>;
var
  Q: TFDQuery;
  L: TList<TAnioCantidad>;
  A: TAnioCantidad;
begin
  L := TList<TAnioCantidad>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT YEAR(u.fecha) AS Anio, COUNT(*) AS N FROM prc_unidad u ' +
      'WHERE u.IdProceso = :p AND u.Activa <> 0 GROUP BY YEAR(u.fecha) ' +
      'ORDER BY YEAR(u.fecha)';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    while not Q.Eof do
    begin
      A.Anio := Q.FieldByName('Anio').AsInteger;
      A.Unidades := Q.FieldByName('N').AsInteger;
      L.Add(A);
      Q.Next;
    end;
    Result := L.ToArray;
  finally
    Q.Free;
    L.Free;
  end;
end;

function ListarDepuraciones(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Anio, Limite: Integer): TArray<TDepuracionFila>;
var
  Lista: TList<TDepuracionFila>;
  Desde, Hasta, Tope: Integer;
  Q: TFDQuery;
  F: TDepuracionFila;
  Aut: TAutorizacion;
begin
  if Limite <= 0 then
    Tope := LIMITE_POR_DEFECTO
  else
    Tope := Limite;
  Lista := TList<TDepuracionFila>.Create;
  try
    Desde := 0;
    while Desde < Length(Nodos) do
    begin
      Hasta := Desde + NODOS_POR_CONSULTA - 1;
      if Hasta > High(Nodos) then
        Hasta := High(Nodos);
      Q := TFDQuery.Create(nil);
      try
        Q.Connection := Conn;
        Q.SQL.Text := 'SELECT TOP ' + IntToStr(Tope) + ' p.IdProceso, p.Anio, ' +
          'p.IdEstructura, p.IdNodo, p.Consecutivo, p.Numero, p.Estado, p.Paso, ' +
          'd.FPrevista, d.FEjecucion, ' +
          '(SELECT COUNT(*) FROM prc_unidad u WHERE u.IdProceso = p.IdProceso AND u.Activa <> 0) AS Unidades, ' +
          '(SELECT MIN(u.fecha) FROM prc_unidad u WHERE u.IdProceso = p.IdProceso AND u.Activa <> 0) AS Desde, ' +
          '(SELECT MAX(u.fecha) FROM prc_unidad u WHERE u.IdProceso = p.IdProceso AND u.Activa <> 0) AS Hasta, ' +
          '(SELECT MIN(R.serie) FROM (prc_unidad u2 INNER JOIN cl_subseries C ON ' +
          'C.codsubs = u2.codsubs) INNER JOIN cl_series R ON R.codserie = C.codserie ' +
          'WHERE u2.IdProceso = p.IdProceso AND u2.Activa <> 0) AS Series, ' +
          'a.Organo, a.NumActa, a.NumAcuerdo ' +
          'FROM ((prc_proceso p INNER JOIN prc_depuracion d ON d.IdProceso = p.IdProceso) ' +
          'LEFT JOIN prc_autorizacion a ON a.IdProceso = p.IdProceso) ' +
          'WHERE p.Tipo = ''D'' AND p.Anio = :a AND (' +
          CondicionNodos('p.IdEstructura', 'p.IdNodo', Desde, Hasta) + ') ' +
          'ORDER BY p.Consecutivo DESC';
        Q.ParamByName('a').AsInteger := Anio;
        PonerNodos(Q, Nodos, Desde, Hasta);
        Q.Open;
        while not Q.Eof do
        begin
          F.IdProceso := Q.FieldByName('IdProceso').AsInteger;
          F.Anio := Q.FieldByName('Anio').AsInteger;
          F.Consecutivo := Q.FieldByName('Consecutivo').AsInteger;
          F.Numero := Trim(Q.FieldByName('Numero').AsString);
          F.Series := Q.FieldByName('Series').AsString;
          F.Autorizacion := '';
          if not Q.FieldByName('NumActa').IsNull then
          begin
            Aut.Organo := OrganoDesdeCodigo(Q.FieldByName('Organo').AsString);
            Aut.NumActa := Q.FieldByName('NumActa').AsString;
            Aut.NumAcuerdo := Q.FieldByName('NumAcuerdo').AsString;
            Aut.Fecha := 0;
            F.Autorizacion := TextoAutorizacionCorto(Aut);
          end;
          F.Nodo.IdEstructura := Q.FieldByName('IdEstructura').AsString;
          F.Nodo.Id := Q.FieldByName('IdNodo').AsInteger;
          F.Paso := Q.FieldByName('Paso').AsInteger;
          F.Proceso := EstadoDesdeCodigo(Q.FieldByName('Estado').AsString);
          F.Estado := TextoEstadoDepuracion(F.Paso, F.Proceso);
          F.Unidades := Q.FieldByName('Unidades').AsInteger;
          F.Desde := FechaODefecto(Q.FieldByName('Desde'));
          F.Hasta := FechaODefecto(Q.FieldByName('Hasta'));
          F.FPrevista := FechaODefecto(Q.FieldByName('FPrevista'));
          F.FEjecucion := FechaODefecto(Q.FieldByName('FEjecucion'));
          Lista.Add(F);
          Q.Next;
        end;
      finally
        Q.Free;
      end;
      Desde := Hasta + 1;
    end;
    Lista.Sort(TComparer<TDepuracionFila>.Construct(
      function(const A, B: TDepuracionFila): Integer
      begin
        Result := B.Consecutivo - A.Consecutivo;
      end));
    if Lista.Count > Tope then
      Lista.Count := Tope;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

{ ---------------------- acta, testigos y condiciones ---------------------- }

{ Exige una depuracion en curso hasta el paso PasoMax. }
procedure ExigirEnCurso(Conn: TFDConnection; IdProceso, PasoMax: Integer;
  const Mensaje: string);
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
begin
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpDepuracion) or
    (Estado <> 'C') or (Paso > PasoMax) then
    raise EArgumentException.Create(Mensaje);
end;

function EnCursoHasta(Conn: TFDConnection; IdProceso, PasoMax: Integer): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
begin
  Result := LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) and (Tipo = tpDepuracion) and
    (Estado = 'C') and (Paso <= PasoMax);
end;

procedure GuardarActaDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const A: TActaDepuracion);
var
  Errores: TArray<string>;
begin
  Errores := ValidarActaDepuracion(A.Lugar, A.FPrevista);
  if Length(Errores) = 0 then
    Errores := ValidarMuestra(A.MuestraDesc, A.MuestraDonde);
  if Length(Errores) > 0 then
    raise EArgumentException.Create(Errores[0]);
  ExigirEnCurso(Conn, IdProceso, 3, 'El acta solo se puede cambiar antes de la ' +
    'ejecuci' + #243 + 'n (pasos 1 a 3).');
  Conn.ExecSQL('UPDATE prc_depuracion SET Lugar = :l, Via = :v, FPrevista = :f, ' +
    'MuestraDesc = :d, MuestraDonde = :m WHERE IdProceso = :p',
    [Trim(A.Lugar), CodigoVia(A.Via), Trunc(A.FPrevista), Trim(A.MuestraDesc),
    Trim(A.MuestraDonde), IdProceso],
    [ftString, ftString, ftDateTime, ftString, ftString, ftInteger]);
end;

function LeerActaDepuracion(Conn: TFDConnection; IdProceso: Integer;
  out A: TActaDepuracion): Boolean;
var
  Q: TFDQuery;
begin
  A.Lugar := '';
  A.Via := veIncineracion;
  A.FPrevista := 0;
  A.MuestraDesc := '';
  A.MuestraDonde := '';
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT Lugar, Via, FPrevista, MuestraDesc, MuestraDonde FROM ' +
      'prc_depuracion WHERE IdProceso = :p';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    Result := not Q.IsEmpty;
    if not Result then
      Exit;
    A.Lugar := Q.FieldByName('Lugar').AsString;
    if not Q.FieldByName('Via').IsNull then
      A.Via := ViaDesdeCodigo(Q.FieldByName('Via').AsString);
    A.FPrevista := FechaODefecto(Q.FieldByName('FPrevista'));
    A.MuestraDesc := Q.FieldByName('MuestraDesc').AsString;
    A.MuestraDonde := Q.FieldByName('MuestraDonde').AsString;
  finally
    Q.Free;
  end;
end;

function AgregarTestigo(Conn: TFDConnection; IdProceso: Integer;
  const T: TTestigoDatos): Integer;
var
  Errores: TArray<string>;
  Propia: Boolean;
begin
  Errores := ValidarTestigo(T);
  if Length(Errores) > 0 then
    raise EArgumentException.Create(Errores[0]);
  ExigirEnCurso(Conn, IdProceso, 4, 'Ya no se pueden agregar testigos: la depuraci' + #243 +
    'n no est' + #225 + ' en curso antes de la ejecuci' + #243 + 'n.');
  Propia := IniciarTx(Conn);
  try
    Conn.ExecSQL('INSERT INTO prc_testigo (IdProceso, Nombre, Cargo, Origen, Firmo) ' +
      'VALUES (:p, :n, :c, :o, :f)', [IdProceso, Copy(Trim(T.Nombre), 1, 100),
      Copy(Trim(T.Cargo), 1, 100), CodigoOrigenTestigo(T.Origen), False],
      [ftInteger, ftString, ftString, ftString, ftBoolean]);
    Result := Integer(Conn.ExecSQLScalar('SELECT MAX(IdTestigo) FROM prc_testigo WHERE ' +
      'IdProceso = :p', [IdProceso]));
    ConfirmarTx(Conn, Propia);
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

procedure QuitarTestigo(Conn: TFDConnection; IdProceso, IdTestigo: Integer);
begin
  if not EnCursoHasta(Conn, IdProceso, 4) then
    Exit;
  Conn.ExecSQL('DELETE FROM prc_testigo WHERE IdProceso = :p AND IdTestigo = :t',
    [IdProceso, IdTestigo], [ftInteger, ftInteger]);
end;

procedure MarcarFirma(Conn: TFDConnection; IdProceso, IdTestigo: Integer; Firmo: Boolean);
begin
  if not EnCursoHasta(Conn, IdProceso, 4) then
    Exit;
  Conn.ExecSQL('UPDATE prc_testigo SET Firmo = :f WHERE IdProceso = :p AND IdTestigo = :t',
    [Firmo, IdProceso, IdTestigo], [ftBoolean, ftInteger, ftInteger]);
end;

function TestigosDeLaDepuracion(Conn: TFDConnection;
  IdProceso: Integer): TArray<TTestigoFila>;
var
  Q: TFDQuery;
  L: TList<TTestigoFila>;
  F: TTestigoFila;
begin
  L := TList<TTestigoFila>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT IdTestigo, Nombre, Cargo, Origen, Firmo FROM prc_testigo ' +
      'WHERE IdProceso = :p ORDER BY IdTestigo';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    while not Q.Eof do
    begin
      F.IdTestigo := Q.FieldByName('IdTestigo').AsInteger;
      F.Nombre := Q.FieldByName('Nombre').AsString;
      F.Cargo := Q.FieldByName('Cargo').AsString;
      F.Origen := OrigenTestigoDesdeCodigo(Q.FieldByName('Origen').AsString);
      F.Firmo := Q.FieldByName('Firmo').AsBoolean;
      L.Add(F);
      Q.Next;
    end;
    Result := L.ToArray;
  finally
    Q.Free;
    L.Free;
  end;
end;

function CondicionesCumplidasDepuracion(Conn: TFDConnection; IdProceso: Integer;
  out Faltan: TArray<string>): TCondiciones;
var
  Tipo: TTipoProceso;
  Paso, Total, Retenidas, I: Integer;
  Estado: string;
  A: TAutorizacion;
  Q: TFDQuery;
  Testigos: TArray<TTestigoFila>;
  Datos: TArray<TTestigoDatos>;
  HayViaYFecha: Boolean;
begin
  Result := [];
  Faltan := nil;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) then
    Exit;
  // retenidas: todas las unidades activas siguen en prc_bloqueo de esta depuracion
  Total := Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad WHERE ' +
    'IdProceso = :p AND Activa <> 0', [IdProceso]));
  Retenidas := Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad u WHERE ' +
    'u.IdProceso = :p AND u.Activa <> 0 AND EXISTS (SELECT 1 FROM prc_bloqueo B WHERE ' +
    'B.IdProceso = u.IdProceso AND B.IdEstructura = u.IdEstructura AND B.id = u.id AND ' +
    'B.codsubs = u.codsubs AND B.Codigodoc = u.Codigodoc AND B.fecha = u.fecha AND ' +
    'B.version = u.version)', [IdProceso]));
  if (Total > 0) and (Total = Retenidas) then
    Include(Result, cdSinBloqueos);
  if LeerAutorizacion(Conn, IdProceso, A) then
    Include(Result, cdAutorizado);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT Lugar, Via, FPrevista, MuestraDesc, MuestraDonde FROM ' +
      'prc_depuracion WHERE IdProceso = :p';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    if not Q.IsEmpty then
    begin
      if (Trim(Q.FieldByName('MuestraDesc').AsString) <> '') and
        (Trim(Q.FieldByName('MuestraDonde').AsString) <> '') then
        Include(Result, cdMuestraDefinida);
      HayViaYFecha := (not Q.FieldByName('Via').IsNull) and
        (not Q.FieldByName('FPrevista').IsNull);
      if (Trim(Q.FieldByName('Lugar').AsString) <> '') and HayViaYFecha then
        Include(Result, cdActaCompleta);
    end;
  finally
    Q.Free;
  end;
  Testigos := TestigosDeLaDepuracion(Conn, IdProceso);
  SetLength(Datos, Length(Testigos));
  for I := 0 to High(Testigos) do
  begin
    Datos[I].Nombre := Testigos[I].Nombre;
    Datos[I].Cargo := Testigos[I].Cargo;
    Datos[I].Origen := Testigos[I].Origen;
  end;
  if TestigosSuficientes(Datos) then
    Include(Result, cdTestigosMinimos);
  Faltan := TextosQueFaltanDepuracion(CondicionesParaAvanzar(tpDepuracion, Paso) - Result);
end;

function AvanzarDepuracion(Conn: TFDConnection; IdProceso, PasoLeido: Integer;
  const Usuario: string; out Faltan: TArray<string>): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Cumplidas, FaltaCond: TCondiciones;
begin
  Result := False;
  Faltan := nil;
  if (PasoLeido < 1) or (PasoLeido > 3) then
    Exit;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpDepuracion) or
    (Estado <> 'C') or (Paso <> PasoLeido) then
    Exit;
  Cumplidas := CondicionesCumplidasDepuracion(Conn, IdProceso, Faltan);
  Result := AvanzarPaso(Conn, IdProceso, PasoLeido, Cumplidas, Usuario, FaltaCond);
  if Result then
    Faltan := nil
  else
    Faltan := TextosQueFaltanDepuracion(FaltaCond);
end;

{ --------------------------- ejecucion y cierre --------------------------- }

function EjecutarDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const Usuario, Confirmacion: string; Hoy: TDateTime): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Falta: TCondiciones;
  Cumplidas: TCondiciones;
  Textos: TArray<string>;
  Centrales: TArray<Integer>;
  A: TAutorizacion;
  Prestadas, FueraDelCentral: Integer;
  Propia: Boolean;
  Referencia: string;
begin
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpDepuracion) then
    Exit;
  if (Estado <> 'C') or (Paso <> 4) then
    Exit;
  if not ConfirmacionEscritaValida(Confirmacion) then
    raise EArgumentException.Create('Escriba ' + PALABRA_CONFIRMACION + ' para confirmar la ' +
      'eliminaci' + #243 + 'n.');
  Centrales := CodigosArchivoCentral(Conn);
  Propia := IniciarTx(Conn);
  try
    // AvanzarPaso toma el proceso; lo que se revisa despues es lo que se aplica. Las
    // condiciones se pasan como cumplidas y se comprueban a continuacion: si alguna
    // falla se lanza y la transaccion deshace el avance.
    if not AvanzarPaso(Conn, IdProceso, 4, [cdConfirmacionEscrita, cdSinBloqueos], Usuario,
      Falta) then
    begin
      DeshacerTx(Conn, Propia);
      Exit;
    end;
    // todo lo exigido hasta el paso 3 se vuelve a comprobar: los testigos y el acta se
    // pueden cambiar hasta el paso 4 y la autorizacion se puede reescribir
    Cumplidas := CondicionesCumplidasDepuracion(Conn, IdProceso, Textos);
    Falta := [cdSinBloqueos, cdAutorizado, cdMuestraDefinida, cdTestigosMinimos,
      cdActaCompleta] - Cumplidas;
    if Falta <> [] then
    begin
      Textos := TextosQueFaltanDepuracion(Falta);
      raise EArgumentException.Create(Textos[0]);
    end;
    Prestadas := Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad u WHERE ' +
      'u.IdProceso = :p AND u.Activa <> 0 AND EXISTS (SELECT 1 FROM TB_PrestamosDocumentos D ' +
      'INNER JOIN TB_Prestamos Pr ON Pr.IdEstructura = D.IdEstructura AND Pr.id = D.id AND ' +
      'Pr.IdPrestamo = D.IdPrestamo WHERE Pr.FDevolucion IS NULL AND Pr.FCancelacion IS NULL ' +
      'AND D.IdEstructura = u.IdEstructura AND D.id = u.id AND D.codsubs = u.codsubs AND ' +
      'D.Codigodoc = u.Codigodoc AND D.fecha = u.fecha AND D.version = u.version)',
      [IdProceso]));
    if Prestadas > 0 then
      raise EArgumentException.Create(IntToStr(Prestadas) + ' documento(s) est' + #225 +
        'n en un pr' + #233 + 'stamo abierto: no se puede eliminar.');
    FueraDelCentral := Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad u WHERE ' +
      'u.IdProceso = :p AND u.Activa <> 0 AND NOT EXISTS (SELECT 1 FROM tb_SeriesDatos H ' +
      'WHERE H.IdEstructura = u.IdEstructura AND H.id = u.id AND H.codsubs = u.codsubs AND ' +
      'H.Codigodoc = u.Codigodoc AND H.fecha = u.fecha AND H.version = u.version AND ' +
      SqlArchivosGestion(Centrales) + ')', [IdProceso]));
    if FueraDelCentral > 0 then
      raise EArgumentException.Create(IntToStr(FueraDelCentral) + ' documento(s) ya no est' +
        #225 + 'n en un archivo central o hist' + #243 + 'rico (o ya no existen): ' +
        'rev' + #237 + 'selos antes de eliminar.');
    Conn.ExecSQL('UPDATE prc_depuracion SET FEjecucion = :f WHERE IdProceso = :p',
      [Trunc(Hoy), IdProceso], [ftDateTime, ftInteger]);
    Referencia := '';
    if LeerAutorizacion(Conn, IdProceso, A) then
      Referencia := ' (acta ' + A.NumActa + ', acuerdo ' + A.NumAcuerdo + ')';
    RegistrarEvento(Conn, IdProceso, Usuario, 'Eliminaci' + #243 + 'n ejecutada' + Referencia);
    ConfirmarTx(Conn, Propia);
    Result := True;
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

function CerrarDepuracion(Conn: TFDConnection; IdProceso: Integer;
  const Usuario: string): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Falta: TCondiciones;
begin
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpDepuracion) then
    Exit;
  if (Estado <> 'C') or (Paso <> 5) then
    Exit;
  // el ultimo paso finaliza el proceso y libera los candados
  Result := AvanzarPaso(Conn, IdProceso, 5, [], Usuario, Falta);
end;

end.
