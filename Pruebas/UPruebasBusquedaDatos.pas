unit UPruebasBusquedaDatos;

{ Pruebas de UBusquedaDatos.
  - TPruebasBusquedaDatos: validaciones de Buscar que no tocan la base.
  - TPruebasBusquedaAccess: contra la copia de un .mdb (ARCHIGENIO_TEST_MDB).
  - TPruebasBusquedaSql: contra SQL Server (ARCHIGENIO_TEST_DB), con los datos
    de TEscenario sembrados dentro de una transaccion que se deshace. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UPruebasAlcanceDatos;

type
  [TestFixture]
  TPruebasBusquedaDatos = class
  public
    [Test]
    procedure Buscar_PedidoVacio_Lanza;
    [Test]
    procedure Buscar_FiltrosSinSubserie_Lanza;
  end;

  [TestFixture]
  TPruebasBusquedaSql = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    function Contar(const Usuario: string; EsAdmin: Boolean): Integer;
    function Buscar(const Texto, CodSubs, Usuario: string; EsAdmin: Boolean;
      Limite: Integer; out Truncado: Boolean): Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Buscar_RespetaAlcance;
    [Test]
    procedure Buscar_Truncado;
    [Test]
    procedure Buscar_TablaMdInexistente;
    [Test]
    procedure Buscar_PorcientoYApostrofeSonLiterales;
    [Test]
    procedure Buscar_ConTablaMd;
    [Test]
    procedure Buscar_GeneralUsuarioSinAsignaciones_SoloPublicas;
    [Test]
    procedure Buscar_NodoActualSinPermiso_SoloPublicas;
    [Test]
    procedure Buscar_NodoActualConPermiso;
    [Test]
    procedure Buscar_NodoActualIncluyeDescendientes;
    [Test]
    procedure NodosDelAmbito_ClavesIrregulares;
    [Test]
    procedure Buscar_AccesoSeMapeaDeLaSubserie;
  end;

  [TestFixture]
  TPruebasBusquedaAccess = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    function Buscar(const Texto, CodSubs: string; Limite: Integer;
      out Truncado: Boolean): Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Access_BuscaTextoEnTitulo;
    [Test]
    procedure Access_Truncado;
    [Test]
    procedure Access_TablaMdInexistente;
    [Test]
    procedure Access_PorcientoYApostrofeSonLiterales;
    [Test]
    procedure Access_ConTablaMd;
    [Test]
    procedure Access_NodoActualIncluyeDescendientes;
  end;

implementation

uses
  System.SysUtils, System.Variants, Data.DB, UAlcance, UAlcanceDatos, UBusqueda, UBusquedaDatos,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param, UEsquemaAlcance;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  VAR_MDB = 'ARCHIGENIO_TEST_MDB';
  TITULO_PRUEBA = 'prueba alcance';

{ Siembra, dentro de la transaccion de la prueba, una tabla md_prueba_busq con
  tres filas para tres documentos de 014001 (los de Sembrar), y apunta la
  subserie 014001 a ella con cuatro campos: Depto (Caracteres), Fecha_ing
  (Fecha), Folios (Entero) y Activo (Boolean).
    Doc 1: Camaguey    2026-01-31  Folios 0   Activo si
    Doc 2: Villa_Clara 2026-02-05  Folios 7   Activo no
    Doc 3: Holguin     2026-03-15  Folios 12  Activo si
  El 31 de enero es a proposito un dia mayor que 12: una fecha enviada como
  texto dd/mm/yyyy se confunde con mm/dd en un servidor en ingles.
  Devuelve False si la subserie 014001 no existe en la base. }
function SembrarMd(Conn: TFDConnection; ConSqlServer: Boolean): Boolean;
const
  DEPTOS: array[0..2] of string = ('Camaguey', 'Villa_Clara', 'Holguin');
  FOLIOS: array[0..2] of Integer = (0, 7, 12);
  ACTIVO_SS: array[0..2] of string = ('1', '0', '1');
  ACTIVO_ACC: array[0..2] of string = ('True', 'False', 'True');
var
  Q: TFDQuery;
  Codigos: array[0..2] of string;
  Serie, TipoBit, Activo: string;
  I: Integer;
  Fechas: array[0..2] of TDateTime;
begin
  Result := Integer(Conn.ExecSQLScalar(
    'SELECT COUNT(*) FROM cl_subseries WHERE codsubs = ''014001''')) > 0;
  if not Result then
    Exit;
  Fechas[0] := EncodeDate(2026, 1, 31);
  Fechas[1] := EncodeDate(2026, 2, 5);
  Fechas[2] := EncodeDate(2026, 3, 15);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT Codigodoc FROM tb_SeriesDatos WHERE codsubs = ''014001'' ' +
      'AND titulodoc = ''' + TITULO_PRUEBA + ''' ORDER BY Codigodoc';
    Q.Open;
    for I := 0 to 2 do
    begin
      Codigos[I] := Q.Fields[0].AsString;
      Q.Next;
    end;
  finally
    Q.Free;
  end;
  if ConSqlServer then
    TipoBit := 'BIT'
  else
    TipoBit := 'YESNO';
  try
    Conn.ExecSQL('DROP TABLE md_prueba_busq');
  except
    // no existia
  end;
  Conn.ExecSQL('CREATE TABLE md_prueba_busq (IdEstructura VARCHAR(50), id INT, ' +
    'codsubs VARCHAR(50), Fecha DATETIME, Version VARCHAR(12), Codigodoc VARCHAR(20), ' +
    'Depto VARCHAR(50), Fecha_ing DATETIME, Folios INT, Activo ' + TipoBit + ')');
  for I := 0 to 2 do
  begin
    if ConSqlServer then
      Activo := ACTIVO_SS[I]
    else
      Activo := ACTIVO_ACC[I];
    Conn.ExecSQL('INSERT INTO md_prueba_busq (IdEstructura, id, codsubs, Fecha, ' +
      'Version, Codigodoc, Depto, Fecha_ing, Folios, Activo) ' +
      'SELECT IdEstructura, id, codsubs, Fecha, Version, Codigodoc, :d, :f, :n, ' +
      Activo + ' FROM tb_SeriesDatos WHERE codsubs = ''014001'' AND Codigodoc = :c',
      [DEPTOS[I], Fechas[I], FOLIOS[I], Codigos[I]]);
  end;
  Serie := VarToStr(Conn.ExecSQLScalar(
    'SELECT codserie FROM cl_subseries WHERE codsubs = ''014001'''));
  Conn.ExecSQL('DELETE FROM cl_VarSubserie WHERE codsubs = ''014001''');
  Conn.ExecSQL('INSERT INTO cl_VarSubserie (codserie, codsubs, Orden, NomVariable, ' +
    'Etiqueta, tipo, longitud) VALUES (:s, ''014001'', 1, ''Depto'', ''Departamento'', 1, 50)', [Serie]);
  Conn.ExecSQL('INSERT INTO cl_VarSubserie (codserie, codsubs, Orden, NomVariable, ' +
    'Etiqueta, tipo, longitud) VALUES (:s, ''014001'', 2, ''Fecha_ing'', ''Ingreso'', 2, 0)', [Serie]);
  Conn.ExecSQL('INSERT INTO cl_VarSubserie (codserie, codsubs, Orden, NomVariable, ' +
    'Etiqueta, tipo, longitud) VALUES (:s, ''014001'', 3, ''Folios'', ''Folios'', 3, 0)', [Serie]);
  Conn.ExecSQL('INSERT INTO cl_VarSubserie (codserie, codsubs, Orden, NomVariable, ' +
    'Etiqueta, tipo, longitud) VALUES (:s, ''014001'', 4, ''Activo'', ''Activo'', 6, 0)', [Serie]);
  Conn.ExecSQL('UPDATE cl_subseries SET NombreTablaMetadatos = ''md_prueba_busq'' ' +
    'WHERE codsubs = ''014001''');
