unit UPrestamosDatos;

{ ---------------------------------------------------------------------------
  Datos del prestamo de documentos. Solo RTL + FireDAC: sin VCL ni TUDM.

  Un prestamo es un proceso de tipo 'P' (prc_proceso) con sus datos propios
  (prc_prestamo) y los documentos que se prestan (prc_unidad, retenidos por
  prc_bloqueo mientras el prestamo este abierto). Los pasos y las reglas de
  avance son los de UProceso; el estado visible y el plazo, los de
  UPrestamosReglas.

    1 Solicitado -> 2 Entregado -> 3 Devuelto (finaliza)

  Reglas:
    - un documento prestado no puede estar en otro proceso abierto;
    - la entrega exige al menos un documento;
    - devolver dos veces (o cancelar un prestamo ya devuelto) se rechaza;
    - las listas y los indicadores se obtienen con consultas de conteo y
      limitadas (nunca recorriendo todos los prestamos);
    - los nodos los decide quien llama: sin nodos no se devuelve nada.
  Valido en SQL Server y Access (SELECT TOP n, parametros, sin CASE).
  Diseno: docs/superpowers/specs/2026-11-12-prestamos-transferencias-
  depuracion-design.md (seccion 5).
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance, UProceso, UCandados,
  UProcesosDatos, UPrestamosReglas;

type
  { La solicitud no cumple las reglas de UPrestamosReglas; el mensaje es el del
    primer error. }
  EPrestamoInvalido = class(Exception);

  TFiltroPrestamo = (fpTodos, fpEnPrestamo, fpVencidos, fpDevueltos,
    fpSolicitudes);

  TPrestamoFila = record
    IdProceso: Integer;
    Anio, Consecutivo: Integer;
    Numero, Solicitante, Carnet, Entidad: string;
    AtendidoPor, Obs: string;
    Creado: TDateTime;                           // fecha de la solicitud
    Usuario: TTipoUsuarioPrestamo;
    Unidades: Integer;
    FEntrega, FLimite, FDevolucion: TDateTime;   // 0 = sin fecha
    Paso: Integer;
    Estado: TEstadoProceso;
    Visible: TEstadoPrestamo;
  end;

  TIndicadoresPrestamo = record
    EnPrestamo: Integer;     // entregados: incluye vencidos y por vencer
    Vencidos: Integer;
    PorVencer: Integer;
    DevueltosAnio: Integer;
    Solicitudes: Integer;
    Total: Integer;          // todos menos los cancelados
  end;

  { Cantidad de prestamos con el mismo paso, estado y fecha limite. }
  TConteoGrupo = record
    Paso: Integer;
    Estado: TEstadoProceso;
    Limite: TDateTime;
    Cantidad: Integer;
  end;

  TDocumentoBuscado = record
    Unidad: TUnidadDoc;
    Titulo: string;
    Ubicacion: string;       // deposito / gaveta / posicion
    Bloqueado: Boolean;
    Bloqueo: TBloqueo;       // quien lo retiene, si Bloqueado
  end;

{ Condicion SQL (sobre p = prc_proceso y r = prc_prestamo) de cada pestana; ''
  para fpTodos. fpVencidos usa el parametro :hoy (solo la fecha). }
function CondicionFiltro(Filtro: TFiltroPrestamo): string;

{ Indicadores a partir de los conteos agrupados (pura; la usa IndicadoresPrestamo). }
function IndicadoresDesdeConteos(const Grupos: TArray<TConteoGrupo>;
  DevueltosAnio: Integer; Hoy: TDateTime): TIndicadoresPrestamo;

{ Crea la solicitud (paso 1). Lanza EPrestamoInvalido si no cumple las reglas. }
function CrearSolicitud(Conn: TFDConnection; const Nodo: TClaveNodo;
  const S: TSolicitudPrestamo; const Usuario: string; Anio: Integer): TProcesoRef;

{ Agrega un documento mientras el prestamo esta solicitado. Si lo retiene otro
  proceso devuelve False y Motivo dice cual. }
function AgregarDocumento(Conn: TFDConnection; IdProceso: Integer;
  const U: TUnidadDoc; out Motivo: string): Boolean;

{ Entrega los documentos (1 -> 2). Exige al menos un documento y que Limite (si se
  indica) no sea anterior a la entrega. False con Motivo si no se puede. }
function RegistrarEntrega(Conn: TFDConnection; IdProceso: Integer;
  const Usuario: string; Entrega, Limite: TDateTime; out Motivo: string): Boolean;

{ Pospone la fecha limite de un prestamo entregado. NuevoLimite debe ser posterior
  al actual (si hay). }
function RenovarPlazo(Conn: TFDConnection; IdProceso: Integer;
  NuevoLimite: TDateTime; const Usuario: string): Boolean;

{ Recibe de vuelta los documentos (2 -> 3 y finaliza; libera los documentos).
  False si ya no esta entregado (por ejemplo, ya devuelto). }
function RegistrarDevolucion(Conn: TFDConnection; IdProceso: Integer;
  Completo: Boolean; const Obs, Usuario: string; Devolucion: TDateTime): Boolean;

{ Cancela un prestamo solicitado o entregado y libera sus documentos. }
function CancelarPrestamo(Conn: TFDConnection; IdProceso: Integer;
  const Motivo, Usuario: string): Boolean;

{ Prestamos de los nodos, mas recientes primero, con a lo sumo Limite filas.
  Texto busca en numero, solicitante y entidad. Hoy fija el estado visible. }
function ListarPrestamos(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Filtro: TFiltroPrestamo; Hoy: TDateTime; const Texto: string;
  Limite: Integer): TArray<TPrestamoFila>;

{ Contadores de la franja de indicadores (3 consultas de conteo). }
function IndicadoresPrestamo(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Hoy: TDateTime): TIndicadoresPrestamo;

{ Documentos de los nodos que el alcance deja ver, marcando los que otro proceso
  retiene. Texto busca en codigo y titulo. Alcance = nil: sin filtro. }
function BuscarDocumentos(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Alcance: TAlcanceUsuario; const Texto: string; Limite: Integer): TArray<TDocumentoBuscado>;

{ Documentos que forman el prestamo. }
function DocumentosDelPrestamo(Conn: TFDConnection;
  IdProceso: Integer): TArray<TDocumentoBuscado>;

implementation

uses
  System.Generics.Collections, System.Generics.Defaults, System.Variants,
  System.DateUtils, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Param,
  FireDAC.Stan.Error, UErroresCampo, UAlcanceDatos, UTransferidos;

const
  NODOS_POR_CONSULTA = 200;
  LIMITE_POR_DEFECTO = 500;

{ -------------------------- reglas puras de SQL -------------------------- }

function CondicionFiltro(Filtro: TFiltroPrestamo): string;
begin
  case Filtro of
    fpEnPrestamo:
      Result := 'p.Estado = ''C'' AND p.Paso = 2';
    fpVencidos:
      Result := 'p.Estado = ''C'' AND p.Paso = 2 AND r.FLimite IS NOT NULL ' +
        'AND r.FLimite < :hoy';
    fpDevueltos:
      Result := 'p.Estado = ''F''';
    fpSolicitudes:
      Result := 'p.Estado = ''C'' AND p.Paso = 1';
  else
    Result := '';
  end;
end;

function IndicadoresDesdeConteos(const Grupos: TArray<TConteoGrupo>;
  DevueltosAnio: Integer; Hoy: TDateTime): TIndicadoresPrestamo;
var
  G: TConteoGrupo;
begin
  Result.EnPrestamo := 0;
  Result.Vencidos := 0;
  Result.PorVencer := 0;
  Result.Solicitudes := 0;
  Result.Total := 0;
  Result.DevueltosAnio := DevueltosAnio;
  for G in Grupos do
    case G.Estado of
      epFinalizado:
        Inc(Result.Total, G.Cantidad);
      epEnCurso:
        begin
          Inc(Result.Total, G.Cantidad);
          if G.Paso <= 1 then
            Inc(Result.Solicitudes, G.Cantidad)
          else
          begin
            Inc(Result.EnPrestamo, G.Cantidad);
            case EstadoDelPrestamo(G.Paso, G.Estado, G.Limite, Hoy) of
              epsVencido: Inc(Result.Vencidos, G.Cantidad);
              epsPorVencer: Inc(Result.PorVencer, G.Cantidad);
            end;
          end;
        end;
    end;
end;

{ ------------------------------- auxiliares ------------------------------ }

{ Condicion '(col1 = :qe0 AND col2 = :qi0) OR ...' para Nodos[Desde..Hasta]. }
function CondicionNodos(const ColEstructura, ColId: string;
  Desde, Hasta: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := Desde to Hasta do
  begin
    if Result <> '' then
      Result := Result + ' OR ';
    Result := Result + '(' + ColEstructura + ' = :qe' + IntToStr(I - Desde) +
      ' AND ' + ColId + ' = :qi' + IntToStr(I - Desde) + ')';
  end;
end;

procedure PonerNodos(Q: TFDQuery; const Nodos: TArray<TClaveNodo>;
  Desde, Hasta: Integer);
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

function CodigoUsuario(U: TTipoUsuarioPrestamo): string;
begin
  if U = tuExterno then
    Result := 'E'
  else
    Result := 'I';
end;

function LimiteValido(Limite: Integer): Integer;
begin
  if Limite <= 0 then
    Result := LIMITE_POR_DEFECTO
  else
    Result := Limite;
end;

function UbicacionDe(const Deposito, Gaveta, Posicion: string): string;
  procedure Sumar(const Parte: string);
  begin
    if (Trim(Parte) = '') or (Trim(Parte) = '0') then
      Exit;
    if Result <> '' then
      Result := Result + ' / ';
    Result := Result + Trim(Parte);
  end;
begin
  Result := '';
  Sumar(Deposito);
  Sumar(Gaveta);
  Sumar(Posicion);
end;

{ ------------------------------- escritura ------------------------------- }

function CrearSolicitud(Conn: TFDConnection; const Nodo: TClaveNodo;
  const S: TSolicitudPrestamo; const Usuario: string; Anio: Integer): TProcesoRef;
var
  Errores: TArray<TErrorCampo>;
  Intento: Integer;
  Propia: Boolean;
begin
  Errores := ValidarSolicitud(S, Date);
  if Length(Errores) > 0 then
    raise EPrestamoInvalido.Create(Errores[0].Mensaje);
  Result.IdProceso := 0;
  Result.Numero := '';
  for Intento := 1 to 3 do
  begin
    Propia := IniciarTx(Conn);
    try
      // dentro de nuestra transaccion CrearProceso no la abre ni la cierra
      Result := CrearProceso(Conn, tpPrestamo, Nodo, Usuario, Anio);
      Conn.ExecSQL('INSERT INTO prc_prestamo (IdProceso, Solicitante, Carnet, ' +
        'Entidad, TipoUsuario, FLimite) VALUES (:i, :s, :c, :e, :t, :l)',
        [Result.IdProceso, Trim(S.Solicitante), Trim(S.Carnet), Trim(S.Entidad),
         CodigoUsuario(S.Usuario), FechaOParametro(S.FechaLimite)],
        [ftInteger, ftString, ftString, ftString, ftString, ftDateTime]);
      ConfirmarTx(Conn, Propia);
      Exit;
    except
      on E: EFDDBEngineException do
      begin
        DeshacerTx(Conn, Propia);
        // otro usuario tomo el mismo numero a la vez: se reintenta
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

function AgregarDocumento(Conn: TFDConnection; IdProceso: Integer;
  const U: TUnidadDoc; out Motivo: string): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
begin
  Motivo := '';
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpPrestamo) then
    raise EArgumentException.Create('El prestamo no existe: ' + IntToStr(IdProceso));
  if (Estado <> 'C') or (Paso <> 1) then
  begin
    Motivo := 'Solo se pueden cambiar los documentos de un prestamo solicitado';
    Exit(False);
  end;
  Motivo := DondeEstaTransferido(Conn, U);
  if Motivo <> '' then
    Exit(False);  // ya no esta en este archivo: se dice a donde fue
  Result := AgregarUnidad(Conn, IdProceso, U, Motivo);
end;

function RegistrarEntrega(Conn: TFDConnection; IdProceso: Integer;
  const Usuario: string; Entrega, Limite: TDateTime; out Motivo: string): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Faltan: TCondiciones;
  Propia: Boolean;
begin
  Motivo := '';
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpPrestamo) then
    raise EArgumentException.Create('El prestamo no existe: ' + IntToStr(IdProceso));
  if (Estado <> 'C') or (Paso <> 1) then
  begin
    Motivo := 'El prestamo ya no esta solicitado';
    Exit;
  end;
  if (Limite <> 0) and (Trunc(Limite) < Trunc(Entrega)) then
  begin
    Motivo := 'La fecha limite no puede ser anterior a la entrega';
    Exit;
  end;
  if Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_unidad WHERE ' +
    'IdProceso = :i AND Activa <> 0', [IdProceso])) = 0 then
  begin
    Motivo := 'Agregue al menos un documento antes de entregar';
    Exit;
  end;
  Propia := IniciarTx(Conn);
  try
    // los documentos ya estan retenidos por este prestamo: no hay otros bloqueos
    if not AvanzarPaso(Conn, IdProceso, 1, [cdSinBloqueos], Usuario, Faltan) then
    begin
      DeshacerTx(Conn, Propia);
      Motivo := 'Otro usuario ya cambio el prestamo';
      Exit;
    end;
    Conn.ExecSQL('UPDATE prc_prestamo SET FEntrega = :e, FLimite = :l, ' +
      'AtendidoPor = :u WHERE IdProceso = :i',
      [Entrega, FechaOParametro(Limite), Usuario, IdProceso],
      [ftDateTime, ftDateTime, ftString, ftInteger]);
    ConfirmarTx(Conn, Propia);
    Result := True;
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

