object frmListEspec: TfrmListEspec
  Left = 0
  Top = 0
  Caption = 'Listado de especialistas'
  ClientHeight = 231
  ClientWidth = 856
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
    Width = 856
    Height = 37
    ButtonHeight = 34
    ButtonWidth = 31
    Caption = 'ToolBar1'
    Images = UDM.ILv1
    TabOrder = 0
    ExplicitWidth = 371
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
      Width = 782
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 813
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
    Width = 856
    Height = 41
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 371
    object cxDBNavigator3: TcxDBNavigator
      Left = 813
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
      DataSource = UDM.dscl_especialista
      InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      InfoPanel.Visible = True
      Align = alRight
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      ExplicitLeft = 328
    end
    object DBNavigator3: TDBNavigator
      Left = 1
      Top = 1
      Width = 812
      Height = 39
      DataSource = UDM.dscl_especialista
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
  object cxGrid1: TcxGrid
    Left = 0
    Top = 78
    Width = 856
    Height = 134
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 104
    ExplicitTop = 72
    object cxGrid1DBTableView1: TcxGridDBTableView
      Navigator.Buttons.ConfirmDelete = True
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.PriorPage.Visible = False
      Navigator.Buttons.NextPage.Visible = False
      Navigator.Buttons.SaveBookmark.Visible = False
      Navigator.Buttons.GotoBookmark.Visible = False
      Navigator.Buttons.Filter.Visible = False
      Navigator.InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
      DataController.DataSource = UDM.dscl_especialista
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      Styles.StyleSheet = UDM.GridTableViewStyleSheetEggplant
      object cxGrid1DBTableView1Idespecialista: TcxGridDBColumn
        Caption = 'ID'
        DataBinding.FieldName = 'Idespecialista'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
      end
      object cxGrid1DBTableView1Nombespecialista: TcxGridDBColumn
        Caption = 'Nombre y Apellidos'
        DataBinding.FieldName = 'Nombespecialista'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 250
      end
      object cxGrid1DBTableView1usuario: TcxGridDBColumn
        Caption = 'Usuario'
        DataBinding.FieldName = 'usuario'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 80
      end
      object cxGrid1DBTableView1CorreoElect: TcxGridDBColumn
        Caption = 'Correo Electr'#243'nico'
        DataBinding.FieldName = 'CorreoElect'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 139
      end
      object cxGrid1DBTableView1NumControl: TcxGridDBColumn
        Caption = 'N'#250'mero de control'
        DataBinding.FieldName = 'NumControl'
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 115
      end
      object cxGrid1DBTableView1Idcargo: TcxGridDBColumn
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
        Width = 100
      end
      object cxGrid1DBTableView1idcategoria: TcxGridDBColumn
        Caption = 'Categor'#237'a'
        DataBinding.FieldName = 'idcategoria'
        PropertiesClassName = 'TcxLookupComboBoxProperties'
        Properties.KeyFieldNames = 'idcategoria'
        Properties.ListColumns = <
          item
            Caption = 'Categor'#237'a'
            HeaderAlignment = taCenter
            FieldName = 'nombrecategoria'
          end>
        Properties.ListSource = UDM.dscl_categoria_ocupacional
        HeaderAlignmentHorz = taCenter
        HeaderGlyphAlignmentHorz = taCenter
        Width = 109
      end
    end
    object cxGrid1Level1: TcxGridLevel
      GridView = cxGrid1DBTableView1
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 212
    Width = 856
    Height = 19
    Panels = <>
    ExplicitLeft = 1
    ExplicitWidth = 371
  end
end
