unit UProcesoDemo;

{ ---------------------------------------------------------------------------
  TEMPORAL (fase F0 de los procesos archivisticos): pantalla de demostracion que
  reproduce la maqueta A1 (Prestamos) con datos de ejemplo, para comprobar
  UProcesoBase dentro de la ventana principal. Solo se abre con la variable de
  entorno ARCHIGENIO_PROCESOS_DEMO=1 (ver TMAIN.AbrirProcesoDemo).

  SE ELIMINA en la primera tarea de la fase F1 (Prestamos), cuando exista la
  pantalla real. No tiene acceso a datos.
  --------------------------------------------------------------------------- }

interface

uses
  UClasificadorBase;

function CrearProcesoDemo: TFormClasificadorBase;

implementation

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, UProceso,
  UProcesoBase;

type
  TFormProcesoDemo = class(TFormProcesoBase)
  private
    FNota: TLabel;
  protected
    procedure AlNuevo; override;
    procedure AlElegirFila(ATag: Integer); override;
    procedure AlGuardar; override;
    procedure AlEliminar; override;
    procedure AlCambiarPestana(Indice: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

function CrearProcesoDemo: TFormClasificadorBase;
begin
  Result := TFormProcesoDemo.Create(nil);
end;

constructor TFormProcesoDemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConstruirProceso(tpPrestamo, 'Pr'#233'stamos',
    '12 pr'#233'stamos (demostraci'#243'n)', 'Nuevo pr'#233'stamo');
  AgregarColumna('N.'#186, 90);
  AgregarColumna('Solicitante', 160);
  AgregarColumna('Entidad', 190);
  AgregarColumna('Unidades', 110);
  AgregarColumna('Devolver antes de', 130);
  AgregarColumna('Estado', 130);
  AgregarFila(['2026-0047', 'Luis Fern'#225'ndez', 'Finanzas (interno)', '3 expedientes',
    '10/11/2026', 'Vencido'], 1);
  AgregarFila(['2026-0048', 'Ernesto Pardo', 'Oficina Nacional (externo)', '1 expediente',
    '16/11/2026', 'Entregado'], 2);
  AgregarFila(['2026-0049', 'Ana Rodr'#237'guez', 'Administraci'#243'n (interno)', '2 cajas',
    '13/11/2026', 'Vence en 1 d'#237'a'], 3);
  RefrescarVista;
  FijarIndicadores([
    Indicador('En pr'#233'stamo ahora', 7, False),
    Indicador('Vencidos', 2, True),
    Indicador('Vencen en 3 d'#237'as', 3, False),
    Indicador('Devueltos este a'#241'o', 41, False)]);
  FijarPestanas([
    Pestana('Todos', 12, False),
    Pestana('En pr'#233'stamo', 7, False),
    Pestana('Vencidos', 2, True),
    Pestana('Devueltos', 41, False)], 0);
  FNota := TLabel.Create(Self);
  FNota.Parent := FCuerpo;
  FNota.Align := alTop;
  FNota.WordWrap := True;
  FNota.AutoSize := True;
  FNota.Font.Color := FTema.TextoSuave;
  FNota.Caption := 'Pantalla de demostraci'#243'n de la fase F0: muestra la franja de ' +
    'indicadores, las pesta'#241'as y la tira de pasos. No guarda datos.';
end;

procedure TFormProcesoDemo.AlNuevo;
begin
  FijarPasos(['Solicitado', 'Entregado', 'Devuelto'], 1);
  AbrirPanel('Nuevo pr'#233'stamo', False);
  FijarBotones(False, True, False);
end;

procedure TFormProcesoDemo.AlElegirFila(ATag: Integer);
begin
  // Se muestra la tira de pasos del prestamo elegido (el segundo esta Entregado)
  case ATag of
    1: FijarPasos(['Solicitado', 'Entregado', 'Devuelto'], 2);
    2: FijarPasos(['Solicitado', 'Entregado', 'Devuelto'], 2);
  else
    FijarPasos(['Solicitado', 'Entregado', 'Devuelto'], 1);
  end;
  AbrirPanel('Pr'#233'stamo ' + IntToStr(ATag), False);
  FijarBotones(False, True, False);
end;

procedure TFormProcesoDemo.AlGuardar;
begin
  // La demostracion no guarda nada
end;

procedure TFormProcesoDemo.AlEliminar;
begin
  // La demostracion no elimina nada
end;

procedure TFormProcesoDemo.AlCambiarPestana(Indice: Integer);
begin
  // La demostracion no filtra la lista
end;

end.