function RenovarPlazo(Conn: TFDConnection; IdProceso: Integer;
  NuevoLimite: TDateTime; const Usuario: string): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Actual: Variant;
  Propia: Boolean;
begin
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpPrestamo) then
    Exit;
  if (Estado <> 'C') or (Paso <> 2) or (NuevoLimite = 0) then
    Exit;
  Actual := Conn.ExecSQLScalar('SELECT FLimite FROM prc_prestamo WHERE IdProceso = :i',
    [IdProceso]);
  if (not VarIsNull(Actual)) and (Trunc(NuevoLimite) <= Trunc(VarToDateTime(Actual))) then
    Exit;
  Propia := IniciarTx(Conn);
  try
    Conn.ExecSQL('UPDATE prc_prestamo SET FLimite = :l WHERE IdProceso = :i',
      [Trunc(NuevoLimite), IdProceso]);
    RegistrarEvento(Conn, IdProceso, Usuario, 'Plazo renovado hasta ' +
      FormatDateTime('dd/mm/yyyy', NuevoLimite));
    ConfirmarTx(Conn, Propia);
    Result := True;
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

function RegistrarDevolucion(Conn: TFDConnection; IdProceso: Integer;
  Completo: Boolean; const Obs, Usuario: string; Devolucion: TDateTime): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Faltan: TCondiciones;
  Propia: Boolean;
