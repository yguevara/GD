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
  Codigodoc VARCHAR(20) NOT NULL,
  fecha DATETIME NOT NULL,
  version VARCHAR(12) NOT NULL,
  Caja INT NULL,
  Activa BIT NOT NULL DEFAULT 1,
  CONSTRAINT PK_prc_unidad PRIMARY KEY (IdProceso, IdEstructura, id, Codigodoc, fecha, version),
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
  Codigodoc VARCHAR(20) NOT NULL,
  fecha DATETIME NOT NULL,
  version VARCHAR(12) NOT NULL,
  IdProceso INT NOT NULL,
  CONSTRAINT PK_prc_bloqueo PRIMARY KEY (IdEstructura, id, Codigodoc, fecha, version),
  CONSTRAINT FK_prc_bloqueo_proceso FOREIGN KEY (IdProceso)
    REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE
);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_unidad_nodo' AND object_id = OBJECT_ID('dbo.prc_unidad'))
CREATE INDEX IX_prc_unidad_nodo ON prc_unidad (IdEstructura, id);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_proceso_estado' AND object_id = OBJECT_ID('dbo.prc_proceso'))
CREATE INDEX IX_prc_proceso_estado ON prc_proceso (Estado, Tipo);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_prc_evento_proceso' AND object_id = OBJECT_ID('dbo.prc_evento'))
CREATE INDEX IX_prc_evento_proceso ON prc_evento (IdProceso);
