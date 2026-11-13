unit UPrestadosSql;

{ ---------------------------------------------------------------------------
  SQL de "documentos prestados", compartido por la pantalla de inicio del nodo
  (UInicioDatos) y la lista de documentos (UDocumentoVistaDatos). Sin VCL ni
  FireDAC: solo texto.

  Un documento esta prestado si lo retiene un prestamo ABIERTO:
    - nuevos: prc_bloqueo de un proceso de tipo prestamo (F1 en adelante);
    - viejos: TB_PrestamosDocumentos con su TB_Prestamos sin devolucion ni
      cancelacion (mientras haya prestamos de la pantalla vieja sin migrar o se
      use procesos_clasico.flag).
  Las dos mitades se UNEN (UNION, sin ALL): un documento migrado que sigue
  figurando abierto en las tablas viejas cuenta una sola vez.

  Las columnas de documento se llaman como en tb_SeriesDatos (alias H). Donde
  aparece [filtro] el llamador pone la condicion de alcance (FiltroDocumentos).
  --------------------------------------------------------------------------- }

interface

{ Documentos (H.IdEstructura, H.id, H.codsubs, H.Codigodoc, H.fecha, H.version)
  retenidos por prestamos nuevos abiertos. Lleva [filtro]. }
function SqlPrestadosNuevos: string;

{ Lo mismo para los prestamos viejos abiertos. Lleva [filtro]. }
function SqlPrestadosViejos: string;

{ Union de las dos anteriores, sin duplicados. Lleva [filtro] dos veces. }
function SqlPrestadosCombinados: string;

{ Fecha, Version y Codigodoc de los documentos prestados de una subserie
  (parametros :est, :id y :cs), de ambas fuentes y sin duplicados. }
function SqlClavesPrestadasDeSubserie: string;

implementation

const
  COLUMNAS_H = 'H.IdEstructura, H.id, H.codsubs, H.Codigodoc, H.fecha, H.version';

function SqlPrestadosNuevos: string;
begin
  Result := 'SELECT ' + COLUMNAS_H + ' FROM (prc_bloqueo B INNER JOIN prc_proceso P ON ' +
    'P.IdProceso = B.IdProceso) INNER JOIN tb_SeriesDatos H ON ' +
    'H.IdEstructura = B.IdEstructura AND H.id = B.id AND H.codsubs = B.codsubs ' +
    'AND H.Codigodoc = B.Codigodoc AND H.fecha = B.fecha AND H.version = B.version ' +
    'WHERE P.Tipo = ''P'' AND ({filtro})';
end;

function SqlPrestadosViejos: string;
begin
  Result := 'SELECT ' + COLUMNAS_H + ' FROM (TB_PrestamosDocumentos D INNER JOIN ' +
    'TB_Prestamos P ON P.IdEstructura = D.IdEstructura AND P.id = D.id AND ' +
    'P.IdPrestamo = D.IdPrestamo) INNER JOIN tb_SeriesDatos H ON ' +
    'H.IdEstructura = D.IdEstructura AND H.id = D.id AND H.codsubs = D.codsubs ' +
    'AND H.Codigodoc = D.Codigodoc AND H.fecha = D.fecha AND H.version = D.version ' +
    'WHERE P.FDevolucion IS NULL AND P.FCancelacion IS NULL AND ({filtro})';
end;

function SqlPrestadosCombinados: string;
begin
  Result := SqlPrestadosViejos + ' UNION ' + SqlPrestadosNuevos;
end;

function SqlClavesPrestadasDeSubserie: string;
begin
  Result := 'SELECT D.fecha AS Fecha, D.version AS Version, D.Codigodoc AS Codigodoc ' +
    'FROM TB_PrestamosDocumentos D INNER JOIN TB_Prestamos P ON ' +
    'P.IdEstructura = D.IdEstructura AND P.id = D.id AND P.IdPrestamo = D.IdPrestamo ' +
    'WHERE D.IdEstructura = :est AND D.id = :id AND D.codsubs = :cs ' +
    'AND P.FDevolucion IS NULL AND P.FCancelacion IS NULL ' +
    'UNION ' +
    'SELECT B.fecha AS Fecha, B.version AS Version, B.Codigodoc AS Codigodoc ' +
    'FROM prc_bloqueo B INNER JOIN prc_proceso P ON P.IdProceso = B.IdProceso ' +
    'WHERE P.Tipo = ''P'' AND B.IdEstructura = :est AND B.id = :id AND B.codsubs = :cs';
end;

end.
