# Rediseño de ArchiGenio — Plan maestro

> **Para quien ejecute:** SUB-SKILL REQUERIDO: usar superpowers:subagent-driven-development (recomendado) o superpowers:executing-plans para implementar este plan tarea por tarea. Los pasos usan casillas `- [ ]`.

**Objetivo:** que un usuario nuevo trabaje con poca capacitación: interfaz simple basada en el árbol de departamentos, seguridad por alcance (solo SQL Server) y búsqueda integrada por metadatos.

**Arquitectura:** la lógica de alcance (quién ve y hace qué) se escribe como unidades Delphi puras, sin VCL ni FireDAC, para poder probarlas con DUnitX. Un único punto genera el filtro SQL que usan el árbol y la búsqueda. La interfaz nueva se construye encima de esas unidades, pantalla por pantalla, sin tocar el motor de datos.

**Stack:** Delphi 10.3 (RAD Studio `20.0`), VCL, DevExpress 19.1 (`RS26`), TMS, FastReport, JVCL, FireDAC (SQL Server y Access), DUnitX.

**Spec:** `docs/superpowers/specs/2026-10-29-rediseno-archigenio-design.md`

## Alcance de este documento

El diseño cubre seis fases independientes. Este plan maestro fija el orden, las dependencias y los entregables de todas, y **detalla por tareas solo la Fase 0 y la Fase 2 (núcleo y datos)**, porque son la base de las demás y se pueden probar sin interfaz. Cada fase restante se detalla en su propio plan cuando le toque, con las maquetas ya decididas. Hacerlo así evita planificar pantallas que todavía no se han elegido.

## Restricciones globales

- Delphi 10.3 (`C:\Program Files (x86)\Embarcadero\Studio\20.0\bin\rsvars.bat`), plataforma Win32, configuración Debug por defecto.
- Motor de producción: SQL Server (base de desarrollo local `SGDDRHMAIN`, cuenta técnica `geoconn`). Access sigue funcionando en modo un solo usuario, **sin seguridad por alcance**.
- Los archivos fuente están en ANSI/Windows-1252: conservar la codificación y no normalizar a UTF-8.
- Toda unidad nueva se agrega a la cláusula `uses` de `ArchiGenioPro.dpr` con la forma `UFoo in 'UFoo.pas'`.
- Los cambios de esquema van en `TUDM.UpDateDB` (`UCapaDatos.pas`), con `execSQLUPD` (silencioso si ya existe), son aditivos y no pueden hacer fallar a un ejecutable antiguo.
- Las pruebas de integración **nunca** apuntan por defecto a `SGDDRHMAIN`: leen el nombre de la base desde la variable de entorno `ARCHIGENIO_TEST_DB`, y sin ella se omiten.
- No hacer `git commit` sin autorización del dueño del producto. El árbol de trabajo tiene borrados pendientes ajenos a este trabajo: añadir archivos por nombre, nunca `git add -A` ni `git add .`.
- La clave de un nodo es `(IdEstructura, id)`. `id` solo no es único (160 se repite 3 veces).
- Roles por nodo y acciones permitidas, tal como fija el spec:

| Rol | Alcance | Acciones |
|---|---|---|
| Administrador | todo | ver, agregar, editar |
| EGD (Especialista de Gestión Documental) | su nodo, sin hijos | ver, agregar, editar, eliminar, prestar, transferir, depurar, asignar usuarios a subseries de su nodo |
| Director | su nodo y todos los hijos, todas las subseries | ver, agregar, editar (decisión mía) |
| Usuario | solo las subseries asignadas dentro de su nodo | ver, agregar, editar |
| Visor | nada propio | ver (solo público) |

- Documentos con acceso `Pública` (`cl_acceso.Idacceso = 1`) los ve cualquier usuario autenticado. `Restringida` (2) y `Secreta` (3) solo quien tenga cobertura. Un valor nulo o fuera de 1–3 se trata como no público.
- Un usuario sin ninguna asignación se comporta como Visor.
- El filtro de seguridad cubre únicamente el árbol y la búsqueda. Préstamos, transferencias, depuración y reportes no se filtran en este proyecto.

