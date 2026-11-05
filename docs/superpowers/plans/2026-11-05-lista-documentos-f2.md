# F2: Lista de documentos y panel de propiedades - Plan de implementacion

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que la subserie muestre sus documentos en una lista clara (icono distinto para documento, expediente y mapa o georreferenciado) con un panel de propiedades a un clic y el contenido a doble clic, en lugar de la rejilla `cxGrid`, que queda disponible como vista alternativa mientras no exista la carga nueva (F3).

**Architecture:** Dos unidades sin VCL, probables desde `Pruebas/` (`UDocumentoVista`: clasificacion, texto de posicion, propiedades, filtro por expediente; `UDocumentoVistaDatos`: indicadores por documento con una consulta agrupada por tema y el filtro de alcance). Una unidad de pantalla hecha por codigo, sin `.dfm` (`UPanelDocumentos`: lista + panel de propiedades, sin acceso a datos). Un enlace delgado en `UMAINFORM.pas` que alimenta el panel desde el dataset que la rejilla ya usa (`UDM.tb_SeriesDatos`), de modo que lo que se lista es exactamente lo que hoy ve el usuario.

**Tech Stack:** Delphi 10.3, VCL, FireDAC (`MSSQL` / `MSAcc`), DUnitX, iconos Tabler (`UIconos`). Reutiliza `UAlcance`/`UAlcanceDatos` (`FiltroDocumentos`, `AplicarParametros`), `UTema`, `UShellPrincipal`.

**Spec:** `docs/superpowers/specs/2026-11-05-documentos-carga-consulta-geo-trazabilidad-design.md`, secciones 3.2 (lista y propiedades) y 3.4 (clasificacion geo y mapa), y la fase F2 de la seccion 7. Maquetas aprobadas: `.superpowers/brainstorm/838-1793891670/content/carga-y-consulta.html` (pantalla 2).

## Global Constraints

- Funciona en SQL Server y en Access; todo SQL nuevo vale en ambos (sin sintaxis exclusiva de un motor).
- Toda consulta que cuente documentos ajenos al listado (hijos de un expediente) incluye `FiltroDocumentos(Alcance, '<alias>')`; `Alcance = nil` (Access) o administrador da `1=1`. Nada del usuario se concatena en el SQL: todo va como parametro, las fechas con tipo `ftDateTime`.
- Las claves del documento son `IdEstructura, id, codsubs, Fecha, Version, Codigodoc`.
- `tb_ssArchdigital.fuente`: `'N'` = fichero digital del documento, `'S'` = fichero fuente.
- Formatos de mapa (confirmados): `tif`, `tiff` (solo si el documento tiene coordenadas), `shp`, `kml`, `geojson`, `dwg`, `dxf`, `gpkg`. Un documento es georreferenciado si `tb_DocCoord` tiene al menos un vertice.
- Un documento es expediente si otros documentos lo referencian en `IDExpediente` (con el mismo `IdEstructura`) o si esta marcado como tal; la marca llega con la F3, en la F2 siempre es falsa.
- Para abrir el contenido se reutiliza `TMAIN.MenuItem5Click` ("Abrir": ejecuta `PDFExpressViewer.exe` con `codsubs` y `codigodoc` del registro actual de `UDM.tb_SeriesDatos`). Ningun permiso nuevo: abre quien hoy puede abrir.
- Unidades nuevas (`UDocumentoVista`, `UDocumentoVistaDatos`, `UPanelDocumentos`, pruebas): ASCII puro (sin tildes), CRLF; agregarlas a `ArchiGenioPro.dpr` y las de prueba a `Pruebas/PruebasArchiGenio.dpr`. `UDocumentoVista` y `UDocumentoVistaDatos` sin VCL ni `UDM`.
- No editar `UMAINFORM.dfm`; todo control nuevo se crea por codigo. `UMAINFORM.pas` tiene ruido de fin de linea en el arbol de trabajo: para subir solo lo propio, `git diff --ignore-space-at-eol -- UMAINFORM.pas > parche` y `git apply --cached --ignore-whitespace parche`.
- Con `shell_clasico.flag` junto al ejecutable nada cambia: queda la rejilla de siempre.
- Pruebas con base real se omiten si faltan `ARCHIGENIO_TEST_DB` (SQL Server, base `SGDTEST_ALCANCE`) o `ARCHIGENIO_TEST_MDB` (copia de `.mdb`, nunca el original), con datos sembrados dentro de una transaccion que se deshace, como en `UPruebasAlcanceDatos.pas`. **No usar `SGDDRHMAIN`.**
- Commits por nombre de archivo y solo con autorizacion del dueno.

