@echo off
:: BuzzHeavier Upload - Installer/Uninstaller
:: This script installs or uninstalls the upload feature
mode con: cols=51 lines=15
echo =================================================
echo               Easy Upload - Setup
echo =================================================
echo.

:: Check for admin rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] This script requires Administrator privileges!
    echo.
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

:: Main menu
:MENU
cls
echo =================================================
echo                Easy Upload - Setup
echo =================================================
echo.
echo What would you like to do?
echo.
echo [1] Install BuzzHeavier Upload
echo [2] Uninstall BuzzHeavier Upload
echo [3] Exit
echo.
echo =================================================
echo.

choice /c 123 /n /m "Enter your choice (1, 2, or 3): "

if errorlevel 3 goto :EXIT
if errorlevel 2 goto :UNINSTALL
if errorlevel 1 goto :INSTALL

:INSTALL
cls
echo =================================================
echo             Installing Easy Upload
echo =================================================
echo.

echo [1/3] Creating directory...
:: Create the BuzzHeavier folder in Program Files
if not exist "C:\Program Files\BuzzHeavier\" (
    mkdir "C:\Program Files\BuzzHeavier"
    echo Created: C:\Program Files\BuzzHeavier
) else (
    echo Directory already exists: C:\Program Files\BuzzHeavier
)
echo.

echo [2/3] Copying upload.bat...
:: Copy upload.bat from current directory to Program Files
if exist "%~dp0upload.bat" (
    copy /Y "%~dp0upload.bat" "C:\Program Files\BuzzHeavier\upload.bat" >nul
    echo Copied: upload.bat
) else (
    echo [ERROR] upload.bat not found in current directory!
    echo Please make sure upload.bat is in the same folder as this installer.
    echo.
    pause
    goto :MENU
)
echo.

echo [3/3] Adding to registry (right-click menu)...
:: Add registry entry for context menu
reg add "HKEY_CLASSES_ROOT\*\shell\BuzzHeavierUpload" /ve /t REG_SZ /d "Easy Upload" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\*\shell\BuzzHeavierUpload" /v "Icon" /t REG_SZ /d "imageres.dll,-1043" /f >nul 2>&1
reg add "HKEY_CLASSES_ROOT\*\shell\BuzzHeavierUpload\command" /ve /t REG_SZ /d "\"C:\\Program Files\\BuzzHeavier\\upload.bat\" \"%%1\"" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo Registry entry added successfully!
) else (
    echo [ERROR] Failed to add registry entry!
    pause
    goto :MENU
)
echo.

echo =================================================
echo             Installation Complete!
echo =================================================
echo.
echo BuzzHeavier Upload has been installed successfully!
echo.
echo To use:
echo 1. Right-click any file
echo 2. Select "Upload to BuzzHeavier"
echo 3. Press 1 to copy the URL after upload
echo.
color a
pause
goto :MENU

:UNINSTALL
cls
echo =================================================
echo            Uninstalling Easy Upload
echo =================================================
echo.

echo [1/2] Removing registry entries...
:: Remove registry entry for context menu
reg delete "HKEY_CLASSES_ROOT\*\shell\BuzzHeavierUpload" /f >nul 2>&1

if %errorlevel% equ 0 (
    echo Registry entries removed successfully!
) else (
    echo Registry entries not found or already removed.
)
echo.

echo [2/2] Removing files...
:: Remove the BuzzHeavier folder
if exist "C:\Program Files\BuzzHeavier\" (
    rd /s /q "C:\Program Files\BuzzHeavier"
    echo Deleted: C:\Program Files\BuzzHeavier
) else (
    echo Directory not found: C:\Program Files\BuzzHeavier
)
echo.

echo =================================================
echo            Uninstallation Complete!
echo =================================================
echo.
echo BuzzHeavier Upload has been removed from your system.
echo.
color c
pause
goto :MENU

:EXIT
cls
echo.
echo Thanks for using EpicZone Scrips!
echo.
exit /b 0