## Puntos de revisión (casos que la especificación no nombra y que más pueden fallar)

1. **Dos nodos con el mismo `id`** (160 en A.1.7, A.3.3 y A.4.6): los permisos de uno no pueden aplicar al otro. Prueba en Tarea 2.
2. **Claves con mayúsculas o espacios** (`a.1.4`, `A.1.6 `): `A.1.6` y `A.1.6 ` son el mismo nodo. Prueba en Tarea 2.
3. **Padre inexistente o ambiguo** (por ejemplo `A.6..3.3`): sin herencia hacia ese nodo, nunca acceso de más. Prueba en Tarea 2.
4. **Usuario sin asignaciones**: solo lo público, sin errores. Prueba en Tarea 3.
5. **Subserie con acceso nulo o inválido**: se trata como no pública. Prueba en Tarea 3.

---

## Hoja de ruta

| Fase | Entregable | Depende de | Detalle | Estado (2026-11-04) |
|---|---|---|---|---|
| 0. Red de seguridad | Proyecto de pruebas DUnitX que compila y corre; script de compilación | — | Tarea 1 (abajo) | Hecha: `Pruebas/` y `scripts/compilar.ps1` |
| 1. Base visual | Sistema de diseño (colores, tipografía, iconos Tabler), shell principal, splash, about | 0; variante de pantalla principal elegida: **A** con el buscador arriba (2026-11-04) | `2026-11-04-fase1-base-visual.md` | Plan aprobado; sin empezar |
| 2. Seguridad por alcance | Núcleo de reglas, tablas nuevas, filtro SQL único, integración en login, árbol filtrado; pantallas "Permisos de mi área" y asignación de EGD | 0 (núcleo y datos); 1 (pantallas) | Tareas 2–6 (abajo) y plan propio para pantallas | Núcleo, tablas, filtro SQL, login, árbol filtrado y asignación de EGD hechos. Falta la pantalla «Permisos de mi área» (no existe en el código) y ejecutar la lista manual `2026-10-29-verificacion-alcance.md` |
| 3. Agregar documentos | Flujo guiado en el contexto de nodo y subserie | 1, 2 | Plan propio | Sin plan |
| 4. Búsqueda integrada | Caja de texto libre y filtros dinámicos desde `cl_VarSubserie` sobre las tablas `md_*`, dentro del alcance | 2 | `2026-11-04-busqueda-integrada.md` | Hecha y en `main`; lista manual `2026-11-04-verificacion-busqueda.md` pendiente de ejecutar. El ámbito general / nodo actual se añade en la Fase 1 |
| 5. Resto de pantallas | Clasificadores, préstamos, transferencias y administración reorganizados; refactor de las pantallas que se toquen | 1 | Plan propio | Sin plan |
| 6. Ayuda y documentación | Ayuda actualizada, documentación de las unidades tocadas | todas | Plan propio | Sin plan |

La refactorización se hace pantalla por pantalla dentro de cada fase, no como proyecto aparte.

### Funcionalidades ampliadas por fase

El spec (secciones 13 y 14) incorpora las funcionalidades del estudio del arte. Esta es su distribución, y cada una se detalla en el plan de su fase:

- **Fase 1:** inicio por tareas (estructura de la pantalla), ayuda dentro de la pantalla (mecanismo común: textos guía y recorrido inicial).
- **Fase 2:** vinculación opcional a Active Directory (columna `usuario_ad` en `cl_Resp_Gest_Arch`; el login del sistema sigue siendo el principal).
- **Fase 3:** arrastrar y soltar, metadatos precompletados y plantilla por subserie.
- **Fase 4:** autocompletado, resaltado y vista previa; vistas guardadas, recientes y favoritos; solicitud de acceso desde un resultado restringido.
- **Fase 5:** calendario de conservación con revisión del EGD, actas con firma, instrumentos de descripción, notificaciones internas, historial por documento, tablero del EGD y datos de "Mis pendientes". Aquí se evalúa también la firma electrónica.
- **Fase 6:** respaldo y API programados, ayuda final y documentación.
- **Diseño de base de datos ya, implementación después:** captura masiva y carpeta vigilada (esquema en el spec, sección 14, sin pantallas ni procesos).
- **Condicionada:** sugerencia automática de subserie y metadatos, tras evaluar el volumen al terminar la fase 4.
- **Fuera de alcance:** OCR y bloqueo legal.