end;

{ Busca en 014001 con un texto y/o una condicion de campo. SQL Server: como
  administrador; Access: sin alcance. }
function CuentaMd(Conn: TFDConnection; ConSqlServer: Boolean; const Texto: string;
  const Campo, Desde, Hasta: string): Integer;
var
  P: TPedidoBusqueda;
  Al: TAlcanceUsuario;
  T: TFDMemTable;
  Trunc: Boolean;
begin
  P.Texto := Texto;
  P.CodSubs := '014001';
  P.Limite := 100000;
  P.Ambito := abGeneral;
  P.IdsNodo := nil;
  if Campo = '' then
    P.Condiciones := nil
  else
  begin
    SetLength(P.Condiciones, 1);
    P.Condiciones[0].Campo := Campo;
    P.Condiciones[0].Desde := Desde;
    P.Condiciones[0].Hasta := Hasta;
  end;
  if ConSqlServer then
    Al := CargarAlcance(Conn, 'administrador', True)
  else
    Al := nil;
  try
    T := UBusquedaDatos.Buscar(Conn, Al, P, ConSqlServer, Trunc);
    try
      Result := T.RecordCount;
    finally
      T.Free;
    end;
  finally
    Al.Free;
  end;
end;

{ Los casos con tabla md_* comunes a los dos motores. }
procedure VerificarMd(Conn: TFDConnection; ConSqlServer: Boolean);
begin
  if not SembrarMd(Conn, ConSqlServer) then
  begin
    Assert.Pass('omitida: la subserie 014001 no existe en esta base');
    Exit;
  end;
  Assert.AreEqual(1, CuentaMd(Conn, ConSqlServer, 'camaguey', '', '', ''),
    'texto en un metadato');
  Assert.AreEqual(1, CuentaMd(Conn, ConSqlServer, 'a_C', '', '', ''),
    'el guion bajo es literal');
  Assert.AreEqual(1, CuentaMd(Conn, ConSqlServer, '', 'Fecha_ing', '2026-01-01', '2026-01-31'),
    'rango de fechas con dia mayor que 12, incluye el ultimo dia');
  Assert.AreEqual(2, CuentaMd(Conn, ConSqlServer, '', 'Fecha_ing', '2026-02-05', ''),
    'solo desde');
  Assert.AreEqual(1, CuentaMd(Conn, ConSqlServer, '', 'Folios', '5', '10'),
    'rango entero');
  Assert.AreEqual(2, CuentaMd(Conn, ConSqlServer, '', 'Activo', '1', ''), 'booleano si');
  Assert.AreEqual(1, CuentaMd(Conn, ConSqlServer, '', 'Activo', '0', ''), 'booleano no');
  Assert.AreEqual(1, CuentaMd(Conn, ConSqlServer, 'holguin', 'Folios', '10', '20'),
    'texto y campo a la vez');
