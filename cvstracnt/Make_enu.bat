@ECHO OFF

net stop CVSTracService

del Bin\cvstrac_enu.exe

ECHO Making cvstrac_enu...
cd Make
copy Makefile_enu Makefile
make strip
IF NOT ERRORLEVEL 0 GOTO ERROR
copy cvstrac.exe ..\Bin\cvstrac_enu.exe
make clean 2>NUL >NUL
del Makefile
cd ..

net start CVSTracService

ECHO Complete!

GOTO END

:ERROR
ECHO Error!

:END