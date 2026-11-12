# Clasificador de Archivos (pantalla nueva) — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reemplazar la pantalla de Archivos (`UMangementArch`) por una pantalla nueva con el patrón de los clasificadores (tabla limpia + panel lateral), embebida en la ventana principal, con miniaturas del croquis y la foto y la descripción con formato conservada.

**Architecture:** Datos y reglas en `UArchivosDatos` (sin VCL ni `TUDM`, con pruebas). Manejo de imágenes en `UImagenes` (VCL sin `TUDM`, con pruebas). La pantalla `UCLArchivosForm` hereda de `TFormClasificadorBase`. `TMAIN.A1Click` la abre embebida con el mismo respaldo a la pantalla clásica que Servidores.

**Tech Stack:** Delphi 10.3 VCL, DevExpress `cxGrid` (vía la base), FireDAC (SQL Server y Access), DUnitX, `UTema`.

**Spec:** `docs/superpowers/specs/2026-11-12-clasificadores-design.md` (punto 3, "Archivos"). Patrón y lecciones: `docs/superpowers/plans/2026-11-12-clasificadores-base-y-servidores.md` y su implementación (`UClasificadorBase`, `UCLServidoresForm`, `TMAIN.AbrirClasificador`). Maqueta de referencia del panel: `.superpowers/brainstorm/918-1794481622/content/tabla-con-panel-s3.html`.

## Datos reales de la pantalla actual

- Tabla `cl_ArchivosGestion`: `Cod` smallint (clave primaria, **no** es identidad: se asigna `MAX+1`), `nombreArchivo` varchar(100), `Tipo` int → `cl_tipoarch(Idtipoarch, tipoarch)` ("Central", "Gestión"), `Idresp` int → `cl_Resp_Gest_Arch(Idresp, NombreResponsable)`, `croquis` y `Foto` image (JPEG guardado en bruto), `Descripcion` text (**contiene RTF**: `{\rtf1\ansi...`; los informes FastReport lo leen).
- Uso (para proteger la baja): `cl_subseries.archivo`, `tb_SeriesDatos.Archivo`, `tb_Serietree.Archivo`, `TB_PrestamosDocumentos.Archivo` (todos smallint = `Cod`).
- Hoy el croquis y la foto se ven con un visor externo (`UDM.ViewIMG`) y se cargan con el diálogo `ManagementPDF`; la descripción se edita con un editor de texto enriquecido (`CampoTexto`).

## Global Constraints

- Delphi 10.3 VCL + DevExpress; FireDAC; SQL válido en **SQL Server y Access** (parámetros; `IIf(expr, 1, 0)` en lugar de `CASE`; `LEFT(col, :n)` en lugar de `LIKE`).
- Pantalla por código (sin `.dfm`), paleta de `TemaLegacyActual`, fuente `Segoe UI`, tamaños con `Esc(...)`; hereda de `TFormClasificadorBase` y se acopla con `Embeber`.
- Lógica sin VCL ni `TUDM`, con pruebas DUnitX; toda unidad nueva en `ArchiGenioPro.dpr` y sus pruebas en `Pruebas/PruebasArchiGenio.dpr`.
- Unidades en ASCII con `#NNN` para tildes; archivos existentes ANSI/CRLF (no reescribirlos por UTF-8).
- Mensajes por `UMensajes` (`TMensajes`); nunca `MessageBox`/`MessageDlg`/`ShowMessage`.
- Comentarios y documentación en español.
- No cambian las tablas ni lo guardado: **guardar solo escribe lo que el usuario cambió** (las imágenes y la descripción no se tocan si no se editaron).
- La pantalla clásica `UMangementArch` no se borra; `clasificadores_clasico.flag`, el respaldo por fallo y `clasificadores_error.log` se comportan como en Servidores.
- Pruebas contra `SGDTEST_ALCANCE` (`ARCHIGENIO_TEST_DB`), sin dejar filas; nunca contra `SGDDRHMAIN`. Filas de prueba: `nombreArchivo LIKE 'zz_arch%'` y `Cod >= 9000`.
- Compilar con `scripts/compilar.ps1` (aplicación y `Pruebas/PruebasArchiGenio.dproj`); `Pruebas\Win32\Debug\PruebasArchiGenio.exe` debe salir con código 0. No incluir `Win32/Debug/*.dcu`, `ArchiGenioPro.identcache` ni `ArchiGenioPro.res` en los commits.
- Una prueba de píxeles de otra pantalla (`UPruebasPanelDocumentos.Propiedades_MensajeReemplazaTodo`) puede fallar de forma aislada según lo que haya sobre la pantalla; se reintenta, no se toca.

