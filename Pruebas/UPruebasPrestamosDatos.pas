unit UPruebasPrestamosDatos;

{ Datos del prestamo. La parte pura (condiciones de filtro e indicadores a partir
  de conteos) se ejecuta siempre; las pruebas de base usan ARCHIGENIO_TEST_DB (se
  omiten sin ella) y limpian sus filas (CreadoPor = '__prueba__', anios 1990-1999). }

interface

uses
  DUnitX.TestFramework, FireDAC.Comp.Client;

type
  [TestFixture]
  TPruebasPrestamosPuro = class
  public
    [Test]
    procedure FiltroTodosNoRestringe;
    [Test]
    procedure FiltroPorEstadoUsaPasoEstadoYFecha;
    [Test]
    procedure IndicadoresCuentaCadaGrupo;
    [Test]
    procedure IndicadoresIgnoranCanceladosEnTodosMenosNinguno;
    [Test]
    procedure IndicadoresSinGruposEnCero;
  end;

  [TestFixture]
  TPruebasPrestamosDatosBD = class
  private
    FConn: TFDConnection;
    function Conectar: Boolean;
    function Escalar(const Sql: string): Variant;
  public
    [Setup]
    procedure Preparar;
    [TearDown]
    procedure Limpiar;
    [Test]
    procedure CrearSolicitudNumeraYGuardaDatos;
    [Test]
    procedure SolicitudInvalidaLanza;
    [Test]
    procedure AgregarUnDocumentoTransferidoSeRechazaYDiceDonde;
    [Test]
    procedure EntregaExigeDocumentos;
    [Test]
    procedure EntregaGuardaFechasYPasa;
    [Test]
    procedure RenovarSoloEntregadoYHaciaAdelante;
    [Test]
    procedure DevolucionLiberaLosDocumentos;
    [Test]
    procedure DevolverDosVecesSoloUna;
    [Test]
    procedure CancelarSolicitadoLibera;
    [Test]
    procedure NoSePuedeCancelarUnDevuelto;
    [Test]
    procedure ListarFiltraPorEstado;
    [Test]
    procedure ListarRespetaLimiteYBusca;
    [Test]
    procedure IndicadoresCuentaCadaGrupoEnBase;
    [Test]
    procedure BuscarDocumentosMarcaLosBloqueados;
    [Test]
    procedure DocumentoDeOtraSubserieNoSeMarca;
  end;

implementation

uses
  System.SysUtils, System.Variants, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSSQL,
  FireDAC.DApt, FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, Data.DB, UAlcance,
  UProceso, UCandados, UEsquemaProcesos, UProcesosDatos, UPrestamosReglas,
  UPrestamosDatos, UPruebasApoyoTransferido;

const
  VAR_BD = 'ARCHIGENIO_TEST_DB';
  USUARIO = '__prueba__';

{ TPruebasPrestamosPuro }

procedure TPruebasPrestamosPuro.FiltroTodosNoRestringe;
begin
  Assert.AreEqual('', CondicionFiltro(fpTodos));
end;

procedure TPruebasPrestamosPuro.FiltroPorEstadoUsaPasoEstadoYFecha;
begin
  Assert.IsTrue(Pos('p.Estado = ''C''', CondicionFiltro(fpEnPrestamo)) > 0);
  Assert.IsTrue(Pos('p.Paso = 2', CondicionFiltro(fpEnPrestamo)) > 0);
  Assert.IsTrue(Pos('r.FLimite < :hoy', CondicionFiltro(fpVencidos)) > 0);
  Assert.IsTrue(Pos('p.Paso = 2', CondicionFiltro(fpVencidos)) > 0);
  Assert.IsTrue(Pos('p.Estado = ''F''', CondicionFiltro(fpDevueltos)) > 0);
  Assert.IsTrue(Pos('p.Paso = 1', CondicionFiltro(fpSolicitudes)) > 0);
end;

procedure TPruebasPrestamosPuro.IndicadoresCuentaCadaGrupo;
var
  G: TArray<TConteoGrupo>;
  R: TIndicadoresPrestamo;
  Hoy: TDateTime;

  function Grupo(Paso: Integer; Estado: TEstadoProceso; Limite: TDateTime;
    N: Integer): TConteoGrupo;
  begin
    Result.Paso := Paso;
    Result.Estado := Estado;
    Result.Limite := Limite;
    Result.Cantidad := N;
  end;

