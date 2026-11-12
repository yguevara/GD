# Procesos archivísticos, F0: base común — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dejar construida la base que comparten Préstamos, Transferencias y Depuración: reglas de pasos, numeración, candado de un-proceso-por-documento, autorización de la Comisión, tablas `prc_*`, acceso a datos y la pantalla base embebida en el shell.

**Architecture:** Reglas en unidades sin VCL ni `TUDM` (RTL + FireDAC como mucho) con pruebas DUnitX en `Pruebas/`; la pantalla base hereda de `TFormClasificadorBase` y se abre con el mismo mecanismo de embebido del shell que los clasificadores. Interruptor `procesos_clasico.flag` para volver a las pantallas viejas. Ninguna pantalla vieja se toca en F0.

**Tech Stack:** Delphi 10.3 VCL, FireDAC (SQL Server y Access), DevExpress `cxGrid`, DUnitX. Comentarios y documentación en español.

**Spec:** `docs/superpowers/specs/2026-11-12-prestamos-transferencias-depuracion-design.md` (secciones 4, 8, 9, 10). Plan maestro: `docs/superpowers/plans/2026-11-12-prestamos-transferencias-depuracion.md`. Maquetas aprobadas: `docs/superpowers/maquetas/2026-11-12-procesos-maqueta.html`.

## Global Constraints

