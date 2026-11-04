# Fase 4: Busqueda integrada - Plan de implementacion

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Una caja de texto libre y filtros dinamicos (desde `cl_VarSubserie`) que buscan documentos en `tb_SeriesDatos` y en las tablas `md_*`, siempre dentro del alcance del usuario, en SQL Server y en Access.

**Architecture:** Dos unidades sin VCL, probables desde `Pruebas/`: `UBusqueda` (reglas puras: tipos de campo, escape de `LIKE`, validacion de nombres, generacion del SQL de una subserie) y `UBusquedaDatos` (lee `cl_VarSubserie`, ejecuta una consulta por subserie con `FiltroDocumentos` y junta los resultados en un `TFDMemTable`). La pantalla (`UBusquedaDocumentos`, por codigo, sin .dfm) solo captura y muestra.

**Tech Stack:** Delphi 10.3, FireDAC (`MSSQL` / `MSAcc`), DUnitX. Reutiliza `UAlcance` y `UAlcanceDatos` (`TFiltroSql`, `FiltroDocumentos`, `AplicarParametros`).

**Spec:** `docs/superpowers/specs/2026-10-29-rediseno-archigenio-design.md`, seccion 7 (Busqueda integrada) y las reglas de busqueda de la seccion 5. Depende de la Fase 2 (ya en el codigo). No depende de la Fase 1: la pantalla es provisional y se reubica cuando exista el shell nuevo.

## Global Constraints

- Debe funcionar en SQL Server y en Access; sin SQL propio de un motor fuera de los dos metodos que lo aislan (`ConSqlServer: Boolean`).
- Toda consulta incluye la condicion de `FiltroDocumentos(Alcance, 'S')`; `Alcance = nil` (Access) o administrador produce `1=1`.
- Nada del texto del usuario se concatena en el SQL: va como parametro. Los nombres de campo y de tabla `md_*` se validan contra `cl_VarSubserie` / `cl_subseries` y contra el patron `^[A-Za-z_][A-Za-z0-9_]*$` antes de usarse.
- El texto libre busca en los campos de tipo Caracteres y Memo de la tabla `md_*` y en `Codigodoc` y `titulodoc` de `tb_SeriesDatos`. Los filtros por fecha, numero o booleano salen del tipo del campo.
- Nombres de tipo en `CL_SubseriesTipoVar.tipo`: `Caracteres`, `Fecha`, `Entero`, `Memo`, `Real`, `Boolean` (asi lo escribe `UCapaDatos.pas`, no "Booleano").
- Las claves del documento son `IdEstructura, id, codsubs, Fecha, Version, Codigodoc`; el cruce con `md_*` usa las seis (el codigo anterior cruzaba solo por dos y duplicaba filas).
- Fuentes nuevos en ASCII puro (sin tildes), CRLF; agregarlos al `.dpr` que corresponda (`ArchiGenioPro.dpr` y `Pruebas/PruebasArchiGenio.dpr`).
- Pruebas contra base real se omiten si faltan `ARCHIGENIO_TEST_DB` (SQL Server) o `ARCHIGENIO_TEST_MDB` (copia de .mdb), con datos sembrados dentro de una transaccion que se deshace, como en `UPruebasAlcanceDatos.pas`.
- Commits por nombre de archivo y solo con autorizacion del dueno. `UMAINFORM.pas` tiene cambios sin commit del dueno: usar `git add -p` y subir solo los trozos de este plan.

## Review Focus

- Texto con `'`, `%`, `_` o `[`: se busca literalmente y no inyecta SQL (Tarea 1 y 2).
- Subserie sin `NombreTablaMetadatos`, o con tabla `md_*` inexistente o vacia: se busca solo en datos fijos / se omite, sin error (Tarea 2).
- Usuario sin asignaciones: solo ve documentos publicos; con el alcance de un nodo no aparece nada de otro (Tarea 2).
- Pedido sin texto, sin subserie y sin condiciones: se rechaza con mensaje claro en vez de listar toda la base (Tarea 1).
- Filtro sobre un campo que no es de la subserie, o rango de fechas invertido: se rechaza / se normaliza, no se ejecuta (Tarea 1).
- Mas resultados que el limite: se devuelve el limite y `Truncado = True` (Tarea 2).

---

## Estructura de archivos

| Archivo | Responsabilidad |
|---|---|
| `UBusqueda.pas` (crear) | Tipos, validaciones y generacion del SQL de una subserie. RTL solamente. |
| `UBusquedaDatos.pas` (crear) | Lectura de campos, ejecucion por subserie, resultado unico. RTL + FireDAC. |
| `UBusquedaDocumentos.pas` (crear) | Pantalla por codigo (caja, combo de subserie, filtros dinamicos, rejilla). |
| `UMAINFORM.pas` (modificar) | Entrada de menu y borrado de `BuscarSeriesDatosDinamico*` (codigo muerto sin alcance). |
| `Pruebas/UPruebasBusqueda.pas` (crear) | Pruebas de ambas unidades. |

