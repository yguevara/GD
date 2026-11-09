unit UPruebasCargaDocumento;

{ Guardar un documento con sus ficheros, metadatos y bitacora, con un almacen en
  memoria. SQL Server: ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB (COPIA).
  Las filas se siembran en una transaccion que se deshace; la tabla md_* de
  prueba se crea y se borra aparte. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, DUnitX.TestFramework, UAlcance,
  UAlmacenFicheros, UPruebasAlcanceDatos, UPruebasMigracion, UCargaModelo,
  UMetadatosSubserie, UCargaDocumento, UCargaLote;

type
  [TestFixture]
  TPruebasCargaDocumento = class
  private
    FConn: TFDConnection;
    FEsc: TEscenario;
    FAlm: TAlmacenMemoria;
    FAlmI: IAlmacenFicheros;
    FCarpeta: string;
    FOrigen: TOrigenDocumento;
    FCampos: TArray<TCampoMeta>;
    FEsSql: Boolean;
    procedure Conectar(EsSql: Boolean);
    function Archivo(const Nombre: string; Bytes: Integer; const Sub: string = ''): string;
    function Candidato(const Codigo: string): TCandidato;
    function Guardar(const Cand: TCandidato; const Usuario: string = 'administrador'): TResultadoDocumento;
    function Cuenta(const Sql: string): Integer;
    function NuevoLote(Cantidad: Integer; const Base: string): TArray<TCandidato>;
    function CrearLote: TCargaLote;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure SqlServer_GuardaDocumentoCompleto;
    [Test]
    procedure SqlServer_SinPermiso_NoToca;
    [Test]
    procedure SqlServer_TopografiaIncompleta_NoToca;
    [Test]
    procedure SqlServer_FallaElSegundoArchivo_Compensa;
    [Test]
    procedure SqlServer_FallaElBorradoDeCompensacion_Lo_Dice;
    [Test]
    procedure SqlServer_CodigoExistente_UsaElSiguiente;
    [Test]
    procedure SqlServer_NombresRepetidos_NoSePisan;
    [Test]
    procedure SqlServer_CeroBytesYNombreRaro_Idem;
    [Test]
    procedure SqlServer_ObligatorioVacio_NoSubeNada;
    [Test]
    procedure Access_GuardaDocumentoBasico;
    [Test]
    procedure SqlServer_Lote_UnoFalla_LosDemasSeGuardan;
    [Test]
    procedure SqlServer_Lote_ReintentarSoloElFallido;
    [Test]
    procedure SqlServer_Lote_CancelarDejaPendientes;
    [Test]
    procedure SqlServer_Lote_CandidatoConFaltas_SeOmite;
    [Test]
    procedure SqlServer_UltimosValores_ReemplazanYSonPorUsuario;
    [Test]
    procedure Access_Lote_GuardaDos;
    [Test]
    procedure CandidatosDeLote_Estados;
    [Test]
    procedure SqlServer_Lote_Retomar_TerminaElMismoLote;
    [Test]
    procedure SqlServer_Lote_Descartar_YaNoEsPendiente;
  end;

implementation

uses
  System.Classes, System.IOUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param,
  Data.DB, UAlcanceDatos, UEsquemaAlcance, UEsquemaCarga, UEsquemaTrazabilidad;

const
  TABLA = 'md_f3_doc';
  EST = 'A.4.3';
  NODO = 104;

procedure TPruebasCargaDocumento.Preparar;
begin
  FConn := nil;
  FEsc := nil;
  FAlm := TAlmacenMemoria.Create;
  FAlmI := FAlm;
  FCarpeta := TPath.Combine(TPath.GetTempPath, 'f3-' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(FCarpeta);
  FOrigen := Default(TOrigenDocumento);
  FOrigen.IdEstructura := EST;
  FOrigen.Id := NODO;
  FOrigen.CodSubs := '014001';
  FOrigen.CodSerie := '014';
  FOrigen.Usuario := 'prueba';
  FOrigen.Rol := 'Administrador';
  FOrigen.UrlRaiz := 's3://77/';
  SetLength(FCampos, 2);
  FCampos[0].Nombre := 'Texto';
  FCampos[0].Etiqueta := 'Texto corto';
  FCampos[0].Tipo := tmTexto;
  FCampos[0].Longitud := 10;
  FCampos[1].Nombre := 'Cantidad';
  FCampos[1].Etiqueta := 'Cantidad total';
  FCampos[1].Tipo := tmEntero;
  FCampos[1].Obligatorio := True;
end;

procedure TPruebasCargaDocumento.Limpiar;
begin
  if FConn <> nil then
  begin
    try
      if FConn.InTransaction then
        FConn.Rollback;
      FConn.ExecSQL('DROP TABLE ' + TABLA);
    except
      // la tabla de prueba puede no existir
    end;
    try
      // el documento reservado y sus filas dependientes quedan fuera de la transaccion
      FConn.ExecSQL('DELETE FROM tb_ssArchdigital WHERE Codigodoc LIKE ''F3T-%''');
      FConn.ExecSQL('DELETE FROM tb_SeriesDatos WHERE Codigodoc LIKE ''F3T-%''');
      FConn.ExecSQL('DELETE FROM tb_log WHERE msg LIKE ''%F3T-%''');
      FConn.ExecSQL('DELETE FROM tb_lote_captura_item WHERE idlote IN (SELECT idlote FROM tb_lote_captura WHERE user_id = ''prueba'')');
      FConn.ExecSQL('DELETE FROM tb_lote_captura WHERE user_id = ''prueba''');
      FConn.ExecSQL('DELETE FROM tb_carga_valores WHERE user_id LIKE ''f3_usuario_%''');
    except
    end;
    FreeAndNil(FEsc);
    FreeAndNil(FConn);
  end;
  FAlmI := nil;
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
end;

procedure TPruebasCargaDocumento.Conectar(EsSql: Boolean);
var
  Tipos: string;
begin
  FEsSql := EsSql;
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
  CrearEsquemaAlcance(FConn, EsSql);
  CrearEsquemaCarga(FConn, EsSql);
  CrearEsquemaTrazabilidad(FConn, EsSql);
  try
    FConn.ExecSQL('DROP TABLE ' + TABLA);
  except
  end;
  FConn.ExecSQL('CREATE TABLE ' + TABLA + ' (IdEstructura VARCHAR(50), id INT, codsubs VARCHAR(50), ' +
    'Fecha DATETIME, Version VARCHAR(12), Codigodoc VARCHAR(20), Texto VARCHAR(10), Cantidad INT)');
  FEsc := TEscenario.Create(FConn);
  FConn.StartTransaction;
  FEsc.Sembrar;
  if not EsSql then
  begin
    if Integer(FConn.ExecSQLScalar('SELECT COUNT(*) FROM tb_Serietree WHERE ' +
      'IdEstructura = ''A.4.3'' AND id = 104 AND codsubs = ''014001''')) = 0 then
      FConn.ExecSQL('INSERT INTO tb_Serietree (IdEstructura, id, codsubs) ' +
        'VALUES (''A.4.3'', 104, ''014001'')');
  end;
  // Topografia completa y servidor del nodo
  FConn.ExecSQL('UPDATE tb_Serietree SET deposito = ''C'', gaveta = ''C'', Archivo = 2, ' +
    'Idservidor = 1 WHERE IdEstructura = ''A.4.3'' AND id = 104 AND codsubs = ''014001''');
end;

function TPruebasCargaDocumento.Archivo(const Nombre: string; Bytes: Integer;
  const Sub: string): string;
var
  Dir: string;
  B: TBytes;
  I: Integer;
begin
  Dir := FCarpeta;
  if Sub <> '' then
    Dir := TPath.Combine(FCarpeta, Sub);
  TDirectory.CreateDirectory(Dir);
  Result := TPath.Combine(Dir, Nombre);
  SetLength(B, Bytes);
  for I := 0 to Bytes - 1 do
    B[I] := Byte((Length(Nombre) * 3 + I) mod 251);
  TFile.WriteAllBytes(Result, B);
end;

function TPruebasCargaDocumento.Candidato(const Codigo: string): TCandidato;
begin
  Result := Default(TCandidato);
  Result.Titulo := 'Documento de prueba';
  Result.Codigo := Codigo;
  Result.Fecha := EncodeDate(2026, 2, 3);
  SetLength(Result.Meta, 2);
  Result.Meta[0].Nombre := 'Texto';
  Result.Meta[0].Valor := 'O''Brien';
  Result.Meta[1].Nombre := 'Cantidad';
  Result.Meta[1].Valor := '42';
end;

function TPruebasCargaDocumento.Cuenta(const Sql: string): Integer;
begin
  Result := Integer(FConn.ExecSQLScalar(Sql));
end;

function TPruebasCargaDocumento.Guardar(const Cand: TCandidato; const Usuario: string): TResultadoDocumento;
var
  Al: TAlcanceUsuario;
begin
  Al := nil;
  if FEsSql then
    Al := CargarAlcance(FConn, Usuario, SameText(Usuario, 'administrador'));
  try
    Result := GuardarDocumento(FConn, Al, FOrigen, FAlmI, Cand, FCampos, TABLA, nil);
  finally
    Al.Free;
  end;
end;

procedure TPruebasCargaDocumento.SqlServer_GuardaDocumentoCompleto;
var
  C: TCandidato;
  R: TResultadoDocumento;
  Q: TFDQuery;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  C := Candidato('F3T-001');
  C.Archivo := Archivo('informe.pdf', 100);
  C.Fuentes := [Archivo('datos.xlsx', 50), Archivo('modelo.dwg', 70)];
  R := Guardar(C);
  Assert.IsTrue(R.Guardado, R.Mensaje);
  Assert.AreEqual('F3T-001', R.Codigodoc);
  Assert.AreEqual(3, R.Subidos);
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc = ''F3T-001'''));
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := FConn;
    Q.Open('SELECT nombre, fuente, urlraiz, path, tamano FROM tb_ssArchdigital ' +
      'WHERE Codigodoc = ''F3T-001'' ORDER BY idhijo');
    Assert.AreEqual(3, Q.RecordCount);
    Assert.AreEqual('informe.pdf', Q.FieldByName('nombre').AsString);
    Assert.AreEqual('N', Q.FieldByName('fuente').AsString);
    Assert.AreEqual('s3://77/', Q.FieldByName('urlraiz').AsString);
    Assert.AreEqual('\A.4.3\014\014001\F3T-001\Anexos Digitales\', Q.FieldByName('path').AsString);
    Assert.AreEqual(Double(100), Q.FieldByName('tamano').AsFloat);
    Q.Next;
    Assert.AreEqual('S', Q.FieldByName('fuente').AsString);
    Assert.AreEqual('\A.4.3\014\014001\F3T-001\Fuentes\', Q.FieldByName('path').AsString);
  finally
    Q.Free;
  end;
  Assert.IsTrue(FAlm.Objetos.ContainsKey('A.4.3/014/014001/F3T-001/Anexos Digitales/informe.pdf'));
  Assert.IsTrue(FAlm.Objetos.ContainsKey('A.4.3/014/014001/F3T-001/Fuentes/modelo.dwg'));
  Assert.AreEqual(100, Length(FAlm.Objetos['A.4.3/014/014001/F3T-001/Anexos Digitales/informe.pdf']));
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM ' + TABLA + ' WHERE Codigodoc = ''F3T-001'' AND Cantidad = 42'));
  Assert.AreEqual('O''Brien', VarToStr(FConn.ExecSQLScalar('SELECT Texto FROM ' + TABLA + ' WHERE Codigodoc = ''F3T-001''')));
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_log WHERE accion = 5 AND msg LIKE ''%F3T-001%'' AND codigodoc = ''F3T-001'''));
  Assert.AreEqual('F3T-001', VarToStr(FConn.ExecSQLScalar('SELECT namefile FROM tb_SeriesDatos WHERE Codigodoc = ''F3T-001''')));
