unit CTPluginUtils;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：插件公共函数单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTPluginUtils.pas,v 1.2 2007/02/09 12:08:45 zjy Exp $
* 更新记录：2005.03.30
*               创建单元
================================================================================
|</PRE>}

interface

uses
  Windows, SysUtils, Classes, IniFiles, CnCommon, CTPluginIntf, CTPlugin;

const
  STicketMacros: array[0..31] of string = (
    'DBName', 'DBFileName', 'LocalServer', 'Port', 'TicketNo', 'TicketType',
    'TicketStatus', 'OrigTime', 'ChangeTime', 'DerivedFrom', 'Version',
    'AssignedTo', 'Severity', 'Priority', 'SubSystem', 'Owner', 'Title',
    'Contact', 'Description', 'Remarks', 'Extra1_Name', 'Extra2_Name',
    'Extra3_Name', 'Extra4_Name', 'Extra5_Name', 'Extra1', 'Extra2', 'Extra3',
    'Extra4', 'Extra5', 'Modificator', 'TicketUrl');
  SMacroChar = '%';
  
  SDefaultTitle = '[%DBName%] %Title%';

function ReplaceTicketMacros(TicketInfo: TTicketInfo; Plugin: TPlugin;
  const Text: string): string;
function GetTicketInfoText(TicketInfo: TTicketInfo; Plugin: TPlugin): string;
function GetTicketInfoShortText(TicketInfo: TTicketInfo; Plugin: TPlugin): string;

implementation

var
  SContentHeadFmtStr: string =
    '%s - 任务单更新通知' + #13#10 +
    '' + #13#10 +
    '任务单 %d: %s' + #13#10 +
    '' + #13#10 +
    '%s';
  SContentRemarksFmtStr: string =
    '' + #13#10 +
    '任务单备注:' + #13#10 +
    '' + #13#10 +
    '%s';
  SContentAttrFmtStr: string =
    '' + #13#10 +
    '任务单属性:' + #13#10 +
    '' + #13#10 +
    '    类型: %s' + #13#10 +
    '    状态: %s' + #13#10 +
    '  严重度: %s' + #13#10 +
    '  优先级: %s' + #13#10 +
    '  分配给: %s' + #13#10 +
    '  创建人: %s' + #13#10 +
    '  版本号: %s' + #13#10 +
    '创建时间: %s' + #13#10 +
    '更新时间: %s' + #13#10 +
    '  子系统: %s' + #13#10 +
    '  衍生自: %s' + #13#10 +
    '联系方式: %s' + #13#10 +
    '%s' + // extra fields
    '' + #13#10 +
    '该任务单由 %s 修改';
  SContentShortFmtStr: string =
    '%s - 任务单更新通知' + #13#10 +
    '' + #13#10 +
    '    标题: %s' + #13#10 +
    '    编号: %d' + #13#10 +
    '    类型: %s' + #13#10 +
    '    状态: %s' + #13#10 +
    '  严重度: %s' + #13#10 +
    '  优先级: %s' + #13#10 +
    '  分配给: %s' + #13#10 +
    '  创建人: %s' + #13#10 +
    '  版本号: %s' + #13#10 +
    '创建时间: %s' + #13#10 +
    '更新时间: %s' + #13#10 +
    '  子系统: %s' + #13#10 +
    '  衍生自: %s' + #13#10 +
    '联系方式: %s' + #13#10 +
    '%s' + // extra fields
    '' + #13#10 +
    '该任务单由 %s 修改';

const
  csTicketLangName = 'Ticket.ini';
  csTicketSection = 'Ticket';

  STicketUrlFmtStr =
    '' + #13#10 +
    '%s:%d/%s/tktview?tn=%d';

function ReplaceTicketMacros(TicketInfo: TTicketInfo; Plugin: TPlugin;
  const Text: string): string;
var
  i: Integer;
  
  procedure DoReplace(var AText: string; const Macro, Value: string);
  begin
    AText := StringReplace(AText, SMacroChar + Macro + SMacroChar, Value,
      [rfReplaceAll, rfIgnoreCase]);
  end;
