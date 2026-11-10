unit URecepcionArchivos;

{ Recepcion de archivos arrastrados desde el Explorador sobre un control.
  Usa el protocolo OLE de arrastre (IDropTarget) para saber cuando el arrastre
  entra y sale del control (por ejemplo para mostrar zonas de soltar) y no solo
  cuando se suelta. Solo atiende archivos y carpetas (formato CF_HDROP): texto u
  otros datos se ignoran. FiltrarRutas es pura (sin VCL). Codigo en ASCII. }

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, Winapi.Messages, Winapi.ActiveX,
  Winapi.ShellAPI, Vcl.Controls;

type
  TSoltarEvent = procedure(const Rutas: TArray<string>) of object;

  TRecepcionArchivos = class;

  { Parte del componente que habla con OLE; el componente no cuenta referencias. }
  TDestinoSoltar = class(TInterfacedObject, IDropTarget)
  private
    FDuenio: TRecepcionArchivos;
    FEntro: Boolean;     // el arrastre actual trae archivos y se acepto
    function HayArchivos(const Datos: IDataObject): Boolean;
    function LeerRutas(const Datos: IDataObject): TArray<string>;
  public
    constructor Create(ADuenio: TRecepcionArchivos);
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
  end;

  TRecepcionArchivos = class(TComponent)
  private
    FControl: TWinControl;
    FDestino: IDropTarget;
    FRegistrado: Boolean;
    FActivo: Boolean;
    FOnEntrar: TNotifyEvent;
    FOnSalir: TNotifyEvent;
    FOnSoltar: TSoltarEvent;
    FAnteriorWndProc: TWndMethod;
    procedure ControlWndProc(var Mensaje: TMessage);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  private
    procedure Entrar;
    procedure Salir;
    procedure Soltado(const Rutas: TArray<string>);
  public
    { Control debe tener ventana (estar ya dentro de un formulario). }
    constructor Crear(AOwner: TComponent; Control: TWinControl);
    destructor Destroy; override;
    { Registra el control como destino de arrastre; se llama sola al crear. }
    procedure Registrar;
    { Hace lo mismo que un soltado real (pruebas). }
    procedure SimularSoltar(const Rutas: TArray<string>);
    { Con Activo = False no se acepta nada (el cursor muestra que no se puede soltar). }
    property Activo: Boolean read FActivo write FActivo;
    { True si el control esta registrado ahora como destino de arrastre. }
    property Registrado: Boolean read FRegistrado;
    property OnEntrar: TNotifyEvent read FOnEntrar write FOnEntrar;
    property OnSalir: TNotifyEvent read FOnSalir write FOnSalir;
    property OnSoltar: TSoltarEvent read FOnSoltar write FOnSoltar;
  end;

{ De las Rutas, las que existen y, si se piden Extensiones (sin punto, sin
  distinguir mayusculas), tienen una de ellas. Sin Extensiones se aceptan
  archivos y carpetas; con ellas, las carpetas no. Las demas van a Rechazadas. }
function FiltrarRutas(const Rutas, Extensiones: TArray<string>;
  out Rechazadas: TArray<string>): TArray<string>;

implementation

uses
  System.IOUtils;

var
  GOleIniciado: Boolean = False;

{ OleInitialize una sola vez por proceso (el VCL ya lo hace al arrancar la
  aplicacion; en las pruebas de consola no). S_FALSE significa que ya estaba. }
procedure IniciarOle;
begin
  if not GOleIniciado then
  begin
    GOleIniciado := True;
    OleInitialize(nil);
  end;
end;

function FiltrarRutas(const Rutas, Extensiones: TArray<string>;
  out Rechazadas: TArray<string>): TArray<string>;
var
  I, J, NA, NR: Integer;
  Ext: string;
  Pasa: Boolean;
