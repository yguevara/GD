# Verificacion manual de la F2: lista de documentos y propiedades

Plan: `2026-11-05-lista-documentos-f2.md`. Pendiente de ejecutar por una persona con la aplicacion real: la lista es interfaz y solo su logica (`UDocumentoVista`, `UDocumentoVistaDatos`) tiene pruebas automaticas (176 en verde, con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y una copia del `.mdb`).

## Que cambia y que no

- Al elegir un nodo y una subserie, los documentos se muestran en una **lista** (codigo, titulo, fecha, tipo, ficheros, insignia geo) con un **panel de propiedades** a la derecha. La rejilla de siempre sigue disponible con el boton **Ver rejilla** (arriba a la derecha de la lista) y se vuelve con **Ver lista**.
- Un clic en un documento muestra sus propiedades; doble clic o Intro abre el contenido (el mismo «Abrir» del menu de ficheros, `PDFExpressViewer.exe`).
- Alta y edicion de documentos siguen haciendose en la rejilla hasta la F3: el boton **Agregar documento** del shell pasa solo a la rejilla.
- Con `shell_clasico.flag` junto al ejecutable no hay lista: rejilla como antes. Si la lista falla al crearse, queda la rejilla y el motivo en `lista_error.log` junto al ejecutable.

## Preparacion

1. Copia del ejecutable con `config.ini` hacia `SGDTEST_ALCANCE` (**no** `SGDDRHMAIN`). Para Access, una **copia** de `BD\SDbd.mdb`.
2. Usuarios de `2026-10-29-verificacion-alcance.md`: administrador, un EGD (`egd_a43`), un usuario con una subserie (`usr_sub`), un usuario sin asignaciones y un visor/Invitado.
3. En el nodo A.4.3 hay las subseries `014001` (expedientes de planeamiento, restringida) y `074` (proyectos, publica, 1299 documentos); documentos de `074` apuntan a expedientes `P-001`... en `014001` mediante `IDExpediente`.

## Casos

| # | Usuario / entorno | Que hacer | Resultado esperado | Registrado |
|---|---|---|---|---|
| 1 | Invitado | Elegir A.4.3 y la subserie Proyectos | Lista con «Proyectos - 1299 documentos», icono de documento, panel vacio con «Elija un documento para ver sus propiedades» y «Abrir contenido» deshabilitado | |
| 2 | Igual | Un clic en un documento | Panel: General (codigo, titulo, fecha dd/mm/aaaa, version, tipo, «Pertenece al expediente»), Posicion fisica (p. ej. «Archivo 2 > Deposito 01 > Gaveta 02 > Posicion 3»), Ficheros | |
| 3 | Administrador | Elegir la subserie de expedientes `014001` | Los expedientes con **icono distinto** (carpeta abierta) y tipo «Expediente»; el panel dice «Contiene N documentos» | |
| 4 | Administrador | En un expediente, «Mostrar solo este expediente» | La lista queda con el expediente y los documentos que lo referencian (mismo nodo); aviso «Solo el expediente ... y sus documentos»; «Mostrar todos» la restablece | |
| 5 | `usr_sub` / sin asignaciones | Mismo expediente | El contador «Contiene N» solo cuenta los documentos que ese usuario puede ver | |
| 6 | Cualquiera | Doble clic en un documento con fichero; Intro | Se abre el contenido en el visor, igual que «Abrir» en la rejilla | |
| 7 | Cualquiera | Documento sin ficheros | «Sin ficheros» y «Abrir contenido» deshabilitado | |
| 8 | Cualquiera | Documento con fuentes (si existe) | Cada fuente en una fila «Fuente: nombre (tamano)»; en la lista «n + m fuente» | |
| 9 | Cualquiera | Documento con coordenadas en `tb_DocCoord` o fichero `shp`/`dxf`/`kml`/`geojson`/`dwg`/`gpkg` | Icono de mapa (si es mapa) y insignia de globo en la ultima columna; en el panel «Georreferenciado: Si» | |
| 10 | Cualquiera | Documento `tif` sin coordenadas | Icono de documento normal (un escaneo no es mapa) | |
| 11 | Cualquiera | Subserie sin documentos | Texto «Esta subserie aun no tiene documentos»; panel sin error | |
| 12 | Cualquiera | Ver rejilla / Ver lista | La rejilla de siempre reaparece con su barra «Ver lista»; al volver, la lista se recarga | |
| 13 | Usuario con permiso de agregar | «Agregar documento» del shell estando en la lista | Pasa a la rejilla y crea el registro como antes; al volver a la lista aparece el documento nuevo | |
| 14 | Cualquiera | Cambiar de subserie y de nodo varias veces seguidas | La lista siempre muestra la subserie elegida, sin parpadeos ni mensajes | |
| 15 | Cualquiera | Subserie `074` (1299 documentos) | Carga sin congelar la ventana; el desplazamiento es fluido | |
| 16 | Visor | Clic y doble clic | Lista de solo lectura; «Abrir» igual que antes para ese rol | |
| 17 | Con `shell_clasico.flag` | Abrir una subserie | Rejilla de siempre, sin lista | |
| 18 | 1366x768 al 125 % | Revisar la lista y el panel | Sin solapes; el panel se puede ensanchar con el separador | |
| 19 | Windows en tema oscuro | Abrir una subserie | Lista y panel con colores oscuros legibles; iconos blancos | |
| 20 | Modo Access (copia del `.mdb`) | Repetir 1, 2, 4 y 6 | Igual que en SQL Server (sin alcance: se ve todo) | |

## Resultado

Anotar fecha, persona, version del ejecutable y, por cada caso, «OK» o la descripcion del fallo con captura. Ante un fallo grave, crear `shell_clasico.flag` junto al ejecutable para volver a la rejilla.
