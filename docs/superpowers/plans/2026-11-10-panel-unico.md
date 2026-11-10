# Panel unico (documento dentro del panel lateral) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pasar el panel del documento al panel lateral como segundo modo (Subserie / Documento) para que la lista recupere el ancho.

**Architecture:** `TPanelDocumentos` ofrece sacar su bloque derecho (documento + formulario) y colocarlo en otro contenedor. `TPanelLateral` gana una tira de modos y una pagina Documento que lo recibe. `TMAIN` conecta ambos y decide cuando cambiar de modo. Los controles se mueven enteros, sin reescribirlos.

**Tech Stack:** Delphi 10.3 VCL, DUnitX, UTema.

**Spec:** `docs/superpowers/specs/2026-11-10-panel-unico-design.md`

## Global Constraints

- Compilar con `powershell -File scripts/compilar.ps1 ArchiGenioPro.dproj` y `Pruebas/PruebasArchiGenio.dproj`; si `ArchiGenioPro.exe` esta abierto el enlace falla (cerrar la aplicacion). Pruebas con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` (copia fresca de `BD/SDbd.mdb`).
- `UMAINFORM.pas` solo con `ed2.py` (`edit2`), cp1252 con EOL mixto. Los scripts Python se escriben con `Write`; sin `\u`, `\U` ni barras invertidas en cadenas.
- Unidades nuevas en ASCII y CRLF; documentacion en espanol. No se commitean `Win32/Debug/*.dcu` ni `*.identcache`.
- Ancho del panel lateral: 440 px por defecto, minimo 320 (`FSepLateral.MinSize`); `AutoSnap = False` en ambos separadores.
- Sin panel lateral (modo de respaldo) el panel del documento queda a la derecha de la lista, como hoy.
- Commit al cerrar cada tarea; las visuales terminan con captura del usuario.

## Review Focus

1. El visor de PDF, el receptor de arrastre de la pestana Archivos/Contenido y el formulario de edicion siguen funcionando tras cambiar de padre (ventana recreada, receptor registrado) (Task 1).
2. Sin documento marcado el modo Documento muestra "Sin documento" y no falla; al cambiar de subserie el modo Documento no queda con claves viejas (Task 1, Task 3).
3. Con el modo Subserie activo y la pestana Contenido abierta, marcar documentos no descarga PDFs que nadie ve (Task 3).
4. Cerrar la aplicacion con el documento movido: sin errores de memoria al salir (Task 3, Task 4).
5. Pantallas pequenas: lista + panel de 440 px no desbordan; la lista conserva un minimo legible (Task 3).

---

### Task 1: El panel de documentos puede sacar su bloque derecho

**Files:**
- Modify: `UPanelDocumentos.pas`
- Test: `Pruebas/UPruebasPanelDocumentos.pas`

**Interfaces:**
- Produces: `procedure ColocarDocumentoEn(Destino: TWinControl)` (pasa el bloque derecho `FDer`, con `FDoc` y el formulario, a `Destino` con `Align := alClient` y oculta `FSplitter`); `procedure RestaurarDocumento` (lo devuelve a la derecha de la lista con su ancho y muestra el separador); `function DocumentoSeparado: Boolean`.

- [ ] **Step 1: Write the failing tests** en `UPruebasPanelDocumentos.pas`: `Colocar_MueveElBloqueAlDestinoYLaListaOcupaTodo` (el padre de `Documento` es el destino, la lista mide todo el ancho menos el borde, el separador no se ve); `Colocar_ElVisorYLosReceptoresSiguenRegistrados` (`Visor.ReceptorSoltar.Registrado`, `ReceptorAnexos.Registrado` y `Formulario.Receptor.Registrado` son True tras el movimiento); `Colocar_ElFormularioDeEdicionSigueAbriendo` (con permiso, `Editar` hace visible el formulario dentro del destino); `Restaurar_DevuelveElBloqueALaDerecha` (ancho 340 y `DocumentoSeparado = False`).
- [ ] **Step 2: Run.** Expected: FAIL (metodos no definidos).
- [ ] **Step 3: Implement** los tres miembros en `TPanelDocumentos`: guarda el ancho anterior de `FDer`, cambia `Parent`/`Align` y fuerza `HandleNeeded` y `Registrar` de los receptores si el control recreo su ventana.
- [ ] **Step 4: Run** las pruebas del panel y la suite completa. Expected: 0 fallos.
- [ ] **Step 5: Commit** "El panel de documentos puede colocar su bloque derecho en otro contenedor".

### Task 2: Modos Subserie y Documento en el panel lateral

**Files:**
- Modify: `UPanelLateral.pas`
- Test: `Pruebas/UPruebasPanelLateral.pas`

**Interfaces:**
- Produces: constantes `MODO_SUBSERIE = 0`, `MODO_DOCUMENTO = 1`; `function AgregarModoDocumento: TPanel` (devuelve el contenedor del modo Documento y muestra la tira de modos); `procedure ActivarModo(Modo: Integer)`; `function ModoActivo: Integer`; `property OnCambioModo: TNotifyEvent`. La tira de modos usa `TTiraPestanas` con "Subserie" y "Documento". Sin llamar a `AgregarModoDocumento` el panel se ve y se comporta como hoy.

- [ ] **Step 1: Write the failing tests**: `Modos_SinModoDocumento_NoMuestraTiraDeModos`; `Modos_ConModoDocumento_ElegirDocumentoMuestraSuContenedor` (el contenedor visible y las paginas Series/Detalle/Complementaria y su tira ocultas); `Modos_VolverASubserie_RestauraLaPaginaActivaAnterior`; `Modos_CabeceraDeSubserie_SeMantieneEnAmbosModos` (o se reemplaza por la del documento: la de la subserie solo en modo Subserie); `Modos_OnCambioModo_DisparaAlCambiar`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** la tira de modos encima de la cabecera existente, el contenedor Documento (`alClient`) y `MostrarModo` que alterna visibilidad; `Repintar` incluye lo nuevo.
- [ ] **Step 4: Run** pruebas y suite. Expected: 0 fallos.
- [ ] **Step 5: Commit** "Panel lateral con modos Subserie y Documento".

### Task 3: Conexion en TMAIN

**Files:**
- Modify: `UMAINFORM.pas`, `UPanelDocumentos.pas`
- Test: `Pruebas/UPruebasPanelDocumentos.pas`

**Interfaces:**
- Consumes: `ColocarDocumentoEn`/`RestaurarDocumento` (Task 1), `AgregarModoDocumento`/`ActivarModo` (Task 2).
- Produces: en `ConectarPanelLateral`, tras crear el panel: `FListaDocs.ColocarDocumentoEn(FPanelLateral.AgregarModoDocumento)`, ancho 440 y `FSepLateral.MinSize := 320`; `TPanelDocumentos.OnDocumentoElegido: TNotifyEvent` (se dispara al marcar un documento por el usuario, no por recargas) que `TMAIN` usa para `FPanelLateral.ActivarModo(MODO_DOCUMENTO)`; `Editar` y abrir contenido activan el modo Documento; F10/F11 (Detalle/Series) activan primero el modo Subserie; si `FPanelLateral` falla o es nil, el panel del documento queda a la derecha (`RestaurarDocumento`).

- [ ] **Step 1: Write the failing tests** en el panel: `OnDocumentoElegido_SoloAlMarcarElUsuario` (no se dispara en `Cargar` ni en `SeleccionarClave`); `Contenido_ConElPanelEnOtroModo_NoDescargaSiNoSeVe` (con el contenedor del documento oculto, `OnPedirContenido` no se llama al marcar documentos; se llama al volver a mostrarlo).
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** el evento y la regla de descarga (solo si `FDoc.Showing`), y la conexion en `TMAIN` con `ed2.py`; el modo de respaldo restaura el bloque en el `except` de la creacion del panel lateral.
- [ ] **Step 4: Run** pruebas, compilar la aplicacion y la suite. Expected: 0 fallos.
- [ ] **Step 5: Verificacion del usuario**: abrir la aplicacion, marcar un documento (se abre el modo Documento), volver a Subserie, mover el separador, cambiar de subserie, Editar, soltar un archivo en Archivos y en Contenido, cerrar la aplicacion; captura de la pantalla con lista y panel.
- [ ] **Step 6: Commit** "Panel del documento como modo del panel lateral".

### Task 4: Verificacion, errores de salida y revision final

**Files:**
- Modify: `docs/superpowers/plans/2026-11-10-verificacion-espacio-de-trabajo.md`

- [ ] **Step 1:** Anadir casos: abrir la aplicacion y ver solo dos bloques; marcar documento activa Documento; clic en Subserie muestra Series/Detalle/Complementaria; separador arrastrado a los extremos no cierra ni deja paneles en blanco; Contenido y arrastres tras el movimiento; Editar abre el formulario dentro del panel lateral; cerrar la aplicacion sin errores (`errores_inesperados.log` sin entradas nuevas).
- [ ] **Step 2:** Con el `errores_inesperados.log` del usuario y el `.map` (`DCC_MapFile=3`), traducir las direcciones del acceso invalido al salir (`TCustomForm.IsFormSizeStored`) y corregir su causa con una prueba que la reproduzca si es posible.
- [ ] **Step 3:** Suite completa (Access y SQL Server) y anotar el total.
- [ ] **Step 4:** Revision final con un revisor independiente (modelo fable) sobre `git diff` desde el inicio del plan y una sola pasada de correcciones con pruebas.
- [ ] **Step 5: Commit.**

## Fuera de este plan

Recordar anchos entre sesiones; mover el cuadro de clasificacion; retirar la rejilla antigua.
