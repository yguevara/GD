unit UManagementIndex;

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
  AdvMenus, AdvPanel, winapi.shellapi;

type
  TfrmIEIndex = class(TForm)
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
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
    Panel2: TPanel;
    TotalProgress: TGauge;
    PartialProgress: TGauge;
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
    btnRefresh: TJvTransparentButton;
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
    procedure JvTransparentButton1Click(Sender: TObject);
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
  end;

var
  AnItemchk: TTreeNode;
  CantidadS, CantidadSS, CantDoc, Cantfuentes, CantAD, CantDocCoord: Integer;
  EnProcesoE, EnProcesoI: boolean;

const
  IndexTable: array[1..6] of string[20] = ('tb_tree', 'tb_Serietree', 'tb_SeriesDatos', 'tb_ssArchdigital', 'tb_DocCoord', 'tb_indiceinfo');

procedure ExportIndex;

implementation

uses
  UCapaDatos;

{$R *.dfm}

procedure ExportIndex;
begin
  with TfrmIEIndex.Create(nil) do
  try
      Caption := 'Interfaz para la gestión de índices de la base de datos.';
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfrmIEIndex.btnExportClick(Sender: TObject);
var
  bm: TBookmark;
  idx, index: integer;
  CantEstruct, CantSeries, CantDoc, CantF, CantAD: integer;
begin
  if (EnProcesoE) then
  begin
    if UDM.sms('Se ha detectado un proceso de exportación de índices en curso. ¿Desea cancelarlo?', 4) = 6 then
    begin
      EnProcesoE := False;
      CancelarProcess;
      exit;
    end;
  end;

  if EnProcesoI then
  begin
    if UDM.sms('Se ha detectado un proceso de importación de índices en curso. ¿Desea cancelarlo?', 4) = 6 then
    begin
      EnProcesoI := False;
      CancelarProcess;
      exit;
    end;
  end;

  if UDM.sms('¿Desea crear un índice de la información almacenada?', 4) = 6 then
  begin
    accion := 'E';
    EnProcesoE := True;
    btnImportIndex.Caption := 'Exportar índices';
    btnImportIndex.Visible := True;
    lblTitle.Caption := 'Por favor escoja una ruta válida para salvar el contenido a exportar.';
    PLoadAndSaveIndexFile.Visible := True;
    UDM.sms('Debe escoger una ruta válida donde se guardará el archivo de índices. ', 3);
  end;

end;

procedure TfrmIEIndex.btnFindInformeClick(Sender: TObject);
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
        if UDM.sms('Se ha detectado un proceso de exportación de índices en curso. ¿Desea cancelarlo?', 4) = 6 then
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
        if UDM.sms('Se ha detectado un proceso de importación de índices en curso. ¿Desea cancelarlo?', 4) = 6 then
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
            TR := GetAllRecordCount(SQLConn) - 1;
            TotalProgress.Progress := 0;
            TotalProgress.MinValue := 0;
            TotalProgress.MaxValue := TR;
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
            PDetalles.Visible := True;
            Height := 580;
            Constraints.MinHeight := 580;
            Constraints.MaxHeight := 580;
            Top := Trunc(Screen.Height / 2) - (trunc(height / 2) + 50);
          except
            on E: EFDException do
            begin
              UDM.sms('No se pudo acceder al fichero de índices. Motivo: ' + e.Message, 1);
              Exit;
            end;
          end;
        end;
      end;
  end;
end;

