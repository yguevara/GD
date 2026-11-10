# Trazabilidad parte 1 (F5) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ver la vida de un documento (creado, versiones, modificado, consultado, descargado, prestado, devuelto, transferido, depurado) en una linea de tiempo del panel de propiedades y en un dialogo «Historia».

**Architecture:** `tb_log` gana columnas aditivas que identifican el documento y una fecha real ordenable; las escrituras existentes del log pasan la clave del documento. Una unidad pura sin VCL (`UTrazabilidad`) clasifica y ordena eventos; otra (`UTrazabilidadDatos`) los lee de `tb_log` y de los prestamos, filtrando por alcance con `UAlcanceDatos`. La pantalla se construye por codigo, sin `.dfm`.

**Tech Stack:** Delphi 10.3 VCL, FireDAC (SQL Server y Access), DUnitX (`Pruebas/`).

**Spec:** `docs/superpowers/specs/2026-11-05-documentos-carga-consulta-geo-trazabilidad-design.md` (3.6 y fila F5 de la seccion 7). La circulacion entre departamentos (`tb_documento_movimiento`) es la F9 y **no** entra aqui.

## Global Constraints

- Todo el SQL debe funcionar en SQL Server y en Access; DDL aditivo e idempotente (patron de `UEsquemaCarga.pas`: cada sentencia aislada, errores ignorados).
- Reglas de negocio en unidades sin VCL ni `TUDM` (RTL + FireDAC como maximo); codigo nuevo en ASCII (sin acentos en codigo, comentarios ni cadenas de unidades nuevas).
- Seguridad por alcance en un solo punto (`UAlcanceDatos`): la historia respeta el alcance, no se agrega regla nueva.
- Ficheros `.pas` existentes se editan conservando ANSI/Windows-1252 y CRLF (skill `delphi-encoding`); `UCapaDatos.pas` y `UMAINFORM.pas` por script de bytes o edicion que no los normalice.
- Unidades nuevas se agregan a `ArchiGenioPro.dpr` y, si son testeables, a `Pruebas/PruebasArchiGenio.dpr`.
- Pruebas con base real se omiten (`Assert.Pass`) sin `ARCHIGENIO_TEST_DB` (SQL Server) o `ARCHIGENIO_TEST_MDB` (copia de Access).
- Cada fase termina con una lista manual en `docs/superpowers/plans/`.

## Review Focus

- Eventos antiguos de `tb_log` sin `codigodoc` (anteriores a la F5): no aparecen en la historia y no rompen la consulta; el mensaje del panel dice que la historia empieza cuando se instalo la F5.
- Dos documentos con el mismo `Codigodoc` en nodos o versiones distintos: la historia de uno no incluye eventos del otro.
- Usuario sin alcance sobre el nodo del documento: la historia devuelve vacio, no las filas ni un error.
- `tb_log` bloqueada o sin permiso para alterar: la aplicacion arranca igual y la historia muestra «no disponible», sin excepcion.
- Documento con miles de eventos de consulta: la linea de tiempo se limita (ultimos 200) e indica que hay mas.

---

### Task 1: Esquema de trazabilidad en `tb_log`

