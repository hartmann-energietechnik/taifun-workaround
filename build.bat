@echo off

where /q  cl.exe
IF ERRORLEVEL 1 (
    @call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat" %* > nul
    @call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" %* > nul
)

cl /EHsc /std:c++17 ./taifun_open_files.cpp

set "exe=taifun_open_files.exe"

"tools/ResourceHacker.exe" -open "%exe%" -save "%exe%" -action addskip -res icon.ico -mask ICONGROUP,MAINICON,