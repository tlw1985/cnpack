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

unit CnEditControlWrapper;
{* |<PRE>
================================================================================
* �������ƣ�CnPack IDE ר�Ұ�
* ��Ԫ���ƣ�IDE ��ع�����Ԫ
* ��Ԫ���ߣ��ܾ��� (zjy@cnpack.org)
* ��    ע���õ�Ԫ��װ�˶� IDE �� EditControl �Ĳ���
* ����ƽ̨��PWin2000Pro + Delphi 5.01
* ���ݲ��ԣ�PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6
* �� �� �����õ�Ԫ�е��ַ��������ϱ��ػ�������ʽ
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��2009.05.30 V1.3
*               �������� BDS �µĶ�����ҳ���л��仯֪ͨ
*           2008.08.20 V1.2
*               ����һ BDS �µ�������λ���仯֪ͨ�����������к��ػ����仯�����
*           2004.12.26 V1.1
*               ����һϵ�� BDS �µ�֪ͨ���ƺ����Լ��༭�����������֪ͨ
*           2004.12.26 V1.0
*               ������Ԫ��ʵ�ֹ���
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, Classes, Controls, SysUtils, Graphics, ToolsAPI, ExtCtrls,
  ComCtrls, TypInfo, Forms, Tabs, Registry, Contnrs,
  CnCommon, CnWizMethodHook, CnWizUtils, CnWizCompilerConst, CnWizNotifier,
  CnWizIdeUtils, CnWizOptions;
  
type

//==============================================================================
// ����༭���ؼ���װ��
//==============================================================================

{ TCnEditControlWrapper }

  TEditControlInfo = record
  {* ����༭��λ����Ϣ }
    TopLine: Integer;         // ���к�
    LinesInWindow: Integer;   // ������ʾ����
    LineCount: Integer;       // ���뻺����������
    CaretX: Integer;          // ���Xλ��
    CaretY: Integer;          // ���Yλ��
    CharXIndex: Integer;      // �ַ����
{$IFDEF BDS}
    LineDigit: Integer;       // �༭����������λ������100��Ϊ3, �������
{$ENDIF}
  end;

  TEditorChangeType = (
    ctView,                   // ��ǰ��ͼ�л�
    ctWindow,                 // �������С�β�б仯
    ctCurrLine,               // ��ǰ�����
    ctCurrCol,                // ��ǰ�����
    ctFont,                   // ������
    ctVScroll,                // �༭����ֱ����
    ctHScroll,                // �༭���������
    ctBlock,                  // ����
    ctModified,               // �༭�����޸�
{$IFDEF BDS}    
    ctLineDigit,              // �༭��������λ���仯����99��100
    ctViewBarChanged,         // BDS �µײ��� TabSet �ı�֪ͨ
    ctTabSetChanged,          // BDS �µ� TIDEGradientTabSet �ı�֪ͨ��
                              // �����������������������߲���ͬ�� ctView
{$ENDIF}
    ctElided,                 // �༭�����۵����ݲ�֧��
    ctUnElided                // �༭����չ�����ݲ�֧��
    );
    
  TEditorChangeTypes = set of TEditorChangeType;

  TEditorContext = record
    TopRow: Integer;
    BottomRow: Integer;
    LeftColumn: Integer;
    CurPos: TOTAEditPos;
    LineCount: Integer;
    LineText: string;
    ModTime: TDateTime;
    BlockValid: Boolean;
    EditView: Pointer;
{$IFDEF BDS}
    LineDigit: Integer;       // �༭����������λ������100��Ϊ3, �������
{$ENDIF}
  end;

  TEditorObject = class
  private
    FContext: TEditorContext;
    FEditControl: TControl;
    FEditWindow: TCustomForm;
    FEditView: IOTAEditView;
    FGutterWidth: Integer;
    FGutterChanged: Boolean;
    procedure SetEditView(AEditView: IOTAEditView);
    function GetGutterWidth: Integer;
  public
    constructor Create(AEditControl: TControl; AEditView: IOTAEditView);
    destructor Destroy; override;
    property Context: TEditorContext read FContext;
    property EditControl: TControl read FEditControl;
    property EditWindow: TCustomForm read FEditWindow;
    property EditView: IOTAEditView read FEditView;
    property GutterWidth: Integer read GetGutterWidth;
  end;

  THighlightItem = class
  private
    FBold: Boolean;
    FColorBk: TColor;
    FColorFg: TColor;
    FItalic: Boolean;
    FUnderline: Boolean;
  public
    property Bold: Boolean read FBold write FBold;
    property ColorBk: TColor read FColorBk write FColorBk;
    property ColorFg: TColor read FColorFg write FColorFg;
    property Italic: Boolean read FItalic write FItalic;
    property Underline: Boolean read FUnderline write FUnderline;
  end;

  TEditorPaintLineNotifier = procedure (Editor: TEditorObject;
    LineNum, LogicLineNum: Integer) of object;
  {* EditControl �ؼ����л���֪ͨ�¼����û����Դ˽����Զ������ }
  TEditorPaintNotifier = procedure (EditControl: TControl; EditView: IOTAEditView)
    of object;
  {* EditControl �ؼ���������֪ͨ�¼����û����Դ˽����Զ������ }
  TEditorNotifier = procedure (EditControl: TControl; EditWindow: TCustomForm;
    Operation: TOperation) of object;
  {* �༭��������ɾ��֪ͨ }
  TEditorChangeNotifier = procedure (Editor: TEditorObject; ChangeType:
    TEditorChangeTypes) of object;
  {* �༭�����֪ͨ }
  TKeyMessageNotifier = procedure (Key, ScanCode: Word; Shift: TShiftState;
    var Handled: Boolean) of object;
  {* �����¼� }

  TCnEditControlWrapper = class(TComponent)
  private
    CorIdeModule: HMODULE;
    FAfterPaintLineNotifiers: TList;
    FBeforePaintLineNotifiers: TList;
    FEditControlNotifiers: TList;
    FEditorChangeNotifiers: TList;
    FKeyDownNotifiers: TList;
    FKeyUpNotifiers: TList;
    FCharSize: TSize;
    FHighlights: TStringList;
    FPaintNotifyAvailable: Boolean;
    FPaintLineHook: TCnMethodHook;
    FSetEditViewHook: TCnMethodHook;
{$IFDEF BDS}
    FTabsChangeTypes: TEditorChangeTypes;
    FTabsChangedHook, FViewBarChangedHook: TCnMethodHook;
{$ENDIF}
    FEditorList: TObjectList;
    FEditControlList: TList;
    FOptionChanged: Boolean;
    FOptionDlgVisible: Boolean;
    procedure AddNotifier(List: TList; Notifier: TMethod);
    function CalcCharSize: Boolean;
    procedure GetHighlightFromReg;
    procedure ClearAndFreeList(var List: TList);
    function IndexOf(List: TList; Notifier: TMethod): Integer;
    procedure InitEditControlHook;
    procedure RemoveNotifier(List: TList; Notifier: TMethod);
    function UpdateCharSize: Boolean;
    procedure EditControlProc(EditWindow: TCustomForm; EditControl:
      TControl; Context: Pointer);
    procedure UpdateEditControlList;
    procedure CheckOptionDlg;
    function GetEditorContext(Editor: TEditorObject): TEditorContext;
    procedure OnActiveFormChange(Sender: TObject);
    procedure OnSourceEditorNotify(SourceEditor: IOTASourceEditor;
      NotifyType: TCnWizSourceEditorNotifyType; EditView: IOTAEditView);
    procedure ApplicationMessage(var Msg: TMsg; var Handled: Boolean);
    procedure OnCallWndProcRet(Handle: HWND; Control: TWinControl; Msg: TMessage);
    procedure OnIdle(Sender: TObject);
    function GetEditorCount: Integer;
    function GetEditors(Index: Integer): TEditorObject;
    function GetHighlight(Index: Integer): THighlightItem;
    function GetHighlightCount: Integer;
    function GetHighlightName(Index: Integer): string;
    procedure ClearHighlights;
  protected
    procedure DoAfterPaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    procedure DoBeforePaintLine(Editor: TEditorObject; LineNum, LogicLineNum: Integer);
    procedure DoAfterElide(EditControl: TControl);   // �ݲ�֧��
    procedure DoAfterUnElide(EditControl: TControl); // �ݲ�֧��
    procedure DoEditControlNotify(EditControl: TControl; Operation: TOperation);
    procedure DoEditorChange(Editor: TEditorObject; ChangeType: TEditorChangeTypes);
{$IFDEF BDS}
    procedure DoTabSetIdleChange(Sender: TObject); // �� IDLE ʱ������
{$ENDIF}
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    procedure CheckNewEditor(EditControl: TControl; View: IOTAEditView);
    function AddEditor(EditControl: TControl; View: IOTAEditView): Integer;
    procedure DeleteEditor(EditControl: TControl);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function IndexOfEditor(EditControl: TControl): Integer;
    property Editors[Index: Integer]: TEditorObject read GetEditors;
    property EditorCount: Integer read GetEditorCount;

    function IndexOfHighlight(const Name: string): Integer;
    property HighlightCount: Integer read GetHighlightCount;
    property HighlightNames[Index: Integer]: string read GetHighlightName;
    property Highlights[Index: Integer]: THighlightItem read GetHighlight;
    
    function GetCharHeight: Integer;
    {* ���ر༭���и� }
    function GetCharWidth: Integer;
    {* ���ر༭���ֿ� }
    function GetCharSize: TSize;
    {* ���ر༭���иߺ��ֿ� }
    function GetEditControlInfo(EditControl: TControl): TEditControlInfo;
    {* ���ر༭����ǰ��Ϣ }
    function GetEditControlCanvas(EditControl: TControl): TCanvas;
    {* ���ر༭���Ļ�������}
    function GetEditView(EditControl: TControl): IOTAEditView;
    {* ����ָ���༭����ǰ������ EditView }
    function GetTopMostEditControl: TControl;
    {* ���ص�ǰ��ǰ�˵� EditControl}
    function GetEditViewFromTabs(TabControl: TXTabControl; Index: Integer):
      IOTAEditView;
    {* ���� TabControl ָ��ҳ������ EditView }
    procedure GetAttributeAtPos(EditControl: TControl; const EdPos: TOTAEditPos;
      IncludeMargin: Boolean; var Element, LineFlag: Integer);
    {* ����ָ��λ�õĸ������ԣ������滻 IOTAEditView �ĺ��������߿��ܻᵼ�±༭�����⡣
       ��ָ��λ�ÿ��� CursorPos �������� utf8 ���ֽ�λ�ã�һ�����ֿ� 3 �� }
    function GetLineIsElided(EditControl: TControl; LineNum: Integer): Boolean;
    {* ����ָ�����Ƿ��۵����������۵���ͷβ��Ҳ���Ƿ����Ƿ����ء�
       ֻ�� BDS ��Ч������������� False}

{$IFDEF BDS}
    function GetPointFromEdPos(EditControl: TControl; APos: TOTAEditPos): TPoint;
    {* ���� BDS �б༭���ؼ�ĳ�ַ�λ�ô������ֻ꣬�� BDS ����Ч}
{$ENDIF}

    procedure MarkLinesDirty(EditControl: TControl; Line: Integer; Count: Integer);
    {* ��Ǳ༭��ָ������Ҫ�ػ棬��Ļ�ɼ���һ��Ϊ 0 }
    procedure EditorRefresh(EditControl: TControl; DirtyOnly: Boolean);
    {* ˢ�±༭�� }
    function GetTextAtLine(EditControl: TControl; LineNum: Integer): string;
    {* ȡָ���е��ı���ע��ú���ȡ�����ı��ǽ� Tab ��չ�ɿո�ģ����ʹ��
       ConvertPos ��ת���� EditPos ���ܻ������⡣ֱ�ӽ� CharIndex + 1 ��ֵ
       �� EditPos.Col ���ɡ� }

    procedure RepaintEditControls;
    {* ����ǿ���ñ༭���ؼ����ػ�}

    procedure AddKeyDownNotifier(Notifier: TKeyMessageNotifier);
    {* ���ӱ༭������֪ͨ }
    procedure RemoveKeyDownNotifier(Notifier: TKeyMessageNotifier);
    {* ɾ���༭������֪ͨ }

    procedure AddKeyUpNotifier(Notifier: TKeyMessageNotifier);
    {* ���ӱ༭��������֪ͨ }
    procedure RemoveKeyUpNotifier(Notifier: TKeyMessageNotifier);
    {* ɾ���༭��������֪ͨ }

    procedure AddBeforePaintLineNotifier(Notifier: TEditorPaintLineNotifier);
    {* ���ӱ༭�������ػ�ǰ֪ͨ }
    procedure RemoveBeforePaintLineNotifier(Notifier: TEditorPaintLineNotifier);
    {* ɾ���༭�������ػ�ǰ֪ͨ }

    procedure AddAfterPaintLineNotifier(Notifier: TEditorPaintLineNotifier);
    {* ���ӱ༭�������ػ��֪ͨ }
    procedure RemoveAfterPaintLineNotifier(Notifier: TEditorPaintLineNotifier);
    {* ɾ���༭�������ػ��֪ͨ }

    procedure AddEditControlNotifier(Notifier: TEditorNotifier);
    {* ���ӱ༭��������ɾ��֪ͨ }
    procedure RemoveEditControlNotifier(Notifier: TEditorNotifier);
    {* ɾ���༭��������ɾ��֪ͨ }

    procedure AddEditorChangeNotifier(Notifier: TEditorChangeNotifier);
    {* ���ӱ༭�����֪ͨ }
    procedure RemoveEditorChangeNotifier(Notifier: TEditorChangeNotifier);
    {* ɾ���༭�����֪ͨ }

    property PaintNotifyAvailable: Boolean read FPaintNotifyAvailable;
    {* ���ر༭�����ػ�֪ͨ�����з���� }
  end;

function EditControlWrapper: TCnEditControlWrapper;

implementation

{$IFDEF DEBUG}
uses
  CnDebug;
{$ENDIF}

type
  PCnWizNotifierRecord = ^TCnWizNotifierRecord;
  TCnWizNotifierRecord = record
    Notifier: TMethod;
  end;

  NoRef = Pointer;

  TCustomControlHack = class(TCustomControl);

{$IFDEF BDS}
const
{$IFDEF BDS2005}
  CnWideControlCanvasOffset = $230;
  // BDS 2005 �� EditControl �� Canvas ���Ե�ƫ����
{$ELSE}
  // BDS 2006/2007 �� EditControl �� Canvas ���Ե�ƫ����
  CnWideControlCanvasOffset = $260;
{$ENDIF}
{$ENDIF}

var
  FEditControlWrapper: TCnEditControlWrapper = nil;

function EditControlWrapper: TCnEditControlWrapper;
begin
  if FEditControlWrapper = nil then
    FEditControlWrapper := TCnEditControlWrapper.Create(nil);
  Result := FEditControlWrapper;
end;

{$IFDEF BDS}

// ���һ�����м�λ��Digit�ǽ�����
function GetLineDigit(LineCount, Digit: Integer): Integer;
begin
  Result := 0;
  if Digit <= 0 then Exit;
  if LineCount < 0 then
    LineCount := -LineCount;

  Inc(Result);
  while LineCount >= Digit do
  begin
    Inc(Result);
    LineCount := LineCount div Digit;
  end;
end;

{$ENDIF}

{ TEditorObject }

constructor TEditorObject.Create(AEditControl: TControl;
  AEditView: IOTAEditView);
begin
  inherited Create;
  FEditControl := AEditControl;
  FEditWindow := TCustomForm(AEditControl.Owner);
  SetEditView(AEditView);
end;

destructor TEditorObject.Destroy;
begin
  SetEditView(nil);
  inherited;
end;

function TEditorObject.GetGutterWidth: Integer;
begin
  if FGutterChanged and Assigned(FEditView) then
  begin
  {$IFDEF BDS}
    FGutterWidth := EditControlWrapper.GetPointFromEdPos(FEditControl,
      OTAEditPos(1, 1)).X;
    FGutterWidth := FGutterWidth + (FEditView.LeftColumn - 1) *
      FEditControlWrapper.FCharSize.cx;
  {$ELSE}
    FGutterWidth := FEditView.Buffer.BufferOptions.LeftGutterWidth;
  {$ENDIF}

    FGutterChanged := False;
  end;
  Result := FGutterWidth;  
end;

procedure TEditorObject.SetEditView(AEditView: IOTAEditView);
begin
  NoRef(FEditView) := NoRef(AEditView);
end;

//==============================================================================
// ����༭���ؼ���װ��
//==============================================================================

{ TCnEditControlWrapper }

const
  STEditViewClass = 'TEditView';
{$IFDEF COMPILER8_UP}
  SPaintLineName = '@Editorcontrol@TCustomEditControl@PaintLine$qqrr16Ek@TPaintContextiii';
  SMarkLinesDirtyName = '@Editorcontrol@TCustomEditControl@MarkLinesDirty$qqriusi';
  SEdRefreshName = '@Editorcontrol@TCustomEditControl@EdRefresh$qqro';
  SGetTextAtLineName = '@Editorcontrol@TCustomEditControl@GetTextAtLine$qqri';
  SGetOTAEditViewName = '@Editorbuffer@TEditView@GetOTAEditView$qqrv';
  SSetEditViewName = '@Editorcontrol@TCustomEditControl@SetEditView$qqrp22Editorbuffer@TEditView';
  SGetAttributeAtPosName = '@Editorcontrol@TCustomEditControl@GetAttributeAtPos$qqrrx9Ek@TEdPosrit2oo';

  SLineIsElidedName = '@Editorcontrol@TCustomEditControl@LineIsElided$qqri';
  SPointFromEdPosName = '@Editorcontrol@TCustomEditControl@PointFromEdPos$qqrrx9Ek@TEdPosoo';
  STabsChangedName = '@Editorform@TEditWindow@TabsChanged$qqrp14System@TObject';
  SViewBarChangedName = '@Editorform@TEditWindow@ViewBarChange$qqrp14System@TObjectiro';
{$ELSE}
  SPaintLineName = '@Editors@TCustomEditControl@PaintLine$qqrr16Ek@TPaintContextisi';
  SMarkLinesDirtyName = '@Editors@TCustomEditControl@MarkLinesDirty$qqriusi';
  SEdRefreshName = '@Editors@TCustomEditControl@EdRefresh$qqro';
  SGetTextAtLineName = '@Editors@TCustomEditControl@GetTextAtLine$qqri';
  SGetOTAEditViewName = '@Editors@TEditView@GetOTAEditView$qqrv';
  SSetEditViewName = '@Editors@TCustomEditControl@SetEditView$qqrp17Editors@TEditView';
{$IFDEF COMPILER7_UP}
  SGetAttributeAtPosName = '@Editors@TCustomEditControl@GetAttributeAtPos$qqrrx9Ek@TEdPosrit2oo';
{$ELSE}
  SGetAttributeAtPosName = '@Editors@TCustomEditControl@GetAttributeAtPos$qqrrx9Ek@TEdPosrit2o';
{$ENDIF}
{$ENDIF}

type
  TControlHack = class(TControl);
  TPaintLineProc = function (Self: TObject; Ek: Pointer;
    LineNum, V1, V2: Integer): Integer; register;
  TMarkLinesDirtyProc = procedure(Self: TObject; LineNum: Integer; Count: Word;
    Flag: Integer); register;
  TEdRefreshProc = procedure(Self: TObject; DirtyOnly: Boolean); register;
  TGetTextAtLineProc = function(Self: TObject; LineNum: Integer): string; register;
  TGetOTAEditViewProc = function(Self: TObject): IOTAEditView; register;
  TSetEditViewProc = function(Self: TObject; EditView: TObject): Integer;
  TLineIsElidedProc = function(Self: TObject; LineNum: Integer): Boolean;

{$IFDEF BDS}
  TPointFromEdPosProc = function(Self: TObject; const EdPos: TOTAEditPos;
    B1, B2: Boolean): TPoint;
  TTabsChangedProc = procedure(Self: TObject; Sender: TObject);
  TViewBarChangedProc = procedure(Self: TObject; Sender: TObject;
    NewTab: Integer; var AllowChange: Boolean);
{$ENDIF}

{$IFDEF COMPILER7_UP}
  TGetAttributeAtPosProc = procedure(Self: TObject; const EdPos: TOTAEditPos;
    var Element, LineFlag: Integer; B1, B2: Boolean);
{$ELSE}
  TGetAttributeAtPosProc = procedure(Self: TObject; const EdPos: TOTAEditPos;
    var Element, LineFlag: Integer; B1: Boolean);
{$ENDIF}

var
  PaintLine: TPaintLineProc = nil;
  GetOTAEditView: TGetOTAEditViewProc = nil;
  DoGetAttributeAtPos: TGetAttributeAtPosProc = nil;
  DoMarkLinesDirty: TMarkLinesDirtyProc = nil;
  EdRefresh: TEdRefreshProc = nil;
  DoGetTextAtLine: TGetTextAtLineProc = nil;
  SetEditView: TSetEditViewProc = nil;
  LineIsElided: TLineIsElidedProc = nil;
{$IFDEF BDS}
  PointFromEdPos: TPointFromEdPosProc = nil;
  TabsChanged: TTabsChangedProc = nil;
  ViewBarChanged: TViewBarChangedProc = nil;
{$ENDIF}

  PaintLineLock: TRTLCriticalSection;

function EditorChangeTypesToStr(ChangeType: TEditorChangeTypes): string;
var
  AType: TEditorChangeType;
begin
  Result := '';
  for AType := Low(AType) to High(AType) do
    if AType in ChangeType then
      if Result = '' then
        Result := GetEnumName(TypeInfo(TEditorChangeType), Ord(AType))
      else
        Result := Result + ', ' + GetEnumName(TypeInfo(TEditorChangeType), Ord(AType));
  Result := '[' + Result + ']';
end;

{$IFDEF BDS}

// �滻���� TabsChanged �������� TIDEGradientTabSet �� OnChange �����¼�
procedure MyTabsChanged(Self: TObject; Sender: TObject);
begin
  FEditControlWrapper.FTabsChangedHook.UnhookMethod;
  try
    try
      TabsChanged(Self, Sender);
    except
      on E: Exception do
        DoHandleException(E.Message);
    end;
  finally
    FEditControlWrapper.FTabsChangedHook.HookMethod;
  end;

  // OnChanged �¼�������󣬱༭����ûˢ�£������ӳٵ� Idle ʱ��֪ͨ
  FEditControlWrapper.FTabsChangeTypes := [ctTabSetChanged];
  CnWizNotifierServices.ExecuteOnApplicationIdle(FEditControlWrapper.DoTabSetIdleChange);
end;

// �滻���� TabsChanged �������� TIDEGradientTabSet �� OnChange �����¼�
procedure MyViewBarChanged(Self: TObject; Sender: TObject;
  NewTab: Integer; var AllowChange: Boolean);
begin
  FEditControlWrapper.FViewBarChangedHook.UnhookMethod;
  try
    try
      ViewBarChanged(Self, Sender, NewTab, AllowChange);
    except
      on E: Exception do
        DoHandleException(E.Message);
    end;
  finally
    FEditControlWrapper.FViewBarChangedHook.HookMethod;
  end;

  // OnChanged �¼�������󣬱༭����ûˢ�£������ӳٵ� Idle ʱ��֪ͨ
  FEditControlWrapper.FTabsChangeTypes := [ctViewBarChanged];
  CnWizNotifierServices.ExecuteOnApplicationIdle(FEditControlWrapper.DoTabSetIdleChange);
end;

{$ENDIF}

// �滻���� TCustomEditControl.PaintLine ����
function MyPaintLine(Self: TObject; Ek: Pointer; LineNum, LogicLineNum, V2: Integer): Integer;
var
  Idx: Integer;
  Editor: TEditorObject;
begin
  Result := 0;
  EnterCriticalSection(PaintLineLock);
  try
    Editor := nil;
    if IsIdeEditorForm(TCustomForm(TControl(Self).Owner)) then
    begin
      Idx := FEditControlWrapper.IndexOfEditor(TControl(Self));
      if Idx >= 0 then
      begin
        Editor := FEditControlWrapper.GetEditors(Idx);
      end;
    end;

    if Editor <> nil then
    begin
    {$IFDEF BDS}
      FEditControlWrapper.DoBeforePaintLine(Editor, LineNum, LogicLineNum);
    {$ELSE}
      FEditControlWrapper.DoBeforePaintLine(Editor, LineNum, LineNum);
    {$ENDIF}
    end;

    FEditControlWrapper.FPaintLineHook.UnhookMethod;
    try
      try
        Result := PaintLine(Self, Ek, LineNum, LogicLineNum, V2);
      except
        on E: Exception do
          DoHandleException(E.Message);
      end;
    finally
      FEditControlWrapper.FPaintLineHook.HookMethod;
    end;

    if Editor <> nil then
    begin
    {$IFDEF BDS}
      FEditControlWrapper.DoAfterPaintLine(Editor, LineNum, LogicLineNum);
    {$ELSE}
      FEditControlWrapper.DoAfterPaintLine(Editor, LineNum, LineNum);
    {$ENDIF}
    end;
  finally
    LeaveCriticalSection(PaintLineLock);
  end;
end;

function MySetEditView(Self: TObject; EditView: TObject): Integer;
begin
  if Assigned(EditView) and IsIdeEditorForm(TCustomForm(TControl(Self).Owner)) then
  begin
    FEditControlWrapper.CheckNewEditor(TControl(Self), GetOTAEditView(EditView));
  end;

  FEditControlWrapper.FSetEditViewHook.UnhookMethod;
  try
    Result := SetEditView(Self, EditView);
  finally
    FEditControlWrapper.FSetEditViewHook.HookMethod;
  end;
end;

constructor TCnEditControlWrapper.Create(AOwner: TComponent);
begin
  inherited;
  FOptionChanged := True;

  FBeforePaintLineNotifiers := TList.Create;
  FAfterPaintLineNotifiers := TList.Create;
  FEditControlNotifiers := TList.Create;
  FEditorChangeNotifiers := TList.Create;
  FKeyDownNotifiers := TList.Create;
  FKeyUpNotifiers := TList.Create;

  FEditControlList := TList.Create;

  FEditorList := TObjectList.Create;
  InitEditControlHook;

  FHighlights := TStringList.Create;

  CnWizNotifierServices.AddSourceEditorNotifier(OnSourceEditorNotify);
  CnWizNotifierServices.AddActiveFormNotifier(OnActiveFormChange);
  CnWizNotifierServices.AddCallWndProcRetNotifier(OnCallWndProcRet);
  CnWizNotifierServices.AddApplicationMessageNotifier(ApplicationMessage);
  CnWizNotifierServices.AddApplicationIdleNotifier(OnIdle);

  UpdateEditControlList;
  GetHighlightFromReg;
end;

destructor TCnEditControlWrapper.Destroy;
begin
  CnWizNotifierServices.RemoveSourceEditorNotifier(OnSourceEditorNotify);
  CnWizNotifierServices.RemoveActiveFormNotifier(OnActiveFormChange);
  CnWizNotifierServices.RemoveCallWndProcRetNotifier(OnCallWndProcRet);
  CnWizNotifierServices.RemoveApplicationMessageNotifier(ApplicationMessage);
  CnWizNotifierServices.RemoveApplicationIdleNotifier(OnIdle);

  if CorIdeModule <> 0 then
    FreeLibrary(CorIdeModule);
  if FPaintLineHook <> nil then
    FPaintLineHook.Free;
  if FSetEditViewHook <> nil then
    FSetEditViewHook.Free;
{$IFDEF BDS}
  if FTabsChangedHook <> nil then
    FTabsChangedHook.Free;
  if FViewBarChangedHook <> nil then
    FViewBarChangedHook.Free;
{$ENDIF}
  FEditControlList.Free;
  FEditorList.Free;

  ClearHighlights;
  FHighlights.Free;

  ClearAndFreeList(FBeforePaintLineNotifiers);
  ClearAndFreeList(FAfterPaintLineNotifiers);
  ClearAndFreeList(FEditControlNotifiers);
  ClearAndFreeList(FEditorChangeNotifiers);
  ClearAndFreeList(FKeyDownNotifiers);
  ClearAndFreeList(FKeyUpNotifiers);
  inherited;
end;

procedure TCnEditControlWrapper.InitEditControlHook;
begin
  try
    CorIdeModule := LoadLibrary(CorIdeLibName);
    Assert(CorIdeModule <> 0, 'Failed to load CorIdeModule');

    GetOTAEditView := GetBplMethodAddress(GetProcAddress(CorIdeModule, SGetOTAEditViewName));
    Assert(Assigned(GetOTAEditView), 'Failed to load GetOTAEditView from CorIdeModule');

    DoGetAttributeAtPos := GetBplMethodAddress(GetProcAddress(CorIdeModule, SGetAttributeAtPosName));
    Assert(Assigned(DoGetAttributeAtPos), 'Failed to load GetAttributeAtPos from CorIdeModule');

    PaintLine := GetBplMethodAddress(GetProcAddress(CorIdeModule, SPaintLineName));
    Assert(Assigned(PaintLine), 'Failed to load PaintLine from CorIdeModule');

    DoMarkLinesDirty := GetBplMethodAddress(GetProcAddress(CorIdeModule, SMarkLinesDirtyName));
    Assert(Assigned(DoMarkLinesDirty), 'Failed to load MarkLinesDirty from CorIdeModule');

    EdRefresh := GetBplMethodAddress(GetProcAddress(CorIdeModule, SEdRefreshName));
    Assert(Assigned(EdRefresh), 'Failed to load EdRefresh from CorIdeModule');

    DoGetTextAtLine := GetBplMethodAddress(GetProcAddress(CorIdeModule, SGetTextAtLineName));
    Assert(Assigned(DoGetTextAtLine), 'Failed to load GetTextAtLine from CorIdeModule');

  {$IFDEF BDS}
    // BDS �²���Ч
    LineIsElided := GetBplMethodAddress(GetProcAddress(CorIdeModule, SLineIsElidedName));
    Assert(Assigned(LineIsElided), 'Failed to load LineIsElided from CorIdeModule');

    PointFromEdPos := GetBplMethodAddress(GetProcAddress(CorIdeModule, SPointFromEdPosName));
    Assert(Assigned(PointFromEdPos), 'Failed to load PointFromEdPos from CorIdeModule');

    TabsChanged := GetBplMethodAddress(GetProcAddress(CorIdeModule, STabsChangedName));
    Assert(Assigned(TabsChanged), 'Failed to load TabsChanged from CorIdeModule');

    FTabsChangedHook := TCnMethodHook.Create(@TabsChanged, @MyTabsChanged);

    ViewBarChanged := GetBplMethodAddress(GetProcAddress(CorIdeModule, SViewBarChangedName));
    Assert(Assigned(ViewBarChanged), 'Failed to load ViewBarChanged from CorIdeModule');

    FViewBarChangedHook := TCnMethodHook.Create(@ViewBarChanged, @MyViewBarChanged);
  {$ENDIF}

    SetEditView := GetBplMethodAddress(GetProcAddress(CorIdeModule, SSetEditViewName));
    Assert(Assigned(SetEditView), 'Failed to load SetEditView from CorIdeModule');

    FPaintLineHook := TCnMethodHook.Create(@PaintLine, @MyPaintLine);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('EditControl.PaintLine Hooked');
  {$ENDIF}

    FSetEditViewHook := TCnMethodHook.Create(@SetEditView, @MySetEditView);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('EditControl.SetEditView Hooked');
  {$ENDIF}

    FPaintNotifyAvailable := True;
  except
    FPaintNotifyAvailable := False;
  end;
end;

//------------------------------------------------------------------------------
// �༭���ؼ��б�����
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.CheckNewEditor(EditControl: TControl;
  View: IOTAEditView);
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
  begin
    Editors[Idx].SetEditView(View);
    DoEditorChange(Editors[Idx], [ctView]);
  end
  else
  begin
    AddEditor(EditControl, View);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper: New EditControl.');
  {$ENDIF}
  end;
end;

function TCnEditControlWrapper.AddEditor(EditControl: TControl;
  View: IOTAEditView): Integer;
begin
  Result := FEditorList.Add(TEditorObject.Create(EditControl, View));
end;

procedure TCnEditControlWrapper.DeleteEditor(EditControl: TControl);
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
  begin
    FEditorList.Delete(Idx);
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper: EditControl Removed.');
  {$ENDIF}
  end;
end;

function TCnEditControlWrapper.GetEditorContext(Editor: TEditorObject):
  TEditorContext;
begin
  FillChar(Result, SizeOf(TEditorContext), 0);
  if (Editor <> nil) and (Editor.EditView <> nil) and (Editor.EditControl <> nil) then
  begin
    Result.TopRow := Editor.EditView.TopRow;
    Result.BottomRow := Editor.EditView.BottomRow;
    Result.LeftColumn := Editor.EditView.LeftColumn;
    Result.CurPos := Editor.EditView.CursorPos;
    Result.ModTime := Editor.EditView.Buffer.GetCurrentDate;
    Result.LineCount := Editor.EditView.Buffer.GetLinesInBuffer;
    Result.BlockValid := Editor.EditView.Block.IsValid;
    Result.EditView := Pointer(Editor.EditView);
    Result.LineText := GetStrProp(Editor.EditControl, 'LineText');
{$IFDEF BDS}
    Result.LineDigit := GetLineDigit(Result.LineCount, 10);
{$ENDIF}
  end;
end;

function TCnEditControlWrapper.GetEditorCount: Integer;
begin
  Result := FEditorList.Count;
end;

function TCnEditControlWrapper.GetEditors(Index: Integer): TEditorObject;
begin
  Result := TEditorObject(FEditorList[Index]);
end;

function TCnEditControlWrapper.IndexOfEditor(
  EditControl: TControl): Integer;
var
  i: Integer;
begin
  for i := 0 to EditorCount - 1 do
  begin
    if Editors[i].EditControl = EditControl then
    begin
      Result := i;
      Exit;
    end;  
  end;
  Result := -1;
end;

procedure TCnEditControlWrapper.OnIdle(Sender: TObject);
var
  i: Integer;
  Context, OldContext: TEditorContext;
  ChangeType: TEditorChangeTypes;
begin
  for i := 0 to EditorCount - 1 do
  begin
    if not Editors[i].EditControl.Visible or (Editors[i].EditView = nil) then
      Continue;

    Context := GetEditorContext(Editors[i]);
    OldContext := Editors[i].Context;

    ChangeType := [];
    if (Context.TopRow <> OldContext.TopRow) or
      (Context.BottomRow <> OldContext.BottomRow) then
      Include(ChangeType, ctWindow);
    if (Context.LeftColumn <> OldContext.LeftColumn) then
      Include(ChangeType, ctHScroll);
    if Context.CurPos.Line <> OldContext.CurPos.Line then
      Include(ChangeType, ctCurrLine);
    if Context.CurPos.Col <> OldContext.CurPos.Col then
      Include(ChangeType, ctCurrCol);
    if Context.BlockValid <> OldContext.BlockValid then
      Include(ChangeType, ctBlock);
    if Context.EditView <> OldContext.EditView then
      Include(ChangeType, ctView);

{$IFDEF BDS}
    if Context.LineDigit <> OldContext.LineDigit then
      Include(ChangeType, ctLineDigit);
    if FTabsChangeTypes * [ctTabSetChanged] <> [] then
    begin
      Include(ChangeType, ctTabSetChanged);
      FTabsChangeTypes := [];
    end;
{$ENDIF}

    // ��ʱ�� EditBuffer �޸ĺ�ʱ��δ�仯
    if (Context.LineCount <> OldContext.LineCount) or
      (Context.ModTime <> OldContext.ModTime) then
    begin
      Include(ChangeType, ctModified);
    end
    else if Context.CurPos.Line = OldContext.CurPos.Line then
    begin
      if not AnsiSameStr(Context.LineText, OldContext.LineText) then
        Include(ChangeType, ctModified);
    end;

    if FOptionChanged then
    begin
      UpdateCharSize;
      Include(ChangeType, ctFont);
      FOptionChanged := False;
    end;

    if ChangeType <> [] then
    begin
      Editors[i].FContext := Context;
      DoEditorChange(Editors[i], ChangeType);
    end;
  end;
end;

//------------------------------------------------------------------------------
// ���弰��������
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.GetHighlightFromReg;
const
{$IFDEF COMPILER7_UP}
  csColorBkName = 'Background Color New';
  csColorFgName = 'Foreground Color New';
{$ELSE}
  csColorBkName = 'Background Color';
  csColorFgName = 'Foreground Color';
{$ENDIF}
var
  i: Integer;
  Reg: TRegistry;
  Names, Values: TStringList;
  Item: THighlightItem;

  function RegReadBool(Reg: TRegistry; const AName: string): Boolean;
  var
    Value: string;
  begin
    if Reg.ValueExists(AName) then
    begin
      Value := Reg.ReadString(AName);
      Result := not (SameText(Value, 'False') or (Value = '0'));
    end
    else
      Result := False;
  end;

  function RegReadColor(Reg: TRegistry; const AName: string): TColor;
  begin
    if Reg.ValueExists(AName) then
    begin
      if Reg.GetDataType(AName) = rdInteger then
        Result := SCnColor16Table[TrimInt(Reg.ReadInteger(AName), 0, 16)]
      else if Reg.GetDataType(AName) = rdString then
        Result := StringToColor(Reg.ReadString(AName))
      else
        Result := clNone;
    end
    else
      Result := clNone;
  end;
begin
  ClearHighlights;
  Reg := nil;
  Names := nil;
  Values := nil;
  try
    Names := TStringList.Create;
    Values := TStringList.Create;
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(WizOptions.CompilerRegPath + '\Editor\Highlight') then
    begin
      Reg.GetKeyNames(Names);
      for i := 0 to Names.Count - 1 do
      begin
        if Reg.OpenKeyReadOnly(WizOptions.CompilerRegPath +
          '\Editor\Highlight\' + Names[i]) then
        begin
          Item := nil;
          try
            Reg.GetValueNames(Values);
            if Values.Count > 0 then // �˼�������
            begin
              Item := THighlightItem.Create;
              Item.Bold := RegReadBool(Reg, 'Bold');
              Item.Italic := RegReadBool(Reg, 'Italic');
              Item.Underline := RegReadBool(Reg, 'Underline');
              if RegReadBool(Reg, 'Default Background') then
                Item.ColorBk := clWhite
              else
                Item.ColorBk := RegReadColor(Reg, csColorBkName);
              if RegReadBool(Reg, 'Default Foreground') then
                Item.ColorFg := clWindowText
              else
                Item.ColorFg := RegReadColor(Reg, csColorFgName);
              FHighlights.AddObject(Names[i], Item);
            end;
          except
            on E: Exception do
            begin
              if Item <> nil then Item.Free;
              DoHandleException(E.Message);
            end;
          end;
        end;
      end;
    end;
  finally
    Values.Free;
    Names.Free;
    Reg.Free;
  end;
end;

function TCnEditControlWrapper.UpdateCharSize: Boolean;
begin
  Result := False;
  if FOptionChanged and (GetCurrentEditControl <> nil) and
    (CnOtaGetEditOptions <> nil) then
    Result := CalcCharSize;
end;

function TCnEditControlWrapper.CalcCharSize: Boolean;
const
  csAlphaText = 'abcdefghijklmnopqrstuvwxyz';
var
  LogFont, AFont: TLogFont;
  DC: HDC;
  SaveFont: HFONT;
  Option: IOTAEditOptions;
  Control: TControlHack;
  FontName: string;
  FontHeight: Integer;
  Size: TSize;
  i: Integer;

  procedure CalcFont(const AName: string; ALogFont: TLogFont);
  var
    AHandle: THandle;
    TM: TEXTMETRIC;
  begin
    AHandle := CreateFontIndirect(ALogFont);
    AHandle := SelectObject(DC, AHandle);
    if SaveFont = 0 then
      SaveFont := AHandle
    else if AHandle <> 0 then
      DeleteObject(AHandle);

    GetTextMetrics(DC, TM);
    GetTextExtentPoint(DC, csAlphaText, Length(csAlphaText), Size);
    // ȡ�ı��߶�
    if TM.tmHeight + TM.tmExternalLeading > FCharSize.cy then
      FCharSize.cy := TM.tmHeight + TM.tmExternalLeading;
    if Size.cy > FCharSize.cy then
      FCharSize.cy := Size.cy;

    // ȡ�ı�����
    if TM.tmAveCharWidth > FCharSize.cx then
      FCharSize.cx := TM.tmAveCharWidth;
    if Size.cx div Length(csAlphaText) > FCharSize.cx then
      FCharSize.cx := Size.cx div Length(csAlphaText);

  {$IFDEF DEBUG}
    CnDebugger.LogFmt('[%s] TM.Height: %d TM.Width: %d Size.cx: %d / %d Size.cy: %d',
      [AName, TM.tmHeight + TM.tmExternalLeading, TM.tmAveCharWidth,
      Size.cx, Length(csAlphaText), Size.cy]);
  {$ENDIF}
  end;
begin
  Result := False;
  FCharSize.cx := 0;
  FCharSize.cy := 0;

  Control := TControlHack(GetCurrentEditControl);
  Option := CnOtaGetEditOptions;
  if not Assigned(Control) or not Assigned(Option) then
    Exit;

  GetHighlightFromReg;

  if GetObject(Control.Font.Handle, SizeOf(LogFont), @LogFont) <> 0 then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper.CalcCharSize');
    CnDebugger.LogFmt('FontName: %s Height: %d Width: %d',
      [LogFont.lfFaceName, LogFont.lfHeight, LogFont.lfWidth]);
  {$ENDIF}

    FontName := Option.FontName;
    FontHeight := -MulDiv(Option.FontSize, Screen.PixelsPerInch, 72);
    if not SameText(FontName, LogFont.lfFaceName) or (FontHeight <> LogFont.lfHeight) then
    begin
      // ����Ϊϵͳ���õ�����
      StrCopy(LogFont.lfFaceName, PChar(FontName));
      LogFont.lfHeight := FontHeight;
    {$IFDEF DEBUG}
      CnDebugger.LogFmt('Adjust FontName: %s Height: %d', [FontName, FontHeight]);
    {$ENDIF}
    end;

    DC := CreateCompatibleDC(0);
    try
      SaveFont := 0;
      if HighlightCount > 0 then
      begin
        for i := 0 to HighlightCount - 1 do
        begin
          AFont := LogFont;
          if Highlights[i].Bold then
            AFont.lfWeight := FW_BOLD;
          if Highlights[i].Italic then
            AFont.lfItalic := 1;
          if Highlights[i].Underline then
            AFont.lfUnderline := 1;
          CalcFont(HighlightNames[i], AFont);
        end;
      {$IFDEF DEBUG}
        CnDebugger.LogFmt('CharSize from registry: X = %d Y = %d',
          [FCharSize.cx, FCharSize.cy]);
      {$ENDIF}
      end
      else
      begin
      {$IFDEF DEBUG}
        CnDebugger.LogMsgWarning('Access registry fail.');
      {$ENDIF}
        AFont := LogFont;
        AFont.lfWeight := FW_BOLD;
        CalcFont('Bold', AFont);

        AFont := LogFont;
        AFont.lfItalic := 1;
        CalcFont('Italic', AFont);
      end;
      
      Result := True;
    finally
      SaveFont := SelectObject(DC, SaveFont);
      if SaveFont <> 0 then
        DeleteObject(SaveFont);
      DeleteDC(DC);
    end;
  end;
end;

function TCnEditControlWrapper.GetCharHeight: Integer;
begin
  Result := GetCharSize.cy;
end;

function TCnEditControlWrapper.GetCharSize: TSize;
begin
  UpdateCharSize;
  Result := FCharSize;
end;

function TCnEditControlWrapper.GetCharWidth: Integer;
begin
  Result := GetCharSize.cx;
end;

function TCnEditControlWrapper.GetEditControlInfo(EditControl: TControl):
  TEditControlInfo;
begin
  try
    Result.TopLine := GetOrdProp(EditControl, 'TopLine');
    Result.LinesInWindow := GetOrdProp(EditControl, 'LinesInWindow');
    Result.LineCount := GetOrdProp(EditControl, 'LineCount');
    Result.CaretX := GetOrdProp(EditControl, 'CaretX');
    Result.CaretY := GetOrdProp(EditControl, 'CaretY');
    Result.CharXIndex := GetOrdProp(EditControl, 'CharXIndex');
{$IFDEF BDS}
    Result.LineDigit := GetLineDigit(Result.LineCount, 10);
{$ENDIF}
  except
    on E: Exception do
      DoHandleException(E.Message);
  end;
end;

function TCnEditControlWrapper.GetEditControlCanvas(
  EditControl: TControl): TCanvas;
begin
  Result := nil;
  if EditControl = nil then Exit;
{$IFDEF BDS}
  {$IFDEF BDS2009_UP}
    // BDS 2009 �� TControl �Ѿ� Unicode ���ˣ�ֱ����
    Result := TCustomControlHack(EditControl).Canvas;
  {$ELSE}
    // BDS 2009 ���µ� EditControl ���ټ̳��� TCustomControl����˵���Ӳ�취����û���
    Result := TCanvas((PInteger(Integer(EditControl) + CnWideControlCanvasOffset))^);
  {$ENDIF}
{$ELSE}
  Result := TCustomControlHack(EditControl).Canvas;
{$ENDIF}
end;

function TCnEditControlWrapper.GetHighlight(Index: Integer): THighlightItem;
begin
  Result := THighlightItem(FHighlights.Objects[Index]);
end;

function TCnEditControlWrapper.GetHighlightCount: Integer;
begin
  Result := FHighlights.Count;
end;

function TCnEditControlWrapper.GetHighlightName(Index: Integer): string;
begin
  Result := FHighlights[Index];
end;

function TCnEditControlWrapper.IndexOfHighlight(
  const Name: string): Integer;
begin
  Result := FHighlights.IndexOf(Name);
end;

procedure TCnEditControlWrapper.ClearHighlights;
var
  i: Integer;
begin
  for i := 0 to FHighlights.Count - 1 do
    FHighlights.Objects[i].Free;
  FHighlights.Clear;
end;

//------------------------------------------------------------------------------
// �༭������
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if IsEditControl(AComponent) and (Operation = opRemove) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper.DoEditControlNotify: opRemove');
  {$ENDIF}
    FEditControlList.Remove(AComponent);
    DeleteEditor(TControl(AComponent));
    DoEditControlNotify(TControl(AComponent), opRemove);
  end;
end;

procedure TCnEditControlWrapper.EditControlProc(EditWindow: TCustomForm;
  EditControl: TControl; Context: Pointer);
begin
  if (EditControl <> nil) and (FEditControlList.IndexOf(EditControl) < 0) then
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('TCnEditControlWrapper.DoEditControlNotify: opInsert');
  {$ENDIF}
    FEditControlList.Add(EditControl);
    EditControl.FreeNotification(Self);
    DoEditControlNotify(EditControl, opInsert);
  end;
end;

procedure TCnEditControlWrapper.UpdateEditControlList;
begin
  EnumEditControl(EditControlProc, nil);
end;

procedure TCnEditControlWrapper.OnSourceEditorNotify(
  SourceEditor: IOTASourceEditor; NotifyType: TCnWizSourceEditorNotifyType;
  EditView: IOTAEditView);
{$IFDEF DELPHI11}
var
  I: Integer;
{$ENDIF}
begin
  if NotifyType = setEditViewActivated then
    UpdateEditControlList;
{$IFDEF DELPHI11}
  if NotifyType = setEditViewRemove then
  begin
    // RAD Studio 2007 Update1 �£�Close All ʱ EditControl �ƺ������ͷţ�
    // Ϊ�˷�ֹ EditView �ͷ��˶� EditControl û���ͷŵ�������˴����м��
    for I := 0 to EditorCount - 1 do
      if Editors[I].EditView = EditView then
      begin
        DeleteEditor(Editors[I].EditControl);
        Break;
      end;
  end;  
{$ENDIF}
end;

procedure TCnEditControlWrapper.CheckOptionDlg;

  function IsEditorOptionDlgVisible: Boolean;
  var
    i: Integer;
  begin
    for i := 0 to Screen.CustomFormCount - 1 do
      if Screen.CustomForms[i].ClassNameIs(SEditorOptionDlgClassName) and
        SameText(Screen.CustomForms[i].Name, SEditorOptionDlgName) and
        Screen.CustomForms[i].Visible then
      begin
        Result := True;
        Exit;
      end;
    Result := False;
  end;
begin
  if IsEditorOptionDlgVisible then
    FOptionDlgVisible := True
  else if FOptionDlgVisible then
  begin
    FOptionDlgVisible := False;
    FOptionChanged := True;
  {$IFDEF DEBUG}
    CnDebugger.LogMsg('Editor Option Changed');
  {$ENDIF}
  end;
end;

procedure TCnEditControlWrapper.OnActiveFormChange(Sender: TObject);
begin
  UpdateEditControlList;
  CheckOptionDlg;
end;

function TCnEditControlWrapper.GetEditView(EditControl: TControl): IOTAEditView;
var
  Idx: Integer;
begin
  Idx := IndexOfEditor(EditControl);
  if Idx >= 0 then
    Result := Editors[Idx].EditView
  else
  begin
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWarning('GetEditView: not found in list.');
  {$ENDIF}
    Result := CnOtaGetTopMostEditView;
  end;
end;

function TCnEditControlWrapper.GetTopMostEditControl: TControl;
var
  Idx: Integer;
  EditView: IOTAEditView;
begin
  Result := nil;
  EditView := CnOtaGetTopMostEditView;
  for Idx := 0 to EditorCount - 1 do
    if Editors[Idx].EditView = EditView then
    begin
      Result := Editors[Idx].EditControl;
      Exit;
    end;
  {$IFDEF DEBUG}
    CnDebugger.LogMsgWarning('GetTopMostEditControl: not found in list.');
  {$ENDIF}
end;

function TCnEditControlWrapper.GetEditViewFromTabs(TabControl: TXTabControl;
  Index: Integer): IOTAEditView;
begin
  if Assigned(GetOTAEditView) and (TabControl <> nil) and
    (TabControl.TabIndex >= 0) and (TabControl.Tabs.Objects[Index] <> nil) and
    TabControl.Tabs.Objects[Index].ClassNameIs(STEditViewClass) then
    Result := GetOTAEditView(TabControl.Tabs.Objects[Index])
  else
    Result := nil;
end;

procedure TCnEditControlWrapper.GetAttributeAtPos(EditControl: TControl; const
  EdPos: TOTAEditPos; IncludeMargin: Boolean; var Element, LineFlag: Integer);
begin
  if Assigned(DoGetAttributeAtPos) then
  begin
  {$IFDEF COMPILER7_UP}
    DoGetAttributeAtPos(EditControl, EdPos, Element, LineFlag, IncludeMargin, True);
  {$ELSE}
    DoGetAttributeAtPos(EditControl, EdPos, Element, LineFlag, IncludeMargin);
  {$ENDIF}
  end;
end;

function TCnEditControlWrapper.GetLineIsElided(EditControl: TControl;
  LineNum: Integer): Boolean;
begin
  Result := False;
  if Assigned(LineIsElided) then
    Result := LineIsElided(EditControl, LineNum);
end;

{$IFDEF BDS}

function TCnEditControlWrapper.GetPointFromEdPos(EditControl: TControl;
  APos: TOTAEditPos): TPoint;
begin
  if Assigned(PointFromEdPos) then
    Result := PointFromEdPos(EditControl, APos, True, True);
end;

procedure TCnEditControlWrapper.DoTabSetIdleChange(Sender: TObject); // �� IDLE ʱ������
var
  Idx: Integer;
  Editor: TEditorObject;
  EditControl: TControl;
begin
  if FTabsChangeTypes <> [] then
  begin
    EditControl := GetTopMostEditControl;
    Idx := IndexOfEditor(EditControl);
    if Idx >= 0 then
      Editor := Editors[Idx]
    else
      Editor := nil;

    DoEditorChange(Editor, FTabsChangeTypes);
    FTabsChangeTypes := [];
  end;
end;
{$ENDIF}

procedure TCnEditControlWrapper.MarkLinesDirty(EditControl: TControl; Line:
  Integer; Count: Integer);
begin
  if Assigned(DoMarkLinesDirty) then
    DoMarkLinesDirty(EditControl, Line, Count, $07);
end;

procedure TCnEditControlWrapper.EditorRefresh(EditControl: TControl;
  DirtyOnly: Boolean);
begin
  if Assigned(EdRefresh) then
    EdRefresh(EditControl, DirtyOnly);
end;

function TCnEditControlWrapper.GetTextAtLine(EditControl: TControl;
  LineNum: Integer): string;
begin
  if Assigned(DoGetTextAtLine) then
    Result := DoGetTextAtLine(EditControl, LineNum);
end;

procedure TCnEditControlWrapper.RepaintEditControls;
var
  I: Integer;
begin
  for I := 0 to FEditControlList.Count - 1 do
  begin
    if IsEditControl(TComponent(FEditControlList[I])) then
    begin
      try
        TControl(FEditControlList[I]).Invalidate;
      except
        ;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
// ֪ͨ���б�����
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddNotifier(List: TList; Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
begin
  if IndexOf(List, Notifier) < 0 then
  begin
    New(Rec);
    Rec^.Notifier := TMethod(Notifier);
    List.Add(Rec);
  end;
end;

procedure TCnEditControlWrapper.RemoveNotifier(List: TList; Notifier: TMethod);
var
  Rec: PCnWizNotifierRecord;
  idx: Integer;
begin
  idx := IndexOf(List, Notifier);
  if idx >= 0 then
  begin
    Rec := List[idx];
    Dispose(Rec);
    List.Delete(idx);
  end;
end;

procedure TCnEditControlWrapper.ClearAndFreeList(var List: TList);
var
  Rec: PCnWizNotifierRecord;
begin
  while List.Count > 0 do
  begin
    Rec := List[0];
    Dispose(Rec);
    List.Delete(0);
  end;
  FreeAndNil(List);
end;

function TCnEditControlWrapper.IndexOf(List: TList; Notifier: TMethod): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to List.Count - 1 do
    if CompareMem(List[i], @Notifier, SizeOf(TMethod)) then
    begin
      Result := i;
      Exit;
    end;
end;

//------------------------------------------------------------------------------
// �༭������ Hook ֪ͨ
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddAfterPaintLineNotifier(
  Notifier: TEditorPaintLineNotifier);
begin
  AddNotifier(FAfterPaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddBeforePaintLineNotifier(
  Notifier: TEditorPaintLineNotifier);
begin
  AddNotifier(FBeforePaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveAfterPaintLineNotifier(
  Notifier: TEditorPaintLineNotifier);
begin
  RemoveNotifier(FAfterPaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveBeforePaintLineNotifier(
  Notifier: TEditorPaintLineNotifier);
begin
  RemoveNotifier(FBeforePaintLineNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoAfterPaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
var
  I: Integer;
begin
  for I := 0 to FAfterPaintLineNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FAfterPaintLineNotifiers[I])^ do
      TEditorPaintLineNotifier(Notifier)(Editor, LineNum, LogicLineNum);
  except
    DoHandleException('TCnEditControlWrapper.DoAfterPaintLine[' + IntToStr(I) + ']');
  end;
end;

procedure TCnEditControlWrapper.DoBeforePaintLine(Editor: TEditorObject;
  LineNum, LogicLineNum: Integer);
var
  I: Integer;
begin
  for I := 0 to FBeforePaintLineNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FBeforePaintLineNotifiers[I])^ do
      TEditorPaintLineNotifier(Notifier)(Editor, LineNum, LogicLineNum);
  except
    DoHandleException('TCnEditControlWrapper.DoBeforePaintLine[' + IntToStr(I) + ']');
  end;
end;

procedure TCnEditControlWrapper.DoAfterElide(EditControl: TControl);
var
  I: Integer;
begin
  I := IndexOfEditor(EditControl);
  if I >= 0 then
    DoEditorChange(Editors[I], [ctElided]);
end;

procedure TCnEditControlWrapper.DoAfterUnElide(EditControl: TControl);
var
  I: Integer;
begin
  I := IndexOfEditor(EditControl);
  if I >= 0 then
    DoEditorChange(Editors[I], [ctUnElided]);
end;

//------------------------------------------------------------------------------
// �༭���ؼ�֪ͨ
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddEditControlNotifier(
  Notifier: TEditorNotifier);
begin
  AddNotifier(FEditControlNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditControlNotifier(
  Notifier: TEditorNotifier);
begin
  RemoveNotifier(FEditControlNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoEditControlNotify(EditControl: TControl;
  Operation: TOperation);
var
  I: Integer;
  EditWindow: TCustomForm;
begin
  EditWindow := TCustomForm(EditControl.Owner);
  for I := 0 to FEditControlNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FEditControlNotifiers[I])^ do
      TEditorNotifier(Notifier)(EditControl, EditWindow, Operation);
  except
    DoHandleException('TCnEditControlWrapper.DoEditControlNotify[' + IntToStr(I) + ']');
  end;
end;

//------------------------------------------------------------------------------
// �༭���ؼ����֪ͨ
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddEditorChangeNotifier(
  Notifier: TEditorChangeNotifier);
begin
  AddNotifier(FEditorChangeNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveEditorChangeNotifier(
  Notifier: TEditorChangeNotifier);
begin
  RemoveNotifier(FEditorChangeNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.DoEditorChange(Editor: TEditorObject;
  ChangeType: TEditorChangeTypes);
var
  I: Integer;
begin
{$IFDEF DEBUG}
  CnDebugger.LogMsg('TCnEditControlWrapper.DoEditorChange: ' + EditorChangeTypesToStr(ChangeType));
{$ENDIF}

  if ChangeType * [ctView, ctWindow{$IFDEF BDS}, ctLineDigit{$ENDIF}] <> [] then
  begin
    Editor.FGutterChanged := True;  // ��λ�������仯ʱ���ᴥ�� Gutter ���ȱ仯
  end;

  for I := 0 to FEditorChangeNotifiers.Count - 1 do
  try
    with PCnWizNotifierRecord(FEditorChangeNotifiers[I])^ do
      TEditorChangeNotifier(Notifier)(Editor, ChangeType);
  except
    DoHandleException('TCnEditControlWrapper.DoEditorChange[' + IntToStr(I) + ']');
  end;
end;

//------------------------------------------------------------------------------
// ��Ϣ֪ͨ
//------------------------------------------------------------------------------

procedure TCnEditControlWrapper.AddKeyDownNotifier(
  Notifier: TKeyMessageNotifier);
begin
  AddNotifier(FKeyDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.AddKeyUpNotifier(
  Notifier: TKeyMessageNotifier);
begin
  AddNotifier(FKeyUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveKeyDownNotifier(
  Notifier: TKeyMessageNotifier);
begin
  RemoveNotifier(FKeyDownNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.RemoveKeyUpNotifier(
  Notifier: TKeyMessageNotifier);
begin
  RemoveNotifier(FKeyUpNotifiers, TMethod(Notifier));
end;

procedure TCnEditControlWrapper.OnCallWndProcRet(Handle: HWND;
  Control: TWinControl; Msg: TMessage);
var
  I: Integer;
begin
  if ((Msg.Msg = WM_VSCROLL) or (Msg.Msg = WM_HSCROLL))
    and IsEditControl(Control) then
  begin
    if Msg.Msg = WM_VSCROLL then
      for I := 0 to EditorCount - 1 do
        DoEditorChange(Editors[I], [ctVScroll])
    else
      for I := 0 to EditorCount - 1 do
        DoEditorChange(Editors[I], [ctHScroll])
  end;
end;

procedure TCnEditControlWrapper.ApplicationMessage(var Msg: TMsg;
  var Handled: Boolean);
var
  I: Integer;
  Key: Word;
  ScanCode: Word;
  Shift: TShiftState;
  List: TList;
begin
  if ((Msg.message = WM_KEYDOWN) or (Msg.message = WM_KEYUP)) and
    IsEditControl(Screen.ActiveControl) then
  begin
    Key := Msg.wParam;
    ScanCode := (Msg.lParam and $00FF0000) shr 16;
    Shift := KeyDataToShiftState(Msg.lParam);

    // �������뷨�ͻصİ���
    if Key = VK_PROCESSKEY then
    begin
      Key := MapVirtualKey(ScanCode, 1);
    end;

    if Msg.message = WM_KEYDOWN then
      List := FKeyDownNotifiers
    else
      List := FKeyUpNotifiers;

    for I := 0 to List.Count - 1 do
    try
      with PCnWizNotifierRecord(List[I])^ do
        TKeyMessageNotifier(Notifier)(Key, ScanCode, Shift, Handled);
      if Handled then Break;
    except
      DoHandleException('TCnEditControlWrapper.KeyMessage[' + IntToStr(I) + ']');
    end;
  end;
end;

initialization
  InitializeCriticalSection(PaintLineLock);

finalization
{$IFDEF DEBUG}
  CnDebugger.LogEnter('CnEditControlWrapper finalization.');
{$ENDIF}

  if FEditControlWrapper <> nil then
    FreeAndNil(FEditControlWrapper);
  DeleteCriticalSection(PaintLineLock);

{$IFDEF DEBUG}
  CnDebugger.LogLeave('CnEditControlWrapper finalization.');
{$ENDIF}

end.