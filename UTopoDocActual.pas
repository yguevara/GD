unit UTopoDocActual;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  JvExControls, JvButton, JvTransparentButton, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, dxSkinsCore,
  dxSkinsDefaultPainters, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit,
  cxNavigator, dxDateRanges, cxDBData, cxBlobEdit, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGridLevel, cxClasses, cxGridCustomView,
  cxGrid, cxImage, cxVGrid, cxDBVGrid, cxInplaceContainer, cxDropDownEdit;

type
  TfrmUbicaDocActual = class(TForm)
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    Edit1: TEdit;
    cmdtopo: TFDQuery;
    cxDBVerticalGrid5: TcxDBVerticalGrid;
    cxCategoryRow2: TcxCategoryRow;
    cxDBVerticalGrid5nombreArchivo: TcxDBEditorRow;
    cxDBVerticalGrid5deposito: TcxDBEditorRow;
    cxDBVerticalGrid5gaveta: TcxDBEditorRow;
    cxDBVerticalGrid5posicion: TcxDBEditorRow;
    cxDBVerticalGrid5etiquetaServ: TcxDBEditorRow;
    cxDBVerticalGrid5croquis: TcxDBEditorRow;
    cxDBVerticalGrid5Foto: TcxDBEditorRow;
    cxDBVerticalGrid5NombreResponsable: TcxDBEditorRow;
    cxDBVerticalGrid5CorreoElect: TcxDBEditorRow;
    cxDBVerticalGrid5Telefono: TcxDBEditorRow;
    cxDBVerticalGrid5CategoryRow1: TcxCategoryRow;
    dscmdtopo: TDataSource;
    procedure JvTransparentButton1Click(Sender: TObject);
    procedure btnSystemHelpClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowTopografia(DocumentoID: string);
    function ObtenerImagenDesdeBD(DocumentoID: string; CampoImagen: String): TStream;
    function ObtenerDatoTopografia(DocumentoID: string):string;
  end;

var
  frmUbicaDocActual: TfrmUbicaDocActual;

implementation

uses
  UCapaDatos;

{$R *.dfm}

{ TfrmUbicaDocActual }


procedure TfrmUbicaDocActual.btnSystemHelpClick(Sender: TObject);
begin
  Application.HelpContext(79);
end;

procedure TfrmUbicaDocActual.FormActivate(Sender: TObject);
begin
  cmdtopo.Open();
end;

procedure TfrmUbicaDocActual.JvTransparentButton1Click(Sender: TObject);
begin
  Close;
end;

function TfrmUbicaDocActual.ObtenerDatoTopografia(DocumentoID: string): string;
var
  cad:string;
begin
  with cmdtopo do begin
    Active:=False;
    cad:='SELECT cl_ArchivosGestion.nombreArchivo, tb_SeriesDatos.deposito, ';
    cad:=cad+'tb_SeriesDatos.gaveta, tb_SeriesDatos.posicion, cl_ftp_Server.etiquetaServ, ';
    cad:=cad+'cl_ArchivosGestion.croquis, cl_ArchivosGestion.Foto, cl_Resp_Gest_Arch.NombreResponsable, ';
    cad:=cad+'cl_Resp_Gest_Arch.CorreoElect, cl_Resp_Gest_Arch.Telefono FROM ((tb_SeriesDatos LEFT ';
    cad:=cad+'JOIN cl_ArchivosGestion ON tb_SeriesDatos.Archivo = cl_ArchivosGestion.Cod) ';
    cad:=cad+'LEFT JOIN cl_ftp_Server ON tb_SeriesDatos.Idservidor = cl_ftp_Server.Idservidor) ';
    cad:=cad+'LEFT JOIN cl_Resp_Gest_Arch ON cl_ArchivosGestion.Idresp = cl_Resp_Gest_Arch.Idresp ';
    cad:=cad+'WHERE tb_SeriesDatos.Codigodoc = '+QuotedStr(DocumentoID);
    SQL.Clear;
    SQL.Text:=cad;
    try
      active:=True;
    except
      on E:EFDException do
        UDM.sms('No se pudo consultar la topografía del documento actual. Motivo: '+e.Message, 3);
    end;
  end;
end;

function TfrmUbicaDocActual.ObtenerImagenDesdeBD(DocumentoID: string;
  CampoImagen: String): TStream;
var
  Query: TFDQuery;
  BlobField: TBlobField;
  MemoryStream: TMemoryStream;
begin
  Result := nil;

  // Crear consulta para obtener la imagen
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := udm.conn; // Asignar la conexión a la base de datos
    Query.SQL.Text := 'SELECT cl_ArchivosGestion.'+CampoImagen+' FROM tb_SeriesDatos LEFT JOIN cl_ArchivosGestion ON tb_SeriesDatos.Archivo = cl_ArchivosGestion.Cod WHERE Codigodoc='+QuotedStr(DocumentoID);
    Query.Open;

    // Si el campo de imagen es un BLOB, cargarlo en un TStream
    BlobField := Query.FieldByName(CampoImagen) as TBlobField;
    if not BlobField.IsNull then
    begin
      MemoryStream := TMemoryStream.Create;
      BlobField.SaveToStream(MemoryStream);
      MemoryStream.Position := 0; // Resetear la posición del stream
      Result := MemoryStream; // Devolver el stream
    end;
  finally
    Query.Free;
  end;
end;

procedure TfrmUbicaDocActual.ShowTopografia(DocumentoID: string);
begin
  ObtenerDatoTopografia(DocumentoID);
end;

end.
