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
** Routines for handling user account
*/
#define _XOPEN_SOURCE
#include <unistd.h>
#include "config.h"
#include "user.h"

/*
** WEBPAGE: /userlist
*/
void user_list(void){
  char **azResult;
  int i;

  login_check_credentials();
  if( !g.okWrite && g.isAnon ){
    login_needed();
    return;
  }
  common_standard_menu("userlist", 0);
  common_add_help_item("CvstracAdminUsers");
  common_add_action_item("useredit", "新增用户");
  common_header("用户列表");
  @ <table cellspacing=0 cellpadding=0 border=0>
  @ <tr>
  @   <th align="right" class="nowrap">用户名</th>
  @   <th>&nbsp;&nbsp;&nbsp;许访问&nbsp;&nbsp;&nbsp;</th>
  @   <th class="nowrap">真实姓名</th>
  @ </tr>
  azResult = db_query(
    "SELECT id, name, email, capabilities FROM user ORDER BY id");
  for(i=0; azResult[i]; i+= 4){
    @ <tr>
    @ <td align="right">
    if( g.okAdmin ){
      @ <a href="useredit?id=%t(azResult[i])">
    }
    @ <span class="nowrap">%h(azResult[i])</span>
    if( g.okAdmin ){
      @ </a>
    }
    @ </td>
    @ <td align="center">%s(azResult[i+3])</td>
    if( azResult[i+2] && azResult[i+2][0] ){
      char *zE = azResult[i+2];
      @ <td align="left" class="nowrap">%h(azResult[i+1])
      @    (<a href="mailto:%h(zE)">%h(zE)</a>)</td>
    } else {
      @ <td align="left" class="nowrap">%h(azResult[i+1])</td>
    }
    @ </tr>
  }
  @ </table>
  @ <hr>
  @ <p><b>提示:</b></p>
  @ <ol>
  @ <li><p>允许访问标志如下:</p>
  @ <table>
  @ <tr><td>a</td><td width="10"></td>
  @     <td>管理: 创建或删除用户及任务单报表格式。</td></tr>
  @ <tr><td>d</td><td></td>
  @     <td>删除: 删除匿名的 Wiki、任务单和附件。</td></tr>
  @ <tr><td>i</td><td></td>
  @     <td>提交: 添加新的代码到 %h(g.scm.zName) 仓库中。</td></tr>
  @ <tr><td>j</td><td></td><td>读 Wiki: 查看 Wiki 页面。</td></tr>
  @ <tr><td>k</td><td></td><td>写 Wiki: 创建或修改 Wiki 页面。</td></tr>
  @ <tr><td>n</td><td></td><td>新建任务单: 创建新的任务单。</td></tr>
  @ <tr><td>o</td><td></td>
  @     <td>取出: 从 %h(g.scm.zName) 仓库中取出代码。</td></tr>
  @ <tr><td>p</td><td></td><td>密码: 修改用户密码。</td></tr>
  @ <tr><td>q</td><td></td><td>查询: 创建或编辑报表格式。</td></tr>
  @ <tr><td>r</td><td></td><td>读任务单: 查看任务单及其历史。</td></tr>
  @ <tr><td>s</td><td></td><td>设置: 修改 CVSTrac 设置。</td></tr>
  @ <tr><td>w</td><td></td><td>写任务单: 修改任务单。</td></tr>
  @ </table>
  @ </li>
  @
  @ <li><p>
  @ 如果存在一个名为 "<b>anonymous</b>" 的用户，则所有人都可以访问
  @ 该服务器而不需要登录。对 anonymous
  @ 匿名用户的权限许可对任何登录的用户都
  @ 适用。
  @ </p></li>
  @
  if( !strcmp(g.scm.zSCM,"cvs") ){
    @ <li><p>
    @ 您必须使用 CVS V1.11 或以上版本，以支持为仓库指定
    @ 用户的只读访问权限。
    @ 在更早版本的 CVS 中，所有拥有取出权限的
    @ 用户自动会获得提交权限。
    @ </p></li>
    @
    @ <li><p>
    @ 修改用户名和密码将同时修改 CVS 仓库中的 <b>CVSROOT/passwd</b>、
    @ <b>CVSROOT/readers</b> 和 <b>CVSROOT/writers</b> 文件，
    @ 前提是那些文件要有可写权限。
    @ 在 <b>CVSROOT/passwd</b> 中存在的而在 CVSTrac 中未知的用户名将保留。
    if( g.okSetup ){
      @ 可以使用
      @ <a href="setup_user">用户设置</a> 页面的 "导入 CVS 用户" 按钮
      @ 来导入 CVS 中的用户到 CVSTrac。
    }
    @ </p></li>
  }
  @ </ol>
  common_footer();
}

