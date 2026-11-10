# Modo Editar: formulario de documento y edicion por lotes

Fecha: 2026-11-10. Estado: propuesta C elegida por el usuario; pendiente de aprobar el plan.
Maqueta: "Modo Editar ArchiGenio" (propuesta C). Tarea 7 del plan de arrastrar y soltar.

## Intencion

Quitar la rejilla de 16 columnas y su navegador de registros como forma de editar. "Editar" abre un formulario que se desliza sobre el panel del documento, con los campos agrupados. Si hay varias filas marcadas, el mismo formulario cambia solo los campos que se rellenen (el resto queda "sin cambios").

## Lo que ya esta decidido

- Un solo formulario para uno o para varios documentos (propuesta C).
- Los documentos se marcan en la lista (seleccion multiple); el formulario dice "Editar N documentos".
- Altas: siguen siendo "Agregar documento" y soltar archivos sobre la lista (ya existen).
- Anexos y contenido por arrastre: siguen en sus pestanas; el formulario por lotes puede recibir archivos para agregarlos a todos los marcados.

## Lo que se puede editar y lo que no (decision mia, por el esquema de datos)

- **No editables**: Codigo, Fecha y Version. Son parte de la clave de `tb_SeriesDatos`; las tablas de metadatos (`md_*`) y la bitacora se enlazan por esa misma clave sin llave foranea con cascada, y `tb_DocCoord` tiene una llave foranea sin accion: cambiarlas dejaria datos huerfanos o fallaria. Una nueva version sera otra funcion.
- **Editables**: Titulo (obligatorio, hasta 255), Observaciones, Gestor, Expediente (IDExpediente) y subexpediente, Visible, y la topografia del documento (Archivo, Deposito, Gaveta, Servidor, Posicion; solo con permiso de editar topografia).
- **Metadatos** de la subserie: solo al editar un documento (no por lotes); se validan con las reglas de `UMetadatosSubserie`.
- **Eliminar**: desde el formulario de un solo documento, con confirmacion y el mismo camino de hoy (permiso por rol y por dias; borra los ficheros del almacen). La "Recuperacion" sigue siendo el modulo externo `ArchiRec.exe`; no se toca.

## Permisos

Editar exige `acEditar` en el nodo y la subserie; los campos de ubicacion exigen ademas `acEditarTopografia`. Sin permiso el boton "Editar" no se ofrece. Con alcance (SQL Server) decide `UAlcance`; en Access, la regla por rol de hoy.

## Metas, no metas, anti-metas

Metas: editar uno o muchos documentos sin rejilla; validar con mensajes al lado del campo; nada a medias (por lotes, todo o nada por documento y un resumen).
No metas: cambiar claves; versionar; tocar el modulo de recuperacion; rediseñar el alta.
Anti-metas: que una edicion por lotes pise campos no rellenados; perder la bitacora (cada cambio queda registrado por documento).

## Decisiones mias (marcadas)

- La rejilla antigua queda un tiempo como "Vista avanzada" (menu), no como boton principal, hasta que el formulario este verificado; despues se retira.
- Por lotes, la topografia solo se aplica a documentos que el usuario puede editar; los demas se omiten y el resumen lo dice.
- Un campo por lotes con valor vacio explicito se pone con un boton "Vaciar" (por defecto vacio = sin cambios).