- Unidades sin pantalla en **ASCII** (sin tildes en comentarios ni cadenas); texto visible al usuario con tildes solo en unidades VCL. Fuentes en Windows‑1252 con CRLF: **no reescribir archivos existentes con herramientas que normalicen a UTF‑8** (usar `Edit` solo en archivos ASCII; en `.pas` con tildes, edición por script que conserve codificación).
- SQL válido en SQL Server y Access; DDL idempotente; todo parametrizado. Claves de nodo siempre con `NormalizaClave` (`IdEstructura` tiene irregularidades y `id` no es único).
- Mensajes al usuario solo por `TMensajes`. Cada unidad nueva se agrega a `ArchiGenioPro.dpr` (si tiene `uses` de VCL) y/o a `Pruebas/PruebasArchiGenio.dpr` (si es probable en consola).
- Compilar: `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y `scripts/compilar.ps1 ArchiGenioPro.dproj`; ejecutar `Pruebas\Win32\Debug\PruebasArchiGenio.exe` (código de salida ≠ 0 si falla).
- **Commits:** el árbol tiene cambios previos sin confirmar (`UMAINFORM.pas`, `Win32/Debug/*.dcu`, `ArchiGenioPro.identcache`). No hacer `git add -A`; agregar solo los archivos de la tarea y, en `UMAINFORM.pas`, solo los hunks propios (`git add -p`). Cierre de mensaje: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
- Tablas nuevas de F0 (YAGNI): solo las cuatro comunes (`prc_proceso`, `prc_unidad`, `prc_evento`, `prc_autorizacion`). `prc_prestamo`, `prc_caja`, `prc_incidencia`, `prc_acta_testigo`, `prc_muestra` las agrega cada fase en `UEsquemaProcesos`.

## Review Focus

1. Dos usuarios avanzan el mismo proceso a la vez: el segundo recibe error, no se duplica el avance (actualización condicionada al paso leído).
2. Dos procesos del mismo tipo creados a la vez: números distintos; al cambiar de año el consecutivo vuelve a 1.
3. Documento con `IdEstructura` irregular (`a.1.4`, `A.1.6 `, `A.6..3.3`) y `id` repetido en otros nodos: el candado no confunde ni mezcla documentos.
4. Cancelar una depuración ya ejecutada (o una transferencia ya recibida): se rechaza.
5. Motor Access: sin `IDENTITY`, sin `IF OBJECT_ID`; el DDL y las consultas de F0 no deben fallar al crearse (se prueba contra la copia `.mdb` si existe `ARCHIGENIO_TEST_MDB`).

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `UProceso.pas` (nuevo) | Tipos de proceso, pasos, condiciones y reglas de avance/cancelación. Puro. |
| `UNumeracion.pas` (nuevo) | Formato y lectura de números (`2026-0047`, `T-2026-02`, `D-2026-01`). Puro. |
| `UCandados.pas` (nuevo) | Regla «un documento, un proceso abierto» y clave normalizada de unidad. Puro. |
| `UAutorizacion.pas` (nuevo) | Validación del acta y acuerdo de la Comisión. Puro. |
| `UEsquemaProcesos.pas` (nuevo) + `SCRIPTS/procesos_tablas.sql` | DDL idempotente de `prc_*` y su copia documental. |
| `UProcesosDatos.pas` (nuevo) | Crear, avanzar, cancelar, bitácora, autorización y bloqueos por nodo. FireDAC sin VCL. |
| `UProcesosInterruptor.pas` (nuevo) | `procesos_clasico.flag` y registro de errores. |
| `UProcesoBase.pas` (nuevo, VCL) | Pantalla base: indicadores, pestañas, lista, panel, tira de pasos. |
| `UCapaDatos.pas`, `UMAINFORM.pas`, `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`, `CLAUDE.md` | Enganches mínimos. |
| `Pruebas/UPruebas*.pas` (nuevos) | Una unidad de pruebas por unidad nueva. |

---

### Task 1: Reglas de pasos (`UProceso`)

**Files:**
- Create: `UProceso.pas`, `Pruebas/UPruebasProceso.pas`
- Modify: `Pruebas/PruebasArchiGenio.dpr` (agregar ambas)

**Interfaces:**
- Produces:
  - `TTipoProceso = (tpPrestamo, tpTransferencia, tpDepuracion)`; `TEstadoProceso = (epEnCurso, epFinalizado, epCancelado)`
  - `TCondicion = (cdAutorizado, cdSinBloqueos, cdVerificacionesCompletas, cdRecepcionConfirmada, cdUbicacionCompleta, cdMuestraDefinida, cdTestigosMinimos, cdActaCompleta, cdConfirmacionEscrita)`; `TCondiciones = set of TCondicion`
  - `TTipoArchivo = (taGestion, taCentral, taHistorico, taOtro)`
  - `function NumeroPasos(Tipo: TTipoProceso): Integer` (préstamo 3, transferencia 6, depuración 5)
  - `function CondicionesParaAvanzar(Tipo: TTipoProceso; PasoActual: Integer): TCondiciones`
  - `function PuedeAvanzar(Tipo: TTipoProceso; PasoActual: Integer; Cumplidas: TCondiciones; out Faltan: TCondiciones): Boolean`
  - `function PuedeCancelar(Tipo: TTipoProceso; PasoActual: Integer): Boolean`
  - `function PuedeIniciar(Tipo: TTipoProceso; Rol: TRolNodo; Archivo: TTipoArchivo): Boolean` (usa `RolPermite` de `UAlcance`)
  - `function TipoArchivoDesdeTexto(const Texto: string): TTipoArchivo` (sin distinguir mayúsculas ni tildes: contiene `CENTRAL` → central, `HIST` → histórico, `GESTI` → gestión)

Tabla de avance (valor de `PasoActual` → condiciones exigidas para pasar al siguiente), copiada del diseño:
- Préstamo: 1→2 `{cdSinBloqueos}`; 2→3 `{}`.
- Transferencia: 1→2 `{cdSinBloqueos}`; 2→3 `{cdAutorizado}`; 3→4 `{cdAutorizado, cdSinBloqueos, cdVerificacionesCompletas}`; 4→5 `{}`; 5→6 `{cdRecepcionConfirmada}`; en el paso 6 no se avanza, se finaliza con `{cdUbicacionCompleta}` (`CondicionesParaAvanzar(tpTransferencia, 6)`).
- Depuración: 1→2 `{cdSinBloqueos}`; 2→3 `{cdAutorizado}`; 3→4 `{cdMuestraDefinida, cdTestigosMinimos, cdActaCompleta}`; 4→5 `{cdConfirmacionEscrita, cdSinBloqueos}`; el paso 5 finaliza con `{}`.
- Cancelar: préstamo siempre mientras no esté en el paso 3; transferencia hasta el paso 4 inclusive; depuración hasta el paso 3 inclusive (desde la ejecución es irreversible).
- `PuedeIniciar`: préstamo, `RolPermite(Rol, acPrestar)`; transferencia, `acTransferir` y `Archivo = taGestion`; depuración, `acDepurar` y `Archivo in [taCentral, taHistorico]` (los archivos de gestión no depuran).

- [ ] **Step 1: Escribir las pruebas** en `UPruebasProceso.pas` (fixture `TPruebasProceso`), con estos nombres y aserciones: `NumeroDePasosPorTipo` (3, 6, 5); `PrestamoAvanzaSoloSinBloqueos`; `TransferenciaPaso2ExigeAutorizacion` (`PuedeAvanzar(tpTransferencia,2,[],Faltan)` es False y `Faltan = [cdAutorizado]`); `TransferenciaPaso3ExigeTresCondiciones`; `DepuracionPaso3ExigeMuestraTestigosYActa`; `DepuracionPaso4ExigeConfirmacionEscrita`; `CancelarDepuracionEnEjecucionEsImposible` (`PuedeCancelar(tpDepuracion,4)` False, paso 3 True); `CancelarTransferenciaTrasRecepcionEsImposible` (paso 5 False, paso 4 True); `GestionNoPuedeIniciarDepuracion`; `CentralPuedeIniciarDepuracionSoloConRolEGD` (Visor/Usuario False, EGD True); `AdministradorNoPresta`; `TipoArchivoDesdeTexto` con `'Gesti'#243'n'`, `'Archivo Central'`, `'Hist'#243'rico'`, `'otro'`.
- [ ] **Step 2: Compilar y ejecutar las pruebas; verificar que fallan** (la unidad no existe). Esperado: error de compilación `UProceso` no encontrada.
- [ ] **Step 3: Implementar `UProceso.pas`** con las firmas de Interfaces; la tabla de avance como `case` por tipo y paso, sin estructuras externas.
- [ ] **Step 4: Compilar y ejecutar `PruebasArchiGenio.exe`.** Esperado: todas las pruebas de `TPruebasProceso` en verde y salida 0.
- [ ] **Step 5: Commit** (`UProceso.pas`, `Pruebas/UPruebasProceso.pas`, `Pruebas/PruebasArchiGenio.dpr`): `feat(procesos): reglas de pasos de los procesos archivisticos`.

---

### Task 2: Numeración (`UNumeracion`)

**Files:** Create `UNumeracion.pas`, `Pruebas/UPruebasNumeracion.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces:**
- Consumes: `TTipoProceso` (Task 1).
- Produces: `function FormatearNumero(Tipo: TTipoProceso; Anio, Consecutivo: Integer): string` — préstamo `2026-0047` (consecutivo a 4 dígitos), transferencia `T-2026-02` y depuración `D-2026-01` (a 2 dígitos; si pasa de 99 crece sin truncar); `function LeerNumero(const Numero: string; out Tipo: TTipoProceso; out Anio, Consecutivo: Integer): Boolean` (False con texto inválido, sin lanzar).

- [ ] **Step 1: Pruebas** `FormateaPrestamo` (`'2026-0047'`), `FormateaTransferencia` (`'T-2026-02'`), `FormateaDepuracion` (`'D-2026-01'`), `NoTruncaConsecutivosGrandes` (`T-2026-123`, `2026-12345`), `LeeLoQueFormatea` (ida y vuelta para los tres tipos), `RechazaTextoInvalido` (`''`, `'X-2026-01'`, `'T-26-01'`, `'T-2026-'`).
- [ ] **Step 2: Ejecutar; verificar que fallan** (unidad inexistente).
- [ ] **Step 3: Implementar** las dos funciones en ASCII.
- [ ] **Step 4: Ejecutar; verificar que pasan.**
- [ ] **Step 5: Commit**: `feat(procesos): formato y lectura de numeros de proceso`.

---

### Task 3: Candado de un proceso por documento (`UCandados`)

**Files:** Create `UCandados.pas`, `Pruebas/UPruebasCandados.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces:**
- Consumes: `TTipoProceso`, `NormalizaClave` (`UAlcance`).
- Produces:
  - `TUnidadDoc = record IdEstructura: string; Id: Integer; CodigoDoc: string; Fecha: TDateTime; Version: string; end` (misma clave que `TB_PrestamosDocumentos`)
  - `function ClaveUnidad(const U: TUnidadDoc): string` — `UpperCase(Trim(IdEstructura)) + '|' + Id + '|' + Trim(CodigoDoc) + '|' + fecha ISO (yyyymmddhhnnss) + '|' + Trim(Version)`
  - `TBloqueo = record Tipo: TTipoProceso; Numero: string; end`
  - `function PuedeEntrar(const Bloqueo: TBloqueo; HayBloqueo: Boolean; out Motivo: string): Boolean` — False si hay bloqueo; `Motivo` en ASCII, p. ej. `'En prestamo 2026-0047'`, `'En transferencia T-2026-02'`, `'En depuracion D-2026-01'`.

- [ ] **Step 1: Pruebas** `ClaveIgnoraMayusculasYEspacios` (`'a.1.4'`≡`'A.1.4 '`), `MismoIdEnOtroNodoEsOtraClave` (`id` 160 en `A.1.7` y `A.3.3`), `ClaveConDobleCero` (`'A.6..3.3'` no se altera salvo mayúsculas/espacios), `EntraSinBloqueo`, `NoEntraConBloqueoYExplicaQuien` (tres tipos, texto exacto del Motivo).
- [ ] **Step 2: Ejecutar; verificar que fallan.**
- [ ] **Step 3: Implementar.**
- [ ] **Step 4: Ejecutar; verificar que pasan.**
- [ ] **Step 5: Commit**: `feat(procesos): candado de un proceso abierto por documento`.

---

### Task 4: Autorización de la Comisión (`UAutorizacion`)

**Files:** Create `UAutorizacion.pas`, `Pruebas/UPruebasAutorizacion.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces:**
- Consumes: `TTipoProceso`, `TErrorCampo` (`UErroresCampo`).
- Produces:
  - `TOrganoComision = (ocCentral, ocMunicipal, ocProvincial, ocNacional)` (central = Comisión Central de Valoración de la entidad)
  - `TAutorizacion = record Organo: TOrganoComision; NumActa, NumAcuerdo: string; Fecha: TDateTime; end`
  - `function ValidarAutorizacion(Tipo: TTipoProceso; const A: TAutorizacion; Hoy: TDateTime): TArray<TErrorCampo>` — vacío si es válida. Reglas: `NumActa` y `NumAcuerdo` no vacíos tras `Trim` (campos `'acta'`, `'acuerdo'`); `Fecha` no futura respecto a `Hoy` y mayor que 01/01/1959 (campo `'fecha'`); transferencia exige `ocCentral`, depuración exige `ocMunicipal`, `ocProvincial` u `ocNacional` (campo `'organo'`); préstamo no usa autorización (siempre error `'organo'`).

- [ ] **Step 1: Pruebas** `ValidaAutorizacionCorrecta`, `ExigeActaYAcuerdo`, `RechazaFechaFutura`, `DepuracionRechazaComisionCentral`, `TransferenciaRechazaComisionProvincial`, `PrestamoNoAdmiteAutorizacion`, `AceptaFechaDeHoy`.
- [ ] **Step 2: Ejecutar; verificar que fallan.**
- [ ] **Step 3: Implementar** con mensajes ASCII.
- [ ] **Step 4: Ejecutar; verificar que pasan.**
- [ ] **Step 5: Commit**: `feat(procesos): validacion de la autorizacion de la comision`.

---

### Task 5: Esquema `prc_*` (`UEsquemaProcesos`)

**Files:** Create `UEsquemaProcesos.pas`, `SCRIPTS/procesos_tablas.sql`, `Pruebas/UPruebasEsquemaProcesos.pas`; Modify `UCapaDatos.pas` (junto a `CrearEsquemaTrazabilidad`, línea ~5697), `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces:**
- Produces: `procedure CrearEsquemaProcesos(Conn: TFDConnection; EsSqlServer: Boolean)`, mismo patrón que `CrearEsquemaAlcance` (cada sentencia aislada, fallos ignorados). Tablas (tipos como `UEsquemaAlcance`: `COUNTER`/`IDENTITY`, `DATETIME`):
  - `prc_proceso(IdProceso autonumérico PK, Tipo VARCHAR(1) NOT NULL ['P','T','D'], Anio INT NOT NULL, Consecutivo INT NOT NULL, Numero VARCHAR(20) NOT NULL, Estado VARCHAR(1) NOT NULL ['C','F','X'], Paso INT NOT NULL, IdEstructura VARCHAR(50) NOT NULL, IdNodo INT NOT NULL [claves del nodo remitente, FK a tb_tree], Creado DATETIME, CreadoPor VARCHAR(100), Cerrado DATETIME NULL, UNIQUE (Tipo, Anio, Consecutivo))`
  - `prc_unidad(IdProceso INT, IdEstructura VARCHAR(50), id INT, Codigodoc VARCHAR(20), fecha DATETIME, version VARCHAR(12), Caja INT NULL, Activa BIT, PK (IdProceso, IdEstructura, id, Codigodoc, fecha, version), FK a prc_proceso ON DELETE CASCADE)`
  - `prc_evento(IdEvento autonumérico PK, IdProceso INT, Fecha DATETIME, Usuario VARCHAR(100), Paso INT, Texto VARCHAR(255) [500 en SQL Server])`
  - `prc_autorizacion(IdProceso INT PK, Organo VARCHAR(1), NumActa VARCHAR(30), NumAcuerdo VARCHAR(30), Fecha DATETIME, RegistradoPor VARCHAR(100), FK a prc_proceso)`
  - Índices: `prc_unidad (IdEstructura, id)`, `prc_proceso (Estado, Tipo)`, `prc_evento (IdProceso)`.
  Decisión mía: `Caja` queda desde F0 para no migrar la tabla en F2; en F0 no se usa.

- [ ] **Step 1: Pruebas** en `UPruebasEsquemaProcesos.pas` (patrón de `UPruebasEsquema`: conexión por `ARCHIGENIO_TEST_DB`, se omite sin ella; rama Access con `ARCHIGENIO_TEST_MDB`): `TablasExisten` (las cuatro), `EsIdempotente` (llamar dos veces no cambia conteos ni lanza), `NumeroUnicoPorTipoAnio` (insertar dos procesos con igual `Tipo, Anio, Consecutivo` lanza), `BorrarProcesoBorraUnidades`, `Access_CreaTablasYEsIdempotente`.
- [ ] **Step 2: Ejecutar; verificar que fallan** (unidad inexistente).
- [ ] **Step 3: Implementar `UEsquemaProcesos.pas`** y escribir la copia SQL Server en `SCRIPTS/procesos_tablas.sql`; llamar `CrearEsquemaProcesos(Conn, TBD = 'S');` en `UCapaDatos.pas` con comentario en español, siguiendo el estilo de las llamadas vecinas.
- [ ] **Step 4: Ejecutar** con `ARCHIGENIO_TEST_DB` apuntando a una base de prueba. Esperado: verde. Sin base de prueba, las pruebas de BD se omiten y se anota en la lista de verificación.
- [ ] **Step 5: Commit**: `feat(procesos): esquema prc_* (proceso, unidad, evento, autorizacion)`.

---

### Task 6: Acceso a datos (`UProcesosDatos`)

**Files:** Create `UProcesosDatos.pas`, `Pruebas/UPruebasProcesosDatos.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces:**
- Consumes: Tasks 1 a 5.
- Produces (todas reciben `Conn: TFDConnection` y son parametrizadas):
  - `TProcesoRef = record IdProceso: Integer; Numero: string; end`
  - `function CrearProceso(Conn: TFDConnection; Tipo: TTipoProceso; const Nodo: TClaveNodo; const Usuario: string; Anio: Integer): TProcesoRef` — calcula el consecutivo (`MAX+1` por `Tipo, Anio` dentro de transacción), inserta con `Estado='C'`, `Paso=1`, escribe evento «Proceso creado»; si choca la clave única reintenta hasta 3 veces.
  - `function AvanzarPaso(Conn: TFDConnection; IdProceso: Integer; PasoLeido: Integer; Cumplidas: TCondiciones; const Usuario: string; out Faltan: TCondiciones): Boolean` — consulta tipo y paso, aplica `PuedeAvanzar`, hace `UPDATE ... SET Paso = Paso+1 WHERE IdProceso=:id AND Paso=:leido AND Estado='C'` y exige exactamente 1 fila afectada; si el paso era el último, pone `Estado='F'` y `Cerrado`; evento «Paso N completado». Devuelve False si faltan condiciones o si el paso ya cambió (otro usuario).
  - `function CancelarProceso(Conn: TFDConnection; IdProceso: Integer; const Usuario, Motivo: string): Boolean` — usa `PuedeCancelar`; `Estado='X'`; evento con el motivo.
  - `procedure RegistrarEvento(Conn: TFDConnection; IdProceso: Integer; const Usuario, Texto: string)`
  - `procedure GuardarAutorizacion(Conn: TFDConnection; IdProceso: Integer; const A: TAutorizacion; const Usuario: string)` — valida con `ValidarAutorizacion` y lanza `EAutorizacionInvalida` con el primer mensaje si falla; reemplaza la anterior.
  - `function AgregarUnidad(Conn: TFDConnection; IdProceso: Integer; const U: TUnidadDoc; out Motivo: string): Boolean` — comprueba el candado en la misma transacción (consulta los procesos `Estado='C'` que contienen la unidad) y solo inserta si no hay bloqueo.
  - `function BloqueosDelNodo(Conn: TFDConnection; const Nodo: TClaveNodo): TDictionary<string, TBloqueo>` — **una sola consulta** que devuelve, indexado por `ClaveUnidad`, todas las unidades bloqueadas del nodo (evita consultar por fila en las listas).
  - `function ContarPorEstado(Conn: TFDConnection; Tipo: TTipoProceso; const Nodos: TArray<TClaveNodo>): TArray<Integer>` — conteos `[EnCurso, Finalizados, Cancelados]` en una consulta (alimenta los indicadores).

- [ ] **Step 1: Pruebas** (BD de prueba, cada prueba limpia sus filas): `CreaProcesoConNumero` (`'2026-0001'` para préstamo), `ConsecutivoAvanzaPorTipoYAnio`, `ConsecutivoReiniciaCadaAnio` (Review Focus 2), `AvanzaPasoYRegistraEvento`, `NoAvanzaSiFaltanCondiciones`, `DosAvancesSimultaneosSoloUnoGana` (misma lectura de paso dos veces: segunda devuelve False; Review Focus 1), `FinalizaEnElUltimoPaso`, `CancelarDepuracionEjecutadaSeRechaza` y `CancelarTransferenciaRecibidaSeRechaza` (Review Focus 4), `AutorizacionInvalidaLanza`, `UnidadBloqueadaNoSeAgrega` (mismo documento en dos procesos abiertos), `UnidadSeLiberaAlCancelar`, `ClaveIrregularNoMezclaDocumentos` (Review Focus 3: `'A.1.6 '` vs `'A.1.6'`, mismo `id` en dos nodos), `BloqueosDelNodoEsUnaConsulta` (cuenta consultas con `Conn.Monitor` o contador de `ExecSQL`; debe ser 1), `ContarPorEstadoSumaBien`.
- [ ] **Step 2: Ejecutar; verificar que fallan.**
- [ ] **Step 3: Implementar `UProcesosDatos.pas`**; cada operación que escribe va en transacción; la unidad no usa VCL ni `TUDM`.
- [ ] **Step 4: Ejecutar con `ARCHIGENIO_TEST_DB`.** Esperado: verde y sin filas residuales (`SELECT COUNT(*) FROM prc_proceso` igual al inicio).
- [ ] **Step 5: Commit**: `feat(procesos): acceso a datos de procesos (crear, avanzar, cancelar, candados)`.

---

### Task 7: Interruptor clásico (`UProcesosInterruptor`)

**Files:** Create `UProcesosInterruptor.pas`, `Pruebas/UPruebasProcesosInterruptor.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces:**
- Produces: constantes `ARCHIVO_PROCESOS_CLASICO = 'procesos_clasico.flag'`, `ARCHIVO_ERRORES_PROCESOS = 'procesos_error.log'`; `function ProcesosClasicos(const ACarpeta: string): Boolean`; `procedure RegistrarErrorProceso(const ACarpeta, ATexto: string)` (nunca lanza). Copia fiel del patrón de `UClasificadoresInterruptor`.

- [ ] **Step 1: Pruebas** (espejo de `UPruebasClasificadoresInterruptor`): `SinFlagNoEsClasico`, `ConFlagEsClasico`, `RegistraErrorEnArchivo`, `RegistrarEnCarpetaInexistenteNoLanza`.
- [ ] **Step 2: Ejecutar; fallan.** Step 3: **Implementar.** Step 4: **Ejecutar; pasan.**
- [ ] **Step 5: Commit**: `feat(procesos): interruptor procesos_clasico.flag`.

---

### Task 8: Pantalla base y enganche en el shell (`UProcesoBase`)

**Files:** Create `UProcesoBase.pas`; Modify `UClasificadorBase.pas` (solo si falta el gancho descrito), `UMAINFORM.pas`, `ArchiGenioPro.dpr`, `CLAUDE.md`.

**Interfaces:**
- Consumes: `TFormClasificadorBase` (cabecera, tabla sin aspecto Excel, panel lateral, `Embeber`, `PuedeSalir`), `TProceso` reglas (Task 1), `ContarPorEstado` (Task 6), `UTema`.
- Produces:
  - `TFormProcesoBase = class(TFormClasificadorBase)` con: `ConstruirProceso(Tipo: TTipoProceso; const Titulo, Subtitulo: string)`; `FijarIndicadores(const Items: array of TIndicador)` con `TIndicador = record Texto: string; Valor: Integer; Alerta: Boolean; end` (franja de la maqueta A1); `FijarPestanas(const Nombres: array of string; const Conteos: array of Integer)` con evento `AlCambiarPestana(Indice: Integer)` virtual; `FijarPasos(const Nombres: array of string; PasoActual: Integer)` (tira de la maqueta B2) con completados en verde y actual resaltado; el panel lateral admite botones de acción propios (decisión: si `TFormClasificadorBase` no ofrece un `PanelAcciones: TPanel` protegido para agregarlos, se agrega ese gancho mínimo sin cambiar el comportamiento actual).
  - `TMAIN.AbrirProceso(AForm: TFormProcesoBase; const ATitulo, ANombreLog: string; AAlSalir: TProc)`: igual que `AbrirClasificador` pero con `ShellPrincipal.AbrirExterno('Procesos', ATitulo)`; comparten el campo de «pantalla externa abierta» para que cambiar de sección o cerrar pida confirmar. Si `ProcesosClasicos(PathSys)` o falla la apertura, registra con `RegistrarErrorProceso` y deja el camino viejo (botones `btnTransfer`, `P3`, `D3`).
  - Pantalla de demostración **temporal**: con la variable de entorno `ARCHIGENIO_PROCESOS_DEMO=1`, la sección `SECCION_PRESTAMOS` abre `TFormProcesoBase` con datos de ejemplo de la maqueta A1 (indicadores, pestañas, tres filas, tira de pasos). Se elimina en la Task 1 de la fase F1. Sin esa variable, nada cambia para el usuario.

- [ ] **Step 1: Construir la pantalla** `UProcesoBase.pas` con comentario de cabecera en español, usando solo colores de `UTema` (claro y oscuro) y Segoe UI; sin `.dfm`; mensajes por `TMensajes`.
- [ ] **Step 2: Enganchar en `UMAINFORM.pas`** `AbrirProceso` (reutilizando el cierre con confirmación de `CerrarClasificador` generalizando el tipo del campo a `TFormClasificadorBase`) y el desvío de demostración en `ShellSeccion`. Agregar `UProcesoBase in 'UProcesoBase.pas'` y las unidades de las tareas 1 a 7 al `.dpr` de la aplicación.
- [ ] **Step 3: Compilar la aplicación** (`scripts/compilar.ps1 ArchiGenioPro.dproj`). Esperado: 0 errores. Si falla por unidades de terceros no instaladas, anotarlo y compilar solo la unidad con `mcp__delphi__compile_unit`.
- [ ] **Step 4: Verificación visual** con `ARCHIGENIO_PROCESOS_DEMO=1`: capturar la pantalla en claro y oscuro y compararla con las maquetas A1 y B2 (franja de indicadores, pestañas con insignia roja, tabla sin cuadrícula, panel lateral, tira de pasos). Confirmar que cambiar de sección con la pantalla abierta funciona y que con `procesos_clasico.flag` se abre la pantalla vieja.
- [ ] **Step 5: Documentar** en `CLAUDE.md` una viñeta «Procesos archivísticos (F0)» (unidades puras, `prc_*`, interruptor, pantalla de demostración temporal) y crear `docs/superpowers/plans/2026-11-12-verificacion-procesos-f0.md` con la lista manual (tablas creadas en SQL Server, comportamiento del flag, captura claro/oscuro, `DatosAntiguos` intactos).
- [ ] **Step 6: Commit** (solo hunks propios de `UMAINFORM.pas`): `feat(procesos): pantalla base de procesos embebida en el shell`.

---

## Cierre de F0

- [ ] Ejecutar la suite completa (`PruebasArchiGenio.exe`): todo en verde, sin regresiones.
- [ ] Revisión de código de la rama con `superpowers:requesting-code-review` (foco: Review Focus y que ninguna pantalla vieja haya cambiado).
- [ ] Entregar al usuario: lista de verificación F0 y la propuesta de plan detallado de F1 (Préstamos).

## Autorrevisión

- **Cobertura del diseño:** modelo común (§4: estados, numeración, bitácora, unidades, autorización, candados) → Tasks 1 a 6; permisos (§8, depuración solo desde archivo central) → Task 1 `PuedeIniciar`; interfaz embebida y flag (§9) → Tasks 7 y 8; compatibilidad y pruebas sin VCL (§10) → restricciones globales y Task 5 (rama Access). Fuera de F0 a propósito: tablas específicas de cada módulo, impresos, migración de datos antiguos.
- **Consistencia de tipos:** `TUnidadDoc`/`ClaveUnidad` (Task 3) se usan en Task 6; `TAutorizacion`/`ValidarAutorizacion` (Task 4) en Task 6; `TCondiciones` (Task 1) en `AvanzarPaso`; `TClaveNodo` y `NormalizaClave` vienen de `UAlcance`.
- **Pendiente de confirmar en ejecución:** el valor real de `ldtipoarch` para «Central» e «Histórico» en `cl_ttipoarch` (`SELECT * FROM cl_ttipoarch`); `TipoArchivoDesdeTexto` trabaja por texto para no depender del código.
