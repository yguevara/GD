# Asignación de EGD y directores por nodo — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que el administrador asigne EGD y Directores a todos los nodos desde una pantalla (árbol con casillas), con varios por nodo, propagación a los hijos y EGD con lectura en los descendientes.

**Architecture:** (1) `tb_nodo_egd` pasa a clave `(IdEstructura,id,user_id)` por `CrearEsquemaAlcance`. (2) `UAlcance.pas` cambia la regla del EGD: ver en su nodo y descendientes, resto de acciones solo en su nodo. (3) Una unidad nueva `UAsignacionDatos.pas` (sin VCL) lee y escribe asignaciones de forma transaccional, con las reglas de propagación como funciones puras probables. (4) Una pantalla nueva `UAsignacionNodos.pas` la usa. (5) Entrada de menú solo para Administrador en SQL Server.

**Tech Stack:** Delphi VCL, FireDAC (MSSQL), DUnitX (`Pruebas/`), `scripts/compilar.ps1`.

**Spec:** `docs/superpowers/specs/2026-10-30-asignacion-egd-design.md` (aprobado por el usuario con todos sus supuestos, 2026-10-31). Contexto: `2026-10-30-roles-y-topografia-design.md`.

## Global Constraints

- Fuentes ANSI/Windows-1252: editar por bytes (`latin-1`, script Python); NO normalizar a UTF-8 ni tocar fines de línea (UMAINFORM.pas y UCapaDatos.pas mezclan CRLF/LF). `.md` en UTF-8.
- Todo SQL debe valer en Access y SQL Server donde corra en ambos; la pantalla y su capa de datos son **solo SQL Server** (en Access `UDM.Alcance = nil` y la entrada de menú no aparece).
- Pruebas SOLO contra `SGDTEST_ALCANCE` (localhost, geoconn/geoconn; `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`). NUNCA ejecutar DDL, `UpDateDB` ni scripts contra `SGDDRHMAIN`.
- No hacer push ni merge sin que el usuario lo pida. Trabajar en una rama nueva `asignacion-egd` desde `main`.
- No matar `ArchiGenioPro.exe` del usuario; verificar el proyecto principal con `/p:DCC_ExeOutput=%TEMP%\outv`.
- Comentarios y mensajes en español, estilo del código vecino (comentarios `{ }` o `//`, sin tildes en comentarios de las unidades nuevas como `UAlcance.pas`).
- Unidades nuevas se agregan a `ArchiGenioPro.dpr` (uses) y a `Pruebas/PruebasArchiGenio.dpr`.
- Roles: `tb_tree_directors.idrol = 3` (Director), `user_id` = `Idresp` INT; EGD en `tb_nodo_egd.user_id` = `tb_user.nombreuser`.
- Commits terminan con `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.
- Verificación: `powershell -NoProfile -File scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y luego `Pruebas/Win32/Debug/PruebasArchiGenio.exe` → hoy 86/86 pasan; deben seguir pasando salvo las pruebas reescritas.

## Review Focus

1. Dos EGD (o dos Directores) en el mismo nodo: cada uno ve y actúa; quitar a uno no afecta al otro.
2. Quitar un EGD/Director de un ancestro con «incluir hijos»: se borran solo las filas propias de ese usuario/rol en descendientes; lo que otro usuario tenía en el hijo se conserva.
3. Guardado a medias (error en la fila N): no queda ninguna fila nueva (transacción) y la pantalla informa.
4. Usuario sin fila en `tb_user`: se crea al asignarlo como EGD; si ya existe con otra capitalización no se duplica.
5. Base ya migrada o antigua (clave vieja con filas existentes): `CrearEsquemaAlcance` conserva las filas, es idempotente y ejecutarlo dos veces no falla.

---

### Task 1: Migración de `tb_nodo_egd` a clave `(IdEstructura,id,user_id)`

**Files:**
- Modify: `UEsquemaAlcance.pas` (CREATE de `tb_nodo_egd` + migración tras las `CrearTabla`)
- Modify: `Pruebas/UPruebasEsquema.pas` (reemplazar `NodoNoAdmiteDosEGD`; ampliar Access)