begin
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpPrestamo) then
    Exit;
  if (Estado <> 'C') or (Paso <> 2) then
    Exit;
  Propia := IniciarTx(Conn);
  try
    // 2 -> 3 (Devuelto) y luego cierra el proceso: libera los documentos
    if not (AvanzarPaso(Conn, IdProceso, 2, [], Usuario, Faltan) and
      AvanzarPaso(Conn, IdProceso, 3, [], Usuario, Faltan)) then
    begin
      DeshacerTx(Conn, Propia);
      Exit;
    end;
    Conn.ExecSQL('UPDATE prc_prestamo SET FDevolucion = :d, Completo = :c, ' +
      'Obs = :o WHERE IdProceso = :i',
      [Devolucion, Completo, Copy(Trim(Obs), 1, 255), IdProceso]);
    ConfirmarTx(Conn, Propia);
    Result := True;
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

function CancelarPrestamo(Conn: TFDConnection; IdProceso: Integer;
  const Motivo, Usuario: string): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
begin
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) or (Tipo <> tpPrestamo) then
    Exit;
  Result := CancelarProceso(Conn, IdProceso, Usuario, Motivo);
end;

{ -------------------------------- lectura -------------------------------- }

function ListarPrestamos(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Filtro: TFiltroPrestamo; Hoy: TDateTime; const Texto: string;
  Limite: Integer): TArray<TPrestamoFila>;
