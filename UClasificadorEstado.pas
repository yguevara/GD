unit UClasificadorEstado;

{ ---------------------------------------------------------------------------
  Estado de la ficha de edicion (panel lateral) de los clasificadores. Sin VCL.

  Modos:
    mfNavegando : se mira una fila; nada se esta editando.
    mfEditando  : se cambio algun campo de una fila existente.
    mfNuevo     : se esta creando un elemento nuevo.
  La pantalla debe consultar RequiereConfirmarAbandono ANTES de cambiar de fila,
  cerrar el panel o cerrar la ventana, y solo entonces llamar a Elegir o
  Descartado.
  --------------------------------------------------------------------------- }

interface

type
  TModoFicha = (mfNavegando, mfEditando, mfNuevo);

  TEstadoFicha = class
  private
    FModo: TModoFicha;
    FCambios: Boolean;
  public
    constructor Create;
    function Modo: TModoFicha;
    function HayCambios: Boolean;
    { Se eligio una fila existente: navegando y sin cambios. }
    procedure Elegir;
    { Se empieza un elemento nuevo (aun sin cambios). }
    procedure Nuevo;
    { El usuario cambio un campo. Si navegaba pasa a editando; en nuevo sigue nuevo. }
    procedure MarcarCambio;
    { Se puede guardar: editando o nuevo, y con cambios. }
    function PuedeGuardar: Boolean;
    { Hay cambios sin guardar que se perderian al abandonar la ficha. }
    function RequiereConfirmarAbandono: Boolean;
    { Se guardo correctamente. }
    procedure Guardado;
    { Se descartaron los cambios. }
    procedure Descartado;
  end;

implementation

constructor TEstadoFicha.Create;
begin
  inherited Create;
  FModo := mfNavegando;
  FCambios := False;
end;

function TEstadoFicha.Modo: TModoFicha;
begin
  Result := FModo;
end;

function TEstadoFicha.HayCambios: Boolean;
begin
  Result := FCambios;
end;

procedure TEstadoFicha.Elegir;
begin
  FModo := mfNavegando;
  FCambios := False;
end;

procedure TEstadoFicha.Nuevo;
begin
  FModo := mfNuevo;
  FCambios := False;
end;

procedure TEstadoFicha.MarcarCambio;
begin
  FCambios := True;
  if FModo = mfNavegando then
    FModo := mfEditando;
end;

function TEstadoFicha.PuedeGuardar: Boolean;
begin
  Result := (FModo in [mfEditando, mfNuevo]) and FCambios;
end;

function TEstadoFicha.RequiereConfirmarAbandono: Boolean;
begin
  Result := FCambios;
end;

procedure TEstadoFicha.Guardado;
begin
  Elegir;
end;

procedure TEstadoFicha.Descartado;
begin
  Elegir;
end;

end.
