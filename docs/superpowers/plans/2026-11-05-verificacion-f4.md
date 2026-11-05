# Verificación manual de la F4: almacén S3/MinIO, migración y expediente completo

Plan: `2026-11-05-minio-f4.md`. Pendiente de ejecutar por una persona con la aplicación real. Tienen prueba automática la firma SigV4, el cliente S3 (contra un MinIO real), el cifrado del secreto, el esquema, la elección de almacén, el alta de servidores S3, la migración (con almacenes en memoria) y el expediente completo (lista con alcance y exportación a carpeta/ZIP), con SQL Server y Access. **No** tienen prueba automática las pantallas ni el FTP real.

## Qué cambia y qué no

- Un servidor de ficheros puede ser **FTP** (de siempre) o **S3/MinIO**. Los ficheros **nuevos** (anexos y fuentes de un documento) van al primer servidor S3 registrado; si no hay ninguno, siguen yendo al FTP.
- Cada fichero se abre según su propio `urlraiz`: `s3://<n>/` es S3; cualquier otro valor es FTP. Se pueden mezclar.
- **La carátula y el fichero principal del documento siguen por FTP** hasta la F3.
- La migración copia y verifica; **no borra nada del FTP**. Borrar un documento sí borra sus ficheros (en S3 o en FTP, según cada uno).
- Con `shell_clasico.flag` la lista de documentos no existe; el botón «Obtener expediente completo» solo está en la lista.

## Preparación

1. Un MinIO accesible desde el equipo (para pruebas: el de la sesión, `127.0.0.1:9100`, usuario `archigenio`, secreto `archigenio-test-1`) con un usuario de servicio con permisos solo sobre un bucket. Recomendado HTTPS en producción.
2. Copia de la aplicación apuntando a `SGDTEST_ALCANCE` (**no** `SGDDRHMAIN`) o a una **copia** de `BD\SDbd.mdb`. Al conectar se agregan solas las columnas de `cl_ftp_Server` y `ipserver` pasa a 100 caracteres.
3. Un administrador, un usuario con alcance restringido y datos de la verificación F2 (nodo A.4.3, expedientes `P-001`...).

## Casos

