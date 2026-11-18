unit UPruebasEdicionDocumento;

{ Edicion de uno o varios documentos (logica y datos). SQL Server:
  ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB (COPIA). Cada prueba corre en
  los motores que tengan su variable; sin ninguna se omite. Las filas
  sembradas llevan codigo F7T-* y se borran al final. Codigo en ASCII. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, DUnitX.TestFramework, UAlcance,
  UCargaDocumento, UDocumentoVista, UEdicionDocumento;

type
  TCuerpoPrueba = reference to procedure(EsSql: Boolean);

  [TestFixture]
  TPruebasEdicionDocumento = class
  private
    FConn: TFDConnection;
    FOrigen: TOrigenDocumento;
    procedure Conectar(EsSql: Boolean);
    procedure Desconectar;
    function Clave(N: Integer): TClaveDocumento;
    procedure Sembrar(N: Integer);
    function Texto(N: Integer; const Campo: string): string;
    procedure EnCadaMotor(const Cuerpo: TCuerpoPrueba);
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Valida_TituloVacioOLargo_Rechaza;
    [Test]
    procedure Valida_CamposValidos_Pasa;
    [Test]
    procedure Valida_CamposLargosOVisibleRaro_Rechaza;
    [Test]
    procedure Actualiza_UnDocumento_SoloLosCamposPedidos;
    [Test]
    procedure Actualiza_Lote_CambiaTodos;
    [Test]
    procedure Actualiza_Lote_UnoFalla_LosDemasSeGuardan;
    [Test]
    procedure SinCambios_NoHaceNada;
    [Test]
    procedure Actualiza_DocumentoTransferido_NoSeEditaYLoDice;
    [Test]
    procedure NoToca_LasClaves;
    [Test]
    procedure Vaciar_PoneNullEnElCampo;
    [Test]
    procedure Bitacora_RegistraElCambio;
    [Test]
    procedure OtroUsuarioCambioElCampo_NoSePisaEnSilencio;
    [Test]
    procedure Topografia_FueraDeLaSubserie_NoSeGuardaYLoDice;
    [Test]
    procedure Topografia_ConLaDeLaSubserie_SeGuarda;
    [Test]
    procedure Topografia_DocumentoYaDesalineado_EditarElTitulo_NoSeBloquea;
    [Test]
    procedure SinPermisoDeEditar_SeOmiteElDocumento;
    [Test]
    procedure Topografia_SinPermiso_SeOmiteElCampoYSeAvisa;
  end;

implementation

uses
  System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL, FireDAC.Phys.MSAcc,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB,
  UEsquemaTrazabilidad, UEsquemaProcesos, UCandados, UPruebasApoyoTransferido;

const
  PREF = 'F7T-';

procedure TPruebasEdicionDocumento.Preparar;
begin
  FConn := nil;
  FOrigen := Default(TOrigenDocumento);
  FOrigen.IdEstructura := 'A.4.3';
  FOrigen.Id := 104;
  FOrigen.CodSubs := '074';
  FOrigen.CodSerie := '07';
  FOrigen.Usuario := 'prueba';
  FOrigen.Rol := 'Administrador';
end;

procedure TPruebasEdicionDocumento.Limpiar;
begin
  Desconectar;
end;

procedure TPruebasEdicionDocumento.Desconectar;
begin
  if FConn <> nil then
  begin
    try
      FConn.ExecSQL('DELETE FROM tb_SeriesDatos WHERE Codigodoc LIKE ''F7T-%''');
      FConn.ExecSQL('DELETE FROM tb_log WHERE msg LIKE ''%F7T-%''');
    except
    end;
    FreeAndNil(FConn);
  end;
end;

function TPruebasEdicionDocumento.Clave(N: Integer): TClaveDocumento;
begin
  Result.IdEstructura := 'A.4.3';
  Result.Id := 104;
  Result.CodSubs := '074';
  Result.Fecha := EncodeDate(2026, 1, 31);
  Result.Version := '1';
  Result.Codigodoc := PREF + Format('%.3d', [N]);
end;

procedure TPruebasEdicionDocumento.Conectar(EsSql: Boolean);
begin
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  if EsSql then
  begin
    FConn.DriverName := 'MSSQL';
    FConn.Params.Values['Server'] := 'localhost';
    FConn.Params.Values['Database'] := GetEnvironmentVariable('ARCHIGENIO_TEST_DB');
    FConn.Params.Values['User_Name'] := 'geoconn';
    FConn.Params.Values['Password'] := 'geoconn';
    FConn.Params.Values['OSAuthent'] := 'No';
  end
  else
  begin
    FConn.DriverName := 'MSAcc';
    FConn.Params.Values['Database'] := GetEnvironmentVariable('ARCHIGENIO_TEST_MDB');
  end;
  FConn.Connected := True;
  CrearEsquemaTrazabilidad(FConn, EsSql);
  FConn.ExecSQL('DELETE FROM tb_SeriesDatos WHERE Codigodoc LIKE ''F7T-%''');
end;

procedure TPruebasEdicionDocumento.Sembrar(N: Integer);
var
  C: TClaveDocumento;
begin
  C := Clave(N);
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Codigodoc, ' +
    'fecha, version, titulodoc, observaciones, deposito, gaveta) VALUES ' +
    '(:e, :i, :c, :d, :f, :v, :t, ''obs inicial'', ''C'', ''G1'')',
    [C.IdEstructura, C.Id, C.CodSubs, C.Codigodoc, C.Fecha, C.Version,
    'Título original ' + IntToStr(N)]);