**Interfaces:**
- Produces: `tb_nodo_egd` admite varios `user_id` por nodo; sin filas perdidas al migrar.

- [ ] **Step 1: Pruebas.** En `TPruebasEsquema` reemplazar `NodoNoAdmiteDosEGD` por `NodoAdmiteVariosEGD` (inserta dos usuarios distintos en un nodo, `Assert.AreEqual(2, conteo)`; el mismo usuario dos veces sí debe lanzar `EFDDBEngineException` con `Assert.IsTrue(Lanzo, 'Se permitio el mismo EGD dos veces')`). Añadir `MigraClaveAntiguaSinPerderFilas`: borra y recrea `tb_nodo_egd` con la clave vieja `PK_tb_nodo_egd (IdEstructura, id)` + una fila, llama `CrearEsquemaAlcance(FConn, True)` y afirma que la fila sigue y que ya admite un segundo usuario en el nodo. Limpiar al final dejando la tabla vacía de las filas de prueba.
- [ ] **Step 2: Ejecutar y ver fallar.** Compilar y correr; `NodoAdmiteVariosEGD` y `MigraClaveAntiguaSinPerderFilas` fallan.
- [ ] **Step 3: Implementar** en `UEsquemaAlcance.pas`: el CREATE usa `PRIMARY KEY (IdEstructura, id, user_id)`. Después de crear las tablas, solo SQL Server: si `PK_tb_nodo_egd` existe y cubre solo 2 columnas (`SELECT COUNT(*) FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE CONSTRAINT_NAME='PK_tb_nodo_egd'` = 2), ejecutar `ALTER TABLE tb_nodo_egd DROP CONSTRAINT PK_tb_nodo_egd` y `ALTER TABLE tb_nodo_egd ADD CONSTRAINT PK_tb_nodo_egd PRIMARY KEY (IdEstructura, id, user_id)` en una transacción (`Conn.StartTransaction/Commit/Rollback`). Access: la tabla está vacía por diseño; si existe con clave vieja (no se puede inspeccionar fácil) hacer `DROP TABLE tb_nodo_egd` solo si `SELECT COUNT(*)` = 0 y recrear; si tiene filas, dejarla.
- [ ] **Step 4: Verificar.** Suite completa en verde (el contador cambia por la prueba reemplazada/añadida).
- [ ] **Step 5: Commit** `Esquema: tb_nodo_egd admite varios EGD por nodo`.

### Task 2: Regla nueva del EGD en `UAlcance.pas` y filtros

**Files:**
- Modify: `UAlcance.pas` (`Permite`, `NodosVisibles`, `NodosCompletos`, comentario de cabecera de `PuedeEliminarDocumento` — aclarar que ignora `CodSubs`)
- Modify: `Pruebas/UPruebasAlcance.pas`, `Pruebas/UPruebasAlcanceDatos.pas` (oráculo `FEsc.Oraculo` del EGD y `FiltroArbol_SoloNodosVisibles`)

**Interfaces:**
- Consumes: `TArbolNodos.EsDescendiente(Raiz, Nodo)` (asumido que es falso para Raiz = Nodo; confirmar leyendo el código y, si es así, añadir `MismoNodo` como ya hace `Permite`).
- Produces: EGD → `acVer` en nodo y descendientes; el resto de acciones solo en `MismoNodo`. `NodosCompletos` y `NodosVisibles` incluyen sus descendientes (con ancestros en `NodosVisibles`). Ninguna firma pública cambia.

