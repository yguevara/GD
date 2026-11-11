unit UPruebasFormularioDocumento;

{ Formulario de edicion de uno o varios documentos (VCL). Codigo en ASCII. }

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasFormularioDocumento = class
  public
    [Test]
    procedure Abrir_UnDocumento_MuestraSusValores;
    [Test]
    procedure Abrir_VariosDocumentos_DiceSinCambios;
    [Test]
    procedure Cambios_NoRellenados_NoSalen;
    [Test]
    procedure Cambios_UnSoloDocumento_SoloLoQueDifiere;
    [Test]
    procedure Guardar_ConTituloVacio_MuestraElErrorBajoElCampoYNoDispara;
    [Test]
    procedure Guardar_Valido_DisparaOnGuardar;
    [Test]
    procedure Abrir_SinPermisoDeTopografia_DeshabilitaLaUbicacion;
    [Test]
    procedure Vaciar_PoneElCampoVacioExplicito;
    [Test]
    procedure LasClavesNoSeEditan;
    [Test]
    procedure Numero_NoNumerico_MuestraElErrorBajoElCampo;
    [Test]
    procedure VisibleDesconocido_NoSeVaciaSiNoSeToca;
    [Test]
    procedure Eliminar_SoloConUnDocumento;
    [Test]
    procedure Soltar_DisparaElEventoConLasRutas;
  end;

implementation

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls,
  UFormularioDocumento, UEdicionDocumento, UDocumentoVista;

type
  TReceptor = class
    Guardados: Integer;
    Cancelados: Integer;
    Eliminados: Integer;
    Rutas: Integer;
    procedure Eliminar(Sender: TObject);
    procedure Soltar(const Rutas: TArray<string>);
    procedure Guardar(Sender: TObject);
    procedure Cancelar(Sender: TObject);
  end;

procedure TReceptor.Eliminar(Sender: TObject);
begin
  Inc(Eliminados);
end;

procedure TReceptor.Soltar(const Rutas: TArray<string>);
begin
  Self.Rutas := Length(Rutas);
end;

procedure TReceptor.Guardar(Sender: TObject);
begin
  Inc(Guardados);
end;

procedure TReceptor.Cancelar(Sender: TObject);
begin
  Inc(Cancelados);
end;

function Clave(const Cod: string): TClaveDocumento;
begin
  Result := Default(TClaveDocumento);
  Result.IdEstructura := 'A.4.3';
  Result.Id := 104;
  Result.CodSubs := '074';
  Result.Fecha := EncodeDate(2026, 1, 31);
  Result.Version := '1';
  Result.Codigodoc := Cod;
end;

function Actuales: TCambiosDoc;
begin
  Result := Default(TCambiosDoc);
  Result.TieneTitulo := True;
  Result.Titulo := 'Alcantarillado Palma Soriano';
  Result.TieneObservaciones := True;
  Result.Observaciones := 'Sin novedad';
  Result.TieneGaveta := True;
  Result.Gaveta := 'G2';
  Result.TieneDeposito := True;
  Result.Deposito := 'D1';
  Result.TieneArchivo := True;
  Result.Archivo := 2;
end;

function Nuevo(F: TForm): TFormularioDocumento;
begin
  F.SetBounds(50, 50, 500, 700);
  Result := TFormularioDocumento.Create(F);
  Result.Parent := F;
  Result.Align := alClient;
  F.Show;
  Application.ProcessMessages;
end;

procedure TPruebasFormularioDocumento.Abrir_UnDocumento_MuestraSusValores;
var
  F: TForm;
  Fm: TFormularioDocumento;
begin
  F := TForm.CreateNew(nil);
  try
    Fm := Nuevo(F);
    Fm.Abrir([Clave('A 03.01.02.0003')], Actuales, True);
    Assert.IsFalse(Fm.EsLote);
    Assert.AreEqual('Alcantarillado Palma Soriano', Fm.TextoCampo('titulo'));
    Assert.AreEqual('G2', Fm.TextoCampo('gaveta'));
    Assert.AreEqual('2', Fm.TextoCampo('archivo'));
    Assert.IsTrue(Pos('A 03.01.02.0003', Fm.TituloFormulario) > 0);
    Assert.AreEqual('Guardar', Fm.TextoBotonGuardar);
  finally
    F.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Abrir_VariosDocumentos_DiceSinCambios;