## Review Focus

- Un documento cuyo `IDExpediente` apunta a un codigo que no existe: se lista como documento normal, sin error (Tareas 1 y 3).
- Un expediente con hijos fuera del alcance del usuario: el contador solo cuenta los que ese usuario puede ver (Tarea 3).
- Subserie sin documentos: la lista muestra un texto guia ("Esta subserie aun no tiene documentos") y el panel de propiedades queda en blanco, sin error (Tarea 4).
- Documento sin ficheros o sin ubicacion fisica: el panel dice "Sin ficheros" y "Sin ubicacion asignada" y el boton "Abrir contenido" queda deshabilitado si no hay fichero (Tareas 2 y 4).
- Subserie con miles de documentos: la lista es virtual (`OwnerData`) y los indicadores se cargan una vez por subserie, no por fila; cargar 3000 documentos no congela la ventana (Tarea 4).

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `UDocumentoVista.pas` (nuevo) | Tipos del documento para la vista, clasificacion (documento / expediente / mapa / geo), formatos de mapa, texto de posicion, tamano legible, lista de propiedades, filtro por expediente. Sin VCL ni datos |
| `UDocumentoVistaDatos.pas` (nuevo) | `CargarIndicadores`: hijos por expediente (con alcance), vertices geo y ficheros por documento de una subserie, en 3 consultas agrupadas |
| `UPanelDocumentos.pas` (nuevo) | `TPanelDocumentos`: lista (`TListView` virtual) + panel de propiedades + barra superior (conteo, filtro de expediente, boton Rejilla/Lista). Eventos, sin datos |
| `UIconos.pas`, `Iconos.rc`, `Iconos.res`, `Iconos/*.png`, `Iconos/blanco/*.png` | Iconos `documento`, `expediente`, `mapa`, `georreferenciado` |
| `UMAINFORM.pas` | `ConectarListaDocumentos`: crea el panel dentro de `PSeriesDatos`, enlace con `UDM.dstb_SeriesDatos` (`TDataLink`), selecciona y abre |
| `Pruebas/UPruebasDocumentoVista.pas`, `Pruebas/UPruebasDocumentoVistaDatos.pas` (nuevos) | Pruebas DUnitX |
| `docs/superpowers/plans/2026-11-05-verificacion-f2.md` (nuevo) | Lista manual de verificacion |

### Task 1: Clasificacion del documento (`UDocumentoVista`, parte 1)

**Files:**
- Create: `UDocumentoVista.pas`, `Pruebas/UPruebasDocumentoVista.pas`
- Modify: `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr` (registrar las unidades)

**Interfaces:**
- Produces (en `UDocumentoVista`):
  - `TTipoDocumento = (tdDocumento, tdExpediente)`.
  - `TClaveDocumento = record IdEstructura: string; Id: Integer; CodSubs: string; Fecha: TDateTime; Version: string; Codigodoc: string; end`.
  - `TFicheroDoc = record Nombre: string; Extension: string; Tamano: Double; EsFuente: Boolean; end`.
  - `TDatosDocumento = record Clave: TClaveDocumento; Titulo, IdExpediente, SubExp, Servidor, Archivo, Deposito, Gaveta, Posicion, Observaciones, ExtPrincipal: string; NumHijos, NumVerticesGeo, NumFicheros, NumFuentes: Integer; MarcadoExpediente: Boolean; end`.
  - `TClaseDocumento = record Tipo: TTipoDocumento; EsGeo: Boolean; EsMapa: Boolean; end`.
  - `function ExtensionNormal(const Ext: string): string` (sin punto, minusculas, sin espacios).
  - `function EsFormatoMapa(const Ext: string): Boolean` (true para `shp, kml, geojson, dwg, dxf, gpkg, tif, tiff`).
  - `function EsFormatoAmbiguo(const Ext: string): Boolean` (true solo para `tif, tiff`).
  - `function ClasificarDocumento(const D: TDatosDocumento): TClaseDocumento`.
  - `function NombreIconoDocumento(const C: TClaseDocumento): string` devuelve `'expediente'`, `'mapa'` o `'documento'`.
  - `function NombreInsigniaGeo(const C: TClaseDocumento): string` devuelve `'georreferenciado'` si `EsGeo` o `EsMapa`, si no `''`.

