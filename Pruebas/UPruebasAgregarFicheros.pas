unit UPruebasAgregarFicheros;

{ Agregar ficheros a un documento existente, con un almacen en memoria. SQL
  Server: ARCHIGENIO_TEST_DB. Access: ARCHIGENIO_TEST_MDB (COPIA). Cada prueba
  corre en los motores que tengan su variable; sin ninguna se omite. Las filas
  sembradas llevan codigo F6T-* y se borran al final. Codigo en ASCII. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, DUnitX.TestFramework, UAlcance,
  UAlmacenFicheros, UPruebasMigracion, UCargaDocumento, UDocumentoVista,
  UAgregarFicheros;

type
  TCuerpoPrueba = reference to procedure(EsSql: Boolean);

  [TestFixture]
  TPruebasAgregarFicheros = class
  private
    FConn: TFDConnection;
    FAlm: TAlmacenMemoria;
    FAlmI: IAlmacenFicheros;
    FCarpeta: string;
    FOrigen: TOrigenDocumento;
    FClave: TClaveDocumento;
    procedure Conectar(EsSql: Boolean);
    procedure Desconectar;
    function Archivo(const Nombre: string; Bytes: Integer): string;
    function Nuevo(const Local: string; EsFuente: Boolean): TFicheroNuevo;
    function Cuenta(const Sql: string): Integer;
    procedure EnCadaMotor(const Cuerpo: TCuerpoPrueba);
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure Agrega_Anexo_SubeInsertaYRegistra;
    [Test]
    procedure Agrega_Fuente_VaALaCarpetaFuentesConFuenteS;
    [Test]
    procedure NombresRepetidos_QuedanUnicos;
    [Test]
    procedure FallaLaSubida_NoDejaFilaNiObjeto;
    [Test]
    procedure FallaLaFila_BorraElObjetoSubido;
    [Test]
    procedure SinPermiso_NoHaceNada;
    [Test]
    procedure ArchivoInexistente_CuentaComoFallido;
    [Test]
    procedure DocumentoConFicheros_UsaSuCarpetaYRaiz;
    [Test]
    procedure RaicesMezcladas_CadaFicheroVaAlAlmacenDeSuRaiz;
    [Test]
    procedure Cancelar_DejaOmitidosLosQueFaltan;
    [Test]
    procedure Reemplaza_ConservaLaPosicionDelPdfPrincipal;
    [Test]
    procedure Reemplaza_SubeElNuevoYBorraElAnterior;
    [Test]
    procedure Reemplaza_FallaLaSubida_ElAnteriorSigueIntacto;
    [Test]
    procedure Reemplaza_NoEsPdf_NoHaceNada;
    [Test]
    procedure Reemplaza_SinPdfAnterior_AgregaComoAnexo;
    [Test]
    procedure Reemplaza_FallaElBorradoDelAnterior_ConservaElNuevoYLoDice;
  end;

implementation

uses
  System.Classes, System.IOUtils, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSAcc, FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param,
  Data.DB, UEsquemaTrazabilidad, UTrazabilidad;

const
  COD = 'F6T-001';

procedure TPruebasAgregarFicheros.Preparar;
begin
  FConn := nil;
  FAlm := TAlmacenMemoria.Create;
  FAlmI := FAlm;
  FCarpeta := TPath.Combine(TPath.GetTempPath, 'f6-' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(FCarpeta);
  FOrigen := Default(TOrigenDocumento);
  FOrigen.IdEstructura := 'A.4.3';
  FOrigen.Id := 104;
  FOrigen.CodSubs := '074';
  FOrigen.CodSerie := '07';
  FOrigen.Usuario := 'prueba';
  FOrigen.Rol := 'Administrador';
  FOrigen.UrlRaiz := 's3://77/';
  FClave.IdEstructura := 'A.4.3';
  FClave.Id := 104;
  FClave.CodSubs := '074';
  FClave.Fecha := EncodeDate(2026, 1, 31);
  FClave.Version := '1';
  FClave.Codigodoc := COD;
end;

procedure TPruebasAgregarFicheros.Limpiar;
begin
  Desconectar;
  FAlmI := nil;
  if TDirectory.Exists(FCarpeta) then
    TDirectory.Delete(FCarpeta, True);
end;

procedure TPruebasAgregarFicheros.Desconectar;
begin
  if FConn <> nil then
  begin
    try
      FConn.ExecSQL('DELETE FROM tb_ssArchdigital WHERE Codigodoc LIKE ''F6T-%''');
      FConn.ExecSQL('DELETE FROM tb_SeriesDatos WHERE Codigodoc LIKE ''F6T-%''');
      FConn.ExecSQL('DELETE FROM tb_log WHERE msg LIKE ''%F6T-%''');
    except
    end;
    FreeAndNil(FConn);
  end;
end;

procedure TPruebasAgregarFicheros.Conectar(EsSql: Boolean);
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
  FConn.ExecSQL('DELETE FROM tb_ssArchdigital WHERE Codigodoc LIKE ''F6T-%''');
  FConn.ExecSQL('DELETE FROM tb_SeriesDatos WHERE Codigodoc LIKE ''F6T-%''');
  FConn.ExecSQL('INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Codigodoc, ' +
    'fecha, version, titulodoc) VALUES (:e, :i, :c, :d, :f, :v, ''t'')',
    [FClave.IdEstructura, FClave.Id, FClave.CodSubs, FClave.Codigodoc,
    FClave.Fecha, FClave.Version]);
end;

function TPruebasAgregarFicheros.Archivo(const Nombre: string; Bytes: Integer): string;
var
  B: TBytes;
  I: Integer;
begin
  Result := TPath.Combine(FCarpeta, Nombre);
  SetLength(B, Bytes);
  for I := 0 to Bytes - 1 do
    B[I] := Byte((Length(Nombre) + I) mod 251);
  TFile.WriteAllBytes(Result, B);
end;

function TPruebasAgregarFicheros.Nuevo(const Local: string; EsFuente: Boolean): TFicheroNuevo;
begin
  Result.Local := Local;
  Result.EsFuente := EsFuente;
end;

function TPruebasAgregarFicheros.Cuenta(const Sql: string): Integer;
begin
  Result := FConn.ExecSQLScalar(Sql);
end;

procedure TPruebasAgregarFicheros.EnCadaMotor(const Cuerpo: TCuerpoPrueba);
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
    FAlm.Objetos.Clear;
    FAlm.Subidas := 0;
    FAlm.Borrados := 0;
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

procedure TPruebasAgregarFicheros.Agrega_Anexo_SubeInsertaYRegistra;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('plano.pdf', 500), False)], nil);
      Assert.AreEqual(1, R.Agregados);
      Assert.AreEqual(0, R.Fallidos);
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND fuente = ''N'' AND nombre = ''plano.pdf'''));
      Assert.AreEqual(1, FAlm.Objetos.Count);
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_log WHERE msg LIKE ''%anexo digital%' +
        COD + '%'''));
    end);
