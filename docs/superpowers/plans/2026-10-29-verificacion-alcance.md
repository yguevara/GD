# Verificación manual del alcance por usuario (Tarea 6)

Pendiente de ejecutar por una persona: requiere iniciar sesión en la aplicación real.

## Preparación

1. Base de pruebas: `SGDTEST_ALCANCE` (copia de `SGDDRHMAIN` con el esquema nuevo). Apuntar `config.ini` de una copia del ejecutable a esa base. **No usar `SGDDRHMAIN`.**
2. Crear tres usuarios con contraseña en `cl_Resp_Gest_Arch` (y su fila en `tb_user`):
   - `administrador` (ya existe).
   - `egd_a43`: fila en `tb_nodo_egd` con `('A.4.3', 104, 'egd_a43')`.
   - `usr_sub`: fila en `tb_usuario_subserie` con `('A.4.3', 104, '014001', 'usr_sub')`.
3. Para que `014001` no sea pública: `UPDATE cl_subseries SET acceso = 2 WHERE codsubs = '014001'` (solo en la base de pruebas).

## Casos

| # | Usuario | Qué hacer | Resultado esperado | Registrado |
|---|---|---|---|---|
| 1 | (sin sesión, Invitado) | Abrir la aplicación | Árbol vacío o solo lo cubierto por subseries públicas; ningún documento restringido |  |
| 2 | `administrador` | Iniciar sesión | Árbol completo; todos los documentos |  |
| 3 | `egd_a43` | Iniciar sesión | En el árbol solo la ruta hasta `A.4.3` y `A.4.3`; documentos de `A.4.3` más los públicos; no los de nodos hijos |  |
| 4 | `usr_sub` | Iniciar sesión | Árbol con la ruta a `A.4.3`; en `A.4.3` solo documentos de la subserie `014001` más los públicos |  |
| 5 | `usr_sub` | Cerrar sesión | Vuelve el caso 1 (el árbol se recarga) |  |
| 6 | `administrador` tras `usr_sub` | Iniciar sesión | Árbol completo otra vez (no queda el filtro del usuario anterior) |  |
| 7 | Cualquiera | Agregar y editar un nodo o documento dentro de su cobertura | Guarda sin error y el registro se sigue viendo |  |
| 8 | Modo Access (`config.ini` con `.mdb`) | Abrir e iniciar sesión | Árbol y documentos completos, sin cambios respecto a la versión anterior |  |

## Qué mirar además

- Que la rejilla de documentos (detalle del nodo seleccionado) no pierda el vínculo maestro-detalle con `tb_Serietree` tras el filtro.
- Que Depuración, Préstamos y Transferencias sigan abriendo (no se filtran en este proyecto, pero comparten `tb_SeriesDatos`).
