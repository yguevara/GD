# Panel lateral unico Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sustituir las tres pestanas verticales de `advtpDetalle` (Subseries disponibles, Detalles Subserie actual, Informacion complementaria) por un solo panel fijo a la derecha con tres pestanas horizontales (Series, Detalle, Complementaria).

**Architecture:** Un control nuevo creado por codigo (`TPanelLateral`) con cabecera, tira de pestanas y una pagina por pestana. Los controles que hoy viven dentro de `advtpSSDispo`, `advtpDetail` y `pArchivoDig` se mueven (cambio de `Parent`, sin recrearlos) a esas paginas, de modo que rejillas, navegadores y botones conservan datos y manejadores. `advtpDetalle` queda oculto. TMAIN solo conecta.

**Tech Stack:** Delphi 10.3 VCL, DevExpress cx*, TMS AdvToolPanel, DUnitX (`Pruebas/`), UTema.

**Spec:** `docs/superpowers/specs/2026-11-10-panel-lateral-design.md` (maqueta "Paneles laterales ArchiGenio", propuesta 1).

## Global Constraints

- Compilar con `powershell -File scripts/compilar.ps1 ArchiGenioPro.dproj` y `Pruebas/PruebasArchiGenio.dproj`; exe de pruebas con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` (copia de `BD/SDbd.mdb`).
- No se edita el .dfm binario de UMAINFORM; no se recrean rejillas ni se tocan datasets, consultas o permisos.
- `UMAINFORM.pas` es Windows-1252 con EOL mixtos: editar solo con `ed2.py` del scratchpad (`edit2`). Unidades nuevas en ASCII, CRLF.
- Colores y fuente de `UTema` (`TemaLegacyActual` en formularios antiguos); Segoe UI.
- Sin `shell_clasico.flag` el comportamiento antiguo sigue; el panel nuevo solo se crea junto con la barra de trabajo (`FBarraTrabajo <> nil`).
- Las teclas F10 (detalle), F11 (series) y el boton `btnViewPanel` (archivo digital) siguen funcionando: activan la pestana correspondiente.
- Antes de cerrar la tarea 2 y la 4, el usuario ejecuta el exe y manda captura (no se puede operar la GUI).
- Commits solo cuando el usuario los pida o al cerrar cada tarea si ya lo pidio de forma general.

## Review Focus

1. Un dataset que se preparaba al mostrar su panel (`PrepareSSDisp`, `PrepareSSDetailView`, `ArchivoActual`) sigue cargandose con el panel nuevo: no depende de que `advtpX.Showing` sea verdadero (revisar `advtpDetalle.Visible`/`Panels[...]` en `PLADClick`, `PLDSClick`, y los sitios de `advtpDetalle.Visible := True`).
2. Los controles movidos conservan sus eventos: pulsar un boton movido (p. ej. `btnExcelExportSSD`) sigue llamando a su manejador (Task 1, prueba de `MoverContenido`).
3. Nodo sin subserie o sin series: cabecera "Sin subserie" y pestanas utilizables, sin excepciones (Task 2).
4. Panel estrecho (380 px) o ventana pequena: las rejillas ajustan columnas y no aparece barra horizontal inutil (Task 4).
5. Modo clasico (`shell_clasico.flag`) y fallo al conectar: `advtpDetalle` y sus paneles siguen visibles como hoy (Task 2).

---

### Task 1: Panel lateral con pestanas y `MoverContenido`

**Files:**
- Create: `UPanelLateral.pas` (ASCII), registrar en `ArchiGenioPro.dpr`
- Create: `Pruebas/UPruebasPanelLateral.pas`; registrar en `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Produces: `TPanelLateral = class(TPanel)` con `function AgregarPagina(const Titulo: string): TPanel` (devuelve el contenedor de la pagina, `Align = alClient`, solo la activa es visible); `procedure Activar(Indice: Integer)`; `function PaginaActiva: Integer`; `function CantidadPaginas: Integer`; `procedure FijarCabecera(const Titulo, Codigo: string)` (con `Titulo = ''` muestra "Sin subserie"); `property OnCambioPagina: TNotifyEvent`; `function TextoCabecera: string`; se construye con `UTema` en `SetParent` como `TBarraTrabajo`.
- Produces: `procedure MoverContenido(Origen, Destino: TWinControl)` (pasa cada hijo de `Origen` a `Destino` en su orden, conservando `Align`, `Anchors` y manejadores; `Origen` queda sin hijos).

