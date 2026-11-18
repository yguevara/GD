# Depuracion F4a (datos y reglas, sin pantalla) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que un proceso de depuracion (D-AAAA-NN) pueda proponerse, autorizarse, documentarse (acta, muestra, testigos), ejecutarse y cerrarse con datos y reglas probados, y que los documentos eliminados queden en solo lectura sin borrar ninguna fila.

**Architecture:** Reglas puras en `UDepuracionReglas` (con pruebas), datos FireDAC en `UDepuracionDatos` sobre la base comun de F0 (`UProcesosDatos`, `prc_*`), esquema nuevo (`prc_depuracion`, `prc_testigo`) y una consulta compartida `UEliminados` (como `UTransferidos`): un documento esta eliminado si es unidad activa de una depuracion ejecutada (`Tipo = 'D'`, `Estado <> 'X'`, `Paso >= 5`). La entrega b agrega las pantallas y la c el retiro de ficheros.

**Tech Stack:** Delphi 10.3, FireDAC, DUnitX (`Pruebas/`), SQL Server (Access sin base de prueba).

**Spec:** `docs/superpowers/specs/2026-11-18-depuracion-f4-design.md` (entrega a). Patron a imitar: `UTransferenciasDatos.pas` (`ProponerTransferencia`, `AgregarGrupo`, `QuitarGrupo`, `ListarTransferencias`) y `UTransferidos.pas`.

## Global Constraints

