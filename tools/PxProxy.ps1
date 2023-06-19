. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoRoot\windows\CredentialProvider.ps1
Import-Module CredentialManager

$pxVersion = "0.8.3"
$pxZipFile = "px-v$pxVersion-windows.zip"
$startScriptPath = "$UserBinDir\StartPxProxy.ps1"
$schTaskName = "Start Px Proxy"
$pxConfigPath = "$UserDir\px.ini"
$pxIniConfig = $UserConfig.PxProxy.PxIni
$pxCredentialTarget = "Px"
$pxIniDependencies = [System.Collections.ArrayList]@()

if (-not (Test-Path -Path $pxConfigPath)) {
    # need to ensure ASCII encoding for px proxy
    [Environment]::NewLine | Out-File -FilePath $pxConfigPath -Encoding ASCII
}

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

Configuration PxProxy
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DSCResource -ModuleName FileContentDsc

    Node localhost 
    {
        if (! (Test-Path $DscWorkDir/$pxZipFile)) {
            xRemoteFile DownloadPxProxy
            {
                DestinationPath = $DscWorkDir
                Uri             = "https://github.com/genotrance/px/releases/download/v$pxVersion/$pxZipFile"
            }
            $unzipDependency = "[xRemoteFile]DownloadPxProxy"
        } else {
            $unzipDependency = $null
        }

        Archive UnZip {
            DependsOn   = $unzipDependency
            Ensure      = "Present"
            Path        = "$DscWorkDir\$pxZipFile"
            Destination = "$UserBinDir\px_proxy"
        }

        foreach ($sectionKey in $pxIniConfig.Keys)
        {
            foreach ($key in $pxIniConfig[$sectionKey].Keys)
            {
                $iniEntry = "PxIni_$sectionKey_$key"
                $pxIniDependencies.Add("[IniSettingsFile]$iniEntry")
                IniSettingsFile $iniEntry
                {
                    Path    = $pxConfigPath
                    Section = "$sectionKey"
                    Key     = "$key"
                    Text    = $pxIniConfig[$sectionKey][$key]
                }
            }
        }

        File StartPxProxy
        {
            DependsOn   = $unzipDependency

            Type            = 'File'
            Contents        = "$UserBinDir\px_proxy\px.exe --config=$pxConfigPath"
            DestinationPath = $startScriptPath
            Ensure          = "Present"
        }

        ScheduledTask ScheduledTaskLogon
        {
            DependsOn                  = "[File]StartPxProxy"

            TaskName                   = $schTaskName
            User                       = "$UserName"
            ScheduleType               = 'AtLogOn'
            LogonType                  = "Interactive"
            ExecuteAsCredential        = $UserCredentialAtAd
            ActionExecutable           = "powershell.exe"
            ActionArguments            = $startScriptPath  
            
            Enable                     = $true
            AllowStartIfOnBatteries    = $true
            DontStopIfGoingOnBatteries = $true
            DontStopOnIdleEnd          = $true
            MultipleInstances          = "IgnoreNew"
        }

        Script StartPxProxyNow
        {
            Credential = $UserCredentialAtComputerDomain

            DependsOn = @("[ScheduledTask]ScheduledTaskLogon") + $pxIniDependencies

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                Start-ScheduledTask -TaskName $using:schTaskName
            }
            TestScript = {
                $pxProcesses = Get-Process px -ErrorAction SilentlyContinue
                if ($pxProcesses) {
                    $true
                } else {
                    $false
                }
            }
        }

        Script SetUserProxyEnvVars
        {
            # Environment resource cannot set an Environment Variable in the User's context
            Credential = $UserCredentialAtComputerDomain

            DependsOn = "[Script]StartPxProxyNow"

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

ApplyDscConfiguration "PxProxy"

LogTodo -Message "PxProxy: You may want to review $startScriptPath (and optionally $pxConfigPath) based on https://github.com/genotrance/px#usage"