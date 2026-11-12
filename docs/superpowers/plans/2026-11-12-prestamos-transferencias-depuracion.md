# Plan de desarrollo: Préstamos, Transferencias y Depuración

Fecha: 2026-11-12. Diseño: `docs/superpowers/specs/2026-11-12-prestamos-transferencias-depuracion-design.md`. Maquetas: `docs/superpowers/maquetas/2026-11-12-procesos-maqueta.html`.

**Puerta de aprobación:** no se escribe código de producto hasta que el usuario apruebe las maquetas y el diseño. Cada fase, al empezar, genera su plan detallado (tareas con pasos de prueba y compilación) en este mismo directorio, como se hizo con series y clasificadores.

## Principios (se aplican a todas las fases)

1. **Reglas fuera de la pantalla.** Cada regla vive en una unidad sin VCL ni `TUDM`, con pruebas DUnitX en `Pruebas/` escritas primero (TDD). La pantalla solo presenta.
2. **Optimización.** Consultas con filtro de alcance y paginación; sin `FetchAll` en tablas grandes; sin consultas por fila (N+1); carga de paneles pesados con `Visible := False` antes de asignar `Parent`; índices en las claves de búsqueda de `prc_*`. Se mide con `UTiempos` cuando haya duda.
3. **Refactorización.** Se retira lo viejo (no se parchea): cada fase termina con la lista de unidades obsoletas y su plan de retiro. Se elimina la contraseña embebida de `UDepuracion`.
4. **Documentación en español.** Cada unidad lleva comentario de cabecera (propósito, reglas, dependencias) y comentarios de método en español; se actualiza `CLAUDE.md`, se escribe la ayuda de usuario de cada pantalla y se deja una lista de verificación manual por fase (`...-verificacion-*.md`).
5. **Compatibilidad.** SQL válido en SQL Server y Access; DDL idempotente; interruptor `procesos_clasico.flag` y registro de error con vuelta a la pantalla vieja si la nueva falla al abrir.
6. **Mensajes** solo por `TMensajes`; texto nuevo con tildes; `.dpr` actualizado.

## Fases

### F0. Base común (sin pantallas de usuario final)
- `UEsquemaProcesos` + `SCRIPTS/procesos_tablas.sql`: tablas `prc_*` (idempotente, ambos motores).
- `UProceso` (estados, pasos, transiciones, condiciones), `UNumeracion` (consecutivo por año y tipo), `UCandados` (un documento, un proceso abierto), `UAutorizacion` (acta y acuerdo).
- Integración con permisos (`UAlcance`: prestar, transferir, depurar; depurar solo archivo central) y con la bitácora de trazabilidad.
- Sección **Procesos** en el shell y esqueleto de pantalla base (`UProcesoBase`: indicadores, pestañas, lista, panel, tira de pasos), con el interruptor `.flag`.
- Salida: pruebas verdes; esquema creado en una base de prueba; pantalla base vacía abre dentro del shell.

### F1. Préstamos
- `UPrestamosDatos` (alta, entrega, renovación, devolución, vencidos, candados) con pruebas.
- Pantalla A1/A2; impresos Solicitud 8.2 y Registro 8.3 (FastReport).
- Migración de `TB_Prestamos` y `TB_PrestamosDocumentos` con conteo antes y después.
- Aviso de vencidos en la pantalla de Inicio del nodo.
- Salida: lista de verificación `...-verificacion-prestamos.md` cumplida; `UPrestamos` marcada como obsoleta.

### F2. Transferencias, parte del remitente (pasos 1 a 4)
- `UTransferenciasDatos`: propuesta por plazo vencido (usa retención de `cl_subseries`), cronograma anual, cajas y numeración, verificaciones, relación de entrega.
- Pantallas B1, B2, B3; impresos Relación de entrega (16) y etiquetas de caja.
- Salida: se puede preparar y entregar una transferencia completa; bloqueos por préstamo y por comisión funcionando.

### F3. Transferencias, parte del receptor (pasos 5 y 6)
- Recepción con n.º de registro de entrada, comparación por caja, cuarentena, incidencias; ubicación topográfica (reutiliza `UTopografia`); cierre que mueve los documentos de archivo.
- Pantalla B4; impresos Registro general de entrada (17) y Registro topográfico (18).
- Migración de `tb_transferencia`; retiro de `UTransferencias` y `UProgresoTransferencia`.

### F4. Depuración
- `UDepuracionDatos`: propuesta por destino *eliminación*, autorización, acta, muestra, testigos, ejecución que **marca** documentos como eliminados (sin `Delete`), retiro del archivo digital del servidor, cierre.
- Pantallas C1, C2, C3; impreso Acta de eliminación (19).
- Migración de `tb_depuracion`; los documentos depurados antes se reflejan como eliminados con su referencia.
- Retiro de `UDepuracion` y de su conexión con credenciales.

### F5. Integración y cierre
- Búsqueda y árbol excluyen documentos eliminados; ficha del documento muestra su historial de préstamos, transferencia y depuración.
- Pruebas de recorrido completo (préstamo bloquea transferencia, transferencia completa, depuración completa) en base de prueba.
- Medición de rendimiento con volumen (decenas de miles de documentos) y ajustes de índices.
- Retiro definitivo de las pantallas viejas y del `.flag`, actualización de `CLAUDE.md`, ayuda de usuario y checklist final.

## Orden y dependencias

F0 → F1 → F2 → F3 → F4 → F5. Préstamos va primero porque es el más pequeño y habilita el candado que usan los otros dos. F3 depende de F2; F4 depende de F0 y F1 (no de F2/F3, puede adelantarse si se prioriza).

## Entregables de documentación por fase

Plan detallado de la fase; lista de verificación manual; comentarios de unidad en español; sección en `CLAUDE.md`; ayuda de usuario de la pantalla; registro de decisiones tomadas (qué se retiró y por qué).

## Riesgos

| Riesgo | Mitigación |
|---|---|
| DDL de Access no se puede probar sin `.mdb` | Igual que en series: se escribe y se marca como no probado; la lógica se prueba contra SQL Server. |
| Datos viejos de depuración/transferencia incompletos | Migración con informe de lo que no se pudo mapear; tablas viejas se conservan hasta aprobar. |
| `UMAINFORM.pas` es enorme y delicado | Solo se agregan entradas de menú y enganches siguiendo el patrón de `AbrirClasificador`; nada de lógica nueva ahí. |
| Plazos de retención mal cargados en subseries | La propuesta muestra de dónde sale el plazo y permite excluir; no se bloquea por datos faltantes. |
