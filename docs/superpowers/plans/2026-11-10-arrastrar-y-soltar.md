# Arrastrar y soltar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Soltar archivos desde el Explorador para dar de alta documentos por lotes (lista), anadir anexos o fuentes a un documento (pestana Archivos) y poner o reemplazar su contenido PDF (pestana Contenido).

**Architecture:** Un receptor OLE (`IDropTarget`) por control avisa de entrada, salida y soltado. Las tres acciones se apoyan en logica sin VCL: la carga existente (`UCargaLote`) para altas, y una unidad nueva `UAgregarFicheros` para anadir o reemplazar ficheros de un documento ya creado. TMAIN solo conecta permisos, almacen y refresco.

**Tech Stack:** Delphi 10.3 VCL, `Winapi.ActiveX`, FireDAC, DUnitX (almacen en memoria de `UPruebasMigracion`).

**Spec:** `docs/superpowers/specs/2026-11-10-arrastrar-y-soltar-design.md`

## Global Constraints

- Compilar con `powershell -File scripts/compilar.ps1 ArchiGenioPro.dproj` y `Pruebas/PruebasArchiGenio.dproj`; exe de pruebas con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` (copia fresca de `BD/SDbd.mdb`).
- Todo SQL vale en SQL Server y Access. Logica de guardado sin VCL ni `UDM`.
- `UMAINFORM.pas` solo con `ed2.py` (`edit2`; acentos con caracteres reales). Scripts Python con `Write` a un archivo, no con heredoc con comillas triples.
- Unidades nuevas en ASCII y CRLF; documentacion en espanol.
- Cada alta, anexo o reemplazo escribe bitacora con `UTrazabilidadDatos` y respeta `UAlcance` (`acAgregar` para altas, `acEditar` para anexos y contenido).
- Nada se guarda a medias: si un archivo falla, se borra lo subido y las filas de ese archivo.
- No tocar la rejilla del modo Editar ni el visor de contenido salvo recibir el soltado.
- Commit al cerrar cada tarea; las visuales terminan con captura del usuario.

## Review Focus

1. Soltar una carpeta enorme o un archivo de cero bytes o sin extension: la carga no se cuelga y dice que omitio (Task 2).
2. Reemplazar contenido y que falle la subida: el PDF anterior sigue intacto, en el almacen y en la tabla (Task 5).
3. Soltar sin permiso o en un nodo sin subserie: aviso claro y no se abre ni guarda nada (Tasks 2, 4, 5).
4. Dos archivos con el mismo nombre en un mismo soltado: nombres unicos por carpeta, sin pisarse (Task 3).
5. Soltar archivos de otra aplicacion o texto (no son archivos): se ignora sin error (Task 1).

---

### Task 1: Receptor de arrastre

**Files:**
- Create: `URecepcionArchivos.pas` (ASCII), registrar en `ArchiGenioPro.dpr`
- Create: `Pruebas/UPruebasRecepcionArchivos.pas`; registrar en `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Produces: `TRecepcionArchivos = class(TComponent)` con `constructor Crear(AOwner: TComponent; Control: TWinControl)`; `property OnEntrar: TNotifyEvent`, `property OnSalir: TNotifyEvent`, `property OnSoltar: TSoltarEvent` donde `TSoltarEvent = procedure(const Rutas: TArray<string>) of object`; `property Activo: Boolean` (si es False ignora todo); `procedure SimularSoltar(const Rutas: TArray<string>)` (misma ruta de codigo que un soltado real, para pruebas).
- Produces (funcion pura): `function FiltrarRutas(const Rutas: TArray<string>; const Extensiones: TArray<string>; out Rechazadas: TArray<string>): TArray<string>` (sin extensiones pedidas acepta todas; las extensiones sin punto y en minusculas; las que no existen van a `Rechazadas`).

- [ ] **Step 1: Write the failing tests**: `FiltrarRutas_SoloPdf_AceptaPdfYRechazaElResto`; `FiltrarRutas_SinExtensiones_AceptaLasQueExisten`; `FiltrarRutas_NoExiste_VaARechazadas`; `SimularSoltar_ConActivoFalso_NoAvisa`; `SimularSoltar_Activo_AvisaConLasRutas`; `SimularSoltar_SinRutas_NoAvisa`.
- [ ] **Step 2: Run** compilar + exe. Expected: no compila.
- [ ] **Step 3: Implement** el componente con `RegisterDragDrop`/`RevokeDragDrop` y `IDropTarget` (`DragEnter` acepta solo `CF_HDROP`, `DragLeave`, `Drop` lee las rutas con `DragQueryFile`) y `FiltrarRutas`; `OleInitialize` una vez.
- [ ] **Step 4: Run** pruebas. Expected: 0 fallos.
- [ ] **Step 5: Commit.**

### Task 2: Soltar sobre la lista abre la carga por lote

**Files:**
- Modify: `UPantallaCarga.pas` (parametro `Rutas`), `UPanelDocumentos.pas` (receptor en la lista, evento), `UMAINFORM.pas`
- Test: `Pruebas/UPruebasPanelDocumentos.pas`, `Pruebas/UPruebasCargaModelo.pas`