**Files:**
- Create: `UEsquemaTrazabilidad.pas`, `SCRIPTS/trazabilidad_esquema.sql`, `Pruebas/UPruebasEsquemaTrazabilidad.pas`
- Modify: `UCapaDatos.pas` (`UpDateDB`, tras `CrearEsquemaCarga(Conn, TBD = 'S');`), `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Produces:
  - `procedure CrearEsquemaTrazabilidad(Conn: TFDConnection; EsSqlServer: Boolean);`
  - `function EsquemaTrazabilidadCompleto(Conn: TFDConnection): Boolean;`
  - Columnas nuevas de `tb_log`: `codigodoc VARCHAR(20) NULL`, `iddoc INT NULL` (id del nodo), `codsubsdoc VARCHAR(50) NULL`, `versiondoc VARCHAR(12) NULL`, `fecha_evento DATETIME NULL`; indice `IX_tb_log_codigodoc` sobre `(codigodoc, IdEstructura)`.

- [ ] **Step 1: Write the failing tests** en `UPruebasEsquemaTrazabilidad.pas` (copiar el patron de `UPruebasEsquemaCarga.pas`): `SqlServer_CreaYEsIdempotente` y `Access_CreaYEsIdempotente` llaman dos veces a `CrearEsquemaTrazabilidad` y comprueban con `SELECT COUNT(codigodoc), COUNT(iddoc), COUNT(codsubsdoc), COUNT(versiondoc), COUNT(fecha_evento) FROM tb_log` que `EsquemaTrazabilidadCompleto` da `True` y que las filas previas no cambian (`SELECT COUNT(*)` igual antes y despues).
- [ ] **Step 2: Run** `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y el exe. Expected: no compila (unidad inexistente).
- [ ] **Step 3: Implement** `UEsquemaTrazabilidad.pas` con las firmas de Interfaces; SQL Server con `IF COL_LENGTH('dbo.tb_log','x') IS NULL ALTER TABLE tb_log ADD x ...` y el indice con `IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_tb_log_codigodoc')`; Access con `ALTER TABLE tb_log ADD COLUMN x ...` (`DATETIME`) y `CREATE INDEX`. Documentar el DDL de SQL Server en `SCRIPTS/trazabilidad_esquema.sql`. Llamarla en `UpDateDB`; si `EsquemaTrazabilidadCompleto` da `False`, la aplicacion sigue (no hay mas cambios en el arranque).
- [ ] **Step 4: Run** compilar y exe, luego `scripts/compilar.ps1 ArchiGenioPro.dproj`. Expected: pruebas en verde (total anterior intacto; las de base real omitidas sin variable) y aplicacion compilada.
- [ ] **Step 5: Commit** `F5: columnas de documento y fecha real en tb_log (esquema aditivo)`.

---

### Task 2: Clasificacion y orden de eventos (logica pura)

