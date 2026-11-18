# Verificacion manual de Transferencias F3 (recepcion, ubicacion y traspaso)

Cierre y reabra ArchiGenio antes de probar (el exe se recompila). Usuario `egd` / `admin` (EGD de A.4.3/104) o `administrador` para ver que NO puede actuar.
Base de pruebas: `SGDTEST_ALCANCE`. Transferencia T-2026-02 (IdProceso 9) esta en el paso 5.

Lo automatico ya cubierto: 863 pruebas (SQL Server) de reglas, datos, cierre atomico y documentos transferidos. Lo que NO se ha visto con la base real es la pantalla, el impreso en papel y el flujo completo de punta a punta: eso es lo de esta lista.

## Antes de empezar

- [ ] En Clasificadores > Archivos hay al menos un archivo de tipo **Central** (hoy solo hay de Gestion: crearlo si falta). Si no hay ninguno, el desplegable de la recepcion lo dice.
- [ ] Hacer copia de la base si se quiere repetir la prueba (el cierre de la transferencia cambia documentos).

## Paso 5: recepcion

- [ ] Abrir Transferencias > T-2026-02. Se ve la lista de cajas con estado **Pendiente**.
- [ ] Marcar una caja y escribir su estado de conservacion; pulsar **Recibida**: el estado y la conservacion se ven en la lista.
- [ ] Marcar otra y pulsar **Cuarentena**; **Resolver cuarentena** la devuelve a Recibida (solo esta activo con cuarentena).
- [ ] Marcar otra como **No llego**: pide confirmacion, queda *Faltante*, y ya no deja cambiarla.
- [ ] Intentar **Registrar la recepcion** con cajas pendientes o en cuarentena: avisa, no avanza.
- [ ] Sin elegir archivo central, o sin numero de registro de entrada: avisa.
- [ ] Con todo decidido, archivo central, registro y quien recibe: pasa al paso 6.
- [ ] Una caja faltante: sus documentos siguen en el archivo de origen y se pueden volver a proponer.

## Paso 6: ubicacion y cierre

- [ ] Cada caja recibida: deposito, gaveta y posicion; **Guardar la ubicacion** la muestra en la lista (Dep. / Gav. / Pos.).
- [ ] Gaveta de mas de 20 caracteres o posicion de mas de 10: avisa.
- [ ] **Finalizar la transferencia** con una caja sin ubicar: avisa cual.
- [ ] **Imprimir registro topografico**: sale el Anexo 18 con una fila por caja recibida (copiar la carpeta `Report` junto al exe si falta `rRegistroTopografico.fr3`).
- [ ] Finalizar con todo ubicado (pide confirmacion, no se deshace).

## Despues del cierre

- [ ] Un documento de una caja recibida tiene ahora el archivo central, deposito, gaveta y posicion de su caja (ficha del documento).
- [ ] En la lista de documentos del origen aparece **Transferido**; no se puede agregar a un prestamo (dice a que archivo fue); editar su titulo lo omite y avisa.
- [ ] No vuelve a proponerse en una nueva transferencia.
- [ ] El Administrador abre la pantalla y los botones de accion no estan o responden explicando por que.
- [ ] La lista de transferencias la muestra finalizada.

## Cosas que no se resolvieron (a decidir)

- Filtro «Transferido» en la barra de la lista de documentos.
- Los botones de la ficha del documento siguen visibles aunque el guardado se omita.
- Plazo de reclamacion de incidencias (30 dias provisional).
- `errores_inesperados.log` con `EAccessViolation` en `TVisorContenido` en cada sesion (pendiente de la sesion anterior).
