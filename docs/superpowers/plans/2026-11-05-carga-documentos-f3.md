# F3 Agregar documentos (A con el asistente de B) y metadatos dinámicos — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que una persona pueda soltar varios archivos a la vez sobre una subserie, completar los datos comunes y los propios de la subserie (generados en tiempo de ejecución) y guardarlos como documentos, con sus ficheros en el almacén S3, sin usar la rejilla.

**Architecture:** La lógica va en unidades sin VCL ni `UDM` (modelo de candidatos, metadatos dinámicos, guardado transaccional por documento con compensación del almacén, lote retomable), probadas desde `Pruebas/` con SQL Server y Access. La pantalla `UPantallaCarga` se construye por código (sin `.dfm`), es una sola pantalla con dos formas de recorrerla (Rápido y Guiado) y se abre desde «Agregar documento» del shell. Los ficheros se suben con `IAlmacenFicheros` (F4); esta fase no escribe en FTP.

**Tech Stack:** Delphi 10.3, FireDAC (MSSQL y MSAccess), DUnitX, `UAlmacenFicheros`/`UAlmacenServidor`/`UAlmacenS3` (F4), `UAlcance`/`UAlcanceDatos`, `UTopografia`, `UTema`, `UIconos`.

**Spec:** `docs/superpowers/specs/2026-11-05-documentos-carga-consulta-geo-trazabilidad-design.md` (sección 3.1 y fila F3 de la tabla de fases). Maquetas aprobadas: `.superpowers/brainstorm/838-1793891670/content/variantes-carga.html` y `carga-y-consulta.html`.

## Global Constraints

- Código nuevo en ASCII (sin acentos en comentarios ni cadenas, textos de pantalla incluidos), CRLF, como `UAlcance` y las unidades de la F4.
- Unidades de lógica sin VCL ni `UDM`: RTL y FireDAC como máximo; toda la SQL vale en SQL Server y en Access (sin `TOP`, `ISNULL`, `LIMIT`, `||`; fechas y números por parámetros tipados con `ParamByName`).
- Unidades y formularios nuevos van al `uses` de `ArchiGenioPro.dpr` (`UFoo in 'UFoo.pas'`); las de lógica también a `Pruebas/PruebasArchiGenio.dpr`.
- `UMAINFORM.pas` tiene cambios sin confirmar ajenos a esta fase y fin de línea mixto: editar por script de bytes (`latin-1`) y confirmar solo los hunks propios (`git diff -U0` filtrado + `git apply --cached --unidiff-zero`).
- Los ficheros se guardan con la convención de la F4: `urlraiz` = `UDM.UrlRaizNuevos` (`s3://<servidor>/`), `path` = `\IdEstructura\codserie\codsubs\<namefile>\Anexos Digitales\` o `\Fuentes\`, `nombre` = nombre del archivo; `namefile` del documento nuevo = su `Codigodoc` (con `NombreSeguro`). Sin servidor S3 registrado la carga no se ofrece: se explica y se lleva al clasificador de servidores.
- Claves del documento: `IdEstructura, id, codsubs, Fecha, Version, Codigodoc`; `Version` = `'1.0'` y `Fecha` = hoy (sin hora) como hoy; el código sigue la regla de `TUDM.ProponerValores`.
- Un fallo en un documento no pierde los demás. Los objetos subidos de un documento cuyo guardado en base falla se borran (compensación).
- Permiso de agregar (`acAgregar` de `UAlcance`) y topografía completa (`UTopografia`) se validan antes de subir nada, con los mensajes que ya existen.
- Pruebas contra MinIO real: variable `ARCHIGENIO_TEST_S3=host:puerto|usuario|secreto` (se omiten si falta). Bases de prueba: `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` = copia de `BD\SDbd.mdb`.
- Ejecutar pruebas: `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y luego `Pruebas\Win32\Debug\PruebasArchiGenio.exe` (hoy 229 en verde; el total solo debe subir). Compilar la aplicación: `scripts/compilar.ps1 ArchiGenioPro.dproj`.
- Fuera de esta fase: coordenadas/georreferencia (`tb_DocCoord`, F6), OCR y búsqueda por contenido (F7), carpetas vigiladas (`tb_regla_carpeta`), lector de códigos de barras.

