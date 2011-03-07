@ECHO OFF

net stop CVSTracService

CALL CleanInplace.bat .\ 2>NUL >NUL
ECHO Building CVSTracOption...
cd Source\CVSTracOption
"%ProgramFiles%\Borland\Delphi7\Bin\dcc32.exe" -q CVSTracOption.dpr
IF ERRORLEVEL 1 GOTO ERROR
cd ..\..\
CALL CleanInplace.bat .\ 2>NUL >NUL

ECHO Building CVSTracService...
cd Source\CVSTracService
"%ProgramFiles%\Borland\Delphi7\Bin\dcc32.exe" -q CVSTracSvc.dpr
IF ERRORLEVEL 1 GOTO ERROR
cd ..\..\
CALL CleanInplace.bat .\ 2>NUL >NUL

ECHO Building CTSender...
cd Source\CTSender
"%ProgramFiles%\Borland\Delphi7\Bin\dcc32.exe" -q CTSender.dpr
IF ERRORLEVEL 1 GOTO ERROR
cd ..\..\
CALL CleanInplace.bat .\ 2>NUL >NUL

ECHO Building CTMailer...
cd Source\CTMailer
"%ProgramFiles%\Borland\Delphi7\Bin\dcc32.exe" -q CTMailer.dpr
IF ERRORLEVEL 1 GOTO ERROR
cd ..\..\
CALL CleanInplace.bat .\ 2>NUL >NUL

ECHO Building CTRTX...
cd Source\CTRTX
"%ProgramFiles%\Borland\Delphi7\Bin\dcc32.exe" -q CTRTX.dpr
IF ERRORLEVEL 1 GOTO ERROR
cd ..\..\
CALL CleanInplace.bat .\ 2>NUL >NUL

ECHO Building CTNetSend...
cd Source\CTNetSend
"%ProgramFiles%\Borland\Delphi7\Bin\dcc32.exe" -q CTNetSend.dpr
IF ERRORLEVEL 1 GOTO ERROR
cd ..\..\
CALL CleanInplace.bat .\ 2>NUL >NUL

del Bin\cvstrac_*.exe

ECHO Making cvstrac_enu...
cd Make
copy Makefile_enu Makefile >NUL
make clean 2>NUL >NUL
make strip 2>NUL >NUL
IF ERRORLEVEL 1 GOTO ERROR
copy cvstrac.exe ..\Bin\cvstrac_enu.exe
make clean 2>NUL >NUL
del Makefile
cd ..

ECHO Making cvstrac_chs...
cd Make
copy Makefile_chs Makefile >NUL
make strip 2>NUL >NUL
IF ERRORLEVEL 1 GOTO ERROR
copy cvstrac.exe ..\Bin\cvstrac_chs.exe
make clean 2>NUL >NUL
del Makefile
cd ..

ECHO Create Setup...
"%ProgramFiles%\NSIS\makensis" Install\Src\CVSTracNT_Install.nsi >NUL
IF ERRORLEVEL 1 GOTO ERROR

net start CVSTracService

ECHO Complete!

GOTO END

:ERROR
ECHO Error!

:END
PAUSE