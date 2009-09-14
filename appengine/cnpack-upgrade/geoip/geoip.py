#!/usr/bin/env python
# coding=utf-8
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import os
import cgi
import datetime
import wsgiref.handlers

from google.appengine.ext import db
from google.appengine.ext import webapp

# Count by Country
class GeoIP(db.Model):
  startip = db.IntegerProperty(required=True)
  endip = db.IntegerProperty(required=True)
  code = db.StringProperty(required=True)

class MainPage(webapp.RequestHandler):
  
  def getint(self, ident, default=0):
    ret = self.request.get(ident)
    if ret == '':
      ret = default
    else:
      ret = int(ret)
    return ret
  
  def get(self):
    fname = self.request.get('fname')
    if fname == '':
      fname = 'geo1.dat'
    offset = self.getint('offset')
    step = self.getint('step', 100)
    
    if self.request.get('view') != '':
	    ips = db.GqlQuery("SELECT * "
	                      "FROM GeoIP ")
	    for ip in ips:
	      self.response.out.write('startip: %d endip: %d code: %s<br>' % (
	        ip.startip, ip.endip, ip.code))
	    return
      
    f = file(fname, 'rb')
    if offset > 0:
      f.seek(offset * 10)
    cnt = 0;
    while True:
        buf = f.read(4)
        if len(buf) == 0:
          self.response.out.write('finished')
          break
        startip = 0l
        for i in range(4):
          startip += ord(buf[i]) << (i * 8)

        buf = f.read(4)
        endip = 0l
        for i in range(4):
          endip += ord(buf[i]) << (i * 8)
          
        code = f.read(2)
        geoip = GeoIP(startip = startip, endip = endip, code = code)
        geoip.put()
        
        cnt += 1
        if cnt == step:
          self.response.out.write('''
<head>
<meta http-equiv="refresh" content="1;url=geoip.py?fname=%s&offset=%d&step=%d">
</head>
<body>''' % (fname, offset + step, step))
          self.response.out.write('process: %s %d..%d' % (fname, offset, offset + step - 1))
          break
    f.close() # close the file 

def main():
  application = webapp.WSGIApplication([
    ('/geoip.py', MainPage),
], debug=True)

  wsgiref.handlers.CGIHandler().run(application)

if __name__ == '__main__':
  main()
