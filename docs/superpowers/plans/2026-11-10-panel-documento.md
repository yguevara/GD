# Panel del documento Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sustituir las propiedades junto a la tabla por un panel con pestanas (Datos, Ubicacion, Archivos, Metadatos, Historia, Contenido) y mostrar el PDF del documento incrustado y separable.

**Architecture:** `TPanelDocumento` (por codigo) compone la tira de pestanas de `UPanelLateral` con una pagina por pestana; cada pagina muestra datos que TMAIN le entrega por eventos (como ya hacen `OnPedirFicheros` y `OnPedirHistoria`). La logica de que va en cada pestana y los tramos de ubicacion es pura (`UDocumentoVista`). El contenido usa `TdxPDFViewer` y se separa moviendolo a otra ventana.

**Tech Stack:** Delphi 10.3 VCL, ExpressPDFViewer (DevExpress), DUnitX, UTema.

**Spec:** `docs/superpowers/specs/2026-11-10-panel-documento-design.md`

## Global Constraints

- Compilar con `powershell -File scripts/compilar.ps1 ArchiGenioPro.dproj` y `Pruebas/PruebasArchiGenio.dproj`; exe de pruebas con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` (copia fresca de `BD/SDbd.mdb`).
- No se edita el .dfm binario de UMAINFORM; `UMAINFORM.pas` solo con `ed2.py` (`edit2`). Las ediciones con acentos se escriben con los caracteres reales (no con U+FFFD).
- Unidades nuevas en ASCII y CRLF; documentacion en espanol (cabecera de unidad y comentario por rutina publica).
- Contenido incrustado: solo PDF. Cada visualizacion registra `ACCION_VISUALIZAR` (`UDM.LogDocActual`) una vez por documento y sesion de pestana.
- Sin `shell_clasico.flag` y con la barra de trabajo, el panel nuevo; el comportamiento clasico no cambia.
- El modo Editar (rejilla y su navegador) no se toca.
- Cada tarea termina con pruebas verdes; las visuales, con captura del usuario. Commit al cerrar cada tarea (el usuario ya pidio que se completen los commits).

## Review Focus

1. Contenido de un documento sin PDF o con fichero ausente en el almacen: mensaje claro, sin excepcion, sin archivo temporal huerfano (Task 5).
2. Cambiar de documento con el Contenido abierto o separado: el visor se actualiza o avisa, y la ventana separada no queda mostrando otro documento sin decirlo (Task 5).
3. Permisos: quien no puede guardar o imprimir no ve esos botones del visor incrustado (Task 5, revisar `PDFExpressViewer.exe` para igualar su comportamiento).
4. Documento sin ubicacion o subserie sin topografia: se muestra "Sin ubicacion asignada" por tramo, no un hueco (Task 2).
5. Anexos de un documento con muchos ficheros: la lista se desplaza y no bloquea la interfaz (Task 3).

---

### Task 1: Pestanas del panel del documento

**Files:**
- Create: `UPanelDocumento.pas` (ASCII), registrar en `ArchiGenioPro.dpr`
- Modify: `UDocumentoVista.pas` (grupos por pestana), `UPanelDocumentos.pas` (usa el panel nuevo en lugar de `FProp` y `FPie`)
- Test: `Pruebas/UPruebasDocumentoVista.pas`, `Pruebas/UPruebasPanelDocumento.pas` (nuevo, registrar en `PruebasArchiGenio.dpr`), `Pruebas/UPruebasPanelDocumentos.pas`

**Interfaces:**
- Produces (UDocumentoVista): `TPestanaDoc = (pdDatos, pdUbicacion, pdArchivos, pdMetadatos, pdHistoria, pdContenido)`; `function PropiedadesDePestana(const Props: TArray<TPropiedad>; P: TPestanaDoc): TArray<TPropiedad>` (Datos = grupos "General" y "Expediente"; Archivos = "Ficheros"; el resto devuelve vacio: esas pestanas se arman aparte).
- Produces (UPanelDocumento): `TPanelDocumento = class(TPanel)` con `function Pagina(P: TPestanaDoc): TPanel`; `procedure Activar(P: TPestanaDoc)`; `property Activa: TPestanaDoc`; `procedure FijarCabecera(const Codigo, Titulo: string; Estado: TEstadoDoc)`; `property OnCambioPestana: TNotifyEvent`. Reutiliza `TTiraPestanas` (UPanelLateral).

- [ ] **Step 1: Write the failing tests**: `PropiedadesDePestana_Datos_SoloGeneralYExpediente`; `PropiedadesDePestana_Archivos_SoloFicheros`; `PropiedadesDePestana_Metadatos_Vacio`; `Panel_SeisPaginas_SoloLaActivaEsVisible`; `Panel_FijarCabecera_MuestraCodigoTituloYEstado`; y en `UPruebasPanelDocumentos` `Seleccion_MuestraDatosEnLaPestanaDatos` (la pestana Datos contiene "GENERAL" y el titulo del documento).
- [ ] **Step 2: Run** compilar + exe. Expected: no compila (simbolos inexistentes).
- [ ] **Step 3: Implement** `PropiedadesDePestana`, `TPanelDocumento` y su uso en `TPanelDocumentos` (la pestana Datos usa `TListaPropiedades`; los botones "Abrir contenido" y "Obtener expediente completo" pasan a la pestana Archivos).
- [ ] **Step 4: Run** pruebas y compilar `ArchiGenioPro.dproj`. Expected: 0 fallos, 0 errores.
- [ ] **Step 5: Verificacion del usuario** con captura del panel nuevo.
- [ ] **Step 6: Commit.**

### Task 2: Ubicacion (subserie y documento)

**Files:**
- Modify: `UDocumentoVista.pas`, `UPanelDocumento.pas`, `UPanelDocumentos.pas`, `UMAINFORM.pas`
- Test: `Pruebas/UPruebasDocumentoVista.pas`, `Pruebas/UPruebasPanelDocumento.pas`

**Interfaces:**
- Produces (UDocumentoVista): `TTramoUbicacion = record Rotulo, Valor: string; end`; `TUbicacion = record Titulo: string; Tramos: TArray<TTramoUbicacion>; Completa: Boolean; end`; `function UbicacionDeDocumento(const D: TDatosDocumento): TUbicacion` (tramos Servidor, Archivo, Deposito, Gaveta, Posicion; los vacios o "0" salen como `'Sin asignar'`, `Completa` solo si todos tienen valor); `function UbicacionDeSubserie(const Servidor, Archivo, Deposito, Gaveta: string): TUbicacion` (sin posicion).
- Produces (UPanelDocumentos): `property OnPedirUbicacionSubserie: TSolicitudUbicacion` donde `TSolicitudUbicacion = function: TUbicacion of object`.
- Produces (UMAINFORM): `ListaDocsUbicacionSubserie: TUbicacion` (lee `UDM.tb_Serietree`: `idservidor`, `Archivo`, `deposito`, `gaveta`).

- [ ] **Step 1: Write the failing tests**: `UbicacionDeDocumento_Completa`; `UbicacionDeDocumento_ConCeroOVacio_DiceSinAsignar` (Archivo '0' y Gaveta '' -> 'Sin asignar', `Completa = False`); `UbicacionDeSubserie_SinPosicion`; `Panel_PestanaUbicacion_MuestraDosBloques` (VCL: titulos "Subserie" y "Documento" presentes).
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** las funciones puras, el control de la pestana (cada tramo como pastilla separada por flechas, los "Sin asignar" en color de aviso) y el evento en TMAIN.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos, 0 errores.
- [ ] **Step 5: Commit.**

### Task 3: Archivos (consulta de anexos y fuentes)

**Files:**
- Modify: `UDocumentoVista.pas` (si falta distinguir), `UPanelDocumento.pas`, `UPanelDocumentos.pas`
- Test: `Pruebas/UPruebasDocumentoVista.pas`, `Pruebas/UPruebasPanelDocumento.pas`

**Interfaces:**
- Consumes: `TFicheroDoc` y `OnPedirFicheros` (ya existentes; `EsFuente` separa fuentes de anexos).
- Produces (UDocumentoVista): `function AgruparFicheros(const F: TArray<TFicheroDoc>): TArray<TGrupoFicheros>` con `TGrupoFicheros = record Titulo: string; Ficheros: TArray<TFicheroDoc>; end` (grupos "Anexos digitales" y "Fuentes", solo los no vacios; ordenados por nombre).
- Produces (UPanelDocumento): la pestana Archivos muestra los grupos con extension, nombre y tamano (`FormatoTamano`), un contador en la pestana (`Archivos 3`), y "Sin ficheros" si no hay; es solo de consulta (sin acciones de edicion).

- [ ] **Step 1: Write the failing tests**: `AgruparFicheros_SeparaAnexosYFuentes`; `AgruparFicheros_SinFicheros_Vacio`; `Panel_PestanaArchivos_ContadorYLista` (VCL con 3 ficheros: la pestana dice 3 y la lista muestra los tres nombres); `Panel_PestanaArchivos_MuchosFicheros_SeDesplaza` (200 ficheros: la altura de contenido supera la del panel y existe barra).
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** `AgruparFicheros` y la pagina (lista dibujada por un control propio con desplazamiento, como `TListaPropiedades`).
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos.
- [ ] **Step 5: Commit.**

### Task 4: Metadatos del documento

**Files:**
- Modify: `UPanelDocumento.pas`, `UPanelDocumentos.pas`, `UMAINFORM.pas`
- Test: `Pruebas/UPruebasPanelDocumento.pas`

**Interfaces:**
- Produces (UPanelDocumentos): `property OnPedirMetadatos: TSolicitudMetadatos` donde `TSolicitudMetadatos = function(const Clave: TClaveDocumento): TArray<TPropiedad> of object` (Grupo = nombre de la subserie, Etiqueta = etiqueta de la variable, Valor = valor o `''`).
- Produces (UMAINFORM): `ListaDocsMetadatos(const Clave): TArray<TPropiedad>` (localiza el documento y lee la fila actual de `md_var` con las etiquetas de `md_def`; si la subserie no tiene variables devuelve `nil`).
- Produces (UPanelDocumento): pestana Metadatos con `TListaPropiedades`; sin variables dice "Esta subserie no define metadatos"; valores vacios como un guion.

- [ ] **Step 1: Write the failing tests**: `Metadatos_SinVariables_DiceQueNoDefine`; `Metadatos_ValorVacio_MuestraGuion`; `Metadatos_ConValores_MuestraEtiquetasYValores`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** el control de la pestana y `ListaDocsMetadatos`, cacheando por subserie lo que no cambia con el documento (como ya se hace con `EscalarCache`).
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos.
- [ ] **Step 5: Verificacion del usuario** con captura de las pestanas Ubicacion, Archivos y Metadatos de un documento con datos.
- [ ] **Step 6: Commit.**

### Task 5: Contenido incrustado y separable

**Files:**
- Create: `UVisorContenido.pas` (ASCII; contiene `TVisorContenido`)
- Modify: `UPanelDocumento.pas`, `UPanelDocumentos.pas`, `UMAINFORM.pas`, `ArchiGenioPro.dpr`
- Test: `Pruebas/UPruebasVisorContenido.pas` (nuevo, registrar en `PruebasArchiGenio.dpr`)

**Interfaces:**
- Produces: `TVisorContenido = class(TPanel)` con `procedure Mostrar(const ArchivoPdf: string)`; `procedure MostrarMensaje(const Texto: string)`; `procedure Limpiar`; `procedure Separar` (mueve el visor a un `TForm` propio con titulo del documento y boton "Volver a la aplicacion"); `procedure Reincorporar`; `property Separado: Boolean`; `property PuedeGuardar, PuedeImprimir: Boolean` (ocultan esos botones del visor).
- Produces (UPanelDocumentos): `property OnPedirContenido: TSolicitudContenido` donde `TSolicitudContenido = function(const Clave: TClaveDocumento; out Motivo: string): string of object` (devuelve la ruta local del PDF o `''` y el motivo).
- Produces (UMAINFORM): `ListaDocsContenido(const Clave; out Motivo): string` (busca el fichero PDF principal del documento, lo descarga con `IAlmacenFicheros.Descargar` a una carpeta temporal por sesion, registra `UDM.LogDocActual(... ACCION_VISUALIZAR)` y devuelve la ruta; extensiones que no son `.pdf` devuelven `''` con el motivo "El contenido incrustado solo admite PDF; use Abrir en Archivos"); los temporales se borran en `TMAIN.FormDestroy`.

- [ ] **Step 1: Research** (sin codigo de producto): leer `PDFExpressViewer.exe` no es posible (binario): comprobar con el usuario que permisos aplica (guardar, imprimir, copiar) y por que rol; anotar la respuesta en el ledger y en la pestana. Sin esta respuesta `PuedeGuardar` y `PuedeImprimir` quedan en `False` para todos.
- [ ] **Step 2: Write the failing tests**: `Visor_SinArchivo_MuestraElMensaje`; `Visor_SepararYReincorporar_ConservaElVisorYElEstado` (el visor cambia de padre y vuelve; `Separado` refleja el estado); `Visor_Limpiar_BorraElDocumento`; `Visor_NoPDF_DiceSoloPDF` (via el evento del panel con extension `.docx`).
- [ ] **Step 3: Run.** Expected: FAIL.
- [ ] **Step 4: Implement** `TVisorContenido` sobre `TdxPDFViewer`, la descarga bajo demanda (solo al abrir la pestana) con cache por documento y el borrado de temporales. Con el contenido separado, un cambio de documento actualiza la ventana separada y el titulo.
- [ ] **Step 5: Run** pruebas y compilar. Expected: 0 fallos, 0 errores.
- [ ] **Step 6: Verificacion del usuario**: abrir la pestana Contenido de un documento con PDF, separarla y volver; un documento sin PDF; un `.docx`. Captura.
- [ ] **Step 7: Commit.**

### Task 6: Limpieza del panel antiguo, verificacion y estado

**Files:**
- Modify: `UPanelDocumentos.pas` (quitar `FDer`/`FPie` obsoletos si quedaron), `UMAINFORM.pas`, `docs/superpowers/plans/2026-11-10-verificacion-espacio-de-trabajo.md`, el diseno (estado)

- [ ] **Step 1:** Quitar lo que Task 1 dejo sin uso, compilar y correr toda la suite (Access y SQL Server).
- [ ] **Step 2:** Anadir a la lista de verificacion los casos de las seis pestanas, el contenido separado, el documento sin PDF, la ubicacion de subserie y de documento, y los permisos del visor.
- [ ] **Step 3: Review final** con un revisor independiente sobre `git diff` desde el inicio de este plan; una pasada de correcciones con pruebas.
- [ ] **Step 4: Commit.**

## Fuera de este plan

Rediseno del modo Editar con arrastrar y soltar (proyecto 2); expedientes y documentos georreferenciados (proyecto 3); formatos de contenido incrustado distintos de PDF.