**Files:**
- Create: `UTrazabilidad.pas`, `Pruebas/UPruebasTrazabilidad.pas`
- Modify: `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Produces:
  - `TTipoEvento = (teCreado, teNuevaVersion, teModificado, teConsultado, teDescargado, tePrestado, teDevuelto, teTransferido, teDepurado, teOtro);`
  - `TEventoDoc = record Fecha: TDateTime; Tipo: TTipoEvento; Usuario, Rol, Detalle: string; end;`
  - `function TipoDesdeAccion(Accion: Integer): TTipoEvento;`
  - `function EtiquetaEvento(Tipo: TTipoEvento): string;` (texto corto en ASCII: `'Creado'`, `'Nueva version'`, `'Modificado'`, `'Consultado'`, `'Descargado'`, `'Prestado'`, `'Devuelto'`, `'Transferido'`, `'Depurado'`, `'Otro'`)
  - `procedure OrdenarYLimitar(var Eventos: TArray<TEventoDoc>; Maximo: Integer; out HayMas: Boolean);` (mas reciente primero; conserva los `Maximo` mas recientes)
  - Constantes `ACCION_ELIMINAR = 2; ACCION_MODIFICAR = 3; ACCION_INSERTAR = 5; ACCION_VISUALIZAR = 14;` y `ACCION_DESCARGAR` con el valor leido de `tb_accionlog` (ver Step 1).

- [ ] **Step 1: Leer los codigos reales** de `tb_accionlog` (`SELECT * FROM tb_accionlog` en la base de pruebas o en `Win32\Debug\Listado_Tablas.txt`/datos de ejemplo) y anotar en un comentario de la unidad la correspondencia id -> nombre (Copiar, Eliminar, Modificar, Descargar, Insertar, Visualizar); si algun valor no se puede confirmar, dejar `teOtro` para ese y anotarlo en la lista manual.
- [ ] **Step 2: Write the failing tests**: `TipoDesdeAccion(5) = teCreado`, `(3) = teModificado`, `(2) = teDepurado`, `(14) = teConsultado`, `(descargar) = teDescargado`, `(999) = teOtro`; `OrdenarYLimitar` con 3 eventos en desorden da fechas descendentes y `HayMas = False`; con 5 eventos y `Maximo = 3` deja los 3 mas recientes y `HayMas = True`; con `Maximo = 0` o lista vacia no falla y `HayMas = False`; `EtiquetaEvento` devuelve una cadena no vacia para todos los valores del enumerado.
- [ ] **Step 3: Run** compilar y exe. Expected: no compila.
- [ ] **Step 4: Implement** `UTrazabilidad.pas` (solo RTL; sin acentos).
- [ ] **Step 5: Run** compilar y exe. Expected: verde.
- [ ] **Step 6: Commit** `F5: tipos de evento del documento, clasificacion por accion y orden`.

---

### Task 3: Registrar la clave del documento en las escrituras del log

**Files:**
- Modify: `UCapaDatos.pas` (`TUDM.log` ~4184 y las llamadas de eliminar/modificar/agregar en ~4985, ~4991, ~5381, ~5462), `UCargaDocumento.pas` (`EscribirBitacora`), `Pruebas/UPruebasCargaDocumento.pas`
- Create: `UTrazabilidadDatos.pas` (solo la parte de escritura en esta tarea), `Pruebas/UPruebasTrazabilidadDatos.pas`

**Interfaces:**
- Consumes: `TClaveDocumento` de `UDocumentoVista` (`IdEstructura`, `Id`, `CodSubs`, `Fecha`, `Version`, `Codigodoc`); columnas de Task 1; constantes de Task 2.
- Produces:
  - `procedure RegistrarEventoDoc(Conn: TFDConnection; const Clave: TClaveDocumento; Accion: Integer; const Msg, Usuario, Rol, Serie: string);` inserta una fila en `tb_log` con las columnas de siempre mas `codigodoc`, `iddoc`, `codsubsdoc`, `versiondoc` y `fecha_evento = Now` (parametro `ftDateTime`); si faltan las columnas nuevas inserta sin ellas (captura el error y reintenta con el INSERT antiguo) para no perder la bitacora.
  - `procedure TUDM.LogDoc(const Clave: TClaveDocumento; Mensaje: string; Acc: Integer);` (nueva; `TUDM.log` queda igual).

- [ ] **Step 1: Write the failing tests** (base real, se omiten sin variable): `RegistrarEventoDoc` con `Codigodoc = 'F5T-001'`, `Accion = 5` deja una fila con `codigodoc = 'F5T-001'`, `iddoc`, `codsubsdoc`, `versiondoc` correctos y `fecha_evento` no nulo; ampliar el test existente de `UPruebasCargaDocumento.pas` (el que cuenta `tb_log ... F3T-001`) para exigir tambien `codigodoc = 'F3T-001'` tras `GuardarDocumento`; limpiar en `TearDown` con `DELETE FROM tb_log WHERE codigodoc LIKE 'F5T-%'`.
- [ ] **Step 2: Run** compilar y exe con la variable definida. Expected: falla (funcion inexistente / `codigodoc` nulo).
- [ ] **Step 3: Implement** `RegistrarEventoDoc` en `UTrazabilidadDatos.pas`; hacer que `EscribirBitacora` de `UCargaDocumento.pas` la use con la clave del documento recien guardado; agregar `TUDM.LogDoc` que la llama con `UDM.UserName`, `UDM.Rol` y la serie del `SudSDetail`, y cambiar a `LogDoc` las cuatro llamadas de `UDM.log` que ya hablan de un documento concreto (eliminado, modificando, agregado, y la de la linea ~5381) usando la clave del `DataSet` de `tb_SeriesDatos` (campos `IdEstructura`, `id`, `codsubs`, `Fecha`, `Version`, `Codigodoc`). Tocar `UCapaDatos.pas` por script de bytes (ANSI).
- [ ] **Step 4: Run** compilar y exe, luego `scripts/compilar.ps1 ArchiGenioPro.dproj`. Expected: verde y aplicacion compilada.
- [ ] **Step 5: Commit** `F5: el log de acciones guarda la clave del documento`.

---

### Task 4: Registrar consultas y descargas del documento

**Files:**
- Modify: `UMAINFORM.pas` (apertura desde la lista de documentos: `ListaDocsFicheros`/el manejador de «Abrir» de `FListaDocs`; y el punto que hoy llama a `DownloadFileFromFTP`/fachada de descarga de `TUDM`), `UCapaDatos.pas` (fachada de descarga/apertura de F4)

**Interfaces:**
- Consumes: `TUDM.LogDoc` (Task 3); `ACCION_VISUALIZAR` y `ACCION_DESCARGAR` (Task 2).
- Produces: cada apertura de un fichero del documento registra un evento `Visualizar`; cada descarga o exportacion registra `Descargar`; ninguna de las dos bloquea la accion si el log falla (`try/except` silencioso).

- [ ] **Step 1: Test** (parte pura ya cubierta en Task 3); aqui solo se agrega a la lista manual (Task 7): abrir un fichero crea un evento «Consultado» y descargarlo un «Descargado».
- [ ] **Step 2: Implement** llamadas a `LogDoc` en los dos puntos, usando la clave del documento seleccionado en la lista (`TClaveDocumento` de `FListaDocs`); para «Obtener el expediente completo» registrar un evento por cada documento incluido solo si el costo es bajo (maximo 1 por documento y por exportacion); si se complica, registrar uno por exportacion en la clave del expediente.
- [ ] **Step 3: Run** `scripts/compilar.ps1 ArchiGenioPro.dproj`. Expected: compilada.
- [ ] **Step 4: Commit** `F5: consultas y descargas de un documento quedan en su historia`.

---

### Task 5: Linea de tiempo del documento (lectura con alcance)

**Files:**
- Modify: `UTrazabilidadDatos.pas`, `Pruebas/UPruebasTrazabilidadDatos.pas`

**Interfaces:**
- Consumes: `TEventoDoc`, `OrdenarYLimitar` (Task 2); `TClaveDocumento`; `TAlcanceUsuario` y `FiltroDocumentos`/`AplicarParametros` de `UAlcanceDatos`; `TB_Prestamos` (`FPrestamo`, `FDevolucion`, `Prestamista`, `Responsable`) y `TB_PrestamosDocumentos` (claves `IdEstructura, id, IdPrestamo, Codigodoc, fecha, version`).
- Produces:
  - `function CargarLineaTiempo(Conn: TFDConnection; Alcance: TAlcanceUsuario; const Clave: TClaveDocumento; Maximo: Integer; out HayMas: Boolean): TArray<TEventoDoc>;` (`Alcance = nil` = Access o administrador, sin filtro, igual que `CargarIndicadores`). Une: filas de `tb_log` con `codigodoc = Clave.Codigodoc AND IdEstructura = Clave.IdEstructura AND iddoc = Clave.Id` (la fecha viene de `fecha_evento`; las que la tienen nula se omiten); un evento `tePrestado` por prestamo (con `FPrestamo`) y otro `teDevuelto` si `FDevolucion` no es nula, con el `Detalle` = prestamista. Devuelve vacio si el nodo esta fuera del alcance. Los parametros de SQL son siempre parametros, nunca concatenados.

- [ ] **Step 1: Write the failing tests** (base real, sembrado propio `F5T-*`, mismo patron de `UPruebasDocumentoVistaDatos`): tres filas de log (insertar, modificar, visualizar) del documento `F5T-001` salen en orden descendente con los tipos esperados; una fila del mismo codigo en otro nodo no aparece; una fila del mismo codigo/nodo pero con `iddoc` distinto no aparece; una fila sin `fecha_evento` no aparece y no rompe; un prestamo con devolucion agrega `tePrestado` y `teDevuelto`, uno sin devolucion solo `tePrestado`; con alcance que no cubre el nodo devuelve vacio; con 5 eventos y `Maximo = 3` da 3 y `HayMas = True`; con las columnas nuevas ausentes (usar `Conn` a una tabla sin ellas solo si es viable; si no, probar solo que no lanza excepcion al capturarla y devuelve vacio).
- [ ] **Step 2: Run** compilar y exe con las variables. Expected: falla (funcion inexistente).
- [ ] **Step 3: Implement** `CargarLineaTiempo`; leer el `tb_log` con una consulta parametrizada; capturar `EFDDBEngineException` y devolver vacio; el filtro de alcance se evalua una vez sobre el nodo del documento reutilizando la logica de `FiltroDocumentos` (misma condicion que usa `CargarIndicadores`).
- [ ] **Step 4: Run** compilar y exe. Expected: verde.
- [ ] **Step 5: Commit** `F5: linea de tiempo del documento (log y prestamos) respetando el alcance`.

---

### Task 6: Panel y dialogo «Historia»

**Files:**
- Create: `UHistoriaDocumento.pas` (dialogo por codigo, sin `.dfm`)
- Modify: `UPanelDocumentos.pas`, `UMAINFORM.pas`, `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: `CargarLineaTiempo`, `EtiquetaEvento`, `TEventoDoc` (Tasks 2 y 5); patron `OnPedirFicheros`/`FEtiquetas`/`FTema` de `UPanelDocumentos`.
- Produces:
  - `TSolicitudHistoria = function(const Clave: TClaveDocumento; out HayMas: Boolean): TArray<TEventoDoc> of object;` y propiedad `TPanelDocumentos.OnPedirHistoria`.
  - En el panel de propiedades, grupo «HISTORIA» con los 5 eventos mas recientes (fecha, etiqueta, usuario) y un enlace «Ver historia completa» que abre `procedure MostrarHistoria(const Titulo: string; const Eventos: TArray<TEventoDoc>; HayMas: Boolean);` en `UHistoriaDocumento.pas`.
  - `function TMAIN.ListaDocsHistoria(const Clave: TClaveDocumento; out HayMas: Boolean): TArray<TEventoDoc>;` (llama a `CargarLineaTiempo` con el `Alcance` del usuario y `Maximo = 200`; ante excepcion devuelve vacio y deja el motivo en `lista_error.log` como `RegistrarErrorLista`).

