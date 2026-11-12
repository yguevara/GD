# Clasificadores — piezas comunes y Servidores FTP/S3 — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Entregar el patrón nuevo de clasificador (cabecera, tabla limpia, panel lateral de edición) y, con él, la pantalla nueva de Servidores FTP/S3 con alta guiada de MinIO, con interruptor para volver a la pantalla vieja.

**Architecture:** Lógica en unidades sin VCL ni `TUDM` con pruebas DUnitX (`UClasificadoresInterruptor`, `UClasificadorEstado`, `UServidoresDatos`). Una clase base VCL por código (`UClasificadorBase`, sin `.dfm`) con una `cxGridTableView` sin enlace a datos (se llena desde arreglos) y un panel lateral. `UCLServidoresForm` hereda de la base y usa `UServidoresDatos`. `TMAIN.L1Click` abre la pantalla nueva y cae a la vieja si hay `.flag` o si falla.

**Tech Stack:** Delphi 10.3 VCL, DevExpress `cxGrid`, FireDAC (SQL Server y Access), DUnitX, `UTema`/`UAparienciaLegacy` (paleta).

**Spec:** `docs/superpowers/specs/2026-11-12-clasificadores-design.md`. Este plan cubre los puntos 1 y 2 del "Orden de construcción" del diseño. **Archivos** y **Series y subseries** tendrán cada uno su propio plan, que se escribe cuando este esté validado (reutilizan la base y sus lecciones). Las maquetas aprobadas están en `.superpowers/brainstorm/918-1794481622/content/` (`tabla-con-panel-s3.html` es la referencia visual de esta pantalla).

## Global Constraints

- Delphi 10.3 VCL + DevExpress (`cxGrid` se mantiene); FireDAC; todo SQL válido en **SQL Server y Access** (usar parámetros; para "empieza por" usar `LEFT(col, :n) = :p`, no `LIKE`).
- Pantallas nuevas **por código** (sin `.dfm`), colores de `TemaLegacyActual`/`TemaClaro`/`TemaOscuro` (claro y oscuro), fuente `Segoe UI`, tamaños con escala (ver `Esc(...)` en `UShellPrincipal.pas`).
- Lógica y reglas en unidades **sin VCL ni `TUDM`**; pruebas DUnitX en `Pruebas/` (se agregan a `Pruebas/PruebasArchiGenio.dpr`; toda unidad nueva también a `ArchiGenioPro.dpr`).
- Unidades sin pantalla en **ASCII** (tildes de la interfaz con `#NNN`); archivos existentes en ANSI/CRLF: no reescribirlos pasando por UTF-8. Las pantallas nuevas también en ASCII con `#NNN` para las tildes (como `UAutentica.pas`).
- Mensajes al usuario siempre por `UMensajes` (`TMensajes.Informacion/Advertencia/Error/Exito/Confirmar`); nada de `MessageBox`, `MessageDlg` ni `ShowMessage`.
- Comentarios y documentación en español; cada rutina pública con su propósito.
- No se cambian tablas ni datos guardados. Las pantallas viejas (`UCLFtpServer`) **no se borran**.
- Permisos y registro de acceso (log tipos 14 y 15) de `L1Click` se conservan.
- Pruebas contra `SGDTEST_ALCANCE` (variable `ARCHIGENIO_TEST_DB`), sin dejar filas; nunca contra `SGDDRHMAIN`.
- Compilar: `scripts/compilar.ps1 ArchiGenioPro.dproj` y `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`; ejecutar `Pruebas\Win32\Debug\PruebasArchiGenio.exe` (código de salida 0). No incluir `Win32/Debug/*.dcu` ni `ArchiGenioPro.identcache` en los commits.

## Review Focus

