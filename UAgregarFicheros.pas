unit UAgregarFicheros;

{ Agrega ficheros (anexos digitales o fuentes) a un documento que ya existe, y
  reemplaza su contenido PDF. Por cada fichero: sube al almacen, inserta su fila
  en tb_ssArchdigital y escribe la bitacora; si algo falla se borra lo subido de
  ese fichero y se sigue con el siguiente, de modo que nada queda a medias. Los
  ficheros nuevos van a la misma carpeta y raiz que los que el documento ya tiene
  de ese tipo (o a la carpeta estandar de documentos nuevos si no tiene). El
  almacen se pide por fichero segun su raiz (una fabrica), porque un documento
  puede tener ficheros en servidores distintos (FTP antiguo y S3). Solo RTL +
  FireDAC, sin VCL ni UDM. Valido en SQL Server y en Access. Codigo en ASCII. }

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
    Omitidos: Integer;  // sin procesar porque se cancelo la operacion
    Mensaje: string;    // permiso, o resumen cuando algo fallo
  end;

  { Almacen donde esta (o debe ir) un fichero, segun su raiz, carpeta y nombre;
    devuelve tambien la clave del objeto en ese almacen. }
  TFabricaAlmacen = reference to function(const UrlRaiz, Path, Nombre: string;
    out Clave: string): IAlmacenFicheros;

{ Clave del objeto en el almacen segun la raiz: 's3://n/' usa Path + Nombre sin
  barra inicial; cualquier otra raiz es una ruta FTP completa. }
function ClaveDeObjeto(const UrlRaiz, Path, Nombre: string): string;

{ Fabrica que siempre devuelve el mismo almacen (documentos con una sola raiz y
  pruebas). }
function FabricaUnica(Almacen: IAlmacenFicheros): TFabricaAlmacen;

{ True si un fichero es PDF: la extension guardada (extnombre) y, si esta vacia,
  la del nombre. Una sola regla para el visor, la confirmacion y el reemplazo. }
function EsPdfDeFichero(const Nombre, ExtNombre: string): Boolean;

{ Agrega los Ficheros al documento Clave. Alcance = nil: sin comprobacion de
  permiso (modo Access); con alcance se exige poder editar en el nodo y la
  subserie. Los nombres se mantienen unicos dentro del soltado y frente a los
  que el documento ya tiene. Origen aporta usuario, rol, serie y la raiz del
  almacen para documentos que aun no tienen ficheros. Si el usuario cancela
  (Progreso pone Cancelar), los que faltan quedan como Omitidos. }
function AgregarFicheros(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; const Clave: TClaveDocumento;
  Fabrica: TFabricaAlmacen; const Ficheros: TArray<TFicheroNuevo>;
  Progreso: TProgresoEvento): TResultadoFicheros;

{ Pone o reemplaza el contenido del documento: su PDF principal (el primer
  anexo digital en PDF). PdfNuevo debe ser un archivo .pdf. Con PDF anterior:
  sube el nuevo, en una transaccion cambia la fila anterior por la nueva (que
  conserva su posicion, idhijo, para seguir siendo el PDF principal) y escribe
  bitacora, y solo despues borra el objeto anterior del almacen; si algo falla
  antes de ese ultimo paso se borra el nuevo y el anterior queda intacto. Si el
  borrado del objeto anterior falla, el nuevo ya esta guardado y Mensaje lo
  dice. Sin PDF anterior equivale a agregar un anexo. }
function ReemplazarContenido(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; const Clave: TClaveDocumento;
  Fabrica: TFabricaAlmacen; const PdfNuevo: string;
  Progreso: TProgresoEvento): TResultadoFicheros;

implementation

uses
  System.Classes, System.IOUtils, System.Variants, Data.DB, FireDAC.Stan.Param,
  FireDAC.Stan.Error, UTrazabilidad, UTrazabilidadDatos, UCargaModelo;

const
  MAX_TAMANO = 2147483647;  // tb_ssArchdigital.tamano es un entero de 32 bits

