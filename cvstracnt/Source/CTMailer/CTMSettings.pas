unit CTMSettings;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：邮件发送设置
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTMSettings.pas,v 1.2 2008/07/10 13:07:47 zjy Exp $
* 更新记录：2005.03.31
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, IniFiles, CTMConsts, CTPluginUtils, CnCommon;

type
  TMailerSettings = class(TObject)
  private
    FNeedAuth: Boolean;
    FPassword: string;
    FSenderMail: string;
    FSenderName: string;
    FSmtpPort: Integer;
    FSmtpServer: string;
    FUserName: string;
    FTimeOut: Integer;
  public
    procedure LoadFromIni(IniFile: TCustomIniFile);
    procedure SaveToIni(IniFile: TCustomIniFile);

    property NeedAuth: Boolean read FNeedAuth write FNeedAuth;
    property Password: string read FPassword write FPassword;
    property SenderMail: string read FSenderMail write FSenderMail;
    property SenderName: string read FSenderName write FSenderName;
    property SmtpPort: Integer read FSmtpPort write FSmtpPort;
    property SmtpServer: string read FSmtpServer write FSmtpServer;
    property UserName: string read FUserName write FUserName;
    property TimeOut: Integer read FTimeOut write FTimeOut;
  end;

  TMailerDBSettings = class(TObject)
  private
    FCopyTo: string;
    FRecipients: string;
    FReplyTo: string;
    FToAllUser: Boolean;
    FToAssigned: Boolean;
    FToContact: Boolean;
    FToOwner: Boolean;
    FTitle: string;
  public
    procedure LoadFromIni(IniFile: TCustomIniFile);
    procedure SaveToIni(IniFile: TCustomIniFile);

    property Title: string read FTitle write FTitle;
    property CopyTo: string read FCopyTo write FCopyTo;
    property Recipients: string read FRecipients write FRecipients;
    property ReplyTo: string read FReplyTo write FReplyTo;
    property ToAllUser: Boolean read FToAllUser write FToAllUser;
    property ToAssigned: Boolean read FToAssigned write FToAssigned;
    property ToOwner: Boolean read FToOwner write FToOwner;
    property ToContact: Boolean read FToContact write FToContact;
  end;

implementation

resourcestring
  SDefSenderName = '[CVSTrac]';

{ TMailerSettings }

const
  csMail = 'Mail';
  
  csSenderMail = 'SenderMail';
  csSenderName = 'SenderName';
  csSmtpServer = 'SmtpServer';
  csSmtpPort = 'SmtpPort';
  csNeedAuth = 'NeedAuth';
  csUserName = 'UserName';
  csUserPass = 'UserPass';
  csPassword = 'Password';
  csTimeOut = 'TimeOut';

  csTitle = 'Title';
  csCopyTo = 'CopyTo';
  csFooter = 'Footer';
  csHeader = 'Header';
  csRecipients = 'Recipients';
  csReplyTo = 'ReplyTo';
  csToAllUser = 'ToAllUser';
  csToAssigned = 'ToAssigned';
  csToOwner = 'ToOwner';
  csToContact = 'ToContact';

function EncodePassword(const S: string): string;
var
  i: Integer;
  Seed: Byte;
begin
  if S <> '' then
  begin
    Seed := Random(255);
    Result := IntToHex(Seed, 2);
    for i := 1 to Length(S) do
    begin
      Result := Result + IntToHex(Seed xor Ord(S[i]), 2);
    end;  
  end;  
end;  

function DecodePassword(const S: string): string;
var
  i: Integer;
  Seed: Byte;
begin
  if (S <> '') and (Length(S) mod 2 = 0) then
  begin
    try
      Seed := StrToInt('$' + Copy(S, 1, 2));
      for i := 1 to Length(S) div 2 - 1 do
      begin
        Result := Result + Char(StrToInt('$' + Copy(S, 1 + 2 * i, 2)) xor Seed);
      end;  
    except
      ;
    end;  
  end;  
end;

procedure TMailerSettings.LoadFromIni(IniFile: TCustomIniFile);
begin
  with IniFile do
  begin
    SenderMail := Trim(ReadString(csMail, csSenderMail, ''));
    SenderName := Trim(ReadString(csMail, csSenderName, SDefSenderName));
    SmtpServer := Trim(ReadString(csMail, csSmtpServer, ''));
    SmtpPort := ReadInteger(csMail, csSmtpPort, 25);
    NeedAuth := ReadBool(csMail, csNeedAuth, False);
    UserName := Trim(ReadString(csMail, csUserName, ''));
    Password := Trim(ReadString(csMail, csUserPass, ''));
    if Password <> '' then
      Password := DecodePassword(Password)
    else // 兼容早期版本的明文密码
      Password := Trim(ReadString(csMail, csPassword, ''));
    TimeOut := ReadInteger(csMail, csTimeOut, csConnectTimeOut);
  end;
end;

procedure TMailerSettings.SaveToIni(IniFile: TCustomIniFile);
begin
  with IniFile do
  begin
    WriteString(csMail, csSenderMail, SenderMail);
    WriteString(csMail, csSenderName, SenderName);
    WriteString(csMail, csSmtpServer, SmtpServer);
    WriteInteger(csMail, csSmtpPort, SmtpPort);
    WriteBool(csMail, csNeedAuth, NeedAuth);
    WriteString(csMail, csUserName, UserName);
    WriteString(csMail, csUserPass, EncodePassword(Password));
    DeleteKey(csMail, csPassword);
    WriteInteger(csMail, csTimeOut, TimeOut);
  end;
end;

{ TMailerDBSettings }

procedure TMailerDBSettings.LoadFromIni(IniFile: TCustomIniFile);
begin
  with IniFile do
  begin
    Title := ReadString(csMail, csTitle, SDefaultTitle);
    CopyTo := ReadString(csMail, csCopyTo, '');
    Recipients := ReadString(csMail, csRecipients, '');
    ReplyTo := ReadString(csMail, csReplyTo, '');
    ToAllUser := ReadBool(csMail, csToAllUser, False);
    ToAssigned := ReadBool(csMail, csToAssigned, True);
    ToOwner := ReadBool(csMail, csToOwner, True);
    ToContact := ReadBool(csMail, csToContact, True);
  end;
end;

procedure TMailerDBSettings.SaveToIni(IniFile: TCustomIniFile);
begin
  with IniFile do
  begin
    WriteString(csMail, csTitle, Title);
    WriteString(csMail, csCopyTo, CopyTo);
    WriteString(csMail, csRecipients, Recipients);
    WriteString(csMail, csReplyTo, ReplyTo);
    WriteBool(csMail, csToAllUser, ToAllUser);
    WriteBool(csMail, csToAssigned, ToAssigned);
    WriteBool(csMail, csToOwner, ToOwner);
    WriteBool(csMail, csToContact, ToContact);
  end;
end;

initialization
  Randomize;

end.