var
  Lista: TList<TPrestamoFila>;
  Desde, Hasta, Tope: Integer;
  Q: TFDQuery;
  F: TPrestamoFila;
  Cond, Sql: string;
begin
  Tope := LimiteValido(Limite);
  Lista := TList<TPrestamoFila>.Create;
  try
    Desde := 0;
    while Desde < Length(Nodos) do
    begin
      Hasta := Desde + NODOS_POR_CONSULTA - 1;
      if Hasta > High(Nodos) then
        Hasta := High(Nodos);
      Cond := CondicionFiltro(Filtro);
      Sql := 'SELECT TOP ' + IntToStr(Tope) + ' p.IdProceso, p.Anio, p.Consecutivo, ' +
        'p.Numero, p.Estado, p.Paso, p.Creado, r.Solicitante, r.Carnet, r.Entidad, ' +
        'r.TipoUsuario, r.FEntrega, r.FLimite, r.FDevolucion, r.AtendidoPor, r.Obs, ' +
        '(SELECT COUNT(*) FROM prc_unidad u WHERE u.IdProceso = p.IdProceso) AS Unidades ' +
        'FROM prc_proceso p INNER JOIN prc_prestamo r ON r.IdProceso = p.IdProceso ' +
        'WHERE p.Tipo = ''P'' AND (' + CondicionNodos('p.IdEstructura', 'p.IdNodo',
        Desde, Hasta) + ')';
      if Cond <> '' then
        Sql := Sql + ' AND (' + Cond + ')';
      if Trim(Texto) <> '' then
        Sql := Sql + ' AND (p.Numero LIKE :qt OR r.Solicitante LIKE :qt OR ' +
          'r.Entidad LIKE :qt)';
      Sql := Sql + ' ORDER BY p.Anio DESC, p.Consecutivo DESC';
      Q := TFDQuery.Create(nil);
      try
        Q.Connection := Conn;
        Q.SQL.Text := Sql;
        PonerNodos(Q, Nodos, Desde, Hasta);
        if Pos(':hoy', Cond) > 0 then
          Q.ParamByName('hoy').AsDateTime := Trunc(Hoy);
        if Trim(Texto) <> '' then
          Q.ParamByName('qt').AsString := '%' + Trim(Texto) + '%';
        Q.Open;
        while not Q.Eof do
        begin
          F.IdProceso := Q.FieldByName('IdProceso').AsInteger;
          F.Anio := Q.FieldByName('Anio').AsInteger;
          F.Consecutivo := Q.FieldByName('Consecutivo').AsInteger;
          F.Numero := Trim(Q.FieldByName('Numero').AsString);
          F.Solicitante := Q.FieldByName('Solicitante').AsString;
          F.Carnet := Q.FieldByName('Carnet').AsString;
          F.Entidad := Q.FieldByName('Entidad').AsString;
          F.AtendidoPor := Q.FieldByName('AtendidoPor').AsString;
          F.Obs := Q.FieldByName('Obs').AsString;
          F.Creado := FechaODefecto(Q.FieldByName('Creado'));
          if Trim(Q.FieldByName('TipoUsuario').AsString) = 'E' then
            F.Usuario := tuExterno
          else
            F.Usuario := tuInterno;
          F.Unidades := Q.FieldByName('Unidades').AsInteger;
          F.FEntrega := FechaODefecto(Q.FieldByName('FEntrega'));
          F.FLimite := FechaODefecto(Q.FieldByName('FLimite'));
          F.FDevolucion := FechaODefecto(Q.FieldByName('FDevolucion'));
          F.Paso := Q.FieldByName('Paso').AsInteger;
          F.Estado := EstadoDesdeCodigo(Q.FieldByName('Estado').AsString);
          F.Visible := EstadoDelPrestamo(F.Paso, F.Estado, F.FLimite, Hoy);
          Lista.Add(F);
          Q.Next;
        end;
      finally
        Q.Free;
      end;
      Desde := Hasta + 1;
    end;
    // Con varias consultas (muchos nodos) se reordena y se recorta al limite
    Lista.Sort(TComparer<TPrestamoFila>.Construct(
      function(const A, B: TPrestamoFila): Integer
      begin
        Result := B.Anio - A.Anio;
        if Result = 0 then
          Result := B.Consecutivo - A.Consecutivo;
      end));
    if Lista.Count > Tope then
      Lista.Count := Tope;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

