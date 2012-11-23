#!/usr/bin/env python
# coding=utf-8
#
# Copyright 2001-2010 CnPack Team
#
# Author: Zhou Jingyu (zjy@cnpack.org)
#

import os
import cgi
import datetime
import cndef
import config
import wsgiref.handlers

from google.appengine.ext import db
from google.appengine.ext import webapp

def atoi(s, default = 0):
  try:
    return int(s)
  except:
    return default

def toStr(s):
  if s != '':
    return s.encode('utf-8')
  else:
    return ''

def toUrl(field, value, s):
  return ('<a href="/view/?kind=7&field=%s&value=%s">%s</a>' %
    (toStr(field), toStr(value), toStr(s)))

def ideUrl(ide):
  return toUrl('ide', ide, ide)

def verUrl(ver):
  return toUrl('ver', ver, ver)

def codeUrl(code):
  if not (code and code != ''):
    code = '--'
  return toUrl('code', code, cndef.country_name_by_code(code))

def langUrl(lang):
  if not (lang and lang != ''):
    lang = 'none'
  return toUrl('lang', lang, cndef.lang_name_by_id(lang))

def ipUrl(ipaddr):
  return toUrl('ipaddr', ipaddr, ipaddr)

class ViewPage(webapp.RequestHandler):

  def getint(self, ident, default=0):
    return atoi(self.request.get(ident), default)

  def outStr(self, s):
    self.response.out.write(s)

  def getPercent(self, v, sum):
    if v > 0:
      return '&nbsp;(%3.1f%%)' % (v * 100.0 / sum)
    else:
      return ''

  def getMax(self, lst):
    if len(lst) == 0:
      return 0
    ret = max(lst)
    if ret < 1:
      ret = 1
    return ret

  def getSum(self, lst):
    ret = 0
    for i in lst:
      ret += i
    return ret

  def getChsWeekDay(self, date):
    dname = ['一', '二', '三', '四', '五', '六', '日']
    return dname[date.isoweekday() - 1]

  def getDateStr(self, date):
    return '%s (星期%s)' % (date, self.getChsWeekDay(date))

  def outHead(self):
    self.outStr('''
<html>

<head>
<meta http-equiv="Content-Type" content="text/html"; charset=utf-8>
<link rel="stylesheet" href="/css/style_zh-cn.css" type="text/css">
<title>CnWizards 用户统计数据</title>
</head>

<body>

<table width="770" align="center" border="0" cellpadding="0" cellspacing="0">
  <tr><td align="center"><b><font size="3">CnWizards 用户统计数据</font></b></td></tr>
  <tr><td><hr></td></tr>
  <tr><td>
<br>
统计方式：
<a href="/view/?kind=0">按日统计</a>
<a href="/view/?kind=1">按月统计</a>
<a href="/view/?kind=2">时段统计</a>
<a href="/view/?kind=3">IDE 统计</a>
<a href="/view/?kind=4">版本统计</a>
<a href="/view/?kind=5">区域统计</a>
<a href="/view/?kind=9">语言统计</a>
<a href="/view/?kind=8">组合查询</a>
<a href="/view/?kind=6">日志查看</a>
<br>
<br>''')

  def outFoot(self):
    self.outStr('''
<div align="center">
  <table border=0 width=770 height=20 cellspacing=0 cellpadding=0>
    <tr><td><hr></td></tr>
  </table>
  <table border=0 width=770 height=20 cellspacing=0 cellpadding=0>
    <tr><td align="center">版权所有(C) 2001-2010 <a href="mailto:master@cnpack.org">CnPack 开发组</a></td></tr>
    <tr><td align="center">程序编写：<a href="mailto:zjy@cnpack.org">周劲羽</a></td></tr>
    <tr><td align="center">由 Google App Engine 提供支持</td></tr>
  </table>
</div>

</body>

</html>''')

  def outDay(self):
    num = 30
    cnt = [0 for x in range(num)]
    date = self.today - datetime.timedelta(self.offset * num)
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntHour "
                       "WHERE date <= :1 AND date > :2",
                       date, date - datetime.timedelta(num))
    for rec in dset:
      delta = date - rec.date
      cnt[delta.days] += rec.count

    cmax = self.getMax(cnt)

    self.outStr('日统计数据：')
    self.outStr('<a href="/view/?kind=0&offset=%d">前一页</a>&nbsp;' % (self.offset + 1))
    self.outStr('<a href="/view/?kind=0&offset=0">今天</a>&nbsp;')
    if self.offset >= 1:
      self.outStr('<a href="/view/?kind=0&offset=%d">后一页</a>&nbsp;' % (self.offset - 1))
    self.outStr('''
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="10%">日期</td>
    <td width="5%">星期</td>
    <td width="35%">访问量</td>
    <td width="10%">日期</td>
    <td width="5%">星期</td>
    <td width="35%">访问量</td>
  </tr>''')

    for i in range(num):
      if i % 2 == 0:
        self.outStr('<tr>')
        idx = i / 2
      else:
        idx = (i + num) / 2
      cd = date - datetime.timedelta(idx)
      self.outStr("<td>&nbsp;%s</td><td>&nbsp;%s</td><td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d</td>" %
        (cd, self.getChsWeekDay(cd), cnt[idx], cnt[idx] * 200 / cmax, cnt[idx]))
      if i % 2 == 1:
        self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def monthDelta(self, date, delta):
    m = date.month - 1
    return datetime.date(date.year + (m + delta) / 12, (m + delta) % 12 + 1, date.day)

  def outMonth(self):
    date = datetime.date(self.today.year, self.today.month, 1)
    num = 24
    mcnt = [0 for x in range(num)]
    mdays = [0 for x in range(num)]
    maver = [0 for x in range(num)]
    mact = [0 for x in range(num)]
    for i in range(num):
      d1 = self.monthDelta(date, 1 - i)
      d2 = self.monthDelta(date, -i)
      if (d2.year == self.today.year) and (d2.month == self.today.month):
        mdays[i] = (self.today - d2).days + 1
      else:
        mdays[i] = (d1 - d2).days
      dset = db.GqlQuery("SELECT * "
                         "FROM CWCntHour "
                         "WHERE date < :1 AND date >= :2",
                         d1, d2)
      for rec in dset:
        mcnt[i] += rec.count
      maver[i] = mcnt[i] / mdays[i]

      d1 = datetime.date(d2.year, d2.month, 1)
      dset = db.GqlQuery("SELECT * "
                         "FROM CWCntMonth "
                         "WHERE date = :1",
                         d1)
      rec = dset.get();
      if rec:
        mact[i] = rec.count

    cmax = self.getMax(mact)

    self.outStr('''
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
  </tr>''')

    for i in range(num):
      if i % 2 == 0:
        self.outStr('<tr>')
        idx = i / 2
      else:
        idx = (i + num) / 2
      cd = self.monthDelta(date, -idx)
      self.outStr("<td>&nbsp;%d-%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d</td>" %
        (cd.year, cd.month, mcnt[idx], maver[idx], mact[idx], mact[idx] * 170 / cmax, mact[idx]))
      if i % 2 == 1:
        self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def outHour(self):
    date = self.today - datetime.timedelta(self.offset)
    cntall = [0 for x in range(24)]
    cntday = [0 for x in range(24)]
    cntlast = [0 for x in range(24)]

    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntHour "
                       "WHERE date = :1",
                       self.alldate)
    for rec in dset:
      cntall[rec.hour] = rec.count

    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntHour "
                       "WHERE date = :1",
                       date)
    for rec in dset:
      cntday[rec.hour] = rec.count

    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntHour "
                       "WHERE date = :1",
                       date - datetime.timedelta(1))
    for rec in dset:
      cntlast[rec.hour] = rec.count

    allmax = self.getMax(cntall)
    allsum = self.getSum(cntall)
    daymax = self.getMax(cntday)
    daysum = self.getSum(cntday)
    lastmax = self.getMax(cntlast)
    lastsum = self.getSum(cntlast)

    self.outStr('时段统计数据：')
    self.outStr('<a href="/view/?kind=2&offset=%d">前一天</a>&nbsp;' % (self.offset + 1))
    self.outStr('<a href="/view/?kind=2&offset=0">今天</a>&nbsp;')
    if self.offset >= 1:
      self.outStr('<a href="/view/?kind=2&offset=%d">后一天</a>&nbsp;' % (self.offset - 1))
    self.outStr('''
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="6%">时段</td>
    <td width="32%">所有日期数据</td>''')
    self.outStr('<td width="31%%">%s</td><td width="31%%">%s</td></tr>' %
      (self.getDateStr(date - datetime.timedelta(1)), self.getDateStr(date)))
    self.outStr("<tr><td>全部</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td></tr>" %
      (allsum, lastsum, daysum))

    for i in range(24):
      self.outStr('<tr>')
      self.outStr("<td>&nbsp;%d</td><td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (i, cntall[i], cntall[i] * 130 / allmax, cntall[i], self.getPercent(cntall[i], allsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntlast[i], cntlast[i] * 130 / lastmax, cntlast[i], self.getPercent(cntlast[i], lastsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntday[i], cntday[i] * 130 / daymax, cntday[i], self.getPercent(cntday[i], daysum)))
      self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def outIde(self):
    date = self.today - datetime.timedelta(self.offset)
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntIde "
                       "WHERE date = :1 ORDER BY count DESC",
                       self.alldate)
    ides = []
    cntall = []
    for rec in dset:
      ides.append(rec.ide)
      cntall.append(rec.count)

    cntday = [0 for x in range(len(ides))]
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntIde "
                       "WHERE date = :1",
                       date)
    for rec in dset:
      if ides.count(rec.ide) > 0:
        cntday[ides.index(rec.ide)] = rec.count

    cntlast = [0 for x in range(len(ides))]
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntIde "
                       "WHERE date = :1",
                       date - datetime.timedelta(1))
    for rec in dset:
      if ides.count(rec.ide) > 0:
        cntlast[ides.index(rec.ide)] = rec.count

    allmax = self.getMax(cntall)
    allsum = self.getSum(cntall)
    daymax = self.getMax(cntday)
    daysum = self.getSum(cntday)
    lastmax = self.getMax(cntlast)
    lastsum = self.getSum(cntlast)

    self.outStr('IDE 统计数据：')
    self.outStr('<a href="/view/?kind=3&offset=%d">前一天</a>&nbsp;' % (self.offset + 1))
    self.outStr('<a href="/view/?kind=3&offset=0">今天</a>&nbsp;')
    if self.offset >= 1:
      self.outStr('<a href="/view/?kind=3&offset=%d">后一天</a>&nbsp;' % (self.offset - 1))
    self.outStr('''
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="16%">IDE</td>
    <td width="29%">所有日期数据</td>''')
    self.outStr('<td width="28%%">%s</td><td width="28%%">%s</td></tr>' %
      (self.getDateStr(date - datetime.timedelta(1)), self.getDateStr(date)))
    self.outStr("<tr><td>全部</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td></tr>" %
      (allsum, lastsum, daysum))

    for i in range(len(ides)):
      self.outStr('<tr>')
      self.outStr("<td>&nbsp;%s</td><td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (ideUrl(ides[i]), cntall[i], cntall[i] * 110 / allmax, cntall[i], self.getPercent(cntall[i], allsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntlast[i], cntlast[i] * 110 / lastmax, cntlast[i], self.getPercent(cntlast[i], lastsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntday[i], cntday[i] * 110 / daymax, cntday[i], self.getPercent(cntday[i], daysum)))
      self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def outVer(self):
    date = self.today - datetime.timedelta(self.offset)
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntVer "
                       "WHERE date = :1 ORDER BY count DESC",
                       self.alldate)
    vers = []
    cntall = []
    for rec in dset:
      vers.append(rec.ver)
      cntall.append(rec.count)

    cntday = [0 for x in range(len(vers))]
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntVer "
                       "WHERE date = :1",
                       date)
    for rec in dset:
      if vers.count(rec.ver) > 0:
        cntday[vers.index(rec.ver)] = rec.count

    cntlast = [0 for x in range(len(vers))]
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntVer "
                       "WHERE date = :1",
                       date - datetime.timedelta(1))
    for rec in dset:
      if vers.count(rec.ver) > 0:
        cntlast[vers.index(rec.ver)] = rec.count

    allmax = self.getMax(cntall)
    allsum = self.getSum(cntall)
    daymax = self.getMax(cntday)
    daysum = self.getSum(cntday)
    lastmax = self.getMax(cntlast)
    lastsum = self.getSum(cntlast)

    self.outStr('版本统计数据：')
    self.outStr('<a href="/view/?kind=4&offset=%d">前一天</a>&nbsp;' % (self.offset + 1))
    self.outStr('<a href="/view/?kind=4&offset=0">今天</a>&nbsp;')
    if self.offset >= 1:
      self.outStr('<a href="/view/?kind=4&offset=%d">后一天</a>&nbsp;' % (self.offset - 1))
    self.outStr('''
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="15%">版本</td>
    <td width="29%">所有日期数据</td>''')
    self.outStr('<td width="28%%">%s</td><td width="28%%">%s</td></tr>' %
      (self.getDateStr(date - datetime.timedelta(1)), self.getDateStr(date)))
    self.outStr("<tr><td>全部</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td></tr>" %
      (allsum, lastsum, daysum))

    for i in range(len(vers)):
      self.outStr('<tr>')
      self.outStr("<td>&nbsp;%s</td><td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (verUrl(vers[i]), cntall[i], cntall[i] * 120 / allmax, cntall[i], self.getPercent(cntall[i], allsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntlast[i], cntlast[i] * 120 / lastmax, cntlast[i], self.getPercent(cntlast[i], lastsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntday[i], cntday[i] * 120 / daymax, cntday[i], self.getPercent(cntday[i], daysum)))
      self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def outCountry(self):
    date = self.today - datetime.timedelta(self.offset)
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntCountry "
                       "WHERE date = :1 ORDER BY count DESC",
                       self.alldate)
    countrys = []
    cntall = []
    for rec in dset:
      countrys.append(rec.code)
      cntall.append(rec.count)

    cntday = [0 for x in range(len(countrys))]
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntCountry "
                       "WHERE date = :1",
                       date)
    for rec in dset:
      if countrys.count(rec.code) > 0:
        cntday[countrys.index(rec.code)] = rec.count

    cntlast = [0 for x in range(len(countrys))]
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntCountry "
                       "WHERE date = :1",
                       date - datetime.timedelta(1))
    for rec in dset:
      if countrys.count(rec.code) > 0:
        cntlast[countrys.index(rec.code)] = rec.count

    allmax = self.getMax(cntall)
    allsum = self.getSum(cntall)
    daymax = self.getMax(cntday)
    daysum = self.getSum(cntday)
    lastmax = self.getMax(cntlast)
    lastsum = self.getSum(cntlast)

    self.outStr('国家/地区统计数据：')
    self.outStr('<a href="/view/?kind=5&offset=%d">前一天</a>&nbsp;' % (self.offset + 1))
    self.outStr('<a href="/view/?kind=5&offset=0">今天</a>&nbsp;')
    if self.offset >= 1:
      self.outStr('<a href="/view/?kind=5&offset=%d">后一天</a>&nbsp;' % (self.offset - 1))
    self.outStr('''
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="16%">国家/地区</td>
    <td width="28%">所有日期数据</td>''')
    self.outStr('<td width="28%%">%s</td><td width="28%%">%s</td></tr>' %
      (self.getDateStr(date - datetime.timedelta(1)), self.getDateStr(date)))
    self.outStr("<tr><td>全部&nbsp;(%d个)</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td></tr>" %
      (len(countrys), allsum, lastsum, daysum))

    for i in range(len(countrys)):
      self.outStr('<tr>')
      self.outStr("<td>&nbsp;%s</td><td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (codeUrl(countrys[i]), cntall[i], cntall[i] * 110 / allmax, cntall[i], self.getPercent(cntall[i], allsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntlast[i], cntlast[i] * 110 / lastmax, cntlast[i], self.getPercent(cntlast[i], lastsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntday[i], cntday[i] * 110 / daymax, cntday[i], self.getPercent(cntday[i], daysum)))
      self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def outLang(self):
    date = self.today - datetime.timedelta(self.offset)
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntLang "
                       "WHERE date = :1 ORDER BY count DESC",
                       self.alldate)
    Langs = []
    cntall = []
    for rec in dset:
      Langs.append(rec.lang)
      cntall.append(rec.count)

    cntday = [0 for x in range(len(Langs))]
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntLang "
                       "WHERE date = :1",
                       date)
    for rec in dset:
      if Langs.count(rec.lang) > 0:
        cntday[Langs.index(rec.lang)] = rec.count

    cntlast = [0 for x in range(len(Langs))]
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntLang "
                       "WHERE date = :1",
                       date - datetime.timedelta(1))
    for rec in dset:
      if Langs.count(rec.lang) > 0:
        cntlast[Langs.index(rec.lang)] = rec.count

    allmax = self.getMax(cntall)
    allsum = self.getSum(cntall)
    daymax = self.getMax(cntday)
    daysum = self.getSum(cntday)
    lastmax = self.getMax(cntlast)
    lastsum = self.getSum(cntlast)

    self.outStr('语言统计数据：')
    self.outStr('<a href="/view/?kind=9&offset=%d">前一天</a>&nbsp;' % (self.offset + 1))
    self.outStr('<a href="/view/?kind=9&offset=0">今天</a>&nbsp;')
    if self.offset >= 1:
      self.outStr('<a href="/view/?kind=9&offset=%d">后一天</a>&nbsp;' % (self.offset - 1))
    self.outStr('''
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="16%">语言</td>
    <td width="28%">所有日期数据</td>''')
    self.outStr('<td width="28%%">%s</td><td width="28%%">%s</td></tr>' %
      (self.getDateStr(date - datetime.timedelta(1)), self.getDateStr(date)))
    self.outStr("<tr><td>全部&nbsp;(%d个)</td><td>&nbsp;%d</td><td>&nbsp;%d</td><td>&nbsp;%d</td></tr>" %
      (len(Langs), allsum, lastsum, daysum))

    for i in range(len(Langs)):
      self.outStr('<tr>')
      self.outStr("<td>&nbsp;%s</td><td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (langUrl(Langs[i]), cntall[i], cntall[i] * 110 / allmax, cntall[i], self.getPercent(cntall[i], allsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntlast[i], cntlast[i] * 110 / lastmax, cntlast[i], self.getPercent(cntlast[i], lastsum)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (cntday[i], cntday[i] * 110 / daymax, cntday[i], self.getPercent(cntday[i], daysum)))
      self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def outLog(self):
    num = 20
    min = self.getint('min')
    date = self.now - datetime.timedelta(minutes = min * 10)
    if min == 0:
	    dset = db.GqlQuery("SELECT * "
	                       "FROM CWLogs "
	                       "ORDER BY date DESC "
	                       "LIMIT %d, %d" % (self.offset * num, num))
    else:
	    dset = db.GqlQuery("SELECT * "
	                       "FROM CWLogs "
	                       "WHERE date <= :1 ORDER BY date DESC "
	                       "LIMIT %d, %d" % (self.offset * num, num), date)

    self.outStr('日志查看：')
    self.outStr('<a href="/view/?kind=6&offset=%d&min=%d">前十分钟</a>&nbsp;' % (self.offset, min + 1))
    self.outStr('<a href="/view/?kind=6&offset=%d&min=%d">前一页</a>&nbsp;' % (self.offset + 1, min))
    self.outStr('<a href="/view/?kind=6&offset=0&min=0">当前</a>&nbsp;')
    if self.offset >= 1:
      self.outStr('<a href="/view/?kind=6&offset=%d&min=%d">后一页</a>&nbsp;' % (self.offset - 1, min))
    if min >= 1:
      self.outStr('<a href="/view/?kind=6&offset=%d&min=%d">后十分钟</a>&nbsp;' % (self.offset, min - 1))
    self.outStr('''
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="20%">时间</td>
    <td width="12%">IP地址</td>
    <td width="28%">国家/地区</td>
    <td width="12%">语言</td>
    <td width="14%">IDE</td>
    <td width="14%">版本号</td>''')

    for rec in dset:
      self.outStr('<tr>')
      self.outStr('<td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>' %
        (rec.date, ipUrl(rec.ipaddr), codeUrl(rec.code), langUrl(rec.lang), ideUrl(rec.ide), verUrl(rec.ver)))
      self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def outDetail(self):
    num = 20
    field = self.request.get('field')
    value = self.request.get('value')
    dset = db.GqlQuery("SELECT * "
                       "FROM CWLogs "
                       "WHERE %s = '%s' "
                       "ORDER BY date DESC "
                       "LIMIT %d, %d" % (field, value, self.offset * num, num))

    self.outStr('日志过滤查看：')
    self.outStr('<a href="/view/?kind=7&offset=%d&field=%s&value=%s">前一页</a>&nbsp;' % (self.offset + 1, toStr(field), toStr(value)))
    self.outStr('<a href="/view/?kind=7&offset=0&field=%s&value=%s">当前</a>&nbsp;' % (toStr(field), toStr(value)))
    if self.offset >= 1:
      self.outStr('<a href="/view/?kind=7&offset=%d&field=%s&value=%s">后一页</a>&nbsp;' % (self.offset - 1, toStr(field), toStr(value)))
    self.outStr('''
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="20%">时间</td>
    <td width="12%">IP地址</td>
    <td width="28%">国家/地区</td>
    <td width="12%">语言</td>
    <td width="14%">IDE</td>
    <td width="14%">版本号</td>''')

    for rec in dset:
      self.outStr('<tr>')
      self.outStr('<td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td>' %
        (rec.date, ipUrl(rec.ipaddr), codeUrl(rec.code), langUrl(rec.lang), ideUrl(rec.ide), verUrl(rec.ver)))
      self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def getMonthStr(self, date):
    if date == self.alldate:
      return '全部'
    else:
      return '%s-%s' % (date.year, date.month)
  
  def outQuery(self):
    num = 20
    idate = self.getint('date', 0)
    if idate > 100:
      year = idate / 100
      month = idate % 100
      date = datetime.date(int(year), int(month), 1)
    else:
      date = self.alldate
    ide = self.request.get('ide')
    ver = self.request.get('ver')
    code = self.request.get('code')
    
    self.outStr('条件组合查询：')
    if self.offset >= 1:
      self.outStr('<a href="/view/?kind=8&offset=%d&date=%d&ide=%s&ver=%s&code=%s">上一页</a>&nbsp;' % (self.offset - 1, idate, toStr(ide), toStr(ver), toStr(code)))
    self.outStr('<a href="/view/?kind=8&offset=0&date=%d&ide=%s&ver=%s&code=%s">当前</a>&nbsp;' % (idate, toStr(ide), toStr(ver), toStr(code)))
    self.outStr('<a href="/view/?kind=8&offset=%d&date=%d&ide=%s&ver=%s&code=%s">下一页</a>&nbsp;' % (self.offset + 1, idate, toStr(ide), toStr(ver), toStr(code)))

    self.outStr('''
<form method="get" name="query" action="/view/" class="form">
<input type="hidden" name="kind" value="8">
月份:&nbsp;
<select size="1" name="date">
<option value="">全部</option>''')
    dset = db.GqlQuery("SELECT * "
                       "FROM CWDictionary "
                       "WHERE name = 'month' "
                       "ORDER BY value DESC ")
    for rec in dset:
      ival = atoi(rec.value)
      if ival > 100:
        if ival == idate:
          selected = 'selected'
        else:
          selected = ''
        self.outStr('<option %s value="%d">%d-%d</option>' % (selected, ival, ival / 100, ival % 100))

    self.outStr('''
</select>
&nbsp;&nbsp;国家/地区:&nbsp;
<select size="1" name="code">
<option value="">全部</option>''')
    dset = db.GqlQuery("SELECT * "
                       "FROM CWDictionary "
                       "WHERE name = 'code' "
                       "ORDER BY value ")
    for rec in dset:
      if rec.value == code:
        selected = 'selected'
      else:
        selected = ''
      self.outStr('<option %s value="%s">%s</option>' % (selected, toStr(rec.value), toStr(cndef.country_name_by_code(rec.value))))

    self.outStr('''
</select><br>
IDE:&nbsp;
<select size="1" name="ide">
<option value="">全部</option>''')
    dset = db.GqlQuery("SELECT * "
                       "FROM CWDictionary "
                       "WHERE name = 'ide' "
                       "ORDER BY value ")
    for rec in dset:
      if rec.value == ide:
        selected = 'selected'
      else:
        selected = ''
      self.outStr('<option %s value="%s">%s</option>' % (selected, toStr(rec.value), toStr(rec.value)))

    self.outStr('''
</select>
&nbsp;&nbsp;版本号:&nbsp;
<select size="1" name="ver">
<option value="">全部</option>''')
    dset = db.GqlQuery("SELECT * "
                       "FROM CWDictionary "
                       "WHERE name = 'ver' "
                       "ORDER BY value ")
    for rec in dset:
      if rec.value == ver:
        selected = 'selected'
      else:
        selected = ''
      self.outStr('<option %s value="%s">%s</option>' % (selected, toStr(rec.value), toStr(rec.value)))

    self.outStr('''
</select>
<input type="submit" value="提交" class="btn2">&nbsp;
<input type="reset" value="重置" class="btn2">
</form>''')

    swhere = " WHERE date = :1"
    if date == '':
      date = self.alldate
    if ide != '':
      swhere += " AND ide = '%s'" % (ide)
    if ver != '':
      swhere += " AND ver = '%s'" % (ver)
    if code != '':
      swhere += " AND code = '%s'" % (code)
    dset = db.GqlQuery("SELECT * "
                       "FROM CWCntUnion "
                       "%s "
                       "ORDER BY count DESC "
                       "LIMIT %d, %d" % (swhere, self.offset * num, num), date)
    cntall = []
    for rec in dset:
      cntall.append(rec.count)
    allmax = self.getMax(cntall)
    allsum = self.getSum(cntall)

    self.outStr('''
<table width="100%" align="center" border="1" cellpadding="1" cellspacing="0">
  <tr>
    <td width="8%">月份</td>
    <td width="30%">访问数</td>
    <td width="24%">国家/地区</td>
    <td width="18%">IDE</td>
    <td width="18%">版本号</td>''')

    for rec in dset:
      self.outStr('<tr>')
      self.outStr('<td>%s</td>' % (self.getMonthStr(rec.date)))
      self.outStr("<td>&nbsp;<img src='/image/gauge.gif' alt='%d' width=%d height=7>&nbsp;%d%s</td>" %
        (rec.count, rec.count * 130 / allmax, rec.count, self.getPercent(rec.count, allsum)))
      self.outStr('<td>%s</td><td>%s</td><td>%s</td>' % (codeUrl(rec.code), ideUrl(rec.ide), verUrl(rec.ver)))
      self.outStr('</tr>')
    self.outStr('''
</table>
<br>''')

  def get(self):
    username = ''
    password = ''
    auth = os.environ.get('HTTP_AUTHORIZATION', '')
    if auth:
      scheme, data = auth.split(None, 1)
      assert scheme.lower() == 'basic'
      username, password = data.decode('base64').split(':', 1)

    if (username != config.ADMIN_USER) or (password != config.ADMIN_PASS):
      self.response.headers["WWW-Authenticate"] = 'Basic realm="CnPack Admin Login"'
      self.response.set_status(401)
      self.outStr('Access denied.')
      return
    
    self.now = datetime.datetime.now() + datetime.timedelta(hours = 8)
    self.today = datetime.date(self.now.year, self.now.month, self.now.day)
    self.alldate = datetime.date.min
    self.offset = self.getint('offset')

    self.outHead()

    kind = self.getint('kind')
    if kind == 0:
      self.outDay()
    elif kind == 1:
      self.outMonth()
    elif kind == 2:
      self.outHour()
    elif kind == 3:
      self.outIde()
    elif kind == 4:
      self.outVer()
    elif kind == 5:
      self.outCountry()
    elif kind == 6:
      self.outLog()
    elif kind == 7:
      self.outDetail()
    elif kind == 8:
      self.outQuery()
    elif kind == 9:
      self.outLang()

    self.outFoot()

def main():
  application = webapp.WSGIApplication([
    ('/view/', ViewPage)
], debug=True)

  wsgiref.handlers.CGIHandler().run(application)

if __name__ == '__main__':
  main()
