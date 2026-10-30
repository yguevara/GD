# Pantalla de asignación de EGD y directores por nodo

Fecha: 2026-10-30. Estado: borrador para aprobación. Complementa `2026-10-30-roles-y-topografia-design.md` y `2026-10-29-rediseno-archigenio-design.md`; si algo choca, manda este documento para lo que trata.

## 1. Intención

Al instalar el sistema, el administrador debe poder dejar asignados los responsables de **todos los nodos de una vez**. Hoy no existe pantalla: el EGD se asigna con `scripts/asignar_egd.sql` y los directores con SQL directo. Sin asignaciones, nadie más que el administrador puede trabajar.

## 2. Decisiones del dueño del producto (2026-10-30)

1. Se usa la **opción B** de las maquetas: árbol de nodos con casillas a la izquierda; a la derecha se elige usuario y rol, y se pulsa "Asignar a los marcados".
2. **Varios por nodo:** un nodo puede tener varios EGD y varios responsables del otro rol ("administradores" del nodo). Pueden ser propios del nodo o venir de un nivel superior.
3. **Obligatorio:** el nodo siempre debe tener al menos **un EGD propio**, aunque tenga otros heredados. El otro rol puede no tener responsable propio.
4. **Herencia hacia los hijos, recursiva:** lo asignado a un nodo vale para todos sus descendientes; al asignar o quitar se propaga.
5. **Alcance del EGD:** acceso total en su nodo y, en todos los nodos hijos, puede ver toda la información. El Director ve toda la información de su nodo y de todos los hijos.

## 3. Supuestos míos (a revisar; el dueño no los confirmó)

- **"Administrador del nodo" = Director.** Es el rol que ya existe (`tb_tree_directors`, `idrol = 3`): ve su nodo y todos sus hijos, sin administrar el sistema. Si fuera un tercer rol con permisos propios, este diseño cambia.
- **Qué significa "propio" frente a "heredado":** "propio" es una asignación escrita en ese nodo; "heredado" es la que llega del ancestro. La herencia de **acceso** se calcula con el árbol (no se copia fila por fila). Para que cada nodo tenga su EGD propio, la casilla "incluir hijos" **crea una asignación propia en cada hijo marcado**.
- **Quitar:** quitar a una persona de un nodo borra su asignación propia de ese nodo. Con "incluir hijos" borra también las propias de los descendientes. Lo heredado de un ancestro no se borra desde el hijo (se quita en el ancestro); en pantalla sale en gris y bloqueado.
- **Acciones del EGD en los hijos:** solo **ver** (lectura). Agregar, editar, eliminar, prestar, transferir, depurar y topografía siguen siendo solo en su propio nodo. Esto es lo que dice "acceso total en su nodo y lectura en los hijos".
- **La obligación de un EGD propio es un aviso, no un bloqueo:** la pantalla lista y cuenta los nodos sin EGD propio ("12 nodos sin EGD") y permite filtrarlos, pero guardar con pendientes está permitido, porque al instalar no siempre se conocen todos.

## 4. Datos

- `tb_nodo_egd` hoy tiene clave primaria `(IdEstructura, id)`: un solo EGD por nodo. Pasa a **`(IdEstructura, id, user_id)`**. Es un cambio de esquema: va por `CrearEsquemaAlcance` (idempotente, ambos motores) con migración para bases ya creadas (SQL Server: quitar y recrear la clave primaria sin perder filas; Access: la tabla está vacía y se recrea). Los ejecutables viejos no deben fallar.
- `tb_tree_directors (IdEstructura, id, user_id, idrol)` ya admite varios por nodo. Su `user_id` es el `Idresp` (entero) de `cl_Resp_Gest_Arch` y el rol se guarda como `idrol = 3` (Ruling 8 del trabajo anterior). El EGD, en cambio, se guarda por **nombre de usuario** (`tb_user.nombreuser`). La pantalla debe manejar las dos formas y crear la fila de `tb_user` si falta.
- Solo SQL Server. En modo Access la pantalla no aparece.

## 5. Reglas (cambio en `UAlcance.pas`)

- El **EGD** de un nodo pasa a: ver todo en su nodo y en todos los descendientes; el resto de acciones, solo en su nodo. Cambia `Permite`, `NodosVisibles`, `NodosCompletos` y, por tanto, el filtro SQL del árbol y de documentos.
- Varios EGD o directores por nodo: las reglas ya iteran todas las asignaciones; hay que cubrirlo con pruebas.
- Quedan sin cambio: el Director (nodo e hijos, ver/agregar/editar), el Usuario por subserie, el Visor y el administrador.
- Las pruebas actuales que fijan "el EGD no desciende" (`EGD_NoDesciende` y las del filtro SQL) se reescriben con la regla nueva.

## 6. La pantalla

- Entrada: menú de administración, visible solo para el rol Administrador. El administrador ve todo, así que no puede quedar bloqueado antes de asignar a nadie.
- Izquierda: el árbol completo con casillas; cada nodo muestra sus EGD y directores propios y, en gris, los heredados; indicador de "sin EGD propio" y filtro para listarlos.
- Derecha: usuario (solo los habilitados de `cl_Resp_Gest_Arch`), rol (EGD o Director), casilla "incluir hijos", botones "Asignar a los marcados" y "Quitar de los marcados".
- Un solo guardado transaccional: o se aplican todas las asignaciones o ninguna.
- Se registra en el log quién asignó o quitó qué y dónde.

## 7. No objetivos

- No incluye "Permisos de mi área" (el EGD asignando usuarios a subseries): es otra pantalla.
- No cambia el login, las contraseñas ni la gestión de usuarios.
- No protege contra quien abra la base directamente con la cuenta técnica (ya aceptado).
- No se asignan Usuarios por subserie aquí.

## 8. Se deja al constructor

Diseño visual exacto, redacción de mensajes, cómo cargar un árbol de cientos de nodos de forma fluida, y la estrategia de pruebas de la parte visual (las reglas y la migración sí llevan pruebas automáticas).
