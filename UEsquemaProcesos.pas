unit UEsquemaProcesos;

{ ---------------------------------------------------------------------------
  Esquema de los procesos archivisticos (prestamo, transferencia, depuracion).
  Solo RTL + FireDAC (sin TUDM ni VCL) para poder probarlo desde una consola.

  Aditivo e idempotente: cada sentencia es independiente y un fallo (por
  ejemplo "ya existe") no impide ejecutar las demas ni toca datos existentes.
  Copia documental del DDL de SQL Server: SCRIPTS/procesos_tablas.sql

  Tablas comunes (F0):
    prc_proceso      : un proceso (tipo, numero, estado, paso, nodo remitente).
    prc_unidad       : documentos incluidos en el proceso (y su caja, si la hay).
    prc_evento       : bitacora de cambios de estado.
    prc_autorizacion : acta y acuerdo de la Comision (una por proceso).
    prc_bloqueo      : candado por documento (un proceso abierto a la vez).
    prc_prestamo     : datos propios del prestamo (solicitante, fechas, devolucion).
    prc_transferencia / prc_cronograma / prc_caja / prc_verificacion: transferencias.
  Las tablas propias de cada modulo (cajas, incidencias, testigos, muestras,
  datos del prestamo) las agrega cada fase en este mismo archivo.
  Tipo: 'P' prestamo, 'T' transferencia, 'D' depuracion.
  Estado: 'C' en curso, 'F' finalizado, 'X' cancelado.
  --------------------------------------------------------------------------- }

interface

uses
  FireDAC.Comp.Client;

{ Sentencias DDL en el orden de ejecucion, para SQL Server o Access. Es pura
  (sin conexion): permite probar el esquema sin base de datos. }
function SentenciasEsquemaProcesos(EsSqlServer: Boolean): TArray<string>;

{ Crea las tablas e indices que falten. Nunca lanza por "ya existe". }
procedure CrearEsquemaProcesos(Conn: TFDConnection; EsSqlServer: Boolean);

implementation

uses
  System.SysUtils;

function SentenciasEsquemaProcesos(EsSqlServer: Boolean): TArray<string>;
var
  Lista: TArray<string>;
  TId, TBit, TBitNo, TLargo: string;

  procedure Agregar(const Sql: string);
  begin
    SetLength(Lista, Length(Lista) + 1);
    Lista[High(Lista)] := Sql;
  end;

  { SQL Server: solo si la tabla no existe. Access: se ejecuta y el fallo por
    "ya existe" se ignora al ejecutar. }
  procedure Tabla(const Nombre, Definicion: string);
  begin
    if EsSqlServer then
      Agregar('IF OBJECT_ID(''dbo.' + Nombre + ''', ''U'') IS NULL CREATE TABLE ' +
        Nombre + ' (' + Definicion + ');')
    else
      Agregar('CREATE TABLE ' + Nombre + ' (' + Definicion + ');');
  end;

  { Columna agregada despues de crear la tabla. SQL Server: solo si falta. Access: el
    fallo por "ya existe" se ignora al ejecutar. }
  procedure Columna(const ATabla, Nombre, Definicion: string);
  begin
    if EsSqlServer then
      Agregar('IF COL_LENGTH(''' + ATabla + ''', ''' + Nombre + ''') IS NULL ALTER TABLE ' +
        ATabla + ' ADD ' + Nombre + ' ' + Definicion)
    else
      Agregar('ALTER TABLE ' + ATabla + ' ADD COLUMN ' + Nombre + ' ' + Definicion);
  end;

  procedure Indice(const Nombre, ATabla, Columnas: string);
  begin
    if EsSqlServer then
      Agregar('IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = ''' + Nombre +
        ''' AND object_id = OBJECT_ID(''dbo.' + ATabla + ''')) CREATE INDEX ' +
        Nombre + ' ON ' + ATabla + ' (' + Columnas + ')')
    else
      Agregar('CREATE INDEX ' + Nombre + ' ON ' + ATabla + ' (' + Columnas + ')');
  end;

