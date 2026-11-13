unit UPrestamosMigracion;

{ ---------------------------------------------------------------------------
  Migracion de los prestamos de la pantalla vieja (TB_Prestamos y
  TB_PrestamosDocumentos) a las tablas de procesos (prc_proceso, prc_prestamo,
  prc_unidad, prc_bloqueo). Solo RTL + FireDAC: sin VCL ni TUDM.

    - Idempotente: un prestamo viejo ya migrado se reconoce por
      prc_prestamo.IdPrestamoViejo (junto con su nodo) y no se repite.
    - Las tablas viejas NO se modifican ni se borran.
    - Estado: con FDevolucion queda finalizado (paso 3); con solo FCancelacion,
      cancelado; en otro caso, entregado y en curso (paso 2). Si trae
      devolucion y cancelacion a la vez, gana la devolucion.
    - El ano y el numero salen de FPrestamo (consecutivo por ano, en orden de
      fecha); sin fecha se usa el ano en curso y se avisa.
    - Un documento que ya esta retenido por otro prestamo abierto no se vuelve a
      retener: se omite y se avisa (el candado es de un proceso a la vez).
    - Cada prestamo se migra en su propia transaccion: si uno falla se avisa y
      los demas siguen.
    - Sin tablas viejas devuelve todo en cero.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UProceso;

type
  TEstadoMigrado = record
    Paso: Integer;
    Estado: TEstadoProceso;
  end;

  TInformeMigracion = record
    Leidos: Integer;             // prestamos viejos encontrados
    Migrados: Integer;           // prestamos copiados en esta ejecucion
    SinDocumentos: Integer;      // de los migrados, los que no traian documentos
    DocumentosOmitidos: Integer; // documentos ya retenidos por otro prestamo abierto
    Avisos: TArray<string>;      // lo que no se pudo mapear o se omitio
  end;

{ Paso y estado con que se migra un prestamo viejo (pura). }
function EstadoMigrado(HayDevolucion, HayCancelacion: Boolean): TEstadoMigrado;

{ Copia los prestamos viejos que falten. EsSqlServer queda para diferencias
  futuras: hoy el SQL es el mismo en ambos motores. }
function MigrarPrestamosViejos(Conn: TFDConnection;
  EsSqlServer: Boolean): TInformeMigracion;

implementation

uses
  System.Generics.Collections, System.Variants, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Param, UAlcance, UCandados, UNumeracion, UProcesosDatos;

type
  TPrestamoViejo = record
    IdEstructura: string;
    Id: Integer;
    IdPrestamo, Prestamista, Estructura, Responsable, Obs: string;
    FPrestamo, FDevolucion, FCancelacion: TDateTime;
    HayPrestamo, HayDevolucion, HayCancelacion: Boolean;
  end;

function EstadoMigrado(HayDevolucion, HayCancelacion: Boolean): TEstadoMigrado;
begin
  if HayDevolucion then
  begin
    Result.Paso := 3;
    Result.Estado := epFinalizado;
  end
  else if HayCancelacion then
  begin
    Result.Paso := 1;
    Result.Estado := epCancelado;
  end
  else
  begin
    Result.Paso := 2;
    Result.Estado := epEnCurso;
  end;
end;

function CodigoEstado(E: TEstadoProceso): string;
begin
  case E of
    epFinalizado: Result := 'F';
    epCancelado: Result := 'X';
  else
    Result := 'C';
  end;
end;

{ Fecha o Null, para parametros tipados ftDateTime. }
function FechaONulo(Hay: Boolean; D: TDateTime): Variant;
begin
  if Hay then
    Result := D
  else
    Result := Null;
end;

function ClavePrestamo(const IdEstructura: string; Id: Integer;
  const IdPrestamo: string): string;
begin
  Result := NormalizaClave(IdEstructura) + '|' + IntToStr(Id) + '|' + Trim(IdPrestamo);
end;

procedure Aviso(var Informe: TInformeMigracion; const Texto: string);
begin
  SetLength(Informe.Avisos, Length(Informe.Avisos) + 1);
  Informe.Avisos[High(Informe.Avisos)] := Texto;
end;

function MigrarPrestamosViejos(Conn: TFDConnection;
  EsSqlServer: Boolean): TInformeMigracion;
var
  Migrados: TDictionary<string, Boolean>;
  Siguiente: TDictionary<Integer, Integer>;
  Docs: TObjectDictionary<string, TList<TUnidadDoc>>;
  Q: TFDQuery;
  Viejos: TList<TPrestamoViejo>;
  P: TPrestamoViejo;
  U: TUnidadDoc;
  Lista: TList<TUnidadDoc>;
  Anio, Cons, IdProceso, Omitidos: Integer;
  Est: TEstadoMigrado;
  Cerrado: Variant;
  Solicitante: string;
begin
  Result.Leidos := 0;
  Result.Migrados := 0;
  Result.SinDocumentos := 0;
  Result.DocumentosOmitidos := 0;
  Result.Avisos := nil;
  Viejos := TList<TPrestamoViejo>.Create;
  Migrados := TDictionary<string, Boolean>.Create;
  Siguiente := TDictionary<Integer, Integer>.Create;
  Docs := TObjectDictionary<string, TList<TUnidadDoc>>.Create([doOwnsValues]);
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      // Sin tablas viejas (base nueva o sin permiso): nada que migrar
      try
        Q.Open('SELECT IdEstructura, id, IdPrestamo, Prestamista, Estructura, ' +
          'Responsable, FPrestamo, FDevolucion, FCancelacion, OBS FROM TB_Prestamos ' +
          'ORDER BY FPrestamo, IdPrestamo');
      except
        Exit;
      end;
      while not Q.Eof do
      begin
        P.IdEstructura := Q.FieldByName('IdEstructura').AsString;
        P.Id := Q.FieldByName('id').AsInteger;
        P.IdPrestamo := Trim(Q.FieldByName('IdPrestamo').AsString);
        P.Prestamista := Trim(Q.FieldByName('Prestamista').AsString);
        P.Estructura := Trim(Q.FieldByName('Estructura').AsString);
        P.Responsable := Trim(Q.FieldByName('Responsable').AsString);
        P.Obs := Trim(Q.FieldByName('OBS').AsString);
        P.HayPrestamo := not Q.FieldByName('FPrestamo').IsNull;
        P.HayDevolucion := not Q.FieldByName('FDevolucion').IsNull;
        P.HayCancelacion := not Q.FieldByName('FCancelacion').IsNull;
        P.FPrestamo := 0;
        P.FDevolucion := 0;
        P.FCancelacion := 0;
        if P.HayPrestamo then
          P.FPrestamo := Q.FieldByName('FPrestamo').AsDateTime;
        if P.HayDevolucion then
          P.FDevolucion := Q.FieldByName('FDevolucion').AsDateTime;
        if P.HayCancelacion then
          P.FCancelacion := Q.FieldByName('FCancelacion').AsDateTime;
        Viejos.Add(P);
        Q.Next;
      end;
      Q.Close;
      Result.Leidos := Viejos.Count;
      if Viejos.Count = 0 then
        Exit;

      // ya migrados
      Q.Open('SELECT r.IdPrestamoViejo AS Viejo, p.IdEstructura AS Estr, p.IdNodo AS Nodo ' +
        'FROM prc_prestamo r INNER JOIN prc_proceso p ON p.IdProceso = r.IdProceso ' +
        'WHERE r.IdPrestamoViejo IS NOT NULL');
      while not Q.Eof do
      begin
        Migrados.AddOrSetValue(ClavePrestamo(Q.FieldByName('Estr').AsString,
          Q.FieldByName('Nodo').AsInteger, Q.FieldByName('Viejo').AsString), True);
        Q.Next;
      end;
      Q.Close;

      // ultimo consecutivo de cada ano
      Q.Open('SELECT Anio, MAX(Consecutivo) AS M FROM prc_proceso WHERE Tipo = ''P'' ' +
        'GROUP BY Anio');
      while not Q.Eof do
      begin
        Siguiente.AddOrSetValue(Q.FieldByName('Anio').AsInteger,
          Q.FieldByName('M').AsInteger + 1);
        Q.Next;
      end;
      Q.Close;

      // documentos de todos los prestamos viejos (una sola consulta)
      Q.Open('SELECT IdEstructura, id, IdPrestamo, codsubs, Codigodoc, fecha, version ' +
        'FROM TB_PrestamosDocumentos');
      while not Q.Eof do
      begin
        U.IdEstructura := Q.FieldByName('IdEstructura').AsString;
        U.Id := Q.FieldByName('id').AsInteger;
        U.CodSubs := Q.FieldByName('codsubs').AsString;
        U.CodigoDoc := Q.FieldByName('Codigodoc').AsString;
        U.Fecha := Q.FieldByName('fecha').AsDateTime;
        U.Version := Q.FieldByName('version').AsString;
        if not Docs.TryGetValue(ClavePrestamo(U.IdEstructura, U.Id,
          Q.FieldByName('IdPrestamo').AsString), Lista) then
        begin
          Lista := TList<TUnidadDoc>.Create;
          Docs.Add(ClavePrestamo(U.IdEstructura, U.Id,
            Q.FieldByName('IdPrestamo').AsString), Lista);
        end;
        Lista.Add(U);
        Q.Next;
      end;
      Q.Close;
    finally
      Q.Free;
    end;

    for P in Viejos do
    begin
      if Migrados.ContainsKey(ClavePrestamo(P.IdEstructura, P.Id, P.IdPrestamo)) then
        Continue;
      Est := EstadoMigrado(P.HayDevolucion, P.HayCancelacion);
      if P.HayPrestamo then
        Anio := StrToInt(FormatDateTime('yyyy', P.FPrestamo))
      else
      begin
        Anio := StrToInt(FormatDateTime('yyyy', Date));
        Aviso(Result, 'Prestamo ' + P.IdPrestamo + ': sin fecha de prestamo; se uso el ano en curso');
      end;
      if not Siguiente.TryGetValue(Anio, Cons) then
        Cons := 1;
      Siguiente.AddOrSetValue(Anio, Cons + 1);
      Solicitante := P.Prestamista;
      if Solicitante = '' then
      begin
        Solicitante := 'Sin nombre (migrado)';
        Aviso(Result, 'Prestamo ' + P.IdPrestamo + ': sin nombre de solicitante');
      end;
      if Est.Estado = epEnCurso then
        Cerrado := Null
      else if Est.Estado = epFinalizado then
        Cerrado := P.FDevolucion
      else
        Cerrado := P.FCancelacion;
      Omitidos := 0;
      Conn.StartTransaction;
      try
        Conn.ExecSQL('INSERT INTO prc_proceso (Tipo, Anio, Consecutivo, Numero, Estado, ' +
          'Paso, IdEstructura, IdNodo, Creado, CreadoPor, Cerrado) VALUES (''P'', :a, :c, ' +
          ':n, :e, :p, :ie, :in, :f, ''migracion'', :x)',
          [Anio, Cons, FormatearNumero(tpPrestamo, Anio, Cons), CodigoEstado(Est.Estado),
           Est.Paso, P.IdEstructura, P.Id, FechaONulo(P.HayPrestamo, P.FPrestamo), Cerrado],
          [ftInteger, ftInteger, ftString, ftString, ftInteger, ftString, ftInteger,
           ftDateTime, ftDateTime]);
        IdProceso := Integer(Conn.ExecSQLScalar('SELECT IdProceso FROM prc_proceso WHERE ' +
          'Tipo = ''P'' AND Anio = :a AND Consecutivo = :c', [Anio, Cons]));
        Conn.ExecSQL('INSERT INTO prc_prestamo (IdProceso, Solicitante, Entidad, ' +
          'TipoUsuario, FEntrega, FDevolucion, AtendidoPor, Obs, IdPrestamoViejo) ' +
          'VALUES (:i, :s, :e, ''I'', :fe, :fd, :u, :o, :v)',
          [IdProceso, Copy(Solicitante, 1, 150), Copy(P.Estructura, 1, 150),
           FechaONulo(P.HayPrestamo, P.FPrestamo), FechaONulo(P.HayDevolucion, P.FDevolucion),
           Copy(P.Responsable, 1, 100), Copy(P.Obs, 1, 255), P.IdPrestamo],
          [ftInteger, ftString, ftString, ftDateTime, ftDateTime, ftString, ftString,
           ftString]);
        if Docs.TryGetValue(ClavePrestamo(P.IdEstructura, P.Id, P.IdPrestamo), Lista) then
        begin
          for U in Lista do
          begin
            if Est.Estado = epEnCurso then
            begin
              if Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_bloqueo WHERE ' +
                'IdEstructura = :e AND id = :i AND codsubs = :s AND Codigodoc = :c ' +
                'AND fecha = :f AND version = :v',
                [U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version])) > 0 then
              begin
                Inc(Omitidos);
                Aviso(Result, 'Prestamo ' + P.IdPrestamo + ': el documento ' + U.CodigoDoc +
                  ' ya esta retenido por otro prestamo abierto; se omitio');
                Continue;
              end;
              Conn.ExecSQL('INSERT INTO prc_bloqueo (IdEstructura, id, codsubs, ' +
                'Codigodoc, fecha, version, IdProceso) VALUES (:e, :i, :s, :c, :f, :v, :p)',
                [U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version, IdProceso]);
            end;
            Conn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, ' +
              'Codigodoc, fecha, version, Activa) VALUES (:p, :e, :i, :s, :c, :f, :v, :a)',
              [IdProceso, U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version,
               True]);
          end;
        end
        else
          Inc(Result.SinDocumentos);
        Conn.ExecSQL('INSERT INTO prc_evento (IdProceso, Fecha, Usuario, Paso, Texto) ' +
          'VALUES (:i, :f, ''migracion'', :p, :t)',
          [IdProceso, Now, Est.Paso, 'Migrado del prestamo ' + P.IdPrestamo]);
        Conn.Commit;
        Inc(Result.Migrados);
        Inc(Result.DocumentosOmitidos, Omitidos);
      except
        on E: Exception do
        begin
          if Conn.InTransaction then
            Conn.Rollback;
          // el consecutivo reservado se pierde: no importa, solo deja un hueco
          Aviso(Result, 'Prestamo ' + P.IdPrestamo + ' no migrado: ' + E.Message);
        end;
      end;
    end;
  finally
    Docs.Free;
    Siguiente.Free;
    Migrados.Free;
    Viejos.Free;
  end;
end;

end.