1. Editar un servidor S3 **sin volver a escribir la clave secreta**: se conserva la guardada, tanto al guardar como al "Probar conexión".
2. Eliminar un servidor **en uso** (documentos o ficheros S3 que lo referencian): se bloquea con el número de usos y no borra nada.
3. Cerrar o cancelar con **cambios sin guardar**: pregunta; nunca guarda ni descarta en silencio.
4. Datos incompletos o inválidos (puerto vacío o no numérico, etiqueta vacía, bucket vacío): un mensaje por campo, sin excepción y sin guardado parcial.
5. La pantalla nueva **falla al abrirse**: se abre la vieja y el motivo queda en `clasificadores_error.log`; con `clasificadores_clasico.flag` se abre la vieja directamente.
6. "Probar conexión" con la red caída o el servidor inexistente: mensaje claro, sin congelar la ventana.

---

## Estructura de archivos

- Create `UClasificadoresInterruptor.pas` — decide pantalla nueva o clásica; registra errores. (sin VCL)
- Create `UClasificadorEstado.pas` — máquina de estados de la ficha (navegando/editando/nuevo, cambios). (sin VCL)
- Create `UServidoresDatos.pas` — lectura, validación, alta/edición, baja protegida y prueba de conexión de servidores. (sin VCL, FireDAC + Indy)
- Create `UClasificadorBase.pas` — formulario base por código: cabecera, tabla `cxGrid`, panel lateral, barra de acciones. (VCL + DevExpress)
- Create `UCLServidoresForm.pas` — pantalla de Servidores FTP/S3 + `MostrarClasificadorServidores`. (VCL; usa `UCapaDatos`)
- Create `Pruebas/UPruebasClasificadoresInterruptor.pas`, `Pruebas/UPruebasClasificadorEstado.pas`, `Pruebas/UPruebasServidoresDatos.pas`.
- Modify `UMAINFORM.pas` (`procedure TMAIN.L1Click`; buscarla por nombre) — elegir pantalla.
- Modify `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`, `CLAUDE.md`.
- Create `docs/superpowers/plans/2026-11-12-verificacion-clasificadores-servidores.md` — lista de verificación manual.

---

### Task 1: Interruptor y registro de errores

**Files:**
- Create: `UClasificadoresInterruptor.pas`
- Create/Test: `Pruebas/UPruebasClasificadoresInterruptor.pas`
- Modify: `Pruebas/PruebasArchiGenio.dpr`, `ArchiGenioPro.dpr`

**Interfaces:**
- Produces:

```pascal
const
  ARCHIVO_CLASIFICADORES_CLASICO = 'clasificadores_clasico.flag';
  ARCHIVO_ERRORES_CLASIFICADORES = 'clasificadores_error.log';
{ True si existe el .flag en ACarpeta (se usan las pantallas viejas). }
function ClasificadoresClasicos(const ACarpeta: string): Boolean;
{ Agrega "fecha hora texto" a clasificadores_error.log en ACarpeta; nunca lanza. }
procedure RegistrarErrorClasificador(const ACarpeta, ATexto: string);
```

- [ ] **Step 1: Escribir las pruebas** (`TPruebasInterruptor`, carpeta temporal `TPath.GetTempPath + 'pr_clasif'` creada y borrada en `Setup/TearDown`): `Clasicos_SinFlag_False`; `Clasicos_ConFlag_True`; `Registrar_CreaArchivoConLaLinea` (el archivo contiene el texto); `Registrar_AgregaSinBorrar` (dos llamadas, dos líneas); `Registrar_CarpetaInexistente_NoLanza` (carpeta `Z:\no_existe\x`, `Assert.Pass`).
- [ ] **Step 2: Agregar** `UClasificadoresInterruptor in '..\UClasificadoresInterruptor.pas'` y la unidad de pruebas a `Pruebas/PruebasArchiGenio.dpr`; compilar pruebas. Expected: FAIL (`F1026 File not found: '..\UClasificadoresInterruptor.pas'`).
- [ ] **Step 3: Implementar** `UClasificadoresInterruptor.pas` (ASCII, solo RTL) con las firmas de arriba; `RegistrarErrorClasificador` con `TFile.AppendAllText` dentro de `try/except` vacío.
- [ ] **Step 4: Compilar y ejecutar pruebas.** Expected: todas PASS, 0 fallos.
- [ ] **Step 5: Agregar la unidad a `ArchiGenioPro.dpr` y commit** (`git add UClasificadoresInterruptor.pas Pruebas/UPruebasClasificadoresInterruptor.pas Pruebas/PruebasArchiGenio.dpr ArchiGenioPro.dpr`; mensaje: "Clasificadores: interruptor clasico y registro de errores").

