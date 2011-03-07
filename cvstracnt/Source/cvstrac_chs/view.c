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
** Code to generate the bug report listings
*/
#include "config.h"
#include "view.h"

/* Forward references to static routines */
static void report_format_hints(void);

/*
** WEBPAGE: /reportlist
*/
void view_list(void){
  char **az;
  int i;

  login_check_credentials();
  if( !g.okRead ){ login_needed(); return; }
  throttle(1,0);
  common_standard_menu("reportlist", "search?t=1");
  if( g.okQuery ){
    common_add_action_item("rptnew", "新建报表格式");
  }
  common_add_help_item("CvstracReport");
  common_header("现有报表格式");
  az = db_query("SELECT rn, title, owner, description "
                "FROM reportfmt ORDER BY title");
  @ <p>请从下表中选择一个报表格式:</p>
  @ <ol>
  for(i=0; az[i]; i+=4){
    @ <li><a href="rptview?rn=%t(az[i])"
    @        rel="nofollow">%h(az[i+1])</a>&nbsp;&nbsp;&nbsp;
    if( g.okWrite && az[i+2] && az[i+2][0] ){
      @ (by <i>%h(az[i+2])</i>)
    }
    if( g.okQuery ){
      @ [<a href="rptedit?rn=%t(az[i])&amp;copy=1" rel="nofollow">复制</a>]
    }
    if( g.okAdmin || (g.okQuery && strcmp(g.zUser,az[i+2])==0) ){
      @ [<a href="rptedit?rn=%t(az[i])" rel="nofollow">编辑</a>]
    }
    @ [<a href="rptsql?rn=%t(az[i])" rel="nofollow">SQL</a>]
    if( az[i+3] && az[i+3][0] ){
      @ <div class="shortcomment">
      if( output_trim_message(az[i+3], MN_CKIN_MSG, MX_CKIN_MSG) ){
        output_formatted(az[i+3], 0);
        @ &nbsp;[...]
      }else{
        output_formatted(az[i+3], 0);
      }
      @ </div>
    }
    @ </li>
  }
  if( g.okQuery ){
    @ <li><a href="rptnew">新建报表格式</a></li>
  }
  @ </ol>
  common_footer();
}

/*
** Remove whitespace from both ends of a string.
*/
char *trim_string(const char *zOrig){
  int i;
  while( isspace(*zOrig) ){ zOrig++; }
  i = strlen(zOrig);
  while( i>0 && isspace(zOrig[i-1]) ){ i--; }
  return mprintf("%.*s", i, zOrig);
}

/*
** Extract a numeric (integer) value from a string.
*/
char *extract_integer(const char *zOrig){
  if( zOrig == NULL || zOrig[0] == 0 ) return "";
  while( *zOrig && !isdigit(*zOrig) ){ zOrig++; }
  if( *zOrig ){
    /* we have a digit. atoi() will get as much of the number as it
    ** can. We'll run it through mprintf() to get a string. Not
    ** an efficient way to do it, but effective.
    */
    return mprintf("%d", atoi(zOrig));
  }
  return "";
}

/*
** Remove blank lines from the beginning of a string and
** all whitespace from the end. Removes whitespace preceeding a NL,
** which also converts any CRNL sequence into a single NL.
*/
char *remove_blank_lines(const char *zOrig){
  int i, j, n;
  char *z;
  for(i=j=0; isspace(zOrig[i]); i++){ if( zOrig[i]=='\n' ) j = i+1; }
  n = strlen(&zOrig[j]);
  while( n>0 && isspace(zOrig[j+n-1]) ){ n--; }
  z = mprintf("%.*s", n, &zOrig[j]);
  for(i=j=0; z[i]; i++){
    if( z[i+1]=='\n' && z[i]!='\n' && isspace(z[i]) ){
      z[j] = z[i];
      while(isspace(z[j]) && z[j] != '\n' ){ j--; }
      j++;
      continue;
    }

    z[j++] = z[i];
  }
  z[j] = 0;
  return z;
}

/*********************************************************************/
/*
** wiki_key(), tkt_key() and chng_key() generate what should be unique
** wrappers around field values which indicate the desired formatting of
** the field. output_report_field() takes care of the formatting when
** it detects a specific wrapper. The wrapper should not be something
** which ever occurs in user-content. Right now, the wrapper is just some
** random junk with a keyword, but if there's collisions we can tweak it,
** maybe to something more dependent on the field contents?
*/

static const char* wiki_key(){
  static char key[64];
  if( key[0]==0 ){
    bprintf(key,sizeof(key),"wiki_%d:",rand());
  }
  return key;
}

static const char* tkt_key(){
  static char key[64];
  if( key[0]==0 ){
    bprintf(key,sizeof(key),"tkt_%d:",rand());
  }
  return key;
}

static const char* chng_key(){
  static char key[64];
  if( key[0]==0 ){
    bprintf(key,sizeof(key),"chng_%d:",rand());
  }
  return key;
}

static void f_wiki(sqlite3_context *context, int argc, sqlite3_value **argv){
  char *zText;
  if( argc!=1 ) return;
  zText = (char*)sqlite3_value_text(argv[0]);
  if(zText==0) return;
  zText = mprintf("%s%s",wiki_key(),zText);
  sqlite3_result_text(context, zText, -1, SQLITE_TRANSIENT);
  free(zText);
}

static void f_tkt(sqlite3_context *context, int argc, sqlite3_value **argv){
  char *zText;
  int tn;
  if( argc!=1 ) return;
  tn = sqlite3_value_int(argv[0]);
  zText = mprintf("%s%d",tkt_key(),tn);
  sqlite3_result_text(context, zText, -1, SQLITE_TRANSIENT);
  free(zText);
}

