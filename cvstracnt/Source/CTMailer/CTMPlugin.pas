unit CTMPlugin;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：邮件通知插件单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTMPlugin.pas,v 1.5 2008/07/10 13:07:47 zjy Exp $
* 更新记录：2005.03.31
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, IniFiles, CTPluginIntf, CTPlugin,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdMessageClient,
  IdMessage, IdSMTP, IdCoderHeader, SQLite3, SQLiteTable3, CnCommon, CnConsts,
  CTMultiLangPlugin, CnLangMgr, CTMConsts;

type
  TMailerPlugin = class(TMultiLangPlugin)
  private
    procedure OnInitializeISO(var VTransferHeader: TTransfer;
      var VHeaderEncoding: Char; var VCharSet: string);
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

uses CTMDatabaseFrm, CTMOptionFrm, CTMSettings, CTPluginUtils;

resourcestring
  SUserEmailSQL = 'SELECT email FROM user WHERE id="%s"';
  SAllUserEmailSQL = 'SELECT email FROM user';
    
{ TMailerPlugin }

function TMailerPlugin.ConfigDatabase(Owner: HWND; IniFile: TCustomIniFile;
  const DBName, DBFileName: string): Boolean;
var
  Settings: TMailerDBSettings;
begin
  Settings := TMailerDBSettings.Create;
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

function TMailerPlugin.ConfigPlugin(Owner: HWND;
  IniFile: TCustomIniFile): Boolean;
var
  Settings: TMailerSettings;
begin
  Settings := TMailerSettings.Create;
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

procedure TMailerPlugin.OnInitializeISO(var VTransferHeader: TTransfer;
  var VHeaderEncoding: Char; var VCharSet: string);
begin
  // 8bit Support
  VHeaderEncoding := '8';
  VCharSet := SCharSet;
end;

function TMailerPlugin.Execute(HostIniFile, DBIniFile: TCustomIniFile;
  TicketInfo: TTicketInfo): Boolean;
var
  Settings: TMailerSettings;
  DBSettings: TMailerDBSettings;
  IdSmtp: TIdSMTP;
  IdMessage: TIdMessage;
  DB: TSQLiteDatabase;

  procedure GetEmailList(Text: string; AList: TStrings);
  var
    i: Integer;
  begin
    AList.Clear;
    Text := StringReplace(Text, ';', ',', [rfReplaceAll]);
    AList.CommaText := Text;
    for i := AList.Count - 1 downto 0 do
    begin
      AList[i] := Trim(AList[i]);
      if not IsValidEmail(AList[i]) then
        AList.Delete(i);
    end;
  end;

  procedure AddEmailFromDB(const SQL: string; AList: TStrings);
  var
    Table: TSQLiteTable;
    Addr: string;
  begin
    try
      if not Assigned(DB) then
        DB := TSQLiteDatabase.Create(TicketInfo.DBFileName);
      Table := DB.GetTable(SQL);
      try
        Table.MoveFirst;
        while not Table.EOF do
        begin
          Addr := Trim(Table.FieldAsString(0));
          if IsValidEmail(Addr) and (AList.IndexOf(Addr) < 0) then
            AList.Add(Addr);
          Table.Next;
        end;
      finally
        Table.Free;
      end;
    except
      ;
    end;                
  end;

  procedure SetMessageParams;
  var
    i: Integer;
    List: TStringList;
  begin
    List := TStringList.Create;
    try
      with IdMessage.From do
      begin
        Address := Settings.SenderMail;
        Name := Settings.SenderName;
      end;
      Log('Sender: ' + Settings.SenderMail);

      GetEmailList(DBSettings.Recipients, List);
      if DBSettings.ToOwner and (TicketInfo.Owner <> nil) and
        (Length(TicketInfo.Owner) > 0) then
        AddEmailFromDB(Format(SUserEmailSQL, [TicketInfo.Owner]), List);
      if DBSettings.ToAssigned and (TicketInfo.AssignedTo <> nil) and
        (Length(TicketInfo.AssignedTo) > 0) then
        AddEmailFromDB(Format(SUserEmailSQL, [TicketInfo.AssignedTo]), List);
      if DBSettings.ToAllUser then
        AddEmailFromDB(SAllUserEmailSQL, List);
      Log('Recipients: ' + List.CommaText);
      for i := 0 to List.Count - 1 do
        with IdMessage.Recipients.Add do
        begin
          Address := List[i];
        end;

      GetEmailList(DBSettings.ReplyTo, List);
      if List.Count > 0 then
      begin
        Log('ReplyTo: ' + List.CommaText);
        for i := 0 to List.Count - 1 do
          with IdMessage.ReplyTo.Add do
          begin
            Address := List[i];
          end;
      end
      else
      begin
        with IdMessage.ReplyTo.Add do
        begin
          Address := Settings.SenderMail;
          Name := Settings.SenderName;
        end;
      end;

      GetEmailList(DBSettings.CopyTo, List);
      Log('CopyTo: ' + List.CommaText);
      for i := 0 to List.Count - 1 do
        with IdMessage.CCList.Add do
        begin
          Address := List[i];
        end;
    finally
      List.Free;
    end;
  end;
