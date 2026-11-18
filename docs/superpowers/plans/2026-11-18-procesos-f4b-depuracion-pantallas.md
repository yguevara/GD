# Depuracion F4b (pantallas C1-C3 y Acta de eliminacion) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Que el EGD pueda proponer, autorizar, documentar (acta, muestra, testigos), ejecutar y cerrar una depuracion desde una pantalla del shell, e imprimir el Acta de eliminacion fisica (Anexo 19), con la pantalla vieja como respaldo.

**Architecture:** Una pantalla `UDepuracionForm` + `.dfm` (clase `TfrmDepuracionNueva`) con el mismo molde que `UTransferenciasForm`: lista (C1) y ficha con tira de pasos y un panel por paso (C2 = pasos 1 a 3, C3 = paso 4), embebida en el shell (`IPantallaProceso`). Los datos vienen de `UDepuracionDatos`/`UDepuracionReglas` (entrega a). Los textos y lineas del acta salen de funciones puras con pruebas; el impreso es FastReport. `TMAIN.AbrirDepuracion` abre la pantalla nueva y cae a `D3` (pantalla vieja) con `procesos_clasico.flag`, sin shell o si falla.

**Tech Stack:** Delphi 10.3, VCL + DevExpress (los componentes que ya usa `UTransferenciasForm`), FastReport, DUnitX para lo puro, arnes de capturas para lo visual.

**Spec:** `docs/superpowers/specs/2026-11-18-depuracion-f4-design.md` (entrega b). Maquetas aprobadas: `docs/superpowers/maquetas/2026-11-12-procesos-maqueta.html` (C1, C2, C3). Molde: `UTransferenciasForm.pas/.dfm`, `UTransferenciasImpresos.pas`, `TMAIN.AbrirTransferencias`.

## Global Constraints

- **TODA interfaz nueva lleva su `.dfm`** (regla del usuario): el codigo solo llena datos y reacciona a eventos; solo componentes que el IDE abre sin paquetes propios (VCL estandar y los DevExpress que ya usa `UTransferenciasForm`); nunca `TBotonShell`/`TCajaBusqueda`/controles de `UShellPrincipal`; dibujos especiales en `TPaintBox` cuyo `OnPaint` llama a `UProcesoPintura` (`PintarPasos`). Colores base del `.dfm` = paleta clara (`CLARO_*`), la pantalla los adapta en `AplicarTema`.
- Mensajes por `UMensajes` (`TMensajes.Informacion/Advertencia/Error/Exito/Confirmar`); nunca `MessageBox/MessageDlg/ShowMessage`.
- Codigo nuevo en ASCII (acentos con `#NNN`); los `.pas`/`.dfm` existentes son ANSI/CRLF: editar sin cambiar la codificacion; los archivos nuevos creados con Write se pasan a CRLF.
- Solo el EGD del nodo actua (`PuedeActuar`, `FijarNodosDeTrabajo(NodosDondeActua(acDepurar), ...)`): el Administrador y el Visor ven pero no actuan; el boton responde explicando por que.
- Cada unidad nueva se agrega a `ArchiGenioPro.dpr` (`in 'UFoo.pas' {frmFoo}` para formularios) y, si es pura, a `Pruebas/PruebasArchiGenio.dpr` (`in '..\UFoo.pas'`).
- Compilar: `scripts/compilar.ps1 Pruebas/PruebasArchiGenio.dproj` y `scripts/compilar.ps1 ArchiGenioPro.dproj`; suite: `ARCHIGENIO_TEST_DB=SGDTEST_ALCANCE` + `Pruebas\Win32\Debug\PruebasArchiGenio.exe` (`scratchpad/suite.sh`). Linea base: **931 pasan, 0 fallan** (la prueba visual `UPruebasPanelDocumentos.Propiedades_MensajeReemplazaTodo` falla a veces: repetir).
- Verificacion visual con el **arnes temporal fuera del repo** (scratchpad `arnes/`: proyecto copiado de `ArchiGenioPro.dproj` con `DCC_UnitSearchPath` al repo, crea el formulario desde su `.dfm`, llama a los `Mostrar*` con datos de ejemplo y guarda capturas con `PrintWindow`): capturas a 100 % y 125 % de cada vista; revisar a ojo sin solapes ni textos cortados. Borrar `dcu`/exe al acabar.
- Commits selectivos (nunca `Win32/Debug/*.dcu` ni `ArchiGenioPro.identcache`), terminados con `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`. Al agregar un archivo con `git add` en `scripts/`, usar la ruta en minusculas (`scripts/...`).
- Recuerdo al usuario al terminar cada cambio visible: cerrar y reabrir la app; la pantalla no se probo con su base.

