#!/usr/bin/env python
# coding=utf-8
#
# Copyright 2009 CnPack Team
#
# Author: Zhou Jingyu (zjy@cnpack.org)
#

import os
import cgi
import datetime
import cndef
import wsgiref.handlers

from google.appengine.ext import db
from google.appengine.ext import webapp

class DelOldPage(webapp.RequestHandler):

  def get(self):
    adate = datetime.datetime.now() - datetime.timedelta(hours = 30 * 24)
    dset = db.GqlQuery("SELECT * "
                       "FROM CWLogs "
                       "WHERE date < :1 "
                       "ORDER BY date "
                       "LIMIT 0, 100", adate)
    if dset:
      for rec in dset:
        rec.delete()
      self.response.out.write('''
<head>
<meta http-equiv="refresh" content="1;url=/tasks/delold/">
</head>
<body>''')
      self.response.out.write('deleting old data...')
    else:
      self.response.out.write('delete nothing')

class CronDelOldPage(webapp.RequestHandler):

  def get(self):
    adate = datetime.datetime.now() - datetime.timedelta(hours = 30 * 24)
    dset = db.GqlQuery("SELECT * "
                       "FROM CWLogs "
                       "WHERE date < :1 "
                       "ORDER BY date "
                       "LIMIT 0, 100", adate)
    if dset:
      for rec in dset:
        rec.delete()

