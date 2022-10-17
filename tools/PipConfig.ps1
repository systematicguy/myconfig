. $PSScriptRoot\..\windows\Environment.ps1
if ($AlreadySourced[$PSCommandPath] -eq $true) { return } else { $AlreadySourced[$PSCommandPath] = $true }

. $RepoRoot\windows\UserCredential.ps1
. $RepoToolsDir\Pyenv.ps1

Configuration PipConfig
{
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Node "localhost"
    {
        Script SetIndexUrl
        {
            PsDscRunAsCredential = $UserCredentialAtComputerDomain
            GetScript = {
                #Do Nothing
            }
            SetScript = {
                $userConfig = $using:UserConfig
                pip config --user set global.index-url $userConfig.Python.PipIndexUrl
            }
            TestScript = {
                $userConfig = $using:UserConfig
                $userConfig.Python.PipIndexUrl -eq ""  # no need to config if left as empty
            }
        }
    }
}

# TODO: parse this using pip config list -v
$PipUserConfigPath = "$env:Home\pip\pip.ini"

PipConfig -Output $DscMofDir\PipConfig -ConfigurationData $DscConfigPath
Start-DscConfiguration -Path $DscMofDir\PipConfig -Wait -Force -Verbose