end;

function ClaveN(const AIdEstructura: string; AId: Integer): TClaveNodo;
begin
  Result.IdEstructura := AIdEstructura;
  Result.Id := AId;
end;

{ Documento propio de la prueba (titulo TITULO_PRUEBA), dentro de la transaccion. }
procedure SembrarDocPropio(Conn: TFDConnection; const IdEstr: string; Id: Integer;
  const CodSubs, Codigodoc: string);
begin
  if Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM tb_Serietree WHERE ' +
    'IdEstructura = :a AND id = :b AND codsubs = :c', [IdEstr, Id, CodSubs])) = 0 then
    Conn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) ' +
      'VALUES (:a, :b, :c)', [IdEstr, Id, CodSubs]);
  Conn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, ' +
    'Version, Codigodoc, titulodoc) VALUES (:a, :b, :c, :d, :e, :f, :g)',
    [IdEstr, Id, CodSubs, EncodeDate(2026, 10, 29), '1', Codigodoc, TITULO_PRUEBA]);
end;

{ Busca TITULO_PRUEBA con el ambito dado; el llamador libera la tabla. }
function BuscarEnAmbito(Conn: TFDConnection; ConSqlServer: Boolean;
  const Usuario: string; EsAdmin: Boolean; Ambito: TAmbitoBusqueda;
  const Nodo: TClaveNodo): TFDMemTable;
