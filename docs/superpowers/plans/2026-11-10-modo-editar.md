# Modo Editar (formulario y lotes) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Editar uno o varios documentos con un formulario deslizante en lugar de la rejilla con navegador de registros.

**Architecture:** La escritura es logica sin VCL (`UEdicionDocumento`): valida y aplica cambios (solo los campos con valor) a una o varias claves, con permisos, bitacora y una operacion por documento. La interfaz es un formulario por codigo (`UFormularioDocumento`) sobre el panel del documento, que sabe si edita uno o varios y que campos mostrar. La lista gana seleccion multiple. TMAIN conecta permisos, refresco y el borrado existente.

**Tech Stack:** Delphi 10.3 VCL, FireDAC (MSSQL y MSAcc), DUnitX, UTema.

**Spec:** `docs/superpowers/specs/2026-11-10-modo-editar-design.md`

## Global Constraints

- Compilar con `powershell -File scripts/compilar.ps1 ArchiGenioPro.dproj` y `Pruebas/PruebasArchiGenio.dproj`; exe de pruebas con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` (copia fresca de `BD/SDbd.mdb`).
- Todo SQL vale en SQL Server y Access; la logica de guardado sin VCL ni `UDM`.
- No se editan Codigo, Fecha ni Version (claves). Los UPDATE nunca las tocan.
- `UMAINFORM.pas` solo con `ed2.py` (`edit2`). Los scripts Python se escriben con `Write` a un archivo; evitar `\u`, `\U` y barras invertidas dentro de cadenas de Python.
- Unidades nuevas en ASCII y CRLF; documentacion en espanol.
- Cada cambio escribe bitacora por documento; los permisos se comprueban en la logica, no solo en la interfaz.
- Sin `shell_clasico.flag`; la rejilla antigua queda como "Vista avanzada" hasta verificar el formulario.
- Commit al cerrar cada tarea; las visuales terminan con captura del usuario.

## Review Focus

1. Edicion por lotes con un documento que falla (sin permiso, titulo demasiado largo, expediente inexistente): los demas se guardan, el fallido no cambia nada y el resumen lo dice (Task 1).
2. Un campo no rellenado no pisa el valor de los documentos marcados (Task 1, Task 3).
3. Cambiar la topografia sin `acEditarTopografia`: se omite ese campo y se avisa; no se guarda a medias (Task 1).
4. Dos usuarios editan el mismo documento: la segunda escritura no pisa en silencio los campos que el otro cambio (Task 1: comparar el valor anterior y avisar).
5. Marcar muchas filas, cambiar de serie o filtrar con filas marcadas: la seleccion no queda apuntando a documentos que ya no se ven (Task 2).

---

### Task 1: Edicion de documentos (logica y datos)

**Files:**
- Create: `UEdicionDocumento.pas` (ASCII, sin VCL ni UDM), registrar en `ArchiGenioPro.dpr`
- Create: `Pruebas/UPruebasEdicionDocumento.pas`; registrar en `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Produces: `TCambiosDoc = record` con un campo `Tiene...: Boolean` y su valor por cada uno de: `Titulo`, `Observaciones`, `Gestor` (Integer), `IdExpediente`, `SubExp`, `Visible` (Boolean), `Archivo` (Integer), `Deposito`, `Gaveta`, `IdServidor` (Integer), `Posicion`; `TResultadoEdicion = record Guardados, Fallidos, Omitidos: Integer; Mensaje: string; end`; `function ValidarCambios(const C: TCambiosDoc): string` ('' si valen: titulo no vacio y hasta 255, gaveta hasta 20, posicion hasta 10, expediente hasta 20, visible S o N); `function ActualizarDocumentos(Conn: TFDConnection; Alcance: TAlcanceUsuario; const Origen: TOrigenDocumento; const Claves: TArray<TClaveDocumento>; const Cambios: TCambiosDoc): TResultadoEdicion` (un documento a la vez en su propia transaccion; sin `acEditar` en el nodo, el documento se omite; los campos de ubicacion solo si `acEditarTopografia`, si no se omiten esos campos y el mensaje lo dice; un cambio vacio no hace nada; bitacora `ACCION_MODIFICAR` con los campos cambiados).
- Consumes: `UAlcance`, `UTrazabilidadDatos`, `UDocumentoVista.TClaveDocumento`, `UCargaDocumento.TOrigenDocumento`.