function IndicadoresPrestamo(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Hoy: TDateTime): TIndicadoresPrestamo;
var
  Grupos: TList<TConteoGrupo>;
  G: TConteoGrupo;
  Desde, Hasta, DevAnio: Integer;
  Q: TFDQuery;
  Nodo, Estado: string;
  Resto: Integer;
begin
  Grupos := TList<TConteoGrupo>.Create;
  DevAnio := 0;
  try
    Desde := 0;
    while Desde < Length(Nodos) do
    begin
      Hasta := Desde + NODOS_POR_CONSULTA - 1;
      if Hasta > High(Nodos) then
        Hasta := High(Nodos);
      Nodo := CondicionNodos('p.IdEstructura', 'p.IdNodo', Desde, Hasta);
      // 1) abiertos: por paso y fecha limite (pocas filas)
      Q := TFDQuery.Create(nil);
      try
        Q.Connection := Conn;
        Q.SQL.Text := 'SELECT p.Paso, r.FLimite, COUNT(*) AS N FROM prc_proceso p ' +
          'INNER JOIN prc_prestamo r ON r.IdProceso = p.IdProceso ' +
          'WHERE p.Tipo = ''P'' AND p.Estado = ''C'' AND (' + Nodo + ') ' +
          'GROUP BY p.Paso, r.FLimite';
        PonerNodos(Q, Nodos, Desde, Hasta);
        Q.Open;
        while not Q.Eof do
        begin
          G.Paso := Q.FieldByName('Paso').AsInteger;
          G.Estado := epEnCurso;
          G.Limite := FechaODefecto(Q.FieldByName('FLimite'));
          G.Cantidad := Q.FieldByName('N').AsInteger;
          Grupos.Add(G);
          Q.Next;
        end;
      finally
        Q.Free;
      end;
      // 2) cerrados: solo por estado
      Q := TFDQuery.Create(nil);
      try
        Q.Connection := Conn;
        Q.SQL.Text := 'SELECT p.Estado, COUNT(*) AS N FROM prc_proceso p ' +
          'WHERE p.Tipo = ''P'' AND p.Estado <> ''C'' AND (' + Nodo + ') ' +
          'GROUP BY p.Estado';
        PonerNodos(Q, Nodos, Desde, Hasta);
        Q.Open;
        while not Q.Eof do
        begin
          Estado := Trim(Q.FieldByName('Estado').AsString);
          if Estado = 'F' then
          begin
            G.Paso := 3;
            G.Estado := epFinalizado;
            G.Limite := 0;
            G.Cantidad := Q.FieldByName('N').AsInteger;
            Grupos.Add(G);
          end;
          Q.Next;
        end;
      finally
        Q.Free;
      end;
      // 3) devueltos este ano
      Q := TFDQuery.Create(nil);
      try
        Q.Connection := Conn;
        Q.SQL.Text := 'SELECT COUNT(*) AS N FROM prc_proceso p ' +
          'INNER JOIN prc_prestamo r ON r.IdProceso = p.IdProceso ' +
          'WHERE p.Tipo = ''P'' AND p.Estado = ''F'' AND r.FDevolucion >= :ini ' +
          'AND r.FDevolucion < :fin AND (' + Nodo + ')';
        PonerNodos(Q, Nodos, Desde, Hasta);
        Q.ParamByName('ini').AsDateTime := EncodeDate(YearOf(Hoy), 1, 1);
        Q.ParamByName('fin').AsDateTime := EncodeDate(YearOf(Hoy) + 1, 1, 1);
        Q.Open;
        Resto := Q.FieldByName('N').AsInteger;
        Inc(DevAnio, Resto);
      finally
        Q.Free;
      end;
      Desde := Hasta + 1;
    end;
    Result := IndicadoresDesdeConteos(Grupos.ToArray, DevAnio, Hoy);
  finally
    Grupos.Free;
  end;
