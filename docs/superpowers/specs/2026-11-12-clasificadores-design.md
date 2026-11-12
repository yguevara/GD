# Rediseño de los clasificadores (fase 1: Servidores FTP/S3, Archivos, Series y subseries)

Fecha: 2026-11-12. Estado: pendiente de aprobación del usuario.

## Intención

Los clasificadores de ArchiGenio se ven y se usan como una hoja de cálculo: una rejilla `cxGrid` con aspecto de Excel, una barra superior de iconos sueltos y el navegador de base de datos (`|◄ ◄ ► ► + − ✓ ✗`). El usuario quiere que se sientan como el resto de la aplicación nueva (shell con paleta "arena y terracota", `UTema`), conservando DevExpress, que valora. Es el primer paso de un rediseño completo del sistema, que se hará poco a poco.

Esta fase cubre las tres pantallas de la paleta de clasificadores: **Servidores FTP/S3**, **Archivos** y **Series y subseries**. Los demás clasificadores (los ocultos) quedan para después.

## Qué se decidió (maquetas aprobadas en el navegador)

1. **Patrón común:** cabecera con título, subtítulo y buscador; tabla a todo el ancho **sin aspecto de Excel** (sin líneas de cuadrícula, filas aireadas, etiquetas de color, punto de estado, ordenar y filtrar por columna); al elegir una fila o pulsar "+ Nuevo" se abre a la derecha un **panel lateral** con la ficha para editar y los botones "Guardar", "Cancelar", "Eliminar". Desaparecen el navegador de base de datos y la barra de iconos. Las acciones son botones con texto ("+ Nuevo", "Exportar", "Probar conexión").
2. **Servidores FTP/S3:** en el panel se elige FTP o S3 / MinIO. Para MinIO se piden solo dirección (endpoint), puerto, HTTPS, bucket, región, clave de acceso y clave secreta, cada uno con ayuda corta, y un botón "Probar conexión" con resultado visible. Esto reemplaza el botón "S3" escondido de la pantalla actual y resuelve cómo registrar un servidor MinIO.
3. **Archivos:** la misma tabla con panel lateral. Campos actuales: código, nombre, tipo de archivo, responsable, croquis, foto, descripción.
4. **Series y subseries:** las series como índice a la izquierda, las subseries en la tabla central y los datos de la subserie en el panel (secciones Identificación, Contenido, Conservación). **El uso principal del usuario es editar las variables del formulario** (casi nunca consulta), así que la subserie tiene una **pantalla propia de variables**: lista ordenable arrastrando (5 a 10 variables normalmente), propiedades de la variable elegida a la derecha y, debajo, una **vista previa** de cómo verá el formulario quien capture documentos (el usuario confirmó que la vista previa le sirve). Esta pantalla sustituye a las pestañas "Variables (Formulario)", "Vista tabla" y "Vista Formulario".

## Metas, no metas y antimetas

- **Metas:** aspecto y uso consistentes con el shell nuevo; editar variables más rápido y sin errores de orden; poder registrar un servidor MinIO sin conocimientos previos.
- **No metas:** cambiar tablas o datos guardados; los clasificadores ocultos; los informes de impresión (FastReport); cambiar el modelo de permisos.
- **Antimetas (sería un fallo aunque funcione):** perder funciones de las pantallas viejas sin avisar; dejar al usuario sin poder volver a la pantalla vieja si la nueva falla; que "Guardar" pierda cambios o los guarde a medias.

## Restricciones

- Delphi 10.3 VCL, DevExpress (`cxGrid` se mantiene, con estilo propio), FireDAC; todo SQL válido en SQL Server y Access.
- Pantallas nuevas **por código** (sin `.dfm`), como `UAsignacionNodos`, con colores de `TemaLegacyActual`/`UTema` (claro y oscuro). Fuente Segoe UI.
- La lógica de datos y las reglas van en **unidades sin VCL ni `TUDM`** con pruebas DUnitX en `Pruebas/`; las pantallas solo presentan.
- Textos nuevos con tildes; las unidades sin pantalla en ASCII. Mensajes siempre por `UMensajes` (`TMensajes`). Cada unidad nueva se agrega al `.dpr`.
- Comentarios y documentación en español.
- Permisos: sin cambios; las entradas actuales (`A1Click`, `L1Click`, `S1Click` en `UMAINFORM`) siguen siendo el único punto de acceso y conservan el registro en el log (tipos 14 y 15).

