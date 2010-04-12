{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2009 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnManWizForm;
{* |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ�ר�ҹ�������
* ��Ԫ���ƣ�ר�ҹ�����������Ԫ
* ��Ԫ���ߣ���Х��LiuXiao�� liuxiao@cnpack.org
* ��    ע��
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�������ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2007.11.11 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, ComCtrls, ToolWin, ActnList, ImgList, Registry,
  Contnrs, ShellAPI, Menus, IniFiles, ActiveX,
  CnWizCompilerConst, CnShellUtils, CnLangStorage, CnHashLangStorage,
  CnClasses, CnLangMgr, CnWizLangID;

const
  csIDENames: array[TCnCompiler] of string = (
    'Delphi 5',
    'Delphi 6',
    'Delphi 7',
    'Delphi 8',
    'BDS 2005',
    'BDS 2006',
    'RAD Studio 2007',
    'RAD Studio 2009',
    'RAD Studio 2010',
    'C++Builder 5',
    'C++Builder 6');

  csCmdShortIDENames: array[TCnCompiler] of string = (
    'Delphi5',
    'Delphi6',
    'Delphi7',
    'Delphi8',
    'BDS2005',
    'BDS2006',
    'RADStudio2007',
    'RADStudio2009',
    'RADStudio2010',
    'BCB5',
    'BCB6');

  csRegPaths: array[TCnCompiler] of string = (
    '\Software\Borland\Delphi\5.0',
    '\Software\Borland\Delphi\6.0',
    '\Software\Borland\Delphi\7.0',
    '\Software\Borland\BDS\2.0',
    '\Software\Borland\BDS\3.0',
    '\Software\Borland\BDS\4.0',
    '\Software\Borland\BDS\5.0',
    '\Software\CodeGear\BDS\6.0',
    '\Software\CodeGear\BDS\7.0',
    '\Software\Borland\C++Builder\5.0',
    '\Software\Borland\C++Builder\6.0');

  csCnPackRegPath = '\Software\CnPack\CnWizards\';

  csCnPackDisabledExperts = 'DisabledExperts\';

var
  IDEInstalled: array[TCnCompiler] of Boolean =
    (False, False, False, False, False, False, False, False, False, False, False);

  IDEWizardsList: array[TCnCompiler] of TObjectList =
    (nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil);

  IDEWizardsChanged: array[TCnCompiler] of Boolean =
    (False, False, False, False, False, False, False, False, False, False, False);

type

  TCnWizardItem = class(TPersistent)
  {* ����һר����Ŀ}
  private
    FRemoved: Boolean;
    FEnabled: Boolean;
    FWizardName: string;
    FWizardPath: string;
  public
    property Removed: Boolean read FRemoved write FRemoved;
    property Enabled: Boolean read FEnabled write FEnabled;
    property WizardName: string read FWizardName write FWizardName;
    property WizardPath: string read FWizardPath write FWizardPath;
  end;

  TCnManageWizardForm = class(TForm)
    bvl1: TBevel;
    pnl1: TPanel;
    lbl2: TLabel;
    lbl1: TLabel;
    img1: TImage;
    bvlLine: TBevel;
    btnAbout: TButton;
    btnHelp: TButton;
    btnClose: TButton;
    pnlMain: TPanel;
    pnlLeft: TPanel;
    lstIDEs: TListBox;
    spl1: TSplitter;
    pnlRight: TPanel;
    tlb1: TToolBar;
    btnRefresh: TToolButton;
    btnSave: TToolButton;
    lvWizards: TListView;
    actlst1: TActionList;
    actRefresh: TAction;
    actSave: TAction;
    actSelectAll: TAction;
    actSelectNone: TAction;
    actSelectInverse: TAction;
    ilIDEs: TImageList;
    ilToolbar: TImageList;
    actAdd: TAction;
    actRemove: TAction;
    btnAdd: TToolButton;
    btnRemove: TToolButton;
    btnSelectAll: TToolButton;
    btnSelectNone: TToolButton;
    btnSelectInverse: TToolButton;
    btnHelp1: TToolButton;
    actHelp: TAction;
    btn1: TToolButton;
    btn2: TToolButton;
    btn3: TToolButton;
    actShowProp: TAction;
    btnShowProp: TToolButton;
    actExplore: TAction;
    actMoveUp: TAction;
    actMoveDown: TAction;
    btnExplore: TToolButton;
    btn4: TToolButton;
    dlgOpenWizard: TOpenDialog;
    pm1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    H1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    H2: TMenuItem;
    N7: TMenuItem;
    actShellMenu: TAction;
    N8: TMenuItem;
    btnShellMenu: TToolButton;
    R1: TMenuItem;
    S1: TMenuItem;
    lm1: TCnLangManager;
    hfs1: TCnHashLangFileStorage;
    procedure actRefreshExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actRemoveExecute(Sender: TObject);
    procedure actSelectAllExecute(Sender: TObject);
    procedure actSelectNoneExecute(Sender: TObject);
    procedure actSelectInverseExecute(Sender: TObject);
    procedure actHelpExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstIDEsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure lstIDEsClick(Sender: TObject);
    procedure lvWizardsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure actShowPropExecute(Sender: TObject);
    procedure actExploreExecute(Sender: TObject);
    procedure actMoveUpExecute(Sender: TObject);
    procedure actMoveDownExecute(Sender: TObject);
    procedure lvWizardsEdited(Sender: TObject; Item: TListItem;
      var S: string);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actShellMenuExecute(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure actlst1Update(Action: TBasicAction; var Handled: Boolean);
  private
    FSaved: Boolean;
    function GetWizardChanged: Boolean;

    { Private declarations }
    procedure TranslateStrings;
    procedure InitialIDENames;
    procedure CheckCmdParam;
    procedure CheckIDEInstalled;
    procedure LoadIDEWizards(IDE: TCnCompiler);
    procedure LoadIDEWizardsFromRoot(AReg: TRegistry; Root: string;
      WizardEnabled: Boolean; IDE: TCnCompiler);
    procedure ClearIDEWizardsRoot(AReg: TRegistry; Root: string);
    procedure UpdateWizardstoListView(IDE: TCnCompiler);

    property WizardChanged: Boolean read GetWizardChanged;
  protected
    procedure DoCreate; override;
  public
    { Public declarations }
  end;

var
  CnManageWizardForm: TCnManageWizardForm;

// ��ʾָ������İ�������
function ShowHelp(const Topic: string): Boolean;
// ȡ������������
function GetTopicHelpUrl(const Topic: string): string;
// ��������ȡ�ļ���
function GetFileFromLang(const FileName: string): string;

implementation

{$R *.DFM}

var
  CmdSelected: TCnCompiler = cnDelphi5;

  SCnAboutCaption: string = '����';
  SCnMessageHint: string = '��ʾ';
  SCnConfirmDeleteFmt: string = 'ȷ��ɾ��ר�� %s �� %s �µ�ע����Ϣ��';
  SCnChangedRefreshFmt: string = '%s �µ�ר��ע����Ϣ�Ѿ��ı䣬�Ƿ�����ı䣬�������룿';
  SCnWizardChangedFmt: string = '���� IDE ��ר��ע����Ϣ�Ѿ��ı䣬�˳�ǰ�Ƿ񱣴棿' + #13#10#13#10;
  SCnConfirmExit: string = 'ȷʵҪ�˳� CnPack IDE ר�ҹ������ߣ�';

  SCnManageWizAbout: string = 'CnPack IDE ר�ҹ�������' + #13#10 +
    '' + #13#10 +
    '�������� ��Х (LiuXiao)  liuxiao@cnpack.org' + #13#10 +
    '��Ȩ���� (C) 2001-2009 CnPack ������';

const
  csLangDir = 'Lang\';
  csHelpDir = 'Help\';
  csWizHelpIniFile = 'Help.ini';

// ��������ȡ�ļ���
function GetFileFromLang(const FileName: string): string;
begin
  if (CnLanguageManager.LanguageStorage <> nil) and
    (CnLanguageManager.LanguageStorage.CurrentLanguage <> nil) then
  begin
    Result := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0)) + csLangDir +
      CnLanguageManager.LanguageStorage.CurrentLanguage.LanguageDirName)
      + FileName;
  end
  else
  begin
    // �����Գ�ʼ��ʧ�ܣ��򷵻����ĵ����ݣ���ΪĬ�ϵĽ��������ĵ�
    Result := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + csLangDir
      + '2052\' + FileName;
  end;