end;

function TPruebasEdicionDocumento.Texto(N: Integer; const Campo: string): string;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.SQL.Text := 'SELECT ' + Campo + ' FROM tb_SeriesDatos WHERE Codigodoc = :c';
    Q.ParamByName('c').AsString := Clave(N).Codigodoc;
    Q.Open;
    if Q.IsEmpty or Q.Fields[0].IsNull then
      Result := '<NULL>'
    else
      Result := Q.Fields[0].AsString;
  finally
    Q.Free;
  end;
end;

procedure TPruebasEdicionDocumento.EnCadaMotor(const Cuerpo: TCuerpoPrueba);
var
  Corrio: Boolean;
begin
  Corrio := False;
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') <> '' then
  begin
    Corrio := True;
    Conectar(True);
    try
      Cuerpo(True);
    finally
      Desconectar;
    end;
  end;
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') <> '' then
  begin
    Corrio := True;
    Conectar(False);
    try
      Cuerpo(False);
    finally
      Desconectar;
    end;
  end;
  if not Corrio then
    Assert.Pass('omitida: faltan ARCHIGENIO_TEST_DB y ARCHIGENIO_TEST_MDB');
end;

procedure TPruebasEdicionDocumento.Valida_TituloVacioOLargo_Rechaza;
var
  C: TCambiosDoc;
begin
  C := Default(TCambiosDoc);
  C.TieneTitulo := True;
  C.Titulo := '   ';
  Assert.IsTrue(ValidarCambios(C) <> '', 'título en blanco');
  C.Titulo := StringOfChar('x', 256);
  Assert.IsTrue(ValidarCambios(C) <> '', 'título de mas de 255');
  C.Titulo := StringOfChar('x', 255);
  Assert.AreEqual('', ValidarCambios(C));
end;

procedure TPruebasEdicionDocumento.Valida_CamposValidos_Pasa;
var
  C: TCambiosDoc;
begin
  C := Default(TCambiosDoc);
  Assert.AreEqual('', ValidarCambios(C), 'sin cambios no hay nada que validar');
  C.TieneGaveta := True;
  C.Gaveta := 'G-02';
  C.TieneVisible := True;
  C.Visible := 'S';
  Assert.AreEqual('', ValidarCambios(C));
end;

procedure TPruebasEdicionDocumento.Valida_CamposLargosOVisibleRaro_Rechaza;
var
  C: TCambiosDoc;
begin
  C := Default(TCambiosDoc);
  C.TieneGaveta := True;
  C.Gaveta := StringOfChar('g', 21);
  Assert.IsTrue(ValidarCambios(C) <> '', 'gaveta de mas de 20');
  C := Default(TCambiosDoc);
  C.TienePosicion := True;
  C.Posicion := StringOfChar('p', 11);
  Assert.IsTrue(ValidarCambios(C) <> '', 'posición de mas de 10');
  C := Default(TCambiosDoc);
  C.TieneIdExpediente := True;
  C.IdExpediente := StringOfChar('e', 21);
  Assert.IsTrue(ValidarCambios(C) <> '', 'expediente de mas de 20');
  C := Default(TCambiosDoc);
  C.TieneVisible := True;
  C.Visible := 'X';
  Assert.IsTrue(ValidarCambios(C) <> '', 'visible solo S o N');