---

### Task 2: Estado de la ficha de edición

**Files:**
- Create: `UClasificadorEstado.pas`
- Create/Test: `Pruebas/UPruebasClasificadorEstado.pas`
- Modify: `Pruebas/PruebasArchiGenio.dpr`, `ArchiGenioPro.dpr`

**Interfaces:**
- Produces:

```pascal
type
  TModoFicha = (mfNavegando, mfEditando, mfNuevo);
  TEstadoFicha = class
  public
    function Modo: TModoFicha;
    function HayCambios: Boolean;
    procedure Elegir;            // navegando, sin cambios
    procedure Nuevo;             // mfNuevo, sin cambios aun
    procedure MarcarCambio;      // HayCambios; si navegaba pasa a mfEditando
    function PuedeGuardar: Boolean;       // (editando o nuevo) y con cambios
    function RequiereConfirmarAbandono: Boolean; // hay cambios sin guardar
    procedure Guardado;          // navegando, sin cambios
    procedure Descartado;        // navegando, sin cambios
  end;
```

- [ ] **Step 1: Escribir las pruebas** (`TPruebasEstadoFicha`): estado inicial `mfNavegando`/sin cambios; `Nuevo_SinCambios_NoPuedeGuardar`; `Nuevo_ConCambio_PuedeGuardar`; `MarcarCambio_DesdeNavegando_PasaAEditando`; `Elegir_DespuesDeCambio_LimpiaCambios` (no pregunta aquí: la pantalla debe consultar `RequiereConfirmarAbandono` antes de llamar a `Elegir`); `RequiereConfirmar_SoloConCambios`; `Guardado_VuelveANavegando`; `Descartado_VuelveANavegando`; `Navegando_NoPuedeGuardar`.
- [ ] **Step 2: Agregar a los `.dpr` de pruebas; compilar.** Expected: FAIL (unidad no encontrada).
- [ ] **Step 3: Implementar** `TEstadoFicha` (ASCII, solo RTL) con campos privados `FModo`, `FCambios`.
- [ ] **Step 4: Compilar y ejecutar.** Expected: todas PASS.
- [ ] **Step 5: Agregar a `ArchiGenioPro.dpr` y commit** ("Clasificadores: estado de la ficha de edicion").

---

### Task 3: Datos de servidores — lectura y validación

**Files:**
- Create: `UServidoresDatos.pas`
- Create/Test: `Pruebas/UPruebasServidoresDatos.pas`
- Modify: `Pruebas/PruebasArchiGenio.dpr`, `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: `UAlmacenServidor` (`TDatosServidorS3`, `GuardarServidorS3`), `USecretoServidor` (`CifrarSecreto`, `DescifrarSecreto`), tabla `cl_ftp_Server` (columnas `Idservidor, etiquetaServ, ipserver, path, pass, puerto, usuarioftp, tipo, bucket, region, usohttps, clave_acceso, secreto_cifrado`; `tipo` es `'FTP'` o `'S3'`).
- Produces:

```pascal
type
  TTipoServidor = (tsFtp, tsS3);
  TServidor = record
    Id: Integer;            // 0 = nuevo
    Etiqueta: string;       // nombre para mostrar (etiquetaServ, max 50)
    Tipo: TTipoServidor;
    Direccion: string;      // ipserver (max 100)
    Puerto: Integer;
    RutaRaiz: string;       // path (solo FTP)
    Usuario, Clave: string; // usuarioftp, pass (solo FTP; Clave max 20)
    Bucket, Region: string; // solo S3
    UsoHttps: Boolean;
    ClaveAcceso: string;    // solo S3
    Secreto: string;        // solo entrada; vacio al editar = conservar el guardado
  end;
  TErrorCampo = record Campo, Mensaje: string; end;
  EServidorInvalido = class(Exception);
  EServidorEnUso = class(Exception)
    Usos: Integer;
  end;

