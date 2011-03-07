unit CTConsts;
{* |<PRE>
================================================================================
* 软件名称：CVSTracNT
* 单元名称：常量定义单元
* 单元作者：周劲羽 (zjy@cnpack.org)
* 备    注：公共常量定义单元
* 开发平台：PWindows Server 2003 + Delphi 7.0
* 本 地 化：该单元中的字符串符合本地化处理方式
* 单元标识：$Id: CTConsts.pas,v 1.7 2008/06/01 16:24:00 zjy Exp $
* 更新记录：2003.11.09
*               创建单元
================================================================================
|</PRE>}

interface

type
  TNotifyKind = (nkNone, nkPlugin, nkOther);

  TSCMKind = (skNone, skCvs, skSvn, skGit);

  PDBOptionInfo = ^TDBOptionInfo;
  TDBOptionInfo = record
    Database: string;
    SCM: TSCMKind;
    Home: string;
    Module: string;
    CvsUser: string;
    Charset: string;
    Passwd: Boolean;
    NotifyKind: TNotifyKind;
  end;

const
  csIniName = 'CVSTracSvc.ini';
  csCTSenderName = 'CTSender.exe';
  csCVSTracSvcName = 'CVSTracSvc.exe';
  csServiceName = 'CVSTracService';
  csServiceDesc = 'CVSTrac Service';
  csDBDirName = 'Database';
  csLangDirName = 'Lang';
  csPluginDirName = 'Plugin';
  csLogDirName = 'Log';
  csDefaultPort = 2040;
  csActiveSection = 'Active';
  csDefBackupCount = 7;

  csSCMs: array[TSCMKind] of string = ('', 'cvs', 'svn', 'git');
  csSCMNames: array[TSCMKind] of string = ('', 'CVS', 'Subversion', 'GIT');

resourcestring
  SDefSenderName = '[CVSTrac]';

var
  // FileName
  SExeName: string = 'cvstrac_chs.exe';
  SReadmeName: string = 'Readme_chs.txt';

  // CTOMainForm
  SAppTitle: string = 'CVSTrac 配置程序';
  SDeleteQuery: string = '您确认要删除这一项吗？';
  SAutoGenHisFileQuery: string =
    '配置程序发现有 %d 个 CVS 仓库下不存在 history 文件，' + #13#10 +
    '这可能是由于您使用了 2.5.x 或更高版本的 CVSNT 所致。' + #13#10#13#10 +
    'CVSTrac 的时间线功能依赖于 history 文件中的数据记录，' + #13#10 +
    '您是否需要自动为这些仓库创建 history 文件？' + #13#10#13#10 +
    '创建 history 后，您可能还需要用 cvs commit -f -R 命令' + #13#10 +
    '强制进行一次提交后才能在时间线中看到内容。';
  SGetDir: string = '请选择数据库文件目录';
  SImportOk: string = '自动导入完成！共初始化数据库 %d 个。' + #13#10#13#10 +
    '您可以点击“浏览”按钮来访问 CVSTrac 页面。' + #13#10 +
    '初始化用户名和密码都是 setup';
  SImportEmpty: string = '没有需要初始化的 CVS 仓库！';
  SInitRepository: string = '您是否需要自动导入 CVS 仓库并初始化数据库？';
  SUseStr: string = '使用';
  SRestartService: string = '您的设置只有在重新启动服务后才生效，是否立即重新启动？';
  SNotifyKinds: array[TNotifyKind] of string = ('无', '通知器', '其它');
  SBackupOk: string = '数据库备份完成！';
  SDBFormatError: string = '数据库格式错误';
  SDBIsSQLite3: string = '数据库 %s 已经是新的格式了！';
  SDBUpgradeSucc: string = '数据库 %s 升级成功！';
  SDBUpgradeFail: string = '数据库 %s 升级失败！';
  SDBUpgradeAllSucc: string = '成功升级数据库 %d 个！';
  SDBUpgradeQuery: string = 'CVSTracNT 2.x 使用新的数据库格式，' + #13#10 +
    '您需要升级所有数据库文件吗？';

  // CTOEditForm
  SEditIsEmpty: string = '数据库名称不能为空！';
  SGetCVSDir: string = '请选择 CVS 仓库目录';
  SNotCVSDir: string = '该目录可能不是 CVS 仓库目录，是否继续？';
  SExportSucc: string = '用户列表导出成功！';
  SExportFail: string = '用户列表导出失败！';
  SImportSucc: string = '用户列表导入成功！';
  SImportFail: string = '用户列表导入失败！';

implementation

end.


