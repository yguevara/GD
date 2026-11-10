# Lista de verificacion manual: espacio de trabajo de documentos

Se ejecuta con el exe recien compilado (`Win32\Debug\ArchiGenioPro.exe`) y con
la base de pruebas. Marcar cada caso y adjuntar captura de los que fallen.

Estado de la suite automatica al escribir esta lista: 316 pruebas, 0 fallos
(Access y SQL Server).

## Barra de trabajo y tabla

1. Nodo con varias series: una ficha por serie; la ficha de la serie actual va resaltada.
2. Pulsar otra ficha: cambia la serie y la tabla muestra sus documentos.
3. Nodo sin series: texto "Este nodo no tiene series asignadas", sin errores.
4. Filtro de texto: teclear parte de un codigo, un titulo o un expediente; la tabla se reduce tras una breve pausa.
5. Filtro sin resultados: "Ningun documento coincide" y las propiedades vuelven a "Elija un documento...".
6. Filtro de estado: "Prestado" deja solo los prestados; "En archivo" los demas.
7. Columna Estado: un documento con prestamo abierto dice "Prestado"; uno devuelto o con prestamo cancelado dice "En archivo".
8. "Editar": abre la rejilla con su navegador; el boton pasa a "Ver lista" y el filtro de la barra queda desactivado.
9. "Agregar documento" (cabecera del shell): abre la rejilla lista para insertar.
10. Con un documento a medio editar, pulsar otra ficha: avisa "Guarde o cancele el documento antes de cambiar de serie." y no cambia.

## Propiedades e historia

11. Titulo muy largo: se ve completo, sin recortes ni superposicion.
12. Documento sin historia: "Sin eventos registrados" se ve entero.
13. Documento con historia: 5 eventos y "Ver historia completa" abre el dialogo.
14. Cambiar de documento varias veces y redimensionar la ventana: no quedan restos de textos anteriores.
15. Letra grande o DPI 125 % y 150 %: sin recortes.

## Paneles

16. "CDC ACTIVO" y su rejilla de series no aparecen; F9 y el boton lateral no los muestran.
17. "Mi area": cabecera con los colores del tema (sin degradado azul).
18. Bloque "Requiere accion" bajo el arbol: cuentas de "Prestados ahora" y "Sin ubicacion"; pulsar "Prestados ahora" filtra la lista por Prestado; sin datos el bloque no aparece.
19. Paneles laterales de detalle (pestanas verticales): pendientes de decision (tarea 7).

## Otros

20. Tema oscuro de Windows: barra, tabla, propiedades y bloque legibles.
21. Con `shell_clasico.flag` junto al exe: la pantalla antigua sigue como antes (con "CDC ACTIVO").
22. Usuario con alcance limitado: las cuentas de "Requiere accion" y los estados solo incluyen documentos de su alcance.

## Notas

- "Prestados vencidos" no existe: la tabla de prestamos no guarda fecha limite.
- Las fichas de serie no muestran cantidad de documentos para no revelar documentos fuera del alcance.

## Panel del documento (pestanas)

23. Al elegir un documento, la cabecera del panel muestra codigo, titulo y estado (En archivo / Prestado).
24. Pestana Datos: codigo, titulo, fecha, version, tipo y expediente; ya no muestra la posicion fisica ni los ficheros.
25. Pestana Ubicacion: dos bloques, Subserie (servidor, archivo, deposito, gaveta) y Documento (con posicion); un tramo sin dato dice "Sin asignar" y el bloque avisa cuantos faltan.
26. Pestana Archivos: anexos digitales y fuentes en grupos, con extension, nombre y tamano; el titulo de la pestana lleva el numero de archivos; "Abrir contenido" y "Obtener expediente completo" siguen alli.
27. Pestana Metadatos: etiquetas y valores de las variables del documento; un valor vacio sale como guion; una subserie sin variables dice "Esta subserie no define metadatos".
28. Pestana Historia: los eventos y "Ver historia completa"; sin el rotulo HISTORIA repetido.
29. Pestana Contenido: no descarga nada al elegir el documento; al abrirla muestra el PDF; con otro documento y la pestana abierta, lo cambia.
30. Contenido de un documento sin PDF: dice el motivo ("no tiene ficheros digitales" o "solo admite PDF"), sin error.
31. "Mostrar aparte" saca el visor a una ventana; "Volver a la aplicacion" (o cerrar la ventana) lo devuelve; con la ventana aparte, elegir un documento sin PDF vuelve el visor a la aplicacion.
32. El visor no ofrece guardar, imprimir ni copiar (solo visualiza, como PDFExpressViewer.exe).
33. Cada vez que se muestra un contenido queda un registro de visualizacion del documento (administracion de log).
34. Al cerrar la aplicacion se borra la carpeta temporal `ArchiGenio_contenido_*` del directorio temporal.

