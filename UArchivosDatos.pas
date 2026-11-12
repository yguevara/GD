unit UArchivosDatos;

{ ---------------------------------------------------------------------------
  Datos del clasificador de Archivos (cl_ArchivosGestion). Sin VCL ni TUDM
  (RTL + FireDAC). La pantalla UCLArchivosForm solo presenta; las reglas viven
  aqui para poder probarlas.

  Columnas: Cod (clave, MAX+1), nombreArchivo (max 100), Tipo (cl_tipoarch),
  Idresp (cl_Resp_Gest_Arch, opcional), croquis y Foto (image, JPEG en bruto) y
  Descripcion (text, normalmente RTF). Al leer la lista NO se traen los blobs:
  solo se informa si existen (TieneCroquis / TieneFoto).
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UServidoresDatos, UErroresCampo;

type
  { Opcion de una lista desplegable (tipo de archivo, responsable). }
  TOpcion = record
    Id: Integer;
    Texto: string;
  end;

  TArchivo = record
    Cod: Integer;           // 0 = nuevo
    Nombre: string;         // nombreArchivo (max 100)
    Tipo: Integer;          // Idtipoarch; 0 = sin elegir
    Idresp: Integer;        // 0 = sin responsable
    TieneCroquis: Boolean;  // solo informativo al leer
    TieneFoto: Boolean;     // solo informativo al leer
  end;

  EArchivoInvalido = class(Exception);

  EArchivoEnUso = class(Exception)
  public
    Usos: Integer;
  end;

{ Archivos ordenados por Cod, sin leer los blobs. }
function ListarArchivos(Conn: TFDConnection): TArray<TArchivo>;

{ Tipos de archivo (cl_tipoarch) ordenados por Id. }
function ListarTiposArchivo(Conn: TFDConnection): TArray<TOpcion>;

{ Responsables (cl_Resp_Gest_Arch) ordenados por nombre; si un responsable no
  tiene nombre se muestra su usuario. }
function ListarResponsables(Conn: TFDConnection): TArray<TOpcion>;

{ Valida un archivo antes de guardarlo. Lista vacia = valido; como maximo un
  error por campo (nombre, tipo). El responsable es opcional. }
function ValidarArchivo(const A: TArchivo): TArray<TErrorCampo>;

type
  { Campo de imagen de cl_ArchivosGestion. }
  TCampoImagen = (ciCroquis, ciFoto);

{ Alta (Cod = 0: MAX+1) o edicion de nombreArchivo, Tipo e Idresp (0 = NULL).
  NO toca croquis, Foto ni Descripcion: eso se guarda aparte y solo cuando el
  usuario lo cambia. Valida primero (EArchivoInvalido con el primer mensaje; no
  escribe nada). Devuelve el Cod. }
function GuardarArchivo(Conn: TFDConnection; const A: TArchivo): Integer;

{ Descripcion tal como esta guardada (RTF o texto); '' si es NULL. }
function LeerDescripcion(Conn: TFDConnection; ACod: Integer): string;

{ Guarda la descripcion; '' deja NULL. }
procedure GuardarDescripcion(Conn: TFDConnection; ACod: Integer; const ATexto: string);

{ Bytes de la imagen; vacio si no hay. }
function LeerImagen(Conn: TFDConnection; ACod: Integer; ACampo: TCampoImagen): TBytes;

procedure GuardarImagen(Conn: TFDConnection; ACod: Integer; ACampo: TCampoImagen;
  const ABytes: TBytes);

{ Deja la imagen en NULL. }
procedure QuitarImagen(Conn: TFDConnection; ACod: Integer; ACampo: TCampoImagen);

{ Elementos que usan el archivo: cl_subseries.archivo + tb_SeriesDatos.Archivo +
  tb_Serietree.Archivo + TB_PrestamosDocumentos.Archivo. }
function ContarUsoArchivo(Conn: TFDConnection; ACod: Integer): Integer;

{ Elimina el archivo. Si esta en uso lanza EArchivoEnUso (con Usos) y no borra. }
procedure EliminarArchivo(Conn: TFDConnection; ACod: Integer);

implementation

uses
  System.Generics.Collections, System.Variants, Data.DB, FireDAC.Stan.Param;

function ListarArchivos(Conn: TFDConnection): TArray<TArchivo>;
var
  Q: TFDQuery;
  L: TList<TArchivo>;
  A: TArchivo;
begin
  L := TList<TArchivo>.Create;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.Open('SELECT Cod, nombreArchivo, Tipo, Idresp, ' +
        'IIf(croquis IS NULL, 0, 1) AS tiene_croquis, ' +
        'IIf(Foto IS NULL, 0, 1) AS tiene_foto ' +
        'FROM cl_ArchivosGestion ORDER BY Cod');
      while not Q.Eof do
      begin
        A := Default(TArchivo);
        A.Cod := Q.FieldByName('Cod').AsInteger;
        A.Nombre := Trim(Q.FieldByName('nombreArchivo').AsString);
        A.Tipo := Q.FieldByName('Tipo').AsInteger;
        A.Idresp := Q.FieldByName('Idresp').AsInteger;
        A.TieneCroquis := Q.FieldByName('tiene_croquis').AsInteger <> 0;
        A.TieneFoto := Q.FieldByName('tiene_foto').AsInteger <> 0;
        L.Add(A);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function ListarTiposArchivo(Conn: TFDConnection): TArray<TOpcion>;
var
  Q: TFDQuery;
  L: TList<TOpcion>;
  O: TOpcion;
begin
  L := TList<TOpcion>.Create;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.Open('SELECT Idtipoarch, tipoarch FROM cl_tipoarch ORDER BY Idtipoarch');
      while not Q.Eof do
      begin
        O.Id := Q.FieldByName('Idtipoarch').AsInteger;
        O.Texto := Trim(Q.FieldByName('tipoarch').AsString);
        L.Add(O);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function ListarResponsables(Conn: TFDConnection): TArray<TOpcion>;
var
  Q: TFDQuery;
  L: TList<TOpcion>;
  O: TOpcion;
begin
  L := TList<TOpcion>.Create;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      Q.Open('SELECT Idresp, NombreResponsable, usuario FROM cl_Resp_Gest_Arch ' +
        'ORDER BY NombreResponsable, usuario');
      while not Q.Eof do
      begin
        O.Id := Q.FieldByName('Idresp').AsInteger;
        O.Texto := Trim(Q.FieldByName('NombreResponsable').AsString);
        if O.Texto = '' then
          O.Texto := Trim(Q.FieldByName('usuario').AsString);
        L.Add(O);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function ValidarArchivo(const A: TArchivo): TArray<TErrorCampo>;
var
  L: TList<TErrorCampo>;

  procedure Error(const Campo, Mensaje: string);
  var
    E: TErrorCampo;
  begin
    E.Campo := Campo;
    E.Mensaje := Mensaje;
    L.Add(E);
  end;

begin
  L := TList<TErrorCampo>.Create;
  try
    if Trim(A.Nombre) = '' then
      Error('nombre', 'Escriba el nombre del archivo.')
    else if Length(Trim(A.Nombre)) > 100 then
      Error('nombre', 'El nombre admite como maximo 100 caracteres.');
    if A.Tipo <= 0 then
      Error('tipo', 'Elija el tipo de archivo.');
    Result := L.ToArray;
  finally
    L.Free;
  end;
end;

function NombreCampoImagen(ACampo: TCampoImagen): string;
begin
  if ACampo = ciCroquis then
    Result := 'croquis'
  else
    Result := 'Foto';
end;

function GuardarArchivo(Conn: TFDConnection; const A: TArchivo): Integer;
var
  Errores: TArray<TErrorCampo>;
  Q: TFDQuery;
  V: Variant;
begin
  Errores := ValidarArchivo(A);
  if Length(Errores) > 0 then
    raise EArchivoInvalido.Create(Errores[0].Mensaje);
  Conn.StartTransaction;
  try
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := Conn;
      if A.Cod = 0 then
      begin
        V := Conn.ExecSQLScalar('SELECT MAX(Cod) FROM cl_ArchivosGestion');
        if VarIsNull(V) or VarIsEmpty(V) then
          Result := 1
        else
          Result := Integer(V) + 1;
        Q.SQL.Text := 'INSERT INTO cl_ArchivosGestion (Cod, nombreArchivo, Tipo, Idresp) ' +
          'VALUES (:c, :n, :t, :r)';
      end
      else
      begin
        Result := A.Cod;
        Q.SQL.Text := 'UPDATE cl_ArchivosGestion SET nombreArchivo = :n, Tipo = :t, ' +
          'Idresp = :r WHERE Cod = :c';
      end;
      Q.ParamByName('c').DataType := ftInteger;
      Q.ParamByName('c').AsInteger := Result;
      Q.ParamByName('n').DataType := ftString;
      Q.ParamByName('n').AsString := Trim(A.Nombre);
      Q.ParamByName('t').DataType := ftInteger;
      Q.ParamByName('t').AsInteger := A.Tipo;
      Q.ParamByName('r').DataType := ftInteger;
      if A.Idresp > 0 then
        Q.ParamByName('r').AsInteger := A.Idresp
      else
        Q.ParamByName('r').Clear;
      Q.ExecSQL;
    finally
      Q.Free;
    end;
    Conn.Commit;
  except
    Conn.Rollback;
    raise;
  end;
end;

function LeerDescripcion(Conn: TFDConnection; ACod: Integer): string;
begin
  Result := VarToStr(Conn.ExecSQLScalar(
    'SELECT Descripcion FROM cl_ArchivosGestion WHERE Cod = :c', [ACod]));
end;

procedure GuardarDescripcion(Conn: TFDConnection; ACod: Integer; const ATexto: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'UPDATE cl_ArchivosGestion SET Descripcion = :d WHERE Cod = :c';
    Q.ParamByName('d').DataType := ftMemo;
    if ATexto = '' then
      Q.ParamByName('d').Clear
    else
      Q.ParamByName('d').AsMemo := ATexto;
    Q.ParamByName('c').DataType := ftInteger;
    Q.ParamByName('c').AsInteger := ACod;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function LeerImagen(Conn: TFDConnection; ACod: Integer; ACampo: TCampoImagen): TBytes;
var
  Q: TFDQuery;
begin
  SetLength(Result, 0);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT ' + NombreCampoImagen(ACampo) +
      ' FROM cl_ArchivosGestion WHERE Cod = :c';
    Q.ParamByName('c').AsInteger := ACod;
    Q.Open;
    if (not Q.Eof) and (not Q.Fields[0].IsNull) then
      Result := Q.Fields[0].AsBytes;
  finally
    Q.Free;
  end;
end;

procedure GuardarImagen(Conn: TFDConnection; ACod: Integer; ACampo: TCampoImagen;
  const ABytes: TBytes);
var
  Q: TFDQuery;
begin
  if Length(ABytes) = 0 then
  begin
    QuitarImagen(Conn, ACod, ACampo);
    Exit;
  end;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'UPDATE cl_ArchivosGestion SET ' + NombreCampoImagen(ACampo) +
      ' = :b WHERE Cod = :c';
    Q.ParamByName('b').DataType := ftBlob;
    Q.ParamByName('b').SetBlobRawData(Length(ABytes), @ABytes[0]);
    Q.ParamByName('c').DataType := ftInteger;
    Q.ParamByName('c').AsInteger := ACod;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure QuitarImagen(Conn: TFDConnection; ACod: Integer; ACampo: TCampoImagen);
begin
  Conn.ExecSQL('UPDATE cl_ArchivosGestion SET ' + NombreCampoImagen(ACampo) +
    ' = NULL WHERE Cod = :c', [ACod]);
end;

function ContarUsoArchivo(Conn: TFDConnection; ACod: Integer): Integer;
begin
  Result := Integer(Conn.ExecSQLScalar(
    'SELECT COUNT(*) FROM cl_subseries WHERE archivo = :c', [ACod]));
  Result := Result + Integer(Conn.ExecSQLScalar(
    'SELECT COUNT(*) FROM tb_SeriesDatos WHERE Archivo = :c', [ACod]));
  Result := Result + Integer(Conn.ExecSQLScalar(
    'SELECT COUNT(*) FROM tb_Serietree WHERE Archivo = :c', [ACod]));
  Result := Result + Integer(Conn.ExecSQLScalar(
    'SELECT COUNT(*) FROM TB_PrestamosDocumentos WHERE Archivo = :c', [ACod]));
end;

procedure EliminarArchivo(Conn: TFDConnection; ACod: Integer);
var
  Usos: Integer;
  E: EArchivoEnUso;
begin
  Usos := ContarUsoArchivo(Conn, ACod);
  if Usos > 0 then
  begin
    E := EArchivoEnUso.CreateFmt('El archivo no se puede eliminar: lo usan %d ' +
      'subserie(s), documento(s) o pr'#233'stamo(s).', [Usos]);
    E.Usos := Usos;
    raise E;
  end;
  Conn.ExecSQL('DELETE FROM cl_ArchivosGestion WHERE Cod = :c', [ACod]);
end;

end.
