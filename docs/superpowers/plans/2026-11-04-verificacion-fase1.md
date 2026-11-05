# Verificación manual de la Fase 1: shell de la variante A (Tarea 3)

Plan: `2026-11-04-fase1-base-visual.md`, Tarea 3. Pendiente de ejecutar por una persona con la aplicación real: el shell es interfaz y no tiene pruebas automáticas. La Tarea 4 ampliará esta lista con los casos del ámbito de la búsqueda.

## Qué cambia y qué no

- Con el shell activo: columna de secciones a la izquierda (Inicio, Archivo, Traslados, Préstamos y, abajo, Gestión), el árbol a unos 270 px con el rótulo «Mi area», y una cabecera sobre el área de trabajo con la ruta y el nombre del nodo elegido, el buscador, «Agregar documento» y el usuario.
- La barra antigua de botones (`pMainContainer`) queda **oculta**, con sus botones dentro y sin cambios de nombre, `OnClick` ni visibilidad: el código por rol (`adminOptions`, `GestorOptions`, `VisorOptions`, `ArchiveroOpts`) los sigue gobernando. El menú **Gestión** se arma al abrirse con los botones que en ese momento están visibles.
- «Buscar documentos» desaparece del menú Herramientas: lo sustituye el buscador de la cabecera.
- Con `shell_clasico.flag` junto al ejecutable no se aplica nada: pantalla clásica como antes (con «Buscar documentos» en Herramientas).

## Preparación

1. Base de pruebas `SGDTEST_ALCANCE` en el `config.ini` de una **copia** del ejecutable. **No usar `SGDDRHMAIN`.** Para el modo Access, una **copia** de `BD\SDbd.mdb`, nunca el original.
2. Usuarios de `2026-10-29-verificacion-alcance.md` y uno por rol: **Administrador** (`administrador`), **Gestor**, **Director** (p. ej. `egd_a43` si es su rol) y **Visor** (sin sesión = Invitado/visor, o un usuario con rol visor). Anotar en cada caso el usuario usado.
3. Antes de empezar, con la versión anterior (o con `shell_clasico.flag`), anotar por rol qué botones de la barra antigua se ven. Es la referencia de los casos 10 a 13.

## Casos

