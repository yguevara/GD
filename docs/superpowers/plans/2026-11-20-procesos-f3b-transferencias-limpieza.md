# Transferencias F3b (migracion de tb_transferencia y retiro de UTransferencias) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dejar solo la pantalla nueva de Transferencias: informar de lo que hay en la tabla vieja `tb_transferencia` y retirar la pantalla vieja `UTransferencias` y su respaldo.

**Architecture:** `tb_transferencia` solo guarda lineas por serie (sin nodo ni documentos): no se puede convertir en `prc_transferencia`. La "migracion" es un informe al arrancar (conteo y avisos en `procesos_error.log`) que no toca la tabla. Se retira `UTransferencias` (pantalla, `.dfm`, entrada en el `.dpr`), sus dos puntos de entrada de `TMAIN` (`btnTransferClick`, `I4Click`) pasan a `AbrirTransferencias`, y el dataset `tb_transferencia` de `UDM` se quita (ya no se lee en el arranque). **`UProgresoTransferencia` NO se retira:** es el dialogo de progreso de subir/descargar/exportar ficheros que usan `UCapaDatos` y `UMAINFORM`.

**Tech Stack:** Delphi 10.3, FireDAC, DUnitX.

**Spec:** `docs/superpowers/specs/2026-11-12-prestamos-transferencias-depuracion-design.md` y decision del usuario (2026-11-20): informe + retirar pantallas, sin respaldo.

## Global Constraints

- Codigo nuevo ASCII (acentos `#NNN`), fuentes ANSI/CRLF, mensajes por `TMensajes`. No se borra ni modifica `tb_transferencia`. `USeriesDatos.TABLAS_USO` conserva `tb_transferencia` (comprobacion de uso al borrar series).
- Sin la ventana principal nueva (o con `procesos_clasico.flag`), Transferencias se abre igual pero como ventana modal de la pantalla nueva; si falla, se muestra el error (no hay pantalla vieja).

## Review Focus

- Arrancar con `tb_transferencia` vacia, con filas y sin la tabla (Access/SQL Server) no rompe el arranque.
- Ningun otro formulario usaba `UDM.tb_transferencia`/`dstb_transferencia`.
- Los dos menus (`btnTransfer`, `I4`) y la seccion del shell abren la pantalla nueva; ninguno entra en bucle.

---

### Task 1: Informe de `tb_transferencia`

**Files:**
- Create: `UTransferenciasMigracion.pas`, `Pruebas/UPruebasTransferenciasMigracion.pas`
- Modify: `UCapaDatos.pas` (llamada tras las demas migraciones), `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:** Produces: `function InformarTransferenciasViejas(Conn: TFDConnection): TInformeMigracion` (de `UPrestamosMigracion`): `Leidos` = filas, `Avisos` = una linea resumen (cuantas ejecutadas y cuantas sin ejecutar) mas una por cada fila sin ejecutar que tenga fecha y serie; sin la tabla devuelve todo en cero. Nunca escribe.

- [ ] **Step 1: Pruebas en rojo**: sin filas -> `Leidos = 0` y sin avisos; con 3 filas sembradas (2 ejecutadas, 1 no) -> `Leidos = 3` y el resumen dice 2 y 1; la tabla queda con 3 filas; sin la tabla (consulta a una tabla inexistente simulada con un nombre invalido no aplica: se prueba que un error de consulta devuelve cero sin lanzar, usando una conexion sin esa tabla en la prueba de SQL puro si no es posible).
- [ ] **Step 2: Implementar** `InformarTransferenciasViejas` (un `SELECT COUNT/SUM` y, solo si hay sin ejecutar, una consulta limitada a 50 filas) y llamarla en `UpDateDB` junto a las otras migraciones (resumen a `procesos_error.log` solo si `Leidos > 0`).
- [ ] **Step 3: Suite** en verde. Commit `feat(transferencias): informe de tb_transferencia al arrancar`.

### Task 2: Retirar `UTransferencias`

**Files:**
- Delete: `UTransferencias.pas`, `UTransferencias.dfm`
- Modify: `ArchiGenioPro.dpr`, `UMAINFORM.pas` (`btnTransferClick`, `I4Click`, `AbrirTransferencias`, `uses`), `UCapaDatos.pas` y `UCapaDatos.dfm` (dataset `tb_transferencia`, `dstb_transferencia`, `FetchAll`, `Active`)

**Interfaces:** Consumes: `TfrmTransferenciasNuevo`/`CrearPantallaTransferencias` (ya existen). Produces: `TMAIN.AbrirTransferencias` sin respaldo viejo.

- [ ] **Step 1:** `btnTransferClick` y `I4Click` llaman a `AbrirTransferencias`. En `AbrirTransferencias`: sin shell o con `procesos_clasico.flag`, la pantalla nueva se muestra modal (`ShowModal`, `Free`); con shell, como hoy. Un fallo se registra (`RegistrarErrorProceso`) y se muestra con `TMensajes.Error`; se quita todo `btnTransfer.Click` de ahi.
- [ ] **Step 2:** Quitar `UTransferencias` de `uses` y del `.dpr`; borrar los dos archivos; quitar de `UCapaDatos` el dataset, su `TDataSource`, el `FetchAll` y el `Active` (`.pas` y `.dfm` a la vez). `grep -rn "tb_transferencia\|dstb_transferencia\|UTransferencias\b\|TfrmTransferencias\b"` solo debe encontrar `USeriesDatos` y la migracion.
- [ ] **Step 3:** Compilar `ArchiGenioPro.dproj`, suite completa; comprobar con un arnes o a mano que `AbrirTransferencias` sin shell no recursa. Commit `refactor(transferencias): retirar la pantalla vieja y su dataset`.

### Task 3: Cierre

**Files:** `CLAUDE.md`, memoria `project_procesos_archivisticos`, `docs/superpowers/plans/2026-11-20-verificacion-transferencias-f3b.md`.

- [ ] **Step 1:** Documentar (informe, pantalla vieja retirada, `UProgresoTransferencia` se queda y por que, el flag `procesos_clasico.flag` ya no afecta a Transferencias) y lista de verificacion manual (abrir Transferencias por el menu, por `I4` y por el shell; arranque con filas en la tabla vieja y ver `procesos_error.log`).
- [ ] **Step 2:** Compilar, suite, comprobar la base de pruebas. Commit `docs: cierre de F3b`.

---

## Self-review

- **Cobertura:** informe (T1), pantalla vieja y respaldo retirados (T2), nota sobre `UProgresoTransferencia` (arquitectura y T3).
- **Proporcion:** tres tareas pequenas; lo visual no cambia.
