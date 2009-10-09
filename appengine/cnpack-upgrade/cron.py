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

def main():
  application = webapp.WSGIApplication([
    ('/tasks/delold/', DelOldPage),
    ('/tasks/crondelold/', CronDelOldPage)
], debug=True)

  wsgiref.handlers.CGIHandler().run(application)

if __name__ == '__main__':
  main()