end;

// ȡ������������
function GetTopicHelpUrl(const Topic: string): string;
const
  csSection = 'CnManageWiz';
var
  FileName: string;
begin
  Result := '';
  FileName := GetFileFromLang(csWizHelpIniFile);

  if not FileExists(FileName) then
    Exit;

  with TIniFile.Create(FileName) do
  try
    Result := ReadString(csSection, Topic, '');
    if Result = '' then
      WriteString(csSection, Topic, '');   // �����������ݹ��༭
  finally
    Free;
  end;
end;

// ��ʾָ������İ�������
function ShowHelp(const Topic: string): Boolean;
var
  Url: string;
  si: TStartupInfo;
  pi: TProcessInformation;
begin
  Url := GetTopicHelpUrl(Topic);
  if Url <> '' then
  begin
    Url := 'mk:@MSITStore:' + ExtractFilePath(ParamStr(0)) + csHelpDir + Url;
    ZeroMemory(@si, SizeOf(si));
    si.cb := SizeOf(si);
    ZeroMemory(@pi, SizeOf(pi));
    CreateProcess(nil, PChar('hh ' + Url),
      nil, nil, False, 0, nil, nil, si, pi);
    if pi.hProcess <> 0 then CloseHandle(pi.hProcess);
    if pi.hThread <> 0 then CloseHandle(pi.hThread);
    Result := True;
  end
  else
    Result := False;
