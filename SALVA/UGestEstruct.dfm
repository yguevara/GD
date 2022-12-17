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
    ClientRectBottom = 502
    ClientRectLeft = 4
    ClientRectRight = 495
    ClientRectTop = 24
    object tsFunciones: TcxTabSheet
      Caption = 'Gestionar Etiquetas'
      ImageIndex = 0
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
        object cxPageControl2: TcxPageControl
          Left = 1
          Top = 1
          Width = 489
          Height = 265
          Align = alClient
          TabOrder = 0
          Properties.ActivePage = cxTabSheet3
          Properties.CustomButtons.Buttons = <>
          ClientRectBottom = 261
          ClientRectLeft = 4
          ClientRectRight = 485
          ClientRectTop = 24
          object tsProperties: TcxTabSheet
            Caption = 'Propiedades del Cargo'
            ImageIndex = 0
            object cxDBVerticalGrid6: TcxDBVerticalGrid
              Left = 0
              Top = 0
              Width = 481
              Height = 237
              Align = alClient
              OptionsView.PaintStyle = psDelphi
              OptionsView.RowHeaderWidth = 215
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
              DataController.DataSource = UDM.dstb_tree
              ExplicitTop = 3
              Version = 1
              object cxDBVerticalGrid6id: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'id'
                ID = 0
                ParentID = -1
                Index = 0
                Version = 1
              end
              object cxDBVerticalGrid6etiqueta: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'etiqueta'
                ID = 1
                ParentID = -1
                Index = 1
                Version = 1
              end
              object cxDBVerticalGrid6padre: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'padre'
                ID = 2
                ParentID = -1
                Index = 2
                Version = 1
              end
              object cxDBVerticalGrid6icono: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'icono'
                ID = 3
                ParentID = -1
                Index = 3
                Version = 1
              end
              object cxDBVerticalGrid6tipo: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'tipo'
                ID = 4
                ParentID = -1
                Index = 4
                Version = 1
              end
              object cxDBVerticalGrid6idcargo: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'idcargo'
                ID = 5
                ParentID = -1
                Index = 5
                Version = 1
              end
              object cxDBVerticalGrid6idfacultades: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'idfacultades'
                ID = 6
                ParentID = -1
                Index = 6
                Version = 1
              end
              object cxDBVerticalGrid6idfunciones: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'idfunciones'
                ID = 7
                ParentID = -1
                Index = 7
                Version = 1
              end
              object cxDBVerticalGrid6Observaciones: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'Observaciones'
                ID = 8
                ParentID = -1
                Index = 8
                Version = 1
              end
            end
          end
          object cxTabSheet3: TcxTabSheet
            Caption = 'Series'
            ImageIndex = 2
            object Panel5: TPanel
              Left = 0
              Top = 0
              Width = 481
              Height = 41
              Align = alTop
              TabOrder = 0
              object cxDBNavigator4: TcxDBNavigator
                Left = 438
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
                DataSource = UDM.dstb_subseries
                InfoPanel.DisplayMask = '[RecordIndex] de [RecordCount]'
                InfoPanel.Visible = True
                Align = alRight
                TabOrder = 0
              end
              object DBNavigator4: TDBNavigator
                Left = 1
                Top = 1
                Width = 437
                Height = 39
                DataSource = UDM.dstb_subseries
                VisibleButtons = [nbPrior, nbNext, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
                Align = alClient
                Enabled = False
                TabOrder = 1
              end
            end
            object cxDBVerticalGrid1: TcxDBVerticalGrid
              Left = 0
              Top = 41
              Width = 481
              Height = 196
              Align = alClient
              OptionsView.PaintStyle = psDelphi
              OptionsView.RowHeaderWidth = 179
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
              TabOrder = 1
              DataController.DataSource = UDM.dstb_subseries
              Version = 1
              object cxDBVerticalGrid1id: TcxDBEditorRow
                Properties.DataBinding.FieldName = 'id'
                Visible = False
                ID = 0
                ParentID = -1
                Index = 0
                Version = 1
              end
              object cxDBVerticalGrid1codserie: TcxDBEditorRow
                Properties.Caption = 'SERIES'
                Properties.EditPropertiesClassName = 'TcxLookupComboBoxProperties'
                Properties.EditProperties.KeyFieldNames = 'codserie'
                Properties.EditProperties.ListColumns = <
                  item
                    Caption = 'SERIES'
                    HeaderAlignment = taCenter
                    MinWidth = 60
                    FieldName = 'serie'
                  end>
                Properties.EditProperties.ListSource = UDM.dscl_series
                Properties.DataBinding.FieldName = 'codserie'
                ID = 1
                ParentID = -1
                Index = 1
                Version = 1
              end
              object cxDBVerticalGrid1codsubs: TcxDBEditorRow
                Properties.Caption = 'Subseries'
                Properties.EditPropertiesClassName = 'TcxLookupComboBoxProperties'
                Properties.EditProperties.KeyFieldNames = 'codsubs'
                Properties.EditProperties.ListColumns = <
                  item
                    Caption = 'Subserie'
                    HeaderAlignment = taCenter
                    MinWidth = 60
                    FieldName = 'subserie'
                  end>
                Properties.EditProperties.ListSource = UDM.dscl_subseries
                Properties.DataBinding.FieldName = 'codsubs'
                ID = 2
                ParentID = -1
                Index = 2
                Version = 1
              end
              object catUbica: TcxCategoryRow
                Height = 30
                Properties.Caption = 'UBICACI'#211'N'
                Properties.HeaderAlignmentHorz = taCenter
                ID = 3
                ParentID = -1
                Index = 3
                Version = 1
              end
              object cxDBVerticalGrid1ubicacion: TcxDBEditorRow
                Properties.Caption = 'Ubicaci'#243'n'
                Properties.DataBinding.FieldName = 'ubicacion'
                ID = 4
                ParentID = 3
                Index = 0
                Version = 1
              end
              object cxDBVerticalGrid1deposito: TcxDBEditorRow
                Properties.Caption = 'Dep'#243'sito'
                Properties.DataBinding.FieldName = 'deposito'
                ID = 5
                ParentID = 3
                Index = 1
                Version = 1
              end
              object cxDBVerticalGrid1gaveta: TcxDBEditorRow
                Properties.Caption = 'Gaveta'
                Properties.DataBinding.FieldName = 'gaveta'
                ID = 6
                ParentID = 3
                Index = 2
                Version = 1
              end
              object cxDBVerticalGrid1file: TcxDBEditorRow
                Properties.Caption = 'File'
                Properties.DataBinding.FieldName = 'file'
                ID = 7
                ParentID = 3
                Index = 3
                Version = 1
              end
              object cxDBVerticalGrid1carpeta: TcxDBEditorRow
                Properties.Caption = 'Carpeta'
                Properties.DataBinding.FieldName = 'carpeta'
                ID = 8
                ParentID = 3
                Index = 4
                Version = 1
              end
              object cxDBVerticalGrid1Idresp: TcxDBEditorRow
                Properties.Caption = 'Responsable'
                Properties.EditPropertiesClassName = 'TcxLookupComboBoxProperties'
                Properties.EditProperties.KeyFieldNames = 'Idresp'
                Properties.EditProperties.ListColumns = <
                  item
                    FieldName = 'NombreResponsable'
                  end>
                Properties.EditProperties.ListSource = UDM.dscl_Resp_Gest_Arch
                Properties.DataBinding.FieldName = 'Idresp'
                ID = 9
                ParentID = -1
                Index = 4
                Version = 1
              end
              object cxDBVerticalGrid1Idservidor: TcxDBEditorRow
                Properties.Caption = 'Archivo Digital'
                Properties.EditPropertiesClassName = 'TcxLookupComboBoxProperties'
                Properties.EditProperties.KeyFieldNames = 'Idservidor'
                Properties.EditProperties.ListColumns = <
                  item
                    Caption = 'Archivo digital'
                    HeaderAlignment = taCenter
                    FieldName = 'NombreServer'
                  end>
                Properties.EditProperties.ListSource = UDM.dscl_ftp_Server
                Properties.DataBinding.FieldName = 'Idservidor'
                ID = 10
                ParentID = -1
                Index = 5
                Version = 1
              end
              object cxDBVerticalGrid1PathEspecificoFile: TcxDBEditorRow
                Properties.Caption = 'Ruta especifica del Fichero '
                Properties.DataBinding.FieldName = 'PathEspecificoFile'
                ID = 11
                ParentID = -1
                Index = 6
                Version = 1
              end
              object cxDBVerticalGrid1observacion: TcxDBEditorRow
                Properties.Caption = 'Observaciones'
                Properties.DataBinding.FieldName = 'observacion'
                ID = 12
                ParentID = -1
                Index = 7
                Version = 1
              end
            end
          end
        end
      end
    end
  end
end
