# Documentos: carga, consulta, mapas, búsqueda por contenido y trazabilidad (diseño)

Fecha: 2026-11-05. Dueño del producto: Yohan Guevara (EMSERGO S.R.L.). Continúa `2026-10-29-rediseno-archigenio-design.md` (fases 3, 4 y 5) y no lo sustituye: lo detalla y añade lo pedido el 2026-11-05. Las maquetas aprobadas están en `.superpowers/brainstorm/838-1793891670/content/` (`variantes-carga.html`, `carga-y-consulta.html`).

## 1. Intención

Hoy un documento se agrega en una rejilla (`cxGrid`), uno a uno, y sus ficheros se suben por FTP. A varios usuarios la rejilla les resulta incómoda. Se quiere que cargar, encontrar y entender un documento sea fácil para una persona sin formación técnica, y que ArchiGenio aproveche lo que ya sabe de cada documento: dónde está, de qué trata, dónde está en el mapa y por qué manos ha pasado.

Criterio rector (dueño del producto): **la facilidad de uso manda**. Ante dos soluciones, la que exige menos pasos y menos conocimiento previo.

## 2. Qué existe hoy (verificado en el código y en `SCRIPTS/`)

| Pieza | Estado |
|---|---|
| Búsqueda por nombre, por metadato (`cl_VarSubserie` sobre `md_*`) y por datos fijos de la subserie, dentro del alcance del usuario, con ámbito «todo el archivo / nodo actual» | **Hecha** (`UBusqueda*`, `UBusquedaDocumentos`). La lista manual de verificación sigue sin ejecutarse |
| Seguridad por alcance, EGD, validación de topografía | **Hecha** (`UAlcance*`, `UTopografia`) |
| Documento: `tb_SeriesDatos` (claves `IdEstructura, id, codsubs, Fecha, Version, Codigodoc`; `deposito, gaveta, Archivo, Idservidor, posicion, IDExpediente`) | Existe |
| Ficheros del documento: `tb_ssArchdigital` (`path`, `urlraiz`, `fuente` = fichero fuente, `ext`, `tamano`) | Existe |
| Coordenadas por documento: `tb_DocCoord (idVertice, x, y)`, cargada en la pantalla principal | Existe; sin sistema de coordenadas definido y sin mapa |
| Registro de acciones: `tb_log`, `tb_accionlog` (Visualizar, Insertar, Modificar, Descargar…) | Existe, pero por subserie, no por documento |
| Préstamos, transferencias, depuración, índices | Existen (pantallas heredadas) |
| Esquema de lotes de captura (`tb_lote_captura`, `_item`, `tb_regla_carpeta`) | Existe sin pantallas |
| Visores de contenido (`UVeditor`, `UVisorTif`, `UREditor`) | Existen |
| Almacenamiento de ficheros | FTP (Indy), servidores definidos en el clasificador «Servidores (FTP)» |
| Shell, iconos Tabler, pantalla de inicio | **Hecho** (Fase 1) |

## 3. Qué se construye

### 3.1 Agregar documentos (A con el asistente de B)

Pantalla «Agregar documentos» abierta desde el nodo y la subserie elegidos (según la maqueta aprobada):

