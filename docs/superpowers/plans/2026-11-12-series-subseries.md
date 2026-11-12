# Series y subseries (clasificador nuevo + editor de variables) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pantalla nueva "Series y subseries" embebida en la ventana principal, con un editor de las variables del formulario de cada subserie (arrastrar para ordenar, propiedades, vista previa en vivo), que permite añadir variables aunque la subserie ya tenga documentos.

**Architecture:** Datos y reglas en unidades sin VCL ni `TUDM` (RTL + FireDAC) con pruebas DUnitX contra `SGDTEST_ALCANCE` (SQL Server, prioridad del usuario); el editor se modela como una sesión pura (`TSesionVariables`) y la interfaz solo la pinta. La pantalla hereda de `TFormClasificadorBase` y reutiliza el patrón de Servidores/Archivos (embebida, fallback a la pantalla vieja `frmCLSeries`).

**Tech Stack:** Delphi 10.3 VCL, DevExpress cxGrid, FireDAC (SQL Server / Access), DUnitX.

**Spec:** maqueta aprobada `.superpowers/brainstorm/918-1794481622/content/series-maqueta-final.html` + decisiones de este plan (no hay documento de diseño aparte). Referencia de patrón: `docs/superpowers/specs/2026-11-12-clasificadores-design.md`.

## Global Constraints

