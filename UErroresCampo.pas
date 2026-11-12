unit UErroresCampo;

{ Error de validacion de un campo de una ficha (compartido por los clasificadores). }

interface

type
  TErrorCampo = record
    Campo: string;           // clave del campo (etiqueta, direccion, puerto, ...)
    Mensaje: string;
  end;

implementation

end.