- Se sueltan varios archivos (o una carpeta) a la vez. Cada archivo es un documento candidato con su estado: en espera, subiendo, listo, falta un dato.
- Modo **Rápido** (todo en una pantalla) y modo **Guiado** (1 Archivos → 2 Datos, primero lo común y luego lo de cada documento → 3 Revisar). Es la misma pantalla por partes, no dos implementaciones.
- Datos fijos: título, código, fecha, acceso, ¿es expediente?. «Aplicar a todos» copia lo común. Precompletado: repetir los últimos valores o una plantilla por subserie.
- **Datos propios de la subserie, generados en tiempo de ejecución.** Si la subserie tiene tabla de metadatos (`NombreTablaMetadatos` en `cl_subseries`), la pantalla construye sus campos desde `cl_VarSubserie` y `CL_SubseriesTipoVar`: etiqueta, tipo (texto, texto largo, fecha, número, sí/no, lista si existe), obligatorio, orden. Nada de esos campos va escrito en el código. Un archivo no pasa a «listo» con un obligatorio vacío. Sin tabla de metadatos, la tarjeta no aparece.
- Ficheros fuente: se arrastran sobre la fila del documento y se guardan con `fuente` marcado.
- Al guardar: una transacción por documento (`tb_SeriesDatos`, `md_*`, `tb_ssArchdigital`, `tb_DocCoord` si aplica, registro en `tb_log`). Un fallo en un documento no pierde los demás; lo ya subido se puede reintentar. El lote se registra en `tb_lote_captura` para poder retomarlo.
- Valida topografía (`UTopografia`) y permiso de agregar en esa subserie (`UAlcance`) con los mensajes que ya existen.

### 3.2 Documentos de la subserie y propiedades

La lista de documentos sustituye a la rejilla como vista principal de la subserie (maqueta pantalla 2):

- **Doble clic**: abre el contenido en el visor adecuado al tipo de fichero.
- **Un clic**: panel de propiedades a la derecha con: datos generales (código, título, fecha, versión, acceso), **posición física** (depósito, gaveta, archivo, servidor, posición), ¿expediente o documento?, datos propios de la subserie, ficheros digitales y ficheros fuente (con «Abrir»), y la trazabilidad resumida (3.6).
- **Iconos que se distinguen a simple vista**: documento (archivo), **expediente (carpeta, icono distinto)**, documento georreferenciado/mapa (marcador de mapa; combinable con el de expediente mediante una insignia). Un documento es expediente si otros documentos lo referencian en `IDExpediente`, o si así se marca al crearlo (ver sección 6).
- Las columnas visibles son las fijas más las que el administrador marque.

### 3.3 Almacenamiento en MinIO

**La versión 2.0 parte de MinIO** (decisión del dueño, 2026-11-05): los ficheros nuevos van siempre a MinIO (compatible con S3). Los clientes que tienen la versión 1.0 reciben una **utilidad de migración de FTP a MinIO** (parte de la F4). Detalles:

- Se introduce una interfaz de almacenamiento (`IAlmacenFicheros`: subir, descargar, abrir con URL temporal, borrar, existe) con la implementación S3/MinIO y una de solo lectura para FTP, que existe únicamente para que la utilidad de migración y los ficheros todavía no migrados sigan abriéndose. El resto del código no sabe cuál usa.
- El clasificador «Servidores» gana un tipo de servidor (FTP o S3) y los datos de MinIO (endpoint, bucket, clave de acceso, secreto, HTTPS). El secreto se guarda cifrado, nunca en claro en `config.ini`.
- Clave del objeto: `IdEstructura/id/codsubs/Codigodoc/Version/<idhijo>-<nombre>`; `tb_ssArchdigital.path` y `urlraiz` siguen identificando el fichero (un `urlraiz` de tipo S3 lo distingue).
- Subida con barra de progreso por archivo, en segundo plano, con reintento. Sin cargar el fichero entero en memoria.
- **Utilidad de migración FTP → MinIO**: recorre `tb_ssArchdigital`, copia cada fichero al bucket, actualiza `urlraiz` y `path` de su registro solo cuando la copia se verificó (tamaño y suma de control), es reanudable, informa de lo que falló y no borra nada del FTP hasta que se confirme. Hasta que termine, cada fichero se abre según su propio `urlraiz`.
- Funciona igual con base SQL Server y con Access.

### 3.4 Documentos georreferenciados y mapas

ArchiGenio gestiona planos y mapas; esa condición debe ser visible y utilizable.

