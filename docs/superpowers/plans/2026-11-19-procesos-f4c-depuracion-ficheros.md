# Depuracion F4c (retiro de ficheros, migracion y retiro de UDepuracion) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que el cierre de una depuracion exija resolver los ficheros digitales de los documentos eliminados (retiro por fichero con reintento), migrar lo ya depurado de `tb_depuracion` y quitar la contrasena embebida de la pantalla vieja.

**Architecture:** La ejecucion (paso 4->5) sigue solo marcando; en la misma transaccion copia a `prc_fichero_retiro` los ficheros de `tb_ssArchdigital` de las unidades activas. En el paso 5 una seccion nueva retira cada fichero con `IAlmacenFicheros` (`Existe`/`Borrar`) y guarda el resultado; el cierre exige `cdFicherosResueltos`. Reglas y datos sin VCL con pruebas contra SQL Server y un almacen simulado; la pantalla lleva su `.dfm`.

**Tech Stack:** Delphi 10.3, FireDAC (SQL Server y Access), DUnitX, `UAlmacenFicheros`/`UAlmacenServidor` existentes.

**Spec:** `docs/superpowers/specs/2026-11-18-depuracion-f4-design.md` (seccion c y datos nuevos). Entregas a y b hechas (main en `47dd820`).

## Global Constraints

- Codigo nuevo ASCII (acentos por `#NNN`), fuentes ANSI/CRLF, mensajes por `TMensajes`, toda UI nueva con `.dfm`, SQL valido en SQL Server y Access, solo el EGD del nodo actua (`PuedeActuarAqui`).
- Estados de fichero: `P` pendiente, `R` retirado, `N` ya no existia, `L` solo lectura (FTP), `M` retirado a mano, `E` error. Un `L` solo cuenta como resuelto al confirmarse `M`.
- Los documentos NO se borran de `tb_SeriesDatos` ni sus filas de `tb_ssArchdigital`: solo se retira el objeto del almacen.
- Las tablas viejas (`tb_depuracion`) no se modifican ni se borran.

## Review Focus

- Un fallo de red/almacen en un fichero no frena los demas ni deja la fila en `P` sin mensaje (queda `E` con el texto).
- Reintentar no vuelve a tocar los ya `R`/`N`/`M`; ejecutar el retiro dos veces seguidas es inocuo.
- Cerrar con un `P`, `E` o `L` pendiente se rechaza aunque la pantalla este desactualizada (la regla vive en datos, no solo en el boton).
- Una depuracion sin ficheros digitales cierra como antes.
- La migracion repetida no duplica procesos.

---

### Task 1: Esquema y condicion de cierre

**Files:**
- Modify: `UEsquemaProcesos.pas`, `SCRIPTS/procesos_tablas.sql`, `UProceso.pas`, `UDepuracionReglas.pas` (texto de lo que falta), `Pruebas/UPruebasProceso.pas`, `Pruebas/UPruebasEsquemaProcesos.pas` (o la unidad de pruebas de esquema existente)

**Interfaces:** Produces: tabla `prc_fichero_retiro` (`IdProceso`, `IdEstructura`, `id`, `codsubs`, `fecha`, `Version`, `Codigodoc`, `idhijo`, `UrlRaiz`, `Path`, `Nombre`, `Estado` char(1), `Mensaje`, `Fecha` datetime; PK = proceso + clave del documento + `idhijo`); `TCondicion.cdFicherosResueltos`; `CondicionesParaAvanzar(tpDepuracion, 5) = [cdFicherosResueltos]`.

- [ ] **Step 1: Pruebas en rojo**: `CondicionesParaAvanzar(tpDepuracion, 5)` es `[cdFicherosResueltos]`; el esquema crea `prc_fichero_retiro` (idempotente, ambos motores); `TextosQueFaltanDepuracion([cdFicherosResueltos])` dice que quedan ficheros por retirar.
- [ ] **Step 2: Implementar** `cdFicherosResueltos`, la sentencia de la tabla en `SentenciasEsquemaProcesos` y su copia en el script; ajustar las pruebas viejas que esperaban paso 5 sin condiciones.
- [ ] **Step 3: Suite** completa en verde. Commit `feat(depuracion): tabla de retiro de ficheros y condicion de cierre`.