- [ ] **Step 1: Escribir las pruebas que fallan** en `TPruebasDocumentoVista` (`Pruebas/UPruebasDocumentoVista.pas`, sin base de datos):
  - `ExtensionNormal_QuitaPuntoYMayusculas`: `ExtensionNormal(' .GeoJSON ') = 'geojson'`, `ExtensionNormal('') = ''`.
  - `EsFormatoMapa_ListaConfirmada`: verdadero para `shp, kml, geojson, dwg, dxf, gpkg, tif, tiff` (cualquier capitalizacion y con punto); falso para `pdf, docx, jpg, png, ''`.
  - `EsFormatoAmbiguo_SoloTif`: verdadero para `tif`, `.TIFF`; falso para `shp`, `dxf`.
  - `Clasificar_ConHijos_EsExpediente`: `NumHijos = 2` -> `Tipo = tdExpediente`; `NumHijos = 0` y `MarcadoExpediente = False` -> `tdDocumento`; `NumHijos = 0` y `MarcadoExpediente = True` -> `tdExpediente` (expediente vacio cuenta).
  - `Clasificar_Geo_PorVertices`: `NumVerticesGeo = 3` -> `EsGeo`; `0` -> no.
  - `Clasificar_Mapa`: `ExtPrincipal = 'shp'` sin vertices -> `EsMapa` y no `EsGeo`; `ExtPrincipal = 'tif'` sin vertices -> no `EsMapa` (escaneo normal); `ExtPrincipal = 'tif'` con 3 vertices -> `EsMapa` y `EsGeo`; `ExtPrincipal = 'pdf'` con 3 vertices -> `EsGeo` pero no `EsMapa`.
  - `NombreIcono_Prioridad`: expediente con vertices -> `'expediente'` y su insignia `'georreferenciado'`; documento `dxf` -> `'mapa'`; documento `pdf` -> `'documento'` y insignia `''`.
