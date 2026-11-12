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
  System.SysUtils, FireDAC.Comp.Client, UServidoresDatos;

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

implementation

uses
  System.Generics.Collections;

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

end.
