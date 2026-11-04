# Fase 1: Base visual (variante A) y búsqueda con ámbito - Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dar a ArchiGenio la pantalla principal de la variante A (barra lateral, árbol, buscador arriba), con un sistema de diseño común, y hacer que la búsqueda pida explícitamente su ámbito (general o nodo actual) respetando siempre los permisos.

**Architecture:** La lógica nueva y comprobable vive en unidades sin VCL (`UBusqueda`, `UBusquedaDatos`, `UTema`), con pruebas DUnitX. La apariencia se aplica por código sobre los controles que `TMAIN` ya tiene (`pMainContainer`, `nbMain`, `tvTree`, `PContainer`), en una unidad nueva `UShellPrincipal`, sin editar el `.dfm` binario de 15.000 líneas. Un archivo `shell_clasico.flag` junto al ejecutable desactiva el shell nuevo si algo falla en un cliente.

**Tech Stack:** Delphi 10.3 (VCL, `TImageCollection`/`TVirtualImageList` para PNG), DevExpress 19.1 ya instalado, iconos Tabler, FireDAC, DUnitX.

**Spec:** `docs/superpowers/specs/2026-10-29-rediseno-archigenio-design.md`, secciones 6, 7 y 15 (decisiones de esta fase). Maqueta aprobada: https://claude.ai/artifact/Qd8aUcEcfhfHFn1UtP5c74

## Global Constraints

