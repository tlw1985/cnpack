unit CnSQLite2To3;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT 服务设置程序
* 单元名称：数据库升级工具
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows Server 2003 + Delphi 7.0
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: CnSQLite2To3.pas,v 1.1 2007/02/09 12:08:45 zjy Exp $
* 更新记录：2007.02.09
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, CnCommon, CnSQLite, SQLite3, SQLiteTable3;

function DBIsSQLite3(const DBName: string): Boolean;

function SQLite2To3(const DBName2, DBName3: string; var zErrMsg: string): Boolean;

implementation

function DBIsSQLite3(const DBName: string): Boolean;
var
  DB: TSQLiteDatabase;
begin
  Result := False;
  if FileExists(DBName) and (GetFileSize(DBName) > 0) then
  begin
    try
      DB := TSQLiteDatabase.Create(DBName);
      DB.Free;
      Result := True;
    except
      ;
    end;
  end;
end;  

function SQLite2To3(const DBName2, DBName3: string; var zErrMsg: string): Boolean;
var
  db2: TSQLite;
  db3: TSQLiteDatabase;
  Tables, Records, Lines, RecData: TStringList;
  ValStr: string;
  i, j, rec, tmp: Integer;
begin
  Result := False;
  try
    zErrMsg := '';
    db2 := nil;
    db3 := nil;
    Tables := nil;
    Records := nil;
    Lines := nil;
    RecData := nil;
    try
      db2 := TSQLite.Create(DBName2);
      if db2.LastError <> SQLITE_OK then
      begin
        zErrMsg := db2.LastErrorMessage;
        Exit;
      end;
    
      db3 := TSQLiteDatabase.Create(DBName3);

      Tables := TStringList.Create;
      Records := TStringList.Create;
      Lines := TStringList.Create;
      RecData := TStringList.Create;

      db2.Query('SELECT name, type, sql FROM sqlite_master ' +
        'WHERE type!=''meta'' AND sql NOT NULL ' +
        'ORDER BY substr(type,2,1), rowid', Tables);
      db3.ExecSQL('BEGIN TRANSACTION;');
      for i := 1 to Tables.Count - 1 do
      begin
        Lines.CommaText := Tables[i];
        if Lines.Count = 3 then
        begin
          db3.ExecSQL(Lines[2]);
          db2.Query('SELECT * FROM ' + Lines[0], Records);
          for rec := 1 to Records.Count - 1 do
          begin
            RecData.CommaText := Records[rec];
            ValStr := '';
            for j := 0 to RecData.Count - 1 do
            begin
              if ValStr <> '' then
                ValStr := ValStr + ',';
              if RecData[j] = '' then
                ValStr := ValStr + 'NULL'
              else if TryStrToInt(RecData[j], tmp) then
                ValStr := ValStr + RecData[j]
              else
                ValStr := ValStr + '''' + StringReplace(RecData[j], '''', '''''', [rfReplaceAll]) + '''';
            end;
            db3.ExecSQL('INSERT INTO ' + Lines[0] + ' VALUES(' + ValStr + ');'); 
          end;  
        end;
      end;  
      db3.ExecSQL('COMMIT;');
      Result := True;
    finally
      db2.Free;
      db3.Free;
      Tables.Free;
      Records.Free;
      Lines.Free;
      RecData.Free;
    end;
  except
    on E: Exception do
      zErrMsg := E.Message;
  end;          
end;

end.