var
  F: TForm;
  Fm: TFormularioDocumento;
begin
  F := TForm.CreateNew(nil);
  try
    Fm := Nuevo(F);
    Fm.Abrir([Clave('A'), Clave('B')], Actuales, True);
    Assert.IsTrue(Fm.EsLote);
    Assert.AreEqual('', Fm.TextoCampo('titulo'), 'por lotes los campos empiezan vacios');
    Assert.IsTrue(Pos('sin cambios', LowerCase(Fm.PistaCampo('titulo'))) > 0);
    Assert.AreEqual('Editar 2 documentos', Fm.TituloFormulario);
    Assert.AreEqual('Aplicar a 2', Fm.TextoBotonGuardar);
  finally
    F.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Cambios_NoRellenados_NoSalen;
var
  F: TForm;
  Fm: TFormularioDocumento;
  C: TCambiosDoc;
begin
  F := TForm.CreateNew(nil);
  try
    Fm := Nuevo(F);
    Fm.Abrir([Clave('A'), Clave('B')], Actuales, True);
    Fm.EscribirCampo('gaveta', 'G9');
    C := Fm.Cambios;
    Assert.IsTrue(C.TieneGaveta);
    Assert.AreEqual('G9', C.Gaveta);
    Assert.IsFalse(C.TieneTitulo, 'el título no se relleno: no se pisa');
    Assert.IsFalse(C.TieneObservaciones);
    Assert.IsFalse(C.TieneDeposito);
  finally
    F.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Cambios_UnSoloDocumento_SoloLoQueDifiere;
var
  F: TForm;
  Fm: TFormularioDocumento;
  C: TCambiosDoc;
begin
  F := TForm.CreateNew(nil);
  try
    Fm := Nuevo(F);
    Fm.Abrir([Clave('A')], Actuales, True);
    Assert.IsFalse(HayCambios(Fm.Cambios), 'recien abierto no hay cambios');
    Fm.EscribirCampo('titulo', 'Título nuevo');
    C := Fm.Cambios;
    Assert.IsTrue(C.TieneTitulo);
    Assert.AreEqual('Título nuevo', C.Titulo);
    Assert.IsFalse(C.TieneObservaciones, 'lo que no se toco no sale');
    Assert.IsFalse(C.TieneGaveta);
  finally
    F.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Guardar_ConTituloVacio_MuestraElErrorBajoElCampoYNoDispara;
var
  F: TForm;
  Fm: TFormularioDocumento;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create;
  try
    Fm := Nuevo(F);
    Fm.OnGuardar := R.Guardar;
    Fm.Abrir([Clave('A')], Actuales, True);
    Fm.EscribirCampo('titulo', '   ');
    Fm.Guardar;
    Assert.AreEqual(0, R.Guardados);
    Assert.IsTrue(Pos('título', LowerCase(Fm.ErrorDe('titulo'))) > 0);
    Assert.AreEqual('', Fm.ErrorDe('gaveta'));
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Guardar_Valido_DisparaOnGuardar;
var
  F: TForm;
  Fm: TFormularioDocumento;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create;
  try
    Fm := Nuevo(F);
    Fm.OnGuardar := R.Guardar;
    Fm.OnCancelar := R.Cancelar;
    Fm.Abrir([Clave('A')], Actuales, True);
    Fm.EscribirCampo('titulo', 'Título valido');
    Fm.Guardar;
    Assert.AreEqual(1, R.Guardados);
    Fm.Cancelar;
    Assert.AreEqual(1, R.Cancelados);
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Abrir_SinPermisoDeTopografia_DeshabilitaLaUbicacion;
var
  F: TForm;
  Fm: TFormularioDocumento;
begin
  F := TForm.CreateNew(nil);
  try
    Fm := Nuevo(F);
    Fm.Abrir([Clave('A')], Actuales, False);
    Assert.IsFalse(Fm.CampoHabilitado('gaveta'));
    Assert.IsFalse(Fm.CampoHabilitado('deposito'));
    Assert.IsTrue(Fm.CampoHabilitado('titulo'));
    Fm.Abrir([Clave('A')], Actuales, True);
    Assert.IsTrue(Fm.CampoHabilitado('gaveta'));
  finally
    F.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Vaciar_PoneElCampoVacioExplicito;