var
  Al: TAlcanceUsuario;
  P: TPedidoBusqueda;
  Trunc: Boolean;
begin
  P.Texto := TITULO_PRUEBA;
  P.CodSubs := '';
  P.Condiciones := nil;
  P.Limite := 100000;
  P.Ambito := Ambito;
  P.IdsNodo := nil;
  if Ambito = abNodoActual then
    P.IdsNodo := NodosDelAmbito(Conn, Nodo);
  if ConSqlServer then
    Al := CargarAlcance(Conn, Usuario, EsAdmin)
  else
    Al := nil;
  try
    Result := UBusquedaDatos.Buscar(Conn, Al, P, ConSqlServer, Trunc);
  finally
    Al.Free;
  end;
end;

function FilasEn(T: TFDMemTable; const IdEstr: string): Integer;
var
  Marca: TBookmark;
begin
  Result := 0;
  Marca := T.GetBookmark;
  T.DisableControls;
  try
    T.First;
    while not T.Eof do
    begin
      if SameText(Trim(T.FieldByName('IdEstructura').AsString), IdEstr) then
        Inc(Result);
      T.Next;
    end;
  finally
    T.GotoBookmark(Marca);
    T.FreeBookmark(Marca);
    T.EnableControls;
  end;
end;

{ Filas cuyo Acceso es distinto de Valor. }
function FilasConAccesoDistinto(T: TFDMemTable; const Valor: string): Integer;
begin
  Result := 0;
  T.First;
  while not T.Eof do
  begin
    if T.FieldByName('Acceso').AsString <> Valor then
      Inc(Result);
    T.Next;
  end;
end;

function FilasConCodsubs(T: TFDMemTable; const CodSubs: string): Integer;
begin
  Result := 0;
  T.First;
  while not T.Eof do
  begin
    if T.FieldByName('codsubs').AsString = CodSubs then
      Inc(Result);
    T.Next;
  end;
end;

{ TPruebasBusquedaDatos }

procedure TPruebasBusquedaDatos.Buscar_PedidoVacio_Lanza;
var
  P: TPedidoBusqueda;
  Trunc: Boolean;
begin
  P.Texto := '';
  P.CodSubs := '';
  P.Condiciones := nil;
  P.Limite := 0;
  P.Ambito := abGeneral;
  P.IdsNodo := nil;
  Assert.WillRaise(
    procedure begin UBusquedaDatos.Buscar(nil, nil, P, True, Trunc).Free; end,
    Exception);
end;

procedure TPruebasBusquedaDatos.Buscar_FiltrosSinSubserie_Lanza;
var
  P: TPedidoBusqueda;
  Trunc: Boolean;
begin
  P.Texto := 'acta';
  P.CodSubs := '';
  SetLength(P.Condiciones, 1);
  P.Condiciones[0].Campo := 'Depto';
  P.Condiciones[0].Desde := 'x';
  P.Condiciones[0].Hasta := '';
  P.Limite := 0;
  P.Ambito := abGeneral;
  P.IdsNodo := nil;
  Assert.WillRaise(
    procedure begin UBusquedaDatos.Buscar(nil, nil, P, True, Trunc).Free; end,
    Exception);
end;

{ TPruebasBusquedaSql }

procedure TPruebasBusquedaSql.Preparar;
var
  NombreBD: string;
