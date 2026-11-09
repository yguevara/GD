# Verificación manual de la F3: Agregar documentos con metadatos dinámicos

Plan: `2026-11-05-carga-documentos-f3.md`. Pendiente de ejecutar por una persona con la aplicación real. Tienen prueba automática (SQL Server y Access): el modelo de la carga (títulos, códigos consecutivos, «aplicar a todos», obligatorios, `ExpandirRutas`, `ResumenLote`), los metadatos dinámicos (campos, validación por tipo, alta en la tabla `md_*`, `ControlParaCampo`), el guardado de un documento (transacción, código único, bitácora, compensación del almacén) y el lote reintentable con últimos valores. **No** tienen prueba automática la pantalla `UPantallaCarga` ni el cableado del shell, ni el MinIO real salvo que `ARCHIGENIO_TEST_S3` esté definida.

## Qué cambia y qué no

- «Agregar documento» del shell abre la pantalla nueva (lista de candidatos, datos comunes, datos propios de la subserie). La rejilla sigue existiendo para editar y borrar: botón «Ver rejilla» de la lista de documentos.
- Los ficheros nuevos van al servidor S3 (F4); sin servidor S3 registrado la carga no se abre y se ofrece el clasificador de servidores. Esta fase no escribe en FTP.
- Con `shell_clasico.flag` el alta es la de siempre (rejilla); la pantalla nueva no existe.
- Fuera de la F3: georreferencia (F6), OCR y búsqueda por contenido (F7), carpetas vigiladas, lector de códigos de barras.

## Cosas a comprobar primero (posibles huecos)

- **Retomar un lote pendiente** (caso 24): al abrir la pantalla en la misma subserie se ofrece retomar, descartar o decidir más tarde. De un lote retomado solo se conservan archivo, código y estado: el **título y los datos propios hay que completarlos de nuevo** (si la subserie tiene obligatorios, quedan en «Falta un dato»). Quitar filas de un lote ya guardado lo descarta y empieza otro.
- **«Reintentar los que fallaron»** sigue el mismo lote (no crea otro).
- **Verificación visual:** nadie ha visto aún la pantalla abierta (ni la tarjeta dinámica ni el modo Guiado).

## Preparación

1. MinIO de pruebas registrado como servidor S3 (como en la lista de la F4) y copia de la aplicación sobre `SGDTEST_ALCANCE` (**no** `SGDDRHMAIN`), o sobre una **copia** de `BD\SDbd.mdb`.
2. Dos subseries de prueba: una con tabla de metadatos y 4 variables de tipos distintos (texto corto, memo, fecha, entero o real, sí/no; al menos una obligatoria) y otra sin tabla de metadatos.
3. Un administrador, un usuario sin permiso de agregar y un EGD; una carpeta con 5 archivos y una subcarpeta; archivos de prueba con nombres con espacios, `ñ`, `#`, `+`, un duplicado de nombre y uno de 0 bytes.

## Casos