### Tabla de esquema para la Tarea 4

Las tablas nuevas de la sección 14 del spec no se crean todas en la Tarea 4 (que solo crea las del alcance de seguridad). Cada fase crea las suyas en su propio plan con el mismo patrón de `UpDateDB`, salvo las de captura masiva, que se crean en la Fase 2 junto con las de seguridad para dejar el esquema listo: `tb_lote_captura`, `tb_lote_captura_item` y `tb_regla_carpeta`.

---

## Fase 0 — Red de seguridad

### Tarea 1: Proyecto de pruebas y script de compilación

**Archivos:**
- Crear: `Pruebas/PruebasArchiGenio.dpr`, `Pruebas/PruebasArchiGenio.dproj`
- Crear: `scripts/compilar.ps1`
- Referencia a copiar: `C:\SISTEMA\cc_ws\ArchiDiag\tests\ArchiGenio.Tests.dpr` y su `.dproj` (mismo DUnitX; ruta `$(BDS)\source\DUnitX`)

**Interfaces:**
- Produce: `scripts/compilar.ps1 -Proyecto <ruta .dproj> [-Config Debug]` que llama a `rsvars.bat` y `msbuild`, y devuelve código de salida distinto de cero si falla.
- Produce: ejecutable `Pruebas/Win32/Debug/PruebasArchiGenio.exe` que acepta la variable `ARCHIGENIO_TEST_DB`.

- [ ] **Paso 1:** Verificar que el proyecto principal compila antes de tocar nada: `powershell -File scripts/compilar.ps1 -Proyecto ArchiGenioPro.dproj`. Esperado: sin errores. Anotar en el resumen el número de advertencias como línea base. Si falla por un paquete no instalado, detenerse y avisar al dueño.
- [ ] **Paso 2:** Crear `Pruebas/PruebasArchiGenio.dpr` como consola DUnitX con `{$STRONGLINKTYPES ON}`, un corredor con registro en consola y salida NUnit XML, y `UnitSearchPath` que incluya la carpeta raíz del repositorio y `$(BDS)\source\DUnitX`. Debe terminar con código de salida distinto de cero si alguna prueba falla.
- [ ] **Paso 3:** Escribir `Pruebas/UPruebaHumo.pas` con la clase `TPruebaHumo` y un caso `CompilaYCorre` que haga `Assert.IsTrue(True)`.
- [ ] **Paso 4:** Compilar y ejecutar: `scripts/compilar.ps1 -Proyecto Pruebas/PruebasArchiGenio.dproj` y luego `Pruebas/Win32/Debug/PruebasArchiGenio.exe`. Esperado: `Tests Passed: 1`.
- [ ] **Paso 5:** Agregar `Pruebas/Win32/` y `Pruebas/*.dcu` al `.gitignore` y, con autorización del dueño, hacer commit de los archivos nuevos por nombre.

---

## Fase 2 — Seguridad por alcance (núcleo y datos)

Estas tareas no tocan ninguna pantalla. Se ejecutan después de la Tarea 1.

### Tarea 2: Reglas puras de acción y árbol de nodos

**Archivos:**
- Crear: `UAlcance.pas` (sin dependencias de VCL ni FireDAC)
- Crear: `Pruebas/UPruebasAlcance.pas`
- Modificar: `Pruebas/PruebasArchiGenio.dpr` (agregar la unidad de pruebas)

**Interfaces:**
- Produce, en `UAlcance.pas`:
  - `TRolNodo = (rnVisor, rnUsuario, rnDirector, rnEGD, rnAdministrador)`
  - `TAccion = (acVer, acAgregar, acEditar, acEliminar, acPrestar, acTransferir, acDepurar, acAsignarUsuarios)`
  - `TClaveNodo = record IdEstructura: string; Id: Integer; end`
  - `function NormalizaClave(const S: string): string` (recorta espacios y pasa a mayúsculas)
  - `function RolPermite(Rol: TRolNodo; Accion: TAccion): Boolean`
  - `TArbolNodos = class` con `procedure Agregar(const Nodo: TClaveNodo; PadreId: Integer)`, `function Contiene(const Nodo: TClaveNodo): Boolean`, `function EsDescendiente(const Raiz, Nodo: TClaveNodo): Boolean` (verdadero también si son el mismo nodo), `function Ancestros(const Nodo: TClaveNodo): TArray<TClaveNodo>`.