end;

function GetAppRootDir(IDE: TCnCompiler): string;
var
  strAppFile: string;
  Reg: TRegistry; // ����ע�������
begin
  Result := '';
  Reg := TRegistry.Create; // ��������ע�������
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  if Reg.OpenKey(csRegPaths[IDE], False) then
  begin
    if Reg.ValueExists('App') then
    begin
      strAppFile := Reg.ReadString('App');
      if FileExists(strAppFile) and Reg.ValueExists('RootDir') then
        Result := IncludeTrailingBackslash(Reg.ReadString('RootDir'));
    end;
  end;

  Reg.CloseKey;
  FreeAndNil(Reg);
end;

procedure TCnManageWizardForm.actRefreshExecute(Sender: TObject);
var
  IDE: TCnCompiler;
  OldIndex: Integer;
begin
  if lstIDEs.ItemIndex >= 0 then
  begin
    IDE := TCnCompiler(lstIDEs.ItemIndex);
    if not IDEWizardsChanged[IDE] or
       (Application.MessageBox(PChar(Format(SCnChangedRefreshFmt,[csIDENames[IDE]])),
        PChar(SCnMessageHint), MB_YESNO + MB_ICONQUESTION) = IDYES) then
    begin
      if lvWizards.Selected <> nil then
        OldIndex := lvWizards.Selected.Index
      else
        OldIndex := -1;

      if not IDEInstalled[IDE] then
        Exit;

      IDEWizardsList[IDE].Clear;

      LoadIDEWizards(IDE);
      UpdateWizardstoListView(IDE);

      if (OldIndex > 0) and (OldIndex < lvWizards.Items.Count) then
        lvWizards.Items[OldIndex].Selected := True
      else if lvWizards.Items.Count > 0 then
        lvWizards.Items[lvWizards.Items.Count - 1].Selected := True;
    end;
  end;
end;