end;

procedure TPruebasCargaDocumento.SqlServer_SinPermiso_NoToca;
var
  C: TCandidato;
  R: TResultadoDocumento;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  C := Candidato('F3T-002');
  C.Archivo := Archivo('a.pdf', 10);
  R := Guardar(C, 'prueba_alc_visor');
  Assert.IsFalse(R.Guardado);
  Assert.IsTrue(R.Mensaje.Contains('permiso'), R.Mensaje);
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc = ''F3T-002'''));
  Assert.AreEqual(0, FAlm.Objetos.Count);
  Assert.AreEqual(0, FAlm.Subidas);
end;

procedure TPruebasCargaDocumento.SqlServer_TopografiaIncompleta_NoToca;
var
  C: TCandidato;
  R: TResultadoDocumento;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  FConn.ExecSQL('UPDATE tb_Serietree SET deposito = '''' WHERE IdEstructura = ''A.4.3'' AND ' +
    'id = 104 AND codsubs = ''014001''');
  C := Candidato('F3T-003');
  C.Archivo := Archivo('a.pdf', 10);
  R := Guardar(C);
  Assert.IsFalse(R.Guardado);
  Assert.IsTrue(R.Mensaje.Contains('topogr'), R.Mensaje);
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc = ''F3T-003'''));
  Assert.AreEqual(0, FAlm.Subidas);
end;

procedure TPruebasCargaDocumento.SqlServer_FallaElSegundoArchivo_Compensa;
var
  C: TCandidato;
  R: TResultadoDocumento;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  C := Candidato('F3T-004');
  C.Archivo := Archivo('uno.pdf', 10);
  C.Fuentes := [Archivo('dos.pdf', 20)];
  FAlm.FallarSubidaEn := 'A.4.3/014/014001/F3T-004/Fuentes/dos.pdf';
  R := Guardar(C);
  Assert.IsFalse(R.Guardado);
  Assert.AreEqual(0, R.Subidos);
  Assert.AreEqual(0, FAlm.Objetos.Count, 'el primer archivo debe borrarse');
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc = ''F3T-004'''), 'no queda el documento reservado');
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''F3T-004'''));
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM ' + TABLA + ' WHERE Codigodoc = ''F3T-004'''));
end;