static void f_chng(sqlite3_context *context, int argc, sqlite3_value **argv){
  char *zText;
  int cn;
  if( argc!=1 ) return;
  cn = sqlite3_value_int(argv[0]);
  zText = mprintf("%s%d",chng_key(),cn);
  sqlite3_result_text(context, zText, -1, SQLITE_TRANSIENT);
  free(zText);
}

static void f_dummy(sqlite3_context *context, int argc, sqlite3_value **argv){
  char *zText;
  if( argc!=1 ) return;
  zText = (char*)sqlite3_value_text(argv[0]);
  if( zText!= 0 ){
    sqlite3_result_text(context, zText, -1, SQLITE_TRANSIENT);
  }
}

static void view_add_functions(int tabs){
  sqlite3 *db = db_open();
  if( tabs ){
    /* non-HTML output, just turn these functions into pass-throughs */
    sqlite3_create_function(db, "wiki", 1, SQLITE_ANY, 0, &f_dummy, 0, 0);
    sqlite3_create_function(db, "tkt", 1, SQLITE_ANY, 0, &f_dummy, 0, 0);
    sqlite3_create_function(db, "chng", 1, SQLITE_ANY, 0, &f_dummy, 0, 0);
  }else{
    sqlite3_create_function(db, "wiki", 1, SQLITE_ANY, 0, &f_wiki, 0, 0);
    sqlite3_create_function(db, "tkt", 1, SQLITE_ANY, 0, &f_tkt, 0, 0);
    sqlite3_create_function(db, "chng", 1, SQLITE_ANY, 0, &f_chng, 0, 0);
  }
}

/*********************************************************************/
/*
** Check the given SQL to see if is a valid query that does not
** attempt to do anything dangerous.  Return 0 on success and a
** pointer to an error message string (obtained from malloc) if
** there is a problem.
*/
char *verify_sql_statement(char *zSql){
  int i;

  /* First make sure the SQL is a single query command by verifying that
  ** the first token is "SELECT" and that there are no unquoted semicolons.
  */
  for(i=0; isspace(zSql[i]); i++){}
  if( strncasecmp(&zSql[i],"select",6)!=0 ){
    return mprintf("SQL 必须是一个 SELECT 语句");
  }
  for(i=0; zSql[i]; i++){
    if( zSql[i]==';' ){
      int bad;
      int c = zSql[i+1];
      zSql[i+1] = 0;
      bad = sqlite3_complete(zSql);
      zSql[i+1] = c;
      if( bad ){
        /* A complete statement basically means that an unquoted semi-colon
        ** was found. We don't actually check what's after that.
        */
        return mprintf("检测到分号！"
                       "只允许单条 SQL 语句");
      }
    }
  }
  return 0;
}

/*
** WEBPAGE: /rptsql
*/
void view_see_sql(void){
  int rn;
  char *zTitle;
  char *zSQL;
  char *zOwner;
  char *zClrKey;
  char **az;

  login_check_credentials();
  if( !g.okRead ){
    login_needed();
    return;
  }
  throttle(1,0);
  rn = atoi(PD("rn","0"));
  az = db_query("SELECT title, sqlcode, owner, cols "
                "FROM reportfmt WHERE rn=%d",rn);
  common_standard_menu(0, 0);
  common_add_help_item("CvstracReport");
  common_add_action_item( mprintf("rptview?rn=%d",rn), "查看");
  common_header("报表格式编号 %d 的 SQL 语句", rn);
  if( az[0]==0 ){
    @ <p>未知报表格式编号: %d(rn)</p>
    common_footer();
    return;
  }
  zTitle = az[0];
  zSQL = az[1];
  zOwner = az[2];
  zClrKey = az[3];
  @ <table cellpadding=0 cellspacing=0 border=0>
  @ <tr><td valign="top" align="right">标题:</td><td width=15></td>
  @ <td colspan=3>%h(zTitle)</td></tr>
  @ <tr><td valign="top" align="right">所有者:</td><td></td>
  @ <td colspan=3>%h(zOwner)</td></tr>
  @ <tr><td valign="top" align="right">SQL 语句:</td><td></td>
  @ <td valign="top"><pre>
  @ %h(zSQL)
  @ </pre></td>
  @ <td width=15></td><td valign="top">
  output_color_key(zClrKey, 0, "border=0 cellspacing=0 cellpadding=3");
  @ </td>
  @ </tr></table>
  report_format_hints();
  common_footer();
}

