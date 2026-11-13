# Procesos archivísticos, F2: Transferencias, parte del remitente (pasos 1 a 4) — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que el archivo de gestión pueda preparar y entregar una transferencia completa: propuesta por plazo vencido, autorización de la Comisión, cajas numeradas con verificaciones, entrega y los impresos oficiales (Relación de entrega, Anexo 16, y etiquetas de caja), todo en una pantalla con `.dfm`.

**Architecture:** Igual que F1: reglas y datos sin VCL (`UTransferenciasReglas`, `UTransferenciasDatos`) sobre las tablas `prc_*` de F0 más cuatro nuevas; pantalla con `.dfm` (`UTransferenciasForm`) con `TPaintBox` para tarjetas y tira de pasos (`UProcesoPintura`); impresos FastReport sin conexión (`UTransferenciasImpresos`). La recepción en el archivo central (pasos 5 y 6) es F3.

**Tech Stack:** Delphi 10.3 VCL, FireDAC (SQL Server y Access), DevExpress, FastReport, DUnitX.

**Spec:** `docs/superpowers/specs/2026-11-12-prestamos-transferencias-depuracion-design.md` (secciones 6, 9, 10). Maqueta aprobada: B1 a B3. Base: planes F0 y F1 (mismas restricciones globales; se repiten las que cambian el trabajo).

## Global Constraints

- **Cada pantalla nueva lleva su `.dfm`** (petición del usuario): diseño en el `.dfm`; el código solo llena datos y reacciona a eventos. Solo componentes que el IDE abre sin paquetes propios (VCL estándar y DevExpress ya usados). Tablas sin enlace a datos, columnas en el `.dfm`. Controles de acción anclados al fondo y tablas elásticas (lección de F1: evitar textos superpuestos con escalas de 125 % o más; probar a 125 %).
- Fuentes `.pas`/`.dfm` en Windows‑1252 con CRLF; `.dfm` en ASCII con `#NNN`; unidades sin pantalla en ASCII. Mensajes por `TMensajes`. SQL válido en SQL Server y Access, parametrizado (sin `CASE`, `TOP n` permitido).
- Retención: `cl_subseries.tgestion` = años en archivo de gestión; un documento vence cuando `FechaBase + tgestion años <= hoy`, con `FechaBase = FechaFin` si existe, si no `Fecha`. `tgestion = 0` = sin plazo definido: **nunca se propone**. Solo se proponen documentos cuyo archivo (`tb_SeriesDatos.Archivo` → `cl_ArchivosGestion.Tipo` → `cl_tipoarch.tipoarch`) es de tipo *Gestión* (texto que empieza por «Gesti»).
- Un expediente (`IDExpediente` no vacío, junto con `codsubs`) **no se divide entre cajas**.
- El candado cruzado (F0) vale: los documentos de la transferencia quedan retenidos en `prc_bloqueo` mientras el proceso esté abierto; los préstamos abiertos los excluyen de la propuesta.
- No conectarse a bases con credenciales del código; las pruebas de BD usan `ARCHIGENIO_TEST_DB` y se omiten sin ella. El ejecutable puede estar en uso por el usuario: si `ArchiGenioPro.exe` no se puede escribir, la compilación del código igual vale (error F2039 solo al enlazar).
- Commits solo de los archivos de la tarea; rutas bajo `scripts/` en minúscula. Cierre: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Review Focus