class CronStatPage(webapp.RequestHandler):

  def addToDict(self, name, value):
    rec = db.get(db.Key.from_path('CWDictionary', 'D:%s:%s' % (name, value)))
    if not rec:
      rec = cndef.CWDictionary(name=name, value=value, key_name='D:%s:%s' % (name, value))
      rec.put()

  def incCntHour(self, date, hour, count):
    rec = db.get(db.Key.from_path('CWCntHour', 'D:%s:%d' % (date, hour)))
    if not rec:
        rec = cndef.CWCntHour(date=date, hour=hour, count=count, key_name='D:%s:%d' % (date, hour))
    else:
        rec.count += count
    rec.put()

  def incCntIde(self, date, ide, count):
    rec = db.get(db.Key.from_path('CWCntIde', 'D:%s:%s' % (date, ide)))
    if not rec:
        rec = cndef.CWCntIde(date=date, ide=ide, count=count, key_name='D:%s:%s' % (date, ide))
    else:
        rec.count += count
    rec.put()

  def incCntVer(self, date, ver, count):
    rec = db.get(db.Key.from_path('CWCntVer', 'D:%s:%s' % (date, ver)))
    if not rec:
        rec = cndef.CWCntVer(date=date, ver=ver, count=count, key_name='D:%s:%s' % (date, ver))
    else:
        rec.count += count
    rec.put()

  def incCntCountry(self, date, code, count):
    rec = db.get(db.Key.from_path('CWCntCountry', 'D:%s:%s' % (date, code)))
    if not rec:
        rec = cndef.CWCntCountry(date=date, code=code, count=count, key_name='D:%s:%s' % (date, code))
    else:
        rec.count += count
    rec.put()

  def incCntLang(self, date, lang, count):
    rec = db.get(db.Key.from_path('CWCntLang', 'D:%s:%s' % (date, lang)))
    if not rec:
        rec = cndef.CWCntLang(date=date, lang=lang, count=count, key_name='D:%s:%s' % (date, lang))
    else:
        rec.count += count
    rec.put()

  def incCntUnion(self, date_month, ide, ver, code, count):
    rec = db.get(db.Key.from_path('CWCntUnion', 'D:%s:%s:%s:%s' % (date_month, ide, ver, code)))
    if not rec:
        rec = cndef.CWCntUnion(date=date_month, ide=ide, ver=ver, code=code, count=count, key_name='D:%s:%s:%s:%s' % (date_month, ide, ver, code))
    else:
        rec.count += count
    rec.put()

  def changeTempTable(self):
    rec = db.get(db.Key.from_path('CWConfig', 'D:Temp'))
    if not rec:
      rec = cndef.CWConfig(name='Temp', value='2', key_name='D:Temp')
      ret = 'CWTemp1'
    elif rec.value == '1':
      rec.value = '2'
      ret = 'CWTemp1'
    else:
      rec.value = '1'
      ret = 'CWTemp2'
    rec.put()
    return ret

  def get(self):
    tmp = self.changeTempTable()
    dset = db.GqlQuery("SELECT * "
                       "FROM %s "
                       "ORDER BY date "
                       "LIMIT 0, 200" % (tmp))
    if not dset:
      return

    alldate = datetime.date.min

    lstDate = []
    lstIde = []
    lstVer = []
    lstCode = []
    lstLang = []
    for rec in dset:
      lstDate.append(rec.date)
      lstIde.append(rec.ide)
      lstVer.append(rec.ver)
      lstCode.append(rec.code)
      lstLang.append(rec.lang)
      rec.delete()

    lstTmp = []
    for date in lstDate:
      date_month = datetime.date(date.year, date.month, 1)
      if lstTmp.count(date_month) == 0:
        lstTmp.append(date_month)
        db.run_in_transaction(self.addToDict, 'month', '%d' % (date_month.year * 100 + date_month.month))

    lstTmp = []
    for ide in lstIde:
      if lstTmp.count(ide) == 0:
        lstTmp.append(ide)
        db.run_in_transaction(self.addToDict, 'ide', ide)

    lstTmp = []
    for ver in lstVer:
      if lstTmp.count(ver) == 0:
        lstTmp.append(ver)
        db.run_in_transaction(self.addToDict, 'ver', ver)

    lstTmp = []
    for code in lstCode:
      if lstTmp.count(code) == 0:
        lstTmp.append(code)
        db.run_in_transaction(self.addToDict, 'code', code)

    lstTmp = []
    for lang in lstLang:
      if lstTmp.count(lang) == 0:
        lstTmp.append(lang)
        db.run_in_transaction(self.addToDict, 'lang', lang)

    while len(lstDate) > 0:
      date = datetime.date(lstDate[0].year, lstDate[0].month, lstDate[0].day)
      dicHour = {}
      dicIde = {}
      dicVer = {}
      dicCode = {}
      dicLang = {}
      for i in range(len(lstDate) - 1, -1, -1):
        if date == datetime.date(lstDate[i].year, lstDate[i].month, lstDate[i].day):
          hour = lstDate[i].hour
          if dicHour.has_key(hour):
            dicHour[hour] = dicHour[hour] + 1
          else:
            dicHour[hour] = 1

          ide = lstIde[i]
          if dicIde.has_key(ide):
            dicIde[ide] = dicIde[ide] + 1
          else:
            dicIde[ide] = 1

          ver = lstVer[i]
          if dicVer.has_key(ver):
            dicVer[ver] = dicVer[ver] + 1
          else:
            dicVer[ver] = 1

          code = lstCode[i]
          if dicCode.has_key(code):
            dicCode[code] = dicCode[code] + 1
          else:
            dicCode[code] = 1

          lang = lstLang[i]
          if dicLang.has_key(lang):
            dicLang[lang] = dicLang[lang] + 1
          else:
            dicLang[lang] = 1

          del lstDate[i]
          del lstIde[i]
          del lstVer[i]
          del lstCode[i]
          del lstLang[i]

      for hour, count in dicHour.items():
        db.run_in_transaction(self.incCntHour, alldate, hour, count)
        db.run_in_transaction(self.incCntHour, date, hour, count)

      for ide, count in dicIde.items():
        db.run_in_transaction(self.incCntIde, alldate, ide, count)
        db.run_in_transaction(self.incCntIde, date, ide, count)

      for ver, count in dicVer.items():
        db.run_in_transaction(self.incCntVer, alldate, ver, count)
        db.run_in_transaction(self.incCntVer, date, ver, count)

      for code, count in dicCode.items():
        db.run_in_transaction(self.incCntCountry, alldate, code, count)
        db.run_in_transaction(self.incCntCountry, date, code, count)

      for lang, count in dicLang.items():
        db.run_in_transaction(self.incCntLang, alldate, lang, count)
        db.run_in_transaction(self.incCntLang, date, lang, count)

def main():
  application = webapp.WSGIApplication([
    ('/tasks/delold/', DelOldPage),
    ('/tasks/crondelold/', CronDelOldPage),
    ('/tasks/cronstat/', CronStatPage)
], debug=True)

  wsgiref.handlers.CGIHandler().run(application)

if __name__ == '__main__':
  main()
