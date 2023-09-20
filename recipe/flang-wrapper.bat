@echo off
setlocal enabledelayedexpansion

rem Replace "-module" with "-module-dir" in the arguments
rem Omit "-Minform" argument
set "args=%*"
set "newArgs="
for %%i in (%args%) do (
    if "%%i"=="-module" (
        set "newArgs=!newArgs! -module-dir"
    ) else if "%%i" neq "-Minform" (
        set "newArgs=!newArgs! %%i"
    )
)

flang-new %newArgs%
set "exitCode=%errorlevel%"

rem Return the exit code of the last call
exit /b %exitCode%
