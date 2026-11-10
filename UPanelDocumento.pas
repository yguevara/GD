unit UPanelDocumento;

{ Panel del documento seleccionado: cabecera (codigo, titulo y estado) y una
  pestana por tipo de informacion: Datos, Ubicacion, Archivos, Metadatos,
  Historia y Contenido. Se crea por codigo (sin .dfm) y no accede a datos:
  quien lo usa llena cada pagina (Pagina) y le indica el estado y el numero de
  archivos. Reutiliza la tira de pestanas de UPanelLateral. Colores de UTema.
  Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Vcl.Controls, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Graphics, UTema, UDocumentoVista, UPanelLateral;

type
  TPanelDocumento = class(TPanel)
  private
    FTema: TTemaColores;
    FConstruido: Boolean;
    FCabecera: TPanel;
    FLblCodigo: TLabel;
    FLblEstado: TLabel;
    FLblTitulo: TLabel;
    FTira: TTiraPestanas;
    FPaginas: array[TPestanaDoc] of TPanel;
    FActiva: TPestanaDoc;
    FOnCambioPestana: TNotifyEvent;
    procedure Construir;
    procedure TiraElegir(Sender: TObject);
    procedure MostrarActiva;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
    { Contenedor de una pestana: quien usa el panel pone ahi sus controles. }
    function Pagina(P: TPestanaDoc): TPanel;
    procedure Activar(P: TPestanaDoc);
    property Activa: TPestanaDoc read FActiva;
    { Codigo vacio: "Sin documento". El estado solo se muestra si se conoce. }
    procedure FijarCabecera(const Codigo, Titulo: string; Estado: TEstadoDoc);
    { Numero de archivos del documento junto al nombre de la pestana Archivos. }
    procedure FijarConteoArchivos(N: Integer);
    function TextoCodigo: string;
    function TextoEstado: string;
    function TituloPestana(P: TPestanaDoc): string;
    property OnCambioPestana: TNotifyEvent read FOnCambioPestana write FOnCambioPestana;
  end;

implementation

uses
  UShellPrincipal;

const
  FUENTE = 'Segoe UI';

constructor TPanelDocumento.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if TemaWindowsOscuro then
    FTema := TemaOscuro
  else
    FTema := TemaClaro;
end;

procedure TPanelDocumento.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  if (AParent <> nil) and not FConstruido then
  begin
    FConstruido := True;
    Construir;
  end;
end;

procedure TPanelDocumento.Construir;
var
  P: TPestanaDoc;
begin
  BevelOuter := bvNone;
  ParentBackground := False;
  StyleElements := [];
  ShowCaption := False;
  Color := FTema.Superficie;

  FCabecera := TPanel.Create(Self);
  FCabecera.Parent := Self;
  FCabecera.Align := alTop;
  FCabecera.Height := 58;
  FCabecera.BevelOuter := bvNone;
  FCabecera.ParentBackground := False;
  FCabecera.StyleElements := [];
  FCabecera.ShowCaption := False;
  FCabecera.Color := FTema.Superficie;

  FLblEstado := TLabel.Create(Self);
  FLblEstado.Parent := FCabecera;
  FLblEstado.Align := alRight;
  FLblEstado.AlignWithMargins := True;
  FLblEstado.Margins.SetBounds(6, 8, 14, 32);
  FLblEstado.Transparent := False;
  FLblEstado.StyleElements := [];
  FLblEstado.Font.Name := FUENTE;
  FLblEstado.Font.Size := 9;
  FLblEstado.Font.Color := FTema.Acento;
  FLblEstado.Color := FTema.AcentoSuave;
  FLblEstado.Layout := tlCenter;

  FLblCodigo := TLabel.Create(Self);
  FLblCodigo.Parent := FCabecera;
  FLblCodigo.Align := alClient;
  FLblCodigo.AlignWithMargins := True;
  FLblCodigo.Margins.SetBounds(14, 8, 6, 32);
  FLblCodigo.Transparent := True;
  FLblCodigo.StyleElements := [];
  FLblCodigo.EllipsisPosition := epEndEllipsis;
  FLblCodigo.Layout := tlCenter;
  FLblCodigo.Font.Name := FUENTE;
  FLblCodigo.Font.Size := 11;
  FLblCodigo.Font.Style := [fsBold];
  FLblCodigo.Font.Color := FTema.Texto;

  FLblTitulo := TLabel.Create(Self);
  FLblTitulo.Parent := FCabecera;
  FLblTitulo.AutoSize := False;
  FLblTitulo.SetBounds(14, 30, 300, 20);
  FLblTitulo.Anchors := [akLeft, akTop, akRight];
  FLblTitulo.Transparent := True;
  FLblTitulo.StyleElements := [];
  FLblTitulo.EllipsisPosition := epEndEllipsis;
  FLblTitulo.Font.Name := FUENTE;
  FLblTitulo.Font.Size := 9;
  FLblTitulo.Font.Color := FTema.TextoSuave;

  FTira := TTiraPestanas.Create(Self);
  FTira.Parent := Self;
  FTira.Align := alTop;
  FTira.Configurar(FTema);
  FTira.Agregar('Datos');
  FTira.Agregar('Ubicacion');
  FTira.Agregar('Archivos');
  FTira.Agregar('Metadatos');
  FTira.Agregar('Historia');
  FTira.Agregar('Contenido');
  FTira.OnElegir := TiraElegir;

  for P := Low(TPestanaDoc) to High(TPestanaDoc) do
  begin
    FPaginas[P] := TPanel.Create(Self);
    FPaginas[P].Parent := Self;
    FPaginas[P].Align := alClient;
    FPaginas[P].BevelOuter := bvNone;
    FPaginas[P].ParentBackground := False;
    FPaginas[P].StyleElements := [];
    FPaginas[P].ShowCaption := False;
    FPaginas[P].Color := FTema.Superficie;
  end;
  MostrarActiva;
  FijarCabecera('', '', edDesconocido);
end;

function TPanelDocumento.Pagina(P: TPestanaDoc): TPanel;
begin
  Result := FPaginas[P];
end;

procedure TPanelDocumento.MostrarActiva;
var
  P: TPestanaDoc;
begin
  for P := Low(TPestanaDoc) to High(TPestanaDoc) do
    if FPaginas[P] <> nil then
      FPaginas[P].Visible := P = FActiva;
end;

procedure TPanelDocumento.Activar(P: TPestanaDoc);
begin
  if P = FActiva then
    Exit;
  FActiva := P;
  FTira.Activa := Ord(P);
  MostrarActiva;
  if Assigned(FOnCambioPestana) then
    FOnCambioPestana(Self);
end;

procedure TPanelDocumento.TiraElegir(Sender: TObject);
begin
  if Ord(FActiva) <> FTira.Activa then
  begin
    FActiva := TPestanaDoc(FTira.Activa);
    MostrarActiva;
    if Assigned(FOnCambioPestana) then
      FOnCambioPestana(Self);
  end;
end;

procedure TPanelDocumento.FijarCabecera(const Codigo, Titulo: string;
  Estado: TEstadoDoc);
begin
  if Trim(Codigo) = '' then
  begin
    FLblCodigo.Caption := 'Sin documento';
    FLblTitulo.Caption := '';
  end
  else
  begin
    FLblCodigo.Caption := Trim(Codigo);
    FLblTitulo.Caption := Trim(Titulo);
  end;
  FLblEstado.Caption := ' ' + TextoEstadoDoc(Estado) + ' ';
  FLblEstado.Visible := (Trim(Codigo) <> '') and (Estado <> edDesconocido);
end;

procedure TPanelDocumento.FijarConteoArchivos(N: Integer);
begin
  if N > 0 then
    FTira.Retitular(Ord(pdArchivos), 'Archivos ' + IntToStr(N))
  else
    FTira.Retitular(Ord(pdArchivos), 'Archivos');
end;

function TPanelDocumento.TextoCodigo: string;
begin
  Result := FLblCodigo.Caption;
end;

function TPanelDocumento.TextoEstado: string;
begin
  if FLblEstado.Visible then
    Result := Trim(FLblEstado.Caption)
  else
    Result := '';
end;

function TPanelDocumento.TituloPestana(P: TPestanaDoc): string;
begin
  Result := FTira.Titulo(Ord(P));
end;

end.