procedure TfrmIEIndex.btnImportClick(Sender: TObject);
begin
  //reinicia..
  if (EnProcesoE) then
  begin
    if UDM.sms('Se ha detectado un proceso de exportación de índices en curso. ¿Desea cancelarlo?', 4) = 6 then
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
    if UDM.sms('Se ha detectado un proceso de importación de índices en curso. ¿Desea cancelarlo?', 4) = 6 then
    begin
      EnProcesoI := False;
      CancelarProcess;
      exit;
    end
    else
      exit;
  end;
  ReiniciaComponentes;
  if UDM.sms('¿Desea importar un fichero de información indexada?', 4) = 6 then
  begin
    accion := 'I';
    EnProcesoI := True;
    btnImportIndex.Caption := 'Importar índices';
    btnImportIndex.Visible := True;
    lblTitle.Caption := 'Por favor especifique la ubicación del fichero de información indexada.';
    PLoadAndSaveIndexFile.Visible := True;
    UDM.sms('Por favor especifique una ruta válida donde se encuentre ubicado el fichero de información indexada. ', 3);
  end;
end;

procedure TfrmIEIndex.btnImportIndexClick(Sender: TObject);
var
  Fname, cad: string;
  i, INDEX: Integer;

  function copiar: Boolean;
  begin
    Pathtransplt := PathSys + 'BD\indexplt.db';
    try
      CopyFile(Pchar(Pathtransplt), PChar(Fname), FALSE);
      Result := True;
    except
      on E: EFilerError do
      begin
        UDM.sms('No se pudo convertir la base de datos en GeoDato. Motivo: ' + E.Message, 1);
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

  procedure copiaregistros;
  var
    i: integer;
  begin
    if origen.RecordCount = 0 then
      Exit;
    PartialProgress.Progress := 0;
    PartialProgress.MinValue := 0;
    PartialProgress.MaxValue := Origen.RecordCount - 1;
    Origen.First;
    while not Origen.Eof do
    begin
      Destino.Append;
      for i := 0 to Origen.FieldCount - 1 do
        Destino.FieldByName(Origen.Fields[i].FieldName).Value := Origen.Fields[i].Value;
      try
        destino.Post;
      except
        on E: EFDException do
        begin
          UDM.sms(e.Message, 1);
          destino.Cancel;
        end;
      end;
      PartialProgress.Progress := PartialProgress.Progress + 1;
      TotalProgress.Progress := TotalProgress.Progress + 1;
      Application.ProcessMessages;
      origen.Next;
    end;
    PartialProgress.Progress := PartialProgress.MaxValue;
    PartialProgress.Progress := 0;
  end;