/*
** WEBPAGE: /rptnew
** WEBPAGE: /rptedit
*/
void view_edit(void){
  int rn;
  const char *zTitle;
  const char *z;
  const char *zOwner;
  char *zClrKey;
  char *zSQL;
  char *zDesc;
  char *zErr = 0;

  login_check_credentials();
  if( !g.okQuery ){
    login_needed();
    return;
  }
  throttle(1,1);
  db_add_functions();
  view_add_functions(0);
  rn = atoi(PD("rn","0"));
  zTitle = P("t");
  zOwner = PD("w",g.zUser);
  z = P("s");
  zSQL = z ? trim_string(z) : 0;
  zClrKey = trim_string(PD("k",""));
  zDesc = PD("d","");
  if( rn>0 && P("del2") ){
    db_execute("DELETE FROM reportfmt WHERE rn=%d", rn);
    cgi_redirect("reportlist");
    return;
  }else if( rn>0 && P("del1") ){
    zTitle = db_short_query("SELECT title FROM reportfmt "
                            "WHERE rn=%d", rn);
    if( zTitle==0 ) cgi_redirect("reportlist");

    common_add_action_item(mprintf("rptview?rn=%d",rn), "取消");
    common_header("确认删除？");
    @ <form action="rptedit" method="POST">
    @ <p>您正在从数据库中删除报表
    @ <strong>%h(zTitle)</strong>
    @ 的所有记录。这是一个不可撤消的操作，所有与这个报表相关的记录
    @ 都将移除并且不能被恢复。</p>
    @
    @ <input type="hidden" name="rn" value="%d(rn)">
    @ <input type="submit" name="del2" value="删除报表">
    @ <input type="submit" name="can" value="取消">
    @ </form>
    common_footer();
    return;
  }else if( P("can") ){
    /* user cancelled */
    cgi_redirect("reportlist");
    return;
  }
  if( zTitle && zSQL ){
    if( zSQL[0]==0 ){
      zErr = "请输入 SQL 查询语句";
    }else if( (zTitle = trim_string(zTitle))[0]==0 ){
      zErr = "请输入标题"; 
    }else if( (zErr = verify_sql_statement(zSQL))!=0 ){
      /* empty... zErr non-zero */
    }else{
      /* check query syntax by actually trying the query */
      db_restrict_access(1);
      zErr = db_query_check("%s", zSQL);
      if( zErr ) zErr = mprintf("%s",zErr);
      db_restrict_access(0);
    }
    if( zErr==0 ){
      if( rn>0 ){
        db_execute("UPDATE reportfmt SET title='%q', sqlcode='%q',"
                   " owner='%q', cols='%q', description='%q' WHERE rn=%d",
           zTitle, zSQL, zOwner, zClrKey, zDesc, rn);
      }else{
        db_execute("INSERT INTO "
                   "reportfmt(title,sqlcode,owner,cols,description) "
                   "VALUES('%q','%q','%q','%q','%q')",
                     zTitle, zSQL, zOwner, zClrKey, zDesc);
        z = db_short_query("SELECT max(rn) FROM reportfmt");
        rn = atoi(z);
      }
      cgi_redirect(mprintf("rptview?rn=%d", rn));
      return;
    }
  }else if( rn==0 ){
    zTitle = "";
    zSQL =
      @ SELECT
      @   CASE WHEN status IN ('新建','活动') THEN '#f2dcdc'
      @        WHEN status='检查' THEN '#e8e8bd'
      @        WHEN status='修正' THEN '#cfe8bd'
      @        WHEN status='测试' THEN '#bde5d6'
      @        WHEN status='推迟' THEN '#cacae5'
      @        ELSE '#c8c8c8' END as 'bgcolor',
      @   tn AS '#',
      @   type AS '类型',
      @   status AS '状态',
      @   sdate(origtime) AS '创建时间',
      @   owner AS '创建人',
      @   subsystem AS '子系统',
      @   sdate(changetime) AS '更新时间',
      @   assignedto AS '分配给',
      @   severity AS '严重',
      @   priority AS '优先',
      @   title AS '标题'
      @ FROM ticket
    ;
    zClrKey =
      @ #ffffff 图例:
      @ #f2dcdc 活动
      @ #e8e8e8 检查
      @ #cfe8bd 修正
      @ #bde5d6 测试
      @ #cacae5 推迟
      @ #c8c8c8 完成
    ;
  }else{
    char **az = db_query("SELECT title, sqlcode, owner, cols, description "
                         "FROM reportfmt WHERE rn=%d",rn);
    if( az[0] ){
      zTitle = az[0];
      zSQL = az[1];
      zOwner = az[2];
      zClrKey = az[3];
      zDesc = az[4];
    }
    if( P("copy") ){
      rn = 0;
      zTitle = mprintf("复件 %s", zTitle);
      zOwner = g.zUser;
    }
  }
  if( zOwner==0 ) zOwner = g.zUser;
  common_add_action_item("reportlist", "取消");
  if( rn>0 ){
    common_add_action_item( mprintf("rptedit?rn=%d&del1=1",rn), "删除");
  }
  common_add_help_item("CvstracReport");
  common_header(rn>0 ? "编辑报表格式":"创建新报表格式");
  if( zErr ){
    @ <blockquote class="error">%h(zErr)</blockquote>
  }
  @ <form action="rptedit" method="POST">
  @ <input type="hidden" name="rn" value="%d(rn)">
  @ <p>报表标题:<br>
  @ <input type="text" name="t" value="%h(zTitle)" size="60"></p>
  @ <p>请为 "任务单" 表格输入完整的 SQL 语句:<br>
  cgi_textarea("s","sql",20,70,zSQL);
  @ </p>
  if( g.okAdmin ){
    char **azUsers;
    azUsers = db_query("SELECT id FROM user UNION SELECT '' ORDER BY id");
    @ <p>报表所有者:
    cgi_v_optionmenu(0, "w", zOwner, (const char**)azUsers);
    @ </p>
  } else {
    @ <input type="hidden" name="w" value="%h(zOwner)">
  }
  @ <p>请在下面输入可选的颜色图例。
  @（如果为空，则不显示任何颜色图例）
  @ 每一行包含图例的一个单独的条目。
  @ 每行的第一个部分即为其颜色。<br>
  cgi_textarea("k","colorkey",6,50,zClrKey);
  @ </p>
  if( !g.okAdmin && strcmp(zOwner,g.zUser)!=0 ){
    @ <p>本报表格式的所有者是 %h(zOwner)，
    @ 您不允许修改。</p>
    @ </form>
    report_format_hints();
    common_footer();
    return;
  }
  @ <p>请输入描述:
  @ (<small>参见 <a href="wikihints">格式文本说明</a></small>)<br>
  cgi_wikitext("d",40,zDesc);
  @ </p>
  @ <input type="submit" value="确认修改">
  if( rn>0 ){
    @ <input type="submit" value="删除该报表格式" name="del1">
  }
  @ </form>
  report_format_hints();
  common_footer();
}

