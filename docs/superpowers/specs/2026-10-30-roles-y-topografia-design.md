# Roles, topografía de la subserie y pantallas de asignación

Fecha: 2026-10-30. Estado: borrador para aprobación. Complementa `2026-10-29-rediseno-archigenio-design.md` (sección 5, seguridad por alcance); si algo choca, manda este documento para lo que trata.

## 1. Por qué

Con el alcance ya filtrando datos, el usuario `egd_a43` (Especialista de Gestión Documental de A.4.3) entra y no puede hacer su trabajo: no ve la topografía de la subserie 074 ni puede agregar documentos. Causas verificadas:

- Los botones de topografía los muestra `ConfiguracionRolGestor` (`UMAINFORM.pas`) solo si el campo `gestor` de `tb_Serietree` (nodo + subserie) coincide con el usuario. Está en 0 en todas las filas.
- El EGD nuevo vive en `tb_nodo_egd`, vacía, y no hay pantalla para llenarla. La interfaz vieja tampoco la consulta.
- Al agregar un documento, `TUDM.tb_SeriesDatosNewRecord` exige que la fila de `tb_Serietree` tenga datos topográficos; si faltan, el Usuario recibe un mensaje que lo manda a una pantalla que no puede abrir.

Objetivo que manda (del diseño base): que un usuario nuevo trabaje con poca capacitación.

## 2. Qué es la topografía

Dónde vive físicamente lo que una subserie guarda en un nodo: depósito, gaveta, archivo y servidor (FTP/repositorio), según el tipo de soporte de la subserie (papel, digital o ambos). Es una propiedad del par nodo–subserie (`tb_Serietree`). En AtoM el equivalente es el *almacenamiento físico* (contenedores y ubicaciones): lo crean y editan los editores y administradores; los colaboradores solo lo vinculan a lo que describen.

## 3. Decisiones del dueño del producto (2026-10-30)

1. **El EGD edita la topografía de todas las subseries de su nodo.** Solo su nodo, sin descender a hijos (igual que el resto de acciones del EGD).
2. **Se mantiene la regla de los días** de eliminación/edición del sistema actual.
3. Lo demás de este documento es decisión mía, a revisar (sección 7).

## 4. Matriz de acciones por rol

| Acción | Administrador | EGD (su nodo) | Director (su nodo y sus hijos) | Usuario (subseries asignadas) | Visor |
|---|---|---|---|---|---|
| Ver documentos | todos | su nodo | su nodo e hijos | lo asignado + público | solo público |
| Agregar y editar documentos | sí | sí | sí | sí | no |
| Eliminar documentos | no (sección 11 del diseño base) | sí, dentro de la ventana de días | sí, dentro de su ventana | no | no |
| Prestar, transferir, depurar | no | sí | no | no | no |
| **Editar topografía de nodo–subserie** | sí | **sí, todas las de su nodo** | no | no | no |
| Asignar usuarios a subseries | sí | sí, dentro de su nodo | no | no | no |
| Asignar el EGD de un nodo | sí | no | no | no | no |
| Usuarios, clasificadores, estructura | sí | no | no | no | no |

**Ventana de días (se conserva la actual):** el EGD (hoy "gestor") elimina un documento hasta 5 días después de su fecha; pasado ese plazo puede editarlo pero no eliminarlo. El Director elimina hasta 1 día después. Los plazos salen de las constantes que ya existen en `UMAINFORM.pas` (5 y 1) y no cambian en este trabajo.

## 5. Cambios de interfaz y de datos

1. **Quién ve los controles de topografía** deja de depender del campo `tb_Serietree.gestor`. Pasa a decidirlo el alcance: administrador, o EGD del nodo del registro actual (`PuedeRealizar` con una acción nueva de topografía). El campo `gestor` queda como dato informativo; no se borra ni se migra.
2. **Mensaje al agregar documentos** cuando falta la topografía: si el usuario puede editarla, se le lleva a ella; si no, "Falta la ubicación de esta subserie en tu área. Avisa al especialista de gestión documental de tu nodo." Nunca se manda a una pantalla vedada.
3. **Pantalla "Permisos de mi área"** (EGD): asigna usuarios a subseries de su nodo (`tb_usuario_subserie`). Pendiente de la Fase 2 del plan maestro.
4. **Pantalla de asignación de EGD y directores por nodo** (administrador), con vía de acceso desde el primer arranque para que el administrador no quede bloqueado. También Fase 2.
5. Los botones vistos hoy por rol (menú de gestión de contenido, exportar, etc.) se reorganizan por rol según la matriz, sin quitar funciones al administrador.
6. Solo SQL Server. En Access no cambia nada (sin alcance, todo visible).

## 6. No objetivos y riesgos

- No se migra ni se borra el campo `gestor` ni los roles viejos (`Archivero` queda tal cual).
- No se cambian los plazos de 5 y 1 días.
- No se filtra por alcance préstamos, transferencias ni depuración (limitación ya aceptada).
- Riesgo: tres copias casi iguales de `ConfiguracionPorRol` en `UMAINFORM.pas` (alrededor de las líneas 4700, 4986 y 5201); el cambio debe aplicarse a las tres o unificarse primero.
- Riesgo: hoy el rol del login (`Gestor`) y el EGD del alcance son cosas distintas; un usuario puede ser Gestor sin ser EGD de ningún nodo (caso `egd_a43`). La regla nueva exige estar asignado como EGD; mientras no exista la pantalla de asignación se asigna por script.

## 7. Decisiones mías (a revisar)

- El Usuario nunca edita topografía, solo la usa.
- El Director no edita topografía (solo lo hace el EGD, igual que en el diseño base).
- Los plazos de 5 y 1 días se aplican por rol viejo (Gestor y Director) tal como hoy; no se trasladan a Usuario porque el Usuario no elimina.
- Orden de trabajo: (a) acción de topografía y mensaje de agregar (arregla a `egd_a43` con la asignación por script), (b) pantalla de asignación de EGD, (c) "Permisos de mi área".
- La comparación con AtoM se hizo con su manual y wikis públicas; no cubren quién gestiona el almacenamiento físico, así que el reparto Usuario/EGD sigue el de una wiki de biblioteca, no una norma de AtoM.

## 8. Se deja al constructor

Diseño visual de las pantallas, redacción exacta de los mensajes, forma de unificar las tres copias de `ConfiguracionPorRol`, y las pruebas de las reglas nuevas (las reglas puras caben en `UAlcance.pas`).
