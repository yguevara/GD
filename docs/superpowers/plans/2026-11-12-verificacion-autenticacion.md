# Verificación manual — autenticación

Ejecutar con la aplicación compilada (`Win32\Debug\ArchiGenioPro.exe`) contra SQL Server y, si se usa, Access.
Marcar cada punto y anotar la fecha y lo observado. Las pruebas automáticas (481/481) ya cubren la lógica de `UAutenticacion`; esta lista cubre la ventana y el shell.

Estado: **pendiente de ejecutar con el usuario** (ver el resumen de la sesión del 2026-11-12).

## Ventana (diseño)

- [ ] Se abre centrada, sin botón de cerrar, con el banner arriba, campos Usuario y Contraseña, "Mostrar contraseña", Ayuda / Entrar / Cancelar.
- [ ] Legible con escala de pantalla 100 % y 150 %; no se corta ningún control; el tema Metropolis se aplica.
- [ ] Enter acepta (botón Entrar); Esc cancela; Alt+U / Alt+A / Alt+E / Alt+C llevan al control correcto.
- [ ] "Mostrar contraseña" muestra y oculta la clave.
- [ ] F1 y el botón Ayuda abren el tema 11 de la ayuda.
- [ ] Si hay un último usuario guardado, aparece escrito y el foco está en la contraseña; si no, el foco está en Usuario.

## Review Focus (del plan)

- [ ] **1. Cancelar tras fallos**: escribir una clave incorrecta dos veces y pulsar Cancelar (y otra vez con Esc): la barra de estado sigue en "Invitado" / "Visor", el botón de autenticación no cambia y el mensaje es "Autenticación cancelada."
- [ ] **2. Mayúsculas**: entrar con `Admin`, ` admin ` y `ADMIN` (usuario existente `admin`/`administrador`): entra igual.
- [ ] **3. Usuario creado en otro puesto**: crear un usuario (desde otro puesto o directo en la BD) y entrar con él en este puesto sin reiniciar: entra; probar también tras cambiarle la clave desde otro puesto.
- [ ] **4. BD caída**: detener el servicio de SQL Server (o desconectar la red) y pulsar Entrar: mensaje "No se pudo consultar la base de datos…", y el error técnico queda en el log del sistema; no dice "clave incorrecta".
- [ ] **5. `lastuseraut.ini`**: dejarlo vacío, con solo espacios, con varias líneas y en una carpeta de solo lectura: la ventana abre sin excepción.

## Roles y sesión

- [ ] Administrador: opciones de administrador, árbol completo, nivel "acceso total".
- [ ] Gestor: opciones de gestor, árbol según su alcance, "acceso total".
- [ ] Director/Archivista (si existen): opciones correspondientes.
- [ ] Visor: opciones de visor, "solo lectura".
- [ ] Usuario deshabilitado (`habilitado = 'N'`) con clave correcta: mensaje "deshabilitado" y el log lo registra.
- [ ] Cerrar sesión: confirmación, vuelve a Invitado/Visor, árbol solo público; volver a entrar funciona.
- [ ] El log registra: inicio (tipo 11), cierre (tipo 13) y los intentos fallidos sin la clave.

## Usuarios

- [ ] Alta de usuario con clave de 5 caracteres: rechazada con el mensaje de longitud mínima; con 6: aceptada y puede iniciar sesión.
- [ ] Cambio de clave (corta rechazada, correcta aceptada) y entrada con la nueva clave.
- [ ] Un usuario antiguo con clave de 4 o 5 caracteres sigue pudiendo entrar.

## Motores

- [ ] SQL Server.
- [ ] Access (consulta con `lcase` y parámetro `:usuario`): iniciar sesión y cerrar sesión.