1. **Documento sin `Fecha` válida, con `FechaFin` anterior a `Fecha`, o subserie con `tgestion = 0`:** no revienta ni se propone por error.
2. **Expediente más grande que la capacidad de la caja** y varios expedientes pequeños seguidos: cada expediente completo en una sola caja; numeración consecutiva sin huecos y la misma serie contigua.
3. **Reasignar cajas** tras agregar/quitar documentos: no deja filas de caja huérfanas ni documentos sin caja.
4. **Dos usuarios proponen y agregan los mismos documentos a la vez:** uno gana y el otro recibe el aviso (clave primaria de `prc_bloqueo`), sin dejar el proceso a medias.
5. **Avanzar a «Entrega» sin verificaciones completas o con documentos sin caja:** se rechaza y dice qué falta.

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `UEsquemaProcesos.pas`, `scripts/procesos_tablas.sql` (modifican) | Tablas `prc_transferencia`, `prc_cronograma`, `prc_caja`, `prc_verificacion`. |
| `UTransferenciasReglas.pas` (nuevo) | Vencimiento, cronograma, verificaciones y reparto en cajas. Puro. |
| `UTransferenciasDatos.pas` (nuevo) | Propuesta, alta, agregar grupos, cajas, verificaciones, condiciones, avance, entrega, listados, cronograma y relación. |
| `UTransferenciasForm.pas` + `.dfm` (nuevos) | Pantalla: lista con cronograma y detalle por pasos. |
| `UTransferenciasImpresos.pas` + dos `.fr3` en `MAISEL REPORT/Report/` (nuevos) | Relación de entrega (Anexo 16) y etiquetas de caja. |
| `UMAINFORM.pas`, ambos `.dpr`, `CLAUDE.md` (modifican) | Enganche en la sección «Traslados», registro de unidades, notas. |

---

### Task 1: Esquema

**Files:** Modify `UEsquemaProcesos.pas`, `scripts/procesos_tablas.sql`, `Pruebas/UPruebasEsquemaProcesos.pas`.

**Interfaces — Produces** (mismo estilo y tipos que las tablas de F0):
- `prc_transferencia(IdProceso INT PK FK→prc_proceso CASCADE, FPrevista DATETIME NULL, FEntrega DATETIME NULL, EntregadoPor VARCHAR(100) NULL, Obs VARCHAR(255) NULL)`
- `prc_cronograma(IdCronograma autonumérico PK, Anio INT NOT NULL, IdEstructura VARCHAR(50) NOT NULL, IdNodo INT NOT NULL, FPrevista DATETIME NOT NULL, IdProceso INT NULL, UNIQUE (Anio, IdEstructura, IdNodo), FK (IdEstructura, IdNodo)→tb_tree)`
- `prc_caja(IdProceso INT NOT NULL, Caja INT NOT NULL, Tipo VARCHAR(100) NULL, Descripcion VARCHAR(255) NULL, FDesde DATETIME NULL, FHasta DATETIME NULL, Unidades INT NOT NULL, PK (IdProceso, Caja), FK→prc_proceso CASCADE)`
- `prc_verificacion(IdProceso INT NOT NULL, Codigo VARCHAR(30) NOT NULL, Marcada BIT, PK (IdProceso, Codigo), FK→prc_proceso CASCADE)`
- Índice `IX_prc_unidad_caja` sobre `prc_unidad (IdProceso, Caja)`.

- [ ] **Step 1: Pruebas** en `TPruebasEsquemaProcesosSql`: las cuatro tablas con guarda `IF OBJECT_ID`, `UNIQUE (Anio, IdEstructura, IdNodo)`, claves primarias de `prc_caja` y `prc_verificacion`, el índice; actualizar el conteo de índices (5) y la lista `TABLAS` de las pruebas de BD (10 tablas).
- [ ] **Step 2:** compilar y ejecutar; falla. **Step 3:** implementar y copiar al `.sql`. **Step 4:** ejecutar; pasa.
- [ ] **Step 5: Commit** `feat(transferencias): tablas de transferencia, cronograma, cajas y verificaciones`.

---

### Task 2: Reglas (`UTransferenciasReglas`)

