# Verificacion de Depuracion F4c (retiro de ficheros, migracion, contrasena)

Lo comprobado automaticamente (SQL Server `SGDTEST_ALCANCE`, almacen simulado): copia de los ficheros al ejecutar, retiro por fichero con resultado y reintento, solo lectura -> confirmacion manual, cierre bloqueado con ficheros sin resolver, migracion de `tb_depuracion` idempotente. **No se ha probado contra un servidor S3 ni FTP real, ni con la pantalla sobre la base real** (solo capturas con datos de ejemplo, 100 % y 125 %, tema claro).

## A mano (antes: una depuracion ejecutada, en el paso 5, con documentos que tengan ficheros digitales)

1. En el paso 5, la seccion «Ficheros digitales» lista los ficheros de lo eliminado, todos «Pendiente»; *Cerrar la depuracion* esta desactivado.
2. *Retirar ficheros* (confirmar): con S3 los ficheros pasan a «Retirado» y el objeto desaparece del bucket; uno que ya no existia sale «Ya no existia».
3. Apagar el servidor S3 y repetir con otro documento: el fichero queda «Error» con el motivo y los demas siguen; volver a encender y *Reintentar los que fallaron*.
4. Un fichero en servidor FTP queda «Solo lectura»: retirarlo a mano en el servidor, elegirlo y *Confirmar retiro a mano* -> «Retirado a mano».
5. Con todo resuelto se activa *Cerrar la depuracion*; antes, intentar cerrar (por otra sesion) avisa que quedan ficheros.
6. Como Administrador (sin ser EGD): ningun boton de ficheros actua.
7. Una depuracion cuyos documentos no tienen ficheros se cierra sin pasos extra.

## Migracion de `tb_depuracion`

Al arrancar en SQL Server se crea un proceso finalizado por fecha de depuracion y nodo con las filas `depurado = 1` y destino *Eliminarlo*; esos documentos figuran como eliminados (solo lectura). Las filas depuradas con otro destino no se migran. El resumen y los avisos van a `procesos_error.log`. La tabla vieja no se toca. La base de pruebas no tiene filas depuradas: revisar con una base real.

## Contrasena embebida

Se quito de `UDepuracion` el metodo sin uso `InsertConnection`. El usuario SQL `geoconn` sigue escrito en otras unidades (`UCapaDatos`, `UMAINFORM`, `UCLFtpServer`, `UCLSeriesDocumentales`): es el acceso de toda la aplicacion y queda para otra entrega.
