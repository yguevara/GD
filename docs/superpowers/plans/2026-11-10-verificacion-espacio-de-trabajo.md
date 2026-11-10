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