**Files:** Create `UTransferenciasReglas.pas`, `Pruebas/UPruebasTransferenciasReglas.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces — Produces:**
- `function FechaCorte(Hoy: TDateTime; AniosGestion: Integer): TDateTime` — `Hoy` menos `AniosGestion` años (con `IncYear`); `AniosGestion <= 0` devuelve 0 (= sin plazo).
- `function PlazoVencido(Fecha, FechaFin: TDateTime; HayFechaFin: Boolean; AniosGestion: Integer; Hoy: TDateTime): Boolean` — falso si `AniosGestion <= 0` o `Fecha = 0`; usa `FechaFin` si hay y no es anterior a `Fecha`, si no `Fecha`.
- `TEstadoCronograma = (ecProgramada, ecAtrasada, ecEnTramite, ecRealizada)` y `function EstadoCronograma(FPrevista: TDateTime; HayProceso: Boolean; Finalizado: Boolean; Hoy: TDateTime): TEstadoCronograma` — realizada si finalizado; en trámite si hay proceso abierto; atrasada si `Trunc(FPrevista) < Trunc(Hoy)`; si no, programada.
- Verificaciones: `const VERIFICACIONES: array[0..4] of record Codigo, Texto: string` con códigos `'unicos'` (ejemplares únicos, no copias), `'completos'` (expedientes completos y en buen estado, sin presillas ni clips), `'sindividir'` (ningún expediente dividido en cajas distintas), `'etiquetas'` (listado pegado en el exterior de cada caja), `'prestamos'` (sin documentos en préstamo); `function VerificacionesCompletas(const Marcadas: array of string): Boolean` y `function VerificacionesFaltan(const Marcadas: array of string): TArray<string>` (códigos que faltan).
- `TItemCaja = record Grupo: string; Orden: Integer; end` (`Grupo` = `codsubs|IDExpediente` o `codsubs|doc` si no hay expediente: el conjunto que no se parte) y `function RepartirEnCajas(const Items: TArray<TItemCaja>; Capacidad, PrimeraCaja: Integer): TArray<Integer>` — devuelve la caja de cada item en el mismo orden de entrada; recorre los items por `Orden`; abre una caja nueva cuando el grupo siguiente no cabe (`Capacidad` unidades por caja), salvo que la caja esté vacía; un grupo mayor que la capacidad ocupa una caja propia; el mismo grupo nunca se divide; cajas consecutivas desde `PrimeraCaja` sin huecos; `Capacidad <= 0` se trata como 20.
- `function TextoEstadoTransferencia(Paso: Integer; Estado: TEstadoProceso): string` (`'Propuesta'`, `'Esperando comisi'#243'n'`, `'En preparaci'#243'n'`, `'Entregada'`, `'En recepci'#243'n'`, `'En ubicaci'#243'n'`, `'Completada'`, `'Cancelada'`).

- [ ] **Step 1: Pruebas** (nombres): `VencidoCuandoPasanLosAnios`, `NoVenceAntesDeTiempo`, `SinPlazoNuncaVence` (Review Focus 1), `FechaFinAnteriorAFechaSeIgnora`, `SinFechaNoVence`, `FechaCorteResta​AniosYCeroSinPlazo`, `CronogramaAtrasadaYProgramada`, `CronogramaEnTramiteYRealizada`, `TodasLasVerificacionesMarcadas`, `FaltanVerificacionesDicenCuales`, `CajasNoPartenUnExpediente`, `ExpedienteMayorQueLaCapacidadVaSolo` y `NumeracionConsecutivaSinHuecos` (Review Focus 2), `GrupoDistintoAbreCajaCuandoNoCabe`, `RespetaElOrdenYLaPrimeraCaja`, `TextoDeEstados`.
- [ ] **Step 2:** ejecutar; falla. **Step 3:** implementar. **Step 4:** ejecutar; pasa.
- [ ] **Step 5: Commit** `feat(transferencias): reglas de vencimiento, cronograma, verificaciones y cajas`.

---

### Task 3: Datos (`UTransferenciasDatos`)

**Files:** Create `UTransferenciasDatos.pas`, `Pruebas/UPruebasTransferenciasDatos.pas`; Modify `Pruebas/PruebasArchiGenio.dpr`.

