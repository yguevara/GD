# Panel lateral unico: diseno

Fecha: 2026-11-10. Estado: aprobado (propuesta 1 de la maqueta "Paneles laterales ArchiGenio").
Continua el diseno del espacio de trabajo (`2026-11-10-espacio-de-trabajo-design.md`).

## Intencion

Hoy hay tres pestanas verticales (advtpDetalle) que abren tres paneles que se excluyen entre si, cada uno con su rotulo y su navegador de registros: Subseries disponibles (advtpSSDispo), Detalles Subserie actual (advtpDetail) e Informacion complementaria (pArchivoDig). Se reunen en un solo panel fijo a la derecha con tres pestanas horizontales.

## Decisiones del usuario

- Propuesta 1: un panel con tres pestanas horizontales: Series, Detalle, Complementaria. Cabecera con el nombre de la subserie y su codigo. Desaparece la tira de pestanas verticales.
- Pestana activa por defecto: Detalle.

## Lo que se conserva

Las rejillas, navegadores, botones (asignar, exportar, ajustar columnas, filtrado rapido, ejecutar fuente, anadir, borrar) y sus eventos: los controles se mueven al panel nuevo sin recrearlos, asi que siguen ligados a los mismos datasets y manejadores. Complementaria conserva sus pestanas internas (Fuentes, Anexos digitales, Variables).

## No metas

Cambiar datos, consultas o permisos; recrear las rejillas; tocar el .dfm binario. No se rediseña el contenido de las rejillas, solo su contenedor y su ajuste de ancho.

## Anti-metas

Perder una accion que hoy esta en esos paneles; que un dataset deje de cargarse porque su panel "no esta visible"; romper el modo clasico (shell_clasico.flag).

## Decisiones mias (marcadas)

- Las teclas F10 (detalle), F11 o la que hoy abre Series y el boton btnViewPanel (archivo digital) pasan a activar la pestana correspondiente.
- El ancho inicial es de 380 px con separador movible.
- Si el usuario no usa algun boton a diario, no se quita: se conserva donde esta dentro de su pestana.