procedure TCnManageWizardForm.actSaveExecute(Sender: TObject);
var
  IDE: TCnCompiler;
  Reg: TRegistry;
  I: Integer;
  WItem: TCnWizardItem;
begin
  Reg := TRegistry.Create;
  Reg.RootKey := HKEY_CURRENT_USER;

  for IDE := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    if IDEWizardsChanged[IDE] then
    begin
      // ɾ��ԭ�еģ��������
      ClearIDEWizardsRoot(Reg, csRegPaths[IDE] + '\Experts');
      ClearIDEWizardsRoot(Reg, csCnPackRegPath + csCnPackDisabledExperts
        + csIDENames[IDE]);

      if Reg.OpenKey(csRegPaths[IDE] + '\Experts', True) then
      begin
        for I := 0 to IDEWizardsList[IDE].Count - 1 do // дʹ�ܵ�
        begin
          WItem := TCnWizardItem(IDEWizardsList[IDE].Items[I]);
          if WItem.Enabled then
            Reg.WriteString(WItem.WizardName, WItem.WizardPath);
        end;
        Reg.CloseKey;
      end;

      if Reg.OpenKey(csCnPackRegPath + csCnPackDisabledExperts
        + csIDENames[IDE], True) then
      begin
        for I := 0 to IDEWizardsList[IDE].Count - 1 do // д���õ�
        begin
          WItem := TCnWizardItem(IDEWizardsList[IDE].Items[I]);
          if not WItem.Enabled then
            Reg.WriteString(WItem.WizardName, WItem.WizardPath);
        end;
        Reg.CloseKey;
      end;

      IDEWizardsChanged[IDE] := False;
    end;
  end;
  Reg.Free;
  FSaved := True;
end;

procedure TCnManageWizardForm.actAddExecute(Sender: TObject);
var
  WItem: TCnWizardItem;
begin
  if IDEInstalled[TCnCompiler(lstIDEs.ItemIndex)] and dlgOpenWizard.Execute then
  begin
    WItem := TCnWizardItem.Create;

    WItem.Enabled := True;
    WItem.Removed := False;
    WItem.WizardName := ChangeFileExt(ExtractFileName(dlgOpenWizard.FileName), '');
    WItem.WizardPath := dlgOpenWizard.FileName;

    IDEWizardsList[TCnCompiler(lstIDEs.ItemIndex)].Add(WItem);
    UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));

    lvWizards.Items[lvWizards.Items.Count - 1].Selected := True;
    IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
  end;
end;

procedure TCnManageWizardForm.actRemoveExecute(Sender: TObject);
var
  OldIndex: Integer;
begin
  if lvWizards.Selected <> nil then
  begin
    if Application.MessageBox(PChar(Format(SCnConfirmDeleteFmt,
      [lvWizards.Selected.Caption, lstIDEs.Items[lstIDEs.ItemIndex]])),
      PChar(SCnMessageHint), MB_YESNO + MB_ICONQUESTION) <> IDYES then
      Exit;

    OldIndex := lvWizards.Selected.Index;
    IDEWizardsList[TCnCompiler(lstIDEs.ItemIndex)].Delete(OldIndex);
    UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));

    if OldIndex < lvWizards.Items.Count then
      lvWizards.Items[OldIndex].Selected := True
    else if lvWizards.Items.Count > 0 then
      lvWizards.Items[lvWizards.Items.Count - 1].Selected := True;
      
    IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
  end;
end;

procedure TCnManageWizardForm.actSelectAllExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvWizards.Items.Count - 1 do
    lvWizards.Items[I].Checked := True;
end;

procedure TCnManageWizardForm.actSelectNoneExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvWizards.Items.Count - 1 do
    lvWizards.Items[I].Checked := False;
end;

procedure TCnManageWizardForm.actSelectInverseExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to lvWizards.Items.Count - 1 do
    lvWizards.Items[I].Checked := not lvWizards.Items[I].Checked;
end;

procedure TCnManageWizardForm.actHelpExecute(Sender: TObject);
begin
  ShowHelp('CnManageWiz');
