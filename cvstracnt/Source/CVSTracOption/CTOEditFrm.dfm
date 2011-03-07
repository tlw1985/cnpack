inherited CTOEditForm: TCTOEditForm
  Left = 367
  Top = 213
  BorderStyle = bsDialog
  Caption = #25968#25454#24211#35774#32622
  ClientHeight = 358
  ClientWidth = 407
  OldCreateOrder = True
  Scaled = False
  OnDestroy = FormDestroy
  DesignSize = (
    407
    358)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 246
    Top = 329
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #30830#23450'(&O)'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 326
    Top = 329
    Width = 75
    Height = 21
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #21462#28040'(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 393
    Height = 313
    ActivePage = tsOption
    TabOrder = 0
    object tsOption: TTabSheet
      Caption = #20179#24211#35774#32622'(&Q)'
      object grp1: TGroupBox
        Left = 8
        Top = 8
        Width = 369
        Height = 265
        Caption = 'CVS '#20179#24211'(&E)'
        TabOrder = 0
        object lbl1: TLabel
          Left = 8
          Top = 47
          Width = 52
          Height = 13
          Caption = #20179#24211#36335#24452':'
        end
        object lbl3: TLabel
          Left = 8
          Top = 99
          Width = 52
          Height = 13
          Caption = #25968#25454#24211#21517':'
        end
        object lbl2: TLabel
          Left = 8
          Top = 73
          Width = 52
          Height = 13
          Caption = #27169#22359#21069#32512':'
        end
        object Label1: TLabel
          Left = 8
          Top = 181
          Width = 52
          Height = 13
          Caption = #26144#23556#29992#25143':'
        end
        object lbl5: TLabel
          Left = 8
          Top = 127
          Width = 40
          Height = 13
          Caption = #23383#31526#38598':'
        end
        object lbl4: TLabel
          Left = 8
          Top = 20
          Width = 52
          Height = 13
          Caption = #20179#24211#31867#22411':'
        end
        object edtDatabase: TEdit
          Left = 64
          Top = 97
          Width = 273
          Height = 21
          TabOrder = 4
        end
        object btnPath: TButton
          Left = 341
          Top = 43
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 2
          OnClick = btnPathClick
        end
        object cbbHome: TComboBox
          Left = 64
          Top = 43
          Width = 273
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnChange = cbbHomeChange
        end
        object cbbModule: TComboBox
          Left = 64
          Top = 69
          Width = 273
          Height = 21
          ItemHeight = 13
          TabOrder = 3
        end
        object chkPasswd: TCheckBox
          Left = 64
          Top = 154
          Width = 281
          Height = 17
          Caption = #30001' CVSTrac '#31649#29702' CVS '#29992#25143#21450#35835#20889#26435#38480#12290
          TabOrder = 6
          OnClick = chkPasswdClick
        end
        object edtCvsUser: TEdit
          Left = 64
          Top = 177
          Width = 273
          Height = 21
          TabOrder = 7
        end
        object btnExport: TButton
          Left = 64
          Top = 205
          Width = 129
          Height = 22
          Caption = #23548#20986#29992#25143#21015#34920'(&P)...'
          TabOrder = 8
          OnClick = btnExportClick
        end
        object btnImport: TButton
          Left = 208
          Top = 205
          Width = 131
          Height = 22
          Caption = #23548#20837#29992#25143#21015#34920'(&I)...'
          TabOrder = 9
          OnClick = btnImportClick
        end
        object edtCharset: TEdit
          Left = 64
          Top = 125
          Width = 273
          Height = 21
          TabOrder = 5
        end
        object cbbSCM: TComboBox
          Left = 64
          Top = 16
          Width = 273
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbbHomeChange
        end
      end
    end
    object ts3: TTabSheet
      Caption = #26356#26032#36890#30693'(&M)'
      ImageIndex = 2
      object grp2: TGroupBox
        Left = 8
        Top = 88
        Width = 369
        Height = 185
        Caption = #26356#26032#36890#30693#25554#20214'(&F)'
        TabOrder = 1
        object lvPlugins: TListView
          Left = 8
          Top = 16
          Width = 353
          Height = 129
          Checkboxes = True
          Columns = <
            item
              Caption = #25554#20214#21517
              Width = 100
            end
            item
              Caption = #35828#26126
              Width = 230
            end>
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnChange = lvPluginsChange
          OnClick = lvPluginsClick
          OnDblClick = btnPluginConfigClick
        end
        object btnPluginConfig: TButton
          Left = 282
          Top = 152
          Width = 81
          Height = 21
          Caption = #25554#20214#35774#32622'(&N)'
          TabOrder = 1
          OnClick = btnPluginConfigClick
        end
      end
      object rgNotifyKind: TRadioGroup
        Left = 8
        Top = 8
        Width = 369
        Height = 73
        Caption = #26356#26032#36890#30693#26041#24335'(&K)'
        TabOrder = 0
        OnClick = rgNotifyKindChange
      end
    end
    object tsHelp: TTabSheet
      Caption = #24110#21161'(&H)'
      ImageIndex = 1
      object mmoHelp: TMemo
        Left = 8
        Top = 8
        Width = 369
        Height = 265
        Color = clInfoBk
        Lines.Strings = (
          #27599#20010' CVS '#20179#24211#23545#24212#19968#20010#25968#25454#24211#65292#22914#26524#25351#23450#20102#27169#22359#21069#32512#65292#21017#21482#26174#31034#30456
          #21305#37197#30340#20869#23481#65292#21542#21017#31649#29702#35813' CVS '#20179#24211#19979#25152#26377#27169#22359#12290
          ''
          #20351#29992#20197#19979#26041#24335#26469#35775#38382#35813#20179#24211#30456#20851#30340' CVSTrac '#39029#38754':'
          'http://'#20027#26426#21517':'#31471#21475#21495'/'#25968#25454#24211#21517'/index'
          ''
          #22914#26524#20351#29992' passwd '#25991#20214#26469#31649#29702#29992#25143#65292#21017#31995#32479#20250#33258#21160#25226' CVSTrac '#24080#21495
          #20889#21040' passwd '#25991#20214#24182#36171#20801#30456#24212#30340' CVS '#35835#20889#26435#38480#12290#27492#26102#26144#23556#29992#25143#21517#35831
          #35774#32622#20026#21487#27491#24120#35775#38382' CVS '#30340#25805#20316#31995#32479#26412#22320#29992#25143#24080#21495#12290
          ''
          #22914#26524#22312' CVSNT '#19979#26080#27861#30331#24405#65292#35831#26597#30475' Readme '#25991#20214#65292#37324#38754#26377#30456#24212#30340#35774
          #32622#26041#27861#12290
          ''
          #35201#20351#29992#26356#26032#36890#30693#21151#33021#65292#38656#35201#22312#20027#30028#38754#20013#37197#32622#36890#30693#25554#20214#12290
          ''
          #35814#35265': CVSTracNT '#20351#29992#35828#26126#12290)
        ReadOnly = True
        TabOrder = 0
      end
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'lst'
    Filter = #29992#25143#21015#34920#25991#20214'(*.lst)|*.lst|'#20840#37096#25991#20214'(*.*)|*.*'
    Options = [ofEnableSizing]
    Left = 8
    Top = 328
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'lst'
    Filter = #29992#25143#21015#34920#25991#20214'(*.lst)|*.lst|'#20840#37096#25991#20214'(*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 40
    Top = 328
  end
end