- [ ] **Step 2: Compilar y ejecutar.** `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y `Pruebas\Win32\Debug\PruebasArchiGenio.exe`. Esperado: no compila (falta `UDocumentoVista`).
- [ ] **Step 3: Implementar `UDocumentoVista.pas`** con los tipos y funciones de arriba. `ClasificarDocumento`: `Tipo = tdExpediente` si `NumHijos > 0` o `MarcadoExpediente`; `EsGeo = NumVerticesGeo > 0`; `EsMapa` verdadero si `EsFormatoMapa(ExtPrincipal)` y (no ambiguo o `EsGeo`).
- [ ] **Step 4: Ejecutar la suite completa.** Esperado: las 149 pruebas anteriores mas las nuevas, todas en verde.
- [ ] **Step 5: Commit por nombre** (`UDocumentoVista.pas`, `Pruebas/UPruebasDocumentoVista.pas`, ambos `.dpr`), con autorizacion.

### Task 2: Posicion, tamano y propiedades (`UDocumentoVista`, parte 2)

**Files:**
- Modify: `UDocumentoVista.pas`, `Pruebas/UPruebasDocumentoVista.pas`

**Interfaces:**
- Consumes: los tipos de la Tarea 1.
- Produces:
  - `TPropiedad = record Grupo: string; Etiqueta: string; Valor: string; end`.
  - `function TextoPosicion(const D: TDatosDocumento): string`: une, en este orden y separadas por `' > '`, las partes no vacias `Servidor`, `Archivo`, `Deposito`, `Gaveta`, `Posicion` con su rotulo (`'Servidor X'`, `'Archivo X'`, `'Deposito X'`, `'Gaveta X'`, `'Posicion X'`); si no hay ninguna, `'Sin ubicacion asignada'`.
  - `function FormatoTamano(Bytes: Double): string`: `'512 B'`, `'1.5 KB'`, `'1.2 MB'`, `'3.0 GB'` (base 1024, un decimal, punto decimal siempre, sin depender del idioma de Windows); negativo o NaN -> `'-'`.
  - `function ConstruirPropiedades(const D: TDatosDocumento; const Ficheros: TArray<TFicheroDoc>): TArray<TPropiedad>`.
  - `function FiltrarPorExpediente(const Docs: TArray<TDatosDocumento>; const Codigo: string): TArray<TDatosDocumento>`.

- [ ] **Step 1: Escribir las pruebas que fallan:**
  - `TextoPosicion_Completa`: `Servidor='SRV1', Archivo='A2', Deposito='D2', Gaveta='14', Posicion='3'` -> `'Servidor SRV1 > Archivo A2 > Deposito D2 > Gaveta 14 > Posicion 3'`.
  - `TextoPosicion_Parcial_OmiteVacios`: solo `Deposito='D2'` y `Gaveta='14'` -> `'Deposito D2 > Gaveta 14'`.
  - `TextoPosicion_Vacia`: todo vacio (o solo espacios) -> `'Sin ubicacion asignada'`.
  - `FormatoTamano_Unidades`: `512 -> '512 B'`, `1536 -> '1.5 KB'`, `1258291 -> '1.2 MB'`, `3221225472 -> '3.0 GB'`, `-1 -> '-'`.
  - `Propiedades_General`: para un documento con `Codigodoc='EXP-0103'`, `Titulo='Acta 103'`, `Fecha = 05/11/2026`, `Version='2'`, la lista contiene `('General','Codigo','EXP-0103')`, `('General','Titulo','Acta 103')`, `('General','Fecha','05/11/2026')`, `('General','Version','2')` y `('General','Tipo','Documento')`; con `NumHijos=2` el tipo es `'Expediente'` y aparece `('Expediente','Contiene','2 documentos')` (singular `'1 documento'`); con `ExtPrincipal='shp'` el tipo es `'Mapa'`; un documento no mapa con vertices muestra `('General','Georreferenciado','Si')`.
  - `Propiedades_ExpedienteYSubexp`: con `IdExpediente='EXP-0001'` y `SubExp='S1'` aparecen `('General','Pertenece al expediente','EXP-0001')` y `('General','Subexpediente','S1')`; vacios, no aparecen.
  - `Propiedades_Posicion`: siempre una fila `('Posicion fisica','Ubicacion', TextoPosicion(D))`.
  - `Propiedades_Ficheros`: sin ficheros -> una fila `('Ficheros','Ficheros','Sin ficheros')`; con un digital `acta.pdf` de 1258291 bytes y una fuente `acta.docx` de 512 -> filas `('Ficheros','Fichero','acta.pdf (1.2 MB)')` y `('Ficheros','Fuente','acta.docx (512 B)')`.
  - `FiltrarPorExpediente`: con documentos `EXP-1` (el expediente), `A` y `B` (con `IdExpediente='EXP-1'`) y `C` (con `IdExpediente='EXP-2'`): el filtro `'EXP-1'` devuelve `EXP-1`, `A`, `B` (el expediente y sus hijos), insensible a mayusculas y espacios; filtro `''` devuelve todos; codigo inexistente devuelve arreglo vacio.
- [ ] **Step 2: Compilar y ejecutar.** Esperado: no compila (faltan las funciones).
- [ ] **Step 3: Implementar** las cuatro funciones y `TPropiedad` en `UDocumentoVista.pas`. La fecha se formatea `dd/mm/yyyy` con `FormatDateTime` y un `TFormatSettings` fijo para no depender de la configuracion regional. El orden de los grupos es General, Expediente, Posicion fisica, Ficheros.
- [ ] **Step 4: Ejecutar la suite completa.** Esperado: todo en verde.
- [ ] **Step 5: Commit por nombre**, con autorizacion.

### Task 3: Indicadores por documento con alcance (`UDocumentoVistaDatos`)

**Files:**
- Create: `UDocumentoVistaDatos.pas`, `Pruebas/UPruebasDocumentoVistaDatos.pas`
- Modify: `ArchiGenioPro.dpr`, `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Consumes: `TClaveDocumento` (Tarea 1); `TAlcanceUsuario` (`UAlcance`); `FiltroDocumentos`, `AplicarParametros` (`UAlcanceDatos`).
- Produces (en `UDocumentoVistaDatos`):
  - `TIndicadoresDoc = record NumHijos, NumVerticesGeo, NumFicheros, NumFuentes: Integer; ExtPrincipal: string; end`.
  - `function ClaveTexto(const C: TClaveDocumento): string`: `IdEstructura|Id|CodSubs|yyyymmddhhnnss|Version|Codigodoc` (recortada y en minusculas).
  - `function CargarIndicadores(Conn: TFDConnection; Alcance: TAlcanceUsuario; const IdEstructura: string; Id: Integer; const CodSubs: string): TDictionary<string, TIndicadoresDoc>`. El que llama libera el diccionario. Las claves son `ClaveTexto` de los documentos de esa subserie; un documento sin ningun indicador no tiene entrada (quien consulta usa `TryGetValue` y toma ceros).