end;

procedure TPruebasAgregarFicheros.Agrega_Fuente_VaALaCarpetaFuentesConFuenteS;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('memoria.docx', 300), True)], nil);
      Assert.AreEqual(1, R.Agregados);
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND fuente = ''S'' AND path LIKE ''%Fuentes%'''));
    end);
end;

procedure TPruebasAgregarFicheros.NombresRepetidos_QuedanUnicos;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
      Otro: string;
    begin
      Archivo('a.pdf', 10);
      TDirectory.CreateDirectory(TPath.Combine(FCarpeta, 'otra'));
      Otro := TPath.Combine(FCarpeta, 'otra\a.pdf');
      TFile.WriteAllBytes(Otro, [1, 2, 3]);
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(TPath.Combine(FCarpeta, 'a.pdf'), False), Nuevo(Otro, False)], nil);
      Assert.AreEqual(2, R.Agregados);
      Assert.AreEqual(2, FAlm.Objetos.Count, 'no se pisan en el almacen');
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND nombre = ''a (2).pdf'''));
      // un segundo soltado con el mismo nombre tambien se renombra
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(TPath.Combine(FCarpeta, 'a.pdf'), False)], nil);
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND nombre = ''a (3).pdf'''));
    end);
end;

procedure TPruebasAgregarFicheros.FallaLaSubida_NoDejaFilaNiObjeto;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      // el segundo archivo falla al subir: el primero queda, el segundo no deja nada
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('uno.pdf', 10), False)], nil);
      Assert.AreEqual(1, R.Agregados);
      FAlm.FallarSubidaEn := 'A.4.3/07/074/F6T-001/Anexos Digitales/dos.pdf';
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('dos.pdf', 10), False)], nil);
      Assert.AreEqual(0, R.Agregados);
      Assert.AreEqual(1, R.Fallidos);
      Assert.IsTrue(R.Mensaje <> '');
      Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND nombre = ''dos.pdf'''));
      Assert.AreEqual(1, FAlm.Objetos.Count, 'solo queda el primero');
    end);
end;

procedure TPruebasAgregarFicheros.FallaLaFila_BorraElObjetoSubido;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      // SQL Server tiene la clave foranea FK_archivoSDATOS: un documento que no
      // existe hace fallar la fila despues de subir el objeto (Access no la tiene)
      if not EsSql then
        Exit;
      FClave.Codigodoc := 'F6T-NOEXISTE';
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('tres.pdf', 10), False)], nil);
      Assert.AreEqual(1, R.Fallidos);
      Assert.AreEqual(0, FAlm.Objetos.Count, 'el objeto subido se borra al fallar la fila');
    end);
