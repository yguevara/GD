# Verificación manual — Archivos (pantalla nueva)

Plan: `2026-11-12-clasificador-archivos.md`. Diseño: `docs/superpowers/specs/2026-11-12-clasificadores-design.md`.
Entrar como administrador y abrir **Clasificadores → Archivos**.

Estado: se comprobó con capturas que la pantalla abre dentro de la ventana principal, que la lista muestra los 4 archivos con sus columnas y que el panel muestra nombre, tipo, responsable y la descripción con formato. **No se pudo comprobar visualmente** el ajuste final de los bloques de croquis y foto (botones Cambiar / Ver / Quitar y el texto "Sin croquis"), ni el flujo de guardar desde la pantalla: la automatización de pantalla perdió el foco. Los datos y las reglas sí están cubiertos por pruebas automáticas (540/540 a esa fecha, 12 de ellas de escritura sobre una base real de pruebas).

## Dentro de la ventana principal

- [ ] La pantalla queda dentro de la ventana principal, con "Clasificadores / Archivos" en la cabecera; Inicio o Archivo la cierran (con confirmación si hay cambios).
- [ ] Con `clasificadores_clasico.flag` junto al ejecutable se abre la pantalla vieja; sin él, la nueva.

## Review Focus del plan

- [ ] **1. Editar solo el nombre** de un archivo que tiene croquis, foto y descripción: después de guardar siguen igual (comprobar en la pantalla: miniaturas y descripción intactas). *Pruebas automáticas:* `Guardar_Editar_NoTocaImagenesNiDescripcion`.
- [ ] **2. Descripción con formato (RTF):** abrir "Desarrollo", no tocar la descripción, cambiar el nombre y guardar; el texto y su formato se conservan. Después editar la descripción (negrita, otra línea) y guardar; vuelve a abrirse igual.
- [ ] **3. Eliminar un archivo en uso** por una subserie, un documento, un nodo o un préstamo: mensaje con el número de usos y no se borra. *Pruebas:* `Eliminar_EnUsoPor...`.
- [ ] **4. Imagen inválida o enorme:** "Cambiar" con un `.txt` renombrado a `.jpg` muestra un aviso y no cambia nada; una foto de varios MB se guarda reducida (máximo 1600 px).
- [ ] **5. Cambios pendientes:** elegir otro archivo, pulsar ✕, cerrar o cambiar de sección después de elegir una imagen nueva (sin guardar) pregunta antes de descartar.
- [ ] **6. Validación:** nombre vacío o sin tipo muestra el mensaje bajo el campo, sin guardar nada.

## Apariencia

- [ ] Los bloques de Croquis y Foto caben en el panel: miniatura a la izquierda y los tres botones (Cambiar, Ver, Quitar) completos a la derecha; sin imagen se lee "Sin croquis" / "Sin foto".
- [ ] "Ver" abre la imagen en el visor de Windows; "Quitar" la deja como "Sin ...". Guardar aplica el cambio.
- [ ] Tema claro y oscuro.
- [ ] El buscador filtra la tabla; "Exportar" genera el Excel.

## Extremo a extremo

- [ ] Crear un archivo nuevo (nombre, tipo, responsable, un croquis y una foto reales, descripción) y guardarlo; aparece en la lista con "Sí" en Croquis y Foto y se abre de nuevo con todo.
- [ ] Eliminar el archivo de prueba creado.