/*
** Output a bunch of text that provides information about report
** formats
*/
static void report_format_hints(void){
  @ <hr><h3>任务单 规则</h3>
  @ <blockquote><pre>
  @ CREATE TABLE ticket(
  @    tn integer primary key,  -- 任务单的唯一标识号
  @    type text,               -- 错误修正、功能改进、新项开发等
  @    status text,             -- 新建、检查、推迟、活动、修正、
  @                             -- 测试 或 完成
  @    origtime int,            -- 任务单创建时间
  @    changetime int,          -- 任务单最后修改时间
  @    derivedfrom int,         -- 该任务单源自另一个任务单
  @    version text,            -- 版本号或 Build 号
  @    assignedto text,         -- 谁应该完成该任务
  @    severity int,            -- 错误程度
  @    priority text,           -- 优先级
  @    subsystem text,          -- 任务单相关的子系统
  @    owner text,              -- 谁创建了该任务单
  @    title text,              -- 任务单标题
  @    description text,        -- 描述信息
  @    remarks text             -- 备注
  @ );
  @ </pre></blockquote>
  @ <h3>提示</h3>
  @ <ul>
  @ <li><p>该 SQL 只能包含单条 SELECT 语句。</p></li>
  @
  @ <li><p>如果结果集的一个列以 "#" 命名，
  @ 则假定其为任务单编号。系统将自动根据
  @ 该列来创建一个超级链接，以显示该任务单的详细信息。</p></li>
  @
  @ <li><p>如果结果集的一个列以 "bgcolor" 命名，则该列的值（颜色）将决定这一
  @ 一行的显示背景色。</p></li>
  @
  @ <li><p>“任务单”表中的时间是从 1970 年到该时间的秒数。
  @ 要转化这些时间为可读的日期格式，可使用
  @ <b>sdate()</b> 和 <b>ldate()</b> SQL 函数。</p></li>
  @ 
  @ <li><p><b>now()</b> 这个 SQL 函数将返回从 1970 年到现在的秒数；
  @ 而 SQL 函数 <b>user()</b>
  @ 则返回当前登陆的用户名字符串。</p></li>
  @
  @ <li><p>从第一个以下划线开头命名的列开始，
  @ 后面的列都将按照顺序显示在表格
  @ 中，这对于显示任务单的描述信息和备注字段非常有用。
  @ </p></li>
  @
  @ <li><p><b>aux()</b> SQL 函数接收一个名称作为参数，
  @ 并且以用户在 HTML 表单中输入的该参数的值作为返回值。
  @ 可选的第二个参数可为该字段提供一个默认值。</p></li>
  @
  @ <li><p><b>option()</b> SQL 函数接收一个名称和
  @ 一个使用单引号包含的 SELECT 语句作为参数。SELECT
  @ 的结果提供给 HTML 页面生成一个下拉列表，该函数返回
  @ 当前选择的值。返回值可能是单列或者是包含
  @ <b>值，描述</b> 的两列，第一列为默认列。</p></li>
  @
  @ <li><p><b>cgi()</b> SQL 函数接收一个名称作为参数，
  @ 并且返回相应的 CGI 查询值。如果 CGI
  @ 参数不存在，一个可选的第二参数将作为代替的
  @ 返回结果。</p></li>
  @
  @ <li><p>如果一个字段使用 <b>wiki()</b> SQL 函数封装，它将作为
  @ wiki 来格式化其内容。</p></li>
  @
  @ <li><p>如果一个字段使用 <b>tkt()</b> SQL 函数封装，它将作为
  @ 一个任务单编号显示，并链接到相应的页面。</p></li>
  @
  @ <li><p>如果一个字段使用 <b>chng()</b> SQL 函数封装，它将作为
  @ 一个提交编号显示，并链接到相应的页面。</p></li>
  @
  @ <li><p><b>path()</b> SQL 函数可用来从 FILE 表中取得完整的
  @ 文件名。例如:
  @ <pre>SELECT path(isdir, dir, base) AS 'filename' FROM file</pre>
  @ </p></li>
  @
  @ <li><p><b>dirname()</b> SQL 函数接收一个文件名参数，
  @ 并且返回该文件名中的父目录名。</p></li>
  @
  @ <li><p><b>basename()</b> SQL 函数接收一个文件名参数，
  @ 并且返回该文件名中的基本文件名。</p></li>
  @
  @ <li><p><b>search()</b> SQL 函数接收一个搜索文本的匹配项参数，
  @ 该函数返回一个匹配分值，该分值的大小依赖于文本搜索匹配
  @ 的程度。</p></li>
  @
  @ <li><p>该查询语句可以联接（join）除“任务单”表以外的任何表。
  @ </p></li>
  @ </ul>
  @
  @ <h3>示例</h3>
  @ <p>在本例中，结果集的第一列是以 "bgcolor" 命名的。
  @ 该列的值不会被显示，相应
  @ 的，它将根据“任务单（TICKET）”表中的“状态（STATUS）”
  @ 字段决定该行的背景色。
  @ 右边的颜色图例将显示不同的颜色代码。</p>
  @ <table align="right" style="margin: 0 5px;" border=1 cellspacing=0 width=125>
  @ <tr bgcolor="#f2dcdc"><td align="center">新建 或 活动</td></tr>
  @ <tr bgcolor="#e8e8bd"><td align="center">检查</td></tr>
  @ <tr bgcolor="#cfe8bd"><td align="center">修正</td></tr>
  @ <tr bgcolor="#bde5d6"><td align="center">测试</td></tr>
  @ <tr bgcolor="#cacae5"><td align="center">推迟</td></tr>
  @ <tr bgcolor="#c8c8c8"><td align="center">完成</td></tr>
  @ </table>
  @ <blockquote><pre>
  @ SELECT
  @   CASE WHEN status IN ('新建','活动') THEN '#f2dcdc'
  @        WHEN status='检查' THEN '#e8e8bd'
  @        WHEN status='修正' THEN '#cfe8bd'
  @        WHEN status='测试' THEN '#bde5d6'
  @        WHEN status='推迟' THEN '#cacae5'
  @        ELSE '#c8c8c8' END as 'bgcolor',
  @   tn AS '#',
  @   type AS '类型',
  @   status AS '状态',
  @   sdate(origtime) AS '创建时间',
  @   owner AS '创建人',
  @   subsystem AS '子系统',
  @   sdate(changetime) AS '更新时间',
  @   assignedto AS '分配给',
  @   severity AS '严重',
  @   priority AS '优先',
  @   title AS '标题'
  @ FROM ticket
  @ </pre></blockquote>
  @ <p>如果要以“任务单（TICKET）”表中的“优先级（PRIORITY）”或
  @ “错误程度（SEVERITY）”
  @ 字段来决定背景色，只需替换查询语句的第一列:</p>
  @ <table align="right" style="margin: 0 5px;" border=1 cellspacing=0 width=125>
  @ <tr bgcolor="#f2dcdc"><td align="center">1</td></tr>
  @ <tr bgcolor="#e8e8bd"><td align="center">2</td></tr>
  @ <tr bgcolor="#cfe8bd"><td align="center">3</td></tr>
  @ <tr bgcolor="#cacae5"><td align="center">4</td></tr>
  @ <tr bgcolor="#c8c8c8"><td align="center">5</td></tr>
  @ </table>
  @ <blockquote><pre>
  @ SELECT
  @   CASE priority WHEN 1 THEN '#f2dcdc'
  @        WHEN 2 THEN '#e8e8bd'
  @        WHEN 3 THEN '#cfe8bd'
  @        WHEN 4 THEN '#cacae5'
  @        ELSE '#c8c8c8' END as 'bgcolor',
  @ ...
  @ FROM ticket
  @ </pre></blockquote>
#if 0
  @ <p>当然，您也可以替换成任何您喜欢的颜色。
  @ 以下是一组推荐的背景色:</p>
  @ <blockquote>
  @ <table border=1 cellspacing=0 width=300>
  @ <tr><td align="center" bgcolor="#ffbdbd">#ffbdbd</td>
  @     <td align="center" bgcolor="#f2dcdc">#f2dcdc</td></tr>
  @ <tr><td align="center" bgcolor="#ffffbd">#ffffbd</td>
  @     <td align="center" bgcolor="#e8e8bd">#e8e8bd</td></tr>
  @ <tr><td align="center" bgcolor="#c0ebc0">#c0ebc0</td>
  @     <td align="center" bgcolor="#cfe8bd">#cfe8bd</td></tr>
  @ <tr><td align="center" bgcolor="#c0c0f4">#c0c0f4</td>
  @     <td align="center" bgcolor="#d6d6e8">#d6d6e8</td></tr>
  @ <tr><td align="center" bgcolor="#d0b1ff">#d0b1ff</td>
  @     <td align="center" bgcolor="#d2c0db">#d2c0db</td></tr>
  @ <tr><td align="center" bgcolor="#bbbbbb">#bbbbbb</td>
  @     <td align="center" bgcolor="#d0d0d0">#d0d0d0</td></tr>
  @ </table>
  @ </blockquote>
#endif
  @ <p>如果要显示“任务单（TICKET）”表中的“描述信息（DESCRIPTION）”或“备注
  @ （REMARKS）”字段，您需要将他们放到最后两列，并给予一个以下划线开头的名字，
  @ 例如:</p>
  @ <blockquote><pre>
  @  SELECT
  @    tn AS '#',
  @    type AS '类型',
  @    status AS '状态',
  @    sdate(origtime) AS '创建时间',
  @    owner AS '创建人',
  @    subsystem AS '子系统',
  @    sdate(changetime) AS '更新时间',
  @    assignedto AS '分配给',
  @    severity AS '严重',
  @    priority AS '优先',
  @    title AS '标题',
  @    description AS '_描述信息',   -- 当列名以下划线开头时，数据将被
  @    remarks AS '_备注'            -- 分行显示。
  @  FROM ticket
  @ </pre></blockquote>
  @
  @ <p>或者，要在同一行中查看描述信息部分，可以使用
  @ <b>wiki()</b> 函数来进行一些字符串处理。使用
  @ <b>tkt()</b> 函数来处理任务单编号同样会生成一个超链接字段，
  @ 但是并不会有额外的 <i>编辑</i> 列:
  @ </p>
  @ <blockquote><pre>
  @  SELECT
  @    tkt(tn) AS '',
  @    title AS '标题',
  @    wiki(substr(description,0,80)) AS '描述信息'
  @  FROM ticket
  @ </pre></blockquote>
  @
}