- [ ] **Step 1: Write the failing tests** (Access y SQL Server, datos F7T-*): `Valida_TituloVacioOLargo_Rechaza`; `Valida_CamposValidos_Pasa`; `Actualiza_UnDocumento_SoloLosCamposPedidos` (cambia titulo y deja observaciones intactas); `Actualiza_Lote_CambiaTodos`; `Actualiza_Lote_UnoFalla_LosDemasSeGuardan` (un documento con clave inexistente cuenta como fallido); `SinCambios_NoHaceNada`; `NoToca_LasClaves` (Codigodoc, Fecha y Version iguales tras editar); `Topografia_SinPermiso_SeOmiteYSeAvisa`; `SinPermisoDeEditar_SeOmiteElDocumento`; `Bitacora_RegistraElCambio`.
- [ ] **Step 2: Run** `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`. Expected: no compila.
- [ ] **Step 3: Implement** `ValidarCambios` y `ActualizarDocumentos` (UPDATE con solo las columnas pedidas y parametros; claves en el WHERE).
- [ ] **Step 4: Run** compilar + exe con las variables de entorno. Expected: 0 fallos en ambos motores.
- [ ] **Step 5: Commit.**

### Task 2: Seleccion multiple en la lista

**Files:**
- Modify: `UPanelDocumentos.pas`
- Test: `Pruebas/UPruebasPanelDocumentos.pas`

**Interfaces:**
- Produces: `TPanelDocumentos.ClavesSeleccionadas: TArray<TClaveDocumento>`; `property OnSeleccionMultiple: TNotifyEvent` (se dispara al cambiar el numero de marcados); con mas de un marcado el panel del documento muestra "N documentos seleccionados" en la cabecera y las pestanas quedan sin datos de uno solo; `procedure LimpiarSeleccion` (se llama al cambiar de serie, filtrar o recargar).
- Consumes: `TListView.MultiSelect` (lista virtual con `OwnerData`).

- [ ] **Step 1: Write the failing tests**: `Seleccion_Varios_DevuelveSusClaves`; `Seleccion_Uno_SigueMostrandoSusDatos`; `Seleccion_Varios_LaCabeceraDiceCuantos`; `Filtrar_LimpiaLaSeleccion`; `Recargar_ConservaLosMarcadosQueSiguenVisibles`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** `MultiSelect := True` y la logica de claves y cabecera.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos.
- [ ] **Step 5: Commit.**

### Task 3: Formulario deslizante

**Files:**
- Create: `UFormularioDocumento.pas` (ASCII), registrar en `ArchiGenioPro.dpr`
- Create: `Pruebas/UPruebasFormularioDocumento.pas`; registrar en `Pruebas/PruebasArchiGenio.dpr`
- Modify: `UPanelDocumentos.pas`

**Interfaces:**
- Produces: `TFormularioDocumento = class(TPanel)` creado por codigo; `procedure Abrir(const Claves: TArray<TClaveDocumento>; const Actuales: TCambiosDoc; PuedeTopografia: Boolean)`; `function Cambios: TCambiosDoc` (solo lo que el usuario relleno; en un solo documento, lo que difiere del valor actual); `procedure MostrarError(const Campo, Texto: string)` (mensaje bajo el campo); `property OnGuardar, OnCancelar: TNotifyEvent`; con varias claves los campos dicen "(sin cambios)" y hay un boton "Vaciar" por campo; "Aplicar a N" en el boton principal; la ubicacion queda deshabilitada si `PuedeTopografia = False`.
- Produces (UPanelDocumentos): `Editar(const Claves: TArray<TClaveDocumento>)` que desliza el formulario sobre el panel y `property OnGuardarEdicion: TGuardarEdicionEvent` (`procedure(const Claves: TArray<TClaveDocumento>; const Cambios: TCambiosDoc; out Error: string) of object`).
- Consumes: `TCambiosDoc`, `ValidarCambios` (Task 1).

