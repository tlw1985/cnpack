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

  def incLog(self, ipaddr, now, ide, ver, code):
    log = cndef.CWLogs(ipaddr=ipaddr, date=now, ide=ide, ver=ver, code=code)
    log.put()

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

  def incCntIde(self, date, ide):
    rec = db.get(db.Key.from_path('CWCntIde', 'D:%s:%s' % (date, ide)))
    if not rec:
        rec = cndef.CWCntIde(date=date, ide=ide, count=1, key_name='D:%s:%s' % (date, ide))
    else:
        rec.count += 1
    rec.put()

  def incCntVer(self, date, ver):
    rec = db.get(db.Key.from_path('CWCntVer', 'D:%s:%s' % (date, ver)))
    if not rec:
        rec = cndef.CWCntVer(date=date, ver=ver, count=1, key_name='D:%s:%s' % (date, ver))
    else:
        rec.count += 1
    rec.put()

  def incCntCountry(self, date, code):
    rec = db.get(db.Key.from_path('CWCntCountry', 'D:%s:%s' % (date, code)))
    if not rec:
        rec = cndef.CWCntCountry(date=date, code=code, count=1, key_name='D:%s:%s' % (date, code))
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

    now = datetime.datetime.now() + datetime.timedelta(hours = 8)
    today = datetime.date(now.year, now.month, now.day)
    date_month = datetime.date(now.year, now.month, 1)
    alldate = datetime.date.min
    ipaddr = os.environ['REMOTE_ADDR']

    if self.request.get('month') == '1':
	    db.run_in_transaction(self.incCntMonth, date_month)

    if self.request.get('manual') == '1':
      return

    ide = self.getReq('ide')
    ver = self.getReq('ver')
    code = cndef.country_code_by_addr(ipaddr)

    self.incLog(ipaddr, now, ide, ver, code)

    db.run_in_transaction(self.incCntHour, alldate, now.hour)
    db.run_in_transaction(self.incCntHour, today, now.hour)

    db.run_in_transaction(self.incCntIde, alldate, ide)
    db.run_in_transaction(self.incCntIde, today, ide)

    db.run_in_transaction(self.incCntVer, alldate, ver)
    db.run_in_transaction(self.incCntVer, today, ver)

    db.run_in_transaction(self.incCntCountry, alldate, code)
    db.run_in_transaction(self.incCntCountry, today, code)

def main():
  application = webapp.WSGIApplication([
    ('/cnwizards/', CnWizards)
], debug=True)

  wsgiref.handlers.CGIHandler().run(application)

if __name__ == '__main__':
  main()
