# Espacio de trabajo de documentos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sustituir en la pantalla principal el panel "CDC ACTIVO" y la rejilla de series por una barra de trabajo, una tabla de documentos con estado y un panel fijo de propiedades e historia sin recortes, dejando la rejilla cxGrid2 y su navegador como modo edicion.

**Architecture:** Controles nuevos creados por codigo (sin .dfm), con la logica de filtro y estado en unidades sin VCL probadas con DUnitX y el dibujo probado con las pruebas VCL ya existentes. TMAIN solo conecta: alimenta la barra con `UDM.tb_Serietree`, la tabla con `UDM.tb_SeriesDatos` (como hoy) y reutiliza `ListaDocsAlternar`, `ShellAgregarDocumento` y `dbnSeriesDatos` para el modo edicion.

**Tech Stack:** Delphi 10.3 VCL, FireDAC (MSSQL y MSAcc), DUnitX (`Pruebas/`), UTema (claro y oscuro).

**Spec:** `docs/superpowers/specs/2026-11-10-espacio-de-trabajo-design.md` (maqueta B + panel fijo de A).

## Global Constraints

- Delphi 10.3; compilar con `powershell -File scripts/compilar.ps1 ArchiGenioPro.dproj` y `Pruebas/PruebasArchiGenio.dproj`; tests: `Pruebas/Win32/Debug/PruebasArchiGenio.exe` con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` (copia de `BD/SDbd.mdb`).
- No se edita el .dfm binario de UMAINFORM; todo control nuevo se crea por codigo.
- `UMAINFORM.pas` es Windows-1252 con EOL mixtos: editar solo con el helper `ed.py` del scratchpad (reemplazos exactos, prueba LF y CRLF). Unidades nuevas en ASCII.
- Todo SQL debe valer en SQL Server y Access (`TOP n`, sin `SET`/`ONLINE` en rutas comunes).
- Colores solo de `UTema` (`TemaLegacyActual` en formularios antiguos); claro y oscuro.
- Sin `shell_clasico.flag` el comportamiento antiguo sigue; `ConectarShell`/`ConectarListaDocumentos` solo corren con el shell activo.
- Alta y edicion de documentos siguen por la rejilla `cxGrid2` y `dbnSeriesDatos` (modo edicion). No se cambia carga de documentos, modelo de datos ni F5.
- No se hace commit ni push sin que el usuario lo pida; cada entrega termina en una verificacion con captura del usuario (no se puede operar la GUI).

## Review Focus

1. Filtro sin resultados: tabla vacia con texto "Ningun documento coincide", sin seleccion y propiedades vacias (test en Task 1 y Task 3).
2. Titulo muy largo o letra grande (DPI 150 %): ninguna fila de propiedades se recorta; el alto sale de medir el texto (Task 2).
3. Elegir otra serie con un documento a medio editar (dataset en dsEdit/dsInsert): no se cambia de serie y se avisa; nunca se pierde ni se guarda sin querer (Task 5).
4. Nodo sin series, o serie sin documentos: barra de series vacia con texto guia, sin excepciones (Task 5).
5. Prestamos o columnas no disponibles en una base antigua: estado en blanco y bloque "Requiere accion" oculto, sin error ni invencion (Task 1 y Task 6).

---

### Task 1: Estado del documento y filtro (logica pura)

**Files:**
- Modify: `UDocumentoVista.pas` (record `TDatosDocumento`, nuevas funciones)
- Modify: `UDocumentoVistaDatos.pas`
- Create: `Pruebas/UPruebasEstadoDocumento.pas`; registrar en `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Produces (UDocumentoVista): `TEstadoDoc = (edDesconocido, edEnArchivo, edPrestado)`; campo `Estado: TEstadoDoc` en `TDatosDocumento` (por defecto `edDesconocido`); `function TextoEstadoDoc(E: TEstadoDoc): string` (`''`, `'En archivo'`, `'Prestado'`); `function CoincideFiltro(const D: TDatosDocumento; const Texto: string; FiltrarEstado: Boolean; Estado: TEstadoDoc): Boolean` (Texto: sin distinguir mayusculas ni espacios extremos, busca en `Codigodoc`, `Titulo`, `IdExpediente`; vacio coincide con todo).
- Produces (UDocumentoVistaDatos): `function CargarEstados(Conn: TFDConnection; Alcance: TAlcanceUsuario; const Est: string; IdNodo: Integer; const CodSubs: string): TDictionary<string, TEstadoDoc>` (clave `ClaveTexto`; documentos con prestamo abierto = `edPrestado`, el resto de los consultados = `edEnArchivo`; ante `EFDDBEngineException` devuelve diccionario vacio, nunca lanza).

