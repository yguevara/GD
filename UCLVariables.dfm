object frmVariables: TfrmVariables
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Clasificador de variables virtuales'
  ClientHeight = 220
  ClientWidth = 364
  Color = clBtnFace
  Constraints.MaxHeight = 249
  Constraints.MaxWidth = 370
  Constraints.MinHeight = 249
  Constraints.MinWidth = 370
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
    Width = 364
    Height = 37
    ButtonHeight = 34
    ButtonWidth = 31
    Caption = 'ToolBar1'
    Images = UDM.ILv1
    TabOrder = 0
    ExplicitWidth = 425
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
      Width = 298
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 329
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
    Width = 364
    Height = 30
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 425
    object cxDBNavigator3: TcxDBNavigator
      Left = 321
      Top = 1
      Width = 42
      Height = 28
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
      DataSource = UDM.dscl_variables
      InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      InfoPanel.Visible = True
      Align = alRight
      TabOrder = 0
      ExplicitLeft = 382
    end
    object DBNavigator3: TDBNavigator
      Left = 1
      Top = 1
      Width = 320
      Height = 28
      DataSource = UDM.dscl_variables
      VisibleButtons = [nbPrior, nbNext, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
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
      ExplicitLeft = -5
      ExplicitTop = -4
      ExplicitWidth = 381
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 201
    Width = 364
    Height = 19
    Panels = <>
    ExplicitLeft = 1
    ExplicitTop = 214
  end
  object cxDBVerticalGrid6: TcxDBVerticalGrid
    Left = 0
    Top = 67
    Width = 364
    Height = 134
    Align = alClient
    OptionsView.ScrollBars = ssNone
    OptionsView.PaintStyle = psDelphi
    OptionsView.RowHeaderWidth = 126
    Navigator.Buttons.CustomButtons = <>
    Navigator.Buttons.First.Hint = 'Primero'
    Navigator.Buttons.PriorPage.Visible = False
    Navigator.Buttons.Prior.Hint = 'Anterior'
    Navigator.Buttons.Next.Hint = 'Pr'#243'ximo'
    Navigator.Buttons.NextPage.Visible = False
    Navigator.Buttons.Last.Hint = #218'ltimo'
    Navigator.Buttons.Insert.Visible = False
    Navigator.Buttons.Delete.Visible = False
    Navigator.Buttons.Edit.Hint = 'Editar propiedades'
    Navigator.Buttons.Post.Hint = 'Aceptar los cambios realizados'
    Navigator.Buttons.Cancel.Hint = 'Cancelar cambios'
    Navigator.Buttons.Refresh.Visible = False
    Navigator.Buttons.SaveBookmark.Visible = False
    Navigator.Buttons.GotoBookmark.Visible = False
    Navigator.Buttons.Filter.Visible = False
    Navigator.InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
    Navigator.InfoPanel.Visible = True
    Styles.StyleSheet = UDM.cxVerticalGridStyleSheetEggplant
    TabOrder = 3
    DataController.DataSource = UDM.dscl_variables
    ExplicitTop = 61
    Version = 1
    object cxDBVerticalGrid6IdVar: TcxDBEditorRow
      Properties.Caption = 'Identificador'
      Properties.DataBinding.FieldName = 'IdVar'
      ID = 0
      ParentID = -1
      Index = 0
      Version = 1
    end
    object cxDBVerticalGrid6NomVariable: TcxDBEditorRow
      Properties.Caption = 'Variable'
      Properties.DataBinding.FieldName = 'NomVariable'
      ID = 1
      ParentID = -1
      Index = 1
      Version = 1
    end
    object cxDBVerticalGrid6Etiqueta: TcxDBEditorRow
      Properties.DataBinding.FieldName = 'Etiqueta'
      ID = 2
      ParentID = -1
      Index = 2
      Version = 1
    end
    object cxDBVerticalGrid6tipo: TcxDBEditorRow
      Properties.Caption = 'Tipo'
      Properties.EditPropertiesClassName = 'TcxComboBoxProperties'
      Properties.EditProperties.Items.Strings = (
        'Entero'
        'Fecha'
        'Real'
        'String')
      Properties.DataBinding.FieldName = 'tipo'
      ID = 3
      ParentID = -1
      Index = 3
      Version = 1
    end
    object cxLong: TcxDBEditorRow
      Properties.Caption = 'Longitud'
      Properties.DataBinding.FieldName = 'longitud'
      ID = 4
      ParentID = -1
      Index = 4
      Version = 1
    end
    object cxDBVerticalGrid6descripcion: TcxDBEditorRow
      Properties.Caption = 'Descripci'#243'n'
      Properties.DataBinding.FieldName = 'descripcion'
      ID = 5
      ParentID = -1
      Index = 5
      Version = 1
    end
    object cxDBVerticalGrid6ListaDesplegable: TcxDBEditorRow
      Properties.Caption = 'Lista desplegable'
      Properties.DataBinding.FieldName = 'ListaDesplegable'
      ID = 6
      ParentID = -1
      Index = 6
      Version = 1
    end
  end
end
