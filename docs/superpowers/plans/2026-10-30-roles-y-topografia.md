# Roles, topografía y eliminación del EGD — Plan de implementación

> **Para quien ejecute:** SUB-SKILL REQUERIDA: superpowers:subagent-driven-development (recomendada) o superpowers:executing-plans. Los pasos usan casillas `- [ ]`.

**Meta:** que el EGD de un nodo edite la topografía de sus subseries y elimine documentos sin ventana de días, que un Usuario sin ese permiso reciba un mensaje útil al agregar, y limpiar y documentar en español el código tocado.

**Arquitectura:** las reglas nuevas son puras y viven en `UAlcance.pas` (con pruebas DUnitX). La validación topográfica se extrae a `UTopografia.pas` (pura). `UMAINFORM.pas` y `UCapaDatos.pas` solo consumen esas reglas. En modo Access (`UDM.Alcance = nil`) el comportamiento no cambia.

**Tecnología:** Delphi 10.3, VCL, FireDAC, DUnitX (`Pruebas/PruebasArchiGenio.dproj`).

**Spec:** `docs/superpowers/specs/2026-10-30-roles-y-topografia-design.md` (base: `2026-10-29-rediseno-archigenio-design.md`).

## Restricciones globales

- Fuentes en ANSI/Windows-1252: no normalizar a UTF-8 ni cambiar fines de línea (`UMAINFORM.pas` y `UCapaDatos.pas` mezclan CRLF y LF; editar por bytes, p. ej. con un script que lea y escriba `latin-1`). Un archivo nuevo con acentos se guarda en Windows-1252.
- Todo SQL debe valer en Access y SQL Server.
- Comentarios y documentación de lo tocado en español: cabecera por rutina con propósito, parámetros, efectos y quién puede usarla.
- Ventana de días del Director: 1 día (la lógica existente); el EGD no tiene ventana; el Administrador no elimina por reglas puras (su rama heredada de la interfaz no cambia).
- Compilar: `powershell -NoProfile -File scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y `... ArchiGenioPro.dproj`. Pruebas: `Pruebas/Win32/Debug/PruebasArchiGenio.exe` con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` (nunca `SGDDRHMAIN`).
- No tocar `SerPerf.dpr`, `UConfig/` ni `VARIABLES VIRTUALES…`. No hacer merge ni push.

## Review Focus

1. Nodos con `id` repetido (160 en A.1.7, A.3.3, A.4.6): ser EGD de uno no da topografía ni eliminación en otro (Tarea 2).
2. `IdEstructura` con mayúsculas o espacios (`a.4.3 `): la regla lo trata como el mismo nodo (Tarea 1).
3. Fila nueva sin `Fecha` (días desconocidos): cuenta como 0 días, nunca como "infinito" que abra de más a un Director (Tarea 1).
4. `idsoporte` 0 o nulo: la topografía se considera completa, como hoy (Tarea 3).
5. Modo Access (`UDM.Alcance = nil`) y login de administrador: sin cambios de comportamiento (Tarea 5).

---

### Tarea 1: Reglas puras de topografía y eliminación

**Files:**
- Modify: `UAlcance.pas` (tipo `TAccion`, `RolPermite`, clase `TAlcanceUsuario`)
- Test: `Pruebas/UPruebasAlcance.pas`

**Interfaces:**
- Produces: `TAccion` gana `acEditarTopografia` (al final, después de `acAsignarUsuarios`). `RolPermite(rnEGD, acEditarTopografia) = True`, `RolPermite(rnAdministrador, acEditarTopografia) = True`, `False` para Visor, Usuario y Director.
- Produces: `function TAlcanceUsuario.PuedeEliminarDocumento(const Nodo: TClaveNodo; const CodSubs: string; DiasDesdeFecha: Integer): Boolean`. Reglas: administrador → `False`; EGD asignado exactamente a `Nodo` → `True` con cualquier número de días; Director cuyo nodo es ancestro o igual de `Nodo` → `DiasDesdeFecha <= 1`; Usuario y Visor → `False`. `DiasDesdeFecha < 0` se trata como 0. Nodo asignado que no existe en el árbol no concede nada.