procedure TPruebasCargaDocumento.SqlServer_FallaElBorradoDeCompensacion_Lo_Dice;
var
  C: TCandidato;
  R: TResultadoDocumento;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  C := Candidato('F3T-005');
  C.Archivo := Archivo('uno.pdf', 10);
  C.Fuentes := [Archivo('dos.pdf', 20)];
  FAlm.FallarSubidaEn := 'A.4.3/014/014001/F3T-005/Fuentes/dos.pdf';
  FAlm.FallarBorrado := True;
  R := Guardar(C);
  Assert.IsFalse(R.Guardado);
  Assert.IsTrue(R.Mensaje.Contains('sin borrar'), R.Mensaje);
end;

procedure TPruebasCargaDocumento.SqlServer_CodigoExistente_UsaElSiguiente;
var
  C: TCandidato;
  R1, R2: TResultadoDocumento;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  C := Candidato('F3T-009');
  C.Archivo := Archivo('a.pdf', 10);
  R1 := Guardar(C);
  R2 := Guardar(C);
  Assert.IsTrue(R1.Guardado and R2.Guardado, R1.Mensaje + ' / ' + R2.Mensaje);
  Assert.AreEqual('F3T-009', R1.Codigodoc);
  Assert.AreEqual('F3T-010', R2.Codigodoc);
  Assert.AreEqual(2, Cuenta('SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc LIKE ''F3T-0%'''));
  Assert.IsTrue(FAlm.Objetos.ContainsKey('A.4.3/014/014001/F3T-010/Anexos Digitales/a.pdf'), 'la ruta usa el codigo final');
