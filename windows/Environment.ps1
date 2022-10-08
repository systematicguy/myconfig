if ($_AlreadySourcedEnvironment -ne $null) { return } else { $_AlreadySourcedEnvironment = $true }

$ErrorActionPreference = "Stop"

# validate administrator:
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (! $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "You must run as Administrator"
}

# validate powershell 5
if ($PSVersionTable.PSVersion.Major -ge 7 -or $PSVersionTable.PSVersion.Major -lt 5) {
    throw "You must run this inside powershell version lower than 7, at least 5.1. If you have powershell-core (7.2+), try simply entering: powershell"
}

$RepoRoot = (Resolve-Path $PSScriptRoot\..).Path
$LocalConfigDir = "$RepoRoot\local_config"

# validate user config existence
$userConfigFile = "$LocalConfigDir\UserConfig.psd1"
if (-not (Test-Path -Path $userConfigFile))
{
    throw "You must copy $LocalConfigDir\UserConfig.template.psd1 as $userConfigFile and adjust its content"
}

##########################

$UserConfig = Import-PowerShellDataFile $userConfigFile
$CorpDomain = $UserConfig.CorpDomain
$UserName = $UserConfig.UserName
$UserDir = $UserConfig.UserDir

# ensure user bin dir
$UserBinDir = $UserConfig.UserBinDir
if (-not (Test-Path -Path $UserBinDir)) 
{
    New-Item -ItemType Directory -Force -Path $UserBinDir
}

$LocalConfig = @{
    DscPublicKeyPath = "$LocalConfigDir\DscPublicKey.cer"
    DscConfigPath    = "$LocalConfigDir\DscConfig.psd1"
    DscWorkDir       = "$RepoRoot\dsc_run"
}
$DscConfigPath = $LocalConfig.DscConfigPath

# ensure work dirs for config running
$DscWorkDir = $LocalConfig.DscWorkDir
if (-not (Test-Path -Path $DscWorkDir))
{
    New-Item -ItemType Directory -Force -Path $DscWorkDir
}
$DscWorkDir = (Resolve-Path $DscWorkDir).Path
$DscMofDir = "$DscWorkDir\mof"
if (-not (Test-Path -Path $DscMofDir))
{
    New-Item -ItemType Directory -Force -Path $DscMofDir
}

$TodoFile = "$LocalConfigDir\manual_todo.txt"
function LogManualTodo {
    param (
        [string]
        $Message
    )

    Write-Output $Message
    Write-Output $Message | Out-File $TodoFile
}