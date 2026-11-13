# Procesos archivísticos, F0: lista de verificación manual

Fecha: 2026-11-12. Plan: `2026-11-12-procesos-f0-base-comun.md`. Marcar cada punto al comprobarlo.

## Automático (ya ejecutado en el desarrollo)

- [x] Suite `PruebasArchiGenio.exe`: las pruebas nuevas de F0 pasan (`TPruebasProceso`, `TPruebasNumeracion`, `TPruebasCandados`, `TPruebasAutorizacion`, `TPruebasEsquemaProcesosSql`, `TPruebasProcesosCodigos`, `TPruebasProcesosInterruptor`).
- [x] `ArchiGenioPro.dproj` compila sin errores.
- [x] Captura de `UProcesoBase` en tema claro (lista y detalle con tira de pasos) comparada con las maquetas A1 y B2.

## Pendiente: requiere una base SQL Server de pruebas

Quedaron escritas pero **sin ejecutar** (se omiten sin la variable de entorno):

- [ ] Crear una base de pruebas con `tb_tree` y definir `ARCHIGENIO_TEST_DB=<nombre>` (usuario `geoconn`, servidor `localhost`, como las demás pruebas de BD).
- [ ] Ejecutar `PruebasArchiGenio.exe`: deben pasar de verdad `TPruebasEsquemaProcesosBD` (4) y `TPruebasProcesosDatosBD` (15), y no quedar filas `CreadoPor = '__prueba__'`.
- [ ] En una base real, abrir ArchiGenio y comprobar que existen las tablas `prc_proceso`, `prc_unidad`, `prc_evento`, `prc_autorizacion`, `prc_bloqueo` y que las bases con datos no pierden nada (el esquema solo agrega).
- [ ] Dos sesiones a la vez: avanzar el mismo proceso desde el mismo paso; solo una debe lograrlo.
- [ ] Dos sesiones a la vez: agregar el mismo documento a dos procesos; solo una debe lograrlo (clave primaria de `prc_bloqueo`).
- [ ] Rama Access: copia de `.mdb` con `ARCHIGENIO_TEST_MDB`; comprobar que el DDL se crea (no probado: no hay `.mdb`).

## Pantalla base (manual, con la aplicación)

- [ ] Sin variable de entorno: la sección **Préstamos** abre la pantalla vieja, como siempre.
- [x] (F1) La pantalla base de F0 y su demostración se reemplazaron por el formulario con `.dfm` de Préstamos; ver `verificacion-prestamos-f1`.
- [ ] Con `procesos_clasico.flag` junto al `.exe` (y la variable): se abre la pantalla vieja.
- [ ] Cambiar de sección con la pantalla abierta funciona y no deja controles huérfanos.
- [ ] Tema oscuro (Windows en modo oscuro): indicadores, pestañas y tira de pasos legibles (verde, rojo y acento visibles).
- [ ] Pantalla a 125 % y 150 % de escala: nada se corta ni se solapa.
- [ ] Clasificadores (Archivos, Servidores, Series) abren y se cierran igual que antes (se agregaron los accesores `Cabecera`, `PanelLateral`, `BarraAcciones` a `UClasificadorBase` y se generalizó `AbrirClasificador`).
- [ ] El registro de auditoría anota «Accediendo a procesos: …» al abrir y «Abandonando procesos: …» al cerrar.

## Cierre de F0

- [ ] Revisión de código de la rama sin hallazgos críticos.
- [ ] Decisión sobre el plan detallado de F1 (Préstamos): primera tarea, eliminar `UProcesoDemo` y el desvío temporal.
