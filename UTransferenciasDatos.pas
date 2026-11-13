unit UTransferenciasDatos;

{ ---------------------------------------------------------------------------
  Datos de la transferencia documental (parte del archivo remitente: pasos 1 a 4).
  Solo RTL + FireDAC: sin VCL ni TUDM. SQL valido en SQL Server y Access
  (SELECT TOP n, parametros, sin CASE).

  Una transferencia es un proceso de tipo 'T' (prc_proceso) con sus datos propios
  (prc_transferencia), los documentos que se transfieren (prc_unidad, retenidos por
  prc_bloqueo), las cajas (prc_caja) y las verificaciones (prc_verificacion):

    1 Propuesta -> 2 Comision -> 3 Preparacion -> 4 Entrega -> 5 Recepcion -> 6 Ubicacion

  Esta unidad cubre hasta registrar la entrega (paso 4 a 5); la recepcion es de F3.

  Reglas:
    - se proponen los documentos de archivo de GESTION cuyo plazo (tgestion) vencio;
      sin plazo no se propone nada (UTransferenciasReglas);
    - los documentos que ya retiene otro proceso abierto (un prestamo, otra
      transferencia) no se pueden agregar: la clave de prc_bloqueo lo garantiza;
    - cualquier cambio en los documentos reinicia la numeracion de cajas;
    - no se pasa a "Entrega" sin autorizacion, sin cajas para todos los documentos y
      sin las cinco verificaciones.
  Diseno: docs/superpowers/specs/2026-11-12-prestamos-transferencias-
  depuracion-design.md (seccion 6).
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance, UProceso, UProcesosDatos,
  UAutorizacion, UTransferenciasReglas;

type
  { Documentos vencidos de una subserie en un nodo, listos para proponer. }
  TGrupoPropuesto = record
    IdEstructura: string;
    IdNodo: Integer;
    CodSubs, Serie, Subserie: string;
    Anios: Integer;               // plazo en archivo de gestion
    Unidades: Integer;            // disponibles para transferir
    Retenidos: Integer;           // vencidos pero retenidos por otro proceso abierto
    Desde, Hasta: TDateTime;      // fechas extremas
    Anticipada: Boolean;          // propuesta antes de vencer (o sin plazo)
  end;

  TTransferenciaFila = record
    IdProceso, Anio, Consecutivo, Paso: Integer;
    Numero, Remitente, Estado: string;
    FPrevista, FEntrega: TDateTime;     // 0 = sin fecha
    Cajas, Unidades: Integer;
    Proceso: TEstadoProceso;
    Nodo: TClaveNodo;                   // nodo (area) remitente de la transferencia
  end;

  TCronogramaFila = record
    IdCronograma, Anio: Integer;
    IdEstructura: string;
    IdNodo: Integer;
    Etiqueta: string;
    FPrevista: TDateTime;
    IdProceso: Integer;                 // 0 = aun sin transferencia
    Estado: TEstadoCronograma;
  end;

  { Documentos ya agregados a la transferencia, por nodo y subserie. }
  TGrupoAgregado = record
    IdEstructura: string;
    IdNodo: Integer;
    CodSubs, Serie, Subserie: string;
    Unidades: Integer;
    Desde, Hasta: TDateTime;
  end;

  { Una linea de la Relacion de entrega (Anexo 16): una por caja. }
  TLineaRelacion = record
    Numero: Integer;
    Desde, Hasta: TDateTime;
    Tipo, Descripcion: string;
    Caja, Unidades: Integer;
  end;

{ Condicion de fecha de los documentos vencidos (alias H; parametro :corte). }
function SqlCondicionVencido: string;

{ H.Archivo IN (...) con los archivos de gestion; '1 = 0' si no hay ninguno. }
function SqlArchivosGestion(const Codigos: array of Integer): string;

{ Clave del conjunto que no se parte entre cajas: el expediente (si lo hay, dentro
  de la subserie) o el documento solo. }
function GrupoDeCaja(const CodSubs, IdExpediente, CodigoDoc: string; Fecha: TDateTime;
  const Version: string): string;

{ Frases de lo que impide avanzar. Faltan son las condiciones sin cumplir. }
function TextosQueFaltan(Faltan: TCondiciones; TotalUnidades, SinCaja: Integer;
  const Marcadas: array of string): TArray<string>;

{ Documentos vencidos por (nodo, subserie) de los nodos dados. Una consulta por
  subserie, nunca por documento. Con IncluirNoVencidas se proponen todos los
  documentos de gestion (aunque el plazo no haya vencido o no exista). }
function ProponerTransferencia(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Hoy: TDateTime; IncluirNoVencidas: Boolean = False): TArray<TGrupoPropuesto>;

{ Crea la transferencia (paso 1) con su fecha prevista (0 = sin fecha) y la enlaza
  con el cronograma del nodo y ano si existe. }
function CrearTransferencia(Conn: TFDConnection; const Nodo: TClaveNodo;
  const Usuario: string; Anio: Integer; FPrevista: TDateTime): TProcesoRef;

{ Agrega al proceso (en paso 1) los documentos vencidos y libres del grupo. False
  con Motivo si no se agrego ninguno o si otro usuario se los llevo a la vez. }
function AgregarGrupo(Conn: TFDConnection; IdProceso: Integer; const G: TGrupoPropuesto;
  Hoy: TDateTime; out Agregados: Integer; out Motivo: string): Boolean;

{ Quita del proceso (hasta el paso 3) los documentos de un nodo y subserie y los
  libera. }
procedure QuitarGrupo(Conn: TFDConnection; IdProceso: Integer; const IdEstructura: string;
  IdNodo: Integer; const CodSubs: string);

function ContarUnidades(Conn: TFDConnection; IdProceso: Integer): Integer;

{ Acta y acuerdo registrados para la transferencia; False si no hay. }
function LeerAutorizacion(Conn: TFDConnection; IdProceso: Integer;
  out A: TAutorizacion): Boolean;

{ Lo agregado a la transferencia agrupado por nodo y subserie (una consulta). }
function GruposDeLaTransferencia(Conn: TFDConnection;
  IdProceso: Integer): TArray<TGrupoAgregado>;

{ Reparte los documentos en cajas numeradas desde 1 (RepartirEnCajas) y reconstruye
  prc_caja. Idempotente. }
procedure NumerarCajas(Conn: TFDConnection; IdProceso, Capacidad: Integer);

procedure MarcarVerificacion(Conn: TFDConnection; IdProceso: Integer;
  const Codigo: string; Marcada: Boolean);
function VerificacionesMarcadas(Conn: TFDConnection; IdProceso: Integer): TArray<string>;

{ Condiciones que se cumplen hoy; Faltan trae las frases de todo lo que falta. }
function CondicionesCumplidas(Conn: TFDConnection; IdProceso: Integer;
  out Faltan: TArray<string>): TCondiciones;

{ Avanza del paso 1 al 4 si se cumplen las condiciones de ese paso; si no, False y
  Faltan dice que falta. PasoLeido es el paso que el usuario vio. }
function AvanzarTransferencia(Conn: TFDConnection; IdProceso, PasoLeido: Integer;
  const Usuario: string; out Faltan: TArray<string>): Boolean;

{ Paso 4 -> 5: registra la entrega. False si ya no esta en el paso 4. }
function RegistrarEntregaTransferencia(Conn: TFDConnection; IdProceso: Integer;
  const Usuario, EntregadoPor: string; Fecha: TDateTime): Boolean;

function ListarTransferencias(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Anio, Limite: Integer): TArray<TTransferenciaFila>;

{ Inserta o actualiza la fecha prevista del nodo en el ano. }
procedure ProgramarTransferencia(Conn: TFDConnection; const Nodo: TClaveNodo;
  Anio: Integer; FPrevista: TDateTime);
function ListarCronograma(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Anio: Integer; Hoy: TDateTime): TArray<TCronogramaFila>;

function RelacionDeEntrega(Conn: TFDConnection; IdProceso: Integer): TArray<TLineaRelacion>;

implementation

uses
  System.Generics.Collections, System.Generics.Defaults, System.Variants, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Param, FireDAC.Stan.Error;

const
  NODOS_POR_CONSULTA = 200;
  LIMITE_POR_DEFECTO = 500;

{ -------------------------- reglas puras de SQL -------------------------- }

function SqlCondicionVencido: string;
begin
  Result := '((H.FechaFin IS NOT NULL AND H.FechaFin >= H.Fecha AND H.FechaFin <= :corte) ' +
    'OR ((H.FechaFin IS NULL OR H.FechaFin < H.Fecha) AND H.Fecha <= :corte))';
end;

function SqlArchivosGestion(const Codigos: array of Integer): string;
var
  I: Integer;
begin
  if Length(Codigos) = 0 then
    Exit('1 = 0');
  Result := 'H.Archivo IN (';
  for I := 0 to High(Codigos) do
  begin
    if I > 0 then
      Result := Result + ', ';
    Result := Result + IntToStr(Codigos[I]);
  end;
  Result := Result + ')';
end;

function GrupoDeCaja(const CodSubs, IdExpediente, CodigoDoc: string; Fecha: TDateTime;
  const Version: string): string;
begin
  if Trim(IdExpediente) <> '' then
    Result := Trim(CodSubs) + '|' + Trim(IdExpediente)
  else
    Result := Trim(CodSubs) + '|doc|' + Trim(CodigoDoc) + '|' +
      FormatDateTime('yyyymmddhhnnss', Fecha) + '|' + Trim(Version);
end;

function TextosQueFaltan(Faltan: TCondiciones; TotalUnidades, SinCaja: Integer;
  const Marcadas: array of string): TArray<string>;
var
  Lista: TList<string>;
  Codigos, Textos: string;
  Falta: TArray<string>;
  V: TVerificacion;
  C: string;
begin
  Lista := TList<string>.Create;
  try
    if cdAutorizado in Faltan then
      Lista.Add('Falta registrar la autorizaci' + #243 + 'n de la Comisi' + #243 +
        'n (acta y acuerdo).');
    if cdSinBloqueos in Faltan then
    begin
      if TotalUnidades = 0 then
        Lista.Add('La transferencia no tiene documentos.')
      else
        Lista.Add('Hay documentos que ya no est' + #225 + 'n retenidos por esta transferencia.');
    end;
    if cdVerificacionesCompletas in Faltan then
    begin
      if SinCaja > 0 then
        Lista.Add('Hay ' + IntToStr(SinCaja) + ' documento(s) sin caja: numere las cajas.');
      Falta := VerificacionesFaltan(Marcadas);
      if Length(Falta) > 0 then
      begin
        Textos := '';
        for C in Falta do
          for V in VERIFICACIONES do
            if V.Codigo = C then
            begin
              if Textos <> '' then
                Textos := Textos + '; ';
              Textos := Textos + V.Texto;
            end;
        Codigos := Textos;
        Lista.Add('Faltan verificaciones: ' + Codigos + '.');
      end;
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

{ ------------------------------- auxiliares ------------------------------ }

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

{ Fecha (sin hora) para un parametro, o Null si no hay (0). }
function FechaOParametro(D: TDateTime): Variant;
begin
  if D = 0 then
    Result := Null
  else
    Result := Trunc(D);
end;

{ Codigos de los archivos (cl_ArchivosGestion) de tipo Gestion. }
function CodigosArchivoGestion(Conn: TFDConnection): TArray<Integer>;
var
  Q: TFDQuery;
  L: TList<Integer>;
begin
  L := TList<Integer>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.Open('SELECT A.Cod AS Cod, T.tipoarch AS Tipo FROM cl_ArchivosGestion A ' +
      'INNER JOIN cl_tipoarch T ON T.Idtipoarch = A.Tipo');
    while not Q.Eof do
    begin
      if TipoArchivoDesdeTexto(Q.FieldByName('Tipo').AsString) = taGestion then
        L.Add(Q.FieldByName('Cod').AsInteger);
      Q.Next;
    end;
    Result := L.ToArray;
  finally
    Q.Free;
    L.Free;
  end;
end;

procedure ReiniciarCajas(Conn: TFDConnection; IdProceso: Integer);
begin
  Conn.ExecSQL('DELETE FROM prc_caja WHERE IdProceso = :p', [IdProceso]);
  Conn.ExecSQL('UPDATE prc_unidad SET Caja = NULL WHERE IdProceso = :p', [IdProceso]);
end;

{ ------------------------------- propuesta ------------------------------- }

function ProponerTransferencia(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Hoy: TDateTime; IncluirNoVencidas: Boolean): TArray<TGrupoPropuesto>;
var
  Lista: TList<TGrupoPropuesto>;
  Gestion: TArray<Integer>;
  Subs: TList<TGrupoPropuesto>;
  G: TGrupoPropuesto;
  Q: TFDQuery;
  Desde, Hasta, I, Total, Ret: Integer;
  Corte: TDateTime;
  Base, Cond, SoloConPlazo: string;

  { Cuenta (y fechas extremas) los documentos vencidos del grupo; Retenidos=True
    cuenta solo los que ya retiene otro proceso. }
  procedure Contar(var Gr: TGrupoPropuesto; SoloRetenidos: Boolean; out N: Integer);
  var
    Sql: string;
  begin
    Sql := 'SELECT COUNT(*) AS N, MIN(H.Fecha) AS Desde, MAX(H.Fecha) AS Hasta ' +
      'FROM tb_SeriesDatos H WHERE H.IdEstructura = :e AND H.id = :i AND H.codsubs = :s ' +
      'AND ' + SqlArchivosGestion(Gestion) + ' AND ' + SqlCondicionVencido;
    if SoloRetenidos then
      Sql := Sql + ' AND EXISTS (SELECT 1 FROM prc_bloqueo B WHERE ' +
        'B.IdEstructura = H.IdEstructura AND B.id = H.id AND B.codsubs = H.codsubs ' +
        'AND B.Codigodoc = H.Codigodoc AND B.fecha = H.fecha AND B.version = H.version)';
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := Sql;
      Q.ParamByName('e').AsString := Gr.IdEstructura;
      Q.ParamByName('i').AsInteger := Gr.IdNodo;
      Q.ParamByName('s').AsString := Gr.CodSubs;
      Q.ParamByName('corte').AsDateTime := Corte;
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
  Gestion := CodigosArchivoGestion(Conn);
  if Length(Gestion) = 0 then
    Exit;
  Lista := TList<TGrupoPropuesto>.Create;
  Subs := TList<TGrupoPropuesto>.Create;
  try
    // 1) subseries asignadas a los nodos (con plazo definido, salvo transferencia anticipada)
    if IncluirNoVencidas then
      SoloConPlazo := ''
    else
      SoloConPlazo := 'C.tgestion > 0 AND ';
    Desde := 0;
    while Desde < Length(Nodos) do
    begin
      Hasta := Desde + NODOS_POR_CONSULTA - 1;
      if Hasta > High(Nodos) then
        Hasta := High(Nodos);
      Cond := CondicionNodos('S.IdEstructura', 'S.id', Desde, Hasta);
      Base := 'SELECT S.IdEstructura, S.id, S.codsubs, C.subserie, C.tgestion, R.serie ' +
        'FROM (tb_Serietree S INNER JOIN cl_subseries C ON C.codsubs = S.codsubs) ' +
        'INNER JOIN cl_series R ON R.codserie = C.codserie ' +
        'WHERE ' + SoloConPlazo + '(' + Cond + ') ORDER BY R.serie, C.subserie';
      Q := TFDQuery.Create(nil);
      try
        Q.Connection := Conn;
        Q.SQL.Text := Base;
        PonerNodos(Q, Nodos, Desde, Hasta);
        Q.Open;
        while not Q.Eof do
        begin
          G.IdEstructura := Q.FieldByName('IdEstructura').AsString;
          G.IdNodo := Q.FieldByName('id').AsInteger;
          G.CodSubs := Q.FieldByName('codsubs').AsString;
          G.Subserie := Q.FieldByName('subserie').AsString;
          G.Serie := Q.FieldByName('serie').AsString;
          G.Anios := Q.FieldByName('tgestion').AsInteger;
          G.Unidades := 0;
          G.Retenidos := 0;
          G.Desde := 0;
          G.Hasta := 0;
          G.Anticipada := IncluirNoVencidas;
          Subs.Add(G);
          Q.Next;
        end;
      finally
        Q.Free;
      end;
      Desde := Hasta + 1;
    end;
    // 2) por cada una, cuantos documentos vencieron y cuantos estan retenidos
    for I := 0 to Subs.Count - 1 do
    begin
      G := Subs[I];
      Corte := FechaCorteGrupo(Hoy, G.Anios, G.Anticipada);
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

function CrearTransferencia(Conn: TFDConnection; const Nodo: TClaveNodo;
  const Usuario: string; Anio: Integer; FPrevista: TDateTime): TProcesoRef;
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
      Result := CrearProceso(Conn, tpTransferencia, Nodo, Usuario, Anio);
      Conn.ExecSQL('INSERT INTO prc_transferencia (IdProceso, FPrevista) VALUES (:i, :f)',
        [Result.IdProceso, FechaOParametro(FPrevista)], [ftInteger, ftDateTime]);
      Conn.ExecSQL('UPDATE prc_cronograma SET IdProceso = :p WHERE Anio = :a AND ' +
        'IdEstructura = :e AND IdNodo = :n AND IdProceso IS NULL',
        [Result.IdProceso, Anio, Nodo.IdEstructura, Nodo.Id]);
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

function AgregarGrupo(Conn: TFDConnection; IdProceso: Integer; const G: TGrupoPropuesto;
  Hoy: TDateTime; out Agregados: Integer; out Motivo: string): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Gestion: TArray<Integer>;
  Corte: TDateTime;
  Propia: Boolean;
  Filtro, Clave, P: string;
begin
  Agregados := 0;
  Motivo := '';
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpTransferencia) then
    raise EArgumentException.Create('La transferencia no existe: ' + IntToStr(IdProceso));
  if (Estado <> 'C') or (Paso <> 1) then
  begin
    Motivo := 'Solo se pueden agregar documentos en el paso de propuesta';
    Exit;
  end;
  Corte := FechaCorteGrupo(Hoy, G.Anios, G.Anticipada);
  if Corte = 0 then
  begin
    Motivo := 'La subserie no tiene plazo definido en el archivo de gestion';
    Exit;
  end;
  Gestion := CodigosArchivoGestion(Conn);
  P := IntToStr(IdProceso);
  Filtro := 'H.IdEstructura = :e AND H.id = :i AND H.codsubs = :s AND ' +
    SqlArchivosGestion(Gestion) + ' AND ' + SqlCondicionVencido + ' AND NOT EXISTS ' +
    '(SELECT 1 FROM prc_bloqueo B WHERE B.IdEstructura = H.IdEstructura AND ' +
    'B.id = H.id AND B.codsubs = H.codsubs AND B.Codigodoc = H.Codigodoc AND ' +
    'B.fecha = H.fecha AND B.version = H.version)';
  Clave := 'B.IdProceso = ' + P + ' AND B.IdEstructura = :e AND B.id = :i AND B.codsubs = :s';
  Propia := IniciarTx(Conn);
  try
    try
      Agregados := Conn.ExecSQL('INSERT INTO prc_bloqueo (IdEstructura, id, codsubs, ' +
        'Codigodoc, fecha, version, IdProceso) SELECT H.IdEstructura, H.id, H.codsubs, ' +
        'H.Codigodoc, H.fecha, H.version, ' + P + ' FROM tb_SeriesDatos H WHERE ' + Filtro,
        [G.IdEstructura, G.IdNodo, G.CodSubs, Corte],
        [ftString, ftInteger, ftString, ftDateTime]);
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
        ReiniciarCajas(Conn, IdProceso);
      end;
      ConfirmarTx(Conn, Propia);
      Result := Agregados > 0;
      if not Result then
        Motivo := 'No hay documentos disponibles en este grupo (ya est' + #225 +
          'n retenidos por otro proceso)';
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
    // el except anterior ya deshizo la transaccion y se relanza lo no controlado
    raise;
  end;
end;

procedure QuitarGrupo(Conn: TFDConnection; IdProceso: Integer; const IdEstructura: string;
  IdNodo: Integer; const CodSubs: string);
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Propia: Boolean;
begin
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpTransferencia) or
    (Estado <> 'C') or (Paso > 3) then
    Exit;
  Propia := IniciarTx(Conn);
  try
    Conn.ExecSQL('DELETE FROM prc_bloqueo WHERE IdProceso = :p AND IdEstructura = :e ' +
      'AND id = :i AND codsubs = :s', [IdProceso, IdEstructura, IdNodo, CodSubs]);
    Conn.ExecSQL('DELETE FROM prc_unidad WHERE IdProceso = :p AND IdEstructura = :e ' +
      'AND id = :i AND codsubs = :s', [IdProceso, IdEstructura, IdNodo, CodSubs]);
    ReiniciarCajas(Conn, IdProceso);
    ConfirmarTx(Conn, Propia);
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

