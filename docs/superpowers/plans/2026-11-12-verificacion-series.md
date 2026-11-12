# Verificación manual — Series y subseries (pantalla nueva)

Qué es: el clasificador "Series y subseries" dentro de la ventana principal (`UCLSeriesForm`), con el editor de variables del formulario (`UVariablesEditor`). Datos y reglas: `USeriesDatos`, `UVariablesDatos`, `UVariablesSesion` (con pruebas contra SQL Server; 633 pruebas en verde).

Estado: comprobada con capturas de la ventana (solo la de ArchiGenio, base SGDTEST_ALCANCE): lista de series, tabla de subseries, ficha, editor de variables bloqueado (014001) y libre (002). **No se probó guardar ni eliminar con clics** y **no se probó nada sobre Access** (no hay `.mdb` de pruebas). Abrir el clasificador: Gestión > Clasificadores > Series y subseries. Para volver a la pantalla vieja: archivo `clasificadores_clasico.flag` junto al exe.

## Series (índice de la izquierda)

- [ ] "Todas las series" y cada serie con su número de subseries; elegir una filtra la tabla.
- [ ] "+ Nueva" abre el mini-panel (código y nombre); guarda, rechaza código repetido y vacío.
- [ ] "Editar" (con una serie elegida) cambia el nombre; el código queda de solo lectura.
- [ ] "Eliminar" una serie con subseries avisa y no elimina; una serie vacía sí se elimina.

## Subseries (tabla y ficha)

- [ ] La columna "Formulario" muestra "N variables" y "con documentos" si ya tiene tabla de datos.
- [ ] Elegir una fila abre la ficha (pestañas Datos y Ubicación y almacenamiento; la de Datos se desplaza).
- [ ] "Nueva subserie": código editable, serie sugerida (la elegida), activa por defecto; rechaza código repetido o vacío y marca el campo.
- [ ] Editar y guardar cambia solo esos campos (vigencia, detalle y demás columnas de la fila no se tocan); la observación (texto enriquecido) se conserva.
- [ ] Eliminar una subserie con documentos / en el árbol / en transferencias o préstamos avisa y no elimina; una sin uso se elimina con sus variables.
- [ ] Cambiar de fila o cerrar con cambios sin guardar pregunta antes.

## Variables del formulario

- [ ] "Editar variables..." abre el editor a pantalla completa; "Volver a subseries" regresa (pregunta si hay cambios).
- [ ] Subserie SIN documentos (p. ej. 002): se puede agregar, quitar, renombrar, cambiar tipo/longitud y arrastrar para ordenar; la vista previa cambia al instante.
- [ ] Subserie CON documentos (p. ej. 014001): aviso amarillo; nombre, tipo, longitud y "Quitar" bloqueados en las existentes; se pueden agregar nuevas, reordenar y cambiar etiqueta/descripción/obligatoria.
- [ ] Guardar una variable nueva en una subserie con documentos pide confirmación y agrega la columna: luego aparece en la carga de un documento y en la búsqueda; los documentos viejos quedan vacíos en ese campo.
- [ ] Nombres rechazados con mensaje: palabra reservada, columna del sistema (Fecha, Version, id...), repetido, con espacios/acentos, empieza por número; "Caracteres" exige longitud.
- [ ] **Access** (pendiente, no probado): repetir alta de variable con documentos sobre una copia de una base Access.

## Seguridad y apariencia

- [ ] Los permisos del clasificador son los de siempre (el visor no llega a esta pantalla desde el menú).
- [ ] Tema claro y oscuro; 100 % y 125 % de escala; textos sin cortes.

## Lo que NO incluye (a propósito)

- Lista desplegable por variable (no hay columna en la base).
- Renombrar, cambiar tipo o quitar variables cuando la subserie ya tiene tabla de datos.