- [ ] **Step 1: Escribir las pruebas que fallan** en `TPruebasDocumentoVistaDatosSql` (con `ARCHIGENIO_TEST_DB`, sembrando con `TEscenario.Sembrar` de `UPruebasAlcanceDatos` y filas propias dentro de la transaccion) y `TPruebasDocumentoVistaDatosAccess` (con `ARCHIGENIO_TEST_MDB`, sin alcance, misma bateria). Documentos de `014001` en `A.4.3/104` (`PALC-*`, `Fecha 2026-10-29`, `Version '1'`):
  - `Hijos_CuentaLosQueApuntanAlExpediente`: se asigna `IDExpediente = 'EXP-PRUEBA'` a 3 documentos de `A.4.3/104` y un cuarto documento tiene `Codigodoc = 'EXP-PRUEBA'`; `NumHijos` de ese cuarto es 3 (administrador).
  - `Hijos_SoloLosVisiblesParaElUsuario` (solo SQL Server): uno de los 3 hijos esta en `A.4.6/160` (fuera de la cobertura de `prueba_alc_usr1`, que solo cubre `014001` en `A.4.3/104`); para `prueba_alc_usr1` `NumHijos = 2`, para `administrador` `3`.
  - `Hijos_ExpedienteInexistente_NoFalla`: un documento con `IDExpediente = 'NO-EXISTE'` no genera error ni entrada de expediente.
  - `Geo_CuentaVertices`: 3 filas en `tb_DocCoord` para un documento (`idVertice` 1..3, `x`, `y` cualesquiera) -> `NumVerticesGeo = 3`; otro documento sin filas -> sin entrada o `0`.
  - `Ficheros_DigitalesYFuentes`: 2 filas `tb_ssArchdigital` con `fuente='N'` (`extnombre` `'pdf'` y `'pdf'`) y 1 con `fuente='S'` (`'docx'`) para un documento -> `NumFicheros = 2`, `NumFuentes = 1`, `ExtPrincipal = 'pdf'`.
  - `Fecha_ConDiaMayorQueDoce`: la clave se arma bien con `Fecha = 2026-01-31` (no se confunde mes y dia).
  - `ClaveTexto_NoDependeDeMayusculasNiEspacios`: sin base de datos.
  - `AlcanceNil_EsTodo` (Access y SQL): `Alcance = nil` no filtra.