end;

procedure TPruebasAgregarFicheros.SinPermiso_NoHaceNada;
var
  Al: TAlcanceUsuario;
begin
  if (GetEnvironmentVariable('ARCHIGENIO_TEST_MDB') = '') then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_MDB');
  Conectar(False);
  Al := TAlcanceUsuario.Create(False, nil, nil, nil, nil);
  try
    var R := AgregarFicheros(FConn, Al, FOrigen, FClave, FabricaUnica(FAlmI),
      [Nuevo(Archivo('x.pdf', 10), False)], nil);
    Assert.AreEqual(0, R.Agregados);
    Assert.IsTrue(Pos('permiso', R.Mensaje) > 0);
    Assert.AreEqual(0, FAlm.Subidas, 'sin permiso no se sube nada');
  finally
    Al.Free;
  end;
end;

procedure TPruebasAgregarFicheros.ArchivoInexistente_CuentaComoFallido;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(TPath.Combine(FCarpeta, 'no_existe.pdf'), False),
        Nuevo(Archivo('bien.pdf', 10), False)], nil);
      Assert.AreEqual(1, R.Agregados, 'el siguiente archivo se procesa igual');
      Assert.AreEqual(1, R.Fallidos);
    end);
end;

procedure TPruebasAgregarFicheros.DocumentoConFicheros_UsaSuCarpetaYRaiz;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      // un documento antiguo con su fichero en otra carpeta y otra raiz
      FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, ' +
        'Version, Codigodoc, idhijo, nombre, ext, extnombre, urlraiz, path, tamano, ' +
        'padre, nivel, fuente, Etiqueta) VALUES (:a, :b, :c, :d, :e, :f, 900001, ' +
        '''viejo.pdf'', 1, ''.pdf'', ''s3://5/'', ''\viejo\carpeta\'', 10, 0, 0, ''N'', ''viejo'')',
        [FClave.IdEstructura, FClave.Id, FClave.CodSubs, FClave.Fecha, FClave.Version,
        FClave.Codigodoc]);
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('nuevo.pdf', 10), False)], nil);
      Assert.AreEqual(1, R.Agregados);
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND nombre = ''nuevo.pdf'' AND urlraiz = ''s3://5/'' AND path = ''\viejo\carpeta\'''));
    end);
end;

procedure TPruebasAgregarFicheros.RaicesMezcladas_CadaFicheroVaAlAlmacenDeSuRaiz;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
      OtroI: IAlmacenFicheros;
      Otro: TAlmacenMemoria;
      Fab: TFabricaAlmacen;
    begin
      // el documento tiene su anexo en la raiz s3://5/ (por ejemplo FTP antiguo) y
      // aun no tiene fuentes: la fuente nueva va a la raiz de los documentos nuevos
      FConn.ExecSQL('INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, ' +
        'Version, Codigodoc, idhijo, nombre, ext, extnombre, urlraiz, path, tamano, ' +
        'padre, nivel, fuente, Etiqueta) VALUES (:a, :b, :c, :d, :e, :f, 900002, ' +
        '''viejo.pdf'', 1, ''.pdf'', ''s3://5/'', ''\viejo\carpeta\'', 10, 0, 0, ''N'', ''viejo'')',
        [FClave.IdEstructura, FClave.Id, FClave.CodSubs, FClave.Fecha, FClave.Version,
        FClave.Codigodoc]);
      Otro := TAlmacenMemoria.Create;
      OtroI := Otro;
      Fab := function(const UrlRaiz, Path, Nombre: string; out Clave: string): IAlmacenFicheros
        begin
          Clave := ClaveDeObjeto(UrlRaiz, Path, Nombre);
          if UrlRaiz = 's3://5/' then
            Result := FAlmI
          else
            Result := OtroI;
        end;
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, Fab,
        [Nuevo(Archivo('fuente.docx', 10), True), Nuevo(Archivo('anexo.pdf', 10), False)], nil);
      Assert.AreEqual(2, R.Agregados);
      Assert.AreEqual(1, Otro.Objetos.Count, 'la fuente va al almacen de la raiz de documentos nuevos');
      Assert.AreEqual(1, FAlm.Objetos.Count, 'el anexo va al almacen de su raiz existente');
    end);
end;

procedure TPruebasAgregarFicheros.Cancelar_DejaOmitidosLosQueFaltan;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      R := AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('c1.pdf', 10), False), Nuevo(Archivo('c2.pdf', 10), False),
        Nuevo(Archivo('c3.pdf', 10), False)],
        procedure(Hecho, Total: Int64; var Cancelar: Boolean)
        begin
          Cancelar := True; // el usuario cancela en el primer archivo
        end);
      Assert.AreEqual(0, R.Agregados);
      Assert.AreEqual(1, R.Fallidos, 'el que se estaba subiendo');
      Assert.AreEqual(2, R.Omitidos, 'los demas ni se intentan');
      Assert.AreEqual(1, FAlm.Subidas);
    end);
