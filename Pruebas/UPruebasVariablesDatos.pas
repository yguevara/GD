unit UPruebasVariablesDatos;

{ Variables del formulario de una subserie (UVariablesDatos).
  Validacion y tipos: sin base de datos. Guardado, modo y columnas: SQL Server
  (ARCHIGENIO_TEST_DB = SGDTEST_ALCANCE); cada prueba siembra la serie ZZ1 y su
  subserie ZZ1A y lo borra al terminar (incluida la tabla md_ZZ1ZZ1A). Codigo en
  ASCII. }

interface

uses
  FireDAC.Comp.Client, DUnitX.TestFramework, UMetadatosSubserie, UVariablesDatos;

type
  [TestFixture]
  TPruebasVariablesValidar = class
  private
    function V(const ANombre, AEtiqueta: string; ATipo: TTipoMeta; ALong: Integer): TCampoMeta;
  public
    [Test]
    procedure NombreReservado_SqlServer;
    [Test]
    procedure NombreReservado_Access_SoloEnAccess;
    [Test]
    procedure ColumnaBase_Fecha;
    [Test]
    procedure NombreDuplicado;
    [Test]
    procedure EtiquetaDuplicada;
    [Test]
    procedure CaracteresSinLongitud;
    [Test]
    procedure NombreConEspaciosOAcentos;
    [Test]
    procedure NombreQueEmpiezaPorDigito;
    [Test]
    procedure ListaCorrecta_SinErrores;
    [Test]
    procedure Existente_NoSeLeExigeSintaxis;
    [Test]
    procedure SqlTipoColumna_SqlServer;
    [Test]
    procedure SqlTipoColumna_Access;
    [Test]
    procedure NombreTablaDatos_Caracteres;
  end;

  [TestFixture]
  TPruebasVariablesBD = class
  private
    FConn: TFDConnection;
    function V(const ANombre, AEtiqueta: string; ATipo: TTipoMeta; ALong: Integer): TCampoMeta;
    procedure CrearTabla(const ACols: string);
    function ColumnaExiste(const ACol: string): Boolean;
    function NumDefiniciones: Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Modo_SinTabla_Libre;
    [Test]
    procedure Modo_TablaHuerfana_Libre;
    [Test]
    procedure Modo_ConTabla_SoloAnadir;
    [Test]
    procedure Guardar_Libre_ReemplazaYOrdena;
    [Test]
    procedure Guardar_Libre_GuardaObligatorioYDescripcion;
    [Test]
    procedure Guardar_SoloAnadir_CreaColumna_YFilaViejaQuedaNull;
    [Test]
    procedure Guardar_SoloAnadir_NoPermiteRenombrar;
    [Test]
    procedure Guardar_SoloAnadir_NoPermiteQuitar;
    [Test]
    procedure Guardar_SoloAnadir_NoPermiteCambiarTipo;
    [Test]
    procedure Guardar_SoloAnadir_PermiteCambiarEtiquetaObligatorioOrden;
    [Test]
    procedure Guardar_Fallo_NoDejaMediasTintas;
    [Test]
    procedure Guardar_ValidacionFalla_NoEscribe;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.DApt,
  FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UErroresCampo;

const
  SERIE = 'ZZ1';
  SUBS = 'ZZ1A';
  TABLA = 'md_ZZ1ZZ1A';

{ TPruebasVariablesValidar }

function TPruebasVariablesValidar.V(const ANombre, AEtiqueta: string; ATipo: TTipoMeta;
  ALong: Integer): TCampoMeta;
begin
  Result := Default(TCampoMeta);
  Result.Nombre := ANombre;
  Result.Etiqueta := AEtiqueta;
  Result.Tipo := ATipo;
  Result.Longitud := ALong;
end;

procedure TPruebasVariablesValidar.NombreReservado_SqlServer;
var
  E: TArray<TErrorCampo>;
begin
  E := ValidarVariables([V('select', 'Seleccion', tmTexto, 10)], True);
  Assert.AreEqual(1, Length(E));
  Assert.AreEqual('select.nombre', E[0].Campo);
end;

procedure TPruebasVariablesValidar.NombreReservado_Access_SoloEnAccess;
begin
  Assert.AreEqual(1, Length(ValidarVariables([V('Counter', 'Contador', tmEntero, 0)], False)));
  Assert.AreEqual(0, Length(ValidarVariables([V('Counter', 'Contador', tmEntero, 0)], True)));
end;

procedure TPruebasVariablesValidar.ColumnaBase_Fecha;
var
  E: TArray<TErrorCampo>;
begin
  E := ValidarVariables([V('Fecha', 'Fecha del acta', tmFecha, 0)], True);
  Assert.AreEqual(1, Length(E));
  Assert.IsTrue(Pos('sistema', E[0].Mensaje) > 0);
