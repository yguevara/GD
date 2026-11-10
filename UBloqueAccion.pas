unit UBloqueAccion;

{ Bloque "Requiere accion" bajo el arbol de la estructura: lo que pide atencion
  (documentos prestados, documentos sin ubicacion) con su cantidad. Se crea por
  codigo y no accede a datos: quien lo usa le entrega los contadores. Sin
  contadores queda oculto. Colores de UTema. Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Graphics, UTema, UDocumentoVistaDatos;

type
  TClaveTextoEvent = procedure(const Clave: string) of object;

  TBloqueAccion = class(TPanel)
  private
    FTema: TTemaColores;
    FFilas: TArray<TLabel>;
    FContadores: TArray<TContadorAccion>;
    FTitulo: TLabel;
    FOnElegir: TClaveTextoEvent;
    procedure FilaClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    procedure Mostrar(const Contadores: TArray<TContadorAccion>);
    function CantidadFilas: Integer;
    { Simula el clic en la fila (pruebas). Solo 'prestados' responde. }
    procedure ClicFila(Indice: Integer);
    property OnElegir: TClaveTextoEvent read FOnElegir write FOnElegir;
  end;

implementation

uses
  UShellPrincipal;

const
  FUENTE = 'Segoe UI';

constructor TBloqueAccion.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if TemaWindowsOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
  BevelOuter := bvNone;
  ParentBackground := False;
  StyleElements := [];
  ShowCaption := False;
  Color := FTema.Fondo;
  Visible := False;
end;

procedure TBloqueAccion.Mostrar(const Contadores: TArray<TContadorAccion>);
var
  I, Y: Integer;
  L: TLabel;
begin
  FContadores := Copy(Contadores);
  for I := 0 to High(FFilas) do
    FFilas[I].Free;
  FFilas := nil;
  FreeAndNil(FTitulo);
  if Length(FContadores) = 0 then
  begin
    Visible := False;
    Exit;
  end;
  FTitulo := TLabel.Create(Self);
  FTitulo.Parent := Self;
  FTitulo.Transparent := True;
  FTitulo.StyleElements := [];
  FTitulo.Font.Name := FUENTE;
  FTitulo.Font.Size := 8;
  FTitulo.Font.Style := [fsBold];
  FTitulo.Font.Color := FTema.TextoSuave;
  FTitulo.Caption := 'REQUIERE ACCION';
  FTitulo.SetBounds(14, 10, 200, 16);
  Y := 32;
  SetLength(FFilas, Length(FContadores));
  for I := 0 to High(FContadores) do
  begin
    L := TLabel.Create(Self);
    L.Parent := Self;
    L.Transparent := True;
    L.StyleElements := [];
    L.Font.Name := FUENTE;
    L.Font.Size := 10;
    L.Font.Color := FTema.Texto;
    L.Caption := FContadores[I].Texto + '   ' + IntToStr(FContadores[I].Cantidad);
    L.Tag := I;
    L.SetBounds(14, Y, 250, 20);
    if FContadores[I].Clave = 'prestados' then
    begin
      L.Cursor := crHandPoint;
      L.Font.Color := FTema.Acento;
      L.Hint := 'Filtra la lista actual por documentos prestados';
      L.ShowHint := True;
      L.OnClick := FilaClick;
    end;
    FFilas[I] := L;
    Inc(Y, 24);
  end;
  Height := Y + 8;
  Visible := True;
end;

function TBloqueAccion.CantidadFilas: Integer;
begin
  Result := Length(FFilas);
end;

procedure TBloqueAccion.FilaClick(Sender: TObject);
var
  I: Integer;
begin
  I := TComponent(Sender).Tag;
  if (I >= 0) and (I <= High(FContadores)) and Assigned(FOnElegir) then
    FOnElegir(FContadores[I].Clave);
end;

procedure TBloqueAccion.ClicFila(Indice: Integer);
begin
  if (Indice >= 0) and (Indice <= High(FFilas)) and
    Assigned(FFilas[Indice].OnClick) then
    FFilas[Indice].OnClick(FFilas[Indice]);
end;

end.
