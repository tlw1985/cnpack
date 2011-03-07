object CTOMainForm: TCTOMainForm
  Left = 233
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'CVSTracNT V2.0.1 '#37197#32622#31243#24207
  ClientHeight = 484
  ClientWidth = 625
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
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
  object Label1: TLabel
    Left = 8
    Top = 448
    Width = 95
    Height = 13
    Caption = 'CVSTrac '#23448#26041#32593#31449':'
  end
  object Label2: TLabel
    Left = 120
    Top = 448
    Width = 115
    Height = 13
    Cursor = crHandPoint
    Caption = 'http://www.cvstrac.org'
    Font.Charset = GB2312_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label2Click
  end
  object Label3: TLabel
    Left = 8
    Top = 464
    Width = 102
    Height = 13
    Caption = 'CnPack '#24320#21457#32452#32593#31449':'
  end
  object Label4: TLabel
    Left = 120
    Top = 464
    Width = 113
    Height = 13
    Cursor = crHandPoint
    Caption = 'http://www.cnpack.org'
    Font.Charset = GB2312_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = Label4Click
  end
  object lbl4: TLabel
    Left = 264
    Top = 464
    Width = 96
    Height = 13
    Cursor = crHandPoint
    Caption = 'master@cnpack.org'
    Font.Charset = GB2312_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lbl4Click
  end
  object btnClose: TButton
    Left = 542
    Top = 456
    Width = 75
    Height = 21
    Caption = #20851#38381'(&C)'
    TabOrder = 2
    OnClick = btnCloseClick
  end
  object btnHelp: TButton
    Left = 462
    Top = 456
    Width = 75
    Height = 21
    Caption = #35828#26126'(&H)'
    TabOrder = 1
    OnClick = btnHelpClick
  end
  object PageControl: TPageControl
    Left = 8
    Top = 8
    Width = 609
    Height = 433
    ActivePage = tsOption
    TabOrder = 0
    object tsOption: TTabSheet
      Caption = #25968#25454#37197#32622'(&F)'
      object grp1: TGroupBox
        Left = 8
        Top = 8
        Width = 585
        Height = 137
        Caption = 'CVSTrac '#26381#21153'(&Q)'
        TabOrder = 0
        object lbl2: TLabel
          Left = 8
          Top = 82
          Width = 52
          Height = 13
          Caption = #26381#21153#31471#21475':'
        end
        object lbl3: TLabel
          Left = 8
          Top = 25
          Width = 52
          Height = 13
          Caption = #25968#25454#30446#24405':'
        end
        object lbl1: TLabel
          Left = 8
          Top = 104
          Width = 569
          Height = 26
          AutoSize = False
          Caption = #27880': '#25968#25454#30446#24405#20445#23384#25152#26377' CVSTrac '#25968#25454#24211#65292#27599#19968#20010#25968#25454#24211#21487#23545#24212#19968#20010#20179#24211#25110#20179#24211#19979#26576#20010#27169#22359'('#22914#26524#25351#23450#20102#27169#22359#21069#32512')'#12290
          WordWrap = True
        end
        object btnInstall: TButton
          Left = 160
          Top = 78
          Width = 65
          Height = 21
          Caption = #23433#35013'(&I)'
          TabOrder = 6
          OnClick = btnInstallClick
        end
        object btnUninstall: TButton
          Left = 229
          Top = 78
          Width = 65
          Height = 21
          Caption = #21368#36733'(&U)'
          TabOrder = 7
          OnClick = btnUninstallClick
        end
        object btnStart: TButton
          Left = 299
          Top = 78
          Width = 65
          Height = 21
          Caption = #21551#21160'(&S)'
          TabOrder = 8
          OnClick = btnStartClick
        end
        object btnStop: TButton
          Left = 368
          Top = 78
          Width = 65
          Height = 21
          Caption = #20572#27490'(&G)'
          TabOrder = 9
          OnClick = btnStopClick
        end
        object sePort: TSpinEdit
          Left = 64
          Top = 78
          Width = 89
          Height = 22
          MaxLength = 5
          MaxValue = 65535
          MinValue = 0
          TabOrder = 5
          Value = 2040
          OnExit = sePortExit
        end
        object edtHome: TEdit
          Left = 64
          Top = 21
          Width = 489
          Height = 21
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
        end
        object btnPath: TButton
          Left = 556
          Top = 21
          Width = 21
          Height = 21
          Caption = '...'
          TabOrder = 1
          OnClick = btnPathClick
        end
        object cbbLang: TComboBox
          Left = 440
          Top = 78
          Width = 137
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 10
          OnChange = cbbLangChange
        end
        object chkEnableBackup: TCheckBox
          Left = 64
          Top = 48
          Width = 201
          Height = 22
          Caption = #33258#21160#22791#20221#25968#25454#24211#12290#22791#20221#22825#25968':'
          Checked = True
          State = cbChecked
          TabOrder = 2
          OnClick = OnSettingChanged
        end
        object seBackupCount: TSpinEdit
          Left = 272
          Top = 48
          Width = 92
          Height = 22
          MaxValue = 99
          MinValue = 1
          TabOrder = 3
          Value = 7
          OnExit = OnSettingChanged
        end
        object btnBackupNow: TButton
          Left = 368
          Top = 49
          Width = 73
          Height = 21
          Caption = #25163#21160#22791#20221'(&W)'
          TabOrder = 4
          OnClick = btnBackupNowClick
        end
      end
      object grp2: TGroupBox
        Left = 8
        Top = 152
        Width = 585
        Height = 241
        Caption = #25968#25454#24211#21015#34920'(&J)'
        TabOrder = 1
        object ListView: TListView
          Left = 8
          Top = 16
          Width = 569
          Height = 185
          Columns = <
            item
              Caption = #25968#25454#24211
              Width = 80
            end
            item
              Caption = #20179#24211#36335#24452
              Width = 110
            end
            item
              Caption = #27169#22359#21069#32512
              Width = 60
            end
            item
              Caption = 'Passwd'
            end
            item
              Caption = #26144#23556#29992#25143
              Width = 60
            end
            item
              Caption = #26356#26032#36890#30693
              Width = 60
            end
            item
              Caption = #23383#31526#38598
            end
            item
              Caption = 'SCM'#31867#22411
              Width = 75
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnChange = ListViewChange
          OnDblClick = btnEditClick
        end
        object btnAdd: TButton
          Left = 8
          Top = 208
          Width = 49
          Height = 21
          Caption = #22686#21152'(&A)'
          TabOrder = 1
          OnClick = btnAddClick
        end
        object btnDelete: TButton
          Left = 63
          Top = 208
          Width = 49
          Height = 21
          Caption = #21024#38500'(&D)'
          TabOrder = 2
          OnClick = btnDeleteClick
        end
        object btnEdit: TButton
          Left = 172
          Top = 208
          Width = 49
          Height = 21
          Caption = #35774#32622'(&E)'
          TabOrder = 4
          OnClick = btnEditClick
        end
        object btnImport: TButton
          Left = 504
          Top = 208
          Width = 73
          Height = 21
          Caption = #23548#20837#20179#24211'(&X)'
          TabOrder = 9
          OnClick = btnImportClick
        end
        object btnBrowse: TButton
          Left = 283
          Top = 208
          Width = 49
          Height = 21
          Caption = #27983#35272'(&B)'
          TabOrder = 6
          OnClick = btnBrowseClick
        end
        object btnCopy: TButton
          Left = 118
          Top = 208
          Width = 49
          Height = 21
          Caption = #22797#21046'(&K)'
          TabOrder = 3
          OnClick = btnCopyClick
        end
        object btnUpgrade: TButton
          Left = 372
          Top = 208
          Width = 49
          Height = 21
          Caption = #21319#32423'(&M)'
          TabOrder = 7
          OnClick = btnUpgradeClick
        end
        object btnUpgradeAll: TButton
          Left = 427
          Top = 208
          Width = 70
          Height = 21
          Caption = #21319#32423#20840#37096'(&N)'
          TabOrder = 8
          OnClick = btnUpgradeAllClick
        end
        object btnRefresh: TButton
          Left = 227
          Top = 208
          Width = 49
          Height = 21
          Caption = #21047#26032'(&Z)'
          TabOrder = 5
          OnClick = btnRefreshClick
        end
      end
    end
    object tsPlugin: TTabSheet
      Caption = #20219#21153#21333#36890#30693'(&P)'
      ImageIndex = 1
      object grp3: TGroupBox
        Left = 8
        Top = 8
        Width = 585
        Height = 81
        Caption = #20219#21153#21333#35774#32622'(&T)'
        TabOrder = 0
        object lbl5: TLabel
          Left = 8
          Top = 25
          Width = 52
          Height = 13
          Caption = #26412#26426#22495#21517':'
        end
        object edtLocalServer: TEdit
          Left = 80
          Top = 21
          Width = 497
          Height = 21
          Hint = 
            #29992#20110#22312#36890#30693#37038#20214#20013#26174#31034#20219#21153#21333#38142#25509#65292#22914#65306#13#10'http://www.mycvstrac.org'#13#10'http://192.168.0.1' +
            #13#10'http://cvsserver'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnExit = OnSettingChanged
        end
        object chkEnableLog: TCheckBox
          Left = 80
          Top = 48
          Width = 313
          Height = 17
          Caption = #20445#23384#20219#21153#21333#36890#30693#26085#24535#12290
          TabOrder = 1
          OnClick = OnSettingChanged
        end
        object btnViewLogs: TButton
          Left = 496
          Top = 52
          Width = 81
          Height = 21
          Caption = #26597#30475#26085#24535'(&V)'
          TabOrder = 2
          OnClick = btnViewLogsClick
        end
      end
      object grp4: TGroupBox
        Left = 8
        Top = 96
        Width = 585
        Height = 297
        Caption = #20219#21153#21333#36890#30693#25554#20214'(&L)'
        TabOrder = 1
        object lvPlugins: TListView
          Left = 8
          Top = 16
          Width = 569
          Height = 241
          Columns = <
            item
              Caption = #25554#20214#21517
              Width = 120
            end
            item
              Caption = #29256#26412
              Width = 80
            end
            item
              Caption = #20316#32773
              Width = 80
            end
            item
              Caption = #35828#26126
              Width = 270
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnChange = lvPluginsChange
          OnDblClick = btnPluginConfigClick
        end
        object btnPluginConfig: TButton
          Left = 496
          Top = 264
          Width = 81
          Height = 21
          Caption = #25554#20214#35774#32622'(&N)'
          TabOrder = 1
          OnClick = btnPluginConfigClick
        end
      end
    end
  end
  object tmrStatus: TTimer
    Interval = 500
    OnTimer = tmrStatusTimer
    Left = 360
    Top = 440
  end
end