begin
  FConn := nil;
  FEsc := nil;
  NombreBD := GetEnvironmentVariable(VAR_BD);
  if NombreBD = '' then
    Exit;
  if SameText(NombreBD, 'SGDDRHMAIN') then
    raise Exception.Create('Las pruebas no deben correr contra SGDDRHMAIN');
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := NombreBD;
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
  CrearEsquemaAlcance(FConn, True);
  FEsc := TEscenario.Create(FConn);
  FConn.StartTransaction;
  FEsc.Sembrar;
end;

procedure TPruebasBusquedaSql.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
end;

{ Documentos sembrados que el alcance deja ver, contados con el filtro de
  alcance directamente (sin pasar por Buscar). }
function TPruebasBusquedaSql.Contar(const Usuario: string; EsAdmin: Boolean): Integer;
var
  Al: TAlcanceUsuario;
  F: TFiltroSql;
begin
  Al := CargarAlcance(FConn, Usuario, EsAdmin);
  try
    F := FiltroDocumentos(Al, 'd');
    F.Condicion := '(' + F.Condicion + ') AND d.titulodoc = ''' + TITULO_PRUEBA + '''';
    Result := FEsc.Contar(F);
  finally
    Al.Free;
  end;
end;

function TPruebasBusquedaSql.Buscar(const Texto, CodSubs, Usuario: string;
  EsAdmin: Boolean; Limite: Integer; out Truncado: Boolean): Integer;
var
  Al: TAlcanceUsuario;
  P: TPedidoBusqueda;
  T: TFDMemTable;
begin
  P.Texto := Texto;
  P.CodSubs := CodSubs;
  P.Condiciones := nil;
  P.Limite := Limite;
  P.Ambito := abGeneral;
  P.IdsNodo := nil;
  Al := CargarAlcance(FConn, Usuario, EsAdmin);
  try
    T := UBusquedaDatos.Buscar(FConn, Al, P, True, Truncado);
    try
      Result := T.RecordCount;
    finally
      T.Free;
    end;
  finally
    Al.Free;
  end;
end;

procedure TPruebasBusquedaSql.Buscar_RespetaAlcance;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(Contar('administrador', True),
    Buscar(TITULO_PRUEBA, '', 'administrador', True, 100000, Trunc), 'administrador');
  Assert.AreEqual(Contar('prueba_alc_usr1', False),
    Buscar(TITULO_PRUEBA, '', 'prueba_alc_usr1', False, 100000, Trunc), 'usr1');
  Assert.AreEqual(Contar('prueba_alc_vacio', False),
    Buscar(TITULO_PRUEBA, '', 'prueba_alc_vacio', False, 100000, Trunc), 'sin asignaciones');
  Assert.AreEqual(Contar('prueba_alc_egd', False),
    Buscar(TITULO_PRUEBA, '', 'prueba_alc_egd', False, 100000, Trunc), 'egd');
end;

procedure TPruebasBusquedaSql.Buscar_Truncado;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(2, Buscar(TITULO_PRUEBA, '', 'administrador', True, 2, Trunc));
  Assert.IsTrue(Trunc, 'debe marcar que hay mas resultados');
end;

procedure TPruebasBusquedaSql.Buscar_TablaMdInexistente;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  FConn.ExecSQL('UPDATE cl_subseries SET NombreTablaMetadatos = ''md_no_existe_xyz'' ' +
    'WHERE codsubs = ''014001''');
  // Sembrar() crea 3 + 4 + 5 documentos de prueba en 014001
  Assert.AreEqual(12, Buscar(TITULO_PRUEBA, '014001', 'administrador', True, 100000, Trunc));
end;

