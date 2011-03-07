/*******************************************************************************
* 软件名称：CVSTracNT
* 单元名称：VC 插件例子工程主单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：
* 开发平台：PWindows XP SP2 + VC6
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: VCDemoMain.c,v 1.1 2005/04/29 02:10:01 zjy Exp $
* 更新记录：2005.04.13
*               创建单元
*******************************************************************************/

#include <WINDOWS.H>
#include "CTPluginIntf.h"

/* DLL 入口函数 */
BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					           )
{
  switch (ul_reason_for_call)
  {
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
  }
  return TRUE;
}

/* 插件信息 */
TPluginInfo PluginInfo = 
{
  sizeof(TPluginInfo),
  "VC 测试插件",
  "使用 VC 开发的测试插件",
  {1, 0, 0, 0},
  "周劲羽",
  "http://www.cnpack.org",
  "master@cnpack.org"  
};

/* 主程序接口 */
PHostIntf Host;

/* 插件接口 */
TPluginIntf Plugin;

/* 返回插件信息结构 */
PPluginInfo CTAPI GetPluginInfo () {
  return &PluginInfo;
}

/* 执行发送任务单更新消息操作 */
BOOL CTAPI Execute (char * IniFileName, PTicketInfo TicketInfo) {
  /* Todo: 发送消息 */
  return TRUE;
}

/* 在主界面中配置插件公共参数，如不需配置可置为 NULL */
BOOL CTAPI ConfigPlugin (HWND Owner) {
  MessageBox(Owner, "配置 VC 测试插件", "测试", MB_OK | MB_ICONINFORMATION);
  return TRUE;
}

/* 在数据库配置界面中配置插件参数，如不需配置可置为 NULL */
BOOL CTAPI ConfigDatabase (HWND Owner, char * DBName, char * DBFileName, 
                           char * IniFileName) {
  MessageBox(Owner, "配置数据库通知方式", "测试", MB_OK | MB_ICONINFORMATION);
  return TRUE;
}

/* 主程序界面语言切换事件 */
void CTAPI LangChanged (int LangID) {
  /* Todo: 切换界面语言 */
}
  
/* 插件导出的供主程序调用的函数，编写插件时需要在 def 文件中导出该函数 */
DllExport BOOL CTAPI InitProc001 (PHostIntf HostIntf, PPluginIntf * PluginIntf)
{
  Host = HostIntf;
  memset(&Plugin, 0, sizeof(TPluginInfo));
  Plugin.dwSize = sizeof(TPluginInfo);
  Plugin.GetPluginInfo = GetPluginInfo;
  Plugin.Execute = Execute;
  Plugin.ConfigPlugin = ConfigPlugin;
  Plugin.ConfigDatabase = ConfigDatabase;
  Plugin.LangChanged = LangChanged;
  *PluginIntf = &Plugin;
  return TRUE;
}
