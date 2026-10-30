# Rediseño de ArchiGenio: interfaz simple, seguridad por alcance y búsqueda integrada

Fecha: 2026-10-29. Estado: borrador para aprobación.

## 1. Intención

ArchiGenio es un sistema de gestión documental de escritorio (Delphi 10.3, VCL, DevExpress 19.1, TMS, FastReport, JVCL) que compran empresas en su versión PROFESIONAL. Hoy la interfaz está muy cargada y por eso la capacitación del personal es difícil y costosa.

**Objetivo único que manda sobre todos los demás:** que un usuario nuevo pueda trabajar con muy poca capacitación. Cada decisión de diseño se mide contra eso.

**Criterio de fracaso (dicho por el dueño del producto):** que el rediseño funcione técnicamente pero los usuarios sigan necesitando mucha capacitación.

El rediseño incluye interfaz moderna y minimalista, iconos sugerentes, nuevo splash y about, ayuda actualizada, seguridad por alcance, búsqueda integrada, refactorización y documentación del código que se toque.

## 2. Cómo trabajan los usuarios hoy (confirmado)

Las dos tareas que se hacen el 80% del tiempo son **agregar documentos** y **buscar documentos**. Todo lo demás (clasificadores, transferencias, préstamos, depuración, usuarios, logs) es secundario.

## 3. Modelo de datos existente (verificado en la base `SGDDRHMAIN`, SQL Server)

- **Estructura arbórea** (`tb_tree`, tipos en `cl_tipoestructura`): organigrama de la empresa (Dirección, direcciones funcionales, departamentos…). Hay más de un árbol (por ejemplo Empresa y Procesos).
- **Cuadro de clasificación:** series (`cl_series`) y subseries (`cl_subseries`). Cada subserie tiene retención, vigencia, destino, nivel de acceso (`cl_acceso`: Pública, Restringida, Secreta) y `NombreTablaMetadatos`.
- **Cruce nodo–subserie** (`tb_Serietree`): qué subseries maneja cada nodo y dónde se guarda físicamente (archivo, depósito, gaveta).
- **Documentos** (`tb_SeriesDatos`): pertenecen a un nodo y a una subserie. Archivos digitales en `tb_ssArchdigital`.
- **Metadatos variables:** cada subserie apunta a su propia tabla `md_*` (por ejemplo `md_014014001`). Sus campos los define el usuario en `cl_VarSubserie` (nombre, etiqueta, tipo, longitud; tipos en `CL_SubseriesTipoVar`: caracteres, fecha, entero, memo, real, booleano). Cada tabla `md_*` repite las columnas de enlace (`IdEstructura`, `id`, `codsubs`, `Fecha`, `Version`, `Codigodoc`).
- **Claves del árbol (verificado):** la clave primaria de `tb_tree` es compuesta (`IdEstructura`, `id`). `id` **no es único** (el valor 160 aparece en 3 nodos hoja: A.1.7, A.3.3, A.4.6), por eso `tb_Serietree` y las consultas que filtran solo por `id` son ambiguas. `IdEstructura` sí es único pero tiene irregularidades (`a.1.4` en minúscula, `A.1.6 ` con espacio final, `A.6..3.3` con doble punto). El padre se guarda como `padre` = `id` del nodo padre.
- **Directores ya modelados:** existe `tb_tree_directors (IdEstructura, id, user_id)`, vacía hoy, creada en `UpDateDB`. Se reutiliza para el rol Director.
- **Seguridad actual:** roles (`tb_rol`: Administrador, Gestor, Director, Visor) que solo controlan menús y controles (`USecurityClasss.pas`). No hay filtrado de datos por usuario. Hay un solo usuario en `tb_user`. Especialistas dispersos en `cl_especialista` y `cl_Resp_Gest_Arch`.

## 4. Modos de uso