- SQL valido en SQL Server y Access: nada de `UPDATE ... FROM`; `EXISTS` correlacionado; `Activa <> 0` (no `= 1`: Access guarda Si como -1).
- Codigo nuevo en ASCII puro (acentos con `#NNN`); los archivos viejos son ANSI/CRLF: editar sin cambiar codificacion; `UTransferenciasImpresos.pas` y los `.pas` nuevos que cree la herramienta Write se convierten a CRLF antes de commit.
- Mensajes al usuario por `UMensajes` (en esta entrega no hay mensajes de pantalla; los errores de datos son `EArgumentException` con texto en espanol).
- No se borran filas de `tb_SeriesDatos` ni de sus tablas de metadatos; ninguna columna nueva en `tb_SeriesDatos`.
- Cada unidad nueva se agrega a `ArchiGenioPro.dpr` (`in 'UFoo.pas'`) y a `Pruebas/PruebasArchiGenio.dpr` (`in '..\UFoo.pas'`).
- Compilar: `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`; ejecutar: `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` + `Pruebas\Win32\Debug\PruebasArchiGenio.exe` (script de apoyo del plan anterior: `scratchpad/suite.sh`). Linea base: **871 pasan, 0 fallan** (la prueba visual `UPruebasPanelDocumentos.Propiedades_MensajeReemplazaTodo` falla a veces: repetir). Compilar tambien `ArchiGenioPro.dproj` al final de cada tarea que toque unidades de la aplicacion.
- Commits selectivos (nunca `Win32/Debug/*.dcu` ni `ArchiGenioPro.identcache`), terminados con `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
- Las pruebas de base siembran sus datos con codigos propios (`CreadoPor = '__prueba__'`, documentos `titulodoc = '__prueba__'`) y los limpian; la base de pruebas no tiene series con `tcentral` ni destino 3.

## Review Focus

- Subserie con `tcentral` en 0 o sin dato: nunca se propone (Task 4).
- Documento retenido por una transferencia abierta, por un prestamo nuevo o por un prestamo viejo abierto (`TB_Prestamos`): no se propone, y al ejecutar se revalida (Tasks 4 y 6).
- Ejecutar dos veces o dos usuarios a la vez: el segundo recibe `False` y nada cambia; un fallo a medias no deja documentos eliminados a medias (Task 6).
- Confirmacion `eliminar` en minusculas, vacia o con otra palabra: se rechaza (Tasks 2 y 6).
- Dos testigos del mismo origen (los dos de la Comision) no bastan (Tasks 2 y 5).
- Un documento eliminado que alguien intenta prestar, editar, transferir o volver a depurar (Tasks 3 y 7).
- Numeros en letras en los bordes: 0, 1, 21, 100, 101, 1 000, 21 000, 1 000 000 y negativos (Task 2).

---

### Task 1: Esquema (`prc_depuracion`, `prc_testigo`)

**Files:**
- Modify: `UEsquemaProcesos.pas` (junto a `prc_caja`/`prc_incidencia`), `SCRIPTS/procesos_tablas.sql`
- Test: `Pruebas/UPruebasEsquemaProcesos.pas`

**Interfaces:** Produces:
`prc_depuracion (IdProceso INT PK con FK a prc_proceso ON DELETE CASCADE, Lugar VARCHAR(255) NULL, Via VARCHAR(1) NULL, FPrevista DATETIME NULL, FEjecucion DATETIME NULL, MuestraDesc VARCHAR(255) NULL, MuestraDonde VARCHAR(255) NULL)`;
`prc_testigo (IdTestigo autonumerico, IdProceso INT NOT NULL, Nombre VARCHAR(100) NOT NULL, Cargo VARCHAR(100) NULL, Origen VARCHAR(1) NOT NULL, Firmo BIT/Si-No NOT NULL por defecto falso)` con FK cascada a `prc_proceso` e indice `IX_prc_testigo_proceso (IdProceso)`.

- [ ] **Step 1: Test** en `TPruebasEsquemaProcesosSql`: `SentenciasEsquemaProcesos(True)` y `(False)` contienen `CREATE TABLE prc_depuracion (` y `CREATE TABLE prc_testigo (`, `CONSTRAINT PK_prc_depuracion PRIMARY KEY (IdProceso)`, `CONSTRAINT PK_prc_testigo PRIMARY KEY (IdTestigo)`, y `CREATE INDEX IX_prc_testigo_proceso ON prc_testigo (IdProceso)`. En `TPruebasEsquemaProcesosBD`: agregar `'prc_depuracion'` y `'prc_testigo'` al arreglo `TABLAS` (pasa de 11 a 13 elementos) para que `TablasExisten` y `EsIdempotente` las cubran. Actualizar los conteos de las pruebas viejas: autonumericos 4 -> 5 (`COUNTER` en Access, `IDENTITY(1,1)` en SQL Server) e indices 6 -> 7 (`CREATE INDEX` y `IF NOT EXISTS (SELECT 1 FROM sys.indexes`).
- [ ] **Step 2:** Compilar y ejecutar la suite. Expected: FAIL (tablas no definidas).
- [ ] **Step 3:** Agregar con `Tabla(...)`/`Indice(...)` (mismo patron que `prc_incidencia`) y reflejar lo mismo en `SCRIPTS/procesos_tablas.sql`.
- [ ] **Step 4:** Suite. Expected: PASS, 0 errores (incluye la creacion real en SQL Server, idempotente).
- [ ] **Step 5: Commit** `feat(procesos): esquema de F4 (acta de depuracion y testigos)`.

### Task 2: Reglas puras (`UDepuracionReglas`)

**Files:**
- Create: `UDepuracionReglas.pas`, `Pruebas/UPruebasDepuracionReglas.pas`; agregar ambos a los dos `.dpr`.

**Interfaces:** Consumes: `UProceso` (`TEstadoProceso`, `TCondiciones`, `TCondicion`), `UTransferenciasReglas.FechaCorte(Hoy: TDateTime; AniosGestion: Integer): TDateTime`. Produces (todo sin VCL ni FireDAC):
```
type
  TViaEliminacion = (veIncineracion, veTrituracion);          // codigos 'I', 'T'
  TOrigenTestigo = (otComision, otArchivoGestion, otOtro);    // codigos 'C', 'G', 'O'
  TTestigoDatos = record Nombre, Cargo: string; Origen: TOrigenTestigo; end;
const MINIMO_TESTIGOS = 2; PALABRA_CONFIRMACION = 'ELIMINAR';
function CodigoVia(V: TViaEliminacion): string;
function ViaDesdeCodigo(const Codigo: string): TViaEliminacion;           // EArgumentException si es desconocido
function TextoVia(V: TViaEliminacion): string;                            // 'Incineracion' / 'Trituracion'
function CodigoOrigenTestigo(O: TOrigenTestigo): string;
function OrigenTestigoDesdeCodigo(const Codigo: string): TOrigenTestigo;  // EArgumentException si es desconocido
function PlazoCentralVencido(Hoy: TDateTime; HayCierre: Boolean; Cierre, Fecha, FechaFin: TDateTime;
  HayFechaFin: Boolean; AniosGestion, AniosCentral: Integer): Boolean;
function UnidadesEnLetras(N: Int64): string;                              // femenino; 0..999 999 999, EArgumentException fuera de rango
function TestigosSuficientes(const T: array of TTestigoDatos): Boolean;
function ValidarTestigo(const T: TTestigoDatos): TArray<string>;
function ValidarActaDepuracion(const Lugar: string; FPrevista: TDateTime): TArray<string>;
function ValidarMuestra(const Descripcion, Donde: string): TArray<string>;
function ConfirmacionEscritaValida(const Texto: string): Boolean;
function TextoEstadoDepuracion(Paso: Integer; Estado: TEstadoProceso): string;
function TextosQueFaltanDepuracion(Faltan: TCondiciones): TArray<string>;
```

- [ ] **Step 1: Tests** (nombre y aserciones, con los valores del spec):
  - `PlazoCentralVencido`: con cierre de transferencia (`HayCierre`) cuenta `Cierre + AniosCentral`: cierre 01/02/2020, `AniosCentral = 5`, hoy 01/02/2025 => True; hoy 31/01/2025 => False; `AniosCentral = 0` => False siempre. Sin cierre usa `FechaBase + AniosGestion + AniosCentral` con `FechaBase = FechaFin` si `HayFechaFin` y `FechaFin >= Fecha`, si no `Fecha` (fecha 10/05/2000, gestion 3, central 5, hoy 10/05/2008 => True, 09/05/2008 => False; `FechaFin` anterior a `Fecha` se ignora; `AniosCentral = 0` => False).
  - `UnidadesEnLetras`: `0` 'cero'; `1` 'una'; `21` 'veintiuna'; `31` 'treinta y una'; `100` 'cien'; `101` 'ciento una'; `240` 'doscientas cuarenta'; `1000` 'mil'; `1001` 'mil una'; `1240` 'mil doscientas cuarenta'; `21000` 'veintiun mil'; `1000000` 'un millon'; `2000000` 'dos millones'; `-1` y `1000000000` lanzan `EArgumentException`.
  - `TestigosSuficientes`: `[]` False; dos de la Comision False; uno de la Comision + uno de archivo de gestion True; uno Comision + uno Otro False; tres con los dos origenes True.
  - `ValidarTestigo`: nombre vacio o en blanco => 1 error; nombre de 101 caracteres => 1; cargo de 101 => 1; correcto => 0.
  - `ValidarActaDepuracion`: lugar vacio => 1 error; `FPrevista = 0` => 1; ambos mal => 2; lugar de 256 caracteres => 1; correcto => 0.
  - `ValidarMuestra`: descripcion o localizacion vacias => un error cada una; mas de 255 => error; correcta => 0.
  - `ConfirmacionEscritaValida`: `'ELIMINAR'` y `'  ELIMINAR '` True; `'eliminar'`, `'Eliminar'`, `''`, `'ELIMINAR TODO'` False.
  - `TextoEstadoDepuracion`: paso 1 en curso 'Propuesta', 2 'En autorizacion', 3 'Acta por firmar', 4 'Lista para ejecutar', 5 'Ejecutada'; finalizado (cualquier paso) 'Cerrada'; cancelado 'Cancelada'.
  - `TextosQueFaltanDepuracion([cdAutorizado, cdMuestraDefinida, cdTestigosMinimos])` devuelve tres frases distintas no vacias; `[]` => vacio.
  - Ida y vuelta de `CodigoVia`/`ViaDesdeCodigo` y de los codigos de origen; `ViaDesdeCodigo('X')` lanza.
- [ ] **Step 2:** Registrar las unidades en los `.dpr`, compilar. Expected: FAIL (no compila: identificadores sin declarar).
- [ ] **Step 3:** Implementar. `PlazoCentralVencido` compara contra `FechaCorte(Hoy, AniosCentral)` (cierre) o `FechaCorte(Hoy, AniosGestion + AniosCentral)` (fecha base), como `PlazoVencido` de `UTransferenciasReglas`; `UnidadesEnLetras` es un algoritmo de miles/millones en espanol femenino ('una', 'veintiuna', 'doscientas', apocope 'veintiun mil', 'un millon'); sin acentos (ASCII).
- [ ] **Step 4:** Suite. Expected: PASS.
- [ ] **Step 5: Commit** `feat(depuracion): reglas puras (plazo en el central, numero en letras, acta, testigos, confirmacion)`.

### Task 3: Documento eliminado (`UEliminados`, consulta compartida)

**Files:**
- Create: `UEliminados.pas`, `Pruebas/UPruebasEliminados.pas`; agregar a los dos `.dpr`.

**Interfaces:** Consumes: patron y rutinas de `UTransferidos.pas` (`TablasDeProcesosExisten`, estructura de `ClavesTransferidas`), `UCandados.TUnidadDoc`. Produces (sin VCL; RTL + FireDAC):
```
function SqlEliminados: string;          // U.IdEstructura, U.id, U.codsubs, U.Codigodoc, U.fecha, U.version, P.IdProceso, P.Numero; WHERE P.Tipo = 'D' AND P.Estado <> 'X' AND P.Paso >= 5 AND U.Activa <> 0; sin parametros
function SqlNoEliminado: string;         // NOT EXISTS (...) con alias H (tb_SeriesDatos), sin parametros
function TextoEliminado(const Numero: string): string;      // 'Eliminado (D-2026-02)'
function DondeEstaEliminado(Conn: TFDConnection; const U: TUnidadDoc): string;   // '' si no; solo la falta de tablas prc_* cuenta como "no eliminado"
function EstaEliminado(Conn: TFDConnection; const U: TUnidadDoc): Boolean;
function ClavesEliminadas(Conn: TFDConnection; const Docs: array of TUnidadDoc): TArray<Boolean>;   // una consulta por subserie
```

- [ ] **Step 1: Tests:**
  - Puros: `SqlEliminados` contiene `P.Tipo = 'D'`, `P.Estado <> 'X'`, `P.Paso >= 5`, `U.Activa <> 0` y la clave completa (`codsubs`, `Codigodoc`, `fecha`, `version`), sin `:`; `SqlNoEliminado` empieza por `NOT EXISTS`; `TextoEliminado('D-2026-02')` = `'Eliminado (D-2026-02)'`.
  - Base (documentos y procesos `D` sembrados a mano: `prc_proceso` tipo `'D'`, `prc_unidad`; limpiar por `CreadoPor = '__prueba__'`): un documento de un proceso `D` en el paso 4 NO esta eliminado; en el paso 5 y finalizado en el 5 SI; con el proceso cancelado (`'X'`) no; con la unidad inactiva (`Activa = 0`) no; `ClavesEliminadas` marca cada documento (uno eliminado, uno no, uno de otra subserie); contra la base `tempdb` (sin tablas `prc_*`) `DondeEstaEliminado` devuelve `''` y `ClavesEliminadas` todo falso.
- [ ] **Step 2:** Registrar en los `.dpr`, compilar y ejecutar. Expected: FAIL (no compila).
- [ ] **Step 3:** Implementar igual que `UTransferidos` (consulta con alias, tolerancia a "sin tablas" con `TablasDeProcesosExisten`, agrupacion por subserie en `ClavesEliminadas`).
- [ ] **Step 4:** Suite. Expected: PASS.
- [ ] **Step 5: Commit** `feat(depuracion): consulta compartida de documentos eliminados`.

### Task 4: Datos I: propuesta, creacion y grupos

**Files:**
- Create: `UDepuracionDatos.pas`, `Pruebas/UPruebasApoyoDepuracion.pas`, `Pruebas/UPruebasDepuracionDatos.pas`; agregar a los dos `.dpr`.

**Interfaces:** Consumes: `UEliminados.SqlNoEliminado` (Task 3), `UProcesosDatos` (`CrearProceso`, `AgregarUnidad`, `TProcesoRef`, `IniciarTx`/`ConfirmarTx`/`DeshacerTx`), `UTransferenciasDatos` (patron, sin reutilizar sus funciones), `UTransferenciasReglas.FechaCorte`, `UDepuracionReglas.PlazoCentralVencido`, `UPrestadosSql.SqlPrestadosViejos`. Produces:
```
type
  TGrupoDepuracion = record
    IdEstructura: string; IdNodo: Integer; CodSubs, Serie, Subserie: string;
    AniosCentral: Integer; Unidades, Retenidos: Integer; Desde, Hasta: TDateTime;
  end;
  TDepuracionFila = record
    IdProceso, Anio, Consecutivo, Paso: Integer; Numero, Series, Estado: string;
    Unidades: Integer; Desde, Hasta, FPrevista, FEjecucion: TDateTime;   // 0 = sin fecha
    Proceso: TEstadoProceso; Nodo: TClaveNodo;
  end;
  TAnioCantidad = record Anio, Unidades: Integer; end;
function SqlCondicionVencidoCentral: string;   // alias H, parametros :corteT (cierre de transferencia) y :corteF (fecha base)
function ProponerDepuracion(Conn: TFDConnection; const Nodo: TClaveNodo; Hoy: TDateTime): TArray<TGrupoDepuracion>;
function CrearDepuracion(Conn: TFDConnection; const Nodo: TClaveNodo; const Usuario: string; Anio: Integer): TProcesoRef;  // crea tambien la fila de prc_depuracion
function AgregarGrupoDepuracion(Conn: TFDConnection; IdProceso: Integer; const G: TGrupoDepuracion; Hoy: TDateTime; out Agregados: Integer; out Motivo: string): Boolean;
procedure QuitarGrupoDepuracion(Conn: TFDConnection; IdProceso: Integer; const IdEstructura: string; IdNodo: Integer; const CodSubs: string);
function GruposDeLaDepuracion(Conn: TFDConnection; IdProceso: Integer): TArray<TGrupoDepuracion>;   // lo ya agregado, por subserie
function DesglosePorAnio(Conn: TFDConnection; IdProceso: Integer): TArray<TAnioCantidad>;           // por ano de Fecha, ascendente
function ListarDepuraciones(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>; Anio, Limite: Integer): TArray<TDepuracionFila>;
```
Apoyo de pruebas (`UPruebasApoyoDepuracion`): `SembrarSerieDepurable(Conn; const Cod: string; AniosCentral: Integer; Documentos: Integer; Archivo: Integer): TClaveNodo` crea una subserie de prueba en `cl_subseries` (destino 3, `tgestion` 0, `tcentral` = AniosCentral), su fila en `tb_Serietree` (en un nodo existente de `tb_tree`) y N documentos de 2010 en `tb_SeriesDatos` con `Archivo` dado y `titulodoc = '__prueba__'`; `LimpiarSerieDepurable(Conn)` los borra. `ArchivoCentralApoyo(Conn): Integer` y `ArchivoGestionApoyo(Conn): Integer` crean (si faltan) archivos de prueba de tipo Central (`Tipo = 1`) y Gestion (`Tipo = 2`) en `cl_ArchivosGestion` con `nombreArchivo = '__prueba__'` y devuelven su codigo.

- [ ] **Step 1: Tests de base** (se omiten sin `ARCHIGENIO_TEST_DB`; limpian en `Limpiar`):
  - Puro: `SqlCondicionVencidoCentral` contiene `:corteT`, `:corteF`, `prc_unidad`, `P.Tipo = 'T'`, `P.Estado = 'F'`, `P.Cerrado` y `H.FechaFin >= H.Fecha`.
  - `ProponerDepuracion`: una serie con `tcentral = 5`, 3 documentos en archivo Central de 2010 => un grupo con `Unidades = 3`, `Desde`/`Hasta` en 2010, `AniosCentral = 5`; los mismos documentos en archivo de **Gestion** => ningun grupo; `tcentral = 0` => ningun grupo; subserie con destino distinto de 3 => ninguno; con `tcentral` mayor que los anos transcurridos (por ejemplo 50) => ninguno.
  - Documento transferido: si el documento esta en una transferencia finalizada con `Cerrado` reciente (insertada a mano: proceso 'T' 'F', `prc_transferencia`, `prc_unidad` activa) y `tcentral = 5`, NO se propone aunque su fecha sea de 2010 (cuenta desde el cierre); con `Cerrado` de hace 6 anos si.
  - Retenidos: un documento retenido (`prc_bloqueo` de otro proceso) no entra en `Unidades` y suma a `Retenidos`; un documento en prestamo viejo abierto (`TB_Prestamos` + `TB_PrestamosDocumentos`, sin `FDevolucion` ni `FCancelacion`) tampoco se propone.
  - `CrearDepuracion` devuelve numero `D-<anio>-NN` consecutivo y crea la fila de `prc_depuracion`; `AgregarGrupoDepuracion` retiene los documentos (`prc_bloqueo`), devuelve `Agregados = 3` y una segunda llamada devuelve `False` con motivo (ya retenidos); `QuitarGrupoDepuracion` los libera.
  - `GruposDeLaDepuracion` y `DesglosePorAnio` (documentos de 2010 y 2011 => dos filas ascendentes con sus cuentas); `ListarDepuraciones` respeta `Anio` y `Limite`.
- [ ] **Step 2:** Compilar y ejecutar. Expected: FAIL (no compila / filas ausentes).
- [ ] **Step 3:** Implementar imitando `ProponerTransferencia`/`AgregarGrupo`/`QuitarGrupo`/`ListarTransferencias` de `UTransferenciasDatos.pas`: dos consultas por subserie; solo documentos cuyo `H.Archivo` es de un archivo con tipo Central o Historico (`TipoArchivoDesdeTexto` sobre `cl_tipoarch`); `SqlCondicionVencidoCentral` = `((EXISTS cierre de transferencia finalizada del documento con P.Cerrado <= :corteT) OR (NOT EXISTS ese cierre AND <fecha base> <= :corteF))` donde `:corteT = FechaCorte(Hoy, tcentral)` y `:corteF = FechaCorte(Hoy, tgestion + tcentral)`; excluir los ya eliminados (`SqlNoEliminado`, Task 3) y los que retiene `prc_bloqueo` o un prestamo viejo abierto; `AgregarGrupoDepuracion` con `INSERT ... SELECT` que retiene en `prc_bloqueo` y crea `prc_unidad` en una transaccion.
- [ ] **Step 4:** Suite. Expected: PASS.
- [ ] **Step 5: Commit** `feat(depuracion): propuesta por plazo en el central, creacion y grupos`.

### Task 5: Datos II: autorizacion, acta, testigos y avance

**Files:**
- Modify: `UDepuracionDatos.pas`
- Test: `Pruebas/UPruebasDepuracionDatos.pas`

**Interfaces:** Consumes: Task 4, `UProcesosDatos.GuardarAutorizacion`, `UTransferenciasDatos.LeerAutorizacion`, `UDepuracionReglas`. Produces:
```
type
  TActaDepuracion = record
    Lugar: string; Via: TViaEliminacion; FPrevista: TDateTime; MuestraDesc, MuestraDonde: string;
  end;
  TTestigoFila = record IdTestigo: Integer; Nombre, Cargo: string; Origen: TOrigenTestigo; Firmo: Boolean; end;
procedure GuardarActaDepuracion(Conn: TFDConnection; IdProceso: Integer; const A: TActaDepuracion);   // EArgumentException si ValidarActaDepuracion/ValidarMuestra fallan o no esta en pasos 1 a 3
function LeerActaDepuracion(Conn: TFDConnection; IdProceso: Integer; out A: TActaDepuracion): Boolean;
function AgregarTestigo(Conn: TFDConnection; IdProceso: Integer; const T: TTestigoDatos): Integer;   // id; EArgumentException si ValidarTestigo falla o el proceso no esta en curso
procedure QuitarTestigo(Conn: TFDConnection; IdProceso, IdTestigo: Integer);
procedure MarcarFirma(Conn: TFDConnection; IdProceso, IdTestigo: Integer; Firmo: Boolean);
function TestigosDeLaDepuracion(Conn: TFDConnection; IdProceso: Integer): TArray<TTestigoFila>;
function CondicionesCumplidasDepuracion(Conn: TFDConnection; IdProceso: Integer; out Faltan: TArray<string>): TCondiciones;
function AvanzarDepuracion(Conn: TFDConnection; IdProceso, PasoLeido: Integer; const Usuario: string; out Faltan: TArray<string>): Boolean;   // pasos 1 a 3; False si falta algo o ya no esta en ese paso
```
`CondicionesCumplidasDepuracion`: `cdSinBloqueos` = hay al menos una unidad activa y todas siguen retenidas por este proceso en `prc_bloqueo`; `cdAutorizado` = hay autorizacion guardada; `cdMuestraDefinida` = `MuestraDesc` y `MuestraDonde` no vacias; `cdTestigosMinimos` = `TestigosSuficientes`; `cdActaCompleta` = `Lugar`, `Via` y `FPrevista` guardados. `Faltan` trae `TextosQueFaltanDepuracion` de lo que no se cumple. `AvanzarDepuracion` usa `AvanzarPaso` con las condiciones del paso.

- [ ] **Step 1: Tests de base:**
  - `GuardarActaDepuracion` con lugar vacio lanza y no guarda; correcta se lee igual con `LeerActaDepuracion` (via, fecha, muestra); fuera de los pasos 1 a 3 lanza.
  - `AgregarTestigo`: devuelve ids distintos; nombre vacio lanza; `TestigosDeLaDepuracion` los devuelve en orden de alta; `QuitarTestigo` los quita; `MarcarFirma` cambia `Firmo`.
  - Un proceso con dos testigos de la Comision: `cdTestigosMinimos` NO se cumple y `Faltan` lo dice; con uno de la Comision y uno de archivo de gestion si.
  - Recorrido: proceso con un grupo agregado: `AvanzarDepuracion(...,1,...)` pasa al 2; el paso 2 exige autorizacion (`GuardarAutorizacion` con `ocProvincial`, acta 14, acuerdo 9, fecha de ayer; con `ocCentral` lanza `EAutorizacionInvalida`); el paso 3 exige muestra, 2 testigos validos y acta completa y falla con `Faltan` mientras falte alguno; con todo pasa al 4; `PasoLeido` desfasado devuelve `False` sin cambiar nada.
  - `QuitarGrupoDepuracion` de todo el proceso: `cdSinBloqueos` no se cumple (sin unidades) y no avanza del paso 1.
- [ ] **Step 2:** Compilar y ejecutar. Expected: FAIL.
- [ ] **Step 3:** Implementar; las escrituras van en transaccion propia (`IniciarTx`/`ConfirmarTx`/`DeshacerTx`) y exigen proceso `Tipo = 'D'` en curso (`LeerProceso`).
- [ ] **Step 4:** Suite. Expected: PASS.
- [ ] **Step 5: Commit** `feat(depuracion): autorizacion, acta, muestra, testigos y avance de los pasos 1 a 3`.

### Task 6: Datos III: ejecucion, cierre y cancelacion

**Files:**
- Modify: `UDepuracionDatos.pas`
- Test: `Pruebas/UPruebasDepuracionDatos.pas`

**Interfaces:** Consumes: Task 5. Produces:
```
function EjecutarDepuracion(Conn: TFDConnection; IdProceso: Integer; const Usuario, Confirmacion: string; Hoy: TDateTime): Boolean;
function CerrarDepuracion(Conn: TFDConnection; IdProceso: Integer; const Usuario: string): Boolean;
```
`EjecutarDepuracion` (paso 4 -> 5): `False` si ya no esta en el paso 4; `EArgumentException` si `ConfirmacionEscritaValida` es falso, si alguna unidad ya no esta retenida por este proceso, si alguna esta en un prestamo viejo abierto (`UPrestadosSql.SqlPrestadosViejos`) o si algun documento de las unidades dejo de estar en un archivo Central o Historico; en UNA transaccion llama a `AvanzarPaso(IdProceso, 4, [cdConfirmacionEscrita, cdSinBloqueos], ...)`, guarda `prc_depuracion.FEjecucion = Hoy` y escribe un evento con el numero de acta. Los documentos pasan a eliminados por la propia regla de `UEliminados` (Task 3: `Paso >= 5`); NO se modifica `tb_SeriesDatos`. `CerrarDepuracion` (paso 5 -> finalizada): `AvanzarPaso(IdProceso, 5, [], ...)`; libera los candados.

- [ ] **Step 1: Tests de base:**
  - Con un proceso en el paso 4: `EjecutarDepuracion` con `'eliminar'` lanza y el proceso sigue en el paso 4; con `'ELIMINAR'` devuelve `True`, `Paso = 5`, `FEjecucion` guardada, **las filas de `tb_SeriesDatos` siguen todas** (conteo igual al de antes) y `prc_bloqueo` sigue reteniendo las unidades; la segunda llamada devuelve `False` y no cambia nada.
  - Si entre el paso 3 y la ejecucion se borra el candado de una unidad (`DELETE FROM prc_bloqueo` a mano), `EjecutarDepuracion` lanza y no ejecuta; si se inserta un prestamo viejo abierto del documento, lanza y no ejecuta.
  - Si el documento deja de estar en un archivo Central (se pone `Archivo` a un archivo de Gestion), lanza.
  - Atomicidad: cuando falla la revalidacion, el proceso sigue en el paso 4 y `FEjecucion` es nulo.
  - `CerrarDepuracion`: solo desde el paso 5 (`False` en otro paso); deja el proceso finalizado (`Estado = 'F'`) y sin candados (`prc_bloqueo` vacio para el proceso); las unidades siguen `Activa <> 0`.
  - `CancelarProceso` (de `UProcesosDatos`) funciona hasta el paso 3 y libera los candados; en el paso 4 devuelve `False`.
- [ ] **Step 2:** Compilar y ejecutar. Expected: FAIL.
- [ ] **Step 3:** Implementar con `IniciarTx`/`ConfirmarTx`/`DeshacerTx`; la revalidacion de archivo usa la misma resolucion de tipo de archivo que `ProponerDepuracion` (extraerla a una rutina interna comun).
- [ ] **Step 4:** Suite. Expected: PASS.
- [ ] **Step 5: Commit** `feat(depuracion): ejecucion con confirmacion y revalidacion, cierre y cancelacion`.

### Task 7: Guardas del documento eliminado

**Files:**
- Modify: `UPrestamosDatos.pas` (`AgregarDocumento`), `UEdicionDocumento.pas` (`ActualizarDocumentos`), `UTransferenciasDatos.pas` (`ProponerTransferencia`/`AgregarGrupo`: excluir eliminados), `UMAINFORM.pas` (ficha, soltar ficheros y eliminar: bloquear tambien los eliminados)
- Test: `Pruebas/UPruebasPrestamosDatos.pas`, `Pruebas/UPruebasEdicionDocumento.pas`, `Pruebas/UPruebasTransferenciasDatos.pas`, `Pruebas/UPruebasDepuracionDatos.pas`

**Interfaces:** Consumes: `UEliminados` (Task 3), una depuracion ejecutada (Task 6). Produces: ninguna nueva en datos; en `UMAINFORM.pas` la funcion de unidad `DondeBloqueadoDoc(const Clave: TClaveDocumento): string` (generaliza `DondeTransferidoDoc`: devuelve el texto de transferido o el de eliminado; si no se puede comprobar, un texto que bloquea).

- [ ] **Step 1: Tests de base** (documento eliminado = unidad activa de un proceso `D` con `Paso = 5`, sembrada a mano):
  - `AgregarDocumento` de un prestamo rechaza un eliminado (`Motivo` empieza por `Eliminado`) y no agrega nada.
  - `ActualizarDocumentos` omite un eliminado, guarda el otro del lote y el mensaje contiene `eliminado`.
  - `ProponerTransferencia` y `AgregarGrupo` de una transferencia no incluyen documentos eliminados (documento de una subserie con plazo vencido que ademas esta eliminado: no se propone).
  - `ProponerDepuracion` ya los excluye (Task 4): agregar la prueba de regresion con un documento eliminado por otra depuracion.
- [ ] **Step 2:** Compilar y ejecutar. Expected: FAIL (las guardas no existen).
- [ ] **Step 3:** Enganchar las guardas: en `UPrestamosDatos.AgregarDocumento` junto a la de transferidos (`DondeEstaEliminado`); en `UEdicionDocumento.ActualizarDocumentos` sumar `ClavesEliminadas` a `ClavesYaTransferidas` (omitido y contado, con un mensaje propio `... omitido(s) por estar eliminado(s)`); `SqlNoEliminado` en el WHERE de `ProponerTransferencia` y de `AgregarGrupo`. En `UMAINFORM.pas` renombrar/generalizar `DondeTransferidoDoc` a `DondeBloqueadoDoc` y usarlo en `ListaDocsPuedeEditar`, soltar ficheros/contenido/lote y eliminar (solo compilacion: son rutinas de ventana).
- [ ] **Step 4:** Suite y compilar `ArchiGenioPro.dproj`. Expected: PASS y sin errores.
- [ ] **Step 5: Commit** `feat(depuracion): los documentos eliminados quedan en solo lectura`.

### Task 8: Documentacion y cierre de la entrega a

**Files:**
- Modify: `CLAUDE.md` (parrafo de Depuracion en "Procesos archivisticos"), memoria `project_procesos_archivisticos` y `MEMORY.md`
- Create: `docs/superpowers/plans/2026-11-18-verificacion-depuracion-f4a.md` (lista corta: SQL contra la base de pruebas ya cubierto; lo manual llega con la entrega b)

- [ ] **Step 1:** Suite completa con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`. Expected: todo pasa; `sqlcmd` confirma que `tb_nodo_egd` y las transferencias T-2026-01/02 siguen como antes y que no quedan filas de prueba (`titulodoc = '__prueba__'`, `cl_ArchivosGestion` de prueba, `cl_subseries` de prueba).
- [ ] **Step 2:** Resumir en `CLAUDE.md` la entrega a (unidades `UDepuracionReglas`, `UDepuracionDatos`, `UEliminados`; tablas `prc_depuracion`/`prc_testigo`; regla "eliminado = unidad activa de depuracion ejecutada"; pendiente: b pantallas y acta, c retiro de ficheros y migracion) y actualizar la memoria.
- [ ] **Step 3: Commit** `docs: F4a de depuracion (datos y reglas)`.

---

## Self-review

- **Cobertura del spec (entrega a):** propuesta por destino E y plazo en el central (T2, T4); exclusiones por candado/prestamo viejo (T4, T6); autorizacion de la Comision (T5); acta con lugar, via, fecha, muestra y testigos (T2, T5); desglose por ano y numero en letras (T2, T4); ejecucion con `ELIMINAR` y revalidacion, una transaccion, sin tocar `tb_SeriesDatos` (T6); cierre y cancelacion (T6); documento eliminado derivado (T3), solo lectura y guardas (T7); esquema (T1); documentacion (T8). Fuera de esta entrega, a proposito: pantallas, Acta impresa, retiro de ficheros, migracion y condicion `cdFicherosResueltos` (b y c). Quien puede iniciar (rol del EGD sobre archivo Central/Historico) lo aplica la entrega b con `PuedeIniciar`; los datos solo proponen documentos que ya estan en esos archivos.
- **Consistencia de tipos:** `TGrupoDepuracion`, `TActaDepuracion`, `TTestigoFila`, `TAnioCantidad`, `TDepuracionFila`, `TTestigoDatos` y `TUnidadDoc` se definen una vez y se usan con los mismos nombres; `UEliminados` (T3) se crea antes de `UDepuracionDatos` (T4) que lo consume.
- **Proporcion:** firmas, pruebas y valores del spec; los cuerpos los escribe quien implementa.