begin
  Log('Start send mail');
  Result := False;
  Settings := nil;
  DBSettings := nil;
  IdSmtp := nil;
  IdMessage := nil;
  DB := nil;
  try
    try
      Settings := TMailerSettings.Create;
      Settings.LoadFromIni(HostIniFile);
      DBSettings := TMailerDBSettings.Create;
      DBSettings.LoadFromIni(DBIniFile);

      if not IsValidEmail(Settings.SenderMail) then
      begin
        Log('Invalid sender mail.');
        Exit;
      end;

      if Settings.SmtpServer = '' then
      begin
        Log('Invalid smtp server.');
        Exit;
      end;

      IdMessage := TIdMessage.Create(nil);
      IdMessage.CharSet := SCharSet;
      IdMessage.OnInitializeISO := OnInitializeISO;

      SetMessageParams;

      if IdMessage.Recipients.Count = 0 then
      begin
        Log('No Recipient!');
        Exit;
      end;

      IdMessage.Body.Text := GetTicketInfoText(TicketInfo, Self);
      Log('Mail Body: ' + IdMessage.Body.Text);

      IdMessage.Subject := ReplaceTicketMacros(TicketInfo, Self, DBSettings.Title);

      IdSmtp := TIdSMTP.Create(nil);
      with IdSmtp do
      begin
        Host := Settings.SmtpServer;
        Port := Settings.SmtpPort;
        Username := Settings.UserName;
        Password := Settings.PassWord;
        if Settings.NeedAuth then
          AuthenticationType := atLogin
        else
          AuthenticationType := atNone;
        Connect(Settings.TimeOut * 1000);
        Log('Login success');
        Send(IdMessage);
      end;

      Log('Send success');
      Result := True;
    except
      on E: Exception do
      begin
        Log('Exception: ' + E.Message);
        if Assigned(IdSmtp) and IdSmtp.Connected then
          IdSmtp.Disconnect;
      end;
    end;
  finally
    if Assigned(Settings) then Settings.Free;
    if Assigned(DBSettings) then DBSettings.Free;
    if Assigned(IdSmtp) then IdSmtp.Free;
    if Assigned(IdMessage) then IdMessage.Free;
    if Assigned(DB) then DB.Free;
  end;
end;

procedure TMailerPlugin.GetPluginInfo(var PluginInfo: TPluginInfo);
begin
  PluginInfo.dwSize := SizeOf(TPluginInfo);
  PluginInfo.Name := PChar(SMailerName);
  PluginInfo.Comment := PChar(SMailerComment);
  PluginInfo.Version := MakeVersion(1, 2, 0, 0);
  PluginInfo.Author := PChar(SCnPack_Zjy);
  PluginInfo.WebSite := PChar(SCnPackUrl);
  PluginInfo.Email := PChar(SCnPackEmail);
end;

procedure TMailerPlugin.LangChanged(LangID: Integer);
begin
  inherited;

  TranslateStr(SMailerName, 'SMailerName');
  TranslateStr(SMailerComment, 'SMailerComment');
  TranslateStr(SBeginTest, 'SBeginTest');
  TranslateStr(SBeginConnect, 'SBeginConnect');
  TranslateStr(SBeginLogin, 'SBeginLogin');
  TranslateStr(STestSucc, 'STestSucc');
  TranslateStr(SLoginFail, 'SLoginFail');
  TranslateStr(STestFail, 'STestFail');
  TranslateStr(SCharSet, 'SCharSet');
end;

initialization
  PluginClass := TMailerPlugin;

end.



