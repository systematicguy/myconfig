######################################################################################
# Warning:
# This file is dot sourced almost everywhere, assumed to be working before any setup.
# It must not rely on any non-standard module, nor should it perform any DSC job.
#####################################################################################
if ($null -ne $AlreadySourced) { return } else { $AlreadySourced = @{} }

$ErrorActionPreference = "Stop"


##############################################################################
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
$RepoToolsDir = "$RepoRoot\tools"

# validate user config existence
$userConfigFile = "$LocalConfigDir\UserConfig.psd1"
if (-not (Test-Path -Path $userConfigFile))
{
    Copy-Item -Path $LocalConfigDir\UserConfig.template.psd1 -Destination $userConfigFile
}
$UserConfig = Import-PowerShellDataFile $userConfigFile
if ($UserConfig.Draft -eq $true) {
    throw "You must edit $userConfigFile, adjust its content and remove the Draft entry from it"
}

##############################################################################

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

##############################################################################

$TodoFile = "$LocalConfigDir\manual_todo.txt"
function LogTodo {
    param (
        [string]
        $Message
    )

    Write-Output $Message
    Write-Output $Message | Out-File $TodoFile -Append
}
LogTodo -Message ""
LogTodo -Message "---------$(Get-Date)-----------------------------------------------------------------------------------------"

function ShowTodo {
    Write-Output "The following has to be done manually:"
    Get-Content $TodoFile | Write-Output
}

#############################################################################

function ApplyDscConfiguration {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ConfigurationName,

        [Parameter(Mandatory=$false)]
        [switch]$IgnoreError = $false
    )

    & $ConfigurationName -Output "$DscMofDir\$ConfigurationName" -ConfigurationData $DscConfigPath
    
    # https://stackoverflow.com/questions/27201314/start-dscconfiguration-doesnt-throw-exceptions
    $originalErrorCount = $error.Count;
    Start-DscConfiguration -Path "$DscMofDir\$ConfigurationName" -Force -Verbose -Wait
    if ($error.Count -gt $originalErrorCount) {
        if ($IgnoreError -eq $false) {
            throw "DSC configuration $ConfigurationName failed"
        } else {
            Write-Warning "DSC configuration $ConfigurationName failed, ignoring as requested"
        }
    }
    return $null
}


######################################################################################
# Warning:
# This file is dot sourced almost everywhere, assumed to be working before any setup.
# It must not rely on any non-standard module, nor should it perform any DSC job.
#####################################################################################