## Review Focus

1. Editar solo el nombre de un archivo que ya tiene croquis, foto y descripción: después de guardar **siguen intactos** los tres (no se sobrescriben con nulos).
2. Abrir y guardar sin tocar la descripción con RTF existente: el contenido y su formato no se pierden ni se convierten a texto plano.
3. Eliminar un archivo en uso (subseries, documentos, nodos, préstamos): se bloquea con el número de usos y no borra nada.
4. Imagen inválida (un texto renombrado a .jpg) o enorme: mensaje claro y no se guarda nada; una imagen grande se reduce antes de guardarse.
5. Elegir otra fila o salir con cambios pendientes, incluida una imagen nueva aún sin guardar: pregunta; nunca guarda ni descarta en silencio.
6. Nombre vacío o sin tipo: mensaje bajo el campo, sin excepción y sin guardado parcial.

---

## Estructura de archivos

- Create `UArchivosDatos.pas` — lectura, validación, alta/edición, baja protegida, descripción e imágenes. (sin VCL)
- Create `UImagenes.pas` — preparar una imagen para guardarla y mostrar una miniatura. (VCL, sin `TUDM`)
- Create `UCLArchivosForm.pas` — pantalla nueva + `CrearClasificadorArchivos`.
- Create `Pruebas/UPruebasArchivosDatos.pas`, `Pruebas/UPruebasImagenes.pas`.
- Modify `UMAINFORM.pas` (`procedure TMAIN.A1Click`), `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`, `CLAUDE.md`.
- Create `docs/superpowers/plans/2026-11-12-verificacion-clasificador-archivos.md`.

---

### Task 1: Datos de archivos — lectura y validación

**Files:**
- Create: `UArchivosDatos.pas`
- Create/Test: `Pruebas/UPruebasArchivosDatos.pas`
- Modify: `Pruebas/PruebasArchiGenio.dpr`, `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: `UServidoresDatos.TErrorCampo` (`Campo`, `Mensaje`); se reutiliza para no duplicar el tipo (deuda anotada: en el plan de Series se moverá a una unidad compartida).
- Produces:

```pascal
type
  TOpcion = record Id: Integer; Texto: string; end;
  TArchivo = record
    Cod: Integer;           // 0 = nuevo
    Nombre: string;         // nombreArchivo (max 100)
    Tipo: Integer;          // Idtipoarch; 0 = sin elegir
    Idresp: Integer;        // 0 = sin responsable
    TieneCroquis, TieneFoto: Boolean;   // solo informativos al leer
  end;
  EArchivoInvalido = class(Exception);
  EArchivoEnUso = class(Exception)
    Usos: Integer;
  end;

