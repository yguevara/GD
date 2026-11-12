unit UProcesosDatos;

{ ---------------------------------------------------------------------------
  Acceso a datos de los procesos archivisticos (prestamo, transferencia,
  depuracion). Solo RTL + FireDAC: sin VCL ni TUDM.

  Todas las operaciones usan parametros y SQL valido en SQL Server y Access.
  Las que escriben van en transaccion; si el llamador ya abrio una, se usa esa
  (no se anidan).

  Reglas que aplica (las define UProceso, UCandados y UAutorizacion):
    - un proceso solo avanza si se cumplen las condiciones de su paso;
    - dos usuarios que leyeron el mismo paso no pueden avanzarlo los dos
      (el UPDATE exige Paso = el leido y comprueba que cambio una fila);
    - un documento solo puede estar en un proceso abierto: lo garantiza la clave
      primaria de prc_bloqueo, no solo una consulta previa;
    - al finalizar o cancelar un proceso sus documentos quedan libres.

  Los IdEstructura se guardan y comparan tal como estan en tb_tree (el llamador
  los lee de la base); la clave en memoria (ClaveUnidad) si es tolerante a
  mayusculas y espacios.
  Diseno: docs/superpowers/specs/2026-11-12-prestamos-transferencias-
  depuracion-design.md (secciones 4 y 8).
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  UAlcance, UProceso, UAutorizacion, UCandados;

type
  { La autorizacion no cumple las reglas de UAutorizacion; el mensaje es el del
    primer error. }
  EAutorizacionInvalida = class(Exception);

  TProcesoRef = record
    IdProceso: Integer;
    Numero: string;
  end;

{ Codigos guardados en la base. TipoDesdeCodigo lanza EArgumentException con un
  codigo desconocido. }
function CodigoTipo(Tipo: TTipoProceso): string;
function TipoDesdeCodigo(const Codigo: string): TTipoProceso;
function CodigoOrgano(Organo: TOrganoComision): string;

{ Crea un proceso en el paso 1 con el siguiente consecutivo del tipo y del ano
  (reintenta si otro usuario toma el mismo numero a la vez) y escribe el primer
  evento. Nodo es el nodo remitente, tal como esta en tb_tree. }
function CrearProceso(Conn: TFDConnection; Tipo: TTipoProceso;
  const Nodo: TClaveNodo; const Usuario: string; Anio: Integer): TProcesoRef;

{ Avanza un paso. PasoLeido es el paso que el usuario vio en pantalla. Devuelve
  False si faltan condiciones (Faltan las lista), si el proceso ya no esta en
  curso o si otro usuario ya lo avanzo. En el ultimo paso finaliza el proceso. }
function AvanzarPaso(Conn: TFDConnection; IdProceso, PasoLeido: Integer;
  Cumplidas: TCondiciones; const Usuario: string;
  out Faltan: TCondiciones): Boolean;

{ Cancela el proceso si PuedeCancelar lo permite en su paso actual; libera sus
  documentos y registra el motivo. False si no se puede o ya no esta en curso. }
function CancelarProceso(Conn: TFDConnection; IdProceso: Integer;
  const Usuario, Motivo: string): Boolean;

procedure RegistrarEvento(Conn: TFDConnection; IdProceso: Integer;
  const Usuario, Texto: string);

{ Guarda (reemplazando la anterior) el acta y acuerdo del proceso. Lanza
  EAutorizacionInvalida si no cumple las reglas del tipo de proceso. }
procedure GuardarAutorizacion(Conn: TFDConnection; IdProceso: Integer;
  const A: TAutorizacion; const Usuario: string);

{ Agrega un documento al proceso si nadie mas lo retiene. Si esta retenido
  devuelve False y Motivo dice quien ("En prestamo 2026-0047"). }
function AgregarUnidad(Conn: TFDConnection; IdProceso: Integer;
  const U: TUnidadDoc; out Motivo: string): Boolean;

{ Documentos retenidos del nodo, indexados por ClaveUnidad. UNA sola consulta
  (para marcar filas de una lista sin consultar por fila). El llamador libera
  el diccionario. }
function BloqueosDelNodo(Conn: TFDConnection;
  const Nodo: TClaveNodo): TDictionary<string, TBloqueo>;

{ Cantidad de procesos del tipo para los nodos dados: [en curso, finalizados,
  cancelados]. Una consulta por cada 200 nodos. }
function ContarPorEstado(Conn: TFDConnection; Tipo: TTipoProceso;
  const Nodos: TArray<TClaveNodo>): TArray<Integer>;

implementation

uses
  System.Variants, Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Param,
  FireDAC.Stan.Error, UErroresCampo, UNumeracion;

const
  MAX_REINTENTOS_NUMERO = 3;
  NODOS_POR_CONSULTA = 200;
  LARGO_TEXTO_EVENTO = 255; // el limite de Access

{ ------------------------------ codigos ---------------------------------- }

function CodigoTipo(Tipo: TTipoProceso): string;
begin
  case Tipo of
    tpPrestamo: Result := 'P';
    tpTransferencia: Result := 'T';
  else
    Result := 'D';
  end;
end;

function TipoDesdeCodigo(const Codigo: string): TTipoProceso;
begin
  if Codigo = 'P' then
    Result := tpPrestamo
  else if Codigo = 'T' then
    Result := tpTransferencia
  else if Codigo = 'D' then
    Result := tpDepuracion
  else
    raise EArgumentException.Create('Tipo de proceso desconocido: ' + Codigo);
end;

function CodigoOrgano(Organo: TOrganoComision): string;
begin
  case Organo of
    ocCentral: Result := 'C';
    ocMunicipal: Result := 'M';
    ocProvincial: Result := 'P';
  else
    Result := 'N';
  end;
end;

{ ---------------------------- transacciones ------------------------------ }

{ True si esta llamada abrio la transaccion (y por tanto debe cerrarla). }
function IniciarTx(Conn: TFDConnection): Boolean;
begin
  Result := not Conn.InTransaction;
  if Result then
    Conn.StartTransaction;
end;

procedure ConfirmarTx(Conn: TFDConnection; Propia: Boolean);
begin
  if Propia then
    Conn.Commit;
end;

procedure DeshacerTx(Conn: TFDConnection; Propia: Boolean);
begin
  if Propia and Conn.InTransaction then
    Conn.Rollback;
end;

{ ------------------------------ auxiliares ------------------------------- }

procedure EscribirEvento(Conn: TFDConnection; IdProceso, Paso: Integer;
  const Usuario, Texto: string);
begin
  Conn.ExecSQL('INSERT INTO prc_evento (IdProceso, Fecha, Usuario, Paso, Texto) ' +
    'VALUES (:i, :f, :u, :p, :t)',
    [IdProceso, Now, Usuario, Paso, Copy(Texto, 1, LARGO_TEXTO_EVENTO)]);
end;

{ Lee tipo, paso y estado del proceso. False si no existe. }
function LeerProceso(Conn: TFDConnection; IdProceso: Integer;
  out Tipo: TTipoProceso; out Paso: Integer; out Estado: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT Tipo, Paso, Estado FROM prc_proceso WHERE IdProceso = :i';
    Q.ParamByName('i').AsInteger := IdProceso;
    Q.Open;
    Result := not Q.IsEmpty;
    if Result then
    begin
      Tipo := TipoDesdeCodigo(Trim(Q.FieldByName('Tipo').AsString));
      Paso := Q.FieldByName('Paso').AsInteger;
      Estado := Trim(Q.FieldByName('Estado').AsString);
    end
    else
    begin
      Tipo := tpPrestamo;
      Paso := 0;
      Estado := '';
    end;
  finally
    Q.Free;
  end;
end;

procedure LiberarBloqueos(Conn: TFDConnection; IdProceso: Integer);
begin
  Conn.ExecSQL('DELETE FROM prc_bloqueo WHERE IdProceso = :i', [IdProceso]);
end;

{ Proceso que retiene el documento, si lo hay. }
function BuscarBloqueo(Conn: TFDConnection; const U: TUnidadDoc;
  out B: TBloqueo): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT p.Tipo, p.Numero FROM prc_bloqueo b ' +
      'INNER JOIN prc_proceso p ON p.IdProceso = b.IdProceso ' +
      'WHERE b.IdEstructura = :e AND b.id = :i AND b.codsubs = :s AND b.Codigodoc = :c ' +
      'AND b.fecha = :f AND b.version = :v';
    Q.ParamByName('e').AsString := U.IdEstructura;
    Q.ParamByName('i').AsInteger := U.Id;
    Q.ParamByName('s').AsString := U.CodSubs;
    Q.ParamByName('c').AsString := U.CodigoDoc;
    Q.ParamByName('f').AsDateTime := U.Fecha;
    Q.ParamByName('v').AsString := U.Version;
    Q.Open;
    Result := not Q.IsEmpty;
    if Result then
    begin
      B.Tipo := TipoDesdeCodigo(Trim(Q.FieldByName('Tipo').AsString));
      B.Numero := Trim(Q.FieldByName('Numero').AsString);
    end;
  finally
    Q.Free;
  end;
end;

{ ------------------------------- procesos -------------------------------- }

function CrearProceso(Conn: TFDConnection; Tipo: TTipoProceso;
  const Nodo: TClaveNodo; const Usuario: string; Anio: Integer): TProcesoRef;
var
  Intento, Consecutivo: Integer;
  Propia: Boolean;
  V: Variant;
  Numero: string;
begin
  Result.IdProceso := 0;
  Result.Numero := '';
  for Intento := 1 to MAX_REINTENTOS_NUMERO do
  begin
    Propia := IniciarTx(Conn);
    try
      V := Conn.ExecSQLScalar('SELECT MAX(Consecutivo) FROM prc_proceso ' +
        'WHERE Tipo = :t AND Anio = :a', [CodigoTipo(Tipo), Anio]);
      if VarIsNull(V) or VarIsEmpty(V) then
        Consecutivo := 1
      else
        Consecutivo := Integer(V) + 1;
      Numero := FormatearNumero(Tipo, Anio, Consecutivo);
      Conn.ExecSQL('INSERT INTO prc_proceso (Tipo, Anio, Consecutivo, Numero, ' +
        'Estado, Paso, IdEstructura, IdNodo, Creado, CreadoPor) ' +
        'VALUES (:t, :a, :c, :n, ''C'', 1, :e, :i, :f, :u)',
        [CodigoTipo(Tipo), Anio, Consecutivo, Numero, Nodo.IdEstructura,
         Nodo.Id, Now, Usuario]);
      V := Conn.ExecSQLScalar('SELECT IdProceso FROM prc_proceso WHERE Tipo = :t ' +
        'AND Anio = :a AND Consecutivo = :c', [CodigoTipo(Tipo), Anio, Consecutivo]);
      Result.IdProceso := Integer(V);
      Result.Numero := Numero;
      EscribirEvento(Conn, Result.IdProceso, 1, Usuario, 'Proceso creado ' + Numero);
      ConfirmarTx(Conn, Propia);
      Exit;
    except
      on E: EFDDBEngineException do
      begin
        DeshacerTx(Conn, Propia);
        // Solo se reintenta si otro usuario tomo el mismo numero y la
        // transaccion es nuestra (dentro de una ajena ya no se puede repetir).
        if (Intento >= MAX_REINTENTOS_NUMERO) or (not Propia) or
          (E.Kind <> ekUKViolated) then
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

function AvanzarPaso(Conn: TFDConnection; IdProceso, PasoLeido: Integer;
  Cumplidas: TCondiciones; const Usuario: string;
  out Faltan: TCondiciones): Boolean;
var
  Tipo: TTipoProceso;
  Paso, Filas: Integer;
  Estado: string;
  Propia, Ultimo: Boolean;
begin
  Faltan := [];
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) then
    Exit;
  // Otro usuario ya lo avanzo, lo cancelo o lo finalizo
  if (Estado <> 'C') or (Paso <> PasoLeido) then
    Exit;
  if not PuedeAvanzar(Tipo, Paso, Cumplidas, Faltan) then
    Exit;
  Ultimo := Paso >= NumeroPasos(Tipo);
  Propia := IniciarTx(Conn);
  try
    if Ultimo then
      Filas := Conn.ExecSQL('UPDATE prc_proceso SET Estado = ''F'', Cerrado = :c ' +
        'WHERE IdProceso = :i AND Paso = :p AND Estado = ''C''', [Now, IdProceso, Paso])
    else
      Filas := Conn.ExecSQL('UPDATE prc_proceso SET Paso = Paso + 1 ' +
        'WHERE IdProceso = :i AND Paso = :p AND Estado = ''C''', [IdProceso, Paso]);
    if Filas <> 1 then
    begin
      DeshacerTx(Conn, Propia);
      Exit;
    end;
    if Ultimo then
    begin
      LiberarBloqueos(Conn, IdProceso);
      EscribirEvento(Conn, IdProceso, Paso, Usuario, 'Proceso finalizado');
    end
    else
      EscribirEvento(Conn, IdProceso, Paso, Usuario,
        'Paso ' + IntToStr(Paso) + ' completado');
    ConfirmarTx(Conn, Propia);
    Result := True;
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

function CancelarProceso(Conn: TFDConnection; IdProceso: Integer;
  const Usuario, Motivo: string): Boolean;
var
  Tipo: TTipoProceso;
  Paso, Filas: Integer;
  Estado: string;
  Propia: Boolean;
begin
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) then
    Exit;
  if (Estado <> 'C') or not PuedeCancelar(Tipo, Paso) then
    Exit;
  Propia := IniciarTx(Conn);
  try
    Filas := Conn.ExecSQL('UPDATE prc_proceso SET Estado = ''X'', Cerrado = :c ' +
      'WHERE IdProceso = :i AND Paso = :p AND Estado = ''C''', [Now, IdProceso, Paso]);
    if Filas <> 1 then
    begin
      DeshacerTx(Conn, Propia);
      Exit;
    end;
    LiberarBloqueos(Conn, IdProceso);
    EscribirEvento(Conn, IdProceso, Paso, Usuario, 'Cancelado: ' + Motivo);
    ConfirmarTx(Conn, Propia);
    Result := True;
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

