unit UInicioDatos;

{ ---------------------------------------------------------------------------
  Datos de la pantalla de inicio del nodo: el resumen (series, subseries,
  documentos, sin ubicacion, prestados) de un conjunto de nodos. Sin VCL ni TUDM
  (RTL + FireDAC), valido en SQL Server y Access.

  El conjunto de nodos lo decide quien llama (en la aplicacion: el nodo elegido en
  el arbol y todos sus descendientes; el arbol que ve el usuario ya esta filtrado
  por su alcance). Los documentos, los "sin ubicacion" y los "prestados" ademas
  pasan por FiltroDocumentos(Alcance): nunca se cuenta un documento que el
  usuario no puede ver. Las subseries y series son las asignadas a esos nodos.
  Un contador cuya consulta falla queda en 0 (no se inventa una cifra).
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance;

type
  TResumenInicio = record
    Series: Integer;
    Subseries: Integer;
    Documentos: Integer;
    SinUbicacion: Integer;   // documentos sin archivo, deposito o gaveta
    Prestados: Integer;      // documentos con un prestamo abierto
  end;

{ Resumen de los nodos dados; con ATodos = True se ignora Nodos y se cuenta todo
  lo que el alcance permite ver. Sin nodos y sin ATodos devuelve todo en 0 sin
  consultar. Alcance = nil: sin filtro (Access o administrador). }
function CargarResumenInicio(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Nodos: TArray<TClaveNodo>; ATodos: Boolean): TResumenInicio;

implementation

uses
  System.Generics.Collections, Data.DB, FireDAC.Stan.Param, FireDAC.Stan.Error,
  UAlcanceDatos;

function ClaveDeNodo(const AEstructura: string; AId: Integer): string;
begin
  Result := LowerCase(Trim(AEstructura)) + '|' + IntToStr(AId);
end;

function CargarResumenInicio(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Nodos: TArray<TClaveNodo>; ATodos: Boolean): TResumenInicio;
var
  Conjunto: TDictionary<string, Boolean>;
  I: Integer;

  function EnAmbito(const AEstructura: string; AId: Integer): Boolean;
  begin
    Result := ATodos or Conjunto.ContainsKey(ClaveDeNodo(AEstructura, AId));
  end;

  // Suma, de las filas (IdEstructura, id, cantidad) que devuelve la consulta, las
  // de los nodos del ambito. El marcador filtro entre llaves de la consulta se
  // sustituye por la condicion del alcance.
  function SumaPorNodo(const ASql: string): Integer;
  var
    Q: TFDQuery;
    Filtro: TFiltroSql;
  begin
    Result := 0;
    try
      Filtro := FiltroDocumentos(Alcance, 'H');
      Q := TFDQuery.Create(nil);
      try
        Q.Connection := Conn;
        Q.SQL.Text := StringReplace(ASql, '{filtro}', Filtro.Condicion, [rfReplaceAll]);
        AplicarParametros(Q, Filtro);
        Q.Open;
        while not Q.Eof do
        begin
          if EnAmbito(Q.Fields[0].AsString, Q.Fields[1].AsInteger) then
            Inc(Result, Q.Fields[2].AsInteger);
          Q.Next;
        end;
      finally
        Q.Free;
      end;
    except
      on EFDDBEngineException do
        Result := 0;   // este contador no se puede calcular
    end;
  end;

  procedure ContarSubseriesYSeries;
  var
    Q: TFDQuery;
    Subs, Sers: TDictionary<string, Boolean>;
    Sub, Ser: string;
  begin
    Subs := TDictionary<string, Boolean>.Create;
    Sers := TDictionary<string, Boolean>.Create;
    try
      try
        Q := TFDQuery.Create(nil);
        try
          Q.Connection := Conn;
          Q.Open('SELECT S.IdEstructura, S.id, S.codsubs, C.codserie FROM tb_Serietree S ' +
            'LEFT JOIN cl_subseries C ON S.codsubs = C.codsubs');
          while not Q.Eof do
          begin
            if EnAmbito(Q.Fields[0].AsString, Q.Fields[1].AsInteger) then
            begin
              Sub := LowerCase(Trim(Q.Fields[2].AsString));
              Ser := LowerCase(Trim(Q.Fields[3].AsString));
              if Sub <> '' then
                Subs.AddOrSetValue(Sub, True);
              if Ser <> '' then
                Sers.AddOrSetValue(Ser, True);
            end;
            Q.Next;
          end;
        finally
          Q.Free;
        end;
      except
        on EFDDBEngineException do
        begin
          Subs.Clear;
          Sers.Clear;
        end;
      end;
      Result.Subseries := Subs.Count;
      Result.Series := Sers.Count;
    finally
      Sers.Free;
      Subs.Free;
    end;
  end;

begin
  Result := Default(TResumenInicio);
  if (not ATodos) and (Length(Nodos) = 0) then
    Exit;
  Conjunto := TDictionary<string, Boolean>.Create;
  try
    for I := 0 to High(Nodos) do
      Conjunto.AddOrSetValue(ClaveDeNodo(Nodos[I].IdEstructura, Nodos[I].Id), True);
    ContarSubseriesYSeries;
    Result.Documentos := SumaPorNodo(
      'SELECT H.IdEstructura, H.id, COUNT(*) FROM tb_SeriesDatos H WHERE ({filtro}) ' +
      'GROUP BY H.IdEstructura, H.id');
    Result.SinUbicacion := SumaPorNodo(
      'SELECT H.IdEstructura, H.id, COUNT(*) FROM tb_SeriesDatos H WHERE ({filtro}) AND ' +
      '(H.Archivo IS NULL OR H.Archivo = 0 OR ' +
      'H.deposito IS NULL OR H.deposito = '''' OR H.deposito = ''0'' OR ' +
      'H.gaveta IS NULL OR H.gaveta = '''' OR H.gaveta = ''0'') ' +
      'GROUP BY H.IdEstructura, H.id');
    Result.Prestados := SumaPorNodo(
      'SELECT T.IdEstructura, T.id, COUNT(*) FROM (SELECT DISTINCT H.IdEstructura, H.id, ' +
      'H.codsubs, H.Codigodoc, H.fecha, H.version FROM (TB_PrestamosDocumentos D ' +
      'INNER JOIN TB_Prestamos P ON P.IdEstructura = D.IdEstructura AND P.id = D.id AND ' +
      'P.IdPrestamo = D.IdPrestamo) INNER JOIN tb_SeriesDatos H ON ' +
      'H.IdEstructura = D.IdEstructura AND H.id = D.id AND H.codsubs = D.codsubs ' +
      'AND H.Codigodoc = D.Codigodoc AND H.fecha = D.fecha AND H.version = D.version ' +
      'WHERE P.FDevolucion IS NULL AND P.FCancelacion IS NULL AND ({filtro})) AS T ' +
      'GROUP BY T.IdEstructura, T.id');
  finally
    Conjunto.Free;
  end;
end;

end.