- [ ] **Paso 1: escribir las pruebas que fallan** en `TPruebasAlcance`: `EGD_EditaTopografiaDeSuNodo` (EGD de A.4/101: `PuedeRealizar(acEditarTopografia, A.4/101, '074')` True; sobre el hijo A.4.3/104 False), `Director_UsuarioYVisor_NoEditanTopografia`, `Administrador_EditaTopografia`, `EGD_EliminaSinVentanaDeDias` (días 0, 6 y 4000 → True), `Director_EliminaSoloElPrimerDia` (hijo del nodo asignado: días 1 → True, 2 → False, -5 → True), `Usuario_Visor_Administrador_NoEliminan`, `Eliminar_NodoRepetido160_NoMezcla` (EGD de A.4.6/160 no elimina en A.1.7/160), `Eliminar_ClaveConEspacios` (EGD de `A.4.6` elimina en `a.4.6 `).
- [ ] **Paso 2: compilar y ejecutar; esperado:** error de compilación `E2003 Undeclared identifier: 'acEditarTopografia'` (rojo).
- [ ] **Paso 3: implementar** `acEditarTopografia`, la rama en `RolPermite` y `PuedeEliminarDocumento` (apoyarse en `MismoNodo`, `FArbol.Contiene` y `FArbol.EsDescendiente` como hace `Permite`). Documentar en español las dos rutinas.
- [ ] **Paso 4: compilar y ejecutar; esperado:** todas las pruebas pasan (las 60 anteriores más las nuevas).
- [ ] **Paso 5: commit** `git add UAlcance.pas Pruebas/UPruebasAlcance.pas` — "Reglas puras: topografia del EGD y eliminacion sin ventana".

---

### Tarea 2: Las reglas con datos reales

**Files:**
- Test: `Pruebas/UPruebasAlcanceDatos.pas`
- Create: `scripts/asignar_egd.sql`

**Interfaces:**
- Consumes: `CargarAlcance(Conn, Usuario, EsAdministrador)`; `TAlcanceUsuario.PuedeRealizar`, `PuedeEliminarDocumento` (Tarea 1). Escenario ya sembrado en `TEscenario.Sembrar`: `prueba_alc_egd` es EGD de A.4/101; `prueba_alc_dir4` Director de A.4/101; `prueba_alc_usr1` Usuario de A.4.3/104 subserie 014001.

- [ ] **Paso 1: pruebas** en `TPruebasAlcanceDatosSql`: `EGD_Real_EditaTopografiaSoloDeSuNodo` (True en A.4/101, False en A.4.3/104 y en A.4.6/160), `Usuario_Director_NoEditanTopografia`, `EGD_Real_EliminaDocumentoAntiguo` (días 4000 True) y `Director_Real_EliminaSoloElPrimerDia` sobre A.4.3/104 (hijo).
- [ ] **Paso 2: ejecutar; esperado:** pasan sin cambios de producto (la lógica ya existe tras la Tarea 1); si alguna falla es un defecto de la Tarea 1 y se corrige allí.
- [ ] **Paso 3: crear `scripts/asignar_egd.sql`** con cabecera en español que explique su uso: inserta en `tb_user` (si no existe) el usuario y en `tb_nodo_egd` la pareja (`IdEstructura`, `id`, `user_id`) con parámetros `@usuario`, `@idestructura`, `@id` y un ejemplo comentado para `egd_a43` en `A.4.3` / `104`. Solo SQL Server; no se ejecuta contra `SGDDRHMAIN`.
- [ ] **Paso 4: commit** de las pruebas y el script.

---

### Tarea 3: Validación topográfica extraída y mensaje según permiso

**Files:**
- Create: `UTopografia.pas`, `Pruebas/UPruebasTopografia.pas`
- Modify: `UCapaDatos.pas` (`TUDM.tb_SeriesDatosNewRecord`), `ArchiGenioPro.dpr` (cláusula `uses`), `Pruebas/PruebasArchiGenio.dpr` y `.dproj`

**Interfaces:**
- Produces (en `UTopografia.pas`, sin VCL ni FireDAC):
  - `TDatosTopografia = record Deposito, Gaveta, Archivo, IdServidor: string; end`
  - `function TopografiaCompleta(IdSoporte: Integer; const Datos: TDatosTopografia): Boolean` — un campo está vacío si `Trim(valor) = ''` o `valor = '0'`; soporte 1 exige Deposito, Gaveta y Archivo; soporte 2 exige IdServidor; soporte 3 exige los cuatro; cualquier otro soporte (incluido 0) devuelve `True`.
  - `function MensajeTopografiaFaltante(IdSoporte: Integer; PuedeEditar: Boolean): string` — con `PuedeEditar`: los textos actuales de `tb_SeriesDatosNewRecord` (soporte 2: "No ha especificado los datos topográficos de la serie actual. Por favor especifique un servidor o repositorio válido."; resto: "Por favor especifique los datos topográficos necesarios para almacenar series en el soporte especificado."). Sin `PuedeEditar`: "Falta la ubicación de esta subserie en tu área. Avisa al especialista de gestión documental de tu nodo."
- Consumes: `UDM.Alcance` (`TAlcanceUsuario`, `nil` en Access) y `PuedeRealizar(acEditarTopografia, Nodo, CodSubs)`.