/*
** WEBPAGE: /useredit
*/
void user_edit(void){
  char **azResult;
  const char *zId, *zName, *zEMail, *zCap;
  char *oaa, *oas, *oar, *oaw, *oan, *oai, *oaj, *oao, *oap ;
  char *oak, *oad, *oaq;
  int doWrite;
  int higherUser = 0;  /* True if user being edited is SETUP and the */
                       /* user doing the editing is ADMIN.  Disallow editing */
#ifdef CVSTRAC_WINDOWS
  char *odl;           /* Domain login - used by "use Windows password" feature */
#endif

  /* Must have ADMIN privleges to access this page
  */
  login_check_credentials();
  if( !g.okAdmin ){ login_needed(); return; }

  /* Check to see if an ADMIN user is trying to edit a SETUP account.
  ** Don't allow that.
  */
  zId = P("id");
  if( zId && !g.okSetup ){
    char *zOldCaps;
    zOldCaps = db_short_query(
       "SELECT capabilities FROM user WHERE id='%q'",zId);
    higherUser = zOldCaps && strchr(zOldCaps,'s');
  }

  if( !higherUser ){
    if( P("delete") ){
      common_add_action_item("userlist", "取消");
      common_header("您确定要删除吗？");
      @ <form action="useredit" method="POST">
      @ <p>您将要从数据库中删除用户 <strong>%h(zId)</strong>。
      @ 这是一个不可恢复的操作！</p>
      @
      @ <input type="hidden" name="id" value="%t(zId)">
      @ <input type="hidden" name="nm" value="">
      @ <input type="hidden" name="em" value="">
      @ <input type="hidden" name="pw" value="">
      @ <input type="submit" name="delete2" value="删除该用户">
      @ <input type="submit" name="can" value="取消">
      @ </form>
      common_footer();
      return;
    }else if( P("can") ){
      cgi_redirect("userlist");
      return;
    }
  }

  /* If we have all the necessary information, write the new or
  ** modified user record.  After writing the user record, redirect
  ** to the page that displays a list of users.
  */
  doWrite = zId && zId[0] && cgi_all("nm","em","pw") && !higherUser;
  if( doWrite ){
    const char *zOldPw;
    char zCap[20];
    int i = 0;
#ifdef CVSTRAC_WINDOWS
    int dl = P("dl")!=0;
#endif
    int aa = P("aa")!=0;
    int ad = P("ad")!=0;
    int ai = P("ai")!=0;
    int aj = P("aj")!=0;
    int ak = P("ak")!=0;
    int an = P("an")!=0;
    int ao = P("ao")!=0;
    int ap = P("ap")!=0;
    int aq = P("aq")!=0;
    int ar = P("ar")!=0;
    int as = g.okSetup && P("as")!=0;
    int aw = P("aw")!=0;
    zOldPw = db_short_query("SELECT passwd FROM user WHERE id='%q'", zId);
    if( as ) aa = 1;
#ifdef CVSTRAC_WINDOWS
    /* If the admin is using external password auth
    ** don't let password change automatically
    */
    if( !dl && aa ) ai = aw = ap = 1;
    else
#endif
    if( aa ) ai = aw = 1;
    if( aw ) an = ar = 1;
    if( ai ) ao = 1;
    if( ak ) aj = 1;
    if( aa ){ zCap[i++] = 'a'; }
    if( ad ){ zCap[i++] = 'd'; }
    if( ai ){ zCap[i++] = 'i'; }
    if( aj ){ zCap[i++] = 'j'; }
    if( ak ){ zCap[i++] = 'k'; }
    if( an ){ zCap[i++] = 'n'; }
    if( ao ){ zCap[i++] = 'o'; }
    if( ap ){ zCap[i++] = 'p'; }
    if( aq ){ zCap[i++] = 'q'; }
    if( ar ){ zCap[i++] = 'r'; }
    if( as ){ zCap[i++] = 's'; }
    if( aw ){ zCap[i++] = 'w'; }

    zCap[i] = 0;
    db_execute("DELETE FROM user WHERE id='%q'", zId);
    if( !P("delete2") ){
      const char *zPw = P("pw");
      char zBuf[3];
      if( zOldPw==0 ){
        char zSeed[100];
        const char *z;
        bprintf(zSeed,sizeof(zSeed),"%d%.20s",getpid(),zId);
        z = crypt(zSeed, "aa");
        zBuf[0] = z[2];
        zBuf[1] = z[3];
        zBuf[2] = 0;
        zOldPw = zBuf;
      }
      db_execute(
         "INSERT INTO user(id,name,email,passwd,capabilities) "
         "VALUES('%q','%q','%q','%q','%s')",
         zId, P("nm"), P("em"), OS_VAL(0, dl) ? "*" : zPw[0] ? crypt(zPw, zOldPw) : zOldPw, zCap
      );
    }else{
      /* User was default assigned user id. Remove the default. */
      db_execute( "DELETE FROM config WHERE "
          "  name='assignto' AND value='%q'", zId);
    }

    /*
    ** The SCM subsystem may be able to replicate the user db somewhere...
    */
    if( g.scm.pxUserWrite ) g.scm.pxUserWrite(P("delete2")!=0 ? zId : 0);

    cgi_redirect("userlist");
    return;
  }

  /* Load the existing information about the user, if any
  */
  zName = "";
  zEMail = "";
  zCap = "";
  oaa = oad = oai = oaj = oak = oan = oao = oap = oaq = oar = oas = oaw = "";
#ifdef CVSTRAC_WINDOWS
  odl = "";
#endif
  if( zId ){
#ifdef CVSTRAC_WINDOWS
    /* "use Windows password" shall be checked when password is set to "*" */
    const char *zOldPw = db_short_query("SELECT passwd FROM user WHERE id='%q'", zId);
    if(zOldPw != 0 && zOldPw[0] == '*' && zOldPw[1] == 0) odl = " checked";
#endif
    azResult = db_query(
      "SELECT name, email, capabilities FROM user WHERE id='%q'", zId
    );
    if( azResult && azResult[0] ){
      zName = azResult[0];
      zEMail = azResult[1];
      zCap = azResult[2];
      if( strchr(zCap, 'a') ) oaa = " checked";
      if( strchr(zCap, 'd') ) oad = " checked";
      if( strchr(zCap, 'i') ) oai = " checked";
      if( strchr(zCap, 'j') ) oaj = " checked";
      if( strchr(zCap, 'k') ) oak = " checked";
      if( strchr(zCap, 'n') ) oan = " checked";
      if( strchr(zCap, 'o') ) oao = " checked";
      if( strchr(zCap, 'p') ) oap = " checked";
      if( strchr(zCap, 'q') ) oaq = " checked";
      if( strchr(zCap, 'r') ) oar = " checked";
      if( strchr(zCap, 's') ) oas = " checked";
      if( strchr(zCap, 'w') ) oaw = " checked";
    }else{
      zId = 0;
    }
  }

  /* Begin generating the page
  */
  common_standard_menu(0,0);
  common_add_help_item("CvstracAdminUsers");
  common_add_action_item("userlist", "取消");
  common_add_action_item(mprintf("useredit?delete=1&id=%t",zId), "删除");
  if( zId ){
    common_header("编辑用户 %s", zId);
  }else{
    common_header("增加新用户");
  }
  @ <form action="%s(g.zPath)" method="POST">
  @ <table align="left" style="margin: 10px;">
  @ <tr>
  @   <td align="right" class="nowrap">用户名:</td>
  if( zId ){
    @   <td>%h(zId) <input type="hidden" name="id" value="%h(zId)"></td>
  }else{
    @   <td><input type="text" name="id" size=10></td>
  }
  @ </tr>
  @ <tr>
  @   <td align="right" class="nowrap">全名:</td>
  @   <td><input type="text" name="nm" value="%h(zName)"></td>
  @ </tr>
  @ <tr>
  @   <td align="right" class="nowrap">邮件地址:</td>
  @   <td><input type="text" name="em" value="%h(zEMail)"></td>
  @ </tr>
  @ <tr>
  @   <td align="right" valign="top">用户权限:</td>
  @   <td>
  @     <input type="checkbox" name="aa" id="aa"%s(oaa)><label for="aa">管理</label><br>
  @     <input type="checkbox" name="ad" id="ad"%s(oad)><label for="ad">删除</label><br>
  @     <input type="checkbox" name="ai" id="ai"%s(oai)><label for="ai">提交</label><br>
  @     <input type="checkbox" name="aj" id="aj"%s(oaj)><label for="aj">读 Wiki</label><br>
  @     <input type="checkbox" name="ak" id="ak"%s(oak)><label for="ak">写 Wiki</label><br>
  @     <input type="checkbox" name="an" id="an"%s(oan)><label for="an">新任务单</label><br>
  @     <input type="checkbox" name="ao" id="ao"%s(oao)><label for="ao">取出</label><br>
  @     <input type="checkbox" name="ap" id="ap"%s(oap)><label for="ap">密码</label><br>
  @     <input type="checkbox" name="aq" id="aq"%s(oaq)><label for="aq">查询</label><br>
  @     <input type="checkbox" name="ar" id="ar"%s(oar)><label for="ar">读任务单</label><br>
  if( g.okSetup ){
    @     <input type="checkbox" name="as" id="as"%s(oas)><label for="as">设置</label><br>
  }
  @     <input type="checkbox" name="aw" id="aw"%s(oaw)><label for="aw">写任务单</label>
  @   </td>
  @ </tr>
  @ <tr>
  @   <td align="right">密码:</td>
  @   <td><input type="password" name="pw" value=""></td>
  @ </tr>
#ifdef CVSTRAC_WINDOWS
  @ <tr>
  @   <td></td>
  @   <td><input type="checkbox" name="dl" id="dl"%s(odl)><label for="dl">使用 Windows 密码</label><br></td>
  @ </tr>
#endif
  if( !higherUser ){
    @ <tr>
    @   <td>&nbsp;</td>
    @   <td><input type="submit" name="submit" value="应用修改">
    @       &nbsp;&nbsp;&nbsp;
    @       <input type="submit" name="delete" value="删除用户"></td>
    @ </tr>
  }
  @ </table>
  @ <table border="0"><tr><td>
  @ <p><b>说明:</b></p>
  @ <ol>
  if( higherUser ){
    @ <li><p>
    @ 用户 %h(zId) 拥有设置权限而您只有管理权限，
    @ 所以您不允许修改用户 %h(zId)。
    @ </p></li>
    @
  }
  if( g.scm.pxUserWrite!=0
        && !strcmp("yes",db_config("write_cvs_passwd","yes")) ){
    @ <li><p>
    @ 如果指定了 <b>CVS 取出</b> 权限，
    @ 则此处输入的密码
    @ 将写入到 <b>CVSROOT/passwd</b>
    @ 文件中并将成为该服务器上该用户
    @ 的 CVS 访问密码。
    @
    @ <li><p>
    @ <b>CVS 提交</b> 权限意味着用户名将写入到
    @ <b>CVSROOT/writers</b> 文件中并使得用户可以写
    @ CVS 仓库。
    @ </p></li>
    @
  }else{
    @ <li><p>
    @ 如果指定了 <b>取出</b> 权限，用户将能够浏览
    @ %s(g.scm.zName) 仓库。
    @ </p></li>
    @
    @ <li><p>
    @ <b>提交</b> 权限将允许用户编辑提交
    @ 信息。
    @ </p></li>
    @
  }
  @ <li><p>
  @ <b>读任务单</b> 和 <b>写任务单</b> 权限允许用户读写
  @ 任务单。<b>新建任务单</b> 权限意味着用户有能力
  @ 创建新的任务单。
  @ </p></li>
  @
  @ <li><p>
  @ <b>删除</b> 权限允许用户拥有删除由匿名用户
  @ 增加的 Wiki、任务单和附件。
  @ 这个功能用于垃圾清理。
  @ </p></li>
  @
  @ <li><p>
  @ <b>查询</b> 权限允许用户通过创建或编辑使用特定 SQL
  @ 语句的报表格式。用户可以运行已有的报表格式而不需要
  @ 查询权限。
  @ </p></li>
  @
  @ <li><p>
  @ 一个 <b>管理</b> 用户能够添加其它的用户、创建新的报表格式、
  @ 以及修改系统默认值。但是只有 <b>设置</b>
  @ 用户才能修改该程序连接到的
  @ %h(g.scm.zName) 仓库。
  @ </p></li>
  @
#ifdef CVSTRAC_WINDOWS
  @ <li><p>
  @ <b>使用 Windows 密码</b> 选项能够让 CVSTrac 的用户密码与 Windows
  @ 域 (计算机) 用户集成。
  @ <p>不过用户可被授予更改密码的权限，这样 CVSTrac 用户的密码可以改得和
  @ Windows 下的同名用户不同。
  @ </p></li>
  @
#endif
  if( zId==0 || strcmp(zId,"anonymous")==0 ){
    @ <li><p>
    @ 不需要登录的用户 "<b>anonymous</b>"。该用户的权限对所有
    @ 人适用，而不需要使用用户名和密码登录。
    @ 要禁用 anonymous 匿名访问，请确认系统中没有
    @ 名为 <b>anonymous</b> 的用户。
    @ </p></li>
    @
    @ <li><p>
    @ 指定给 "<b>anonymous</b>" 用户的密码用于
    @ %h(g.scm.zName) 匿名访问。推荐使用
    @ "anonymous" 来作为匿名访问密码。
    @ </p></li>
  }
  @ </ol>
  @ </td></tr></table>
  @ </form>
  common_footer();
}

/*
** Remove the newline from the end of a string.
*/
void remove_newline(char *z){
  while( *z && *z!='\n' && *z!='\r' ){ z++; }
  if( *z ){ *z = 0; }
}
