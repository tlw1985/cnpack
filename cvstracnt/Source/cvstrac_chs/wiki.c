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
** 简体中文翻译: beta (xbeta@163.net) 2003-11-10
**
*******************************************************************************
**
** This file contains code used to generated the Wiki pages
*/
#include <stdlib.h>
#include "config.h"
#include "wiki.h"
#include <time.h>

/*
** Adds all appropriate action bar links for external wiki tools
*/
static void add_wiki_tools(
  const char *zExcept,
  const char *zPage,
  time_t t1, time_t t2
){
  int i;
  char *zLink;
  char **azTools;
  db_add_functions();
  azTools = db_query("SELECT tool.name FROM tool,user "
                     "WHERE tool.object='wiki' AND user.id='%q' "
                     "      AND cap_and(tool.perms,user.capabilities)!=''",
                     g.zUser);

  for(i=0; azTools[i]; i++){
    if( zExcept && 0==strcmp(zExcept,azTools[i]) ) continue;

    if( t1 && t2 ){
      zLink = mprintf("wikitool?t=%T&p=%T&t1=%d&t2=%d",azTools[i],zPage,t1,t2);
    }else if( t1 ){
      zLink = mprintf("wikitool?t=%T&p=%T&t1=%d",azTools[i],zPage,t1);
    }else{
      zLink = mprintf("wikitool?t=%T&p=%T",azTools[i],zPage);
    }
    common_add_action_item(zLink, azTools[i]);
  }
}

/*
** WEBPAGE: /wikitool
**
** Execute an external tool on a given ticket
*/
void wikitool(void){
  const char *zPage = P("p");
  const char *zTool = P("t");
  time_t t1 = atoi(PD("t1","0"));
  time_t t2 = atoi(PD("t2","0"));
  char *zAction;
  const char *azSubst[32];
  int n = 0;
  char **azPage;
  char *zView;

  if( zPage==0 || zTool==0 ) cgi_redirect("index");

  login_check_credentials();
  if( !g.okRdWiki ){ login_needed(); return; }
  throttle(1,0);
  history_update(0);

  azPage = db_query(
    "SELECT text,invtime FROM wiki WHERE name='%q' AND invtime>=%d LIMIT 1",
    zPage, -(t1 ? t1 : time(0))
  );
  if( azPage[0]==0 ) {
    common_err("Wiki 页面 '%s' 没有返回任何内容", zPage);
  }

  if(P("t1")){
    zView = mprintf("wiki?p=%T&t=%d",zPage,t1);
  }else{
    zView = mprintf("wiki?p=%T",zPage);
  }

  zAction = db_short_query("SELECT command FROM tool WHERE name='%q'", zTool);
  if( zAction==0 || zAction[0]==0 ){
    cgi_redirect(zView);
  }

  common_standard_menu(0, "search?w=1");
  common_add_action_item(zView, "View");
  add_wiki_tools(zTool,zPage,t1,t2);

  common_header("%h: %h", zPage, zTool);

  azSubst[n++] = "W";
  azSubst[n++] = quotable_string(zPage);
  if( P("t1") ){
    azSubst[n++] = "T1";
    azSubst[n++] = mprintf("%d",t1);
  }
  if( P("t2") ){
    azSubst[n++] = "T2";
    azSubst[n++] = mprintf("%d",t2);
  }
  azSubst[n++] = 0;

  n = execute_tool(zTool,zAction,azPage[0],azSubst);
  free(zAction);
  if( n<=0 ){
    cgi_redirect(zView);
  }
  common_footer();
}

/*
** Expand a wiki page name by adding a single space before each
** capital letter after the first.  The returned string is written
** into space obtained from malloc().
*/
char *wiki_expand_name(const char *z){
  int i, n;
  char *zOut;
  for(n=i=0; z[i]; i++, n++){
    if( isupper(z[i]) ) n++;
  }
  zOut = malloc(n+1);
  if( zOut==0 ) return "<内存不足>";
  for(n=i=0; z[i]; i++, n++){
    if( n>0 && isupper(z[i]) ){ zOut[n++] = ' '; }
    zOut[n] = z[i];
  }
  zOut[n] = 0;
  return zOut;
}