## Review Focus

- Administrador o Visor abren la pantalla: ningun boton de accion actua; explican por que (Tasks 4 a 7).
- `eliminar` en minusculas, vacio o con otra palabra: el boton Ejecutar no ejecuta y lo dice (Task 6).
- Dos usuarios ejecutan a la vez o la ficha esta desactualizada: el segundo recibe un aviso claro («ya no esta en este paso») y la pantalla se refresca (Tasks 4 a 6).
- Sin archivos de tipo Central o sin series depurables: la propuesta explica por que esta vacia en vez de quedar en blanco (Task 4).
- Acta con muchas series, descripciones de muestra largas o 1 documento: sigue legible y sin cortar (Task 2).
- 125 % de escala y tema oscuro: sin solapes (Tasks 3 a 6).
- Cancelar una depuracion en paso 4 o posterior no se ofrece (Task 6).

---

### Task 1: Textos puros del acta y de la lista

**Files:**
- Modify: `UDepuracionReglas.pas`
- Test: `Pruebas/UPruebasDepuracionReglas.pas`

**Interfaces:** Consumes: `UAutorizacion` (`TAutorizacion`, `TOrganoComision`). Produces (sin VCL):
```
function UnidadesNumerosYLetras(N: Int64): string;                 // '1 240 (mil doscientas cuarenta)'; separador de miles = espacio; 0 => '0 (cero)'
function RangoMesAnio(Desde, Hasta: TDateTime): string;            // '01/2008 - 12/2012'; mismo mes => '03/2010'; Desde = 0 => ''
function TextoAutorizacionCorto(const A: TAutorizacion): string;   // 'Comision Prov. - Ac. 14/Ac. 9'... ver pruebas
```

- [ ] **Step 1: Tests** (nombre y aserciones):
  - `UnidadesNumerosYLetras`: `1240` => `'1 240 (mil doscientas cuarenta)'`; `0` => `'0 (cero)'`; `1` => `'1 (una)'`; `85` => `'85 (ochenta y cinco)'`; `1000000` => `'1 000 000 (un millon)'`; `-1` lanza `EArgumentException`.
  - `RangoMesAnio(EncodeDate(2008,1,15), EncodeDate(2012,12,3))` => `'01/2008 - 12/2012'`; mismos mes y ano => `'03/2010'`; `Desde = 0` => `''`; `Hasta = 0` con `Desde` dado => solo el mes de `Desde`.
  - `TextoAutorizacionCorto`: `ocProvincial`, acta `'14'`, acuerdo `'9'` => `'Comision Prov. - Acta 14 - Acuerdo 9'`; `ocMunicipal` => `'Comision Mun. - ...'`; `ocNacional` => `'Comision Nac. - ...'`; `ocCentral` => `'Comision Central - ...'` (no deberia darse, pero no lanza).
- [ ] **Step 2:** Compilar y ejecutar la suite. Expected: FAIL (no compila).
- [ ] **Step 3:** Implementar (`UnidadesEnLetras` ya existe: reutilizarla; el separador de miles se arma a mano, no con `FormatSettings`).
- [ ] **Step 4:** Suite. Expected: PASS.
- [ ] **Step 5: Commit** `feat(depuracion): textos puros del acta y de la lista`.

### Task 2: Acta de eliminacion fisica (Anexo 19): lineas e impreso

