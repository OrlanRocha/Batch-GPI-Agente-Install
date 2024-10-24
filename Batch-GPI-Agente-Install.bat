:: GLPI Agent Deployment Batch Script
:: Copyright (C) 2024 BY OrlanRocha
:: 
:: 

@echo off
setlocal ENABLEDELAYEDEXPANSION

REM Set the version of GLPI Agent to be installed
set "SetupVersion=1.7.3"

set "ipServer=127.0.0.1"

REM Set the location of the agent to be installed
set "SetupLocation=http://%ipServer%/glpi/agent/%SetupVersion%"

REM Set the setup architecture to auto-detect
set "SetupArchitecture=Auto"

REM Set installation options
set "SetupOptions=/quiet RUNNOW=1 SERVER=http://%ipServer%/glpi/"

REM Set whether to uninstall FusionInventory Agent and OCS Inventory Agent
set "RunUninstallFusionInventoryAgent=Yes"
set "UninstallOcsAgent=No"

REM Define temporary file path
set "TempDir=%TEMP%"

REM Detect system architecture
set "ARCH=%PROCESSOR_ARCHITECTURE%"
if "%ARCH%"=="x86" (set "SetupArchitecture=x86") else (set "SetupArchitecture=x64")

REM Define installer name
set "Setup=GLPI-Agent-%SetupVersion%-%SetupArchitecture%.msi"

REM Download GLPI Agent
if exist "%TempDir%\%Setup%" del /q "%TempDir%\%Setup%"

curl -o "%TempDir%\%Setup%" "%SetupLocation%/%Setup%"

if exist "%TempDir%\%Setup%" (
    echo Installing GLPI Agent...
    msiexec /i "%TempDir%\%Setup%" %SetupOptions%
    if %errorlevel%==0 (
        echo Installation successful!
    ) else (
        echo Installation failed with error code %errorlevel%.
    )
) else (
    echo Failed to download the GLPI Agent installer.
)

REM Optional: Uninstall FusionInventory Agent if required
if /i "%RunUninstallFusionInventoryAgent%"=="Yes" (
    echo Uninstalling FusionInventory Agent...
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent" /v UninstallString >nul 2>&1 && (
        for /f "tokens=3*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\FusionInventory-Agent" /v UninstallString') do (
            set "UninstallCmd=%%a %%b"
            call !UninstallCmd! /S /NOSPLASH
        )
    )
)

echo Done.
endlocal
pause
