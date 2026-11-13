# Procesos archivísticos, F1: Préstamos — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar la pantalla vieja de Préstamos por una nueva (con `.dfm`, editable en el IDE), con estados, vencimientos, candado por documento, impresos oficiales y migración de los datos antiguos.

**Architecture:** Reglas y datos en unidades sin VCL (`UPrestamosReglas`, `UPrestamosDatos`, `UPrestamosMigracion`) sobre las tablas `prc_*` de F0 más `prc_prestamo`. La pantalla es un formulario con `.dfm` (`UPrestamosForm`) que usa solo componentes que el IDE puede abrir (VCL estándar y DevExpress instalados); los dibujos especiales (tarjetas, pestañas, tira de pasos) son `TPaintBox` del `.dfm` cuyo pintado vive en una unidad aparte (`UProcesoPintura`).

**Tech Stack:** Delphi 10.3 VCL, FireDAC (SQL Server y Access), DevExpress (`cxGrid`, `cxButton`, `cxTextEdit`, `cxDateEdit`), FastReport, DUnitX.

**Spec:** `docs/superpowers/specs/2026-11-12-prestamos-transferencias-depuracion-design.md` (sección 5, 9, 10). Maqueta aprobada: `docs/superpowers/maquetas/2026-11-12-procesos-maqueta.html` (A1 a A3). Base: `docs/superpowers/plans/2026-11-12-procesos-f0-base-comun.md`.

## Global Constraints

- **Cada pantalla nueva lleva su `.dfm`** (petición del usuario, 2026-11-12): todo el diseño (posición, tamaño, anclajes, colores, fuentes, columnas de las tablas) vive en el `.dfm`; el código solo llena datos y reacciona a eventos. Prohibido crear controles de diseño por código. **El `.dfm` solo puede usar componentes que el IDE abre sin paquetes propios**: VCL estándar (`TPanel`, `TLabel`, `TPaintBox`, `TShape`, `TSplitter`, `TScrollBox`, `TImageList`) y DevExpress ya usados en otros `.dfm` del proyecto. No usar `TBotonShell`, `TCajaBusqueda` ni ningún control de `UShellPrincipal` en un `.dfm`. Cada componente del `.dfm` tiene su campo publicado en el `.pas` (sincronizados).
- Fuentes `.pas`/`.dfm` en **Windows‑1252 con CRLF** (los `.dfm` escriben los acentos como `#233`, `#243`, …: así el `.dfm` es ASCII). Unidades sin pantalla en ASCII. Nunca reescribir un archivo existente con herramientas que lo normalicen a UTF‑8.
- Mensajes por `TMensajes`. Textos visibles con tildes (en `.dfm` como `#NNN`; en `.pas` de pantallas igual o con la codificación correcta).
- SQL válido en SQL Server y Access, parametrizado; booleanos con `<> 0`.
- Cada unidad nueva con `uses` de VCL va a `ArchiGenioPro.dpr` (con `{frmX}` si tiene formulario); las puras también a `Pruebas/PruebasArchiGenio.dpr`.
- Compilar y probar: `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`, `Pruebas\Win32\Debug\PruebasArchiGenio.exe`, `scripts/compilar.ps1 ArchiGenioPro.dproj`. Estado base de la suite: 684 pasan, 23 errores previos (`cl_series`). No conectarse a bases con credenciales del código: las pruebas de BD usan `ARCHIGENIO_TEST_DB` y se omiten sin ella.
- **Commits** solo de los archivos de la tarea (el árbol tiene ruido previo); `scripts/` en minúscula para rutas bajo `scripts/` ya rastreadas (ojo: `scripts/procesos_tablas.sql`). Cierre: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Review Focus

