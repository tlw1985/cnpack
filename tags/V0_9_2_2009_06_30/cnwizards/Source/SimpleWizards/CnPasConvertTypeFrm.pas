{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2009 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnPasConvertTypeFrm;
{* |<PRE>
================================================================================
* 软件名称：CnPack IDE 专家包
* 单元名称：代码到HTML转换输出专家类型选择单元
* 单元作者：小冬 kendling@sina.com
* 备    注：
* 开发平台：PWinXP SP2 + Delphi 7
* 兼容测试：暂无（PWin9X/2000/XP + Delphi 5/6/7 + C++Builder 5/6）
* 本 地 化：该窗体中的字符串均符合本地化处理方式
* 单元标识：$Id: CnPasConvertTypeFrm.pas,v 1.9 2009/01/02 08:36:29 liuxiao Exp $
* 修改记录：2008.08.20 v1.1
*               加入编码的输入
*           2006.09.06 v1.0
*               创建单元，实现功能
================================================================================
|</PRE>}

interface

{$I CnWizards.inc}

uses
  Windows, Messages, SysUtils, Classes, CnPasConvert, Clipbrd, ToolsAPI,
  CnConsts, CnWizClasses, CnWizConsts, CnWizUtils, CnCommon, CnWizIdeUtils,
  Forms, Dialogs, Controls, StdCtrls, ComCtrls, CnIni, IniFiles,
  FileCtrl, Graphics, CnWizEditFiler, CnWizMultiLang, ExtCtrls;

type

{ TCnPasConvertType }

  TCnPasConvertType  = (ctHTML, ctRTF);

{ TCnPasConvertTypeForm }

  TCnPasConvertTypeForm = class(TCnTranslateForm)
    btnOK: TButton;
    rgConvertType: TRadioGroup;
    btnCancel: TButton;
    chkOpenAfterConvert: TCheckBox;
    lblEncode: TLabel;
    cbbEncoding: TComboBox;
    procedure rgConvertTypeClick(Sender: TObject);
  private
    function GetConvertType: TCnPasConvertType;
    procedure SetConvertType(const Value: TCnPasConvertType);
    function GetHTMLEncode: string;
    procedure SetHTMLEncode(const Value: string);
    { Private declarations }
  public
    function Open: Boolean;
    property ConvertType: TCnPasConvertType read GetConvertType write SetConvertType;
    property HTMLEncode: string read GetHTMLEncode write SetHTMLEncode;
  end;

const
  SConvertTypeFileExt: array[TCnPasConvertType] of string = (
    'htm',
    'rtf'
  );

  SConvertTypeFileFilter: array[TCnPasConvertType] of string = (
    'HTML Files (*.htm;*.html)|*.htm; *.html',
    'RTF Files (*.rtf)|*.rtf'
  );

implementation

{$R *.dfm}

function TCnPasConvertTypeForm.GetConvertType: TCnPasConvertType;
begin
  Result := TCnPasConvertType(rgConvertType.ItemIndex);
end;

function TCnPasConvertTypeForm.GetHTMLEncode: string;
begin
  Result := cbbEncoding.Text;
end;

function TCnPasConvertTypeForm.Open: Boolean;
begin
  Result := ShowModal = mrOK;
end;

procedure TCnPasConvertTypeForm.SetConvertType(
  const Value: TCnPasConvertType);
begin
  rgConvertType.ItemIndex := Ord(Value);
end;

procedure TCnPasConvertTypeForm.SetHTMLEncode(const Value: string);
begin
  cbbEncoding.Text := Value;
end;

procedure TCnPasConvertTypeForm.rgConvertTypeClick(Sender: TObject);
begin
  lblEncode.Enabled := rgConvertType.ItemIndex = 0;
  cbbEncoding.Enabled := rgConvertType.ItemIndex = 0;
end;

end.