/*
** Write a string in zText into a temporary file.  Write the name of
** the temporary file in zFile.  Return 0 on success and 1 if there is
** any kind of error.
*/
int write_to_temp(const char *zText, char *zFile, size_t nLen){
  FILE *f;
#ifndef CVSTRAC_WINDOWS
  int fd;
#endif
  char *zTmp = getenv("TMPDIR");        /* most Unices */
  if( zTmp==0 ) zTmp = getenv("TEMP");  /* Windows/Cygwin */
  if( zTmp==0 ) zTmp = "/tmp";

  bprintf(zFile,nLen,OS_VAL("%s/cvstrac_XXXXXX","%s\\cvstrac_XXXXXX"), zTmp);
#ifndef CVSTRAC_WINDOWS
  if( (fd=mkstemp(zFile))<0 || 0==(f = fdopen(fd, "w+")) ){
    if( fd>=0 ){
      unlink(zFile);
      close(fd);
    }
    zFile[0] = 0;
    return 1;
  }
#else
  /* mkstemp is not present on Windows */
  if( NULL==mktemp(zFile) || 0==(f = fopen(zFile, "w+")) ){
    zFile[0] = 0;
    return 1;
  }
#endif
  fwrite(zText, 1, strlen(zText), f);
  fprintf(f, "\n");
  fclose(f);
  return 0;
}

/*
** Output a <PRE> formatted diff of two strings.
*/
void diff_strings(int nContext,const char *zString1, const char *zString2){
  char zF1[200], zF2[200];

  zF1[0] = zF2[0] = 0;
  if( !write_to_temp(zString1, zF1,sizeof(zF1))
       && !write_to_temp(zString2, zF2,sizeof(zF2))
  ){
    char *zCmd;
    FILE *p;
    char zLine[2000];
    int cnt = 0;
    zCmd = mprintf(OS_VAL("diff -U %d -b '%s' '%s' 2>&1",
                          "diff -U %d -b \"%s\" \"%s\" 2>NUL"), nContext,
                   quotable_string(zF1), quotable_string(zF2));
    if( zCmd ){
      p = popen(zCmd, "r");

      if( p ){
        @ <pre class="diff">
        while( fgets(zLine, sizeof(zLine), p) ){
          cnt++;
          if( cnt>3 ) cgi_printf("%h", zLine);
        }
        @ </pre>
        pclose(p);
      }else{
        common_err("无法比较临时文件");
      }
      free(zCmd);
    }
  } else {
    common_err("无法创建临时文件");
  }
  if( zF1[0] ) unlink(zF1);
  if( zF2[0] ) unlink(zF2);
}

/*
** WEBPAGE: /wiki.txt
**
** View a text version of a wiki page.
**
** Query parameters are "p" and "t".  "p" is the name of the page to
** view.  If "p" is omitted, the "WikiIndex" page is shown.  "t" is
** the time (seconds since 1970) that determines which page to view.
** If omitted, the current time is substituted for "t".
*/
void wiki_text_page(void){
  const char *pg = P("p");
  const char *zTime = P("t");
  int tm;
  char **azPage;

  login_check_credentials();
  if( !g.okRdWiki ){ login_needed(); return; }
  throttle(0,0);
  if( zTime==0 || (tm = atoi(zTime))==0 ){
    time_t now;
    time(&now);
    tm = now;
  }
  if( pg==0 || is_wiki_name(pg)!=strlen(pg) ){
    pg = "WikiIndex";
  }
  azPage = db_query(
    "SELECT text,invtime FROM wiki WHERE name='%q' AND invtime>=%d LIMIT 1", pg, -tm
  );

  if( tm == -atoi(azPage[1]) ){
    /* Specific versions of wiki text never change... However, the match was
    ** maybe a bit fuzzy so we only do this stuff if there was a specific
    ** timestamp specified that actually matches the page timestamp.
    */
    cgi_modified_since(tm);
    cgi_append_header(mprintf("Last-Modified: %h\r\n",
                              cgi_rfc822_datestamp(tm)));
  }

  cgi_set_content_type("text/plain");
  cgi_append_content(azPage[0],strlen(azPage[0]));
}

