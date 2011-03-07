/*******************************************************************************
* 软件名称：CVSTracNT
* 单元名称：C 插件接口定义单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：使用 C/C++ 编写 CVSTracNT 插件时，需要包含该头文件，实现并导出
*           InitProc001 函数。见示例工程。
* 开发平台：PWindows XP SP2 + VC6
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTPluginIntf.h,v 1.2 2007/02/09 12:08:45 zjy Exp $
* 更新记录：2005.04.13
*               创建单元
*******************************************************************************/

#ifndef CTPLUGININTF_H
#define CTPLUGININTF_H

#ifdef __cplusplus
  #define DllExport    extern "C"
#else
  #define DllExport    extern
#endif

#define CTAPI          __stdcall

/*******************************************************************************
* 主程序接口
*******************************************************************************/

/* 版本号结构 */
typedef struct VERSION_struct {
  DWORD dwMajorVersion;
  DWORD dwMinorVersion;
  DWORD dwReleaseVersion;
  DWORD dwBuildNumber;
} TVersion, * PVersion;

/* 主程序提供的服务接口结构 */
typedef struct HOST_INTF_struct {
  DWORD dwSize;                           /* 结构大小 */
  TVersion Version;                       /* 主程序版本号 */
  char * (CTAPI * GetDBPath) ();          /* 取得数据库的路径 */
  char * (CTAPI * GetLangPath) ();        /* 取得多语文件路径 */
  int (CTAPI * GetLangID) ();             /* 取主程序当前的语言 ID */
  void (CTAPI * Log) (char * Text);       /* 输出插件运行日志 */
} HOST_INTF, THostIntf, * PHostIntf;

/*******************************************************************************
* 插件接口
*******************************************************************************/

/* 任务单信息结构 */
typedef struct TICKET_INFO_struct {
  DWORD dwSize;                  /* 结构大小 */
  char * DBName;                 /* 数据库名称 */
  char * DBFileName;             /* 数据全路径文件名 */
  char * LocalServer;            /* 本地服务器 URL */
  int Port;                      /* 本地服务端口号 */
  int TicketNo;                  /* 任务单编号 */
  char * TicketType;             /* 类型 */
  char * TicketStatus;           /* 状态 */
  char * OrigTime;               /* 创建时间 */
  char * ChangeTime;             /* 修改时间 */
  char * DerivedFrom;            /* 衍生自 */
  char * Version;                /* 相关版本号 */
  char * AssignedTo;             /* 指定修改人 */
  char * Severity;               /* 严重程度 */
  char * Priority;               /* 优先级 */
  char * SubSystem;              /* 子系统 */
  char * Owner;                  /* 创建者 */
  char * Title;                  /* 标题 */
  char * Description;            /* 描述 */
  char * Remarks;                /* 注释 */
  char * Contact;                /* 联系方式 */
  char * Modificator;            /* 任务单修改人 */
  // Added in v2.0.1 
  char * Extra_Name[5];          /* 扩展字段名称 */
  char * Extra[5];               /* 扩展字段值 */
} TICKET_INFO, TTicketInfo, * PTicketInfo;
  
/* 插件信息结构 */
typedef struct PLUGIN_INFO_struct {
  DWORD dwSize;                  /* 结构大小 */
  char * Name;                   /* 插件名称 */
  char * Comment;                /* 插件描述 */
  TVersion Version;              /* 插件版本号 */
  char * Author;                 /* 插件作者 */
  char * WebSite;                /* 作者网站 */
  char * Email;                  /* 作者信箱 */
} PLUGIN_INFO, TPluginInfo, * PPluginInfo;

/* 由插件实现的接口结构 */
typedef struct PLUGIN_INTF_struct {
  DWORD dwSize;                                       /* 结构大小 */
  PPluginInfo (CTAPI * GetPluginInfo) ();             /* 返回插件信息结构 */

  /* 执行发送任务单更新消息操作 */
  BOOL (CTAPI * Execute) (char * IniFileName,         /* 数据库文件相关的全路径 INI 文件名 */
                          PTicketInfo TicketInfo);    /* 任务单信息 */

  /* 在主界面中配置插件公共参数，如不需配置可置为 NULL */
  BOOL (CTAPI * ConfigPlugin) (HWND Owner);           /* 主程序句柄 */

  /* 在数据库配置界面中配置插件参数，如不需配置可置为 NULL */
  BOOL (CTAPI * ConfigDatabase) (HWND Owner,          /* 主程序句柄 */
                                 char * DBName,       /* 正在配置的数据库名 */
                                 char * DBFileName,   /* 数据库全路径文件名 */
                                 char * IniFileName); /* 数据库相关的全路径 INI 文件名 */

  /* 主程序界面语言切换事件 */
  void (CTAPI * LangChanged) (int LangID);            /* 新的语言 ID */
} PLUGIN_INTF, TPluginIntf, * PPluginIntf;

/* 插件导出的供主程序调用的函数 */
DllExport BOOL CTAPI InitProc001 (PHostIntf HostIntf,        /* 主程序传递下来的接口结构 */
                                  PPluginIntf * PluginIntf); /* 返回给主程序的插件结构指针 */

#endif /* CTPLUGININTF_H */