- [ ] **Step 1: Write the failing tests** en `UPruebasPanelLateral.pas`: `AgregarPagina_SoloLaActivaEsVisible`; `Activar_CambiaDePaginaYAvisa` (cuenta `OnCambioPagina`); `FijarCabecera_SinTitulo_DiceSinSubserie`; `MoverContenido_ConservaOrdenAlignYEventos` (origen con un `TPanel alTop`, un `TButton` con `OnClick` que incrementa un contador y un `TPanel alClient`; tras mover, `Destino.ControlCount = 3`, el boton sigue con su `OnClick` y al llamar `Click` el contador sube, y `Origen.ControlCount = 0`).
- [ ] **Step 2: Run** `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`. Expected: no compila (unidad inexistente).
- [ ] **Step 3: Implement** `UPanelLateral.pas`: cabecera (titulo en 11 pt negrita y codigo como pastilla), tira de pestanas dibujada por un control propio (texto Segoe UI 9 semi-negrita, subrayado de `Acento` en la activa, tab foco por teclado con flechas), paginas como `TPanel` sin borde con `Color = Superficie`.
- [ ] **Step 4: Run** compilar + exe con las variables de entorno. Expected: 0 fallos.
- [ ] **Step 5: Commit** (`UPanelLateral.pas`, `Pruebas/UPruebasPanelLateral.pas`, ambos `.dpr`).

### Task 2: Conectar el panel lateral en TMAIN

**Files:**
- Modify: `UMAINFORM.pas` (`ConectarListaDocumentos` o nuevo `ConectarPanelLateral`, sitios con `advtpDetalle.Visible := True`, `BarraSeriesCargar`, `PLADClick`, `PLDSClick`)
- Modify: `UAparienciaLegacy.pas` solo si hace falta (Task 4)

**Interfaces:**
- Consumes: `TPanelLateral`, `MoverContenido` (Task 1); `FBarraTrabajo`, `BarraSeriesCargar`, `FNombresSerie` (ya existentes).
- Produces en `TMAIN`: `FPanelLateral: TPanelLateral`; `procedure ConectarPanelLateral` (lo crea en `PContainer` con `Align = alRight` y `Width = 380`, un separador movible, y llama a `MoverContenido(advtpSSDispo, paginaSeries)`, `MoverContenido(advtpDetail, paginaDetalle)`, `MoverContenido(pArchivoDig, paginaComplementaria)`; activa Detalle; `advtpDetalle.Visible := False`); `procedure AjustarPanelLateral` (si `FPanelLateral <> nil`, `advtpDetalle` siempre oculto; si no, comportamiento actual) usado en lugar de cada `advtpDetalle.Visible := True`; `procedure ActualizarCabeceraLateral` (nombre y codigo de la subserie actual de `tb_Serietree`, via `FNombresSerie`; vacio si no hay), llamado al final de `BarraSeriesCargar`.

