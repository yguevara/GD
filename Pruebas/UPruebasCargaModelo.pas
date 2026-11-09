unit UPruebasCargaModelo;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TPruebasCargaModelo = class
  public
    [Test]
    procedure TituloDesdeNombre_Casos;
    [Test]
    procedure SiguienteCodigo_Casos;
    [Test]
    procedure CodigosParaLote_SonConsecutivosYDistintos;
    [Test]
    procedure AplicarATodos_CopiaSoloLoPedido;
    [Test]
    procedure Faltantes_FijosYMetadatos;
    [Test]
    procedure EstadoTrasEditar_PasaDeFaltaAListo;
    [Test]
    procedure LimpiarNombreArchivo_Casos;
    [Test]
    procedure ExpandirRutas_CarpetasSueltosYFiltros;
    [Test]
    procedure ControlParaCampo_Casos;
    [Test]
    procedure ResumenLote_Casos;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, UCargaModelo, UMetadatosSubserie;

function Candidato: TCandidato;
begin
  Result := Default(TCandidato);
  Result.Archivo := 'C:\x\a.pdf';
  Result.Estado := ecEspera;
end;

procedure TPruebasCargaModelo.TituloDesdeNombre_Casos;
begin
  Assert.AreEqual('Informe final 2026 v2', TituloDesdeNombre('C:\x\informe_final-2026__v2.pdf'));
  Assert.AreEqual('', TituloDesdeNombre('C:\x\.pdf'));
  Assert.AreEqual('', TituloDesdeNombre('   '));
  Assert.AreEqual('Sin extension', TituloDesdeNombre('sin extension'));
  Assert.AreEqual('Plano ' + Char($F1) + 'and' + Char($FA), TituloDesdeNombre('plano_' + Char($F1) + 'and' + Char($FA) + '.dwg'));
end;

procedure TPruebasCargaModelo.SiguienteCodigo_Casos;
begin
  Assert.AreEqual('A.4.30741.0', SiguienteCodigo('', 'A.4.3', '074', '1.0'));
  Assert.AreEqual('DOC010', SiguienteCodigo('DOC009', 'x', 'y', '1.0'));
  Assert.AreEqual('DOC1000', SiguienteCodigo('DOC999', 'x', 'y', '1.0'));
  Assert.AreEqual('SINNUM001', SiguienteCodigo('SINNUM', 'x', 'y', '1.0'));
end;

procedure TPruebasCargaModelo.CodigosParaLote_SonConsecutivosYDistintos;
var
  C: TArray<string>;
begin
  C := CodigosParaLote('DOC009', 'x', 'y', '1.0', 3);
  Assert.AreEqual(3, Length(C));
  Assert.AreEqual('DOC010', C[0]);
  Assert.AreEqual('DOC011', C[1]);
  Assert.AreEqual('DOC012', C[2]);
  C := CodigosParaLote('', 'A.4.3', '074', '1.0', 3);
  Assert.AreEqual('A.4.30741.0', C[0]);
  Assert.AreNotEqual(C[0], C[1]);
  Assert.AreNotEqual(C[1], C[2]);
  Assert.AreEqual(0, Length(CodigosParaLote('', 'x', 'y', '1.0', 0)));
end;

procedure TPruebasCargaModelo.AplicarATodos_CopiaSoloLoPedido;
var
  L: TArray<TCandidato>;
  P: TCandidato;
begin
  SetLength(L, 2);
  L[0] := Candidato;
  L[0].Codigo := 'C1';
  L[0].Titulo := 'Uno';
  L[0].Estado := ecGuardado;
  L[1] := Candidato;
  L[1].Archivo := 'C:\x\b.pdf';
  L[1].Codigo := 'C2';
  P := Candidato;
  P.Titulo := 'Comun';
  P.Acceso := '2';
  P.Fecha := EncodeDate(2026, 3, 4);
  P.EsExpediente := True;
  AplicarATodos(L, P, [ccTitulo, ccAcceso]);
  Assert.AreEqual('Comun', L[0].Titulo);
  Assert.AreEqual('2', L[1].Acceso);
  Assert.AreEqual(Double(0), Double(L[1].Fecha), 'la fecha no se pidio');
  Assert.IsFalse(L[1].EsExpediente, 'EsExpediente no se pidio');
  Assert.AreEqual('C:\x\b.pdf', L[1].Archivo);
  Assert.AreEqual('C1', L[0].Codigo);
  Assert.IsTrue(L[0].Estado = ecGuardado, 'el estado no cambia');
end;

procedure TPruebasCargaModelo.Faltantes_FijosYMetadatos;
var
  C: TCandidato;
  F: TArray<string>;
begin
  C := Candidato;
  F := Faltantes(C, ['Cantidad']);
  Assert.AreEqual(4, Length(F), 'titulo, codigo, fecha y el obligatorio');
  C.Titulo := 'T';
  C.Codigo := 'K';
  C.Fecha := EncodeDate(2026, 1, 1);
  SetLength(C.Meta, 1);
  C.Meta[0].Nombre := 'Cantidad';
  C.Meta[0].Valor := '   ';
  F := Faltantes(C, ['Cantidad']);
  Assert.AreEqual(1, Length(F));
  Assert.AreEqual('Cantidad', F[0]);
  C.Meta[0].Valor := '5';
  Assert.AreEqual(0, Length(Faltantes(C, ['Cantidad'])));
  Assert.AreEqual(0, Length(Faltantes(C, [])));