end;

procedure TPruebasAgregarFicheros.Reemplaza_ConservaLaPosicionDelPdfPrincipal;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      Antes, Despues: Integer;
    begin
      AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('contenido.pdf', 40), False), Nuevo(Archivo('anexo2.pdf', 40), False)], nil);
      Antes := Cuenta('SELECT idhijo FROM tb_ssArchdigital WHERE Codigodoc = ''' + COD +
        ''' AND nombre = ''contenido.pdf''');
      ReemplazarContenido(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        Archivo('reemplazo.pdf', 60), nil);
      Despues := Cuenta('SELECT idhijo FROM tb_ssArchdigital WHERE Codigodoc = ''' + COD +
        ''' AND nombre = ''reemplazo.pdf''');
      Assert.AreEqual(Antes, Despues, 'el nuevo ocupa el lugar del anterior: sigue siendo el principal');
    end);
end;

procedure TPruebasAgregarFicheros.Reemplaza_SubeElNuevoYBorraElAnterior;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('viejo.pdf', 40), False)], nil);
      Assert.AreEqual(1, FAlm.Objetos.Count);
      R := ReemplazarContenido(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        Archivo('nuevo.pdf', 60), nil);
      Assert.AreEqual(1, R.Agregados);
      Assert.AreEqual('', R.Mensaje);
      Assert.AreEqual(0, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND nombre = ''viejo.pdf'''), 'la fila anterior desaparece');
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND nombre = ''nuevo.pdf'''));
      Assert.AreEqual(1, FAlm.Objetos.Count, 'solo queda el nuevo en el almacen');
      Assert.AreEqual(1, FAlm.Borrados);
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_log WHERE msg LIKE ''%contenido%' +
        COD + '%'''));
    end);
end;

procedure TPruebasAgregarFicheros.Reemplaza_FallaLaSubida_ElAnteriorSigueIntacto;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('viejo.pdf', 40), False)], nil);
      FAlm.FallarSubidaEn := 'A.4.3/07/074/F6T-001/Anexos Digitales/nuevo.pdf';
      R := ReemplazarContenido(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        Archivo('nuevo.pdf', 60), nil);
      Assert.AreEqual(0, R.Agregados);
      Assert.AreEqual(1, R.Fallidos);
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND nombre = ''viejo.pdf'''), 'el anterior sigue en la tabla');
      Assert.AreEqual(1, FAlm.Objetos.Count, 'el anterior sigue en el almacen');
      Assert.AreEqual(0, FAlm.Borrados, 'no se borro nada');
    end);
end;

procedure TPruebasAgregarFicheros.Reemplaza_NoEsPdf_NoHaceNada;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      R := ReemplazarContenido(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        Archivo('memoria.docx', 20), nil);
      Assert.AreEqual(0, R.Agregados);
      Assert.IsTrue(Pos('PDF', R.Mensaje) > 0);
      Assert.AreEqual(0, FAlm.Subidas, 'un archivo que no es PDF no se sube');
    end);
end;

procedure TPruebasAgregarFicheros.Reemplaza_SinPdfAnterior_AgregaComoAnexo;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      R := ReemplazarContenido(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        Archivo('primero.pdf', 20), nil);
      Assert.AreEqual(1, R.Agregados);
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND fuente = ''N'' AND nombre = ''primero.pdf'''));
      Assert.AreEqual(0, FAlm.Borrados);
    end);
end;

procedure TPruebasAgregarFicheros.Reemplaza_FallaElBorradoDelAnterior_ConservaElNuevoYLoDice;
begin
  EnCadaMotor(procedure(EsSql: Boolean)
    var
      R: TResultadoFicheros;
    begin
      AgregarFicheros(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        [Nuevo(Archivo('viejo.pdf', 40), False)], nil);
      FAlm.FallarBorrado := True;
      R := ReemplazarContenido(FConn, nil, FOrigen, FClave, FabricaUnica(FAlmI),
        Archivo('nuevo.pdf', 60), nil);
      Assert.AreEqual(1, R.Agregados, 'el nuevo ya esta guardado');
      Assert.IsTrue(Pos('anterior', R.Mensaje) > 0, 'avisa que el anterior quedo en el almacen');
      Assert.AreEqual(1, Cuenta('SELECT COUNT(*) FROM tb_ssArchdigital WHERE Codigodoc = ''' +
        COD + ''' AND nombre = ''nuevo.pdf'''));
      FAlm.FallarBorrado := False;
    end);
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasAgregarFicheros);

end.