**Interfaces — Consumes:** `UProcesosDatos` (`CrearProceso`, `AvanzarPaso`, `CancelarProceso`, `LeerProceso`, `GuardarAutorizacion`, `BloqueosDelNodo`, `IniciarTx`, `ConfirmarTx`, `DeshacerTx`, `EstadoDesdeCodigo`), `UTransferenciasReglas`. **Produces** (todas con `Conn: TFDConnection`, parametrizadas y transaccionales):
- `TGrupoPropuesto = record IdEstructura: string; IdNodo: Integer; CodSubs, Serie, Subserie: string; Anios: Integer; Unidades, EnPrestamo: Integer; Desde, Hasta: TDateTime; end`
- `function ProponerTransferencia(Conn; const Nodos: TArray<TClaveNodo>; Hoy: TDateTime): TArray<TGrupoPropuesto>` — un grupo por (nodo, subserie) con documentos vencidos de archivo de gestión; consulta una por subserie distinta (corte de fecha con `FechaCorte`), nunca por documento; `Unidades` = los disponibles (no retenidos por ningún proceso abierto) y `EnPrestamo` = los vencidos retenidos.
- `function CrearTransferencia(Conn; const Nodo: TClaveNodo; const Usuario: string; Anio: Integer; FPrevista: TDateTime): TProcesoRef` — proceso tipo `tpTransferencia` + fila en `prc_transferencia`.
- `function AgregarGrupo(Conn; IdProceso: Integer; const G: TGrupoPropuesto; Hoy: TDateTime; out Agregados: Integer; out Motivo: string): Boolean` — en una transacción, `INSERT … SELECT` en `prc_bloqueo` y luego en `prc_unidad` de los documentos vencidos del grupo que no estén retenidos; solo con el proceso en paso 1; `False` con `Motivo` si falla (p. ej. otro usuario se los llevó, Review Focus 4).
- `procedure QuitarGrupo(Conn; IdProceso: Integer; const IdEstructura: string; IdNodo: Integer; const CodSubs: string)` — libera `prc_bloqueo` y borra `prc_unidad`/`prc_caja` afectadas (solo paso ≤ 3).
- `function ContarUnidades(Conn; IdProceso: Integer): Integer`.
- `procedure NumerarCajas(Conn; IdProceso: Integer; Capacidad: Integer)` — lee las unidades ordenadas por serie, subserie, fecha y código; arma `TItemCaja` (grupo por expediente); `RepartirEnCajas`; actualiza `prc_unidad.Caja`; reconstruye `prc_caja` (tipo = subserie, descripción = «Serie · Subserie», fechas extremas, unidades) sin dejar filas huérfanas (Review Focus 3).
- `function MarcarVerificacion(Conn; IdProceso: Integer; const Codigo: string; Marcada: Boolean)`; `function VerificacionesMarcadas(Conn; IdProceso: Integer): TArray<string>`.
- `function CondicionesCumplidas(Conn; IdProceso: Integer; out Faltan: TArray<string>): TCondiciones` — `cdAutorizado` si hay fila en `prc_autorizacion`; `cdSinBloqueos` si el proceso tiene unidades y todas están en `prc_bloqueo` propio; `cdVerificacionesCompletas` si están las cinco marcadas **y** toda unidad tiene caja (Review Focus 5); `Faltan` lista frases legibles.
- `function AvanzarTransferencia(Conn; IdProceso, PasoLeido: Integer; const Usuario: string; out Faltan: TArray<string>): Boolean` — calcula condiciones y llama `AvanzarPaso`.
- `function RegistrarEntregaTransferencia(Conn; IdProceso: Integer; const Usuario, EntregadoPor: string; Fecha: TDateTime): Boolean` — paso 4 → 5; guarda `FEntrega` y `EntregadoPor`.
- `TTransferenciaFila = record IdProceso, Anio, Consecutivo, Paso: Integer; Numero, Remitente, Estado: string; FPrevista, FEntrega: TDateTime; Cajas, Unidades: Integer; Proceso: TEstadoProceso; end` y `function ListarTransferencias(Conn; const Nodos: TArray<TClaveNodo>; Anio: Integer; Limite: Integer): TArray<TTransferenciaFila>`.
- Cronograma: `TCronogramaFila = record IdCronograma, Anio: Integer; IdEstructura: string; IdNodo: Integer; Etiqueta: string; FPrevista: TDateTime; IdProceso: Integer; Estado: TEstadoCronograma; end`; `procedure ProgramarTransferencia(Conn; const Nodo: TClaveNodo; Anio: Integer; FPrevista: TDateTime)` (inserta o actualiza la fecha); `function ListarCronograma(Conn; const Nodos: TArray<TClaveNodo>; Anio: Integer; Hoy: TDateTime): TArray<TCronogramaFila>`; al crear una transferencia se enlaza con su cronograma si existe.
- `TLineaRelacion = record Numero: Integer; Desde, Hasta: TDateTime; Tipo, Descripcion: string; Caja, Unidades: Integer; end` y `function RelacionDeEntrega(Conn; IdProceso: Integer): TArray<TLineaRelacion>` (una línea por caja).