end;

procedure TPruebasCargaModelo.EstadoTrasEditar_PasaDeFaltaAListo;
var
  C: TCandidato;
begin
  C := Candidato;
  Assert.IsTrue(EstadoTrasEditar(C, []) = ecFalta);
  C.Titulo := 'T';
  C.Codigo := 'K';
  C.Fecha := EncodeDate(2026, 1, 1);
  Assert.IsTrue(EstadoTrasEditar(C, []) = ecListo);
end;

procedure TPruebasCargaModelo.LimpiarNombreArchivo_Casos;
begin
  Assert.AreEqual('F3T-001', LimpiarNombreArchivo('F3T-001'));
  Assert.AreEqual('a_b_c_d_e_f_g_h_i', LimpiarNombreArchivo('a\b/c:d*e?f"g<h>i'));
  Assert.AreEqual('_', LimpiarNombreArchivo('   '));
end;

procedure TPruebasCargaModelo.ExpandirRutas_CarpetasSueltosYFiltros;
var
  Raiz, Sub: string;
  R: TArray<string>;
begin
  Raiz := TPath.Combine(TPath.GetTempPath, 'exp-rutas-' + TGUID.NewGuid.ToString);
  Sub := TPath.Combine(Raiz, 'sub');
  TDirectory.CreateDirectory(Sub);
  try
    TFile.WriteAllText(TPath.Combine(Raiz, 'a.pdf'), 'a');
    TFile.WriteAllText(TPath.Combine(Sub, 'b.pdf'), 'b');
    TFile.WriteAllText(TPath.Combine(Sub, '~$c.docx'), 'temporal');
    TFile.WriteAllText(TPath.Combine(Raiz, 'oculto.txt'), 'o');
    TFile.SetAttributes(TPath.Combine(Raiz, 'oculto.txt'), [TFileAttribute.faHidden]);
    TFile.WriteAllText(TPath.Combine(Raiz, 'Thumbs.db'), 't');
    R := ExpandirRutas([Raiz, TPath.Combine(Raiz, 'a.pdf'), TPath.Combine(Raiz, 'no existe.pdf')], True);
    Assert.AreEqual(2, Length(R), 'a.pdf (sin duplicar) y sub.pdf');
    Assert.AreEqual('a.pdf', ExtractFileName(R[0]));
    Assert.AreEqual('b.pdf', ExtractFileName(R[1]));
    R := ExpandirRutas([Raiz], False);
    Assert.AreEqual(1, Length(R));
    Assert.AreEqual('a.pdf', ExtractFileName(R[0]));
    Assert.AreEqual(0, Length(ExpandirRutas([], True)));
  finally
    TDirectory.Delete(Raiz, True);
  end;
end;

procedure TPruebasCargaModelo.ControlParaCampo_Casos;
begin
  Assert.AreEqual(Ord(cmEdit), Ord(ControlParaCampo(tmTexto, 50)));
  Assert.AreEqual(Ord(cmEdit), Ord(ControlParaCampo(tmTexto, 255)));
  Assert.AreEqual(Ord(cmMemo), Ord(ControlParaCampo(tmTexto, 256)));
  Assert.AreEqual(Ord(cmMemo), Ord(ControlParaCampo(tmTexto, 0)));
  Assert.AreEqual(Ord(cmMemo), Ord(ControlParaCampo(tmMemo, 10)));
  Assert.AreEqual(Ord(cmFecha), Ord(ControlParaCampo(tmFecha, 0)));
  Assert.AreEqual(Ord(cmNumero), Ord(ControlParaCampo(tmEntero, 0)));
  Assert.AreEqual(Ord(cmNumero), Ord(ControlParaCampo(tmReal, 0)));
  Assert.AreEqual(Ord(cmSiNo), Ord(ControlParaCampo(tmBooleano, 0)));
end;

procedure TPruebasCargaModelo.ResumenLote_Casos;
begin
  Assert.AreEqual('Se guardaron 3 documentos.', ResumenLote(3, 0, 0));
  Assert.AreEqual('Se guardo 1 documento.', ResumenLote(1, 0, 0));
  Assert.AreEqual('No se guardo ningun documento.', ResumenLote(0, 0, 0));
  Assert.AreEqual('No se guardo ningun documento y 2 no se pudieron guardar.', ResumenLote(0, 2, 0));
  Assert.AreEqual('Se guardo 1 documento y 2 no se pudieron guardar.', ResumenLote(1, 2, 0));
  Assert.AreEqual('Se guardaron 3 documentos y 1 no se pudo guardar.', ResumenLote(3, 1, 0));
  Assert.AreEqual('Se guardaron 2 documentos. Se cancelo la carga: 4 quedaron sin procesar.', ResumenLote(2, 0, 4));
  Assert.AreEqual('Se guardo 1 documento y 1 no se pudo guardar. Se cancelo la carga: 1 quedo sin procesar.', ResumenLote(1, 1, 1));
end;

initialization
  TDUnitX.RegisterTestFixture(TPruebasCargaModelo);

end.