- [ ] **Step 1: Write the failing tests** (VCL): `Abrir_UnDocumento_MuestraSusValores`; `Abrir_VariosDocumentos_DiceSinCambios`; `Cambios_NoRellenados_NoSalen`; `Cambios_UnSoloDocumento_SoloLoQueDifiere`; `Guardar_ConTituloVacio_MuestraElErrorBajoElCampoYNoDispara`; `Abrir_SinPermisoDeTopografia_DeshabilitaLaUbicacion`; `Vaciar_PoneElCampoVacioExplicito`; `ClavesYClavesNoSeEditan` (no hay controles para Codigo, Fecha ni Version).
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** el formulario con secciones Datos, Ubicacion y (en un solo documento) Metadatos.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos.
- [ ] **Step 5: Verificacion del usuario**: captura del formulario con un documento y con dos marcados.
- [ ] **Step 6: Commit.**

### Task 4: Conexion en TMAIN y metadatos

**Files:**
- Modify: `UMAINFORM.pas`, `UBarraTrabajo.pas`

**Interfaces:**
- Consumes: `ActualizarDocumentos` (Task 1), `Editar` y `OnGuardarEdicion` (Task 3), `ClavesSeleccionadas` (Task 2), `ListaDocsPuedeEditar` y la regla de topografia de `ShellAgregarDocumento`.
- Produces: el boton "Editar" de la barra abre el formulario con las claves marcadas (o el documento actual); "Vista avanzada" (menu) abre la rejilla antigua; `TMAIN.ListaDocsGuardarEdicion` (arma el `Origen`, llama a `ActualizarDocumentos`, muestra el resumen "Se guardaron N; M no se pudieron guardar" y recarga la lista con `ListaDocsCargar`); en un solo documento se guardan tambien los metadatos con `GuardarMetadatos` de `UMetadatosSubserie` (en la misma operacion).

- [ ] **Step 1: Write the failing test**: `Barra_Editar_DisparaOnEditarConLasClaves` (en `UPruebasBarraTrabajo.pas`); la logica de guardado ya esta probada en Task 1.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** la conexion, "Vista avanzada" y el resumen.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos.
- [ ] **Step 5: Verificacion del usuario**: editar un documento, editar dos, un campo invalido, un documento sin permiso. Captura.
- [ ] **Step 6: Commit.**

### Task 5: Eliminar y arrastrar archivos desde el formulario

**Files:**
- Modify: `UFormularioDocumento.pas`, `UMAINFORM.pas`

**Interfaces:**
- Produces: boton "Eliminar..." del formulario de un solo documento (con confirmacion; llama al mismo borrado de `tb_SeriesDatos` de hoy, con su permiso por rol y por dias y el borrado de los ficheros del almacen); zona "Arrastre aqui PDF o anexos" que, con varios marcados, agrega los archivos a todos con `AgregarFicheros` de `UAgregarFicheros` (un documento a la vez, con resumen).
- Consumes: `UAgregarFicheros`, `ListaDocsSoltarFicheros` (reutiliza su confirmacion y progreso).

- [ ] **Step 1: Write the failing tests**: `Formulario_Eliminar_SoloConUnDocumento` (con varios no hay boton); `Formulario_Soltar_DisparaElEventoConLasClaves`.
- [ ] **Step 2: Run.** Expected: FAIL.
- [ ] **Step 3: Implement** el boton y la zona; el borrado reutiliza `tb_SeriesDatos.Delete` tras localizar el documento.
- [ ] **Step 4: Run** pruebas y compilar. Expected: 0 fallos.
- [ ] **Step 5: Verificacion del usuario**: eliminar un documento de prueba; arrastrar archivos con dos marcados. Captura.
- [ ] **Step 6: Commit.**

### Task 6: Verificacion, estado y revision final

**Files:**
- Modify: `docs/superpowers/plans/2026-11-10-verificacion-espacio-de-trabajo.md`, estado del diseno

- [ ] **Step 1:** Anadir casos: editar un documento (cada campo), editar dos con "sin cambios", vaciar un campo, titulo invalido, expediente inexistente, sin permiso de editar, sin permiso de topografia, eliminar, arrastrar archivos con varios marcados, "Vista avanzada".
- [ ] **Step 2:** Suite completa (Access y SQL Server) y anotar el total.
- [ ] **Step 3:** Revision final con un revisor independiente sobre `git diff` desde el inicio del plan y una pasada de correcciones con pruebas.
- [ ] **Step 4: Commit.**

## Fuera de este plan

Cambiar claves (codigo, fecha, version) y versionar documentos; el modulo de recuperacion (`ArchiRec.exe`); retirar del todo la rejilla antigua (despues de verificar el formulario).
