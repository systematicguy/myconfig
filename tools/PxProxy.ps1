. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\UserCredential.ps1
. $RepoRoot\helpers\CredentialProvider.ps1
. $RepoRoot\helpers\Downloader.ps1
. $RepoRoot\helpers\EnsureFile.ps1
. $RepoRoot\helpers\Ini.ps1
. $RepoRoot\helpers\EnsureScheduledTaskAndStart.ps1
Import-Module CredentialManager

$pxVersion = $UserConfig.PxProxy.Version
$pxZipFile = "px-v$pxVersion-windows.zip"
$pxProxyDownloadUrl = "https://github.com/genotrance/px/releases/download/v$pxVersion/$pxZipFile"
$pxProxyDir = "$UserBinDir\px_proxy"
$startPxScriptPath = "$UserBinDir\StartPxProxy.ps1"
$pxConfigPath = "$UserDir\px.ini"
$pxIniConfig = $UserConfig.PxProxy.PxIni
$pxCredentialTarget = "Px"

# store password for proxy in windows credential manager if server:username has been configured
$pxIniProxyUsername = $pxIniConfig.proxy.username
if (($pxIniConfig.Count -gt 0) -and ($pxIniProxyUsername -ne $null)) {
    Write-Host "UserConfig.PxProxy.PxIni.proxy.username has been specified, dealing with password for proxy server..."
    $storedPxProxyCredential = Get-StoredCredential -Target $pxCredentialTarget
    if ($storedPxProxyCredential -eq $null) {
        $proxyCredentials = ProvideCredential -Purpose "px_password" -User $pxIniProxyUsername -Message "Provide password for px proxy server (UserConfig.PxProxy.PxIni.proxy.username was set)"
        New-StoredCredential -Credentials $proxyCredentials -Target $pxCredentialTarget -Persist "Enterprise" > $null
    } else {
        Write-Host "Password already stored in credential store for target [$pxCredentialTarget]"
    }
}

if (($pxIniConfig.Count -gt 0) -and ($pxIniConfig.proxy.Count -gt 0) -and ($pxIniConfig.proxy.noproxy -eq $null)) {
    Write-Host "Setting server:noproxy to be the same value as UserConfig.NoProxy (UserConfig.PxProxy.PxIni.proxy.server section is present but server:noproxy was absent)..."
    $pxIniConfig.proxy.noproxy = $UserConfig.NoProxy
}

EnsureFile -Path $pxConfigPath -EncodingIfMissing ASCII
EnsureIniConfig -Path $pxConfigPath -IniConfig $pxIniConfig

EnsureExtractedUrl `
    -Url $pxProxyDownloadUrl `
    -ExtractedDir $pxProxyDir

Configuration PxProxyScriptFiles
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName FileContentDsc

    Node localhost 
    {
        File StartPxProxy
        {
            Type            = 'File'
            Contents        = "$pxProxyDir\px.exe --config=$pxConfigPath"
            DestinationPath = $startPxScriptPath
            Ensure          = "Present"
        }

        File StopPxProxy
        {
            Type            = 'File'
            Contents        = "$pxProxyDir\px.exe --quit"
            DestinationPath = "$UserBinDir\StopPxProxy.ps1"
            Ensure          = "Present"
        }
    }
}
ApplyDscConfiguration "PxProxyScriptFiles"

EnsureScheduledTaskAndStart `
    -TaskName "Start Px Proxy" `
    -ScriptPath $startPxScriptPath `
    -SkipStartDecisionScript {
        $runningProcesses = Get-Process px -ErrorAction SilentlyContinue
        if ($runningProcesses) {
            $true
        } else {
            $false
        }
    }

Configuration PxProxyEnvVars 
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node localhost
    {
        Script SetUserProxyEnvVars
        {
            # Environment resource cannot set an Environment Variable in the User's context
            Credential = $UserCredential

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                $userConfig = $using:UserConfig
                [System.Environment]::SetEnvironmentVariable('HTTP_PROXY',  'http://127.0.0.1:3128', 'User')
                [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', 'http://127.0.0.1:3128', 'User')
                [System.Environment]::SetEnvironmentVariable('NO_PROXY',    $userConfig.NoProxy, 'User')
            }
            TestScript = {
                $false
            }
        }
    }
}
ApplyDscConfiguration "PxProxyEnvVars"

LogTodo -Message "PxProxy: You may want to review $startPxScriptPath (and optionally $pxConfigPath) based on https://github.com/genotrance/px#usage"