---

### Task 1: Reglas puras y SQL de una subserie (`UBusqueda`)

**Files:**
- Create: `UBusqueda.pas`
- Test: `Pruebas/UPruebasBusqueda.pas` (clase `TPruebasBusqueda`)
- Modify: `Pruebas/PruebasArchiGenio.dpr` (agregar ambas unidades)

**Interfaces:**
- Produces:
  - `TTipoCampo = (tcCaracteres, tcFecha, tcEntero, tcMemo, tcReal, tcBooleano)`
  - `TCampoBusqueda = record Nombre, Etiqueta: string; Tipo: TTipoCampo; end`
  - `TCondicionCampo = record Campo: string; Desde, Hasta: string; end` (para Caracteres/Memo `Desde` es "contiene"; para Fecha/Entero/Real es el rango, `Hasta` vacio = solo `Desde`; para Booleano `Desde` es `'1'` o `'0'`)
  - `TPedidoBusqueda = record Texto: string; CodSubs: string; Condiciones: TArray<TCondicionCampo>; Limite: Integer; end` (`CodSubs = ''` = todas las del alcance; `Limite <= 0` = 500)
  - `function TipoDeNombre(const Nombre: string): TTipoCampo` (lanza `EArgumentException` si no es uno de los seis)
  - `function NombreSeguro(const Nombre: string): Boolean`
  - `function EscaparLike(const Texto: string): string` (cada `%`, `_` y `[` queda entre corchetes: `[%]`; valido en SQL Server y Access)
  - `function ValidarPedido(const P: TPedidoBusqueda): string` (`''` si es valido; si no, el mensaje para el usuario)
  - `function SqlSubserie(const Pedido: TPedidoBusqueda; const Campos: TArray<TCampoBusqueda>; const TablaMd: string; const FiltroAlcance: TFiltroSql; ConSqlServer: Boolean): TFiltroSql` (`Condicion` aqui es el SELECT completo; `Parametros` incluye los del alcance y los propios)

- [ ] **Step 1: Escribir las pruebas que fallan** en `TPruebasBusqueda`:
  - `EscaparLike_PorcientoGuionYCorchete`: `EscaparLike('50%_[a]')` = `'50[%][_][[]a]'`.
  - `NombreSeguro_RechazaEspaciosYComillas`: `'Depto'` True; `'a b'`, `'x;drop'`, `'1abc'`, `''` False.
  - `ValidarPedido_SinNadaSeRechaza`: texto vacio, `CodSubs=''`, sin condiciones devuelve mensaje no vacio; con solo `CodSubs` o solo texto devuelve `''`.
  - `ValidarPedido_RangoInvertido`: condicion de fecha con `Desde='2026-02-01'`, `Hasta='2026-01-01'` devuelve mensaje.
  - `SqlSubserie_ConTabla`: el texto contiene `LEFT JOIN md_014001 M ON`, las seis columnas de enlace, `S.titulodoc` y `S.Codigodoc` con `LIKE`, el texto del usuario no aparece en el SQL y si como parametro con `[%]` escapado.
  - `SqlSubserie_SinTabla`: con `TablaMd=''` no hay `JOIN` y solo busca en datos fijos.
  - `SqlSubserie_CampoAjeno`: una condicion sobre un campo que no esta en `Campos` lanza `EArgumentException`.
  - `SqlSubserie_SqlServerUsaCollate`: con `ConSqlServer=True` aparece `COLLATE Modern_Spanish_CI_AI`; con `False` no.
  - `SqlSubserie_IncluyeAlcance`: la condicion del `FiltroAlcance` aparece unida con `AND` y sus parametros se conservan.
