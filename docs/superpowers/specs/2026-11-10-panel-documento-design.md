# Panel del documento con pestanas: diseno

Fecha: 2026-11-10. Estado: aprobado el diseno (propuesta A de la maqueta "Panel de documento ArchiGenio"); pendiente de aprobar el plan.
Continua `2026-11-10-espacio-de-trabajo-design.md` y `2026-11-10-panel-lateral-design.md`.

## Intencion

La informacion de un documento esta repartida en tres sitios: las propiedades junto a la tabla, la rejilla del modo Editar (pestanas Fuentes, Anexos, Variables) y el panel lateral Complementaria. Se reune todo lo que describe al DOCUMENTO en un panel con pestanas junto a la tabla, y el panel lateral queda solo con lo que describe a la SUBSERIE (Series, Detalle, definicion de variables).

## Orden de los proyectos (acordado con el usuario)

1. Este: panel del documento con pestanas y contenido.
2. Despues: rediseno del modo Editar con arrastrar y soltar (drag and drop) para todo.
3. Despues: expedientes y documentos georreferenciados.

## Decisiones del usuario

- Pestanas del panel del documento: Datos, Ubicacion, Archivos, Metadatos, Historia y Contenido.
- Contenido: muestra el documento dentro de la aplicacion y se puede sacar a una ventana aparte.
- Ubicacion (topografia): trata las dos, la de la subserie y la del documento.
- Modo lista: los anexos del documento se muestran solo de consulta, como un todo.
- La rejilla del modo Editar se conserva tal cual (sus pestanas Fuentes, Anexos y Variables) hasta el proyecto 2.

## Decision mia (a confirmar): formato del contenido

El contenido incrustado sigue siendo solo PDF. Razones: es la convencion de la primera version, ExpressPDFViewer (DevExpress) ya esta instalado y es lo que usa PDFExpressViewer.exe, y un unico formato permite aplicar los mismos permisos (guardar, imprimir, copiar) por rol. Los demas formatos (DOCX de fuentes, imagenes, TIF) siguen en la pestana Archivos y se abren con su aplicacion. Un formato nuevo (por ejemplo imagenes) se anade despues sin cambiar el panel.

## Metas, no metas, anti-metas

Metas: toda la informacion del documento en un solo panel; Contenido incrustado y separable; ubicacion de subserie y de documento visibles; consulta de anexos en modo lista.
No metas: cambiar el modelo de datos, el almacen de ficheros o la carga; tocar el modo Editar (proyecto 2); expedientes y geo (proyecto 3).
Anti-metas: que el contenido incrustado permita guardar o imprimir a quien no tiene permiso; perder la auditoria (cada visualizacion sigue registrandose con `ACCION_VISUALIZAR`); que mostrar el contenido descargue archivos pesados sin que el usuario lo pida.

## Restricciones

- Delphi 10.3 VCL; ExpressPDFViewer (`dxPDFViewer`) ya instalado; el contenido se obtiene con `IAlmacenFicheros.Descargar` a un archivo temporal que se borra al cerrar.
- Controles creados por codigo, sin tocar el .dfm de UMAINFORM.
- La logica pura (que grupos van en cada pestana, tramos de ubicacion) en `UDocumentoVista`, sin VCL, con pruebas DUnitX.
- Unidades nuevas en ASCII.

## Decisiones mias (marcadas)

- El panel del documento reutiliza la tira de pestanas de `UPanelLateral`.
- Contenido solo se descarga al abrir su pestana (no al seleccionar el documento) y se guarda en cache por documento durante la sesion.
- "Anexos" son los ficheros de `tb_ssArchdigital` que no son fuentes; "Fuentes" los marcados como fuente. Se muestran en dos grupos.