- Regla del padre: se resuelve por `PadreId`. Si varios nodos comparten ese `id`, el padre es el que cumpla que su `IdEstructura` normalizado más `.` sea prefijo del `IdEstructura` normalizado del hijo. Si ninguno cumple o no existe, el nodo queda sin padre (sin herencia).

- [ ] **Paso 1:** Escribir las pruebas en `TPruebasReglas` y `TPruebasArbol`:
  - `RolPermite_Visor_SoloVer`: Visor solo `acVer`.
  - `RolPermite_Usuario_VerAgregarEditar`: Usuario y Director y Administrador permiten exactamente `acVer`, `acAgregar`, `acEditar` y niegan las otras cinco.
  - `RolPermite_EGD_Todo`: EGD permite las ocho acciones.
  - `NormalizaClave_MinusculasYEspacios`: `NormalizaClave('a.1.6 ') = 'A.1.6'`.
  - `Arbol_Descendiente_HijosYNietos`: con A(1) ← A.4(101) ← A.4.3(104), `EsDescendiente(A.4, A.4.3)` es verdadero y `EsDescendiente(A.4.3, A.4)` es falso.
  - `Arbol_IdDuplicado_NoMezcla` (punto de revisión 1): con A.1(82), A.3(92), A.4(101) bajo A(1), y hojas A.1.7, A.3.3, A.4.6 las tres con `id` 160 y padres 82, 92 y 101, `EsDescendiente(A.4, A.1.7)` es falso y `EsDescendiente(A.1, A.1.7)` es verdadero.
  - `Arbol_ClaveConEspacio_EsMismoNodo` (punto 2): `Contiene` con `'A.1.6 '` y con `'a.1.6'` es verdadero si se agregó `'A.1.6'`.
  - `Arbol_PadreInexistente_SinHerencia` (punto 3): un nodo `A.6..3.3` con `PadreId = 999` no es descendiente de A ni de A.6, y `Ancestros` devuelve vacío.
- [ ] **Paso 2:** Compilar y ejecutar las pruebas. Esperado: FALLAN porque `UAlcance` no existe.
- [ ] **Paso 3:** Implementar `UAlcance.pas` con las firmas de Interfaces. Para `TArbolNodos`, guardar los nodos con clave normalizada y calcular el padre en `Agregar` o de forma perezosa en la primera consulta, para que el orden de inserción no importe.
- [ ] **Paso 4:** Compilar y ejecutar. Esperado: todas pasan.
- [ ] **Paso 5:** Agregar `UAlcance.pas` a `Pruebas/PruebasArchiGenio.dpr` y, con autorización, hacer commit por nombre.

### Tarea 3: Resolución de alcance de un usuario

**Archivos:**
- Modificar: `UAlcance.pas`
- Modificar: `Pruebas/UPruebasAlcance.pas`

**Interfaces:**
- Consume: Tarea 2 (`TRolNodo`, `TAccion`, `TClaveNodo`, `TArbolNodos`, `RolPermite`).
- Produce, en `UAlcance.pas`:
  - `TAsignacionNodo = record Nodo: TClaveNodo; Rol: TRolNodo; end` (para Director y EGD)
  - `TSubserieAsignada = record Nodo: TClaveNodo; CodSubs: string; end`
  - `TAlcanceUsuario = class` con constructor `Create(EsAdministrador: Boolean; Arbol: TArbolNodos; const Nodos: TArray<TAsignacionNodo>; const Subseries: TArray<TSubserieAsignada>; const SubseriesPublicas: TArray<string>)`
  - `function PuedeVerDocumento(const Nodo: TClaveNodo; const CodSubs: string; NivelAcceso: Integer): Boolean`
  - `function PuedeRealizar(Accion: TAccion; const Nodo: TClaveNodo; const CodSubs: string): Boolean`
  - `function NodosVisibles: TArray<TClaveNodo>` (nodos cubiertos más sus ancestros, para dibujar el árbol)
  - `function NodosCompletos: TArray<TClaveNodo>` (nodos donde ve todas las subseries: administrador no aplica, director con hijos, EGD sin hijos)
