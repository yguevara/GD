# Panel unico: el documento dentro del panel lateral (diseno)

Fecha: 2026-11-10. Opcion C elegida por el usuario en la maqueta "Panel unico ArchiGenio".

## Por que

La pantalla de documentos tiene tres bloques (lista, panel del documento a la derecha de la lista y panel lateral Series/Detalle/Complementaria). La lista queda en ~590 px de ~1450 y el espacio de trabajo se reduce. El usuario propone que el panel del documento sea una pestana mas del panel lateral.

## Diseno

- El panel lateral gana un primer nivel de pestanas con dos modos: **Subserie** (lo de hoy: Series, Detalle, Complementaria) y **Documento** (cabecera con codigo y estado, sus seis pestanas Datos, Ubicacion, Archivos, Metadatos, Historia, Contenido, y el formulario de edicion).
- El panel del documento (`TPanelDocumento`, con el formulario y las zonas de soltar) se **mueve entero** al modo Documento; no se reescribe. La lista de documentos queda sola, a todo el ancho que sobre.
- Marcar un documento activa el modo Documento. Elegir el modo Subserie (clic, F10/F11 para Detalle/Series) vuelve a lo de siempre. Editar y el boton "Abrir contenido" tambien activan Documento.
- El panel lateral pasa de 380 a 440 px (minimo 320) para que quepan las seis pestanas del documento.
- Sin panel lateral (modo de respaldo), el panel del documento se queda a la derecha de la lista como hoy.

## No objetivos

- No cambia ningun dato, permiso ni regla de edicion.
- No se recuerda el ancho entre sesiones (fuera de este alcance).

## Riesgos

- El visor de PDF y los receptores de arrastre dependen de su ventana: al moverse de padre deben seguir registrados (hay pruebas de ello en el plan).
- Con la pestana Contenido abierta y el modo Subserie activo, el contenido no debe descargarse en segundo plano sin verse.
