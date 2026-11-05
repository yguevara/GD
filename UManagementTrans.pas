unit UManagementTrans;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, JvExControls, JvButton, JvTransparentButton, Vcl.ExtCtrls,
  FireDAC.UI.Intf, FireDAC.VCLUI.Wait, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MSAcc, FireDAC.Phys.MSAccDef,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef, Vcl.Buttons,
  FireDAC.Phys.SQLite, FireDAC.Comp.BatchMove.DataSet, FireDAC.Comp.BatchMove,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Comp.UI,
  dxSkinsCore, dxSkinsDefaultPainters, dxBarBuiltInMenu, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, Vcl.Samples.Gauges, cxPC, Vcl.ComCtrls,
  AdvCheckTreeView, JvExExtCtrls, JvExtComponent, JvCaptionPanel, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  dxDateRanges, cxDBData, cxDBLookupComboBox, cxBlobEdit, cxGridLevel,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxClasses,
  cxGridCustomView, cxGrid, cxVGrid, cxDBVGrid, cxInplaceContainer,
  FireDAC.Stan.StorageBin, AdvSplitter, Vcl.Grids, Vcl.DBGrids, Vcl.Menus,
  AdvMenus, AdvPanel, winapi.shellapi, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase, IdFTP, System.Zip,
  strutils;