procedure TPruebasBusquedaSql.Buscar_PorcientoYApostrofeSonLiterales;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc) VALUES (''A.4.3'', 104, ''003'', :f, ''1'', ''PBUS-1'', :t)',
    [EncodeDate(2026, 10, 29), 'Acta 100% O''Brien']);
  Assert.AreEqual(1, Buscar('100%', '', 'administrador', True, 100000, Trunc), 'porciento');
  Assert.AreEqual(1, Buscar('O''Brien', '', 'administrador', True, 100000, Trunc), 'apostrofe');
  Assert.AreEqual(1, Buscar('%', '', 'administrador', True, 100000, Trunc),
    'un % solo debe buscar el caracter, no todo');
end;

procedure TPruebasBusquedaSql.Buscar_GeneralUsuarioSinAsignaciones_SoloPublicas;
var
  T: TFDMemTable;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // 074 es la unica subserie publica de la base de prueba
  SembrarDocPropio(FConn, 'A.4.6', 160, '074', 'PBAMB-1');
  T := BuscarEnAmbito(FConn, True, 'prueba_alc_vacio', False, abGeneral, ClaveN('', 0));
  try
    Assert.IsTrue(T.RecordCount > 0, 'debe devolver al menos el documento publico');
    Assert.AreEqual(0, FilasConAccesoDistinto(T, 'Publica'), 'solo publicas');
  finally
    T.Free;
  end;
end;

procedure TPruebasBusquedaSql.Buscar_NodoActualSinPermiso_SoloPublicas;
var
  T: TFDMemTable;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  SembrarDocPropio(FConn, 'A.4.6', 160, '074', 'PBAMB-1');
  T := BuscarEnAmbito(FConn, True, 'prueba_alc_usr1', False, abNodoActual,
    ClaveN('A.4.6', 160));
  try
    Assert.IsTrue(T.RecordCount > 0, 'debe devolver al menos el documento publico');
    Assert.AreEqual(0, FilasConAccesoDistinto(T, 'Publica'), 'solo publicas');
  finally
    T.Free;
  end;
end;

procedure TPruebasBusquedaSql.Buscar_NodoActualConPermiso;
var
  T: TFDMemTable;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  SembrarDocPropio(FConn, 'A.4.3', 104, '014001', 'PBAMB-1');
  SembrarDocPropio(FConn, 'A.4.3', 104, '074', 'PBAMB-2');
  T := BuscarEnAmbito(FConn, True, 'prueba_alc_usr1', False, abNodoActual,
    ClaveN('A.4.3', 104));
  try
    // el de 014001 (permitido) y el publico; no los 2 de '003' del mismo nodo
    Assert.AreEqual(2, T.RecordCount);
    Assert.AreEqual(1, FilasConCodsubs(T, '014001'), '014001 del nodo');
    Assert.AreEqual(1, FilasConCodsubs(T, '074'), 'publico del nodo');
    Assert.AreEqual(2, FilasEn(T, 'A.4.3'), 'todas del nodo');
  finally
    T.Free;
  end;
  // en A.4 (padre) tampoco ve los de 014001 de A.4 ni los de A.4.6
  T := BuscarEnAmbito(FConn, True, 'prueba_alc_usr1', False, abNodoActual,
    ClaveN('A.4', 101));
  try
    Assert.AreEqual(2, T.RecordCount, 'misma cobertura dentro del padre');
  finally
    T.Free;
  end;
end;

procedure TPruebasBusquedaSql.Buscar_NodoActualIncluyeDescendientes;
var
  T: TFDMemTable;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  T := BuscarEnAmbito(FConn, True, 'administrador', True, abNodoActual,
    ClaveN('A.4', 101));
  try
    Assert.AreEqual(3, FilasEn(T, 'A.4.6'), 'descendiente A.4.6');
    Assert.AreEqual(5, FilasEn(T, 'A.4'), 'el propio nodo');
    Assert.AreEqual(2, FilasEn(T, 'A.4.3'), 'descendiente A.4.3');
    Assert.AreEqual(0, FilasEn(T, 'A.1.7'), 'otra rama');
    Assert.AreEqual(10, T.RecordCount, 'nada mas');
  finally
    T.Free;
  end;
