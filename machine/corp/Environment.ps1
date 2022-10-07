if ($_AlreadySourcedEnvironment -ne $null) { return } else { $_AlreadySourcedEnvironment = $true }

$ErrorActionPreference = "Stop"

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (! $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "You must run as Administrator"
}

if ($PSVersionTable.PSVersion.Major -ge 7) {
    throw "You must run this inside powershell version lower than 7. Try simply entering powershell"
}

$RepoRoot = (Resolve-Path $PSScriptRoot\..\..).Path

$LocalConfigDir = "$RepoRoot\local_config"

$userConfigFile = "$LocalConfigDir\UserConfig.psd1"
if (-not (Test-Path -Path $userConfigFile))
{
    throw "You must copy $LocalConfigDir\UserConfig.template.psd1 as $userConfigFile and adjust its content"
}

$UserConfig = Import-PowerShellDataFile $userConfigFile
$UserName = $UserConfig.UserName
$UserDir = $UserConfig.UserDir
$UserBinDir = $UserConfig.UserBinDir
if (-not (Test-Path -Path $UserBinDir)) 
{
    New-Item -ItemType Directory -Force -Path $UserBinDir
}

$LocalConfig = @{
    PublicKeyPath = "$LocalConfigDir\DscPublicKey.cer"
    DscConfigPath = "$LocalConfigDir\DscConfig.psd1"
    DscWorkDir    = "$RepoRoot\dsc_run"
}
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

$DscConfigPath = $LocalConfig.DscConfigPath