- Reglas: Director cubre su nodo y descendientes con todas las subseries (`acVer`, `acAgregar`, `acEditar`). EGD cubre solo su nodo con todas las subseries y las ocho acciones. Usuario cubre solo los pares `(nodo, subserie)` asignados. Los permisos de varios roles se unen. `NivelAcceso = 1` es público: `PuedeVerDocumento` es verdadero para cualquier usuario, pero `PuedeRealizar` sigue exigiendo cobertura. Administrador ve todo y su única acción es lo que dice `RolPermite(rnAdministrador, ...)`.

- [ ] **Paso 1:** Escribir pruebas en `TPruebasAlcance` con el árbol A ← A.4 ← A.4.3 (y A.1):
  - `Director_VeHijos`: director de A.4 ve un documento no público del nodo A.4.3 y no el de A.1.
  - `EGD_NoDesciende`: EGD de A.4 ve A.4 y no A.4.3.
  - `EGD_PuedeEliminarEnSuNodo` y `Usuario_NoPuedeEliminar`.
  - `Usuario_SoloSubserieAsignada`: usuario con `(A.4.3, '014001')` ve documentos de esa subserie en A.4.3 y no los de `'074'` en A.4.3 ni los de `'014001'` en A.1.
  - `Publico_LoVeCualquiera`: nivel 1 visible desde cualquier nodo, incluso para un Visor.
  - `Publico_NoDaPermisoDeEditar`: sobre un documento público de otro nodo, `PuedeRealizar(acEditar, ...)` es falso.
  - `SinAsignaciones_SoloPublico` (punto de revisión 4): ni error ni acceso a nivel 2 o 3, y `NodosVisibles` vacío.
  - `AccesoInvalido_NoEsPublico` (punto 5): `NivelAcceso` 0, 4 y -1 se tratan como no público.
  - `Administrador_VeTodo`.
  - `VariosRoles_SeUnen`: usuario que es director de A.1 y usuario en `(A.4.3, '014001')` ve ambos.
  - `NodosVisibles_IncluyeAncestros`: para el usuario con `(A.4.3, ...)`, `NodosVisibles` contiene A, A.4 y A.4.3.
- [ ] **Paso 2:** Ejecutar. Esperado: FALLAN (clases no definidas).
- [ ] **Paso 3:** Implementar `TAlcanceUsuario` en `UAlcance.pas`.
- [ ] **Paso 4:** Ejecutar. Esperado: todas pasan, incluidas las de la Tarea 2.
- [ ] **Paso 5:** Commit por nombre, con autorización.

### Tarea 4: Tablas nuevas en `UpDateDB`

**Archivos:**
- Modificar: `UCapaDatos.pas` (procedimiento `TUDM.UpDateDB`, a partir de la línea 5371; seguir el patrón de `tb_tree_directors` cerca de la línea 5461)
- Crear: `Pruebas/UPruebasEsquema.pas`
- Crear: `SCRIPTS/alcance_tablas.sql` (copia documental del DDL)

**Interfaces:**
- Produce las tablas (SQL Server; en Access con tipos equivalentes `TEXT`/`LONG`):
  - `tb_nodo_egd (IdEstructura VARCHAR(50) NOT NULL, id INT NOT NULL, user_id VARCHAR(100) NOT NULL, PK (IdEstructura, id))`, FK a `tb_tree(IdEstructura, id)` y a `tb_user(nombreuser)`. La clave primaria impide dos EGD en un nodo.
  - `tb_usuario_subserie (IdEstructura VARCHAR(50) NOT NULL, id INT NOT NULL, codsubs VARCHAR(50) NOT NULL, user_id VARCHAR(100) NOT NULL, PK (IdEstructura, id, codsubs, user_id))`, FK a `tb_tree` y a `tb_user`.
