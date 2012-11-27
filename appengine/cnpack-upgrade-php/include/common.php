<?php

require_once ('config.php');
require_once ('db_mysql.inc');

$g_lang['DatabaseErrorDebug'] = "数据库错误：%s<br><br>\nMySQL 错误：%d (%s)";
$g_lang['DatabaseError'] = "无效的数据访问！";

//==============================================================================
// 全局公共函数
//==============================================================================

// 得到当前日期
function get_date()
{
  return date('Y-m-d');
}

// 得到当前时间
function get_time()
{
  return date('H:i:s');
}  

// 得到日期时间
function get_datetime()
{
	return date("Y-m-d H:i:s");
}

// 取两个时间相差的天数，$time2 - $time1，如果 $time2 为空，使用当前时间计算
function get_diff_days($time1, $time2 = '')
{
  if (is_string($time1))
    $time1 = strtotime($time1);
  if ($time2 == '')
    $time2 = time();
  elseif (is_string($time2))
    $time2 = strtotime($time2);
  return floor(($time2 - $time1) / 60 / 60 / 24);
}

// 验证是格式有效的 Email 地址
function is_valid_email($email)
{
  $result = isset($email) && strstr($email, '@') &&
    ($email == addslashes($email)) && ($email == htmlspecialchars($email));
  return $result;
}

// 取用户提交的参数
function get_request($name, $default = '', $valid = '', $delete_ctrlchar = true)
{
  $result = $_REQUEST[$name];
  if (empty($result) || ($valid != '') && ($result != $valid))
    $result = $default;
  // 过滤掉不安全的控制字符
  if ($delete_ctrlchar)
    $result = preg_replace("[;_'<>\"]", "", $result);
  return $result;
}

// 取用户提交的整数参数
function get_int_request($name, $default = '', $valid = '', $delete_ctrlchar = true)
{
  return (integer) get_request($name, $default, $valid, $delete_ctrlchar);
}

// 返回带语言参数的输出链接
function get_link($link)
{
  global $lang;
  if (ereg("([?&]{1})lang=", $link) || strstr($link, "://")) {
    // 已经包含语言参数的或链接到其它地方的不修改
  	return $link;
  } else {
    if (strstr($link, "?"))
      return $link."&lang=".$lang;
    else
      return $link."?lang=".$lang;
  }
}

// 输出带换行符的文本
function output($html = '')
{
  echo $html."\n";
}

// 输出一个链接
function output_url($url, $text = '', $head = '', $tail = '')
{
  if ($text == '')
    $text = $url;
  echo "$head<a href=\"$url\">".$text."</a>$tail";
}

// 输出 JavaScript 对话框信息
function output_alert($msg = '')
{
  echo "<script type=\"text/javascript\">\n".
       "<!--\n".
       "alert(\"".$msg."\");\n".
       "-->\n".
       "</script>\n";
}

// 提示错误信息返回
function halt($msg = '')
{
  global $g_lang;
  output("<hr>");
  output("<font size=3><b>".$g_lang['Error']."</b></font><p>");
  output($msg."<br>");
  output("<hr>");
  output('<input type="button" value="'.$g_lang['Back'].'" onclick="javascript:history.back();">');
  exit();
}

//==============================================================================
// 调试相关公共函数
//==============================================================================

// 输出调试信息
function debug_output($msg)
{
  global $debug;
	if (isset($debug) && $debug != 0)
		echo $msg."<br>\n";
}

// 检查传递的值，是否有？是否为空？
function filled_out($form_vars, $check_has_vars = 0)
{
  // 检查变量一定要有
  if ( 0 == count($form_vars) && $check_has_vars == 1)
    return false;

  // 检查每个变量一定要存在，而且要赋值
  foreach ($form_vars as $key => $value)
  {
  	 debug_output("$key = $value");
     if (!isset($key) || ($value == ""))
        return false;
  }
  return true;
}

// dump_array 输出数组变量内容
// $array     要输出的数组变量
// to represent the array as a set
function dump_array($array)
{
  if(is_array($array))
  {
    $size = count($array);
    $string = "";
    if($size)
    {
      $count = 0;
      $string .= "{ ";
      // add each element's key and value to the string
      foreach($array as $var => $value)
      {
        $string .= "$var = '$value'";
        if($count++ < ($size-1))
        {
          $string .= ", ";
        }
      }
      $string .= " }";
    }
    return $string;
  }
  else
  {
    // 如果不是数组，则返回变量
    return $array;
  }
}

function dump_sys_vars()
{
  global $HTTP_GET_VARS;
  global $HTTP_POST_VARS;
  global $HTTP_POST_FILES;
  global $HTTP_SESSION_VARS;
  global $HTTP_COOKIE_VARS;

  return "\n<!-- BEGIN VARIABLE DUMP -->\n\n".
         "<!-- BEGIN GET VARS -->\n".
         
         "<!-- ".dump_array($HTTP_GET_VARS)." -->\n".
         "<!-- BEGIN POST VARS -->\n".
         
         "<!-- ".dump_array($HTTP_POST_VARS)." -->\n".
         "<!-- BEGIN POST FILES -->\n".
         
         "<!-- ".dump_array($HTTP_POST_FILES)." -->\n".
         "<!-- BEGIN SESSION VARS -->\n".
         
         "<!-- ".dump_array($HTTP_SESSION_VARS)." -->\n".
         "<!-- BEGIN COOKIE VARS -->\n".
         
         "<!-- ".dump_array($HTTP_COOKIE_VARS)." -->\n".
         "\n<!-- END VARIABLE DUMP -->\n";
}

// output_vars 显示常用的数组变量
function output_vars()
{
  echo dump_sys_vars();
}

// user_error_handler 自定义错误处理函数
// $errno 	错误编号
// $errstr  错误信息
function user_error_handler ($errno, $errstr)
{
  echo "<table bgcolor = '#cccccc'><tr><td>
        <P><B>ERROR:</B> $errstr
        <P>Please try again, or contact us and tell us that
        the error occurred in line ".__LINE__." of file '".__FILE__."'";
  if ($errno == E_USER_ERROR||$errno == E_ERROR)
  {
    echo "<P>This error was fatal, program ending";
    echo "</td></tr></table><br>";
    exit;
  }
  echo "</td></tr></table><br>";
}

// 产生随机数
function rndkey($lng){
 $char_list = array();
 $char_list[] = "1234567890";
 $char_list[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
 $char_list[] = "abcdefghijklmnopqrstuvwxyz";
 $char_list[] = "!@^()_:+\-";
 $char_length = count($char_list);
 $rnd_Key = "";
 for($i=1; $i<=$lng; $i++){
  $rnd_Str  = $char_list[rand(1,$char_length) - 1];
  $rnd_Key .= substr($rnd_Str, rand(0,strlen($rnd_Str)-1), 1);
 }
 return($rnd_Key);
}

// 用户数据库类
class db extends DB_Sql 
{
  function db($query = "")
  {
    global $g_sys_vars;
    global $debug;
    $this->Debug = $debug;
    $this->Host = $g_sys_vars['dbhost'];
    $this->Database = $g_sys_vars['dbname'];
    $this->User = $g_sys_vars['dbuser'];
    $this->Password = $g_sys_vars['dbpasswd'];
    
    $this->DB_Sql($query);
  }
  
  function halt($msg)
  {
    global $g_lang;
    if ($this->Debug)
      halt(printf($g_lang['DatabaseErrorDebug'], $msg, $this->Errno, $this->Error));
    else 
      halt($g_lang['DatabaseError']);
  }
}

?>