function ListarArchivos(Conn: TFDConnection): TArray<TArchivo>;          // ordenados por Cod; sin leer los blobs
function ListarTiposArchivo(Conn: TFDConnection): TArray<TOpcion>;      // cl_tipoarch
function ListarResponsables(Conn: TFDConnection): TArray<TOpcion>;      // cl_Resp_Gest_Arch (Idresp, NombreResponsable), por nombre
function ValidarArchivo(const A: TArchivo): TArray<TErrorCampo>;
```

  Reglas de `ValidarArchivo` (un error por campo): `nombre` obligatorio y <= 100; `tipo` obligatorio (> 0). El responsable es opcional. `TieneCroquis`/`TieneFoto` se calculan con `IIf(croquis IS NULL, 0, 1)`, sin traer los blobs.

- [ ] **Step 1: Escribir las pruebas** — `TPruebasValidarArchivo` (puras): `Valido_Completo_SinErrores`, `Nombre_Vacio_Error`, `Nombre_De101_Error`, `SinTipo_Error`, `SinResponsable_Valido`, `Dos_Errores_Dos_Campos`. `TPruebasListarArchivos` (BD, omiten sin `ARCHIGENIO_TEST_DB`; mismo fixture que `UPruebasServidoresDatos`): `Listar_IncluyeLosExistentes` (Cod 1..4 presentes, `Nombre = 'Administración'` para Cod 1), `Listar_MarcaCroquisYFoto` (con un archivo de prueba al que se le pone un blob de 3 bytes en `croquis`, `TieneCroquis = True` y `TieneFoto = False`), `Tipos_IncluyeCentralYGestion`, `Responsables_NoVacio`.
- [ ] **Step 2: Agregar a los `.dpr` de pruebas; compilar.** Expected: FAIL (`F1026 File not found: '..\UArchivosDatos.pas'`).
- [ ] **Step 3: Implementar** las firmas de arriba en `UArchivosDatos.pas` (ASCII; mensajes con `#NNN`).
- [ ] **Step 4: Compilar y ejecutar** con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`. Expected: todas PASS; sin filas `zz_arch%` ni `Cod >= 9000` restantes.
- [ ] **Step 5: Agregar a `ArchiGenioPro.dpr` y commit** ("Archivos: lectura y validacion").

---

### Task 2: Datos de archivos — guardar, descripción, imágenes y baja protegida

**Files:**
- Modify: `UArchivosDatos.pas`, `Pruebas/UPruebasArchivosDatos.pas`

**Interfaces:**
- Consumes: Task 1.
- Produces:

```pascal
type TCampoImagen = (ciCroquis, ciFoto);

{ Alta (Cod = 0: MAX+1) o edicion de nombreArchivo, Tipo e Idresp (Idresp 0 = NULL).
  NO toca croquis, Foto ni Descripcion. Valida primero (EArchivoInvalido; no escribe). Devuelve Cod. }
function GuardarArchivo(Conn: TFDConnection; const A: TArchivo): Integer;
{ Descripcion tal como esta guardada (RTF o texto); '' si es NULL. }
function LeerDescripcion(Conn: TFDConnection; ACod: Integer): string;
procedure GuardarDescripcion(Conn: TFDConnection; ACod: Integer; const ATexto: string);   // '' guarda NULL
function LeerImagen(Conn: TFDConnection; ACod: Integer; ACampo: TCampoImagen): TBytes;   // vacio si no hay
procedure GuardarImagen(Conn: TFDConnection; ACod: Integer; ACampo: TCampoImagen; const ABytes: TBytes);
procedure QuitarImagen(Conn: TFDConnection; ACod: Integer; ACampo: TCampoImagen);        // deja NULL
{ cl_subseries.archivo + tb_SeriesDatos.Archivo + tb_Serietree.Archivo + TB_PrestamosDocumentos.Archivo }
function ContarUsoArchivo(Conn: TFDConnection; ACod: Integer): Integer;
procedure EliminarArchivo(Conn: TFDConnection; ACod: Integer);   // EArchivoEnUso (con Usos) y no borra si Usos > 0
```

- [ ] **Step 1: Escribir las pruebas de datos** (fixture: filas con `nombreArchivo LIKE 'zz_arch%'`, borradas en `TearDown`; usar transacción + `Rollback` para los casos de uso): `Guardar_Nuevo_AsignaCodYSePuedeLeer`; `Guardar_Editar_CambiaNombreTipoYResp`; `Guardar_Editar_NoTocaImagenesNiDescripcion` (Review Focus 1: poner croquis `[1,2,3]`, foto `[4,5]`, descripción `'{\rtf1 hola}'`; editar el nombre; las tres lecturas devuelven lo mismo); `Guardar_SinResponsable_GuardaNull`; `Guardar_Invalido_LanzaYNoEscribe` (Review Focus 6); `Descripcion_RoundTrip` (RTF con `\'e1`); `Descripcion_Vacia_GuardaNull`; `Imagen_RoundTrip` (bytes 0..255 y largo 100000); `Imagen_Quitar_DejaVacio`; `Eliminar_SinUso_Borra`; `Eliminar_EnUsoPorSubserie_Bloquea` (en transacción: `UPDATE cl_subseries SET archivo = :c` con el Cod de prueba; `EArchivoEnUso.Usos >= 1`; la fila sigue; Review Focus 3); `Eliminar_EnUsoPorSerieTree_Bloquea`.
- [ ] **Step 2: Compilar pruebas.** Expected: FAIL (identificadores sin definir).
- [ ] **Step 3: Implementar** las funciones. Los blobs se escriben con `TFDQuery` y parámetro `ftBlob` (`Params[0].AsBlob`/`SetBlobRawData`), nunca con `ExecSQL` y texto; `GuardarArchivo` en transacción; `Cod` con `SELECT MAX(Cod)`.
- [ ] **Step 4: Compilar y ejecutar la suite completa.** Expected: todas PASS; sin filas sobrantes.
- [ ] **Step 5: Commit** ("Archivos: guardar, imagenes, descripcion y baja protegida").

