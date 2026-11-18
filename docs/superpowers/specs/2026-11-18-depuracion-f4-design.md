# Depuracion (F4): proceso de eliminacion de documentos

Fecha: 2026-11-18. Continua `2026-11-12-prestamos-transferencias-depuracion-design.md` (seccion 7) y el plan maestro `docs/superpowers/plans/2026-11-12-prestamos-transferencias-depuracion.md` (F4). Maqueta aprobada: `docs/superpowers/maquetas/2026-11-12-procesos-maqueta.html` (C1, C2, C3).

## Intencion

Reemplazar `UDepuracion` (pantalla vieja: conexion con credenciales embebidas, tabla `tb_depuracion` que copia documentos) por un proceso de cinco pasos como el de Transferencias: propuesta, autorizacion de la Comision, acta de eliminacion fisica, ejecucion y cierre. Es un acto con valor legal: nada se elimina sin autorizacion y sin dejar muestra, y los documentos NO se borran: quedan marcados como eliminados con la referencia del acta.

## Objetivos

- Proceso `D-AAAA-NN` sobre la base comun de F0 (`UProceso`, `UProcesosDatos`, `prc_*`): los pasos y condiciones de avance ya estan definidos para `tpDepuracion` (1 `cdSinBloqueos`; 2 `cdAutorizado`; 3 `cdMuestraDefinida`, `cdTestigosMinimos`, `cdActaCompleta`; 4 `cdConfirmacionEscrita`, `cdSinBloqueos`); se cancela hasta el paso 3.
- **Propuesta**: documentos que estan en un archivo de tipo Central o Historico, de subseries cuyo destino es *Eliminarlo (E)* (`cl_destino.IdDestino = 3`), con el plazo vencido en el central: la fecha de cierre de su transferencia (`prc_proceso.Cerrado` de la transferencia finalizada que lo incluyo) + `tcentral` anos; los documentos que ya estaban en el central antes del sistema (sin transferencia registrada) usan `fecha base + tgestion + tcentral` (fecha base = `FechaFin` si existe y no es anterior a `Fecha`, como en Transferencias); `tcentral = 0` o sin dato nunca se propone. Decidido por el usuario (la norma habla del tiempo que la serie *permanece* en cada tipo de archivo). Se excluyen los que retiene otro proceso (prestamo, transferencia abierta, otra depuracion: `prc_bloqueo`) y los ya eliminados.
- **Autorizacion**: acta y acuerdo de la Comision Nacional, Provincial o Municipal (`UAutorizacion`, ya valida que no sea la Central).
- **Acta** (paso 3, Anexo 19): por serie, unidades en numeros y letras, desglose por ano, fechas extremas, **muestra que se conserva** (descripcion y localizacion; obligatoria), lugar, via (incineracion o trituracion), fecha prevista y **testigos** (minimo 2: uno de la Comision y uno de un archivo de gestion; nombre y cargo).
- **Ejecucion** (paso 4): confirmacion reforzada (escribir `ELIMINAR`); revalida que nada este retenido; marca los documentos como eliminados con la referencia del acta (una sola transaccion).
- **Cierre** (paso 5): acta definitiva; solo se cierra cuando los ficheros digitales estan resueltos (ver entrega c).
- **Documento eliminado** = unidad activa de una depuracion ejecutada (`prc_proceso.Tipo = 'D'`, `Estado <> 'X'`, `Paso >= 5`, `prc_unidad.Activa <> 0`). No se toca `tb_SeriesDatos`, no hay columnas nuevas. Una consulta compartida (como `UTransferidos`) responde "esta eliminado y por que acta". Desde la ejecucion un eliminado queda en solo lectura: no se presta, no se edita, no se propone en transferencia ni en otra depuracion (mismas guardas que los transferidos).
- **Impreso**: Acta de eliminacion fisica (Anexo 19) en FastReport, con las rutinas comunes de `UImpresosComun`.
- **Pantallas**: C1 lista, C2 acta (formulario por secciones), C3 ejecucion; cada una con su `.dfm` (regla del proyecto), embebidas en el shell con `IPantallaProceso`.
- **Migracion/retiro**: `tb_depuracion` (600 filas en la base de pruebas, ninguna marcada `depurado`) se conserva sin tocar; si hubiera filas depuradas se reflejan como eliminadas con una referencia "migrada" y se informa de lo que no se pudo mapear (patron de `UPrestamosMigracion`). `UDepuracion` queda como respaldo detras de `procesos_clasico.flag` hasta F5 (como Prestamos y Transferencias), pero sin su contrasena embebida.

## Fuera de alcance

- Excluir eliminados de la busqueda, el arbol y los contadores y mostrar el historial en la ficha: es F5. F4 deja la consulta compartida y el indice listos.
- Depuracion de series con destino distinto de *Eliminarlo*; seleccion (S) o digitalizacion (D).
- Que el archivo central tenga nodo propio en el arbol (pregunta abierta desde F3).

## Antimetas (seria un fallo aunque funcione)

- Borrar filas de `tb_SeriesDatos` o de sus tablas de metadatos.
- Eliminar sin autorizacion cargada, sin muestra o con menos de dos testigos; ejecutar sin escribir `ELIMINAR`.
- Retirar un fichero digital antes de que la ejecucion se haya confirmado.
- Un cambio a medias: la ejecucion marca todo o nada.
- Credenciales en el codigo.

## Restricciones

