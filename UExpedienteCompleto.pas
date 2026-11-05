unit UExpedienteCompleto;

{ "Obtener el expediente completo": lista los ficheros del expediente y de los
  documentos que lo referencian (IDExpediente) en el mismo nodo, respetando el
  alcance del usuario, y los exporta a una carpeta (una subcarpeta por
  documento) o a un ZIP. Solo RTL + FireDAC, sin VCL ni UDM. Valido en SQL
  Server y en Access. Codigo en ASCII. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance, UAlmacenFicheros;

type
  TFicheroExpediente = record
    Documento: string;   // Codigodoc
    Titulo: string;
    Nombre: string;
    UrlRaiz: string;
    Path: string;
    EsFuente: Boolean;
  end;

  { Devuelve el almacen donde esta el fichero y la clave dentro de el }
  TResolverAlmacen = reference to function(const F: TFicheroExpediente;
    out Clave: string): IAlmacenFicheros;

  TResumenExportacion = record
    Copiados, Fallidos: Integer;
    Cancelado: Boolean;
    Fallos: string;      // una linea por fichero fallido
  end;

{ Ficheros del expediente CodigoExpediente (de IdEstructura, Id) y de los
  documentos del mismo nodo cuyo IDExpediente coincide (sin importar
  mayusculas ni espacios). Alcance = nil (Access) o administrador: sin filtro. }
function ListarFicherosExpediente(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const IdEstructura: string; Id: Integer;
  const CodigoExpediente: string): TArray<TFicheroExpediente>;

{ Destino es una carpeta (EnZip = False) o la ruta del .zip (EnZip = True).
  Un fichero que falla no detiene el resto. Progreso cuenta ficheros. }
function ExportarExpediente(const Ficheros: TArray<TFicheroExpediente>;
  Resolver: TResolverAlmacen; const Destino: string; EnZip: Boolean;
  Progreso: TProgresoEvento): TResumenExportacion;

implementation

uses
  System.Classes, System.IOUtils, System.Zip, System.Generics.Collections,
  Data.DB, FireDAC.Stan.Param, UDocumentoVista, UDocumentoVistaDatos, UAlcanceDatos;

function Norm(const S: string): string;
begin
  Result := LowerCase(Trim(S));
end;

function ListarFicherosExpediente(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const IdEstructura: string; Id: Integer;
  const CodigoExpediente: string): TArray<TFicheroExpediente>;
var
  Q: TFDQuery;
  Filtro: TFiltroSql;
  Docs: TDictionary<string, string>;   // clave del documento -> titulo
  Cod: string;
  C: TClaveDocumento;
  F: TFicheroExpediente;
  N: Integer;

  function ClaveDe(const Q: TFDQuery): TClaveDocumento;
  begin
    Result := Default(TClaveDocumento);
    Result.IdEstructura := IdEstructura;
    Result.Id := Id;
    Result.CodSubs := Q.FieldByName('codsubs').AsString;
    Result.Fecha := Q.FieldByName('Fecha').AsDateTime;
    Result.Version := Q.FieldByName('Version').AsString;
    Result.Codigodoc := Q.FieldByName('Codigodoc').AsString;
  end;

begin
  Result := nil;
  Cod := Norm(CodigoExpediente);
  if Cod = '' then
    Exit;
  Docs := TDictionary<string, string>.Create;
  try
    Filtro := FiltroDocumentos(Alcance, 'D');
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := 'SELECT D.codsubs, D.Fecha, D.Version, D.Codigodoc, D.titulodoc, ' +
        'D.IDExpediente FROM tb_SeriesDatos D WHERE D.IdEstructura = :est AND D.id = :id ' +
        'AND (' + Filtro.Condicion + ')';
      Q.ParamByName('est').AsString := IdEstructura;
      Q.ParamByName('id').AsInteger := Id;
      AplicarParametros(Q, Filtro);
      Q.Open;
      while not Q.Eof do
      begin
        if (Norm(Q.FieldByName('Codigodoc').AsString) = Cod) or
          (Norm(Q.FieldByName('IDExpediente').AsString) = Cod) then
          Docs.AddOrSetValue(ClaveTexto(ClaveDe(Q)), Q.FieldByName('titulodoc').AsString);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    if Docs.Count = 0 then
      Exit;

    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.SQL.Text := 'SELECT F.codsubs, F.Fecha, F.Version, F.Codigodoc, F.idhijo, ' +
        'F.nombre, F.urlraiz, F.path, F.fuente FROM tb_ssArchdigital F ' +
        'WHERE F.IdEstructura = :est AND F.id = :id ORDER BY F.Codigodoc, F.idhijo';
      Q.ParamByName('est').AsString := IdEstructura;
      Q.ParamByName('id').AsInteger := Id;
      Q.Open;
      N := 0;
      while not Q.Eof do
      begin
        C := ClaveDe(Q);
        if Docs.TryGetValue(ClaveTexto(C), F.Titulo) then
        begin
          F.Documento := Trim(C.Codigodoc);
          F.Nombre := Q.FieldByName('nombre').AsString;
          F.UrlRaiz := Q.FieldByName('urlraiz').AsString;
          F.Path := Q.FieldByName('path').AsString;
          F.EsFuente := UpperCase(Trim(Q.FieldByName('fuente').AsString)) = 'S';
          SetLength(Result, N + 1);
          Result[N] := F;
          Inc(N);
        end;
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  finally
    Docs.Free;
  end;
end;

{ Nombre valido en Windows (sin \ / : * ? " < > |) }
function NombreSeguro(const S: string): string;
var
  I: Integer;
begin
  Result := Trim(S);
  for I := 1 to Length(Result) do
    if CharInSet(Result[I], ['\', '/', ':', '*', '?', '"', '<', '>', '|']) then
      Result[I] := '_';
  if Result = '' then
    Result := '_';
end;

{ Si el nombre ya se uso en ese documento agrega " (2)", " (3)"... antes de la extension }
function NombreUnico(Usados: TDictionary<string, Boolean>; const DirDoc, Nombre: string): string;
var
  Base, Ext: string;
  N: Integer;
begin
  Result := Nombre;
  N := 1;
  Base := TPath.GetFileNameWithoutExtension(Nombre);
  Ext := TPath.GetExtension(Nombre);
  while Usados.ContainsKey(LowerCase(DirDoc + '/' + Result)) do
  begin
    Inc(N);
    Result := Format('%s (%d)%s', [Base, N, Ext]);
  end;
  Usados.Add(LowerCase(DirDoc + '/' + Result), True);
end;

function ExportarExpediente(const Ficheros: TArray<TFicheroExpediente>;
  Resolver: TResolverAlmacen; const Destino: string; EnZip: Boolean;
  Progreso: TProgresoEvento): TResumenExportacion;
var
  Zip: TZipFile;
  Usados: TDictionary<string, Boolean>;
  I: Integer;
  F: TFicheroExpediente;
  DirDoc, Nombre, Clave, Tmp, Final: string;
  Cancelar: Boolean;
  Alm: IAlmacenFicheros;
begin
  Result := Default(TResumenExportacion);
  if Length(Ficheros) = 0 then
    Exit;
  Zip := nil;
  Usados := TDictionary<string, Boolean>.Create;
  try
    if EnZip then
    begin
      if TFile.Exists(Destino) then
        TFile.Delete(Destino);
      Zip := TZipFile.Create;
      Zip.Open(Destino, zmWrite);
    end
    else
      TDirectory.CreateDirectory(Destino);
    for I := 0 to High(Ficheros) do
    begin
      F := Ficheros[I];
      DirDoc := NombreSeguro(F.Documento);
      Nombre := NombreUnico(Usados, DirDoc, NombreSeguro(F.Nombre));
      Tmp := '';
      try
        Alm := Resolver(F, Clave);
        if EnZip then
        begin
          Tmp := TPath.GetTempFileName;
          Alm.Descargar(Clave, Tmp, nil);
          Zip.Add(Tmp, DirDoc + '/' + Nombre);
        end
        else
        begin
          TDirectory.CreateDirectory(TPath.Combine(Destino, DirDoc));
          Final := TPath.Combine(TPath.Combine(Destino, DirDoc), Nombre);
          Alm.Descargar(Clave, Final, nil);
        end;
        Inc(Result.Copiados);
      except
        on E: Exception do
        begin
          Inc(Result.Fallidos);
          Result.Fallos := Result.Fallos + F.Documento + '/' + F.Nombre + ': ' + E.Message + sLineBreak;
        end;
      end;
      if (Tmp <> '') and TFile.Exists(Tmp) then
        TFile.Delete(Tmp);
      if Assigned(Progreso) then
      begin
        Cancelar := False;
        Progreso(I + 1, Length(Ficheros), Cancelar);
        if Cancelar then
        begin
          Result.Cancelado := True;
          Break;
        end;
      end;
    end;
    if Zip <> nil then
      Zip.Close;
  finally
    Zip.Free;
    Usados.Free;
  end;
end;

end.
