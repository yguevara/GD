unit UPruebasAlcanceDatos;

{ Pruebas del filtro SQL de alcance (UAlcanceDatos).
  - TPruebasFiltroTexto: sin base de datos, sobre el texto generado.
  - TPruebasAlcanceDatosSql: contra SQL Server (ARCHIGENIO_TEST_DB). Los datos
    de ejemplo se insertan dentro de una transaccion que se deshace al final.
  - TPruebasAlcanceDatosAccess: contra la COPIA de una base .mdb
    (ARCHIGENIO_TEST_MDB), tambien con transaccion deshecha. }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client, UAlcance, UAlcanceDatos;

type
  { Datos de ejemplo y consultas comunes a ambos motores. }
  TEscenario = class
  private
    FConn: TFDConnection;
    FSecuencia: Integer;
    procedure Doc(const IdEstr: string; Id: Integer; const CodSubs: string;
      Cuantos: Integer);
  public
    constructor Create(Conn: TFDConnection);
    procedure Sembrar;
    function Contar(const Filtro: TFiltroSql): Integer;
    function ContarTotal: Integer;
    function ContarPublicos: Integer;
    function Oraculo(Al: TAlcanceUsuario): Integer;
    function NodosFiltrados(const Filtro: TFiltroSql): TArray<TClaveNodo>;
  end;

  [TestFixture]
  TPruebasFiltroTexto = class
  private
    FArbol: TArbolNodos;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Nil_EsUnoIgualUno;
    [Test]
    procedure Administrador_EsUnoIgualUno;
    [Test]
    procedure SinCoberturaNiPublicas_EsUnoIgualCero;
    [Test]
    procedure Apostrofe_VaComoParametro;
    [Test]
    procedure Nodos_SiempreConParIdEstructuraId;
    [Test]
    procedure Texto_SinSintaxisExclusivaDeSqlServer;
    [Test]
    procedure ListaGrande_RespetaLimiteDeParametros;
    [Test]
    procedure Alias_Invalido_Lanza;
    [Test]
    procedure Alias_Vacio_SinPrefijo;
  end;

  [TestFixture]
  TPruebasAlcanceDatosSql = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    FTotal, FPublicos: Integer;
    function Docs(const Usuario: string; EsAdmin: Boolean): Integer;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Administrador_VeTodas;
    [Test]
    procedure AlcanceNil_VeTodas;
    [Test]
    procedure DirectorA43_SuNodo;
    [Test]
    procedure DirectorA4_NodoEHijos_SinMezclarId160;
    [Test]
    procedure EGD_NoVeHijos;
    [Test]
    procedure Usuario_SoloSubserieAsignadaMasPublicas;
    [Test]
    procedure Usuario_Id160_NoMezclaNodos;
    [Test]
    procedure SinAsignaciones_SoloPublicas;
    [Test]
    procedure FiltroDocumentos_ApostrofeEnCodigo;
    [Test]
    procedure CodSubsEnBlanco_NoDaAcceso;
    [Test]
    procedure DirectorConRolNoDirector_NoDaAcceso;
    [Test]
    procedure Usuario_SinDistinguirMayusculas;
    [Test]
    procedure Filtro_CoincideConReglasPuras;
    [Test]
    procedure FiltroArbol_SoloNodosVisibles;
  end;

  [TestFixture]
  TPruebasAlcanceDatosAccess = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Access_FiltrosSonSqlValido;
  end;

implementation

uses
  System.SysUtils, System.Variants, System.Generics.Collections,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc, FireDAC.DApt,
  FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UEsquemaAlcance;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  VAR_MDB = 'ARCHIGENIO_TEST_MDB';
  COD_APOSTROFE = '014001'' OR ''1''=''1';

function Clave(const AIdEstructura: string; AId: Integer): TClaveNodo;
begin
  Result.IdEstructura := AIdEstructura;
  Result.Id := AId;
end;

function Asig(const N: TClaveNodo; R: TRolNodo): TAsignacionNodo;
begin
  Result.Nodo := N;
  Result.Rol := R;
end;