/*********************************************************************/
static void output_report_field(const char *zData,int rn){
  const char *zWkey = wiki_key();
  const char *zTkey = tkt_key();
  const char *zCkey = chng_key();

  if( !strncmp(zData,zWkey,strlen(zWkey)) ){
    output_formatted(&zData[strlen(zWkey)],0);
  }else if( !strncmp(zData,zTkey,strlen(zTkey)) ){
    output_ticket(atoi(&zData[strlen(zTkey)]),rn);
  }else if( !strncmp(zData,zCkey,strlen(zCkey)) ){
    output_chng(atoi(&zData[strlen(zCkey)]));
  }else{
    @ %h(zData)
  }
}

static void column_header(int rn,const char *zCol, int nCol, int nSorted,
    const char *zDirection, const char *zExtra
){
  int set = (nCol==nSorted);
  int desc = !strcmp(zDirection,"DESC");

  /*
  ** Clicking same column header 3 times in a row resets any sorting.
  ** Note that we link to rptview, which means embedded reports will get
  ** sent to the actual report view page as soon as a user tries to do
  ** any sorting. I don't see that as a Bad Thing.
  */
  if(set && desc){
    @ <th bgcolor="%s(BG1)" class="bkgnd1">
    @   <a href="rptview?rn=%d(rn)%s(zExtra)">%h(zCol)</a></th>
  }else{
    if(set){
      @ <th bgcolor="%s(BG1)" class="bkgnd1"><a
    }else{
      @ <th><a
    }
    @ href="rptview?rn=%d(rn)&amp;order_by=%d(nCol)&amp;\
    @ order_dir=%s(desc?"ASC":"DESC")\
    @ %s(zExtra)">%h(zCol)</a></th>
  }
}