end;

procedure TPruebasEdicionDocumento.Actualiza_UnDocumento_SoloLosCamposPedidos;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
      R: TResultadoEdicion;
    begin
      Sembrar(1);
      C := Default(TCambiosDoc);
      C.TieneTitulo := True;
      C.Titulo := 'Título nuevo';
      R := ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1)], C, Default(TCambiosDoc));
      Assert.AreEqual(1, R.Guardados);
      Assert.AreEqual('Título nuevo', Texto(1, 'titulodoc'));
      Assert.AreEqual('obs inicial', Texto(1, 'observaciones'), 'lo que no se pidio no cambia');
    end);
end;

procedure TPruebasEdicionDocumento.Actualiza_Lote_CambiaTodos;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
      R: TResultadoEdicion;
    begin
      Sembrar(1);
      Sembrar(2);
      Sembrar(3);
      C := Default(TCambiosDoc);
      C.TieneGaveta := True;
      C.Gaveta := '14';
      C.TieneIdExpediente := True;
      C.IdExpediente := 'P-006';
      R := ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1), Clave(2), Clave(3)], C,
        Default(TCambiosDoc));
      Assert.AreEqual(3, R.Guardados, R.Mensaje);
      Assert.AreEqual('14', Texto(2, 'gaveta'));
      Assert.AreEqual('P-006', Texto(3, 'IDExpediente'));
      Assert.AreEqual('Título original 2', Texto(2, 'titulodoc'));
    end);
end;

procedure TPruebasEdicionDocumento.Actualiza_Lote_UnoFalla_LosDemasSeGuardan;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
      R: TResultadoEdicion;
    begin
      Sembrar(1);
      Sembrar(3);
      C := Default(TCambiosDoc);
      C.TieneGaveta := True;
      C.Gaveta := '14';
      // el 2 no existe: no se puede actualizar
      R := ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1), Clave(2), Clave(3)], C,
        Default(TCambiosDoc));
      Assert.AreEqual(2, R.Guardados);
      Assert.AreEqual(1, R.Fallidos);
      Assert.AreEqual('14', Texto(1, 'gaveta'));
      Assert.AreEqual('14', Texto(3, 'gaveta'), 'el siguiente se guarda igual');
      Assert.IsTrue(R.Mensaje <> '');
    end);
end;

procedure TPruebasEdicionDocumento.Actualiza_DocumentoTransferido_NoSeEditaYLoDice;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
      R: TResultadoEdicion;
      K: TClaveDocumento;
      U: TUnidadDoc;
    begin
      if not EsSql then Exit;  // las tablas prc_* solo se prueban en SQL Server
      CrearEsquemaProcesos(FConn, True);
      Sembrar(1);
      Sembrar(2);
      K := Clave(1);
      U.IdEstructura := K.IdEstructura;
      U.Id := K.Id;
      U.CodSubs := K.CodSubs;
      U.CodigoDoc := K.Codigodoc;
      U.Fecha := K.Fecha;
      U.Version := K.Version;
      SembrarTransferido(FConn, U, '__prueba__');
      try
        C := Default(TCambiosDoc);
        C.TieneTitulo := True;
        C.Titulo := 'Nuevo';
        R := ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1), Clave(2)], C,
          Default(TCambiosDoc));
        Assert.AreEqual(1, R.Guardados, 'solo se guarda el que no esta transferido');
        Assert.AreEqual(1, R.Omitidos);
        Assert.IsTrue(Pos('transferido', R.Mensaje) > 0, 'el mensaje lo dice: ' + R.Mensaje);
        Assert.AreNotEqual('Nuevo', Texto(1, 'titulodoc'), 'el transferido no cambia');
        Assert.AreEqual('Nuevo', Texto(2, 'titulodoc'));
      finally
        LimpiarTransferidos(FConn, '__prueba__');
      end;
    end);
end;

procedure TPruebasEdicionDocumento.SinCambios_NoHaceNada;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoEdicion;
    begin
      Sembrar(1);
      R := ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1)], Default(TCambiosDoc),
        Default(TCambiosDoc));
      Assert.AreEqual(0, R.Guardados);
      Assert.AreEqual(0, R.Fallidos);
      Assert.AreEqual('Título original 1', Texto(1, 'titulodoc'));
    end);
end;