begin
  Result := Text;
  with TicketInfo do
  begin
    DoReplace(Result, 'DBName', DBName);
    DoReplace(Result, 'DBFileName', DBFileName);
    DoReplace(Result, 'LocalServer', LocalServer);
    DoReplace(Result, 'Port', IntToStr(Port));
    DoReplace(Result, 'TicketNo', IntToStr(TicketNo));
    DoReplace(Result, 'TicketType', TicketType);
    DoReplace(Result, 'TicketStatus', TicketStatus);
    DoReplace(Result, 'OrigTime', OrigTime);
    DoReplace(Result, 'ChangeTime', ChangeTime);
    DoReplace(Result, 'DerivedFrom', DerivedFrom);
    DoReplace(Result, 'Version', Version);
    DoReplace(Result, 'AssignedTo', AssignedTo);
    DoReplace(Result, 'Severity', Severity);
    DoReplace(Result, 'Priority', Priority);
    DoReplace(Result, 'SubSystem', SubSystem);
    DoReplace(Result, 'Owner', Owner);
    DoReplace(Result, 'Title', Title);
    DoReplace(Result, 'Contact', Contact);
    for i := 1 to 5 do
    begin
      DoReplace(Result, Format('Extra%d_Name', [i]), Extra_Name[i]);
      DoReplace(Result, Format('Extra%d', [i]), Extra[i]);
    end;
    DoReplace(Result, 'Description', Description);
    DoReplace(Result, 'Remarks', Remarks);
    DoReplace(Result, 'Modificator', Modificator);
    DoReplace(Result, 'TicketUrl', Format(STicketUrlFmtStr, [LocalServer,
      Port, DBName, TicketNo]));
  end;
end;

function DoGetTicketInfoText(TicketInfo: TTicketInfo; Plugin: TPlugin;
  IsShort: Boolean): string;
var
  LangIDStr: string;
  Content: TStringList;
  ExtraStr: string;
  i: Integer;
begin
  try
    LangIDStr := IntToStr(Plugin.GetLangID);
    with TIniFile.Create(MakePath(Plugin.GetLangPath) + IntToStr(Plugin.GetLangID)
      + '\' + csTicketLangName) do
    try
      SContentHeadFmtStr := StrToLines(ReadString(csTicketSection,
        'SContentHeadFmtStr', SContentHeadFmtStr));
      SContentRemarksFmtStr := StrToLines(ReadString(csTicketSection,
        'SContentRemarksFmtStr', SContentRemarksFmtStr));
      SContentAttrFmtStr := StrToLines(ReadString(csTicketSection,
        'SContentAttrFmtStr', SContentAttrFmtStr));
      SContentShortFmtStr := StrToLines(ReadString(csTicketSection,
        'SContentShortFmtStr', SContentShortFmtStr));
    finally
      Free;
    end;

    Content := TStringList.Create;
    try
      with TicketInfo do
      begin
        for i := 1 to 5 do
          if (Extra_Name[i] <> nil) and (Length(Extra_Name[i]) > 0) then
          begin
            ExtraStr := ExtraStr + Format('%s: %s'#13#10, [Extra_Name[i],
              Extra[i]]);
          end;
          
        if IsShort then
        begin
          Content.Add(AdjustLineBreaks(Format(SContentShortFmtStr, [
            DBName, Title, TicketNo, TicketType,
            TicketStatus, Severity, Priority, AssignedTo, Owner, Version,
            OrigTime, ChangeTime, SubSystem, DerivedFrom, Contact, ExtraStr,
            Modificator])));
        end
        else
        begin
          // Unix 换行转 CRLF
          Content.Add(AdjustLineBreaks(Format(SContentHeadFmtStr,
            [DBName, TicketNo, Title, Description])));

          if Remarks <> '' then
            Content.Add(AdjustLineBreaks(Format(SContentRemarksFmtStr, [Remarks])));

          Content.Add(AdjustLineBreaks(Format(SContentAttrFmtStr, [TicketType,
            TicketStatus, Severity, Priority, AssignedTo, Owner, Version,
            OrigTime, ChangeTime, SubSystem, DerivedFrom, Contact, ExtraStr,
            Modificator])));
        end;

        if Trim(LocalServer) <> '' then
          Content.Add(Format(STicketUrlFmtStr, [Trim(LocalServer), Port, DBName,
            TicketNo]));
      end;

      Result := Content.Text;
    finally
      Content.Free;
    end;
  except
    on E: Exception do
      Result := E.Message;
  end;
end;

function GetTicketInfoText(TicketInfo: TTicketInfo; Plugin: TPlugin): string;
begin
  Result := DoGetTicketInfoText(TicketInfo, Plugin, False);
end;

function GetTicketInfoShortText(TicketInfo: TTicketInfo; Plugin: TPlugin): string;
begin
  Result := DoGetTicketInfoText(TicketInfo, Plugin, True);
end;

end.
