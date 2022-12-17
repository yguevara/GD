object frmRepActArch: TfrmRepActArch
  Left = 0
  Top = 0
  Caption = 'Listado de representantes actividad archivistica'
  ClientHeight = 231
  ClientWidth = 441
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
    Width = 441
    Height = 37
    ButtonHeight = 34
    ButtonWidth = 31
    Caption = '`'
    Images = UDM.ILv1
    TabOrder = 0
    ExplicitLeft = -380
    ExplicitWidth = 885
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
      Width = 367
      Caption = 'a'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 398
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 406
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
    Width = 441
    Height = 134
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 1
    ExplicitTop = 83
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.ConfirmDelete = True
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.PriorPage.Visible = False
      Navigator.Buttons.NextPage.Visible = False
      Navigator.Buttons.SaveBookmark.Visible = False
      Navigator.Buttons.GotoBookmark.Visible = False
      Navigator.Buttons.Filter.Visible = False
      Navigator.InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      DataController.DataSource = UDM.dscl_ftp_Server
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      Styles.StyleSheet = UDM.GridTableViewStyleSheetEggplant
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 212
    Width = 441
    Height = 19
    Panels = <>
    ExplicitLeft = -380
    ExplicitWidth = 885
  end
  object Panel6: TPanel
    Left = 0
    Top = 37
    Width = 441
    Height = 41
    Align = alTop
    TabOrder = 3
    ExplicitLeft = -380
    ExplicitWidth = 885
    object cxDBNavigator3: TcxDBNavigator
      Left = 398
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
      DataSource = UDM.dscl_ftp_Server
      InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      InfoPanel.Visible = True
      Align = alRight
      TabOrder = 0
      ExplicitLeft = 842
    end
    object DBNavigator3: TDBNavigator
      Left = 1
      Top = 1
      Width = 397
      Height = 39
      DataSource = UDM.dscl_ftp_Server
      VisibleButtons = [nbPrior, nbNext, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
      Align = alClient
      TabOrder = 1
      ExplicitWidth = 841
    end
  end
end
