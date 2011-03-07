/*
** Copyright (c) 2002 D. Richard Hipp
**
** This program is free software; you can redistribute it and/or
** modify it under the terms of the GNU General Public
** License as published by the Free Software Foundation; either
** version 2 of the License, or (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
** General Public License for more details.
**
** You should have received a copy of the GNU General Public
** License along with this library; if not, write to the
** Free Software Foundation, Inc., 59 Temple Place - Suite 330,
** Boston, MA  02111-1307, USA.
**
** Author contact information:
**   drh@hwaci.com
**   http://www.hwaci.com/drh/
**
** 简体中文翻译: 周劲羽 (zjy@cnpack.org) 2003-11-09
**
*******************************************************************************
**
** Implementation of the Setup page
*/
#include <assert.h>
#include "config.h"
#include "setup.h"


/*
** Output a single entry for a menu generated using an HTML table.
** If zLink is not NULL or an empty string, then it is the page that
** the menu entry will hyperlink to.  If zLink is NULL or "", then
** the menu entry has no hyperlink - it is disabled.
*/
static void menu_entry(
  const char *zTitle,
  const char *zLink,
  const char *zDesc
){
  @ <dt>
  if( zLink && zLink[0] ){
    @ <a href="%s(zLink)">%h(zTitle)</a>
  }else{
    @ %h(zTitle)
  }
  @ </dt>
  @ <dd>%h(zDesc)</dd>
}