- [ ] **Step 1: Pruebas.** Reescribir `EGD_NoDesciende` como `EGD_VeDescendientes_PeroNoActuaEnEllos`: EGD de A.4(101) → `PuedeVerDocumento(A.4.3/104, '014001', 2)` True; `PuedeRealizar(acEditar, A.4.3/104, ...)` False; `PuedeRealizar(acEditar, A.4/101, ...)` True; `PuedeEliminarDocumento(A.4.3/104, ..., 0)` False. Nuevas: `DosEGDEnElMismoNodo_AmbosActuan` (dos `Crear` con el mismo nodo), `DosDirectoresEnElMismoNodo`, `NodosCompletos_EGDIncluyeDescendientes` (A.4 → contiene 101 y 104 y no 82), `NodosVisibles_EGDIncluyeDescendientesYAncestros`. Ajustar las pruebas del filtro SQL (`FiltroArbol_SoloNodosVisibles`, oráculo de documentos) a la regla nueva; el oráculo en `TEscenarioSql` debe contar los documentos de los descendientes para un EGD.
- [ ] **Step 2: Ejecutar y ver fallar** las reescritas.
- [ ] **Step 3: Implementar.** En `Permite`, `rnEGD`: `if MismoNodo(...) or ((Accion = acVer) and FArbol.EsDescendiente(A.Nodo, Nodo)) then Exit(True)`. En `NodosVisibles` y `NodosCompletos`, el caso `rnEGD` acumula igual que `rnDirector` (descendientes; en visibles con ancestros). `PuedeEliminarDocumento` y `EsEGDDeAlgunNodo` no cambian. Como `FiltroDocumentos`/`FiltroNodosArbol` se derivan de `NodosCompletos`/`NodosVisibles`, no se tocan.
- [ ] **Step 4: Verificar.** Suite completa en verde; revisar que `UMAINFORM.AplicarReglasPorAlcance` sigue coherente (el EGD ahora puede ver descendientes pero los botones de acción dependen de `PuedeRealizar`, que ya filtra por nodo).
- [ ] **Step 5: Commit** `Alcance: el EGD ve los descendientes de su nodo; varios EGD y directores por nodo`.

### Task 3: Capa de datos de asignación (`UAsignacionDatos.pas`)

**Files:**
- Create: `UAsignacionDatos.pas` (sin VCL), `Pruebas/UPruebasAsignacion.pas`
- Modify: `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr` (uses)

**Interfaces:**
- Consumes: `TArbolNodos` (`Todos`, `EsDescendiente`), `TClaveNodo`, `TRolNodo` de `UAlcance`; `ROL_DIRECTOR` (mover/duplicar como constante pública en esta unidad solo si `UAlcanceDatos` no la expone).
- Produces:
  ```pascal
  TAsignacion = record Nodo: TClaveNodo; Rol: TRolNodo; Usuario: string; end; // Usuario: nombreuser (EGD) o usuario de cl_Resp_Gest_Arch (Director)
  TCambioAsignacion = record Asignacion: TAsignacion; Agregar: Boolean; end;
  function NodosAfectados(Arbol: TArbolNodos; const Marcados: TArray<TClaveNodo>; IncluirHijos: Boolean): TArray<TClaveNodo>;
  function CalcularCambios(Arbol: TArbolNodos; const Marcados: TArray<TClaveNodo>; IncluirHijos: Boolean; Rol: TRolNodo; const Usuario: string; Agregar: Boolean): TArray<TCambioAsignacion>;
  function CargarAsignaciones(Conn: TFDConnection): TArray<TAsignacion>;      // propias, de ambas tablas
  procedure AplicarCambios(Conn: TFDConnection; const Cambios: TArray<TCambioAsignacion>); // transaccional
  function NodosSinEGDPropio(Arbol: TArbolNodos; const Propias: TArray<TAsignacion>): TArray<TClaveNodo>;
  function UsuariosHabilitados(Conn: TFDConnection): TArray<string>;          // cl_Resp_Gest_Arch habilitados
  ```
  `NodosAfectados`: marcados + (si `IncluirHijos`) todos sus descendientes, sin duplicados y solo nodos existentes. `CalcularCambios`: un cambio por nodo afectado, omitiendo las asignaciones que ya existen al agregar (se resuelve en `AplicarCambios`).

