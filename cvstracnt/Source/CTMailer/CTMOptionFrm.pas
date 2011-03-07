unit CTMOptionFrm;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：邮件发送设置窗口
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTMOptionFrm.pas,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.03.31
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, CTMSettings, IdSMTP, IdAntiFreeze, CnCommon, CnConsts,
  CTMultiLangFrm;

type
  TCTOMailForm = class(TCTMultiLangForm)
    grp1: TGroupBox;
    lbl1: TLabel;
    edtSmtpServer: TEdit;
    chkNeedAuth: TCheckBox;
    lbl2: TLabel;
    lbl3: TLabel;
    edtSenderMail: TEdit;
    edtUserName: TEdit;
    lbl4: TLabel;
    edtPassword: TEdit;
    btnClose: TButton;
    btnHelp: TButton;
    lbl7: TLabel;
    seSmtpPort: TSpinEdit;
    lbl8: TLabel;
    edtSenderName: TEdit;
    btnTest: TButton;
    lbl5: TLabel;
    seTimeOut: TSpinEdit;
    lbl6: TLabel;
    procedure chkNeedAuthClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ShowOptionForm(Settings: TMailerSettings): Boolean;

implementation

{$R *.DFM}

uses
  CTMTestFrm, CTMConsts;

function ShowOptionForm(Settings: TMailerSettings): Boolean;
begin
  with Settings, TCTOMailForm.Create(Application) do
  try
    edtSenderMail.Text := SenderMail;
    edtSenderName.Text := SenderName;
    edtSmtpServer.Text := SmtpServer;
    seSmtpPort.Value := SmtpPort;
    chkNeedAuth.Checked := NeedAuth;
    edtUserName.Text := UserName;
    edtPassword.Text := Password;
    seTimeOut.Value := TimeOut;
    chkNeedAuthClick(nil);

    Result := ShowModal = mrOk;
    if Result then
    begin
      SenderMail := edtSenderMail.Text;
      SenderName := edtSenderName.Text;
      SmtpServer := edtSmtpServer.Text;
      SmtpPort := seSmtpPort.Value;
      NeedAuth := chkNeedAuth.Checked;
      UserName := edtUserName.Text;
      Password := edtPassword.Text;
      TimeOut := seTimeOut.Value;
    end;
  finally
    Free;
  end;
end;

procedure TCTOMailForm.chkNeedAuthClick(Sender: TObject);
begin
  edtUserName.Enabled := chkNeedAuth.Checked;
  edtPassword.Enabled := chkNeedAuth.Checked;
end;

procedure TCTOMailForm.btnTestClick(Sender: TObject);
var
  Smtp: TIdSMTP;
  AntiFreeze: TIdAntiFreeze;
begin
  try
    Smtp := nil;
    AntiFreeze := nil;
    Enabled := False;
    ShowTestForm(SBeginTest, Font);
    try
      Smtp := TIdSMTP.Create(nil);
      AntiFreeze := TIdAntiFreeze.Create(nil);
      AntiFreeze.Active := True;
      with Smtp do
      begin
        Host := edtSmtpServer.Text;
        Port := seSmtpPort.Value;
        Username := edtUserName.Text;
        Password := edtPassword.Text;
        if chkNeedAuth.Checked then
          AuthenticationType := atLogin
        else
          AuthenticationType := atNone;
        
        UpdateTestForm(SBeginConnect);
        Connect(seTimeOut.Value * 1000);

        if chkNeedAuth.Checked then
        begin
          UpdateTestForm(SBeginLogin);
          if not Authenticate then
          begin
            HideTestForm;
            MessageBox(Handle, PChar(SLoginFail), PChar(SCnError), MB_OK +
              MB_ICONSTOP);
            Exit;
          end;
        end;

        HideTestForm;
        MessageBox(Handle, PChar(STestSucc), PChar(SCnInformation), MB_OK +
          MB_ICONINFORMATION);
      end;
    finally
      if Assigned(Smtp) then Smtp.Free;
      if Assigned(AntiFreeze) then AntiFreeze.Free;
      HideTestForm;
      Enabled := True;
    end;
  except
    on E: Exception do
    begin
      HideTestForm;
      MessageBox(Handle, PChar(STestFail + #13#10 + E.Message), PChar(SCnError),
        MB_OK + MB_ICONSTOP);
    end;
  end;
end;

end.
