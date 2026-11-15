# Transferencias F3: recepcion, ubicacion por caja y traspaso de los documentos

Fecha: 2026-11-15. Completa los pasos 5 y 6 de `2026-11-12-prestamos-transferencias-depuracion-design.md` (seccion 6).
Sustituye a la "version minima" (quien recibe + fecha, ubicacion en texto libre).

## Decisiones del usuario (2026-11-15)

1. **Regla de fondo:** al cerrar la transferencia NO queda ningun documento en el archivo de origen; solo queda el acta (la relacion de entrega y el registro de la transferencia). La topografia completa del documento cambia.
2. **Destino:** lo elige quien recibe en el paso 5, entre los archivos de tipo *Central* (`cl_ArchivosGestion` con `Tipo` = Central). Si no existe ninguno, la recepcion se bloquea y avisa que hay que crearlo en el clasificador Archivos.
3. **En el origen:** el documento sigue en el arbol de su nodo, marcado como *transferido* (conserva `IdEstructura`, `id`, `codsubs` y su ficha), con `Archivo` = el central. El EGD de origen lo ve en solo lectura: no presta, no edita, no transfiere ni depura.
4. **Ubicacion:** por caja. En el paso 6 se ubica cada caja (deposito, gaveta, posicion; Anexo 18) y los documentos de la caja heredan esa ubicacion mas el numero de caja.

## Modelo de datos

Columnas de ubicacion que ya tiene cada documento (`tb_SeriesDatos`): `Archivo` (smallint, codigo de `cl_ArchivosGestion`), `deposito`, `gaveta`, `posicion`, `Idservidor`.

- `prc_transferencia`: se agregan `IdArchivoDestino` (smallint) y `NumRegistroEntrada` (Anexo 17, texto).
- `prc_caja`: se agregan `Deposito`, `Gaveta`, `Posicion` (texto, como en `tb_SeriesDatos`), `Estado` (normal / cuarentena), `Conservacion` (texto) y `Recibida` (bit) para la comparacion con la relacion.
- Nueva `prc_incidencia` (IdProceso, IdCaja nulo, Tipo, Descripcion, FechaLimite, Estado, Usuario, Fecha): faltas y daños detectados en la recepcion.
- Marca de *transferido* de un documento: se deduce de `prc_unidad` + `prc_transferencia` finalizada (no se agrega columna a `tb_SeriesDatos`). Una consulta compartida (como `UPrestadosSql`) responde "este documento esta transferido y a donde".

## Pasos

**5 Recepcion** (la hace quien recibe en el archivo central):
- elige el archivo destino (obligatorio), registra el n.o de registro general de entrada (Anexo 17) y la fecha;
- por caja: marca *recibida*, estado de conservacion; humedad u hongo => *cuarentena* (no se ubica hasta resolverla);
- lo que falte frente a la relacion genera una *incidencia* con plazo de reclamacion;
- avanza al paso 6 solo si todas las cajas estan recibidas o tienen incidencia, y hay archivo destino.

**6 Ubicacion** (Anexo 18):
- cada caja recibida y no en cuarentena recibe deposito, gaveta y posicion (`UTopografia` valida que no esten vacios);
- al cerrar, en UNA transaccion: para cada documento de cada caja, `Archivo` = destino, `deposito`/`gaveta`/`posicion` = los de su caja; se libera `prc_bloqueo`; la transferencia pasa a finalizada. Si algo falla, no cambia nada.
- las cajas en cuarentena no impiden cerrar: sus documentos se traspasan al resolver la cuarentena (queda como lista pendiente en la ficha).

## Reglas sin VCL (con pruebas)

- `UTransferenciasReglas`: validar recepcion (destino elegido, registro de entrada, todas las cajas decididas), validar ubicacion por caja, que cajas pueden cerrar.
- `UTransferenciasDatos`: `RegistrarRecepcionCaja`, `RegistrarUbicacionCaja`, `CerrarTransferencia` (la transaccion de arriba), `ListarArchivosCentrales`, consulta de transferido.
- Los documentos transferidos se excluyen de las acciones de origen en `UAlcance`/`PuedeActuar` (prestar, editar, transferir, depurar desde gestion).

## Pantalla

Se amplian los pasos 5 y 6 de `UTransferenciasForm` + `.dfm` (regla: toda interfaz nueva lleva .dfm): cuadricula de cajas con estado, y un panel por paso. Impreso nuevo: Registro topografico (Anexo 18) en FastReport (`UImpresosComun`).

## Fuera de F3

Migrar `tb_transferencia` y retirar `UTransferencias`/`UProgresoTransferencia` (F3b). Transferencia central -> historico. Depuracion (F4).

## Pendiente de confirmar al implementar

- Como se ven los documentos transferidos en las busquedas y el arbol del origen (insignia "Transferido" o solo texto).
- Si el archivo central, ademas, debe aparecer en un nodo propio del arbol (hoy el documento no cambia de nodo).
