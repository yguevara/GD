# Rediseño de Préstamos, Transferencias y Depuración

Fecha: 2026-11-12. Estado: **borrador para aprobación** (maquetas en `docs/superpowers/maquetas/2026-11-12-procesos-maqueta.html`).

## 1. Intención

Los tres procesos que cierran el ciclo de vida del documento (préstamo, transferencia de archivo de gestión a archivo central, depuración) existen hoy como pantallas sueltas que no siguen el procedimiento archivístico oficial. Se rediseñan desde cero, **desestimando lo implementado**, para que cumplan la norma cubana de gestión documental y, a la vez, sean simples de usar (objetivo rector del producto: poca capacitación).

Fuentes analizadas (`docs/GD`): *Manual de procedimientos GD* (procedimientos de transferencia, recepción y depuración; Anexos 16 a 20), *Manual Marco 2020* (Anexos 8.2 y 8.3, servicio archivístico), *REG.CITMA 53‑2022* y *Gaceta Oficial 2020* (atribuciones del gestor y del archivo central, instrumentos de control), más ISO 15489 / ISAD(G) como contexto.

## 2. Hallazgos del sistema actual

| Unidad | Estado | Problema |
|---|---|---|
| `UPrestamos` (314 líneas) | Pantalla `.dfm` con tablas `TB_Prestamos` y `TB_PrestamosDocumentos` | Sin estados ni vencimientos, sin solicitud firmada, no bloquea transferencias ni depuraciones. |
| `UTransferencias` (147) + `UProgresoTransferencia` | Cuadrícula sobre `tb_transferencia` | No hay proceso: sin comisión, sin cajas, sin relación de entrega, sin recepción. |
| `UDepuracion` (1090) | Cuadrícula + `tb_depuracion` | **Borra** filas de `tb_SeriesDatos` directamente (`tb_SeriesDatos.Delete`), sin autorización de la comisión, sin acta, sin testigos, sin muestra. Llama a `MessageDlg`. La línea 488 contiene un **usuario y contraseña de base de datos escritos en el código** (riesgo de seguridad). |

## 3. Metas, no metas y antimetas

**Metas**
- Cada módulo es un **proceso con pasos** que el sistema hace respetar; el usuario siempre sabe en qué paso está y qué falta.
- Generar los impresos oficiales (Anexos 8.2, 8.3, 16, 17, 18, 19) con los datos ya capturados, sin retipear.
- Seguridad de la depuración: nada se elimina sin autorización registrada y sin muestra; los documentos se marcan, no se pierden.
- Código por capas, **reglas sin VCL ni `TUDM`** con pruebas DUnitX; pantallas por código embebidas en el shell; documentado en español.
- Optimizado: consultas paginadas y acotadas por alcance, sin `FetchAll` sobre tablas grandes, sin consultas por fila.

**No metas**
- No es un flujo de trabajo (BPM) general ni firma electrónica; las firmas son físicas (se imprime y se firma).
- No se modela el voto interno de la Comisión de Valoración: se **registra su acta y acuerdo** (número, fecha, órgano) como autorización.
- No se cambia el modelo de permisos por alcance ya existente.
- No se tocan los clasificadores ni la carga de documentos.

**Antimetas (sería un fallo aunque funcione)**
- Que un usuario nuevo necesite capacitación larga para completar una transferencia.
- Que se pueda eliminar un documento por un camino que no pase por la autorización.
- Que un documento prestado se transfiera o elimine.
- Perder datos históricos de préstamos, transferencias y depuraciones ya registrados.

## 4. Modelo común: el expediente de proceso

Los tres módulos comparten un esqueleto (unidad `UProceso`, sin VCL):