procedure RegistrarEvento(Conn: TFDConnection; IdProceso: Integer;
  const Usuario, Texto: string);
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
begin
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) then
    raise EArgumentException.Create('El proceso no existe: ' + IntToStr(IdProceso));
  EscribirEvento(Conn, IdProceso, Paso, Usuario, Texto);
end;

procedure GuardarAutorizacion(Conn: TFDConnection; IdProceso: Integer;
  const A: TAutorizacion; const Usuario: string);
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  Errores: TArray<TErrorCampo>;
  Propia: Boolean;
begin
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) then
    raise EArgumentException.Create('El proceso no existe: ' + IntToStr(IdProceso));
  Errores := ValidarAutorizacion(Tipo, A, Date);
  if Length(Errores) > 0 then
    raise EAutorizacionInvalida.Create(Errores[0].Mensaje);
  Propia := IniciarTx(Conn);
  try
    Conn.ExecSQL('DELETE FROM prc_autorizacion WHERE IdProceso = :i', [IdProceso]);
    Conn.ExecSQL('INSERT INTO prc_autorizacion (IdProceso, Organo, NumActa, ' +
      'NumAcuerdo, Fecha, RegistradoPor) VALUES (:i, :o, :a, :c, :f, :u)',
      [IdProceso, CodigoOrgano(A.Organo), Trim(A.NumActa), Trim(A.NumAcuerdo),
       A.Fecha, Usuario]);
    EscribirEvento(Conn, IdProceso, Paso, Usuario, 'Autorizacion registrada: acta ' +
      Trim(A.NumActa) + ', acuerdo ' + Trim(A.NumAcuerdo));
    ConfirmarTx(Conn, Propia);
  except
    DeshacerTx(Conn, Propia);
    raise;
  end;