function ContarUnidades(Conn: TFDConnection; IdProceso: Integer): Integer;
begin
  Result := Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad WHERE ' +
    'IdProceso = :p AND Activa <> 0', [IdProceso]));
end;

function LeerAutorizacion(Conn: TFDConnection; IdProceso: Integer;
  out A: TAutorizacion): Boolean;
var
  Q: TFDQuery;
  C: string;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT Organo, NumActa, NumAcuerdo, Fecha FROM prc_autorizacion ' +
      'WHERE IdProceso = :p';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    Result := not Q.IsEmpty;
    if not Result then
      Exit;
    C := Trim(Q.FieldByName('Organo').AsString);
    if C = 'M' then
      A.Organo := ocMunicipal
    else if C = 'P' then
      A.Organo := ocProvincial
    else if C = 'N' then
      A.Organo := ocNacional
    else
      A.Organo := ocCentral;
    A.NumActa := Q.FieldByName('NumActa').AsString;
    A.NumAcuerdo := Q.FieldByName('NumAcuerdo').AsString;
    A.Fecha := FechaODefecto(Q.FieldByName('Fecha'));
  finally
    Q.Free;
  end;
end;

function GruposDeLaTransferencia(Conn: TFDConnection;
  IdProceso: Integer): TArray<TGrupoAgregado>;
