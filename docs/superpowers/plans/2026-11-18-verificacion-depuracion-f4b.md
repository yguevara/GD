# Verificacion de Depuracion F4b (pantallas y Acta de eliminacion)

La pantalla se vio solo con un arnes de capturas y datos de ejemplo (100 % y 125 %, tema claro); no con la base real ni con la impresora. Antes de probar a mano hacen falta:

- un archivo de tipo **Central** (Clasificadores > Archivos);
- una serie/subserie con destino final *Eliminarlo* y `tcentral` > 0;
- documentos de esa subserie dentro de ese archivo (por ejemplo, una transferencia cerrada) con el plazo del central ya vencido;
- un usuario EGD del nodo de origen y uno Administrador.

## Como EGD

1. Abrir **Depuracion** (se abre embebida). Debe verse la lista del ano.
2. *Nueva depuracion*, confirmar: se abre la ficha en el paso 1.
3. Con la propuesta vacia, el texto de la cuadricula explica por que (sin archivo Central, o nada vencido).
4. Marcar una serie y *Agregar*: pasa a «Ya agregado»; *Quitar* la devuelve.
5. *Pasar al siguiente paso*; registrar la autorizacion (organo, acta, acuerdo, fecha). Sin acta o acuerdo avisa lo que falta.
6. Paso 3: guardar el acta (lugar, via, fecha prevista), la muestra (descripcion y donde) y al menos 2 testigos, uno de la Comision y uno de un archivo de gestion; marcar su firma. «Lo que falta» pasa de rojo a verde.
7. *Imprimir acta*: revisar el Anexo 19 (totales en numeros y letras, desglose por ano, firmas).
8. *Pasar a ejecucion*. Paso 4: las cuatro comprobaciones en verde; escribir `eliminar` en minusculas -> el boton sigue desactivado; escribir `ELIMINAR` -> se activa; *Ejecutar eliminacion* y confirmar.
9. Paso 5: texto con la fecha, *Imprimir acta* (ahora dice «Eliminacion» y no «Fecha prevista»), *Cerrar la depuracion*.
10. Comprobar que los documentos eliminados ya no se pueden prestar, editar ni proponer de nuevo.
11. Cancelar una depuracion en el paso 1 a 3 libera los documentos; *Eliminar depuracion* la borra.

## Como Administrador (sin ser EGD)

Ningun boton actua: *Nueva depuracion*, *Agregar*, *Registrar autorizacion*, *Guardar acta*, testigos, *Ejecutar* y *Cerrar* explican que solo el EGD del nodo puede depurar.

## Respaldo

Con `procesos_clasico.flag` junto al exe, o sin la ventana principal nueva, o si la pantalla falla al abrirse (queda en `procesos_error.log`), se abre la pantalla vieja (`UDepuracion`).

## Pendiente (entrega c)

Retiro de ficheros digitales con reintento, migracion de `tb_depuracion` y retirada de `UDepuracion`.