begin
  Hoy := EncodeDate(2026, 11, 12);
  G := [Grupo(2, epEnCurso, Hoy - 1, 2),   // vencidos
        Grupo(2, epEnCurso, Hoy + 2, 3),   // por vencer
        Grupo(2, epEnCurso, Hoy + 10, 1),  // entregado
        Grupo(1, epEnCurso, 0, 4),         // solicitudes
        Grupo(3, epFinalizado, Hoy - 5, 5)];
  R := IndicadoresDesdeConteos(G, 41, Hoy);
  Assert.AreEqual(6, R.EnPrestamo, 'en prestamo incluye vencidos y por vencer');
  Assert.AreEqual(2, R.Vencidos);
  Assert.AreEqual(3, R.PorVencer);
  Assert.AreEqual(4, R.Solicitudes);
  Assert.AreEqual(41, R.DevueltosAnio);
  Assert.AreEqual(15, R.Total);
end;

procedure TPruebasPrestamosPuro.IndicadoresIgnoranCanceladosEnTodosMenosNinguno;
var
  G: TArray<TConteoGrupo>;
  R: TIndicadoresPrestamo;
begin
  SetLength(G, 1);
  G[0].Paso := 2;
  G[0].Estado := epCancelado;
  G[0].Limite := 0;
  G[0].Cantidad := 7;
  R := IndicadoresDesdeConteos(G, 0, EncodeDate(2026, 11, 12));
  Assert.AreEqual(0, R.EnPrestamo);
  Assert.AreEqual(0, R.Total, 'los cancelados no cuentan en el total');
end;

procedure TPruebasPrestamosPuro.IndicadoresSinGruposEnCero;
var
  R: TIndicadoresPrestamo;
begin
  R := IndicadoresDesdeConteos(nil, 0, Date);
  Assert.AreEqual(0, R.EnPrestamo + R.Vencidos + R.PorVencer + R.Solicitudes + R.Total);
end;

{ TPruebasPrestamosDatosBD }

procedure TPruebasPrestamosDatosBD.Preparar;
begin
  FConn := nil;
  if GetEnvironmentVariable(VAR_BD) = '' then
    Exit;
  FConn := TFDConnection.Create(nil);
  FConn.LoginPrompt := False;
  FConn.DriverName := 'MSSQL';
  FConn.Params.Values['Server'] := 'localhost';
  FConn.Params.Values['Database'] := GetEnvironmentVariable(VAR_BD);
  FConn.Params.Values['User_Name'] := 'geoconn';
  FConn.Params.Values['Password'] := 'geoconn';
  FConn.Params.Values['OSAuthent'] := 'No';
  FConn.Connected := True;
  CrearEsquemaProcesos(FConn, True);
end;

