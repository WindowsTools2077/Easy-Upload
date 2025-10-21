@echo off
color 1
mode con: cols=51 lines=15
setlocal enabledelayedexpansion

:: Get the file path from the argument
set "FILEPATH=%~1"
set "FILENAME=%~nx1"

:: Display upload header
cls
echo ===================================================
echo                    File Uploader
echo ===================================================
echo.
echo Uploading: %FILENAME%
echo.

:: Create temporary files
set "TEMPFILE=%TEMP%\buzzheavier_%RANDOM%.json"
set "PROGRESSFILE=%TEMP%\buzzheavier_progress_%RANDOM%.txt"

:: URL encode the filename using PowerShell (handles spaces and special chars)
for /f "delims=" %%a in ('powershell -NoProfile -Command "[uri]::EscapeDataString('%FILENAME%')"') do (
    set "ENCODED_FILENAME=%%a"
)

:: Upload file with curl
:: -# shows progress bar (goes to stderr)
:: -o writes response to file
:: -T uploads the file
curl -# -o "%TEMPFILE%" -T "%FILEPATH%" "https://w.buzzheavier.com/!ENCODED_FILENAME!"

:: Check curl exit code
if errorlevel 1 (
    echo.
    echo [ERROR] Upload failed - curl error!
    echo.
    pause
    del "%TEMPFILE%" 2>nul
    exit /b 1
)

:: Check if we got a response
if not exist "%TEMPFILE%" (
    echo.
    echo [ERROR] Upload failed - no response file created!
    echo.
    pause
    exit /b 1
)

:: Check if file has content
for %%A in ("%TEMPFILE%") do set "FILESIZE=%%~zA"
if "%FILESIZE%"=="0" (
    echo.
    echo [ERROR] Upload failed - empty response from server!
    echo.
    pause
    del "%TEMPFILE%" 2>nul
    exit /b 1
)

:: Use PowerShell to parse JSON properly
echo.
echo Parsing response...
echo.

for /f "delims=" %%a in ('powershell -NoProfile -Command "$json = Get-Content '%TEMPFILE%' | ConvertFrom-Json; $json.data.id"') do (
    set "FILEID=%%a"
)

:: Clean up temp file
del "%TEMPFILE%" 2>nul

:: Check if we got an ID
if "!FILEID!"=="" (
    echo.
    echo [ERROR] Could not extract file ID from response
    echo.
    pause
    exit /b 1
)

:: Construct the URL
set "FILEURL=https://buzzheavier.com/!FILEID!"

:: Display success message
cls
echo ===================================================
echo                 Upload Complete :3
echo ===================================================
echo.
echo File: %FILENAME%
echo File ID: !FILEID!
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