**Files:**
- Create: `UDepuracionActa.pas` (puro: usa `UDepuracionDatos`, `UDepuracionReglas`; sin FastReport), `UDepuracionImpresos.pas` (FastReport + FireDAC), `MAISEL REPORT/Report/rActaEliminacion.fr3`, `Pruebas/UPruebasDepuracionActa.pas`; agregar `UDepuracionActa` y `UPruebasDepuracionActa` a los dos `.dpr` y `UDepuracionImpresos` a `ArchiGenioPro.dpr`.

**Interfaces:** Consumes: Task 1, `UDepuracionDatos` (`TGrupoDepuracion`, `TActaDepuracion`, `TTestigoFila`, `TAnioCantidad`, `GruposDeLaDepuracion`, `DesglosePorAnio`, `LeerActaDepuracion`, `TestigosDeLaDepuracion`), `UTransferenciasImpresos`/`UImpresosComun` (patron: `NuevaTablaMemoria`, `ConectarDataset`, `CadenaFr`, `EmpresaDe`, `FechaTexto`). Produces:
```
// UDepuracionActa (puro)
type
  TLineaActa = record Descripcion, Unidades, Fechas, MuestraDesc, MuestraDonde: string; end;
  TFirmaActa = record Nombre, Cargo: string; end;
function LineasActaDepuracion(const Grupos: TArray<TGrupoDepuracion>; const A: TActaDepuracion): TArray<TLineaActa>;
function FirmasActaDepuracion(const T: TArray<TTestigoFila>): TArray<TFirmaActa>;   // en el orden de alta; Cargo vacio => ''
function TextoCabeceraActa(const Organo, NumActa, NumAcuerdo: string; FAutorizacion, FEjecucion: TDateTime; const Lugar: string; Via: TViaEliminacion): string;

// UDepuracionImpresos (FastReport)
procedure ImprimirActaDepuracion(Conn: TFDConnection; IdProceso: Integer; const CarpetaReportes: string);
function PrepararActaDepuracion(const Fr3: string; const D: TDatosActa): TfrxReport;   // TDatosActa: Empresa, Numero, textos de cabecera, Lineas, Desglose, Firmas
```
Dataset en memoria `Lineas` (Descripcion, Unidades, Fechas, MuestraDesc, MuestraDonde) y `Desglose` (Anio, Unidades), conectados a las bandas `MasterData1` y `MasterData2` del `.fr3`; variables `Empresa`, `Numero`, `Cabecera`, `TotalUnidades`, `Firma1..Firma3`/`Firmas` (lo que decida el diseno del informe).

- [ ] **Step 1: Tests puros** (`UPruebasDepuracionActa`):
  - `LineasActaDepuracion` con un grupo (`Serie` 'Facturas de proveedores', `Unidades` 1240, `Desde` 01/01/2008, `Hasta` 31/12/2012) y acta con muestra `'Facturas de enero de cada ano'` / `'Dep. 1 - Est. B - Caja M-2'` => una linea con `Descripcion` `'Facturas de proveedores'`, `Unidades` `'1 240 (mil doscientas cuarenta)'`, `Fechas` `'01/2008 - 12/2012'` y la muestra copiada; dos grupos => dos lineas en el orden dado, con la **misma** muestra en cada una; sin grupos => vacio; descripcion de 300 caracteres no se recorta (el informe la estira).
  - `FirmasActaDepuracion`: tres testigos => tres firmas en orden de alta con nombre y cargo; cargo nulo => `''`.
  - `TextoCabeceraActa('Provincial','14','9',03/09/2026, 20/11/2026,'Planta de reciclaje municipal', veTrituracion)` contiene `'Provincial'`, `'Acta 14'`, `'Acuerdo 9'`, `'03/09/2026'`, `'20/11/2026'`, `'Planta de reciclaje municipal'` y `'Trituracion'`; sin fecha de ejecucion (0) usa la prevista del acta como `'Fecha prevista'`... (decidir el texto y fijarlo en la prueba).
