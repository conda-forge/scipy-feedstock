@echo on
setlocal enabledelayedexpansion

:: copy %SRC_DIR%/base somewhere to be able to hard-reset state in build-output.bat
mkdir .\backup
robocopy base backup /E >nul
:: for whatever reason, robocopy returns 1 in case of success, see
:: https://learn.microsoft.com/en-us/troubleshoot/windows-server/backup-and-storage/return-codes-used-robocopy-utility
if %ERRORLEVEL% neq 1 exit 1
