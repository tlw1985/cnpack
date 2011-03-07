unit CTSMain;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT 服务程序
* 单元名称：服务单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：该单元实现了调用 cvstrac.exe 的服务类
* 开发平台：PWindows Server 2003 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTSMain.pas,v 1.3 2005/09/16 02:16:14 zjy Exp $
* 更新记录：2003.11.15
*               修改 cvstrac 运行方式，只运行一个实例
*           2003.11.09
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  CTConsts, CTUtils, ExtCtrls, CnCommon;

type
  TCVSTracService = class(TService)
    tmrBackup: TTimer;
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure tmrBackupTimer(Sender: TObject);
  private
    { Private declarations }
    HProcess: THandle;
  public
    { Public declarations }
    function GetServiceController: TServiceController; override;
  end;

var
  CVSTracService: TCVSTracService;

implementation

{$R *.DFM}

uses
  IniFiles;

{$IFDEF DEBUG}
var
  LogFile: TFileStream;
{$ENDIF}

procedure Log(const Msg: string);
{$IFDEF DEBUG}
var
  Buff: string;
{$ENDIF}
begin
{$IFDEF DEBUG}
  Buff := Msg + #13#10;
  LogFile.Write(PChar(Buff)^, Length(Buff));
{$ENDIF}
end;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  CVSTracService.Controller(CtrlCode);
end;

function DoExec(const FileName: string; WorkDir: string = ''): THandle;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  if WorkDir = '' then
    WorkDir := ExtractFilePath(ParamStr(0));
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);

  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;
  if CreateProcess(nil, PChar(FileName), nil, nil, False, CREATE_NEW_CONSOLE or
    NORMAL_PRIORITY_CLASS, nil, PChar(WorkDir), StartupInfo, ProcessInfo) then
    Result := ProcessInfo.hProcess
  else
    Result := 0;
end;

function LongNameToShortName(const FileName: string): string;
var
  Buf: PChar;
  BufSize: Integer;
begin
  BufSize := GetShortPathName(PChar(FileName), nil, 0) + 1;
  GetMem(Buf, BufSize);
  try
    GetShortPathName(PChar(FileName), Buf, BufSize);
    Result := Buf;
  finally
    FreeMem(Buf);
  end;
end;

procedure TCVSTracService.ServiceCreate(Sender: TObject);
const
  csPath = 'PATH';
var
  AppDir: string;
  Path: string;
  R: Cardinal;
begin
  // 在 Path 路径中加入当前目录以支持 cvstrac 运行时调用外部命令
  AppDir := LongNameToShortName(ExtractFileDir(ParamStr(0)));
  R := GetEnvironmentVariable(PChar(csPath), nil, 0);
  SetLength(Path, R);
  GetEnvironmentVariable(PChar(csPath), PChar(Path), R);
  SetEnvironmentVariable(csPath, PChar(AppDir + ';' + Path));
  tmrBackupTimer(nil);
end;

function TCVSTracService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TCVSTracService.ServiceStart(Sender: TService;
  var Started: Boolean);
var
  FmtStr: string;
  FileName: string;
  Settings: TSettingsInfo;
  ExitCode: Cardinal;
begin
  Started := False;

{$IFDEF DEBUG}
  Log('FmtStr: ' + FmtStr);
{$ENDIF}
  Settings := LoadSettingsFromIni;
  FmtStr := '"' + ExtractFilePath(ParamStr(0)) + Settings.ExeName + '" server %d "%s"';
  FileName := Format(FmtStr, [Settings.Port, Settings.DBPath]);
{$IFDEF DEBUG}
  Log(Format('Port: %d, Home: %s', [Settings.Port, Settings.DBPath]));
  Log('FileName: ' + FileName);
{$ENDIF}
  HProcess := DoExec(FileName, ExtractFilePath(ParamStr(0)));
  if HProcess = 0 then
  begin
  {$IFDEF DEBUG}
    Log('CreateProcess Error: ' + FileName);
  {$ENDIF}
    LogMessage('CreateProcess Error: ' + FileName);
  end;

  if HProcess <> 0 then
  begin
    // 延时 1 秒等待 CVSTrac 运行稳定（如果出错会自动关闭）
    Sleep(1000);
    GetExitCodeProcess(HProcess, ExitCode);
    if ExitCode = STILL_ACTIVE then
      Started := True
    else
    begin
    {$IFDEF DEBUG}
      Log('Start CVSTrac Error: ' + FileName);
    {$ENDIF}
      LogMessage('Start CVSTrac Error: ' + FileName);
    end;
  end;
end;

procedure TCVSTracService.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
  if not TerminateProcess(HProcess, 0) then
  begin
  {$IFDEF DEBUG}
    Log('TerminateProcess Error.');
  {$ENDIF}
    LogMessage('TerminateProcess Error.');
  end;

  Stopped := True;
end;

procedure TCVSTracService.tmrBackupTimer(Sender: TObject);
begin
  BackupDataBase(False);
end;

initialization
{$IFDEF DEBUG}
  LogFile := TFileStream.Create(ChangeFileExt(ParamStr(0), '.log'), fmCreate);
  Log('Application Start: ' + DateTimeToStr(Now));
{$ENDIF}

finalization
{$IFDEF DEBUG}
  Log('Application End: ' + DateTimeToStr(Now));
  LogFile.Free;
{$ENDIF}

end.


