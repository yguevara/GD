# Procesos archivísticos, F1 (Préstamos): lista de verificación manual

Fecha: 2026-11-12. Plan: `2026-11-12-procesos-f1-prestamos.md`. Marcar cada punto al comprobarlo.
Para abrir los formularios con diseño: `UPrestamosForm.dfm` en el IDE (Delphi 10.3 con DevExpress instalado).

## Ya comprobado en el desarrollo

- [x] Pruebas puras: reglas de estado/plazo/texto/validación (`UPrestamosReglas`), indicadores y filtros (`UPrestamosDatos`), estado de migración, SQL de «prestados», pintado de pestañas, `codsubs` en la clave del documento. Suite: 747 pasan; los 23 errores son los de siempre (`cl_series`).
- [x] `ArchiGenioPro.dproj` compila sin errores.
- [x] El formulario se crea desde su `.dfm` sin errores de propiedades y, con datos de ejemplo (sin base), se ve como las maquetas A1 y A2: lista, ficha de vencido, ficha de solicitado y «nuevo préstamo», a 125 % de escala, tema claro.
- [x] Los dos `.fr3` cargan, enlazan los datos y generan la página (PDF revisados): solicitud (8.2) y registro (8.3).

## Pendiente: requiere una base SQL Server de pruebas

Quedó escrito pero **sin ejecutar contra una base** (las pruebas de base se omiten sin `ARCHIGENIO_TEST_DB`):

- [ ] Definir `ARCHIGENIO_TEST_DB` (base con `tb_tree`; usuario `geoconn`, servidor `localhost`) y ejecutar `PruebasArchiGenio.exe`. Deben pasar de verdad `TPruebasPrestamosDatosBD` (14), `TPruebasMigracionBD` (4), `TPruebasProcesosDatosBD` (16) y `TPruebasEsquemaProcesosBD` (4), sin filas residuales.
- [ ] Abrir ArchiGenio contra una base **con préstamos antiguos** y revisar `procesos_error.log` junto al `.exe`: debe decir cuántos migró y los avisos (sin nombre, documento ya retenido…). Ejecutarlo dos veces: la segunda no migra nada.
- [ ] Contar antes y después: filas de `TB_Prestamos` = préstamos en `prc_prestamo` con `IdPrestamoViejo`; documentos de préstamos abiertos = filas de `prc_bloqueo` (menos los avisos).
- [ ] Rama Access (`.mdb`): el DDL, `SELECT TOP n`, los `UNION` de «prestados» y la migración no se han probado. La migración automática solo corre en SQL Server.

## Pantalla (con la aplicación y una base)

- [ ] Sección **Préstamos** abre la pantalla nueva dentro de la ventana principal, con «Procesos > Préstamos» en la cabecera.
- [ ] Con `procesos_clasico.flag` junto al `.exe` abre la pantalla vieja; si la nueva falla, `procesos_error.log` anota el motivo y abre la vieja.
- [ ] La lista muestra los préstamos del nodo elegido y sus descendientes (y de todo el árbol sin nodo elegido); los indicadores y pestañas cuadran con la lista.
- [ ] **Nuevo préstamo** (EGD): datos del solicitante (externo exige carnet de 11 dígitos y entidad), buscar documentos (los ya prestados salen marcados y no se pueden agregar), «Guardar solicitud» y «Registrar entrega».
- [ ] Ficha: entregar, renovar plazo (solo hacia adelante), devolver (dos veces seguidas: la segunda se rechaza), cancelar. Tras devolver o cancelar, los documentos quedan libres.
- [ ] Un usuario que no es EGD del nodo ve la lista y las fichas, pero no puede crear ni cambiar préstamos (botones ocultos y «Nuevo préstamo» deshabilitado).
- [ ] Dos sesiones a la vez: el mismo documento en dos préstamos (solo uno lo logra) y el mismo préstamo avanzado desde dos puestos (solo uno lo logra).
- [ ] «Imprimir solicitud» y «Registro anual» abren la vista previa; el registro lista solo los préstamos del año.
- [ ] «Exportar» genera el Excel de la lista.
- [ ] La pantalla de Inicio del nodo y la lista de documentos siguen mostrando «Prestados» y el estado de cada documento, también para los préstamos viejos aún abiertos.
- [ ] Cambiar de sección con un préstamo nuevo a medio llenar pregunta si se descarta.
- [ ] Tema oscuro y escalas de 100 %, 125 % y 150 %: textos legibles, nada cortado (el diseño se probó solo a 125 % claro).
- [ ] Abrir `UPrestamosForm.dfm` en el IDE: sin errores de componentes; ajustar el diseño si algo no gusta (todo el diseño está en el `.dfm`).
- [ ] Clasificadores (Archivos, Servidores, Series) abren y cierran igual que antes (`UClasificadorBase` volvió a su estado anterior).

## Cierre de F1

- [ ] Revisión de código de la rama sin hallazgos críticos.
- [ ] Decidir cuándo retirar `UPrestamos` (pantalla vieja) y `procesos_clasico.flag`: **no se retiran en F1**; siguen como respaldo.
- [ ] Plan detallado de F2 (Transferencias, parte del remitente).
