@echo off
color 1
mode con: cols=51 lines=15
setlocal enabledelayedexpansion

:: Get the file path from the argument
set "FILEPATH=%~1"
set "FILENAME=%~nx1"

:: Mirror list - tried in order until one succeeds
set "MIRRORS=buzzheavier.com bzzhr.co bzzhr.to"

:: Display upload header
cls
echo ===================================================
echo                    File Uploader
echo ===================================================
echo.
echo Uploading: %FILENAME%
echo.

:: URL encode the filename using PowerShell (handles spaces and special chars)
for /f "delims=" %%a in ('powershell -NoProfile -Command "[uri]::EscapeDataString('%FILENAME%')"') do (
    set "ENCODED_FILENAME=%%a"
)

set "UPLOAD_OK=0"

for %%M in (%MIRRORS%) do (
    if "!UPLOAD_OK!"=="0" (
        call :TRY_MIRROR "%%M"
    )
)

if "!UPLOAD_OK!"=="0" (
    echo.
    echo [ERROR] Upload failed on all mirrors!
    echo.
    pause
    exit /b 1
)

:: Construct the URL
set "FILEURL=https://!UPLOAD_HOST!/!FILEID!"

:: Display success message
cls
echo ===================================================
echo                 Upload Complete :3
echo ===================================================
echo.
echo File: %FILENAME%
echo File ID: !FILEID!
echo Mirror: !UPLOAD_HOST!
echo.
color a
echo URL: !FILEURL!
echo.
echo ===================by EpicZone====================
echo.
echo Press 1 to copy URL to clipboard
echo Press any other key to exit
echo.

:WAIT_INPUT
choice /c 1234567890 /n /m "" >nul

if errorlevel 1 if not errorlevel 2 (
    echo !FILEURL! | clip
    echo.
    echo [SUCCESS] URL copied to clipboard!
    echo.
    timeout /t 2 >nul
    exit /b 0
)

exit /b 0

:: ============================================
:: Subroutine: try uploading to a single mirror
:: %1 = mirror hostname (e.g. buzzheavier.com)
:: Sets UPLOAD_OK=1, FILEID, UPLOAD_HOST on success
:: ============================================
:TRY_MIRROR
setlocal
set "HOST=%~1"
set "TEMPFILE=%TEMP%\upload_%RANDOM%.json"

echo Trying !HOST!...

curl -# -o "%TEMPFILE%" -T "%FILEPATH%" "https://w.!HOST!/!ENCODED_FILENAME!"

:: Bail out of this attempt on curl error
if errorlevel 1 (
    echo [WARN] !HOST! - curl error, trying next mirror...
    del "%TEMPFILE%" 2>nul
    endlocal
    exit /b 1
)

:: Bail out if no response file
if not exist "%TEMPFILE%" (
    echo [WARN] !HOST! - no response, trying next mirror...
    endlocal
    exit /b 1
)

echo [PASS] !HOST! upload complete!
echo.

:: Bail out if response is empty
for %%A in ("%TEMPFILE%") do set "FSIZE=%%~zA"
if "!FSIZE!"=="0" (
    echo [WARN] !HOST! - empty response, trying next mirror...
    del "%TEMPFILE%" 2>nul
    endlocal
    exit /b 1
)

:: Try to parse the file ID out of the JSON
set "PARSED_ID="
for /f "delims=" %%a in ('powershell -NoProfile -Command "try { $json = Get-Content '%TEMPFILE%' | ConvertFrom-Json; $json.data.id } catch { '' }"') do (
    set "PARSED_ID=%%a"
)

del "%TEMPFILE%" 2>nul

if "!PARSED_ID!"=="" (
    echo [WARN] !HOST! - could not parse file ID, trying next mirror...
    endlocal
    exit /b 1
)

:: Success - pass values back up to the caller
endlocal & (
    set "UPLOAD_OK=1"
    set "FILEID=%PARSED_ID%"
    set "UPLOAD_HOST=%HOST%"
)
exit /b 0
