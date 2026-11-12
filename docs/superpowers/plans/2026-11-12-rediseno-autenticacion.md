# Rediseño de la autenticación — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rediseñar la ventana de inicio de sesión y corregir el flujo de autenticación (cancelar, usuario con mayúsculas, datos desactualizados, errores tragados), dejando la lógica en una unidad sin VCL con pruebas y el código documentado en español.

**Architecture:** La ventana `TfrmAutentica` solo captura datos y muestra mensajes. Una unidad nueva sin VCL ni `TUDM` (`UAutenticacion.pas`) valida los campos, consulta la base de datos con parámetros y devuelve un resultado explícito (`TResultadoAutenticacion`). `UDM.Rol`/`UDM.UserName` solo se escriben cuando el resultado es `raAceptado`. El shell (`TMAIN.btnautenticaClick`) consume ese resultado.

**Tech Stack:** Delphi 10.3 VCL, FireDAC (SQL Server y Access), DUnitX en `Pruebas/`, tema Vcl.Styles de la aplicación.

**Spec:** No hay documento de diseño aparte; el diagnóstico de esta conversación (2026-11-12) es la especificación. Resumen en la sección "Diagnóstico base". Seguridad (hash con sal, límite de intentos) queda **fuera de alcance** por decisión del usuario.

## Diagnóstico base (lo que el plan debe corregir)

1. Cancelar o cerrar con Esc tras un intento fallido deja `UDM.Rol = ''`; `autenticar` lo devuelve y el shell lo toma como sesión válida (`btncancelClick` asigna `UserROL`, otra variable).
2. `cl_Resp_Gest_Arch.Locate('usuario', texto, [])` distingue mayúsculas; `GetRol` pasa a minúsculas.
3. El login depende de la copia local `cl_Resp_Gest_Arch` (se abre al conectar): un usuario nuevo o con clave cambiada desde otro puesto falla hasta refrescar.
4. `GetRol` traga toda excepción (`except Result := ''`): error de BD se ve como clave incorrecta; usuario deshabilitado no se distingue.
5. Longitud mínima de clave: login 4, `UChangePass` >4, `UNewUser` >6.
6. `FormActivate` roba el foco en cada activación; `FormShow` usa `Focused` (solo consulta) y `List[0]` sin protección si `lastuseraut.ini` está vacío.
7. Código muerto en `UAutentica` (`buscaUser`, `nombreuser`, `Arol`, `LogeUser`, `userrol`, `getFileMd5HashString`) y versión comentada de `btnautenticaClick` en `UMAINFORM`; MD5 duplicado en `UAutentica` y `UDM`.

## Global Constraints

