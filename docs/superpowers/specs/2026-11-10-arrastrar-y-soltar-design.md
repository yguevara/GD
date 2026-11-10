# Arrastrar y soltar archivos: diseno

Fecha: 2026-11-10. Estado: pendiente de aprobar. Proyecto 2 del orden acordado (despues del panel del documento).

## Intencion

Dar de alta y completar documentos arrastrando archivos desde el Explorador, en tres sitios. El rediseno visual de la rejilla del modo Editar se agrega como tarea 7 del plan (primero maqueta y aprobacion, despues codigo); hasta entonces la rejilla y su navegador siguen como estan.

## Lo que pidio el usuario

1. **Lista de documentos**: soltar archivos o una carpeta para dar de alta documentos por lotes. La aplicacion toma de cada archivo el titulo (nombre del archivo) y genera las llaves (codigo consecutivo, fecha, version, etc.); el usuario solo completa lo que falta.
2. **Pestana Archivos**: soltar archivos sobre un documento para anadirlos como anexos digitales o como fuentes.
3. **Pestana Contenido**: soltar un PDF para ponerle o reemplazarle el contenido (el PDF principal).
4. Metadatos y ubicacion: no aplican.

## Lo que ya existe (se reutiliza)

- `UPantallaCarga` (modal "Agregar documentos"): ya acepta archivos y carpetas soltados dentro de su ventana, arma un candidato por archivo (`UCargaModelo`: `TituloDesdeNombre`, `CodigosParaLote`, `ExpandirRutas`) y guarda con `UCargaLote`/`UCargaDocumento` (almacen, filas de `tb_ssArchdigital`, bitacora y deshacer si falla).
- `IAlmacenFicheros`, `AlmacenParaFichero`, `TProgresoTransferencia`, permisos en `UAlcance` (`acAgregar`, `acEditar`).

## Decisiones del diseno

- **Lista** (1): soltar sobre la lista abre la pantalla "Agregar documentos" ya cargada con las rutas soltadas, para la subserie actual. No se crea nada sin que el usuario la confirme (ve los candidatos, completa y guarda). Requiere permiso de agregar en el nodo y subserie; sin el, un aviso y no se abre.
- **Archivos** (2): al arrastrar sobre la pestana aparecen dos zonas, "Soltar como anexo digital" y "Soltar como fuente". Guarda con una unidad nueva sin VCL (`UAgregarFicheros`) que sube al almacen, inserta las filas y registra la bitacora; si algo falla deshace lo subido. Requiere permiso de editar.
- **Contenido** (3): solo acepta un PDF. Si el documento ya tiene PDF principal, pide confirmacion ("Reemplazar el contenido actual?") y, al aceptar, borra el anterior (almacen y fila) y sube el nuevo en una operacion que se deshace si falla. El "PDF principal" es el primer anexo digital en PDF, igual que el visor.
- **Mecanismo**: un receptor de arrastre por OLE (`IDropTarget`) permite saber cuando se entra y se sale sobre un control (para mostrar las zonas), no solo cuando se suelta.
- Todo registra bitacora (alta, anexo agregado, contenido reemplazado) y respeta el alcance.

## Metas, no metas, anti-metas

Metas: altas por lote arrastrando; anexos, fuentes y contenido arrastrando; confirmacion antes de reemplazar; nada se guarda a medias.
No metas: rediseñar la rejilla antes de aprobar su maqueta (tarea 7); arrastrar entre aplicaciones que no sean el Explorador; arrastrar documentos entre subseries; metadatos y ubicacion.
Anti-metas: crear documentos sin que el usuario vea y confirme los candidatos; reemplazar contenido sin confirmar; perder el PDF anterior si falla la subida del nuevo.

## Restricciones

- Delphi 10.3 VCL; la logica de guardado sin VCL ni `UDM` (solo RTL + FireDAC), valida en SQL Server y Access, con pruebas DUnitX usando el almacen en memoria ya existente.
- Controles por codigo; unidades nuevas en ASCII; documentacion en espanol.
- Sin `shell_clasico.flag`: el comportamiento nuevo solo con el shell nuevo.

## Decisiones mias (marcadas)

- Una subida de varios archivos es una operacion por archivo con resumen final (como `UCargaLote`), no todo o nada: un archivo que falla no impide los demas, pero cada archivo se deshace por completo si falla.
- Los archivos fuente aceptan cualquier formato; los anexos digitales tambien (el contenido incrustado sigue siendo solo PDF).
- Tamano maximo por archivo: el del almacen; no se agrega un limite nuevo.