end;

procedure TPruebasCargaDocumento.SqlServer_NombresRepetidos_NoSePisan;
var
  C: TCandidato;
  R: TResultadoDocumento;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  C := Candidato('F3T-006');
  C.Archivo := Archivo('x.pdf', 10, 'a');
  C.Fuentes := [Archivo('f.dwg', 11, 'a'), Archivo('f.dwg', 12, 'b'), Archivo('F.DWG', 13, 'c')];
  R := Guardar(C);
  Assert.IsTrue(R.Guardado, R.Mensaje);
  Assert.AreEqual(4, R.Subidos);
  Assert.IsTrue(FAlm.Objetos.ContainsKey('A.4.3/014/014001/F3T-006/Fuentes/f.dwg'));
  Assert.IsTrue(FAlm.Objetos.ContainsKey('A.4.3/014/014001/F3T-006/Fuentes/f (2).dwg'));
  Assert.IsTrue(FAlm.Objetos.ContainsKey('A.4.3/014/014001/F3T-006/Fuentes/F (3).DWG'));
  Assert.AreEqual(11, Length(FAlm.Objetos['A.4.3/014/014001/F3T-006/Fuentes/f.dwg']));
  Assert.AreEqual(12, Length(FAlm.Objetos['A.4.3/014/014001/F3T-006/Fuentes/f (2).dwg']));
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''F3T-006'' AND nombre = ''f (2).dwg'''));
end;

procedure TPruebasCargaDocumento.SqlServer_CeroBytesYNombreRaro_Idem;
var
  C: TCandidato;
  R: TResultadoDocumento;
  N: string;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  N := 'plano ' + Char($F1) + Char($E1) + ' #1+2.pdf';
  C := Candidato('F3T-007');
  C.Archivo := Archivo(N, 0);
  R := Guardar(C);
  Assert.IsTrue(R.Guardado, R.Mensaje);
  Assert.IsTrue(FAlm.Objetos.ContainsKey('A.4.3/014/014001/F3T-007/Anexos Digitales/' + N));
  Assert.AreEqual(0, Length(FAlm.Objetos['A.4.3/014/014001/F3T-007/Anexos Digitales/' + N]));
end;

procedure TPruebasCargaDocumento.SqlServer_ObligatorioVacio_NoSubeNada;
var
  C: TCandidato;
  R: TResultadoDocumento;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  C := Candidato('F3T-008');
  C.Meta[1].Valor := '';
  C.Archivo := Archivo('a.pdf', 10);
  R := Guardar(C);
  Assert.IsFalse(R.Guardado);
  Assert.IsTrue(R.Mensaje.Contains('Cantidad total'), R.Mensaje);
  Assert.AreEqual(0, FAlm.Subidas);
  Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc = ''F3T-008'''));
