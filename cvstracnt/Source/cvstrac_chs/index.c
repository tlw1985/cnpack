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
** Code to generate the index page
*/
#include "config.h"
#include "index.h"

/*
** Return TRUE if the given string contains at least one non-space
** character
*/
static int not_blank(const char *z){
  while( isspace(*z) ){ z++; }
  return *z!=0;
}

/*
** WEBPAGE: /
** WEBPAGE: /index
** WEBPAGE: /index.html
** WEBPAGE: /mainmenu
*/
void index_page(void){
  int cnt = 0;
  login_check_credentials();
  common_standard_menu("index", 0);

  common_add_help_item("CvstracDocumentation");

  /* If the user has wiki read permission and a wiki page named HomePage
  ** exists and is not empty and is locked (meaning that only an
  ** administrator could have created it), then use that page as the
  ** main menu rather than the built-in main menu.
  **
  ** The built-in main menu is always reachable using the /mainmenu URL
  ** instead of "/index" or "/".
  */
  if( g.okRdWiki && g.zPath[0]!='m' ){
    char *zBody = db_short_query(
        "SELECT text FROM wiki WHERE name='HomePage' AND locked");
    if( zBody && not_blank(zBody) ){
      common_add_nav_item("mainmenu", "主菜单");
      common_header("首页");
      /* menu_sidebar(); */
      output_wiki(zBody, "", "HomePage");
      common_footer();
      return;
    }
  }

  /* Render the built-in main-menu page.
  */
  common_header("主菜单");
  @ <dl id="index">
  if( g.zPath[0]=='m' ){
    @ <dt>
    @ <a href="index"><b>首页</b></a>
    @ </dt>
    @ <dd>
    @ 查看该项目基于 Wiki 的首页。
    @ </dd>
    @
    cnt++;
  }
  if( g.okNewTkt ){
    @ <dt>
    @ <a href="tktnew"><b>任务单</b></a>
    @ </dt>
    @ <dd>
    @ 为错误报告或功能改进而创建一个新的任务单。
    @ </dd>
    @
    cnt++;
  }
  if( g.okCheckout ){
    @ <dt>
    @ <a href="%h(default_browse_url())"><b>浏览</b></a>
    @ </dt>
    @ <dd>
    @ 浏览 %s(g.scm.zName) 仓库树。
    @ </dd>
    @
    cnt++;
  }
  if( g.okRead ){
    @ <dt>
    @ <a href="reportlist"><b>报表</b></a>
    @ </dt>
    @ <dd>
    @ 查看关于任务单的摘要报表。
    @ </dd>
    @
    cnt++;
  }
  if( g.okRdWiki || g.okRead || g.okCheckout ){
    @ <dt>
    @ <a href="timeline"><b>时间线</b></a>
    @ </dt>
    @ <dd>
    @ 查看历次 CVS 提交及任务单更新记录。
    @ </dd>
    @ 
    cnt++;
  }
  if( g.okRdWiki ){
    @ <dt>
    @ <a href="wiki"><b>Wiki</b></a>
    @ </dt>
    @ <dd>
    @ 查看 Wiki 文档页面。
    @ </dd>
    cnt++;
  }
  if( g.okRead || g.okCheckout || g.okRdWiki ){
    const char *az[5];
    int n=0;
    if( g.okRead ) az[n++] = "任务单";
    if( g.okCheckout ) az[n++] = "提交记录";
    if( g.okRdWiki ) az[n++] = "Wiki 页面";
    if( g.okCheckout ) az[n++] = "文件名";
    @ <dt>
    @ <a href="search"><b>搜索</b></a>
    @ </dt>
    @ <dd>
    if( n==4 ){
      @ 通过关键字在 %s(az[0])、%s(az[1])、%s(az[2]) 及/或 %s(az[3]) 中进行搜索。
    }else if( n==3 ){
      @ 通过关键字在 %s(az[0])、%s(az[1]) 及/或 %s(az[2]) 中进行搜索。
    }else if( n==2 ){
      @ 通过关键字在 %s(az[0]) 及/或 %s(az[1]) 中进行搜索。
    }else{
      @ 通过关键字在 %s(az[0]) 中进行搜索。
    }
    @ </dd>
    @
    cnt++;
  }
  if( g.okCheckin ){
    @ <dt>
    @ <a href="msnew"><b>里程碑</b></a>
    @ </dt>
    @ <dd>
    @ 创建一个新的项目里程碑。
    @ </dd>
    @ 
    cnt++;
  }
  if( g.okWrite && !g.isAnon ){
    @ <dt>
    @ <a href="userlist"><b>用户</b></a>
    @ </dt>
    @ <dd>
    @ 新增、修改和删除用户。
    @ </dd>
    @ 
    cnt++;
  }
  if( g.okAdmin ){
    @ <dt>
    @ <a href="setup"><b>设置</b></a>
    @ </dt>
    @ <dd>
    @ 设置全局系统参数。
    @ </dd>
    @ 
    cnt++;
  }
  if( g.okRdWiki ){
    @ <dt>
    @ <a href="wiki?p=CvstracDocumentation"><b>文档</b></a>
    @ </dt>
    @ <dd>
    @ 阅读在线使用手册。
    @ </dd>
    @
    cnt++;
  }
  if( g.isAnon ){
    if( cnt==0 ){
      login_needed();
      return;
    }
    @ <dt>
    @ <a href="login"><b>登录</b></a>
    @ </dt>
    @ <dd>
    @ 登录系统。
    @ </dd>
    @ 
  }else{
    @ <dt>
    @ <a href="logout"><b>注销</b></a>
    @ </dt>
    @ <dd>
    @ 注销或修改密码。
    @ </dd>
    @ 
  }
  @ </dl>
  @ 
  common_footer();
}
