object frmCLFacultades: TfrmCLFacultades
  Left = 0
  Top = 0
  Caption = 'Clasificador de facultades'
  ClientHeight = 341
  ClientWidth = 684
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
  object Panel6: TPanel
    Left = 0
    Top = 37
    Width = 684
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 505
    object cxDBNavigator3: TcxDBNavigator
      Left = 641
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
      DataSource = UDM.dscl_funcionesgen
      InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      InfoPanel.Visible = True
      Align = alRight
      TabOrder = 0
      ExplicitLeft = 462
    end
    object DBNavigator3: TDBNavigator
      Left = 1
      Top = 1
      Width = 640
      Height = 39
      DataSource = UDM.dscl_funcionesgen
      VisibleButtons = [nbPrior, nbNext, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
      Align = alClient
      TabOrder = 1
      ExplicitLeft = -5
      ExplicitTop = -4
      ExplicitWidth = 461
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
    ExplicitLeft = -8
    ExplicitWidth = 505
    object btnClose: TToolButton
      Left = 0
      Top = 0
      Hint = 'Regresar a la ventana principal'
      Caption = 'btnClose'
      ImageIndex = 0
      OnClick = btnCloseClick
    end
    object ToolButton3: TToolButton
      Left = 31
      Top = 0
      Width = 431
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 462
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
    Width = 684
    Height = 263
    Align = alClient
    TabOrder = 2
    ExplicitTop = 83
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.DataSource = UDM.dscl_facultadesgen
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      Styles.StyleSheet = UDM.GridTableViewStyleSheetRedWhiteandBlueVGA
      object cxGrid1DBTableView1idfacultades: TcxGridDBColumn
        DataBinding.FieldName = 'idfacultades'
        Visible = False
      end
      object cxGrid1DBTableView1facultades: TcxGridDBColumn
        Caption = 'Facultades'
        DataBinding.FieldName = 'facultades'
        PropertiesClassName = 'TcxRichEditProperties'
        Properties.VisibleLineCount = 10
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 679
      end
      object cxGrid1DBTableView1IdCargo: TcxGridDBColumn
        DataBinding.FieldName = 'IdCargo'
        Visible = False
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
end
