inherited CTNDatabaseForm: TCTNDatabaseForm
  Left = 433
  Top = 197
  BorderStyle = bsDialog
  Caption = #20449#20351#36890#30693#35774#32622
  ClientHeight = 332
  ClientWidth = 360
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 345
    Height = 289
    Caption = #20449#20351#36890#30693#35774#32622'(&N)'
    TabOrder = 0
    object lbl2: TLabel
      Left = 8
      Top = 56
      Width = 271
      Height = 26
      Caption = #35201#25509#25910#20449#20351#36890#30693#30340#20854#23427#22320#22336#21015#34920#65292#27599#34892#19968#20010#22320#22336'(&U):'#13#10#26684#24335': '#29992#25143#21517' | '#35745#31639#26426#21517' | '#24037#20316#32452#21517' | /'#22495#21517':['#29992#25143#21517']'
      FocusControl = mmoUsers
    end
    object lbl1: TLabel
      Left = 8
      Top = 248
      Width = 329
      Height = 33
      AutoSize = False
      Caption = #27880': '#29992#25143#24517#39035#36816#34892#20102' WinPopup (Win9X) '#25110#21551#21160#20102' Messenger '#26381#21153' (WinNT) '#25165#33021#25509#25910#28040#24687#12290
      FocusControl = mmoUsers
      WordWrap = True
    end
    object chkAllUsers: TCheckBox
      Left = 8
      Top = 16
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#26412#32593#27573#25152#26377#29992#25143'(&A)'#12290
      TabOrder = 0
    end
    object chkLoginUsers: TCheckBox
      Left = 8
      Top = 36
      Width = 329
      Height = 17
      Caption = #21457#36865#32473#30331#24405#21040#26412#26426#30340#25152#26377#29992#25143'(&L)'#12290
      TabOrder = 1
    end
    object mmoUsers: TMemo
      Left = 8
      Top = 88
      Width = 329
      Height = 153
      ScrollBars = ssVertical
      TabOrder = 2
      WordWrap = False
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