end;

procedure TCnManageWizardForm.FormCreate(Sender: TObject);
var
  Kind: TCnCompiler;
begin
  CoInitialize(nil);
  Application.Title := Caption;
  lbl1.Font.Style := [fsBold];

  CheckCmdParam;
  CheckIDEInstalled;

  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
    LoadIDEWizards(Kind);

  InitialIDENames;
  lstIDEs.OnClick(lstIDEs);
end;

procedure TCnManageWizardForm.InitialIDENames;
var
  Kind: TCnCompiler;
begin
  lstIDEs.Clear;
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
    lstIDEs.Items.Add(csIDENames[Kind]);

  if not IDEInstalled[CmdSelected] then
  begin
    for Kind := Low(TCnCompiler) to High(TCnCompiler) do
      if IDEInstalled[Kind] then
        lstIDEs.ItemIndex := Integer(Kind);
  end
  else
    lstIDEs.ItemIndex := Integer(CmdSelected);
end;

procedure TCnManageWizardForm.lstIDEsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ImgIdx, Margin, TextH: Integer;
  ListBox: TListBox;
begin
  ListBox := Control as TListBox;

  ImgIdx := Index mod ilIDEs.Count;
  TextH := ListBox.Canvas.TextHeight('Ag');

  // ѡ�б���������ɫ
  if (odSelected in State) then
  begin
    if IDEInstalled[TCnCompiler(ImgIdx)] then
      ListBox.Canvas.Brush.Color := clNavy
    else
      ListBox.Canvas.Brush.Color := clSilver;
  end
  else
  begin
    ListBox.Canvas.Brush.Color := clWindow;
  end;

  ListBox.Canvas.FillRect(Rect);

  // ѡ������ɫ
  if not IDEInstalled[TCnCompiler(ImgIdx)] then
    ListBox.Canvas.Font.Color := clGray
  else if (odSelected in State) then
    ListBox.Canvas.Font.Color := clWhite
  else
    ListBox.Canvas.Font.Color := clBlack;

//  if IDEWizardsChanged[TCnCompiler(Index)] then
//    ListBox.Canvas.Font.Style := [fsBold];

  // ������
  Margin := (ListBox.ItemHeight - TextH) div 2;
  ListBox.Canvas.TextOut(Rect.Left + ListBox.ItemHeight + 2, Rect.Top + Margin,
    csIDENames[TCnCompiler(ImgIdx)]);

  // �����Ƿ� Enable ��ͼ��
  Margin := (ListBox.ItemHeight - ilIDEs.Height) div 2;
  ilIDEs.Draw(ListBox.Canvas, Rect.Left + Margin, Rect.Top + Margin, ImgIdx,
    IDEInstalled[TCnCompiler(ImgIdx)]);
end;

procedure TCnManageWizardForm.CheckCmdParam;
var
  Kind: TCnCompiler;
begin
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    if FindCmdLineSwitch('I' + csCmdShortIDENames[Kind], ['-', '/'], True) then
    begin
      CmdSelected := Kind;
      Exit;
    end;
  end;
end;

procedure TCnManageWizardForm.CheckIDEInstalled;
var
  Kind: TCnCompiler;
begin
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    IDEInstalled[Kind] := GetAppRootDir(Kind) <> '';
    if IDEInstalled[Kind] then
      IDEWizardsList[Kind] := TObjectList.Create;
  end;
end;

procedure TCnManageWizardForm.FormDestroy(Sender: TObject);
var
  Kind: TCnCompiler;
begin
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
    FreeAndNil(IDEWizardsList[Kind]);
  CoUninitialize;
end;

