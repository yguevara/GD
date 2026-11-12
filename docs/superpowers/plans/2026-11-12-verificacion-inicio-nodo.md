# Verificación manual — Pantalla de inicio del nodo (A + C + B plegable)

Qué es: lo que se ve en el área de trabajo cuando no hay nada elegido o el nodo elegido no tiene subseries (antes un espacio gris vacío). Unidades: `UInicioDatos` (cifras, con pruebas), `UInicioNodo` (panel, con pruebas), integración en `UShellPrincipal` y `TMAIN.ShellInicioDatos/ShellNodoVacio`.

Estado: comprobada con una captura de la ventana (solo la de ArchiGenio) con sesión de **visor**: aparecen las cifras reales de la base de pruebas, "Buscar un documento", el ciclo de vida y "Primeros pasos". No se probó con otros roles ni con clics.

## Cuándo aparece

- [ ] Al arrancar, si no hay nodo elegido: "Resumen de toda su área".
- [ ] Al elegir un nodo sin subseries (p. ej. la raíz "Estructura delegación"): "Resumen de <nodo> y todo lo que contiene".
- [ ] Al elegir un nodo con subseries aparece la lista de siempre, no esta pantalla.
- [ ] Mientras hay un clasificador abierto (Servidores, Archivos) esta pantalla no se superpone.

## Cifras

- [ ] Series, subseries, documentos, sin ubicación y prestados coinciden con lo que se ve en el árbol y en el bloque "Requiere acción" (sin ubicación y prestados).
- [ ] Las cifras de un nodo incluyen a sus descendientes; las de "toda su área" respetan el alcance del usuario (un visor no cuenta documentos que no puede ver).
- [ ] Cambiar de nodo o de usuario actualiza las cifras; con la pantalla a la vista se recalculan cada ~60 s.

## Acciones y etapas

- [ ] **Ciclo de vida solo para quien trabaja:** el invitado y el visor **no ven** la tarjeta del ciclo de vida; el administrador, los directores y los EGD (gestores) sí. Para el visor el tercer paso de "Primeros pasos" habla de buscar, no de agregar.

- [ ] Administrador/gestor: aparece "Agregar documento" (abre el alta) y "Ver cuadro de clasificación"; el visor y el invitado solo ven "Buscar un documento".
- [ ] "Buscar un documento" lleva el foco al buscador de la cabecera.
- [ ] Las etapas Clasificación, Préstamos, Transferencia y Depuración llevan a su sección si el usuario tiene permiso; sin permiso se ven atenuadas y no responden. Captura lleva al alta de documento.
- [ ] La etapa Ubicación es solo informativa (no hay una pantalla propia a la que llevar).

## Primeros pasos

- [ ] La primera vez se ve abierto; "Ocultar" lo pliega y queda recordado (archivo `%USERPROFILE%\AppData\Roaming\ArchiGenio\inicio.ini` o la carpeta de datos de aplicación del usuario).
- [ ] "Mostrar" lo vuelve a abrir.

## Apariencia

- [ ] Cifras y textos completos (sin cortes) a 100 % y 125 % de escala; tema claro y oscuro.

## Lo que NO incluye (a propósito)

- Cifra de Transferencia y de Depuración: no hay un dato fiable que contar (la depuración depende de reglas de retención por serie).
- "Actividad reciente": las fechas del registro del sistema están guardadas como texto con formato propio; no es un dato ordenable de forma fiable.