## Arrastrar y soltar

35. Soltar 3 archivos y una carpeta sobre la lista de documentos de una subserie: se abre "Agregar documentos" con los candidatos (titulo desde el nombre del archivo, codigos consecutivos); no se crea nada hasta guardar.
36. Soltar sobre la lista sin subserie elegida, o sin permiso de agregar: aviso claro y no se abre la carga.
37. Pestana Archivos con un documento elegido y permiso: las dos zonas "Suelte aqui ... anexos digitales" y "... fuentes" resaltan al arrastrar encima; soltar agrega los ficheros, el contador de la pestana sube y la lista se actualiza.
38. Archivos repetidos o con el mismo nombre que los del documento: quedan como "nombre (2).ext", sin pisarse en el almacen.
39. Un archivo que no existe o falla la subida: se cuenta como fallido, los demas se agregan y el resumen lo dice; no queda fila ni objeto del fallido.
40. Sin permiso de editar: las zonas dicen que no hay permiso y no aceptan nada.
41. Pestana Contenido: soltar un PDF en un documento sin contenido lo pone y el visor lo muestra.
42. Soltar otro PDF sobre un documento que ya tiene contenido: pide confirmacion; al aceptar lo reemplaza; si se cancela no cambia nada.
43. Soltar un archivo que no es PDF, o varios archivos, sobre Contenido: aviso "solo admite un archivo PDF" / "Suelte un solo archivo PDF".
44. Cortar la red durante un reemplazo: el contenido anterior sigue intacto (fila y objeto).
45. Cada alta, anexo, fuente o reemplazo queda en la bitacora del documento.
46. Marcar un documento y pulsar Editar: se abre el formulario sobre el panel con sus valores (titulo, observaciones, expediente, subexpediente, visible, archivo, deposito, gaveta, servidor, posicion); el codigo, la fecha y la version no se pueden cambiar.
47. Cambiar el titulo y guardar: se cierra, la lista se recarga con el titulo nuevo y la bitacora registra la modificacion.
48. Marcar dos o mas documentos (Ctrl o Mayus) y pulsar Editar: los campos dicen "(sin cambios)", el boton dice "Aplicar a N"; solo cambia lo que se rellena (por ejemplo la gaveta) y el resto queda como estaba.
49. Con varios documentos, "Vaciar" en un campo lo deja vacio en todos; "Deshacer" lo revierte antes de guardar.
50. Titulo en blanco o demasiado largo, gaveta de mas de 20 caracteres, archivo no numerico: el error sale bajo el campo y no se guarda.
51. Un documento del lote falla (por ejemplo lo borro otro usuario): los demas se guardan y el resumen dice "Se guardaron N; M no se pudieron guardar".
52. Dos usuarios: A abre un documento, B cambia su titulo y guarda, A guarda otro titulo: A recibe "Otro usuario cambio titulo..." y no se pisa el cambio de B.
53. Sin permiso de editar: el boton avisa y no abre el formulario. Con permiso de editar pero sin el de topografia: la ubicacion queda deshabilitada y, en un lote, se avisa de lo omitido.
54. Eliminar... (solo con un documento): pide confirmacion, aplica las mismas reglas por rol y quita los ficheros; con varios marcados el boton no aparece.
55. Arrastrar archivos sobre la zona del formulario con varios documentos: una confirmacion, los archivos se agregan como anexos a cada documento y el resumen cuenta agregados y fallidos.
56. "Vista avanzada" abre la rejilla antigua; el boton de la barra pasa a "Ver lista" y vuelve a la lista.
57. Marcar varios y cambiar de subserie o filtrar: la seleccion que ya no se ve se limpia; las pestanas muestran "N documentos seleccionados" mientras haya mas de uno marcado.