var
  Q: TFDQuery;
  L: TList<TGrupoAgregado>;
  G: TGrupoAgregado;
begin
  L := TList<TGrupoAgregado>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT u.IdEstructura AS Ie, u.id AS Id, u.codsubs AS Cs, ' +
      'C.subserie AS Sub, R.serie AS Ser, COUNT(*) AS N, MIN(u.fecha) AS Desde, ' +
      'MAX(u.fecha) AS Hasta FROM (prc_unidad u LEFT JOIN cl_subseries C ON ' +
      'C.codsubs = u.codsubs) LEFT JOIN cl_series R ON R.codserie = C.codserie ' +
      'WHERE u.IdProceso = :p AND u.Activa <> 0 GROUP BY u.IdEstructura, u.id, ' +
      'u.codsubs, C.subserie, R.serie ORDER BY R.serie, C.subserie';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    while not Q.Eof do
    begin
      G.IdEstructura := Q.FieldByName('Ie').AsString;
      G.IdNodo := Q.FieldByName('Id').AsInteger;
      G.CodSubs := Q.FieldByName('Cs').AsString;
      G.Subserie := Q.FieldByName('Sub').AsString;
      G.Serie := Q.FieldByName('Ser').AsString;
      G.Unidades := Q.FieldByName('N').AsInteger;
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