begin
  if accion = 'E' then
  begin
    //Export...
    if trim(edt1.Text) = '' then
    begin
      UDM.sms('Debe escoger una ruta válida antes de continuar el proceso.', 2);
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
        TR := GetAllRecordCount(UDM.Conn) - 1;
        TotalProgress.Progress := 0;
        TotalProgress.MinValue := 0;
        TotalProgress.MaxValue := TR;
        ExecSQL('VACUUM;');
        configuraIdx(destino);
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
              copiaregistros;
              destino.Edit;
              destino.FieldByName('marca').Value := True;
              destino.Post;
              configTable(IndexTable[2], Origen, INDEX);
              copiaregistros;
              configTable(IndexTable[3], Origen, INDEX);
              copiaregistros;
              configTable(IndexTable[4], Origen, INDEX);
              copiaregistros;
              configTable(IndexTable[5], Origen, INDEX);
              copiaregistros;
            end;
          end;
        end;
        PartialProgress.Progress := 0;
        TotalProgress.Progress := TotalProgress.MaxValue;
        UDM.sms('El proceso de exportación ha terminado satisfactoriamente.', 3);
        Application.ProcessMessages;
        ExecSQL('VACUUM;');
        CancelarProcess;
        ShellExecute(0, nil, '', '', PWideChar(ExtractFilePath(edt1.Text)), SW_SHOW);
      except
        on E: EFDException do
        begin
          UDM.sms('No se pudo acceder al fichero de índices. Motivo: ' + e.Message, 1);
          Exit;
        end;
      end;
    end;
  end
  else if accion = 'I' then
  begin
    tb_treeO.Active:=True;
    tb_SerietreeO.Active:=True;
    tb_SeriesDatosO.Active:=True;
    tb_ssArchdigitalO.Active:=True;
    tb_DocCoordO.Active:=True;
    tb_tree.Active:=True;
    tb_Serietree.Active:=True;
    tb_SeriesDatos.Active:=True;
    tb_ssArchdigital.Active:=True;
    tb_DocCoord.Active:=True;
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
    while not tb_SeriesDatosO.Eof do
    begin
      if not tb_SeriesDatos.Locate('IdEstructura;id;codsubs;Fecha;Version;Codigodoc', VarArrayOf([tb_SeriesDatosO.FieldByName('IdEstructura').AsString, tb_SeriesDatosO.FieldByName('id').AsString, tb_SeriesDatosO.FieldByName('codsubs').AsString, tb_SeriesDatosO.FieldByName('Fecha').AsString, tb_SeriesDatosO.FieldByName('Version').AsString, tb_SeriesDatosO.FieldByName('Codigodoc').AsString]), []) then
        tb_SeriesDatos.Append
      else
        tb_SeriesDatos.Edit;
      for i := 0 to tb_SeriesDatos.FieldCount - 1 do
        tb_SeriesDatos.Fields[i].Value := tb_SeriesDatosO.FieldByName(tb_SeriesDatos.Fields[i].FieldName).Value;
      try
        tb_SeriesDatos.Post;
      except
        tb_SeriesDatos.Cancel;
      end;
      tb_SeriesDatosO.Next;
    end;
    tb_ssArchdigitalO.First;
    while not tb_ssArchdigitalO.Eof do
    begin
      if not tb_ssArchdigital.Locate('IdEstructura;id;codsubs;Fecha;Version;Codigodoc;idhijo', VarArrayOf([tb_ssArchdigitalO.FieldByName('IdEstructura').AsString, tb_ssArchdigitalO.FieldByName('id').AsString, tb_ssArchdigitalO.FieldByName('codsubs').AsString, tb_ssArchdigitalO.FieldByName('Fecha').AsString, tb_ssArchdigitalO.FieldByName('Version').AsString, tb_ssArchdigitalO.FieldByName('Codigodoc').AsString, tb_ssArchdigitalO.FieldByName('idhijo').AsString]), []) then
        tb_ssArchdigital.Append
      else
        tb_ssArchdigital.Edit;
      for i := 0 to tb_ssArchdigital.FieldCount - 1 do
        tb_ssArchdigital.Fields[i].Value := tb_ssArchdigitalO.FieldByName(tb_ssArchdigital.Fields[i].FieldName).Value;
      try
        tb_ssArchdigital.Post;
      except
        tb_ssArchdigital.Cancel;
      end;
      tb_ssArchdigitalO.Next;
    end;
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
    UDM.tb_tree.FetchAll();
    udm.tb_Serietree.FetchAll;
    udm.tb_SeriesDatos.FetchAll;
    UDM.tb_ssArchdigital.FetchAll;
    UDM.tb_DocCoord.FetchAll;
    showmessage('yaaaaaa');








  {  tb_tree.Active := True;
    tb_Serietree.Active := True;
    tb_SeriesDatos.Active := True;
    tb_ssArchdigital.Active := True;
    tb_DocCoord.Active := True;
    UDM.tb_tree.Active := True;
    UDM.tb_Serietree.Active := True;
    UDM.tb_SeriesDatos.Active := True;
    UDM.tb_ssArchdigital.Active := True;
    UDM.tb_DocCoord.Active := True;
    UDM.tb_Serietree.MasterSource := nil;
    udm.tb_Serietree.MasterFields := '';
    udm.tb_Serietree.IndexFieldNames := '';
    UDM.tb_SeriesDatos.MasterSource := nil;
    udm.tb_SeriesDatos.MasterFields := '';
    udm.tb_SeriesDatos.IndexFieldNames := '';
    UDM.tb_ssArchdigital.MasterSource := nil;
    udm.tb_ssArchdigital.MasterFields := '';
    udm.tb_ssArchdigital.IndexFieldNames := '';
    UDM.tb_DocCoord.MasterSource := nil;
    udm.tb_DocCoord.MasterFields := '';
    udm.tb_DocCoord.IndexFieldNames := '';
    tb_tree.First;
    while not tb_tree.Eof do
    begin
      tb_Serietree.First;
      while not tb_Serietree.Eof do
      begin
        if not UDM.tb_Serietree.Locate('IdEstructura;id;codsubs', VarArrayOf([tb_Serietree.FieldByName('IdEstructura').asstring, tb_Serietree.FieldByName('id').asstring, tb_Serietree.FieldByName('codsubs').asstring]), []) then
          UDM.tb_Serietree.Append
        else
          UDM.tb_Serietree.Edit;
        for i := 0 to udm.tb_Serietree.FieldCount - 1 do
          UDM.tb_Serietree.Fields[i].Value := tb_Serietree.FieldByName(udm.tb_Serietree.Fields[i].FieldName).Value;
        try
          UDM.tb_Serietree.Post;
        except
          UDM.tb_Serietree.Cancel;
        end;
        tb_SeriesDatos.First;
        while not tb_SeriesDatos.Eof do
        begin
          if not UDM.tb_SeriesDatos.Locate('IdEstructura;id;codsubs;Fecha;Version;Codigodoc', VarArrayOf([tb_SeriesDatos.FieldByName('IdEstructura').AsString, tb_SeriesDatos.FieldByName('id').AsString, tb_SeriesDatos.FieldByName('codsubs').AsString, tb_SeriesDatos.FieldByName('Fecha').AsString, tb_SeriesDatos.FieldByName('Version').AsString, tb_SeriesDatos.FieldByName('Codigodoc').AsString]), []) then
            UDM.tb_SeriesDatos.Append
          else
            UDM.tb_SeriesDatos.Edit;
          for i := 0 to udm.tb_SeriesDatos.FieldCount - 1 do
            UDM.tb_SeriesDatos.Fields[i].Value := tb_SeriesDatos.FieldByName(udm.tb_SeriesDatos.Fields[i].FieldName).Value;
          try
            UDM.tb_SeriesDatos.Post;
          except
            UDM.tb_SeriesDatos.Cancel;
          end;
          tb_ssArchdigital.First;
          while not tb_ssArchdigital.eof do
          begin
            if not UDM.tb_ssArchdigital.Locate('IdEstructura;id;codsubs;Fecha;Version;Codigodoc;idhijo', VarArrayOf([tb_ssArchdigital.FieldByName('IdEstructura').AsString, tb_ssArchdigital.FieldByName('id').AsString, tb_ssArchdigital.FieldByName('codsubs').AsString, tb_ssArchdigital.FieldByName('Fecha').AsString, tb_ssArchdigital.FieldByName('Version').AsString, tb_ssArchdigital.FieldByName('Codigodoc').AsString, tb_ssArchdigital.FieldByName('idhijo').AsString]), []) then
              UDM.tb_ssArchdigital.Append
            else
              UDM.tb_ssArchdigital.Edit;
            for i := 0 to udm.tb_ssArchdigital.FieldCount - 1 do
              UDM.tb_ssArchdigital.Fields[i].Value := tb_ssArchdigital.FieldByName(udm.tb_ssArchdigital.Fields[i].FieldName).Value;
            try
              UDM.tb_ssArchdigital.Post;
            except
              UDM.tb_ssArchdigital.Cancel;
            end;
            tb_ssArchdigital.Next;
          end;
          tb_DocCoord.First;
          while not tb_DocCoord.Eof do
          begin
            if not UDM.tb_DocCoord.Locate('IdEstructura;id;codsubs;Fecha;Version;Codigodoc;idvertice', VarArrayOf([tb_DocCoord.FieldByName('IdEstructura').AsString, tb_DocCoord.FieldByName('id').AsString, tb_DocCoord.FieldByName('codsubs').AsString, tb_DocCoord.FieldByName('Fecha').AsString, tb_DocCoord.FieldByName('Version').AsString, tb_DocCoord.FieldByName('idvertice').AsString]), []) then
              UDM.tb_DocCoord.Append
            else
              UDM.tb_DocCoord.Edit;
            for i := 0 to udm.tb_DocCoord.FieldCount - 1 do
              UDM.tb_DocCoord.Fields[i].Value := tb_DocCoord.FieldByName(udm.tb_DocCoord.Fields[i].FieldName).Value;
            try
              UDM.tb_DocCoord.Post;
            except
              UDM.tb_DocCoord.Cancel;
            end;
            tb_DocCoord.Next;
          end;

          tb_SeriesDatos.Next;
        end;
        tb_Serietree.Next;
      end;
      tb_tree.Next;
    end;
    PartialProgress.Progress := 0;
    TotalProgress.Progress := TotalProgress.MaxValue;

    UDM.sms('El proceso de Importación ha terminado satisfactoriamente.', 3);
    UDM.sms('Para aplicar los cambios debe reiniciar la aplicación.', 3);
    Application.Terminate; }
  end;

