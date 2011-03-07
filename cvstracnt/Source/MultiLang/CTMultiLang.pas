unit CTMultiLang;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：多语言处理公共单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTMultiLang.pas,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.03.30
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, CnLangMgr, CnHashLangStorage, CnLangStorage;

procedure InitLangManager(const LangPath: string; LangID: Integer;
  FileName: string = '');

procedure UpdateLangID(LangID: Integer);

implementation

const
  csLanguage = 'Language';
  csEnglishID = 1033;

var
  FStorage: TCnHashLangFileStorage;

procedure InitLangManager(const LangPath: string; LangID: Integer;
  FileName: string = '');
begin
  if CnLanguageManager = nil then
    CreateLanguageManager;
    
  CnLanguageManager.AutoTranslate := False;
  CnLanguageManager.TranslateTreeNode := True;
  CnLanguageManager.UseDefaultFont := True;
  FStorage := TCnHashLangFileStorage.Create(nil);
  if FileName = '' then
    FileName := ChangeFileExt(ExtractFileName(GetModuleName(HInstance)), '.txt');
  FStorage.FileName := FileName;
  FStorage.StorageMode := smByDirectory;
  FStorage.LanguagePath := LangPath;
  CnLanguageManager.LanguageStorage := FStorage;

  if FStorage.Languages.Find(LangID) >= 0 then
    CnLanguageManager.CurrentLanguageIndex := FStorage.Languages.Find(LangID)
  else
    CnLanguageManager.CurrentLanguageIndex := FStorage.Languages.Find(csEnglishID);
end;

procedure UpdateLangID(LangID: Integer);
begin
  if FStorage.Languages.Find(LangID) >= 0 then
    CnLanguageManager.CurrentLanguageIndex := FStorage.Languages.Find(LangID);
end;

end.