{ --------------------------------- cajas --------------------------------- }

type
  TUnidadCaja = record
    IdEstructura: string;
    Id: Integer;
    CodSubs, Codigo, Version, Serie, Subserie: string;
    Fecha, FechaDoc: TDateTime;
    HayFechaDoc: Boolean;
  end;

procedure NumerarCajas(Conn: TFDConnection; IdProceso, Capacidad: Integer);
var
  Q, Up: TFDQuery;
  Unidades: TList<TUnidadCaja>;
  U: TUnidadCaja;
  Items: TArray<TItemCaja>;
  Cajas: TArray<Integer>;
  I, C: Integer;
  Propia: Boolean;
  Ex: string;
  Desde, Hasta: TDictionary<Integer, TDateTime>;
  Cuenta: TDictionary<Integer, Integer>;
  Rotulo: TDictionary<Integer, TUnidadCaja>;
  Mixta: TDictionary<Integer, Boolean>;
  D, H: TDateTime;
  Desc: string;
begin
  Unidades := TList<TUnidadCaja>.Create;
  Desde := TDictionary<Integer, TDateTime>.Create;
  Hasta := TDictionary<Integer, TDateTime>.Create;
  Cuenta := TDictionary<Integer, Integer>.Create;
  Rotulo := TDictionary<Integer, TUnidadCaja>.Create;
  Mixta := TDictionary<Integer, Boolean>.Create;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := 'SELECT u.IdEstructura AS Ie, u.id AS Id, u.codsubs AS Cs, ' +
        'u.Codigodoc AS Cd, u.fecha AS Fe, u.version AS Ve, H.IDExpediente AS Ex, ' +
        'H.Fecha AS FechaDoc, C.subserie AS Sub, R.serie AS Ser ' +
        'FROM (((prc_unidad u LEFT JOIN tb_SeriesDatos H ON H.IdEstructura = u.IdEstructura ' +
        'AND H.id = u.id AND H.codsubs = u.codsubs AND H.Codigodoc = u.Codigodoc AND ' +
        'H.fecha = u.fecha AND H.version = u.version) ' +
        'LEFT JOIN cl_subseries C ON C.codsubs = u.codsubs) ' +
        'LEFT JOIN cl_series R ON R.codserie = C.codserie) ' +
        'WHERE u.IdProceso = :p AND u.Activa <> 0 ' +
        'ORDER BY R.serie, C.subserie, u.fecha, u.Codigodoc';
      Q.ParamByName('p').AsInteger := IdProceso;
      Q.Open;
      SetLength(Items, 0);
      while not Q.Eof do
      begin
        U.IdEstructura := Q.FieldByName('Ie').AsString;
        U.Id := Q.FieldByName('Id').AsInteger;
        U.CodSubs := Q.FieldByName('Cs').AsString;
        U.Codigo := Q.FieldByName('Cd').AsString;
        U.Version := Q.FieldByName('Ve').AsString;
        U.Fecha := Q.FieldByName('Fe').AsDateTime;
        U.HayFechaDoc := not Q.FieldByName('FechaDoc').IsNull;
        if U.HayFechaDoc then
          U.FechaDoc := Q.FieldByName('FechaDoc').AsDateTime
        else
          U.FechaDoc := U.Fecha;
        U.Serie := Q.FieldByName('Ser').AsString;
        U.Subserie := Q.FieldByName('Sub').AsString;
        Ex := Q.FieldByName('Ex').AsString;
        Unidades.Add(U);
        SetLength(Items, Length(Items) + 1);
        Items[High(Items)].Grupo := GrupoDeCaja(U.CodSubs, Ex, U.Codigo, U.Fecha, U.Version);
        Items[High(Items)].Orden := Unidades.Count;
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    Cajas := RepartirEnCajas(Items, Capacidad, 1);
    Propia := IniciarTx(Conn);
    try
      Conn.ExecSQL('DELETE FROM prc_caja WHERE IdProceso = :p', [IdProceso]);
      Up := TFDQuery.Create(nil);
      try
        Up.Connection := Conn;
        Up.SQL.Text := 'UPDATE prc_unidad SET Caja = :c WHERE IdProceso = :p AND ' +
          'IdEstructura = :e AND id = :i AND codsubs = :s AND Codigodoc = :d AND ' +
          'fecha = :f AND version = :v';
        for I := 0 to Unidades.Count - 1 do
        begin
          U := Unidades[I];
          C := Cajas[I];
          Up.ParamByName('c').AsInteger := C;
          Up.ParamByName('p').AsInteger := IdProceso;
          Up.ParamByName('e').AsString := U.IdEstructura;
          Up.ParamByName('i').AsInteger := U.Id;
          Up.ParamByName('s').AsString := U.CodSubs;
          Up.ParamByName('d').AsString := U.Codigo;
          Up.ParamByName('f').AsDateTime := U.Fecha;
          Up.ParamByName('v').AsString := U.Version;
          Up.ExecSQL;
          if not Cuenta.ContainsKey(C) then
          begin
            Cuenta.Add(C, 0);
            Desde.Add(C, U.FechaDoc);
            Hasta.Add(C, U.FechaDoc);
            Rotulo.Add(C, U);
            Mixta.Add(C, False);
          end
          else if Rotulo[C].CodSubs <> U.CodSubs then
            Mixta[C] := True;
          Cuenta[C] := Cuenta[C] + 1;
          if U.FechaDoc < Desde[C] then
            Desde[C] := U.FechaDoc;
          if U.FechaDoc > Hasta[C] then
            Hasta[C] := U.FechaDoc;
        end;
      finally
        Up.Free;
      end;
      for C in Cuenta.Keys do
      begin
        U := Rotulo[C];
        D := Desde[C];
        H := Hasta[C];
        Desc := Trim(U.Serie);
        if Trim(U.Subserie) <> '' then
        begin
          if Desc <> '' then
            Desc := Desc + ' - ';
          Desc := Desc + Trim(U.Subserie);
        end;
        if Mixta[C] then
          Desc := Desc + ' y otras';
        Conn.ExecSQL('INSERT INTO prc_caja (IdProceso, Caja, Tipo, Descripcion, FDesde, ' +
          'FHasta, Unidades) VALUES (:p, :c, :t, :d, :f1, :f2, :u)',
          [IdProceso, C, Copy(Trim(U.Subserie), 1, 100), Copy(Desc, 1, 255), D, H,
           Cuenta[C]]);
      end;
      ConfirmarTx(Conn, Propia);
    except
      DeshacerTx(Conn, Propia);
      raise;
    end;
  finally
    Mixta.Free;
    Rotulo.Free;
    Cuenta.Free;
    Hasta.Free;
    Desde.Free;
    Unidades.Free;
  end;