end;

procedure TfrmIEIndex.btnRefreshClick(Sender: TObject);
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

procedure TfrmIEIndex.btnSystemHelpClick(Sender: TObject);
var
  i: integer;
  List: TStringList;
begin
  CantidadS := 0;
  CantidadSS := 0;
  CantDoc := 0;
  Cantfuentes := 0;
  CantAD := 0;
  UDM.tb_indice.Last;
  TBlobField(UDM.tb_indice.FieldByName('treeformat')).SaveToFile(PathTemp + 'treestateindex.src');
  List := TStringList.Create;
  List.LoadFromFile(PathTemp + 'treestateindex.src');
  for i := 0 to List.Count - 1 do
  begin
    if List[i] = '1' then
      tvTreechk.Checked[tvTreechk.Items[i]] := true
    else
      tvTreechk.Checked[tvTreechk.Items[i]] := False;

  end;
  ShowMessage('yaaa');

end;

function TfrmIEIndex.configTable(nombreTabla: string; dsOrigen: TFDQuery; aIdStruct: integer): boolean;
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

procedure TfrmIEIndex.configuraIdx(dsOrigen: TFDQuery);
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

procedure TfrmIEIndex.CopiarREG(Opt: integer);
var
  i, PR: integer;
  MF, IFN: string;