end;

procedure TPruebasBusquedaSql.NodosDelAmbito_ClavesIrregulares;
var
  IdA1: Integer;
  Ids: TArray<string>;
  S: string;
  Minus, ConEspacio, ElPropio: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  IdA1 := Integer(FConn.ExecSQLScalar(
    'SELECT MIN(id) FROM tb_tree WHERE IdEstructura = ''A.1'''));
  Assert.IsTrue(IdA1 > 0, 'la base de prueba debe tener el nodo A.1');
  FConn.ExecSQL('INSERT INTO tb_tree (IdEstructura, id, padre) VALUES (:a, :b, :c)',
    ['a.1.4', 990101, IdA1]);
  FConn.ExecSQL('INSERT INTO tb_tree (IdEstructura, id, padre) VALUES (:a, :b, :c)',
    ['A.1.6 ', 990102, IdA1]);
  Ids := NodosDelAmbito(FConn, ClaveN('A.1', IdA1));
  Minus := False;
  ConEspacio := False;
  ElPropio := False;
  for S in Ids do
  begin
    if S = 'a.1.4' then Minus := True;
    if S = 'A.1.6 ' then ConEspacio := True;
    if S = 'A.1' then ElPropio := True;
  end;
  Assert.IsTrue(Minus, 'a.1.4 con su escritura literal');
  Assert.IsTrue(ConEspacio, 'A.1.6 con el espacio final');
  Assert.IsTrue(ElPropio, 'el propio nodo');
end;

procedure TPruebasBusquedaSql.Buscar_AccesoSeMapeaDeLaSubserie;
var
  T: TFDMemTable;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // 003: acceso 0; 074: 1; 014001 pasa a 3
  FConn.ExecSQL('UPDATE cl_subseries SET acceso = 3 WHERE codsubs = ''014001''');
  SembrarDocPropio(FConn, 'A.4.3', 104, '074', 'PBAMB-1');
  T := BuscarEnAmbito(FConn, True, 'administrador', True, abGeneral, ClaveN('', 0));
  try
    Assert.IsTrue(T.RecordCount > 0);
    T.First;
    while not T.Eof do
    begin
      if T.FieldByName('codsubs').AsString = '014001' then
        Assert.AreEqual('Secreta', T.FieldByName('Acceso').AsString)
      else if T.FieldByName('codsubs').AsString = '074' then
        Assert.AreEqual('Publica', T.FieldByName('Acceso').AsString)
      else if T.FieldByName('codsubs').AsString = '003' then
        Assert.AreEqual('Sin definir', T.FieldByName('Acceso').AsString);
      T.Next;
    end;
    Assert.IsTrue(FilasConCodsubs(T, '014001') > 0, 'hay secretas');
    Assert.IsTrue(FilasConCodsubs(T, '074') > 0, 'hay publicas');
    Assert.IsTrue(FilasConCodsubs(T, '003') > 0, 'hay sin definir');
  finally
    T.Free;
  end;
  FConn.ExecSQL('UPDATE cl_subseries SET acceso = 2 WHERE codsubs = ''014001''');
  T := BuscarEnAmbito(FConn, True, 'administrador', True, abGeneral, ClaveN('', 0));
  try
    T.First;
    while not T.Eof do
    begin
      if T.FieldByName('codsubs').AsString = '014001' then
        Assert.AreEqual('Restringida', T.FieldByName('Acceso').AsString);
      T.Next;
    end;
  finally
    T.Free;
  end;
end;

{ TPruebasBusquedaAccess }
{ Contra la COPIA de una base .mdb (ARCHIGENIO_TEST_MDB). En Access no hay
  alcance (Alcance = nil, como en la aplicacion real). }

procedure TPruebasBusquedaAccess.Preparar;
var
  Ruta: string;
