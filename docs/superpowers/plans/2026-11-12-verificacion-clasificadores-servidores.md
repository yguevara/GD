# Verificación manual — Servidores FTP/S3 (pantalla nueva)

Plan: `2026-11-12-clasificadores-base-y-servidores.md`. Diseño: `docs/superpowers/specs/2026-11-12-clasificadores-design.md`.
Entrar como administrador y abrir **Clasificadores → Servidores**.

Estado: la apariencia se comprobó con capturas de pantalla el 2026-11-12 (tabla sin rejilla, panel lateral, selector FTP/S3, botones). Pendiente de ejecutar con el usuario todo lo que sigue.

## Apariencia

- [ ] La tabla ocupa todo el ancho, sin aspecto de Excel (encabezado suave, líneas finas, fila elegida resaltada).
- [ ] Al elegir una fila se abre el panel lateral a la derecha con su ficha; ✕ y Esc lo cierran.
- [ ] "Nuevo servidor" abre el panel con S3 / MinIO elegido y puerto 9000.
- [ ] Los botones Guardar, Cancelar y Eliminar se ven completos y no se tocan.
- [ ] Tema claro y tema oscuro de Windows (la paleta cambia).
- [ ] El buscador filtra la tabla mientras se escribe; "Exportar" genera el Excel.

## Review Focus del plan

- [ ] **1. Editar S3 sin volver a escribir la clave secreta:** crear un servidor S3, cerrar y volver a abrirlo; cambiar la región y guardar con la clave secreta vacía; "Probar conexión" sigue funcionando.
- [ ] **2. Eliminar un servidor en uso:** el servidor FTP `localhost` lo usan documentos; "Eliminar" muestra "lo usan N documento(s) o fichero(s)" y no lo borra.
- [ ] **3. Cambios sin guardar:** escribir en un campo y (a) elegir otra fila, (b) pulsar ✕, (c) cerrar la ventana, (d) pulsar Cancelar: en todos pregunta antes de descartar.
- [ ] **4. Datos inválidos:** puerto vacío o 0, nombre vacío, bucket vacío: aparece un mensaje bajo cada campo, sin excepción y sin guardar.
- [ ] **5. Interruptor y respaldo:** con `clasificadores_clasico.flag` junto al ejecutable se abre la pantalla vieja; sin el archivo, la nueva. Si la nueva falla al abrirse, se abre la vieja y se escribe `clasificadores_error.log`.
- [ ] **6. "Probar conexión" sin red:** con un servidor inexistente muestra un mensaje claro y la ventana no se congela.

## Alta de MinIO de punta a punta

- [ ] "Nuevo servidor" → S3 / MinIO: nombre, dirección (endpoint), puerto, HTTPS si aplica, bucket, región, clave de acceso y clave secreta.
- [ ] "Probar conexión" con un MinIO real: resultado correcto (o el motivo del fallo).
- [ ] Guardar: la fila aparece como "S3 / MinIO"; el estado pasa a "Correcto" tras una prueba satisfactoria.
- [ ] Subir un documento con ese servidor como destino de ficheros nuevos y comprobar que el fichero aparece en el bucket.

## Registro de uso

- [ ] El log del sistema registra "Accediendo al clasificador de Servidores FTP." (14) y "Abandonando…" (15).
