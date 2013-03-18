{*******************************************************}
{                                                       }
{       Pascal Script Source File                       }
{       Run by RemObjects Pascal Script in CnWizards    }
{                                                       }
{       Generated by CnPack IDE Wizards                 }
{                                                       }
{       Note: This script must run under Delphi 2009    } 
{             or Later to Support BuildConfiguration.   }
{                                                       }
{*******************************************************}

program BuildConfiguration;

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

var
  POCS: IOTAProjectOptionsConfigurations;
  BC: IOTABuildConfiguration;
  I: Integer;
begin
  BC := nil;
  if (_SUPPORT_OTA_PROJECT_CONFIGURATION = True) and (CompilerKind = ckDelphi) then
  begin
    POCS := CnOtaGetActiveProjectOptionsConfigurations(nil);
    if POCS <> nil then
    begin
      Writeln('Current Project''s Configuration Count: ' + IntToStr(POCS.GetConfigurationCount));
      for I := 0 to POCS.GetConfigurationCount - 1 do
      begin
        if POCS.GetConfiguration(I).GetName = POCS.GetActiveConfiguration.GetName then
        begin
          Writeln(Format('Configuration %d (Active): ', [I]) + POCS.GetConfiguration(I).GetName)
          BC := POCS.GetConfiguration(I);
        end
        else
          Writeln(Format('Configuration %d: ', [I]) + POCS.GetConfiguration(I).GetName);
      end;
    end;

    if BC <> nil then
    begin
      Writeln('');
      //Writeln(Format('Active Configuration Platform %s:', [BC.GetPlatform]));
      Writeln(Format('Active Configuration has %d properties:', [BC.GetPropertyCount]));
      for I := 0 to BC.GetPropertyCount - 1 do
      begin
        Writeln(BC.GetPropertyName(I));
      end;

      Writeln('');
      Writeln('VerInfo_MajorVer: ' + BC.GetValue('VerInfo_MajorVer'));
      Writeln('VerInfo_MinorVer: ' + BC.GetValue('VerInfo_MinorVer'));
      Writeln('VerInfo_Release: ' + BC.GetValue('VerInfo_Release'));
      Writeln('VerInfo_Build: ' + BC.GetValue('VerInfo_Build'));

      //BC.SetValue('VerInfo_Build', '2');

      Writeln('');
      Writeln(Format('Active Configuration has %d Children:', [BC.GetChildCount]));
    end;

    if POCS <> nil then
      if QueryDlg('Test: Do you want to Set Active Configuration to Index 1?', True) then
        POCS.SetActiveConfiguration(POCS.GetConfiguration(1));
  end
  else
    ErrorDlg('Only Support Delphi 2009 and Later.');
end.

