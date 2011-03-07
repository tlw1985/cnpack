unit CTMultiLangPlugin;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：支持多语言的插件单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTMultiLangPlugin.pas,v 1.2 2007/02/09 12:08:45 zjy Exp $
* 更新记录：2005.04.04
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, CTPluginIntf, CTPlugin;
  
type
  TMultiLangPlugin = class(TPlugin)
  protected
    procedure LangChanged(LangID: Integer); override;
  public
    procedure Loaded; override;
  end;

implementation

uses
  CnLangMgr, CTMultiLang, CnConsts;

{ TMultiLangPlugin }

procedure TMultiLangPlugin.LangChanged(LangID: Integer);
begin
  inherited;
  UpdateLangID(LangID);
  
  // Common
  TranslateStr(SCnInformation, 'SCnInformation');
  TranslateStr(SCnWarning, 'SCnWarning');
  TranslateStr(SCnError, 'SCnError');
  TranslateStr(SCnEnabled, 'SCnEnabled');
  TranslateStr(SCnDisabled, 'SCnDisabled');
  TranslateStr(SCnMsgDlgOK, 'SCnMsgDlgOK');
  TranslateStr(SCnMsgDlgCancel, 'SCnMsgDlgCancel');
  TranslateStr(SCnPack_Zjy, 'SCnPack_Zjy');
end;

procedure TMultiLangPlugin.Loaded;
begin
  inherited;
  InitLangManager(GetLangPath, GetLangID);
end;

end.
