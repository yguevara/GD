object frmSelectFuncionG: TfrmSelectFuncionG
  Left = 0
  Top = 0
  Caption = 'Selecciona funci'#243'n general.'
  ClientHeight = 340
  ClientWidth = 531
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 531
    Height = 37
    ButtonHeight = 34
    ButtonWidth = 31
    Caption = 'ToolBar1'
    Images = UDM.ILv1
    TabOrder = 0
    object btnClose: TToolButton
      Left = 0
      Top = 0
      Hint = 'Regresar a la ventana principal'
      Caption = 'btnClose'
      ImageIndex = 0
      ParentShowHint = False
      ShowHint = True
      OnClick = btnCloseClick
    end
    object ToolButton3: TToolButton
      Left = 31
      Top = 0
      Width = 462
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 493
      Top = 0
      Hint = 'Ayuda para manipular la interface actual'
      Caption = 'btnhlp'
      ImageIndex = 1
      ParentShowHint = False
      ShowHint = True
      OnClick = btnhlpClick
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 37
    Width = 531
    Height = 41
    Align = alTop
    TabOrder = 1
    object cxDBNavigator3: TcxDBNavigator
      Left = 488
      Top = 1
      Width = 42
      Height = 39
      Buttons.CustomButtons = <>
      Buttons.First.Visible = False
      Buttons.PriorPage.Visible = False
      Buttons.Prior.Visible = False
      Buttons.Next.Visible = False
      Buttons.NextPage.Visible = False
      Buttons.Last.Visible = False
      Buttons.Insert.Visible = False
      Buttons.Delete.Visible = False
      Buttons.Edit.Visible = False
      Buttons.Post.Visible = False
      Buttons.Cancel.Visible = False
      Buttons.Refresh.Visible = False
      Buttons.SaveBookmark.Visible = False
      Buttons.GotoBookmark.Visible = False
      Buttons.Filter.Visible = False
      DataSource = dscmdfun
      InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      InfoPanel.Visible = True
      Align = alRight
      TabOrder = 0
    end
    object DBNavigator3: TDBNavigator
      Left = 1
      Top = 1
      Width = 487
      Height = 39
      DataSource = dscmdfun
      VisibleButtons = [nbPrior, nbNext]
      Align = alClient
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
        'Refrescar')
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object z: TcxGrid
    Left = 0
    Top = 78
    Width = 531
    Height = 262
    Align = alClient
    TabOrder = 3
    ExplicitLeft = -1
    ExplicitTop = 83
    object zDBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = dscmdfun
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      Styles.StyleSheet = UDM.GridTableViewStyleSheetEggplant
      object zDBTableView1idfunciones: TcxGridDBColumn
        Caption = 'ID'
        DataBinding.FieldName = 'idfunciones'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
      end
      object zDBTableView1funciones: TcxGridDBColumn
        Caption = 'Funciones'
        DataBinding.FieldName = 'funciones'
        PropertiesClassName = 'TcxBlobEditProperties'
        Properties.BlobEditKind = bekMemo
        Properties.BlobPaintStyle = bpsText
        Properties.PopupHeight = 300
        Properties.PopupWidth = 300
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 268
      end
      object zDBTableView1Idcargo: TcxGridDBColumn
        Caption = 'Cargo'
        DataBinding.FieldName = 'Idcargo'
        PropertiesClassName = 'TcxLookupComboBoxProperties'
        Properties.KeyFieldNames = 'Idcargo'
        Properties.ListColumns = <
          item
            FieldName = 'nombre'
          end>
        Properties.ListSource = UDM.dscl_cargo
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 150
      end
    end
    object zLevel1: TcxGridLevel
      GridView = zDBTableView1
    end
  end
  object jcpSelectCargo: TJvCaptionPanel
    Left = 147
    Top = 120
    Width = 273
    Height = 97
    Buttons = [capClose]
    Caption = 'Especifique el Cargo'
    CaptionPosition = dpTop
    CaptionFont.Charset = DEFAULT_CHARSET
    CaptionFont.Color = clWhite
    CaptionFont.Height = -13
    CaptionFont.Name = 'Tahoma'
    CaptionFont.Style = [fsBold]
    OutlookLook = False
    TabOrder = 2
    Visible = False
    OnButtonClick = jcpSelectCargoButtonClick
    object lcbSelectCargo: TDBLookupComboBox
      Left = 16
      Top = 40
      Width = 225
      Height = 21
      KeyField = 'Idcargo'
      ListField = 'nombre'
      ListSource = UDM.dscl_cargo
      TabOrder = 0
    end
  end
  object PMFunciones: TAdvPopupMenu
    Version = '2.6.4.0'
    Left = 393
    Top = 93
    object agregarfun: TMenuItem
      Caption = 'Todas'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object eliminarfun: TMenuItem
      Caption = 'Por Cargo'
      OnClick = eliminarfunClick
    end
  end
  object cmdfun: TFDQuery
    Active = True
    Connection = UDM.Conn
    SQL.Strings = (
      'select * from cl_funcionesgen')
    Left = 200
    Top = 200
  end
  object dscmdfun: TDataSource
    DataSet = cmdfun
    Left = 248
    Top = 232
  end
end
