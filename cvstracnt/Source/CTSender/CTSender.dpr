program CTSender;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  CTPluginIntf in '..\Public\CTPluginIntf.pas',
  CTPluginMgr in '..\Public\CTPluginMgr.pas',
  CTSMain in 'CTSMain.pas',
  CTConsts in '..\Public\CTConsts.pas',
  CTUtils in '..\Public\CTUtils.pas';

{$R *.res}

begin
  if (ParamCount <> 3) and (ParamCount <> 4) then
  begin
    Writeln(Format(
      'CVSTracNT Ticket Change Notification Sender' + #13#10 +
      '' + #13#10 +
      'Usage: %s Database TicketNo UserID' + #13#10 +
      '  Database - Project name' + #13#10 +
      '  TicketNo - The ticket number' + #13#10 +
      '  UserID   - UserID of the person who made the change' + #13#10 +
      '' + #13#10 +
      'Example: %s myrep 23 tom' + #13#10 +
      '' + #13#10 +
      'Note: Notification will be sent according to project settings',
      [ExtractFileName(ParamStr(0)), ExtractFileName(ParamStr(0))]));
  end;

  try
    with TCTSSender.Create do
    try
      Execute;
    finally
      Free;
    end;
  except
    ;
  end;
end.
