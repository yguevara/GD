unit UHistoriaDocumento;

{ Dialogo modal con la historia completa de un documento (F5): fecha, evento,
  usuario y detalle, el mas reciente primero. Se crea por codigo (sin .dfm) y no
  accede a datos: quien lo abre le entrega los eventos. Colores de UTema.
  Codigo en ASCII. }

interface

uses
  UTema, UTrazabilidad;

procedure MostrarHistoria(const Titulo: string; const Eventos: TArray<TEventoDoc>;
  HayMas: Boolean; const Tema: TTemaColores);

{ Texto de una fecha de evento para las listas ('dd/mm/yyyy hh:nn'). }
function TextoFechaEvento(F: TDateTime): string;

implementation

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Graphics;

function TextoFechaEvento(F: TDateTime): string;
begin
  Result := FormatDateTime('dd/mm/yyyy hh:nn', F);
end;

procedure MostrarHistoria(const Titulo: string; const Eventos: TArray<TEventoDoc>;
  HayMas: Boolean; const Tema: TTemaColores);
const
  FUENTE = 'Segoe UI';
var
  Dlg: TForm;
  Lbl, Aviso: TLabel;
  Lista: TListView;
  Pie: TPanel;
  Cerrar: TButton;
  Item: TListItem;
  I: Integer;

  procedure Col(const Cab: string; Ancho: Integer);
  begin
    with Lista.Columns.Add do
    begin
      Caption := Cab;
      Width := Ancho;
    end;
  end;

begin
  Dlg := TForm.CreateNew(nil);
  try
    Dlg.Caption := 'Historia del documento';
    Dlg.Position := poScreenCenter;
    Dlg.BorderStyle := bsSizeable;
    Dlg.ClientWidth := 720;
    Dlg.ClientHeight := 420;
    Dlg.Color := Tema.Fondo;
    Dlg.Font.Name := FUENTE;
    Dlg.Font.Size := 9;
    Dlg.Font.Color := Tema.Texto;

    Lbl := TLabel.Create(Dlg);
    Lbl.Parent := Dlg;
    Lbl.Align := alTop;
    Lbl.AlignWithMargins := True;
    Lbl.Margins.SetBounds(14, 12, 14, 4);
    Lbl.Font.Size := 11;
    Lbl.Font.Style := [fsBold];
    Lbl.Font.Color := Tema.Texto;
    Lbl.Caption := Titulo;

    Pie := TPanel.Create(Dlg);
    Pie.Parent := Dlg;
    Pie.Align := alBottom;
    Pie.Height := 48;
    Pie.BevelOuter := bvNone;
    Pie.ParentBackground := False;
    Pie.Color := Tema.Fondo;

    Cerrar := TButton.Create(Dlg);
    Cerrar.Parent := Pie;
    Cerrar.Caption := 'Cerrar';
    Cerrar.ModalResult := mrOk;
    Cerrar.Default := True;
    Cerrar.Cancel := True;
    Cerrar.SetBounds(Dlg.ClientWidth - 100, 10, 86, 28);
    Cerrar.Anchors := [akRight, akTop];

    Aviso := TLabel.Create(Dlg);
    Aviso.Parent := Pie;
    Aviso.SetBounds(14, 16, 560, 16);
    Aviso.Font.Color := Tema.TextoSuave;
    Aviso.Anchors := [akLeft, akTop, akRight];
    if HayMas then
      Aviso.Caption := 'Se muestran los eventos mas recientes; hay mas anteriores.'
    else
      Aviso.Caption := '';

    Lista := TListView.Create(Dlg);
    Lista.Parent := Dlg;
    Lista.Align := alClient;
    Lista.AlignWithMargins := True;
    Lista.Margins.SetBounds(14, 4, 14, 4);
    Lista.ViewStyle := vsReport;
    Lista.ReadOnly := True;
    Lista.RowSelect := True;
    Lista.StyleElements := [];
    Lista.Color := Tema.Superficie;
    Lista.Font.Color := Tema.Texto;
    Col('Fecha', 120);
    Col('Evento', 110);
    Col('Usuario', 130);
    Col('Detalle', 330);

    if Length(Eventos) = 0 then
    begin
      Item := Lista.Items.Add;
      Item.Caption := '';
      Item.SubItems.Add('Sin eventos registrados');
      Item.SubItems.Add('');
      Item.SubItems.Add('La historia empieza cuando se instalo esta version.');
    end
    else
      for I := 0 to High(Eventos) do
      begin
        Item := Lista.Items.Add;
        Item.Caption := TextoFechaEvento(Eventos[I].Fecha);
        Item.SubItems.Add(EtiquetaEvento(Eventos[I].Tipo));
        Item.SubItems.Add(Eventos[I].Usuario);
        Item.SubItems.Add(Eventos[I].Detalle);
      end;
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

end.
