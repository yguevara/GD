unit UPruebasProceso;

{ Reglas de pasos de los procesos archivisticos (prestamo, transferencia,
  depuracion): condiciones de avance, cancelacion y quien puede iniciar. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasProceso = class
  public
    [Test]
    procedure NumeroDePasosPorTipo;
    [Test]
    procedure PrestamoAvanzaSoloSinBloqueos;
    [Test]
    procedure PrestamoPaso2AvanzaSinCondiciones;
    [Test]
    procedure TransferenciaPaso2ExigeAutorizacion;
    [Test]
    procedure TransferenciaPaso3ExigeTresCondiciones;
    [Test]
    procedure TransferenciaPaso5ExigeRecepcion;
    [Test]
    procedure TransferenciaPaso6ExigeUbicacionCompleta;
    [Test]
    procedure DepuracionPaso3ExigeMuestraTestigosYActa;
    [Test]
    procedure DepuracionPaso4ExigeConfirmacionEscrita;
    [Test]
    procedure DepuracionPaso5ExigeFicherosResueltos;
    [Test]
    procedure PasoFueraDeRangoNoAvanza;
    [Test]
    procedure CancelarDepuracionEnEjecucionEsImposible;
    [Test]
    procedure EliminarSoloCanceladosOEnCursoQueAunSeCancelan;
    [Test]
    procedure CancelarTransferenciaTrasRecepcionEsImposible;
    [Test]
    procedure CancelarPrestamoDevueltoEsImposible;
    [Test]
    procedure GestionNoPuedeIniciarDepuracion;
    [Test]
    procedure CentralPuedeIniciarDepuracionSoloConRolEGD;
    [Test]
    procedure CentralNoPuedeIniciarTransferenciaDeGestion;
    [Test]
    procedure AdministradorNoPresta;
    [Test]
    procedure TipoArchivoDesdeTextoReconoceNombres;
    [Test]
    procedure EstadoDelPasoSegunElActual;
    [Test]
    procedure ProcesoFinalizadoMarcaTodosLosPasosComoHechos;
  end;

implementation

uses
  System.SysUtils, UAlcance, UProceso;

procedure TPruebasProceso.NumeroDePasosPorTipo;
begin
  Assert.AreEqual(3, NumeroPasos(tpPrestamo));
  Assert.AreEqual(6, NumeroPasos(tpTransferencia));
  Assert.AreEqual(5, NumeroPasos(tpDepuracion));
end;

procedure TPruebasProceso.PrestamoAvanzaSoloSinBloqueos;
var
  Faltan: TCondiciones;
begin
  Assert.IsFalse(PuedeAvanzar(tpPrestamo, 1, [], Faltan));
  Assert.IsTrue(Faltan = [cdSinBloqueos]);
  Assert.IsTrue(PuedeAvanzar(tpPrestamo, 1, [cdSinBloqueos], Faltan));
  Assert.IsTrue(Faltan = []);
end;

procedure TPruebasProceso.PrestamoPaso2AvanzaSinCondiciones;
var
  Faltan: TCondiciones;
begin
  Assert.IsTrue(PuedeAvanzar(tpPrestamo, 2, [], Faltan));
end;

procedure TPruebasProceso.TransferenciaPaso2ExigeAutorizacion;
var
  Faltan: TCondiciones;
begin
  Assert.IsFalse(PuedeAvanzar(tpTransferencia, 2, [], Faltan));
  Assert.IsTrue(Faltan = [cdAutorizado]);
  Assert.IsTrue(PuedeAvanzar(tpTransferencia, 2, [cdAutorizado], Faltan));
end;

procedure TPruebasProceso.TransferenciaPaso3ExigeTresCondiciones;
var
  Faltan: TCondiciones;
begin
  Assert.IsFalse(PuedeAvanzar(tpTransferencia, 3, [cdAutorizado], Faltan));
  Assert.IsTrue(Faltan = [cdSinBloqueos, cdVerificacionesCompletas]);
  Assert.IsTrue(PuedeAvanzar(tpTransferencia, 3,
    [cdAutorizado, cdSinBloqueos, cdVerificacionesCompletas], Faltan));
end;

procedure TPruebasProceso.TransferenciaPaso5ExigeRecepcion;
var
  Faltan: TCondiciones;
begin
  Assert.IsTrue(PuedeAvanzar(tpTransferencia, 4, [], Faltan));
  Assert.IsFalse(PuedeAvanzar(tpTransferencia, 5, [], Faltan));
  Assert.IsTrue(Faltan = [cdRecepcionConfirmada]);
end;

procedure TPruebasProceso.TransferenciaPaso6ExigeUbicacionCompleta;
var
  Faltan: TCondiciones;
begin
  Assert.IsFalse(PuedeAvanzar(tpTransferencia, 6, [], Faltan));
  Assert.IsTrue(Faltan = [cdUbicacionCompleta]);
  Assert.IsTrue(PuedeAvanzar(tpTransferencia, 6, [cdUbicacionCompleta], Faltan));
end;

procedure TPruebasProceso.DepuracionPaso3ExigeMuestraTestigosYActa;
var
  Faltan: TCondiciones;
begin
  Assert.IsFalse(PuedeAvanzar(tpDepuracion, 3, [cdMuestraDefinida], Faltan));
  Assert.IsTrue(Faltan = [cdTestigosMinimos, cdActaCompleta]);
  Assert.IsTrue(PuedeAvanzar(tpDepuracion, 3,
    [cdMuestraDefinida, cdTestigosMinimos, cdActaCompleta], Faltan));
end;

procedure TPruebasProceso.DepuracionPaso5ExigeFicherosResueltos;
var
  Faltan: TCondiciones;
begin
  Assert.IsTrue(CondicionesParaAvanzar(tpDepuracion, 5) = [cdFicherosResueltos]);
  Assert.IsFalse(PuedeAvanzar(tpDepuracion, 5, [], Faltan));
  Assert.IsTrue(Faltan = [cdFicherosResueltos]);
  Assert.IsTrue(PuedeAvanzar(tpDepuracion, 5, [cdFicherosResueltos], Faltan));
end;

procedure TPruebasProceso.DepuracionPaso4ExigeConfirmacionEscrita;
var
  Faltan: TCondiciones;
begin
  Assert.IsFalse(PuedeAvanzar(tpDepuracion, 4, [cdSinBloqueos], Faltan));
  Assert.IsTrue(Faltan = [cdConfirmacionEscrita]);
  Assert.IsTrue(PuedeAvanzar(tpDepuracion, 4,
    [cdConfirmacionEscrita, cdSinBloqueos], Faltan));
end;

procedure TPruebasProceso.PasoFueraDeRangoNoAvanza;
var
  Faltan: TCondiciones;
begin
  Assert.IsFalse(PuedeAvanzar(tpDepuracion, 0, [], Faltan));
  Assert.IsFalse(PuedeAvanzar(tpDepuracion, 6, [cdAutorizado], Faltan));
  Assert.IsFalse(PuedeAvanzar(tpPrestamo, 4, [], Faltan));
end;

procedure TPruebasProceso.EliminarSoloCanceladosOEnCursoQueAunSeCancelan;
begin
  // cancelado: siempre (queda como borrador inutil)
  Assert.IsTrue(PuedeEliminar(tpTransferencia, 3, epCancelado));
  // en curso: solo mientras todavia se puede cancelar
  Assert.IsTrue(PuedeEliminar(tpTransferencia, 1, epEnCurso));
  Assert.IsTrue(PuedeEliminar(tpTransferencia, 4, epEnCurso));
  Assert.IsFalse(PuedeEliminar(tpTransferencia, 5, epEnCurso));
  // finalizado: nunca, es parte del archivo historico
  Assert.IsFalse(PuedeEliminar(tpTransferencia, 6, epFinalizado));
  Assert.IsFalse(PuedeEliminar(tpPrestamo, 3, epFinalizado));
end;

procedure TPruebasProceso.CancelarDepuracionEnEjecucionEsImposible;
begin
  Assert.IsTrue(PuedeCancelar(tpDepuracion, 3));
  Assert.IsFalse(PuedeCancelar(tpDepuracion, 4));
  Assert.IsFalse(PuedeCancelar(tpDepuracion, 5));
end;

procedure TPruebasProceso.CancelarTransferenciaTrasRecepcionEsImposible;
begin
  Assert.IsTrue(PuedeCancelar(tpTransferencia, 4));
  Assert.IsFalse(PuedeCancelar(tpTransferencia, 5));
  Assert.IsFalse(PuedeCancelar(tpTransferencia, 6));
end;

procedure TPruebasProceso.CancelarPrestamoDevueltoEsImposible;
begin
  Assert.IsTrue(PuedeCancelar(tpPrestamo, 1));
  Assert.IsFalse(PuedeCancelar(tpPrestamo, 3));
end;

procedure TPruebasProceso.GestionNoPuedeIniciarDepuracion;
begin
  Assert.IsFalse(PuedeIniciar(tpDepuracion, rnEGD, taGestion));
end;

procedure TPruebasProceso.CentralPuedeIniciarDepuracionSoloConRolEGD;
begin
  Assert.IsTrue(PuedeIniciar(tpDepuracion, rnEGD, taCentral));
  Assert.IsTrue(PuedeIniciar(tpDepuracion, rnEGD, taHistorico));
  Assert.IsFalse(PuedeIniciar(tpDepuracion, rnVisor, taCentral));
  Assert.IsFalse(PuedeIniciar(tpDepuracion, rnUsuario, taCentral));
  Assert.IsFalse(PuedeIniciar(tpDepuracion, rnAdministrador, taCentral));
end;

procedure TPruebasProceso.CentralNoPuedeIniciarTransferenciaDeGestion;
begin
  Assert.IsTrue(PuedeIniciar(tpTransferencia, rnEGD, taGestion));
  Assert.IsFalse(PuedeIniciar(tpTransferencia, rnEGD, taCentral));
end;

procedure TPruebasProceso.AdministradorNoPresta;
begin
  Assert.IsFalse(PuedeIniciar(tpPrestamo, rnAdministrador, taGestion));
  Assert.IsTrue(PuedeIniciar(tpPrestamo, rnEGD, taGestion));
end;

procedure TPruebasProceso.TipoArchivoDesdeTextoReconoceNombres;
begin
  Assert.IsTrue(TipoArchivoDesdeTexto('Gesti'#243'n') = taGestion);
  Assert.IsTrue(TipoArchivoDesdeTexto('Archivo Central') = taCentral);
  Assert.IsTrue(TipoArchivoDesdeTexto('Hist'#243'rico') = taHistorico);
  Assert.IsTrue(TipoArchivoDesdeTexto('otro') = taOtro);
  Assert.IsTrue(TipoArchivoDesdeTexto('') = taOtro);
end;

procedure TPruebasProceso.EstadoDelPasoSegunElActual;
begin
  Assert.IsTrue(EstadoDelPaso(tpTransferencia, 3, epEnCurso, 1) = psHecho);
  Assert.IsTrue(EstadoDelPaso(tpTransferencia, 3, epEnCurso, 3) = psActual);
  Assert.IsTrue(EstadoDelPaso(tpTransferencia, 3, epEnCurso, 4) = psPendiente);
  Assert.IsTrue(EstadoDelPaso(tpTransferencia, 3, epEnCurso, 6) = psPendiente);
end;

procedure TPruebasProceso.ProcesoFinalizadoMarcaTodosLosPasosComoHechos;
var
  P: Integer;
begin
  for P := 1 to NumeroPasos(tpDepuracion) do
    Assert.IsTrue(EstadoDelPaso(tpDepuracion, 5, epFinalizado, P) = psHecho);
  // Un proceso cancelado deja el paso en el que se detuvo como pendiente
  Assert.IsTrue(EstadoDelPaso(tpDepuracion, 2, epCancelado, 1) = psHecho);
  Assert.IsTrue(EstadoDelPaso(tpDepuracion, 2, epCancelado, 2) = psPendiente);
end;

end.