// ��ע����ж���ĳ���汾�� IDE ר���б�
procedure TCnManageWizardForm.LoadIDEWizards(IDE: TCnCompiler);
var
  Reg: TRegistry;

  procedure DeleteDuplicated;
  var
    I, J: Integer;
    WItem1, WItem2: TCnWizardItem;
  begin
    if not IDEInstalled[IDE] then
      Exit;

    I := 0;

    while I < IDEWizardsList[IDE].Count do
    begin
      J := I + 1;
      WItem1 := TCnWizardItem(IDEWizardsList[IDE].Items[I]);

      while J < IDEWizardsList[IDE].Count do
      begin
        WItem2 := TCnWizardItem(IDEWizardsList[IDE].Items[J]);
        if WItem1.WizardName = WItem2.WizardName then
        begin
          if WItem1.Enabled and not WItem2.Enabled then // ǰ���ʹ�ܣ������˺���Ĳ�ʹ��
          begin
            IDEWizardsList[IDE].Delete(J);
            Continue;
          end;
        end;
        Inc(J);
      end;
      Inc(I);
    end;
  end;

begin
  Reg := TRegistry.Create; // ��������ע�������
  Reg.RootKey := HKEY_CURRENT_USER;

  LoadIDEWizardsFromRoot(Reg, csRegPaths[IDE] + '\Experts', True, IDE);
  LoadIDEWizardsFromRoot(Reg, csCnPackRegPath + csCnPackDisabledExperts
    + csIDENames[IDE], False, IDE);

  FreeAndNil(Reg);
  DeleteDuplicated;
end;


procedure TCnManageWizardForm.LoadIDEWizardsFromRoot(AReg: TRegistry;
  Root: string; WizardEnabled: Boolean; IDE: TCnCompiler);
var
  I: Integer;
  List: TStrings;
  Item: TCnWizardItem;
begin
  if IDEInstalled[IDE] and AReg.OpenKey(Root, False) then
  begin
    List := TStringList.Create;
    AReg.GetValueNames(List);

    for I := 0 to List.Count - 1 do
    begin
      Item := TCnWizardItem.Create;

      Item.WizardName := List[I];
      Item.WizardPath := AReg.ReadString(List[I]);;
      Item.Enabled := WizardEnabled;

      IDEWizardsList[IDE].Add(Item);
    end;
    IDEWizardsChanged[IDE] := False;
    AReg.CloseKey;
  end;
end;

procedure TCnManageWizardForm.lstIDEsClick(Sender: TObject);
begin
  UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));
  if lvWizards.Items.Count > 0 then
    lvWizards.Items[0].Selected := True;
end;

// ��WizardList�����ݸ��µ�ListView��
procedure TCnManageWizardForm.UpdateWizardstoListView(IDE: TCnCompiler);
var
  I: Integer;
  WItem: TCnWizardItem;
  LItem: TListItem;
  OldChange: TLVChangeEvent;
begin
  OldChange := lvWizards.OnChange;
  lvWizards.OnChange := nil;
  lvWizards.Items.Clear;
  lvWizards.OnChange := OldChange;
  
  if IDEWizardsList[IDE] = nil then
    Exit;

  lvWizards.Items.BeginUpdate;

  for I := 0 to IDEWizardsList[IDE].Count - 1 do
  begin
    WItem := TCnWizardItem(IDEWizardsList[IDE].Items[I]);
    LItem := lvWizards.Items.Add;
    LItem.Caption := WItem.WizardName;
    LItem.SubItems.Add(WItem.WizardPath);
    LItem.Checked := WItem.Enabled;
    LItem.Data := WItem;
  end;
  lvWizards.Items.EndUpdate;
end;

// ��ListView�Ľڵ�Check״̬���µ�WizardList�С�
procedure TCnManageWizardForm.lvWizardsChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
  WItem: TCnWizardItem;
begin
  if csDestroying in ComponentState then Exit;

  if (Change = ctState) and (Item.Data <> nil) then
  begin
    if TObject(Item.Data) is TCnWizardItem then
    begin
      WItem := TCnWizardItem(Item.Data);

      if WItem.Enabled <> Item.Checked then
      begin
        WItem.Enabled := Item.Checked;
        IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
      end;
    end;
  end;
end;

