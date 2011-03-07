unit CTXPlugin;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：RTX 通知插件单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTXPlugin.pas,v 1.3 2007/02/09 12:08:45 zjy Exp $
* 更新记录：2005.03.31
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, Variants, IniFiles, CTPluginIntf, CTPlugin,
  CnCommon, CnConsts, CnLangMgr, CTMultiLangPlugin, SQLite3, SQLiteTable3,
  ComObj, ActiveX;

type
  TRTXPlugin = class(TMultiLangPlugin)
  protected
    procedure GetPluginInfo(var PluginInfo: TPluginInfo); override;
    function Execute(HostIniFile, DBIniFile: TCustomIniFile; TicketInfo:
      TTicketInfo): Boolean; override;
    procedure LangChanged(LangID: Integer); override;
  published
    function ConfigPlugin(Owner: HWND; IniFile: TCustomIniFile): Boolean; override;
    function ConfigDatabase(Owner: HWND; IniFile: TCustomIniFile;
      const DBName, DBFileName: string): Boolean; override;
  end;

implementation

uses CTXSettings, CTXOptionFrm, CTXDatabaseFrm, CTXConsts, CTPluginUtils;

resourcestring
  SUserSQL = 'SELECT name FROM user WHERE id="%s"';
  SAllUsersSQL = 'SELECT name FROM user';
    
{ TRTXPlugin }

function TRTXPlugin.ConfigDatabase(Owner: HWND; IniFile: TCustomIniFile;
  const DBName, DBFileName: string): Boolean;
var
  Settings: TRTXDBSettings;
begin
  Settings := TRTXDBSettings.Create;
  try
    Settings.LoadFromIni(IniFile);
    if ShowDBOptionForm(Settings) then
    begin
      Settings.SaveToIni(IniFile);
      Result := True;
    end
    else
      Result := False;
  finally
    Settings.Free;
  end;
end;

function TRTXPlugin.ConfigPlugin(Owner: HWND;
  IniFile: TCustomIniFile): Boolean;
var
  Settings: TRTXSettings;
begin
  Settings := TRTXSettings.Create;
  try
    Settings.LoadFromIni(IniFile);
    if ShowOptionForm(Settings) then
    begin
      Settings.SaveToIni(IniFile);
      Result := True;
    end
    else
      Result := False;
  finally
    Settings.Free;
  end;
end;

function TRTXPlugin.Execute(HostIniFile, DBIniFile: TCustomIniFile;
  TicketInfo: TTicketInfo): Boolean;
var
  Text: string;
  Settings: TRTXSettings;
  DBSettings: TRTXDBSettings;
  List: TStringList;
  DB: TSQLiteDatabase;
  RTXObj: Variant;
  RTXParams: Variant;
  RETCode: Variant;

  procedure AddUsersFromDB(const SQL: string; AList: TStrings);
  var
    Table: TSQLiteTable;
    User: string;
  begin
    try
      if not Assigned(DB) then
        DB := TSQLiteDatabase.Create(TicketInfo.DBFileName);
      Table := DB.GetTable(SQL);
      try
        Table.MoveFirst;
        while not Table.EOF do
        begin
          User := Trim(Table.FieldAsString(0));
          if (User <> '') and (AList.IndexOf(User) < 0) then
            AList.Add(User);
          Table.Next;
        end;
      finally
        Table.Free;
      end;
    except
      ;
    end;                
  end;
begin
  Result := False;
  Settings := nil;
  DBSettings := nil;
  List := nil;
  try
    try
      Settings := TRTXSettings.Create;
      Settings.LoadFromIni(HostIniFile);
      DBSettings := TRTXDBSettings.Create;
      DBSettings.LoadFromIni(DBIniFile);

      List := TStringList.Create;
      List.AddStrings(DBSettings.Users);
      if DBSettings.ToOwner and (TicketInfo.Owner <> nil) and
        (Length(TicketInfo.Owner) > 0) then
        AddUsersFromDB(Format(SUserSQL, [TicketInfo.Owner]), List);
      if DBSettings.ToAssigned and (TicketInfo.AssignedTo <> nil) and
        (Length(TicketInfo.AssignedTo) > 0) then
        AddUsersFromDB(Format(SUserSQL, [TicketInfo.AssignedTo]), List);
      if DBSettings.ToAllUser then
        AddUsersFromDB(SAllUsersSQL, List);
      if List.Count = 0 then
      begin
        Log('No RTX user');
        Exit;
      end;

      Log('Users: ' + List.CommaText);

      Text := GetTicketInfoText(TicketInfo, Self);
      Log('Context: ' + Text);

      RTXObj := CreateOleObject('RTXServer.RTXObj');
      RTXObj.ServerIP := Settings.ServerAddress;
      RTXObj.ServerPort := Settings.ServerPort;
      RTXParams := CreateOleObject('RTXServer.Collection');
      RTXParams.Remove('SENDMODE');
      RTXParams.Add('USERNAME', List.CommaText);
      RTXParams.Add('MSGINFO', Text);
      RTXParams.Add('TITLE', ReplaceTicketMacros(TicketInfo, Self, DBSettings.Title));
      RTXParams.Add('DELAYTIME', DBSettings.MsgDelay * 1000);
      if DBSettings.SysMsg then
        RTXParams.Add('TYPE', 1)
      else
        RTXParams.Add('TYPE', 0);
      if DBSettings.ToAllRTXUsers then
        RTXParams.Add('SENDMODE', $1);

      RETCode := RTXObj.Call2($2100, RTXParams);
      
      Log('Send success, RetCode: ' + IntToStr(RETCode));
      Result := True;
    except
      on E: Exception do
      begin
        Log('Exception: ' + E.Message);
      end;
    end;
  finally
    if Assigned(DB) then DB.Free;
    if Assigned(List) then List.Free;
    if Assigned(Settings) then Settings.Free;
    if Assigned(DBSettings) then DBSettings.Free;
  end;
end;

procedure TRTXPlugin.GetPluginInfo(var PluginInfo: TPluginInfo);
begin
  PluginInfo.dwSize := SizeOf(TPluginInfo);
  PluginInfo.Name := PChar(SRTXName);
  PluginInfo.Comment := PChar(SRTXComment);
  PluginInfo.Version := MakeVersion(1, 0, 0, 0);
  PluginInfo.Author := PChar(SCnPack_Zjy);
  PluginInfo.WebSite := PChar(SCnPackUrl);
  PluginInfo.Email := PChar(SCnPackEmail);
end;

procedure TRTXPlugin.LangChanged(LangID: Integer);
begin
  inherited;

  TranslateStr(SRTXName, 'SRTXName');
  TranslateStr(SRTXComment, 'SRTXComment');
  TranslateStr(SRTXTestSucc, 'SRTXTestSucc');
  TranslateStr(SRTXTestError, 'SRTXTestError');
end;

initialization
  PluginClass := TRTXPlugin;
  CoInitialize(nil);

end.

