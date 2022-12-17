object frmCLFrecuencia: TfrmCLFrecuencia
  Left = 0
  Top = 0
  Caption = 'Frecuencia de creaci'#243'n'
  ClientHeight = 231
  ClientWidth = 333
  Color = clBtnFace
  Constraints.MaxHeight = 270
  Constraints.MaxWidth = 349
  Constraints.MinHeight = 270
  Constraints.MinWidth = 349
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
    Width = 333
    Height = 37
    ButtonHeight = 34
    ButtonWidth = 31
    Caption = '`'
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
      Width = 268
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 299
      Top = 0
      Hint = 'Ayuda para manipular la interface actual'
      Caption = 'btnhlp'
      ImageIndex = 1
      ParentShowHint = False
      ShowHint = True
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 78
    Width = 333
    Height = 134
    Align = alClient
    TabOrder = 1
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.ConfirmDelete = True
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.PriorPage.Visible = False
      Navigator.Buttons.NextPage.Visible = False
      Navigator.Buttons.SaveBookmark.Visible = False
      Navigator.Buttons.GotoBookmark.Visible = False
      Navigator.Buttons.Filter.Visible = False
      Navigator.InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      DataController.DataSource = UDM.dscl_frecuencia
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      Styles.StyleSheet = UDM.GridTableViewStyleSheetEggplant
      object cxGrid1DBTableView1Idfrecuencia: TcxGridDBColumn
        Caption = 'C'#243'digo'
        DataBinding.FieldName = 'Idfrecuencia'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
      end
      object cxGrid1DBTableView1NombreFrecuencia: TcxGridDBColumn
        Caption = 'Frecuencia'
        DataBinding.FieldName = 'NombreFrecuencia'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 237
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 212
    Width = 333
    Height = 19
    Panels = <>
  end
  object Panel6: TPanel
    Left = 0
    Top = 37
    Width = 333
    Height = 41
    Align = alTop
    TabOrder = 3
    object cxDBNavigator3: TcxDBNavigator
      Left = 290
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
      DataSource = UDM.dscl_frecuencia
      InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      InfoPanel.Visible = True
      Align = alRight
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object DBNavigator3: TDBNavigator
      Left = 1
      Top = 1
      Width = 289
      Height = 39
      DataSource = UDM.dscl_frecuencia
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
    end
  end
end
