unit CTMultiLangFrm;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：多语言基窗体
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTMultiLangFrm.pas,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.04.04
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CnLangMgr;

type
  TCTMultiLangForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TCTMultiLangForm.FormCreate(Sender: TObject);
begin
  CnLanguageManager.TranslateForm(Self);
end;

end.
