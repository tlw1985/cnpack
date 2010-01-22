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

from google.appengine.ext import db
from google.appengine.ext import webapp

COUNTRY_CODES = (
    '--', 'AP', 'EU', 'AD', 'AE', 'AF', 'AG', 'AI', 'AL', 'AM', 'AN', 'AO', 'AQ',
    'AR', 'AS', 'AT', 'AU', 'AW', 'AZ', 'BA', 'BB', 'BD', 'BE', 'BF', 'BG', 'BH',
    'BI', 'BJ', 'BM', 'BN', 'BO', 'BR', 'BS', 'BT', 'BV', 'BW', 'BY', 'BZ', 'CA',
    'CC', 'CD', 'CF', 'CG', 'CH', 'CI', 'CK', 'CL', 'CM', 'CN', 'CO', 'CR', 'CU',
    'CV', 'CX', 'CY', 'CZ', 'DE', 'DJ', 'DK', 'DM', 'DO', 'DZ', 'EC', 'EE', 'EG',
    'EH', 'ER', 'ES', 'ET', 'FI', 'FJ', 'FK', 'FM', 'FO', 'FR', 'FX', 'GA', 'GB',
    'GD', 'GE', 'GF', 'GH', 'GI', 'GL', 'GM', 'GN', 'GP', 'GQ', 'GR', 'GS', 'GT',
    'GU', 'GW', 'GY', 'HK', 'HM', 'HN', 'HR', 'HT', 'HU', 'ID', 'IE', 'IL', 'IN',
    'IO', 'IQ', 'IR', 'IS', 'IT', 'JM', 'JO', 'JP', 'KE', 'KG', 'KH', 'KI', 'KM',
    'KN', 'KP', 'KR', 'KW', 'KY', 'KZ', 'LA', 'LB', 'LC', 'LI', 'LK', 'LR', 'LS',
    'LT', 'LU', 'LV', 'LY', 'MA', 'MC', 'MD', 'MG', 'MH', 'MK', 'ML', 'MM', 'MN',
    'MO', 'MP', 'MQ', 'MR', 'MS', 'MT', 'MU', 'MV', 'MW', 'MX', 'MY', 'MZ', 'NA',
    'NC', 'NE', 'NF', 'NG', 'NI', 'NL', 'NO', 'NP', 'NR', 'NU', 'NZ', 'OM', 'PA',
    'PE', 'PF', 'PG', 'PH', 'PK', 'PL', 'PM', 'PN', 'PR', 'PS', 'PT', 'PW', 'PY',
    'QA', 'RE', 'RO', 'RU', 'RW', 'SA', 'SB', 'SC', 'SD', 'SE', 'SG', 'SH', 'SI',
    'SJ', 'SK', 'SL', 'SM', 'SN', 'SO', 'SR', 'ST', 'SV', 'SY', 'SZ', 'TC', 'TD',
    'TF', 'TG', 'TH', 'TJ', 'TK', 'TM', 'TN', 'TO', 'TL', 'TR', 'TT', 'TV', 'TW',
    'TZ', 'UA', 'UG', 'UM', 'US', 'UY', 'UZ', 'VA', 'VC', 'VE', 'VG', 'VI', 'VN',
    'VU', 'WF', 'WS', 'YE', 'YT', 'RS', 'ZA', 'ZM', 'ME', 'ZW', 'A1', 'A2', 'O1',
    'AX', 'GG', 'IM', 'JE', 'BL', 'MF'
    )

