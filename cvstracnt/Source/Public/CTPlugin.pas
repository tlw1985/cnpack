unit CTPlugin;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：插件定义
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：插件基础单元
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTPlugin.pas,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.03.30
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, IniFiles, CTPluginIntf, CnConsts;

type
  TPlugin = class(TPersistent)
  private
    FPluginInfo: TPluginInfo;
    FPluginIntf: TPluginIntf;
    FHostIntf: PHostIntf;
  protected
    procedure GetPluginInfo(var PluginInfo: TPluginInfo); virtual; abstract;
    function Execute(HostIniFile, DBIniFile: TCustomIniFile; TicketInfo:
      TTicketInfo): Boolean; virtual; abstract;
    procedure LangChanged(LangID: Integer); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Loaded; virtual;
    
    function GetLangID: Integer;
    function GetLangPath: string;
    function GetHostVersion: TVersion;
    function GetDBPath: string;
    function GetIniFileName: string;
    procedure Log(const Text: string);
  published
    function ConfigPlugin(Owner: HWND; IniFile: TCustomIniFile): Boolean; virtual;
    function ConfigDatabase(Owner: HWND; IniFile: TCustomIniFile;
      const DBName, DBFileName: string): Boolean; virtual;
  end;

  TPluginClass = class of TPlugin;

var
  PluginClass: TPluginClass;

function PluginInitProc(HostIntf: PHostIntf; var PluginIntf: PPluginInfo):
  Boolean; stdcall;

exports
  PluginInitProc name csPluginExportProc;

implementation

var
  Plugin: TPlugin;

function PluginInitProc(HostIntf: PHostIntf; var PluginIntf: PPluginInfo):
  Boolean; stdcall;
begin
  Assert(PluginClass <> nil, 'PluginClass is nil.');
  Plugin := PluginClass.Create;
  Plugin.FHostIntf := HostIntf;
  PluginIntf := @Plugin.FPluginIntf;
  Plugin.Loaded;
  Plugin.LangChanged(HostIntf.GetLangID);
  Result := True;
end;

{ TPlugin }

function GetPluginInfoProc: PPluginInfo; stdcall;
begin
  Assert(Assigned(Plugin));
  Plugin.FPluginInfo.dwSize := SizeOf(TPluginInfo);
  Plugin.FPluginInfo.Version := MakeVersion(1, 0, 0, 0);
  Plugin.FPluginInfo.Author := PChar(SCnPackAbout);
  Plugin.FPluginInfo.WebSite := PChar(SCnPackUrl);
  Plugin.FPluginInfo.Email := PChar(SCnPackEmail);
  Plugin.GetPluginInfo(Plugin.FPluginInfo);
  
  Result := @Plugin.FPluginInfo;
end;

function ConfigPluginProc(Owner: HWND): BOOL; stdcall;
var
  IniFile: TIniFile;
begin
  Assert(Assigned(Plugin));
  IniFile := TIniFile.Create(Plugin.GetIniFileName);
  try
    Application.Handle := Owner;
    Result := Plugin.ConfigPlugin(Owner, IniFile);
  finally
    IniFile.Free;
  end;
end;

function ConfigDatabaseProc(Owner: HWND; DBName, DBFileName,
  IniFileName: PChar): BOOL; stdcall;
var
  IniFile: TIniFile;
begin
  Assert(Assigned(Plugin));
  IniFile := TIniFile.Create(IniFileName);
  try
    Application.Handle := Owner;
    Result := Plugin.ConfigDatabase(Owner, IniFile, DBName, DBFileName);
  finally
    IniFile.Free;
  end;
end;

function PluginExecuteProc(IniFileName: PChar; TicketInfo: PTicketInfo): BOOL; stdcall;
var
  HostIniFile, DBIniFile: TIniFile;
begin
  Assert(Assigned(Plugin));
  HostIniFile := TIniFile.Create(Plugin.GetIniFileName);
  try
    DBIniFile := TIniFile.Create(IniFileName);
    try
      Result := Plugin.Execute(HostIniFile, DBIniFile, TicketInfo^);
    finally
      DBIniFile.Free;
    end;
  finally
    HostIniFile.Free;
  end;
end;

procedure LangChangedProc(LangID: Integer); stdcall;
begin
  Assert(Assigned(Plugin));
  Plugin.LangChanged(LangID);
end;

function TPlugin.ConfigDatabase(Owner: HWND; IniFile: TCustomIniFile;
  const DBName, DBFileName: string): Boolean;
begin
  Result := True;
end;

function TPlugin.ConfigPlugin(Owner: HWND; IniFile: TCustomIniFile): Boolean;
begin
  Result := True;
end;

constructor TPlugin.Create;
const
  csConfigPlugin = 'ConfigPlugin';
  csConfigDatabase = 'ConfigDatabase';
begin
  inherited Create;
  FPluginIntf.dwSize := SizeOf(TPluginIntf);
  FPluginIntf.GetPluginInfo := GetPluginInfoProc;
  FPluginIntf.Execute := PluginExecuteProc;
  FPluginIntf.LangChanged := LangChangedProc;
  if MethodAddress(csConfigPlugin) <> TPlugin.MethodAddress(csConfigPlugin) then
    FPluginIntf.ConfigPlugin := ConfigPluginProc;
  if MethodAddress(csConfigDatabase) <> TPlugin.MethodAddress(csConfigDatabase) then
    FPluginIntf.ConfigDatabase := ConfigDatabaseProc;
end;

destructor TPlugin.Destroy;
begin
  inherited Destroy;
end;

function TPlugin.GetDBPath: string;
begin
  Result := FHostIntf.GetDBPath;
end;

function TPlugin.GetHostVersion: TVersion;
begin
  Result := FHostIntf.Version;
end;

function TPlugin.GetIniFileName: string;
begin
  Result := ChangeFileExt(GetModuleName(HInstance), '.ini');
end;

function TPlugin.GetLangID: Integer;
begin
  Result := FHostIntf.GetLangID;
end;

function TPlugin.GetLangPath: string;
begin
  Result := FHostIntf.GetLangPath;
end;

procedure TPlugin.LangChanged(LangID: Integer);
begin
  // Do nothing
end;

procedure TPlugin.Loaded;
begin

end;

procedure TPlugin.Log(const Text: string);
begin
  FHostIntf.Log(PChar(Text));
end;

initialization

finalization
  if Assigned(Plugin) then FreeAndNil(Plugin);

end.



