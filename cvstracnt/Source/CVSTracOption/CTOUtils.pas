unit CTOUtils;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT 服务设置程序
* 单元名称：公共过程单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows Server 2003 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTOUtils.pas,v 1.5 2007/02/09 12:08:45 zjy Exp $
* 更新记录：2003.11.14
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, CnCommon, SQLite3, SQLiteTable3, CTConsts;

function FmtPath(const Path: string): string;
{* 转化路径为标准格式}

procedure GetRepositoryList(List: TStrings);
{* 取 CVSNT 在注册表中定义的 CVS 仓库列表}

function GetRepositoryInfo(const DBFile: string; var Info: TDBOptionInfo):
  Boolean;
{* 从数据库文件中返回 CVS 仓库路径及模块名}

function SetRepositoryInfo(const DBFile: string; Info: TDBOptionInfo): Boolean;
{* 写 CVS 仓库路径及模块名到数据库文件}

function ExportUsersToFile(const DBFile, ListFile: string): Boolean;
{* 导出用户列表到文件}

function ImportUsersFromFile(const DBFile, ListFile: string): Boolean;
{* 从用户列表文件中导入数据}

function SCMToStr(SCM: TSCMKind; LongStr: Boolean): string;

function StrToSCM(const S: string): TSCMKind;

implementation

const
  csMaxRepository = 64;

function FmtPath(const Path: string): string;
begin
  Result := GetUnixPath(MakeDir(Path));
end;

procedure GetRepositoryList(List: TStrings);
var
  i: Integer;
  AHome: string;
begin
  List.Clear;
  for i := 0 to csMaxRepository - 1 do
  begin
    AHome := RegReadStringDef(HKEY_LOCAL_MACHINE, 'Software\CVS\Pserver',
      'Repository' + IntToStr(i), '');
    AHome := FmtPath(AHome);
    if (AHome <> '') and (List.IndexOf(AHome) < 0) then
      List.Add(AHome);
  end;
end;

function GetRepositoryInfo(const DBFile: string; var Info: TDBOptionInfo):
  Boolean;
var
  DB: TSQLiteDatabase;
  NotifyCmd: string;
  List: TStrings;

  function GetParam(const Name: string): string;
  begin
    try
      Result := DB.GetTableString(Format('SELECT value FROM config WHERE name=''%s'';', [Name]));
    except
      Result := '';
    end;
  end;
begin
  Result := True;
  try
    DB := TSQLiteDatabase.Create(DBFile);
    try
      List := TStringList.Create;
      try
        Info.SCM := StrToSCM(GetParam('scm'));
        Info.Home := GetParam('cvsroot');
        Info.Module := GetParam('module');
        Info.CvsUser := GetParam('cvs_user_id');
        Info.Charset := GetParam('charset');
        Info.Passwd := Copy(GetParam('write_cvs_passwd'), 1, 1) <> 'n';
        NotifyCmd := GetParam('notify');
        if NotifyCmd = '' then
          Info.NotifyKind := nkNone
        else if Pos(csCTSenderName, NotifyCmd) > 0 then
          Info.NotifyKind := nkPlugin
        else
          Info.NotifyKind := nkOther;
      finally
        List.Free;
      end;
    finally
      DB.Free;
    end;
  except
    Result := False;
  end;
end;

function SetRepositoryInfo(const DBFile: string; Info: TDBOptionInfo): Boolean;
const
  SYesNo: array[Boolean] of string = ('no', 'yes');
var
  DB: TSQLiteDatabase;

  function TransFileName(const FileName: string): string;
  begin
    if Pos(' ', FileName) > 0 then
      Result := '"' + FileName + '"'
    else
      Result := FileName;
  end;