- **Clasificación.** Un documento es *georreferenciado* si tiene coordenadas (`tb_DocCoord`, al menos un vértice). Es *mapa* si su fichero principal es de uno de estos formatos, confirmados por el dueño: **GeoTIFF/TIF, SHP, KML, GeoJSON, DWG y DXF** (y GeoPackage, `.gpkg`, que mencionó al responder). Un TIF solo cuenta como mapa si el documento tiene coordenadas, porque un TIF puede ser un escaneo normal. Se muestra con su icono e insignia (3.2).
- **Sistema de coordenadas (decidido).** Las coordenadas se **almacenan siempre en WGS84** (EPSG:4326). Si la persona las introduce en coordenadas planas o locales, indica su sistema de origen (código EPSG o parámetros) y la conversión a WGS84 es automática; el valor original y su sistema se conservan en `tb_doc_geo` para poder reproducirlo. Se añade esa tabla aditiva `tb_doc_geo (claves del documento, srid_origen, tipo_geometria, minx, miny, maxx, maxy)`; `tb_DocCoord` guarda los vértices ya en WGS84 y la caja envolvente permite buscar por zona. Sin tipos espaciales del motor mientras la base siga siendo SQL Server/Access. Los ficheros DXF/SHP/GeoPackage se leen con una biblioteca externa (GDAL/OGR) invocada por el programa; la tecnología concreta se confirma con una prueba corta.
- **¿Migrar a PostgreSQL/PostGIS?** Valorado el 2026-11-05: **no en la versión 2.0**. Motivo: el acceso a datos (`UCapaDatos`, unas 5 500 líneas, más cada consulta que debe valer en Access y en SQL Server) y las migraciones de esquema están construidos sobre dos motores; añadir un tercero y quitar Access afecta a todos los clientes, a la instalación y a la migración de datos, y compite con las fases F2-F9. PostGIS aporta reproyección y búsqueda espacial nativas, pero esas dos cosas se resuelven en 2.0 con una biblioteca de conversión y la caja envolvente. Para no cerrar la puerta, la parte geográfica se escribe detrás de una interfaz (`IRepositorioGeo`) con la implementación actual (tablas + caja envolvente); si más adelante se decide PostgreSQL, solo cambia esa implementación. La decisión se revisa cuando haya clientes con volumen de planos que exija consultas espaciales complejas.
- **Alta.** En «Agregar documentos», si la subserie está marcada como georreferenciable, aparece el paso «Ubicación en el mapa»: escribir vértices, importarlos de KML/GeoJSON, o dibujar sobre el mapa.
- **Vista de mapa.** Pantalla que muestra la huella de los documentos del nodo o de la búsqueda sobre un mapa; clic en una huella abre sus propiedades; doble clic abre el contenido.
- **Búsqueda espacial.** «Documentos que tocan esta zona o este punto», usando la caja envolvente. Se integra en la búsqueda como un filtro más.
- La tecnología del mapa (componente propio de Delphi, TMS, o Leaflet en un navegador embebido) y el mapa base (en línea u offline) se deciden con una prueba corta al empezar (sección 6).

### 3.5 Búsqueda

Se mantiene la búsqueda actual (nombre, metadatos, propiedades de la subserie, alcance, ámbito). Se añade:

- **Por contenido del documento.** El texto se extrae al subir el fichero (cuando aún está en el equipo del usuario) y se indexa en una tabla aditiva `tb_doc_texto (claves, idhijo, texto)`. Formatos con texto propio: PDF con capa de texto, Word/Excel (DOCX/XLSX), ODT, RTF, TXT. En SQL Server se usa búsqueda de texto completo si está instalada y `LIKE` si no; en Access, `LIKE`. Los documentos ya cargados se indexan con un proceso por lotes en segundo plano.
- Los resultados por contenido pasan por el mismo filtro de alcance (`UAlcanceDatos`): un documento fuera del alcance solo aparece como lo que ya se muestra hoy para lo restringido (nunca su texto).
- Resultado con fragmento resaltado y doble clic para abrir. La búsqueda por contenido es una casilla más («incluir el texto de los documentos»), no una pantalla nueva.
- **Escaneos (TIF/PDF de imagen): ver sección 6, pregunta 1.**