type
  { Donde van los ficheros nuevos de un tipo (anexo o fuente) de este documento. }
  TDestino = record
    UrlRaiz: string;
    Path: string;       // carpeta con barra final, relativa a la raiz
  end;

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

function FabricaUnica(Almacen: IAlmacenFicheros): TFabricaAlmacen;
begin
  Result := function(const UrlRaiz, Path, Nombre: string; out Clave: string): IAlmacenFicheros
    begin
      Clave := ClaveDeObjeto(UrlRaiz, Path, Nombre);
      Result := Almacen;
    end;
end;

function EsPdfDeFichero(const Nombre, ExtNombre: string): Boolean;
var
  Ext: string;
begin
  Ext := LowerCase(Trim(ExtNombre));
  if Ext = '' then
    Ext := LowerCase(ExtractFileExt(Nombre));
  while (Ext <> '') and (Ext[1] = '.') do
    Delete(Ext, 1, 1);
  Result := Ext = 'pdf';
end;

{ Carpeta y raiz de los ficheros de ese tipo que el documento ya tiene; si no
  tiene, la carpeta estandar de documentos nuevos. Agrega a Usados todos los
  nombres que el documento ya tiene (de los dos tipos). }
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
      'Version = :e AND Codigodoc = :f ORDER BY idhijo';
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

{ Inserta la fila de un fichero. IdHijoFijo > 0 la inserta con ese idhijo (para
  que un reemplazo conserve su posicion); si no, el siguiente libre. }
procedure InsertarFila(Conn: TFDConnection; const Clave: TClaveDocumento;
  const Destino: TDestino; const Nombre: string; Tamano: Int64; EsFuente: Boolean;
  IdHijoFijo: Integer);
var
  Q: TFDQuery;
  V: Variant;
  IdHijo: Integer;
  Ext: string;
begin
  if IdHijoFijo > 0 then
    IdHijo := IdHijoFijo
  else
  begin
    V := Conn.ExecSQLScalar('SELECT MAX(idhijo) FROM tb_ssArchdigital');
    if VarIsNull(V) or VarIsEmpty(V) then
      IdHijo := 1
    else
      IdHijo := Integer(V) + 1;
  end;
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
    Q.ParamByName('g').AsInteger := IdHijo;
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

{ PDF principal actual del documento: primer anexo digital (por idhijo) que es PDF. }
function PdfActual(Conn: TFDConnection; const Clave: TClaveDocumento;
  out IdHijo: Integer; out UrlRaiz, Path, Nombre: string): Boolean;
var
  Q: TFDQuery;
begin
  Result := False;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT idhijo, nombre, urlraiz, path, extnombre FROM tb_ssArchdigital ' +
      'WHERE IdEstructura = :a AND id = :b AND codsubs = :c AND Fecha = :d AND ' +
      'Version = :e AND Codigodoc = :f AND fuente = ''N'' ORDER BY idhijo';
    Q.ParamByName('a').AsString := Clave.IdEstructura;
    Q.ParamByName('b').AsInteger := Clave.Id;
    Q.ParamByName('c').AsString := Clave.CodSubs;
    Q.ParamByName('d').AsDateTime := Clave.Fecha;
    Q.ParamByName('e').AsString := Clave.Version;
    Q.ParamByName('f').AsString := Clave.Codigodoc;
    Q.Open;
    while not Q.Eof do
    begin
      if EsPdfDeFichero(Q.FieldByName('nombre').AsString, Q.FieldByName('extnombre').AsString) then
      begin
        IdHijo := Q.FieldByName('idhijo').AsInteger;
        UrlRaiz := Q.FieldByName('urlraiz').AsString;
        Path := Q.FieldByName('path').AsString;
        Nombre := Q.FieldByName('nombre').AsString;
        Exit(True);
      end;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TamanoDeArchivo(const Ruta: string): Int64;
var
  F: TFileStream;
begin
  F := TFileStream.Create(Ruta, fmOpenRead or fmShareDenyNone);
  try
    Result := F.Size;
  finally
    F.Free;
  end;
end;

function PuedeEditar(Alcance: TAlcanceUsuario; const Origen: TOrigenDocumento): Boolean;
var
  Nodo: TClaveNodo;
