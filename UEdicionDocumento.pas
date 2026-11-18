unit UEdicionDocumento;

{ Edicion de uno o varios documentos: valida los cambios y los aplica solo a los
  campos pedidos, un documento a la vez (cada uno en su propia transaccion, con su
  bitacora), de modo que un documento que falla no impide los demas. Nunca toca
  las claves (codigo, fecha, version). Comprueba el permiso de editar por
  documento y, para los campos de ubicacion, el de editar topografia. Si se le
  pasan los valores con que se abrio el formulario (Anteriores), no pisa en
  silencio lo que otro usuario cambio mientras tanto. Solo RTL + FireDAC, sin VCL
  ni UDM. Valido en SQL Server y en Access. Codigo en ASCII. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance, UCargaDocumento, UDocumentoVista;

type
  { Campos de un documento que se pueden cambiar. Cada campo tiene su bandera
    Tiene...: solo los que la tienen se escriben. Un texto vacio, o un numero
    negativo, vacia el campo (NULL). Visible: 'S', 'N' o '' (vaciar). }
  TCambiosDoc = record
    TieneTitulo: Boolean;        Titulo: string;
    TieneObservaciones: Boolean; Observaciones: string;
    TieneGestor: Boolean;        Gestor: Integer;
    TieneIdExpediente: Boolean;  IdExpediente: string;
    TieneSubExp: Boolean;        SubExp: string;
    TieneVisible: Boolean;       Visible: string;
    TieneArchivo: Boolean;       Archivo: Integer;
    TieneDeposito: Boolean;      Deposito: string;
    TieneGaveta: Boolean;        Gaveta: string;
    TieneIdServidor: Boolean;    IdServidor: Integer;
    TienePosicion: Boolean;      Posicion: string;
  end;

  TResultadoEdicion = record
    Guardados: Integer;
    Fallidos: Integer;
    Omitidos: Integer;   // sin permiso, o sin nada que cambiar
    Mensaje: string;     // el primer error y avisos de lo omitido
  end;

{ '' si los cambios valen; si no, el texto del primer error. }
function ValidarCambios(const C: TCambiosDoc): string;

{ True si hay al menos un campo para cambiar. }
function HayCambios(const C: TCambiosDoc): Boolean;

{ Aplica Cambios a cada documento de Claves. Alcance = nil: sin comprobacion de
  permiso (modo Access). Anteriores: valores con que se abrio el formulario de un
  solo documento (vacio = no comparar); si el documento ya tiene otro valor, no se
  guarda y se avisa. }
function ActualizarDocumentos(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; const Claves: TArray<TClaveDocumento>;
  const Cambios, Anteriores: TCambiosDoc): TResultadoEdicion;

implementation

uses
  System.Classes, Data.DB, FireDAC.Stan.Param, FireDAC.Stan.Error, UTrazabilidad,
  UTrazabilidadDatos, UCandados, UTransferidos;

function HayCambios(const C: TCambiosDoc): Boolean;
begin
  Result := C.TieneTitulo or C.TieneObservaciones or C.TieneGestor or
    C.TieneIdExpediente or C.TieneSubExp or C.TieneVisible or C.TieneArchivo or
    C.TieneDeposito or C.TieneGaveta or C.TieneIdServidor or C.TienePosicion;
end;

function ValidarCambios(const C: TCambiosDoc): string;
begin
  Result := '';
  if C.TieneTitulo then
  begin
    if Trim(C.Titulo) = '' then
      Exit('El título no puede quedar vacío.');
    if Length(C.Titulo) > 255 then
      Exit('El título admite hasta 255 caracteres.');
  end;
  if C.TieneIdExpediente and (Length(C.IdExpediente) > 20) then
    Exit('El expediente admite hasta 20 caracteres.');
  if C.TieneSubExp and (Length(C.SubExp) > 50) then
    Exit('El subexpediente admite hasta 50 caracteres.');
  if C.TieneDeposito and (Length(C.Deposito) > 255) then
    Exit('El depósito admite hasta 255 caracteres.');
  if C.TieneGaveta and (Length(C.Gaveta) > 20) then
    Exit('La gaveta admite hasta 20 caracteres.');
  if C.TienePosicion and (Length(C.Posicion) > 10) then
    Exit('La posición admite hasta 10 caracteres.');
  if C.TieneVisible and not ((C.Visible = '') or (C.Visible = 'S') or (C.Visible = 'N')) then
    Exit('Visible solo puede ser S o N.');
  if C.TieneArchivo and (C.Archivo > 32767) then
    Exit('El número de archivo es demasiado grande.');
  if C.TieneIdServidor and (C.IdServidor > 32767) then
    Exit('El número de servidor es demasiado grande.');
end;

type
  { Un campo editable: su columna, si esta pedido y como poner su valor. }
  TCampoEdicion = record
    Columna: string;
    Etiqueta: string;
    Pedido: Boolean;
    EsEntero: Boolean;
    Texto: string;
    Entero: Integer;
    EsUbicacion: Boolean;
  end;

function CamposDe(const C: TCambiosDoc): TArray<TCampoEdicion>;
var
  N: Integer;

  procedure Agrega(const Col, Et: string; Pedido: Boolean; EsEnt: Boolean;
    const Txt: string; Ent: Integer; Ubic: Boolean);
  begin
    if not Pedido then
      Exit;
    SetLength(Result, N + 1);
    Result[N].Columna := Col;
    Result[N].Etiqueta := Et;
    Result[N].Pedido := True;
    Result[N].EsEntero := EsEnt;
    Result[N].Texto := Txt;
    Result[N].Entero := Ent;
    Result[N].EsUbicacion := Ubic;
    Inc(N);
  end;

begin
  N := 0;
  Result := nil;
  Agrega('titulodoc', 'titulo', C.TieneTitulo, False, C.Titulo, 0, False);
  Agrega('observaciones', 'observaciones', C.TieneObservaciones, False, C.Observaciones, 0, False);
  Agrega('gestor', 'gestor', C.TieneGestor, True, '', C.Gestor, False);
  Agrega('IDExpediente', 'expediente', C.TieneIdExpediente, False, C.IdExpediente, 0, False);
  Agrega('subexp', 'subexpediente', C.TieneSubExp, False, C.SubExp, 0, False);
  Agrega('visible', 'visible', C.TieneVisible, False, C.Visible, 0, False);
  Agrega('Archivo', 'archivo', C.TieneArchivo, True, '', C.Archivo, True);
  Agrega('deposito', 'deposito', C.TieneDeposito, False, C.Deposito, 0, True);
  Agrega('gaveta', 'gaveta', C.TieneGaveta, False, C.Gaveta, 0, True);
  Agrega('Idservidor', 'servidor', C.TieneIdServidor, True, '', C.IdServidor, True);
  Agrega('posicion', 'posicion', C.TienePosicion, False, C.Posicion, 0, True);
end;

procedure PonValor(P: TFDParam; const Campo: TCampoEdicion);
begin
  if Campo.EsEntero then
  begin
    P.DataType := ftInteger;
    if Campo.Entero < 0 then
      P.Clear
    else
      P.AsInteger := Campo.Entero;
  end
  else
  begin
    // las observaciones pueden ser un memo: un parametro de cadena largo falla
    if SameText(Campo.Columna, 'observaciones') then
      P.DataType := ftMemo
    else
      P.DataType := ftString;
    if Campo.Texto = '' then
      P.Clear
    else
      P.AsString := Campo.Texto;
  end;
end;

procedure PonClave(Q: TFDQuery; const K: TClaveDocumento);
begin
  Q.ParamByName('ke').AsString := K.IdEstructura;
  Q.ParamByName('ki').AsInteger := K.Id;
  Q.ParamByName('kc').AsString := K.CodSubs;
  Q.ParamByName('kf').AsDateTime := K.Fecha;
  Q.ParamByName('kv').AsString := K.Version;
  Q.ParamByName('kd').AsString := K.Codigodoc;
end;

const
  DONDE_CLAVE = ' WHERE IdEstructura = :ke AND id = :ki AND codsubs = :kc AND ' +
    'Fecha = :kf AND Version = :kv AND Codigodoc = :kd';

{ Texto con el que se compara un valor guardado: NULL y '' son lo mismo. }
function TextoDeCampo(F: TField): string;
begin
  if F.IsNull then
    Result := ''
  else
    Result := Trim(F.AsString);
end;

{ '' si los valores actuales del documento son los de Anteriores; si no, el nombre
  del primer campo que otro usuario cambio. }
function CampoCambiadoPorOtro(Conn: TFDConnection; const K: TClaveDocumento;
  const Campos: TArray<TCampoEdicion>): string;
var
  Q: TFDQuery;
  I: Integer;
  Cols: string;
  Actual, Esperado: string;
begin
  Result := '';
  if Length(Campos) = 0 then
    Exit;
  Cols := '';
  for I := 0 to High(Campos) do
  begin
    if Cols <> '' then
      Cols := Cols + ', ';
    Cols := Cols + Campos[I].Columna;
  end;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT ' + Cols + ' FROM tb_SeriesDatos' + DONDE_CLAVE;
    PonClave(Q, K);
    Q.Open;
    if Q.IsEmpty then
      Exit;
    for I := 0 to High(Campos) do
    begin
      Actual := TextoDeCampo(Q.Fields[I]);
      if Campos[I].EsEntero then
      begin
        if Campos[I].Entero < 0 then
          Esperado := ''
        else
          Esperado := IntToStr(Campos[I].Entero);
      end
      else
        Esperado := Trim(Campos[I].Texto);
      if not SameText(Actual, Esperado) then
        Exit(Campos[I].Etiqueta);
    end;
  finally
    Q.Free;
  end;
end;

{ '' si los campos de ubicacion que se quieren cambiar coinciden con los de la
  subserie del documento (servidor, archivo, deposito y gaveta); si no, el
  motivo. Un documento debe estar donde esta su subserie. Solo se comparan los
  campos que se cambian (un dato heredado que ya no coincide no bloquea editar
  el titulo) y los que la subserie define. Vaciar un campo no se bloquea. }
function UbicacionFueraDeLaSubserie(Conn: TFDConnection; const K: TClaveDocumento;
  const Campos: TArray<TCampoEdicion>): string;
var
  Q: TFDQuery;
  I: Integer;
  Sub, Nuevo: string;
begin
  Result := '';
  Q := nil;
  for I := 0 to High(Campos) do
  begin
    if not Campos[I].EsUbicacion or SameText(Campos[I].Columna, 'posicion') then
      Continue;
    if Q = nil then
    begin
      Q := TFDQuery.Create(nil);
      Q.Connection := Conn;
      Q.SQL.Text := 'SELECT deposito, gaveta, Archivo, idservidor FROM tb_Serietree ' +
        'WHERE IdEstructura = :e AND id = :i AND codsubs = :c';
      Q.ParamByName('e').AsString := K.IdEstructura;
      Q.ParamByName('i').AsInteger := K.Id;
      Q.ParamByName('c').AsString := K.CodSubs;
      Q.Open;
    end;
    if Q.IsEmpty then
      Break;
    if SameText(Campos[I].Columna, 'deposito') then
      Sub := Trim(Q.FieldByName('deposito').AsString)
    else if SameText(Campos[I].Columna, 'gaveta') then
      Sub := Trim(Q.FieldByName('gaveta').AsString)
    else if SameText(Campos[I].Columna, 'Archivo') then
      Sub := Trim(Q.FieldByName('Archivo').AsString)
    else
      Sub := Trim(Q.FieldByName('idservidor').AsString);
    if (Sub = '') or (Sub = '0') then
      Continue; // la subserie no define este tramo
    if Campos[I].EsEntero then
    begin
      if Campos[I].Entero < 0 then
        Continue;
      Nuevo := IntToStr(Campos[I].Entero);
    end
    else
    begin
      Nuevo := Trim(Campos[I].Texto);
      if Nuevo = '' then
        Continue;
    end;
    if not SameText(Nuevo, Sub) then
    begin
      Result := Format('Ubicación fuera de la subserie: %s "%s", pero la subserie tiene %s "%s". ' +
        'El documento debe estar donde está su subserie.',
        [Campos[I].Etiqueta, Nuevo, Campos[I].Etiqueta, Sub]);
      Break;
    end;
  end;
  Q.Free;
end;

{ Cuales de las claves ya pasaron a un archivo central (solo lectura en el origen):
  una consulta por subserie. Una base sin las tablas de procesos no tiene documentos
  transferidos; cualquier otro error de base se propaga. }
function ClavesYaTransferidas(Conn: TFDConnection;
  const Claves: TArray<TClaveDocumento>): TArray<Boolean>;
var
  Docs: TArray<TUnidadDoc>;
  I: Integer;
begin
  SetLength(Docs, Length(Claves));
  for I := 0 to High(Claves) do
  begin
    Docs[I].IdEstructura := Claves[I].IdEstructura;
    Docs[I].Id := Claves[I].Id;
    Docs[I].CodSubs := Claves[I].CodSubs;
    Docs[I].CodigoDoc := Claves[I].Codigodoc;
    Docs[I].Fecha := Claves[I].Fecha;
    Docs[I].Version := Claves[I].Version;
  end;
  Result := ClavesTransferidas(Conn, Docs);
end;

function ActualizarDocumentos(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; const Claves: TArray<TClaveDocumento>;
  const Cambios, Anteriores: TCambiosDoc): TResultadoEdicion;
var
  Todos, Aplicar, Previos: TArray<TCampoEdicion>;
  I, J, N, TopoOmitida, SinPermiso, Transferidos: Integer;
  Nodo: TClaveNodo;
  K: TClaveDocumento;
  PuedeTopo, Propia: Boolean;
  YaTransferido: TArray<Boolean>;
  Q: TFDQuery;
  Sets, Cambiados, PrimerError, Otro: string;
begin
  Result := Default(TResultadoEdicion);
  PrimerError := ValidarCambios(Cambios);
  if PrimerError <> '' then
  begin
    Result.Fallidos := Length(Claves);
    Result.Mensaje := PrimerError;
    Exit;
  end;
  if not HayCambios(Cambios) then
    Exit;
  Todos := CamposDe(Cambios);
  Previos := CamposDe(Anteriores);
  TopoOmitida := 0;
  SinPermiso := 0;
  Transferidos := 0;
  YaTransferido := ClavesYaTransferidas(Conn, Claves);
  for I := 0 to High(Claves) do
  begin
    K := Claves[I];
    Nodo.IdEstructura := K.IdEstructura;
    Nodo.Id := K.Id;
    if YaTransferido[I] then
    begin
      Inc(Result.Omitidos);
      Inc(Transferidos);
      Continue;
    end;
    if (Alcance <> nil) and not Alcance.PuedeRealizar(acEditar, Nodo, K.CodSubs) then
    begin
      Inc(Result.Omitidos);
      Inc(SinPermiso);
      Continue;
    end;
    PuedeTopo := (Alcance = nil) or Alcance.PuedeRealizar(acEditarTopografia, Nodo, K.CodSubs);
    // los campos de ubicacion solo con permiso de topografia
    SetLength(Aplicar, Length(Todos));
    N := 0;
    for J := 0 to High(Todos) do
      if (not Todos[J].EsUbicacion) or PuedeTopo then
      begin
        Aplicar[N] := Todos[J];
        Inc(N);
      end;
    SetLength(Aplicar, N);
    if N < Length(Todos) then
      Inc(TopoOmitida);
    if N = 0 then
    begin
      Inc(Result.Omitidos);
      Continue;
    end;
    try
      Otro := UbicacionFueraDeLaSubserie(Conn, K, Aplicar);
      if Otro <> '' then
        raise Exception.Create(Otro);
      // otro usuario pudo cambiar el documento desde que se abrio el formulario
      if Length(Previos) > 0 then
      begin
        Otro := CampoCambiadoPorOtro(Conn, K, Previos);
        if Otro <> '' then
          raise Exception.CreateFmt('Otro usuario cambio %s de "%s" mientras tanto; ' +
            'vuelva a abrir el documento.', [Otro, Trim(K.Codigodoc)]);
      end;
      Sets := '';
      Cambiados := '';
      for J := 0 to High(Aplicar) do
      begin
        if Sets <> '' then
        begin
          Sets := Sets + ', ';
          Cambiados := Cambiados + ', ';
        end;
        Sets := Sets + Aplicar[J].Columna + ' = :p' + IntToStr(J);
        Cambiados := Cambiados + Aplicar[J].Etiqueta;
      end;
      Propia := not Conn.InTransaction;
      if Propia then
        Conn.StartTransaction;
      try
        Q := TFDQuery.Create(nil);
        try
          Q.Connection := Conn;
          Q.SQL.Text := 'UPDATE tb_SeriesDatos SET ' + Sets + DONDE_CLAVE;
          for J := 0 to High(Aplicar) do
            PonValor(Q.ParamByName('p' + IntToStr(J)), Aplicar[J]);
          PonClave(Q, K);
          Q.ExecSQL;
          if Q.RowsAffected = 0 then
            raise Exception.CreateFmt('El documento "%s" ya no existe.', [Trim(K.Codigodoc)]);
        finally
          Q.Free;
        end;
        RegistrarEventoDoc(Conn, K, ACCION_MODIFICAR,
          Format('Se modificaron los datos del documento con código "%s": %s.',
          [Trim(K.Codigodoc), Cambiados]), Origen.Usuario, Origen.Rol, Origen.CodSerie);
        if Propia then
          Conn.Commit;
      except
        if Propia and Conn.InTransaction then
          Conn.Rollback;
        raise;
      end;
      Inc(Result.Guardados);
    except
      on E: Exception do
      begin
        Inc(Result.Fallidos);
        if PrimerError = '' then
          PrimerError := E.Message;
      end;
    end;
  end;
  Result.Mensaje := PrimerError;
  if Transferidos > 0 then
    Result.Mensaje := Trim(Result.Mensaje + Format(' %d documento(s) omitido(s) por estar transferido(s) al archivo central.',
      [Transferidos]));
  if SinPermiso > 0 then
    Result.Mensaje := Trim(Result.Mensaje + Format(' %d documento(s) omitido(s) por falta de permiso.',
      [SinPermiso]));
  if TopoOmitida > 0 then
    Result.Mensaje := Trim(Result.Mensaje + Format(' En %d documento(s) no se cambio la ubicación: ' +
      'falta permiso para editar la topografía.', [TopoOmitida]));
end;

end.
