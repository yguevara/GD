unit MAIN;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, FireDAC.Phys.MSAccDef,
  FireDAC.Phys.MSSQLDef, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSAcc,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  Vcl.Grids, Vcl.DBGrids, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Comp.UI, FireDAC.Phys.MSSQL, FireDAC.Phys.ODBCBase, cxGraphics,
  cxControls, cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsDefaultPainters, cxClasses, dxNavBarBase, dxNavBarCollns, dxNavBar,
  dxBarBuiltInMenu, dxNavBarOfficeNavigationBar;

type
  TForm1 = class(TForm)
    btnConfig: TButton;
    MSAccessDriver: TFDPhysMSAccessDriverLink;
    FDPhysMSSQLDriverLink1: TFDPhysMSSQLDriverLink;
    WaitCursor: TFDGUIxWaitCursor;
    Conn: TFDConnection;
    cmd: TFDMetaInfoQuery;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    ComboBox1: TComboBox;
    Button1: TButton;
    Button2: TButton;
    dxNavBar1: TdxNavBar;
    dxNavBar1Group1: TdxNavBarGroup;
    Button3: TButton;
    procedure btnConfigClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnConfigClick(Sender: TObject);
var
  List:TStringList;
begin
  cmd.Active:=True;
  cmd.First;
  List:=TStringList.Create;
  while not cmd.Eof do begin
    List.Add(cmd.FieldByName('TABLE_NAME').AsString);
    cmd.Next;
  end;
  List.SaveToFile('C:\py\Listado_Tablas.txt');
  ShowMessage('yaaaaa');
end;

procedure TForm1.Button1Click(Sender: TObject);
function ListSQLServers: TStringList;
var
  SL: TStringList;
  Cmd: string;
  ServerOutput: THandle;
  SecurityAttributes: TSecurityAttributes;
  ReadPipe, WritePipe: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: array[0..255] of Char;
  BytesRead: DWORD;
begin
  SL := TStringList.Create;
  try
    // Configuración de las tuberías de seguridad
    ZeroMemory(@SecurityAttributes, SizeOf(SecurityAttributes));
    SecurityAttributes.nLength := SizeOf(SecurityAttributes);
    SecurityAttributes.bInheritHandle := True;

    // Crear las tuberías de lectura y escritura
    if not CreatePipe(ReadPipe, WritePipe, @SecurityAttributes, 0) then
      raise Exception.Create('Error al crear las tuberías de la consola');

    // Configurar la información del proceso
    ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
    StartupInfo.cb := SizeOf(StartupInfo);
    StartupInfo.hStdOutput := WritePipe;
    StartupInfo.hStdError := WritePipe;
    StartupInfo.dwFlags := STARTF_USESTDHANDLES;

    ZeroMemory(@ProcessInfo, SizeOf(ProcessInfo));

    // Ejecutar el comando sqlcmd para listar servidores SQL
    Cmd := 'sqlcmd -L';

    if not CreateProcess(nil, PChar(Cmd), nil, nil, True, 0, nil, nil, StartupInfo, ProcessInfo) then
      raise Exception.Create('No se pudo ejecutar sqlcmd');

    CloseHandle(WritePipe);

    // Leer la salida del comando
    ServerOutput := ReadPipe;
    try
      repeat
        ZeroMemory(@Buffer, SizeOf(Buffer));
        if not ReadFile(ServerOutput, Buffer, SizeOf(Buffer), BytesRead, nil) then Break;
        SL.Text := SL.Text + Buffer;
      until BytesRead = 0;
    finally
      CloseHandle(ServerOutput);
    end;

    // Procesar y limpiar la salida
    SL.Text := StringReplace(SL.Text, #13#10, #10, [rfReplaceAll]);
    SL.Text := StringReplace(SL.Text, 'Servers:', '', [rfReplaceAll]);
    SL.Text := Trim(SL.Text);
  finally
    Result := SL;
  end;
end;
begin
  ComboBox1.Items.Assign(ListSQLServers);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  List, List1, noEsta:TStringList;
  i:integer;
begin
  List:=TStringList.Create;
  List1:=TStringList.Create;
  noEsta:=TStringList.Create;
  List.LoadFromFile('C:\py\Listado_Tablas.txt');
  List1.LoadFromFile('C:\py\Listado_Tablas1.txt');
  for i := 0 to List1.Count-1 do
  begin
    if List.IndexOf(List1[i])=-1 then
      noEsta.Add(List1[i]);

  end;
  noEsta.SaveToFile('C:\py\NoEsta.txt');
  ShowMessage('yaaaaaaaa');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  dxNavBar1.OptionsBehavior.NavigationPane.Collapsed:=not dxNavBar1.OptionsBehavior.NavigationPane.Collapsed;
end;

end.
