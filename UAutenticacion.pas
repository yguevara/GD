unit UAutenticacion;

{ ---------------------------------------------------------------------------
  Logica de autenticacion sin VCL ni TUDM (RTL + FireDAC como maximo), para
  poder probarla desde Pruebas/. La ventana UAutentica solo captura los datos
  y muestra el resultado que devuelve esta unidad.

  Flujo:
    1. ValidarCampos        -> hay usuario y clave escritos.
    2. VerificarCredenciales -> consulta la base de datos (siempre en vivo, sin
                                depender de copias locales de datasets) y
                                devuelve un TResultadoAutenticacion.
    3. Quien llama decide: solo con Estado = eaAceptado se establece la sesion
       (rol y usuario). Cualquier otro estado deja la sesion intacta.

  Fuera de alcance (pendiente de la etapa de seguridad): hash con sal, bloqueo
  por intentos fallidos y migracion de claves. La clave se sigue guardando como
  MD5 en minusculas (compatible con los usuarios existentes).
  --------------------------------------------------------------------------- }

interface

uses
  FireDAC.Comp.Client;

const
  { Longitud minima de una clave NUEVA (altas y cambios). El inicio de sesion
    no exige longitud para no bloquear a quien tenga una clave antigua corta. }
  LONGITUD_MINIMA_CLAVE_NUEVA = 6;

type
  { Resultado posible de un intento de inicio de sesion. }
  TEstadoAutenticacion = (
    eaAceptado,               // usuario y clave correctos, usuario habilitado
    eaCamposInvalidos,        // faltan datos (usuario o clave vacios)
    eaCredencialesInvalidas,  // usuario inexistente o clave incorrecta
    eaDeshabilitado,          // credenciales correctas pero usuario deshabilitado
    eaErrorBD                 // no se pudo consultar la base de datos
  );

  { Resultado completo de un intento de inicio de sesion. }
  TResultadoAutenticacion = record
    Estado: TEstadoAutenticacion;
    Usuario: string;  // normalizado: minusculas y sin espacios en los extremos
    Rol: string;      // nombre del rol; vacio salvo que Estado = eaAceptado
    Mensaje: string;  // texto pensado para mostrar al usuario
    Detalle: string;  // texto tecnico para el registro (UDM.log); puede estar vacio
  end;

{ Calcula el MD5 de AValor en hexadecimal y minusculas (formato guardado en
  cl_Resp_Gest_Arch.password). Unico punto de calculo del sistema. }
function CalcularMd5(const AValor: string): string;

{ Devuelve el usuario sin espacios en los extremos y en minusculas. }
function NormalizarUsuario(const AUsuario: string): string;

{ Comprueba que se escribieron usuario y clave. Devuelve False y deja en
  AMensaje el texto para el usuario si falta alguno. No exige longitud minima. }
function ValidarCampos(const AUsuario, AClave: string; out AMensaje: string): Boolean;

{ Valida una clave NUEVA (alta de usuario o cambio de clave): longitud minima
  LONGITUD_MINIMA_CLAVE_NUEVA y coincidencia con la confirmacion. }
function ValidarClaveNueva(const AClave, AConfirmacion: string; out AMensaje: string): Boolean;

{ Verifica usuario y clave contra cl_Resp_Gest_Arch y tb_rol, con una consulta
  parametrizada valida en SQL Server y Access. Nunca lanza excepciones: un
  fallo de la base de datos se devuelve como eaErrorBD con el motivo en Detalle.
  La clave se recorta (Trim) antes de calcular el MD5, igual que el inicio de
  sesion anterior. }
function VerificarCredenciales(AConn: TFDConnection; const AUsuario, AClave: string): TResultadoAutenticacion;

{ Lee el ultimo usuario guardado en ARuta (primera linea, recortada).
  Devuelve '' si el archivo no existe, esta vacio o no se puede leer. }
function LeerUltimoUsuario(const ARuta: string): string;

{ Guarda AUsuario como ultimo usuario en ARuta. Ignora los errores de escritura
  (carpeta de solo lectura, ruta inexistente): recordar el usuario es una
  comodidad, no un requisito. }
procedure GuardarUltimoUsuario(const ARuta, AUsuario: string);

implementation

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Param, IdGlobal, IdHashMessageDigest;

function CalcularMd5(const AValor: string): string;
var
  Hash: TIdHashMessageDigest5;
begin
  Hash := TIdHashMessageDigest5.Create;
  try
    Result := IndyLowerCase(Hash.HashStringAsHex(AValor));
  finally
    Hash.Free;
  end;
