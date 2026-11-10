unit UVisorContenido;

{ Visor del contenido (PDF) de un documento dentro de la aplicacion, que se puede
  sacar a una ventana aparte y volver a incorporar. Solo muestra: no ofrece
  guardar, imprimir ni copiar (igual que PDFExpressViewer.exe). No accede a datos:
  quien lo usa le entrega la ruta de un archivo PDF local. Se crea por codigo.
  Usa ExpressPDFViewer (DevExpress). Colores de UTema. Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Forms, Vcl.Graphics,
  dxPDFViewer, UTema;

type
  TVisorContenido = class(TPanel)
  private
    FTema: TTemaColores;
    FConstruido: Boolean;
    FVisor: TdxPDFViewer;
    FMensaje: TLabel;
    FBarra: TPanel;
    FBtnSeparar: TButton;
    FArchivo: string;
    FTitulo: string;
    FVentana: TForm;
    FEnVentana: Boolean;
    procedure Construir;
    procedure SepararClick(Sender: TObject);
    procedure VentanaCerrada(Sender: TObject; var Action: TCloseAction);
    procedure ActualizarBoton;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Muestra el PDF de esa ruta; si no se puede abrir muestra el motivo. }
    procedure Mostrar(const ArchivoPdf, Titulo: string);
    { Solo un texto (sin documento, sin PDF, o error). Quita el documento. }
    procedure MostrarMensaje(const Texto: string);
    { Quita el documento mostrado, sin mensaje. }
    procedure Limpiar;
    { Mueve el visor a una ventana aparte. Sin documento no hace nada. }
    procedure Separar;
    { Trae el visor de vuelta a la aplicacion y cierra la ventana aparte. }
    procedure Reincorporar;
    property Separado: Boolean read FEnVentana;
    property Archivo: string read FArchivo;
    { Donde esta ahora el visor: este panel o la ventana aparte (pruebas). }
    function ContenedorDelVisor: TWinControl;
    function TextoMensaje: string;
  end;

implementation

uses
  UShellPrincipal;

const
  FUENTE = 'Segoe UI';

constructor TVisorContenido.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if TemaWindowsOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
end;

destructor TVisorContenido.Destroy;
begin
  // la ventana aparte contiene el visor: se cierra antes de liberar el panel
  if FVentana <> nil then
  begin
    FVentana.OnClose := nil;
    FVisor.Parent := Self;
    FreeAndNil(FVentana);
  end;
  inherited Destroy;
end;

procedure TVisorContenido.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not FConstruido then
  begin
    FConstruido := True;
    Construir;
  end;
end;

procedure TVisorContenido.Construir;
begin
  BevelOuter := bvNone;
  ParentBackground := False;
  StyleElements := [];
  ShowCaption := False;
  Color := FTema.Superficie;

  FBarra := TPanel.Create(Self);
  FBarra.Parent := Self;
  FBarra.Align := alTop;
  FBarra.Height := 36;
  FBarra.BevelOuter := bvNone;
  FBarra.ParentBackground := False;
  FBarra.StyleElements := [];
  FBarra.ShowCaption := False;
  FBarra.Color := FTema.Superficie;

  FBtnSeparar := TButton.Create(Self);
  FBtnSeparar.Parent := FBarra;
  FBtnSeparar.Align := alRight;
  FBtnSeparar.Width := 150;
  FBtnSeparar.AlignWithMargins := True;
  FBtnSeparar.Margins.SetBounds(6, 5, 12, 5);
  FBtnSeparar.OnClick := SepararClick;

  FMensaje := TLabel.Create(Self);
  FMensaje.Parent := Self;
  FMensaje.Align := alClient;
  FMensaje.AlignWithMargins := True;
  FMensaje.Margins.SetBounds(16, 20, 16, 16);
  FMensaje.WordWrap := True;
  FMensaje.Transparent := True;
  FMensaje.StyleElements := [];
  FMensaje.Font.Name := FUENTE;
  FMensaje.Font.Size := 9;
  FMensaje.Font.Color := FTema.TextoSuave;
  FMensaje.Layout := tlTop;

  FVisor := TdxPDFViewer.Create(Self);
  FVisor.Parent := Self;
  FVisor.Align := alClient;
  FVisor.Visible := False;

  ActualizarBoton;