procedure TCnManageWizardForm.actShowPropExecute(Sender: TObject);
var
  SEI: SHELLEXECUTEINFO;
  F: array[0..255] of Char;
begin
  if lvWizards.Selected <> nil then
  begin
    StrCopy(@F[0], PChar(lvWizards.Selected.SubItems[0]));
    with SEI do
    begin
      cbSize := SizeOf(SEI);
      fMask := SEE_MASK_NOCLOSEPROCESS or SEE_MASK_INVOKEIDLIST or
        SEE_MASK_FLAG_NO_UI;
      Wnd := 0;
      lpVerb := 'properties';
      lpFile := PChar(@F[0]);
      lpParameters := nil;
      lpDirectory := nil;
      nShow := 0;
      hInstApp := 0;
      lpIDList := nil;
    end;
    ShellExecuteEx(@SEI);
  end;
end;

procedure TCnManageWizardForm.actExploreExecute(Sender: TObject);
begin
  if lvWizards.Selected <> nil then
    WinExec(PChar(Format('EXPLORER.EXE /e,/select,%s',
     [lvWizards.Selected.SubItems[0]])), SW_SHOWNORMAL);
end;

procedure TCnManageWizardForm.actMoveUpExecute(Sender: TObject);
var
  OldIndex: Integer;
begin
  if lvWizards.Selected <> nil then
  begin
    if lvWizards.Selected.Index > 0 then
    begin
      OldIndex := lvWizards.Selected.Index;
      IDEWizardsList[TCnCompiler(lstIDEs.ItemIndex)].Exchange
        (lvWizards.Selected.Index, lvWizards.Selected.Index - 1);
      UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));
      lvWizards.Items[OldIndex - 1].Selected := True;
      IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
    end;
  end;
end;

procedure TCnManageWizardForm.actMoveDownExecute(Sender: TObject);
var
  OldIndex: Integer;
begin
  if lvWizards.Selected <> nil then
  begin
    if lvWizards.Selected.Index < lvWizards.Items.Count - 1 then
    begin
      OldIndex := lvWizards.Selected.Index;
      IDEWizardsList[TCnCompiler(lstIDEs.ItemIndex)].Exchange
        (lvWizards.Selected.Index, lvWizards.Selected.Index + 1);
      UpdateWizardstoListView(TCnCompiler(lstIDEs.ItemIndex));
      lvWizards.Items[OldIndex + 1].Selected := True;
      IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
    end;
  end;
end;

procedure TCnManageWizardForm.lvWizardsEdited(Sender: TObject;
  Item: TListItem; var S: String);
var
  WItem: TCnWizardItem;
begin
  if csDestroying in ComponentState then Exit;

  if S = '' then S := Item.Caption;
  if (Item.Data <> nil) or (S <> '') then
  begin
    if TObject(Item.Data) is TCnWizardItem then
    begin
      WItem := TCnWizardItem(Item.Data);

      if WItem.WizardName <> S then
      begin
        WItem.WizardName := S;
        IDEWizardsChanged[TCnCompiler(lstIDEs.ItemIndex)] := True;
      end;
    end;
  end;
end;

procedure TCnManageWizardForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

function TCnManageWizardForm.GetWizardChanged: Boolean;
var
  Kind: TCnCompiler;
begin
  Result := False;
  for Kind := Low(TCnCompiler) to High(TCnCompiler) do
  begin
    Result := Result or IDEWizardsChanged[Kind];
    if Result then
      Exit;
  end;
end;

procedure TCnManageWizardForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Kind: TCnCompiler;
  IDENames: TStrings;