## Review Focus

1. Dos usuarios cargando a la vez en la misma subserie: el mismo `Codigodoc` propuesto no debe terminar duplicado (Tarea 3).
2. Lote de varios archivos donde uno falla a mitad (red, base, obligatorio): los demás se guardan, el fallido queda reintentable y no deja objetos huérfanos ni filas a medias (Tareas 3 y 4).
3. Nombres de archivo repetidos dentro del lote, con espacios, `ñ`, `#`, `+`, y archivos de 0 bytes: cada uno es un fichero distinto, ninguno se pisa (Tarea 3).
4. Campos propios de la subserie: tipo número/fecha con texto inválido, texto más largo que `Longitud`, obligatorio vacío, subserie sin tabla de metadatos y subserie con tabla pero sin variables (Tarea 2).
5. Soltar 300 archivos de golpe: la pantalla no se congela ni crea 300 controles pesados (Tarea 5).

---

## File Structure

| Archivo | Responsabilidad |
|---|---|
| `UCargaModelo.pas` (nuevo, puro) | Candidato, estados, título desde el nombre, códigos secuenciales, «aplicar a todos», validación de obligatorios |
| `UMetadatosSubserie.pas` (nuevo, FireDAC) | Campos propios de la subserie desde `cl_VarSubserie`, validación por tipo y alta/lectura en la tabla `md_*` |
| `UEsquemaCarga.pas` (nuevo, FireDAC) | Columna `obligatorio` en `cl_VarSubserie` y tabla `tb_carga_valores` (idempotente); copia en `SCRIPTS/carga_esquema.sql` |
| `UCargaDocumento.pas` (nuevo, FireDAC) | Guardado de un documento: reserva de código, transacción, ficheros, bitácora, compensación |
| `UCargaLote.pas` (nuevo, FireDAC) | Lote (`tb_lote_captura`, `_item`), reintento y últimos valores por usuario y subserie |
| `UPantallaCarga.pas` (nuevo, sin `.dfm`) | Pantalla Rápido/Guiado, soltar archivos, tarjetas de datos comunes y propios |
| `UShellPrincipal.pas`, `UMAINFORM.pas`, `ArchiGenioPro.dpr`, `UCapaDatos.pas` | Entrada «Agregar documentos» y cableado |

---

### Task 1: Modelo de la carga (lógica pura)

**Files:**
- Create: `UCargaModelo.pas`
- Test: `Pruebas/UPruebasCargaModelo.pas` (agregar a `Pruebas/PruebasArchiGenio.dpr`)

**Interfaces:**
- Consumes: nada.
- Produces:
  - `TEstadoCandidato = (ecEspera, ecFalta, ecListo, ecSubiendo, ecGuardado, ecError)`.
  - `TCandidato = record Archivo: string; Titulo, Codigo, Acceso: string; Fecha: TDateTime; EsExpediente: Boolean; Fuentes: TArray<string>; Meta: TArray<TValorMeta>; Estado: TEstadoCandidato; Error: string; end` y `TValorMeta = record Nombre, Valor: string; end`.
  - `function TituloDesdeNombre(const Archivo: string): string` (sin carpeta ni extensión; `_` y `-` repetidos a espacio; recorta; primera letra en mayúscula).
  - `function SiguienteCodigo(const Ultimo, IdEstructura, CodSubs, Version: string): string` (misma regla que `TUDM.ProponerValores`; sin último = `IdEstructura + CodSubs + Version`) y `function CodigosParaLote(const Ultimo, IdEstructura, CodSubs, Version: string; Cantidad: Integer): TArray<string>` (consecutivos y distintos).
  - `procedure AplicarATodos(var Lote: TArray<TCandidato>; const Plantilla: TCandidato; Campos: TCamposComunes)` con `TCamposComunes = set of (ccTitulo, ccFecha, ccAcceso, ccEsExpediente)`; no toca `Archivo`, `Codigo` ni `Estado`.
  - `function Faltantes(const C: TCandidato; const Obligatorios: TArray<string>): TArray<string>` (nombres de los datos fijos —`Titulo`, `Codigo`, `Fecha`— y de los metadatos obligatorios vacíos) y `function EstadoTrasEditar(const C: TCandidato; const Obligatorios: TArray<string>): TEstadoCandidato` (`ecListo` si no falta nada, `ecFalta` si falta).

