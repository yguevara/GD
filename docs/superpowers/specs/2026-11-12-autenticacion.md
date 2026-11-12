# Autenticación — diseño y mantenimiento

Documento de referencia del inicio de sesión de ArchiGenio tras el rediseño del 2026-11-12
(plan: `docs/superpowers/plans/2026-11-12-rediseno-autenticacion.md`).

## Piezas

| Unidad | Responsabilidad |
|---|---|
| `UAutenticacion.pas` | Lógica **sin VCL ni `TUDM`**: validar campos, calcular MD5, verificar credenciales contra la BD, recordar el último usuario. Cubierta por `Pruebas/UPruebasAutenticacion.pas`. |
| `UAutentica.pas/.dfm` | Ventana. Solo captura usuario y clave, muestra el mensaje y devuelve un `TResultadoAutenticacion`. **No modifica la sesión.** |
| `UMAINFORM.pas` | `btnautenticaClick` decide; `AplicarSesion` y `CerrarSesion` son el **único lugar** donde cambia la sesión (`UDM.Rol`, `UDM.UserName`, alcance, paneles, opciones por rol, árbol, nivel de acceso). |
| `UNewUser.pas`, `UChangePass.pas` | Altas y cambios de clave; usan `ValidarClaveNueva` y `CalcularMd5`. |

## Flujo

1. El usuario pulsa el botón de autenticación (`btnautentica`).
2. `Autenticar(out R)` abre la ventana. Al pulsar **Entrar**:
   1. `ValidarCampos`: usuario y clave no vacíos (sin longitud mínima, para no bloquear claves antiguas cortas).
   2. `VerificarCredenciales(UDM.Conn, usuario, clave)`: consulta parametrizada a `cl_Resp_Gest_Arch` + `tb_rol`, siempre en vivo (no usa el dataset `cl_Resp_Gest_Arch` de `UDM`, que puede estar desactualizado).
3. Estados de `TResultadoAutenticacion.Estado`:
   - `eaAceptado`: la ventana se cierra con `mrOk`; el shell llama a `AplicarSesion(R.Usuario, R.Rol)`.
   - `eaCredencialesInvalidas`, `eaDeshabilitado`: mensaje bajo los campos, se limpia solo la clave, se registra el fallo (log tipo 11, **sin la clave**).
   - `eaErrorBD`: mensaje de "no se pudo consultar la base de datos" y el motivo técnico en el log.
   - `eaCamposInvalidos`: lo produce `ValidarCampos` en la ventana (no llega a la BD).
4. **Cancelar / Esc / cerrar con X**: `Autenticar` devuelve `False`; la sesión no cambia.
5. Cerrar sesión: confirmación, log tipo 13 y `CerrarSesion` (= `AplicarSesion('Invitado', 'Visor')`).

## Reglas

- Usuario: no distingue mayúsculas ni espacios en los extremos (`NormalizarUsuario`).
- Clave guardada: MD5 en minúsculas de `Trim(clave)` (`CalcularMd5`). Es el mismo formato de siempre.
- Clave nueva (alta o cambio): mínimo `LONGITUD_MINIMA_CLAVE_NUEVA` = 6 caracteres y coincidir con la confirmación.
- Último usuario: archivo `lastuseraut.ini` en `PathTemp` (primera línea). Cualquier fallo de lectura o escritura se ignora.
- Ayuda: botón "Ayuda" y F1 abren el tema 11 de `ArchiGenio.chm`.

## Cambios respecto al comportamiento anterior

- Cancelar tras un intento fallido ya no deja una sesión "autenticada" con rol vacío.
- El usuario escrito como `Admin` o `ADMIN` entra igual que `admin`.
- Un usuario creado o con la clave cambiada desde otro puesto entra sin reiniciar la aplicación.
- Un error de BD, un usuario deshabilitado y una clave incorrecta se distinguen (mensaje y log).
- `TSecurityClass.GetRol` y `TUDM.getMd5HashString` se eliminaron; `USplash` conserva su copia privada de MD5.

## Pendiente (etapa de seguridad, fuera de este rediseño)

- Hash con sal / algoritmo más fuerte que MD5 y migración de las claves existentes.
- Límite de intentos fallidos y bloqueo temporal.
- Decidir si el mensaje de "usuario inexistente" debe seguir siendo genérico (hoy es el mismo que "clave incorrecta").
- Unificar el cálculo de MD5 de `USplash` (si se sigue usando).
- Revisar el almacenamiento de `lastuseraut.ini` si `PathTemp` es compartida entre usuarios del sistema operativo.