| # | Usuario / entorno | Qué hacer | Resultado esperado | Registrado |
|---|---|---|---|---|
| 1 | Administrador | Elegir un nodo y la subserie con metadatos; pulsar «Agregar documento» | Se abre «Agregar documentos - serie / subserie» (no la rejilla) | |
| 2 | Administrador | Soltar 3 archivos sobre la zona | 3 filas «Listo» con título sacado del nombre y códigos consecutivos | |
| 3 | Administrador | Soltar una carpeta con subcarpeta (con «Incluir subcarpetas» marcada y sin marcar) | Con la casilla entra todo; sin ella, solo los de la carpeta; sin ocultos ni `~$*` | |
| 4 | Administrador | «Elegir archivos...» y «Agregar carpeta...» | Agrega sin duplicar los que ya estaban | |
| 5 | Administrador | Editar título, código y fecha de un candidato | La lista y el estado se actualizan al instante | |
| 6 | Administrador | Dejar vacío el título o el código | Estado «Falta un dato» y la columna Detalle dice qué falta | |
| 7 | Administrador | Subserie con metadatos: mirar la tarjeta «Datos de la subserie» | Un control por variable (texto corto = caja, memo = caja grande, fecha con casilla, número, sí/no); obligatorios con `*` | |
| 8 | Administrador | Dejar un obligatorio vacío | «Falta un dato»; mensaje rojo bajo el campo | |
| 9 | Administrador | Texto inválido en número y en fecha; texto más largo que la longitud | Mensaje bajo el campo; no pasa a «Listo» | |
| 10 | Administrador | Subserie **sin** tabla de metadatos | No aparece la tarjeta; se puede guardar igual | |
| 11 | Administrador | Subserie con tabla pero sin variables | No aparece la tarjeta | |
| 12 | Administrador | «Aplicar a todos» con varios archivos | Copia la fecha; pregunta si copia también los datos de la subserie; nunca cambia archivo ni código | |
| 13 | Administrador | Guardar una carga y abrir otra de la misma subserie; «Repetir los últimos valores» | Rellena la tarjeta con los valores de la carga anterior | |
| 14 | Administrador | Marcar «Modo guiado»; recorrer Archivos > Datos > Revisar | Un paso a la vez; en Revisar la lista muestra estado y detalle; Anterior/Siguiente habilitados según corresponda | |
| 15 | Administrador | Cerrar y reabrir la pantalla | Recuerda el modo elegido (por usuario) | |
| 16 | Administrador | Soltar un archivo sobre la **fila** de un candidato; y usar «Agregar fuente...» | Queda como fuente de ese documento (el estado muestra «n fuente(s)»), no como candidato nuevo | |
| 17 | Administrador | «Guardar todos» con 3 archivos | Progreso; resumen «Se guardaron 3 documentos.»; la lista de documentos muestra los 3 | |
| 18 | Administrador | Abrir un documento guardado y su anexo | El fichero está en el bucket (consola de MinIO) con `urlraiz = s3://<n>/`; abre desde S3; la fuente está en `\Fuentes\` con `fuente='S'` | |
| 19 | Administrador | Nombres con espacios, `ñ`, `#`, `+`, repetidos y de 0 bytes | Cada uno es un fichero distinto; ninguno se pisa; todos abren | |
| 20 | Administrador | Cancelar a mitad de un lote | Los ya guardados quedan; el resumen dice cuántos quedaron sin procesar | |
| 21 | Administrador | Apagar MinIO a mitad de un lote | Los fallidos salen con motivo y «¿Reintentar los que fallaron?»; sin objetos huérfanos ni filas a medias | |
| 22 | Administrador | Encender MinIO y reintentar | Se guardan los fallidos; ninguno duplicado | |
| 23 | Dos usuarios | Cargar a la vez en la misma subserie | Ningún `Codigodoc` duplicado (el segundo recibe uno distinto) | |
| 24 | Administrador | Cancelar un lote a mitad, cerrar la pantalla (confirmar) y volver a abrirla en la misma subserie | Ofrece retomar: Sí = vuelve la lista (los guardados como «Guardado»), se completan título y datos propios y «Guardar todos» termina el mismo lote; No = lo descarta y no vuelve a ofrecerlo; Cancelar = lo ofrece la próxima vez | |
| 25 | Usuario sin permiso de agregar | Pulsar «Agregar documento» | «No tiene permiso para agregar documentos en esta subserie.»; no se abre nada | |
| 26 | Usuario / EGD | Subserie con topografía incompleta | EGD y administrador: mensaje de que falta; el resto: que avise al EGD; no se abre nada | |
| 27 | Administrador | Sin ningún servidor S3 registrado | «Registre primero un servidor S3...» y oferta de abrir el clasificador de servidores | |
| 28 | Administrador | Sin nodo o sin subserie elegidos | «Elija en el arbol el nodo y la subserie...» | |
| 29 | Administrador | Soltar 300 archivos de golpe | La pantalla no se congela; la lista sigue fluida (un solo control) | |
| 30 | Administrador | Cerrar con archivos sin guardar | Pregunta antes de cerrar | |
| 31 | Administrador | «Ver rejilla» en la lista de documentos | Abre la rejilla para editar y borrar | |
| 32 | Administrador | Modo Access (copia de `SDbd.mdb`) | Mismos resultados que en SQL Server | |
| 33 | Administrador | Pantalla de 1366x768 al 125 % | Sin solapes ni controles cortados; la tarjeta propia se desplaza | |
| 34 | Administrador | Tema oscuro de Windows | Legible; sin textos invisibles | |
| 35 | Administrador | Con `shell_clasico.flag` junto al ejecutable | El alta es la de siempre (rejilla); no aparece la pantalla nueva | |

## Resultado

Ejecutada por: ______  Fecha: ______  Versión: ______

Los casos que fallen se anotan como tareas de seguimiento de la F3.