/*
** Return TRUE if it is ok to delete the wiki page named Create by zUser
** at time tm.  Rules:
**
**    *  The Setup user can delete any wiki page at any time.
**
**    *  Users with Delete privilege can delete wiki created by anonymous
**       for up to 24 hours.
**
**    *  Registered users can delete their own wiki for up to 24 hours.
*/
static int ok_to_delete_wiki(int tm, const char *zUser){
  if( g.okSetup ){
    return 1;
  }
  if( g.okDelete && strcmp(zUser,"anonymous")==0 && tm>=time(0)-86400 ){
    return 1;
  }
  if( !g.isAnon && strcmp(zUser,g.zUser)==0 && tm>=time(0)-86400 ){
    return 1;
  }
  return 0;
}

/*
** Check to see if zId is a user id and a corresponding wiki "home page"
** exists.  For the purposes of this check, anonymous and setup aren't
** considered real users.
*/
int is_user_page(const char *zId){
  if( zId && strcmp(zId,"setup") && strcmp(zId,"anonymous") ){
    if( db_exists("SELECT 1 FROM user,wiki "
                  "WHERE user.id='%q' AND wiki.name=user.id", zId) ){
      return 1;
    }
  }
  return 0;
}

/*
** Check to see if the wiki page zPage is the logged in users home page. Note
** that a user must have wiki edit permissions in order for this to happen.
*/
int is_home_page(const char* zPage){
  return !g.isAnon && g.okWiki && zPage && 0==strcmp(zPage,g.zUser);
}

char *format_user(const char* zUser){
  if( zUser!=0 ){
    if( g.okRdWiki && is_user_page(zUser) ){
      return mprintf("<a class=\"user\" href=\"wiki?p=%t\">%h</a>",
                     zUser, zUser);
    }else{
      return mprintf("<span class=\"user\">%h</span>",zUser);
    }
  }
  return 0;
}

/*
** Output a user id
*/
void output_user(const char* zUser){
  char *z = format_user(zUser);
  if( z!=0 ){
    cgi_printf("%s",z);
    free(z);
  }
}