end;

{ Lee un documento de una consulta con las columnas de tb_SeriesDatos. }
procedure LeerDocumento(Q: TFDQuery; out D: TDocumentoBuscado);
begin
  D.Unidad.IdEstructura := Q.FieldByName('IdEstructura').AsString;
  D.Unidad.Id := Q.FieldByName('id').AsInteger;
  D.Unidad.CodSubs := Q.FieldByName('codsubs').AsString;
  D.Unidad.CodigoDoc := Q.FieldByName('Codigodoc').AsString;
  D.Unidad.Fecha := Q.FieldByName('fecha').AsDateTime;
  D.Unidad.Version := Q.FieldByName('version').AsString;
  D.Titulo := Q.FieldByName('titulodoc').AsString;
  D.Ubicacion := UbicacionDe(Q.FieldByName('deposito').AsString,
    Q.FieldByName('gaveta').AsString, Q.FieldByName('posicion').AsString);
  D.Bloqueado := False;
  D.Bloqueo.Tipo := tpPrestamo;
  D.Bloqueo.Numero := '';
end;

function BuscarDocumentos(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Alcance: TAlcanceUsuario; const Texto: string; Limite: Integer): TArray<TDocumentoBuscado>;
var
  Lista: TList<TDocumentoBuscado>;
  Desde, Hasta, Tope, I: Integer;
  Q: TFDQuery;
  D: TDocumentoBuscado;
  Filtro: TFiltroSql;
  Sql: string;
  Mapas: TObjectDictionary<string, TDictionary<string, TBloqueo>>;
  Mapa: TDictionary<string, TBloqueo>;
  ClaveNodo: string;
  B: TBloqueo;
  Nodo: TClaveNodo;