**Interfaces:**
- Consumes: `TRecepcionArchivos` (Task 1), `MostrarCargaDocumentos` y `ShellAgregarDocumento` existentes, `ExpandirRutas` (UCargaModelo).
- Produces: `MostrarCargaDocumentos(const Origen; const Subserie; Conn; Alcance; Almacen; const RutasIniciales: TArray<string> = nil): Boolean` (si hay rutas iniciales las expande y las agrega como candidatos al abrir); `TPanelDocumentos.OnSoltarArchivos: TSoltarEvent` (se dispara con las rutas soltadas sobre la lista; con `Activo = False` o sin lista no hace nada); `TMAIN.ListaDocsSoltar(const Rutas: TArray<string>)` (comprueba el mismo permiso que `ShellAgregarDocumento` y abre la carga con las rutas).

- [ ] **Step 1: Write the failing tests**: `Panel_SoltarSobreLaLista_DisparaOnSoltarArchivos` (con `SimularSoltar`); `Panel_SinSubserie_NoDisparaElEvento`; `ExpandirRutas_CarpetaConArchivosIgnorables_OmiteLosIgnorables` (si falta en `UPruebasCargaModelo`).
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** el parametro y el evento; en TMAIN, `ListaDocsSoltar` reutiliza la validacion de `ShellAgregarDocumento` (permiso, topografia completa, servidor S3) antes de abrir la carga.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos.
- [ ] **Step 5: Verificacion del usuario**: soltar 3 archivos y una carpeta sobre la lista; ver los candidatos con titulo y codigos propuestos. Captura.
- [ ] **Step 6: Commit.**

### Task 3: Anadir ficheros a un documento (logica)