end;

{ ----------------------------- verificaciones ---------------------------- }

procedure MarcarVerificacion(Conn: TFDConnection; IdProceso: Integer;
  const Codigo: string; Marcada: Boolean);
var
  N: Integer;
begin
  N := Conn.ExecSQL('UPDATE prc_verificacion SET Marcada = :m WHERE IdProceso = :p ' +
    'AND Codigo = :c', [Marcada, IdProceso, Codigo], [ftBoolean, ftInteger, ftString]);
  if N = 0 then
    Conn.ExecSQL('INSERT INTO prc_verificacion (IdProceso, Codigo, Marcada) ' +
      'VALUES (:p, :c, :m)', [IdProceso, Codigo, Marcada], [ftInteger, ftString, ftBoolean]);
end;

function VerificacionesMarcadas(Conn: TFDConnection; IdProceso: Integer): TArray<string>;
var
  Q: TFDQuery;
  L: TList<string>;
begin
  L := TList<string>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT Codigo FROM prc_verificacion WHERE IdProceso = :p AND Marcada <> 0';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    while not Q.Eof do
    begin
      L.Add(Trim(Q.FieldByName('Codigo').AsString));
      Q.Next;
    end;
    Result := L.ToArray;
  finally
    Q.Free;
    L.Free;
  end;
