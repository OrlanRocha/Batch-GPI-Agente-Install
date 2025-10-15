[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    try {
        $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    } catch {
        return $false
    }
}

if (-not (Test-IsAdministrator)) {
    Write-Host 'Este script deve ser executado como administrador.'
    exit 1
}

# Configuracoes iniciais
$SetupVersion = '1.7.3'
$SetupArchitecture = 'Auto'
$IpServidor = '127.0.0.1'
$SetupLocation = "http://$IpServidor/glpi/agent/$SetupVersion"
$SetupOptions = @(
    '/quiet',
    'RUNNOW=1',
    "SERVER=http://$IpServidor/glpi/"
)
$Reconfigure = 'Yes'
$Repair = 'Yes'
$RunUninstallFusionInventoryAgent = 'Yes'
$UninstallOcsAgent = 'No'
$ExitCode = 0

if ($SetupArchitecture -eq 'Auto') {
    if ([Environment]::Is64BitOperatingSystem) {
        $SetupArchitecture = 'x64'
    } else {
        $SetupArchitecture = 'x86'
    }
}

$Setup = "GLPI-Agent-$SetupVersion-$SetupArchitecture.msi"
$SetupUrl = "$SetupLocation/$Setup"
$TempFile = Join-Path -Path $env:TEMP -ChildPath $Setup

function Remove-DirectorySafe {
    param(
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

try {
    Write-Host 'Baixando agente GLPI...'
    try {
        Invoke-WebRequest -Uri $SetupUrl -OutFile $TempFile -UseBasicParsing
    } catch {
        throw (New-Object System.Exception 'DownloadFailed', $_.Exception)
    }

    if (-not (Test-Path -LiteralPath $TempFile)) {
        throw (New-Object System.Exception 'DownloadFailed')
    }

    if ($RunUninstallFusionInventoryAgent -eq 'Yes') {
        Write-Host 'Desinstalando FusionInventory-Agent...'
        try {
            $fusionProducts = Get-WmiObject -Class Win32_Product -Filter "Name LIKE 'FusionInventory-Agent%'" -ErrorAction Stop
        } catch {
            $fusionProducts = @()
        }

        foreach ($product in $fusionProducts) {
            try {
                $null = $product.Uninstall()
            } catch {
                Write-Verbose "Falha ao desinstalar FusionInventory-Agent: $($_.Exception.Message)"
            }
        }

        Remove-DirectorySafe "$env:ProgramFiles\FusionInventory-Agent"
        Remove-DirectorySafe "$env:ProgramFiles(x86)\FusionInventory-Agent"
    }

    if ($UninstallOcsAgent -eq 'Yes') {
        Write-Host 'Desinstalando OCS Inventory Agent...'
        try {
            $ocsProducts = Get-WmiObject -Class Win32_Product -Filter "Name LIKE 'OCS Inventory%'" -ErrorAction Stop
        } catch {
            $ocsProducts = @()
        }

        foreach ($product in $ocsProducts) {
            try {
                $null = $product.Uninstall()
            } catch {
                Write-Verbose "Falha ao desinstalar OCS Inventory Agent: $($_.Exception.Message)"
            }
        }

        foreach ($serviceName in @('OCS INVENTORY')) {
            try {
                if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
                    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                    sc.exe delete "$serviceName" | Out-Null
                }
            } catch {
                Write-Verbose "Falha ao remover o servico $serviceName: $($_.Exception.Message)"
            }
        }

        Remove-DirectorySafe "$env:ProgramFiles\OCS Inventory Agent"
        Remove-DirectorySafe "$env:ProgramFiles(x86)\OCS Inventory Agent"
        Remove-DirectorySafe "$env:SystemDrive\ocs-ng"
    }

    $installArguments = @()
    if ($Repair -eq 'Yes') {
        $installArguments += '/fa'
    } else {
        $installArguments += '/i'
    }

    $installArguments += $TempFile
    $installArguments += $SetupOptions

    Write-Host 'Instalando agente GLPI...'
    $process = Start-Process -FilePath 'msiexec.exe' -ArgumentList $installArguments -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        $ExitCode = $process.ExitCode
        Write-Host "Falha na instalacao com o codigo de erro $ExitCode."
        return
    }

    Write-Host 'Instalacao realizada com sucesso!'
} catch {
    if ($_.Exception.Message -eq 'DownloadFailed') {
        Write-Host 'Falha ao baixar o instalador do GLPI Agent.'
        if ($ExitCode -eq 0) {
            $ExitCode = 1
        }
    } else {
        Write-Host "Falha inesperada: $($_.Exception.Message)"
        if ($ExitCode -eq 0) {
            $ExitCode = 1
        }
    }
} finally {
    if (Test-Path -LiteralPath $TempFile) {
        Remove-Item -LiteralPath $TempFile -Force -ErrorAction SilentlyContinue
    }

    Write-Host 'Concluido.'
    exit $ExitCode
}
