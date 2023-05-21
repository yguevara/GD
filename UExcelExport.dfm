object frmExcelExport: TfrmExcelExport
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Exportando conjunto de datos a excel....'
  ClientHeight = 22
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 457
    Height = 22
    Align = alClient
    Caption = 'Esperndo nombre de fichero....!!!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    ExplicitHeight = 25
    object g1: TsGauge
      Left = 1
      Top = 1
      Width = 455
      Height = 20
      Align = alClient
      Visible = False
      ForeColor = clBlue
      Progress = 0
      Suffix = '%'
      ExplicitLeft = 0
      ExplicitTop = 32
      ExplicitWidth = 265
      ExplicitHeight = 25
    end
  end
  object ex: TJvgExportExcel
    Captions = fecDisplayLabels
    TransliterateRusToEng = False
    MaxFieldSize = 0
    HeaderFont.Charset = DEFAULT_CHARSET
    HeaderFont.Color = clWindowText
    HeaderFont.Height = -16
    HeaderFont.Name = 'Tahoma'
    HeaderFont.Style = [fsBold]
    SubHeaderFont.Charset = DEFAULT_CHARSET
    SubHeaderFont.Color = clWindowText
    SubHeaderFont.Height = -13
    SubHeaderFont.Name = 'Tahoma'
    SubHeaderFont.Style = []
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    ExcelVisible = True
    CloseExcel = True
    OnExportRecord = exExportRecord
    Left = 24
    Top = 16
  end
  object SD: TsSaveDialog
    DefaultExt = '*.xlsx'
    Filter = 'Microsoft Excel|*.XLSX'
    Left = 104
    Top = 16
  end
  object Timer1: TTimer
    Interval = 500
    OnTimer = Timer1Timer
    Left = 272
    Top = 8
  end
end
