CVSTracNT 中文版源码说明 
========================

CnPack 开发组 周劲羽
http://www.cnpack.org

1. 目录结构
-----------
BuildAll.bat    自动创建批处理

Bin             存放二进制文件，内有 Readme
  co.exe            用于 check out 文件，cvstrac 中使用
  cvstrac_*.exe     cvstrac 主程序（多语），在 cygwin 下编译生成（见后）
  CVSTracOption.exe 设置工具，Delphi 7 下编译生成
  CVSTracSvc.exe    cvstrac 外壳服务程序，Delphi 7 下编译生成
  cygintl-1.dll     diff.exe 使用到的库
  cygwin1.dll       cvstrac.exe 等在 cygwin 下编译的程序使用的库
  diff.exe          用于比较源代码文件
  License_*.txt     授权文件（多语）
  rcsdiff.exe       用于比较 RCS 文件中不同版本的内容
  Readme_*.txt      发布说明文件（多语）
  rlog.exe          用于取出 RCS 文件版本信息
  sh.exe            cygwin 程序通过管道调用外部命令时使用的外壳程序
  sqlite.dll        设置程序调用它来访问数据库

  Database          存放数据库文件
  Lang              存放语言文件，一种语言一个目录
  Log               日志文件目录
  Plugin            任务单通知插件目录

Dcu             存放编译临时文件

Make            存放自动 Make 文件

Source          源代码目录
  cvstrac           cvstrac 移植版，NT 汉化版用 CVSTracNT_CHS 标签取出
  CVSTracOption     设置工具源码，Delphi 7 下编译
  CVSTracService    cvstrac 外壳服务源码，Delphi 7 下编译
  CTSender          任务单更新通知程序源码，调用通知插件，Delphi 7 下编译
  CTMailer          邮件通知插件源码，Delphi 7 下编译
  CTNetSend         信使服务通知插件源码，Delphi 7 下编译
  Public            源码公共目录
  MultiLang         多语言处理公共目录

Plugins         插件源码目录
  Include           公共包含文件
  VCDemo            使用 VC6 编写的简单插件示例


2. Delphi 源代码编译
--------------------
Delphi 源代码在 D7 下编译通过，编译时需要使用 CnPack 包中的 CnCommon.pas 以及多语言组件，建议从 CnPack 的 CVS 服务器中取出 cnpack 模块的代码与 cvstracnt 放在同一级目录下编译。


3. cvstrac 源代码编译
---------------------
编译步骤：

  * 安装 cygwin (http://www.cygwin.com)，安装时要选择 develop 下的 gcc、automake。
  * 下载 sqlite 源码 (http://www.sqlite.org)，在 cygwin 下编译。
  * 取出 CVSTracNT_CHS 分支的 cvstrac 源码放到 Source/cvstrac_chs 目录下
  * 取出 CVSTracNT_ENU 分支的 cvstrac 源码放到 Source/cvstrac_enu 目录下
  * 执行 BuildAll.bat 编译 cvstrac 源码及生成安装程序。