- [ ] **Step 2:** Registrar y compilar. Expected: FAIL.
- [ ] **Step 3:** Implementar `UDepuracionActa`; despues `UDepuracionImpresos` (cabecera desde `prc_proceso`, `prc_autorizacion`, `prc_depuracion`; `EmpresaDe`) y `rActaEliminacion.fr3` (UTF-8 XML, mismo estilo que `rRelacionEntrega.fr3`: titulo `ACTA DE ELIMINACION FISICA DE LOS DOCUMENTOS`, cabecera con Comision/acta/acuerdo/fechas/lugar/via, tabla de lineas con `Stretched`, desglose por ano, totales y las firmas de los testigos al pie con linea de firma, nombre y cargo).
- [ ] **Step 4:** Suite. Expected: PASS. Con el arnes, exportar el informe a PNG con datos de ejemplo (1 serie corta; 3 series con muestra larga; 5 testigos) y revisar que se lee entero, con `Stretched` funcionando y las firmas no partidas entre paginas.
- [ ] **Step 5: Commit** `feat(depuracion): Acta de eliminacion fisica (Anexo 19)`.

### Task 3: Pantalla: esqueleto, lista (C1) y ficha con tira de pasos

**Files:**
- Create: `UDepuracionForm.pas`, `UDepuracionForm.dfm` (clase `TfrmDepuracionNueva`, implementa `IPantallaProceso`; ojo: la pantalla vieja se llama `Tfrmdepuracion`); agregar a `ArchiGenioPro.dpr` como `UDepuracionForm in 'UDepuracionForm.pas' {frmDepuracionNueva}`.

**Interfaces:** Consumes: `UDepuracionDatos` (`ListarDepuraciones`, `TDepuracionFila`), `UDepuracionReglas` (Task 1: `TextoAutorizacionCorto`, `RangoMesAnio`), `UProcesoPintura.PintarPasos`, `UPantallaProceso` (`IPantallaProceso`), `UOpcionNodo`, `UTema`. Produces (publicos, igual que `TfrmTransferenciasNuevo`):
```
constructor Create(AOwner: TComponent); override;
procedure Iniciar(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>; const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario; const Usuario: string);
procedure FijarNodosDeTrabajo(const Opciones: TArray<TOpcionNodo>; const Preferido: TClaveNodo);
procedure MostrarLista(const Filas: TArray<TDepuracionFila>);
procedure MostrarDetalle(const Fila: TDepuracionFila);
procedure Embeber(Host: TWinControl); function PuedeSalir: Boolean; procedure FijarAlSalir(const Valor: TNotifyEvent);
property PuedeActuar: Boolean; property AlImprimirActa: TImprimirDepuracion;   // TImprimirDepuracion = reference to procedure(IdProceso: Integer)
function CrearPantallaDepuracion(Conn: TFDConnection; const Nodos: TArray<TClaveNodo>; const NodoActual: TClaveNodo; Alcance: TAlcanceUsuario; const Usuario: string): TfrmDepuracionNueva;
```

- [ ] **Step 1:** Crear el `.dfm` y el `.pas` siguiendo `UTransferenciasForm` (cabecera con titulo «Depuracion», selector de nodo de trabajo, `Abrir` y `Nueva depuracion`; cuadricula C1 con columnas N.º, Series, Unidades, Fechas extremas (`RangoMesAnio`), Autorizacion, Paso («N de 5») y Estado (`TextoEstadoDepuracion`); contadores por estado si el molde los tiene; ficha con `pbPasos` (`PintarPasos` con los nombres `Propuesta, Autorizacion, Acta, Ejecucion, Cierre`), cabecera de la ficha, barra inferior con `Volver a la lista`, `Cancelar depuracion` y `Eliminar` (aun sin acciones) y cinco paneles de paso vacios `pnlPaso1..pnlPaso5` que solo se muestran segun el paso). `Recargar` llama a `ListarDepuraciones(FConn, FNodos, FAnio, LIMITE_LISTA)`.
- [ ] **Step 2:** Compilar `ArchiGenioPro.dproj`. Expected: sin errores.
- [ ] **Step 3:** Arnes: escenas «lista con 3 depuraciones» (la del mockup C1: D-2026-01 Circulares internas 320 2005-2010 Comision Prov. Ac. 5/2026 paso 5 Ejecutada; D-2026-02 Facturas de proveedores 1 240 2008-2012 paso 3 Acta por firmar; D-2026-03 Control de asistencia 85 2010-2013 sin autorizacion paso 1 Propuesta), «lista vacia» y «ficha en el paso 3» (solo cabecera y tira). Capturas a 100 % y 125 %; revisar y ajustar el `.dfm`.
- [ ] **Step 4: Commit** `feat(depuracion): pantalla (esqueleto, lista C1 y ficha con tira de pasos)`.