procedure TPruebasPrestamosDatosBD.Limpiar;
begin
  if FConn <> nil then
  try
    FConn.ExecSQL('DELETE FROM prc_proceso WHERE CreadoPor = ''' + USUARIO + '''');
    LimpiarTransferidos(FConn, USUARIO);
  finally
    FreeAndNil(FConn);
  end;
end;

function TPruebasPrestamosDatosBD.Conectar: Boolean;
begin
  Result := FConn <> nil;
  if not Result then
    Assert.Pass('omitida: falta ARCHIGENIO_TEST_DB');
end;

function TPruebasPrestamosDatosBD.Escalar(const Sql: string): Variant;
begin
  Result := FConn.ExecSQLScalar(Sql);
end;

function NodoDePrueba(Conn: TFDConnection): TClaveNodo;
begin
  Result.IdEstructura := VarToStr(Conn.ExecSQLScalar(
    'SELECT TOP 1 IdEstructura FROM tb_tree ORDER BY IdEstructura, id'));
  Result.Id := Integer(Conn.ExecSQLScalar(
    'SELECT TOP 1 id FROM tb_tree ORDER BY IdEstructura, id'));
end;

function SolicitudPrueba(const Nombre: string): TSolicitudPrestamo;
begin
  Result.Solicitante := Nombre;
  Result.Carnet := '';
  Result.Entidad := 'Finanzas';
  Result.Usuario := tuInterno;
  Result.FechaLimite := 0;
end;

function DocPrueba(const IdEstr: string; Id: Integer; const Subs, Cod: string): TUnidadDoc;
begin
  Result.IdEstructura := IdEstr;
  Result.Id := Id;
  Result.CodSubs := Subs;
  Result.CodigoDoc := Cod;
  Result.Fecha := EncodeDate(2020, 5, 17);
  Result.Version := '1';
end;

procedure TPruebasPrestamosDatosBD.CrearSolicitudNumeraYGuardaDatos;
var
  R: TProcesoRef;
begin
  if not Conectar then Exit;
  R := CrearSolicitud(FConn, NodoDePrueba(FConn), SolicitudPrueba('Ana'), USUARIO, 1990);
  Assert.AreEqual('1990-0001', R.Numero);
  Assert.AreEqual('Ana', VarToStr(Escalar('SELECT Solicitante FROM prc_prestamo WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.AreEqual('I', VarToStr(Escalar('SELECT TipoUsuario FROM prc_prestamo WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasPrestamosDatosBD.AgregarUnDocumentoTransferidoSeRechazaYDiceDonde;
var
  R: TProcesoRef;
  U: TUnidadDoc;
  Motivo: string;
begin
  if not Conectar then Exit;
  R := CrearSolicitud(FConn, NodoDePrueba(FConn), SolicitudPrueba('Ana'), USUARIO, 1990);
  U := DocPrueba('ZZ.1', 173, 'S1', 'DX1');
  SembrarTransferido(FConn, U, USUARIO);
  Assert.IsFalse(AgregarDocumento(FConn, R.IdProceso, U, Motivo));
  Assert.IsTrue(Pos('Transferido', Motivo) > 0, 'el motivo dice que fue transferido: ' + Motivo);
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_unidad WHERE IdProceso = ' +
    IntToStr(R.IdProceso))), 'no se agrego');
end;

procedure TPruebasPrestamosDatosBD.SolicitudInvalidaLanza;
var
  S: TSolicitudPrestamo;
begin
  if not Conectar then Exit;
  S := SolicitudPrueba('');
  Assert.WillRaise(
    procedure
    begin
      CrearSolicitud(FConn, NodoDePrueba(FConn), S, USUARIO, 1990);
    end, EPrestamoInvalido);
  Assert.AreEqual(0, Integer(Escalar('SELECT COUNT(*) FROM prc_proceso WHERE CreadoPor = ''' +
    USUARIO + '''')));
end;

procedure TPruebasPrestamosDatosBD.EntregaExigeDocumentos;
var
  R: TProcesoRef;
  Motivo: string;
begin
  if not Conectar then Exit;
  R := CrearSolicitud(FConn, NodoDePrueba(FConn), SolicitudPrueba('Ana'), USUARIO, 1990);
  Assert.IsFalse(RegistrarEntrega(FConn, R.IdProceso, USUARIO, Now, Date + 3, Motivo));
  Assert.IsTrue(Motivo <> '');
  Assert.AreEqual(1, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasPrestamosDatosBD.EntregaGuardaFechasYPasa;
var
  R: TProcesoRef;
  Motivo: string;
begin
  if not Conectar then Exit;
  R := CrearSolicitud(FConn, NodoDePrueba(FConn), SolicitudPrueba('Ana'), USUARIO, 1990);
  Assert.IsTrue(AgregarDocumento(FConn, R.IdProceso, DocPrueba('ZZ.1', 170, 'S1', 'D1'), Motivo));
  Assert.IsTrue(RegistrarEntrega(FConn, R.IdProceso, USUARIO, Now, Date + 3, Motivo));
  Assert.AreEqual(2, Integer(Escalar('SELECT Paso FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.IsFalse(VarIsNull(Escalar('SELECT FEntrega FROM prc_prestamo WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  Assert.IsFalse(VarIsNull(Escalar('SELECT FLimite FROM prc_prestamo WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
end;

procedure TPruebasPrestamosDatosBD.RenovarSoloEntregadoYHaciaAdelante;
var
  R: TProcesoRef;
  Motivo: string;
begin
  if not Conectar then Exit;
  R := CrearSolicitud(FConn, NodoDePrueba(FConn), SolicitudPrueba('Ana'), USUARIO, 1990);
  Assert.IsFalse(RenovarPlazo(FConn, R.IdProceso, Date + 9, USUARIO), 'aun solicitado');
  Assert.IsTrue(AgregarDocumento(FConn, R.IdProceso, DocPrueba('ZZ.1', 171, 'S1', 'D1'), Motivo));
  Assert.IsTrue(RegistrarEntrega(FConn, R.IdProceso, USUARIO, Now, Date + 3, Motivo));
  Assert.IsFalse(RenovarPlazo(FConn, R.IdProceso, Date + 2, USUARIO), 'hacia atras');
  Assert.IsTrue(RenovarPlazo(FConn, R.IdProceso, Date + 9, USUARIO));
end;

procedure TPruebasPrestamosDatosBD.DevolucionLiberaLosDocumentos;
var
  R, R2: TProcesoRef;
  Motivo: string;
  N: TClaveNodo;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  R := CrearSolicitud(FConn, N, SolicitudPrueba('Ana'), USUARIO, 1990);
  Assert.IsTrue(AgregarDocumento(FConn, R.IdProceso, DocPrueba('ZZ.1', 172, 'S1', 'D1'), Motivo));
  Assert.IsTrue(RegistrarEntrega(FConn, R.IdProceso, USUARIO, Now, Date + 3, Motivo));
  Assert.IsTrue(RegistrarDevolucion(FConn, R.IdProceso, True, 'completo', USUARIO, Now));
  Assert.AreEqual('F', VarToStr(Escalar('SELECT Estado FROM prc_proceso WHERE IdProceso = ' +
    IntToStr(R.IdProceso))));
  R2 := CrearSolicitud(FConn, N, SolicitudPrueba('Luis'), USUARIO, 1990);
  Assert.IsTrue(AgregarDocumento(FConn, R2.IdProceso, DocPrueba('ZZ.1', 172, 'S1', 'D1'), Motivo),
    'devuelto el documento, otro prestamo puede tomarlo');
end;

procedure TPruebasPrestamosDatosBD.DevolverDosVecesSoloUna;
var
  R: TProcesoRef;
  Motivo: string;
  Antes: Integer;
begin
  if not Conectar then Exit;
  R := CrearSolicitud(FConn, NodoDePrueba(FConn), SolicitudPrueba('Ana'), USUARIO, 1990);
  Assert.IsTrue(AgregarDocumento(FConn, R.IdProceso, DocPrueba('ZZ.1', 173, 'S1', 'D1'), Motivo));
  Assert.IsTrue(RegistrarEntrega(FConn, R.IdProceso, USUARIO, Now, Date + 3, Motivo));
  Assert.IsTrue(RegistrarDevolucion(FConn, R.IdProceso, True, '', USUARIO, Now));
  Antes := Integer(Escalar('SELECT COUNT(*) FROM prc_evento WHERE IdProceso = ' +
    IntToStr(R.IdProceso)));
  Assert.IsFalse(RegistrarDevolucion(FConn, R.IdProceso, True, '', USUARIO, Now));
  Assert.AreEqual(Antes, Integer(Escalar('SELECT COUNT(*) FROM prc_evento WHERE IdProceso = ' +
    IntToStr(R.IdProceso))), 'la segunda devolucion no escribe eventos');
end;

procedure TPruebasPrestamosDatosBD.CancelarSolicitadoLibera;
var
  R, R2: TProcesoRef;
  Motivo: string;
  N: TClaveNodo;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  R := CrearSolicitud(FConn, N, SolicitudPrueba('Ana'), USUARIO, 1990);
  Assert.IsTrue(AgregarDocumento(FConn, R.IdProceso, DocPrueba('ZZ.1', 174, 'S1', 'D1'), Motivo));
  Assert.IsTrue(CancelarPrestamo(FConn, R.IdProceso, 'ya no hace falta', USUARIO));
  R2 := CrearSolicitud(FConn, N, SolicitudPrueba('Luis'), USUARIO, 1990);
  Assert.IsTrue(AgregarDocumento(FConn, R2.IdProceso, DocPrueba('ZZ.1', 174, 'S1', 'D1'), Motivo));
end;

procedure TPruebasPrestamosDatosBD.NoSePuedeCancelarUnDevuelto;
var
  R: TProcesoRef;
  Motivo: string;
begin
  if not Conectar then Exit;
  R := CrearSolicitud(FConn, NodoDePrueba(FConn), SolicitudPrueba('Ana'), USUARIO, 1990);
  Assert.IsTrue(AgregarDocumento(FConn, R.IdProceso, DocPrueba('ZZ.1', 175, 'S1', 'D1'), Motivo));
  Assert.IsTrue(RegistrarEntrega(FConn, R.IdProceso, USUARIO, Now, Date + 3, Motivo));
  Assert.IsTrue(RegistrarDevolucion(FConn, R.IdProceso, True, '', USUARIO, Now));
  Assert.IsFalse(CancelarPrestamo(FConn, R.IdProceso, 'tarde', USUARIO));
end;

procedure TPruebasPrestamosDatosBD.ListarFiltraPorEstado;
var
  N: TClaveNodo;
  R1, R2: TProcesoRef;
  Motivo: string;
  Filas: TArray<TPrestamoFila>;
  F: TPrestamoFila;
  Vencido, EnPrestamo: Boolean;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  R1 := CrearSolicitud(FConn, N, SolicitudPrueba('Vencido'), USUARIO, 1990);
  R2 := CrearSolicitud(FConn, N, SolicitudPrueba('Vigente'), USUARIO, 1990);
  Assert.IsTrue(AgregarDocumento(FConn, R1.IdProceso, DocPrueba('ZZ.1', 176, 'S1', 'D1'), Motivo));
  Assert.IsTrue(AgregarDocumento(FConn, R2.IdProceso, DocPrueba('ZZ.1', 177, 'S1', 'D1'), Motivo));
  Assert.IsTrue(RegistrarEntrega(FConn, R1.IdProceso, USUARIO, Date - 10, Date - 2, Motivo));
  Assert.IsTrue(RegistrarEntrega(FConn, R2.IdProceso, USUARIO, Date, Date + 20, Motivo));
  Filas := ListarPrestamos(FConn, [N], fpVencidos, Date, '', 500);
  Vencido := False;
  for F in Filas do
    if F.IdProceso = R1.IdProceso then
      Vencido := True
    else if F.IdProceso = R2.IdProceso then
      Assert.Fail('el vigente no debe salir como vencido');
  Assert.IsTrue(Vencido);
  Filas := ListarPrestamos(FConn, [N], fpEnPrestamo, Date, '', 500);
  EnPrestamo := False;
  for F in Filas do
    if F.IdProceso = R2.IdProceso then
    begin
      EnPrestamo := True;
      Assert.IsTrue(F.Visible = epsEntregado);
    end;
  Assert.IsTrue(EnPrestamo);
end;

procedure TPruebasPrestamosDatosBD.ListarRespetaLimiteYBusca;
var
  N: TClaveNodo;
  I: Integer;
  Filas: TArray<TPrestamoFila>;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  for I := 1 to 5 do
    CrearSolicitud(FConn, N, SolicitudPrueba('Zeta' + IntToStr(I)), USUARIO, 1990);
  Filas := ListarPrestamos(FConn, [N], fpTodos, Date, 'Zeta', 3);
  Assert.AreEqual(3, Length(Filas), 'respeta el limite');
  Filas := ListarPrestamos(FConn, [N], fpTodos, Date, 'Zeta4', 50);
  Assert.AreEqual(1, Length(Filas), 'busca por solicitante');
end;

procedure TPruebasPrestamosDatosBD.IndicadoresCuentaCadaGrupoEnBase;
var
  N: TClaveNodo;
  R1, R2: TProcesoRef;
  Motivo: string;
  Antes, Despues: TIndicadoresPrestamo;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  Antes := IndicadoresPrestamo(FConn, [N], Date);
  R1 := CrearSolicitud(FConn, N, SolicitudPrueba('Vencido'), USUARIO, 1990);
  R2 := CrearSolicitud(FConn, N, SolicitudPrueba('Solo solicitud'), USUARIO, 1990);
  Assert.IsTrue(AgregarDocumento(FConn, R1.IdProceso, DocPrueba('ZZ.1', 178, 'S1', 'D1'), Motivo));
  Assert.IsTrue(RegistrarEntrega(FConn, R1.IdProceso, USUARIO, Date - 9, Date - 1, Motivo));
  Despues := IndicadoresPrestamo(FConn, [N], Date);
  Assert.AreEqual(Antes.Vencidos + 1, Despues.Vencidos);
  Assert.AreEqual(Antes.EnPrestamo + 1, Despues.EnPrestamo);
  Assert.AreEqual(Antes.Solicitudes + 1, Despues.Solicitudes);
  Assert.IsTrue(R2.IdProceso > 0);
end;

procedure TPruebasPrestamosDatosBD.BuscarDocumentosMarcaLosBloqueados;
var
  N: TClaveNodo;
  Docs: TArray<TDocumentoBuscado>;
  D: TDocumentoBuscado;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  Docs := BuscarDocumentos(FConn, [N], nil, '', 50);
  for D in Docs do
    Assert.IsTrue(D.Unidad.IdEstructura <> '', 'cada documento trae su nodo');
  Assert.IsTrue(Length(Docs) <= 50, 'respeta el limite');
end;

procedure TPruebasPrestamosDatosBD.DocumentoDeOtraSubserieNoSeMarca;
var
  N: TClaveNodo;
  R: TProcesoRef;
  Motivo: string;
  U, V: TUnidadDoc;
begin
  if not Conectar then Exit;
  N := NodoDePrueba(FConn);
  R := CrearSolicitud(FConn, N, SolicitudPrueba('Ana'), USUARIO, 1990);
  U := DocPrueba('ZZ.7', 179, 'S1', 'D1');
  V := U;
  V.CodSubs := 'S2';
  Assert.IsTrue(AgregarDocumento(FConn, R.IdProceso, U, Motivo));
  Assert.IsTrue(AgregarDocumento(FConn, R.IdProceso, V, Motivo),
    'la otra subserie es otro documento y puede ir en el mismo prestamo');
end;

end.