- [ ] **Step 1: Write the failing tests** en `UPruebasEstadoDocumento.pas`: `TextoEstadoDoc_TresValores`; `CoincideFiltro_TextoPorCodigoTituloYExpediente` (`'palma'` coincide con titulo `'Alcantarillado Palma Soriano'`, `'a 03.01'` con codigo `'A 03.01.02.0003'`, `'p-006'` con expediente); `CoincideFiltro_VacioCoincideConTodo`; `CoincideFiltro_EstadoSoloSiSeFiltra`; `CargarEstados_Access_MarcaPrestado` (siembra con el patron de `SembrarDocumento` de `UPruebasTrazabilidadDatos.pas` un documento con prestamo abierto y otro sin): espera `edPrestado` y `edEnArchivo`; `CargarEstados_SinTablaPrestamos_DevuelveVacio`.
- [ ] **Step 2: Run** `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y el exe. Expected: no compila (simbolos no definidos).
- [ ] **Step 3: Implement** las dos funciones puras y `CargarEstados`. Para el prestamo abierto, reutilizar la consulta de prestamos de `CargarLineaTiempo` (`UTrazabilidadDatos.pas`, bloque `prestamos:`) y su filtro de alcance; sin devolucion registrada = abierto.
- [ ] **Step 4: Run** compilacion y exe con las variables de entorno. Expected: 0 fallos, total anterior (293) mas los nuevos.
- [ ] **Step 5: Commit** (solo si el usuario lo pide): `git add UDocumentoVista.pas UDocumentoVistaDatos.pas Pruebas/UPruebasEstadoDocumento.pas Pruebas/PruebasArchiGenio.dpr`.

### Task 2: Lista de propiedades de un solo control

Sustituye las etiquetas sueltas de `FScroll` por un unico control que dibuja y mide su propio texto: no hay hijos que dejen restos y el alto de cada fila sale de medir.

**Files:**
- Create: `UListaPropiedades.pas` (ASCII), registrar en `ArchiGenioPro.dpr` y `Pruebas/PruebasArchiGenio.dpr`
- Modify: `UPanelDocumentos.pas` (quitar `FEtiquetas`, `NuevaEtiqueta` de propiedades, `VaciarPropiedades`, `Reconstruyendo*`; `FScroll` pasa a ser `FPropiedades: TListaPropiedades`)
- Test: `Pruebas/UPruebasPanelDocumentos.pas`

**Interfaces:**
- Produces: `TListaPropiedades = class(TCustomControl)` con `procedure Mostrar(const Props: TArray<TPropiedad>; const Historia: TArray<TEventoDoc>; HayMas: Boolean; const MotivoHistoria: string)`; `procedure MostrarMensaje(const Texto: string)`; `function AlturaContenido: Integer`; `procedure AplicarTema(const T: TTemaColores)`; `property OnVerHistoria: TNotifyEvent`. Desplazamiento vertical propio (rueda y barra), sin hijos.
- Consumes: `ConstruirPropiedades` (UDocumentoVista), `TextoFechaEvento`, `EtiquetaEvento` (UHistoriaDocumento/UTrazabilidad), `TTemaColores` (UTema).

- [ ] **Step 1: Write the failing tests** (VCL, ventana real): `Propiedades_TituloLargo_AlturaCubreElTexto` (titulo de 200 caracteres a 300 px de ancho y fuente 150 %: `AlturaContenido` mayor o igual que lineas medidas con `DrawText(DT_CALCRECT)`); `Propiedades_SinEventos_MuestraSinEventosRegistradosCompleto` (la ultima fila queda dentro de `AlturaContenido`); `Propiedades_MensajeReemplazaTodo` (tras `MostrarMensaje` no queda texto de propiedades: `PaintTo` comparado con repintado limpio, como `SeleccionarDocumento_LaPantallaEsIgualQueUnRepintadoLimpio`); `Propiedades_ClicEnVerHistoria_DisparaEvento`.
- [ ] **Step 2: Run** compilar + exe. Expected: no compila (unidad inexistente).
- [ ] **Step 3: Implement** `TListaPropiedades` (DoubleBuffered, `Paint` dibuja grupos en mayuscula con `Acento`, etiquetas con `TextoSuave`, valores con `Texto`, historia con 5 eventos y el enlace "Ver historia completa"; fuente `Segoe UI`, tamanos 8/10/9 escalados por `Font.PixelsPerInch`; cache de alturas recalculada en `Resize`/`Mostrar`). Adaptar `TPanelDocumentos` y mantener `OnPedirHistoria`, cache de historia y `HistoriaClick`.
- [ ] **Step 4: Run** el exe. Expected: 0 fallos; las pruebas de `UPruebasPanelDocumentos` que dependian de `FEtiquetas` se reescriben contra el nuevo control en este mismo paso.
- [ ] **Step 5: Compile** `ArchiGenioPro.dproj`. Expected: 0 errores.
- [ ] **Step 6: Verificacion del usuario**: ejecutar, elegir un documento con titulo largo y sin historia, y enviar captura (comprobar que no hay texto recortado ni superpuesto).
- [ ] **Step 7: Commit** si el usuario lo pide.

### Task 3: Tabla con estado y filtro en el panel

**Files:**
- Modify: `UPanelDocumentos.pas`, `UMAINFORM.pas` (`ListaDocsCargar`)
- Test: `Pruebas/UPruebasPanelDocumentos.pas`

**Interfaces:**
- Consumes: `TEstadoDoc`, `CoincideFiltro`, `TextoEstadoDoc`, `CargarEstados` (Task 1).
- Produces: `procedure TPanelDocumentos.FijarFiltro(const Texto: string; FiltrarEstado: Boolean; Estado: TEstadoDoc)` (reaplica `AplicarFiltro`, conserva seleccion si sigue visible); columnas de `FLista`: Codigo, Titulo, Serie, Estado (la columna Estado muestra `TextoEstadoDoc`, vacia si `edDesconocido`); `property Visibles: Integer` (cantidad mostrada) y `property OnCambioFiltro: TNotifyEvent`.

- [ ] **Step 1: Write the failing tests**: `Filtro_PorTexto_DejaSoloLosQueCoinciden`; `Filtro_SinResultados_MuestraTextoYNoSeleccion` (`FVacio` dice "Ningun documento coincide" y las propiedades quedan vacias); `Filtro_PorEstado_Prestado`; `Cargar_ConEstados_MuestraColumna`.
- [ ] **Step 2: Run.** Expected: FAIL (metodo no definido).
- [ ] **Step 3: Implement** `FijarFiltro` y columna Estado; en `ListaDocsCargar` llamar a `CargarEstados` dentro del mismo `try` que `CargarIndicadores` (si falla, `RegistrarErrorLista('Estados: ...')` y se sigue sin estado); asignar `D.Estado`. Quitar el boton "Ver rejilla" de `FBarra` (pasa a la barra de trabajo, Task 4) y dejar en `FBarra` solo el titulo y el aviso de expediente filtrado.
- [ ] **Step 4: Run** compilar + exe. Expected: 0 fallos.
- [ ] **Step 5: Commit** si el usuario lo pide.

### Task 4: Barra de trabajo

**Files:**
- Create: `UBarraTrabajo.pas` (ASCII), registrar en ambos `.dpr`
- Modify: `UMAINFORM.pas` (`ConectarListaDocumentos`, `ListaDocsAlternar`, `ShellAgregarDocumento`), `UPanelDocumentos.pas` (`OnAlternarVista` deja de usarse)
- Test: `Pruebas/UPruebasBarraTrabajo.pas`

**Interfaces:**
- Produces: `TSerieFiltro = record CodSubs, Nombre: string; Cantidad: Integer; end` (`Cantidad = -1` desconocida); `TSerieEvent = procedure(const CodSubs: string) of object`; `TBarraTrabajo = class(TPanel)` con `procedure FijarRuta(const Ruta, Titulo: string)`; `procedure FijarSeries(const Series: TArray<TSerieFiltro>; const Actual: string)`; `procedure ModoEdicion(Valor: Boolean)` (cambia el texto de "Editar" a "Ver lista"); `property Texto: string`; `property FiltrarEstado: Boolean`; `property Estado: TEstadoDoc`; `property OnElegirSerie: TSerieEvent`; `property OnFiltroCambio: TNotifyEvent`; `property OnNuevo, OnEditar: TNotifyEvent`. Se construye por codigo con `UTema`; alto 96 (ruta y titulo, fichas de serie, fila de busqueda y botones).
- Consumes: `TEstadoDoc` (Task 1).

- [ ] **Step 1: Write the failing tests**: `Barra_FijarSeries_CreaUnaFichaPorSerieMasTodas`; `Barra_ClicEnFicha_DisparaOnElegirSerieConSuCodigo`; `Barra_SinSeries_MuestraTextoGuia`; `Barra_Busqueda_DisparaOnFiltroCambio`; `Barra_ModoEdicion_CambiaTextoDelBoton`.
- [ ] **Step 2: Run.** Expected: FAIL (unidad inexistente).
- [ ] **Step 3: Implement** `TBarraTrabajo` (fichas con ajuste de linea si no caben; busqueda con retardo de 250 ms para no recargar en cada tecla).
- [ ] **Step 4: En `UMAINFORM.pas`** crear `FBarraTrabajo` alineada arriba en `PSeriesDatos` (visible en modo lista y en modo edicion), conectar `OnFiltroCambio` a `FListaDocs.FijarFiltro`, `OnNuevo` a `ShellAgregarDocumento`, `OnEditar` a `ListaDocsAlternar`, y llamar a `FBarraTrabajo.ModoEdicion(not FModoLista)` desde `ListaDocsAlternar`. Retirar `FBarraRejilla` (su boton "Ver lista" lo sustituye "Ver lista" de la barra).
- [ ] **Step 5: Run** pruebas y compilar `ArchiGenioPro.dproj`. Expected: 0 fallos, 0 errores.
- [ ] **Step 6: Commit** si el usuario lo pide.

### Task 5: Series como filtro y fuera "CDC ACTIVO"

**Files:**
- Modify: `UMAINFORM.pas` (`BarraSeriesCargar`, `BarraElegirSerie`, `MostrarCuadroClasif`, sitios que hacen `advtpCuadroClasif.Show` en `tvTreeChange`/`tvTreeClick`/`PMTool`)
- Test: `Pruebas/UPruebasBarraTrabajo.pas` (comportamiento visual) y verificacion manual de la parte con datos

**Interfaces:**
- Produces en `TMAIN`: `procedure BarraSeriesCargar` (recorre `UDM.tb_Serietree` con `DisableControls`/bookmark, arma `TArray<TSerieFiltro>` con `codsubs` y nombre de `cl_subseries`, llama a `FBarraTrabajo.FijarSeries`); `procedure BarraElegirSerie(const CodSubs: string)` (`UDM.tb_Serietree.Locate('codsubs', CodSubs, [])`; si el dataset de documentos esta en `dsEdit`/`dsInsert` no cambia, avisa con `UDM.sms('Guarde o cancele el documento antes de cambiar de serie.', 3)` y deja la ficha anterior marcada); `procedure MostrarCuadroClasif(Mostrar: Boolean)` (con shell activo y `FBarraTrabajo <> nil` siempre oculta `advtpCuadroClasif` y `advtpCC`; sin shell conserva el comportamiento actual).
- Consumes: `FBarraTrabajo` (Task 4), `ListaDocsCambio` (ya recarga al cambiar `tb_Serietree`).

- [ ] **Step 1: Write the failing tests** (VCL con fabrica): `Barra_ElegirSerie_ConEdicionPendiente_NoCambia` usando un doble de dataset en `dsEdit` expuesto por una funcion `PuedeCambiarSerie(Estado: TDataSetState): Boolean` en `UBarraTrabajo.pas` (pura: solo `dsBrowse`/`dsInactive` permiten cambiar) y `PuedeCambiarSerie_TodosLosEstados`.
- [ ] **Step 2: Run.** Expected: FAIL (funcion no definida).
- [ ] **Step 3: Implement** `PuedeCambiarSerie`, y las tres rutinas de `TMAIN`; sustituir cada `advtpCuadroClasif.Show`/`Hide`/`Locked` (lineas 5355, 6563, 10442-10658 en la version actual) por `MostrarCuadroClasif`; llamar a `BarraSeriesCargar` al cambiar de nodo (donde hoy se asigna `advtpCuadroClasif.Caption := 'CDC ACTIVO ...'`) y poner `FijarRuta` con la ruta del nodo del `tvTree`.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos, 0 errores.
- [ ] **Step 5: Verificacion del usuario**: cambiar de nodo con series (fichas), nodo sin series (texto guia), y con un documento en edicion en la rejilla (aviso). Enviar captura.
- [ ] **Step 6: Commit** si el usuario lo pide.

### Task 6: Panel "Mi area" y bloque "Requiere accion"

**Files:**
- Create: `UBloqueAccion.pas` (ASCII)
- Modify: `UDocumentoVistaDatos.pas`, `UMAINFORM.pas`, `UAparienciaLegacy.pas`
- Test: `Pruebas/UPruebasEstadoDocumento.pas`

**Interfaces:**
- Produces: `TContadorAccion = record Clave, Texto: string; Cantidad: Integer; end`; `function CargarRequiereAccion(Conn: TFDConnection; Alcance: TAlcanceUsuario): TArray<TContadorAccion>` (`'vencidos'` = prestamos abiertos con fecha de devolucion anterior a hoy; `'sinubicacion'` = documentos del alcance con archivo, deposito o gaveta vacios o `'0'`; si una consulta falla se omite ese contador; sin contadores devuelve arreglo vacio); `TBloqueAccion = class(TPanel)` con `procedure Mostrar(const Contadores: TArray<TContadorAccion>)` (oculto si el arreglo esta vacio) y `TClaveTextoEvent = procedure(const Clave: string) of object` y `property OnElegir: TClaveTextoEvent` (solo `'vencidos'` es pulsable y pone el filtro de estado en Prestado en la barra; `'sinubicacion'` es informativo, sin accion).
- Consumes: `TTemaColores`, `FijarFiltro`/`TBarraTrabajo` (Tasks 3-4).

- [ ] **Step 1: Write the failing tests**: `RequiereAccion_Access_CuentaVencidosYSinUbicacion`; `RequiereAccion_SinColumna_OmiteContadorYNoLanza`; `Bloque_SinContadores_QuedaOculto`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** la funcion de datos y `TBloqueAccion`; colocar el bloque bajo `tvTree` dentro de `bgBDControl` (mismo padre que el arbol, `Align := alBottom`); refrescar al conectar el shell y tras cada recarga de documentos. En `UAparienciaLegacy.pas` aplicar a `nbMain` el color y la cabecera de "Mi area" del tema (sin la cabecera azul).
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos, 0 errores.
- [ ] **Step 5: Verificacion del usuario** con captura del panel izquierdo (con datos y, si es posible, con una base sin prestamos).
- [ ] **Step 6: Commit** si el usuario lo pide.

### Task 7: Paneles laterales de detalle

**Files:**
- Modify: `UAparienciaLegacy.pas` (`AdaptarPanelLateral`), `UMAINFORM.pas` (arranque de `advtpDetalle`)
- Test: verificacion con captura (no hay logica pura)

**Interfaces:**
- Produces: `procedure AdaptarPanelLateral(P: TAdvToolPanel; const T: TTemaColores)` (cabecera con fuente Segoe UI en negrita, color de `Superficie2`, borde `Linea`, sin gradiente ni icono de chincheta; aplica `AdaptarRejilla` a las rejillas que contiene, como `advtpSSDispo.cxGrid1`).
- Consumes: `AdaptarRejilla`, `AdaptarControl`.

- [ ] **Step 1:** Antes de escribir codigo, pedir al usuario una captura de `advtpDetalle` abierto (series disponibles, detalle, archivo digital) y decidir con el usuario si se agrupa en pestanas o se mantiene; esa decision cambia lo que sigue (no se asume).
- [ ] **Step 2: Implement** `AdaptarPanelLateral` segun lo decidido y llamarlo desde `AplicarAparienciaLegacy` para los `TAdvToolPanel` de `TMAIN`.
- [ ] **Step 3: Compile** y **verificacion del usuario** con captura.
- [ ] **Step 4: Commit** si el usuario lo pide.

### Task 8: Lista de verificacion y estado del diseno

**Files:**
- Create: `docs/superpowers/plans/2026-11-10-verificacion-espacio-de-trabajo.md`
- Modify: `docs/superpowers/specs/2026-11-10-espacio-de-trabajo-design.md` (estado: Implementada o lo que quede)

- [ ] **Step 1:** Escribir la lista manual: nodo con varias series; nodo sin series; filtro de texto sin resultados; filtro de estado; documento prestado visible en la tabla y en la historia; "Nuevo" abre la rejilla lista para insertar; "Editar" y "Ver lista" alternan; cambio de serie con documento en edicion avisa; titulo largo; tema oscuro; DPI 125 y 150 %; `shell_clasico.flag` presente conserva la pantalla antigua.
- [ ] **Step 2:** Ejecutar la suite completa (Access y SQL Server) y anotar el total en el documento.
- [ ] **Step 3: Commit** si el usuario lo pide.

## Fuera de este plan

Aplicar el mismo criterio al resto de pantallas antiguas (entrega 5 del diseno): se planifica aparte, con capturas de cada una, una vez aprobada esta pantalla.