1. Documento de **dos subseries distintas con el mismo `Codigodoc`/fecha/versión** en el mismo nodo: el candado no los confunde (la clave incluye `codsubs`).
2. Préstamo **vence hoy / venció ayer / sin fecha límite**: el estado visible y los indicadores no se contradicen (hoy no es vencido; mañana sí).
3. **Devolver dos veces**, o devolver un préstamo cancelado: la segunda operación se rechaza y no duplica el evento.
4. **Datos viejos**: préstamo antiguo con `FDevolucion` y `FCancelacion` a la vez, con `Prestamista` vacío, sin documentos o con un documento ya prestado en otro préstamo abierto; la migración no pierde ni duplica filas y reporta lo que no pudo mapear.
5. Lista con **miles de préstamos**: la pantalla pagina o limita (no carga todo) y los contadores salen de una consulta de conteo, no de recorrer filas.

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `UCandados.pas`, `UEsquemaProcesos.pas`, `UProcesosDatos.pas`, `scripts/procesos_tablas.sql` (modifica) | Agregar `codsubs` a la clave del documento (corrige F0). |
| `UPrestamosReglas.pas` (nuevo) | Estado visible, plazos y validación de la solicitud. Puro. |
| `UEsquemaProcesos.pas` (modifica) | Tabla `prc_prestamo`. |
| `UPrestamosDatos.pas` (nuevo) | Altas, entrega, renovación, devolución, cancelación, listado con filtro y paginación, indicadores, búsqueda de documentos. |
| `UPrestamosMigracion.pas` (nuevo) | Copia `TB_Prestamos*` a `prc_*` con informe. |
| `UInicioDatos.pas`, `UDocumentoVistaDatos.pas` (modifican) | «Prestados» pasa a leer `prc_bloqueo` (y los préstamos viejos abiertos mientras exista el `.flag`). |
| `UProcesoPintura.pas` (nuevo) | Pintado de tarjetas, pestañas y tira de pasos sobre un `TCanvas`; puntería de pestañas. |
| `UPrestamosForm.pas` + `UPrestamosForm.dfm` (nuevos) | Pantalla con `.dfm`: lista, ficha, nuevo préstamo. |
| `UProcesoBase.pas`, `UProcesoDemo.pas` (se eliminan) | Sustituidos por el formulario con `.dfm`. |
| `UMAINFORM.pas` (modifica) | `IPantallaProceso`, apertura embebida, retiro del desvío de demostración. |
| `ReportesYoyo/` (nuevos `.fr3`) | `rSolicitudPrestamo.fr3` (Anexo 8.2) y `rRegistroPrestamos.fr3` (Anexo 8.3). |
| `UClasificadorBase.pas` (modifica) | Se retiran los accesores de F0 si ya no se usan. |

---

### Task 1: Corregir F0 — `codsubs` en la clave del documento

**Files:** Modify `UCandados.pas`, `UEsquemaProcesos.pas`, `UProcesosDatos.pas`, `scripts/procesos_tablas.sql`, `Pruebas/UPruebasCandados.pas`, `Pruebas/UPruebasEsquemaProcesos.pas`, `Pruebas/UPruebasProcesosDatos.pas`.

**Interfaces:**
- Produces: `TUnidadDoc` gana el campo `CodSubs: string` (entre `Id` y `CodigoDoc`); `ClaveUnidad` = `NormalizaClave(IdEstructura)|Id|Trim(CodSubs)|Trim(CodigoDoc)|fecha|Trim(Version)`; `prc_unidad` y `prc_bloqueo` tienen columna `codsubs VARCHAR(50) NOT NULL` y su clave primaria incluye `codsubs` (`IdEstructura, id, codsubs, Codigodoc, fecha, version`).

- [ ] **Step 1: Pruebas (rojo).** En `UPruebasCandados`: `MismoCodigoEnOtraSubserieEsOtraClave` (mismo nodo, `codsubs` `'A'` y `'B'` → claves distintas); ajustar la función `Unidad(...)` para asignar `CodSubs := 'S1'`. En `UPruebasEsquemaProcesos`: `Bloqueo_ClavePrimariaEsElDocumento` espera `PRIMARY KEY (IdEstructura, id, codsubs, Codigodoc, fecha, version)`. En `UPruebasProcesosDatos`: `UnidadPrueba(IdEstr, Id, Cod)` asigna `CodSubs := 'S1'` y se agrega `MismoCodigoEnOtraSubserieNoSeBloquea` (BD).
- [ ] **Step 2: Compilar y ejecutar; verificar que falla** (campo `CodSubs` inexistente / clave primaria distinta).
- [ ] **Step 3: Implementar** el campo y la clave en `UCandados`; agregar `codsubs` a `prc_unidad`/`prc_bloqueo` en `UEsquemaProcesos` y en `scripts/procesos_tablas.sql`; en `UProcesosDatos` incluir `codsubs` en los `INSERT` de `prc_bloqueo` y `prc_unidad` y en los `WHERE`/lecturas de `BuscarBloqueo` y `BloqueosDelNodo`.
- [ ] **Step 4: Ejecutar la suite;** esperado: los tests de `TPruebasCandados` y `TPruebasEsquemaProcesosSql` pasan; el resto igual que antes (684 + los nuevos, 23 errores previos).
- [ ] **Step 5: Commit:** `fix(procesos): la clave del documento incluye codsubs`.

