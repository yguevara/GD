object frmNewUser: TfrmNewUser
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Nuevo Usuario...'
  ClientHeight = 395
  ClientWidth = 464
  Color = clBtnFace
  Constraints.MaxHeight = 424
  Constraints.MaxWidth = 470
  Constraints.MinHeight = 424
  Constraints.MinWidth = 470
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblNameUser: TLabel
    Left = 16
    Top = 13
    Width = 91
    Height = 13
    Caption = 'Nombre de Usuario'
  end
  object Label1: TLabel
    Left = 16
    Top = 47
    Width = 83
    Height = 13
    Caption = 'Nombre completo'
  end
  object Label2: TLabel
    Left = 16
    Top = 148
    Width = 47
    Height = 13
    Caption = 'Habilitado'
  end
  object lblPass: TLabel
    Left = 16
    Top = 193
    Width = 56
    Height = 13
    Caption = 'Contrase'#241'a'
  end
  object Label3: TLabel
    Left = 16
    Top = 233
    Width = 106
    Height = 13
    Caption = 'Confirmar Contrase'#241'a'
  end
  object lblGrupo: TLabel
    Left = 16
    Top = 282
    Width = 83
    Height = 13
    Caption = 'Grupo de Usuario'
  end
  object Label5: TLabel
    Left = 15
    Top = 83
    Width = 41
    Height = 13
    Caption = 'Empresa'
  end
  object Label6: TLabel
    Left = 15
    Top = 115
    Width = 45
    Height = 13
    Caption = 'Ministerio'
  end
  object edtUser: TEdit
    Left = 128
    Top = 9
    Width = 313
    Height = 21
    TabOrder = 0
  end
  object edtCompleteName: TEdit
    Left = 128
    Top = 43
    Width = 313
    Height = 21
    TabOrder = 1
  end
  object cbEnable: TComboBox
    Left = 128
    Top = 144
    Width = 59
    Height = 21
    TabOrder = 4
    Items.Strings = (
      'S'
      'N')
  end
  object edtpass: TEdit
    Left = 128
    Top = 189
    Width = 313
    Height = 21
    PasswordChar = '*'
    TabOrder = 5
  end
  object Panel2: TPanel
    Left = 16
    Top = 178
    Width = 425
    Height = 4
    BevelInner = bvLowered
    TabOrder = 10
  end
  object edtconfirmpass: TEdit
    Left = 128
    Top = 229
    Width = 313
    Height = 21
    PasswordChar = '*'
    TabOrder = 6
  end
  object Panel3: TPanel
    Left = 16
    Top = 258
    Width = 425
    Height = 4
    BevelInner = bvLowered
    TabOrder = 11
  end
  object Panel4: TPanel
    Left = 16
    Top = 322
    Width = 425
    Height = 4
    BevelInner = bvLowered
    TabOrder = 12
  end
  object btnClose: TButton
    Left = 366
    Top = 344
    Width = 75
    Height = 25
    Caption = 'Cerrar'
    TabOrder = 8
    OnClick = btnCloseClick
  end
  object btnCreateUser: TButton
    Left = 285
    Top = 344
    Width = 75
    Height = 25
    Caption = 'Crear'
    TabOrder = 7
    OnClick = btnCreateUserClick
  end
  object btnHelp: TButton
    Left = 8
    Top = 344
    Width = 75
    Height = 25
    Caption = 'Ayuda'
    TabOrder = 9
    OnClick = btnHelpClick
  end
  object edtEmpresa: TEdit
    Left = 128
    Top = 79
    Width = 313
    Height = 21
    TabOrder = 2
  end
  object edtMinisterio: TEdit
    Left = 128
    Top = 111
    Width = 313
    Height = 21
    TabOrder = 3
  end
  object lcbrol: TDBLookupComboBox
    Left = 128
    Top = 282
    Width = 313
    Height = 21
    KeyField = 'idrol'
    ListField = 'rol'
    TabOrder = 13
  end
end