- [ ] **Step 1: Write the failing tests** en `Pruebas/UPruebasCargaModelo.pas`: `TituloDesdeNombre('C:\x\informe_final-2026__v2.pdf') = 'Informe final 2026 v2'`; sin extensión y con solo espacios dan `''`; `SiguienteCodigo('', 'A.4.3', '074', '1.0') = 'A.4.3074' + '1.0'`; `SiguienteCodigo` de un último con sufijo numérico incrementa conservando el ancho (usar los valores reales que produce `ProponerValores` leyéndolo antes de escribir el test; si el patrón es `DOC###` el test lo fija); `CodigosParaLote(..., 5)` da 5 códigos distintos y ordenados; `AplicarATodos` copia solo los campos pedidos y deja intactos `Archivo`, `Codigo` y `Estado`; `Faltantes` con título vacío y un obligatorio vacío devuelve ambos nombres; `EstadoTrasEditar` pasa de `ecFalta` a `ecListo` al completar.
- [ ] **Step 2: Run** `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`. Expected: no compila por unidades inexistentes (RED).
- [ ] **Step 3: Implement** `UCargaModelo.pas` con las firmas de Interfaces.
- [ ] **Step 4: Run** compilar y exe. Expected: pruebas de la tarea en verde y el total anterior (229) intacto.
- [ ] **Step 5: Commit** `F3: modelo de la carga de documentos (candidatos, titulos, codigos y validacion)`.

---

### Task 2: Metadatos dinámicos de la subserie