type
  TfrmTrans = class(TForm)
    pMainContainer: TPanel;
    btnClose: TJvTransparentButton;
    btnImport: TJvTransparentButton;
    btnExport: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    Edit1: TEdit;
    WAIT: TFDGUIxWaitCursor;
    SQLConn: TFDConnection;
    Origen: TFDQuery;
    SQLiteDriver: TFDPhysSQLiteDriverLink;
    SD: TSaveDialog;
    OD: TOpenDialog;
    PDetalles: TPanel;
    jvcpInformation: TJvCaptionPanel;
    pADF: TPanel;
    Panel3: TPanel;
    tvTreechk: TAdvCheckTreeView;
    Marcadas: TFDMemTable;
    AdvSplitter1: TAdvSplitter;
    DataSource1: TDataSource;
    PLoadAndSaveIndexFile: TPanel;
    btnFindInforme: TSpeedButton;
    edt1: TEdit;
    lblTitle: TLabel;
    tb_indiceinfo: TFDMemTable;
    tb_indiceinfoidindice: TIntegerField;
    tb_indiceinfoFecha: TSQLTimeStampField;
    tb_indiceinfoEstructura: TIntegerField;
    tb_indiceinfoCantsubseries: TIntegerField;
    tb_indiceinfoCantDocumentos: TIntegerField;
    tb_indiceinfoCantFuentes: TIntegerField;
    tb_indiceinfoCantFAD: TIntegerField;
    tb_indiceinfoUsuarioPC: TWideStringField;
    tb_indiceinfoPC: TWideStringField;
    tb_indiceinfousuario_sistema: TWideStringField;
    tb_indiceinforoluser: TWideStringField;
    tb_indiceinfotreeformat: TBlobField;
    dstb_indiceinfo: TDataSource;
    AdvMenuStyler2: TAdvMenuStyler;
    Destino: TFDQuery;
    AdvPanel1: TAdvPanel;
    cxDBVerticalGrid2: TcxDBVerticalGrid;
    cxDBVerticalGrid2CategoryRow1: TcxCategoryRow;
    cxDBVerticalGrid2idindice: TcxDBEditorRow;
    cxDBVerticalGrid2Fecha: TcxDBEditorRow;
    cxDBVerticalGrid2usuario_sistema: TcxDBEditorRow;
    cxDBVerticalGrid2roluser: TcxDBEditorRow;
    cxDBVerticalGrid2PC: TcxDBEditorRow;
    cxDBVerticalGrid2UsuarioPC: TcxDBEditorRow;
    cxDBVerticalGrid2CategoryRow2: TcxCategoryRow;
    cxDBVerticalGrid2Estructura: TcxDBEditorRow;
    cxDBVerticalGrid2Cantsubseries: TcxDBEditorRow;
    cxDBVerticalGrid2CantDocumentos: TcxDBEditorRow;
    cxDBVerticalGrid2CantFuentes: TcxDBEditorRow;
    cxDBVerticalGrid2CantFAD: TcxDBEditorRow;
    btnImportIndex: TButton;
    Timer1: TTimer;
    tb_treeO: TFDQuery;
    dstb_treeO: TDataSource;
    tb_SerietreeO: TFDQuery;
    dstb_SerietreeO: TDataSource;
    tb_SeriesDatosO: TFDQuery;
    dstb_SeriesDatosO: TDataSource;
    tb_ssArchdigitalO: TFDQuery;
    dstb_ssArchdigitalO: TDataSource;
    tb_DocCoordO: TFDQuery;
    dstb_DocCoordO: TDataSource;
    dstb_Serietree: TDataSource;
    dstb_tree: TDataSource;
    tb_tree: TFDQuery;
    tb_Serietree: TFDQuery;
    dstb_SeriesDatos: TDataSource;
    dstb_DocCoord: TDataSource;
    tb_DocCoord: TFDQuery;
    dstb_ssArchdigital: TDataSource;
    tb_ssArchdigital: TFDQuery;
    tb_SeriesDatos: TFDQuery;
    IdFTP1: TIdFTP;
    Gauge4: TGauge;
    Gauge3: TGauge;
    Gauge2: TGauge;
    Label1: TLabel;
    pCompact: TPanel;
    ProgressBar1: TProgressBar;
    Label2: TLabel;
    Label3: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure tvTreechkMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tvTreechkNodeCheckedChanged(Sender: TObject; Node: TTreeNode; NewState: Boolean);
    procedure btnImportClick(Sender: TObject);
    procedure pMainContainerClick(Sender: TObject);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnFindInformeClick(Sender: TObject);
    procedure btnImportIndexClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
  private
    procedure CancelarProcess;
    procedure RestableceForm;
    procedure CleanDataSet;
    procedure ReiniciaComponentes;
    { Private declarations }
  public
    { Public declarations }
    accion: string;
    TR: Integer;
    function GetAllRecordCount(cnn: TFDConnection): LongInt;
    function configTable(nombreTabla: string; dsOrigen: TFDQuery; aIdStruct: integer): boolean;
    procedure configuraIdx(dsOrigen: TFDQuery);
    procedure CopiarREG(Opt: integer);
    procedure ImportIdxREG(Opt: integer);
    procedure MarcaNodoyPadres(IdNodo: TTreenode; V: boolean);
    procedure MarcaHijos(conn: TFDConnection; IdNodo: string; V: boolean);
    procedure UpDateIdx;

    //Nuevos
    procedure DownloadFileFromFTP(const Host, Username, Password, RemoteFile, LocalFile, EsArchivo: string; Puerto: Integer);
    procedure CopyFileToFtpServer(const AServer, AUsername, APassword, ALocalFile, ARemotePath, Opts: string; Puerto: integer);
    procedure ZipDirectory(const Directory, ZipFileName: string);
    procedure UnzipFile(const ZipFileName, OutputPath: string);
    procedure ftpw(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
    procedure ftpwb(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
    procedure ftpwe(ASender: TObject; AWorkMode: TWorkMode);
    procedure OnZipProgressEvent(Sender: TObject; FileName: string; Header: TZipHeader; Position: Int64);
    procedure deshabilita(Opts: boolean);
    procedure ExportaClsif(Opt: string);
    procedure CuadroClasif(Opt: string);
  end;

var
  AnItemchk: TTreeNode;
  CantidadS, CantidadSS, CantDoc, Cantfuentes, CantAD, CantDocCoord: Integer;
  EnProcesoE, EnProcesoI: boolean;
  fz, progresototal, tamanoAD: Int64;
  PreviousFilename: string;
  NombreFich, PathCarpetaTF, PathOrigen, PathDestino: string;

const
  IndexTable: array[1..6] of string[20] = ('tb_tree', 'tb_Serietree', 'tb_SeriesDatos', 'tb_ssArchdigital', 'tb_DocCoord', 'tb_indiceinfo');

procedure ExportTrans;

implementation

uses
  UCapaDatos, UAlmacenFicheros;

{$R *.dfm}

procedure ExportTrans;
begin
  with TfrmTrans.Create(nil) do
  try
    Caption := 'Interfaz para la gestión de transferencias de la base de datos.';
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmTrans.btnExportClick(Sender: TObject);
var
  bm: TBookmark;
  idx, index: integer;
  CantEstruct, CantSeries, CantDoc, CantF, CantAD: integer;
begin
  if (EnProcesoE) then
  begin
    if UDM.sms('Se ha detectado un proceso de exportación de transferencias en curso. ¿Desea cancelarlo?', 4) = 6 then
    begin
      EnProcesoE := False;
      CancelarProcess;
      exit;
    end;
  end;

  if EnProcesoI then
  begin
    if UDM.sms('Se ha detectado un proceso de importación de transferencia en curso. ¿Desea cancelarlo?', 4) = 6 then
    begin
      EnProcesoI := False;
      CancelarProcess;
      exit;
    end;
  end;

  if UDM.sms('¿Desea crear una transferencia de la información almacenada?', 4) = 6 then
  begin
    accion := 'E';
    EnProcesoE := True;
    btnImportIndex.Caption := 'Exportar transferencia';
    btnImportIndex.Visible := True;
    lblTitle.Caption := 'Por favor escoja una ruta válida para salvar el contenido a exportar.';
    PLoadAndSaveIndexFile.Visible := True;
    UDM.sms('Debe escoger una ruta válida donde se guardará el archivo de transferencias. ', 3);
  end;

end;

procedure TfrmTrans.btnFindInformeClick(Sender: TObject);
var
  bm: TBookmark;
  idx, index, i: integer;
  CantEstruct, CantSeries, CantDoc, CantF, CantAD: integer;
begin
  if accion = 'E' then
  begin
    if trim(edt1.Text) <> '' then
      if (EnProcesoE) then
      begin
        if UDM.sms('Se ha detectado un proceso de exportación de transferencias en curso. ¿Desea cancelarlo?', 4) = 6 then
        begin
          EnProcesoE := False;
          CancelarProcess;
          exit;
        end
        else
          Exit;
      end;
    if SD.Execute then
      if Trim(SD.FileName) <> '' then
      begin
        edt1.Text := SD.FileName;
        cxDBVerticalGrid2CategoryRow1.Properties.Caption := 'DATOS DE LA EXPORTACIÓN';
        idx := UDM.Conn.ExecSQLScalar('select count(*)from tb_indiceinfo');
        inc(idx);
        Marcadas.Active := True;
        bm := UDM.tb_tree.GetBookmark;
        UDM.tb_tree.DisableControls;
        UDM.tb_tree.First;
        while not UDM.tb_tree.Eof do
        begin
          Marcadas.Append;
          Marcadas.Fields[0].AsInteger := UDM.tb_tree.FieldByName('id').AsInteger;
          Marcadas.Fields[1].AsBoolean := False;
          Marcadas.Fields[2].AsInteger := UDM.tb_tree.FieldByName('tipo').AsInteger;
          try
            Marcadas.Post;
          except
            Marcadas.Cancel;
          end;
          UDM.tb_tree.Next;
        end;
        UDM.tb_tree.First;
        UDM.CreaTreeDB(UDM.Conn, @tvTreechk, True);
        UDM.tb_tree.EnableControls;
        if not tb_indiceinfo.Locate('idindice', idx, []) then
        begin
          tb_indiceinfo.Append;
          tb_indiceinfo.FieldByName('idindice').AsInteger := idx;
          tb_indiceinfo.FieldByName('Fecha').AsDateTime := Now();
          tb_indiceinfo.FieldByName('Estructura').AsInteger := 0;
          tb_indiceinfo.FieldByName('Cantsubseries').AsInteger := 0;
          tb_indiceinfo.FieldByName('CantDocumentos').AsInteger := 0;
          tb_indiceinfo.FieldByName('CantFuentes').AsInteger := 0;
          tb_indiceinfo.FieldByName('CantFAD').AsInteger := 0;
          tb_indiceinfo.FieldByName('UsuarioPC').AsString := DatosPC.Usuario;
          tb_indiceinfo.FieldByName('PC').AsString := DatosPC.Nombre;
          tb_indiceinfo.FieldByName('usuario_sistema').AsString := UDM.UserName;
          tb_indiceinfo.FieldByName('roluser').AsString := UDM.Rol;
          try
            tb_indiceinfo.Post;
          except
            tb_indiceinfo.Cancel;
          end;
          UDM.tb_tree.GotoBookmark(bm);
        end;
        PDetalles.Visible := True;
        Height := 580;
        Constraints.MinHeight := 580;
        Constraints.MaxHeight := 580;
        Top := Trunc(Screen.Height / 2) - (trunc(height / 2) + 50);
      end;
  end
  else if accion = 'I' then
  begin
    if trim(edt1.Text) <> '' then
      if EnProcesoI then
      begin
        if UDM.sms('Se ha detectado un proceso de importación de transferencias en curso. ¿Desea cancelarlo?', 4) = 6 then
        begin
          EnProcesoI := False;
          CancelarProcess;
          exit;
        end
        else
          Exit;
      end;
    if OD.Execute then
      if Trim(OD.FileName) <> '' then
      begin
        NombreFich := AnsiReplaceStr(ansilowercase(OD.FileName), '.tfi', '.tfz');
        if FileExists(NombreFich) then
        begin
          edt1.Text := OD.FileName;
          with SQLConn do
          begin
            Connected := False;
            with params do
            begin
              Clear;
              Add('Database=' + OD.FileName);
              Add('DriverID=SQLite');
            end;
            try
              Connected := True;
              configuraIdx(Destino);
              Destino.First;
              while not Destino.Eof do
              begin
                tb_indiceinfo.Append;
                for i := 0 to Destino.FieldCount - 1 do
                  tb_indiceinfo.FieldByName(Destino.Fields[i].FieldName).Value := Destino.Fields[i].Value;
                try
                  tb_indiceinfo.Post;
                except
                  tb_indiceinfo.Cancel;
                end;
                Destino.Next;
              end;
              with Origen do
              begin
                Active := False;
                Connection := SQLConn;
                SQL.Clear;
                SQL.Add('select * from tb_tree order by id ASC');
                try
                  Active := True;
                except
                  on E: EFDException do
                  begin
                    udm.sms('No se pudo iniciar el proceso de sincronización con el fichero de transferencias. Motivo: ' + e.Message, 1);
                    Exit;
                  end;
                end;
              end;
              Origen.First;
            //Crea el arbol con toda la estructura de la empresa..
              UDM.tb_tree.DisableControls;
              UDM.CreaTreeDB(UDM.Conn, @tvTreechk, True);
              UDM.tb_tree.EnableControls;
            // Recorre el arbol y marca las estructuras que vienen en el indice..
              for i := 0 to tvTreechk.Items.Count - 1 do
                if Origen.Locate('id', pDataRec(tvTreechk.Items[i].Data).Id, []) then
                begin
                  tvTreechk.Checked[tvTreechk.Items[i]] := origen.FieldByName('marca').AsBoolean;
                end;
              PDetalles.Visible := True;
              Height := 580;
              Constraints.MinHeight := 580;
              Constraints.MaxHeight := 580;
              Top := Trunc(Screen.Height / 2) - (trunc(height / 2) + 50);
            except
              on E: EFDException do
              begin
                UDM.sms('No se pudo acceder al fichero de transferencias. Motivo: ' + e.Message, 1);
                Exit;
              end;
            end;
          end;
        end
        else
        begin
          UDM.sms('Se ha detectado qeue el fichero de transferencia especificado está incompleto.Por favor verifique la información suministrada', 1);
        end;
      end;
  end;
end;

procedure TfrmTrans.btnImportClick(Sender: TObject);
begin
  //reinicia..
  if (EnProcesoE) then
  begin
    if UDM.sms('Se ha detectado un proceso de exportación de transferencias en curso. ¿Desea cancelarlo?', 4) = 6 then
    begin
      EnProcesoE := False;
      CancelarProcess;
      exit;
    end
    else
      Exit;
  end;
  if EnProcesoI then
  begin
    if UDM.sms('Se ha detectado un proceso de importación de transferencias en curso. ¿Desea cancelarlo?', 4) = 6 then
    begin
      EnProcesoI := False;
      CancelarProcess;
      exit;
    end
    else
      exit;
  end;
  ReiniciaComponentes;
  if UDM.sms('¿Desea importar un fichero de transferencias?', 4) = 6 then
  begin
    accion := 'I';
    EnProcesoI := True;
    btnImportIndex.Caption := 'Importar transferencias';
    btnImportIndex.Visible := True;
    lblTitle.Caption := 'Por favor especifique la ubicación del fichero de transferencias.';
    PLoadAndSaveIndexFile.Visible := True;
    UDM.sms('Por favor especifique una ruta válida donde se encuentre ubicado el fichero de transferencias. ', 3);
  end;
end;

procedure TfrmTrans.btnImportIndexClick(Sender: TObject);
var
  Fname, cad, NombreFicheroAD: string;
  i, INDEX: Integer;

  procedure CrearCarpeta(rootpath: string);
  begin
    ForceDirectories(rootpath);
    PathCarpetaTF := rootpath;
  end;

  procedure copiaAD(aidEstruct: string);
  var
    PathTRF, Origen, Destino, cad: string;
  begin
    tamanoAD := 0;
    PathTRF := ExtractFilePath(SD.FileName);
    tb_ssArchdigital.Filtered := False;
    tb_ssArchdigital.Filter := 'id=' + QuotedStr(aidEstruct);
    tb_ssArchdigital.Filtered := True;
    if tb_ssArchdigital.RecordCount = 0 then
    begin
      tb_ssArchdigital.Filtered := False;
      tb_ssArchdigital.Filter := '';
      exit;
    end;
    Gauge3.MinValue := 0;
    try
      cad := 'SELECT Sum(tb_ssArchdigital.tamano) AS SumaDetamano FROM tb_ssArchdigital where id=' + QuotedStr(aidEstruct) + ' and Codigodoc=' + QuotedStr(tb_SeriesDatos.FieldByName('Codigodoc').AsString);
      progresototal := UDM.Conn.ExecSQLScalar(cad);
    except
      progresototal := tb_ssArchdigital.RecordCount;
    end;
    jvcpInformation.Visible := True;
    pADF.Visible := True;
    pADF.Align := alClient;
    progresototal := trunc(progresototal / 1024);
    Gauge3.MaxValue := progresototal;
    Gauge3.Progress := 0;
    tb_ssArchdigital.First;
    while not tb_ssArchdigital.Eof do
    begin
      Origen := tb_ssArchdigital.FieldByName('urlraiz').AsString + tb_ssArchdigital.FieldByName('path').AsString + tb_ssArchdigital.FieldByName('nombre').AsString;
      Origen := AnsiReplaceStr(Origen, '\', '/');
      Origen := AnsiReplaceStr(Origen, '//', '/');
      Destino := PathTRF + 'file\' + tb_ssArchdigital.FieldByName('path').AsString;
      Destino := AnsiReplaceStr(Destino, '/', '\');
      Destino := AnsiReplaceStr(Destino, '\\', '\');
      CrearCarpeta(Destino);
      Destino := Destino + tb_ssArchdigital.FieldByName('nombre').AsString;
      FZ := tb_ssArchdigital.FieldByName('tamano').AsInteger;
      try
        DownloadFileFromFTP(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, Origen, Destino, 'S', UDM.cmdServer.FieldByName('puerto').AsInteger);
      except
      end;
      Gauge3.Progress := Gauge3.Progress + trunc(FZ / 1024);
      tb_ssArchdigital.Next;
      Application.ProcessMessages;
    end;
    //jvcpInformation.Visible := False;
    pADF.Visible := False;
    pADF.Align := alRight;
  end;

  procedure CopiarSeries(aidEstruct: string);
  var
    PathTRF, Origen, Destino, cad: string;
    RutaFicheroAD: string;
    cantfS, CantADF: Integer;
  begin
    PathTRF := ExtractFilePath(SD.FileName);
    udm.Conn.Connected := True;
    tb_SeriesDatos.Active := True;
    UDm.cmdServer.Active := True;
    tb_ssArchdigital.Active := True;
    cad := 'select count(*) from tb_SeriesDatos where id=' + aidEstruct + ' and fichero is not null';
    cantfS := udm.Conn.ExecSQLScalar(cad);
    CantADF := udm.Conn.ExecSQLScalar('select count(*) from tb_ssArchdigital where id=' + aidEstruct);
    tb_SeriesDatos.Filtered := False;
    tb_SeriesDatos.Filter := 'id=' + QuotedStr(aidEstruct);
    tb_SeriesDatos.Filtered := True;
    if tb_SeriesDatos.RecordCount = 0 then
    begin
      tb_SeriesDatos.Filtered := False;
      tb_SeriesDatos.Filter := '';
      Exit;
    end;
    Gauge2.MinValue := 0;
    Gauge2.MaxValue := tb_SeriesDatos.RecordCount - 1;
    Gauge2.Progress := 0;
    Gauge3.MinValue := 0;
    Gauge3.MaxValue := CantADF;
    Gauge3.Progress := 0;
    tb_SeriesDatos.First;
    jvcpInformation.Visible := True;
    Gauge2.Visible := True;
    while not tb_SeriesDatos.Eof do
    begin
      if (tb_SeriesDatos.FieldByName('fichero').Value <> null) and (trim(tb_SeriesDatos.FieldByName('fichero').AsString) <> '') then
      begin
        Origen := UDM.cmdServer.FieldByName('path').AsString + tb_SeriesDatos.FieldByName('fichero').AsString;
        Origen := AnsiReplaceStr(Origen, '\', '/');
        Origen := AnsiReplaceStr(Origen, '//', '/');
        Destino := PathTRF + 'file\' + Copy(tb_SeriesDatos.FieldByName('fichero').AsString, 1, LastDelimiter('/', tb_SeriesDatos.FieldByName('fichero').AsString));
        Destino := AnsiReplaceStr(Destino, '/', '\');
        Destino := AnsiReplaceStr(Destino, '\\', '\');
        CrearCarpeta(Destino);
        Destino := Destino + Copy(tb_SeriesDatos.FieldByName('fichero').AsString, LastDelimiter('/', tb_SeriesDatos.FieldByName('fichero').AsString) + 1, length(tb_SeriesDatos.FieldByName('fichero').AsString));
        try
          DownloadFileFromFTP(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, Origen, Destino, 'N', UDM.cmdServer.FieldByName('puerto').AsInteger);
          Gauge2.Progress := Gauge2.Progress + 1;
          Application.ProcessMessages;
        except
        end;
      end;
      tb_SeriesDatos.Next;
    end;
    tb_SeriesDatos.Filtered := False;
    tb_SeriesDatos.Filter := '';
  end;

  function copiar: Boolean;
  begin
    Pathtransplt := PathSys + 'BD\indexplt.db';
    try
      CopyFile(Pchar(Pathtransplt), PChar(Fname), FALSE);
      Result := True;
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo crear el fichero de transferencias. Motivo: ' + E.Message, 1);
        Result := False;
      end;
    end;
  end;

  procedure configtabla(cnnOrigen, cnnDestino: TFDConnection; adsOrigen, adsDestino: TFDQuery; nombreTabla: string);
  begin
    with adsOrigen do
    begin
      Active := False;
      Connection := cnnOrigen;
      SQL.Clear;
      SQL.add('select * from ' + nombreTabla);
      try
        Open();
        FetchAll;
      except
        on E: EFDException do
        begin
          UDM.sms('No se pudo configurar el origen de datos. Motivo: ' + e.Message, 1);
          Exit;
        end;
      end;
    end;
    with Destino do
    begin
      Active := False;
      Connection := cnnDestino;
      SQL.Clear;
      SQL.add('select * from ' + nombreTabla);
      try
        Open();
        FetchAll;
      except
        on E: EFDException do
        begin
          UDM.sms('No se pudo configurar el origen de datos. Motivo: ' + e.Message, 1);
          Exit;
        end;
      end;
    end;
  end;

  procedure DeleteDir(APath: string);
  var
    sr: TSearchRec;
  begin
    APath := IncludeTrailingBackslash(APath);
    if FindFirst(APath + '*.*', faAnyFile, sr) = 0 then
      repeat
        if (sr.Name <> '..') and (sr.Name <> '.') then
        begin
          if (sr.Attr = faDirectory) then
            DeleteDir(APath + sr.Name)
          else
            Win32Check(System.SysUtils.DeleteFile(APath + sr.Name));
        end;
      until FindNext(sr) <> 0;
    System.SysUtils.FindClose(sr);
    APath := ExcludeTrailingBackslash(APath);
    Win32Check(RemoveDir(APath));
  end;

  procedure copiaregistros;
  var
    i: integer;
  begin
    if Origen.RecordCount = 0 then
      Exit;
    Origen.First;
    while not Origen.Eof do
    begin
      Destino.Append;
      for i := 0 to Origen.FieldCount - 1 do
        Destino.FieldByName(Origen.Fields[i].FieldName).Value := Origen.Fields[i].Value;
      try
        Destino.Post;
      except
        on E: EFDException do
        begin
          UDM.sms(e.Message, 1);
          Destino.Cancel;
        end;
      end;
      Application.ProcessMessages;
      Origen.Next;
    end;
  end;

begin
 // deshabilita(False);
  if accion = 'E' then
  begin
    //Export...
    if trim(edt1.Text) = '' then
    begin
      UDM.sms('Debe escoger una ruta válida antes de continuar el proceso.', 2);
      deshabilita(true);
      Exit;
    end;
    Fname := ExtractFileName(edt1.Text);
    copiar;
      //Conexión
    with SQLConn do
    begin
      Connected := False;
      with params do
      begin
        Clear;
        Add('Database=' + SD.FileName);
        Add('DriverID=SQLite');
      end;
      try
        Connected := True;
        ExecSQL('VACUUM;');
        ExportaClsif('E');
        CuadroClasif('E');
        configuraIdx(Destino);
        tb_indiceinfo.First;
        while not tb_indiceinfo.Eof do
        begin
          Destino.Append;
          for i := 0 to Destino.FieldCount - 1 do
            Destino.fields[i].Value := tb_indiceinfo.FieldByName(Destino.Fields[i].FieldName).Value;
          try
            Destino.Post;
          except
            Destino.Cancel;
          end;
          tb_indiceinfo.Next;
        end;

        for i := 0 to tvTreechk.Items.Count - 1 do
        begin
          if tvTreechk.Checked[tvTreechk.Items[i]] then
          begin
            INDEX := pDataRec(tvTreechk.Items[i].Data).Id;
            if udm.tb_tree.Locate('id', INDEX, []) then
            begin
              configTable(IndexTable[1], Origen, INDEX);
              {copiaregistros; }
              if Destino.Locate('id', INDEX, []) then
              begin
                Destino.Edit;
                Destino.FieldByName('marca').Value := True;
                Destino.Post;
              end;
              configTable(IndexTable[2], Origen, INDEX);
              copiaregistros;
              configTable(IndexTable[3], Origen, INDEX);
              copiaregistros;
              CopiarSeries(IntToStr(INDEX));
              configTable(IndexTable[4], Origen, INDEX);
              copiaregistros;
              copiaAD(IntToStr(INDEX));
              configTable(IndexTable[5], Origen, INDEX);
              copiaregistros;
            end;
          end;
        end;
        //compacta...
        jvcpInformation.Visible := True;
        NombreFicheroAD := Copy(SD.FileName, LastDelimiter('\', SD.FileName) + 1, LENGTH(SD.FileName));
        NombreFicheroAD := Copy(NombreFicheroAD, 1, LastDelimiter('.', NombreFicheroAD) - 1);
        jvcpInformation.Visible := True;
        pCompact.Visible := True;
        pCompact.Align := alClient;
        Gauge2.Visible := False;
        CrearCarpeta(ExtractFilePath(edt1.Text) + '\file\');
        try
          ZipDirectory(ExtractFilePath(SD.FileName) + '\file', NombreFicheroAD + '.tfz');
        except
          udm.sms('Error: no se pudo compactar la información.', 1);
        end;
        try
          DeleteDir(ExtractFilePath(SD.FileName) + '\file');
        except
        end;
        jvcpInformation.Visible := False;
        pCompact.Visible := False;
        pCompact.Align := alLeft;
//        Application.BringToFront;
        UDM.sms('El proceso de exportación ha terminado satisfactoriamente.', 3);
        Application.ProcessMessages;
        ExecSQL('VACUUM;');
        CancelarProcess;
        ShellExecute(0, nil, '', '', PWideChar(ExtractFilePath(edt1.Text)), SW_SHOW);
        deshabilita(True);
      except
        on E: EFDException do
        begin
          UDM.sms('No se pudo acceder al fichero de índices. Motivo: ' + e.Message, 1);
          deshabilita(True);
          Exit;
        end;
      end;
    end;
  end
  else if accion = 'I' then
  begin
    ExportaClsif('I');
    CuadroClasif('I');
    tb_treeO.Active := True;
    tb_SerietreeO.Active := True;
    tb_SeriesDatosO.Active := True;
    tb_ssArchdigitalO.Active := True;
    tb_DocCoordO.Active := True;
    tb_tree.Active := True;
    tb_Serietree.Active := True;
    tb_SeriesDatos.Active := True;
    tb_ssArchdigital.Active := True;
    tb_DocCoord.Active := True;
    //descompacta...
    jvcpInformation.Visible := True;
    Label2.Caption := 'Descomprimiendo información. Espere...';
    pCompact.Visible := True;
    pCompact.Align := alClient;
    Gauge2.Visible := False;
    CrearCarpeta(ExtractFilePath(edt1.Text) + '\file\');
    UnzipFile(ExtractFileName(NombreFich), PathCarpetaTF);
    jvcpInformation.Visible := False;
    pCompact.Visible := False;
    pCompact.Align := alLeft;
    Label2.Caption := 'Compactando información. Espere...';
    tb_SerietreeO.First;
    while not tb_SerietreeO.Eof do
    begin
      if not tb_Serietree.Locate('IdEstructura;id;codsubs', VarArrayOf([tb_SerietreeO.FieldByName('IdEstructura').asstring, tb_SerietreeO.FieldByName('id').asstring, tb_SerietreeO.FieldByName('codsubs').asstring]), []) then
        tb_Serietree.Append
      else
        tb_Serietree.Edit;
      for i := 0 to tb_Serietree.FieldCount - 1 do
        tb_Serietree.Fields[i].Value := tb_SerietreeO.FieldByName(tb_Serietree.Fields[i].FieldName).Value;
      try
        tb_Serietree.Post;
      except
        tb_Serietree.Cancel;
      end;
      tb_SerietreeO.Next;
    end;
    tb_SeriesDatosO.First;
    Gauge2.MinValue := 0;
    Gauge2.MaxValue := tb_SeriesDatosO.RecordCount;
    Gauge2.Progress := 0;
    jvcpInformation.Height := 50;
    jvcpInformation.Visible := True;
    Gauge2.Visible := true;
    while not tb_SeriesDatosO.Eof do
    begin
      if not tb_SeriesDatos.Locate('IdEstructura;id;codsubs;Fecha;Version;Codigodoc', VarArrayOf([tb_SeriesDatosO.FieldByName('IdEstructura').AsString, tb_SeriesDatosO.FieldByName('id').AsString, tb_SeriesDatosO.FieldByName('codsubs').AsString, tb_SeriesDatosO.FieldByName('Fecha').AsString, tb_SeriesDatosO.FieldByName('Version').AsString, tb_SeriesDatosO.FieldByName('Codigodoc').AsString]), []) then
        tb_SeriesDatos.Append
      else
        tb_SeriesDatos.Edit;
      tb_SeriesDatos.FieldByName('idEstructura').AsString := tb_SeriesDatosO.FieldByName('IdEstructura').AsString;
      tb_SeriesDatos.FieldByName('id').AsString := tb_SeriesDatosO.FieldByName('id').AsString;
      tb_SeriesDatos.FieldByName('codsubs').AsString := tb_SeriesDatosO.FieldByName('codsubs').AsString;
      tb_SeriesDatos.FieldByName('Fecha').AsDateTime := tb_SeriesDatosO.FieldByName('Fecha').AsDateTime;
      tb_SeriesDatos.FieldByName('Version').AsString := tb_SeriesDatosO.FieldByName('Version').AsString;
      tb_SeriesDatos.FieldByName('Codigodoc').AsString := tb_SeriesDatosO.FieldByName('Codigodoc').AsString;
      tb_SeriesDatos.FieldByName('titulodoc').AsString := tb_SeriesDatosO.FieldByName('titulodoc').AsString;
      tb_SeriesDatos.FieldByName('Archivo').AsString := tb_SeriesDatosO.FieldByName('Archivo').AsString;
      tb_SeriesDatos.FieldByName('deposito').AsString := tb_SeriesDatosO.FieldByName('deposito').AsString;
      tb_SeriesDatos.FieldByName('gaveta').AsString := tb_SeriesDatosO.FieldByName('gaveta').AsString;
      tb_SeriesDatos.FieldByName('Idservidor').AsString := tb_SeriesDatosO.FieldByName('Idservidor').AsString;
      tb_SeriesDatos.FieldByName('fichero').AsString := tb_SeriesDatosO.FieldByName('fichero').AsString;
      tb_SeriesDatos.FieldByName('FechaFin').AsDateTime := tb_SeriesDatosO.FieldByName('FechaFin').AsDateTime;
      tb_SeriesDatos.FieldByName('gestor').AsString := tb_SeriesDatosO.FieldByName('gestor').AsString;
      tb_SeriesDatos.FieldByName('observaciones').AsString := tb_SeriesDatosO.FieldByName('observaciones').AsString;
      tb_SeriesDatos.FieldByName('IDExpediente').AsString := tb_SeriesDatosO.FieldByName('IDExpediente').AsString;
      tb_SeriesDatos.FieldByName('namefile').AsString := tb_SeriesDatosO.FieldByName('namefile').AsString;
      tb_SeriesDatos.FieldByName('subexp').AsString := tb_SeriesDatosO.FieldByName('subexp').AsString;
      tb_SeriesDatos.FieldByName('visible').AsString := tb_SeriesDatosO.FieldByName('visible').AsString;
      {for i := 0 to tb_SeriesDatos.FieldCount - 1 do
        tb_SeriesDatos.Fields[i].Value := tb_SeriesDatosO.FieldByName(tb_SeriesDatos.Fields[i].FieldName).Value;}
      try
        tb_SeriesDatos.Post;
        UDM.cmdServer.Active := False;
        UDM.cmdServer.Params[0].Value := tb_SeriesDatos.FieldByName('Idservidor').AsString;
        try
          UDM.cmdServer.Active := true;
        except
        end;
        PathSaveBinaryFile := UDM.cmdServer.FieldByName('Path').AsString + tb_SeriesDatosO.FieldByName('fichero').AsString;
        PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '\', '/');
        PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '//', '/');
        PathDestino := PathSaveBinaryFile;
        PathOrigen := PathCarpetaTF + tb_SeriesDatosO.FieldByName('fichero').AsString;
        PathOrigen := AnsiReplaceStr(PathOrigen, '/', '\');
        PathOrigen := AnsiReplaceStr(PathOrigen, '\\\', '\');
        PathOrigen := AnsiReplaceStr(PathOrigen, '\\', '\');
        //Up To Server...
        CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, PathOrigen, PathDestino, 'O', UDM.cmdServer.FieldByName('puerto').AsInteger);
      except
        tb_SeriesDatos.Cancel;
      end;
      Gauge2.Progress := Gauge2.Progress + 1;
      Application.ProcessMessages;
      tb_SeriesDatosO.Next;
    end;
    Gauge2.MinValue := 0;
    Gauge2.MaxValue := 0;
    Gauge2.Progress := 0;
    Gauge2.Visible := False;
    jvcpInformation.Height := 105;
    jvcpInformation.Visible := False;

    tb_ssArchdigitalO.First;
    jvcpInformation.Visible := True;
    Label1.Caption := 'Subiendo Archivos digitales y Fuentes';
    pADF.Visible := True;
    pADF.Align := alClient;
    Gauge2.Visible := False;
    Gauge3.MinValue := 0;
    Gauge3.Progress := 0;
    while not tb_ssArchdigitalO.Eof do
    begin
      Gauge3.MaxValue := tb_ssArchdigitalO.RecordCount;
      if not tb_ssArchdigital.Locate('IdEstructura;id;codsubs;Fecha;Version;Codigodoc;idhijo', VarArrayOf([tb_ssArchdigitalO.FieldByName('IdEstructura').AsString, tb_ssArchdigitalO.FieldByName('id').AsString, tb_ssArchdigitalO.FieldByName('codsubs').AsString, tb_ssArchdigitalO.FieldByName('Fecha').AsString, tb_ssArchdigitalO.FieldByName('Version').AsString, tb_ssArchdigitalO.FieldByName('Codigodoc').AsString, tb_ssArchdigitalO.FieldByName('idhijo').AsString]), []) then
        tb_ssArchdigital.Append
      else
        tb_ssArchdigital.Edit;
      for i := 0 to tb_ssArchdigital.FieldCount - 1 do
        tb_ssArchdigital.Fields[i].Value := tb_ssArchdigitalO.FieldByName(tb_ssArchdigital.Fields[i].FieldName).Value;
      try
        tb_ssArchdigital.Post;
        //Sube archivos al FTP...
        if tb_SeriesDatos.Locate('IdEstructura;id;codsubs;Fecha;Version;Codigodoc', VarArrayOf([tb_ssArchdigitalO.FieldByName('IdEstructura').AsString, tb_ssArchdigitalO.FieldByName('id').AsString, tb_ssArchdigitalO.FieldByName('codsubs').AsString, tb_ssArchdigitalO.FieldByName('Fecha').AsString, tb_ssArchdigitalO.FieldByName('Version').AsString, tb_ssArchdigitalO.FieldByName('Codigodoc').AsString]), []) then
        begin
          if (trim(tb_SeriesDatos.FieldByName('Idservidor').AsString) <> '') and (tb_SeriesDatos.FieldByName('Idservidor').Value <> null) then
          begin
            UDM.cmdServer.Active := False;
            UDM.cmdServer.Params[0].Value := tb_SeriesDatos.FieldByName('Idservidor').AsString;
            try
              UDM.cmdServer.Active := true;
              PathSaveBinaryFile := UDM.cmdServer.FieldByName('Path').AsString + tb_ssArchdigital.FieldByName('path').AsString + tb_ssArchdigital.FieldByName('nombre').AsString;
              PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '\', '/');
              PathSaveBinaryFile := AnsiReplaceStr(PathSaveBinaryFile, '//', '/');
              PathDestino := PathSaveBinaryFile;
              FZ := tb_ssArchdigital.FieldByName('tamano').AsInteger;
              PathOrigen := PathCarpetaTF + tb_ssArchdigital.FieldByName('path').AsString + tb_ssArchdigital.FieldByName('nombre').AsString;
              PathOrigen := AnsiReplaceStr(PathOrigen, '/', '\');
              PathOrigen := AnsiReplaceStr(PathOrigen, '\\\', '\');
              PathOrigen := AnsiReplaceStr(PathOrigen, '\\', '\');
        //Up To Server...
              CopyFileToFtpServer(UDM.cmdServer.FieldByName('ipserver').AsString, UDM.cmdServer.FieldByName('usuarioftp').AsString, UDM.cmdServer.FieldByName('pass').AsString, PathOrigen, PathDestino, 'S', UDM.cmdServer.FieldByName('puerto').AsInteger);
              Gauge3.Progress := Gauge3.Progress + 1;
              Application.ProcessMessages;
            except
            end;
          end;
        end;
      except
        tb_ssArchdigital.Cancel;
      end;
      tb_ssArchdigitalO.Next;
    end;
    jvcpInformation.Visible := False;
    pADF.Visible := False;
    pADF.Align := alRight;
    Gauge2.Visible := False;
    Label1.Caption := 'Descargando Archivo digital y Fuentes';
    tb_DocCoordO.First;
    while not tb_DocCoordO.Eof do
    begin
      if not tb_DocCoord.Locate('IdEstructura;id;codsubs;Fecha;Version;Codigodoc;idvertice', VarArrayOf([tb_DocCoordO.FieldByName('IdEstructura').AsString, tb_DocCoordO.FieldByName('id').AsString, tb_DocCoordO.FieldByName('codsubs').AsString, tb_DocCoordO.FieldByName('Fecha').AsString, tb_DocCoordO.FieldByName('Version').AsString, tb_DocCoordO.FieldByName('idvertice').AsString]), []) then
        tb_DocCoord.Append
      else
        tb_DocCoord.Edit;
      for i := 0 to udm.tb_DocCoord.FieldCount - 1 do
        tb_DocCoord.Fields[i].Value := tb_DocCoordO.FieldByName(tb_DocCoord.Fields[i].FieldName).Value;
      try
        tb_DocCoord.Post;
      except
        tb_DocCoord.Cancel;
      end;
      tb_DocCoordO.Next;
    end;
    DeleteDir(ExtractFilePath(edt1.Text) + '\file\');
    UDM.tb_tree.FetchAll();
    udm.tb_Serietree.FetchAll;
    udm.tb_SeriesDatos.FetchAll;
    UDM.tb_ssArchdigital.FetchAll;
    UDM.tb_DocCoord.FetchAll;
    //deshabilita(True);
//    Application.BringToFront;
    UDM.sms('El proceso de importación de las transferencias concluyó correctamente.', 3);
    CancelarProcess;
  end;
  //deshabilita(True);
end;

procedure TfrmTrans.btnRefreshClick(Sender: TObject);
var
  i: integer;
begin
  if UDM.sms('Esta acción reconstruirá el árbol con la información por defecto. ¿Desea continuar?', 4) = 6 then
  begin
    if accion = 'I' then
    begin
      with Origen do
      begin
        Active := False;
        Connection := SQLConn;
        SQL.Clear;
        SQL.Add('select * from tb_tree order by id ASC');
        try
          Active := True;
        except
          on E: EFDException do
          begin
            udm.sms('No se pudo iniciar el proceso de sincronización con el fichero de índices. Motivo: ' + e.Message, 1);
            Exit;
          end;
        end;
      end;
      Origen.First;
            //Crea el arbol con toda la estructura de la empresa..
      UDM.tb_tree.DisableControls;
      UDM.CreaTreeDB(UDM.Conn, @tvTreechk, True);
      UDM.tb_tree.EnableControls;
            // Recorre el arbol y marca las estructuras que vienen en el indice..
      for i := 0 to tvTreechk.Items.Count - 1 do
        if Origen.Locate('id', pDataRec(tvTreechk.Items[i].Data).Id, []) then
        begin
          tvTreechk.Checked[tvTreechk.Items[i]] := True;
        end;
    end
    else
    begin
      UDM.tb_tree.First;
      UDM.CreaTreeDB(UDM.Conn, @tvTreechk, True);
      UDM.tb_tree.EnableControls;
    end;
  end;

end;

procedure TfrmTrans.btnSystemHelpClick(Sender: TObject);
var
  TopicID: integer;
begin
  TopicID := 30;
  Application.HelpContext(TopicID);
end;

function TfrmTrans.configTable(nombreTabla: string; dsOrigen: TFDQuery; aIdStruct: integer): boolean;
begin
  Result := False;
  with dsOrigen do
  begin
    Active := False;
    SQL.Clear;
    SQL.add('select * from ' + nombreTabla + ' where id=' + IntToStr(aIdStruct));
    try
      Open();
      FetchAll;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo configurar el origen de datos. Motivo: ' + e.Message, 1);
        Exit;
      end;
    end;
  end;
  with Destino do
  begin
    Active := False;
    SQL.Clear;
    SQL.add('select * from ' + nombreTabla);
    try
      Open();
      FetchAll;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo configurar el origen de datos. Motivo: ' + e.Message, 1);
        Exit;
      end;
    end;
  end;
  Result := True;
end;

procedure TfrmTrans.configuraIdx(dsOrigen: TFDQuery);
begin
  with dsOrigen do
  begin
    Active := False;
    SQL.Clear;
    SQL.add('select * from tb_indiceinfo');
    try
      Open();
      FetchAll;
    except
      on E: EFDException do
      begin
        UDM.sms('No se pudo configurar el origen de datos. Motivo: ' + e.Message, 1);
        Exit;
      end;
    end;
  end;
end;

procedure TfrmTrans.CopiarREG(Opt: integer);
var
  i, PR: integer;
  MF, IFN: string;
begin
  case Opt of
    1:
      begin
        if Origen.RecordCount = 0 then
          Exit;
        Origen.First;
        Marcadas.First;
        while not Origen.Eof do
        begin
          Marcadas.Locate('id', UDM.tb_tree.FieldByName('id').AsInteger, []);
          Destino.Append;
          for i := 0 to Origen.FieldCount - 1 do
            Destino.FieldByName(Origen.Fields[i].FieldName).Value := Origen.Fields[i].Value;
          Destino.FieldByName('marca').Value := Marcadas.Fields[1].Value;
          try
            Destino.Post;
          except
            on E: EFDException do
            begin
              UDM.sms(e.Message, 1);
              Destino.Cancel;
            end;
          end;

          Application.ProcessMessages;
          Origen.Next;
        end;
      end;
    2:
      begin
        if UDM.tb_Serietree.RecordCount = 0 then
          Exit;
        {UDM.tb_Serietree.MasterSource := nil;
        MF := UDM.tb_Serietree.MasterFields;
        IFN := UDM.tb_Serietree.IndexFieldNames;
        UDM.tb_Serietree.MasterFields := '';
        UDM.tb_Serietree.IndexFieldNames := ''; }
        UDM.tb_Serietree.First;
        while not UDM.tb_Serietree.Eof do
        begin
          Origen.Append;
          for i := 0 to Origen.FieldCount - 1 do
            Origen.Fields[i].Value := UDM.tb_Serietree.FieldByName(Origen.Fields[i].FieldName).Value;
          try
            Origen.Post;
          except
            on E: EFDException do
            begin
              UDM.sms(e.Message, 1);
              Origen.Cancel;
            end;
          end;
          Application.ProcessMessages;
          UDM.tb_Serietree.Next;
        end;
      end;
    3:
      begin
        if UDM.tb_SeriesDatos.RecordCount = 0 then
          Exit;
       { UDM.tb_SeriesDatos.MasterSource := nil;
        MF := UDM.tb_SeriesDatos.MasterFields;
        IFN := UDM.tb_SeriesDatos.IndexFieldNames;
        UDM.tb_SeriesDatos.MasterFields := '';
        UDM.tb_SeriesDatos.IndexFieldNames := '';  }
        UDM.tb_SeriesDatos.First;
        while not UDM.tb_SeriesDatos.Eof do
        begin
          Origen.Append;
          for i := 0 to Origen.FieldCount - 1 do
            Origen.Fields[i].Value := UDM.tb_SeriesDatos.FieldByName(Origen.Fields[i].FieldName).Value;
          try
            Origen.Post;
          except
            on E: EFDException do
            begin
              UDM.sms(e.Message, 1);
              Origen.Cancel;
            end;
          end;
          UDM.tb_SeriesDatos.Next;
        end;
       { UDM.tb_SeriesDatos.MasterSource := UDM.dstb_Serietree;
        UDM.tb_SeriesDatos.MasterFields := MF;
        UDM.tb_SeriesDatos.IndexFieldNames := IFN; }
      end;
    4:
      begin
        if UDM.tb_ssArchdigital.RecordCount = 0 then
          Exit;
        {UDM.tb_ssArchdigital.MasterSource := nil;
        MF := UDM.tb_ssArchdigital.MasterFields;
        IFN := UDM.tb_ssArchdigital.IndexFieldNames;
        UDM.tb_ssArchdigital.MasterFields := '';
        UDM.tb_ssArchdigital.IndexFieldNames := '';}
        UDM.tb_ssArchdigital.First;
        while not UDM.tb_ssArchdigital.Eof do
        begin
          Origen.Append;
          for i := 0 to Origen.FieldCount - 1 do
            Origen.Fields[i].Value := UDM.tb_ssArchdigital.FieldByName(Origen.Fields[i].FieldName).Value;
          try
            Origen.Post;
          except
            on E: EFDException do
            begin
              UDM.sms(e.Message, 1);
              Origen.Cancel;
            end;
          end;
          UDM.tb_ssArchdigital.Next;
        end;

      end;
    5:
      begin
        if UDM.tb_DocCoord.RecordCount = 0 then
          Exit;
        UDM.tb_DocCoord.MasterSource := nil;
        MF := UDM.tb_DocCoord.MasterFields;
        IFN := UDM.tb_DocCoord.IndexFieldNames;
        UDM.tb_DocCoord.MasterFields := '';
        UDM.tb_DocCoord.IndexFieldNames := '';
        UDM.tb_DocCoord.First;
        while not UDM.tb_DocCoord.Eof do
        begin
          Origen.Append;
          for i := 0 to Origen.FieldCount - 1 do
            Origen.Fields[i].Value := UDM.tb_DocCoord.FieldByName(Origen.Fields[i].FieldName).Value;
          try
            Origen.Post;
          except
            on E: EFDException do
            begin
              UDM.sms(e.Message, 1);
              Origen.Cancel;
            end;
          end;
          Application.ProcessMessages;
          UDM.tb_DocCoord.Next;
        end;
        UDM.tb_DocCoord.MasterSource := UDM.dstb_SeriesDatos;
        UDM.tb_DocCoord.MasterFields := MF;
        UDM.tb_DocCoord.IndexFieldNames := IFN;
      end;
    6:
      begin
        if tb_indiceinfo.RecordCount = 0 then
          Exit;
        tb_indiceinfo.First;
        while not tb_indiceinfo.Eof do
        begin
          Origen.Append;
          for i := 0 to Origen.FieldCount - 1 do
            Origen.Fields[i].Value := tb_indiceinfo.FieldByName(Origen.Fields[i].FieldName).Value;
          try
            Origen.Post;
          except
            on E: EFDException do
            begin
              UDM.sms(e.Message, 1);
              Origen.Cancel;
            end;
          end;
          Application.ProcessMessages;
          tb_indiceinfo.Next;
        end;
      end;
  end;

end;

procedure TfrmTrans.CopyFileToFtpServer(const AServer, AUsername, APassword, ALocalFile, ARemotePath, Opts: string; Puerto: integer);
var
  FTP: TIdFTP;
  Path, NombreFichero: string;
begin
  FTP := TIdFTP.Create(nil);
  try
    FTP.Host := AServer;
    FTP.Username := AUsername;
    FTP.Password := APassword;
    FTP.Port := Puerto;
    FTP.Passive := True; // Modo pasivo para conexiones detrás de un firewall
    FTP.Connect;
    Path := Copy(ARemotePath, 1, LastDelimiter('/', ARemotePath));
    NombreFichero := Copy(ARemotePath, LastDelimiter('/', ARemotePath) + 1, LastDelimiter('.', ARemotePath) - LastDelimiter('/', ARemotePath) - 1);
    //CREAR ESTRUCTURA DE DIRECTORIOS...
    if Opts = 'S' then
    begin
      FTP.OnWorkBegin := ftpwb;
      FTP.OnWork := ftpw;
      FTP.OnWorkEnd := ftpwe;
    end;
    try
      FTP.MakeDir(Path);
    except
    end;
    if Opts = 'O' then
    begin
      try
        FTP.MakeDir(Path + NombreFichero + '/');
      except
      end;
      try
        FTP.MakeDir(Path + NombreFichero + '/Fuentes/');
      except
      end;
      try
        FTP.MakeDir(Path + NombreFichero + '/Anexos Digitales/');
      except
      end;
    end;
    try
      FTP.Put(ALocalFile, ARemotePath, False);  //+ '/' + ExtractFileName(ALocalFile)
      // El cuarto parámetro indica que se sobrescribirá el archivo si ya existe
      FTP.Disconnect;
    except
      FTP.Disconnect;
      raise;
    end;
  finally
    FTP.Free;
  end;
end;

procedure TfrmTrans.CuadroClasif(Opt: string);
var
  cmdOrigenS, cmddestinoS: TFDQuery;
  i: integer;
begin
  cmdOrigenS := TFDQuery.Create(nil);
  cmddestinoS := TFDQuery.Create(nil);
  with cmdOrigenS do
  begin
    Active := False;
    if Opt = 'E' then
      Connection := UDM.Conn
    else
      Connection := SQLConn;
    SQL.Clear;
    SQL.Add('select * from tb_tree');
    try
      Open();
      FetchAll;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        Exit;
      end;
    end;
  end;
  with cmddestinoS do
  begin
    Active := False;
    if Opt = 'E' then
      Connection := SQLConn
    else
      Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('select * from tb_tree');
    try
      Open();
      FetchAll;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        Exit;
      end;
    end;
  end;
  cmdOrigenS.First;
  while not cmdOrigenS.Eof do
  begin
    if not cmddestinoS.Locate('IdEstructura;id', VarArrayOf([cmdOrigenS.FieldByName('IdEstructura').AsString, cmdOrigenS.FieldByName('id').AsString]), []) then
      cmddestinoS.Append
    else
      cmddestinoS.Edit;
    for i := 0 to cmddestinoS.FieldCount - 1 do
      if ansilowercase(cmddestinoS.Fields[i].FieldName) <> 'marca' then
        cmddestinoS.Fields[i].Value := cmdOrigenS.FieldByName(cmddestinoS.Fields[i].FieldName).Value;
    try
      cmddestinoS.Post;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        cmddestinoS.Cancel;
      end;
    end;
    cmdOrigenS.Next;
  end;
  cmdOrigenS.Free;
  cmddestinoS.Free;
end;

procedure TfrmTrans.deshabilita(Opts: boolean);
begin
  btnExport.Enabled := Opts;
  btnImport.Enabled := Opts;
  btnClose.Enabled := Opts;
  btnFindInforme.Enabled := Opts;
  btnImportIndex.Enabled := Opts;
end;

procedure TfrmTrans.DownloadFileFromFTP(const Host, Username, Password, RemoteFile, LocalFile, EsArchivo: string; Puerto: Integer);
var
  FTP: TIdFTP;
  IdS3: Integer;
  ClaveS3: string;
begin
  // Ficheros ya migrados a S3 (urlraiz 's3://<n>/'): se bajan del almacen S3
  if ParsearRutaS3(RemoteFile, IdS3, ClaveS3) then
  begin
    UDM.DescargarDeS3(IdS3, ClaveS3, LocalFile);
    Exit;
  end;
  FTP := TIdFTP.Create(nil);
  try
    FTP.Host := Host;
    FTP.Username := Username;
    FTP.Password := Password;
    FTP.Port := Puerto;
    if EsArchivo = 'S' then
    begin
      FTP.OnWorkBegin := ftpwb;
      FTP.OnWork := ftpw;
      FTP.OnWorkEnd := ftpwe;
    end;
    FTP.Connect;
    try
      FTP.Get(RemoteFile, LocalFile, True);
    except
    end;
    FTP.Disconnect;
  finally
    FTP.Free;
  end;
end;

procedure TfrmTrans.ExportaClsif(Opt: string);
var
  cmdOrigenS, cmddestinoS: TFDQuery;
  cmdOrigenSS, cmddestinoSS: TFDQuery;
  i: integer;
begin
  cmdOrigenS := TFDQuery.Create(nil);
  cmdOrigenSS := TFDQuery.Create(nil);
  cmddestinoS := TFDQuery.Create(nil);
  cmddestinoSS := TFDQuery.Create(nil);
  //Series...
  with cmdOrigenS do
  begin
    Active := False;
    if Opt = 'E' then
      Connection := UDM.Conn
    else
      Connection := SQLConn;
    SQL.Clear;
    SQL.Add('select * from cl_series');
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        Exit;
      end;
    end;
  end;
  with cmdOrigenSS do
  begin
    Active := False;
    if Opt = 'E' then
      Connection := UDM.Conn
    else
      Connection := SQLConn;
    SQL.Clear;
    SQL.Add('select * from cl_subseries');
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        Exit;
      end;
    end;
  end;
  with cmddestinoS do
  begin
    Active := False;
    if Opt = 'E' then
      Connection := SQLConn
    else
      Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('select * from cl_series');
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        Exit;
      end;
    end;
  end;
  with cmddestinoSS do
  begin
    Active := False;
    if Opt = 'E' then
      Connection := SQLConn
    else
      Connection := UDM.Conn;
    SQL.Clear;
    SQL.Add('select * from cl_subseries');
    try
      Active := True;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        Exit;
      end;
    end;
  end;
  cmdOrigenS.First;
  while not cmdOrigenS.Eof do
  begin
    if not cmddestinoS.Locate('codserie', cmdOrigenS.FieldByName('codserie').AsString, []) then
      cmddestinoS.Append
    else
      cmddestinoS.Edit;
    for i := 0 to cmddestinoS.FieldCount - 1 do
      cmddestinoS.Fields[i].Value := cmdOrigenS.FieldByName(cmddestinoS.Fields[i].FieldName).Value;
    try
      cmddestinoS.Post;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        cmddestinoS.Cancel;
      end;
    end;
    cmdOrigenS.Next;
  end;
  cmdOrigenSS.First;
  while not cmdOrigenSS.Eof do
  begin
    if not cmddestinoSS.Locate('codserie;codsubs', VarArrayOf([cmdOrigenSS.FieldByName('codserie').AsString, cmdOrigenSS.FieldByName('codsubs').AsString]), []) then
      cmddestinoSS.Append
    else
      cmddestinoSS.Edit;
    for i := 0 to cmddestinoSS.FieldCount - 1 do
      cmddestinoSS.Fields[i].Value := cmdOrigenSS.FieldByName(cmddestinoSS.Fields[i].FieldName).Value;
    try
      cmddestinoSS.Post;
    except
      on E: EFDException do
      begin
        UDM.sms(e.Message, 1);
        cmddestinoSS.Cancel;
      end;
    end;
    cmdOrigenSS.Next;
  end;
  cmdOrigenS.Free;
  cmddestinoS.Free;
  cmdOrigenSS.Free;
  cmddestinoSS.Free;
end;

procedure TfrmTrans.FormCreate(Sender: TObject);
begin
  EnProcesoE := False;
  EnProcesoI := False;
  Height := 176;
  Constraints.MinHeight := 176;
  Constraints.MaxHeight := 176;
  Constraints.MinWidth := 894;
  Constraints.MaxWidth := 894;
end;

procedure TfrmTrans.ftpw(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
var
  pc: Integer;
begin
  tamanoAD := tamanoAD + AWorkCount;
  pc := trunc(AWorkCount / FZ * 100);
  Gauge4.Progress := pc;
  Application.ProcessMessages;
end;

procedure TfrmTrans.ftpwb(ASender: TObject; AWorkMode: TWorkMode; AWorkCountMax: Int64);
begin
  Gauge4.MinValue := 0;
  Gauge4.MaxValue := 100;
  Gauge4.Progress := 0;
end;

procedure TfrmTrans.ftpwe(ASender: TObject; AWorkMode: TWorkMode);
begin
  Gauge4.Progress := 0;
  Gauge4.MinValue := 0;
  tamanoAD := 0;
end;

function TfrmTrans.GetAllRecordCount(cnn: TFDConnection): LongInt;
var
  cantidad: LongInt;
begin
  Result := 0;
  //udm
  try
    Result := cnn.ExecSQLScalar('select count(*)from tb_tree') + cnn.ExecSQLScalar('select count(*)from tb_Serietree') + cnn.ExecSQLScalar('select count(*)from tb_SeriesDatos') + cnn.ExecSQLScalar('select count(*)from tb_ssArchdigital') + cnn.ExecSQLScalar('select count(*)from tb_DocCoord');
    cantidad := Result;
  except
    on E: EFDException do
    begin
      UDM.sms('No se pudo obtener la cantidad de registros a indexar. Motivo: ' + e.Message, 1);
      Exit;
    end;

  end;

end;

procedure TfrmTrans.ImportIdxREG(Opt: integer);
var
  i: integer;
  MF, IFN: string;
begin
end;

procedure TfrmTrans.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTrans.MarcaHijos(conn: TFDConnection; IdNodo: string; V: boolean);
var
  qry: TFDQuery;
  Nodo, nodohijo: TTreeNode;

  function findnodo(acap: string; aid: integer): TTreeNode;
  var
    i: integer;
  begin
    Result := nil;
    for i := 0 to tvTreechk.Items.Count - 1 do
      if (ansilowercase(tvTreechk.Items[i].Text) = ansilowercase(acap)) and (PDataRec(tvTreechk.Items[i].Data).Id = aid) then
      begin
        Result := tvTreechk.Items[i];
        Break;
      end;

  end;

  procedure NodoQuery(IdPadre: integer);
  var
    s: string;
  begin
    with TFDQuery.Create(nil) do
    try
      Connection := UDM.conn;
      SQL.Clear;
      SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre FROM tb_tree  where padre=' + inttostr(IdPadre) + ' order by etiqueta asc');
      try
        Active := True;
        First;       //GUANTÁNAMO (X)
        s := Fields[1].AsString;
        while not Eof do
        begin
          nodohijo := findnodo(Fields[1].asstring, Fields[0].AsInteger);
          tvTreechk.Checked[nodohijo] := V;
          NodoQuery(Fields[0].AsInteger);
          if nodohijo <> nil then
          begin
            tvTreechk.Checked[nodohijo] := V;
            if Marcadas.Locate('id', Fields[0].AsInteger, []) then
            begin
              marcadas.Edit;
              Marcadas.Fields[1].AsBoolean := V;
              Marcadas.Post;
            end;
          end;
          Next;
        end;
      except
      end;
    finally
      Free;
    end;
  end;

begin
  Screen.Cursor := crSQLWait;
  qry := TFDQuery.create(nil);
  with qry do
  begin
    Active := False;
    Connection := conn;
    SQL.Clear;
    SQL.Add('SELECT tb_tree.id, tb_tree.etiqueta, tb_tree.padre FROM tb_tree  where padre=' + IdNodo + ' order by etiqueta asc');
    try
      Active := True;
      First;
      while not Eof do
      begin
        Nodo := findnodo(Fields[1].asstring, Fields[0].AsInteger);
        if Nodo <> nil then
        begin
          tvTreechk.Checked[Nodo] := V;
          if Marcadas.Locate('id', Fields[0].AsInteger, []) then
          begin
            marcadas.Edit;
            Marcadas.Fields[1].AsBoolean := V;
            Marcadas.Post;
          end;
          NodoQuery(Fields[0].AsInteger);
        end;
        Next;
      end;
    except
      on E: EDatabaseError do
      begin
        UDM.sms(E.Message, 1);
      end;
    end;
  end;
  Screen.Cursor := crDefault;
end;

procedure TfrmTrans.MarcaNodoyPadres(IdNodo: TTreenode; V: boolean);
var
  Id, IdPadre: Integer;
  NodoPadre: TTreeNode;
  NombrePadre: string;
  bm: TBookmark;

  function findnodo(acap: string; aid: integer): TTreeNode;
  var
    i: integer;
  begin
    Result := nil;
    for i := 0 to tvTreechk.Items.Count - 1 do
      if (ansilowercase(tvTreechk.Items[i].Text) = ansilowercase(acap)) and (PDataRec(tvTreechk.Items[i].Data).Id = aid) then
      begin
        Result := tvTreechk.Items[i];
        Break;
      end;

  end;

begin
  IdPadre := PDataRec(IdNodo.Data).Padre;
  NombrePadre := '';
  NombrePadre := UDM.Conn.ExecSQLScalar('select etiqueta from tb_tree where id=' + IntToStr(IdPadre));
  if Trim(NombrePadre) <> '' then
  begin
    NodoPadre := findnodo(NombrePadre, IdPadre);
    tvTreechk.Checked[NodoPadre] := V;
    while NodoPadre <> nil do
    begin
      IdPadre := PDataRec(NodoPadre.Data).Padre;
      NombrePadre := UDM.Conn.ExecSQLScalar('select etiqueta from tb_tree where id=' + IntToStr(IdPadre));
      NodoPadre := findnodo(NombrePadre, IdPadre);
      if NodoPadre <> nil then
      begin
        tvTreechk.Checked[NodoPadre] := V;
        if Marcadas.Locate('id', PDataRec(NodoPadre.Data).Id, []) then
        begin
          marcadas.Edit;
          Marcadas.Fields[1].AsBoolean := V;
          Marcadas.Post;
        end;
      end;
    end;
  end;
end;

procedure TfrmTrans.OnZipProgressEvent(Sender: TObject; FileName: string; Header: TZipHeader; Position: Int64);
begin
  if PreviousFilename <> FileName then
  begin
    Label3.Caption := ExtractFileName(FileName);
    PreviousFilename := FileName;
    ProgressBar1.Position := 0;
  end
  else
    ProgressBar1.Position := (Position * 100) div Header.UncompressedSize;
  Application.ProcessMessages;
end;

procedure TfrmTrans.pMainContainerClick(Sender: TObject);
var
  List: TStringList;
  i: integer;
begin
 {  List := TStringList.Create;
  for i := 0 to tvTreechk.Items.Count - 1 do
    if tvTreechk.Checked[tvTreechk.Items[i]] then
      List.Add('1')
    else
      List.Add('0');
  List.SaveToFile(PathTemp + 'treestateindex.src');
  List.Free;
  //UDM.tb_indice.Last;
  UDM.tb_indice.Edit;
  TBlobField(UDM.tb_indice.FieldByName('treeformat')).LoadFromFile(PathTemp + 'treestateindex.src');
  try
    UDM.tb_indice.Post;
    UDM.sms('Formato guardado.', 3);
  except
    on E: EFDException do
    begin
      UDM.tb_indice.Cancel;
      UDM.sms('No se pudo guardar el formato. Motivo: ' + e.Message, 1);
    end;
  end;      }
end;

procedure TfrmTrans.tvTreechkMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HT: THitTests;
  id: Integer;
  s: string;
begin
  HT := tvTreechk.GetHitTestInfoAt(X, Y);
  AnItemchk := tvTreechk.GetNodeAt(X, Y);
  if (HT - [htOnItem, htOnLabel] <> HT) then
  begin
    if Button = mbRight then
    begin
    end
    else
    begin
      if AnItemchk.Text <> '' then
      begin
        etiquetaNA := PDataRec(AnItemchk.data).Etiqueta;
        id := PDataRec(AnItemchk.Data).id;
        Marcadas.Locate('id', id, []);
      end;
    end;
  end;
end;

procedure TfrmTrans.UnzipFile(const ZipFileName, OutputPath: string);
begin
  TZipFile.ExtractZipFile(ZipFileName, OutputPath, OnZipProgressEvent);
end;

procedure TfrmTrans.UpDateIdx;
begin
  //if True then

  tb_indiceinfo.Edit;
  tb_indiceinfo.FieldByName('Estructura').AsInteger := CantidadS;
  tb_indiceinfo.FieldByName('Cantsubseries').AsInteger := CantidadSS;
  tb_indiceinfo.FieldByName('CantDocumentos').AsInteger := CantDoc;
  tb_indiceinfo.FieldByName('CantFuentes').AsInteger := Cantfuentes;
  tb_indiceinfo.FieldByName('CantFAD').AsInteger := CantAD;
  try
    tb_indiceinfo.Post;
  except
    on E: EFDException do
    begin
      tb_indiceinfo.Cancel;
      UDM.sms('No se pudieron actualizar los datos de la exportación. Motivo: ' + e.Message, 1);
    end;
  end;
end;

procedure TfrmTrans.ZipDirectory(const Directory, ZipFileName: string);
begin
  TZipFile.ZipDirectoryContents(ZipFileName, Directory, zcDeflate, OnZipProgressEvent);
end;

procedure TfrmTrans.ReiniciaComponentes;
begin
  edt1.Text := '';
  PLoadAndSaveIndexFile.Visible := False;
  PDetalles.Visible := False;
  btnImportIndex.Caption := '';
  accion := '';
end;

procedure TfrmTrans.CleanDataSet;
begin
  tb_indiceinfo.Last;
  while not tb_indiceinfo.Bof do
    tb_indiceinfo.Delete;
  Marcadas.Last;
  while not Marcadas.Bof do
    Marcadas.Delete;
  Origen.Active := False;
  Destino.Active := False;
  with SQLConn do
  begin
    Connected := False;
    Params.Clear;
  end;
end;

procedure TfrmTrans.RestableceForm;
var
  h, w: Integer;
begin
  Height := 176;
  Constraints.MinHeight := 176;
  Constraints.MaxHeight := 176;
  w := Screen.Width;
  h := screen.Height;
  top := (trunc(h / 2) - (trunc(height / 2) + 50));
  BringToFront;
end;

procedure TfrmTrans.CancelarProcess;
begin
  CleanDataSet;
  ReiniciaComponentes;
  RestableceForm;
end;

procedure TfrmTrans.tvTreechkNodeCheckedChanged(Sender: TObject; Node: TTreeNode; NewState: Boolean);
var
  Estructura, s: string;
  id: Integer;

  procedure MarcarNodos(nodo: TTreeNode; V: Boolean; S: string);
  var
    i: Integer;
  begin
    tvTreechk.Checked[nodo] := V;
    if S = 's' then
    begin
      for i := 0 to nodo.Count - 1 do
        MarcarNodos(nodo.Item[i], V, S);
    end
    else
  // Marcar los padres del nodo actual
      if Assigned(nodo.Parent) then
      MarcarNodos(nodo.Parent, V, S);
  end;

  function GetCountOfStruct: Integer;
  var
    i, tmp: integer;
  begin
    result := 0;
    tmp := 0;
    UDM.tb_tree.DisableControls;
    for i := 0 to tvTreechk.Items.Count - 1 do
      if (tvTreechk.Checked[tvTreechk.Items[i]]) then
        if UDM.tb_tree.Locate('id', PDataRec(tvTreechk.Items[i].Data).id, []) then
        begin
          if UDM.tb_tree.FieldByName('tipo').AsInteger = 2 then
          begin
            tmp := tmp + 1;
          end;
//          CantidadSS := CantidadSS + UDM.tb_Serietree.RecordCount;
          CantidadSS := CantidadSS + UDM.Conn.ExecSQLScalar('select count(*) as cant from tb_Serietree where id=' + inttostr(PDataRec(tvTreechk.Items[i].Data).id));
          CantDoc := CantDoc + UDM.Conn.ExecSQLScalar('select count(*) as cant from tb_seriesdatos where id=' + inttostr(PDataRec(tvTreechk.Items[i].Data).id));
          Cantfuentes := Cantfuentes + UDM.Conn.ExecSQLScalar('select count(*) as cant from tb_ssArchdigital where fuente=' + QuotedStr('S') + ' and id=' + inttostr(PDataRec(tvTreechk.Items[i].Data).id));
          CantAD := CantAD + UDM.Conn.ExecSQLScalar('select count(*) as cant from tb_ssArchdigital where fuente=' + QuotedStr('N') + ' and id=' + inttostr(PDataRec(tvTreechk.Items[i].Data).id));
        end;
    UDM.tb_tree.EnableControls;
    result := tmp;
  end;

begin
  if accion = 'E' then
  begin
    CantidadS := 0;
    CantidadSS := 0;
    CantDoc := 0;
    Cantfuentes := 0;
    CantAD := 0;
    if NewState then
    begin
      MarcarNodos(Node, NewState, 's');
      MarcarNodos(Node, NewState, 'p');
    end
    else
      MarcarNodos(Node, NewState, 's');
    CantidadS := GetCountOfStruct;
    UpDateIdx;
  end;
end;

end.

