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
  end;

implementation

uses
  System.SysUtils, UCargaModelo;

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

initialization
  TDUnitX.RegisterTestFixture(TPruebasCargaModelo);

end.
