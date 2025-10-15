@echo off
setlocal enableextensions

:: Verifica se esta sendo executado como administrador
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Este script deve ser executado como administrador.
    pause
    exit /b 1
)

:: Configuracoes iniciais
:: Versão do Agente GLPI
set "SetupVersion=1.7.3"
set "SetupArchitecture=Auto"

:: IP Servidor GLPI
:: Se o servidor GLPI estiver em outro IP, altere aqui
set "ipServidor=127.0.0.1"

:: Diretorio do Agente GLPI
set "SetupLocation=http://%ipServidor%/glpi/agent/%SetupVersion%"

:: Opcoes passadas ao instalador MSI. Utiliza o mesmo IP configurado acima
:: para evitar discrepancias e remove aspas simples invalidas para o msiexec.
set "SetupOptions=/quiet RUNNOW=1 SERVER=http://%ipServidor%/glpi/"
set "Reconfigure=Yes"
set "Repair=Yes"
set "Verbose=No"
set "RunUninstallFusionInventoryAgent=Yes"
set "UninstallOcsAgent=No"
set "ExitCode=0"

:: Detectar arquitetura automaticamente
if /I "%SetupArchitecture%"=="Auto" (
    if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
        set "SetupArchitecture=x64"
    ) else (
        set "SetupArchitecture=x86"
    )
)

set "Setup=GLPI-Agent-%SetupVersion%-%SetupArchitecture%.msi"
set "SetupURL=%SetupLocation%/%Setup%"
set "TempFile=%TEMP%\%Setup%"

:: Funcao de download com PowerShell
echo Baixando agente GLPI...
powershell -Command "Invoke-WebRequest '%SetupURL%' -OutFile '%TempFile%'" || goto :DownloadFailed

if not exist "%TempFile%" (
    goto :DownloadFailed
)

:: Desinstalar FusionInventory-Agent se necessario
if /I "%RunUninstallFusionInventoryAgent%"=="Yes" (
    echo Desinstalando FusionInventory-Agent...
    wmic product where "name like '%%FusionInventory-Agent%%'" call uninstall /nointeractive
    rd /s /q "%ProgramFiles%\FusionInventory-Agent" 2>nul
    rd /s /q "%ProgramFiles(x86)%\FusionInventory-Agent" 2>nul
)

:: Desinstalar OCS Inventory Agent se necessario
if /I "%UninstallOcsAgent%"=="Yes" (
    echo Desinstalando OCS Inventory Agent...
    wmic product where "name like '%%OCS Inventory%%'" call uninstall /nointeractive
    sc stop "OCS INVENTORY" 2>nul
    sc delete "OCS INVENTORY" 2>nul
    rd /s /q "%ProgramFiles%\OCS Inventory Agent" 2>nul
    rd /s /q "%ProgramFiles(x86)%\OCS Inventory Agent" 2>nul
    rd /s /q "%SystemDrive%\ocs-ng" 2>nul
)

:: Executar instalacao ou reparo
if "%Repair%"=="Yes" (
    set "InstallCmd=/fa"
) else (
    set "InstallCmd=/i"
)

echo Instalando agente GLPI...
msiexec %InstallCmd% "%TempFile%" %SetupOptions%
if errorlevel 1 (
    set "ExitCode=%errorlevel%"
    echo Falha na instalacao com o codigo de erro %ExitCode%.
    goto :Cleanup
)

echo Instalacao realizada com sucesso!

:: Limpeza
if exist "%TempFile%" (
    del /f /q "%TempFile%"
)

echo Concluido.
endlocal
exit /b 0

:DownloadFailed
set "ExitCode=1"
echo Falha ao baixar o instalador do GLPI Agent.

:Cleanup
if exist "%TempFile%" (
    del /f /q "%TempFile%"
)
endlocal
exit /b %ExitCode%
