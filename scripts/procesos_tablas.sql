-- Procesos archivisticos (prestamo, transferencia, depuracion): tablas comunes.
-- Copia documental del DDL de SQL Server de UEsquemaProcesos.pas; la aplicacion
-- lo crea sola al conectar (UpDateDB). Es idempotente: se puede ejecutar varias veces.
-- Tipo: 'P' prestamo, 'T' transferencia, 'D' depuracion.
-- Estado: 'C' en curso, 'F' finalizado, 'X' cancelado.

IF OBJECT_ID('dbo.prc_proceso', 'U') IS NULL
CREATE TABLE prc_proceso (
  IdProceso INT IDENTITY(1,1) NOT NULL,
  Tipo VARCHAR(1) NOT NULL,
  Anio INT NOT NULL,
  Consecutivo INT NOT NULL,
  Numero VARCHAR(20) NOT NULL,
  Estado VARCHAR(1) NOT NULL,
  Paso INT NOT NULL,
  IdEstructura VARCHAR(50) NOT NULL,
  IdNodo INT NOT NULL,
  Creado DATETIME NULL,
  CreadoPor VARCHAR(100) NULL,
  Cerrado DATETIME NULL,
  CONSTRAINT PK_prc_proceso PRIMARY KEY (IdProceso),
  CONSTRAINT UQ_prc_proceso_numero UNIQUE (Tipo, Anio, Consecutivo),
  CONSTRAINT FK_prc_proceso_tree FOREIGN KEY (IdEstructura, IdNodo)
    REFERENCES tb_tree(IdEstructura, id)
);