/*
** WEBPAGE: /wiki
**
** View a single page of wiki.
**
** Query parameters are "p" and "t".  "p" is the name of the page to
** view.  If "p" is omitted, the "WikiIndex" page is shown.  "t" is
** the time (seconds since 1970) that determines which page to view.
** If omitted, the current time is substituted for "t".
**
** A history of all versions of the page is displayed if the "t"
** parameter is present and is omitted if absent.
*/
void wiki_page(void){
  const char *pg = P("p");
  const char *zTime = P("t");
  char *zSearch = NULL;
  int doDiff = atoi(PD("diff","0"));
  int tm;
  int i;
  char **azPage;               /* Query result: page to display */
  char **azHist = 0;           /* Query result: history of the page */
  int isLocked;
  char *zTimeFmt;              /* Human readable translation of "t" parameter */
  char *zTruncTime = 0;
  char *zTruncTimeFmt = 0;
  int truncCnt = 0;
  int overload;
  int isHome = 0;
  int isUser = 0;
  int canEdit = 0;
  int canDelete = 0;

  login_check_credentials();
  if( !g.okRdWiki ){ login_needed(); return; }
  overload = throttle(0,0);
  if( overload ){
    zTime = 0;
    doDiff = 0;
  }
  db_add_functions();
  if( zTime==0 || (tm = atoi(zTime))==0 ){
    time_t now;
    time(&now);
    tm = now;
  }
  isHome = is_home_page(pg);
  isUser = isHome || is_user_page(pg);
  if( !isUser && (pg==0 || is_wiki_name(pg)!=strlen(pg)) ){
    pg = "WikiIndex";
  }
  azPage = db_query(
    "SELECT -invtime, locked, who, ipaddr, text "
    "FROM wiki WHERE name='%q' AND invtime>=%d LIMIT 2", pg, -tm
  );
  if( azPage[0]==0 || azPage[5]==0 ){ doDiff = 0; }
  if( zTime && !doDiff ){
    zTimeFmt = db_short_query("SELECT ldate(%d)",tm);
    azHist = db_query(
        "SELECT ldate(-invtime), who, -invtime FROM wiki "
        "WHERE name='%q'", pg
    );
  }

  isLocked = azPage[0] && atoi(azPage[1])!=0;

  if( zTime==0 && !overload ){
    if( g.okAdmin ){
      /* admin or up can always edit */
      canEdit = 1;
    }else if( isHome ){
      /* users can always edit their own "home page" */
      canEdit = 1;
    }else if( !isUser && g.okWiki && !isLocked ){
      /* anyone else with wiki edit can edit unlocked pages, unless they're
      ** some's home page.
      */
      canEdit = 1;
    }
  }

  if( azPage[0] ){
    if( isHome || g.okSetup ){
      canDelete = 1;
    }else if( !isUser && !isLocked
              && ok_to_delete_wiki(atoi(azPage[0]),azPage[2]) ){
      canDelete = 1;
    }
  }

  if( pg && strcmp(pg,"WikiIndex")!=0 ){
    common_standard_menu(0, "search?w=1");
  }else{
    common_standard_menu("wiki", "search?w=1");
  }
  common_add_help_item("CvstracWiki");
  common_add_action_item("wikitoc", "内容");
  if( canEdit ){
    common_add_action_item( mprintf("wikiedit?p=%t", pg), "编辑");
    if( attachment_max()>0 ){
      common_add_action_item( mprintf("attach_add?tn=%t",pg), "附件");
    }
  }
  if( zTime==0 && azPage[0] && azPage[5] && !overload ){
    common_add_action_item(mprintf("wiki?p=%t&t=%t", pg, azPage[0]), "历史");
  }
  if( !overload ){
    common_add_action_item(mprintf("wiki.txt?p=%t&t=%t", pg, azPage[0]),"文本");
  }
  if( doDiff ){
    common_add_action_item(mprintf("wiki?p=%t&t=%t",pg,azPage[0]), "无差异");
  }else if( azPage[0] && azPage[5] ){
    common_add_action_item(mprintf("wiki?p=%t&t=%t&diff=1",pg,azPage[0]),
                           "有差异");
  }
  if( canDelete ){
    const char *zLink;
    if( zTime==0 ){
      zLink = mprintf("wikidel?p=%t", pg);
    }else{
      zLink = mprintf("wikidel?p=%t&t=%d", pg, atoi(azPage[0]));
    }
    common_add_action_item( zLink, "删除");
  }
  if( azPage[0] ){
    add_wiki_tools(0,pg,atoi(azPage[0]),azPage[5]?atoi(azPage[5]):0);
  }

  zSearch = mprintf("search?s=%t&w=1", pg);
  common_link_header(zSearch,wiki_expand_name(pg));
  if( zTime && !doDiff ){
    @ <div id="history">
    @ <h3>页面历史</h3>
    @ <ul>
    for(i=0; azHist[i]; i+=3){
      if( azPage[0] && strcmp(azHist[i+2],azPage[0])==0 ){
        @ <li class="current">%h(azHist[i]) %h(azHist[i+1])</li>
        if( i>0 && g.okAdmin ){
          zTruncTime = azHist[i+2];
          zTruncTimeFmt = azHist[i];
          truncCnt = 1;
        }
      }else{
        @ <li><a href="wiki?p=%h(pg)&amp;t=%h(azHist[i+2])">
        @   %h(azHist[i]) %h(azHist[i+1])</a></li>
        if( zTruncTime ) truncCnt++;
      }
    }
    @ </ul>
    @ <p class="off"><a href="wiki?p=%h(pg)">关闭历史</a></p>
    @ </div>
  }
  if( doDiff ){
    diff_strings(3,azPage[9], azPage[4]);
  }else if( azPage[0] ){
    char *zLinkSuffix;
    zLinkSuffix = zTime ? mprintf("&amp;%h",zTime) : "";
    output_wiki(azPage[4], zLinkSuffix, pg);
    isLocked = atoi(azPage[1]);
    attachment_html(pg,
      "<h3>附件:</h3>\n<blockquote>",
      "</blockquote>"
    );
  }else{
    if( isHome ){
      @ <i>在主页上，您还没有创建任何内容...</i>
    }else if( !isUser ){
      @ <i>该页尚未创建...</i>
    }
    isLocked = 0;
  }
  common_footer();
}

