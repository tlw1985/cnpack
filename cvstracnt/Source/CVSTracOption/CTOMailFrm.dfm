object CTOMailForm: TCTOMailForm
  Left = 363
  Top = 255
  BorderStyle = bsDialog
  Caption = #37038#20214#36890#30693#35774#32622
  ClientHeight = 310
  ClientWidth = 319
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 305
    Height = 265
    Caption = #37038#20214#26381#21153#22120'(&S)'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 68
      Width = 66
      Height = 12
      Caption = 'SMTP'#26381#21153#22120':'
    end
    object lbl2: TLabel
      Left = 8
      Top = 140
      Width = 66
      Height = 12
      Caption = #30331#24405#29992#25143#21517':'
    end
    object lbl3: TLabel
      Left = 8
      Top = 20
      Width = 66
      Height = 12
      Caption = #21457#20449#20154#37038#31665':'
    end
    object lbl4: TLabel
      Left = 8
      Top = 164
      Width = 54
      Height = 12
      Caption = #30331#24405#23494#30721':'
    end
    object lbl5: TLabel
      Left = 8
      Top = 188
      Width = 54
      Height = 12
      Caption = #26412#26426#22495#21517':'
    end
    object lbl6: TLabel
      Left = 80
      Top = 208
      Width = 216
      Height = 48
      Caption = 
        #29992#20110#22312#36890#30693#37038#20214#20013#26174#31034#20219#21153#21333#38142#25509#65292#22914#65306#13#10'http://www.mycvstrac.org'#13#10'http://192.168.0.1' +
        #13#10'http://cvsserver'
    end
    object lbl7: TLabel
      Left = 8
      Top = 92
      Width = 54
      Height = 12
      Caption = 'SMTP'#31471#21475':'
    end
    object lbl8: TLabel
      Left = 8
      Top = 44
      Width = 66
      Height = 12
      Caption = #21457#20449#20154#21517#31216':'
    end
    object edtSmtpServer: TEdit
      Left = 80
      Top = 64
      Width = 209
      Height = 20
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
      Height = 20
      TabOrder = 0
    end
    object edtUserName: TEdit
      Left = 80
      Top = 136
      Width = 209
      Height = 20
      TabOrder = 5
    end
    object edtPassword: TEdit
      Left = 80
      Top = 160
      Width = 209
      Height = 20
      PasswordChar = '*'
      TabOrder = 6
    end
    object edtLocalServer: TEdit
      Left = 80
      Top = 184
      Width = 209
      Height = 20
      TabOrder = 7
    end
    object seSmtpPort: TSpinEdit
      Left = 80
      Top = 88
      Width = 209
      Height = 21
      MaxValue = 65535
      MinValue = 0
      TabOrder = 3
      Value = 25
    end
    object edtSenderName: TEdit
      Left = 80
      Top = 40
      Width = 209
      Height = 20
      TabOrder = 1
    end
  end
  object btnClose: TButton
    Left = 239
    Top = 280
    Width = 75
    Height = 21
    Cancel = True
    Caption = #21462#28040'(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 159
    Top = 280
    Width = 75
    Height = 21
    Caption = #30830#23450'(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