begin
  Lista := nil;
  if EsSqlServer then
  begin
    TId := 'INT IDENTITY(1,1) NOT NULL';
    TBit := 'BIT NOT NULL DEFAULT 1';
    TBitNo := 'BIT NOT NULL DEFAULT 0';
    TLargo := 'VARCHAR(500)';
  end
  else
  begin
    TId := 'COUNTER';
    TBit := 'BIT';
    TBitNo := 'BIT';
    TLargo := 'VARCHAR(255)';
  end;

  Tabla('prc_proceso',
    'IdProceso ' + TId + ', ' +
    'Tipo VARCHAR(1) NOT NULL, ' +
    'Anio INT NOT NULL, ' +
    'Consecutivo INT NOT NULL, ' +
    'Numero VARCHAR(20) NOT NULL, ' +
    'Estado VARCHAR(1) NOT NULL, ' +
    'Paso INT NOT NULL, ' +
    'IdEstructura VARCHAR(50) NOT NULL, ' +
    'IdNodo INT NOT NULL, ' +
    'Creado DATETIME NULL, ' +
    'CreadoPor VARCHAR(100) NULL, ' +
    'Cerrado DATETIME NULL, ' +
    'CONSTRAINT PK_prc_proceso PRIMARY KEY (IdProceso), ' +
    'CONSTRAINT UQ_prc_proceso_numero UNIQUE (Tipo, Anio, Consecutivo), ' +
    'CONSTRAINT FK_prc_proceso_tree FOREIGN KEY (IdEstructura, IdNodo) ' +
    'REFERENCES tb_tree(IdEstructura, id)');

  Tabla('prc_unidad',
    'IdProceso INT NOT NULL, ' +
    'IdEstructura VARCHAR(50) NOT NULL, ' +
    'id INT NOT NULL, ' +
    'codsubs VARCHAR(50) NOT NULL, ' +
    'Codigodoc VARCHAR(20) NOT NULL, ' +
    'fecha DATETIME NOT NULL, ' +
    'version VARCHAR(12) NOT NULL, ' +
    'Caja INT NULL, ' +
    'Activa ' + TBit + ', ' +
    'CONSTRAINT PK_prc_unidad PRIMARY KEY (IdProceso, IdEstructura, id, codsubs, Codigodoc, fecha, version), ' +
    'CONSTRAINT FK_prc_unidad_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE');

  Tabla('prc_evento',
    'IdEvento ' + TId + ', ' +
    'IdProceso INT NOT NULL, ' +
    'Fecha DATETIME NULL, ' +
    'Usuario VARCHAR(100) NULL, ' +
    'Paso INT NULL, ' +
    'Texto ' + TLargo + ' NULL, ' +
    'CONSTRAINT PK_prc_evento PRIMARY KEY (IdEvento), ' +
    'CONSTRAINT FK_prc_evento_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE');

  Tabla('prc_autorizacion',
    'IdProceso INT NOT NULL, ' +
    'Organo VARCHAR(1) NOT NULL, ' +
    'NumActa VARCHAR(30) NOT NULL, ' +
    'NumAcuerdo VARCHAR(30) NOT NULL, ' +
    'Fecha DATETIME NULL, ' +
    'RegistradoPor VARCHAR(100) NULL, ' +
    'CONSTRAINT PK_prc_autorizacion PRIMARY KEY (IdProceso), ' +
    'CONSTRAINT FK_prc_autorizacion_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE');

  // Candado: una fila por documento retenido por un proceso abierto. La clave
  // primaria es el documento, asi que la base impide que dos procesos lo retengan
  // a la vez aunque dos usuarios lo intenten en el mismo instante.
  Tabla('prc_bloqueo',
    'IdEstructura VARCHAR(50) NOT NULL, ' +
    'id INT NOT NULL, ' +
    'codsubs VARCHAR(50) NOT NULL, ' +
    'Codigodoc VARCHAR(20) NOT NULL, ' +
    'fecha DATETIME NOT NULL, ' +
    'version VARCHAR(12) NOT NULL, ' +
    'IdProceso INT NOT NULL, ' +
    'CONSTRAINT PK_prc_bloqueo PRIMARY KEY (IdEstructura, id, codsubs, Codigodoc, fecha, version), ' +
    'CONSTRAINT FK_prc_bloqueo_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE');

  // Datos propios del prestamo (uno por proceso de tipo 'P').
  Tabla('prc_prestamo',
    'IdProceso INT NOT NULL, ' +
    'Solicitante VARCHAR(150) NOT NULL, ' +
    'Carnet VARCHAR(20) NULL, ' +
    'Entidad VARCHAR(150) NULL, ' +
    'TipoUsuario VARCHAR(1) NOT NULL, ' +
    'FEntrega DATETIME NULL, ' +
    'FLimite DATETIME NULL, ' +
    'FDevolucion DATETIME NULL, ' +
    'AtendidoPor VARCHAR(100) NULL, ' +
    'Obs VARCHAR(255) NULL, ' +
    'Completo BIT NULL, ' +
    'IdPrestamoViejo VARCHAR(12) NULL, ' +
    'CONSTRAINT PK_prc_prestamo PRIMARY KEY (IdProceso), ' +
    'CONSTRAINT FK_prc_prestamo_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE');

  // Datos propios de la transferencia (uno por proceso de tipo 'T').
  Tabla('prc_transferencia',
    'IdProceso INT NOT NULL, ' +
    'FPrevista DATETIME NULL, ' +
    'FEntrega DATETIME NULL, ' +
    'EntregadoPor VARCHAR(100) NULL, ' +
    'Obs VARCHAR(255) NULL, ' +
    'CONSTRAINT PK_prc_transferencia PRIMARY KEY (IdProceso), ' +
    'CONSTRAINT FK_prc_transferencia_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE');

  // Recepcion en el archivo central (paso 5) y ubicacion de las cajas (paso 6).
  Columna('prc_transferencia', 'FRecepcion', 'DATETIME NULL');
  Columna('prc_transferencia', 'RecibidoPor', 'VARCHAR(100) NULL');
  Columna('prc_transferencia', 'Ubicacion', 'VARCHAR(255) NULL');
  // F3: archivo central que recibe y registro general de entrada (Anexo 17).
  Columna('prc_transferencia', 'IdArchivoDestino', 'SMALLINT NULL');
  Columna('prc_transferencia', 'NumRegistroEntrada', 'VARCHAR(30) NULL');

  // Cronograma anual: una transferencia prevista por unidad (nodo) y ano.
  Tabla('prc_cronograma',
    'IdCronograma ' + TId + ', ' +
    'Anio INT NOT NULL, ' +
    'IdEstructura VARCHAR(50) NOT NULL, ' +
    'IdNodo INT NOT NULL, ' +
    'FPrevista DATETIME NOT NULL, ' +
    'IdProceso INT NULL, ' +
    'CONSTRAINT PK_prc_cronograma PRIMARY KEY (IdCronograma), ' +
    'CONSTRAINT UQ_prc_cronograma UNIQUE (Anio, IdEstructura, IdNodo), ' +
    'CONSTRAINT FK_prc_cronograma_tree FOREIGN KEY (IdEstructura, IdNodo) ' +
    'REFERENCES tb_tree(IdEstructura, id)');

  // Cajas de la transferencia (numeracion consecutiva por proceso).
  Tabla('prc_caja',
    'IdProceso INT NOT NULL, ' +
    'Caja INT NOT NULL, ' +
    'Tipo VARCHAR(100) NULL, ' +
    'Descripcion VARCHAR(255) NULL, ' +
    'FDesde DATETIME NULL, ' +
    'FHasta DATETIME NULL, ' +
    'Unidades INT NOT NULL, ' +
    'CONSTRAINT PK_prc_caja PRIMARY KEY (IdProceso, Caja), ' +
    'CONSTRAINT FK_prc_caja_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE');

  // F3: recepcion y ubicacion por caja. Estado: P pendiente, R recibida, Q cuarentena,
  // F faltante; NULL se lee como pendiente (Access no admite bien DEFAULT al agregar).
  Columna('prc_caja', 'Deposito', 'VARCHAR(255) NULL');
  Columna('prc_caja', 'Gaveta', 'VARCHAR(20) NULL');
  Columna('prc_caja', 'Posicion', 'VARCHAR(10) NULL');
  Columna('prc_caja', 'Estado', 'VARCHAR(1) NULL');
  Columna('prc_caja', 'Conservacion', 'VARCHAR(255) NULL');

  // Faltas y danos detectados en la recepcion. Estado: A abierta, C cerrada.
  Tabla('prc_incidencia',
    'IdIncidencia ' + TId + ', ' +
    'IdProceso INT NOT NULL, ' +
    'Caja INT NULL, ' +
    'Tipo VARCHAR(20) NOT NULL, ' +
    'Descripcion VARCHAR(255) NULL, ' +
    'FechaLimite DATETIME NULL, ' +
    'Estado VARCHAR(1) NOT NULL, ' +
    'Usuario VARCHAR(100) NULL, ' +
    'Fecha DATETIME NULL, ' +
    'CONSTRAINT PK_prc_incidencia PRIMARY KEY (IdIncidencia), ' +
    'CONSTRAINT FK_prc_incidencia_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE');

  // Verificaciones previas a la entrega (casillas marcadas por el usuario).
  Tabla('prc_verificacion',
    'IdProceso INT NOT NULL, ' +
    'Codigo VARCHAR(30) NOT NULL, ' +
    'Marcada ' + TBitNo + ', ' +
    'CONSTRAINT PK_prc_verificacion PRIMARY KEY (IdProceso, Codigo), ' +
    'CONSTRAINT FK_prc_verificacion_proceso FOREIGN KEY (IdProceso) ' +
    'REFERENCES prc_proceso(IdProceso) ON DELETE CASCADE');

  // Para saber rapido que documentos de un nodo estan bloqueados.
  Indice('IX_prc_unidad_nodo', 'prc_unidad', 'IdEstructura, id');
  // Para los contadores y pestanas de cada pantalla.
  Indice('IX_prc_proceso_estado', 'prc_proceso', 'Estado, Tipo');
  // Para la bitacora de un proceso.
  Indice('IX_prc_evento_proceso', 'prc_evento', 'IdProceso');
  // Para los vencimientos de los prestamos.
  Indice('IX_prc_prestamo_limite', 'prc_prestamo', 'FLimite');
  // Para las incidencias de una transferencia.
  Indice('IX_prc_incidencia_proceso', 'prc_incidencia', 'IdProceso');
  // Para listar las unidades de una caja.
  Indice('IX_prc_unidad_caja', 'prc_unidad', 'IdProceso, Caja');

  Result := Lista;
end;

procedure CrearEsquemaProcesos(Conn: TFDConnection; EsSqlServer: Boolean);
var
  Sql: string;
begin
  for Sql in SentenciasEsquemaProcesos(EsSqlServer) do
  begin
    try
      Conn.ExecSQL(Sql);
    except
      // Ya existe o no aplica: se ignora, igual que CrearEsquemaAlcance.
    end;
  end;
end;

end.
