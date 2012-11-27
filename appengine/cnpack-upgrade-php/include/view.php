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

function cStr($s) {
  return empty($s) ? 'Unknown' : $s;
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
    if (v > 0)
      return sprintf('&nbsp;(%3.1f%%)', v * 100.0 / $sum);
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
    // todo: Auth
    
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
                 "FROM CWCntMonth ".
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
  
  function outHour() {
    $date = addDays($this->today, -$this->offset);
    $cntall = array();
    $cntday = array();
    $cntlast = array();

    $db = new db("SELECT * ".
                 "FROM cwcnthour ".
                 "WHERE date = '".$this->alldate."'");
    while ($db->next_record()) {
      $cntall[$db->f('hour')] = $db->f('count');
    }

    $db->query("SELECT * ".
               "FROM CWCntHour ".
               "WHERE date = '$date'");
    while ($db->next_record()) {
      $cntday[$db->f('hour')] = $db->f('count');
    }

    $db->query("SELECT * ".
               "FROM CWCntHour ".
               "WHERE date = '".addDays($date, -1)."'");
    while ($db->next_record()) {
      $cntlast[$db->f('hour')] = $db->f('count');
    }

    $allmax = $this->getMax($cntall);
    $allsum = $this->getSum($cntall);
    $daymax = $this->getMax($cntday);
    $daysum = $this->getSum($cntday);
    $lastmax = $this->getMax($cntlast);
    $lastsum = $this->getSum($cntlast);

    $this->outStr('时段统计数据：');
    $this->outStr(sprintf('<a href="./?kind=2&offset=%d">前一天</a>&nbsp;', $this->offset + 1));
    $this->outStr('<a href="./?kind=2&offset=0">今天</a>&nbsp;');
    if ($this->offset >= 1)
      $this->outStr(sprintf('<a href="./?kind=2&offset=%d">后一天</a>&nbsp;', $this->offset - 1));
    $this->outStr('
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="6%">时段</td>
    <td width="32%">所有日期数据</td>');
    $this->outStr(sprintf('<td width="31%%">%s</td><td width="31%%">%s</td></tr>',
      $this->getDateStr(addDays($date, -1)), $this->getDateStr($date)));
    $this->outStr(sprintf("<tr><td>全部</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td></tr>",
      $allsum, $lastsum, $daysum));

    for ($i = 0; $i < 24; $i++) {
      $this->outStr('<tr>');
      $this->outStr(sprintf("<td>&nbsp;%d</td><td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $i, $cntall[$i], $cntall[$i] * 130 / $allmax, $cntall[$i], $this->getPercent($cntall[$i], $allsum)));
      $this->outStr(sprintf("<td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $cntlast[$i], $cntlast[$i] * 130 / $lastmax, $cntlast[$i], $this->getPercent($cntlast[$i], $lastsum)));
      $this->outStr(sprintf("<td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $cntday[$i], $cntday[$i] * 130 / $daymax, $cntday[$i], $this->getPercent($cntday[$i], $daysum)));
      $this->outStr('</tr>');
    }
    $this->outStr('
</table>
<br>');
  }

  function outIde() {
    $date = addDays($this->today, $this->offset);
    $db = new db("SELECT * ".
                 "FROM CWCntIde ".
                 "WHERE date = '".$this->alldate."' ORDER BY count DESC");
    $ides = array();
    $cntall = array();
    while ($db->next_record()) {
      $ides[] = cStr($db->f('ide'));
      $cntall[cStr($db->f('ide'))] = $db->f('count');
    }

    $cntday = array();
    $db->query("SELECT * ".
               "FROM CWCntIde ".
               "WHERE date = '$date'");
    while ($db->next_record()) {
      $cntday[cStr($db->f('ide'))] = $db->f('count');
    }

    $cntlast = array();
    $db->query("SELECT * ".
               "FROM CWCntIde ".
               "WHERE date = '".addDays($date, -1)."'");
    while ($db->next_record()) {
      $cntlast[cStr($db->f('ide'))] = $db->f('count');
    }

    $allmax = $this->getMax($cntall);
    $allsum = $this->getSum($cntall);
    $daymax = $this->getMax($cntday);
    $daysum = $this->getSum($cntday);
    $lastmax = $this->getMax($cntlast);
    $lastsum = $this->getSum($cntlast);

    $this->outStr('IDE 统计数据：');
    $this->outStr(sprintf('<a href="./?kind=3&offset=%d">前一天</a>&nbsp;', $this->offset + 1));
    $this->outStr('<a href="./?kind=3&offset=0">今天</a>&nbsp;');
    if ($this->offset >= 1)
      $this->outStr(sprintf('<a href="./?kind=3&offset=%d">后一天</a>&nbsp;', $this->offset - 1));
    $this->outStr('
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="16%">IDE</td>
    <td width="29%">所有日期数据</td>');
    $this->outStr(sprintf('<td width="28%%">%s</td><td width="28%%">%s</td></tr>',
      $this->getDateStr(addDays($date, -1)), $this->getDateStr($date)));
    $this->outStr(sprintf("<tr><td>全部</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td></tr>",
      $allsum, $lastsum, $daysum));

    foreach ($ides as $i) {
      $this->outStr('<tr>');
      $this->outStr(sprintf("<td>&nbsp;%s</td><td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        ideUrl($i), $cntall[$i], $cntall[$i] * 110 / $allmax, $cntall[$i], $this->getPercent($cntall[$i], $allsum)));
      $this->outStr(sprintf("<td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $cntlast[$i], $cntlast[$i] * 110 / $lastmax, $cntlast[$i], $this->getPercent($cntlast[$i], $lastsum)));
      $this->outStr(sprintf("<td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $cntday[$i], $cntday[$i] * 110 / $daymax, $cntday[$i], $this->getPercent($cntday[$i], $daysum)));
      $this->outStr('</tr>');
    }
    $this->outStr('
</table>
<br>');
  }

  function outVer() {
    $date = addDays($this->today, $this->offset);
    $db = new db("SELECT * ".
                 "FROM CWCntVer ".
                 "WHERE date = '".$this->alldate."' ORDER BY count DESC");
    $vers = array();
    $cntall = array();
    while ($db->next_record()) {
      $vers[] = cStr($db->f('ver'));
      $cntall[cStr($db->f('ver'))] = $db->f('count');
    }

    $cntday = array();
    $db->query("SELECT * ".
               "FROM CWCntVer ".
               "WHERE date = '$date'");
    while ($db->next_record()) {
      $cntday[cStr($db->f('ver'))] = $db->f('count');
    }

    $cntlast = array();
    $db->query("SELECT * ".
               "FROM CWCntVer ".
               "WHERE date = '".addDays($date, -1)."'");
    while ($db->next_record()) {
      $cntlast[cStr($db->f('ver'))] = $db->f('count');
    }

    $allmax = $this->getMax($cntall);
    $allsum = $this->getSum($cntall);
    $daymax = $this->getMax($cntday);
    $daysum = $this->getSum($cntday);
    $lastmax = $this->getMax($cntlast);
    $lastsum = $this->getSum($cntlast);

    $this->outStr('版本统计数据：');
    $this->outStr(sprintf('<a href="./?kind=4&offset=%d">前一天</a>&nbsp;', $this->offset + 1));
    $this->outStr('<a href="./?kind=4&offset=0">今天</a>&nbsp;');
    if ($this->offset >= 1)
      $this->outStr(sprintf('<a href="./?kind=4&offset=%d">后一天</a>&nbsp;', $this->offset - 1));
    $this->outStr('
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="15%">版本</td>
    <td width="29%">所有日期数据</td>');
    $this->outStr(sprintf('<td width="28%%">%s</td><td width="28%%">%s</td></tr>',
      $this->getDateStr(addDays($date, -1)), $this->getDateStr($date)));
    $this->outStr(sprintf("<tr><td>全部</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td></tr>",
      $allsum, $lastsum, $daysum));

    foreach ($vers as $i) {
      $this->outStr('<tr>');
      $this->outStr(sprintf("<td>&nbsp;%s</td><td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        verUrl($i), $cntall[$i], $cntall[$i] * 120 / $allmax, $cntall[$i], $this->getPercent($cntall[$i], $allsum)));
      $this->outStr(sprintf("<td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $cntlast[$i], $cntlast[$i] * 120 / $lastmax, $cntlast[$i], $this->getPercent($cntlast[$i], $lastsum)));
      $this->outStr(sprintf("<td>&nbsp;<img src='../image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>",
        $cntday[$i], $cntday[$i] * 120 / $daymax, $cntday[$i], $this->getPercent($cntday[$i], $daysum)));
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