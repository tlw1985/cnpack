CVSTracNT V2.0.1 Build 20080601
===============================

Zhou JingYu(zjy@cnpack.org), CnPack Team.
http://www.cnpack.org

1. CVSTrac Introduction
-----------------------
CVSTrac is A Web-Based Bug And Patch-Set Tracking System For CVS:

  * Automatically generates a patch-set log from CVS check-in comments
  * User-defined color-coded database queries
  * Web-based administration of the CVSROOT/passwd file
  * Built-in repository browser
  * Built-in Wiki
  * Very simple setup - a self-contained executable runs as CGI, from
    inetd, or as a stand-alone web server
  * Minimal memory, disk and CPU requirements - works on old hardware
  * Access permissions configurable separately for each user
  * Allows for anonymous users
  * Uses a built-in SQL database engine (SQLite) - no external RDBMS
    required
  * Tested under Linux - works on other versions of Unix. Also works
    under Windows
  * Can be run from a chroot jail for added security.
  * GNU Public License

Official site: http://www.cvstrac.org
Chinese site: http://www.cnpack.org


2. Windows Version Introduction
-------------------------------
Usually CVSTrac works under Unix/Linux. In its official site, there's a
document describes how to work under Windows:
(http://www.cvstrac.org/cvstrac/wiki?p=CvstracOnWindows)
But it's difficult and restrained. So I make this software to help us use
CVSTrac more easily.

Our works:

  * Compile SQLite3 and CVSTrac under Cygwin
  * Write a NT service CVSTracSvc.exe to start as a service
  * Write CVSTracOption.exe to make configuration more easily
  * Write CTSender.exe and some plugins for sending ticket notificaition
  * Manage passwd for CVSNT
  * Import/Export CVSTrac users list
  * User-defined charset support.
  * Fix a series of problem for CVSNT

Compile Environment:

  * cygwin-1.5.18.1
  * sqlite-3.5.9
  * cvstrac-2.0.1
  * Delphi 7

Tested Environment:

  * Windows Server 2003 Stardard Edition
  * Windows 2000 Server SP4
  * Windows XP Professtional SP1
  * CVSNT 2.0.58d/2.5.03 build 2382


3. Installation
---------------

  * Run install exe to install, need not uninstall the old version.
  * Run CVSTrac Option.
  * Click "Auto Import" button to import CVS Repositories in CVSNT.
  * Double click every item, modify it.
  * Import/Export users list in database setup dialog.
  * You can add/delete CVS Repositories also.

Test it:

Select a database, click "Browse" button, if you can see the login
page in opened Explorer, then it is OK!

The default login user is "setup", password is "setup" also.
You can create others accounts after login.
Anonymous can access server when "anonymous" account exists.


4. Operation
------------
Note:

  * Restart service needed after modify database path, port or language.
  * Modify database need not restart service.
  * When system running, do not modify cvs repository and module prefix in
    database, except cvs repository moved.
  * Backup database directory when needed, rewrite it when restore.
  * Configure ticket notificaition plugins if you want to use ticket notify ferture.

Use passwd file on CVSNT:

  * Create a local system user "cvsuser" who can to access the CVS repository.
  * Set the CVSTrac database to support passwd file.


5. Uninstall
------------

Run the uninstall program.


6. Get Source Code
------------------
CVS Check out:

  * CVSROOT   :pserver:anoncvs@www.cnpack.org:/var/cvshome/cnpack
  * Module    cvstracnt
  * Password  anoncvs

The CVSTracNT's source is on this branch:

  * Module    cvstracnt/Source/cvstrac
  * Branch    CVSTracNT_ENU


7. History
----------

2008.06.01 V2.0.1 Build 20080601

  * Upgrade to CVSTrac 2.0.1 (see http://www.cvstrac.org)
  * Upgrade database to new format automatically.
  * Added extra fields for notify plugin.
  * Create CVSROOT/history file for CVS respository automatically.

2006.01.12 V1.2.1 Build 20060112

  * Upgrade to CVSTrac 1.2.1 (see http://www.cvstrac.org)
  * Fixed a problem of long caption in mail plugin.

2005.09.15 V1.2.0 Build 20050916

  * Upgrade to CVSTrac 1.2.0 (see http://www.cvstrac.org)
  + Support CVS/Subversion/GIT in one cvstrac service.
  * Added Auto Backup Database feature.
  * Fixed a bug that cvstrac does not call Ticket Notification in some system.
  * Compile under cygwin 1.5.18.1 and sqlite 2.8.16.

2005.07.03 V1.1.5 Build 20050703

  * Fixed the problem of restarting service.
  * Library name modified to keep the compatibility with other software.

2005.04.26 V1.1.5 Build 20050426

  * Added user-defined charset support.
  * Fix the bug that email plugin does not support email address includes '-'.

2005.04.13 V1.1.5 Build 20050413

  * Fix the problem of plugin's not supporting customized database path.

2005.04.08 V1.1.5 Build 20050408

  + Archtecture of Ticket Notification Changed to Plugins with the Ability of Free Extension.
  + Added a Plugin of RTX Notification.
  + Added a Plugin of NET SEND Notification.
  + Added Ticket Notification log feature.
  * Other Improvement, include Multi-Recieptents Supporting in Email Notification.
  * Fix the bug that timeline does not work in some particular systems.

2005.01.15 V1.1.5 Build 20050115
  * Upgrade to CVSTrac 1.1.5

2004.12.07 V1.1.4 Build 20041207
  * Fixed form scaled problem in English OS

2004.09.10 V1.1.4 Build 20040910
  * Fixed a problem if filename includes whitespaces in CVS Browser
    (Thanks jeack)

2004.08.13 V1.1.4 Build 20040813
  * Update to vertion 1.1.4
  * Fixed Input Validation Hole caused by filediff
  * Fixed known bugs

2004.05.29 V1.1.3 Build 20040529

  * Added multi-language support, include Chinese and English
  * Fixed some wrong icons in timeline
  * Fixed other known bugs

2004.04.09 V1.1.3 Build 20040409

  * Update to vertion 1.1.3
  * Fixed known bugs

2003.12.14 V1.1.2 Build 20031213

  + Added mail notify
  * Fixed known bugs

2003.12.10 V1.1.2 Build 20031210

  + Added support passwd file for CVSNT
  + Added import/export CVSTrac users list
  * Fixed known bugs

2003.11.15 V1.1.2 Build 20031115

  * Fixed known bugs

2003.11.12 V1.1.2 Build 20031112

  * First release