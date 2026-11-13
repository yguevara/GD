-- Diagnostico de inicio de sesion de un usuario (solo lectura; SQL Server).
-- Edite @usuario y @clave (los que escribe en la pantalla de acceso) y ejecute.
DECLARE @usuario varchar(100) = 'egd';
DECLARE @clave varchar(100) = 'admin';

SET @usuario = LOWER(LTRIM(RTRIM(@usuario)));
DECLARE @md5 varchar(32) = LOWER(CONVERT(varchar(32), HASHBYTES('MD5', LTRIM(RTRIM(@clave))), 2));

-- 1) La fila de login. Debe haber UNA: habilitado = 'S', rol con nombre y la clave igual.
SELECT r.Idresp, r.usuario, r.habilitado, r.Rol AS idrol, t.rol AS nombre_rol,
       r.password AS clave_guardada, @md5 AS clave_esperada,
       CASE WHEN LTRIM(RTRIM(r.password)) = @md5 THEN 'SI' ELSE 'NO' END AS clave_coincide
FROM cl_Resp_Gest_Arch r LEFT JOIN tb_rol t ON t.idrol = r.Rol
WHERE LOWER(r.usuario) = @usuario;

-- 2) Si el paso 1 no devuelve filas, el usuario no existe (el script no se aplico:
--    ejecute crear_usuario_egd.sql con @confirmar = 1). Roles disponibles:
SELECT idrol, rol FROM tb_rol ORDER BY idrol;

-- 3) Nodos donde ese usuario es EGD (necesario para crear prestamos y transferencias)
SELECT IdEstructura, id, user_id FROM tb_nodo_egd WHERE LOWER(user_id) = @usuario;