**Files:**
- Create: `UMetadatosSubserie.pas`, `UEsquemaCarga.pas`, `SCRIPTS/carga_esquema.sql`
- Test: `Pruebas/UPruebasMetadatosSubserie.pas`, `Pruebas/UPruebasEsquemaCarga.pas`
- Modify: `UCapaDatos.pas` (llamada a `CrearEsquemaCarga` en `UpDateDB`, junto a `CrearEsquemaAlmacen`), `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: `cl_VarSubserie`, `CL_SubseriesTipoVar`, `cl_subseries.NombreTablaMetadatos`.
- Produces:
  - `UEsquemaCarga`: `procedure CrearEsquemaCarga(Conn: TFDConnection; EsSqlServer: Boolean)` agrega `cl_VarSubserie.obligatorio BIT` (nulo = no obligatorio) y crea `tb_carga_valores (user_id VARCHAR(100), codsubs VARCHAR(50), campo VARCHAR(100), valor VARCHAR(255))` con clave `(user_id, codsubs, campo)`; y `function EsquemaCargaCompleto(Conn: TFDConnection): Boolean`.
  - `UMetadatosSubserie`: `TTipoMeta = (tmTexto, tmMemo, tmFecha, tmEntero, tmReal, tmBooleano)`; `TCampoMeta = record Nombre, Etiqueta: string; Tipo: TTipoMeta; Longitud, Orden: Integer; Obligatorio: Boolean; end`; `function CargarCamposSubserie(Conn: TFDConnection; const CodSubs: string): TArray<TCampoMeta>` (ordenados por `Orden`; vacío si la subserie no tiene variables); `function NombreTablaMeta(Conn: TFDConnection; const CodSubs: string): string` (`NombreTablaMetadatos`, o `''` si no tiene); `function ValidarValorMeta(const Campo: TCampoMeta; const Texto: string): string` (`''` = válido; mensaje en español si es obligatorio y vacío, si excede `Longitud`, si la fecha, el entero o el real no son válidos con el separador decimal `.` que fija el `.dpr`); `procedure GuardarMetadatos(Conn: TFDConnection; const Tabla: string; const Clave: TClaveMeta; const Campos: TArray<TCampoMeta>; const Valores: TArray<TValorMeta>)` con `TClaveMeta = record IdEstructura: string; Id: Integer; CodSubs: string; Fecha: TDateTime; Version, Codigodoc: string; end` (INSERT con parámetros tipados por tipo; valor vacío = NULL; nombre de tabla y de columnas validados contra los reales de la tabla, nunca concatenados sin comprobar).
  - `TValorMeta` viene de `UCargaModelo` (Tarea 1).

- [ ] **Step 1: Write the failing tests**: `CrearEsquemaCarga` sobre SQL Server y Access agrega la columna y la tabla, una segunda llamada no falla (idempotente), `EsquemaCargaCompleto` da `True`; con una subserie de prueba sembrada (variables `Texto` de longitud 10, `Cantidad` entero obligatorio, `Fecha ref` fecha, `Nota` memo) `CargarCamposSubserie` devuelve los cuatro campos en orden con tipos correctos y `Obligatorio` leído de la columna; subserie sin variables devuelve arreglo vacío; `NombreTablaMeta` de una subserie sin tabla da `''`; `ValidarValorMeta`: obligatorio vacío → mensaje, texto de 11 caracteres con longitud 10 → mensaje, `'abc'` como entero → mensaje, `'12'` válido, `'1.5'` como real válido, `'31/02/2026'` fecha inválida, `'28/02/2026'` válida, vacío opcional válido; `GuardarMetadatos` inserta una fila en una tabla `md_*` de prueba creada por el test con `CreateTable` equivalente (columnas base + las cuatro) y la fila vuelve con los valores tipados; con un nombre de columna que no existe en la tabla lanza `EMetadatos` y no escribe; valores con apóstrofes (`O'Brien`) se guardan intactos.
- [ ] **Step 2: Run** compilar y exe. Expected: no compila (RED).
- [ ] **Step 3: Implement** ambas unidades; la tabla `md_*` de prueba se crea con SQL propio dentro de la transacción de la prueba (que se deshace) para no depender de `TUDM.CreateTableFromDefinitions`; el tipo sale del texto de `CL_SubseriesTipoVar.tipo` (`Caracteres`, `Memo`, `Fecha`, `Entero`, `Real`, `Boolean`).
- [ ] **Step 4: Run** compilar y exe, luego `scripts/compilar.ps1 ArchiGenioPro.dproj`. Expected: pruebas en verde y aplicación compilada.
- [ ] **Step 5: Commit** `F3: metadatos dinamicos de la subserie (campos, validacion por tipo y alta en la tabla md_*)`.

---

### Task 3: Guardar un documento (transacción, ficheros y compensación)

**Files:**
- Create: `UCargaDocumento.pas`
- Test: `Pruebas/UPruebasCargaDocumento.pas`