### Task 4: Pasos 1 y 2 (propuesta y autorizacion)

**Files:**
- Modify: `UDepuracionForm.pas`, `UDepuracionForm.dfm` (`pnlPaso1`, `pnlPaso2`)

**Interfaces:** Consumes: `ProponerDepuracion`, `CrearDepuracion`, `AgregarGrupoDepuracion`, `QuitarGrupoDepuracion`, `GruposDeLaDepuracion`, `AvanzarDepuracion`, `CondicionesCumplidasDepuracion`, `GuardarAutorizacion` (`UProcesosDatos`), `LeerAutorizacion` (`UTransferenciasDatos`). Produces metodos publicos de presentacion: `MostrarPropuesta(const Grupos: TArray<TGrupoDepuracion>)`, `MostrarAgregados(const Grupos: TArray<TGrupoDepuracion>)`, `MostrarAutorizacion(Hay: Boolean; const A: TAutorizacion)`, `MostrarFaltan(const Textos: TArray<string>)`.

- [ ] **Step 1:** `.dfm`: paso 1 = cuadricula «Propuesta» (Serie, Plazo en el central («N anos»), Unidades, Fechas extremas, Observacion con «N retenidos por otro proceso») + boton `Agregar`; cuadricula «Ya agregado» (Serie, Unidades, Fechas) + `Quitar`; texto de ayuda. Paso 2 = organo (`TcxComboBox` solo Nacional/Provincial/Municipal), N.º de acta, N.º de acuerdo, fecha, boton `Registrar autorizacion` y un aviso de lo que falta.
- [ ] **Step 2:** Codigo: `btnNuevaClick` crea la depuracion (`CrearDepuracion` en el nodo de trabajo y el ano actual) y abre su ficha; `btnAgregarClick` (confirma y llama a `AgregarGrupoDepuracion`; `Motivo` por `TMensajes.Advertencia`); `btnQuitarClick`; `btnRegistrarAutClick` (`GuardarAutorizacion`; `EAutorizacionInvalida` por `lblAviso`); `btnAvanzarClick` (`AvanzarDepuracion`; si devuelve `False`, muestra `Faltan` o, si ya no esta en el paso, «otro usuario ya la avanzo» y refresca). Sin `PuedeActuar` cada boton llama a `AvisarSinPermiso` (explica que solo el EGD del nodo actua). La propuesta vacia dice por que: sin archivo Central o Historico, sin series con destino *Eliminarlo* y plazo en el central, o nada vencido todavia.
- [ ] **Step 3:** Compilar. Arnes: «propuesta con 2 grupos y 1 agregado», «propuesta vacia por falta de archivo central», «autorizacion sin registrar» y «autorizacion registrada»; 100 % y 125 %.
- [ ] **Step 4: Commit** `feat(depuracion): pasos 1 y 2 (propuesta y autorizacion)`.

### Task 5: Paso 3 (acta) e impresion del acta

**Files:**
- Modify: `UDepuracionForm.pas`, `UDepuracionForm.dfm` (`pnlPaso3`)

**Interfaces:** Consumes: `GuardarActaDepuracion`, `LeerActaDepuracion`, `AgregarTestigo`, `QuitarTestigo`, `MarcarFirma`, `TestigosDeLaDepuracion`, `DesglosePorAnio`, `GruposDeLaDepuracion`, Task 1 (`UnidadesNumerosYLetras`), `ImprimirActaDepuracion` (via `AlImprimirActa`). Produces: `MostrarActa(const A: TActaDepuracion; const Grupos: TArray<TGrupoDepuracion>; const Desglose: TArray<TAnioCantidad>)`, `MostrarTestigos(const T: TArray<TTestigoFila>)`.