| # | Usuario / entorno | Qué hacer | Resultado esperado | Registrado |
|---|---|---|---|---|
| 1 | Cualquiera, **con** `shell_clasico.flag` junto al `.exe` | Abrir la aplicación | Pantalla clásica idéntica a la anterior: barra de botones arriba, árbol de 300 px con «CUADRO DE CLASIFICACIÓN», sin columna ni cabecera nuevas; Herramientas incluye «Buscar documentos» | |
| 2 | Igual que 1 | Iniciar sesión como administrador y usar cada botón de la barra | Todo funciona como antes | |
| 3 | Cualquiera, **sin** el archivo | Abrir la aplicación | Columna azul de 58 px a la izquierda; árbol a ~270 px rotulado «Mi area»; cabecera blanca sobre el área de trabajo con buscador, «Agregar documento» y el chip «Invitado - Visor»; la barra antigua no se ve | |
| 4 | Sin el archivo | Elegir nodos del árbol | La cabecera muestra la ruta (ancestros separados por «>») y el nombre del nodo; sin nodo: «Elija un nodo en el arbol» | |
| 5 | Sin el archivo | Mover el separador del árbol, ocultar/mostrar el árbol con F8, plegar el panel del árbol, restaurar y maximizar la ventana | La cabecera acompaña siempre al área de trabajo: no tapa el árbol ni deja hueco; el contenido no queda debajo de la cabecera | |
| 6 | Sin el archivo | Clic en el chip del usuario | Igual que el antiguo botón de autenticar: pide usuario o, si hay sesión, ofrece cerrarla. Tras iniciar sesión el chip muestra «usuario - rol» en menos de un segundo | |
| 7 | Sin el archivo | Clic en Inicio y en Archivo | Muestra el árbol (si estaba oculto con F8) y le da el foco; el botón pulsado queda marcado | |
| 8 | Administrador | Abrir **Gestión** | Aparecen: Iniciar o cerrar sesión, Localizar documentos y subseries, Administración de usuarios, Listas de códigos (submenú), Impresiones y reportes (submenú), Administrar cuadro de clasificación, Herramientas administrativas (submenú), Ayuda del sistema (submenú) y Salir del sistema. «Mostrar paneles ocultos» solo si su botón estaba visible | |
| 9 | Administrador | Ejecutar **cada** entrada de Gestión y de sus submenús | Cada una hace lo mismo que su botón o ítem antiguo (mismos formularios, mismos mensajes, mismo registro en el log). Herramientas **no** tiene «Buscar documentos» | |
| 10 | Administrador | Comparar Gestión con la referencia de la Preparación 3 | Mismos botones disponibles que en la barra antigua | |
| 11 | Gestor | Ídem | Solo los visibles para el gestor (p. ej. Impresiones y reportes, sesión, localizar, ayuda, salir); **no** usuarios, listas, cuadro de clasificación ni herramientas | |
| 12 | Director | Ídem | Igual que en la barra antigua para el director | |
| 13 | Visor / Invitado | Ídem | Solo sesión, localizar, ayuda y salir (lo que antes se veía) | |
| 14 | Cada rol | Mirar la columna | **Préstamos** solo aparece si el rol veía Herramientas (administrador) y el ítem Préstamos de ese menú; **Traslados** solo si además el ítem «Tranferencias» está visible (hoy está oculto en el `.dfm`, así que no debería aparecer para nadie) | |
| 15 | Administrador | Clic en Préstamos | Se abre lo mismo que Herramientas → Préstamos en la pantalla clásica | |
| 16 | Administrador | Cerrar sesión desde el chip | La columna y el menú Gestión se ajustan al rol visor sin reiniciar | |
| 17 | Usuario con permiso de agregar | Elegir nodo y subserie; pulsar **Agregar documento** | Se crea un documento nuevo en esa subserie, igual que con el botón «+» del navegador de documentos (mismas validaciones de topografía y mensajes) | |
| 18 | Igual | Pulsar «Agregar documento» sin nodo elegido o sin subserie | Mensaje «Elija en el arbol el nodo y la subserie donde agregar el documento.»; no se crea nada | |
| 19 | Visor, o usuario sin permiso de agregar en esa subserie | Pulsar «Agregar documento» | Mensaje «No tiene permiso para agregar documentos en esta subserie.»; no se crea nada | |
| 20 | Administrador | Escribir `acta` en el buscador y pulsar Intro | Se abre «Buscar documentos» con `acta` ya escrito y los resultados cargados (dentro del alcance del usuario) | |
| 21 | Igual | Clic en la lupa con el buscador vacío | Se abre la pantalla de búsqueda vacía, sin buscar | |
| 22 | Igual | Escape en el buscador | Borra el texto | |
| 23 | Usuario sin asignaciones | Buscar un texto | Solo resultados públicos o de su alcance (mismo comportamiento que la pantalla de búsqueda existente) | |
| 24 | Pantalla **1366x768** al 100 % | Revisar la ventana maximizada con cada rol | Columna, árbol y cabecera no se solapan; los textos largos de la ruta y el título terminan en «…» | |
| 25 | **1366x768 con escala de Windows al 125 %** | Ídem | No hay solapes; si falta sitio el buscador se achica (mín. ~160 px) y el usuario, y luego «Agregar documento», quedan solo con su icono (el texto aparece en la ayuda emergente) | |
| 26 | Monitor con otra escala (si hay dos) | Pasar la ventana de un monitor a otro | La columna, la cabecera y los iconos se reescalan sin quedar cortados | |
| 27 | Windows en **tema claro** (Configuración → Personalización → Colores → modo de aplicación claro) | Abrir la aplicación | Columna en azul `#1d5fa6` con iconos y textos blancos; cabecera blanca con texto oscuro | |
| 28 | Windows en **tema oscuro** | Abrir la aplicación | Columna en azul claro `#6aa8ea` con iconos y textos oscuros; cabecera oscura (`#1a232c`) con texto claro y buscador legible. Los controles DevExpress conservan su aspecto | |
| 29 | Cualquiera | Abrir y cerrar la aplicación varias veces; cerrar desde Gestión → Salir | Sin errores al cerrar ni procesos colgados | |
| 30 | Modo Access (copia del `.mdb`) | Repetir 3, 8, 17 y 20 | Igual que en SQL Server (en Access no hay alcance: se ve todo) | |
| 31 | Administrador y `egd_a43` | Ambito «Todo el archivo»; buscar `acta` | Resultados de todo su alcance; columna «Acceso» con Publica/Restringida/Secreta; columna «Nodo» con la ruta como texto | |
| 32 | `usr_sub` (una subserie) y usuario sin asignaciones | Ambito «Todo el archivo» | Solo su subserie / solo lo publico; lo que cae fuera de su alcance sale con «Acceso» = Publica | |
| 33 | `egd_a43` | Elegir un nodo propio; en la cabecera elegir «Solo en <nodo>» y buscar | Solo documentos de ese nodo y sus descendientes; la pantalla muestra «Solo en <ruta>» seleccionado | |
| 34 | `egd_a43` | Elegir un nodo ajeno; «Solo en <nodo>» | Solo lo publico de ese nodo y sus descendientes | |
| 35 | Cualquiera | Sin nodo elegido, elegir «Solo en el nodo actual» y buscar | Aviso «Elija un nodo en el arbol para buscar en el nodo actual.»; no se abre la busqueda general | |
| 36 | Cualquiera | Dentro de la pantalla de busqueda abierta en general, elegir «Solo en ...» sin nodo | Aviso y vuelve a «Todo el archivo» | |
| 37 | Cualquiera | Elegir «Solo en el nodo actual», cerrar, buscar de nuevo | El ambito elegido se recuerda durante la sesion | |
| 38 | Cualquiera | Doble clic en un resultado cuyo nodo se ve en el arbol | Se cierra la busqueda, el arbol selecciona y expande el nodo y el area de trabajo carga igual que con un clic | |
| 38b | Cualquiera | Doble clic en un resultado publico de un nodo que el arbol no muestra | Muestra codigo, titulo, subserie, ruta del nodo y acceso; el arbol no cambia | |
| 39 | Modo Access | Ambitos general y nodo actual | Funciona igual (sin alcance: se ve todo) | |
| 40 | 1366x768 al 125 % | Revisar la cabecera con el selector de ambito | Sin solapes; el buscador se achica antes que el titulo | |
| 41 | Administrador | Mirar la columna | Arriba: Inicio, Archivo, Clasificad., Cuadro, Traslados, Prestamos, Depuracion, Indices. Abajo: Usuarios, Config. y Gestion. Todos con icono y texto completo | |
| 42 | Administrador | Clasificad. | Menu con Archivos, Servidores (FTP) y Series y Subseries Documentales; cada uno abre lo mismo que en la pantalla clasica | |
| 43 | Administrador | Cuadro, Traslados, Depuracion, Indices, Usuarios | Abren Administrar cuadro de clasificacion, Transferencias, Depuracion, Gestion de indices y Administracion de usuarios | |
| 44 | Administrador | Config. | Menu con Configuracion del sistema, Cambiar Base de Datos y Logs del sistema | |
| 45 | Gestor, Director y Visor/Invitado | Mirar la columna | Solo ven las secciones que su rol veia en la barra antigua; ninguno ve Clasificad., Cuadro, Traslados, Depuracion, Indices, Usuarios ni Config. si antes no veia esos botones | |
| 46 | Cualquiera | Abrir Ayuda -> Acerca de | Cabecera con el nombre, version 2.x con la compilacion de siempre, edicion, logo de EMSERGO S.R.L. y derechos reservados; claro y oscuro | |
| 47 | Cualquiera | Propiedades del .exe -> Detalles | Version de archivo 2.0.9299.15405, empresa EMSERGO S.R.L | |
| 48 | Cualquiera | Arrancar la aplicacion | La barra del splash avanza por pasos (configuracion, base de datos, interfaz, listo) y el texto de estado cambia | |
| 49 | Cualquiera | Mirar el arbol del cuadro de clasificacion | Iconos Tabler: edificio (entidad), etiqueta (unidad), carpeta (nodo), jerarquia, etc.; los nodos invisibles (si se muestran) en gris. Mismos significados que antes | |
| 50 | Cualquiera | Mirar el pie de la columna | Gestion y, debajo, Acerca de, siempre visibles; Acerca de abre el mismo cuadro que Ayuda -> Acerca de | |
| 51 | Administrador | Menu Gestion, Clasificad. y Config. | Todas las entradas llevan su icono | |

## Resultado

Anotar fecha, persona, versión del ejecutable y, por cada caso, «OK» o la descripción del fallo con captura. Ante cualquier fallo grave en un cliente, crear `shell_clasico.flag` junto al ejecutable para volver a la pantalla clásica.
