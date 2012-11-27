<?php

require_once ('common.php');
require_once ('db_mysql.inc');
require_once ('cndef.php');

function toStr($s) {
  return $s;
}

function toUrl($field, $value, $s) {
  return "<a href=\"./?kind=7&field=$field&value=$value\">$s</a>";
}

function ideUrl($ide) {
  return toUrl('ide', $ide, $ide);
}

function verUrl($ver) {
  return toUrl('ver', $ver, $ver);
}

function codeUrl($code) {
  if (empty($code))
    $code = '--';
  return toUrl('code', $code, country_name_by_code($code));
}

function langUrl($lang) {
  if (empty($lang))
    $lang = 'none';
  return toUrl('lang', $lang, lang_name_by_id($lang));
}

function ipUrl($ipaddr) {
  return toUrl('ipaddr', $ipaddr, $ipaddr);
}

function addDays($date, $days) {
  return date("Y-m-d", strtotime($date) + $days * 60 * 60 * 24);
}

function getYear($date) {
  return date("Y", strtotime($date));
}

function getMonth($date) {
  return date("m", strtotime($date));
}

function getDay($date) {
  return date("d", strtotime($date));
}

class ViewPage {

  var $now = "";
  var $today = "";
  var $alldate = "";
  var $offset = 0;
  
  function getint($ident) {
    return (int)get_request($ident);
  }

  function outStr($s) {
    echo ($s);
  }

  function getPercent($v, $sum) {
    if ($v > 0)
      return sprintf('&nbsp;(%3.1f%%)', $v * 100.0 / $sum);
    else
      return '';
  }

  function getMax($lst) {
    if (count($lst) == 0)
      return 1;
    $ret = max($lst);
    return $ret < 1 ? 1 : $ret;
  }

  function getSum($lst) {
    $ret = 0;
    foreach ($lst as $i)
      $ret += $i;
    return $ret;
  }

  function getChsWeekDay($date) {
    $dname = array('日', '一', '二', '三', '四', '五', '六');
    return $dname[date("w", strtotime($date))];
  }

  function getDateStr($date) {
    return "$date (星期".$this->getChsWeekDay($date).")";
  }

  function get() {
    global $g_sys_vars;
    if (!isset($_SERVER['PHP_AUTH_USER']) || !isset($_SERVER['PHP_AUTH_PW']) ||
      ($_SERVER['PHP_AUTH_USER'] != $g_sys_vars['mgruser']) || 
      ($_SERVER['PHP_AUTH_PW'] != $g_sys_vars['mgrpassword'])) {
      Header("WWW-Authenticate: Basic realm=\"CnPack Upgrade Stat\""); 
      Header("HTTP/1.0 401 Unauthorized"); 
      echo "<Center>你无权执行这一操作<br>要继续请刷新页面并输入正确的用户名及密码<br>有其它任何问题请与<a href='mailto:master@cnpack.org'>master@cnpack.org</a>联系。"; 
      echo "<P><a href='http://www.cnpack.org'>返回 CnPack 开发网站</a> | <a href='http://bbs.cnpack.org'>CnPack 论坛</a> | <a href='javascript:window.close()'>关闭窗口</a></center>";
      exit; 
    }
    
    date_default_timezone_set('PRC');
    $this->now = date("Y-m-d H:i:s");
    $this->today = date("Y-m-d");
    $this->alldate = date("2000-1-1");
    $this->offset = $this->getint('offset');

    $this->outHead();

    $kind = $this->getint('kind');
    if ($kind == 0)
      $this->outDay();
    else if ($kind == 1)
      $this->outMonth();
    else if ($kind == 2)
      $this->outHour();
    else if ($kind == 3)
      $this->outIde();
    else if ($kind == 4)
      $this->outVer();
    else if ($kind == 5)
      $this->outCountry();
    else if ($kind == 6)
      $this->outLog();
    else if ($kind == 7)
      $this->outDetail();
    else if ($kind == 8)
      $this->outQuery();
    else if ($kind == 9)
      $this->outLang();

    $this->outFoot();
  }

