object frmConnProperties: TfrmConnProperties
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Propiedades de la Conexi'#243'n'
  ClientHeight = 251
  ClientWidth = 427
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
  object lblServer: TLabel
    Left = 16
    Top = 32
    Width = 40
    Height = 13
    Caption = 'Servidor'
  end
  object lblUser: TLabel
    Left = 16
    Top = 69
    Width = 36
    Height = 13
    Caption = 'Usuario'
  end
  object lblpuerto: TLabel
    Left = 16
    Top = 144
    Width = 95
    Height = 13
    Caption = 'Puerto de Conexi'#243'n'
  end
  object Label1: TLabel
    Left = 16
    Top = 107
    Width = 56
    Height = 13
    Caption = 'Contrase'#241'a'
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 427
    Height = 24
    Caption = 'ToolBar1'
    Images = DMBDR.ILEdith
    TabOrder = 4
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object ToolButton2: TToolButton
      Left = 8
      Top = 0
      Hint = 'Regresar a la interfaz principal'
      Caption = 'ToolButton2'
      ImageIndex = 36
      ParentShowHint = False
      ShowHint = True
      OnClick = ToolButton2Click
    end
    object ToolButton5: TToolButton
      Left = 31
      Top = 0
      Width = 354
      Caption = 'ToolButton5'
      ImageIndex = 92
      Style = tbsSeparator
    end
    object ToolButton4: TToolButton
      Left = 385
      Top = 0
      Hint = 'Ayuda de la interface actual'
      Caption = 'ToolButton4'
      ImageIndex = 91
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 232
    Width = 427
    Height = 19
    Panels = <>
  end
  object edtServer: TEdit
    Left = 16
    Top = 45
    Width = 385
    Height = 21
    TabOrder = 0
  end
  object edtuser: TEdit
    Left = 16
    Top = 83
    Width = 385
    Height = 21
    TabOrder = 1
  end
  object edtpuerto: TEdit
    Left = 16
    Top = 158
    Width = 385
    Height = 21
    TabOrder = 3
  end
  object edtpass: TEdit
    Left = 16
    Top = 120
    Width = 385
    Height = 21
    TabOrder = 2
  end
  object btnAcept: TButton
    Left = 245
    Top = 201
    Width = 75
    Height = 25
    Caption = 'Aceptar'
    ModalResult = 1
    TabOrder = 6
    OnClick = btnAceptClick
  end
  object btnCancel: TButton
    Left = 326
    Top = 201
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    ModalResult = 2
    TabOrder = 7
    OnClick = btnCancelClick
  end
end