- **SQL Server, multiusuario:** con seguridad por alcance (sección 5). Es el modo de las empresas.
- **Access, un solo usuario:** sin módulo de seguridad. Lo usa una persona para sus propios documentos sensibles (asesoría jurídica, gestión de cuadros…). Debe seguir funcionando.
- La seguridad se diseña solo para SQL Server. La interfaz y la búsqueda deben funcionar en ambos motores. En modo Access no aparecen las pantallas de permisos.

## 5. Seguridad por alcance (decidido)

- Cada nodo del árbol tiene un **especialista de gestión documental**.
- **Director de un área:** ve todos los documentos de su nodo y de todos los nodos hijos.
- **Especialista:** gestiona solo los documentos de su departamento (su nodo) y **asigna los permisos de su área**.
- **Usuario común:** ve solo las **subseries completas asignadas dentro de su nodo**, más los documentos públicos del sistema. La asignación es sobre el par nodo–subserie (el mismo par de `tb_Serietree`).
- Los documentos de subseries con acceso "Pública" los ve cualquier usuario autenticado.
- El filtro se aplica en la consulta de datos (árbol y búsqueda), no solo ocultando botones.
- Cada persona ve un árbol reducido a su alcance.

### Respuestas del dueño del producto (2026-10-29)

**Roles por nodo.** Un nodo puede tener varios directores y varios "especialistas", pero **un solo Especialista de Gestión Documental (EGD)**. Todo usuario autenticado ve los documentos públicos del sistema, sin importar el departamento ni la subserie, porque es información pública.

**Acciones permitidas por rol:**

| Rol | Alcance | Acciones |
|---|---|---|
| Administrador | (ver nota 1) | ver, agregar, editar |
| Especialista de Gestión Documental | su nodo | ver, agregar, editar, eliminar, prestar, transferir, depurar, y asignar usuarios a subseries dentro de su nodo |
| Usuario | solo las subseries que se le asignaron dentro de su nodo, más lo público | ver, agregar, editar |
| Visor | solo información pública | ver |

**Alcance del filtro de seguridad:** únicamente el **árbol y la búsqueda**. Préstamos, transferencias, depuración, reportes y contadores no se filtran por alcance en este proyecto.

**Migración de usuarios existentes:** mientras a un usuario no se le asigne nada, se comporta como **Visor**.

Notas y puntos abiertos que se resolvieron como decisión mía (sección 11): el rol Director y los "especialistas" adicionales no tienen acciones definidas por el dueño del producto; el administrador del sistema no aparece con "eliminar".

## 6. La interfaz

- **Estructura de la pantalla principal:** el árbol (recortado al alcance del usuario) a un lado; al elegir un nodo se ven sus subseries y sus documentos. "Agregar documento" actúa en el contexto del nodo y la subserie elegidos. Esto refleja cómo se trabaja hoy (el usuario navega hasta su departamento, elige la subserie y carga).
- Lo secundario se agrupa en secciones de gestión y configuración, fuera del camino diario. Lo avanzado se muestra solo cuando se necesita.
- Estilo: moderno, minimalista, iconos sugerentes y consistentes, colores y tipografía con contraste legible.
- **Pendiente de elegir entre tres variantes (A barra lateral, B cinta, C caja de búsqueda al centro):** las maquetas mostradas no reflejaban el árbol. Se rehacen, ver sección 11.

## 7. Búsqueda integrada (nueva; no existe código previo)

- Una caja de texto libre: nombre del documento o cualquier dato de sus metadatos (fecha de creado, departamento, municipio, provincia, etc.).
- Filtros que se construyen en tiempo de ejecución a partir de `cl_VarSubserie` de cada subserie, porque los campos los define cada cliente.
- Devuelve un documento o un listado de los que cumplan las condiciones. Siempre respeta el alcance de seguridad (sección 5).
- Debe funcionar en SQL Server y en Access.

## 8. Alcance del trabajo, por fases (orden propuesto)

1. Base visual: sistema de diseño, shell principal, splash y about.
2. Seguridad por alcance (solo SQL Server): modelo de asignaciones, pantallas "Permisos de mi área", filtrado en consultas.
3. Flujo de agregar documentos, simplificado y guiado.
4. Búsqueda integrada.
5. Resto de pantallas, reorganizadas por importancia.
6. Ayuda actualizada y documentación.

