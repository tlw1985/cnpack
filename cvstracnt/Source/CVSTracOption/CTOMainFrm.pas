unit CTOMainFrm;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT 服务设置程序
* 单元名称：主窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows Server 2003 + Delphi 7.0
* 本 地 化：该单元中的字符串支持本地化处理方式
* 单元标识：$Id: CTOMainFrm.pas,v 1.10 2008/06/01 16:24:00 zjy Exp $
* 更新记录：2003.11.09
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, IniFiles, ExtCtrls, CTConsts, CTUtils, CnCommon, Spin,
  CTOUtils, CnConsts, CnLangMgr, CnWinSvc, CTPluginIntf, CTPluginMgr,
  CTMultiLang, CnSQLite2To3;

type
  TCTOMainForm = class(TForm)
    btnClose: TButton;
    tmrStatus: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnHelp: TButton;
    PageControl: TPageControl;
    tsOption: TTabSheet;
    tsPlugin: TTabSheet;
    grp1: TGroupBox;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl1: TLabel;
    btnInstall: TButton;
    btnUninstall: TButton;
    btnStart: TButton;
    btnStop: TButton;
    sePort: TSpinEdit;
    edtHome: TEdit;
    btnPath: TButton;
    cbbLang: TComboBox;
    grp2: TGroupBox;
    ListView: TListView;
    btnAdd: TButton;
    btnDelete: TButton;
    btnEdit: TButton;
    btnImport: TButton;
    btnBrowse: TButton;
    grp3: TGroupBox;
    lbl5: TLabel;
    edtLocalServer: TEdit;
    chkEnableLog: TCheckBox;
    grp4: TGroupBox;
    lvPlugins: TListView;
    btnPluginConfig: TButton;
    lbl4: TLabel;
    btnViewLogs: TButton;
    btnCopy: TButton;
    chkEnableBackup: TCheckBox;
    seBackupCount: TSpinEdit;
    btnBackupNow: TButton;
    btnUpgrade: TButton;
    btnUpgradeAll: TButton;
    btnRefresh: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure tmrStatusTimer(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnInstallClick(Sender: TObject);
    procedure btnUninstallClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnPathClick(Sender: TObject);
    procedure sePortExit(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure cbbLangChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnSettingChanged(Sender: TObject);
    procedure lvPluginsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnPluginConfigClick(Sender: TObject);
    procedure lbl4Click(Sender: TObject);
    procedure btnViewLogsClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnBackupNowClick(Sender: TObject);
    procedure btnUpgradeClick(Sender: TObject);
    procedure btnUpgradeAllClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
  private
    { Private declarations }
    FCVSTracSvcName: string;
    FNTService: TCnNTService;
    FSettings: TSettingsInfo;
    FHomeList: TStringList;
    FUpdating: Boolean;
    FNeedUpgrade: Boolean;

    procedure AutoCreateHistoryForCVSNT;
    function GetExclusiveName(ADatabase: string = ''): string;
    function GetDBDir: string;
    procedure InitDatabase(Info: TDBOptionInfo);
    procedure DropDatabase(const ADatabase: string);
    procedure CopyDatabase(const ADatabase: string);
    function GetDBFile(const ADatabase: string): string;
    procedure DoFindFile(const FileName: string; const Info: TSearchRec;
      var Abort: Boolean);
    function UpgradeDatabase2To3(const DBFile: string): Boolean;

    procedure CnStorageLanguageChanged(Sender: TObject; ALanguageIndex: Integer);
    procedure LoadSettings;
    procedure SaveSettings;
    procedure UpdateLangage;
    procedure UpdateStatus;
    procedure UpdateList;
    procedure UpdatePlugins;
    procedure QueryRestartService;
  protected

  public
    { Public declarations }
    property DBDir: string read GetDBDir;
  end;

var
  CTOMainForm: TCTOMainForm;

implementation

uses CTOEditFrm;

{$R *.DFM}

const
  csMaxRepository = 64;
  csDefCvsUser = 'cvsuser';
  csBackExt = '.bu';

{ TCTOMainForm }

procedure TCTOMainForm.FormCreate(Sender: TObject);
begin
  FNTService := TCnNTService.Create(csServiceName);
  FCVSTracSvcName := ExtractFilePath(ParamStr(0)) + csCVSTracSvcName;
  if Pos(' ', FCVSTracSvcName) > 0 then
    FCVSTracSvcName := '"' + FCVSTracSvcName + '"';
  FHomeList := TStringList.Create;

  LoadSettings;
  InitLangManager(PluginMgr.LangPath, FSettings.LangID);
  CnLanguageManager.LanguageStorage.OnLanguageChanged := CnStorageLanguageChanged;
  UpdateLangage;
  CnStorageLanguageChanged(CnLanguageManager, CnLanguageManager.LanguageStorage.CurrentLanguageIndex);
  SaveSettings;

  Application.Title := SAppTitle;
  PageControl.ActivePageIndex := 0;
  
  UpdateList;
  UpdateStatus;

  PluginMgr.LoadPlugins;
  UpdatePlugins;

  // 处理命令行
  if FindCmdLineSwitch('i', ['/', '-'], True) then
  begin
    SaveSettings;
    FNTService.Install(FCVSTracSvcName, csServiceDesc);
    FNTService.Start;
    PostMessage(Handle, WM_CLOSE, 0, 0);
  end
  else if FindCmdLineSwitch('u', ['/', '-'], True) then
  begin
    FNTService.Stop;
    FNTService.Uninstall;
    Sleep(1000);
    PostMessage(Handle, WM_CLOSE, 0, 0);
  end;
end;

procedure TCTOMainForm.FormDestroy(Sender: TObject);
begin
  FHomeList.Free;
  FNTService.Free;
end;

procedure TCTOMainForm.FormShow(Sender: TObject);
var
  List: TStrings;
begin
  if ListView.Items.Count = 0 then
  begin
    List := TStringList.Create;
    try
      GetRepositoryList(List);
      if (List.Count > 0) and QueryDlg(SInitRepository) then
      begin
        btnImportClick(nil);
      end;
    finally
      List.Free;
    end;
  end
  else if FNeedUpgrade then
  begin
    if QueryDlg(SDBUpgradeQuery) then
      btnUpgradeAllClick(nil);
  end;

  AutoCreateHistoryForCVSNT;
end;

//------------------------------------------------------------------------------
// 参数读写
//------------------------------------------------------------------------------

procedure TCTOMainForm.LoadSettings;
begin
  FUpdating := True;
  try
    FSettings := LoadSettingsFromIni;
    edtHome.Text := FSettings.DBPath;
    sePort.Value := FSettings.Port;
    edtLocalServer.Text := FSettings.LocalServer;
    chkEnableLog.Checked := FSettings.EnableLog;
    chkEnableBackup.Checked := FSettings.EnableBackup;
    seBackupCount.Value := FSettings.BackupCount;
    PluginMgr.DBPath := FSettings.DBPath;
  finally
    FUpdating := False;
  end;
end;

procedure TCTOMainForm.SaveSettings;
begin
  seBackupCount.Enabled := chkEnableBackup.Checked;
  FSettings.DBPath := edtHome.Text;
  PluginMgr.DBPath := FSettings.DBPath;
  FSettings.Port := sePort.Value;
  edtLocalServer.Text := Trim(edtLocalServer.Text);
  if (edtLocalServer.Text <> '') and (AnsiPos('http://', edtLocalServer.Text) <> 1) then
    edtLocalServer.Text := 'http://' + edtLocalServer.Text;
  FSettings.LocalServer := edtLocalServer.Text;
  FSettings.EnableLog := chkEnableLog.Checked;
  FSettings.EnableBackup := chkEnableBackup.Checked;
  FSettings.BackupCount := seBackupCount.Value;
  if CnLanguageManager.LanguageStorage.CurrentLanguage <> nil then
    FSettings.LangID := CnLanguageManager.LanguageStorage.CurrentLanguage.LanguageID;
  FSettings.ExeName := SExeName;
  SaveSettingsToIni(FSettings);
end;

//------------------------------------------------------------------------------
// 数据库处理
//------------------------------------------------------------------------------

procedure TCTOMainForm.UpdateStatus;
begin
  btnInstall.Enabled := not FNTService.IsInstalled;
  btnUninstall.Enabled := not btnInstall.Enabled;
  btnStart.Enabled := FNTService.CanStart;
  btnStop.Enabled := FNTService.CanStop;
end;

function TCTOMainForm.GetDBDir: string;
begin
  Result := Trim(edtHome.Text);
  if Result = '' then
    Result := ExtractFilePath(ParamStr(0)) + csDBDirName;
end;

function TCTOMainForm.GetExclusiveName(ADatabase: string): string;
var
  i: Integer;

  function NameHasExists(const ADatabase: string): Boolean;
  var
    i: Integer;
  begin
    for i := 0 to ListView.Items.Count - 1 do
      if SameText(ListView.Items[i].Caption, ADatabase) then
      begin
        Result := True;
        Exit;
      end;
    Result := False;
  end;
begin
  if Trim(ADatabase) = '' then
    ADatabase := 'Repository';
  Result := Trim(ADatabase);

  if NameHasExists(Result) then
  begin
    i := 1;
    repeat
      Result := ADatabase + IntToStr(i);
      Inc(i);
    until not NameHasExists(Result);
  end;
end;

function TCTOMainForm.GetDBFile(const ADatabase: string): string;
begin
  Result := MakePath(DBDir) + ADatabase + '.db';
end;

procedure TCTOMainForm.DropDatabase(const ADatabase: string);
var
  i: Integer; 
begin
  DeleteToRecycleBin(GetDBFile(ADatabase));
  if FileExists(DataBaseFileNameToIniName(GetDBFile(ADatabase))) then
    DeleteToRecycleBin(DataBaseFileNameToIniName(GetDBFile(ADatabase)));
  i := 1;
  while FileExists(GetBackupName(GetDBFile(ADatabase), i)) do
  begin
    DeleteToRecycleBin(GetBackupName(GetDBFile(ADatabase), i));
    Inc(i);
  end;
end;

procedure TCTOMainForm.CopyDatabase(const ADatabase: string);
var
  AName: string;
begin
  AName := GetExclusiveName(ADatabase);
  CopyFile(PChar(GetDBFile(ADatabase)), PChar(GetDBFile(AName)), True);
  CopyFile(PChar(DataBaseFileNameToIniName(GetDBFile(ADatabase))),
    PChar(DataBaseFileNameToIniName(GetDBFile(AName))), True);
end;

procedure TCTOMainForm.InitDatabase(Info: TDBOptionInfo);
var
  FmtStr: string;
  FileName: string;
begin
  ForceDirectories(DBDir);
  FmtStr := '"' + ExtractFilePath(ParamStr(0)) + SExeName + '" init "%s" %s';
  FileName := Format(FmtStr, [DBDir, Info.Database]);
  WinExecAndWait32(FileName, SW_HIDE, False);
  SetRepositoryInfo(GetDBFile(Info.Database), Info);
end;

procedure TCTOMainForm.DoFindFile(const FileName: string;
  const Info: TSearchRec; var Abort: Boolean);
var
  AInfo: TDBOptionInfo;
begin
  if GetFileSize(FileName) = 0 then
  begin
    Exit;
  end;
  
  with ListView.Items.Add do
  begin
    Caption := DataBaseFileNameToDBName(FileName);
    if GetRepositoryInfo(FileName, AInfo) then
    begin
      if (AInfo.Home <> '') and (FHomeList.IndexOf(AInfo.Home) < 0) then
        FHomeList.Add(AInfo.Home);
      SubItems.Add(AInfo.Home);
      SubItems.Add(AInfo.Module);
      if AInfo.Passwd then
        SubItems.Add(SUseStr)
      else
        SubItems.Add('');
      SubItems.Add(AInfo.CvsUser);
      SubItems.Add(SNotifyKinds[AInfo.NotifyKind]);
      SubItems.Add(AInfo.Charset);
      SubItems.Add(SCMToStr(AInfo.SCM, True));
      Data := nil;
    end
    else
    begin
      FNeedUpgrade := True;
      SubItems.Add(SDBFormatError);
      Data := Pointer(1);
    end;       
  end;
end;

procedure TCTOMainForm.UpdateList;
begin
  FHomeList.Clear;
  FNeedUpgrade := False;
  ListView.Items.Clear;
  FindFile(MakePath(DBDir), '*.db', DoFindFile, nil, False, False);
  btnUpgradeAll.Enabled := FNeedUpgrade;
end;

procedure TCTOMainForm.QueryRestartService;
begin
  if FNTService.IsInstalled and FNTService.CanStop then
    if QueryDlg(SRestartService) then
    begin
      FNTService.Stop;
      while not FNTService.CanStart do
        Application.ProcessMessages;
      btnStartClick(nil);
    end;
end;

procedure TCTOMainForm.AutoCreateHistoryForCVSNT;
var
  List, Files: TStringList;
  i: Integer;

  procedure AddFileList(AList: TStringList);
  var
    i: Integer;
    FileName: string;
    Dir: string;
  begin
    for i := 0 to List.Count - 1 do
    begin
      Dir := GetWinPath(MakePath(AList[i]) + 'CVSROOT');
      FileName := GetWinPath(MakePath(AList[i])) + 'CVSROOT\history';
      if DirectoryExists(Dir) and not FileExists(FileName)
        and (Files.IndexOf(FileName) < 0) then
      begin
        Files.Add(FileName);
      end;
    end;
  end;
begin
  List := nil;
  Files := nil;
  try
    List := TStringList.Create;
    Files := TStringList.Create;
    GetRepositoryList(List);

    AddFileList(List);
    AddFileList(FHomeList);

    if (Files.Count > 0) and QueryDlg(Format(SAutoGenHisFileQuery, [Files.Count])) then
    begin
      for i := 0 to Files.Count - 1 do
        SaveStringToFile('', Files[i]);
    end;  
  finally
    List.Free;
    Files.Free;
  end;
end;

procedure TCTOMainForm.tmrStatusTimer(Sender: TObject);
begin
  UpdateStatus;
end;

procedure TCTOMainForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TCTOMainForm.btnBackupNowClick(Sender: TObject);
begin
  BackupDataBase(True);
  InfoDlg(SBackupOk);
end;

procedure TCTOMainForm.btnAddClick(Sender: TObject);
var
  Info: TDBOptionInfo;
  NewDB: string;
begin
  NewDB := GetExclusiveName;
  Info.Database := NewDB;
  Info.Home := '';
  Info.Module := '';
  Info.CvsUser := csDefCvsUser;
  Info.Charset := '';
  Info.Passwd := False;
  Info.NotifyKind := nkNone;
  Info.SCM := skNone;
  if ShowEditForm(GetDBFile(Info.Database), Info) then
  begin
    Info.Database := GetExclusiveName(Info.Database);
    InitDatabase(Info);
    UpdateList;
    if FileExists(DataBaseFileNameToIniName(GetDBFile(NewDB))) then
      RenameFile(DataBaseFileNameToIniName(GetDBFile(NewDB)),
        DataBaseFileNameToIniName(GetDBFile(Info.Database)));
  end;
  AutoCreateHistoryForCVSNT;
end;

procedure TCTOMainForm.btnDeleteClick(Sender: TObject);
begin
  if Assigned(ListView.Selected) and QueryDlg(SDeleteQuery) then
  begin
    DropDatabase(ListView.Selected.Caption);
    UpdateList;
  end;
end;

procedure TCTOMainForm.btnCopyClick(Sender: TObject);
begin
  if Assigned(ListView.Selected) then
  begin
    CopyDatabase(ListView.Selected.Caption);
    UpdateList;
  end;
end;

procedure TCTOMainForm.btnEditClick(Sender: TObject);
var
  Info: TDBOptionInfo;
  NotifyKind: TNotifyKind;
  i: Integer;
begin
  if Assigned(ListView.Selected) and (ListView.Selected.Data = nil) then
    with ListView.Selected do
    begin
      Info.Database := Caption;
      Info.Home := SubItems[0];
      Info.Module := SubItems[1];
      Info.Passwd := SameText(SubItems[2], SUseStr);
      Info.CvsUser := SubItems[3];
      Info.NotifyKind := nkOther;
      for NotifyKind := Low(TNotifyKind) to High(TNotifyKind) do
        if SameText(SubItems[4], SNotifyKinds[NotifyKind]) then
        begin
          Info.NotifyKind := NotifyKind;
          Break;
        end;
      Info.Charset := SubItems[5];
      Info.SCM := StrToSCM(SubItems[6]);
      if ShowEditForm(GetDBFile(Info.Database), Info) then
      begin
        if not SameText(Caption, Info.Database) then
        begin
          RenameFile(GetDBFile(Caption), GetDBFile(Info.Database));
          if FileExists(GetDBFile(Caption) + csBackExt) then
            RenameFile(GetDBFile(Caption) + csBackExt, GetDBFile(Info.Database) + csBackExt);
          if FileExists(DataBaseFileNameToIniName(GetDBFile(Caption))) then
            RenameFile(DataBaseFileNameToIniName(GetDBFile(Caption)),
              DataBaseFileNameToIniName(GetDBFile(Info.Database)));
          i := 1;
          while FileExists(GetBackupName(GetDBFile(Caption), i)) do
          begin
            RenameFile(GetBackupName(GetDBFile(Caption), i),
              GetBackupName(GetDBFile(Info.Database), i));
            Inc(i);
          end;
        end;
        SetRepositoryInfo(GetDBFile(Info.Database), Info);
        UpdateList;
      end;
      AutoCreateHistoryForCVSNT;
    end;
end;

procedure TCTOMainForm.btnBrowseClick(Sender: TObject);
begin
  if Assigned(ListView.Selected) and (ListView.Selected.Data = nil) then
    OpenUrl(Format('http://localhost:%d/%s/index', [sePort.Value,
      ListView.Selected.Caption]));
end;

procedure TCTOMainForm.btnRefreshClick(Sender: TObject);
begin
  UpdateList;
end;

function TCTOMainForm.UpgradeDatabase2To3(const DBFile: string): Boolean;
var
  BkName: string;
  zErrMsg: string;
begin
  Result := False;
  if FileExists(DBFile) then
  begin
    BkName := ChangeFileExt(DBFile, '.db2');
    DeleteFile(BkName);
    RenameFile(DBFile, BkName);
    Result := SQLite2To3(BkName, DBFile, zErrMsg);
  end;
end;

procedure TCTOMainForm.btnUpgradeClick(Sender: TObject);
var
  DBName: string;
  DBFile: string;
begin
  if Assigned(ListView.Selected) then
  begin
    DBName := ListView.Selected.Caption;
    DBFile := GetDBFile(DBName);
    if DBIsSQLite3(DBFile) then
    begin
      InfoDlg(Format(SDBIsSQLite3, [DBName]));
      Exit;
    end;

    if UpgradeDatabase2To3(DBFile) then
    begin
      UpdateList;
      InfoDlg(Format(SDBUpgradeSucc, [DBName]));
    end
    else
      ErrorDlg(Format(SDBUpgradeFail, [DBName]));
  end;
end;

procedure TCTOMainForm.btnUpgradeAllClick(Sender: TObject);
var
  i: Integer;
  DBFile: string;
  Succ: Integer;
begin
  Succ := 0;
  for i := 0 to ListView.Items.Count - 1 do
  begin
    DBFile := GetDBFile(ListView.Items[i].Caption);
    if not DBIsSQLite3(DBFile) then
    begin
      if UpgradeDatabase2To3(DBFile) then
        Inc(Succ)
      else
        ErrorDlg(Format(SDBUpgradeFail, [ListView.Items[i].Caption]));
    end;
  end;
  UpdateList;
  InfoDlg(Format(SDBUpgradeAllSucc, [Succ]));
end;

procedure TCTOMainForm.btnImportClick(Sender: TObject);
var
  i: Integer;
  Count: Integer;
  Info: TDBOptionInfo;
  List: TStrings;

  function IsRepositoryExists(const Repository: string): Boolean;
  var
    i: Integer;
  begin
    for i := 0 to ListView.Items.Count - 1 do
      if SameText(FmtPath(ListView.Items[i].SubItems[0]), FmtPath(Repository)) then
      begin
        Result := True;
        Exit;
      end;
    Result := False;
  end;

begin
  List := TStringList.Create;
  try
    Count := 0;
    GetRepositoryList(List);
    for i := 0 to List.Count - 1 do
    begin
      if not IsRepositoryExists(List[i]) then
      begin
        Info.Database := GetExclusiveName(ExtractFileName(GetWinPath(List[i])));
        Info.Home := List[i];
        Info.Module := '';
        Info.CvsUser := csDefCvsUser;
        Info.Passwd := False;
        Info.NotifyKind := nkNone;
        Info.SCM := skNone;
        InitDatabase(Info);
        Inc(Count);
      end;
    end;
    UpdateList;
    if Count > 0 then
      InfoDlg(Format(SImportOk, [Count]))
    else
      InfoDlg(SImportEmpty);
  finally
    List.Free;
  end;

  AutoCreateHistoryForCVSNT;
end;

procedure TCTOMainForm.btnInstallClick(Sender: TObject);
begin
  if not FNTService.Install(FCVSTracSvcName, csServiceDesc) then
    ErrorDlg(FNTService.LastErrorMsg + #13#10 + GetLastErrorMsg(True));
end;

procedure TCTOMainForm.btnUninstallClick(Sender: TObject);
begin
  FNTService.Stop;
  if not FNTService.Uninstall then
    ErrorDlg(FNTService.LastErrorMsg + #13#10 + GetLastErrorMsg(True));
end;

procedure TCTOMainForm.btnStartClick(Sender: TObject);
begin
  if not FNTService.Start then
    ErrorDlg(FNTService.LastErrorMsg + #13#10 + GetLastErrorMsg(True));
end;

procedure TCTOMainForm.btnStopClick(Sender: TObject);
begin
  if not FNTService.Stop then
    ErrorDlg(FNTService.LastErrorMsg + #13#10 + GetLastErrorMsg(True));
end;

procedure TCTOMainForm.btnHelpClick(Sender: TObject);
begin
  RunFile(ExtractFilePath(ParamStr(0)) + SReadmeName);
end;

procedure TCTOMainForm.Label2Click(Sender: TObject);
begin
  OpenUrl('http://www.cvstrac.org');
end;

procedure TCTOMainForm.Label4Click(Sender: TObject);
begin
  OpenUrl(SCnPackUrl);
end;

procedure TCTOMainForm.lbl4Click(Sender: TObject);
begin
  MailTo(SCnPackEmail, 'About CVSTracNT');
end;

procedure TCTOMainForm.sePortExit(Sender: TObject);
begin
  if sePort.Value <> FSettings.Port then
  begin
    SaveSettings;
    QueryRestartService;
  end;
end;

procedure TCTOMainForm.btnPathClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := edtHome.Text;
  if GetDirectory(SGetDir, Dir) and (edtHome.Text <> Dir) then
  begin
    edtHome.Text := Dir;
    SaveSettings;
    UpdateList;
    QueryRestartService;
  end;
end;

procedure TCTOMainForm.ListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
var
  HasSel, FmtOk: Boolean;
begin
  HasSel := Assigned(ListView.Selected);
  FmtOk := HasSel and (ListView.Selected.Data = nil);
  btnDelete.Enabled := HasSel;
  btnCopy.Enabled := HasSel;
  btnEdit.Enabled := FmtOk;
  btnBrowse.Enabled := FmtOk;
  btnUpgrade.Enabled := HasSel and not FmtOk;
end;

//------------------------------------------------------------------------------
// 插件处理相关
//------------------------------------------------------------------------------

procedure TCTOMainForm.OnSettingChanged(Sender: TObject);
begin
  if not FUpdating then
    SaveSettings;
end;

procedure TCTOMainForm.UpdatePlugins;
var
  i: Integer;
  PluginInfo: TPluginInfo;
begin
  lvPlugins.Items.BeginUpdate;
  try
    lvPlugins.Clear;
    for i := 0 to PluginMgr.Count - 1 do
    begin
      PluginInfo := Pluginmgr[i].GetPluginInfo;
      with lvPlugins.Items.Add do
      begin
        Caption := PluginInfo.Name;
        SubItems.Add(VersionToStr(PluginInfo.Version));
        SubItems.Add(PluginInfo.Author);
        SubItems.Add(PluginInfo.Comment);
      end;
    end;
  finally
    lvPlugins.Items.EndUpdate;
  end;
end;

procedure TCTOMainForm.lvPluginsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  btnPluginConfig.Enabled := Assigned(lvPlugins.Selected) and
    PluginMgr[lvPlugins.Selected.Index].CanConfigPlugin;
end;

procedure TCTOMainForm.btnPluginConfigClick(Sender: TObject);
begin
  if Assigned(lvPlugins.Selected) and
    PluginMgr[lvPlugins.Selected.Index].CanConfigPlugin then
    PluginMgr[lvPlugins.Selected.Index].ConfigPlugin(Application.Handle);
end;

procedure TCTOMainForm.btnViewLogsClick(Sender: TObject);
begin
  RunFile(AppPath + csLogDirName);
end;

//------------------------------------------------------------------------------
// 多语言相关
//------------------------------------------------------------------------------

procedure TCTOMainForm.UpdateLangage;
var
  i: Integer;
begin
  FUpdating := True;
  try
    cbbLang.Items.Clear;
    for i := 0 to CnLanguageManager.LanguageStorage.Languages.Count - 1 do
      cbbLang.Items.Add(CnLanguageManager.LanguageStorage.Languages[i].LanguageName);
    cbbLang.ItemIndex := CnLanguageManager.CurrentLanguageIndex;
  finally
    FUpdating := False;
  end;
end;

procedure TCTOMainForm.cbbLangChange(Sender: TObject);
var
  i: Integer;
begin
  if not FUpdating and (CnLanguageManager.CurrentLanguageIndex <> cbbLang.ItemIndex) then
  begin
    CnLanguageManager.CurrentLanguageIndex := cbbLang.ItemIndex;
    UpdateList;
    SaveSettings;
    QueryRestartService;
    
    if CnLanguageManager.LanguageStorage.CurrentLanguage <> nil then
    begin
      for i := 0 to PluginMgr.Count - 1 do
        PluginMgr[i].LangChanged(CnLanguageManager.LanguageStorage.CurrentLanguage.LanguageID);
    end;
    UpdatePlugins;
  end;
end;

procedure TCTOMainForm.CnStorageLanguageChanged(Sender: TObject;
  ALanguageIndex: Integer);
begin
  CnLanguageManager.TranslateForm(Self);
  
  // Common
  TranslateStr(SCnInformation, 'SCnInformation');
  TranslateStr(SCnWarning, 'SCnWarning');
  TranslateStr(SCnError, 'SCnError');
  TranslateStr(SCnEnabled, 'SCnEnabled');
  TranslateStr(SCnDisabled, 'SCnDisabled');
  TranslateStr(SCnMsgDlgOK, 'SCnMsgDlgOK');
  TranslateStr(SCnMsgDlgCancel, 'SCnMsgDlgCancel');

  // FileName
  TranslateStr(SExeName, 'SExeName');
  TranslateStr(SReadmeName, 'SReadmeName');

  // CTOMainForm
  TranslateStr(SAppTitle, 'SAppTitle');
  TranslateStr(SDeleteQuery, 'SDeleteQuery');
  TranslateStr(SAutoGenHisFileQuery, 'SAutoGenHisFileQuery');
  TranslateStr(SGetDir, 'SGetDir');
  TranslateStr(SImportOk, 'SImportOk');
  TranslateStr(SImportEmpty, 'SImportEmpty');
  TranslateStr(SInitRepository, 'SInitRepository');
  TranslateStr(SUseStr, 'SUseStr');
  TranslateStr(SRestartService, 'SRestartService');
  TranslateStr(SNotifyKinds[nkNone], 'SNotifyKinds_None');
  TranslateStr(SNotifyKinds[nkPlugin], 'SNotifyKinds_Plugin');
  TranslateStr(SNotifyKinds[nkOther], 'SNotifyKinds_Other');
  TranslateStr(SBackupOk, 'SBackupOk');
  TranslateStr(SDBFormatError, 'SDBFormatError');
  TranslateStr(SDBIsSQLite3, 'SDBIsSQLite3');
  TranslateStr(SDBUpgradeSucc, 'SDBUpgradeSucc');
  TranslateStr(SDBUpgradeFail, 'SDBUpgradeFail');
  TranslateStr(SDBUpgradeAllSucc, 'SDBUpgradeAllSucc');
  TranslateStr(SDBUpgradeQuery, 'SDBUpgradeQuery');

  // CTOEditForm
  TranslateStr(SEditIsEmpty, 'SEditIsEmpty');
  TranslateStr(SGetCVSDir, 'SGetCVSDir');
  TranslateStr(SNotCVSDir, 'SNotCVSDir');
  TranslateStr(SExportSucc, 'SExportSucc');
  TranslateStr(SExportFail, 'SExportFail');
  TranslateStr(SImportSucc, 'SImportSucc');
  TranslateStr(SImportFail, 'SImportFail');

  Application.Title := SAppTitle;
end;

end.