function Sub(const N: TClaveNodo; const Cod: string): TSubserieAsignada;
begin
  Result.Nodo := N;
  Result.CodSubs := Cod;
end;

function EnConjunto(const Lista: TArray<TClaveNodo>; const Nodo: TClaveNodo): Boolean;
var
  N: TClaveNodo;
begin
  Result := False;
  for N in Lista do
    if (NormalizaClave(N.IdEstructura) = NormalizaClave(Nodo.IdEstructura)) and
      (N.Id = Nodo.Id) then
      Exit(True);
end;

{ TEscenario }

constructor TEscenario.Create(Conn: TFDConnection);
begin
  inherited Create;
  FConn := Conn;
  FSecuencia := 0;
end;

procedure TEscenario.Doc(const IdEstr: string; Id: Integer;
  const CodSubs: string; Cuantos: Integer);
var
  I: Integer;
begin
  FConn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) VALUES (:a, :b, :c)',
    [IdEstr, Id, CodSubs]);
  for I := 1 to Cuantos do
  begin
    Inc(FSecuencia);
    FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, ' +
      'Version, Codigodoc, titulodoc) VALUES (:a, :b, :c, :d, :e, :f, :g)',
      [IdEstr, Id, CodSubs, EncodeDate(2026, 10, 29), '1',
      'PALC-' + IntToStr(FSecuencia), 'prueba alcance']);
  end;
end;

procedure TEscenario.Sembrar;

  procedure Usuario(const Nombre: string);
  begin
    FConn.ExecSQL('INSERT INTO tb_user (nombreuser) VALUES (:a)', [Nombre]);
  end;

  procedure Resp(Id: Integer; const Nombre: string);
  begin
    FConn.ExecSQL('INSERT INTO cl_Resp_Gest_Arch (Idresp, usuario, Rol, habilitado) ' +
      'VALUES (:a, :b, 3, ''S'')', [Id, Nombre]);
  end;

  procedure Director(const IdEstr: string; Id, IdResp, IdRol: Integer);
  begin
    FConn.ExecSQL('INSERT INTO tb_tree_directors (IdEstructura, id, user_id, idrol) ' +
      'VALUES (:a, :b, :c, :d)', [IdEstr, Id, IdResp, IdRol]);
  end;

  procedure Subserie(const IdEstr: string; Id: Integer; const Cod, Usr: string);
  begin
    FConn.ExecSQL('INSERT INTO tb_usuario_subserie (IdEstructura, id, codsubs, user_id) ' +
      'VALUES (:a, :b, :c, :d)', [IdEstr, Id, Cod, Usr]);
  end;

begin
  // 014001 pasa a Restringida; 074 sigue Publica; 003 (acceso 0) no es publica
  FConn.ExecSQL('UPDATE cl_subseries SET acceso = 2 WHERE codsubs = ''014001''');
  Doc('A.4.3', 104, '003', 2);
  Doc('A.4.6', 160, '014001', 3);
  Doc('A.1.7', 160, '014001', 4);
  Doc('A.4', 101, '014001', 5);

  Usuario('prueba_alc_usr1');
  Usuario('prueba_alc_usr2');
  Usuario('prueba_alc_egd');
  Usuario('prueba_alc_visor');
  Usuario('prueba_alc_apos');
  Usuario('prueba_alc_vacio');
  Resp(990001, 'prueba_alc_dir43');
  Resp(990002, 'prueba_alc_dir4');
  Resp(990003, 'prueba_alc_falso');
  Director('A.4.3', 104, 990001, 3);
  Director('A.4', 101, 990002, 3);
  Director('A.4', 101, 990003, 4); // fila con rol Visor: no es director
  FConn.ExecSQL('INSERT INTO tb_nodo_egd (IdEstructura, id, user_id) VALUES (:a, :b, :c)',
    ['A.4', 101, 'prueba_alc_egd']);
  Subserie('A.4.3', 104, '014001', 'prueba_alc_usr1');
  Subserie('A.4.6', 160, '014001', 'prueba_alc_usr2');
  Subserie('A.4.3', 104, COD_APOSTROFE, 'prueba_alc_apos');
  Subserie('A.4.3', 104, ' ', 'prueba_alc_vacio');