- [ ] **Step 1: Pruebas puras** (sin BD, árbol A(1)→A.4(101)→A.4.3(104), A.1(82)): `NodosAfectados_SinHijos`, `NodosAfectados_ConHijos_SinDuplicados` (marcar 101 y 104 con hijos → 2 nodos), `CalcularCambios_QuitarConHijosSoloDelUsuario`, `NodosSinEGDPropio_ListaLosQueNoTienen`, `NodosSinEGDPropio_HeredadoNoCuenta` (EGD solo en el padre → el hijo sigue listado).
- [ ] **Step 2: Pruebas contra `SGDTEST_ALCANCE`** (omitir sin `ARCHIGENIO_TEST_DB`; fixture que borra al terminar las filas que creó, restaurando egd_a43 en A.4.3/104): `AplicarCambios_AgregaEGDCreaUsuarioSiFalta` (usuario inexistente en `tb_user` → se crea; mayúsculas distintas no duplican), `AplicarCambios_DirectorUsaIdrespEIdrol3`, `AplicarCambios_Repetido_EsIdempotente`, `AplicarCambios_ErrorAMedias_NoDejaNada` (segundo cambio con nodo inexistente → excepción y cero filas nuevas), `AplicarCambios_QuitarUnEGD_NoQuitaAlOtro`.
- [ ] **Step 3: Ver fallar.**
- [ ] **Step 4: Implementar** las seis funciones. `AplicarCambios`: `Conn.StartTransaction`; para cada cambio con `INSERT … WHERE NOT EXISTS` / `DELETE` parametrizados (el Director se resuelve a `Idresp` con `SELECT Idresp FROM cl_Resp_Gest_Arch WHERE {fn UCASE(usuario)} = :u`; error si no existe); el EGD asegura `tb_user` (`INSERT INTO tb_user (nombreuser) SELECT :u WHERE NOT EXISTS (SELECT 1 FROM tb_user WHERE {fn UCASE(nombreuser)} = {fn UCASE(:u)})`); `Commit`, y `Rollback` + re-lanzar en cualquier excepción.
- [ ] **Step 5: Verificar** suite en verde.
- [ ] **Step 6: Commit** `Asignacion: capa de datos transaccional para EGD y directores`.

### Task 4: Pantalla `UAsignacionNodos`

**Files:**
- Create: `UAsignacionNodos.pas`, `UAsignacionNodos.dfm` (form `TfrmAsignacionNodos`)
- Modify: `ArchiGenioPro.dpr` (`UAsignacionNodos in 'UAsignacionNodos.pas' {frmAsignacionNodos}`)

**Interfaces:**
- Consumes: todo `UAsignacionDatos`; `UDM.Conn`; `UDM.log(Mensaje, acc, aSerie, aSSerie, aStructura)`.
- Produces: `TfrmAsignacionNodos.Create(nil).ShowModal` (función de arranque sin parámetros).

- [ ] **Step 1: Diseñar el formulario** (opción B): izquierda `TTreeView` con casillas (`TVS_CHECKBOXES` o imágenes de estado), cada nodo muestra «código · nombre — EGD: a, b · Dir: c» y, en gris, lo heredado (calculado en memoria subiendo por `Ancestros`); barra superior con contador «N nodos sin EGD propio» y casilla de filtro «solo sin EGD propio»; derecha `TComboBox` Usuario (de `UsuariosHabilitados`), `TRadioGroup` Rol (EGD/Director), `TCheckBox` «Incluir hijos», botones «Asignar a los marcados», «Quitar de los marcados», «Cerrar». El árbol se carga una vez en memoria (un `TArbolNodos` + `CargarAsignaciones`) y se pinta con `BeginUpdate/EndUpdate`; la etiqueta de cada nodo se recalcula solo para nodos afectados tras cada acción.
- [ ] **Step 2: Lógica.** «Asignar/Quitar» llama `CalcularCambios` + `AplicarCambios` en un `try/except` que muestra el error (`sms`/`MessageDlg` como el resto de la app) y, si falla, no cambia la vista; si funciona, recarga `CargarAsignaciones`, refresca etiquetas y contador y llama `UDM.log` una vez por operación («Asignó EGD <usuario> a N nodos», «Quitó Director <usuario> de N nodos») con la estructura del primer nodo. Confirmar con diálogo si «Quitar» afecta a más de 1 nodo. Sin marcados o sin usuario: mensaje y no hacer nada. Guardar con pendientes (nodos sin EGD) está permitido: solo el aviso del contador.
- [ ] **Step 3: Compilar** `ArchiGenioPro.dproj` con `/p:DCC_ExeOutput=%TEMP%\outv`; sin errores nuevos.
- [ ] **Step 4: Prueba manual en `SGDTEST_ALCANCE`** (el usuario la hará; dejar los pasos anotados en Task 6).
- [ ] **Step 5: Commit** `Pantalla de asignacion de EGD y directores por nodo`.