- Codificación: archivos existentes ANSI/Windows-1252 con CRLF; no reescribirlos pasando por UTF-8. Unidades nuevas en ASCII puro (sin tildes en comentarios ni cadenas), igual que `UAlcance`. Los textos con tilde que vea el usuario se ponen en el `.dfm`/`.pas` existente conservando su codificación o se escapan con `#NNN`.
- SQL válido en Access y SQL Server (funciones de minúsculas: `lcase`/`lower` según `TBD`; usar parámetros, nunca concatenar).
- Las unidades nuevas no usan VCL ni `UCapaDatos` (RTL + FireDAC como máximo) para poder compilarse en `Pruebas/`.
- Toda unidad nueva se agrega en `ArchiGenioPro.dpr` (y las de prueba en `Pruebas/PruebasArchiGenio.dpr`).
- No se tocan `Win32/Debug/*.dcu` ni `ArchiGenioPro.identcache` al hacer commit.
- Comentarios y documentación de código en español; cada rutina pública lleva un encabezado de propósito, parámetros y resultado.
- Compilar con `scripts/compilar.ps1`; tests: `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y ejecutar `Pruebas\Win32\Debug\PruebasArchiGenio.exe` (código de salida 0).
- Fuera de alcance: cambiar el algoritmo de hash, sal, bloqueo por intentos, migración de claves.

## Review Focus

1. Cancelar (botón, Esc, cierre con X) tras uno o varios intentos fallidos: la sesión no debe quedar autenticada ni `UDM.Rol` debe quedar vacío.
2. Usuario escrito como `Admin`, ` admin ` o `ADMIN`: debe entrar igual que `admin`.
3. Usuario creado o clave cambiada en otro puesto un minuto antes: el login debe funcionar sin reiniciar la aplicación.
4. Servidor de BD caído durante el login: mensaje de "no se pudo consultar" y registro del error, no "clave incorrecta".
5. `lastuseraut.ini` vacío, solo con espacios, con varias líneas o en una carpeta de solo lectura: la ventana abre igual y no lanza excepción.

---

## Estructura de archivos

- Create `UAutenticacion.pas`: lógica sin VCL (validación de campos, MD5, consulta de credenciales, último usuario).
- Create `Pruebas/UPruebasAutenticacion.pas`: pruebas DUnitX de la unidad anterior.
- Modify `UAutentica.pas` / `UAutentica.dfm`: ventana rediseñada, delgada, usa `UAutenticacion`.
- Modify `UMAINFORM.pas` (`btnautenticaClick`, ~2313-2451; versión comentada ~2455-2560): consumir el resultado, extraer `AplicarSesion`, borrar código comentado.
- Modify `UNewUser.pas`, `UChangePass.pas`: regla de clave única; usar el MD5 común.
- Modify `UCapaDatos.pas` (`TUDM.getMd5HashString`, ~2916): delegar en la unidad nueva o eliminarlo si queda sin usos.
- Modify `USecurityClasss.pas` (`GetRol`, ~666): retirar si queda sin usos.
- Modify `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`, `CLAUDE.md`.

---

### Task 1: Diseño de la ventana (aprobación y maqueta)

**Files:**
- Modify: `UAutentica.dfm`, `UAutentica.pas` (solo declaraciones/eventos de controles; la lógica no cambia en esta tarea)

**Interfaces:**
- Consumes: controles actuales `edtuser`, `edtpass`, `btnAcept`, `btnCancel`, `btnHelp`, `Image1`, y los manejadores existentes.
- Produces: la misma clase `TfrmAutentica` con los mismos nombres de controles más `lblMensaje: TLabel` (línea de error bajo los campos) y `chkMostrarClave: TCheckBox`. Las tareas 3 y 4 usan esos dos nombres.

- [ ] **Step 1: Presentar la maqueta al usuario y esperar aprobación.** Mostrar esta propuesta (ASCII) y ajustar con sus comentarios antes de tocar el `.dfm`:

```
+--------------------------------------------+
|  [logo ArchiGenio]   Iniciar sesion        |
|                      Sistema de gestion... |
|--------------------------------------------|
|  Usuario                                   |
|  [______________________________]          |
|  Contrasena                                |
|  [______________________________] [ojo]    |
|  (mensaje de error en rojo, 1-2 lineas)    |
|--------------------------------------------|
|  [Ayuda]                [Cancelar][Entrar] |
+--------------------------------------------+
```

  Decisiones a confirmar con el usuario: logo/imagen que se conserva (`Image1`), texto del título, si se mantiene el botón Ayuda (hoy `Application.HelpContext(11)` y F1), y si se desea "mostrar contraseña".
- [ ] **Step 2: Comprobar cómo aplican tema y DPI las pantallas recientes** (`UAsignacionNodos.pas`, `UTema.pas`, `UAparienciaLegacy.pas`) y usar el mismo mecanismo en `TfrmAutentica`. Anotar en un comentario del `.pas` cuál se usó.
- [ ] **Step 3: Reescribir `UAutentica.dfm`** (conservar codificación y estructura `object`/`end`): quitar `Constraints.Min/Max` fijos; `Position = poScreenCenter`; `BorderStyle = bsDialog`; `Font.Name = 'Segoe UI'`, tamaño 9; controles con `Anchors`/`Align`; `edtpass.PasswordChar = '*'`; `btnAcept.Default = True` y `btnCancel.Cancel = True` (reemplaza los `KeyPress` de Esc/Enter); `KeyPreview = False`. Agregar `lblMensaje` (vacío, `Font.Color` rojo, oculto con `Visible = False`) y `chkMostrarClave` (su `OnClick` alterna `PasswordChar` entre `#0` y `'*'`).
- [ ] **Step 4: Ajustar `UAutentica.pas`** para declarar los dos controles nuevos y el manejador `chkMostrarClaveClick`; eliminar los manejadores `edtpassKeyPress`, `btnAceptKeyPress`, `btnCancelKeyPress`, `FormKeyPress` (cubiertos por `Default`/`Cancel`) y el cuerpo duplicado de F1 se deja en `edtuserKeyDown`.
- [ ] **Step 5: Compilar** `scripts/compilar.ps1 ArchiGenioPro.dproj` — Expected: sin errores.
- [ ] **Step 6: Verificación manual**: abrir la aplicación, pulsar el botón de autenticación; Enter acepta, Esc cancela, ventana legible a 100 % y 150 % de escala, tema correcto. Mostrar captura/descripción al usuario.
- [ ] **Step 7: Commit** (`git add UAutentica.pas UAutentica.dfm`; mensaje en español: "Autenticacion: nueva ventana de inicio de sesion").