- **Estado y paso**: transiciones permitidas definidas en una tabla en código, con prueba por transición. Solo se avanza si se cumplen las condiciones del paso (ejemplo: «Pasar a entrega» exige todas las verificaciones marcadas).
- **Número de proceso** por año y tipo: `2026‑0047` (préstamo), `T‑2026‑02`, `D‑2026‑01` (unidad `UNumeracion`, único por año).
- **Bitácora**: cada cambio de estado escribe usuario, fecha y detalle (reutiliza el registro de trazabilidad existente, ver `trazabilidad_esquema.sql`).
- **Unidades**: lo que entra en el proceso (documento, expediente o caja), con su ubicación topográfica al momento.
- **Autorización**: acta y acuerdo de la Comisión (órgano, n.º de acta, n.º de acuerdo, fecha). Reutilizada por transferencia y depuración.
- **Candados cruzados**: un documento solo puede estar en *un* proceso abierto a la vez (préstamo abierto, transferencia en curso o depuración en curso). Es la regla que evita las antimetas.

Tablas nuevas (prefijo `prc_`, DDL idempotente en `UEsquemaProcesos` y copia documental en `SCRIPTS/procesos_tablas.sql`, válidas en SQL Server y Access): `prc_proceso`, `prc_unidad`, `prc_evento`, `prc_autorizacion`, `prc_prestamo`, `prc_caja`, `prc_incidencia`, `prc_acta_testigo`, `prc_muestra`. Los datos de `TB_Prestamos*`, `tb_transferencia` y `tb_depuracion` se **migran** (script de una vez, con conteo antes/después) y las tablas viejas se conservan hasta aprobar el cierre.

## 5. Préstamos

- **Estados**: Solicitado → Entregado → Devuelto; además Vencido (calculado por fecha), Cancelado.
- **Datos**: solicitante, carnet de identidad (externos), entidad, tipo (interno/externo), fecha de entrega, fecha límite (plazo por defecto configurable, hoy propuesto 3 días), atendido por, unidades (documentos o cajas).
- **Reglas**: un documento ya prestado no se agrega (se muestra quién lo tiene); un documento prestado bloquea transferencia y depuración; renovar plazo queda en bitácora; la devolución registra si llegó completo.
- **Impresos**: Solicitud de consulta o préstamo (8.2) para firmar; Registro interno de préstamo (8.3) por año.
- **Panel de control**: contadores (en préstamo, vencidos, por vencer, devueltos) y pestañas; los vencidos se resaltan. Se ofrece un aviso en la pantalla de Inicio del nodo (ya existente, `UInicioNodo`).

## 6. Transferencias

Seis pasos: **1 Propuesta** → **2 Comisión** → **3 Preparación** → **4 Entrega** → **5 Recepción** → **6 Ubicación**.

1. **Propuesta**: el sistema lista, para el archivo remitente, los documentos cuyo plazo de retención en archivo de gestión ya venció (según la tabla de retención de la subserie), excluyendo los prestados. El usuario elige. También existe el **cronograma anual** (una transferencia por unidad productora y año; se muestra atrasada si pasó la fecha).
2. **Comisión**: se registra la autorización (acta y acuerdo). Sin ella no se avanza.
3. **Preparación**: cajas numeradas de forma consecutiva por sujeto productor, tipo documental, título, fechas extremas y unidades por caja. Verificaciones del Manual (ejemplares únicos, expedientes completos y sin presillas, ninguno dividido entre cajas, listado en el exterior de la caja, sin préstamos pendientes). Genera la **Relación de entrega (Anexo 16)** y las etiquetas de caja.
4. **Entrega**: queda registrada la entrega (firma física en 2 ejemplares).
5. **Recepción** (archivo central): asigna **n.º de registro general de entrada (Anexo 17)**; compara lo recibido con la relación por caja; registra el estado de conservación; las cajas con humedad u hongo pasan a **cuarentena**; las faltas generan una **incidencia** con plazo de reclamación.
6. **Ubicación**: ubica cada caja en el depósito (**Registro topográfico, Anexo 18**), reutilizando `UTopografia`. Al cerrar, los documentos cambian de archivo (gestión → central) y se actualiza su ubicación.

