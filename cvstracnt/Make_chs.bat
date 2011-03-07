@ECHO OFF

net stop CVSTracService

del Bin\cvstrac_chs.exe

ECHO Making cvstrac_chs...
CALL SetEnv.bat
cd Make
copy Makefile_chs Makefile
make strip
IF NOT ERRORLEVEL 0 GOTO ERROR
copy cvstrac.exe ..\Bin\cvstrac_chs.exe
make clean 2>NUL >NUL
del Makefile
cd ..

net start CVSTracService

ECHO Complete!

GOTO END

:ERROR
ECHO Error!

:END