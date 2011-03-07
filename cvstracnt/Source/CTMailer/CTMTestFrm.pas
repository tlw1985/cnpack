unit CTMTestFrm;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：邮件设置测试窗体
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTMTestFrm.pas,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.03.30
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TCTMTestForm = class(TForm)
    btn1: TSpeedButton;
    img1: TImage;
    lblText: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowTestForm(const Text: string; Font: TFont);
procedure HideTestForm;
procedure UpdateTestForm(const Text: string);

implementation

{$R *.dfm}

var
  FCTMTestForm: TCTMTestForm;

procedure ShowTestForm(const Text: string; Font: TFont);
begin
  if not Assigned(FCTMTestForm) then
    FCTMTestForm := TCTMTestForm.Create(Application);
  FCTMTestForm.lblText.Caption := Text;
  FCTMTestForm.Font.Assign(Font);
  FCTMTestForm.Show;
  FCTMTestForm.BringToFront;
  Application.ProcessMessages;
end;

procedure HideTestForm;
begin
  if Assigned(FCTMTestForm) then
    FreeAndNil(FCTMTestForm);
  Application.ProcessMessages;
end;

procedure UpdateTestForm(const Text: string);
begin
  if Assigned(FCTMTestForm) then
    FCTMTestForm.lblText.Caption := Text;
  Application.ProcessMessages;
end;

end.