end;

function TEscenario.Contar(const Filtro: TFiltroSql): Integer;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'SELECT COUNT(*) AS n FROM tb_SeriesDatos d WHERE ' + Filtro.Condicion;
    AplicarParametros(Q, Filtro);
    Q.Open;
    Result := Q.Fields[0].AsInteger;
  finally
    Q.Free;
  end;
end;

function TEscenario.ContarTotal: Integer;
begin
  Result := Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_SeriesDatos'));
end;

function TEscenario.ContarPublicos: Integer;
begin
  Result := Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_SeriesDatos d ' +
    'INNER JOIN cl_subseries s ON s.codsubs = d.codsubs WHERE s.acceso = 1'));
end;

function TEscenario.Oraculo(Al: TAlcanceUsuario): Integer;
var
  Q: TFDQuery;
  Nivel: Integer;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'SELECT d.IdEstructura, d.id, d.codsubs, s.acceso ' +
      'FROM tb_SeriesDatos d LEFT JOIN cl_subseries s ON s.codsubs = d.codsubs';
    Q.Open;
    while not Q.Eof do
    begin
      if Q.Fields[3].IsNull then
        Nivel := -1
      else
        Nivel := Q.Fields[3].AsInteger;
      if Al.PuedeVerDocumento(Clave(Q.Fields[0].AsString, Q.Fields[1].AsInteger),
        Q.Fields[2].AsString, Nivel) then
        Inc(Result);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

function TEscenario.NodosFiltrados(const Filtro: TFiltroSql): TArray<TClaveNodo>;
var
  Q: TFDQuery;
  Lista: TList<TClaveNodo>;
begin
  Lista := TList<TClaveNodo>.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'SELECT t.IdEstructura, t.id FROM tb_tree t WHERE ' + Filtro.Condicion;
    AplicarParametros(Q, Filtro);
    Q.Open;
    while not Q.Eof do
    begin
      Lista.Add(Clave(Q.Fields[0].AsString, Q.Fields[1].AsInteger));
      Q.Next;
    end;
    Result := Lista.ToArray;
  finally
    Q.Free;
    Lista.Free;
  end;
end;

{ TPruebasFiltroTexto }

procedure TPruebasFiltroTexto.Preparar;
begin
  FArbol := TArbolNodos.Create;
  FArbol.Agregar(Clave('A', 1), 0);
  FArbol.Agregar(Clave('A.1', 82), 1);
  FArbol.Agregar(Clave('A.4', 101), 1);
  FArbol.Agregar(Clave('A.4.3', 104), 101);
  FArbol.Agregar(Clave('A.1.7', 160), 82);
  FArbol.Agregar(Clave('A.4.6', 160), 101);
end;

procedure TPruebasFiltroTexto.Limpiar;
begin
  FArbol.Free;
end;

procedure TPruebasFiltroTexto.Nil_EsUnoIgualUno;
var
  F: TFiltroSql;
begin
  F := FiltroDocumentos(nil, 'd');
  Assert.AreEqual('1=1', F.Condicion);
  Assert.AreEqual(0, Integer(Length(F.Parametros)));
  F := FiltroNodosArbol(nil, 't');
  Assert.AreEqual('1=1', F.Condicion);
  Assert.AreEqual(0, Integer(Length(F.Parametros)));
end;

procedure TPruebasFiltroTexto.Administrador_EsUnoIgualUno;
var
  Al: TAlcanceUsuario;
  F: TFiltroSql;
begin
  Al := TAlcanceUsuario.Create(True, FArbol, nil, nil, ['074']);
  try
    F := FiltroDocumentos(Al, 'd');
    Assert.AreEqual('1=1', F.Condicion);
    Assert.AreEqual(0, Integer(Length(F.Parametros)));
    F := FiltroNodosArbol(Al, 't');
    Assert.AreEqual('1=1', F.Condicion);
  finally
    Al.Free;
  end;
end;

