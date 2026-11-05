unit UCargaDocumento;

{ Guarda un documento nuevo con sus ficheros, metadatos y bitacora.
  Orden: permiso y topografia -> validacion de datos -> reserva del codigo
  (insercion del documento, que garantiza la unicidad por su clave) -> subida
  de ficheros al almacen -> alta de metadatos, ficheros y bitacora (una
  transaccion si el llamador no tiene una abierta). Si algo falla desde la
  subida en adelante se deshace todo: se borran los objetos subidos y las filas
  creadas. Solo RTL + FireDAC, sin VCL ni UDM. Valido en SQL Server y en
  Access. Codigo en ASCII. }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UAlcance, UAlmacenFicheros, UCargaModelo,
  UMetadatosSubserie;

type
  TOrigenDocumento = record
    IdEstructura: string;
    Id: Integer;
    CodSubs: string;
    CodSerie: string;
    Usuario: string;
    Rol: string;
    UrlRaiz: string;      // 's3://<servidor>/'
  end;

  TResultadoDocumento = record
    Guardado: Boolean;
    Codigodoc: string;    // el codigo final (puede diferir del pedido)
    Mensaje: string;
    Subidos: Integer;
  end;

{ Alcance = nil: sin comprobacion de permiso (modo Access). Campos y TablaMeta
  vacios: la subserie no tiene datos propios. }
function GuardarDocumento(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; Almacen: IAlmacenFicheros; const Cand: TCandidato;
  const Campos: TArray<TCampoMeta>; const TablaMeta: string;
  Progreso: TProgresoEvento): TResultadoDocumento;

implementation

uses
  System.Classes, System.IOUtils, System.Variants, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Error, FireDAC.Stan.Param, UTopografia;

const
  VERSION_INICIAL = '1.0';
  MAX_INTENTOS_CODIGO = 50;

type
  TNodo = record
    Encontrado: Boolean;
    Deposito, Gaveta, Archivo, Gestor, IdServidor: Variant;
  end;

  TSubido = record
    Clave: string;
    Nombre, Carpeta, Local: string;
    EsFuente: Boolean;
    Tamano: Int64;
  end;

procedure PonParam(P: TFDParam; Tipo: TFieldType; const V: Variant);
begin
  P.DataType := Tipo;
  if VarIsNull(V) or VarIsEmpty(V) then
    P.Clear
  else
    P.Value := V;
end;

function LeerNodo(Conn: TFDConnection; const O: TOrigenDocumento): TNodo;
var
  Q: TFDQuery;
begin
  Result := Default(TNodo);
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT deposito, gaveta, Archivo, gestor, Idservidor FROM tb_Serietree ' +
      'WHERE IdEstructura = :a AND id = :b AND codsubs = :c';
    Q.ParamByName('a').AsString := O.IdEstructura;
    Q.ParamByName('b').AsInteger := O.Id;
    Q.ParamByName('c').AsString := O.CodSubs;
    Q.Open;
    Result.Encontrado := not Q.IsEmpty;
    if Result.Encontrado then
    begin
      Result.Deposito := Q.FieldByName('deposito').Value;
      Result.Gaveta := Q.FieldByName('gaveta').Value;
      Result.Archivo := Q.FieldByName('Archivo').Value;
      Result.Gestor := Q.FieldByName('gestor').Value;
      Result.IdServidor := Q.FieldByName('Idservidor').Value;
    end;
  finally
    Q.Free;
  end;
end;

function SoporteDe(Conn: TFDConnection; const CodSubs: string): Integer;
var
  Q: TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT soporte FROM cl_subseries WHERE codsubs = :c';
    Q.ParamByName('c').AsString := CodSubs;
    Q.Open;
    if not Q.IsEmpty then
      Result := Q.FieldByName('soporte').AsInteger;
  finally
    Q.Free;
  end;
end;

function Texto(const V: Variant): string;
begin
  if VarIsNull(V) or VarIsEmpty(V) then
    Result := ''
  else
    Result := VarToStr(V);
end;

function ExisteCodigo(Conn: TFDConnection; const Codigo: string): Boolean;
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT COUNT(*) FROM tb_SeriesDatos WHERE Codigodoc = :c';
    Q.ParamByName('c').AsString := Codigo;
    Q.Open;
    Result := Q.Fields[0].AsInteger > 0;
  finally
    Q.Free;
  end;