## Convivencia con las pantallas viejas (decisión del usuario)

Las pantallas nuevas son las predeterminadas. Un archivo **`clasificadores_clasico.flag`** junto al ejecutable hace que se abran las pantallas viejas, igual que ya funciona `shell_clasico.flag`. Las pantallas viejas no se borran en esta fase. Si la pantalla nueva falla al abrirse, se abre la vieja y el motivo queda en un archivo de errores (como `lista_error.log`), sin molestar al usuario.

## Orden de construcción (cada punto es entregable y probable por separado)

1. **Piezas comunes:** formulario base de clasificador (cabecera, zona de tabla, panel lateral con barra de acciones y estados "navegando / editando / nuevo"), estilo de la `cxGrid`, y la regla del interruptor `.flag`.
2. **Servidores FTP/S3:** reutiliza `UAlmacenServidor` (`GuardarServidorS3`, cifrado del secreto en `USecretoServidor`) y `UEsquemaAlmacen`; añade lectura/alta/edición/baja de servidores FTP y la prueba de conexión (FTP ya existe como `btnTestConn`; para S3 usar `UAlmacenS3`).
3. **Archivos:** datos en `cl_ArchivosGestion` (con croquis y foto como imágenes: elegir, ver, quitar).
4. **Series y subseries:** series (`cl_series`), subseries (`cl_subseries`) y el editor de variables (`cl_VarSubserie`: `Orden`, `NomVariable`, `Etiqueta`, `tipo` según `CL_SubseriesTipoVar` = Caracteres, Fecha, Entero, Memo, Real, Boolean; `longitud`, `descripcion`, `obligatorio`, lista desplegable).

## Para el constructor (decisiones abiertas, a su criterio salvo que se indique)

- Reordenar variables arrastrando debe reescribir `Orden` de forma consistente (sin huecos ni duplicados) y de una vez; definir qué pasa con las variables ya usadas por documentos existentes al cambiar su tipo o longitud (propuesta: avisar y no permitir cambiar el tipo si ya hay documentos con ese dato).
- Dónde se guarda exactamente la "lista desplegable" de una variable (el dataset actual expone el campo `ListaDesplegable`): confirmar en el esquema y mantener el formato actual para no romper el formulario de captura. Mi propuesta de "una opción por línea" es solo de interfaz.
- El campo "ayuda para quien captura" de la maqueta es una **suposición**: puede mapearse a `descripcion` o quitarse si no hay campo adecuado.
- Si la pantalla se muestra modal a pantalla casi completa (como hoy) o embebida en el contenedor principal: por defecto, modal como las actuales.
- Qué hacer con "Imprimir"/"Ayuda" de las pantallas viejas: mantenerlos accesibles en la cabecera.

## Decisiones que tomé yo al revisar el documento como constructor (el usuario puede cambiarlas)

- Eliminar un servidor, archivo, serie o subserie que ya está en uso se **bloquea con un mensaje claro** (cuántos elementos lo usan); no se borra en cascada.
- Cambiar el tipo o la longitud de una variable que ya tiene documentos con datos: se **avisa y se impide cambiar el tipo**; la longitud solo puede ampliarse.
- Croquis y foto de un archivo: se aceptan imágenes habituales (JPG, PNG, BMP) y se redimensionan al guardar para no inflar la base de datos.
- "Guardar" valida antes de escribir y es todo o nada; "Cancelar" descarta sin preguntar si no hubo cambios y pregunta si los hubo.
- Las pruebas de datos usan la base `SGDTEST_ALCANCE` (variable `ARCHIGENIO_TEST_DB`) y no dejan filas.