- [ ] **Step 2: Compilar y ejecutar** (`scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj`, luego `Pruebas\Win32\Debug\PruebasArchiGenio.exe`). Esperado: no compila porque `UBusqueda` no existe.
- [ ] **Step 3: Implementar `UBusqueda.pas`** con las firmas de Interfaces. `SqlSubserie` arma `SELECT S.IdEstructura, S.id, S.codsubs, S.Fecha, S.Version, S.Codigodoc, S.titulodoc FROM tb_SeriesDatos S [LEFT JOIN <TablaMd> M ON <6 claves>] WHERE <alcance> [AND (<texto>)] [AND <condiciones>]`, con parametros `:b1, :b2...` (el prefijo no debe chocar con los del alcance; leer `TConstructorParametros` en `UAlcanceDatos.pas` y usar otro prefijo, p. ej. `:q`). El texto libre es un `OR` de `LIKE` sobre `S.Codigodoc`, `S.titulodoc` y cada campo Caracteres/Memo. Fechas y numeros se comparan con `>=`/`<=` y parametros tipados (convertir `Desde`/`Hasta` con `TFormatSettings` invariante, no con el formato regional).
- [ ] **Step 4: Compilar y ejecutar.** Esperado: todas pasan.
- [ ] **Step 5: Commit por nombre** (`UBusqueda.pas`, `Pruebas/UPruebasBusqueda.pas`, `Pruebas/PruebasArchiGenio.dpr`), con autorizacion.

### Task 2: Datos y ejecucion (`UBusquedaDatos`)

**Files:**
- Create: `UBusquedaDatos.pas`
- Modify: `Pruebas/UPruebasBusqueda.pas` (clases `TPruebasBusquedaSql`, `TPruebasBusquedaAccess`), `Pruebas/PruebasArchiGenio.dpr`

**Interfaces:**
- Consumes: Task 1 (`TPedidoBusqueda`, `TCampoBusqueda`, `SqlSubserie`, `ValidarPedido`, `TipoDeNombre`); `UAlcanceDatos` (`FiltroDocumentos`, `AplicarParametros`, `TFiltroSql`); `UAlcance` (`TAlcanceUsuario`).
- Produces:
  - `function CargarCamposSubserie(Conn: TFDConnection; const CodSubs: string): TArray<TCampoBusqueda>` (lee `cl_VarSubserie` unido a `CL_SubseriesTipoVar` por `idtipo`, ordenado por `Orden`; omite nombres que no pasan `NombreSeguro`)
  - `function TablaMetadatos(Conn: TFDConnection; const CodSubs: string): string` (`''` si la subserie no tiene `NombreTablaMetadatos`, si el nombre no es seguro o si la tabla no existe)
  - `function Buscar(Conn: TFDConnection; Alcance: TAlcanceUsuario; const Pedido: TPedidoBusqueda; ConSqlServer: Boolean; out Truncado: Boolean): TFDMemTable` (del llamador; columnas: las 7 de `SqlSubserie` mas `NombreSubserie`; lanza `Exception` con el mensaje de `ValidarPedido`)

- [ ] **Step 1: Escribir las pruebas que fallan.** Clases `TPruebasBusquedaSql` y `TPruebasBusquedaAccess` con la misma bateria (omitidas sin su variable de entorno), sembrando en transaccion: dos subseries (una con `md_*` con un campo Caracteres `Depto` y uno Fecha, otra sin `NombreTablaMetadatos`), documentos en dos nodos y un documento con `titulodoc = 'Acta 100% O''Brien'`:
  - `Buscar_TextoEnMetadato`: buscar `'Camaguey'` devuelve solo el documento cuyo `Depto` lo contiene.
  - `Buscar_PorcientoYApostrofeSonLiterales`: `'100%'` y `'O''Brien'` devuelven solo el documento sembrado (no todos).
  - `Buscar_SubserieSinTabla`: busca por titulo sin error.
  - `Buscar_TablaMdInexistente`: con `NombreTablaMetadatos` apuntando a una tabla que no existe, la subserie se busca solo en datos fijos y no lanza.
  - `Buscar_RespetaAlcance`: usuario con una subserie asignada solo ve esa mas las publicas; usuario sin asignaciones, solo publicas; administrador y `Alcance=nil`, todas.
  - `Buscar_FiltroFechaYBooleano`: rango de fechas sobre el campo Fecha incluye los extremos.
  - `Buscar_Truncado`: con `Limite=2` y 5 coincidencias, 2 filas y `Truncado=True`.
  - `Buscar_PedidoVacio`: lanza con el mensaje de `ValidarPedido`.
- [ ] **Step 2: Ejecutar con `ARCHIGENIO_TEST_DB` apuntando a la copia de pruebas.** Esperado: FALLAN (`UBusquedaDatos` no existe).
- [ ] **Step 3: Implementar `UBusquedaDatos.pas`.** `Buscar` obtiene las subseries a recorrer con `SELECT DISTINCT S.codsubs FROM tb_SeriesDatos S WHERE <FiltroDocumentos>` (o la indicada en el pedido si esta dentro de ellas), ejecuta `SqlSubserie` por cada una con una consulta nueva, copia las filas al `TFDMemTable` (agregando el nombre de la subserie desde `cl_subseries`) y se detiene al llegar a `Limite + 1` filas para marcar `Truncado`. Una consulta por subserie evita los `UNION` entre tablas con columnas distintas.
- [ ] **Step 4: Ejecutar las pruebas contra SQL Server.** Esperado: pasan.
- [ ] **Step 5: Ejecutar contra la copia `.mdb` (`ARCHIGENIO_TEST_MDB`).** Esperado: pasan. Si `EscaparLike` con `[` falla en Access, ajustar solo esa funcion y su prueba de Task 1, y dejar anotado en el codigo la diferencia observada (la comparacion de acentos en Access no es insensible: limitacion conocida, documentarla en la ayuda de la pantalla).
- [ ] **Step 6: Commit por nombre**, con autorizacion.