/*
** WEBPAGE: /wikidiff
**
** Display the difference between two wiki pages
*/
void wiki_diff(void){
}

/*
** WEBPAGE: /wikiedit
**
** Edit a page of wiki.
*/
void wikiedit_page(void){
  const char *pg = P("p");
  const char *text = P("x");
  const char *reason = PD("r","");
  char **az;
  int isLocked;
  char *zErrMsg = 0;
  int isHome = 0;

  login_check_credentials();
  throttle(1,1);
  isHome = is_home_page(pg);
  if( !isHome && (pg==0 || is_wiki_name(pg)!=strlen(pg)) ){
    pg = "WikiIndex";
  }
  az = db_query(
    "SELECT invtime, locked, who, ipaddr, text "
    "FROM wiki WHERE name='%q' LIMIT 1", pg
  );
  isLocked = az[0] ? atoi(az[1]) : 0;
  if( !g.okAdmin && !isHome && (!g.okWiki || isLocked) ){
    cgi_redirect(mprintf("wiki?p=%t", pg));
  }
  if( g.okAdmin && az[0] && P("lock")!=0 ){
    isLocked = !isLocked;
    db_execute("UPDATE wiki SET locked=%d WHERE name='%q'", isLocked, pg);
    if( text && strcmp(remove_blank_lines(text),remove_blank_lines(az[4]))==0 ){
      cgi_redirect(mprintf("wiki?p=%t",pg));
      return;
    }
  }
  if( P("submit")!=0 && text!=0 ){
    time_t now = time(0);
    char *zOld = db_short_query("SELECT text FROM wiki "
                                "WHERE name='%q' AND invtime>=%d LIMIT 1",
                                pg, now);
    zErrMsg = is_edit_allowed(zOld,text);
    if( 0==zErrMsg ){
      const char *zIp = getenv("REMOTE_ADDR");
      if( zIp==0 ){ zIp = ""; }
      db_execute(
        "INSERT INTO wiki(name,invtime,locked,who,ipaddr,text,reason) "
        "VALUES('%q',%d,%d,'%q','%q','%q','%q')",
        pg, -(int)now, isLocked, g.zUser, zIp, remove_blank_lines(text),
        reason
      );
      cgi_redirect(mprintf("wiki?p=%t", pg));
      return;
    }
  }
  if( text==0 ) text = az[0] ? az[4] : "";
  text = remove_blank_lines(text);
  common_add_help_item("CvstracWiki");
  common_add_action_item( mprintf("wiki?p=%t",pg), "取消");
  common_header("编辑 Wiki %h", pg);

  @ <p><big><b>编辑: "%h(wiki_expand_name(pg))"</b></big></p>
  @ <form action="wikiedit" method="POST">
  @ <input type="hidden" name="p" value="%h(pg)">

  if( zErrMsg ){
    @ <blockquote class="error">
    @ %h(zErrMsg)
    @ </blockquote>
  }

  @ 请修改下面的文本内容。
  if( P("preview") ){
    @ 参见 <a href="wikihints">格式文本说明</a>.
  }else{
    @ 参见 <a href="#formatting">格式文本说明</a>.
  }
  @ <br>
  cgi_wikitext("x", 100, text);
  @ <br>

  /*
  ** Allow the editor to add a comment describing the change
  */
  cgi_text( "r", 0, 0, 0, 0, 70, 70, 1, reason, "注释");

  if( g.okAdmin ){
    if( isLocked ){
      @ <input type="submit" name="lock" value="解锁">
      @ 当前页面已被锁定，
      @ 只有管理员能进行编辑。<br>
    }else{
      @ <input type="submit" name="lock" value="锁定">
      @ 页面锁定已解除，任何人都可以编辑它。
    }
  }
  if( P("preview") ){
    @ <input type="submit" name="submit" value="提交修改并显示">
  }
  @ <input type="submit" name="preview" value="预览修改效果">
  @ </form>

  if( P("preview") ){
    @ <p>以下是该页面实际的显示效果:</p>
    @ <p><table border=2 cellpadding=5 width="100%%"><tr><td>
    output_wiki(text,"",pg);
    @ </td></tr></table></p><br>
  }

  attachment_html(pg,
    "<hr><h3>附件:</h3>\n<blockquote>",
    "</blockquote>"
  );
  if( !P("preview") ){
    @ <a name="formatting">
    @ <hr>
    @ <h3>格式文本说明</h3>
    append_formatting_hints();
  }
  common_footer(); 
}