begin
  Nodo.IdEstructura := Origen.IdEstructura;
  Nodo.Id := Origen.Id;
  Result := (Alcance = nil) or Alcance.PuedeRealizar(acEditar, Nodo, Origen.CodSubs);
end;

function AgregarFicheros(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; const Clave: TClaveDocumento;
  Fabrica: TFabricaAlmacen; const Ficheros: TArray<TFicheroNuevo>;
  Progreso: TProgresoEvento): TResultadoFicheros;
var
  Usados: TStringList;
  Destinos: array[Boolean] of TDestino;
  I, J: Integer;
  Destino: TDestino;
  Nombre, ClaveObj, Que, Ultimo: string;
  Alm: IAlmacenFicheros;
  Res: TResultadoSubida;
  Subido, Propia, Cancelado: Boolean;
  Envuelto: TProgresoEvento;
begin
  Result := Default(TResultadoFicheros);
  if not PuedeEditar(Alcance, Origen) then
  begin
    Result.Mensaje := 'No tiene permiso para modificar los ficheros de este documento.';
    Exit;
  end;
  Cancelado := False;
  Envuelto := procedure(Hecho, Total: Int64; var Cancelar: Boolean)
    begin
      if Assigned(Progreso) then
        Progreso(Hecho, Total, Cancelar);
      if Cancelar then
        Cancelado := True;
    end;
  Usados := TStringList.Create;
  try
    // (DestinoDe agrega a Usados todos los nombres existentes del documento)
    Destinos[False] := DestinoDe(Conn, Origen, Clave, False, Usados);
    Destinos[True] := DestinoDe(Conn, Origen, Clave, True, Usados);
    Ultimo := '';
    for I := 0 to High(Ficheros) do
    begin
      if Cancelado then
      begin
        // el usuario cancelo: los que faltan no se intentan
        for J := I to High(Ficheros) do
          Inc(Result.Omitidos);
        Break;
      end;
      Subido := False;
      Alm := nil;
      Destino := Destinos[Ficheros[I].EsFuente];
      if Ficheros[I].EsFuente then
        Que := 'fuente'
      else
        Que := 'anexo digital';
      try
        if not TFile.Exists(Ficheros[I].Local) then
          raise EAlmacen.Create('No se encuentra el archivo ' + ExtractFileName(Ficheros[I].Local) + '.');
        if TamanoDeArchivo(Ficheros[I].Local) > MAX_TAMANO then
          raise EAlmacen.Create('El archivo supera los 2 GB que admite el registro.');
        Nombre := NombreUnico(Usados, Destino.Path, ExtractFileName(Ficheros[I].Local));
        Alm := Fabrica(Destino.UrlRaiz, Destino.Path, Nombre, ClaveObj);
        Res := Alm.Subir(Ficheros[I].Local, ClaveObj, Envuelto);
        Subido := True;
        Propia := not Conn.InTransaction;
        if Propia then
          Conn.StartTransaction;
        try
          InsertarFila(Conn, Clave, Destino, Nombre, Res.Tamano, Ficheros[I].EsFuente, 0);
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
          if Subido and (Alm <> nil) then
            try
              Alm.Borrar(ClaveObj);
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
  if Result.Omitidos > 0 then
    Result.Mensaje := Trim(Result.Mensaje + Format(' Se cancelo: %d quedaron sin procesar.',
      [Result.Omitidos]));
end;

function ReemplazarContenido(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; const Clave: TClaveDocumento;
  Fabrica: TFabricaAlmacen; const PdfNuevo: string;
  Progreso: TProgresoEvento): TResultadoFicheros;
var
  Usados: TStringList;
  Destino: TDestino;
  IdViejo: Integer;
  UrlViejo, PathViejo, NombreViejo, Nombre, ClaveNueva, ClaveVieja: string;
  AlmNuevo, AlmViejo: IAlmacenFicheros;
  Res: TResultadoSubida;
  Subido, Propia: Boolean;
  Un: TArray<TFicheroNuevo>;