/*********************************************************************/
struct GenerateHTML {
  int rn;
  int nCount;
};

/*
** The callback function for db_query
*/
static int generate_html(
  void* pUser,     /* Pointer to output state */
  int nArg,        /* Number of columns in this result row */
  char **azArg,    /* Text of data in all columns */
  char **azName    /* Names of the columns */
){
  struct GenerateHTML* pState = (struct GenerateHTML*)pUser;
  int i;
  int tn;            /* Ticket number.  (value of column named '#') */
  int rn;            /* Report number */
  int ncol;          /* Number of columns in the table */
  int multirow;      /* True if multiple table rows per line of data */
  int newrowidx;     /* Index of first column that goes on a separate row */
  int iBg = -1;      /* Index of column that determines background color */
  char *zBg = 0;     /* Use this background color */
  char zPage[30];    /* Text version of the ticket number */

  /* Get the report number
  */
  rn = pState->rn;

  /* Figure out the number of columns, the column that determines background
  ** color, and whether or not this row of data is represented by multiple
  ** rows in the table.
  */
  ncol = 0;
  multirow = 0;
  newrowidx = -1;
  for(i=0; i<nArg; i++){
    if( azName[i][0]=='b' && strcmp(azName[i],"bgcolor")==0 ){
      zBg = azArg ? azArg[i] : 0;
      iBg = i;
      continue;
    }
    if( g.okWrite && azName[i][0]=='#' ){
      ncol++;
    }
    if( !multirow ){
      if( azName[i][0]=='_' ){
        multirow = 1;
        newrowidx = i;
      }else{
        ncol++;
      }
    }
  }

  /* The first time this routine is called, output a table header
  */
  if( pState->nCount==0 ){
    char zExtra[2000];
    int nField = atoi(PD("order_by","0"));
    const char* zDir = PD("order_dir","");
    zDir = !strcmp("ASC",zDir) ? "ASC" : "DESC";
    zExtra[0] = 0;

    if( g.nAux ){
      @ <tr>
      @ <td colspan=%d(ncol)><form action="rptview" method="GET">
      @ <input type="hidden" name="rn" value="%d(rn)">
      for(i=0; i<g.nAux; i++){
        const char *zN = g.azAuxName[i];
        const char *zP = g.azAuxParam[i];
        if( g.azAuxVal[i] && g.azAuxVal[i][0] ){
          appendf(zExtra,0,sizeof(zExtra),
                  "&amp;%t=%t",g.azAuxParam[i],g.azAuxVal[i]);
        }
        if( g.azAuxOpt[i] ){
          @ %h(zN): 
          if( g.anAuxCols[i]==1 ) {
            cgi_v_optionmenu( 0, zP, g.azAuxVal[i], g.azAuxOpt[i] );
          }else if( g.anAuxCols[i]==2 ){
            cgi_v_optionmenu2( 0, zP, g.azAuxVal[i], g.azAuxOpt[i] );
          }
        }else{
          @ %h(zN): <input type="text" name="%h(zP)" value="%h(g.azAuxVal[i])">
        }
      }
      @ <input type="submit" value="执行">
      @ </form></td></tr>
    }
    @ <tr>
    tn = -1;
    for(i=0; i<nArg; i++){
      char *zName = azName[i];
      if( i==iBg ) continue;
      if( newrowidx>=0 && i>=newrowidx ){
        if( g.okWrite && tn>=0 ){
          @ <th>&nbsp;</th>
          tn = -1;
        }
        if( zName[0]=='_' ) zName++;
        @ </tr><tr><th colspan=%d(ncol)>%h(zName)</th>
      }else{
        if( zName[0]=='#' ){
          tn = i;
        }
        /*
        ** This handles any sorting related stuff. Note that we don't
        ** bother trying to sort on the "wiki format" columns. I don't
        ** think it makes much sense, visually.
        */
        column_header(rn,azName[i],i+1,nField,zDir,zExtra);
      }
    }
    if( g.okWrite && tn>=0 ){
      @ <th>&nbsp;</th>
    }
    @ </tr>
  }
  if( azArg==0 ){
    @ <tr><td colspan="%d(ncol)">
    @ <i>没有符合该报表要求的记录。</i>
    @ </td></tr>
    return 0;
  }
  ++pState->nCount;

  /* Output the separator above each entry in a table which has multiple lines
  ** per database entry.
  */
  if( newrowidx>=0 ){
    @ <tr><td colspan=%d(ncol)><font size=1>&nbsp;</font></td></tr>
  }

  /* Output the data for this entry from the database
  */
  if( zBg==0 ) zBg = "white";
  @ <tr bgcolor="%h(zBg)">
  tn = 0;
  zPage[0] = 0;
  for(i=0; i<nArg; i++){
    char *zData;
    if( i==iBg ) continue;
    zData = azArg[i];
    if( zData==0 ) zData = "";
    if( newrowidx>=0 && i>=newrowidx ){
      if( tn>0 && g.okWrite ){
        @ <td valign="top"><a href="tktedit?tn=%d(tn),%d(rn)">编辑</a></td>
        tn = 0;
      }
      if( zData[0] ){
        @ </tr><tr bgcolor="%h(zBg)"><td colspan=%d(ncol)>
        output_formatted(zData, zPage[0] ? zPage : 0);
      }
    }else if( azName[i][0]=='#' ){
      tn = atoi(zData);
      if( tn>0 ) bprintf(zPage, sizeof(zPage), "%d", tn);
      @ <td valign="top"><a href="tktview?tn=%d(tn),%d(rn)">%h(zData)</a></td>
    }else if( zData[0]==0 ){
      @ <td valign="top">&nbsp;</td>
    }else{
      @ <td valign="top">
      output_report_field(zData,rn);
      @ </td>
    }
  }
  if( tn>0 && g.okWrite ){
    @ <td valign="top"><a href="tktedit?tn=%d(tn),%d(rn)">编辑</a></td>
  }
  @ </tr>
  return 0;
}

