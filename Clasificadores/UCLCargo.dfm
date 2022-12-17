object frmCLCargo: TfrmCLCargo
  Left = 0
  Top = 0
  Caption = 'Clasificador de Cargos'
  ClientHeight = 341
  ClientWidth = 505
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
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 505
    ButtonHeight = 30
    ButtonWidth = 32
    Caption = 'ToolBar1'
    Images = UDM.ILEdith
    TabOrder = 0
    ExplicitWidth = 512
    object ToolButton2: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 8
      Top = 0
      Hint = 'Regresar'
      Caption = 'ToolButton1'
      ImageIndex = 36
      ParentShowHint = False
      ShowHint = True
      OnClick = ToolButton1Click
    end
    object ToolButton4: TToolButton
      Left = 40
      Top = 0
      Hint = 'Ordenar por la descripci'#243'n del clasificador'
      Caption = 'ToolButton4'
      ImageIndex = 74
      ParentShowHint = False
      ShowHint = True
      OnClick = ToolButton4Click
    end
    object ToolButton3: TToolButton
      Left = 72
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 37
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 80
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 75
      Style = tbsSeparator
      Visible = False
    end
    object Panel1: TPanel
      Left = 88
      Top = 0
      Width = 377
      Height = 30
      Caption = 'Panel1'
      TabOrder = 0
      object edtfind: TEdit
        Left = 1
        Top = 1
        Width = 375
        Height = 28
        Align = alClient
        TabOrder = 0
        OnChange = edtfindChange
        OnExit = edtfindExit
        ExplicitHeight = 21
      end
    end
  end
  object GDATA: TDBGrid
    Left = 0
    Top = 32
    Width = 505
    Height = 265
    Align = alClient
    DataSource = UDM.dscl_cargo
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnCellClick = GDATACellClick
  end
  object dbnCargos: TDBNavigator
    Left = 0
    Top = 297
    Width = 505
    Height = 25
    DataSource = UDM.dscl_cargo
    Align = alBottom
    Hints.Strings = (
      'Primero'
      'Anterior'
      'Pr'#243'ximo'
      'Ultimo'
      'Insertar'
      'Borrar'
      'Editar'
      'Aceptar'
      'Cancelar'
      'Refrescar'
      '')
    TabOrder = 2
    ExplicitTop = 335
    ExplicitWidth = 512
  end
  object StatusBar2: TStatusBar
    Left = 0
    Top = 322
    Width = 505
    Height = 19
    Panels = <
      item
        Text = 'Registros: '
        Width = 70
      end
      item
        Width = 50
      end
      item
        Alignment = taCenter
        Text = 'de'
        Width = 40
      end
      item
        Width = 50
      end>
    ExplicitLeft = -372
    ExplicitTop = 366
    ExplicitWidth = 884
  end
end
