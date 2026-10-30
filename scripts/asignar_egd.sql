-- Asigna el Especialista de Gestion Documental (EGD) de un nodo.
-- Solo SQL Server. Hasta que exista la pantalla de asignacion, este script es
-- la via para dar a un usuario la topografia y la eliminacion de su nodo.
--
-- Uso: edite las tres variables de abajo y ejecute en la base del cliente.
--   @usuario       nombre de login (cl_Resp_Gest_Arch.usuario), en minusculas
--   @idestructura  tb_tree.IdEstructura del nodo (ej.: 'A.4.3')
--   @id            tb_tree.id del nodo           (ej.: 104)
-- Un nodo tiene un solo EGD (clave primaria de tb_nodo_egd): si ya hay uno,
-- se reemplaza. Por seguridad corre en simulacro: muestra el resultado y deshace
-- los cambios. Ponga @confirmar = 1 para aplicarlos.
DECLARE @usuario varchar(100) = 'egd_a43';
DECLARE @idestructura varchar(50) = 'A.4.3';
DECLARE @id int = 104;
DECLARE @confirmar bit = 0;

BEGIN TRAN;

IF NOT EXISTS (SELECT 1 FROM tb_tree WHERE IdEstructura = @idestructura AND id = @id)
BEGIN
  RAISERROR('El nodo indicado no existe en tb_tree.', 16, 1);
  ROLLBACK TRAN;
  RETURN;
END

IF NOT EXISTS (SELECT 1 FROM tb_user WHERE nombreuser = @usuario)
  INSERT INTO tb_user (nombreuser) VALUES (@usuario);

IF EXISTS (SELECT 1 FROM tb_nodo_egd WHERE IdEstructura = @idestructura AND id = @id)
  UPDATE tb_nodo_egd SET user_id = @usuario
  WHERE IdEstructura = @idestructura AND id = @id;
ELSE
  INSERT INTO tb_nodo_egd (IdEstructura, id, user_id)
  VALUES (@idestructura, @id, @usuario);

SELECT IdEstructura, id, user_id FROM tb_nodo_egd
WHERE IdEstructura = @idestructura AND id = @id;

IF @confirmar = 1
  COMMIT TRAN;
ELSE
  ROLLBACK TRAN;
