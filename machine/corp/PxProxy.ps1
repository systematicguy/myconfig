. $PSScriptRoot\..\..\windows\Environment.ps1
. $PSScriptRoot\..\..\windows\UserCredential.ps1

$pxVersion = "0.8.3"
$pxZipFile = "px-v$pxVersion-windows.zip"
$startScriptPath = "$UserBinDir\StartPxProxy.ps1"
$schTaskName = "Start Px Proxy"

configuration PxProxy
{

    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [PSCredential]
        $UserCredential
    )

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
            ExecuteAsCredential        = $UserCredential
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
            Credential = $UserCredential

            DependsOn = "[ScheduledTask]ScheduledTaskLogon"

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                Start-ScheduledTask -TaskName $schTaskName
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
            Credential = $UserCredential

            DependsOn = "[Script]StartPxProxyNow"

            GetScript = {
                #Do Nothing
            }
            SetScript = {
                [System.Environment]::SetEnvironmentVariable('HTTP_PROXY',  'http://127.0.0.1:3128', 'User')
                [System.Environment]::SetEnvironmentVariable('HTTPS_PROXY', 'http://127.0.0.1:3128', 'User')
                [System.Environment]::SetEnvironmentVariable('NO_PROXY',    $UserConfig.NoProxy, 'User')
            }
            TestScript = {
                $false
            }
        }
    }
}
PxProxy -Output $DscMofDir\PxProxy -UserCredential $UserCredential -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\PxProxy -Wait -Force -Verbose