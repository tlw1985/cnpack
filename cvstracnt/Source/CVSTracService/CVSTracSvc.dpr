program CVSTracSvc;

uses
  SvcMgr,
  CTSMain in 'CTSMain.pas' {CVSTracService: TService},
  CTConsts in '..\Public\CTConsts.pas',
  CTUtils in '..\Public\CTUtils.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'CVSTrac Service';
  Application.CreateForm(TCVSTracService, CVSTracService);
  Application.Run;
end.
