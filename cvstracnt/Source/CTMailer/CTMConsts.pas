unit CTMConsts;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：邮件常量定义单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTMConsts.pas,v 1.2 2008/07/10 13:07:47 zjy Exp $
* 更新记录：2005.04.01
*               创建单元
================================================================================
|</PRE>}

interface

const
  csConnectTimeOut = 60;

var
  SMailerName: string = '邮件插件';
  SMailerComment: string = '任务单更新时发送邮件通知到指定的信箱';

  SBeginTest: string = '开始测试邮件连接...';
  SBeginConnect: string = '正在连接邮件服务器...';
  SBeginLogin: string = '正在执行登录验证...';
  STestSucc: string = '邮件连接测试通过！';
  SLoginFail: string = '登录验证失败！';
  STestFail: string = '邮件连接测试失败:';
  SCharSet: string = 'GB2312';
  
implementation

end.