- [ ] **Step 1:** `.dfm` por secciones (como la maqueta C2, no una hoja de calculo): «Autorizacion» (solo lectura), «Que se elimina» (series con unidades en numeros y letras y fechas extremas, mas la cuadricula de desglose por ano), «Muestra que se conserva (obligatoria)» (descripcion, donde queda), «Ejecucion» (lugar, via `TcxComboBox` Incineracion/Trituracion, fecha prevista), «Testigos y firmas» (cuadricula Nombre, Cargo, Origen, Firmo; alta con nombre, cargo y origen; `Quitar`) y el recordatorio «Para pasar a Ejecucion hace falta: autorizacion cargada, muestra definida y al menos 2 testigos, uno de la Comision y uno de un archivo de gestion» con lo que falta en rojo/verde; botones `Guardar acta`, `Imprimir acta` (visible si `AlImprimirActa` esta asignado) y `Pasar a ejecucion` (la barra inferior comun).
- [ ] **Step 2:** Codigo: `btnGuardarActaClick` (`GuardarActaDepuracion`; `EArgumentException` por `lblAviso`), alta/baja de testigos y marca de firma, refresco de «lo que falta» con `CondicionesCumplidasDepuracion` cada vez que algo cambia.
- [ ] **Step 3:** Compilar. Arnes: «acta vacia», «acta completa con 3 testigos y desglose de 5 anos», «acta con dos series y muestra larga»; 100 % y 125 %.
- [ ] **Step 4: Commit** `feat(depuracion): paso 3 (acta, muestra y testigos) e impresion del acta`.

### Task 6: Pasos 4 y 5 (ejecucion C3 y cierre) y acciones de la barra

**Files:**
- Modify: `UDepuracionForm.pas`, `UDepuracionForm.dfm` (`pnlPaso4`, `pnlPaso5`)

**Interfaces:** Consumes: `EjecutarDepuracion`, `CerrarDepuracion`, `CancelarProceso`/`EliminarProceso` (`UProcesosDatos`), `ConfirmacionEscritaValida`, `PuedeCancelar`/`PuedeEliminar` (`UProceso`). Produces: `MostrarEjecucion(const Fila: TDepuracionFila; const Checks: TArray<TCheckEjecucion>)` con `TCheckEjecucion = record Texto: string; Cumplido: Boolean; end`.

- [ ] **Step 1:** `.dfm` paso 4 (C3): «Se marcaran como eliminados N documentos (serie, fechas)», cuatro comprobaciones con marca (acuerdo de la Comision con su acta y fecha; muestra definida con sus unidades y donde queda; N testigos y cuantos firmaron; ningun documento en prestamo ni en transferencia), la advertencia «Esta accion no se puede deshacer. Escribe ELIMINAR para confirmar», la caja de texto y `Ejecutar eliminacion` (desactivado mientras la palabra no sea valida) y `Volver`. Paso 5: texto «Eliminacion ejecutada el DD/MM/AAAA por ...», `Imprimir acta` y `Cerrar la depuracion` (la entrega c agregara aqui los ficheros).
- [ ] **Step 2:** Codigo: `edtConfirmacionChange` habilita el boton con `ConfirmacionEscritaValida`; `btnEjecutarClick` pide una ultima confirmacion con `TMensajes.Confirmar` y llama a `EjecutarDepuracion(FConn, Id, FUsuario, edtConfirmacion.Text, Date)`; `EArgumentException` por `lblAviso`; `False` => «ya no esta en este paso» y refresca; `btnCerrarClick` -> `CerrarDepuracion`. Barra inferior: `Cancelar depuracion` solo si `PuedeCancelar(tpDepuracion, Paso)` (hasta el paso 3) con motivo; `Eliminar` solo si `PuedeEliminar` (canceladas o aun cancelables). Sin permiso: `AvisarSinPermiso`.
- [ ] **Step 3:** Compilar. Arnes: «paso 4 con todo cumplido», «paso 4 con una comprobacion en rojo» (boton desactivado), «paso 5», «depuracion cancelada»; 100 % y 125 %, claro y oscuro.
- [ ] **Step 4: Commit** `feat(depuracion): pasos 4 y 5 (ejecucion con confirmacion reforzada y cierre)`.