- [ ] **Step 2: Compilar y ejecutar** con las dos variables de entorno. Esperado: no compila. Con una base o ruta inexistente las pruebas con base fallan (no se omiten por error).
- [ ] **Step 3: Implementar `UDocumentoVistaDatos.pas`:** tres consultas parametrizadas, una por tema, y se juntan en el diccionario. (a) Hijos: `SELECT H.IDExpediente AS Cod, COUNT(*) AS N FROM tb_SeriesDatos H WHERE H.IdEstructura = :est AND H.IDExpediente IS NOT NULL AND H.IDExpediente <> '' AND <FiltroDocumentos(Alcance,'H').Condicion> GROUP BY H.IDExpediente`; el resultado se asigna a cada documento de la subserie cuyo `Codigodoc` coincide (sin distinguir mayusculas). (b) Geo: `SELECT Fecha, Version, Codigodoc, COUNT(*) FROM tb_DocCoord WHERE IdEstructura=:est AND id=:id AND codsubs=:cs GROUP BY Fecha, Version, Codigodoc`. (c) Ficheros: `SELECT Fecha, Version, Codigodoc, fuente, COUNT(*), MIN(extnombre) FROM tb_ssArchdigital WHERE IdEstructura=:est AND id=:id AND codsubs=:cs GROUP BY Fecha, Version, Codigodoc, fuente`. Verificar contra la base real que `IDExpediente` referencia el `Codigodoc` dentro del mismo `IdEstructura`; si el dato real dice otra cosa (p. ej. expedientes de otra estructura), ajustar la condicion `:est` y anotarlo en el plan.
- [ ] **Step 4: Ejecutar la suite completa** con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` y `ARCHIGENIO_TEST_MDB` apuntando a la copia. Esperado: todo en verde.
- [ ] **Step 5: Commit por nombre**, con autorizacion.

### Task 4: Pantalla `TPanelDocumentos` e iconos

**Files:**
- Create: `UPanelDocumentos.pas`, `Iconos/documento.png`, `Iconos/expediente.png`, `Iconos/mapa.png`, `Iconos/georreferenciado.png` (y los cuatro en `Iconos/blanco/`)
- Modify: `UIconos.pas`, `Iconos.rc`, `Iconos.res`, `ArchiGenioPro.dpr`

**Interfaces:**
- Consumes: `TDatosDocumento`, `TClaseDocumento`, `TFicheroDoc`, `TPropiedad`, `ClasificarDocumento`, `NombreIconoDocumento`, `NombreInsigniaGeo`, `ConstruirPropiedades`, `FiltrarPorExpediente` (Tareas 1 y 2); `TIconos.Lista`, `IndiceIcono`, `IndiceIconoBlanco` (`UIconos`); `TemaClaro`/`TemaOscuro` (`UTema`) y `TemaWindowsOscuro` (`UShellPrincipal`).
- Produces (en `UPanelDocumentos`):
  - `TSolicitudFicheros = function(const Clave: TClaveDocumento): TArray<TFicheroDoc> of object`.
  - `TClaveEvent = procedure(const Clave: TClaveDocumento) of object`.
  - `TPanelDocumentos = class(TPanel)` con: `procedure Cargar(const Docs: TArray<TDatosDocumento>; const Titulo: string)`; `procedure SeleccionarClave(const Clave: TClaveDocumento)`; propiedades `OnSeleccion: TClaveEvent`, `OnAbrirContenido: TClaveEvent`, `OnPedirFicheros: TSolicitudFicheros`, `OnAlternarVista: TNotifyEvent` (boton "Ver rejilla"); `property ExpedienteFiltrado: string read` (vacio si no hay filtro).

- [ ] **Step 1: Exportar los iconos** con las herramientas Tabler (`tabler_export_icons`): `file` -> `documento`, `folder-open` -> `expediente`, `map-2` -> `mapa`, `world-pin` -> `georreferenciado` (si `world-pin` no existe, usar `world`), 24 px, trazo 1.75, color `#1b2733` en `Iconos/` y `#ffffff` en `Iconos/blanco/`. Agregar las ocho lineas `RCDATA` a `Iconos.rc`, recompilar `Iconos.res` con `brcc32` y anadir los cuatro nombres a `NombresIconos` en `UIconos.pas` (ajustar el tamano del arreglo).
- [ ] **Step 2: Implementar `UPanelDocumentos.pas`** (por codigo, sin `.dfm`, ASCII) segun la maqueta, con los colores de `UTema`:
  - Barra superior: titulo y conteo ("Expedientes de planeamiento - 48 documentos"), cuando hay filtro de expediente un aviso "Solo el expediente EXP-0103 y sus documentos" con enlace "Mostrar todos", y el boton "Ver rejilla" (dispara `OnAlternarVista`).
  - Lista: `TListView` `vsReport`, `OwnerData = True` (virtual, `OnData` toma de un arreglo interno) con columnas icono+Codigo, Titulo, Fecha (`dd/mm/yyyy`), Tipo (Documento / Expediente / Mapa), Ficheros (`n` o `n + m fuente`) y una columna final solo con la insignia `georreferenciado`. `SmallImages := TIconos.Lista`; icono por `IndiceIcono(NombreIconoDocumento(C))`. Orden por Codigo. `ReadOnly`, `RowSelect`, `FullRowSelect`.
  - Un clic: dispara `OnSeleccion(Clave)`, pide `OnPedirFicheros(Clave)` y rellena el panel derecho con `ConstruirPropiedades` (grupos con titulo, etiqueta y valor; el panel hace scroll si no cabe). Doble clic y Intro: `OnAbrirContenido(Clave)`.
  - Panel de propiedades, abajo: boton "Abrir contenido" (deshabilitado si el documento no tiene ficheros digitales) y, si el documento es expediente, enlace "Mostrar solo este expediente" que aplica `FiltrarPorExpediente`.
  - Lista vacia: texto guia centrado "Esta subserie aun no tiene documentos"; el panel de propiedades en blanco.
  - Tema claro u oscuro segun `TemaWindowsOscuro`. Ningun acceso a datos ni a `UDM`.