end;

function NormalizarUsuario(const AUsuario: string): string;
begin
  Result := AnsiLowerCase(Trim(AUsuario));
end;

function ValidarCampos(const AUsuario, AClave: string; out AMensaje: string): Boolean;
begin
  AMensaje := '';
  if Trim(AUsuario) = '' then
    AMensaje := 'Debe especificar un nombre de usuario.'
  else if Trim(AClave) = '' then
    AMensaje := 'Debe especificar la contrase'#241'a.';
  Result := AMensaje = '';
end;

function ValidarClaveNueva(const AClave, AConfirmacion: string; out AMensaje: string): Boolean;
begin
  AMensaje := '';
  if Length(AClave) < LONGITUD_MINIMA_CLAVE_NUEVA then
    AMensaje := Format('La contrase'#241'a debe tener al menos %d caracteres.',
      [LONGITUD_MINIMA_CLAVE_NUEVA])
  else if AClave <> AConfirmacion then
    AMensaje := 'La contrase'#241'a y su confirmaci'#243'n no coinciden.';
  Result := AMensaje = '';
end;

function VerificarCredenciales(AConn: TFDConnection; const AUsuario, AClave: string): TResultadoAutenticacion;
var
  Q: TFDQuery;
  FuncMinusculas, HashClave: string;
begin
  Result.Estado := eaCredencialesInvalidas;
  Result.Usuario := NormalizarUsuario(AUsuario);
  Result.Rol := '';
  Result.Mensaje := 'El usuario y/o la contrase'#241'a son incorrectos. ' +
    'Si el problema continua, contacte con un administrador del sistema.';
  Result.Detalle := '';
  try
    if SameText(AConn.DriverName, 'MSAcc') then
      FuncMinusculas := 'lcase'
    else
      FuncMinusculas := 'lower';
    HashClave := CalcularMd5(Trim(AClave));
    Q := TFDQuery.Create(nil);
    try
      Q.Connection := AConn;
      Q.SQL.Text :=
        'SELECT tb_rol.rol AS nombre_rol, cl_Resp_Gest_Arch.password AS clave, ' +
        'cl_Resp_Gest_Arch.habilitado AS activo ' +
        'FROM cl_Resp_Gest_Arch INNER JOIN tb_rol ON cl_Resp_Gest_Arch.rol = tb_rol.idrol ' +
        'WHERE ' + FuncMinusculas + '(cl_Resp_Gest_Arch.usuario) = :usuario';
      Q.ParamByName('usuario').AsString := Result.Usuario;
      Q.Open;
      while not Q.Eof do
      begin
        if SameText(Trim(Q.FieldByName('clave').AsString), HashClave) then
        begin
          if not SameText(Trim(Q.FieldByName('activo').AsString), 'S') then
          begin
            Result.Estado := eaDeshabilitado;
            Result.Mensaje := 'El usuario est'#225' deshabilitado. ' +
              'Contacte con un administrador del sistema.';
          end
          else if Trim(Q.FieldByName('nombre_rol').AsString) = '' then
            Result.Detalle := 'El usuario "' + Result.Usuario + '" no tiene un rol valido asignado.'
          else
          begin
            Result.Estado := eaAceptado;
            Result.Rol := Trim(Q.FieldByName('nombre_rol').AsString);
            Result.Mensaje := '';
          end;
          Exit;
        end;
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  except
    on E: Exception do
    begin
      Result.Estado := eaErrorBD;
      Result.Rol := '';
      Result.Mensaje := 'No se pudo consultar la base de datos. ' +
        'Intente de nuevo o contacte con un administrador del sistema.';
      Result.Detalle := E.ClassName + ': ' + E.Message;
    end;
  end;
end;

function LeerUltimoUsuario(const ARuta: string): string;
var
  Lista: TStringList;
begin
  Result := '';
  if not FileExists(ARuta) then
    Exit;
  Lista := TStringList.Create;
  try
    try
      Lista.LoadFromFile(ARuta);
      if Lista.Count > 0 then
        Result := Trim(Lista[0]);
    except
      Result := '';
    end;
  finally
    Lista.Free;
  end;
end;

procedure GuardarUltimoUsuario(const ARuta, AUsuario: string);
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  try
    try
      Lista.Add(Trim(AUsuario));
      Lista.SaveToFile(ARuta);
    except
      // Recordar el ultimo usuario es opcional: se ignora cualquier fallo.
    end;
  finally
    Lista.Free;
  end;
end;

end.