end;

procedure TPruebasCargaDocumento.Access_GuardaDocumentoBasico;
var
  C: TCandidato;
  R: TResultadoDocumento;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  C := Candidato('F3T-011');
  C.Archivo := Archivo('a.pdf', 10);
  R := Guardar(C);
  Assert.IsTrue(R.Guardado, R.Mensaje);
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc = ''F3T-011'''));
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''F3T-011'''));
  Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM ' + TABLA + ' WHERE Codigodoc = ''F3T-011'''));
end;

function TPruebasCargaDocumento.NuevoLote(Cantidad: Integer; const Base: string): TArray<TCandidato>;
var
  I: Integer;
begin
  SetLength(Result, Cantidad);
  for I := 0 to Cantidad - 1 do
  begin
    Result[I] := Candidato(Format('%s%.2d', [Base, I + 1]));
    Result[I].Archivo := Archivo(Chr(Ord('a') + I) + '.pdf', 10 + I, 'lote' + IntToStr(I));
    Result[I].Estado := ecListo;
  end;
end;

function TPruebasCargaDocumento.CrearLote: TCargaLote;
var
  Al: TAlcanceUsuario;
begin
  Al := nil;
  if FEsSql then
    Al := CargarAlcance(FConn, 'administrador', True);
  // el alcance vive lo que dure la prueba (el lote no lo libera)
  Result := TCargaLote.Create(FConn, Al, FOrigen, FAlmI, FCampos, TABLA);
end;

procedure TPruebasCargaDocumento.SqlServer_Lote_UnoFalla_LosDemasSeGuardan;
var
  L: TArray<TCandidato>;
  Lote: TCargaLote;
  R: TResumenLote;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  L := NuevoLote(4, 'F3T-1');
  FAlm.FallarSubidaEn := 'A.4.3/014/014001/F3T-103/Anexos Digitales/c.pdf';
  Lote := CrearLote;
  try
    R := Lote.Guardar(L, nil, nil);
    Assert.AreEqual(3, R.Guardados);
    Assert.AreEqual(1, R.Fallidos);
    Assert.AreEqual(0, R.Omitidos);
    Assert.IsTrue(L[2].Estado = ecError);
    Assert.AreNotEqual('', L[2].Error);
    Assert.IsTrue(L[0].Estado = ecGuardado);
    Assert.AreEqual(3, Cuenta('SELECT COUNT(*) FROM tb_lote_captura_item WHERE idlote = ' +
      IntToStr(Lote.IdLote) + ' AND estado = ''guardado'''));
    Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_lote_captura_item WHERE idlote = ' +
      IntToStr(Lote.IdLote) + ' AND estado = ''error'''));
    Assert.AreEqual('abierto', VarToStr(FConn.ExecSQLScalar('SELECT estado FROM tb_lote_captura WHERE idlote = ' +
      IntToStr(Lote.IdLote))));
  finally
    Lote.Free;
  end;
end;

