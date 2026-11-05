-- Copia documental de UEsquemaCarga.CrearEsquemaCarga (SQL Server).
-- La aplicacion lo ejecuta sola al conectar; es idempotente.
IF COL_LENGTH('dbo.cl_VarSubserie', 'obligatorio') IS NULL ALTER TABLE cl_VarSubserie ADD obligatorio BIT NULL;
IF OBJECT_ID('dbo.tb_carga_valores', 'U') IS NULL
  CREATE TABLE tb_carga_valores (
    user_id VARCHAR(100) NOT NULL,
    codsubs VARCHAR(50) NOT NULL,
    campo VARCHAR(100) NOT NULL,
    valor VARCHAR(255) NULL,
    CONSTRAINT PK_tb_carga_valores PRIMARY KEY (user_id, codsubs, campo));
