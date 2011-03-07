unit CTPluginMgr;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：插件定义
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：插件管理器单元
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTPluginMgr.pas,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.03.30
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Contnrs, IniFiles, CnCommon, CTConsts,
  CTPluginIntf, CTUtils;

type
  TPluginDll = class(TObject)
  private
    FPluginIntf: TPluginIntf;
    FFileName: string;
    FHandle: HMODULE;
    function GetPluginID: string;
  public
    constructor Create;
    destructor Destroy; override;

    function LoadPlugin(const AFileName: string): Boolean;
    procedure FreePlugin;
    
    function GetPluginInfo: TPluginInfo;
    function Execute(const IniFileName: string; TicketInfo: TTicketInfo): Boolean;
    function ConfigPlugin(Owner: HWND): Boolean;
    function ConfigDatabase(Owner: HWND; const DBName, DBFileName,
      IniFileName: string): Boolean;
    function CanConfigPlugin: Boolean;
    function CanConfigDatabase: Boolean;
    procedure LangChanged(LangID: Integer);

    property PluginID: string read GetPluginID;
    property FileName: string read FFileName;
    property Handle: HMODULE read FHandle;
  end;

  TLogEvent = procedure (const Text: string) of object;
  TGetPluginEvent = procedure (const PluginID, FileName: string;
    var Enabled: Boolean) of object;

  TPluginMgr = class(TObject)
  private
    FList: TObjectList;
    FDBPath: string;
    FLangPath: string;
    FOnLog: TLogEvent;
    FOnGetPlugin: TGetPluginEvent;
    function GetCount: Integer;
    function GetPlugins(Index: Integer): TPluginDll;
    procedure DoFindPlugin(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    function PluginEnabled(const FileName: string): Boolean;
    function GetLangID: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Log(const Text: string);
    procedure LoadPlugins;
    procedure FreePlugins;
    property Plugins[Index: Integer]: TPluginDll read GetPlugins; default;
    property Count: Integer read GetCount;

    property DBPath: string read FDBPath write FDBPath;
    property LangPath: string read FLangPath write FLangPath;
    property LangID: Integer read GetLangID;
    property OnLog: TLogEvent read FOnLog write FOnLog;
    property OnGetPlugin: TGetPluginEvent read FOnGetPlugin write FOnGetPlugin;
  end;

function PluginMgr: TPluginMgr;

implementation

var
  HostIntf: THostIntf;
  FPluginMgr: TPluginMgr;

function PluginMgr: TPluginMgr;
begin
  if FPluginMgr = nil then
    FPluginMgr := TPluginMgr.Create;
  Result := FPluginMgr;
end;

function PluginFileNameToID(const FileName: string): string;
begin
  Result := ChangeFileExt(ExtractFileName(FileName), '');
end;

{ TPluginDll }

function TPluginDll.CanConfigDatabase: Boolean;
begin
  Result := Assigned(FPluginIntf.ConfigDatabase);
end;

function TPluginDll.CanConfigPlugin: Boolean;
begin
  Result := Assigned(FPluginIntf.ConfigPlugin);
end;

function TPluginDll.ConfigDatabase(Owner: HWND; const DBName, DBFileName,
  IniFileName: string): Boolean;
begin
  if Assigned(FPluginIntf.ConfigDatabase) then
    Result := FPluginIntf.ConfigDatabase(Owner, PChar(DBName), PChar(DBFileName),
      PChar(IniFileName))
  else
    Result := False;
end;

function TPluginDll.ConfigPlugin(Owner: HWND): Boolean;
begin
  if Assigned(FPluginIntf.ConfigPlugin) then
    Result := FPluginIntf.ConfigPlugin(Owner)
  else
    Result := False;
end;

constructor TPluginDll.Create;
begin
  inherited Create;
  FHandle := 0;
end;

destructor TPluginDll.Destroy;
begin
  FreePlugin;
  inherited;
end;

function TPluginDll.Execute(const IniFileName: string; TicketInfo:
  TTicketInfo): Boolean;
begin
  if Assigned(FPluginIntf.Execute) then
    Result := FPluginIntf.Execute(PChar(IniFileName), @TicketInfo)
  else
    Result := False;
end;

procedure TPluginDll.FreePlugin;
begin
  if FHandle <> 0 then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
  end;
end;

function TPluginDll.GetPluginID: string;
begin
  Result := PluginFileNameToID(FileName);
end;

function TPluginDll.GetPluginInfo: TPluginInfo;
begin
  if Assigned(FPluginIntf.GetPluginInfo) then
    Result := FPluginIntf.GetPluginInfo()^;
end;

procedure TPluginDll.LangChanged(LangID: Integer);
begin
  if Assigned(FPluginIntf.LangChanged) then
    FPluginIntf.LangChanged(LangID);
end;

function TPluginDll.LoadPlugin(const AFileName: string): Boolean;
var
  PluginInitProc: TPluginInitProc;
  APluginIntf: PPluginIntf;
begin
  Result := False;
  try
    FFileName := AFileName;
    FHandle := LoadLibrary(PChar(AFileName));
    Win32Check(FHandle <> 0);

    PluginInitProc := GetProcAddress(FHandle, csPluginExportProc);
    Win32Check(Assigned(PluginInitProc));
    
    PluginInitProc(@HostIntf, APluginIntf);
    FPluginIntf := APluginIntf^;
    Result := True;
  except
    ;
  end;
end;

{ TPluginMgr }

function _GetDBPath: PChar; stdcall;
begin
  Result := PChar(PluginMgr.FDBPath);
end;

function _GetLangPath: PChar; stdcall;
begin
  Result := PChar(PluginMgr.FLangPath);
end;

function _GetLangID: Integer; stdcall;
begin
  Result := PluginMgr.LangID;
end;

procedure _Log(Text: PChar); stdcall;
begin
  PluginMgr.Log(Text);
end;

constructor TPluginMgr.Create;
begin
  inherited Create;
  FList := TObjectList.Create;

  FDBPath := CTUtils.LoadSettingsFromIni.DBPath;
  FLangPath := MakePath(AppPath + csLangDirName);

  HostIntf.dwSize := SizeOf(THostIntf);
  HostIntf.Version := MakeVersion(1, 0, 0, 0);
  HostIntf.GetDBPath := _GetDBPath;
  HostIntf.GetLangPath := _GetLangPath;
  HostIntf.GetLangID := _GetLangID;
  HostIntf.Log := _Log;
end;

destructor TPluginMgr.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TPluginMgr.DoFindPlugin(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  PluginDll: TPluginDll;
begin
  if PluginEnabled(FileName) then
  begin
    PluginDll := TPluginDll.Create;
    if PluginDll.LoadPlugin(FileName) then
      FList.Add(PluginDll)
    else
      PluginDll.Free;
  end;
end;

procedure TPluginMgr.FreePlugins;
begin
  FList.Clear;
end;

function TPluginMgr.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPluginMgr.GetPlugins(Index: Integer): TPluginDll;
begin
  Result := TPluginDll(FList[Index]);
end;

function TPluginMgr.GetLangID: Integer;
begin
  Result := CTUtils.LoadSettingsFromIni.LangID;
end;

procedure TPluginMgr.LoadPlugins;
begin
  FreePlugins;
  FindFile(AppPath + csPluginDirName, '*.dll', DoFindPlugin, nil, False, False);
end;

procedure TPluginMgr.Log(const Text: string);
begin
  if Assigned(FOnLog) then
    FOnLog(Text);
end;

function TPluginMgr.PluginEnabled(const FileName: string): Boolean;
begin
  Result := True;
  if Assigned(FOnGetPlugin) then
    FOnGetPlugin(PluginFileNameToID(FileName), FileName, Result);
end;

initialization

finalization
  if FPluginMgr <> nil then
    FreeAndNil(FPluginMgr);

end.