begin
  case Opt of
    1:
      begin
        if origen.RecordCount = 0 then
          Exit;
        PartialProgress.Progress := 0;
        PartialProgress.MinValue := 0;
        PartialProgress.MaxValue := Origen.RecordCount - 1;
        Origen.First;
        Marcadas.First;
        while not Origen.Eof do
        begin
          Marcadas.Locate('id', UDM.tb_tree.FieldByName('id').AsInteger, []);
          Destino.Append;
          for i := 0 to Origen.FieldCount - 1 do
            Destino.FieldByName(Origen.Fields[i].FieldName).Value := Origen.Fields[i].Value;
          destino.FieldByName('marca').Value := Marcadas.Fields[1].Value;
          try
            destino.Post;
          except
            on E: EFDException do
            begin
              UDM.sms(e.Message, 1);
              destino.Cancel;
            end;
          end;
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          origen.Next;
        end;
        PartialProgress.Progress := PartialProgress.MaxValue;
        PartialProgress.Progress := 0;
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
        PartialProgress.Progress := 0;
        PartialProgress.MinValue := 0;
        PartialProgress.MaxValue := UDM.tb_Serietree.RecordCount - 1;
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
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          UDM.tb_Serietree.Next;
        end;
        PartialProgress.Progress := PartialProgress.MaxValue;
       { UDM.tb_Serietree.MasterSource := UDM.dstb_tree;
        UDM.tb_Serietree.MasterFields := MF;
        UDM.tb_Serietree.IndexFieldNames := IFN; }
        PartialProgress.Progress := 0;
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
        PartialProgress.Progress := 0;
        PartialProgress.MinValue := 0;
        PartialProgress.MaxValue := UDM.tb_SeriesDatos.RecordCount - 1;
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
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          UDM.tb_SeriesDatos.Next;
        end;
        PartialProgress.Progress := PartialProgress.MaxValue;
       { UDM.tb_SeriesDatos.MasterSource := UDM.dstb_Serietree;
        UDM.tb_SeriesDatos.MasterFields := MF;
        UDM.tb_SeriesDatos.IndexFieldNames := IFN; }
        PartialProgress.Progress := 0;
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
        PartialProgress.Progress := 0;
        PartialProgress.MinValue := 0;
        PartialProgress.MaxValue := UDM.tb_ssArchdigital.RecordCount - 1;
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
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          UDM.tb_ssArchdigital.Next;
        end;
        PartialProgress.Progress := PartialProgress.MaxValue;
        {UDM.tb_ssArchdigital.MasterSource := UDM.dstb_SeriesDatos;
        UDM.tb_ssArchdigital.MasterFields := MF;
        UDM.tb_ssArchdigital.IndexFieldNames := IFN;  }
        PartialProgress.Progress := 0;
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
        PartialProgress.Progress := 0;
        PartialProgress.MinValue := 0;
        PartialProgress.MaxValue := UDM.tb_DocCoord.RecordCount - 1;
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
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          UDM.tb_DocCoord.Next;
        end;
        PartialProgress.Progress := PartialProgress.MaxValue;
        UDM.tb_DocCoord.MasterSource := UDM.dstb_SeriesDatos;
        UDM.tb_DocCoord.MasterFields := MF;
        UDM.tb_DocCoord.IndexFieldNames := IFN;
      end;
    6:
      begin
        if tb_indiceinfo.RecordCount = 0 then
          Exit;
        tb_indiceinfo.First;
        PartialProgress.Progress := 0;
        PartialProgress.MinValue := 0;
        PartialProgress.MaxValue := tb_indiceinfo.RecordCount - 1;
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
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          tb_indiceinfo.Next;
        end;
        PartialProgress.Progress := PartialProgress.MaxValue;
      end;
  end;

