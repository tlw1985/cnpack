CVSTracNT Source Code Document
==============================

Zhou JingYu, CnPack Develop Team
http://www.cnpack.org

1. Directories
--------------
BuildAll.bat    Auto build batch file.

Bin             Output files here
  co.exe            used to check out files in cvstrac
  cvstrac_*.exe     cvstrac main programs (multi-language), compiled under cygwin
  CVSTracOption.exe option tools, compiled with Delphi 7
  CVSTracSvc.exe    cvstrac service program, compiled with Delphi 7
  cygintl-1.dll     dll file used by diff.exe
  cygwin1.dll       cygwin dll file used by cvstrac.exe and etc.
  diff.exe          used to compare two source files in cvstrac
  License_*.txt     license files (multi-language)
  rcsdiff.exe       used to compare two versions in RCS file
  Readme_*.txt      readme files (multi-language)
  rlog.exe          used to get RCS file information
  sh.exe            shell program for pipe operation under cygwin
  sqlite.dll        SQLite database engine used in option tools.

  Database          database files here
  Lang              language files here, one sub directory per language
  Log               log files here
  Plugin            ticket notification plugins here

Dcu             Temporary files here

Make            Make files here

Source          Source code files here
  cvstrac           source of cvstrac, English NT version is in branch "CVSTracNT_ENU"
  CVSTracOption     source of option tools, use delphi 7 to compile
  CVSTracService    source of cvstrac service, use delphi 7 to compile
  CTSender          source of ticket notification sender, use delphi 7 to compile
  CTMailer          source of mailer plugin, use delphi 7 to compile
  CTNetSend         source of Net Send plugin, use delphi 7 to compile
  Public            public source files
  MultiLang         public multi-language source files

Plugins         Plugin source files here
  Include           common include file
  VCDemo            simple plugin in VC6


2. Compile Delphi Source
------------------------
All delphi source are compiled with Delphi 7. CnPack Component Package is needed, you can
download from cnpack site and put to the parent directory of cvstrac.


3. Compile cvstrac Source
-------------------------
The steps:

  * Install cygwin (http://www.cygwin.com), "gcc" and "automake" under "develop" are needed
  * Download sqlite source (http://www.sqlite.org), compile it under cygwin
  * Checkout "Source/cvstrac" with "CVSTracNT_ENU" branch and put it to Source/cvstrac_enu
  * Checkout "Source/cvstrac" with "CVSTracNT_CHS" branch and put it to Source/cvstrac_chs
  * Run BuildAll.bat to compile cvstrac source and build installer
