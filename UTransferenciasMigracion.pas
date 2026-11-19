unit UTransferenciasMigracion;

{ ---------------------------------------------------------------------------
  Informe de la tabla vieja tb_transferencia (pantalla UTransferencias, retirada).
  Esa tabla solo guardaba lineas por serie (entidad, serie, subserie, periodo,
  destino, ruta de un zip): sin nodo ni documentos, asi que NO se puede convertir en
  transferencias nuevas (prc_transferencia). Aqui solo se cuenta lo que hay para
  dejar constancia en procesos_error.log. Nunca escribe: la tabla se conserva.
  Solo RTL + FireDAC: sin VCL ni TUDM.
  --------------------------------------------------------------------------- }

interface

uses
  System.SysUtils, FireDAC.Comp.Client, UPrestamosMigracion;

{ Leidos = filas de tb_transferencia. Avisos: una linea de resumen (ejecutadas y sin
  ejecutar) y, como mucho, 50 lineas con las sin ejecutar. Sin la tabla (o si no se
  puede leer) devuelve todo en cero. }
function InformarTransferenciasViejas(Conn: TFDConnection): TInformeMigracion;

implementation

uses
  System.Variants, Data.DB;

const
  MAX_LINEAS = 50;

procedure Aviso(var Informe: TInformeMigracion; const Texto: string);
begin
  SetLength(Informe.Avisos, Length(Informe.Avisos) + 1);
  Informe.Avisos[High(Informe.Avisos)] := Texto;
end;

function InformarTransferenciasViejas(Conn: TFDConnection): TInformeMigracion;
var
  Q: TFDQuery;
  Ejecutadas: Integer;
  Linea: string;
begin
  Result.Leidos := 0;
  Result.Migrados := 0;
  Result.SinDocumentos := 0;
  Result.DocumentosOmitidos := 0;
  Result.Avisos := nil;
  Q := TFDQuery.Create(nil);
  try
    Q.Connection := Conn;
    try
      // dos conteos simples: CASE no existe en Access (alli seria IIF)
      Q.Open('SELECT COUNT(*) AS Total FROM tb_transferencia');
      Result.Leidos := Q.FieldByName('Total').AsInteger;
      Q.Close;
      if Result.Leidos = 0 then
        Exit;
      Q.Open('SELECT COUNT(*) AS Hechas FROM tb_transferencia WHERE Ejecutada <> 0');
      Ejecutadas := Q.FieldByName('Hechas').AsInteger;
      Q.Close;
      if Result.Leidos = 0 then
        Exit;
      Aviso(Result, 'tb_transferencia (pantalla vieja, retirada): ' + IntToStr(Result.Leidos) +
        ' lineas, ' + IntToStr(Ejecutadas) + ' ejecutadas y ' +
        IntToStr(Result.Leidos - Ejecutadas) + ' sin ejecutar. No se migran (no tienen ' +
        'nodo ni documentos); la tabla se conserva.');
      if Result.Leidos - Ejecutadas > 0 then
      begin
        Q.Open('SELECT TOP ' + IntToStr(MAX_LINEAS) + ' fechainput, entidad, serie, subserie ' +
          'FROM tb_transferencia WHERE Ejecutada = 0 OR Ejecutada IS NULL ' +
          'ORDER BY fechainput');
        while not Q.Eof do
        begin
          Linea := '  sin ejecutar: ';
          if not Q.FieldByName('fechainput').IsNull then
            Linea := Linea + FormatDateTime('yyyy-mm-dd', Q.FieldByName('fechainput').AsDateTime) + ' ';
          Linea := Linea + Trim(Q.FieldByName('entidad').AsString) + ' / ' +
            Trim(Q.FieldByName('serie').AsString) + ' / ' + Trim(Q.FieldByName('subserie').AsString);
          Aviso(Result, Linea);
          Q.Next;
        end;
      end;
    except
      // sin la tabla (o sin permiso): nada que informar
      Result.Leidos := 0;
      Result.Avisos := nil;
    end;
  finally
    Q.Free;
  end;
end;

end.
