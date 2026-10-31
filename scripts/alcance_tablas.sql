-- Copia documental del DDL que crea UEsquemaAlcance.CrearEsquemaAlcance (version SQL Server).
-- Aditivo e idempotente. La aplicacion lo ejecuta desde TUDM.UpDateDB; no hace falta correrlo a mano.

IF OBJECT_ID('dbo.tb_nodo_egd', 'U') IS NULL
CREATE TABLE tb_nodo_egd (
  IdEstructura VARCHAR(50) NOT NULL,
  id INT NOT NULL,
  user_id VARCHAR(100) NOT NULL,
  CONSTRAINT PK_tb_nodo_egd PRIMARY KEY (IdEstructura, id, user_id),
  CONSTRAINT FK_tb_nodo_egd_tree FOREIGN KEY (IdEstructura, id) REFERENCES tb_tree(IdEstructura, id),
  CONSTRAINT FK_tb_nodo_egd_user FOREIGN KEY (user_id) REFERENCES tb_user(nombreuser)
);
GO

IF OBJECT_ID('dbo.tb_usuario_subserie', 'U') IS NULL
CREATE TABLE tb_usuario_subserie (
  IdEstructura VARCHAR(50) NOT NULL,
  id INT NOT NULL,
  codsubs VARCHAR(50) NOT NULL,
  user_id VARCHAR(100) NOT NULL,
  CONSTRAINT PK_tb_usuario_subserie PRIMARY KEY (IdEstructura, id, codsubs, user_id),
  CONSTRAINT FK_tb_usuario_subserie_tree FOREIGN KEY (IdEstructura, id) REFERENCES tb_tree(IdEstructura, id),
  CONSTRAINT FK_tb_usuario_subserie_user FOREIGN KEY (user_id) REFERENCES tb_user(nombreuser)
);
GO

-- Captura masiva: solo esquema, sin uso todavia (sin claves foraneas a tablas de documentos).
IF OBJECT_ID('dbo.tb_lote_captura', 'U') IS NULL
CREATE TABLE tb_lote_captura (
  idlote INT IDENTITY(1,1) NOT NULL,
  fecha DATETIME NULL,
  user_id VARCHAR(100) NULL,
  origen VARCHAR(255) NULL,
  estado VARCHAR(20) NULL,
  IdEstructura VARCHAR(50) NULL,
  id INT NULL,
  codsubs VARCHAR(50) NULL,
  CONSTRAINT PK_tb_lote_captura PRIMARY KEY (idlote)
);
GO

IF OBJECT_ID('dbo.tb_lote_captura_item', 'U') IS NULL
CREATE TABLE tb_lote_captura_item (
  idlote INT NOT NULL,
  orden INT NOT NULL,
  archivo VARCHAR(500) NULL,
  codigo_barras VARCHAR(100) NULL,
  estado VARCHAR(20) NULL,
  Codigodoc VARCHAR(20) NULL,
  error VARCHAR(500) NULL,
  CONSTRAINT PK_tb_lote_captura_item PRIMARY KEY (idlote, orden),
  CONSTRAINT FK_tb_lote_captura_item_lote FOREIGN KEY (idlote) REFERENCES tb_lote_captura(idlote) ON DELETE CASCADE
);
GO

IF OBJECT_ID('dbo.tb_regla_carpeta', 'U') IS NULL
CREATE TABLE tb_regla_carpeta (
  idregla INT IDENTITY(1,1) NOT NULL,
  ruta VARCHAR(500) NULL,
  IdEstructura VARCHAR(50) NULL,
  id INT NULL,
  codsubs VARCHAR(50) NULL,
  user_id VARCHAR(100) NULL,
  activa BIT NOT NULL DEFAULT 1,
  CONSTRAINT PK_tb_regla_carpeta PRIMARY KEY (idregla)
);
GO

-- Vinculacion opcional a Active Directory.
IF COL_LENGTH('dbo.cl_Resp_Gest_Arch', 'usuario_ad') IS NULL
ALTER TABLE cl_Resp_Gest_Arch ADD usuario_ad VARCHAR(256) NULL;
GO
