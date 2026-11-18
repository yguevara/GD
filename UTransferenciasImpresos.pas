unit UTransferenciasImpresos;

{ ---------------------------------------------------------------------------
  Impresos oficiales de la transferencia (FastReport):

    - Relacion de entrega para las transferencias documentales (Anexo 16 del Manual
      de procedimientos GD): una linea por caja; la firman quien entrega y quien
      recibe, y el archivo receptor completa fecha y numero de entrada;
    - Etiquetas de caja: una pagina por caja con su listado de documentos (el Manual
      pide el listado en el exterior de cada caja).

  Los informes (MAISEL REPORT/Report/rRelacionEntrega.fr3 y rEtiquetasCaja.fr3, en
  la carpeta Report junto al ejecutable) se pueden retocar con el disenador de
  FastReport. Sin conexion ni credenciales (ver UImpresosComun). Variables y campos:

    Relacion : variables Empresa, Remitente, FTransferencia, Numero, EntregadoPor;
               dataset "Relacion" (Numero, Fechas, Tipo, Descripcion, Caja).
    Etiquetas: variables Remitente, Numero; dataset "Etiquetas" (Caja, Codigo,
               Titulo, CajaDesc, CajaFechas, CajaUnidades), ordenado por caja.

  Prepararxxx devuelve el informe listo para mostrar o exportar; el llamador lo
  libera (los datos viajan dentro del informe).
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, frxClass, UTransferenciasReglas,
  UTransferenciasDatos;

type
  TDatosRelacion = record
    Empresa, Remitente, Numero, EntregadoPor: string;
    FTransferencia: TDateTime;
  end;

  { Un documento con los datos de su caja (se repiten en cada fila de la caja). }
  TDocumentoCaja = record
    Caja: Integer;
    Codigo, Titulo, CajaDesc: string;
    Desde, Hasta: TDateTime;
    CajaUnidades: Integer;
  end;

  { Registro topografico (Anexo 18): lo que firma el archivo receptor. }
  TDatosTopografico = record
    Empresa, Archivo, Numero, NumRegistro, RecibidoPor: string;
    FRecepcion: TDateTime;
  end;

function PrepararRelacion(const Fr3: string; const D: TDatosRelacion;
  const Lineas: TArray<TLineaRelacion>): TfrxReport;
function PrepararRegistroTopografico(const Fr3: string; const D: TDatosTopografico;
  const Lineas: TArray<TLineaTopografia>): TfrxReport;
function PrepararEtiquetas(const Fr3: string; const D: TDatosRelacion;
  const Docs: TArray<TDocumentoCaja>): TfrxReport;

{ Leen de la base y muestran la vista previa. CarpetaReportes termina en barra. }
procedure ImprimirRelacion(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);
procedure ImprimirEtiquetas(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);
procedure ImprimirRegistroTopografico(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);

implementation

uses
  System.Classes, System.Variants, Data.DB, UImpresosComun;

const
  ARCHIVO_RELACION = 'rRelacionEntrega.fr3';
  ARCHIVO_ETIQUETAS = 'rEtiquetasCaja.fr3';
  ARCHIVO_TOPOGRAFICO = 'rRegistroTopografico.fr3';

function PrepararRelacion(const Fr3: string; const D: TDatosRelacion;
  const Lineas: TArray<TLineaRelacion>): TfrxReport;
var
  Tabla: TFDMemTable;
  L: TLineaRelacion;
begin
  Result := TfrxReport.Create(nil);
  try
    Result.LoadFromFile(Fr3);
    Result.Variables['Empresa'] := CadenaFr(D.Empresa);
    Result.Variables['Remitente'] := CadenaFr(D.Remitente);
    Result.Variables['FTransferencia'] := CadenaFr(FechaTexto(D.FTransferencia));
    Result.Variables['Numero'] := CadenaFr(D.Numero);
    Result.Variables['EntregadoPor'] := CadenaFr(D.EntregadoPor);
    Tabla := NuevaTablaMemoria(Result, ['Numero', 'Fechas', 'Tipo', 'Descripcion', 'Caja'],
      [10, 30, 100, 255, 10]);
    for L in Lineas do
    begin
      Tabla.Append;
      Tabla.FieldByName('Numero').AsString := IntToStr(L.Numero);
      Tabla.FieldByName('Fechas').AsString := RangoTexto(L.Desde, L.Hasta);
      Tabla.FieldByName('Tipo').AsString := L.Tipo;
      Tabla.FieldByName('Descripcion').AsString := DescripcionConDocs(L.Descripcion,
        L.Unidades);
      Tabla.FieldByName('Caja').AsString := IntToStr(L.Caja);
      Tabla.Post;
    end;
    ConectarDataset(Result, Tabla, 'Relacion', 'MasterData1');
  except
    Result.Free;
    raise;
  end;
end;

function PrepararRegistroTopografico(const Fr3: string; const D: TDatosTopografico;
  const Lineas: TArray<TLineaTopografia>): TfrxReport;
var
  Tabla: TFDMemTable;
  L: TLineaTopografia;
begin
  Result := TfrxReport.Create(nil);
  try
    Result.LoadFromFile(Fr3);
    Result.Variables['Empresa'] := CadenaFr(D.Empresa);
    Result.Variables['Archivo'] := CadenaFr(D.Archivo);
    Result.Variables['Numero'] := CadenaFr(D.Numero);
    Result.Variables['NumRegistro'] := CadenaFr(D.NumRegistro);
    Result.Variables['FRecepcion'] := CadenaFr(FechaTexto(D.FRecepcion));
    Result.Variables['RecibidoPor'] := CadenaFr(D.RecibidoPor);
    Tabla := NuevaTablaMemoria(Result, ['Caja', 'Descripcion', 'Fechas', 'Deposito',
      'Gaveta', 'Posicion'], [10, 255, 30, 255, 20, 10]);
    for L in Lineas do
    begin
      Tabla.Append;
      Tabla.FieldByName('Caja').AsString := IntToStr(L.Caja);
      Tabla.FieldByName('Descripcion').AsString := DescripcionConDocs(L.Descripcion,
        L.Unidades);
      Tabla.FieldByName('Fechas').AsString := RangoTexto(L.Desde, L.Hasta);
      Tabla.FieldByName('Deposito').AsString := L.Deposito;
      Tabla.FieldByName('Gaveta').AsString := L.Gaveta;
      Tabla.FieldByName('Posicion').AsString := L.Posicion;
      Tabla.Post;
    end;
    ConectarDataset(Result, Tabla, 'Topografico', 'MasterData1');
  except
    Result.Free;
    raise;
  end;
end;

function PrepararEtiquetas(const Fr3: string; const D: TDatosRelacion;
  const Docs: TArray<TDocumentoCaja>): TfrxReport;
var
  Tabla: TFDMemTable;
  X: TDocumentoCaja;
begin
  Result := TfrxReport.Create(nil);
  try
    Result.LoadFromFile(Fr3);
    Result.Variables['Remitente'] := CadenaFr(D.Remitente);
    Result.Variables['Numero'] := CadenaFr(D.Numero);
    Tabla := NuevaTablaMemoria(Result, ['Caja', 'Codigo', 'Titulo', 'CajaDesc',
      'CajaFechas', 'CajaUnidades'], [10, 30, 255, 255, 40, 10]);
    for X in Docs do
    begin
      Tabla.Append;
      Tabla.FieldByName('Caja').AsString := Format('%.4d', [X.Caja]);
      Tabla.FieldByName('Codigo').AsString := X.Codigo;
      Tabla.FieldByName('Titulo').AsString := X.Titulo;
      Tabla.FieldByName('CajaDesc').AsString := X.CajaDesc;
      Tabla.FieldByName('CajaFechas').AsString := RangoTexto(X.Desde, X.Hasta);
      Tabla.FieldByName('CajaUnidades').AsString := IntToStr(X.CajaUnidades);
      Tabla.Post;
    end;
    ConectarDataset(Result, Tabla, 'Etiquetas', 'MasterData1');
  except
    Result.Free;
    raise;
  end;
end;

{ Cabecera de la transferencia: numero, remitente, entrega. }
procedure LeerCabecera(Conn: TFDConnection; IdProceso: Integer; out D: TDatosRelacion);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT p.Numero, N.etiqueta AS Remitente, t.FEntrega, t.EntregadoPor ' +
      'FROM (prc_proceso p INNER JOIN prc_transferencia t ON t.IdProceso = p.IdProceso) ' +
      'LEFT JOIN tb_tree N ON N.IdEstructura = p.IdEstructura AND N.id = p.IdNodo ' +
      'WHERE p.IdProceso = :i';
    Q.ParamByName('i').AsInteger := IdProceso;
    Q.Open;
    if Q.IsEmpty then
      raise EArgumentException.Create('La transferencia no existe: ' + IntToStr(IdProceso));
    D.Empresa := EmpresaDe(Conn);
    D.Numero := Trim(Q.FieldByName('Numero').AsString);
    D.Remitente := Q.FieldByName('Remitente').AsString;
    D.EntregadoPor := Q.FieldByName('EntregadoPor').AsString;
    if Q.FieldByName('FEntrega').IsNull then
      D.FTransferencia := Date
    else
      D.FTransferencia := Q.FieldByName('FEntrega').AsDateTime;
  finally
    Q.Free;
  end;
end;

{ Cabecera del Registro topografico: transferencia, archivo receptor y recepcion. }
procedure LeerCabeceraTopografico(Conn: TFDConnection; IdProceso: Integer;
  out D: TDatosTopografico);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT p.Numero, t.NumRegistroEntrada, t.FRecepcion, t.RecibidoPor, ' +
      'a.nombreArchivo AS Archivo FROM ((prc_proceso p INNER JOIN prc_transferencia t ON ' +
      't.IdProceso = p.IdProceso) LEFT JOIN cl_ArchivosGestion a ON ' +
      'a.Cod = t.IdArchivoDestino) WHERE p.IdProceso = :i';
    Q.ParamByName('i').AsInteger := IdProceso;
    Q.Open;
    if Q.IsEmpty then
      raise EArgumentException.Create('La transferencia no existe: ' + IntToStr(IdProceso));
    D.Empresa := EmpresaDe(Conn);
    D.Numero := Trim(Q.FieldByName('Numero').AsString);
    D.Archivo := Q.FieldByName('Archivo').AsString;
    D.NumRegistro := Q.FieldByName('NumRegistroEntrada').AsString;
    D.RecibidoPor := Q.FieldByName('RecibidoPor').AsString;
    if Q.FieldByName('FRecepcion').IsNull then
      D.FRecepcion := Date
    else
      D.FRecepcion := Q.FieldByName('FRecepcion').AsDateTime;
  finally
    Q.Free;
  end;
end;

procedure ImprimirRegistroTopografico(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);
var
  D: TDatosTopografico;
  Rep: TfrxReport;
begin
  LeerCabeceraTopografico(Conn, IdProceso, D);
  Rep := PrepararRegistroTopografico(IncludeTrailingPathDelimiter(CarpetaReportes) +
    ARCHIVO_TOPOGRAFICO, D, LineasRegistroTopografico(CajasDeTransferencia(Conn, IdProceso)));
  try
    Rep.ShowReport;
  finally
    Rep.Free;
  end;
end;

procedure ImprimirRelacion(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);
var
  D: TDatosRelacion;
  Rep: TfrxReport;
begin
  LeerCabecera(Conn, IdProceso, D);
  Rep := PrepararRelacion(IncludeTrailingPathDelimiter(CarpetaReportes) + ARCHIVO_RELACION, D,
    RelacionDeEntrega(Conn, IdProceso));
  try
    Rep.ShowReport;
  finally
    Rep.Free;
  end;
end;

procedure ImprimirEtiquetas(Conn: TFDConnection; IdProceso: Integer;
  const CarpetaReportes: string);
var
  D: TDatosRelacion;
  Docs: TArray<TDocumentoCaja>;
  X: TDocumentoCaja;
  Q: TFDQuery;
  Lista: TArray<TDocumentoCaja>;
  Rep: TfrxReport;
  N: Integer;
begin
  LeerCabecera(Conn, IdProceso, D);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT u.Caja AS Caja, u.Codigodoc AS Codigo, H.titulodoc AS Titulo, ' +
      'c.Descripcion AS CajaDesc, c.FDesde AS Desde, c.FHasta AS Hasta, ' +
      'c.Unidades AS CajaUnidades FROM ((prc_unidad u INNER JOIN prc_caja c ON ' +
      'c.IdProceso = u.IdProceso AND c.Caja = u.Caja) LEFT JOIN tb_SeriesDatos H ON ' +
      'H.IdEstructura = u.IdEstructura AND H.id = u.id AND H.codsubs = u.codsubs AND ' +
      'H.Codigodoc = u.Codigodoc AND H.fecha = u.fecha AND H.version = u.version) ' +
      'WHERE u.IdProceso = :p AND u.Activa <> 0 ORDER BY u.Caja, u.fecha, u.Codigodoc';
    Q.ParamByName('p').AsInteger := IdProceso;
    Q.Open;
    Lista := nil;
    N := 0;
    while not Q.Eof do
    begin
      SetLength(Lista, N + 1);
      X.Caja := Q.FieldByName('Caja').AsInteger;
      X.Codigo := Q.FieldByName('Codigo').AsString;
      X.Titulo := Q.FieldByName('Titulo').AsString;
      X.CajaDesc := Q.FieldByName('CajaDesc').AsString;
      if Q.FieldByName('Desde').IsNull then
        X.Desde := 0
      else
        X.Desde := Q.FieldByName('Desde').AsDateTime;
      if Q.FieldByName('Hasta').IsNull then
        X.Hasta := 0
      else
        X.Hasta := Q.FieldByName('Hasta').AsDateTime;
      X.CajaUnidades := Q.FieldByName('CajaUnidades').AsInteger;
      Lista[N] := X;
      Inc(N);
      Q.Next;
    end;
    Docs := Lista;
  finally
    Q.Free;
  end;
  if Length(Docs) = 0 then
    raise EArgumentException.Create('La transferencia no tiene cajas numeradas.');
  Rep := PrepararEtiquetas(IncludeTrailingPathDelimiter(CarpetaReportes) + ARCHIVO_ETIQUETAS, D, Docs);
  try
    Rep.ShowReport;
  finally
    Rep.Free;
  end;
end;

end.