- [ ] **Step 1: Write the failing test** (VCL, `UPruebasPanelLateral.pas`): `MoverContenido_TresPaneles_QuedanLasRejillasEnSuPagina` con tres `TPanel` origen que simulan los paneles (cada uno con un hijo `TPanel` etiquetado) y comprobacion de que cada hijo termina en la pagina correcta y visible solo cuando su pestana esta activa.
- [ ] **Step 2: Run.** Expected: FAIL hasta que el helper de ensamblado exista.
- [ ] **Step 3: Implement** `ConectarPanelLateral` y las funciones de ajuste en TMAIN; llamar a `ConectarPanelLateral` en `ConectarListaDocumentos` despues de crear la barra; limpiar (`FreeAndNil(FPanelLateral)`, `advtpDetalle.Visible := True`) en la rama de error, como ya se hace con la barra.
- [ ] **Step 4: Run** compilar `ArchiGenioPro.dproj` y pruebas. Expected: 0 errores, 0 fallos.
- [ ] **Step 5: Verificacion del usuario**: ejecutar, elegir un nodo con series y comprobar que el panel muestra Detalle, que Series lista las subseries disponibles con sus botones y que Complementaria muestra sus pestanas. Enviar captura de cada pestana.
- [ ] **Step 6: Commit.**

### Task 3: Teclas y botones

**Files:**
- Modify: `UMAINFORM.pas` (`FormKeyDown` en teclas 121 y 122, `btnViewPanelClick`, `PLADClick`, `PLDSClick`, `PLSDClick`)

**Interfaces:**
- Consumes: `FPanelLateral.Activar(Indice)` y las constantes `PAG_SERIES = 0`, `PAG_DETALLE = 1`, `PAG_COMPLEMENTARIA = 2` (definirlas en `UPanelLateral.pas`).
- Produces: con `FPanelLateral <> nil`, F10 activa Detalle, F11 activa Series y `btnViewPanel` activa Complementaria; sin panel nuevo, el codigo actual no cambia.

- [ ] **Step 1: Write the failing test**: `Activar_PorConstante_SeleccionaLaPaginaEsperada` (en `UPruebasPanelLateral.pas`).
- [ ] **Step 2: Run.** Expected: FAIL (constantes no definidas).
- [ ] **Step 3: Implement** las constantes y el mapeo en los manejadores citados.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos, 0 errores.
- [ ] **Step 5: Commit.**

### Task 4: Ajuste de contenido y tema

**Files:**
- Modify: `UAparienciaLegacy.pas` (`AdaptarVistaTabla`, `AdaptarRejillaVertical`, `AplicarAparienciaLegacy`)
- Test: verificacion con captura

**Interfaces:**
- Produces: `AdaptarVistaTabla` pone `OptionsView.ColumnAutoWidth := True` en las vistas de `cxGrid1` y `gVariablesDetail` para que las columnas quepan en 380 px; `AdaptarRejillaVertical` fija `OptionsView.RowHeaderWidth` proporcional al ancho; el panel nuevo recibe fuente y colores del tema como el resto.

- [ ] **Step 1:** Sin captura nueva no se decide: pedir al usuario captura de las tres pestanas del panel nuevo antes de tocar anchos.
- [ ] **Step 2: Implement** los ajustes citados y las filas altas de "Pertenece a la Serie" y "Observacion" (altura por contenido, sin altura fija) si la captura lo muestra.
- [ ] **Step 3: Compile** y verificacion del usuario con captura de las tres pestanas.
- [ ] **Step 4: Commit.**

### Task 5: Lista de verificacion y estado

**Files:**
- Modify: `docs/superpowers/plans/2026-11-10-verificacion-espacio-de-trabajo.md` (casos 19 y siguientes)
- Modify: `docs/superpowers/specs/2026-11-10-panel-lateral-design.md` (estado)

- [ ] **Step 1:** Anadir casos: las tres pestanas muestran el contenido de sus paneles antiguos; F10 y F11 cambian de pestana; `btnViewPanel` abre Complementaria; "Asignar", "Exportar", "Ajustar columnas" y "Filtrado rapido" funcionan desde Series; nodo sin subserie dice "Sin subserie"; `shell_clasico.flag` conserva las pestanas verticales.
- [ ] **Step 2:** Correr la suite completa (Access y SQL Server) y anotar el total.
- [ ] **Step 3: Commit.**

## Fuera de este plan

Rediseñar el contenido de las rejillas (columnas, textos) o eliminar botones que el usuario no use; aplicar este criterio al resto de pantallas antiguas.