Delphi 10.3, FireDAC, SQL valido en SQL Server y Access (sin `UPDATE ... FROM`; `EXISTS` correlacionado), codigo nuevo en ASCII, mensajes por `UMensajes`, pruebas DUnitX (las de base con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`, que no tiene series con `tcentral`/destino cargados: las pruebas siembran sus datos y los limpian), solo el EGD del nodo actua (`PuedeActuar`), nada de `TBotonShell`/controles del shell en los `.dfm`.

## Enfoques considerados

1. **Eliminado derivado de la depuracion ejecutada (elegido por el usuario).** Sin columnas nuevas, auditable, igual que "transferido". Costo: cada listado debe excluirlos con la consulta compartida (F5, con indice).
2. Columna `Eliminado` (y referencia) en `tb_SeriesDatos`: filtrar es mas barato pero hay que alterar la tabla mas grande en los dos motores y tocar ficha y guardados.
3. Copiar el documento a una tabla de evidencia y quitarlo de `tb_SeriesDatos`: borra filas y no se puede deshacer; contradice la regla.

Ficheros digitales (decidido por el usuario): la ejecucion solo marca; el retiro es un paso aparte con resultado por fichero y reintento.

## Datos nuevos (en `UEsquemaProcesos` + `SCRIPTS/procesos_tablas.sql`)

- `prc_depuracion` (IdProceso): `Lugar`, `Via` (I incineracion, T trituracion), `FPrevista`, `FEjecucion`, `MuestraDesc`, `MuestraDonde`.
- `prc_testigo` (IdTestigo, IdProceso): `Nombre`, `Cargo`, `Origen` (C Comision, G archivo de gestion, O otro), `Firmo`.
- `prc_fichero_retiro` (IdProceso + clave del documento + `idhijo`): `UrlRaiz`/`Path`/`Nombre` copiados de `tb_ssArchdigital` al ejecutar, `Estado` (P pendiente, R retirado, N ya no existia, L solo lectura -FTP-, M retirado a mano, E error), `Mensaje`, `Fecha`.
- `prc_unidad` y `prc_bloqueo` ya existen (candado por documento).

## Las tres entregas (cada una con plan, pruebas y commit propios)

**a) Datos y reglas (sin pantalla).** `UDepuracionReglas` (plazo en el central, desglose por ano, numero en letras en espanol, validacion de acta/muestra/testigos/via/lugar, texto `ELIMINAR`, textos de estado), `UDepuracionDatos` (proponer, crear, agregar/quitar grupo, autorizacion, acta y testigos, condiciones, avanzar, ejecutar, cancelar, eliminar, listados), esquema, `UEliminados` (consulta compartida, `EstaEliminado`, `ClavesEliminadas`; mismas guardas que `UTransferidos` en prestamo, edicion, transferencia y borrado), pruebas con datos sembrados.

**b) Pantallas e impreso.** `UDepuracionForm` + `.dfm` (C1, C2, C3), `rActaEliminacion.fr3`, `TMAIN.AbrirDepuracion` con respaldo a la pantalla vieja (`procesos_clasico.flag`, sin shell o si falla), verificacion con arnes de capturas a 100 % y 125 %.

**c) Retiro de ficheros y migracion.** `UDepuracionFicheros` (por cada fichero de `prc_fichero_retiro`, con `CrearAlmacen`/`IAlmacenFicheros`: `Existe`, `Borrar`; resultado por fichero; reintento de los que fallaron; FTP es de solo lectura y queda como `L` para retirarlo a mano y confirmarlo -> `M`), seccion en el paso 5, condicion de cierre (nada en `P` ni `E`; `L` solo cuenta como resuelto cuando se confirma `M`), migracion de `tb_depuracion`, retirada de la contrasena embebida de `UDepuracion`.

## Decisiones

Del usuario (2026-11-18):
- **Quien depura:** el EGD del nodo de origen depura lo que ya esta en un archivo Central o Historico. La regla "solo el archivo central depura" se aplica al tipo de archivo **del documento** (`tb_SeriesDatos.Archivo`; tras F3 apunta al central), no al nodo; los roles de `UAlcance` no cambian. Se revisara cuando el central tenga nodo propio.
- **Plazo en el central:** desde el cierre de su transferencia (ver Objetivos).
- Fuente de ficheros digitales: paso aparte con reintento (arriba).

Del autor del diseno (el usuario las dio por buenas):
- Se incluyen archivos Central e Historico (`PuedeIniciar` ya los admite); en una misma depuracion pueden mezclarse.
- Cada depuracion pertenece a **un** nodo (`prc_proceso.IdEstructura/IdNodo`), como Transferencias; la propuesta se limita a ese nodo.
- Un documento cuenta como eliminado desde la ejecucion (paso 4 -> 5), no desde el cierre. Si ademas fue transferido, el estado eliminado manda.
- El candado (`prc_bloqueo`) se toma al agregar el documento a la propuesta (paso 1), igual que en Transferencias.
- En las entregas a y b el paso 5 (cierre) no tiene condicion extra; la entrega c agrega la condicion `cdFicherosResueltos` a `UProceso`. Mientras haya ficheros pendientes el documento figura como eliminado, con una nota de retiro pendiente.
- La migracion de `tb_depuracion` es un informe sin cambios (la base de pruebas tiene 600 filas, ninguna depurada).

## Lo que queda al constructor

Nombres exactos de columnas y tipos, formato del numero de depuracion (sigue `UNumeracion`), disposicion de los controles en los `.dfm`, textos de mensajes, orden de las pruebas, como probar el retiro de ficheros (almacen simulado en las pruebas; sin servidor real).
