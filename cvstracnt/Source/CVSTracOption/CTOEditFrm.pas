unit CTOEditFrm;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT 服务设置程序
* 单元名称：仓库设置窗体单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows Server 2003 + Delphi 7.0
* 本 地 化：该单元中的字符串暂不符合本地化处理方式
* 单元标识：$Id: CTOEditFrm.pas,v 1.3 2005/09/14 13:56:20 zjy Exp $
* 更新记录：2003.11.09
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, FileCtrl, CTConsts, CTOUtils, CnCommon, ComCtrls,
  IniFiles, CTPluginIntf, CTPluginMgr, CTUtils, CTMultiLangFrm, ExtCtrls;

type
  TCTOEditForm = class(TCTMultiLangForm)
    btnOK: TButton;
    btnCancel: TButton;
    PageControl: TPageControl;
    tsOption: TTabSheet;
    tsHelp: TTabSheet;
    grp1: TGroupBox;
    lbl1: TLabel;
    lbl3: TLabel;
    lbl2: TLabel;
    Label1: TLabel;
    edtDatabase: TEdit;
    btnPath: TButton;
    cbbHome: TComboBox;
    cbbModule: TComboBox;
    chkPasswd: TCheckBox;
    edtCvsUser: TEdit;
    mmoHelp: TMemo;
    btnExport: TButton;
    btnImport: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ts3: TTabSheet;
    grp2: TGroupBox;
    lvPlugins: TListView;
    btnPluginConfig: TButton;
    lbl5: TLabel;
    edtCharset: TEdit;
    rgNotifyKind: TRadioGroup;
    lbl4: TLabel;
    cbbSCM: TComboBox;
    procedure btnOKClick(Sender: TObject);
    procedure btnPathClick(Sender: TObject);
    procedure chkPasswdClick(Sender: TObject);
    procedure cbbHomeChange(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rgNotifyKindChange(Sender: TObject);
    procedure lvPluginsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure btnPluginConfigClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvPluginsClick(Sender: TObject);
  private
    { Private declarations }
    FDBFile: string;
    FUpdating: Boolean;
    Actives: array of Boolean;
    function IsCVS: Boolean;
    procedure UpdateModules;
    procedure UpdatePlugins;
    procedure UpdateControls(Sender: TObject);
    procedure SaveActives;
  public
    { Public declarations }
  end;

function ShowEditForm(const ADBFile: string; var Info: TDBOptionInfo): Boolean;

implementation

{$R *.DFM}

function ShowEditForm(const ADBFile: string; var Info: TDBOptionInfo): Boolean;
begin
  with TCTOEditForm.Create(Application.MainForm) do
  try
    FDBFile := ADBFile;

    cbbSCM.ItemIndex := Ord(Info.SCM);
    
    GetRepositoryList(cbbHome.Items);
    cbbHome.Items.Insert(0, '');
    if (Info.Home <> '') and (cbbHome.Items.IndexOf(Info.Home) < 0) then
    begin
      cbbHome.Items.Insert(0, Info.Home);
      cbbHome.ItemIndex := cbbHome.Items.IndexOf(Info.Home);
    end
    else if (Info.Home <> '') and (cbbHome.Items.IndexOf(Info.Home) >= 0) then
      cbbHome.ItemIndex := cbbHome.Items.IndexOf(Info.Home)
    else if cbbHome.Items.Count > 0 then
      cbbHome.ItemIndex := 0;

    UpdateModules;
    cbbModule.Text := Info.Module;

    edtDatabase.Text := Info.Database;
    edtCvsUser.Text := Info.CvsUser;
    edtCharset.Text := Info.Charset;
    chkPasswd.Checked := Info.Passwd;
    rgNotifyKind.ItemIndex := Ord(Info.NotifyKind);

    chkPasswdClick(nil);
    rgNotifyKindChange(nil);
    UpdatePlugins;

    btnExport.Visible := FileExists(FDBFile);
    btnImport.Visible := btnExport.Visible;

    Result := ShowModal = mrOk;
    if Result then
    begin
      SaveActives;
      Info.Database := Trim(edtDatabase.Text);
      Info.SCM := TSCMKind(cbbSCM.ItemIndex);
      Info.Home := Trim(cbbHome.Text);
      Info.Module := Trim(cbbModule.Text);
      Info.CvsUser := Trim(edtCvsUser.Text);
      Info.Charset := Trim(edtCharset.Text);
      Info.Passwd := chkPasswd.Checked;
      Info.NotifyKind := TNotifyKind(TrimInt(rgNotifyKind.ItemIndex, 0,
        Ord(High(TNotifyKind))));
    end;
  finally
    Free;
  end;
end;

{ TCTOEditForm }

procedure TCTOEditForm.FormCreate(Sender: TObject);
var
  NotifyKind: TNotifyKind;
  SCM: TSCMKind;
begin
  inherited;
  PageControl.ActivePageIndex := 0;
  for NotifyKind := Low(TNotifyKind) to High(TNotifyKind) do
    rgNotifyKind.Items.Add(SNotifyKinds[NotifyKind]);
  for SCM := Low(TSCMKind) to High(TSCMKind) do
    cbbSCM.Items.Add(csSCMNames[SCM]);
  SetLength(Actives, PluginMgr.Count);
end;

procedure TCTOEditForm.FormDestroy(Sender: TObject);
begin
  Actives := nil;
end;

//------------------------------------------------------------------------------
// 仓库相关
//------------------------------------------------------------------------------

function TCTOEditForm.IsCVS: Boolean;
begin
  Result := TSCMKind(cbbSCM.ItemIndex) in [skNone, skCvs];
end;

procedure TCTOEditForm.UpdateModules;
var
  APath: string;
  Info: TSearchRec;
  Succ: Integer;
begin
  APath := Trim(cbbHome.Text);
  cbbModule.Items.Clear;
  if IsCVS and (APath <> '') and DirectoryExists(APath) then
  begin
    APath := MakePath(APath);
    Succ := FindFirst(APath + '*.*', faAnyFile - faVolumeID, Info);
    try
      while Succ = 0 do
      begin
        if ((Info.Attr and faDirectory) = faDirectory) and
          (Info.Name <> '.') and (Info.Name <> '..') and
          not SameText(Info.Name, 'CVSROOT') and
          not SameText(Info.Name, 'CVS') then
          cbbModule.Items.Add(Info.Name);
        Succ := FindNext(Info);
      end;
    finally
      FindClose(Info);
    end;
  end;
end;

procedure TCTOEditForm.btnPathClick(Sender: TObject);
var
  Dir: string;
begin
  Dir := cbbHome.Text;
  if GetDirectory(SGetCVSDir, Dir) then
    if not IsCVS or DirectoryExists(MakePath(Dir) + 'CVSROOT') or
      QueryDlg(SNotCVSDir) then
    begin
      Dir := FmtPath(Dir);
      if cbbHome.Items.IndexOf(Dir) < 0 then
        cbbHome.Items.Insert(0, Dir);
      cbbHome.ItemIndex := cbbHome.Items.IndexOf(Dir);
      UpdateModules;
    end;
end;

procedure TCTOEditForm.chkPasswdClick(Sender: TObject);
begin
  edtCvsUser.Enabled := chkPasswd.Checked;
end;

procedure TCTOEditForm.cbbHomeChange(Sender: TObject);
begin
  UpdateModules;
end;

procedure TCTOEditForm.btnOKClick(Sender: TObject);
begin
  if Trim(edtDatabase.Text) = '' then
    ErrorDlg(SEditIsEmpty)
  else
    ModalResult := mrOk;
end;

procedure TCTOEditForm.btnExportClick(Sender: TObject);
begin
  if SaveDialog.Execute then
    if ExportUsersToFile(FDBFile, SaveDialog.FileName) then
      InfoDlg(SExportSucc)
    else
      ErrorDlg(SExportFail);
end;

procedure TCTOEditForm.btnImportClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    if ImportUsersFromFile(FDBFile, OpenDialog.FileName) then
      InfoDlg(SImportSucc)
    else
      ErrorDlg(SImportFail);
end;

//------------------------------------------------------------------------------
// 任务单通知相关
//------------------------------------------------------------------------------

procedure TCTOEditForm.UpdatePlugins;
var
  i: Integer;
  PluginInfo: TPluginInfo;
begin
  lvPlugins.Items.BeginUpdate;
  FUpdating := True;
  try
    with TIniFile.Create(DataBaseFileNameToIniName(FDBFile)) do
    try
      lvPlugins.Clear;
      for i := 0 to PluginMgr.Count - 1 do
      begin
        Actives[i] := ReadBool(csActiveSection, PluginMgr[i].PluginID, False);
        PluginInfo := PluginMgr[i].GetPluginInfo;
        with lvPlugins.Items.Add do
        begin
          Caption := PluginInfo.Name;
          Checked := Actives[i];
          SubItems.Add(PluginInfo.Comment);
        end;
      end;
      if lvPlugins.Items.Count > 0 then
        lvPlugins.Selected := lvPlugins.Items[0];
    finally
      Free;
    end;
  finally
    FUpdating := False;
    lvPlugins.Items.EndUpdate;
  end;
  UpdateControls(nil);
end;

procedure TCTOEditForm.SaveActives;
var
  i: Integer;
begin
  with TIniFile.Create(DataBaseFileNameToIniName(FDBFile)) do
  try
    for i := 0 to PluginMgr.Count - 1 do
      WriteBool(csActiveSection, PluginMgr[i].PluginID, Actives[i]);
  finally
    Free;
  end;
end;

procedure TCTOEditForm.rgNotifyKindChange(Sender: TObject);
begin
  lvPlugins.Enabled := rgNotifyKind.ItemIndex = Ord(nkPlugin);
  UpdateControls(nil);
end;

procedure TCTOEditForm.UpdateControls(Sender: TObject);
begin
  btnPluginConfig.Enabled := lvPlugins.Enabled and Assigned(lvPlugins.Selected) and
    Actives[lvPlugins.Selected.Index] and
    PluginMgr[lvPlugins.Selected.Index].CanConfigDatabase;
end;

procedure TCTOEditForm.lvPluginsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  UpdateControls(nil);
end;

procedure TCTOEditForm.lvPluginsClick(Sender: TObject);
var
  i: Integer;
begin
  if not FUpdating then
  begin
    FUpdating := True;
    try
      if lvPlugins.Enabled then
      begin
        for i := 0 to lvPlugins.Items.Count - 1 do
          Actives[i] := lvPlugins.Items[i].Checked;
      end;
      UpdateControls(nil);
    finally
      FUpdating := False;
    end;
  end;
end;

procedure TCTOEditForm.btnPluginConfigClick(Sender: TObject);
begin
  if lvPlugins.Enabled and Assigned(lvPlugins.Selected) and
    Actives[lvPlugins.Selected.Index] and
    PluginMgr[lvPlugins.Selected.Index].CanConfigDatabase then
    PluginMgr[lvPlugins.Selected.Index].ConfigDatabase(Application.Handle,
      DataBaseFileNameToDBName(FDBFile), FDBFile, DataBaseFileNameToIniName(FDBFile));
end;

end.