Pendiente de tu confirmación: la transferencia del archivo central al **histórico** se modela con el mismo proceso (el archivo remitente es el central y el receptor el histórico); en la primera entrega solo se cubre gestión → central.

## 7. Depuración

Cinco pasos: **1 Propuesta** → **2 Autorización** → **3 Acta** → **4 Ejecución** → **5 Cierre**.

1. **Propuesta**: lista las series cuyo destino final es *eliminación* y cuyo plazo de retención en el archivo central ya venció, excluyendo prestados, en transferencia o en otra depuración. Solo el archivo central y sus secciones pueden iniciar (los archivos de gestión no).
2. **Autorización**: acta y acuerdo de la Comisión Nacional, Provincial o Municipal.
3. **Acta de eliminación física (Anexo 19)**: serie, unidades en números y letras, desglose por año, fechas extremas, **muestra que se conserva** (descripción y localización; obligatoria), lugar y vía (incineración o trituración), fecha prevista y testigos (mínimo 2, uno de la Comisión y uno de un archivo de gestión).
4. **Ejecución**: confirmación reforzada (escribir «ELIMINAR»). Los documentos **no se borran**: pasan a estado *eliminado* con la referencia del acta, y salen de búsquedas y del árbol. Los archivos digitales se retiran del servidor; la ficha y los metadatos mínimos se conservan como evidencia.
5. **Cierre**: acta definitiva y archivado de los instrumentos como evidencia.

## 8. Permisos

Se reutiliza `UAlcance`. Prestar, transferir y depurar son acciones del EGD en su nodo (ya definidas en el rediseño de alcance). Regla nueva: **iniciar y ejecutar una depuración solo desde el archivo central**. Administrador y Visor no prestan, transfieren ni depuran. Registrar la autorización de la Comisión la hace el EGD; ejecutar exige además el candado cruzado.

## 9. Interfaz

Pantallas por código (sin `.dfm`), embebidas en el shell con el mismo mecanismo que los clasificadores (`AbrirClasificador` / `Embeber`), pero bajo la sección **Procesos** (Préstamos, Transferencias, Depuración). Patrón: indicadores arriba, pestañas de estado, lista a ancho completo, panel lateral con el detalle y acciones, y una **tira de pasos** para transferencias y depuración. Paleta de `UTema`, claro y oscuro, Segoe UI. Mensajes por `TMensajes`. Interruptor `procesos_clasico.flag` junto al ejecutable para volver a las pantallas viejas mientras dure la transición. Ver maquetas A1 a C3.

## 10. Compatibilidad y técnica

- Delphi 10.3, FireDAC, SQL válido en SQL Server y Access (en Access no hay alcance por usuario; los procesos funcionan igual para un solo usuario). El DDL de Access no se puede probar sin `.mdb` (igual que en la fase de series).
- Reglas en unidades sin VCL (`UProceso`, `UPrestamosDatos`, `UTransferenciasDatos`, `UDepuracionDatos`, `UNumeracion`, `UEsquemaProcesos`) con pruebas en `Pruebas/`. Impresos en FastReport (`.fr3` nuevos), sin credenciales embebidas: los informes usan los datasets de la aplicación.
- Todo texto nuevo con tildes en pantallas; unidades sin pantalla en ASCII; unidad nueva se agrega al `.dpr`.

## 11. Supuestos que tomé (corrígelos si no son así)

1. El plazo de préstamo por defecto es 3 días, configurable.
2. El documento es la unidad mínima de préstamo y de transferencia; la caja es la unidad física de transferencia.
3. La Comisión se registra por su acta y acuerdo, sin flujo de votación interno.
4. Los documentos depurados se marcan y se conservan como ficha; no se borran de la base.
5. La depuración exige muestra siempre (la norma lo pide en toda depuración de series).
6. Los datos antiguos se migran; las tablas viejas se conservan hasta cerrar la fase de retiro.
7. Todo vive bajo un grupo «Procesos» en el menú principal.