procedure TPruebasEdicionDocumento.NoToca_LasClaves;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
      Antes, Despues: string;
    begin
      Sembrar(1);
      Antes := Texto(1, 'Codigodoc') + Texto(1, 'Version') + Texto(1, 'Fecha');
      C := Default(TCambiosDoc);
      C.TieneTitulo := True;
      C.Titulo := 'otro';
      C.TieneObservaciones := True;
      C.Observaciones := 'o';
      ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1)], C, Default(TCambiosDoc));
      Despues := Texto(1, 'Codigodoc') + Texto(1, 'Version') + Texto(1, 'Fecha');
      Assert.AreEqual(Antes, Despues);
    end);
end;

procedure TPruebasEdicionDocumento.Vaciar_PoneNullEnElCampo;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
    begin
      Sembrar(1);
      C := Default(TCambiosDoc);
      C.TieneObservaciones := True;
      C.Observaciones := '';
      C.TieneArchivo := True;
      C.Archivo := -1; // vaciar
      ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1)], C, Default(TCambiosDoc));
      Assert.AreEqual('<NULL>', Texto(1, 'observaciones'));
      Assert.AreEqual('<NULL>', Texto(1, 'Archivo'));
    end);
end;

procedure TPruebasEdicionDocumento.Bitacora_RegistraElCambio;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
    begin
      Sembrar(1);
      C := Default(TCambiosDoc);
      C.TieneTitulo := True;
      C.Titulo := 'Con bitacora';
      ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1)], C, Default(TCambiosDoc));
      Assert.AreEqual(1, Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_log WHERE ' +
        'msg LIKE ''%F7T-001%'' AND accion = 3')));
    end);
end;

procedure TPruebasEdicionDocumento.OtroUsuarioCambioElCampo_NoSePisaEnSilencio;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C, Ant: TCambiosDoc;
      R: TResultadoEdicion;
    begin
      Sembrar(1);
      // el formulario se abrio cuando el titulo era "Titulo original 1"
      Ant := Default(TCambiosDoc);
      Ant.TieneTitulo := True;
      Ant.Titulo := 'Título original 1';
      // mientras tanto otro usuario lo cambio
      FConn.ExecSQL('UPDATE tb_SeriesDatos SET titulodoc = ''Cambio ajeno'' WHERE Codigodoc = ''F7T-001''');
      C := Default(TCambiosDoc);
      C.TieneTitulo := True;
      C.Titulo := 'Mi cambio';
      R := ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1)], C, Ant);
      Assert.AreEqual(0, R.Guardados);
      Assert.AreEqual(1, R.Fallidos);
      Assert.IsTrue(Pos('otro usuario', LowerCase(R.Mensaje)) > 0);
      Assert.AreEqual('Cambio ajeno', Texto(1, 'titulodoc'), 'no se piso el cambio ajeno');
    end);
end;

var
  GArbol: TArbolNodos;  // el alcance no es duenio del arbol: lo libera la prueba

function AlcanceDirector: TAlcanceUsuario;
var
  Arbol: TArbolNodos;
  Nodo: TClaveNodo;
  A: TArray<TAsignacionNodo>;
  S: TArray<TSubserieAsignada>;
begin
  Arbol := TArbolNodos.Create;
  Nodo.IdEstructura := 'A.4.3';
  Nodo.Id := 104;
  Arbol.Agregar(Nodo, 0);
  SetLength(A, 1);
  A[0].Nodo := Nodo;
  A[0].Rol := rnDirector;
  SetLength(S, 1);
  S[0].Nodo := Nodo;
  S[0].CodSubs := '074';
  GArbol := Arbol;
  Result := TAlcanceUsuario.Create(False, Arbol, A, S, nil);
end;

// La subserie A.4.3 / 074 (la de las pruebas) queda en deposito 01 y gaveta 14
procedure PonerUbicacionDeLaSubserie(Conn: TFDConnection);
begin
  // la subserie A.4.3 / 104 / 074 de las bases de prueba ya esta en el deposito 01,
  // gaveta 14: no se modifica ningun dato
  Assert.IsTrue(Integer(Conn.ExecSQLScalar('SELECT COUNT(*) FROM tb_Serietree WHERE ' +
    'IdEstructura = ''A.4.3'' AND id = 104 AND codsubs = ''074'' AND gaveta = ''14''')) = 1,
    'la subserie de prueba debe estar en la gaveta 14');
end;