- Variante A: columna de iconos de 58 px a la izquierda, árbol de unos 270 px, trabajo a la derecha; buscador y «Agregar documento» en la barra superior (decisión del dueño, spec sección 15).
- La búsqueda alcanza **todos los nodos**. Donde el usuario no tiene permiso devuelve solo documentación **pública** (subseries con `acceso = 1`). El usuario elige el ámbito: **general** o **nodo actual**; el nodo actual incluye sus descendientes. Por defecto «general», y se recuerda la última elección durante la sesión.
- Toda consulta de documentos conserva `FiltroDocumentos(Alcance, 'S')`; `Alcance = nil` (Access) o administrador produce `1=1`. El ámbito solo añade una restricción más con `AND`.
- Nada del texto del usuario va concatenado al SQL (parámetros tipados con `AplicarParametros`).
- SQL Server y Access; el modo Access sigue mostrando todo y no tiene alcance.
- Colores con contraste legible: razón de contraste mínima 4.5 entre texto y fondo, y entre texto y acento, en claro y oscuro. Iconos de una sola familia (Tabler, trazo 1.75).
- Fuentes nuevos en ASCII puro, CRLF, registrados en `ArchiGenioPro.dpr` (y en `Pruebas/PruebasArchiGenio.dpr` los comprobables). No se edita `UMAINFORM.dfm`. Los cambios en `UMAINFORM.pas` son mínimos: llamadas a `UShellPrincipal`.
- Pruebas con base: `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y una **copia** de `BD\SDbd.mdb` en `ARCHIGENIO_TEST_MDB`; nunca `SGDDRHMAIN` ni el `.mdb` original.
- `UMAINFORM.pas` está en ANSI y con saltos de línea mezclados; confirmar el estado con `git diff --ignore-space-at-eol` y subir solo las líneas propias (`git apply --cached` de ese diff).
- Commits por nombre de archivo y solo con autorización del dueño.

## Review Focus

- Búsqueda general como usuario sin asignaciones: devuelve solo públicas, nunca una restringida de otro nodo (Tarea 1).
- Ámbito «nodo actual» sobre un nodo sin permiso: solo públicas de ese nodo y sus hijos; sobre un nodo con claves irregulares (`A.1.6 ` con espacio final, `a.1.4` en minúscula): lo encuentra igual (Tarea 1).
- Ámbito «nodo actual» sin nodo seleccionado en el árbol: la pantalla lo avisa y no cae en silencio a «general» (Tarea 4).
- Resultado público de un nodo que no aparece en el árbol del usuario: se abre sin intentar seleccionarlo en el árbol (Tarea 4).
- Shell nuevo con `shell_clasico.flag` presente: la pantalla clásica funciona igual que antes (Tarea 3).
- Botones antiguos con permisos (`SetMenuSecurity` trabaja por Caption): siguen visibles u ocultos según el rol tras moverlos al menú de Gestión (Tarea 3).
- Pantalla pequeña (1366x768) y escala de Windows al 125%: la columna, el árbol y la barra no se solapan (Tarea 3).

---

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `UBusqueda.pas` (modificar) | `TAmbitoBusqueda`, restricción de nodos en `SqlSubserie`. |
| `UBusquedaDatos.pas` (modificar) | Nodos del ámbito, columna `Acceso` en el resultado. |
| `UTema.pas` (crear) | Tokens de color y tamaño, razón de contraste. Sin VCL de formularios. |
| `UIconos.pas` (crear) | Colección de iconos Tabler en PNG (`TImageCollection`) y acceso por nombre. |
| `Iconos/` y `Iconos.rc` (crear) | PNG exportados y recurso que los enlaza al ejecutable. |
| `UShellPrincipal.pas` (crear) | Aplica la variante A sobre `TMAIN`: columna, barra superior, buscador, ámbito. |
| `UBusquedaDocumentos.pas` (modificar) | Selector de ámbito y columna de acceso; se reutiliza como panel de resultados. |
| `USplash.dfm/.pas`, `UAbout.dfm/.pas` (modificar) | Nueva apariencia con los tokens; sin tocar la protección ni la lectura de hardware. |
| `UMAINFORM.pas` (modificar) | Llamadas mínimas a `UShellPrincipal`. |
| `Pruebas/UPruebasBusqueda*.pas`, `Pruebas/UPruebasTema.pas` (crear/modificar) | Pruebas de las tareas 1 y 2. |

---

### Task 1: Ámbito de la búsqueda (general o nodo actual)

**Files:**
- Modify: `UBusqueda.pas`, `UBusquedaDatos.pas`
- Test: `Pruebas/UPruebasBusqueda.pas`, `Pruebas/UPruebasBusquedaDatos.pas`

**Interfaces:**
- Consumes: `TClaveNodo`, `TArbolNodos` (`Contiene`, `EsDescendiente`, `Todos`), `NormalizaClave` de `UAlcance`; `CargarAlcance` y `FiltroDocumentos` de `UAlcanceDatos`.
- Produces:
  - `TAmbitoBusqueda = (abGeneral, abNodoActual)` en `UBusqueda`.
  - Campos nuevos de `TPedidoBusqueda`: `Ambito: TAmbitoBusqueda`; `IdsNodo: TArray<string>` (los `IdEstructura` literales del nodo y sus descendientes; vacío con `abGeneral`).
  - `ValidarPedido` rechaza `abNodoActual` con `IdsNodo` vacío: «Elija un nodo del árbol para buscar en el nodo actual.»
  - `SqlSubserie` añade `AND S.IdEstructura IN (:bqN, ...)` cuando `Ambito = abNodoActual`.
  - `function NodosDelAmbito(Conn: TFDConnection; const Nodo: TClaveNodo): TArray<string>` en `UBusquedaDatos` (carga `tb_tree` con la misma rutina que `CargarAlcance`, devuelve los `IdEstructura` literales del nodo y de todo `EsDescendiente`).
  - Columna `Acceso` (`string`: `Publica`, `Restringida`, `Secreta`) en el `TFDMemTable` de `Buscar`, leída de `cl_subseries.acceso` (1, 2, 3).

- [ ] **Step 1: Escribir las pruebas que fallan** en `TPruebasBusqueda` (sin base):
  - `ValidarPedido_NodoActualSinNodo`: `Ambito=abNodoActual`, `IdsNodo=nil` devuelve el mensaje exacto de arriba; con `abGeneral` y `IdsNodo=nil` devuelve `''`.
  - `SqlSubserie_NodoActualRestringeIdEstructura`: con `IdsNodo=['A.4.3','A.4.3.1']` la condición contiene `S.IdEstructura IN (`, los dos valores van como parámetros y no aparecen en el SQL; con `abGeneral` no hay `IN` de `IdEstructura`.
  - `SqlSubserie_NodoActualConservaElAlcance`: el texto del filtro de alcance sigue presente, unido con `AND`.
- [ ] **Step 2: Escribir las pruebas con base** en `TPruebasBusquedaSql` (y su gemela de Access sin alcance). Con los datos de `TEscenario.Sembrar` (documentos de `014001` en `A.4.6/160`, `A.1.7/160`, `A.4/101`, y `003` en `A.4.3/104`):
  - `Buscar_GeneralUsuarioSinAsignaciones_SoloPublicas`: `prueba_alc_vacio`, texto «prueba alcance», `abGeneral`: ninguna fila con `Acceso <> 'Publica'`.
  - `Buscar_NodoActualSinPermiso_SoloPublicas`: `prueba_alc_usr1`, `abNodoActual` en `A.4.6` (donde no tiene permiso): ninguna fila restringida.
  - `Buscar_NodoActualConPermiso`: `prueba_alc_usr1`, `abNodoActual` en `A.4.3`: devuelve los de `014001` de ese nodo y descendientes más los públicos de ahí.
  - `Buscar_NodoActualIncluyeDescendientes`: `administrador`, `abNodoActual` en `A.4`: incluye los de `A.4.6` y `A.4`, no los de `A.1.7`.
  - `NodosDelAmbito_ClavesIrregulares`: sembrar nodos `a.1.4` y `A.1.6 ` (con espacio final) dentro de la transacción y comprobar que `NodosDelAmbito` desde `A.1` los devuelve con su escritura literal.
- [ ] **Step 3: Compilar y ejecutar.** Esperado: no compila (faltan `Ambito`, `IdsNodo`, `NodosDelAmbito`).
- [ ] **Step 4: Implementar** los tipos y la restricción en `UBusqueda.pas`, y `NodosDelAmbito` y la columna `Acceso` en `UBusquedaDatos.pas`. La columna `Acceso` sale de un `LEFT JOIN cl_subseries` en la consulta de cada subserie (o de una consulta por subserie ya hecha en `NombreDeSubserie`; elegir lo más simple).
- [ ] **Step 5: Ejecutar la suite completa** con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` apuntando a la copia. Esperado: todo en verde; con una base o ruta inexistente fallan las pruebas con base (no se omiten por error).
- [ ] **Step 6: Commit por nombre**, con autorización.

### Task 2: Sistema de diseño (`UTema`) e iconos (`UIconos`)

**Files:**
- Create: `UTema.pas`, `UIconos.pas`, `Iconos.rc`, carpeta `Iconos/` con los PNG
- Test: `Pruebas/UPruebasTema.pas`
- Modify: `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Produces:
  - `TTemaColores = record Fondo, Superficie, Superficie2, Texto, TextoSuave, Linea, Acento, TextoSobreAcento, AcentoSuave, Aviso: TColor; end`.
  - `function TemaClaro: TTemaColores; function TemaOscuro: TTemaColores;` con los valores de la maqueta (claro: fondo `#e9edf1`, superficie `#ffffff`, texto `#1b2733`, acento `#1d5fa6`; oscuro: fondo `#12181e`, superficie `#1a232c`, texto `#e5ebf1`, acento `#6aa8ea`).
  - `function ColorDeHex(const Hex: string): TColor` (`'#rrggbb'`, lanza `EArgumentException` si no es válido) y `function RazonContraste(A, B: TColor): Double` (fórmula WCAG de luminancia relativa).
  - `TIconos.Lista: TVirtualImageList` (24 px) e `function IndiceIcono(const Nombre: string): Integer` con los nombres: `inicio, archivo, traslados, prestamos, gestion, buscar, agregar, editar, archivos, topografia, eliminar, usuario, mas, abajo, derecha`. Nombre desconocido lanza `EArgumentException`.

- [ ] **Step 1: Escribir las pruebas que fallan** en `TPruebasTema` (sin VCL de formularios):
  - `ColorDeHex_ValoresDeLaMaqueta`: `'#1d5fa6'` se convierte en el `TColor` con R=29, G=95, B=166 (en BGR), y `'1d5fa6'`, `'#12'` y `''` lanzan.
  - `RazonContraste_BlancoSobreNegro_Es21` y `RazonContraste_MismoColor_Es1`.
  - `TemaClaro_Contrastes`: `Texto/Fondo >= 4.5`, `Texto/Superficie >= 4.5`, `TextoSobreAcento/Acento >= 4.5`, `Acento/Superficie >= 3.0`.
  - `TemaOscuro_Contrastes`: las mismas cuatro comprobaciones.
- [ ] **Step 2: Compilar y ejecutar.** Esperado: no compila (`UTema` no existe).
- [ ] **Step 3: Implementar `UTema.pas`.** Las constantes salen de la maqueta publicada; si una comprobación de contraste falla, ajustar el valor oscuro/claro hasta cumplirlo y anotarlo en el código.
- [ ] **Step 4: Ejecutar.** Esperado: pasan.
- [ ] **Step 5: Exportar los iconos.** Con las herramientas Tabler (`tabler_export_icons`), exportar a PNG de 24 px, trazo 1.75, color neutro oscuro y una variante blanca para la columna lateral, los iconos de la lista de arriba (equivalencias Tabler sugeridas: `home, folder, arrows-exchange, clipboard-text, adjustments, search, plus, pencil, files, map-pin, trash, user, dots, chevron-down, chevron-right`) en `Iconos/`.
- [ ] **Step 6: Implementar `UIconos.pas`:** `Iconos.rc` con una entrada `RCDATA` por PNG; `UIconos` los carga en un `TImageCollection` y expone `IndiceIcono`. Agregar `{$R Iconos.res}` (compilado con `brcc32`) y registrar las unidades.
- [ ] **Step 7: Compilar el proyecto principal** (`scripts/compilar.ps1 ArchiGenioPro.dproj`). Esperado: sin errores nuevos.
- [ ] **Step 8: Commit por nombre**, con autorización.

### Task 3: Shell de la variante A sobre `TMAIN`

**Files:**
- Create: `UShellPrincipal.pas`
- Modify: `UMAINFORM.pas` (llamada en `FormShow`, junto a `AgregarMenuBusqueda`), `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: `UTema` y `UIconos` (Tarea 2); `TMAIN.pMainContainer`, `nbMain`, `tvTree`, `PContainer`, `PMTool`, los `btn*` de la barra actual.
- Produces:
  - `procedure AplicarShell(Main: TForm)` en `UShellPrincipal`: sin efecto si existe `shell_clasico.flag` junto al ejecutable.
  - `function ShellActivo: Boolean`.
  - Eventos que `TMAIN` conecta: `OnAgregarDocumento`, `OnBuscar(const Texto: string; Ambito: TAmbitoBusqueda)`, `OnSeccion(const Nombre: string)`.

Esta tarea es de interfaz y no tiene pruebas automáticas; el control es la lista de verificación manual (Step 5).

- [ ] **Step 1: Escribir `docs/superpowers/plans/2026-11-04-verificacion-fase1.md`** con los casos: shell nuevo y clásico (con y sin `shell_clasico.flag`), cada botón antiguo accesible desde su nuevo lugar, roles Administrador/Gestor/Director/Visor (los botones antes ocultos siguen ocultos), 1366x768 y escala 125%, tema claro y oscuro de Windows, y los flujos «agregar» y «buscar» de punta a punta.
- [ ] **Step 2: Implementar `UShellPrincipal.AplicarShell`**: (a) columna alLeft de 58 px con botones Inicio, Archivo, Traslados, Préstamos y, abajo, Gestión, con el icono blanco de `UIconos`; (b) `nbMain` reducido a ~270 px y rotulado «Mi área»; (c) en `pMainContainer`, dejar el ancho para el breadcrumb y poner a la derecha el buscador, el selector de ámbito (Task 4), «Agregar documento» y el usuario; (d) mover los botones antiguos de `pMainContainer` (cerrar, autenticar, usuarios, listas, impresión, recuperación, árbol, herramientas, panel) al menú «Gestión» **sin cambiar su `Name`, `Caption` ni `OnClick`** para que `SetMenuSecurity` y los eventos sigan funcionando; (e) aplicar `TemaClaro`/`TemaOscuro` según el tema de Windows a los paneles propios, no a los controles DevExpress.
- [ ] **Step 3: Conectar en `UMAINFORM.pas.FormShow`** la llamada `AplicarShell(Self)` y las tres respuestas a eventos (usar `AbrirBusquedaDocumentos` ya existente para `OnBuscar` hasta la Tarea 4; `OnAgregarDocumento` abre el flujo actual de alta en el nodo y subserie elegidos). Quitar el ítem «Buscar documentos» de `PMTool` cuando el shell esté activo.
- [ ] **Step 4: Compilar** (`scripts/compilar.ps1 ArchiGenioPro.dproj`). Esperado: sin errores nuevos.
- [ ] **Step 5: Ejecutar la lista del Step 1** con la aplicación real y anotar el resultado.
- [ ] **Step 6: Commit por nombre** (con el procedimiento de subir solo líneas propias de `UMAINFORM.pas`), con autorización.

### Task 4: Buscador de la barra superior con selector de ámbito

**Files:**
- Modify: `UShellPrincipal.pas`, `UBusquedaDocumentos.pas`, `UMAINFORM.pas`

**Interfaces:**
- Consumes: Task 1 (`TAmbitoBusqueda`, `IdsNodo`, `NodosDelAmbito`, columna `Acceso`); Task 3 (eventos y barra).
- Produces: `TfrmBusquedaDocumentos.Abrir(const Texto: string; Ambito: TAmbitoBusqueda; const Nodo: TClaveNodo; TieneNodo: Boolean)`; el selector de ámbito de la barra con dos opciones visibles a la vez, «Todo el archivo» y «Solo en A.4.3 …» (el nombre del nodo actual), y un recordatorio de la última elección por sesión.

- [ ] **Step 1: Ampliar la lista del Task 3 con los casos de búsqueda**: ámbito general como EGD, como usuario con una subserie y como usuario sin asignaciones; ámbito nodo actual en un nodo propio y en uno ajeno; nodo actual sin nodo elegido; resultado público de un nodo que no se ve en el árbol; columna «Acceso» con la etiqueta «Pública» para lo que está fuera del alcance.
- [ ] **Step 2: Modificar `UBusquedaDocumentos.pas`:** el selector de ámbito reemplaza al combo actual de «todas»; con «Solo en el nodo» deshabilitado y con aviso cuando el árbol no tiene nodo elegido (nunca cae en silencio a «general»); la lista incorpora la columna «Acceso» y muestra la ruta del nodo como texto.
- [ ] **Step 3: Conectar la barra** (`OnBuscar`): Enter en el cuadro abre la pantalla de resultados con el texto y el ámbito elegidos; se recuerda el ámbito en una variable de unidad durante la sesión.
- [ ] **Step 4: Doble clic en un resultado:** si el nodo es visible en el árbol del usuario, seleccionarlo; si no (documento público de un nodo ajeno), mostrar sus datos y su ruta sin tocar el árbol. Reutilizar la rutina de selección de nodos existente en `UMAINFORM.pas`; si no hay una reutilizable, mostrar solo la ruta y anotarlo como pendiente.
- [ ] **Step 5: Compilar y ejecutar la lista** con tres usuarios (administrador, `egd_a43`, `usr_sub`) contra la base de pruebas y la copia de Access. Anotar el resultado.
- [ ] **Step 6: Commit por nombre**, con autorización.

### Task 5: Splash y «Acerca de» con la nueva apariencia

**Files:**
- Modify: `USplash.dfm`, `USplash.pas`, `UAbout.dfm`, `UAbout.pas`

- [ ] **Step 1: Inventariar** qué controles de cada formulario son visuales (imágenes, etiquetas, barra de progreso) y cuáles son de la protección (`mxProtector`, `CBIOSInfo`, `CProcessorInfo`, `CDiskDriveInfo`, `IdHash*`). Solo los visuales se tocan.
- [ ] **Step 2: Rediseñar con los tokens de `UTema`:** fondo y acento del tema, el nombre «ArchiGenio», la versión y compilación existentes (`VersionProgram`, `buildprogram`), una barra de progreso con el acento; «Acerca de» con versión, edición (`VERSION`), licencia y soporte. Los `.dfm` de estos dos formularios están en texto; editar propiedades sin cambiar la estructura `object`/`end`.
- [ ] **Step 3: Compilar y abrir ambas pantallas** (arranque y menú Ayuda → Acerca de) en claro y oscuro. Esperado: sin errores; la validación de licencia y el arranque no cambian.
- [ ] **Step 4: Commit por nombre**, con autorización.

### Task 6: Pantalla de inicio y prueba corta con usuarios

**Files:**
- Modify: `UShellPrincipal.pas`; Create: `docs/superpowers/plans/2026-11-04-prueba-usuarios-fase1.md`

- [ ] **Step 1: Pantalla de inicio mínima:** cuando no hay nodo elegido, el área de trabajo muestra dos acciones grandes, «Agregar un documento» y «Buscar un documento», y un texto guía de una línea sobre elegir su área en el árbol. «Mis pendientes» y «recientes» quedan para la Fase 5 (necesitan datos que aún no existen).
- [ ] **Step 2: Escribir la prueba corta** (spec, medida de éxito): con 3 a 5 usuarios nuevos y una explicación de unos minutos, cada uno agrega un documento y encuentra otro por un metadato sin ayuda. Registrar tiempo y dudas.
- [ ] **Step 3: Ejecutarla** y anotar los resultados; las conclusiones alimentan la Fase 3.
- [ ] **Step 4: Commit por nombre**, con autorización.

---

## Autorrevisión

- **Cobertura de las decisiones del dueño:** variante A con buscador arriba (Tareas 3 y 4); búsqueda en todos los nodos con solo públicas fuera de permiso (Tarea 1 y el filtro de alcance que no se toca); ámbito explícito general o nodo actual (Tareas 1 y 4); permisos (restricción `AND` sobre `FiltroDocumentos`, pruebas por usuario).
- **Fase 1 de la especificación:** sistema de diseño e iconos (Tarea 2), shell (Tarea 3), splash y about (Tarea 5), pantalla de inicio por tareas en su parte de la Fase 1 (Tarea 6), medida de éxito (Tarea 6). Queda para la Fase 5: «Mis pendientes», recientes y tablero.
- **Riesgo mayor:** la Tarea 3, por mover botones con permisos en un formulario de más de 10.000 líneas sin pruebas automáticas; por eso va tras un `shell_clasico.flag` y una lista de verificación manual con roles.
- **Fuera de este plan:** vistas guardadas, autocompletado y vista previa de la búsqueda (Fase 4 ampliada), calendario de conservación y notificaciones (Fase 5).
- **Dato a confirmar con el dueño:** si el modo Access (un solo usuario) debe mostrar el mismo selector de ámbito (hoy no tiene alcance, pero sí árbol).
