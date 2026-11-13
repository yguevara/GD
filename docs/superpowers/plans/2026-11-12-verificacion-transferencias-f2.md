# Procesos archivísticos, F2 (Transferencias, parte del remitente): lista de verificación manual

Fecha: 2026-11-13. Plan: `2026-11-12-procesos-f2-transferencias-remitente.md`. Marcar cada punto al comprobarlo.
Diseño editable: `UTransferenciasForm.dfm` (Delphi 10.3 con DevExpress). Impresos editables con el diseñador de FastReport: `MAISEL REPORT/Report/rRelacionEntrega.fr3` y `rEtiquetasCaja.fr3`.

## Ya comprobado en el desarrollo

- [x] Pruebas puras: vencimiento por años (día del aniversario, sin plazo, `FechaFin`), cronograma, verificaciones, reparto en cajas (expediente no dividido, expediente mayor que la caja, numeración sin huecos), SQL de vencidos y agrupación por expediente, textos de lo que falta, esquema. Suite: 791 pasan de 814; los 23 errores son los de siempre (`cl_series`).
- [x] `ArchiGenioPro.dproj` compila.
- [x] El formulario se crea desde su `.dfm` final sin errores de propiedades y, con datos de ejemplo (sin base), se ven bien la lista con cronograma y los pasos 1 a 4 sin textos superpuestos ni recortados.
- [x] Los dos `.fr3` generan páginas (la relación en una página; las etiquetas, una página por caja).
- [x] Los impresos de Préstamos siguen funcionando tras extraer `UImpresosComun`.

## Pendiente: requiere una base SQL Server de pruebas

Escrito pero **sin ejecutar contra una base** (las pruebas de base se omiten sin `ARCHIGENIO_TEST_DB`):

- [ ] Definir `ARCHIGENIO_TEST_DB` (base con `tb_tree`) y ejecutar `PruebasArchiGenio.exe`: deben pasar de verdad `TPruebasTransferenciasDatosBD` (11) y los de esquema.
- [ ] **Catálogos reales**: comprobar que `cl_ArchivosGestion` (`Cod`, `Tipo`), `cl_tipoarch` (`Idtipoarch`, `tipoarch`), `cl_subseries` (`tgestion`), `cl_series` (`serie`) y `tb_SeriesDatos` (`Archivo`, `Fecha`, `FechaFin`, `IDExpediente`) tienen esas columnas; la propuesta se escribió contra ellas.
- [ ] **Propuesta** con datos reales: solo documentos de archivo de *Gestión* con el plazo (`tgestion` años) vencido; una subserie sin plazo no aparece; los documentos que están en préstamo salen contados como «N en préstamo u otro proceso» y no se pueden agregar.
- [ ] `AgregarGrupo` (no tiene prueba de base): agrega los documentos, los deja retenidos (otro usuario no los puede prestar ni transferir) y «Quitar» los libera.
- [ ] Dos sesiones a la vez agregando las mismas series: una gana y la otra recibe el aviso, sin dejar la transferencia a medias.
- [ ] Rendimiento de la propuesta con muchos nodos y subseries (hace 2 consultas por subserie).
- [ ] Rama Access: el SQL (`IN (...)`, `EXISTS`, `INSERT … SELECT`, `UPDATE … IS NULL`) y el DDL no se han probado.

## Pantalla (con la aplicación y una base)

- [ ] La sección **Traslados** abre la pantalla nueva dentro de la ventana principal, con «Procesos > Transferencias» en la cabecera.
- [ ] Con `procesos_clasico.flag` (o si la nueva falla) abre la pantalla vieja (`btnTransfer`); `procesos_error.log` anota el motivo.
- [ ] Cronograma: «Programar» guarda la fecha del nodo; reprogramar la actualiza; el estado pasa a «Atrasada» si pasó la fecha y no hay transferencia; «En trámite» cuando se crea la transferencia.
- [ ] **Nueva transferencia** crea `T-AAAA-NN` y abre el detalle en el paso 1.
- [ ] Paso 1: marcar series (casillas) y «Agregar a la transferencia»; «Quitar la serie elegida».
- [ ] «Pasar al siguiente paso» sin documentos, sin autorización o sin verificaciones dice qué falta (franja roja).
- [ ] Paso 2: acta, acuerdo y fecha (la fecha no puede ser futura); la autorización queda registrada y se puede reemplazar.
- [ ] Paso 3: «Numerar las cajas» con distintas capacidades; ningún expediente queda dividido; las cinco verificaciones se guardan al marcarlas; no se pasa al paso 4 sin cajas para todos los documentos.
- [ ] Paso 4: «Registrar la entrega» exige el nombre de quien entrega y confirma; pasa al paso 5 y la pantalla queda de solo lectura.
- [ ] «Imprimir relación de entrega» y «Imprimir etiquetas de caja» abren la vista previa con los datos reales; la relación lleva el espacio «Para uso del archivo receptor».
- [ ] «Cancelar transferencia» solo hasta el paso 4; libera los documentos.
- [ ] Un usuario que no es EGD del nodo ve la lista y los pasos pero no puede crear ni cambiar (botones ocultos o deshabilitados).
- [ ] Tema oscuro y escalas de 100 %, 125 % y 150 %: textos legibles y nada superpuesto (el diseño se probó solo en tema claro).
- [ ] Abrir `UTransferenciasForm.dfm` en el IDE sin errores de componentes.
- [ ] Clasificadores y Préstamos siguen abriendo y cerrando igual.

## Cierre de F2

- [ ] Revisión de código de la rama sin hallazgos críticos.
- [ ] Plan detallado de F3 (recepción, registro de entrada, topografía, cuarentena, incidencias, migración y retiro de `UTransferencias`/`UProgresoTransferencia`).