---

### Task 3: Imágenes — preparar y mostrar miniatura

**Files:**
- Create: `UImagenes.pas`
- Create/Test: `Pruebas/UPruebasImagenes.pas`
- Modify: `Pruebas/PruebasArchiGenio.dpr`, `ArchiGenioPro.dpr`

**Interfaces:**
- Produces:

```pascal
const LADO_MAXIMO_IMAGEN = 1600;
type EImagenInvalida = class(Exception);
{ Lee JPG, PNG o BMP de ARuta, reduce para que ningun lado pase de AMaxLado
  (conservando la proporcion; nunca agranda) y devuelve JPEG calidad 85.
  EImagenInvalida si el fichero no existe o no es una imagen. }
function PrepararImagen(const ARuta: string; AMaxLado: Integer = LADO_MAXIMO_IMAGEN): TBytes;
{ Muestra ABytes (JPEG, PNG o BMP, detectados por su cabecera) en AImagen
  (Proportional, Center). False si esta vacio o no es una imagen; nunca lanza. }
function CargarMiniatura(const ABytes: TBytes; AImagen: TImage): Boolean;
```

- [ ] **Step 1: Escribir las pruebas** (`TPruebasImagenes`, ficheros temporales en `TPath.GetTempPath`): `Preparar_PngGrande_SeReduceA1600` (PNG 2000x1000 → el resultado se carga como JPEG con ancho 1600 y alto 800); `Preparar_Pequena_NoSeAgranda` (JPEG 100x50 queda 100x50); `Preparar_NoEsImagen_Lanza` (un `.txt` renombrado a `.jpg` → `EImagenInvalida`; Review Focus 4); `Preparar_NoExiste_Lanza`; `Miniatura_Jpeg_True`; `Miniatura_Png_True`; `Miniatura_Basura_FalseSinLanzar`; `Miniatura_Vacia_False`.
- [ ] **Step 2: Agregar a los `.dpr` de pruebas; compilar.** Expected: FAIL (unidad no encontrada).
- [ ] **Step 3: Implementar** `UImagenes.pas` (ASCII) con `Vcl.Imaging.jpeg`, `Vcl.Imaging.pngimage`, `Vcl.Graphics`; reducir con `StretchDraw` sobre un `TBitmap` pf24bit; detectar el formato por los primeros bytes (`FF D8`, `89 50 4E 47`, `42 4D`).
- [ ] **Step 4: Compilar y ejecutar.** Expected: PASS.
- [ ] **Step 5: Agregar a `ArchiGenioPro.dpr` y commit** ("Imagenes: preparar y miniatura").

---

### Task 4: Pantalla de Archivos