end;

procedure TPruebasVariablesValidar.NombreDuplicado;
var
  E: TArray<TErrorCampo>;
begin
  E := ValidarVariables([V('Org', 'Organismo', tmTexto, 10), V('org', 'Otro', tmTexto, 10)], True);
  Assert.AreEqual(1, Length(E));
  Assert.IsTrue(Pos('repetido', E[0].Mensaje) > 0);
end;

procedure TPruebasVariablesValidar.EtiquetaDuplicada;
var
  E: TArray<TErrorCampo>;
begin
  E := ValidarVariables([V('A1', 'Organismo', tmTexto, 10), V('A2', 'organismo', tmTexto, 10)], True);
  Assert.AreEqual(1, Length(E));
  Assert.AreEqual('A2.etiqueta', E[0].Campo);
end;

procedure TPruebasVariablesValidar.CaracteresSinLongitud;
var
  E: TArray<TErrorCampo>;
begin
  E := ValidarVariables([V('Nom', 'Nombre', tmTexto, 0)], True);
  Assert.AreEqual(1, Length(E));
  Assert.AreEqual('Nom.longitud', E[0].Campo);
  Assert.AreEqual(0, Length(ValidarVariables([V('Nom', 'Nombre', tmEntero, 0)], True)));
end;

procedure TPruebasVariablesValidar.NombreConEspaciosOAcentos;
begin
  Assert.AreEqual(1, Length(ValidarVariables([V('Mi campo', 'Uno', tmEntero, 0)], True)));
  Assert.AreEqual(1, Length(ValidarVariables([V('A' + #241 + 'o', 'Dos', tmEntero, 0)], True)));
end;

procedure TPruebasVariablesValidar.NombreQueEmpiezaPorDigito;
begin
  Assert.AreEqual(1, Length(ValidarVariables([V('1campo', 'Uno', tmEntero, 0)], True)));
end;

procedure TPruebasVariablesValidar.ListaCorrecta_SinErrores;
begin
  Assert.AreEqual(0, Length(ValidarVariables(
    [V('Municipio', 'Municipio', tmTexto, 29), V('year1', 'Anno', tmEntero, 0)], True)));
end;

procedure TPruebasVariablesValidar.Existente_NoSeLeExigeSintaxis;
begin
  // un nombre antiguo con espacio sigue valiendo si ya existia
  Assert.AreEqual(0, Length(ValidarVariables([V('Mi campo', 'Uno', tmEntero, 0)], True, ['Mi campo'])));
end;

procedure TPruebasVariablesValidar.SqlTipoColumna_SqlServer;
begin
  Assert.AreEqual('VARCHAR(20)', SqlTipoColumna(tmTexto, 20, True));
  Assert.AreEqual('VARCHAR(MAX)', SqlTipoColumna(tmTexto, 0, True));
  Assert.AreEqual('DATETIME2', SqlTipoColumna(tmFecha, 0, True));
  Assert.AreEqual('INT', SqlTipoColumna(tmEntero, 0, True));
  Assert.AreEqual('VARCHAR(MAX)', SqlTipoColumna(tmMemo, 0, True));
  Assert.AreEqual('DECIMAL(18, 6)', SqlTipoColumna(tmReal, 0, True));
  Assert.AreEqual('BIT', SqlTipoColumna(tmBooleano, 0, True));
end;

procedure TPruebasVariablesValidar.SqlTipoColumna_Access;
begin
  Assert.AreEqual('VARCHAR(20)', SqlTipoColumna(tmTexto, 20, False));
  Assert.AreEqual('LONGTEXT', SqlTipoColumna(tmTexto, 300, False));
  Assert.AreEqual('DATETIME', SqlTipoColumna(tmFecha, 0, False));
  Assert.AreEqual('LONGTEXT', SqlTipoColumna(tmMemo, 0, False));
  Assert.AreEqual('YESNO', SqlTipoColumna(tmBooleano, 0, False));
end;

procedure TPruebasVariablesValidar.NombreTablaDatos_Caracteres;
begin
  Assert.AreEqual('md_014014001', NombreTablaDatos('014', '014001'));
  Assert.AreEqual('md_01_2', NombreTablaDatos('01', '-2'));
end;

{ TPruebasVariablesBD }

function TPruebasVariablesBD.V(const ANombre, AEtiqueta: string; ATipo: TTipoMeta;
  ALong: Integer): TCampoMeta;
begin
  Result := Default(TCampoMeta);
  Result.Nombre := ANombre;
  Result.Etiqueta := AEtiqueta;
  Result.Tipo := ATipo;
  Result.Longitud := ALong;
end;

procedure TPruebasVariablesBD.Preparar;
begin
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := GetEnvironmentVariable('ARCHIGENIO_TEST_DB');
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
  Limpiar;
  FConn.Connected := True;
  FConn.ExecSQL('INSERT INTO cl_series (codserie, serie) VALUES (''' + SERIE + ''', ''Serie de prueba'')');
  FConn.ExecSQL('INSERT INTO cl_subseries (codserie, codsubs, subserie) VALUES (''' + SERIE +
    ''', ''' + SUBS + ''', ''Subserie de prueba'')');
end;

procedure TPruebasVariablesBD.Limpiar;
begin
  if FConn = nil then
    Exit;
  try
    if FConn.InTransaction then
      FConn.Rollback;
    try
      FConn.ExecSQL('DROP TABLE ' + TABLA);
    except
      // puede no existir
    end;
    FConn.ExecSQL('DELETE FROM cl_VarSubserie WHERE codserie = ''' + SERIE + '''');
    FConn.ExecSQL('DELETE FROM cl_subseries WHERE codserie = ''' + SERIE + '''');
    FConn.ExecSQL('DELETE FROM cl_series WHERE codserie = ''' + SERIE + '''');
  except
    // limpieza de mejor esfuerzo
  end;
end;

procedure TPruebasVariablesBD.CrearTabla(const ACols: string);
begin
  FConn.ExecSQL('CREATE TABLE ' + TABLA + ' (id INT NOT NULL PRIMARY KEY' + ACols + ')');
end;

function TPruebasVariablesBD.ColumnaExiste(const ACol: string): Boolean;
begin
  Result := Integer(FConn.ExecSQLScalar(
    'SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ''' + TABLA +
    ''' AND COLUMN_NAME = ''' + ACol + '''')) = 1;
end;

function TPruebasVariablesBD.NumDefiniciones: Integer;
begin
  Result := Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM cl_VarSubserie WHERE codsubs = ''' + SUBS + ''''));
end;

procedure TPruebasVariablesBD.Modo_SinTabla_Libre;
begin
  Assert.IsTrue(ModoVariables(FConn, SERIE, SUBS) = mvLibre);
end;

procedure TPruebasVariablesBD.Modo_TablaHuerfana_Libre;
begin
  FConn.ExecSQL('UPDATE cl_subseries SET NombreTablaMetadatos = ''md_no_existe'' WHERE codsubs = ''' + SUBS + '''');
  Assert.IsTrue(ModoVariables(FConn, SERIE, SUBS) = mvLibre);
end;

procedure TPruebasVariablesBD.Modo_ConTabla_SoloAnadir;
begin
  CrearTabla('');
  Assert.IsTrue(ModoVariables(FConn, SERIE, SUBS) = mvSoloAnadir);
  Assert.AreEqual(TABLA, TablaDatosActual(FConn, SERIE, SUBS));
end;

procedure TPruebasVariablesBD.Guardar_Libre_ReemplazaYOrdena;
var
  C: TArray<TCampoMeta>;
begin
  GuardarVariables(FConn, True, SERIE, SUBS,
    [V('A1', 'Uno', tmTexto, 10), V('A2', 'Dos', tmEntero, 0), V('A3', 'Tres', tmFecha, 0)]);
  C := CargarCamposSubserie(FConn, SUBS);
  Assert.AreEqual(3, Length(C));
  Assert.AreEqual('A3', C[2].Nombre);
  // otro orden y una menos
  GuardarVariables(FConn, True, SERIE, SUBS, [V('A3', 'Tres', tmFecha, 0), V('A1', 'Uno', tmTexto, 10)]);
  C := CargarCamposSubserie(FConn, SUBS);
  Assert.AreEqual(2, Length(C));
  Assert.AreEqual('A3', C[0].Nombre);
  Assert.AreEqual(1, C[0].Orden);
  Assert.AreEqual('A1', C[1].Nombre);
  Assert.AreEqual(2, C[1].Orden);
end;

procedure TPruebasVariablesBD.Guardar_Libre_GuardaObligatorioYDescripcion;
var
  X: TCampoMeta;
  C: TArray<TCampoMeta>;
begin
  X := V('A1', 'Uno', tmTexto, 10);
  X.Obligatorio := True;
  X.Descripcion := 'Ayuda del campo';
  GuardarVariables(FConn, True, SERIE, SUBS, [X]);
  C := CargarCamposSubserie(FConn, SUBS);
  Assert.IsTrue(C[0].Obligatorio);
  Assert.AreEqual('Ayuda del campo', C[0].Descripcion);
end;

procedure TPruebasVariablesBD.Guardar_SoloAnadir_CreaColumna_YFilaViejaQuedaNull;
var
  C: TArray<TCampoMeta>;
begin
  GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmTexto, 20)]);
  CrearTabla(', Org VARCHAR(20) NULL');
  FConn.ExecSQL('INSERT INTO ' + TABLA + ' (id, Org) VALUES (1, ''ONE'')');
  GuardarVariables(FConn, True, SERIE, SUBS,
    [V('Org', 'Organismo', tmTexto, 20), V('Anno', 'Anno', tmEntero, 0), V('Obs', 'Observacion', tmMemo, 0)]);
  Assert.IsTrue(ColumnaExiste('Anno'));
  Assert.IsTrue(ColumnaExiste('Obs'));
  C := CargarCamposSubserie(FConn, SUBS);
  Assert.AreEqual(3, Length(C));
  Assert.AreEqual('ONE', string(FConn.ExecSQLScalar('SELECT Org FROM ' + TABLA + ' WHERE id = 1')));
  Assert.IsTrue(VarIsNull(FConn.ExecSQLScalar('SELECT Anno FROM ' + TABLA + ' WHERE id = 1')));
end;

procedure TPruebasVariablesBD.Guardar_SoloAnadir_NoPermiteRenombrar;
begin
  GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmTexto, 20)]);
  CrearTabla(', Org VARCHAR(20) NULL');
  Assert.WillRaise(
    procedure
    begin
      GuardarVariables(FConn, True, SERIE, SUBS, [V('Org2', 'Organismo', tmTexto, 20)]);
    end, EVariables);
  Assert.AreEqual('Org', CargarCamposSubserie(FConn, SUBS)[0].Nombre);
end;

procedure TPruebasVariablesBD.Guardar_SoloAnadir_NoPermiteQuitar;
begin
  GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmTexto, 20), V('Ent', 'Entidad', tmTexto, 20)]);
  CrearTabla(', Org VARCHAR(20) NULL, Ent VARCHAR(20) NULL');
  Assert.WillRaise(
    procedure
    begin
      GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmTexto, 20)]);
    end, EVariables);
  Assert.AreEqual(2, NumDefiniciones);
end;

procedure TPruebasVariablesBD.Guardar_SoloAnadir_NoPermiteCambiarTipo;
begin
  GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmTexto, 20)]);
  CrearTabla(', Org VARCHAR(20) NULL');
  Assert.WillRaise(
    procedure
    begin
      GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmTexto, 40)]);
    end, EVariables);
  Assert.WillRaise(
    procedure
    begin
      GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmEntero, 0)]);
    end, EVariables);
end;

procedure TPruebasVariablesBD.Guardar_SoloAnadir_PermiteCambiarEtiquetaObligatorioOrden;
var
  A, B: TCampoMeta;
  C: TArray<TCampoMeta>;
begin
  GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmTexto, 20), V('Ent', 'Entidad', tmTexto, 20)]);
  CrearTabla(', Org VARCHAR(20) NULL, Ent VARCHAR(20) NULL');
  A := V('Org', 'Organismo emisor', tmTexto, 20);
  A.Obligatorio := True;
  A.Descripcion := 'nueva ayuda';
  B := V('Ent', 'Entidad', tmTexto, 20);
  GuardarVariables(FConn, True, SERIE, SUBS, [B, A]);
  C := CargarCamposSubserie(FConn, SUBS);
  Assert.AreEqual('Ent', C[0].Nombre);
  Assert.AreEqual('Org', C[1].Nombre);
  Assert.AreEqual('Organismo emisor', C[1].Etiqueta);
  Assert.IsTrue(C[1].Obligatorio);
  Assert.AreEqual('nueva ayuda', C[1].Descripcion);
end;

procedure TPruebasVariablesBD.Guardar_Fallo_NoDejaMediasTintas;
var
  C: TArray<TCampoMeta>;
begin
  GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmTexto, 20)]);
  // la columna Extra ya existe en la tabla: el ALTER fallara a mitad del guardado
  CrearTabla(', Org VARCHAR(20) NULL, Extra INT NULL');
  Assert.WillRaise(
    procedure
    begin
      GuardarVariables(FConn, True, SERIE, SUBS,
        [V('Org', 'Organismo', tmTexto, 20), V('Nueva', 'Nueva', tmEntero, 0), V('Extra', 'Extra', tmEntero, 0)]);
    end, EVariables);
  C := CargarCamposSubserie(FConn, SUBS);
  Assert.AreEqual(1, Length(C), 'las definiciones quedan como estaban');
  Assert.IsFalse(ColumnaExiste('Nueva'), 'la columna anadida antes del fallo se deshizo');
end;

procedure TPruebasVariablesBD.Guardar_ValidacionFalla_NoEscribe;
begin
  GuardarVariables(FConn, True, SERIE, SUBS, [V('Org', 'Organismo', tmTexto, 20)]);
  Assert.WillRaise(
    procedure
    begin
      GuardarVariables(FConn, True, SERIE, SUBS, [V('select', 'Algo', tmEntero, 0)]);
    end, EVariables);
  Assert.AreEqual(1, NumDefiniciones);
end;

end.
