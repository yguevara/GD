# Verificacion de Depuracion F4a (datos y reglas)

Esta entrega no tiene pantalla: nada que probar a mano todavia. Lo comprobado automaticamente (SQL Server, `SGDTEST_ALCANCE`):

- Plazo en el central (desde el cierre de la transferencia o desde la fecha del documento), destino *Eliminarlo*, solo documentos en archivo Central; exclusion de retenidos, prestamos viejos abiertos y ya eliminados.
- Recorrido de los pasos 1 a 3 (autorizacion de la Comision que no sea la Central, acta, muestra y al menos 2 testigos de origen distinto) y ejecucion con `ELIMINAR` revalidando todo en una transaccion, sin tocar las filas de `tb_SeriesDatos`.
- Un documento eliminado no se presta, no se edita y no se vuelve a proponer.

Pendiente para las entregas b y c: pantallas C1 a C3 y Acta (Anexo 19); retiro de ficheros digitales con reintento; migracion y retiro de `UDepuracion`.