### 3.6 Seguimiento del documento (trazabilidad)

Objetivo: ver la vida de un documento desde que se genera y por qué departamentos del Cuadro de Clasificación ha pasado, y usarlo para gestionar mejor el trabajo.

- **Eventos del documento** en una línea de tiempo (en el panel de propiedades y en una pestaña «Historia»): creado (quién, nodo origen), nueva versión, modificado, consultado/descargado, prestado y devuelto, transferido, enviado a otro departamento, recibido, depurado. La mayor parte sale de lo que ya se registra (`tb_log`, préstamos, transferencias); hace falta añadir `Codigodoc` a `tb_log` de forma aditiva (ya previsto en el diseño del 2026-10-29, sección 14) y consultar por documento.
- **Circulación entre departamentos.** Tabla aditiva `tb_documento_movimiento (idmov, claves del documento, fecha, user_id, nodo_origen (IdEstructura,id), nodo_destino, tipo, estado, observacion, fecha_recepcion)`. El documento **no cambia de nodo de archivo** (las claves de `tb_SeriesDatos` incluyen el nodo); lo que se mueve y se registra es la *custodia*: dónde está ahora y quién lo tiene. La pantalla «Enviar a…» elige el nodo destino y el destino recibe una notificación.
- **Reglas de la circulación (decididas).** Quien tiene la custodia **solo ve que el documento existe**; **solo lo abre quien tenga permiso** por su alcance (la custodia no da acceso, así que no hay regla nueva en `UAlcanceDatos`). **Ni el administrador ni el EGD pueden revertir un envío.** Solo lo puede revertir **quien lo envió o el director del área desde donde se envió**; los directores de niveles superiores no pueden cancelarlo.
- **Para la gestión.** Tablero por departamento: documentos en custodia, tiempo medio de permanencia, los que llevan más tiempo sin moverse, recorridos más largos. Exportable a Excel/PDF. Respeta el alcance: cada responsable ve su área; el administrador y el EGD ven lo de su alcance.
- Reutiliza las notificaciones internas y el tablero del EGD de la Fase 5 del diseño original.

## 4. Objetivos, no objetivos y antiobjetivos

**Objetivos**
- Una persona nueva agrega varios documentos de una subserie, con sus metadatos, sin ayuda (medida de éxito de la Fase 1, ya definida).
- Cargar y abrir ficheros con MinIO sin que el usuario note el cambio.
- Ver de un vistazo qué es expediente, qué es mapa y dónde está cada documento (física y geográficamente).
- Encontrar un documento por lo que dice por dentro.
- Saber dónde está un documento y por dónde ha pasado.

**No objetivos (en este diseño)**
- Edición en línea de documentos de Office ni versionado automático de contenido.
- SIG completo (edición de capas, análisis espacial avanzado): solo ubicar, ver y buscar por zona.
- Firma electrónica (se evalúa en la Fase 5 original).
- Carga automática desde carpeta vigilada o código de barras (solo existe el esquema; el diseño no lo activa).

**Antiobjetivos (fallaría aunque «funcione»)**
- Que cargar un documento exija más pasos o más conocimiento que hoy.
- Que algún usuario vea, por la búsqueda por contenido o por el mapa, información fuera de su alcance.
- Que un ejecutable antiguo o los datos existentes dejen de funcionar: todos los cambios de base son aditivos.
- Que un fallo de red a mitad de una carga deje documentos a medias sin que el usuario lo sepa.

## 5. Restricciones

