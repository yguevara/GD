-- F5 trazabilidad: columnas aditivas de tb_log (copia documental de UEsquemaTrazabilidad.pas)
-- La aplicacion lo ejecuta con SET LOCK_TIMEOUT 5000 y prueba el indice primero WITH (ONLINE = ON).
-- Si tb_log esta ocupada, ejecutarlo a mano en una ventana de mantenimiento.
IF COL_LENGTH('dbo.tb_log', 'codigodoc') IS NULL ALTER TABLE tb_log ADD codigodoc VARCHAR(20) NULL;
IF COL_LENGTH('dbo.tb_log', 'iddoc') IS NULL ALTER TABLE tb_log ADD iddoc INT NULL;
IF COL_LENGTH('dbo.tb_log', 'codsubsdoc') IS NULL ALTER TABLE tb_log ADD codsubsdoc VARCHAR(50) NULL;
IF COL_LENGTH('dbo.tb_log', 'versiondoc') IS NULL ALTER TABLE tb_log ADD versiondoc VARCHAR(12) NULL;
IF COL_LENGTH('dbo.tb_log', 'fecha_evento') IS NULL ALTER TABLE tb_log ADD fecha_evento DATETIME NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tb_log_codigodoc')
  CREATE INDEX IX_tb_log_codigodoc ON tb_log (codigodoc, IdEstructura);