---

### Task 2: Unidad de lógica `UAutenticacion` con pruebas

**Files:**
- Create: `UAutenticacion.pas`
- Create: `Pruebas/UPruebasAutenticacion.pas`
- Modify: `Pruebas/PruebasArchiGenio.dpr`, `ArchiGenioPro.dpr`

**Interfaces:**
- Produces (todo en `UAutenticacion.pas`, ASCII, sin VCL):

```pascal
const
  LONGITUD_MINIMA_CLAVE_NUEVA = 6;   // altas y cambios de clave

type
  TEstadoAutenticacion = (eaAceptado, eaCamposInvalidos, eaCredencialesInvalidas,
                          eaDeshabilitado, eaErrorBD);

  TResultadoAutenticacion = record
    Estado: TEstadoAutenticacion;
    Usuario: string;     // normalizado a minusculas y sin espacios
    Rol: string;         // solo si eaAceptado
    Mensaje: string;     // texto para el usuario
    Detalle: string;     // texto tecnico para el registro (UDM.log)
  end;

function CalcularMd5(const AValor: string): string;
function NormalizarUsuario(const AUsuario: string): string;
function ValidarCampos(const AUsuario, AClave: string; out AMensaje: string): Boolean;
function ValidarClaveNueva(const AClave, AConfirmacion: string; out AMensaje: string): Boolean;
function VerificarCredenciales(AConn: TFDConnection; const AUsuario, AClave: string): TResultadoAutenticacion;
function LeerUltimoUsuario(const ARuta: string): string;
procedure GuardarUltimoUsuario(const ARuta, AUsuario: string);
```

  Reglas: `ValidarCampos` exige usuario no vacío y clave no vacía (sin mínimo de longitud, para no bloquear a quien tenga clave antigua corta). `VerificarCredenciales` consulta con parámetros `tb_rol` + `cl_Resp_Gest_Arch` comparando `lower(usuario)`; si no hay fila → `eaCredencialesInvalidas`; si hay fila con clave correcta y `habilitado <> 'S'` → `eaDeshabilitado`; cualquier excepción → `eaErrorBD` con `Detalle = E.Message`. `LeerUltimoUsuario` devuelve `''` ante archivo inexistente, vacío, ilegible; `GuardarUltimoUsuario` ignora errores de escritura.

- [ ] **Step 1: Escribir las pruebas** en `UPruebasAutenticacion.pas`, siguiendo el montaje de conexión de `Pruebas/UPruebasAsignacion.pas` (fixture con tablas temporales). Casos, con sus aserciones:
  - `Md5_Conocido`: `CalcularMd5('abc') = '900150983cd24fb0d6963f7d28e17f72'`.
  - `Normalizar_QuitaEspaciosYMayusculas`: `NormalizarUsuario('  Admin ') = 'admin'`.
  - `Campos_UsuarioVacio_Falla` / `Campos_ClaveVacia_Falla` / `Campos_ClaveDeTresCaracteres_Acepta`.
  - `ClaveNueva_CortaFalla` (5 caracteres), `ClaveNueva_NoCoincideFalla`, `ClaveNueva_SeisCoincideAcepta`.
  - `Verificar_CorrectoDevuelveRol`: estado `eaAceptado`, `Rol` igual al de `tb_rol`, `Usuario = 'admin'`.
  - `Verificar_UsuarioConMayusculasAcepta`: `'ADMIN'` → `eaAceptado`.
  - `Verificar_ClaveIncorrecta`: `eaCredencialesInvalidas`, `Rol = ''`.
  - `Verificar_UsuarioInexistente`: `eaCredencialesInvalidas`.
  - `Verificar_Deshabilitado`: `eaDeshabilitado` y `Rol = ''`.
  - `Verificar_ComillaEnUsuario_NoRompe`: usuario `o'brien` → `eaCredencialesInvalidas` sin excepción.
  - `Verificar_ConexionCerrada`: `eaErrorBD` y `Detalle <> ''`.
  - `Verificar_UsuarioNuevoSinRefrescar`: insertar usuario por SQL directo y verificar de inmediato → `eaAceptado` (cubre Review Focus 3).
  - `UltimoUsuario_ArchivoVacio`, `_SoloEspacios`, `_VariasLineas` (devuelve la primera línea recortada), `_NoExiste` → `''`; `Guardar_RutaInvalida_NoLanza`.
