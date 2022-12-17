object frmChangePass: TfrmChangePass
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Cambiar contrase'#241'a...'
  ClientHeight = 129
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblPass: TLabel
    Left = 17
    Top = 27
    Width = 56
    Height = 13
    Caption = 'Contrase'#241'a'
  end
  object Label3: TLabel
    Left = 17
    Top = 64
    Width = 106
    Height = 13
    Caption = 'Confirmar Contrase'#241'a'
  end
  object edtconfirmpass: TEdit
    Left = 128
    Top = 56
    Width = 313
    Height = 21
    PasswordChar = '*'
    TabOrder = 1
  end
  object edtpass: TEdit
    Left = 128
    Top = 22
    Width = 313
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
  end
  object btnCreateUser: TButton
    Left = 285
    Top = 96
    Width = 75
    Height = 25
    Caption = '&Aceptar'
    TabOrder = 2
    OnClick = btnCreateUserClick
  end
  object btnClose: TButton
    Left = 366
    Top = 96
    Width = 75
    Height = 25
    Caption = '&Cancelar'
    TabOrder = 3
    OnClick = btnCloseClick
  end
end
