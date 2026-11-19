# Verificacion de Transferencias F3b (informe de tb_transferencia y pantallas viejas retiradas)

Comprobado automaticamente (SQL Server `SGDTEST_ALCANCE`): el informe cuenta ejecutadas y sin ejecutar y no escribe. El proyecto compila sin `UTransferencias`, `frmTransferencia` ni el dataset `tb_transferencia`. No se ha abierto la ventana principal con la base real.

## A mano

1. Abrir **Transferencias** por el menu, por el atajo `I4` y por la seccion del shell: los tres abren la pantalla nueva (embebida con shell).
2. Con `shell_clasico.flag` o `procesos_clasico.flag` junto al exe: la pantalla nueva se abre como ventana modal y se puede cerrar con la X.
3. Arrancar una base con filas en `tb_transferencia`: en `procesos_error.log` aparece un resumen (ejecutadas y sin ejecutar) y las lineas sin ejecutar; la tabla queda igual.
4. Arrancar con una base sin esa tabla (o vacia): no hay aviso ni error.
5. Subir, descargar y exportar un expediente siguen mostrando su dialogo de progreso (`UProgresoTransferencia` se conserva).
6. Al abrir un nodo sin permisos o forzar un fallo, se muestra un mensaje de error (no se abre ninguna pantalla vieja).
