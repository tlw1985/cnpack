<?php

require_once ('common.php');
require_once ('db_mysql.inc');
require_once ('cndef.php');

function incLog($ipaddr, $now, $ide, $ver, $code, $lang)
{
  $db = new db("INSERT INTO cwlogs (ipaddr, date, ide, ver, code, lang) VALUES ('$ipaddr', '$now', '$ide', '$ver', '$code', '$lang')");
}

function incCntHour($date, $hour)
{
  $id = "D:$date:$hour";
  $db = new db("SELECT * FROM cwcnthour WHERE id = '$id'");
  if ($db->next_record())
    $db->query("UPDATE cwcnthour SET count = count + 1 WHERE id = '$id'");
  else
    $db->query("INSERT INTO cwcnthour (id, date, hour, count) VALUES ('$id', '$date', '$hour', 1)");
}

function incCntMonth($date_month)
{
  $id = "D:$date_month";
  $db = new db("SELECT * FROM cwcntmonth WHERE id = '$id'");
  if ($db->next_record())
    $db->query("UPDATE cwcntmonth SET count = count + 1 WHERE id = '$id'");
  else
    $db->query("INSERT INTO cwcntmonth (id, date, count) VALUES ('$id', '$date_month', 1)");
}

function incCntIde($date, $ide)
{
  $id = "D:$date:$ide";
  $db = new db("SELECT * FROM cwcntide WHERE id = '$id'");
  if ($db->next_record())
    $db->query("UPDATE cwcntide SET count = count + 1 WHERE id = '$id'");
  else
    $db->query("INSERT INTO cwcntide (id, date, ide, count) VALUES ('$id', '$date', '$ide', 1)");
}

function incCntVer($date, $ver)
{
  $id = "D:$date:$ver";
  $db = new db("SELECT * FROM cwcntver WHERE id = '$id'");
  if ($db->next_record())
    $db->query("UPDATE cwcntver SET count = count + 1 WHERE id = '$id'");
  else
    $db->query("INSERT INTO cwcntver (id, date, ver, count) VALUES ('$id', '$date', '$ver', 1)");
}

function incCntCountry($date, $code)
{
  $id = "D:$date:$code";
  $db = new db("SELECT * FROM cwcntcountry WHERE id = '$id'");
  if ($db->next_record())
    $db->query("UPDATE cwcntcountry SET count = count + 1 WHERE id = '$id'");
  else
    $db->query("INSERT INTO cwcntcountry (id, date, code, count) VALUES ('$id', '$date', '$code', 1)");
}

function incCntLang($date, $lang)
{
  $id = "D:$date:$lang";
  $db = new db("SELECT * FROM cwcntlang WHERE id = '$id'");
  if ($db->next_record())
    $db->query("UPDATE cwcntlang SET count = count + 1 WHERE id = '$id'");
  else
    $db->query("INSERT INTO cwcntlang (id, date, lang, count) VALUES ('$id', '$date', '$lang', 1)");
}

function incCntUnion($date_month, $ide, $ver, $code)
{
  $id = "D:$date_month:$ide:$ver:$code";
  $db = new db("SELECT * FROM cwcntunion WHERE id = '$id'");
  if ($db->next_record())
    $db->query("UPDATE cwcntunion SET count = count + 1 WHERE id = '$id'");
  else
    $db->query("INSERT INTO cwcntunion (id, date, ide, ver, code, count) VALUES ('$id', '$date_month', '$ide', '$ver', '$code', 1)");
}

function DoStat()
{
  date_default_timezone_set('PRC');
  $now = date("Y-m-d H:i:s");
  $today = date("Y-m-d");
  $date_month = date("Y-m-1");
  $alldate = date("2000-1-1");

  if (get_request('month') == '1')
    incCntMonth($date_month);

  if (get_request('manual') == '1')
    return;

  incCntHour($today, date("H"));
  incCntHour($alldate, date("H"));

  $ipaddr = get_request('ip');
  if (ip2long($ipaddr) == 0)
    $ipaddr = $_SERVER["REMOTE_ADDR"];
  
  $ide = get_request('ide', 'none');
  incCntIde($today, $ide);
  incCntIde($alldate, $ide);

  $ver = get_request('ver', 'none');
  incCntVer($today, $ver);
  incCntVer($alldate, $ver);

  $code = country_code_by_addr($ipaddr);
  incCntCountry($today, $code);
  incCntCountry($alldate, $code);

  $lang = get_request('langid', 'none');
  incCntLang($today, $lang);
  incCntLang($alldate, $lang);

  incLog($ipaddr, $now, $ide, $ver, $code, $lang);

  incCntUnion($alldate, $ide, $ver, $code);
  incCntUnion($date_month, $ide, $ver, $code);
}

DoStat();

?>