- [ ] **Step 1: Pruebas.** Puras (se ejecutan): construcción de las condiciones de fecha del grupo y del SQL de listados que se expongan como funciones (`SqlDocumentosVencidos(Corte: …)`), y el armado de `TItemCaja` desde filas. De BD (se omiten sin base): `ProponerSoloVencidosDeArchivoDeGestion`, `ProponerIgnoraSubserieSinPlazo`, `ProponerCuentaLosEnPrestamo`, `AgregarGrupoBloqueaLosDocumentos`, `AgregarGrupoDosVecesNoDuplica`, `AgregarGrupoConcurrenteUnoGana`, `QuitarGrupoLibera`, `NumerarCajasNoPartePorExpediente`, `NumerarCajasEsIdempotenteYSinHuerfanas`, `CondicionesFaltanSinAutorizacion`, `CondicionesFaltanVerificacionesYCajas`, `AvanzarHastaEntrega`, `EntregaGuardaFechaYPasoCinco`, `ListarTransferenciasPorAnio`, `CronogramaEstadoAtrasado`, `RelacionTieneUnaLineaPorCaja`.
- [ ] **Step 2:** ejecutar; falla. **Step 3:** implementar. **Step 4:** ejecutar (las de BD se omiten sin `ARCHIGENIO_TEST_DB`; documentarlo).
- [ ] **Step 5: Commit** `feat(transferencias): acceso a datos de la transferencia (propuesta, cajas, verificaciones, entrega, cronograma)`.

---

### Task 4: Pantalla con `.dfm` y enganche en el shell

**Files:** Create `UTransferenciasForm.pas`, `UTransferenciasForm.dfm`; Modify `UMAINFORM.pas` (sección `SECCION_TRASLADOS`, `AbrirTransferencias`), `ArchiGenioPro.dpr`.

**Interfaces — Consumes:** `IPantallaProceso`, `UProcesoPintura` (tarjetas, pestañas, pasos), Task 3. **Produces:** `TfrmTransferencias`… **nombre real: `TfrmTransferenciasNuevo`** (el nombre `TfrmTransferencias` ya lo usa la pantalla vieja `UTransferencias`) con `procedure Iniciar(Conn; const Nodos; const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario; const Usuario: string)`, `property PuedeActuar: Boolean`, `property AlImprimirRelacion: TImprimirTransferencia`, `property AlImprimirEtiquetas: TImprimirTransferencia`, métodos públicos `Mostrar*` para verificar sin base, y `function CrearPantallaTransferencias(...)`.

**Diseño del `.dfm`** (maquetas B1 a B4, todo en el `.dfm`):
- Cabecera (título, buscador, botones «Cronograma», «Nueva transferencia») en un panel `alRight` sin anclajes.
- **Vista lista** (`pnlLista`): tarjetas del cronograma (`TPaintBox` o fichas), pestañas/estado y tabla `grdTransferencias` (N.º, Remitente, Series, Cajas, Fecha prevista, Paso, Estado).
- **Vista detalle** (`pnlDetalle`, ocupa todo el área al abrir una transferencia, con «‹ Volver»): tira de pasos (`TPaintBox`) y debajo cuatro paneles apilados, uno por paso:
  1. *Propuesta*: tabla `grdPropuesta` (casilla elegir, Serie/subserie, Años, Unidades, Plazo, Venció, Observación «N en préstamo») y botón «Agregar a la transferencia».
  2. *Comisión*: campos de acta, acuerdo y fecha (`TcxTextEdit`, `TcxDateEdit`) y botón «Registrar autorización»; mensajes de validación.
  3. *Preparación*: tabla de cajas (`grdCajas`), botón «Numerar cajas» con capacidad por caja (`TcxSpinEdit`), lista de verificaciones con casillas (`TCheckBox`) y qué falta.
  4. *Entrega*: fecha, entregado por, botón «Registrar entrega» y accesos «Imprimir relación de entrega» y «Etiquetas de caja».
- Botones «Pasar al siguiente paso» y «Cancelar transferencia» en una barra inferior anclada al fondo.
- Reglas de calidad de F1 (todo anclado al fondo/derecha donde corresponde, sin posiciones que dependan de 1280 px; probar a 125 %).