- [ ] **Step 3: Compilar** (`scripts/compilar.ps1 ArchiGenioPro.dproj`). Esperado: sin errores nuevos. Esta unidad no tiene prueba automatica: es interfaz; se verifica en la Tarea 5.
- [ ] **Step 4: Commit por nombre** (`UPanelDocumentos.pas`, los iconos, `UIconos.pas`, `Iconos.rc`, `Iconos.res`, `ArchiGenioPro.dpr`), con autorizacion.

### Task 5: Enlace en `UMAINFORM.pas` (lista como vista de la subserie)

**Files:**
- Modify: `UMAINFORM.pas` (declaracion en la clase `TMAIN`, implementacion y `uses`), `ArchiGenioPro.dpr` si falta alguna unidad

**Interfaces:**
- Consumes: `TPanelDocumentos` y sus eventos (Tarea 4); `CargarIndicadores`, `ClaveTexto` (Tarea 3); `ClasificarDocumento` (Tarea 1); `UDM.tb_SeriesDatos`, `UDM.dstb_SeriesDatos`, `UDM.qryAnexosDig`, `UDM.qryFuentesDig` (master-detail ya enlazados al registro actual de `tb_SeriesDatos`), `UDM.Alcance`; `ShellActivo` (`UShellPrincipal`); `MenuItem5Click` ("Abrir").
- Produces: `procedure TMAIN.ConectarListaDocumentos` (privado), llamada una vez desde `FormShow` cuando `ShellActivo`; clase local `TEnlaceDocumentos = class(TDataLink)` en la seccion de implementacion de `UMAINFORM.pas` con `DataSetChanged`/`ActiveChanged` que piden recargar.

- [ ] **Step 1: Crear el panel** dentro de `PSeriesDatos` (`Align := alClient`, `Parent := PSeriesDatos`, por delante de `cxPageControl2`). En modo Lista se oculta `cxPageControl2`; el boton "Ver rejilla" del panel (y uno equivalente "Ver lista" en la rejilla, creado por codigo en `AdvPanel6` o en una franja propia) alterna. El modo se recuerda mientras dure la sesion. Por defecto: Lista. Si la creacion falla, se registra el motivo y queda la rejilla (sin mensajes).
- [ ] **Step 2: Cargar.** Un `TEnlaceDocumentos` sobre `UDM.dstb_SeriesDatos`; cuando el dataset cambia de subserie o se refresca (`ActiveChanged`, `DataSetChanged` con coalescencia de un temporizador de 150 ms para no recargar en cada `Next`), recorre `UDM.tb_SeriesDatos` con `DisableControls` y marcador (restaura posicion y `EnableControls` en `finally`), arma `TDatosDocumento` por fila (claves, `titulodoc`, `IDExpediente`, `subexp`, `Idservidor`, `Archivo`, `deposito`, `gaveta`, `posicion`, `observaciones`, `namefile`/`fichero` para `ExtPrincipal` si no hay indicador), pide `CargarIndicadores` una vez para la subserie y copia los indicadores (`TryGetValue`; ceros si no hay). Servidor y archivo se muestran con su nombre si el dataset lo tiene (campo de busqueda existente en `UDM`), si no, con el numero. `Cargar(Docs, Titulo)` con el nombre de la subserie.
- [ ] **Step 3: Seleccion y apertura.** `OnSeleccion`: `UDM.tb_SeriesDatos.Locate` por las seis claves (con `Fecha` como `TDateTime`); `OnPedirFicheros` lee `UDM.qryAnexosDig` (digitales) y `UDM.qryFuentesDig` (fuentes) del registro ya localizado y devuelve `TArray<TFicheroDoc>` (`nombre`, `extnombre`, `tamano`). `OnAbrirContenido`: localiza el registro y llama `MenuItem5Click(Self)`. Todo dentro de `try/except` con el mensaje habitual de `UDM.sms` en caso de error.
- [ ] **Step 4: Compilar y ejecutar la suite.** `scripts/compilar.ps1 ArchiGenioPro.dproj`; `Pruebas`. Esperado: sin errores nuevos; 149 + nuevas pruebas en verde.
- [ ] **Step 5: Verificacion en la aplicacion real** (base `SGDTEST_ALCANCE`, copia del ejecutable): elegir un nodo con subserie; ver la lista con iconos; un clic abre propiedades; doble clic abre el visor; alternar a la rejilla y volver; `shell_clasico.flag` deja la rejilla. Capturar la ventana con `PrintWindow` (no la pantalla completa).
- [ ] **Step 6: Commit por nombre** con el procedimiento de parche de `UMAINFORM.pas`, con autorizacion.

