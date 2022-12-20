object frmVariables: TfrmVariables
  Left = 0
  Top = 0
  Caption = 
    'Clasificador de variables virtuales identifcadas en Series docum' +
    'entales'
  ClientHeight = 254
  ClientWidth = 425
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
    Width = 425
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
      Width = 351
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 382
      Top = 0
      Hint = 'Ayuda para manipular la interface actual'
      Caption = 'btnhlp'
      ImageIndex = 1
      ParentShowHint = False
      ShowHint = True
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 37
    Width = 425
    Height = 41
    Align = alTop
    TabOrder = 1
    object cxDBNavigator3: TcxDBNavigator
      Left = 382
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
      DataSource = UDM.dscl_variables
      InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      InfoPanel.Visible = True
      Align = alRight
      TabOrder = 0
      ExplicitLeft = 388
      ExplicitTop = 6
    end
    object DBNavigator3: TDBNavigator
      Left = 1
      Top = 1
      Width = 381
      Height = 39
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
      ExplicitTop = -4
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 235
    Width = 425
    Height = 19
    Panels = <>
  end
  object cxDBVerticalGrid6: TcxDBVerticalGrid
    Left = 0
    Top = 78
    Width = 425
    Height = 157
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
    ExplicitTop = 72
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
      Properties.Caption = 'Nombre'
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