### Task 3: Pantalla, entrada de menu y limpieza

**Files:**
- Create: `UBusquedaDocumentos.pas` (sin .dfm, patron de `UAsignacionNodos.pas`: barra superior con Cerrar y Ayuda, barra de estado)
- Modify: `UMAINFORM.pas` (menu; borrar `BuscarSeriesDatosDinamico`, `...SQLServer`, `...MSAccess` y sus tres declaraciones, lineas 704-706 y 3237-3400 aprox.), `ArchiGenioPro.dpr`
- Create: `docs/superpowers/plans/2026-11-04-verificacion-busqueda.md`

**Interfaces:**
- Consumes: Task 2 (`Buscar`, `CargarCamposSubserie`); `UDM.Alcance` y `UDM.Conn`; `TBD = 'S'` para `ConSqlServer`.
- Produces: `procedure AbrirBusquedaDocumentos` (muestra la pantalla modal desde `TMAIN`).

- [ ] **Step 1: Escribir la lista de verificacion manual** en `docs/superpowers/plans/2026-11-04-verificacion-busqueda.md`: con los tres usuarios de `2026-10-29-verificacion-alcance.md` (administrador, EGD de `A.4.3`, usuario con una subserie) buscar por: titulo, un metadato de texto, rango de fechas, solo subserie; con `%`, `'` y `_`; mas de `Limite` resultados (aviso de truncado); modo Access (todo visible). Esperado por usuario: nunca aparece un documento fuera de su alcance.
- [ ] **Step 2: Implementar `UBusquedaDocumentos.pas`** con `procedure AbrirBusquedaDocumentos`: caja de texto, combo de subserie (solo las que devuelve el alcance, primera opcion "Todas"), y al elegir una subserie, un editor por cada campo de `CargarCamposSubserie` segun su tipo (texto, par de fechas, par numerico, casilla). Boton Buscar llama a `Buscar` (excepcion -> mensaje del sistema, `UDM.sms`), rejilla con los resultados, aviso en la barra de estado si `Truncado`. Doble clic en una fila selecciona el nodo `(IdEstructura, id)` en el arbol de `TMAIN` usando la rutina de seleccion existente (localizarla en `UMAINFORM.pas`; si no hay una reutilizable, solo mostrar la ruta del nodo y dejar la navegacion para la Fase 1).
- [ ] **Step 3: Agregar la entrada de menu en `TMAIN`** que llama a `AbrirBusquedaDocumentos`, y registrar la unidad en `ArchiGenioPro.dpr`.
- [ ] **Step 4: Borrar el codigo muerto** `BuscarSeriesDatosDinamico*` de `UMAINFORM.pas` tras confirmar con la busqueda que no tiene mas usos (`grep -n "BuscarSeriesDatosDinamico" *.pas`: solo declaraciones y definiciones).
- [ ] **Step 5: Compilar el proyecto completo** con `scripts/compilar.ps1 ArchiGenioPro.dproj`. Esperado: sin errores nuevos respecto a la linea base.
- [ ] **Step 6: Ejecutar la lista del Step 1** con la aplicacion real contra la base de pruebas y anotar el resultado en el documento, incluida la prueba en modo Access.
- [ ] **Step 7: Commit por nombre** (con `git add -p` para `UMAINFORM.pas`), con autorizacion.

---

## Autorrevision

- **Cobertura de la seccion 7:** caja de texto libre y metadatos (Task 1-2); filtros dinamicos desde `cl_VarSubserie` (Task 1-3); siempre dentro del alcance (Task 2, `FiltroDocumentos`); ambos motores (Task 2 pasos 4-5).
- **Fuera de este plan:** tabla de apoyo de busqueda (la spec la deja para si el volumen lo exige); busqueda sin acentos en Access; reubicar la pantalla en el shell de la Fase 1.
- **Dato a confirmar con el dueno:** limite de resultados por defecto (500 aqui) y si la busqueda debe incluir tambien el nombre de los archivos digitales de `tb_ssArchdigital`.