begin
  if WizardChanged then
  begin
    IDENames := TStringList.Create;
    for Kind := Low(TCnCompiler) to High(TCnCompiler) do
    begin
      if IDEWizardsChanged[Kind] then
        IDENames.Add(csIDENames[Kind]);
    end;

    case Application.MessageBox(PChar(SCnWizardChangedFmt + IDENames.Text),
      PChar(SCnMessageHint), MB_YESNOCANCEL + MB_ICONQUESTION) of
      IDCANCEL:
        begin
          CanClose := False;
          Exit;
        end;
      IDYES:
        begin
          actSave.Execute;
        end;
      IDNO:
        begin
          ; // ֱ�ӹر�
        end;
    end;
    IDENames.Free;
  end
  else if FSaved then
    Exit
  else
    CanClose := Application.MessageBox(PChar(SCnConfirmExit),
      PChar(SCnMessageHint), MB_OKCANCEL + MB_ICONQUESTION) = IDOK;
end;

procedure TCnManageWizardForm.actShellMenuExecute(Sender: TObject);
begin
  if lvWizards.Selected <> nil then
    if FileExists(lvWizards.Selected.SubItems[0]) then
      DisplayContextMenu(lvWizards.Handle, lvWizards.Selected.SubItems[0],
        lvWizards.ScreenToClient(Mouse.CursorPos));
end;

procedure TCnManageWizardForm.btnAboutClick(Sender: TObject);
begin
  Application.MessageBox(PChar(SCnManageWizAbout), PChar(SCnAboutCaption), MB_OK +
    MB_ICONINFORMATION);
end;

procedure TCnManageWizardForm.ClearIDEWizardsRoot(AReg: TRegistry;
  Root: string);
var
  List: TStrings;
  I: Integer;
begin
  if AReg.OpenKey(Root, False) then
  begin
    List := TStringList.Create;

    AReg.GetValueNames(List);
    for I := 0 to List.Count - 1 do
      AReg.DeleteValue(List[I]);

    AReg.CloseKey;
    List.Free;
  end;
end;

procedure TCnManageWizardForm.actlst1Update(Action: TBasicAction;
  var Handled: Boolean);
var
  lvSel, lvEmpty: Boolean;
begin
  lvSel := lvWizards.Selected <> nil;
  lvEmpty := lvWizards.Items.Count = 0;

  if (Action = actRemove) or (Action = actExplore) or (Action = actShowProp)
    or (Action = actShellMenu) then
    (Action as TCustomAction).Enabled := lvSel
  else if Action = actSave then
    (Action as TCustomAction).Enabled := WizardChanged
  else if (Action = actSelectAll) or (Action = actSelectNone) or
    (Action = actSelectInverse) then
    (Action as TCustomAction).Enabled := not lvEmpty
  else if (Action = actAdd) or (Action = actRefresh) then
    (Action as TCustomAction).Enabled := IDEInstalled[TCnCompiler(lstIDEs.ItemIndex)];

  Handled := True;
end;

procedure TCnManageWizardForm.DoCreate;
var
  I: Integer;
  LangID: DWORD;
begin
  if CnLanguageManager <> nil then
  begin
    hfs1.LanguagePath := ExtractFilePath(ParamStr(0)) + csLangDir;
    CnLanguageManager.LanguageStorage := hfs1;

    LangID := GetWizardsLanguageID;
    for I := 0 to CnLanguageManager.LanguageStorage.LanguageCount - 1 do
    begin
      if CnLanguageManager.LanguageStorage.Languages[I].LanguageID = LangID then
      begin
        CnLanguageManager.CurrentLanguageIndex := I;
        TranslateStrings;
        CnLanguageManager.TranslateForm(Self);
        Break;
      end;
    end;
  end;

  inherited;
end;

procedure TCnManageWizardForm.TranslateStrings;
begin
  TranslateStr(SCnAboutCaption, 'SCnAboutCaption');
  TranslateStr(SCnMessageHint, 'SCnMessageHint');
  TranslateStr(SCnConfirmDeleteFmt, 'SCnConfirmDeleteFmt');
  TranslateStr(SCnChangedRefreshFmt, 'SCnChangedRefreshFmt');
  TranslateStr(SCnWizardChangedFmt, 'SCnWizardChangedFmt');
  TranslateStr(SCnConfirmExit, 'SCnConfirmExit');
  TranslateStr(SCnManageWizAbout, 'SCnManageWizAbout');
end;

end.