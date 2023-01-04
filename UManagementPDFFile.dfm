object frmManagementProc: TfrmManagementProc
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 
    'Gestiona procedimientos de calidad asociados al procedimiento ac' +
    'tual'
  ClientHeight = 144
  ClientWidth = 566
  Color = clBtnFace
  Constraints.MaxHeight = 173
  Constraints.MaxWidth = 572
  Constraints.MinHeight = 173
  Constraints.MinWidth = 572
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnFindInforme: TSpeedButton
    Left = 506
    Top = 59
    Width = 24
    Height = 25
    Hint = 'Abrir ficheros existentes'
    Caption = '...'
    ParentShowHint = False
    ShowHint = True
    OnClick = btnFindInformeClick
  end
  object lbl1: TLabel
    Left = 24
    Top = 40
    Width = 133
    Height = 13
    Caption = 'Camino o estado del fichero'
  end
  object tlbObject: TToolBar
    Left = 0
    Top = 0
    Width = 566
    Height = 29
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
    end
  end
  object statInformesGeo: TStatusBar
    Left = 0
    Top = 125
    Width = 566
    Height = 19
    AutoHint = True
    Panels = <>
    ParentShowHint = False
    ShowHint = True
  end
  object edt1: TEdit
    Left = 24
    Top = 60
    Width = 481
    Height = 21
    ReadOnly = True
    TabOrder = 2
  end
  object dlgOpenOD: TOpenDialog
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
