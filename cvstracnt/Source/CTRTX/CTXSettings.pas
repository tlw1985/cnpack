unit CTXSettings;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：RTX设置
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTXSettings.pas,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.03.31
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, IniFiles, CTXConsts, CTPluginUtils, CnCommon;

type
  TRTXSettings = class(TObject)
  private
    FServerAddress: string;
    FServerPort: Integer;
  public
    procedure LoadFromIni(IniFile: TCustomIniFile);
    procedure SaveToIni(IniFile: TCustomIniFile);
    
    property ServerAddress: string read FServerAddress write FServerAddress;
    property ServerPort: Integer read FServerPort write FServerPort;
  end;

  TRTXDBSettings = class(TObject)
  private
    FToAllUser: Boolean;
    FToAssigned: Boolean;
    FToContact: Boolean;
    FToOwner: Boolean;
    FUsers: TStrings;
    FTitle: string;
    FSysMsg: Boolean;
    FMsgDelay: Integer;
    FToAllRTXUsers: Boolean;
  public
    procedure LoadFromIni(IniFile: TCustomIniFile);
    procedure SaveToIni(IniFile: TCustomIniFile);
    constructor Create;
    destructor Destroy; override;

    property Users: TStrings read FUsers;
    property ToAllRTXUsers: Boolean read FToAllRTXUsers write FToAllRTXUsers;
    property ToAllUser: Boolean read FToAllUser write FToAllUser;
    property ToAssigned: Boolean read FToAssigned write FToAssigned;
    property ToContact: Boolean read FToContact write FToContact;
    property ToOwner: Boolean read FToOwner write FToOwner;
    property Title: string read FTitle write FTitle;
    property SysMsg: Boolean read FSysMsg write FSysMsg;
    property MsgDelay: Integer read FMsgDelay write FMsgDelay;
  end;

implementation

{ TRTXSettings }

const
  csRTX = 'RTX';
  csServerAddress = 'ServerAddress';
  csServerPort = 'ServerPort';

  csToAllRTXUser = 'ToAllRTXUser';
  csToAllUser = 'ToAllUser';
  csToAssigned = 'ToAssigned';
  csToOwner = 'ToOwner';
  csToContact = 'ToContact';
  csUsers = 'Users';
  csTitle = 'Title';
  csSysMsg = 'SysMsg';
  csMsgDelay = 'MsgDelay';
  
procedure TRTXSettings.LoadFromIni(IniFile: TCustomIniFile);
begin
  with IniFile do
  begin
    ServerAddress := Trim(ReadString(csRTX, csServerAddress, '127.0.0.1'));
    ServerPort := ReadInteger(csRTX, csServerPort, 6000);
  end;
end;

procedure TRTXSettings.SaveToIni(IniFile: TCustomIniFile);
begin
  with IniFile do
  begin
    WriteString(csRTX, csServerAddress, ServerAddress);
    WriteInteger(csRTX, csServerPort, ServerPort);
  end;
end;

{ TRTXDBSettings }

constructor TRTXDBSettings.Create;
begin
  inherited Create;
  FUsers := TStringList.Create;
end;

destructor TRTXDBSettings.Destroy;
begin
  FUsers.Free;
  inherited Destroy;
end;

procedure TRTXDBSettings.LoadFromIni(IniFile: TCustomIniFile);
begin
  with IniFile do
  begin
    ToAllRTXUsers := ReadBool(csRTX, csToAllRTXUser, False);
    ToAllUser := ReadBool(csRTX, csToAllUser, False);
    ToAssigned := ReadBool(csRTX, csToAssigned, True);
    ToOwner := ReadBool(csRTX, csToOwner, True);
    ToContact := ReadBool(csRTX, csToContact, True);
    FUsers.CommaText := ReadString(csRTX, csUsers, '');
    Title := ReadString(csRTX, csTitle, SDefaultTitle);
    SysMsg := ReadBool(csRTX, csSysMsg, True);
    MsgDelay := ReadInteger(csRTX, csMsgDelay, 0);
  end;
end;

procedure TRTXDBSettings.SaveToIni(IniFile: TCustomIniFile);
begin
  with IniFile do
  begin
    WriteBool(csRTX, csToAllRTXUser, ToAllRTXUsers);
    WriteBool(csRTX, csToAllUser, ToAllUser);
    WriteBool(csRTX, csToAssigned, ToAssigned);
    WriteBool(csRTX, csToOwner, ToOwner);
    WriteBool(csRTX, csToContact, ToContact);
    WriteString(csRTX, csUsers, FUsers.CommaText);
    WriteString(csRTX, csTitle, Title);
    WriteBool(csRTX, csSysMsg, SysMsg);
    WriteInteger(csRTX, csMsgDelay, MsgDelay);
  end;
end;

end.