/*
** WEBPAGE: /wikihints
**
** Show the "formatting hints" content on its own page.
*/
void wikihints_page(void){
  login_check_credentials();
  throttle(0,0);
  common_standard_menu("wiki", "search?w=1");
  common_add_help_item("FormattingWikiPages");
  common_header("Wiki 格式提示");
  append_formatting_hints();
  common_footer(); 
}

/*
** WEBPAGE: /wikitoc
**
** Show a wiki table of contents.
*/
void wikitoc_page(void){
  int i;
  char **az;
  const char *zOrderBy = "1";
  const char *zDesc = "";

  login_check_credentials();
  throttle(0,0);
  if( !g.okRdWiki ){ login_needed(); return; }
  if( P("ctime") ){
    zOrderBy = "min(-invtime)";
  }else if( P("mtime") ){
    zOrderBy = "max(-invtime)";
  }
  if( P("desc") ){
    zDesc = " DESC";
  }
  db_add_functions();
  az = db_query(
    "SELECT name, ldate(min(-invtime)), ldate(max(-invtime)) FROM wiki "
    "GROUP BY name ORDER BY %s%s", zOrderBy, zDesc
  );
  common_standard_menu("wiki", "search?w=1");
  common_add_help_item("CvstracWiki");
  common_header("Wiki 内容列表");
  @ <table id="wikitoc">
  @ <tr>
  @   <th><a href="%h(g.zPath)">页面名称</a></th>
  @   <th><a href="%h(g.zPath)?ctime=1&amp;desc=1">创建时间</a></th>
  @   <th><a href="%h(g.zPath)?mtime=1&amp;desc=1">最后修改</a></th>
  @ </tr>
  for(i=0; az[i]; i+=3){
    @ <tr>
    @   <td><a href="wiki?p=%h(az[i])">%h(az[i])</a></td>
    @   <td>%h(az[i+1])</td>
    @   <td>%h(az[i+2])</td>
    @ </tr>
  }
  @ </table>
  common_footer(); 
}

