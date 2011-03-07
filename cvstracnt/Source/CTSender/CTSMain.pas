unit CTSMain;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：任务单通知主单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元用于发送指定任务单的通知，调用的命令行：
*           CTSender 数据库名 任务单编号 修改人标识
* 开发平台：PWindows Server 2003 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTSMain.pas,v 1.3 2007/02/09 12:08:45 zjy Exp $
* 更新记录：2003.12.13
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, IniFiles, CnCommon, SQLite3, SQLiteTable3,
  CTPluginIntf, CTConsts, CTUtils, CTPluginMgr;

type
  TCTSSender = class(TObject)
  private
    FLog: TStringList;
    FEnableLog: Boolean;
    FList: TStringList;
    FExtraNames: TStringList;
    IniFileName: string;
    function GetTicketInfo(var TicketInfo: TTicketInfo): Boolean;
    procedure OnGetPlugin(const PluginID, FileName: string;
      var Enabled: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Log(const Text: string);
    procedure Execute;
  end;


implementation

resourcestring
  STicketSQL = 'SELECT type, status, origtime, changetime, derivedfrom, ' +
    'version, assignedto, severity, priority, subsystem, owner, title, ' +
    'contact, extra1, extra2, extra3, extra4, extra5, description, remarks ' +
    'FROM ticket WHERE tn=%d';
  SInvalidParamCount = 'Invalid parameter count.';
  SInvalidTicketNo = 'Invalid ticket number: %d';
  SNoPlugin = 'No plugin available.';
  SGetTicketInfoError = 'Read ticket from database error.';

const
  csFieldCount = 20;
  csSecondsPerDay = 60 * 60 * 24;
  csExec = '-Exec';

{ TCTSSender }

function SQLiteDateTimeToDateTime(Value: string): string;
var
  Seconds: Integer;
  DateTime: TDateTime;
begin
  Seconds := StrToIntDef(Value, -1);
  if Seconds > 0 then
  begin
    DateTime := EncodeDate(1970, 1, 1) + Seconds / csSecondsPerDay;
    DateTime := DateTimeToLocalDateTime(DateTime);
    Result := DateTimeToStr(DateTime);
  end
  else
    Result := '';
end;

constructor TCTSSender.Create;
begin
  inherited;
  FLog := TStringList.Create;
  FList := TStringList.Create;
  FExtraNames := TStringList.Create;
  FEnableLog := LoadSettingsFromIni.EnableLog;
end;

destructor TCTSSender.Destroy;
begin
  FList.Free;
  FExtraNames.Free;
  if FEnableLog and (FLog.Count > 0) then
  try
    if ForceDirectories(MakePath(AppPath + csLogDirName)) then
      FLog.SaveToFile(MakePath(AppPath + csLogDirName) +
        DateTimeToFlatStr(Now) + '.txt');
  except
    ;
  end;
  inherited;
end;

procedure TCTSSender.Execute;
var
  i: Integer;
  Settings: TSettingsInfo;
  TicketInfo: TTicketInfo;
  Cmd: string;
begin
  Settings := LoadSettingsFromIni;

  if (ParamCount <> 3) and (ParamCount <> 4) then
  begin
    if ParamCount > 0 then
      Log(SInvalidParamCount);
    Exit;
  end;

  // 重新启动一个进程来发送通知，以避免影响网页打开速度
  if ParamCount = 3 then
  begin
    Cmd := CmdLine + ' ' + csExec;
    WinExecute(Cmd, SW_HIDE);
    Exit;
  end;

  if (ParamCount = 4) and not SameText(ParamStr(4), csExec) then
  begin
    Log(SInvalidParamCount);
    Exit;
  end;

  Log(DateTimeToStr(Now));
  Log('CmdLine: ' + CmdLine); 

  with TicketInfo do
  begin
    FillChar(TicketInfo, SizeOf(TTicketInfo), 0);
    dwSize := SizeOf(TTicketInfo);
    
    TicketNo := StrToIntDef(ParamStr(2), -1);
    if TicketNo <= 0 then
    begin
      Log(Format(SInvalidTicketNo, [TicketNo]));
      Exit;
    end;

    DBName := PChar(ParamStr(1));
    DBFileName := PChar(MakePath(Settings.DBPath) + DBName + '.db');
    IniFileName := DataBaseFileNameToIniName(DBFileName);

    LocalServer := PChar(Settings.LocalServer);
    Port := Settings.Port;

    Modificator := PChar(ParamStr(3));
  end;

  PluginMgr.OnLog := Log;
  PluginMgr.OnGetPlugin := OnGetPlugin;
  PluginMgr.LoadPlugins;

  if PluginMgr.Count = 0 then
  begin
    Log(SNoPlugin);
    Exit;
  end;

  if not GetTicketInfo(TicketInfo) then
  begin
    Exit;
  end;

  for i := 0 to PluginMgr.Count - 1 do
  begin
    try
      Log('---------------------');
      Log(DateTimeToStr(Now));
      Log('Begin plugin: ' + PluginMgr[i].PluginID);
      PluginMgr[i].Execute(IniFileName, TicketInfo);
      Log('End plugin: ' + PluginMgr[i].PluginID);
      Log(DateTimeToStr(Now));
    except
      on E: Exception do
        Log('Exception: ' + E.Message);
    end;
  end;
end;

function TCTSSender.GetTicketInfo(var TicketInfo: TTicketInfo): Boolean;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteTable;
  i, j: Integer;
  
  function GetParam(const Name: string): string;
  begin
    try
      Result := DB.GetTableString(Format('SELECT value FROM config WHERE name=''%s'';', [Name]));
    except
      Result := '';
    end;
  end;
begin
  Result := False;
  try
    FList.Clear;
    FExtraNames.Clear;
    
    DB := TSQLiteDatabase.Create(TicketInfo.DBFileName);
    try
      for i := 1 to 5 do
        FExtraNames.Add(GetParam(Format('extra%d_name', [i])));
        
      Table := DB.GetTable(Format(STicketSQL, [TicketInfo.TicketNo]));
      try
        if Table.MoveFirst then
        begin
          Result := Table.ColCount = csFieldCount;
          if Result then
          begin
            for i := 0 to Table.ColCount - 1 do
              FList.Add(Table.FieldAsString(i));

            with TicketInfo do
            begin
              TicketType := PChar(FList[0]);
              TicketStatus := PChar(FList[1]);
              FList[2] := SQLiteDateTimeToDateTime(FList[2]);
              OrigTime := PChar(FList[2]);
              FList[3] := SQLiteDateTimeToDateTime(FList[3]);
              ChangeTime := PChar(FList[3]);
              DerivedFrom := PChar(FList[4]);
              Version := PChar(FList[5]);
              AssignedTo := PChar(FList[6]);
              Severity := PChar(FList[7]);
              Priority := PChar(FList[8]);
              SubSystem := PChar(FList[9]);
              Owner := PChar(FList[10]);
              Title := PChar(FList[11]);
              Contact := PChar(FList[12]);
              Extra[1] := PChar(FList[13]);
              Extra[2] := PChar(FList[14]);
              Extra[3] := PChar(FList[15]);
              Extra[4] := PChar(FList[16]);
              Extra[5] := PChar(FList[17]);
              Description := PChar(FList[18]);
              Remarks := PChar(FList[19]);

              for j := 1 to 5 do
                Extra_Name[j] := PChar(FExtraNames[j - 1]);
            end;
          end;
        end;
      finally
        Table.Free;
      end;                      
    finally
      DB.Free;
    end;
  except
    on E: Exception do
    begin
      Log(SGetTicketInfoError + ': ' + E.Message);
      Result := False;
    end;
  end;
end;

procedure TCTSSender.Log(const Text: string);
begin
  if FEnableLog then
    FLog.Add(Text);
end;

procedure TCTSSender.OnGetPlugin(const PluginID, FileName: string;
  var Enabled: Boolean);
begin
  with TIniFile.Create(IniFileName) do
  try
    Enabled := ReadBool(csActiveSection, PluginID, False);
  finally
    Free;
  end;
end;

end.