end;

procedure TfrmIEIndex.FormCreate(Sender: TObject);
begin
  EnProcesoE := False;
  EnProcesoI := False;
  Height := 176;
  Constraints.MinHeight := 176;
  Constraints.MaxHeight := 176;
  Constraints.MinWidth := 894;
  Constraints.MaxWidth := 894;
end;

function TfrmIEIndex.GetAllRecordCount(cnn: TFDConnection): LongInt;
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

procedure TfrmIEIndex.ImportIdxREG(Opt: integer);
var
  i: integer;
  MF, IFN: string;
begin
  if Origen.RecordCount = 0 then
    exit;
  PartialProgress.Progress := 0;
  PartialProgress.MinValue := 0;
  PartialProgress.MaxValue := Origen.RecordCount - 1;
  case Opt of
    1:
      begin
        origen.First;
        while not Origen.Eof do
        begin
          if not UDM.tb_tree.Locate('IdEstructura;Id', VarArrayOf([Origen.FieldByName('IdEstructura').AsString, Origen.FieldByName('Id').AsString]), []) then
          begin
            UDM.tb_tree.Append;
            for i := 0 to UDM.tb_tree.FieldCount - 1 do
              UDM.tb_tree.Fields[i].Value := Origen.FieldByName(UDM.tb_tree.Fields[i].FieldName).Value;
            try
              UDM.tb_tree.Post;
            except
              on E: EFDException do
              begin
                UDM.sms(e.Message, 1);
                UDM.tb_tree.Cancel;
              end;
            end;
          end;
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          Origen.Next;
        end;
        PartialProgress.Progress := PartialProgress.MaxValue;
        PartialProgress.Progress := 0;
      end;
    2:
      begin
        UDM.tb_Serietree.MasterSource := nil;
        MF := UDM.tb_Serietree.MasterFields;
        IFN := UDM.tb_Serietree.IndexFieldNames;
        UDM.tb_Serietree.MasterFields := '';
        UDM.tb_Serietree.IndexFieldNames := '';
        origen.First;
        while not Origen.Eof do
        begin
          if not UDM.tb_Serietree.Locate('IdEstructura;Id;codsubs', VarArrayOf([Origen.FieldByName('IdEstructura').AsString, Origen.FieldByName('Id').AsString, Origen.FieldByName('codsubs').AsString]), []) then
          begin
            UDM.tb_Serietree.Append;
            for i := 0 to UDM.tb_Serietree.FieldCount - 1 do
              UDM.tb_Serietree.Fields[i].Value := Origen.FieldByName(UDM.tb_Serietree.Fields[i].FieldName).Value;
            try
              UDM.tb_Serietree.Post;
            except
              on E: EFDException do
              begin
                UDM.sms(e.Message, 1);
                UDM.tb_Serietree.Cancel;
              end;
            end;
          end;
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          Origen.Next;
        end;
        UDM.tb_Serietree.MasterSource := UDM.dstb_tree;
        UDM.tb_Serietree.MasterFields := MF;
        UDM.tb_Serietree.IndexFieldNames := IFN;
        PartialProgress.Progress := PartialProgress.MaxValue;
        PartialProgress.Progress := 0;
      end;
    3:
      begin
        UDM.tb_SeriesDatos.MasterSource := nil;
        MF := UDM.tb_SeriesDatos.MasterFields;
        IFN := UDM.tb_SeriesDatos.IndexFieldNames;
        UDM.tb_SeriesDatos.MasterFields := '';
        UDM.tb_SeriesDatos.IndexFieldNames := '';
        origen.First;
        while not Origen.Eof do
        begin
          if not UDM.tb_SeriesDatos.Locate('IdEstructura;Id;codsubs;Fecha;Version', VarArrayOf([Origen.FieldByName('IdEstructura').AsString, Origen.FieldByName('Id').AsString, Origen.FieldByName('codsubs').AsString, Origen.FieldByName('Fecha').AsString, Origen.FieldByName('Version').AsString]), []) then
          begin
            UDM.tb_SeriesDatos.Append;
            for i := 0 to UDM.tb_SeriesDatos.FieldCount - 1 do
              UDM.tb_SeriesDatos.Fields[i].Value := Origen.FieldByName(UDM.tb_SeriesDatos.Fields[i].FieldName).Value;
            try
              UDM.tb_SeriesDatos.Post;
            except
              on E: EFDException do
              begin
                UDM.sms(e.Message, 1);
                UDM.tb_SeriesDatos.Cancel;
              end;
            end;
          end;
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          Origen.Next;
        end;
        UDM.tb_SeriesDatos.MasterSource := UDM.dstb_Serietree;
        UDM.tb_SeriesDatos.MasterFields := MF;
        UDM.tb_SeriesDatos.IndexFieldNames := IFN;
        PartialProgress.Progress := PartialProgress.MaxValue;
        PartialProgress.Progress := 0;
      end;
    4:
      begin
        UDM.tb_ssArchdigital.MasterSource := nil;
        MF := UDM.tb_ssArchdigital.MasterFields;
        IFN := UDM.tb_ssArchdigital.IndexFieldNames;
        UDM.tb_ssArchdigital.MasterFields := '';
        UDM.tb_ssArchdigital.IndexFieldNames := '';
        origen.First;
        while not Origen.Eof do
        begin
          if not UDM.tb_ssArchdigital.Locate('IdEstructura;Id;codsubs;Fecha;Version;idhijo', VarArrayOf([Origen.FieldByName('IdEstructura').AsString, Origen.FieldByName('Id').AsString, Origen.FieldByName('codsubs').AsString, Origen.FieldByName('Fecha').AsString, Origen.FieldByName('Version').AsString, Origen.FieldByName('idhijo').AsString]), []) then
          begin
            UDM.tb_ssArchdigital.Append;
            for i := 0 to UDM.tb_ssArchdigital.FieldCount - 1 do
              UDM.tb_ssArchdigital.Fields[i].Value := Origen.FieldByName(UDM.tb_ssArchdigital.Fields[i].FieldName).Value;
            try
              UDM.tb_ssArchdigital.Post;
            except
              on E: EFDException do
              begin
                UDM.sms(e.Message, 1);
                UDM.tb_ssArchdigital.Cancel;
              end;
            end;
          end;
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          Origen.Next;
        end;
        PartialProgress.Progress := PartialProgress.MaxValue;
        PartialProgress.Progress := 0;
        UDM.tb_ssArchdigital.MasterSource := UDM.dstb_SeriesDatos;
        UDM.tb_ssArchdigital.MasterFields := MF;
        UDM.tb_ssArchdigital.IndexFieldNames := IFN;
      end;
    5:
      begin
        UDM.tb_DocCoord.MasterSource := nil;
        MF := UDM.tb_DocCoord.MasterFields;
        IFN := UDM.tb_DocCoord.IndexFieldNames;
        UDM.tb_DocCoord.MasterFields := '';
        UDM.tb_DocCoord.IndexFieldNames := '';
        origen.First;
        while not Origen.Eof do
        begin
          if not UDM.tb_DocCoord.Locate('IdEstructura;Id;codsubs;Fecha;Version;idVertice', VarArrayOf([Origen.FieldByName('IdEstructura').AsString, Origen.FieldByName('Id').AsString, Origen.FieldByName('codsubs').AsString, Origen.FieldByName('Fecha').AsString, Origen.FieldByName('Version').AsString, Origen.FieldByName('idVertice').AsString]), []) then
          begin
            UDM.tb_DocCoord.Append;
            for i := 0 to UDM.tb_DocCoord.FieldCount - 1 do
              UDM.tb_DocCoord.Fields[i].Value := Origen.FieldByName(UDM.tb_DocCoord.Fields[i].FieldName).Value;
            try
              UDM.tb_DocCoord.Post;
            except
              on E: EFDException do
              begin
                UDM.sms(e.Message, 1);
                UDM.tb_DocCoord.Cancel;
              end;
            end;
          end;
          PartialProgress.Progress := PartialProgress.Progress + 1;
          TotalProgress.Progress := TotalProgress.Progress + 1;
          Application.ProcessMessages;
          Origen.Next;
        end;
        PartialProgress.Progress := PartialProgress.MaxValue;
        PartialProgress.Progress := 0;
        UDM.tb_DocCoord.MasterSource := UDM.dstb_SeriesDatos;
        UDM.tb_DocCoord.MasterFields := MF;
        UDM.tb_DocCoord.IndexFieldNames := IFN;
      end;

  end;

end;

procedure TfrmIEIndex.JvTransparentButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmIEIndex.MarcaHijos(conn: TFDConnection; IdNodo: string; V: boolean);
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

procedure TfrmIEIndex.MarcaNodoyPadres(IdNodo: TTreenode; V: boolean);
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

procedure TfrmIEIndex.pMainContainerClick(Sender: TObject);
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

procedure TfrmIEIndex.tvTreechkMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TfrmIEIndex.UpDateIdx;
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

procedure TfrmIEIndex.ReiniciaComponentes;
begin
  edt1.Text := '';
  PLoadAndSaveIndexFile.Visible := False;
  PDetalles.Visible := False;
  btnImportIndex.Caption := '';
  accion := '';
end;

procedure TfrmIEIndex.CleanDataSet;
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

procedure TfrmIEIndex.RestableceForm;
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

procedure TfrmIEIndex.CancelarProcess;
begin
  CleanDataSet;
  ReiniciaComponentes;
  RestableceForm;
end;

procedure TfrmIEIndex.tvTreechkNodeCheckedChanged(Sender: TObject; Node: TTreeNode; NewState: Boolean);
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