end;

{ ------------------------------- unidades -------------------------------- }

function AgregarUnidad(Conn: TFDConnection; IdProceso: Integer;
  const U: TUnidadDoc; out Motivo: string): Boolean;
var
  Tipo: TTipoProceso;
  Paso: Integer;
  Estado: string;
  B: TBloqueo;
  Propia: Boolean;
begin
  Motivo := '';
  Result := False;
  if not LeerProceso(Conn, IdProceso, Tipo, Paso, Estado) then
    raise EArgumentException.Create('El proceso no existe: ' + IntToStr(IdProceso));
  if Estado <> 'C' then
  begin
    Motivo := 'El proceso ya no esta en curso';
    Exit;
  end;
  if BuscarBloqueo(Conn, U, B) then
  begin
    PuedeEntrar(B, True, Motivo);
    Exit;
  end;
  Propia := IniciarTx(Conn);
  try
    Conn.ExecSQL('INSERT INTO prc_bloqueo (IdEstructura, id, codsubs, Codigodoc, ' +
      'fecha, version, IdProceso) VALUES (:e, :i, :s, :c, :f, :v, :p)',
      [U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version, IdProceso]);
    Conn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, ' +
      'Codigodoc, fecha, version, Activa) VALUES (:p, :e, :i, :s, :c, :f, :v, :a)',
      [IdProceso, U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version,
       True]);
    ConfirmarTx(Conn, Propia);
    Result := True;
  except
    on E: EFDDBEngineException do
    begin
      DeshacerTx(Conn, Propia);
      // Otro usuario lo retuvo entre la consulta y el insert: lo dice la clave
      if E.Kind <> ekUKViolated then
        raise;
      if BuscarBloqueo(Conn, U, B) then
        PuedeEntrar(B, True, Motivo)
      else
        Motivo := 'El documento esta retenido por otro proceso';
    end;
    on Exception do
    begin
      DeshacerTx(Conn, Propia);
      raise;
    end;
  end;
