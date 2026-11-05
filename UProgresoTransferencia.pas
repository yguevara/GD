unit UProgresoTransferencia;

{ Ventana de progreso de subida/descarga de un fichero, construida por codigo
  (sin .dfm) con la paleta de UTema. No bloquea la aplicacion: cada aviso de
  progreso procesa los mensajes pendientes, de modo que el boton Cancelar
  responde. Se cierra sola al destruirse. }

interface

uses
  System.Classes, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Graphics;

type
  TProgresoTransferencia = class(TForm)
  private
    FTitulo, FArchivo: TLabel;
    FBarra: TProgressBar;
    FEstado: TLabel;
    FCancelar: TButton;
    FCancelado: Boolean;
    FVentanas: Pointer;
    procedure AlCancelar(Sender: TObject);
  public
    constructor Create(AOwner: TComponent; const Titulo, Archivo: string); reintroduce;
    destructor Destroy; override;
    { Compatible con TProgresoEvento: Actualizar(Hecho, Total, Cancelar) }
    procedure Actualizar(Hecho, Total: Int64; var Cancelar: Boolean);
    property Cancelado: Boolean read FCancelado;
  end;

implementation

uses
  System.SysUtils, UTema;

const
  MB = 1024 * 1024;

constructor TProgresoTransferencia.Create(AOwner: TComponent; const Titulo, Archivo: string);
var
  T: TTemaColores;
begin
  inherited CreateNew(AOwner);
  T := TemaClaro;
  BorderStyle := bsDialog;
  BorderIcons := [];
  Position := poScreenCenter;
  Caption := 'ArchiGenio';
  ClientWidth := 440;
  ClientHeight := 150;
  Color := T.Fondo;
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  FTitulo := TLabel.Create(Self);
  FTitulo.Parent := Self;
  FTitulo.SetBounds(20, 16, 400, 20);
  FTitulo.Font.Style := [fsBold];
  FTitulo.Font.Size := 11;
  FTitulo.Caption := Titulo;

  FArchivo := TLabel.Create(Self);
  FArchivo.Parent := Self;
  FArchivo.SetBounds(20, 44, 400, 18);
  FArchivo.AutoSize := False;
  FArchivo.EllipsisPosition := epPathEllipsis;
  FArchivo.Caption := Archivo;

  FBarra := TProgressBar.Create(Self);
  FBarra.Parent := Self;
  FBarra.SetBounds(20, 70, 400, 18);
  FBarra.Max := 1000;

  FEstado := TLabel.Create(Self);
  FEstado.Parent := Self;
  FEstado.SetBounds(20, 100, 300, 18);

  FCancelar := TButton.Create(Self);
  FCancelar.Parent := Self;
  FCancelar.SetBounds(330, 104, 90, 28);
  FCancelar.Caption := 'Cancelar';
  FCancelar.OnClick := AlCancelar;
end;

destructor TProgresoTransferencia.Destroy;
begin
  // reactiva las ventanas que se deshabilitaron mientras duraba la operacion
  if FVentanas <> nil then
    EnableTaskWindows(FVentanas);
  inherited;
end;

procedure TProgresoTransferencia.AlCancelar(Sender: TObject);
begin
  FCancelado := True;
  FCancelar.Enabled := False;
  FEstado.Caption := 'Cancelando...';
end;

procedure TProgresoTransferencia.Actualizar(Hecho, Total: Int64; var Cancelar: Boolean);
begin
  if not Visible then
  begin
    Show;
    // Durante la operacion no se puede tocar el resto de la aplicacion (el dataset
    // del documento esta en edicion): solo esta ventana responde
    if FVentanas = nil then
      FVentanas := DisableTaskWindows(Handle);
  end;
  if Total > 0 then
  begin
    FBarra.Position := Integer((Hecho * 1000) div Total);
    FEstado.Caption := Format('%.1f de %.1f MB', [Hecho / MB, Total / MB]);
  end;
  Application.ProcessMessages;
  if FCancelado then
    Cancelar := True;
end;

end.
