inherited CTOMailForm: TCTOMailForm
  Left = 363
  Top = 255
  BorderStyle = bsDialog
  Caption = #37038#20214#26381#21153#22120#35774#32622
  ClientHeight = 260
  ClientWidth = 319
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 305
    Height = 217
    Caption = #37038#20214#26381#21153#22120'(&S)'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 68
      Width = 66
      Height = 13
      Caption = 'SMTP'#26381#21153#22120':'
    end
    object lbl2: TLabel
      Left = 8
      Top = 140
      Width = 64
      Height = 13
      Caption = #30331#24405#29992#25143#21517':'
    end
    object lbl3: TLabel
      Left = 8
      Top = 20
      Width = 64
      Height = 13
      Caption = #21457#20449#20154#37038#31665':'
    end
    object lbl4: TLabel
      Left = 8
      Top = 164
      Width = 52
      Height = 13
      Caption = #30331#24405#23494#30721':'
    end
    object lbl7: TLabel
      Left = 8
      Top = 92
      Width = 54
      Height = 13
      Caption = 'SMTP'#31471#21475':'
    end
    object lbl8: TLabel
      Left = 8
      Top = 44
      Width = 64
      Height = 13
      Caption = #21457#20449#20154#21517#31216':'
    end
    object lbl5: TLabel
      Left = 8
      Top = 190
      Width = 52
      Height = 13
      Caption = #32593#32476#36229#26102':'
    end
    object lbl6: TLabel
      Left = 160
      Top = 190
      Width = 12
      Height = 13
      Caption = #31186
    end
    object edtSmtpServer: TEdit
      Left = 80
      Top = 64
      Width = 209
      Height = 21
      TabOrder = 2
    end
    object chkNeedAuth: TCheckBox
      Left = 80
      Top = 112
      Width = 209
      Height = 17
      Caption = #26381#21153#22120#38656#35201#36523#20221#39564#35777#12290
      TabOrder = 4
      OnClick = chkNeedAuthClick
    end
    object edtSenderMail: TEdit
      Left = 80
      Top = 16
      Width = 209
      Height = 21
      TabOrder = 0
    end
    object edtUserName: TEdit
      Left = 80
      Top = 136
      Width = 209
      Height = 21
      TabOrder = 5
    end
    object edtPassword: TEdit
      Left = 80
      Top = 160
      Width = 209
      Height = 21
      PasswordChar = '*'
      TabOrder = 6
    end
    object seSmtpPort: TSpinEdit
      Left = 80
      Top = 88
      Width = 209
      Height = 22
      MaxValue = 65535
      MinValue = 0
      TabOrder = 3
      Value = 25
    end
    object edtSenderName: TEdit
      Left = 80
      Top = 40
      Width = 209
      Height = 21
      TabOrder = 1
    end
    object btnTest: TButton
      Left = 216
      Top = 186
      Width = 75
      Height = 21
      Caption = #27979#35797'(&T)'
      TabOrder = 8
      OnClick = btnTestClick
    end
    object seTimeOut: TSpinEdit
      Left = 80
      Top = 185
      Width = 73
      Height = 22
      MaxValue = 300
      MinValue = -1
      TabOrder = 7
      Value = 0
    end
  end
  object btnClose: TButton
    Left = 239
    Top = 232
    Width = 75
    Height = 21
    Cancel = True
    Caption = #21462#28040'(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 159
    Top = 232
    Width = 75
    Height = 21
    Caption = #30830#23450'(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
