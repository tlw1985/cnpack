inherited CTXOptionForm: TCTXOptionForm
  Left = 403
  Top = 283
  BorderStyle = bsDialog
  Caption = 'RTX '#35774#32622
  ClientHeight = 180
  ClientWidth = 319
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 305
    Height = 137
    Caption = 'RTX '#35774#32622'(&S)'
    TabOrder = 0
    object lbl1: TLabel
      Left = 8
      Top = 20
      Width = 62
      Height = 13
      Caption = 'RTX '#26381#21153#22120':'
    end
    object lbl7: TLabel
      Left = 8
      Top = 49
      Width = 50
      Height = 13
      Caption = 'RTX '#31471#21475':'
    end
    object lbl2: TLabel
      Left = 8
      Top = 72
      Width = 276
      Height = 39
      Caption = 
        #27880#65306#26412#25554#20214#22522#20110' RTXServer SDK 3.3 '#24320#21457#12290#35201#20351#29992' RTX '#36890#30693#21151#33021#65292#35831#30830#35748#24744#24050#32463#22312#26412#26426#27491#30830#23433#35013#24182#37197#32622#20102' RTX ' +
        #33150#35759#36890' SDK'#12290#35814#35265#33150#35759#32593#31449#19978#30340#35828#26126#12290
      WordWrap = True
    end
    object edtServerAddress: TEdit
      Left = 80
      Top = 16
      Width = 209
      Height = 21
      TabOrder = 0
      Text = '127.0.0.1'
    end
    object seServerPort: TSpinEdit
      Left = 80
      Top = 44
      Width = 121
      Height = 22
      MaxValue = 65535
      MinValue = 0
      TabOrder = 1
      Value = 6000
    end
    object btnTest: TButton
      Left = 216
      Top = 44
      Width = 75
      Height = 21
      Caption = #27979#35797'(&T)'
      TabOrder = 2
      OnClick = btnTestClick
    end
  end
  object btnClose: TButton
    Left = 239
    Top = 152
    Width = 75
    Height = 21
    Cancel = True
    Caption = #21462#28040'(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 159
    Top = 152
    Width = 75
    Height = 21
    Caption = #30830#23450'(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