- Reutiliza `tb_tree_directors` tal como está.
- Esquema de captura masiva, sin uso todavía (spec, sección 14): `tb_lote_captura`, `tb_lote_captura_item`, `tb_regla_carpeta`, con las columnas allí indicadas y sin claves foráneas hacia tablas de documentos.
- Columna `usuario_ad VARCHAR(256) NULL` en `cl_Resp_Gest_Arch` (vinculación opcional a Active Directory), agregada con `ALTER TABLE` silencioso si ya existe.
- La prueba `TablasExisten` también comprueba estas tres tablas y la columna.

- [ ] **Paso 1:** Escribir `TPruebasEsquema.TablasExisten`: conecta con la base de `ARCHIGENIO_TEST_DB` (omitir la prueba si la variable no está), llama a `UpDateDB` y comprueba con `INFORMATION_SCHEMA.TABLES` que existen `tb_nodo_egd` y `tb_usuario_subserie`. Y `NodoNoAdmiteDosEGD`: insertar dos filas para el mismo nodo debe lanzar excepción.
- [ ] **Paso 2:** Ejecutar contra una base de pruebas creada como copia de `SGDDRHMAIN` (por ejemplo con `BACKUP`/`RESTORE`). Esperado: FALLAN.
- [ ] **Paso 3:** Agregar los `CREATE TABLE` en `UpDateDB` con `execSQLUPD`, solo cuando sea necesario según `TBD`: la versión SQL Server si `TBD = 'S'`, y la de Access en la rama contraria. Copiar el mismo DDL en `SCRIPTS/alcance_tablas.sql`.
- [ ] **Paso 4:** Ejecutar las pruebas. Esperado: pasan. Repetir contra una copia de una base Access y confirmar que las tablas se crean vacías y que la aplicación abre sin error.
- [ ] **Paso 5:** Comprobar que `UpDateDB` es idempotente: ejecutarlo dos veces seguidas y verificar que no hay error ni filas duplicadas.
- [ ] **Paso 6:** Commit por nombre, con autorización.

### Tarea 5: Cargar el alcance desde la base y generar el filtro SQL único

**Archivos:**
- Crear: `UAlcanceDatos.pas` (usa FireDAC y `UAlcance`)
- Crear: `Pruebas/UPruebasAlcanceDatos.pas`
- Modificar: `ArchiGenioPro.dpr` (agregar `UAlcanceDatos in 'UAlcanceDatos.pas'`)

**Interfaces:**
- Consume: Tareas 2, 3 y 4.
- Produce, en `UAlcanceDatos.pas`:
  - `function CargarAlcance(Conn: TFDConnection; const Usuario: string; EsAdministrador: Boolean): TAlcanceUsuario`: lee `tb_tree` (clave y `padre`), `tb_tree_directors`, `tb_nodo_egd`, `tb_usuario_subserie` y las subseries con `cl_subseries.acceso = 1` (públicas).
  - `TFiltroSql = record Condicion: string; Parametros: TArray<TParametroSql>; end` y `TParametroSql = record Nombre: string; Valor: Variant; end`
  - `function FiltroDocumentos(Alcance: TAlcanceUsuario; const AliasDocumentos: string): TFiltroSql`: devuelve una condición parametrizada para `tb_SeriesDatos` (columnas `IdEstructura`, `id`, `codsubs`). Si `Alcance = nil` (modo Access) o es administrador, la condición es `1=1`. Sin cobertura alguna, solo las subseries públicas. La condición es válida en SQL Server y en Access.
  - `function FiltroNodosArbol(Alcance: TAlcanceUsuario; const AliasArbol: string): TFiltroSql`: restringe `tb_tree` a `NodosVisibles`.

