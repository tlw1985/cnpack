unit CTNDatabaseFrm;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：Net Send 通知设置窗体
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTNDatabaseFrm.pas,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.03.31
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CTNSettings, StdCtrls, CTMultiLangFrm;

type
  TCTNDatabaseForm = class(TCTMultiLangForm)
    grp1: TGroupBox;
    btnClose: TButton;
    btnHelp: TButton;
    lbl2: TLabel;
    chkAllUsers: TCheckBox;
    chkLoginUsers: TCheckBox;
    mmoUsers: TMemo;
    lbl1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ShowDBOptionForm(Settings: TNetSendDBSettings): Boolean;

implementation

{$R *.dfm}

function ShowDBOptionForm(Settings: TNetSendDBSettings): Boolean;
begin
  with Settings, TCTNDatabaseForm.Create(Application) do
  try
    chkAllUsers.Checked := AllUsers;
    chkLoginUsers.Checked := LoginUsers;
    mmoUsers.Lines.Assign(Users);

    Result := ShowModal = mrOk;
    if Result then
    begin
      AllUsers := chkAllUsers.Checked;
      LoginUsers := chkLoginUsers.Checked;
      Users.Assign(mmoUsers.Lines);
    end;
  finally
    Free;
  end;
end;

end.
