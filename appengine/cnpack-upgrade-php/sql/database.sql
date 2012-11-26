-- phpMyAdmin SQL Dump
-- version 2.11.9.5
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2012 年 11 月 26 日 16:23
-- 服务器版本: 5.1.37
-- PHP 版本: 5.2.10

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- 数据库: `test`
--

-- --------------------------------------------------------

--
-- 表的结构 `cwcntcountry`
--

CREATE TABLE IF NOT EXISTS `cwcntcountry` (
  `id` varchar(64) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `code` char(2) NOT NULL DEFAULT '',
  `count` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `cwcnthour`
--

CREATE TABLE IF NOT EXISTS `cwcnthour` (
  `id` varchar(64) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `hour` int(4) NOT NULL DEFAULT '0',
  `count` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `cwcntide`
--

CREATE TABLE IF NOT EXISTS `cwcntide` (
  `id` varchar(64) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `ide` varchar(32) NOT NULL DEFAULT '',
  `count` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ide` (`ide`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `cwcntlang`
--

CREATE TABLE IF NOT EXISTS `cwcntlang` (
  `id` varchar(64) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `lang` char(4) NOT NULL DEFAULT '',
  `count` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `lang` (`lang`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `cwcntmonth`
--

CREATE TABLE IF NOT EXISTS `cwcntmonth` (
  `id` varchar(64) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `count` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `cwcntunion`
--

CREATE TABLE IF NOT EXISTS `cwcntunion` (
  `id` varchar(255) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `ide` varchar(32) NOT NULL DEFAULT '',
  `ver` varchar(32) NOT NULL DEFAULT '',
  `code` char(2) NOT NULL DEFAULT '',
  `count` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `cwcntver`
--

CREATE TABLE IF NOT EXISTS `cwcntver` (
  `id` varchar(64) NOT NULL DEFAULT '',
  `date` date NOT NULL DEFAULT '0000-00-00',
  `ver` varchar(32) NOT NULL DEFAULT '',
  `count` int(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ver` (`ver`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `cwconfig`
--

CREATE TABLE IF NOT EXISTS `cwconfig` (
  `name` varchar(32) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `cwdictionary`
--

CREATE TABLE IF NOT EXISTS `cwdictionary` (
  `name` varchar(32) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `cwlogs`
--

CREATE TABLE IF NOT EXISTS `cwlogs` (
  `ipaddr` varchar(32) NOT NULL DEFAULT '',
  `date` datetime NOT NULL,
  `ide` varchar(32) NOT NULL DEFAULT '',
  `ver` varchar(32) NOT NULL DEFAULT '',
  `code` char(2) NOT NULL DEFAULT '',
  `lang` char(4) NOT NULL DEFAULT ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