begin
  Result := Default(TResultadoFicheros);
  if not PuedeEditar(Alcance, Origen) then
  begin
    Result.Mensaje := 'No tiene permiso para modificar los ficheros de este documento.';
    Exit;
  end;
  if not SameText(ExtractFileExt(PdfNuevo), '.pdf') then
  begin
    Result.Mensaje := 'El contenido debe ser un archivo PDF.';
    Exit;
  end;
  if not PdfActual(Conn, Clave, IdViejo, UrlViejo, PathViejo, NombreViejo) then
  begin
    // sin contenido anterior: es agregar un anexo digital
    SetLength(Un, 1);
    Un[0].Local := PdfNuevo;
    Un[0].EsFuente := False;
    Exit(AgregarFicheros(Conn, Alcance, Origen, Clave, Fabrica, Un, Progreso));
  end;
  Usados := TStringList.Create;
  Subido := False;
  try
    DestinoDe(Conn, Origen, Clave, False, Usados);
    // el nuevo va a la carpeta y la raiz del PDF anterior, con un nombre que no
    // lo pise (el anterior se borra solo cuando el nuevo ya esta guardado)
    Destino.UrlRaiz := UrlViejo;
    Destino.Path := PathViejo;
    try
      if not TFile.Exists(PdfNuevo) then
        raise EAlmacen.Create('No se encuentra el archivo ' + ExtractFileName(PdfNuevo) + '.');
      if TamanoDeArchivo(PdfNuevo) > MAX_TAMANO then
        raise EAlmacen.Create('El archivo supera los 2 GB que admite el registro.');
      Nombre := NombreUnico(Usados, Destino.Path, ExtractFileName(PdfNuevo));
      AlmNuevo := Fabrica(Destino.UrlRaiz, Destino.Path, Nombre, ClaveNueva);
      Res := AlmNuevo.Subir(PdfNuevo, ClaveNueva, Progreso);
      Subido := True;
      Propia := not Conn.InTransaction;
      if Propia then
        Conn.StartTransaction;
      try
        Conn.ExecSQL('DELETE FROM tb_ssArchdigital WHERE idhijo = :h AND ' +
          'IdEstructura = :a AND id = :b AND codsubs = :c AND Fecha = :d AND ' +
          'Version = :e AND Codigodoc = :f',
          [IdViejo, Clave.IdEstructura, Clave.Id, Clave.CodSubs, Clave.Fecha,
          Clave.Version, Clave.Codigodoc]);
        // con el mismo idhijo: sigue siendo el primer PDF, el principal
        InsertarFila(Conn, Clave, Destino, Nombre, Res.Tamano, False, IdViejo);
        RegistrarEventoDoc(Conn, Clave, ACCION_MODIFICAR,
          Format('Se reemplazo el contenido del documento con codigo "%s": "%s" por "%s".',
          [Trim(Clave.Codigodoc), NombreViejo, Nombre]), Origen.Usuario, Origen.Rol,
          Origen.CodSerie);
        if Propia then
          Conn.Commit;
      except
        if Propia and Conn.InTransaction then
          Conn.Rollback;
        raise;
      end;
    except
      on E: Exception do
      begin
        Inc(Result.Fallidos);
        Result.Mensaje := ExtractFileName(PdfNuevo) + ': ' + E.Message;
        if Subido and (AlmNuevo <> nil) then
          try
            AlmNuevo.Borrar(ClaveNueva);
          except
            // el nuevo no se pudo quitar: el mensaje ya dice que fallo
          end;
        Exit;
      end;
    end;
    Inc(Result.Agregados);
    // el nuevo ya esta guardado: ahora se quita el objeto anterior del almacen
    // (del servidor donde esta, que puede no ser el del nuevo)
    try
      AlmViejo := Fabrica(UrlViejo, PathViejo, NombreViejo, ClaveVieja);
      AlmViejo.Borrar(ClaveVieja);
    except
      on E: Exception do
        Result.Mensaje := 'El contenido se reemplazo, pero el PDF anterior quedo en el ' +
          'almacen (' + NombreViejo + '): ' + E.Message;
    end;
  finally
    Usados.Free;
  end;
end;

end.