end;

function BloqueosDelNodo(Conn: TFDConnection;
  const Nodo: TClaveNodo): TDictionary<string, TBloqueo>;
var
  Q: TFDQuery;
  U: TUnidadDoc;
  B: TBloqueo;
begin
  Result := TDictionary<string, TBloqueo>.Create;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := 'SELECT b.IdEstructura, b.id, b.codsubs, b.Codigodoc, b.fecha, b.version, ' +
        'p.Tipo, p.Numero FROM prc_bloqueo b ' +
        'INNER JOIN prc_proceso p ON p.IdProceso = b.IdProceso ' +
        'WHERE b.IdEstructura = :e AND b.id = :i';
      Q.ParamByName('e').AsString := Nodo.IdEstructura;
      Q.ParamByName('i').AsInteger := Nodo.Id;
      Q.Open;
      while not Q.Eof do
      begin
        U.IdEstructura := Q.FieldByName('IdEstructura').AsString;
        U.Id := Q.FieldByName('id').AsInteger;
        U.CodSubs := Q.FieldByName('codsubs').AsString;
        U.CodigoDoc := Q.FieldByName('Codigodoc').AsString;
        U.Fecha := Q.FieldByName('fecha').AsDateTime;
        U.Version := Q.FieldByName('version').AsString;
        B.Tipo := TipoDesdeCodigo(Trim(Q.FieldByName('Tipo').AsString));
        B.Numero := Trim(Q.FieldByName('Numero').AsString);
        Result.AddOrSetValue(ClaveUnidad(U), B);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function ContarPorEstado(Conn: TFDConnection; Tipo: TTipoProceso;
  const Nodos: TArray<TClaveNodo>): TArray<Integer>;
