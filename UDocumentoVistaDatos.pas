unit UDocumentoVistaDatos;

{ Indicadores por documento para la lista de una subserie: cuantos documentos
  referencian a un expediente (solo los que el alcance del usuario deja ver),
  cuantos vertices geograficos tiene y cuantos ficheros digitales y fuentes.
  Tres consultas agrupadas por subserie (no una por fila). Sin VCL ni TUDM.
  Valido en SQL Server y en Access. Codigo en ASCII. }

interface

uses
  System.SysUtils, System.Generics.Collections, FireDAC.Comp.Client,
  UAlcance, UDocumentoVista;

type
  TIndicadoresDoc = record
    NumHijos: Integer;
    NumVerticesGeo: Integer;
    NumFicheros: Integer;
    NumFuentes: Integer;
    ExtPrincipal: string;
  end;

  TIndicadoresDocs = TDictionary<string, TIndicadoresDoc>;

{ IdEstructura|Id|CodSubs|yyyymmddhhnnss|Version|Codigodoc, recortada y en
  minusculas. Es la clave de TIndicadoresDocs. }
function ClaveTexto(const C: TClaveDocumento): string;

{ Indicadores de los documentos de la subserie (IdEstructura, Id, CodSubs). Un
  documento sin ningun indicador no tiene entrada. Alcance = nil (Access) o
  administrador: sin filtro. El resultado es del llamador. }
function CargarIndicadores(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const IdEstructura: string; Id: Integer;
  const CodSubs: string): TIndicadoresDocs;

implementation

uses
  Data.DB, FireDAC.Stan.Param, UAlcanceDatos;

function ClaveTexto(const C: TClaveDocumento): string;
begin
  Result := LowerCase(Trim(C.IdEstructura)) + '|' + IntToStr(C.Id) + '|' +
    LowerCase(Trim(C.CodSubs)) + '|' + FormatDateTime('yyyymmddhhnnss', C.Fecha) +
    '|' + LowerCase(Trim(C.Version)) + '|' + LowerCase(Trim(C.Codigodoc));
end;

function NuevaConsulta(Conn: TFDConnection; const Sql: string): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := Conn;
  Result.SQL.Text := Sql;
end;

procedure PonClavesSubserie(Q: TFDQuery; const IdEstructura: string; Id: Integer;
  const CodSubs: string);
begin
  Q.ParamByName('est').AsString := IdEstructura;
  Q.ParamByName('id').AsInteger := Id;
  Q.ParamByName('cs').AsString := CodSubs;
end;

function ClaveDeFila(Q: TFDQuery; const IdEstructura: string; Id: Integer;
  const CodSubs: string): string;
var
  C: TClaveDocumento;
begin
  C.IdEstructura := IdEstructura;
  C.Id := Id;
  C.CodSubs := CodSubs;
  C.Fecha := Q.FieldByName('Fecha').AsDateTime;
  C.Version := Q.FieldByName('Version').AsString;
  C.Codigodoc := Q.FieldByName('Codigodoc').AsString;
  Result := ClaveTexto(C);
end;

function CargarIndicadores(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const IdEstructura: string; Id: Integer;
  const CodSubs: string): TIndicadoresDocs;
const
  DONDE = 'WHERE IdEstructura = :est AND id = :id AND codsubs = :cs ';
var
  R: TIndicadoresDocs;
  Q: TFDQuery;
  Filtro: TFiltroSql;
  CodigoDe: TDictionary<string, string>;  // clave del documento -> codigo en minusculas
  Hijos: TDictionary<string, Integer>;    // codigo en minusculas -> cuantos lo referencian
  Par: TPair<string, string>;
  K, Fuente: string;
  N: Integer;

  function Actual(const Clave: string): TIndicadoresDoc;
  begin
    if not R.TryGetValue(Clave, Result) then
      Result := Default(TIndicadoresDoc);
  end;

  procedure Anota(const Clave: string; const Ind: TIndicadoresDoc);
  begin
    R.AddOrSetValue(Clave, Ind);
  end;

var
  Ind: TIndicadoresDoc;
