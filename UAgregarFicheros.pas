unit UAgregarFicheros;

{ Agrega ficheros (anexos digitales o fuentes) a un documento que ya existe, y
  reemplaza su contenido PDF. Por cada fichero: sube al almacen, inserta su fila
  en tb_ssArchdigital y escribe la bitacora; si algo falla se borra lo subido de
  ese fichero y se sigue con el siguiente, de modo que nada queda a medias. Los
  ficheros nuevos van a la misma carpeta y raiz que los que el documento ya tiene
  (o a la carpeta estandar de documentos nuevos si no tiene). Solo RTL + FireDAC,
  sin VCL ni UDM. Valido en SQL Server y en Access. Codigo en ASCII. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance, UAlmacenFicheros,
  UCargaDocumento, UDocumentoVista;

type
  TFicheroNuevo = record
    Local: string;      // ruta del archivo en el equipo del usuario
    EsFuente: Boolean;  // True: fuente; False: anexo digital
  end;

  TResultadoFicheros = record
    Agregados: Integer;
    Fallidos: Integer;
    Mensaje: string;    // permiso, o resumen cuando algo fallo
  end;

{ Agrega los Ficheros al documento Clave. Alcance = nil: sin comprobacion de
  permiso (modo Access); con alcance se exige poder editar en el nodo y la
  subserie. Los nombres se mantienen unicos dentro del soltado y frente a los
  que el documento ya tiene. Origen aporta usuario, rol, serie y la raiz del
  almacen para documentos que aun no tienen ficheros. }
function AgregarFicheros(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; const Clave: TClaveDocumento;
  Almacen: IAlmacenFicheros; const Ficheros: TArray<TFicheroNuevo>;
  Progreso: TProgresoEvento): TResultadoFicheros;

implementation

uses
  System.Classes, System.IOUtils, System.Variants, Data.DB, FireDAC.Stan.Param,
  FireDAC.Stan.Error, UTrazabilidad, UTrazabilidadDatos, UCargaModelo;

type
  { Donde van los ficheros nuevos de un tipo (anexo o fuente) de este documento. }
  TDestino = record
    UrlRaiz: string;
    Path: string;       // carpeta con barra final, relativa a la raiz
  end;

{ Carpeta y raiz de los ficheros de ese tipo que el documento ya tiene; si no
  tiene, la carpeta estandar de documentos nuevos. }
function DestinoDe(Conn: TFDConnection; const Origen: TOrigenDocumento;
  const Clave: TClaveDocumento; EsFuente: Boolean; Usados: TStringList): TDestino;
var
  Q: TFDQuery;
  Tipo, Nombre, Carp: string;
  Hallado: Boolean;
begin
  Result.UrlRaiz := Origen.UrlRaiz;
  Result.Path := '\' + Origen.IdEstructura + '\' + Origen.CodSerie + '\' + Origen.CodSubs +
    '\' + LimpiarNombreArchivo(Clave.Codigodoc);
  if EsFuente then
    Result.Path := Result.Path + '\Fuentes\'
  else
    Result.Path := Result.Path + '\Anexos Digitales\';
  Hallado := False;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT nombre, urlraiz, path, fuente FROM tb_ssArchdigital ' +
      'WHERE IdEstructura = :a AND id = :b AND codsubs = :c AND Fecha = :d AND ' +
      'Version = :e AND Codigodoc = :f';
    Q.ParamByName('a').AsString := Clave.IdEstructura;
    Q.ParamByName('b').AsInteger := Clave.Id;
    Q.ParamByName('c').AsString := Clave.CodSubs;
    Q.ParamByName('d').AsDateTime := Clave.Fecha;
    Q.ParamByName('e').AsString := Clave.Version;
    Q.ParamByName('f').AsString := Clave.Codigodoc;
    Q.Open;
    if EsFuente then
      Tipo := 'S'
    else
      Tipo := 'N';
    while not Q.Eof do
    begin
      Nombre := Q.FieldByName('nombre').AsString;
      Carp := Q.FieldByName('path').AsString;
      Usados.Add(LowerCase(Carp + '|' + Nombre));
      if (not Hallado) and SameText(Trim(Q.FieldByName('fuente').AsString), Tipo) and
        (Carp <> '') then
      begin
        Result.Path := Carp;
        Result.UrlRaiz := Q.FieldByName('urlraiz').AsString;
        Hallado := True;
      end;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

{ Clave del objeto en el almacen segun la raiz: 's3://n/' usa Path + Nombre sin
  barra inicial; cualquier otra raiz es una ruta FTP completa. }
function ClaveDeObjeto(const UrlRaiz, Path, Nombre: string): string;
var
  Id: Integer;
begin
  if EsUrlRaizS3(UrlRaiz, Id) then
  begin
    Result := NormalizarRutaFtp(Path + Nombre);
    if (Result <> '') and (Result[1] = '/') then
      Delete(Result, 1, 1);
  end
  else
    Result := NormalizarRutaFtp(UrlRaiz + Path + Nombre);
end;

procedure InsertarFila(Conn: TFDConnection; const Clave: TClaveDocumento;
  const Destino: TDestino; const Nombre: string; Tamano: Int64; EsFuente: Boolean);
var
  Q: TFDQuery;
  V: Variant;
  BaseHijo: Integer;
  Ext: string;
begin
  V := Conn.ExecSQLScalar('SELECT MAX(idhijo) FROM tb_ssArchdigital');
  if VarIsNull(V) or VarIsEmpty(V) then
    BaseHijo := 0
  else
    BaseHijo := Integer(V);
  Ext := ExtractFileExt(Nombre);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, ' +
      'Version, Codigodoc, idhijo, nombre, ext, extnombre, urlraiz, path, tamano, ' +
      'padre, nivel, fuente, Etiqueta) VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, ' +
      ':j, :k, :l, :m, 0, 0, :n, :o)';
    Q.ParamByName('a').AsString := Clave.IdEstructura;
    Q.ParamByName('b').AsInteger := Clave.Id;
    Q.ParamByName('c').AsString := Clave.CodSubs;
    Q.ParamByName('d').AsDateTime := Clave.Fecha;
    Q.ParamByName('e').AsString := Clave.Version;
    Q.ParamByName('f').AsString := Clave.Codigodoc;
    Q.ParamByName('g').AsInteger := BaseHijo + 1;
    Q.ParamByName('h').AsString := Nombre;
    Q.ParamByName('i').AsInteger := IdTipoExtension(Conn, Ext);
    Q.ParamByName('j').AsString := Ext;
    Q.ParamByName('k').AsString := Destino.UrlRaiz;
    Q.ParamByName('l').AsString := Destino.Path;
    Q.ParamByName('m').AsFloat := Tamano;
    if EsFuente then
      Q.ParamByName('n').AsString := 'S'
    else
      Q.ParamByName('n').AsString := 'N';
    Q.ParamByName('o').AsString := TPath.GetFileNameWithoutExtension(Nombre);
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function AgregarFicheros(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; const Clave: TClaveDocumento;
  Almacen: IAlmacenFicheros; const Ficheros: TArray<TFicheroNuevo>;
  Progreso: TProgresoEvento): TResultadoFicheros;
var
  Nodo: TClaveNodo;
  Usados: TStringList;
  Destinos: array[Boolean] of TDestino;
  I: Integer;
  Destino: TDestino;
  Nombre, ClaveObj, Que, Ultimo: string;
  Res: TResultadoSubida;
  Subido, Propia: Boolean;
begin
  Result := Default(TResultadoFicheros);
  Nodo.IdEstructura := Origen.IdEstructura;
  Nodo.Id := Origen.Id;
  if (Alcance <> nil) and not Alcance.PuedeRealizar(acEditar, Nodo, Origen.CodSubs) then
  begin
    Result.Mensaje := 'No tiene permiso para modificar los ficheros de este documento.';
    Exit;
  end;
  Usados := TStringList.Create;
  try
    // las carpetas existentes de cada tipo y los nombres ya usados
    // (DestinoDe agrega a Usados todos los nombres existentes del documento)
    Destinos[False] := DestinoDe(Conn, Origen, Clave, False, Usados);
    Destinos[True] := DestinoDe(Conn, Origen, Clave, True, Usados);
    Ultimo := '';
    for I := 0 to High(Ficheros) do
    begin
      Subido := False;
      Destino := Destinos[Ficheros[I].EsFuente];
      if Ficheros[I].EsFuente then
        Que := 'fuente'
      else
        Que := 'anexo digital';
      try
        if not TFile.Exists(Ficheros[I].Local) then
          raise EAlmacen.Create('No se encuentra el archivo ' + ExtractFileName(Ficheros[I].Local) + '.');
        Nombre := NombreUnico(Usados, Destino.Path, ExtractFileName(Ficheros[I].Local));
        ClaveObj := ClaveDeObjeto(Destino.UrlRaiz, Destino.Path, Nombre);
        Res := Almacen.Subir(Ficheros[I].Local, ClaveObj, Progreso);
        Subido := True;
        Propia := not Conn.InTransaction;
        if Propia then
          Conn.StartTransaction;
        try
          InsertarFila(Conn, Clave, Destino, Nombre, Res.Tamano, Ficheros[I].EsFuente);
          RegistrarEventoDoc(Conn, Clave, ACCION_MODIFICAR,
            Format('Se agrego el %s "%s" al documento con codigo "%s".',
            [Que, Nombre, Trim(Clave.Codigodoc)]), Origen.Usuario, Origen.Rol,
            Origen.CodSerie);
          if Propia then
            Conn.Commit;
        except
          if Propia and Conn.InTransaction then
            Conn.Rollback;
          raise;
        end;
        Inc(Result.Agregados);
      except
        on E: Exception do
        begin
          Inc(Result.Fallidos);
          Ultimo := ExtractFileName(Ficheros[I].Local) + ': ' + E.Message;
          // compensacion: el objeto subido de este fichero no debe quedar huerfano
          if Subido then
            try
              Almacen.Borrar(ClaveObj);
            except
              // si tampoco se puede borrar, el mensaje ya dice que fallo
            end;
        end;
      end;
    end;
  finally
    Usados.Free;
  end;
  if Result.Fallidos > 0 then
    Result.Mensaje := Format('%d fichero(s) no se pudieron agregar. Ultimo error: %s',
      [Result.Fallidos, Ultimo]);
end;

end.