- [ ] **Step 1: Implement** `UHistoriaDocumento.pas`: dialogo modal con `TListView` (vsReport: Fecha, Evento, Usuario, Detalle), tema oscuro/claro del panel, aviso «Se muestran los 200 eventos mas recientes» si `HayMas`, y «Sin eventos registrados. La historia empieza cuando se instalo esta version.» si esta vacia.
- [ ] **Step 2: Implement** la seccion en `MostrarPropiedades`/`LimpiarPropiedades` de `UPanelDocumentos.pas`, cargada solo al seleccionar el documento (sin hilo; una consulta), y el cableado `FListaDocs.OnPedirHistoria := ListaDocsHistoria;` en `UMAINFORM.pas`. Con `shell_clasico.flag` no hay panel y no cambia nada.
- [ ] **Step 3: Run** `scripts/compilar.ps1 ArchiGenioPro.dproj` y las pruebas. Expected: compilada y verde.
- [ ] **Step 4: Verificar visualmente** (arrancar la app, seleccionar un documento con eventos, abrir «Ver historia completa», probar tema oscuro) y anotar lo observado; si no se puede abrir la app, decirlo explicitamente en el commit.
- [ ] **Step 5: Commit** `F5: seccion Historia en el panel de propiedades y dialogo de historia completa`.