{ Filas de cl_ftp_Server (Secreto siempre vacio). Ordenadas por Idservidor. }
function ListarServidores(Conn: TFDConnection): TArray<TServidor>;
{ Lista vacia = valido. Campo es uno de: etiqueta, direccion, puerto, usuario, clave,
  bucket, claveacceso, secreto. }
function ValidarServidor(const S: TServidor): TArray<TErrorCampo>;
```

  Reglas de `ValidarServidor`: `etiqueta` obligatoria (<=50); `direccion` obligatoria (<=100); `puerto` entre 1 y 65535; FTP: `usuario` obligatorio, `clave` obligatoria si `Id = 0` y <=20; S3: `bucket` y `claveacceso` obligatorios, `secreto` obligatorio si `Id = 0`.

- [ ] **Step 1: Escribir las pruebas puras** (`TPruebasValidarServidor`): `Valido_FtpCompleto_SinErrores`; `Etiqueta_Vacia_Error`; `Puerto_Cero_Error`; `Puerto_70000_Error`; `Ftp_SinUsuario_Error`; `Ftp_ClaveDe21Caracteres_Error`; `S3_SinBucket_Error`; `S3_Nuevo_SinSecreto_Error`; `S3_Existente_SinSecreto_Valido` (conserva el guardado); `Un_Error_Por_Campo` (dos campos malos → dos entradas con `Campo` distinto). Y de datos (`TPruebasListarServidores`, con fixture de conexión como `Pruebas/UPruebasAlmacenServidor.pas`, omite si falta `ARCHIGENIO_TEST_DB`): `Listar_IncluyeElFtpExistente` (Id 1, tipo `tsFtp`, `Secreto = ''`).
- [ ] **Step 2: Agregar a los `.dpr` de pruebas; compilar.** Expected: FAIL (unidad no encontrada).
- [ ] **Step 3: Implementar `ListarServidores` y `ValidarServidor`** en `UServidoresDatos.pas` (ASCII; mensajes con `#NNN` para tildes). `ListarServidores` lee `cl_ftp_Server` con una consulta; `tipo` vacío o `NULL` cuenta como FTP.
- [ ] **Step 4: Compilar y ejecutar** (`ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`). Expected: PASS.
- [ ] **Step 5: Agregar a `ArchiGenioPro.dpr` y commit** ("Servidores: lectura y validacion").

---

### Task 4: Datos de servidores — guardar, eliminar protegido y probar

**Files:**
- Modify: `UServidoresDatos.pas`, `Pruebas/UPruebasServidoresDatos.pas`

**Interfaces:**
- Consumes: Task 3 (`TServidor`, `ValidarServidor`, excepciones).
- Produces:

```pascal
{ Alta (Id = 0) o edicion. Valida primero (EServidorInvalido con el primer mensaje).
  S3 usa GuardarServidorS3 (secreto cifrado; vacio al editar = conserva). FTP escribe
  etiquetaServ, ipserver, path, pass, puerto, usuarioftp, tipo='FTP'. Devuelve el Idservidor. }
function GuardarServidor(Conn: TFDConnection; const S: TServidor): Integer;
{ Documentos y ficheros que usan el servidor: tb_SeriesDatos.Idservidor +
  tb_Serietree.Idservidor + tb_ssArchdigital con urlraiz que empieza por 's3://<id>/'. }
function ContarUsoServidor(Conn: TFDConnection; Id: Integer): Integer;
{ EServidorEnUso (con Usos) si Usos > 0; no borra nada. }
procedure EliminarServidor(Conn: TFDConnection; Id: Integer);
{ Prueba de conexion. S3: TAlmacenS3.Probar con el secreto escrito o, si esta vacio,
  el guardado (DescifrarSecreto). FTP: TIdFTP Connect/Disconnect. Nunca lanza: devuelve
  False y un Mensaje legible ('Servidor no encontrado', 'Credenciales rechazadas'...). }
function ProbarServidor(Conn: TFDConnection; const S: TServidor; out Mensaje: string): Boolean;
```