IF OBJECT_ID('dbo.prc_unidad', 'U') IS NULL
CREATE TABLE prc_unidad (
  IdProceso INT NOT NULL,
  IdEstructura VARCHAR(50) NOT NULL,
  id INT NOT NULL,
  codsubs VARCHAR(50) NOT NULL,
  Codigodoc VARCHAR(20) NOT NULL,
  fecha DATETIME NOT NULL,
  version VARCHAR(12) NOT NULL,
  Caja INT NULL,
  Activa BIT NOT NULL DEFAULT 1,
  CONSTRAINT PK_prc_unidad PRIMARY KEY (IdProceso, IdEstructura, id, codsubs, Codigodoc, fecha, version),
  CONSTRAINT FK_prc_unidad_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF OBJECT_ID('dbo.prc_evento', 'U') IS NULL
CREATE TABLE prc_evento (
  IdEvento INT IDENTITY(1,1) NOT NULL,
  IdProceso INT NOT NULL,
  Fecha DATETIME NULL,
  Usuario VARCHAR(100) NULL,
  Paso INT NULL,
  Texto VARCHAR(500) NULL,
  CONSTRAINT PK_prc_evento PRIMARY KEY (IdEvento),
  CONSTRAINT FK_prc_evento_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF OBJECT_ID('dbo.prc_autorizacion', 'U') IS NULL
CREATE TABLE prc_autorizacion (
  IdProceso INT NOT NULL,
  Organo VARCHAR(1) NOT NULL,
  NumActa VARCHAR(30) NOT NULL,
  NumAcuerdo VARCHAR(30) NOT NULL,
  Fecha DATETIME NULL,
  RegistradoPor VARCHAR(100) NULL,
  CONSTRAINT PK_prc_autorizacion PRIMARY KEY (IdProceso),
  CONSTRAINT FK_prc_autorizacion_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF OBJECT_ID('dbo.prc_bloqueo', 'U') IS NULL
CREATE TABLE prc_bloqueo (
  IdEstructura VARCHAR(50) NOT NULL,
  id INT NOT NULL,
  codsubs VARCHAR(50) NOT NULL,
  Codigodoc VARCHAR(20) NOT NULL,
  fecha DATETIME NOT NULL,
  version VARCHAR(12) NOT NULL,
  IdProceso INT NOT NULL,
  CONSTRAINT PK_prc_bloqueo PRIMARY KEY (IdEstructura, id, codsubs, Codigodoc, fecha, version),
  CONSTRAINT FK_prc_bloqueo_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF OBJECT_ID('dbo.prc_prestamo', 'U') IS NULL
CREATE TABLE prc_prestamo (
  IdProceso INT NOT NULL,
  Solicitante VARCHAR(150) NOT NULL,
  Carnet VARCHAR(20) NULL,
  Entidad VARCHAR(150) NULL,
  TipoUsuario VARCHAR(1) NOT NULL,
  FEntrega DATETIME NULL,
  FLimite DATETIME NULL,
  FDevolucion DATETIME NULL,
  AtendidoPor VARCHAR(100) NULL,
  Obs VARCHAR(255) NULL,
  Completo BIT NULL,
  IdPrestamoViejo VARCHAR(12) NULL,
  CONSTRAINT PK_prc_prestamo PRIMARY KEY (IdProceso),
  CONSTRAINT FK_prc_prestamo_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF OBJECT_ID('dbo.prc_transferencia', 'U') IS NULL
CREATE TABLE prc_transferencia (
  IdProceso INT NOT NULL,
  FPrevista DATETIME NULL,
  FEntrega DATETIME NULL,
  EntregadoPor VARCHAR(100) NULL,
  Obs VARCHAR(255) NULL,
  CONSTRAINT PK_prc_transferencia PRIMARY KEY (IdProceso),
  CONSTRAINT FK_prc_transferencia_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF OBJECT_ID('dbo.prc_cronograma', 'U') IS NULL
CREATE TABLE prc_cronograma (
  IdCronograma INT IDENTITY(1,1) NOT NULL,
  Anio INT NOT NULL,
  IdEstructura VARCHAR(50) NOT NULL,
  IdNodo INT NOT NULL,
  FPrevista DATETIME NOT NULL,
  IdProceso INT NULL,
  CONSTRAINT PK_prc_cronograma PRIMARY KEY (IdCronograma),
  CONSTRAINT UQ_prc_cronograma UNIQUE (Anio, IdEstructura, IdNodo),
  CONSTRAINT FK_prc_cronograma_tree FOREIGN KEY (IdEstructura, IdNodo)
    REFERENCES tb_tree(IdEstructura, id)
);

IF OBJECT_ID('dbo.prc_caja', 'U') IS NULL
CREATE TABLE prc_caja (
  IdProceso INT NOT NULL,
  Caja INT NOT NULL,
  Tipo VARCHAR(100) NULL,
  Descripcion VARCHAR(255) NULL,
  FDesde DATETIME NULL,
  FHasta DATETIME NULL,
  Unidades INT NOT NULL,
  CONSTRAINT PK_prc_caja PRIMARY KEY (IdProceso, Caja),
  CONSTRAINT FK_prc_caja_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF OBJECT_ID('dbo.prc_verificacion', 'U') IS NULL
CREATE TABLE prc_verificacion (
  IdProceso INT NOT NULL,
  Codigo VARCHAR(30) NOT NULL,
  Marcada BIT NOT NULL DEFAULT 0,
  CONSTRAINT PK_prc_verificacion PRIMARY KEY (IdProceso, Codigo),
  CONSTRAINT FK_prc_verificacion_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_unidad_nodo' AND object_id = OBJECT_ID('dbo.prc_unidad'))
CREATE INDEX IX_prc_unidad_nodo ON prc_unidad (IdEstructura, id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_proceso_estado' AND object_id = OBJECT_ID('dbo.prc_proceso'))
CREATE INDEX IX_prc_proceso_estado ON prc_proceso (Estado, Tipo);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_evento_proceso' AND object_id = OBJECT_ID('dbo.prc_evento'))
CREATE INDEX IX_prc_evento_proceso ON prc_evento (IdProceso);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_prestamo_limite' AND object_id = OBJECT_ID('dbo.prc_prestamo'))
CREATE INDEX IX_prc_prestamo_limite ON prc_prestamo (FLimite);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_unidad_caja' AND object_id = OBJECT_ID('dbo.prc_unidad'))
CREATE INDEX IX_prc_unidad_caja ON prc_unidad (IdProceso, Caja);

-- Transferencias: recepcion (paso 5) y ubicacion (paso 6), version minima y F3.
IF COL_LENGTH('prc_transferencia', 'FRecepcion') IS NULL ALTER TABLE prc_transferencia ADD FRecepcion DATETIME NULL;
IF COL_LENGTH('prc_transferencia', 'RecibidoPor') IS NULL ALTER TABLE prc_transferencia ADD RecibidoPor VARCHAR(100) NULL;
IF COL_LENGTH('prc_transferencia', 'Ubicacion') IS NULL ALTER TABLE prc_transferencia ADD Ubicacion VARCHAR(255) NULL;
IF COL_LENGTH('prc_transferencia', 'IdArchivoDestino') IS NULL ALTER TABLE prc_transferencia ADD IdArchivoDestino SMALLINT NULL;
IF COL_LENGTH('prc_transferencia', 'NumRegistroEntrada') IS NULL ALTER TABLE prc_transferencia ADD NumRegistroEntrada VARCHAR(30) NULL;

-- Cajas: ubicacion y estado (P pendiente, R recibida, Q cuarentena, F faltante; NULL = pendiente).
IF COL_LENGTH('prc_caja', 'Deposito') IS NULL ALTER TABLE prc_caja ADD Deposito VARCHAR(255) NULL;
IF COL_LENGTH('prc_caja', 'Gaveta') IS NULL ALTER TABLE prc_caja ADD Gaveta VARCHAR(20) NULL;
IF COL_LENGTH('prc_caja', 'Posicion') IS NULL ALTER TABLE prc_caja ADD Posicion VARCHAR(10) NULL;
IF COL_LENGTH('prc_caja', 'Estado') IS NULL ALTER TABLE prc_caja ADD Estado VARCHAR(1) NULL;
IF COL_LENGTH('prc_caja', 'Conservacion') IS NULL ALTER TABLE prc_caja ADD Conservacion VARCHAR(255) NULL;

IF OBJECT_ID('dbo.prc_incidencia', 'U') IS NULL
CREATE TABLE prc_incidencia (
  IdIncidencia INT IDENTITY(1,1) NOT NULL,
  IdProceso INT NOT NULL,
  Caja INT NULL,
  Tipo VARCHAR(20) NOT NULL,
  Descripcion VARCHAR(255) NULL,
  FechaLimite DATETIME NULL,
  Estado VARCHAR(1) NOT NULL,
  Usuario VARCHAR(100) NULL,
  Fecha DATETIME NULL,
  CONSTRAINT PK_prc_incidencia PRIMARY KEY (IdIncidencia),
  CONSTRAINT FK_prc_incidencia_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_incidencia_proceso' AND object_id = OBJECT_ID('dbo.prc_incidencia'))
CREATE INDEX IX_prc_incidencia_proceso ON prc_incidencia (IdProceso);

-- F4: acta de depuracion y testigos (Via: I incineracion, T trituracion; Origen: C Comision, G gestion, O otro).
IF OBJECT_ID('dbo.prc_depuracion', 'U') IS NULL
CREATE TABLE prc_depuracion (
  IdProceso INT NOT NULL,
  Lugar VARCHAR(255) NULL,
  Via VARCHAR(1) NULL,
  FPrevista DATETIME NULL,
  FEjecucion DATETIME NULL,
  MuestraDesc VARCHAR(255) NULL,
  MuestraDonde VARCHAR(255) NULL,
  CONSTRAINT PK_prc_depuracion PRIMARY KEY (IdProceso),
  CONSTRAINT FK_prc_depuracion_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF OBJECT_ID('dbo.prc_testigo', 'U') IS NULL
CREATE TABLE prc_testigo (
  IdTestigo INT IDENTITY(1,1) NOT NULL,
  IdProceso INT NOT NULL,
  Nombre VARCHAR(100) NOT NULL,
  Cargo VARCHAR(100) NULL,
  Origen VARCHAR(1) NOT NULL,
  Firmo BIT NOT NULL DEFAULT 0,
  CONSTRAINT PK_prc_testigo PRIMARY KEY (IdTestigo),
  CONSTRAINT FK_prc_testigo_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_testigo_proceso' AND object_id = OBJECT_ID('dbo.prc_testigo'))
CREATE INDEX IX_prc_testigo_proceso ON prc_testigo (IdProceso);


-- F4c: ficheros digitales de los documentos eliminados (Estado: P pendiente, R retirado, N ya no existia,
-- L solo lectura/FTP, M retirado a mano, E error).
IF OBJECT_ID('dbo.prc_fichero_retiro', 'U') IS NULL
CREATE TABLE prc_fichero_retiro (
  IdProceso INT NOT NULL,
  IdEstructura VARCHAR(50) NOT NULL,
  id INT NOT NULL,
  codsubs VARCHAR(50) NOT NULL,
  Codigodoc VARCHAR(20) NOT NULL,
  fecha DATETIME NOT NULL,
  version VARCHAR(12) NOT NULL,
  idhijo INT NOT NULL,
  UrlRaiz VARCHAR(50) NULL,
  Path VARCHAR(255) NULL,
  Nombre VARCHAR(255) NULL,
  Estado VARCHAR(1) NOT NULL,
  Mensaje VARCHAR(255) NULL,
  FechaRetiro DATETIME NULL,
  CONSTRAINT PK_prc_fichero_retiro PRIMARY KEY (IdProceso, IdEstructura, id, codsubs, Codigodoc, fecha, version, idhijo),
  CONSTRAINT FK_prc_fichero_retiro_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);