procedure TPruebasEdicionDocumento.Topografia_FueraDeLaSubserie_NoSeGuardaYLoDice;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
      R: TResultadoEdicion;
    begin
      PonerUbicacionDeLaSubserie(FConn);
      Sembrar(1);
      C := Default(TCambiosDoc);
      C.TieneGaveta := True;
      C.Gaveta := '02'; // la subserie esta en la gaveta 14
      R := ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1)], C, Default(TCambiosDoc));
      Assert.AreEqual(0, R.Guardados);
      Assert.AreEqual(1, R.Fallidos);
      Assert.IsTrue(Pos('gaveta', LowerCase(R.Mensaje)) > 0, R.Mensaje);
      Assert.IsTrue(Pos('14', R.Mensaje) > 0, 'dice donde esta la subserie');
      Assert.AreEqual('G1', Texto(1, 'gaveta'), 'no se cambio');
    end);
end;

procedure TPruebasEdicionDocumento.Topografia_ConLaDeLaSubserie_SeGuarda;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
      R: TResultadoEdicion;
    begin
      PonerUbicacionDeLaSubserie(FConn);
      Sembrar(1);
      C := Default(TCambiosDoc);
      C.TieneGaveta := True;
      C.Gaveta := '14';
      C.TieneDeposito := True;
      C.Deposito := '01';
      C.TienePosicion := True;
      C.Posicion := '3'; // la posicion es del documento: libre
      R := ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1)], C, Default(TCambiosDoc));
      Assert.AreEqual(1, R.Guardados, R.Mensaje);
      Assert.AreEqual('14', Texto(1, 'gaveta'));
    end);
end;

procedure TPruebasEdicionDocumento.Topografia_DocumentoYaDesalineado_EditarElTitulo_NoSeBloquea;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      C: TCambiosDoc;
      R: TResultadoEdicion;
    begin
      PonerUbicacionDeLaSubserie(FConn);
      Sembrar(1); // gaveta G1, distinta de la 14: dato heredado
      C := Default(TCambiosDoc);
      C.TieneTitulo := True;
      C.Titulo := 'Solo el titulo';
      R := ActualizarDocumentos(FConn, nil, FOrigen, [Clave(1)], C, Default(TCambiosDoc));
      Assert.AreEqual(1, R.Guardados, 'solo se valida lo que se cambia');
    end);
end;

procedure TPruebasEdicionDocumento.SinPermisoDeEditar_SeOmiteElDocumento;
var
  Al: TAlcanceUsuario;
  C: TCambiosDoc;
  R: TResultadoEdicion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  Sembrar(1);
  Al := TAlcanceUsuario.Create(False, nil, nil, nil, nil);
  try
    C := Default(TCambiosDoc);
    C.TieneTitulo := True;
    C.Titulo := 'No debe cambiar';
    R := ActualizarDocumentos(FConn, Al, FOrigen, [Clave(1)], C, Default(TCambiosDoc));
    Assert.AreEqual(0, R.Guardados);
    Assert.AreEqual(1, R.Omitidos);
    Assert.AreEqual('Título original 1', Texto(1, 'titulodoc'));
  finally
    Al.Free;
  end;
end;

procedure TPruebasEdicionDocumento.Topografia_SinPermiso_SeOmiteElCampoYSeAvisa;
var
  Al: TAlcanceUsuario;
  C: TCambiosDoc;
  R: TResultadoEdicion;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  Sembrar(1);
  // un Director edita pero no puede cambiar la topografia
  Al := AlcanceDirector;
  try
    C := Default(TCambiosDoc);
    C.TieneTitulo := True;
    C.Titulo := 'Si cambia';
    C.TieneGaveta := True;
    C.Gaveta := 'NUEVA';
    R := ActualizarDocumentos(FConn, Al, FOrigen, [Clave(1)], C, Default(TCambiosDoc));
    Assert.AreEqual(1, R.Guardados, 'el título si se guarda');
    Assert.AreEqual('Si cambia', Texto(1, 'titulodoc'));
    Assert.AreEqual('G1', Texto(1, 'gaveta'), 'la gaveta no cambia sin permiso de topografía');
    Assert.IsTrue(Pos('ubicación', LowerCase(R.Mensaje)) > 0, 'avisa que omitio la ubicación');
  finally
    Al.Free;
    FreeAndNil(GArbol);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasEdicionDocumento);

end.
