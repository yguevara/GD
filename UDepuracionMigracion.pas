unit UDepuracionMigracion;

{ ---------------------------------------------------------------------------
  Migracion de lo ya depurado en la pantalla vieja (tb_depuracion, filas con
  depurado = 1 y destino 3 = Eliminarlo) a procesos de depuracion finalizados
  (prc_proceso 'D', prc_depuracion, prc_unidad), para que esos documentos figuren
  como eliminados (UEliminados). Solo RTL + FireDAC: sin VCL ni TUDM.

    - Un proceso por fecha de depuracion y nodo; el numero sigue a UNumeracion.
    - Cada proceso lleva Lugar = 'MIGRADA tb_depuracion <fecha> <estructura>/<nodo>':
      esa marca hace la migracion idempotente.
    - Paso 5, finalizado, sin candados; no hay acta, testigos ni autorizacion.
    - Un documento que ya es eliminado por otra depuracion no se vuelve a marcar (la
      consulta lo deja fuera, sin aviso).
    - Las filas depuradas con otro destino (conservar, etc.) no se migran ni se cuentan.
    - tb_depuracion no se modifica ni se borra; sin esa tabla devuelve todo en cero.
    - Cada proceso se migra en su propia transaccion.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UPrestamosMigracion;

{ Reutiliza TInformeMigracion: Leidos = documentos depurados como Eliminarlo,
  Migrados = procesos creados, DocumentosOmitidos, Avisos. }
function MigrarDepuracionesViejas(Conn: TFDConnection): TInformeMigracion;

implementation

uses
  System.Generics.Collections, System.Variants, Data.DB, FireDAC.Stan.Param, UCandados,
  UProceso, UNumeracion;

const
  MARCA = 'MIGRADA tb_depuracion ';

type
  TGrupoViejo = class
    Fecha: TDateTime;
    HayFecha: Boolean;
    IdEstructura: string;
    Nodo: Integer;
    Docs: TList<TUnidadDoc>;
    constructor Create;
    destructor Destroy; override;
  end;

constructor TGrupoViejo.Create;
begin
  inherited Create;
  Docs := TList<TUnidadDoc>.Create;
end;

destructor TGrupoViejo.Destroy;
begin
  Docs.Free;
  inherited;
end;

function FechaONulo(Hay: Boolean; D: TDateTime): Variant;
begin
  if Hay then
    Result := D
  else
    Result := Null;
end;

procedure Aviso(var Informe: TInformeMigracion; const Texto: string);
begin
  SetLength(Informe.Avisos, Length(Informe.Avisos) + 1);
  Informe.Avisos[High(Informe.Avisos)] := Texto;
end;

function MarcaDe(G: TGrupoViejo): string;
begin
  if G.HayFecha then
    Result := FormatDateTime('yyyy-mm-dd', G.Fecha)
  else
    Result := 'sin-fecha';
  Result := MARCA + Result + ' ' + Trim(G.IdEstructura) + '/' + IntToStr(G.Nodo);
end;

function MigrarDepuracionesViejas(Conn: TFDConnection): TInformeMigracion;
var
  Q: TFDQuery;
  Grupos: TObjectDictionary<string, TGrupoViejo>;
  Orden: TList<string>;
  Hechos: TDictionary<string, Boolean>;
  G: TGrupoViejo;
  K: string;
  U: TUnidadDoc;
  Utiles: TList<TUnidadDoc>;
  F: TDateTime;
  HayF: Boolean;
  Anio, Cons, IdProceso, Otros: Integer;
begin
  Result.Leidos := 0;
  Result.Migrados := 0;
  Result.SinDocumentos := 0;
  Result.DocumentosOmitidos := 0;
  Result.Avisos := nil;
  Grupos := TObjectDictionary<string, TGrupoViejo>.Create([doOwnsValues]);
  Orden := TList<string>.Create;
  Hechos := TDictionary<string, Boolean>.Create;
  Utiles := TList<TUnidadDoc>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    try
      Q.Open('SELECT IdEstructura, id, codsubs, Codigodoc, fecha, version, fechadepuracion ' +
        'FROM tb_depuracion d WHERE d.depurado = 1 AND d.destino = 3 AND NOT EXISTS ' +
        '(SELECT 1 FROM prc_unidad u INNER JOIN prc_proceso p ON p.IdProceso = u.IdProceso ' +
        'WHERE p.Tipo = ''D'' AND p.Estado <> ''X'' AND p.Paso >= 5 AND u.Activa <> 0 AND ' +
        'u.IdEstructura = d.IdEstructura AND u.id = d.id AND u.codsubs = d.codsubs AND ' +
        'u.Codigodoc = d.Codigodoc AND u.fecha = d.fecha AND u.version = d.version) ' +
        'ORDER BY d.fechadepuracion, d.IdEstructura, d.id');
    except
      Exit;   // sin la tabla vieja: nada que migrar
    end;
    while not Q.Eof do
    begin
      HayF := not Q.FieldByName('fechadepuracion').IsNull;
      if HayF then
        F := Trunc(Q.FieldByName('fechadepuracion').AsDateTime)
      else
        F := 0;
      U.IdEstructura := Q.FieldByName('IdEstructura').AsString;
      U.Id := Q.FieldByName('id').AsInteger;
      U.CodSubs := Q.FieldByName('codsubs').AsString;
      U.CodigoDoc := Q.FieldByName('Codigodoc').AsString;
      U.Fecha := Q.FieldByName('fecha').AsDateTime;
      U.Version := Q.FieldByName('version').AsString;
      if HayF then
        K := FormatDateTime('yyyymmdd', F)
      else
        K := 'sin-fecha';
      K := K + '|' + Trim(U.IdEstructura) + '|' + IntToStr(U.Id);
      if not Grupos.TryGetValue(K, G) then
      begin
        G := TGrupoViejo.Create;
        G.Fecha := F;
        G.HayFecha := HayF;
        G.IdEstructura := U.IdEstructura;
        G.Nodo := U.Id;
        Grupos.Add(K, G);
        Orden.Add(K);
      end;
      G.Docs.Add(U);
      Inc(Result.Leidos);
      Q.Next;
    end;
    Q.Close;
    if Result.Leidos = 0 then
      Exit;

    // grupos ya migrados
    Q.Open('SELECT Lugar FROM prc_depuracion WHERE Lugar LIKE ''' + MARCA + '%''');
    while not Q.Eof do
    begin
      Hechos.AddOrSetValue(Trim(Q.FieldByName('Lugar').AsString), True);
      Q.Next;
    end;
    Q.Close;

    for K in Orden do
    begin
      G := Grupos[K];
      if Hechos.ContainsKey(MarcaDe(G)) then
        Continue;
      // la consulta ya dejo fuera lo que otra depuracion elimina (una sola consulta,
      // sin una por documento)
      Utiles.Clear;
      Utiles.AddRange(G.Docs);
      Otros := 0;
      if G.HayFecha then
        Anio := StrToInt(FormatDateTime('yyyy', G.Fecha))
      else
      begin
        Anio := StrToInt(FormatDateTime('yyyy', Date));
        Aviso(Result, 'Documentos del nodo ' + Trim(G.IdEstructura) + '/' + IntToStr(G.Nodo) +
          ' depurados sin fecha: se uso el ano en curso');
      end;
      Conn.StartTransaction;
      try
        // la marca se vuelve a mirar DENTRO de la transaccion y con candado: si otro puesto
        // arranca a la vez y migra el mismo grupo, el segundo espera y no lo duplica
        if Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM prc_depuracion WITH (UPDLOCK, ' +
          'HOLDLOCK) WHERE Lugar = :l', [Copy(MarcaDe(G), 1, 255)])) > 0 then
        begin
          Conn.Rollback;
          Continue;
        end;
        Cons := Integer(Conn.ExecSQLScalar('SELECT COALESCE(MAX(Consecutivo), 0) + 1 FROM ' +
          'prc_proceso WHERE Tipo = ''D'' AND Anio = :a', [Anio]));
        Conn.ExecSQL('INSERT INTO prc_proceso (Tipo, Anio, Consecutivo, Numero, Estado, ' +
          'Paso, IdEstructura, IdNodo, Creado, CreadoPor, Cerrado) VALUES (''D'', :a, :c, ' +
          ':n, ''F'', 5, :ie, :in, :f, ''migracion'', :x)',
          [Anio, Cons, FormatearNumero(tpDepuracion, Anio, Cons), G.IdEstructura, G.Nodo,
           FechaONulo(G.HayFecha, G.Fecha), FechaONulo(G.HayFecha, G.Fecha)],
          [ftInteger, ftInteger, ftString, ftString, ftInteger, ftDateTime, ftDateTime]);
        IdProceso := Integer(Conn.ExecSQLScalar('SELECT IdProceso FROM prc_proceso WHERE ' +
          'Tipo = ''D'' AND Anio = :a AND Consecutivo = :c', [Anio, Cons]));
        Conn.ExecSQL('INSERT INTO prc_depuracion (IdProceso, Lugar, FEjecucion, MuestraDesc, ' +
          'MuestraDonde) VALUES (:i, :l, :f, ''Depuracion anterior al proceso actual'', ' +
          '''No registrada'')',
          [IdProceso, Copy(MarcaDe(G), 1, 255), FechaONulo(G.HayFecha, G.Fecha)],
          [ftInteger, ftString, ftDateTime]);
        for U in Utiles do
          Conn.ExecSQL('INSERT INTO prc_unidad (IdProceso, IdEstructura, id, codsubs, ' +
            'Codigodoc, fecha, version, Activa) VALUES (:p, :e, :i, :s, :c, :f, :v, :a)',
            [IdProceso, U.IdEstructura, U.Id, U.CodSubs, U.CodigoDoc, U.Fecha, U.Version,
             True]);
        Conn.ExecSQL('INSERT INTO prc_evento (IdProceso, Fecha, Usuario, Paso, Texto) ' +
          'VALUES (:i, :f, ''migracion'', 5, :t)',
          [IdProceso, Now, 'Migrado de tb_depuracion (' + IntToStr(Utiles.Count) +
          ' documentos)']);
        Conn.Commit;
        Inc(Result.Migrados);
      except
        on E: Exception do
        begin
          if Conn.InTransaction then
            Conn.Rollback;
          Aviso(Result, 'Nodo ' + Trim(G.IdEstructura) + '/' + IntToStr(G.Nodo) +
            ' no migrado: ' + E.Message);
        end;
      end;
    end;
  finally
    Q.Free;
    Utiles.Free;
    Hechos.Free;
    Orden.Free;
    Grupos.Free;
  end;
end;

end.