### Task 2: Datos del retiro (`UDepuracionFicheros`)

**Files:**
- Create: `UDepuracionFicheros.pas`, `Pruebas/UPruebasDepuracionFicheros.pas`
- Modify: `UDepuracionDatos.pas` (ejecutar copia los ficheros; condicion; cierre), `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Produces: `TFicheroRetiro` (`Clave: string`, `IdHijo: Integer`, `Nombre, Path, UrlRaiz, Estado, Mensaje: string`), `TFabricaAlmacenRetiro = reference to function(const UrlRaiz, Path, Nombre: string; out Clave: string): IAlmacenFicheros` (igual a `TFabricaAlmacen` de `UAgregarFicheros`), `function FicherosDelRetiro(Conn; IdProceso): TArray<TFicheroRetiro>`, `function RetirarFicheros(Conn; IdProceso: Integer; Fabrica: TFabricaAlmacenRetiro; Usuario: string): TResumenRetiro` (cuenta por estado; procesa solo `P` y `E`; `EAlmacenSoloLectura` -> `L`; `Existe` falso -> `N`; `Borrar` ok -> `R`; otra excepcion -> `E` con el mensaje; nunca lanza por un fichero), `function ConfirmarRetiroManual(Conn; IdProceso: Integer; const Clave: string; IdHijo: Integer; Usuario: string): Boolean` (solo `L` -> `M`), `function FicherosSinResolver(Conn; IdProceso): Integer`.
- Consumes: `IAlmacenFicheros`, `EAlmacenSoloLectura` (`UAlmacenFicheros`), `AlmacenParaFichero` (`UAlmacenServidor`) para la fabrica real, `TablasDeProcesosExisten`.

- [ ] **Step 1: Pruebas en rojo** (almacen simulado en memoria con modos: ok, no existe, solo lectura, lanza error): ejecutar la depuracion copia a `prc_fichero_retiro` solo los ficheros de las unidades activas (en `P`); `RetirarFicheros` deja `R`/`N`/`L`/`E` segun el caso y los demas siguen aunque uno falle; segunda llamada no toca `R`/`N`/`L`/`M` pero reintenta `E`; `ConfirmarRetiroManual` solo pasa `L` a `M`; `CondicionesCumplidasDepuracion` en paso 5 incluye `cdFicherosResueltos` solo sin `P`/`E`/`L`; `CerrarDepuracion` devuelve `False` con pendientes y `True` sin ellos; depuracion sin ficheros cierra.
- [ ] **Step 2: Implementar** `UDepuracionFicheros`; en `EjecutarDepuracion` (misma transaccion) un `INSERT ... SELECT` desde `tb_ssArchdigital` por la clave del documento (incluye `codsubs`) para las unidades activas; `CondicionesCumplidasDepuracion` en paso 5 evalua `FicherosSinResolver = 0`; `CerrarDepuracion` pasa las condiciones a `AvanzarPaso`.
- [ ] **Step 3: Suite** en verde y registro en ambos `.dpr`. Commit `feat(depuracion): retiro de ficheros digitales con reintento`.

### Task 3: Seccion de ficheros en el paso 5

**Files:**
- Modify: `UDepuracionForm.pas`, `UDepuracionForm.dfm` (`pnlPaso5`), `UMAINFORM.pas` (fabrica real de almacenes)

**Interfaces:** Consumes: Task 2. Produces: `MostrarFicheros(const F: TArray<TFicheroRetiro>)` publico; evento `AlRetirarFicheros: TRetirarFicherosDepuracion = reference to procedure(IdProceso: Integer)`; en `TMAIN.AbrirDepuracion` se asigna con `AlmacenParaFichero(UDM.Conn, ..., servidor por defecto ...)`.

- [ ] **Step 1: `.dfm`**: bajo el texto del paso 5, cuadricula (Fichero, Estado en palabras, Mensaje), resumen («N retirados, N pendientes, N con error, N solo lectura») y botones `Retirar ficheros`, `Reintentar los que fallaron` (visible con `E`), `Confirmar retiro a mano` (sobre un `L` elegido); `Cerrar la depuracion` desactivado mientras `FicherosSinResolver > 0`.
- [ ] **Step 2: Codigo**: cargar en `CargarPaso` caso 5; los tres botones llaman a datos con `PuedeActuarAqui`; el resultado se explica por `lblAviso`; refresca la lista y el boton de cerrar.
- [ ] **Step 3: Arnes**: capturas (todo pendiente, mezcla con error y solo lectura, todo resuelto), 100 % y 125 %. Compilar. Commit `feat(depuracion): seccion de ficheros en el cierre`.

### Task 4: Migracion de `tb_depuracion`

**Files:**
- Create: `UDepuracionMigracion.pas`, `Pruebas/UPruebasDepuracionMigracion.pas`
- Modify: `UCapaDatos.pas` (llamarla tras la migracion de prestamos, en SQL Server, resumen a `procesos_error.log`), ambos `.dpr`

**Interfaces:** Produces: `function MigrarDepuracionesViejas(Conn: TFDConnection; EsSqlServer: Boolean): TInformeMigracion` (reusa el record de `UPrestamosMigracion`).

- [ ] **Step 1: Pruebas en rojo**: sin tabla vieja o sin filas `depurado` -> todo en cero; con filas depuradas (sembradas) crea UN proceso `D` finalizado (paso 5) por fecha de depuracion, sus unidades activas sin candado, `Lugar` con la marca `MIGRADA tb_depuracion <fecha>`; el documento aparece como eliminado (`UEliminados`); segunda ejecucion no duplica; una fila cuya subserie no existe se omite y se avisa; `tb_depuracion` queda intacta.
- [ ] **Step 2: Implementar** (cada fecha en su propia transaccion, patron de `UPrestamosMigracion`) y enganchar en `UpDateDB`.
- [ ] **Step 3: Suite** en verde. Commit `feat(depuracion): migracion de tb_depuracion como informe y procesos finalizados`.

### Task 5: Retirar la contrasena de `UDepuracion` y cerrar la entrega

**Files:**
- Modify: `UDepuracion.pas`, `CLAUDE.md`, memoria `project_procesos_archivisticos`
- Create: `docs/superpowers/plans/2026-11-19-verificacion-depuracion-f4c.md`

- [ ] **Step 1:** Quitar `Password=geoconn;User ID=geoconn` de `InsertConnection` (linea ~488): la cadena toma usuario y clave de `UDM.Conn.Params` o, si el metodo no se usa (la llamada esta comentada), se elimina el metodo y su declaracion. `grep -rn geoconn *.pas` no debe devolver nada.
- [ ] **Step 2:** Compilar `ArchiGenioPro.dproj` y la suite completa; comprobar la base de pruebas intacta (`sqlcmd`).
- [ ] **Step 3:** Lista de verificacion manual (ejecutar, retirar con S3, FTP -> `L` -> `M`, reintento tras apagar el servidor, cerrar), `CLAUDE.md` y memoria. Commit `feat(depuracion): cierre de la entrega c`.

---

## Self-review

- **Cobertura del spec (c):** retiro por fichero con reintento y FTP de solo lectura (T2, T3); condicion de cierre y nota de retiro pendiente (T1, T3); migracion de `tb_depuracion` (T4); contrasena embebida (T5). `UDepuracion` sigue como respaldo tras `procesos_clasico.flag` hasta F5.
- **Tipos:** `TFicheroRetiro`, `TFabricaAlmacenRetiro` y `cdFicherosResueltos` se definen una vez (T1, T2) y los usa T3.
- **Proporcion:** la pantalla se verifica con capturas; reglas y datos con pruebas, el almacen real solo contra servidor en la prueba manual.
