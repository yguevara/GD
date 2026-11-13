unit UPantallaProceso;

{ ---------------------------------------------------------------------------
  Contrato de las pantallas de procesos archivisticos (prestamos,
  transferencias, depuracion) que se abren DENTRO de la ventana principal.

  Son formularios con su .dfm (no heredan de una clase comun: un formulario
  intermedio sin .dfm no se puede abrir en el IDE), asi que la ventana principal
  los maneja por esta interfaz:

    Embeber       : acopla el formulario al area de trabajo (sin borde, a todo
                    el area).
    PuedeSalir    : pregunta si hay algo sin guardar; False si el usuario decide
                    quedarse.
    FijarAlSalir  : evento que el formulario dispara cuando el usuario pide salir
                    (Esc sin panel abierto); la ventana principal decide.
  --------------------------------------------------------------------------- }

interface

uses
  System.Classes, Vcl.Controls;

type
  IPantallaProceso = interface
    ['{6F1E3B52-9C41-4D0A-8E57-2B7A1C9D4F60}']
    procedure Embeber(Host: TWinControl);
    function PuedeSalir: Boolean;
    procedure FijarAlSalir(const Valor: TNotifyEvent);
  end;

implementation

end.
