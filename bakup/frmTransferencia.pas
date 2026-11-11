unit frmTransferencia;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, dxSkinsCore, dxSkinsDefaultPainters,
  cxContainer, cxEdit, cxTextEdit, cxMemo, cxDropDownEdit, cxLookupEdit,
  cxDBLookupEdit, cxDBExtLookupComboBox, cxMaskEdit, cxCalendar, Vcl.StdCtrls,
  cxButtons, cxGrid, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, Vcl.ExtCtrls, cxLabel, cxBlobEdit, cxDBEdit,
  cxDBLookupComboBox, Vcl.ComCtrls, AdvDateTimePicker, AdvDBDateTimePicker,
  Vcl.Mask, Vcl.DBCtrls, cxGroupBox, Vcl.Menus, JvExControls, JvButton,
  JvTransparentButton, System.ImageList, Vcl.ImgList, cxImageList, cxStyles,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxNavigator, dxDateRanges,
  cxDBData;

type
  TfrmTransferencias = class(TForm)
    OpenDialog1: TOpenDialog;
    Panel2: TPanel;
    cxLookAndFeelController1: TcxLookAndFeelController;
    cxGroupBox1: TcxGroupBox;
    edtCodTransf: TDBEdit;
    lblCodigo: TcxLabel;
    cxLabel2: TcxLabel;
    dtpFechaTransf: TAdvDBDateTimePicker;
    lcbUsuarioTransf: TcxDBLookupComboBox;
    lblUsuario: TcxLabel;
    cxGroupBox2: TcxGroupBox;
    dbmObs: TcxDBMemo;
    Panel3: TPanel;
    Panel4: TPanel;
    cxLabel1: TcxLabel;
    cxDBBlobEdit1: TcxDBBlobEdit;
    pMainContainer: TPanel;
    JvTransparentButton1: TJvTransparentButton;
    btnSystemHelp: TJvTransparentButton;
    btnPrint: TJvTransparentButton;
    Edit1: TEdit;
    cxGroupBox3: TcxGroupBox;
    Panel1: TPanel;
    btnClear: TcxButton;
    cxImageList1: TcxImageList;
    btnAdd: TcxButton;
    btnRemove: TcxButton;
    cxGrid1DBTableView1: TcxGridDBTableView;
    cxGrid1Level1: TcxGridLevel;
    cxGrid1: TcxGrid;
    JvTransparentButton3: TJvTransparentButton;

    procedure FormCreate(Sender: TObject);
    procedure btnAdjuntarActaClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
    procedure btnValidarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure btnAgregarDocClick(Sender: TObject);
    procedure btnQuitarDocClick(Sender: TObject);
    procedure btnLimpiarListaClick(Sender: TObject);
    procedure JvTransparentButton1Click(Sender: TObject);
  private
    ActaStream: TMemoryStream;
    FIdTransferencia: Integer;
    procedure CargarUsuarios;
    procedure PrepararGridDocumentos;
  public
    { Public declarations }
  end;

var
  frmTransferencias: TfrmTransferencias;

implementation

{$R *.dfm}

uses UCapaDatos;

procedure TfrmTransferencias.FormCreate(Sender: TObject);
begin
  CargarUsuarios;
  PrepararGridDocumentos;
//  dtpFecha.Date := Now;
end;

procedure TfrmTransferencias.JvTransparentButton1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmTransferencias.CargarUsuarios;
begin
  // Cargar usuarios en el combo desde tb_usuarios (usar FDQuery o TFDMemTable)
end;

procedure TfrmTransferencias.PrepararGridDocumentos;
begin
  // Vincular gridDocumentos a la memoria temporal de documentos seleccionados
end;

procedure TfrmTransferencias.btnAdjuntarActaClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    ActaStream := TMemoryStream.Create;
    ActaStream.LoadFromFile(OpenDialog1.FileName);
//    lblNombreArchivo.Caption := ExtractFileName(OpenDialog1.FileName);
  end;
end;

procedure TfrmTransferencias.btnGuardarClick(Sender: TObject);
var
  i: Integer;
begin
 { FIdTransferencia := InsertarTransferencia(
    txtCodigo.Text,
    dtpFecha.Date,
    cmbUsuarioEnvia.EditValue,
    memoObs.Text,
    lblNombreArchivo.Caption,
    ActaStream
  );

  for i := 0 to gridDocumentosView.DataController.RecordCount - 1 do
  begin
    InsertarDetalleTransferencia(FIdTransferencia,
      gridDocumentosView.DataController.Values[i, 0], // id_serie_dato
      'Bueno', // o dinámico
      ''
    );
  end;

  ShowMessage('Transferencia registrada correctamente.');  }
end;

procedure TfrmTransferencias.btnValidarClick(Sender: TObject);
begin
  {if FIdTransferencia > 0 then
  begin
    ValidarTransferencia(FIdTransferencia, ID_UsuarioActual);
    ShowMessage('Transferencia validada correctamente.');
  end;}
end;

procedure TfrmTransferencias.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmTransferencias.btnAgregarDocClick(Sender: TObject);
begin
  // Lógica para seleccionar un documento desde tb_seriesdatos y agregarlo al grid
end;

procedure TfrmTransferencias.btnQuitarDocClick(Sender: TObject);
begin
  // Lógica para quitar documento seleccionado del grid
end;

procedure TfrmTransferencias.btnLimpiarListaClick(Sender: TObject);
begin
  // Lógica para limpiar todos los documentos seleccionados
end;

end.