- Codigo nuevo en ASCII con `#NNN` para acentos; fuentes existentes ANSI/CRLF (editar con Python latin-1 tolerante a `\r?\n`); archivos nuevos: escribir y convertir a CRLF.
- Mensajes solo por `UMensajes` (`TMensajes`). Estilo Light + paleta `UTema`. Sin `.dfm` en pantallas nuevas.
- Todo SQL valido en SQL Server y Access (parametros, sin `IIf`/`LEFT` incompatibles). Pruebas de BD solo con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`, nunca `SGDDRHMAIN`; cada prueba limpia lo que crea (codigos `ZZ*`).
- Cada unidad nueva se registra en `ArchiGenioPro.dpr` y `Pruebas/PruebasArchiGenio.dpr`.
- Compilar con `scripts/compilar.ps1`; commits con el trailer Co-Authored-By; no incluir `ArchiGenioPro.res`, `Win32/*.dcu`, `identcache`.
- Esquema real (SGDTEST_ALCANCE): `cl_VarSubserie(codserie, codsubs, Orden smallint, NomVariable varchar50, Etiqueta varchar100, tipo int -> CL_SubseriesTipoVar [1 Caracteres,2 Fecha,3 Entero,4 Memo,5 Real,6 Boolean], longitud smallint, descripcion text, obligatorio bit)`, PK `(codserie, codsubs, Orden)`. La tabla de datos es `md_<codserie><codsubs>` (solo alfanumericos, `UDM.QuitaCaracter`), se crea al guardar el primer documento (`CreateTableFromDefinitions`) y su nombre queda en `cl_subseries.NombreTablaMetadatos`. **No existe columna "lista desplegable"**: la maqueta lo muestra como "Descripcion / ayuda" (columna `descripcion`).

## Reglas de las variables (decision del usuario: opcion B)

- **Sin tabla de datos** (subserie sin documentos): edicion libre (agregar, quitar, renombrar, cambiar tipo/longitud, ordenar).
- **Con tabla de datos**: solo se puede **agregar** variables (ALTER TABLE ADD COLUMN, las existentes quedan NULL en los documentos viejos), y cambiar en las existentes solo `Etiqueta`, `descripcion`, `obligatorio` y `Orden`. Nombre, tipo, longitud y quitar quedan bloqueados.
- Nombre: valido para el motor (letra inicial, letras/digitos/`_`, max 30), no reservado (SQL Server y Access), no duplicado en la subserie ni igual a una columna base de la tabla (`IdEstructura, id, codsubs, Fecha, Version, Codigodoc`); etiqueta unica en la subserie; `Caracteres` exige longitud 1..8000.

## Review Focus

- Alta de variable en subserie con 1 299 documentos (md_014074): la columna aparece, los documentos viejos siguen leyendose y la busqueda/carga no se rompen.
- Fallo a mitad de guardado (nombre repetido, tabla bloqueada): no queda ni fila en `cl_VarSubserie` sin columna ni columna sin fila.
- Nombre que choca con palabra reservada o con columna base (`Fecha`, `Version`, `id`): se rechaza antes de tocar la BD.
- Dos usuarios editando la misma subserie: gana el guardado que llega primero; el segundo recibe un error claro, no datos mezclados.
- Subserie con `NombreTablaMetadatos` apuntando a una tabla que ya no existe (caso `002`: vacio): se trata como "sin tabla" (edicion libre).

## File Structure

- Create `UErroresCampo.pas` — `TErrorCampo` compartido (sale de `UServidoresDatos`).
- Create `UPalabrasReservadas.pas` — listas SQL Server/Access y `EsPalabraReservada` (salen de `UCapaDatos`).
- Create `UVariablesDatos.pas` — leer/validar/guardar variables y alta de columnas (sin VCL).
- Create `USeriesDatos.pas` — series y subseries: listar, validar, guardar, eliminar, opciones de catalogos (sin VCL).
- Create `UVariablesSesion.pas` — sesion de edicion (reglas de que se puede tocar, orden, cambios) sin VCL ni BD.
- Create `UVariablesEditor.pas` — panel VCL: lista ordenable, propiedades, vista previa.
- Create `UCLSeriesForm.pas` — pantalla (hereda de `TFormClasificadorBase`).
- Modify `UClasificadorBase.pas` (zona de indice izquierda opcional y vista alterna), `UMAINFORM.pas` (menu + fallback), `UCapaDatos.pas` (usa `UPalabrasReservadas`), `UServidoresDatos.pas`/`UArchivosDatos.pas` (usan `UErroresCampo`), `CLAUDE.md`.
- Tests: `Pruebas/UPruebasVariablesDatos.pas`, `UPruebasSeriesDatos.pas`, `UPruebasVariablesSesion.pas`, `UPruebasVariablesEditor.pas`, `UPruebasPalabrasReservadas.pas`.

---

### Task 1: Compartir `TErrorCampo` y las palabras reservadas

**Files:** Create `UErroresCampo.pas`, `UPalabrasReservadas.pas`, `Pruebas/UPruebasPalabrasReservadas.pas`; Modify `UServidoresDatos.pas`, `UArchivosDatos.pas`, `UCapaDatos.pas`, ambos `.dpr`.

**Interfaces:**
- Produces: `TErrorCampo = record Campo, Mensaje: string; end` (misma forma que hoy en `UServidoresDatos.pas:35`); `function EsPalabraReservada(const Nombre: string; EsSqlServer: Boolean): Boolean` (comparacion sin distinguir mayusculas).

- [ ] **Step 1: test** `EsPalabraReservada_SqlServer_Select` (`'select'` True), `_Access_Counter` (`'COUNTER'`, False para SQL Server), `_NombreLibre_False` (`'Municipio'`), `_Vacio_False`. Registrar el test en `Pruebas/PruebasArchiGenio.dpr`.
- [ ] **Step 2:** compilar pruebas. Expected: FAIL (unidad inexistente).
- [ ] **Step 3:** crear `UPalabrasReservadas.pas` moviendo `SQLServerReservadas`/`AccessReservadas` (`UCapaDatos.pas:38-45`) sin cambiar su contenido; `UCapaDatos` las usa desde la unidad (los bucles de `UCapaDatos.pas:2354` no cambian). Crear `UErroresCampo.pas` y hacer que `UServidoresDatos`/`UArchivosDatos` lo usen (borrar la declaracion local).
- [ ] **Step 4:** compilar app y pruebas; correr suite. Expected: todo verde (569 + nuevas).
- [ ] **Step 5:** commit `Compartir TErrorCampo y palabras reservadas`.

### Task 2: `UVariablesDatos` (leer, validar, guardar, anadir columna) — SQL Server primero

**Files:** Create `UVariablesDatos.pas`, `Pruebas/UPruebasVariablesDatos.pas`.

**Interfaces:**
- Consumes: `TCampoMeta`/`TTipoMeta`/`CargarCamposSubserie`/`NombreTablaMeta` (`UMetadatosSubserie`), `TErrorCampo`, `EsPalabraReservada`.
- Produces:
  - `TModoVariables = (mvLibre, mvSoloAnadir)`; `function ModoVariables(Conn; const CodSubs: string): TModoVariables` (`mvSoloAnadir` solo si la tabla `md_*` existe de verdad; `NombreTablaMetadatos` huerfano = `mvLibre`).
  - `function NombreTablaDatos(const CodSerie, CodSubs: string): string` (`'md_' + alfanumericos`).
  - `function ValidarVariables(const Lista: TArray<TCampoMeta>; EsSqlServer: Boolean): TArray<TErrorCampo>` (reglas de arriba; `Campo` = `'<nombre>.<propiedad>'`).
  - `procedure GuardarVariables(Conn; EsSqlServer: Boolean; const CodSerie, CodSubs: string; const Lista: TArray<TCampoMeta>)` — lanza `EVariables` (mensaje en espanol) si `ValidarVariables` falla o si en `mvSoloAnadir` se cambia/quita una variable existente en nombre, tipo o longitud.
  - `function SqlTipoColumna(Tipo: TTipoMeta; Longitud: Integer; EsSqlServer: Boolean): string` (igual mapeo que `CreateTableFromDefinitions`, `UCapaDatos.pas:3163`).

- [ ] **Step 1: tests (SQL Server, subserie `ZZ1/ZZ1A`, limpiar al final)**: `Modo_SinTabla_Libre`, `Modo_TablaHuerfana_Libre`, `Modo_ConTabla_SoloAnadir`, `Validar_NombreReservado`, `Validar_ColumnaBase_Fecha`, `Validar_NombreDuplicado`, `Validar_EtiquetaDuplicada`, `Validar_CaracteresSinLongitud`, `Validar_NombreConEspacios`, `Guardar_Libre_ReemplazaYOrdena`, `Guardar_SoloAnadir_CreaColumna_YFilaViejaQuedaNull`, `Guardar_SoloAnadir_NoPermiteRenombrar`, `Guardar_SoloAnadir_NoPermiteQuitar`, `Guardar_SoloAnadir_PermiteCambiarEtiquetaObligatorioOrden`, `Guardar_Fallo_NoDejaMediasTintas` (columna duplicada forzada: `cl_VarSubserie` y tabla intactas), `SqlTipoColumna_TodosLosTipos_SqlServer`. Cada una con sus asserts de estado real en la BD.
- [ ] **Step 2:** compilar pruebas. Expected: FAIL por unidad inexistente.
- [ ] **Step 3:** implementar `UVariablesDatos`. SQL Server: `StartTransaction` con DDL + filas (el DDL es transaccional). Access: hacer primero `ALTER TABLE ... ADD COLUMN` y, si falla el `INSERT/UPDATE` posterior, compensar con `ALTER TABLE ... DROP COLUMN`; nombre de tabla/columna comprobados con `NombreSeguro` antes de concatenar (no se parametrizan identificadores). `Orden` se renumera 1..n.
- [ ] **Step 4:** correr pruebas con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`. Expected: todas verdes; ademas `SELECT COUNT(*)` sobre `md_014074` sigue en 1 299 (las pruebas no tocan datos reales).
- [ ] **Step 5:** pruebas que no requieren motor (`SqlTipoColumna_Access`, `Validar_*` con `EsSqlServer=False`) en la misma unidad; las de DDL real sobre Access quedan en la lista de verificacion manual (no hay `.mdb` de pruebas).
- [ ] **Step 6:** commit `Series: datos de las variables del formulario (anadir columna con documentos)`.

### Task 3: `USeriesDatos` (series y subseries)

**Files:** Create `USeriesDatos.pas`, `Pruebas/UPruebasSeriesDatos.pas`.

**Interfaces:**
- Consumes: `TErrorCampo`, `TOpcion` (de `UArchivosDatos`).
- Produces: `TSerie {CodSerie, Serie}`; `TSubserie` con los campos editables de `cl_subseries` (codserie, codsubs, subserie, soporte, tipodoc, Activa, ayear, tgestion, tcentral, destino, archivo, deposito, gaveta, acceso, frecuencia, cargo, observacion, fechaaprov, idtiposerie); `ListarSeries(Conn): TArray<TSerieResumen>` (con numero de subseries); `ListarSubseries(Conn; const CodSerie): TArray<TSubserieResumen>` (con tipo, soporte, `NVariables`, `TieneTabla`, Activa); `LeerSubserie`; `ValidarSerie/ValidarSubserie` (`TArray<TErrorCampo>`: codigo y nombre obligatorios, codigo unico, longitudes de la tabla); `GuardarSerie/GuardarSubserie(Conn; const X; EsNueva: Boolean)`; `ContarUsoSerie`, `ContarUsoSubserie` (arbol `tb_Serietree`, documentos `tb_SeriesDatos`, `tb_transferencia`, `TB_PrestamosDocumentos`); `EliminarSerie/EliminarSubserie` (bloquea si hay uso; si no, borra sus variables y la tabla `md_*` vacia en la misma transaccion); `ListarOpciones(Conn; const Catalogo: string): TArray<TOpcion>` con lista blanca (`cl_soporte, cl_tipodoc, cl_destino, cl_frecuencia, cl_tiposerie` + los de archivo/acceso/cargo que usa `UCLSeriesDocumentales.dfm`; el implementador los lee de ahi).

- [ ] **Step 1: tests (SQL Server, series `ZZ9`/`ZZ9A`)**: `Listar_CuentaSubseries`, `ValidarSubserie_CodigoVacio`, `ValidarSubserie_CodigoDuplicado`, `Guardar_Nueva_YLeer`, `Guardar_Edicion_SoloCambiaLoModificado`, `Eliminar_ConDocumentos_Bloquea` (usar `074`: no se borra, comprobar mensaje con el conteo), `Eliminar_Libre_BorraVariablesYTablaVacia`, `ListarOpciones_CatalogoNoPermitido_Lanza`.
- [ ] **Step 2:** compilar. Expected: FAIL.
- [ ] **Step 3:** implementar siguiendo el patron de `UArchivosDatos` (guardar solo lo cambiado, transacciones, parametros).
- [ ] **Step 4:** correr suite con `SGDTEST_ALCANCE`. Expected: verde y `COUNT(*)` de `cl_series`/`cl_subseries` igual al inicial tras las pruebas.
- [ ] **Step 5:** commit `Series: datos de series y subseries`.

### Task 4: `UVariablesSesion` (reglas del editor, sin VCL ni BD)

**Files:** Create `UVariablesSesion.pas`, `Pruebas/UPruebasVariablesSesion.pas`.

**Interfaces:**
- Consumes: `TCampoMeta`, `TModoVariables`, `ValidarVariables`.
- Produces: `TSesionVariables` con `Cargar(const Lista; Modo)`, `Count`, `Campo(I)`, `Agregar: Integer` (nombre provisional `Variable<N>`), `Quitar(I)`, `Mover(De, A)`, `Modificar(I; const Nuevo: TCampoMeta)`, `PuedeQuitar(I)`, `PuedeEditarNombre(I)`, `PuedeEditarTipo(I)` (solo las nuevas en `mvSoloAnadir`; todas en `mvLibre`), `HayCambios`, `Errores: TArray<TErrorCampo>`, `Resultado: TArray<TCampoMeta>`, `Descartar`.

- [ ] **Step 1: tests**: `Libre_TodoEditable`, `SoloAnadir_ExistentesBloqueadas_NuevasLibres`, `SoloAnadir_NoPermiteQuitarExistente`, `Mover_ReordenaYMarcaCambio`, `Agregar_ProponeNombreNoRepetido`, `Descartar_VuelveAlOriginal`, `Errores_SePropaganDeValidarVariables`, `SinCambios_HayCambiosFalse`.
- [ ] **Step 2:** compilar. Expected: FAIL. **Step 3:** implementar. **Step 4:** suite verde. **Step 5:** commit `Series: sesion de edicion de variables`.

### Task 5: Editor visual de variables (`UVariablesEditor`)

**Files:** Create `UVariablesEditor.pas`, `Pruebas/UPruebasVariablesEditor.pas`.

**Interfaces:**
- Consumes: `TSesionVariables`, `ControlParaCampo`, `TTema` de `UTema`.
- Produces: `TEditorVariables(TPanel)` con `Create(AOwner; ATema)`, `Cargar(const Lista; Modo)`, `Resultado`, `HayCambios`, `Errores`, `OnCambio: TNotifyEvent`. Zonas de la maqueta pantalla 2/3: lista ordenable por arrastre (indice, nombre, "tipo . longitud", chip "Obligatoria"), propiedades de la variable elegida (nombre interno, etiqueta, tipo, longitud, obligatoria, descripcion/ayuda), vista previa del formulario que se actualiza en cada cambio y resalta el campo elegido; aviso "Estas variables ya no se pueden modificar..." solo para lo bloqueado en `mvSoloAnadir`; controles bloqueados en solo lectura.

- [ ] **Step 1: tests (VCL en consola, sin BD)**: `Cargar_PintaUnItemPorVariable`, `Preview_UnCampoPorVariable_ConEtiqueta`, `Preview_Obligatoria_MarcaAsterisco`, `Preview_CambiarEtiqueta_ActualizaEnVivo`, `SoloAnadir_ControlesDeNombreYTipoSoloLecturaEnExistentes`, `Arrastrar_Reordena_YDisparaOnCambio`.
- [ ] **Step 2:** compilar. Expected: FAIL. **Step 3:** implementar (sin `.dfm`, fuente Segoe UI, `Esc()` para escalas, controles del shell para botones). **Step 4:** suite verde + captura de la ventana (solo ArchiGenio, `PrintWindow`) para revisar contra la maqueta. **Step 5:** commit `Series: editor visual de variables con vista previa`.

### Task 6: Pantalla `UCLSeriesForm` + base

**Files:** Create `UCLSeriesForm.pas`; Modify `UClasificadorBase.pas`, `UMAINFORM.pas`, ambos `.dpr`.

**Interfaces:**
- Consumes: `USeriesDatos`, `UVariablesDatos`, `TEditorVariables`, `TFormClasificadorBase`.
- Produces: `TFormClasificadorBase` gana una zona de indice a la izquierda opcional (`FIndice: TPanel`, oculta por defecto) y `MostrarVista(AControl: TWinControl)`/`VolverALista` para alternar la tabla por una vista a pantalla completa (la de variables, con "Volver a subseries"); `TfrmCLSeriesNueva` (indice de series con contador; tabla de subseries con columnas Codigo, Subserie, Tipo de documento, Soporte, Formulario ("N variables", candado si hay tabla), Estado; panel con pestanas **Datos** y **Ubicacion y almacenamiento** y boton "Variables del formulario" que abre el editor); "Nueva serie" y "Nueva subserie"; Guardar de variables llama a `GuardarVariables` y confirma con `TMensajes`; errores de validacion bajo cada campo como en Archivos.
- `TMAIN`: el item de menu de Series y subseries abre `AbrirClasificador(TfrmCLSeriesNueva...)` con fallback a `frmCLSeries` y respeto de `clasificadores_clasico.flag`, igual que `L1Click`/`A1Click`.

- [ ] **Step 1:** pruebas de la base extendida (`Pruebas/UPruebasClasificadorEstado.pas` o nueva): `Indice_OcultoPorDefecto`, `MostrarVista_OcultaTablaYVolverLaRestaura`.
- [ ] **Step 2:** compilar. Expected: FAIL. **Step 3:** implementar base y pantalla. **Step 4:** compilar app; suite verde.
- [ ] **Step 5:** captura de la ventana (administrador, subserie `014001` con tabla y subserie `002` sin tabla): comparar con la maqueta; comprobar que con `014001` solo se puede **anadir**.
- [ ] **Step 6:** commit `Series: pantalla nueva de series y subseries dentro de la ventana principal`.

### Task 7: Documentacion y verificacion

**Files:** Create `docs/superpowers/plans/2026-11-12-verificacion-series.md`; Modify `CLAUDE.md`.

- [ ] **Step 1:** lista de verificacion manual: alta/edicion/baja de serie y subserie; variables en subserie sin tabla (libre) y con tabla (solo anadir: la columna se ve luego en la carga de un documento y en la busqueda); **repetir en Access** (no hay `.mdb` de pruebas: queda como paso manual del usuario); vista previa; arrastrar; permisos (el visor no abre el clasificador); fallback `clasificadores_clasico.flag`.
- [ ] **Step 2:** `CLAUDE.md`: reemplazar "Pending: Series y subseries..." por la descripcion de la pantalla, las reglas de variables y las unidades nuevas.
- [ ] **Step 3:** suite completa. Expected: verde. Commit `Series: documentacion y lista de verificacion`.

## Fuera de alcance (a proposito)

- Lista desplegable por variable (no hay columna; seria un cambio de esquema aparte).
- Renombrar, cambiar tipo o quitar variables con tabla de datos existente.
- Investigar los `EAccessViolation` de `TVisorContenido` al arrancar (hallazgo aparte, previo a este trabajo).