var
  F: TForm;
  Fm: TFormularioDocumento;
  C: TCambiosDoc;
begin
  F := TForm.CreateNew(nil);
  try
    Fm := Nuevo(F);
    Fm.Abrir([Clave('A'), Clave('B')], Actuales, True);
    Fm.VaciarCampo('gaveta');
    C := Fm.Cambios;
    Assert.IsTrue(C.TieneGaveta);
    Assert.AreEqual('', C.Gaveta, 'vaciar pone el campo vacío a proposito');
    Assert.IsFalse(C.TieneDeposito);
  finally
    F.Free;
  end;
end;

procedure TPruebasFormularioDocumento.LasClavesNoSeEditan;
var
  F: TForm;
  Fm: TFormularioDocumento;
  N: string;
begin
  F := TForm.CreateNew(nil);
  try
    Fm := Nuevo(F);
    N := LowerCase(Fm.NombresCampos);
    Assert.IsTrue(Pos('titulo', N) > 0);
    Assert.AreEqual(0, Pos('codigo', N));
    Assert.AreEqual(0, Pos('fecha', N));
    Assert.AreEqual(0, Pos('version', N));
  finally
    F.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Numero_NoNumerico_MuestraElErrorBajoElCampo;
var
  F: TForm;
  Fm: TFormularioDocumento;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create;
  try
    Fm := Nuevo(F);
    Fm.OnGuardar := R.Guardar;
    Fm.Abrir([Clave('A')], Actuales, True);
    Fm.EscribirCampo('archivo', 'abc');
    Fm.Guardar;
    Assert.AreEqual(0, R.Guardados);
    Assert.IsTrue(Fm.ErrorDe('archivo') <> '');
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasFormularioDocumento.VisibleDesconocido_NoSeVaciaSiNoSeToca;
var
  F: TForm;
  Fm: TFormularioDocumento;
  A: TCambiosDoc;
  C: TCambiosDoc;
begin
  F := TForm.CreateNew(nil);
  try
    Fm := Nuevo(F);
    A := Actuales;
    A.TieneVisible := True;
    A.Visible := 's'; // valor que el combo no reconoce
    Fm.Abrir([Clave('A')], A, True);
    Fm.EscribirCampo('titulo', 'Solo el título');
    C := Fm.Cambios;
    Assert.IsTrue(C.TieneTitulo);
    Assert.IsFalse(C.TieneVisible, 'visible no se toca si el usuario no lo cambio');
  finally
    F.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Eliminar_SoloConUnDocumento;
var
  F: TForm;
  Fm: TFormularioDocumento;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create;
  try
    Fm := Nuevo(F);
    Fm.OnEliminar := R.Eliminar;
    Fm.Abrir([Clave('A')], Actuales, True);
    Assert.IsTrue(Fm.EliminarVisible);
    Fm.Eliminar;
    Assert.AreEqual(1, R.Eliminados);
    Fm.Abrir([Clave('A'), Clave('B')], Actuales, True);
    Assert.IsFalse(Fm.EliminarVisible, 'por lotes no se elimina');
    Fm.Eliminar;
    Assert.AreEqual(1, R.Eliminados, 'con varios no dispara');
  finally
    F.Free;
    R.Free;
  end;
end;

procedure TPruebasFormularioDocumento.Soltar_DisparaElEventoConLasRutas;
var
  F: TForm;
  Fm: TFormularioDocumento;
  R: TReceptor;
begin
  F := TForm.CreateNew(nil);
  R := TReceptor.Create;
  try
    Fm := Nuevo(F);
    Fm.OnSoltarArchivos := R.Soltar;
    Fm.Abrir([Clave('A'), Clave('B')], Actuales, True);
    Fm.Receptor.SimularSoltar(['a.pdf', 'b.pdf']);
    Assert.AreEqual(2, R.Rutas);
  finally
    F.Free;
    R.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasFormularioDocumento);

end.
