{*******************************************************}
{                                                       }
{       Pascal Script Source File                       }
{       Run by RemObjects Pascal Script in CnWizards    }
{                                                       }
{       Generated by CnPack IDE Wizards                 }
{                                                       }
{*******************************************************}

program InsertGuid;

{
  This function is similar to the Shortcut Ctrl+Shift+G
  Author: jAmEs_
}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Clipbrd, ComObj;

var
  Guid: TGUID;
begin
  OleCheck(CreateGuid(Guid));
  IdeInsertTextIntoEditor('['''+ GUIDToString(Guid) + ''']');
end.
