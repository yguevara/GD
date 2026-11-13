unit UPrestamosImpresos;

{ ---------------------------------------------------------------------------
  Impresos oficiales del prestamo (FastReport):

    - Solicitud de consulta o prestamo de documentos (Anexo 8.2 del Manual Marco),
      que el solicitante firma al recibir los documentos;
    - Registro interno de prestamo de documentos (Anexo 8.3), por ano.

  Los informes (MAISEL REPORT/Report/rSolicitudPrestamo.fr3 y
  rRegistroPrestamos.fr3, en la carpeta Report junto al ejecutable) se pueden
  retocar con el disenador de FastReport. NO llevan conexion ni credenciales: la
  aplicacion les pasa los datos con variables y con un TfrxDBDataset sobre una
  tabla en memoria. Las variables y los campos que usan estan en el .fr3:

    Solicitud: variables Empresa, Numero, Solicitante, Carnet, Entidad,
               TipoUsuario, FEntrega, FLimite, Atendido; dataset "Documentos"
               (Codigo, Titulo, Ubicacion).
    Registro : variables Empresa, Anio; dataset "Registro" (Numero, Solicitante,
               Serie, FSolicitud, FDevolucion, Entidad, Observaciones).

  Prepararxxx devuelve el informe listo para mostrar (ShowReport) o exportar; el
  llamador lo libera (los datos viajan dentro del informe).
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, frxClass, UAlcance, UPrestamosDatos;

type
  TDatosSolicitud = record
    Empresa, Numero, Solicitante, Carnet, Entidad, TipoUsuario, Atendido: string;
    FEntrega, FLimite: TDateTime;    // 0 = sin fecha
  end;

  TLineaRegistro = record
    Numero, Solicitante, Serie, Entidad, Observaciones: string;
    FSolicitud, FDevolucion: TDateTime;
  end;

{ Carga Fr3 y le pone los datos de la solicitud. }
function PrepararSolicitud(const Fr3: string; const D: TDatosSolicitud;
  const Docs: TArray<TDocumentoBuscado>): TfrxReport;

{ Carga Fr3 y le pone las lineas del registro del ano. }
function PrepararRegistro(const Fr3, Empresa: string; Anio: Integer;
  const Lineas: TArray<TLineaRegistro>): TfrxReport;

{ Lee de la base y muestra la vista previa. CarpetaReportes termina en barra. }
procedure ImprimirSolicitud(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);

procedure ImprimirRegistro(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Anio: Integer; const CarpetaReportes: string);

implementation

uses
  System.Classes, System.Generics.Collections, System.Variants, Data.DB,
  UImpresosComun;

const
  ARCHIVO_SOLICITUD = 'rSolicitudPrestamo.fr3';
  ARCHIVO_REGISTRO = 'rRegistroPrestamos.fr3';

function PrepararSolicitud(const Fr3: string; const D: TDatosSolicitud;
  const Docs: TArray<TDocumentoBuscado>): TfrxReport;
var
  Tabla: TFDMemTable;
  Doc: TDocumentoBuscado;
begin
  Result := TfrxReport.Create(nil);
  try
    Result.LoadFromFile(Fr3);
    Result.Variables['Empresa'] := CadenaFr(D.Empresa);
    Result.Variables['Numero'] := CadenaFr(D.Numero);
    Result.Variables['Solicitante'] := CadenaFr(D.Solicitante);
    Result.Variables['Carnet'] := CadenaFr(D.Carnet);
    Result.Variables['Entidad'] := CadenaFr(D.Entidad);
    Result.Variables['TipoUsuario'] := CadenaFr(D.TipoUsuario);
    Result.Variables['FEntrega'] := CadenaFr(FechaTexto(D.FEntrega));
    Result.Variables['FLimite'] := CadenaFr(FechaTexto(D.FLimite));
    Result.Variables['Atendido'] := CadenaFr(D.Atendido);
    Tabla := NuevaTablaMemoria(Result, ['Codigo', 'Titulo', 'Ubicacion'], [20, 255, 255]);
    for Doc in Docs do
    begin
      Tabla.Append;
      Tabla.FieldByName('Codigo').AsString := Doc.Unidad.CodigoDoc;
      Tabla.FieldByName('Titulo').AsString := Doc.Titulo;
      Tabla.FieldByName('Ubicacion').AsString := Doc.Ubicacion;
      Tabla.Post;
    end;
    ConectarDataset(Result, Tabla, 'Documentos', 'MasterData1');
  except
    Result.Free;
    raise;
  end;
end;

function PrepararRegistro(const Fr3, Empresa: string; Anio: Integer;
  const Lineas: TArray<TLineaRegistro>): TfrxReport;
var
  Tabla: TFDMemTable;
  L: TLineaRegistro;
begin
  Result := TfrxReport.Create(nil);
  try
    Result.LoadFromFile(Fr3);
    Result.Variables['Empresa'] := CadenaFr(Empresa);
    Result.Variables['Anio'] := CadenaFr(IntToStr(Anio));
    Tabla := NuevaTablaMemoria(Result, ['Numero', 'Solicitante', 'Serie', 'FSolicitud',
      'FDevolucion', 'Entidad', 'Observaciones'], [20, 150, 255, 12, 12, 150, 255]);
    for L in Lineas do
    begin
      Tabla.Append;
      Tabla.FieldByName('Numero').AsString := L.Numero;
      Tabla.FieldByName('Solicitante').AsString := L.Solicitante;
      Tabla.FieldByName('Serie').AsString := L.Serie;
      Tabla.FieldByName('FSolicitud').AsString := FechaTexto(L.FSolicitud);
      Tabla.FieldByName('FDevolucion').AsString := FechaTexto(L.FDevolucion);
      Tabla.FieldByName('Entidad').AsString := L.Entidad;
      Tabla.FieldByName('Observaciones').AsString := L.Observaciones;
      Tabla.Post;
    end;
    ConectarDataset(Result, Tabla, 'Registro', 'MasterData1');
  except
    Result.Free;
    raise;
  end;
end;

procedure ImprimirSolicitud(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);
var
  Q: TFDQuery;
  D: TDatosSolicitud;
  Docs: TArray<TDocumentoBuscado>;
  Rep: TfrxReport;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT p.Numero, r.Solicitante, r.Carnet, r.Entidad, r.TipoUsuario, ' +
      'r.FEntrega, r.FLimite, r.AtendidoPor FROM prc_proceso p INNER JOIN prc_prestamo r ' +
      'ON r.IdProceso = p.IdProceso WHERE p.IdProceso = :i';
    Q.ParamByName('i').AsInteger := IdProceso;
    Q.Open;
    if Q.IsEmpty then
      raise EArgumentException.Create('El prestamo no existe: ' + IntToStr(IdProceso));
    D.Empresa := EmpresaDe(Conn);
    D.Numero := Trim(Q.FieldByName('Numero').AsString);
    D.Solicitante := Q.FieldByName('Solicitante').AsString;
    D.Carnet := Q.FieldByName('Carnet').AsString;
    D.Entidad := Q.FieldByName('Entidad').AsString;
    if Trim(Q.FieldByName('TipoUsuario').AsString) = 'E' then
      D.TipoUsuario := 'Externo'
    else
      D.TipoUsuario := 'Interno';
    D.Atendido := Q.FieldByName('AtendidoPor').AsString;
    if Q.FieldByName('FEntrega').IsNull then
      D.FEntrega := 0
    else
      D.FEntrega := Q.FieldByName('FEntrega').AsDateTime;
    if Q.FieldByName('FLimite').IsNull then
      D.FLimite := 0
    else
      D.FLimite := Q.FieldByName('FLimite').AsDateTime;
  finally
    Q.Free;
  end;
  Docs := DocumentosDelPrestamo(Conn, IdProceso);
  Rep := PrepararSolicitud(CarpetaReportes + ARCHIVO_SOLICITUD, D, Docs);
  try
    Rep.ShowReport;
  finally
    Rep.Free;
  end;
end;

{ Series documentales de los documentos de cada prestamo del ano (una consulta). }
function SeriesPorPrestamo(Conn: TFDConnection; Anio: Integer): TDictionary<Integer, string>;
var
  Q: TFDQuery;
  Id: Integer;
  Actual: string;
begin
  Result := TDictionary<Integer, string>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT DISTINCT u.IdProceso AS IdProceso, S.serie AS Serie ' +
      'FROM ((prc_unidad u INNER JOIN prc_proceso p ON p.IdProceso = u.IdProceso) ' +
      'INNER JOIN cl_subseries SS ON SS.codsubs = u.codsubs) ' +
      'INNER JOIN cl_series S ON S.codserie = SS.codserie ' +
      'WHERE p.Tipo = ''P'' AND p.Anio = :a ORDER BY u.IdProceso, S.serie';
    Q.ParamByName('a').AsInteger := Anio;
    Q.Open;
    while not Q.Eof do
    begin
      Id := Q.FieldByName('IdProceso').AsInteger;
      if Result.TryGetValue(Id, Actual) then
        Result[Id] := Actual + ', ' + Trim(Q.FieldByName('Serie').AsString)
      else
        Result.Add(Id, Trim(Q.FieldByName('Serie').AsString));
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure ImprimirRegistro(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>;
  Anio: Integer; const CarpetaReportes: string);
var
  Filas: TArray<TPrestamoFila>;
  F: TPrestamoFila;
  Series: TDictionary<Integer, string>;
  Lineas: TList<TLineaRegistro>;
  L: TLineaRegistro;
  Rep: TfrxReport;
  S: string;
begin
  Filas := ListarPrestamos(Conn, Nodos, fpTodos, Now, '', 5000);
  Series := SeriesPorPrestamo(Conn, Anio);
  Lineas := TList<TLineaRegistro>.Create;
  try
    // del mas antiguo al mas reciente: es un libro de registro
    for F in Filas do
    begin
      if F.Anio <> Anio then
        Continue;
      L.Numero := F.Numero;
      L.Solicitante := F.Solicitante;
      if Series.TryGetValue(F.IdProceso, S) then
        L.Serie := S
      else
        L.Serie := '';
      L.FSolicitud := F.Creado;
      L.FDevolucion := F.FDevolucion;
      L.Entidad := F.Entidad;
      L.Observaciones := F.Obs;
      Lineas.Insert(0, L);
    end;
    Rep := PrepararRegistro(CarpetaReportes + ARCHIVO_REGISTRO, EmpresaDe(Conn), Anio,
      Lineas.ToArray);
  finally
    Lineas.Free;
    Series.Free;
  end;
  try
    Rep.ShowReport;
  finally
    Rep.Free;
  end;
end;

end.
