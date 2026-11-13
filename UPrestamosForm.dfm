object frmPrestamos: TfrmPrestamos
  Left = 0
  Top = 0
  Caption = 'Pr'#233'stamos'
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
  object pnlLateral: TPanel
    Left = 840
    Top = 0
    Width = 440
    Height = 720
    Align = alRight
    BevelOuter = bvNone
    Color = 16383487
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    Visible = False
    object pnlLateralLinea: TPanel
      Left = 0
      Top = 0
      Width = 1
      Height = 720
      Align = alLeft
      BevelOuter = bvNone
      Color = 13031136
      ParentBackground = False
      ShowCaption = False
      TabOrder = 0
    end
    object pnlLateralTitulo: TPanel
      Left = 1
      Top = 0
      Width = 439
      Height = 52
      Align = alTop
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 1
      object lblLateralTitulo: TLabel
        Left = 18
        Top = 16
        Width = 110
        Height = 20
        Caption = 'Pr'#233'stamo'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1581355
        Font.Height = -15
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object lblCerrarLateral: TLabel
        Left = 395
        Top = 12
        Width = 44
        Height = 28
        Alignment = taCenter
        AutoSize = False
        Caption = #10005
        Cursor = crHandPoint
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -15
        Font.Name = 'Segoe UI Symbol'
        Font.Style = []
        ParentFont = False
        Layout = tlCenter
        OnClick = lblCerrarLateralClick
      end
    end
    object pnlFicha: TPanel
      Left = 1
      Top = 52
      Width = 439
      Height = 668
      Align = alClient
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 2
      object lblFichaEstado: TLabel
        Left = 18
        Top = 4
        Width = 3
        Height = 17
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 803266
        Font.Height = -13
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object lblSecSolicitante: TLabel
        Left = 18
        Top = 28
        Width = 76
        Height = 13
        Caption = 'SOLICITANTE'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -11
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object lblFichaSolicitante: TLabel
        Left = 18
        Top = 44
        Width = 3
        Height = 17
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1581355
        Font.Height = -14
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object lblFichaDetalle: TLabel
        Left = 18
        Top = 64
        Width = 3
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblSecFechas: TLabel
        Left = 18
        Top = 90
        Width = 44
        Height = 13
        Caption = 'FECHAS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -11
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object lblFichaEntregaTit: TLabel
        Left = 18
        Top = 106
        Width = 40
        Height = 15
        Caption = 'Entrega'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblFichaEntrega: TLabel
        Left = 18
        Top = 120
        Width = 3
        Height = 17
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1581355
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblFichaLimiteTit: TLabel
        Left = 230
        Top = 106
        Width = 100
        Height = 15
        Caption = 'Devolver antes del'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblFichaLimite: TLabel
        Left = 230
        Top = 120
        Width = 3
        Height = 17
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1581355
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblFichaAtendido: TLabel
        Left = 18
        Top = 142
        Width = 3
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblSecDocs: TLabel
        Left = 18
        Top = 166
        Width = 82
        Height = 13
        Caption = 'DOCUMENTOS'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -11
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
      object grdFichaDocs: TcxGrid
        Left = 18
        Top = 182
        Width = 403
        Height = 100
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = cxcbsNone
        TabOrder = 0
        LookAndFeel.Kind = lfUltraFlat
        LookAndFeel.NativeStyle = False
        object tvFichaDocs: TcxGridTableView
          OnCustomDrawColumnHeader = tvCustomDrawColumnHeader
          OptionsData.Appending = False
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.DataRowHeight = 30
          OptionsView.GridLineColor = 13031136
          OptionsView.GridLines = glHorizontal
          OptionsView.GroupByBox = False
          OptionsView.HeaderHeight = 28
          OptionsView.Indicator = False
          OptionsView.NoDataToDisplayInfoText = 'Sin documentos'
          Styles.Background = stContenidoPeq
          Styles.Content = stContenidoPeq
          Styles.ContentEven = stContenidoPeq
          Styles.ContentOdd = stContenidoPeq
          Styles.Header = stCabeceraGrid
          Styles.Inactive = stSeleccion
          Styles.Selection = stSeleccion
          object colFichaCodigo: TcxGridColumn
            Caption = 'C'#243'digo'
            DataBinding.ValueType = 'String'
            Width = 70
          end
          object colFichaTitulo: TcxGridColumn
            Caption = 'T'#237'tulo'
            DataBinding.ValueType = 'String'
            Width = 150
          end
          object colFichaUbicacion: TcxGridColumn
            Caption = 'Ubicaci'#243'n'
            DataBinding.ValueType = 'String'
            Width = 150
          end
        end
        object lvFichaDocs: TcxGridLevel
          GridView = tvFichaDocs
        end
      end
      object lblFichaAccionTit: TLabel
        Left = 18
        Top = 292
        Width = 3
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object dteFichaLimite: TcxDateEdit
        Left = 18
        Top = 310
        TabOrder = 1
        Width = 180
      end
      object chkCompleto: TCheckBox
        Left = 18
        Top = 340
        Width = 190
        Height = 21
        Caption = 'Devuelto completo'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object edtObservacion: TcxTextEdit
        Left = 18
        Top = 366
        TabOrder = 3
        TextHint = 'Observaciones de la devoluci'#243'n'
        Width = 403
      end
      object pnlFichaAcciones: TPanel
        Left = 0
        Top = 556
        Width = 439
        Height = 112
        Align = alBottom
        BevelOuter = bvNone
        Color = 14806258
        ParentBackground = False
        ShowCaption = False
        TabOrder = 4
        object btnEntrega: TcxButton
          Left = 16
          Top = 10
          Width = 190
          Height = 36
          Caption = 'Registrar entrega'
          TabOrder = 0
          OnClick = btnEntregaClick
        end
        object btnDevolucion: TcxButton
          Left = 16
          Top = 10
          Width = 190
          Height = 36
          Caption = 'Registrar devoluci'#243'n'
          TabOrder = 1
          OnClick = btnDevolucionClick
        end
        object btnRenovar: TcxButton
          Left = 218
          Top = 10
          Width = 205
          Height = 36
          Caption = 'Renovar plazo'
          TabOrder = 2
          OnClick = btnRenovarClick
        end
        object btnImprimir: TcxButton
          Left = 16
          Top = 58
          Width = 190
          Height = 36
          Caption = 'Imprimir solicitud'
          TabOrder = 3
          OnClick = btnImprimirClick
        end
        object btnCancelarPrestamo: TcxButton
          Left = 218
          Top = 58
          Width = 205
          Height = 36
          Caption = 'Cancelar pr'#233'stamo'
          TabOrder = 4
          OnClick = btnCancelarPrestamoClick
        end
      end
    end
    object pnlNuevo: TScrollBox
      Left = 1
      Top = 52
      Width = 439
      Height = 668
      Align = alClient
      BorderStyle = bsNone
      Color = 16383487
      TabOrder = 3
      Visible = False
      object lblNuevoTipo: TLabel
        Left = 18
        Top = 8
        Width = 85
        Height = 15
        Caption = 'Tipo de usuario'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object cboTipoUsuario: TcxComboBox
        Left = 18
        Top = 26
        Properties.DropDownListStyle = lsFixedList
        Properties.Items.Strings = (
          'Interno'
          'Externo')
        Properties.OnChange = cboTipoUsuarioPropertiesChange
        TabOrder = 0
        Text = 'Interno'
        Width = 190
      end
      object lblNuevoLimite: TLabel
        Left = 230
        Top = 8
        Width = 100
        Height = 15
        Caption = 'Devolver antes del'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object dteNuevoLimite: TcxDateEdit
        Left = 230
        Top = 26
        TabOrder = 1
        Width = 191
      end
      object lblNuevoSolicitante: TLabel
        Left = 18
        Top = 56
        Width = 59
        Height = 15
        Caption = 'Solicitante'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtSolicitante: TcxTextEdit
        Left = 18
        Top = 72
        TabOrder = 2
        Width = 403
      end
      object lblNuevoCarnet: TLabel
        Left = 18
        Top = 102
        Width = 105
        Height = 15
        Caption = 'Carnet de identidad'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtCarnet: TcxTextEdit
        Left = 18
        Top = 118
        Properties.MaxLength = 11
        TabOrder = 3
        Width = 190
      end
      object lblNuevoEntidad: TLabel
        Left = 230
        Top = 102
        Width = 40
        Height = 15
        Caption = 'Entidad'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtEntidad: TcxTextEdit
        Left = 230
        Top = 118
        TabOrder = 4
        Width = 191
      end
      object lblNuevoBuscar: TLabel
        Left = 18
        Top = 150
        Width = 111
        Height = 15
        Caption = 'Documentos a prestar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object edtBuscarDoc: TcxTextEdit
        Left = 18
        Top = 168
        Properties.OnChange = edtBuscarDocPropertiesChange
        TabOrder = 5
        TextHint = 'C'#243'digo o t'#237'tulo del documento...'
        Width = 403
      end
      object grdBuscarDoc: TcxGrid
        Left = 18
        Top = 198
        Width = 403
        Height = 120
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = cxcbsNone
        TabOrder = 6
        LookAndFeel.Kind = lfUltraFlat
        LookAndFeel.NativeStyle = False
        object tvBuscarDoc: TcxGridTableView
          OnCustomDrawColumnHeader = tvCustomDrawColumnHeader
          OnCellDblClick = tvBuscarDocCellDblClick
          OptionsData.Appending = False
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.DataRowHeight = 30
          OptionsView.GridLineColor = 13031136
          OptionsView.GridLines = glHorizontal
          OptionsView.GroupByBox = False
          OptionsView.HeaderHeight = 28
          OptionsView.Indicator = False
          OptionsView.NoDataToDisplayInfoText = 'Sin resultados'
          Styles.Background = stContenidoPeq
          Styles.Content = stContenidoPeq
          Styles.ContentEven = stContenidoPeq
          Styles.ContentOdd = stContenidoPeq
          Styles.Header = stCabeceraGrid
          Styles.Inactive = stSeleccion
          Styles.Selection = stSeleccion
          object colBuscarCodigo: TcxGridColumn
            Caption = 'C'#243'digo'
            DataBinding.ValueType = 'String'
            Width = 70
          end
          object colBuscarTitulo: TcxGridColumn
            Caption = 'T'#237'tulo'
            DataBinding.ValueType = 'String'
            Width = 120
          end
          object colBuscarUbicacion: TcxGridColumn
            Caption = 'Ubicaci'#243'n'
            DataBinding.ValueType = 'String'
            Width = 110
          end
          object colBuscarEstado: TcxGridColumn
            Caption = 'Estado'
            DataBinding.ValueType = 'String'
            Width = 100
          end
        end
        object lvBuscarDoc: TcxGridLevel
          GridView = tvBuscarDoc
        end
      end
      object btnAgregarDoc: TcxButton
        Left = 18
        Top = 322
        Width = 120
        Height = 28
        Caption = 'Agregar'
        TabOrder = 7
        OnClick = btnAgregarDocClick
      end
      object lblNuevoElegidos: TLabel
        Left = 150
        Top = 330
        Width = 117
        Height = 15
        Caption = 'Documentos elegidos'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object grdElegidos: TcxGrid
        Left = 18
        Top = 356
        Width = 403
        Height = 80
        Anchors = [akLeft, akTop, akRight]
        BorderStyle = cxcbsNone
        TabOrder = 8
        LookAndFeel.Kind = lfUltraFlat
        LookAndFeel.NativeStyle = False
        object tvElegidos: TcxGridTableView
          OnCellDblClick = tvElegidosCellDblClick
          OptionsData.Appending = False
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.DataRowHeight = 28
          OptionsView.GridLineColor = 13031136
          OptionsView.GridLines = glHorizontal
          OptionsView.GroupByBox = False
          OptionsView.HeaderHeight = 0
          OptionsView.Header = False
          OptionsView.Indicator = False
          OptionsView.NoDataToDisplayInfoText = 'Ning'#250'n documento elegido'
          Styles.Background = stContenidoPeq
          Styles.Content = stContenidoPeq
          Styles.ContentEven = stContenidoPeq
          Styles.ContentOdd = stContenidoPeq
          Styles.Inactive = stSeleccion
          Styles.Selection = stSeleccion
          object colElegidoCodigo: TcxGridColumn
            Caption = 'C'#243'digo'
            DataBinding.ValueType = 'String'
            Width = 90
          end
          object colElegidoTitulo: TcxGridColumn
            Caption = 'T'#237'tulo'
            DataBinding.ValueType = 'String'
            Width = 300
          end
        end
        object lvElegidos: TcxGridLevel
          GridView = tvElegidos
        end
      end
      object lblNuevoAyuda: TLabel
        Left = 18
        Top = 442
        Width = 3
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 5924725
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblNuevoError: TLabel
        Left = 18
        Top = 462
        Width = 3
        Height = 15
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1975987
        Font.Height = -12
        Font.Name = 'Segoe UI Semibold'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlNuevoAcciones: TPanel
      Left = 1
      Top = 658
      Width = 439
      Height = 62
      Align = alBottom
      BevelOuter = bvNone
      Color = 14806258
      ParentBackground = False
      ShowCaption = False
      TabOrder = 4
      Visible = False
      object btnGuardarSolicitud: TcxButton
        Left = 16
        Top = 13
        Width = 150
        Height = 36
        Caption = 'Guardar solicitud'
        TabOrder = 0
        OnClick = btnGuardarSolicitudClick
      end
      object btnRegistrarEntrega: TcxButton
        Left = 176
        Top = 13
        Width = 150
        Height = 36
        Caption = 'Registrar entrega'
        TabOrder = 1
        OnClick = btnRegistrarEntregaNuevoClick
      end
      object btnCerrarNuevo: TcxButton
        Left = 336
        Top = 13
        Width = 90
        Height = 36
        Caption = 'Cancelar'
        TabOrder = 2
        OnClick = btnCerrarNuevoClick
      end
    end
  end
  object pnlPrincipal: TPanel
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
        Caption = 'Pr'#233'stamos'
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
        Left = 680
        Top = 0
        Width = 600
        Height = 65
        Align = alRight
        BevelOuter = bvNone
        Color = 16383487
        ParentBackground = False
        ShowCaption = False
        TabOrder = 0
        object edtBuscar: TcxTextEdit
          Left = 10
          Top = 15
            Properties.OnChange = edtBuscarPropertiesChange
          TabOrder = 0
          TextHint = 'Buscar solicitante, n'#250'mero o entidad...'
          Width = 250
        end
        object btnExportar: TcxButton
          Left = 274
          Top = 15
          Width = 100
          Height = 36
            Caption = 'Exportar'
          TabOrder = 1
          OnClick = btnExportarClick
        end
        object btnNuevo: TcxButton
          Left = 388
          Top = 15
          Width = 192
          Height = 36
            Caption = 'Nuevo pr'#233'stamo'
          TabOrder = 2
          OnClick = btnNuevoClick
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
        TabOrder = 3
      end
    end
    object pnlIndicadores: TPanel
      Left = 0
      Top = 66
      Width = 1280
      Height = 84
      Align = alTop
      BevelOuter = bvNone
      Color = 15528951
      ParentBackground = False
      ShowCaption = False
      TabOrder = 1
      object pbIndicadores: TPaintBox
        Left = 0
        Top = 0
        Width = 1280
        Height = 84
        Align = alClient
        OnPaint = pbIndicadoresPaint
      end
    end
    object pnlPasos: TPanel
      Left = 0
      Top = 150
      Width = 1280
      Height = 84
      Align = alTop
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 2
      Visible = False
      object pbPasos: TPaintBox
        Left = 0
        Top = 0
        Width = 1280
        Height = 84
        Align = alClient
        OnPaint = pbPasosPaint
      end
    end
    object pnlPestanas: TPanel
      Left = 0
      Top = 234
      Width = 1280
      Height = 46
      Align = alTop
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 3
      object pbPestanas: TPaintBox
        Left = 0
        Top = 0
        Width = 1280
        Height = 46
        Align = alClient
        OnMouseDown = pbPestanasMouseDown
        OnMouseMove = pbPestanasMouseMove
        OnPaint = pbPestanasPaint
      end
    end
    object pnlLista: TPanel
      Left = 0
      Top = 280
      Width = 1280
      Height = 440
      Align = alClient
      BevelOuter = bvNone
      Color = 16383487
      ParentBackground = False
      ShowCaption = False
      TabOrder = 5
      object grdPrestamos: TcxGrid
        Left = 16
        Top = 0
        Width = 808
        Height = 424
        Align = alClient
        BorderStyle = cxcbsNone
        TabOrder = 0
        LookAndFeel.Kind = lfUltraFlat
        LookAndFeel.NativeStyle = False
        object tvPrestamos: TcxGridTableView
          OnCustomDrawColumnHeader = tvCustomDrawColumnHeader
          OnFocusedRecordChanged = tvPrestamosFocusedRecordChanged
          OptionsData.Appending = False
          OptionsData.Deleting = False
          OptionsData.Editing = False
          OptionsData.Inserting = False
          OptionsSelection.CellSelect = False
          OptionsView.ColumnAutoWidth = True
          OptionsView.DataRowHeight = 42
          OptionsView.GridLineColor = 13031136
          OptionsView.GridLines = glHorizontal
          OptionsView.GroupByBox = False
          OptionsView.HeaderHeight = 36
          OptionsView.Indicator = False
          OptionsView.NoDataToDisplayInfoText = 'No hay pr'#233'stamos con este filtro'
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
            Width = 90
          end
          object colSolicitante: TcxGridColumn
            Caption = 'Solicitante'
            DataBinding.ValueType = 'String'
            Width = 160
          end
          object colEntidad: TcxGridColumn
            Caption = 'Entidad'
            DataBinding.ValueType = 'String'
            Width = 190
          end
          object colUnidades: TcxGridColumn
            Caption = 'Documentos'
            DataBinding.ValueType = 'String'
            Width = 100
          end
          object colFecha: TcxGridColumn
            Caption = 'Fecha'
            DataBinding.ValueType = 'String'
            Width = 90
          end
          object colLimite: TcxGridColumn
            Caption = 'Devolver antes de'
            DataBinding.ValueType = 'String'
            Width = 120
          end
          object colEstado: TcxGridColumn
            Caption = 'Estado'
            DataBinding.ValueType = 'String'
            Width = 130
          end
        end
        object lvPrestamos: TcxGridLevel
          GridView = tvPrestamos
        end
      end
    end
  end
  object tmrBuscarLista: TTimer
    Enabled = False
    Interval = 350
    OnTimer = tmrBuscarListaTimer
    Left = 120
    Top = 620
  end
  object tmrBuscarDoc: TTimer
    Enabled = False
    Interval = 350
    OnTimer = tmrBuscarDocTimer
    Left = 180
    Top = 620
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
