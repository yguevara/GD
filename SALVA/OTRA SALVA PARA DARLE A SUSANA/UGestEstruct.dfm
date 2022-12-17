object frmEstructura: TfrmEstructura
  Left = 0
  Top = 0
  ClientHeight = 562
  ClientWidth = 499
  Color = clBtnFace
  Constraints.MaxHeight = 601
  Constraints.MaxWidth = 515
  Constraints.MinHeight = 601
  Constraints.MinWidth = 515
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 499
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
      OnClick = btnCloseClick
    end
    object ToolButton3: TToolButton
      Left = 31
      Top = 0
      Width = 418
      Caption = 'ToolButton3'
      ImageIndex = 136
      Style = tbsSeparator
    end
    object btnhlp: TToolButton
      Left = 449
      Top = 0
      Hint = 'Ayuda para manipular la interface actual'
      Caption = 'btnhlp'
      ImageIndex = 1
      ParentShowHint = False
      ShowHint = True
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 543
    Width = 499
    Height = 19
    Panels = <>
    ExplicitTop = 315
  end
  object cxPageControl1: TcxPageControl
    Left = 0
    Top = 37
    Width = 499
    Height = 506
    Align = alClient
    TabOrder = 2
    Properties.ActivePage = tsFunciones
    Properties.CustomButtons.Buttons = <>
    ExplicitTop = 31
    ExplicitHeight = 290
    ClientRectBottom = 502
    ClientRectLeft = 4
    ClientRectRight = 495
    ClientRectTop = 24
    object tsFunciones: TcxTabSheet
      Caption = 'Gestionar Etiquetas'
      ImageIndex = 0
      ExplicitLeft = 3
      ExplicitTop = 22
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 491
        Height = 41
        Align = alTop
        TabOrder = 0
        object cxDBNavigator3: TcxDBNavigator
          Left = 448
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
          DataSource = UDM.dstb_tree
          InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
          InfoPanel.Visible = True
          Align = alRight
          TabOrder = 0
        end
        object DBNavigator3: TDBNavigator
          Left = 1
          Top = 1
          Width = 447
          Height = 39
          DataSource = UDM.dstb_tree
          VisibleButtons = [nbPost, nbCancel]
          Align = alClient
          TabOrder = 1
          ExplicitLeft = -5
          ExplicitTop = -4
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 41
        Width = 491
        Height = 170
        Align = alTop
        BorderStyle = bsSingle
        TabOrder = 1
        ExplicitTop = 36
        object Label2: TLabel
          Left = 86
          Top = 18
          Width = 33
          Height = 13
          Caption = 'C'#243'digo'
        end
        object Label3: TLabel
          Left = 213
          Top = 18
          Width = 20
          Height = 13
          Caption = 'Tipo'
        end
        object Label1: TLabel
          Left = 86
          Top = 64
          Width = 40
          Height = 13
          Caption = 'Etiqueta'
        end
        object Label5: TLabel
          Left = 86
          Top = 112
          Width = 28
          Height = 13
          Caption = 'Padre'
        end
        object Label4: TLabel
          Left = 280
          Top = 112
          Width = 34
          Height = 13
          Caption = 'ICONO'
        end
        object edtCodigo: TcxDBTextEdit
          Left = 86
          Top = 37
          DataBinding.DataField = 'id'
          DataBinding.DataSource = UDM.dstb_tree
          TabOrder = 0
          Width = 121
        end
        object lcbTipoNodo: TcxDBLookupComboBox
          Left = 213
          Top = 37
          DataBinding.DataField = 'tipo'
          DataBinding.DataSource = UDM.dstb_tree
          Properties.KeyFieldNames = 'Idestructura'
          Properties.ListColumns = <
            item
              Caption = 'ESTRUCTURA'
              HeaderAlignment = taCenter
              FieldName = 'Nombreestructura'
            end>
          Properties.ListSource = UDM.dscl_tipoestructura
          Properties.OnCloseUp = lcbTipoNodoPropertiesCloseUp
          TabOrder = 1
          Width = 188
        end
        object edtEtiqueta: TcxDBTextEdit
          Left = 86
          Top = 85
          DataBinding.DataField = 'etiqueta'
          DataBinding.DataSource = UDM.dstb_tree
          TabOrder = 2
          Width = 315
        end
        object lcbPadre: TcxDBLookupComboBox
          Left = 86
          Top = 131
          DataBinding.DataField = 'padre'
          DataBinding.DataSource = UDM.dstb_tree
          Properties.KeyFieldNames = 'id'
          Properties.ListColumns = <
            item
              Caption = 'PADRE'
              FieldName = 'etiqueta'
            end>
          Properties.ListSource = UDM.dsAllFather
          TabOrder = 3
          Width = 188
        end
        object lcbIMG: TcxDBImageComboBox
          Left = 280
          Top = 131
          DataBinding.DataField = 'icono'
          DataBinding.DataSource = UDM.dstb_tree
          Properties.Images = UDM.ILDigital
          Properties.Items = <
            item
              ImageIndex = 0
              Value = 0
            end
            item
              ImageIndex = 1
              Value = 1
            end
            item
              ImageIndex = 2
              Value = 2
            end
            item
              ImageIndex = 3
              Value = 3
            end
            item
              ImageIndex = 4
              Value = 4
            end
            item
              ImageIndex = 5
              Value = 5
            end
            item
              ImageIndex = 6
              Value = 6
            end
            item
              ImageIndex = 7
              Value = 7
            end
            item
              ImageIndex = 8
              Value = 8
            end
            item
              ImageIndex = 9
              Value = 9
            end
            item
              ImageIndex = 10
              Value = 10
            end
            item
              ImageIndex = 11
              Value = 11
            end
            item
              ImageIndex = 12
              Value = 12
            end
            item
              ImageIndex = 13
              Value = 13
            end
            item
              ImageIndex = 14
            end>
          TabOrder = 4
          Width = 121
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 211
        Width = 491
        Height = 267
        Align = alClient
        Caption = 'Panel2'
        TabOrder = 2
        ExplicitTop = 209
        object cxPageControl2: TcxPageControl
          Left = 1
          Top = 1
          Width = 489
          Height = 265
          Align = alClient
          TabOrder = 0
          Properties.ActivePage = tsProperties
          Properties.CustomButtons.Buttons = <>
          ExplicitTop = 0
          ClientRectBottom = 261
          ClientRectLeft = 4
          ClientRectRight = 485
          ClientRectTop = 24
          object tsProperties: TcxTabSheet
            Caption = 'Propiedades del Cargo'
            ImageIndex = 0
            ExplicitLeft = 5
            ExplicitTop = 25
            object Label6: TLabel
              Left = 22
              Top = 10
              Width = 36
              Height = 13
              Caption = 'CARGO'
            end
            object cxDBLookupComboBox1: TcxDBLookupComboBox
              Left = 22
              Top = 29
              DataBinding.DataField = 'idcargo'
              DataBinding.DataSource = UDM.dstb_tree
              Properties.KeyFieldNames = 'Idcargo'
              Properties.ListColumns = <
                item
                  Caption = 'CARGO'
                  HeaderAlignment = taCenter
                  FieldName = 'nombre'
                end>
              Properties.ListSource = UDM.dscl_cargo
              Properties.OnCloseUp = lcbTipoNodoPropertiesCloseUp
              TabOrder = 0
              Width = 418
            end
            object cxPageControl3: TcxPageControl
              Left = 0
              Top = 56
              Width = 481
              Height = 181
              Align = alBottom
              TabOrder = 1
              Properties.ActivePage = tsfuncion
              Properties.CustomButtons.Buttons = <>
              ClientRectBottom = 177
              ClientRectLeft = 4
              ClientRectRight = 477
              ClientRectTop = 24
              object tsfuncion: TcxTabSheet
                Caption = 'Funciones'
                ImageIndex = 0
                ExplicitLeft = 3
                ExplicitTop = 25
              end
              object tsCargo: TcxTabSheet
                Caption = 'Facultades'
                ImageIndex = 2
                ExplicitLeft = 3
                ExplicitTop = 25
              end
            end
          end
          object cxTabSheet3: TcxTabSheet
            Caption = 'Series'
            ImageIndex = 2
            ExplicitWidth = 810
            ExplicitHeight = 295
          end
        end
      end
    end
  end
end