**Interfaces:**
- Consumes: `UCargaModelo`, `UMetadatosSubserie`, `IAlmacenFicheros`, `UAlcance` (`TAlcanceUsuario.PuedeRealizar(acAgregar, ...)`), `UTopografia` (`TopografiaCompleta`), `NombreSeguro`/`ClaveObjeto` no se usan.
- Produces:
  - `TOrigenDocumento = record IdEstructura: string; Id: Integer; CodSubs, CodSerie: string; Usuario, Rol: string; UrlRaiz: string; end` (`UrlRaiz` = `s3://<n>/`).
  - `TResultadoDocumento = record Guardado: Boolean; Codigodoc: string; Mensaje: string; Subidos: Integer; end`.
  - `function GuardarDocumento(Conn: TFDConnection; Alcance: TAlcanceUsuario; const Origen: TOrigenDocumento; Almacen: IAlmacenFicheros; const Cand: TCandidato; const Campos: TArray<TCampoMeta>; const TablaMeta: string; Progreso: TProgresoEvento): TResultadoDocumento`. Orden: (1) comprueba `acAgregar` y topografía del nodo y la subserie → si no, `Guardado=False` con el mensaje de siempre y sin tocar nada; (2) reserva `Codigodoc` único: si el pedido ya existe lo reemplaza por el siguiente libre, y reintenta una vez ante violación de clave; (3) sube cada fichero (archivo principal como anexo `fuente='N'`, cada fuente `fuente='S'`) con la clave `path + nombre`; (4) una transacción: `tb_SeriesDatos` (hereda `Archivo, deposito, gaveta, Idservidor, gestor` del nodo, `namefile = Codigodoc` seguro, `IDExpediente` y `subexp` vacíos), metadatos, filas de `tb_ssArchdigital` (`idhijo` = máximo + 1 dentro de la transacción), registro en `tb_log` (acción 5, el mismo texto que hoy); (5) si algo de (3) o (4) falla: rollback y borrado de lo ya subido; `Mensaje` en español sin rutas internas ni secretos.

- [ ] **Step 1: Write the failing tests** (fixture SQL Server con almacén en memoria `TAlmacenMemoria` de `UPruebasMigracion`, y la copia de Access con lo básico): guardar un candidato con dos archivos y una fuente deja un documento, 3 filas de `tb_ssArchdigital` con `fuente` `N`,`N`,`S`, `urlraiz = 's3://77/'`, el `path` esperado, la fila de metadatos y una línea en `tb_log`; los tres objetos están en el almacén bajo `path + nombre` sin `\`; usuario sin permiso de agregar → `Guardado=False`, nada en base ni en el almacén; topografía incompleta → igual; el almacén falla en el 2.º archivo → rollback, el 1.º se borra del almacén, `Guardado=False`, `Subidos=0`; el almacén falla al borrar la compensación → igual `Guardado=False` y el mensaje lo dice sin lanzar; código pedido ya existente → se guarda con el siguiente y `Codigodoc` lo informa; dos llamadas seguidas con el mismo código pedido dan dos documentos con códigos distintos; dos archivos con el mismo nombre en un mismo documento → dos filas, el segundo objeto con sufijo ` (2)` en `nombre` y en la clave; archivo de 0 bytes se guarda; nombre con `ñ`, espacio, `#` y `+` se guarda idéntico; obligatorio de metadatos vacío → `Guardado=False` antes de subir; metadatos con apóstrofe se guardan intactos; Access: el caso básico (documento + 1 archivo + metadatos).
- [ ] **Step 2: Run** compilar y exe. Expected: no compila (RED).
- [ ] **Step 3: Implement** `GuardarDocumento` con las firmas de Interfaces. `idhijo` y código se reservan dentro de la transacción; la unicidad de `Codigodoc` se confirma con un `SELECT COUNT(*)` en la misma transacción y un reintento ante `EFDDBEngineException` de clave duplicada.
- [ ] **Step 4: Run** compilar y exe. Expected: pruebas en verde.
- [ ] **Step 5: Commit** `F3: guardar un documento con sus ficheros y metadatos (transaccion, compensacion y codigo unico)`.

---

### Task 4: Lote, reintento y últimos valores

**Files:**
- Create: `UCargaLote.pas`
- Test: `Pruebas/UPruebasCargaLote.pas`

