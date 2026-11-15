# Transferencias F3 (recepcion, ubicacion por caja y traspaso) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que los pasos 5 y 6 de una transferencia registren la recepcion por caja y la ubicacion por caja, y que al cerrar los documentos pasen al archivo central con su nueva topografia, quedando marcados como transferidos en el origen.

**Architecture:** Reglas puras en `UTransferenciasReglas` (con pruebas), datos en `UTransferenciasDatos` (FireDAC, SQL valido en SQL Server y Access, una transaccion para el cierre), esquema en `UEsquemaProcesos`, consulta compartida de "transferido" en una unidad nueva sin VCL, y pantalla ampliada en `UTransferenciasForm` + `.dfm`. Los documentos transferidos se bloquean para prestar/editar/transferir consultando esa unidad.

**Tech Stack:** Delphi 10.3, FireDAC, DUnitX (`Pruebas/`), FastReport, SQL Server (Access sin base de prueba).

**Spec:** `docs/superpowers/specs/2026-11-15-transferencias-f3-recepcion-ubicacion.md` (disenos previos: `2026-11-12-prestamos-transferencias-depuracion-design.md` seccion 6).

## Global Constraints

- Codigo nuevo en ASCII puro (acentos con `#243` etc. como en `ValidarRecepcion`); los archivos viejos son ANSI/CRLF: editar sin cambiar codificacion ni BOM.
- Mensajes al usuario solo por `TMensajes`. Toda interfaz nueva lleva `.dfm` (solo VCL estandar y DevExpress ya usados; nunca `TBotonShell`/`TCajaBusqueda`).
- SQL valido en SQL Server y Access: nada de `UPDATE ... FROM`; usar `WHERE EXISTS (SELECT ...)` correlacionado.
- Solo el EGD del nodo actua (`PuedeActuar`). El Administrador no transfiere.
- Longitudes de `tb_SeriesDatos`: `deposito` 255, `gaveta` 20, `posicion` 10.
- Compilar con `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`; ejecutar la suite con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` (ver memoria `reference_bd_pruebas_local`). Linea base: 827 pasan, 0 fallan, 0 errores.
- Commits sin tocar `Win32/Debug/*.dcu` ni `ArchiGenioPro.identcache`. Terminar cada mensaje con `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Decisiones del plan (a confirmar con el usuario; cambian el spec)

1. **Cuarentena y faltantes se resuelven en el paso 5, antes de pasar al 6.** El spec decia que la cuarentena no impedia cerrar; se simplifica: el paso 6 solo recibe cajas *recibidas*. Una caja *faltante* genera una incidencia y sus documentos se sacan de la transferencia (`prc_unidad.Activa = 0`, bloqueo liberado): se quedan en el origen y pueden proponerse otra vez.
2. **Numero de caja:** el documento no tiene columna de caja; hereda `deposito`/`gaveta`/`posicion` de su caja y el numero de caja se conserva en `prc_unidad.Caja` (el acta).
3. **Plazo de reclamacion** de una incidencia: 30 dias desde la recepcion (constante `PLAZO_RECLAMACION_DIAS`, valor provisional: el spec no lo fija).

## Review Focus

- Caja sin ninguna unidad activa o transferencia sin cajas: no debe poder pasar al paso 6 ni cerrar (mensaje claro, no excepcion tecnica).
- Cerrar dos veces / dos usuarios a la vez: la segunda llamada devuelve `False` y no repite el traspaso.
- Falla a mitad del cierre (por ejemplo un documento ya no existe): ningun documento queda a medio traspasar.
- `gaveta` de mas de 20 o `posicion` de mas de 10 caracteres: error de validacion, no truncado silencioso ni error de SQL.
- Documento transferido que alguien intenta prestar, editar o volver a proponer.
- Archivo destino que no es de tipo Central o que ya no existe.

---

### Task 0: Hacer no destructivo el test de migracion de `tb_nodo_egd`

**Files:**
- Modify: `Pruebas/UPruebasEsquema.pas` (`TPruebasEsquema.MigraClaveAntiguaSinPerderFilas`, ~linea 164)

**Interfaces:** Produces: ninguna.

- [ ] **Step 1:** Antes del `DELETE` del nodo, guardar sus filas (`user_id`) en una `TArray<string>`; en el `finally`, borrar solo las filas que el test inserto (`Usuario1`, `Usuario2`) y volver a insertar las guardadas. Hoy el `finally` borra todas las del nodo.
- [ ] **Step 2:** Anadir al final del test la comprobacion `Assert.AreEqual(Antes, ContarEgdDelNodo)` donde `Antes` es el conteo previo al test.
- [ ] **Step 3: Verify.** Run: `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y la suite con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`; despues `sqlcmd ... SELECT * FROM tb_nodo_egd`. Expected: 827 pasan y la tabla conserva sus filas y la clave `PK_tb_nodo_egd`.
- [ ] **Step 4: Commit** `test(esquema): la prueba de migracion de tb_nodo_egd restaura las filas del nodo`.

### Task 1: Esquema (columnas nuevas y `prc_incidencia`)

**Files:**
- Modify: `UEsquemaProcesos.pas` (junto a `Columna('prc_transferencia', 'Ubicacion', ...)`, ~linea 203), `SCRIPTS/procesos_tablas.sql`
- Test: `Pruebas/UPruebasEsquemaProcesos.pas`

**Interfaces:** Produces columnas y tabla que usan las tareas 3 y 4:
`prc_transferencia.IdArchivoDestino SMALLINT NULL`, `prc_transferencia.NumRegistroEntrada VARCHAR(30) NULL`;
`prc_caja.Deposito VARCHAR(255) NULL`, `Gaveta VARCHAR(20) NULL`, `Posicion VARCHAR(10) NULL`, `Estado VARCHAR(1) NOT NULL DEFAULT 'P'` (`P` pendiente, `R` recibida, `Q` cuarentena, `F` faltante), `Conservacion VARCHAR(255) NULL`;
`prc_incidencia (IdIncidencia autonumerico, IdProceso INT NOT NULL, Caja INT NULL, Tipo VARCHAR(20) NOT NULL, Descripcion VARCHAR(255) NULL, FechaLimite DATETIME NULL, Estado VARCHAR(1) NOT NULL, Usuario VARCHAR(100) NULL, Fecha DATETIME NULL)` con FK a `prc_proceso ON DELETE CASCADE`.

- [ ] **Step 1: Test** en `TPruebasEsquemaProcesosSql`: `SentenciasEsquemaProcesos(True)` y `(False)` contienen `prc_incidencia` y cada columna nueva; y en `TPruebasEsquemaProcesosBD` (omitido sin `ARCHIGENIO_TEST_DB`): tras `CrearEsquemaProcesos` dos veces, `INFORMATION_SCHEMA.COLUMNS` tiene `prc_caja.Estado` y `prc_incidencia` existe (idempotente).
- [ ] **Step 2:** Run la suite. Expected: FAIL (columna/tabla inexistente).
- [ ] **Step 3:** Agregar con `Columna(...)` las columnas de `prc_transferencia` y `prc_caja` (el `Estado` de `prc_caja` con valor por defecto `'P'` en ambos motores) y `Tabla('prc_incidencia', ...)` con el patron de `prc_caja`; un indice `IX_prc_incidencia_proceso` sobre `IdProceso`. Reflejar lo mismo en `SCRIPTS/procesos_tablas.sql`.
- [ ] **Step 4:** Run la suite. Expected: PASS, 0 errores.
- [ ] **Step 5: Commit** `feat(procesos): esquema de F3 (destino, cajas con ubicacion y estado, incidencias)`.

### Task 2: Reglas puras de recepcion y ubicacion por caja

**Files:**
- Modify: `UTransferenciasReglas.pas` (interfaz y `implementation`)
- Test: `Pruebas/UPruebasTransferenciasReglas.pas`

**Interfaces:** Produces (todas sin VCL):
```
type TEstadoCaja = (ecPendiente, ecRecibida, ecCuarentena, ecFaltante);
const PLAZO_RECLAMACION_DIAS = 30;
function EstadoCajaDesdeCodigo(const Codigo: string): TEstadoCaja;   // 'P','R','Q','F'; otro => ecPendiente
function CodigoDeEstadoCaja(E: TEstadoCaja): string;
function ValidarEntradaCentral(IdArchivoDestino: Integer; const NumRegistro: string): TArray<string>;
function CajasDecididas(const Estados: array of TEstadoCaja): Boolean;      // True si hay >= 1 caja y ninguna pendiente
function HayCajaRecibida(const Estados: array of TEstadoCaja): Boolean;
function ValidarUbicacionCaja(const Deposito, Gaveta, Posicion: string): TArray<string>;
function FechaLimiteReclamacion(FRecepcion: TDateTime): TDateTime;
```
`ValidarRecepcion` y `ValidarUbicacion` se conservan hasta la tarea 4 (que retira `ValidarUbicacion`).

- [ ] **Step 1: Tests** (nombres y aserciones):
  - `ValidarEntradaCentral_ExigeDestinoYRegistro`: `(0,'')` => 2 errores; `(3,'')` => 1; `(3,'  ')` => 1; `(3,'2026-0012')` => 0; `NumRegistro` de 31 caracteres => 1.
  - `CajasDecididas` (ninguna pendiente y al menos una caja): `[]` => False; `[ecRecibida, ecPendiente]` => False; `[ecRecibida, ecCuarentena, ecFaltante]` => True. La cuarentena la rechaza aparte la tarea 3.
  - `HayCajaRecibida`: `[ecFaltante]` => False; `[ecRecibida, ecFaltante]` => True; `[]` => False.
  - `ValidarUbicacionCaja`: vacios o `'0'` => un error por campo; `Gaveta` de 21 => 1 error; `Posicion` de 11 => 1; `Deposito` de 256 => 1; `('01','02','3')` => 0 (se aplica `Trim`).
  - `EstadoCajaDesdeCodigo('Q')` = `ecCuarentena`, `'x'` = `ecPendiente`; ida y vuelta con `CodigoDeEstadoCaja`.
  - `FechaLimiteReclamacion(EncodeDate(2026,11,1))` = `EncodeDate(2026,12,1)`.
- [ ] **Step 2:** Run la suite. Expected: FAIL (no compila).
- [ ] **Step 3:** Implementar en `UTransferenciasReglas.pas` con textos de error en espanol (acentos por `#NNN`).
- [ ] **Step 4:** Run la suite. Expected: PASS.
- [ ] **Step 5: Commit** `feat(transferencias): reglas de recepcion y ubicacion por caja`.

### Task 3: Datos del paso 5 (recepcion por caja, incidencias, destino)

**Files:**
- Modify: `UTransferenciasDatos.pas` (declaraciones ~linea 150-170 e implementacion ~linea 990-1030), `UTransferenciasForm.pas` (llamada de `btnRegistrarRecepcionClick`, ~linea 1327; solo la firma, la pantalla completa va en la tarea 6)
- Test: `Pruebas/UPruebasTransferenciasDatos.pas` (se omiten sin BD; correrlas con `ARCHIGENIO_TEST_DB`)

**Interfaces:** Consumes: `TEstadoCaja`, `ValidarEntradaCentral`, `CajasDecididas`, `HayCajaRecibida`, `FechaLimiteReclamacion` (tarea 2). Produces:
```
type
  TArchivoCentral = record Cod: Integer; Nombre: string; end;
  TCajaFila = record
    Caja: Integer; Tipo, Descripcion: string; FDesde, FHasta: TDateTime;
    Unidades: Integer; Estado: TEstadoCaja; Conservacion: string;
    Deposito, Gaveta, Posicion: string;
  end;
function ListarArchivosCentrales(Conn: TFDConnection): TArray<TArchivoCentral>;  // cl_ArchivosGestion con tipo Central
function CajasDeTransferencia(Conn: TFDConnection; IdProceso: Integer): TArray<TCajaFila>;
procedure MarcarCajaRecibida(Conn: TFDConnection; IdProceso, Caja: Integer; const Conservacion: string);
procedure MarcarCajaCuarentena(Conn: TFDConnection; IdProceso, Caja: Integer; const Conservacion: string);
procedure ResolverCuarentena(Conn: TFDConnection; IdProceso, Caja: Integer);    // Q -> R
procedure MarcarCajaFaltante(Conn: TFDConnection; IdProceso, Caja: Integer; const Usuario, Descripcion: string; Hoy: TDateTime);
function RegistrarRecepcionTransferencia(Conn: TFDConnection; IdProceso: Integer;
  const Usuario, RecibidoPor, NumRegistro: string; Fecha: TDateTime;
  IdArchivoDestino: Integer): Boolean;   // reemplaza a la version de 5 parametros
```
`MarcarCajaFaltante` pone `Estado='F'`, crea la incidencia (`Tipo='FALTA'`, `Estado='A'`, `FechaLimite = FechaLimiteReclamacion(Hoy)`), pone `prc_unidad.Activa = 0` para la caja y borra de `prc_bloqueo` esos documentos (clave `IdEstructura, id, codsubs, Codigodoc, fecha, version`, via `EXISTS` sobre `prc_unidad`). `RegistrarRecepcionTransferencia` lanza `EArgumentException` si `ValidarRecepcion`/`ValidarEntradaCentral` fallan, si `IdArchivoDestino` no esta en `ListarArchivosCentrales`, si no `CajasDecididas`, si hay cajas en cuarentena o si no `HayCajaRecibida`; guarda `FRecepcion`, `RecibidoPor`, `NumRegistroEntrada`, `IdArchivoDestino` y avanza 5 -> 6 con `AvanzarPaso`. Devuelve `False` si ya no esta en el paso 5.

- [ ] **Step 1: Tests de base** (una transferencia creada con el escenario de `UPruebasTransferenciasDatos`, dentro de una transaccion revertida): `ListarArchivosCentrales` solo devuelve archivos con tipo Central (insertar uno de prueba en la transaccion); `MarcarCajaFaltante` deja `Estado='F'`, una incidencia abierta con `FechaLimite` = hoy + 30, `Activa=0` y sin `prc_bloqueo` para esas unidades; `RegistrarRecepcionTransferencia` lanza con destino inexistente, con una caja `P`, con una caja `Q`; con todas `R` avanza al paso 6 y guarda destino y registro; la segunda llamada devuelve `False`.
- [ ] **Step 2:** Run la suite con `ARCHIGENIO_TEST_DB`. Expected: FAIL.
- [ ] **Step 3:** Implementar. `ListarArchivosCentrales` reutiliza el cruce de `CodigosArchivoGestion` (~linea 323) pero para `taCentral`. Estados leidos y escritos con `CodigoDeEstadoCaja`/`EstadoCajaDesdeCodigo`. Todo lo que escribe va en transaccion propia (`IniciarTx`/`ConfirmarTx`/`DeshacerTx`, como `RegistrarRecepcionTransferencia` actual).
- [ ] **Step 4:** Ajustar `btnRegistrarRecepcionClick` a la firma nueva con valores provisionales (destino = primer archivo central, registro = texto del `TEdit` existente de quien recibe) solo para que compile; la pantalla real es la tarea 6.
- [ ] **Step 5:** Run la suite. Expected: PASS.
- [ ] **Step 6: Commit** `feat(transferencias): recepcion por caja con destino, cuarentena, faltantes e incidencias`.

### Task 4: Datos del paso 6 (ubicacion por caja y cierre con traspaso)

**Files:**
- Modify: `UTransferenciasDatos.pas`, `UTransferenciasReglas.pas` (retirar `ValidarUbicacion` y sus pruebas), `UTransferenciasForm.pas` (llamada ~linea 1353, solo firma)
- Test: `Pruebas/UPruebasTransferenciasDatos.pas`, `Pruebas/UPruebasTransferenciasReglas.pas`

**Interfaces:** Consumes: `ValidarUbicacionCaja`, `CajasDeTransferencia`. Produces:
```
procedure RegistrarUbicacionCaja(Conn: TFDConnection; IdProceso, Caja: Integer;
  const Deposito, Gaveta, Posicion: string);       // valida con ValidarUbicacionCaja; EArgumentException si falla; solo cajas R y solo en paso 6
function CerrarTransferencia(Conn: TFDConnection; IdProceso: Integer; const Usuario: string): Boolean;
```
`CerrarTransferencia`: `False` si ya no esta en el paso 6; lanza `EArgumentException` si alguna caja `R` no tiene ubicacion; en UNA transaccion hace, por cada caja `R`: `UPDATE tb_SeriesDatos SET Archivo = :destino, deposito = :d, gaveta = :g, posicion = :p WHERE EXISTS (SELECT 1 FROM prc_unidad U WHERE U.IdProceso = :proc AND U.Caja = :caja AND U.Activa = 1 AND U.IdEstructura = tb_SeriesDatos.IdEstructura AND U.id = tb_SeriesDatos.id AND U.codsubs = tb_SeriesDatos.codsubs AND U.Codigodoc = tb_SeriesDatos.Codigodoc AND U.fecha = tb_SeriesDatos.fecha AND U.version = tb_SeriesDatos.version)`; luego `AvanzarPaso(... 6, [cdUbicacionCompleta] ...)` (finaliza y libera bloqueos). Cualquier fallo deshace todo. Se conserva `prc_transferencia.Ubicacion` como resumen de texto (p. ej. `Deposito x, gaveta y: cajas 1-6`), armado al cerrar.

- [ ] **Step 1: Tests de base:** (a) `RegistrarUbicacionCaja` con `Gaveta` de 21 caracteres lanza y no cambia la caja; (b) `CerrarTransferencia` sin ubicar una caja lanza; (c) con todo ubicado: los documentos de cada caja tienen `Archivo`, `deposito`, `gaveta`, `posicion` de su caja, los de una caja `F` (Activa=0) siguen intactos, `prc_bloqueo` queda vacio para el proceso y el proceso esta en `Estado='F'`; (d) segunda llamada devuelve `False` y no cambia nada; (e) atomicidad: con dos cajas `R` y la segunda con `prc_transferencia.IdArchivoDestino = NULL` en el momento del cierre se lanza `EArgumentException` antes de escribir; ademas, con el proceso a cuyo paso se le cambia `Paso` a otro valor entre medias (simula a otro usuario), `CerrarTransferencia` devuelve `False` y ningun documento cambia.
- [ ] **Step 2:** Run la suite con `ARCHIGENIO_TEST_DB`. Expected: FAIL.
- [ ] **Step 3:** Implementar; reemplazar `RegistrarUbicacionTransferencia` por `CerrarTransferencia` (retirar la anterior y `ValidarUbicacion` con sus tests) y ajustar la llamada en `btnRegistrarUbicacionClick` solo para compilar.
- [ ] **Step 4:** Run la suite. Expected: PASS.
- [ ] **Step 5: Commit** `feat(transferencias): ubicacion por caja y cierre que traspasa los documentos al archivo central`.

### Task 5: Documento transferido (consulta compartida y bloqueos de origen)

**Files:**
- Create: `UTransferidosSql.pas` (sin VCL ni FireDAC, como `UPrestadosSql`); anadir a `ArchiGenioPro.dpr` y a `Pruebas/PruebasArchiGenio.dpr`
- Modify: `UPrestamosDatos.pas` (agregar documentos a un prestamo), `UTransferenciasDatos.pas` (`ProponerTransferencia`/`AgregarGrupo` ya usan `SqlNoTransferido`: comprobar que lo usan), `UDocumentoVistaDatos.pas` (exponer la marca), y el punto de edicion de documentos que localice `Grep` de `UEdicionDocumento` (pantalla de ficha)
- Test: `Pruebas/UPruebasTransferidosSql.pas` (nuevo, agregar al `.dpr`), `Pruebas/UPruebasPrestamosDatos.pas`

**Interfaces:** Produces:
```
function SqlTransferidos: string;   // SELECT H.IdEstructura, H.id, H.codsubs, H.Codigodoc, H.fecha, H.version, P.IdProceso, T.IdArchivoDestino FROM prc_unidad U INNER JOIN prc_proceso P ON P.IdProceso = U.IdProceso INNER JOIN prc_transferencia T ON T.IdProceso = P.IdProceso INNER JOIN tb_SeriesDatos H ON <clave> WHERE P.Tipo = 'T' AND P.Estado = 'F' AND U.Activa = 1
function EstaTransferido(Conn: TFDConnection; const IdEstructura: string; Id: Integer;
  const CodSubs, CodigoDoc: string; Fecha: TDateTime; const Version: string): Boolean;
```
(`EstaTransferido` va en `UTransferenciasDatos`, que ya usa FireDAC, para mantener `UTransferidosSql` sin FireDAC.)

- [ ] **Step 1: Tests:** `SqlTransferidos` contiene `P.Tipo = 'T'`, `P.Estado = 'F'` y la clave completa (con `codsubs`); de base: tras `CerrarTransferencia`, `EstaTransferido` es True para un documento de la caja y False para uno de otra transferencia; intentar agregar un documento transferido a un prestamo lanza `EArgumentException` con texto que diga a donde fue.
- [ ] **Step 2:** Run la suite. Expected: FAIL.
- [ ] **Step 3:** Implementar. En `UPrestamosDatos` rechazar documentos transferidos (mismo punto donde hoy se rechaza el ya prestado). En la ficha/edicion y en el listado de documentos: ubicar con `Grep` donde se decide si un documento es editable (`UEdicionDocumento`, `UDocumentoVistaDatos`) y desactivar editar/prestar/transferir/eliminar si `EstaTransferido`, mostrando el texto `Transferido al archivo <nombre>`; la pantalla de la ficha se prueba a mano (lista de verificacion de la tarea 8).
- [ ] **Step 4:** Run la suite. Expected: PASS.
- [ ] **Step 5: Commit** `feat(transferencias): los documentos transferidos quedan en solo lectura en el origen`.

### Task 6: Pantalla de los pasos 5 y 6

**Files:**
- Modify: `UTransferenciasForm.pas`, `UTransferenciasForm.dfm` (panel `pnlPaso5`, ~linea 177, y sus botones `btnRegistrarRecepcion`/`btnRegistrarUbicacion`)
- Test: arnes temporal fuera del repo (ver `feedback_trabajo_procesos`): crea el formulario desde su `.dfm`, le pasa datos de ejemplo por metodos `Mostrar*` y guarda capturas (100 % y 125 %)

**Interfaces:** Consumes: `TCajaFila`, `TArchivoCentral`, las funciones de las tareas 3 y 4. Produces en `TfrmTransferenciasNuevo`: `procedure MostrarArchivosCentrales(const Lista: TArray<TArchivoCentral>)`, `procedure MostrarCajasRecepcion(const Cajas: TArray<TCajaFila>)`; eventos `AlCambiarEstadoCaja(Caja: Integer; Estado: TEstadoCaja; const Texto: string)` y `AlUbicarCaja(Caja: Integer; const Deposito, Gaveta, Posicion: string)`.

- [ ] **Step 1:** En el `.dfm` (editar a mano manteniendo `object`/`end` y los campos publicados del `.pas` sincronizados): en el paso 5, combo de archivo destino, caja de texto del n.o de registro (Anexo 17), fecha, quien recibe y una cuadricula de cajas con columnas Caja, Descripcion, Unidades, Estado y Conservacion, con botones Recibida / Cuarentena / Faltante / Resolver cuarentena; en el paso 6, la misma cuadricula con Deposito, Gaveta, Posicion editables por caja y el boton Cerrar transferencia. Colores de la paleta clara; `AplicarTema` los adapta.
- [ ] **Step 2:** Cableado en el `.pas`: los botones llaman a `MarcarCajaRecibida/Cuarentena/Faltante/ResolverCuarentena`, `RegistrarRecepcionTransferencia`, `RegistrarUbicacionCaja` y `CerrarTransferencia`; solo con `PuedeActuar`; errores de `EArgumentException` por `TMensajes.Advertencia`; confirmar con `TMensajes.Confirmar` antes de `CerrarTransferencia` (irreversible) y de marcar una caja faltante.
- [ ] **Step 3:** Con el arnes, capturas de: paso 5 con cajas en los cuatro estados, paso 6 con una caja sin ubicar, y a 125 % de escala. Revisar a ojo que nada se corte ni se solape.
- [ ] **Step 4:** Compilar `ArchiGenioPro.dproj` (`scripts/compilar.ps1 ArchiGenioPro.dproj`). Expected: sin errores.
- [ ] **Step 5: Commit** `feat(transferencias): pantalla de recepcion y ubicacion por caja`.

### Task 7: Impreso Registro topografico (Anexo 18)

**Files:**
- Create: `MAISEL REPORT/Report/rRegistroTopografico.fr3`
- Modify: `UTransferenciasImpresos.pas`, `UTransferenciasForm.pas` (boton en el paso 6), y copiar el `.fr3` a `Win32\Debug\Report`
- Test: `Pruebas/` (solo si el armado de lineas es una funcion pura; el impreso se revisa a mano)

**Interfaces:** Consumes: `CajasDeTransferencia`. Produces: `procedure ImprimirRegistroTopografico(Conn: TFDConnection; IdProceso: Integer; const RutaInformes: string)` en `UTransferenciasImpresos` (mismo patron que la relacion de entrega: variables + dataset en memoria asignado a `MasterData1`, rutinas de `UImpresosComun`; la ruta de informes lleva la barra final).

- [ ] **Step 1:** Anadir una funcion pura en `UTransferenciasReglas` `LineasRegistroTopografico(const Cajas: TArray<TCajaFila>): TArray<TLineaTopografia>` (solo cajas `R`, ordenadas por numero) con su prueba (`UPruebasTransferenciasReglas`): cajas `Q`/`F`/`P` no aparecen; orden ascendente.
- [ ] **Step 2:** Run la suite. Expected: FAIL, luego implementar y PASS.
- [ ] **Step 3:** Disenar `rRegistroTopografico.fr3` (columnas: Caja, Descripcion, Deposito, Gaveta, Posicion, fechas extremas; cabecera con numero de transferencia, archivo destino, n.o de registro de entrada y fecha) y el boton en el paso 6. Probar imprimiendo T-2026-02.
- [ ] **Step 4: Commit** `feat(transferencias): impreso Registro topografico (Anexo 18)`.

### Task 8: Verificacion de punta a punta, documentacion y cierre

**Files:**
- Create: `docs/superpowers/plans/2026-11-15-verificacion-transferencias-f3.md` (lista manual como `...-verificacion-transferencias-f2.md`)
- Modify: `CLAUDE.md` (parrafo de Transferencias: reemplazar "Version minima de recepcion y ubicacion" por el resumen de F3), spec (actualizar la seccion de cuarentena con la decision 1 del plan), memoria `project_procesos_archivisticos` y `project_transferencias_f3_decisiones`

- [ ] **Step 1:** Suite completa con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`. Expected: todo pasa, 0 errores; confirmar con `sqlcmd` que `tb_nodo_egd` y `prc_proceso` (T-2026-01/02) siguen como antes.
- [ ] **Step 2:** Lista manual para el usuario con `egd`/`admin`: cerrar T-2026-02 (hoy en paso 5): elegir destino (crear antes un archivo Central en el clasificador Archivos), recibir cajas, probar cuarentena y faltante, ubicar, cerrar, comprobar en la ficha de un documento que sale como Transferido y que ya no se puede prestar.
- [ ] **Step 3:** Actualizar CLAUDE.md, spec y memoria.
- [ ] **Step 4: Commit** `docs: F3 de transferencias (verificacion, CLAUDE.md y spec al dia)`.

---

## Self-review

- **Cobertura del spec:** destino por quien recibe (T3/T6), solo lectura en origen (T5), ubicacion por caja (T2/T4/T6), cuarentena e incidencias (T1/T3), Anexo 17 (`NumRegistroEntrada`, T1/T3), Anexo 18 (T7), cierre atomico (T4). No cubierto a proposito: migrar `tb_transferencia`, retirar pantallas viejas, central->historico (F3b/F4, fuera de F3 segun el spec). La cuarentena que no impide cerrar se cambio (decision 1).
- **Consistencia de tipos:** `TEstadoCaja`, `TCajaFila`, `TArchivoCentral`, `RegistrarRecepcionTransferencia` (6 parametros + destino), `CerrarTransferencia` y `EstaTransferido` se definen una vez y se usan con el mismo nombre en las tareas siguientes.
- **Proporcion:** el plan indica firmas, reglas y pruebas; los cuerpos los escribe quien implementa.
