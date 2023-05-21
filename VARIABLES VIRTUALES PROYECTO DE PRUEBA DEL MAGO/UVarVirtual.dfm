object FVarVirtual: TFVarVirtual
  Left = 0
  Top = 0
  Caption = 'FVariablesVirtuales'
  ClientHeight = 373
  ClientWidth = 1060
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter2: TSplitter
    Left = 377
    Top = 0
    Width = 6
    Height = 373
    Color = clBackground
    ParentColor = False
    ExplicitLeft = 337
    ExplicitHeight = 450
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 377
    Height = 373
    Align = alLeft
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 1
      Top = 179
      Width = 375
      Height = 5
      Cursor = crVSplit
      Align = alTop
      Color = clSkyBlue
      ParentColor = False
      ExplicitTop = 297
      ExplicitWidth = 703
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 375
      Height = 35
      Align = alTop
      Caption = 'SubSerie Documental'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
    end
    object Panel3: TPanel
      Left = 1
      Top = 184
      Width = 375
      Height = 188
      Align = alClient
      Caption = 'Panel3'
      TabOrder = 1
      object DBNavigator1: TDBNavigator
        Left = 1
        Top = 157
        Width = 373
        Height = 30
        DataSource = DM.Dtb_SerieDatosVar
        Align = alBottom
        TabOrder = 0
      end
      object cxGrid1: TcxGrid
        Left = 1
        Top = 25
        Width = 373
        Height = 132
        Align = alClient
        TabOrder = 1
        ExplicitLeft = 3
        ExplicitTop = 19
        object cxGrid1DBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DM.Dtb_SerieDatosVar
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          object cxGrid1DBTableView1Id: TcxGridDBColumn
            DataBinding.FieldName = 'Id'
            Visible = False
            HeaderAlignmentHorz = taCenter
            Width = 49
          end
          object cxGrid1DBTableView1codsubs: TcxGridDBColumn
            DataBinding.FieldName = 'codsubs'
            Visible = False
            HeaderAlignmentHorz = taCenter
            Width = 53
          end
          object cxGrid1DBTableView1Fecha: TcxGridDBColumn
            DataBinding.FieldName = 'Fecha'
            Visible = False
            HeaderAlignmentHorz = taCenter
            Width = 90
          end
          object cxGrid1DBTableView1Version: TcxGridDBColumn
            DataBinding.FieldName = 'Version'
            Visible = False
            HeaderAlignmentHorz = taCenter
          end
          object cxGrid1DBTableView1Orden: TcxGridDBColumn
            DataBinding.FieldName = 'Orden'
            HeaderAlignmentHorz = taCenter
          end
          object cxGrid1DBTableView1IdVar: TcxGridDBColumn
            DataBinding.FieldName = 'IdVar'
            PropertiesClassName = 'TcxLookupComboBoxProperties'
            Properties.KeyFieldNames = 'IdVar'
            Properties.ListColumns = <
              item
                FieldName = 'Etiqueta'
              end>
            Properties.ListSource = DM.Dcl_Variables
            HeaderAlignmentHorz = taCenter
            Width = 74
          end
          object cxGrid1DBTableView1VarInteger: TcxGridDBColumn
            DataBinding.FieldName = 'VarInteger'
          end
          object cxGrid1DBTableView1VarDouble: TcxGridDBColumn
            DataBinding.FieldName = 'VarDouble'
          end
          object cxGrid1DBTableView1VarDate: TcxGridDBColumn
            DataBinding.FieldName = 'VarDate'
            Width = 120
          end
          object cxGrid1DBTableView1VarString255: TcxGridDBColumn
            DataBinding.FieldName = 'VarString255'
            Width = 100
          end
        end
        object cxGrid1Level1: TcxGridLevel
          GridView = cxGrid1DBTableView1
        end
      end
      object Panel5: TPanel
        Left = 1
        Top = 1
        Width = 373
        Height = 24
        Align = alTop
        Caption = 'Variables'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 2
      end
    end
    object Panel4: TPanel
      Left = 1
      Top = 36
      Width = 375
      Height = 143
      Align = alTop
      Caption = 'Panel3'
      TabOrder = 2
      object DBGrid2: TDBGrid
        Left = 1
        Top = 1
        Width = 373
        Height = 111
        Align = alClient
        DataSource = DM.Dtb_SeriesDatos
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'Id'
            Width = 22
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'codsubs'
            Width = 55
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Fecha'
            Width = 61
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Version'
            Width = 44
            Visible = True
          end>
      end
      object DBNavigator2: TDBNavigator
        Left = 1
        Top = 112
        Width = 373
        Height = 30
        DataSource = DM.Dtb_SeriesDatos
        Align = alBottom
        TabOrder = 1
      end
    end
  end
  object Panel6: TPanel
    Left = 383
    Top = 0
    Width = 562
    Height = 373
    Align = alLeft
    TabOrder = 1
    object Panel7: TPanel
      Left = 1
      Top = 1
      Width = 560
      Height = 35
      Align = alTop
      Caption = 'Clasificador de Variables'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      ExplicitWidth = 528
    end
    object Panel10: TPanel
      Left = 1
      Top = 36
      Width = 560
      Height = 336
      Align = alClient
      Caption = 'Panel3'
      TabOrder = 1
      ExplicitWidth = 528
      object DBNavigator4: TDBNavigator
        Left = 1
        Top = 305
        Width = 558
        Height = 30
        DataSource = DM.Dcl_Variables
        Align = alBottom
        TabOrder = 0
        ExplicitWidth = 526
      end
      object cxGrid2: TcxGrid
        Left = 1
        Top = 1
        Width = 558
        Height = 304
        Align = alClient
        TabOrder = 1
        ExplicitLeft = -1
        ExplicitTop = 6
        object cxGrid2DBTableView1: TcxGridDBTableView
          Navigator.Buttons.CustomButtons = <>
          DataController.DataSource = DM.Dcl_Variables
          DataController.Summary.DefaultGroupSummaryItems = <>
          DataController.Summary.FooterSummaryItems = <>
          DataController.Summary.SummaryGroups = <>
          OptionsView.GroupByBox = False
          OptionsView.Indicator = True
          OptionsView.IndicatorWidth = 15
          object cxGrid2DBTableView1IdVar: TcxGridDBColumn
            Caption = 'ID'
            DataBinding.FieldName = 'IdVar'
            HeaderAlignmentHorz = taCenter
            Width = 40
          end
          object cxGrid2DBTableView1NomVariable: TcxGridDBColumn
            Caption = 'Nombre Variable'
            DataBinding.FieldName = 'NomVariable'
            HeaderAlignmentHorz = taCenter
            Width = 115
          end
          object cxGrid2DBTableView1Etiqueta: TcxGridDBColumn
            DataBinding.FieldName = 'Etiqueta'
            HeaderAlignmentHorz = taCenter
          end
          object cxGrid2DBTableView1tipo: TcxGridDBColumn
            DataBinding.FieldName = 'tipo'
            PropertiesClassName = 'TcxComboBoxProperties'
            Properties.Items.Strings = (
              'Entero'
              'Real'
              'Fecha'
              'Cadena')
            HeaderAlignmentHorz = taCenter
          end
          object cxGrid2DBTableView1longitud: TcxGridDBColumn
            DataBinding.FieldName = 'longitud'
            HeaderAlignmentHorz = taCenter
          end
          object cxGrid2DBTableView1descripcion: TcxGridDBColumn
            DataBinding.FieldName = 'descripcion'
            PropertiesClassName = 'TcxBlobEditProperties'
            Properties.BlobEditKind = bekMemo
            HeaderAlignmentHorz = taCenter
          end
          object cxGrid2DBTableView1ListaDesplegable: TcxGridDBColumn
            DataBinding.FieldName = 'ListaDesplegable'
            HeaderAlignmentHorz = taCenter
            Width = 53
          end
        end
        object cxGrid2Level1: TcxGridLevel
          GridView = cxGrid2DBTableView1
        end
      end
    end
  end
  object Panel8: TPanel
    Left = 945
    Top = 0
    Width = 115
    Height = 373
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 913
    ExplicitWidth = 112
    object Button1: TButton
      Left = 6
      Top = 157
      Width = 89
      Height = 57
      Caption = 'Editar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