/*
** WEBPAGE: /wikidel
**
** The confirmation page for deleting a page of wiki.
*/
void wikidel_page(void){
  const char *pg = P("p");
  const char *zTime = P("t");
  char *zTimeFmt;
  const char *zIP = 0;
  int nBefore, nAfter, nSimilar;
  int tm = 0;
  int isLocked;
  int isHome = 0;
  int isUser = 0;

  login_check_credentials();
  db_add_functions();
  isUser = is_user_page(pg);
  isHome = is_home_page(pg);
  if( !isUser && (pg==0 || is_wiki_name(pg)!=strlen(pg)) ){
    login_needed();
    return;
  }
  if( zTime==0 || (tm = atoi(zTime))==0 ){
    zTime = db_short_query(
       "SELECT max(-invtime) FROM wiki WHERE name='%q'", pg);
    if( zTime==0 || (tm = atoi(zTime))==0 ){
      cgi_redirect("index");
    }
  }
  if( !g.okSetup && !isHome ){
    const char *zUser = db_short_query(
       "SELECT who FROM wiki WHERE name='%q' AND invtime=%d", pg, -tm);
    if( !ok_to_delete_wiki(tm, zUser) ){
      login_needed();
      return;
    }
  }
  zIP = db_short_query(
       "SELECT ipaddr FROM wiki WHERE name='%q' AND invtime=%d", pg, -tm);
  nBefore = atoi( db_short_query(
     "SELECT count(*) FROM wiki WHERE name='%q' AND invtime>%d", pg, -tm));
  nAfter = atoi( db_short_query(
     "SELECT count(*) FROM wiki WHERE name='%q' AND invtime<%d", pg, -tm));
  nSimilar = atoi( db_short_query(
     "SELECT count(*) FROM wiki WHERE invtime>=%d AND invtime<=%d "
               "AND ipaddr='%q'", -3600-tm, 3600-tm, zIP));

  zTimeFmt = db_short_query("SELECT ldate(%d)", tm);
  isLocked = atoi( db_short_query(
     "SELECT locked FROM wiki WHERE name='%q' LIMIT 1", pg));
  common_add_action_item(
     zTime ? mprintf("wiki?p=%t&t=%d", pg, tm) : mprintf("wiki?p=%t", pg),
     "取消"     
  );
  common_add_help_item("CvstracWiki");
  common_header("确认删除");
  @ <p><big><b>删除 Wiki 页面 "%h(wiki_expand_name(pg))"?</b></big></p>
  @ <p>删除后将不可恢复！请谨慎抉择！</p>
  @ <form action="wikidodel" method="POST">
  @ <input type="hidden" name="p" value="%h(pg)">
  if( P("t") ){
    @ <input type="hidden" name="t" value="%d(tm)">
  }
  @ <input type="hidden" name="t2" value="%d(tm)">
  @ <table border=0 cellpadding=5>
  @
  if( !isLocked && (isHome || g.okSetup || nBefore+nAfter==0) ){
    @ <tr><td align="right">
    if( nBefore==0 && nAfter==0 ){
      @ <input type="submit" name="all" value="确定">
    }else{
      @ <input type="submit" name="all" value="全部">
    }
    @ </td><td>
    @ 删除该页及其所有历史。
    @ </td></tr>
    @
  }
  if( nBefore>0 && nAfter>0 && (isHome || g.okSetup) ){
    @
    @ <tr><td align="right">
    @ <input type="submit" name="after" value="旧的">
    @ </td><td>
    @ 删除 %s(zTimeFmt) 以前的 %d(nBefore+1) 个历史版本，并保留 %d(nAfter) 个
    @ 最新的页面版本。
    @ </td></tr>
  }
  if( nBefore+nAfter>0 ){
    @
    @ <tr><td align="right">
    @ <input type="submit" name="one" value="一个">
    @ </td><td>
    @ 删除 %s(zTimeFmt) 的单个页面，
    @ 并保留 %d(nBefore+nAfter) 个历史页面。
    @ </td></tr>
  }
  if( zIP && zIP[0] && nSimilar>1 ){
    @
    @ <tr><td align="right">
    @ <input type="submit" name="similar" value="类似">
    @ <input type="hidden" name="ip" value="%s(zIP)">
    @ </td><td>
    @ 删除来自 IP 地址 (%s(zIP))，在 %s(zTimeFmt) 起
    @ 一小时内提交的对该页面和其它页面的
    @ %d(nSimilar) 处修改。
    @ </td></tr>
  }
  @
  @ <tr><td align="right">
  @ <input type="submit" name="cancel" value="取消">
  @ </td><td>
  @ 不删除任何页面。
  @ </td></tr>
  @ </table>  
  @ </form>
  common_footer();
}