begin
  SetLength(Result, Length(Rutas));
  SetLength(Rechazadas, Length(Rutas));
  NA := 0;
  NR := 0;
  for I := 0 to High(Rutas) do
  begin
    Pasa := False;
    if TFile.Exists(Rutas[I]) then
    begin
      if Length(Extensiones) = 0 then
        Pasa := True
      else
      begin
        Ext := LowerCase(ExtractFileExt(Rutas[I]));
        if (Ext <> '') and (Ext[1] = '.') then
          Delete(Ext, 1, 1);
        for J := 0 to High(Extensiones) do
          if SameText(Ext, Extensiones[J]) then
            Pasa := True;
      end;
    end
    else if (Length(Extensiones) = 0) and TDirectory.Exists(Rutas[I]) then
      Pasa := True;
    if Pasa then
    begin
      Result[NA] := Rutas[I];
      Inc(NA);
    end
    else
    begin
      Rechazadas[NR] := Rutas[I];
      Inc(NR);
    end;
  end;
  SetLength(Result, NA);
  SetLength(Rechazadas, NR);
end;

{ TDestinoSoltar }

constructor TDestinoSoltar.Create(ADuenio: TRecepcionArchivos);
begin
  inherited Create;
  FDuenio := ADuenio;
end;

function TDestinoSoltar.HayArchivos(const Datos: IDataObject): Boolean;
var
  F: TFormatEtc;
begin
  F.cfFormat := CF_HDROP;
  F.ptd := nil;
  F.dwAspect := DVASPECT_CONTENT;
  F.lindex := -1;
  F.tymed := TYMED_HGLOBAL;
  Result := (Datos <> nil) and (Datos.QueryGetData(F) = S_OK);
end;

function TDestinoSoltar.LeerRutas(const Datos: IDataObject): TArray<string>;
var
  F: TFormatEtc;
  M: TStgMedium;
  N, I, L: Integer;
  Buf: string;
begin
  Result := nil;
  F.cfFormat := CF_HDROP;
  F.ptd := nil;
  F.dwAspect := DVASPECT_CONTENT;
  F.lindex := -1;
  F.tymed := TYMED_HGLOBAL;
  if Datos.GetData(F, M) <> S_OK then
    Exit;
  try
    N := DragQueryFile(M.hGlobal, $FFFFFFFF, nil, 0);
    SetLength(Result, N);
    for I := 0 to N - 1 do
    begin
      L := DragQueryFile(M.hGlobal, I, nil, 0);
      SetLength(Buf, L);
      DragQueryFile(M.hGlobal, I, PChar(Buf), L + 1);
      Result[I] := Buf;
    end;
  finally
    ReleaseStgMedium(M);
  end;
end;

function TDestinoSoltar.DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
  pt: TPoint; var dwEffect: Longint): HResult;
begin
  FEntro := (FDuenio <> nil) and FDuenio.FActivo and HayArchivos(dataObj);
  if FEntro then
  begin
    dwEffect := DROPEFFECT_COPY;
    FDuenio.Entrar;
  end
  else
    dwEffect := DROPEFFECT_NONE;
  Result := S_OK;
end;

function TDestinoSoltar.DragOver(grfKeyState: Longint; pt: TPoint;
  var dwEffect: Longint): HResult;
begin
  // el cursor de copiar solo si lo que se arrastra son archivos y se acepta
  if FEntro and (FDuenio <> nil) and FDuenio.FActivo then
    dwEffect := DROPEFFECT_COPY
  else
    dwEffect := DROPEFFECT_NONE;
  Result := S_OK;
end;

function TDestinoSoltar.DragLeave: HResult;
begin
  if FEntro and (FDuenio <> nil) then
    FDuenio.Salir;
  FEntro := False;
  Result := S_OK;
end;

function TDestinoSoltar.Drop(const dataObj: IDataObject; grfKeyState: Longint;
  pt: TPoint; var dwEffect: Longint): HResult;
var
  Rutas: TArray<string>;
  Yo: IDropTarget;