**Interfaces:**
- Consumes: `UCargaDocumento`, `UCargaModelo`, tablas `tb_lote_captura`, `tb_lote_captura_item`, `tb_carga_valores`.
- Produces:
  - `TCargaLote = class` con `constructor Create(Conn: TFDConnection; Alcance: TAlcanceUsuario; const Origen: TOrigenDocumento; Almacen: IAlmacenFicheros; const Campos: TArray<TCampoMeta>; const TablaMeta: string)`; `function Guardar(var Lote: TArray<TCandidato>; AlAvanzar: TProc<Integer, Integer, string>; Cancelar: TFunc<Boolean>): TResumenLote` (`Total, Guardados, Fallidos, Omitidos: Integer`; solo procesa candidatos en `ecListo` o `ecError`; deja `Estado`, `Codigo` y `Error` actualizados en cada uno; registra el lote y sus items); `function IdLote: Integer`.
  - `function LotesPendientes(Conn: TFDConnection; const Usuario: string): TArray<TLotePendiente>` (`TLotePendiente = record IdLote: Integer; Fecha: TDateTime; Origen, IdEstructura, CodSubs: string; Pendientes: Integer; end`) y `function CargarItems(Conn: TFDConnection; IdLote: Integer): TArray<TItemLote>` para retomar.
  - `procedure GuardarUltimosValores(Conn: TFDConnection; const Usuario, CodSubs: string; const Valores: TArray<TValorMeta>)` y `function LeerUltimosValores(Conn: TFDConnection; const Usuario, CodSubs: string): TArray<TValorMeta>` (sobre `tb_carga_valores`; reemplaza, no acumula).

- [ ] **Step 1: Write the failing tests** (almacén en memoria, SQL Server y un caso de Access): un lote de 4 candidatos con uno que falla en la subida guarda 3, `Fallidos=1`, ese candidato queda `ecError` con mensaje, el lote queda `estado` abierto con el item `error`; reintentar `Guardar` sobre el mismo arreglo guarda solo el fallido (los `ecGuardado` no se tocan) y cierra el lote; cancelar tras 2 documentos deja `Omitidos` correctos y el lote pendiente; `LotesPendientes` lista el lote con su número de pendientes y `CargarItems` devuelve el estado de cada archivo; un candidato en `ecFalta` se omite (no se sube); `GuardarUltimosValores` dos veces con distintos valores deja solo los últimos; los valores de un usuario no aparecen para otro; ninguna fila de otro usuario cambia al guardar.
- [ ] **Step 2: Run** compilar y exe. Expected: no compila (RED).
- [ ] **Step 3: Implement** `UCargaLote.pas`; cada documento usa `GuardarDocumento` (una transacción por documento, nunca una para todo el lote); los códigos del lote se piden con `CodigosParaLote` al empezar y se revalidan en `GuardarDocumento`.
- [ ] **Step 4: Run** compilar y exe. Expected: pruebas en verde.
- [ ] **Step 5: Commit** `F3: lote de carga reintentable y ultimos valores por usuario y subserie`.

---

### Task 5: Pantalla «Agregar documentos» (datos comunes y soltar archivos)