end;

{ Nombre valido en Windows (sin \ / : * ? " < > |) para usarlo en rutas }
function CarpetaSegura(const S: string): string;
begin
  Result := LimpiarNombreArchivo(S);
end;

{ Inserta el documento reservando un codigo libre. Devuelve el codigo final. }
function ReservarDocumento(Conn: TFDConnection; const O: TOrigenDocumento;
  const Nodo: TNodo; const Cand: TCandidato; Fecha: TDateTime;
  const CodigoPedido: string): string;
var
  Q: TFDQuery;
  Codigo, Ultimo: string;
  Intento: Integer;
begin
  Codigo := CodigoPedido;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'INSERT INTO tb_SeriesDatos (IdEstructura, id, codsubs, Fecha, Version, ' +
      'Codigodoc, titulodoc, Archivo, deposito, gaveta, Idservidor, gestor, namefile) ' +
      'VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k, :l, :m)';
    for Intento := 1 to MAX_INTENTOS_CODIGO do
    begin
      if ExisteCodigo(Conn, Codigo) then
      begin
        Ultimo := Codigo;
        Codigo := SiguienteCodigo(Ultimo, O.IdEstructura, O.CodSubs, VERSION_INICIAL);
        Continue;
      end;
      PonParam(Q.ParamByName('a'), ftString, O.IdEstructura);
      PonParam(Q.ParamByName('b'), ftInteger, O.Id);
      PonParam(Q.ParamByName('c'), ftString, O.CodSubs);
      PonParam(Q.ParamByName('d'), ftDateTime, Fecha);
      PonParam(Q.ParamByName('e'), ftString, VERSION_INICIAL);
      PonParam(Q.ParamByName('f'), ftString, Codigo);
      PonParam(Q.ParamByName('g'), ftString, Cand.Titulo);
      PonParam(Q.ParamByName('h'), ftSmallint, Nodo.Archivo);
      PonParam(Q.ParamByName('i'), ftString, Nodo.Deposito);
      PonParam(Q.ParamByName('j'), ftString, Nodo.Gaveta);
      PonParam(Q.ParamByName('k'), ftSmallint, Nodo.IdServidor);
      PonParam(Q.ParamByName('l'), ftInteger, Nodo.Gestor);
      PonParam(Q.ParamByName('m'), ftString, CarpetaSegura(Codigo));
      try
        Q.ExecSQL;
        Exit(Codigo);
      except
        on E: EFDDBEngineException do
        begin
          if E.Kind <> ekUKViolated then
            raise;
          Ultimo := Codigo;
          Codigo := SiguienteCodigo(Ultimo, O.IdEstructura, O.CodSubs, VERSION_INICIAL);
        end;
      end;
    end;
  finally
    Q.Free;
  end;
  raise EAlmacen.Create('No se pudo reservar un codigo libre para el documento.');
end;

procedure BorrarFilasDelDocumento(Conn: TFDConnection; const O: TOrigenDocumento;
  Fecha: TDateTime; const Codigo, TablaMeta: string);
var
  Q: TFDQuery;

  procedure Borrar(const Tabla: string);
  begin
    Q.SQL.Text := 'DELETE FROM ' + Tabla + ' WHERE IdEstructura = :a AND id = :b AND ' +
      'codsubs = :c AND Version = :e AND Codigodoc = :f AND Fecha >= :d1 AND Fecha <= :d2';
    Q.ParamByName('a').AsString := O.IdEstructura;
    Q.ParamByName('b').AsInteger := O.Id;
    Q.ParamByName('c').AsString := O.CodSubs;
    Q.ParamByName('e').AsString := VERSION_INICIAL;
    Q.ParamByName('f').AsString := Codigo;
    Q.ParamByName('d1').AsDateTime := Fecha - 1 / 86400;
    Q.ParamByName('d2').AsDateTime := Fecha + 1 / 86400;
    Q.ExecSQL;
  end;

begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    try Borrar('tb_ssArchdigital'); except end;
    if TablaMeta <> '' then
      try Borrar(TablaMeta); except end;
    try Borrar('tb_SeriesDatos'); except end;
  finally
    Q.Free;
  end;
end;

function IdTipoExtension(Conn: TFDConnection; const Ext: string): Integer;
var
  Q: TFDQuery;
begin
  Result := 102;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'SELECT id FROM tb_ext WHERE ext = :e';
    Q.ParamByName('e').AsString := LowerCase(Ext);
    try
      Q.Open;
      if not Q.IsEmpty then
        Result := Q.FieldByName('id').AsInteger - 1;
    except
      Result := 102;
    end;
  finally
    Q.Free;
  end;
end;

function NombreUnico(Usados: TStringList; const Carpeta, Nombre: string): string;
var
  Base, Ext: string;
  N: Integer;
begin
  Result := Nombre;
  Base := TPath.GetFileNameWithoutExtension(Nombre);
  Ext := TPath.GetExtension(Nombre);
  N := 1;
  while Usados.IndexOf(LowerCase(Carpeta + '|' + Result)) >= 0 do
  begin
    Inc(N);
    Result := Format('%s (%d)%s', [Base, N, Ext]);
  end;
  Usados.Add(LowerCase(Carpeta + '|' + Result));
end;

function TamanoDe(const Ruta: string): Int64;
var
  F: TFileStream;
begin
  F := TFileStream.Create(Ruta, fmOpenRead or fmShareDenyNone);
  try
    Result := F.Size;
  finally
    F.Free;
  end;
end;

procedure EscribirBitacora(Conn: TFDConnection; const O: TOrigenDocumento; const Msg: string);
var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    Q.SQL.Text := 'INSERT INTO tb_log (usuariopc, pc, fecha, ip, usuario_sistema, rol, msg, ' +
      'serie, subserie, IdEstructura, accion) VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k)';
    Q.ParamByName('a').AsString := GetEnvironmentVariable('USERNAME');
    Q.ParamByName('b').AsString := GetEnvironmentVariable('COMPUTERNAME');
    Q.ParamByName('c').AsString := FormatDateTime('[ddd dd mmm, hh:nn:ss:zzz]', Now);
    Q.ParamByName('d').AsString := '';
    Q.ParamByName('e').AsString := O.Usuario;
    Q.ParamByName('f').AsString := O.Rol;
    Q.ParamByName('g').AsString := Copy(Msg, 1, 255);
    Q.ParamByName('h').AsString := O.CodSerie;
    Q.ParamByName('i').AsString := O.CodSubs;
    Q.ParamByName('j').AsString := O.IdEstructura;
    Q.ParamByName('k').AsInteger := 5;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function GuardarDocumento(Conn: TFDConnection; Alcance: TAlcanceUsuario;
  const Origen: TOrigenDocumento; Almacen: IAlmacenFicheros; const Cand: TCandidato;
  const Campos: TArray<TCampoMeta>; const TablaMeta: string;
  Progreso: TProgresoEvento): TResultadoDocumento;
var
  Nodo: TNodo;
  Topo: TDatosTopografia;
  Soporte, I, J, BaseHijo: Integer;
  PuedeEditar: Boolean;
  Clave: TClaveNodo;
  Faltan: TArray<string>;
  Err, Codigo, Nombre, Carpeta, ClaveObj, PathDoc, Ext: string;
  Fecha: TDateTime;
  Archivos: TArray<TSubido>;
  Usados: TStringList;
  Subidos: TArray<string>;
  Q: TFDQuery;
  Propia, Reservado: Boolean;
  KM: TClaveMeta;
  Res: TResultadoSubida;
  SinBorrar: Boolean;
  V: Variant;
begin
  Result := Default(TResultadoDocumento);
  Fecha := Trunc(Cand.Fecha);
  if Fecha = 0 then
    Fecha := Date;

  // 1. Permiso y topografia (antes de tocar nada)
  Clave.IdEstructura := Origen.IdEstructura;
  Clave.Id := Origen.Id;
  if (Alcance <> nil) and not Alcance.PuedeRealizar(acAgregar, Clave, Origen.CodSubs) then
  begin
    Result.Mensaje := 'No tiene permiso para agregar documentos en esta subserie.';
    Exit;
  end;
  Nodo := LeerNodo(Conn, Origen);
  if not Nodo.Encontrado then
  begin
    Result.Mensaje := 'La subserie no esta declarada en este nodo.';
    Exit;
  end;
  Soporte := SoporteDe(Conn, Origen.CodSubs);
  Topo.Deposito := Texto(Nodo.Deposito);
  Topo.Gaveta := Texto(Nodo.Gaveta);
  Topo.Archivo := Texto(Nodo.Archivo);
  Topo.IdServidor := Texto(Nodo.IdServidor);
  if not TopografiaCompleta(Soporte, Topo) then
  begin
    PuedeEditar := (Alcance = nil) or Alcance.PuedeRealizar(acEditarTopografia, Clave, Origen.CodSubs);
    Result.Mensaje := MensajeTopografiaFaltante(Soporte, PuedeEditar);
    Exit;
  end;

  // 2. Datos fijos y propios de la subserie
  Faltan := Faltantes(Cand, []);
  if Length(Faltan) > 0 then
  begin
    Result.Mensaje := 'Falta el dato: ' + Faltan[0] + '.';
    Exit;
  end;
  for I := 0 to High(Campos) do
  begin
    Err := '';
    for J := 0 to High(Cand.Meta) do
      if SameText(Cand.Meta[J].Nombre, Campos[I].Nombre) then
      begin
        Err := ValidarValorMeta(Campos[I], Cand.Meta[J].Valor);
        Break;
      end;
    if (Err = '') and (Length(Cand.Meta) = 0) then
      Err := ValidarValorMeta(Campos[I], '');
    if Err <> '' then
    begin
      Result.Mensaje := Err;
      Exit;
    end;
  end;
  if (Cand.Archivo <> '') and not TFile.Exists(Cand.Archivo) then
  begin
    Result.Mensaje := 'No se encuentra el archivo ' + ExtractFileName(Cand.Archivo) + '.';
    Exit;
  end;
  for I := 0 to High(Cand.Fuentes) do
    if not TFile.Exists(Cand.Fuentes[I]) then
    begin
      Result.Mensaje := 'No se encuentra el archivo fuente ' + ExtractFileName(Cand.Fuentes[I]) + '.';
      Exit;
    end;

  // 3. Reserva del codigo
  Reservado := False;
  Subidos := nil;
  Usados := TStringList.Create;
  try
    try
      Codigo := ReservarDocumento(Conn, Origen, Nodo, Cand, Fecha, Cand.Codigo);
      Reservado := True;
      Result.Codigodoc := Codigo;

      // Lista de ficheros con nombre unico por carpeta
      PathDoc := '\' + Origen.IdEstructura + '\' + Origen.CodSerie + '\' + Origen.CodSubs + '\' +
        CarpetaSegura(Codigo);
      Archivos := nil;
      if Cand.Archivo <> '' then
      begin
        SetLength(Archivos, 1);
        Archivos[0].Local := Cand.Archivo;
        Archivos[0].Carpeta := '\Anexos Digitales\';
        Archivos[0].EsFuente := False;
      end;
      for I := 0 to High(Cand.Fuentes) do
      begin
        SetLength(Archivos, Length(Archivos) + 1);
        Archivos[High(Archivos)].Local := Cand.Fuentes[I];
        Archivos[High(Archivos)].Carpeta := '\Fuentes\';
        Archivos[High(Archivos)].EsFuente := True;
      end;
      for I := 0 to High(Archivos) do
      begin
        Nombre := NombreUnico(Usados, Archivos[I].Carpeta, ExtractFileName(Archivos[I].Local));
        Archivos[I].Nombre := Nombre;
        ClaveObj := NormalizarRutaFtp(PathDoc + Archivos[I].Carpeta + Nombre);
        if (ClaveObj <> '') and (ClaveObj[1] = '/') then
          Delete(ClaveObj, 1, 1);
        Archivos[I].Clave := ClaveObj;
      end;

      // 4. Subida
      for I := 0 to High(Archivos) do
      begin
        Res := Almacen.Subir(Archivos[I].Local, Archivos[I].Clave, Progreso);
        Archivos[I].Tamano := Res.Tamano;
        SetLength(Subidos, Length(Subidos) + 1);
        Subidos[High(Subidos)] := Archivos[I].Clave;
      end;

      // 5. Metadatos, ficheros y bitacora
      Propia := not Conn.InTransaction;
      if Propia then
        Conn.StartTransaction;
      try
        if (TablaMeta <> '') and (Length(Campos) > 0) then
        begin
          KM.IdEstructura := Origen.IdEstructura;
          KM.Id := Origen.Id;
          KM.CodSubs := Origen.CodSubs;
          KM.Fecha := Fecha;
          KM.Version := VERSION_INICIAL;
          KM.Codigodoc := Codigo;
          GuardarMetadatos(Conn, TablaMeta, KM, Campos, Cand.Meta);
        end;
        V := Conn.ExecSQLScalar('SELECT MAX(idhijo) FROM tb_ssArchdigital');
        if VarIsNull(V) or VarIsEmpty(V) then
          BaseHijo := 0
        else
          BaseHijo := Integer(V);
        Q := TFDQuery.Create(nil);
        try
          Q.Connection := Conn;
          Q.SQL.Text := 'INSERT INTO tb_ssArchdigital (IdEstructura, id, codsubs, Fecha, ' +
            'Version, Codigodoc, idhijo, nombre, ext, extnombre, urlraiz, path, tamano, ' +
            'padre, nivel, fuente, Etiqueta) VALUES (:a, :b, :c, :d, :e, :f, :g, :h, :i, ' +
            ':j, :k, :l, :m, 0, 0, :n, :o)';
          for I := 0 to High(Archivos) do
          begin
            Ext := ExtractFileExt(Archivos[I].Nombre);
            Q.ParamByName('a').AsString := Origen.IdEstructura;
            Q.ParamByName('b').AsInteger := Origen.Id;
            Q.ParamByName('c').AsString := Origen.CodSubs;
            Q.ParamByName('d').AsDateTime := Fecha;
            Q.ParamByName('e').AsString := VERSION_INICIAL;
            Q.ParamByName('f').AsString := Codigo;
            Q.ParamByName('g').AsInteger := BaseHijo + I + 1;
            Q.ParamByName('h').AsString := Archivos[I].Nombre;
            Q.ParamByName('i').AsInteger := IdTipoExtension(Conn, Ext);
            Q.ParamByName('j').AsString := Ext;
            Q.ParamByName('k').AsString := Origen.UrlRaiz;
            Q.ParamByName('l').AsString := PathDoc + Archivos[I].Carpeta;
            PonParam(Q.ParamByName('m'), ftFloat, Double(Archivos[I].Tamano));
            if Archivos[I].EsFuente then
              Q.ParamByName('n').AsString := 'S'
            else
              Q.ParamByName('n').AsString := 'N';
            Q.ParamByName('o').AsString := TPath.GetFileNameWithoutExtension(Archivos[I].Nombre);
            Q.ExecSQL;
          end;
        finally
          Q.Free;
        end;
        EscribirBitacora(Conn, Origen, Format('El documento "%s" con codigo "%s" fue agregado al sistema.',
          [Cand.Titulo, Codigo]));
        if Propia then
          Conn.Commit;
      except
        if Propia and Conn.InTransaction then
          Conn.Rollback;
        raise;
      end;
      Result.Guardado := True;
      Result.Subidos := Length(Subidos);
    except
      on E: Exception do
      begin
        Result.Guardado := False;
        Result.Subidos := 0;
        // Compensacion: objetos subidos y filas creadas
        SinBorrar := False;
        for I := 0 to High(Subidos) do
          try
            Almacen.Borrar(Subidos[I]);
          except
            SinBorrar := True;
          end;
        if Reservado then
          BorrarFilasDelDocumento(Conn, Origen, Fecha, Codigo, TablaMeta);
        if (E is EAlmacen) or (E is EMetadatos) then
          Result.Mensaje := 'No se pudo guardar el documento. ' + E.Message
        else
          Result.Mensaje := 'No se pudo guardar el documento (' + E.ClassName + ').';
        if SinBorrar then
          Result.Mensaje := Result.Mensaje + ' Quedaron ficheros sin borrar en el almacen.';
      end;
    end;
  finally
    Usados.Free;
  end;
end;

end.
