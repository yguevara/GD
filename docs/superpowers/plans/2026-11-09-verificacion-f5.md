# Verificación manual de la F5: trazabilidad del documento (línea de tiempo e «Historia»)

Plan: `2026-11-09-trazabilidad-f5.md`. Pendiente de ejecutar por una persona con la aplicación real. Tienen prueba automática (SQL Server y Access): el esquema aditivo de `tb_log`, la clasificación y el orden de eventos, la clave del documento en las escrituras del log, el registro de consultas y descargas y la línea de tiempo con alcance. **No** tienen prueba automática la sección «HISTORIA» del panel, el diálogo `UHistoriaDocumento` ni el cableado de consultas/descargas desde la interfaz. Nadie ha visto aún el panel ni el diálogo abiertos.

## Cosas a comprobar primero (posibles huecos)

- **Códigos de `tb_accionlog`:** el código usa 2 Eliminar, 3 Modificar, 5 Insertar y 14 Visualizar (confirmados por el código existente); 4 Descargar y 6 Visualizar se dedujeron del orden y **no están confirmados**. Ejecutar `SELECT * FROM tb_accionlog` y comparar con `UTrazabilidad.pas`. Si difieren, los eventos saldrían como otro tipo.
- **Eventos anteriores a la F5** no tienen clave de documento: no aparecen en la historia (es lo esperado).
- **Circulación entre departamentos** no entra (es la F9).

## Preparación

1. Copia de la aplicación sobre `SGDTEST_ALCANCE` (**no** `SGDDRHMAIN`) o sobre una **copia** de `BD\SDbd.mdb`.
2. Un administrador y un usuario con alcance restringido a otro nodo; un documento anterior a la F5; un documento con más de 200 eventos (insertar filas de prueba en `tb_log` con su clave).

## Casos

| # | Usuario / entorno | Qué hacer | Resultado esperado | Registrado |
|---|---|---|---|---|
| 1 | Administrador | Crear un documento y seleccionarlo en la lista | Sección «HISTORIA» con «Creado» | |
| 2 | Administrador | Modificar el documento | Aparece «Modificado» arriba | |
| 3 | Administrador | Abrir un fichero del documento | Aparece «Consultado» | |
| 4 | Administrador | Descargar un fichero | Aparece «Descargado» (ver código 4 arriba) | |
| 5 | Administrador | Prestar y luego devolver | Aparecen «Prestado» y «Devuelto» con el prestamista | |
| 6 | Administrador | Eliminar el documento | Ya no está en la lista; sus eventos siguen en `tb_log` | |
| 7 | Administrador | Seleccionar un documento anterior a la F5 | «Sin eventos registrados» en el panel; el diálogo explica que la historia empieza al instalar la F5 | |
| 8 | Usuario con alcance restringido | Seleccionar un documento fuera de su alcance (o abrir su historia) | Historia vacía, sin filas ajenas ni error | |
| 9 | Administrador | Documento con más de 200 eventos: «Ver historia completa» | 200 eventos y el aviso de que hay más anteriores | |
| 10 | Administrador | Dos documentos con el mismo `Codigodoc` en nodos distintos | La historia de uno no incluye eventos del otro | |
| 11 | Access | Repetir los casos 1 a 5 | Mismo resultado | |
| 12 | Administrador | Cambiar a tema oscuro, abrir «Ver historia completa» | El diálogo usa los colores del tema | |
| 13 | Con `shell_clasico.flag` | Arrancar la aplicación | Sin panel; nada cambia | |
| 14 | `tb_log` sin permiso para alterar | Arrancar | La aplicación arranca; la historia queda vacía; error en `lista_error.log` | |

## Registro

Fecha, usuario y observaciones: ______________________
