{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2010 CnPack ������                       }
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

unit CnAlignPropEditor;
{* |<PRE>
================================================================================
* �������ƣ����������ԡ�����༭����
* ��Ԫ���ƣ�Align���Ա༭����Ԫ
* ��Ԫ���ߣ�real-like@163.com
* ��    ע��
* ����ƽ̨��Windows2000Pro + Delphi 6.1
* ���ݲ��ԣ�PWin2000Pro + Delphi 6
* �� �� ����
* ��Ԫ��ʶ��$Id$
* �޸ļ�¼��
*           2004-11-16 V1.0 by Leeon
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, SysUtils, Classes,
  Graphics, TypInfo, Controls,
{$IFDEF COMPILER6_UP}
  DesignIntf, DesignEditors, VCLEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  CnDesignEditor, CnDesignEditorConsts, CnConsts;

type

{$IFDEF COMPILER6_UP}
  TCnAlignProperty = class(TEnumProperty,
    ICustomPropertyDrawing, ICustomPropertyListDrawing)
{$ELSE}
  TCnAlignProperty = class(TEnumProperty)
{$ENDIF}
  private
    procedure DrawAlignBitmap(const Value: string; ACanvas: TCanvas;
      var ARect: TRect; ASelected, AListDraw: Boolean);
  public
  {$IFDEF COMPILER6_UP}
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer);
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
      var AWidth: Integer);
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean);
    procedure PropDrawName(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);
  {$ELSE}
    procedure ListMeasureHeight(const Value: string; ACanvas: TCanvas;
      var AHeight: Integer); override;
    procedure ListMeasureWidth(const Value: string; ACanvas: TCanvas;
      var AWidth: Integer); override;
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean);
      override;
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean); override;
  {$ENDIF}
    class procedure GetInfo(var Name, Author, Email, Comment: string);
    class procedure Register;
  end;

implementation

{$R CnAlignPropEditor.res}

const
  AlignResNames: array[TAlign] of string = (
    'CN_ALIGN_NONE',
    'CN_ALIGN_TOP',
    'CN_ALIGN_BOTTOM',
    'CN_ALIGN_LEFT',
    'CN_ALIGN_RIGHT',
    'CN_ALIGN_CLIENT'
  {$IFDEF COMPILER6_UP}
    , 'CN_ALIGNPROP_CUSTOM'
  {$ENDIF}
  );

  AlignPropResNames: array[TAlign] of string = (
    'CN_ALIGNPROP_NONE',
    'CN_ALIGNPROP_TOP',
    'CN_ALIGNPROP_BOTTOM',
    'CN_ALIGNPROP_LEFT',
    'CN_ALIGNPROP_RIGHT',
    'CN_ALIGNPROP_CLIENT'
  {$IFDEF COMPILER6_UP}
    , 'CN_ALIGNPROP_CUSTOM'
  {$ENDIF}
  );

  csItemHeight = 24;
  csItemWidth = 24;
  csItemBorder = 2;

class procedure TCnAlignProperty.GetInfo(var Name, Author, Email,
  Comment: string);
begin
  Name := SCnAlignPropEditorName;
  Author := SCnPack_Leeon;
  Email := SCnPack_LeeonEmail;
  Comment := SCnAlignPropEditorComment;
end;

procedure TCnAlignProperty.ListMeasureHeight(const Value: string;
  ACanvas: TCanvas; var AHeight: Integer);
begin
  if AHeight < csItemHeight then
    AHeight := csItemHeight;
end;

procedure TCnAlignProperty.ListMeasureWidth(const Value: string;
  ACanvas: TCanvas; var AWidth: Integer);
begin
  AWidth := AWidth + csItemWidth;
end;

{$IFDEF COMPILER6_UP}
procedure TCnAlignProperty.PropDrawName(ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
begin
  DefaultPropertyDrawName(Self, ACanvas, ARect);
end;
{$ENDIF}

procedure TCnAlignProperty.DrawAlignBitmap(const Value: string;
  ACanvas: TCanvas; var ARect: TRect; ASelected, AListDraw: Boolean);
var
  Align: TAlign;
  Bmp: TBitmap;
  R: TRect;
begin
  if Value <> '' then
  begin
    Bmp := TBitmap.Create;
    try
      Align := TAlign(GetEnumValue(GetPropInfo^.PropType^, Value));
      if AListDraw then
        Bmp.Handle := LoadBitmap(HInstance, PChar(AlignResNames[Align]))
      else
        Bmp.Handle := LoadBitmap(HInstance, PChar(AlignPropResNames[Align]));
      Bmp.Transparent := True;
      Bmp.TransparentColor := clFuchsia;
      
      R := ARect;
      R.Right := ARect.Left + csItemBorder * 2 + Bmp.Width;
      ACanvas.FillRect(R);
      ACanvas.Draw(R.Left + csItemBorder, (R.Top + R.Bottom - Bmp.Height) div 2, Bmp);

      ARect.Left := ARect.Left + csItemBorder * 2 + Bmp.Width;
    finally
      Bmp.Free;
    end;
  end;
end;

procedure TCnAlignProperty.PropDrawValue(ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
var
  R: TRect;
begin
  R := ARect;
  DrawAlignBitmap(GetVisualValue, ACanvas, R, ASelected, False);
{$IFDEF COMPILER6_UP}
  DefaultPropertyDrawValue(Self, ACanvas, R);
{$ELSE}
  inherited PropDrawValue(ACanvas, R, ASelected);
{$ENDIF}
end;

procedure TCnAlignProperty.ListDrawValue(const Value: string;
  ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
var
  R: TRect;
begin
  R := ARect;
  DrawAlignBitmap(Value, ACanvas, R, ASelected, True);
{$IFDEF COMPILER6_UP}
  DefaultPropertyListDrawValue(Value, ACanvas, R, ASelected);
{$ELSE}
  inherited ListDrawValue(Value, ACanvas, R, ASelected);
{$ENDIF}
end;

class procedure TCnAlignProperty.Register;
begin
  RegisterPropertyEditor(TypeInfo(TAlign), TWinControl, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), TGraphicControl, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), TControl, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), TComponent, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), TPersistent, 'Align', TCnAlignProperty);
  RegisterPropertyEditor(TypeInfo(TAlign), nil, '', TCnAlignProperty);
end;

initialization
  CnDesignEditorMgr.RegisterPropEditor(TCnAlignProperty,
    TCnAlignProperty.GetInfo, TCnAlignProperty.Register);
  
end.