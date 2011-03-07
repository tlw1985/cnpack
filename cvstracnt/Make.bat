@ECHO OFF

net stop CVSTracService

del Bin\cvstrac_*.exe

ECHO Making cvstrac_enu...
cd Make
copy Makefile_enu Makefile
make clean 2>NUL >NUL
make 2>NUL >NUL
IF NOT ERRORLEVEL 0 GOTO ERROR
copy cvstrac.exe ..\Bin\cvstrac_enu.exe
make clean 2>NUL >NUL
del Makefile
cd ..

ECHO Making cvstrac_chs...
cd Make
copy Makefile_chs Makefile
make 2>NUL >NUL
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