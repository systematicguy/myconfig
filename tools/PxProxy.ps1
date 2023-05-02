. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1

$pxVersion = "0.8.3"
$pxZipFile = "px-v$pxVersion-windows.zip"
$startScriptPath = "$UserBinDir\StartPxProxy.ps1"
$schTaskName = "Start Px Proxy"

Configuration PxProxy
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

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

        File StartPxProxy
        {
            DependsOn   = $unzipDependency

            Type            = 'File'
            Contents        = "$UserBinDir\px_proxy\px.exe --workers=5 --gateway"
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

            DependsOn = "[ScheduledTask]ScheduledTaskLogon"

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