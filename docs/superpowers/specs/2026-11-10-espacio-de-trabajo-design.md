# Espacio de trabajo de documentos: diseno

Fecha: 2026-11-10. Estado: pendiente de aprobacion.
Origen: propuestas visuales B (listado grande) con el panel fijo de A (propiedades e historia a la derecha), elegidas por el usuario.

## Intencion

La pantalla principal sigue mostrando, junto al shell nuevo, el panel antiguo "CDC ACTIVO" (barra de registros, pestana "Series agregadas a la estructuda actual", rejilla cxGrid). Es un control de bases de datos que ocupa media pantalla para mostrar dos filas y no se puede modernizar con colores. Los paneles laterales son solo contenedores. El panel de propiedades, dibujado con etiquetas sueltas, recorta texto ("Sin eventos registrados") y deja restos al repintar.

El objetivo es una pantalla moderna y funcional: ver rapido que documentos hay en un nodo, filtrarlos, y leer sus propiedades e historia sin pasos extra.

## Disposicion (maqueta aprobada: artefacto "Propuestas ArchiGenio", B + panel fijo de A)

- Izquierda, "Mi area": arbol de la estructura (tvTree) con fuente legible y colores del tema. Debajo, bloque "Requiere accion" con contadores (prestamos vencidos, documentos sin ubicacion).
- Centro: cabecera con ruta ("Estructura > Inversiones") y nombre del nodo; barra con busqueda, filtro de serie, filtro de estado y boton Nuevo; tabla de documentos (codigo, titulo, serie, estado).
- Derecha, fija: propiedades e historia del documento elegido, siempre visibles. Sin boton de abrir/cerrar.
- Estilo del shell nuevo (tema "Arena y terracota" y oscuro) aplicado por codigo; no se edita el .dfm binario.

## Lo que se quita de la vista por defecto

- El panel "CDC ACTIVO" con su barra de registros y la pestana unica de series.
- La rejilla de series asignadas (GViewSeriesI): las series pasan a ser el filtro "Serie" de la barra, alimentado por los mismos datos.

## Lo que se conserva (decision del usuario)

Hoy el alta y la edicion de documentos se hacen desde la rejilla cxGrid2 de documentos y su navegador (dbnSeriesDatos). Eso no desaparece:
- La rejilla y su navegador quedan como **modo edicion**, alcanzable desde un boton de la barra ("Editar") y desde "Nuevo" (que abre la rejilla lista para insertar).
- El modo normal es la tabla nueva. El codigo ya tiene el conmutador (ListaDocsAlternar, "Ver lista"); se reutiliza.
- Cuando exista la carga nueva de documentos, el modo edicion podra retirarse. Fuera de alcance aqui.

## Metas, no metas, anti-metas

Metas: tabla real con estado; propiedades sin recortes ni superposicion; series como filtro; mismo criterio visual en las pantallas antiguas despues.
No metas: cambiar la carga de documentos, el modelo de datos, o el esquema de trazabilidad (F5). No se migra el .dfm de UMAINFORM.
Anti-metas: perder alta/edicion; que el filtro de series muestre datos distintos a los de hoy; un diseno que solo funcione en claro.

## Restricciones

- Delphi 10.3 VCL, DevExpress/TMS presentes; tests DUnitX solo para unidades sin VCL (los controles nuevos se prueban con las pruebas VCL ya existentes en Pruebas/UPruebasPanelDocumentos.pas).
- El dato manda desde UDM (tb_SeriesDatos, tabla de series asignadas); no se duplica la consulta.
- Codificacion Windows-1252 y CRLF en UMAINFORM.pas; unidades nuevas en ASCII.
- Sin shell_clasico.flag el comportamiento antiguo debe seguir disponible (ConectarShell solo corre con el shell activo).

## Decisiones mias (marcadas para revisar)

- El estado de cada fila (en archivo / prestado) sale de los prestamos ya cargados para la historia; si algun dato no existe se muestra vacio, no inventado.
- El bloque "Requiere accion" solo cuenta lo que ya se puede consultar sin cambiar el esquema; si un contador no es posible, no se muestra.
- Las propiedades pasan de etiquetas a un control de lista de propiedades (grupos plegables) dentro de un panel de ancho fijo ajustable.
- Orden de entrega: 1) propiedades y panel derecho, 2) tabla y barra, 3) series como filtro y ocultar CDC ACTIVO, 4) bloque "Requiere accion", 5) las demas pantallas antiguas.

## Pendiente para quien construya

Elegir el control concreto de la tabla y de las propiedades (TListView/virtual vs. TCustomControl dibujado), medir en DPI alto, y confirmar con el usuario que el filtro de series cubre su uso del navegador de registros.