- [ ] **Step 1: Escribir las pruebas de datos** (fixture: filas con `etiquetaServ LIKE 'zz_srv%'` e `Idservidor >= 9000`, borradas en `TearDown`): `Guardar_FtpNuevo_DevuelveIdYSePuedeLeer`; `Guardar_S3Nuevo_CifraElSecreto` (`secreto_cifrado <> ''` y distinto del texto plano); `Guardar_S3Editar_SinSecreto_ConservaElCifrado` (Review Focus 1); `Guardar_Invalido_LanzaYNoEscribe` (cuenta de filas igual antes y después; Review Focus 4); `Eliminar_SinUso_Borra`; `Eliminar_EnUsoPorSerieTree_Bloquea` (insertar fila en `tb_Serietree` con ese `Idservidor` en una transacción de la prueba, `EServidorEnUso.Usos >= 1`, la fila del servidor sigue; Review Focus 2); `Eliminar_EnUsoPorUrlRaizS3_Bloquea` (fila en `tb_ssArchdigital` con `urlraiz = 's3://<id>/'`); `Probar_FtpSinServidor_DevuelveFalseConMensaje` (`127.0.0.1` puerto `1`, `Mensaje <> ''`, no lanza; Review Focus 6); `Probar_S3EndpointInexistente_DevuelveFalse` (host `no-existe.invalid`).
- [ ] **Step 2: Compilar pruebas.** Expected: FAIL (identificadores sin definir).
- [ ] **Step 3: Implementar** las cuatro funciones en `UServidoresDatos.pas`. `GuardarServidor` en transacción para FTP. `ContarUsoServidor` con `ExecSQLScalar` parametrizado y `LEFT(urlraiz, :n) = :p`. `ProbarServidor` con timeouts cortos (`ConnectTimeout` de `TIdFTP` 5000 ms) y `try/except` que traduce `EIdSocketError`/`EIdException`/`EAlmacen` a un mensaje.
- [ ] **Step 4: Compilar y ejecutar toda la suite.** Expected: todas PASS, 0 fallos, sin filas `zz_srv%` ni `Idservidor >= 9000` restantes (`SELECT COUNT(*) ...` = 0).
- [ ] **Step 5: Commit** ("Servidores: guardar, baja protegida y prueba de conexion").

---

### Task 5: Formulario base de clasificador (por código)

**Files:**
- Create: `UClasificadorBase.pas`
- Modify: `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: `UTema`, `UAparienciaLegacy.TemaLegacyActual`, `UClasificadorEstado.TEstadoFicha`, `UMensajes`.
- Produces:

```pascal
type
  TFormClasificadorBase = class(TForm)
  protected
    FTema: TTemaColores;
    FEstado: TEstadoFicha;
    FCuerpoPanel: TPanel;      // contenedor donde la pantalla hija arma sus campos
    function Vista: TcxGridTableView;
    procedure ConstruirBase(const ATitulo, ASubtitulo, ATextoNuevo: string);
    function AgregarColumna(const ATitulo: string; AAncho: Integer): TcxGridColumn;
    function AgregarFila(const AValores: array of Variant; ATag: Integer): Integer;
    procedure LimpiarFilas;
    function FilaActualTag: Integer;     // -1 si no hay fila elegida
    procedure SeleccionarPorTag(ATag: Integer);
    procedure AbrirPanel(const ATitulo: string; AMostrarEliminar: Boolean);
    procedure CerrarPanel;
    procedure FijarBotones(AGuardar, ACancelar, AEliminar: Boolean);
    function ConfirmarAbandonar: Boolean;  // True si no hay cambios o el usuario acepta perderlos
    // Eventos que la pantalla hija implementa:
    procedure AlNuevo; virtual; abstract;
    procedure AlElegirFila(ATag: Integer); virtual; abstract;
    procedure AlGuardar; virtual; abstract;
    procedure AlEliminar; virtual; abstract;
    procedure AlCancelar; virtual;        // por defecto: descarta y cierra el panel
  public
    destructor Destroy; override;
  end;