- [ ] **Step 2: Agregar** `UPruebasAutenticacion` y `UAutenticacion in '..\UAutenticacion.pas'` a `Pruebas/PruebasArchiGenio.dpr`; compilar — Expected: falla por unidad inexistente.
- [ ] **Step 3: Implementar `UAutenticacion.pas`** con las firmas de arriba y documentación en español en cada rutina. `CalcularMd5` con `TIdHashMessageDigest5.HashStringAsHex` en minúsculas (igual al hash ya guardado). SQL con `:usuario` como parámetro y `lcase`/`lower` según el driver de la conexión (`AConn.DriverName`).
- [ ] **Step 4: Compilar y ejecutar** las pruebas — Expected: todas PASS, código de salida 0.
- [ ] **Step 5: Agregar la unidad a `ArchiGenioPro.dpr`** y commit ("Autenticacion: unidad de logica sin VCL con pruebas").

---

### Task 3: Conectar la ventana a la lógica y corregir cancelar

**Files:**
- Modify: `UAutentica.pas`

**Interfaces:**
- Consumes: Task 1 (`lblMensaje`, `chkMostrarClave`) y Task 2 (`VerificarCredenciales`, `ValidarCampos`, `NormalizarUsuario`, `LeerUltimoUsuario`, `GuardarUltimoUsuario`, `TResultadoAutenticacion`).
- Produces: `function Autenticar(out AResultado: TResultadoAutenticacion): Boolean;` — `True` solo si `AResultado.Estado = eaAceptado`. Sustituye a `function autenticar: string`. No escribe `UDM.Rol` ni `UDM.UserName`.

- [ ] **Step 1: Reescribir `btnaceptClick`**: `ValidarCampos` → `VerificarCredenciales(UDM.Conn, ...)` → según `Estado`: aceptado guarda el resultado, llama `GuardarUltimoUsuario(PathTemp + 'lastuseraut.ini', usuario)` y `ModalResult := mrOk`; credenciales inválidas/deshabilitado muestran `lblMensaje`, limpian la clave y devuelven el foco; `eaErrorBD` muestra mensaje y llama `UDM.log(Detalle, 11, '', '', '')`. Los fallos se registran con el log existente, sin cambiar su formato.
- [ ] **Step 2: `btnCancel.ModalResult = mrCancel`** (sin código); `Autenticar` devuelve `False` y deja `AResultado.Estado` en `eaCredencialesInvalidas` con `Rol = ''`.
- [ ] **Step 3: `FormShow`**: `edtuser.Text := LeerUltimoUsuario(...)`; foco en `edtpass` si hay usuario, si no en `edtuser`. Eliminar `FormActivate`, `Arol`, `LogeUser`, `userrol`, `buscaUser`, `nombreuser`, `getFileMd5HashString`, `getMd5HashString` de la clase.
- [ ] **Step 4: Compilar** — Expected: errores solo en `UMAINFORM` por el cambio de firma de `autenticar` (se resuelve en Task 4).
- [ ] **Step 5: Commit** junto con Task 4 (no dejar la rama sin compilar).

---

### Task 4: Shell — consumir el resultado y limpiar `btnautenticaClick`

**Files:**
- Modify: `UMAINFORM.pas:2313-2451` (y borrar la versión comentada `2455-~2560`)

**Interfaces:**
- Consumes: `Autenticar(out R): Boolean` de Task 3.
- Produces: `procedure TMAIN.AplicarSesion(const AUsuario, ARol: string);` (privado) que centraliza paneles `MB.Panels[1]`/`[3]`, `UDM.Rol`, `UDM.UserName`, `EstablecerAlcance`, `CargarArbol`, opciones por rol, `Acomoda`/`Acomoda2`, `acceso` y `Security.SetModSecurity`; y `procedure TMAIN.CerrarSesion;` que llama a `AplicarSesion('Invitado','Visor')`. `FIsAuthenticated` solo se pone en `True` al terminar `AplicarSesion` sin excepción.