### Task 5: Entrada de menú solo para Administrador

**Files:**
- Modify: `UMAINFORM.pas`, `UMAINFORM.dfm` (botón/menú junto a `btnusercontrol`, cuyo handler es `btnusercontrolClick`, ~línea 3173)

**Interfaces:**
- Consumes: `TfrmAsignacionNodos`; `UDM.Alcance`, el rol/`UDM.Rol` del administrador (usar el mismo criterio que ya oculta `btnusercontrol`), tipo de BD (`TBD = 'S'`).
- Produces: `TMAIN.btnAsignacionNodosClick`.

- [ ] **Step 1: Añadir el botón** clonando las propiedades de `btnusercontrol` (mismo contenedor, caption «Asignación de responsables»); handler: `UDM.log('Accediendo a la asignacion de responsables.', 14, '', '', '')`, `ShowModal`, `UDM.log('Abandonando ...', 15, ...)` (reutilizar los códigos 14/15 solo si el visor `UAdminLog` los muestra como «módulo»; si no, no inventar códigos nuevos).
- [ ] **Step 2: Visibilidad.** Donde se decide la visibilidad de `btnusercontrol`, `btnAsignacionNodos.Visible := (administrador) and (TBD = 'S')`.
- [ ] **Step 3: Editar por bytes** (CRLF/LF mezclados); compilar con `/p:DCC_ExeOutput=%TEMP%\outv`.
- [ ] **Step 4: Commit** (truco `git hash-object`/`update-index --cacheinfo` si UMAINFORM aparece modificado solo por fines de línea) `Menu: asignacion de responsables solo para el administrador`.

### Task 6: Script, documentación y verificación manual

**Files:**
- Modify: `scripts/asignar_egd.sql` (nota: ya no sustituye al EGD; ahora agrega uno más; actualizar la cabecera «Un nodo tiene un solo EGD» y el `UPDATE` → solo `INSERT … WHERE NOT EXISTS`, simulacro por defecto)
- Modify: `docs/superpowers/plans/2026-10-29-verificacion-alcance.md` (casos manuales 15+)
- Modify: `CLAUDE.md` (una línea sobre la pantalla; sin versionar, no commitear)

- [ ] **Step 1: Ajustar el script** al nuevo modelo y probarlo en simulacro contra `SGDTEST_ALCANCE`.
- [ ] **Step 2: Casos manuales** (como administrador en `SGDTEST_ALCANCE`): 15) abrir la pantalla: se ven los 86 nodos y `egd_a43` en A.4.3; 16) marcar A.4 + «incluir hijos» + EGD `egd_a43`: A.4 y todos sus hijos lo muestran; 17) asignar un segundo EGD al mismo nodo; 18) quitar con «incluir hijos» desde A.4: los hijos pierden solo a ese usuario; 19) filtro «solo sin EGD propio» y contador; 20) iniciar sesión como `egd_a43` con EGD en A.4: ve A.4.3 pero no puede editar/eliminar en él; 21) cerrar sesión de administrador y comprobar que el menú no aparece para otros roles; 22) cancelar a medias (provocar error) no deja filas.
- [ ] **Step 3: Suite completa** y compilación de ambos proyectos; anotar resultado.
- [ ] **Step 4: Commit** `Asignacion de EGD: script al nuevo modelo y casos de verificacion`.
- [ ] **Step 5: Revisión final** de toda la rama por un revisor `opus` (Review Focus incluido); arreglar críticos/importantes.

---

## Auto-revisión

- **Cobertura del spec:** §4 datos → T1; §5 reglas → T2; §6 pantalla (árbol, heredado en gris, contador/filtro, transacción, log, solo admin/SQL Server) → T3–T5; §3 supuestos (aviso no bloqueo, quitar propias) → T3/T4; §7 no objetivos respetados (sin «Permisos de mi área», sin usuarios por subserie).
- **Consistencia de tipos:** `TAsignacion`/`TCambioAsignacion` se definen solo en T3 y se usan en T4.
- **Riesgo explícito:** la verificación visual de T4 depende del usuario; las reglas y la migración tienen pruebas automáticas.