**Files:**
- Create: `UCLArchivosForm.pas`
- Modify: `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: Tasks 1-3, `TFormClasificadorBase` (`AgregarColumna`, `AgregarFila`, `RefrescarVista`, `SeleccionarPorTag`, `AbrirPanel`, `CerrarPanel`, `FijarBotones`, `FEstado`, `FCuerpo`, `Esc`, `AlNuevo/AlElegirFila/AlGuardar/AlEliminar`), `UMensajes`.
- Produces:

```pascal
{ Crea la pantalla de Archivos sin mostrarla; TMAIN la acopla con AbrirClasificador. }
function CrearClasificadorArchivos(Conn: TFDConnection): TFormClasificadorBase;
```

- [ ] **Step 1: Implementar `TfrmArchivos`** (por código): columnas Código (80), Nombre (260), Tipo (140), Responsable (220), Croquis y Foto ("Sí" / "—", 90 c/u); subtítulo "N archivos". Panel ("Nuevo archivo" / el nombre): Nombre; Tipo (combo de lista, opciones de `ListarTiposArchivo`); Responsable (combo con "(sin responsable)" + `ListarResponsables`); bloques **Croquis** y **Foto** (miniatura 160x110 con `CargarMiniatura`, botones "Cambiar…" (`TOpenDialog` con filtro JPG/PNG/BMP → `PrepararImagen`), "Ver" (escribe la imagen en un archivo temporal de la carpeta temporal de Windows, `TPath.GetTempPath`, y lo abre con `ShellExecute` "open"; sin depender de `UDM`) y "Quitar"); **Descripción** con `TRichEdit` (`PlainText = False`, barra vertical) que carga el RTF guardado con `LoadFromStream` y lo guarda con `SaveToStream` **solo si el usuario la modificó**. Las imágenes se leen (`LeerImagen`) solo al elegir la fila. Los cambios de imagen quedan pendientes (`FCroquisNuevo`, `FCroquisQuitar`, ídem foto) hasta "Guardar", que llama a `GuardarArchivo` y luego, solo para lo pendiente, `GuardarImagen`/`QuitarImagen`/`GuardarDescripcion`. Reparto de campos con `Distribuir` por ancho real (como `TfrmServidores`). Errores de `ValidarArchivo` bajo cada campo. Eliminar: `TMensajes.Confirmar`, `EliminarArchivo`, `EArchivoEnUso` → `TMensajes.Advertencia` con los usos. Imagen inválida → `TMensajes.Advertencia` con el motivo (Review Focus 4). Cambios pendientes de imagen o descripción cuentan para `FEstado.MarcarCambio` (Review Focus 5). Nombre del archivo en una fila nueva con `Tipo` vacío selecciona el primero de la lista como sugerencia, sin marcar cambio.
- [ ] **Step 2: Agregar a `ArchiGenioPro.dpr`; compilar** `scripts/compilar.ps1 ArchiGenioPro.dproj`. Expected: sin errores.
- [ ] **Step 3: Commit** ("Archivos: pantalla nueva").

---

### Task 5: Conexión con el menú, respaldo y documentación

**Files:**
- Modify: `UMAINFORM.pas` (`procedure TMAIN.A1Click`), `CLAUDE.md`
- Create: `docs/superpowers/plans/2026-11-12-verificacion-clasificador-archivos.md`

**Interfaces:**
- Consumes: Task 4 (`CrearClasificadorArchivos`), `TMAIN.AbrirClasificador`, `ClasificadoresClasicos`, `RegistrarErrorClasificador`.

- [ ] **Step 1: Extraer el cuerpo actual de `A1Click` a `procedure TMAIN.AbrirArchivosClasico`** (privado; sin cambiar su comportamiento: `PContainer`, log, `TfrmManagemetArch`, refresco de `UDM.cl_ArchivosGestion`).
- [ ] **Step 2: Reescribir `A1Click`** como `L1Click`: si `ClasificadoresClasicos(PathSys) or not ShellActivo` → `AbrirArchivosClasico`; si no, `AbrirClasificador(CrearClasificadorArchivos(UDM.Conn), 'Archivos', 'Archivos', procedure begin UDM.cl_ArchivosGestion.Refresh; end)` dentro de `try/except` que registra con `RegistrarErrorClasificador(PathSys, 'Archivos: ' + ...)` y abre la clásica.
- [ ] **Step 3: Compilar la aplicación y la suite.** Expected: sin errores; todas las pruebas PASS.
- [ ] **Step 4: Verificación visual con capturas** (gancho temporal por variable de entorno en el `.dpr`, **sin confirmarlo**: `MAIN.A1Click(nil)` tras 2,5 s): lista con las 4 filas existentes, panel de una fila con miniaturas/descripción, alta de un archivo de prueba, guardado, edición solo del nombre (Review Focus 1 comprobado en la BD con `DATALENGTH`), y borrar la fila de prueba. Ajustar `UCLArchivosForm.pas` hasta que se vea como Servidores.
- [ ] **Step 5: Escribir la lista de verificación** `2026-11-12-verificacion-clasificador-archivos.md` (los seis puntos de Review Focus + pantalla embebida, tema claro/oscuro, croquis y foto reales, descripción con formato, `.flag`, fallo simulado), **actualizar `CLAUDE.md`** y **commit** ("Clasificadores: Archivos usa la pantalla nueva dentro de la ventana principal").
