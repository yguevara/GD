object FVariablesAyuda: TFVariablesAyuda
  Left = 0
  Top = 0
  Caption = 'FVariablesAyuda'
  ClientHeight = 310
  ClientWidth = 302
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
  object Panel1: TPanel
    Left = 0
    Top = 269
    Width = 302
    Height = 41
    Align = alBottom
    TabOrder = 0
    OnResize = eesize
    ExplicitWidth = 308
    object Button1: TButton
      Left = 112
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Salir'
      TabOrder = 0
    end
  end
  object cxDBVerticalGrid1: TcxDBVerticalGrid
    Left = 0
    Top = 37
    Width = 302
    Height = 232
    Align = alClient
    Navigator.Buttons.CustomButtons = <>
    Styles.Header = cxStyle1
    TabOrder = 1
    DataController.DataSource = UDM.dscl_variables
    ExplicitTop = 42
    ExplicitWidth = 308
    ExplicitHeight = 227
    Version = 1
    object cxDBVerticalGrid1IdVar: TcxDBEditorRow
      Properties.Caption = 'ID Variable'
      Properties.DataBinding.FieldName = 'IdVar'
      Properties.Options.Editing = False
      ID = 0
      ParentID = -1
      Index = 0
      Version = 1
    end
    object cxDBVerticalGrid1NomVariable: TcxDBEditorRow
      Properties.Caption = 'Nombre Variable'
      Properties.DataBinding.FieldName = 'NomVariable'
      Properties.Options.Editing = False
      ID = 1
      ParentID = -1
      Index = 1
      Version = 1
    end
    object cxDBVerticalGrid1Etiqueta: TcxDBEditorRow
      Properties.DataBinding.FieldName = 'Etiqueta'
      Properties.Options.Editing = False
      ID = 2
      ParentID = -1
      Index = 2
      Version = 1
    end
    object cxDBVerticalGrid1tipo: TcxDBEditorRow
      Properties.Caption = 'Tipo variable'
      Properties.DataBinding.FieldName = 'tipo'
      Properties.Options.Editing = False
      ID = 3
      ParentID = -1
      Index = 3
      Version = 1
    end
    object cxDBVerticalGrid1longitud: TcxDBEditorRow
      Properties.Caption = 'Longitud'
      Properties.DataBinding.FieldName = 'longitud'
      Properties.Options.Editing = False
      ID = 4
      ParentID = -1
      Index = 4
      Version = 1
    end
    object cxDBVerticalGrid1descripcion: TcxDBEditorRow
      Properties.Caption = 'Descripcion'
      Properties.EditPropertiesClassName = 'TcxMemoProperties'
      Properties.EditProperties.VisibleLineCount = 7
      Properties.DataBinding.FieldName = 'descripcion'
      Properties.Options.Editing = False
      ID = 5
      ParentID = -1
      Index = 5
      Version = 1
    end
    object cxDBVerticalGrid1ListaDesplegable: TcxDBEditorRow
      Properties.Caption = 'Tiene Lista'
      Properties.DataBinding.FieldName = 'ListaDesplegable'
      Properties.Options.Editing = False
      ID = 6
      ParentID = -1
      Index = 6
      Version = 1
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 302
    Height = 37
    ButtonHeight = 34
    ButtonWidth = 31
    Caption = 'ToolBar1'
    Images = UDM.ILv1
    TabOrder = 2
    ExplicitTop = 47
    ExplicitWidth = 450
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
      Width = 234
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 265
      Top = 0
      Hint = 'Ayuda para manipular la interface actual'
      Caption = 'btnhlp'
      ImageIndex = 1
      ParentShowHint = False
      ShowHint = True
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 152
    Top = 168
    PixelsPerInch = 96
    object cxStyle1: TcxStyle
      AssignedValues = [svColor]
      Color = clGradientActiveCaption
    end
  end
end
