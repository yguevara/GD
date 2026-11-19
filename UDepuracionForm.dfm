object frmDepuracionNueva: TfrmDepuracionNueva
  Left = 0
  Top = 0
  Caption = 'Depuraci'#243'n'
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
        Caption = 'Depuraci'#243'n'
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
          Caption = 'Trabajar en el nodo'
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
          Caption = 'Nueva depuraci'#243'n'
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
    object pnlTabla: TPanel
      Left = 0
      Top = 66
      Width = 1280
      Height = 654
      Align = alClient
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      Padding.Left = 16
      Padding.Right = 16
      Padding.Bottom = 16
      TabOrder = 2
      object grdDepuraciones: TcxGrid
        Left = 16
        Top = 0
        Width = 1248
        Height = 422
        Align = alClient
        BorderStyle = cxcbsNone
        TabOrder = 0
        LookAndFeel.Kind = lfUltraFlat
        LookAndFeel.NativeStyle = False
        object tvDepuraciones: TcxGridTableView
          OnCustomDrawColumnHeader = tvCustomDrawColumnHeader
          OnCellDblClick = tvDepuracionesCellDblClick
          OnFocusedRecordChanged = tvDepuracionesFocusedRecordChanged
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
          OptionsView.NoDataToDisplayInfoText = 'No hay depuraciones este a'#241'o'
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
          object colSeries: TcxGridColumn
            Caption = 'Series'
            DataBinding.ValueType = 'String'
            Width = 260
          end
          object colUnidades: TcxGridColumn
            Caption = 'Unidades'
            DataBinding.ValueType = 'String'
            Width = 90
          end
          object colFechas: TcxGridColumn
            Caption = 'Fechas extremas'
            DataBinding.ValueType = 'String'
            Width = 150
          end
          object colAutorizacion: TcxGridColumn
            Caption = 'Autorizaci'#243'n'
            DataBinding.ValueType = 'String'
            Width = 260
          end
          object colPaso: TcxGridColumn
            Caption = 'Paso'
            DataBinding.ValueType = 'String'
            Width = 70
          end
          object colEstado: TcxGridColumn
            Caption = 'Estado'
            DataBinding.ValueType = 'String'
            Width = 150
          end
        end
        object lvDepuraciones: TcxGridLevel
          GridView = tvDepuraciones
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
      object btnCancelarDep: TcxButton
        Left = 20
        Top = 13
        Width = 190
        Height = 36
        Caption = 'Cancelar depuraci'#243'n'
        TabOrder = 1
        OnClick = btnCancelarDepClick
      end
      object btnEliminarDep: TcxButton
        Left = 224
        Top = 13
        Width = 190
        Height = 36
        Caption = 'Eliminar depuraci'#243'n'
        TabOrder = 2
        OnClick = btnEliminarDepClick
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
        Top = 0
        Width = 1280
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        Visible = False
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
              Caption = 'Series cuyo plazo en el archivo central ya venci'#243' y su destino final es eliminarlas. Elija las series y agr'#233'guelas.'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = 5924725
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              ParentFont = False
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
                Caption = 'Agregar a la depuraci'#243'n'
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
                  Caption = 'Plazo central'
                  DataBinding.ValueType = 'String'
                  Width = 70
                end
                object colPropUnidades: TcxGridColumn
                  Caption = 'Unidades'
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
              Caption = 'YA AGREGADO A LA DEPURACI'#211'N'
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
                  Caption = 'Unidades'
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
        Top = 0
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
          Caption = 'La depuraci'#243'n necesita la autorizaci'#243'n de la Comisi'#243'n de Valoraci'#243'n Documental. Elija el '#243'rgano y registre el n'#250'mero de acta y de acuerdo.'
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
        object cboOrgano: TcxComboBox
          Left = 20
          Top = 82
          Properties.DropDownListStyle = lsFixedList
          Properties.Items.Strings = (
            'Comisi'#243'n Nacional'
            'Comisi'#243'n Provincial'
            'Comisi'#243'n Municipal')
          TabOrder = 4
          Width = 300
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
        Top = 0
        Width = 1280
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 2
        Visible = False
        object sbActa: TScrollBox
          Left = 0
          Top = 0
          Width = 1280
          Height = 450
          Align = alClient
          BorderStyle = bsNone
          Color = 16383487
          TabOrder = 0
          object lblA3AutT: TLabel
            Left = 20
            Top = 8
            Width = 3
            Height = 15
            Caption = 'AUTORIZACI'#211'N'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -11
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object lblA3Aut: TLabel
            Left = 20
            Top = 26
            Width = 700
            Height = 15
            Caption = ''
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 1581355
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object lblA3QueT: TLabel
            Left = 20
            Top = 66
            Width = 3
            Height = 15
            Caption = 'QU'#201' SE ELIMINA'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -11
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object grdLineas: TcxGrid
            Left = 20
            Top = 86
            Width = 740
            Height = 150
            BorderStyle = cxcbsNone
            TabOrder = 0
            LookAndFeel.Kind = lfUltraFlat
            LookAndFeel.NativeStyle = False
            object tvLineas: TcxGridTableView
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
              OptionsView.NoDataToDisplayInfoText = 'Sin documentos agregados'
              Styles.Background = stContenido
              Styles.Content = stContenido
              Styles.ContentEven = stContenido
              Styles.ContentOdd = stContenido
              Styles.Header = stCabeceraGrid
              Styles.Inactive = stSeleccion
              Styles.Selection = stSeleccion
              object colLinSerie: TcxGridColumn
                Caption = 'Serie / subserie'
                DataBinding.ValueType = 'String'
                Width = 300
              end
              object colLinUnidades: TcxGridColumn
                Caption = 'Unidades'
                DataBinding.ValueType = 'String'
                Width = 260
              end
              object colLinFechas: TcxGridColumn
                Caption = 'Fechas extremas'
                DataBinding.ValueType = 'String'
                Width = 140
              end
            end
            object lvLineas: TcxGridLevel
              GridView = tvLineas
            end
          end
          object grdDesglose: TcxGrid
            Left = 790
            Top = 86
            Width = 300
            Height = 150
            BorderStyle = cxcbsNone
            TabOrder = 0
            LookAndFeel.Kind = lfUltraFlat
            LookAndFeel.NativeStyle = False
            object tvDesglose: TcxGridTableView
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
              OptionsView.NoDataToDisplayInfoText = 'Sin datos'
              Styles.Background = stContenido
              Styles.Content = stContenido
              Styles.ContentEven = stContenido
              Styles.ContentOdd = stContenido
              Styles.Header = stCabeceraGrid
              Styles.Inactive = stSeleccion
              Styles.Selection = stSeleccion
              object colDesAnio: TcxGridColumn
                Caption = 'A'#241'o'
                DataBinding.ValueType = 'String'
                Width = 100
              end
              object colDesUnidades: TcxGridColumn
                Caption = 'Unidades'
                DataBinding.ValueType = 'String'
                Width = 120
              end
            end
            object lvDesglose: TcxGridLevel
              GridView = tvDesglose
            end
          end
          object lblA3MuestraT: TLabel
            Left = 20
            Top = 254
            Width = 3
            Height = 15
            Caption = 'MUESTRA QUE SE CONSERVA (OBLIGATORIA)'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -11
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object lblMDescT: TLabel
            Left = 20
            Top = 276
            Width = 3
            Height = 15
            Caption = 'Descripci'#243'n de la muestra'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object edtMuestraDesc: TcxTextEdit
            Left = 20
            Top = 294
            TabOrder = 0
            Width = 540
          end
          object lblMDondeT: TLabel
            Left = 580
            Top = 276
            Width = 3
            Height = 15
            Caption = 'D'#243'nde se conserva'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object edtMuestraDonde: TcxTextEdit
            Left = 580
            Top = 294
            TabOrder = 1
            Width = 400
          end
          object lblA3EjecT: TLabel
            Left = 20
            Top = 334
            Width = 3
            Height = 15
            Caption = 'EJECUCI'#211'N'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -11
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object lblLugarT: TLabel
            Left = 20
            Top = 356
            Width = 3
            Height = 15
            Caption = 'Lugar'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object edtLugar: TcxTextEdit
            Left = 20
            Top = 374
            TabOrder = 2
            Width = 400
          end
          object lblViaT: TLabel
            Left = 440
            Top = 356
            Width = 3
            Height = 15
            Caption = 'V'#237'a de eliminaci'#243'n'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object cboVia: TcxComboBox
            Left = 440
            Top = 374
            Properties.DropDownListStyle = lsFixedList
            Properties.Items.Strings = (
              'Incineraci'#243'n'
              'Trituraci'#243'n')
            TabOrder = 3
            Width = 200
          end
          object lblFPrevT: TLabel
            Left = 660
            Top = 356
            Width = 3
            Height = 15
            Caption = 'Fecha prevista'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object dteFPrevista: TcxDateEdit
            Left = 660
            Top = 374
            TabOrder = 4
            Width = 160
          end
          object btnGuardarActa: TcxButton
            Left = 20
            Top = 420
            Width = 148
            Height = 36
            Caption = 'Guardar acta'
            TabOrder = 5
            OnClick = btnGuardarActaClick
          end
          object btnImprimirActa: TcxButton
            Left = 170
            Top = 420
            Width = 156
            Height = 36
            Caption = 'Imprimir acta'
            TabOrder = 6
            Visible = False
            OnClick = btnImprimirActaClick
          end
          object lblA3TestT: TLabel
            Left = 20
            Top = 480
            Width = 3
            Height = 15
            Caption = 'TESTIGOS Y FIRMAS'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -11
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object grdTestigos: TcxGrid
            Left = 20
            Top = 500
            Width = 740
            Height = 130
            BorderStyle = cxcbsNone
            TabOrder = 0
            LookAndFeel.Kind = lfUltraFlat
            LookAndFeel.NativeStyle = False
            object tvTestigos: TcxGridTableView
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
              OptionsView.NoDataToDisplayInfoText = 'Todav'#237'a no hay testigos'
              Styles.Background = stContenido
              Styles.Content = stContenido
              Styles.ContentEven = stContenido
              Styles.ContentOdd = stContenido
              Styles.Header = stCabeceraGrid
              Styles.Inactive = stSeleccion
              Styles.Selection = stSeleccion
              object colTesNombre: TcxGridColumn
                Caption = 'Nombre'
                DataBinding.ValueType = 'String'
                Width = 240
              end
              object colTesCargo: TcxGridColumn
                Caption = 'Cargo'
                DataBinding.ValueType = 'String'
                Width = 200
              end
              object colTesOrigen: TcxGridColumn
                Caption = 'Origen'
                DataBinding.ValueType = 'String'
                Width = 160
              end
              object colTesFirmo: TcxGridColumn
                Caption = 'Firm'#243''
                DataBinding.ValueType = 'String'
                Width = 70
              end
            end
            object lvTestigos: TcxGridLevel
              GridView = tvTestigos
            end
          end
          object btnQuitarTestigo: TcxButton
            Left = 790
            Top = 500
            Width = 164
            Height = 32
            Caption = 'Quitar testigo'
            TabOrder = 7
            OnClick = btnQuitarTestigoClick
          end
          object btnMarcarFirma: TcxButton
            Left = 790
            Top = 540
            Width = 244
            Height = 32
            Caption = 'Marcar o desmarcar firma'
            TabOrder = 8
            OnClick = btnMarcarFirmaClick
          end
          object lblTNombreT: TLabel
            Left = 20
            Top = 642
            Width = 3
            Height = 15
            Caption = 'Nombre'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object edtTNombre: TcxTextEdit
            Left = 20
            Top = 660
            TabOrder = 9
            Width = 240
          end
          object lblTCargoT: TLabel
            Left = 280
            Top = 642
            Width = 3
            Height = 15
            Caption = 'Cargo'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object edtTCargo: TcxTextEdit
            Left = 280
            Top = 660
            TabOrder = 10
            Width = 200
          end
          object lblTOrigenT: TLabel
            Left = 500
            Top = 642
            Width = 3
            Height = 15
            Caption = 'Origen'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object cboTOrigen: TcxComboBox
            Left = 500
            Top = 660
            Properties.DropDownListStyle = lsFixedList
            Properties.Items.Strings = (
              'Comisi'#243'n de Valoraci'#243'n'
              'Archivo de gesti'#243'n'
              'Otro')
            TabOrder = 11
            Width = 240
          end
          object btnAgregarTestigo: TcxButton
            Left = 760
            Top = 656
            Width = 172
            Height = 34
            Caption = 'Agregar testigo'
            TabOrder = 12
            OnClick = btnAgregarTestigoClick
          end
          object lblA3Req: TLabel
            Left = 20
            Top = 712
            Width = 3
            Height = 15
            Caption = 'Para pasar a Ejecuci'#243'n hace falta: autorizaci'#243'n cargada, muestra definida y al menos 2 testigos, uno de la Comisi'#243'n y uno de un archivo de gesti'#243'n.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 5924725
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
          end
          object lblA3Falta: TLabel
            Left = 20
            Top = 736
            Width = 1000
            Height = 15
            Caption = ''
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 1581355
            Font.Height = -12
            Font.Name = 'Segoe UI Semibold'
            Font.Style = []
            ParentFont = False
          end
        end
      end
      object pnlPaso4: TPanel
        Left = 0
        Top = 0
        Width = 1280
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 3
        Visible = False
        object lblE4Titulo: TLabel
          Left = 20
          Top = 14
          Width = 3
          Height = 15
          Caption = 'SE MARCAR'#193'N COMO ELIMINADOS'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblE4Resumen: TLabel
          Left = 20
          Top = 34
          Width = 1200
          Height = 40
          Caption = ''
        AutoSize = False
        WordWrap = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -14
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object lblE4ChkT: TLabel
          Left = 20
          Top = 90
          Width = 3
          Height = 15
          Caption = 'COMPROBACIONES ANTES DE EJECUTAR'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblChk1: TLabel
          Left = 20
          Top = 112
          Width = 1200
          Height = 20
          Caption = ''
        AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblChk2: TLabel
          Left = 20
          Top = 138
          Width = 1200
          Height = 20
          Caption = ''
        AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblChk3: TLabel
          Left = 20
          Top = 164
          Width = 1200
          Height = 20
          Caption = ''
        AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblChk4: TLabel
          Left = 20
          Top = 190
          Width = 1200
          Height = 20
          Caption = ''
        AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblE4Advert: TLabel
          Left = 20
          Top = 236
          Width = 700
          Height = 20
          Caption = 'Esta acci'#243'n no se puede deshacer. Escriba ELIMINAR para confirmar.'
        AutoSize = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -13
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object edtConfirmacion: TcxTextEdit
          Left = 20
          Top = 264
          Properties.OnChange = edtConfirmacionPropertiesChange
          TabOrder = 0
          Width = 240
        end
        object btnEjecutar: TcxButton
          Left = 280
          Top = 258
          Width = 256
          Height = 36
          Caption = 'Ejecutar eliminaci'#243'n'
          TabOrder = 1
          Enabled = False
          OnClick = btnEjecutarClick
        end
      end
      object pnlPaso5: TPanel
        Left = 0
        Top = 0
        Width = 1280
        Height = 450
        Align = alClient
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 4
        Visible = False
        object lblE5Texto: TLabel
          Left = 20
          Top = 20
          Width = 1200
          Height = 60
          Caption = ''
        AutoSize = False
        WordWrap = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 1581355
          Font.Height = -14
          Font.Name = 'Segoe UI Semibold'
          Font.Style = []
          ParentFont = False
        end
        object lblE5Ayuda: TLabel
          Left = 20
          Top = 92
          Width = 1200
          Height = 40
          Caption = ''
        AutoSize = False
        WordWrap = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5924725
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object btnImprimirActa5: TcxButton
          Left = 20
          Top = 140
          Width = 160
          Height = 36
          Caption = 'Imprimir acta'
          TabOrder = 0
          Visible = False
          OnClick = btnImprimirActaClick
        end
        object btnCerrarDep: TcxButton
          Left = 200
          Top = 140
          Width = 256
          Height = 36
          Caption = 'Cerrar la depuraci'#243'n'
          TabOrder = 1
          OnClick = btnCerrarDepClick
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