| # | Usuario / entorno | Qué hacer | Resultado esperado | Registrado |
|---|---|---|---|---|
| 1 | Administrador | Clasificadores > Servidores > «Servidor S3 (MinIO)...» | Diálogo con nombre, servidor, puerto, bucket, región, HTTPS, clave de acceso y secreto (oculto) | |
| 2 | Administrador | Rellenar con el MinIO de pruebas y pulsar «Probar conexión» | «Conexion correcta.» en verde; el botón vuelve a estar activo; la ventana no se congela | |
| 3 | Administrador | Probar con un secreto equivocado | Mensaje rojo «acceso denegado...»; el secreto no aparece en ningún mensaje | |
| 4 | Administrador | Probar con el servidor apagado | Mensaje claro «No se pudo conectar con el servidor S3», sin excepción sin tratar | |
| 5 | Administrador | Guardar; reabrir el diálogo del mismo servidor | Los datos vuelven; el secreto queda vacío («dejar vacío para conservar»); guardar así no cambia el secreto | |
| 6 | Administrador | Revisar la base: `SELECT secreto_cifrado FROM cl_ftp_Server` | Valor que empieza por `v1:`, nunca el secreto en claro | |
| 7 | Gestor | En un documento, agregar un anexo digital | Aparece la ventana de progreso; el fichero queda en el bucket (ver la consola de MinIO); la fila tiene `urlraiz = s3://<n>/` | |
| 8 | Gestor | Abrir ese anexo (menú Abrir / doble clic en la lista) | Se descarga con progreso y se abre en su programa | |
| 9 | Gestor | Cancelar a mitad una subida de un fichero grande | No queda registro a medias ni objeto en el bucket | |
| 10 | Gestor | Agregar una fuente | Igual que el caso 7 para fuentes | |
| 11 | Gestor | Abrir un anexo antiguo (urlraiz de FTP) | Sigue abriéndose por FTP como antes | |
| 12 | Gestor | Borrar un anexo S3 y uno FTP | Desaparecen de la lista y del almacén correspondiente | |
| 13 | Gestor | Documento con nombre de fichero con espacios, `ñ`, `#` y `+` | Sube, abre y descarga idéntico | |
| 14 | Administrador | Configuración > «Migrar ficheros a MinIO...» (con FTP y S3 registrados) | Pantalla con servidor FTP de origen y S3 de destino | |
| 15 | Administrador | Iniciar la migración sobre una base de prueba con ficheros en FTP | Barra de progreso; al terminar, «Migrados: n. Ya estaban en S3: 0. Fallidos: 0» y los `urlraiz` pasan a `s3://<n>/` | |
| 16 | Administrador | Repetir la migración | «Migrados: 0. Ya estaban en S3: n» | |
| 17 | Administrador | Cancelar a mitad y volver a iniciar | Reanuda sin duplicar ni perder ficheros | |
| 18 | Administrador | Apagar MinIO a mitad de la migración | Los ficheros pendientes salen como fallidos; «Ver fallos» abre `migracion_fallos.log`; las filas fallidas conservan su `urlraiz` de FTP | |
| 19 | Administrador | Tras migrar, abrir un fichero migrado | Se abre desde S3; el original sigue en el FTP (no se borró) | |
| 20 | Usuario sin permiso de configuración | Menú Configuración | No aparece la sección ni la migración | |
| 21 | Administrador | En la lista de documentos, elegir un expediente | El panel muestra «Obtener expediente completo» (solo para expedientes) | |
| 22 | Administrador | Pulsarlo y guardar el ZIP | ZIP con una carpeta por documento (`P-001/`, `P-0xx/`...) con todos sus ficheros, incluidas las fuentes | |
| 23 | Usuario con alcance restringido | Mismo expediente | El ZIP no incluye ficheros de documentos fuera de su alcance | |
| 24 | Administrador | Expediente sin ficheros digitales | Aviso «no tiene ficheros digitales»; no se crea ZIP | |
| 25 | Administrador | Expediente con un fichero que falta en el almacén | El resto se copia; el aviso final lista el que falló | |
| 26 | Cualquiera | Documento no expediente | El botón no aparece | |
| 27 | Modo Access (copia del `.mdb`) | Repetir 1, 2, 5, 7, 8, 15, 22 | Igual que en SQL Server | |
| 28 | 1366x768 al 125 % | Panel de documentos con un expediente seleccionado | Los dos botones y el enlace caben sin solapes | |
| 29 | Tema oscuro de Windows | Diálogo S3, migración y progreso | Legibles (usan la paleta clara fija: confirmar que no desentonan) | |

## Notas conocidas

- La subida, la descarga y la migración corren en el hilo principal procesando mensajes: la ventana responde y se puede cancelar, pero un solo fichero muy grande retrasa el efecto de Cancelar hasta terminar ese fichero.
- La clave en S3 de un fichero nuevo es la ruta histórica (`\IdEstructura\serie\subserie\documento\Anexos Digitales\`) más el nombre, no la clave del diseño (`IdEstructura/id/codsubs/Codigodoc/Version/idhijo-nombre`). La unidad `UAlmacenFicheros` ya trae `ClaveObjeto` para cambiarla en la F3.
- El secreto va cifrado con AES-256 y una clave embebida en la aplicación: protege contra leerlo en la base, no contra quien tenga el ejecutable y la base.
- `TAlmacenFtp.Descargar/Existe` no tiene prueba automática (no hay servidor FTP de pruebas): casos 11, 15 y 19.

## Resultado

Anotar fecha, persona, versión del ejecutable y, por cada caso, «OK» o la descripción del fallo con captura. Ante un fallo grave, quitar el servidor S3 del clasificador devuelve los ficheros NUEVOS al FTP (los ya subidos a S3 dejarían de abrirse hasta volver a registrar ese servidor con el mismo número).