var
  Desde, Hasta, I: Integer;
  Q: TFDQuery;
  Condicion, Estado: string;
begin
  SetLength(Result, 3);
  Result[0] := 0;
  Result[1] := 0;
  Result[2] := 0;
  Desde := 0;
  while Desde < Length(Nodos) do
  begin
    Hasta := Desde + NODOS_POR_CONSULTA - 1;
    if Hasta > High(Nodos) then
      Hasta := High(Nodos);
    Condicion := '';
    for I := Desde to Hasta do
    begin
      if Condicion <> '' then
        Condicion := Condicion + ' OR ';
      Condicion := Condicion + '(IdEstructura = :e' + IntToStr(I - Desde) +
        ' AND IdNodo = :i' + IntToStr(I - Desde) + ')';
    end;
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := 'SELECT Estado, COUNT(*) AS N FROM prc_proceso WHERE Tipo = :t ' +
        'AND (' + Condicion + ') GROUP BY Estado';
      Q.ParamByName('t').AsString := CodigoTipo(Tipo);
      for I := Desde to Hasta do
      begin
        Q.ParamByName('e' + IntToStr(I - Desde)).AsString := Nodos[I].IdEstructura;
        Q.ParamByName('i' + IntToStr(I - Desde)).AsInteger := Nodos[I].Id;
      end;
      Q.Open;
      while not Q.Eof do
      begin
        Estado := Trim(Q.FieldByName('Estado').AsString);
        if Estado = 'C' then
          Inc(Result[0], Q.FieldByName('N').AsInteger)
        else if Estado = 'F' then
          Inc(Result[1], Q.FieldByName('N').AsInteger)
        else if Estado = 'X' then
          Inc(Result[2], Q.FieldByName('N').AsInteger);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    Desde := Hasta + 1;
  end;
end;

end.
