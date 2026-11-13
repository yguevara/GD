-- Crea un usuario con rol Gestor y lo asigna como Especialista de Gestion
-- Documental (EGD) de un nodo: puede crear prestamos y transferencias en ese nodo.
-- Solo SQL Server. Es idempotente (se puede ejecutar varias veces) y por seguridad
-- corre en SIMULACRO: muestra el resultado y deshace los cambios. Ponga
-- @confirmar = 1 para aplicarlos.
--
-- Uso: edite las variables de abajo y ejecute en la base de ArchiGenio.
--   @usuario       login (se guarda en minusculas)
--   @clave         contrasena (se guarda como MD5 en minusculas, igual que la
--                  pantalla de usuarios)
--   @idestructura / @id   nodo donde sera EGD (tb_tree). Si los deja en NULL se
--                  usa el primer nodo del arbol; la lista de nodos aparece al final
--                  del simulacro. Elija un nodo que tenga documentos y subseries.
-- Despues entre en ArchiGenio con ese usuario y contrasena.
DECLARE @usuario varchar(100) = 'egd';
DECLARE @clave varchar(100) = 'Egd#2026';
DECLARE @nombre varchar(30) = 'Especialista GD';
DECLARE @idestructura varchar(50) = NULL;
DECLARE @id int = NULL;
DECLARE @confirmar bit = 0;

SET @usuario = LOWER(LTRIM(RTRIM(@usuario)));

BEGIN TRAN;

IF @idestructura IS NULL OR @id IS NULL
  SELECT TOP 1 @idestructura = IdEstructura, @id = id FROM tb_tree ORDER BY IdEstructura, id;

IF NOT EXISTS (SELECT 1 FROM tb_tree WHERE IdEstructura = @idestructura AND id = @id)
BEGIN
  RAISERROR('El nodo indicado no existe en tb_tree.', 16, 1);
  ROLLBACK TRAN;
  RETURN;
END

DECLARE @idrol smallint = (SELECT TOP 1 idrol FROM tb_rol WHERE LOWER(LTRIM(RTRIM(rol))) = 'gestor');
IF @idrol IS NULL
BEGIN
  RAISERROR('No existe el rol Gestor en tb_rol.', 16, 1);
  ROLLBACK TRAN;
  RETURN;
END

-- login (cl_Resp_Gest_Arch): rol Gestor, habilitado, clave en MD5 minusculas
IF NOT EXISTS (SELECT 1 FROM cl_Resp_Gest_Arch WHERE LOWER(usuario) = @usuario)
  INSERT INTO cl_Resp_Gest_Arch (Idresp, NombreResponsable, usuario, Rol, password, habilitado)
  VALUES ((SELECT ISNULL(MAX(Idresp), 0) + 1 FROM cl_Resp_Gest_Arch), @nombre, @usuario,
          @idrol, LOWER(CONVERT(varchar(32), HASHBYTES('MD5', LTRIM(RTRIM(@clave))), 2)), 'S');
ELSE
  UPDATE cl_Resp_Gest_Arch SET Rol = @idrol, habilitado = 'S',
    password = LOWER(CONVERT(varchar(32), HASHBYTES('MD5', LTRIM(RTRIM(@clave))), 2))
  WHERE LOWER(usuario) = @usuario;

-- fila de tb_user (la exige la clave foranea de tb_nodo_egd)
IF NOT EXISTS (SELECT 1 FROM tb_user WHERE nombreuser = @usuario)
  INSERT INTO tb_user (nombreuser) VALUES (@usuario);

-- EGD del nodo (un nodo puede tener varios; no reemplaza a nadie)
IF NOT EXISTS (SELECT 1 FROM tb_nodo_egd WHERE IdEstructura = @idestructura
               AND id = @id AND user_id = @usuario)
  INSERT INTO tb_nodo_egd (IdEstructura, id, user_id) VALUES (@idestructura, @id, @usuario);

SELECT 'Usuario' AS Dato, @usuario AS Valor
UNION ALL SELECT 'Contrasena', @clave
UNION ALL SELECT 'Rol (idrol)', CONVERT(varchar(10), @idrol)
UNION ALL SELECT 'EGD del nodo', @idestructura + ' / ' + CONVERT(varchar(10), @id);

-- Nodos disponibles, para elegir otro si hace falta
SELECT IdEstructura, id, etiqueta FROM tb_tree ORDER BY IdEstructura, id;

IF @confirmar = 1
  COMMIT TRAN;
ELSE
BEGIN
  ROLLBACK TRAN;
  PRINT 'SIMULACRO: no se guardo nada. Ponga @confirmar = 1 para aplicar.';
END