La refactorización y la optimización se hacen pantalla por pantalla mientras se rediseña, no como proyecto aparte.

## 9. Objetivos, no objetivos y antiobjetivos

**Objetivos:** mínima capacitación; flujos principales cortos; seguridad por alcance real; búsqueda sobre metadatos variables.

**No objetivos:** cambiar el motor de datos; soportar otros motores; migrar a otro lenguaje o framework; módulo de seguridad para Access.

**Antiobjetivos:** una interfaz bonita pero igual de cargada; perder o corromper datos o metadatos existentes de clientes; romper el modo Access de un solo usuario; una refactorización global sin red de seguridad.

## 10. Restricciones

- Delphi 10.3 (RAD Studio 10.3 Rio), VCL, DevExpress 19.1, TMS, FastReport, JVCL.
- Archivos fuente en ANSI/Windows-1252: se conserva la codificación al editar.
- `UMAINFORM.pas` (más de 10.000 líneas) y `UCapaDatos.pas` (más de 5.000) concentran lógica; no existen pruebas automáticas.
- Los clientes ya tienen datos en producción: los cambios de esquema pasan por la rutina de actualización existente (`UpDateDB`) y deben ser compatibles hacia atrás.

## 11. Decisiones mías (a revisar)

- Seguir con los componentes DevExpress 19.1 ya instalados y una sola apariencia coherente; evaluar si el estilo VCL actual (`Metropolis UI Blue`) y los skins de DevExpress conviven bien.
- Iconos de la familia Tabler (consistentes y minimalistas), exportados a la resolución que necesite la interfaz.
- Especialista y director como roles ligados a un nodo del árbol; unificar `cl_especialista` y `cl_Resp_Gest_Arch` con `tb_user`.
- El especialista abarca solo su nodo, sin descender a hijos; el director sí desciende.
- Restringida y Secreta solo las ven quienes tengan asignado el nodo y la subserie.
- El administrador del sistema ve todo.
- En modo Access, la interfaz muestra todo su árbol sin permisos.
- **Identidad y límite de la seguridad:** el login es propio de la aplicación: valida contra `cl_Resp_Gest_Arch` (usuario, contraseña con `md5.pas`, rol, habilitado) en `TSecurityClass.GetRol`, y guarda el nombre del rol en `UDM.Rol`; `tb_user` existe aparte y es el destino de claves foráneas (por ejemplo `tb_tree_directors.user_id`), con el mismo usuario `administrador` en ambas, y todos los equipos se conectan a SQL Server con la misma cuenta técnica (`geoconn`, fijada en `UCapaDatos.pas`). Por tanto la seguridad por alcance se impone en la capa de datos de la aplicación (consultas filtradas en un único punto, no repartidas por las pantallas). No protege contra quien abra la base directamente con la cuenta técnica; endurecer eso (vistas, procedimientos o seguridad a nivel de fila) queda fuera de este proyecto.
- **Búsqueda:** por defecto recorre solo las subseries dentro del alcance del usuario, con la subserie como filtro opcional. El texto libre busca en los campos de tipo caracteres y memo de cada tabla `md_*` y en los datos fijos (código, título). Los filtros por fecha, número o booleano salen del tipo del campo. Si el volumen real lo exige, se evalúa una tabla de apoyo de búsqueda.
- **Esquema:** las tablas nuevas de asignación son aditivas (no modifican las existentes) y se crean en ambos motores, vacías en Access. Un ejecutable viejo no debe fallar al encontrarlas.
- **Medida de éxito de "poca capacitación":** un usuario nuevo, con una explicación de unos minutos, agrega un documento y encuentra uno por un metadato sin ayuda. Se comprueba con una prueba corta con usuarios reales al terminar la fase 1 y al terminar cada flujo principal.
- **Director:** mismas acciones que el Usuario (ver, agregar, editar), sobre su nodo y todos los hijos con todas sus subseries. No elimina, presta, transfiere ni depura (eso es del EGD).
- **"Especialistas" adicionales del nodo** (distintos del EGD): se tratan como Usuarios con subseries asignadas por el EGD.
- **Administrador del sistema:** ve todo el árbol y todos los documentos (agregar y editar según la tabla). Sin permiso de eliminar documentos; la depuración y eliminación quedan en manos del EGD de cada nodo. La administración del sistema (usuarios, clasificadores, estructura) es función suya aparte de las acciones sobre documentos.
- **Un nodo sin EGD asignado:** el administrador debe poder asignarlo; hasta entonces nadie elimina, presta, transfiere ni depura en ese nodo.
- **Actualización:** los usuarios existentes pasan a Visor al instalar. El administrador asigna un EGD por nodo y ese EGD asigna subseries. Hay que prever una vía para que el administrador pueda hacerlo desde el primer arranque sin quedar bloqueado.
- **Operaciones que cruzan nodos** (préstamos, transferencias, depuración, reportes) no se filtran por alcance en este proyecto: es una limitación conocida, a revisar en una fase posterior.
- **Variantes de pantalla principal:** se rehacen las maquetas con el árbol incluido y se decide antes de construir la fase 1; esa decisión es del dueño del producto.

