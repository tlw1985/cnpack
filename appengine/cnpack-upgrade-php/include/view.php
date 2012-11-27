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
    foreach ($list as $i)
      $ret += $i;
    return $ret;
  }

  function getChsWeekDay($date) {
    $dname = array('日', '一', '二', '三', '四', '五', '六');
    return $dname[date("w", strtotime($date))];
  }

  function getDateStr($date) {
    return "$date (星期".getChsWeekDay($date);
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
}

$viewpage = new ViewPage();
$viewpage->get();

?>