end;

{ ------------------------------- avance ---------------------------------- }

{ Evalua las condiciones; devuelve tambien el total de unidades, las que no tienen
  caja y las verificaciones marcadas (para armar las frases). }
function Evaluar(Conn: TFDConnection; IdProceso: Integer; out Total, SinCaja: Integer;
  out Marcadas: TArray<string>): TCondiciones;
var
  Propias: Integer;
begin
  Result := [];
  Total := ContarUnidades(Conn, IdProceso);
  SinCaja := Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad WHERE ' +
    'IdProceso = :p AND Activa <> 0 AND Caja IS NULL', [IdProceso]));
  Propias := Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad u WHERE ' +
    'u.IdProceso = :p AND u.Activa <> 0 AND EXISTS (SELECT 1 FROM prc_bloqueo b WHERE ' +
    'b.IdProceso = u.IdProceso AND b.IdEstructura = u.IdEstructura AND b.id = u.id AND ' +
    'b.codsubs = u.codsubs AND b.Codigodoc = u.Codigodoc AND b.fecha = u.fecha AND ' +
    'b.version = u.version)', [IdProceso]));
  Marcadas := VerificacionesMarcadas(Conn, IdProceso);
  if Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_autorizacion WHERE ' +
    'IdProceso = :p', [IdProceso])) > 0 then
    Include(Result, cdAutorizado);
  if (Total > 0) and (Propias = Total) then
    Include(Result, cdSinBloqueos);
  if (Total > 0) and (SinCaja = 0) and VerificacionesCompletas(Marcadas) then
    Include(Result, cdVerificacionesCompletas);
