object frmDoc: TfrmDoc
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Documentaci'#243'n asociada al sistema'
  ClientHeight = 337
  ClientWidth = 579
  Color = clBtnFace
  Constraints.MaxHeight = 366
  Constraints.MaxWidth = 585
  Constraints.MinHeight = 366
  Constraints.MinWidth = 585
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar2: TStatusBar
    Left = 0
    Top = 318
    Width = 579
    Height = 19
    Panels = <>
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 579
    Height = 29
    ButtonHeight = 30
    ButtonWidth = 32
    Caption = 'ToolBar1'
    Images = UDM.ILv1
    TabOrder = 1
    ExplicitTop = -6
    object ToolButton2: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object ToolButton1: TToolButton
      Left = 8
      Top = 0
      Hint = 'Regresar a la interfase principal'
      Caption = 'ToolButton1'
      ImageIndex = 0
      ParentShowHint = False
      ShowHint = True
      OnClick = ToolButton1Click
    end
    object ToolButton3: TToolButton
      Left = 40
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 37
      Style = tbsSeparator
    end
  end
  object lbDoc: TJvListView
    Left = 0
    Top = 29
    Width = 579
    Height = 289
    Align = alClient
    Columns = <
      item
        AutoSize = True
        Caption = 'Documento'
      end>
    ReadOnly = True
    SmallImages = UDM.ILEdith
    SortType = stBoth
    TabOrder = 2
    ViewStyle = vsReport
    OnDblClick = lbDocDblClick
    ColumnsOrder = '0=575'
    SortMethod = smAlphabetic
    ExtendedColumns = <
      item
        SortMethod = smAlphabetic
      end>
    ExplicitWidth = 314
    ExplicitHeight = 163
  end
end
