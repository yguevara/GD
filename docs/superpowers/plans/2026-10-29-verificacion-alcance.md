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
| 9 | `egd_a43` (asignado con `scripts/asignar_egd.sql`) | En `A.4.3`, elegir un documento | Ve los botones de topografía (datos topográficos y gestionar contenido) y puede editar la topografía de sus subseries |  |
| 10 | `egd_a43` | Eliminar un documento de `A.4.3` con más de 5 días | El botón Eliminar está disponible y borra (el EGD no tiene ventana de días) |  |
| 11 | Un Director (fila en `tb_tree_directors` con `idrol = 3`) de un nodo con hijos | Eliminar un documento de un nodo hijo | Solo puede eliminarlo el primer día; pasado ese plazo no aparece Eliminar. No ve los botones de topografía |  |
| 12 | `usr_sub` | Agregar un documento en `A.4.3` / `014001` con la topografía incompleta (dejar vacío el depósito en `tb_Serietree`) | Mensaje: "Falta la ubicación de esta subserie en tu área. Avisa al especialista de gestión documental de tu nodo." |  |
| 13 | `egd_a43` | El mismo caso 12 | Mensaje pidiendo especificar los datos topográficos, y puede completarlos desde el botón de topografía |  |
| 14 | `administrador` y modo Access | Agregar, editar y eliminar | Sin cambios respecto a la versión anterior |  |
| 15 | `administrador` | Administración de usuarios → «Asignación de responsables por nodo…» | Se abre la pantalla con los 86 nodos; `egd_a43` aparece como EGD en A.4.3 y el contador dice «N nodos, N sin EGD propio» |  |
| 16 | `administrador` | Marcar A.4, rol EGD, «Incluir todos los nodos hijos», usuario `egd_a43`, «Asignar a los marcados» | A.4 y todos sus hijos muestran `EGD: egd_a43`; el contador baja |  |
| 17 | `administrador` | Asignar un segundo EGD (otro usuario) al mismo nodo | El nodo muestra los dos EGD; los dos pueden iniciar sesión y actuar en él |  |
| 18 | `administrador` | Quitar a un usuario con «Incluir hijos» desde A.4 | Los hijos pierden solo a ese usuario; los demás EGD/Directores de los hijos se conservan. Pide confirmación al afectar más de un nodo |  |
| 19 | `administrador` | Marcar «Mostrar solo los nodos sin EGD propio» | Lista plana de los nodos sin EGD propio (en rojo); un nodo que solo hereda EGD de su padre sigue apareciendo |  |
| 20 | `egd_a43` con EGD en A.4 | Ver documentos de A.4.3 y editarlos | Los ve (lectura en descendientes) pero no puede editar, eliminar ni tocar la topografía en A.4.3 |  |
| 21 | cualquier usuario no administrador | Abrir Administración de usuarios | No tiene acceso a la pantalla de asignación (el botón de usuarios solo es del administrador). En modo Access el botón no aparece |  |
| 22 | `administrador` | Asignar un Director con un usuario que no está en `cl_Resp_Gest_Arch` / provocar un error a mitad | Mensaje de error y ningún cambio guardado |  |

## Qué mirar además

- Que la rejilla de documentos (detalle del nodo seleccionado) no pierda el vínculo maestro-detalle con `tb_Serietree` tras el filtro.
- Que Depuración, Préstamos y Transferencias sigan abriendo (no se filtran en este proyecto, pero comparten `tb_SeriesDatos`).
