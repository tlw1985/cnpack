inherited CTXDatabaseForm: TCTXDatabaseForm
  Left = 379
  Top = 198
  BorderStyle = bsDialog
  Caption = 'RTX '#36890#30693#35774#32622
  ClientHeight = 380
  ClientWidth = 391
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 377
    Height = 241
    Caption = #29992#25143#35774#32622'(&M)'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 109
      Width = 313
      Height = 13
      Caption = #27880#65306#21457#36865#26102#20351#29992' CVSTrac '#29992#25143#20840#21517#26469#20851#32852' RTX '#29992#25143#21517#25110' ID'#12290
    end
    object lbl2: TLabel
      Left = 8
      Top = 128
      Width = 267
      Height = 13
      Caption = #20854#23427#25509#25910#32773#65292#21487#20197#26159' RTX '#29992#25143#21517#25110' ID'#65292#27599#34892#19968#20010#65306
    end
    object chkToAll: TCheckBox
      Left = 8
      Top = 34
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#39033#30446#32452#20013#25152#26377#20154'(&A)'#12290
      TabOrder = 1
    end
    object chkToAssigned: TCheckBox
      Left = 8
      Top = 52
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#20219#21153#21333#25509#25910#20154'(&G)'#12290
      TabOrder = 2
    end
    object chkToContact: TCheckBox
      Left = 8
      Top = 88
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#20219#21153#21333#32852#31995#26041#24335#22320#22336'(&I)'#12290
      TabOrder = 4
    end
    object chkToOwner: TCheckBox
      Left = 8
      Top = 70
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#20219#21153#21333#21019#24314#20154'(&T)'#12290
      TabOrder = 3
    end
    object mmoUsers: TMemo
      Left = 8
      Top = 144
      Width = 361
      Height = 89
      ScrollBars = ssVertical
      TabOrder = 5
      WordWrap = False
    end
    object chkToAllRTXUsers: TCheckBox
      Left = 8
      Top = 16
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#25152#26377' RTX '#29992#25143'(&X)'#12290
      TabOrder = 0
    end
  end
  object btnClose: TButton
    Left = 311
    Top = 352
    Width = 75
    Height = 21
    Cancel = True
    Caption = #21462#28040'(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object btnHelp: TButton
    Left = 231
    Top = 352
    Width = 75
    Height = 21
    Caption = #30830#23450'(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object grp2: TGroupBox
    Left = 8
    Top = 256
    Width = 377
    Height = 89
    Caption = #28040#24687#35774#32622'(&S)'
    TabOrder = 1
    object lbl3: TLabel
      Left = 8
      Top = 20
      Width = 52
      Height = 13
      Caption = #28040#24687#26631#39064':'
    end
    object lbl4: TLabel
      Left = 176
      Top = 46
      Width = 52
      Height = 13
      Caption = #28040#24687#24310#26102':'
    end
    object lbl5: TLabel
      Left = 336
      Top = 46
      Width = 12
      Height = 13
      Caption = #31186
    end
    object rbSysMsg: TRadioButton
      Left = 8
      Top = 64
      Width = 153
      Height = 17
      Caption = #20351#29992#31995#32479#28040#24687#26041#24335#12290
      TabOrder = 3
      OnClick = rbNormalMsgClick
    end
    object rbNormalMsg: TRadioButton
      Left = 8
      Top = 43
      Width = 153
      Height = 17
      Caption = #20351#29992#25552#37266#28040#24687#26041#24335#12290
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = rbNormalMsgClick
    end
    object edtTitle: TEdit
      Left = 72
      Top = 16
      Width = 297
      Height = 21
      TabOrder = 0
    end
    object seMsgDelay: TSpinEdit
      Left = 240
      Top = 43
      Width = 89
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
  end
end