procedure TPruebasCargaDocumento.SqlServer_Lote_ReintentarSoloElFallido;
var
  L: TArray<TCandidato>;
  Lote: TCargaLote;
  R: TResumenLote;
  Antes: Integer;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  L := NuevoLote(4, 'F3T-2');
  FAlm.FallarSubidaEn := 'A.4.3/014/014001/F3T-203/Anexos Digitales/c.pdf';
  Lote := CrearLote;
  try
    Lote.Guardar(L, nil, nil);
    FAlm.FallarSubidaEn := '';
    Antes := FAlm.Subidas;
    R := Lote.Guardar(L, nil, nil);
    Assert.AreEqual(1, R.Guardados);
    Assert.AreEqual(0, R.Fallidos);
    Assert.AreEqual(Antes + 1, FAlm.Subidas, 'solo se vuelve a subir el fallido');
    Assert.IsTrue(L[2].Estado = ecGuardado);
    Assert.AreEqual(4, FAlm.Objetos.Count);
    Assert.AreEqual('cerrado', VarToStr(FConn.ExecSQLScalar('SELECT estado FROM tb_lote_captura WHERE idlote = ' +
      IntToStr(Lote.IdLote))));
    Assert.AreEqual(4, Cuenta('SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc LIKE ''F3T-2%'''));
  finally
    Lote.Free;
  end;
end;

procedure TPruebasCargaDocumento.SqlServer_Lote_CancelarDejaPendientes;
var
  L: TArray<TCandidato>;
  Lote: TCargaLote;
  R: TResumenLote;
  Llamadas: Integer;
  P: TArray<TLotePendiente>;
  Items: TArray<TItemLote>;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  L := NuevoLote(4, 'F3T-3');
  Llamadas := 0;
  Lote := CrearLote;
  try
    R := Lote.Guardar(L, nil,
      function: Boolean
      begin
        Inc(Llamadas);
        Result := Llamadas > 2;
      end);
    Assert.AreEqual(2, R.Guardados);
    Assert.AreEqual(2, R.Omitidos);
    P := LotesPendientes(FConn, FOrigen.Usuario);
    Assert.IsTrue(Length(P) >= 1);
    Assert.AreEqual(2, P[High(P)].Pendientes);
    Assert.AreEqual(Lote.IdLote, P[High(P)].IdLote);
    Items := CargarItems(FConn, Lote.IdLote);
    Assert.AreEqual(4, Length(Items));
    Assert.AreEqual('guardado', Items[0].Estado);
    Assert.AreEqual('espera', Items[3].Estado);
  finally
    Lote.Free;
  end;
end;

procedure TPruebasCargaDocumento.SqlServer_Lote_CandidatoConFaltas_SeOmite;
var
  L: TArray<TCandidato>;
  Lote: TCargaLote;
  R: TResumenLote;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  L := NuevoLote(2, 'F3T-4');
  L[1].Estado := ecFalta;
  Lote := CrearLote;
  try
    R := Lote.Guardar(L, nil, nil);
    Assert.AreEqual(1, R.Guardados);
    Assert.AreEqual(1, R.Omitidos);
    Assert.AreEqual(1, FAlm.Subidas);
  finally
    Lote.Free;
  end;
end;

procedure TPruebasCargaDocumento.SqlServer_UltimosValores_ReemplazanYSonPorUsuario;
var
  V: TArray<TValorMeta>;
  R: TArray<TValorMeta>;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  SetLength(V, 2);
  V[0].Nombre := 'Texto';    V[0].Valor := 'uno';
  V[1].Nombre := 'Cantidad'; V[1].Valor := '5';
  GuardarUltimosValores(FConn, 'f3_usuario_a', '014001', V);
  SetLength(V, 1);
  V[0].Nombre := 'Texto';    V[0].Valor := 'dos';
  GuardarUltimosValores(FConn, 'f3_usuario_a', '014001', V);
  R := LeerUltimosValores(FConn, 'f3_usuario_a', '014001');
  Assert.AreEqual(1, Length(R), 'reemplaza, no acumula');
  Assert.AreEqual('dos', R[0].Valor);
  Assert.AreEqual(0, Length(LeerUltimosValores(FConn, 'f3_usuario_b', '014001')));
  Assert.AreEqual(0, Length(LeerUltimosValores(FConn, 'f3_usuario_a', '074')));
end;

procedure TPruebasCargaDocumento.Access_Lote_GuardaDos;
var
  L: TArray<TCandidato>;
  Lote: TCargaLote;
  R: TResumenLote;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  L := NuevoLote(2, 'F3T-5');
  Lote := CrearLote;
  try
    R := Lote.Guardar(L, nil, nil);
    Assert.AreEqual(2, R.Guardados);
    Assert.IsTrue(Lote.IdLote > 0);
    Assert.AreEqual(2, Cuenta('SELECT COUNT(*) FROM tb_lote_captura_item WHERE idlote = ' + IntToStr(Lote.IdLote)));
  finally
    Lote.Free;
  end;