begin
  if FEntro and (FDuenio <> nil) then
    FDuenio.Salir;
  FEntro := False;
  dwEffect := DROPEFFECT_NONE;
  if (FDuenio <> nil) and FDuenio.FActivo and HayArchivos(dataObj) then
  begin
    Rutas := LeerRutas(dataObj);
    if Length(Rutas) > 0 then
    begin
      dwEffect := DROPEFFECT_COPY;
      // El trabajo (ventanas modales, subidas) no corre dentro de la llamada OLE:
      // el Explorador, que arrastra, quedaria congelado y una excepcion se
      // perderia. Se encola y la llamada vuelve enseguida. La referencia a este
      // destino lo mantiene vivo hasta que se ejecute.
      Yo := Self;
      TThread.ForceQueue(nil,
        procedure
        var
          D: TDestinoSoltar;
        begin
          D := TDestinoSoltar(Yo as TObject);
          if D.FDuenio <> nil then
            D.FDuenio.Soltado(Rutas);
        end);
    end;
  end;
  Result := S_OK;
end;

{ TRecepcionArchivos }

constructor TRecepcionArchivos.Crear(AOwner: TComponent; Control: TWinControl);
begin
  inherited Create(AOwner);
  FControl := Control;
  FActivo := True;
  FDestino := TDestinoSoltar.Create(Self);
  // Un control puede recrear su ventana (cambio de estilo, DPI...): la
  // registracion se pierde con ella, asi que se vigila para repetirla.
  FAnteriorWndProc := FControl.WindowProc;
  FControl.WindowProc := ControlWndProc;
  // si el control se libera antes que este componente (mismo duenio), no se le
  // vuelve a tocar
  FControl.FreeNotification(Self);
  Registrar;
end;

procedure TRecepcionArchivos.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FControl) then
  begin
    FControl := nil;
    FRegistrado := False;
    FAnteriorWndProc := nil;
  end;
end;

procedure TRecepcionArchivos.ControlWndProc(var Mensaje: TMessage);
begin
  if (Mensaje.Msg = WM_DESTROY) and FRegistrado then
  begin
    RevokeDragDrop(FControl.Handle);
    FRegistrado := False;
  end;
  FAnteriorWndProc(Mensaje);
  if Mensaje.Msg = WM_CREATE then
    Registrar;
end;

procedure TRecepcionArchivos.Registrar;
begin
  if FRegistrado or (FControl = nil) then
    Exit;
  IniciarOle;
  try
    FControl.HandleNeeded;
    if Succeeded(RegisterDragDrop(FControl.Handle, FDestino)) then
      FRegistrado := True;
  except
    // sin ventana todavia: se puede volver a llamar a Registrar
    FRegistrado := False;
  end;
end;

destructor TRecepcionArchivos.Destroy;
begin
  // se quita el vigilante solo si sigue siendo este (otro pudo instalarse encima)
  if Assigned(FAnteriorWndProc) and (FControl <> nil) and
    (TMethod(FControl.WindowProc).Data = Pointer(Self)) then
    FControl.WindowProc := FAnteriorWndProc;
  if FRegistrado and (FControl <> nil) and FControl.HandleAllocated then
    RevokeDragDrop(FControl.Handle);
  // el destino ya no debe avisar a un componente liberado
  TDestinoSoltar(FDestino as TObject).FDuenio := nil;
  FDestino := nil;
  inherited Destroy;
end;

procedure TRecepcionArchivos.Entrar;
begin
  if Assigned(FOnEntrar) then
    FOnEntrar(Self);
end;

procedure TRecepcionArchivos.Salir;
begin
  if Assigned(FOnSalir) then
    FOnSalir(Self);
end;

procedure TRecepcionArchivos.Soltado(const Rutas: TArray<string>);
begin
  if FActivo and (Length(Rutas) > 0) and Assigned(FOnSoltar) then
    FOnSoltar(Rutas);
end;

procedure TRecepcionArchivos.SimularSoltar(const Rutas: TArray<string>);
begin
  Soltado(Rutas);
end;

end.