end;

procedure TVisorContenido.ActualizarBoton;
begin
  if FEnVentana then
  begin
    FBtnSeparar.Caption := 'Volver a la aplicacion';
    FBtnSeparar.Enabled := True;
  end
  else
  begin
    FBtnSeparar.Caption := 'Mostrar aparte';
    FBtnSeparar.Enabled := FArchivo <> '';
  end;
end;

procedure TVisorContenido.Mostrar(const ArchivoPdf, Titulo: string);
begin
  if not FileExists(ArchivoPdf) then
  begin
    MostrarMensaje('No se encontro el archivo del contenido.');
    Exit;
  end;
  try
    FVisor.LoadFromFile(ArchivoPdf);
  except
    on E: Exception do
    begin
      MostrarMensaje('No se pudo mostrar el contenido: ' + E.Message);
      Exit;
    end;
  end;
  FArchivo := ArchivoPdf;
  FTitulo := Titulo;
  FMensaje.Visible := False;
  FVisor.Visible := True;
  if FVentana <> nil then
    FVentana.Caption := 'Contenido - ' + Titulo;
  ActualizarBoton;
end;

procedure TVisorContenido.MostrarMensaje(const Texto: string);
begin
  Limpiar;
  FMensaje.Caption := Texto;
  FMensaje.Visible := True;
  if FEnVentana then
    Reincorporar;
end;

procedure TVisorContenido.Limpiar;
begin
  FArchivo := '';
  FTitulo := '';
  FMensaje.Caption := '';
  try
    FVisor.Clear;
  except
    // un visor sin documento no tiene nada que quitar
  end;
  FVisor.Visible := False;
  FMensaje.Visible := True;
  ActualizarBoton;
end;

procedure TVisorContenido.Separar;
begin
  if FEnVentana or (FArchivo = '') then
    Exit;
  FVentana := TForm.CreateNew(Application);
  FVentana.Caption := 'Contenido - ' + FTitulo;
  FVentana.SetBounds(120, 80, 900, 700);
  FVentana.Position := poScreenCenter;
  FVentana.OnClose := VentanaCerrada;
  FVisor.Parent := FVentana;
  FVisor.Align := alClient;
  FEnVentana := True;
  FMensaje.Caption := 'El contenido esta en una ventana aparte.';
  FMensaje.Visible := True;
  FVentana.Show;
  ActualizarBoton;
end;

procedure TVisorContenido.Reincorporar;
var
  V: TForm;
begin
  if not FEnVentana then
    Exit;
  FEnVentana := False;
  V := FVentana;
  FVentana := nil;
  if V <> nil then
    V.OnClose := nil;
  FVisor.Parent := Self;
  FVisor.Align := alClient;
  FMensaje.Visible := FArchivo = '';
  FVisor.Visible := FArchivo <> '';
  if V <> nil then
    V.Release;
  ActualizarBoton;
end;

procedure TVisorContenido.VentanaCerrada(Sender: TObject; var Action: TCloseAction);
begin
  // cerrar la ventana aparte equivale a volver a la aplicacion
  Action := caNone;
  Reincorporar;
end;

procedure TVisorContenido.SepararClick(Sender: TObject);
begin
  if FEnVentana then
    Reincorporar
  else
    Separar;
end;

function TVisorContenido.ContenedorDelVisor: TWinControl;
begin
  Result := FVisor.Parent;
end;

function TVisorContenido.TextoMensaje: string;
begin
  if FMensaje.Visible then
    Result := FMensaje.Caption
  else
    Result := '';
end;

end.