begin
  FConn := nil;
  FEsc := nil;
  Ruta := GetEnvironmentVariable(VAR_MDB);
  if Ruta = '' then
    Exit;
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSAcc';
  FConn.Params.Values['Database'] := Ruta;
  FConn.Connected := True;
  CrearEsquemaAlcance(FConn, False);
  FEsc := TEscenario.Create(FConn);
  FConn.StartTransaction;
  FEsc.Sembrar;
end;

procedure TPruebasBusquedaAccess.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
end;

function TPruebasBusquedaAccess.Buscar(const Texto, CodSubs: string;
  Limite: Integer; out Truncado: Boolean): Integer;
var
  P: TPedidoBusqueda;
  T: TFDMemTable;
begin
  P.Texto := Texto;
  P.CodSubs := CodSubs;
  P.Condiciones := nil;
  P.Limite := Limite;
  P.Ambito := abGeneral;
  P.IdsNodo := nil;
  T := UBusquedaDatos.Buscar(FConn, nil, P, False, Truncado);
  try
    Result := T.RecordCount;
  finally
    T.Free;
  end;
end;

procedure TPruebasBusquedaAccess.Access_BuscaTextoEnTitulo;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  // Sembrar() crea 2 + 3 + 4 + 5 documentos de prueba
  Assert.AreEqual(14, Buscar(TITULO_PRUEBA, '', 100000, Trunc));
  Assert.IsFalse(Trunc);
end;

procedure TPruebasBusquedaAccess.Access_Truncado;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  Assert.AreEqual(2, Buscar(TITULO_PRUEBA, '', 2, Trunc));
  Assert.IsTrue(Trunc);
end;

procedure TPruebasBusquedaAccess.Access_TablaMdInexistente;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  FConn.ExecSQL('UPDATE cl_subseries SET NombreTablaMetadatos = ''md_no_existe_xyz'' ' +
    'WHERE codsubs = ''014001''');
  Assert.AreEqual(12, Buscar(TITULO_PRUEBA, '014001', 100000, Trunc));
end;

procedure TPruebasBusquedaAccess.Access_PorcientoYApostrofeSonLiterales;
var
  Trunc: Boolean;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
    'Codigodoc, titulodoc) VALUES (''A.4.3'', 104, ''003'', :f, ''1'', ''PBUS-1'', :t)',
    [EncodeDate(2026, 10, 29), 'Acta 100% O''Brien']);
  Assert.AreEqual(1, Buscar('100%', '', 100000, Trunc), 'porciento');
  Assert.AreEqual(1, Buscar('O''Brien', '', 100000, Trunc), 'apostrofe');
  Assert.AreEqual(1, Buscar('%', '', 100000, Trunc),
    'un % solo debe buscar el caracter, no todo');
end;

procedure TPruebasBusquedaSql.Buscar_ConTablaMd;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  VerificarMd(FConn, True);
end;

procedure TPruebasBusquedaAccess.Access_ConTablaMd;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  VerificarMd(FConn, False);
end;

procedure TPruebasBusquedaAccess.Access_NodoActualIncluyeDescendientes;
var
  T: TFDMemTable;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  T := BuscarEnAmbito(FConn, False, '', True, abNodoActual, ClaveN('A.4', 101));
  try
    Assert.IsTrue(FilasEn(T, 'A.4.6') > 0, 'descendiente A.4.6');
    Assert.IsTrue(FilasEn(T, 'A.4') > 0, 'el propio nodo');
    Assert.AreEqual(0, FilasEn(T, 'A.1.7'), 'otra rama');
    Assert.IsNotNull(T.FindField('Acceso'), 'columna Acceso presente');
  finally
    T.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasBusquedaDatos);
  TDUnitX.RegisterTestFixture(TPruebasBusquedaSql);
  TDUnitX.RegisterTestFixture(TPruebasBusquedaAccess);

end.
