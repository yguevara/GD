object FEntrada: TFEntrada
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  Caption = 'FEntrada'
  ClientHeight = 337
  ClientWidth = 684
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 37
    Width = 684
    Height = 281
    Align = alClient
    Caption = ' '
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 379
      Top = 1
      Width = 5
      Height = 279
      Align = alRight
      Color = clBackground
      ParentColor = False
      Visible = False
      ExplicitLeft = 266
      ExplicitHeight = 251
    end
    object cxDBVerticalGrid1: TcxDBVerticalGrid
      Left = 1
      Top = 1
      Width = 378
      Height = 279
      Align = alClient
      OptionsView.RowHeight = 20
      OptionsBehavior.GoToNextCellOnEnter = True
      OptionsBehavior.FocusFirstCellOnNewRecord = True
      Navigator.Buttons.CustomButtons = <>
      Styles.Background = cxStyle3
      Styles.Header = cxStyle1
      TabOrder = 0
      OnMouseDown = cxDBVerticalGrid1MouseDown
      DataController.DataSource = UDM.Dtb_VirtualVar
      ExplicitTop = 6
      Version = 1
      object iv1: TcxDBEditorRow
        Visible = False
        ID = 0
        ParentID = -1
        Index = 0
        Version = 1
      end
      object iv2: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'codsubs'
        Visible = False
        ID = 1
        ParentID = -1
        Index = 1
        Version = 1
      end
      object iv3: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'Fecha'
        Visible = False
        ID = 2
        ParentID = -1
        Index = 2
        Version = 1
      end
      object iv4: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'Version'
        Visible = False
        ID = 3
        ParentID = -1
        Index = 3
        Version = 1
      end
      object iv5: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'Codigodoc'
        Visible = False
        ID = 4
        ParentID = -1
        Index = 4
        Version = 1
      end
      object iv6: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'Idservidor'
        Visible = False
        ID = 5
        ParentID = -1
        Index = 5
        Version = 1
      end
      object iv7: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'deposito'
        Visible = False
        ID = 6
        ParentID = -1
        Index = 6
        Version = 1
      end
      object iv8: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'gaveta'
        Visible = False
        ID = 7
        ParentID = -1
        Index = 7
        Version = 1
      end
      object iv9: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'fichero'
        Visible = False
        ID = 8
        ParentID = -1
        Index = 8
        Version = 1
      end
      object iv10: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'soporte'
        Visible = False
        ID = 9
        ParentID = -1
        Index = 9
        Version = 1
      end
      object iv11: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'observaciones'
        Visible = False
        ID = 10
        ParentID = -1
        Index = 10
        Version = 1
      end
    end
    object Panel2: TPanel
      Left = 384
      Top = 1
      Width = 299
      Height = 279
      Align = alRight
      Constraints.MinWidth = 299
      TabOrder = 1
      Visible = False
      OnResize = Panel2Resize
      object DBGrid1: TDBGrid
        Left = 41
        Top = 25
        Width = 257
        Height = 253
        Align = alClient
        DataSource = DQListaCodigo
        Options = [dgEditing, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'fddsd'
            Visible = True
          end>
      end
      object Panel3: TPanel
        Left = 1
        Top = 25
        Width = 40
        Height = 253
        Align = alLeft
        TabOrder = 0
        OnResize = Panel3Resize
        object SpeedButton3: TSpeedButton
          Left = 5
          Top = 96
          Width = 32
          Height = 33
          Hint = 
            'Adicionar el valor actual de la lista c'#243'digo a la variable actua' +
            'l'
          Glyph.Data = {
            36090000424D3609000000000000360000002800000018000000180000000100
            2000000000000009000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000140F0014644B
            00649E76009EB58800B5B58800B59E76009E634A0063140F0014000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000001B14001B99730099FABB00FAFFBF
            00FFE5AC00E5CF9B00CFCF9B00CFE5AC00E5FFBF00FFFABB00FA987200981A13
            001A000000000000000000000000000000000000000000000000000000000000
            000000000000000000000000000040300040ECB100ECF9BB00F9957000952F23
            002F000000000000000000000000000000003024003097710097FABB00FAEBB0
            00EB3F2F003F0000000000000000000000000000000000000000000000000000
            000000000000000000003F2F003FF9BB00F9D5A000D5261C0026000000000000
            0000000000000000000000000000000000000000000000000000281E0028D6A0
            00D6F9BB00F93C2D003C00000000000000000000000000000000000000000000
            00000000000019130019EAAF00EAD39E00D30F0B000F00000000000000000000
            0000000000000000000000000000000000000000000000000000000000000F0B
            000FD5A000D5E8AE00E817110017000000000000000000000000000000000000
            00000000000098720098F6B800F6211900210000000000000000000000000000
            0000000000000000000033260033B68800B60E0A000E00000000000000000000
            0000251C0025F8BA00F895700095000000000000000000000000000000000000
            000016100016FBBC00FB8A67008A000000000000000000000000000000000000
            0000000000003F2F003FF4B700F4D6A000D61812001800000000000000000000
            0000000000008E6A008EFABB00FA140F00140000000000000000000000000000
            000061490061FFBF00FF2E22002E000000000000000000000000000000000000
            0000392B0039F1B500F1DAA300DA1C15001C0000000000000000000000000000
            00000000000031250031FFBF00FF5E46005E0000000000000000000000000000
            00009A73009AE8AE00E800000000000000000000000000000000000000003A2B
            003AF1B500F1DAA300DA1B14001B000000000000000000000000000000000000
            00000000000000000000EBB000EB977100970000000000000000000000000000
            0000B48700B4CB9800CB0000000000000000000000000000000042310042F5B8
            00F5D39E00D31610001600000000000000000000000000000000000000000000
            00000000000000000000CC9900CCB28500B20000000000000000000000000000
            0000B38600B3CB9800CB0000000000000000000000000000000037290037F0B4
            00F0D39E00D31610001600000000000000000000000000000000000000000000
            00000000000000000000CC9900CCB28500B20000000000000000000000000000
            000099730099E6AC00E600000000000000000000000000000000000000004131
            0041F5B800F5CB9800CB110D0011000000000000000000000000000000000000
            00000000000000000000E9AF00E9977100970000000000000000000000000000
            0000664C0066FFBF00FF251C0025000000000000000000000000000000000000
            000042310042F5B800F5CB9800CB110D00110000000000000000000000000000
            0000000000002A1F002AFFBF00FF634A00630000000000000000000000000000
            000016100016FBBC00FB8A67008A000000000000000000000000000000000000
            0000000000003B2C003BF2B500F2D6A000D61812001800000000000000000000
            0000000000008E6A008EFABB00FA140F00140000000000000000000000000000
            00000000000098720098F6B800F6211900210000000000000000000000000000
            0000000000000000000043320043CD9A00CD1812001800000000000000000000
            0000241B0024F7B900F7946F0094000000000000000000000000000000000000
            00000000000019130019EAAF00EAD39E00D30F0B000F00000000000000000000
            000000000000000000000000000000000000000000000000000000000000100C
            0010D5A000D5E8AE00E816100016000000000000000000000000000000000000
            000000000000000000003F2F003FF9BB00F9D5A000D5251C0025000000000000
            0000000000000000000000000000000000000000000000000000271D0027D6A0
            00D6F9BB00F93C2D003C00000000000000000000000000000000000000000000
            000000000000000000000000000040300040ECB100ECF7B900F788660088261C
            002600000000000000000000000000000000271D002789670089F8BA00F8EBB0
            00EB3F2F003F0000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000001B14001B99730099FABB00FAFFBF
            00FFE4AB00E4CF9B00CFCF9B00CFE5AC00E5FFBF00FFFABB00FA977100971A13
            001A000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000140F0014644B
            00649E76009EB58800B5B58800B59E76009E634A0063140F0014000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000}
          ParentShowHint = False
          ShowHint = True
          OnClick = SpeedButton3Click
        end
      end
      object PanelCaption: TPanel
        Left = 1
        Top = 1
        Width = 297
        Height = 24
        Align = alTop
        Alignment = taLeftJustify
        BevelInner = bvSpace
        Caption = ' Variable:'
        Color = clActiveCaption
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentBackground = False
        ParentFont = False
        TabOrder = 2
        ExplicitTop = 5
      end
      object Panel4: TPanel
        Left = 47
        Top = 90
        Width = 232
        Height = 25
        Caption = 'La Variable no tiene datos que mostrar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 3
      end
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 684
    Height = 37
    ButtonHeight = 34
    ButtonWidth = 31
    Caption = 'ToolBar1'
    Images = UDM.ILv1
    TabOrder = 1
    object ToolButton6: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton6'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object btnClose: TToolButton
      Left = 8
      Top = 0
      Hint = 'Regresar a la ventana principal'
      Caption = 'btnClose'
      ImageIndex = 0
      ParentShowHint = False
      ShowHint = True
      OnClick = btnCloseClick
    end
    object ToolButton7: TToolButton
      Left = 39
      Top = 0
      Width = 8
      Caption = 'ToolButton7'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object ToolButton8: TToolButton
      Left = 47
      Top = 0
      Hint = 'Salva los valores actuales a la tabla ctual'
      Caption = 'ToolButton8'
      ImageIndex = 11
      ParentShowHint = False
      ShowHint = True
      OnClick = ToolButton8Click
    end
    object ToolButton1: TToolButton
      Left = 78
      Top = 0
      Hint = 'Consultar definici'#243'n de variable'
      Caption = 'ToolButton1'
      ImageIndex = 14
      ParentShowHint = False
      ShowHint = True
      OnClick = G1Click
    end
    object ToolButton4: TToolButton
      Left = 109
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object ToolButton5: TToolButton
      Left = 117
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object ToolButton2: TToolButton
      Left = 125
      Top = 0
      Hint = 'Valor de la variable'
      Caption = 'ToolButton2'
      ImageIndex = 15
      OnClick = V1Click
    end
    object ToolButton3: TToolButton
      Left = 156
      Top = 0
      Width = 493
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 649
      Top = 0
      Hint = 'Ayuda para manipular la interface actual'
      Caption = 'btnhlp'
      ImageIndex = 1
      ParentShowHint = False
      ShowHint = True
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 318
    Width = 684
    Height = 19
    Panels = <>
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 472
    Top = 80
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor, svFont]
      Color = clGradientActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
    end
    object cxStyle3: TcxStyle
      AssignedValues = [svColor]
      Color = clInfoBk
    end
  end
  object QListaCodigo: TFDQuery
    Connection = UDM.Conn
    Left = 280
    Top = 176
  end
  object DQListaCodigo: TDataSource
    DataSet = QListaCodigo
    Left = 336
    Top = 240
  end
  object AdvPopupMenu1: TAdvPopupMenu
    Version = '2.6.4.0'
    Left = 312
    Top = 72
    object G1: TMenuItem
      Caption = 'Seleccionar valor'
      OnClick = G1Click
    end
    object V1: TMenuItem
      Caption = 'Variable'
      OnClick = V1Click
    end
  end
  object cxStyleRepository2: TcxStyleRepository
    Left = 392
    Top = 80
    PixelsPerInch = 96
    object cxStyle2: TcxStyle
    end
  end
end
