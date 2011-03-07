library CTNetSend;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  CTPluginUtils in '..\Public\CTPluginUtils.pas',
  CTPluginIntf in '..\Public\CTPluginIntf.pas',
  CTPlugin in '..\Public\CTPlugin.pas',
  CTNDatabaseFrm in 'CTNDatabaseFrm.pas' {CTNDatabaseForm},
  CTNSettings in 'CTNSettings.pas',
  CTNPlugin in 'CTNPlugin.pas',
  CTNConsts in 'CTNConsts.pas',
  CTMultiLangFrm in '..\MultiLang\CTMultiLangFrm.pas' {CTMultiLangForm},
  CTMultiLangPlugin in '..\MultiLang\CTMultiLangPlugin.pas',
  CTMultiLang in '..\MultiLang\CTMultiLang.pas';

{$R *.res}

begin
end.