```

- [ ] **Step 1: Implementar `UClasificadorBase.pas`** (sin `.dfm`): formulario modal casi a pantalla completa (`Position = poScreenCenter`, tamaño 90 % del área de trabajo), `BorderIcons` solo cerrar, `Color = FTema.Fondo`; cabecera (`TPanel` alto 64 con título en `Segoe UI Semibold`, subtítulo en `TextoSuave`, `TEdit` de búsqueda con marca "Buscar…" a la derecha, botón "Exportar" secundario y botón "+ <ATextoNuevo>" de acento); `TcxGrid` con una `TcxGridTableView` **sin enlace a datos** (`DataController.RecordCount` + `Values[fila, col]`), con `OptionsView.GridLines = glNone`, `GroupByBox = False`, `ColumnAutoWidth = True`, altura de fila y de cabecera con `Esc(...)`, `OptionsSelection.CellSelect = False`, `OptionsData.Editing/Inserting/Deleting = False`, estilos (`TcxStyleRepository`) con colores del tema (cabecera `Superficie2` texto `TextoSuave` en mayúsculas pequeñas, selección `AcentoSuave`, fondo `Superficie`, línea `Linea`) y `LookAndFeel.NativeStyle = False`; panel lateral derecho de 370 px (oculto hasta `AbrirPanel`) con título, botón cerrar (✕), `FCuerpoPanel` y barra inferior "Guardar / Cancelar / Eliminar". La búsqueda filtra filas cuyo texto en cualquier columna contiene el texto (sin distinguir mayúsculas). Elegir una fila llama a `ConfirmarAbandonar` y luego a `AlElegirFila`; pulsar ✕ o cerrar el formulario con cambios llama a `ConfirmarAbandonar` (Review Focus 3) con `TMensajes.Confirmar('Hay cambios sin guardar. ¿Descartarlos?', 'Cambios sin guardar')`. "Exportar" reutiliza el mecanismo de exportación a Excel de `UExcelExport` (revisar cómo lo llama `TfrmListFTPServer.btnExcelExportClick`, `UCLFtpServer.pas:93`).
- [ ] **Step 2: Agregar a `ArchiGenioPro.dpr`; compilar** `scripts/compilar.ps1 ArchiGenioPro.dproj`. Expected: sin errores.
- [ ] **Step 3: Commit** ("Clasificadores: formulario base por codigo"). La verificación visual ocurre en la Task 6, cuando haya una pantalla que lo use.

---

### Task 6: Pantalla de Servidores FTP/S3

**Files:**
- Create: `UCLServidoresForm.pas`
- Modify: `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: Task 3 y 4 (`UServidoresDatos`), Task 5 (`TFormClasificadorBase`), `UCapaDatos.UDM.Conn` (solo en la función de entrada), `UMensajes`.
- Produces:

```pascal
{ Abre la pantalla de Servidores FTP/S3 de forma modal sobre Conn. }
procedure MostrarClasificadorServidores(Conn: TFDConnection);
```