procedure TPruebasFiltroTexto.SinCoberturaNiPublicas_EsUnoIgualCero;
var
  Al: TAlcanceUsuario;
  F: TFiltroSql;
begin
  Al := TAlcanceUsuario.Create(False, FArbol, nil, [Sub(Clave('A.4', 101), ' ')], nil);
  try
    F := FiltroDocumentos(Al, 'd');
    Assert.AreEqual('1=0', F.Condicion);
    F := FiltroNodosArbol(Al, 't');
    Assert.AreEqual('1=0', F.Condicion);
  finally
    Al.Free;
  end;
end;

procedure TPruebasFiltroTexto.Apostrofe_VaComoParametro;
var
  Al: TAlcanceUsuario;
  F: TFiltroSql;
  P: TParametroSql;
  Hallado: Boolean;
begin
  Al := TAlcanceUsuario.Create(False, FArbol, nil,
    [Sub(Clave('A.4.3', 104), COD_APOSTROFE)], ['07''4']);
  try
    F := FiltroDocumentos(Al, 'd');
    Assert.IsFalse(F.Condicion.Contains(''''), 'La condicion lleva literales: ' + F.Condicion);
    Hallado := False;
    for P in F.Parametros do
      if VarToStr(P.Valor) = UpperCase(COD_APOSTROFE) then
        Hallado := True;
    Assert.IsTrue(Hallado, 'El codigo con apostrofe no se paso como parametro');
  finally
    Al.Free;
  end;
end;

procedure TPruebasFiltroTexto.Nodos_SiempreConParIdEstructuraId;
var
  Al: TAlcanceUsuario;
  F: TFiltroSql;
begin
  Al := TAlcanceUsuario.Create(False, FArbol, [Asig(Clave('A.4.6', 160), rnEGD)],
    [Sub(Clave('A.1.7', 160), '014001')], nil);
  try
    F := FiltroDocumentos(Al, 'd');
    // cada aparicion de d.id va precedida de su d.IdEstructura en el mismo grupo
    Assert.AreEqual(
      '((d.IdEstructura = :alcd_1 AND d.id IN (160)) OR ' +
      '(d.IdEstructura = :alcd_2 AND d.id = 160 AND d.codsubs IN (:alcd_3)))',
      F.Condicion);
    Assert.AreEqual(3, Integer(Length(F.Parametros)));
    Assert.AreEqual('A.4.6', VarToStr(F.Parametros[0].Valor));
    Assert.AreEqual('A.1.7', VarToStr(F.Parametros[1].Valor));
    Assert.AreEqual('014001', VarToStr(F.Parametros[2].Valor));
    F := FiltroNodosArbol(Al, 't');
    Assert.IsTrue(F.Condicion.Contains('t.IdEstructura = :alca_'), F.Condicion);
    Assert.IsFalse(F.Condicion.Contains('d.'), F.Condicion);
  finally
    Al.Free;
  end;
end;

procedure TPruebasFiltroTexto.Texto_SinSintaxisExclusivaDeSqlServer;
const
  PROHIBIDOS: array[0..14] of string = ('[', ']', '"', 'TOP ', 'ISNULL', 'COALESCE',
    'CONCAT', 'LEN(', 'CAST(', 'CONVERT(', 'COLLATE', 'N''', '+', '--', ';');
var
  Al: TAlcanceUsuario;
  F: TFiltroSql;
  S: string;
  I: Integer;
begin
  Al := TAlcanceUsuario.Create(False, FArbol,
    [Asig(Clave('A.4', 101), rnDirector), Asig(Clave('A.1', 82), rnEGD)],
    [Sub(Clave('A.1.7', 160), '014001'), Sub(Clave('A.1.7', 160), '003')],
    ['074', '014']);
  try
    for I := 0 to 1 do
    begin
      if I = 0 then
        F := FiltroDocumentos(Al, 'd')
      else
        F := FiltroNodosArbol(Al, 't');
      for S in PROHIBIDOS do
        Assert.IsFalse(UpperCase(F.Condicion).Contains(S),
          'Contiene "' + S + '": ' + F.Condicion);
    end;
  finally
    Al.Free;
  end;
end;

procedure TPruebasFiltroTexto.ListaGrande_RespetaLimiteDeParametros;
var
  Arbol: TArbolNodos;
  Al: TAlcanceUsuario;
  F: TFiltroSql;
  I: Integer;
begin
  Arbol := TArbolNodos.Create;
  try
    Arbol.Agregar(Clave('R', 1), 0);
    for I := 2 to 3000 do
      Arbol.Agregar(Clave('R.' + IntToStr(I), I), 1);
    Arbol.Agregar(Clave('R.O''X', 5000), 1);
    Al := TAlcanceUsuario.Create(False, Arbol, [Asig(Clave('R', 1), rnDirector)],
      [Sub(Clave('R.2', 2), 'X''Y')], ['074']);
    try
      F := FiltroDocumentos(Al, 'd');
      Assert.IsTrue(Length(F.Parametros) <= LIMITE_PARAMETROS,
        'Demasiados parametros: ' + IntToStr(Length(F.Parametros)));
      Assert.IsTrue(F.Condicion.Contains('d.id IN (5000)'), 'Falta el nodo 5000');
      // por encima del limite los textos van como literales con el apostrofe doblado
      Assert.IsTrue(F.Condicion.Contains('''R.O''''X'''), 'Literal mal escapado');
      Assert.IsFalse(F.Condicion.Contains('''R.O''X'''), 'Literal sin escapar');
      F := FiltroNodosArbol(Al, 't');
      Assert.IsTrue(Length(F.Parametros) <= LIMITE_PARAMETROS);
    finally
      Al.Free;
    end;
  finally
    Arbol.Free;
  end;
end;

procedure TPruebasFiltroTexto.Alias_Invalido_Lanza;
var
  Al: TAlcanceUsuario;
begin
  Al := TAlcanceUsuario.Create(False, FArbol, nil, nil, ['074']);
  try
    Assert.WillRaise(
      procedure
      begin
        FiltroDocumentos(Al, 'd; DROP TABLE x');
      end, EArgumentException);
    Assert.WillRaise(
      procedure
      begin
        FiltroNodosArbol(Al, 't.x');
      end, EArgumentException);
  finally
    Al.Free;
  end;
end;

procedure TPruebasFiltroTexto.Alias_Vacio_SinPrefijo;
var
  Al: TAlcanceUsuario;
  F: TFiltroSql;
begin
  Al := TAlcanceUsuario.Create(False, FArbol, nil, nil, ['074']);
  try
    F := FiltroDocumentos(Al, '');
    Assert.AreEqual('(codsubs IN (:alcd_1))', F.Condicion);
  finally
    Al.Free;
  end;
end;

{ TPruebasAlcanceDatosSql }

procedure TPruebasAlcanceDatosSql.Preparar;
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
  FTotal := FEsc.ContarTotal;
  FPublicos := FEsc.ContarPublicos;
end;

procedure TPruebasAlcanceDatosSql.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
end;

function TPruebasAlcanceDatosSql.Docs(const Usuario: string; EsAdmin: Boolean): Integer;
var
  Al: TAlcanceUsuario;
begin
  Al := CargarAlcance(FConn, Usuario, EsAdmin);
  try
    Result := FEsc.Contar(FiltroDocumentos(Al, 'd'));
    Assert.AreEqual(FEsc.Oraculo(Al), Result, 'El filtro SQL no coincide con las reglas puras');
  finally
    Al.Free;
  end;
end;

procedure TPruebasAlcanceDatosSql.Administrador_VeTodas;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(FTotal, Docs('administrador', True));
end;

procedure TPruebasAlcanceDatosSql.AlcanceNil_VeTodas;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(FTotal, FEsc.Contar(FiltroDocumentos(nil, 'd')));
end;

procedure TPruebasAlcanceDatosSql.DirectorA43_SuNodo;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // A.4.3: 27 de 014001 (ya en la base) + 2 de 003 (sembrados)
  Assert.AreEqual(FPublicos + 29, Docs('prueba_alc_dir43', False));
end;

procedure TPruebasAlcanceDatosSql.DirectorA4_NodoEHijos_SinMezclarId160;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // A.4 (5) + A.4.3 (29) + A.4.6/160 (3); no A.1.7/160 (4)
  Assert.AreEqual(FPublicos + 37, Docs('prueba_alc_dir4', False));
end;

procedure TPruebasAlcanceDatosSql.EGD_NoVeHijos;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(FPublicos + 5, Docs('prueba_alc_egd', False));
end;

procedure TPruebasAlcanceDatosSql.Usuario_SoloSubserieAsignadaMasPublicas;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // solo los 27 de (A.4.3, 014001); no los 2 de (A.4.3, 003)
  Assert.AreEqual(FPublicos + 27, Docs('prueba_alc_usr1', False));
end;

procedure TPruebasAlcanceDatosSql.Usuario_Id160_NoMezclaNodos;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // (A.4.6, 160, 014001): 3; los 4 de (A.1.7, 160, 014001) no
  Assert.AreEqual(FPublicos + 3, Docs('prueba_alc_usr2', False));
end;

procedure TPruebasAlcanceDatosSql.SinAsignaciones_SoloPublicas;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.IsTrue(FPublicos > 0, 'La base no tiene documentos publicos');
  Assert.IsTrue(FPublicos < FTotal);
  Assert.AreEqual(FPublicos, Docs('prueba_alc_visor', False));
  Assert.AreEqual(FPublicos, Docs('no_existe_este_usuario', False));
end;

procedure TPruebasAlcanceDatosSql.FiltroDocumentos_ApostrofeEnCodigo;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(FPublicos, Docs('prueba_alc_apos', False));
  // la tabla sigue ahi y la transaccion sigue viva
  Assert.AreEqual(FTotal, FEsc.ContarTotal);
end;

procedure TPruebasAlcanceDatosSql.CodSubsEnBlanco_NoDaAcceso;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(FPublicos, Docs('prueba_alc_vacio', False));
end;

procedure TPruebasAlcanceDatosSql.DirectorConRolNoDirector_NoDaAcceso;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(FPublicos, Docs('prueba_alc_falso', False));
end;

procedure TPruebasAlcanceDatosSql.Usuario_SinDistinguirMayusculas;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Assert.AreEqual(FPublicos + 27, Docs(' PRUEBA_ALC_USR1 ', False));
  Assert.AreEqual(FPublicos + 29, Docs('Prueba_Alc_Dir43', False));
end;

procedure TPruebasAlcanceDatosSql.Filtro_CoincideConReglasPuras;
var
  Al: TAlcanceUsuario;
  Arbol: TArbolNodos;
  Q: TFDQuery;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  // varios roles a la vez, construido a mano sobre el arbol real
  Arbol := TArbolNodos.Create;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.Open('SELECT IdEstructura, id, padre FROM tb_tree');
    while not Q.Eof do
    begin
      Arbol.Agregar(Clave(Q.Fields[0].AsString, Q.Fields[1].AsInteger), Q.Fields[2].AsInteger);
      Q.Next;
    end;
    Al := TAlcanceUsuario.Create(False, Arbol,
      [Asig(Clave('A.4.6', 160), rnEGD), Asig(Clave('A.3', 92), rnDirector)],
      [Sub(Clave('a.4.3 ', 104), '003'), Sub(Clave('A.1.7', 160), '014001')], ['074']);
    try
      Assert.AreEqual(FEsc.Oraculo(Al), FEsc.Contar(FiltroDocumentos(Al, 'd')));
    finally
      Al.Free;
    end;
  finally
    Q.Free;
    Arbol.Free;
  end;
end;

procedure TPruebasAlcanceDatosSql.FiltroArbol_SoloNodosVisibles;
var
  Al: TAlcanceUsuario;
  N, V: TArray<TClaveNodo>;
  K: TClaveNodo;
  I: Integer;
  Usuarios: array[0..2] of string;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB'); Exit; end;
  Usuarios[0] := 'prueba_alc_usr1';
  Usuarios[1] := 'prueba_alc_usr2';
  Usuarios[2] := 'prueba_alc_dir4';
  for I := Low(Usuarios) to High(Usuarios) do
  begin
    Al := CargarAlcance(FConn, Usuarios[I], False);
    try
      V := Al.NodosVisibles;
      N := FEsc.NodosFiltrados(FiltroNodosArbol(Al, 't'));
      Assert.AreEqual(Length(V), Length(N), Usuarios[I]);
      for K in N do
        Assert.IsTrue(EnConjunto(V, K), Usuarios[I] + ': sobra ' + K.IdEstructura);
    finally
      Al.Free;
    end;
  end;
  Al := CargarAlcance(FConn, 'prueba_alc_usr2', False);
  try
    N := FEsc.NodosFiltrados(FiltroNodosArbol(Al, 't'));
    Assert.AreEqual(3, Integer(Length(N)));
    Assert.IsTrue(EnConjunto(N, Clave('A.4.6', 160)));
    Assert.IsFalse(EnConjunto(N, Clave('A.1.7', 160)));
    Assert.IsFalse(EnConjunto(N, Clave('A.3.3', 160)));
  finally
    Al.Free;
  end;
  Al := CargarAlcance(FConn, 'prueba_alc_visor', False);
  try
    Assert.AreEqual(0, Integer(Length(FEsc.NodosFiltrados(FiltroNodosArbol(Al, 't')))));
  finally
    Al.Free;
  end;
  Al := CargarAlcance(FConn, 'administrador', True);
  try
    Assert.AreEqual(Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_tree')),
      Integer(Length(FEsc.NodosFiltrados(FiltroNodosArbol(Al, 't')))));
  finally
    Al.Free;
  end;
end;

{ TPruebasAlcanceDatosAccess }

procedure TPruebasAlcanceDatosAccess.Preparar;
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

procedure TPruebasAlcanceDatosAccess.Limpiar;
begin
  if (FConn <> nil) and FConn.InTransaction then
    FConn.Rollback;
  FreeAndNil(FEsc);
  FreeAndNil(FConn);
end;

procedure TPruebasAlcanceDatosAccess.Access_FiltrosSonSqlValido;
const
  USUARIOS: array[0..6] of string = ('prueba_alc_usr1', 'prueba_alc_usr2',
    'prueba_alc_dir43', 'prueba_alc_dir4', 'prueba_alc_egd', 'prueba_alc_apos',
    'prueba_alc_visor');
var
  Al: TAlcanceUsuario;
  Total, Publicos: Integer;
  U: string;
  V, N: TArray<TClaveNodo>;
begin
  if FConn = nil then begin Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB'); Exit; end;
  Total := FEsc.ContarTotal;
  Publicos := FEsc.ContarPublicos;
  Assert.AreEqual(Total, FEsc.Contar(FiltroDocumentos(nil, 'd')));
  Assert.AreEqual(Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_tree')),
    Integer(Length(FEsc.NodosFiltrados(FiltroNodosArbol(nil, 't')))));
  Al := CargarAlcance(FConn, 'administrador', True);
  try
    Assert.AreEqual(Total, FEsc.Contar(FiltroDocumentos(Al, 'd')));
  finally
    Al.Free;
  end;
  for U in USUARIOS do
  begin
    Al := CargarAlcance(FConn, U, False);
    try
      Assert.AreEqual(FEsc.Oraculo(Al), FEsc.Contar(FiltroDocumentos(Al, 'd')), 'Access: ' + U);
      V := Al.NodosVisibles;
      N := FEsc.NodosFiltrados(FiltroNodosArbol(Al, 't'));
      Assert.AreEqual(Length(V), Length(N), 'Access arbol: ' + U);
    finally
      Al.Free;
    end;
  end;
  Al := CargarAlcance(FConn, 'prueba_alc_usr2', False);
  try
    Assert.AreEqual(Publicos + 3, FEsc.Contar(FiltroDocumentos(Al, 'd')));
  finally
    Al.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasFiltroTexto);
  TDUnitX.RegisterTestFixture(TPruebasAlcanceDatosSql);
  TDUnitX.RegisterTestFixture(TPruebasAlcanceDatosAccess);

end.
