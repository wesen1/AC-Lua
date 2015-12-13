@echo off
where /q mingw32-make
IF ERRORLEVEL 1 (
    ECHO mingw32-make was not found on your system. Aborting.
    EXIT /B
)

ECHO Removing old build directory...
RMDIR /s /q server_out

ECHO Building Lua...
cd lua
mingw32-make mingw
copy src/liblua.a ../lib/
copy src/lua51.dll ../lib/
cd ..

ECHO Building AssaultCube server
mingw32-make mingw
