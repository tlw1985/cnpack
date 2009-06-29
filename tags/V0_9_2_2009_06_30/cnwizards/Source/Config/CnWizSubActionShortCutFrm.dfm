object CnWizSubActionShortCutForm: TCnWizSubActionShortCutForm
  Left = 349
  Top = 221
  BorderStyle = bsDialog
  Caption = '子菜单快捷键设置'
  ClientHeight = 331
  ClientWidth = 351
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grp1: TGroupBox
    Left = 8
    Top = 8
    Width = 337
    Height = 289
    Caption = '快捷键设置'
    TabOrder = 0
    object lbl2: TLabel
      Left = 8
      Top = 260
      Width = 40
      Height = 13
      Caption = '快捷键:'
    end
    object ListView: TListView
      Left = 8
      Top = 16
      Width = 321
      Height = 233
      Columns = <
        item
          Caption = '子菜单项'
          Width = 160
        end
        item
          Caption = '快捷键'
          Width = 130
        end>
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = ListViewChange
    end
    object HotKey: THotKey
      Left = 64
      Top = 256
      Width = 265
      Height = 19
      HotKey = 0
      InvalidKeys = [hcNone, hcShift]
      Modifiers = []
      TabOrder = 1
      OnExit = HotKeyExit
    end
  end
  object btnHelp: TButton
    Left = 270
    Top = 304
    Width = 75
    Height = 21
    Caption = '帮助(&H)'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object btnOK: TButton
    Left = 110
    Top = 304
    Width = 75
    Height = 21
    Caption = '确定(&O)'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 190
    Top = 304
    Width = 75
    Height = 21
    Cancel = True
    Caption = '取消(&C)'
    ModalResult = 2
    TabOrder = 2
  end
end