### Task 7: Conexion con la ventana principal y cierre de la entrega

**Files:**
- Modify: `UMAINFORM.pas` (`TMAIN.AbrirDepuracion` + el clic de la seccion + uses), `CLAUDE.md`, memoria `project_procesos_archivisticos`
- Create: `docs/superpowers/plans/2026-11-18-verificacion-depuracion-f4b.md`

**Interfaces:** Consumes: `CrearPantallaDepuracion`, `ImprimirActaDepuracion`, `NodosDondeActua(acDepurar)`, `NodosDelArbolElegido`, `AbrirPantallaProceso`, `ProcesosClasicos`, `RegistrarErrorProceso`. Produces: `procedure TMAIN.AbrirDepuracion;` declarado en la clase.

- [ ] **Step 1:** `TMAIN.AbrirDepuracion` copia el patron de `AbrirTransferencias`: si `ProcesosClasicos(PathSys)` o no hay shell o falla, `D3.Click` (pantalla vieja); si no, crea la pantalla, `FijarNodosDeTrabajo(NodosDondeActua(acDepurar), Nodos[0])`, asigna `AlImprimirActa` (carpeta `Report` junto al exe, errores por `TMensajes.Error`) y `AbrirPantallaProceso(Pantalla, 'Depuracion', 'Depuracion')`. En el despachador de secciones (`SECCION_DEPURACION`) reemplazar `D3.Click` por `AbrirDepuracion`.
- [ ] **Step 2:** Compilar `ArchiGenioPro.dproj` y la suite completa. Expected: sin errores; todo pasa; la base de pruebas intacta (`sqlcmd`: `tb_nodo_egd` con `egd_a43`, T-2026-01/02, sin filas `__prueba__`).
- [ ] **Step 3:** Capturas finales de todas las vistas (100 % y 125 %, claro y oscuro) y lista manual de verificacion: abrir Depuracion como EGD, crear una depuracion, agregar un grupo, registrar la autorizacion, llenar el acta, probar `eliminar` en minusculas, ejecutar, imprimir el acta, cerrar; como Administrador: ningun boton actua. Documentar que antes hay que tener un archivo Central, una serie con destino *Eliminarlo* y `tcentral`, y documentos en ese archivo.
- [ ] **Step 4:** Actualizar `CLAUDE.md` (entrega b) y la memoria; copiar `rActaEliminacion.fr3` a `Win32\Debug\Report` si la compilacion no lo hace.
- [ ] **Step 5: Commit** `feat(depuracion): conexion con la ventana principal y cierre de la entrega b`.

---

## Self-review

- **Cobertura del spec (entrega b):** pantallas C1, C2, C3 y su `.dfm` (T3 a T6); Acta Anexo 19 en FastReport con rutinas comunes (T2); `TMAIN.AbrirDepuracion` con respaldo a la pantalla vieja por `procesos_clasico.flag`, sin shell o si falla (T7); solo el EGD actua y los demas ven (T4 a T7); confirmacion `ELIMINAR` (T6); verificacion con arnes a 100/125 % (T3 a T7). Fuera de esta entrega: retiro de ficheros, migracion y retirada de `UDepuracion` (c).
- **Consistencia de tipos:** `TLineaActa`, `TFirmaActa`, `TCheckEjecucion`, `TImprimirDepuracion` y los records de `UDepuracionDatos` se definen una vez; los metodos `Mostrar*` de T4 a T6 se llaman igual en el arnes y en `Recargar/CargarPaso`.
- **Proporcion:** lo visual se verifica con capturas, no con pruebas automaticas; lo puro (T1, T2) lleva sus pruebas.