/*
** WEBPAGE: /wikidodel
**
** Do the actual work of deleting a page.  Nothing is displayed.
** After the delete is accomplished, we redirect to a different page.
*/
void wikidodel_page(void){
  const char *pg = P("p");
  const char *t = P("t");
  const char *t2 = P("t2");
  char *zLast;
  const char *zRestrict;
  int isHome = 0;
  int isUser = 0;

  login_check_credentials();
  isHome = is_home_page(pg);
  isUser = is_user_page(pg);
  if( t2==0 || (!isUser && (pg==0 || is_wiki_name(pg)!=strlen(pg))) ){
    login_needed();
    return;
  }
  if( P("cancel") ){
    if( t==0 ){
      cgi_redirect(mprintf("wiki?p=%t",pg));
    }else{
      cgi_redirect(mprintf("wiki?p=%t&t=%t",pg,t));
    }
    return;
  }
  db_add_functions();
  if( isHome || g.okSetup ){
    /* The Setup user can delete anything. A user can always delete their
    ** home page.
    */
    zRestrict = "";
  }else if( g.okDelete ){
    /* Make sure users with Delete privilege but without Setup privilege
    ** can only delete wiki added by anonymous within the past 24 hours.
    */
    zRestrict = " AND (who='anonymous' OR who=user()) AND invtime<86400-now()";
  }else if( g.isAnon ){
    /* Anonymous user without Delete privilege cannot delete anything */
    login_needed();
    return;
  }else{
    /* What is left is registered users without Delete privilege.  They
    ** can delete the things that they themselves have added within 24
    ** hours. */
    zRestrict = " AND who=user() AND invtime<=86400-now()";
  }
  if( P("all") ){
    db_execute(
      "BEGIN;"
      "DELETE FROM wiki WHERE name='%q'%s;"
      "DELETE FROM attachment WHERE tn='%q' AND "
          "(SELECT count(*) FROM wiki WHERE name='%q')==0;"
      "COMMIT",
      pg, zRestrict, pg, pg
    );
    cgi_redirect("wiki?p=WikiIndex");
    return;
  }
  if( P("similar") ){
    db_execute("DELETE FROM wiki WHERE invtime>=%d AND invtime<=%d "
               "AND ipaddr='%q'%s",
              -3600-atoi(t2), 3600-atoi(t2), P("ip"), zRestrict);
  }else if( P("one") ){
    db_execute("DELETE FROM wiki WHERE name='%q' AND invtime=%d%s",
                pg, -atoi(t2), zRestrict);
  }else if( P("after") && (isHome || g.okSetup) ){
    db_execute("DELETE FROM wiki WHERE name='%q' AND invtime>=%d",pg,-atoi(t2));
  }
  zLast = db_short_query("SELECT max(-invtime) FROM wiki WHERE name='%q'",pg);
  if( zLast ){
    cgi_redirect(mprintf("wiki?p=%t&t=%t",pg,zLast));
  }else{
    cgi_redirect(mprintf("wiki?p=%t",pg));
  }
}
