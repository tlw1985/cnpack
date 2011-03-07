object CVSTracService: TCVSTracService
  OldCreateOrder = False
  OnCreate = ServiceCreate
  AllowPause = False
  DisplayName = 'CVSTrac Service'
  WaitHint = 2000
  OnStart = ServiceStart
  OnStop = ServiceStop
  Left = 192
  Top = 107
  Height = 480
  Width = 696
  object tmrBackup: TTimer
    Interval = 10000
    OnTimer = tmrBackupTimer
    Left = 328
    Top = 208
  end
end
