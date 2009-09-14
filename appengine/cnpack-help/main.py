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
import wsgiref.handlers

from google.appengine.ext import webapp

class MainPage(webapp.RequestHandler):
  
  def get(self):
    self.response.out.write('test')

class CWPage(webapp.RequestHandler):
  
  def get(self):
    # CnWizards_CHS.chm::/cnpack/about.htm =>
    # http://cnpack.googlecode.com/svn/trunk/cnwizards/Help/CnWizards_CHS/cnpack/about.htm
    path = os.environ['PATH_INFO']
    path = path.replace('/cnwizards/', '', 1)
    path = path.replace('.chm::', '')
    url = 'http://cnpack.googlecode.com/svn/trunk/cnwizards/Help/%s' % path
    self.redirect(url)

def main():
  application = webapp.WSGIApplication([
    ('/', MainPage),
    ('/cnwizards/.*', CWPage)
], debug=True)

  wsgiref.handlers.CGIHandler().run(application)

if __name__ == '__main__':
  main()