begin
  Tope := LimiteValido(Limite);
  Lista := TList<TDocumentoBuscado>.Create;
  Mapas := TObjectDictionary<string, TDictionary<string, TBloqueo>>.Create([doOwnsValues]);
  try
    Desde := 0;
    while (Desde < Length(Nodos)) and (Lista.Count < Tope) do
    begin
      Hasta := Desde + NODOS_POR_CONSULTA - 1;
      if Hasta > High(Nodos) then
        Hasta := High(Nodos);
      Filtro := FiltroDocumentos(Alcance, 'H');
      Sql := 'SELECT TOP ' + IntToStr(Tope - Lista.Count) + ' H.IdEstructura, H.id, ' +
        'H.codsubs, H.Codigodoc, H.fecha, H.version, H.titulodoc, H.deposito, ' +
        'H.gaveta, H.posicion FROM tb_SeriesDatos H WHERE (' + Filtro.Condicion +
        ') AND (' + CondicionNodos('H.IdEstructura', 'H.id', Desde, Hasta) + ')';
      if Trim(Texto) <> '' then
        Sql := Sql + ' AND (H.Codigodoc LIKE :qt OR H.titulodoc LIKE :qt)';
      Sql := Sql + ' ORDER BY H.titulodoc';
      Q := TFDQuery.Create(nil);
      try
        Q.Connection := Conn;
        Q.SQL.Text := Sql;
        PonerNodos(Q, Nodos, Desde, Hasta);
        AplicarParametros(Q, Filtro);
        if Trim(Texto) <> '' then
          Q.ParamByName('qt').AsString := '%' + Trim(Texto) + '%';
        Q.Open;
        while not Q.Eof do
        begin
          LeerDocumento(Q, D);
          Lista.Add(D);
          Q.Next;
        end;
      finally
        Q.Free;
      end;
      Desde := Hasta + 1;
    end;
    // Bloqueos: una consulta por nodo distinto del resultado (no por documento)
    for I := 0 to Lista.Count - 1 do
    begin
      D := Lista[I];
      ClaveNodo := NormalizaClave(D.Unidad.IdEstructura) + '|' + IntToStr(D.Unidad.Id);
      if not Mapas.TryGetValue(ClaveNodo, Mapa) then
      begin
        Nodo.IdEstructura := D.Unidad.IdEstructura;
        Nodo.Id := D.Unidad.Id;
        Mapa := BloqueosDelNodo(Conn, Nodo);
        Mapas.Add(ClaveNodo, Mapa);
      end;
      if Mapa.TryGetValue(ClaveUnidad(D.Unidad), B) then
      begin
        D.Bloqueado := True;
        D.Bloqueo := B;
        Lista[I] := D;
      end;
    end;
    Result := Lista.ToArray;
  finally
    Mapas.Free;
    Lista.Free;
  end;
end;

function DocumentosDelPrestamo(Conn: TFDConnection;
  IdProceso: Integer): TArray<TDocumentoBuscado>;
var
  Lista: TList<TDocumentoBuscado>;
  Q: TFDQuery;
  D: TDocumentoBuscado;
begin
  Lista := TList<TDocumentoBuscado>.Create;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := 'SELECT u.IdEstructura, u.id, u.codsubs, u.Codigodoc, u.fecha, ' +
        'u.version, H.titulodoc, H.deposito, H.gaveta, H.posicion ' +
        'FROM prc_unidad u LEFT JOIN tb_SeriesDatos H ON ' +
        'H.IdEstructura = u.IdEstructura AND H.id = u.id AND H.codsubs = u.codsubs ' +
        'AND H.Codigodoc = u.Codigodoc AND H.fecha = u.fecha AND H.version = u.version ' +
        'WHERE u.IdProceso = :i AND u.Activa <> 0 ORDER BY H.titulodoc';
      Q.ParamByName('i').AsInteger := IdProceso;
      Q.Open;
      while not Q.Eof do
      begin
        LeerDocumento(Q, D);
        Lista.Add(D);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    Result := Lista.ToArray;
  finally
    Lista.Free;
  end;
end;

end.