- [ ] **Paso 1: pruebas** `UPruebasTopografia`: una por soporte 0, 1, 2 y 3 con datos completos e incompletos; `'0'` y espacios cuentan como vacío; y los tres mensajes (soporte 2 con y sin permiso; otro soporte con y sin permiso).
- [ ] **Paso 2: ejecutar; esperado:** falla la compilación (unidad inexistente).
- [ ] **Paso 3: crear `UTopografia.pas`** (Windows-1252) y registrarla en ambos `.dpr`/`.dproj`.
- [ ] **Paso 4: ejecutar; esperado:** pasan todas.
- [ ] **Paso 5: usar la unidad en `tb_SeriesDatosNewRecord`:** reemplazar el `case SoporteId` y los mensajes por `TopografiaCompleta` y `MensajeTopografiaFaltante`. `PuedeEditar := (Alcance = nil) or Alcance.PuedeRealizar(acEditarTopografia, <IdEstructura e id de tb_Serietree>, CodSubs)`. Sin cambios cuando `Alcance = nil`. Cabecera en español.
- [ ] **Paso 6: compilar `ArchiGenioPro.dproj`; esperado:** sin errores. Commit.

---

### Tarea 4: Eliminar el código comentado duplicado de `UMAINFORM.pas`

**Files:**
- Modify: `UMAINFORM.pas`

- [ ] **Paso 1: localizar** el bloque que empieza en `{procedure TMAIN.dstb_SeriesDatosDataChange(Sender: TObject; Field: TField);` (primera aparición tras la rutina activa del mismo nombre, hoy línea ~4893) y termina en la línea `end;   }` justo antes de `procedure TMAIN.dstb_SerietreeDataChange` (hoy ~5480). Comprobar que dentro no queda ninguna rutina activa: todo el rango son dos bloques de llave que cierran con `end;}` y `end;   }`.
- [ ] **Paso 2: borrarlo** editando por bytes (conservar Windows-1252 y fines de línea del resto). Registrar `git diff --stat` (esperado: unas 590 líneas menos, ninguna añadida).
- [ ] **Paso 3: compilar `ArchiGenioPro.dproj`; esperado:** sin errores. Commit — "Quitar copias comentadas de dstb_SeriesDatosDataChange".

---

### Tarea 5: La interfaz del documento decide por el alcance

**Files:**
- Modify: `UMAINFORM.pas` (`TMAIN.dstb_SeriesDatosDataChange` y su declaración)
- Modify: `docs/superpowers/plans/2026-10-29-verificacion-alcance.md` (casos nuevos)

**Interfaces:**
- Consumes: `UDM.Alcance`, `PuedeRealizar(acAgregar|acEditar|acEditarTopografia, …)`, `PuedeEliminarDocumento` (Tarea 1); `GetCantOfDay` existente para los días.
- Produces: `procedure TMAIN.AplicarReglasDocumento;` (privado) que sustituye a las rutinas anidadas `GetIdResp`, `SetVisibilityForButtons`, `SetDbNavigatorButtons`, `ConfiguracionRolGestor` y `ConfiguracionPorRol` de `dstb_SeriesDatosDataChange`. Los ayudantes pasan a ser métodos privados con su propia cabecera en español.

**Comportamiento exigido:**
- Rol `administrador`: la misma rama de hoy.
- Rol `gestor` o `director` y `UDM.Alcance <> nil` (SQL Server): decide el alcance. Nodo = `IdEstructura` e `id` de `tb_Serietree`; subserie = `codsubs`; días = `GetCantOfDay(Fecha)` o 0 si `Fecha` es nula. Navegador: siempre los botones de navegar y cancelar; insertar y guardar si `PuedeRealizar(acAgregar)` o `acEditar`; borrar si `PuedeEliminarDocumento`. Botones de archivos y fuentes (`SetVisibilityForButtons`) visibles solo si puede eliminar. `JvTransparentButton5`, `btnViewtopoSS` y `mGestionarContentFile` visibles solo si `PuedeRealizar(acEditarTopografia)`. Ya no se consulta `tb_Serietree.gestor`.
- Rol `gestor` o `director` con `Alcance = nil` (Access), y roles `archivero` y `visor`: exactamente la lógica de hoy.

- [ ] **Paso 1: extraer** la lógica activa a `AplicarReglasDocumento` sin cambiar el comportamiento (compilar; mismo resultado).
- [ ] **Paso 2: añadir la rama por alcance** descrita arriba.
- [ ] **Paso 3: documentar en español** la rutina y cada ayudante.
- [ ] **Paso 4: compilar `ArchiGenioPro.dproj`; esperado:** sin errores.
- [ ] **Paso 5: añadir a `verificacion-alcance.md`** los casos: EGD asignado por `scripts/asignar_egd.sql` ve y edita la topografía de su nodo y elimina un documento de más de 5 días; Director elimina solo el primer día; Usuario sin permiso de topografía recibe "Avisa al especialista…" al agregar; modo Access y administrador sin cambios.
- [ ] **Paso 6: commit** — "La interfaz del documento decide por el alcance (topografia y eliminacion)".

---

## Verificación final

- [ ] Compilar ambos proyectos y ejecutar la suite completa con `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE`; esperado: todas pasan.
- [ ] Revisión de la rama completa con un revisor nuevo (modelo más capaz) y ledger en `.superpowers/sdd/`.
- [ ] Pendiente humano: recorrer la lista de `verificacion-alcance.md` en la aplicación real.