  function outHead() {
    $this->outStr('
<html>

<head>
<meta http-equiv="Content-Type" content="text/html"; charset=utf-8>
<link rel="stylesheet" href="../css/style_zh-cn.css" type="text/css">
<title>CnWizards 用户统计数据</title>
</head>

<body>

<table width="770" align="center" border="0" cellpadding="0" cellspacing="0">
  <tr><td align="center"><b><font size="3">CnWizards 用户统计数据</font></b></td></tr>
  <tr><td><hr></td></tr>
  <tr><td>
<br>
统计方式：
<a href="./?kind=0">按日统计</a>
<a href="./?kind=1">按月统计</a>
<a href="./?kind=2">时段统计</a>
<a href="./?kind=3">IDE 统计</a>
<a href="./?kind=4">版本统计</a>
<a href="./?kind=5">区域统计</a>
<a href="./?kind=9">语言统计</a>
<a href="./?kind=8">组合查询</a>
<a href="./?kind=6">日志查看</a>
<br>
<br>');
  }

  function outFoot() {
    $this->outStr('
<div align="center">
  <table border=0 width=770 height=20 cellspacing=0 cellpadding=0>
    <tr><td><hr></td></tr>
  </table>
  <table border=0 width=770 height=20 cellspacing=0 cellpadding=0>
    <tr><td align="center">版权所有(C) 2001-2012 <a href="mailto:master@cnpack.org">CnPack 开发组</a></td></tr>
    <tr><td align="center">程序编写：<a href="mailto:zjy@cnpack.org">周劲羽</a></td></tr>
  </table>
</div>

</body>

</html>');
  }

  function outDay() {
    $num = 30;
    $cnt = array ();
    $date = addDays($this->today, - $this->offset * $num);
    $db = new db("SELECT * ".
                 "FROM cwcnthour ".
                 "WHERE date <= '$date' AND date > '".addDays($date, -$num)."'");
    while ($db->next_record()) {
      $delta = get_diff_days($db->f('date'), $date);
      $cnt[$delta] += $db->f('count');
    }
    $cmax = $this->getMax($cnt);

    $this->outStr('日统计数据：');
    $this->outStr('<a href="./?kind=0&offset='.($this->offset + 1).'">前一页</a>&nbsp;');
    $this->outStr('<a href="./?kind=0&offset=0">今天</a>&nbsp;');
    if ($this->offset >= 1)
      $this->outStr(sprintf('<a href="./?kind=0&offset=%d">后一页</a>&nbsp;', $this->offset - 1));
    $this->outStr('
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="10%">日期</td>
    <td width="5%">星期</td>
    <td width="35%">访问量</td>
    <td width="10%">日期</td>
    <td width="5%">星期</td>
    <td width="35%">访问量</td>
  </tr>');

    for ($i = 0; $i < $num; $i++) {
      if ($i % 2 == 0) {
        $this->outStr('<tr>');
        $idx = floor($i / 2);
      } else {
        $idx = floor(($i + $num) / 2);
      }
      $cd = addDays($date, -$idx);
      $this->outStr(sprintf("<td>&nbsp;%s</td><td>&nbsp;%s</td><td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d</td>",
        $cd, $this->getChsWeekDay($cd), $cnt[$idx], floor($cnt[$idx] * 200 / $cmax), $cnt[$idx]));
      if ($i % 2 == 1)
        $this->outStr('</tr>');
    }
    $this->outStr('
</table>
<br>');
  }

  function monthDelta($date, $delta) {
    return date("Y-m-d", mktime(0, 0, 0, getMonth($date) + $delta, getDay($date), getYear($date)));
  }

  function outMonth() {
    $date = date("Y-m-d", mktime(0, 0, 0, getMonth($this->today), 1, getYear($this->today)));
    $num = 36;
    $mcnt = array();
    $mdays = array();
    $maver = array();
    $mact = array();
    $db = new db();
    for ($i = 0; $i < $num; $i++) {
      $d1 = $this->monthDelta($date, 1 - $i);
      $d2 = $this->monthDelta($date, -$i);
      if ((getYear($d2) == getYear($this->today)) and (getMonth($d2) == getMonth($this->today)))
        $mdays[$i] = get_diff_days($d2, $this->today) + 1;
      else
        $mdays[$i] = get_diff_days($d2, $d1);
        
      $db->query("SELECT SUM(count) as cnt ".
                 "FROM cwcnthour ".
                 "WHERE date < '$d1' AND date >= '$d2'");
      if ($db->next_record()) {
        $mcnt[$i] = $db->f('cnt');
        $maver[$i] = floor($mcnt[$i] / $mdays[$i]);
      }

      $d1 = date("Y-m-d", mktime(0, 0, 0, getMonth($d2), 1, getYear($d2)));
      $db->query("SELECT * ".
                 "FROM cwcntmonth ".
                 "WHERE date = $d1");
      if ($db->next_record()) {
        $mact[$i] = $db->f('count');
      }
    }

    $cmax = $this->getMax($mact);

    $this->outStr('
月统计数据：
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="7%">月份</td>
    <td width="7%">总访问</td>
    <td width="7%">日均访问</td>
    <td width="29%">当月活跃用户数</td>
    <td width="7%">月份</td>
    <td width="7%">总访问</td>
    <td width="7%">日均访问</td>
    <td width="29%">当月活跃用户数</td>
  </tr>');

    for ($i = 0; $i < $num; $i++) {
      if ($i % 2 == 0) {
        $this->outStr('<tr>');
        $idx = floor($i / 2);
      } else {
        $idx = floor(($i + $num) / 2);
      }
      $cd = $this->monthDelta($date, -$idx);
      $this->outStr(sprintf("<td>&nbsp;%d-%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d</td>",
        getYear($cd), getMonth($cd), $mcnt[$idx], $maver[$idx], $mact[$idx], $mact[$idx] * 170 / $cmax, $mact[$idx]));
      if ($i % 2 == 1)
        $this->outStr('</tr>');
    }
    $this->outStr('
</table>
<br>');
  }
  
  function doOutData($table, $field, $title, $kind, $col1, $col2, $col3, $col4) {
    $date = addDays($this->today, $this->offset);
    $db = new db("SELECT * ".
                 "FROM $table ".
                 "WHERE date = '".$this->alldate."' ORDER BY count DESC");
    $dict = array();
    $cntall = array();
    if ($field == 'hour')
      for ($i = 0; $i < 24; $i++)
        $dict[] = $i;
    while ($db->next_record()) {
      if ($field != 'hour')
        $dict[] = $db->f($field);
      $cntall[$db->f($field)] = $db->f('count');
    }

    $cntday = array();
    $db->query("SELECT * ".
               "FROM $table ".
               "WHERE date = '$date'");
    while ($db->next_record()) {
      $cntday[$db->f($field)] = $db->f('count');
    }

    $cntlast = array();
    $db->query("SELECT * ".
               "FROM $table ".
               "WHERE date = '".addDays($date, -1)."'");
    while ($db->next_record()) {
      $cntlast[$db->f($field)] = $db->f('count');
    }

    $allmax = $this->getMax($cntall);
    $allsum = $this->getSum($cntall);
    $daymax = $this->getMax($cntday);
    $daysum = $this->getSum($cntday);
    $lastmax = $this->getMax($cntlast);
    $lastsum = $this->getSum($cntlast);

    $this->outStr($title.'统计数据：');
    $this->outStr(sprintf('<a href="./?kind='.$kind.'&offset=%d">前一天</a>&nbsp;', $this->offset + 1));
    $this->outStr('<a href="./?kind='.$kind.'&offset=0">今天</a>&nbsp;');
    if ($this->offset >= 1)
      $this->outStr(sprintf('<a href="./?kind='.$kind.'&offset=%d">后一天</a>&nbsp;', $this->offset - 1));
    $this->outStr('
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="'.$col1.'%">'.$title.'</td>
    <td width="'.$col2.'%">所有日期数据</td>');
    $this->outStr(sprintf('<td width="'.$col3.'%%">%s</td><td width="'.$col3.'%%">%s</td></tr>',
      $this->getDateStr(addDays($date, -1)), $this->getDateStr($date)));
    $this->outStr(sprintf("<tr><td>全部</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td></tr>",
      $allsum, $lastsum, $daysum));

    foreach ($dict as $i) {
      $this->outStr('<tr>');
      if ($field == 'ide')
        $head = ideUrl($i);
      else if ($field == 'ver')
        $head = verUrl($i);
      else if ($field == 'code')
        $head = codeUrl($i);
      else if ($field == 'lang')
        $head = langUrl($i);
      else
        $head = $i;
      $this->outStr(sprintf("<td>&nbsp;%s</td><td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $head, $cntall[$i], $cntall[$i] * $col4 / $allmax, $cntall[$i], $this->getPercent($cntall[$i], $allsum)));
      $this->outStr(sprintf("<td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $cntlast[$i], $cntlast[$i] * $col4 / $lastmax, $cntlast[$i], $this->getPercent($cntlast[$i], $lastsum)));
      $this->outStr(sprintf("<td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $cntday[$i], $cntday[$i] * $col4 / $daymax, $cntday[$i], $this->getPercent($cntday[$i], $daysum)));
      $this->outStr('</tr>');
    }
    $this->outStr('
</table>
<br>');
  }

  function outHour() {
    $this->doOutData('cwcnthour', 'hour', '时段', 2, 6, 32, 31, 130);
  }

  function outIde() {
    $this->doOutData('cwcntide', 'ide', 'IDE ', 3, 15, 29, 28, 110);
  }

  function outVer() {
    $this->doOutData('cwcntver', 'ver', '版本', 4, 15, 29, 28, 110);
  }

  function outCountry() {
    $this->doOutData('cwcntcountry', 'code', '国家/地区', 5, 16, 28, 28, 110);
  }

  function outLang() {
    $this->doOutData('cwcntlang', 'lang', '语言', 5, 16, 28, 28, 110);
  }

  function outLog() {
    $num = 20;
    $min = $this->getint('min');
    $date = date("Y-m-d H:i:s", time() - $min * 10 * 60);
    $db = new db();
    if ($min == 0)
	    $db->query("SELECT * ".
                 "FROM cwlogs ".
                 "ORDER BY date DESC ".
                 "LIMIT ".($this->offset * $num).", $num");
    else
	    $db->query("SELECT * ".
                 "FROM cwlogs ".
                 "WHERE date <= $date ORDER BY date DESC ".
                 "LIMIT ".($this->offset * $num).", $num");

    $this->outStr('日志查看：');
    $this->outStr(sprintf('<a href="./?kind=6&offset=%d&$min=%d">前十分钟</a>&nbsp;', $this->offset, $min + 1));
    $this->outStr(sprintf('<a href="./?kind=6&offset=%d&$min=%d">前一页</a>&nbsp;', $this->offset + 1, $min));
    $this->outStr('<a href="./?kind=6&offset=0&$min=0">当前</a>&nbsp;');
    if ($this->offset >= 1)
      $this->outStr(sprintf('<a href="./?kind=6&offset=%d&$min=%d">后一页</a>&nbsp;', $this->offset - 1, $min));
    if ($min >= 1)
      $this->outStr(sprintf('<a href="./?kind=6&offset=%d&$min=%d">后十分钟</a>&nbsp;', $this->offset, $min - 1));
    $this->outStr('
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="20%">时间</td>
    <td width="12%">IP地址</td>
    <td width="28%">国家/地区</td>
    <td width="12%">语言</td>
    <td width="14%">IDE</td>
    <td width="14%">版本号</td>');

    while ($db->next_record()) {
      $this->outStr('<tr>');
      $this->outStr(sprintf('<td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>',
        $db->f('date'), ipUrl($db->f('ipaddr')), codeUrl($db->f('code')), langUrl($db->f('lang')), ideUrl($db->f('ide')), verUrl($db->f('ver'))));
      $this->outStr('</tr>');
    }
    $this->outStr('
</table>
<br>');
  }

  function outDetail() {
    $num = 20;
    $field = get_request('field');
    $value = get_request('value');
    $db = new db(sprintf("SELECT * ".
                 "FROM CWLogs ".
                 "WHERE %s = '%s' ".
                 "ORDER BY date DESC ".
                 "LIMIT %d, %d", $field, $value, $this->offset * $num, $num));

    $this->outStr('日志过滤查看：');
    $this->outStr(sprintf('<a href="./?kind=7&offset=%d&field=%s&value=%s">前一页</a>&nbsp;', $this->offset + 1, toStr($field), toStr($value)));
    $this->outStr(sprintf('<a href="./?kind=7&offset=0&field=%s&value=%s">当前</a>&nbsp;', toStr($field), toStr($value)));
    if ($this->offset >= 1)
      $this->outStr(sprintf('<a href="./?kind=7&offset=%d&field=%s&value=%s">后一页</a>&nbsp;', $this->offset - 1, toStr($field), toStr($value)));
    $this->outStr('
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="20%">时间</td>
    <td width="12%">IP地址</td>
    <td width="28%">国家/地区</td>
    <td width="12%">语言</td>
    <td width="14%">IDE</td>
    <td width="14%">版本号</td>');

    while ($db->next_record()) {
      $this->outStr('<tr>');
      $this->outStr(sprintf('<td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>',
        $db->f('date'), ipUrl($db->f('ipaddr')), codeUrl($db->f('code')), langUrl($db->f('lang')), ideUrl($db->f('ide')), verUrl($db->f('ver'))));
      $this->outStr('</tr>');
    }
    $this->outStr('
</table>
<br>');
  } 

  function getMonthStr($date) {
    if (date == $this->alldate)
      return '全部';
    else
      return date("Y-m", strtotime($date));
  }
  
  function doOutCombo($title, $table, $field, $selval) {
    $this->outStr('
</select>
&nbsp;&nbsp;'.$title.':&nbsp;
<select size="1" name="'.$field.'">
<option value="">全部</option>');
    $db = new db("SELECT $field ".
                 "FROM $table ".
                 "GROUP BY $field ".
                 "ORDER BY $field ");
    while ($db->next_record()) {
      if ($db->f($field) == $selval)
        $selected = 'selected';
      else
        $selected = '';
      if ($field == 'code')
        $disp = country_name_by_code($db->f($field));
      else
        $disp = $db->f($field);
      $this->outStr(sprintf('<option %s value="%s">%s</option>', $selected, toStr($db->f($field)), toStr($disp)));
    }
  }
  
  function outQuery() {
    $num = 20;
    $idate = get_request('date', 0);
    if ($idate > 100) {
      $year = floor($idate / 100);
      $month = $idate % 100;
      $date = "$year-$month-1";
    } else {
      $date = $this->alldate;
    }
    $ide = get_request('ide');
    $ver = get_request('ver');
    $code = get_request('code');
    
    $this->outStr('条件组合查询：');
    if ($this->offset >= 1)
      $this->outStr(sprintf('<a href="./?kind=8&offset=%d&date=%d&ide=%s&ver=%s&code=%s">上一页</a>&nbsp;', 
        $this->offset - 1, $idate, toStr(ide), toStr(ver), toStr(code)));
    $this->outStr(sprintf('<a href="./?kind=8&offset=0&date=%d&ide=%s&ver=%s&code=%s">当前</a>&nbsp;', 
      $idate, toStr(ide), toStr(ver), toStr(code)));
    $this->outStr(sprintf('<a href="./?kind=8&offset=%d&date=%d&ide=%s&ver=%s&code=%s">下一页</a>&nbsp;', 
      $this->offset + 1, $idate, toStr(ide), toStr(ver), toStr(code)));

    $this->outStr('
<form method="get" name="query" action="./" class="form">
<input type="hidden" name="kind" value="8">
月份:&nbsp;
<select size="1" name="date">
<option value="">全部</option>');
    $db = new db();
    $db->query("SELECT * ".
               "FROM cwcntmonth ".
               "ORDER BY date DESC ");
    while ($db->next_record()) {
      $ival = getYear($db->f('date')) * 100 + getMonth($db->f('date'));
      if ($ival == $idate)
        $selected = 'selected';
      else
        $selected = '';
      $this->outStr(sprintf('<option %s value="%d">%d-%d</option>', $selected, $ival, $ival / 100, $ival % 100));
    }

    $this->doOutCombo('国家/地区', 'cwcntcountry', 'code', $code);
    $this->doOutCombo('IDE', 'cwcntide', 'ide', $ide);
    $this->doOutCombo('版本号', 'cwcntver', 'ver', $ver);

    $this->outStr('
</select>
<input type="submit" value="提交" class="btn2">&nbsp;
<input type="reset" value="重置" class="btn2">
</form>');

    if ($date == '')
      $date = $this->alldate;
    $swhere = " WHERE date = '$date'";
    if ($ide != '')
      $swhere .= " AND ide = '$ide'";
    if ($ver != '')
      $swhere .= " AND ver = '$ver'";
    if ($code != '')
      $swhere .= " AND code = '$code'";
    $db->query(sprintf("SELECT * ".
               "FROM cwcntunion ".
               "%s ".
               "ORDER BY count DESC ".
               "LIMIT %d, %d", $swhere, $this->offset * $num, $num));
    $cntall = array();
    while ($db->next_record())
      $cntall[] = $db->f('count');
    $allmax = $this->getMax($cntall);
    $allsum = $this->getSum($cntall);

    $this->outStr('
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="8%">月份</td>
    <td width="30%">访问数</td>
    <td width="24%">国家/地区</td>
    <td width="18%">IDE</td>
    <td width="18%">版本号</td>');

    $db->seek();
    while ($db->next_record()) {
      $this->outStr('<tr>');
      $this->outStr(sprintf('<td>%s</td>', $this->getMonthStr($db->f('date'))));
      $this->outStr(sprintf("<td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $db->f('count'), $db->f('count') * 130 / $allmax, $db->f('count'), $this->getPercent($db->f('count'), $allsum)));
      $this->outStr(sprintf('<td>%s</td><td>%s</td><td>%s</td>', codeUrl($db->f('code')), ideUrl($db->f('ide')), verUrl($db->f('ver'))));
      $this->outStr('</tr>');
    }
    $this->outStr('
</table>
<br>');
  }
}
  
$viewpage = new ViewPage();
$viewpage->get();

?>