---

### Task 2: Reglas del préstamo (`UPrestamosReglas`)

**Files:** Create `UPrestamosReglas.pas`, `Pruebas/UPruebasPrestamosReglas.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces:**
- Consumes: `TEstadoProceso`, `NumeroPasos` (`UProceso`), `TErrorCampo` (`UErroresCampo`).
- Produces:
  - `TTipoUsuarioPrestamo = (tuInterno, tuExterno)`
  - `TEstadoPrestamo = (epSolicitado, epEntregado, epVencido, epPorVencer, epDevuelto, epCancelado)` (`epPorVencer`: entregado que vence en ≤ 3 días, sin vencer)
  - `function EstadoDelPrestamo(Paso: Integer; Estado: TEstadoProceso; FechaLimite: TDateTime; Hoy: TDateTime): TEstadoPrestamo` — paso 1 en curso = solicitado; paso 2 en curso = entregado, `epVencido` si `Trunc(FechaLimite) < Trunc(Hoy)`, `epPorVencer` si faltan 0..3 días; finalizado = devuelto; cancelado = cancelado. `FechaLimite = 0` (sin límite) nunca vence.
  - `function DiasDeRetraso(FechaLimite, Hoy: TDateTime): Integer` (0 si no vencido o sin límite)
  - `const PLAZO_PRESTAMO_DIAS = 3`, `function FechaLimiteSugerida(Entrega: TDateTime; Dias: Integer): TDateTime`
  - `TSolicitudPrestamo = record Solicitante, Carnet, Entidad: string; Usuario: TTipoUsuarioPrestamo; FechaLimite: TDateTime; end`
  - `function ValidarSolicitud(const S: TSolicitudPrestamo; Hoy: TDateTime): TArray<TErrorCampo>` — campos `'solicitante'` (vacío), `'carnet'` (obligatorio y de 11 dígitos solo si es externo), `'entidad'` (obligatoria si es externo), `'limite'` (no anterior a hoy cuando se indica).

- [ ] **Step 1: Pruebas** (nombres): `EntregadoVencidoAlDiaSiguiente`, `VenceHoyNoEstaVencido` (Review Focus 2), `PorVencerAlFaltarTresDias`, `SinFechaLimiteNuncaVence`, `SolicitadoDevueltoYCancelado`, `DiasDeRetrasoCuentaDiasCompletos`, `FechaLimiteSugeridaSumaDias`, `ExternoExigeCarnetDeOnceDigitosYEntidad`, `InternoNoExigeCarnet`, `RechazaLimiteAnteriorAHoy`, `SolicitanteVacioEsError`.
- [ ] **Step 2: Ejecutar; verificar que fallan** (unidad inexistente).
- [ ] **Step 3: Implementar** (ASCII, sin VCL).
- [ ] **Step 4: Ejecutar; verificar que pasan.**
- [ ] **Step 5: Commit:** `feat(prestamos): reglas de estado, plazo y validacion`.

---

### Task 3: Esquema `prc_prestamo`

**Files:** Modify `UEsquemaProcesos.pas`, `scripts/procesos_tablas.sql`, `Pruebas/UPruebasEsquemaProcesos.pas`.

**Interfaces:**
- Produces: tabla `prc_prestamo(IdProceso INT PK FK→prc_proceso ON DELETE CASCADE, Solicitante VARCHAR(150) NOT NULL, Carnet VARCHAR(20) NULL, Entidad VARCHAR(150) NULL, TipoUsuario VARCHAR(1) NOT NULL ['I','E'], FEntrega DATETIME NULL, FLimite DATETIME NULL, FDevolucion DATETIME NULL, AtendidoPor VARCHAR(100) NULL, Obs VARCHAR(255) NULL, Completo BIT NULL [devuelto completo], IdPrestamoViejo VARCHAR(12) NULL [trazabilidad de la migración])`; índice `IX_prc_prestamo_limite (FLimite)`.

- [ ] **Step 1: Pruebas:** `Prestamo_TablaConClaveYCascada` (la sentencia contiene `CREATE TABLE prc_prestamo (` con guarda y `REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE`), `Prestamo_IndiceDeLimite`; la prueba de conteo de índices pasa de 3 a 4; la prueba de tablas de BD incluye `prc_prestamo`.
- [ ] **Step 2: Ejecutar; falla.** **Step 3: Implementar** en `SentenciasEsquemaProcesos` y en el `.sql`. **Step 4: Ejecutar; pasa.**
- [ ] **Step 5: Commit:** `feat(prestamos): tabla prc_prestamo`.

---

### Task 4: Datos del préstamo (`UPrestamosDatos`)

**Files:** Create `UPrestamosDatos.pas`, `Pruebas/UPruebasPrestamosDatos.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces:**
- Consumes: Tasks 1 a 3; `CrearProceso`, `AvanzarPaso`, `CancelarProceso`, `AgregarUnidad`, `BloqueosDelNodo`, `RegistrarEvento` (`UProcesosDatos`).
- Produces (todas con `Conn: TFDConnection`, parametrizadas, transaccionales):
  - `TPrestamoFila = record IdProceso: Integer; Numero, Solicitante, Entidad: string; Usuario: TTipoUsuarioPrestamo; Unidades: Integer; FEntrega, FLimite, FDevolucion: TDateTime; Paso: Integer; Estado: TEstadoProceso; Visible: TEstadoPrestamo; end`
  - `function CrearSolicitud(Conn; const Nodo: TClaveNodo; const S: TSolicitudPrestamo; const Usuario: string; Anio: Integer): TProcesoRef` — valida con `ValidarSolicitud` (lanza `EPrestamoInvalido` con el primer mensaje), crea proceso tipo préstamo e inserta `prc_prestamo`.
  - `function AgregarDocumento(Conn; IdProceso: Integer; const U: TUnidadDoc; out Motivo: string): Boolean` (usa `AgregarUnidad`; solo si el préstamo está en paso 1).
  - `function RegistrarEntrega(Conn; IdProceso: Integer; const Usuario: string; Entrega, Limite: TDateTime; out Motivo: string): Boolean` — exige al menos 1 documento; avanza 1→2 con `[cdSinBloqueos]`; guarda `FEntrega`, `FLimite`, `AtendidoPor`.
  - `function RenovarPlazo(Conn; IdProceso: Integer; NuevoLimite: TDateTime; const Usuario: string): Boolean` — solo entregado; el nuevo límite debe ser posterior al actual; evento «Plazo renovado hasta dd/mm/aaaa».
  - `function RegistrarDevolucion(Conn; IdProceso: Integer; Completo: Boolean; const Obs, Usuario: string; Devolucion: TDateTime): Boolean` — avanza 2→3 (finaliza, libera candados), guarda `FDevolucion`, `Completo`, `Obs`; devolver dos veces → `False` (Review Focus 3).
  - `function CancelarPrestamo(Conn; IdProceso: Integer; const Motivo, Usuario: string): Boolean`
  - `function ListarPrestamos(Conn; const Nodos: TArray<TClaveNodo>; Filtro: TFiltroPrestamo; Hoy: TDateTime; Texto: string; Limite: Integer): TArray<TPrestamoFila>` con `TFiltroPrestamo = (fpTodos, fpEnPrestamo, fpVencidos, fpDevueltos, fpSolicitudes)`; ordena por fecha límite y luego número; devuelve a lo más `Limite` filas (Review Focus 5); `Texto` busca en número, solicitante y entidad (con `LIKE` y parámetro).
  - `TIndicadoresPrestamo = record EnPrestamo, Vencidos, PorVencer, DevueltosAnio, Solicitudes, Total: Integer; end` y `function IndicadoresPrestamo(Conn; const Nodos: TArray<TClaveNodo>; Hoy: TDateTime): TIndicadoresPrestamo` — una sola consulta de conteos agrupados (las reglas de vencido se aplican con comparaciones de fecha en SQL).
  - `TDocumentoBuscado = record Unidad: TUnidadDoc; Titulo, Ubicacion: string; Bloqueo: TBloqueo; Bloqueado: Boolean; end` y `function BuscarDocumentos(Conn; const Nodo: TClaveNodo; const Texto: string; Limite: Integer): TArray<TDocumentoBuscado>` — de `tb_SeriesDatos` del nodo (y sus descendientes si se pasan en `Nodos`: variante con `TArray<TClaveNodo>`), con `Ubicacion` = `deposito / gaveta / posicion` y `Bloqueado` tomado de `BloqueosDelNodo` (una consulta).
  - `function DocumentosDelPrestamo(Conn; IdProceso: Integer): TArray<TDocumentoBuscado>`.

- [ ] **Step 1: Pruebas** (BD, se omiten sin `ARCHIGENIO_TEST_DB`; reales y puras las de construcción de SQL de filtro si se exponen): `CrearSolicitudNumeraYGuardaDatos`, `SolicitudInvalidaLanza`, `EntregaExigeDocumentos`, `EntregaGuardaFechasYPasa`, `RenovarSoloEntregadoYHaciaAdelante`, `DevolucionLibera​LosDocumentos`, `DevolverDosVecesSoloUna` (Review Focus 3), `CancelarSolicitadoLibera`, `NoSePuedeCancelarUnDevuelto`, `ListarFiltraPorEstado` (vencidos vs en préstamo con fechas fijas), `ListarRespetaLimiteYBusca` (Review Focus 5), `IndicadoresCuentaCadaGrupo`, `BuscarDocumentosMarcaLosBloqueados`, `DocumentoDeOtraSubserieNoSeMarca` (Review Focus 1).
- [ ] **Step 2: Compilar y ejecutar; verificar que falla** (unidad inexistente).
- [ ] **Step 3: Implementar** con la regla: ninguna operación consulta por fila; `ListarPrestamos` e `IndicadoresPrestamo` hacen una consulta cada una.
- [ ] **Step 4: Ejecutar;** esperado: compila y las pruebas de BD se omiten sin base (documentarlo en la lista de verificación).
- [ ] **Step 5: Commit:** `feat(prestamos): acceso a datos del prestamo`.

---

### Task 5: Migración de los préstamos antiguos (`UPrestamosMigracion`)

**Files:** Create `UPrestamosMigracion.pas`, `Pruebas/UPruebasPrestamosMigracion.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces:**
- Produces: `TInformeMigracion = record Leidos, Migrados, SinDocumentos, DocumentosOmitidos: Integer; Avisos: TArray<string>; end`; `function MigrarPrestamosViejos(Conn: TFDConnection; EsSqlServer: Boolean): TInformeMigracion` — recorre `TB_Prestamos` ordenado por `FPrestamo` y, por cada fila no migrada (`prc_prestamo.IdPrestamoViejo` + nodo no existe): crea el proceso con su año (el de `FPrestamo`) y su número, estado `F` paso 3 si `FDevolucion` no es nulo, `X` paso 1 si hay `FCancelacion` y no `FDevolucion`, `C` paso 2 en otro caso; copia solicitante, entidad, responsable, observaciones y fechas; copia sus documentos a `prc_unidad` (y a `prc_bloqueo` si el préstamo queda abierto y el documento no está retenido ya: si lo está, se omite con aviso). Idempotente (segunda ejecución: 0 migrados). Si `TB_Prestamos` no existe devuelve ceros. Función pura `EstadoMigrado(FDevolucion, FCancelacion: TDateTime; HayDevolucion, HayCancelacion: Boolean): (paso, estado)` expuesta para probar sin BD.
- [ ] **Step 1: Pruebas puras:** `DevueltoSeMigraComoFinalizado`, `CanceladoSeMigraComoCancelado`, `AbiertoSeMigraComoEntregado`, `DevueltoYCanceladoGanaLaDevolucion` (Review Focus 4). Pruebas de BD (se omiten sin base): `MigraUnPrestamoConSusDocumentos`, `EsIdempotente`, `DocumentoRepetidoEnPrestamoAbiertoSeOmiteConAviso`, `PrestamoSinDocumentosSeCuenta`.
- [ ] **Step 2: Ejecutar; falla.** **Step 3: Implementar.** **Step 4: Ejecutar; pasan las puras.**
- [ ] **Step 5: Commit:** `feat(prestamos): migracion de los prestamos antiguos`.

---

### Task 6: Lecturas del resto del sistema pasan a `prc_bloqueo`

**Files:** Modify `UInicioDatos.pas`, `UDocumentoVistaDatos.pas`, sus pruebas si cubren esas consultas (`Pruebas/UPruebasInicioDatos.pas`, `Pruebas/UPruebasDocumentoVistaDatos.pas`).

**Interfaces:**
- Consumes: `prc_bloqueo` (Task 1). Produces: el contador `Prestados` y el estado `edPrestado` salen de `prc_bloqueo` JOIN `prc_proceso` (`Tipo = 'P'`) **unidos** (UNION) a los préstamos viejos abiertos mientras exista `TB_Prestamos` sin migrar; si las tablas `prc_*` no existen, la consulta falla como hoy y el contador queda en 0.
- [ ] **Step 1: Pruebas:** si las pruebas existentes arman SQL de esas consultas, ajustar y agregar `PrestadosCuentaTambienLosDePrc` (BD, se omite sin base). Las pruebas de solo texto de SQL verifican que aparece `prc_bloqueo`.
- [ ] **Step 2: Ejecutar; falla.** **Step 3: Implementar** (una sola consulta, sin recorrer filas). **Step 4: Ejecutar; la suite no regresa.**
- [ ] **Step 5: Commit:** `feat(prestamos): prestados e indicadores de estado leen prc_bloqueo`.

---

### Task 7: Pantalla con `.dfm`, pintura y apertura en el shell

**Files:** Create `UProcesoPintura.pas`, `Pruebas/UPruebasProcesoPintura.pas`, `UPrestamosForm.pas`, `UPrestamosForm.dfm`; Modify `UMAINFORM.pas`, `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`, `UClasificadorBase.pas`; Delete `UProcesoBase.pas`, `UProcesoDemo.pas`.

**Interfaces:**
- `UProcesoPintura` (solo `Vcl.Graphics`, `System.Types`; sin controles):
  - `TIndicadorTarjeta = record Texto: string; Valor: Integer; Alerta: Boolean; end`, `TPestanaVista = record Texto: string; Conteo: Integer; Alerta: Boolean; end`
  - `procedure PintarTarjetas(C: TCanvas; const Area: TRect; const Items: array of TIndicadorTarjeta; const T: TTemaColores; Escala: Integer)`
  - `function DisenarPestanas(C: TCanvas; const Items: array of TPestanaVista; Alto, Escala: Integer): TArray<TRect>` y `procedure PintarPestanas(C: TCanvas; const Area: TRect; const Items: array of TPestanaVista; const Rects: TArray<TRect>; Activa: Integer; const T: TTemaColores; Escala: Integer)`; `function PestanaEn(const Rects: TArray<TRect>; X, Y: Integer): Integer` (−1 si ninguna; pura)
  - `procedure PintarPasos(C: TCanvas; const Area: TRect; Tipo: TTipoProceso; const Nombres: array of string; PasoActual: Integer; Estado: TEstadoProceso; const T: TTemaColores; Escala: Integer)` (usa `EstadoDelPaso`)
  - Es el pintado de `UProcesoBase` movido sin cambiar su aspecto.
- `IPantallaProceso = interface` (en `UProcesoPintura` no; en una unidad `UPantallaProceso.pas` puras sin VCL salvo `TWinControl`): `procedure Embeber(Host: TWinControl); function PuedeSalir: Boolean; procedure FijarAlSalir(const Valor: TNotifyEvent);`
- `TfrmPrestamos = class(TForm, IPantallaProceso)` en `UPrestamosForm.pas/.dfm` y `function CrearPantallaPrestamos(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>; Alcance: TAlcanceUsuario; const Usuario: string): TfrmPrestamos`.
- `TMAIN.AbrirProceso` acepta `IPantallaProceso` + `TForm` (nuevo campo `FProceso: TForm`); `CerrarClasificador` pregunta a quien esté abierto (clasificador o proceso).

**Diseño del `.dfm`** (maqueta A1 y A2; todo en el `.dfm`):
- `pnlCabecera` (alTop): título «Préstamos», subtítulo, `edtBuscar` (`TcxTextEdit`), `btnExportar` y `btnNuevo` (`TcxButton`).
- `pbIndicadores` (`TPaintBox` en `pnlIndicadores`, alTop), `pbPestanas` (`TPaintBox` en `pnlPestanas`, alTop), `pbPasos` (`TPaintBox` en `pnlPasos`, alTop, oculto salvo en la ficha).
- `grdPrestamos` (`TcxGrid` con `TcxGridTableView` **sin enlace a datos**, columnas definidas en el `.dfm`: N.º, Solicitante, Entidad, Unidades, Fecha, Devolver antes de, Estado) en `pnlLista` (alClient).
- `pnlLateral` (alRight, 440 px) con dos páginas de paneles apilados, `pnlFicha` y `pnlNuevo`; `pnlFicha`: etiquetas y `TcxTextEdit`/`TcxDateEdit` de solo lectura con los datos del préstamo, `lstDocumentos` (`TcxGrid` sin enlace), botones `btnEntrega`, `btnDevolucion`, `btnRenovar`, `btnImprimirSolicitud`, `btnCancelarPrestamo`; `pnlNuevo`: `cboTipoUsuario` (`TcxComboBox`), `edtSolicitante`, `edtCarnet`, `edtEntidad`, `dteLimite`, `edtBuscarDoc`, `grdBuscarDoc` (`TcxGrid` sin enlace), `lstElegidos` (`TcxGrid`), `btnRegistrar`, `btnGuardarSolicitud`, `btnCerrarNuevo`.
- Colores y fuentes por defecto en el `.dfm` con la paleta clara (los adapta `UAparienciaLegacy` al tema); el código solo cambia color en tiempo de ejecución para los estados (rojo/verde).

- [ ] **Step 1: Pruebas** (`UPruebasProcesoPintura`, consola con `TBitmap.Canvas`): `PestanaEnEncuentraLaPestanaBajoElPunto`, `PestanaEnFueraDevuelveMenosUno`, `DisenarPestanasNoSolapaYCreceConElTexto`, `DisenarPestanasConInsigniaEsMasAnchaQueSin`.
- [ ] **Step 2: Ejecutar; falla.** **Step 3: Implementar `UProcesoPintura`** moviendo el pintado de `UProcesoBase`.
- [ ] **Step 4: Escribir `UPrestamosForm.dfm` y `.pas`** (campos publicados = componentes del `.dfm`; `uses` de cada unidad DevExpress/VCL usada). El `.pas` carga `ListarPrestamos`, `IndicadoresPrestamo`, aplica pestañas como filtro (`TFiltroPrestamo`), abre la ficha al elegir fila (`DocumentosDelPrestamo`, tira de pasos según `EstadoDelPaso`), y las acciones llaman a `UPrestamosDatos` con confirmación por `TMensajes`. Cada operación recarga la lista y los indicadores. Estados vencido/por vencer en rojo/ámbar.
- [ ] **Step 5: Enganchar en `UMAINFORM`:** `IPantallaProceso`, `AbrirProceso` genérico, `ShellSeccion` → `CrearPantallaPrestamos` (con `procesos_clasico.flag`, sin shell o ante un error se usa `P3.Click`); eliminar el desvío `ARCHIGENIO_PROCESOS_DEMO` y `AbrirProcesoDemo`; borrar `UProcesoBase`/`UProcesoDemo` del disco, del `.dpr` y retirar los accesores de `UClasificadorBase` si ya nadie los usa.
- [ ] **Step 6: Compilar la aplicación** (`ArchiGenioPro.dproj`; esperado 0 errores) y **verificar con un arnés temporal** (como en F0, fuera del repo al terminar) que el formulario se crea desde su `.dfm` sin errores de propiedades y que las capturas de la lista, la ficha y «nuevo préstamo» coinciden con las maquetas A1 y A2 en claro. Anotar en la lista de verificación lo que quede sin probar (tema oscuro, DPI, uso real con base).
- [ ] **Step 7: Commit:** `feat(prestamos): pantalla de prestamos con dfm, embebida en el shell`.

---

### Task 8: Impresos oficiales (FastReport)

**Files:** Create `ReportesYoyo/rSolicitudPrestamo.fr3`, `ReportesYoyo/rRegistroPrestamos.fr3`, `UPrestamosImpresos.pas`; Modify `UPrestamosForm.pas`, `ArchiGenioPro.dpr`.

**Interfaces:**
- Produces: `procedure ImprimirSolicitud(Conn: TFDConnection; IdProceso: Integer; const CarpetaReportes: string)` y `procedure ImprimirRegistro(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>; Anio: Integer; const CarpetaReportes: string)`. Cargan los `.fr3` con `TfrxReport.LoadFromFile`, les pasan los datos con `TfrxUserDataSet`/`TfrxDBDataset` sobre consultas locales (sin credenciales de conexión en el informe) y muestran la vista previa. Contenido según los anexos 8.2 (solicitante, carnet, documento, fecha de entrega, atendido por, firma, fecha de devolución) y 8.3 (n.º, solicitante, serie, fecha de solicitud, fecha de devolución, entidad, observaciones; año en el título).
- [ ] **Step 1: Escribir los `.fr3`** a mano (XML de FastReport con un `TfrxMemoView` por campo y una `TfrxMasterData` para el registro) y `UPrestamosImpresos`. Los `.fr3` quedan abiertos en el diseñador de FastReport para que el usuario los retoque.
- [ ] **Step 2: Compilar** la aplicación (0 errores). **Step 3: Probar en el arnés** que ambos informes cargan y generan una página con datos de ejemplo (sin base) y guardar la captura. Lo que no se pueda probar sin base se anota en la lista de verificación.
- [ ] **Step 4: Commit:** `feat(prestamos): impresos de solicitud (8.2) y registro (8.3)`.

---

### Task 9: Migración en el arranque, documentación y cierre

**Files:** Modify `UCapaDatos.pas`, `CLAUDE.md`, `docs/superpowers/plans/2026-11-12-verificacion-procesos-f0.md`; Create `docs/superpowers/plans/2026-11-12-verificacion-prestamos-f1.md`.

- [ ] **Step 1:** llamar a `MigrarPrestamosViejos` una sola vez tras `CrearEsquemaProcesos` en `UpDateDB` (solo SQL Server en esta fase; en Access queda por probar), registrando el informe en el log de auditoría; un fallo no impide el arranque.
- [ ] **Step 2:** actualizar `CLAUDE.md` (Préstamos nuevo, regla de los `.dfm`, `UPrestamos` obsoleta y conservada bajo `procesos_clasico.flag`, retiro del demo) y escribir la lista de verificación de F1.
- [ ] **Step 3:** suite completa y compilación final; commit `docs(prestamos): lista de verificacion y notas de F1`.

---

## Autorrevisión

- **Cobertura del diseño (§5):** estados y vencimientos → T2; datos y reglas (candado, renovar, devolver, cancelar) → T4; impresos 8.2/8.3 → T8; indicadores y pestañas → T4/T7; aviso en Inicio (prestados) → T6; migración → T5/T9; pantallas por código **sustituidas por `.dfm`** por petición del usuario → T7. Fuera de F1 a propósito: transferencias y depuración, y la ruta de préstamo por caja (se presta por documento; la caja se expande en F2).
- **Consistencia de tipos:** `TUnidadDoc` (con `CodSubs`, T1) lo usan T4, T5 y T7; `TSolicitudPrestamo`/`TEstadoPrestamo` (T2) los usan T4 y T7; `TFiltroPrestamo`, `TPrestamoFila`, `TIndicadoresPrestamo` (T4) los usa T7; `IPantallaProceso` (T7) lo usa `UMAINFORM`.
- **Pendiente de confirmar en ejecución:** nombres exactos de propiedades de los componentes DevExpress al escribir el `.dfm` (se copian de `.dfm` ya existentes en el proyecto); formato `.fr3` de la versión instalada de FastReport (se copia el de un informe existente de `ReportesYoyo/`).