end;

function CondicionesCumplidas(Conn: TFDConnection; IdProceso: Integer;
  out Faltan: TArray<string>): TCondiciones;
var
  Total, SinCaja: Integer;
  Marcadas: TArray<string>;
begin
  Result := Evaluar(Conn, IdProceso, Total, SinCaja, Marcadas);
  Faltan := TextosQueFaltan([cdAutorizado, cdSinBloqueos, cdVerificacionesCompletas] - Result,
    Total, SinCaja, Marcadas);
end;

function AvanzarTransferencia(Conn: TFDConnection; IdProceso, PasoLeido: Integer;
  const Usuario: string; out Faltan: TArray<string>): Boolean;
var
  Tipo: TTipoProceso;
  Paso, Total, SinCaja: Integer;
  Estado: string;
  Marcadas: TArray<string>;
  Cond, Necesarias, Falta: TCondiciones;
begin
  Faltan := nil;
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpTransferencia) then
    Exit;
  if (Estado <> 'C') or (Paso <> PasoLeido) or (Paso >= 4) then
  begin
    Faltan := ['Otro usuario ya cambi' + #243 + ' la transferencia o no se puede avanzar desde este paso.'];
    Exit;
  end;
  Cond := Evaluar(Conn, IdProceso, Total, SinCaja, Marcadas);
  Necesarias := CondicionesParaAvanzar(tpTransferencia, Paso);
  Falta := Necesarias - Cond;
  if Falta <> [] then
  begin
    Faltan := TextosQueFaltan(Falta, Total, SinCaja, Marcadas);
    Exit;
  end;
  Result := AvanzarPaso(Conn, IdProceso, PasoLeido, Cond, Usuario, Falta);
  if not Result then
    Faltan := ['Otro usuario ya cambi' + #243 + ' la transferencia.'];
end;

function RegistrarEntregaTransferencia(Conn: TFDConnection; IdProceso: Integer;
  const Usuario, EntregadoPor: string; Fecha: TDateTime): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Falta: TCondiciones;
  Propia: Boolean;
begin
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpTransferencia) then
    Exit;
  if (Estado <> 'C') or (Paso <> 4) then
    Exit;
  Propia := IniciarTx(Conn);
  try
    if not AvanzarPaso(Conn, IdProceso, 4, [], Usuario, Falta) then
    begin
      DeshacerTx(Conn, Propia);
      Exit;
    end;
    Conn.ExecSQL('UPDATE prc_transferencia SET FEntrega = :f, EntregadoPor = :e ' +
      'WHERE IdProceso = :p', [Fecha, Copy(Trim(EntregadoPor), 1, 100), IdProceso],
      [ftDateTime, ftString, ftInteger]);
    ConfirmarTx(Conn, Propia);
    Result := True;
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

{ -------------------------------- listados ------------------------------- }

function ListarTransferencias(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Anio, Limite: Integer): TArray<TTransferenciaFila>;
var
  Lista: TList<TTransferenciaFila>;
  Desde, Hasta, Tope: Integer;
  Q: TFDQuery;
  F: TTransferenciaFila;
begin
  if Limite <= 0 then
    Tope := LIMITE_POR_DEFECTO
  else
    Tope := Limite;
  Lista := TList<TTransferenciaFila>.Create;
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
        Q.SQL.Text := 'SELECT TOP ' + IntToStr(Tope) + ' p.IdProceso, p.Anio, p.IdEstructura, p.IdNodo, ' +
          'p.Consecutivo, p.Numero, p.Estado, p.Paso, N.etiqueta AS Remitente, ' +
          't.FPrevista, t.FEntrega, ' +
          '(SELECT COUNT(*) FROM prc_unidad u WHERE u.IdProceso = p.IdProceso) AS Unidades, ' +
          '(SELECT COUNT(*) FROM prc_caja c WHERE c.IdProceso = p.IdProceso) AS Cajas ' +
          'FROM (prc_proceso p INNER JOIN prc_transferencia t ON t.IdProceso = p.IdProceso) ' +
          'LEFT JOIN tb_tree N ON N.IdEstructura = p.IdEstructura AND N.id = p.IdNodo ' +
          'WHERE p.Tipo = ''T'' AND p.Anio = :a AND (' +
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
          F.Remitente := Q.FieldByName('Remitente').AsString;
          F.Nodo.IdEstructura := Q.FieldByName('IdEstructura').AsString;
          F.Nodo.Id := Q.FieldByName('IdNodo').AsInteger;
          F.Paso := Q.FieldByName('Paso').AsInteger;
          F.Proceso := EstadoDesdeCodigo(Q.FieldByName('Estado').AsString);
          F.Estado := TextoEstadoTransferencia(F.Paso, F.Proceso);
          F.FPrevista := FechaODefecto(Q.FieldByName('FPrevista'));
          F.FEntrega := FechaODefecto(Q.FieldByName('FEntrega'));
          F.Unidades := Q.FieldByName('Unidades').AsInteger;
          F.Cajas := Q.FieldByName('Cajas').AsInteger;
          Lista.Add(F);
          Q.Next;
        end;
      finally
        Q.Free;
      end;
      Desde := Hasta + 1;
    end;
    Lista.Sort(TComparer<TTransferenciaFila>.Construct(
      function(const A, B: TTransferenciaFila): Integer
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

procedure ProgramarTransferencia(Conn: TFDConnection; const Nodo: TClaveNodo;
  Anio: Integer; FPrevista: TDateTime);
var
  N: Integer;
begin
  N := Conn.ExecSQL('UPDATE prc_cronograma SET FPrevista = :f WHERE Anio = :a AND ' +
    'IdEstructura = :e AND IdNodo = :n', [Trunc(FPrevista), Anio, Nodo.IdEstructura, Nodo.Id],
    [ftDateTime, ftInteger, ftString, ftInteger]);
  if N = 0 then
    Conn.ExecSQL('INSERT INTO prc_cronograma (Anio, IdEstructura, IdNodo, FPrevista) ' +
      'VALUES (:a, :e, :n, :f)', [Anio, Nodo.IdEstructura, Nodo.Id, Trunc(FPrevista)],
      [ftInteger, ftString, ftInteger, ftDateTime]);
end;

function ListarCronograma(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Anio: Integer; Hoy: TDateTime): TArray<TCronogramaFila>;
var
  Lista: TList<TCronogramaFila>;
  Desde, Hasta: Integer;
  Q: TFDQuery;
  F: TCronogramaFila;
  Est: string;
begin
  Lista := TList<TCronogramaFila>.Create;
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
        Q.SQL.Text := 'SELECT c.IdCronograma, c.Anio, c.IdEstructura, c.IdNodo, ' +
          'c.FPrevista, c.IdProceso, N.etiqueta AS Etiqueta, p.Estado AS Estado ' +
          'FROM (prc_cronograma c LEFT JOIN tb_tree N ON N.IdEstructura = c.IdEstructura ' +
          'AND N.id = c.IdNodo) LEFT JOIN prc_proceso p ON p.IdProceso = c.IdProceso ' +
          'WHERE c.Anio = :a AND (' + CondicionNodos('c.IdEstructura', 'c.IdNodo', Desde,
          Hasta) + ') ORDER BY c.FPrevista';
        Q.ParamByName('a').AsInteger := Anio;
        PonerNodos(Q, Nodos, Desde, Hasta);
        Q.Open;
        while not Q.Eof do
        begin
          F.IdCronograma := Q.FieldByName('IdCronograma').AsInteger;
          F.Anio := Q.FieldByName('Anio').AsInteger;
          F.IdEstructura := Q.FieldByName('IdEstructura').AsString;
          F.IdNodo := Q.FieldByName('IdNodo').AsInteger;
          F.Etiqueta := Q.FieldByName('Etiqueta').AsString;
          F.FPrevista := Q.FieldByName('FPrevista').AsDateTime;
          if Q.FieldByName('IdProceso').IsNull then
            F.IdProceso := 0
          else
            F.IdProceso := Q.FieldByName('IdProceso').AsInteger;
          Est := Trim(Q.FieldByName('Estado').AsString);
          // una transferencia cancelada no cuenta: el cronograma sigue pendiente
          F.Estado := EstadoCronograma(F.FPrevista, (F.IdProceso <> 0) and (Est <> 'X'),
            Est = 'F', Hoy);
          Lista.Add(F);
          Q.Next;
        end;
      finally
        Q.Free;
      end;
      Desde := Hasta + 1;
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

function RelacionDeEntrega(Conn: TFDConnection; IdProceso: Integer): TArray<TLineaRelacion>;
var
  Q: TFDQuery;
  L: TList<TLineaRelacion>;
  R: TLineaRelacion;
  N: Integer;
begin
  L := TList<TLineaRelacion>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT Caja, Tipo, Descripcion, FDesde, FHasta, Unidades FROM prc_caja ' +
      'WHERE IdProceso = :p ORDER BY Caja';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    N := 0;
    while not Q.Eof do
    begin
      Inc(N);
      R.Numero := N;
      R.Caja := Q.FieldByName('Caja').AsInteger;
      R.Tipo := Q.FieldByName('Tipo').AsString;
      R.Descripcion := Q.FieldByName('Descripcion').AsString;
      R.Desde := FechaODefecto(Q.FieldByName('FDesde'));
      R.Hasta := FechaODefecto(Q.FieldByName('FHasta'));
      R.Unidades := Q.FieldByName('Unidades').AsInteger;
      L.Add(R);
      Q.Next;
    end;
    Result := L.ToArray;
  finally
    Q.Free;
    L.Free;
  end;
end;

end.