/*
** Output the text given in the argument.  Convert tabs and newlines into
** spaces.
*/
static void output_no_tabs(const char *z){
  while( z && z[0] ){
    int i, j;
    for(i=0; z[i] && (!isspace(z[i]) || z[i]==' '); i++){}
    if( i>0 ){
      cgi_printf("%.*s", i, z);
    }
    for(j=i; isspace(z[j]); j++){}
    if( j>i ){
      cgi_printf("%*s", j-i, "");
    }
    z += j;
  }
}

/*
** Output a row as a tab-separated line of text.
*/
static int output_tab_separated(
  void *pUser,     /* Pointer to row-count integer */
  int nArg,        /* Number of columns in this result row */
  char **azArg,    /* Text of data in all columns */
  char **azName    /* Names of the columns */
){
  int *pCount = (int*)pUser;
  int i;

  if( *pCount==0 ){
    for(i=0; i<nArg; i++){
      output_no_tabs(azName[i]);
      cgi_printf("%c", i<nArg-1 ? '\t' : '\n');
    }
  }
  ++*pCount;
  for(i=0; i<nArg; i++){
    output_no_tabs(azArg[i]);
    cgi_printf("%c", i<nArg-1 ? '\t' : '\n');
  }
  return 0;
}

/*
** Generate HTML that describes a color key.
*/
void output_color_key(const char *zClrKey, int horiz, char *zTabArgs){
  int i, j, k;
  char *zSafeKey, *zToFree;
  while( isspace(*zClrKey) ) zClrKey++;
  if( zClrKey[0]==0 ) return;
  @ <table %s(zTabArgs)>
  if( horiz ){
    @ <tr>
  }
  zToFree = zSafeKey = mprintf("%h", zClrKey);
  while( zSafeKey[0] ){
    while( isspace(*zSafeKey) ) zSafeKey++;
    for(i=0; zSafeKey[i] && !isspace(zSafeKey[i]); i++){}
    for(j=i; isspace(zSafeKey[j]); j++){}
    for(k=j; zSafeKey[k] && zSafeKey[k]!='\n' && zSafeKey[k]!='\r'; k++){}
    if( !horiz ){
      cgi_printf("<tr bgcolor=\"%.*s\"><td>%.*s</td></tr>\n",
        i, zSafeKey, k-j, &zSafeKey[j]);
    }else{
      cgi_printf("<td bgcolor=\"%.*s\">%.*s</td>\n",
        i, zSafeKey, k-j, &zSafeKey[j]);
    }
    zSafeKey += k;
  }
  free(zToFree);
  if( horiz ){
    @ </tr>
  }
  @ </table>
}

/*
** Outputs a report, rn.
**
** zTableOpts may be used to control things like table alignment or width. It
** goes in the HTML <TABLE> tag.
*/
void embed_view(int rn, const char *zCaption, const char *zTableOpts){
  char **az;
  char *zSql;
  const char *zTitle;
  char *zClrKey;
  static int nDepth = 0;
  struct GenerateHTML sState;

  /* report fields can be wiki formatted. Let's not get into infinite
  ** recursions...
  */
  if(nDepth) return;

  db_add_functions();
  view_add_functions(0);

  az = db_query( "SELECT title, sqlcode, cols FROM reportfmt WHERE rn=%d", rn);
  if( az[0]==0 ) return;
  nDepth++;
  zTitle = az[0];
  if( zCaption==0 || zCaption[0]==0 ){
    zCaption = zTitle;
  }
  zSql = az[1];
  zClrKey = az[3];
  db_execute("PRAGMA empty_result_callbacks=ON");
  /* output_color_key(zClrKey, 1, "border=0 cellpadding=3 cellspacing=0"); */
  @ <div>
  @ <table border=1 cellpadding=2 cellspacing=0
  @        summary="%h(zTitle)" %s(zTableOpts?zTableOpts:"")>
  @ <caption>
  @   <a href="rptview?rn=%d(rn)" rel="nofollow"
  @      title="%h(zTitle)">%h(zCaption)</a>
  @ </caption>
  db_restrict_access(1);
  sState.rn = rn;
  sState.nCount = 0;
  db_callback_query(generate_html, &sState, "%s", zSql);
  db_restrict_access(0);
  @ </table></div>
  nDepth--;
}