### Task 6: Lista de verificacion manual y cierre de la fase

**Files:**
- Create: `docs/superpowers/plans/2026-11-05-verificacion-f2.md`
- Modify: `docs/superpowers/specs/2026-11-05-documentos-carga-consulta-geo-trazabilidad-design.md` (estado de la F2)

- [ ] **Step 1: Escribir la lista** para una persona con la aplicacion real, con estos casos minimos (usuario y resultado esperado en cada uno): lista de una subserie con documentos; icono de expediente distinto del de documento; documento `shp` o `dxf` con icono de mapa; documento georreferenciado con la insignia; un clic muestra posicion fisica, fecha, version, tipo, ficheros y fuentes; doble clic abre el contenido en el visor; "Mostrar solo este expediente" y "Mostrar todos"; documento sin ficheros ("Sin ficheros", "Abrir contenido" deshabilitado); subserie vacia; usuario con alcance parcial (el contador de hijos no incluye los que no ve); rol visor (la lista es solo lectura; "Abrir" igual que antes); alternar Lista/Rejilla y agregar un documento con el boton del shell (la lista se refresca); `shell_clasico.flag`; 1366x768 al 125 %; tema claro y oscuro; subserie con unos 3000 documentos; modo Access.
- [ ] **Step 2: Anotar el estado** de la F2 en el diseno (seccion 7) y en el plan maestro, sin cambiar nada mas.
- [ ] **Step 3: Commit por nombre**, con autorizacion.

## Autorrevision

- **Cobertura del diseno (3.2 y 3.4, F2):** lista con doble clic y un clic (Tareas 4 y 5); icono distinto de expediente (Tareas 1 y 4); mapa/georreferenciado e insignia (Tareas 1, 3 y 4); posicion fisica, fecha, version, expediente, ficheros digitales y fuente (Tarea 2); expediente engloba documentos con filtro "solo este expediente" (Tareas 2, 4); alcance en el contador de hijos (Tarea 3). Lo que la F2 **no** hace, por diseno: agregar o editar documentos (F3), subir a MinIO (F4), linea de tiempo (F5), entrada de coordenadas y mapa (F6, F8), "obtener el expediente completo" (tras la F4, porque necesita los ficheros).
- **Consistencia de nombres:** `TDatosDocumento`, `TClaveDocumento`, `TFicheroDoc`, `TClaseDocumento`, `TPropiedad` (Tareas 1 y 2) son los que usan las Tareas 3, 4 y 5; `ClaveTexto` y `TIndicadoresDoc` (Tarea 3) los usa la Tarea 5; los eventos de `TPanelDocumentos` (Tarea 4) los conecta la Tarea 5.
- **Proporcion:** el plan no escribe cuerpos de funciones; da firmas, valores de la especificacion y las pruebas.
