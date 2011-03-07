inherited CTMDatabaseForm: TCTMDatabaseForm
  Left = 379
  Top = 198
  BorderStyle = bsDialog
  Caption = #37038#20214#36890#30693#35774#32622
  ClientHeight = 330
  ClientWidth = 359
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 345
    Height = 289
    Caption = #37038#20214#36890#30693#35774#32622'(&M)'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 269
      Width = 166
      Height = 13
      Caption = #27880#65306#22810#20010#25509#25910#32773#21487#29992' , '#21495#20998#38548#12290
    end
    object chkToAll: TCheckBox
      Left = 8
      Top = 16
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#39033#30446#32452#20013#25152#26377#20154'(&A)'#12290
      TabOrder = 0
    end
    object chkToAssigned: TCheckBox
      Left = 8
      Top = 37
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#20219#21153#21333#25509#25910#20154'(&G)'#12290
      TabOrder = 1
    end
    object chkToContact: TCheckBox
      Left = 8
      Top = 80
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#20219#21153#21333#32852#31995#26041#24335#22320#22336'(&I)'#12290
      TabOrder = 3
    end
    object lbledtRecipients: TLabeledEdit
      Left = 8
      Top = 160
      Width = 321
      Height = 21
      EditLabel.Width = 79
      EditLabel.Height = 13
      EditLabel.Caption = #20854#23427#25509#25910#32773'(&R):'
      TabOrder = 5
    end
    object lbledtCopyTo: TLabeledEdit
      Left = 8
      Top = 200
      Width = 321
      Height = 21
      EditLabel.Width = 54
      EditLabel.Height = 13
      EditLabel.Caption = #25220#36865#21040'(&P):'
      TabOrder = 6
    end
    object lbledtReplyTo: TLabeledEdit
      Left = 8
      Top = 240
      Width = 321
      Height = 21
      EditLabel.Width = 54
      EditLabel.Height = 13
      EditLabel.Caption = #22238#22797#21040'(&Y):'
      TabOrder = 7
    end
    object chkToOwner: TCheckBox
      Left = 8
      Top = 59
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#20219#21153#21333#21019#24314#20154'(&T)'#12290
      TabOrder = 2
    end
    object lbledtTitle: TLabeledEdit
      Left = 8
      Top = 120
      Width = 321
      Height = 21
      EditLabel.Width = 65
      EditLabel.Height = 13
      EditLabel.Caption = #37038#20214#26631#39064'(&L):'
      TabOrder = 4
    end
  end
  object btnClose: TButton
    Left = 279
    Top = 304
    Width = 75
    Height = 21
    Cancel = True
    Caption = #21462#28040'(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 199
    Top = 304
    Width = 75
    Height = 21
    Caption = #30830#23450'(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