/*
** WEBPAGE: /setup
*/
void setup_page(void){
  /* The user must be at least the administrator in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okAdmin ){
    login_needed();
    return;
  }

  common_standard_menu("setup", 0);
  common_add_help_item("CvstracAdmin");
  common_header("设置菜单");

  @ <dl id="setup">
  if( g.okSetup ){
    menu_entry(mprintf("%s 仓库",g.scm.zName), "setup_repository",
      "指定该服务器连接到的仓库路径。");
    if( g.scm.pxUserWrite || g.scm.pxUserRead ){
      menu_entry("用户数据库", "setup_user", 
        mprintf("控制 CVSTrac 如何处理 %h 用户"
                "及密码数据库。", g.scm.zName));
    }
    menu_entry("日志文件", "setup_log",
      "控制访问日志文件开启或关闭。");
    menu_entry("附件", "setup_attach",
      "设置允许的附件文件最大长度。");
    menu_entry("带宽限制", "setup_throttle",
      "控制网络带宽及防止 wiki 垃圾。");
  }
  menu_entry("任务单类型", "setup_enum?e=type",
    "列出能被插入到系统中的任务单"
    "类型。");
  menu_entry("任务单状态", "setup_enum?e=status",
    "设置任务单 \"状态\" 属性允许的值。");
  menu_entry("新任务单默认值", "setup_newtkt",
    "指定当创建一个新的任务单时，自动设定的"
    "属性默认值。");
  menu_entry("子系统名称", "setup_enum?e=subsys",
    "列出在任务单中 \"子系统\" 属性"
    "所能使用的名称。");
  menu_entry("自定义字段", "setup_udef",
    "创建任务单表中可由用户自定义的数据库栏目。");
  if( g.okSetup ){
    menu_entry("比较和过滤程序", "setup_diff",
      "指定一个外部命令或脚本用来比较同一文件两个版本"
      "之间的差异以及美化输出文件。");
    menu_entry("外部工具", "setup_tools",
      "管理处理 CVSTrac 对象的外部工具。" );
    menu_entry("更新通知", "setup_chng",
      "定义一个外部程序在任务单创建或修改时"
      "自动运行以获得通知。");
    menu_entry("定制样式", "setup_style",
      "设置页眉、页脚、样式表和其它页面元素。");
    menu_entry("用户界面", "setup_interface",
      "控制用户界面功能。" );
    menu_entry("Wiki 标记", "setup_markup",
      "管理可定制的 Wiki 标记。" );
    menu_entry("备份和恢复", "setup_backup",
      "创建数据库备份文件或从备份文件中"
      "恢复数据库。");
    menu_entry("时间线和 RSS", "setup_timeline", 
      "设置时间线 Cookie 生命期和 RSS \"Time To Live\"。");
  }
  @ </dl>
  common_footer();
}

/*
** WEBPAGE: /setup_repository
*/
void setup_repository_page(void){
  const char *zRoot, *zOldRoot;
  const char *zModule, *zOldModule;

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  /*
  ** The "r" query parameter is the name of the CVS repository root
  ** directory.  Change it if it has changed.
  */
  zOldRoot = db_config("cvsroot","");
  zRoot = P("r");
  if( zRoot && strcmp(zOldRoot,zRoot)!=0 ){
    db_execute("REPLACE INTO config(name,value) VALUES('cvsroot','%q');",
      zRoot);
    zOldRoot = zRoot;
    db_config(0,0);
  }

  /*
  ** The "m" query parameter is the name of the module within the
  ** CVS repository that this CVSTrac instance is suppose to track.
  ** Change it if it has changed.
  */
  zOldModule = db_config("module","");
  zModule = P("m");
  if( zModule && strcmp(zOldModule,zModule)!=0 ){
    db_execute("REPLACE INTO config(name,value) VALUES('module','%q');",
      zModule);
    zOldModule = zModule;
    db_config(0,0);
  }

  /*
  ** The "rrh" query parameter is present if the user presses the
  ** "Reread Revision History" button.  This causes the CVSROOT/history
  ** file to be reread.  Do this with caution as it erases any edits
  ** to the history that are currently in the database.  Only the
  ** setup user can do this.
  */
  if( P("rrh") ){
    common_add_action_item("setup_repository", "取消");
    common_header("确认重新读取仓库数据文件");
    @ <h3>警告！</h3>
    @ <p>
    @ 如果您决定以 <b>重新构造</b> 方式更新历史数据库，
    @ 所有提交记录都将被重新编号。这可能会打断任务单和
    @ wiki 页面与提交记录之间的关系。您自己对提交注
    @ 释的修改同样会丢失。</p>
    @
    @ <p> 一个更安全办法是选择 <b>重新扫描</b>，这样
    @ 将尝试保留已存在的提交编号和提交注释修改。
    @ </p>
    @
    @ <p>无论怎样，您可以先创建一个数据库 <a href="setup_backup">
    @ 备份</a> 这样如果您发现有任何错误时，可以恢复
    @ 到原来的状态。</p>
    @
    @ <form action="%s(g.zPath)" method="POST">
    @ <p>
    @ <input type="submit" name="rrh2" value="重新构造">
    @ 重新开始建造提交记录数据库。
    @ </p>
    @ <p>
    @ <input type="submit" name="rrh3" value="重新扫描">
    @ 尝试使用现有的提交记录编号。
    @ </p>
    @ <p>
    @ <input type="submit" name="cancel" value="取消">
    @ 取消此次操作。
    @ </p>
    @ </form>
    common_footer();
    return;
  }
  if( P("rrh2") ){
    db_execute(
      "BEGIN;"
      "DELETE FROM chng WHERE not milestone;"
      "DELETE FROM filechng;"
      "DELETE FROM file;"
      "UPDATE config SET value=0 WHERE name='historysize';"
    );

    if( g.scm.pxHistoryReconstructPrep ) g.scm.pxHistoryReconstructPrep();

    db_execute("COMMIT; VACUUM;");

    db_config(0,0);
    history_update(0);
  }
  if( P("rrh3") ){
    db_execute(
      "BEGIN;"
      "DELETE FROM filechng WHERE rowid NOT IN ("
         "SELECT min(rowid) FROM filechng "
         "GROUP BY filename, vers||'x'"
      ");"
      "DELETE FROM chng WHERE milestone=0 AND cn NOT IN ("
         "SELECT cn FROM filechng"
      ");"
      "UPDATE config SET value=0 WHERE name='historysize';"
    );

    if( g.scm.pxHistoryRescanPrep ) g.scm.pxHistoryRescanPrep();

    db_execute(
      "COMMIT;"
      "VACUUM;"
    );
    db_config(0,0);
    history_update(1);
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminRepository");
  common_header("配置仓库");
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>在下面的编辑框中输入
  @ %s(g.scm.zName) 仓库根目录的完整路径。
  if( g.scm.canFilterModules ){
    @ 如果您想要限制
    @ 该服务只能看
    @ 到此 %s(g.scm.zName) 仓库中一个子集的文件
    @ （例如，如果您希望只能看到一个模块，
    @ 而仓库还包含其它几个不相关的模块），
    @ 请在第二个输入框中输入您想看到的文件集的
    @ 路径前缀。模块前缀可以使用正则表达式以用于
    @ 匹配多个模块。请注意，一个正则表达式必须从
    @ 行首开始标记(必须以 ^ 开头)才会被认为是有
    @ 效的。
  }
  @ </p>
  @ <table>
  @ <tr>
  @   <td align="right">%s(g.scm.zName) 仓库:</td>
  @   <td><input type="text" name="r" size="40" value="%h(zOldRoot)"></td>
  @ </tr>

  if( g.scm.canFilterModules ){
    @ <tr>
    @   <td align="right">模块前缀:</td>
    @   <td><input type="text" name="m" size="40" value="%h(zOldModule)"></td>
    @ </tr>
  }

  @ </table><br>
  @ <input type="submit" value="提交">
  @
  @ <p>
  @ 在前面修改了 %s(g.scm.zName) 仓库路径后，通常您可能还想要
  @ 点击下面的按钮来从新的仓库中重新
  @ 读取数据文件。您也可以使用这个按钮
  @ 来重新同步由于原来读取数据失败或
  @ 您手工修改了数据文件引起的问题(这并不是一个好主意)。
  @ <p><input type="submit" name="rrh" value="重新读取仓库"></p>
  @ </form>
  @ <hr>
  common_footer();
}

/*
** WEBPAGE: /setup_user
*/
void setup_user_page(void){
  const char *zWPswd, *zOldWPswd;

  /* The user must be at least the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  /*
  ** The "wpw" query parameter is "yes" if the CVSROOT/passwd file is
  ** writable and "no" if not.
  ** Change it if it has changed.
  */
  zOldWPswd = db_config("write_cvs_passwd","yes");
  zWPswd = P("wpw");
  if( zWPswd && strcmp(zOldWPswd,zWPswd)!=0 ){
    db_execute(
      "REPLACE INTO config(name,value) VALUES('write_cvs_passwd','%q');",
      zWPswd
    );
    zOldWPswd = zWPswd;
    db_config(0,0);
  }

  /*
  ** Import users out of the CVSROOT/passwd file if the user pressed
  ** the Import Users button.  Only setup can do this.
  */
  if( P("import_users") && g.scm.pxUserRead ){
    g.scm.pxUserRead();
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminUserDatabase");
  common_header("设置用户数据库联接");
  if( g.scm.pxUserWrite ){
    @ <form action="%s(g.zPath)" method="POST">
    @ <p>CVSTrac 能根据 CVSTrac 的所有用户名和密码
    @ 自动更新 CVSROOT/passwd 文件。在下面可以
    @ 允许或禁止这一功能。</p>
    @ <p>将用户变更写入 CVSROOT/passwd？
    cgi_optionmenu(0, "wpw", zOldWPswd, "是", "yes", "否", "no", NULL);
    @ <input type="submit" value="提交">
    @ </p>
    @ </form>
  }
  if( g.scm.pxUserRead ){
    @ <form action="%s(g.zPath)" method="POST">
    @ <p>使用下面的按钮自动根据当前 CVSROOT/passwd 文件为
    @ 每一个已有的用户创建 CVSTrac 帐号。新的用户将获得
    @ 与 anonymous 匿名帐号相同的权限，如果 CVS 允许用户
    @ 读写，还将获得取出和提交的权限。</p>
    @ <p><input type="submit" name="import_users" value="导入 CVS 用户"></p>
    @ </form>
  }
  common_footer();
}

/*
** WEBPAGE: /setup_log
*/
void setup_logfile_page(void){
  const char *zLog, *zOldLog;

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  /*
  ** The "log" query parameter specifies a log file into which a record
  ** of all HTTP hits is written.  Write this value if this has changed.
  ** Only setup can make this change.
  */
  zOldLog = db_config("logfile","");
  zLog = P("log");
  if( zLog && strcmp(zOldLog,zLog)!=0 ){
    db_execute(
      "REPLACE INTO config(name,value) VALUES('logfile','%q');",
      zLog
    );
    zOldLog = zLog;
    db_config(0,0);
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminLog");
  common_header("设置日志文件");
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>输入一个文件名，用来保存所有对该服务
  @ 器的访问日志。留空将禁用日志功能:
  @ </p>
  @ <p>日志文件: <input type="text" name="log" size="40" value="%h(zOldLog)">
  @ <input type="submit" value="提交"></p>
  @ </form>
  common_footer();
}

/*
** WEBPAGE: /setup_newtkt
*/
void setup_newticket_page(void){
  char **azResult;
  const char *zState, *zOldState;
  const char *zAsgnto, *zOldAsgnto;
  const char *zType, *zOldType;
  const char *zPri, *zOldPri;
  const char *zSev, *zOldSev;

  /* The user must be at least the administrator in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okAdmin ){
    login_needed();
    return;
  }

  /*
  ** The "asgnto" query parameter specifies a userid who is assigned to
  ** all new tickets.  Record this value in the configuration table if
  ** it has changed.
  */
  zOldAsgnto = db_config("assignto","");
  zAsgnto = P("asgnto");
  if( zAsgnto && strcmp(zOldAsgnto,zAsgnto)!=0 ){
    db_execute(
      "REPLACE INTO config(name,value) VALUES('assignto','%q');", zAsgnto
    );
    zOldAsgnto = zAsgnto;
    db_config(0,0);
  }

  /*
  ** The "istate" query parameter specifies the initial state for new
  ** tickets.  Record any changes to this value.
  */
  zOldState = db_config("initial_state","");
  zState = P("istate");
  if( zState && strcmp(zOldState,zState)!=0 ){
    db_execute(
      "REPLACE INTO config(name,value) VALUES('initial_state','%q');",
      zState
    );
    zOldState = zState;
    db_config(0,0);
  }

  /*
  ** The "type" query parameter specifies the initial type for new
  ** tickets.  Record any changes to this value.
  */
  zOldType = db_config("dflt_tkt_type","");
  zType = P("type");
  if( zType && strcmp(zOldType,zType)!=0 ){
    db_execute(
      "REPLACE INTO config(name,value) VALUES('dflt_tkt_type','%q');",
      zType
    );
    zOldType = zType;
    db_config(0,0);
  }

  /*
  ** The "pri" query parameter specifies the initial priority for new
  ** tickets.  Record any changes to this value.
  */
  zOldPri = db_config("dflt_priority","1");
  zPri = P("pri");
  if( zPri && strcmp(zOldPri,zPri)!=0 ){
    db_execute(
      "REPLACE INTO config(name,value) VALUES('dflt_priority','%q');",
      zPri
    );
    zOldPri = zPri;
    db_config(0,0);
  }

  /*
  ** The "sev" query parameter specifies the initial severity for new
  ** tickets.  Record any changes to this value.
  */
  zOldSev = db_config("dflt_severity","1");
  zSev = P("sev");
  if( zSev && strcmp(zOldSev,zSev)!=0 ){
    db_execute(
      "REPLACE INTO config(name,value) VALUES('dflt_severity','%q');",
      zSev
    );
    zOldSev = zSev;
    db_config(0,0);
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminNewTicket");
  common_header("设置新任务单默认值");
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>
  @ 选择当创建新任务单时默认分配到的用户名:</p><p>
  @ 默认分配:
  azResult = db_query("SELECT id FROM user UNION SELECT '' ORDER BY id");
  cgi_v_optionmenu(0, "asgnto", zOldAsgnto, (const char**)azResult);
  @ </p>
  @
  @ <p>
  @ 选择当创建新任务单时的初始状态:</p><p>
  @ 初始状态:
  cgi_v_optionmenu2(0, "istate", zOldState, (const char**)db_query(
     "SELECT name, value FROM enums WHERE type='status'"));
  @ </p>
  @
  @ <p>
  @ 选择新任务单的默认类型:</p><p>
  @ 默认类型:
  cgi_v_optionmenu2(0, "type", zOldType, (const char**)db_query(
     "SELECT name, value FROM enums WHERE type='type'"));
  @ </p>
  @
  @ <p>
  @ 选择新任务单的默认优先级:</p><p>
  @ 默认优先级:
  cgi_optionmenu(0, "pri", zOldPri, "1", "1", "2", "2", "3", "3", "4", "4",
      "5", "5", NULL);
  @ </p>
  @
  @ <p>
  @ 选择新任务单的默认严重度:</p><p>
  @ 默认严重度:
  cgi_optionmenu(0, "sev", zOldSev, "1", "1", "2", "2", "3", "3", "4", "4",
      "5", "5", NULL);
  @ </p>
  @
  @ <p>
  @ <input type="submit" value="提交">
  @ </p>
  @ </form>
  common_footer();
}

/*
** WEBPAGE: /setup_interface
*/
void setup_interface_page(void){
  int atkt, ack, tkt, ck, cols, rows, st;
  const char *zBrowseUrl;
  const char *zWrap;
  int nCookieLife;

  /* The user must be at least the administrator in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okAdmin ){
    login_needed();
    return;
  }

  if( P("update") ){
    cols = atoi(PD("cols",db_config("wiki_textarea_cols",WIKI_TEXTAREA_COLS)));
    if (cols < 20) cols = 20;

    rows = atoi(PD("rows",db_config("wiki_textarea_rows",WIKI_TEXTAREA_ROWS)));
    if (rows < 5) rows = 5;

    db_execute(
      "REPLACE INTO config(name,value) VALUES('anon_ticket_linkinfo',%d);"
      "REPLACE INTO config(name,value) VALUES('anon_checkin_linkinfo',%d);"
      "REPLACE INTO config(name,value) VALUES('ticket_linkinfo',%d);"
      "REPLACE INTO config(name,value) VALUES('checkin_linkinfo',%d);"
      "REPLACE INTO config(name,value) VALUES('browse_url_cookie_life',%d);"
      "REPLACE INTO config(name,value) VALUES('default_browse_url','%q');"
      "REPLACE INTO config(name,value) VALUES('wiki_textarea_wrap','%q');"
      "REPLACE INTO config(name,value) VALUES('wiki_textarea_cols',%d);"
      "REPLACE INTO config(name,value) VALUES('wiki_textarea_rows',%d);"
      "REPLACE INTO config(name,value) VALUES('safe_ticket_editting',%d);",
      atoi(PD("atkt",db_config("anon_ticket_linkinfo","0"))),
      atoi(PD("ack",db_config("anon_checkin_linkinfo","0"))),
      atoi(PD("tkt",db_config("ticket_linkinfo","1"))),
      atoi(PD("ck",db_config("checkin_linkinfo","0"))),
      atoi(PD("cl",db_config("browse_url_cookie_life", "90"))),
      PD("bu",db_config("default_browse_url","dir")),
      PD("wrap",db_config("wiki_textarea_wrap",WIKI_TEXTAREA_WRAP)),
      cols,
      rows,
      atoi(PD("st",db_config("safe_ticket_editting", "0")))
    );
    db_config(0, 0);
  }

  atkt = atoi(db_config("anon_ticket_linkinfo","0"));
  ack = atoi(db_config("anon_checkin_linkinfo","0"));
  tkt = atoi(db_config("ticket_linkinfo","1"));
  ck = atoi(db_config("checkin_linkinfo","0"));
  st = atoi(db_config("safe_ticket_editting","0"));
  cols = atoi(db_config("wiki_textarea_cols",WIKI_TEXTAREA_COLS));
  rows = atoi(db_config("wiki_textarea_rows",WIKI_TEXTAREA_ROWS));
  zWrap = db_config("wiki_textarea_wrap",WIKI_TEXTAREA_WRAP);
  zBrowseUrl = db_config("default_browse_url","dir");
  nCookieLife = atoi(db_config("browse_url_cookie_life", "90"));

  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminInterface");
  common_header("设置用户界面");

  @ <form action="%s(g.zPath)" method="POST">
  @ <h1>任务单和提交/里程碑链接信息</h1>
  @ <p>任务单和提交/里程碑链接信息允许在大多数浏览器中实现
  @ 工具提示。例如，
  @ <a href="tktview?tn=1" title="第一个任务单">#1</a> 和
  @ <a href="chngview?cn=1" title="提交 [1]: 第一次提交
  @ (由 anonymous)">[1]</a>。这个功能将提供给用户更多
  @ 的信息而不需要点击这个链接，这将加重一
  @ 点服务器的负担并导致页面大小增加。
  @ 提交链接信息功能通常当你的用户在 Wiki
  @ 或注释中加入了大量的提交链接时很
  @ 有用。
  @ </p>
  @ <p>
  @ <label for="atkt"><input type="checkbox" name="atkt" id="atkt"
  @   %s(atkt?" checked":"") value="1">
  @ 为匿名用户开启任务单链接信息功能。</label>
  @ <br>
  @ <label for="ack"><input type="checkbox" name="ack" id="ack"
  @   %s(ack?" checked":"") value="1">
  @ 为匿名用户开启提交/里程碑链接信息功能。</label>
  @ <br>
  @ <label for="tkt"><input type="checkbox" name="tkt" id="tkt"
  @   %s(tkt?" checked":"") value="1">
  @ 为登录用户开启任务单链接信息功能。</label>
  @ <br>
  @ <label for="ck"><input type="checkbox" name="ck" id="ck"
  @   %s(ck?" checked":"") value="1">
  @ 为登录用户开启提交/里程碑链接信息功能。</label>
  @ </p>
  @ <p>
  cgi_submit("update", 0, 0, 0, 0, "提交");
  @ </p>
  @ </form>

  @ <form class="setup-section" action="%s(g.zPath)" method="POST">
  @ <h1>仓库</h1>
  @ <p>在浏览仓库时有两种显示文件和目录的方法。
  @ <em>简短</em> 视图采用压缩列表的方式将所有文件
  @ 和目录显示在四列中。<em>详细</em> 视图
  @ 为每一个文件都显示其在仓库中最近的信息。</p>
  @ <p><label for="bu0"><input type="radio" name="bu" id="bu0"
  @    %s(strcmp("dirview",zBrowseUrl)==0?" checked":"") value="dirview">
  @ 详细视图</label><br>
  @ <label for="bu1"><input type="radio" name="bu" id="bu1"
  @   %s(strcmp("dir",zBrowseUrl)==0?" checked":"") value="dir">
  @ 简短视图</label>
  @ <p>
  cgi_submit("update", 0, 0, 0, 0, "提交");
  @ </p>
  @ </form>

  @ <form class="setup-section" action="%s(g.zPath)" method="POST">
  @ <h1>Cookies</h1>
  @ <p>
  @ 输入在用户浏览器中 Cookie 需要保存的天数。
  @ 该 Cookie 用来保存用户的浏览方式并作为以后访问的首选
  @ 浏览方式。<br>
  @ 该功能对所有用户有效。<br>
  @ 设置为 0 将禁用浏览器 Cookie。
  @ </p>
  @ <p>
  @ Cookie 生命期:
  @ <input type="text" name="cl" value="%d(nCookieLife)" size=5> 天
  @ </p>
  @ <p>
  cgi_submit("update", 0, 0, 0, 0, "提交");
  @ </p>
  @ </form>

  @ <form class="setup-section" action="%s(g.zPath)" method="POST">
  @ <h1>Wiki 文本输入</h1>
  @ <p>通过设置以下的参数来定制 Wiki 文本输入/编辑对话框。
  @ 输入区域换行方式指定输入文本提交给程序的方式。
  @ 如果换行方式设置为 <em>硬换行</em>
  @ 则当输入框内的单行文本自动换行时将自动插入硬回车符。
  @ <em>软换行</em> 换行方式则不会自动插入硬回车符。
  @ 如果输入的文本需要保持原始格式，则该选项应设置为
  @ <em>软换行</em> 方式。</p>
  @ <p>输入区域的屏幕大小也可以配置。请注意，
  @ 配置的行数只是一个 <i>最大值</i>。某些文本编辑框
  @ 可能更小一些。</p>
  @ <p>Wiki 文本输入换行:
  cgi_optionmenu(0, "wrap", zWrap,
                 "physical", "硬换行", "virtual", "软换行", NULL);
  @ </p>
  @ <p>输入区域大小:
  @ <input name="cols" size="3" value="%d(cols)"/> 列 
  @ <input name="rows" size="3" value="%d(rows)"/> 行
  @ </p>
  @ <p>
  cgi_submit("update", 0, 0, 0, 0, "提交");
  @ </p>
  @ </form>

  @ <form class="setup-section" action="%s(g.zPath)" method="POST">
  @ <h1>安全的任务单编辑</h1>
  @ <p>启用该选项将允许 CVSTrac 在准备编辑
  @ 任务单前进行检查，如果发现与另一个正在更新任务单的操作冲突，
  @ 将产生一个错误。
  @ </p>
  @ <p>
  @ <label for="st">
  @ <input type="checkbox" name="st" id="st" %s(st?" checked":"") value="1"/>
  @ 开启安全任务单编辑模式。</label>
  @ <br>
  cgi_submit("update", 0, 0, 0, 0, "设置");
  @ </p>
  @ </form>

  common_footer();
}

/*
** Generate a string suitable for inserting into a <TEXTAREA> that
** describes all allowed values for a particular enumeration.
*/
static char *enum_to_string(const char *zEnum){
  char **az;
  char *zResult;
  int i, j, nByte;
  int len1, len2, len3;
  int mx1, mx2, mx3;
  int rowCnt;
  az = db_query("SELECT name, value, color FROM enums "
                "WHERE type='%s' ORDER BY idx", zEnum);
  rowCnt = mx1 = mx2 = mx3 = 0;
  for(i=0; az[i]; i+=3){
    len1 = strlen(az[i]);
    len2 = strlen(az[i+1]);
    len3 = strlen(az[i+2]);
    if( len1>mx1 ) mx1 = len1;
    if( len2>mx2 ) mx2 = len2;
    if( len3>mx3 ) mx3 = len3;
    rowCnt++;
  }
  if( mx2<mx1 ) mx2 = mx1;
  nByte = (mx1 + mx2 + mx3 + 11)*rowCnt + 1;
  zResult = malloc( nByte );
  if( zResult==0 ) exit(1);
  for(i=j=0; az[i]; i+=3){
    const char *z1 = az[i];
    const char *z2 = az[i+1];
    const char *z3 = az[i+2];
    if( z1[0]==0 ){ z1 = "?"; }
    if( z2[0]==0 ){ z2 = z1; }
    if( z3[0] ){
      bprintf(&zResult[j], nByte-j, "%*s    %*s   (%s)\n",
              -mx1, z1, -mx2, z2, z3);
    }else{
      bprintf(&zResult[j], nByte-j, "%*s    %s\n", -mx1, z1, z2);
    }
    j += strlen(&zResult[j]);
  }
  db_query_free(az);
  zResult[j] = 0;
  return zResult;
}

/*
** Given text that describes an enumeration, fill the ENUMS table with
** coresponding entries.
**
** The text line oriented.  Each line represents a single value for
** the enum.  The first token on the line is the internal name.
** subsequent tokens are the human-readable description.  If the last
** token is in parentheses, then it is a color for the entry.
*/
static void string_to_enum(const char *zEnum, const char *z){
  int i, j, n;
  int cnt = 1;
  char *zColor;
  char zName[50];
  char zDesc[200];

  db_execute("DELETE FROM enums WHERE type='%s'", zEnum);
  while( isspace(*z) ){ z++; }
  while( *z ){
    assert( !isspace(*z) );
    for(i=1; z[i] && !isspace(z[i]); i++){}
    n = i>49 ? 49 : i;
    memcpy(zName, z, n);
    zName[n] = 0;
    z += i;
    while( *z!='\n' && isspace(z[1]) ){ z++; }
    if( *z=='\n' || *z==0 ){
      strcpy(zDesc, zName);
      zColor = "";
    }else{
      int lastP1 = -1;
      int lastP2 = -1;
      z++;
      for(j=i=0; *z && *z!='\n'; z++){
        if( j<199 && (j==0 || !isspace(*z) || !isspace(zDesc[j-1])) ){
          zDesc[j++] = *z;
        }
        if( *z=='(' ){ lastP1 = j-1; }
        else if( *z==')' ){ lastP2 = j-1; }
        else if( !isspace(*z) ){ lastP2 = -1; }
      }
      zDesc[j] = 0;
      if( lastP2>lastP1 && lastP1>1 ){
        zColor = &zDesc[lastP1+1];
        zDesc[lastP2] = 0;
        zDesc[lastP1] = 0;
        j = lastP1;
        while( j>0 && isspace(zDesc[j-1]) ){ j--; }
        zDesc[j] = 0;
      }else{
        j = strlen(zDesc);
        while( j>0 && isspace(zDesc[j-1]) ){ j--; }
        zDesc[j] = 0;
        zColor = "";
      }
    }
    db_execute(
       "INSERT INTO enums(type,idx,name,value,color) "
       "VALUES('%s',%d,'%q','%q','%q')",
       zEnum, cnt++, zName, zDesc, zColor
    );
    while( isspace(*z) ) z++;
  }

  /* If the enums were updated such that one of the defaults was removed,
  ** choose a new default.
  */
  if( !strcmp(zEnum,"status") ){
    const char* zDefault = db_config("initial_state","new");
    char* z = db_short_query("SELECT name FROM enums "
                             "WHERE type='status' AND name='%q'", zDefault);
    if( z==0 || z[0]==0 ) {
      /* gone missing, update */
      db_execute(
        "REPLACE INTO config(name,value) "
        "VALUES('initial_state',(SELECT name FROM enums WHERE type='status'));"
      );
    }
  }else if( !strcmp(zEnum,"type") ){
    const char* zDefault = db_config("dflt_tkt_type","code");
    char* z = db_short_query("SELECT name FROM enums "
                             "WHERE type='type' AND name='%q'", zDefault);
    if( z==0 || z[0]==0 ) {
      /* gone missing, update */
      db_execute(
        "REPLACE INTO config(name,value) "
        "VALUES('dflt_tkt_type',(SELECT name FROM enums WHERE type='type'));"
      );
    }
  }
}

/*
** WEBPAGE: /setup_enum
*/
void setup_enum_page(void){
  char *zText;
  const char *zEnum;
  int nRow;
  const char *zTitle;
  const char *zName;

  /* The user must be at least the administrator in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okAdmin ){
    login_needed();
    return;
  }

  /* What type of enumeration are we entering.
  */
  zEnum = P("e");
  if( zEnum==0 ){ zEnum = "subsys"; }
  if( strcmp(zEnum,"subsys")==0 ){
    zTitle = "设置子系统名称";
    zName = "子系统";
    nRow = 20;
    common_add_help_item("CvstracAdminSubsystem");
  }else
  if( strcmp(zEnum,"type")==0 ){
    zTitle = "设置任务单类型";
    zName = "类型";
    nRow = 6;
    common_add_help_item("CvstracAdminTicketType");
  }else
  if( strcmp(zEnum,"status")==0 ){
    zTitle = "设置任务单状态";
    zName = "状态";
    nRow = 10;
    common_add_help_item("CvstracAdminTicketState");
  }else
  {
    common_add_nav_item("setup", "主设置菜单");
    common_header("未知的枚举类型");
    @ <p>URL 错误:  "e" 查询参数指定了一个
    @ 未知的枚举类型: "%h(zEnum)".</p>
    @
    @ <p>点击 "后退" 链接返回到设置菜单。</p>
    common_footer();
    return;
  }

  /*
  ** The "s" query parameter is a long text string that specifies
  ** the names of all subsystems.  If any subsystem names have been
  ** added or removed, then make appropriate changes to the subsyst
  ** table in the database.
  */
  if( P("x") ){
    db_execute("BEGIN");
    string_to_enum(zEnum, P("x"));
    db_execute("COMMIT");
  }

  /* Genenerate the page.
  */
  common_add_nav_item("setup", "主设置菜单");
  common_header(zTitle);
  zText = enum_to_string(zEnum);
  @ <p>
  @ 下面列出的是任务单的 "%s(zName)" 属性
  @ 所允许的值。
  @ 您可以编辑下面的文本并点击应用来修改所
  @ 允许的值。
  @ </p>
  @
  @ <p>
  @ 左边的标记是保存到数据库中的值。
  @ 随后的标记是用来显示的可读的描述文本。
  @ 描述文本后面是一个可选的用圆括号包
  @ 含的颜色名，用在报表显示中。
  @ </p>
  @
  @ <form action="%s(g.zPath)" method="POST">
  @ <p><input type="hidden" name="e" value="%s(zEnum)">
  @ <textarea cols=60 rows=%d(nRow) name="x">%h(zText)</textarea></p>
  @ <p><input type="submit" value="提交"></p>
  @ </form>
  common_footer();
}

/*
** WEBPAGE: /setup_udef
*/
void setup_udef_page(void){
  int idx, i;
  const char *zName;
  const char *zText;

  /* The user must be at least the administrator in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okAdmin ){
    login_needed();
    return;
  }

  /* Write back results if requested.
  */
  idx = atoi(PD("idx","0"));
  zName = P("n");
  zText = P("x");
  if( idx>=1 && idx<=5 && zName && zText ){
    char zEnum[20];
    char *zName2 = trim_string(zName);
    char *zDesc2 = trim_string(PD("d",""));
    bprintf(zEnum,sizeof(zEnum),"extra%d", idx);
    db_execute("BEGIN");

    /* Always delete... A missing description is meaningful for /tktnew */
    db_execute("DELETE FROM config WHERE name='%s_desc'", zEnum);

    if( zName2[0] ){
      string_to_enum(zEnum, zText);
      db_execute(
        "REPLACE INTO config(name,value) VALUES('%s_name','%q');",
        zEnum, zName2
      );
      if( zDesc2 && zDesc2[0] ){
        db_execute(
          "REPLACE INTO config(name,value) VALUES('%s_desc','%q');",
          zEnum, zDesc2
        );
      }
    }else{
      db_execute("DELETE FROM config WHERE name='%s_name'", zEnum);
      db_execute("DELETE FROM enums WHERE type='%s'", zEnum);
    }
    db_execute("COMMIT");
    db_config(0,0);
  }

  /* Genenerate the page.
  */
  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminUserField");
  common_header("设置用户自定义字段");
  @ <p>
  @ 数据库任务单表 TICKET 中包含了五个命名为 "extra1" 到 "extra5"
  @ 的扩展字段。这些字段栏目的含义可以在本设置页中由用户根据特定的
  @ 应用自己定义。
  @ </p>
  @
  @ <p>
  @ 每一个栏目都可以在下面独立地控制。当且仅当该栏目
  @ 的显示名不为空时，它将显示在任务单报表中。用户
  @ 在报表中看到的栏目是显示名，而不是类似的
  @ "extra1"。
  @ </p>
  @
  @ <p>
  @ 每个栏目允许的值可以在下面的编辑框中指定。
  @ 此处可使用的格式等同于在
  @ 指定 <a href="setup_enum?e=type">任务单类型</a>、
  @ <a href="setup_enum?e=status">任务单状态</a> 和
  @ <a href="setup_enum?e=subsys">子系统名称</a> 时的格式。
  @ 每行对应一个允许的值。
  @ 左边的标记是保存到数据库中的值。
  @ 随后的标记是用来显示的可读的描述文本。
  @ 描述文本后面是一个可选的用圆括号包
  @ 含的颜色名，用在报表显示中。
  @ </p>
  @
  @ <p>
  @ 允许值编辑框也可以留空。
  @ 如果为一个栏目定义了允许值列表，用户对该栏目内容的
  @ 修改将限制在这些值之中。
  @ 如果没有定义允许值列表，则栏目的内容可以为
  @ 任意的文本。
  @ </p>
  @
  @ <p>
  @ 描述编辑框可以为空。
  @ 如果提供了描述信息，则该字段会在新建任务单页面中显示并输入。
  @ 如果没有描述信息，则该字段内容能在编辑任务单页面中显示和修改，
  @ 但不会出现在新建任务单页面中。
  @ </p>
  for(i=0; i<5; i++){
    const char *zOld;
    char *zAllowed;
    const char *zDesc;
    char zEnumName[30];
    bprintf(zEnumName,sizeof(zEnumName),"extra%d_name",i+1);
    zOld = db_config(zEnumName,"");
    zEnumName[6] = 0;
    zAllowed = enum_to_string(zEnumName);
    bprintf(zEnumName,sizeof(zEnumName),"extra%d_desc",i+1);
    zDesc = db_config(zEnumName,"");
    @ <hr>
    @ <h3>数据库栏目 "extra%d(i+1)":</h3>
    @ <form action="%s(g.zPath)" method="POST">
    @ <input type="hidden" name="idx" value="%d(i+1)">
    @ 显示名:
    @ <input type="text" name="n" value="%h(zOld)"><br>
    @ 允许值列表: (<i>名称 描述 颜色</i> - 忽略剩余的文本)<br>
    @ <textarea cols=60 rows=15 name="x">%h(zAllowed)</textarea><br>
    @ 描述信息: (HTML - 留空将从新建任务单页面中忽略)<br>
    @ <textarea cols=60 rows=5 name="d">%h(zDesc)</textarea><br>
    @ <input type="submit" value="提交">
    @ </form>
  }
  common_footer();
}

/*
** WEBPAGE: /setup_chng
*/
void setup_chng_page(void){
  const char *zNotify, *zOldNotify;

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  /*
  ** The "notify" query parameter is the name of a program or script that
  ** is run whenever a ticket is created or modified.  Modify the notify
  ** value if it has changed.  Only setup can do this.
  */
  zOldNotify = db_config("notify","");
  zNotify = P("notify");
  if( zNotify && strcmp(zOldNotify,zNotify)!=0 ){
    db_execute(
      "REPLACE INTO config(name,value) VALUES('notify','%q');",
      zNotify
    );
    zOldNotify = zNotify;
    db_config(0,0);
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminNotification");
  common_header("设置任务单变更通知");
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>输入一个外部命令，当一个任务单被创建或修改时
  @ 会自动调用。 在传给 /bin/sh 前，下面的符号会
  @ 替换成相应的字符串:
  @
  @ <table border=1 cellspacing=0 cellpadding=5 align="right" width="45%%">
  @ <tr><td bgcolor="#e0c0c0">
  @ <big><b>重要的安全提示</b></big>
  @
#ifdef CVSTRAC_WINDOWS
  @ <p>请保证所有的替换符号都使用双引号包含起来。
  @ (如 <tt>"%%d"</tt>) 否则，用户可能会使用其它任意
  @ 的外部命令在您的系统上运行。</p>
  @
  @ <p>文本在替换前会除去所有的单引号和反斜杆，
  @ 所以如果替换符号自身用双引号包含时，它会被
  @ 外壳当作一个标记来看待。</p>
#else
  @ <p>请保证所有的替换符号都使用单引号包含起来。
  @ (如 <tt>'%%d'</tt>) 否则，用户可能会使用其它任意
  @ 的外部命令在您的系统上运行。</p>
  @
  @ <p>文本在替换前会除去所有的单引号和反斜杆，
  @ 所以如果替换符号自身用单引号包含时，它会被
  @ 外壳当作一个标记来看待。</p>
#endif
  @
  @ <p>最安全的方法是，只使用一个 <b>%%n</b> 替换符号，
  @ 然后用一个 Tcl 或 Perl 脚本从数据库中直接读取出其它的字段内容。</p>
  @ </td></tr></table>
  @
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td width="40"><b>%%a</b></td>
  @     <td>该任务单分配给的用户名</td></tr>
  @ <tr><td><b>%%A</b></td><td>任务分配人的邮件地址</td></tr>
  @ <tr><td><b>%%c</b></td><td>任务负责人的联系方式</td></tr>
  @ <tr><td><b>%%d</b></td><td>描述信息</td></tr>
  @ <tr><td><b>%%D</b></td><td>HTML 格式的描述信息</td></tr>
  @ <tr><td><b>%%n</b></td><td>任务单编号</td></tr>
  @ <tr><td><b>%%p</b></td><td>项目名称</td></tr>
  @ <tr><td><b>%%r</b></td><td>备注信息</td></tr>
  @ <tr><td><b>%%R</b></td><td>HTML 格式的备注信息</td></tr>
  @ <tr><td><b>%%s</b></td><td>任务单的状态</td></tr>
  @ <tr><td><b>%%t</b></td><td>任务单的标题</td></tr>
  @ <tr><td><b>%%u</b></td>
  @     <td>修改该任务单的用户名</td></tr>
  @ <tr><td><b>%%w</b></td><td>任务单的创建人用户名</td></tr>
  @ <tr><td><b>%%y</b></td><td>任务单的类型</td></tr>
  @ <tr><td><b>%%f</b></td><td>第一次变更的 TKTCHNG 记录 ID；如果是新记录则为 0。</td></tr>
  @ <tr><td><b>%%l</b></td><td>最后一次变更的 TKTCHNG 记录 ID；如果是新记录则为 0。</td></tr>
  @ <tr><td><b>%%h</b></td><td>如果变更内容是增加新附件，则为附件编号，否则为 0。</td></tr>
  @ <tr><td><b>%%1</b></td><td>第一个用户自定义字段</td></tr>
  @ <tr><td><b>%%2</b></td><td>第二个用户自定义字段</td></tr>
  @ <tr><td><b>%%3</b></td><td>第三个用户自定义字段</td></tr>
  @ <tr><td><b>%%4</b></td><td>第四个用户自定义字段</td></tr>
  @ <tr><td><b>%%5</b></td><td>第五个用户自定义字段</td></tr>
  @ <tr><td><b>%%%%</b></td><td>原样输出字符 "<b>%%</b>"</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ <input type="text" name="notify" size="70" value="%h(zOldNotify)">
  @ <input type="submit" value="提交">
  @ </form>
  common_footer();
}

/*
** WEBPAGE: /setup_diff
*/
void setup_diff_page(void){
  const char *zDiff, *zOldDiff;
  const char *zList, *zOldList;
  const char *zFilter, *zOldFilter;

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  /*
  ** The "diff" query parameter is the name of a program or script that
  ** is run whenever a ticket is created or modified.  Modify the filediff
  ** value if it has changed.  Only setup can do this.
  */
  zOldDiff = db_config("filediff","");
  zDiff = P("diff");
  if( zDiff && strcmp(zOldDiff,zDiff)!=0 ){
    if( zDiff[0] ){
      db_execute(
        "REPLACE INTO config(name,value) VALUES('filediff','%q');",
        zDiff
      );
    }else{
      db_execute("DELETE FROM config WHERE name='filediff'");
    }
    zOldDiff = zDiff;
    db_config(0,0);
  }

  /*
  ** The "list" query parameter is the name of a program or script that
  ** is run whenever a ticket is created or modified.  Modify the filelist
  ** value if it has changed.  Only setup can do this.
  */
  zOldList = db_config("filelist","");
  zList = P("list");
  if( zList && strcmp(zOldList,zList)!=0 ){
    if( zList[0] ){
      db_execute(
        "REPLACE INTO config(name,value) VALUES('filelist','%q');",
        zList
      );
    }else{
      db_execute("DELETE FROM config WHERE name='filelist'");
    }
    zOldList = zList;
    db_config(0,0);
  }

  /*
  ** The "filter" query parameter is the name of a program or script that any
  ** files get filtered through for HTML markup.
  */
  zOldFilter = db_config("filefilter","");
  zFilter = P("filter");
  if( zFilter && strcmp(zOldFilter,zFilter)!=0 ){
    if( zFilter[0] ){
      db_execute(
        "REPLACE INTO config(name,value) VALUES('filefilter','%q');",
        zFilter
      );
    }else{
      db_execute("DELETE FROM config WHERE name='filefilter'");
    }
    zOldFilter = zFilter;
    db_config(0,0);
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminFilter");
  common_header("设置源代码比较程序");
  @ <form action="%s(g.zPath)" method="POST">
  @ <h2>文件比较</h2>
  @ <p>输入一个外部命令用来对同一个文件的两个不同版本进行比较，
  @ 输出方式可以是纯文本或 HTML 格式。
  @ 如果使用 HTML，则第一个非空白字符要求是
  @ 字符 "<"。否则会认为输出内容为纯文本格式。</p>
  @
  @ <table border=1 cellspacing=0 cellpadding=5 align="right" width="33%%">
  @ <tr><td bgcolor="#e0c0c0">
  @ <big><b>重要的安全提示</b></big>
  @
  @ <p>请保证所有的替换符号都使用单引号包含起来。
  @ (如 <tt>'%%F'</tt> 或 <tt>'%%V2'</tt>)
  @ 否则，如果用户提交一些新文件
  @ （使用非常规的文件名）将可能在您的系统上执行任意
  @ 的外部命令。</p>
  @
  @ <p>CVSTrac 将不尝试比较一个名字中包含单引号或反斜杆的
  @ 文件。
  @ 所以如果替换符号自身用单引号包含时，它会被
  @ 外壳当作一个标记来看待。</p>
  @ </td></tr></table>
  @
  @ <p>下面替换符号将在执行程序前处理:</p>
  @
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td width="40" valign="top"><b>%%F</b></td>
  if( !strcmp(g.scm.zSCM,"cvs") ){
    @     <td>需要比较的 RCS 文件名。这是一个包含
    @         "<b>,v</b>" 后缀的完整路径的文件名。</td></tr>
  }else{
    @     <td>需要进行比较的文件名。</td>
  }
  @ </tr>
  @ <tr><td><b>%%V1</b></td><td>需要比较的第一个版本</td></tr>
  @ <tr><td><b>%%V2</b></td><td>需要比较的第二个版本</td></tr>
  @ <tr><td><b>%%RP</b></td><td>仓库根路径</td></tr>
  @ <tr><td><b>%%%%</b></td><td>原样输出字符 "<b>%%</b>"</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ <input type="text" name="diff" size="70" value="%h(zOldDiff)">
  @ <input type="submit" value="提交">
  @
  @ <p>如果留空，将使用以下命令:</p>
  @
  @ <blockquote><pre>
  if( !strcmp(g.scm.zSCM,"cvs") ){
    @ rcsdiff -q -r'%%V1' -r'%%V2' -u '%%F'
  }else{
    @ svnlook diff -r '%%V2' '%%RP'
  }
  @ </pre></blockquote>
  @ </form>
  @ <hr>

  @ <form action="%s(g.zPath)" method="POST">
  @ <h2>文件列表</h2>
  @ <p>输入一个外部命令用来<i>类似于比较方式</i>
  @ 显示一个文件指定版本的内容
  @ (即显示文件的第一个版本)。输出方式可以是纯文本或 HTML 格式。
  @ 如果使用 HTML，则第一个非空白字符要求是
  @ 字符 "<"。否则会认为输出内容为纯文本格式。</p>
  @
  @ <p>该命令用于在显示一个最近被加入到
  @ 仓库中的文件内容。</p>
  @
  @ <p>下面替换符号将在执行程序前处理:</p>
  @
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td width="40" valign="top"><b>%%F</b></td>
  if( !strcmp(g.scm.zSCM,"cvs") ){
    @     <td>需要比较的 RCS 文件名。这是一个包含
    @         "<b>,v</b>" 后缀的完整路径的文件名。</td>
  }else{
    @     <td>需要进行比较的文件名。</td>
  }
  @ </tr>
  @ <tr><td><b>%%V</b></td><td>要显示内容的版本号</td></tr>
  @ <tr><td><b>%%RP</b></td><td>仓库根路径</td></tr>
  @ <tr><td><b>%%%%</b></td><td>原样输出字符 "<b>%%</b>"</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ <input type="text" name="list" size="70" value="%h(zOldList)">
  @ <input type="submit" value="提交">
  @
  @ <p>如果留空，将使用以下命令:</p>
  @
  @ <blockquote><pre>
  if( !strcmp(g.scm.zSCM,"cvs") ){
    @ co -q -p'%%V' '%%F' | diff -c /dev/null -
  }else{
    @ svnlook cat -r '%%V' '%%RP' '%%F'
  }
  @ </pre></blockquote>
  @ </form>
  @ <hr>

  @ <form action="%s(g.zPath)" method="POST">
  @ <h2>文件过滤器</h2>
  @ <p>输入一个外部命令用来对文件的单个版本进行内容过滤。
  @ 这个过滤器将从标准输入中取得文件内容，
  @ 输出方式可以是纯文本或 HTML 格式。
  @ 如果使用 HTML，则第一个非空白字符要求是
  @ 字符 "<"。否则会认为输出内容为纯文本格式。</p>
  @
  @ <p>该命令用于显示文件的内容。</p>
  @
  @ <p>下面替换符号将在执行程序前处理:</p>
  @
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td width="40" valign="top"><b>%%F</b></td>
  if( !strcmp(g.scm.zSCM,"cvs") ){
    @     <td>将进行处理的文件名。这是一个相对路径的文件名，
    @         可用来显示或检查文件内容。</td>
  }else{
    @     <td>将进行处理的文件名。</td>
  }
  @ </tr>
  @ <tr><td><b>%%V</b></td><td>需要显示的版本号</td></tr>
  @ <tr><td><b>%%RP</b></td><td>仓库根路径</td></tr>
  @ <tr><td><b>%%%%</b></td><td>原样输出字符 "<b>%%</b>"</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ <input type="text" name="filter" size="70" value="%h(zOldFilter)">
  @ <input type="submit" value="提交">
  @
  @ <p>如果留空，输出内容将直接使用
  @ HTML &lt;PRE&gt; 标签来作为简单的 HTML 显示。</p>
  @ </form>
  common_footer();
}

/*
** WEBPAGE: /setup_style
*/
void setup_style_page(void){
  const char *zHeader, *zFooter;

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  /*
  ** If both "header" and "footer" query parameters are present, then
  ** change the header and footer to the values of those parameters.
  ** Only the setup user can do this.
  */
  if( P("ok") && P("header") && P("footer") ){
    db_execute(
      "REPLACE INTO config VALUES('header','%q');"
      "REPLACE INTO config VALUES('footer','%q');",
       trim_string(P("header")),
       trim_string(P("footer"))
    );
    db_config(0,0);
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminStyle");
  if( attachment_max()>0 ){
    common_add_action_item("attach_add?tn=0", "附件");
  }
  common_header("设置样式");
  @ <p>
  @ 输入用来显示在每个页面的页眉和页脚的 HTML 代码。
  @ 如果留空，将使用默认的页眉和页脚。
  @ 如果输入了一个文件名（由字符 "/" 开头的文件名）
  @ 来代替 HTML 文本，则该文件会在运行
  @ 期读入来作为页眉或页脚。</p>
  @
  @ <p>
  @ 您可以在这个页面添加附件，这些附件可以被定制的页眉页
  @ 脚或其它页面引用。例如，样式表、JavaScript 文件、
  @ 网站标志、图标等都可以作为附件。这些附件可以直接通过
  @ 文件名 (例如 <i>filename.png</i>) 来引用，而不需要
  @ <i>attach_get/89/filename.png</i> 这种完整的链接。</p>
  @
  @ <p>一份默认的 <a href="cvstrac.css">cvstrac.css</a> 样式表始终是有效的。
  @ 然而，您也可以附加一份更新的版本到这个页面。
  @ 原始的版本可通过
  @ <a href="cvstrac_default.css">cvstrac_default.css</a> 取得。</p>
  @
  @ <p>以下替换用于页眉和页脚的文本中。这些替换内容是
  @ HTML 无关的，不管这些 HTML 内容是直接在下面输入
  @ 还是从文件中读取来的。</p>
  @
  @ <blockquote>
  @ <table>
  @ <tr><td width="40"><b>%%N</b></td><td>项目的名称</td></tr>
  @ <tr><td><b>%%T</b></td><td>当前页面的标题</td></tr>
  @ <tr><td><b>%%V</b></td><td>CVSTrac 的版本号</td></tr>
  @ <tr><td><b>%%B</b></td><td>CVSTrac 基础链接</td></tr>
  @ <tr><td><b>%%D</b></td><td>当前文档链接 (不包含基本的链接)</td></tr>
  @ <tr><td><b>%%%%</b></td><td>原样输出字符 "<b>%%</b>"</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>
  zHeader = db_config("header","");
  zFooter = db_config("footer","");

  /* user wants to restore the defaults */
  if( P("def") ){
    zHeader = HEADER;
    zFooter = FOOTER;
  }

  @ 页眉:<br>
  @ <textarea cols=80 rows=8 name="header">%h(zHeader)</textarea><br>
  @ 页脚:<br>
  @ <textarea cols=80 rows=8 name="footer">%h(zFooter)</textarea><br>
  @ <input type="submit" name="ok" value="提交">
  @ <input type="submit" name="def" value="默认">
  @ <input type="submit" name="can" value="取消">
  @ </p>
  @ </form>

  attachment_html("0","","");

  common_footer();
}

/*
** Make a copy of file zFrom into file zTo.  If any errors occur,
** return a pointer to a string describing the error.
*/
static const char *file_copy(const char *zFrom, const char *zTo){
  FILE *pIn, *pOut;
  int n;
  long long int total = 0;
  char zBuf[10240];
  pIn = fopen(zFrom, "r");
  if( pIn==0 ){
    return mprintf(
      "无法复制文件 - 不能以读方式打开文件 \"%h\" 。", zFrom
    );
  }
  unlink(zTo);
  pOut = fopen(zTo, "w");
  if( pOut==0 ){
    fclose(pIn);
    return mprintf(
      "无法复制文件 - 不能以写方式打开文件 \"%h\" 。", zTo
    );
  }
  while( (n = fread(zBuf, 1, sizeof(zBuf), pIn))>0 ){
    if( fwrite(zBuf, 1, n, pOut)<n ){
      fclose(pIn);
      fclose(pOut);
      return mprintf(
        "复制操作在完成 %lld 字节后失败。磁盘满了吗？", total
      );
    }
    total += n;
  }
  fclose(pIn);
  fclose(pOut);
  return 0;
}

/*
** WEBPAGE: /setup_attach
*/
void setup_attachment_page(void){
  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  if( P("sz") ){
    int sz = atoi(P("sz"))*1024;
    db_execute("REPLACE INTO config VALUES('max_attach_size',%d)", sz);
    db_config(0, 0);
    cgi_redirect("setup");
  }
 
  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminAttachment");
  common_header("设置附件文件最大长度");
  @ <p>
  @ 在下面输入附件文件允许的最大长度。如果输入零，
  @ 将不允许上传附件。
  @ </p>
  @
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>
  @ 最大允许附件文件长度:
  @ <input type="text" name="sz" value="%d(attachment_max()/1024)" size=5> KB。
  @ <input type="submit" value="设置">
  @ </p>
  @ </form>
  common_footer();
}

/*
** WEBPAGE: /setup_throttle
*/
void setup_throttle_page(void){
  int mxHit = atoi(db_config("throttle","0"));
  int nf = atoi(db_config("nofollow_link","0"));
  int cp = atoi(db_config("enable_captcha","0"));
  int lnk = atoi(db_config("max_links_per_edit","0"));
  int mscore = atoi(db_config("keywords_max_score","0"));
  const char *zKeys = db_config("keywords","");

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }


  if( P("sz") && atoi(P("sz"))!=mxHit ){
    mxHit = atoi(P("sz"));
    db_execute("REPLACE INTO config VALUES('throttle',%d)", mxHit);
    db_config(0, 0);
  }

  if( P("nf") && atoi(P("nf"))!=nf ){
    nf = atoi(P("nf"));
    db_execute("REPLACE INTO config VALUES('nofollow_link',%d)", nf);
    db_config(0, 0);
  }
 
  if( P("cp") && atoi(P("cp"))!=cp ){
    cp = atoi(P("cp"));
    db_execute("REPLACE INTO config VALUES('enable_captcha',%d)", cp);
    db_config(0, 0);
  }
 
  if( P("lnk") && atoi(P("lnk"))!=lnk ){
    lnk = atoi(P("lnk"));
    db_execute("REPLACE INTO config VALUES('max_links_per_edit',%d)", lnk);
    db_config(0, 0);
  }

  if( P("mscore") && atoi(P("mscore"))!=mscore ){
    mscore = atoi(P("mscore"));
    db_execute("REPLACE INTO config VALUES('keywords_max_score',%d)", mscore);
    db_config(0, 0);
  }

  if( P("keys") && strcmp(zKeys,PD("keys","")) ){
    zKeys = P("keys");
    db_execute("REPLACE INTO config VALUES('keywords','%q')", zKeys);
    db_config(0, 0);
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminAbuse");
  common_header("带宽限制");
  @ <h2>设置匿名用户每小时最高访问次数限制</h2>
  @ <p>
  @ 输入来自同一IP地址的匿名用户允许的
  @ 每小时最高的访问次数。输入零表示不
  @ 作限制。
  @ </p>
  @
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>
  @ 每小时最高访问量:
  @ <input type="text" name="sz" value="%d(mxHit)" size=5>
  @ <input type="submit" value="设置">
  @ </p>
  @ </form>
  @
  @ <p>
  @ 限制器通过数据库中一张单独的表 (表 ACCESS_LOAD) 来工作，
  @ 它记录了来自每个访问IP的最后访问时间和一个 "负载值"。
  @ 负载值每隔一小时会按指数规律减半。
  @ 每个新的访问会增加一个单位的负载值，
  @ 当负载值增长到设定的上限时，负载值将自动翻倍，
  @ 并且客户端将跳转到 <a href="captcha">智能验证</a>
  @ 页面。当这样的跳转发生过几次后，
  @ 用户将被禁止访问，直接负载值下降到极限值
  @ 以下。如果用户通过了
  @ <a href="captcha">智能验证</a> 测试，一个 Cookie 标志将被设置。
  @ </p>
  @
  @ <p>
  @ 当使用限制器时，<a href="captcha">智能验证</a>
  @ 页面同样会在用户试图做任何改动数据库
  @ 的活动前显示 (如创建 <a href="tktnew">新的任务单</a>，
  @ <a href="wikiedit?p=WikiIndex">修改 Wiki 页面</a> 等等)。这个
  @ 功能用来阻止那些自动垃圾 Wiki 生成器。
  @
  @ <p>
  @ 所有对 "禁止" 页(通过
  @ <a href="honeypot">陷阱</a> 页)的访问自动将负载值增长到
  @ 上限的两倍。每一个网页上都有一个隐藏的陷
  @ 阱页超链接。这个方法用来欺骗那些网络蜘蛛去访问
  @ 陷阱页，使得他们的访问很快地被禁止掉。
  @ </p>
  @
  @ <p>
  @ 限制器和陷阱只针对那些没有登录的匿名用户有效。
  @ 登录用户能任意次数地访问任何页面
  @ (包括陷阱页)，并且永远不会被拒绝
  @ 访问。另外，限制器(但不包含陷阱)对那些通过了
  @ <a href="captcha">智能验证</a> 并设置了 Cookie
  @ 的人失效。
  @ </p>
  @
  @ <p>一份对 <a href="info_throttle">访问日志</a> 的统计是
  @ 单独可用的。</p>

  @ <hr>
  @ <h2>智能验证</h2>
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>
  @ 如果开启这个选项，匿名用户在被允许修改网站内容（任务单、wiki 等）
  @ 之前，必须通过一个简单的 <a href="http://en.wikipedia.org/wiki/Captcha">智能验证</a>
  @ 测试。通过测试后将会在浏览器中设置
  @ Cookie 标志。如果测试失败次数太多
  @ 将会触发限定器以锁定用户 IP 地址。
  @ 注：如果要开启这个选项，流量限制功能必须已经开启
  @ （非零值）。
  @ </p>
  @ <p>
  @ <label for="cp"><input type="checkbox" name="cp" id="cp"
  @    %s(cp?" checked":"") %s(mxHit?"":"disabled") value="1">
  @ 为修改内容开启智能验证功能</label>
  @ </p>
  @ <input type="submit" value="设置">
  @ </form>
  @ <hr>

  @ <h2>外部链接</h2>
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>
  @ 如果开启这个选项，所有链接到外部站点的超链接都将标记为
  @ "不跟踪"。这将提供给搜索引擎一个提示来忽略这些链接，
  @ 以达到抑制 wiki 垃圾的目的。无论如何，这只是个用处有限的功能，wiki
  @ 垃圾制造者们并不总是有足够的聪明能认识到这种行为只是在浪费他们
  @ 自己的时间。
  @ </p>
  @ <p>
  @ <label for="nf"><input type="checkbox" name="nf" id="nf"
  @    %s(nf?" checked":"") value="1">
  @ 不允许搜索引擎跟踪访问外部链接。</label>
  @ </p>
  @ <input type="submit" value="设置">
  @ </form>
  @ 
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>
  @ Wiki 垃圾生成器通过向一个页面插入大量的外部链接
  @ 来工作。一个简单的解决办法是强制在单个 wiki 编辑中
  @ 限制外部链接的最大数。
  @ 设置为零将禁用该选项。
  @ </p>
  @ <p>
  @ 每次 Wiki 编辑时允许的最大外部链接数:
  @ <input type="text" name="lnk" value="%d(lnk)" size=5>
  @ </p>
  @ <input type="submit" value="设置">
  @ </form>
  @ <hr>
  @ <h2>关键字过滤</h2>
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>
  @ 输入一个空格分隔的关键字列表。所有的 wiki 编辑都将
  @ 检查这个列表，如果超过最大阈值限制，
  @ 修改将会拒绝。评分算法使用标准的
  @ CVSTrac 文本 <strong>search()</strong> 函数（其中每一个匹配的关键
  @ 字将获得 6 到 10 个点）。重复出现列表中的一个关键字将导致
  @ 更高的分值。
  @ </p>
  @ <p>
  cgi_text("mscore", 0, 0, 0, 0, 5, 8, 1, mprintf("%d",mscore),
           "最大关键字分值");
  @ </p>
  @ <h3>关键字黑名单</h3>
  @ <p><textarea name="keys" rows="8" cols="80" class="wrapvirtual">
  @ %h(zKeys)
  @ </textarea></p>
  @ <input type="submit" value="设置">
  @ </form>

  common_footer();
}

/*
** WEBPAGE: /setup_markupedit
*/
void setup_markupedit_page(void){
  const char *zMarkup = PD("m","");
  const char *zType = PD("t","0");
  const char *zFormat = PD("f","");
  const char *zDescription = PD("d","");
  int delete = atoi(PD("del","0"));

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_action_item("setup_markup", "取消");
  common_add_action_item(mprintf("setup_markupedit?m=%h&del=1",zMarkup),
                         "删除");
  common_add_help_item("CvstracAdminMarkup");
  common_header("定制 Wiki 标记");

  if( P("can") ){
    cgi_redirect("setup_markup");
    return;
  }else if( P("ok") ){
    /* delete it */
    db_execute("DELETE FROM markup WHERE markup='%q';", zMarkup);
    cgi_redirect("setup_markup");
    return;
  }else if( delete && zMarkup[0] ){
    @ <p>您确定要删除标记 <b>%h(zMarkup)</b>？</p>
    @
    @ <form method="POST" action="setup_markupedit">
    @ <input type="hidden" name="m" value="%h(zMarkup)">
    @ <input type="submit" name="ok" value="是，删除">
    @ <input type="submit" name="can" value="否，取消">
    @ </form>
    common_footer();
    return;
  }

  if( P("u") ){
    if( zMarkup[0] && zType[0] && zFormat[0] ) {
      /* update database and bounce back to listing page. If the
      ** description is empty, we'll survive (and wing it).
      */
      db_execute("REPLACE INTO markup(markup,type,formatter,description) "
                 "VALUES('%q',%d,'%q','%q');",
                 zMarkup, atoi(zType), zFormat, zDescription);
    }

    cgi_redirect("setup_markup");
    return;
  }
  
  if( zMarkup[0] ){
    /* grab values from database, if available
    */
    char **az = db_query("SELECT type, formatter, description "
                         "FROM markup WHERE markup='%q';",
                         zMarkup);
    if( az && az[0] && az[1] && az[2] ){
      zType = az[0];
      zFormat = az[1];
      zDescription = az[2];
    }
  }

  @ <form action="%s(g.zPath)" method="POST">
  @ 标记名称: <input type="text" name="m" value="%h(zMarkup)" size=12>
  cgi_optionmenu(0,"t",zType, "标记","0", "块","2",
    "程序标记","1", "程序块","3",
    "可信任的程序标记","4", "可信任的程序块","5",
    NULL);
  @ <br>格式:<br>
  @ <textarea name="f" rows="4" cols="60">%h(zFormat)</textarea><br>
  @ 描述:<br>
  @ <textarea name="d" rows="4" cols="60">%h(zDescription)</textarea><br>
  @ <input type="hidden" name="u">
  @ <input type="submit" value="设置">
  @ </form>
  @
  @ <table border=1 cellspacing=0 cellpadding=5 align="right" width="45%%">
  @ <tr><td bgcolor="#e0c0c0">
  @ <big><b>重要的安全提示</b></big>
  @
  @ <p>程序格式工具将执行外部脚本和程序，不适当的配置
  @ 可能会危及服务器的安全。</p>
  @
  @ <p>请确认使用单引号来包含所有的文本
  @ (如 <tt>'%%k'</tt>)。否则，别有用心的用户可能会
  @ 在您的服务器上执行任意的命令。</p>
  @  
  @ <p>文本在被替换之前，已经被截去了所有的单引号和反斜杆，
  @ 故如果替换结果本身使用单引号包含的话，
  @ 它将始终被外壳程序作为一个单独的符号来处理。</p>
  @ </td></tr></table>
  @
  @ 下列替换将应用于自定义标记中:
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td width="40"><b>%%m</b></td><td>标记名称</td></tr>
  @ <tr><td><b>%%k</b></td><td>标记键值</td></tr>
  @ <tr><td><b>%%a</b></td><td>标记参数</td></tr>
  @ <tr><td><b>%%x</b></td><td>标记参数，如果为空则为键值</td></tr>
  @ <tr><td><b>%%b</b></td><td>标记块</td></tr>
  @ <tr><td><b>%%r</b></td><td>%s(g.scm.zName) 仓库根路径</td></tr>
  @ <tr><td><b>%%n</b></td><td>CVSTrac 数据库名</td></tr>
  @ <tr><td><b>%%u</b></td><td>当前用户</td></tr>
  @ <tr><td><b>%%c</b></td><td>用户权限</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ 此外，外部程序还将拥有以下这些
  @ 环境变量定义:<br>
  @ REQUEST_METHOD, GATEWAY_INTERFACE, REQUEST_URI, PATH_INFO,
  @ QUERY_STRING, REMOTE_ADDR, HTTP_USER_AGENT, CONTENT_LENGTH,
  @ HTTP_REFERER, HTTP_HOST, CONTENT_TYPE, HTTP_COOKIE
  @ <br>
  @
  @ <h2>说明</h2>
  @ <ul>
  @   <li>标记名称为 Wiki 格式化标签。如一个标记
  @   <b>echo</b> 可以使用 <tt>{echo: key args}</tt> 来调用</li>
  @   <li>对标记名的修改，将打乱已存在的使用了该标记的
  @   Wiki 页面</li>
  @   <li>"标记" 只是简单的字符串替换，并由
  @   CVSTrac 直接处理</li>
  @   <li>"块" 标记是由成对的 {markup} 和 {endmarkup} 块组成，在它们之
  @   间的所有文本将作为参数 (%a)，不包含标记键值。</li>
  @   <li>"程序" 标记通过运行外部脚本和程序来处理。
  @   它们可以更为复杂，但同样也存在安全风险
  @   并且会减慢页面生成的速度。程序标记从命令行中取得参数，
  @   程序块则从标准输入中取得文本块内容。
  @   这两种方式都需要将 HTML 结果输出到标准输出</li>
  @   <li>输出时，除了可信任的标记，所有包含不安全的 HTML 标签/属性
  @   将被过滤。可信任的标记由它们自己来负责过滤
  @   (显然，这些也只能由程序来完成)。</li>
  @   <li>描述信息用来在使用 {markups} 标签枚举所有可用的
  @   标记列表时使用。这个列表包含在诸如
  @   <a href="wiki?p=WikiFormatting">WikiFormatting</a> 这样的页面中，
  @   以提供与服务器相关的文档。</li>
  @ </ul>

  common_footer();
}

/*
** WEBPAGE: /setup_markup
*/
void setup_markup_page(void){
  int j;
  char **az;

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_action_item("setup_markupedit", "增加标记");
  common_add_help_item("CvstracAdminMarkup");
  common_header("定制 Wiki 标记");

  az = db_query("SELECT markup, description FROM markup ORDER BY markup;");
  if( az && az[0] ){
    @ <p><big><b>定制标记规则</b></big></p>
    @ <dl>
    for(j=0; az[j]; j+=2){
      @ <dt><a href="setup_markupedit?m=%h(az[j])">%h(az[j])</a></dt>
      if( az[j+1] && az[j+1][0] ){
        /* this markup has a description, output it.
        */
        @ <dd>
        output_formatted(az[j+1],NULL);
        @ </dd>
      }else{
        @ <dd>(无描述)</dd>
      }
    }
    @ </dl>
  }

  common_footer();
}

/*
** WEBPAGE: /setup_toolsedit
*/
void setup_toolsedit_page(void){
  const char *zTool = PD("t","");
  const char *zObject = PD("o","");
  const char *zCommand = PD("c","");
  const char *zDescription = PD("d","");
  const char *zPerms = PD("p","as");
  int delete = atoi(PD("del","0"));

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_action_item("setup_tools", "取消");
  common_add_action_item(mprintf("setup_toolsedit?t=%h&del=1",zTool),
                         "Delete");
  common_header("外部工具");

  if( P("can") ){
    cgi_redirect("setup_tools");
    return;
  }else if( P("ok") ){
    /* delete it */
    db_execute("DELETE FROM tool WHERE name='%q';", zTool);
    cgi_redirect("setup_tools");
    return;
  }else if( delete && zTool[0] ){
    @ <p>您确定要删除工具 <b>%h(zTool)</b>吗？</p>
    @
    @ <form method="POST" action="setup_toolsedit">
    @ <input type="hidden" name="t" value="%h(zTool)">
    @ <input type="submit" name="ok" value="是，删除">
    @ <input type="submit" name="can" value="否，取消">
    @ </form>
    common_footer();
    return;
  }

  if( P("u") ){
    if( zTool[0] && zPerms[0] && zObject[0] && zCommand[0] ) {
      /* update database and bounce back to listing page. If the
      ** description is empty, we'll survive (and wing it).
      */
      db_execute("REPLACE INTO tool(name,perms,object,command,description) "
                 "VALUES('%q','%q','%q','%q','%q');",
                 zTool, zPerms, zObject, zCommand, zDescription);
    }

    cgi_redirect("setup_tools");
  }
  
  if( zTool[0] ){
    /* grab values from database, if available
    */
    char **az = db_query("SELECT perms, object, command, description "
                         "FROM tool WHERE name='%q';",
                         zTool);
    if( az && az[0] && az[1] && az[2] && az[3] ){
      zPerms = az[0];
      zObject = az[1];
      zCommand = az[2];
      zDescription = az[3];
    }
  }

  @ <form action="%s(g.zPath)" method="POST">
  @ 工具名称: <input type="text" name="t" value="%h(zTool)" size=12>
  cgi_optionmenu(0,"o",zObject,
                 "文件","file",
                 "Wiki","wiki",
                 "任务单","tkt",
                 "提交","chng",
                 "里程碑","ms",
                 "报表", "rpt",
                 "目录", "dir",
                 NULL);
  @ <br>需要的权限:
  @ <input type="text" name="p" size=16 value="%h(zPerms)"><br>
  @ <br>命令行:<br>
  @ <textarea name="c" rows="4" cols="60">%h(zCommand)</textarea><br>
  @ 描述:<br>
  @ <textarea name="d" rows="4" cols="60">%h(zDescription)</textarea><br>
  @ <input type="hidden" name="u">
  @ <input type="submit" value="设置">
  @ </form>
  @
  @ <table border=1 cellspacing=0 cellpadding=5 align="right" width="45%%">
  @ <tr><td bgcolor="#e0c0c0">
  @ <big><b>重要的安全提示</b></big>
  @
  @ <p>外部脚本、程序和不适当的配置
  @ 可能会危及服务器的安全。</p>
  @
  @ <p>请确认使用单引号来包含所有的文本
  @ (如 <tt>'%%k'</tt>)。否则，别有用心的用户可能会
  @ 在您的服务器上执行任意的命令。</p>
  @  
  @ <p>文本在被替换之前，已经被截去了所有的单引号和反斜杆，
  @ 故如果替换结果本身使用单引号包含的话，
  @ 它将始终被外壳程序作为一个单独的符号来处理。</p>
  @
  @ <p>每一个工具都有一个最小的权限设置要求。参见
  @ <a href="userlist">用户</a> 来获得全部的权限列表。</p>
  @ </td></tr></table>
  @
  @ 下列替换对所有外部工具有效:
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td><b>%%RP</b></td><td>%s(g.scm.zName) 仓库路径</td></tr>
  @ <tr><td><b>%%P</b></td><td>CVSTrac 工程名称</td></tr>
  @ <tr><td><b>%%B</b></td><td>服务器根 URL</td></tr>
  @ <tr><td><b>%%U</b></td><td>当前用户</td></tr>
  @ <tr><td><b>%%UC</b></td><td>用户权限</td></tr>
  @ <tr><td><b>%%N</b></td><td>当前时间点</td></tr>
  @ <tr><td><b>%%T</b></td><td>工具名称</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ 下列替换对文件工具有效:
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td><b>%%F</b></td><td>文件名</td></tr>
  @ <tr><td><b>%%V1</b></td><td>第一个版本号</td></tr>
  @ <tr><td><b>%%V2</b></td><td>第二个版本号 (例如 diff)</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ 下列替换对目录工具有效:
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td><b>%%F</b></td><td>目录路径名</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ 下列替换对任务单工具有效:
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td><b>%%TN</b></td><td>任务单编号</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ 下列替换对 Wiki 工具有效:
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td><b>%%W</b></td><td>Wiki 页面名称</td></tr>
  @ <tr><td><b>%%T1</b></td><td>第一个 wiki 页面的时间戳</td></tr>
  @ <tr><td><b>%%T2</b></td><td>第二个 wiki 页面的时间戳 (例如 diff)
  @            </td></tr>
  @ <tr><td><b>%%C</b></td><td>包含内容的临时文件</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ 下列替换对提交工具有效:
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td><b>%%CN</b></td><td>提交号</td></tr>
  @ <tr><td><b>%%C</b></td><td>包含信息的临时文件</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ 下列替换对里程碑工具有效:
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td><b>%%MS</b></td><td>里程碑编号</td></tr>
  @ <tr><td><b>%%C</b></td><td>包含信息的临时文件</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ 下列替换对报告工具有效:
  @ <blockquote>
  @ <table cellspacing="5" cellpadding="0">
  @ <tr><td><b>%%RN</b></td><td>报告编号</td></tr>
  @ </table>
  @ </blockquote>
  @
  @ 此外，外部程序还将有下列部分或全部的
  @ 环境变量定义:<br>
  @ REQUEST_METHOD, GATEWAY_INTERFACE, REQUEST_URI, PATH_INFO,
  @ QUERY_STRING, REMOTE_ADDR, HTTP_USER_AGENT, CONTENT_LENGTH,
  @ HTTP_REFERER, HTTP_HOST, CONTENT_TYPE, HTTP_COOKIE
  @ <br>
  common_footer();
}

/*
** WEBPAGE: /setup_tools
*/
void setup_tools_page(void){
  int j;
  char **az;

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  common_add_nav_item("setup", "主设置菜单");
  common_add_action_item("setup_toolsedit", "增加工具");
  common_header("外部工具");

  az = db_query("SELECT name, description FROM tool ORDER BY name;");
  if( az && az[0] ){
    @ <p><big><b>外部工具</b></big></p>
    @ <dl>
    for(j=0; az[j]; j+=2){
      @ <dt><a href="setup_toolsedit?t=%h(az[j])">%h(az[j])</a></dt>
      if( az[j+1] && az[j+1][0] ){
        /* this tool has a description, output it.
        */
        @ <dd>
        output_formatted(az[j+1],NULL);
        @ </dd>
      }else{
        @ <dd>(无描述)</dd>
      }
    }
    @ </dl>
  }

  common_footer();
}

/*
** WEBPAGE: /setup_backup
*/
void setup_backup_page(void){
  char *zDbName = mprintf("%s.db", g.zName);
  char *zBuName = mprintf("%s.db.bu", g.zName);
  const char *zMsg = 0;

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  if( P("bkup") ){
    db_execute("BEGIN");
    zMsg = file_copy(zDbName, zBuName);
    db_execute("COMMIT");
  }else if( P("rstr") ){
    db_execute("BEGIN");
    zMsg = file_copy(zBuName, zDbName);
    db_execute("COMMIT");
  }
 
  common_add_nav_item("setup", "主设置菜单");
  common_add_help_item("CvstracAdminBackup");
  common_header("备份数据库");
  if( zMsg ){
    @ <p class="error">%s(zMsg)</p>
  }
  @ <p>
  @ 使用下面的按钮对数据库进行安全自动地备份及恢复操作。
  @ 原数据库文件名
  @ 为 <b>%h(zDbName)</b>，备份文件
  @ 为 <b>%h(zBuName)</b>。
  @ </p>
  @
  @ <p>
  @ 备份总是安全的。最坏的情形是会覆盖上一次的
  @ 备份。但是如果在恢复时中断操作，将会破坏您
  @ 的数据库。
  @ 使用恢复功能时，请谨慎。
  @ </p>
  @
  @ <form action="%s(g.zPath)" method="POST">
  @ <p><input type="submit" name="bkup" value="备份"></p>
  @ <p><input type="submit" name="rstr" value="恢复"></p>
  @ </form>
  common_footer();
}

/*
** WEBPAGE: /setup_timeline
*/
void setup_timeline_page(void){
  int nCookieLife;
  int nTTL;
  int nRDL;
  
  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }
  
  if( P("cl") || P("ttl") || P("rdl") ){
    if( P("cl") ){
      int nCookieLife = atoi(P("cl"));
      db_execute("REPLACE INTO config VALUES('timeline_cookie_life',%d)", nCookieLife);
    }
    if( P("ttl") ){
      int nTTL = atoi(P("ttl"));
      db_execute("REPLACE INTO config VALUES('rss_ttl',%d)", nTTL);
    }
    if( P("rdl") ){
      int nRDL = atoi(P("rdl"));
      db_execute("REPLACE INTO config VALUES('rss_detail_level',%d)", nRDL);
    }
    db_config(0, 0);
  }
  
  nCookieLife = atoi(db_config("timeline_cookie_life", "90"));
  nTTL = atoi(db_config("rss_ttl", "60"));
  nRDL = atoi(db_config("rss_detail_level", "5"));
  
  common_add_nav_item("setup", "主设置菜单");
  common_header("时间线和 RSS 设置");
  @ <form action="%s(g.zPath)" method="POST">
  @ <p>
  @ 输入在用户浏览器中 Cookie 需要保存的天数。
  @ 该 Cookie 能保存时间线的设置以方便用户的多次访问。<br>
  @ 该功能对所有用户有效。<br>
  @ 设置为 0 将禁用浏览器 Cookie。
  @ </p>
  @ <p>
  @ Cookie 生命期: 
  @ <input type="text" name="cl" value="%d(nCookieLife)" size=5> 天
  @ <input type="submit" value="提交">
  @ </p>
  @ <hr>
  @ <p>
  @ RSS feed 的 TTL (Time To Live) 用来通知 RSS 阅读器其内容在刷新之前
  @ 需要缓存多长时间。因为每次刷新都需要下载整个页面，为了避免额外的带宽
  @ 占用，这个值可以设置得长一些。
  @ 低于 15 的值可能不是个好的方案，通常建议使用 30-60
  @ 的数值。
  @ </p>
  @ <p>
  @ Time To Live:
  @ <input type="text" name="ttl" value="%d(nTTL)" size=5> 分钟
  @ <input type="submit" value="提交">
  @ </p>
  @ <hr>
  @ <p>
  @ RSS 源的详细等级决定了在源中将会包含
  @ 多少详细内容。<br>
  @ 详细等级越高，带宽占用也会越大。
  @ </p>
  @ <p>
  @ RSS 详细等级:<br>
  @ <label for="rdl0"><input type="radio" name="rdl" value="0" id="rdl0"
  @ %s(nRDL==0?" checked":"")> 基本</label><br>
  @ <label for="rdl5"><input type="radio" name="rdl" value="5" id="rdl5"
  @ %s(nRDL==5?" checked":"")> 中等</label><br>
  @ <label for="rdl9"><input type="radio" name="rdl" value="9" id="rdl9"
  @ %s(nRDL==9?" checked":"")> 高</label><br>
  @ <input type="submit" value="设置">
  @ </p>
  @ </form>
  common_footer();
}

#if 0  /* TO DO */
/*
** WEB-PAGE: /setup_repair
*/
void setup_repair_page(void){

  /* The user must be the setup user in order to see
  ** this screen.
  */
  login_check_credentials();
  if( !g.okSetup ){
    cgi_redirect("setup");
    return;
  }

  /*
  ** Change a check-in number.
  */
  cnfrom = atoi(PD("cnfrom"),"0");
  cnto = atoi(PD("cnto"),"0");
  if( cnfrom>0 && cnto>0 && cnfrom!=cnto ){
    const char *zOld;
    zOld = db_short_query(
       "SELECT rowid FROM chng WHERE cn=%d", cnfrom
    );
    if( zOld || zOld[0] ){
      db_execute(
        "BEGIN;"
        "DELETE FROM chng WHERE cn=%d;"
        "UPDATE chng SET cn=%d WHERE cn=%d;"
        "UPDATE filechng SET cn=%d WHERE cn=%d;"
        "UPDATE xref SET cn=%d WHERE cn=%d;"
        "COMMIT;",
        cnto,
        cnto, cnfrom,
        cnto, cnfrom,
        cnto, cnfrom
      );
    }
  }

  /*
  ** Remove duplicate entries in the FILECHNG table.  Remove check-ins
  ** from the CHNG table that have no corresponding FILECHNG entries.
  */
  if( P("rmdup") ){
    db_execute(
      "BEGIN;"
      "DELETE FROM filechng WHERE rowid NOT IN ("
         "SELECT min(rowid) FROM filechng "
         "GROUP BY filename, vers||'x'"
      ");"
      "DELETE FROM chng WHERE milestone=0 AND cn NOT IN ("
         "SELECT cn FROM filechng"
      ");"
      "COMMIT;"
    );
  }

  common_add_nav_item("setup", "主设置菜单");
  common_header("修复数据库");
  @ <p>
  @ 您可以使用该页面来修复在
  @ 读取仓库数据文件时发生了错误的数据库。
  @ 该问题可能是由于错误的 %s(g.scm.zName) 仓库或一个系统错误，
  @ 或者是 CVSTrac 的错误。（所有已知的这种类型的错误
  @ 都已修正，但不知道新的问题什么时候还会出现。）
  @ </p>
  @
  @
  @ </p>
  common_footer();
}
#endif
