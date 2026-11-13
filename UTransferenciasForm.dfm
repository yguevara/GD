object frmTransferenciasNuevo: TfrmTransferenciasNuevo
  Left = 0
  Top = 0
  Caption = 'Transferencias'
  ClientHeight = 720
  ClientWidth = 1280
  Color = 15528951
  Font.Charset = DEFAULT_CHARSET
  Font.Color = 1581355
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 15
  object pnlLista: TPanel
    Left = 0
    Top = 0
    Width = 1280
    Height = 720
    Align = alClient
    BevelOuter = bvNone
    Color = 15528951
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    object pnlCabecera: TPanel
      Left = 0
      Top = 0
      Width = 1280
      Height = 66
      Align = alTop
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
      object lblTitulo: TLabel
        Left = 20
        Top = 10
        Width = 74
        Height = 23
        Caption = 'Transferencias'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1581355
        Font.Height = -17
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object lblSubtitulo: TLabel
        Left = 20
        Top = 38
        Width = 3
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object pnlCabeceraAcciones: TPanel
        Left = 600
        Top = 0
        Width = 680
        Height = 65
        Align = alRight
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        object lblNodoTrab: TLabel
          Left = 10
          Top = 6
          Width = 3
          Height = 15
          Caption = 'Crear en el nodo'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object cboNodoTrabajo: TcxComboBox
          Left = 10
          Top = 26
          Properties.DropDownListStyle = lsFixedList
          Properties.OnChange = cboNodoTrabajoPropertiesChange
          TabOrder = 2
          Width = 265
        end
        object btnAbrir: TcxButton
          Left = 290
          Top = 15
          Width = 100
          Height = 36
          Caption = 'Abrir'
          TabOrder = 0
          OnClick = btnAbrirClick
        end
        object btnNueva: TcxButton
          Left = 404
          Top = 15
          Width = 200
          Height = 36
          Caption = 'Nueva transferencia'
          TabOrder = 1
          OnClick = btnNuevaClick
        end
      end
      object pnlCabeceraLinea: TPanel
        Left = 0
        Top = 65
        Width = 1280
        Height = 1
        Align = alBottom
        BevelOuter = bvNone
        Color = 13031136
        ParentBackground = False
        ShowCaption = False
        TabOrder = 1
      end
    end
    object pnlCronograma: TPanel
      Left = 0
      Top = 66
      Width = 1280
      Height = 216
      Align = alTop
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 1
      object lblCronTitulo: TLabel
        Left = 20
        Top = 12
        Width = 3
        Height = 15
        Caption = 'CRONOGRAMA ANUAL (UNA TRANSFERENCIA POR UNIDAD)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -11
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object grdCronograma: TcxGrid
        Left = 20
        Top = 32
        Width = 1240
        Height = 128
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = cxcbsNone
        TabOrder = 0
        LookAndFeel.Kind = lfUltraFlat
        LookAndFeel.NativeStyle = False
        object tvCronograma: TcxGridTableView
          OnCustomDrawColumnHeader = tvCustomDrawColumnHeader
          OptionsData.Appending = False
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsCustomize.ColumnSorting = False
          OptionsSelection.CellSelect = False
          OptionsView.CellAutoHeight = True
          OptionsView.ColumnAutoWidth = True
          OptionsView.DataRowHeight = 30
          OptionsView.GridLineColor = 13031136
          OptionsView.GridLines = glHorizontal
          OptionsView.GroupByBox = False
          OptionsView.HeaderHeight = 28
          OptionsView.Indicator = False
          OptionsView.NoDataToDisplayInfoText = 'Sin transferencias programadas'
          Styles.Background = stContenidoPeq
          Styles.Content = stContenidoPeq
          Styles.ContentEven = stContenidoPeq
          Styles.ContentOdd = stContenidoPeq
          Styles.Header = stCabeceraGrid
          Styles.Inactive = stSeleccion
          Styles.Selection = stSeleccion
          object colCronUnidad: TcxGridColumn
            Caption = 'Unidad'
            DataBinding.ValueType = 'String'
            Width = 220
          end
          object colCronFecha: TcxGridColumn
            Caption = 'Fecha prevista'
            DataBinding.ValueType = 'String'
            Width = 110
          end
          object colCronEstado: TcxGridColumn
            Caption = 'Estado'
            DataBinding.ValueType = 'String'
            Width = 130
          end
          object colCronNumero: TcxGridColumn
            Caption = 'Transferencia'
            DataBinding.ValueType = 'String'
            Width = 110
          end
        end
        object lvCronograma: TcxGridLevel
          GridView = tvCronograma
        end
      end
      object lblProgramar: TLabel
        Left = 20
        Top = 176
        Width = 3
        Height = 15
        Caption = 'Programar la transferencia de este nodo para el'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object dteProgramar: TcxDateEdit
        Left = 330
        Top = 170
        TabOrder = 1
        Width = 150
      end
      object btnProgramar: TcxButton
        Left = 494
        Top = 166
        Width = 130
        Height = 32
        Caption = 'Programar'
        TabOrder = 2
        OnClick = btnProgramarClick
      end
    end
    object pnlTabla: TPanel
      Left = 0
      Top = 282
      Width = 1280
      Height = 438
      Align = alClient
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      Padding.Left = 16
      Padding.Right = 16
      Padding.Bottom = 16
      TabOrder = 2
      object grdTransferencias: TcxGrid
        Left = 16
        Top = 0
        Width = 1248
        Height = 422
        Align = alClient
        BorderStyle = cxcbsNone
        TabOrder = 0
        LookAndFeel.Kind = lfUltraFlat
        LookAndFeel.NativeStyle = False
        object tvTransferencias: TcxGridTableView
          OnCustomDrawColumnHeader = tvCustomDrawColumnHeader
          OnCellDblClick = tvTransferenciasCellDblClick
          OnFocusedRecordChanged = tvTransferenciasFocusedRecordChanged
          OptionsData.Appending = False
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsCustomize.ColumnSorting = False
          OptionsSelection.CellSelect = False
          OptionsView.CellAutoHeight = True
          OptionsView.ColumnAutoWidth = True
          OptionsView.DataRowHeight = 42
          OptionsView.GridLineColor = 13031136
          OptionsView.GridLines = glHorizontal
          OptionsView.GroupByBox = False
          OptionsView.HeaderHeight = 36
          OptionsView.Indicator = False
          OptionsView.NoDataToDisplayInfoText = 'No hay transferencias este a'#241'o'
          Styles.Background = stContenido
          Styles.Content = stContenido
          Styles.ContentEven = stContenido
          Styles.ContentOdd = stContenido
          Styles.Header = stCabeceraGrid
          Styles.Inactive = stSeleccion
          Styles.Selection = stSeleccion
          object colIdProceso: TcxGridColumn
            DataBinding.ValueType = 'Integer'
            Visible = False
            Width = 40
          end
          object colNumero: TcxGridColumn
            Caption = 'N.'#186
            DataBinding.ValueType = 'String'
            Width = 100
          end
          object colRemitente: TcxGridColumn
            Caption = 'Remitente'
            DataBinding.ValueType = 'String'
            Width = 200
          end
          object colDocumentos: TcxGridColumn
            Caption = 'Documentos'
            DataBinding.ValueType = 'String'
            Width = 90
          end
          object colCajas: TcxGridColumn
            Caption = 'Cajas'
            DataBinding.ValueType = 'String'
            Width = 60
          end
          object colPrevista: TcxGridColumn
            Caption = 'Fecha prevista'
            DataBinding.ValueType = 'String'
            Width = 100
          end
          object colPaso: TcxGridColumn
            Caption = 'Paso'
            DataBinding.ValueType = 'String'
            Width = 60
          end
          object colEstado: TcxGridColumn
            Caption = 'Estado'
            DataBinding.ValueType = 'String'
            Width = 150
          end
        end
        object lvTransferencias: TcxGridLevel
          GridView = tvTransferencias
        end
      end
    end
  end
  object pnlDetalle: TPanel
    Left = 0
    Top = 0
    Width = 1280
    Height = 720
    Align = alClient
    BevelOuter = bvNone
    Color = 15528951
    ParentBackground = False
    ShowCaption = False
    TabOrder = 1
    Visible = False
    object pnlDetCabecera: TPanel
      Left = 0
      Top = 0
      Width = 1280
      Height = 66
      Align = alTop
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
      object btnVolver: TcxButton
        Left = 20
        Top = 15
        Width = 160
        Height = 36
        Caption = #8249' Volver a la lista'
        TabOrder = 0
        OnClick = btnVolverClick
      end
      object lblDetTitulo: TLabel
        Left = 200
        Top = 10
        Width = 74
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1581355
        Font.Height = -17
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object lblDetSub: TLabel
        Left = 200
        Top = 38
        Width = 3
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object pnlDetLinea: TPanel
        Left = 0
        Top = 65
        Width = 1280
        Height = 1
        Align = alBottom
        BevelOuter = bvNone
        Color = 13031136
        ParentBackground = False
        ShowCaption = False
        TabOrder = 1
      end
    end
    object pnlPasos: TPanel
      Left = 0
      Top = 66
      Width = 1280
      Height = 84
      Align = alTop
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 1
      object pbPasos: TPaintBox
        Left = 0
        Top = 0
        Width = 1280
        Height = 84
        Align = alClient
        OnPaint = pbPasosPaint
      end
    end
    object pnlAcciones: TPanel
      Left = 0
      Top = 658
      Width = 1280
      Height = 62
      Align = alBottom
      BevelOuter = bvNone
      Color = 14806258
      ParentBackground = False
      ShowCaption = False
      TabOrder = 3
      object pnlAccionesDer: TPanel
        Left = 1010
        Top = 0
        Width = 270
        Height = 62
        Align = alRight
        BevelOuter = bvNone
        Color = 14806258
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        object btnAvanzar: TcxButton
          Left = 10
          Top = 13
          Width = 240
          Height = 36
          Caption = 'Pasar al siguiente paso'
          TabOrder = 0
          OnClick = btnAvanzarClick
        end
      end
      object btnCancelarTransf: TcxButton
        Left = 20
        Top = 13
        Width = 190
        Height = 36
        Caption = 'Cancelar transferencia'
        TabOrder = 1
        OnClick = btnCancelarTransfClick
      end
      object btnEliminarTransf: TcxButton
        Left = 224
        Top = 13
        Width = 190
        Height = 36
        Caption = 'Eliminar transferencia'
        TabOrder = 2
        OnClick = btnEliminarTransfClick
      end
    end
    object pnlAviso: TPanel
      Left = 0
      Top = 600
      Width = 1280
      Height = 58
      Align = alBottom
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 2
      object lblAviso: TLabel
        Left = 20
        Top = 6
        Width = 1240
        Height = 46
        AutoSize = False
        WordWrap = True
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1975987
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlContenido: TPanel
      Left = 0
      Top = 150
      Width = 1280
      Height = 450
      Align = alClient
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 2
      object pnlPaso1: TPanel
        Left = 0
        Top = 150
        Width = 1280
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        object pnlP1Prop: TPanel
          Left = 0
          Top = 0
          Width = 1280
          Height = 260
          Align = alTop
          BevelOuter = bvNone
          Color = 16383487
          ParentBackground = False
          ShowCaption = False
          TabOrder = 0
          object pnlP1Top: TPanel
            Left = 0
            Top = 0
            Width = 1280
            Height = 46
            Align = alTop
            BevelOuter = bvNone
            Color = 16383487
            ParentBackground = False
            ShowCaption = False
            TabOrder = 0
            object lblP1Ayuda: TLabel
              Left = 20
              Top = 14
              Width = 3
              Height = 15
              Caption = 'Documentos cuyo plazo en el archivo de gesti'#243'n ya venci'#243'. Elija las series y agr'#233'guelas.'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 5924725
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
            end
            object chkAnticipada: TcxCheckBox
              Left = 640
              Top = 10
              Properties.Caption = 'Mostrar tambi'#233'n las que a'#250'n no vencen'
              Properties.OnChange = chkAnticipadaPropertiesChange
              TabOrder = 1
              Width = 320
            end
            object pnlP1TopDer: TPanel
              Left = 1010
              Top = 0
              Width = 270
              Height = 46
              Align = alRight
              BevelOuter = bvNone
              Color = 16383487
              ParentBackground = False
              ShowCaption = False
              TabOrder = 0
              object btnAgregar: TcxButton
                Left = 10
                Top = 6
                Width = 240
                Height = 34
                Caption = 'Agregar a la transferencia'
                TabOrder = 0
                OnClick = btnAgregarClick
              end
            end
          end
          object pnlP1Rej: TPanel
            Left = 0
            Top = 46
            Width = 1280
            Height = 214
            Align = alClient
            BevelOuter = bvNone
            Color = 16383487
            ParentBackground = False
            ShowCaption = False
            Padding.Left = 16
            Padding.Right = 16
            TabOrder = 1
            object grdPropuesta: TcxGrid
              Left = 0
              Top = 0
              Width = 1248
              Height = 214
              Align = alClient
              BorderStyle = cxcbsNone
              TabOrder = 0
              LookAndFeel.Kind = lfUltraFlat
              LookAndFeel.NativeStyle = False
              object tvPropuesta: TcxGridTableView
                OnCustomDrawColumnHeader = tvCustomDrawColumnHeader
                OptionsData.Appending = False
                OptionsData.Deleting = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsSelection.CheckBoxVisibility = [cbvDataRow, cbvColumnHeader]
                OptionsSelection.MultiSelect = True
                OptionsCustomize.ColumnSorting = False
                OptionsSelection.CellSelect = False
                OptionsView.CellAutoHeight = True
                OptionsView.ColumnAutoWidth = True
                OptionsView.DataRowHeight = 34
                OptionsView.GridLineColor = 13031136
                OptionsView.GridLines = glHorizontal
                OptionsView.GroupByBox = False
                OptionsView.HeaderHeight = 30
                OptionsView.Indicator = False
                OptionsView.NoDataToDisplayInfoText = 'No hay documentos con el plazo vencido. Marque "Mostrar tambi'#233'n las que a'#250'n no vencen" para ver todos.'
                Styles.Background = stContenido
                Styles.Content = stContenido
                Styles.ContentEven = stContenido
                Styles.ContentOdd = stContenido
                Styles.Header = stCabeceraGrid
                Styles.Inactive = stSeleccion
                Styles.Selection = stSeleccion
                object colPropSerie: TcxGridColumn
                  Caption = 'Serie / subserie'
                  DataBinding.ValueType = 'String'
                  Width = 320
                end
                object colPropAnios: TcxGridColumn
                  Caption = 'Plazo'
                  DataBinding.ValueType = 'String'
                  Width = 70
                end
                object colPropUnidades: TcxGridColumn
                  Caption = 'Documentos'
                  DataBinding.ValueType = 'String'
                  Width = 90
                end
                object colPropFechas: TcxGridColumn
                  Caption = 'Fechas extremas'
                  DataBinding.ValueType = 'String'
                  Width = 150
                end
                object colPropObs: TcxGridColumn
                  Caption = 'Observaci'#243'n'
                  DataBinding.ValueType = 'String'
                  Width = 200
                end
              end
              object lvPropuesta: TcxGridLevel
                GridView = tvPropuesta
              end
            end
          end
        end
        object pnlP1Agreg: TPanel
          Left = 0
          Top = 260
          Width = 1280
          Height = 190
          Align = alClient
          BevelOuter = bvNone
          Color = 16383487
          ParentBackground = False
          ShowCaption = False
          TabOrder = 1
          object pnlP1AgregTop: TPanel
            Left = 0
            Top = 0
            Width = 1280
            Height = 44
            Align = alTop
            BevelOuter = bvNone
            Color = 16383487
            ParentBackground = False
            ShowCaption = False
            TabOrder = 0
            object lblP1Agregados: TLabel
              Left = 20
              Top = 16
              Width = 3
              Height = 15
              Caption = 'YA AGREGADO A LA TRANSFERENCIA'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 5924725
              Font.Height = -11
              Font.Name = 'Segoe UI Semibold'
              Font.Style = []
              ParentFont = False
            end
            object pnlP1AgregDer: TPanel
              Left = 1010
              Top = 0
              Width = 270
              Height = 44
              Align = alRight
              BevelOuter = bvNone
              Color = 16383487
              ParentBackground = False
              ShowCaption = False
              TabOrder = 0
              object btnQuitar: TcxButton
                Left = 10
                Top = 5
                Width = 240
                Height = 32
                Caption = 'Quitar la serie elegida'
                TabOrder = 0
                OnClick = btnQuitarClick
              end
            end
          end
          object pnlP1AgregRej: TPanel
            Left = 0
            Top = 44
            Width = 1280
            Height = 146
            Align = alClient
            BevelOuter = bvNone
            Color = 16383487
            ParentBackground = False
            ShowCaption = False
            Padding.Left = 16
            Padding.Right = 16
            Padding.Bottom = 8
            TabOrder = 1
            object grdAgregados: TcxGrid
              Left = 0
              Top = 0
              Width = 1248
              Height = 146
              Align = alClient
              BorderStyle = cxcbsNone
              TabOrder = 0
              LookAndFeel.Kind = lfUltraFlat
              LookAndFeel.NativeStyle = False
              object tvAgregados: TcxGridTableView
                OnCustomDrawColumnHeader = tvCustomDrawColumnHeader
                OptionsData.Appending = False
                OptionsData.Deleting = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsCustomize.ColumnSorting = False
                OptionsSelection.CellSelect = False
                OptionsView.CellAutoHeight = True
                OptionsView.ColumnAutoWidth = True
                OptionsView.DataRowHeight = 32
                OptionsView.GridLineColor = 13031136
                OptionsView.GridLines = glHorizontal
                OptionsView.GroupByBox = False
                OptionsView.HeaderHeight = 30
                OptionsView.Indicator = False
                OptionsView.NoDataToDisplayInfoText = 'Todav'#237'a no se agreg'#243' nada'
                Styles.Background = stContenido
                Styles.Content = stContenido
                Styles.ContentEven = stContenido
                Styles.ContentOdd = stContenido
                Styles.Header = stCabeceraGrid
                Styles.Inactive = stSeleccion
                Styles.Selection = stSeleccion
                object colAgrSerie: TcxGridColumn
                  Caption = 'Serie / subserie'
                  DataBinding.ValueType = 'String'
                  Width = 320
                end
                object colAgrUnidades: TcxGridColumn
                  Caption = 'Documentos'
                  DataBinding.ValueType = 'String'
                  Width = 90
                end
                object colAgrFechas: TcxGridColumn
                  Caption = 'Fechas extremas'
                  DataBinding.ValueType = 'String'
                  Width = 150
                end
              end
              object lvAgregados: TcxGridLevel
                GridView = tvAgregados
              end
            end
          end
        end
      end
      object pnlPaso2: TPanel
        Left = 0
        Top = 150
        Width = 1280
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        Visible = False
        object lblP2Ayuda: TLabel
          Left = 20
          Top = 16
          Width = 1240
          Height = 34
          Caption = 'La transferencia necesita la autorizaci'#243'n de la Comisi'#243'n Central de Valoraci'#243'n de la entidad. Registre el n'#250'mero de acta y de acuerdo.'
          AutoSize = False
          WordWrap = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblP2Organo: TLabel
          Left = 20
          Top = 64
          Width = 3
          Height = 15
          Caption = #211'RGANO'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -11
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object lblP2OrganoVal: TLabel
          Left = 20
          Top = 82
          Width = 3
          Height = 15
          Caption = 'Comisi'#243'n Central de Valoraci'#243'n'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblP2Acta: TLabel
          Left = 20
          Top = 118
          Width = 3
          Height = 15
          Caption = 'N.'#186' de acta'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object edtActa: TcxTextEdit
          Left = 20
          Top = 136
          TabOrder = 0
          Width = 200
        end
        object lblP2Acuerdo: TLabel
          Left = 240
          Top = 118
          Width = 3
          Height = 15
          Caption = 'N.'#186' de acuerdo'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object edtAcuerdo: TcxTextEdit
          Left = 240
          Top = 136
          TabOrder = 1
          Width = 200
        end
        object lblP2Fecha: TLabel
          Left = 460
          Top = 118
          Width = 3
          Height = 15
          Caption = 'Fecha de la autorizaci'#243'n'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object dteAutorizacion: TcxDateEdit
          Left = 460
          Top = 136
          TabOrder = 2
          Width = 180
        end
        object btnRegistrarAut: TcxButton
          Left = 20
          Top = 184
          Width = 230
          Height = 36
          Caption = 'Registrar autorizaci'#243'n'
          TabOrder = 3
          OnClick = btnRegistrarAutClick
        end
        object lblAutError: TLabel
          Left = 20
          Top = 234
          Width = 1240
          Height = 20
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1975987
          Font.Height = -12
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object lblAutRegistrada: TLabel
          Left = 20
          Top = 262
          Width = 1240
          Height = 20
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5209391
          Font.Height = -12
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlPaso3: TPanel
        Left = 0
        Top = 150
        Width = 1280
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        Visible = False
        object pnlP3Der: TPanel
          Left = 840
          Top = 0
          Width = 440
          Height = 450
          Align = alRight
          BevelOuter = bvNone
          Color = 14806258
          ParentBackground = False
          ShowCaption = False
          TabOrder = 1
          object lblVerTit: TLabel
            Left = 16
            Top = 14
            Width = 3
            Height = 15
            Caption = 'VERIFICACIONES ANTES DE ENTREGAR'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -11
            Font.Name = 'Segoe UI Semibold'
            Font.Style = []
            ParentFont = False
          end
          object chkVer1: TCheckBox
            Left = 16
            Top = 40
            Width = 408
            Height = 40
            Caption = 'Son ejemplares '#250'nicos, no copias'
            Tag = 0
            TabOrder = 0
            WordWrap = True
            OnClick = chkVerClick
          end
          object chkVer2: TCheckBox
            Left = 16
            Top = 86
            Width = 408
            Height = 40
            Caption = 'Los expedientes est'#225'n completos y en buen estado, sin presillas ni clips'
            Tag = 1
            TabOrder = 0
            WordWrap = True
            OnClick = chkVerClick
          end
          object chkVer3: TCheckBox
            Left = 16
            Top = 132
            Width = 408
            Height = 40
            Caption = 'Ning'#250'n expediente queda dividido en cajas distintas'
            Tag = 2
            TabOrder = 0
            WordWrap = True
            OnClick = chkVerClick
          end
          object chkVer4: TCheckBox
            Left = 16
            Top = 178
            Width = 408
            Height = 40
            Caption = 'El listado de documentos est'#225' pegado en el exterior de cada caja'
            Tag = 3
            TabOrder = 0
            WordWrap = True
            OnClick = chkVerClick
          end
          object chkVer5: TCheckBox
            Left = 16
            Top = 224
            Width = 408
            Height = 40
            Caption = 'No hay documentos de la transferencia en pr'#233'stamo'
            Tag = 4
            TabOrder = 0
            WordWrap = True
            OnClick = chkVerClick
          end
          object lblP3Falta: TLabel
            Left = 16
            Top = 282
            Width = 408
            Height = 140
            AutoSize = False
            WordWrap = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 1975987
            Font.Height = -12
            Font.Name = 'Segoe UI Semibold'
            Font.Style = []
            ParentFont = False
          end
        end
        object pnlP3Izq: TPanel
          Left = 0
          Top = 0
          Width = 840
          Height = 450
          Align = alClient
          BevelOuter = bvNone
          Color = 16383487
          ParentBackground = False
          ShowCaption = False
          TabOrder = 0
          object pnlP3Barra: TPanel
            Left = 0
            Top = 0
            Width = 840
            Height = 54
            Align = alTop
            BevelOuter = bvNone
            Color = 16383487
            ParentBackground = False
            ShowCaption = False
            TabOrder = 0
            object lblCap: TLabel
              Left = 20
              Top = 20
              Width = 3
              Height = 15
              Caption = 'Documentos por caja'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 5924725
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
            end
            object spnCapacidad: TcxSpinEdit
              Left = 150
              Top = 16
              Properties.MaxValue = 500.000000000000000000
              Properties.MinValue = 1.000000000000000000
              TabOrder = 0
              Value = 20
              Width = 80
            end
            object btnNumerar: TcxButton
              Left = 246
              Top = 12
              Width = 180
              Height = 34
              Caption = 'Numerar las cajas'
              TabOrder = 1
              OnClick = btnNumerarClick
            end
          end
          object pnlP3Rej: TPanel
            Left = 0
            Top = 54
            Width = 840
            Height = 396
            Align = alClient
            BevelOuter = bvNone
            Color = 16383487
            ParentBackground = False
            ShowCaption = False
            Padding.Left = 16
            Padding.Right = 16
            Padding.Bottom = 16
            TabOrder = 1
            object grdCajas: TcxGrid
              Left = 0
              Top = 0
              Width = 808
              Height = 380
              Align = alClient
              BorderStyle = cxcbsNone
              TabOrder = 0
              LookAndFeel.Kind = lfUltraFlat
              LookAndFeel.NativeStyle = False
              object tvCajas: TcxGridTableView
                OnCustomDrawColumnHeader = tvCustomDrawColumnHeader
                OptionsData.Appending = False
                OptionsData.Deleting = False
                OptionsData.Editing = False
                OptionsData.Inserting = False
                OptionsCustomize.ColumnSorting = False
                OptionsSelection.CellSelect = False
                OptionsView.CellAutoHeight = True
                OptionsView.ColumnAutoWidth = True
                OptionsView.DataRowHeight = 32
                OptionsView.GridLineColor = 13031136
                OptionsView.GridLines = glHorizontal
                OptionsView.GroupByBox = False
                OptionsView.HeaderHeight = 30
                OptionsView.Indicator = False
                OptionsView.NoDataToDisplayInfoText = 'Todav'#237'a no hay cajas: n'#250'merelas'
                Styles.Background = stContenido
                Styles.Content = stContenido
                Styles.ContentEven = stContenido
                Styles.ContentOdd = stContenido
                Styles.Header = stCabeceraGrid
                Styles.Inactive = stSeleccion
                Styles.Selection = stSeleccion
                object colCajaNum: TcxGridColumn
                  Caption = 'Caja'
                  DataBinding.ValueType = 'String'
                  Width = 60
                end
                object colCajaTipo: TcxGridColumn
                  Caption = 'Tipo documental'
                  DataBinding.ValueType = 'String'
                  Width = 180
                end
                object colCajaDesc: TcxGridColumn
                  Caption = 'Descripci'#243'n'
                  DataBinding.ValueType = 'String'
                  Width = 260
                end
                object colCajaFechas: TcxGridColumn
                  Caption = 'Fechas extremas'
                  DataBinding.ValueType = 'String'
                  Width = 150
                end
                object colCajaUnid: TcxGridColumn
                  Caption = 'Docs.'
                  DataBinding.ValueType = 'String'
                  Width = 60
                end
              end
              object lvCajas: TcxGridLevel
                GridView = tvCajas
              end
            end
          end
        end
      end
      object pnlPaso4: TPanel
        Left = 0
        Top = 150
        Width = 1280
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        Visible = False
        object lblP4Ayuda: TLabel
          Left = 20
          Top = 16
          Width = 1240
          Height = 34
          Caption = 'Imprima la relaci'#243'n de entrega y las etiquetas de caja, entregue las cajas y registre la entrega. La firman quien entrega y quien recibe.'
          AutoSize = False
          WordWrap = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblEntFecha: TLabel
          Left = 20
          Top = 64
          Width = 3
          Height = 15
          Caption = 'Fecha de la entrega'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object dteEntrega: TcxDateEdit
          Left = 20
          Top = 82
          TabOrder = 0
          Width = 180
        end
        object lblEntPor: TLabel
          Left = 230
          Top = 64
          Width = 3
          Height = 15
          Caption = 'Entrega (nombre de quien entrega)'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object edtEntregadoPor: TcxTextEdit
          Left = 230
          Top = 82
          TabOrder = 1
          Width = 280
        end
        object btnRegistrarEntrega: TcxButton
          Left = 20
          Top = 130
          Width = 230
          Height = 38
          Caption = 'Registrar la entrega'
          TabOrder = 2
          OnClick = btnRegistrarEntregaClick
        end
        object btnRelacion: TcxButton
          Left = 20
          Top = 196
          Width = 230
          Height = 36
          Caption = 'Imprimir relaci'#243'n de entrega'
          TabOrder = 3
          OnClick = btnRelacionClick
        end
        object btnEtiquetas: TcxButton
          Left = 264
          Top = 196
          Width = 230
          Height = 36
          Caption = 'Imprimir etiquetas de caja'
          TabOrder = 4
          OnClick = btnEtiquetasClick
        end
        object lblEntInfo: TLabel
          Left = 20
          Top = 252
          Width = 1240
          Height = 40
          AutoSize = False
          WordWrap = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlPaso5: TPanel
        Left = 0
        Top = 150
        Width = 1280
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        Visible = False
        object lblP5: TLabel
          Left = 20
          Top = 20
          Width = 1240
          Height = 60
          AutoSize = False
          WordWrap = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object btnRelacion5: TcxButton
          Left = 20
          Top = 96
          Width = 230
          Height = 36
          Caption = 'Imprimir relaci'#243'n de entrega'
          TabOrder = 1
          OnClick = btnRelacionClick
        end
        object btnEtiquetas5: TcxButton
          Left = 264
          Top = 96
          Width = 230
          Height = 36
          Caption = 'Imprimir etiquetas de caja'
          TabOrder = 2
          OnClick = btnEtiquetasClick
        end
      end
    end
  end
  object strEstilos: TcxStyleRepository
    Left = 40
    Top = 620
    PixelsPerInch = 96
    object stContenido: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 16383487
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 1581355
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      TextColor = 1581355
    end
    object stContenidoPeq: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 16383487
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 1581355
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      TextColor = 1581355
    end
    object stCabeceraGrid: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 14806258
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5924725
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      TextColor = 5924725
    end
    object stSeleccion: TcxStyle
      AssignedValues = [svColor, svFont, svTextColor]
      Color = 14214909
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 1581355
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      TextColor = 1581355
    end
  end
end