**Files:**
- Create: `UPantallaCarga.pas`
- Modify: `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: `UCargaModelo`, `UCargaLote`, `UTema`, `UIconos`, `UMetadatosSubserie` (Tarea 6 completa la tarjeta propia).
- Produces: `function MostrarCargaDocumentos(const Origen: TOrigenDocumento; const Subserie: string; Conn: TFDConnection; Alcance: TAlcanceUsuario; Almacen: IAlmacenFicheros): Boolean` (modal; `True` si se guardó algo). Pantalla construida por código: izquierda, lista virtual (`TListView` con `OwnerData`, un solo control para cualquier cantidad) de candidatos con icono y texto de estado («En espera», «Falta un dato», «Listo», «Subiendo», «Guardado», «Error»); zona para soltar archivos y carpetas (`WM_DROPFILES`, recursivo, sin duplicar rutas) más botón «Elegir archivos...»; derecha, tarjeta de datos comunes (título, código, fecha, acceso, ¿es expediente?) y botón «Aplicar a todos»; pie con «Guardar todos», progreso y «Cancelar». Modos Rápido y Guiado como la misma pantalla con las tarjetas visibles por pasos (1 Archivos, 2 Datos, 3 Revisar) o todas a la vez; el modo se recuerda por usuario. Los textos de pantalla y la apariencia salen de `UTema`.

- [ ] **Step 1: Write the failing test** de lo único automatizable: en `UCargaModelo` agregar y probar `function ExpandirRutas(const Rutas: TArray<string>; Recursivo: Boolean): TArray<string>` (archivos de las carpetas y de las rutas sueltas, sin duplicados, sin ocultos ni temporales `~$*`, ordenados) sobre una carpeta temporal con subcarpetas y un duplicado. Run: falla por función inexistente (RED).
- [ ] **Step 2: Implement** `ExpandirRutas` y verificar GREEN; después construir `UPantallaCarga.pas` según la descripción. La pantalla no tiene prueba automática: va a la lista de verificación (Tarea 8).
- [ ] **Step 3: Run** compilar y exe de pruebas y `scripts/compilar.ps1 ArchiGenioPro.dproj`. Expected: pruebas en verde y aplicación compilada.
- [ ] **Step 4: Verificación visual** con el método de capturas por proceso (`snap.ps1`, `PrintWindow` con DPI consciente; nunca el escritorio completo) con una subserie de prueba y 3 archivos: sin solapes a 1366x768 al 125 %.
- [ ] **Step 5: Commit** `F3: pantalla Agregar documentos (lista de candidatos, soltar archivos y datos comunes)`.

---

### Task 6: Tarjeta de datos propios generada en tiempo de ejecución y modo Guiado

**Files:**
- Modify: `UPantallaCarga.pas`
- Test: `Pruebas/UPruebasCargaModelo.pas` (mapeo de campos a controles)

**Interfaces:**
- Consumes: `CargarCamposSubserie`, `ValidarValorMeta`, `UCargaModelo`.
- Produces: en `UCargaModelo`, `TControlMeta = (cmEdit, cmMemo, cmFecha, cmNumero, cmSiNo)` y `function ControlParaCampo(Tipo: TTipoMeta; Longitud: Integer): TControlMeta` (texto de hasta 255 → `cmEdit`; `Memo` o `Longitud` > 255 o 0 → `cmMemo`; `Fecha` → `cmFecha`; `Entero` y `Real` → `cmNumero`; `Boolean` → `cmSiNo`). En la pantalla: la tarjeta «Datos de la subserie» se crea al abrir a partir de los campos (etiqueta, control del tipo, asterisco si es obligatorio, orden de `Orden`), no existe si la subserie no tiene tabla de metadatos o variables, y cada valor se guarda en `Meta` del candidato seleccionado; «Aplicar a todos» ofrece también los campos propios; un candidato no pasa a `ecListo` con un obligatorio vacío o inválido (mensaje bajo el campo); «Repetir los últimos valores» usa `LeerUltimosValores`. El modo Guiado muestra por pasos primero lo común y luego lo de cada documento y termina en Revisar (tabla resumen con errores marcados).

- [ ] **Step 1: Write the failing tests** de `ControlParaCampo` con los casos de Interfaces (incluye `Longitud=255` y `256`) en `Pruebas/UPruebasCargaModelo.pas`. Run: falla (RED).
- [ ] **Step 2: Implement** `ControlParaCampo` (GREEN) y la tarjeta dinámica en `UPantallaCarga.pas` sin ningún nombre de campo escrito en el código; sin tabla de metadatos, la tarjeta no se crea.
- [ ] **Step 3: Run** compilar y exe de pruebas y de la aplicación. Expected: verde y compilada.
- [ ] **Step 4: Verificación visual** con dos subseries de prueba (una con tabla de metadatos de 4 variables de tipos distintos, otra sin tabla): la primera muestra los 4 campos con el control correcto y obligatorios marcados, la segunda no muestra la tarjeta.
- [ ] **Step 5: Commit** `F3: tarjeta de datos propios de la subserie en tiempo de ejecucion y modo Guiado`.

---

### Task 7: Integración en el shell, ficheros fuente y resultado

**Files:**
- Modify: `UShellPrincipal.pas`, `UMAINFORM.pas` (`ShellAgregarDocumento` y el botón «Agregar documento» de la pantalla de inicio), `UCapaDatos.pas` (`UDM.Almacen` si hace falta una función de apoyo), `ArchiGenioPro.dpr`
- Modify: `UPantallaCarga.pas` (fuentes y resumen final)

**Interfaces:**
- Consumes: `MostrarCargaDocumentos`, `CrearAlmacen`, `ServidorDestinoNuevos`, `UDM.UrlRaizNuevos`, `UDM.Alcance`, `UDM.tb_Serietree`, `UDM.SudSDetail`.
- Produces: `ShellAgregarDocumento` abre la pantalla nueva con el nodo y la subserie elegidos; si no hay subserie en el nodo, o falta el permiso de agregar, o la topografía está incompleta, o no hay servidor S3, muestra el mensaje de siempre (o «Registre primero un servidor S3 en Clasificadores > Servidores» con un botón que abre el clasificador) y no abre nada; al cerrar con documentos guardados refresca la lista de documentos de la subserie y los datasets del maestro-detalle. Con `shell_clasico.flag` el comportamiento de hoy (rejilla) no cambia. Los ficheros fuente se arrastran sobre la fila del candidato (o se eligen con un botón «Agregar fuente...») y se guardan con `fuente='S'`. Al terminar un lote se muestra el resumen (guardados, fallidos con motivo, «Reintentar los que fallaron»). La rejilla sigue disponible con «Ver rejilla» para editar y borrar.

- [ ] **Step 1: Write the failing test** de lo automatizable: función pura en `UCargaModelo` `function ResumenLote(Guardados, Fallidos, Omitidos: Integer): string` con los textos en español para 0/1/N en cada caso («Se guardaron 3 documentos.», «No se guardo ningun documento.», «Se guardo 1 documento y 2 no se pudieron guardar.») y el caso de cancelación. Run: falla (RED).
- [ ] **Step 2: Implement** `ResumenLote` (GREEN) y el cableado descrito; el cableado de `UMAINFORM.pas` va por script de bytes y se confirma solo con los hunks propios.
- [ ] **Step 3: Run** compilar y exe de pruebas y de la aplicación. Expected: verde y compilada.
- [ ] **Step 4: Verificación visual** del recorrido completo con un administrador sobre `SGDTEST_ALCANCE` y el MinIO de pruebas: soltar 3 archivos, completar, guardar, ver los documentos en la lista y sus ficheros abiertos desde S3.
- [ ] **Step 5: Commit** `F3: Agregar documentos desde el shell, ficheros fuente y resumen del lote`.

---

### Task 8: Lista de verificación manual y estado en el diseño

**Files:**
- Create: `docs/superpowers/plans/2026-11-05-verificacion-f3.md`
- Modify: `docs/superpowers/specs/2026-11-05-documentos-carga-consulta-geo-trazabilidad-design.md` (estado de la F3 en la tabla de fases)

**Interfaces:**
- Consumes: todo lo anterior.
- Produces: la lista con casos para: soltar varios archivos y una carpeta; elegir archivos; modo Rápido y Guiado; datos comunes y «Aplicar a todos»; repetir últimos valores; subserie con y sin metadatos; obligatorio vacío; tipos inválidos; ficheros fuente; cancelar a mitad; fallo de red a mitad y reintento (apagar MinIO); retomar un lote pendiente; dos usuarios cargando a la vez en la misma subserie; usuario sin permiso de agregar; topografía incompleta; sin servidor S3; 300 archivos; modo Access; 1366x768 al 125 %; tema oscuro; `shell_clasico.flag`.

- [ ] **Step 1: Write** la lista (tabla `# | Usuario/entorno | Qué hacer | Resultado esperado | Registrado`, como `2026-11-05-verificacion-f4.md`) y la nota de lo que no cubren las pruebas automáticas.
- [ ] **Step 2: Run** la suite completa. Expected: todo en verde (total anterior más las pruebas nuevas).
- [ ] **Step 3: Commit** `F3: lista de verificacion manual y estado de la fase en el diseno`.