COUNTRY_NAMES = (
    "Unknown", "Asia/Pacific Region", "Europe", "Andorra", "United Arab Emirates",
    "Afghanistan", "Antigua and Barbuda", "Anguilla", "Albania", "Armenia",
    "Netherlands Antilles", "Angola", "Antarctica", "Argentina", "American Samoa",
    "Austria", "Australia", "Aruba", "Azerbaijan", "Bosnia and Herzegovina",
    "Barbados", "Bangladesh", "Belgium", "Burkina Faso", "Bulgaria", "Bahrain",
    "Burundi", "Benin", "Bermuda", "Brunei Darussalam", "Bolivia", "Brazil",
    "Bahamas", "Bhutan", "Bouvet Island", "Botswana", "Belarus", "Belize",
    "Canada", "Cocos (Keeling) Islands", "Congo, The Democratic Republic of the",
    "Central African Republic", "Congo", "Switzerland", "Cote D'Ivoire", "Cook Islands",
    "Chile", "Cameroon", "China", "Colombia", "Costa Rica", "Cuba", "Cape Verde",
    "Christmas Island", "Cyprus", "Czech Republic", "Germany", "Djibouti",
    "Denmark", "Dominica", "Dominican Republic", "Algeria", "Ecuador", "Estonia",
    "Egypt", "Western Sahara", "Eritrea", "Spain", "Ethiopia", "Finland", "Fiji",
    "Falkland Islands (Malvinas)", "Micronesia, Federated States of", "Faroe Islands",
    "France", "France, Metropolitan", "Gabon", "United Kingdom",
    "Grenada", "Georgia", "French Guiana", "Ghana", "Gibraltar", "Greenland",
    "Gambia", "Guinea", "Guadeloupe", "Equatorial Guinea", "Greece",
    "South Georgia and the South Sandwich Islands",
    "Guatemala", "Guam", "Guinea-Bissau",
    "Guyana", "Hong Kong", "Heard Island and McDonald Islands", "Honduras",
    "Croatia", "Haiti", "Hungary", "Indonesia", "Ireland", "Israel", "India",
    "British Indian Ocean Territory", "Iraq", "Iran, Islamic Republic of",
    "Iceland", "Italy", "Jamaica", "Jordan", "Japan", "Kenya", "Kyrgyzstan",
    "Cambodia", "Kiribati", "Comoros", "Saint Kitts and Nevis",
    "Korea, Democratic People's Republic of",
    "Korea, Republic of", "Kuwait", "Cayman Islands",
    "Kazakstan", "Lao People's Democratic Republic", "Lebanon", "Saint Lucia",
    "Liechtenstein", "Sri Lanka", "Liberia", "Lesotho", "Lithuania", "Luxembourg",
    "Latvia", "Libyan Arab Jamahiriya", "Morocco", "Monaco", "Moldova, Republic of",
    "Madagascar", "Marshall Islands", "Macedonia",
    "Mali", "Myanmar", "Mongolia", "Macau", "Northern Mariana Islands",
    "Martinique", "Mauritania", "Montserrat", "Malta", "Mauritius", "Maldives",
    "Malawi", "Mexico", "Malaysia", "Mozambique", "Namibia", "New Caledonia",
    "Niger", "Norfolk Island", "Nigeria", "Nicaragua", "Netherlands", "Norway",
    "Nepal", "Nauru", "Niue", "New Zealand", "Oman", "Panama", "Peru", "French Polynesia",
    "Papua New Guinea", "Philippines", "Pakistan", "Poland", "Saint Pierre and Miquelon",
    "Pitcairn Islands", "Puerto Rico", "Palestinian Territory",
    "Portugal", "Palau", "Paraguay", "Qatar", "Reunion", "Romania",
    "Russian Federation", "Rwanda", "Saudi Arabia", "Solomon Islands",
    "Seychelles", "Sudan", "Sweden", "Singapore", "Saint Helena", "Slovenia",
    "Svalbard and Jan Mayen", "Slovakia", "Sierra Leone", "San Marino", "Senegal",
    "Somalia", "Suriname", "Sao Tome and Principe", "El Salvador", "Syrian Arab Republic",
    "Swaziland", "Turks and Caicos Islands", "Chad", "French Southern Territories",
    "Togo", "Thailand", "Tajikistan", "Tokelau", "Turkmenistan",
    "Tunisia", "Tonga", "Timor-Leste", "Turkey", "Trinidad and Tobago", "Tuvalu",
    "Taiwan", "Tanzania, United Republic of", "Ukraine",
    "Uganda", "United States Minor Outlying Islands", "United States", "Uruguay",
    "Uzbekistan", "Holy See (Vatican City State)", "Saint Vincent and the Grenadines",
    "Venezuela", "Virgin Islands, British", "Virgin Islands, U.S.",
    "Vietnam", "Vanuatu", "Wallis and Futuna", "Samoa", "Yemen", "Mayotte",
    "Serbia", "South Africa", "Zambia", "Montenegro", "Zimbabwe",
    "Anonymous Proxy","Satellite Provider","Other",
    "Aland Islands","Guernsey","Isle of Man","Jersey","Saint Barthelemy","Saint Martin"
    )

# Count by Country
class GeoIP(db.Model):
  startip = db.IntegerProperty(required=True)
  endip = db.IntegerProperty(required=True)
  code = db.StringProperty(required=True)

def ip2long(ip):
  ip_array = ip.split('.')
  ip_long = int(ip_array[0]) * 16777216 + int(ip_array[1]) * 65536 + int(ip_array[2]) * 256 + int(ip_array[3])
  return ip_long

def country_code_by_addr(ip):
  ipnum = ip2long(ip)
  geos = db.GqlQuery("SELECT * "
                     "FROM GeoIP "
                     "WHERE startip <= :1 ORDER BY startip DESC LIMIT 1", ipnum)
  geo = geos.get()
  if geo and (ipnum <= geo.endip):
    return geo.code
  else:
    return '--'

def country_name_by_code(code):
  codes = list(COUNTRY_CODES)
  names = list(COUNTRY_NAMES)
  if codes.count(code) > 0:
    return names[codes.index(code)]
  else:
    return names[0]

# Access logs
class CWLogs(db.Model):
  ipaddr = db.StringProperty(required=True)
  date = db.DateTimeProperty(required=True)
  ide = db.StringProperty(required=True) # IDE Kind
  ver = db.StringProperty(required=True) # CnWizards Version
  code = db.StringProperty() # Country Code

# Dictionary
class CWDictionary(db.Model):
  name = db.StringProperty(required=True)
  value = db.StringProperty(required=True)

# Count by Hour
class CWCntHour(db.Model):
  date = db.DateProperty(required=True) # date = min means all the time
  hour = db.IntegerProperty(required=True)
  count = db.IntegerProperty(required=True)

# Count by Month
class CWCntMonth(db.Model):
  date = db.DateProperty(required=True)
  count = db.IntegerProperty(required=True)

# Count by Ide
class CWCntIde(db.Model):
  date = db.DateProperty(required=True) # date = min means all the time
  ide = db.StringProperty(required=True)
  count = db.IntegerProperty(required=True)

# Count by Ver
class CWCntVer(db.Model):
  date = db.DateProperty(required=True) # date = min means all the time
  ver = db.StringProperty(required=True)
  count = db.IntegerProperty(required=True)

# Count by Country
class CWCntCountry(db.Model):
  date = db.DateProperty(required=True) # date = min means all the time
  code = db.StringProperty(required=True)
  count = db.IntegerProperty(required=True)

# Count by Ide & Ver & Country
class CWCntUnion(db.Model):
  date = db.DateProperty(required=True) # date = min means all the time
  ide = db.StringProperty(required=True)
  ver = db.StringProperty(required=True)
  code = db.StringProperty(required=True)
  count = db.IntegerProperty(required=True)
