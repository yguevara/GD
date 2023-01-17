object frmCLSeries: TfrmCLSeries
  Left = 0
  Top = 0
  Caption = 'Clalsificador de Series y Subseries documentales'
  ClientHeight = 476
  ClientWidth = 871
  Color = clBtnFace
  Constraints.MaxHeight = 515
  Constraints.MaxWidth = 887
  Constraints.MinHeight = 515
  Constraints.MinWidth = 887
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object AdvSplitter1: TAdvSplitter
    Left = 484
    Top = 37
    Height = 420
    Appearance.BorderColor = clNone
    Appearance.BorderColorHot = clNone
    Appearance.Color = clWhite
    Appearance.ColorTo = clSilver
    Appearance.ColorHot = clWhite
    Appearance.ColorHotTo = clGray
    GripStyle = sgDots
    ExplicitLeft = 657
    ExplicitTop = 56
    ExplicitHeight = 569
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 871
    Height = 37
    ButtonHeight = 30
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
      Width = 806
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 837
      Top = 0
      Hint = 'Ayuda para manipular la interface actual'
      Caption = 'btnhlp'
      ImageIndex = 1
      ParentShowHint = False
      ShowHint = True
      OnClick = btnhlpClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 457
    Width = 871
    Height = 19
    AutoHint = True
    Panels = <>
  end
  object pSeries: TPanel
    Left = 0
    Top = 37
    Width = 484
    Height = 420
    Align = alLeft
    TabOrder = 2
    object Panel2: TPanel
      Left = 1
      Top = 25
      Width = 482
      Height = 30
      Align = alTop
      TabOrder = 0
      object cxDBNavigator2: TcxDBNavigator
        Left = 439
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
        DataSource = UDM.dscl_series
        InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
        InfoPanel.Visible = True
        Align = alRight
        TabOrder = 0
      end
      object DBNavigator2: TDBNavigator
        Left = 1
        Top = 1
        Width = 438
        Height = 28
        DataSource = UDM.dscl_series
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
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
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 482
      Height = 24
      Align = alTop
      Caption = 'Series Documentales'
      Font.Charset = ANSI_CHARSET
      Font.Color = 10789888
      Font.Height = -16
      Font.Name = 'Ink Free'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 1
    end
    object cxGrid1: TcxGrid
      Left = 1
      Top = 55
      Width = 482
      Height = 364
      Align = alClient
      TabOrder = 2
      object cxGrid1DBTableView1: TcxGridDBTableView
        Navigator.Buttons.ConfirmDelete = True
        Navigator.Buttons.CustomButtons = <>
        Navigator.Buttons.PriorPage.Visible = False
        Navigator.Buttons.NextPage.Visible = False
        Navigator.Buttons.SaveBookmark.Visible = False
        Navigator.Buttons.GotoBookmark.Visible = False
        Navigator.Buttons.Filter.Visible = False
        Navigator.InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
        DataController.DataSource = UDM.dscl_series
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        OptionsView.GroupByBox = False
        Styles.StyleSheet = UDM.GridTableViewStyleSheetEggplant
        object cxGrid1DBTableView1codserie: TcxGridDBColumn
          Caption = 'C'#243'digo'
          DataBinding.FieldName = 'codserie'
          FooterAlignmentHorz = taCenter
          GroupSummaryAlignment = taCenter
          HeaderAlignmentHorz = taCenter
          HeaderGlyphAlignmentHorz = taCenter
          Width = 103
        end
        object cxGrid1DBTableView1serie: TcxGridDBColumn
          Caption = 'Nombre'
          DataBinding.FieldName = 'serie'
          FooterAlignmentHorz = taCenter
          GroupSummaryAlignment = taCenter
          HeaderAlignmentHorz = taCenter
          HeaderGlyphAlignmentHorz = taCenter
          Width = 371
        end
      end
      object cxGrid1Level1: TcxGridLevel
        GridView = cxGrid1DBTableView1
      end
    end
  end
  object pSubSeries: TPanel
    Left = 487
    Top = 37
    Width = 374
    Height = 420
    Align = alClient
    TabOrder = 3
    object cxDBVerticalGrid6: TcxDBVerticalGrid
      Left = 1
      Top = 55
      Width = 372
      Height = 364
      Align = alClient
      OptionsView.PaintStyle = psDelphi
      OptionsView.RowHeaderWidth = 150
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
      TabOrder = 0
      DataController.DataSource = UDM.dscl_subseries
      DataController.GridMode = True
      Version = 1
      object cxDBVerticalGrid6codserie: TcxDBEditorRow
        Properties.DataBinding.FieldName = 'codserie'
        Visible = False
        ID = 0
        ParentID = -1
        Index = 0
        Version = 1
      end
      object cxDBVerticalGrid6CategoryRow1: TcxCategoryRow
        Properties.Caption = 'DATOS GENERALES'
        ID = 1
        ParentID = -1
        Index = 1
        Version = 1
      end
      object cxDBVerticalGrid6codsubs: TcxDBEditorRow
        Properties.Caption = 'C'#243'digo'
        Properties.DataBinding.FieldName = 'codsubs'
        ID = 2
        ParentID = 1
        Index = 0
        Version = 1
      end
      object cxDBVerticalGrid6etiqueta: TcxDBEditorRow
        Properties.Caption = 'Etiqueta'
        Properties.DataBinding.FieldName = 'etiqueta'
        ID = 3
        ParentID = 1
        Index = 1
        Version = 1
      end
      object cxDBVerticalGrid6subserie: TcxDBEditorRow
        Properties.Caption = 'Nombre'
        Properties.DataBinding.FieldName = 'subserie'
        ID = 4
        ParentID = 1
        Index = 2
        Version = 1
      end
      object cxDBVerticalGrid6tipodoc: TcxDBEditorRow
        Height = 17
        Properties.Caption = 'Tipo de documento'
        Properties.EditPropertiesClassName = 'TcxLookupComboBoxProperties'
        Properties.EditProperties.KeyFieldNames = 'Idtipodoc'
        Properties.EditProperties.ListColumns = <
          item
            Caption = 'Tipo de Documento'
            FieldName = 'Tipodoc'
          end>
        Properties.EditProperties.ListSource = UDM.dscl_tipodoc
        Properties.DataBinding.FieldName = 'tipodoc'
        ID = 5
        ParentID = -1
        Index = 2
        Version = 1
      end
      object cxDBVerticalGrid6ayear: TcxDBEditorRow
        Properties.Caption = 'A'#241'o'
        Properties.DataBinding.FieldName = 'ayear'
        ID = 6
        ParentID = -1
        Index = 3
        Version = 1
      end
      object cxDBVerticalGrid6CategoryRow2: TcxCategoryRow
        Properties.Caption = 'RETARDO'
        ID = 7
        ParentID = -1
        Index = 4
        Version = 1
      end
      object cxDBVerticalGrid6tgestion: TcxDBEditorRow
        Properties.Caption = 'Archivo de Gesti'#243'n'
        Properties.DataBinding.FieldName = 'tgestion'
        ID = 8
        ParentID = 7
        Index = 0
        Version = 1
      end
      object cxDBVerticalGrid6tcentral: TcxDBEditorRow
        Properties.Caption = 'Archivo Central'
        Properties.DataBinding.FieldName = 'tcentral'
        ID = 9
        ParentID = 7
        Index = 1
        Version = 1
      end
      object cxDBVerticalGrid6destino: TcxDBEditorRow
        Properties.Caption = 'Destino'
        Properties.EditPropertiesClassName = 'TcxLookupComboBoxProperties'
        Properties.EditProperties.KeyFieldNames = 'IdDestino'
        Properties.EditProperties.ListColumns = <
          item
            Caption = 'Destino'
            HeaderAlignment = taCenter
            FieldName = 'NombreDestino'
          end>
        Properties.EditProperties.ListSource = UDM.dscl_destino
        Properties.DataBinding.FieldName = 'destino'
        ID = 10
        ParentID = -1
        Index = 5
        Version = 1
      end
      object cxDBVerticalGrid6acceso: TcxDBEditorRow
        Properties.Caption = 'Acceso'
        Properties.EditPropertiesClassName = 'TcxLookupComboBoxProperties'
        Properties.EditProperties.KeyFieldNames = 'Idacceso'
        Properties.EditProperties.ListColumns = <
          item
            Caption = 'Acceso'
            HeaderAlignment = taCenter
            FieldName = 'NombreAcceso'
          end>
        Properties.EditProperties.ListSource = UDM.dscl_acceso
        Properties.DataBinding.FieldName = 'acceso'
        ID = 11
        ParentID = -1
        Index = 6
        Version = 1
      end
      object cxDBVerticalGrid6soporte: TcxDBEditorRow
        Properties.Caption = 'Soporte'
        Properties.EditPropertiesClassName = 'TcxLookupComboBoxProperties'
        Properties.EditProperties.KeyFieldNames = 'Idsoporte'
        Properties.EditProperties.ListColumns = <
          item
            Caption = 'Soporte'
            HeaderAlignment = taCenter
            FieldName = 'Nombresoporte'
          end>
        Properties.EditProperties.ListSource = UDM.dscl_soporte
        Properties.DataBinding.FieldName = 'soporte'
        ID = 12
        ParentID = -1
        Index = 7
        Version = 1
      end
      object cxDBVerticalGrid6observacion: TcxDBEditorRow
        Properties.Caption = 'Observaci'#243'n'
        Properties.EditPropertiesClassName = 'TcxBlobEditProperties'
        Properties.EditProperties.BlobEditKind = bekMemo
        Properties.EditProperties.PopupHeight = 250
        Properties.DataBinding.FieldName = 'observacion'
        ID = 13
        ParentID = -1
        Index = 8
        Version = 1
      end
    end
    object Panel1: TPanel
      Left = 1
      Top = 25
      Width = 372
      Height = 30
      Align = alTop
      TabOrder = 1
      object btnFunciones: TJvTransparentButton
        Left = 316
        Top = 1
        Width = 55
        Height = 28
        Hint = 'Variables virtuales asociaadas'
        Align = alRight
        FrameStyle = fsLight
        ParentShowHint = False
        ShowHint = True
        Transparent = False
        OnClick = btnFuncionesClick
        Glyph.Data = {
          460E0000424D460E00000000000036000000280000001E0000001E0000000100
          200000000000100E000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000FFBF0030FFBF0093FFC00099FFC00099FFC00099FFC0
          0099FFC00099FFC00099FFBF0064FFFF00010000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000FFBF
          0010FFC000EDFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFC0006100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000FFBE003BFFBF00FFFFBF
          00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          009F00000000000000000000000000000000000000000000000000000000FFFF
          0001FFC00089FFBE006200000000FFBF0004FFBF0090FFC0005900000000FFB6
          0007FFBE0096FFBF005000000000FFC0003DFFBF00FFFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFC000A1000000000000
          00000000000000000000000000000000000000000000FFC4000DFFBF00FAFFBF
          00CA00000000FFBF0018FFBE00FDFFC000BD00000000FFBD0023FFBF00FEFFBF
          00AF00000000FFC0003DFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFBF00FFFFBF00FFFFC000A10000000000000000000000000000
          000000000000000000000000000000000000FFC1002DFFC1001D000000000000
          0000FFC10031FFC200190000000000000000FFBF0034FFC2001500000000FFC0
          003DFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFC000A100000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000FFBF0030FFBF00FFFFBF
          00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          009300000000000000000000000000000000000000000000000000000000FFFF
          0001FFBF0093FFBF006700000000000000000000000000000000000000000000
          0000000000000000000000000000FF800002FFC000BDFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFC000F1FFC10031000000000000
          00000000000000000000000000000000000000000000FFBF000CFFBF00F7FFC0
          00C5000000000000000000000000000000000000000000000000000000000000
          00000000000000000000FFAA0003FFC10031FFBF0044FFBF0044FFBF0044FFBF
          0044FFBF0044FFBD003EFFC30011000000000000000000000000000000000000
          000000000000000000000000000000000000FFBD001FFFBC0013000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000FF80
          0002FFBF009FFFBF007400000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000FFB9000BFFBF00F2FFBF
          00C0000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000FFBC0013FFB9000B000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000FFBE0033FFBF00BEFFBF00CCFFBF
          00CCFFBF00CCFFBF00CCFFBF00CCFFBF00CCFFBF00AFFFBD001B000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000FFBF00DEFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFBF00FFFFBF00FFFFC000AD0000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000FFB6
          0007FFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFBF00D700000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000FFB60007FFBF00FFFFBF
          00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          00D7000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000FFB60007FFBF00FFFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00D7000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000FFB60007FFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFBF00FFFFBF00FFFFBF00D70000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          000000000000000000000000000000000000000000000000000000000000FFFF
          0001FFBF00EEFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF
          00FFFFBF00FFFFBF00BF00000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000FFBF005FFFC0
          00F1FFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00FFFFBF00E4FFBE
          003B000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000FFFF0001FFC30011FFC3
          0011FFC30011FFC30011FFC30011FFBB000F0000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000000000000000
          00000000000000000000}
        ExplicitLeft = 312
        ExplicitTop = 6
        ExplicitHeight = 39
      end
      object cxDBNavigator1: TcxDBNavigator
        Left = 274
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
        DataSource = UDM.dscl_subseries
        InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
        InfoPanel.Visible = True
        Align = alRight
        TabOrder = 0
      end
      object DBNavigator1: TDBNavigator
        Left = 1
        Top = 1
        Width = 273
        Height = 28
        DataSource = UDM.dscl_subseries
        VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
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
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 372
      Height = 24
      Align = alTop
      Caption = 'SubSeries Documentales'
      Font.Charset = ANSI_CHARSET
      Font.Color = 10789888
      Font.Height = -16
      Font.Name = 'Ink Free'
      Font.Style = [fsBold]
      ParentBackground = False
      ParentFont = False
      TabOrder = 2
    end
  end
  object Panel5: TPanel
    Left = 861
    Top = 37
    Width = 10
    Height = 420
    Align = alRight
    BevelInner = bvLowered
    BorderStyle = bsSingle
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 10789888
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 4
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 736
    Top = 117
  end
end
