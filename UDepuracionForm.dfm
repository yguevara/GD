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
        end
      end
      object btnCancelarDep: TcxButton
        Left = 20
        Top = 13
        Width = 190
        Height = 36
        Caption = 'Cancelar depuraci'#243'n'
        TabOrder = 1
      end
      object btnEliminarDep: TcxButton
        Left = 224
        Top = 13
        Width = 190
        Height = 36
        Caption = 'Eliminar depuraci'#243'n'
        TabOrder = 2
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
        object lblP1: TLabel
          Left = 20
          Top = 16
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
        TabOrder = 1
        Visible = False
        object lblP2: TLabel
          Left = 20
          Top = 16
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
        object lblP3: TLabel
          Left = 20
          Top = 16
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
        object lblP4: TLabel
          Left = 20
          Top = 16
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
        object lblP5: TLabel
          Left = 20
          Top = 16
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