begin
  R := TIndicadoresDocs.Create;
  CodigoDe := TDictionary<string, string>.Create;
  Hijos := TDictionary<string, Integer>.Create;
  try
    try
      // Documentos de la subserie
      Q := NuevaConsulta(Conn, 'SELECT Fecha, Version, Codigodoc FROM tb_SeriesDatos ' + DONDE);
      try
        PonClavesSubserie(Q, IdEstructura, Id, CodSubs);
        Q.Open;
        while not Q.Eof do
        begin
          CodigoDe.AddOrSetValue(ClaveDeFila(Q, IdEstructura, Id, CodSubs),
            LowerCase(Trim(Q.FieldByName('Codigodoc').AsString)));
          Q.Next;
        end;
      finally
        Q.Free;
      end;

      // Hijos de cada expediente: documentos del mismo nodo (IdEstructura e id)
      // que lo referencian en IDExpediente y que el alcance deja ver
      Filtro := FiltroDocumentos(Alcance, 'H');
      Q := NuevaConsulta(Conn, 'SELECT H.IDExpediente AS Cod, COUNT(*) AS N ' +
        'FROM tb_SeriesDatos H WHERE H.IdEstructura = :est AND H.id = :id ' +
        'AND H.IDExpediente IS NOT NULL AND H.IDExpediente <> '''' AND (' +
        Filtro.Condicion + ') GROUP BY H.IDExpediente');
      try
        Q.ParamByName('est').AsString := IdEstructura;
        Q.ParamByName('id').AsInteger := Id;
        AplicarParametros(Q, Filtro);
        Q.Open;
        while not Q.Eof do
        begin
          K := LowerCase(Trim(Q.FieldByName('Cod').AsString));
          if K <> '' then
          begin
            // ' EXP-1' y 'EXP-1' son el mismo expediente: se suman
            if not Hijos.TryGetValue(K, N) then
              N := 0;
            Hijos.AddOrSetValue(K, N + Q.FieldByName('N').AsInteger);
          end;
          Q.Next;
        end;
      finally
        Q.Free;
      end;
      for Par in CodigoDe do
        if Hijos.TryGetValue(Par.Value, N) and (N > 0) then
        begin
          Ind := Actual(Par.Key);
          Ind.NumHijos := N;
          Anota(Par.Key, Ind);
        end;

      // Vertices geograficos
      Q := NuevaConsulta(Conn, 'SELECT Fecha, Version, Codigodoc, COUNT(*) AS N ' +
        'FROM tb_DocCoord ' + DONDE + 'GROUP BY Fecha, Version, Codigodoc');
      try
        PonClavesSubserie(Q, IdEstructura, Id, CodSubs);
        Q.Open;
        while not Q.Eof do
        begin
          K := ClaveDeFila(Q, IdEstructura, Id, CodSubs);
          Ind := Actual(K);
          Ind.NumVerticesGeo := Q.FieldByName('N').AsInteger;
          Anota(K, Ind);
          Q.Next;
        end;
      finally
        Q.Free;
      end;

      // Ficheros digitales ('N') y fuentes ('S')
      Q := NuevaConsulta(Conn, 'SELECT Fecha, Version, Codigodoc, fuente, ' +
        'COUNT(*) AS N, MIN(extnombre) AS E FROM tb_ssArchdigital ' + DONDE +
        'GROUP BY Fecha, Version, Codigodoc, fuente');
      try
        PonClavesSubserie(Q, IdEstructura, Id, CodSubs);
        Q.Open;
        while not Q.Eof do
        begin
          K := ClaveDeFila(Q, IdEstructura, Id, CodSubs);
          Ind := Actual(K);
          Fuente := UpperCase(Trim(Q.FieldByName('fuente').AsString));
          if Fuente = 'S' then
            Ind.NumFuentes := Ind.NumFuentes + Q.FieldByName('N').AsInteger
          else
          begin
            Ind.NumFicheros := Ind.NumFicheros + Q.FieldByName('N').AsInteger;
            Ind.ExtPrincipal := ExtensionNormal(Q.FieldByName('E').AsString);
          end;
          Anota(K, Ind);
          Q.Next;
        end;
      finally
        Q.Free;
      end;
    finally
      CodigoDe.Free;
      Hijos.Free;
    end;
  except
    R.Free;
    raise;
  end;
  Result := R;
end;

end.
