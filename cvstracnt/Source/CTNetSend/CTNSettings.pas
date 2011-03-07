unit CTNSettings;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：Net Send 设置
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTNSettings.pas,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.04.03
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, IniFiles;

type
  TNetSendDBSettings = class(TObject)
  private
    FUsers: TStrings;
    FAllUsers: Boolean;
    FLoginUsers: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromIni(IniFile: TCustomIniFile);
    procedure SaveToIni(IniFile: TCustomIniFile);

    property AllUsers: Boolean read FAllUsers write FAllUsers;
    property LoginUsers: Boolean read FLoginUsers write FLoginUsers;
    property Users: TStrings read FUsers;
  end;

implementation

{ TNetSendSettings }

const
  csNetSend = 'NetSend';

  csAllUsers = 'AllUsers';
  csLoginUsers = 'LoginUsers';
  csUsers = 'Users';

{ TNetSendDBSettings }

constructor TNetSendDBSettings.Create;
begin
  inherited Create;
  FUsers := TStringList.Create;
end;

destructor TNetSendDBSettings.Destroy;
begin
  FUsers.Free;
  inherited Destroy;
end;

procedure TNetSendDBSettings.LoadFromIni(IniFile: TCustomIniFile);
begin
  AllUsers := IniFile.ReadBool(csNetSend, csAllUsers, False);
  LoginUsers := IniFile.ReadBool(csNetSend, csLoginUsers, False);
  FUsers.CommaText := IniFile.ReadString(csNetSend, csUsers, '');
end;

procedure TNetSendDBSettings.SaveToIni(IniFile: TCustomIniFile);
begin
  IniFile.WriteBool(csNetSend, csAllUsers, AllUsers);
  IniFile.WriteBool(csNetSend, csLoginUsers, LoginUsers);
  IniFile.WriteString(csNetSend, csUsers, FUsers.CommaText);
end;

end.
