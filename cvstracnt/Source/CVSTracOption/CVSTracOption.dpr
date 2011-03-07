program CVSTracOption;

uses
  SysUtils,
  Forms,
  CTOMainFrm in 'CTOMainFrm.pas' {CTOMainForm},
  CTOEditFrm in 'CTOEditFrm.pas' {CTOEditForm},
  CTConsts in '..\Public\CTConsts.pas',
  CTOUtils in 'CTOUtils.pas',
  CTUtils in '..\Public\CTUtils.pas',
  CTPluginIntf in '..\Public\CTPluginIntf.pas',
  CTPluginMgr in '..\Public\CTPluginMgr.pas',
  CTMultiLangFrm in '..\MultiLang\CTMultiLangFrm.pas' {CTMultiLangForm},
  CTMultiLang in '..\MultiLang\CTMultiLang.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := '';
  if FindCmdLineSwitch('i', ['/', '-'], True) or
    FindCmdLineSwitch('u', ['/', '-'], True) then
    Application.ShowMainForm := False;
  Application.CreateForm(TCTOMainForm, CTOMainForm);
  Application.Run;
end.