- [ ] **Step 1:** escribir el `.dfm` y el `.pas` (campos publicados = componentes; `AplicarTema` como en F1).
- [ ] **Step 2:** enganchar `TMAIN.AbrirTransferencias` (nodos como en Préstamos; respaldo a `btnTransfer.Click` con `procesos_clasico.flag`, sin shell o ante un error) y agregar las unidades a `ArchiGenioPro.dpr`. **Step 3:** compilar el código (0 errores aparte de un posible `F2039` al enlazar si el `.exe` está en uso).
- [ ] **Step 4: Verificación visual** con un arnés temporal (fuera del repo al terminar) que cree el formulario desde su `.dfm`, le pase datos de ejemplo por los métodos `Mostrar*` y capture lista, propuesta, comisión, preparación y entrega a 125 %; revisar que no haya textos superpuestos ni recortados.
- [ ] **Step 5: Commit** `feat(transferencias): pantalla de transferencias con dfm, embebida en el shell`.

---

### Task 5: Impresos oficiales

**Files:** Create `UTransferenciasImpresos.pas`, `MAISEL REPORT/Report/rRelacionEntrega.fr3`, `MAISEL REPORT/Report/rEtiquetasCaja.fr3`; Modify `UTransferenciasForm.pas`, `UMAINFORM.pas`, `ArchiGenioPro.dpr`.

**Interfaces — Produces:** `function PrepararRelacion(const Fr3, Empresa: string; const Cab: TDatosRelacion; const Lineas: TArray<TLineaRelacion>): TfrxReport` (variables `Empresa`, `Remitente`, `FTransferencia`, `Numero`, `Entrada` y dataset `Relacion` con `Numero, Desde, Hasta, Tipo, Descripcion, Caja`; pie con firmas de quien entrega y quien recibe; casillas «Para uso del archivo receptor»), `function PrepararEtiquetas(const Fr3: string; const Cab: TDatosRelacion; const Cajas: TArray<TLineaRelacion>): TfrxReport` (una etiqueta por caja con remitente, n.º de caja y su listado) y `procedure ImprimirRelacion(Conn; IdProceso; const Carpeta: string)` / `ImprimirEtiquetas(...)`. Mismo mecanismo que F1 (sin `<Datasets>` en el `.fr3`; el dataset se asigna a la banda `MasterData1`).

- [ ] **Step 1:** generar los `.fr3` con un script (como en F1) y escribir la unidad. **Step 2:** arnés temporal que genere los PDF con datos de ejemplo; revisarlos. **Step 3:** conectar los botones de la pantalla; compilar. **Step 4: Commit** `feat(transferencias): relacion de entrega (Anexo 16) y etiquetas de caja`.

---

### Task 6: Documentación y cierre

**Files:** Modify `CLAUDE.md`; Create `docs/superpowers/plans/2026-11-12-verificacion-transferencias-f2.md`.

- [ ] **Step 1:** nota en `CLAUDE.md` (F2 hecha, retención, cajas, candado, pantalla, impresos, lo no probado). **Step 2:** lista de verificación manual (base real, concurrencia, escalas, impresos). **Step 3:** suite completa y compilación; commit `docs(transferencias): lista de verificacion y notas de F2`.

---

## Autorrevisión

- **Cobertura del diseño (§6, pasos 1 a 4):** propuesta por plazo vencido y cronograma → T2/T3/T4; comisión (acta y acuerdo con `ocCentral`) → T3 usa `GuardarAutorizacion`; cajas, verificaciones y relación → T2/T3/T5; entrega → T3/T4. Fuera de F2 a propósito: recepción, registro de entrada, topografía, cuarentena e incidencias (F3), migración y retiro de `UTransferencias`/`UProgresoTransferencia` (F3).
- **Consistencia de tipos:** `TCondiciones`, `TEstadoCronograma`, `TGrupoPropuesto`, `TLineaRelacion` se definen en T2/T3 y los usan T4/T5; el nombre de la pantalla nueva evita chocar con `TfrmTransferencias` (pantalla vieja).
- **Pendiente de confirmar en ejecución:** que `cl_tipoarch`/`cl_ArchivosGestion` tengan las columnas descritas en la base real (el SQL de propuesta se escribe contra ellas) y el valor real de `tgestion` en la unidad «años».