---

### Task 7: Lista de verificacion manual y estado en el diseno

**Files:**
- Create: `docs/superpowers/plans/2026-11-09-verificacion-f5.md`
- Modify: `docs/superpowers/specs/2026-11-05-documentos-carga-consulta-geo-trazabilidad-design.md` (fila F5 de la seccion 7: estado **Implementada**, plan y lista)

- [ ] **Step 1: Escribir la lista** con el formato de `2026-11-05-verificacion-f3.md` (tabla Caso / Usuario / Que hacer / Esperado / Registrado) cubriendo: crear un documento y verlo como «Creado»; modificarlo; abrir un fichero («Consultado»); descargar («Descargado»); prestar y devolver; eliminar (el documento ya no esta en la lista, su historia queda en `tb_log`); documento anterior a la F5 (historia vacia con el aviso); usuario con alcance restringido; documento con mas de 200 eventos; modo Access; tema oscuro; `shell_clasico.flag`; `tb_log` sin permiso para alterar. Incluir lo que **no** tiene prueba automatica (panel, dialogo, cableado de consultas/descargas) y las acciones de `tb_accionlog` que no se pudieron confirmar en la Task 2.
- [ ] **Step 2: Actualizar el estado** de la F5 en el diseno.
- [ ] **Step 3: Run** compilar y exe, compilar la aplicacion. Expected: todas las pruebas en verde (total anterior mas las nuevas) y aplicacion compilada.
- [ ] **Step 4: Commit** `F5: lista de verificacion manual y estado de la fase en el diseno`.