- [ ] **Paso 1:** Escribir pruebas contra la base de pruebas (omitir sin `ARCHIGENIO_TEST_DB`): crear usuarios y asignaciones de ejemplo en transacción con rollback y comprobar el número de filas de `tb_SeriesDatos` que devuelve `FiltroDocumentos` para: administrador (todas), director de `A.4.3` (las de ese nodo), usuario con `('A.4.3', '014001')` (solo esa subserie más las públicas), usuario sin asignaciones (solo públicas), y `Alcance = nil` (todas). Añadir `FiltroDocumentos_ApostrofeEnCodigo`: un `codsubs` con apóstrofe no rompe la consulta ni inyecta SQL, porque se pasa como parámetro.
- [ ] **Paso 2:** Ejecutar. Esperado: FALLAN.
- [ ] **Paso 3:** Implementar `CargarAlcance`, `FiltroDocumentos` y `FiltroNodosArbol`. Construir la condición con pares `(IdEstructura, codsubs)` como parámetros y listas `IN` para los nodos completos.
- [ ] **Paso 4:** Ejecutar. Esperado: pasan. Repetir con una base Access para confirmar que `Alcance = nil` produce `1=1` y que la consulta se ejecuta.
- [ ] **Paso 5:** Commit por nombre, con autorización.

### Tarea 6: Integrar en el inicio de sesión y filtrar el árbol y la lista de documentos

**Archivos:**
- Modificar: `UCapaDatos.pas` (agregar el campo público `Alcance: TAlcanceUsuario` en `TUDM`; liberarlo al destruir)
- Modificar: `UAutentica.pas` (tras `UDM.Rol := Security.GetRol(...)`, línea 139)
- Modificar: `UMAINFORM.pas` (consulta de documentos alrededor de la línea 6478; carga del árbol alrededor de la línea 4570 y `UDM.tb_tree`)

**Interfaces:**
- Consume: Tarea 5 (`CargarAlcance`, `FiltroDocumentos`, `FiltroNodosArbol`).
- Produce: `UDM.Alcance` cargado tras el login en modo SQL Server; `nil` en modo Access.

- [ ] **Paso 1:** Escribir la lista de verificación manual en `docs/superpowers/plans/2026-10-29-verificacion-alcance.md`: con tres usuarios de ejemplo (administrador, EGD de `A.4.3`, usuario con una subserie) iniciar sesión y registrar qué nodos y documentos se ven. Esperado: administrador ve todo; EGD solo `A.4.3` y su ruta; usuario solo su subserie más lo público.
- [ ] **Paso 2:** En `UAutentica.pas`, tras un login correcto, asignar `UDM.Alcance` con `CargarAlcance` cuando `TBD = 'S'`, y dejarlo en `nil` en modo Access. El administrador (rol `Administrador`) se carga con `EsAdministrador = True`.
- [ ] **Paso 3:** En `UMAINFORM.pas`, aplicar `FiltroNodosArbol` a la consulta de `tb_tree` y `FiltroDocumentos` a la consulta de documentos, usando parámetros. No cambiar nada más de esas rutinas.
- [ ] **Paso 4:** Compilar el proyecto completo con `scripts/compilar.ps1`. Esperado: sin errores nuevos respecto a la línea base de la Tarea 1.
- [ ] **Paso 5:** Ejecutar la lista de verificación del Paso 1 con la aplicación real contra la base de pruebas y anotar el resultado. Comprobar además que el modo Access abre y muestra todo su árbol.
- [ ] **Paso 6:** Commit por nombre, con autorización.

---

## Fases 1, 3, 4, 5 y 6 — condiciones de entrada

- **Fase 1:** antes de construir el shell, rehacer las maquetas de pantalla principal incluyendo el árbol y decidir la variante con el dueño del producto. Incluye una prueba corta con usuarios nuevos (medida de éxito del spec).
- **Fase 2 (pantallas):** "Permisos de mi área" para el EGD (asignar usuarios a subseries de su nodo) y asignación de EGD y directores por nodo para el administrador, con vía de acceso desde el primer arranque para que la actualización no deje al administrador sin acceso.
- **Fase 4:** los filtros se construyen desde `cl_VarSubserie`; la consulta respeta `FiltroDocumentos`. Casos a cubrir en su plan: apóstrofes y `%` en el texto, subserie sin `NombreTablaMetadatos`, tabla `md_*` inexistente o vacía, y diferencias de SQL entre SQL Server y Access.
- **Fases 3, 5 y 6:** se detallan al llegar, con las pantallas ya decididas.