/*
** Adds all appropriate action bar links for report tools
*/
static void add_rpt_tools( const char *zExcept, int rn ){
  int i;
  char *zLink;
  char **azTools;
  db_add_functions();
  azTools = db_query("SELECT tool.name FROM tool,user "
                     "WHERE tool.object='rpt' AND user.id='%q' "
                     "      AND cap_and(tool.perms,user.capabilities)!=''",
                     g.zUser);

  for(i=0; azTools[i]; i++){
    if( zExcept && 0==strcmp(zExcept,azTools[i]) ) continue;
    zLink = mprintf("rptrool?t=%T&rn=%d", azTools[i], rn);
    common_add_action_item(zLink, azTools[i]);
  }
}

/*
** WEBPAGE: /rpttool
**
** Execute an external tool on a given ticket
*/
void rpttool(void){
  int rn = atoi(PD("rn","0"));
  const char *zTool = P("t");
  char *zAction;
  const char *azSubst[32];
  int n = 0;

  if( rn==0 || zTool==0 ) cgi_redirect("index");

  login_check_credentials();
  if( !g.okRead ){ login_needed(); return; }
  throttle(1,0);
  history_update(0);

  zAction = db_short_query("SELECT command FROM tool "
                           "WHERE name='%q' AND object='rpt'", zTool);
  if( zAction==0 || zAction[0]==0 ){
    cgi_redirect(mprintf("rptview?rn=%d",rn));
  }

  common_standard_menu(0, 0);
  common_add_action_item(mprintf("rptview?rn=%d", rn), "查看");
  common_add_action_item( mprintf("rptsql?rn=%d",rn), "SQL");
  add_rpt_tools(zTool,rn);

  common_header("%h (%d)", zTool, rn);

  azSubst[n++] = "RN";
  azSubst[n++] = mprintf("%d",rn);
  azSubst[n++] = 0;

  n = execute_tool(zTool,zAction,0,azSubst);
  free(zAction);
  if( n<=0 ){
    cgi_redirect(mprintf("rptview?rn=%d", rn));
  }
  common_footer();
}

/*
** WEBPAGE: /rptview
**
** Generate a report.  The rn query parameter is the report number
** corresponding to REPORTFMT.RN.  If the tablist query parameter exists,
** then the output consists of lines of tab-separated fields instead of
** an HTML table.
*/
void view_view(void){
  int count = 0;
  int rn;
  char **az;
  char *zSql;
  char *zTitle;
  char *zDesc;
  char *zOwner;
  char *zClrKey;
  int tabs;

  login_check_credentials();
  if( !g.okRead ){ login_needed(); return; }
  throttle(1,0);
  rn = atoi(PD("rn","0"));
  if( rn==0 ){
    cgi_redirect("reportlist");
    return;
  }
  tabs = P("tablist")!=0;
  db_add_functions();
  view_add_functions(tabs);
  az = db_query(
    "SELECT title, sqlcode, owner, cols, description "
    "FROM reportfmt WHERE rn=%d", rn);
  if( az[0]==0 ){
    cgi_redirect("reportlist");
    return;
  }
  zTitle = az[0];
  zSql = az[1];
  zDesc = az[4];

  if( P("order_by") ){
    /*
    ** If the user wants to do a column sort, wrap the query into a sub
    ** query and then sort the results. This is a whole lot easier than
    ** trying to insert an ORDER BY into the query itself, especially
    ** if the query is already ordered.
    */
    int nField = atoi(P("order_by"));
    if( nField > 0 ){
      const char* zDir = PD("order_dir","");
      zDir = !strcmp("ASC",zDir) ? "ASC" : "DESC";
      zSql = mprintf("SELECT * FROM (%s) ORDER BY %d %s", zSql, nField, zDir);
    }
  }

  zOwner = az[2];
  zClrKey = az[3];
  count = 0;
  if( !tabs ){
    struct GenerateHTML sState;

    db_execute("PRAGMA empty_result_callbacks=ON");
    common_standard_menu("rptview", 0);
    common_add_help_item("CvstracReport");
    common_add_action_item(
      mprintf("rptview?tablist=1&%s", getenv("QUERY_STRING")),
      "原始数据"
    );
    if( g.okAdmin || (g.okQuery && strcmp(g.zUser,zOwner)==0) ){
      common_add_action_item( mprintf("rptedit?rn=%d",rn), "编辑");
    }
    common_add_action_item( mprintf("rptsql?rn=%d",rn), "SQL 语句");
    common_header("%s", zTitle);
    if( zDesc && zDesc[0] ){
      @ <div class="wiki">
      output_formatted(zDesc,0);
      @ </div>
    }
    output_color_key(zClrKey, 1, "border=0 cellpadding=3 cellspacing=0 class=\"report\"");
    @ <table border=1 cellpadding=2 cellspacing=0 class="report">
    db_restrict_access(1);
    sState.rn = rn;
    sState.nCount = 0;
    db_callback_query(generate_html, &sState, "%s", zSql);
    db_restrict_access(0);
    @ </table>
    @ <div id="rowcount" align="right">
    @ <small><i>行数: %d(sState.nCount)</i></small>
    @ </div>
  }else{
    db_restrict_access(1);
    db_callback_query(output_tab_separated, &count, "%s", zSql);
    db_restrict_access(0);
    cgi_set_content_type("text/plain");
  }
  if( !tabs ){
    common_footer();
  }
}
