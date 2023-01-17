object frmManagementFile: TfrmManagementFile
  Left = 0
  Top = 0
  Caption = 'Gestiona ficheros de Series documentales'
  ClientHeight = 127
  ClientWidth = 556
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lbl1: TLabel
    Left = 20
    Top = 45
    Width = 133
    Height = 13
    Caption = 'Camino o estado del fichero'
  end
  object btnFindInforme: TSpeedButton
    Left = 501
    Top = 58
    Width = 24
    Height = 25
    Hint = 'Abrir ficheros existentes'
    Caption = '...'
    ParentShowHint = False
    ShowHint = True
    OnClick = btnFindInformeClick
  end
  object tlbObject: TToolBar
    Left = 0
    Top = 0
    Width = 556
    Height = 33
    ButtonHeight = 30
    ButtonWidth = 31
    Caption = 'tlbObject'
    Images = UDM.ILv1
    TabOrder = 0
    object btntbtncerrar: TToolButton
      Left = 0
      Top = 0
      Hint = 'Cerrar'
      Caption = '&Cerrar'
      ImageIndex = 0
      ParentShowHint = False
      ShowHint = True
      OnClick = btntbtncerrarClick
    end
    object btn3: TToolButton
      Left = 31
      Top = 0
      Hint = 'Limpiar Campo'
      Caption = 'btn3'
      ImageIndex = 12
      ParentShowHint = False
      ShowHint = True
      OnClick = btn3Click
    end
    object btn1: TToolButton
      Left = 62
      Top = 0
      Width = 8
      Caption = 'btn1'
      ImageIndex = 112
      Style = tbsSeparator
    end
    object btnViewInforme: TToolButton
      Left = 70
      Top = 0
      Hint = 'Ver informe'
      Caption = 'btnViewInforme'
      ImageIndex = 13
      ParentShowHint = False
      ShowHint = True
      OnClick = btnViewInformeClick
    end
    object btn2: TToolButton
      Left = 101
      Top = 0
      Width = 420
      Caption = 'btn2'
      ImageIndex = 9
      Style = tbsSeparator
    end
    object btnhelp: TToolButton
      Left = 521
      Top = 0
      Hint = 'Ayuda'
      ImageIndex = 1
      ParentShowHint = False
      ShowHint = True
      OnClick = btnhelpClick
    end
  end
  object statInformesGeo: TStatusBar
    Left = 0
    Top = 108
    Width = 556
    Height = 19
    AutoHint = True
    Panels = <>
    ParentShowHint = False
    ShowHint = True
  end
  object edt1: TEdit
    Left = 20
    Top = 60
    Width = 481
    Height = 21
    ReadOnly = True
    TabOrder = 2
  end
  object dlgOpenOD: TOpenDialog
    Filter = 'Serie Documental (PDF)|*.PDF'
    Left = 352
    Top = 24
  end
  object Timer1: TTimer
    Interval = 500
    OnTimer = Timer1Timer
    Left = 272
    Top = 80
  end
end