begin
  try
    DB := TSQLiteDatabase.Create(DBFile);
    try
      DB.ExecSQL(Format('REPLACE INTO config(name,value) VALUES(''scm'',''%s'');', [SCMToStr(Info.SCM, False)]));
      DB.ExecSQL(Format('REPLACE INTO config(name,value) VALUES(''cvsroot'',''%s'');', [Info.Home]));
      DB.ExecSQL(Format('REPLACE INTO config(name,value) VALUES(''module'',''%s'');', [Info.Module]));
      DB.ExecSQL(Format('REPLACE INTO config(name,value) VALUES(''cvs_user_id'',''%s'');', [Info.CvsUser]));
      if Info.Charset <> '' then
        DB.ExecSQL(Format('REPLACE INTO config(name,value) VALUES(''charset'',''%s'');', [Info.Charset]))
      else
        DB.ExecSQL('DELETE FROM config WHERE (name = ''charset'');');
      DB.ExecSQL(Format('REPLACE INTO config(name,value) VALUES(''write_cvs_passwd'',''%s'');', [SYesNo[Info.Passwd]]));
      if Info.NotifyKind = nkNone then
        DB.ExecSQL('REPLACE INTO config(name,value) VALUES(''notify'','''');')
      else if Info.NotifyKind = nkPlugin then
        DB.ExecSQL(Format('REPLACE INTO config(name,value) VALUES(''notify'',''%s "%s" "%%n" "%%u"'');',
          [GetUnixPath(TransFileName(ExtractFilePath(ParamStr(0)) + csCTSenderName)),
          Info.Database]));
      Result := True;
    finally
      DB.Free;
    end;
  except
    Result := False;
  end;
end;

function ExportUsersToFile(const DBFile, ListFile: string): Boolean;
var
  DB: TSQLiteDatabase;
  Table: TSQLiteTable;
  List: TStrings;
begin
  Result := True;
  try
    DB := TSQLiteDatabase.Create(DBFile);
    try
      List := TStringList.Create;
      try
        Table := DB.GetTable('SELECT id,name,email,passwd,capabilities FROM user');
        try
          Table.MoveFirst;
          while not Table.EOF do
          begin
            List.Add(Format('%s,%s,%s,%s,%s', [Table.FieldAsString(0),
              Table.FieldAsString(1), Table.FieldAsString(2),
              Table.FieldAsString(3), Table.FieldAsString(4)]));
            Table.Next;
          end;
          List.SaveToFile(ListFile);
        finally
          Table.Free;
        end;
      finally
        List.Free;
      end;
    finally
      DB.Free;
    end;
  except
    Result := False;
  end;
end;

function ImportUsersFromFile(const DBFile, ListFile: string): Boolean;
const
  csFieldCount = 5;
var
  DB: TSQLiteDatabase;
  List: TStrings;
  Fields: TStrings;
  i: Integer;
begin
  try
    DB := nil;
    List := nil;
    Fields := nil;
    try
      DB := TSQLiteDatabase.Create(DBFile);
      List := TStringList.Create;
      Fields := TStringList.Create;
      List.LoadFromFile(ListFile);
      for i := 0 to List.Count - 1 do
      begin
        Fields.CommaText := List[i];
        if Fields.Count = csFieldCount then
        begin
          DB.ExecSQL(Format('REPLACE INTO user(id,name,email,passwd,capabilities)' + #13#10 +
            'VALUES(''%s'',''%s'',''%s'',''%s'',''%s'')', [Fields[0], Fields[1],
            Fields[2], Fields[3], Fields[4]]));
        end;
      end;
      Result := True;
    finally
      if Assigned(DB) then DB.Free;
      if Assigned(List) then List.Free;
      if Assigned(Fields) then Fields.Free;
    end;
  except
    Result := False;
  end;
end;

function SCMToStr(SCM: TSCMKind; LongStr: Boolean): string;
begin
  if LongStr then
    Result := csSCMNames[SCM]
  else
    Result := csSCMs[SCM];
end;  

function StrToSCM(const S: string): TSCMKind;
var
  SCM: TSCMKind;
begin
  for SCM := Low(TSCMKind) to High(TSCMKind) do
    if SameText(S, csSCMs[SCM]) or SameText(S, csSCMNames[SCM]) then
    begin
      Result := SCM;
      Exit;
    end;
  Result := skNone;
end;  

end.

