#!/usr/bin/env python
# coding=utf-8
#
# Copyright 2009 CnPack Team
#
# Author: Zhou Jingyu (zjy@cnpack.org)
#

import os
import cgi
import re
import datetime
import cndef
import wsgiref.handlers

from google.appengine.ext import db
from google.appengine.ext import webapp

class CnWizards(webapp.RequestHandler):

  def getReq(self, ident, default='none'):
    ret = self.request.get(ident)
    if ret == '':
      ret = default
    else:
      p = re.compile('[^a-zA-Z0-9_.\-]')
      if p.search(ret):
        ret = default
    return ret

  def incLog(self, ipaddr, now, ide, ver, code, lang):
    log = cndef.CWLogs(ipaddr=ipaddr, date=now, ide=ide, ver=ver, code=code, lang=lang)
    log.put()
    
  def incTemp(self, now, ide, ver, code, lang):
    rec = db.get(db.Key.from_path('CWConfig', 'D:Temp'))
    if (not rec) or (rec.value == '1'):
      Temp = cndef.CWTemp1(date=now, ide=ide, ver=ver, code=code, lang=lang)
    else:
      Temp = cndef.CWTemp2(date=now, ide=ide, ver=ver, code=code, lang=lang)
    Temp.put()

  def incCntHour(self, date, hour):
    rec = db.get(db.Key.from_path('CWCntHour', 'D:%s:%d' % (date, hour)))
    if not rec:
        rec = cndef.CWCntHour(date=date, hour=hour, count=1, key_name='D:%s:%d' % (date, hour))
    else:
        rec.count += 1
    rec.put()

  def incCntMonth(self, date_month):
    rec = db.get(db.Key.from_path('CWCntMonth', 'D:%s' % (date_month)))
    if not rec:
        rec = cndef.CWCntMonth(date=date_month, count=1, key_name='D:%s' % (date_month))
    else:
        rec.count += 1
    rec.put()

  def incCntUnion(self, date_month, ide, ver, code):
    rec = db.get(db.Key.from_path('CWCntUnion', 'D:%s:%s:%s:%s' % (date_month, ide, ver, code)))
    if not rec:
        rec = cndef.CWCntUnion(date=date_month, ide=ide, ver=ver, code=code, count=1, key_name='D:%s:%s:%s:%s' % (date_month, ide, ver, code))
    else:
        rec.count += 1
    rec.put()

  def outDatafile(self, fname):
    f = file(fname)
    while True:
        line = f.readline()
        if len(line) == 0: # Zero length indicates EOF
            break
        self.response.out.write(line)
    f.close() # close the file

  def get(self):
    # Use bin type to avoid utf-8 encoding error.
    self.response.headers["Content-Type"] = "application/octet-stream"
    self.outDatafile('cnwizards/update.ini')

    try:
      now = datetime.datetime.now() + datetime.timedelta(hours = 8)
      today = datetime.date(now.year, now.month, now.day)
      date_month = datetime.date(now.year, now.month, 1)
      alldate = datetime.date.min
  
      if self.request.get('month') == '1':
        db.run_in_transaction(self.incCntMonth, date_month)
  
      if self.request.get('manual') == '1':
        return
  
      db.run_in_transaction(self.incCntHour, today, now.hour)
      db.run_in_transaction(self.incCntHour, alldate, now.hour)

      ipaddr = os.environ['REMOTE_ADDR']
      ide = self.getReq('ide')
      ver = self.getReq('ver')
      code = cndef.country_code_by_addr(ipaddr)
      lang = self.getReq('langid')
  
      self.incLog(ipaddr, now, ide, ver, code, lang)
      self.incTemp(now, ide, ver, code, lang)
  
      db.run_in_transaction(self.incCntUnion, alldate, ide, ver, code)
      db.run_in_transaction(self.incCntUnion, date_month, ide, ver, code)
    except:
      return

def main():
  application = webapp.WSGIApplication([
    ('/cnwizards/', CnWizards)
], debug=True)

  wsgiref.handlers.CGIHandler().run(application)

if __name__ == '__main__':
  main()