- Todo el SQL debe funcionar en SQL Server y en Access; sin tipos espaciales ni texto completo como único camino.
- Reglas de negocio en unidades sin VCL ni `TUDM` (probables con DUnitX): formulario dinámico desde metadatos, validación de lote, clasificación geo/expediente, extracción de texto, eventos de trazabilidad. Código nuevo en ASCII.
- Seguridad por alcance en un solo punto (`UAlcanceDatos`); lo nuevo lo reutiliza.
- Delphi 10.3, VCL; DevExpress, TMS, JVCL ya instalados. Cambios de interfaz sin editar a ciegas los `.dfm` binarios.
- Credenciales de MinIO cifradas; HTTPS recomendado; permisos mínimos del usuario de servicio sobre un solo bucket.
- Cada fase se verifica con una lista manual con la aplicación real, como en las fases anteriores.

## 6. Decisiones

### Decididas por el dueño del producto (2026-11-05, respuestas a las preguntas del diseño)
- **OCR y TIFF escaneados**: se retoman en una fase posterior; la búsqueda por contenido de la F7 cubre solo documentos con texto.
- Coordenadas siempre en WGS84, con conversión automática desde coordenadas planas o locales (3.4). Formatos de mapa: GeoTIFF/TIF, SHP, KML, GeoJSON, DWG y DXF.
- La versión 2.0 parte de MinIO; los clientes de la 1.0 reciben una utilidad de migración (3.3).
- Georreferenciable = marca de la subserie (`georef`). Expediente engloba subexpedientes y documentos, y debe poder verse cada documento u obtenerse el expediente completo (la vista en la F2; obtener el expediente completo, tras la F4, porque necesita los ficheros).
- Reglas de la circulación y de la custodia (3.6).
- Variante de carga: A con el asistente de B integrado.
- Pantalla de documentos con doble clic = contenido y un clic = propiedades (posición, fecha, expediente, ficheros fuente).
- Campos de metadatos generados en tiempo de ejecución según lo definido por el usuario.
- Icono distinto para expediente.
- Tener en cuenta documentos georreferenciados y mapas.
- Buscar por nombre, metadato, propiedades de la subserie y contenido.
- Seguimiento del documento por los departamentos del Cuadro de Clasificación.
- MinIO en lugar de FTP.

### Mías, a revisar
- Interfaz `IAlmacenFicheros` con S3/MinIO como almacén de la versión 2.0 y FTP solo de lectura para migrar.
- Sin tipos espaciales por ahora: caja envolvente en `tb_doc_geo` y vértices en `tb_DocCoord`; geografía detrás de `IRepositorioGeo` por si se migra a PostGIS (3.4).
- Custodia separada del nodo de archivo (el documento no cambia de claves).
- Texto extraído al subir, índice en `tb_doc_texto`, `LIKE` como camino común.
- Reutilizar `tb_lote_captura` para registrar y retomar cada carga.
- Un documento es expediente si otros lo referencian en `IDExpediente` o se marca al crearlo.
- **Resolución del almacén por registro**: cada fichero se abre según el `urlraiz` de su propio registro, de modo que ficheros migrados y no migrados conviven durante la transición.
- **«Georreferenciable» es una marca de la subserie**: columna aditiva `georef` (sí/no, por defecto no) en `cl_subseries`, editada en el clasificador de series y subseries. Con la marca, la carga ofrece el paso «Ubicación en el mapa». Un documento de otra subserie también puede recibir coordenadas después, desde sus propiedades.
- **Expediente.** Se respeta lo que ya hay: un documento es expediente si otros lo referencian en `IDExpediente` o si se marca al crearlo (columna aditiva en `tb_SeriesDatos`), un expediente vacío cuenta como expediente, y el nivel de anidación es el que ya permite `subexp`. La carga en lote puede asignar un mismo expediente a todos los archivos de golpe.

### Pendientes del dueño del producto (se resuelven antes de la fase que los necesita)
1. **Confirmación de recepción** (antes de la F9): cuando se envía un documento a otro departamento, ¿el destino debe confirmar que lo recibió (estados pendiente/recibido/rechazado y notificaciones) o basta registrar dónde está?
2. **Mapa base sin internet** (antes de la F8): ¿el mapa de fondo debe funcionar sin conexión (teselas propias) o se acepta un mapa en línea?