**Files:**
- Create: `UAgregarFicheros.pas` (ASCII, sin VCL ni UDM), registrar en `ArchiGenioPro.dpr`
- Create: `Pruebas/UPruebasAgregarFicheros.pas`; registrar en `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Consumes: `IAlmacenFicheros`, `TOrigenDocumento`, `TClaveDocumento`, `UAlcance`, el patron de `UCargaDocumento` (nombre unico por carpeta, `ClaveObjeto`, filas de `tb_ssArchdigital`, bitacora).
- Produces: `TFicheroNuevo = record Local: string; EsFuente: Boolean; end`; `TResultadoFicheros = record Agregados, Fallidos: Integer; Mensaje: string; end`; `function AgregarFicheros(Conn: TFDConnection; Alcance: TAlcanceUsuario; const Clave: TClaveDocumento; const UrlRaiz: string; Almacen: IAlmacenFicheros; const Ficheros: TArray<TFicheroNuevo>; Progreso: TProgresoEvento): TResultadoFicheros` (un archivo a la vez: sube, inserta fila y bitacora; si falla, borra lo subido de ese archivo y sigue con el siguiente; sin permiso `acEditar` no hace nada y `Mensaje` lo dice; nombres unicos dentro del soltado y frente a los existentes de la carpeta del documento).

- [ ] **Step 1: Write the failing tests** con `TAlmacenMemoria`: `Agrega_Anexo_SubeInsertaYRegistra`; `Agrega_Fuente_VaALaCarpetaFuentesConFuenteS`; `NombresRepetidos_QuedanUnicos`; `FallaLaSubida_NoDejaFilaNiObjeto` (almacen que lanza en el segundo archivo: el primero queda, el segundo no deja nada); `SinPermiso_NoHaceNada` (alcance que niega `acEditar`); `ArchivoInexistente_CuentaComoFallido`. Access (`ARCHIGENIO_TEST_MDB`) y SQL Server (`ARCHIGENIO_TEST_DB`) con datos sembrados que se borran al final.
- [ ] **Step 2: Run.** Expected: no compila.
- [ ] **Step 3: Implement** `AgregarFicheros` reutilizando los patrones de `UCargaDocumento` (extraer a funciones compartidas solo si lo pide la duplicacion).
- [ ] **Step 4: Run** pruebas. Expected: 0 fallos en ambos motores.
- [ ] **Step 5: Commit.**

### Task 4: Pestana Archivos con zonas de soltar

**Files:**
- Modify: `UPanelDocumentos.pas`, `UPanelDocumento.pas` (zonas), `UMAINFORM.pas`
- Test: `Pruebas/UPruebasPanelDocumento.pas`, `Pruebas/UPruebasPanelDocumentos.pas`

**Interfaces:**
- Consumes: `TRecepcionArchivos`, `AgregarFicheros` (Task 3).
- Produces: `TPanelDocumento.MostrarZonasSoltar(Mostrar: Boolean)` (dos zonas sobre la pagina Archivos: "Soltar como anexo digital" y "Soltar como fuente"; cada una con su `TRecepcionArchivos`); `TPanelDocumentos.OnSoltarFicheros: procedure(const Clave: TClaveDocumento; const Ficheros: TArray<TFicheroNuevo>) of object`; `TMAIN.ListaDocsAgregarFicheros(...)` (permiso, almacen por defecto, barra de progreso, resumen "Se agregaron N archivos; M fallaron", refresco de `qryAnexosDig` y de la pestana Archivos).

- [ ] **Step 1: Write the failing tests**: `Zonas_VisiblesSoloAlArrastrar` (`MostrarZonasSoltar`); `Soltar_EnZonaAnexo_DisparaElEventoConEsFuenteFalso`; `Soltar_EnZonaFuente_DisparaElEventoConEsFuenteVerdadero`; `SinDocumentoElegido_NoHayZonas`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** zonas y conexion en TMAIN.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos.
- [ ] **Step 5: Verificacion del usuario**: arrastrar 2 archivos sobre un documento a cada zona; ver el contador y la lista de Archivos actualizados. Captura.
- [ ] **Step 6: Commit.**

### Task 5: Contenido por arrastre (poner o reemplazar el PDF)

**Files:**
- Modify: `UAgregarFicheros.pas`, `UPanelDocumentos.pas`, `UVisorContenido.pas`, `UMAINFORM.pas`
- Test: `Pruebas/UPruebasAgregarFicheros.pas`, `Pruebas/UPruebasVisorContenido.pas`

**Interfaces:**
- Produces (UAgregarFicheros): `function ReemplazarContenido(Conn; Alcance; const Clave; const UrlRaiz; Almacen; const PdfNuevo: string; Progreso): TResultadoFicheros` (comprueba que es PDF; sube el nuevo primero; en una transaccion borra la fila del PDF anterior e inserta la del nuevo; solo despues borra el objeto anterior del almacen; si algo falla antes de ese ultimo paso, borra el nuevo y deja el anterior intacto; sin PDF anterior equivale a agregar un anexo).
- Produces (UPanelDocumentos): `OnSoltarContenido: procedure(const Clave: TClaveDocumento; const Pdf: string; HayContenido: Boolean; out Confirmado: Boolean) of object`; el visor muestra "Soltar el PDF aqui" al arrastrar y rechaza lo que no sea PDF con un mensaje.
- Produces (TMAIN): confirmacion "Reemplazar el contenido actual?" solo si ya hay PDF; al terminar, descarta la cache de contenido de ese documento (`FContenidoCache`) y recarga el visor.

- [ ] **Step 1: Write the failing tests**: `Reemplaza_SubeElNuevoYBorraElAnterior`; `FallaLaSubida_ElAnteriorSigueIntacto`; `FallaLaBaseDeDatos_BorraElNuevoYConservaElAnterior`; `NoEsPdf_NoHaceNada`; `SinPdfAnterior_AgregaComoAnexo`; `Visor_SoltarUnNoPdf_MuestraElMensaje`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** `ReemplazarContenido` (orden: subir nuevo, transaccion fila, borrar objeto viejo) y la conexion con el visor y TMAIN.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos en ambos motores.
- [ ] **Step 5: Verificacion del usuario**: soltar un PDF en un documento sin contenido; soltar otro encima (pide confirmacion); soltar un .docx (rechazado). Captura.
- [ ] **Step 6: Commit.**

### Task 6: Verificacion, estado y revision final

**Files:**
- Modify: `docs/superpowers/plans/2026-11-10-verificacion-espacio-de-trabajo.md`, estado del diseno

- [ ] **Step 1:** Anadir casos: soltar archivos y carpeta sobre la lista; sin permiso; zonas anexo y fuente; archivos repetidos; contenido nuevo, reemplazo con confirmacion y no-PDF; fallo de red durante la subida.
- [ ] **Step 2:** Suite completa (Access y SQL Server) y anotar el total.
- [ ] **Step 3:** Revision final con un revisor independiente sobre `git diff` desde el inicio del plan y una pasada de correcciones con pruebas.
- [ ] **Step 4: Commit.**

### Task 7: Rediseno visual de la rejilla del modo Editar

Pedido por el usuario junto con el arrastrar y soltar. No hay diseno todavia: antes de tocar codigo se propone y se aprueba una maqueta (el usuario pidio propuestas visuales antes de decidir).

**Files:**
- Create: `docs/superpowers/specs/2026-11-10-modo-editar-design.md`
- Modify (despues de aprobar la maqueta): `UMAINFORM.pas`, `UAparienciaLegacy.pas` y lo que la maqueta decida

- [ ] **Step 1: Recon**: listar lo que hoy hay en el modo Editar (rejilla `cxGrid2` con sus columnas, navegador `dbnSeriesDatos`, pestanas Fuentes, Anexos y Variables, botones por rol) y que acciones solo existen ahi (alta, edicion, borrado, topografia, expediente).
- [ ] **Step 2: Maqueta**: publicar un artefacto con 2 o 3 propuestas (por ejemplo, rejilla con edicion en el propio panel del documento; formulario lateral por pestanas; rejilla compacta con acciones en una barra), con pros y contras, y pedir al usuario que elija.
- [ ] **Step 3**: con la propuesta elegida, escribir el diseno y un plan por tareas (con pruebas) y pedir su aprobacion antes de ejecutar.

## Fuera de este plan

Arrastrar documentos entre subseries; arrastre de metadatos o ubicacion.
