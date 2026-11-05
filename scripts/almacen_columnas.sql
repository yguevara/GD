-- Copia documental de UEsquemaAlmacen.CrearEsquemaAlmacen (SQL Server).
-- La aplicacion lo ejecuta sola al conectar; es idempotente.
IF COL_LENGTH('dbo.cl_ftp_Server', 'tipo') IS NULL ALTER TABLE cl_ftp_Server ADD tipo VARCHAR(3) NULL;
IF COL_LENGTH('dbo.cl_ftp_Server', 'bucket') IS NULL ALTER TABLE cl_ftp_Server ADD bucket VARCHAR(100) NULL;
IF COL_LENGTH('dbo.cl_ftp_Server', 'region') IS NULL ALTER TABLE cl_ftp_Server ADD region VARCHAR(50) NULL;
IF COL_LENGTH('dbo.cl_ftp_Server', 'usohttps') IS NULL ALTER TABLE cl_ftp_Server ADD usohttps BIT NULL;
IF COL_LENGTH('dbo.cl_ftp_Server', 'clave_acceso') IS NULL ALTER TABLE cl_ftp_Server ADD clave_acceso VARCHAR(100) NULL;
IF COL_LENGTH('dbo.cl_ftp_Server', 'secreto_cifrado') IS NULL ALTER TABLE cl_ftp_Server ADD secreto_cifrado VARCHAR(500) NULL;
UPDATE cl_ftp_Server SET tipo = 'FTP' WHERE tipo IS NULL;
