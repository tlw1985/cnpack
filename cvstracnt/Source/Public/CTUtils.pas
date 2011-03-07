unit CTUtils;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：公共过程单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows Server 2003 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTUtils.pas,v 1.3 2005/09/16 02:16:14 zjy Exp $
* 更新记录：2003.12.13
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, IniFiles, CnCommon, CTConsts;

type
  PSettingsInfo = ^TSettingsInfo;
  TSettingsInfo = record
    DBPath: string;
    LocalServer: string;
    Port: Integer;
    LangID: Integer;
    ExeName: string;
    EnableLog: Boolean;
    EnableBackup: Boolean;
    BackupCount: Integer;
  end;

  TBackupDatabase = class
  private
    FMaxBackupCount: Integer;
    function GetLastBackupDate: TDateTime;
    procedure SetLastBackupDate(const Value: TDateTime);
  protected
    procedure DoBackupFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
  public
    procedure DoBackupDataBase(ForceBackup: Boolean);
    property LastBackupDate: TDateTime read GetLastBackupDate write SetLastBackupDate;
  end;

function GetIniFileName: string;
function LoadSettingsFromIni: TSettingsInfo;
procedure SaveSettingsToIni(SettingsInfo: TSettingsInfo);

function DataBaseFileNameToDBName(const FileName: string): string;
function DataBaseFileNameToIniName(const FileName: string): string;

function GetBackupName(const FileName: string; Idx: Integer): string;
procedure BackupDataBase(ForceBackup: Boolean);

implementation

const
  csSetup = 'Setup';
  csPort = 'Port';
  csLangID = 'LangID';
  csExeName = 'ExeName';
  csDBPath = 'DBPath';
  csLocalServer = 'LocalServer';
  csEnableLog = 'EnableLog';
  csBackup = 'Backup';
  
  csEnableBackup = 'EnableBackup';
  csBackupCount = 'BackupCount';
  csLastBackupDate = 'LastBackupDate';

function GetIniFileName: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + csIniName;
end;

function LoadSettingsFromIni: TSettingsInfo;
begin
  with Result do
  begin
    with TIniFile.Create(GetIniFileName) do
    try
      DBPath := Trim(ReadString(csSetup, csDBPath, ''));
      if DBPath = '' then
        DBPath := ExtractFilePath(ParamStr(0)) + csDBDirName;
      CreateDir(DBPath);
      Port := ReadInteger(csSetup, csPort, csDefaultPort);
      LangID := ReadInteger(csSetup, csLangID, GetSystemDefaultLCID);
      ExeName := ReadString(csSetup, csExeName, SExeName);
      LocalServer := Trim(ReadString(csSetup, csLocalServer, ''));
      while (LocalServer <> '') and (LocalServer[Length(LocalServer)] = '/') do
        Delete(LocalServer, Length(LocalServer), 1);
      EnableLog := ReadBool(csSetup, csEnableLog, False);
      
      EnableBackup := ReadBool(csBackup, csEnableBackup, True);
      BackupCount := ReadInteger(csBackup, csBackupCount, csDefBackupCount);
    finally
      Free;
    end;
  end;
end;

procedure SaveSettingsToIni(SettingsInfo: TSettingsInfo);
var
  Home: string;
begin
  with SettingsInfo do
  begin
    with TIniFile.Create(GetIniFileName) do
    try
      if SameText(DBPath, ExtractFilePath(ParamStr(0)) + csDBDirName) then
        Home := ''
      else
        Home := DBPath;
      WriteString(csSetup, csDBPath, Home);
      WriteInteger(csSetup, csPort, Port);
      WriteInteger(csSetup, csLangID, LangID);
      WriteString(csSetup, csExeName, ExeName);
      WriteString(csSetup, csLocalServer, LocalServer);
      WriteBool(csSetup, csEnableLog, EnableLog);

      WriteBool(csBackup, csEnableBackup, EnableBackup);
      WriteInteger(csBackup, csBackupCount, BackupCount);
    finally
      Free;
    end;
  end;
end;

function DataBaseFileNameToDBName(const FileName: string): string;
begin
  Result := ChangeFileExt(ExtractFileName(FileName), '');
end;

function DataBaseFileNameToIniName(const FileName: string): string;
begin
  Result := ChangeFileExt(FileName, '.ini');
end;

function GetBackupName(const FileName: string; Idx: Integer): string;
begin
  Result := FileName + '.' + IntToStrEx(Idx, 3);
end;  

procedure BackupDataBase(ForceBackup: Boolean);
begin
  with TBackupDatabase.Create do
  try
    DoBackupDataBase(ForceBackup);
  finally
    Free;
  end;
end;
  
{ TBackupDatabase }

function TBackupDatabase.GetLastBackupDate: TDateTime;
begin
  with TIniFile.Create(GetIniFileName) do
  try
    Result := ReadDate(csBackup, csLastBackupDate, 0);
  finally
    Free;
  end;
end;

procedure TBackupDatabase.SetLastBackupDate(const Value: TDateTime);
begin
  with TIniFile.Create(GetIniFileName) do
  try
    WriteDate(csBackup, csLastBackupDate, Value);
  finally
    Free;
  end;
end;

procedure TBackupDatabase.DoBackupFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  i: Integer;

  function GetBkName(Idx: Integer): string;
  begin
    Result := GetBackupName(FileName, Idx);
  end;
begin
  i := FMaxBackupCount;
  while FileExists(GetBkName(i)) do
  begin
    DeleteFile(GetBkName(i));
    Inc(i);
  end;

  for i := FMaxBackupCount - 1 downto 1 do
  begin
    if FileExists(GetBkName(i)) then
      RenameFile(GetBkName(i), GetBkName(i + 1));
  end;

  CopyFile(PChar(FileName), PChar(GetBkName(1)), False);
end;

procedure TBackupDatabase.DoBackupDataBase(ForceBackup: Boolean);
var
  Settings: TSettingsInfo;
  DBPath: string;
begin
  Settings := LoadSettingsFromIni;
  if ForceBackup or Settings.EnableBackup and (Date <> GetLastBackupDate) then
  begin
    DBPath := Trim(Settings.DBPath);
    if DBPath = '' then
      DBPath := ExtractFilePath(ParamStr(0)) + csDBDirName;
    FMaxBackupCount := Settings.BackupCount;
    FindFile(MakePath(Settings.DBPath), '*.db', DoBackupFile, nil, False, False);

    SetLastBackupDate(Date);
  end;    
end;

end.