- [ ] **Step 1: Extraer `AplicarSesion` y `CerrarSesion`** desde el código actual (misma secuencia: `EstablecerAlcance`, `CargarArbol`, opciones por `GetRolID`, `Acomoda`, `Acomoda2`, `acceso`, `SetModSecurity`). Reemplazar el cuerpo duplicado de cerrar sesión y de autenticar. `GetRolID` pasa a consulta parametrizada.
- [ ] **Step 2: `btnautenticaClick`**: si ya autenticado, confirmar y `CerrarSesion` (conservar los textos y `UDM.log(...,13,...)`); si no, `if Autenticar(R) then AplicarSesion(R.Usuario, R.Rol) + log 11 + mensaje` `else` mensaje "Autenticación cancelada." solo si el estado fue cancelación.
- [ ] **Step 3: Borrar la versión comentada** de `btnautenticaClick`.
- [ ] **Step 4: Compilar** — Expected: sin errores.
- [ ] **Step 5: Verificación manual** (Review Focus 1, 2, 3, 4): fallar la clave dos veces y cancelar → sigue como Invitado/Visor y botón sin cambiar; entrar como `Admin`; crear un usuario desde otro puesto o directamente en BD y entrar sin reiniciar; detener SQL Server y comprobar el mensaje.
- [ ] **Step 6: Commit** (Tasks 3 y 4 juntas): "Autenticacion: ventana y shell usan el resultado explicito; cancelar no autentica".

---

### Task 5: Regla de clave única en altas y cambios

**Files:**
- Modify: `UNewUser.pas:~98-105`, `UChangePass.pas:~43-49`, `UCapaDatos.pas:~2916` (`getMd5HashString`)

**Interfaces:**
- Consumes: `ValidarClaveNueva`, `CalcularMd5`, `LONGITUD_MINIMA_CLAVE_NUEVA` de Task 2.

- [ ] **Step 1: En `UNewUser` y `UChangePass`** reemplazar las comprobaciones de longitud/coincidencia por `ValidarClaveNueva` (mostrar `AMensaje` con `UDM.sms`), y `UDM.getMd5HashString(...)` por `CalcularMd5(...)`.
- [ ] **Step 2: Si `TUDM.getMd5HashString` queda sin usos** (`grep -rn getMd5HashString --include=*.pas` fuera de `bakup/`), eliminarlo de interfaz e implementación; si no, hacer que delegue en `CalcularMd5`.
- [ ] **Step 3: Compilar y ejecutar pruebas** — Expected: sin errores; PASS.
- [ ] **Step 4: Verificación manual**: crear usuario con clave de 5 caracteres (rechazada), de 6 (aceptada), cambiar clave y volver a entrar.
- [ ] **Step 5: Commit**: "Autenticacion: regla unica de clave nueva y MD5 en una sola unidad".

---

### Task 6: Retiro de código sin uso y documentación

**Files:**
- Modify: `USecurityClasss.pas:~666` (`GetRol`), `UAutentica.pas`, `UMAINFORM.pas`, `CLAUDE.md`
- Create: `docs/superpowers/specs/2026-11-12-autenticacion.md`

- [ ] **Step 1: Retirar `TSecurityClass.GetRol`** si no tiene usos (`grep -rn "GetRol" --include=*.pas` fuera de `bakup/`).
- [ ] **Step 2: Revisar cabeceras** de `UAutenticacion.pas`, `UAutentica.pas` y de `AplicarSesion`/`CerrarSesion`: propósito, parámetros, resultado y excepciones en español (encoding del archivo respetado).
- [ ] **Step 3: Escribir el documento de diseño** `docs/superpowers/specs/2026-11-12-autenticacion.md`: flujo, estados del resultado, reglas de clave, ubicación de `lastuseraut.ini`, y la lista de "pendientes de seguridad" (hash con sal, intentos fallidos, migración).
- [ ] **Step 4: Actualizar `CLAUDE.md`**: añadir `UAutenticacion` a la capa pura y mencionar el documento de diseño; quitar la referencia a `GetRol` si la hubiera.
- [ ] **Step 5: Compilar proyecto y pruebas** — Expected: sin errores; pruebas PASS.
- [ ] **Step 6: Commit**: "Autenticacion: retiro de codigo sin uso y documentacion".

---

### Task 7: Verificación de punta a punta

**Files:**
- Create: `docs/superpowers/plans/2026-11-12-verificacion-autenticacion.md` (lista de comprobación, estilo de `2026-11-10-verificacion-espacio-de-trabajo.md`)

- [ ] **Step 1: Redactar la lista** con los cinco puntos de Review Focus más: login con administrador, gestor, archivista y visor (opciones y árbol según rol), cierre de sesión, ayuda con F1, Access y SQL Server.
- [ ] **Step 2: Ejecutarla** con el usuario y anotar resultados; corregir lo que falle antes de cerrar.
- [ ] **Step 3: Commit** del documento con los resultados.