- [ ] **Step 1: Implementar `TfrmServidores = class(TFormClasificadorBase)`** en `UCLServidoresForm.pas` (por código): columnas Estado (punto + texto: "Activo"/"Sin probar", sin consultar la red al abrir), Nombre, Tipo (etiqueta "S3 · MinIO" o "FTP" en texto), Dirección (`host:puerto`), Destino (bucket o ruta raíz); subtítulo "N servidores · M en S3/MinIO". Panel: selector de tipo (dos botones tipo segmento FTP | S3 / MinIO, solo editable en servidores nuevos), campos según el tipo (FTP: nombre, dirección, puerto, ruta raíz, usuario, contraseña; S3: nombre, dirección (endpoint), puerto, "Usar conexión segura (HTTPS)", bucket, región, clave de acceso, clave secreta con la ayuda "Se guarda cifrada. Déjela vacía al editar para conservar la actual."), botón "Probar conexión" con el resultado en una línea bajo los campos (verde/granate) que corre en `TThread.CreateAnonymousThread` + `TThread.Queue` copiando el patrón de `TDialogoS3.AlProbar` (`UServidorS3Dialogo.pas:186-236`, incluido el guardia por si la ventana ya se cerró), y mensajes de error **por campo** bajo cada campo desde `ValidarServidor`. Cada cambio en un campo llama a `FEstado.MarcarCambio`. `AlGuardar` arma el `TServidor`, llama a `GuardarServidor`, refresca la tabla, selecciona la fila y llama a `FEstado.Guardado`. `AlEliminar` pide `TMensajes.Confirmar`, llama a `EliminarServidor` y, ante `EServidorEnUso`, muestra `TMensajes.Advertencia` con el número de usos. Todo mensaje de error de BD por `TMensajes.Error`.
- [ ] **Step 2: Agregar a `ArchiGenioPro.dpr`; compilar.** Expected: sin errores.
- [ ] **Step 3:** La comprobación visual se hace en la Task 7, Step 5 (aún no hay entrada de menú que abra esta pantalla); aquí basta con que compile.
- [ ] **Step 4: Commit** ("Servidores: pantalla nueva FTP/S3").

---

### Task 7: Conexión con el menú, interruptor y documentación

**Files:**
- Modify: `UMAINFORM.pas` (`TMAIN.L1Click`), `CLAUDE.md`
- Create: `docs/superpowers/plans/2026-11-12-verificacion-clasificadores-servidores.md`

**Interfaces:**
- Consumes: Task 1 (`ClasificadoresClasicos`, `RegistrarErrorClasificador`), Task 6 (`MostrarClasificadorServidores`).

- [ ] **Step 1: Extraer el cuerpo actual de `L1Click` a `procedure TMAIN.AbrirServidoresClasico`** (privado; misma lógica: `TfrmListFTPServer.Create`, `ShowModal`, refrescos y logs 14/15) sin cambiar su comportamiento.
- [ ] **Step 2: Reescribir `L1Click`:** `if ClasificadoresClasicos(PathSys) then AbrirServidoresClasico else try (registrar log 14; MostrarClasificadorServidores(UDM.Conn); refrescar UDM.cl_ftp_Server y UDM.cmdServer; log 15) except on E: Exception do begin RegistrarErrorClasificador(PathSys, 'Servidores: ' + E.ClassName + ': ' + E.Message); AbrirServidoresClasico; end end;` con `Screen.Cursor` y `PContainer.Visible` restaurados en `finally` como hoy. Agregar `UCLServidoresForm, UClasificadoresInterruptor` a la cláusula `uses` de implementación.
- [ ] **Step 3: Compilar la aplicación y la suite de pruebas.** Expected: sin errores; todas las pruebas PASS.
- [ ] **Step 4: Escribir la lista de verificación** `2026-11-12-verificacion-clasificadores-servidores.md` con los seis puntos de Review Focus más: tabla sin aspecto de Excel, panel lateral, claro y oscuro, alta de FTP, alta de S3/MinIO con "Probar conexión", editar S3 sin tocar la clave secreta, `clasificadores_clasico.flag` abre la pantalla vieja, simular un fallo (renombrar una columna en una copia de la base de pruebas o forzar excepción) abre la vieja y escribe `clasificadores_error.log`.
- [ ] **Step 5: Verificación visual con captura de pantalla** (`CopyFromScreen` como se hizo en el arranque): iniciar sesión como administrador, abrir Servidores desde el menú de clasificadores y comparar con `tabla-con-panel-s3.html`. Ajustar espacios, colores y tamaños en `UClasificadorBase.pas`/`UCLServidoresForm.pas` hasta que coincidan en lo esencial.
- [ ] **Step 6: Actualizar `CLAUDE.md`** (capa de clasificadores nuevos, interruptor `.flag`, `clasificadores_error.log`, base `UClasificadorBase` para las próximas pantallas) y **commit** ("Clasificadores: Servidores usa la pantalla nueva con interruptor clasico").