### Se deja al constructor
Tecnología del mapa y de la extracción de texto (con una prueba corta previa), forma exacta de la pantalla de dibujo de la huella, nombres de pantallas y de tablas dentro de lo descrito, orden interno de las tareas dentro de cada fase, y la biblioteca para hablar con S3 (firma AWS v4 con Indy, o el componente de Delphi si admite un endpoint propio).

## 7. Plan de desarrollo por fases

Estado: **Hecho** / **Parcial** / **Nuevo**. Tamaño: S pocos días, M una o dos semanas, L varias semanas. Cada fase termina con pruebas DUnitX de la lógica pura y una lista manual.

| Fase | Entrega | Depende de | Estado | Tamaño |
|---|---|---|---|---|
| F0 | Base visual: shell, iconos, splash, «Acerca de», pantalla de inicio | — | **Hecho** (falta la lista manual y la prueba con usuarios) | — |
| F1 | Búsqueda por nombre, metadato, propiedades y alcance | alcance | **Hecho** (falta la lista manual) | — |
| F2 | **Lista de documentos y panel de propiedades** (3.2): iconos documento/expediente/geo, doble clic y un clic, posición, ficheros y fuente, filtro por expediente. Sin tocar la carga todavía | F0 | **Implementada** (plan `2026-11-05-lista-documentos-f2.md`; falta ejecutar la lista manual `2026-11-05-verificacion-f2.md` con un administrador) | M |
| F4 | **MinIO** (3.3): almacén S3, tipo de servidor en el clasificador, subida con progreso, **utilidad de migración FTP → MinIO** para clientes de la 1.0, y «obtener el expediente completo» | F2 | **Implementada** (plan `2026-11-05-minio-f4.md`; falta ejecutar la lista manual `2026-11-05-verificacion-f4.md`) | L |
| F3 | **Agregar documentos A+B con metadatos dinámicos** (3.1) sobre el almacén MinIO; registro del lote | F2, F4 | **Implementada** (plan `2026-11-05-carga-documentos-f3.md`; falta ejecutar la lista manual `2026-11-05-verificacion-f3.md`) | L |
| F5 | **Trazabilidad, parte 1** (3.6): `Codigodoc` en `tb_log`, línea de tiempo por documento en el panel y «Historia» | F2 | Parcial (hay `tb_log`) | M |
| F6 | **Georreferenciación, parte 1** (3.4): `tb_doc_geo`, WGS84 con conversión automática, clasificación geo/mapa, entrada de vértices (escribir e importar KML/GeoJSON), insignia | F2, F3 | Parcial (hay `tb_DocCoord`) | M |
| F7 | **Búsqueda por contenido** (3.5) de documentos con texto: extracción al subir, `tb_doc_texto`, índice de los existentes, casilla en la búsqueda. OCR y TIFF escaneados, fase posterior | F3 | Nuevo | L |
| F8 | **Georreferenciación, parte 2**: vista de mapa y búsqueda espacial; lectura de DXF/SHP/GeoPackage | F6, decisión pendiente 2 | Nuevo | L |
| F9 | **Trazabilidad, parte 2**: circulación entre departamentos (`tb_documento_movimiento`), reglas de reversión, notificaciones, tablero y reportes para la gestión | F5, decisión pendiente 1, notificaciones de la Fase 5 original | Nuevo | L |

Orden recomendado: F2 → F4 → F3 → F5 → F6 → F7 → F8 → F9. La F4 va antes que la F3 porque la versión 2.0 parte de MinIO y la carga no debe escribirse dos veces; por eso su prueba corta (S3 con Indy o el componente de Delphi) se hace al empezar. F2 y F5 son de bajo riesgo y dan valor enseguida. Antes de la F6/F8 y la F7 hay otra prueba corta (conversión de coordenadas y lectura de formatos con GDAL/OGR; extracción de PDF).

Cada fase tendrá su plan con tareas (`docs/superpowers/plans/`) cuando le toque, empezando por F2.
