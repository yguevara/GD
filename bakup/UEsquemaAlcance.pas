unit UEsquemaAlcance;

{ Esquema de la seguridad por alcance y de la captura masiva.
  Solo RTL + FireDAC (sin TUDM ni VCL) para poder probarlo desde una consola.
  Aditivo e idempotente: cada sentencia es independiente y un fallo (por ejemplo
  "ya existe") no impide ejecutar las demas ni toca datos existentes.
  Copia documental del DDL de SQL Server: SCRIPTS/alcance_tablas.sql }

interface

uses
  FireDAC.Comp.Client;

procedure CrearEsquemaAlcance(Conn: TFDConnection; EsSqlServer: Boolean);

implementation

uses
  System.SysUtils;

procedure CrearEsquemaAlcance(Conn: TFDConnection; EsSqlServer: Boolean);

  procedure Ejecutar(const Sql: string);
  begin
    try
      Conn.ExecSQL(Sql);
    except
      // Ya existe o no aplica: se ignora, igual que execSQLUPD.
    end;
  end;

  procedure CrearTabla(const Tabla, Sql: string);
  begin
    if EsSqlServer then
      Ejecutar('IF OBJECT_ID(''dbo.' + Tabla + ''', ''U'') IS NULL ' + Sql)
    else
      Ejecutar(Sql);
  end;

var
  TId, TFecha, TBit, TLargo: string;
begin
  if EsSqlServer then
  begin
    TId := 'INT IDENTITY(1,1) NOT NULL';
    TFecha := 'DATETIME NULL';
    TBit := 'BIT NOT NULL DEFAULT 1';
    TLargo := 'VARCHAR(500)';
  end
  else
  begin
    TId := 'COUNTER';
    TFecha := 'DATETIME NULL';
    TBit := 'BIT';
    TLargo := 'VARCHAR(255)';
  end;

  CrearTabla('tb_nodo_egd',
    'CREATE TABLE tb_nodo_egd (' +
    'IdEstructura VARCHAR(50) NOT NULL, ' +
    'id INT NOT NULL, ' +
    'user_id VARCHAR(100) NOT NULL, ' +
    'CONSTRAINT PK_tb_nodo_egd PRIMARY KEY (IdEstructura, id), ' +
    'CONSTRAINT FK_tb_nodo_egd_tree FOREIGN KEY (IdEstructura, id) ' +
    'REFERENCES tb_tree(IdEstructura, id), ' +
    'CONSTRAINT FK_tb_nodo_egd_user FOREIGN KEY (user_id) ' +
    'REFERENCES tb_user(nombreuser));');

  CrearTabla('tb_usuario_subserie',
    'CREATE TABLE tb_usuario_subserie (' +
    'IdEstructura VARCHAR(50) NOT NULL, ' +
    'id INT NOT NULL, ' +
    'codsubs VARCHAR(50) NOT NULL, ' +
    'user_id VARCHAR(100) NOT NULL, ' +
    'CONSTRAINT PK_tb_usuario_subserie PRIMARY KEY (IdEstructura, id, codsubs, user_id), ' +
    'CONSTRAINT FK_tb_usuario_subserie_tree FOREIGN KEY (IdEstructura, id) ' +
    'REFERENCES tb_tree(IdEstructura, id), ' +
    'CONSTRAINT FK_tb_usuario_subserie_user FOREIGN KEY (user_id) ' +
    'REFERENCES tb_user(nombreuser));');

  // Captura masiva: solo esquema, sin claves foraneas a tablas de documentos.
  CrearTabla('tb_lote_captura',
    'CREATE TABLE tb_lote_captura (' +
    'idlote ' + TId + ', ' +
    'fecha ' + TFecha + ', ' +
    'user_id VARCHAR(100) NULL, ' +
    'origen VARCHAR(255) NULL, ' +
    'estado VARCHAR(20) NULL, ' +
    'IdEstructura VARCHAR(50) NULL, ' +
    'id INT NULL, ' +
    'codsubs VARCHAR(50) NULL, ' +
    'CONSTRAINT PK_tb_lote_captura PRIMARY KEY (idlote));');

  CrearTabla('tb_lote_captura_item',
    'CREATE TABLE tb_lote_captura_item (' +
    'idlote INT NOT NULL, ' +
    'orden INT NOT NULL, ' +
    'archivo ' + TLargo + ' NULL, ' +
    'codigo_barras VARCHAR(100) NULL, ' +
    'estado VARCHAR(20) NULL, ' +
    'Codigodoc VARCHAR(20) NULL, ' +
    'error ' + TLargo + ' NULL, ' +
    'CONSTRAINT PK_tb_lote_captura_item PRIMARY KEY (idlote, orden), ' +
    'CONSTRAINT FK_tb_lote_captura_item_lote FOREIGN KEY (idlote) ' +
    'REFERENCES tb_lote_captura(idlote) ON DELETE CASCADE);');

  CrearTabla('tb_regla_carpeta',
    'CREATE TABLE tb_regla_carpeta (' +
    'idregla ' + TId + ', ' +
    'ruta ' + TLargo + ' NULL, ' +
    'IdEstructura VARCHAR(50) NULL, ' +
    'id INT NULL, ' +
    'codsubs VARCHAR(50) NULL, ' +
    'user_id VARCHAR(100) NULL, ' +
    'activa ' + TBit + ', ' +
    'CONSTRAINT PK_tb_regla_carpeta PRIMARY KEY (idregla));');

  // Vinculacion opcional a Active Directory (silencioso si ya existe).
  if EsSqlServer then
    Ejecutar('IF COL_LENGTH(''dbo.cl_Resp_Gest_Arch'', ''usuario_ad'') IS NULL ' +
      'ALTER TABLE cl_Resp_Gest_Arch ADD usuario_ad VARCHAR(256) NULL')
  else
    Ejecutar('ALTER TABLE cl_Resp_Gest_Arch ADD COLUMN usuario_ad VARCHAR(255) NULL');
end;

end.
