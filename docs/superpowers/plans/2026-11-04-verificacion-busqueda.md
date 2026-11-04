# Verificación manual de la búsqueda integrada (Fase 4, Tarea 3)

Plan: `2026-11-04-busqueda-integrada.md`. Pendiente de ejecutar por una persona: requiere iniciar sesión en la aplicación real.

## Lo que ya verifican las pruebas automáticas

Ejecutadas el 2026-11-04 con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` apuntando a una **copia** de `BD\SDbd.mdb`: 128/128 pasan (la prueba con rutas inexistentes falla, así que no se omiten).

- SQL Server y Access: texto en el título, límite y aviso de truncado, tabla `md_*` inexistente (se busca solo en datos fijos), `%` y `'` como caracteres literales.
- SQL Server: la búsqueda respeta el alcance (administrador, usuario con una subserie, usuario sin asignaciones, EGD).
- Reglas puras: escape de `LIKE`, nombres de campo y tabla seguros, pedido vacío, rango invertido, SQL de una subserie.

**Lo que las automáticas no cubren y esta lista sí:** la pantalla, el menú, y la búsqueda por campos propios de una subserie (tabla `md_*` con datos), que necesita una subserie con metadatos cargados.

## Preparación

1. Base de pruebas: `SGDTEST_ALCANCE`. Apuntar `config.ini` de una copia del ejecutable a esa base. **No usar `SGDDRHMAIN`.** Para el modo Access, usar una **copia** de `BD\SDbd.mdb`, nunca el original.
2. Usuarios: los mismos de `2026-10-29-verificacion-alcance.md` (`administrador`, `egd_a43`, `usr_sub`) y `014001` no pública (`acceso = 2`, solo en la base de pruebas).
3. Una subserie con metadatos: elegir una que ya tenga `NombreTablaMetadatos` y documentos con datos, o crear una en Clasificadores con tres campos: **Departamento** (Caracteres), **Ingreso** (Fecha) y **Folios** (Entero), más uno **Activo** (Boolean). Agregar al menos 4 documentos con valores distintos, uno con Departamento `Camagüey`, otro con Folios `0`, y fechas `01/01/2026`, `15/01/2026` y `31/01/2026`.
4. Agregar un documento con título `Acta 100% O'Brien` en una subserie visible para `administrador`.

## Casos

| # | Usuario | Qué hacer | Resultado esperado | Registrado |
|---|---|---|---|---|
| 1 | `administrador` | Herramientas → «Buscar documentos» | Se abre la pantalla; el combo lista «(Todas las de mi alcance)» y las subseries con documentos | |
| 2 | `administrador` | Cerrar la pantalla, cerrar y reabrir la ventana principal, abrir el menú de nuevo | «Buscar documentos» aparece **una sola vez** en el menú | |
| 3 | `administrador` | Buscar con todo vacío y «Todas» | Mensaje «Escriba un texto, o elija una subserie o un filtro, para buscar.»; no lista toda la base | |
| 4 | `administrador` | Texto `acta`, todas las subseries | Aparecen los documentos con «acta» en código o título, de varias subseries; la barra de estado indica la cantidad | |
| 5 | `administrador` | Texto `100%` | Solo el documento `Acta 100% O'Brien` | |
| 6 | `administrador` | Texto `%` | Solo los documentos que contienen el carácter `%` (el del caso 5), no toda la base | |
| 7 | `administrador` | Texto `O'Brien` | Solo ese documento, sin error de SQL | |
| 8 | `administrador` | Texto `_` | Solo documentos con un guion bajo literal | |
| 9 | `administrador` | Texto `camaguey` (sin tilde ni mayúscula) en la subserie con metadatos | SQL Server: encuentra el documento con Departamento `Camagüey`. Access: encuentra solo si coincide la tilde (limitación conocida) | |
| 10 | `administrador` | Elegir la subserie con metadatos | Aparece un filtro por cada campo: texto, dos fechas con casilla, dos números, y un combo para Activo | |
| 11 | `administrador` | Cambiar a otra subserie, y a «Todas» | Los filtros se reconstruyen; con «Todas» muestran «Elija una subserie…» | |
| 12 | `administrador` | Subserie sin campos propios | Mensaje «Esta subserie no tiene campos propios para filtrar.»; la búsqueda por texto sigue funcionando | |
| 13 | `administrador` | Filtro Ingreso desde `01/01/2026` hasta `31/01/2026` | Incluye los documentos del 01 y del 31 (el último día completo) | |
| 14 | `administrador` | Ingreso desde `31/01/2026` hasta `01/01/2026` | Mensaje de rango invertido; no ejecuta la búsqueda | |
| 15 | `administrador` | Folios desde `0` hasta `10` | Incluye el documento con Folios `0` | |
| 16 | `administrador` | Activo = Sí / No / (cualquiera) | Filtra por el valor; «(cualquiera)» no filtra | |
| 17 | `administrador` | Texto y filtro de campo a la vez | Devuelve solo los que cumplen ambas condiciones | |
| 18 | `administrador` | Una búsqueda con más de 500 coincidencias (por ejemplo texto `a`, si la base las tiene) | Lista 500 y la barra de estado dice «Hay más resultados: afine la búsqueda.». Si la base de pruebas no llega a 500, anotar «no aplicable» | |
| 19 | `egd_a43` | Buscar `acta` | Solo documentos de `A.4.3` más los públicos; el combo de subseries no ofrece las de otros nodos restringidos | |
| 20 | `usr_sub` | Buscar `acta` | Solo la subserie `014001` en `A.4.3` más los públicos | |
| 21 | Usuario sin asignaciones (o Invitado) | Buscar `acta` | Solo documentos públicos; ninguno restringido | |
| 22 | `usr_sub` | Con la subserie `014001` elegida, aplicar un filtro de campo | Los resultados siguen dentro del alcance (nada de otros nodos) | |
| 23 | Cualquiera | Doble clic en un resultado | Muestra el código del documento y el nodo donde está (la navegación al árbol queda para la Fase 1) | |
| 24 | Cualquiera | Con resultados en pantalla, editar el texto y volver a buscar | La lista se reemplaza, no se acumula | |
| 25 | Cualquiera | Cerrar con el botón «Cerrar» y con Esc | Se cierra sin error | |
| 26 | Modo Access (copia de `BD\SDbd.mdb`) | Abrir, iniciar sesión, «Buscar documentos» | Sin alcance: ve todas las subseries; texto, `%` y `'` literales; el menú funciona igual | |
| 27 | Modo Access | Búsqueda por un campo de metadatos y por rango de fechas | Mismos resultados que en SQL Server (salvo tildes, caso 9) | |

## Registro de la ejecución

- Fecha:
- Persona:
- Versión / compilación:
- Resultado general: aprobado / con observaciones / rechazado
- Observaciones:
