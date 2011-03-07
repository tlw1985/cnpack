;******************************************************************************
;                                CVSTracNT 中文版
;                   中文版权 (C)Copyright 2003-2007 CnPack 开发组
;******************************************************************************

; 以下脚本用以生成 CVSTracNT 中文版 装程序 CVSTracNT.exe 文件
; 该脚本仅在 NSIS 2.0 下编译通过，不支持更低（或更高）的版本，使用时请注意

!include "MUI.nsh"

;------------------------------------------------------------------------------
; 软件版本号，根据实际版本号进行更新
;------------------------------------------------------------------------------

; 软件主版本号
!define VER_MAJOR "2"
; 软件子版本号
!define VER_MINOR "0.1_20080601"

;------------------------------------------------------------------------------
; 需要多语言处理的字符串
;------------------------------------------------------------------------------

; 快捷方式名
LangString SREADME 1033 "Readme"
LangString SREADME 2052 "自述文件"

LangString SLICENSE 1033 "License"
LangString SLICENSE 2052 "授权文件"

LangString SOPTION 1033 "CVSTrac Option"
LangString SOPTION 2052 "CVSTrac 配置"

LangString SUNINSTALL 1033 "Uninstall"
LangString SUNINSTALL 2052 "卸载"

; 文件名
LangString README_FILE 1033 "Readme_enu.txt"
LangString README_FILE 2052 "Readme_chs.txt"

LangString LICENSE_FILE 1033 "License_enu.txt"
LangString LICENSE_FILE 2052 "License_chs.txt"

; 对话框提示消息
LangString SQUERYDELETE 1033 "Delete user data files and settings?$\n(If you want to keep them, please click [No].)"
LangString SQUERYDELETE 2052 "是否删除用户数据文件和设置信息？$\n(若您要保留这些文件，请点击下面的 [否] 按钮)"

;------------------------------------------------------------------------------
; 软件主信息
;------------------------------------------------------------------------------

!define SOFT_NAME "CVSTracNT"

; 软件名称
!define FULL_NAME "${SOFT_NAME}"

; 安装程序下方分隔线标题
!define INSTALL_NAME "${SOFT_NAME}"

; 软件名称
Name "${FULL_NAME} ${VER_MAJOR}.${VER_MINOR}"
; 标题名称
Caption "${FULL_NAME}"
; 标牌的内容
BrandingText "${INSTALL_NAME}"

; 安装程序输出文件名
OutFile "..\Output\CVSTracNT_${VER_MAJOR}.${VER_MINOR}.exe"

;------------------------------------------------------------------------------
; 基本编译选项
;------------------------------------------------------------------------------

; 设置文件覆盖标记
SetOverwrite on
; 设置压缩选项
SetCompress auto
; 选择压缩方式
SetCompressor /solid lzma
; 设置数据块优化
SetDatablockOptimize on
; 设置在数据中写入文件时间
SetDateSave on


;------------------------------------------------------------------------------
; 包含文件及 Modern UI 设置
;------------------------------------------------------------------------------

!verbose 3

; 定义要显示的页面

!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install-blue.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall-blue.ico"

!define MUI_ABORTWARNING

!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "cnpack.bmp"

LicenseLangString SLICENSEFILE 1033 "..\..\Bin\License_enu.txt"
LicenseLangString SLICENSEFILE 2052 "..\..\Bin\License_chs.txt"

; 安装程序页面
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE $(SLICENSEFILE)
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

; 卸载程序页面
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; 安装完成后执行设置程序
!define MUI_FINISHPAGE_RUN "$INSTDIR\CVSTracOption.exe"
; 安装完成后显示自述文件
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\$(README_FILE)"
; 安装不需要重启
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

!insertmacro MUI_PAGE_FINISH

;多语支持
!define MUI_LANGDLL_REGISTRY_ROOT "HKCU"
!define MUI_LANGDLL_REGISTRY_KEY "Software\CnPack"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"
;!insertmacro MUI_LANGUAGE "TradChinese"

!verbose 4


;------------------------------------------------------------------------------
; 安装程序设置
;------------------------------------------------------------------------------

; 启用 WindowsXP 的视觉样式
XPstyle on

; 安装程序显示标题
WindowIcon on
; 设定渐变背景
BGGradient off
; 执行 CRC 检查
CRCCheck on
; 完成后自动关闭安装程序
AutoCloseWindow true
; 显示安装时“显示详细细节”对话框
ShowInstDetails show
; 显示卸载时“显示详细细节”对话框
ShowUninstDetails show
; 是否允许安装在根目录下
AllowRootDirInstall false

; 默认的安装目录
InstallDir "$PROGRAMFILES\CVSTracNT"
; 如果可能的话从注册表中检测安装路径
InstallDirRegKey HKLM \
                "Software\Microsoft\Windows\CurrentVersion\Uninstall\CVSTracNT" \
                "UninstallString"

;------------------------------------------------------------------------------
; 安装组件设置
;------------------------------------------------------------------------------

; 选择要安装的组件
InstType "Typical"


;------------------------------------------------------------------------------
; 安装程序内容
;------------------------------------------------------------------------------

Section "System Data"
  SectionIn 1
  ; 设置输出路径，每次使用都会改变
  SetOutPath $INSTDIR
  File "..\..\Bin\sqlite.dll"
  File "..\..\Bin\sqlite3.dll"
  File "..\..\Bin\CVSTracOption.exe"
  ExecWait "$INSTDIR\CVSTracOption.exe /u"
  File "..\..\Bin\cvstrac_chs.exe"
  File "..\..\Bin\cvstrac_enu.exe"
  File "..\..\Bin\CVSTracSvc.exe"
  File "..\..\Bin\CTSender.exe"
  File "..\..\Bin\Readme_chs.txt"
  File "..\..\Bin\Readme_enu.txt"
  File "..\..\Bin\License_chs.txt"
  File "..\..\Bin\License_enu.txt"
  File "..\..\Bin\cygwin1.dll"
  File "..\..\Bin\cygintl-1.dll"
  File "..\..\Bin\diff.exe"
  File "..\..\Bin\rcsdiff.exe"
  File "..\..\Bin\rlog.exe"
  File "..\..\Bin\co.exe"
  File "..\..\Bin\sh.exe"
  
  CreateDirectory "$INSTDIR\Database"
  CreateDirectory "$INSTDIR\Log"

  SetOutPath "$INSTDIR\Plugin"
	File "..\..\Bin\Plugin\*.dll"

  SetOutPath "$INSTDIR\Lang\2052"
	File "..\..\Bin\Lang\2052\*.*"

  SetOutPath "$INSTDIR\Lang\1033"
	File "..\..\Bin\Lang\1033\*.*"

  ; 为 Windows 卸载程序写入键值
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CVSTracNT" "DisplayName" "${FULL_NAME}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CVSTracNT" "UninstallString" '"$INSTDIR\uninst.exe"'

  ; 创建开始菜单项
  CreateDirectory "$SMPROGRAMS\${FULL_NAME}"
  CreateShortCut "$SMPROGRAMS\${FULL_NAME}\$(SREADME).lnk" "$INSTDIR\$(README_FILE)"
  CreateShortCut "$SMPROGRAMS\${FULL_NAME}\$(SLICENSE).lnk" "$INSTDIR\$(LICENSE_FILE)"
  CreateShortCut "$SMPROGRAMS\${FULL_NAME}\$(SOPTION).lnk" "$INSTDIR\CVSTracOption.exe"
  CreateShortCut "$SMPROGRAMS\${FULL_NAME}\$(SUNINSTALL) ${FULL_NAME}.lnk" "$INSTDIR\uninst.exe"

  ; 写入生成卸载程序
  WriteUninstaller "$INSTDIR\uninst.exe"

  ExecWait "$INSTDIR\CVSTracOption.exe /i"
SectionEnd


;------------------------------------------------------------------------------
; 安装时的回调函数
;------------------------------------------------------------------------------

; 安装程序初始化设置
Function .onInit

  ; 显示选择语言对话框
  !insertmacro MUI_LANGDLL_DISPLAY

FunctionEnd


;------------------------------------------------------------------------------
; 卸载程序及其相关回调函数
;------------------------------------------------------------------------------

; 卸载程序内容
Section "Uninstall"
  ExecWait "$INSTDIR\CVSTracOption.exe /u"

  Delete "$INSTDIR\*.exe"
  Delete "$INSTDIR\*.dll"
  Delete "$INSTDIR\*.txt"
	Delete "$INSTDIR\Lang\*.*"
	Delete "$INSTDIR\Plugin\*.dll"
	RMDir /r "$INSTDIR\Lang"
  RMDir /r "$SMPROGRAMS\${FULL_NAME}"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CVSTracNT"
  ; 提示用户是否删除数据文件
  MessageBox MB_YESNO|MB_ICONQUESTION "$(SQUERYDELETE)" IDNO NoDelete

  RMDir /r "$INSTDIR\Database"
  RMDir /r "$INSTDIR"
NODelete:
SectionEnd


; 结束