end;

procedure TPruebasCargaDocumento.CandidatosDeLote_Estados;
var
  Items: TArray<TItemLote>;
  C: TArray<TCandidato>;
  Existe: string;
begin
  Existe := Archivo('existe.pdf', 5, 'cdl');
  SetLength(Items, 3);
  Items[0].Orden := 1;
  Items[0].Archivo := Existe;
  Items[0].Estado := 'guardado';
  Items[0].Codigodoc := 'X-001';
  Items[1].Orden := 2;
  Items[1].Archivo := Existe;
  Items[1].Estado := 'error';
  Items[1].Codigodoc := 'X-002';
  Items[2].Orden := 3;
  Items[2].Archivo := Existe + '.no-existe';
  Items[2].Estado := 'espera';
  C := CandidatosDeLote(Items);
  Assert.AreEqual(3, Length(C));
  Assert.IsTrue(C[0].Estado = ecGuardado);
  Assert.IsTrue(C[1].Estado = ecListo);
  Assert.AreEqual('X-002', C[1].Codigo);
  Assert.IsTrue(C[2].Estado = ecError, 'falta el archivo');
  Assert.IsTrue(C[2].Error <> '');
  Assert.AreEqual(0, Length(CandidatosDeLote(nil)));
end;

procedure TPruebasCargaDocumento.SqlServer_Lote_Retomar_TerminaElMismoLote;
var
  L, L2: TArray<TCandidato>;
  Lote, Otro: TCargaLote;
  R: TResumenLote;
  Llamadas, Lotes: Integer;
  Id, J: Integer;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  L := NuevoLote(4, 'F3T-6');
  Llamadas := 0;
  Lote := CrearLote;
  try
    Lote.Guardar(L, nil,
      function: Boolean
      begin
        Inc(Llamadas);
        Result := Llamadas > 2;
      end);
    Id := Lote.IdLote;
  finally
    Lote.Free;
  end;
  Lotes := Cuenta('SELECT COUNT(*) FROM tb_lote_captura');
  L2 := CandidatosDeLote(CargarItems(FConn, Id));
  Assert.AreEqual(4, Length(L2));
  // los codigos de los que no se guardaron no se conocen en el lote: la pantalla los pide de nuevo
  // los datos propios tampoco se conservan: hay que completarlos de nuevo
  Assert.AreEqual(0, Length(L2[2].Meta));
  for J := 0 to 3 do
  begin
    if L2[J].Codigo = '' then
      L2[J].Codigo := L[J].Codigo;
    L2[J].Meta := L[J].Meta;
  end;
  Otro := CrearLote;
  try
    Otro.Retomar(Id, Length(L2));
    R := Otro.Guardar(L2, nil, nil);
    Assert.AreEqual(2, R.Guardados);
    Assert.AreEqual(Id, Otro.IdLote);
    Assert.AreEqual(Lotes, Cuenta('SELECT COUNT(*) FROM tb_lote_captura'), 'no crea otro lote');
    Assert.AreEqual('cerrado', VarToStr(FConn.ExecSQLScalar(
      'SELECT estado FROM tb_lote_captura WHERE idlote = ' + IntToStr(Id))));
    Assert.AreEqual(4, Cuenta('SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc LIKE ''F3T-6%'''));
  finally
    Otro.Free;
  end;
end;

procedure TPruebasCargaDocumento.SqlServer_Lote_Descartar_YaNoEsPendiente;
var
  L: TArray<TCandidato>;
  Lote: TCargaLote;
  Id, Antes, Despues: Integer;
begin
  if GetEnvironmentVariable('ARCHIGENIO_TEST_DB') = '' then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
  Conectar(True);
  L := NuevoLote(2, 'F3T-7');
  Lote := CrearLote;
  try
    Lote.Guardar(L, nil,
      function: Boolean
      begin
        Result := True;
      end);
    Id := Lote.IdLote;
  finally
    Lote.Free;
  end;
  Antes := Length(LotesPendientes(FConn, FOrigen.Usuario));
  DescartarLote(FConn, Id);
  Despues := Length(LotesPendientes(FConn, FOrigen.Usuario));
  Assert.AreEqual(Antes - 1, Despues);
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasCargaDocumento);

end.