## 12. Se deja al constructor

Elección final de componentes de cada pantalla, formato de la ayuda (por ejemplo CHM u otro), esquema exacto de las tablas nuevas de asignación, y estrategia de pruebas para las partes que se refactoricen.

## 13. Funcionalidades ampliadas (elegidas por el dueño del producto tras el estudio del arte, 2026-10-29)

Origen: estudio de sistemas de gestión documental populares (M-Files, Paperless-ngx, DocuWare, Laserfiche, SharePoint, Alfresco, Nuxeo, OpenKM, AtoM) y de la práctica de gestión de registros (ISO 15489). Las fuentes son secundarias (resúmenes de proveedores y comparadores).

**Incluidas en este proyecto:**

| # | Funcionalidad | Fase |
|---|---|---|
| 1 | Búsqueda con autocompletado, resaltado y vista previa en la misma pantalla | 4 |
| 2 | Vistas guardadas por usuario: "Mis búsquedas", "Recientes", "Favoritos" | 4 |
| 3 | Carga con arrastrar y soltar; metadatos precompletados (repetir últimos valores o plantilla por subserie) | 3 |
| 4 | Pantalla de inicio por tareas: "Mis pendientes", lo recién agregado, préstamos por vencer | 1 y 5 |
| 5 | Ayuda dentro de la pantalla: textos guía, pasos señalados, recorrido inicial | 1 a 6 (transversal) |
| 6 | Calendario de conservación con alertas y revisión y aprobación del EGD (aprobar, ampliar o documentar) antes de depurar | 5 |
| 7 | Acta de eliminación y de transferencia generada automáticamente, con firma | 5 |
| 8 | Instrumentos de descripción: inventario por nodo o subserie y cuadro de clasificación exportable a PDF o Excel | 5 |
| 11 | Solicitud de acceso a un documento restringido, al EGD con un clic | 4 y 5 |
| 12 | Notificaciones dentro del sistema (vencimientos, préstamos, solicitudes) | 5 |
| 13 | Historial de versiones visible y registro de quién consultó o modificó cada documento | 5 |
| 14 | Tablero del EGD: documentos por subserie, vencimientos próximos, préstamos activos | 5 |
| 15 | Inicio de sesión con usuario de Windows o Active Directory, **opcional**: la inscripción dentro del sistema prevalece y el vínculo con AD es una opción por usuario | 2 |
| 19 | API y respaldo programados desde el sistema | 6 |

**Diseñadas en la base de datos pero no implementadas en esta versión:**

| # | Funcionalidad | Qué se deja listo |
|---|---|---|
| 10 | Carpeta vigilada y carga masiva por código de barras | Tablas de lotes de captura, sus elementos y reglas de carpeta (sección 14). Sin pantallas ni procesos. |

