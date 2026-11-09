unit UTrazabilidadDatos;

{ Trazabilidad del documento (F5), acceso a datos: escritura de eventos en
  tb_log con la clave del documento y lectura de la linea de tiempo (log y
  prestamos) respetando el alcance. Solo RTL + FireDAC (sin VCL ni TUDM).
  Codigo en ASCII. }

interface

uses
  FireDAC.Comp.Client, UAlcance, UDocumentoVista;

{ Inserta un evento del documento en tb_log. Si tb_log aun no tiene las
  columnas de la F5 inserta la fila de siempre (sin clave de documento) para no
  perder la bitacora. Serie va a la columna serie. }
procedure RegistrarEventoDoc(Conn: TFDConnection; const Clave: TClaveDocumento;
  Accion: Integer; const Msg, Usuario, Rol, Serie: string);

implementation

uses
  System.SysUtils, Data.DB, FireDAC.Stan.Param, FireDAC.Stan.Error;

procedure RegistrarEventoDoc(Conn: TFDConnection; const Clave: TClaveDocumento;
  Accion: Integer; const Msg, Usuario, Rol, Serie: string);
const
  BASE_COLS = 'usuariopc, pc, fecha, ip, usuario_sistema, rol, msg, serie, ' +
    'subserie, IdEstructura, accion';
  BASE_VALS = ':a, :b, :c, :d, :e, :f, :g, :h, :i, :j, :k';

  procedure Poner(Q: TFDQuery);
  begin
    Q.ParamByName('a').AsString := GetEnvironmentVariable('USERNAME');
    Q.ParamByName('b').AsString := GetEnvironmentVariable('COMPUTERNAME');
    Q.ParamByName('c').AsString := FormatDateTime('[ddd dd mmm, hh:nn:ss:zzz]', Now);
    Q.ParamByName('d').AsString := '';
    Q.ParamByName('e').AsString := Usuario;
    Q.ParamByName('f').AsString := Rol;
    Q.ParamByName('g').AsString := Copy(Msg, 1, 255);
    Q.ParamByName('h').AsString := Serie;
    Q.ParamByName('i').AsString := Clave.CodSubs;
    Q.ParamByName('j').AsString := Clave.IdEstructura;
    Q.ParamByName('k').AsInteger := Accion;
  end;

var
  Q: TFDQuery;
begin
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    try
      Q.SQL.Text := 'INSERT INTO tb_log (' + BASE_COLS + ', codigodoc, iddoc, ' +
        'codsubsdoc, versiondoc, fecha_evento) VALUES (' + BASE_VALS +
        ', :m, :n, :o, :p, :q)';
      Poner(Q);
      Q.ParamByName('m').AsString := Copy(Clave.Codigodoc, 1, 20);
      Q.ParamByName('n').AsInteger := Clave.Id;
      Q.ParamByName('o').AsString := Clave.CodSubs;
      Q.ParamByName('p').AsString := Copy(Clave.Version, 1, 12);
      Q.ParamByName('q').AsDateTime := Now;
      Q.ExecSQL;
    except
      on EFDDBEngineException do
      begin
        // Sin las columnas de la F5: la bitacora de siempre
        Q.SQL.Text := 'INSERT INTO tb_log (' + BASE_COLS + ') VALUES (' + BASE_VALS + ')';
        Poner(Q);
        Q.ExecSQL;
      end;
    end;
  finally
    Q.Free;
  end;
end;

end.
