object frmListFTPServer: TfrmListFTPServer
  Left = 0
  Top = 0
  Caption = 'Servidores vinculados al Archivo central'
  ClientHeight = 296
  ClientWidth = 953
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
    Width = 953
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
      Width = 821
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 852
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
    Width = 953
    Height = 199
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
      DataController.DataSource = UDM.dscl_ftp_Server
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      Styles.StyleSheet = UDM.GridTableViewStyleSheetEggplant
      object cxGrid1DBTableView1Idservidor: TcxGridDBColumn
        Caption = 'Identificador'
        DataBinding.FieldName = 'Idservidor'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 90
      end
      object cxGrid1DBTableView1NombreServer: TcxGridDBColumn
        DataBinding.FieldName = 'NombreServer'
        Width = 127
      end
      object cxGrid1DBTableView1ipserver: TcxGridDBColumn
        Caption = 'IP Server'
        DataBinding.FieldName = 'ipserver'
        FooterAlignmentHorz = taCenter
        GroupSummaryAlignment = taCenter
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 150
      end
      object cxGrid1DBTableView1path: TcxGridDBColumn
        Caption = 'Directorio ra'#237'z'
        DataBinding.FieldName = 'path'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 180
      end
      object cxGrid1DBTableView1user: TcxGridDBColumn
        Caption = 'Usuario'
        DataBinding.FieldName = 'user'
        PropertiesClassName = 'TcxTextEditProperties'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 180
      end
      object cxGrid1DBTableView1pass: TcxGridDBColumn
        Caption = 'Contrase'#241'a'
        DataBinding.FieldName = 'pass'
        PropertiesClassName = 'TcxTextEditProperties'
        Properties.EchoMode = eemPassword
        Properties.PasswordChar = '*'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 180
      end
      object cxGrid1DBTableView1puerto: TcxGridDBColumn
        Caption = 'Puerto'
        DataBinding.FieldName = 'puerto'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 80
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 277
    Width = 953
    Height = 19
    Panels = <>
  end
  object Panel6: TPanel
    Left = 0
    Top = 37
    Width = 953
    Height = 41
    Align = alTop
    TabOrder = 3
    object cxDBNavigator3: TcxDBNavigator
      Left = 910
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
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object DBNavigator3: TDBNavigator
      Left = 1
      Top = 1
      Width = 909
      Height = 39
      DataSource = UDM.dscl_ftp_Server
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
      ExplicitTop = 6
    end
  end
end
