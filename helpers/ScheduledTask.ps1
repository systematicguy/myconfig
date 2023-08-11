. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\helpers\ToIdentifier.ps1
. $RepoRoot\helpers\UserCredential.ps1

function EnsureScheduledTaskAndStart {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ScriptPath,
        
        [Parameter(Mandatory=$false)]
        [string]$Executable = "powershell.exe",

        [Parameter(Mandatory=$false)]
        [string]$TaskName = "",

        [Parameter(Mandatory=$false)]
        [scriptblock]$SkipStartDecisionScript = { $false }
    )

    if ($TaskName -eq "") {
        $TaskName = PathToIdentifier $ScriptPath
    }

    $dscConfigName = "ScheduledTask_$(PathToIdentifier $TaskName)"
    Configuration $dscConfigName
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName ComputerManagementDsc

        Node localhost 
        {
            ScheduledTask ScheduledTask
            {
                TaskName                   = $TaskName
                ActionExecutable           = $Executable
                ActionArguments            = $ScriptPath

                User                       = "$UserName"
                ScheduleType               = 'AtLogOn'
                LogonType                  = "Interactive"
                ExecuteAsCredential        = $UserCredential  # this was $UserCredentialAtAd
                
                Enable                     = $true
                AllowStartIfOnBatteries    = $true
                DontStopIfGoingOnBatteries = $true
                DontStopOnIdleEnd          = $true
                MultipleInstances          = "IgnoreNew"
            }

            Script StartScheduledTaskNow
            {
                DependsOn  = "[ScheduledTask]ScheduledTask"
                Credential = $UserCredential

                GetScript = {
                    #Do Nothing
                }
                SetScript = {
                    Start-ScheduledTask -TaskName $using:TaskName
                }
                TestScript = $SkipStartDecisionScript
            }
        }
    }
    Write-Host "Ensuring Scheduled Task [$TaskName] for [$ScriptPath]..."
    ApplyDscConfiguration $dscConfigName
}