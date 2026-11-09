# Verificación manual de la F5: trazabilidad del documento (línea de tiempo e «Historia»)

Plan: `2026-11-09-trazabilidad-f5.md`. Pendiente de ejecutar por una persona con la aplicación real. Tienen prueba automática (SQL Server y Access): el esquema aditivo de `tb_log`, la clasificación y el orden de eventos, la clave del documento en las escrituras del log, el registro de consultas y descargas y la línea de tiempo con alcance. **No** tienen prueba automática la sección «HISTORIA» del panel, el diálogo `UHistoriaDocumento` ni el cableado de consultas/descargas desde la interfaz. Nadie ha visto aún el panel ni el diálogo abiertos.

## Cosas a comprobar primero (posibles huecos)

- **Códigos de `tb_accionlog`:** el código usa 2 Eliminar, 3 Modificar, 5 Insertar y 14 Visualizar (confirmados por el código existente); 4 Descargar y 6 Visualizar se dedujeron del orden y **no están confirmados**. Ejecutar `SELECT * FROM tb_accionlog` y comparar con `UTrazabilidad.pas`. Si difieren, los eventos saldrían como otro tipo.
- **Eventos anteriores a la F5** no tienen clave de documento: no aparecen en la historia (es lo esperado).
- **Columna `IdEstructura` de `tb_log`:** desde la F5, los eventos de documento (alta, modificación, baja, consulta) guardan ahí el **código** de la estructura (p. ej. `A.4.3`), porque es parte de la clave de la historia. Antes guardaban el nombre (`Nombreestructura`). En «Administración del log» (`UAdminLog`) las filas viejas y las nuevas muestran valores distintos en esa columna; es esperado. El usuario del equipo, el nombre del PC y la IP se siguen guardando como antes (excepto en las altas por «Agregar documentos», que no tiene acceso a `DatosPC`: la IP queda vacía).
- **Circulación entre departamentos** no entra (es la F9).

## Preparación

1. Copia de la aplicación sobre `SGDTEST_ALCANCE` (**no** `SGDDRHMAIN`) o sobre una **copia** de `BD\SDbd.mdb`.
2. Un administrador y un usuario con alcance restringido a otro nodo; un documento anterior a la F5; un documento con más de 200 eventos (insertar filas de prueba en `tb_log` con su clave).

## Casos

| # | Usuario / entorno | Qué hacer | Resultado esperado | Registrado |
|---|---|---|---|---|
| 1 | Administrador | Crear un documento y seleccionarlo en la lista | Sección «HISTORIA» con «Creado» | |
| 2 | Administrador | Modificar el documento | Aparece «Modificado» arriba | |
| 3 | Administrador | Abrir el documento (doble clic, «Abrir» del menú de ficheros y desde el árbol clásico), y abrir un fichero fuente y un anexo digital | Cada apertura agrega «Consultado» (una sola vez por apertura) | |
| 4 | Administrador | «Obtener expediente completo» (copia los ficheros a un archivo) | Aparece «Descargado» (ver código 4 arriba). Abrir un fichero lo baja a una carpeta temporal y cuenta como «Consultado», no como «Descargado» | |
| 5 | Administrador | Prestar y luego devolver | Aparecen «Prestado» y «Devuelto» con el prestamista | |
| 6 | Administrador | Eliminar el documento | Ya no está en la lista; sus eventos siguen en `tb_log` | |
| 7 | Administrador | Seleccionar un documento anterior a la F5 | «Sin eventos registrados» en el panel; el diálogo explica que la historia empieza al instalar la F5 | |
| 8 | Usuario con alcance restringido | Seleccionar un documento fuera de su alcance (o abrir su historia) | Historia vacía, sin filas ajenas ni error | |
| 9 | Administrador | Documento con más de 200 eventos: «Ver historia completa» | 200 eventos y el aviso de que hay más anteriores | |
| 10 | Administrador | Dos documentos con el mismo `Codigodoc` en nodos distintos | La historia de uno no incluye eventos del otro | |
| 11 | Access | Repetir los casos 1 a 5 | Mismo resultado | |
| 12 | Administrador | Cambiar a tema oscuro, abrir «Ver historia completa» | El diálogo usa los colores del tema | |
| 13 | Con `shell_clasico.flag` | Arrancar la aplicación | Sin panel; nada cambia | |
| 14 | `tb_log` sin permiso para alterar | Arrancar y seleccionar un documento | La aplicación arranca; el panel dice «Historia no disponible» (no «Sin eventos registrados») y el motivo queda en `lista_error.log` | |
| 15 | SQL Server, `tb_log` ocupada | Desde otra sesión, `BEGIN TRAN; SELECT * FROM tb_log WITH (TABLOCKX)` sin cerrar; arrancar la aplicación por primera vez tras instalar la F5 | Arranca en unos 5 s por columna pendiente (no se cuelga); la historia no estará disponible hasta que se libere la tabla y se reinicie. El script `scripts/trazabilidad_esquema.sql` sirve para aplicarlo a mano | |
| 16 | Administrador | Redimensionar el panel o mover el divisor con un documento seleccionado | La historia no vuelve a consultarse (sin parpadeo ni demora) | |
| 17 | Administrador | Documento con miles de eventos de consulta | El panel abre sin demora apreciable y muestra los 200 más recientes | |

## Registro

Fecha, usuario y observaciones: ______________________