**Condicionadas:**

| # | Funcionalidad | Condición |
|---|---|---|
| 16 | Sugerencia automática de subserie y metadatos al cargar | Solo si hay volumen de documentos que la justifique; se decide después de la fase 4. |
| 18 | Firma electrónica integrada | Se evalúa en la fase 5 junto con el punto 7. Las fuentes consultadas no confirman que DocuWare o Laserfiche la tengan de forma nativa. |

**Fuera de alcance por decisión del dueño del producto:** OCR de PDF y TIFF (estudio, punto 9) y bloqueo legal (punto 17).

## 14. Modelo de datos adicional propuesto (mis decisiones, a revisar en el plan de cada fase)

Lo que ya existe y se reutiliza (verificado en `SGDDRHMAIN`):

- `tb_log` y `tb_accionlog`: registran quién hizo qué sobre una subserie y estructura (acciones: Copiar, Eliminar, Modificar, Descargar, Insertar, Visualizar). Base del punto 13; falta una consulta por documento y una pantalla. `tb_log` no guarda el código del documento, solo serie, subserie y estructura: para el historial por documento hay que añadir una columna (`Codigodoc`) de forma aditiva.
- `cl_subseries` (`tgestion`, `tcentral`, `destino`, `Vigencia`, `ayear`): plazos de conservación en archivo de gestión y central y destino final. Base del calendario de conservación (punto 6).
- `TB_Prestamos` y `TB_PrestamosDocumentos` (`FDevolucion`, `FCancelacion`): base de "préstamos por vencer".
- `tb_transferencia` y `tb_indiceinfo`: transferencias e índices generados.
- `tb_solicitud` y `tb_solicitud_documentos`: solicitudes de **préstamo** (no de acceso). La solicitud de acceso (punto 11) usa tabla propia.

Tablas nuevas, todas aditivas y creadas en SQL Server (en Access se crean vacías, salvo que se indique otra cosa):

- `tb_vista_guardada (user_id, idvista, nombre, tipo, criterios)`: búsquedas guardadas y recientes. `tb_favorito (user_id, IdEstructura, id, codsubs, Codigodoc, Version, fecha)`: favoritos.
- `tb_notificacion (idnotif, user_id, tipo, mensaje, referencia, fecha, leida)`: notificaciones internas.
- `tb_revision_conservacion (idrevision, IdEstructura, id, codsubs, Codigodoc, Version, fecha_vence, estado, decidido_por, fecha_decision, decision, motivo)`: revisión del EGD (decisión: aprobar, ampliar, documentar).
- `tb_acta (idacta, tipo, fecha, IdEstructura, id, contenido, firmado_por, fecha_firma)` y `tb_acta_documento`: actas de eliminación y de transferencia.
- `tb_solicitud_acceso (idsolicitud, user_id, IdEstructura, id, codsubs, Codigodoc, Version, fecha, estado, resuelto_por, fecha_resolucion, motivo)`.
- `tb_documento_version (IdEstructura, id, codsubs, Codigodoc, Version, fecha, user_id, resumen)`: solo si las tablas actuales no bastan para el historial de versiones; se confirma en el plan de la fase 5.
- Vinculación opcional a Active Directory: columna `usuario_ad` (nulable) en `cl_Resp_Gest_Arch`; sin ella el usuario entra solo con su cuenta del sistema.
- Respaldo y API programados: parámetros en `tb_sysconfig` o tabla de configuración aparte (`tb_config_respaldo`).
- Captura masiva (punto 10, solo el esquema): `tb_lote_captura (idlote, fecha, user_id, origen, estado, IdEstructura, id, codsubs)`, `tb_lote_captura_item (idlote, orden, archivo, codigo_barras, estado, Codigodoc, error)` y `tb_regla_carpeta (idregla, ruta, IdEstructura, id, codsubs, user_id, activa)`.

Restricción: ninguno de estos cambios puede afectar a un ejecutable antiguo ni a los datos existentes.
